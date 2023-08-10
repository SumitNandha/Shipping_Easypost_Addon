table 55020 "Agent Service Option"
{
    Caption = 'Agent Service Option';
    DataClassification = ToBeClassified;

    fields
    {
        field(1;"Packing No";Code[20])
        {
            Caption = 'Packing No';
            DataClassification = ToBeClassified;
        }
        field(2;"LineNo.";Integer)
        {
            Caption = 'LineNo.';
            DataClassification = ToBeClassified;
        }
        field(3;Agent;Text[50])
        {
            Caption = 'Agent';
            DataClassification = ToBeClassified;
        }
        field(4;"Agent Service";Text[50])
        {
            Caption = 'Agent Service';
            DataClassification = ToBeClassified;
        }
        field(5;Choose;Boolean)
        {
            // Caption = 'Include EasyPost Rates';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK;"Packing No", "LineNo.")
        {
            Clustered = true;
        }
    }
}
