table 55001 "Pallet/Box Master"
{
    Caption = 'Pallet/Box Master';
    DataClassification = ToBeClassified;
    LookupPageId = "Pallet/Box Master List";
    DrillDownPageId = "Pallet/Box Master List";

    fields
    {
        field(1;"Pallet/Box";Code[20])
        {
            Caption = 'Pallet/Box';
            DataClassification = ToBeClassified;
        }
        field(10;"Type";Enum "Pallet/Box Enum")
        {
            DataClassification = ToBeClassified;
        }
        field(2;"No Series";Code[20])
        {
            Caption = 'No Series';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
        }
        field(3;L;Decimal)
        {
            Caption = 'L';
            DataClassification = ToBeClassified;
        }
        field(4;W;Decimal)
        {
            Caption = 'W';
            DataClassification = ToBeClassified;
        }
        field(5;H;Decimal)
        {
            Caption = 'H';
            DataClassification = ToBeClassified;
        }
        field(6;"Weight of Pallet/BoX";Decimal)
        {
            Caption = 'Weight of Pallet/Box';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK;"Pallet/Box")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown;Type, "Pallet/Box", H, L, W, "Weight of Pallet/BoX")
        {
        }
    }
}
