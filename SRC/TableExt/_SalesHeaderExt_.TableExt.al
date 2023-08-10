tableextension 55004 "SalesHeaderExt" extends "Sales Header"
{
    fields
    {
        field(75005; "SI Total Shipping Rate"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                ShipPackageHeader: Record "Ship Package Header";
            begin
                ShipPackageHeader.Reset();
                ShipPackageHeader.SetRange("Document No.", Rec."No.");
                if ShipPackageHeader.FindSet() then begin
                    repeat
                        ShipPackageHeader.Validate("Existing Shipping Rate on SO/SQ", Rec."SI Total Shipping Rate");
                        ShipPackageHeader.Modify();
                    until ShipPackageHeader.Next() = 0;
                end;
            end;
        }
    }
}
