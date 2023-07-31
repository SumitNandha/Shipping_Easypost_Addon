page 55007 "Ship Package List"
{
    Caption = 'Ship Package List';
    PageType = List;
    SourceTable = "Ship Package Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = 75004;
    Editable = false;
    SourceTableView = where(Posted=filter(false));

    layout
    {
        area(content)
        {
            repeater(Details)
            {
                field(No;Rec.No)
                {
                    ApplicationArea = All;
                }
                field("Inventory Pick";Rec."Inventory Pick")
                {
                    Caption = 'Inventory Pick No';
                    ApplicationArea = All;
                }
                field("Document No.";Rec."Document No.")
                {
                    Caption = 'Document No.';
                    ApplicationArea = All;
                }
                field("Close All Boxs";Rec."Close All Boxs")
                {
                    ApplicationArea = All;
                    Caption = 'Close All Boxes';
                }
                field("Close All Pallets";Rec."Close All Pallets")
                {
                    Caption = 'Close All Pallets';
                    ApplicationArea = All;
                }
                field(Carrier;Rec.Carrier)
                {
                    Caption = 'Carrier';
                    ApplicationArea = All;
                }
                field(Service;Rec.Service)
                {
                    Caption = 'Service';
                    ApplicationArea = All;
                }
                field("Confirm Quote No";Rec."Confirm Quote No")
                {
                    Caption = 'Confirm Quote No';
                    ApplicationArea = All;
                }
                field("Tracking Code";Rec."Tracking Code")
                {
                    Caption = 'Tracking Code';
                    ApplicationArea = All;
                }
                field(Location;Rec.Location)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
