# Create a raw transaction that can be spent in 2 weeks time, assuming the current block is 25

# Amount of 20,000,000 satoshis to this address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP 
# Use the UTXOs from the transaction below
# transaction="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
transaction="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

#Extract transaction ID
txn_id=$(bitcoin-cli -regtest decoderawtransaction $transaction | jq -r '.txid')

#Extract UTXO details
utxo_vout_1=$(bitcoin-cli -regtest decoderawtransaction $transaction | jq -r '.vout | .[0] | .n')
utxo_vout_1_value=$(bitcoin-cli -regtest decoderawtransaction $transaction | jq -r '.vout | .[0] | .value')

utxo_vout_2=$(bitcoin-cli -regtest decoderawtransaction $transaction | jq -r '.vout | .[1] | .n')
utxo_vout_2_value=$(bitcoin-cli -regtest decoderawtransaction $transaction | jq -r '.vout | .[1] | .value')

# Calculate total input value (in satoshis)
total_input_sats=$(echo "$utxo_vout_1_value + $utxo_vout_2_value" | bc | awk '{printf "%.0f", $1 * 100000000}')

# Calculate change amount (total input - 20,000,000 satoshis)
change_sats=$((total_input_sats - 20000000))

# Convert change amount back to BTC with 8 decimal places
change_amount=$(echo "scale=8; $change_sats / 100000000" | bc | awk '{printf "%.8f", $1}')

# Create the raw transaction with nLockTime set to 2041
bitcoin-cli -regtest -named createrawtransaction \
inputs='''[ 
  { "txid": "'$txn_id'", "vout": '$utxo_vout_1', "sequence": 1 }, 
  { "txid": "'$txn_id'", "vout": '$utxo_vout_2', "sequence": 1 } 
]''' \
outputs='''{ 
  "'$recipient'": 0.20000000, 
  "'$recipient'": '$change_amount' 
}''' \
locktime=2041