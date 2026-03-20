# Json Examples Extension
This extension consists of 4 codeunits, 2 pages, 1 page extension and 1 table. It demonstrates importing and exporting API files.

# Json Token
Is a container for any well-formed JSON data. A default JsonToken object contains the JSON value of NULL.
AsArray() - Converts the value in a JsonToken to a JsonArray data type.
AsObject() - Converts the value in a JsonToken to a JsonObject data type.
AsValue() - Converts the value in a JsonToken to a JsonValue data type.
Path() - Retrieves the JSON path of the token relative to the root of its containing tree.
ReadFrom(Text) - Reads the JSON data from the string into a JsonToken variable.
ReadFrom(InStream) - Reads the JSON data from the stream into a JsonToken variable.

Variant - Represents an AL variable object. The AL variant data type can contain many AL data types.
Json containers - JsonToken, JsonObject, JsonArray, JsonValue
Reference objects - RecordRef, FieldRef, FieldType

# Import File table 
-This is a table that defines the structure of the data for imported files. It has three fields: ID, AccessToken, and ExpiresIn. -The ID field is an auto-incrementing integer that serves as the primary key. The AccessToken field is a text field that can store up to 100 characters, and the ExpiresIn field is a text field that can store up to 20 characters. 
-This table allows for storing information about imported files, such as access tokens and their expiration times.

# Import File page
-This is a list page that shows records of the table "KNHImportFile". It has two actions, one to get data from an API and another to get data from an external file. 
-The first action uses the HttpClient class to send a GET request to a specified URL with custom headers and reads the response content as text. 
-The second action allows the user to upload a file, reads its content into a text variable, and displays it in a message box.

# Get Fact page 
-This page 'Get Fact' demonstrates how to call a REST API and read the JSON response. 
-The 'Get A Fact' procedure is called from the page layout. It calls an API that returns a random cat fact.
-The 'Get A Villain' procedure calls an API that returns a list of dog breeds and counts them.

# Export to Json codeunit
-This codeunit demonstrates how to export a purchase order with its lines and line comments to a JSON file.

# Import from Json file codeunit
-This codeunit demonstrates how to import purchase order data from a JSON file. It includes procedures to request a JSON file from the user, parse the JSON data, and create purchase orders and lines in the system based on the imported data. The code handles JSON objects and arrays, and it also includes error handling for missing or invalid data in the JSON file.

# Json Loop Import
This codeunit demonstrates how to import records from a JSON file.

# Json Management codeunit (Not in use)
-Procedures: ReadJson, Json2Rec, Json2Rec, Rec2Json, FieldRef2JsonValue, GetJsonFieldName, AssignValueToFieldRef
-This codeunit demonstrates how to read a JSON object, convert JSON to record and record to JSON, and assign values to field references.