table 55017 "Box Scan History"
{
    Caption = 'Box Scan (Shipping)';

    fields
    {
        field(1; "Serial No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Serial No.';
        }
        field(2; "User Id"; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'User Id';
        }
        field(3; "Scan Date and Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Scan Date and Time';
        }
        field(4; "Box ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Box ID';
        }
        field(5; "Error If Any"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Error If Any';
        }
        field(6; "Scan Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Scan Date';
        }
        field(7; "Employee Code"; Code[1])
        {
            DataClassification = ToBeClassified;
            Caption = 'Employee Code';
        }
        field(8; "Employee Name"; text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Employee Name';
        }
    }

    keys
    {
        key(Key1; "Box ID", "Serial No.")
        {
            Clustered = true;
        }
    }


}