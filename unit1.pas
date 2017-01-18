unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  dblo, dbhi,
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

   // example: update the first record
   //database.SetField('PH', 1, '1 长城（132醇味）威版');
   //database.SetField('ITEMS', 1, '      411');
   //database.SetField('HDHI', 1, '             85.00');

   // example: delete a record
   //database.Delete(2);

   // example: append an empty record
   //database.Append();

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

      // example: get fieldvalue based on fieldname and recno
      //DebugLn( database.GetField('WGLO', r) );

      FOR i := 0 TO database.NumFields-1 DO BEGIN
       	StringGrid1.Cells[i,r] := database.GetFieldNr(i, r);
      end;
      r := r+1;
   END;



   //DebugLn(s);
end;


end.

