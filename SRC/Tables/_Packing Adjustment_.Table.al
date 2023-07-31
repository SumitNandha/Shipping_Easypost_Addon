table 55013 "Packing Adjustment"
{
    fields
    {
        field(1;"Packing No";Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2;"Box/Pallet ID";code[20])
        {
            DataClassification = ToBeClassified;
        // trigger OnValidate()
        // var
        //     PalletBoxMaster: Record "Pallet/Box Master";
        //     SubPackingLines: Record "Sub Packing Lines";
        // begin
        //     SubPackingLines.Reset();
        //     SubPackingLines.SetRange("Packing No.", Rec."Packing No");
        //     SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
        //     SubPackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box/Pallet ID");
        //     if SubPackingLines.FindFirst() then begin
        //         PalletBoxMaster.Get(SubPackingLines."Box Code / Packing Type");
        //         Rec.Validate("Box / Pallet Wt", PalletBoxMaster."Weight of Pallet/BoX");
        //     end;
        // end;
        }
        field(3;"Packing Type";Enum "Pallet/Box Enum")
        {
            DataClassification = ToBeClassified;
        }
        field(4;"Qty Packed in this Box/Pallet";Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5;"Total Gross Ship Wt";Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()var SubPackingLines: Record "Sub Packing Lines";
            begin
                SubPackingLines.Reset();
                SubPackingLines.SetRange("Packing No.", Rec."Packing No");
                SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
                SubPackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box/Pallet ID");
                if SubPackingLines.FindFirst()then begin
                    SubPackingLines."Total Gross Ship Wt":=Rec."Total Gross Ship Wt";
                    SubPackingLines.Modify();
                end;
            end;
        }
        field(6;"Box Dimension";Text[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()var SubPackingLines: Record "Sub Packing Lines";
            begin
                SubPackingLines.Reset();
                SubPackingLines.SetRange("Packing No.", Rec."Packing No");
                SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
                SubPackingLines.SetRange("Box Sr ID/Packing No.", Rec."Box/Pallet ID");
                if SubPackingLines.FindFirst()then begin
                    SubPackingLines."Box Dimension":=Rec."Box Dimension";
                    SubPackingLines.Modify();
                end;
            end;
        }
        field(7;"Box / Pallet Wt";Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8;"Total Item Wt";Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10;"Additional Wt";Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()begin
                Rec.Validate("Total Gross Ship Wt", Rec."Total Gross Ship Wt" - xRec."Additional Wt" + Rec."Additional Wt");
            end;
        }
        field(11;L;Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()begin
                Rec."Box Dimension":='';
                Rec.validate("Box Dimension", format(Rec.L) + ' x ' + format(Rec.H) + ' x ' + format(Rec.W));
            end;
        }
        field(12;H;Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()begin
                Rec."Box Dimension":='';
                Rec.validate("Box Dimension", format(Rec.L) + ' x ' + format(Rec.H) + ' x ' + format(Rec.W));
            end;
        }
        field(13;W;Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()begin
                Rec."Box Dimension":='';
                Rec.validate("Box Dimension", format(Rec.L) + ' x ' + format(Rec.H) + ' x ' + format(Rec.W));
            end;
        }
        field(14;"Insurance Price";Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(pk;"Packing No", "Box/Pallet ID")
        {
            Clustered = true;
        }
    }
}
