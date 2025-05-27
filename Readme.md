# Json Examples Extension

# Json Token
Is a container for any well-formed JSON data. A default JsonToken object contains the JSON value of NULL.
AsArray() - Converts the value in a JsonToken to a JsonArray data type.
AsObject() - Converts the value in a JsonToken to a JsonObject data type.
AsValue() - Converts the value in a JsonToken to a JsonValue data type.
Path() - Retrieves the JSON path of the token relative to the root of its containing tree.
ReadFrom(Text) - Reads the JSON data from the string into a JsonToken variable.
ReadFrom(InStream) - Reads the JSON data from the stream into a JsonToken variable.

Variant - Represents an AL variable object. The AL variant data type can contain many AL data types.
JsonToken - is a container for well formed Json data. A default JsonToken object contains the JSON value of NULL.
JsonObject - Is a container for well formed JSON data. A default Json Object contains an empty JSON object
JsonArray - Is a container for well formed JSON array. A default Json array contains an empty Json Array.
JsonValue - Is a container for well formed JSON value. A default JsonValue is set to the JSON value of NULL.
RecordRef - References a record in a table.
FieldRef - References a field in a table.
FieldType - References the type of a table field

# Json Examples
---------------
This extension demonstrates how to import records from a CSV file.

# "Import File" table 
- holds records imported from import file containing Json records.
# "Import File" page
- imports Json data and display them.
    - Action: Get Json data from website. 
    - Action: Get Json data from external file. 
# "Get IP Address" page 
- displays IP address from http website.
    Action: Get IP address.
# "Import File"
- displays imported records.
    Action: Get Json data from website.
    Action: Get Json data from file.
# "Json Loop Import" codeunit 
- Called from action in Import file page. It reads Json records and creates records in import file table.
# "Json Management" codeunit (Not in use)
- Procedures: ReadJson, Json2Rec, Json2Rec, Rec2Json, FieldRef2JsonValue, GetJsonFieldName, AssignValueToFieldRef