codeunit 55001 "Rate Mgnt"
{
    procedure AddHttpBasicAuthHeader(SubPackingLines: Record "Sub Packing Lines"): text;
    var
        AuthString: Text;
        //  responstempblob: Record TempBlob;
        Response: HttpResponseMessage;
        request: HttpRequestMessage;
        EasyPostLink: text;
        responsetext: text;
        headers: HttpHeaders;
        jsonBuffertemt: Record "JSON Buffer" temporary;
        jsonbuffer: Record "JSON Buffer";
        Password: Text;
        UserName: Text;
        // TypeHelper: Codeunit "Type Helper";
        Base64: Codeunit "Base64 Convert";
    begin
        //UserName := 'EZTK8069182a35cf49ea896f89e54629d942wmRjzkNTvZGT30oERnVExg';//SN Commented
        EasyPostLink := 'https://api.easypost.com/v2/trackers/' + SubPackingLines."Tracking ID";
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
        // Message(responsetext);
        request.Method := 'GET';
        request.SetRequestUri(EasyPostLink);
        request.GetHeaders(Headers);
        AuthString := StrSubstNo('%1', UserName);
        // responstempblob.WriteAsText(AuthString, TextEncoding::UTF8);
        //  AuthString := responstempblob.ToBase64String();
        AuthString := Base64.ToBase64(AuthString);
        AuthString := StrSubstNo('Basic %1', AuthString);
        Headers.Add('Authorization', AuthString);
        HttpClient.Get(EasyPostLink, response);
        HttpClient.Send(request, response);
        response.Content.ReadAs(responsetext);
        exit(responsetext);
    end;

    procedure EasyPostGetRate(Var Rec: Record "Ship Package Header");
    var
        JsonObjectVar: JsonObject;
        i: Integer;
        PathJson: Text;
        SubPackingLines: Record "Sub Packing Lines";
        content: HttpContent;
        client: HttpClient;
        Headers: HttpHeaders;
        request: HttpRequestMessage;
        PackingModuleSetup: Record "Packing Module Setup";
        AuthString: Text;
        Response: HttpResponseMessage;
        responsetext: Text;
        JsonBuffer: Record "JSON Buffer" temporary;
        JsonBuffer1: Record "JSON Buffer" temporary;
        jsonBuffertemp: Record "JSON Buffer" temporary;
        BuyShipment: Record "Buy Shipment";
        ShipmentIDPath: text;
        RatePath: text;
        ShipID: text;
        BuyShipmentLast: Record "Buy Shipment";
        BuyShipment1: Record "Buy Shipment";
        ratetext: text;
        ratedec: Decimal;
        DeliveryDaystxt: text;
        DeliveryDaysint: Integer;
        DateGrnttext: text;
        dateGrntBoolean: Boolean;
        BuyShipment2: Record "Buy Shipment";
        SubPackingLines2: Record "Sub Packing Lines";
        Base64: Codeunit "Base64 Convert";
        AgentServiceOptions: Record "Agent Service Option";
        ShipMarkup: Record "Shipping MarkUp Setup";
        SIEventMngt: Codeunit "SI Event Mgnt";
        ShipPackageHeader: Record "Ship Package Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        PackingModuleSetup.Get();
        SubPackingLines.Reset();
        SubPackingLines.SetRange("Packing No.", Rec.No);
        if SubPackingLines.FindSet() then begin
            repeat
                SubPackingLines2.Reset();
                SubPackingLines2.SetRange("Packing No.", SubPackingLines."Packing No.");
                SubPackingLines2.SetRange("Line No.", SubPackingLines."Line No.");
                if SubPackingLines2.FindFirst() then begin
                    Clear(GrandMasterJson);
                    Clear(MasterJson);
                    Clear(JsonObjectVar);
                    for i := 1 to 5 do begin
                        SetJSONData(SubPackingLines2, I);
                    end;
                    Clear(AuthString);
                    Clear(Headers);
                    Clear(content);
                    Clear(request);
                    Clear(Response);
                    Clear(client);
                    //  Clear(responstempblob);
                    GrandMasterJson.Add('shipment', MasterJson);
                    // Message('%1', GrandMasterJson);
                    content.WriteFrom(Format(GrandMasterJson));
                    Message(Format(GrandMasterJson));
                    content.GetHeaders(Headers);
                    Headers.Clear();
                    Headers.Add('Content-Type', 'application/json');
                    request.Content := content;
                    request.Method := 'POST';
                    request.SetRequestUri(PackingModuleSetup."EasyPost URL");
                    request.GetHeaders(Headers);
                    if PackingModuleSetup."Mode Test" then
                        AuthString := StrSubstNo('%1', PackingModuleSetup."EasyPost API Key")
                    else
                        AuthString := StrSubstNo('%1', PackingModuleSetup."EasyPost Live API Key");
                    AuthString := Base64.ToBase64(AuthString);
                    AuthString := StrSubstNo('Basic %1', AuthString);
                    Headers.Add('Authorization', AuthString);
                    Client.Get(PackingModuleSetup."EasyPost URL", response);
                    Client.Send(request, response);
                    if not Response.IsSuccessStatusCode then begin
                        Message('%1', Response.HttpStatusCode);
                        Message(Response.ReasonPhrase);
                    END;
                    response.Content.ReadAs(responsetext);
                    SIEventMngt.CreateAPILog(SubPackingLines."Packing No.", SubPackingLines."Box Sr ID/Packing No.", 'POST', Format(GrandMasterJson), responsetext, Response.HttpStatusCode, CurrentDateTime, PackingModuleSetup."EasyPost URL");
                    //Message(responsetext);
                    JsonBuffer.Reset();
                    JsonBuffer.DeleteAll();
                    jsonBuffertemp.ReadFromText(responsetext);
                    if jsonBuffertemp.FindSet() then
                        repeat
                            JsonBuffer := jsonBuffertemp;
                            JsonBuffer.Insert();
                        until jsonBuffertemp.Next() = 0;
                    ShipmentIDPath := 'rates[0].shipment_id';
                    JsonBuffer.Reset();
                    JsonBuffer.SetFilter(Path, ShipmentIDPath);
                    JsonBuffer.SetFilter("Token type", '%1', JsonBuffer."Token type"::String);
                    if JsonBuffer.FindFirst() then ShipID := JsonBuffer.GetValue();
                    //     BuyShipment2.Reset();
                    //     BuyShipment2.SetRange("No.", rec.No);
                    //     BuyShipment2.SetRange("Rate ID", JsonBuffer1.GetValue());
                    //     if BuyShipment2.FindSet() then
                    //         BuyShipment2.DeleteAll();
                    // end;
                    //Message(ShipID);
                    i := 0;
                    begin
                        repeat
                            clear(ratedec);
                            Clear(DeliveryDaysint);
                            RatePath := 'rates[' + Format(i) + '].*';
                            JsonBuffer.Reset();
                            JsonBuffer.Setfilter(Path, RatePath);
                            JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                            if JsonBuffer.FindSet() then begin
                                if Rec."Get All Rates EasyPost" = false then begin
                                    AgentServiceOptions.Reset();
                                    AgentServiceOptions.SetRange("Packing No", Rec.No);
                                    AgentServiceOptions.SetRange(Choose, true);
                                    if AgentServiceOptions.FindSet() then
                                        repeat
                                            JsonBuffer.Reset();
                                            // JsonBuffer.Setfilter(Path, RatePath);
                                            JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                            JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].service');
                                            if JsonBuffer.FindFirst() then
                                                if JsonBuffer.GetValue() = AgentServiceOptions."Agent Service" then begin
                                                    BuyShipmentLast.Reset();
                                                    BuyShipmentLast.SetRange("No.", Rec."No");
                                                    if BuyShipmentLast.FindLast() then;
                                                    BuyShipment.Init();
                                                    BuyShipment.Validate("No.", rec."No");
                                                    BuyShipment.Validate("Packing No", SubPackingLines."Box Sr ID/Packing No.");
                                                    BuyShipment.Validate("Line No.", BuyShipmentLast."Line No." + 10000);
                                                    BuyShipment.Validate("Shipment ID", ShipID);
                                                    BuyShipment.Insert();
                                                    //repeat
                                                    BuyShipment1.Reset();
                                                    BuyShipment1.SetRange("No.", BuyShipment."No.");
                                                    BuyShipment1.SetRange("Line No.", BuyShipment."Line No.");
                                                    if BuyShipment1.FindFirst() then begin
                                                        //if 'rates[' + Format(i) + '].id' = JsonBuffer.Path then
                                                        JsonBuffer.Reset();
                                                        JsonBuffer.Setfilter(Path, RatePath);
                                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].id');
                                                        if JsonBuffer.FindFirst() then BuyShipment1.Validate(BuyShipment1."Rate ID", JsonBuffer.GetValue());
                                                        JsonBuffer.Reset();
                                                        JsonBuffer.Setfilter(Path, RatePath);
                                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].carrier');
                                                        if JsonBuffer.FindFirst() then //if 'rates[' + Format(i) + '].carrier' = JsonBuffer.Path then
                                                            BuyShipment1.Validate(Carrier, JsonBuffer.GetValue());
                                                        JsonBuffer.Reset();
                                                        JsonBuffer.Setfilter(Path, RatePath);
                                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].service');
                                                        if JsonBuffer.FindFirst() then //if 'rates[' + Format(i) + '].service' = JsonBuffer.Path then
                                                            BuyShipment1.Validate(service, JsonBuffer.GetValue());
                                                        JsonBuffer.Reset();
                                                        JsonBuffer.Setfilter(Path, RatePath);
                                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].currency');
                                                        if JsonBuffer.FindFirst() then //if 'rates[' + Format(i) + '].currency' = JsonBuffer.Path then
                                                            BuyShipment1.Validate(currency, JsonBuffer.GetValue());
                                                        JsonBuffer.Reset();
                                                        JsonBuffer.Setfilter(Path, RatePath);
                                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].rate');
                                                        if JsonBuffer.FindFirst() then begin
                                                            //if 'rates[' + Format(i) + '].list_rate' = JsonBuffer.Path then begin
                                                            ratetext := JsonBuffer.GetValue();
                                                            Evaluate(ratedec, ratetext);
                                                            BuyShipment1.Validate(rate, ratedec);
                                                        end;
                                                        JsonBuffer.Reset();
                                                        JsonBuffer.Setfilter(Path, RatePath);
                                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].delivery_days');
                                                        if JsonBuffer.FindFirst() then begin
                                                            //if 'rates[' + Format(i) + '].delivery_days' = JsonBuffer.Path then begin
                                                            if JsonBuffer.GetValue() <> '' then begin
                                                                DeliveryDaystxt := JsonBuffer.GetValue();
                                                                Evaluate(DeliveryDaysint, DeliveryDaystxt);
                                                                BuyShipment1.Validate("Delivery Days", DeliveryDaysint);
                                                            end;
                                                        end;

                                                        JsonBuffer.Reset();
                                                        JsonBuffer.Setfilter(Path, RatePath);
                                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].delivery_date_guaranteed');
                                                        if JsonBuffer.FindFirst() then begin
                                                            //if 'rates[' + Format(i) + '].delivery_date_guaranteed' = JsonBuffer.Path then begin
                                                            DateGrnttext := JsonBuffer.GetValue();
                                                            Evaluate(dateGrntBoolean, DateGrnttext);
                                                            BuyShipment1.Validate("delivery date guaranteed", dateGrntBoolean);
                                                        end;

                                                        JsonBuffer.Reset();
                                                        JsonBuffer.Setfilter(Path, RatePath);
                                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].carrier_account_id');
                                                        if JsonBuffer.FindFirst() then begin
                                                            //if 'rates[' + Format(i) + '].delivery_days' = JsonBuffer.Path then begin
                                                            if JsonBuffer.GetValue() <> '' then begin
                                                                BuyShipment1.Validate("EasyPost CA Account", JsonBuffer.GetValue());
                                                                ShippingAgent.reset;
                                                                ShippingAgent.SetRange("EasyPost CA Account", JsonBuffer.GetValue());
                                                                if ShippingAgent.FindFirst() then begin
                                                                    BuyShipment1."EasyPost CA Name" := ShippingAgent."SI Get Rate Carrier";
                                                                    if ShippingAgent."Make Carrier Base Price ZERO" then//SN-12042023++ added Condition, it must be used as third party account
                                                                        BuyShipment1.Rate := 0;

                                                                end;
                                                            end;
                                                        end;
                                                        ShippingAgent.reset;
                                                        ShippingAgent.SetRange(Code, AgentServiceOptions.Agent);
                                                        ShippingAgent.SetRange("EasyPost CA Account", JsonBuffer.GetValue());
                                                        if ShippingAgent.FindFirst() then
                                                            BuyShipment1.Modify();
                                                    end;
                                                end;
                                        until AgentServiceOptions.Next() = 0;
                                end
                                else begin
                                    BuyShipmentLast.Reset();
                                    BuyShipmentLast.SetRange("No.", Rec."No");
                                    if BuyShipmentLast.FindLast() then;
                                    BuyShipment.Init();
                                    BuyShipment.Validate("No.", rec."No");
                                    BuyShipment.Validate("Packing No", SubPackingLines."Box Sr ID/Packing No.");
                                    BuyShipment.Validate("Line No.", BuyShipmentLast."Line No." + 10000);
                                    BuyShipment.Validate("Shipment ID", ShipID);
                                    BuyShipment.Insert();
                                    //repeat
                                    BuyShipment1.Reset();
                                    BuyShipment1.SetRange("No.", BuyShipment."No.");
                                    BuyShipment1.SetRange("Line No.", BuyShipment."Line No.");
                                    if BuyShipment1.FindFirst() then begin
                                        //if 'rates[' + Format(i) + '].id' = JsonBuffer.Path then
                                        JsonBuffer.Reset();
                                        JsonBuffer.Setfilter(Path, RatePath);
                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].id');
                                        if JsonBuffer.FindFirst() then BuyShipment1.Validate(BuyShipment1."Rate ID", JsonBuffer.GetValue());
                                        JsonBuffer.Reset();
                                        JsonBuffer.Setfilter(Path, RatePath);
                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].carrier');
                                        if JsonBuffer.FindFirst() then //if 'rates[' + Format(i) + '].carrier' = JsonBuffer.Path then
                                            BuyShipment1.Validate(Carrier, JsonBuffer.GetValue());
                                        JsonBuffer.Reset();
                                        JsonBuffer.Setfilter(Path, RatePath);
                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].service');
                                        if JsonBuffer.FindFirst() then //if 'rates[' + Format(i) + '].service' = JsonBuffer.Path then
                                            BuyShipment1.Validate(service, JsonBuffer.GetValue());
                                        JsonBuffer.Reset();
                                        JsonBuffer.Setfilter(Path, RatePath);
                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].currency');
                                        if JsonBuffer.FindFirst() then //if 'rates[' + Format(i) + '].currency' = JsonBuffer.Path then
                                            BuyShipment1.Validate(currency, JsonBuffer.GetValue());
                                        JsonBuffer.Reset();
                                        JsonBuffer.Setfilter(Path, RatePath);
                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].rate');
                                        if JsonBuffer.FindFirst() then begin
                                            //if 'rates[' + Format(i) + '].list_rate' = JsonBuffer.Path then begin
                                            ratetext := JsonBuffer.GetValue();
                                            Evaluate(ratedec, ratetext);
                                            BuyShipment1.Validate(rate, ratedec);
                                        end;
                                        JsonBuffer.Reset();
                                        JsonBuffer.Setfilter(Path, RatePath);
                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].delivery_days');
                                        if JsonBuffer.FindFirst() then begin
                                            //if 'rates[' + Format(i) + '].delivery_days' = JsonBuffer.Path then begin
                                            if JsonBuffer.GetValue() <> '' then begin
                                                DeliveryDaystxt := JsonBuffer.GetValue();
                                                Evaluate(DeliveryDaysint, DeliveryDaystxt);
                                                BuyShipment1.Validate("Delivery Days", DeliveryDaysint);
                                            end;
                                        end;
                                        JsonBuffer.Reset();
                                        JsonBuffer.Setfilter(Path, RatePath);
                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].carrier_account_id');
                                        if JsonBuffer.FindFirst() then begin
                                            //if 'rates[' + Format(i) + '].delivery_days' = JsonBuffer.Path then begin
                                            if JsonBuffer.GetValue() <> '' then begin
                                                BuyShipment1.Validate("EasyPost CA Account", JsonBuffer.GetValue());
                                                ShippingAgent.reset;
                                                ShippingAgent.SetRange("EasyPost CA Account", JsonBuffer.GetValue());
                                                if ShippingAgent.FindFirst() then begin
                                                    BuyShipment1."EasyPost CA Name" := ShippingAgent."SI Get Rate Carrier";
                                                    if ShippingAgent."Make Carrier Base Price ZERO" then//SN-12042023++ added Condition, it must be used as third party account
                                                        BuyShipment1.Rate := 0;
                                                end;
                                            end;
                                        end;
                                        JsonBuffer.Reset();
                                        JsonBuffer.Setfilter(Path, RatePath);
                                        JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
                                        JsonBuffer.SetFilter(Path, 'rates[' + Format(i) + '].delivery_date_guaranteed');
                                        if JsonBuffer.FindFirst() then begin
                                            //if 'rates[' + Format(i) + '].delivery_date_guaranteed' = JsonBuffer.Path then begin
                                            DateGrnttext := JsonBuffer.GetValue();
                                            Evaluate(dateGrntBoolean, DateGrnttext);
                                            BuyShipment1.Validate("delivery date guaranteed", dateGrntBoolean);
                                        end;

                                        BuyShipment1.Modify();
                                    end;
                                end;
                            end;
                            i := i + 1;
                        until i = 30;
                    end;
                end;
                BuyShipment.reset;
                BuyShipment.SetRange("No.", rec."No");
                BuyShipment.SetRange("Packing No", SubPackingLines."Box Sr ID/Packing No.");
                BuyShipment.SetRange(Carrier, '');
                BuyShipment.SetRange(Service, '');
                BuyShipment.SetRange(Rate, 0);
                if BuyShipment.FindSet() then
                    BuyShipment.DeleteAll();
            until SubPackingLines.Next() = 0;
        end;
        if ShipPackageHeader.Get(BuyShipment."No.") then;
        if ShipPackageHeader."Use 3rd Party Shipping Account" then begin
            // ShipMarkup.reset();
            // if ShipMarkup.Get(Rec."Ship-to Customer No.") then begin
            //     if ShipMarkup."Customer Shipping Carrier" <> '' then begin
            BuyShipment.Reset();
            BuyShipment.SetRange("No.", Rec.No);
            // BuyShipment.SetRange(Carrier, ShipMarkup."Customer Shipping Carrier");
            if BuyShipment.FindSet() then
                repeat
                    if UpperCase(BuyShipment.Carrier) = UpperCase(ShipPackageHeader."3rd Party Carrier") then begin
                        BuyShipment.Rate := 0;
                        BuyShipment.Modify();
                    end;
                until BuyShipment.Next() = 0
            // else begin
            //     ShipMarkup.Get();
            //     if ShipMarkup."Customer Shipping Carrier" <> '' then begin
            //         BuyShipment.Reset();
            //         BuyShipment.SetRange("Packing No", Rec.No);
            //         // BuyShipment.SetRange(Carrier, ShipMarkup."Customer Shipping Carrier");
            //         if BuyShipment.FindSet() then
            //             repeat
            //                 if UpperCase(BuyShipment.Carrier) = UpperCase(ShipMarkup."Customer Shipping Carrier") then begin
            //                     BuyShipment.Rate := 0;
            //                     BuyShipment.Modify();
            //                 end;
            //             until BuyShipment.Next() = 0;
            //     end;
            // end;
        end;
    end;

    local procedure SetJSONData(SubPackingLines: Record "Sub Packing Lines";
    I: Integer)
    var
        JsonObjectVar: JsonObject;
        ShipPackageHeader: Record "Ship Package Header";
        Location: Record Location;
        Boxmaster: Record "Box Master";
        shippingMarkupSetup: Record "Shipping MarkUp Setup";
    begin
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange(No, SubPackingLines."Packing No.");
        if ShipPackageHeader.FindFirst() then begin
            "Boxmaster".Get(SubPackingLines."Box Code / Packing Type");
            Location.Get(ShipPackageHeader.Location);
        end;
        case I of
            1:
                begin
                    MasterJson.Add('object', 'Shipment');
                    SetShippingToAddress(ShipPackageHeader);
                end;
            2:
                begin
                    SetShippingFromAddress(Location);
                    CarrierInsurance(SubPackingLines, ShipPackageHeader);
                end;
            3:
                begin
                    ParcelInfo(Boxmaster, SubPackingLines);
                end;
            4:
                begin
                    Custom_info(SubPackingLines);
                end;
        end;
    end;

    local procedure SetShippingToAddress(ShipPackageHeader: Record "Ship Package Header")
    var
        myInt: Integer;
        JsonObjectVar: JsonObject;
        PackingModuleSetup: Record "Packing Module Setup";
    begin
        PackingModuleSetup.get();

        Clear(JsonObjectVar);
        JsonObjectVar.Add('name', ShipPackageHeader."Ship-to Name");
        JsonObjectVar.Add('company', ShipPackageHeader."Ship-to Company");
        // if (ShipPackageHeader."Delivery Message" <> 'Success') and (ShipPackageHeader."Zip Message" <> 'Success') then begin
        // if ShipPackageHeader."Use Ship-to Adsress" = true then begin
        JsonObjectVar.Add('street1', ShipPackageHeader."Ship-to Address");
        if ShipPackageHeader."Ship-to Address 2" <> '' then
            JsonObjectVar.Add('street2', ShipPackageHeader."Ship-to Address 2")
        else
            JsonObjectVar.Add('street2', '');
        JsonObjectVar.Add('city', ShipPackageHeader."Ship-to City");
        JsonObjectVar.Add('state', ShipPackageHeader."Ship-to County");
        JsonObjectVar.Add('zip', ShipPackageHeader."Ship-to Post Code");
        JsonObjectVar.Add('country', ShipPackageHeader."Ship-to Country/Region Code");
        // end else
        //     Error('Ship-to Address is Incorrect.');
        // end else begin
        //     JsonObjectVar.Add('street1', ShipPackageHeader."Suggested Addr");
        //     if ShipPackageHeader."Suggested Addr 2" <> '' then
        //         JsonObjectVar.Add('street2', ShipPackageHeader."Suggested Addr 2")
        //     else
        //         JsonObjectVar.Add('street2', '');
        //     JsonObjectVar.Add('city', ShipPackageHeader."Suggested City");
        //     JsonObjectVar.Add('state', ShipPackageHeader."Suggested State");
        //     JsonObjectVar.Add('zip', ShipPackageHeader."Suggested Post Code");
        //     JsonObjectVar.Add('country', ShipPackageHeader."Suggested Country Code");
        // end;
        if ShipPackageHeader."Ship-to Contact No." <> '' then
            JsonObjectVar.Add('phone', ShipPackageHeader."Ship-to Contact No.")
        Else
            JsonObjectVar.Add('phone', 'Null');

        if PackingModuleSetup."Mode Test" = true then
            JsonObjectVar.Add('mode', 'test')
        else
            JsonObjectVar.Add('mode', 'production');

        //JsonObjectVar.add('options', '"currency": "USD", "payment": {"type": "SENDER"}');

        JsonObjectVar.Add('carrier_facility', 'Null');
        if ShipPackageHeader.Residential then
            JsonObjectVar.Add('residential', 'true')
        else
            JsonObjectVar.Add('residential', 'false');
        JsonObjectVar.Add('email', ShipPackageHeader."Ship-to Email");
        MasterJson.Add('reference', ShipPackageHeader."Document No.");
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
        if Location."Name" <> '' then begin
            JsonObjectVar.Add('name', Location."Name");
            JsonObjectVar.Add('company', Location."Name");
        end
        else begin
            JsonObjectVar.Add('name', 'null');
            JsonObjectVar.Add('company', 'null');
        end;
        if Location."Address" <> '' then
            JsonObjectVar.Add('street1', Location."Address")
        Else
            JsonObjectVar.Add('street1', '');
        if Location."Address 2" <> '' then
            JsonObjectVar.Add('street2', Location."Address 2")
        else
            JsonObjectVar.Add('street2', '');
        JsonObjectVar.Add('city', Location."City");
        JsonObjectVar.Add('state', Location."County");
        JsonObjectVar.Add('zip', Location."Post Code");
        JsonObjectVar.Add('country', Location."Country/Region Code");
        if Location."Phone No." <> '' then
            JsonObjectVar.Add('phone', Location."Phone No.")
        else
            JsonObjectVar.Add('phone', 'null');
        JsonObjectVar.Add('email', Location."E-Mail");
        if PackingModuleSetup."Mode Test" = true then
            JsonObjectVar.Add('mode', 'test')
        else
            JsonObjectVar.Add('mode', 'production');
        JsonObjectVar.Add('carrier_facility', 'null');
        JsonObjectVar.Add('residential', 'null');
        MasterJson.Add('from_address', JsonObjectVar);
        //Clear(MasterJson);
    end;

    local procedure CarrierInsurance(SubPackingLines: record "Sub Packing Lines";
    Shippackageheader: Record "Ship Package Header")
    var
        JsonObjectVar: JsonObject;
        Readjustpacking: Record "ReAdjust Packing";
        shippingMarkupSetup: Record "Shipping MarkUp Setup";
        PaymentJsonObjectVar: JsonObject;
        PaymentJsonObjectVar1: JsonObject;
        PackingModuleSetup: Record "Packing Module Setup";
    begin
        if shippingMarkupSetup.Get(ShipPackageHeader."Ship-to Customer No.") then begin
            if (shippingMarkupSetup."Box Shipping Insurance?" = shippingMarkupSetup."Box Shipping Insurance?"::Carrier) then JsonObjectVar.Add('carrier_insurance_amount', SubPackingLines."Insurance Price");
        end
        else begin
            shippingMarkupSetup.Reset();
            shippingMarkupSetup.SetFilter("Customer No.", '');
            if shippingMarkupSetup.FindFirst() then begin
                if (shippingMarkupSetup."Box Shipping Insurance?" = shippingMarkupSetup."Box Shipping Insurance?"::Carrier) then JsonObjectVar.Add('carrier_insurance_amount', SubPackingLines."Insurance Price");
            end;
        end;
        JsonObjectVar.Add('print_custom_1', Shippackageheader."Customer PO No");
        JsonObjectVar.Add('print_custom_2', Shippackageheader."Inventory Pick" + ' | ' + Shippackageheader."Document No.");
        JsonObjectVar.Add('print_custom_1_code', 'PO');
        JsonObjectVar.Add('print_custom_2_code', 'DP');
        if Shippackageheader."Use 3rd Party Shipping Account" then begin
            Shippackageheader.TestField("3rd Party Account No.");
            Shippackageheader.TestField("3rd Party Carrier");
            Shippackageheader.TestField("3rd Party Account Zip");
            Shippackageheader.TestField("3rd Party country");
            PaymentJsonObjectVar.Add('type', 'THIRD_PARTY');
            PaymentJsonObjectVar.Add('account', Shippackageheader."3rd Party Account No.");
            PaymentJsonObjectVar.Add('country', Shippackageheader."3rd Party country");
            PaymentJsonObjectVar.Add('postal_code', Shippackageheader."3rd Party Account Zip");
            JsonObjectVar.Add('payment', PaymentJsonObjectVar);
        end;
        MasterJson.Add('options', JsonObjectVar);
    end;

    local procedure ParcelInfo(Boxmaster: Record "Box Master";
    ShipPackinglines: Record "Sub Packing Lines")
    var
        JsonObjectVar: JsonObject;
        Item: Record Item;
        PackingModuleSetup: Record "Packing Module Setup";
        PackingAdjustment: Record "Packing Adjustment";
        jsonArrayCA: JsonArray;
        ShipPackageHeader: Record "Ship Package Header";
        shippingAgent: Record "Shipping Agent";
        AgentServiceOptions: Record "Agent Service Option";
    begin
        PackingModuleSetup.Get();
        PackingAdjustment.Get(ShipPackinglines."Packing No.", ShipPackinglines."Box Sr ID/Packing No.");
        //Item.get(ShipPackinglines."Item No.");
        Clear(JsonObjectVar);
        JsonObjectVar.Add('length', PackingAdjustment.L);
        JsonObjectVar.Add('width', PackingAdjustment.W);
        JsonObjectVar.Add('height', PackingAdjustment.H);
        //  JsonObjectVar.Add('predefined_package', 'null');
        JsonObjectVar.Add('weight', PackingAdjustment."Total Gross Ship Wt");
        MasterJson.Add('parcel', JsonObjectVar);
        Clear(JsonObjectVar);
        if ShipPackageHeader.Get(ShipPackinglines."Packing No.") then // if ShipPackageHeader.Agent <> '' then
            //     if Not ShipPackageHeader."Get All Rates EasyPost" then begin
            //         shippingAgent.get(ShipPackageHeader.Agent);
            //         if shippingAgent."EasyPost CA Account" <> '' then begin
            //             jsonArrayCA.add(shippingAgent."EasyPost CA Account");
            //             MasterJson.Add('carrier_accounts', jsonArrayCA);
            //         end;
            //         //Clear(MasterJson);
            //     end;
            if not ShipPackageHeader."Use 3rd Party Shipping Account" then begin
                if not ShipPackageHeader."Get All Rates EasyPost" then begin
                    AgentServiceOptions.Reset();
                    AgentServiceOptions.SetRange("Packing No", ShipPackageHeader.No);
                    AgentServiceOptions.SetRange(Choose, true);
                    if AgentServiceOptions.FindSet() then
                        repeat
                            shippingAgent.Get(AgentServiceOptions.Agent);
                            jsonArrayCA.add(shippingAgent."EasyPost CA Account");
                        until AgentServiceOptions.Next() = 0;
                    MasterJson.Add('carrier_accounts', jsonArrayCA);
                end;
            end else begin
                ShipPackageHeader.TestField("3rd Party Carrier");
                if shippingAgent.Get(ShipPackageHeader."3rd Party Carrier") then;
                jsonArrayCA.add(shippingAgent."EasyPost CA Account");
                MasterJson.Add('carrier_accounts', jsonArrayCA);
            end;
    end;

    local procedure Custom_info(ShipPackageLines: Record "Sub Packing Lines")
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
    ShipPackageLines: Record "Sub Packing Lines";
    ShipPackageHeader: Record "Ship Package Header")
    var
        Location: Record Location;
        ShipPackageModule: Record "Packing Module Setup";
        ReadjustPacking: Record "ReAdjust Packing";
        ItemsDescription: Text;
    begin
        Clear(ItemsDescription);
        ReadjustPacking.Reset();
        ReadjustPacking.SetRange("Packing No", ShipPackageLines."Packing No.");
        ReadjustPacking.SetRange("Box ID", ShipPackageLines."Box Sr ID/Packing No.");
        if ReadjustPacking.FindSet() then
            repeat
                if ItemsDescription = '' then
                    ItemsDescription := ReadjustPacking."Item Description" + ' X ' + format(ReadjustPacking."Qty to pack in this Box")
                else
                    ItemsDescription += ' ' + ReadjustPacking."Item Description" + ' X ' + format(ReadjustPacking."Qty to pack in this Box");
            until ReadjustPacking.Next() = 0;
        ShipPackageModule.get();
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange(No, ShipPackageLines."Packing No.");
        if ShipPackageHeader.FindFirst() then;
        Boxmaster.Get(ShipPackageLines."Box Code / Packing Type");
        Location.Get(ShipPackageHeader.Location);
        Clear(ChildJeson);
        Clear(ChildJesonArray);
        ChildJeson.Add('description', ItemsDescription);
        ChildJeson.Add('hs_tariff_number', '');
        ChildJeson.Add('origin_country', Location."Country/Region Code");
        ChildJeson.Add('quantity', ShipPackageLines."Qty Packed");
        ChildJeson.Add('value', 1);
        ChildJeson.Add('weight', ShipPackageLines."Total Gross Ship Wt");
        ChildJesonArray.Add(ChildJeson);
        JsonObjectVar.Add('customs_items', ChildJesonArray);
        //Clear(ChildJeson);
    end;

    procedure CombineRateInformation(ShipPackingHeader: Record "Ship Package Header")
    var
        BuyShipment: Record "Buy Shipment";
        // RLGetRates: Record "RL Rate Quote";
        CombineRateInformation: Record "Combine Rate Information";
        CombineRateInformation2: Record "Combine Rate Information";
        CombineRateInformationLast: Record "Combine Rate Information";
        ShippingAgent: Record "Shipping Agent";
    Begin
        CombineRateInformation2.reset();
        CombineRateInformation2.SetRange("Packing No.", ShipPackingHeader.No);
        if CombineRateInformation2.FindSet() then CombineRateInformation2.DeleteAll();
        BuyShipment.Reset();
        BuyShipment.SetRange(BuyShipment."No.", ShipPackingHeader.No);
        if BuyShipment.FindSet() then begin
            Repeat
                CombineRateInformation2.reset();
                CombineRateInformation2.SetRange(Carrier, BuyShipment.Carrier);
                CombineRateInformation2.SetRange(Service, BuyShipment.Service);
                CombineRateInformation2.SetRange("EasyPost CA Account", BuyShipment."EasyPost CA Account");
                CombineRateInformation2.SetRange("Packing No.", BuyShipment."No.");
                if Not CombineRateInformation2.FindFirst() then begin
                    CombineRateInformationLast.Reset();
                    // CombineRateInformationLast.SetRange("Packing No.", ShipPackingHeader.No);
                    if CombineRateInformationLast.FindLast() then;
                    CombineRateInformation.Init();
                    CombineRateInformation."Entry No." := CombineRateInformationLast."Entry No." + 1;
                    CombineRateInformation."Packing No." := BuyShipment."No.";
                    CombineRateInformation.Rate := BuyShipment.Rate;
                    CombineRateInformation.Validate(Carrier, BuyShipment.Carrier);
                    CombineRateInformation.Service := BuyShipment.Service;
                    CombineRateInformation."Delivery Days" := BuyShipment."Delivery Days";
                    if BuyShipment."EasyPost CA Account" <> '' then begin
                        ShippingAgent.reset;
                        ShippingAgent.SetRange("EasyPost CA Account", BuyShipment."EasyPost CA Account");
                        if ShippingAgent.FindFirst() then
                            CombineRateInformation."EasyPost CA Name" := ShippingAgent."SI Get Rate Carrier";
                    End else
                        CombineRateInformation."EasyPost CA Name" := BuyShipment."EasyPost CA Name";//SN-01062023+
                    CombineRateInformation."EasyPost CA Account" := BuyShipment."EasyPost CA Account";
                    CombineRateInformation.Insert();
                end
                Else begin
                    CombineRateInformation2.Rate += BuyShipment.Rate;
                    CombineRateInformation2."Total Shipping Rate for Customer" := CombineRateInformation2.Rate + CombineRateInformation2."Markup Value";
                    CombineRateInformation2.Modify();
                end;
            until BuyShipment.Next() = 0;
        end;
    end;

    procedure CheckGetRateForAllBoxes(ShipPackageHeader: Record "Ship Package Header")
    var
        CombineRateInfo: Record "Combine Rate Information";
        BuyShipment: Record "Buy Shipment";
        SubPackingLines: Record "Sub Packing Lines";
    begin

        CombineRateInfo.Reset();
        CombineRateInfo.SetRange("Packing No.", ShipPackageHeader.No);
        if CombineRateInfo.FindSet() then begin
            repeat
                // if not (CombineRateInfo.Carrier in ['YRC', 'RL Carrier', 'Customer PickUp', 'Truck Freight', 'Custom Freight']) then begin
                SubPackingLines.Reset();
                SubPackingLines.SetRange("Packing No.", ShipPackageHeader.No);
                if SubPackingLines.FindSet() then;
                BuyShipment.Reset();
                BuyShipment.SetRange("No.", CombineRateInfo."Packing No.");
                BuyShipment.SetRange(Carrier, CombineRateInfo.Carrier);
                BuyShipment.SetRange(Service, CombineRateInfo.Service);
                BuyShipment.SetRange("EasyPost CA Account", CombineRateInfo."EasyPost CA Account");//SN_11042023++ to Get Rid of the Issue of Error and Account 1 and Account 2
                if BuyShipment.FindSet() then begin
                    IF BuyShipment.Count <> SubPackingLines.Count then begin
                        Message('Rates not pulled for all the Boxes.');
                        exit;
                    end;
                end;
            // end;
            until CombineRateInfo.Next() = 0;
        end;
    end;

    procedure CheckGetRates(CombineRateInfo: Record "Combine Rate Information")
    var
        SubPackingLines: Record "Sub Packing Lines";
        BuySipmentRec: Record "Buy Shipment";
        ShipPackageHeader: Record "Ship Package Header";
    BEGIN
        if ShipPackageHeader.Get(CombineRateInfo."Packing No.") then begin
            // if not (CombineRateInfo.Carrier in ['YRC', 'RL Carrier', 'Customer PickUp', 'Truck Freight', 'Custom Freight']) then begin
            SubPackingLines.Reset();
            SubPackingLines.SetRange("Packing No.", CombineRateInfo."Packing No.");
            if SubPackingLines.FindSet() then;
            BuySipmentRec.Reset();
            BuySipmentRec.SetRange("No.", SubPackingLines."Packing No.");
            BuySipmentRec.SetRange(Carrier, CombineRateInfo.Carrier);
            BuySipmentRec.SetRange(Service, CombineRateInfo.Service);
            if BuySipmentRec.FindSet() then begin
                if BuySipmentRec.Count <> SubPackingLines.Count then
                    Error('Rates for all the Boxes are not pulled. Please Get Rates again to buy the shipment.');
            end;
        END;
    end;

    var
        HttpClient: HttpClient;
        CClient: HttpClient;
        GrandMasterJson: JsonObject;
        MasterJson: JsonObject;
        JsonArrayVar: JsonArray;
        ChildJeson: JsonObject;
        ChildJesonArray: JsonArray;
        Boxmaster: Record "Box Master";
        NULL: Text;
        Location: Record Location;
}
