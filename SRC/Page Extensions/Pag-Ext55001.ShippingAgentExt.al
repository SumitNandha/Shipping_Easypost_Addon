pageextension 55001 "Shipping Agent Ext" extends "Shipping Agents"
{
    layout
    {
        addlast(Control1)
        {
            field("Minimum Weight Threshold";Rec."Minimum Weight Threshold")
            {
                ToolTip = 'Specifies the value of the Minimum Weight Threshold field';
                ApplicationArea = All;
            }
            field("Get Rate Carrier";Rec."SI Get Rate Carrier")
            {
                Caption = 'EasyPost / Ship Package Carrier';
                ApplicationArea = All;
            }
            field("EasyPost CA Account";Rec."EasyPost CA Account")
            {
                Caption = 'EasyPost CA Account';
                ApplicationArea = All;
            }
            field("Include EasyPost Rates";Rec."Include EasyPost Rates")
            {
                ApplicationArea = All;
            }
            field("Packing Type";Rec."Packing Type")
            {
                ApplicationArea = All;
            }
            field("Make Carrier Base Price ZERO"; Rec."Make Carrier Base Price ZERO")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Make Carrier Base Price ZERO field.';
            }
        }
    }
}
