unit FPDF.adapter;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  ShellAPI,
  fpdf,
  fpdf_ext;

type
  IFPDFAdapter = interface;

  TFPDFChild = class;
  TFPDFAdapterEvent = procedure (APDFAdapter: IFPDFAdapter) of object;
  TFPDFAcceptPageBreak = function : Boolean of object;

  IFPDFAdapter = interface
    ['{9BD5DF0F-5187-4F80-9B7C-9FE6682B1A31}']
    function Parent: TFPDFChild;
    function OnHeader(APDFAdapter: TFPDFAdapterEvent): IFPDFAdapter;
    function OnFooter(APDFAdapter: TFPDFAdapterEvent): IFPDFAdapter;
    function OnAcceptPageBreak(AFunc: TFPDFAcceptPageBreak): IFPDFAdapter;
    function AddPage: IFPDFAdapter;
    function Font(const AFamily: string; const AStyle: string; ASize: Double): IFPDFAdapter; overload;
    function Font(const AStyle: string): IFPDFAdapter; overload;
    function Font(const ASize: Double): IFPDFAdapter; overload;
    function BoldOn: IFPDFAdapter;
    function BoldOff: IFPDFAdapter;
    function Ln(const AHeight: Double = 0): IFPDFAdapter;
    function Cell(const AWidth: Double; AHeight: Double = 0; const AText: string = '';  const ABorder: string = '0';
      ALineBreak: Integer = 0; const AAlign: string = ''; AFill: Boolean = False; ALink: string = ''): IFPDFAdapter;
    function CellLeft(const AWidth: Double; AHeight: Double; const AText: string): IFPDFAdapter;
    function CellRight(const AWidth: Double; AHeight: Double; const AText: string): IFPDFAdapter;
    function PageNo: Integer;
    procedure Generate;
  end;

  TFPDFChild = class(TFPDFExt)
  private
    FOnAcceptPageBreak: TFPDFAcceptPageBreak;
  public
//    function lMargin_: Double;
//    function tMargin_: Double;
//    function rMargin_: Double;
//    function bMargin_: Double;
//    function cMargin_: Double;
    function AcceptPageBreak: Boolean; override;
    procedure OnAcceptPageBreak(AFunc: TFPDFAcceptPageBreak);
  end;

  TFPDFAdapter = class(TInterfacedObject, IFPDFAdapter)
  private
    FPDF: TFPDFChild;
    FDirFilePDF: string;
    FPathFilePDF: string;
    FPageTitle: string;
    FFamilyAtual: string;
    FSizeAtual: double;
    FStyleAtual: string;
    FOnHeader: TFPDFAdapterEvent;
    FOnFooter: TFPDFAdapterEvent;
    FOpenAfterGenerating: Boolean;
    procedure PrintHeader(APDF: TFPDF); overload;
    procedure PrintFooter(APDF: TFPDF); overload;
    procedure ConfPDFOnCreate;
    procedure SetDefaultValues;
    procedure ConfDirectories;
  protected
    function Parent: TFPDFChild;
    function OnHeader(APDFAdapter: TFPDFAdapterEvent): IFPDFAdapter;
    function OnFooter(APDFAdapter: TFPDFAdapterEvent): IFPDFAdapter;
    function OnAcceptPageBreak(AFunc: TFPDFAcceptPageBreak): IFPDFAdapter;
    function AddPage: IFPDFAdapter;
    function Font(const AFamily: string; const AStyle: string; ASize: Double): IFPDFAdapter; overload;
    function Font(const AStyle: string): IFPDFAdapter; overload;
    function Font(const ASize: Double): IFPDFAdapter; overload;
    function BoldOn: IFPDFAdapter;
    function BoldOff: IFPDFAdapter;
    function Ln(const AHeight: Double = 0): IFPDFAdapter;
    function Cell(const AWidth: Double; AHeight: Double = 0; const AText: string = '';  const ABorder: string = '0';
      ALineBreak: Integer = 0; const AAlign: string = ''; AFill: Boolean = False; ALink: string = ''): IFPDFAdapter;
    function CellLeft(const AWidth: Double; AHeight: Double; const AText: string): IFPDFAdapter;
    function CellRight(const AWidth: Double; AHeight: Double; const AText: string): IFPDFAdapter;
    function PageNo: Integer;
    procedure Generate;
  public
    class function New: IFPDFAdapter;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TFPDFChild }

function TFPDFChild.AcceptPageBreak: Boolean;
begin
  if Assigned(FOnAcceptPageBreak) then
    FOnAcceptPageBreak
  else
    inherited AcceptPageBreak;
end;

//function TFPDFChild.lMargin_: Double;
//begin
//  Result := Self.lMargin;
//end;
//
//function TFPDFChild.tMargin_: Double;
//begin
//  Result := Self.tMargin;
//end;
//
//function TFPDFChild.rMargin_: Double;
//begin
//  Result := Self.rMargin;
//end;
//
//function TFPDFChild.bMargin_: Double;
//begin
//  Result := Self.bMargin;
//end;
//
//function TFPDFChild.cMargin_: Double;
//begin
//  Result := Self.cMargin;
//end;

