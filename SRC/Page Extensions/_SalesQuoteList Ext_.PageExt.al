pageextension 55005 "SalesQuoteList Ext" extends "Sales Quotes"
{
    actions
    {
        addlast("&Quote")
        {
            action("Ship Package List")
            {
                ApplicationArea = All;
                Image = List;

                trigger OnAction()
                var
                    ShipPackageHeader: Record "Ship Package Header";
                begin
                    ShipPackageHeader.Reset();
                    ShipPackageHeader.SetRange("Document No.", Rec."No.");
                    if ShipPackageHeader.FindSet() then;
                    Page.RunModal(Page::"Ship Package List", ShipPackageHeader);
                end;
            }
        }
    }
}
