unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  System.Threading, FMX.HTTP.Request;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  aData: string;
begin
  TTask.Run(
    procedure
    begin
      aData := TmyAPI.Get('http://rzaripov.kz/fmx.php?method=hello' { , TEncoding.UTF8 } ); // тут любой запрос

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          if TmyAPI.IsOK(aData) then // all is ok, no errors?
            ShowMessage(aData)
          else
            ShowMessage(TmyAPI.ErrorText(aData)); // show error text message
        end)
    end);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
var
  aData: string;
  aFields: TArray<TmyPostParam>;
begin
  // post fields
  SetLength(aFields, 2);
  aFields[0] := TmyPostParam.Create('method', 'getCode');
  aFields[1] := TmyPostParam.Create('phpCode', '1'); // 1/0

  // for example add file
  // aFields[1] := TmyPostParam.Create('file', 'd:\upload\file.jpg', true);

  TTask.Run(
    procedure
    begin
      aData := TmyAPI.Post('http://rzaripov.kz/fmx.php', aFields { , TEncoding.UTF8 } ); // тут любой запрос

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          if TmyAPI.IsOK(aData) then // all is ok, no errors?
            ShowMessage(aData)
          else
            ShowMessage(TmyAPI.ErrorText(aData)); // show error text message
        end)
    end);
end;

end.
