codeunit 51001 "KNH Json Sample Loop Import"
{
    procedure GetAPIToken(Txtresponse: Text) //Receive response
    var
        KNHSampleAPI: Record "KNH Sample API";
        ResponseObject: JsonObject;
        ResponseValue: JsonValue;
        ResponseToken: JsonToken;
        ResponseKey: Text;
        RecCount: Integer;
        RecordsCountedMsg: Label 'Records imported = %1', Comment = '%1 = Record Count';
    begin
        KNHSampleAPI.Reset();
        if KNHSampleAPI.FindLast() then
            RecCount := KNHSampleAPI.ID + 1
        else
            RecCount := 1;
        if ResponseToken.ReadFrom(txtResponse) then //Read response into json token
            if ResponseToken.IsObject() then begin //Check json token contains a json object
                ResponseObject := ResponseToken.AsObject(); //Place json token in json object
                KNHSampleAPI.Reset();
                KNHSampleAPI.Init();
                KNHSampleAPI.ID := RecCount; //use record count as table id
                foreach ResponseKey in ResponseObject.Keys() do begin //Loop for each field in json object
                    if ResponseKey = 'accesstoken' then //If field key = access token
                        KNHSampleAPI.AccessToken := CopyStr(ResponseValue.AsText(), 1, 100); //Transfer json value to record field 
                    if ResponseKey = 'expires_in' then //If field key = expires in
                        KNHSampleAPI.ExpiresIn := CopyStr(ResponseValue.AsText(), 1, 20); //Transfer json value to record field
                end;
                KNHSampleAPI.Insert();
                RecCount += 1;
            end;
        if RecCount <> 0 then //Post reading of response display record count message
            Message(RecordsCountedMsg)
    end;
}
