// Actions (2) - Get API data, Get API Data 2 

namespace JsonExamples;

page 51000 "KNH Import File"
{
    ApplicationArea = All;
    Caption = 'Imported Records';
    PageType = List;
    SourceTable = "KNH Import File";
    UsageCategory = Lists;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                    ToolTip = 'ID';
                }
                field(AccessToken; Rec.AccessToken)
                {
                    ApplicationArea = All;
                    Caption = 'Access Token';
                    ToolTip = 'Access Token';
                }
                field(ExpiresIn; Rec.ExpiresIn)
                {
                    ApplicationArea = All;
                    Caption = 'Expires In';
                    ToolTip = 'Expires In';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(GetAPIData)
            {
                ApplicationArea = All;
                Caption = 'Get Access Token';
                Image = Web;
                ToolTip = 'Get Access Token.';

                trigger OnAction()
                var
                    KNHSampleAPILoopImport: Codeunit "KNH Json Loop Import";
                    WebHeaders: HttpHeaders;
                    HttpResponseMsg: HttpResponseMessage;
                    WebClient: HttpClient;
                    Response: Text;
                begin
                    WebHeaders := WebClient.DefaultRequestHeaders; //Gets request hdrs sent with each request
                    WebHeaders.Add('Username', '   '); //Adds spec header and its value 
                    WebHeaders.Add('Password', '   ');
                    WebHeaders.Add('Authorization', 'Auth2');
                    if WebClient.Get('URL', HttpResponseMsg) then begin //Sends request to get http response
                        HttpResponseMsg.Content.ReadAs(Response); //Gets content of http response
                        KNHSampleAPILoopImport.GetAPIToken(Response); //Call codeunit
                    end;
                end;
            }
            action(ImportJsonData)
            {
                ApplicationArea = All;
                Caption = 'Import Records';
                Image = Import;
                ToolTip = 'Import data from external file.';

                trigger OnAction()
                var
                    InStr: InStream;
                    MyText: Text;
                    FromFolder: Text;
                begin
                    FromFolder := 'C:\Temp\ImportFile.json';
                    UploadIntoStream('Import', FromFolder, '', MyText, InStr);
                end;
            }
        }
    }
}
