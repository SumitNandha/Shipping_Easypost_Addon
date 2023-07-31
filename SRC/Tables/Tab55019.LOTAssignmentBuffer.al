table 55019 "LOT Assignment Buffer"
{
    Caption = 'LOT Assignment Buffer';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(2; "LOT No."; Code[50])
        {
            Caption = 'LOT No.';
            DataClassification = ToBeClassified;
        }
        field(3; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
        }
        field(4; "Qty assigned to box"; Decimal)
        {
            Caption = 'Qty assigned to box';
            DataClassification = ToBeClassified;
        }
        field(5; "Remaining Qty"; Decimal)
        {
            Caption = 'Remaining Qty';
            DataClassification = ToBeClassified;
        }
        field(6; "Item No"; Code[20])
        {
            Caption = 'Item No';
            DataClassification = ToBeClassified;
        }
        field(7; Completed; Boolean)
        {
            Caption = 'Completed';
            DataClassification = ToBeClassified;
        }
        field(8; InvPickNo; Code[20])
        {
            Caption = 'InvPickNo';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
