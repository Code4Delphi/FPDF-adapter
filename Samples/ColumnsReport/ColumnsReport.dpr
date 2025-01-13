program ColumnsReport;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  FPDF.adapter in '..\..\Src\FPDF.adapter.pas';

type
  TColumnsReport = class
  private
    const
      COL_HEIGHT = 4;
  private
    FFPDFAdapter: IFPDFAdapter;
    FColNumber: Integer;
    FColWidth: Double;
    FColCurrent: Integer;
    FMarginLeft: Double;
    Fy0: Double;
    FTotalOrc: Double;
    FTotalGeral: Double;
    procedure PrintHeader(APDFAdapter: IFPDFAdapter);
    procedure PrintFooter(APDFAdapter: IFPDFAdapter);
    function AcceptPageBreak: Boolean;
    procedure AddTitle;
    procedure PreencherDados;
    procedure PreencherDadosOrcamento(const ANumOrcamento: Integer);
    procedure PreencherDadosOrcamentoItens(const ANumOrcamento: Integer);
    procedure PreencherTotaisOrcamento;
    procedure SetCol(const ACol: Integer);
    procedure PreencherTotalGeral;
  public
    procedure Gerar;
  end;

var
  ColumnsReportObj: TColumnsReport;

procedure TColumnsReport.PrintHeader(APDFAdapter: IFPDFAdapter);
begin
  FFPDFAdapter.Parent.SetLeftMargin(FMarginLeft);
  FFPDFAdapter.Parent.SetX(FMarginLeft);

  APDFAdapter
    .Cell(0, 13, '', 'TB')
    .Ln(1)
    .BoldOn
    .CellLeft(135, 3, 'Nome fantasia do sistemas')
    .BoldOff
    .Font(8)
    .CellRight(0, 3, Format('%s  Pág.: %s', [DateTimeToStr(Now), APDFAdapter.PageNo.ToString]))

    .Ln(4)
    .CellLeft(135, 3, 'Razão social da empresa logada LTDA')
    .BoldOff
    .Font(8)
    .CellRight(0, 3, 'Período: 19/12/2024 à 19/12/2024')

    .Ln(4)
    .BoldOn
    .CellLeft(135, 3, 'Orçamentos / Pedidos')
    .BoldOff
    .Font(8)
    .CellRight(0, 3, Format('Total orç.: %d', [114]));

  Self.AddTitle;

  Fy0 := FFPDFAdapter.Parent.GetY;
end;

procedure TColumnsReport.PrintFooter(APDFAdapter: IFPDFAdapter);
begin
  APDFAdapter.Parent.SetY(0);
  APDFAdapter.Font('Arial','I',8);
  APDFAdapter.Parent.SetTextColor(128);
  APDFAdapter.Cell(0, 10, 'Page '+IntToStr(APDFAdapter.PageNo()), '0', 0, 'C');
end;

procedure TColumnsReport.AddTitle;
const
  TEXTO = 'Código    Produto                                                        Qtd           Vlr. unit.';
begin
  FFPDFAdapter
    .Ln(4)
    .BoldOn
    .Cell(0, COL_HEIGHT, Format('%s     %s', [TEXTO, TEXTO]), 'B');

  FFPDFAdapter.Ln(5);
end;

procedure TColumnsReport.PreencherDados;
var
  LNumOrcamento: Integer;
begin
  for LNumOrcamento := 1 to 120 do
  begin
    Self.PreencherDadosOrcamento(LNumOrcamento);
    Self.PreencherDadosOrcamentoItens(LNumOrcamento);
    Self.PreencherTotaisOrcamento;
  end;

  Self.PreencherTotalGeral;
end;

procedure TColumnsReport.PreencherDadosOrcamento(const ANumOrcamento: Integer);
begin
  FTotalOrc := 0;

  FFPDFAdapter.BoldON
    .Parent.MultiCell(94, COL_HEIGHT, Format('%s - Cliente nome teste: %d', [FormatFloat('000000', ANumOrcamento), ANumOrcamento]), '1'); //TRL
