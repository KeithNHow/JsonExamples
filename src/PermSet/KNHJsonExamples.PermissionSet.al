permissionset 51000 "KNH Json Examples"
{
    Assignable = true;
    Caption = 'Json Tools', MaxLength = 30;
    Permissions =
        codeunit "KNH Json Management" = X,
        codeunit "KNH Json Loop Import" = X,
        tabledata "KNH Import File" = RIMD,
        table "KNH Import File" = X,
        page "KNH Import File" = X,
        page "KNH Get IP Address" = X;
}