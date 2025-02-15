namespace JsonExamples;

codeunit 51001 "KNH Json Loop Import"
{
    procedure GetAPIToken(Txtresponse: Text) //Receive response
    var
        KNHImportFile: Record "KNH Import File";
        ResponseObject: JsonObject;
        ResponseValue: JsonValue;
        ResponseToken: JsonToken;
        ResponseKey: Text;
        RecCount: Integer;
        RecordsCountedMsg: Label 'Records imported = %1', Comment = '%1 = Record Count';
    begin
        KNHImportFile.Reset();
        if KNHImportFile.FindLast() then
            RecCount := KNHImportFile.ID + 1
        else
            RecCount := 1;
        if ResponseToken.ReadFrom(txtResponse) then //Read response into json token
            if ResponseToken.IsObject() then begin //Check json token contains a json object
                ResponseObject := ResponseToken.AsObject(); //Place json token in json object
                KNHImportFile.Reset();
                KNHImportFile.Init();
                KNHImportFile.ID := RecCount; //use record count as table id
                foreach ResponseKey in ResponseObject.Keys() do begin //Loop for each field in json object
                    if ResponseKey = 'accesstoken' then //If field key = access token
                        KNHImportFile.AccessToken := CopyStr(ResponseValue.AsText(), 1, 100); //Transfer json value to record field 
                    if ResponseKey = 'expires_in' then //If field key = expires in
                        KNHImportFile.ExpiresIn := CopyStr(ResponseValue.AsText(), 1, 20); //Transfer json value to record field
                end;
                KNHImportFile.Insert();
                RecCount += 1;
            end;
        if RecCount <> 0 then //Post reading of response display record count message
            Message(RecordsCountedMsg)
    end;
}
