import ballerina/http;
import ballerina/io;
import ballerina/uuid;
import ballerinax/mongodb;

// MongoDB configuration
configurable string host = "localhost";
configurable int port = 27017;

final mongodb:Client mongoDb = check new ({
    connection: {
        serverAddress: {
            host,
            port
        }
    }
});

// Define CORS configuration
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173"],
        allowHeaders: ["REQUEST_ID", "Content-Type"],
        exposeHeaders: ["RESPONSE_ID"],
        allowMethods: ["GET", "POST", "OPTIONS"],
        maxAge: 84900
    }
}

service / on new http:Listener(9091) {
    private final mongodb:Database userDb;

    function init() returns error? {
        self.userDb = check mongoDb->getDatabase("tikevent");
        io:println("MongoDB connected to UserDb");
    }

    // Handle user signup
    resource function post signup(UserInput input) returns json|error {
        // Check if the email already exists
        mongodb:Collection users = check self.userDb->getCollection("fisherman");
        User? existingUser = check users->findOne({email: input.email});

        if (existingUser is User) {
            return error("Email is already in use.");
        }

        // If email doesn't exist, proceed to create the user without hashing the password
        string id = uuid:createType1AsString();
        User user = {id, ...input}; // Store the password as is
        check users->insertOne(user);
        return {id: id};
    }

    // Handle user login
    resource function post login(LoginInput input) returns json|error {
        mongodb:Collection users = check self.userDb->getCollection("fisherman");
        User? user = check users->findOne({email: input.email, password: input.password}); // Directly match the plain text password

        if (user is User) {
            return {id: user.id}; // Return user ID on successful login
        } else {
            return error("Invalid email or password"); // Return error message for failed login
        }
    }

    // Add this function to your Ballerina service
    resource function get user(string id) returns User|error {
        mongodb:Collection users = check self.userDb->getCollection("fisherman");
        User? user = check users->findOne({id: id});

        if (user is User) {
            return user; // Return user data
        } else {
            return error("User not found");
        }
    }

}

// UserInput type for creating new users
public type UserInput record {|
    string firstName;
    string lastName;
    string phoneNumber;
    string registrationNumber;
    string email;
    string password;
|};

// LoginInput type for user login 
public type LoginInput record {|
    string email;
    string password;
|};

// User type which includes a unique ID 
public type User record {|
    readonly string id;
    *UserInput;
|};