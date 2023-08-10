pageextension 55009 "Inventory Pick" extends "Inventory Pick"
{
    actions
    {
        addlast(processing)
        {
            action("Ship Package Card")
            {
                ApplicationArea = All;
                Image = List;

                trigger OnAction()
                var
                    ShipPackageHeader: Record "Ship Package Header";
                begin
                    ShipPackageHeader.Reset();
                    ShipPackageHeader.SetRange("Inventory Pick", Rec."No.");
                    if ShipPackageHeader.FindSet() then Page.RunModal(Page::"Ship Package List", ShipPackageHeader);
                end;
            }
            action("Create Ship Package Card")
            {
                ApplicationArea = All;
                Image = CreateDocument;

                trigger OnAction()
                var
                    ShipPackageHeader: Record "Ship Package Header";
                    Noseries: Codeunit NoSeriesManagement;
                    packingModuleSetup: Record "Packing Module Setup";
                    shippackageheaderpage: Page "Ship Package Header";
                    ShipPackageHeader2: Record "Ship Package Header";
                    SIEvnetMgnt: Codeunit "SI Event Mgnt";
                begin
                    // SIEvnetMgnt.QtyValidationBeforeCreateShipPackage(Rec);//Phase 7 SN-02032023 +
                    ShipPackageHeader.Reset();
                    ShipPackageHeader.SetRange("Document No.", Rec."No.");
                    if not ShipPackageHeader.FindSet() then begin
                        ShipPackageHeader.Init();
                        packingModuleSetup.Get();
                        if ShipPackageHeader.No = '' then ShipPackageHeader.No := Noseries.GetNextNo(packingModuleSetup."Packing Nos", 0D, true);
                        ShipPackageHeader.Validate("Inventory Pick", Rec."No.");
                        ShipPackageHeader.Insert();
                        ShipPackageHeader2.Reset();
                        ShipPackageHeader2.SetRange(No, ShipPackageHeader.No);
                        if ShipPackageHeader2.FindFirst() then
                            Page.Run(Page::"Ship Package Header", ShipPackageHeader2);
                    end;
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
    begin

        if CompanyName = 'Paclantic Naturals LLC' then begin
            PaclanticCompany := true;
            BlossomCompany := false;
        end
        else
            if CompanyName = 'Blossom Group LLC' then begin
                BlossomCompany := true;
                PaclanticCompany := false;
            end
            else begin
                PaclanticCompany := true;
                BlossomCompany := true;
            end
    end;

    var
        PaclanticCompany: boolean;
        BlossomCompany: boolean;
}
