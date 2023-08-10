pageextension 55012 "Posted Sales Shipment - Update" extends "Posted Sales Shipment - Update"
{
    layout
    {
        addafter("Package Tracking No.")
        {
            field("Ship package tracking No"; Rec."Ship package tracking No")
            {
                ApplicationArea = All;
                Editable = true;
            }
        }
    }
}
