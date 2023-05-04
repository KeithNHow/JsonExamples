/// <summary>
/// Page KNH IP Address (ID 51001).
/// Pop field with IP Address by calling GetIP func
/// </summary>
page 51001 "KNH_IP_Address"
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
        JObject: JsonObject;
        Result: JsonToken;
        ResponseTxt: Text;
        Member: Text;
    begin
        if Client.Get('https:://api.ipify.org?format=json', Response) then //Get Response from path
            if Response.IsSuccessStatusCode() then begin
                Response.Content().ReadAs(ResponseTxt); //Gets the contents of http response into text object 
                JsObject.ReadFrom(ResponseTxt); //Reads text into json object
                if JObject.Get(Member, Result) then //Retrieves value using field key from json object and places in json token
                    exit(Result.AsValue().AsText()); //Converts the value in a json token into text object
            end;
    end;
}
