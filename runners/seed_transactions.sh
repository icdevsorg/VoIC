# you need a default principal that has no password
# you need a test_nns principal seeded with the following pem:
#-----BEGIN EC PRIVATE KEY-----
#MHQCAQEEICJxApEbuZznKFpV+VKACRK30i6+7u5Z13/DOl18cIC+oAcGBSuBBAAK
#oUQDQgAEPas6Iag4TUx+Uop+3NhE6s3FlayFtbwdhRVjvOar0kPTfE/N8N6btRnd
#74ly5xXEBNSXiENyxhEuzOZrIWMCNQ==
#-----END EC PRIVATE KEY-----




dfx identity new alice --disable-encryption || true
dfx identity new bob --disable-encryption || true
dfx identity new dan --disable-encryption || true
dfx identity new default --disable-encryption || true

dfx identity use default
DEFAULT_PRINCIPAL=$(dfx identity get-principal)

dfx identity use alice
ALICE_PRINCIPAL=$(dfx identity get-principal)

dfx identity use bob
BOB_PRINCIPAL=$(dfx identity get-principal)

dfx identity use dan
DAN_PRINCIPAL=$(dfx identity get-principal)

dfx identity use test_nns


COUNTER=0
TOTAL_PRINCIPALS=20

while [ $COUNTER -le $TOTAL_PRINCIPALS ]
do
  dfx canister call  --async  nns-ledger icrc1_transfer "(record {to= record {owner = principal \"$DEFAULT_PRINCIPAL\"; subaccount=null;};fee= opt (10000 : nat); memo=null; from_subaccount=null; created_at_time = null; amount = $(printf '%d00000000' "$COUNTER") : nat;})"
  dfx canister call  --async  nns-ledger icrc1_transfer "(record {to= record {owner = principal \"$ALICE_PRINCIPAL\"; subaccount=null;};fee= opt (10000 : nat); memo=null; from_subaccount=null; created_at_time = null; amount = $(printf '%d00000000' "$COUNTER") : nat;})"
  dfx canister call  --async  nns-ledger icrc1_transfer "(record {to= record {owner = principal \"$BOB_PRINCIPAL\"; subaccount=null;};fee= opt (10000 : nat); memo=null; from_subaccount=null; created_at_time = null; amount = $(printf '%d00000000' "$COUNTER") : nat;})"
  dfx canister call  --async  nns-ledger icrc1_transfer "(record {to= record {owner = principal \"$DAN_PRINCIPAL\"; subaccount=null;};fee= opt (10000 : nat); memo=null; from_subaccount=null; created_at_time = null; amount = $(printf '%d00000000' "$COUNTER") : nat;})"
 
  ((COUNTER++))
  ((COUNTER++))
  ((COUNTER++))
  ((COUNTER++))
done

dfx identity use alice


COUNTER=0
TOTAL_PRINCIPALS=20

while [ $COUNTER -le $TOTAL_PRINCIPALS ]
do
  dfx canister call  --async  nns-ledger icrc1_transfer "(record {to= record {owner = principal \"$DEFAULT_PRINCIPAL\"; subaccount=null;};fee= opt (10000 : nat); memo=null; from_subaccount=null; created_at_time = null; amount = $(printf '%d0000000' "$COUNTER") : nat;})"
  dfx canister call  --async  nns-ledger icrc1_transfer "(record {to= record {owner = principal \"$BOB_PRINCIPAL\"; subaccount=null;};fee= opt (10000 : nat); memo=null; from_subaccount=null; created_at_time = null; amount = $(printf '%d0000000' "$COUNTER") : nat;})"
  dfx canister call  --async  nns-ledger icrc1_transfer "(record {to= record {owner = principal \"$DAN_PRINCIPAL\"; subaccount=null;};fee= opt (10000 : nat); memo=null; from_subaccount=null; created_at_time = null; amount = $(printf '%d0000000' "$COUNTER") : nat;})"
 
  ((COUNTER++))
  ((COUNTER++))
  ((COUNTER++))
done

dfx identity use bob


COUNTER=0
TOTAL_PRINCIPALS=20

while [ $COUNTER -le $TOTAL_PRINCIPALS ]
do
  dfx canister call  --async  nns-ledger icrc1_transfer "(record {to= record {owner = principal \"$DEFAULT_PRINCIPAL\"; subaccount=null;};fee= opt (10000 : nat); memo=null; from_subaccount=null; created_at_time = null; amount = $(printf '%d0000000' "$COUNTER") : nat;})"
  dfx canister call  --async  nns-ledger icrc1_transfer "(record {to= record {owner = principal \"$ALICE_PRINCIPAL\"; subaccount=null;};fee= opt (10000 : nat); memo=null; from_subaccount=null; created_at_time = null; amount = $(printf '%d0000000' "$COUNTER") : nat;})"
  dfx canister call  --async  nns-ledger icrc1_transfer "(record {to= record {owner = principal \"$DAN_PRINCIPAL\"; subaccount=null;};fee= opt (10000 : nat); memo=null; from_subaccount=null; created_at_time = null; amount = $(printf '%d0000000' "$COUNTER") : nat;})"
 
  ((COUNTER++))
  ((COUNTER++))
  ((COUNTER++))
done


dfx identity use default