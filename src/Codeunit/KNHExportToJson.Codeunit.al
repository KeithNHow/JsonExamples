namespace JsonExamples;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Comment;
using System.Utilities;

codeunit 51004 "KNH Export To Json"
{
    procedure ExportPurchaseOrderAsJson(PurchaseHeader: Record "Purchase Header")
    var
        Tempblob: Codeunit "Temp Blob";
        PurchaseOrerJson: JsonObject;
        InStream: InStream;
        OutStream: OutStream;
        ExportFileName: Text;
    begin
        PurchaseOrerJson.Add(PurchaseHeader.FieldCaption("No."), PurchaseHeader."No.");
        PurchaseOrerJson.Add(PurchaseHeader.FieldCaption("Order Date"), PurchaseHeader."Order Date");
        PurchaseOrerJson.Add(PurchaseHeader.FieldCaption("Buy-from Vendor No."), PurchaseHeader."Buy-from Vendor No.");
        PurchaseOrerJson.Add('lines', this.GetPurchaseLineArray(PurchaseHeader));
        Tempblob.CreateOutStream(OutStream);
        if PurchaseOrerJson.WriteTo(OutStream) then begin
            ExportFileName := 'PurchaseOrder' + PurchaseHeader."No." + '.json';
            Tempblob.CreateInStream(InStream);
            DownloadFromStream(InStream, '', '', '', ExportFileName);
        end;
    end;

    local procedure GetPurchaseLineArray(PurchaseHeader: Record "Purchase Header") PurchaseLineArray: JsonArray
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                this.ExportPurchaseLines(PurchaseLine, PurchaseLineArray);
            until PurchaseLine.Next() = 0;
    end;

    local procedure ExportPurchaseLines(PurchaseLine: Record "Purchase Line"; PurchaseLineArray: JsonArray)
    var
        PurchaseLineJson: JsonObject;
    begin
        PurchaseLineJson.Add(PurchaseLine.FieldCaption(Type), FORMAT(PurchaseLine.Type));
        PurchaseLineJson.Add(PurchaseLine.FieldCaption("No."), PurchaseLine."No.");
        PurchaseLineJson.Add(PurchaseLine.FieldCaption(Quantity), PurchaseLine.Quantity);
        if this.PurchaseCommentExist(PurchaseLine) then
            PurchaseLineJson.Add('comment', this.GetPurchaseLineCommentArray(PurchaseLine));
        PurchaseLineArray.Add(PurchaseLineJson);
    end;

    local procedure GetPurchaseLineCommentArray(PurchaseLine: Record "Purchase Line") CommentLineArray: JsonArray
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        PurchCommentLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchCommentLine.SetRange("Document Line No.", PurchaseLine."Line No.");
        PurchCommentLine.SetRange("No.", PurchaseLine."Document No.");
        if PurchCommentLine.FindSet() then
            repeat
                this.ExportPurchaseLineComments(PurchCommentLine, CommentLineArray);
            until (PurchCommentLine.Next() = 0);
    end;

    local procedure ExportPurchaseLineComments(PurchCommentLine: Record "Purch. Comment Line"; CommentLineArray: JsonArray)
    var
        PurchCommentLineJson: JsonObject;
    begin
        PurchCommentLineJson.Add('comment', PurchCommentLine.Comment);
        PurchCommentLineJson.Add('date', PurchCommentLine.Date);
        CommentLineArray.Add(PurchCommentLineJson);
    end;

    local procedure PurchaseCommentExist(PurchaseLine: Record "Purchase Line"): Boolean
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        PurchCommentLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchCommentLine.SetRange("Document Line No.", PurchaseLine."Line No.");
        PurchCommentLine.SetRange("No.", PurchaseLine."Document No.");
        exit(not PurchCommentLine.IsEmpty);
    end;
}