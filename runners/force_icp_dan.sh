# you need a default principal that has no password
# you need a test_nns principal seeded with the following pem:
#-----BEGIN EC PRIVATE KEY-----
#MHQCAQEEICJxApEbuZznKFpV+VKACRK30i6+7u5Z13/DOl18cIC+oAcGBSuBBAAK
#oUQDQgAEPas6Iag4TUx+Uop+3NhE6s3FlayFtbwdhRVjvOar0kPTfE/N8N6btRnd
#74ly5xXEBNSXiENyxhEuzOZrIWMCNQ==
#-----END EC PRIVATE KEY-----
set -ex

NNS_CANISTER_ID=$(dfx canister id nns-ledger)
AXON_CANISTER_ID=$(dfx canister id axon)
ICP_VOICE_CANISTER_ID=$(dfx canister id icp_voice)





dfx identity use default
DEFAULT_PRINCIPAL=$(dfx identity get-principal)

dfx identity use alice
ALICE_PRINCIPAL=$(dfx identity get-principal)

dfx identity use bob
BOB_PRINCIPAL=$(dfx identity get-principal)

dfx identity use dan
DAN_PRINCIPAL=$(dfx identity get-principal)

dfx identity use default


repl_commands2=$(cat <<EOF
import axon = "$AXON_CANISTER_ID"
import nns_ledger = "$NNS_CANISTER_ID"
import icp_voice = "$ICP_VOICE_CANISTER_ID"
identity default "~/.config/dfx/identity/default/identity.pem"
call icp_voice.inject_subaccount(vec {
    record {
      principal "$DEFAULT_PRINCIPAL"; 
      null
    }; 
    record {
      principal "$ALICE_PRINCIPAL"; 
      null
    }; 
    record {
      principal "$BOB_PRINCIPAL";
      null
    };})
call icp_voice.add_force_accounts(vec{ principal "$DAN_PRINCIPAL";})
EOF
)

echo "calling repl 2"

proxy=$(ic-repl -r http://localhost:8080 <<EOF
$repl_commands2
EOF
)


