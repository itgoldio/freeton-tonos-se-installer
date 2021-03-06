#!/bin/bash

OS_VERSION=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
OS_VERSION_ID=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')
TONOS_SE_VERSION="0.28.7"
ARANGODB_VERSION="3.7.14"
TON_Q_SERVER_VERSION="0.42.1"
TON_CLIENT_JS_VERSION="1.21.4"

ARANGODBURL="https://download.arangodb.com/arangodb37/Community/Linux/arangodb3-linux-${ARANGODB_VERSION}.tar.gz"

TONSEURL="https://github.com/itgoldio/freeton-tonos-se-installer/releases/download/${TONOS_SE_VERSION}/tonos-se_${TONOS_SE_VERSION}_${OS_VERSION}_${OS_VERSION_ID}"
TONSECONFIG="https://github.com/itgoldio/freeton-tonos-se-installer/releases/download/${TONOS_SE_VERSION}/tonos-se_${TONOS_SE_VERSION}_config.json"
TONSEBLOCKCHAINCONFIG="https://github.com/itgoldio/freeton-tonos-se-installer/releases/download/${TONOS_SE_VERSION}/tonos-se_${TONOS_SE_VERSION}_blockchain.conf.json"
TONSEPUBKEY="https://github.com/itgoldio/freeton-tonos-se-installer/releases/download/${TONOS_SE_VERSION}/tonos-se_${TONOS_SE_VERSION}_pub-key"
TONSEPRVKEY="https://github.com/itgoldio/freeton-tonos-se-installer/releases/download/${TONOS_SE_VERSION}/tonos-se_${TONOS_SE_VERSION}_private-key"
TONSELOGCONFIG="https://github.com/itgoldio/freeton-tonos-se-installer/releases/download/${TONOS_SE_VERSION}/tonos-se_${TONOS_SE_VERSION}_log_cfg.yml"
TONSENGINXCONFIG="https://github.com/itgoldio/freeton-tonos-se-installer/releases/download/${TONOS_SE_VERSION}/tonos-se_${TONOS_SE_VERSION}_nginx.conf"

DIR_DISTR="distr"
DIR_TONOSSE="tonos-se"
DIR_ARANGO="arangodb"
DIR_TON_Q_SERVER="ton-q-server"
DIR_TON_CLIENT_JS="ton-client-js"
################Requirements##############

while read -r p ; do
    if [ "" == "`which $p`" ];
    then echo "$p Not Found";
        if [ -n "`which apt`" ];
        then sudo apt update && sudo apt install -y $p ;
        elif [ -n "`which yum`" ];
        then sudo yum -y install $p ;
        fi ;
    fi
done < <(cat << "EOF"
    jq
    git
    wget
    tar
    net-tools
    nginx
EOF
)

##########################################

mkdir $DIR_DISTR
mkdir $DIR_TONOSSE

####################NPM###################

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install --lts --latest-npm

#################ArangoDB#################

wget  $ARANGODBURL -P $DIR_DISTR/
tar  -xzf $DIR_DISTR/`ls $DIR_DISTR/ | grep tar.gz | grep arangodb3`  -C $DIR_DISTR/
rm -f $DIR_DISTR/`ls $DIR_DISTR/ | grep tar.gz | grep arangodb3`
ln -s `ls -d $DIR_DISTR/*/ | grep arango` $DIR_ARANGO

##########################################

################Tonos SE##################

wget $TONSEURL  -O $DIR_TONOSSE/ton_node_startup
chmod +x $DIR_TONOSSE/ton_node_startup
wget $TONSECONFIG  -O $DIR_TONOSSE/config.json
wget $TONSEPUBKEY  -O $DIR_TONOSSE/pub-key
wget $TONSEPRVKEY  -O $DIR_TONOSSE/private-key
wget $TONSELOGCONFIG -O $DIR_TONOSSE/log_cfg.yml
wget $TONSEBLOCKCHAINCONFIG -O $DIR_TONOSSE/blockchain.conf.json


##########################################

##################Nginx####################

sudo systemctl disable --now nginx
sudo setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/nginx
mkdir -p $DIR_DISTR/nginx/static
wget $TONSENGINXCONFIG -O $DIR_DISTR/nginx/nginx.conf
chmod o+x ~

if [ `git --version | awk '{split($3,a,"."); print a[2]}'` -ge 27 ] ; then
    git clone --depth=1 --filter=blob:none --sparse https://github.com/tonlabs/tonos-se.git $DIR_DISTR/nginx/static
else
    git clone --depth=1 --filter=blob:none --no-checkout https://github.com/tonlabs/tonos-se.git $DIR_DISTR/nginx/static
fi
cd $DIR_DISTR/nginx/static
git sparse-checkout set docker/ton-live
cd ../../..
##########################################

################TON-Q-Server##############

export Q_DATA_MUT=http://127.0.0.1:8529
export Q_DATA_HOT=${Q_DATA_MUT}
export Q_SLOW_QUERIES_MUT=${Q_DATA_MUT}
export Q_SLOW_QUERIES_HOT=${Q_DATA_MUT}
export Q_REQUESTS_MODE=rest
export Q_PORT=4000
export Q_REQUESTS_SERVER=http://127.0.0.1
export Q_HOST=127.0.0.1

git clone --depth=1 --branch ${TON_Q_SERVER_VERSION} https://github.com/tonlabs/ton-q-server.git $DIR_DISTR/$DIR_TON_Q_SERVER
ln -s $DIR_DISTR/$DIR_TON_Q_SERVER $DIR_TON_Q_SERVER
cd $DIR_TON_Q_SERVER && npm ci && npm run tsc && npm ci --production && npm audit fix && cd ..

##########################################


################TON-CLIENT-JS#############
git clone --depth=1 --branch ${TON_CLIENT_JS_VERSION} https://github.com/tonlabs/ton-client-js.git $DIR_DISTR/ton-client-js
ln -s $DIR_DISTR/$DIR_TON_CLIENT_JS $DIR_TON_CLIENT_JS
cd $DIR_TON_CLIENT_JS
npm i --save @tonclient/core
npm i --save @tonclient/lib-node
cd packages/core
npm i
npx tsc
cd ../tests
npm i
npx tsc
cd ../tests-node
npm i
cd ../../
##########################################

