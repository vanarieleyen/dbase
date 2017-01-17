unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  db, unit2,
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, Grids, LazLogger, strutils, iconvenc, lazutf8;

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

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.Button1Click(Sender: TObject);
var
  i, r: integer;
  s, str, naam: string;
  database: TDBFdatabase;
begin
   database := TDBFdatabase.Create;
   database.Open(FileNameEdit1.FileName);

   Label4.Caption := database.DateOfUpdate;
   Label6.Caption := IntToStr(database.NumRecs);
   Label8.Caption := IntToStr(database.HeadLen);
   Label10.Caption := IntToStr(database.RecLen);

   StringGrid1.ColCount := database.NumFields;
   StringGrid1.RowCount := database.NumRecs+1;

   // set fieldnames
   for i := 0 to database.NumFields-1 do begin
      StringGrid1.Cells[i, 0] := database.fielddev[i].name;
   end;

   // read each record
   r := 1;
   WHILE r <= database.NumRecs DO BEGIN

      // get fieldvalue based on fieldname and recno
      DebugLn( database.GetField('WGLO', r) );

      FOR i := 0 TO database.NumFields-1 DO BEGIN
       	StringGrid1.Cells[i,r] := database.GetFieldNr(i, r);
      end;
      r := r+1;
   END;

    database.SetField('PH', 1, 'test');

{
   // search example (gives index of record)
   debugLn( inttostr(database.Locate('PH', 'COCO')) );

   	// fill remaining with spaces
   str := 'A';
   for i:=4-Length(str) downto 1 do
     str := str + 'X';

   s := '1234567890';
	// move the string to the database
   for i:= 1 to Length(str) do
     s[i+3] := str[i];
}
   DebugLn(s);
end;


end.

