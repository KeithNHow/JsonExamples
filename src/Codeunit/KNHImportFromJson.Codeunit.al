codeunit 51002 "KNH Import From Json"
{
    procedure ImportPurchaseOrderFromJson()
    var
        InputToken: JsonToken;
    begin
        this.RequestFileFromUser(InputToken);
        this.ImportPurchOrder(InputToken);
    end;

    local procedure RequestFileFromUser(InputToken: JsonToken)
    var
        InputFilename: Text;
        InputInStream: InStream;
    begin
        if UploadIntoStream('Select File to Import', '', '*.*|*.json', InputFilename, InputInStream) then
            InputToken.ReadFrom(InputInStream);
    end;

    local procedure ImportPurchOrder(InputToken: JsonToken)
    var
        PurchaseHeader: Record "Purchase Header";
        OrderToken: JsonToken;
        OrderArrayToken: JsonToken;
        OrderObject: JsonObject;
    begin
        if not InputToken.IsObject then
            exit;

        OrderObject := InputToken.AsObject();

        if OrderObject.Contains('Orders') then
            OrderObject.Get('Orders', OrderToken);
        foreach OrderToken in OrderArrayToken.AsArray() do begin
            OrderObject := OrderToken.AsObject();
            Clear(PurchaseHeader);
            if this.GetPurchHeader(OrderObject, PurchaseHeader) then
                this.GetPurchLine(OrderObject, PurchaseHeader);
        end;
    end;

    local procedure GetPurchHeader(OrderObject: JsonObject; PurchaseHeader: Record "Purchase Header"): Boolean
    var
        OrderDate: Date;
        VendorNo: Code[20];
        ValueToken: JsonToken;
    begin
        if OrderObject.Get('Order Date', ValueToken) then
            OrderDate := ValueToken.AsValue().AsDate();
        if OrderObject.Get('Buy from Vendor No.', ValueToken) then
            VendorNo := CopyStr(ValueToken.AsValue().AsCode(), 1, 20);

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Insert(true);
        PurchaseHeader."Buy-from Vendor No." := VendorNo;
        PurchaseHeader."Order Date" := OrderDate;
        PurchaseHEader.Modify(true);
        exit(true);
    end;

    local procedure GetPurchLine(OrderObject: JsonObject; PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        LineArrayToken: JsonToken;
        LineToken: JsonToken;
        ValueToken: JsonToken;
        LineObject: JsonObject;
        OrderDate: Date;
        ItemNo: Code[20];
        LineQty: Decimal;
    begin
        if OrderObject.Contains('Lines') then
            if OrderObject.Get('Lines', LineArrayToken) then
                foreach Linetoken in LineArrayToken.AsArray() do begin
                    LineObject := LineToken.AsObject();
                    if OrderObject.Get('Order Date', ValueToken) then
                        OrderDate := ValueToken.AsValue().AsDate();
                    if OrderObject.Get('No.', ValueToken) then
                        ItemNo := CopyStr(ValueToken.AsValue().AsCode(), 1, 20);
                    if OrderObject.Get('Quantity', ValueToken) then
                        LineQty := ValueToken.AsValue().AsDecimal();
                end;

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

        if LineObject.Contains('comment') then
            this.GetPurchComments(LineObject, PurchaseLine);
    end;

    local procedure GetNextPurchLineNo(PurchaseHeader: Record "Purchase Header"): Integer
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindLast() then
            exit(PurchaseLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure GetPurchComments(LineObject: JsonObject; PurchaseLine: Record "Purchase Line")
    var
        PurchCommentLine: Record "Purch. Comment Line";
        LineCommentArrayToken: JsonToken;
        LineCommentObject: JsonObject;
        ValueToken: JsonToken;
        CommentText: Text[80];
        CommentDate: Date;
    begin
        if LineObject.Get('Comment', LineCommentArrayToken) then
            foreach LineCommentArrayToken in LineCommentArrayToken.AsArray() do begin
                LineCommentObject := LineCommentArrayToken.AsObject();
                if LineCommentObject.Get('Comment', ValueToken) then
                    CommentText := CopyStr(ValueToken.AsValue().AsText(), 1, 80);
                if LineCommentObject.Get('Date', ValueToken) then
                    CommentDate := ValueToken.AsValue().AsDate();

                PurchCommentLine.Init();
                PurchCommentLine."Document Type" := PurchCommentLine."Document Type"::Order;
                PurchCommentLine."No." := PurchaseLine."Document No.";
                PurchCommentLine."Line No." := PurchaseLine."Line No.";
                PurchCommentLine."Document Line No." := GetNextPurchCommentLineNo(PurchaseLine);
                PurchCommentLine.Insert(true);
                PurchCommentLine.Comment := CommentText;
                PurchCommentLine.Date := CommentDate;
                PurchCommentLine.Modify(true);
            end;
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
        exit(10000);
    end;
}
