page 55023 "Other Option Card"
{
    Caption = 'Shipping Options';
    PageType = Card;
    SourceTable = "Ship Package Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                // field("Airpor tDelivery"; Rec."Airpor tDelivery")
                // {
                //     ToolTip = 'Specifies the value of the Airport Delivery field.';
                //     ApplicationArea = All;
                // }
                // field("Airport Pickup"; Rec."Airport Pickup")
                // {
                //     ToolTip = 'Specifies the value of the Airport Pickup field.';
                //     ApplicationArea = All;
                // }
                // field(COD; Rec.COD)
                // {
                //     ToolTip = 'Specifies the value of the COD field.';
                //     ApplicationArea = All;
                // }
                // field("Cubic Feet"; Rec."Cubic Feet")
                // {
                //     ToolTip = 'Specifies the value of the Cubic Feet field.';
                //     ApplicationArea = All;
                // }
                // field("Dock Delivery"; Rec."Dock Delivery")
                // {
                //     ToolTip = 'Specifies the value of the Dock Delivery field.';
                //     ApplicationArea = All;
                // }
                // field("Dock Pickup"; Rec."Dock Pickup")
                // {
                //     ToolTip = 'Specifies the value of the Dock Pickup field.';
                //     ApplicationArea = All;
                // }
                // field("Door To Door"; Rec."Door To Door")
                // {
                //     ToolTip = 'Specifies the value of the Door To Door field.';
                //     ApplicationArea = All;
                // }
                // field("Keep From Freezing"; Rec."Keep From Freezing")
                // {
                //     ToolTip = 'Specifies the value of the Keep From Freezing field.';
                //     ApplicationArea = All;
                // }
                group("Origin Options")
                {
                    field("Inside Pickup";Rec."Inside Pickup")
                    {
                        ToolTip = 'Specifies the value of the Inside Pickup field.';
                        ApplicationArea = All;
                    }
                    field("Limited Access Pickup";Rec."Limited Access Pickup")
                    {
                        ToolTip = 'Specifies the value of the Limited Access Pickup field.';
                        ApplicationArea = All;
                    }
                    field("Origin Lift gate";Rec."Origin Lift gate")
                    {
                        ToolTip = 'Specifies the value of the Origin Lift gate field.';
                        ApplicationArea = All;
                    }
                    field("Residential Pickup";Rec."Residential Pickup")
                    {
                        ToolTip = 'Specifies the value of the Residential Pickup field.';
                        ApplicationArea = All;
                    }
                    field("Get All Rates EasyPost";Rec."Get All Rates EasyPost")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Destination Options")
                {
                    field("Destination Lift gate";Rec."Destination Lift gate")
                    {
                        ToolTip = 'Specifies the value of the Destination Lift gate field.';
                        ApplicationArea = All;
                    }
                    field("Limited Access Delivery";Rec."Limited Access Delivery")
                    {
                        ToolTip = 'Specifies the value of the Limited Access Delivery field.';
                        ApplicationArea = All;
                    }
                    field("Residential Delivery";Rec."Residential Delivery")
                    {
                        ToolTip = 'Specifies the value of the Residential Delivery field.';
                        ApplicationArea = All;
                    }
                    field("Inside Delivery";Rec."Inside Delivery")
                    {
                        ToolTip = 'Specifies the value of the Inside Delivery field.';
                        ApplicationArea = All;
                    }
                    field("Delivery Notification";Rec."Delivery Notification")
                    {
                        ToolTip = 'Specifies the value of the Delivery Notification field.';
                        ApplicationArea = All;
                    }
                // field("Sort And Segregate"; Rec."Sort And Segregate")
                // {
                //     ToolTip = 'Specifies the value of the Sort And Segregate field.';
                //     ApplicationArea = All;
                // }
                }
                group("Shipment Options")
                {
                    // field(Freezable; Rec.Freezable)
                    // {
                    //     ToolTip = 'Specifies the value of the Freezable field.';
                    //     ApplicationArea = All;
                    // }
                    field(Hazmat;Rec.Hazmat)
                    {
                        ToolTip = 'Specifies the value of the Hazmat field.';
                        ApplicationArea = All;
                    }
                // field("Over Dimension"; Rec."Over Dimension")
                // {
                //     ToolTip = 'Specifies the value of the Over Dimension field.';
                //     ApplicationArea = All;
                // }
                }
            }
            part("Agent Service OPtions";"Agent Service Options")
            {
                Caption = 'Agent Service Options for Get Rates';
                ApplicationArea = All;
                SubPageLink = "Packing No"=field(No);
                UpdatePropagation = Both;
            }
        }
    }
}
