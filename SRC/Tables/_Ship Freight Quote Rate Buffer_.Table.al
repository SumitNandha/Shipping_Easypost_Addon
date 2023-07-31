table 55007 "Ship Freight Quote Rate Buffer"
{
    fields
    {
        field(1;"Carrier Name";Text[100])
        {
            Caption = 'Carrier Name';
        }
        field(2;"Service";text[100])
        {
            Caption = 'Service';
        }
        field(3;"Rate Price";Decimal)
        {
            Caption = 'Rate Price';
        }
        field(7;Currency;Code[20])
        {
            Caption = 'Currency';
        }
        field(4;"Delivery Days";Integer)
        {
            Caption = 'Delivery Days';
        }
        field(5;"Delivery Date";DateTime)
        {
            Caption = 'Delivery Date';
        }
        field(6;"Delivery Date Guaranteed";Boolean)
        {
            Caption = 'Delivery Date Guaranteed';
        }
    }
}
