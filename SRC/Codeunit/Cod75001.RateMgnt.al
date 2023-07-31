codeunit 55000 "Rate Mgnt"
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

    procedure GetDataCustomeFreight(ShipPackageHeader: Record "Ship Package Header")
    var
        SubPackageLines: Record "Sub Packing Lines";
        CustomFreight: Record "Custom Freight";
        BuyShipment: Record "Buy Shipment";
        BuyShipmentLast: Record "Buy Shipment";
    begin
        SubPackageLines.Reset();
        SubPackageLines.SetRange("Packing No.", ShipPackageHeader.No);
        SubPackageLines.SetRange("Packing Type", SubPackageLines."Packing Type"::pallet);
        if SubPackageLines.FindSet() then begin
            CustomFreight.Reset();
            CustomFreight.SetRange(CustomFreight."Number of Pallets", SubPackageLines.Count);
            if CustomFreight.FindFirst() then begin
                BuyShipmentLast.Reset();
                BuyShipmentLast.SetRange(BuyShipmentLast."No.", ShipPackageHeader.No);
                if BuyShipmentLast.FindLast() then;
                BuyShipment.Init();
                BuyShipment."No." := ShipPackageHeader.No;
                BuyShipment."Line No." := BuyShipmentLast."Line No." + 10000;
                BuyShipment.Carrier := 'Custom Freight';
                BuyShipment.Service := 'Custom Freight';
                BuyShipment."EasyPost CA Name" := 'Custom Freight';//SN-01062023+
                BuyShipment.Rate := CustomFreight."Base Cost";
                BuyShipment.Insert();
            end;
        end;
    end;

    procedure "GetTruckFreight"(ShipPackageHeader: Record "Ship Package Header")
    var
        BuyShipmentLast: Record "Buy Shipment";
        BuyShipment: Record "Buy Shipment";
    begin
        BuyShipmentLast.Reset();
        BuyShipmentLast.SetRange(BuyShipmentLast."No.", ShipPackageHeader.No);
        BuyShipmentLast.SetFilter(Carrier, 'Truck Freight');
        if BuyShipmentLast.FindSet() then BuyShipmentLast.DeleteAll();
        BuyShipmentLast.Reset();
        BuyShipmentLast.SetRange(BuyShipmentLast."No.", ShipPackageHeader.No);
        if BuyShipmentLast.FindLast() then;
        BuyShipment.Init();
        BuyShipment."No." := ShipPackageHeader.No;
        BuyShipment."Line No." := BuyShipmentLast."Line No." + 10000;
        BuyShipment.Carrier := 'Truck Freight';
        BuyShipment.Service := 'Truck Freight';
        BuyShipment."EasyPost CA Name" := 'Truck Freight';//SN_12042023+
        BuyShipment.Rate := 0;
        BuyShipment.Insert();
    end;

    procedure CustomerPickUp(ShipPackageHeader: Record "Ship Package Header")
    var
        CustomFreight: Record "Custom Freight";
        BuyShipment: Record "Buy Shipment";
        BuyShipmentLast: Record "Buy Shipment";
    begin
        BuyShipmentLast.Reset();
        BuyShipmentLast.SetRange(BuyShipmentLast."No.", ShipPackageHeader.No);
        BuyShipmentLast.SetFilter(Carrier, 'Customer PickUp');
        if BuyShipmentLast.FindSet() then BuyShipmentLast.DeleteAll();
        BuyShipmentLast.Reset();
        BuyShipmentLast.SetRange(BuyShipmentLast."No.", ShipPackageHeader.No);
        if BuyShipmentLast.FindLast() then;
        BuyShipment.Init();
        BuyShipment."No." := ShipPackageHeader.No;
        BuyShipment."Line No." := BuyShipmentLast."Line No." + 10000;
        BuyShipment.Carrier := 'Customer PickUp';
        BuyShipment.Service := 'Customer PickUp';
        BuyShipment."EasyPost CA Name" := 'Customer PickUp';//SN_12042023+
        BuyShipment.Rate := 0;
        BuyShipment.Insert();
        // end;
    end;

    procedure GetRateYRC(ShipPackageHeader: Record "Ship Package Header");
    Var //ShipPackageHeader: Record "Ship Package Header";
        jObject: JsonObject;
        jObject2: JsonObject;
        jToken: JsonToken;
        jarray: JsonArray;
        CountryRegion: Record "Country/Region";
        Location: Record Location;
        PackingModuleSetUp: Record "Packing Module Setup";
        YRCServiceClass: Enum "YRC Service Class";
        SubPackageLines: Record "Sub Packing Lines";
        palletboxmaster: Record "Pallet/Box Master";
        Datetext: Text;
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        responseText: Text;
        JsonBuffer: Record "Json Buffer" Temporary;
        JsonBufferReal: Record "Json Buffer" Temporary;
        BuyShipment: Record "Buy Shipment";
        //pagetitlepath: Text;
        BuyShipmentLast: Record "Buy Shipment";
        tablecounttext: text[250];
        tablecountint: Integer;
        tablecountpath: text;
        i: Integer;
        J: Integer;
        RateDec: Decimal;
        RateTxt: Text;
        totalchargespath: Text[200];
        ServicePath: text;
        ServiceReqLevelPath: text;
        ReferanceIDpath: text;
        Errormsgpath: text;
        ServiceOCCpath: text;
        deliverydaypath: Text;
        deliverydaysint: Integer;
        JsonBufferReal1: Record "Json Buffer" Temporary;
        JsonBufferReal2: Record "Json Buffer" Temporary;
        JsonBufferReal3: Record "Json Buffer" Temporary;
        JsonBufferReal4: Record "Json Buffer" Temporary;
        JsonBufferReal5: Record "Json Buffer" Temporary;
        JsonBufferReal6: Record "Json Buffer" Temporary;
        insertAllow: Boolean;
        BuyShipment2: Record "Buy Shipment";
        RateDecStrPos: Integer;
        DateMonth: Decimal;
        DateYEAR: Decimal;
        DatEDAYS: Decimal;
        DateMonthTXT: Text;
        DateYEARTXT: Text;
        DatEDAYStext: Text;
        BuyShip: Record "Buy Shipment";
        SIEventMngt: Codeunit "SI Event Mgnt";
    begin
        PackingModuleSetUp.Get();
        //ShipPackageHeader.Get(Rec.No);
        if Date2DMY(ShipPackageHeader."PickUp Date", 2) < 10 then begin
            DateMonthTXT := '0' + Format(Date2DMY(ShipPackageHeader."PickUp Date", 2))
        end
        else
            DateMonthTXT := Format(Date2DMY(ShipPackageHeader."PickUp Date", 2));
        if Date2DMY(ShipPackageHeader."PickUp Date", 1) < 10 then begin
            DatedaysTeXT := '0' + Format(Date2DMY(ShipPackageHeader."PickUp Date", 1))
        end
        else
            DatedaysTeXT := Format(Date2DMY(ShipPackageHeader."PickUp Date", 1));
        Datetext := format(Date2DMY(ShipPackageHeader."PickUp Date", 3)) + DateMonthTXT + DatEDAYStext;
        //IF ShipPackageHeader."Service Class" = 0 then begin
        ShipPackageHeader."Service Class" := ShipPackageHeader."Service Class"::ALL;
        ShipPackageHeader.Modify();
        Commit();
        //end;
        jObject.Add('username', PackingModuleSetUp."YRC User Name");
        jObject.Add('password', PackingModuleSetUp."YRC API Password");
        jObject.Add('busId', PackingModuleSetUp."YRC BusID");
        jObject.Add('busRole', 'Third Party');
        jObject.Add('paymentTerms', 'Prepaid');
        jObject2.Add('login', jObject);
        Clear(jObject);
        //Clear(jObject2);
        jObject.Add('serviceClass', Format(ShipPackageHeader."Service Class"));
        jObject.Add('typeQuery', 'MATRX');
        jObject.Add('pickupDate', Datetext);
        jObject2.Add('details', jObject);
        Clear(jObject);
        Location.get(ShipPackageHeader.Location);
        CountryRegion.Get(Location."Country/Region Code");
        jObject.Add('city', Location.City);
        jObject.Add('state', Location.County);
        jObject.Add('postalCode', Location."Post Code");
        jObject.Add('country', CountryRegion.Name);
        jObject2.Add('originLocation', jObject);
        Clear(jObject);
        //Clear(jObject2);
        CountryRegion.Get(ShipPackageHeader."Ship-to Country/Region Code");
        jObject.Add('city', ShipPackageHeader."Ship-to City");
        jObject.Add('state', ShipPackageHeader."Ship-to County");
        jObject.Add('postalCode', ShipPackageHeader."Ship-to Post Code");
        jObject.Add('country', CountryRegion.Name);
        jObject2.Add('destinationLocation', jObject);
        //Message('%1,%2', Date1, text1);
        Clear(jObject);
        SubPackageLines.Reset();
        SubPackageLines.SetRange("Packing No.", ShipPackageHeader.No);
        SubPackageLines.SetRange("Packing Type", SubPackageLines."Packing Type"::Pallet);
        if SubPackageLines.FindSet() then begin
            repeat
                palletboxmaster.Get(SubPackageLines."Box Code / Packing Type");
                AddLinestoJson(ShipPackageHeader."Class", ShipPackageHeader."Service Package Code", jarray, SubPackageLines);
            until SubPackageLines.Next() = 0;
        end;
        jObject2.Add('listOfCommodities', jObject);
        jObject.Add('commodity', jarray);
        Clear(jObject);
        Clear(jarray);
        if ShipPackageHeader."Inside Pickup" then
            jarray.Add('IP');
        IF ShipPackageHeader."Limited Access Pickup" then
            jarray.Add('LTDO');
        IF ShipPackageHeader."Origin Lift gate" then
            jarray.Add('LFTO');
        IF ShipPackageHeader."Residential Pickup" then
            jarray.Add('HOMP');
        IF ShipPackageHeader."Destination Lift gate" then
            jarray.Add('LFTD');
        IF ShipPackageHeader."Limited Access Delivery" then
            jarray.Add('LTDD');
        IF ShipPackageHeader."Residential Delivery" then
            jarray.Add('HOMD');
        IF ShipPackageHeader."Inside Delivery" then
            jarray.Add('ID');
        IF ShipPackageHeader.Hazmat then
            jarray.Add('HAZM');
        if ShipPackageHeader."Delivery Notification" then begin
            jarray.Add('NTFY');
            jarray.Add('APPT');
        end;
        jObject.Add('accOptions', jarray);
        jObject2.Add('serviceOpts', jObject);
        // Message(FORMAT(jObject2));
        content.WriteFrom(format(jObject2));
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        request.Content := content;
        request.SetRequestUri(PackingModuleSetUp."YRC URL");
        request.Method := 'POST';
        client.Send(request, response);
        response.Content().ReadAs(responseText);
        SIEventMngt.CreateAPILog(ShipPackageHeader."No", '', 'POST', format(jObject2), responsetext, Response.HttpStatusCode, CurrentDateTime, PackingModuleSetUp."YRC URL");
        JsonBufferReal1.Reset();
        JsonBufferReal1.DeleteAll();
        JsonBufferReal1.ReadFromText(responseText);
        clear(tablecounttext);
        Clear(tablecountint);
        tablecountpath := 'pageRoot.bodyMain.rateQuote.quoteMatrix.tableCount';
        JsonBufferReal2.Copy(JsonBufferReal1, true);
        JsonBufferReal3.Copy(JsonBufferReal1, true);
        JsonBufferReal4.Copy(JsonBufferReal1, true);
        JsonBufferReal5.Copy(JsonBufferReal1, true);
        JsonBufferReal6.Copy(JsonBufferReal1, true);
        JsonBufferReal1.Reset();
        JsonBufferReal1.SetFilter(Path, tablecountpath);
        JsonBufferReal1.SetRange("Token type", JsonBufferReal."Token type"::String);
        if JsonBufferReal1.FindFirst() then begin
            tablecounttext := JsonBufferReal1.Value;
            Evaluate(tablecountint, tablecounttext);
        end;
        i := 0;
        Repeat
            j := 0;
            Repeat
                totalchargespath := 'pageRoot.bodyMain.rateQuote.quoteMatrix.table[' + Format(i) + '].transitOptions[' + Format(j) + '].totalCharges';
                JsonBufferReal1.Reset();
                JsonBufferReal1.SetFilter(Path, totalchargespath);
                JsonBufferReal1.SetRange("Token type", JsonBufferReal1."Token type"::String);
                if JsonBufferReal1.Findlast() then begin
                    BuyShipmentLast.Reset();
                    BuyShipmentLast.SetRange("No.", ShipPackageHeader.No);
                    if BuyShipmentLast.FindLast() then;
                    BuyShipment.Init();
                    BuyShipment.Validate("No.", ShipPackageHeader.No);
                    BuyShipment.Validate("Line No.", BuyShipmentLast."Line No." + 10000);
                    BuyShipment.Validate(Carrier, 'YRC');
                    BuyShipment."EasyPost CA Name" := 'YRC';//SN-01062023+
                    RateDec := 0;
                    if (JsonBufferReal1.GetValue() <> 'Call') AND (JsonBufferReal1.GetValue() <> 'N/A') then begin
                        Evaluate(RateTxt, JsonBufferReal1.GetValue());
                        RateDecStrPos := StrLen(JsonBufferReal1.GetValue()) - 1;
                        RateTxt := InsStr(RateTxt, '.', RateDecStrPos);
                        Evaluate(RateDec, RateTxt);
                        BuyShipment.Validate(Rate, RateDec);
                    end
                    else begin
                        BuyShipment.Validate("YRC Error Code", JsonBufferReal1.GetValue());
                    end;
                    ServicePath := 'pageRoot.bodyMain.rateQuote.quoteMatrix.table[' + Format(i) + '].serviceReq';
                    JsonBufferReal2.Reset();
                    JsonBufferReal2.SetFilter(Path, ServicePath);
                    JsonBufferReal2.SetRange("Token type", JsonBufferReal2."Token type"::String);
                    if JsonBufferReal2.FindFirst() then begin
                        if JsonBufferReal2."Token type" = JsonBufferReal2."Token type"::String then begin
                            BuyShipment.Validate(Service, JsonBufferReal2.GetValue());
                        end;
                    end;
                    ServiceReqLevelPath := 'pageRoot.bodyMain.rateQuote.quoteMatrix.table[' + format(i) + '].transitOptions[' + Format(J) + '].serviceReqLevel';
                    JsonBufferReal3.Reset();
                    JsonBufferReal3.SetFilter(Path, ServiceReqLevelPath);
                    JsonBufferReal3.SetRange("Token type", JsonBufferReal3."Token type"::String);
                    if JsonBufferReal3.FindFirst() then begin
                        if JsonBufferReal3."Token type" = JsonBufferReal3."Token type"::String then begin
                            BuyShipment.Validate("YRC Service Req", JsonBufferReal3.GetValue());
                        end;
                    end;
                    ReferanceIDpath := 'pageRoot.bodyMain.rateQuote.referenceId';
                    JsonBufferReal4.Reset();
                    JsonBufferReal4.SetFilter(Path, ReferanceIDpath);
                    JsonBufferReal4.SetRange("Token type", JsonBufferReal4."Token type"::String);
                    if JsonBufferReal4.FindFirst() then begin
                        if JsonBufferReal4."Token type" = JsonBufferReal4."Token type"::String then begin
                            BuyShipment.Validate("Quote ID", JsonBufferReal4.GetValue());
                        end;
                    end;
                    Errormsgpath := 'pageRoot.bodyMain.rateQuote.quoteMatrix.table[' + Format(i) + '].transitOptions[' + Format(J) + '].errorMsg';
                    JsonBufferReal.Reset();
                    JsonBufferReal.SetFilter(Path, Errormsgpath);
                    JsonBufferReal.SetRange("Token type", JsonBufferReal."Token type"::String);
                    if JsonBufferReal.FindFirst() then begin
                        if JsonBufferReal."Token type" = JsonBufferReal."Token type"::String then begin
                            BuyShipment.Validate("YRC Error Message", JsonBufferReal.GetValue());
                        end;
                    end;
                    ServiceOCCpath := 'pageRoot.bodyMain.rateQuote.quoteMatrix.table[' + Format(i) + '].serviceOcc';
                    JsonBufferReal5.Reset();
                    JsonBufferReal5.SetFilter(Path, ServiceOCCpath);
                    JsonBufferReal5.SetRange("Token type", JsonBufferReal5."Token type"::String);
                    if JsonBufferReal5.FindFirst() then begin
                        if JsonBufferReal5."Token type" = JsonBufferReal5."Token type"::String then begin
                            BuyShipment.Validate("YRC Service Occ Code", JsonBufferReal5.GetValue());
                        end;
                    end;
                    deliverydaypath := 'pageRoot.bodyMain.rateQuote.quoteMatrix.table[' + Format(i) + '].transitOptions[' + Format(J) + '].transitDays';
                    JsonBufferReal6.Reset();
                    JsonBufferReal6.SetFilter(Path, deliverydaypath);
                    JsonBufferReal6.SetRange("Token type", JsonBufferReal6."Token type"::String);
                    if JsonBufferReal6.FindFirst() then begin
                        if JsonBufferReal6."Token type" = JsonBufferReal6."Token type"::String then begin
                            if JsonBufferReal6.GetValue() <> '*' then begin
                                Evaluate(deliverydaysint, JsonBufferReal6.GetValue());
                                BuyShipment.Validate("Delivery Days", deliverydaysint);
                            end
                            else
                                BuyShipment.Validate("Delivery Days", 0);
                        end;
                    end;
                    if (BuyShipment."YRC Service Req" = 'TCSP') and (BuyShipment.Rate <> 0) then begin
                        BuyShipment2.Reset();
                        BuyShipment2.SetRange("No.", ShipPackageHeader.No);
                        //BuyShipment2.SetRange("Line No.", BuyShipmentLast."Line No." + 10000);
                        BuyShipment2.SetRange(Carrier, 'YRC');
                        BuyShipment2.SetFilter(Rate, '<>%1', 0);
                        BuyShipment2.SetRange("YRC Service Req", 'TCSP');
                        if Not BuyShipment2.FindFirst() then
                            insertAllow := true
                        else begin
                            BuyShip.SetRange("No.", ShipPackageHeader.No);
                            BuyShip.SetRange(Carrier, 'YRC');
                            BuyShip.SetFilter(Rate, '<>%1', 0);
                            BuyShip.SetRange("YRC Service Req", 'TCSP');
                            if BuyShip.FindFirst() then
                                BuyShip.Validate(Rate, RateDec);
                            BuyShip.Modify();
                        end;
                    end;
                    if BuyShipment."YRC Service Req" = '' then insertAllow := true;
                    if BuyShipment."YRC Service Req" = 'ACEL' then insertAllow := true;
                    if insertAllow then BuyShipment.Insert();
                    insertAllow := false;
                end;
                J := 1 + J;
            until j = 7;
            i := 1 + i;
        until i = tablecountint + 1;
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
        SubPackingLines.SetRange("Packing Type", SubPackingLines."Packing Type"::Box);
        if SubPackingLines.FindSet() then begin
            repeat
                SubPackingLines2.Reset();
                SubPackingLines2.SetRange("Packing No.", SubPackingLines."Packing No.");
                SubPackingLines2.SetRange("Line No.", SubPackingLines."Line No.");
                SubPackingLines2.SetRange(SubPackingLines2."Packing Type", SubPackingLines2."Packing Type"::Box);
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
        palletBoxMaster: Record "Pallet/Box Master";
        shippingMarkupSetup: Record "Shipping MarkUp Setup";
    begin
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange(No, SubPackingLines."Packing No.");
        if ShipPackageHeader.FindFirst() then begin
            "PalletBoxmaster".Get(SubPackingLines."Box Code / Packing Type");
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
                    ParcelInfo(palletBoxMaster, SubPackingLines);
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
        if (ShipPackageHeader."Delivery Message" <> 'Success') and (ShipPackageHeader."Zip Message" <> 'Success') then begin
            if ShipPackageHeader."Use Ship-to Adsress" = true then begin
                JsonObjectVar.Add('street1', ShipPackageHeader."Ship-to Address");
                if ShipPackageHeader."Ship-to Address 2" <> '' then
                    JsonObjectVar.Add('street2', ShipPackageHeader."Ship-to Address 2")
                else
                    JsonObjectVar.Add('street2', '');
                JsonObjectVar.Add('city', ShipPackageHeader."Ship-to City");
                JsonObjectVar.Add('state', ShipPackageHeader."Ship-to County");
                JsonObjectVar.Add('zip', ShipPackageHeader."Ship-to Post Code");
                JsonObjectVar.Add('country', ShipPackageHeader."Ship-to Country/Region Code");
            end else
                Error('Ship-to Address is Incorrect.');
        end else begin
            JsonObjectVar.Add('street1', ShipPackageHeader."Suggested Addr");
            if ShipPackageHeader."Suggested Addr 2" <> '' then
                JsonObjectVar.Add('street2', ShipPackageHeader."Suggested Addr 2")
            else
                JsonObjectVar.Add('street2', '');
            JsonObjectVar.Add('city', ShipPackageHeader."Suggested City");
            JsonObjectVar.Add('state', ShipPackageHeader."Suggested State");
            JsonObjectVar.Add('zip', ShipPackageHeader."Suggested Post Code");
            JsonObjectVar.Add('country', ShipPackageHeader."Suggested Country Code");
        end;
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
            // ShippingMarkUpSetup.Reset;
            // ShippingMarkUpSetup.SetRange("Customer No.", ShipPackageHeader."Bill-to Customer No.");
            // ShippingMarkUpSetup.SetFilter("Customer Shipping Carrier", '<>%1', '');
            // ShippingMarkUpSetup.SetFilter("Customer Shipping Carrier Acc.", '<>%1', '');
            // ShippingMarkUpSetup.SetFilter("Customer Shipping Carrier Zip", '<>%1', '');
            // ShippingMarkUpSetup.SetFilter("Customer Ship. Carrier Country", '<>%1', '');
            // if ShippingMarkUpSetup.FindFirst() then begin
            PaymentJsonObjectVar.Add('type', 'THIRD_PARTY');
            PaymentJsonObjectVar.Add('account', Shippackageheader."3rd Party Account No.");
            PaymentJsonObjectVar.Add('country', Shippackageheader."3rd Party country");
            PaymentJsonObjectVar.Add('postal_code', Shippackageheader."3rd Party Account Zip");
            JsonObjectVar.Add('payment', PaymentJsonObjectVar);
        end;
        MasterJson.Add('options', JsonObjectVar);
    end;

    local procedure ParcelInfo(palletBoxMaster: Record "Pallet/Box Master";
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
        PackingModuleSetup.TestField("Pounds to Ounces converter");
        PackingAdjustment.Get(ShipPackinglines."Packing No.", ShipPackinglines."Box Sr ID/Packing No.");
        //Item.get(ShipPackinglines."Item No.");
        Clear(JsonObjectVar);
        JsonObjectVar.Add('length', PackingAdjustment.L);
        JsonObjectVar.Add('width', PackingAdjustment.W);
        JsonObjectVar.Add('height', PackingAdjustment.H);
        //  JsonObjectVar.Add('predefined_package', 'null');
        JsonObjectVar.Add('weight', PackingAdjustment."Total Gross Ship Wt" * PackingModuleSetup."Pounds to Ounces converter");
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
    begin
        ShipPackageModule.get();
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange(No, ShipPackageLines."Packing No.");
        if ShipPackageHeader.FindFirst() then;
        "Pallet/Box master".Get(ShipPackageLines."Box Code / Packing Type");
        Location.Get(ShipPackageHeader.Location);
        Clear(ChildJeson);
        Clear(ChildJesonArray);
        ChildJeson.Add('description', '');
        ChildJeson.Add('hs_tariff_number', '');
        ChildJeson.Add('origin_country', Location."Country/Region Code");
        ChildJeson.Add('quantity', ShipPackageLines."Qty Packed");
        ChildJeson.Add('value', 1);
        ChildJeson.Add('weight', ShipPackageLines."Total Gross Ship Wt" * ShipPackageModule."Pounds to Ounces converter");
        ChildJesonArray.Add(ChildJeson);
        JsonObjectVar.Add('customs_items', ChildJesonArray);
        //Clear(ChildJeson);
    end;

    local procedure AddLinestoJson(NFCClass: Enum Class;
                                                 ServicePackageCode: Enum "YRC Package Code";
                                                 jArray: JsonArray;
                                                 SubPackageLines: record "Sub Packing Lines")
    var
        jObject: JsonObject;
        palletboxmaster: Record "Pallet/Box Master";
        NFCClassDec: Decimal;
        Item: Record Item;
        TotalGrossWeightint: Integer;
    begin
        palletboxmaster.Get(SubPackageLines."Box Code / Packing Type");
        Evaluate(NFCClassDec, Format(NFCClass));
        //  Evaluate(TotalGrossWeightint, Format(round(SubPackageLines."Total Gross Ship Wt")));
        jObject.Add('nmfcClass', NFCClassDec);
        jObject.Add('handlingUnits', 1);
        jObject.Add('packageCode', format(ServicePackageCode));
        jObject.Add('packageLength', palletboxmaster.L);
        jObject.Add('packageWidth', palletboxmaster.W);
        jObject.Add('packageHeight', palletboxmaster.H);
        jObject.Add('weight', round(SubPackageLines."Total Gross Ship Wt", 1));
        jArray.Add(jObject);
    end;


    procedure GetRateRL(var Rec: Record "Ship Package Header")
    var
        RLCarriers: Codeunit RLCarriers;
        XmlRequest: text;
        content: HttpContent;
        Headers: HttpHeaders;
        request: HttpRequestMessage;
        packingModuleSetup: Record "Packing Module Setup";
        RLurl: Text;
        Response: HttpResponseMessage;
        client: HttpClient;
        responsetext: Text;
        Xmlbuffer: Record "XML Buffer";
        xmlDoc: XmlDocument;
        Tempblob: Codeunit "Temp Blob";
        Outstr: OutStream;
        Instr: InStream;
        RLRateQuote: Record "RL Rate Quote";
        ServicelevelPath: Text;
        ServicePath: Text;
        ServiceCodePath: text;
        Servicedayspath: Text;
        QuoteNumberpath: Text;
        chargepath: text;
        netchargespath: Text;
        ParentEntryNo: Text;
        ParentEntryNo2: Integer;
        XmlBuffer2: Record "XML Buffer";
        servicedaystxt: text;
        servicedaysint: Integer;
        chargetxt: Text;
        chargedec: Decimal;
        Netchargetxt: text;
        Netchargedec: Decimal;
        ServiceTitle: Text;
        chargetxt2: text;
        netchargetxt2: Text;
        messagepath: Text;
        messagetxt: Text;
        Outstream: OutStream;
        //     RecTempblob: Record TempBlob;
        Client1: HttpClient;
        response1: HttpResponseMessage;
        BuyShipmentRate: Record "Buy Shipment";
        BuyShipmentRateLast: Record "Buy Shipment";
        SIEventMngt: Codeunit "SI Event Mgnt";
    begin
        packingModuleSetup.Get();
        RLurl := packingModuleSetup."RL URL" + '?APIKEY=' + packingModuleSetup."RL API Key";
        XmlRequest := RLCarriers.SOAPMessage(Rec);
        // Message(XmlRequest);
        //Message('%1.....%2', RLurl, XmlRequest);
        content.WriteFrom(XmlRequest);
        content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('SOAPAction', '"http://www.rlcarriers.com/GetRateQuote"');
        Headers.Add('Content-Type', 'text/xml');
        request.Content := content;
        request.SetRequestUri(RLurl);
        request.Method := 'POST';
        client.Send(request, Response);
        if not Response.IsSuccessStatusCode then begin
            Message('%1', Response.HttpStatusCode);
            Message(responsetext);
        end;
        Response.Content.ReadAs(responsetext);
        SIEventMngt.CreateAPILog(Rec."No", '', 'POST', XmlRequest, responsetext, Response.HttpStatusCode, CurrentDateTime, RLurl);
        Xmlbuffer.Reset();
        Xmlbuffer.DeleteAll();
        XmlDocument.ReadFrom(responsetext, xmlDoc);
        Tempblob.CreateOutStream(Outstr);
        xmlDoc.WriteTo(Outstr);
        Tempblob.CreateInStream(Instr);
        Xmlbuffer.LoadFromStream(Instr);
        RLRateQuote.Reset();
        RLRateQuote.SetRange(No, Rec.No);
        if RLRateQuote.FindSet() then RLRateQuote.DeleteAll();
        Xmlbuffer.Reset();
        Xmlbuffer.SetFilter(Path, ServicelevelPath);
        Xmlbuffer.SetRange(Depth, 8);
        if Xmlbuffer.FindSet() then begin
            repeat
                ParentEntryNo := format(Xmlbuffer."Parent Entry No.");
                XmlBuffer2.Reset();
                XmlBuffer2.SetFilter(Path, Xmlbuffer.Path);
                XmlBuffer2.SetRange(Depth, 8);
                XmlBuffer2.SetFilter("Parent Entry No.", ParentEntryNo);
                if XmlBuffer2.FindSet() then begin
                    repeat
                        if ('/soap:Envelope/soap:Body/GetRateQuoteResponse/GetRateQuoteResult/Result/ServiceLevels/ServiceLevel/Title' = Xmlbuffer2.Path) then begin
                            RLRateQuote.Reset();
                            RLRateQuote.Init();
                            RLRateQuote.Validate(No, Rec.No);
                            RLRateQuote.Validate(Service, Xmlbuffer2.GetValue());
                            ServiceTitle := RLRateQuote.Service;
                            RLRateQuote.Insert();
                        end;
                        if ('/soap:Envelope/soap:Body/GetRateQuoteResponse/GetRateQuoteResult/Result/ServiceLevels/ServiceLevel/Code' = Xmlbuffer2.Path) then begin
                            RLRateQuote.Reset();
                            RLRateQuote.SetRange(No, Rec.No);
                            RLRateQuote.SetRange(Service, ServiceTitle);
                            if RLRateQuote.FindFirst() then begin
                                RLRateQuote.Validate("Service Code", Xmlbuffer2.GetValue());
                                RLRateQuote.Modify();
                            end;
                        end;
                        if ('/soap:Envelope/soap:Body/GetRateQuoteResponse/GetRateQuoteResult/Result/ServiceLevels/ServiceLevel/QuoteNumber' = XmlBuffer2.Path) then begin
                            RLRateQuote.Reset();
                            RLRateQuote.SetRange(No, Rec.No);
                            RLRateQuote.SetRange(Service, ServiceTitle);
                            if RLRateQuote.FindFirst() then begin
                                RLRateQuote.Validate("Quote No", XmlBuffer2.GetValue());
                                RLRateQuote.Modify();
                            end;
                        end;
                        if ('/soap:Envelope/soap:Body/GetRateQuoteResponse/GetRateQuoteResult/Result/ServiceLevels/ServiceLevel/ServiceDays' = XmlBuffer2.Path) then begin
                            servicedaystxt := XmlBuffer2.GetValue();
                            Evaluate(servicedaysint, servicedaystxt);
                            RLRateQuote.Reset();
                            RLRateQuote.SetRange(No, Rec.No);
                            RLRateQuote.SetRange(Service, ServiceTitle);
                            if RLRateQuote.FindFirst() then begin
                                RLRateQuote.Validate("Service Days", servicedaysint);
                                RLRateQuote.Modify();
                            end;
                        END;
                        if ('/soap:Envelope/soap:Body/GetRateQuoteResponse/GetRateQuoteResult/Result/ServiceLevels/ServiceLevel/Charge' = XmlBuffer2.Path) then begin
                            RLRateQuote.Reset();
                            RLRateQuote.SetRange(No, Rec.No);
                            RLRateQuote.SetRange(Service, ServiceTitle);
                            if RLRateQuote.FindFirst() then begin
                                chargetxt := XmlBuffer2.GetValue();
                                chargetxt2 := DelStr(chargetxt, 1, 1);
                                Evaluate(chargedec, chargetxt2);
                                RLRateQuote.Validate(Charge, chargedec);
                                RLRateQuote.Modify();
                            end;
                        end;
                        if ('/soap:Envelope/soap:Body/GetRateQuoteResponse/GetRateQuoteResult/Result/ServiceLevels/ServiceLevel/NetCharge' = XmlBuffer2.Path) then begin
                            RLRateQuote.Reset();
                            RLRateQuote.SetRange(No, Rec.No);
                            RLRateQuote.SetRange(Service, ServiceTitle);
                            if RLRateQuote.FindFirst() then begin
                                Netchargetxt := XmlBuffer2.GetValue();
                                netchargetxt2 := DelStr(netchargetxt, 1, 1);
                                Evaluate(Netchargedec, netchargetxt2);
                                RLRateQuote.Validate("Net Charge", Netchargedec);
                                RLRateQuote.Modify();
                            end;
                        end;
                    until XmlBuffer2.Next() = 0;
                end;
            until Xmlbuffer.Next() = 0;
        end;
        messagepath := '/soap:Envelope/soap:Body/GetRateQuoteResponse/GetRateQuoteResult/Result/Messages/Message/Text';
        Xmlbuffer.Reset();
        Xmlbuffer.SetFilter(Path, messagepath);
        if Xmlbuffer.FindSet() then begin
            repeat
                messagetxt += Xmlbuffer.GetValue() + ',';
            until Xmlbuffer.Next() = 0;
        end;
        // Clear(Rec."RL Message");
        // rec."RL Message".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        // OutStream.WriteText(messagetxt);
        RLRateQuote.Reset();
        RLRateQuote.SetRange(No, Rec.No);
        if RLRateQuote.FindSet() then begin
            repeat
                BuyShipmentRateLast.Reset();
                BuyShipmentRateLast.SetRange("No.", RLRateQuote.No);
                if BuyShipmentRateLast.FindLast() then;
                BuyShipmentRate.Init();
                BuyShipmentRate.Carrier := 'RL Carrier';
                BuyShipmentRate."EasyPost CA Name" := 'RL Carrier';//SN-01062023+
                BuyShipmentRate.Service := RLRateQuote.Service;
                BuyShipmentRate.Rate := RLRateQuote."Net Charge";
                BuyShipmentRate."No." := RLRateQuote.No;
                BuyShipmentRate."Line No." := BuyShipmentRateLast."Line No." + 1000;
                BuyShipmentRate."Quote ID" := RLRateQuote."Quote No";
                BuyShipmentRate."Delivery Days" := RLRateQuote."Service Days";
                BuyShipmentRate.Insert();
            until RLRateQuote.Next() = 0;
        end;
        // Rec.Modify();
        Commit();
    end;

    procedure CombineRateInformation(ShipPackingHeader: Record "Ship Package Header")
    var
        BuyShipment: Record "Buy Shipment";
        RLGetRates: Record "RL Rate Quote";
        CombineRateInformation: Record "Combine Rate Information";
        CombineRateInformation2: Record "Combine Rate Information";
        CombineRateInformationLast: Record "Combine Rate Information";
        ShippingAgent: Record "Shipping Agent";
    Begin
        CombineRateInformation2.reset();
        CombineRateInformation2.SetRange("Packing No.", ShipPackingHeader.No);
        if CombineRateInformation2.FindSet() then CombineRateInformation2.DeleteAll();
        // RLGetRates.Reset();
        // RLGetRates.SetRange(No, ShipPackingHeader.No);
        // if RLGetRates.FindSet() then begin
        //     repeat
        //         CombineRateInformationLast.Reset();
        //         CombineRateInformationLast.SetRange("Packing No.", ShipPackingHeader.No);
        //         if CombineRateInformationLast.FindLast() then;
        //         CombineRateInformation.Init();
        //         CombineRateInformation."Entry No." := CombineRateInformationLast."Entry No." + 1;
        //         CombineRateInformation.Carrier := 'RL Carrier';
        //         CombineRateInformation.Service := RLGetRates.Service;
        //         CombineRateInformation."Delivery Days" := RLGetRates."Service Days";
        //         CombineRateInformation.Rate := RLGetRates."Net Charge";
        //         CombineRateInformation."Packing No." := RLGetRates.No;
        //         CombineRateInformation.Insert();
        //     until RLGetRates.Next() = 0;
        // end;
        BuyShipment.Reset();
        BuyShipment.SetRange("No.", ShipPackingHeader.No);
        if BuyShipment.FindSet() then begin
            repeat
                if BuyShipment.Carrier in ['YRC'] then begin
                    CombineRateInformationLast.Reset();
                    //CombineRateInformationLast.SetRange("Packing No.", ShipPackingHeader.No);
                    if CombineRateInformationLast.FindLast() then;
                    CombineRateInformation.Reset();
                    CombineRateInformation.SetRange("Packing No.", ShipPackingHeader.No);
                    CombineRateInformation.SetRange(Carrier, 'YRC');
                    if BuyShipment."YRC Service Req" <> '' then
                        CombineRateInformation.SetRange(Service, BuyShipment.Service + '-' + BuyShipment."YRC Service Req")
                    else
                        CombineRateInformation.SetRange(Service, BuyShipment.Service);
                    if Not CombineRateInformation.FindLast() then begin
                        CombineRateInformation.Init();
                        CombineRateInformation."Entry No." := CombineRateInformationLast."Entry No." + 1;
                        CombineRateInformation."Packing No." := BuyShipment."No.";
                        CombineRateInformation.Rate += BuyShipment.Rate;
                        CombineRateInformation.Validate(Carrier, BuyShipment.Carrier);
                        CombineRateInformation."EasyPost CA Name" := 'YRC';//SN-01062023+
                        if BuyShipment."YRC Service Req" <> '' then
                            CombineRateInformation.Service := BuyShipment.Service + '-' + BuyShipment."YRC Service Req"
                        else
                            CombineRateInformation.Service := BuyShipment.Service;
                        CombineRateInformation."YRC Error Code" := BuyShipment."YRC Error Code";
                        CombineRateInformation."YRC Error Message" := BuyShipment."YRC Error Message";
                        CombineRateInformation."Delivery Days" := BuyShipment."Delivery Days";
                        // CombineRateInformation."Markup Value" := ShipPackingHeader."Pallet Markup value";
                        CombineRateInformation.Insert();
                    end
                    Else begin
                        CombineRateInformation.Rate += BuyShipment.Rate;
                        CombineRateInformation."Total Shipping Rate for Customer" := CombineRateInformation.Rate + CombineRateInformation."Markup Value";
                        CombineRateInformation.Modify();
                    end;
                end;
            until BuyShipment.Next() = 0;
        end;
        BuyShipment.Reset();
        BuyShipment.SetRange(BuyShipment."No.", ShipPackingHeader.No);
        if BuyShipment.FindSet() then begin
            Repeat
                if Not (BuyShipment.Carrier in ['YRC']) then begin
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
                end;
            until BuyShipment.Next() = 0;
        end;
    end;

    procedure CheckGetRateForAllBoxesPallets(ShipPackageHeader: Record "Ship Package Header")
    var
        CombineRateInfo: Record "Combine Rate Information";
        BuyShipment: Record "Buy Shipment";
        SubPackingLines: Record "Sub Packing Lines";
    begin

        CombineRateInfo.Reset();
        CombineRateInfo.SetRange("Packing No.", ShipPackageHeader.No);
        if CombineRateInfo.FindSet() then begin
            repeat
                if not (CombineRateInfo.Carrier in ['YRC', 'RL Carrier', 'Customer PickUp', 'Truck Freight', 'Custom Freight']) then begin
                    SubPackingLines.Reset();
                    SubPackingLines.SetRange("Packing No.", ShipPackageHeader.No);
                    SubPackingLines.SetRange("Packing Type", SubPackingLines."Packing Type"::Box);
                    if SubPackingLines.FindSet() then;
                    BuyShipment.Reset();
                    BuyShipment.SetRange("No.", CombineRateInfo."Packing No.");
                    BuyShipment.SetRange(Carrier, CombineRateInfo.Carrier);
                    BuyShipment.SetRange(Service, CombineRateInfo.Service);
                    BuyShipment.SetRange("EasyPost CA Account", CombineRateInfo."EasyPost CA Account");//SN_11042023++ to Get Rid of the Issue of Error and Account 1 and Account 2
                    if BuyShipment.FindSet() then begin
                        IF BuyShipment.Count <> SubPackingLines.Count then begin
                            Message('Rates not pulled for all the Boxes/Pallets.');
                            exit;
                        end;
                    end;
                    // end else begin
                    //     if ((CombineRateInfo.Carrier in ['YRC', 'RL Carrier'])) AND NOT (CombineRateInfo.Carrier in ['Customer PickUp', 'Truck Freight', 'Custom Freight']) then begin
                    //         SubPackingLines.Reset();
                    //         SubPackingLines.SetRange("Packing No.", ShipPackageHeader.No);
                    //         SubPackingLines.SetRange("Packing Type", SubPackingLines."Packing Type"::Pallet);
                    //         if SubPackingLines.FindSet() then;
                    //         BuyShipment.Reset();
                    //         BuyShipment.SetRange("No.", CombineRateInfo."Packing No.");
                    //         BuyShipment.SetRange(Carrier, CombineRateInfo.Carrier);
                    //         if CombineRateInfo."Service" = 'TIME' then begin
                    //             IF StrPos(CombineRateInfo.Service, '-') <> 0 then begin
                    //                 BuyShipment.SetRange(Service, 'Time');
                    //                 BuyShipment.SetRange("YRC Service Req", CopyStr(CombineRateInfo.Service, StrPos(CombineRateInfo.Service, '-') + 1));
                    //             end else
                    //                 BuyShipment.SetRange(Service, CombineRateInfo.Service);
                    //         end else
                    //             BuyShipment.SetRange(Service, CombineRateInfo.Service);
                    //         if BuyShipment.FindSet() then
                    //             IF BuyShipment.Count <> SubPackingLines.Count then begin
                    //                 Message('Rates not pulled for all the Boxes/Pallets.');
                    //                 exit;
                    //             end;
                    //     end;
                end;
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
            if not (CombineRateInfo.Carrier in ['YRC', 'RL Carrier', 'Customer PickUp', 'Truck Freight', 'Custom Freight']) then begin
                SubPackingLines.Reset();
                SubPackingLines.SetRange("Packing No.", CombineRateInfo."Packing No.");
                SubPackingLines.SetRange("Packing Type", SubPackingLines."Packing Type"::Box);
                if SubPackingLines.FindSet() then;
                BuySipmentRec.Reset();
                BuySipmentRec.SetRange("No.", SubPackingLines."Packing No.");
                BuySipmentRec.SetRange(Carrier, CombineRateInfo.Carrier);
                BuySipmentRec.SetRange(Service, CombineRateInfo.Service);
                if BuySipmentRec.FindSet() then begin
                    if BuySipmentRec.Count <> SubPackingLines.Count then
                        Error('Rates for all the Boxes are not pulled. Please Get Rates again to buy the shipment.');
                end;
            end;
            // end else begin
            //     if ((CombineRateInfo.Carrier in ['YRC', 'RL Carrier'])) AND NOT (CombineRateInfo.Carrier in ['Customer PickUp', 'Truck Freight', 'Custom Freight']) then begin
            //         SubPackingLines.Reset();
            //         SubPackingLines.SetRange("Packing No.", ShipPackageHeader.No);
            //         SubPackingLines.SetRange("Packing Type", SubPackingLines."Packing Type"::Pallet);
            //         if SubPackingLines.FindSet() then;
            //         BuySipmentRec.Reset();
            //         BuySipmentRec.SetRange("No.", SubPackingLines."Packing No.");
            //         BuySipmentRec.SetRange(Carrier, CombineRateInfo.Carrier);
            //         if CombineRateInfo."Service" = 'TIME' then begin
            //             IF StrPos(CombineRateInfo.Service, '-') <> 0 then begin
            //                 BuySipmentRec.SetRange(Service, 'Time');
            //                 BuySipmentRec.SetRange("YRC Service Req", CopyStr(CombineRateInfo.Service, StrPos(CombineRateInfo.Service, '-') + 1));
            //             end else
            //                 BuySipmentRec.SetRange(Service, CombineRateInfo.Service);
            //         end else
            //             BuySipmentRec.SetRange(Service, CombineRateInfo.Service);
            //         if BuySipmentRec.FindSet() then
            //             if BuySipmentRec.Count <> SubPackingLines.Count then
            //                 Error('Rates for all the Boxes are not pulled. Please Get Rates again to buy the shipment.');
            //     end;
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
        "Pallet/Box master": Record "Pallet/Box Master";
        NULL: Text;
        Location: Record Location;
}
