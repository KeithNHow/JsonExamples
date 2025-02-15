namespace JsonExamples;

table 51000 "KNH Sample API"
{
    Caption = 'KNH API Sample';
    DataClassification = CustomerContent;

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
