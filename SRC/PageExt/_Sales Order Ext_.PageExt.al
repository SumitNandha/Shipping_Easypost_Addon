pageextension 55005 "Sales Order Ext" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("SI Total Shipping Rate"; Rec."SI Total Shipping Rate")
            {
                ApplicationArea = ALL;
                Editable = false;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            // action("Ship Freight Quote")
            // {
            //     ApplicationArea = All;
            //     Image = Shipment;

            //     trigger OnAction()
            //     var
            //         SalesHeader: Record "Sales Header";
            //     begin
            //         SalesHeader.Reset();
            //         SalesHeader.SetRange("No.", Rec."No.");
            //         if SalesHeader.FindFirst() then begin
            //             Page.RunModal(Page::"Ship Freight Quote", SalesHeader)
            //         end;
            //     end;
            // }
            action("Ship Package List")
            {
                ApplicationArea = All;
                Image = List;

                trigger OnAction()
                var
                    ShipPackageHeader: Record "Ship Package Header";
                begin
                    ShipPackageHeader.Reset();
                    ShipPackageHeader.SetRange("Document No.", Rec."No.");
                    if ShipPackageHeader.FindSet() then;
                    Page.RunModal(Page::"Ship Package List", ShipPackageHeader);
                end;
            }
            action("Create Ship Package Card")
            {
                ApplicationArea = All;
                Image = CreateForm;

                trigger OnAction()
                var
                    ShipPackageHeader: Record "Ship Package Header";
                    ShipPackageHeader2: Record "Ship Package Header";
                    Noseries: Codeunit NoSeriesManagement;
                    packingModuleSetup: Record "Packing Module Setup";
                    shippackageheaderpage: Page "Ship Package Header";
                begin
                    ShipPackageHeader.Init();
                    packingModuleSetup.Get();
                    if ShipPackageHeader.No = '' then ShipPackageHeader.No := Noseries.GetNextNo(packingModuleSetup."Packing Nos", 0D, true);
                    ShipPackageHeader.Validate("Document No.", Rec."No.");
                    ShipPackageHeader.Insert();
                    // shippackageheaderpage.SetTableView(ShipPackageHeader);
                    // shippackageheaderpage.Run();
                    ShipPackageHeader2.reset;
                    ShipPackageHeader2.SetRange(No, ShipPackageHeader.No);
                    if ShipPackageHeader2.FindFirst() then
                        Page.Run(Page::"Ship Package Header", ShipPackageHeader2);
                end;
            }
        }
    }
    local procedure SetJSONData(SalesHeader: Record "Sales Header";
    I: Integer)
    var
        JsonObjectVar: JsonObject;
    begin
        case I of
            1:
                begin
                    MasterJson.Add('object', 'Shipment');
                    SetShippingToAddress(SalesHeader);
                end;
            2:
                begin
                    SetShippingFromAddress(SalesHeader);
                end;
            3:
                begin
                    ParcelInfo(SalesHeader);
                end;
            4:
                begin
                    Custom_info(SalesHeader);
                end;
        end;
    end;

    local procedure SetShippingToAddress(SalesHeader: Record "Sales Header")
    var
        myInt: Integer;
        JsonObjectVar: JsonObject;
    begin
        JsonObjectVar.Add('name', SalesHeader."Ship-to Name");
        JsonObjectVar.Add('company', '');
        JsonObjectVar.Add('street1', SalesHeader."Ship-to Address");
        JsonObjectVar.Add('street2', SalesHeader."Ship-to Address 2");
        JsonObjectVar.Add('city', SalesHeader."Ship-to City");
        JsonObjectVar.Add('state', SalesHeader."Ship-to County");
        JsonObjectVar.Add('zip', SalesHeader."Ship-to Post Code");
        JsonObjectVar.Add('country', SalesHeader."Ship-to Country/Region Code");
        JsonObjectVar.Add('phone', SalesHeader."Sell-to Phone No.");
        JsonObjectVar.Add('mode', '');
        JsonObjectVar.Add('carrier_facility', NULL);
        JsonObjectVar.Add('residential', NULL);
        JsonObjectVar.Add('email', SalesHeader."Sell-to E-Mail");
        MasterJson.Add('to_address', JsonObjectVar);
    end;

    local procedure SetShippingFromAddress(SalesHeader: Record "Sales Header")
    var
        JsonObjectVar: JsonObject;
    begin
        JsonObjectVar.Add('name', SalesHeader."Ship-to Name");
        JsonObjectVar.Add('company', '');
        JsonObjectVar.Add('street1', SalesHeader."Ship-to Address");
        JsonObjectVar.Add('street2', SalesHeader."Ship-to Address 2");
        JsonObjectVar.Add('city', SalesHeader."Ship-to City");
        JsonObjectVar.Add('state', SalesHeader."Ship-to County");
        JsonObjectVar.Add('zip', SalesHeader."Ship-to Post Code");
        JsonObjectVar.Add('country', SalesHeader."Ship-to Country/Region Code");
        JsonObjectVar.Add('phone', SalesHeader."Sell-to Phone No.");
        JsonObjectVar.Add('email', SalesHeader."Sell-to E-Mail");
        JsonObjectVar.Add('mode', '');
        JsonObjectVar.Add('carrier_facility', '');
        JsonObjectVar.Add('residential', '');
        MasterJson.Add('from_address', JsonObjectVar);
    end;

    local procedure ParcelInfo(SalesHeader: Record "Sales Header")
    var
        JsonObjectVar: JsonObject;
    begin
        JsonObjectVar.Add('length', 5480.9);
        JsonObjectVar.Add('width', 4563);
        JsonObjectVar.Add('height', 145.65);
        JsonObjectVar.Add('predefined_package', '');
        JsonObjectVar.Add('weight', 140.123);
        MasterJson.Add('Parcel', JsonObjectVar);
    end;

    local procedure Custom_info(SalesHeader: Record "Sales Header")
    var
        JsonObjectVar: JsonObject;
    begin
        JsonObjectVar.Add('contents_explanation', '');
        JsonObjectVar.Add('contents_type', 'merchandise');
        JsonObjectVar.Add('customs_certify', false);
        JsonObjectVar.Add('customs_signer', '');
        JsonObjectVar.Add('eel_pfc', '');
        JsonObjectVar.Add('non_delivery_option', 'Return');
        JsonObjectVar.Add('restriction_comments', '');
        JsonObjectVar.Add('restriction_type', 'None');
        Custom_items(JsonObjectVar, SalesHeader);
        MasterJson.Add('customs_info', JsonObjectVar);
    end;

    local procedure Custom_items(var JsonObjectVar: JsonObject;
    SalesHeader: Record "Sales Header")
    var
    begin
        ChildJeson.Add('description', 'Many, many EasyPost stickers.');
        ChildJeson.Add('hs_tariff_number', '12356');
        ChildJeson.Add('origin_country', 'US');
        ChildJeson.Add('quantity', 5);
        ChildJeson.Add('value', 879);
        ChildJeson.Add('weight', 140);
        ChildJesonArray.Add(ChildJeson);
        JsonObjectVar.Add('customs_items', ChildJesonArray);
    end;

    var
        JsonArrayVar: JsonArray;
        MasterJson: JsonObject;
        ChildJeson: JsonObject;
        ChildJesonArray: JsonArray;
        GrandMasterJson: JsonObject;
        NULL: Text;
}
