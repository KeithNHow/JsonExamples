/// <summary>
/// Codeunit JsonTools (ID 51000).
/// Variant - Represents an AL variable object. The AL variant data type can contain many AL data types.
/// Jsonobject - Is a container for JSON object. default JsonObject contains an empty JSON object.
/// JsonArray - Is a container for JSON array. default contains an empty JSON array.
/// JsonToken - Is a container for JSON data. default contains the JSON value of NULL.
/// JsonValue - Is a container for JSON value. default is set to the JSON value of NULL.
/// RecordRef - References a record in a table.
/// FieldRef - References a field in a table.
/// FieldType - References the type of a table field
/// </summary>
codeunit 51000 "KNH_JsonTools"
{
    /// <summary>
    /// Json2Rec.
    /// </summary>
    /// <param name="jsObject">JsonObject.</param>
    /// <param name="variantrec">Variant.</param>
    /// <returns>Return value of type Variant.</returns>
    procedure Json2Rec(jsObject: JsonObject; variantrec: Variant): Variant //rec json obj and variant rec and return variant
    var
        recordRef: RecordRef;
    begin
        recordRef.GetTable(variantrec);
        exit(Json2Rec(jsObject, recordRef.Number())); //return variant
    end;

    /// <summary>
    /// Json2Rec.
    /// </summary>
    /// <param name="JsObject">JsonObject.</param>
    /// <param name="TableNo">Integer.</param>
    /// <returns>Return value of type Variant.</returns>
    procedure Json2Rec(JsObject: JsonObject; TableNo: Integer): Variant //recive json object and table no, return variant
    var
        recordRef: RecordRef;
        fieldRef: FieldRef;
        fieldHash: Dictionary of [Text, Integer];
        jsToken: JsonToken;
        jsValue: JsonValue;
        recVariant: Variant;
        jsKey: Text;
        i: Integer;
    begin
        recordRef.Open(TableNo);
        for i := 1 to recordRef.FieldCount() do begin //loop for each field in ref record
            fieldRef := recordRef.FieldIndex(i);
            fieldHash.Add(GetJsonFieldName(fieldRef), fieldRef.Number);
        end;
        recordRef.Init();
        foreach jsKey in jsObject.Keys() do //loop for each field in json object
            if jsObject.Get(jsKey, jstoken) then //place field in token 
                if jsToken.IsValue() then begin //check token has value
                    jsValue := jstoken.AsValue(); //converts value in json token to json value
                    fieldRef := recordRef.Field(fieldHash.Get(jsKey)); //place key value in field ref
                    AssignValueToFieldRef(fieldRef, jsValue); //convert json value to field ref
                end;
        recVariant := recordRef;
        exit(recVariant); //return variant 
    end;

    /// <summary>
    /// Rec2Json.
    /// </summary>
    /// <param name="variantRec">Variant.</param>
    /// <returns>Return value of type JsonObject.</returns>
    procedure Rec2Json(variantRec: Variant): JsonObject //receive variant value and return json object
    var
        recordRef: RecordRef;
        fieldRef: FieldRef;
        jsObject: JsonObject;
        i: Integer;
    begin
        if not variantRec.IsRecord then
            Error('Parameter Rec is not a record');
        recordRef.GetTable(variantRec);
        for i := 1 to recordRef.FieldCount() do begin //loop for each field
            fieldRef := recordRef.FieldIndex(i);
            case fieldRef.Class of
                fieldRef.Class::Normal:
                    jsObject.Add(GetJsonFieldName(fieldRef), FieldRef2JsonValue(fieldRef)); //add jsValue with key
                fieldRef.Class::FlowField:
                    begin
                        fieldRef.CalcField();
                        jsObject.Add(GetJsonFieldName(fieldRef), FieldRef2JsonValue(fieldRef)); //add jsValue with key
                    end;
            end;
        end;
        exit(jsObject);
    end;

    local procedure FieldRef2JsonValue(fieldRef: FieldRef): JsonValue //receive var and return json value
    var
        jsValue: JsonValue;
        jsDate: Date;
        jsDateTime: DateTime;
        jsTime: Time;
    begin
        case fieldRef.Type() of
            FieldType::Date:
                begin
                    jsDate := fieldRef.Value; //place value in date var
                    jsValue.SetValue(jsDate); //convert to json value
                end;
            FieldType::Time:
                begin
                    jsTime := fieldRef.Value; //place value in time var
                    jsValue.SetValue(jsTime); //convert to json value
                end;
            FieldType::DateTime:
                begin
                    jsDateTime := fieldRef.Value; //place value in datetime var
                    jsValue.SetValue(jsDateTime); //convert to json value
                end;
            else
                jsValue.SetValue(Format(fieldRef.Value, 0, 9)); //place value in json value by formatting to to text
        end;
        exit(jsValue);
    end;

    local procedure GetJsonFieldName(fieldRef: FieldRef): Text //receive field ref and return text var
    var
        name: Text;
        i: Integer;
    begin
        name := fieldRef.Name(); //place field ref name in text var
        for i := 1 to Strlen(name) do //for each char in name
            if name[i] < '0' then
                name[i] := '_'; //convert char less than 0
        exit(name.Replace('__', '_').TrimEnd('_').TrimStart('_')); //change name
    end;

    local procedure AssignValueToFieldRef(var fdRef: FieldRef; JsValue: JsonValue) //receive and return field ref and receive json value
    var
        fdType: FieldType;
    begin
        case fdRef.Type() of
            fdType::Code,
            fdType::Text:
                fdRef.Value := JsValue.AsText(); //convert to field ref
            fdType::Integer:
                fdRef.Value := JsValue.AsInteger(); //convert to field ref
            fdType::Date:
                fdRef.Value := JsValue.AsDate(); //convert to field ref
            else
                Error('%1 is not a supported field type', fdRef.Type());
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
        Json_Managaement: Codeunit "Json Management";
        ObjectJsonManagement: Codeunit "Json management";
        i: Integer;
        CodeText: Text;
        CustomerJsonObject: Text;
        JsonArrayText: Text;
        ShipToJsonObject: Text;
    begin
        Json_Managaement.InitializeObject(JsonObjectText);
        if Json_Managaement.GetArrayPropertyValueAsStringByName('Customer', CustomerJsonObject) then begin
            Json_Managaement.InitializeObject(CustomerJsonObject);

            Customer.Init();
            ObjectJsonManagement.GetStringPropertyValueByName('No', CodeText);
            Customer.Validate("No.", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(Customer."No.")));
            ObjectJsonManagement.GetStringPropertyValueByName('Address', CodeText);
            Customer.Validate("No.", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(Customer."Address")));
            Customer.Insert();

            Json_Managaement.InitializeObject(CustomerJsonObject);
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
