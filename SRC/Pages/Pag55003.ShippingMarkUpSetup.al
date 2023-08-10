page 55003 "Shipping MarkUp Setup"
{
    Caption = 'Shipping MarkUp Setup';
    PageType = List;
    SourceTable = "Shipping MarkUp Setup";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            // group(General)
            // {
            repeater(general)
            {
                field("All Customer"; Rec."All Customer")
                {
                    ToolTip = 'Specifies the value of the All Customer field.';
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field.';
                    ApplicationArea = All;
                }
                field("Add Shipping Cost to Invoice"; Rec."Add Shipping Cost to Invoice")
                {
                    ApplicationArea = All;
                }
                field("MarkUp per Box"; Rec."MarkUp per Box")
                {
                    ToolTip = 'Specifies the value of the MarkUp per Box field';
                    ApplicationArea = All;
                }
                field("Box Shipping Insurance?"; Rec."Box Shipping Insurance?")
                {
                    ApplicationArea = All;
                }
                field("Box Shipping Insurace %"; rec."Box Shipping Insurace %")
                {
                    ApplicationArea = All;
                }
                field("Freight Shipping Insurance?"; Rec."Freight Shipping Insurance?")
                {
                    ApplicationArea = All;
                }
                field("Freight Shipping Insurace %"; Rec."Freight Shipping Insurace %")
                {
                    ApplicationArea = All;
                }
                field("Customer Shipping Carrier"; Rec."Customer Shipping Carrier")
                {
                    ApplicationArea = All;
                }
                field("Customer Shipping Carrier Account"; Rec."Customer Shipping Carrier Acc.")
                {
                    ApplicationArea = All;
                }
                field("Customer Shipping Carrier Zip"; Rec."Customer Shipping Carrier Zip")
                {
                    ApplicationArea = All;
                }
                field("Customer Ship. Carrier Country"; Rec."Customer Ship. Carrier Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Ship. Carrier Country field.';
                }
            }
            // }
        }
    }
}
