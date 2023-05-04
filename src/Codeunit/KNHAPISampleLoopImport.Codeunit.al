/// <summary>
/// Codeunit KNH API Sample Loop Import (D 51001).
/// </summary>
codeunit 51001 "KNH_API_Sample_Loop_Import"
{
    /// <summary>
    /// GetAPIToken.
    /// </summary>
    /// <param name="txtresponse">Text.</param>
    procedure GetAPIToken(txtresponse: Text) //receive response
    var
        kNHAPISample: Record "KNH_API_Sample";
        jsObject: JsonObject;
        jsValue: JsonValue;
        jsToken: JsonToken;
        jsKey: Text;
        RecCount: Integer;
    begin
        kNHAPISample.Reset();
        if kNHAPISample.FindLast() then
            RecCount := kNHAPISample.ID + 1
        else
            RecCount := 1;
        if jsToken.ReadFrom(txtResponse) then //Read response into json token
            if jsToken.IsObject() then begin //Check json token contains a json object
                jsObject := jsToken.AsObject(); //Extract json object from json token
                kNHAPISample.Reset();
                kNHAPISample.Init();
                kNHAPISample.ID := RecCount;
                foreach jsKey in jsObject.Keys() do begin //loop for each field in json object
                    if jsKey = 'accesstoken' then //if field key = access token
                        kNHAPISample.AccessToken := CopyStr(jsValue.AsText(), 1, 100); //Get json value 
                    if jsKey = 'expires_in' then //if field key = expires in
                        kNHAPISample.ExpiresIn := CopyStr(jsValue.AsText(), 1, 20);
                end;
                kNHAPISample.Insert();
                RecCount += 1;
            end;
    end;
}
