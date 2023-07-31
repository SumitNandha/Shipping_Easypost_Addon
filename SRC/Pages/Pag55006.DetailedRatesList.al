page 55006 "Detailed Rates List"
{
    Caption = 'Detailed Rates';
    PageType = ListPart;
    SourceTable = "Buy Shipment";
    ApplicationArea = All;
    UsageCategory = Lists;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    Visible = false;
                    ApplicationArea = All;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("Purchase Service"; Rec."Purchase Service")
                {
                    ToolTip = 'Specifies the value of the Purchase Service field.';
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
                field("Packing No"; Rec."Packing No")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("Quote ID"; Rec."Quote ID")
                {
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("YRC Service Req: Code"; Rec."YRC Service Req")
                {
                    ToolTip = 'Specifies the value of the YRC Service Req field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field(Currency; Rec.Currency)
                {
                    ToolTip = 'Specifies the value of the Currency field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field(Rate; Rec.Rate)
                {
                    Caption = 'Carrier Base Cost';
                    ToolTip = 'Specifies the value of the Rate field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("Rate ID"; REC."Rate ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("Shipment ID"; Rec."Shipment ID")
                {
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
                //SJ 07102021 +
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
                field("YRC Service Occ Code"; Rec."YRC Service Occ Code")
                {
                    ToolTip = 'Specifies the value of the YRC Service Occ Code field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("Delivery Date Guaranteed"; Rec."Delivery Date Guaranteed")
                {
                    ToolTip = 'Specifies the value of the Delivery Date Guaranteed field.';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("Shipment Refund Status"; Rec."Shipment Refund Status")
                {
                    ApplicationArea = All;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                    // Editable = false;
                }
                field("EasyPost CA Account"; Rec."EasyPost CA Account")
                {
                    ApplicationArea = All;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                field("EasyPost CA Name"; Rec."EasyPost CA Name")
                {
                    ApplicationArea = All;
                    StyleExpr = CombineRateBoolean;
                    Style = Unfavorable;
                }
                //SJ 07102021 -
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        ShipPackageHeader: Record "Ship Package Header";
    begin
        ShipPackageHeader.Reset();
        ShipPackageHeader.SetRange(No, Rec."No.");
        if ShipPackageHeader.FindFirst() then;
        if (ShipPackageHeader.Carrier = 'YRC') and (ShipPackageHeader.Service <> 'STND') then begin
            if (Rec."EasyPost CA Name" = ShipPackageHeader.Carrier) and (Rec.Service = DelStr(ShipPackageHeader.Service, StrPos(ShipPackageHeader.Service, '-'))) AND (Rec."YRC Service Req" = CopyStr(ShipPackageHeader.Service, StrPos(ShipPackageHeader.Service, '-'))) then
                CombineRateBoolean := true
            else
                CombineRateBoolean := false;
        end
        ELSE begin
            if (Rec."EasyPost CA Name" = ShipPackageHeader.Carrier) and (Rec.Service = ShipPackageHeader.Service) then
                CombineRateBoolean := true
            else
                CombineRateBoolean := false;
        end;
        //   Rec."Update Suggested Addr" := true;
    end;

    var
        CombineRateBoolean: Boolean;
}
