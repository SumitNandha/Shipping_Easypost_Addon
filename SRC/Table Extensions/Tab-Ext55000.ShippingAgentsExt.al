tableextension 55000 "Shipping Agents Ext" extends "Shipping Agent"
{
    fields
    {
        field(75000;"Minimum Weight Threshold";Decimal)
        {
            Caption = 'Minimum Weight Threshold';
            DataClassification = ToBeClassified;
        }
        field(75001;"SI Get Rate Carrier";text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(75002;"EasyPost CA Account";Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(75003;"Include EasyPost Rates";Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(75004;"Packing Type";Enum "Pallet/Box Enum")
        {
            DataClassification = ToBeClassified;
        }
        field(75005;"Make Carrier Base Price ZERO";Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}
