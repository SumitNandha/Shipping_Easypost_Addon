tableextension 55001 "Packing_Item Ext" extends Item
{
    fields
    {
        field(75000;"SI Box Code of Item";Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Box/Pallet Code';
            TableRelation = "Pallet/Box Master";
        }
    }
}
