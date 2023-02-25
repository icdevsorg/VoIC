module {
  public type Account = { owner : Principal; subaccount : ?[Nat8] };
  public type ArchivedTransactionRange = {
    callback : shared query GetTransactionsRequest -> async {
        transactions : [Transaction];
      };
    start : Nat;
    length : Nat;
  };
  public type Burn = {
    from : Account;
    memo : ?[Nat8];
    created_at_time : ?Nat64;
    amount : Nat;
  };
  public type GetTransactionsRequest = { start : Nat; length : Nat };
  public type GetTransactionsResponse = {
    first_index : Nat;
    log_length : Nat;
    transactions : [Transaction];
    archived_transactions : [ArchivedTransactionRange];
  };
  public type Mint = {
    to : Account;
    memo : ?[Nat8];
    created_at_time : ?Nat64;
    amount : Nat;
  };
  public type Result = { #Ok : Nat; #Err : TransferError };
  public type StandardRecord = { url : Text; name : Text };
  public type Transaction = {
    burn : ?Burn;
    kind : Text;
    mint : ?Mint;
    timestamp : Nat64;
    transfer : ?Transfer;
  };
  public type Transfer = {
    to : Account;
    fee : ?Nat;
    from : Account;
    memo : ?[Nat8];
    created_at_time : ?Nat64;
    amount : Nat;
  };
  public type TransferArg = {
    to : Account;
    fee : ?Nat;
    memo : ?[Nat8];
    from_subaccount : ?[Nat8];
    created_at_time : ?Nat64;
    amount : Nat;
  };
  public type TransferError = {
    #GenericError : { message : Text; error_code : Nat };
    #TemporarilyUnavailable;
    #BadBurn : { min_burn_amount : Nat };
    #Duplicate : { duplicate_of : Nat };
    #BadFee : { expected_fee : Nat };
    #CreatedInFuture : { ledger_time : Nat64 };
    #TooOld;
    #InsufficientFunds : { balance : Nat };
  };

   public type BlockRange = { blocks : [CandidBlock] };

  public type ArchivedBlocksRange = {
    callback : shared query LegacyGetBlocksArgs -> async {
        #Ok : BlockRange;
        #Err : LegacyGetBlocksError;
      };
    start : Nat64;
    length : Nat64;
  };

  public type LegacyGetBlocksArgs = { start : Nat64; length : Nat64 };

  public type LegacyGetBlocksError = {
    #BadFirstBlockIndex : {
      requested_index : Nat64;
      first_valid_index : Nat64;
    };
    #Other : { error_message : Text; error_code : Nat64 };
  };

  public type QueryBlocksResponse = {
    certificate : ?[Nat8];
    blocks : [CandidBlock];
    chain_length : Nat64;
    first_block_index : Nat64;
    archived_blocks : [ArchivedBlocksRange];
  };

  public type TimeStamp = { timestamp_nanos : Nat64 };

  public type CandidBlock = {
    transaction : CandidTransaction;
    timestamp : TimeStamp;
    parent_hash : ?[Nat8];
  };

  public type Tokens = { e8s : Nat64 };

  public type CandidOperation = {
    #Approve : {
      fee : Tokens;
      from : [Nat8];
      allowance : Tokens;
      expires_at : ?TimeStamp;
      spender : [Nat8];
    };
    #Burn : { from : [Nat8]; amount : Tokens };
    #Mint : { to : [Nat8]; amount : Tokens };
    #Transfer : { to : [Nat8]; fee : Tokens; from : [Nat8]; amount : Tokens };
    #TransferFrom : {
      to : [Nat8];
      fee : Tokens;
      from : [Nat8];
      amount : Tokens;
      spender : [Nat8];
    };
  };
  public type CandidTransaction = {
    memo : Nat64;
    icrc1_memo : ?[Nat8];
    operation : CandidOperation;
    created_at_time : TimeStamp;
  };
   public type LegacyQueryBlocksResponse = {
    certificate : ?[Nat8];
    blocks : [CandidBlock];
    chain_length : Nat64;
    first_block_index : Nat64;
    archived_blocks : [ArchivedBlocksRange];
  };

   public type SendArgs = {
    to : Text;
    fee : Tokens;
    memo : Nat64;
    from_subaccount : ?[Nat8];
    created_at_time : ?TimeStamp;
    amount : Tokens;
  };

  public type Value = { #Int : Int; #Nat : Nat; #Blob : [Nat8]; #Text : Text };
  public type Self = actor {
    get_transactions : shared query GetTransactionsRequest -> async GetTransactionsResponse;
    icrc1_balance_of : shared query Account -> async Nat;
    icrc1_decimals : shared query () -> async Nat8;
    icrc1_fee : shared query () -> async Nat;
    icrc1_metadata : shared query () -> async [(Text, Value)];
    icrc1_minting_account : shared query () -> async ?Account;
    icrc1_name : shared query () -> async Text;
    icrc1_supported_standards : shared query () -> async [StandardRecord];
    icrc1_symbol : shared query () -> async Text;
    icrc1_total_supply : shared query () -> async Nat;
    icrc1_transfer : shared TransferArg -> async Result;
    query_blocks : shared query LegacyGetBlocksArgs -> async LegacyQueryBlocksResponse;
    send_dfx : shared SendArgs -> async Nat64;
  }
}