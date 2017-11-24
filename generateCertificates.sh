mkdir channel-artifacts
export CHANNEL_NAME=mychannel
./bin/cryptogen generate --config=./crypto-config.yaml
export FABRIC_CFG_PATH=$PWD
./bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
./bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

./bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/DealerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg DealerMSP
./bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/BankerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg BankerMSP
./bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/InsuranceMSPanchors.tx -channelID $CHANNEL_NAME -asOrg InsuranceMSP
./bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/DmvMSPanchors.tx -channelID $CHANNEL_NAME -asOrg DmvMSP