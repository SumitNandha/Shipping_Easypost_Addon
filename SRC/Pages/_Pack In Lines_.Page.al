page 55011 "Pack In Lines"
{
    SourceTable = "Pack In Lines";
    ApplicationArea = All;
    UsageCategory = Lists;
    PageType = ListPart;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(general)
            {
                field("Packing No.";Rec."Packing No.")
                {
                    ApplicationArea = All;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Visible = false;
                }
                field("Line No.";Rec."Line No.")
                {
                    ApplicationArea = All;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Visible = false;
                }
                field("Packing Type";Rec."Packing Type")
                {
                    ApplicationArea = All;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Visible = false;
                }
                field("Item No.";Rec."Item No.")
                {
                    ApplicationArea = All;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Editable = false;
                }
                field("Item Description";Rec."Item Description")
                {
                    ApplicationArea = All;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Editable = false;
                }
                field("Sales UoM";Rec."Sales UoM")
                {
                    ApplicationArea = ALL;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Editable = false;
                }
                field("Gross Wt (Items)";Rec."Gross Wt (Items)")
                {
                    ApplicationArea = All;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Editable = false;
                }
                field("Total Qty";Rec."Total Qty")
                {
                    ApplicationArea = All;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Editable = false;
                }
                field("Qty Packed";Rec."Qty Packed")
                {
                    ApplicationArea = All;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Editable = false;
                }
                field("Remaining Qty";Rec."Remaining Qty")
                {
                    ApplicationArea = All;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Editable = false;
                }
                field("Box/Pallet Qty Packing Details";Rec."Box/Pallet Qty Packing Details")
                {
                    ApplicationArea = All;
                    StyleExpr = SytleRed;
                    Style = Attention;
                    Editable = false;
                }
            }
        }
    }
    trigger OnAfterGetRecord()var begin
        SytleRed:=false;
        if Rec."Remaining Qty" <> 0 then SytleRed:=True
        else
            SytleRed:=false;
        CurrPage.Update(false);
    end;
    trigger OnAfterGetCurrRecord()var begin
        SytleRed:=false;
        if Rec."Remaining Qty" <> 0 then SytleRed:=True
        else
            SytleRed:=false;
    end;
    var[InDataSet]
    SytleRed: Boolean;
    [InDataSet]
    StyleTxt: Text;
}
