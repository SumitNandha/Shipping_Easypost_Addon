page 55003 "Ship Package Header"
{
    Caption = 'Ship Package';
    PageType = Card;
    SourceTable = "Ship Package Header";
    ApplicationArea = All;
    UsageCategory = Documents;

    //  Editable = PostedVar;
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
                    Caption = 'Sales Document No';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Location; Rec.Location)
                {
                    ApplicationArea = All;
                    Editable = edit;
                    // AssistEdit = true;
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
                    Editable = edit;
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
                    // Editable = PostedVar;
                }
                field("Service Option"; Rec."Service Option")
                {
                    ApplicationArea = All;
                    Visible = false;
                    // Editable = PostedVar;
                }
                field("NMFC Class"; Rec."NMFC Class")
                {
                    ApplicationArea = All;
                    Visible = false;
                    // Editable = PostedVar;
                }
                field(Class; Rec.Class)
                {
                    ApplicationArea = All;
                    // Editable = PostedVar;
                    Visible = false;
                }
                field("YRC Discount Percentage"; Rec."YRC Discount Percentage")
                {
                    ApplicationArea = All;
                    Visible = false;
                    // Editable = PostedVar;
                }
                field(RLMessage; RLMessage)
                {
                    ApplicationArea = all;
                    MultiLine = true;
                    ShowCaption = true;
                    Caption = 'RL Message';
                    Editable = false;
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
                    Editable = edit;

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
                    Editable = true;
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
                    Editable = false;
                }
                field("Web Order No"; Rec."Web Order No")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shipment Refund Status"; Rec."Shipment Refund Status")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                    Editable = edit;
                    Caption = 'Add Shipping Cost to Invoice';
                }
                field("Use 3rd Party Shipping Account"; Rec."Use 3rd Party Shipping Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use 3rd Party Shipping Account field.';
                    trigger OnValidate()
                    begin
                        if rec."Use 3rd Party Shipping Account" = true then begin
                            IF (Rec."3rd Party Account No." = '') and (Rec."3rd Party Account Zip" = '') and (Rec."3rd Party country" = '') and (Rec."3rd Party Carrier" = '') then
                                EditThirdPartyDetails := true;
                        end else
                            EditThirdPartyDetails := false;
                        CurrPage.Update(true);
                    end;
                }
                field("3rd Party Account No."; Rec."3rd Party Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3rd Party Account No. field.';
                    Editable = EditThirdPartyDetails;
                }
                field("3rd Party Account Zip"; Rec."3rd Party Account Zip")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3rd Party Account Zip field.';
                    Editable = EditThirdPartyDetails;
                }
                field("3rd Party Carrier"; Rec."3rd Party Carrier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3rd Party Carrier field.';
                    Editable = EditThirdPartyDetails;
                }
                field("3rd Party country"; Rec."3rd Party country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3rd Party country field.';
                    Editable = EditThirdPartyDetails;
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
                field(ShiptoEdit; ShiptoEdit)
                {
                    ApplicationArea = all;
                    Caption = 'Ship to Edit';
                    Editable = edit;
                }
                field("Ship-to Company"; rec."Ship-to Company")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to Customer No."; Rec."Ship-to Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to Name 2"; Rec."Ship-to Name 2")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to County"; Rec."Ship-to County")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to Contact No."; Rec."Ship-to Contact No.")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                }
                field("Ship-to Email"; Rec."Ship-to Email")
                {
                    ApplicationArea = All;
                    Editable = ShiptoEdit;
                    MultiLine = true;
                }
                field("Zip Message"; Rec."Zip Message")
                {
                    ApplicationArea = All;
                    StyleExpr = VerifyMsg;
                    Editable = false;
                    Caption = 'Addr. Validation (Zip Message)';
                }
                field("Delivery Message"; Rec."Delivery Message")
                {
                    ApplicationArea = All;
                    StyleExpr = VerifyMsg;
                    Editable = false;
                    Caption = 'Addr. Validation (Delivery Message)';
                }
                field("Suggested Address"; Rec."Suggested Address")
                {
                    ApplicationArea = All;
                    Caption = 'Validated Address';
                    Editable = false;
                    MultiLine = true;
                }
                field("Update Suggested Addr"; Rec."Update Suggested Addr")
                {
                    ApplicationArea = All;
                    Caption = 'Copy Validated Address to ”Ship-To”';
                    // Editable = PostedVar;
                }
                field("Use Ship-to Adsress"; Rec."Use Ship-to Adsress")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Ship-to Adsress field.';
                    Caption = 'Ignore Address Validation';
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
                Editable = edit;
            }
            part("Tracker"; "tracker List")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field(No);
                UpdatePropagation = Both;
                SubPageView = sorting("Tracking Code");
                Visible = false;
                Editable = edit;
            }
            part("Combine Rate Information"; "Combine Rate Information")
            {
                ApplicationArea = All;
                SubPageLink = "Packing No." = field(No);
                UpdatePropagation = SubPart;
                Editable = edit;
                //Visible = false;
            }
            part("Buy Shipment"; "Detailed Rates List")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field(No);
                UpdatePropagation = SubPart;
                Editable = edit;
                //Visible = false;
            }
            part("RL Rate Quote"; "RL Rate Quote")
            {
                ApplicationArea = All;
                SubPageLink = No = field(No);
                UpdatePropagation = SubPart;
                Visible = false;
                Editable = edit;
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
        area(Navigation)
        {
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
            action("Delivery Note")
            {
                ApplicationArea = All;
                Caption = 'Delivery Note';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Report;
                Visible = PaclanticCompany;

                trigger OnAction()
                var
                    WarehouseActivityheader: Record "Warehouse Activity Header";
                begin
                    WarehouseActivityheader.Reset();
                    WarehouseActivityheader.SetRange("No.", Rec."Inventory Pick");
                    if WarehouseActivityheader.FindFirst() then Report.Run(Report::"Delivery Note", true, false, WarehouseActivityheader);
                end;
            }
            action("Packing List")
            {
                ApplicationArea = All;
                Caption = 'Packing List';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Report;
                Visible = BlossomCompany;

                trigger OnAction()
                var
                    WarehouseActivityheader: Record "Warehouse Activity Header";
                begin
                    WarehouseActivityheader.Reset();
                    WarehouseActivityheader.SetRange("No.", Rec."Inventory Pick");
                    if WarehouseActivityheader.FindFirst() then Report.Run(Report::"Packing List", true, false, WarehouseActivityheader);
                end;
            }



            action("Inventory-Pick")
            {
                ApplicationArea = All;
                Caption = 'Inventory Pick Card';
                Image = Card;

                trigger OnAction()
                var
                    InventoryPickHeader: Record "Warehouse Activity Header";
                begin
                    InventoryPickHeader.Reset();
                    InventoryPickHeader.SetRange("No.", Rec."Inventory Pick");
                    if InventoryPickHeader.FindFirst() then;
                    Page.RunModal(Page::"Inventory Pick", InventoryPickHeader);
                end;
            }
            action(DocumentCard)
            {
                ApplicationArea = All;
                Caption = 'Sales Document Card';
                Image = Card;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader.Reset();
                    SalesHeader.SetRange("No.", Rec."Document No.");
                    if SalesHeader.FindFirst() then;
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then page.RunModal(Page::"Sales Order", SalesHeader);
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then page.RunModal(Page::"Sales Quote", SalesHeader);
                end;
            }
            action("Select Sales Document No")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Caption = 'Select Sales Document No';
                ToolTip = 'Salect sales Document No to create Ship Package Card';
                Image = Select;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    OrderQuote: Label '&Order,&Quote';
                    DefaultOption: Integer;
                    Selection: Integer;
                begin
                    DefaultOption := 0;
                    Selection := StrMenu(OrderQuote, DefaultOption);
                    if Selection = 0 then;
                    // Receive := Selection in [1];
                    // Invoice := Selection in [2];
                    if Selection = 1 then if Page.RunModal(Page::"Sales Order list", SalesHeader) = Action::lookUpOK then Rec.Validate("Document No.", SalesHeader."No.");
                    if Selection = 2 then if Page.RunModal(Page::"Sales Quotes", SalesHeader) = Action::lookUpOK then Rec.Validate("Document No.", SalesHeader."No.");
                end;
            }
            action("Select Inventory Pick No")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Caption = 'Select Inventory Pick No';
                ToolTip = 'Salect Inventory Pick No to create Ship Package Card';
                Image = Select;

                trigger OnAction()
                var
                    WarehouseActHeader: Record "Warehouse Activity Header";
                begin
                    if Page.RunModal(Page::"Inventory Picks", WarehouseActHeader) = Action::lookUpOK then Rec.Validate("Inventory Pick", WarehouseActHeader."No.");
                end;
            }
            action("Delivery Note - By Box")
            {
                ApplicationArea = All;
                Caption = 'Delivery Note - By Box';
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
                                    BoxIDs += ' ; ' + SubpackingLines."Box Sr ID/Packing No.";
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
                                    BoxIDs += ' ; ' + SubpackingLines."Box Sr ID/Packing No.";
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
        area(Processing)
        {
            action("Pack In Box")
            {
                ApplicationArea = All;
                Image = Allocate;

                trigger OnAction()
                var
                    Packin: Record "Pack In";
                    PackInLines: Record "Pack In Lines";
                    shipPackageLines: Record "Ship Packing Lines";
                    PackInLinesLast: Record "Pack In Lines";
                    shipmarkup: Record "Shipping MarkUp Setup";
                    SalesHeader: Record "Sales Header";
                begin
                    Packin.Reset();
                    Packin.SetRange("Packing No.", Rec.No);
                    Packin.SetRange("Packing Type", Packin."Packing Type"::Box);
                    if not Packin.FindSet() then begin
                        Packin.Init();
                        Packin.Validate("Packing No.", Rec.No);
                        Packin.Validate("Packing Type", Packin."Packing Type"::Box);
                        Packin.Validate("Pack in Boxes?", true);
                        Packin.Insert();
                    end;
                    //  PackInLines.DeleteAll();
                    PackInLines.Reset();
                    PackInLines.SetRange("Packing No.", Rec.No);
                    PackInLines.SetRange("Packing Type", PackInLines."Packing Type"::Box);
                    if not PackInLines.FindSet() then begin
                        shipPackageLines.Reset();
                        shipPackageLines.SetRange("No.", Rec.No);
                        if shipPackageLines.FindSet() then begin
                            repeat
                                PackInLinesLast.Reset();
                                PackInLinesLast.SetRange("Packing No.", PackInLines."Packing No.");
                                if PackInLinesLast.FindLast() then;
                                PackInLines.Init();
                                PackInLines.Validate("Packing No.", Rec.No);
                                PackInLines.Validate("Packing Type", PackInLines."Packing Type"::Box);
                                PackInLines.Validate("Line No.", shipPackageLines."Line No.");
                                PackInLines.Validate("Item No.", shipPackageLines."Item No.");
                                PackInLines.Validate("Item Description", shipPackageLines.Description);
                                PackInLines.Validate("Sales UoM", shipPackageLines."Sales UOM");
                                PackInLines.Validate("Gross Wt (Items)", shipPackageLines."Total Item Weight");
                                PackInLines.Validate("Total Qty", shipPackageLines.Quantity);
                                PackInLines.Validate("Box/Pallet ID", shipPackageLines."Box Code for Item");
                                PackInLines.Validate("Remaining Qty", shipPackageLines.Quantity);
                                PackInLines.Validate(SourceLineNo, shipPackageLines.SourceLineNo);
                                PackInLines.Insert();
                            until shipPackageLines.Next() = 0;
                        end;
                    end;
                    PackIn.Reset();
                    PackIn.SetRange("Packing No.", Rec.No);
                    Packin.SetRange("Packing Type", Packin."Packing Type"::Box);
                    if PackIn.FindSet() then begin
                        Page.Run(Page::"Pack In Box", PackIn);
                    end;
                end;
            }
            action("Pack in Pallets")
            {
                ApplicationArea = All;
                Image = Allocate;

                trigger OnAction()
                var
                    Packin: Record "Pack In";
                    PackInLines: Record "Pack In Lines";
                    shipPackageLines: Record "Ship Packing Lines";
                    PackInLinesLast: Record "Pack In Lines";
                begin
                    Packin.Reset();
                    Packin.SetRange("Packing No.", Rec.No);
                    Packin.SetRange("Packing Type", Packin."Packing Type"::Pallet);
                    if not Packin.FindSet() then begin
                        Packin.Init();
                        Packin.Validate("Packing No.", Rec.No);
                        Packin.Validate("Packing Type", Packin."Packing Type"::Pallet);
                        Packin.Validate("Pack In Pallets?", true);
                        Packin.Validate(Class, Packin.Class::"65.0");
                        Packin.Insert();
                    end;
                    //  PackInLines.DeleteAll();
                    PackInLines.Reset();
                    PackInLines.SetRange("Packing No.", Rec.No);
                    PackInLines.SetRange("Packing Type", PackInLines."Packing Type"::Pallet);
                    if not PackInLines.FindSet() then begin
                        shipPackageLines.Reset();
                        shipPackageLines.SetRange("No.", Rec.No);
                        if shipPackageLines.FindSet() then begin
                            repeat
                                PackInLinesLast.Reset();
                                PackInLinesLast.SetRange("Packing No.", PackInLines."Packing No.");
                                if PackInLinesLast.FindLast() then;
                                PackInLines.Init();
                                PackInLines.Validate("Packing No.", Rec.No);
                                PackInLines.Validate("Packing Type", PackInLines."Packing Type"::Pallet);
                                PackInLines.Validate("Line No.", shipPackageLines."Line No.");
                                PackInLines.Validate("Item No.", shipPackageLines."Item No.");
                                PackInLines.Validate("Item Description", shipPackageLines.Description);
                                PackInLines.Validate("Sales UoM", shipPackageLines."Sales UOM");
                                PackInLines.Validate("Gross Wt (Items)", shipPackageLines."Total Item Weight");
                                PackInLines.Validate("Total Qty", shipPackageLines.Quantity);
                                PackInLines.Validate("Box/Pallet ID", shipPackageLines."Box Code for Item");
                                PackInLines.Validate("Remaining Qty", shipPackageLines.Quantity);
                                PackInLines.Validate(SourceLineNo, shipPackageLines.SourceLineNo);
                                PackInLines.Insert();
                            until shipPackageLines.Next() = 0;
                        end;
                    end;
                    PackIn.Reset();
                    PackIn.SetRange("Packing No.", Rec.No);
                    Packin.SetRange("Packing Type", Packin."Packing Type"::Pallet);
                    if PackIn.FindSet() then begin
                        Page.Run(Page::"Pack In Pallet", PackIn);
                    end;
                end;
            }
            action("Get Rates")
            {
                ApplicationArea = All; //SN+ New Added
                Image = PriceAdjustment;

                trigger OnAction()
                var
                    RateMgnt: Codeunit "Rate Mgnt";
                    CombineRateInfo: Record "Combine Rate Information";
                    location: Record Location;
                    SubPackingLines: Record "Sub Packing Lines";
                    BuyShipment: Record "Buy Shipment";
                    PackIn: Record "Pack In";
                begin
                    //SN-01062023+
                    if (Rec."Zip Message" <> 'Success') or (Rec."Delivery Message" <> 'Success') then
                        if Rec."Use Ship-to Adsress" = true then
                        Error('Ship-to Address is Incorrect.');
                    //SN-01062023-
                    if (Rec.Carrier = '') and (Rec.Service = '') then begin
                        if Rec."Use 3rd Party Shipping Account" then
                            if UpperCase(Rec.Agent) <> UpperCase(Rec."3rd Party Carrier") then
                                Error('Shipping Carrier on Sales Order is different than the 3rd Party Carrier.');
                        Rec.TestField(Location);
                        Rec.TestField("Ship-to Address");
                        Rec.TestField("Ship-to City");
                        Rec.TestField("Ship-to Country/Region Code");
                        Rec.TestField("Ship-to Name");
                        Rec.TestField("Ship-to County");
                        Rec.TestField("Ship-to Email");
                        Rec.TestField("Ship-to Contact No.");
                        location.get(Rec.Location);
                        location.TestField("E-Mail");
                        location.TestField("Country/Region Code");
                        location.TestField("Phone No.");
                        BuyShipment.reset();
                        BuyShipment.SetRange("No.", Rec.No);
                        if BuyShipment.FindSet() then BuyShipment.DeleteAll();
                        BuyShipment.reset();
                        // BuyShipment.SetRange("No.", Rec.No);
                        // BuyShipment.SetRange(Carrier, 'YRC');
                        // if BuyShipment.FindSet() then
                        //     BuyShipment.DeleteAll();
                        PackIn.Reset();
                        PackIn.SetRange("Packing No.", Rec.No);
                        if PackIn.FindFirst() then begin
                            if (PackIn."Close All Boxs" = true) or (PackIn."Close All Pallets" = true) then begin
                                SubPackingLines.Reset();
                                SubPackingLines.SetRange("Packing No.", Rec.No);
                                SubPackingLines.setrange("Packing Type", SubPackingLines."Packing Type"::Pallet);
                                if SubPackingLines.FindSet() then begin
                                    RateMgnt.GetDataCustomeFreight(Rec);
                                    RateMgnt.GetRateYRC(Rec);
                                    RateMgnt.GetRateRL(Rec);
                                end;
                                SubPackingLines.Reset();
                                SubPackingLines.SetRange("Packing No.", Rec.No);
                                SubPackingLines.setrange("Packing Type", SubPackingLines."Packing Type"::Box);
                                if SubPackingLines.FindSet() then begin
                                    RateMgnt.EasyPostGetRate(Rec);
                                end;
                                SubPackingLines.Reset();
                                SubPackingLines.SetRange("Packing No.", Rec.No);
                                if SubPackingLines.FindSet() then begin
                                    repeat
                                        RateMgnt.CustomerPickUp(Rec);
                                        RateMgnt.GetTruckFreight(Rec);
                                        RateMgnt.CombineRateInformation(Rec);
                                    until SubPackingLines.Next() = 0;
                                end;
                                Commit();
                                CombineRateInfo.Reset();
                                CombineRateInfo.SetRange("Packing No.", Rec."No");
                                if CombineRateInfo.FindFirst() then begin
                                    RateMgnt.CheckGetRateForAllBoxesPallets(Rec);
                                    Page.RunModal(Page::"Combine Rate Information", CombineRateInfo)
                                end;
                            end
                            else
                                Message('Please pack items in boxes/pallets. CLOSE boxes/pallets when done.');
                        END
                        else
                            Message('Please pack items in boxes/pallets. CLOSE boxes/pallets when done.');
                    end
                    else
                        Message('You have already purchased the labels. It is recommended to VOID the purchased labels and then use Get Rates again');
                end;
            }
            action("Combine Rate Information.")
            {
                ApplicationArea = All;
                Caption = 'Choose/Buy Service';
                Image = Info;

                //Visible = false;
                trigger OnAction()
                var
                    CombineRateInfo: Record "Combine Rate Information";
                begin
                    if (Rec.Carrier = '') and (rec.Service = '') then begin
                        CombineRateInfo.Reset();
                        CombineRateInfo.SetRange("Packing No.", Rec."No");
                        if CombineRateInfo.FindFirst() then begin
                            Page.RunModal(Page::"Combine Rate Information", CombineRateInfo)
                        end;
                    end
                    else
                        Message('You have already purchased the service.  First VOID the purchased labels.  Then you will be able to select/purchase another service');
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
            action("Other Options")
            {
                ApplicationArea = All;
                Image = Open;

                trigger OnAction()
                var
                    otheroption: Page "Other Option";
                    ShipPackageHeader: Record "Ship Package Header";
                begin
                    ShipPackageHeader.Reset();
                    ShipPackageHeader.SetRange(No, Rec.No);
                    if ShipPackageHeader.FindFirst() then begin
                        Page.Run(Page::"Other Option Card", ShipPackageHeader);
                    end;
                end;
            }
            action("Process Refund")
            {
                ApplicationArea = All; //SN+ New Added
                Image = Process;

                trigger OnAction()
                var
                    BuyShip: Codeunit BuyShipment;
                    BuyShipment: Record "Buy Shipment";
                    CombineRateInfo: Record "Combine Rate Information";
                    jsonBufferTemp: Record "JSON Buffer" temporary;
                    jsonbuffer: Record "JSON Buffer";
                    responseText: Text;
                    Refundstatus: Text;
                    BuyShipRefundStatus: Enum "Shipment Refund Status";
                    BuyShipment1: record "Buy Shipment";
                    RefundUnequal: Boolean;
                    BuyShipment2: record "Buy Shipment";
                    i: Integer;
                    SubPacingLines: Record "Sub Packing Lines";
                    ins: InStream;
                begin
                    i := 1;
                    CombineRateInfo.Reset();
                    CombineRateInfo.SetRange("Packing No.", Rec.No);
                    CombineRateInfo.SetRange("Buy Service", true);
                    if CombineRateInfo.FindSet() then begin
                        BuyShipment.Reset();
                        BuyShipment.SetRange("No.", Rec.No);
                        BuyShipment.SetRange(Carrier, CombineRateInfo.Carrier);
                        BuyShipment.SetRange(Service, CombineRateInfo.Service);
                        if BuyShipment.FindSet() then begin
                            repeat
                                Clear(responseText);
                                responseText := BuyShip.ProcessRefund(BuyShipment."Shipment ID");
                                jsonbuffer.Reset();
                                jsonbuffer.DeleteAll();
                                jsonBufferTemp.ReadFromText(responseText);
                                If jsonBufferTemp.FindSet() then
                                    repeat
                                        JsonBuffer := jsonBufferTemp;
                                        JsonBuffer.Insert();
                                    until jsonBufferTemp.Next = 0;
                                jsonbuffer.Reset();
                                jsonbuffer.SetRange(Path, 'refund_status');
                                jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::String);
                                if jsonbuffer.FindFirst() then begin
                                    if jsonbuffer.GetValue() = 'refunded' then begin
                                        BuyShipment.Validate("Shipment Refund Status", BuyShipment."Shipment Refund Status"::Refunded);
                                        Rec.Validate("Shipment Refund Status", Rec."Shipment Refund Status"::Refunded);
                                    end;
                                    if jsonbuffer.GetValue() = 'rejected' then BuyShipment.Validate("Shipment Refund Status", BuyShipment."Shipment Refund Status"::Rejected);
                                    //   Rec.Validate("Shipment Refund Status", Rec."Shipment Refund Status"::Rejected);
                                    if jsonbuffer.GetValue() = 'submitted' then BuyShipment.Validate("Shipment Refund Status", BuyShipment."Shipment Refund Status"::Submitted);
                                    //   Rec.Validate("Shipment Refund Status", Rec."Shipment Refund Status"::Submitted);
                                    BuyShipment.Modify();
                                end;
                                if i = 1 then begin
                                    clear(BuyShipRefundStatus);
                                    RefundUnequal := true;
                                    BuyShipRefundStatus := BuyShipment."Shipment Refund Status";
                                end;
                                i += 1;
                            until BuyShipment.Next() = 0;
                            BuyShipment1.reset();
                            BuyShipment1.SetRange("No.", BuyShipment."No.");
                            BuyShipment1.SetFilter("Shipment Refund Status", '<>%1', 0);
                            if BuyShipment1.FindSet() then begin
                                repeat
                                    if BuyShipment1."Shipment Refund Status" <> BuyShipRefundStatus then RefundUnequal := false;
                                until BuyShipment1.Next() = 0;
                                if RefundUnequal = true then begin
                                    Rec.Validate("Shipment Refund Status", BuyShipRefundStatus);
                                    Rec.Modify();
                                end
                                else begin
                                    Rec.Validate("Shipment Refund Status", 0);
                                    Rec.Modify();
                                end;
                            end;
                            // end;
                        end;
                        CombineRateInfo.Validate("Buy Service", false);
                        CombineRateInfo.Modify();
                        Rec.Validate(Carrier, '');
                        rec.Validate(Service, '');
                        rec.Validate("Tracking Code", '');
                        Rec.Validate("Confirm Quote No", '');
                        Rec.Validate("Freight Value", 0);
                        Rec.Modify();
                    end;
                end;
            }
            action("Address Verify")
            {
                ApplicationArea = All;
                Image = Check;

                trigger OnAction()
                var
                    JObject: JsonObject;
                    AuthString: Text;
                    //   responstempblob: Record TempBlob;
                    Response: HttpResponseMessage;
                    request: HttpRequestMessage;
                    EasyPostLink: text;
                    responsetext: text;
                    headers: HttpHeaders;
                    jsonBuffertemt: Record "JSON Buffer" temporary;
                    jsonbuffer: Record "JSON Buffer";
                    content: HttpContent;
                    URL: Text;
                    PackingModuleSetUp: Record "Packing Module Setup";
                    HttpClient: HttpClient;
                    Zip4path: Text;
                    DeliveryPath: Text;
                    i: Integer;
                    ZiperrorMsgPath: text;
                    deliveryerrormsgpath: text;
                    ZiperrorFieldPath: Text;
                    deliveryerrorFieldpath: Text;
                    SuggPostCode: Text;
                    strposSuggPostCode: Integer;
                    Base64: Codeunit "Base64 Convert";
                    ResidentialPath: Text;
                    ResidentialBoolean: Boolean;
                begin
                    rec.Validate("Update Suggested Addr", false);
                    Rec.Validate("Suggested Addr", '');
                    Rec.Validate("Suggested Addr 2", '');
                    Rec.Validate("Suggested city", '');
                    Rec.Validate("Suggested state", '');
                    Rec.Validate("Suggested post Code", '');
                    Rec.Validate("Suggested Country Code", '');
                    Rec.Validate("Suggested Address", '');
                    Rec.Validate(Residential, false);
                    PackingModuleSetUp.Get();
                    JObject.Add('street1', Rec."Ship-to Address");
                    JObject.Add('street2', Rec."Ship-to Address 2");
                    JObject.Add('city', Rec."Ship-to city");
                    JObject.Add('state', Rec."Ship-to county");
                    JObject.Add('zip', Rec."Ship-to Post Code");
                    JObject.Add('country', Rec."Ship-to Country/Region Code");
                    JObject.Add('company', Rec."Ship-to Company");
                    JObject.Add('name', Rec."Ship-to Name");
                    // Message(format(JObject));
                    URL := 'https://api.easypost.com/api/v2/addresses?verify';
                    content.WriteFrom(Format(JObject));
                    content.GetHeaders(Headers);
                    Headers.Clear();
                    Headers.Add('Content-Type', 'application/json');
                    request.Content := content;
                    request.Method := 'POST';
                    request.SetRequestUri(URL);
                    request.GetHeaders(Headers);
                    if PackingModuleSetUp."Mode Test" then
                        AuthString := StrSubstNo('%1', PackingModuleSetUp."EasyPost API Key")
                    else
                        AuthString := StrSubstNo('%1', PackingModuleSetUp."EasyPost Live API Key");
                    //  responstempblob.WriteAsText(AuthString, TextEncoding::UTF8);
                    //  AuthString := responstempblob.ToBase64String();
                    AuthString := Base64.ToBase64(AuthString);
                    AuthString := StrSubstNo('Basic %1', AuthString);
                    Headers.Add('Authorization', AuthString);
                    HttpClient.Get(URL, response);
                    HttpClient.Send(request, response);
                    response.Content.ReadAs(responsetext);
                    // Message(responsetext);
                    jsonbuffer.Reset();
                    jsonbuffer.DeleteAll();
                    jsonBuffertemt.ReadFromText(responsetext);
                    IF jsonBuffertemt.FindSet() then begin
                        repeat
                            jsonbuffer := jsonBuffertemt;
                            jsonbuffer.Insert();
                        until jsonBuffertemt.Next() = 0;
                    end;
                    Clear(Rec."Zip Message");
                    Zip4path := 'verifications.zip4.success';
                    jsonbuffer.Reset();
                    jsonbuffer.SetFilter(Path, Zip4path);
                    jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::Boolean);
                    if jsonbuffer.FindFirst() then begin
                        if jsonbuffer.value = 'Yes' then begin
                            Rec.validate("Zip Message", 'Success');
                            Rec.Modify();
                        end
                        else begin
                            for i := 0 to 1 do begin
                                ZiperrorFieldPath := 'verifications.zip4.errors[' + Format(i) + '].field';
                                jsonbuffer.Reset();
                                jsonbuffer.SetFilter(Path, ZiperrorFieldPath);
                                jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::String);
                                if jsonbuffer.FindFirst() then Rec."Zip Message" += jsonbuffer.GetValue() + ' : ';
                                ZiperrorMsgPath := 'verifications.zip4.errors[' + Format(i) + '].message';
                                jsonbuffer.Reset();
                                jsonbuffer.SetFilter(Path, ZiperrorMsgPath);
                                jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::String);
                                if jsonbuffer.FindFirst() then Rec."Zip Message" += jsonbuffer.GetValue() + ' ; ';
                                i := i + 1;
                            end;
                        end;
                    end;
                    Clear(Rec."Delivery Message");
                    DeliveryPath := 'verifications.delivery.success';
                    jsonbuffer.Reset();
                    jsonbuffer.SetFilter(Path, DeliveryPath);
                    jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::Boolean);
                    if jsonbuffer.FindFirst() then begin
                        if jsonbuffer.value = 'Yes' then begin
                            Rec.validate("Delivery Message", 'Success');
                            Rec.Modify();
                            // if Rec."Ship-to Address" = '' then begin
                            jsonbuffer.Reset();
                            jsonbuffer.SetRange(Path, 'street1');
                            jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                            if jsonbuffer.FindFirst() then begin
                                if jsonbuffer.GetValue() <> '' then begin
                                    Rec.Validate("Suggested Addr", jsonbuffer.GetValue());
                                    Rec."Suggested Address" += Rec."Suggested Addr" + ' ; ';
                                end;
                            end;
                            //if Rec."Ship-to Address 2" = '' then begin
                            jsonbuffer.Reset();
                            jsonbuffer.SetRange(Path, 'street2');
                            jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                            if jsonbuffer.FindFirst() then begin
                                if jsonbuffer.GetValue() <> '' then begin
                                    Rec.Validate("Suggested Addr 2", jsonbuffer.GetValue());
                                    Rec."Suggested Address" += Rec."Suggested Addr 2" + ' ; ';
                                END;
                            end;
                            //if Rec."Ship-to City" = '' then begin
                            jsonbuffer.Reset();
                            jsonbuffer.SetRange(Path, 'city');
                            jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                            if jsonbuffer.FindFirst() then begin
                                if jsonbuffer.GetValue() <> '' then begin
                                    Rec.Validate("Suggested City", jsonbuffer.GetValue());
                                    Rec."Suggested Address" += Rec."Suggested city" + ' ; ';
                                end;
                            end;
                            //if Rec."Ship-to County" = '' then begin
                            jsonbuffer.Reset();
                            jsonbuffer.SetRange(Path, 'state');
                            jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                            if jsonbuffer.FindFirst() then begin
                                if jsonbuffer.GetValue() <> '' then begin
                                    Rec.Validate("Suggested state", jsonbuffer.GetValue());
                                    Rec."Suggested Address" += Rec."Suggested State" + ' ; ';
                                end;
                            end;
                            //if Rec."Ship-to Post Code" = '' then begin
                            jsonbuffer.Reset();
                            jsonbuffer.SetRange(Path, 'zip');
                            jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                            if jsonbuffer.FindFirst() then begin
                                if jsonbuffer.GetValue() <> '' then begin
                                    strposSuggPostCode := StrPos(jsonbuffer.GetValue(), '-');
                                    SuggPostCode := CopyStr(jsonbuffer.GetValue(), 1, strposSuggPostCode - 1);
                                    Rec.Validate("Suggested Post Code", SuggPostCode);
                                    Rec."Suggested Address" += Rec."Suggested Post Code" + ' ; ';
                                end;
                            end;
                            //if Rec."Ship-to Country/Region Code" = '' then begin
                            jsonbuffer.Reset();
                            jsonbuffer.SetRange(Path, 'country');
                            jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                            if jsonbuffer.FindFirst() then begin
                                if jsonbuffer.GetValue() <> '' then begin
                                    Rec.Validate("Suggested Country Code", jsonbuffer.GetValue());
                                    Rec."Suggested Address" += Rec."Suggested Country Code" + ' ; ';
                                END;
                            end;
                        end
                        else begin
                            for i := 0 to 1 do begin
                                deliveryerrorFieldpath := 'verifications.delivery.errors[' + Format(i) + '].field';
                                jsonbuffer.Reset();
                                jsonbuffer.SetFilter(Path, deliveryerrorFieldpath);
                                jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::String);
                                if jsonbuffer.FindFirst() then Rec."Delivery Message" += jsonbuffer.GetValue() + ' : ';
                                deliveryerrormsgpath := 'verifications.delivery.errors[' + Format(i) + '].message';
                                jsonbuffer.Reset();
                                jsonbuffer.SetFilter(Path, deliveryerrormsgpath);
                                jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::String);
                                if jsonbuffer.FindFirst() then Rec."Delivery Message" += jsonbuffer.GetValue() + ' ; ';
                                i := i + 1;
                            end;
                        end;
                        ResidentialPath := 'residential';
                        jsonbuffer.Reset();
                        jsonbuffer.SetRange(Path, ResidentialPath);
                        jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::Boolean);
                        if jsonbuffer.FindFirst() then begin
                            Evaluate(ResidentialBoolean, jsonbuffer.GetValue());
                            Rec.Validate(Residential, ResidentialBoolean);
                            Rec.Modify();
                        end;
                    end
                end;
                //  end;
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
                    CombineRateInfo.Reset();
                    CombineRateInfo.SetRange("Packing No.", Rec.No);
                    CombineRateInfo.SetRange("Buy Service", true);
                    if CombineRateInfo.FindFirst() then begin
                        if (CombineRateInfo.Carrier <> 'YRC') AND (CombineRateInfo.Carrier <> 'RL Carrier') and (CombineRateInfo.Carrier <> 'Custom Freight') and (CombineRateInfo.Carrier <> 'Customer PickUp') then begin
                            EmailMngmt.EmailDraft(Rec, true, false, false);
                        end;
                        if (CombineRateInfo.Carrier = 'YRC') or (CombineRateInfo.Carrier = 'Custom Freight') or (CombineRateInfo.Carrier = 'RL Carrier') or (CombineRateInfo.Carrier = 'Truck Freight') then begin
                            EmailMngmt.EmailDraft(Rec, false, true, false);
                        end;
                        if (CombineRateInfo.Carrier = 'Customer PickUp') then begin
                            EmailMngmt.EmailDraft(Rec, false, false, true);
                        end;
                    end;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        // if Rec.Posted = true then
        //     PostedVar := false
        // else
        //     PostedVar := true;
        VerifyMsg := Rec.Verify();

    end;

    var
        VerifyMsg: text;

    local procedure SetJSONData(ShipPackageLines: Record "Ship Packing Lines";
    I: Integer)
    var
        JsonObjectVar: JsonObject;
        ShipPackageHeader: Record "Ship Package Header";
        Location: Record Location;
        palletBoxMaster: Record "Pallet/Box Master";
    begin
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange(No, Rec."No");
        if ShipPackageHeader.FindFirst() then;
        Location.Get(ShipPackageHeader.Location);
        "PalletBoxmaster".Get(ShipPackageLines."Packing type");
        case I of
            1:
                begin
                    MasterJson.Add('object', 'Shipment');
                    SetShippingToAddress(ShipPackageHeader);
                end;
            2:
                begin
                    SetShippingFromAddress(Location);
                end;
            3:
                begin
                    ParcelInfo(palletBoxMaster);
                end;
            4:
                begin
                    Custom_info(ShipPackageLines);
                end;
        end;
    end;

    local procedure SetShippingToAddress(ShipPackageHeader: Record "Ship Package Header")
    var
        myInt: Integer;
        JsonObjectVar: JsonObject;
    begin
        Clear(JsonObjectVar);
        JsonObjectVar.Add('name', ShipPackageHeader."Ship-to Name");
        JsonObjectVar.Add('company', '');
        JsonObjectVar.Add('street1', ShipPackageHeader."Ship-to Address");
        JsonObjectVar.Add('street2', ShipPackageHeader."Ship-to Address 2");
        JsonObjectVar.Add('city', ShipPackageHeader."Ship-to City");
        JsonObjectVar.Add('state', ShipPackageHeader."Ship-to County");
        JsonObjectVar.Add('zip', ShipPackageHeader."Ship-to Post Code");
        JsonObjectVar.Add('country', ShipPackageHeader."Ship-to Country/Region Code");
        JsonObjectVar.Add('phone', ShipPackageHeader."Ship-to Contact No.");
        JsonObjectVar.Add('mode', 'test');
        JsonObjectVar.Add('carrier_facility', NULL);
        JsonObjectVar.Add('residential', NULL);
        JsonObjectVar.Add('email', ShipPackageHeader."Ship-to Email");
        MasterJson.Add('to_address', JsonObjectVar);
        //Clear(MasterJson);
    end;

    local procedure SetShippingFromAddress(Location: Record Location)
    var
        JsonObjectVar: JsonObject;
        PackingModuleSetup: Record "Packing Module Setup";
    begin
        PackingModuleSetup.Get();
        Clear(JsonObjectVar);
        JsonObjectVar.Add('name', Location."Name");
        JsonObjectVar.Add('company', '');
        JsonObjectVar.Add('street1', Location."Address");
        JsonObjectVar.Add('street2', Location."Address 2");
        JsonObjectVar.Add('city', Location."City");
        JsonObjectVar.Add('state', Location."County");
        JsonObjectVar.Add('zip', Location."Post Code");
        JsonObjectVar.Add('country', Location."Country/Region Code");
        JsonObjectVar.Add('phone', Location."Phone No.");
        JsonObjectVar.Add('email', Location."E-Mail");
        if PackingModuleSetup."Mode Test" = true then
            JsonObjectVar.Add('mode', 'test')
        else
            JsonObjectVar.Add('mode', 'production');
        JsonObjectVar.Add('carrier_facility', '');
        JsonObjectVar.Add('residential', '');
        MasterJson.Add('from_address', JsonObjectVar);
        //Clear(MasterJson);
    end;

    local procedure ParcelInfo(palletBoxMaster: Record "Pallet/Box Master")
    var
        JsonObjectVar: JsonObject;
    begin
        Clear(JsonObjectVar);
        JsonObjectVar.Add('length', palletBoxMaster.L);
        JsonObjectVar.Add('width', palletBoxMaster.W);
        JsonObjectVar.Add('height', palletBoxMaster.H);
        //  JsonObjectVar.Add('predefined_package', 'null');
        JsonObjectVar.Add('weight', palletBoxMaster."Weight of Pallet/BoX");
        MasterJson.Add('parcel', JsonObjectVar);
        // Clear(MasterJson);
    end;

    local procedure Custom_info(ShipPackageLines: Record "Ship Packing Lines")
    var
        JsonObjectVar: JsonObject;
        shipPackageheader: Record "Ship Package Header";
    begin
        Clear(JsonObjectVar);
        JsonObjectVar.Add('contents_explanation', '');
        JsonObjectVar.Add('contents_type', 'merchandise');
        JsonObjectVar.Add('customs_certify', false);
        JsonObjectVar.Add('customs_signer', '');
        JsonObjectVar.Add('eel_pfc', '');
        JsonObjectVar.Add('non_delivery_option', 'return');
        JsonObjectVar.Add('restriction_comments', '');
        JsonObjectVar.Add('restriction_type', 'none');
        Custom_items(JsonObjectVar, ShipPackageLines, shipPackageheader);
        MasterJson.Add('customs_info', JsonObjectVar);
        //Clear(MasterJson);
    end;

    local procedure Custom_items(var JsonObjectVar: JsonObject;
    ShipPackageLines: Record "Ship Packing Lines";
    ShipPackageHeader: Record "Ship Package Header")
    var
        Location: Record Location;
    begin
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange(No, Rec."No");
        if ShipPackageHeader.FindFirst() then;
        "Pallet/Box master".Get(ShipPackageLines."Packing type");
        Location.Get(ShipPackageHeader.Location);
        Clear(ChildJeson);
        Clear(ChildJesonArray);
        ChildJeson.Add('description', 'Many, many EasyPost stickers.');
        ChildJeson.Add('hs_tariff_number', '12356');
        ChildJeson.Add('origin_country', Location."Country/Region Code");
        ChildJeson.Add('quantity', ShipPackageLines."Packed Qty");
        ChildJeson.Add('value', 879);
        ChildJeson.Add('weight', "Pallet/Box master"."Weight of Pallet/BoX");
        ChildJesonArray.Add(ChildJeson);
        JsonObjectVar.Add('customs_items', ChildJesonArray);
        //Clear(ChildJeson);
    end;

    local procedure AddLinestoJson(NFCClass: Enum nmfcClass;
                                                 ServicePackageCode: Enum "YRC Package Code";
                                                 jArray: JsonArray;
                                                 Shippackingline: record "Ship Packing Lines")
    var
        jObject: JsonObject;
        palletboxmaster: Record "Pallet/Box Master";
        NFCClassDec: Decimal;
    begin
        palletboxmaster.Get(Shippackingline."Packing type");
        Evaluate(NFCClassDec, Format(NFCClass));
        jObject.Add('nmfcClass', NFCClassDec);
        jObject.Add('handlingUnits', ShipPackingLine."Packed Qty");
        jObject.Add('packageCode', format(ServicePackageCode));
        jObject.Add('packageLength', palletboxmaster.L);
        jObject.Add('packageWidth', palletboxmaster.W);
        jObject.Add('packageHeight', palletboxmaster.H);
        jObject.Add('weight', palletboxmaster."Weight of Pallet/BoX");
        jArray.Add(jObject);
    end;

    trigger OnAfterGetRecord()
    var
    begin
        if (Rec.Carrier <> '') and (Rec.Service <> '') then
            edit := false
        else
            edit := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Noseries: Codeunit NoSeriesManagement;
        packingModuleSetup: Record "Packing Module Setup";
    begin
        packingModuleSetup.Get();
        // Message('insert');
        if Rec.No = '' then Rec.No := Noseries.GetNextNo(packingModuleSetup."Packing Nos", 0D, true);
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
            end;
        if Rec."Use 3rd Party Shipping Account" = false then
            EditThirdPartyDetails := false
        else
            if (Rec."3rd Party Account No." = '') and (Rec."3rd Party Account Zip" = '') and (Rec."3rd Party country" = '') and (Rec."3rd Party Carrier" = '') then
                EditThirdPartyDetails := true
            else
                EditThirdPartyDetails := false
    end;

    procedure GenerateBrcodeAndLotAssignAndPrint(ShipPackageHeader: Record "Ship Package Header")
    var
        SubpackingLines: Record "Sub Packing Lines";
        SIEventMngt: Codeunit "SI Event Mgnt";
    begin
        SubpackingLines.Reset();
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", ShipPackageHeader.No);
        if SubpackingLines.FindFirst() then begin
            SIEventMngt.BoxSequence(SubpackingLines);
            Commit();
        end;
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", ShipPackageHeader."No");
        if SubpackingLines.FindFirst() then begin
            repeat
                SIEventMngt.GetBarcode(SubpackingLines);
                Commit();
            until SubpackingLines.Next() = 0;
        end;
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", ShipPackageHeader."No");
        if SubpackingLines.FindFirst() then begin
            SIEventMngt.UnpostedBOXWiseLOTAssignment(SubpackingLines);
            Commit();
        end;

        SubpackingLines.Reset();
        SubpackingLines.SetRange("Packing Type", SubpackingLines."Packing Type"::Box);
        SubpackingLines.SetRange("Packing No.", ShipPackageHeader."No");
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
        edit: Boolean;
        RLMessage: text;
        GrandMasterJson: JsonObject;
        MasterJson: JsonObject;
        JsonArrayVar: JsonArray;
        ChildJeson: JsonObject;
        ChildJesonArray: JsonArray;
        "Pallet/Box master": Record "Pallet/Box Master";
        NULL: Text;
        Location: Record Location;
        ShiptoEdit: Boolean;
        ConfirmationTxt: Label 'Shipping Labels for Box ID/s %1 NOT purchased yet.  Do you want to print this Packing List/Delivery Note?';

        EditThirdPartyDetails: Boolean;
}
