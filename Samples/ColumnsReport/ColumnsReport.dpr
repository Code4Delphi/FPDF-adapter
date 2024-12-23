program ColumnsReport;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  FPDF.adapter in '..\..\Src\FPDF.adapter.pas';

type
  TColumnsReport = class
  private
    FFPDFAdapter: IFPDFAdapter;
    FTotalOrc: Double;
    procedure PrintHeader(APDFAdapter: IFPDFAdapter);
    procedure PrintFooter(APDFAdapter: IFPDFAdapter);
    procedure AddTitle;
    procedure PreencherDados;
    procedure PreencherDadosOrcamento(const ANumOrcamento: Integer);
    procedure PreencherDadosOrcamentoItens(const ANumOrcamento: Integer);
    procedure PreencherTotaisOrcamento;
  public
    procedure Gerar;
  end;

var
  ColumnsReportObj: TColumnsReport;

procedure TColumnsReport.PrintHeader(APDFAdapter: IFPDFAdapter);
begin
  APDFAdapter
    .Cell(0, 13, '', 'TB')
    .Ln(1)
    .BoldOn
    .CellLeft(135, 3, 'Solusys Sistemas')
    .BoldOff
    .Font(8)
    .CellRight(0, 3, Format('%s  Pág.: %s', [DateTimeToStr(Now), APDFAdapter.PageNo.ToString]))

    .Ln(4)
    .CellLeft(135, 3, 'MDK Assistência, Suporte Técnico e Computadores LTDA')
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
end;

procedure TColumnsReport.PrintFooter(APDFAdapter: IFPDFAdapter);
begin
  APDFAdapter.Parent.SetY(-15);
  APDFAdapter.Font('Arial','I',8);
  APDFAdapter.Parent.SetTextColor(128);
  APDFAdapter.Cell( 0, 10, 'Page '+IntToStr(APDFAdapter.PageNo()), '0', 0, 'C');
end;

procedure TColumnsReport.AddTitle;
const
  TEXTO = 'Código    Produto                                                        Qtd           Vlr. unit.';
begin
  FFPDFAdapter
    .Ln(4)
    .BoldOn
    .Cell(0, 5, Format('%s     %s', [TEXTO, TEXTO]), 'B');
end;

procedure TColumnsReport.Gerar;
begin
  FFPDFAdapter := TFPDFAdapter.New
    .OnHeader(PrintHeader)
    .OnFooter(PrintFooter);

  FFPDFAdapter.AddPage;
  Self.PreencherDados;
  FFPDFAdapter.Generate;
end;

procedure TColumnsReport.PreencherDados;
var
  LNumOrcamento: Integer;
begin
  for LNumOrcamento := 1 to 15 do
  begin
    Self.PreencherDadosOrcamento(LNumOrcamento);
    Self.PreencherDadosOrcamentoItens(LNumOrcamento);
    Self.PreencherTotaisOrcamento;
  end;
end;

procedure TColumnsReport.PreencherDadosOrcamento(const ANumOrcamento: Integer);
begin
  FFPDFAdapter.Ln.BoldON
    .Cell(95, 4, Format('%s  %s %d', [FormatFloat('000000', ANumOrcamento), 'Cliente nome teste ', ANumOrcamento]), '1');
end;

procedure TColumnsReport.PreencherDadosOrcamentoItens(const ANumOrcamento: Integer);
var
  LNumItem: Integer;
  LTotal: Double;
begin
  FFPDFAdapter.BoldOFF;
  for LNumItem := 1 to 4 do
  begin
    LTotal := LNumItem * 10;

    FFPDFAdapter.Ln
      .Cell(12, 4, Format('%s', [FormatFloat('000000', LNumItem)]), 'BLR')
      .Cell(54, 4, Format('%s %d', ['Produto teste ', LNumItem]), '1')
      .Cell(12, 4, Format('%d', [LNumItem]), 'BLR', 0, 'R')
      .Cell(17, 4, Format('%s', [FormatFloat(',,0.00', LTotal)]), 'BLR', 0, 'R');

    FTotalOrc := FTotalOrc +  LTotal;
  end;
end;

procedure TColumnsReport.PreencherTotaisOrcamento;
begin
  FFPDFAdapter.BoldOn.Ln
    .Cell(95, 4, Format('%s', [FormatFloat(',,0.00', FTotalOrc)]), '1', 0, 'R');
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
