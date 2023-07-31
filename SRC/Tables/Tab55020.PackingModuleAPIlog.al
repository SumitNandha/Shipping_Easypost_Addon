table 55020 "Packing Module API log"
{
    Caption = 'Packing Module API log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Packing No."; Code[20])
        {
            Caption = 'Packing No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Box/Pallet ID"; Code[20])
        {
            Caption = 'Box/Pallet ID';
            DataClassification = ToBeClassified;
        }
        field(4; Method; Text[20])
        {
            Caption = 'Method';
            DataClassification = ToBeClassified;
        }
        field(5; Request; Blob)
        {
            Caption = 'Request ';
            DataClassification = ToBeClassified;

        }
        field(6; Response; Blob)
        {
            Caption = 'Response';
            DataClassification = ToBeClassified;
        }
        field(7; "HTTP Status Code"; Integer)
        {
            Caption = 'HTTP Status Code';
            DataClassification = ToBeClassified;
        }
        field(8; "Date/Time"; DateTime)
        {
            Caption = 'Date/Time';
            DataClassification = ToBeClassified;
        }
        field(9; URL; Text[1000])
        {
            Caption = 'URL';
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
