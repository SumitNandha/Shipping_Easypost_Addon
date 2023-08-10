table 55000 "Packing Module Setup"
{
    Caption = 'Packing Module Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary key"; Code[20])
        {
            Caption = 'Primary key';
            DataClassification = ToBeClassified;
        }
        field(2; "Packing Nos"; Code[20])
        {
            Caption = 'Packing Nos';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
        }
        field(3; "EasyPost URL"; Text[100])
        {
            Caption = 'EasyPost URL';
            DataClassification = ToBeClassified;
        }
        field(4; "EasyPost API Key"; Text[100])
        {
            Caption = 'EasyPost API Key';
            DataClassification = ToBeClassified;
        }
        field(11; "Tracking email Cust Souce"; Enum "Packing Module Tracking Mail")
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Shipping Cost Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Mode Test"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Combine Box Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Box Master";
        }
        field(18; "Estimated Shipping Cost Account No"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "EasyPost Live API Key"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Primary key")
        {
            Clustered = true;
        }
    }
}
