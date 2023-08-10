page 55000 "Packing Module Setup"
{
    Caption = 'Packing Module Setup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = all;
    InsertAllowed = false;
    DeleteAllowed = false;
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
                action("Box master Setup")
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Page.Run(Page::"Box Master List");
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
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
