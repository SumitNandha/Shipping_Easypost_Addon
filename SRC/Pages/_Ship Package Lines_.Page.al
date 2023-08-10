page 55005 "Ship Package Lines"
{
    //Caption = 'Ship Package Lines';
    PageType = ListPart;
    SourceTable = "Ship Packing Lines";
    AutoSplitKey = true;
    Caption = 'Item Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sales UOM"; Rec."Sales UOM")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Gross Ship Wt"; Rec."Gross Ship Wt")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Box Weight"; Rec."Box Weight")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Packed Qty"; Rec."Packed Qty")
                {
                    ToolTip = 'Specifies the value of the Packed Qty field.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Packing type"; Rec."Packing type")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Packing No."; Rec."Packing No.")
                {
                    ToolTip = 'Specifies the value of the Packing No. field.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Quantity to Move"; Rec."Quantity to Move")
                {
                    ToolTip = 'Specifies the value of the Quantity to Move field.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("New Packing No."; Rec."New Packing No.")
                {
                    Visible = false;
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PackingList: Record "Packing List";
                    begin
                        PackingList.Reset();
                        PackingList.SetFilter("Packing No", '%1|%2', '', Rec."No.");
                        if PackingList.FindSet() then if Page.RunModal(Page::"Packing List", PackingList) = Action::LookupOK then Rec.Validate("New Packing No.", PackingList."No.");
                    end;
                }
                field(QtyPacked; Rec.QtyPacked)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Total Qty"; Rec."Total Qty")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Tracking ID"; Rec."Tracking ID")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Public URL"; Rec."Public URL")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                    Visible = false;
                    Editable = false;
                }
                field("Label URL"; Rec."Label URL")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                    Editable = false;
                }
                field("Remaining Qty"; rEc."Remaining Qty")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field("Label Image"; Rec."Label Image")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Total Item Weight"; Rec."Total Item Weight")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Box Code for Item"; Rec."Box Code for Item")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Box L"; Rec."Box L")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Box H"; Rec."Box H")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Box W"; Rec."Box W")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
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
            // action("CreateShipment")
            // {
            //     Image = Create;
            //     ApplicationArea = All;
            //     Caption = 'Create Shipment';
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     trigger OnAction()
            //     var
            //         JsonObjectVar: JsonObject;
            //         i: Integer;
            //         PathJson: Text;
            //         SHipPackingLines: Record "sub Packing Lines";
            //         ShipPackageHeader: Record "Ship Package Header";
            //         content: HttpContent;
            //         client: HttpClient;
            //         Headers: HttpHeaders;
            //         request: HttpRequestMessage;
            //         PackingModuleSetup: Record "Packing Module Setup";
            //         AuthString: Text;
            //         //  Responstempblob: Record TempBlob;
            //         Response: HttpResponseMessage;
            //         responsetext: Text;
            //         JsonBuffer: Record "JSON Buffer";
            //         JsonBuffer1: Record "JSON Buffer";
            //         jsonBuffertemp: Record "JSON Buffer" temporary;
            //         BuyShipment: Record "Buy Shipment";
            //         ShipmentIDPath: text;
            //         RatePath: text;
            //         ShipID: text;
            //         BuyShipmentLast: Record "Buy Shipment";
            //         BuyShipment1: Record "Buy Shipment";
            //         ratetext: text;
            //         ratedec: Decimal;
            //         DeliveryDaystxt: text;
            //         DeliveryDaysint: Integer;
            //         DateGrnttext: text;
            //         dateGrntBoolean: Boolean;
            //         BuyShipment2: Record "Buy Shipment";
            //         Base64: Codeunit "Base64 Convert";
            //         SHipPackingLines2: Record "Sub Packing Lines";
            //     begin
            //         // PackingModuleSetup.Get();
            //         BuyShipment2.Reset();
            //         BuyShipment2.SetRange("No.", Rec."Packing No.");
            //         BuyShipment2.SetFilter(Carrier, '<>%1&<>%2&<>%3', 'YRC', 'Custom Freight', 'RL Carrier');
            //         if BuyShipment2.FindSet() then
            //             BuyShipment2.DeleteAll();
            //         //SN-
            //         PackingModuleSetup.Get();
            //         SHipPackingLines.Reset();
            //         SHipPackingLines.SetRange("Packing No.", Rec."No.");
            //         SHipPackingLines.SetRange("Packing Type", SHipPackingLines."Packing Type"::Box);
            //         //SHipPackingLines.SetFilter("Packing No.", '<>%1', '');
            //         if SHipPackingLines.FindSet() then begin
            //             repeat
            //                 SHipPackingLines2.Reset();
            //                 SHipPackingLines2.SetRange("Packing No.", Rec."No.");
            //                 SHipPackingLines2.SetRange("Line No.", SHipPackingLines."Line No.");
            //                 SHipPackingLines2.SetRange(SHipPackingLines2."Packing Type", SHipPackingLines2."Packing Type"::Box);
            //                 if SHipPackingLines2.FindFirst() then begin
            //                     Clear(GrandMasterJson);
            //                     Clear(MasterJson);
            //                     Clear(JsonObjectVar);
            //                     for i := 1 to 5 do begin
            //                         SetJSONData(Rec, I);
            //                     end;
            //                     GrandMasterJson.Add('shipment', MasterJson);
            //                     Message('%1', GrandMasterJson);
            //                     content.WriteFrom(Format(GrandMasterJson));
            //                     content.GetHeaders(Headers);
            //                     Headers.Clear();
            //                     Headers.Add('Content-Type', 'application/json');
            //                     request.Content := content;
            //                     request.Method := 'POST';
            //                     request.SetRequestUri(PackingModuleSetup."EasyPost URL");
            //                     request.GetHeaders(Headers);
            //                     AuthString := StrSubstNo('%1', PackingModuleSetup."EasyPost API Key");
            //                     // responstempblob.WriteAsText(AuthString, TextEncoding::UTF8);
            //                     // AuthString := responstempblob.ToBase64String();
            //                     AuthString := Base64.ToBase64(AuthString);
            //                     AuthString := StrSubstNo('Basic %1', AuthString);
            //                     Headers.Add('Authorization', AuthString);
            //                     Client.Get(PackingModuleSetup."EasyPost URL", response);
            //                     Client.Send(request, response);
            //                     if not Response.IsSuccessStatusCode then
            //                         Message('%1', Response.HttpStatusCode);
            //                     response.Content.ReadAs(responsetext);
            //                     Message(responsetext);
            //                     JsonBuffer.Reset();
            //                     JsonBuffer.DeleteAll();
            //                     jsonBuffertemp.ReadFromText(responsetext);
            //                     if jsonBuffertemp.FindSet() then
            //                         repeat
            //                             JsonBuffer := jsonBuffertemp;
            //                             JsonBuffer.Insert();
            //                         until jsonBuffertemp.Next() = 0;
            //                     ShipmentIDPath := 'rates[0].shipment_id';
            //                     JsonBuffer1.Reset();
            //                     JsonBuffer1.SetFilter(Path, ShipmentIDPath);
            //                     JsonBuffer1.SetFilter("Token type", '%1', JsonBuffer1."Token type"::String);
            //                     if JsonBuffer1.FindFirst() then begin
            //                         ShipID := JsonBuffer1.GetValue();
            //                         BuyShipment2.Reset();
            //                         BuyShipment2.SetRange("No.", ShipPackageHeader.No);
            //                         BuyShipment2.SetRange("Rate ID", JsonBuffer1.GetValue());
            //                         if BuyShipment2.FindSet() then
            //                             BuyShipment2.DeleteAll();
            //                     end;
            //                 end;
            //                 i := 0;
            //                 begin
            //                     repeat
            //                         clear(ratedec);
            //                         Clear(DeliveryDaysint);
            //                         RatePath := 'rates[' + Format(i) + '].*';
            //                         JsonBuffer.Reset();
            //                         JsonBuffer.Setfilter(Path, RatePath);
            //                         JsonBuffer.Setfilter("Token type", '<>%1', JsonBuffer."Token type"::"Property Name");
            //                         if JsonBuffer.FindSet() then begin
            //                             BuyShipmentLast.Reset();
            //                             BuyShipmentLast.SetRange("No.", Rec."No.");
            //                             if BuyShipmentLast.FindLast() then;
            //                             BuyShipment.Init();
            //                             BuyShipment.Validate("No.", rec."No.");
            //                             BuyShipment.Validate("Packing No", rec."Packing No.");
            //                             BuyShipment.Validate("Line No.", BuyShipmentLast."Line No." + 10000);
            //                             BuyShipment.Validate("Shipment ID", ShipID);
            //                             BuyShipment.Insert();
            //                             repeat
            //                                 BuyShipment1.Reset();
            //                                 BuyShipment1.SetRange("No.", BuyShipment."No.");
            //                                 BuyShipment1.SetRange("Line No.", BuyShipment."Line No.");
            //                                 if BuyShipment1.FindFirst() then begin
            //                                     if 'rates[' + Format(i) + '].id' = JsonBuffer.Path then
            //                                         BuyShipment1.Validate(BuyShipment1."Rate ID", JsonBuffer.GetValue());
            //                                     if 'rates[' + Format(i) + '].carrier' = JsonBuffer.Path then
            //                                         BuyShipment1.Validate(Carrier, JsonBuffer.GetValue());
            //                                     if 'rates[' + Format(i) + '].service' = JsonBuffer.Path then
            //                                         BuyShipment1.Validate(service, JsonBuffer.GetValue());
            //                                     if 'rates[' + Format(i) + '].currency' = JsonBuffer.Path then
            //                                         BuyShipment1.Validate(currency, JsonBuffer.GetValue());
            //                                     if 'rates[' + Format(i) + '].list_rate' = JsonBuffer.Path then begin
            //                                         ratetext := JsonBuffer.GetValue();
            //                                         Evaluate(ratedec, ratetext);
            //                                         BuyShipment1.Validate(rate, ratedec);
            //                                     end;
            //                                     if 'rates[' + Format(i) + '].delivery_days' = JsonBuffer.Path then begin
            //                                         if JsonBuffer.GetValue() <> '' then begin
            //                                             DeliveryDaystxt := JsonBuffer.GetValue();
            //                                             Evaluate(DeliveryDaysint, DeliveryDaystxt);
            //                                             BuyShipment1.Validate("Delivery Days", DeliveryDaysint);
            //                                         end;
            //                                     end;
            //                                     if 'rates[' + Format(i) + '].delivery_date_guaranteed' = JsonBuffer.Path then begin
            //                                         DateGrnttext := JsonBuffer.GetValue();
            //                                         Evaluate(dateGrntBoolean, DateGrnttext);
            //                                         BuyShipment1.Validate("delivery date guaranteed", dateGrntBoolean);
            //                                     end;
            //                                     BuyShipment1.Modify();
            //                                 end;
            //                             until JsonBuffer.Next() = 0;
            //                         end;
            //                         i := i + 1;
            //                     until i = 50;
            //                 end;
            //             until SHipPackingLines.Next() = 0;
            //         end;
            //     end;
            // }
            // action("Combine Rate Information")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Combine Rate Information';
            //     Image = Info;
            //     trigger OnAction()
            //     var
            //         CombineRateInfo: Record "Combine Rate information";
            //     begin
            //         CombineRateInfo.Reset();
            //         CombineRateInfo.SetRange("Packing No.", Rec."Packing No.");
            //         if CombineRateInfo.FindFirst() then begin
            //             Page.RunModal(Page::"Combine Rate Information", CombineRateInfo)
            //         end;
            //     end;
            // }
            // action("EasyPost tracking")
            // {
            //     ApplicationArea = all;
            //     Image = Recalculate;
            //     trigger OnAction()
            //     var
            //         ShipPackageHeader: Record "Ship Package Header";
            //         serviceMngt: Codeunit "Rate Mgnt";
            //         Username: text;
            //         Pwd: text;
            //         client: HttpClient;
            //         jsonBuffertemp: Record "JSON Buffer" temporary;
            //         responsetext: text;
            //         jsonbuffer: Record "JSON Buffer";
            //         Tracker: Record Tracker;
            //         trackerpath: text;
            //         i: Integer;
            //         sourcepath: Text;
            //         TrackerLast: Record Tracker;
            //         TrackingCode: Text;
            //     begin
            //         jsonbuffer.Reset();
            //         jsonbuffer.DeleteAll();
            //         //Username := 'EZTK8069182a35cf49ea896f89e54629d942wmRjzkNTvZGT30oERnVExg';
            //         //responsetext := serviceMngt.AddHttpBasicAuthHeader(Username, Pwd, client, Rec);
            //         Message(responsetext);
            //         jsonBuffertemp.ReadFromText(responsetext);
            //         if jsonBuffertemp.FindSet() then
            //             repeat
            //                 jsonbuffer := jsonBuffertemp;
            //                 jsonbuffer.Insert();
            //             until jsonBuffertemp.Next() = 0;
            //         ShipPackageHeader.Get(Rec."No.");
            //         trackerpath := 'tracking_code';
            //         jsonbuffer.Reset();
            //         jsonbuffer.SetRange(Path, trackerpath);
            //         jsonbuffer.SetFilter("Token type", 'String');
            //         if jsonbuffer.FindFirst() then begin
            //             TrackingCode := jsonbuffer.GetValue();
            //             Tracker.Reset();
            //             Tracker.SetRange("No.", ShipPackageHeader.No);
            //             Tracker.SetRange("Tracking Code", jsonbuffer.GetValue());
            //             if Tracker.FindSet() then begin
            //                 Tracker.DeleteAll();
            //             end;
            //         end;
            //         i := 0;
            //         repeat
            //             sourcepath := 'tracking_details[' + format(i) + '].*';
            //             jsonbuffer.Reset();
            //             jsonbuffer.SetFilter(Path, '%1', sourcepath);
            //             jsonbuffer.SetFilter("Token type", '%1|%2', jsonbuffer."Token type"::String, jsonbuffer."Token type"::Null);
            //             if jsonbuffer.FindSet() then begin
            //                 Tracker.Init();
            //                 Tracker.Validate("No.", ShipPackageHeader.No);
            //                 Tracker.Validate("Line No", i);
            //                 Tracker.Validate("Tracking Code", TrackingCode);
            //                 Tracker.Insert();
            //                 repeat
            //                     Tracker.Reset();
            //                     Tracker.SetRange("No.", ShipPackageHeader.No);
            //                     Tracker.SetRange("Line No", i);
            //                     if Tracker.FindLast() then begin
            //                         if 'tracking_details[' + format(i) + '].message' = jsonbuffer.Path then
            //                             Tracker.Validate(Message, jsonbuffer.GetValue());
            //                         if 'tracking_details[' + format(i) + '].status' = jsonbuffer.Path then
            //                             Tracker.Validate(Status, jsonbuffer.GetValue());
            //                         // if 'tracking_details[' + format(i) + '].tracking_location' = jsonbuffer.Path then
            //                         //     Tracker.Validate("Tracking Location", jsonbuffer.GetValue());
            //                         if 'tracking_details[' + format(i) + '].source' = jsonbuffer.Path then
            //                             Tracker.Validate(Service, jsonbuffer.GetValue());
            //                         if 'tracking_details[' + format(i) + '].tracking_location.country' = jsonbuffer.Path then
            //                             Tracker.Validate(Country, jsonbuffer.GetValue());
            //                         if 'tracking_details[' + format(i) + '].tracking_location.city' = jsonbuffer.Path then
            //                             Tracker.Validate(City, jsonbuffer.GetValue());
            //                         if 'tracking_details[' + format(i) + '].tracking_location.state' = jsonbuffer.Path then
            //                             Tracker.Validate(State, jsonbuffer.GetValue());
            //                         if 'tracking_details[' + format(i) + '].tracking_location.zip' = jsonbuffer.Path then begin
            //                             if jsonbuffer.GetValue() = '' then
            //                                 Tracker.Validate(Zip, 'Null');
            //                         END;
            //                         if 'tracking_details[' + format(i) + '].carrier_code' = jsonbuffer.Path then begin
            //                             if jsonbuffer.GetValue() = '' then
            //                                 Tracker.Validate(Carrier, 'Null');
            //                         end;
            //                         if 'tracking_details[' + Format(i) + '].tracking_location.object' = jsonbuffer.Path then
            //                             Tracker.Validate(object, jsonbuffer.GetValue());
            //                         Tracker.Modify();
            //                     end
            //                 until jsonbuffer.Next() = 0;
            //             end;
            //             i := i + 1;
            //         until i = 50;
            //     end;
            // }
            // action("EasyPost Response")
            // {
            //     ApplicationArea = All;
            //     trigger OnAction()
            //     var
            //         serviceMngt: Codeunit "Rate Mgnt";
            //         Username: text;
            //         Pwd: text;
            //         client: HttpClient;
            //     begin
            //         ///Username := 'EZTK8069182a35cf49ea896f89e54629d942wmRjzkNTvZGT30oERnVExg';
            //         //serviceMngt.AddHttpBasicAuthHeader(Rec);
            //     end;
            // }
        }
    }
    local procedure SetJSONData(ShipPackageLines: Record "Ship Packing Lines";
    I: Integer)
    var
        JsonObjectVar: JsonObject;
        ShipPackageHeader: Record "Ship Package Header";
        Location: Record Location;
        BoxMaster: Record "Box Master";
    begin
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange(No, Rec."No.");
        if ShipPackageHeader.FindFirst() then;
        Location.Get(ShipPackageHeader.Location);
        "Boxmaster".Get(ShipPackageLines."Packing type");
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
                    ParcelInfo(BoxMaster);
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

    local procedure ParcelInfo(BoxMaster: Record "Box Master")
    var
        JsonObjectVar: JsonObject;
    begin
        Clear(JsonObjectVar);
        JsonObjectVar.Add('length', BoxMaster.L);
        JsonObjectVar.Add('width', BoxMaster.W);
        JsonObjectVar.Add('height', BoxMaster.H);
        //  JsonObjectVar.Add('predefined_package', 'null');
        JsonObjectVar.Add('weight', BoxMaster."Weight of BoX");
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
    begin
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange(No, Rec."No.");
        if ShipPackageHeader.FindFirst() then;
        "/Box master".Get(ShipPackageLines."Packing type");
        Location.Get(ShipPackageHeader.Location);
        Clear(ChildJeson);
        Clear(ChildJesonArray);
        ChildJeson.Add('description', 'Many, many EasyPost stickers.');
        ChildJeson.Add('hs_tariff_number', '12356');
        ChildJeson.Add('origin_country', Location."Country/Region Code");
        ChildJeson.Add('quantity', ShipPackageLines."Packed Qty");
        ChildJeson.Add('value', 879);
        ChildJeson.Add('weight', "/Box master"."Weight of BoX");
        ChildJesonArray.Add(ChildJeson);
        JsonObjectVar.Add('customs_items', ChildJesonArray);
        //Clear(ChildJeson);
    end;

    var
        "/Box master": Record "Box Master";
        Location: Record Location;
        ShipPackageHeader: Record "Ship Package Header";
        NoSeries: Codeunit NoSeriesManagement;
        PackingList: Record "Packing List";
        JsonArrayVar: JsonArray;
        MasterJson: JsonObject;
        ChildJeson: JsonObject;
        ChildJesonArray: JsonArray;
        GrandMasterJson: JsonObject;
        NULL: Text;
}
