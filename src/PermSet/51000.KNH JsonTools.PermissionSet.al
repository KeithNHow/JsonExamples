/// <summary>
/// Unknown KNH JsonTools (ID 51000). 
/// </summary>
permissionset 51000 "KNH JsonTools"
{
    Assignable = true;
    Caption = 'Json Tools', MaxLength = 30;
    Permissions =
        codeunit "KNH JsonTools" = X,
        codeunit "KNH API Sample Import" = X,
        tabledata "KNH API Sample" = RIMD,
        table "KNH API Sample" = X,
        page "KNH API Sample Import" = X,
        page "KNH IP Address" = X;
}