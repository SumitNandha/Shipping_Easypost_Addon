// page 75013 "ShipFreightQuoteMessageBuffer"
// {
//     Caption = 'Ship Freight Quote Message Buffer';
//     SourceTable = ShipFreightQuoteMessageBuffer;
//     PageType = ListPart;
//     Editable = false;

//     layout
//     {
//         area(Content)
//         {
//             repeater(General)
//             {
//                 field(Carrier;rEC.Carrier)
//                 {
//                     ApplicationArea = all;
//                 }
//                 field("Type";Rec."Type")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(Message;Rec.Message)
//                 {
//                     ApplicationArea = All;
//                 }
//             }
//         }
//     }
// }
