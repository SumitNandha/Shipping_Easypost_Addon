page 55015 "Item Packing Information"
{
    Caption = 'All Items Information';
    PageType = ListPart;
    SourceTable = "Pack In Lines";
    DeleteAllowed = false;
    InsertAllowed = false;

    // ModifyAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Packing No.";Rec."Packing No.")
                {
                    ToolTip = 'Specifies the value of the Packing No. field.';
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = SytleRed;
                    Visible = false;
                }
                field("Line No.";Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = SytleRed;
                    Visible = false;
                }
                // field("Box/Pallet ID"; Rec."Box/Pallet ID")
                // {
                //     ApplicationArea = All;
                //     Style = Attention;
                //     StyleExpr = SytleRed;
                //     Visible = false;
                // }
                field("Item No.";Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = SytleRed;
                    Editable = false;
                }
                field("Item Description";Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.';
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = SytleRed;
                    Editable = false;
                }
                field("Sales UoM";Rec."Sales UoM")
                {
                    ToolTip = 'Specifies the value of the Sales UoM field.';
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = SytleRed;
                    Editable = false;
                }
                field("Total Qty";Rec."Total Qty")
                {
                    ToolTip = 'Specifies the value of the Total Qty field.';
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = SytleRed;
                    Editable = false;
                }
                field("Qty Packed";Rec."Qty in this Box/Pallet")
                {
                    Caption = 'Qty Packed (All Boxes)';
                    ToolTip = 'Specifies the value of the Qty Packed field.';
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = SytleRed;
                    CaptionClass = QtyPackedCaption();
                    Editable = false;
                }
                field("Remaining Qty";Rec."Remaining Qty")
                {
                    ToolTip = 'Specifies the value of the Remaining Qty field.';
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = SytleRed;
                    Editable = false;
                }
                field("Qty to Add";Rec."Qty to Add")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = SytleRed;

                    trigger OnValidate()begin
                        if rec."Qty to Add" > Rec."Remaining Qty" then Rec.FieldError("Qty to Add", 'Qty cannot be added');
                    // Commit();
                    // CurrPage.Update(false);
                    end;
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
    local procedure "QtyPackedCaption"(): Text var QtyPackedInthisBox: label 'Qty Packed (All Boxes)';
    QtyPackedInthisPallet: label 'Qty Packed (All Pallets)';
    begin
        if Rec."Packing Type" = Rec."Packing Type"::Box then exit(QtyPackedInthisBox)
        else
            exit(QtyPackedInthisPallet)end;
    var[InDataSet]
    SytleRed: Boolean;
    [InDataSet]
    StyleTxt: Text;
}
