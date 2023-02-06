/// <summary>
/// Codeunit KNH API Test (ID 51001).
/// </summary>
codeunit 51001 "KNH API Test"
{
    /// <summary>
    /// GetAPIToken.
    /// </summary>
    /// <param name="txtresponse">Text.</param>
    procedure GetAPIToken(txtresponse: Text) //receive response
    var
        TestAPI: Record "KNH API Sample";
        jsObject: JsonObject;
        jsValue: JsonValue;
        jsToken: JsonToken;
        jsKey: Text;
        RecCount: Integer;
    begin
        TestAPI.Reset();
        if TestAPI.FindLast() then
            RecCount := TestAPI.ID + 1
        else
            RecCount := 1;
        if jsToken.ReadFrom(txtResponse) then //Read response into json token
            if jsToken.IsObject() then begin //Check json token contains a json object
                jsObject := jsToken.AsObject(); //Extract json object from json token
                TestAPI.Reset();
                TestAPI.Init();
                TestAPI.ID := RecCount;
                foreach jsKey in jsObject.Keys() do begin //loop for each field in json object
                    if jsKey = 'accesstoken' then //if field key = access token
                        TestAPI.AccessToken := CopyStr(jsValue.AsText(), 1, 100); //Get json value 
                    if jsKey = 'expires_in' then //if field key = expires in
                        TestAPI.ExpiresIn := CopyStr(jsValue.AsText(), 1, 20);
                end;
                TestAPI.Insert();
                RecCount += 1;
            end;
    end;

    /// <summary>
    /// ReadJSON - using Json Management codeunit. 
    /// </summary>
    /// <param name="JsonObjectText">Text.</param>
    procedure ReadJSON(JsonObjectText: Text) //5459
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        ArrayJSONManagement: Codeunit "Json Management";
        JsonManagaement: Codeunit "Json Management";
        ObjectJsonManagement: Codeunit "Json management";
        i: Integer;
        CodeText: Text;
        CustomerJsonObject: Text;
        JsonArrayText: Text;
        ShipToJsonObject: Text;
    begin
        JsonManagaement.InitializeObject(JsonObjectText);
        if JsonManagaement.GetArrayPropertyValueAsStringByName('Customer', CustomerJsonObject) then begin
            JsonManagaement.InitializeObject(CustomerJsonObject);

            Customer.Init();
            ObjectJsonManagement.GetStringPropertyValueByName('No', CodeText);
            Customer.Validate("No.", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(Customer."No.")));
            ObjectJsonManagement.GetStringPropertyValueByName('Address', CodeText);
            Customer.Validate("No.", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(Customer."Address")));
            Customer.Insert();

            JsonManagaement.InitializeObject(CustomerJsonObject);
            if ObjectJsonManagement.GetStringPropertyValueByName('Ship-to', JsonArrayText) then begin
                ObjectJsonManagement.InitializeCollection(JsonArrayText);
                for i := 1 to ArrayJsonManagement.GetCollectionCount() do begin
                    ArrayJSONManagement.GetObjectFromCollectionByIndex(ShipToJsonObject, i);

                    ShipToAddress.Init();
                    ShipToAddress.Validate("Customer No.", Customer."No.");
                    ObjectJsonManagement.GetStringPropertyValueByName('Code', CodeText);
                    ShipToAddress.Validate("Code", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(ShipToAddress.Code)));
                    ObjectJsonManagement.GetStringPropertyValueByName('Address', CodeText);
                    ShipToAddress.Validate("Address", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(ShipToAddress.Address)));
                    ShipToAddress.Insert();
                end;
            end;
        end;
    end;
}
