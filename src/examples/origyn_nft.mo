
import ICRCTypes "../ICRCTypes";
import OGYNFTTypes "../OGYNFTTypes";

import VoIC "../voic";
import VoICTypes "../Types";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import IC "mo:base/ExperimentalInternetComputer";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Timer "mo:base/Timer";


import ExperimentalCycles "mo:base/ExperimentalCycles";
import Set "mo:map_7_0_0/Set";
import Map "mo:map_7_0_0/Map";


shared (deployer) actor class ogy_voice() = this {


  stable var admin = deployer.caller;
  stable var token_address : Principal = Principal.fromText("2oqzn-paaaa-aaaaj-azrla-cai");
  stable var voice_address : Principal = Principal.fromText("zfcdd-tqaaa-aaaaq-aaaga-cai");
  stable var axon_caniser : Principal = Principal.fromText("vq3jg-tiaaa-aaaao-ag2uq-cai");
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

  let voic = VoIC.VoIC({
    axonId = axonId;
    axonCanister = axon_caniser;
    voiceWallet = voice_address;
    icp_fee = ?10000 : ?Nat64;
  });

  let nanosecond : Nat64 = 10 ** 9;

  private func processHolders(items: [(Principal, Nat)], buffer: Buffer.Buffer<VoICTypes.BatchOp>) : () {
    for(thisItem in items.vals()){
      buffer.add(#Burn({owner = thisItem.0; amount = null})); //burn it all
      buffer.add(#Mint({owner = ?thisItem.0; amount = thisItem.1}));// mint new balance
    };
  };

  private func updateSecondsPerRound(newVal : Nat) : (){
    secondsPerRound := secondsPerRound / 2;
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

    

    let accounts = try{
      let result = switch(await service.collection_nft_origyn(null)){
        case(#ok(val)){val};
        case(#err(err)){
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
              };
            };  
          };
          case(#err(err)){
            //cant deduce
          };
        }
      };

      Iter.toArray<Principal>(Set.keys<Principal>(accounts));

      
    } catch (e){
      //todo airbrake
      if(airbrake < 100){
        airbrake += 1;
        updateSecondsPerRound(secondsPerRound * 2);
        let escape_timer = Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
      };
      return;
    };

    let principalAccounts = Iter.toArray(Iter.map<Principal, OGYNFTTypes.Account>(accounts.vals(), func(x : Principal) : OGYNFTTypes.Account{#principal(x)}));

    if(principalAccounts.size() > 0){
      //we need to handle some archived transactions and likely shorten our time to wait.
      let balances = await service.balance_of_batch_nft_origyn(principalAccounts);

      let balance_count = Buffer.Buffer<(Principal, Nat)>(balances.size());
      
      
      Iter.iterate<OGYNFTTypes.Result_19>(balances.vals(), func(x: OGYNFTTypes.Result_19, idx: Nat){
        switch(x){
          case(#ok(val)) balance_count.add((accounts[idx], val.nfts.size()));
          case(#err(err)){
            Set.add<Principal>(force_sync, Set.phash, accounts[idx]);
          };
        }
      });
      
      processHolders(balance_count.toArray(), buffer);

      let result = await* voic.process(buffer);

      //if any errors, just wait until next time and it should be fixed? I guess we can do sync accounts as well;
      switch(result){
        case(#err(err)){
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
            };
          };
        };
        case(#ok(val)){};
        //lets inspect this and kick this off manually if necessary
        //let force_timer = Timer.setTimer(#seconds(secondsPerRound), _force_accounts);
      };
      let refresh_timer = Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);

    } else {
      //no accounts yet
      let refresh_timer = Timer.setTimer(#seconds(secondsPerRound), _sync_accounts);
    };
  };

  private func _force_accounts() : async (){
    let failedSeeds = Buffer.Buffer<Principal>(1);

    let service : OGYNFTTypes.Self = actor(Principal.toText(token_address));


    for(thisItem in Set.keys(force_sync)){
      let result = await* voic.ogynft_seed(thisItem, switch(await service.balance_of_nft_origyn(#principal(thisItem))){
        case(#ok(val)){val.nfts.size()};
        case(#err(err)) 0;
      });
      switch(result){
        case(#ok(val)){
          Set.delete(force_sync, Set.phash, thisItem);
        };
        case(#err(err)){
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
   ignore _sync_accounts();
    return true;
  };

  

  public shared(msg) func force_accounts() : async Bool{
    ignore _force_accounts();
    return true;
  };

  public shared(msg) func add_force_accounts(request : [Principal]) : async Bool{
  
    for(principal in request.vals()){
      assert(msg.caller == principal or msg.caller == admin); //only an owner or admin can add their subaccount
      Set.add(force_sync, Set.phash, principal);
    };
    ignore force_accounts();
    return true;
  };

  public shared(msg) func reset_airbrake() : async Bool{
    //get the transactions since the last block;
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
    return true;
  };

  public shared(msg) func set_voice_address(account: Principal) : async Bool{
    assert(msg.caller == admin);
    voice_address:= account;
    return true;
  };

  public shared(msg) func set_axon_canisers(account: Principal) : async Bool{
    assert(msg.caller == admin);
    axon_caniser:= account;
    return true;
  };

  public shared(msg) func set_axon_id(id: Nat) : async Bool{
    assert(msg.caller == admin);
    axonId:= id;
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


  public query func get_metrics() : async {
    account_position : Nat;
    admin : Principal;
    token_address : Principal;
    voice_address : Principal;
    axon_caniser : Principal;
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
      axon_caniser = axon_caniser; 
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