permissionset 51000 "KNH Json Examples"
{
    Assignable = true;
    Caption = 'Json Tools', MaxLength = 30;
    Permissions =
        codeunit "KNH Json Management" = X,
        codeunit "KNH Json Sample Loop Import" = X,
        tabledata "KNH Sample API" = RIMD,
        table "KNH Sample API" = X,
        page "KNH Json Sample Import" = X,
        page "KNH Get IP Address" = X;
}