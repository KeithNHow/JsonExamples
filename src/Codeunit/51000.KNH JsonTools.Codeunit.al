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
codeunit 51000 "KNH JsonTools"
{
    /// <summary>
    /// Json2Rec.
    /// </summary>
    /// <param name="jsObject">JsonObject.</param>
    /// <param name="rec">Variant.</param>
    /// <returns>Return value of type Variant.</returns>
    procedure Json2Rec(jsObject: JsonObject; rec: Variant): Variant //rec json obj and variant rec and return variant
    var
        recRef: RecordRef;
    begin
        recRef.GetTable(rec);
        exit(Json2Rec(jsObject, recRef.Number())); //return variant
    end;

    /// <summary>
    /// Json2Rec.
    /// </summary>
    /// <param name="JsObject">JsonObject.</param>
    /// <param name="TableNo">Integer.</param>
    /// <returns>Return value of type Variant.</returns>
    procedure Json2Rec(JsObject: JsonObject; TableNo: Integer): Variant //recive json object and table no, return variant
    var
        recRef: RecordRef;
        fdRef: FieldRef;
        fieldHash: Dictionary of [Text, Integer];
        jsToken: JsonToken;
        jsValue: JsonValue;
        recVariant: Variant;
        jsKey: Text;
        i: Integer;
    begin
        recRef.Open(TableNo);
        for i := 1 to recRef.FieldCount() do begin //loop for each field in ref record
            fdRef := recRef.FieldIndex(i);
            fieldHash.Add(GetJsonFieldName(fdRef), fdRef.Number);
        end;
        recRef.Init();
        foreach jsKey in jsObject.Keys() do //loop for each field in json object
            if jsObject.Get(jsKey, jstoken) then //place field in token 
                if jsToken.IsValue() then begin //check token has value
                    jsValue := jstoken.AsValue(); //converts value in json token to json value
                    fdRef := recRef.Field(fieldHash.Get(jsKey)); //place key value in field ref
                    AssignValueToFieldRef(fdRef, jsValue); //convert json value to field ref
                end;
        recVariant := recRef;
        exit(recVariant); //return variant 
    end;

    /// <summary>
    /// Rec2Json.
    /// </summary>
    /// <param name="Rec">Variant.</param>
    /// <returns>Return value of type JsonObject.</returns>
    procedure Rec2Json(Rec: Variant): JsonObject //receive variant value and return json object
    var
        recRef: RecordRef;
        fdRef: FieldRef;
        jsObject: JsonObject;
        i: Integer;
    begin
        if not Rec.IsRecord then
            Error('Parameter Rec is not a record');
        recRef.GetTable(Rec);
        for i := 1 to recRef.FieldCount() do begin //loop for each field
            fdRef := recRef.FieldIndex(i);
            case fdRef.Class of
                fdRef.Class::Normal:
                    jsObject.Add(GetJsonFieldName(fdRef), FieldRef2JsonValue(fdRef)); //add jsValue with key
                fdRef.Class::FlowField:
                    begin
                        fdRef.CalcField();
                        jsObject.Add(GetJsonFieldName(fdRef), FieldRef2JsonValue(fdRef)); //add jsValue with key
                    end;
            end;
        end;
        exit(jsObject);
    end;

    local procedure FieldRef2JsonValue(fdRef: FieldRef): JsonValue //receive var and return json value
    var
        jsValue: JsonValue;
        jsDate: Date;
        jsDateTime: DateTime;
        jsTime: Time;
    begin
        case fdRef.Type() of
            FieldType::Date:
                begin
                    jsDate := fdRef.Value; //place value in date var
                    jsValue.SetValue(jsDate); //convert to json value
                end;
            FieldType::Time:
                begin
                    jsTime := fdRef.Value; //place value in time var
                    jsValue.SetValue(jsTime); //convert to json value
                end;
            FieldType::DateTime:
                begin
                    jsDateTime := fdRef.Value; //place value in datetime var
                    jsValue.SetValue(jsDateTime); //convert to json value
                end;
            else
                jsValue.SetValue(Format(fdRef.Value, 0, 9)); //place value in json value by formatting to to text
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
}
