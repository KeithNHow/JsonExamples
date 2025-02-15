// Pop field with IP Address by calling GetIP func

namespace JsonExamples;

page 51001 "KNH Get IP Address"
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
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        JsObject: JsonObject;
        JObject: JsonObject;
        Result: JsonToken;
        ResponseTxt: Text;
        Member: Text;
    begin
        if HttpClient.Get('https:://api.ipify.org?format=json', HttpResponseMessage) then //Get Response from path
            if HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content().ReadAs(ResponseTxt); //move content of http response into text variable 
                JsObject.ReadFrom(ResponseTxt); //move text into json object
                if JObject.Get(Member, Result) then //move json object to json token
                    exit(Result.AsValue().AsText()); //exit after converting json token into text
            end;
    end;
}
