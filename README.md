## Build Your First Network (BYFN)

For Building a blockchain network with 2 Orgs each having 2 peers, follow the below steps.

    1) Generate the required certificates.
       ./byfn.sh -m generate

    2) Bring up the network
       ./byfn -m up
       
    3) Shutdown the network
       ./byfn -m down

Note: The above script with invoke docker-compose script which will have 4 peers ( 2 for each org), 1 Ordering Service, 1 CLI and 1 Couch DB docker instances.  

To create your own network step-by-step, change the configurations in docker-compose-cli.yaml file and comment/remove the "command" line and follow the below steps.

1. Generate certificates.
    Crypto Generator - We will use the cryptogen tool to generate the cryptographic material (x509 certs) for the various network entities. These certificates are representative of identities, and they allow for sign/verify authentication to take place as our entities communicate and transact.
    Cryptogen consumes a file - crypto-config.yaml - that contains the network topology and allows us to generate a set of certificates and keys for both the Organizations and the components that belong to those Organizations. Each Organization is provisioned a unique root certificate (ca-cert) that binds specific components (peers and orderers) to that Org. By assigning each Organization a unique CA certificate, we are mimicking a typical network where a participating Member would use its own Certificate Authority. Transactions and communications within Hyperledger Fabric are signed by an entity’s private key (keystore), and then verified by means of a public key (signcerts).You will notice a count variable within this file. We use this to specify the number of peers per Organization; in our case there are two peers per Org. The naming convention for a network entity is as follows - “{{.Hostname}}.{{.Domain}}”. So using our ordering node as a reference point, we are left with an ordering node named - orderer.walmartlabs.com that is tied to an MSP ID of Orderer. 
    
        Command: ../bin/cryptogen generate --config=./crypto-config.yaml

    After we run the cryptogen tool, the generated certificates and keys will be saved to a folder titled crypto-config.


2. Configuration Transaction Generator - The configtxgen tool is used to create four configuration artifacts:

        a) Orderer genesis block,
        b) Channel channel configuration transaction,
        c) Two anchor peer transactions - one for each Peer Org.
     
        1. Execute the below commands
        export FABRIC_CFG_PATH=$PWD
        ../bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block

        2. Channel Transaction artifact
        export CHANNEL_NAME=mychannel
        ../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

        3. Anchor Peer for Orgs
        ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
        ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

        4. Bring up the network
        ./cc_network -m up

3. Create and Join channel

        1. Set the below required environment variable (already done in CLI docker-compose script)
            CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.walmartlabs.com/users/Admin@dealer.walmartlabs.com/msp
            CORE_PEER_ADDRESS=peer0.dealer.walmartlabs.com:7051
            CORE_PEER_LOCALMSPID=DealerMSP
            CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.walmartlabs.com/peers/peer0.dealer.walmartlabs.com/tls/ca.crt
            CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.walmartlabs.com/peers/peer0.dealer.walmartlabs.com/tls/server.key
        2. Login to the CLI docker VM
            docker exec -it cli bash
        
        3. Create and join channel

            a) export CHANNEL_NAME=mychannel

            b) peer channel create -o orderer.walmartlabs.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/walmartlabs.com/orderers/orderer.walmartlabs.com/msp/tlscacerts/tlsca.walmartlabs.com-cert.pem

            c) peer channel join -b <channel-ID.block> (<channel-ID.block> is returned for the previous command)

4. Install & Instantiate Chaincode

        1. Install the chaincode on all four peers using the below command.
            peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/walmartlabs/chaincode/go/chaincode_example02

        2. Instantiate the chaincode using the below command
            peer chaincode instantiate -o orderer.walmartlabs.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/walmartlabs.com/orderers/orderer.walmartlabs.com/msp/tlscacerts/tlsca.walmartlabs.com-cert.pem -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('DealerMSP.member','BankerMSP.member')"

        3. Query to check the value of "a"
            peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

        4. Move 10 from 'a' to 'b' and check the value of 'a' again
            peer chaincode invoke -o orderer.walmartlabs.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/walmartlabs.com/orderers/orderer.walmartlabs.com/msp/tlscacerts/tlsca.walmartlabs.com-cert.pem  -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'
            
            peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
