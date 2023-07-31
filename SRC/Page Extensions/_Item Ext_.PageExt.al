pageextension 55000 "Item Ext" extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            field("Box Code of Item"; Rec."SI Box Code of Item")
            {
                Caption = 'SI_Box/Pallet Code of Item';
                ApplicationArea = ALL;
            }
        }
    }
}
