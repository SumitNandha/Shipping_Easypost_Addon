page 55006 "Packing List"
{
    Caption = 'Packing List';
    PageType = List;
    SourceTable = "Packing LIST";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    MultipleNewLines = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(EntryNo;Rec.EntryNo)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("No.";Rec."No.")
                {
                    Caption = 'Packing No.';
                    ToolTip = 'Specifies the value of the No. field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
