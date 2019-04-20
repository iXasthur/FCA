unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  System.ImageList, Vcl.ImgList, Vcl.Buttons, Math, System.IOUtils;



type
  //TText = TStringList;
  TFile = TextFile;

  THuffArrayElement = Record
    symbolCode: Integer;
    count: Integer;
  end;
  THuffArray = Array of THuffArrayElement;

  HUFFTreePointer = ^HUFFTreeNode;
  HUFFTreeNode = Record
    symbol: Integer;
    left: HUFFTreePointer;
    right: HUFFTreePointer;
  end;


type
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
    CheckBoxHUFF: TCheckBox;
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




const
  outputFiles = false;



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



//-------RLE-------
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

      while (length(str)>=1) and (str[1]=buffChar) and (s<>127) do
      begin
        s:=s+1;
        delete(str,1,1);
      end;
//      writeln(s:3,buffChar:2);
      buffStr:=buffStr+Chr(s);
      buffStr:=buffStr+buffChar;
    end;
  end else
        if length(str)=1 then
        begin
          buffChar:=str[1];
          buffStr:='1';
          buffStr:=buffStr+buffChar;
        end;

  RLECompressString:=buffStr;
end;


procedure RLECompress(s:string; newPath:String);
var
  i: Integer;
  F: TFile;
begin
  AssignFile(F,newPath);
  Rewrite(F);
  write(F,RLECompressString(s));


  CloseFile(F);
end;
//-----------------



//-----HUFFMAN-----
function HUFFGetCount(var arr:THuffArray; str: String):integer;
var
  i,n: Integer;
  buffChar: char;
  check: boolean;
begin
  n:=-1;
  while length(str)>0 do
  begin
    n:=n+1;
    buffChar:=str[1];
    arr[n].symbolCode:=ord(buffChar);
    while pos(buffChar,str)<>0 do
    begin
      arr[n].count:=arr[n].count+1;
      delete(str, pos(buffChar,str), 1);
    end;

  end;
  HUFFGetCount:=n+1;
end;


procedure HUFFSort(var arr:THuffArray);
var
  i: integer;
  save:THuffArrayElement;
  check:Boolean;
begin
  check:=false;
  while check=false do
  begin
    check:=true;
    for i := 0 to length(arr)-2 do
    begin
      if arr[i].count<arr[i+1].count then
      begin
        save:=arr[i];
        arr[i]:=arr[i+1];
        arr[i+1]:=save;
        check:=false;
      end;
    end;
  end;
end;

procedure HUFFCreateTree(var head: HuffTreePointer; arr:THuffArray);
var
  elementL,elementR: HuffTreePointer;
  n:integer;
begin
  n:=0;

  new(head);
  head.symbol:=-1;
  head.left:=nil;
  head.right:=nil;

  elementL:=head;
  elementR:=head;

  while n<length(arr)-2 do
  begin
    new(elementL.left);
    elementL:=elementL.left;
    elementL.symbol:=-1;
    elementL.left:=nil;

    new(elementL.right);
    elementL.right.right:=nil;
    elementL.right.left:=nil;
    elementL.right.symbol:=arr[n].symbolCode;
    n:=n+1;

    if n<length(arr)-2 then
    begin
      new(elementR.right);
      elementR:=elementR.right;
      elementR.symbol:=-1;
      elementR.right:=nil;

      new(elementR.left);
      elementR.left.right:=nil;
      elementR.left.left:=nil;
      elementR.left.symbol:=arr[n].symbolCode;
      n:=n+1;
    end;
  end;

  if length(arr)>0 then
  begin
    new(elementR.right);
    elementR:=elementR.right;
    elementR.right:=nil;
    elementR.left:=nil;
    elementR.symbol:=arr[n].symbolCode;

    if length(arr)>1 then
    begin
      new(elementL.left);
      elementL:=elementL.left;
      elementL.right:=nil;
      elementL.left:=nil;
      elementL.symbol:=arr[n+1].symbolCode;
    end;
  end;


end;

procedure OutputTree(head:HuffTreePointer);
var
  element: HuffTreePointer;
  check: Boolean;
  i: integer;
