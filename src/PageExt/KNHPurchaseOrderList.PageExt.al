namespace JsonExamples;
using Microsoft.Purchases.Document;

pageextension 51000 "KNH Purchase Order List" extends "Purchase Order List"
{
    actions
    {
        addfirst(processing)
        {
            action("Download Json")
            {
                ToolTip = 'This Action Download the Purchase order as JSon';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Export;
                trigger OnAction()
                var
                    ExportToJson: Codeunit "KNH Export To Json";
                begin
                    ExportToJson.ExportPurchaseOrderAsJson(Rec);
                end;
            }
            action("Upload Json")
            {
                ToolTip = 'This Action Upload the Purchase order as JSon';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Import;
                trigger OnAction()
                var
                    ImportFromJson: Codeunit "KNH Import From Json";
                begin
                    ImportFromJson.ImportPurchaseOrderFromJson();
                end;
            }
        }
    }
}