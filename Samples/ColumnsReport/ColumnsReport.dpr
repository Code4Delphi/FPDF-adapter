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
    FColNumber: Integer;
    FColWidth: Double;
    FColCurrent: Double;
    FColMarginLeft: Double;
    Fy0: Double;
    FTotalOrc: Double;
    procedure PrintHeader(APDFAdapter: IFPDFAdapter);
    procedure PrintFooter(APDFAdapter: IFPDFAdapter);
    function AcceptPageBreak: Boolean;
    procedure AddTitle;
    procedure PreencherDados;
    procedure PreencherDadosOrcamento(const ANumOrcamento: Integer);
    procedure PreencherDadosOrcamentoItens(const ANumOrcamento: Integer);
    procedure PreencherTotaisOrcamento;
    procedure SetCol(const Acol: Double);
    procedure AddTxtColumns;
    function TxtGrande: string;
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

  //Self.AddTitle;

  Fy0 := FFPDFAdapter.Parent.GetY();
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

function TColumnsReport.AcceptPageBreak: Boolean;
begin
  Result := False;

  // Method accepting or not automatic page break
  if FColCurrent < Pred(FColNumber) then
  begin
    // Go to next column
    Self.SetCol(FColCurrent + 1);
    // Set ordinate to top
    FFPDFAdapter.Parent.SetY(Fy0);
    // Keep on page
    //Result := False;
  end
  else
  begin
    //**
    FFPDFAdapter.AddPage();
    //**

    // Go back to first column
    Self.SetCol(0);
    // Page break
    //Result := True
  end;
end;

procedure TColumnsReport.SetCol(const Acol: Double);
var
  LX: Double;
begin
  // Set position at a given column
  FColCurrent := ACol;
  LX := FColMarginLeft + ACol * FColWidth; //65 (FColWidth + 5)
  FFPDFAdapter.Parent.SetLeftMargin(LX);
  FFPDFAdapter.Parent.SetX(LX);
end;

procedure TColumnsReport.Gerar;
var
  LMarginTotal: Double;
begin
  FColNumber := 2;
  FColMarginLeft := 12;
  LMarginTotal := (Pred(FColNumber) * FColMarginLeft) + 10; //Self.rMargin;
  //FColWidth := (Self.GetPageWidth - LMarginTotal) / FColNumber;
  FColCurrent := 0;

  FFPDFAdapter := TFPDFAdapter.New
    //.OnHeader(PrintHeader)
    //.OnFooter(PrintFooter)
    .OnAcceptPageBreak(AcceptPageBreak)
    ;

  FColWidth := (FFPDFAdapter.Parent.GetPageWidth - LMarginTotal) / FColNumber;
  //FColWidth := Trunc(FColWidth);

  //FFPDFAdapter.AddPage();
  Self.AddTxtColumns;
  //Self.PreencherDados;
  FFPDFAdapter.Ln();
  FFPDFAdapter.Generate;
end;

procedure TColumnsReport.PreencherDados;
var
  LNumOrcamento: Integer;
begin
  for LNumOrcamento := 1 to 150 do
  begin
    Self.PreencherDadosOrcamento(LNumOrcamento);
    //Self.PreencherDadosOrcamentoItens(LNumOrcamento);
    //Self.PreencherTotaisOrcamento;
  end;
end;

procedure TColumnsReport.PreencherDadosOrcamento(const ANumOrcamento: Integer);
begin
//  FFPDFAdapter.Ln.BoldON
//    .Cell(95, 4, Format('%s  %s %d', [FormatFloat('000000', ANumOrcamento), 'Cliente nome teste ', ANumOrcamento]), '1');

  FFPDFAdapter.BoldON
    .Parent.MultiCell(95, 5, Format('%s  %s %d', [FormatFloat('000000', ANumOrcamento), 'Cliente nome teste ', ANumOrcamento]), '1');
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
      .Cell(54, 4, Format('Teste produto orçamento %d item %d', [ANumOrcamento, LNumItem]), '1')
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

procedure TColumnsReport.AddTxtColumns;
var
  LTxt: string;
begin
  FFPDFAdapter.AddPage();

  // Title
  FFPDFAdapter.Font('Arial', '', 12);
  FFPDFAdapter.Parent.SetFillColor(200, 220, 255);
  FFPDFAdapter.Cell(0, 6, 'Chapter: ' + FColCurrent.ToString, '0', 1, 'L', true);
  FFPDFAdapter.Ln(4);
  // Save ordinate
  Fy0 := FFPDFAdapter.Parent.GetY();

  //**
  LTxt := Self.TxtGrande;
  FFPDFAdapter.Font('Times', '', 12);
  // Output text in a 6 cm width column
  FFPDFAdapter.Parent.MultiCell(FColWidth, 5, LTxt);
  FFPDFAdapter.Ln();

  FFPDFAdapter.Font('I');
  FFPDFAdapter.Cell(0, 5, '(end of excerpt)');
  // Go back to first column
  Self.SetCol(0);
end;

//var
//  LTxt: string;
//begin
//  LTxt := Self.TxtGrande;
//  FFPDFAdapter.Font('Times', '', 12);
//  // Output text in a 6 cm width column
//  FFPDFAdapter.Parent.MultiCell(FColWidth, 5, LTxt);
//  FFPDFAdapter.Ln();
//
//  FFPDFAdapter.Font('I');
//  FFPDFAdapter.Cell(0, 5, '(end of excerpt)');
//  // Go back to first column
//  Self.SetCol(0);
//end;

function TColumnsReport.TxtGrande: string;
begin
  Result :=
  '''
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam elit nisi, ultrices ut nulla eget, mattis volutpat tortor. Sed a libero ornare, ultrices leo sit amet, condimentum enim.
  Quisque a fringilla purus. In semper mauris augue, id aliquam libero vestibulum sed. Nullam porttitor quam mi, ut gravida libero aliquet sed. Sed convallis mi et pellentesque tincidunt.
  Phasellus sem eros, pharetra nec tincidunt vel, sagittis ac nibh. Nam lorem massa, congue nec tempor tincidunt, elementum scelerisque nisi.

  Vestibulum fringilla pretium ultrices. Curabitur gravida tempus nunc, nec semper magna euismod ac. Integer molestie, nunc eu sodales iaculis, augue risus elementum libero, a sagittis
  turpis nibh sed mi. Maecenas lobortis metus quis maximus ullamcorper. Integer fermentum mollis egestas. Duis tristique congue sem ac faucibus. Etiam sed nulla nec ante faucibus faucibus.
  Aliquam in felis quis lacus maximus efficitur.

  Aenean lobortis libero metus, tempor fringilla ligula rhoncus placerat. Nullam ut maximus metus, sit amet tincidunt elit. Vivamus nec nisi scelerisque, suscipit quam eu, iaculis enim.
  Integer vulputate eros magna, in sagittis elit eleifend eu. Curabitur non dui ut nulla aliquet mollis. Phasellus et turpis nec tortor elementum efficitur sit amet eget diam. Nunc non orci
  placerat, placerat arcu scelerisque, maximus quam. Vestibulum et nunc et justo ullamcorper bibendum. Nunc ac eros id turpis suscipit fermentum ac lobortis ipsum. Suspendisse potenti.
  Proin ac ipsum elit. Proin semper justo non bibendum efficitur. Cras gravida felis orci, non commodo enim porttitor quis. Suspendisse ut fermentum nulla.
  ''';

  Result := Result + Result + Result;
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
