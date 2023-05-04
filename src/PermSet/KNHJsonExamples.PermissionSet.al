/// <summary>
/// Unknown KNH Json Examples (ID 51000). 
/// </summary>
permissionset 51000 "KNH_JsonExamples"
{
    Assignable = true;
    Caption = 'Json Tools', MaxLength = 30;
    Permissions =
        codeunit "KNH_JsonTools" = X,
        codeunit "KNH_API_Sample_Loop_Import" = X,
        tabledata "KNH_API_Sample" = RIMD,
        table "KNH_API_Sample" = X,
        page "KNH_API_Sample_Import" = X,
        page "KNH_IP_Address" = X;
}