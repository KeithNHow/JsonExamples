///<summary>
///Procedures - ReadJson, Json2Rec, Rec2Json, FieldRef2JsonValue, GetJsonFieldName, AssignValueToFieldRef
///This codeunit demonstrates how to read a JSON object, convert JSON to record and record to JSON, and assign values to field references.
///</summary>
namespace KNHJsonExamples;
using Microsoft.Sales.Customer;
using System.Text;

codeunit 51000 KNHJsonManagement
{
    procedure ReadJson(JsonObjectText: Text)
    var
        Customer: Record Customer; //18
        ShipToAddress: Record "Ship-to Address"; //222
        ArrayJSONManagement: Codeunit "JSON Management";
        GenJsonManagement: Codeunit "JSON Management"; //5459
        ObjectJsonManagement: Codeunit "JSON Management";
        I: Integer;
        CodeText: Text;
        CustomerJsonObject: Text;
        JsonArrayText: Text;
        ShipToJsonObject: Text;
    begin
        GenJsonManagement.InitializeObject(JsonObjectText); //Initialize the JSON object
        if GenJsonManagement.GetArrayPropertyValueAsStringByName('Customer', CustomerJsonObject) then begin //Get the 'Customer' array from the JSON object
            GenJsonManagement.InitializeObject(CustomerJsonObject);  //Initialize the Customer JSON object

            Customer.Init(); //Initialize the Customer record
            ObjectJsonManagement.GetStringPropertyValueByName('No', CodeText); //Get the 'No' property from the JSON object
            Customer.Validate("No.", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(Customer."No."))); //Validate the 'No' field
            ObjectJsonManagement.GetStringPropertyValueByName('Address', CodeText); //Get the 'Address' property from the JSON object
            Customer.Validate("No.", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(Customer.Address))); //Validate the 'Address' field
            Customer.Insert(); //Insert the Customer record

            GenJsonManagement.InitializeObject(CustomerJsonObject); //Re-initialize the Customer JSON object to extract more properties
            if ObjectJsonManagement.GetStringPropertyValueByName('Ship-to', JsonArrayText) then begin //Get the 'Ship-to' array from the JSON object
                ObjectJsonManagement.InitializeCollection(JsonArrayText); //Initialize the collection from the JSON array
                for I := 1 to ArrayJSONManagement.GetCollectionCount() do begin //Loop through each item in the collection
                    ArrayJSONManagement.GetObjectFromCollectionByIndex(ShipToJsonObject, I); //Get the Ship-to JSON object by index

                    ShipToAddress.Init(); //Initialize the Ship-to Address record
                    ShipToAddress.Validate("Customer No.", Customer."No."); //Validate the 'Customer No.' field
                    ObjectJsonManagement.GetStringPropertyValueByName('Code', CodeText); //Get the 'Code' property from the JSON object
                    ShipToAddress.Validate("Code", CopyStr(CodeText.ToUpper(), 1, MaxStrLen(ShipToAddress.Code))); //Validate the 'Code' field
                    ObjectJsonManagement.GetStringPropertyValueByName('Address', CodeText); //Get the 'Address' property from the JSON object
                    ShipToAddress.Validate(Address, CopyStr(CodeText.ToUpper(), 1, MaxStrLen(ShipToAddress.Address))); //Validate the 'Address' field
                    ShipToAddress.Insert(); //Insert the Ship-to Address record
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
        I: Integer;
        ResponseToken: JsonToken;
        ResponseValue: JsonValue;
        ResponseKey: Text;
        RecVariant: Variant;
    begin
        RecordRef.Open(TableNo);
        for I := 1 to RecordRef.FieldCount() do begin //Loop for each field in ref record
            FieldRef := RecordRef.FieldIndex(I);
            FieldHash.Add(this.GetJsonFieldName(FieldRef), FieldRef.Number);
        end;
        RecordRef.Init();
        foreach ResponseKey in ResponseObject.Keys() do //Loop for each field in json object
            if ResponseObject.Get(ResponseKey, ResponseToken) then //Get json token 
                if ResponseToken.IsValue() then begin //Check json token has value
                    ResponseValue := ResponseToken.AsValue(); //Convert json token to json value
                    FieldRef := RecordRef.Field(FieldHash.Get(ResponseKey)); //Place key value in fieldref
                    this.AssignValueToFieldRef(FieldRef, ResponseValue); //Convert json value to fieldref
                end;
        RecVariant := RecordRef;
        exit(RecVariant); //Return variant 
    end;

    procedure Rec2Json(VariantRec: Variant): JsonObject //Receive variant value and return json object
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        I: Integer;
        SendObject: JsonObject;
    begin
        if not VariantRec.IsRecord then
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
        TempDate: Date;
        TempDateTime: DateTime;
        ResponseValue: JsonValue;
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
        I: Integer;
        Name: Text;
    begin
        Name := FieldRef.Name(); //Place fieldref name in text variable
        for I := 1 to StrLen(Name) do //For each char in name
            if Name[I] < '0' then
                Name[I] := '_'; //Convert char less than 0
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
