page 55032 "Posted Pack In Box"
{
    Caption = 'Posted Pack In Box';
    PageType = Card;
    SourceTable = "Pack In";
    ApplicationArea = All;
    UsageCategory = Documents;
    Editable = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Pack in Boxes?"; Rec."Pack in Boxes?")
                {
                    ToolTip = 'Specifies the value of the Pack in Boxes? field.';
                    ApplicationArea = All;
                }
                field("Suggest Packing"; Rec."Suggest Packing")
                {
                    ToolTip = 'Specifies the value of the Suggest Packing field.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if Rec."Suggest Packing" = true then begin
                            Rec."Pack All in 1 Box" := false;
                            Rec.Modify();
                        end;
                    end;
                }
                field("Pack All in 1 Box"; Rec."Pack All in 1 Box")
                {
                    ToolTip = 'Specifies the value of the Pack All in 1 Box field.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if Rec."Pack All in 1 Box" = true then begin
                            rec."Suggest Packing" := false;
                            Rec.Modify();
                        end;
                        CurrPage.Update();
                    end;
                }
                field("All in One Box Code"; Rec."All in One Box Code")
                {
                    // Editable = true;
                    ApplicationArea = All;
                }
                field("Close All Boxs"; Rec."Close All Boxs")
                {
                    // Editable = true;
                    ApplicationArea = All;
                }
            }
            part("Pack In"; "Sub Packing Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Packing No." = field("Packing No.");
                // SubPageView = where("Packing Type" = filter(Box));
                UpdatePropagation = SubPart;
            }
            part("Pack In Box"; "Pack In Lines")
            {
                ApplicationArea = All;
                Caption = 'Pack in Box';
                SubPageLink = "Packing No." = field("Packing No.");
                // SubPageView = where("Packing Type" = filter(Box));
                UpdatePropagation = SubPart;
            }
        }
    }
}
