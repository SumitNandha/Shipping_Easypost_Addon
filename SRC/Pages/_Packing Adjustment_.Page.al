page 55014 "Packing Adjustment"
{
    Caption = 'Packing Adjustment';
    PageType = ListPlus;
    SourceTable = "Packing Adjustment";
    DeleteAllowed = false;
    InsertAllowed = false;

    // ModifyAllowed = false;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Box/Pallet ID";Rec."Box/Pallet ID")
                {
                    ToolTip = 'Specifies the value of the Packing ID field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Packing Type";Rec."Packing Type")
                {
                    ToolTip = 'Specifies the value of the Packing Type field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty Packed in this Box/Pallet";Rec."Qty Packed in this Box/Pallet")
                {
                    ToolTip = 'Specifies the value of the Qty Packed in this Box/Pallet field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Gross Ship Wt";Rec."Total Gross Ship Wt")
                {
                    ToolTip = 'Specifies the value of the Total Gross Ship Wt field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Box / Pallet Wt";rec."Box / Pallet Wt")
                {
                    ApplicationArea = All;
                    CaptionClass = GetCaptionID();
                    Editable = false;
                }
                field("Total Item Wt";Rec."Total Item Wt")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Additional Wt";Rec."Additional Wt")
                {
                    ApplicationArea = All;
                }
                field("Box Dimension";Rec."Box Dimension")
                {
                    ToolTip = 'Specifies the value of the Box Dimension field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(L;Rec.L)
                {
                    ApplicationArea = All;
                }
                field(H;Rec.H)
                {
                    ApplicationArea = All;
                }
                field(W;Rec.W)
                {
                    ApplicationArea = All;
                }
            }
            group("Re-Adjust")
            {
                part("Item Packing Information";"Item Packing Information")
                {
                    ApplicationArea = All;
                    SubPageLink = "Packing No."=field("Packing No"), "Packing Type"=field("Packing Type");
                    UpdatePropagation = Both;
                }
                part("Re-Adjust Packing";"ReAdjust Packing")
                {
                    ApplicationArea = All;
                    SubPageLink = "Packing No"=field("Packing No"), "Box/Pallet ID"=field("Box/Pallet ID"), "Packing Type"=field("Packing Type");
                    UpdatePropagation = Both;
                }
            }
        }
    }
    trigger OnOpenPage()var PackInLines: record "Pack In Lines";
    ReAdjustPacking: Record "ReAdjust Packing";
    GrossWt: Decimal;
    Item: Record Item;
    begin
        PackInLines.Reset();
        PackInLines.SetRange("Packing No.", Rec."Packing No");
        PackInLines.SetRange("Packing Type", Rec."Packing Type");
        if PackInLines.FindSet()then begin
            PackInLines.ModifyAll("Temp. Box Pallet ID", Rec."Box/Pallet ID");
        //   Message(PackInLines."Temp. Box Pallet ID");
        end;
        ReAdjustPacking.Reset();
        ReAdjustPacking.SetRange("Packing No", Rec."Packing No");
        ReAdjustPacking.SetRange("Packing Type", Rec."Packing Type");
        ReAdjustPacking.SetRange("Box/Pallet ID", Rec."Box/Pallet ID");
        if ReAdjustPacking.FindSet()then begin
            repeat Item.get(ReAdjustPacking."Item No.");
                GrossWt+=Item."Gross Weight" * ReAdjustPacking."Qty to pack in this Box";
            until ReAdjustPacking.Next() = 0;
            if Rec."Total Item Wt" = 0 then begin
                Rec.Validate("Total Item Wt", GrossWt);
                Rec.Modify();
            end;
        end;
    end;
    trigger OnClosePage()var PackInLines: Record "Pack In Lines";
    SubPackingLines: Page "Sub Packing Lines";
    begin
        PackInLines.Reset();
        PackInLines.SetRange("Packing No.", Rec."Packing No");
        PackInLines.SetRange("Packing Type", Rec."Packing Type");
        if PackInLines.FindSet()then begin
            PackInLines.ModifyAll("Temp. Box Pallet ID", '');
        end;
        SubPackingLines.Update(true);
    end;
    trigger OnAfterGetRecord()var PalletBoxMaster: Record "Pallet/Box Master";
    SubPackingLines: Record "Sub Packing Lines";
    ReadjustPacking: Record "ReAdjust Packing";
    begin
        SubPackingLines.Reset();
        SubPackingLines.SetRange("Packing No.", Rec."Packing No");
        SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
        SubPackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box/Pallet ID");
        if SubPackingLines.FindFirst()then begin
            PalletBoxMaster.Get(SubPackingLines."Box Code / Packing Type");
            Rec.Validate("Box / Pallet Wt", PalletBoxMaster."Weight of Pallet/BoX");
            Rec.Modify();
        end;
    end;
    local procedure GetCaptionID(): Text var BoxWt: Label 'Box Wt';
    PalletWt: Label 'Pallet Wt';
    begin
        if Rec."Packing Type" = Rec."Packing Type"::Box then exit(BoxWt)
        else
            exit(PalletWt)end;
}
