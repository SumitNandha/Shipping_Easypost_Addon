page 55014 "Combine Rate Information"
{
    SourceTable = "Combine Rate Information";
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    //Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    // ModifyAllowed = false;
    Caption = 'Choose/Buy Service';

    layout
    {
        area(Content)
        {
            repeater(Details)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field(Carrier; Rec.Carrier)
                {
                    ToolTip = 'Specifies the value of the Carrier field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field(Service; Rec.Service)
                {
                    ToolTip = 'Specifies the value of the Service field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("Delivery Days"; Rec."Delivery Days")
                {
                    ToolTip = 'Specifies the value of the Delivery Days field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field(Rate; Rec.Rate)
                {
                    ToolTip = 'Specifies the value of the Rate field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                    Caption = 'Carrier Base Shipping Cost';
                }
                field("Markup Value"; Rec."Markup Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("Total Shipping Rate for Customer"; Rec."Total Shipping Rate for Customer")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("YRC Error Code"; Rec."YRC Error Code")
                {
                    ToolTip = 'Specifies the value of the YRC Error Code field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("YRC Error Message"; Rec."YRC Error Message")
                {
                    ToolTip = 'Specifies the value of the YRC Error Message field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("EasyPost CA Account"; Rec."EasyPost CA Account")
                {
                    
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                    ToolTip = 'Specifies the value of the EasyPost CA Account field.';
                }
                field("EasyPost CA Name"; Rec."EasyPost CA Name")
                {
                     ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                    ToolTip = 'Specifies the value of the EasyPost CA Name field.';
                }
                
                field("Choose Service"; Rec."Choose Service")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Style = Unfavorable;
                }
                field("Buy Service"; Rec."Buy Service")
                {
                    ToolTip = 'Specifies the value of the Buy Service field.';
                    ApplicationArea = All;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;

                    trigger OnValidate()
                    var
                        ShipPackageHeader: Record "Ship Package Header";
                        buyShipment: Codeunit BuyShipment;
                        CombineRateInfo: Record "Combine Rate Information";
                        SubPackinLines: Record "Sub Packing Lines";
                        BuyShipmentRec: Record "Buy Shipment";
                        RateMngt: Codeunit "Rate Mgnt";
                    begin
                        if Rec."Buy Service" = true then begin
                            CombineRateInfo.Reset();
                            CombineRateInfo.SetRange("Packing No.", Rec."Packing No.");
                            CombineRateInfo.SetRange("Buy Service", true);
                            if not CombineRateInfo.FindSet() then begin
                                if ShipPackageHeader.Get(Rec."Packing No.") then
                                    if ShipPackageHeader."Inventory Pick" <> '' then begin
                                        RateMngt.CheckGetRates(Rec);
                                        buyShipment.BuyShipmentHeader(Rec)
                                    end else
                                        Error('Buy Service can’t be used if the Ship Package Card is for a Sales Order/Sales Quote.  Please use Choose Service column');
                            end
                            else
                                Error('Service already bought.');
                        end;
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        ShipPackageHeader: Record "Ship Package Header";
    begin
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange("No", Rec."Packing No.");
        if ShipPackageHeader.FindFirst() then;
        // if (Rec.Carrier = ShipPackageHeader.Carrier) and (Rec.Service = ShipPackageHeader.Service) then
        //     CombineRateBoolean := true
        // else
        //     CombineRateBoolean := false;
        if (Rec."EasyPost CA Name" = ShipPackageHeader.Carrier) and (Rec.Service = ShipPackageHeader.Service) then
            CombineRateBoolean := true
        else
            CombineRateBoolean := false;
        //   Rec."Update Suggested Addr" := true;
    end;

    var
        CombineRateBoolean: Boolean;
}
