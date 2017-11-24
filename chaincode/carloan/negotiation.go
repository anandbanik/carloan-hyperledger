package main

/* Imports
 * 4 utility libraries for formatting, handling bytes, reading and writing JSON, and string manipulation
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts
 */
import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// Define the Smart Contract structure
type SmartContract struct {
}

// Negotiation object definition
type Negotiation struct {
	CustomerID  string `json:"customer_id"`
	VinNumber   string `json:"vin_number"`
	ActualPrice string `json:"actual_price"`
	Comments    string `json:"comments"`
	DealerName  string `json:"dealer_name"`
}

// Init method
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "negotiation"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "queryNegotiations" {
		return s.queryNegotiation(APIstub, args)
	} else if function == "createNegotiation" {
		return s.createNegotiation(APIstub, args)
	} else if function == "queryAllNegotiations" {
		return s.queryAllNegotiations(APIstub)
	} else if function == "changeCarOwner" {
		return s.changeCarOwner(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

func (s *SmartContract) queryNegotiation(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	negotiationsAsBytes, _ := APIstub.GetState(args[0])
	return shim.Success(negotiationsAsBytes)
}

//Create a negotiation
func (s *SmartContract) createNegotiation(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 6 {
		return shim.Error("Incorrect number of arguments. Expecting 6")
	}

	var negotiations = Negotiation{CustomerID: args[1], VinNumber: args[2], ActualPrice: args[3], Comments: args[4], DealerName: args[5]}

	negotiationsAsBytes, _ := json.Marshal(negotiations)
	APIstub.PutState(args[0], negotiationsAsBytes)

	return shim.Success(nil)
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	} 
}
