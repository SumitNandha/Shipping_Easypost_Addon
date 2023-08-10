pageextension 55011 "Posted Sales Shipment Ext" extends "Posted Sales Shipment"
{
    actions
    {
        addafter("&Navigate")
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
