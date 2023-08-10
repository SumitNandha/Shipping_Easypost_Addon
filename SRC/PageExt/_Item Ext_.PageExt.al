pageextension 55006 "Item Ext" extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            field("Box Code of Item"; Rec."SI Box Code of Item")
            {
                Caption = 'Box Code of Item';
                ApplicationArea = ALL;
            }
        }
    }
}
