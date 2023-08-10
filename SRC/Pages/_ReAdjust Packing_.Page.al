page 55022 "ReAdjust Packing"
{
    Caption = 'Pack Items in Box';
    PageType = ListPart;
    SourceTable = "ReAdjust Packing";
    DeleteAllowed = false;
    InsertAllowed = false;

    // ModifyAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Packing ID"; Rec."Box ID")
                {
                    ToolTip = 'Specifies the value of the Packing ID field.';
                    ApplicationArea = All;
                    Caption = 'Box ID';
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sales UoM"; Rec."Sales UoM")
                {
                    ToolTip = 'Specifies the value of the Sales UoM field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Qty"; Rec."Total Qty")
                {
                    ToolTip = 'Specifies the value of the Total Qty field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty to pack in this Box"; Rec."Qty to pack in this Box")
                {
                    ToolTip = 'Specifies the value of the Qty to pack in this Box field.';
                    Caption = 'Qty in this Box';
                    ApplicationArea = All;
                }
                field("Insurance Price"; Rec."Insurance Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty to Remove"; Rec."Qty to Remove")
                {
                    ToolTip = 'Specifies the value of the Qty to Remove field.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                        if Rec."Qty to Remove" > Rec."Qty to pack in this Box" then rec.FieldError("Qty to Remove", 'Qty cannot be removed');
                    end;
                }
            }
        }
    }
}
