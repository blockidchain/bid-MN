#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'blockidcoind' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop blockidcoind${NC}"
        blockidcoin-cli stop
        sleep 30
        if pgrep -x 'blockidcoind' > /dev/null; then
            echo -e "${RED}blockidcoind daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 blockidcoind
            sleep 30
            if pgrep -x 'blockidcoind' > /dev/null; then
                echo -e "${RED}Can't stop blockidcoind! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your Blockidchain Masternode Will be Updated To The Latest Version v2.0.1 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'bidauto.sh' | crontab -

#Stop blockidcoind by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/blockidcoin*
mkdir BID_2.0.1
cd BID_2.0.1
wget https://github.com/blockidchain/bidv2/releases/download/v2.0.1/bid-2.0.1-16.04-ubuntu-daemon.tar.gz
tar -xzvf bid-2.0.1-16.04-ubuntu-daemon.tar.gz
mv blockidcoind /usr/local/bin/blockidcoind
mv blockidcoin-cli /usr/local/bin/blockidcoin-cli
chmod +x /usr/local/bin/blockidcoin*
rm -rf ~/.blockidcoin/blocks
rm -rf ~/.blockidcoin/chainstate
rm -rf ~/.blockidcoin/sporks
rm -rf ~/.blockidcoin/peers.dat
cd ~/.blockidcoin/
wget https://github.com/blockidchain/bidv2/releases/download/v2.0.1/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.blockidcoin/bootstrap.zip ~/BID_2.0.1

# add new nodes to config file
sed -i '/addnode/d' ~/.blockidcoin/blockidcoin.conf

echo "addnode=104.156.249.165
addnode=45.77.149.72
addnode=140.82.62.126
addnode=149.28.37.28" >> ~/.blockidcoin/blockidcoin.conf

#start blockidcoind
blockidcoind -daemon

printf '#!/bin/bash\nif [ ! -f "~/.blockidcoin/blockidcoind.pid" ]; then /usr/local/bin/blockidcoind -daemon ; fi' > /root/bidauto.sh
chmod -R 755 /root/bidauto.sh
#Setting auto start cron job for Blockidchain
if ! crontab -l | grep "bidauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/bidauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"