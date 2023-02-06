/// <summary>
/// Page KNH API Sample (ID 51000).
/// </summary>
page 51000 "KNH API Sample"
{
    ApplicationArea = All;
    Caption = 'KNH API Sample';
    PageType = List;
    SourceTable = "KNH API Sample";
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
                ToolTip = 'Get Access Token';

                trigger OnAction()
                var
                    KNHApiTest: Codeunit "KNH API Test";
                    WebHeaders: HttpHeaders;
                    HttpResponseMsg: HttpResponseMessage;
                    WebClient: HttpClient;
                    Response: Text;
                begin
                    WebHeaders := WebClient.DefaultRequestHeaders; //Gets request headers which should be sent with each request
                    WebHeaders.Add('Username', '   '); //Adds spec header and its value 
                    WebHeaders.Add('Password', '   ');
                    WebHeaders.Add('Authorization', 'Auth2');
                    if WebClient.Get('URL', HttpResponseMsg) then begin //Sends request to get http response
                        httpResponseMsg.Content.ReadAs(Response); //Gets content of http response
                        KNHApiTest.GetAPIToken(Response); //Call CU 
                    end;
                end;
            }
        }
    }
}
