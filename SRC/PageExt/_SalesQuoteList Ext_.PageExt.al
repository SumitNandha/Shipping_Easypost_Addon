pageextension 55004 "SalesQuoteList Ext" extends "Sales Quotes"
{
    actions
    {
        addlast("&Quote")
        {
            // action("Ship Freight Quote")
            // {
            //     ApplicationArea = All;
            //     Image = Shipment;

            //     trigger OnAction()var SalesHeader: Record "Sales Header";
            //     begin
            //         SalesHeader.Reset();
            //         SalesHeader.SetRange("No.", Rec."No.");
            //         if SalesHeader.FindFirst()then begin
            //             Page.RunModal(Page::"Ship Freight Quote", SalesHeader)end;
            //     end;
            // }
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
