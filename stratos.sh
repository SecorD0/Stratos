#!/bin/bash
sudo apt update
sudo apt install curl -y
curl -s https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh | bash
echo -e 'The guide of \e[40m\e[92mhttps://t.me/how_to_node\e[0m was used\n'
if [ ! $Stratos_Nodename ]; then
	read -p $'Enter your node name: \e[40m\e[92m' Stratos_Nodename
	echo -e '\e[0m'
	echo "export Stratos_Nodename=\"$Stratos_Nodename\"" >> ~/.bash_profile
	source ~/.bash_profile
else
	echo -e "Your node name: \e[40m\e[92m$Stratos_Nodename\e[0m\n"
fi
sudo apt upgrade -y
sudo apt install jq -y
curl -s https://raw.githubusercontent.com/SecorD0/utils/main/golang_installer.sh | bash
cd $HOME
mkdir stratos
cd $HOME/stratos
echo -e '\e[40m\e[92mNode installation...\e[0m'
wget https://github.com/stratosnet/stratos-chain/releases/download/v0.3.0/stchaincli
wget https://github.com/stratosnet/stratos-chain/releases/download/v0.3.0/stchaind
chmod +x stchaincli
chmod +x stchaind
$HOME/stratos/stchaind init --home ./ $Stratos_Nodename
wget https://raw.githubusercontent.com/stratosnet/stratos-chain-testnet/main/genesis.json
wget https://raw.githubusercontent.com/stratosnet/stratos-chain-testnet/main/config.toml
mv genesis.json $HOME/stratos/config/genesis.json
mv config.toml $HOME/stratos/config/config.toml
sed -i "s/mynode/"$Stratos_Nodename"/g" $HOME/stratos/config/config.toml
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
$HOME/stratos/stchaincli keys add --hd-path "m/44'/606'/0'/0/0" --keyring-backend test --home $HOME/stratos/ $Stratos_Nodename &> "$HOME/stratos/$Stratos_Nodename.txt"
Stratos_Address=$(grep -oP '(?<=\  address: )(\w+)' "$HOME/stratos/$Stratos_Nodename.txt")
echo "export Stratos_Address=\"$Stratos_Address\"" >> ~/.bash_profile
source ~/.bash_profile
curl -X POST https://faucet-test.thestratos.org/faucet/$Stratos_Address
echo -e '\e[40m\e[92mDone!\e[0m'
curl -s https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh | bash
echo -e 'The guide of \e[40m\e[92mhttps://t.me/how_to_node\e[0m was used\n'
echo -e '\nThe node was \e[40m\e[92mstarted\e[0m, the wallet was \e[40m\e[92mcreated\e[0m, the tokens was \e[40m\e[92mreceived\e[0m.\n'
echo -e 'Remember to save this files:'
echo -e "\e[40m\e[92m\"$HOME/stratos/$Stratos_Nodename.txt\"\e[0m"
echo -e "\e[40m\e[92m\"$HOME/stratos/keyring-test-cosmos/$Stratos_Address.address\"\e[0m"
echo -e "The wallet address: \e[40m\e[92m$Stratos_Address\e[0m"
echo -e 'Enter "\e[40m\e[92msource ~/.bash_profile\e[0m" command or login to server again then you can use \e[40m\e[92m$Stratos_Nodename\e[0m and \e[40m\e[92m$Stratos_Address\e[0m variables (start to print variable then press "Tab")\n\n'
echo -e '\tv \e[40m\e[92mUseful commands\e[0m v\n'
echo -e 'To view the node status: \e[40m\e[92msystemctl status stratosd\e[0m'
echo -e 'To view the node log: \e[40m\e[92mjournalctl -n 100 -f -u stratosd\e[0m'
echo -e 'To view the node sync status: \e[40m\e[92m$HOME/stratos/stchaincli status 2>&1 | jq ."sync_info"."catching_up"\e[0m'
echo -e 'To view latest block height: \e[40m\e[92m$HOME/stratos/stchaincli status 2>&1 | jq ."sync_info"."latest_block_height"\e[0m'
echo -e 'To view the node balance (full sync required): \e[40m\e[92m$HOME/stratos/stchaincli query account $Stratos_Address --home $HOME/stratos/\e[0m'
echo -e 'To restart the node: \e[40m\e[92msystemctl restart stratosd\e[0m\n'