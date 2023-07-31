codeunit 55000 "BuyShipment"
{
    procedure BuyShipmentHeader(CombineRateInfo: Record "Combine Rate Information")
    var
        BuyShipment: Record "Buy Shipment";
        ShipPackageHeaderRec: Record "Ship Package Header";
        RLGetRates: Record "RL Rate Quote";
        SubPackageLineRec: Record "Sub Packing Lines";
        CombineRateInfo2: Record "Combine Rate Information";
        LineCount: Integer;
        ShipPackageHeader: Record "Ship Package Header";
        SalesHeader: Record "Sales Header";
        shipmarkup: Record "Shipping MarkUp Setup";
        SalesLine: Record "Sales Line";
        PackingModuleSetUp: Record "Packing Module Setup";
        SalesLineLast: Record "Sales Line";
        BuyShipmentRec: Record "Buy Shipment";
        InvPick: Record "Warehouse Activity Header";
        ReleaseDoc: Codeunit "Release Sales Document";
        StatusBefore: Text;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        GLAcc: Record "G/L Account";
        YRCService: Text;
        ShippackageHeaderPage: Page "Ship Package Header";
        PackInBoxPAGE: Page "Pack In Box";
        PackInPalletPage: Page "Pack In Pallet";
        PackIn: Record "Pack In";
        ShippingAgent: Record "Shipping Agent";
        ShippingAgentServices: Record "Shipping Agent Services";
    begin
        // CombineRateInfo2.Reset();
        // CombineRateInfo2.SetRange("Packing No.", CombineRateInfo."Packing No.");
        // CombineRateInfo2.SetRange("Buy Service", true);
        // if CombineRateInfo2.FindFirst() then
        //     Error('You can not buy service for package %1, Service is already purchased.', CombineRateInfo."Packing No.");
        ShipPackageHeader.Get(CombineRateInfo."Packing No.");
        SalesHeader.Reset();
        SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
        if SalesHeader.FindFirst() then begin
            StatusBefore := format(SalesHeader.Status);
            if SalesHeader.Status <> SalesHeader.Status::Open then ReleaseDoc.Reopen(SalesHeader);
        end;
        PackingModuleSetUp.Get();
        if Not (CombineRateInfo.Carrier in ['YRC', 'Custom Freight', 'Customer PickUp', 'Truck Freight']) then begin
            BuyShipment.Reset();
            BuyShipment.SetRange("No.", CombineRateInfo."Packing No.");
            BuyShipment.SetRange(Carrier, CombineRateInfo.Carrier);
            BuyShipment.SetRange(Service, CombineRateInfo.Service);
            BuyShipment.SetRange("EasyPost CA Account", CombineRateInfo."EasyPost CA Account");//SN_11042023+
            // BuyShipment.SetFilter("Packing No", '<>%1', 'BOX4786');
            if BuyShipment.FindSet() then begin
                Repeat
                    if BuyShipment."Rate ID" <> '' then begin
                        BuyShipments(BuyShipment); // = true then begin
                        //end;
                        SubPackageLineRec.Reset();
                        SubPackageLineRec.SetRange("Packing No.", CombineRateInfo."Packing No.");
                        SubPackageLineRec.SetRange("Packing type", SubPackageLineRec."Packing Type"::Box);
                        SubPackageLineRec.SetFilter("Tracking ID", '<>%1', '');
                        if SubPackageLineRec.FindFirst() then
                            if ShipPackageHeader."Tracking Code" = '' then begin
                                ShipPackageHeaderRec.get(CombineRateInfo."Packing No.");
                                ShipPackageHeaderRec."Tracking Code" := SubPackageLineRec."Tracking ID";
                                ShipPackageHeaderRec.Modify();
                                Commit();
                            END;
                    end;
                until BuyShipment.Next() = 0;
                //BuyInsuranceShipments(BuyShipment);
                ShipPackageHeaderRec.get(CombineRateInfo."Packing No.");
                // ShipPackageHeaderRec.Carrier := CombineRateInfo.Carrier;
                ShipPackageHeaderRec.Carrier := CombineRateInfo."EasyPost CA Name";//SN_12042023+
                ShipPackageHeaderRec.Service := CombineRateInfo.Service;
                ShipPackageHeaderRec."Freight Value" := CombineRateInfo.Rate;
                ShipPackageHeaderRec."Confirm Quote No" := RLGetRates."Quote No";
                ShipPackageHeaderRec.Modify();
                UpdateSatatistics(BuyShipment, CombineRateInfo);
                RLGetRates.SetRange(Service, CombineRateInfo.Carrier);
                RLGetRates.SetRange("Service Code", CombineRateInfo.Service);
                if RLGetRates.FindFirst() then begin
                    ShipPackageHeaderRec.get(CombineRateInfo."Packing No.");
                    // ShipPackageHeaderRec.Carrier := CombineRateInfo.Carrier;
                    ShipPackageHeaderRec.Carrier := CombineRateInfo."EasyPost CA Name";//SN_12042023+
                    ShipPackageHeaderRec.Service := CombineRateInfo.Service;
                    ShipPackageHeaderRec."Freight Value" := CombineRateInfo.Rate;
                    ShipPackageHeaderRec."Confirm Quote No" := RLGetRates."Quote No";
                    ShipPackageHeaderRec.Modify();
                    BuyShipmentRec.Reset();
                    BuyShipmentRec.SetRange("No.", CombineRateInfo."Packing No.");
                    BuyShipmentRec.SetFilter(Carrier, 'RL Carrier');
                    if BuyShipmentRec.FindSet() then UpdateSatatistics(BuyShipment, CombineRateInfo);
                end;
            end;
        end
        Else begin
            ShipPackageHeaderRec.get(CombineRateInfo."Packing No.");
            // ShipPackageHeaderRec.Carrier := CombineRateInfo.Carrier;
            ShipPackageHeaderRec.Carrier := CombineRateInfo."EasyPost CA Name";//SN_12042023+
            ShipPackageHeaderRec.Service := CombineRateInfo.Service;
            ShipPackageHeaderRec."Freight Value" := CombineRateInfo.Rate;
            if (CombineRateInfo.Carrier = 'YRC') and (CombineRateInfo.Service <> 'STND') then
                YRCService := DelStr(CombineRateInfo.Service, StrPos(CombineRateInfo.Service, '-'))
            else
                YRCService := CombineRateInfo.Service;
            ShipPackageHeaderRec.Modify();
            BuyShipment.Reset();
            BuyShipment.SetRange("No.", CombineRateInfo."Packing No.");
            BuyShipment.SetRange(Carrier, CombineRateInfo.Carrier);
            BuyShipment.SetRange(Service, YRCService);
            if BuyShipment.FindSet() then begin
                if Not (CombineRateInfo.Carrier = 'YRC') then begin
                    Repeat
                        ShipPackageHeaderRec."Confirm Quote No" += BuyShipment."Quote ID";
                    until BuyShipment.Next() = 0;
                    ShipPackageHeaderRec.Modify(false);
                end
                else begin
                    ShipPackageHeaderRec."Confirm Quote No" := BuyShipment."Quote ID";
                    ShipPackageHeaderRec.Modify();
                end;
                UpdateSatatistics(BuyShipment, CombineRateInfo);
            end;
        end;
        SalesHeader.Reset();
        SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
        if SalesHeader.FindFirst() then;
        if CombineRateInfo."Buy Service" = true then begin
            ShippingAgent.Reset();
            // ShippingAgent.SetRange("SI Get Rate Carrier", CombineRateInfo.Carrier);
            ShippingAgent.SetRange("SI Get Rate Carrier", CombineRateInfo."EasyPost CA Name");//SN_1242023+

            if ShippingAgent.FindFirst() then begin
                SalesHeader.Validate("Shipping Agent Code", ShippingAgent.Code);
            end;
            ShippingAgentServices.Reset();
            ShippingAgentServices.SetRange("SI Get Rate Service", CombineRateInfo.Service);
            if ShippingAgentServices.FindFirst() then begin
                SalesHeader.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
            end;
            SalesHeader.Validate("SI Total Shipping Rate", CombineRateInfo."Total Shipping Rate for Customer");
            SalesHeader.Modify(false);
        end;
        if shipmarkup.Get(ShipPackageHeader."Ship-to Customer No.") then begin
            if ShipPackageHeader."Shipping rate for Customer" = true then begin
                SalesHeader.Reset();
                SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
                SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Quote);
                if SalesHeader.FindFirst() then begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                    SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
                    SalesLine.SetRange("No.", PackingModuleSetUp."Estimated Shipping Cost Account No");
                    if SalesLine.FindSet() then SalesLine.DeleteAll();
                    // SalesLine.reset();
                    // SalesLine.SetRange("Document No.", SalesHeader."No.");
                    // SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                    // SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
                    // SalesLine.SetRange("No.", PackingModuleSetUp."Shipping Cost Account No.");
                    // if not SalesLine.FindFirst() then begin
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
                    SalesLine.Validate("No.", PackingModuleSetUp."Shipping Cost Account No.");
                    GLAcc.Get(SalesLine."No.");
                    SalesLine.Validate(description, GLAcc.Name + '(' + ShipPackageHeader."Inventory Pick" + ')');
                    SalesLine.Validate(Quantity, 1);
                    SalesLine.Validate("Unit Price", CombineRateInfo."Total Shipping Rate for Customer");
                    SalesLine.Insert();
                    OnInsertSalesLinefromShippingModuleBuyShipment(CombineRateInfo."Total Shipping Rate for Customer", SalesLine);
                    // end
                    // else begin
                    // SalesLine.Validate("Unit Price", CombineRateInfo."Total Shipping Rate for Customer");
                    // SalesLine.Modify();
                    // end;
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
                        SalesLine.SetRange("Document No.", SalesHeader."No.");
                        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                        SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
                        SalesLine.SetRange("No.", PackingModuleSetUp."Estimated Shipping Cost Account No");
                        if SalesLine.FindSet() then SalesLine.DeleteAll();
                        // SalesLine.reset();
                        // SalesLine.SetRange("Document No.", SalesHeader."No.");
                        // SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                        // SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
                        // SalesLine.SetRange("No.", PackingModuleSetUp."Shipping Cost Account No.");
                        // if not SalesLine.FindFirst() then begin
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
                        SalesLine.Validate("No.", PackingModuleSetUp."Shipping Cost Account No.");
                        GLAcc.Get(SalesLine."No.");
                        SalesLine.Validate(description, GLAcc.Name + '(' + ShipPackageHeader."Inventory Pick" + ')');
                        SalesLine.Validate(Quantity, 1);
                        SalesLine.Validate("Unit Price", CombineRateInfo."Total Shipping Rate for Customer");
                        SalesLine.Insert();
                        OnInsertSalesLinefromShippingModuleBuyShipment(CombineRateInfo."Total Shipping Rate for Customer", SalesLine);
                        // end
                        // else begin
                        //     SalesLine.Validate("Unit Price", CombineRateInfo."Total Shipping Rate for Customer");
                        //     SalesLine.Modify();
                        // end;
                    end;
                end;
            end;
        end;
        if StatusBefore = 'Released' then ReleaseSalesDoc.Run(SalesHeader);
    end;

    procedure BuyShipments(Var Rec: Record "Buy Shipment")
    var
        AuthString: Text;
        //  responstempblob: Record TempBlob;
        Base64: Codeunit "Base64 Convert";
        Response: HttpResponseMessage;
        request: HttpRequestMessage;
        responsetext: text;
        headers: HttpHeaders;
        jsonBuffertemt: Record "JSON Buffer" temporary;
        jsonbuffer: Record "JSON Buffer" temporary;
        content: HttpContent;
        PackingModuleSetup: Record "Packing Module Setup";
        Client: HttpClient;
        jObject: JsonObject;
        jObject2: JsonObject;
        URL: Text;
        Shippackagelines: Record "Sub Packing Lines";
        LabelPath: Text;
        PublicURLPath: text;
        trackingCodePath: Text;
        ShipPackageHeader: Record "Ship Package Header";
        SubPackageLineRec: Record "Sub Packing Lines";
        LineCountBox: Integer;
        LineCountPallet: Integer;
        SalesHeader: Record "Sales Header";
        shipmarkup: Record "Shipping MarkUp Setup";
        ShipAgent: Record "Shipping Agent";
        ShipAgentService: Record "Shipping Agent Services";
        SIEventMngt: Codeunit "SI Event Mgnt";
    begin
        URL := 'https://api.easypost.com/v2/shipments/' + Format(Rec."Shipment ID") + '/buy/';
        jObject.Add('id', Format(Rec."Rate ID"));
        jObject2.Add('rate', jObject);
        PackingModuleSetup.get();
        content.WriteFrom(Format(jObject2));
        content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        request.Content := content;
        request.Method := 'POST';
        request.SetRequestUri(URL);
        request.GetHeaders(Headers);
        if PackingModuleSetup."Mode Test" then
            AuthString := StrSubstNo('%1', PackingModuleSetup."EasyPost API Key")
        else
            AuthString := StrSubstNo('%1', PackingModuleSetup."EasyPost Live API Key");
        AuthString := Base64.ToBase64(AuthString);
        AuthString := StrSubstNo('Basic %1', AuthString);
        Headers.Add('Authorization', AuthString);
        Client.Get(URL, Response);
        Client.Send(request, Response);
        if not Response.IsSuccessStatusCode then begin
            Message('%1', Response.HttpStatusCode);
            Message(Response.ReasonPhrase);
        END;
        response.Content.ReadAs(responsetext);
        SIEventMngt.CreateAPILog(Rec."No.", Rec."Packing No", 'POST', Format(jObject2), responsetext, Response.HttpStatusCode, CurrentDateTime, URL);
        jsonbuffer.Reset();
        jsonbuffer.DeleteAll();
        jsonbuffer.ReadFromText(responsetext);
        Shippackagelines.Reset();
        Shippackagelines.SetRange("Packing No.", Rec."No.");
        Shippackagelines.SetRange("Box Sr ID/Packing No.", Rec."Packing No");
        Shippackagelines.SetRange("Packing Type", Shippackagelines."Packing Type"::Box);
        if Shippackagelines.FindFirst() then begin
            LabelPath := 'postage_label.label_url';
            jsonbuffer.Reset();
            jsonbuffer.SetFilter(Path, LabelPath);
            jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::String);
            if jsonbuffer.FindFirst() then begin
                Shippackagelines.Validate("Label URL", jsonbuffer.GetValue());
            end;
            PublicURLPath := 'tracker.public_url';
            jsonbuffer.Reset();
            jsonbuffer.SetFilter(Path, PublicURLPath);
            jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::String);
            if jsonbuffer.FindFirst() then begin
                Shippackagelines.Validate(Shippackagelines."Tracking URL", jsonbuffer.GetValue());
            end;
            trackingCodePath := 'tracking_code';
            jsonbuffer.Reset();
            jsonbuffer.SetFilter(Path, trackingCodePath);
            jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::String);
            if jsonbuffer.FindFirst() then begin
                Shippackagelines.Validate("Tracking ID", jsonbuffer.GetValue());
            end;
            Shippackagelines.Modify();
        end;
    end;

    local procedure UpdateSatatistics(Rec: Record "Buy Shipment";
    CombinerateInfo: record "Combine Rate Information")
    var
        ShipPackageHeader: Record "Ship Package Header";
        SubPackageLineRec: Record "Sub Packing Lines";
        LineCountBox: Integer;
        LineCountPallet: Integer;
        SalesHeader: Record "Sales Header";
        shipmarkup: Record "Shipping MarkUp Setup";
        ShipAgent: Record "Shipping Agent";
        ShipAgentService: Record "Shipping Agent Services";
    begin
        ShipPackageHeader.Get(Rec."No.");
        ShipPackageHeader."Markup value" := 0;
        ShipPackageHeader."Total Shipping Rate for Customer" := 0;
        ShipPackageHeader.Validate("Freight Value", CombinerateInfo.Rate);
        ShipPackageHeader.Modify();
        // ShipPackageHeader."Markup value" := CombinerateInfo."Markup Value";
        ShipAgent.Reset();
        ShipAgent.SetRange("SI Get Rate Carrier", CombinerateInfo.Carrier);
        if ShipAgent.FindFirst() then;
        if ShipAgent."Packing Type" = ShipAgent."Packing Type"::Box then begin
            ShipPackageHeader."Total Shipping Rate for Customer" += ShipPackageHeader."Freight Value" + ShipPackageHeader."Box Markup value" + ShipPackageHeader."Insurance Markup for Box" + ShipPackageHeader."Additional Mark Up";
            ShipPackageHeader."Markup value" := ShipPackageHeader."Box Markup value";
        end
        else begin
            ShipPackageHeader."Total Shipping Rate for Customer" += ShipPackageHeader."Freight Value" + ShipPackageHeader."Pallet Markup value" + ShipPackageHeader."Insurance Markup for Pallet" + ShipPackageHeader."Additional Mark Up";
            ShipPackageHeader."Markup value" := ShipPackageHeader."Pallet Markup value";
        end;
        ShipAgent.Reset();
        ShipAgent.SetRange("SI Get Rate Carrier", Rec.Carrier);
        if ShipAgent.FindFirst() then begin
            SalesHeader.Reset();
            SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
            if SalesHeader.FindFirst() then begin
                SalesHeader.Validate("Shipping Agent Code", ShipAgent.Code);
                SalesHeader.Modify(false);
            end;
        end;
        ShipAgentService.Reset();
        ShipAgentService.SetRange("SI Get Rate service", Rec.Service);
        if ShipAgentService.FindFirst() then begin
            SalesHeader.Reset();
            SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
            if SalesHeader.FindFirst() then begin
                SalesHeader.Validate("Shipping Agent Service code", ShipAgentService.Code);
                SalesHeader.Modify(false);
            end;
        end;
        SalesHeader.Reset();
        SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
        if SalesHeader.FindFirst() then begin
            SalesHeader.Validate("SI Total Shipping Rate", CombinerateInfo."Total Shipping Rate for Customer");
            SalesHeader.Modify(false);
        end;
        // SalesHeader.Modify();
        ShipPackageHeader.Validate(Difference, Abs(ShipPackageHeader."Total Shipping Rate for Customer" - ShipPackageHeader."Existing Shipping Rate on SO/SQ"));
        ShipPackageHeader.Modify();
    end;

    procedure BuyInsuranceShipments(Var Rec: Record "Buy Shipment"): Boolean
    var
        AuthString: Text;
        //  responstempblob: Record TempBlob;
        Base64: Codeunit "Base64 Convert";
        Response: HttpResponseMessage;
        request: HttpRequestMessage;
        responsetext: text;
        headers: HttpHeaders;
        jsonBuffertemt: Record "JSON Buffer" temporary;
        jsonbuffer: Record "JSON Buffer";
        content: HttpContent;
        PackingModuleSetup: Record "Packing Module Setup";
        Client: HttpClient;
        jObject: JsonObject;
        jObject2: JsonObject;
        URL: Text;
        Shippackagelines: Record "Sub Packing Lines";
        LabelPath: Text;
        PublicURLPath: text;
        trackingCodePath: Text;
    begin
        URL := 'https://api.easypost.com/v2/shipments/' + Format(Rec."Shipment ID") + '/insure/';
        jObject.Add('amount', '100.01');
        // Message('%1', jObject2);
        PackingModuleSetup.get();
        content.WriteFrom(Format(jObject));
        content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        request.Content := content;
        request.Method := 'POST';
        request.SetRequestUri(URL);
        request.GetHeaders(Headers);
        AuthString := StrSubstNo('%1', PackingModuleSetup."EasyPost API Key");
        //  responstempblob.WriteAsText(AuthString, TextEncoding::UTF8);
        // AuthString := responstempblob.ToBase64String();
        AuthString := Base64.ToBase64(AuthString);
        AuthString := StrSubstNo('Basic %1', AuthString);
        Headers.Add('Authorization', AuthString);
        Client.Get(URL, Response);
        Client.Send(request, Response);
        if not Response.IsSuccessStatusCode then begin
            Message('%1', Response.HttpStatusCode);
            Message(responsetext);
            exit(false);
        END;
        response.Content.ReadAs(responsetext);
        jsonbuffer.Reset();
        jsonbuffer.DeleteAll();
        jsonBuffertemt.ReadFromText(responsetext);
        if jsonBuffertemt.FindSet() then
            repeat
                jsonbuffer := jsonBuffertemt;
                jsonbuffer.Insert();
            until jsonBuffertemt.Next() = 0;
        Shippackagelines.Reset();
        Shippackagelines.SetRange("Packing No.", Rec."No.");
        Shippackagelines.SetRange("Box Sr ID/Packing No.", Rec."Packing No");
        Shippackagelines.SetRange("Packing Type", Shippackagelines."Packing Type"::Box);
        if Shippackagelines.FindFirst() then begin
            LabelPath := 'postage_label.label_url';
            jsonbuffer.Reset();
            jsonbuffer.SetFilter(Path, LabelPath);
            jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::String);
            if jsonbuffer.FindFirst() then begin
                Shippackagelines.Validate("Label URL", jsonbuffer.GetValue());
            end;
            PublicURLPath := 'tracker.public_url';
            jsonbuffer.Reset();
            jsonbuffer.SetFilter(Path, PublicURLPath);
            jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::String);
            if jsonbuffer.FindFirst() then begin
                Shippackagelines.Validate(Shippackagelines."Tracking URL", jsonbuffer.GetValue());
            end;
            trackingCodePath := 'tracking_code';
            jsonbuffer.Reset();
            jsonbuffer.SetFilter(Path, trackingCodePath);
            jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::String);
            if jsonbuffer.FindFirst() then begin
                Shippackagelines.Validate("Tracking ID", jsonbuffer.GetValue());
            end;
            Shippackagelines.Modify();
            exit(true);
        end;
    end;

    procedure "ProcessRefund"(var ShipID: text[50]): text
    var
        EasyPostLink: Text;
        SubPackingLines: Record "Sub Packing Lines";
        BuyShipment: record "Buy Shipment";
        Password: Text;
        AuthString: Text;
        // responstempblob: Record TempBlob;
        Response: HttpResponseMessage;
        request: HttpRequestMessage;
        responsetext: text;
        headers: HttpHeaders;
        jsonBuffertemt: Record "JSON Buffer" temporary;
        jsonbuffer: Record "JSON Buffer";
        UserName: Text;
        client: HttpClient;
        PackingModuleSetUp: Record "Packing Module Setup";
        ShipPackageHeader: Record "Ship Package Header";
        Base64: Codeunit "Base64 Convert";
        MsgString: Text;
        MsgPosition: Integer;
        ErrorPosition: Integer;
        ResposneLength: Integer;
        SIEventMngt: Codeunit "SI Event Mgnt";
    begin
        EasyPostLink := 'https://api.easypost.com/v2/shipments/' + ShipID + '/refund';
        Password := '';
        // // request.SetRequestUri(EasyPostLink);
        // AuthString := STRSUBSTNO('%1:%2', UserName, Password);
        // // AuthString := TypeHelper.convertvaluetobase64(AuthString);
        // AuthString := responstempblob.ToBase64String();
        // AuthString := STRSUBSTNO('Basic %1', AuthString);
        // HttpClient.DefaultRequestHeaders().Add('Authorization', AuthString);
        // //headers.Add('Authorization', AuthString);
        // HttpClient.Get(EasyPostLink, Response);
        // if not Response.IsSuccessStatusCode then
        //     message('%1', Response.HttpStatusCode);
        // //HttpClient.Send(request, Response);
        // Response.Content.ReadAs(responsetext);
        //Message(responsetext);
        Clear(responsetext);
        //   Message(EasyPostLink);
        Clear(AuthString);
        headers.Clear();
        PackingModuleSetUp.Get();
        request.Method := 'POST';
        request.SetRequestUri(EasyPostLink);
        request.GetHeaders(Headers);
        if PackingModuleSetUp."Mode Test" then
            AuthString := StrSubstNo('%1', PackingModuleSetUp."EasyPost API Key")
        else
            AuthString := StrSubstNo('%1', PackingModuleSetUp."EasyPost Live API Key");
        // responstempblob.WriteAsText(AuthString, TextEncoding::UTF8);
        //  AuthString := responstempblob.ToBase64String();
        AuthString := Base64.ToBase64(AuthString);
        AuthString := StrSubstNo('Basic %1', AuthString);
        Headers.Add('Authorization', AuthString);
        client.Get(EasyPostLink, response);
        client.Send(request, response);
        response.Content.ReadAs(responsetext);
        if not Response.IsSuccessStatusCode then begin
            //   Message('%1', Response.HttpStatusCode);
            // Message(responsetext);
            BuyShipment.Reset();
            BuyShipment.SetRange("Shipment ID", ShipID);
            if BuyShipment.FindFirst() then;
            SIEventMngt.CreateAPILog(BuyShipment."No.", BuyShipment."Packing No", 'POST', '', responsetext, Response.HttpStatusCode, CurrentDateTime, EasyPostLink);
            MsgPosition := StrPos(responsetext, 'message');
            ErrorPosition := StrPos(responsetext, 'errors');
            ResposneLength := StrLen(responsetext);
            // Message('MsgPosition %1 \ ErrorPosition %2 \ ResposneLength %3', MsgPosition, ErrorPosition, ResposneLength);
            MsgString := CopyStr(responsetext, MsgPosition + 10, (ErrorPosition - 3) - (MsgPosition + 11));
            Message(MsgString);
        end;
        exit(responsetext);
    end;

    [BusinessEvent(false)]
    procedure OnInsertSalesLinefromShippingModuleBuyShipment(ShippingAmount: Decimal; salesline: Record "Sales Line")
    begin

    end;
}
