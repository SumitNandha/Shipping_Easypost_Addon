page 55001 "Pallet/Box Master List"
{
    ApplicationArea = All;
    Caption = 'Pallet/Box Master List';
    PageType = List;
    SourceTable = "Pallet/Box Master";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = All;
                }
                field("Pallet/Box "; Rec."Pallet/Box")
                {
                    ToolTip = 'Specifies the value of the Pallet/Box field';
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
                field("Weight of Pallet/BoX"; Rec."Weight of Pallet/BoX")
                {
                    ToolTip = 'Specifies the value of the Weight of Pallet/BoX field';
                    ApplicationArea = All;
                }
            }
        }
    }
}
