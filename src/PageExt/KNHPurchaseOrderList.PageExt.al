/// <summary>
/// This is a page extension of the standard "Purchase Order List" page. It adds two actions to the processing group, one for exporting purchase orders as Json files and another for importing purchase orders from Json files. The export action calls a codeunit that handles the logic for exporting the purchase orders, while the import action calls a codeunit that handles the logic for importing the purchase orders. Additionally, both actions are also added to the promoted actions group for easier access.
/// </summary>
namespace KNHJsonExamples;
using Microsoft.Purchases.Document;

pageextension 51000 KNHPurchaseOrderList extends "Purchase Order List"
{
    actions
    {
        addlast(processing)
        {
            group(JsonExamples)
            {
                action("Export Purchase Orders")
                {
                    ToolTip = 'This action is for exporting the purchase orders as Json.';
                    ApplicationArea = All;
                    Image = Export;
                    trigger OnAction()
                    var
                        ExportToJson: Codeunit KNHExportToJson;
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
                        ImportFromJson: Codeunit KNHImportFromJsonFile;
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
                Image = Transactions;
                actionref(Export_Promoted_Ref; "Export Purchase Orders") { }
                actionref(Import_Promoted_Ref; "Import Purchase Orders") { }
            }
        }
    }
}