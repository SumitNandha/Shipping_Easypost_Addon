table 55016 "Box wise Lot History"
{
    Caption = 'Box wise Lot History';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Packing No"; Code[20])
        {
            Caption = 'Packing No';
            DataClassification = ToBeClassified;
        }
        field(2; "Box ID"; Code[20])
        {
            Caption = 'Box ID';
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
    }
    keys
    {
        key(PK; "Packing No", "Box ID")
        {
            Clustered = true;
        }
    }
}
