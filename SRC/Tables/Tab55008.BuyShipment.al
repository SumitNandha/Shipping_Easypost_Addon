table 55008 "Buy Shipment"
{
    Caption = 'Buy Shipment';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Detailed Rates List";
    LookupPageId = "Detailed Rates List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Purchase Service"; Boolean)
        {
            Caption = 'Purchase Service';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                AuthString: Text;
                // responstempblob: Record TempBlob;
                Response: HttpResponseMessage;
                request: HttpRequestMessage;
                responsetext: text;
                headers: HttpHeaders;
                jsonBuffertemt: Record "JSON Buffer" temporary;
                jsonbuffer: Record "JSON Buffer";
                content: HttpContent;
                PackingModuleSetup: Record "Packing Module Setup";
                Client: HttpClient;
                jObject: JsonObject;
                jObject2: JsonObject;
                URL: Text;
                Shippackagelines: Record "Ship Packing Lines";
                LabelPath: Text;
                PublicURLPath: text;
                trackingCodePath: Text;
                Base64: Codeunit "Base64 Convert";
            begin
                URL := 'https://api.easypost.com/v2/shipments/' + Format(Rec."Shipment ID") + '/buy/';
                jObject.Add('id', Format(Rec."Rate ID"));
                jObject2.Add('rate', jObject);
                PackingModuleSetup.get();
                content.WriteFrom(Format(jObject2));
                content.GetHeaders(Headers);
                Headers.Clear();
                Headers.Add('Content-Type', 'application/json');
                request.Content := content;
                request.Method := 'POST';
                request.SetRequestUri(URL);
                request.GetHeaders(Headers);
                if PackingModuleSetup."Mode Test" then
                    AuthString := StrSubstNo('%1', PackingModuleSetup."EasyPost API Key")
                else
                    AuthString := StrSubstNo('%1', PackingModuleSetup."EasyPost Live API Key");
                //  responstempblob.WriteAsText(AuthString, TextEncoding::UTF8);
                // AuthString := responstempblob.ToBase64String();
                AuthString := Base64.ToBase64(AuthString);
                AuthString := StrSubstNo('Basic %1', AuthString);
                Headers.Add('Authorization', AuthString);
                Client.Get(URL, Response);
                Client.Send(request, Response);
                if not Response.IsSuccessStatusCode then Message('%1', Response.HttpStatusCode);
                response.Content.ReadAs(responsetext);
                Message(responsetext);
                jsonbuffer.Reset();
                jsonbuffer.DeleteAll();
                jsonBuffertemt.ReadFromText(responsetext);
                if jsonBuffertemt.FindSet() then
                    repeat
                        jsonbuffer := jsonBuffertemt;
                        jsonbuffer.Insert();
                    until jsonBuffertemt.Next() = 0;
                Shippackagelines.Reset();
                Shippackagelines.SetRange("No.", Rec."No.");
                Shippackagelines.SetRange("Packing No.", Rec."Packing No");
                if Shippackagelines.FindFirst() then begin
                    LabelPath := 'postage_label.label_url';
                    jsonbuffer.Reset();
                    jsonbuffer.SetFilter(Path, LabelPath);
                    jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::String);
                    if jsonbuffer.FindFirst() then begin
                        Shippackagelines.Validate("Label URL", jsonbuffer.GetValue());
                    end;
                    PublicURLPath := 'tracker.public_url';
                    jsonbuffer.Reset();
                    jsonbuffer.SetFilter(Path, PublicURLPath);
                    jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::String);
                    if jsonbuffer.FindFirst() then begin
                        Shippackagelines.Validate("Public URL", jsonbuffer.GetValue());
                    end;
                    trackingCodePath := 'tracking_code';
                    jsonbuffer.Reset();
                    jsonbuffer.SetFilter(Path, trackingCodePath);
                    jsonbuffer.SetFilter("Token type", '%1', jsonbuffer."Token type"::String);
                    if jsonbuffer.FindFirst() then begin
                        Shippackagelines.Validate("Tracking ID", jsonbuffer.GetValue());
                    end;
                    Shippackagelines.Modify();
                end;
            end;
        }
        field(4; Carrier; Text[100])
        {
            Caption = 'Carrier';
            DataClassification = ToBeClassified;
        }
        field(5; Service; Text[100])
        {
            Caption = 'Service';
            DataClassification = ToBeClassified;
        }
        field(6; Currency; Code[20])
        {
            Caption = 'Currency';
            DataClassification = ToBeClassified;
        }
        field(7; Rate; Decimal)
        {
            Caption = 'Rate';
            DataClassification = ToBeClassified;
        }
        field(8; "Delivery Days"; Integer)
        {
            Caption = 'Delivery Days';
            DataClassification = ToBeClassified;
        }
        //SJ 07102021 +
        field(9; "YRC Error Code"; Code[20])
        {
            Caption = 'YRC Error Code';
            DataClassification = ToBeClassified;
        }
        field(10; "YRC Error Message"; Text[1000])
        {
            Caption = 'YRC Error Message';
            DataClassification = ToBeClassified;
        }
        field(11; "YRC Service Occ Code"; Code[20])
        {
            Caption = 'YRC Service Occ Code';
            DataClassification = ToBeClassified;
        }
        field(12; "YRC Service Req"; Code[20])
        {
            Caption = 'YRC Service Req';
            DataClassification = ToBeClassified;
        }
        field(13; "Delivery Date Guaranteed"; Boolean)
        {
            Caption = 'Delivery Date Guaranteed';
            DataClassification = ToBeClassified;
        }
        field(14; "Quote ID"; code[50])
        {
            Caption = 'Quote ID';
            DataClassification = ToBeClassified;
        }
        field(15; "Packing No"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Packing No.';
        }
        field(16; "Rate ID"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Rate ID';
        }
        field(17; "Shipment ID"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipment ID';
        }
        //SJ 07102021 -
        field(18; "Shipment Refund Status"; Enum "Shipment Refund Status")
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipment Refund Status';
        }
         field(19;"EasyPost CA Account";Text[50])
        {
            DataClassification = ToBeClassified;
        }
         field(20;"EasyPost CA Name";Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
