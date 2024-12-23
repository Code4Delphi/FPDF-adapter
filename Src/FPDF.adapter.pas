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

  TFPDFAdapterEvent = procedure (APDFAdapter: IFPDFAdapter) of object;

  IFPDFAdapter = interface
    ['{9BD5DF0F-5187-4F80-9B7C-9FE6682B1A31}']
    function Parent: TFPDFExt;
    function OnHeader(APDFAdapter: TFPDFAdapterEvent): IFPDFAdapter;
    function OnFooter(APDFAdapter: TFPDFAdapterEvent): IFPDFAdapter;
    function SetFont(const AFamily: string; const AStyle: string; ASize: Double): IFPDFAdapter; overload;
    function SetFont(const AStyle: string): IFPDFAdapter; overload;
    function SetFont(const ASize: Double): IFPDFAdapter; overload;
    function BoldOn: IFPDFAdapter;
    function BoldOff: IFPDFAdapter;
    function Ln(const AHeight: Double = 0): IFPDFAdapter;
    function Cell(const AWidth: Double; AHeight: Double = 0; const AText: String = '';  const ABorder: String = '0';
      ALineBreak: Integer = 0; const AAlign: String = ''; AFill: Boolean = False; ALink: String = ''): IFPDFAdapter;
    function PageNo: Integer;
    procedure Generate;
  end;

  TFPDFAdapter = class(TInterfacedObject, IFPDFAdapter)
  private
    FPDF: TFPDFExt;
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
    function Parent: TFPDFExt;
    function OnHeader(APDFAdapter: TFPDFAdapterEvent): IFPDFAdapter;
    function OnFooter(APDFAdapter: TFPDFAdapterEvent): IFPDFAdapter;
    function SetFont(const AFamily: string; const AStyle: string; ASize: Double): IFPDFAdapter; overload;
    function SetFont(const AStyle: string): IFPDFAdapter; overload;
    function SetFont(const ASize: Double): IFPDFAdapter; overload;
    function BoldOn: IFPDFAdapter;
    function BoldOff: IFPDFAdapter;
    function Ln(const AHeight: Double = 0): IFPDFAdapter;
    function Cell(const AWidth: Double; AHeight: Double = 0; const AText: String = '';  const ABorder: String = '0';
      ALineBreak: Integer = 0; const AAlign: String = ''; AFill: Boolean = False; ALink: String = ''): IFPDFAdapter;
    function PageNo: Integer;
    procedure Generate;
  public
    class function New: IFPDFAdapter;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

class function TFPDFAdapter.New: IFPDFAdapter;
begin
  Result := Self.Create;
end;

constructor TFPDFAdapter.Create;
begin
  FPDF := TFPDFExt.Create;

  Self.SetDefaultValues;
  Self.ConfDirectories;
  Self.ConfPDFOnCreate;
end;

destructor TFPDFAdapter.Destroy;
begin
  FPDF.Free;
  inherited;
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
  Self.SetFont('Arial', '', 10);
end;

procedure TFPDFAdapter.SetDefaultValues;
begin
  FOpenAfterGenerating := True;
  FPageTitle := 'Relatório';
end;

function TFPDFAdapter.Parent: TFPDFExt;
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

function TFPDFAdapter.SetFont(const AFamily: String; const AStyle: String; ASize: Double): IFPDFAdapter;
begin
  Result := Self;
  FFamilyAtual := AFamily;
  FStyleAtual := AStyle;
  FSizeAtual := ASize;
  FPDF.SetFont(AFamily, AStyle, ASize);
end;

function TFPDFAdapter.SetFont(const ASize: Double): IFPDFAdapter;
begin
  Result := Self;
  Self.SetFont(FFamilyAtual, FStyleAtual, ASize);
end;

function TFPDFAdapter.SetFont(const AStyle: string): IFPDFAdapter;
begin
  Result := Self;
  Self.SetFont(FFamilyAtual, AStyle, FSizeAtual);
end;

function TFPDFAdapter.BoldOn: IFPDFAdapter;
begin
  Result := Self;
  Self.SetFont(FFamilyAtual, 'B', FSizeAtual);
end;

function TFPDFAdapter.BoldOff: IFPDFAdapter;
begin
  Result := Self;
  Self.SetFont(FFamilyAtual, '', FSizeAtual);
end;

function TFPDFAdapter.Ln(const AHeight: Double = 0): IFPDFAdapter;
begin
  Result := Self;
  FPDF.Ln(AHeight);
end;

function TFPDFAdapter.Cell(const AWidth: Double; AHeight: Double; const AText, ABorder: String; ALineBreak: Integer;
  const AAlign: String; AFill: Boolean; ALink: String): IFPDFAdapter;
begin
  Result := Self;
  FPDF.Cell(AWidth, AHeight, AText, ABorder, ALineBreak, AAlign, AFill, ALink);
end;

function TFPDFAdapter.PageNo: Integer;
begin
  Result := FPDF.PageNo;
end;

procedure TFPDFAdapter.Generate;
begin
  FPDF.AddPage;
  Self.SetFont('Arial', '', 8);

  Self.Ln.BoldON;
  FPDF.Cell(95, 4, Format('%s  %s %d', [FormatFloat('000000', 10), 'Cliente nome teste ', 10]), '1');

  FPDF.SaveToFile(FPathFilePDF);

  if FOpenAfterGenerating then
    ShellExecute(0, 'open', PChar(FPathFilePDF), nil, nil, SW_SHOWNORMAL);
end;

end.
