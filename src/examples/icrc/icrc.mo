
import ICRCTypes "../../ICRCTypes";

import VoIC "../../voic";
import VoICTypes "../../Types";

import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import Debug "mo:base/Debug";
import IC "mo:base/ExperimentalInternetComputer";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Timer "mo:base/Timer";
import Time "mo:base/Time";


import ExperimentalCycles "mo:base/ExperimentalCycles";
import Set "mo:map_7_0_0/Set";
import Map "mo:map_7_0_0/Map";


shared (deployer) actor class icrc_voice() = this {

  stable var next_block = 0 : Nat;
  stable var admin = deployer.caller;
  stable var token_address : Principal = Principal.fromText("zfcdd-tqaaa-aaaaq-aaaga-cai");
  stable var voice_address : Principal = Principal.fromText("zfcdd-tqaaa-aaaaq-aaaga-cai");
  stable var axon_canister : Principal = Principal.fromText("vq3jg-tiaaa-aaaao-ag2uq-cai");
  stable var secondsPerRound : Nat = 20;
  stable var axonId = 0;
  stable var force_sync = Set.new<Principal>();
  stable var seen_sub_accounts = Map.new<Principal, Set.Set<Blob>>();
  stable var transactions_at_a_time = 500;
  stable var airbrake = 0;
  stable var minSecondsPerRound = 20;
  stable var maxSecondsPerRound = 60 * 60 * 12; //at least once every 12 hours.
  stable var maxAirbrake = 100;
  stable var delegation_fee = 10000000;
  stable var log = Map.new<Int, Text>();
  stable var currentSyncTimer = 0;

  var voic = VoIC.VoIC({
    axonId = axonId;
    axonCanister = axon_canister;
    voiceTarget = token_address;
    icp_fee = ?10000 : ?Nat64;
  });

  let nanosecond : Nat64 = 10 ** 9;

  private func updateSecondsPerRound(newVal : Nat) : (){
    secondsPerRound := newVal;
    if(secondsPerRound < minSecondsPerRound){
      secondsPerRound := minSecondsPerRound;
    };
     if(secondsPerRound > maxSecondsPerRound){
      secondsPerRound := maxSecondsPerRound;
    };
  };

   private func addLog(item : Text){
    ignore Map.put(log, Map.ihash, Time.now() + Map.size(log), item);
    Debug.print(item);
    clearLog();
  };

  private func clearLog(){
    if(Map.size(log) > 2000){
      var tracker = 0;
      label clear for(thisItem in Map.entries(log)){
        Map.delete(log, Map.ihash, thisItem.0);
        tracker +=1;
        if(tracker > 1000){break clear};
      };
    };
  };

  private func processTransactions(items: [ICRCTypes.Transaction], buffer: Buffer.Buffer<VoICTypes.BatchOp>) : () {
    addLog("processingTransactions " # debug_show(items.size()));
    for(thisItem in items.vals()){
      switch(thisItem.burn){
        case(null){};
        case(?val){
          addLog("found a burn " # debug_show(val.from, val.amount));
          switch(val.from.subaccount){
            case(?sub){
              let thisSet : Set.Set<Blob> = Option.get(Map.get<Principal, Set.Set<Blob>>(seen_sub_accounts, Map.phash, val.from.owner), do{
                  let aSet = Set.new<Blob>();
                  ignore Map.put<Principal, Set.Set<Blob>>(seen_sub_accounts, Map.phash, val.from.owner, aSet);
                  aSet;
                }
              );
              Set.add<Blob>(thisSet, Set.bhash, Blob.fromArray(sub));
            };
            case(null){};
          };
          if(val.amount > 0) buffer.add(#Burn({owner = val.from.owner; amount = ?val.amount }));
        };
      };
      switch(thisItem.mint){
        case(null){};
        case(?val){
          addLog("found a mint " # debug_show(val.to, val.amount));
          switch(val.to.subaccount){
            case(?sub){
              let thisSet : Set.Set<Blob> = Option.get(Map.get<Principal, Set.Set<Blob>>(seen_sub_accounts, Map.phash, val.to.owner), do{
                  let aSet = Set.new<Blob>();
                  ignore Map.put<Principal, Set.Set<Blob>>(seen_sub_accounts, Map.phash, val.to.owner, aSet);
                  aSet;
                }
              );
              Set.add<Blob>(thisSet, Set.bhash, Blob.fromArray(sub));
            };
            case(null){};
          };

          if(val.amount > 0) buffer.add(#Mint({owner = ?val.to.owner; amount = val.amount}));
        };
      };
      switch(thisItem.transfer){
        case(null){};
        case(?val){
          //only have to add the tos as we should have seen the froms before
          addLog("found a transfer " # debug_show(val.to, val.from, val.amount));
          switch(val.to.subaccount){
            case(?sub){
              let thisSet : Set.Set<Blob> = Option.get(Map.get<Principal, Set.Set<Blob>>(seen_sub_accounts, Map.phash, val.to.owner), do{
                  let aSet = Set.new<Blob>();
                  ignore Map.put<Principal, Set.Set<Blob>>(seen_sub_accounts, Map.phash, val.to.owner, aSet);
                  aSet;
                }
              );
              Set.add<Blob>(thisSet, Set.bhash, Blob.fromArray(sub));
            };
            case(null){};
          };

          if((val.amount + Option.get(val.fee,0)) > 0) buffer.add(#Burn({owner =val.from.owner; amount = ?(val.amount + Option.get(val.fee,0))}));
          if(val.amount > 0) buffer.add(#Mint({owner = ?val.to.owner; amount = val.amount}));
        };
      };
    };
  };

  private func _sync_accounts() : async (){
    addLog("in _sync_accounts " # debug_show(next_block));
    let service : ICRCTypes.Self = actor(Principal.toText(token_address));

    let buffer = Buffer.Buffer<VoICTypes.BatchOp>(1);

    let this_next_block = next_block;
    let this_transactions_at_a_time = transactions_at_a_time;
    var numberProcessed = 0;

    let transactions = try{
      await service.get_transactions({start = this_next_block; length = this_transactions_at_a_time;});
    } catch (e){
      //todo airbrake
      addLog("caught sync account error " # Error.message(e));
      if(airbrake < 100){
        airbrake += 1;
        currentSyncTimer := Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
      };
      return;
    };

    addLog("archive size " # debug_show(transactions.archived_transactions.size()));

    if(transactions.archived_transactions.size() > 0){
      //we need to handle some archived transactions and likely shorten our time to wait.
      updateSecondsPerRound(secondsPerRound / 2);

      try{
        for(thisItem in transactions.archived_transactions.vals()){
          addLog("calling archive " # debug_show(thisItem.start, thisItem.length));
          let archive = await thisItem.callback({start = thisItem.start; length = thisItem.length});
          addLog("archive size pulled" # debug_show(archive.transactions.size()));
          numberProcessed += archive.transactions.size();
          processTransactions(archive.transactions, buffer);
        };
      } catch(e){
        addLog("caught sync account error in archive " # Error.message(e));
        if(airbrake < 100){
          airbrake += 1;
          currentSyncTimer := Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
        };
        return;
      };
    };

     addLog("found blocks " # debug_show(transactions.transactions.size()));

    if(transactions.transactions.size() > 0){
      numberProcessed += transactions.transactions.size();
      processTransactions(transactions.transactions, buffer);
    } else {
      //we can slow down
      addLog("should we slow down? " # debug_show(transactions.transactions.size()));
      if( transactions.archived_transactions.size() == 0){
        addLog("slowing down");
        updateSecondsPerRound(secondsPerRound * 2);
      } ;
    };

    let result = await* voic.process(buffer);

    //if any errors, force sync those accounts;
    switch(result){
      case(#err(err)){
        addLog("caught process error " # debug_show(err));
        //unfortunately it could have been any of these that failed.
        for(thisItem in buffer.vals()){
          switch(thisItem){
            case(#Mint(data)){
              switch(data.owner){
                case(?val) Set.add<Principal>(force_sync, Set.phash, val);
                case(null){Set.add<Principal>(force_sync, Set.phash, voice_address)};
              };
            };
            case(#Burn(data)){
              Set.add<Principal>(force_sync, Set.phash, data.owner);
            };
            case(#Balance(data)){
              Set.add<Principal>(force_sync, Set.phash, data.owner);
            };
          };
        };
      };
      case(#ok(val)){};
      //lets inspect this and kick this off manually if necessary
      //let force_timer = Timer.setTimer(#seconds(secondsPerRound), _force_accounts);
    };

    next_block := this_next_block + numberProcessed;
    addLog("next block is " # debug_show(next_block));
    currentSyncTimer :=  Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
  };

  private func _force_accounts() : async (){
    let failedSeeds = Buffer.Buffer<Principal>(1);
    addLog("in force accounts" # debug_show(Set.size(force_sync)));

    for(thisItem in Set.keys(force_sync)){
      addLog("getting balance for" # debug_show(thisItem));
      let result = await* voic.icrc1_seed(thisItem, Iter.toArray<[Nat8]>(Iter.map<Blob,[Nat8]>(Set.keys<Blob>(Option.get(Map.get<Principal, Set.Set<Blob>>(seen_sub_accounts, Map.phash, thisItem), Set.new<Blob>())), func(x){Blob.toArray(x)})));
      addLog("result from force account " # debug_show(result));
      switch(result){
        case(#ok(val)){
          Set.delete(force_sync, Set.phash, thisItem);
        };
        case(#err(err)){
          //todo log the error somewhere retrievalble
          addLog("force account error" # debug_show(err));
          if(airbrake < 100){
            airbrake += 1;
            let force_timer = Timer.setTimer(#seconds(secondsPerRound), _force_accounts);
          };
          //if one error occurs...it is likely man more will as well
          return;
        };
      };
    };
  };

 

   public shared(msg) func start_sync() : async Bool{
    Timer.cancelTimer(currentSyncTimer);
    ignore _sync_accounts();
    return true;
  };

  public shared(msg) func inject_subaccount(request : [(Principal, ?Blob)]) : async Bool{
    addLog("injecting subaccount" # debug_show(request));
   for((principal, subaccount) in request.vals()){
    
    
    let thisSet : Set.Set<Blob> = Option.get(Map.get<Principal, Set.Set<Blob>>(seen_sub_accounts, Map.phash, principal), do{
          let aSet = Set.new<Blob>();
          ignore Map.put<Principal, Set.Set<Blob>>(seen_sub_accounts, Map.phash, principal, aSet);
          aSet;
        }
      );
      Set.add<Blob>(thisSet, Set.bhash, Option.get(subaccount, Blob.fromArray([])));
   };
    return true;
  };

  public shared(msg) func force_accounts() : async Bool{
    ignore _force_accounts();
    return true;
  };

  public shared(msg) func add_force_accounts(request : [Principal]) : async Bool{
    addLog("adding principal to force account" # debug_show(request));
    for(principal in request.vals()){
      assert(msg.caller == principal or msg.caller == admin); //only an owner or admin can add their subaccount
      Set.add(force_sync, Set.phash, principal);
    };
    ignore force_accounts();
    return true;
  };

 

  public shared(msg) func reset_airbrake() : async Bool{
    //get the transactions since the last block;
    addLog("reset airbrake");
    airbrake := 0;
    return true;
  };

  public shared(msg) func set_admin(account: Principal) : async Bool{
    assert(msg.caller == admin);
    admin:= account;
    return true;
  };

  public shared(msg) func set_token_address(account: Principal) : async Bool{
    assert(msg.caller == admin);
    token_address:= account;
    voic := VoIC.VoIC({
      axonId = axonId;
      axonCanister = axon_canister;
      voiceTarget = token_address;
      icp_fee = ?10000 : ?Nat64;
    });
    return true;
  };

  public shared(msg) func set_voice_address(account: Principal) : async Bool{
    assert(msg.caller == admin);
    voice_address:= account;
    return true;
  };

  public shared(msg) func set_axon_canister(account: Principal) : async Bool{
    assert(msg.caller == admin);
    axon_canister:= account;
    voic := VoIC.VoIC({
      axonId = axonId;
      axonCanister = axon_canister;
      voiceTarget = token_address;
      icp_fee = ?10000 : ?Nat64;
    });
    return true;
  };

  public shared(msg) func set_axon_id(id: Nat) : async Bool{
    assert(msg.caller == admin);
    axonId:= id;
    voic := VoIC.VoIC({
      axonId = axonId;
      axonCanister = axon_canister;
      voiceTarget = token_address;
      icp_fee = ?10000 : ?Nat64;
    });
    return true;
  };

  public shared(msg) func set_min_seconds(amount: Nat) : async Bool{
    assert(msg.caller == admin);
    minSecondsPerRound:= amount;
    return true;
  };

  public shared(msg) func set_max_seconds(amount: Nat) : async Bool{
    assert(msg.caller == admin);
    maxSecondsPerRound:= amount;
    return true;
  };

  public shared(msg) func set_transactions_at_a_time(amount: Nat) : async Bool{
    assert(msg.caller == admin);
    transactions_at_a_time:= amount;
    return true;
  };

  public shared(msg) func set_delegation_fee(amount: Nat) : async Bool{
    assert(msg.caller == admin);
    delegation_fee := amount;
    return true;
  };

  public query func get_log() : async [(Int, Text)]{
    Iter.toArray(Map.entries(log));
  };


  public query func get_metrics() : async {
    next_block : Nat;
    admin : Principal;
    token_address : Principal;
    voice_address : Principal;
    axon_canister : Principal;
    secondsPerRound : Nat;
    axonId : Nat;
    force_sync : [Principal];
    transactions_at_a_time : Nat;
    airbrake : Nat;
    minSecondsPerRound : Nat;
    maxSecondsPerRound : Nat; 
    cycles : Nat;
  } {
    {
      next_block = next_block; 
      admin = admin; 
      token_address = token_address; 
      voice_address = voice_address; 
      axon_canister = axon_canister; 
      secondsPerRound = secondsPerRound; 
      axonId = axonId; 
      force_sync = Iter.toArray<Principal>(Set.keys<Principal>(force_sync)); 
      transactions_at_a_time = transactions_at_a_time; 
      airbrake = airbrake; 
      minSecondsPerRound = minSecondsPerRound; 
      maxSecondsPerRound = maxSecondsPerRound; 
      cycles  = ExperimentalCycles.balance();
    };
  };

  public query func cycles() : async Nat {
    ExperimentalCycles.balance();
  };

  public query(msg) func get_delegation_info(followee: ?Principal, follower: ICRCTypes.Account) : async VoICTypes.DelegationInfo{
    return voic.get_delegation_info(followee, follower, Principal.fromActor(this), delegation_fee);
  };

  private func isAnonymous(caller: Principal) : Bool {
    Principal.equal(caller, Principal.fromText("2vxsx-fae"))
  };

  public shared(msg) func process_delegation(followee: ?Principal, follower: ICRCTypes.Account, block : Nat64) : async Result.Result<Bool, Text>{
    if(followee != ?msg.caller and followee != null){
      return(#err("unauthorized"));
    };
    return await* voic.process_delegation(followee, follower, block, Principal.fromActor(this), delegation_fee);
  };

  system func postupgrade() {
    /* if(airbrake < maxAirbrake){
      let refresh_timer = Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
    };
    if(Set.size<Principal>(force_sync) > 0 and airbrake < maxAirbrake){
      let force_timer = Timer.setTimer(#seconds(secondsPerRound * 2), _force_accounts);
    }; */
  };

  

};