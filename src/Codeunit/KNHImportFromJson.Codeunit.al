namespace JsonExamples;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Comment;

// Instream to Token, Token to Object, Orders to Array, 
codeunit 51002 "KNH Import From Json"
{
    procedure ImportPurchOrderFromJsonFile()
    var
        InputJsonToken: JsonToken;
    begin
        this.RequestFileFromUser(InputJsonToken);
        this.ImportPurchOrder(InputJsonToken);
    end;

    local procedure RequestFileFromUser(InputJsonToken: JsonToken)
    var
        InputFilename: Text;
        InputInStream: InStream;
    begin
        if UploadIntoStream('Select File to Import', '', '*.*|*.json', InputFilename, InputInStream) then
            InputJsonToken.ReadFrom(InputInStream); // Read the JSON from the input stream
    end;

    local procedure ImportPurchOrder(InputJsonToken: JsonToken)
    var
        PurchaseHeader: Record "Purchase Header";
        OrderJsonToken: JsonToken; // Token to hold the order data
        OrderArrayJsonToken: JsonToken; // Token to hold the array of orders
        OrderJsonObject: JsonObject; //
    begin
        if InputJsonToken.IsObject then begin // if the input is a JSON object
            OrderJsonObject := InputJsonToken.AsObject(); // Get the JSON object from the input token
            if OrderJsonObject.Contains('Orders') then begin // Check if the JSON object contains 'Orders'
                OrderJsonObject.Get('Orders', OrderJsonToken); // Get the orders from the JSON object
                foreach OrderJsonToken in OrderArrayJsonToken.AsArray() do begin // Iterate through each order in the JSON array
                    OrderJsonObject := OrderJsonToken.AsObject(); // Convert the token to a JSON object
                    Clear(PurchaseHeader);
                    if this.CreatePurchHeader(OrderJsonObject, PurchaseHeader) then
                        this.CreatePurchLine(OrderJsonObject, PurchaseHeader)
                end
            end
        end else
            exit
    end;

    local procedure CreatePurchHeader(OrderObject: JsonObject; PurchaseHeader: Record "Purchase Header"): Boolean
    var
        OrderDate: Date;
        VendorNo: Code[20];
        ValueJsonToken: JsonToken;
    begin
        if OrderObject.Get('Order Date', ValueJsonToken) then // Check if the JSON object contains 'Order Date'
            OrderDate := ValueJsonToken.AsValue().AsDate(); // Get the order date from the JSON object
        if OrderObject.Get('Buy from Vendor No.', ValueJsonToken) then // Check if the JSON object contains 'Buy from Vendor No.'
            VendorNo := CopyStr(ValueJsonToken.AsValue().AsCode(), 1, 20); // Get the vendor number from the JSON object

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Insert(true);
        PurchaseHeader."Buy-from Vendor No." := VendorNo;
        PurchaseHeader."Order Date" := OrderDate;
        PurchaseHeader.Modify(true);
        exit(true)
    end;

    local procedure CreatePurchLine(OrderObject: JsonObject; PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        LineArrayToken: JsonToken;
        LineToken: JsonToken;
        ValueJsonToken: JsonToken;
        LineJsonObject: JsonObject;
        OrderDate: Date;
        ItemNo: Code[20];
        LineQty: Decimal;
    begin
        if not OrderObject.Contains('Lines') then // Check if the JSON object contains 'Lines'
            exit // Exit if 'Lines' is not present in the JSON object
        else
            if OrderObject.Get('Lines', LineArrayToken) then // Get the 'Lines' array from the JSON object
                foreach Linetoken in LineArrayToken.AsArray() do begin // Iterate through each line in the 'Lines' array
                    LineJsonObject := LineToken.AsObject(); // Convert the token to a JSON object
                    if OrderObject.Get('Order Date', ValueJsonToken) then // Check if the JSON object contains 'Order Date'
                        OrderDate := ValueJsonToken.AsValue().AsDate(); // Get the order date
                    if OrderObject.Get('No.', ValueJsonToken) then // Check if the JSON object contains 'No.'
                        ItemNo := CopyStr(ValueJsonToken.AsValue().AsCode(), 1, 20); // Get the item number from the JSON object
                    if OrderObject.Get('Quantity', ValueJsonToken) then // Check if the JSON object contains 'Quantity'
                        LineQty := ValueJsonToken.AsValue().AsDecimal(); // Get the line quantity from the JSON object

                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseLine."Document Type"::Order;
                    PurchaseLine."Document No." := PurchaseLine."Document No.";
                    PurchaseLine."Line No." := this.GetNextPurchLineNo(PurchaseHeader);
                    PurchaseLine.Insert(true);
                    PurchaseLine."Order Date" := OrderDate;
                    Purchaseline.Type := Purchaseline.Type::Item;
                    Purchaseline.Validate("No.", ItemNo);
                    Purchaseline.Validate(Quantity, LineQty);
                    PurchaseLine.Modify(true);

                    if LineJsonObject.Contains('comment') then // Check if the line object contains 'comment'
                        this.GetPurchComments(LineJsonObject, PurchaseLine) // Get the purchase comments from the line object
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
        LineCommentArrayJsonToken: JsonToken;
        LineCommentJsonObject: JsonObject;
        ValueJsonToken: JsonToken;
        CommentText: Text[80];
        CommentDate: Date;
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
                PurchCommentLine."Document Line No." := GetNextPurchCommentLineNo(PurchaseLine);
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
