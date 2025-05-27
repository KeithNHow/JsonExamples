namespace JsonExamples;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Comment;
using System.Utilities;

codeunit 51004 "KNH Export To Json"
{
    procedure ExportPurchOrderToJsonFile(PurchaseHeader: Record "Purchase Header")
    var
        Tempblob: Codeunit "Temp Blob";
        PurchOrderJsonObject: JsonObject;
        InStream: InStream;
        OutStream: OutStream;
        ExportFileName: Text;
    begin
        PurchOrderJsonObject.Add(PurchaseHeader.FieldCaption("No."), PurchaseHeader."No.");
        PurchOrderJsonObject.Add(PurchaseHeader.FieldCaption("Order Date"), PurchaseHeader."Order Date");
        PurchOrderJsonObject.Add(PurchaseHeader.FieldCaption("Buy-from Vendor No."), PurchaseHeader."Buy-from Vendor No.");
        PurchOrderJsonObject.Add('Lines', this.GetPurchLineArray(PurchaseHeader));
        Tempblob.CreateOutStream(OutStream); // Create an output stream to write the JSON data
        if PurchOrderJsonObject.WriteTo(OutStream) then begin // Write the JSON object to the output stream
            ExportFileName := 'PurchOrderExportFile' + PurchaseHeader."No." + '.json'; // Define the export file name
            Tempblob.CreateInStream(InStream); // Create an input stream from the output stream
            DownloadFromStream(InStream, '', '', '', ExportFileName) // Download the stream as a file
        end
    end;

    local procedure GetPurchLineArray(PurchaseHeader: Record "Purchase Header") PurchLineJsonArray: JsonArray
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                this.ExportPurchLines(PurchaseLine, PurchLineJsonArray)
            until PurchaseLine.Next() = 0
    end;

    local procedure ExportPurchLines(PurchaseLine: Record "Purchase Line"; PurchLineJsonArray: JsonArray)
    var
        PurchLineJsonObject: JsonObject;
    begin
        PurchLineJsonObject.Add(PurchaseLine.FieldCaption(Type), Format(PurchaseLine.Type));
        PurchLineJsonObject.Add(PurchaseLine.FieldCaption("No."), PurchaseLine."No.");
        PurchLineJsonObject.Add(PurchaseLine.FieldCaption(Quantity), PurchaseLine.Quantity);
        if this.PurchaseCommentExist(PurchaseLine) then
            PurchLineJsonObject.Add('Comment', this.GetPurchLineCommentArray(PurchaseLine));
        PurchLineJsonArray.Add(PurchLineJsonObject);
    end;

    local procedure GetPurchLineCommentArray(PurchaseLine: Record "Purchase Line") CommentLineArray: JsonArray
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        PurchCommentLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchCommentLine.SetRange("Document Line No.", PurchaseLine."Line No.");
        PurchCommentLine.SetRange("No.", PurchaseLine."Document No.");
        if PurchCommentLine.FindSet() then
            repeat
                this.ExportPurchaseLineComments(PurchCommentLine, CommentLineArray)
            until PurchCommentLine.Next() = 0
    end;

    local procedure ExportPurchaseLineComments(PurchCommentLine: Record "Purch. Comment Line"; CommentLineArray: JsonArray)
    var
        PurchCommentLineJsonObject: JsonObject;
    begin
        PurchCommentLineJsonObject.Add('Comment', PurchCommentLine.Comment);
        PurchCommentLineJsonObject.Add('Date', PurchCommentLine.Date);
        CommentLineArray.Add(PurchCommentLineJsonObject)
    end;

    local procedure PurchaseCommentExist(PurchaseLine: Record "Purchase Line"): Boolean
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        PurchCommentLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchCommentLine.SetRange("Document Line No.", PurchaseLine."Line No.");
        PurchCommentLine.SetRange("No.", PurchaseLine."Document No.");
        if not PurchCommentLine.IsEmpty then
            exit(true)
        else
            exit(false)
    end;
}