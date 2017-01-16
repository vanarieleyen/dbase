unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  unit3,
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, Grids, LazLogger, strutils, iconvenc;

type
    PseudoStr = ARRAY[1..255] OF Char;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    FileNameEdit1: TFileNameEdit;
    Label10: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  dbfile: file;
  DB : dbfRecord;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.Button1Click(Sender: TObject);
var
  i, r: integer;
  s, str: string;
begin
	with DB do begin
   	FileName := FileNameEdit1.FileName;
     	OpenDbf(DB);
      StringGrid1.ColCount := NumFields;
      FOR i := 1 TO NumFields DO BEGIN
         StringGrid1.Cells[i-1,0] := Fields^[i].Name;
      end;
     	r := 1;
     	WHILE r <= NumRecs DO BEGIN
     		GetDbfRecord(DB, r);
      	FOR i := 1 TO NumFields DO BEGIN
				SetString(s, @CurRecord^[Fields^[i].Off] , Fields^[i].Len);
            StringGrid1.RowCount := r+1;
            IConvert(s,str,'gb18030','utf8');
         	StringGrid1.Cells[i-1,r] := str;
         end;
         r := r+1;
      END;
      Label4.Caption := DateOfUpdate;
      Label6.Caption := IntToStr(NumRecs);
      Label8.Caption := IntToStr(HeadLen);
      Label10.Caption := IntToStr(RecLen);
   end;
   //DebugLn(dbgs(header));
end;

end.

