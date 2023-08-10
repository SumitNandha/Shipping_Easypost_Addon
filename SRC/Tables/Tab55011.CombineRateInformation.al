table 55011 "Combine Rate Information"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Packing No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Carrier; Text[100])
        {
            Caption = 'Carrier';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                ShipPackageHeader: Record "Ship Package Header";
                ShippingAgents: Record "Shipping Agent";
            begin
                ShipPackageHeader.Get(Rec."Packing No.");
                ShippingAgents.Reset();
                ShippingAgents.SetRange("SI Get Rate Carrier", Rec.Carrier);
                if ShippingAgents.FindFirst() then;
                Rec.validate("Markup Value", ShipPackageHeader."Box Markup value" + ShipPackageHeader."Additional Mark Up" + ShipPackageHeader."Insurance Markup for Box");
            end;
        }
        field(5; Service; Text[100])
        {
            Caption = 'Service';
            DataClassification = ToBeClassified;
        }
        field(6; Currency; Code[20])
        {
            Caption = 'Currency';
            DataClassification = ToBeClassified;
        }
        field(7; Rate; Decimal)
        {
            Caption = 'Rate';
            DataClassification = ToBeClassified;
        }
        field(8; "Delivery Days"; Integer)
        {
            Caption = 'Delivery Days';
            DataClassification = ToBeClassified;
        }
        field(9; "YRC Error Code"; Code[20])
        {
            Caption = 'YRC Error Code';
            DataClassification = ToBeClassified;
        }
        field(10; "YRC Error Message"; Text[1000])
        {
            Caption = 'YRC Error Message';
            DataClassification = ToBeClassified;
        }
        field(11; "YRC Service Occ Code"; Code[20])
        {
            Caption = 'YRC Service Occ Code';
            DataClassification = ToBeClassified;
        }
        field(12; "YRC Service Req"; Code[20])
        {
            Caption = 'YRC Service Req';
            DataClassification = ToBeClassified;
        }
        field(13; "Buy Service"; Boolean)
        {
            Caption = 'Buy Service';
            DataClassification = ToBeClassified;
        }
        field(14; "Choose Service"; Boolean)
        {
            Caption = 'Choose service';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                ShipAgent: Record "Shipping Agent";
                ShipAgentService: Record "Shipping Agent Services";
                SalesHeader: Record "Sales Header";
                ShipPackageHeader: Record "Ship Package Header";
                SubPackageLineRec: record "Sub Packing Lines";
                CombineRateInfo: Record "Combine Rate Information";
                LineCount: Integer;
                shipmarkup: Record "Shipping MarkUp Setup";
                PackingModuleSetUp: Record "Packing Module Setup";
                SalesLine: Record "Sales Line";
                SalesLineLast: Record "Sales Line";
                ReleaseDoc: Codeunit "Release Sales Document";
                StatusBefore: Text;
                ReleaseSalesDoc: Codeunit "Release Sales Document";
                ShippingAgents: Record "Shipping Agent";
            begin
                CombineRateInfo.Reset();
                CombineRateInfo.SetRange("Packing No.", Rec."Packing No.");
                CombineRateInfo.SetRange("Buy Service", true);
                if not CombineRateInfo.FindSet() then begin
                    ShipPackageHeader.Get(Rec."Packing No.");
                    if ShipPackageHeader."Inventory Pick" = '' then begin
                        if Rec."Choose Service" = true then begin
                            // ShipPackageHeader.Get(Rec."Packing No.");
                            ShipPackageHeader.Validate("Markup value", 0);
                            ShipPackageHeader.Validate("Total Shipping Rate for Customer", 0);
                            ShipPackageHeader.Validate(Difference, 0);
                            ShipPackageHeader.Validate("Existing Shipping Rate on SO/SQ", 0);
                            ShipPackageHeader.Validate("Freight Value", Rec.Rate);
                            ShipPackageHeader.Modify();
                            SubPackageLineRec.Reset();
                            SubPackageLineRec.SetRange("Packing No.", Rec."Packing No.");
                            if SubPackageLineRec.FindSet() then begin
                                LineCount := SubPackageLineRec.Count;
                            end;
                            // ShipPackageHeader.Get(Rec."Packing No.");
                            SalesHeader.Reset();
                            SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
                            if SalesHeader.FindFirst() then begin
                                StatusBefore := format(SalesHeader.Status);
                                if SalesHeader.Status <> SalesHeader.Status::Open then ReleaseDoc.Reopen(SalesHeader);
                            end;
                            PackingModuleSetUp.get();
                            // ShipPackageHeader.Get(Rec."Packing No.");
                            ShippingAgents.Reset();
                            ShippingAgents.SetRange("SI Get Rate Carrier", Rec.Carrier);
                            if ShippingAgents.FindFirst() then;
                            ShipPackageHeader."Total Shipping Rate for Customer" += ShipPackageHeader."Freight Value" + ShipPackageHeader."Box Markup value" + ShipPackageHeader."Insurance Markup for box" + ShipPackageHeader."Additional Mark Up";
                            ShipPackageHeader."Markup value" := ShipPackageHeader."Box Markup value";
                            ShipPackageHeader.Modify();
                            ShipPackageHeader.Get(Rec."Packing No.");
                            SalesHeader.Reset();
                            SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
                            if SalesHeader.FindFirst() then;
                            SalesHeader."Shipping Agent Code" := '';
                            SalesHeader."Shipping Agent Service Code" := '';
                            SalesHeader.Modify();
                            ShipAgent.Reset();
                            ShipAgent.SetRange("SI Get Rate Carrier", Rec."EasyPost CA Name");
                            if ShipAgent.FindFirst() then begin
                                SalesHeader.Validate("Shipping Agent Code", ShipAgent.Code);
                                SalesHeader.Modify();
                            end;
                            ShipAgentService.Reset();
                            ShipAgentService.SetRange("SI Get Rate service", Rec.Service);
                            if ShipAgentService.FindFirst() then begin
                                SalesHeader.Validate("Shipping Agent Service code", ShipAgentService.Code);
                                SalesHeader.Modify();
                            end;
                            ShipPackageHeader.Reset();
                            ShipPackageHeader.SetRange(No, Rec."Packing No.");
                            if ShipPackageHeader.FindFirst() then begin
                                SalesHeader.Reset();
                                SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
                                if SalesHeader.FindFirst() then begin
                                    SalesHeader.Validate("SI Total Shipping Rate", Rec."Total Shipping Rate for Customer");
                                    SalesHeader.Modify();
                                end;
                            end;
                            ShipPackageHeader.Reset();
                            ShipPackageHeader.SetRange(No, Rec."Packing No.");
                            if ShipPackageHeader.FindFirst() then begin
                                ShipPackageHeader.Validate(Difference, Abs(ShipPackageHeader."Total Shipping Rate for Customer" - ShipPackageHeader."Existing Shipping Rate on SO/SQ"));
                                //ShipPackageHeader.Validate(Carrier, Rec.Carrier);
                                ShipPackageHeader.Validate(Carrier, Rec."EasyPost CA Name");//SN_12042023+ 
                                ShipPackageHeader.Validate(Service, Rec.Service);
                                ShipPackageHeader.Modify();
                            end;
                            // ShipPackageHeader.Get(Rec."Packing No.");
                            if shipmarkup.Get(ShipPackageHeader."Ship-to Customer No.") then begin
                                if ShipPackageHeader."Shipping rate for Customer" = true then begin
                                    SalesHeader.Reset();
                                    SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
                                    SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Quote);
                                    if SalesHeader.FindFirst() then begin
                                        SalesLine.reset();
                                        SalesLine.SetRange("Document No.", SalesHeader."No.");
                                        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                                        SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
                                        SalesLine.SetRange("No.", PackingModuleSetUp."Estimated Shipping Cost Account No");
                                        if not SalesLine.FindFirst() then begin
                                            SalesLineLast.reset();
                                            SalesLineLast.SetRange("Document No.", SalesHeader."No.");
                                            SalesLineLast.SetRange("Document Type", salesHeader."Document Type");
                                            if SalesLineLast.FindLast() then;
                                            SalesLine.Init();
                                            // SalesLine.Validate("Document No.", ShipPackageHeader."Document No.");
                                            SalesLine.validate("document type", SalesHeader."Document Type");
                                            SalesLine.Validate("Line No.", SalesLineLast."Line No." + 10000);
                                            SalesLine.Validate("Document No.", SalesHeader."No.");
                                            SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                                            SalesLine.Validate("No.", PackingModuleSetUp."Estimated Shipping Cost Account No");
                                            SalesLine.Validate(Quantity, 1);
                                            SalesLine.Validate("Unit Price", ShipPackageHeader."Total Shipping Rate for Customer");
                                            SalesLine.Insert();
                                            OnInsertSalesLinefromShippingModule(SalesLine, ShipPackageHeader."Total Shipping Rate for Customer")
                                        end
                                        else begin
                                            SalesLine.Validate("Unit Price", ShipPackageHeader."Total Shipping Rate for Customer");
                                            SalesLine.Modify();
                                        end;
                                    end;
                                end;
                            end
                            else begin
                                shipmarkup.Reset();
                                shipmarkup.SetFilter("Customer No.", '');
                                if shipmarkup.FindFirst() then begin
                                    if ShipPackageHeader."Shipping rate for Customer" = true then begin
                                        SalesHeader.Reset();
                                        SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
                                        SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Quote);
                                        if SalesHeader.FindFirst() then begin
                                            SalesLine.reset();
                                            SalesLine.SetRange("Document No.", SalesHeader."No.");
                                            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                                            SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
                                            SalesLine.SetRange("No.", PackingModuleSetUp."Estimated Shipping Cost Account No");
                                            if not SalesLine.FindFirst() then begin
                                                SalesLineLast.reset();
                                                SalesLineLast.SetRange("Document No.", SalesHeader."No.");
                                                SalesLineLast.SetRange("Document Type", salesHeader."Document Type");
                                                if SalesLineLast.FindLast() then;
                                                SalesLine.Init();
                                                // SalesLine.Validate("Document No.", ShipPackageHeader."Document No.");
                                                SalesLine.validate("document type", SalesHeader."Document Type");
                                                SalesLine.Validate("Line No.", SalesLineLast."Line No." + 10000);
                                                SalesLine.Validate("Document No.", SalesHeader."No.");
                                                SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                                                SalesLine.Validate("No.", PackingModuleSetUp."Estimated Shipping Cost Account No");
                                                SalesLine.Validate(Quantity, 1);
                                                SalesLine.Validate("Unit Price", ShipPackageHeader."Total Shipping Rate for Customer");
                                                SalesLine.Insert();
                                                OnInsertSalesLinefromShippingModule(SalesLine, ShipPackageHeader."Total Shipping Rate for Customer");
                                            end
                                            else begin
                                                SalesLine.Validate("Unit Price", ShipPackageHeader."Total Shipping Rate for Customer");
                                                SalesLine.Modify();
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                            if StatusBefore = 'Released' then ReleaseSalesDoc.Run(SalesHeader);
                        end;
                        Rec.Modify();
                    END
                    else
                        Error('Choose Service can’t be used if the Ship Package Card is for an Inventory Pick.  Please use Buy Service column.');
                end
                else
                    Error('Service already chosen.');
            end;
        }
        field(15; "Markup Value"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Rec."Total Shipping Rate for Customer" := Rec."Markup Value" + Rec.Rate;
            end;
        }
        field(16; "Total Shipping Rate for Customer"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "EasyPost CA Account"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "EasyPost CA Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                ShipPackageHeader: Record "Ship Package Header";
                ShippingAgents: Record "Shipping Agent";
            begin
                ShipPackageHeader.Get(Rec."Packing No.");
                ShippingAgents.Reset();
                ShippingAgents.SetRange("SI Get Rate Carrier", Rec."EasyPost CA Name");
                if ShippingAgents.FindFirst() then;
                Rec.validate("Markup Value", ShipPackageHeader."Box Markup value" + ShipPackageHeader."Additional Mark Up" + ShipPackageHeader."Insurance Markup for Box");
            end;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    [BusinessEvent(false)]
    procedure OnInsertSalesLinefromShippingModule(SalesLines: Record "Sales Line"; TotalShippingRateForCustomer: Decimal)
    begin

    end;
}
