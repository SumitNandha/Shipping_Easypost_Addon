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
        // field(5; "EasyPost User Name"; Text[100])
        // {
        //     Caption = 'EasyPost User Name';
        //     DataClassification = ToBeClassified;
        // }
        // field(6; "EasyPost Password"; Text[100])
        // {
        //     Caption = 'EasyPost Password';
        //     DataClassification = ToBeClassified;
        // }
        field(7; "YRC URL"; Text[100])
        {
            Caption = 'YRC URL';
            DataClassification = ToBeClassified;
        }
        field(8; "YRC User Name"; Text[100])
        {
            Caption = 'YRC User Name';
            DataClassification = ToBeClassified;
        }
        field(13; "YRC API Password"; Text[100])
        {
            Caption = 'YRC API Password';
            DataClassification = ToBeClassified;
        }
        field(14; "YRC BusID"; Text[100])
        {
            Caption = 'YRC BusID';
            DataClassification = ToBeClassified;
        }
        field(9; "RL URL"; Text[100])
        {
            Caption = 'RL URL';
            DataClassification = ToBeClassified;
        }
        field(10; "RL API Key"; Text[100])
        {
            Caption = 'RL API Key';
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
        field(16; "Pounds to Ounces converter"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Combine Box Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Pallet/Box Master";
        }
        field(18; "Estimated Shipping Cost Account No"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Packing Report Id"; Integer)
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Report Layout Selection";
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