procedure TFPDFChild.OnAcceptPageBreak(AFunc: TFPDFAcceptPageBreak);
begin
  FOnAcceptPageBreak := AFunc;
end;

{ TFPDFAdapter }
class function TFPDFAdapter.New: IFPDFAdapter;
begin
  Result := Self.Create;
end;

constructor TFPDFAdapter.Create;
begin
  FPDF := TFPDFChild.Create;
  Self.SetDefaultValues;
  Self.ConfDirectories;
  Self.ConfPDFOnCreate;
end;

destructor TFPDFAdapter.Destroy;
begin
  FPDF.Free;
  inherited;
end;

function TFPDFAdapter.AddPage: IFPDFAdapter;
begin
  Result := Self;
  FPDF.AddPage;
end;

procedure TFPDFAdapter.ConfDirectories;
begin
  FDirFilePDF := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'PDFs' + PathDelim;
  if not DirectoryExists(FDirFilePDF) then
    ForceDirectories(FDirFilePDF);
  FPathFilePDF := FDirFilePDF + 'MeuTeste.pdf';
end;

procedure TFPDFAdapter.ConfPDFOnCreate;
begin
  FPDF.OnHeader := PrintHeader;
  FPDF.OnFooter := PrintFooter;
  FPDF.SetCompression(True);
  Self.Font('Arial', '', 10);
end;

procedure TFPDFAdapter.SetDefaultValues;
begin
  FOpenAfterGenerating := True;
  FPageTitle := 'Relatório';
end;

function TFPDFAdapter.Parent: TFPDFChild;
begin
  Result := FPDF;
end;

function TFPDFAdapter.OnHeader(APDFAdapter: TFPDFAdapterEvent): IFPDFAdapter;
begin
  Result := Self;
  FOnHeader := APDFAdapter;
end;

function TFPDFAdapter.OnFooter(APDFAdapter: TFPDFAdapterEvent): IFPDFAdapter;
begin
  Result := Self;
  FOnFooter := APDFAdapter;
end;

function TFPDFAdapter.OnAcceptPageBreak(AFunc: TFPDFAcceptPageBreak): IFPDFAdapter;
begin
  Result := Self;
  FPDF.OnAcceptPageBreak(AFunc);
end;

procedure TFPDFAdapter.PrintHeader(APDF: TFPDF);
begin
  if Assigned(FOnHeader) then
    FOnHeader(Self);
end;

procedure TFPDFAdapter.PrintFooter(APDF: TFPDF);
begin
  if Assigned(FOnFooter) then
    FOnFooter(Self);
end;

function TFPDFAdapter.Font(const AFamily: string; const AStyle: string; ASize: Double): IFPDFAdapter;
begin
  Result := Self;
  FFamilyAtual := AFamily;
  FStyleAtual := AStyle;
  FSizeAtual := ASize;
  FPDF.SetFont(AFamily, AStyle, ASize);
end;

function TFPDFAdapter.Font(const ASize: Double): IFPDFAdapter;
begin
  Result := Self;
  Self.Font(FFamilyAtual, FStyleAtual, ASize);
end;

function TFPDFAdapter.Font(const AStyle: string): IFPDFAdapter;
begin
  Result := Self;
  Self.Font(FFamilyAtual, AStyle, FSizeAtual);
end;

function TFPDFAdapter.BoldOn: IFPDFAdapter;
begin
  Result := Self;
  Self.Font(FFamilyAtual, 'B', FSizeAtual);
end;

function TFPDFAdapter.BoldOff: IFPDFAdapter;
begin
  Result := Self;
  Self.Font(FFamilyAtual, '', FSizeAtual);
end;

function TFPDFAdapter.Ln(const AHeight: Double = 0): IFPDFAdapter;
begin
  Result := Self;
  FPDF.Ln(AHeight);
end;

function TFPDFAdapter.Cell(const AWidth: Double; AHeight: Double; const AText, ABorder: string; ALineBreak: Integer;
  const AAlign: string; AFill: Boolean; ALink: string): IFPDFAdapter;
begin
  Result := Self;
  FPDF.Cell(AWidth, AHeight, AText, ABorder, ALineBreak, AAlign, AFill, ALink);
end;

function TFPDFAdapter.CellLeft(const AWidth: Double; AHeight: Double; const AText: string): IFPDFAdapter;
begin
  Result := Self.Cell(AWidth, AHeight, AText, '0', 0, 'L');
end;

function TFPDFAdapter.CellRight(const AWidth: Double; AHeight: Double; const AText: string): IFPDFAdapter;
begin
  Result := Self.Cell(AWidth, AHeight, AText, '0', 0, 'R');
end;

function TFPDFAdapter.PageNo: Integer;
begin
  Result := FPDF.PageNo;
end;

procedure TFPDFAdapter.Generate;
begin
  Self.Ln.BoldON;
  //FPDF.Cell(95, 4, Format('%s  %s %d', [FormatFloat('000000', 10), 'Cliente nome teste ', 10]), '1');

  FPDF.SaveToFile(FPathFilePDF);

  if FOpenAfterGenerating then
    ShellExecute(0, 'open', PChar(FPathFilePDF), nil, nil, SW_SHOWNORMAL);
end;

end.
