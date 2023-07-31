table 55011 "Pack In"
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
        field(2; "Packing Type"; Enum "Pallet/Box Enum")
        {
            Caption = 'Packing Type';
            DataClassification = ToBeClassified;
        }
        field(3; "Pack in Boxes?"; Boolean)
        {
            Caption = 'Pack in Boxes?';
            DataClassification = ToBeClassified;
        }
        field(4; "Pack In Pallets?"; Boolean)
        {
            Caption = 'Pack In Pallets?';
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
                PalletBoxMaster: Record "Pallet/Box Master";
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
                    ReAdjustPacking.SetRange("Packing Type", ReAdjustPacking."Packing Type"::Box);
                    if ReAdjustPacking.FindSet() then ReAdjustPacking.DeleteAll(); //SN-12-11-2021+
                    //SubPackingLinesLast.DeleteAll();
                    PackingModuleSetUp.Get();
                    PackingModuleSetUp.TestField("Combine Box Code");
                    SubPackingLinesLast.reset();
                    SubPackingLinesLast.SetRange("Packing No.", Rec."Packing No.");
                    SubPackingLineslast.SetRange("Packing Type", Rec."Packing Type");
                    if SubPackingLinesLast.FindLast() then SubPackingLinesLast.DeleteAll();
                    shippackagelines.Reset();
                    shippackagelines.SetRange("No.", Rec."Packing No.");
                    if shippackagelines.FindSet() then
                        repeat
                            PalletBoxMaster.Reset();
                            PalletBoxMaster.SetRange("Pallet/Box", shippackagelines."Box Code for Item");
                            if PalletBoxMaster.FindFirst() then;
                            if PalletBoxMaster.Type = PalletBoxMaster.Type::Pallet then Error('Item %1 has been assigned to be shipped on pallet', shippackagelines."Item No.");
                        until shippackagelines.Next() = 0;
                    PackInLines.Reset();
                    PackInLines.SetRange("Packing No.", Rec."Packing No.");
                    PackInLines.SetRange("Packing Type", PackInLines."Packing Type"::Box);
                    PackInLines.SetFilter("Box/Pallet ID", '<>%1', PackingModuleSetUp."Combine Box Code");
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
                                SubPackingLines.Validate("Packing Type", PackInLines."Packing Type");
                                SubPackingLines.Validate("Box Code / Packing Type", PackInLines."Box/Pallet ID");
                                PalletBoxMaster.Get(PackInLines."Box/Pallet ID");
                                //SubPackingLines.Validate("Box Sr ID/Packing No.", '');
                                PackInLines.Validate("Box/Pallet Qty Packing Details", SubPackingLines."Box Sr ID/Packing No.");
                                SubPackingLines.Validate("Qty Packed", 1);
                                Item.Get(PackInLines."Item No.");
                                SubPackingLines.Validate("Total Gross Ship Wt", (Item."Gross Weight" + PalletBoxMaster."Weight of Pallet/BoX"));
                                SubPackingLines.Validate("Box Dimension", (format(PalletBoxMaster.L) + ' X ' + Format(PalletBoxMaster.W) + ' X ' + Format(PalletBoxMaster.H)));
                                SubPackingLines.Insert();
                                PackInLines.Validate("Qty Packed", PackInLines."Total Qty");
                                PackInLines.Validate("Qty in this Box/Pallet", 1);
                                PackInLines.Validate("Remaining Qty", PackInLines."Total Qty" - PackInLines."Qty Packed");
                                PackInLines.Modify();
                                ReAdjustPacking.Reset();
                                ReAdjustPacking.SetRange("Packing No", PackInLines."Packing No.");
                                ReAdjustPacking.SetRange("Box/Pallet ID", SubPackingLines."Box Sr ID/Packing No.");
                                ReAdjustPacking.SetRange("Line No.", PackInLines."Line No.");
                                if not ReAdjustPacking.FindSet() then begin
                                    // ReAdjustPacking.DeleteAll();
                                    ReAdjustPacking.Init();
                                    ReAdjustPacking.Validate("Packing No", PackInLines."Packing No.");
                                    ReAdjustPacking.Validate("Line No.", PackInLines."Line No.");
                                    ReAdjustPacking.Validate("Box/Pallet ID", SubPackingLines."Box Sr ID/Packing No.");
                                    ReAdjustPacking.Validate("Packing Type", PackInLines."Packing Type");
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
                    PackInLines.SetRange("Packing Type", PackInLines."Packing Type"::Box);
                    PackInLines.SetFilter("Box/Pallet ID", '=%1', PackingModuleSetUp."Combine Box Code");
                    if PackInLines.FindSet() then begin
                        PackInLines2.Reset();
                        PackInLines2.SetRange("Packing No.", Rec."Packing No.");
                        PackInLines2.SetRange("Packing Type", PackInLines2."Packing Type"::Box);
                        PackInLines2.SetFilter("Box/Pallet ID", '=%1', PackingModuleSetUp."Combine Box Code");
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
                            SubPackingLines.Validate("Packing Type", PackInLines."Packing Type");
                            SubPackingLines.Validate("Box Code / Packing Type", PackInLines."Box/Pallet ID");
                            PalletBoxMaster.Get(PackInLines."Box/Pallet ID");
                            //   SubPackingLines.Validate("Box Sr ID/Packing No.", NoSeries.GetNextNo(PalletBoxMaster."No Series", 0D, true));
                            SubPackingLines.Validate("Qty Packed", Totalqty);
                            SubPackingLines.Validate("Total Gross Ship Wt", (GrossWt + PalletBoxMaster."Weight of Pallet/BoX"));
                            SubPackingLines.Validate("Box Dimension", (format(PalletBoxMaster.L) + ' X ' + Format(PalletBoxMaster.W) + ' X ' + Format(PalletBoxMaster.H)));
                            SubPackingLines.Insert();
                            //  PackInLines.Modify();
                            PackInLines.Reset();
                            PackInLines.SetRange("Packing No.", Rec."Packing No.");
                            PackInLines.SetRange("Packing Type", PackInLines."Packing Type"::Box);
                            PackInLines.SetFilter("Box/Pallet ID", '=%1', PackingModuleSetUp."Combine Box Code");
                            if PackInLines.FindSet() then begin
                                repeat
                                    PackInLines.Validate("Qty Packed", PackInLines."Total Qty");
                                    PackInLines.Validate("Qty in this Box/Pallet", Totalqty);
                                    PackInLines.Validate("Box/Pallet Qty Packing Details", SubPackingLines."Box Sr ID/Packing No.");
                                    PackInLines.Validate("Remaining Qty", PackInLines."Total Qty" - PackInLines."Qty Packed");
                                    ReAdjustPacking.Reset();
                                    ReAdjustPacking.SetRange("Packing No", PackInLines."Packing No.");
                                    ReAdjustPacking.SetRange("Box/Pallet ID", SubPackingLines."Box Sr ID/Packing No.");
                                    ReAdjustPacking.SetRange("Line No.", PackInLines."Line No.");
                                    if not ReAdjustPacking.FindSet() then begin
                                        // ReAdjustPacking.DeleteAll();
                                        ReAdjustPacking.Init();
                                        ReAdjustPacking.Validate("Packing No", PackInLines."Packing No.");
                                        ReAdjustPacking.Validate("Line No.", PackInLines."Line No.");
                                        ReAdjustPacking.Validate("Box/Pallet ID", SubPackingLines."Box Sr ID/Packing No.");
                                        ReAdjustPacking.Validate("Packing Type", PackInLines."Packing Type");
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
                    SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
                    if SubPackingLines.FindSet() then begin
                        repeat // SubPackingLines."Insurance price" := 0;
                            ReAdjustPacking.Reset();
                            ReAdjustPacking.SetRange("Packing No", SubPackingLines."Packing No.");
                            ReAdjustPacking.SetRange("Packing Type", SubPackingLines."Packing Type");
                            ReAdjustPacking.SetRange("Box/Pallet ID", SubPackingLines."Box Sr ID/Packing No.");
                            if ReAdjustPacking.FindSet() then begin
                                repeat
                                    SubPackingLinesLast.Reset();
                                    SubPackingLinesLast.SetRange("Packing No.", ReAdjustPacking."Packing No");
                                    SubPackingLinesLast.SetRange("Packing Type", ReAdjustPacking."Packing Type");
                                    SubPackingLinesLast.SetRange("Box Sr ID/Packing No.", ReAdjustPacking."Box/Pallet ID");
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
                PalletBoxMaster: Record "Pallet/Box Master";
                NoSeries: Codeunit NoSeriesManagement;
                ReAdjustPacking: Record "ReAdjust Packing";
                PackInLines2: Record "Pack In Lines";
                Totalqty: Decimal;
                GrossWt: Decimal;
            begin
                if Rec."Pack All in 1 Box" = true then begin
                    ReAdjustPacking.Reset();
                    ReAdjustPacking.SetRange("Packing No", Rec."Packing No.");
                    ReAdjustPacking.SetRange(ReAdjustPacking."Packing Type", ReAdjustPacking."Packing Type"::Box);
                    if ReAdjustPacking.FindSet() then ReAdjustPacking.DeleteAll();
                    Clear(Totalqty);
                    Clear(GrossWt);
                    Rec.TestField("All in One Box Code");
                    SubPackingLinesLast.reset();
                    SubPackingLinesLast.SetRange("Packing No.", rec."Packing No.");
                    SubPackingLinesLast.SetRange("Packing Type", Rec."Packing Type");
                    if SubPackingLinesLast.FindLast() then SubPackingLinesLast.DeleteAll();
                    PackInLines.Reset();
                    PackInLines.SetRange("Packing No.", Rec."Packing No.");
                    PackInLines.SetRange("Packing Type", PackInLines."Packing Type"::Box);
                    if PackInLines.FindSet() then begin
                        PackInLines2.Reset();
                        PackInLines2.SetRange("Packing No.", Rec."Packing No.");
                        PackInLines2.SetRange("Packing Type", PackInLines2."Packing Type"::Box);
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
                        SubPackingLines.Validate("Packing Type", PackInLines."Packing Type"::Box);
                        SubPackingLines.Validate("Box Code / Packing Type", "All in One Box Code");
                        PalletBoxMaster.Get("All in One Box Code");
                        //  SubPackingLines.Validate("Box Sr ID/Packing No.", NoSeries.GetNextNo(PalletBoxMaster."No Series", 0D, true));
                        SubPackingLines.Validate("Qty Packed", Totalqty);
                        SubPackingLines.Validate("Total Gross Ship Wt", (GrossWt + PalletBoxMaster."Weight of Pallet/BoX"));
                        SubPackingLines.Validate("Box Dimension", (format(PalletBoxMaster.L) + ' X ' + Format(PalletBoxMaster.W) + ' X ' + Format(PalletBoxMaster.H)));
                        SubPackingLines.Insert();
                        //PackInLines.Modify();
                        PackInLines.Reset();
                        PackInLines.SetRange("Packing No.", Rec."Packing No.");
                        PackInLines.SetRange("Packing Type", PackInLines."Packing Type"::Box);
                        //  PackInLines.SetFilter("Box/Pallet ID", '=%1', 'Combine');
                        if PackInLines.FindSet() then begin
                            repeat
                                PackInLines.Validate("Qty Packed", PackInLines."Total Qty");
                                PackInLines.Validate("Qty in this Box/Pallet", PackInLines."Qty Packed");
                                PackInLines.Validate("Box/Pallet Qty Packing Details", SubPackingLines."Box Sr ID/Packing No.");
                                PackInLines.Validate("Remaining Qty", PackInLines."Total Qty" - PackInLines."Qty Packed");
                                ReAdjustPacking.Reset();
                                ReAdjustPacking.SetRange("Packing No", PackInLines."Packing No.");
                                ReAdjustPacking.SetRange("Box/Pallet ID", SubPackingLines."Box Sr ID/Packing No.");
                                ReAdjustPacking.SetRange("Line No.", PackInLines."Line No.");
                                if not ReAdjustPacking.FindSet() then begin
                                    //  ReAdjustPacking.DeleteAll();
                                    ReAdjustPacking.Init();
                                    ReAdjustPacking.Validate("Packing No", PackInLines."Packing No.");
                                    ReAdjustPacking.Validate("Line No.", PackInLines."Line No.");
                                    ReAdjustPacking.Validate("Box/Pallet ID", SubPackingLines."Box Sr ID/Packing No.");
                                    ReAdjustPacking.Validate("Packing Type", PackInLines."Packing Type");
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
                    SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
                    if SubPackingLines.FindSet() then begin
                        SubPackingLines."Insurance price" := 0;
                        repeat
                            ReAdjustPacking.Reset();
                            ReAdjustPacking.SetRange("Packing No", SubPackingLines."Packing No.");
                            ReAdjustPacking.SetRange("Packing Type", SubPackingLines."Packing Type");
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
        field(7; "Pack All in 1 Pallet"; Boolean)
        {
            Caption = 'Pack All in 1 Pallet';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                SubPackingLines: Record "Sub Packing Lines";
                SubPackingLinesLast: Record "Sub Packing Lines";
                PackInLines: Record "Pack In Lines";
                PackInLines2: Record "Pack In Lines";
                PalletBoxMaster: Record "Pallet/Box Master";
                NoSeries: Codeunit NoSeriesManagement;
                ReAdjustPacking: Record "ReAdjust Packing";
                Totalqty: Decimal;
                GrossWt: Decimal;
            begin
                if Rec."Pack All in 1 Pallet" = true then begin
                    ReAdjustPacking.Reset();
                    ReAdjustPacking.SetRange("Packing No", Rec."Packing No.");
                    ReAdjustPacking.SetRange("Packing Type", ReAdjustPacking."Packing Type"::Pallet);
                    if ReAdjustPacking.FindSet() then ReAdjustPacking.DeleteAll(); //SN-12-11-2021+
                    Clear(Totalqty);
                    Clear(GrossWt);
                    Rec.TestField("All in One Pallet Code");
                    SubPackingLinesLast.reset();
                    SubPackingLinesLast.SetRange("Packing No.", rec."Packing No.");
                    SubPackingLinesLast.SetRange("Packing Type", Rec."Packing Type");
                    if SubPackingLinesLast.FindLast() then SubPackingLinesLast.DeleteAll();
                    PackInLines.Reset();
                    PackInLines.SetRange("Packing No.", Rec."Packing No.");
                    PackInLines.SetRange("Packing Type", PackInLines."Packing Type"::Pallet);
                    if PackInLines.FindSet() then begin
                        PackInLines2.Reset();
                        PackInLines2.SetRange("Packing No.", Rec."Packing No.");
                        PackInLines2.SetRange("Packing Type", PackInLines2."Packing Type"::Pallet);
                        if PackInLines2.FindSet() then
                            repeat
                                Totalqty += PackInLines2."Total Qty";
                                GrossWt += PackInLines2."Gross Wt (Items)";
                            until PackInLines2.Next() = 0;
                        //        PackInLines.CalcSums("Total Qty", "Gross Wt (Items)");
                        SubPackingLinesLast.reset();
                        SubPackingLinesLast.SetRange("Packing No.", rec."Packing No.");
                        if SubPackingLinesLast.FindLast() then;
                        SubPackingLines.Init();
                        SubPackingLines.Validate("Packing No.", Rec."Packing No.");
                        SubPackingLines.Validate("Line No.", SubPackingLinesLast."Line No." + 10000);
                        SubPackingLines.Validate("Document Line No.", PackInLines."Line No.");
                        SubPackingLines.Validate("Packing Type", PackInLines."Packing Type"::Pallet);
                        SubPackingLines.Validate("Box Code / Packing Type", "All in One Pallet Code");
                        PalletBoxMaster.Get("All in One Pallet Code");
                        //  SubPackingLines.Validate("Box Sr ID/Packing No.", NoSeries.GetNextNo(PalletBoxMaster."No Series", 0D, true));
                        SubPackingLines.Validate("Qty Packed", Totalqty);
                        SubPackingLines.Validate("Total Gross Ship Wt", (GrossWt + PalletBoxMaster."Weight of Pallet/BoX"));
                        SubPackingLines.Validate("Box Dimension", (format(PalletBoxMaster.L) + ' X ' + Format(PalletBoxMaster.W) + ' X ' + Format(PalletBoxMaster.H)));
                        SubPackingLines.Insert();
                        //  PackInLines.Modify();
                        PackInLines.Reset();
                        PackInLines.SetRange("Packing No.", Rec."Packing No.");
                        PackInLines.SetRange("Packing Type", PackInLines."Packing Type"::Pallet);
                        //  PackInLines.SetFilter("Box/Pallet ID", '=%1', 'Combine');
                        if PackInLines.FindSet() then begin
                            repeat
                                PackInLines.Validate("Qty Packed", PackInLines."Total Qty");
                                PackInLines.Validate("Qty in this Box/Pallet", PackInLines."Qty Packed");
                                PackInLines.Validate("Box/Pallet Qty Packing Details", SubPackingLines."Box Sr ID/Packing No.");
                                PackInLines.Validate("Remaining Qty", PackInLines."Total Qty" - PackInLines."Qty Packed");
                                ReAdjustPacking.Reset();
                                ReAdjustPacking.SetRange("Packing No", PackInLines."Packing No.");
                                ReAdjustPacking.SetRange("Box/Pallet ID", SubPackingLines."Box Sr ID/Packing No.");
                                ReAdjustPacking.SetRange("Line No.", PackInLines."Line No.");
                                if not ReAdjustPacking.FindSet() then begin
                                    // ReAdjustPacking.DeleteAll();
                                    ReAdjustPacking.Init();
                                    ReAdjustPacking.Validate("Packing No", PackInLines."Packing No.");
                                    ReAdjustPacking.Validate("Line No.", PackInLines."Line No.");
                                    ReAdjustPacking.Validate("Box/Pallet ID", SubPackingLines."Box Sr ID/Packing No.");
                                    ReAdjustPacking.Validate("Packing Type", PackInLines."Packing Type");
                                    ReAdjustPacking.Validate("Item No.", PackInLines."Item No.");
                                    ReAdjustPacking.Validate("Item Description", PackInLines."Item Description");
                                    ReAdjustPacking.Validate("Sales UoM", PackInLines."Sales UoM");
                                    ReAdjustPacking.Validate("Total Qty", PackInLines."Total Qty");
                                    //   ReAdjustPacking.Validate("Qty Packed", ReAdjustPacking."Total Qty" - ReAdjustPacking."Qty to Remove");
                                    ReAdjustPacking.Validate(SourceLineNo, PackInLines.SourceLineNo);
                                    ReAdjustPacking.Validate("Qty to pack in this Box", PackInLines."Total Qty");
                                    ReAdjustPacking.Insert();
                                    PackInLines.Modify();
                                end;
                            until PackInLines.Next() = 0;
                            SubPackingLines.Reset();
                        end;
                    end;
                    SubPackingLines.Reset();
                    SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
                    SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
                    if SubPackingLines.FindSet() then begin
                        SubPackingLines."Insurance price" := 0;
                        repeat
                            ReAdjustPacking.Reset();
                            ReAdjustPacking.SetRange("Packing No", SubPackingLines."Packing No.");
                            ReAdjustPacking.SetRange("Packing Type", SubPackingLines."Packing Type");
                            if ReAdjustPacking.FindSet() then
                                repeat
                                    SubPackingLines."Insurance price" += ReAdjustPacking."Insurance Price";
                                until ReAdjustPacking.Next() = 0;
                        until SubPackingLines.Next() = 0;
                        SubPackingLines.Modify();
                    end;
                end;
                //  ClearAll();
            end;
        }
        field(8; "All in One Box Code"; Code[20])
        {
            Caption = 'All in One Box Code';
            DataClassification = ToBeClassified;
            TableRelation = "Pallet/Box Master" where(Type = const(Box));
        }
        field(9; "All in One Pallet Code"; Code[20])
        {
            Caption = 'All in One Pallet Code';
            DataClassification = ToBeClassified;
            TableRelation = "Pallet/Box Master" where(Type = const(Pallet));
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
                    PackinLines.SetRange("Packing Type", Rec."Packing Type");
                    if PackinLines.FindSet() then begin
                        repeat
                            PackinLines."Box/Pallet Qty Packing Details" := '';
                            PackinLines.Modify();
                        until PackinLines.Next() = 0;
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    PackinLines.SetRange("Packing Type", Rec."Packing Type");
                    PackinLines.SetFilter("Remaining Qty", '<>%1', 0);
                    if PackinLines.FindSet() then Error('Some of items still Unpacked,Please Pack all the items and try again!');
                    SubPackingLines.reset();
                    SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
                    SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
                    SubPackingLines.SetRange("Qty Packed", 0);
                    if SubPackingLines.FindSet() then begin
                        SubPackingLines.DeleteAll();
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    PackinLines.SetRange("Packing Type", Rec."Packing Type");
                    if PackinLines.FindSet() then begin
                        PackinLines.ModifyAll("Box/Pallet Qty Packing Details", '');
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    PackinLines.SetRange("Packing Type", Rec."Packing Type");
                    if PackinLines.FindSet() then begin
                        repeat
                            Readjust.Reset();
                            Readjust.SetRange("Packing No", PackinLines."Packing No.");
                            Readjust.SetRange("Packing Type", PackinLines."Packing Type");
                            Readjust.SetRange("Line No.", PackinLines."Line No.");
                            if Readjust.FindSet() then begin
                                repeat
                                    qty := Format(Readjust."Qty to pack in this Box");
                                    if PackinLines."Box/Pallet Qty Packing Details" <> '' then PackinLines."Box/Pallet Qty Packing Details" += ' | ' + Readjust."Box/Pallet ID" + ' - ' + qty;
                                    if PackinLines."Box/Pallet Qty Packing Details" = '' then PackinLines."Box/Pallet Qty Packing Details" += Readjust."Box/Pallet ID" + ' - ' + qty;
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
        field(11; "Close All Pallets"; Boolean)
        {
            Caption = 'Close All Pallets';
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
                if Rec."Close All Pallets" = true then begin
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    PackinLines.SetRange("Packing Type", Rec."Packing Type");
                    if PackinLines.FindSet() then begin
                        repeat
                            PackinLines."Box/Pallet Qty Packing Details" := '';
                            PackinLines.Modify();
                        until PackinLines.Next() = 0;
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    PackinLines.SetRange("Packing Type", Rec."Packing Type");
                    PackinLines.SetFilter("Remaining Qty", '<>%1', 0);
                    if PackinLines.FindSet() then Error('Some of items still unpacked,Please pack all the items and try again!');
                    SubPackingLines.reset();
                    SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
                    SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
                    SubPackingLines.SetRange("Qty Packed", 0);
                    if SubPackingLines.FindSet() then begin
                        SubPackingLines.DeleteAll();
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    PackinLines.SetRange("Packing Type", Rec."Packing Type");
                    if PackinLines.FindSet() then begin
                        PackinLines.ModifyAll("Box/Pallet Qty Packing Details", '');
                    end;
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No.");
                    PackinLines.SetRange("Packing Type", Rec."Packing Type");
                    if PackinLines.FindSet() then begin
                        repeat
                            Readjust.Reset();
                            Readjust.SetRange("Packing No", PackinLines."Packing No.");
                            Readjust.SetRange("Packing Type", PackinLines."Packing Type");
                            Readjust.SetRange("Line No.", PackinLines."Line No.");
                            if Readjust.FindSet() then begin
                                repeat
                                    qty := Format(Readjust."Qty to pack in this Box");
                                    if PackinLines."Box/Pallet Qty Packing Details" <> '' then PackinLines."Box/Pallet Qty Packing Details" += ' | ' + Readjust."Box/Pallet ID" + ' - ' + qty;
                                    if PackinLines."Box/Pallet Qty Packing Details" = '' then PackinLines."Box/Pallet Qty Packing Details" += Readjust."Box/Pallet ID" + ' - ' + qty;
                                    PackinLines.Modify();
                                until Readjust.Next() = 0;
                            end;
                        until PackinLines.Next() = 0;
                    end;
                    SubPackingLines.Reset();
                    SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
                    SubPackingLines.SetRange("Packing Type", Rec."Packing Type"::Pallet);
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
        key(PK; "Packing No.", "Packing Type")
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
        RLRateQuote: Record "RL Rate Quote";
        Readjust: Record "ReAdjust Packing";
    begin
        SubPackingLines.Reset();
        SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
        SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
        if SubPackingLines.FindSet() then SubPackingLines.DeleteAll();
        PackinLines.Reset();
        PackinLines.SetRange("Packing No.", Rec."Packing No.");
        PackinLines.SetRange("Packing Type", Rec."Packing Type");
        if PackinLines.FindSet() then PackinLines.DeleteAll();
        PackingAdjustment.Reset();
        PackingAdjustment.SetRange("Packing No", Rec."Packing No.");
        PackingAdjustment.SetRange("Packing Type", Rec."Packing Type");
        if PackingAdjustment.FindSet() then PackingAdjustment.DeleteAll();
        Readjust.Reset();
        Readjust.SetRange("Packing No", Rec."Packing No.");
        Readjust.SetRange("Packing Type", Rec."Packing Type");
        if Readjust.FindSet() then Readjust.DeleteAll();
    end;



    var
        SiEventMgnt: Codeunit "SI Event Mgnt";
}
