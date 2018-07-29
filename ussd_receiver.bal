import ballerina/http;
import ballerina/log;
import ballerina/io;


//Set the URL in the SMS Application data as http://localhost:9000/ussd/receiver

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

service<http:Service> ussd bind { port: 9000 } {

        // Invoke all resources with arguments of server connector and request.
        receiver(endpoint caller, http:Request req) {
            http:Response res = new;
            
                json resPayload = check req.getJsonPayload();
                io:println("From the response : ",resPayload);
                var varPayload="Response body: "+resPayload.toString();
                
                //Create the file
                var destinationChannel = getFileCharacterChannel("./files/ussdreceiverLog.txt",io:WRITE, "UTF-8");
                writeCharacters(destinationChannel, varPayload, 0);

            // Send the response back to the caller.
            caller->respond(res) but { error e => log:printError("Error sending response", err = e) };
        }
    }
    
