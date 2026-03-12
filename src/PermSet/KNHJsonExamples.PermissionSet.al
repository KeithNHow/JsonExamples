permissionset 51000 KNHJsonExamples
{
    Assignable = true;
    Caption = 'Json Tools', MaxLength = 30;
    Permissions =
        codeunit KNHJsonManagement = X,
        codeunit KNHJsonLoopImport = X,
        tabledata KNHImportFile = RIMD,
        table KNHImportFile = X,
        page KNHImportFile = X,
        page KNHGetFact = X;
}