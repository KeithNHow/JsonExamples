/// <summary>
/// Table KNH API Test (ID 51000).
/// </summary>
table 51000 "KNH API Test"
{
    Caption = 'KNH API Test';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; AccessToken; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; ExpiresIn; Text[20])
        {
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
