page 55009 "LOT Assignment "
{
    ApplicationArea = All;
    Caption = 'LOT Assignment ';
    PageType = List;
    SourceTable = "Box wise LOT assignment";
    UsageCategory = Lists;
    Editable = false;
    DeleteAllowed = true;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Packing No"; Rec."Packing No")
                {
                    ToolTip = 'Specifies the value of the Packing No field.';
                    ApplicationArea = All;
                }
                field(BoxID; Rec.BoxID)
                {
                    ToolTip = 'Specifies the value of the BoxID field.';
                    ApplicationArea = All;
                }
                field("Item No"; Rec."Item No")
                {
                    ToolTip = 'Specifies the value of the Item No field.';
                    ApplicationArea = All;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.';
                    ApplicationArea = All;
                }
                field("Lot No"; Rec."Lot No")
                {
                    ToolTip = 'Specifies the value of the Lot No field.';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                    ApplicationArea = All;
                }
                field("Report Serial No"; Rec."Report Serial No")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    // actions
    // {
    //     area(Processing)
    //     {
    //         action("Delete")
    //         {
    //             ApplicationArea = All;
    //             trigger OnAction()
    //             begin
    //                 Rec.Delete(false);
    //             end;
    //         }
    //     }
    // }
}
