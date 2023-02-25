import Result "mo:base/Result";
import ICRCTypes "ICRCTypes";

module{

public type Options = {
  axonCanister: Principal;
  axonId : Nat;
  voiceTarget: Principal;
  icp_fee: ?Nat64;
};

public type AxonCommandExecution = {
    #Ok;
    #Transfer : {
      senderBalanceAfter : Nat;
      amount : Nat;
      receiver : Principal;
    };
    #SupplyChanged : { to : Nat; from : Nat };
  };

  public type GovernanceError = { error_message : Text; error_type : Int32 };

  public type AxonError = {
    #AlreadyVoted;
    #Error : { error_message : Text; error_type : ErrorCode };
    #CannotVote;
    #CannotExecute;
    #ProposalNotFound;
    #NotAllowedByPolicy;
    #InvalidProposal;
    #InsufficientBalance;
    #NotFound;
    #Unauthorized;
    #NotProposer;
    #NoNeurons;
    #GovernanceError : GovernanceError;
    #InsufficientBalanceToPropose;
  };

  public type ErrorCode = {
    #canister_error;
    #system_transient;
    #future : Nat32;
    #canister_reject;
    #destination_invalid;
    #system_fatal;
  };

public type BatchOp = {
  #Mint:{owner : ?Principal; amount :Nat};
  #Burn:{owner: Principal; amount : ?Nat};
  #Balance:{owner: Principal; amount : Nat};};

public type DelegationInfo = {
    delegationAccount :  ?{ 
      follower : Principal;
      followee : Principal;
      account : ICRCTypes.Account;
      address_legacy_blob : Blob;
      address_legacy_text : Text;
      address_text: Text;

    };
    removalAccount : {
      follower: Principal;
      account: ICRCTypes.Account;
      address_legacy_blob : Blob;
      address_legacy_text : Text;
      address_text: Text;
    };
    fee : Nat;
  };

public type AxonService = actor {
  mint: (Nat, Principal, Nat) -> async Result.Result<AxonCommandExecution, AxonError>;
  burn: (Nat, Principal, Nat) -> async Result.Result<AxonCommandExecution, AxonError>;
  delegate: (Nat, Principal, ?Principal) -> async Result.Result<(), AxonError>;
  mint_burn_batch : shared (Nat, [BatchOp]) -> async Result.Result<AxonCommandExecution, AxonError>;
};


}