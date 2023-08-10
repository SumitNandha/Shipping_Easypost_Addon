tableextension 55002 "Posted Inv. Pick Header Ext" extends "Sales Shipment Header"
{
    fields
    {
        field(75000; "SI Inv. Pick No."; Code[20])
        {
            Caption = 'SI Inv. Pick No.';
            DataClassification = ToBeClassified;
        }
        field(75001; "Send Tracking Email"; Boolean)
        {
            Caption = 'Send Tracking Email';
            DataClassification = ToBeClassified;
        }
        field(75002; "Ship package tracking No"; Text[30])
        {
            Caption = 'Ship package tracking No';
            DataClassification = ToBeClassified;
        }
    }
}
