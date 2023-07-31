codeunit 55000 "SI Event Mgnt"
{
    Permissions = tabledata "Sales Shipment Header" = m;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Post", 'OnBeforePostedInvtPickHeaderInsert', '', false, false)]
    local procedure OnPostWhseActivityLineOnBeforePosting_FlowInvPickNo(var PostedInvtPickHeader: Record "Posted Invt. Pick Header")
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShipPackageHeader: Record "Ship Package Header";
        CombineRateInfo: Record "Combine Rate Information";
        EmailMngmt: Codeunit "Email Management";
        ShippackageheaderRec: Record "Ship Package Header";
    begin
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange("Inventory Pick", PostedInvtPickHeader."Invt Pick No.");
        if ShipPackageHeader.FindFirst() then;
        if SalesShipmentHeader.get(PostedInvtPickHeader."Source No.") then begin
            SalesShipmentHeader."SI Inv. Pick No." := PostedInvtPickHeader."Invt Pick No.";
            SalesShipmentHeader.Validate(SalesShipmentHeader."Package Tracking No.", ShipPackageHeader."Tracking Code");
            SalesShipmentHeader.Validate("BigCommerce Tracking No.", ShipPackageHeader."Tracking Code");
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
        NoOfPallet: Integer;
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
            SubPackingLines.SetCurrentKey("Packing No.", "Packing Type");
            SubPackingLines.SetRange("Packing No.", ShipPackage.No);
            if SubPackingLines.FindSet() then begin
                repeat
                    if SubPackingLines."Packing Type" = SubPackingLines."Packing Type"::Box then NoOfBox := NoOfBox + 1;
                    if SubPackingLines."Packing Type" = SubPackingLines."Packing Type"::Pallet then NoOfPallet := NoOfPallet + 1;
                until SubPackingLines.Next() = 0;
            end;
            ShipPackage."Box Markup value" := 0;
            ShipPackage."Pallet Markup value" := 0;
            ShipPackage."Box Markup value" := NoOfBox * ShipMarkupSetup."MarkUp per Box";
            if NoOfPallet > 1 then ShipPackage."Pallet Markup value" += (NoOfPallet - 1) * ShipMarkupSetup."MarkUp for Remaning Pallet" + ShipMarkupSetup."MarkUp per For 1st Pallet";
            if NoOfPallet = 1 then ShipPackage."Pallet Markup value" += 1 * ShipMarkupSetup."MarkUp per For 1st Pallet";
            ShipPackage.Modify();
            SubPackingLines.Reset();
            SubPackingLines.SetRange("Packing No.", PackingNo);
            SubPackingLines.SetRange("Packing Type", SubPackingLines."Packing Type"::Box);
            if SubPackingLines.FindSet() then begin
                if ShipMarkupSetup."Box Shipping Insurance?" = ShipMarkupSetup."Box Shipping Insurance?"::"3rd Party" then begin
                    ShipPackage.Get(PackingNo);
                    ShipPackage."Insurance Markup for Box" := (ShipMarkupSetup."Box Shipping Insurace %" * ShipPackage.Insurance) / 100;
                end;
            END;
            SubPackingLines.Reset();
            SubPackingLines.SetRange("Packing No.", PackingNo);
            SubPackingLines.SetRange("Packing Type", SubPackingLines."Packing Type"::Pallet);
            if SubPackingLines.FindSet() then begin
                if ShipMarkupSetup."Freight Shipping Insurance?" = ShipMarkupSetup."Freight Shipping Insurance?"::"3rd Party" then begin
                    ShipPackage.Get(PackingNo);
                    ShipPackage."Insurance Markup for Pallet" := (ShipMarkupSetup."Freight Shipping Insurace %" * ShipPackage.Insurance) / 100;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BigCommerce BC Orders", 'OnInsertSalesLinefromBigCommerce', '', false, false)]
    local procedure FlowRatesinTotalShippingRate(ShippingAmount: Decimal; var SalesHeader: Record "Sales Header")
    var
        //SalesHeader: Record "Sales Header";
        bigCommerceSetUp: Record "BigCommerce Setup";
    begin
        if ShippingAmount <> 0 then begin
            SalesHeader.Validate("SI Total Shipping Rate", ShippingAmount);
            if SalesHeader.Modify(false) then;
        end;
    end;

    // Procedure SendEmailShippingTrackingNo()
    // var
    //     SalesShipmentHeader: Record "Sales Shipment Header";
    //     ShipPackageHeader: Record "Ship Package Header";
    //     CombineRateInfo: Record "Combine Rate Information";
    //     EmailMngmt: Codeunit "Email Management";
    // begin
    //     SalesShipmentHeader.Reset();
    //     SalesShipmentHeader.SetFilter("SI Inv. Pick No.", '<>%1', '');
    //     SalesShipmentHeader.SetRange("Send Tracking Email", false);
    //     if SalesShipmentHeader.FindSet() then begin
    //         repeat
    //             ShipPackageHeader.Reset();
    //             ShipPackageHeader.SetRange("Inventory Pick", SalesShipmentHeader."SI Inv. Pick No.");
    //             if ShipPackageHeader.FindFirst() then begin
    //                 ShipPackageHeader.Validate(Posted, true);
    //                 ShipPackageHeader.Modify();
    //                 CombineRateInfo.Reset();
    //                 CombineRateInfo.SetRange("Packing No.", ShipPackageHeader.No);
    //                 CombineRateInfo.SetRange("Buy Service", true);
    //                 if CombineRateInfo.FindFirst() then begin
    //                     if (CombineRateInfo.Carrier <> 'YRC') AND (CombineRateInfo.Carrier <> 'RL Carrier') and (CombineRateInfo.Carrier <> 'Custom Freight') and (CombineRateInfo.Carrier <> 'Customer PickUp') then begin
    //                         EmailMngmt.EmailDraft(ShipPackageHeader, true, false, false);
    //                     end;
    //                     if (CombineRateInfo.Carrier = 'YRC') or (CombineRateInfo.Carrier = 'Custom Freight') or (CombineRateInfo.Carrier = 'RL Carrier') or (CombineRateInfo.Carrier = 'Truck Freight') then begin
    //                         EmailMngmt.EmailDraft(ShipPackageHeader, false, true, false);
    //                     end;
    //                     if (CombineRateInfo.Carrier = 'Customer PickUp') then begin
    //                         EmailMngmt.EmailDraft(ShipPackageHeader, false, false, true);
    //                     end;
    //                 end;
    //             end;
    //         until SalesShipmentHeader.Next() = 0;
    //     end;
    // end;

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
                        if CompanyName = 'Blossom Group LLC' then
                            SalesShptHeader."BigCommerce Tracking No." := FromSalesShptHeader."Ship package tracking No";
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
        SubPackingLinesRec.SetRange("Packing Type", SubPackingLinesRec."Packing Type"::Box);
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

    procedure UnpostedBOXWiseLOTAssignment(var Subpackinglines: Record "Sub Packing Lines")
    var
        ShippackageHeader: Record "Ship Package Header";
        WarehouseActHeader: Record "Warehouse Activity Header";
        warehouseActivityLines: Record "Warehouse Activity Line";
        LOTAssignBuffer: Record "LOT Assignment Buffer";
        EntryNo: Integer;
        ReadjustPacking: Record "ReAdjust Packing";
        BoxWiseLOTAssignment: Record "Box wise LOT assignment";
        LOTAssignBufferRec: Record "LOT Assignment Buffer";
        InventoryItemsCount: Integer;
        LOTAssignitemCount: Integer;
        BoxWiseLOTAssignCheck1: Record "Box wise LOT assignment";
        BoxWiseLOTAssignCheck2: Record "Box wise LOT assignment";
        BoxWiseLOTAssignCheck3: Record "Box wise LOT assignment";
        LastLotNo: Text;
        LastItemNo: Text;
        LastBoxID: Text;
        BoxWiseItem: Code[20];
        BoxWiseLOTAssignCheckItemTotal: Record "Box wise LOT assignment";
        ItemLOT: Code[50];
    begin

        if ShippackageHeader.Get(Subpackinglines."Packing No.") then begin
            if LOTAssignBuffer.FindSet() then
                LOTAssignBuffer.DeleteAll(true);
            BoxWiseLOTAssignment.Reset();
            BoxWiseLOTAssignment.SetRange("Packing No", ShippackageHeader.no);
            if BoxWiseLOTAssignment.FindSet() then
                BoxWiseLOTAssignment.DeleteAll(true);
            if WarehouseActHeader.Get(WarehouseActHeader.Type::"Invt. Pick", ShippackageHeader."Inventory Pick") then begin
                warehouseActivityLines.Reset();
                warehouseActivityLines.SetRange("No.", WarehouseActHeader."No.");
                warehouseActivityLines.SetRange("activity Type", warehouseActivityLines."Activity Type"::"Invt. Pick");
                if warehouseActivityLines.FindSet() then begin
                    EntryNo := 0;
                    repeat
                        LOTAssignBuffer.Init();
                        LOTAssignBuffer.Validate("Entry No.", EntryNo);
                        LOTAssignBuffer.Validate(InvPickNo, warehouseActivityLines."No.");
                        LOTAssignBuffer.Validate("LOT No.", warehouseActivityLines."Lot No.");
                        LOTAssignBuffer.Validate("Item No", warehouseActivityLines."Item No.");
                        LOTAssignBuffer.Validate(Quantity, warehouseActivityLines."Qty. to Handle");
                        LOTAssignBuffer.Validate("Qty assigned to box", 0);
                        LOTAssignBuffer.Validate("Remaining Qty", LOTAssignBuffer.Quantity);
                        LOTAssignBuffer.Insert(true);
                        EntryNo += 1;
                    until warehouseActivityLines.Next() = 0;
                end;
            end;
            EntryNo := 0;


            ReadjustPacking.Reset();
            ReadjustPacking.SetRange("Packing No", ShippackageHeader.No);
            if ReadjustPacking.FindSet() then begin
                repeat
                    LOTAssignBuffer.Reset();
                    LOTAssignBuffer.SetCurrentKey("Item No");
                    LOTAssignBuffer.SetRange(InvPickNo, ShippackageHeader."Inventory Pick");
                    LOTAssignBuffer.SetRange("Item No", ReadjustPacking."Item No.");
                    LOTAssignBuffer.SetFilter("Remaining Qty", '<>%1', 0);
                    if LOTAssignBuffer.FindFirst() then begin
                        LOTAssignBufferRec.Reset();
                        LOTAssignBufferRec.SetCurrentKey("Item No");
                        LOTAssignBufferRec.SetRange(InvPickNo, ShippackageHeader."Inventory Pick");
                        LOTAssignBufferRec.SetRange("Item No", ReadjustPacking."Item No.");
                        LOTAssignBufferRec.SetFilter("Remaining Qty", '>=%1', ReadjustPacking."Qty to pack in this Box");
                        if LOTAssignBufferRec.FindFirst() then begin
                            // if (LOTAssignBuffer.Quantity = LOTAssignBuffer."Remaining Qty") or (LOTAssignBuffer.Quantity > LOTAssignBuffer."Remaining Qty") then begin
                            if (LOTAssignBufferRec."Remaining Qty" = ReadjustPacking."Qty to pack in this Box") or (LOTAssignBufferRec."Remaining Qty" > ReadjustPacking."Qty to pack in this Box") then begin
                                BoxWiseLOTAssignment.Init();
                                BoxWiseLOTAssignment.Validate("Serial No", EntryNo + 1);
                                BoxWiseLOTAssignment.Validate("Packing No", ShippackageHeader.No);
                                BoxWiseLOTAssignment.Validate("Item No", ReadjustPacking."Item No.");
                                BoxWiseLOTAssignment.Validate("Lot No", LOTAssignBufferRec."LOT No.");
                                BoxWiseLOTAssignment.Validate(Quantity, ReadjustPacking."Qty to pack in this Box");
                                BoxWiseLOTAssignment.Validate(BoxID, ReadjustPacking."Box/Pallet ID");
                                BoxWiseLOTAssignCheck1.Reset();
                                BoxWiseLOTAssignCheck1.SetCurrentKey("Serial No");
                                BoxWiseLOTAssignCheck1.SetRange("Packing No", Subpackinglines."Packing No.");
                                BoxWiseLOTAssignCheck1.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                if BoxWiseLOTAssignCheck1.FindLast() then begin
                                    BoxWiseLOTAssignCheck2.SetCurrentKey("Serial No");
                                    BoxWiseLOTAssignCheck2.SetRange("Packing No", Subpackinglines."Packing No.");
                                    BoxWiseLOTAssignCheck2.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                    BoxWiseLOTAssignCheck2.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                                    if BoxWiseLOTAssignCheck2.FindLast() then begin
                                        BoxWiseLOTAssignCheck3.Reset();
                                        BoxWiseLOTAssignCheck3.SetCurrentKey("Serial No");
                                        BoxWiseLOTAssignCheck3.SetRange("Packing No", Subpackinglines."Packing No.");
                                        BoxWiseLOTAssignCheck3.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                        BoxWiseLOTAssignCheck3.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                                        BoxWiseLOTAssignCheck3.SetRange("Lot No", BoxWiseLOTAssignment."Lot No");
                                        if BoxWiseLOTAssignCheck3.FindLast() then begin
                                            BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck3."Report Serial No";
                                        end else begin
                                            BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck2."Report Serial No";
                                        end;
                                    end Else begin
                                        BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck1."Report Serial No" + 1;
                                    End;
                                end Else begin
                                    BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignment."Report Serial No" + 1;
                                end;
                                BoxWiseLOTAssignment.Insert(true);
                                LOTAssignBufferRec."Qty assigned to box" += ReadjustPacking."Qty to pack in this Box";
                                LOTAssignBufferRec."Remaining Qty" := LOTAssignBufferRec.Quantity - LOTAssignBufferRec."Qty assigned to box";
                                EntryNo += 1;
                            end
                        end
                        else begin
                            LOTAssignBufferRec.Reset();
                            LOTAssignBufferRec.SetCurrentKey("Item No");
                            LOTAssignBufferRec.SetRange(InvPickNo, ShippackageHeader."Inventory Pick");
                            LOTAssignBufferRec.SetRange("Item No", ReadjustPacking."Item No.");
                            LOTAssignBufferRec.SetFilter("Remaining Qty", '<%1', LOTAssignBuffer."Remaining Qty");
                            if LOTAssignBufferRec.FindFirst() then begin
                                BoxWiseLOTAssignment.Init();
                                BoxWiseLOTAssignment.Validate("Serial No", EntryNo + 1);
                                BoxWiseLOTAssignment.Validate("Packing No", ShippackageHeader.No);
                                BoxWiseLOTAssignment.Validate("Item No", ReadjustPacking."Item No.");
                                BoxWiseLOTAssignment.Validate("Lot No", LOTAssignBufferRec."LOT No.");
                                BoxWiseLOTAssignment.Validate(Quantity, LOTAssignBufferRec."Remaining Qty");
                                BoxWiseLOTAssignment.Validate(BoxID, ReadjustPacking."Box/Pallet ID");
                                BoxWiseLOTAssignCheck1.Reset();
                                BoxWiseLOTAssignCheck1.SetCurrentKey("Serial No");
                                BoxWiseLOTAssignCheck1.SetRange("Packing No", Subpackinglines."Packing No.");
                                BoxWiseLOTAssignCheck1.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                if BoxWiseLOTAssignCheck1.FindLast() then begin
                                    BoxWiseLOTAssignCheck2.SetCurrentKey("Serial No");
                                    BoxWiseLOTAssignCheck2.SetRange("Packing No", Subpackinglines."Packing No.");
                                    BoxWiseLOTAssignCheck2.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                    BoxWiseLOTAssignCheck2.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                                    if BoxWiseLOTAssignCheck2.FindLast() then begin
                                        BoxWiseLOTAssignCheck3.Reset();
                                        BoxWiseLOTAssignCheck3.SetCurrentKey("Serial No");
                                        BoxWiseLOTAssignCheck3.SetRange("Packing No", Subpackinglines."Packing No.");
                                        BoxWiseLOTAssignCheck3.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                        BoxWiseLOTAssignCheck3.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                                        BoxWiseLOTAssignCheck3.SetRange("Lot No", BoxWiseLOTAssignment."Lot No");
                                        if BoxWiseLOTAssignCheck3.FindLast() then begin
                                            BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck3."Report Serial No";
                                        end else begin
                                            BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck2."Report Serial No";
                                        end;
                                    end Else begin
                                        BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck1."Report Serial No" + 1;
                                    End;
                                end Else begin
                                    BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignment."Report Serial No" + 1;
                                end;
                                BoxWiseLOTAssignment.Insert(true);
                                LOTAssignBufferRec."Qty assigned to box" += ReadjustPacking."Qty to pack in this Box";
                                LOTAssignBufferRec."Remaining Qty" := 0;
                                EntryNo += 1;
                            end;
                        end;

                        LOTAssignBufferRec.Modify(false);
                    end;
                until ReadjustPacking.Next() = 0;
            end;



            //Item Wise validation ++
            BoxWiseLOTAssignment.Reset();
            BoxWiseLOTAssignment.SetCurrentKey("Item No");
            BoxWiseLOTAssignment.SetRange("Packing No", Subpackinglines."Packing No.");
            if BoxWiseLOTAssignment.FindSet() then
                repeat
                    if (BoxWiseItem = '') or (BoxWiseItem <> BoxWiseLOTAssignment."Item No") then begin
                        BoxWiseLOTAssignCheckItemTotal.Reset();
                        BoxWiseLOTAssignCheckItemTotal.SetRange("Packing No", BoxWiseLOTAssignment."Packing No");
                        BoxWiseLOTAssignCheckItemTotal.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                        if BoxWiseLOTAssignCheckItemTotal.FindSet() then begin
                            Clear(LOTAssignitemCount);
                            BoxWiseItem := BoxWiseLOTAssignment."Item No";
                            //  Message('%1', BoxWiseLOTAssignCheckItemTotal.Count);
                            repeat
                                LOTAssignitemCount += BoxWiseLOTAssignCheckItemTotal.Quantity;
                            until BoxWiseLOTAssignCheckItemTotal.Next() = 0;
                            warehouseActivityLines.Reset();
                            warehouseActivityLines.SetRange("Activity Type", warehouseActivityLines."Activity Type"::"Invt. Pick");
                            warehouseActivityLines.SetRange("No.", ShippackageHeader."Inventory Pick");
                            warehouseActivityLines.SetRange("Item No.", BoxWiseLOTAssignment."Item No");
                            if warehouseActivityLines.FindSet() then begin
                                // Message('%1', warehouseActivityLines.Count);
                                Clear(InventoryItemsCount);
                                repeat
                                    InventoryItemsCount += warehouseActivityLines."Qty. to Handle";
                                until warehouseActivityLines.Next() = 0;
                            end;
                            BoxWiseLOTAssignment.CalcFields("Item Description");
                            if InventoryItemsCount <> LOTAssignitemCount then
                                Error('Item Wise Inventory mismatch. \ %1', BoxWiseLOTAssignment."Item Description");
                        end;
                    end
                until BoxWiseLOTAssignment.Next() = 0;
            //Item Wise validation --
            //Item Wise Lot Wise validation ++
            BoxWiseLOTAssignment.Reset();
            BoxWiseLOTAssignment.SetCurrentKey("Item No", "Lot No");
            BoxWiseLOTAssignment.SetRange("Packing No", Subpackinglines."Packing No.");
            if BoxWiseLOTAssignment.FindSet() then
                repeat
                    if ((BoxWiseItem = '') and (ItemLOT = '')) or ((BoxWiseItem <> BoxWiseLOTAssignment."Item No") or (ItemLOT <> BoxWiseLOTAssignment."Lot No")) then begin
                        BoxWiseLOTAssignCheckItemTotal.Reset();
                        BoxWiseLOTAssignCheckItemTotal.SetRange("Packing No", BoxWiseLOTAssignment."Packing No");
                        BoxWiseLOTAssignCheckItemTotal.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                        BoxWiseLOTAssignCheckItemTotal.SetRange("Lot No", ItemLOT);
                        if BoxWiseLOTAssignCheckItemTotal.FindSet() then begin
                            BoxWiseItem := BoxWiseLOTAssignCheckItemTotal."Item No";
                            ItemLOT := BoxWiseLOTAssignCheckItemTotal."Lot No";
                            repeat
                                LOTAssignitemCount += BoxWiseLOTAssignCheckItemTotal.Quantity;
                            until BoxWiseLOTAssignCheckItemTotal.Next() = 0;
                            warehouseActivityLines.Reset();
                            warehouseActivityLines.SetRange("Activity Type", warehouseActivityLines."Activity Type"::"Invt. Pick");
                            warehouseActivityLines.SetRange("No.", ShippackageHeader."Inventory Pick");
                            warehouseActivityLines.SetRange("Item No.", BoxWiseLOTAssignment."Item No");
                            if warehouseActivityLines.FindSet() then
                                repeat
                                    InventoryItemsCount += warehouseActivityLines."Qty. to Handle";
                                until warehouseActivityLines.Next() = 0;
                            BoxWiseLOTAssignment.CalcFields("Item Description");
                            if InventoryItemsCount <> LOTAssignitemCount then
                                Error('Item Wise Lot Wise Inventory Mismatch. \ %1 ( %2 )', BoxWiseLOTAssignment."Item Description", ItemLOT);
                        end;
                    end
                until BoxWiseLOTAssignment.Next() = 0;
            //Item Wise Lot Wise validation --
            //Quantity validation ++
            BoxWiseLOTAssignment.Reset();
            BoxWiseLOTAssignment.SetRange("Packing No", Subpackinglines."Packing No.");
            if BoxWiseLOTAssignment.FindSet() then
                repeat
                    LOTAssignitemCount += BoxWiseLOTAssignment.Quantity;
                until BoxWiseLOTAssignment.Next() = 0;
            warehouseActivityLines.Reset();
            warehouseActivityLines.SetRange("Activity Type", warehouseActivityLines."Activity Type"::"Invt. Pick");
            warehouseActivityLines.SetRange("No.", ShippackageHeader."Inventory Pick");
            if warehouseActivityLines.FindSet() then
                repeat
                    InventoryItemsCount += warehouseActivityLines."Qty. to Handle";
                until warehouseActivityLines.Next() = 0;
            if InventoryItemsCount <> LOTAssignitemCount then Error('Pack all the items from Inventory pick.');
            //Quantity validation --
        end;
    end;

    procedure PostedBOXWiseLOTAssignment(var Subpackinglines: Record "Sub Packing Lines")
    var
        ShippackageHeader: Record "Ship Package Header";
        PostedInvPickHeader: Record "Posted Invt. Pick Header";
        PostedInvPickLines: Record "Posted Invt. Pick Line";
        LOTAssignBuffer: Record "LOT Assignment Buffer";
        EntryNo: Integer;
        ReadjustPacking: Record "ReAdjust Packing";
        BoxWiseLOTAssignment: Record "Box wise LOT assignment";
        LOTAssignBufferRec: Record "LOT Assignment Buffer";
        InventoryItemsCount: Integer;
        LOTAssignitemCount: Integer;
        BoxWiseLOTAssignCheck: Record "Box wise LOT assignment";
        BoxWiseLOTAssignCheck1: Record "Box wise LOT assignment";
        BoxWiseLOTAssignCheck2: Record "Box wise LOT assignment";
        BoxWiseLOTAssignCheck3: Record "Box wise LOT assignment";
        BoxWiseItem: Code[20];
        BoxWiseLOTAssignCheckItemTotal: Record "Box wise LOT assignment";
        ItemLOT: Code[50];
        SalesShipmentLines: Record "Sales Shipment Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        Clear(LOTAssignitemCount);
        Clear(InventoryItemsCount);
        BoxWiseLOTAssignCheck.Reset();
        BoxWiseLOTAssignCheck.SetRange("Packing No", Subpackinglines."Packing No.");
        if not BoxWiseLOTAssignCheck.FindSet() then begin
            if ShippackageHeader.Get(Subpackinglines."Packing No.") then;
            PostedInvPickHeader.Reset();
            PostedInvPickHeader.SetRange("Invt Pick No.", ShippackageHeader."Inventory Pick");
            if PostedInvPickHeader.FindFirst() then begin
                if LOTAssignBuffer.FindSet() then
                    LOTAssignBuffer.DeleteAll(true);
                PostedInvPickLines.Reset();
                PostedInvPickLines.SetRange("No.", PostedInvPickHeader."No.");
                if PostedInvPickLines.FindSet() then begin
                    EntryNo := 0;
                    repeat
                        LOTAssignBuffer.Init();
                        LOTAssignBuffer.Validate("Entry No.", EntryNo);
                        LOTAssignBuffer.Validate(InvPickNo, ShippackageHeader."Inventory Pick");
                        LOTAssignBuffer.Validate("LOT No.", PostedInvPickLines."Lot No.");
                        LOTAssignBuffer.Validate("Item No", PostedInvPickLines."Item No.");
                        LOTAssignBuffer.Validate(Quantity, PostedInvPickLines.Quantity);
                        LOTAssignBuffer.Validate("Qty assigned to box", 0);
                        LOTAssignBuffer.Validate("Remaining Qty", LOTAssignBuffer.Quantity);
                        LOTAssignBuffer.Insert(true);
                        EntryNo += 1;
                    until PostedInvPickLines.Next() = 0;
                end;
            end;
            EntryNo := 0;
            BoxWiseLOTAssignment.Reset();
            BoxWiseLOTAssignment.SetRange("Packing No", ShippackageHeader.no);
            if BoxWiseLOTAssignment.FindSet() then
                BoxWiseLOTAssignment.DeleteAll(true);

            ReadjustPacking.Reset();
            ReadjustPacking.SetRange("Packing No", ShippackageHeader.No);
            if ReadjustPacking.FindSet() then begin
                repeat
                    LOTAssignBuffer.Reset();
                    LOTAssignBuffer.SetCurrentKey("Item No");
                    LOTAssignBuffer.SetRange(InvPickNo, ShippackageHeader."Inventory Pick");
                    LOTAssignBuffer.SetRange("Item No", ReadjustPacking."Item No.");
                    LOTAssignBuffer.SetFilter("Remaining Qty", '<>%1', 0);
                    if LOTAssignBuffer.FindFirst() then begin

                        LOTAssignBufferRec.Reset();
                        LOTAssignBufferRec.SetCurrentKey("Item No");
                        LOTAssignBufferRec.SetRange(InvPickNo, ShippackageHeader."Inventory Pick");
                        LOTAssignBufferRec.SetRange("Item No", ReadjustPacking."Item No.");
                        LOTAssignBufferRec.SetFilter("Remaining Qty", '>=%1', LOTAssignBuffer."Remaining Qty");
                        if LOTAssignBufferRec.FindFirst() then begin
                            // if (LOTAssignBuffer.Quantity = LOTAssignBuffer."Remaining Qty") or (LOTAssignBuffer.Quantity > LOTAssignBuffer."Remaining Qty") then begin
                            if (LOTAssignBufferRec."Remaining Qty" = ReadjustPacking."Qty to pack in this Box") or (LOTAssignBufferRec."Remaining Qty" > ReadjustPacking."Qty to pack in this Box") then begin
                                BoxWiseLOTAssignment.Init();
                                BoxWiseLOTAssignment.Validate("Serial No", EntryNo + 1);
                                BoxWiseLOTAssignment.Validate("Packing No", ShippackageHeader.No);
                                BoxWiseLOTAssignment.Validate("Item No", ReadjustPacking."Item No.");
                                BoxWiseLOTAssignment.Validate("Lot No", LOTAssignBufferRec."LOT No.");
                                BoxWiseLOTAssignment.Validate(Quantity, ReadjustPacking."Qty to pack in this Box");
                                BoxWiseLOTAssignment.Validate(BoxID, ReadjustPacking."Box/Pallet ID");
                                BoxWiseLOTAssignCheck1.Reset();
                                BoxWiseLOTAssignCheck1.SetCurrentKey("Serial No");
                                BoxWiseLOTAssignCheck1.SetRange("Packing No", Subpackinglines."Packing No.");
                                BoxWiseLOTAssignCheck1.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                if BoxWiseLOTAssignCheck1.FindLast() then begin
                                    BoxWiseLOTAssignCheck2.SetCurrentKey("Serial No");
                                    BoxWiseLOTAssignCheck2.SetRange("Packing No", Subpackinglines."Packing No.");
                                    BoxWiseLOTAssignCheck2.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                    BoxWiseLOTAssignCheck2.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                                    if BoxWiseLOTAssignCheck2.FindLast() then begin
                                        BoxWiseLOTAssignCheck3.Reset();
                                        BoxWiseLOTAssignCheck3.SetCurrentKey("Serial No");
                                        BoxWiseLOTAssignCheck3.SetRange("Packing No", Subpackinglines."Packing No.");
                                        BoxWiseLOTAssignCheck3.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                        BoxWiseLOTAssignCheck3.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                                        BoxWiseLOTAssignCheck3.SetRange("Lot No", BoxWiseLOTAssignment."Lot No");
                                        if BoxWiseLOTAssignCheck3.FindLast() then begin
                                            BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck3."Report Serial No";
                                        end else begin
                                            BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck2."Report Serial No";
                                        end;
                                    end Else begin
                                        BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck1."Report Serial No" + 1;
                                    End;
                                end Else begin
                                    BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignment."Report Serial No" + 1;
                                end;
                                BoxWiseLOTAssignment.Insert(true);
                                LOTAssignBufferRec."Qty assigned to box" += ReadjustPacking."Qty to pack in this Box";
                                LOTAssignBufferRec."Remaining Qty" := LOTAssignBufferRec.Quantity - LOTAssignBufferRec."Qty assigned to box";
                                EntryNo += 1;
                            end
                        end
                        else begin
                            LOTAssignBufferRec.Reset();
                            LOTAssignBufferRec.SetCurrentKey("Item No");
                            LOTAssignBufferRec.SetRange(InvPickNo, ShippackageHeader."Inventory Pick");
                            LOTAssignBufferRec.SetRange("Item No", ReadjustPacking."Item No.");
                            LOTAssignBufferRec.SetFilter("Remaining Qty", '<%1', LOTAssignBuffer."Remaining Qty");
                            if LOTAssignBufferRec.FindFirst() then begin
                                BoxWiseLOTAssignment.Init();
                                BoxWiseLOTAssignment.Validate("Serial No", EntryNo + 1);
                                BoxWiseLOTAssignment.Validate("Packing No", ShippackageHeader.No);
                                BoxWiseLOTAssignment.Validate("Item No", ReadjustPacking."Item No.");
                                BoxWiseLOTAssignment.Validate("Lot No", LOTAssignBufferRec."LOT No.");
                                BoxWiseLOTAssignment.Validate(Quantity, LOTAssignBufferRec."Remaining Qty");
                                BoxWiseLOTAssignment.Validate(BoxID, ReadjustPacking."Box/Pallet ID");
                                BoxWiseLOTAssignCheck1.Reset();
                                BoxWiseLOTAssignCheck1.SetCurrentKey("Serial No");
                                BoxWiseLOTAssignCheck1.SetRange("Packing No", Subpackinglines."Packing No.");
                                BoxWiseLOTAssignCheck1.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                if BoxWiseLOTAssignCheck1.FindLast() then begin
                                    BoxWiseLOTAssignCheck2.SetCurrentKey("Serial No");
                                    BoxWiseLOTAssignCheck2.SetRange("Packing No", Subpackinglines."Packing No.");
                                    BoxWiseLOTAssignCheck2.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                    BoxWiseLOTAssignCheck2.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                                    if BoxWiseLOTAssignCheck2.FindLast() then begin
                                        BoxWiseLOTAssignCheck3.Reset();
                                        BoxWiseLOTAssignCheck3.SetCurrentKey("Serial No");
                                        BoxWiseLOTAssignCheck3.SetRange("Packing No", Subpackinglines."Packing No.");
                                        BoxWiseLOTAssignCheck3.SetRange(BoxID, BoxWiseLOTAssignment.BoxID);
                                        BoxWiseLOTAssignCheck3.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                                        BoxWiseLOTAssignCheck3.SetRange("Lot No", BoxWiseLOTAssignment."Lot No");
                                        if BoxWiseLOTAssignCheck3.FindLast() then begin
                                            BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck3."Report Serial No";
                                        end else begin
                                            BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck2."Report Serial No";
                                        end;
                                    end Else begin
                                        BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignCheck1."Report Serial No" + 1;
                                    End;
                                end Else begin
                                    BoxWiseLOTAssignment."Report Serial No" := BoxWiseLOTAssignment."Report Serial No" + 1;
                                end;
                                BoxWiseLOTAssignment.Insert(true);
                                LOTAssignBufferRec."Qty assigned to box" += ReadjustPacking."Qty to pack in this Box";
                                LOTAssignBufferRec."Remaining Qty" := 0;
                                EntryNo += 1;
                            end;
                        end;

                        LOTAssignBufferRec.Modify(false);
                    end;
                until ReadjustPacking.Next() = 0;
            end;

            //Item Wise validation ++
            BoxWiseLOTAssignment.Reset();
            BoxWiseLOTAssignment.SetCurrentKey("Item No");
            BoxWiseLOTAssignment.SetRange("Packing No", Subpackinglines."Packing No.");
            if BoxWiseLOTAssignment.FindSet() then
                repeat
                    if (BoxWiseItem = '') or (BoxWiseItem <> BoxWiseLOTAssignment."Item No") then begin
                        BoxWiseLOTAssignCheckItemTotal.Reset();
                        BoxWiseLOTAssignCheckItemTotal.SetRange("Packing No", BoxWiseLOTAssignment."Packing No");
                        BoxWiseLOTAssignCheckItemTotal.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                        if BoxWiseLOTAssignCheckItemTotal.FindSet() then begin
                            Clear(LOTAssignitemCount);
                            BoxWiseItem := BoxWiseLOTAssignment."Item No";
                            //  Message('%1', BoxWiseLOTAssignCheckItemTotal.Count);
                            repeat
                                LOTAssignitemCount += BoxWiseLOTAssignCheckItemTotal.Quantity;
                            until BoxWiseLOTAssignCheckItemTotal.Next() = 0;
                            SalesShipmentHeader.Reset();
                            SalesShipmentHeader.SetRange("SI Inv. Pick No.", ShippackageHeader."Inventory Pick");
                            if SalesShipmentHeader.FindSet() then begin
                                SalesShipmentLines.Reset();
                                SalesShipmentLines.SetRange("Document No.", SalesShipmentHeader."No.");
                                SalesShipmentLines.SetRange("No.", BoxWiseLOTAssignment."Item No");
                                if SalesShipmentLines.FindSet() then begin
                                    // Message('%1', warehouseActivityLines.Count);
                                    Clear(InventoryItemsCount);
                                    repeat
                                        InventoryItemsCount += SalesShipmentLines.Quantity;
                                    until SalesShipmentLines.Next() = 0;
                                end;
                            end;
                            BoxWiseLOTAssignment.CalcFields("Item Description");
                            if InventoryItemsCount <> LOTAssignitemCount then
                                Error('Item Wise Inventory mismatch. \ %1', BoxWiseLOTAssignment."Item Description");
                        end;
                    end
                until BoxWiseLOTAssignment.Next() = 0;
            //Item Wise validation --
            //Item Wise Lot Wise validation ++
            BoxWiseLOTAssignment.Reset();
            BoxWiseLOTAssignment.SetCurrentKey("Item No", "Lot No");
            BoxWiseLOTAssignment.SetRange("Packing No", Subpackinglines."Packing No.");
            if BoxWiseLOTAssignment.FindSet() then
                repeat
                    if ((BoxWiseItem = '') and (ItemLOT = '')) or ((BoxWiseItem <> BoxWiseLOTAssignment."Item No") or (ItemLOT <> BoxWiseLOTAssignment."Lot No")) then begin
                        BoxWiseLOTAssignCheckItemTotal.Reset();
                        BoxWiseLOTAssignCheckItemTotal.SetRange("Packing No", BoxWiseLOTAssignment."Packing No");
                        BoxWiseLOTAssignCheckItemTotal.SetRange("Item No", BoxWiseLOTAssignment."Item No");
                        BoxWiseLOTAssignCheckItemTotal.SetRange("Lot No", ItemLOT);
                        if BoxWiseLOTAssignCheckItemTotal.FindSet() then begin
                            BoxWiseItem := BoxWiseLOTAssignCheckItemTotal."Item No";
                            ItemLOT := BoxWiseLOTAssignCheckItemTotal."Lot No";
                            repeat
                                LOTAssignitemCount += BoxWiseLOTAssignCheckItemTotal.Quantity;
                            until BoxWiseLOTAssignCheckItemTotal.Next() = 0;
                            SalesShipmentHeader.Reset();
                            SalesShipmentHeader.SetRange("SI Inv. Pick No.", ShippackageHeader."Inventory Pick");
                            if SalesShipmentHeader.FindSet() then begin
                                SalesShipmentLines.Reset();
                                SalesShipmentLines.SetRange("Document No.", SalesShipmentHeader."No.");
                                SalesShipmentLines.SetRange("No.", BoxWiseLOTAssignment."Item No");
                                if SalesShipmentLines.FindSet() then begin
                                    Clear(InventoryItemsCount);
                                    repeat
                                        InventoryItemsCount += SalesShipmentLines.Quantity;
                                    until SalesShipmentLines.Next() = 0;
                                end;
                            end;
                            BoxWiseLOTAssignment.CalcFields("Item Description");
                            if InventoryItemsCount <> LOTAssignitemCount then
                                Error('Item Wise Lot Wise Inventory Mismatch. \ %1 ( %2 )', BoxWiseLOTAssignment."Item Description", ItemLOT);
                        end;
                    end
                until BoxWiseLOTAssignment.Next() = 0;
            //Item Wise Lot Wise validation --
            BoxWiseLOTAssignment.Reset();
            BoxWiseLOTAssignment.SetRange("Packing No", Subpackinglines."Packing No.");
            if BoxWiseLOTAssignment.FindSet() then
                repeat
                    LOTAssignitemCount += BoxWiseLOTAssignment.Quantity;
                until BoxWiseLOTAssignment.Next() = 0;
            PostedInvPickLines.Reset();
            PostedInvPickLines.SetRange("No.", PostedInvPickHeader."No.");
            if PostedInvPickLines.FindSet() then
                repeat
                    InventoryItemsCount += PostedInvPickLines.Quantity;
                until PostedInvPickLines.Next() = 0;
            //if InventoryItemsCount <> LOTAssignitemCount then Error('Pack all the items from Inventory pick.');

            // BoxWiseLOTAssignCheck1.Reset();
            // BoxWiseLOTAssignCheck1.SetCurrentKey("Serial No");
            // BoxWiseLOTAssignCheck1.SetRange("Packing No", Subpackinglines."Packing No.");
            // if BoxWiseLOTAssignCheck1.FindSet() then begin
            //     repeat
            //         BoxWiseLOTAssignCheck1."Report Serial No" := 1;
            //         BoxWiseLOTAssignCheck1.Modify();
            //     until BoxWiseLOTAssignCheck1.Next() = 0;
            // end;

            // BoxWiseLOTAssignCheck1.Reset();
            // BoxWiseLOTAssignCheck1.SetCurrentKey("Serial No");
            // BoxWiseLOTAssignCheck1.SetRange("Packing No", Subpackinglines."Packing No.");
            // if BoxWiseLOTAssignCheck1.FindSet() then begin
            //     repeat
            //         BoxWiseLOTAssignCheck2.Reset();
            //         BoxWiseLOTAssignCheck2.SetCurrentKey("Serial No");
            //         BoxWiseLOTAssignCheck2.SetRange("Packing No", Subpackinglines."Packing No.");
            //         BoxWiseLOTAssignCheck2.SetRange(BoxID, BoxWiseLOTAssignCheck1.BoxID);
            //         BoxWiseLOTAssignCheck2.SetRange("Item No", BoxWiseLOTAssignCheck1."Item No");
            //         BoxWiseLOTAssignCheck2.SetRange("Lot No", BoxWiseLOTAssignCheck1."Lot No");
            //         BoxWiseLOTAssignCheck2.SetFilter("Serial No", '<>%1', BoxWiseLOTAssignCheck1."Serial No");
            //         if Not BoxWiseLOTAssignCheck2.FindLast() then
            //             BoxWiseLOTAssignCheck1."Report Serial No" := BoxWiseLOTAssignCheck2."Report Serial No" + 1;
            //         BoxWiseLOTAssignCheck1.Modify();
            //     until BoxWiseLOTAssignCheck1.Next() = 0;
            // end;

            /*
            BoxWiseLOTAssignCheck2.Reset();
                    BoxWiseLOTAssignCheck2.SetRange("Packing No", Subpackinglines."Packing No.");
                    BoxWiseLOTAssignCheck2.SetRange(BoxID, BoxWiseLOTAssignCheck1.BoxID);
                    BoxWiseLOTAssignCheck2.SetRange("Item No", BoxWiseLOTAssignCheck1."Item No");
                    BoxWiseLOTAssignCheck2.SetFilter("Serial No", '<>%1', BoxWiseLOTAssignCheck1."Serial No");
                    if Not BoxWiseLOTAssignCheck2.FindFirst() then
                        BoxWiseLOTAssignCheck1."Report Serial No" := BoxWiseLOTAssignCheck2."Serial No" + 1;
            */
            //BoxWiseLOTAssignCheck1.SetRange("Packing No", Subpackinglines."Packing No.");
        end;
    end;

    procedure QtyValidationBeforeCreateShipPackage(WhseActivityHeader: Record "Warehouse Activity Header")
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        ItemLRec: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        CautionError: Label 'Caution:  LOT# and Bin# combination does not seem to have enough quantities. Please check RED rows.  Do you want to continue to Ship Package?';
    begin
        //SN-01032023 Phase 7
        WarehouseActivityLine.Reset();
        WarehouseActivityLine.SetRange("Activity Type", WhseActivityHeader.Type);
        WarehouseActivityLine.SetRange(WarehouseActivityLine."No.", WhseActivityHeader."No.");
        if WarehouseActivityLine.FindSet() then begin
            repeat
                WarehouseActivityLine.SetFilter("Item No. Filter", WarehouseActivityLine."Item No.");
                WarehouseActivityLine.SetFilter("Location Code Filter", WarehouseActivityLine."Location Code");
                WarehouseActivityLine.SetFilter("Variant No. Filter", WarehouseActivityLine."Variant Code");
                WarehouseActivityLine.SetFilter("Lot No. Filter", WarehouseActivityLine."Lot No.");
                WarehouseActivityLine.SetFilter("Serial No. Filter", WarehouseActivityLine."Serial No.");
                WarehouseActivityLine.SetFilter("Bin Code Filter", WarehouseActivityLine."Bin Code");
                WarehouseActivityLine.CalcFields("Total Quantity", "Total Pick Quantity");
                WarehouseActivityLine."Qty. Balance (Packs)" := WarehouseActivityLine."Total Quantity" - WarehouseActivityLine."Total Pick Quantity";
                if ItemLRec.get(WarehouseActivityLine."Item No.") then
                    If ItemUnitOfMeasure.Get(ItemLRec."No.", ItemLRec."Sales Unit of Measure") then
                        if (ItemUnitOfMeasure."Qty. per Unit of Measure" <> 0) then begin
                            WarehouseActivityLine."Qty. Balance (Packs)" := WarehouseActivityLine."Qty. Balance (Packs)" / ItemUnitOfMeasure."Qty. per Unit of Measure";
                            WarehouseActivityLine.Modify(false);
                        end;
            until WarehouseActivityLine.Next = 0;
        end;
        WarehouseActivityLine.Reset();
        WarehouseActivityLine.SetRange("Activity Type", WhseActivityHeader.Type);
        WarehouseActivityLine.SetRange(WarehouseActivityLine."No.", WhseActivityHeader."No.");
        WarehouseActivityLine.SetFilter("Qty. Balance (Packs)", '<%1', 0);
        if WarehouseActivityLine.FindSet() then
            if Not Confirm(CautionError) then
                error('');
        //SN-01032023 Phase 7

    end;

    procedure CreateAPILog(PackingNO: Code[20]; "Box/PalletID": Code[20]; Method: Text; Request: Text; Response: Text; StatusCode: Integer; CurDateTime: DateTime; URL: Text)
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
        PackingModuleAPILog."Box/Pallet ID" := "Box/PalletID";
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