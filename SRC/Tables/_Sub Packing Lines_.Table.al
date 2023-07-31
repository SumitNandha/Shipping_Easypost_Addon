table 55012 "Sub Packing Lines"
{
    Caption = 'Sub Packing Lines';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Packing No."; Code[20])
        {
            Caption = 'Packing No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        // field(4; "Cls. Box"; Boolean)
        // {
        //     Caption = 'Cls. Box';
        //     DataClassification = ToBeClassified;
        // }
        field(5; "Box Sr ID/Packing No."; Code[20])
        {
            Caption = 'Box Sr ID/Packing No.';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                PackingAdjustment: Record "Packing Adjustment";
                palletBoxMaster: Record "Pallet/Box Master";
            begin
                PackingAdjustment.Reset();
                PackingAdjustment.SetRange("Box/Pallet ID", Rec."Box Sr ID/Packing No.");
                if not PackingAdjustment.FindFirst() then begin
                    // Rec.CalcSums("Qty Packed", "Total Gross Ship Wt");
                    PackingAdjustment.Init();
                    PackingAdjustment.Validate("Packing No", Rec."Packing No.");
                    PackingAdjustment.Validate("Packing Type", Rec."Packing Type");
                    PackingAdjustment.Validate("Box/Pallet ID", Rec."Box Sr ID/Packing No.");
                    //// PackingAdjustment.Validate("Qty Packed in this Box/Pallet", Rec."Qty Packed");
                    //        PackingAdjustment.Validate("Total Gross Ship Wt", Rec."Total Gross Ship Wt");
                    palletBoxMaster.Get(Rec."Box Code / Packing Type");
                    PackingAdjustment.Validate(L, palletBoxMaster.L);
                    PackingAdjustment.Validate(H, palletBoxMaster.H);
                    PackingAdjustment.Validate(W, palletBoxMaster.W);
                    //   PackingAdjustment.Validate("Box Dimension", (format(PalletBoxMaster.L) + ' X ' + Format(PalletBoxMaster.W) + ' X ' + Format(PalletBoxMaster.H)));
                    PackingAdjustment.Insert();
                    Rec.Validate("Box Dimension", PackingAdjustment."Box Dimension");
                    //Rec.Modify();
                end;
            end;
        }
        field(6; "Box Code / Packing Type"; Code[20])
        {
            TableRelation = "Pallet/Box Master" where(Type = field("Packing Type"));
            Caption = 'Box Code / Packing Type';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                NoSeries: Codeunit NoSeriesManagement;
                palletboxmaster: Record "Pallet/Box Master";
                PackingNo: Text;
                packingtype: Code[20];
                SubPackingLines: Record "Sub Packing Lines";
                PackingAdjustment: Record "Packing Adjustment";
            begin
                if "Packing No." = '' then Rec.Validate("Packing No.", Rec.GetFilter("Packing No."));
                IF Rec."Box Sr ID/Packing No." = '' then begin
                    if palletboxmaster.Get(Rec."Box Code / Packing Type") then begin
                        //  Rec.Validate("Packing Type",Rec.GetFilter("Packing Type"));
                        Rec.Validate("Box Sr ID/Packing No.", NoSeries.GetNextNo(palletboxmaster."No Series", 0D, true));
                        Rec.Validate("Total Gross Ship Wt", palletboxmaster."Weight of Pallet/BoX");
                        SubPackingLines.Reset();
                        SubPackingLines.SetRange("Packing No.", Rec."Packing No.");
                        SubPackingLines.SetRange("Packing Type", Rec."Packing Type");
                        if SubPackingLines.FindLast() then;
                        if Rec."Line No." = 0 then Rec.Validate("Line No.", SubPackingLines."Line No." + 10000);
                        // PackingAdjustment.reset();
                        // PackingAdjustment.SetRange("Packing No", Rec."Packing No.");
                        // PackingAdjustment.SetRange("Box/Pallet ID", Rec."Box Sr ID/Packing No.");
                        // if PackingAdjustment.FindFirst() then begin
                        //     PackingAdjustment.Validate("Total Gross Ship Wt", SubPackingLines."Total Gross Ship Wt");
                        // end;
                    end
                    else
                        Message('Pallet Not Get');
                end;
            end;
        }
        field(7; "Qty Packed"; Decimal)
        {
            Caption = 'Qty Packed';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                PackingAdjustment: Record "Packing Adjustment";
            begin
                PackingAdjustment.Reset();
                PackingAdjustment.SetRange("Packing No", Rec."Packing No.");
                PackingAdjustment.SetRange("Box/Pallet ID", Rec."Box Sr ID/Packing No.");
                if PackingAdjustment.FindFirst() then begin
                    PackingAdjustment.Validate("Qty Packed in this Box/Pallet", Rec."Qty Packed");
                    PackingAdjustment.Modify();
                end;
            end;
        }
        field(8; "Total Gross Ship Wt"; Decimal)
        {
            Caption = 'Total Gross Ship Wt';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                PackingAdjustment: Record "Packing Adjustment";
            begin
                PackingAdjustment.Reset();
                PackingAdjustment.SetRange("Packing No", Rec."Packing No.");
                PackingAdjustment.SetRange("Box/Pallet ID", Rec."Box Sr ID/Packing No.");
                if PackingAdjustment.FindFirst() then begin
                    PackingAdjustment.Validate("Total Gross Ship Wt", Rec."Total Gross Ship Wt");
                    PackingAdjustment.Modify();
                end;
            end;
        }
        field(9; "Box Dimension"; Text[100])
        {
            Caption = 'Pallet Dimension';
            DataClassification = ToBeClassified;
        }
        field(10; "Tracking ID"; Text[200])
        {
            Caption = 'Tracking ID';
            DataClassification = ToBeClassified;
        }
        field(11; "Tracking URL"; Text[200])
        {
            Caption = 'Tracking URL';
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(12; "Label URL"; Text[200])
        {
            Caption = 'Label URL';
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;

            trigger OnValidate()
            var
                client: HttpClient;
                response: HttpResponseMessage;
                Instr: InStream;
                tempblob: Codeunit "Temp Blob";
                outstr: OutStream;
            begin
                Clearall();
                client.Get("Label URL", response);
                Response.Content.ReadAs(Instr);
                Rec."Label Image".ImportStream(Instr, 'Lable');
                //Message('%1', Rec."Label Image".Length);
                Rec.Modify();
                // "Label Image".CreateInStream(Instr);
            end;
        }
        field(13; "Label Image"; Media)
        {
            Caption = 'Label Image';
            DataClassification = ToBeClassified;
        }
        field(14; "Document Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Insurance price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Box Number"; Integer)
        {

        }
        field(17; Barcode; Media)
        {

        }
        field(18; "Label Print count"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Box Scan History" where("Box ID" = field("Box Sr ID/Packing No.")));
        }
        field(19; "Employee Name"; text[100])
        {

        }
    }
    keys
    {
        key(PK; "Packing No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
