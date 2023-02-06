/// <summary>
/// Page KNH IP Address (ID 51001).
/// </summary>
page 51001 "KNH IP Address"
{
    Caption = 'What is my IP Address';
    PageType = Card;
    Editable = false;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field(IP; GetIP())
            {
                ApplicationArea = All;
                Caption = 'Current IP Address of BC Server';
                ToolTip = 'Current IP Address of BC Server';
            }
        }
    }

    local procedure GetIP(): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        JsObject: JsonObject;
        ResponseTxt: Text;
    begin
        if Client.Get('https:://api.ipify.org?format=json', Response) then
            if Response.IsSuccessStatusCode() then begin
                Response.Content().ReadAs(ResponseTxt); //Gets the contents of the http response and reads it in text field
                JsObject.ReadFrom(ResponseTxt); //Read json data into json object
                exit(GetJsonTextField(JsObject, 'ip'));
            end;
    end;

    local procedure GetJsonTextfield(O: JsonObject; Member: Text): Text
    var
        Result: JsonToken;
    begin
        if O.Get(Member, Result) then //Retrieves the value of a property with a given key from a json object
            exit(Result.AsValue().AsText()); //Converts the value in a json token to a json value
    end;
}
