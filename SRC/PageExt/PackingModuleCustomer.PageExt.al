pageextension 55001 PackingModuleCustomer extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Total Shipping Rate for Customer"; Rec."Shipping Rate for Customer")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("Tracking Email Id"; rec."Tracking Email Id")
            {
                ApplicationArea = ALL;
                Visible = true;
                MultiLine = true;
            }
        }
    }
}
