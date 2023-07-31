pageextension 55009 "Shipping Agent Services Ext" extends "Shipping Agent Services"
{
    layout
    {
        addlast(Control1)
        {
            field("Get Rate Service";Rec."SI Get Rate Service")
            {
                Caption = 'EasyPost / Ship Package Service';
                ApplicationArea = All;
            }
        }
    }
}
