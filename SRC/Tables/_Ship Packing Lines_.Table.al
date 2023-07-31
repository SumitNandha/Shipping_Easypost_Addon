table 55004 "Ship Packing Lines"
{
    Caption = 'Ship Packing Lines';
    DataClassification = ToBeClassified;

    fields
    {
        field(11; "No."; code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
        }
        field(12; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Item.Get(Rec."Item No.") then begin
                    Rec.Validate("Box Code for Item", Item."SI Box Code of Item");
                    Rec.Validate("Gross Ship Wt", Item."Gross Weight");
                end;
            end;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(3; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = ToBeClassified;
        }
        field(4; Quantity; Integer)
        {
            Caption = 'Quantity (Packs)';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Rec.validate("Total Item Weight", (Rec.Quantity * Rec."Gross Ship Wt"));
            end;
        }
        field(5; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = ToBeClassified;
        }
        field(6; "Packed Qty"; Integer)
        {
            Caption = 'Packed Qty';
            DataClassification = ToBeClassified;
        }
        field(7; "Packing No."; Code[20])
        {
            Caption = 'Packing No.';
            DataClassification = ToBeClassified;
        }
        field(8; "Quantity to Move"; Integer)
        {
            Caption = 'Quantity to Move';
            DataClassification = ToBeClassified;
        }
        field(9; "New Packing No."; Code[20])
        {
            Caption = 'New Packing No.';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                "Pallet/Box master": Record "Pallet/Box Master";
                PackingList: Record "Packing List";
                PackingListLast: Record "Packing List";
                NoSeries: Codeunit NoSeriesManagement;
            begin
                if Rec."New Packing No." = 'NEW' then begin
                    "Pallet/Box master".Get(rec."Packing type");
                    PackingListLast.Reset();
                    if PackingListLast.FindLast() then begin
                        PackingList.Init();
                        PackingList.Validate(EntryNo, PackingListLast.EntryNo + 1);
                        PackingList.Validate("Packing No", Rec."No.");
                        PackingList.Validate("No.", NoSeries.GetNextNo("Pallet/Box master"."No Series", 0D, true));
                        PackingList.Insert();
                        Rec.Validate("New Packing No.", PackingList."No.");
                    end;
                    // Rec.Validate("Packed Qty", "Quantity to Move");
                    // Rec.Validate("Quantity to Move", 0);
                    // Rec.Validate(Quantity, Rec.Quantity - Rec."Packed Qty");
                end;
            end;
        }
        field(10; "Sales Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = ToBeClassified;
        }
        field(13; "Packing type"; code[20])
        {
            Caption = 'Packing type';
            DataClassification = ToBeClassified;
            TableRelation = "Pallet/Box Master";
        }
        field(14; "QtyPacked"; Boolean)
        {
            Caption = 'Qty Packed';
            DataClassification = ToBeClassified;
        }
        field(15; "Total Qty"; Decimal)
        {
            Caption = 'Total Qty';
            DataClassification = ToBeClassified;
        }
        field(16; "Public URL"; Text[300])
        {
            Caption = 'Tracking URL';
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(17; "Tracking ID"; Code[50])
        {
            Caption = 'Tracking ID';
            DataClassification = ToBeClassified;
        }
        field(18; "Label URL"; Text[300])
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
        field(19; "Remaining Qty"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Remaining Qty';
        }
        field(20; "SalesLine No."; integer)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Label Image"; Media)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Sales UOM"; Code[10])
        {
            TableRelation = "Unit of Measure".Code;
        }
        field(23; "Gross Ship Wt"; Decimal)
        {
            Caption = 'Gross Weight per Item';
            DataClassification = ToBeClassified;
        }
        field(24; "Box Dimension"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Box/Pallet Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Total Item Weight"; Decimal)
        {
            Caption = 'Gross Weight (All Items)';
            DataClassification = ToBeClassified;
        }
        field(27; "Box Code for Item"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                PalletBoxMaster: Record "Pallet/Box Master";
            begin
                if PalletBoxMaster.Get(Rec."Box Code for Item") then begin
                    Rec.Validate("Box/Pallet Weight", PalletBoxMaster."Weight of Pallet/BoX");
                    Rec.Validate("Box L", PalletBoxMaster.L);
                    Rec.Validate("Box W", PalletBoxMaster.W);
                    Rec.Validate("Box H", PalletBoxMaster.H);
                end;
            end;
        }
        field(28; "Box L"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Box H"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Box W"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Bin Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(32; "SourceLineNo"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "No.", "Line No.")
        {
            Clustered = true;
        }
    }
    // trigger OnInsert()
    // var
    //     ShipPackage: Record "Ship Packing Lines";
    // begin
    //     ShipPackage.Reset();
    //     ShipPackage.SetRange("No.", Rec."No.");
    //     ShipPackage.SetRange("Line No.", Rec."Line No.");
    //     if ShipPackage.FindLast() then
    //         Rec."Line No." := ShipPackage."Line No." + 1
    //     else
    //         Rec."Line No." := 0;
    // end;
}
