pageextension 55008 "Packing_InventoryPicksEXT" extends "Inventory Picks"
{
    actions
    {
        addafter("P&ick")
        {
            action("Ship Package List")
            {
                ApplicationArea = All;
                Image = List;

                trigger OnAction()var ShipPackageHeader: Record "Ship Package Header";
                begin
                    ShipPackageHeader.Reset();
                    ShipPackageHeader.SetRange("Inventory Pick", Rec."No.");
                    if ShipPackageHeader.FindSet()then Page.RunModal(Page::"Ship Package List", ShipPackageHeader);
                end;
            }
        }
    }
}
