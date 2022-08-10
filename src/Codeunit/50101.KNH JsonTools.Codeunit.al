/// <summary>
/// Codeunit JsonTools (ID 50001).
/// </summary>
codeunit 50101 "KNH JsonTools"
{
    /// <summary>
    /// Json2Rec.
    /// </summary>
    /// <param name="JsonObj">JsonObject.</param>
    /// <param name="Rec">Variant.</param>
    /// <returns>Return value of type Variant.</returns>
    procedure Json2Rec(JsonObj: JsonObject; Rec: Variant): Variant
    var
        Ref: RecordRef;
    begin
        Ref.GetTable(Rec);
        exit(Json2Rec(JsonObj, Ref.Number()));
    end;

    /// <summary>
    /// Json2Rec.
    /// </summary>
    /// <param name="JsonObj">JsonObject.</param>
    /// <param name="TableNo">Integer.</param>
    /// <returns>Return value of type Variant.</returns>
    procedure Json2Rec(JsonObj: JsonObject; TableNo: Integer): Variant
    var
        i: Integer;
        recVar: Variant;
        recRef: RecordRef;
        fdRef: FieldRef;
        fieldHash: Dictionary of [Text, Integer];
        jsonKey: Text;
        token: JsonToken;
        jsonKeyValue: JsonValue;
    begin
        RecRef.Open(TableNo);
        for i := 1 to RecRef.FieldCount() do begin
            fdRef := RecRef.FieldIndex(i);
            fieldHash.Add(GetJsonFieldName(fdRef), fdRef.Number);
        end;
        RecRef.Init();
        foreach JsonKey in JsonObj.Keys() do begin //loop for each record
            if JsonObj.Get(jsonKey, token) then begin //get record 
                if token.IsValue() then begin //check token has value
                    jsonKeyValue := token.AsValue();
                    fdRef := recRef.Field(fieldHash.Get(jsonKey));
                    AssignValueToFieldRef(fdRef, jsonKeyValue);
                end;
            end;
        end;
        recVar := recRef;
        exit(recVar);
    end;

    /// <summary>
    /// Rec2Json.
    /// </summary>
    /// <param name="Rec">Variant.</param>
    /// <returns>Return value of type JsonObject.</returns>
    procedure Rec2Json(Rec: Variant): JsonObject
    var
        recRef: RecordRef;
        jsonObj: JsonObject;
        fdRef: FieldRef;
        i: Integer;
    begin
        if not Rec.IsRecord then
            Error('Parameter Rec is not a record');
        recRef.GetTable(Rec);
        for i := 1 to recRef.FieldCount() do begin
            FdRef := recRef.FieldIndex(i);
            case fdRef.Class of
                fdRef.Class::Normal:
                    jsonObj.Add(GetJsonFieldName(fdRef), FieldRef2JsonValue(fdRef));
                fdRef.Class::FlowField:
                    begin
                        fdRef.CalcField();
                        jsonObj.Add(GetJsonFieldName(fdRef), FieldRef2JsonValue(fdRef));
                    end;
            end;
        end;
        exit(jsonObj);
    end;

    local procedure FieldRef2JsonValue(fRef: FieldRef): JsonValue
    var
        jsonVal: JsonValue;
        d: Date;
        dt: DateTime;
        t: Time;
    begin
        case fRef.Type() of
            FieldType::Date:
                begin
                    d := FRef.Value;
                    jsonVal.SetValue(D);
                end;
            FieldType::Time:
                begin
                    t := fRef.Value;
                    jsonVal.SetValue(T);
                end;
            FieldType::DateTime:
                begin
                    dt := fRef.Value;
                    jsonVal.SetValue(DT);
                end;
            else
                jsonVal.SetValue(Format(fRef.Value, 0, 9));
        end;
        exit(jsonVal);
    end;

    local procedure GetJsonFieldName(fdRef: FieldRef): Text
    var
        name: Text;
        i: Integer;
    begin
        name := fdRef.Name();
        for i := 1 to Strlen(name) do begin
            if name[i] < '0' then
                name[i] := '_';
        end;
        exit(name.Replace('__', '_').TrimEnd('_').TrimStart('_'));
    end;

    local procedure AssignValueToFieldRef(var fdRef: FieldRef; JsonKeyValue: JsonValue)
    begin
        case fdRef.Type() of
            FieldType::Code,
            FieldType::Text:
                fdRef.Value := JsonKeyValue.AsText();
            FieldType::Integer:
                fdRef.Value := JsonKeyValue.AsInteger();
            FieldType::Date:
                fdRef.Value := JsonKeyValue.AsDate();
            else
                Error('%1 is not a supported field type', fdRef.Type());
        end;
    end;
}
