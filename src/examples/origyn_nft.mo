
import ICRCTypes "../ICRCTypes";
import OGYNFTTypes "../OGYNFTTypes";

import VoIC "../voic";
import VoICTypes "../Types";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
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


shared (deployer) actor class ogy_voice() = this {


  stable var admin = deployer.caller;
  stable var token_address : Principal = Principal.fromText("2oqzn-paaaa-aaaaj-azrla-cai");
  stable var voice_address : Principal = Principal.fromText("zfcdd-tqaaa-aaaaq-aaaga-cai");
  stable var axon_canister : Principal = Principal.fromText("vq3jg-tiaaa-aaaao-ag2uq-cai");
  stable var secondsPerRound : Nat = 360;
  stable var axonId = 0;
  stable var force_sync = Set.new<Principal>();
  stable var accounts_at_a_time = 500;
  stable var airbrake = 0;
  stable var standardSecondsPerRound = 3600;
  stable var minSecondsPerRound = 20;
  stable var maxSecondsPerRound = 60 * 60 * 12; //at least once every 12 hours.
  stable var maxAirbrake = 100;
  stable var delegation_fee = 1000000;
  stable var account_position = 0;
  stable var log = Map.new<Int, Text>();

  var voic = VoIC.VoIC({
    axonId = axonId;
    axonCanister = axon_canister;
    voiceTarget = token_address;
    icp_fee = ?10000 : ?Nat64;
  });

  let nanosecond : Nat64 = 10 ** 9;

  let anon = Principal.fromText("2vxsx-fae");

  private func processHolders(items: [(Principal, Nat)], buffer: Buffer.Buffer<VoICTypes.BatchOp>) : () {
    
    addLog("processingHolders " # debug_show(items.size()));
    for(thisItem in items.vals()){
      if(thisItem.0 != anon){
        buffer.add(#Balance({owner = thisItem.0; amount = thisItem.1}));// mint new balance
      };
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

  private func updateSecondsPerRound(newVal : Nat) : (){
    secondsPerRound := newVal;
    if(secondsPerRound < minSecondsPerRound){
      secondsPerRound := minSecondsPerRound;
    };
     if(secondsPerRound > maxSecondsPerRound){
      secondsPerRound := maxSecondsPerRound;
    };
  };

  private func _sync_accounts() : async (){
    let service : OGYNFTTypes.Self = actor(Principal.toText(token_address));

    let buffer = Buffer.Buffer<VoICTypes.BatchOp>(1);

    
    addLog("in sync accounts");
    let accounts = try{
      let result = switch(await service.collection_nft_origyn(null)){
        case(#ok(val)){val};
        case(#err(err)){
          addLog("error in getholder" # debug_show(err));
          //handle
          if(airbrake < 100){
            airbrake += 1;
            updateSecondsPerRound(secondsPerRound * 2);
            let escape_timer = Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
          };
         return;};
      };
      let tokenids = result.token_ids;
      let accounts_result = await service.bearer_batch_nft_origyn(Option.get<[Text]>(tokenids,[]));

      addLog("have accounts " # debug_show(accounts_result.size()));
        
      let accounts = Set.new<Principal>();
      for(thisItem in accounts_result.vals()){
        switch(thisItem){
          case(#ok(val)){
            switch(val){
              case(#principal(val)){
                Set.add<Principal>(accounts, Set.phash, val);
              };
              case(#account(val)){
                Set.add<Principal>(accounts,  Set.phash, val.owner);
              };
              case(_){
                //cant deduce
                addLog("unknown account" # debug_show(val));
              };
            };  
          };
          case(#err(err)){
            //cant deduce
             addLog("unknown error" # debug_show(err));
          };
        }
      };

      

      Iter.toArray<Principal>(Set.keys<Principal>(accounts));



      
    } catch (e){
      //todo airbrake
       addLog("error occured" # Error.message(e));
      if(airbrake < 100){
        airbrake += 1;
        updateSecondsPerRound(secondsPerRound * 2);
        let escape_timer = Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
      };
      return;
    };

    addLog("holders"  # debug_show(accounts.size()));

    let principalAccounts = Iter.toArray(Iter.map<Principal, OGYNFTTypes.Account>(accounts.vals(), func(x : Principal) : OGYNFTTypes.Account{#principal(x)}));

    addLog("ready with principals"  # debug_show(principalAccounts.size()));
    if(principalAccounts.size() > 0){
      //we need to handle some archived transactions and likely shorten our time to wait.
      
      let balances = try{
        await service.balance_of_batch_nft_origyn(principalAccounts);
      } catch(e){

        addLog("balances error"  # Error.message(e));
        return;
      };

      addLog("have balances"  # debug_show(balances.size()));

      let balance_count = Buffer.Buffer<(Principal, Nat)>(balances.size());
      
      
      Iter.iterate<OGYNFTTypes.Result_19>(balances.vals(), func(x: OGYNFTTypes.Result_19, idx: Nat){
        switch(x){
          case(#ok(val)) balance_count.add((accounts[idx], val.nfts.size()));
          case(#err(err)){
            Set.add<Principal>(force_sync, Set.phash, accounts[idx]);
          };
        }
      });

      addLog("processing holders"  # debug_show(balance_count.size()));
      
      processHolders(balance_count.toArray(), buffer);

      let result = await* voic.process(buffer);

      addLog("done wint process");

      //if any errors, just wait until next time and it should be fixed? I guess we can do sync accounts as well;
      switch(result){
        case(#err(err)){
          //unfortunately it could have been any of these that failed.
          addLog("error occured with result" # debug_show(err));
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
        case(#ok(val)){

         addLog("no error");
        };
        //lets inspect this and kick this off manually if necessary
        //let force_timer = Timer.setTimer(#seconds(secondsPerRound), _force_accounts);
      };

      addLog("setting timer " # debug_show(secondsPerRound));
      let refresh_timer = Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);

    } else {
      //no accounts yet
      addLog("no accounts timer " # debug_show(secondsPerRound));
      let refresh_timer = Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
    };
  };

  private func _force_accounts() : async (){
    let failedSeeds = Buffer.Buffer<Principal>(1);

    let service : OGYNFTTypes.Self = actor(Principal.toText(token_address));

    addLog("in force accounts" # debug_show(Set.size(force_sync)));


    for(thisItem in Set.keys(force_sync)){
      addLog("getting balance for" # debug_show(thisItem));
      let result = await* voic.ogynft_seed(thisItem, switch(await service.balance_of_nft_origyn(#principal(thisItem))){
        case(#ok(val)){val.nfts.size()};
        case(#err(err)) 0;
      });
      addLog("result from force account " # debug_show(result));
      switch(result){
        case(#ok(val)){
          Set.delete(force_sync, Set.phash, thisItem);
        };
        case(#err(err)){
          addLog("force account error" # debug_show(err));
          //todo log the error somewhere retrievalble
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
    assert(msg.caller == admin);
   ignore _sync_accounts();
    return true;
  };



  

  public shared(msg) func force_accounts() : async Bool{
    assert(msg.caller == admin);
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
    assert(msg.caller == admin);
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

   public shared(msg) func set_seconds_per_round(amount: Nat) : async Bool{
    assert(msg.caller == admin);
    updateSecondsPerRound(amount);
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

  public shared(msg) func set_standard_seconds(amount: Nat) : async Bool{
    assert(msg.caller == admin);
    standardSecondsPerRound := amount;
    return true;
  };

  public shared(msg) func set_accounts_at_a_time(amount: Nat) : async Bool{
    assert(msg.caller == admin);
    accounts_at_a_time:= amount;
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
    account_position : Nat;
    admin : Principal;
    token_address : Principal;
    voice_address : Principal;
    axon_canister : Principal;
    secondsPerRound : Nat;
    standardSecondsPerround : Nat;
    axonId : Nat;
    force_sync : [Principal];
    accounts_at_a_time : Nat;
    airbrake : Nat;
    minSecondsPerRound : Nat;
    maxSecondsPerRound : Nat; 
    cycles : Nat;
  } {
    {
      account_position = account_position; 
      admin = admin; 
      token_address = token_address; 
      voice_address = voice_address; 
      axon_canister = axon_canister; 
      secondsPerRound = secondsPerRound; 
      standardSecondsPerround = standardSecondsPerRound;
      axonId = axonId; 
      force_sync = Iter.toArray<Principal>(Set.keys<Principal>(force_sync)); 
      accounts_at_a_time = accounts_at_a_time; 
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
    addLog("Processesing Delegation " # debug_show(followee, follower, block));

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