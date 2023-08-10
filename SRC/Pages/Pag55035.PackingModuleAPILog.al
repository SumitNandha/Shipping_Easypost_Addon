page 55035 "Packing Module API Log"
{
    ApplicationArea = All;
    Caption = 'Packing Module API Log';
    PageType = List;
    SourceTable = "Packing Module API log";
    UsageCategory = Lists;
    Editable = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Packing No."; Rec."Packing No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Packing No. field.';
                }
                field("Box ID"; Rec."Box ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Box ID field.';
                }
                field(Method; Rec.Method)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Method field.';
                }
                field(Request; Rec.Request)
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    ToolTip = 'Specifies the value of the Request Json.';
                    trigger OnAssistEdit()
                    var
                        IInStream: InStream;
                        TextMessage: Text;
                    begin
                        Rec.CalcFields(Rec.Request);
                        if Rec.Request.HasValue then begin
                            Rec.Request.CreateInStream(IInStream);
                            IInStream.ReadText(TextMessage);
                            Message(TextMessage);
                        end;
                    end;
                }
                field(Response; Rec.Response)
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    ToolTip = 'Specifies the value of the Response Json.';
                    trigger OnAssistEdit()
                    var
                        IInStream: InStream;
                        TextMessage: Text;
                    begin
                        Rec.CalcFields(Rec.Response);
                        if Rec.Response.HasValue then begin
                            Rec.Response.CreateInStream(IInStream);
                            IInStream.ReadText(TextMessage);
                            Message(TextMessage);
                        end;
                    end;
                }
                field("HTTP Status Code"; Rec."HTTP Status Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the HTTP Status Code field.';
                }
                field("Date/Time"; Rec."Date/Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date/Time field.';
                }
                field(URL; Rec.URL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the URL field.';
                }
            }
        }
    }
}
