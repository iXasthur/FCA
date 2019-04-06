unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  System.ImageList, Vcl.ImgList, Vcl.Buttons;

type
  TText = TStringList;
  TFile = TextFile;
  TForm1 = class(TForm)
    Label1: TLabel;
    GridPanelMain: TGridPanel;
    OpenDialog1: TOpenDialog;
    OpenButton: TSpeedButton;
    Memo1: TMemo;
    OpenLabel: TLabel;
    LabelFilePreview: TLabel;
    LabelFilePath: TLabel;
    CompressionButton: TSpeedButton;
    CheckBoxRLE: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    DecompressionButton: TSpeedButton;
    CheckBoxExport: TCheckBox;
    procedure OpenButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure CompressionButtonClick(Sender: TObject);
    procedure DecompressionButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function GetFileSize(FileName: String): Int64;
var FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  Result := FS.Size;
  FS.Free;
end;

//n-Full File Path
procedure printFileInfo(n:String);
begin
  Writeln('File Info:');
  writeln('Drive      = '+ExtractFileDrive (n));
  writeln('Catalog    = '+ExtractFileDir   (n));
  writeln('Path       = '+ExtractFilePath  (n));
  writeln('Name       = '+ExtractFileName  (n));
  writeln('Extention  = '+ExtractFileExt   (n));
  writeln('Size       = '+IntToStr(GetFileSize(n)));
end;




function RLECompressString(str: String):String;
var
  s: Integer;
  buffChar: Char;
  buffStr: String;
begin
  buffStr:='';
  if length(str)>1 then
  begin
    while length(str)>=1 do
    begin
      s:=0;
      buffChar:=str[1];

      while (length(str)>=1) and (str[1]=buffChar) and (s<>9) do
      begin
        s:=s+1;
        delete(str,1,1);
      end;

      buffStr:=buffStr+IntToStr(s);
      buffStr:=buffStr+buffChar;
    end;
  end else
        if length(str)=1 then
        begin
          buffChar:=str[1];
          buffStr:='1';
          buffStr:=buffStr+buffChar;
        end;


//  RLECompressString:=IntToStr(length(str));
  RLECompressString:=buffStr;
end;


procedure RLECompress(strs:TText; newPath:String);
var
  i: Integer;
  F: TFile;
begin
  AssignFile(F,newPath);
  Rewrite(F);
  if strs.Count>1 then
  begin
    for i:=0 to strs.Count-2 do
    begin
      writeln(F,RLECompressString(strs[i]));
    end;
    write(F,RLECompressString(strs[i]));
  end else
        if strs.Count=1 then
        begin
          write(F,RLECompressString(strs[0]));
        end;

  CloseFile(F);
end;



procedure CompressionStart(strs:TText;z:integer);
var
  i,p: Integer;
  newPath,newName: String;
begin
  newPath:=ExtractFilePath(Form1.OpenDialog1.FileName);
  newName:=ExtractFileName(Form1.OpenDialog1.FileName);
  p:=pos(ExtractFileExt(Form1.OpenDialog1.FileName),newName);
  if p<>0 then
  begin
    Delete(newName,p,length(ExtractFileExt(Form1.OpenDialog1.FileName)));
  end;




  case z of
    1:
      begin
        newName:=newName+'.xrle';
        newPath:=newPath+newName;

        RLECompress(strs,newPath);
        write('RLE ');
      end;
    2:
      begin
        newName:=newName+'.xhfm';
        newPath:=newPath+newName;

//        HUFFCompress(strs,newPath);
        write('Huffman ');
      end;
    3:
      begin

      end;
  end;


  strs.LoadFromFile(newPath);
  writeln('Compression Result:');
  for i := 0 to strs.Count-1 do
  begin
    writeln(strs[i]);
  end;


  writeln;
  printFileInfo(newPath);
  writeln;
  writeln;
end;


procedure TForm1.CompressionButtonClick(Sender: TObject);
var
  txt: TText;
  i:integer;
begin
  txt:= TStringList.Create;
  txt.LoadFromFile(Self.OpenDialog1.FileName);

  AllocConsole;
  writeln('Uncompressed text:');
  for i := 0 to txt.Count-1 do
  begin
    writeln(txt[i]);
  end;

  writeln;
  printFileInfo(Self.OpenDialog1.FileName);
  writeln;
  writeln;

  if Self.CheckBoxRLE.Checked then
  begin
    CompressionStart(txt,1);
  end;
  txt.Free;
  //FreeConsole;
end;



function decompressRLEString(str:String):String;
var
  s,i: Integer;
  buffChar: Char;
  buffCount: Integer;
  buffStr: String;
begin
  buffStr:='';
  if length(str)>2 then
  begin
    while length(str)>=2 do
    begin
      buffCount:=StrToInt(str[1]);
      buffChar:=str[2];
      for i:=1 to buffCount do
      begin
        buffStr:=buffStr+buffChar;
      end;
      delete(str,1,2);
    end;
  end else
        if length(str)=2 then
        begin
          buffCount:=StrToInt(str[1]);
          buffChar:=str[2];
          for i:=1 to buffCount do
          begin
            buffStr:=buffStr+buffChar;
          end;

        end;


//  decompressRLEString:=IntToStr(length(str));
  decompressRLEString:=buffStr;
