// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
  public type Burner = { burnedAmount : Nat; earnedAmount : Nat };
  public type HeaderField = (Text, Text);
  public type Metadata = {
    fee : Nat;
    decimals : Nat8;
    owner : Principal;
    logo : Text;
    name : Text;
    totalSupply : Nat;
    symbol : Text;
  };
  public type Request = {
    url : Text;
    method : Text;
    body : [Nat8];
    headers : [HeaderField];
  };
  public type Response = {
    body : [Nat8];
    headers : [HeaderField];
    streaming_strategy : ?StreamingStrategy;
    status_code : Nat16;
  };
  public type StreamingCallback = shared query StreamingCallbackToken -> async StreamingCallbackResponse;
  public type StreamingCallbackResponse = {
    token : ?StreamingCallbackToken;
    body : [Nat8];
  };
  public type StreamingCallbackToken = {
    key : Nat32;
    sha256 : ?[Nat8];
    index : Nat32;
    content_encoding : Text;
  };
  public type StreamingStrategy = {
    #Callback : {
      token : StreamingCallbackToken;
      callback : StreamingCallback;
    };
  };
  public type Time = Int;
  public type TokenInfo = {
    holderNumber : Nat;
    deployTime : Time;
    metadata : Metadata;
    historySize : Nat;
    cycles : Nat;
    feeTo : Principal;
  };
  public type TxReceipt = {
    #Ok : Text;
    #Err : {
      #InsufficientAllowance;
      #InsufficientBalance;
      #ErrorOperationStyle;
      #Unauthorized;
      #LedgerTrap;
      #ErrorTo;
      #Other : Text;
      #BlockUsed;
      #AmountTooSmall;
    };
  };
  public type Self = actor {
    allowance : shared query (Principal, Principal) -> async Nat;
    approve : shared (Principal, Nat) -> async TxReceipt;
    balanceOf : shared query Principal -> async Nat;
    burn : shared Nat -> async TxReceipt;
    chargeTax : shared (Principal, Nat) -> async Text;
    decimals : shared query () -> async Nat8;
    distributeTransactions : shared () -> async ();
    fetchBurners : shared query (Nat, Nat) -> async [(Principal, Burner)];
    fetchTopBurners : shared query () -> async [(Principal, Burner)];
    getAllowanceSize : shared query () -> async Nat;
    getBurner : shared query Principal -> async ?Burner;
    getBurnerCount : shared query () -> async Nat;
    getCreditor : shared query () -> async Principal;
    getCycles : shared query () -> async Nat;
    getHeapSize : shared query () -> async Nat;
    getHolders : shared query (Nat, Nat) -> async [(Principal, Nat)];
    getMemorySize : shared query () -> async Nat;
    getMetadata : shared query () -> async Metadata;
    getTokenFee : shared query () -> async Nat;
    getTokenInfo : shared query () -> async TokenInfo;
    getUserApprovals : shared query Principal -> async [(Principal, Nat)];
    historySize : shared query () -> async Nat;
    http_request : shared query Request -> async Response;
    logo : shared query () -> async Text;
    mint : shared (Principal, Nat) -> async TxReceipt;
    name : shared query () -> async Text;
    setCreditors : shared Principal -> async ();
    setFee : shared Nat -> ();
    setFeeTo : shared Principal -> ();
    setLogo : shared Text -> ();
    setName : shared Text -> ();
    setOwner : shared Principal -> ();
    setTransactionChunkCount : shared Nat -> async ();
    setTransactionQueueDuration : shared Nat -> async ();
    setup : shared () -> async TxReceipt;
    symbol : shared query () -> async Text;
    taxTransfer : shared (Principal, Nat) -> async TxReceipt;
    totalSupply : shared query () -> async Nat;
    transfer : shared (Principal, Nat) -> async TxReceipt;
    transferFrom : shared (Principal, Principal, Nat) -> async TxReceipt;
    updateTransactionPercentage : shared Float -> async ();
  }
}