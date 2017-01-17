unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazLogger, db, iconvenc, math;

(******************************************************************************
High level DBase file handling

On open the DBase file is completely read into memory and closed
Field content is seen as string data, each field is stored in a string that contains all
field-data in one long string (this makes locating fast)

Usage:

database := TDBFdatabase.Create;
database.Open(FileName);

GetField(fieldname; recno)	: returns content of field
GetFieldNr(fieldnr; recno) : returns content of field
Locate(fieldname; needle) : returns location or 0 when not found
******************************************************************************)

type
   TRecord = record
		name: string;
      length: integer;
   end;

	Tvalues = array of string;  	// field contents in one long string
   TFields = array of TRecord;

   TDBFdatabase = class
		private
      public
         numfields: integer;
         numrecs: integer;
         HeadLen:	integer;
         RecLen: integer;
         DateOfUpdate: string;
        	fieldval: Tvalues;
			fielddev: TFields;
         DBASE : dbfRecord;
         procedure Open(text: string);
         procedure Close();
         function GetField(name: string; recno: integer): string;
         function GetFieldNr(nr: integer; recno: integer): string;
         function Locate(field: string; needle: string): integer;
         procedure SetField(name: string; recno: integer; value: string);
			procedure SetFieldNr(nr: integer; recno: integer; value: string);
   end;

implementation

// open the database and read the data into memory
procedure TDBFdatabase.Open(text: string);
var
  i, r: integer;
  s: string;
begin
   DBASE.FileName := text;
   OpenDbf(DBASE);
   IF NOT dbfOK THEN
      ErrorHalt(dbfError);

   numfields := DBASE.NumFields;
   numrecs := DBASE.NumRecs;
   RecLen := DBASE.RecLen;
   HeadLen := DBASE.HeadLen;
   DateOfUpdate := DBASE.DateOfUpdate;

   setlength(fieldval, numfields);
   setlength(fielddev, numfields);

   FOR i := 0 TO numfields-1 DO BEGIN			// store fieldnames and lengths
     fielddev[i].name := DBASE.Fields^[i+1].Name;
     fielddev[i].length := DBASE.Fields^[i+1].Len;
   end;

   r := 1;
   WHILE r <= numrecs DO BEGIN       // store all records
   	GetDbfRecord(DBASE, r);
    	FOR i := 0 TO numfields-1 DO BEGIN
			SetString(s, @DBASE.CurRecord^[DBASE.Fields^[i+1].Off] , DBASE.Fields^[i+1].Len);
         fieldval[i] := fieldval[i] + s;
      end;
      r := r+1;
   END;
end;

// get fieldvalue based on field name and record number
function TDBFdatabase.GetField(name: string; recno: integer): string;
var
  i: integer;
begin
   for i := 0 to numfields-1 do begin
 	 	if fielddev[i].name = name then
   	  	break;
   end;
   Result := GetFieldNr(i, recno);
end;

// get fieldvalue based on field number and record number
function TDBFdatabase.GetFieldNr(nr: integer; recno: integer): string;
var
	s, str: string;
begin
   s := copy( fieldval[nr], (recno-1)*fielddev[nr].length+1, fielddev[nr].length);
   IConvert(s,str,'gb18030','utf8');
   Result := str;
end;

// set fieldvalue based on field name and record number
procedure TDBFdatabase.SetField(name: string; recno: integer; value: string);
var
  i: integer;
begin
   for i := 0 to numfields-1 do begin
 	 	if fielddev[i].name = name then
   	  	break;
   end;
   SetFieldNr(i, recno, value);
end;

// set fieldvalue based on field number and record number
procedure TDBFdatabase.SetFieldNr(nr: integer; recno: integer; value: string);
var
	str: string;
   s: string;
   i: integer;
begin
   IConvert(value, str, 'utf8','gb18030');	// convert utf8 string to dbase format (gb18030)

	// fill remaining with spaces
   for i:=fielddev[nr].length-Length(str) downto 1 do
     str := str + ' ';

	// move the string to the memory database
   for i:=1 to fielddev[nr].length do
     fieldval[nr][recno*fielddev[nr].length+i] := str[i];

   // update the physical database
   GetDbfRecord(DBASE, recno);
   /s := @DBASE.CurRecord^[DBASE.Fields^[nr].Off];
   //SetString(s, @str, DBASE.Fields^[nr].Len);
   //Move(DBASE.CurRecord^[DBASE.Fields^[nr].Off], str, DBASE.Fields^[nr].Len);
   //PutDbfRecord(DBASE, recno);
end;

procedure TDBFdatabase.Close();
begin
   CloseDbf(DBASE);
end;


// locate record, returns index or 0 when not found
function TDBFdatabase.Locate(field: string; needle: string): integer;
var
   i: integer;
	str: string;
begin
   for i := 0 to numfields-1 do begin
 	 	if fielddev[i].name = field then
   	  	break;
   end;
   IConvert(needle, str, 'utf8','gb18030');
   Result := ceil(Pos(str, fieldval[i])/fielddev[i].length);
end;


end.