end;


procedure decompressRLE(txt:TText;newPath:String);
var
  F:TFile;
  i:integer;
begin
  AssignFile(F,newPath);
  Rewrite(F);

  if txt.Count>1 then
  begin
    for i:=0 to txt.Count-2 do
    begin
      writeln(F,decompressRLEString(txt[i]));
    end;
    write(F,decompressRLEString(txt[i]));
  end else
        if txt.Count=1 then
        begin
        write(F,decompressRLEString(txt[0]));
        end;


  CloseFile(F);
end;


procedure StartDecompression(path:String;z:integer);
var
  i,p: Integer;
  txt:TText;
  newPath,newName: String;
begin
  AllocConsole;

  Form1.Memo1.Clear;
  txt:= TStringList.Create;
  txt.LoadFromFile(path);

  newPath:=ExtractFilePath(path);
  newName:=ExtractFileName(path);
  p:=pos(ExtractFileExt(path),newName);
  if p<>0 then
  begin
    Delete(newName,p,length(ExtractFileExt(path)));
  end;
  newName:='D_' + newName;
  newName:=newName+'.txt';
  newPath:=newPath+newName;

  case z of
    1:
      begin
        decompressRLE(txt,newPath);
        write('RLE ');
      end;
    2:
      begin

      end;
    3:
      begin

      end;
  end;

  txt.clear;
  txt.LoadFromFile(newPath);
  Form1.Memo1.Lines:=txt;

  writeln('Decompression Result:');
  for i := 0 to txt.Count-1 do
  begin
    writeln(txt[i]);
  end;


  writeln;
  printFileInfo(newPath);
  writeln;
  writeln;

  if Form1.CheckBoxExport.Checked=false then
  begin
    DeleteFile(newPath);
  end;

  txt.Free;
end;


procedure TForm1.DecompressionButtonClick(Sender: TObject);
begin
  if (Self.OpenDialog1.FileName<>'') and (ExtractFileExt(Form1.OpenDialog1.FileName)='.xrle') then
  begin
    StartDecompression(Self.OpenDialog1.FileName,1);
  end;

end;
















procedure TForm1.FormCreate(Sender: TObject);
begin
  Self.GridPanelMain.Color:=clWebSeashell;
  Self.OpenLabel.Caption:='File isn''t open';
  openDialog1.InitialDir := GetCurrentDir;
  Self.Memo1.Color:=clWebLavender;
  Self.Memo1.Text:='';
  Self.LabelFilePath.Hide;
  Self.LabelFilePreview.Caption:='File preview';

  Self.CheckBoxRLE.Enabled:=False;
  Self.CheckBox2.Enabled:=False;
  Self.CheckBox3.Enabled:=False;
  Self.CheckBoxExport.Enabled:=False;

  Self.CompressionButton.Enabled:=False;
  Self.DecompressionButton.Enabled:=False;

end;

procedure TForm1.OpenButtonClick(Sender: TObject);
var
  s:integer;
begin
  if OpenDialog1.Execute() then
  begin
    Self.Memo1.Lines.LoadFromFile(Self.OpenDialog1.FileName);

    Self.OpenButton.Caption:='Open another file';
    Self.OpenLabel.Hide;

    Self.LabelFilePath.Show;
    Self.LabelFilePath.Caption:='File path: ' + OpenDialog1.FileName;

    s:=0;
    if ExtractFileExt(Self.OpenDialog1.FileName)='.xrle' then
    begin
      s:=1;
    end else
          if ExtractFileExt(Self.OpenDialog1.FileName)='.xhfm' then
          begin
            s:=2;
          end;


    case s of
    1:
      begin
        Self.DecompressionButton.Enabled:=True;
        Self.DecompressionButton.Caption:='Decompress(RLE)';

        Self.CompressionButton.Enabled:=False;

        Self.CheckBoxRLE.Enabled:=False;
        Self.CheckBox2.Enabled:=False;
        Self.CheckBox3.Enabled:=False;
        Self.CheckBoxExport.Enabled:=True;
      end;
    2:
      begin
        Self.DecompressionButton.Enabled:=True;
        Self.DecompressionButton.Caption:='Decompress(Huffman)';

        Self.CompressionButton.Enabled:=False;

        Self.CheckBoxRLE.Enabled:=False;
        Self.CheckBox2.Enabled:=False;
        Self.CheckBox3.Enabled:=False;
        Self.CheckBoxExport.Enabled:=True;
      end;
    else
      begin
        Self.DecompressionButton.Enabled:=False;
        Self.DecompressionButton.Caption:='Decompress';

        Self.CompressionButton.Enabled:=True;

        Self.CheckBoxRLE.Enabled:=True;
        Self.CheckBox2.Enabled:=True;
        Self.CheckBox3.Enabled:=True;
        Self.CheckBoxExport.Enabled:=False;
      end;
    end;
  end;
end;


procedure TForm1.Label1Click(Sender: TObject);
begin
  if Self.Label1.Caption='(c)Mikhail Kavaleuski ' then
  begin
    Self.Label1.Caption:='�� ��������� �� ���! '
  end else
      begin
        Self.Label1.Caption:='(c)Mikhail Kavaleuski '
      end;

end;



end.
