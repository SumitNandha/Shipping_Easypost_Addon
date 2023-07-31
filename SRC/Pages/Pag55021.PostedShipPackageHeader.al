page 55021 "Posted Ship Package Header"
{
    Caption = 'Posted Ship Package Header';
    PageType = Card;
    SourceTable = "Ship Package Header";
    Editable = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(Details)
            {
                field(No; Rec.No)
                {
                    ApplicationArea = All;
                    //  Visible = false;
                    Editable = false;
                }
                field("Inventory Pick"; Rec."Inventory Pick")
                {
                    Caption = 'Inventory Pick No';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    Caption = 'Document No.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Location; Rec.Location)
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Location: Record Location;
                    begin
                        if Page.RunModal(Page::"Location List", Location) = Action::LookupOK then Rec.Validate(Location, Location.Code);
                    end;
                }
                field("Close All Boxs"; Rec."Close All Boxs")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Close All Pallets"; Rec."Close All Pallets")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Pickup Date"; Rec."PickUp Date")
                {
                    ApplicationArea = All;
                }
                field("Total Packages"; Rec."Total Packages")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("COD Amount"; Rec."COD Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Service Option"; Rec."Service Option")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("NMFC Class"; Rec."NMFC Class")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Class; Rec.Class)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("YRC Discount Percentage"; Rec."YRC Discount Percentage")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Markup value"; Rec."Markup value")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'MarkUp Cost';
                    Visible = false;
                }
                field("Freight Value"; Rec."Freight Value")
                {
                    Caption = 'Carrier Base Shipping Cost';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Additional Mark Up"; Rec."Additional Mark Up")
                {
                    Caption = 'Additional Mark Up';
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                    begin
                        CurrPage.MarkupStatistics.Page.Activate(true);
                    end;
                }
                field("Total Shipping Rate for Customer"; Rec."Total Shipping Rate for Customer")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Existing Shipping Rate on SO/SQ"; Rec."Existing Shipping Rate on SO/SQ")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Difference; Rec.Difference)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Carrier; Rec.Carrier)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Service; Rec.Service)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Confirm Quote No"; Rec."Confirm Quote No")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tracking Code"; Rec."Tracking Code")
                {
                    ApplicationArea = All;
                }
                field(Posted; Rec.Posted)
                {
                    Caption = 'Posted';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer PO No"; Rec."Customer PO No")
                {
                    ApplicationArea = All;
                }
                field("Web Order No"; Rec."Web Order No")
                {
                    ApplicationArea = All;
                }
                field("Shipment Refund Status"; Rec."Shipment Refund Status")
                {
                    ApplicationArea = All;
                }
                field(Agent; Rec.Agent)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Agent Service"; Rec."Agent Service")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Work Description"; Rec."Work Description")
                {
                    ApplicationArea = All;
                    Editable = true;
                    MultiLine = true;
                }
                field(Insurance; Rec.Insurance)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shipping rate for Customer"; Rec."Shipping rate for Customer")
                {
                    ApplicationArea = All;
                    Visible = true;
                    Caption = 'Add Shipping cost to invoice';
                }
            }
            group("Bill-to")
            {
                Visible = false;

                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Name 2"; Rec."Bill-to Name 2")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Address"; Rec."Bill-to Address")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Address 2"; Rec."Bill-to Address 2")
                {
                    ApplicationArea = All;
                }
                field("Bill-to City"; Rec."Bill-to City")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Contact"; Rec."Bill-to Contact")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Post Code"; Rec."Bill-to Post Code")
                {
                    ApplicationArea = All;
                }
                field("Bill-to County"; Rec."Bill-to County")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                {
                    ApplicationArea = All;
                }
            }
            group("Ship-to")
            {
                field("Ship-to Company"; rec."Ship-to Company")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Customer No."; Rec."Ship-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Name 2"; Rec."Ship-to Name 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to County"; Rec."Ship-to County")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Contact No."; Rec."Ship-to Contact No.")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Email"; Rec."Ship-to Email")
                {
                    ApplicationArea = All;
                }
                field("Zip Message"; Rec."Zip Message")
                {
                    ApplicationArea = All;
                    StyleExpr = VerifyMsg;
                    Editable = false;
                }
                field("Delivery Message"; Rec."Delivery Message")
                {
                    ApplicationArea = All;
                    StyleExpr = VerifyMsg;
                    Editable = false;
                }
                field("Suggested Address"; Rec."Suggested Address")
                {
                    ApplicationArea = All;
                    Caption = 'Suggested Address';
                    Editable = false;
                }
                field("Update Suggested Addr"; Rec."Update Suggested Addr")
                {
                    ApplicationArea = All;
                    Caption = 'Update Suggested Address';
                }
                field(Residential; Rec.Residential)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part("Ship Package Lines"; "Ship Package Lines")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No");
                UpdatePropagation = Both;
                Editable = false;
            }
            part("Tracker"; "tracker List")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field(No);
                UpdatePropagation = Both;
                SubPageView = sorting("Tracking Code");
                Visible = false;
                Editable = false;
            }
            part("Combine Rate Information"; "Combine Rate Information")
            {
                ApplicationArea = All;
                SubPageLink = "Packing No." = field(No);
                UpdatePropagation = SubPart;
                Editable = false;
            }
            part("Buy Shipment"; "Detailed Rates List")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field(No);
                UpdatePropagation = SubPart;
                editable = false;
            }
        }
        area(FactBoxes)
        {
            part(MarkupStatistics; "Markup Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = No = FIELD(No);
                UpdatePropagation = SubPart;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Pack In Box")
            {
                ApplicationArea = All;
                Image = Allocate;

                trigger OnAction()
                var
                    PackIn: Record "Pack In";
                    PackiInBox: Page "Pack In Box";
                begin
                    PackIn.Reset();
                    PackIn.SetRange("Packing No.", Rec.No);
                    Packin.SetRange("Packing Type", Packin."Packing Type"::Box);
                    if PackIn.FindSet() then begin
                        Page.Run(Page::"Posted Pack In Box", PackIn);
                    end;
                END;
            }
            action("Pack In Pallet")
            {
                ApplicationArea = All;
                Image = Allocate;

                trigger OnAction()
                var
                    PackIn: Record "Pack In";
                    PackiInPallet: Page "Pack In Pallet";
                begin
                    PackIn.Reset();
                    PackIn.SetRange("Packing No.", Rec.No);
                    Packin.SetRange("Packing Type", Packin."Packing Type"::Pallet);
                    if PackIn.FindSet() then begin
                        Page.Run(Page::"Posted Pack in Pallets", PackIn);
                    end;
                end;
            }
            action("Label Print")
            {
                ApplicationArea = All;
                Image = Picture;

                trigger OnAction()
                var
                    LabelPrint: Report "Label Print -Other";
                    shippackageheader: Record "Ship Package Header";
                begin
                    shippackageheader.Reset();
                    shippackageheader.SetRange(No, Rec.No);
                    if shippackageheader.FindFirst() then;
                    if CopyStr(shippackageheader.Carrier,1,3) <> 'UPS' then
                        Report.Run(Report::"Label Print -Other", true, false, shippackageheader)
                    else
                        Report.Run(report::"Label Print - UPS", true, false, shippackageheader);
                end;
            }
            action("Pick and Pack Report")
            {
                ApplicationArea = All;
                Caption = 'Pick and Pack Report';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Report;

                trigger OnAction()
                var
                    PackAndPickReport: Report "Pick and Pack Report";
                    ShipPackageHeader: Record "Ship Package Header";
                begin
                    ShipPackageHeader.Reset();
                    ShipPackageHeader.SetRange(No, Rec.No);
                    if ShipPackageHeader.FindFirst() then Report.Run(Report::"Pick and Pack Report", true, false, ShipPackageHeader);
                end;
            }
            action("Shipping Delivery Note")
            {
                ApplicationArea = all;
                Image = Report;
                Caption = 'Shipping Delivery Note';
                Visible = PaclanticCompany;

                trigger OnAction()
                var
                    SalesShipmentHeader: Record "Sales Shipment Header";
                begin
                    SalesShipmentHeader.Reset();
                    SalesShipmentHeader.SetRange("SI Inv. Pick No.", Rec."Inventory Pick");
                    if SalesShipmentHeader.FindFirst() then
                        Report.RunModal(Report::"Shipping Delivery Note", true, false, SalesShipmentHeader)
                end;
            }
            action("Shipping Packing List")
            {
                ApplicationArea = all;
                Image = Report;
                Caption = 'Shipping Packing List';
                Visible = BlossomCompany;

                trigger OnAction()
                var
                    SalesShipmentHeader: Record "Sales Shipment Header";
                begin
                    SalesShipmentHeader.Reset();
                    SalesShipmentHeader.SetRange("SI Inv. Pick No.", Rec."Inventory Pick");
                    if SalesShipmentHeader.FindFirst() then
                        Report.RunModal(75006, true, false, SalesShipmentHeader)
                end;
            }
            action("E-mail")
            {
                ApplicationArea = all;
                Visible = false;

                trigger OnAction()
                var
                    EmailItem: Record "Email Item";
                    EasyPostBody: Text;
                    EmailTemplate: Record "Email Templates";
                    MailManagement: Codeunit "Mail Management";
                    EmailScenario: Enum "Email Scenario";
                    PO: Label 'PO#';
                    SO: Label 'SO#';
                    Dispatch: Label 'Dispatch#';
                    EmailTemplateLines: Record "Email Template Lines";
                    Customer: Record Customer;
                    CombineRateInfo: Record "Combine Rate Information";
                    ShipPackageHeader: Record "Ship Package Header";
                    TemplateLineFieldSelection: code[50];
                    myrecordref: RecordRef;
                    myfieldref: FieldRef;
                    PackingNoref: Code[20];
                    SubPackignLines: Record "Sub Packing Lines";
                    ShipAgent: Record "Shipping Agent";
                    EmailMngmt: Codeunit "Email Management";
                begin
                    // CombineRateInfo.Reset();
                    // CombineRateInfo.SetRange("Packing No.", Rec.No);
                    // CombineRateInfo.SetRange("Buy Service", true);
                    // if CombineRateInfo.FindFirst() then begin
                    //     if (CombineRateInfo.Carrier <> 'YRC') AND (CombineRateInfo.Carrier <> 'RL Carrier') and (CombineRateInfo.Carrier <> 'Custom Freight') and (CombineRateInfo.Carrier <> 'Customer PickUp') then begin
                    //         EmailMngmt.EmailDraft(Rec, true, false, false);
                    //     end;
                    //     if (CombineRateInfo.Carrier = 'YRC') or (CombineRateInfo.Carrier = 'Custom Freight') or (CombineRateInfo.Carrier = 'RL Carrier') or (CombineRateInfo.Carrier = 'Truck Freight') then begin
                    //         EmailMngmt.EmailDraft(Rec, false, true, false);
                    //     end;
                    //     if (CombineRateInfo.Carrier = 'Customer PickUp') then begin
                    //         EmailMngmt.EmailDraft(Rec, false, false, true);
                    //     end;
                    // end;
                    Report.Run(Report::SendTrackingNoEmail);
                end;
            }
            action("Delivery Note -By Box")
            {
                ApplicationArea = All;
                Caption = 'Delivery Note -By Box';
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = PaclanticCompany;
                trigger OnAction()
                var
                    SubpackingLines: Record "Sub Packing Lines";
                    BoxIDs: Text;
                begin
                    Clear(BoxIDs);
                    SubpackingLines.Reset();
                    SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
                    SubpackingLines.SetRange("Packing No.", Rec."No");
                    if SubpackingLines.FindFirst() then begin
                        repeat
                            if (SubpackingLines."Tracking ID" = '') and (SubpackingLines."Label URL" = '') then
                                if BoxIDs = '' then
                                    BoxIDs := SubpackingLines."Box Sr ID/Packing No."
                                else
                                    BoxIDs := ' ; ' + SubpackingLines."Box Sr ID/Packing No.";
                        until SubpackingLines.Next() = 0;
                    end;
                    if BoxIDs = '' then
                        GenerateBrcodeAndLotAssignAndPrint(Rec)
                    else
                        if Confirm(StrSubstNo(ConfirmationTxt, BoxIDs), true) then
                            GenerateBrcodeAndLotAssignAndPrint(Rec);
                end;
            }

            action("Packing List - By Box")
            {
                ApplicationArea = All;
                Caption = 'Packing List - By Box';
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = BlossomCompany;
                trigger OnAction()
                var
                    SubpackingLines: Record "Sub Packing Lines";
                    BoxIDs: Text;
                begin
                    Clear(BoxIDs);
                    SubpackingLines.Reset();
                    SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
                    SubpackingLines.SetRange("Packing No.", Rec."No");
                    if SubpackingLines.FindFirst() then begin
                        repeat
                            if (SubpackingLines."Tracking ID" = '') and (SubpackingLines."Label URL" = '') then
                                if BoxIDs = '' then
                                    BoxIDs := SubpackingLines."Box Sr ID/Packing No."
                                else
                                    BoxIDs := ' ; ' + SubpackingLines."Box Sr ID/Packing No.";
                        until SubpackingLines.Next() = 0;
                    end;
                    if BoxIDs = '' then
                        GenerateBrcodeAndLotAssignAndPrint(Rec)
                    else
                        if Confirm(StrSubstNo(ConfirmationTxt, BoxIDs), true) then
                            GenerateBrcodeAndLotAssignAndPrint(Rec);
                end;
            }

        }
    }
    trigger OnAfterGetRecord()
    begin
        verifymsg := Rec.Verify();
    end;

    trigger OnOpenPage()
    var
    begin

        if CompanyName = 'Paclantic Naturals LLC' then begin
            PaclanticCompany := true;
            BlossomCompany := false;
        end
        else
            if CompanyName = 'Blossom Group LLC' then begin
                BlossomCompany := true;
                PaclanticCompany := false;
            end
            else begin
                PaclanticCompany := true;
                BlossomCompany := true;
            end
    end;

    procedure GenerateBrcodeAndLotAssignAndPrint(ShipPackageHeader: Record "Ship Package Header")
    var
        SubpackingLines: Record "Sub Packing Lines";
        SIEventMngt: Codeunit "SI Event Mgnt";
    begin
        SubpackingLines.Reset();
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", Rec.No);
        if SubpackingLines.FindFirst() then begin
            SIEventMngt.BoxSequence(SubpackingLines);
            Commit();
        end;
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", Rec."No");
        if SubpackingLines.FindFirst() then begin
            SIEventMngt.GetBarcode(SubpackingLines);
            Commit();
        end;
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", Rec."No");
        if SubpackingLines.FindFirst() then begin
            SIEventMngt.PostedBOXWiseLOTAssignment(SubpackingLines);
            Commit();
        end;
        SubpackingLines.Reset();
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", Rec."No");
        if SubpackingLines.FindFirst() then begin
            if CompanyName = 'Blossom Group LLC' then
                Report.RunModal(Report::"Packing List - Box", true, false, SubpackingLines)
            else
                if CompanyName = 'Paclantic Naturals LLC' then
                    Report.RunModal(Report::"Delivery Note - Box", true, false, SubpackingLines)
        end;
    end;

    var
        PaclanticCompany: boolean;
        BlossomCompany: boolean;
        verifymsg: Text;
        ConfirmationTxt: Label 'Shipping Labels for Box ID/s %1 NOT purchased yet.  Do you want to print this Packing List/Delivery Note?';
}
