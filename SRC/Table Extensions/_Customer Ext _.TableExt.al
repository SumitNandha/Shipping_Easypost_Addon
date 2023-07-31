tableextension 55005 "Customer Ext " extends Customer
{
    fields
    {
        field(75005; "Shipping Rate for Customer"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(75006; "Tracking Email Id"; Text[400])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                EmailMngmt: Codeunit "mail Management";
            begin
                if Rec."Tracking Email Id" <> '' then
                    EmailMngmt.CheckValidEmailAddresses("Tracking Email Id");
            end;
        }
        // modify("E-Mail")
        // {
        //     Width = 150;
        // }
    }
}
