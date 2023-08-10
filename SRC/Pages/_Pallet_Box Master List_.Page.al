page 55002 "Box Master List"
{
    ApplicationArea = All;
    Caption = 'Box Master List';
    PageType = List;
    SourceTable = "Box Master";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Box "; Rec."Box")
                {
                    ToolTip = 'Specifies the value of the Box field';
                    ApplicationArea = All;
                }
                field("No Series"; Rec."No Series")
                {
                    ToolTip = 'Specifies the value of the No Series field';
                    ApplicationArea = All;
                }
                field(L; Rec.L)
                {
                    ToolTip = 'Specifies the value of the L field';
                    ApplicationArea = All;
                }
                field(W; Rec.W)
                {
                    ToolTip = 'Specifies the value of the W field';
                    ApplicationArea = All;
                }
                field(H; Rec.H)
                {
                    ToolTip = 'Specifies the value of the H field';
                    ApplicationArea = All;
                }
                field("Weight of BoX"; Rec."Weight of BoX")
                {
                    ToolTip = 'Specifies the value of the Weight of BoX field';
                    ApplicationArea = All;
                }
            }
        }
    }
}
