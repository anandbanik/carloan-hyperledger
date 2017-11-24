export CHANNEL_NAME=mychannel

peer channel create -o orderer.walmartlabs.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/walmartlabs.com/orderers/orderer.walmartlabs.com/msp/tlscacerts/tlsca.walmartlabs.com-cert.pem

peer channel join -b 



peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/walmartlabs/chaincode/go/chaincode_example02

peer chaincode instantiate -o orderer.walmartlabs.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/walmartlabs.com/orderers/orderer.walmartlabs.com/msp/tlscacerts/tlsca.walmartlabs.com-cert.pem -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('DealerMSP.member','BankerMSP.member')"

peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

peer chaincode invoke -o orderer.walmartlabs.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/walmartlabs.com/orderers/orderer.walmartlabs.com/msp/tlscacerts/tlsca.walmartlabs.com-cert.pem  -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'