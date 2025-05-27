namespace JsonExamples;
using Microsoft.Purchases.Document;

pageextension 51000 "KNH Purchase Order List" extends "Purchase Order List"
{
    actions
    {
        addlast(Processing)
        {
            group(JsonExamples)
            {
                Caption = 'Transfers';
                Image = Transactions;

                action("Export Purchase Orders")
                {
                    ToolTip = 'This action is for exporting the purchase orders as Json.';
                    ApplicationArea = All;
                    Image = Export;
                    trigger OnAction()
                    var
                        ExportToJson: Codeunit "KNH Export To Json";
                    begin
                        ExportToJson.ExportPurchOrderToJsonFile(Rec);
                    end;
                }
                action("Import Purchase Orders")
                {
                    ToolTip = 'This action is for uploading the purchase order as Json.';
                    ApplicationArea = All;
                    Image = Import;
                    trigger OnAction()
                    var
                        ImportFromJson: Codeunit "KNH Import From Json";
                    begin
                        ImportFromJson.ImportPurchOrderFromJsonFile();
                    end;
                }
            }
        }
        addlast(Promoted)
        {
            group(JsonExamples_Promoted)
            {
                Caption = 'Transfers';
                actionref("Export_Promoted_Ref"; "Export Purchase Orders") { }
                actionref("Import_Promoted_Ref"; "Import Purchase Orders") { }
            }
        }
    }
}