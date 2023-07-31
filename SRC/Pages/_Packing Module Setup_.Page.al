page 55000 "Packing Module Setup"
{
    Caption = 'Packing Module Setup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = all;
    SourceTable = "Packing Module Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Packing Nos"; Rec."Packing Nos")
                {
                    ToolTip = 'Specifies the value of the Packing Nos field';
                    ApplicationArea = All;
                }
                field("Shipping Cost Account No."; Rec."Shipping Cost Account No.")
                {
                    ToolTip = 'Specifies the value og Shipping Cost Account No.';
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "G/LAccount": Record "G/L Account";
                    begin
                        if Page.RunModal(Page::"G/L Account List", "G/LAccount") = Action::LookupOK then Rec.Validate("Shipping Cost Account No.", "G/LAccount"."No.");
                    end;
                }
                field("Combine Box Code"; Rec."Combine Box Code")
                {
                    ApplicationArea = All;
                }
                field("Estimated Shipping Cost Account No"; Rec."Estimated Shipping Cost Account No")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "G/LAccount": Record "G/L Account";
                    begin
                        if Page.RunModal(Page::"G/L Account List", "G/LAccount") = Action::LookupOK then Rec.Validate("Estimated Shipping Cost Account No", "G/LAccount"."No.");
                    end;
                }
                field("Packing Report Id"; Rec."Packing Report Id")
                {
                    ApplicationArea = All;
                    // trigger OnLookup(var Text: Text): Boolean
                    // var
                    //     RepSelectionLayout: Record "Report Layout Selection";
                    // begin
                    //     //     if page.RunModal(Page::"Report Layout Selection", RepSelectionLayout) = Action::LookupOK then
                    //     //         Rec.Validate("Packing Report Id", RepSelectionLayout."Report ID");
                    // end;
                }
            }
            group(EasyPost)
            {
                field("EasyPost API Key"; Rec."EasyPost API Key")
                {
                    ToolTip = 'Specifies the value of the EasyPost API Key field';
                    ApplicationArea = All;
                    Caption = 'EasyPost Test API Key';
                }
                field("EasyPost Live API Key"; Rec."EasyPost Live API Key")
                {
                    ToolTip = 'Specifies the value of the EasyPost API Key field';
                    ApplicationArea = All;
                    Caption = 'EasyPost Live API Key';
                }
                // field("EasyPost Password"; Rec."EasyPost Password")
                // {
                //     ToolTip = 'Specifies the value of the EasyPost Password field';
                //     ApplicationArea = All;
                // }
                field("EasyPost URL"; Rec."EasyPost URL")
                {
                    ToolTip = 'Specifies the value of the EasyPost URL field';
                    ApplicationArea = All;
                }
                // field("EasyPost User Name"; Rec."EasyPost User Name")
                // {
                //     ToolTip = 'Specifies the value of the EasyPost User Name field';
                //     ApplicationArea = All;
                // }
                field("Mode Test"; Rec."Mode Test")
                {
                    ApplicationArea = All;
                }
                field("Pounds to Ounces converter"; Rec."Pounds to Ounces converter")
                {
                    ApplicationArea = all;
                }
            }
            group(YRC)
            {
                field("YRC API Key"; Rec."YRC User Name")
                {
                    ToolTip = 'Specifies the value of the YRC API Key field';
                    ApplicationArea = All;
                }
                field("YRC URL"; Rec."YRC URL")
                {
                    ToolTip = 'Specifies the value of the YRC URL field';
                    ApplicationArea = All;
                }
                field("YRC API Password"; Rec."YRC API Password")
                {
                    ToolTip = 'Specifies the YRC API Password.';
                    ApplicationArea = All;
                }
                field("YRC BusID"; Rec."YRC BusID")
                {
                    ToolTip = 'Specifies the YRC BusID.';
                    ApplicationArea = All;
                }
            }
            group(RL)
            {
                field("RL API Key"; Rec."RL API Key")
                {
                    ToolTip = 'Specifies the value of the RL API Key field';
                    ApplicationArea = All;
                }
                field("RL URL"; Rec."RL URL")
                {
                    ToolTip = 'Specifies the value of the RL URL field';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            group("Shipping SetUp")
            {
                action("Pallet Box master Setup")
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Page.Run(Page::"Pallet/Box Master List");
                    end;
                }
                action("Shipping Markup Setup")
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Page.Run(Page::"Shipping MarkUp Setup");
                    end;
                }
                action("Email templates")
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Page.Run(Page::"Email Template List");
                    end;
                }
                action("Custom Freight")
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Page.Run(Page::"Custom Freight");
                    end;
                }
                action("Shipping Agent")
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Page.Run(Page::"Shipping Agents");
                    end;
                }
            }
        }
    }
}
