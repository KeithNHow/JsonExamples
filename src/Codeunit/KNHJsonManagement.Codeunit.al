namespace JsonExamples;
using Microsoft.Sales.Customer;
using System.Text;

codeunit 51000 "KNH Json Management"
{
    procedure ReadJson(JsonObjectText: Text)
    var
        Customer: Record Customer; //18
        ShipToAddress: Record "Ship-to Address"; //222
        ArrayJSONManagement: Codeunit "Json Management";
        GenJsonManagement: Codeunit "Json Management"; //5459
        ObjectJsonManagement: Codeunit "Json management";
        I: Integer;
        CodeText: Text;
        CustomerJsonObject: Text;
        JsonArrayText: Text;
        ShipToJsonObject: Text;
    begin
        GenJsonManagement.InitializeObject(JsonObjectText);
        if GenJsonManagement.GetArrayPropertyValueAsStringByName('Customer', CustomerJsonObject) then begin
            GenJsonManagement.InitializeObject(CustomerJsonObject);

            Customer.Init();
            ObjectJsonManagement.GetStringPropertyValueByName('No', CodeText);
            Customer.Validate("No.", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(Customer."No.")));
            ObjectJsonManagement.GetStringPropertyValueByName('Address', CodeText);
            Customer.Validate("No.", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(Customer."Address")));
            Customer.Insert();

            GenJsonManagement.InitializeObject(CustomerJsonObject);
            if ObjectJsonManagement.GetStringPropertyValueByName('Ship-to', JsonArrayText) then begin
                ObjectJsonManagement.InitializeCollection(JsonArrayText);
                for I := 1 to ArrayJsonManagement.GetCollectionCount() do begin
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

    procedure Json2Rec(ResponseObject: JsonObject; VariantRec: Variant): Variant //Receive json obj and variant rec and return variant
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(VariantRec);
        exit(this.Json2Rec(ResponseObject, RecordRef.Number())); //Return variant
    end;

    procedure Json2Rec(ResponseObject: JsonObject; TableNo: Integer): Variant //Receive json object and table no, return variant
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldHash: Dictionary of [Text, Integer];
        ResponseToken: JsonToken;
        ResponseValue: JsonValue;
        RecVariant: Variant;
        ResponseKey: Text;
        I: Integer;
    begin
        RecordRef.Open(TableNo);
        for I := 1 to RecordRef.FieldCount() do begin //Loop for each field in ref record
            FieldRef := RecordRef.FieldIndex(i);
            FieldHash.Add(this.GetJsonFieldName(fieldRef), fieldRef.Number);
        end;
        RecordRef.Init();
        foreach ResponseKey in ResponseObject.Keys() do //Loop for each field in json object
            if ResponseObject.Get(ResponseKey, ResponseToken) then //Get json token 
                if ResponseToken.IsValue() then begin //Check json token has value
                    ResponseValue := ResponseToken.AsValue(); //Convert json token to json value
                    FieldRef := RecordRef.Field(FieldHash.Get(ResponseKey)); //Place key value in fieldref
                    this.AssignValueToFieldRef(fieldRef, ResponseValue); //Convert json value to fieldref
                end;
        RecVariant := RecordRef;
        exit(RecVariant); //Return variant 
    end;

    procedure Rec2Json(VariantRec: Variant): JsonObject //Receive variant value and return json object
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        SendObject: JsonObject;
        I: Integer;
    begin
        if not variantRec.IsRecord then
            Error('Parameter Rec is not a record');
        RecordRef.GetTable(VariantRec);
        for I := 1 to RecordRef.FieldCount() do begin //Loop for each field
            FieldRef := RecordRef.FieldIndex(I);
            case FieldRef.Class of
                FieldRef.Class::Normal:
                    SendObject.Add(this.GetJsonFieldName(FieldRef), this.FieldRef2JsonValue(FieldRef)); //Add json value with key
                FieldRef.Class::FlowField:
                    begin
                        FieldRef.CalcField();
                        SendObject.Add(this.GetJsonFieldName(FieldRef), this.FieldRef2JsonValue(FieldRef)); //Add json value with key
                    end;
            end;
        end;
        exit(SendObject);
    end;

    local procedure FieldRef2JsonValue(FieldRef: FieldRef): JsonValue //receive var and return json value
    var
        ResponseValue: JsonValue;
        TempDate: Date;
        TempDateTime: DateTime;
        TempTime: Time;
    begin
        case FieldRef.Type() of
            FieldType::Date:
                begin
                    TempDate := FieldRef.Value; //Place fieldref in date variable
                    ResponseValue.SetValue(TempDate); //Convert date to json value
                end;
            FieldType::Time:
                begin
                    TempTime := FieldRef.Value; //Place fieldref in time variable
                    ResponseValue.SetValue(TempTime); //Convert time to json value
                end;
            FieldType::DateTime:
                begin
                    TempDateTime := FieldRef.Value; //Place fieldref in datetime variable
                    ResponseValue.SetValue(TempDateTime); //Convert datetime to json value
                end;
            else
                ResponseValue.SetValue(Format(FieldRef.Value, 0, 9)); //Format fieldref and convert to json value
        end;
        exit(ResponseValue);
    end;

    local procedure GetJsonFieldName(FieldRef: FieldRef): Text //Receive fieldref and return text variable
    var
        Name: Text;
        I: Integer;
    begin
        Name := FieldRef.Name(); //Place fieldref name in text variable
        for I := 1 to Strlen(Name) do //For each char in name
            if Name[i] < '0' then
                Name[i] := '_'; //Convert char less than 0
        exit(Name.Replace('__', '_').TrimEnd('_').TrimStart('_')); //Change name
    end;

    local procedure AssignValueToFieldRef(var FieldRef: FieldRef; ResponseValue: JsonValue) //Receive and return fieldref and receive json value
    var
        FieldType: FieldType;
    begin
        case FieldRef.Type() of
            FieldType::Code,
            FieldType::Text:
                FieldRef.Value := ResponseValue.AsText(); //Convert json text to value
            FieldType::Integer:
                FieldRef.Value := ResponseValue.AsInteger(); //convert json integer to value
            FieldType::Date:
                FieldRef.Value := ResponseValue.AsDate(); //convert json date to value
            else
                Error('%1 is not a supported field type', FieldRef.Type());
        end;
    end;
}
