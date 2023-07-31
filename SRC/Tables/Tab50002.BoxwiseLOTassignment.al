table 55018 "Box wise LOT assignment"
{
    Caption = 'Box wise LOT assignment';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Serial No"; Integer)
        {
            Caption = 'Serial No';
            DataClassification = ToBeClassified;
        }
        field(2; "Packing No"; Code[20])
        {
            Caption = 'Packing No';
            DataClassification = ToBeClassified;
        }
        field(3; "Item No"; Code[20])
        {
            Caption = 'Item No';
            DataClassification = ToBeClassified;
        }
        field(4; "Lot No"; Code[50])
        {
            Caption = 'Lot No';
            DataClassification = ToBeClassified;
        }
        field(5; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
        }
        field(6; BoxID; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Report Serial No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Item Description"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No")));
        }
    }
    keys
    {
        key(PK; "Serial No", "Packing No")
        {
            Clustered = true;
        }
    }
}
