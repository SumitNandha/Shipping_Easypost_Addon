table 55014 "ReAdjust Packing"
{
    Caption = 'ReAdjust Packing';
    DataClassification = ToBeClassified;

    fields
    {
        field(1;"Packing No";Code[20])
        {
            Caption = 'Packing No';
            DataClassification = ToBeClassified;
        }
        field(2;"Box/Pallet ID";Code[20])
        {
            Caption = 'Packing ID';
            DataClassification = ToBeClassified;
        }
        field(3;"Line No.";Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(4;"Packing Type";Enum "Pallet/Box Enum")
        {
            Caption = 'Packing Type';
            DataClassification = ToBeClassified;
        }
        field(5;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;
        }
        field(6;"Item Description";Text[100])
        {
            Caption = 'Item Description';
            DataClassification = ToBeClassified;
        }
        field(7;"Sales UoM";Code[10])
        {
            Caption = 'Sales UoM';
            DataClassification = ToBeClassified;
        }
        field(8;"Total Qty";Decimal)
        {
            Caption = 'Total Qty';
            DataClassification = ToBeClassified;
        }
        field(10;"Qty to Remove";Decimal)
        {
            Caption = 'Qty to Remove';
            DataClassification = ToBeClassified;

            trigger OnValidate()var PackinLines: Record "Pack In Lines";
            PackingAdjustment: Record "Packing Adjustment";
            Item: Record Item;
            SubPackingLines: Record "Sub Packing Lines";
            SubPackingLinesPage: Page "Sub Packing Lines";
            Readjust: Record "ReAdjust Packing";
            begin
                if "Qty to Remove" <> 0 then begin
                    Rec.Validate("Qty to pack in this Box", xRec."Qty to pack in this Box" - Rec."Qty to Remove");
                    // Rec.Validate("Qty Packed", Rec."Qty Packed" - Rec."Qty to Remove");
                    Rec.Modify();
                    PackinLines.Reset();
                    PackinLines.SetRange("Packing No.", Rec."Packing No");
                    PackinLines.SetRange("Line No.", Rec."Line No.");
                    PackinLines.SetRange("Packing Type", Rec."Packing Type");
                    IF PackinLines.FindFirst()then begin
                        PackinLines.Validate("Remaining Qty", PackinLines."Remaining Qty" + Rec."Qty to Remove");
                        PackinLines.Validate("Qty in this Box/Pallet", Rec."Qty to pack in this Box");
                        PackinLines.Validate("Qty Packed", PackinLines."Qty Packed" - PackinLines."Remaining Qty");
                        PackinLines.Modify();
                    end;
                    PackingAdjustment.Reset();
                    PackingAdjustment.SetRange("Packing No", Rec."Packing No");
                    PackingAdjustment.SetRange("Box/Pallet ID", Rec."Box/Pallet ID");
                    if PackingAdjustment.FindFirst()then begin
                        PackingAdjustment.Validate("Qty Packed in this Box/Pallet", PackingAdjustment."Qty Packed in this Box/Pallet" - Rec."Qty to Remove");
                        Item.get(Rec."Item No.");
                        PackingAdjustment.Validate("Total Item Wt", PackingAdjustment."Total Item Wt" - (Rec."Qty to Remove" * Item."Gross Weight"));
                        PackingAdjustment.Validate("Total Gross Ship Wt", PackingAdjustment."Additional Wt" + PackingAdjustment."Total Item Wt" + PackingAdjustment."Box / Pallet Wt");
                        PackingAdjustment.Modify();
                    end;
                    SubPackingLines.Reset();
                    SubPackingLines.SetRange("Packing No.", Rec."Packing No");
                    SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
                    SubPackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box/Pallet ID");
                    if SubPackingLines.FindFirst()then begin
                        // SubPackingLines.Validate("Qty Packed", PackingAdjustment."Qty Packed in this Box/Pallet");
                        // Item.Get(Rec."Item No.");
                        // SubPackingLines.Validate("Total Gross Ship Wt", SubPackingLines."Total Gross Ship Wt" - (rec."Qty to Remove" * item."Gross Weight"));
                        Readjust.Reset();
                        Readjust.SetRange("Packing No", Rec."Packing No");
                        Readjust.SetRange("Box/Pallet ID", Rec."Box/Pallet ID");
                        if Readjust.FindSet()then begin
                            SubPackingLines."Insurance price":=0;
                            SubPackingLines."Qty Packed":=0;
                            repeat SubPackingLines."Insurance price"+=Readjust."Insurance Price";
                                SubPackingLines."Qty Packed"+=Readjust."Qty to pack in this Box";
                            until Readjust.Next() = 0;
                            SubPackingLinesPage.Activate(true);
                            SubPackingLines.Modify();
                        end;
                    end;
                    Rec.Validate("Qty to Remove", 0);
                    Rec.Modify();
                    if Rec."Qty to pack in this Box" = 0 then Rec.Delete();
                end;
            end;
        }
        field(11;"Qty to pack in this Box";Decimal)
        {
            Caption = 'Qty to pack in this Box';
            DataClassification = ToBeClassified;

            trigger OnValidate()var SalesLines: Record "Sales Line";
            ShipPackageHeader: Record "Ship Package Header";
            InventoryPickLines: Record "Warehouse Activity Line";
            // SubPackingLines: Record "Sub Packing Lines";
            begin
                ShipPackageHeader.Get(Rec."Packing No");
                if ShipPackageHeader."Inventory Pick" <> '' then begin
                    SalesLines.Reset();
                    SalesLines.SetRange("Document No.", ShipPackageHeader."Document No.");
                    SalesLines.SetRange("Line No.", Rec.SourceLineNo);
                    if SalesLines.FindFirst()then begin
                        Rec.Validate("Insurance Price", Rec."Qty to pack in this Box" * SalesLines."Unit price");
                    //  Rec.Modify();
                    end;
                end
                else
                begin
                    SalesLines.Reset();
                    SalesLines.SetRange("Document No.", ShipPackageHeader."Document No.");
                    SalesLines.SetRange("Line No.", Rec."Line No.");
                    if SalesLines.FindFirst()then begin
                        Rec.Validate("Insurance Price", Rec."Qty to pack in this Box" * SalesLines."Unit price");
                    //  Rec.Modify();
                    end;
                end;
            end;
        }
        field(12;"Insurance Price";Decimal)
        {
            DataClassification = ToBeClassified;
        // trigger OnValidate()
        // var
        //     Readjust: Record "ReAdjust Packing";
        //     SubPackingLines: Record "Sub Packing Lines";
        // begin
        //     SubPackingLines.Reset();
        //     SubPackingLines.SetRange("Packing No.", Rec."Packing No");
        //     SubPackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box/Pallet ID");
        //     if SubPackingLines.FindFirst() then begin
        //         Readjust.Reset();
        //         Readjust.SetRange("Packing No", Rec."Packing No");
        //         Readjust.SetRange("Box/Pallet ID", Rec."Box/Pallet ID");
        //         if Readjust.FindSet() then
        //             SubPackingLines."Insurance price" := 0;
        //         repeat
        //             SubPackingLines."Insurance price" += Rec."Insurance Price";
        //         until Readjust.Next() = 0;
        //         SubPackingLines.Modify();
        //     end;
        // end;
        }
        field(13;"SourceLineNo";Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK;"Packing No", "Box/Pallet ID", "Line No.")
        {
            Clustered = true;
        }
    }
}
