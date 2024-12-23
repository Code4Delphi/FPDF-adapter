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
    procedure PrintHeader(APDFAdapter: IFPDFAdapter);
    procedure PrintFooter(APDFAdapter: IFPDFAdapter);
    procedure AddTitle;
  public
    procedure Gerar;
  end;

var
  ColumnsReportObj: TColumnsReport;

procedure TColumnsReport.PrintHeader(APDFAdapter: IFPDFAdapter);
begin
  APDFAdapter.Cell(0, 13, '', 'TB');

  APDFAdapter.Ln(1);
  APDFAdapter.BoldOn;
  APDFAdapter.Cell(135, 3, 'Solusys Sistemas', '', 0, 'E');
  APDFAdapter.BoldOff.SetFont(8);
  APDFAdapter.Cell(0, 3, Format('%s  Pág.: %s', [DateTimeToStr(Now), APDFAdapter.PageNo.ToString]), '0', 0, 'R');

  APDFAdapter.Ln(4);
  APDFAdapter.Cell(135, 3, 'MDK Assistência, Suporte Técnico e Computadores LTDA', '', 0, 'E');
  APDFAdapter.BoldOff.SetFont(8);
  APDFAdapter.Cell(0, 3, Format('%s', ['Período: 19/12/2024 à 19/12/2024']), '0', 0, 'R');

  APDFAdapter.Ln(4);
  APDFAdapter.BoldOn;
  APDFAdapter.Cell(135, 3, 'Orçamentos / Pedidos', '', 0, 'E');
  APDFAdapter.BoldOff.SetFont(8);
  APDFAdapter.Cell(0, 3, Format('Total orç.: %d', [114]), '', 0, 'R');

  Self.AddTitle;
end;

procedure TColumnsReport.PrintFooter(APDFAdapter: IFPDFAdapter);
begin
  APDFAdapter.Parent.SetY(-15);
  APDFAdapter.SetFont('Arial','I',8);
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

  FFPDFAdapter.Generate;
end;

{CONSOLE}
begin
  ReportMemoryLeaksOnShutdown := True;

  ColumnsReportObj := TColumnsReport.Create;
  try
   ColumnsReportObj.Gerar;
  finally
    ColumnsReportObj.Free;
  end;

end.
