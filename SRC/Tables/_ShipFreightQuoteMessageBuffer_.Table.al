table 55008 "ShipFreightQuoteMessageBuffer"
{
    Caption = 'Ship Freight Quote Message Buffer';

    fields
    {
        field(4;ID;Integer)
        {
            Caption = 'ID';
        }
        field(1;Carrier;Text[100])
        {
            Caption = 'Carrier';
        }
        field(2;"Type";text[20])
        {
            Caption = 'Type';
        }
        field(3;Message;text[100])
        {
            Caption = 'Message';
        }
        field(5;Referance;text[100])
        {
            Caption = 'Referance';
        }
    }
    keys
    {
        key(PK;ID)
        {
            Clustered = true;
        }
    }
}
