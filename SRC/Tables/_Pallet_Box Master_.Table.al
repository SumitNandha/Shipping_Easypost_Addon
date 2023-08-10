table 55002 "Box Master"
{
    Caption = 'Box Master';
    DataClassification = ToBeClassified;
    LookupPageId = "Box Master List";
    DrillDownPageId = "Box Master List";

    fields
    {
        field(1; Box; Code[20])
        {
            Caption = 'Box';
            DataClassification = ToBeClassified;
        }
        field(2; "No Series"; Code[20])
        {
            Caption = 'No Series';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
        }
        field(3; L; Decimal)
        {
            Caption = 'L';
            DataClassification = ToBeClassified;
        }
        field(4; W; Decimal)
        {
            Caption = 'W';
            DataClassification = ToBeClassified;
        }
        field(5; H; Decimal)
        {
            Caption = 'H';
            DataClassification = ToBeClassified;
        }
        field(6; "Weight of Box"; Decimal)
        {
            Caption = 'Weight of Box';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Box)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Box, H, L, W, "Weight of Box")
        {
        }
    }
}
