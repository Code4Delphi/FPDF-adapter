program ColumnsReport;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  FPDF.adapter in '..\..\Src\FPDF.adapter.pas';

var
  PDF: IFPDFAdapter;

procedure PrintHeader(APDFAdapter: IFPDFAdapter);
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

  //APDFAdapter.AddTitle;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  PDF := TFPDFAdapter.New
    .OnHeader(PrintHeader);

  PDF.Generate;

end.
