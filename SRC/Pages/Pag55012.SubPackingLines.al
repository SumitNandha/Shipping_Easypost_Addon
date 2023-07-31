page 55012 "Sub Packing Lines"
{
    Caption = 'Sub Packing Lines';
    PageType = ListPart;
    SourceTable = "Sub Packing Lines";
    //  InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Packing No."; Rec."Packing No.")
                {
                    ToolTip = 'Specifies the value of the Packing No. field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Packing Type"; Rec."Packing Type")
                {
                    ToolTip = 'Specifies the value of the Packing Type field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                // field("Cls. Box"; Rec."Cls. Box")
                // {
                //     ToolTip = 'Specifies the value of the Cls. Box field.';
                //     ApplicationArea = All;
                // }
                field("Box Sr ID/Packing No."; Rec."Box Sr ID/Packing No.")
                {
                    //   Caption = 'Box Sr ID/Packing No.';
                    ToolTip = 'Specifies the value of the Box Sr ID/Packing No. field.';
                    ApplicationArea = All;
                    CaptionClass = GetCaptionID();

                    // Editable = false;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        packingadjustment: Record "Packing Adjustment";
                    begin
                        packingadjustment.Reset();
                        packingadjustment.SetFilter("Box/Pallet ID", '=%1', Rec."Box Sr ID/Packing No.");
                        if packingadjustment.FindSet() then Page.RunModal(Page::"Packing Adjustment", packingadjustment);
                    end;
                }
                field("Box Code / Packing Type`"; Rec."Box Code / Packing Type")
                {
                    //Caption = 'Box Code / Packing Type';
                    ToolTip = 'Specifies the value of the Box Code / Packing Type field.';
                    ApplicationArea = All;
                    CaptionClass = GetCaptionCode();
                }
                field("Qty Packed"; Rec."Qty Packed")
                {
                    ToolTip = 'Specifies the value of the Qty Packed field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Gross Ship Wt"; Rec."Total Gross Ship Wt")
                {
                    ToolTip = 'Specifies the value of the Total Gross Ship Wt field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Box Dimension"; Rec."Box Dimension")
                {
                    ToolTip = 'Specifies the value of the Box Dimension field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tracking ID"; Rec."Tracking ID")
                {
                    ToolTip = 'Specifies the value of the Tracking ID field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Label Print count"; Rec."Label Print count")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Tracking URL"; Rec."Tracking URL")
                {
                    ToolTip = 'Specifies the value of the Tracking URL field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Label URL"; Rec."Label URL")
                {
                    ToolTip = 'Specifies the value of the Label URL field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Label Image"; Rec."Label Image")
                {
                    ToolTip = 'Specifies the value of the Label Image field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Insurance price"; Rec."Insurance price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("View Box")
            {
                ApplicationArea = all;

                trigger OnAction()
                var
                    packingadjustment: Record "Packing Adjustment";
                    PackingAdjust: Page "Packing Adjustment";
                begin
                    packingadjustment.Reset();
                    packingadjustment.SetFilter("Box/Pallet ID", '=%1', Rec."Box Sr ID/Packing No.");
                    if packingadjustment.FindSet() then begin
                        PackingAdjust.SetTableView(packingadjustment);
                        PackingAdjust.Editable(false);
                        PackingAdjust.Run();
                    end;
                end;
            }
            action("Delivery Note -Box")
            {
                ApplicationArea = All;
                Caption = 'Delivery Note - By Box';
                Visible = PaclanticCompany;

                trigger OnAction()
                begin
                    if Rec."Packing Type" = Rec."Packing Type"::Box then
                        if (Rec."Tracking ID" <> '') and (Rec."Label URL" <> '') then begin
                            GenerateBrcodeAndLotAssignAndPrint(Rec);
                        end else
                            if Confirm(StrSubstNo(ConfirmationTxt, Rec."Box Sr ID/Packing No."), true) then
                                GenerateBrcodeAndLotAssignAndPrint(Rec);
                end;
            }
            action("Packing List - By Box")
            {
                ApplicationArea = All;
                Caption = 'Packing List - By Box';
                Visible = BlossomCompany;
                trigger OnAction()
                begin
                    if Rec."Packing Type" = Rec."Packing Type"::Box then
                        if (Rec."Tracking ID" <> '') and (Rec."Label URL" <> '') then begin
                            GenerateBrcodeAndLotAssignAndPrint(Rec);
                        end else
                            if Confirm(StrSubstNo(ConfirmationTxt, Rec."Box Sr ID/Packing No."), true) then
                                GenerateBrcodeAndLotAssignAndPrint(Rec);
                end;
            }

            action("View LOT Assignment")
            {
                ApplicationArea = All;
                Caption = 'View LOT Assignment';
                trigger OnAction()
                var
                    BoxwiseLOTAssign: Record "Box wise LOT assignment";
                begin
                    BoxwiseLOTAssign.Reset();
                    BoxwiseLOTAssign.SetRange("Packing No", Rec."Packing No.");
                    if BoxwiseLOTAssign.FindSet() then;
                    Page.RunModal(Page::"LOT Assignment ", BoxwiseLOTAssign);
                end;
            }

            action("Generate Barcode")
            {
                ApplicationArea = All;
                Caption = 'Generate Barcode';
                Visible = false;
                trigger OnAction()
                var
                    SubpackingLines: Record "Sub Packing Lines";
                    SIEventMngt: Codeunit "SI Event Mgnt";
                begin
                    SubpackingLines.Reset();
                    SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
                    SubpackingLines.SetRange("Packing No.", Rec."Packing No.");
                    SubpackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box Sr ID/Packing No.");
                    if SubpackingLines.FindFirst() then begin
                        SIEventMngt.GetBarcode(SubpackingLines);
                        Commit();
                    end;
                end;
            }
            action("Buy Shipment")
            {
                ApplicationArea = All;
                Caption = 'Buy Shipments';
                Visible = true;
                Enabled = BuyShimentEnable;
                trigger OnAction()
                begin
                    
                    BuyShipment(Rec);
                end;
            }
        }
    }
    local procedure GetCaptionCode(): Text
    var
        BoxCode: Label 'Box Code';
        PalletCode: Label 'Pallet Code';
    begin
        if Rec."Packing Type" = Rec."Packing Type"::Box then
            exit(BoxCode)
        else
            exit(PalletCode)
    end;

    local procedure GetCaptionID(): Text
    var
        BoxID: Label 'Box ID';
        PalletID: Label 'Pallet ID';
    begin
        if Rec."Packing Type" = Rec."Packing Type"::Box then
            exit(BoxID)
        else
            exit(PalletID)
    end;

    trigger OnOpenPage()
    var
        Shippackageheader: Record "Ship Package Header";
        SubPackingLines: Record "Sub Packing Lines";
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
            end;


    end;

    trigger OnAfterGetCurrRecord()
    var
        Shippackageheader: Record "Ship Package Header";
    begin
        if Rec."Packing Type" = Rec."Packing Type"::Box then
            BuyShimentEnable := true
        else
            BuyShimentEnable := false;
    end;

    procedure BuyShipment(SubPackingLines: Record "Sub Packing Lines")
    var
        CombineRateInfo: Record "Combine Rate Information";
        BuyShip: Codeunit BuyShipment;
        BuyShipmentRec: Record "Buy Shipment";
    begin
        CombineRateInfo.Reset();
        CombineRateInfo.SetRange("Packing No.", SubPackingLines."Packing No.");
        CombineRateInfo.SetRange("Buy Service", true);
        if CombineRateInfo.FindFirst() then begin
            if Not (CombineRateInfo.Carrier in ['YRC', 'Custom Freight', 'Customer PickUp', 'Truck Freight']) then begin
                BuyShipmentRec.Reset();
                BuyShipmentRec.SetRange("No.", SubPackingLines."Packing No.");
                BuyShipmentRec.SetRange("Packing No", SubPackingLines."Box Sr ID/Packing No.");
                BuyShipmentRec.SetRange("EasyPost CA Account",CombineRateInfo."EasyPost CA Account");//SN_11042023+
                if BuyShipmentRec.FindFirst() then begin
                    if BuyShipmentRec."Rate ID" <> '' then
                        BuyShip.BuyShipments(BuyShipmentRec);
                end;
            end;
        end;
    end;

    procedure GenerateBrcodeAndLotAssignAndPrint(Rec: Record "Sub Packing Lines")
    var
        SubpackingLines: Record "Sub Packing Lines";
        SIEventMngt: Codeunit "SI Event Mgnt";
        ShippackageHeader: Record "Ship Package Header";
    begin
        SubpackingLines.Reset();
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", Rec."Packing No.");
        SubpackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box Sr ID/Packing No.");
        if SubpackingLines.FindFirst() then begin
            SIEventMngt.BoxSequence(SubpackingLines);
            Commit();
        end;
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", Rec."Packing No.");
        SubpackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box Sr ID/Packing No.");
        if SubpackingLines.FindFirst() then begin
            SIEventMngt.GetBarcode(SubpackingLines);
            Commit();
        end;
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", Rec."Packing No.");
        SubpackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box Sr ID/Packing No.");
        if SubpackingLines.FindFirst() then begin
            if ShippackageHeader.Get(SubpackingLines."Packing No.") then begin
                if ShippackageHeader.Posted = false then
                    SIEventMngt.UnpostedBOXWiseLOTAssignment(SubpackingLines)
                else
                    SIEventMngt.PostedBOXWiseLOTAssignment(SubpackingLines);
                Commit();
            end;
        end;
        SubpackingLines.Reset();
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", Rec."Packing No.");
        SubpackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box Sr ID/Packing No.");
        if SubpackingLines.FindFirst() then begin
            if CompanyName = 'Blossom Group LLC' then
                Report.RunModal(Report::"Packing List - Box", true, false, SubpackingLines)
            else
                if CompanyName = 'Paclantic Naturals LLC' then
                    Report.RunModal(Report::"Delivery Note - Box", true, false, SubpackingLines)
        end
    end;


    var
        PaclanticCompany: boolean;
        BlossomCompany: boolean;
        ConfirmationTxt: Label 'Shipping Labels for Box ID %1 NOT purchased yet.  Do you want to print this Packing List/Delivery Note?';
        BuyShimentEnable: Boolean;

}

