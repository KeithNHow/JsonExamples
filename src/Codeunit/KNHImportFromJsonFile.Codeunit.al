///<summary>
///This codeunit demonstrates how to import purchase order data from a JSON file. It includes procedures to request a JSON file from the user, parse the JSON data, and create purchase orders and lines in the system based on the imported data. The code handles JSON objects and arrays, and it also includes error handling for missing or invalid data in the JSON file.
///</summary>
namespace KNHJsonExamples;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Comment;
using Microsoft.Purchases.Vendor;

// Instream to Token, Token to Object, Orders to Array, 
codeunit 51002 KNHImportFromJsonFile
{
    procedure ImportPurchOrderFromJsonFile()
    var
        ImportToken: JsonToken;
    begin
        this.RequestFileFromUser(ImportToken);
        this.ImportPurchOrder(ImportToken);
    end;

    local procedure RequestFileFromUser(ImportToken: JsonToken)
    var
        ImportInStream: InStream;
        ImportFilename: Text;
    begin
        if UploadIntoStream('Select File to Import', '', '*.*|*.json', ImportFilename, ImportInStream) then
            ImportToken.ReadFrom(ImportInStream); // Read the JSON data from the inport stream into a JSON token
    end;

    local procedure ImportPurchOrder(ImportToken: JsonToken)
    var
        PurchaseHeader: Record "Purchase Header";
        OrderObject: JsonObject;
        OrderArray: JsonArray;
        OrderToken: JsonToken;
    //OrderText: Text;
    begin
        if ImportToken.IsArray then begin // Check if the input token is an object    
            OrderArray := ImportToken.AsArray(); // Convert the token to a JSON array
            foreach OrderToken in OrderArray do begin // Loop through each order in the Order array
                OrderObject := OrderToken.AsObject(); // Convert the token to a JSON object
                Clear(PurchaseHeader);
                if this.CreatePurchHeader(OrderObject, PurchaseHeader) then
                    this.CreatePurchLine(OrderObject, PurchaseHeader);
            end;
        end;
    end;

    local procedure CreatePurchHeader(OrderObject: JsonObject; PurchaseHeader: Record "Purchase Header"): Boolean
    var
        Vendor: Record Vendor;
        VendorNo: Code[20];
        TextDate: Text;
        OrderDate: Date;
        ValueToken: JsonToken;
    begin
        if OrderObject.Get('Order Date', ValueToken) then begin// Check if the object contains 'Order Date'
            TextDate := ValueToken.AsValue().AsText(); // Get the order date as text from the object
            Evaluate(OrderDate, CopyStr(TextDate, 1, 2) + CopyStr(TextDate, 4, 2) + CopyStr(textDate, 7, 4)); // Convert the order date from text to date format
        end;

        if OrderObject.Get('Buy-from Vendor No.', ValueToken) then // Check if the object contains 'Buy from Vendor No.'
            VendorNo := CopyStr(ValueToken.AsValue().AsCode(), 1, 20); // Get the vendor number from the object

        PurchaseHeader.Init();
        PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        PurchaseHeader.Validate("Order Date", OrderDate);
        PurchaseHeader.Validate("Posting Date", OrderDate);
        PurchaseHeader.Validate("Document Date", OrderDate);
        Vendor.Get(VendorNo);
        PurchaseHeader.Validate("Payment Terms Code", Vendor."Payment Terms Code"); // Set default payment terms
        PurchaseHeader.Modify(true);
    end;

    local procedure CreatePurchLine(OrderObject: JsonObject; PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        ItemNo: Code[20];
        OrderDate: Date;
        TextDate: Text;
        LineQty: Decimal;
        LineObject: JsonObject;
        LineArrayToken: JsonToken;
        LineToken: JsonToken;
        ValueToken: JsonToken;
    begin
        if not OrderObject.Contains('Lines') then // Check if the JSON object contains 'Lines'
            exit // Exit if 'Lines' is not present in the JSON object
        else
            if OrderObject.Get('Lines', LineArrayToken) then // Get the 'Lines' array from the JSON object
                foreach LineToken in LineArrayToken.AsArray() do begin // Iterate through each line in the 'Lines' array
                    LineObject := LineToken.AsObject(); // Convert the token to a JSON object
                    if OrderObject.Get('Order Date', ValueToken) then begin// Check if the JSON object contains 'Order Date'
                        TextDate := ValueToken.AsValue().AsText();
                        Evaluate(OrderDate, CopyStr(TextDate, 1, 2) + CopyStr(TextDate, 4, 2) + CopyStr(textDate, 7, 4)); // Get the order date
                    end;
                    if OrderObject.Get('No.', ValueToken) then // Check if the JSON object contains 'No.'
                        ItemNo := CopyStr(ValueToken.AsValue().AsCode(), 1, 20); // Get the item number from the JSON object
                    if OrderObject.Get('Quantity', ValueToken) then // Check if the JSON object contains 'Quantity'
                        LineQty := ValueToken.AsValue().AsDecimal(); // Get the line quantity from the JSON object

                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseLine."Document Type"::Order;
                    PurchaseLine."Document No." := PurchaseLine."Document No.";
                    PurchaseLine."Line No." := this.GetNextPurchLineNo(PurchaseHeader);
                    PurchaseLine.Insert(true);
                    PurchaseLine."Order Date" := OrderDate;
                    PurchaseLine.Type := PurchaseLine.Type::Item;
                    PurchaseLine.Validate("No.", ItemNo);
                    PurchaseLine.Validate(Quantity, LineQty);
                    PurchaseLine.Modify(true);

                    if LineObject.Contains('comment') then // Check if the line object contains 'comment'
                        this.GetPurchComments(LineObject, PurchaseLine) // Get the purchase comments from the line object
                end
    end;

    local procedure GetNextPurchLineNo(PurchaseHeader: Record "Purchase Header"): Integer
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindLast() then
            exit(PurchaseLine."Line No." + 10000);
        exit(10000)
    end;

    local procedure GetPurchComments(LineJsonObject: JsonObject; PurchaseLine: Record "Purchase Line")
    var
        PurchCommentLine: Record "Purch. Comment Line";
        CommentDate: Date;
        LineCommentJsonObject: JsonObject;
        LineCommentArrayJsonToken: JsonToken;
        ValueJsonToken: JsonToken;
        CommentText: Text[80];
    begin
        if LineJsonObject.Get('Comment', LineCommentArrayJsonToken) then // Check if the line object contains 'Comment'
            foreach LineCommentArrayJsonToken in LineCommentArrayJsonToken.AsArray() do begin // Iterate through each comment in the 'Comment' array
                LineCommentJsonObject := LineCommentArrayJsonToken.AsObject(); // Convert the token to a JSON object
                if LineCommentJsonObject.Get('Comment', ValueJsonToken) then // Check if the comment object contains 'Comment'
                    CommentText := CopyStr(ValueJsonToken.AsValue().AsText(), 1, 80); // Get the comment text from the JSON object
                if LineCommentJsonObject.Get('Date', ValueJsonToken) then // Check if the comment object contains 'Date'
                    CommentDate := ValueJsonToken.AsValue().AsDate(); // Get the comment date from the JSON object

                PurchCommentLine.Init();
                PurchCommentLine."Document Type" := PurchCommentLine."Document Type"::Order;
                PurchCommentLine."No." := PurchaseLine."Document No.";
                PurchCommentLine."Line No." := PurchaseLine."Line No.";
                PurchCommentLine."Document Line No." := this.GetNextPurchCommentLineNo(PurchaseLine);
                PurchCommentLine.Insert(true);
                PurchCommentLine.Comment := CommentText;
                PurchCommentLine.Date := CommentDate;
                PurchCommentLine.Modify(true)
            end
    end;

    local procedure GetNextPurchCommentLineNo(PurchaseLine: Record "Purchase Line"): Integer
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        PurchCommentLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchCommentLine.SetRange("Document Line No.", PurchaseLine."Line No.");
        PurchCommentLine.SetRange("No.", PurchaseLine."Document No.");
        if PurchCommentLine.FindLast() then
            exit(PurchCommentLine."Line No." + 10000);
        exit(10000)
    end;
}
