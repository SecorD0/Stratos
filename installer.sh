#!/bin/bash
sudo apt update
sudo apt install wget -y
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
echo -e 'The guide of \e[40m\e[92mhttps://t.me/how_to_node\e[0m was used\n'
if [ ! -n "$stratos_moniker" ]; then
	read -p $'Enter your node name: \e[40m\e[92m' stratos_moniker
	echo -e '\e[0m'
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n "stratos_moniker" -v "$stratos_moniker"
else
	echo -e "Your node name: \e[40m\e[92m$stratos_moniker\e[0m\n"
fi
sudo apt upgrade -y
sudo apt install curl jq -y
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/installers/golang.sh) --
cd $HOME
mkdir stratos
cd $HOME/stratos
echo -e '\e[40m\e[92mNode installation...\e[0m'
wget https://github.com/stratosnet/stratos-chain/releases/download/v0.3.0/stchaincli
wget https://github.com/stratosnet/stratos-chain/releases/download/v0.3.0/stchaind
chmod +x stchaincli
chmod +x stchaind
$HOME/stratos/stchaind init --home ./ $stratos_moniker
wget https://raw.githubusercontent.com/stratosnet/stratos-chain-testnet/main/genesis.json
wget https://raw.githubusercontent.com/stratosnet/stratos-chain-testnet/main/config.toml
mv genesis.json $HOME/stratos/config/genesis.json
mv config.toml $HOME/stratos/config/config.toml
sed -i "s%mynode%"$stratos_moniker"%g" $HOME/stratos/config/config.toml
sudo tee <<EOF >/dev/null /etc/systemd/system/stratosd.service
[Unit]
Description=Stratos Node
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
ExecStart=$HOME/stratos/stchaind start --home $HOME/stratos/ 

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable stratosd
sudo systemctl daemon-reload
sudo systemctl restart stratosd
echo -e '\e[40m\e[92mDone!\e[0m'
echo -e '\e[40m\e[92mWallet creating...\e[0m'
$HOME/stratos/stchaincli keys add --hd-path "m/44'/606'/0'/0/0" --keyring-backend test --home $HOME/stratos/ $stratos_moniker &> "$HOME/stratos/$stratos_moniker.txt"
stratos_address=$(grep -oP '(?<=\  address: )(\w+)' "$HOME/stratos/$stratos_moniker.txt")
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n "stratos_address" -v "$stratos_address"
curl -X POST https://faucet-test.thestratos.org/faucet/$stratos_address
echo -e '\e[40m\e[92mDone!\e[0m'
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
echo -e 'The guide of \e[40m\e[92mhttps://t.me/how_to_node\e[0m was used\n'
echo -e '\nThe node was \e[40m\e[92mstarted\e[0m, the wallet was \e[40m\e[92mcreated\e[0m, the tokens was \e[40m\e[92mreceived\e[0m.\n'
echo -e 'Remember to save this files:'
echo -e "\e[40m\e[92m\"$HOME/stratos/$stratos_moniker.txt\"\e[0m"
echo -e "\e[40m\e[92m\"$HOME/stratos/keyring-test-cosmos/$stratos_address.address\"\e[0m"
echo -e "The wallet address: \e[40m\e[92m$stratos_address\e[0m"
echo -e 'You can use \e[40m\e[92m$stratos_moniker\e[0m and \e[40m\e[92m$stratos_address\e[0m variables (start to print variable then press "Tab")\n\n'
echo -e '\tv \e[40m\e[92mUseful commands\e[0m v\n'
echo -e 'To view the node status: \e[40m\e[92msystemctl status stratosd\e[0m'
echo -e 'To view the node log: \e[40m\e[92mjournalctl -n 100 -f -u stratosd\e[0m'
echo -e 'To view the node sync status: \e[40m\e[92m$HOME/stratos/stchaincli status 2>&1 | jq ."sync_info"."catching_up"\e[0m'
echo -e 'To view latest block height: \e[40m\e[92m$HOME/stratos/stchaincli status 2>&1 | jq ."sync_info"."latest_block_height"\e[0m'
echo -e 'To view the node balance (full sync required): \e[40m\e[92m$HOME/stratos/stchaincli query account $stratos_address --home $HOME/stratos/\e[0m'
echo -e 'To restart the node: \e[40m\e[92msystemctl restart stratosd\e[0m\n'
