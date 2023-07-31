page 55013 "Pack In Box"
{
    Caption = 'Pack In Box';
    PageType = Card;
    SourceTable = "Pack In";
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Pack in Boxes?";Rec."Pack in Boxes?")
                {
                    ToolTip = 'Specifies the value of the Pack in Boxes? field.';
                    ApplicationArea = All;
                    Editable = RateEdit;
                }
                field("Suggest Packing";Rec."Suggest Packing")
                {
                    ToolTip = 'Specifies the value of the Suggest Packing field.';
                    ApplicationArea = All;
                    Editable = RateEdit;

                    trigger OnValidate()begin
                        if Rec."Suggest Packing" = true then begin
                            Rec."Pack All in 1 Box":=false;
                            Rec.Modify();
                        end;
                    end;
                }
                field("Pack All in 1 Box";Rec."Pack All in 1 Box")
                {
                    ToolTip = 'Specifies the value of the Pack All in 1 Box field.';
                    ApplicationArea = All;
                    Editable = RateEdit;

                    trigger OnValidate()begin
                        if Rec."Pack All in 1 Box" = true then begin
                            rec."Suggest Packing":=false;
                            Rec.Modify();
                        end;
                        CurrPage.Update();
                    end;
                }
                field("All in One Box Code";Rec."All in One Box Code")
                {
                    // Editable = true;
                    ApplicationArea = All;
                    Editable = RateEdit;
                }
                field("Close All Boxs";Rec."Close All Boxs")
                {
                    // Editable = true;
                    ApplicationArea = All;
                    Editable = closeboxedit;

                    trigger OnValidate()begin
                        if rec."Close All Boxs" = true then begin
                            CurrPage.Update(true);
                        end;
                        Closed();
                    end;
                }
            }
            part("Pack In";"Sub Packing Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Packing No."=field("Packing No."), "Packing Type"=filter(Box);
                // SubPageView = where("Packing Type" = filter(Box));
                UpdatePropagation = SubPart;
                Editable = RateEdit;
            }
            part("Pack In Box";"Pack In Lines")
            {
                ApplicationArea = All;
                Caption = 'Pack in Box';
                SubPageLink = "Packing No."=field("Packing No."), "Packing Type"=filter(Box);
                // SubPageView = where("Packing Type" = filter(Box));
                UpdatePropagation = SubPart;
                Editable = RateEdit;
            }
        }
    }
    //procedure "RatesEdit"()
    trigger OnOpenPage()var ShipPackageHeader: Record "Ship Package Header";
    begin
        RateEdit:=false;
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange(No, Rec."Packing No.");
        if ShipPackageHeader.FindFirst()then begin
            if(ShipPackageHeader.Carrier <> '') and (ShipPackageHeader.Service <> '')then begin
                RateEdit:=false;
                closeboxedit:=false;
            end
            else
            begin
                closeboxedit:=true;
                if Rec."Close All Boxs" = false then RateEdit:=true;
            end;
        end;
    end;
    procedure "Closed"()var Closed: Boolean;
    begin
        if Rec."Close All Boxs" = true then RateEdit:=false
        else
            RateEdit:=true;
    end;
    var PackInLines: Record "Pack In Lines";
    RateEdit: Boolean;
    closeboxedit: Boolean;
}
