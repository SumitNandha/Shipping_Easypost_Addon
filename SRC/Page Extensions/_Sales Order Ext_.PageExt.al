pageextension 55006 "Sales Order Ext" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("SI Total Shipping Rate"; Rec."SI Total Shipping Rate")
            {
                ApplicationArea = ALL;
                Editable = false;
            }
        }
    }
    actions
    {
        addlast(processing)
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
            action("Create Ship Package Card")
            {
                ApplicationArea = All;
                Image = Create;

                trigger OnAction()
                var
                    ShipPackageHeader: Record "Ship Package Header";
                    ShipPackageHeader2: Record "Ship Package Header";
                    Noseries: Codeunit NoSeriesManagement;
                    packingModuleSetup: Record "Packing Module Setup";
                    shippackageheaderpage: Page "Ship Package Header";
                begin
                    ShipPackageHeader.Init();
                    packingModuleSetup.Get();
                    if ShipPackageHeader.No = '' then ShipPackageHeader.No := Noseries.GetNextNo(packingModuleSetup."Packing Nos", 0D, true);
                    ShipPackageHeader.Validate("Document No.", Rec."No.");
                    ShipPackageHeader.Insert();
                    ShipPackageHeader2.reset;
                    ShipPackageHeader2.SetRange(No, ShipPackageHeader.No);
                    if ShipPackageHeader2.FindFirst() then
                        Page.Run(Page::"Ship Package Header", ShipPackageHeader2);
                end;
            }
        }
    }
}