begin
  writeln('Left Branch');
  element:=head;
  check:=true;
  while check=true do
  begin
    check:=false;
    if element.left<>nil then
    begin
      element:=element.left;

      if element.right<>nil then
      begin
        write(chr(element.right.symbol));
        check:=true;
      end else
          begin
            writeln(chr(element.symbol));
          end;
    end;
  end;

  writeln('Right Branch');
  element:=head;
  check:=true;
  while check=true do
  begin
    check:=false;
    if element.right<>nil then
    begin
      element:=element.right;

      if element.left<>nil then
      begin
        write(chr(element.left.symbol));
        check:=true;
      end else
          begin
            writeln(chr(element.symbol));
          end;
    end;
  end;
  writeln;

end;

function HUFFGetBSymbol(head:HuffTreePointer; c:Char):String;
var
  buff,buffL,buffR: String;
  elementL, elementR: HuffTreePointer;
  check: Boolean;
begin
  buff:='';
  buffL:='';
  buffR:='';

  elementL:=head;
  elementR:=head;

  check:=false;
  while check=false do
  begin
    if elementL.left<>nil then
    begin
      elementL:=elementL.left;
      buffL:=buffL+'0';

      if elementL.symbol=ord(c) then
      begin
        buff:=buffL;
        check:=true;
      end else
            if elementL.right<>nil then
            begin
              if elementL.right.symbol=ord(c) then
              begin
                buffL:=buffL+'1';
                buff:=buffL;
                check:=true;
              end;
            end;
    end;


    if check<>true then
    begin
      if elementR.right<>nil then
      begin
        elementR:=elementR.right;
        buffR:=buffR+'1';

        if elementR.symbol=ord(c) then
        begin
          buff:=buffR;
          check:=true;
        end else
              if elementR.left<>nil then
              begin
                if elementR.left.symbol=ord(c) then
                begin
                  buffR:=buffR+'0';
                  buff:=buffR;
                  check:=true;
                end;
              end;
      end;
    end;
  end;

//  writeln(c,'_',buff);
  HUFFGetBSymbol:=buff;
end;

function StrBinToInt(s: String; l:integer):Integer;
var
  i: integer;
  value: integer;
begin
  value:=0;
  for i:=1 to l do
  begin
    if s[i]='1' then
    begin
//      value:=value+round(exp(abs(i-8)*ln(2)));
      value:=value+round(power(2,abs(i-l)));
    end;
  end;
//  write(' ',value);
  StrBinToInt:=value;
end;

function HUFFStringBinaryToChar(s:String):String;
var
  buff:String;
  lastLength,i: Integer;
begin
  buff:='';

  while length(s)>7 do
  begin
    buff:=buff+chr(StrBinToInt(s,7));
    delete(s,1,7);
  end;
//  writeln;
  {
    Next part adds (lastLength) additional 0 to beginning of the next sequence
  }
  if (length(s)>0) and (length(s)<=7) then
  begin
    lastLength:=length(s);
    if lastLength<>0 then
    begin
      buff:=buff+chr(StrBinToInt(s,lastLength));
    end;
    buff:=buff+IntToStr(7-lastLength);
  end;


  HUFFStringBinaryToChar:=buff;
end;

function HUFFCompressString(head:HuffTreePointer; s: String):String;
var
  i: Integer;
  encodedStr: String;
begin
  encodedStr:='';
  for i:=1 to length(s) do
  begin
    encodedStr:=encodedStr+HUFFGetBSymbol(head, s[i]);
  end;
  //writeln(encodedStr);

  encodedStr:=HUFFStringBinaryToChar(encodedStr);

  HUFFCompressString:=encodedStr;
end;


procedure HUFFCompress(s:String; newPath:String);
var
  i,n: Integer;
  F: TFile;
  arr: THuffArray;
  treeHead: HuffTreePointer;
