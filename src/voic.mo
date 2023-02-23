import Types "Types";
import ICRCTypes "ICRCTypes";

import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import D "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import SHA256 "mo:crypto/SHA/SHA256";
import AccountIdentifier "mo:principalmo/AccountIdentifier";
import Hex "mo:encoding/Hex";

import Conversions "mo:candy_0_1_12/conversion";


module {
  public class VoIC(options: Types.Options) {

    let axon : Types.AxonService = actor(Principal.toText(options.axonCanister));
    let icp_fee : Nat64 = Option.get(options.icp_fee, 10000 : Nat64);
    let axonId = options.axonId;
    let voiceWallet : ICRCTypes.Self = actor(Principal.toText(options.voiceWallet));
    let icpWallet : ICRCTypes.Self = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");
    let donationWallet : Text = "d006f15acf418a039559d0bef90367a8302524c1511b3307f2f4e3c1020903e8";
    

    public func process(buffer: Buffer.Buffer<Types.BatchOp>) : async* Result.Result<Types.AxonCommandExecution, Types.AxonError> {
      let results = await axon.mint_burn_batch(axonId, buffer.toArray());
      return results;
    };

    public func icrc1_seed(owner: Principal, subaccounts: [[Nat8]]) : async* Result.Result<Types.AxonCommandExecution, Types.AxonError>{
      var balance = 0;

      //todo: Make sure the Nats aren't too long

      let results = Buffer.Buffer<async Nat>(9);

      var totalSeed = 0;

      totalSeed += await voiceWallet.icrc1_balance_of({owner = owner; subaccount = null});

      //todo: refactor to batch when available
      for(thisItem in subaccounts.vals()){
        results.add(voiceWallet.icrc1_balance_of({owner = owner; subaccount = ?thisItem}));
        if(results.size() == 9){
          for(thisItem in results.vals()){
            totalSeed += await thisItem
          };
          results.clear();
        };
      };

      for(thisItem in results.vals()){
        totalSeed += await thisItem
      };

      if(balance == 0){
        return await axon.mint_burn_batch(axonId, [#Burn({owner = owner; amount = null;})]);
      } else {
        return await axon.mint_burn_batch(axonId, [#Burn({owner = owner; amount = null;}), #Mint({owner=?owner; amount = totalSeed})]);
      };
    };

    public func dip20_seed(owner: Principal, balance: Nat) : async* Result.Result<Types.AxonCommandExecution, Types.AxonError>{
      var balance = 0;

      //todo: Make sure the Nats aren't too long

      let results = Buffer.Buffer<async Nat>(9);

      var totalSeed = 0;

      totalSeed += balance;

       if(balance == 0){
        return await axon.mint_burn_batch(axonId, [#Burn({owner = owner; amount = null;})]);
      } else {
        return await axon.mint_burn_batch(axonId, [#Burn({owner = owner; amount = null;}), #Mint({owner=?owner; amount = totalSeed})]);
      };
    };

    public func ogynft_seed(owner: Principal, balance: Nat) : async* Result.Result<Types.AxonCommandExecution, Types.AxonError>{
      var balance = 0;

      //todo: Make sure the Nats aren't too long

      let results = Buffer.Buffer<async Nat>(9);

      var totalSeed = 0;

      totalSeed += balance;

      if(balance == 0){
        return await axon.mint_burn_batch(axonId, [#Burn({owner = owner; amount = null;})]);
      } else {
        return await axon.mint_burn_batch(axonId, [#Burn({owner = owner; amount = null;}), #Mint({owner=?owner; amount = totalSeed})]);
      };
    };

    public func mint(owner: Principal, amount: Nat) : async* Result.Result<Types.AxonCommandExecution, Types.AxonError>{
      return(await axon.mint(axonId, owner, amount));
    };

    public func burn(owner: Principal, amount: Nat) : async* Result.Result<Types.AxonCommandExecution, Types.AxonError>{
      return(await axon.burn(axonId, owner, amount));
    };

    public func transfer(from_owner: Principal, to_owner:Principal, amount: Nat) : async* Result.Result<Types.AxonCommandExecution, Types.AxonError>{
      await axon.mint_burn_batch(axonId, [#Burn({owner=from_owner; amount = ?amount}),#Mint({owner = ?to_owner; amount = amount})]);
    };

    public func get_delegation_info(caller: ?Principal, follower: ICRCTypes.Account, canister: Principal, fee: Nat) : Types.DelegationInfo{
      //delegation Account
      //delegation removal Account
      D.print("Getting delegation account");

      let h = SHA256.New();
      h.write(Conversions.valueToBytes(#Text("com.voic.delegation.remove")));
      h.write(Conversions.valueToBytes(#Text("follower")));
      h.write(Conversions.valueToBytes(#Principal(follower.owner)));
      h.write(Conversions.valueToBytes(#Text("canister")));
      h.write(Conversions.valueToBytes(#Principal(canister)));
      let sub_hash_remove = h.sum([]);


      switch(caller){
          case(null){
            return {
              delegationAccount =  null;
              removalAccount = { 
                follower = follower.owner;
                account = {
                  owner = canister;
                  subaccount = ?sub_hash_remove;
                };
                address_legacy_blob = Blob.fromArray(AccountIdentifier.addHash(AccountIdentifier.fromPrincipal(canister, ?sub_hash_remove)));
                address_legacy_text = Hex.encode(AccountIdentifier.addHash(AccountIdentifier.fromPrincipal(canister, ?sub_hash_remove)));
                address_text = "NYI";
              };
              fee = fee;
            }
          };
          case(?followee){

            let h = SHA256.New();
            h.write(Conversions.valueToBytes(#Text("com.voic.delegation.set")));
            h.write(Conversions.valueToBytes(#Text("caller")));
            h.write(Conversions.valueToBytes(#Principal(followee)));
            h.write(Conversions.valueToBytes(#Text("follower")));
            h.write(Conversions.valueToBytes(#Principal(follower.owner)));
            h.write(Conversions.valueToBytes(#Text("canister")));
            h.write(Conversions.valueToBytes(#Principal(canister)));
            let sub_hash_delegation =h.sum([]);
  

            return {
              delegationAccount =  ?{
                follower= follower.owner;
                followee = followee;
                account = {
                  owner = canister;
                  subaccount = ?sub_hash_delegation;
                };
                address_legacy_blob = Blob.fromArray(AccountIdentifier.addHash(AccountIdentifier.fromPrincipal(canister, ?sub_hash_delegation)));
                address_legacy_text = Hex.encode(AccountIdentifier.addHash(AccountIdentifier.fromPrincipal(canister, ?sub_hash_delegation)));
                address_text = "NYI";
              };
            
              removalAccount = { 
                follower = follower.owner;
                account = {
                  owner = canister;
                  subaccount = ?sub_hash_delegation;
                };
                address_legacy_blob = Blob.fromArray(AccountIdentifier.addHash(AccountIdentifier.fromPrincipal(canister, ?sub_hash_remove)));
                address_legacy_text = Hex.encode(AccountIdentifier.addHash(AccountIdentifier.fromPrincipal(canister, ?sub_hash_remove)));
                address_text = "NYI";
              };
              fee = fee;
            };
          };
      };
    };

  private func clearFee(subaccount: ?[Nat8], amount: Nat64): async* Nat64{
    return await icpWallet.send_dfx{
      from_subaccount = subaccount;
      to = donationWallet;
      created_at_time = null;
      memo = 0;
      fee = {e8s = icp_fee};
      amount = {e8s = amount - icp_fee};
    }
  };

  public func process_delegation(caller: ?Principal, follower: ICRCTypes.Account, block: Nat64, canister: Principal, fee: Nat): async* Result.Result<Bool, Text>{
      //delegation Account
      //delegation removal Account
      D.print("Getting delegation account");

      let account = switch(caller){
        case(?val){
          let h = SHA256.New();
          h.write(Conversions.valueToBytes(#Text("com.voic.delegation.set")));
          h.write(Conversions.valueToBytes(#Text("caller")));
          h.write(Conversions.valueToBytes(#Principal(val)));
          h.write(Conversions.valueToBytes(#Text("follower")));
          h.write(Conversions.valueToBytes(#Principal(follower.owner)));
          h.write(Conversions.valueToBytes(#Text("canister")));
          h.write(Conversions.valueToBytes(#Principal(canister)));
          h.sum([]);
        };
        case(null){
          let h = SHA256.New();
          h.write(Conversions.valueToBytes(#Text("com.voic.delegation.remove")));
          h.write(Conversions.valueToBytes(#Text("follower")));
          h.write(Conversions.valueToBytes(#Principal(follower.owner)));
          h.write(Conversions.valueToBytes(#Text("canister")));
          h.write(Conversions.valueToBytes(#Principal(canister)));
          h.sum([]);
        };
      };

      //verify the fee
      let found_balance = icpWallet.icrc1_balance_of({owner = canister; subaccount = ?account});
      let found_block = try{
        await icpWallet.query_blocks({start = block; length = 1});
      } catch(err){
        return #err("Ledger Error: " # Error.message(err));
      };

      let transaction = if(found_block.blocks.size() > 0){
        found_block.blocks[0];
      } else {
        try{
          let archiveblock = switch(await found_block.archived_blocks[0].callback({start = found_block.archived_blocks[0].start; length =1})){
            case(#Ok(archiveblock)){
              if(archiveblock.blocks.size() > 0){
                archiveblock.blocks[0];
              } else {
                return #err("Archive Error: Block not found.");
              };
            };
            case(#Err(err)){
              return #err("Archive Error: " # debug_show(err));
            };
          };
          
        } catch(e){
          return #err("Archive Error: " # Error.message(e));
        };
      };

      switch(await found_balance, transaction){
        case(found_balance, transaction){
          if(found_balance >= fee){
            switch(caller){
              case(null){
                //if the transaction was sourced properly then we will remove the delegation
                switch(transaction.transaction.operation){
                  case(#Transfer(details)){
                    if(details.to == AccountIdentifier.addHash(AccountIdentifier.fromPrincipal(canister, ?account)) and
                      details.from == AccountIdentifier.addHash(AccountIdentifier.fromPrincipal(follower.owner, follower.subaccount))){
                      switch(await axon.delegate(axonId, follower.owner, null)){
                        case(#ok){
                          //delegation occured so lets remove the fee
                          let clear = clearFee(?account, Nat64.fromNat(found_balance));
                          return #ok(true);
                        };
                        case(_){
                          return #err("delegation operation");
                        };
                      };
                    } else {
                      return #err("Invalid Block Args" # debug_show(details));
                    };
                  };
                  case(_){
                    return #err("Operation Error " # debug_show(transaction.transaction.operation));
                  };
                }
                
              };
              case(?val){
                //if the transaction was sourced properly then we will set up the delegation.
                switch(transaction.transaction.operation){
                  case(#Transfer(details)){
                    if(details.to == AccountIdentifier.addHash(AccountIdentifier.fromPrincipal(canister, ?account)) and
                      details.from == AccountIdentifier.addHash(AccountIdentifier.fromPrincipal(follower.owner, follower.subaccount))){
                      switch(await axon.delegate(axonId, follower.owner, ?val)){
                        case(#ok){
                          //delegation occured so lets remove the fee
                          let clear = clearFee(?account, Nat64.fromNat(found_balance));
                          return #ok(true);
                        };
                        case(_){
                          return #err("delegation operation");
                        };
                      };
                    } else {
                      return #err("Invalid Block Args" # debug_show(details));
                    };
                  };
                  case(_){
                    return #err("Operation Error " # debug_show(transaction.transaction.operation));
                  };
                }
              };
            };
          } else {
            return #err("Insufficent Funds " # debug_show(found_balance, fee));
          };
        };
        
      }
      
    };
  };
}