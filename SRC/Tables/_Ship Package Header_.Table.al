table 55003 "Ship Package Header"
{
    Caption = 'Ship Package Header';
    DataClassification = ToBeClassified;

    fields
    {
        field(13; No; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'No.';
        }
        field(1; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                ShipPackageLines: Record "Ship Packing Lines";
                ShipPackageLinesLast: Record "Ship Packing Lines";
                SalesLine: Record "Sales Line";
                SalesLine1: Record "Sales Line";
                SalesHeader: Record "Sales Header";
                ItemNo: Code[20];
                TotalQty: Decimal;
                Customer: Record Customer;
                shiptoaddress: Record "Ship-to Address";
                PackInLines: Record "Pack In Lines";
                OutS: OutStream;
                Ins: InStream;
                tempblob: Codeunit "Temp Blob";
                ShippingAgentService: Record "Shipping Agent Services";
                ShippackageHeader: Page "Ship Package Header";
                Item: Record Item;
                ShippingMarkup: Record "Shipping MarkUp Setup";
            begin
                // packingModuleSetup.Get();
                // Commit();
                Rec."PickUp Date" := Today;
                SalesHeader.reset();
                SalesHeader.SetRange("No.", Rec."Document No.");
                SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Quote);
                if SalesHeader.FindFirst() then begin
                    //SN+
                    Rec."Ship-to Address" := SalesHeader."Ship-to Address";
                    Rec."Ship-to Address 2" := SalesHeader."Ship-to Address 2";
                    Rec."Ship-to City" := SalesHeader."Ship-to City";
                    Rec."Ship-to Contact" := SalesHeader."Ship-to Contact";
                    Rec."Ship-to Country/Region Code" := SalesHeader."Ship-to Country/Region Code";
                    Rec."Ship-to County" := SalesHeader."Ship-to County";
                    Rec."Ship-to Name" := SalesHeader."Ship-to Name";
                    Rec."Ship-to Name 2" := SalesHeader."Ship-to Name 2";
                    Rec."Ship-to Post Code" := SalesHeader."Ship-to Post Code";
                    Rec."Ship-to Customer No." := SalesHeader."Sell-to Customer No.";
                    Rec."Customer PO No" := SalesHeader."Your Reference";
                    if SalesHeader."Ship-to Code" <> '' then begin
                        shiptoaddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code");
                        Rec."Ship-to Contact No." := shiptoaddress."Phone No.";
                        if shiptoaddress."E-Mail" <> '' then
                            Rec."Ship-to Email" := shiptoaddress."E-Mail"
                        else
                            Rec."Ship-to Email" := SalesHeader."Sell-to E-Mail";
                    end

                    else begin
                        Customer.get(SalesHeader."Sell-to Customer No.");
                        Rec."Ship-to Contact No." := Customer."Phone No.";
                        if salesHeader."Sell-to E-Mail" <> '' then
                            Rec."Ship-to Email" := SalesHeader."Sell-to E-Mail"
                        else
                            Rec."Ship-to Email" := Customer."E-Mail";
                    end;
                    // Customer.get(Rec."Ship-to Customer No.");
                    // Rec."Shipping rate for Customer" := Customer."Shipping Rate for Customer";
                    Customer.get(SalesHeader."Sell-to Customer No.");
                    if Customer."Tracking Email Id" <> '' then Rec."Ship-to Email" += ';' + Customer."Tracking Email Id";
                    Rec."Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
                    Rec."Bill-to Address" := SalesHeader."Bill-to Address";
                    Rec."Bill-to Address 2" := SalesHeader."Bill-to Address 2";
                    Rec."Bill-to City" := SalesHeader."Bill-to City";
                    Rec."Bill-to Contact" := SalesHeader."Bill-to Contact";
                    Rec."Bill-to Country/Region Code" := SalesHeader."Bill-to Country/Region Code";
                    Rec."Bill-to County" := SalesHeader."Bill-to County";
                    Rec."Bill-to Name" := SalesHeader."Bill-to Name";
                    Rec."Bill-to Name 2" := SalesHeader."Bill-to Name 2";
                    Rec."Bill-to Post Code" := SalesHeader."Bill-to Post Code";
                    Rec."Bill-to Contact No." := SalesHeader."Bill-to Contact No.";
                    Rec.Location := SalesHeader."Location Code";
                    Rec."Web Order No" := SalesHeader."BigCommerce ID";
                    Rec.Validate("Existing Shipping Rate on SO/SQ", SalesHeader."SI Total Shipping Rate");
                    Rec.Agent := SalesHeader."Shipping Agent Code";
                    if ShippingAgentService.Get(SalesHeader."Shipping Agent Code", SalesHeader."Shipping Agent Service Code") then
                        Rec.Validate("Agent Service", ShippingAgentService."SI Get Rate Service")
                    else
                        Rec.Validate("Agent Service", '');
                    //SN-
                    Clear(ItemNo);
                    SalesLine.Reset();
                    SalesLine.SetCurrentKey("No.");
                    SalesLine.SetRange("Document No.", Rec."Document No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    if SalesLine.FindSet() then begin
                        repeat
                            ShipPackageLinesLast.Reset();
                            ShipPackageLinesLast.SetRange("No.", Rec.No);
                            if ShipPackageLinesLast.FindLast() then;
                            ShipPackageLines.Init();
                            ShipPackageLines.Validate("No.", No);
                            ShipPackageLines.Validate("Line No.", SalesLine."Line No.");
                            ShipPackageLines.Validate("Item No.", SalesLine."No.");
                            Item.Get(ShipPackageLines."Item No.");
                            if Item."SI Box Code of Item" = '' then Error('Box/Pallet Id must have a value in Item %1', Item."No.");
                            ShipPackageLines.Validate(Description, SalesLine.Description);
                            ShipPackageLines.Validate(Quantity, SalesLine.Quantity);
                            ShipPackageLines.Validate("Total Qty", SalesLine.Quantity);
                            ShipPackageLines.Validate("SalesLine No.", SalesLine."Line No.");
                            ShipPackageLines.Validate("Sales UOM", SalesLine."Unit of Measure Code");
                            ShipPackageLines.Validate("Bin Code", SalesLine."Bin Code");
                            ShipPackageLines.Insert();
                        until SalesLine.Next() = 0;
                    end;
                    Rec.Validate(Class, Rec.Class::"65.0");
                    Rec.Validate("Service Class", Rec."Service Class"::ALL);
                    Rec.Validate("Service Package Code", rec."Service Package Code"::"PLT (pallet)");
                    Rec."Work Description" := SalesHeader.GetWorkDescription();
                    AddressVerify(Rec);
                    ShippackageHeader.Activate(true);
                    Rec.validate(Insurance, GetInsuranceAmount(Rec));
                    SIEventMgnt.GetAgentServiceOptions(Rec);
                    if ShippingMarkup.Get(SalesHeader."Sell-to Customer No.") then begin
                        Rec."Shipping rate for Customer" := ShippingMarkup."Add Shipping Cost to Invoice";
                        if (ShippingMarkup."Customer Shipping Carrier" <> '') and (ShippingMarkup."Customer Shipping Carrier Acc." <> '') and (ShippingMarkup."Customer Shipping Carrier Zip" <> '') and (ShippingMarkup."Customer Ship. Carrier Country" <> '') then begin
                            Rec."Use 3rd Party Shipping Account" := true;
                            Rec.Validate("3rd Party Carrier", ShippingMarkup."Customer Shipping Carrier");
                            Rec.Validate("3rd Party Account No.", ShippingMarkup."Customer Shipping Carrier Acc.");
                            Rec.Validate("3rd Party Account Zip", ShippingMarkup."Customer Shipping Carrier Zip");
                            Rec.Validate("3rd Party country", ShippingMarkup."Customer Ship. Carrier Country");
                        end
                    end
                    else begin
                        if ShippingMarkup.Get() then begin
                            Rec."Shipping rate for Customer" := ShippingMarkup."Add Shipping Cost to Invoice";
                            if (ShippingMarkup."Customer Shipping Carrier" <> '') and (ShippingMarkup."Customer Shipping Carrier Acc." <> '') and (ShippingMarkup."Customer Shipping Carrier Zip" <> '') and (ShippingMarkup."Customer Ship. Carrier Country" <> '') then begin
                                Rec."Use 3rd Party Shipping Account" := true;
                                Rec.Validate("3rd Party Carrier", ShippingMarkup."Customer Shipping Carrier");
                                Rec.Validate("3rd Party Account No.", ShippingMarkup."Customer Shipping Carrier Acc.");
                                Rec.Validate("3rd Party Account Zip", ShippingMarkup."Customer Shipping Carrier Zip");
                                Rec.Validate("3rd Party country", ShippingMarkup."Customer Ship. Carrier Country");
                            end
                        end;
                    end;
                end;
            end;
        }
        field(2; Location; Code[20])
        {
            Caption = 'Location';
            DataClassification = ToBeClassified;
        }
        field(3; "Close All Boxs"; Boolean)
        {
            Caption = 'Close All Boxes';
            CalcFormula = lookup("Pack In"."Close All Boxs" where("Packing No." = field(No), "Packing Type" = filter(Box)));
            FieldClass = FlowField;
        }
        field(4; "Close All Pallets"; Boolean)
        {
            Caption = 'Close All Pallets';
            FieldClass = FlowField;
            CalcFormula = lookup("Pack In"."Close All Pallets" where("Packing No." = field(No), "Packing Type" = filter(Pallet)));
        }
        field(5; "PickUp Date"; Date)
        {
            Caption = 'Pickup Date';
            DataClassification = ToBeClassified;
        }
        field(6; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = ToBeClassified;
        }
        field(7; "Bill-to Name"; Text[100])
        {
            Caption = 'Bill-to Name';
            DataClassification = ToBeClassified;
        }
        field(8; "Bill-to Name 2"; Text[50])
        {
            Caption = 'Bill-to Name 2';
            DataClassification = ToBeClassified;
        }
        field(9; "Bill-to Address"; Text[100])
        {
            Caption = 'Bill-to Address';
            DataClassification = ToBeClassified;
        }
        field(10; "Bill-to Address 2"; Text[50])
        {
            Caption = 'Bill-to Address 2';
            DataClassification = ToBeClassified;
        }
        field(11; "Bill-to City"; Text[30])
        {
            Caption = 'Bill-to City';
            DataClassification = ToBeClassified;
        }
        field(12; "Bill-to Contact"; Text[100])
        {
            Caption = 'Bill-to Contact';
            DataClassification = ToBeClassified;
        }
        field(15; "Bill-to Contact No."; Code[20])
        {
            Caption = 'Bill-to Contact No.';
            DataClassification = ToBeClassified;
        }
        field(17; "Bill-to Post Code"; Code[20])
        {
            Caption = 'Bill-to Post Code';
            DataClassification = ToBeClassified;
        }
        field(18; "Bill-to County"; Text[30])
        {
            Caption = 'Bill-to County';
            DataClassification = ToBeClassified;
        }
        field(19; "Bill-to Country/Region Code"; Code[10])
        {
            Caption = 'Bill-to Country/Region Code';
            DataClassification = ToBeClassified;
        }
        field(21; "Ship-to Customer No."; Code[20])
        {
            Caption = 'Ship-to Customer No.';
            DataClassification = ToBeClassified;
        }
        field(22; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                salesHeader: Record "Sales Header";
            begin
                salesHeader.Reset();
                salesHeader.SetRange("No.", Rec."Document No.");
                if salesHeader.FindFirst() then begin
                    //    if Rec."Ship-to Name" <> '' then begin
                    if salesHeader."Ship-to Name" <> Rec."Ship-to Name" then begin
                        salesHeader.Validate("Ship-to Name", Rec."Ship-to Name");
                        salesHeader.Modify();
                    end;
                    //  end;
                end;
            end;
        }
        field(23; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Ship-to Name 2';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                salesHeader: Record "Sales Header";
            begin
                salesHeader.Reset();
                salesHeader.SetRange("No.", Rec."Document No.");
                if salesHeader.FindFirst() then begin
                    //    if Rec."Ship-to Name 2" <> '' then begin
                    if salesHeader."Ship-to Name 2" <> Rec."Ship-to Name 2" then begin
                        salesHeader.Validate("Ship-to Name 2", Rec."Ship-to Name 2");
                        salesHeader.Modify();
                    end;
                    //  end;
                end;
            end;
        }
        field(24; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                salesHeader: Record "Sales Header";
            begin
                salesHeader.Reset();
                salesHeader.SetRange("No.", Rec."Document No.");
                if salesHeader.FindFirst() then begin
                    //  if Rec."Ship-to Address" <> '' then begin
                    if salesHeader."Ship-to Address" <> Rec."Ship-to Address" then begin
                        salesHeader.Validate("Ship-to Address", Rec."Ship-to Address");
                        salesHeader.Modify();
                    end;
                    // end;
                end;
            end;
        }
        field(25; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                salesHeader: Record "Sales Header";
            begin
                salesHeader.Reset();
                salesHeader.SetRange("No.", Rec."Document No.");
                if salesHeader.FindFirst() then begin
                    // if Rec."Ship-to Address 2" <> '' then begin
                    if salesHeader."Ship-to Address 2" <> Rec."Ship-to Address 2" then begin
                        salesHeader.Validate("Ship-to Address 2", Rec."Ship-to Address 2");
                        salesHeader.Modify();
                    end;
                    // end;
                end;
            end;
        }
        field(26; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                salesHeader: Record "Sales Header";
            begin
                salesHeader.Reset();
                salesHeader.SetRange("No.", Rec."Document No.");
                if salesHeader.FindFirst() then begin
                    // if Rec."Ship-to city" <> '' then begin
                    if salesHeader."Ship-to city" <> Rec."Ship-to city" then begin
                        salesHeader.Validate("Ship-to city", Rec."Ship-to city");
                        salesHeader.Modify();
                    end;
                    // end;
                end;
            end;
        }
        field(27; "Ship-to Contact"; Text[100])
        {
            Caption = 'Ship-to Contact';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                salesHeader: Record "Sales Header";
            begin
                salesHeader.Reset();
                salesHeader.SetRange("No.", Rec."Document No.");
                if salesHeader.FindFirst() then begin
                    //  if Rec."Ship-to Contact" <> '' then begin
                    if salesHeader."Ship-to Contact" <> Rec."Ship-to Contact" then begin
                        salesHeader.Validate("Ship-to Contact", Rec."Ship-to Contact");
                        salesHeader.Modify();
                    end;
                    //   end;
                end;
            end;
        }
        field(29; "Ship-to Contact No."; Code[20])
        {
            Caption = 'Ship-to Contact No.';
            DataClassification = ToBeClassified;
        }
        field(31; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to Post Code';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                salesHeader: Record "Sales Header";
            begin
                salesHeader.Reset();
                salesHeader.SetRange("No.", Rec."Document No.");
                if salesHeader.FindFirst() then begin
                    //  if Rec."Ship-to Post Code" <> '' then begin
                    if salesHeader."Ship-to Post Code" <> Rec."Ship-to Post Code" then begin
                        salesHeader.Validate("Ship-to Post Code", Rec."Ship-to Post Code");
                        salesHeader.Modify();
                    end;
                    //  end;
                end;
            end;
        }
        field(32; "Ship-to County"; Text[30])
        {
            Caption = 'Ship-to State';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                salesHeader: Record "Sales Header";
            begin
                salesHeader.Reset();
                salesHeader.SetRange("No.", Rec."Document No.");
                if salesHeader.FindFirst() then begin
                    //if Rec."Ship-to County" <> '' then begin
                    if salesHeader."Ship-to County" <> Rec."Ship-to County" then begin
                        salesHeader.Validate("Ship-to County", Rec."Ship-to County");
                        salesHeader.Modify();
                    end;
                    //  end;
                end;
            end;
        }
        field(33; "Ship-to Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                salesHeader: Record "Sales Header";
            begin
                salesHeader.Reset();
                salesHeader.SetRange("No.", Rec."Document No.");
                if salesHeader.FindFirst() then begin
                    // if Rec."Ship-to Country/Region Code" <> '' then begin
                    if salesHeader."Ship-to Country/Region Code" <> Rec."Ship-to Country/Region Code" then begin
                        salesHeader.Validate("Ship-to Country/Region Code", Rec."Ship-to Country/Region Code");
                        salesHeader.Modify();
                    end;
                    //  end;
                end;
            end;
        }
        field(65; "Ship-to Email"; Code[500])
        {
            Caption = 'Ship-to Email';
            DataClassification = ToBeClassified;
        }
        field(35; "Total Packages"; Integer)
        {
            Caption = 'Total Packages';
            DataClassification = ToBeClassified;
        }
        field(36; "COD Amount"; Decimal)
        {
            Caption = 'COD Amount';
            DataClassification = ToBeClassified;
        }
        field(37; "Inside Delivery"; Boolean)
        {
            Caption = 'Inside Delivery';
            DataClassification = ToBeClassified;
        }
        field(38; "Residential Pickup"; Boolean)
        {
            Caption = 'Residential Pickup';
            DataClassification = ToBeClassified;
        }
        field(39; "Residential Delivery"; Boolean)
        {
            Caption = 'Residential Delivery';
            DataClassification = ToBeClassified;
        }
        field(40; "Origin Lift gate"; Boolean)
        {
            Caption = 'Origin Lift gate';
            DataClassification = ToBeClassified;
        }
        field(41; "Destination Lift gate"; Boolean)
        {
            Caption = 'Destination Lift gate';
            DataClassification = ToBeClassified;
        }
        field(42; "Delivery Notification"; Boolean)
        {
            Caption = 'Delivery Notification';
            DataClassification = ToBeClassified;
        }
        field(43; "Sort And Segregate"; Boolean)
        {
            Caption = 'Sort And Segregate';
            DataClassification = ToBeClassified;
        }
        field(44; Freezable; Boolean)
        {
            Caption = 'Freezable ';
            DataClassification = ToBeClassified;
        }
        field(45; Hazmat; Boolean)
        {
            Caption = 'Hazmat  ';
            DataClassification = ToBeClassified;
        }
        field(46; "Inside Pickup"; Boolean)
        {
            Caption = 'Inside Pickup   ';
            DataClassification = ToBeClassified;
        }
        field(47; "Limited Access Pickup"; Boolean)
        {
            Caption = 'Limited Access Pickup    ';
            DataClassification = ToBeClassified;
        }
        field(48; "Dock Pickup"; Boolean)
        {
            Caption = 'Dock Pickup     ';
            DataClassification = ToBeClassified;
        }
        field(49; "Dock Delivery"; Boolean)
        {
            Caption = 'Dock Delivery      ';
            DataClassification = ToBeClassified;
        }
        field(50; "Airport Pickup"; Boolean)
        {
            Caption = 'Airport Pickup';
            DataClassification = ToBeClassified;
        }
        field(51; "Airpor tDelivery"; Boolean)
        {
            Caption = 'Airport Delivery';
            DataClassification = ToBeClassified;
        }
        field(52; "Limited Access Delivery"; Boolean)
        {
            Caption = 'Limited Access Delivery';
            DataClassification = ToBeClassified;
        }
        field(53; "Cubic Feet"; Boolean)
        {
            Caption = 'Cubic Feet';
            DataClassification = ToBeClassified;
        }
        field(54; "Keep From Freezing"; Boolean)
        {
            Caption = 'Keep From Freezing';
            DataClassification = ToBeClassified;
        }
        field(55; "Door To Door"; Boolean)
        {
            Caption = 'Door To Door';
            DataClassification = ToBeClassified;
        }
        field(56; COD; Boolean)
        {
            Caption = 'COD';
            DataClassification = ToBeClassified;
        }
        field(57; "Over Dimension"; Boolean)
        {
            Caption = 'Over Dimension';
            DataClassification = ToBeClassified;
        }
        field(58; "Service Option"; Enum "YRC Service Option")
        {
            Caption = 'Service Option';
            DataClassification = ToBeClassified;
        }
        field(59; "Service Class"; Enum "YRC Service Class")
        {
            Caption = 'Service Class';
            DataClassification = ToBeClassified;
        }
        field(60; "Service Package Code"; Enum "YRC Package Code")
        {
            Caption = 'Service Package Code';
            DataClassification = ToBeClassified;
        }
        field(61; "NMFC Class"; Enum nmfcClass)
        {
            Caption = 'NMFC Class';
            DataClassification = ToBeClassified;
        }
        field(62; "Class"; Enum Class)
        {
            Caption = 'Class';
            DataClassification = ToBeClassified;
        }
        field(63; "YRC Discount Percentage"; Decimal)
        {
            Caption = 'YRC Discount Percentage';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Rec."YRC Discount Percentage" > 100 then Rec.FieldError("YRC Discount Percentage", 'Cannot be greater than 100%');
            end;
        }
        field(64; "RL Message"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(66; "Markup value"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(67; "Freight Value"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(68; "Carrier"; text[100])
        {
            Caption = 'Ship Pkg. Carrier';
            DataClassification = ToBeClassified;
        }
        field(69; "Service"; Text[100])
        {
            Caption = 'Ship Pkg. Service';
            DataClassification = ToBeClassified;
        }
        field(70; "Confirm Quote No"; text[500])
        {
            DataClassification = ToBeClassified;
        }
        field(71; "Ship-to Company"; text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(72; "Tracking Code"; text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(73; "Zip Message"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(74; "Delivery Message"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(75; "Suggested Addr"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(76; "Suggested Addr 2"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(77; "Suggested City"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(78; "Suggested State"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(79; "Suggested Post Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Suggested Country Code"; code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(81; "Suggested Address"; Text[300])
        {
            DataClassification = ToBeClassified;
        }
        field(82; "Update Suggested Addr"; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Rec."Update Suggested Addr" = true then begin
                    if (rec."Suggested Addr" <> '') and (Rec."Ship-to Address" <> Rec."Suggested Addr") then Rec.Validate("Ship-to Address", "Suggested Addr");
                    if (rec."Suggested Addr 2" <> '') and (Rec."Ship-to Address 2" <> Rec."Suggested Addr 2") then Rec.Validate("Ship-to Address 2", "Suggested Addr 2");
                    if (rec."Suggested city" <> '') and (Rec."Ship-to city" <> Rec."Suggested city") then Rec.Validate("Ship-to city", "Suggested city");
                    if (rec."Suggested state" <> '') and (Rec."Ship-to county" <> Rec."Suggested State") then Rec.Validate("Ship-to County", "Suggested State");
                    if (rec."Suggested post Code" <> '') and (Rec."Ship-to Post Code" <> Rec."Suggested Post Code") then Rec.Validate("Ship-to Post Code", "Suggested Post Code");
                    if (rec."Suggested country Code" <> '') and (Rec."Ship-to country/region code" <> Rec."Suggested Country Code") then Rec.Validate("Ship-to Country/Region Code", "Suggested Country Code");
                end;
            end;
        }
        field(83; "Inventory Pick"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                ShipPackageLines: Record "Ship Packing Lines";
                ShipPackageLinesLast: Record "Ship Packing Lines";
                InventoryPickLines: Record "Warehouse Activity Line";
                SalesLine1: Record "Sales Line";
                SalesHeader: Record "Sales Header";
                ItemNo: Code[20];
                TotalQty: Decimal;
                Customer: Record Customer;
                shiptoaddress: Record "Ship-to Address";
                PackInLines: Record "Pack In Lines";
                InventoryPick: Record "Warehouse Activity Header";
                ShippingAgentService: Record "Shipping Agent Services";
                ShippackageHeader: Page "Ship Package Header";
                ShipHeader: Record "Ship Package Header";
                Item: Record Item;
                ShippingMarkup: Record "Shipping MarkUp Setup";
                AgentServiceOptions: Record "Agent Service Option";
            begin
                ShipHeader.reset();
                ShipHeader.SetRange("Inventory Pick", Rec."Inventory Pick");
                if not ShipHeader.FindFirst() then begin
                    packingModuleSetup.Get();
                    InventoryPick.Get(InventoryPick.Type::"Invt. Pick", Rec."Inventory Pick");
                    if InventoryPick."Source Document" = InventoryPick."Source Document"::"Sales Order" then begin
                        rec."Document No." := InventoryPick."Source No.";
                        Rec."PickUp Date" := Today;
                        //if SalesHeader.get(InventoryPick."Source No.", SalesHeader."Document Type"::Order) then begin
                        SalesHeader.reset();
                        SalesHeader.SetRange("No.", InventoryPick."Source No.");
                        SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Quote);
                        if SalesHeader.FindFirst() then begin
                            //SN+
                            Rec."Ship-to Address" := SalesHeader."Ship-to Address";
                            Rec."Ship-to Address 2" := SalesHeader."Ship-to Address 2";
                            Rec."Ship-to City" := SalesHeader."Ship-to City";
                            Rec."Ship-to Contact" := SalesHeader."Ship-to Contact";
                            Rec."Ship-to Country/Region Code" := SalesHeader."Ship-to Country/Region Code";
                            Rec."Ship-to County" := SalesHeader."Ship-to County";
                            Rec."Ship-to Name" := SalesHeader."Ship-to Name";
                            Rec."Ship-to Name 2" := SalesHeader."Ship-to Name 2";
                            Rec."Ship-to Post Code" := SalesHeader."Ship-to Post Code";
                            Rec."Ship-to Customer No." := SalesHeader."Sell-to Customer No.";
                            Rec."Customer PO No" := SalesHeader."Your Reference";
                            if SalesHeader."Ship-to Code" <> '' then begin
                                shiptoaddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code");
                                Rec."Ship-to Contact No." := shiptoaddress."Phone No.";
                                if shiptoaddress."E-Mail" <> '' then
                                    Rec."Ship-to Email" := shiptoaddress."E-Mail"
                                else
                                    Rec."Ship-to Email" := SalesHeader."Sell-to E-Mail";
                            end
                            else begin
                                Customer.get(SalesHeader."Sell-to Customer No.");
                                Rec."Ship-to Contact No." := Customer."Phone No.";
                                if salesHeader."Sell-to E-Mail" <> '' then
                                    Rec."Ship-to Email" := SalesHeader."Sell-to E-Mail"
                                else
                                    Rec."Ship-to Email" := Customer."E-Mail";
                            end;
                            Customer.get(SalesHeader."Sell-to Customer No.");
                            if Customer."Tracking Email Id" <> '' then Rec."Ship-to Email" += ';' + Customer."Tracking Email Id";
                            Rec."Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
                            Rec."Bill-to Address" := SalesHeader."Bill-to Address";
                            Rec."Bill-to Address 2" := SalesHeader."Bill-to Address 2";
                            Rec."Bill-to City" := SalesHeader."Bill-to City";
                            Rec."Bill-to Contact" := SalesHeader."Bill-to Contact";
                            Rec."Bill-to Country/Region Code" := SalesHeader."Bill-to Country/Region Code";
                            Rec."Bill-to County" := SalesHeader."Bill-to County";
                            Rec."Bill-to Name" := SalesHeader."Bill-to Name";
                            Rec."Bill-to Name 2" := SalesHeader."Bill-to Name 2";
                            Rec."Bill-to Post Code" := SalesHeader."Bill-to Post Code";
                            Rec."Bill-to Contact No." := SalesHeader."Bill-to Contact No.";
                            Rec.Location := InventoryPick."Location Code";
                            Rec."Web Order No" := SalesHeader."BigCommerce ID";
                            Rec.Validate("Existing Shipping Rate on SO/SQ", SalesHeader."SI Total Shipping Rate");
                            if Rec.Location = '' then Rec.Location := SalesHeader."Location Code";
                            Rec.Agent := SalesHeader."Shipping Agent Code";
                            if ShippingAgentService.Get(SalesHeader."Shipping Agent Code", SalesHeader."Shipping Agent Service Code") then
                                Rec.validate("Agent Service", ShippingAgentService."SI Get Rate Service")
                            else
                                Rec.Validate("Agent Service", '');
                            Rec."Work Description" := SalesHeader.GetWorkDescription();
                            //SN-
                            Clear(ItemNo);
                            InventoryPickLines.Reset();
                            InventoryPickLines.SetCurrentKey("No.");
                            InventoryPickLines.SetRange("No.", Rec."Inventory Pick");
                            InventoryPickLines.SetRange("Activity Type", InventoryPickLines."Activity Type"::"Invt. Pick");
                            //  InventoryPickLines.SetRange(Type, SalesLine.Type::Item);
                            if InventoryPickLines.FindSet() then begin
                                repeat
                                    ShipPackageLinesLast.Reset();
                                    ShipPackageLinesLast.SetRange("No.", Rec.No);
                                    if ShipPackageLinesLast.FindLast() then;
                                    ShipPackageLines.Init();
                                    ShipPackageLines.Validate("No.", No);
                                    ShipPackageLines.Validate("Line No.", InventoryPickLines."Line No.");
                                    ShipPackageLines.Validate("Item No.", InventoryPickLines."Item No.");
                                    Item.Get(ShipPackageLines."Item No.");
                                    if Item."SI Box Code of Item" = '' then Error('Box/Pallet Id must have a value in Item %1', Item."No.");
                                    ShipPackageLines.Validate(Description, InventoryPickLines.Description);
                                    ShipPackageLines.Validate(Quantity, InventoryPickLines."Qty. to Handle");
                                    ShipPackageLines.Validate("Total Qty", InventoryPickLines.Quantity);
                                    ShipPackageLines.Validate("SalesLine No.", InventoryPickLines."Line No.");
                                    ShipPackageLines.Validate("Sales UOM", InventoryPickLines."Unit of Measure Code");
                                    ShipPackageLines.Validate("Bin Code", InventoryPickLines."Bin Code");
                                    ShipPackageLines.Validate(SourceLineNo, InventoryPickLines."Source Line No.");
                                    ShipPackageLines.Validate("Lot No.", InventoryPickLines."Lot No.");
                                    ShipPackageLines.Insert();
                                until InventoryPickLines.Next() = 0;
                            end;
                            Rec.Validate(Class, Rec.Class::"65.0");
                            AddressVerify(Rec);
                            ShippackageHeader.Activate(true);
                            rec.Validate(Insurance, GetInsuranceAmount(Rec));
                            // Rec.Modify();
                            SIEventMgnt.GetAgentServiceOptions(Rec);
                            if ShippingMarkup.Get(SalesHeader."Sell-to Customer No.") then begin
                                Rec."Shipping rate for Customer" := ShippingMarkup."Add Shipping Cost to Invoice";
                                if (ShippingMarkup."Customer Shipping Carrier" <> '') and (ShippingMarkup."Customer Shipping Carrier Acc." <> '') and (ShippingMarkup."Customer Shipping Carrier Zip" <> '') and (ShippingMarkup."Customer Ship. Carrier Country" <> '') then begin
                                    Rec."Use 3rd Party Shipping Account" := true;
                                    Rec.Validate("3rd Party Carrier", ShippingMarkup."Customer Shipping Carrier");
                                    Rec.Validate("3rd Party Account No.", ShippingMarkup."Customer Shipping Carrier Acc.");
                                    Rec.Validate("3rd Party Account Zip", ShippingMarkup."Customer Shipping Carrier Zip");
                                    Rec.Validate("3rd Party country", ShippingMarkup."Customer Ship. Carrier Country");
                                end
                            end
                            else begin
                                if ShippingMarkup.Get() then begin
                                    Rec."Shipping rate for Customer" := ShippingMarkup."Add Shipping Cost to Invoice";
                                    if (ShippingMarkup."Customer Shipping Carrier" <> '') and (ShippingMarkup."Customer Shipping Carrier Acc." <> '') and (ShippingMarkup."Customer Shipping Carrier Zip" <> '') and (ShippingMarkup."Customer Ship. Carrier Country" <> '') then begin
                                        Rec."Use 3rd Party Shipping Account" := true;
                                        Rec.Validate("3rd Party Carrier", ShippingMarkup."Customer Shipping Carrier");
                                        Rec.Validate("3rd Party Account No.", ShippingMarkup."Customer Shipping Carrier Acc.");
                                        Rec.Validate("3rd Party Account Zip", ShippingMarkup."Customer Shipping Carrier Zip");
                                        Rec.Validate("3rd Party country", ShippingMarkup."Customer Ship. Carrier Country");
                                    end
                                end;
                            end;
                        end;
                    end;
                end
                else
                    Error('Ship Package for this inventory pick already exists.');
            end;
        }
        field(84; "Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(85; "Customer PO No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(89; "Shipment Refund Status"; Enum "Shipment Refund Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(90; "Additional Mark Up"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Rec.Validate("Total Shipping Rate for Customer", Rec."Total Shipping Rate for Customer" - xRec."Additional Mark Up" + Rec."Additional Mark Up");
                Rec.Modify(false);
            end;
        }
        field(91; "Total Shipping Rate for Customer"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Rec.Difference := 0;
                Rec.Difference := Abs(Rec."Total Shipping Rate for Customer" - Rec."Existing Shipping Rate on SO/SQ");
                Rec.Modify(false);
            end;
        }
        field(92; "Work Description"; text[2000])
        {
            DataClassification = ToBeClassified;
        }
        field(93; "Residential"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(94; "Agent"; Text[50])
        {
            Caption = 'Ship Agent from SO/SQ';
            DataClassification = ToBeClassified;
        }
        field(95; "Agent Service"; Text[50])
        {
            Caption = 'Ship Agent Service from SO/SQ';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Rec."Agent Service" = '' then
                    Rec."Get All Rates EasyPost" := true
                else
                    Rec."Get All Rates EasyPost" := false;
            end;
        }
        field(96; "Web Order No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(97; "Existing Shipping Rate on SO/SQ"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(98; Difference; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(99; "Shipping rate for Customer"; Boolean)
        {
            Caption = 'Add Shipping Cost to Invoice';
            DataClassification = ToBeClassified;
        }
        field(100; "Insurance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(101; "Box Markup value"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(102; "Pallet Markup value"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(103; "Get All Rates EasyPost"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(104; "Insurance Markup for Box"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(105; "Insurance Markup for Pallet"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(106; "total Gross Wt (All Items)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(107; "total Quantity (Packs)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(108; "Use Ship-to Adsress"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(109; "Use 3rd Party Shipping Account"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(110; "3rd Party Carrier"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(111; "3rd Party Account No."; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(112; "3rd Party Account Zip"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(113; "3rd Party country"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "No")
        {
            Clustered = true;
        }
    }
    local procedure AddressVerify(var ShipPackageHeader: Record "Ship Package Header")// begin
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
        ShipPackageHeader.Validate("Update Suggested Addr", false);
        ShipPackageHeader.Validate("Suggested Addr", '');
        ShipPackageHeader.Validate("Suggested Addr 2", '');
        ShipPackageHeader.Validate("Suggested city", '');
        ShipPackageHeader.Validate("Suggested state", '');
        ShipPackageHeader.Validate("Suggested post Code", '');
        ShipPackageHeader.Validate("Suggested Country Code", '');
        ShipPackageHeader.Validate("Suggested Address", '');
        PackingModuleSetUp.Get();
        JObject.Add('street1', ShipPackageHeader."Ship-to Address");
        JObject.Add('street2', ShipPackageHeader."Ship-to Address 2");
        JObject.Add('city', ShipPackageHeader."Ship-to city");
        JObject.Add('state', ShipPackageHeader."Ship-to county");
        JObject.Add('zip', ShipPackageHeader."Ship-to Post Code");
        JObject.Add('country', ShipPackageHeader."Ship-to Country/Region Code");
        JObject.Add('company', ShipPackageHeader."Ship-to Company");
        JObject.Add('name', ShipPackageHeader."Ship-to Name");
        //Message(format(JObject));
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
        //Message(responsetext);
        jsonbuffer.Reset();
        jsonbuffer.DeleteAll();
        jsonBuffertemt.ReadFromText(responsetext);
        IF jsonBuffertemt.FindSet() then begin
            repeat
                jsonbuffer := jsonBuffertemt;
                jsonbuffer.Insert();
            until jsonBuffertemt.Next() = 0;
        end;
        Clear(ShipPackageHeader."Zip Message");
        Zip4path := 'verifications.zip4.success';
        jsonbuffer.Reset();
        jsonbuffer.SetFilter(Path, Zip4path);
        jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::Boolean);
        if jsonbuffer.FindFirst() then begin
            if jsonbuffer.value = 'Yes' then begin
                ShipPackageHeader.validate("Zip Message", 'Success');
                // ShipPackageHeader.Modify();
            end
            else begin
                for i := 0 to 1 do begin
                    ZiperrorFieldPath := 'verifications.zip4.errors[' + Format(i) + '].field';
                    jsonbuffer.Reset();
                    jsonbuffer.SetFilter(Path, ZiperrorFieldPath);
                    jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::String);
                    if jsonbuffer.FindFirst() then ShipPackageHeader."Zip Message" += jsonbuffer.GetValue() + ' : ';
                    ZiperrorMsgPath := 'verifications.zip4.errors[' + Format(i) + '].message';
                    jsonbuffer.Reset();
                    jsonbuffer.SetFilter(Path, ZiperrorMsgPath);
                    jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::String);
                    if jsonbuffer.FindFirst() then ShipPackageHeader."Zip Message" += jsonbuffer.GetValue() + ' ; ';
                    i := i + 1;
                end;
            end;
        end;
        Clear(ShipPackageHeader."Delivery Message");
        DeliveryPath := 'verifications.delivery.success';
        jsonbuffer.Reset();
        jsonbuffer.SetFilter(Path, DeliveryPath);
        jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::Boolean);
        if jsonbuffer.FindFirst() then begin
            if jsonbuffer.value = 'Yes' then begin
                ShipPackageHeader.validate("Delivery Message", 'Success');
                //    ShipPackageHeader.Modify();
                // if Rec."Ship-to Address" = '' then begin
                jsonbuffer.Reset();
                jsonbuffer.SetRange(Path, 'street1');
                jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                if jsonbuffer.FindFirst() then begin
                    if jsonbuffer.GetValue() <> '' then begin
                        ShipPackageHeader.Validate("Suggested Addr", jsonbuffer.GetValue());
                        ShipPackageHeader."Suggested Address" += ShipPackageHeader."Suggested Addr" + ' ; ';
                    end;
                end;
                //if Rec."Ship-to Address 2" = '' then begin
                jsonbuffer.Reset();
                jsonbuffer.SetRange(Path, 'street2');
                jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                if jsonbuffer.FindFirst() then begin
                    if jsonbuffer.GetValue() <> '' then begin
                        ShipPackageHeader.Validate("Suggested Addr 2", jsonbuffer.GetValue());
                        ShipPackageHeader."Suggested Address" += ShipPackageHeader."Suggested Addr 2" + ' ; ';
                    END;
                end;
                //if Rec."Ship-to City" = '' then begin
                jsonbuffer.Reset();
                jsonbuffer.SetRange(Path, 'city');
                jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                if jsonbuffer.FindFirst() then begin
                    if jsonbuffer.GetValue() <> '' then begin
                        ShipPackageHeader.Validate("Suggested City", jsonbuffer.GetValue());
                        ShipPackageHeader."Suggested Address" += ShipPackageHeader."Suggested city" + ' ; ';
                    end;
                end;
                //if Rec."Ship-to County" = '' then begin
                jsonbuffer.Reset();
                jsonbuffer.SetRange(Path, 'state');
                jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                if jsonbuffer.FindFirst() then begin
                    if jsonbuffer.GetValue() <> '' then begin
                        ShipPackageHeader.Validate("Suggested state", jsonbuffer.GetValue());
                        ShipPackageHeader."Suggested Address" += ShipPackageHeader."Suggested State" + ' ; ';
                    end;
                end;
                //if Rec."Ship-to Post Code" = '' then begin
                jsonbuffer.Reset();
                jsonbuffer.SetRange(Path, 'zip');
                jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                if jsonbuffer.FindFirst() then begin
                    if jsonbuffer.GetValue() <> '' then begin
                        strposSuggPostCode := StrPos(jsonbuffer.GetValue(), '-');
                        if strposSuggPostCode <> 0 then
                            SuggPostCode := CopyStr(jsonbuffer.GetValue(), 1, strposSuggPostCode - 1)
                        else
                            SuggPostCode := jsonbuffer.GetValue();
                        ShipPackageHeader.Validate("Suggested Post Code", SuggPostCode);
                        ShipPackageHeader."Suggested Address" += ShipPackageHeader."Suggested Post Code" + ' ; ';
                    end;
                end;
                //if Rec."Ship-to Country/Region Code" = '' then begin
                jsonbuffer.Reset();
                jsonbuffer.SetRange(Path, 'country');
                jsonbuffer.SetRange("Token type", jsonbuffer."Token type"::String);
                if jsonbuffer.FindFirst() then begin
                    if jsonbuffer.GetValue() <> '' then begin
                        ShipPackageHeader.Validate("Suggested Country Code", jsonbuffer.GetValue());
                        ShipPackageHeader."Suggested Address" += ShipPackageHeader."Suggested Country Code" + ' ; ';
                    END;
                end;
            end
            else begin
                for i := 0 to 1 do begin
                    deliveryerrorFieldpath := 'verifications.delivery.errors[' + Format(i) + '].field';
                    jsonbuffer.Reset();
                    jsonbuffer.SetFilter(Path, deliveryerrorFieldpath);
                    jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::String);
                    if jsonbuffer.FindFirst() then ShipPackageHeader."Delivery Message" += jsonbuffer.GetValue() + ' : ';
                    deliveryerrormsgpath := 'verifications.delivery.errors[' + Format(i) + '].message';
                    jsonbuffer.Reset();
                    jsonbuffer.SetFilter(Path, deliveryerrormsgpath);
                    jsonbuffer.SetFilter("Token type", '=%1', jsonbuffer."Token type"::String);
                    if jsonbuffer.FindFirst() then ShipPackageHeader."Delivery Message" += jsonbuffer.GetValue() + ' ; ';
                    i := i + 1;
                end;
            end;
            ResidentialPath := 'residential';
            jsonbuffer.Reset();
            jsonbuffer.SetRange(Path, ResidentialPath);
            jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::Boolean);
            if jsonbuffer.FindFirst() then begin
                Evaluate(ResidentialBoolean, jsonbuffer.GetValue());
                ShipPackageHeader.Validate(Residential, ResidentialBoolean);
                //   ShipPackageHeader.Modify();
            end;
            // ShipPackageHeader.Modify();
        end
    end;

    procedure GetInsuranceAmount(ShipPackageHeader: Record "Ship Package Header"): Decimal
    var
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        SalesHeader: Record "Sales Header";
        SalesLines: Record "Sales Line";
        ShippingInsurance: Decimal;
    begin
        ShippingInsurance := 0;
        if ShipPackageHeader."Inventory Pick" = '' then begin
            SalesHeader.Reset();
            SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Quote, SalesHeader."Document Type"::Order);
            SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
            if SalesHeader.FindFirst() then begin
                rec.Insurance := 0;
                SalesLines.Reset();
                SalesLines.SetRange("Document Type", SalesHeader."Document Type");
                SalesLines.SetRange("Document No.", SalesHeader."No.");
                SalesLines.SetRange(Type, SalesLines.Type::Item);
                if SalesLines.FindSet() then begin
                    //Repeat
                    SalesLines.CalcSums(SalesLines."Amount Including VAT");
                    ShippingInsurance := SalesLines."Amount Including VAT";
                    //until SalesLines.Next() = 0;
                end;
            end;
        end
        Else begin
            WarehouseActivityHeader.Reset();
            WarehouseActivityHeader.SetRange("No.", ShipPackageHeader."Inventory Pick");
            WarehouseActivityHeader.SetRange(Type, WarehouseActivityHeader.Type::"Invt. Pick");
            if WarehouseActivityHeader.FindFirst() then begin
                Rec.Insurance := 0;
                WarehouseActivityLine.reset();
                WarehouseActivityLine.SetRange("Activity Type", WarehouseActivityHeader.Type);
                WarehouseActivityLine.SetRange("No.", WarehouseActivityHeader."No.");
                if WarehouseActivityLine.FindSet() then begin
                    repeat
                        SalesLines.Reset();
                        SalesLines.SetRange("Line No.", WarehouseActivityLine."Source Line No.");
                        SalesLines.SetRange("Document No.", WarehouseActivityLine."Source No.");
                        SalesLines.SetFilter("Document Type", '%1|%2', SalesLines."Document Type"::Order, SalesLines."Document Type"::Quote);
                        SalesLines.SetRange(Type, SalesLines.Type::Item);
                        if SalesLines.FindFirst() then begin
                            ShippingInsurance += SalesLines."Unit price" * WarehouseActivityLine."Qty. to Handle";
                        end;
                    until WarehouseActivityLine.Next() = 0;
                end;
                // ShipPackage.Modify();
            end;
        end;
        exit(ShippingInsurance);
        // ShipPackage.Modify();
    end;

    procedure Verify() Verifymsg: text;
    begin
        if "Zip Message" = 'Success' then
            Verifymsg := 'Favorable'
        else
            Verifymsg := 'UnFavorable';
    end;

    procedure GetNoSeries(shipPackageMain: Record "Ship Package Header"): Boolean
    begin
        Noseries.SetSeries(No);
        exit(true)
    end;

    trigger OnDelete()
    var
        ShippackingLines: Record "Ship Packing Lines";
        SubPackingLines: Record "Sub Packing Lines";
        PackinLines: Record "Pack In Lines";
        PackingAdjustment: Record "Packing Adjustment";
        buyShipment: Record "Buy Shipment";
        CombinedRateInfo: Record "Combine Rate Information";
        Packin: Record "Pack In";
        RLRateQuote: Record "RL Rate Quote";
        Readjust: Record "ReAdjust Packing";
    begin
        if Rec.Carrier = '' then begin
            ShippackingLines.Reset();
            ShippackingLines.SetRange("No.", Rec.No);
            if ShippackingLines.FindSet() then ShippackingLines.DeleteAll();
            SubPackingLines.Reset();
            SubPackingLines.SetRange("Packing No.", Rec.No);
            if SubPackingLines.FindSet() then SubPackingLines.DeleteAll();
            PackinLines.Reset();
            PackinLines.SetRange("Packing No.", Rec.No);
            if PackinLines.FindSet() then PackinLines.DeleteAll();
            PackingAdjustment.Reset();
            PackingAdjustment.SetRange("Packing No", Rec.No);
            if PackingAdjustment.FindSet() then PackingAdjustment.DeleteAll();
            buyShipment.Reset();
            buyShipment.SetRange("No.", Rec.No);
            if buyShipment.FindSet() then buyShipment.DeleteAll();
            CombinedRateInfo.Reset();
            CombinedRateInfo.SetRange("Packing No.", Rec.No);
            if CombinedRateInfo.FindSet() then CombinedRateInfo.DeleteAll();
            Packin.Reset();
            Packin.SetRange("Packing No.", Rec.No);
            if Packin.FindSet() then Packin.DeleteAll();
            RLRateQuote.Reset();
            RLRateQuote.SetRange("No", Rec.No);
            if RLRateQuote.FindSet() then RLRateQuote.DeleteAll();
            Readjust.Reset();
            Readjust.SetRange("Packing No", Rec.No);
            if Readjust.FindSet() then Readjust.DeleteAll();
        end;
    end;

    procedure GetNoSeriesCode(): Code[20]
    var
        check: boolean;
        NoSeriesCode: code[20];
        selectNoSeriesAllow: Boolean;
    begin
        packingModuleSetup.Get();
        check := false;
        if check then exit;
        NoSeriesCode := packingModuleSetup."Packing Nos";
        exit(Noseries.GetNoSeriesWithCheck(NoSeriesCode, selectNoSeriesAllow, No))
    end;

    var
        Noseries: Codeunit NoSeriesManagement;
        packingModuleSetup: record "Packing Module Setup";
        shipPackageMain: Record "Ship Package Header";
        NewNoSeries: code[20];
        WorkDesc: Text;

    var
        SIEventMgnt: Codeunit "SI Event Mgnt";
        verifytxt: Text;
}
