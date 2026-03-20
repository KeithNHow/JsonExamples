///<summary>
/// This page 'Get Fact' demonstrates how to call a REST API and read the JSON response. 
/// The 'Get A Fact' procedure is called from the page layout. It calls an API that returns a random cat fact.
/// the 'Get A Villain' procedure calls an API that returns a list of dog breeds and counts them.
///</summary>
namespace KNHJsonExamples;

page 51001 KNHGetFact
{
    Caption = 'Get Fact';
    PageType = Card;
    Editable = false;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            field(Fact; this.GetAFact())
            {
                ApplicationArea = All;
                Caption = 'Fact';
                ToolTip = 'Display a Fact.';
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(GetVillain)
            {
                ApplicationArea = All;
                Caption = 'Get Villain';
                ToolTip = 'This action gets a villain from a book.';
                Image = Import;

                trigger OnAction()
                var
                    Counter: Integer;
                begin
                    Counter := this.GetAVillain();
                    Message(Format(Counter));
                end;
            }
        }
        area(Promoted)
        {
            actionref(GetVillain_Ref; GetVillain) { }
        }
    }

    local procedure GetAFact(): Text
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        JsonObject: JsonObject;
        Result: JsonToken;
        ResponseTxt: Text;
    begin
        if HttpClient.Get('https://catfact.ninja/fact', HttpResponseMessage) then //Get Response from path
            if HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content().ReadAs(ResponseTxt); //move content of http response into text variable 
                JsonObject.ReadFrom(ResponseTxt); //read text into json object
                if JsonObject.Get('fact', Result) then //copy JsonObject property into json token
                    exit(Result.AsValue().AsText()); //exit after converting json token into text
            end;
    end;

    local procedure GetAVillain(): Integer
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        Counter: Integer;
        BreedJsonObject: JsonObject;
        DogJsonObject: JsonObject;
        BreedJsonToken: JsonToken;
        DogJsonToken: JsonToken;
        Identity: Text;
        ResponseTxt: Text;
    begin
        Counter := 0;
        if HttpClient.Get('https://dogapi.dog/api/v2/breeds', HttpResponseMessage)
        and HttpResponseMessage.IsSuccessStatusCode() then begin
            HttpResponseMessage.Content().ReadAs(ResponseTxt); //move content of http response into text variable 
            DogJsonObject.ReadFrom(ResponseTxt); //read text into json object
            if DogJsonObject.Contains('data') and DogJsonObject.Get('data', DogJsonToken) then
                foreach DogJsonToken in DogJsonToken.AsArray() do begin //loop through json Objects 
                    Counter += 1;
                    BreedJsonObject := DogJsonToken.AsObject();
                    if BreedJsonObject.Get('id', BreedJsonToken) then
                        Identity := BreedJsonToken.AsValue().AsText();
                end;
            Message('Imported records: %1', Counter);
        end;
    end;
}
