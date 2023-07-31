pageextension 55007 "SI Sales Shipment List Ext" extends "Posted Sales Shipments"
{
    layout
    {
        addafter("No.")
        {
            field("Inv. Pick No."; Rec."SI Inv. Pick No.")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
        addlast(Control1)
        {
            field("Send Tracking Email"; Rec."Send Tracking Email")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
    actions
    {
        addafter("&Shipment")
        {
            action("Ship Package Card")
            {
                ApplicationArea = All;
                Image = Card;
                Caption = 'Ship Package Card';

                trigger OnAction()
                var
                    shippackageheader: Record "Ship Package Header";
                begin
                    shippackageheader.Reset();
                    shippackageheader.SetRange("Inventory Pick", Rec."SI Inv. Pick No.");
                    if shippackageheader.FindFirst() then Page.Run(Page::"Posted Ship Package Header", shippackageheader);
                end;
            }
        }
    }
}
