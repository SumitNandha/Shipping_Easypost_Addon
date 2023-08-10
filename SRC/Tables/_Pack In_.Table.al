table 55014 "Pack In"
{
    Caption = 'Pack In';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Packing No."; Code[20])
        {
            Caption = 'Packing No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Pack in Boxes?"; Boolean)
        {
            Caption = 'Pack in Boxes?';
            DataClassification = ToBeClassified;
        }
        field(12; "Class"; Enum Class)
        {
            Caption = 'Class';
            DataClassification = ToBeClassified;
        }
        field(5; "Suggest Packing"; Boolean)
        {
            Caption = 'Suggest Packing';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                PackInLines: Record "Pack In Lines";
                PackInLines2: Record "Pack In Lines";
                BoxMaster: Record "Box Master";
                SubPackingLines: Record "Sub Packing Lines";
                SubPackingLinesLast: Record "Sub Packing Lines";
                NoSeries: Codeunit NoSeriesManagement;
                ReAdjustPacking: Record "ReAdjust Packing";
                Totalqty: Decimal;
                GrossWt: decimal;
                PackingModuleSetUp: Record "Packing Module Setup";
                i: Integer;
                Item: Record Item;
                SalesLines: Record "Sales Line";
                shippackagelines: Record "Ship Packing Lines";
            begin
                if Rec."Suggest Packing" = true then begin
                    ReAdjustPacking.Reset();
                    ReAdjustPacking.SetRange("Packing No", Rec."Packing No.");
                    if ReAdjustPacking.FindSet() then ReAdjustPacking.DeleteAll(); //SN-12-11-2021+
                    //SubPackingLinesLast.DeleteAll();
                    PackingModuleSetUp.Get();
                    PackingModuleSetUp.TestField("Combine Box Code");
                    SubPackingLinesLast.reset();
                    SubPackingLinesLast.SetRange("Packing No.", Rec."Packing No.");
                    if SubPackingLinesLast.FindLast() then SubPackingLinesLast.DeleteAll();
                    shippackagelines.Reset();
                    shippackagelines.SetRange("No.", Rec."Packing No.");
                    if shippackagelines.FindSet() then
                        repeat
                            BoxMaster.Reset();
                            BoxMaster.SetRange("Box", shippackagelines."Box Code for Item");
                            if BoxMaster.FindFirst() then;
                        // if BoxMaster.Type = BoxMaster.Type:: then Error('Item %1 has been assigned to be shipped on ', shippackagelines."Item No.");
                        until shippackagelines.Next() = 0;
                    PackInLines.Reset();
                    PackInLines.SetRange("Packing No.", Rec."Packing No.");
                    PackInLines.SetFilter("Box ID", '<>%1', PackingModuleSetUp."Combine Box Code");
                    if PackInLines.FindSet() then begin
                        repeat
                            for i := 1 to PackInLines."Total Qty" do begin
                                SubPackingLinesLast.reset();
                                SubPackingLinesLast.SetRange("Packing No.", Rec."Packing No.");
                                if SubPackingLinesLast.FindLast() then;
                                SubPackingLines.Init();
                                SubPackingLines.Validate("Packing No.", Rec."Packing No.");
                                SubPackingLines.Validate("Line No.", SubPackingLinesLast."Line No." + 10000);
                                SubPackingLines.Validate("Document Line No.", PackInLines."Line No.");
                                SubPackingLines.Validate("Box Code / Packing Type", PackInLines."Box ID");
                                BoxMaster.Get(PackInLines."Box ID");
                                //SubPackingLines.Validate("Box Sr ID/Packing No.", '');
                                PackInLines.Validate("Box Qty Packing Details", SubPackingLines."Box Sr ID/Packing No.");
                                SubPackingLines.Validate("Qty Packed", 1);
                                Item.Get(PackInLines."Item No.");
                                SubPackingLines.Validate("Total Gross Ship Wt", (Item."Gross Weight" + BoxMaster."Weight of BoX"));
                                SubPackingLines.Validate("Box Dimension", (format(BoxMaster.L) + ' X ' + Format(BoxMaster.W) + ' X ' + Format(BoxMaster.H)));
                                SubPackingLines.Insert();
                                PackInLines.Validate("Qty Packed", PackInLines."Total Qty");
                                PackInLines.Validate("Qty in this Box", 1);
                                PackInLines.Validate("Remaining Qty", PackInLines."Total Qty" - PackInLines."Qty Packed");
                                PackInLines.Modify();
                                ReAdjustPacking.Reset();
                                ReAdjustPacking.SetRange("Packing No", PackInLines."Packing No.");
                                ReAdjustPacking.SetRange("Box ID", SubPackingLines."Box Sr ID/Packing No.");
                                ReAdjustPacking.SetRange("Line No.", PackInLines."Line No.");
                                if not ReAdjustPacking.FindSet() then begin
                                    // ReAdjustPacking.DeleteAll();
                                    ReAdjustPacking.Init();
                                    ReAdjustPacking.Validate("Packing No", PackInLines."Packing No.");
                                    ReAdjustPacking.Validate("Line No.", PackInLines."Line No.");
                                    ReAdjustPacking.Validate("Box ID", SubPackingLines."Box Sr ID/Packing No.");
                                    ReAdjustPacking.Validate("Item No.", PackInLines."Item No.");
                                    ReAdjustPacking.Validate("Item Description", PackInLines."Item Description");
                                    ReAdjustPacking.Validate("Sales UoM", PackInLines."Sales UoM");
                                    ReAdjustPacking.Validate("Total Qty", PackInLines."Total Qty");
                                    // ReAdjustPacking.Validate("Qty Packed", SubPackingLines."Qty Packed");
                                    ReAdjustPacking.Validate(SourceLineNo, PackInLines.SourceLineNo);
                                    ReAdjustPacking.Validate("Qty to pack in this Box", 1);
                                    ReAdjustPacking.Insert();
                                end;
                            end;
                        until PackInLines.Next() = 0;
                        //SubPackingLines.Reset();
                    end;
                    PackInLines.Reset();
                    PackInLines.SetRange("Packing No.", Rec."Packing No.");
                    PackInLines.SetFilter("Box ID", '=%1', PackingModuleSetUp."Combine Box Code");
                    if PackInLines.FindSet() then begin
                        PackInLines2.Reset();
                        PackInLines2.SetRange("Packing No.", Rec."Packing No.");
                        PackInLines2.SetFilter("Box ID", '=%1', PackingModuleSetUp."Combine Box Code");
                        if PackInLines2.FindSet() then
                            repeat
                                Totalqty += PackInLines2."Total Qty";
                                GrossWt += PackInLines2."Gross Wt (Items)";
                            until PackInLines2.Next() = 0;
                        //  PackInLines.CalcSums("Total Qty", "Gross Wt (Items)");
                        if Totalqty <> 0 then begin
                            SubPackingLinesLast.reset();
                            SubPackingLinesLast.SetRange("Packing No.", Rec."Packing No.");
                            if SubPackingLinesLast.FindLast() then;
                            SubPackingLines.Init();
                            SubPackingLines.Validate("Packing No.", Rec."Packing No.");
                            SubPackingLines.Validate("Line No.", SubPackingLinesLast."Line No." + 10000);
                            SubPackingLines.Validate("Document Line No.", PackInLines."Line No.");
                            SubPackingLines.Validate("Box Code / Packing Type", PackInLines."Box ID");
                            BoxMaster.Get(PackInLines."Box ID");
                            //   SubPackingLines.Validate("Box Sr ID/Packing No.", NoSeries.GetNextNo(BoxMaster."No Series", 0D, true));
                            SubPackingLines.Validate("Qty Packed", Totalqty);
                            SubPackingLines.Validate("Total Gross Ship Wt", (GrossWt + BoxMaster."Weight of BoX"));
                            SubPackingLines.Validate("Box Dimension", (format(BoxMaster.L) + ' X ' + Format(BoxMaster.W) + ' X ' + Format(BoxMaster.H)));
                            SubPackingLines.Insert();
                            //  PackInLines.Modify();
                            PackInLines.Reset();
                            PackInLines.SetRange("Packing No.", Rec."Packing No.");
                            PackInLines.SetFilter("Box ID", '=%1', PackingModuleSetUp."Combine Box Code");
                            if PackInLines.FindSet() then begin
                                repeat
                                    PackInLines.Validate("Qty Packed", PackInLines."Total Qty");
                                    PackInLines.Validate("Qty in this Box", Totalqty);
                                    PackInLines.Validate("Box Qty Packing Details", SubPackingLines."Box Sr ID/Packing No.");
                                    PackInLines.Validate("Remaining Qty", PackInLines."Total Qty" - PackInLines."Qty Packed");
                                    ReAdjustPacking.Reset();
                                    ReAdjustPacking.SetRange("Packing No", PackInLines."Packing No.");
                                    ReAdjustPacking.SetRange("Box ID", SubPackingLines."Box Sr ID/Packing No.");
                                    ReAdjustPacking.SetRange("Line No.", PackInLines."Line No.");
                                    if not ReAdjustPacking.FindSet() then begin
                                        // ReAdjustPacking.DeleteAll();
                                        ReAdjustPacking.Init();
                                        ReAdjustPacking.Validate("Packing No", PackInLines."Packing No.");
                                        ReAdjustPacking.Validate("Line No.", PackInLines."Line No.");
                                        ReAdjustPacking.Validate("Box ID", SubPackingLines."Box Sr ID/Packing No.");
                                        ReAdjustPacking.Validate("Item No.", PackInLines."Item No.");
                                        ReAdjustPacking.Validate("Item Description", PackInLines."Item Description");
                                        ReAdjustPacking.Validate("Sales UoM", PackInLines."Sales UoM");
                                        ReAdjustPacking.Validate("Total Qty", PackInLines."Total Qty");
                                        //  ReAdjustPacking.Validate("Qty Packed", SubPackingLines."Qty Packed");
                                        ReAdjustPacking.Validate(SourceLineNo, PackInLines.SourceLineNo);
                                        ReAdjustPacking.Validate("Qty to pack in this Box", PackInLines."Total Qty");
                                        ReAdjustPacking.Insert();
                                        PackInLines.Modify();
                                    end;
                                until PackInLines.Next() = 0;
                                //SubPackingLines.Reset();
                            end;
                        end;
                        //  ClearAll();
                    end;
                    SubPackingLines.Reset();
                    SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
                    if SubPackingLines.FindSet() then begin
                        repeat // SubPackingLines."Insurance price" := 0;
                            ReAdjustPacking.Reset();
                            ReAdjustPacking.SetRange("Packing No", SubPackingLines."Packing No.");
                            ReAdjustPacking.SetRange("Box ID", SubPackingLines."Box Sr ID/Packing No.");
                            if ReAdjustPacking.FindSet() then begin
                                repeat
                                    SubPackingLinesLast.Reset();
                                    SubPackingLinesLast.SetRange("Packing No.", ReAdjustPacking."Packing No");
                                    SubPackingLinesLast.SetRange("Box Sr ID/Packing No.", ReAdjustPacking."Box ID");
                                    if SubPackingLinesLast.FindFirst() then begin
                                        SubPackingLinesLast."Insurance price" += ReAdjustPacking."Insurance Price";
                                        SubPackingLinesLast.Modify();
                                    end;
                                until ReAdjustPacking.Next() = 0;
                            end;
                        until SubPackingLines.Next() = 0;
                    end;
                end;
            end;
        }
        field(6; "Pack All in 1 Box"; Boolean)
        {
            Caption = 'Pack All in 1 Box';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                SubPackingLines: Record "Sub Packing Lines";
                SubPackingLinesLast: Record "Sub Packing Lines";
                PackInLines: Record "Pack In Lines";
                BoxMaster: Record "Box Master";
                NoSeries: Codeunit NoSeriesManagement;
                ReAdjustPacking: Record "ReAdjust Packing";
                PackInLines2: Record "Pack In Lines";
                Totalqty: Decimal;
                GrossWt: Decimal;
            begin
                if Rec."Pack All in 1 Box" = true then begin
                    ReAdjustPacking.Reset();
                    ReAdjustPacking.SetRange("Packing No", Rec."Packing No.");
                    if ReAdjustPacking.FindSet() then ReAdjustPacking.DeleteAll();
                    Clear(Totalqty);
                    Clear(GrossWt);
                    Rec.TestField("All in One Box Code");
                    SubPackingLinesLast.reset();
                    SubPackingLinesLast.SetRange("Packing No.", rec."Packing No.");
                    if SubPackingLinesLast.FindLast() then SubPackingLinesLast.DeleteAll();
                    PackInLines.Reset();
                    PackInLines.SetRange("Packing No.", Rec."Packing No.");
                    if PackInLines.FindSet() then begin
                        PackInLines2.Reset();
                        PackInLines2.SetRange("Packing No.", Rec."Packing No.");
                        if PackInLines2.FindSet() then
                            repeat
                                Totalqty += PackInLines2."Total Qty";
                                GrossWt += PackInLines2."Gross Wt (Items)";
                            until PackInLines2.Next() = 0;
                        //end;
                        // PackInLines.CalcSums("Total Qty","Gross Wt (Items)");
                        SubPackingLinesLast.reset();
                        SubPackingLinesLast.SetRange("Packing No.", rec."Packing No.");
                        if SubPackingLinesLast.FindLast() then;
                        SubPackingLines.Init();
                        SubPackingLines.Validate("Packing No.", Rec."Packing No.");
                        SubPackingLines.Validate("Line No.", SubPackingLinesLast."Line No." + 10000);
                        SubPackingLines.Validate("Document Line No.", PackInLines."Line No.");
                        SubPackingLines.Validate("Box Code / Packing Type", "All in One Box Code");
                        BoxMaster.Get("All in One Box Code");
                        //  SubPackingLines.Validate("Box Sr ID/Packing No.", NoSeries.GetNextNo(BoxMaster."No Series", 0D, true));
                        SubPackingLines.Validate("Qty Packed", Totalqty);
                        SubPackingLines.Validate("Total Gross Ship Wt", (GrossWt + BoxMaster."Weight of BoX"));
                        SubPackingLines.Validate("Box Dimension", (format(BoxMaster.L) + ' X ' + Format(BoxMaster.W) + ' X ' + Format(BoxMaster.H)));
                        SubPackingLines.Insert();
                        //PackInLines.Modify();
                        PackInLines.Reset();
                        PackInLines.SetRange("Packing No.", Rec."Packing No.");
                        //  PackInLines.SetFilter("Box ID", '=%1', 'Combine');
                        if PackInLines.FindSet() then begin
                            repeat
                                PackInLines.Validate("Qty Packed", PackInLines."Total Qty");
                                PackInLines.Validate("Qty in this Box", PackInLines."Qty Packed");
                                PackInLines.Validate("Box Qty Packing Details", SubPackingLines."Box Sr ID/Packing No.");
                                PackInLines.Validate("Remaining Qty", PackInLines."Total Qty" - PackInLines."Qty Packed");
                                ReAdjustPacking.Reset();
                                ReAdjustPacking.SetRange("Packing No", PackInLines."Packing No.");
                                ReAdjustPacking.SetRange("Box ID", SubPackingLines."Box Sr ID/Packing No.");
                                ReAdjustPacking.SetRange("Line No.", PackInLines."Line No.");
                                if not ReAdjustPacking.FindSet() then begin
                                    //  ReAdjustPacking.DeleteAll();
                                    ReAdjustPacking.Init();
                                    ReAdjustPacking.Validate("Packing No", PackInLines."Packing No.");
                                    ReAdjustPacking.Validate("Line No.", PackInLines."Line No.");
                                    ReAdjustPacking.Validate("Box ID", SubPackingLines."Box Sr ID/Packing No.");
                                    ReAdjustPacking.Validate("Item No.", PackInLines."Item No.");
                                    ReAdjustPacking.Validate("Item Description", PackInLines."Item Description");
                                    ReAdjustPacking.Validate("Sales UoM", PackInLines."Sales UoM");
                                    ReAdjustPacking.Validate("Total Qty", PackInLines."Total Qty");
                                    //   ReAdjustPacking.Validate("Qty Packed", SubPackingLines."Qty Packed");
                                    ReAdjustPacking.Validate(SourceLineNo, PackInLines.SourceLineNo);
                                    ReAdjustPacking.Validate("Qty to pack in this Box", PackInLines."Total Qty");
                                    ReAdjustPacking.Insert();
                                    PackInLines.Modify();
                                end;
                            until PackInLines.Next() = 0;
                            //  SubPackingLines.Reset();
                        end;
                    end;
                    SubPackingLines.Reset();
                    SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
                    if SubPackingLines.FindSet() then begin
                        SubPackingLines."Insurance price" := 0;
                        repeat
                            ReAdjustPacking.Reset();
                            ReAdjustPacking.SetRange("Packing No", SubPackingLines."Packing No.");
                            if ReAdjustPacking.FindSet() then begin
                                repeat
                                    SubPackingLines."Insurance price" += ReAdjustPacking."Insurance Price";
                                until ReAdjustPacking.Next() = 0;
                            end;
                        until SubPackingLines.Next() = 0;
                        SubPackingLines.Modify();
                    end;
                end;
                //ClearAll();
            end;
        }
        field(8; "All in One Box Code"; Code[20])
        {
            Caption = 'All in One Box Code';
            DataClassification = ToBeClassified;
            TableRelation = "Box Master";
        }
        field(9; "All in One  Code"; Code[20])
        {
            Caption = 'All in One  Code';
            DataClassification = ToBeClassified;
            TableRelation = "Box Master";
        }
        field(10; "Close All Boxs"; Boolean)
        {
            Caption = 'Close All Box';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                PackinLines: Record "Pack In Lines";
                SubPackingLines: Record "Sub Packing Lines";
                i: Integer;
                Packin: Record "Pack In";
                BoxCode: Code[20];
                PackinLines2: Record "Pack In Lines";
                PackingModuleSetUp: Record "Packing Module Setup";
                Readjust: Record "ReAdjust Packing";
                qty: Text;
                SalesHeader: Record "Sales Header";
                shipmarkup: Record "Shipping MarkUp Setup";
                ShipPackageHeader: Record "Ship Package Header";
                LineCount: Integer;
            begin
                PackingModuleSetUp.Get();
                if Rec."Close All Boxs" = true then begin
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    if PackinLines.FindSet() then begin
                        repeat
                            PackinLines."Box Qty Packing Details" := '';
                            PackinLines.Modify();
                        until PackinLines.Next() = 0;
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    PackinLines.SetFilter("Remaining Qty", '<>%1', 0);
                    if PackinLines.FindSet() then Error('Some of items still Unpacked,Please Pack all the items and try again!');
                    SubPackingLines.reset();
                    SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
                    SubPackingLines.SetRange("Qty Packed", 0);
                    if SubPackingLines.FindSet() then begin
                        SubPackingLines.DeleteAll();
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    if PackinLines.FindSet() then begin
                        PackinLines.ModifyAll("Box Qty Packing Details", '');
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    if PackinLines.FindSet() then begin
                        repeat
                            Readjust.Reset();
                            Readjust.SetRange("Packing No", PackinLines."Packing No.");
                            Readjust.SetRange("Line No.", PackinLines."Line No.");
                            if Readjust.FindSet() then begin
                                repeat
                                    qty := Format(Readjust."Qty to pack in this Box");
                                    if PackinLines."Box Qty Packing Details" <> '' then PackinLines."Box Qty Packing Details" += ' | ' + Readjust."Box ID" + ' - ' + qty;
                                    if PackinLines."Box Qty Packing Details" = '' then PackinLines."Box Qty Packing Details" += Readjust."Box ID" + ' - ' + qty;
                                    PackinLines.Modify();
                                until Readjust.Next() = 0;
                            end;
                        until PackinLines.Next() = 0;
                    end;
                    SiEventMgnt.GetMarkupAmount(Rec."Packing No.");
                    // BoxSequence(Rec);
                end;
            end;
        }
        field(11; "Close All s"; Boolean)
        {
            Caption = 'Close All s';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                PackinLines: Record "Pack In Lines";
                SubPackingLines: Record "Sub Packing Lines";
                Readjust: Record "ReAdjust Packing";
                qty: text;
                SalesHeader: Record "Sales Header";
                shipmarkup: Record "Shipping MarkUp Setup";
                ShipPackageHeader: Record "Ship Package Header";
                SImgntCodeunit: Codeunit "SI Event Mgnt";
            begin
                if Rec."Close All s" = true then begin
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    if PackinLines.FindSet() then begin
                        repeat
                            PackinLines."Box Qty Packing Details" := '';
                            PackinLines.Modify();
                        until PackinLines.Next() = 0;
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    PackinLines.SetFilter("Remaining Qty", '<>%1', 0);
                    if PackinLines.FindSet() then Error('Some of items still unpacked,Please pack all the items and try again!');
                    SubPackingLines.reset();
                    SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
                    SubPackingLines.SetRange("Qty Packed", 0);
                    if SubPackingLines.FindSet() then begin
                        SubPackingLines.DeleteAll();
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    if PackinLines.FindSet() then begin
                        PackinLines.ModifyAll("Box Qty Packing Details", '');
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    if PackinLines.FindSet() then begin
                        repeat
                            Readjust.Reset();
                            Readjust.SetRange("Packing No", PackinLines."Packing No.");
                            Readjust.SetRange("Line No.", PackinLines."Line No.");
                            if Readjust.FindSet() then begin
                                repeat
                                    qty := Format(Readjust."Qty to pack in this Box");
                                    if PackinLines."Box Qty Packing Details" <> '' then PackinLines."Box Qty Packing Details" += ' | ' + Readjust."Box ID" + ' - ' + qty;
                                    if PackinLines."Box Qty Packing Details" = '' then PackinLines."Box Qty Packing Details" += Readjust."Box ID" + ' - ' + qty;
                                    PackinLines.Modify();
                                until Readjust.Next() = 0;
                            end;
                        until PackinLines.Next() = 0;
                    end;
                    SubPackingLines.Reset();
                    SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
                    if SubPackingLines.FindSet() then
                        repeat
                            SalesHeader.Reset();
                            SalesHeader.SetRange("No.", Rec."Packing No.");
                            if SalesHeader.FindSet() then
                                if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) or (SalesHeader."Document Type" = SalesHeader."Document Type"::Quote) then
                                    if shipmarkup.Get(SalesHeader."Sell-to Customer No.") then begin
                                        ShipPackageHeader.reset();
                                        ShipPackageHeader.SetRange(No, Rec."Packing No.");
                                        if ShipPackageHeader.FindFirst() then
                                            ShipPackageHeader."Markup value" += shipmarkup."MarkUp per Box";
                                    end;
                        until SubPackingLines.Next() = 0;
                    SiEventMgnt.GetMarkupAmount(Rec."Packing No.");

                end;
            end;
        }
    }
    keys
    {
        key(PK; "Packing No.")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        ShippackingLines: Record "Ship Packing Lines";
        SubPackingLines: Record "Sub Packing Lines";
        PackinLines: Record "Pack In Lines";
        PackingAdjustment: Record "Packing Adjustment";
        buyShipment: Record "Buy Shipment";
        CombinedRateInfo: Record "Combine Rate Information";
        Packin: Record "Pack In";
        // RLRateQuote: Record "RL Rate Quote";
        Readjust: Record "ReAdjust Packing";
    begin
        SubPackingLines.Reset();
        SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
        if SubPackingLines.FindSet() then SubPackingLines.DeleteAll();
        PackinLines.Reset();
        PackinLines.SetRange("Packing No.", Rec."Packing No.");
        if PackinLines.FindSet() then PackinLines.DeleteAll();
        PackingAdjustment.Reset();
        PackingAdjustment.SetRange("Packing No", Rec."Packing No.");
        if PackingAdjustment.FindSet() then PackingAdjustment.DeleteAll();
        Readjust.Reset();
        Readjust.SetRange("Packing No", Rec."Packing No.");
        if Readjust.FindSet() then Readjust.DeleteAll();
    end;



    var
        SiEventMgnt: Codeunit "SI Event Mgnt";
}
