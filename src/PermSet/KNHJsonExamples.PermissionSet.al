permissionset 51000 KNHJsonExamples
{
    Assignable = true;
    Caption = 'Json Tools', MaxLength = 30;
    Permissions =
        tabledata KNHImportFile = RIMD,
        table KNHImportFile = X,
        page KNHImportFile = X,
        page KNHGetFact = X,
        codeunit KNHExportToJson = X,
        codeunit KNHImportFromJsonFile = X,
        codeunit KNHJsonLoopImport = X,
        codeunit KNHJsonManagement = X;
}