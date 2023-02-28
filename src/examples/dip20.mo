
import ICRCTypes "../ICRCTypes";
import DIP20Types "../DIP20Types";

import VoIC "../voic";
import VoICTypes "../Types";

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


shared (deployer) actor class dip20_voice() = this {


  stable var admin = deployer.caller;
  stable var token_address : Principal = Principal.fromText("5gxp5-jyaaa-aaaag-qarma-cai");
  stable var voice_address : Principal = Principal.fromText("zfcdd-tqaaa-aaaaq-aaaga-cai");
  stable var axon_canister : Principal = Principal.fromText("vq3jg-tiaaa-aaaao-ag2uq-cai");
  stable var secondsPerRound : Nat = 20;
  stable var axonId = 0;
  stable var force_sync = Set.new<Principal>();
  stable var accounts_at_a_time = 50000;
  stable var airbrake = 0;
  stable var standardSecondsPerRound = 3600;
  stable var minSecondsPerRound = 20;
  stable var maxSecondsPerRound = 60 * 60 * 12; //at least once every 12 hours.
  stable var maxAirbrake = 100;
  stable var delegation_fee = 1000000;
  stable var account_position = 0;
  stable var log = Map.new<Int, Text>();
  stable var currentSyncTimer = 0;

  var voic = VoIC.VoIC({
    axonId = axonId;
    axonCanister = axon_canister;
    voiceTarget = token_address;
    icp_fee = ?10000 : ?Nat64;
  });

  let nanosecond : Nat64 = 10 ** 9;

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

  let anon = Principal.fromText("2vxsx-fae");

  private func processHolders(items: [(Principal, Nat)], buffer: Buffer.Buffer<VoICTypes.BatchOp>) : () {
    addLog("processingHolders " # debug_show(items.size()));
    for(thisItem in items.vals()){
      if(thisItem.0 != anon){
        buffer.add(#Balance({owner = thisItem.0; amount = thisItem.1}));// mint new balance
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
    let service : DIP20Types.Self = actor(Principal.toText(token_address));

    let buffer = Buffer.Buffer<VoICTypes.BatchOp>(1);

    
    addLog("in sync accounts");
    let holders = try{
      await service.getHolders(account_position, accounts_at_a_time);
    } catch (e){
      addLog("error in getholder" # Error.message(e));
      //todo airbrake
      if(airbrake < 100){
        airbrake += 1;
        updateSecondsPerRound(secondsPerRound * 2);
        currentSyncTimer := Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
      };
      return;
    };

    addLog("holders"  # debug_show(holders.size()));

    if(holders.size() > 0){
      //we need to handle some archived transactions and likely shorten our time to wait.
      updateSecondsPerRound(standardSecondsPerRound);
      processHolders(holders, buffer);
      let next_round = if(holders.size() == accounts_at_a_time){
        account_position += accounts_at_a_time;
        5;
        
      } else{
        account_position :=0;
        secondsPerRound;
      };

      addLog("have next round"  # debug_show(next_round));
       let result : Result.Result<VoICTypes.AxonCommandExecution, VoICTypes.AxonError> = try{
          let a_result = await* voic.process(buffer);
          addLog("have result"  # debug_show(a_result));
          a_result
        
      } catch(err){
        addLog("err in await* "  # debug_show(Error.message(err)));
        #err(#Error({error_message = Error.message(err); error_type = #canister_error}));
      };

      
      

      //if any errors, just wait until next time and it should be fixed? I guess we can do sync accounts as well;
      switch(result){
        case(#err(err)){
          addLog("found an error"  # debug_show(err));
          //unfortunately it could have been any of these that faileDebug.
          
        };
        case(#ok(val)){
          addLog("no error found");
        //lets inspect this and kick this off manually if necessary
        //let force_timer = Timer.setTimer(#seconds(secondsPerRound), _force_accounts);
        }
      };

      
      currentSyncTimer := Timer.setTimer(#seconds(next_round), _sync_accounts);
      addLog("setting next timer"  # debug_show(currentSyncTimer));

    } else {
      //no accounts yet
      currentSyncTimer := Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
    };
  };

 

  private func _force_accounts() : async (){
    let failedSeeds = Buffer.Buffer<Principal>(1);

    let service : DIP20Types.Self = actor(Principal.toText(token_address));

    addLog("in force accounts" # debug_show(Set.size(force_sync)));


    for(thisItem in Set.keys(force_sync)){
      addLog("getting balance for" # debug_show(thisItem));
      let result = await* voic.dip20_seed(thisItem, await service.balanceOf(thisItem));
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
    assert(msg.caller == admin);
    Timer.cancelTimer(currentSyncTimer);
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

   public shared(msg) func set_seconds_per_round(amount: Nat) : async Bool{
    assert(msg.caller == admin);
    updateSecondsPerRound(amount);
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

  public shared(msg) func clear_force_sync(amount: Nat) : async Bool{
    assert(msg.caller == admin);
    force_sync := Set.new<Principal>();
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