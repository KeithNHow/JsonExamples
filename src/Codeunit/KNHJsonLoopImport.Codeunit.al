namespace JsonExamples;

codeunit 51001 KNHJsonLoopImport
{
    procedure ImportRecords(Txtresponse: Text) //Receive response
    var
        KNHImportFile: Record KNHImportFile;
        RecCount: Integer;
        ResponseObject: JsonObject;
        ResponseToken: JsonToken;
        ResponseValue: JsonValue;
        RecordsCountedMsg: Label 'Records imported = %1', Comment = '%1 = Record Count';
        ResponseKey: Text;
    begin
        KNHImportFile.Reset();
        if KNHImportFile.FindLast() then
            RecCount := KNHImportFile.ID + 1
        else
            RecCount := 1;

        if ResponseToken.ReadFrom(Txtresponse) then //Read text into json token
            if ResponseToken.IsObject() then begin //Check json token contains a Json object
                ResponseObject := ResponseToken.AsObject(); //Convert json token into json object

                KNHImportFile.Reset();
                KNHImportFile.Init();
                KNHImportFile.ID := RecCount; //Use record count as table id
                foreach ResponseKey in ResponseObject.Keys() do begin //Loop for each field in json object
                    if ResponseKey = 'accesstoken' then //If field key = access token
                        KNHImportFile.AccessToken := CopyStr(ResponseValue.AsText(), 1, 100); //Transfer json value to record field 
                    if ResponseKey = 'expires_in' then //If field key = expires in
                        KNHImportFile.ExpiresIn := CopyStr(ResponseValue.AsText(), 1, 20); //Transfer json value to record field
                end;
                KNHImportFile.Insert();
                RecCount += 1
            end;

        if RecCount <> 0 then //Post reading of response display record count message
            Message(RecordsCountedMsg)
    end;
}
