codeunit 55003 "SI Event Mgnt"
{
    Permissions = tabledata "Sales Shipment Header" = m;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Post", 'OnBeforePostedInvtPickHeaderInsert', '', false, false)]
    local procedure OnPostWhseActivityLineOnBeforePosting_FlowInvPickNo(var PostedInvtPickHeader: Record "Posted Invt. Pick Header")
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShipPackageHeader: Record "Ship Package Header";
        CombineRateInfo: Record "Combine Rate Information";
        // EmailMngmt: Codeunit "Email Management";
        ShippackageheaderRec: Record "Ship Package Header";
    begin
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange("Inventory Pick", PostedInvtPickHeader."Invt Pick No.");
        if ShipPackageHeader.FindFirst() then;
        if SalesShipmentHeader.get(PostedInvtPickHeader."Source No.") then begin
            SalesShipmentHeader."SI Inv. Pick No." := PostedInvtPickHeader."Invt Pick No.";
            SalesShipmentHeader.Validate(SalesShipmentHeader."Package Tracking No.", ShipPackageHeader."Tracking Code");
            // SalesShipmentHeader.Validate("BigCommerce Tracking No.", ShipPackageHeader."Tracking Code");
            SalesShipmentHeader.Modify(false)
        end;
        ShippackageheaderRec.Reset();
        ShippackageheaderRec.SetRange("Inventory Pick", PostedInvtPickHeader."Invt Pick No.");
        if ShippackageheaderRec.FindFirst() then begin
            ShippackageheaderRec.Validate(Posted, true);
            ShippackageheaderRec.Modify();
        end;
        // if PostedInvtPickHeader."Invt Pick No." <> '' then begin
        //     ShipPackageHeader.Reset();
        //     ShipPackageHeader.SetRange("Inventory Pick", PostedInvtPickHeader."Invt Pick No.");
        //     if ShipPackageHeader.FindFirst() then begin
        //         ShipPackageHeader.Validate(Posted, true);
        //         ShipPackageHeader.Modify();
        //         CombineRateInfo.Reset();
        //         CombineRateInfo.SetRange("Packing No.", ShipPackageHeader.No);
        //         CombineRateInfo.SetRange("Buy Service", true);
        //         if CombineRateInfo.FindFirst() then begin
        //             if (CombineRateInfo.Carrier <> 'YRC') AND (CombineRateInfo.Carrier <> 'RL Carrier') and (CombineRateInfo.Carrier <> 'Custom Freight') and (CombineRateInfo.Carrier <> 'Customer PickUp') then begin
        //                 EmailMngmt.EmailDraft(ShipPackageHeader, true, false, false);
        //             end;
        //             if (CombineRateInfo.Carrier = 'YRC') or (CombineRateInfo.Carrier = 'Custom Freight') or (CombineRateInfo.Carrier = 'RL Carrier') or (CombineRateInfo.Carrier = 'Truck Freight') then begin
        //                 EmailMngmt.EmailDraft(ShipPackageHeader, false, true, false);
        //             end;
        //             if (CombineRateInfo.Carrier = 'Customer PickUp') then begin
        //                 EmailMngmt.EmailDraft(ShipPackageHeader, false, false, true);
        //             end;
        //         end;
        //     end;

        // end;
    end;
    // [EventSubscriber(ObjectType::Page, page::"Ship Package Header", 'OnBeforeActionEvent', 'Select Sales Document No', false, false)]
    // local procedure MyProcedure(var Rec: Record "Ship Package Header")
    // var
    //     Noseries: Codeunit NoSeriesManagement;
    //     packingModuleSetup: Record "Packing Module Setup";
    // begin
    //     packingModuleSetup.Get();
    //     // Rec.Init();
    //     // Rec.Insert();
    //     Commit();
    // end;
    // [EventSubscriber(ObjectType::Page, page::"Ship Package Header", 'OnBeforeActionEvent', 'Select Inventory Pick No', false, false)]
    // local procedure MyProcedureInvPick(var Rec: Record "Ship Package Header")
    // var
    // begin
    //     packingModuleSetup.Get();
    //     // Rec.Init();
    //     if Rec.No = '' then
    //         Rec.No := Noseries.GetNextNo(packingModuleSetup."Packing Nos", 0D, true);
    //     // Rec.Insert();
    //     Commit();
    // end;
    procedure GetMarkupAmount(PackingNo: Code[20])
    var
        ShipMarkupSetup: Record "Shipping MarkUp Setup";
        ShipPackage: Record "Ship Package Header";
        PackinLines: Record "Sub Packing Lines";
        NoOfBox: Integer;
        SalesHeader: Record "Sales Header";
        SubPackingLines: Record "Sub Packing Lines";
    begin
        ShipPackage.Reset();
        ShipPackage.SetRange(No, PackingNo);
        if ShipPackage.FindFirst() then begin
            ShipMarkupSetup.Reset();
            ShipMarkupSetup.SetRange("Customer No.", ShipPackage."Ship-to Customer No.");
            if ShipMarkupSetup.FindFirst() then begin
                //Message
            end
            else begin
                ShipMarkupSetup.Reset();
                ShipMarkupSetup.SetRange("All Customer", true);
                if ShipMarkupSetup.FindFirst() then;
            end;
            SubPackingLines.Reset();
            SubPackingLines.SetRange("Packing No.", ShipPackage.No);
            if SubPackingLines.FindSet() then begin
                repeat
                    NoOfBox := NoOfBox + 1;
                until SubPackingLines.Next() = 0;
            end;
            ShipPackage."Box Markup value" := 0;
            ShipPackage."Box Markup value" := NoOfBox * ShipMarkupSetup."MarkUp per Box";
            ShipPackage.Modify();
            SubPackingLines.Reset();
            SubPackingLines.SetRange("Packing No.", PackingNo);
            if SubPackingLines.FindSet() then begin
                if ShipMarkupSetup."Box Shipping Insurance?" = ShipMarkupSetup."Box Shipping Insurance?"::"3rd Party" then begin
                    ShipPackage.Get(PackingNo);
                    ShipPackage."Insurance Markup for Box" := (ShipMarkupSetup."Box Shipping Insurace %" * ShipPackage.Insurance) / 100;
                end;
            END;
            ShipPackage.Modify();
        end;
    end;

    procedure "GetAgentServiceOptions"(ShipPackageHeader: Record "Ship Package Header")
    var
        AgentServiceOptions: Record "Agent Service Option";
        AgenntServiceLast: Record "Agent Service Option";
        ShippingAgent: Record "Shipping Agent";
        ShippingAgentService: Record "Shipping Agent Services";
    begin
        AgentServiceOptions.Reset();
        AgentServiceOptions.SetRange("Packing No", ShipPackageHeader.No);
        if not AgentServiceOptions.FindSet() then begin
            ShippingAgent.Reset();
            ShippingAgent.SetRange("Include EasyPost Rates", true);
            if ShippingAgent.FindSet() then
                repeat
                    ShippingAgentService.Reset();
                    ShippingAgentService.SetRange("Shipping Agent Code", ShippingAgent.Code);
                    if ShippingAgentService.FindSet() then
                        repeat
                            AgenntServiceLast.Reset();
                            AgenntServiceLast.SetRange("Packing No", ShipPackageHeader.No);
                            if AgenntServiceLast.FindLast() then;
                            AgentServiceOptions.Init();
                            AgentServiceOptions.Validate("Packing No", ShipPackageHeader.No);
                            AgentServiceOptions.Validate("LineNo.", AgenntServiceLast."LineNo." + 10000);
                            AgentServiceOptions.Validate(Agent, ShippingAgent.Code);
                            AgentServiceOptions.Validate("Agent Service", ShippingAgentService.Description);
                            if ShipPackageHeader.Agent = AgentServiceOptions.Agent then
                                if ShipPackageHeader."Agent Service" = AgentServiceOptions."Agent Service" then
                                    AgentServiceOptions.Validate(Choose, true);
                            AgentServiceOptions.Insert()
                            until ShippingAgentService.Next() = 0;
                until ShippingAgent.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shipment Header - Edit", 'OnBeforeSalesShptHeaderModify', '', false, false)]
    local procedure OnBeforeSalesShptHeaderModify(FromSalesShptHeader: Record "Sales Shipment Header"; var SalesShptHeader: Record "Sales Shipment Header")
    var
        ShipPackageHeader: Record "Ship Package Header";
        ShippingAgents: Record "Shipping Agent";
    begin
        if SalesShptHeader."SI Inv. Pick No." <> '' then begin
            ShipPackageHeader.Reset();
            ShipPackageHeader.SetRange("Inventory Pick", SalesShptHeader."SI Inv. Pick No.");
            if ShipPackageHeader.FindFirst() then begin
                ShippingAgents.Reset();
                ShippingAgents.SetRange("SI Get Rate Carrier", ShipPackageHeader.Carrier);
                if ShippingAgents.FindFirst() then
                    if ShippingAgents."Include EasyPost Rates" = false then begin
                        ShipPackageHeader.Validate("Tracking Code", FromSalesShptHeader."Ship package tracking No");
                        ShipPackageHeader.Modify(false);
                        SalesShptHeader."Package Tracking No." := FromSalesShptHeader."Ship package tracking No";
                        SalesShptHeader.Modify(false);
                    end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::page, Page::"Posted Sales Shipment - Update", 'OnAfterRecordChanged', '', false, false)]
    local procedure OnAfterRecordChanged(var IsChanged: Boolean; var SalesShipmentHeader: Record "Sales Shipment Header"; xSalesShipmentHeader: Record "Sales Shipment Header")
    begin
        IsChanged := xSalesShipmentHeader."Ship package tracking No" <> SalesShipmentHeader."Ship package tracking No";
    end;

    Procedure InsertBoxWiseLotInfo(SubPackingLines: Record "Sub Packing Lines")
    begin

    end;

    Procedure BoxSequence(var SubPackingLines: Record "Sub Packing Lines")
    var
        SubPackingLinesRec: Record "Sub Packing Lines";
        BoxNumber: Integer;
    begin
        BoxNumber := 0;
        SubPackingLinesRec.Reset();
        SubPackingLinesRec.SetRange("Packing No.", SubPackingLines."Packing No.");
        if SubPackingLinesRec.FindSet() then begin
            repeat
                SubPackingLinesRec."Box Number" := BoxNumber + 1;
                BoxNumber += 1;
                SubPackingLinesRec.Modify(false);
            until SubPackingLinesRec.Next() = 0;
        end;
    end;

    procedure GetBarcode(var SubPackingLines: Record "Sub Packing Lines")
    var
        request: HttpRequestMessage;
        client: HttpClient;
        Link: Text;
        Response: HttpResponseMessage;
        Ins: InStream;
    begin
        if not SubPackingLines.Barcode.HasValue then begin
            Link := 'https://barcodeapi.org/api/128/' + SubPackingLines."Box Sr ID/Packing No.";
            request.SetRequestUri(Link);
            client.Get(Link, Response);
            client.Send(request, Response);
            if not Response.IsSuccessStatusCode then
                Message('%1', Response.HttpStatusCode)
            else begin
                Response.Content.ReadAs(Ins);
                SubPackingLines.Barcode.ImportStream(Ins, 'Barcode');
                SubPackingLines.Modify(true);
            end;
        end;
    end;

    // procedure QtyValidationBeforeCreateShipPackage(WhseActivityHeader: Record "Warehouse Activity Header")
    // var
    //     WarehouseActivityLine: Record "Warehouse Activity Line";
    //     ItemLRec: Record Item;
    //     ItemUnitOfMeasure: Record "Item Unit of Measure";
    //     CautionError: Label 'Caution:  LOT# and Bin# combination does not seem to have enough quantities. Please check RED rows.  Do you want to continue to Ship Package?';
    // begin
    //     //SN-01032023 Phase 7
    //     WarehouseActivityLine.Reset();
    //     WarehouseActivityLine.SetRange("Activity Type", WhseActivityHeader.Type);
    //     WarehouseActivityLine.SetRange(WarehouseActivityLine."No.", WhseActivityHeader."No.");
    //     if WarehouseActivityLine.FindSet() then begin
    //         repeat
    //             WarehouseActivityLine.SetFilter("Item No. Filter", WarehouseActivityLine."Item No.");
    //             WarehouseActivityLine.SetFilter("Location Code Filter", WarehouseActivityLine."Location Code");
    //             WarehouseActivityLine.SetFilter("Variant No. Filter", WarehouseActivityLine."Variant Code");
    //             WarehouseActivityLine.SetFilter("Lot No. Filter", WarehouseActivityLine."Lot No.");
    //             WarehouseActivityLine.SetFilter("Serial No. Filter", WarehouseActivityLine."Serial No.");
    //             WarehouseActivityLine.SetFilter("Bin Code Filter", WarehouseActivityLine."Bin Code");
    //             WarehouseActivityLine.CalcFields("Total Quantity", "Total Pick Quantity");
    //             WarehouseActivityLine."Qty. Balance (Packs)" := WarehouseActivityLine."Total Quantity" - WarehouseActivityLine."Total Pick Quantity";
    //             if ItemLRec.get(WarehouseActivityLine."Item No.") then
    //                 If ItemUnitOfMeasure.Get(ItemLRec."No.", ItemLRec."Sales Unit of Measure") then
    //                     if (ItemUnitOfMeasure."Qty. per Unit of Measure" <> 0) then begin
    //                         WarehouseActivityLine."Qty. Balance (Packs)" := WarehouseActivityLine."Qty. Balance (Packs)" / ItemUnitOfMeasure."Qty. per Unit of Measure";
    //                         WarehouseActivityLine.Modify(false);
    //                     end;
    //         until WarehouseActivityLine.Next = 0;
    //     end;
    //     WarehouseActivityLine.Reset();
    //     WarehouseActivityLine.SetRange("Activity Type", WhseActivityHeader.Type);
    //     WarehouseActivityLine.SetRange(WarehouseActivityLine."No.", WhseActivityHeader."No.");
    //     WarehouseActivityLine.SetFilter("Qty. Balance (Packs)", '<%1', 0);
    //     if WarehouseActivityLine.FindSet() then
    //         if Not Confirm(CautionError) then
    //             error('');
    //     //SN-01032023 Phase 7

    // end;

    procedure CreateAPILog(PackingNO: Code[20]; "BoxID": Code[20]; Method: Text; Request: Text; Response: Text; StatusCode: Integer; CurDateTime: DateTime; URL: Text)
    VAR
        PackModuleAPILogLast: Record "Packing Module API log";
        PackingModuleAPILog: Record "Packing Module API log";
        OustreamReq: OutStream;
        OustreamRes: OutStream;
    begin
        PackModuleAPILogLast.Reset();
        if PackModuleAPILogLast.FindLast() then;
        PackingModuleAPILog.Init();
        PackingModuleAPILog."Entry No." := PackModuleAPILogLast."Entry No." + 1;
        PackingModuleAPILog."Packing No." := PackingNO;
        PackingModuleAPILog."Box ID" := "BoxID";
        PackingModuleAPILog.Method := Method;
        PackingModuleAPILog.Request.CreateOutStream(OustreamReq);
        OustreamReq.WriteText(Request);
        PackingModuleAPILog.Response.CreateOutStream(OustreamRes);
        OustreamRes.WriteText(Response);
        PackingModuleAPILog."HTTP Status Code" := StatusCode;
        PackingModuleAPILog."Date/Time" := CurDateTime;
        PackingModuleAPILog.URL := URL;
        PackingModuleAPILog.Insert();
    end;
}