begin
  SetLength(arr,1024);
  n:=HUFFGetCount(arr,s);
  SetLength(arr,n);
  HUFFSort(arr);

  HUFFCreateTree(treeHead,arr);
  //OutputTree(treeHead);
  s:=HUFFCompressString(treeHead, s);

  AssignFile(F,newPath);
  Rewrite(F);

  //HuffTable in file
  for i := 0 to length(arr)-1 do
  begin
    write(F,Chr(arr[i].symbolCode));
  end;
  write(F,#27,#27);
  //

  write(F,s);

  CloseFile(F);
  Finalize(arr);

  //ClearTree!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //ClearTree!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //ClearTree!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //ClearTree!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //ClearTree!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

end;
//-----------------










procedure CompressionStart(s:string;z:integer);
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

        RLECompress(s,newPath);
        write('RLE ');
      end;
    2:
      begin
        newName:=newName+'.xhfm';
        newPath:=newPath+newName;

        HUFFCompress(s,newPath);
        write('Huffman ');
      end;
    3:
      begin

      end;
  end;


  s:=System.IOUtils.TFile.ReadAllText(newPath);
  writeln('Compression Result:');
  if outputFiles then
  begin
    writeln(s);
  end;




  writeln;
  printFileInfo(newPath);
  writeln;
  writeln;
end;


procedure TForm1.CompressionButtonClick(Sender: TObject);
var
  s: String;
  i:integer;
begin
  s:=System.IOUtils.TFile.ReadAllText(Self.OpenDialog1.FileName);
  AllocConsole;
  writeln('Uncompressed text:');
  if outputFiles then
  begin
    writeln(s);
  end;

  writeln;
  printFileInfo(Self.OpenDialog1.FileName);
  writeln;
  writeln;

  if Self.CheckBoxRLE.Checked then
  begin
    CompressionStart(s,1);
  end;

  if Self.CheckBoxHUFF.Checked then
  begin
    CompressionStart(s,2);
  end;

  //FreeConsole;
end;




//-------RLE-------
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
      buffCount:=Ord(str[1]);
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
          buffCount:=Ord(str[1]);
          buffChar:=str[2];
          for i:=1 to buffCount do
          begin
            buffStr:=buffStr+buffChar;
          end;

        end;


  decompressRLEString:=buffStr;
end;


procedure decompressRLE(s,newPath:String);
var
  F:TFile;
  i:integer;
begin
  AssignFile(F,newPath);
  Rewrite(F);

  write(F,decompressRLEString(s));


  CloseFile(F);
end;
//-----------------




//-----HUFFMAN-----
function IntToBin7(d: Integer): string;
var
  x, p: Integer;
  bin: string;
begin
  bin := '';
  for x := 1 to 7 do
  begin
    if Odd(d) then
    begin
      bin := '1' + bin
    end else
        begin
          bin := '0' + bin;
        end;
    d := d shr 1;
  end;
  Delete(bin, 1, 8 * ((Pos('1', bin) - 1) div 8));
  Result := bin;
end;


function HUFFCharToStringBinary(s:string):String;
var
  buff:String;
  i,z:integer;
begin
  buff:='';
  for i:=1 to length(s)-1 do
  begin
    buff:=buff+IntToBin7(ord(s[i]));
  end;
  z:=StrToInt(s[length(s)]);
  delete(buff,length(buff)-6,z);
  HUFFCharToStringBinary:=buff;
end;


function getSymbolFromHuffTree(head:HuffTreePointer; buffSequence:string):Integer;
var
  code,i:integer;
  element:HuffTreePointer;
begin
  code:=-1;
  element:=head;
  case StrToInt(buffSequence[1]) of
    0:
      begin
        for i:=1 to length(buffSequence)-1 do
        begin
          element:=element.left;
        end;

        if buffSequence[length(buffSequence)]='1' then
        begin
          code:=element.right.symbol;
        end else
            begin
              code:=element.left.symbol;
            end;
      end;
    1:
      begin
        for i:=1 to length(buffSequence)-1 do
        begin
          element:=element.right;
        end;

        if buffSequence[length(buffSequence)]='1' then
        begin
          code:=element.right.symbol;
        end else
            begin
              code:=element.left.symbol;
            end;
      end;
  end;

  getSymbolFromHuffTree:=code;
end;

function decodeHuffString(head:HuffTreePointer; s:string):String;
var
  buff, buffSequence:string;
  z:integer;
begin
  buff:='';
  buffSequence:='';
  while length(s)>0 do
  begin
    buffSequence:=buffSequence+s[1];
    delete(s,1,1);

    z:=getSymbolFromHuffTree(head, buffSequence);
    if z<>-1 then
    begin
      buff:=buff+Chr(z);
      buffSequence:='';
    end;


  end;

  decodeHuffString:=buff;
end;


procedure decompressHFM(s:string;newPath:String);
var
  F:TFile;
  i,n,p:integer;
  arr:THuffArray;
  head:HUFFTreePointer;
  buff:String;
begin
  if (length(s)>2)  and (pos(#27#27,s)<>0) then
  begin
    buff:='';
    p:=pos(#27#27,s);
    if pos(#27#27#27,s)=p then
    begin
      p:=p+1;
    end;

    for i:=1 to p-1 do
    begin
      buff:=buff+s[i];
    end;

    setLength(arr,p-1);
    HUFFGetCount(arr,buff);

    HUFFCreateTree(head,arr);
    //OutputTree(head);


    delete(s,1,p+1);
    s:=HUFFCharToStringBinary(s);
    s:=decodeHuffString(head,s);

  end else
      begin
        s:='';
      end;
  Finalize(arr);

  AssignFile(F,newPath);
  Rewrite(F);
  write(F,s);


  CloseFile(F);

  //----Clear-Tree!!!-----
  //----Clear-Tree!!!-----
  //----Clear-Tree!!!-----
  //----Clear-Tree!!!-----
  //----Clear-Tree!!!-----
end;
//-----------------



procedure StartDecompression(path:String;z:integer);
var
  i,p: Integer;
  s:string;
  newPath,newName: String;
begin
  AllocConsole;
  Form1.Memo1.Clear;


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
        s:=System.IOUtils.TFile.ReadAllText(path);
        decompressRLE(s,newPath);
        write('RLE ');
      end;
    2:
      begin
        s:=System.IOUtils.TFile.ReadAllText(path);
        decompressHFM(s,newPath);
        write('Huffman ');
      end;
    3:
      begin

      end;
  end;

  s:=System.IOUtils.TFile.ReadAllText(newPath);
  writeln('Decompression Result:');
  if outputFiles then
  begin
    writeln(s);
  end;
  Form1.Memo1.Text:=s;


  writeln;
  printFileInfo(newPath);
  writeln;
  writeln;

  if Form1.CheckBoxExport.Checked=false then
  begin
    DeleteFile(newPath);
  end;

end;


procedure TForm1.DecompressionButtonClick(Sender: TObject);
begin
  if (Self.OpenDialog1.FileName<>'') then
  begin
    if ExtractFileExt(Form1.OpenDialog1.FileName)='.xrle' then
    begin
      StartDecompression(Self.OpenDialog1.FileName,1);
    end else
          if ExtractFileExt(Form1.OpenDialog1.FileName)='.xhfm' then
          begin
            StartDecompression(Self.OpenDialog1.FileName,2);
          end;
  end

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
  Self.CheckBoxHUFF.Enabled:=False;
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
        Self.CheckBoxHUFF.Enabled:=False;
        Self.CheckBox3.Enabled:=False;
        Self.CheckBoxExport.Enabled:=True;
      end;
    2:
      begin
        Self.DecompressionButton.Enabled:=True;
        Self.DecompressionButton.Caption:='Decompress(Huffman)';

        Self.CompressionButton.Enabled:=False;

        Self.CheckBoxRLE.Enabled:=False;
        Self.CheckBoxHUFF.Enabled:=False;
        Self.CheckBox3.Enabled:=False;
        Self.CheckBoxExport.Enabled:=True;
      end;
    else
      begin
        Self.DecompressionButton.Enabled:=False;
        Self.DecompressionButton.Caption:='Decompress';

        Self.CompressionButton.Enabled:=True;

        Self.CheckBoxRLE.Enabled:=True;
        Self.CheckBoxHUFF.Enabled:=True;
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
