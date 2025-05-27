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
                Caption = 'Json Examples';
                Image = ExportFile;

                action("Export Purchase Orders")
                {
                    ToolTip = 'This action is for exporting the purchase orders as Json.';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = Export;
                    trigger OnAction()
                    var
                        ExportToJson: Codeunit "KNH Export To Json";
                    begin
                        ExportToJson.ExportPurchOrderAsJson(Rec);
                    end;
                }
                action("Import Purchase Orders")
                {
                    ToolTip = 'This action is for uploading the purchase order as Json.';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = Import;
                    trigger OnAction()
                    var
                        ImportFromJson: Codeunit "KNH Import From Json";
                    begin
                        ImportFromJson.ImportPurchaseOrderFromJsonFile();
                    end;
                }
            }
        }
    }
}