end;

procedure TColumnsReport.PreencherDadosOrcamentoItens(const ANumOrcamento: Integer);
var
  LContItens: Integer;
  LNumItem: Integer;
  LTotal: Double;
begin
  FFPDFAdapter.BoldOFF;

  Randomize;
  LNumItem := Random(20);
  if LNumItem <= 0 then
    LNumItem := 5;

  for LContItens := 1 to LNumItem do
  begin
    LTotal := LContItens * 10;

    FFPDFAdapter
      .Cell(12, COL_HEIGHT, Format('%s', [FormatFloat('000000', LContItens)]), '1')
      .Cell(54, COL_HEIGHT, Format('Teste produto orçamento %d item %d', [ANumOrcamento, LContItens]), '1')
      .Cell(11, COL_HEIGHT, Format('%d', [LContItens]), '1', 0, 'R')
      .Cell(17, COL_HEIGHT, Format('%s', [FormatFloat(',,0.00', LTotal)]), '1', 0, 'R')
      .Ln;

    FTotalOrc := FTotalOrc + LTotal;
  end;

  FTotalGeral := FTotalGeral + FTotalOrc;
end;

procedure TColumnsReport.PreencherTotaisOrcamento;
begin
  FFPDFAdapter.BoldOn
    .Parent.MultiCell(94, COL_HEIGHT, Format('%s', [FormatFloat(',,0.00', FTotalOrc)]), '1', 'R');
end;

procedure TColumnsReport.PreencherTotalGeral;
begin
  FFPDFAdapter.BoldOn
    .Parent.MultiCell(94, COL_HEIGHT, Format('Total geral: %s', [FormatFloat(',,0.00', FTotalGeral)]), '1', 'R');
end;

procedure TColumnsReport.Gerar;
const
  MARGIN_RIGHT = 10;
var
  LMarginTotal: Double;
begin
  FTotalGeral := 0;
  FColCurrent := 1;
  FColNumber := 2;
  FMarginLeft := 10;
  LMarginTotal := FMarginLeft + MARGIN_RIGHT;

  FFPDFAdapter := TFPDFAdapter.New
    .OnAcceptPageBreak(AcceptPageBreak)
    .OnHeader(PrintHeader)
    //.OnFooter(PrintFooter)
    ;

  FColWidth := (FFPDFAdapter.Parent.GetPageWidth - LMarginTotal) / FColNumber;
  FFPDFAdapter.AddPage();
  Self.PreencherDados;
  FFPDFAdapter.Ln();
  FFPDFAdapter.Generate;
end;

function TColumnsReport.AcceptPageBreak: Boolean;
begin
  Result := False;

  //METODO QUE ACEITA OU NAO QUEBRA DE PAGINA AUTOMATICA
  if FColCurrent < FColNumber then
  begin
    //GO TO NEXT COLUMN
    Self.SetCol(Succ(FColCurrent));
    FFPDFAdapter.Parent.SetY(Fy0);
    //Result := False;
  end
  else
  begin
    FFPDFAdapter.AddPage;
    Self.SetCol(1);
    //PAGE BREAK
    //Result := True
  end;
end;

procedure TColumnsReport.SetCol(const ACol: Integer);
var
  LX: Double;
begin
  FColCurrent := ACol;
  LX := (Pred(ACol) * FColWidth) + FMarginLeft;
  FFPDFAdapter.Parent.SetLeftMargin(LX);
  FFPDFAdapter.Parent.SetX(LX);
end;

{CONSOLE}
begin
  ReportMemoryLeaksOnShutdown := True;

  ColumnsReportObj := TColumnsReport.Create;
  try
   try
     ColumnsReportObj.Gerar;
   except
     on E: Exception do
     begin
       Writeln('Ocorreu um erro: ' + E.Message);
       Readln;
     end;
   end;
  finally
    ColumnsReportObj.Free;
  end;
end.
