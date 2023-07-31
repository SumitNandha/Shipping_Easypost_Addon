table 55005 "Packing List"
{
    Caption = 'Packing List';
    DataClassification = ToBeClassified;

    fields
    {
        field(3;"EntryNo";Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2;"Packing No";code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK;EntryNo)
        {
            Clustered = true;
        }
    }
    trigger OnInsert()var PackingList: Record "Packing List";
    begin
        // Message('oninsert');
        PackingList.Reset();
        PackingList.SetRange(EntryNo, Rec.EntryNo);
        if PackingList.FindLast()then rec.EntryNo:=PackingList.EntryNo + 1;
    end;
}
