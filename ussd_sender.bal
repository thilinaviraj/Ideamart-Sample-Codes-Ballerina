import ballerina/http;
import ballerina/io;
import ballerina/log;

//Make sure to run the ideamart simulator before you run the code

//Create the client endpoint
endpoint http:Client clientEndpoint {
    url: "http://localhost:7000"
};

// This function wrties characters to 'channel'
function writeCharacters(io:CharacterChannel channel, string content,
                         int startOffset) {
    //This is how the characters are written.
    match channel.write(content, startOffset) {
        int numberOfCharsWritten => {
            io:println(" No of characters written : " + numberOfCharsWritten);
        }
        error err => {
            throw err;
        }
    }
}


// This function returns a CharacterChannel from a given file location,
// according to the permissions and encoding that you specify.
function getFileCharacterChannel(string filePath, io:Mode permission,
                                 string encoding) returns io:CharacterChannel {
    // First, get the ByteChannel representation of the file.
    io:ByteChannel channel = io:openFile(filePath, permission);
    // Then, create an instance of the CharacterChannel from the ByteChannel
    // to read content as text.
    io:CharacterChannel charChannel = new(channel, encoding);
    return charChannel;
    
}

function main(string... args) {
    //create new http request
    http:Request req = new;
    //define the headers
    req.addHeader("Content-Type", "application/json");
    var destinationChannel = getFileCharacterChannel("./files/ussdsenderLog.txt",io:WRITE, "UTF-8");

    //define the json payload
    json payload = {"message": "1. Press One 2. Press two 3. Press three, 4. Exit","destinationAddress": "tel:94777123456","password": "password","applicationId": "APP_OO1","ussdOperation": "mt-cont","sessionId": "1330929317043"};
    req.setJsonPayload(payload, contentType = "application/json");
    string StrPayload = payload.toString();

    var response = clientEndpoint->post("/ussd/send", req);
    match response {
        http:Response resp => {
            
            int statusCode = resp.statusCode;
            var txt=resp.getPayloadAsString();
            io:println("From the response : ",txt);
            
            log:printInfo("Status code: " + statusCode+ "\nUSSD message sent successfully");
            var textLog="Request body: "+StrPayload+" Response: "+statusCode+"\n";
            writeCharacters(destinationChannel, textLog, 0);

        }
        //Print the error log
        error err => { log:printError(err.message, err = err); }

    }
  
}

