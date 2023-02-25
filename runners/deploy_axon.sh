# you need a default principal that has no password
# you need a test_nns principal seeded with the following pem:
#-----BEGIN EC PRIVATE KEY-----
#MHQCAQEEICJxApEbuZznKFpV+VKACRK30i6+7u5Z13/DOl18cIC+oAcGBSuBBAAK
#oUQDQgAEPas6Iag4TUx+Uop+3NhE6s3FlayFtbwdhRVjvOar0kPTfE/N8N6btRnd
#74ly5xXEBNSXiENyxhEuzOZrIWMCNQ==
#-----END EC PRIVATE KEY-----
set -ex

dfx identity use default
DEFAULT_PRINCIPAL=$(dfx identity get-principal)

vessel install

dfx canister create axon
dfx build axon

original_dir=$(pwd)

cd .vessel/axon/v2.1.1/src/axon

dfx canister create Axon
dfx build Axon

cd ..

cd axon-ui

npm i
npm run build_voice
npm run export_voice

cd "$original_dir"

dfx deploy axon --mode reinstall
dfx ledger fabricate-cycles --canister axon --t 1000

dfx deploy frontend

dfx deploy icp_voice --mode reinstall





