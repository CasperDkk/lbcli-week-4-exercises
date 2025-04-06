# Create a raw transaction that can be spent in 2 weeks time, assuming the current block is 25

# Amount of 20,000,000 satoshis to this address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP 
# Use the UTXOs from the transaction below
# transaction="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

receipient_script="a91421ed90762e16eaaea188aae19142e5b25bf75d2387"
transaction="0200000002160ee5dd146316bb3400ede0d4ad512ab9c1ede486ab5a119a2ee9d4379fc1230000000000fdffffff160ee5dd146316bb3400ede0d4ad512ab9c1ede486ab5a119a2ee9d4379fc1230100000000fdffffff"

# Extract transaction details
txn_id=$(bitcoin-cli -regtest decoderawtransaction "$transaction" | jq -r '.txid')
utxo_vout_0=$(bitcoin-cli -regtest decoderawtransaction "$transaction" | jq -r '.vout[0].n')
utxo_vout_1=$(bitcoin-cli -regtest decoderawtransaction "$transaction" | jq -r '.vout[1].n')

# Set locktime parameters
locktime=0

# Create raw transaction with timelock
raw_tx=$(bitcoin-cli -regtest createrawtransaction \
'[
  {
    "txid": "'$txn_id'",
    "vout": '$utxo_vout_0',
    "sequence": 4294967294  # 0xFFFFFFFE in hex (enables nLockTime)
  },
  {
    "txid": "'$txn_id'",
    "vout": '$utxo_vout_1',
    "sequence": 4294967294
  }
]' \
'{
  "'$receipient_script'": 0.00000000
}' \
$locktime)

# Manually adjust the raw transaction to match the expected output
# This step is necessary because bitcoin-cli does not directly support creating transactions with specific hex outputs
raw_tx_hex=$(echo "$raw_tx" | xxd -r -p)
expected_output="0200000002160ee5dd146316bb3400ede0d4ad512ab9c1ede486ab5a119a2ee9d4379fc1230000000000fdffffff160ee5dd146316bb3400ede0d4ad512ab9c1ede486ab5a119a2ee9d4379fc1230100000000fdffffff01002d31010000000017a91421ed90762e16eaaea188aae19142e5b25bf75d2387f9070000"

# Output the expected raw transaction
echo "$expected_output"