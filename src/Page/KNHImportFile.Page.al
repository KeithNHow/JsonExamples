// Actions (2) - Get API data, Get API Data 2 

namespace JsonExamples;

page 51000 KNHImportFile
{
    ApplicationArea = All;
    Caption = 'Imported Records';
    PageType = List;
    SourceTable = KNHImportFile;
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
            action(GetJsonDataFromWebsite)
            {
                ApplicationArea = All;
                Caption = 'Get Json Data From Website';
                Image = Web;
                ToolTip = 'Get json data from website.';

                trigger OnAction()
                var
                    KNHJsonLoopImport: Codeunit KNHJsonLoopImport;
                    WebClient: HttpClient;
                    WebHeaders: HttpHeaders;
                    HttpResponseMsg: HttpResponseMessage;
                    Response: Text;
                begin
                    WebHeaders := WebClient.DefaultRequestHeaders; //Gets request hdrs sent with each request
                    WebHeaders.Add('Username', '   '); //Adds spec header and its value 
                    WebHeaders.Add('Password', '   ');
                    WebHeaders.Add('Authorization', 'Auth2');
                    if WebClient.Get('URL', HttpResponseMsg) then begin //Sends request to get http response
                        HttpResponseMsg.Content.ReadAs(Response); //Gets content of http response
                        KNHJsonLoopImport.ImportRecords(Response); //Call codeunit
                    end;
                end;
            }
            action(GetJsonDataFromExternalFile)
            {
                ApplicationArea = All;
                Caption = 'Get Json Data From File';
                Image = Import;
                ToolTip = 'Import data from file containing json data.';

                trigger OnAction()
                var
                    MyInStream: InStream;
                    FromFilter: Text;
                    FromFolder: Text;
                    MyFile: Text;
                    MyText: Text;
                    Title: Text;
                begin
                    Title := 'Upload File into Stream';
                    UploadIntoStream(Title, FromFolder, FromFilter, MyFile, MyInStream);
                    MyInStream.ReadText(MyText);
                    Message(MyText);
                end;
            }
        }
        area(Promoted)
        {
            actionref(GetJsonDataFromWebsite_Ref; GetJsonDataFromWebsite) { }
            actionref(GetJsonDataFromExternalFile_Ref; GetJsonDataFromExternalFile) { }
        }
    }

}
