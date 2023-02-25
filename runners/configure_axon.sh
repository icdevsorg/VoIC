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

dfx identity use default
DEFAULT_PRINCIPAL=$(dfx identity get-principal)

dfx identity use alice
ALICE_PRINCIPAL=$(dfx identity get-principal)

dfx identity use bob
BOB_PRINCIPAL=$(dfx identity get-principal)

dfx identity use dan
DAN_PRINCIPAL=$(dfx identity get-principal)

dfx identity use default


repl_commands=$(cat <<EOF
import axon = "$AXON_CANISTER_ID"
import nns_ledger = "$NNS_CANISTER_ID"
import icp_voice = "$ICP_VOICE_CANISTER_ID"
identity default "~/.config/dfx/identity/default/identity.pem"
call axon.get_admins()
let result = call axon.create(record {
                          name="test icp"; 
                          ledgerEntries =vec{record{ principal "$DEFAULT_PRINCIPAL"; 1}}; 
                          visibility =  variant{Public = null}; 
                          policy = record{
                            proposers = variant {Open = null}; 
                            proposeThreshold = 1; 
                            acceptanceThreshold = variant {
                              Percent = record {
                                percent = 50000000; 
                                quorum = opt 3000000
                              }
                            }; 
                            allowTokenBurn = true; 
                            restrictTokenTransfer = true; 
                            minters = variant{
                              Minters = vec {
                                principal "$ICP_VOICE_CANISTER_ID"
                              }
                            }
                          }

                        })
call icp_voice.set_axon_canister(principal "$AXON_CANISTER_ID")
call icp_voice.set_axon_id(result.ok.id)
let proxy = result.ok.proxy
proxy
EOF
)

echo "calling repl 1"

proxy=$(ic-repl -r http://localhost:8080 <<EOF
$repl_commands
EOF
)

wallet_address=$(echo "$proxy" | grep 'service' | sed 's/.*"\(.*\)".*/\1/')


echo "seeding wallet address"
echo "$wallet_address"


repl_commands2=$(cat <<EOF
import axon = "$AXON_CANISTER_ID"
import nns_ledger = "$NNS_CANISTER_ID"
import icp_voice = "$ICP_VOICE_CANISTER_ID"
identity default "~/.config/dfx/identity/default/identity.pem"
call icp_voice.set_voice_address(principal "$wallet_address")
call icp_voice.set_token_address(principal "$NNS_CANISTER_ID")
call icp_voice.start_sync()
EOF
)

echo "calling repl 2"

proxy=$(ic-repl -r http://localhost:8080 <<EOF
$repl_commands2
EOF
)


