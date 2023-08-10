page 55029 "Agent Service Options"
{
    // Caption = 'Agent Service Options';
    Caption = 'Agent Service Options for Get Rates';
    PageType = ListPart;
    SourceTable = "Agent Service Option";
    // UsageCategory = Administration;
    // ApplicationArea = basic;


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
                    Visible = false;
                }
                field("LineNo."; Rec."LineNo.")
                {
                    ToolTip = 'Specifies the value of the LineNo. field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Agent; Rec.Agent)
                {
                    ToolTip = 'Specifies the value of the Agent field.';
                    ApplicationArea = All;
                }
                field("Agent Service"; Rec."Agent Service")
                {
                    ToolTip = 'Specifies the value of the Agent Service field.';
                    ApplicationArea = All;
                }
                field(Choose; Rec.Choose)
                {
                    ToolTip = 'Specifies the value of the Include EasyPost Rates field.';
                    Caption = 'Choose';
                    ApplicationArea = All;
                }
            }
        }
    }
}
