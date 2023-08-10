table 55003 "Shipping MarkUp Setup"
{
    Caption = 'Shipping MarkUp Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = ToBeClassified;
            TableRelation = Customer."No.";

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get("Customer No.") then "Customer Name" := Customer.Name;
            end;
        }
        field(2; "MarkUp per Box"; Decimal)
        {
            Caption = 'MarkUp per Box';
            DataClassification = ToBeClassified;
        }
        field(5; "Shipping Rate Discount  %"; Decimal)
        {
            Caption = 'Shipping Rate Discount  %';
            DataClassification = ToBeClassified;
        }
        field(6; "Acc No UPS"; Text[100])
        {
            Caption = 'Acc No UPS';
            DataClassification = ToBeClassified;
        }
        field(7; "Acc No FEDX"; Text[100])
        {
            Caption = 'Acc No FEDX';
            DataClassification = ToBeClassified;
        }
        field(8; "Add Shipping Cost to Invoice"; Boolean)
        {
            Caption = 'Add Shipping Cost to Invoice';
            DataClassification = ToBeClassified;
        }
        field(10; "Box Shipping Insurance?"; Enum "Box Shipping Insurance")
        {
            Caption = 'Box Shipping Insurance?';
            DataClassification = ToBeClassified;
        }
        field(11; "Box Shipping Insurace %"; Decimal)
        {
            Caption = 'Box Shipping Insurace %';
            DataClassification = ToBeClassified;
        }
        field(12; "Freight Shipping Insurance?"; Enum "Freight Shipping Insurance")
        {
            Caption = 'Freight Shipping Insurance?';
            DataClassification = ToBeClassified;
        }
        field(13; "Freight Shipping Insurace %"; Decimal)
        {
            Caption = 'Freight Shipping Insurace %';
            DataClassification = ToBeClassified;
        }
        field(14; "Customer Shipping Carrier"; Code[20])
        {
            Caption = 'Customer Shipping Carrier';
            DataClassification = ToBeClassified;
        }
        field(15; "Customer Shipping Carrier Acc."; Code[50])
        {
            Caption = 'Customer Shipping Carrier Account';
            DataClassification = ToBeClassified;
        }
        field(16; "Customer Shipping Carrier Zip"; Code[20])
        {
            Caption = 'Customer Shipping Carrier Zip';
            DataClassification = ToBeClassified;
        }
        field(17; "All Customer"; Boolean)
        {
            Caption = 'All Customer';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(18; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(19; "Customer Ship. Carrier Country"; Code[10])
        {
            Caption = 'Customer Ship. Carrier Country';
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region".Code;
        }
    }
    keys
    {
        key(PK; "Customer No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        MarkupSetup: Record "Shipping MarkUp Setup";
    begin
        MarkupSetup.Reset();
        if Not MarkupSetup.Get('') then begin
            MarkupSetup.Init();
            MarkupSetup."Customer No." := '';
            MarkupSetup."All Customer" := true;
            MarkupSetup.Insert();
        end;
    end;

    trigger OnModify()
    var
        MarkupSetup: Record "Shipping MarkUp Setup";
    begin
        if rec."All Customer" then Rec.TestField("Customer No.", '');
        MarkupSetup.Reset();
        if Not MarkupSetup.Get('') then begin
            MarkupSetup.Init();
            MarkupSetup."Customer No." := '';
            MarkupSetup."All Customer" := true;
            MarkupSetup.Insert();
        end;
    end;

    trigger OnDelete()
    var
        MarkupSetup: Record "Shipping MarkUp Setup";
    begin
        Rec.TestField("All Customer");
        MarkupSetup.Reset();
        if Not MarkupSetup.Get('') then begin
            MarkupSetup.Init();
            MarkupSetup."Customer No." := '';
            MarkupSetup."All Customer" := true;
            MarkupSetup.Insert();
        end;
    end;
}
