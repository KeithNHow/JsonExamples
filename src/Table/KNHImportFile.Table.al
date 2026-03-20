///<summary>
/// This is a table that defines the structure of the data for imported files. It has three fields: ID, AccessToken, and ExpiresIn. The ID field is an auto-incrementing integer that serves as the primary key. The AccessToken field is a text field that can store up to 100 characters, and the ExpiresIn field is a text field that can store up to 20 characters. This table allows for storing information about imported files, such as access tokens and their expiration times.
///</summary>
namespace KNHJsonExamples;

table 51000 KNHImportFile
{
    Caption = 'Import File';
    DataClassification = CustomerContent;
    AllowInCustomizations = AsReadWrite;

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'ID';
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; AccessToken; Text[100])
        {
            Caption = 'Access Token';
            DataClassification = ToBeClassified;
        }
        field(3; ExpiresIn; Text[20])
        {
            Caption = 'Expires In';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}
