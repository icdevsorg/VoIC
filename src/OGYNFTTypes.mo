// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
  public type Account = {
    #account_id : Text;
    #principal : Principal;
    #extensible : CandyValue__1;
    #account : { owner : Principal; sub_account : ?[Nat8] };
  };
  public type AccountIdentifier = Text;
  public type Account__1 = {
    #account_id : Text;
    #principal : Principal;
    #extensible : CandyValue__1;
    #account : { owner : Principal; sub_account : ?[Nat8] };
  };
  public type AllocationRecordStable = {
    allocated_space : Nat;
    token_id : Text;
    available_space : Nat;
    canister : Principal;
    chunks : [Nat];
    library_id : Text;
  };
  public type AuctionConfig = {
    start_price : Nat;
    token : TokenSpec;
    reserve : ?Nat;
    start_date : Int;
    min_increase : { #amount : Nat; #percentage : Float };
    allow_list : ?[Principal];
    buy_now : ?Nat;
    ending : {
      #waitForQuiet : {
        max : Nat;
        date : Int;
        fade : Float;
        extention : Nat64;
      };
      #date : Int;
    };
  };
  public type AuctionStateStable = {
    status : { #closed; #open; #not_started };
    participants : [(Principal, Int)];
    current_bid_amount : Nat;
    winner : ?Account;
    end_date : Int;
    wait_for_quiet_count : ?Nat;
    current_escrow : ?EscrowReceipt;
    allow_list : ?[(Principal, Bool)];
    current_broker_id : ?Principal;
    min_next_bid : Nat;
    config : PricingConfig__1;
  };
  public type Balance = Nat;
  public type BalanceRequest = { token : TokenIdentifier; user : User };
  public type BalanceResponse = {
    nfts : [Text];
    offers : [EscrowRecord];
    sales : [EscrowRecord];
    stake : [StakeRecord];
    multi_canister : ?[Principal];
    escrow : [EscrowRecord];
  };
  public type BalanceResponse__1 = { #ok : Balance; #err : CommonError };
  public type BidRequest = {
    broker_id : ?Principal;
    escrow_receipt : EscrowReceipt;
    sale_id : Text;
  };
  public type BidResponse = {
    token_id : Text;
    txn_type : {
      #escrow_deposit : {
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #canister_network_updated : {
        network : Principal;
        extensible : CandyValue__1;
      };
      #escrow_withdraw : {
        fee : Nat;
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #canister_managers_updated : {
        managers : [Principal];
        extensible : CandyValue__1;
      };
      #auction_bid : {
        token : TokenSpec;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : Text;
      };
      #burn;
      #data;
      #sale_ended : {
        token : TokenSpec;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : ?Text;
      };
      #mint : {
        to : Account__1;
        from : Account__1;
        sale : ?{ token : TokenSpec; amount : Nat };
        extensible : CandyValue__1;
      };
      #royalty_paid : {
        tag : Text;
        token : TokenSpec;
        reciever : Account__1;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : ?Text;
      };
      #extensible : CandyValue__1;
      #owner_transfer : {
        to : Account__1;
        from : Account__1;
        extensible : CandyValue__1;
      };
      #sale_opened : {
        pricing : PricingConfig;
        extensible : CandyValue__1;
        sale_id : Text;
      };
      #canister_owner_updated : {
        owner : Principal;
        extensible : CandyValue__1;
      };
      #sale_withdraw : {
        fee : Nat;
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #deposit_withdraw : {
        fee : Nat;
        token : TokenSpec;
        trx_id : TransactionID;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
    };
    timestamp : Int;
    index : Nat;
  };
  public type Caller = ?Principal;
  public type CandyValue = {
    #Int : Int;
    #Nat : Nat;
    #Empty;
    #Nat16 : Nat16;
    #Nat32 : Nat32;
    #Nat64 : Nat64;
    #Blob : [Nat8];
    #Bool : Bool;
    #Int8 : Int8;
    #Nat8 : Nat8;
    #Nats : { #thawed : [Nat]; #frozen : [Nat] };
    #Text : Text;
    #Bytes : { #thawed : [Nat8]; #frozen : [Nat8] };
    #Int16 : Int16;
    #Int32 : Int32;
    #Int64 : Int64;
    #Option : ?CandyValue;
    #Floats : { #thawed : [Float]; #frozen : [Float] };
    #Float : Float;
    #Principal : Principal;
    #Array : { #thawed : [CandyValue]; #frozen : [CandyValue] };
    #Class : [Property];
  };
  public type CandyValue__1 = {
    #Int : Int;
    #Nat : Nat;
    #Empty;
    #Nat16 : Nat16;
    #Nat32 : Nat32;
    #Nat64 : Nat64;
    #Blob : [Nat8];
    #Bool : Bool;
    #Int8 : Int8;
    #Nat8 : Nat8;
    #Nats : { #thawed : [Nat]; #frozen : [Nat] };
    #Text : Text;
    #Bytes : { #thawed : [Nat8]; #frozen : [Nat8] };
    #Int16 : Int16;
    #Int32 : Int32;
    #Int64 : Int64;
    #Option : ?CandyValue__1;
    #Floats : { #thawed : [Float]; #frozen : [Float] };
    #Float : Float;
    #Principal : Principal;
    #Array : { #thawed : [CandyValue__1]; #frozen : [CandyValue__1] };
    #Class : [Property__1];
  };
  public type CanisterCyclesAggregatedData = [Nat64];
  public type CanisterHeapMemoryAggregatedData = [Nat64];
  public type CanisterLogFeature = {
    #filterMessageByContains;
    #filterMessageByRegex;
  };
  public type CanisterLogMessages = {
    data : [LogMessagesData];
    lastAnalyzedMessageTimeNanos : ?Nanos;
  };
  public type CanisterLogMessagesInfo = {
    features : [?CanisterLogFeature];
    lastTimeNanos : ?Nanos;
    count : Nat32;
    firstTimeNanos : ?Nanos;
  };
  public type CanisterLogRequest = {
    #getMessagesInfo;
    #getMessages : GetLogMessagesParameters;
    #getLatestMessages : GetLatestLogMessagesParameters;
  };
  public type CanisterLogResponse = {
    #messagesInfo : CanisterLogMessagesInfo;
    #messages : CanisterLogMessages;
  };
  public type CanisterMemoryAggregatedData = [Nat64];
  public type CanisterMetrics = { data : CanisterMetricsData };
  public type CanisterMetricsData = {
    #hourly : [HourlyMetricsData];
    #daily : [DailyMetricsData];
  };
  public type ChunkContent = {
    #remote : { args : ChunkRequest; canister : Principal };
    #chunk : {
      total_chunks : Nat;
      content : [Nat8];
      storage_allocation : AllocationRecordStable;
      current_chunk : ?Nat;
    };
  };
  public type ChunkRequest = {
    token_id : Text;
    chunk : ?Nat;
    library_id : Text;
  };
  public type CollectionInfo = {
    multi_canister_count : ?Nat;
    managers : ?[Principal];
    owner : ?Principal;
    metadata : ?CandyValue;
    logo : ?Text;
    name : ?Text;
    network : ?Principal;
    created_at : ?Nat64;
    fields : ?[(Text, ?Nat, ?Nat)];
    upgraded_at : ?Nat64;
    token_ids_count : ?Nat;
    available_space : ?Nat;
    multi_canister : ?[Principal];
    token_ids : ?[Text];
    transaction_count : ?Nat;
    unique_holders : ?Nat;
    total_supply : ?Nat;
    symbol : ?Text;
    allocated_storage : ?Nat;
  };
  public type CommonError = { #InvalidToken : TokenIdentifier; #Other : Text };
  public type DailyMetricsData = {
    updateCalls : Nat64;
    canisterHeapMemorySize : NumericEntity;
    canisterCycles : NumericEntity;
    canisterMemorySize : NumericEntity;
    timeMillis : Int;
  };
  public type Data = {
    #Int : Int;
    #Nat : Nat;
    #Empty;
    #Nat16 : Nat16;
    #Nat32 : Nat32;
    #Nat64 : Nat64;
    #Blob : [Nat8];
    #Bool : Bool;
    #Int8 : Int8;
    #Nat8 : Nat8;
    #Nats : { #thawed : [Nat]; #frozen : [Nat] };
    #Text : Text;
    #Bytes : { #thawed : [Nat8]; #frozen : [Nat8] };
    #Int16 : Int16;
    #Int32 : Int32;
    #Int64 : Int64;
    #Option : ?CandyValue__1;
    #Floats : { #thawed : [Float]; #frozen : [Float] };
    #Float : Float;
    #Principal : Principal;
    #Array : { #thawed : [CandyValue__1]; #frozen : [CandyValue__1] };
    #Class : [Property__1];
  };
  public type DepositDetail = {
    token : TokenSpec__1;
    trx_id : ?TransactionID__1;
    seller : Account;
    buyer : Account;
    amount : Nat;
    sale_id : ?Text;
  };
  public type DepositWithdrawDescription = {
    token : TokenSpec__1;
    withdraw_to : Account;
    buyer : Account;
    amount : Nat;
  };
  public type DistributeSaleRequest = { seller : ?Account };
  public type DistributeSaleResponse = [Result_6];
  public type EXTTokensResult = (
    Nat32,
    ?{ locked : ?Int; seller : Principal; price : Nat64 },
    ?[Nat8],
  );
  public type EndSaleResponse = {
    token_id : Text;
    txn_type : {
      #escrow_deposit : {
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #canister_network_updated : {
        network : Principal;
        extensible : CandyValue__1;
      };
      #escrow_withdraw : {
        fee : Nat;
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #canister_managers_updated : {
        managers : [Principal];
        extensible : CandyValue__1;
      };
      #auction_bid : {
        token : TokenSpec;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : Text;
      };
      #burn;
      #data;
      #sale_ended : {
        token : TokenSpec;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : ?Text;
      };
      #mint : {
        to : Account__1;
        from : Account__1;
        sale : ?{ token : TokenSpec; amount : Nat };
        extensible : CandyValue__1;
      };
      #royalty_paid : {
        tag : Text;
        token : TokenSpec;
        reciever : Account__1;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : ?Text;
      };
      #extensible : CandyValue__1;
      #owner_transfer : {
        to : Account__1;
        from : Account__1;
        extensible : CandyValue__1;
      };
      #sale_opened : {
        pricing : PricingConfig;
        extensible : CandyValue__1;
        sale_id : Text;
      };
      #canister_owner_updated : {
        owner : Principal;
        extensible : CandyValue__1;
      };
      #sale_withdraw : {
        fee : Nat;
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #deposit_withdraw : {
        fee : Nat;
        token : TokenSpec;
        trx_id : TransactionID;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
    };
    timestamp : Int;
    index : Nat;
  };
  public type Errors = {
    #nyi;
    #storage_configuration_error;
    #escrow_withdraw_payment_failed;
    #token_not_found;
    #owner_not_found;
    #content_not_found;
    #auction_ended;
    #out_of_range;
    #sale_id_does_not_match;
    #sale_not_found;
    #item_not_owned;
    #property_not_found;
    #validate_trx_wrong_host;
    #withdraw_too_large;
    #content_not_deserializable;
    #bid_too_low;
    #validate_deposit_wrong_amount;
    #existing_sale_found;
    #asset_mismatch;
    #escrow_cannot_be_removed;
    #deposit_burned;
    #cannot_restage_minted_token;
    #cannot_find_status_in_metadata;
    #receipt_data_mismatch;
    #validate_deposit_failed;
    #unreachable;
    #unauthorized_access;
    #item_already_minted;
    #no_escrow_found;
    #escrow_owner_not_the_owner;
    #improper_interface;
    #app_id_not_found;
    #token_non_transferable;
    #sale_not_over;
    #update_class_error;
    #malformed_metadata;
    #token_id_mismatch;
    #id_not_found_in_metadata;
    #auction_not_started;
    #library_not_found;
    #attempt_to_stage_system_data;
    #validate_deposit_wrong_buyer;
    #not_enough_storage;
    #sales_withdraw_payment_failed;
  };
  public type EscrowReceipt = {
    token : TokenSpec;
    token_id : Text;
    seller : Account__1;
    buyer : Account__1;
    amount : Nat;
  };
  public type EscrowRecord = {
    token : TokenSpec;
    token_id : Text;
    seller : Account__1;
    lock_to_date : ?Int;
    buyer : Account__1;
    amount : Nat;
    sale_id : ?Text;
    account_hash : ?[Nat8];
  };
  public type EscrowRequest = {
    token_id : Text;
    deposit : DepositDetail;
    lock_to_date : ?Int;
  };
  public type EscrowResponse = {
    balance : Nat;
    receipt : EscrowReceipt;
    transaction : TransactionRecord;
  };
  public type GenericValue = {
    #Nat64Content : Nat64;
    #Nat32Content : Nat32;
    #BoolContent : Bool;
    #Nat8Content : Nat8;
    #Int64Content : Int64;
    #IntContent : Int;
    #NatContent : Nat;
    #Nat16Content : Nat16;
    #Int32Content : Int32;
    #Int8Content : Int8;
    #FloatContent : Float;
    #Int16Content : Int16;
    #BlobContent : [Nat8];
    #NestedContent : Vec;
    #Principal : Principal;
    #TextContent : Text;
  };
  public type GetLatestLogMessagesParameters = {
    upToTimeNanos : ?Nanos;
    count : Nat32;
    filter : ?GetLogMessagesFilter;
  };
  public type GetLogMessagesFilter = {
    analyzeCount : Nat32;
    messageRegex : ?Text;
    messageContains : ?Text;
  };
  public type GetLogMessagesParameters = {
    count : Nat32;
    filter : ?GetLogMessagesFilter;
    fromTimeNanos : ?Nanos;
  };
  public type GetMetricsParameters = {
    dateToMillis : Nat;
    granularity : MetricsGranularity;
    dateFromMillis : Nat;
  };
  public type GovernanceRequest = { #clear_shared_wallets : Text };
  public type GovernanceResponse = { #clear_shared_wallets : Bool };
  public type HTTPResponse = {
    body : [Nat8];
    headers : [HeaderField__1];
    streaming_strategy : ?StreamingStrategy;
    status_code : Nat16;
  };
  public type HeaderField = (Text, Text);
  public type HeaderField__1 = (Text, Text);
  public type HourlyMetricsData = {
    updateCalls : UpdateCallsAggregatedData;
    canisterHeapMemorySize : CanisterHeapMemoryAggregatedData;
    canisterCycles : CanisterCyclesAggregatedData;
    canisterMemorySize : CanisterMemoryAggregatedData;
    timeMillis : Int;
  };
  public type HttpRequest = {
    url : Text;
    method : Text;
    body : [Nat8];
    headers : [HeaderField];
  };
  public type ICTokenSpec = {
    fee : Nat;
    decimals : Nat;
    canister : Principal;
    standard : { #ICRC1; #EXTFungible; #DIP20; #Ledger };
    symbol : Text;
  };
  public type InitArgs = { owner : Principal; storage_space : ?Nat };
  public type LogMessagesData = {
    data : Data;
    timeNanos : Nanos;
    message : Text;
    caller : Caller;
  };
  public type ManageCollectionCommand = {
    #UpdateOwner : Principal;
    #UpdateManagers : [Principal];
    #UpdateMetadata : (Text, ?CandyValue, Bool);
    #UpdateNetwork : ?Principal;
    #UpdateSymbol : ?Text;
    #UpdateLogo : ?Text;
    #UpdateName : ?Text;
  };
  public type ManageSaleRequest = {
    #bid : BidRequest;
    #escrow_deposit : EscrowRequest;
    #withdraw : WithdrawRequest;
    #end_sale : Text;
    #refresh_offers : ?Account;
    #distribute_sale : DistributeSaleRequest;
    #open_sale : Text;
  };
  public type ManageSaleResponse = {
    #bid : BidResponse;
    #escrow_deposit : EscrowResponse;
    #withdraw : WithdrawResponse;
    #end_sale : EndSaleResponse;
    #refresh_offers : [EscrowRecord];
    #distribute_sale : DistributeSaleResponse;
    #open_sale : Bool;
  };
  public type ManageStorageRequest = {
    #add_storage_canisters : [(Principal, Nat, (Nat, Nat, Nat))];
  };
  public type ManageStorageResponse = { #add_storage_canisters : (Nat, Nat) };
  public type MarketTransferRequest = {
    token_id : Text;
    sales_config : SalesConfig;
  };
  public type MarketTransferRequestReponse = {
    token_id : Text;
    txn_type : {
      #escrow_deposit : {
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #canister_network_updated : {
        network : Principal;
        extensible : CandyValue__1;
      };
      #escrow_withdraw : {
        fee : Nat;
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #canister_managers_updated : {
        managers : [Principal];
        extensible : CandyValue__1;
      };
      #auction_bid : {
        token : TokenSpec;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : Text;
      };
      #burn;
      #data;
      #sale_ended : {
        token : TokenSpec;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : ?Text;
      };
      #mint : {
        to : Account__1;
        from : Account__1;
        sale : ?{ token : TokenSpec; amount : Nat };
        extensible : CandyValue__1;
      };
      #royalty_paid : {
        tag : Text;
        token : TokenSpec;
        reciever : Account__1;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : ?Text;
      };
      #extensible : CandyValue__1;
      #owner_transfer : {
        to : Account__1;
        from : Account__1;
        extensible : CandyValue__1;
      };
      #sale_opened : {
        pricing : PricingConfig;
        extensible : CandyValue__1;
        sale_id : Text;
      };
      #canister_owner_updated : {
        owner : Principal;
        extensible : CandyValue__1;
      };
      #sale_withdraw : {
        fee : Nat;
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #deposit_withdraw : {
        fee : Nat;
        token : TokenSpec;
        trx_id : TransactionID;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
    };
    timestamp : Int;
    index : Nat;
  };
  public type Memo = [Nat8];
  public type Metadata = {
    #fungible : {
      decimals : Nat8;
      metadata : ?[Nat8];
      name : Text;
      symbol : Text;
    };
    #nonfungible : { metadata : ?[Nat8] };
  };
  public type Metadata_1 = { #Ok : [Nat]; #Err : NftError };
  public type Metadata_2 = { #Ok : [TokenMetadata]; #Err : NftError };
  public type Metadata_3 = { #Ok : TokenMetadata; #Err : NftError };
  public type Metadata__1 = {
    logo : ?Text;
    name : ?Text;
    created_at : Nat64;
    upgraded_at : Nat64;
    custodians : [Principal];
    symbol : ?Text;
  };
  public type MetricsGranularity = { #hourly; #daily };
  public type NFTBackupChunk = {
    sales_balances : StableSalesBalances;
    offers : StableOffers;
    collection_data : StableCollectionData;
    nft_ledgers : StableNftLedger;
    canister : Principal;
    allocations : [((Text, Text), AllocationRecordStable)];
    nft_sales : [(Text, SaleStatusStable)];
    buckets : [(Principal, StableBucketData)];
    escrow_balances : StableEscrowBalances;
  };
  public type NFTInfoStable = {
    metadata : CandyValue;
    current_sale : ?SaleStatusStable;
  };
  public type NFTUpdateRequest = {
    #update : { token_id : Text; update : UpdateRequest; app_id : Text };
    #replace : { token_id : Text; data : CandyValue };
  };
  public type NFTUpdateResponse = Bool;
  public type Nanos = Nat64;
  public type NftError = {
    #UnauthorizedOperator;
    #SelfTransfer;
    #TokenNotFound;
    #UnauthorizedOwner;
    #TxNotFound;
    #SelfApprove;
    #OperatorNotFound;
    #ExistedNFT;
    #OwnerNotFound;
    #Other : Text;
  };
  public type NumericEntity = {
    avg : Nat64;
    max : Nat64;
    min : Nat64;
    first : Nat64;
    last : Nat64;
  };
  public type OrigynError = {
    text : Text;
    error : Errors;
    number : Nat32;
    flag_point : Text;
  };
  public type OwnerOfResponse = { #Ok : ?Principal; #Err : NftError };
  public type OwnerTransferResponse = {
    transaction : TransactionRecord;
    assets : [CandyValue];
  };
  public type PricingConfig = {
    #flat : { token : TokenSpec; amount : Nat };
    #extensible : { #candyClass };
    #instant;
    #auction : AuctionConfig;
    #dutch : { start_price : Nat; reserve : ?Nat; decay_per_hour : Float };
  };
  public type PricingConfig__1 = {
    #flat : { token : TokenSpec; amount : Nat };
    #extensible : { #candyClass };
    #instant;
    #auction : AuctionConfig;
    #dutch : { start_price : Nat; reserve : ?Nat; decay_per_hour : Float };
  };
  
  public type Property = { value : CandyValue; name : Text; immutable : Bool };
  public type Property__1 = {
    value : CandyValue__1;
    name : Text;
    immutable : Bool;
  };
  public type RejectDescription = {
    token : TokenSpec__1;
    token_id : Text;
    seller : Account;
    buyer : Account;
  };
  public type Result = { #ok : NFTUpdateResponse; #err : OrigynError };
  public type Result_1 = { #ok : [EXTTokensResult]; #err : CommonError };
  public type Result_10 = {
    #ok : MarketTransferRequestReponse;
    #err : OrigynError;
  };
  public type Result_11 = { #ok : ManageStorageResponse; #err : OrigynError };
  public type Result_12 = { #ok : [TransactionRecord]; #err : OrigynError };
  public type Result_13 = { #ok : GovernanceResponse; #err : OrigynError };
  public type Result_14 = { #ok : Bool; #err : OrigynError };
  public type Result_15 = { #ok : CollectionInfo; #err : OrigynError };
  public type Result_16 = { #ok : ChunkContent; #err : OrigynError };
  public type Result_17 = { #ok : Account; #err : OrigynError };
  public type Result_18 = { #ok : AccountIdentifier; #err : CommonError };
  public type Result_19 = { #ok : BalanceResponse; #err : OrigynError };
  public type Result_2 = { #ok : StorageMetrics; #err : OrigynError };
  public type Result_3 = { #ok : Text; #err : OrigynError };
  public type Result_4 = { #ok : StageLibraryResponse; #err : OrigynError };
  public type Result_5 = { #ok : OwnerTransferResponse; #err : OrigynError };
  public type Result_6 = { #ok : ManageSaleResponse; #err : OrigynError };
  public type Result_7 = { #ok : SaleInfoResponse; #err : OrigynError };
  public type Result_8 = { #ok : NFTInfoStable; #err : OrigynError };
  public type Result_9 = { #ok : Metadata; #err : CommonError };
  public type Result__1 = { #Ok : Nat; #Err : NftError };
  public type SaleInfoRequest = {
    #status : Text;
    #active : ?(Nat, Nat);
    #deposit_info : ?Account;
    #history : ?(Nat, Nat);
  };
  public type SaleInfoResponse = {
    #status : ?SaleStatusStable;
    #active : {
      eof : Bool;
      records : [(Text, ?SaleStatusStable)];
      count : Nat;
    };
    #deposit_info : SubAccountInfo;
    #history : { eof : Bool; records : [?SaleStatusStable]; count : Nat };
  };
  public type SaleStatusStable = {
    token_id : Text;
    sale_type : { #auction : AuctionStateStable };
    broker_id : ?Principal;
    original_broker_id : ?Principal;
    sale_id : Text;
  };
  public type SalesConfig = {
    broker_id : ?Principal;
    pricing : PricingConfig__1;
    escrow_receipt : ?EscrowReceipt;
  };
  public type ShareWalletRequest = {
    to : Account;
    token_id : Text;
    from : Account;
  };
  public type StableBucketData = {
    principal : Principal;
    allocated_space : Nat;
    date_added : Int;
    version : (Nat, Nat, Nat);
    b_gateway : Bool;
    available_space : Nat;
    allocations : [((Text, Text), Int)];
  };
  public type StableCollectionData = {
    active_bucket : ?Principal;
    managers : [Principal];
    owner : Principal;
    metadata : ?CandyValue;
    logo : ?Text;
    name : ?Text;
    network : ?Principal;
    available_space : Nat;
    symbol : ?Text;
    allocated_storage : Nat;
  };
  public type StableEscrowBalances = [(Account, Account, Text, EscrowRecord)];
  public type StableNftLedger = [(Text, TransactionRecord)];
  public type StableOffers = [(Account, Account, Int)];
  public type StableSalesBalances = [(Account, Account, Text, EscrowRecord)];
  public type StageChunkArg = {
    content : [Nat8];
    token_id : Text;
    chunk : Nat;
    filedata : CandyValue;
    library_id : Text;
  };
  public type StageLibraryResponse = { canister : Principal };
  public type StakeRecord = { staker : Account; token_id : Text; amount : Nat };
  public type StateSize = {
    sales_balances : Nat;
    offers : Nat;
    nft_ledgers : Nat;
    allocations : Nat;
    nft_sales : Nat;
    buckets : Nat;
    escrow_balances : Nat;
  };
  public type Stats = {
    cycles : Nat;
    total_transactions : Nat;
    total_unique_holders : Nat;
    total_supply : Nat;
  };
  public type StorageMetrics = {
    gateway : Principal;
    available_space : Nat;
    allocations : [AllocationRecordStable];
    allocated_storage : Nat;
  };
  public type StreamingCallbackResponse = {
    token : ?StreamingCallbackToken;
    body : [Nat8];
  };
  public type StreamingCallbackToken = {
    key : Text;
    index : Nat;
    content_encoding : Text;
  };
  public type StreamingStrategy = {
    #Callback : {
      token : StreamingCallbackToken;
      callback : shared () -> async ();
    };
  };
  public type SubAccount = [Nat8];
  public type SubAccountInfo = {
    account_id : [Nat8];
    principal : Principal;
    account_id_text : Text;
    account : { principal : Principal; sub_account : [Nat8] };
  };
  public type SupportedInterface = {
    #Burn;
    #Mint;
    #Approval;
    #TransactionHistory;
  };
  public type TokenIdentifier = Text;
  public type TokenMetadata = {
    transferred_at : ?Nat64;
    transferred_by : ?Principal;
    owner : ?Principal;
    operator : ?Principal;
    approved_at : ?Nat64;
    approved_by : ?Principal;
    properties : [(Text, GenericValue)];
    is_burned : Bool;
    token_identifier : Nat;
    burned_at : ?Nat64;
    burned_by : ?Principal;
    minted_at : Nat64;
    minted_by : Principal;
  };
  public type TokenSpec = { #ic : ICTokenSpec; #extensible : CandyValue__1 };
  public type TokenSpec__1 = { #ic : ICTokenSpec; #extensible : CandyValue__1 };
  public type TransactionID = {
    #nat : Nat;
    #text : Text;
    #extensible : CandyValue__1;
  };
  public type TransactionID__1 = {
    #nat : Nat;
    #text : Text;
    #extensible : CandyValue__1;
  };
  public type TransactionRecord = {
    token_id : Text;
    txn_type : {
      #escrow_deposit : {
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #canister_network_updated : {
        network : Principal;
        extensible : CandyValue__1;
      };
      #escrow_withdraw : {
        fee : Nat;
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #canister_managers_updated : {
        managers : [Principal];
        extensible : CandyValue__1;
      };
      #auction_bid : {
        token : TokenSpec;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : Text;
      };
      #burn;
      #data;
      #sale_ended : {
        token : TokenSpec;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : ?Text;
      };
      #mint : {
        to : Account__1;
        from : Account__1;
        sale : ?{ token : TokenSpec; amount : Nat };
        extensible : CandyValue__1;
      };
      #royalty_paid : {
        tag : Text;
        token : TokenSpec;
        reciever : Account__1;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : ?Text;
      };
      #extensible : CandyValue__1;
      #owner_transfer : {
        to : Account__1;
        from : Account__1;
        extensible : CandyValue__1;
      };
      #sale_opened : {
        pricing : PricingConfig;
        extensible : CandyValue__1;
        sale_id : Text;
      };
      #canister_owner_updated : {
        owner : Principal;
        extensible : CandyValue__1;
      };
      #sale_withdraw : {
        fee : Nat;
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #deposit_withdraw : {
        fee : Nat;
        token : TokenSpec;
        trx_id : TransactionID;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
    };
    timestamp : Int;
    index : Nat;
  };
  public type TransferRequest = {
    to : User;
    token : TokenIdentifier;
    notify : Bool;
    from : User;
    memo : Memo;
    subaccount : ?SubAccount;
    amount : Balance;
  };
  public type TransferResponse = {
    #ok : Balance;
    #err : {
      #CannotNotify : AccountIdentifier;
      #InsufficientBalance;
      #InvalidToken : TokenIdentifier;
      #Rejected;
      #Unauthorized : AccountIdentifier;
      #Other : Text;
    };
  };
  public type Update = { mode : UpdateMode; name : Text };
  public type UpdateCallsAggregatedData = [Nat64];
  public type UpdateMode = {
    #Set : CandyValue;
    #Lock : CandyValue;
    #Next : [Update];
  };
  public type UpdateRequest = { id : Text; update : [Update] };
  public type User = { #principal : Principal; #address : AccountIdentifier };
  public type Vec = [
    (
      Text,
      {
        #Nat64Content : Nat64;
        #Nat32Content : Nat32;
        #BoolContent : Bool;
        #Nat8Content : Nat8;
        #Int64Content : Int64;
        #IntContent : Int;
        #NatContent : Nat;
        #Nat16Content : Nat16;
        #Int32Content : Int32;
        #Int8Content : Int8;
        #FloatContent : Float;
        #Int16Content : Int16;
        #BlobContent : [Nat8];
        #NestedContent : Vec;
        #Principal : Principal;
        #TextContent : Text;
      },
    )
  ];
  public type WithdrawDescription = {
    token : TokenSpec__1;
    token_id : Text;
    seller : Account;
    withdraw_to : Account;
    buyer : Account;
    amount : Nat;
  };
  public type WithdrawRequest = {
    #reject : RejectDescription;
    #sale : WithdrawDescription;
    #deposit : DepositWithdrawDescription;
    #escrow : WithdrawDescription;
  };
  public type WithdrawResponse = {
    token_id : Text;
    txn_type : {
      #escrow_deposit : {
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #canister_network_updated : {
        network : Principal;
        extensible : CandyValue__1;
      };
      #escrow_withdraw : {
        fee : Nat;
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #canister_managers_updated : {
        managers : [Principal];
        extensible : CandyValue__1;
      };
      #auction_bid : {
        token : TokenSpec;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : Text;
      };
      #burn;
      #data;
      #sale_ended : {
        token : TokenSpec;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : ?Text;
      };
      #mint : {
        to : Account__1;
        from : Account__1;
        sale : ?{ token : TokenSpec; amount : Nat };
        extensible : CandyValue__1;
      };
      #royalty_paid : {
        tag : Text;
        token : TokenSpec;
        reciever : Account__1;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
        sale_id : ?Text;
      };
      #extensible : CandyValue__1;
      #owner_transfer : {
        to : Account__1;
        from : Account__1;
        extensible : CandyValue__1;
      };
      #sale_opened : {
        pricing : PricingConfig;
        extensible : CandyValue__1;
        sale_id : Text;
      };
      #canister_owner_updated : {
        owner : Principal;
        extensible : CandyValue__1;
      };
      #sale_withdraw : {
        fee : Nat;
        token : TokenSpec;
        token_id : Text;
        trx_id : TransactionID;
        seller : Account__1;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
      #deposit_withdraw : {
        fee : Nat;
        token : TokenSpec;
        trx_id : TransactionID;
        extensible : CandyValue__1;
        buyer : Account__1;
        amount : Nat;
      };
    };
    timestamp : Int;
    index : Nat;
  };
  public type canister_id = Principal;
  public type canister_status = {
    status : { #stopped; #stopping; #running };
    memory_size : Nat;
    cycles : Nat;
    settings : definite_canister_settings;
    module_hash : ?[Nat8];
  };
  public type definite_canister_settings = {
    freezing_threshold : Nat;
    controllers : ?[Principal];
    memory_allocation : Nat;
    compute_allocation : Nat;
  };
  public type Self = actor {
    __advance_time : shared Int -> async Int;
    __set_time_mode : shared { #test; #standard } -> async Bool;
    __supports : shared query () -> async [(Text, Text)];
    back_up : shared query Nat -> async {
        #eof : NFTBackupChunk;
        #data : NFTBackupChunk;
      };
    balance : shared query BalanceRequest -> async BalanceResponse__1;
    balanceEXT : shared query BalanceRequest -> async BalanceResponse__1;
    balance_of_nft_origyn : shared query Account -> async Result_19;
    balance_of_batch_nft_origyn : shared query [Account] -> async [Result_19];
    balance_of_secure_nft_origyn : shared Account -> async Result_19;
    bearer : shared query TokenIdentifier -> async Result_18;
    bearerEXT : shared query TokenIdentifier -> async Result_18;
    bearer_batch_nft_origyn : shared query [Text] -> async [Result_17];
    
    bearer_batch_secure_nft_origyn : shared [Text] -> async [Result_17];
    bearer_nft_origyn : shared query Text -> async Result_17;
    bearer_secure_nft_origyn : shared Text -> async Result_17;
    canister_status : shared {
        canister_id : canister_id;
      } -> async canister_status;
    chunk_nft_origyn : shared query ChunkRequest -> async Result_16;
    chunk_secure_nft_origyn : shared ChunkRequest -> async Result_16;
    collectCanisterMetrics : shared query () -> async ();
    collection_nft_origyn : shared query ?[
        (Text, ?Nat, ?Nat)
      ] -> async Result_15;
    collection_secure_nft_origyn : shared ?[
        (Text, ?Nat, ?Nat)
      ] -> async Result_15;
    collection_update_batch_nft_origyn : shared [
        ManageCollectionCommand
      ] -> async [Result_14];
    collection_update_nft_origyn : shared ManageCollectionCommand -> async Result_14;
    cycles : shared query () -> async Nat;
    dip721_balance_of : shared query Principal -> async Nat;
    dip721_custodians : shared query () -> async [Principal];
    dip721_is_approved_for_all : shared query (
        Principal,
        Principal,
      ) -> async Result_1;
    dip721_logo : shared query () -> async ?Text;
    dip721_metadata : shared query () -> async Metadata__1;
    dip721_name : shared query () -> async ?Text;
    dip721_operator_token_identifiers : shared query Principal -> async Metadata_1;
    dip721_operator_token_metadata : shared query Principal -> async Metadata_2;
    dip721_owner_of : shared query Nat -> async OwnerOfResponse;
    dip721_owner_token_identifiers : shared query Principal -> async Metadata_1;
    dip721_owner_token_metadata : shared query Principal -> async Metadata_2;
    dip721_stats : shared query () -> async Stats;
    dip721_supported_interfaces : shared query () -> async [SupportedInterface];
    dip721_symbol : shared query () -> async ?Text;
    dip721_token_metadata : shared query Nat -> async Metadata_3;
    dip721_total_supply : shared query () -> async Nat;
    dip721_total_transactions : shared query () -> async Nat;
    dip721_transfer : shared (Principal, Nat) -> async Result__1;
    dip721_transfer_from : shared (
        Principal,
        Principal,
        Nat,
      ) -> async Result__1;
    getCanisterLog : shared query ?CanisterLogRequest -> async ?CanisterLogResponse;
    getCanisterMetrics : shared query GetMetricsParameters -> async ?CanisterMetrics;
    getEXTTokenIdentifier : shared query Text -> async Text;
    get_access_key : shared query () -> async Result_3;
    get_halt : shared query () -> async Bool;
    get_nat_as_token_id_origyn : shared query Nat -> async Text;
    get_token_id_as_nat_origyn : shared query Text -> async Nat;
    governance_nft_origyn : shared GovernanceRequest -> async Result_13;
    history_batch_nft_origyn : shared query [(Text, ?Nat, ?Nat)] -> async [
        Result_12
      ];
    history_batch_secure_nft_origyn : shared [(Text, ?Nat, ?Nat)] -> async [
        Result_12
      ];
    history_nft_origyn : shared query (Text, ?Nat, ?Nat) -> async Result_12;
    history_secure_nft_origyn : shared (Text, ?Nat, ?Nat) -> async Result_12;
    http_access_key : shared () -> async Result_3;
    http_request : shared query HttpRequest -> async HTTPResponse;
    http_request_streaming_callback : shared query StreamingCallbackToken -> async StreamingCallbackResponse;
    manage_storage_nft_origyn : shared ManageStorageRequest -> async Result_11;
    market_transfer_batch_nft_origyn : shared [MarketTransferRequest] -> async [
        Result_10
      ];
    market_transfer_nft_origyn : shared MarketTransferRequest -> async Result_10;
    metadata : shared query () -> async Metadata__1;
    metadataExt : shared query TokenIdentifier -> async Result_9;
    mint_batch_nft_origyn : shared [(Text, Account)] -> async [Result_3];
    mint_nft_origyn : shared (Text, Account) -> async Result_3;
    nftStreamingCallback : shared query StreamingCallbackToken -> async StreamingCallbackResponse;
    nft_batch_origyn : shared query [Text] -> async [Result_8];
    nft_batch_secure_origyn : shared [Text] -> async [Result_8];
    nft_origyn : shared query Text -> async Result_8;
    nft_secure_origyn : shared Text -> async Result_8;
    operaterTokenMetadata : shared query Principal -> async Metadata_2;
    ownerOf : shared query Nat -> async OwnerOfResponse;
    ownerTokenMetadata : shared query Principal -> async Metadata_2;
    sale_batch_nft_origyn : shared [ManageSaleRequest] -> async [Result_6];
    sale_info_batch_nft_origyn : shared query [SaleInfoRequest] -> async [
        Result_7
      ];
    sale_info_batch_secure_nft_origyn : shared [SaleInfoRequest] -> async [
        Result_7
      ];
    sale_info_nft_origyn : shared query SaleInfoRequest -> async Result_7;
    sale_info_secure_nft_origyn : shared SaleInfoRequest -> async Result_7;
    sale_nft_origyn : shared ManageSaleRequest -> async Result_6;
    set_data_harvester : shared Nat -> async ();
    set_halt : shared Bool -> async ();
    share_wallet_nft_origyn : shared ShareWalletRequest -> async Result_5;
    stage_batch_nft_origyn : shared [{ metadata : CandyValue }] -> async [
        Result_3
      ];
    stage_library_batch_nft_origyn : shared [StageChunkArg] -> async [Result_4];
    stage_library_nft_origyn : shared StageChunkArg -> async Result_4;
    stage_nft_origyn : shared { metadata : CandyValue } -> async Result_3;
    state_size : shared query () -> async StateSize;
    storage_info_nft_origyn : shared query () -> async Result_2;
    storage_info_secure_nft_origyn : shared () -> async Result_2;
    tokens_ext : shared query Text -> async Result_1;
    transfer : shared TransferRequest -> async TransferResponse;
    transferDip721 : shared (Principal, Nat) -> async Result__1;
    transferEXT : shared TransferRequest -> async TransferResponse;
    transferFrom : shared (Principal, Principal, Nat) -> async Result__1;
    transferFromDip721 : shared (Principal, Principal, Nat) -> async Result__1;
    update_app_nft_origyn : shared NFTUpdateRequest -> async Result;
    wallet_receive : shared () -> async Nat;
    whoami : shared query () -> async Principal;
  }
}