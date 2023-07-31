report 55000 "Pick and Pack Report"
{
    ApplicationArea = All;
    Caption = 'Pick and Pack Report';
    UsageCategory = Documents;
    DefaultLayout = RDLC;
    RDLCLayout = './SRC/Layout/PickAndPack.rdl';

    dataset
    {
        dataitem("ShipPackageHeader"; "Ship Package Header")
        {
            RequestFilterFields = "No";
            MaxIteration = 1;

            // DJ12112021 +

            column(shipmentNo; postedsalesshipment."No.")
            {
            }
            column(No; No)
            {
            }
            column(Carrier; Carrier)
            {
            }
            column(Service; Service)
            {
            }
            column(PickUp_Date; "PickUp Date")
            {
            }
            column(Web_Order_No; "Web Order No")
            {
            }
            column(Inventory_Pick; "Inventory Pick")
            {
            }
            column(Customer_PO_No; "Customer PO No")
            {
            }
            column(PackingTypeBox; PackingTypeBox)
            {
            }
            column(Packdetails; Packdetails)
            {
            }
            column(PackingTypePallet; PackignTypePallet)
            {
            }
            column(Tracking_Code; "Tracking Code")
            {
            }
            // DJ -
            column(LocationFromShip; Location)
            {
            }
            column(CountOfLines; CountOfLines)
            {
            }
            column(CountOfLinesP; CountOfLinesP)
            {
            }
            column(Order_No; "Document No.")
            {
            }
            column(LOGO; CompanyInfo.Picture)
            {
            }
            column(ShipToAddress1; "Ship-to Name")
            {
            }
            column(ShipToAddress2; "Ship-to Address")
            {
            }
            column(ShipToAddress3; "Ship-to Address 2")
            {
            }
            column(ShipToAddress4; "Ship-to City")
            {
            }
            column(ShipToAddress5; "Ship-to County")
            {
            }
            column(ShipToAddress6; "Ship-to Post Code")
            {
            }
            column(ShipToAddress7; "Ship-to Country/Region Code")
            {
            }
            column(BillToAddress1; "Bill-to Name")
            {
            }
            column(BillToAddress2; "Bill-to Address")
            {
            }
            column(BillToAddress3; "Bill-to Address 2")
            {
            }
            column(BillToAddress4; "Bill-to City")
            {
            }
            column(BillToAddress5; "Bill-to County")
            {
            }
            column(BillToAddress6; "Bill-to Post Code")
            {
            }
            column(BillToAddress7; "Bill-to Country/Region Code")
            {
            }
            DataItem("Ship Packing Lines"; "Ship Packing Lines")
            {
                DataItemLinkReference = "ShipPackageHeader";
                DataItemLink = "No." = field("No");
                DataItemTableView = sorting("No.");

                column(Packing_No_; "Packing No.")
                {
                }
                column(GrossWTData; GrossWT)
                {
                }
                column(No_; "No.")
                {
                }
                column(LineNo; "Line No.")
                {
                }
                column(Lot_No_; "Lot No.")
                {
                }
                column(LenWitHei; LenWitHei)
                {
                }
                column(Item_No_Ship; "Item No.")
                {
                }
                column(Description_Ship; Description)
                {
                }
                column(Packing_type; "Sales UOM")
                {
                }
                column(QuantityShip; Quantity)
                {
                }
                column(Bin_Code; "Bin Code")
                {
                }
                trigger OnAfterGetRecord()
                var
                    ShipPackLines: Record "Ship Packing Lines";
                    SalesHeader: Record "Sales Header";
                begin
                    if BoxMaster.Get("Packing type") then begin
                        LenWitHei := Format(BoxMaster.L) + '-' + Format(BoxMaster.W) + '-' + Format(BoxMaster.H);
                        GrossWT := BoxMaster."Weight of Pallet/BoX";
                    end;
                    //  Message("No.");
                    SalesHeader.Reset();
                    SalesHeader.SetRange("No.", ShipPackageHeader."Document No.");
                    if SalesHeader.FindFirst() then;
                    //
                    FormatAddress.SalesHeaderSellTo(BillToAddress, SalesHeader);
                    FormatAddress.SalesHeaderShipTo(ShipToAddress, ShipToAddress, SalesHeader);
                    UOM.Get("Ship Packing Lines"."Sales UOM");
                end;
            }
            dataitem("Sub Packing Lines"; "Sub Packing Lines")
            {
                DataItemTableView = sorting("Packing No.") where("Packing Type" = filter(Box));
                DataItemLink = "Packing No." = field(No);

                column(Box_Sr_ID_Packing_No_; "Box Sr ID/Packing No.")
                {
                }
                column(PackingType; "Packing Type")
                {
                }
                column(Box_Dimension; BoxDimension)
                {
                }
                column(SubPackingLinesLine_No_; "Line No.")
                {
                }
                column(GrossWeight; "Total Gross Ship Wt")
                {
                }
                column(Tracking_ID; "Tracking ID")
                {
                }
                // column(PackingType1; "Packing Type")
                // {
                // }
                dataitem("ReAdjust Packing"; "ReAdjust Packing")
                {
                    DataItemTableView = sorting("Packing No") where("Packing Type" = filter(Box));
                    DataItemLink = "Packing No" = field("Packing No."), "Box/Pallet ID" = field("Box Sr ID/Packing No.");

                    column(Item_Description; "Item Description")
                    {
                    }
                    column(Item_No_; "Item No.")
                    {
                    }
                    column(Box_Pallet_ID; "Box/Pallet ID")
                    {
                    }
                    column(Line_No_; "Line No.")
                    {
                    }
                    column(Qty_to_pack_in_this_Box; "Qty to pack in this Box")
                    {
                    }
                    column(packtypebox; Item."Sales Unit of Measure")
                    {
                    }
                    trigger OnAfterGetRecord()
                    var

                    begin
                        // Message('Readjust %1', "Box/Pallet ID");
                        Item.Get("Item No.");

                    end;
                }
                trigger OnAfterGetRecord()
                var
                    packingAdjustment: Record "Packing Adjustment";
                    Shippackagelines: Record "Ship Packing Lines";
                begin
                    Clear(BoxDimension);
                    packingAdjustment.Get("Packing No.", "Box Sr ID/Packing No.");
                    BoxDimension := Format(packingAdjustment.L) + '-' + format(packingAdjustment.W) + '-' + format(packingAdjustment.H);




                end;
                // }
                // }
            }
            dataitem("Sub Packing Lines P"; "Sub Packing Lines")
            {
                DataItemTableView = sorting("Packing No.") where("Packing Type" = filter(Pallet));
                DataItemLink = "Packing No." = field(No);

                column(Box_Sr_ID_Packing_No_p; "Box Sr ID/Packing No.")
                {
                }
                column(PackingTypeP; "Packing Type")
                {
                }
                column(Box_DimensionP; PalletDimension)
                {
                }
                column(SubPackingLinesLine_No_P; "Line No.")
                {
                }
                column(GrossWeightP; "Total Gross Ship Wt")
                {
                }
                column(Tracking_IDP; "Tracking ID")
                {
                }
                // column(PackingType1P; "Packing Type")
                // {
                // }
                dataitem("ReAdjust PackingP"; "ReAdjust Packing")
                {
                    DataItemTableView = sorting("Packing No") where("Packing Type" = filter(Pallet));
                    DataItemLink = "Packing No" = field("Packing No."), "Box/Pallet ID" = field("Box Sr ID/Packing No.");

                    column(Item_DescriptionP; "Item Description")
                    {
                    }
                    column(Item_No_P; "Item No.")
                    {
                    }
                    column(Box_Pallet_IDP; "Box/Pallet ID")
                    {
                    }
                    column(Line_No_P; "Line No.")
                    {
                    }
                    column(Qty_to_pack_in_this_BoxP; "Qty to pack in this Box")
                    {
                    }
                    column(packtypepallet; Item."Sales Unit of Measure")
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        //   Message('Readjust %1', "Box/Pallet ID");
                        Item.Get("Item No.");
                    end;
                }
                trigger OnAfterGetRecord()
                var
                    packingAdjustment: Record "Packing Adjustment";
                begin
                    Clear(PalletDimension);
                    packingAdjustment.Get("Packing No.", "Box Sr ID/Packing No.");
                    PalletDimension := Format(packingAdjustment.L) + '-' + format(packingAdjustment.W) + '-' + format(packingAdjustment.H);
                end;
                // }
                // }
            }
            trigger OnAfterGetRecord()
            var
                SubPackingLinesP: Record "Sub Packing Lines";
                SubPackingLines: Record "Sub Packing Lines";

            begin
                Clear(CountOfLinesP);
                //  Message('SubPacking %1', "Box Sr ID/Packing No.");
                "SubPackingLinesP".Reset();
                "SubPackingLinesP".SetRange("Packing No.", "ShipPackageHeader".No);
                "SubPackingLinesP".SetRange("Packing Type", "SubPackingLinesP"."Packing Type"::Pallet);
                //   ShipPackLines.SetFilter("Packed Qty", '<>%1', 0);
                if "SubPackingLinesP".FindSet() then begin
                    // Message("Sub Packing Lines"."No.");
                    CountOfLinesP := "SubPackingLinesP".Count;
                    PackignTypePallet := 'Pallet';
                    Packdetails := format(CountOfLinesP) + ' ' + PackignTypePallet;
                end;
                Clear(CountOfLines);
                //  Message('SubPacking %1', "Box Sr ID/Packing No.");
                "SubPackingLines".Reset();
                "SubPackingLines".SetRange("Packing No.", "ShipPackageHeader".No);
                "SubPackingLines".SetRange("Packing Type", "SubPackingLines"."Packing Type"::Box);
                //   ShipPackLines.SetFilter("Packed Qty", '<>%1', 0);
                if "SubPackingLines".FindSet() then begin
                    // Message("Sub Packing Lines"."No.");
                    CountOfLines := "SubPackingLines".Count;
                    PackingTypeBox := 'Box';
                    Packdetails += ' ' + format(CountOfLines) + ' ' + PackingTypeBox;
                end;

                postedsalesshipment.Reset();
                postedsalesshipment.SetRange("SI Inv. Pick No.", "Inventory Pick");
                if postedsalesshipment.FindFirst() then;
            end;
        }
    }
    labels
    {
        Title = 'PICK & PACK';
        Pack = 'Pack#';
        Pick = 'Pick#';
        Shipment = 'Shipment#';
        SO = 'SO#';
        WebOrder = 'Web Order#';
        CustomerPO = 'Customer PO#';
        ShipTo = 'Ship To:';
        BillTo = 'Bill To:';
        PickItem = 'Pick Item';
        Product = 'Product Name';
        // Name = 'Name';
        LOT = 'LOT#';
        PackType = 'Pack Type';
        QtyToPick = 'Qty To Pick';
        BinCode = 'Bin Code';
        LocCode = 'LOC. Code';
        QtyPick = 'Actual Qty Picked';
        ShipmentPacking = 'Shipment Packing';
        TotalShippingUnit = 'Total Shipping Unit';
        CarrierLbl = 'Carriers:';
        ServiceLbl = 'Service:';
        Item = 'Item#';
        BoxID = 'BOX ID:';
        Boxsize = 'Box Size:';
        GrossWt = 'Gross Wt';
        Tracking = 'Tracking#';
        ItemDesc = 'Item Description';
        Qty = 'Qty';
        PalletIDLbl = 'Pallet ID';
        PalletSize = 'Pallet Size';
        Boxes = 'Boxes';
        Pallets = 'Pallets';
        LBs = '(LB)';
        DateLbl = 'Date#';
    }
    trigger OnInitReport()
    var
    begin
        if CompanyInfo.get then;
        CompanyInfo.CalcFields(Picture);
    end;

    var
        postedsalesshipment: Record "Sales Shipment Header";
        Item: Record item;
        Packdetails: text[50];
        PalletDimension: Code[20];
        BoxDimension: Code[20];
        UOM: Record "Unit of Measure";
        PackingTypeBox: Text;
        PackignTypePallet: Text;
        SalesOrder: Report "Sales Order";
        BillToAddress: array[8] of Text[100];
        ShipToAddress: array[8] of Text[100];
        FormatAddress: Codeunit "Format Address";
        CompanyInfo: Record "Company Information";
        CountOfLines: Integer;
        CountOfLinesP: Integer;
        PackingNo: Code[20];
        LenWitHei: Text;
        BoxMaster: Record "Pallet/Box Master";
        GrossWT: Decimal;
}
