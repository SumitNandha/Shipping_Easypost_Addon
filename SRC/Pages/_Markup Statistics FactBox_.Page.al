page 55018 "Markup Statistics FactBox"
{
    Caption = 'Markup Statistics FactBox';
    PageType = ListPart;
    SourceTable = "Ship Package Header";
    RefreshOnActivate = true;
    Editable = false;

    layout
    {
        area(content)
        {
            group("Items Information")
            {
                field("total Gross Wt (All Items)"; Rec."total Gross Wt (All Items)")
                {
                    ApplicationArea = All;
                    Caption = 'Total Gross Wt (All Items) Lbs';
                }
                field("Total Quantity (Packs)"; Rec."total Quantity (Packs)")
                {
                    Caption = 'Total Quantity (Packs)';
                    ApplicationArea = All;
                }
            }
            group("Box / Pallet Information")
            {
                field(BoxCount; BoxCount)
                {
                    ApplicationArea = All;
                    Caption = 'No of Boxes';
                }
                field(PalletCount; PalletCount)
                {
                    ApplicationArea = All;
                    Caption = 'No of Pallets';
                }
            }
            group(Markups)
            {
                field("Box Markup value"; Rec."Box Markup value")
                {
                    ToolTip = 'Specifies the value of the Box Markup value field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Pallet Markup value"; Rec."Pallet Markup value")
                {
                    ToolTip = 'Specifies the value of the Pallet Markup value field.';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(General)
            {
                field("Markup value"; Rec."Markup value")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'MarkUp Cost';
                }
                field("Freight Value"; Rec."Freight Value")
                {
                    Caption = 'Carrier Base Shipping Cost';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Insurance Markup for Box"; Rec."Insurance Markup for Box")
                {
                    Caption = 'Box Insurance Markup';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Insurance Markup for Pallet"; Rec."Insurance Markup for Pallet")
                {
                    Caption = 'Pallet Insurance Markup';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Additional Mark Up"; Rec."Additional Mark Up")
                {
                    Caption = 'Additional Mark Up';
                    ApplicationArea = All;
                }
                field("Total Shipping Rate for Customer"; Rec."Total Shipping Rate for Customer")
                {
                    ApplicationArea = All;
                    Caption = 'Total Shipping Rate for Customer';
                }
                field("Existing Shipping Rate on SO/SQ"; Rec."Existing Shipping Rate on SO/SQ")
                {
                    ApplicationArea = All;
                }
                field(Difference; Rec.Difference)
                {
                    ApplicationArea = All;
                }
            }

        }
    }
    trigger OnAfterGetRecord()
    var
        SubPackingLines: Record "Sub Packing Lines";
        SHipPackageLines: Record "Ship Packing Lines";
    begin
        Clear(Rec."total Gross Wt (All Items)");
        Clear(Rec."total Quantity (Packs)");
        Clear(BoxCount);
        SubPackingLines.Reset();
        SubPackingLines.SetRange("Packing No.", Rec.No);
        SubPackingLines.SetRange("Packing Type", SubPackingLines."Packing Type"::Box);
        if SubPackingLines.FindSet() then BoxCount := SubPackingLines.Count;
        Clear(PalletCount);
        SubPackingLines.Reset();
        SubPackingLines.SetRange("Packing No.", Rec.No);
        SubPackingLines.SetRange("Packing Type", SubPackingLines."Packing Type"::Pallet);
        if SubPackingLines.FindSet() then PalletCount := SubPackingLines.Count;
        SHipPackageLines.Reset();
        SHipPackageLines.SetRange("No.", rec.No);
        if SHipPackageLines.FindSet() then begin
            repeat
                Rec."total Gross Wt (All Items)" += SHipPackageLines."Total Item Weight";
                Rec."total Quantity (Packs)" += SHipPackageLines.Quantity;
            until SHipPackageLines.Next() = 0;
        end;
    end;

    var
        BoxCount: Decimal;
        PalletCount: Decimal;
}
