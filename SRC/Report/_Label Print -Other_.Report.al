report 55001 "Label Print -Other"
{
    DefaultLayout = RDLC;
    RDLCLayout = './SRC/Layout/LabelPrint-Other.rdl';

    dataset
    {
        dataitem("Ship Package Header"; "Ship Package Header")
        {
            RequestFilterFields = No;

            dataitem("Sub Packing Lines"; "Sub Packing Lines")
            {
                //DataItemLink = "No." = field(No);
                //CalcFields = "Label Image";
                column(Label_Image; "Label Image")
                {
                }
                column(No_; "Packing No.")
                {
                }
                column(Line_No_; "Line No.")
                {
                }
                trigger OnPreDataItem()
                begin
                    SetFilter("Packing No.", '%1', "Ship Package Header".No);
                    SetFilter("Label URL", '<>%1', '');
                end;

                trigger OnAfterGetRecord()
                var
                begin
                    //Message('%1', "Label Image".Length);
                end;
            }
            trigger OnPreDataItem()
            begin
                SetFilter(Carrier, '<>%1', 'UPS');
            end;
        }
    }
}
