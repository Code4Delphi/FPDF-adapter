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
    FColCurrent: Integer;
    FMarginLeft: Double;
    FMarginBetweenCol: Double;
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
    procedure SetCol(const ACol: Integer);
    procedure AddTxtColumns;
    function TxtGrande: string;
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

  //FFPDFAdapter.Ln(5);
  Fy0 := FFPDFAdapter.Parent.GetY;
  //FFPDFAdapter.Parent.SetX(0);
end;

procedure TColumnsReport.PrintFooter(APDFAdapter: IFPDFAdapter);
begin
  //APDFAdapter.Parent.SetY(-15);
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
    .Cell(0, 5, Format('%s     %s', [TEXTO, TEXTO]), 'B');

  FFPDFAdapter.Ln(5);
end;

procedure TColumnsReport.PreencherDados;
var
  LNumOrcamento: Integer;
begin
  for LNumOrcamento := 1 to 20 do
  begin
    Self.PreencherDadosOrcamento(LNumOrcamento);
    Self.PreencherDadosOrcamentoItens(LNumOrcamento);
    //Self.PreencherTotaisOrcamento;
  end;
end;

procedure TColumnsReport.PreencherDadosOrcamento(const ANumOrcamento: Integer);
begin
  FFPDFAdapter.BoldON
    .Parent.MultiCell(94, 5, Format('%s - Cliente nome teste: %d', [FormatFloat('000000', ANumOrcamento), ANumOrcamento]), '1');
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

    FFPDFAdapter
      .Cell(12, 4, Format('%s', [FormatFloat('000000', LNumItem)]), 'BLR')
      .Cell(54, 4, Format('Teste produto orçamento %d item %d', [ANumOrcamento, LNumItem]), '1')
      .Cell(11, 4, Format('%d', [LNumItem]), 'BLR', 0, 'R')
      .Cell(17, 4, Format('%s', [FormatFloat(',,0.00', LTotal)]), 'BLR', 0, 'R')
      .Ln;

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
  FFPDFAdapter.AddPage;

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

procedure TColumnsReport.Gerar;
const
  MARGIN_RIGHT = 10;
var
  LMarginTotal: Double;
begin
  FColCurrent := 1;
  FColNumber := 2;
  FMarginLeft := 10;
  FMarginBetweenCol := 4;
  LMarginTotal := FMarginLeft + MARGIN_RIGHT; // {+ (Pred(FColNumber) * FMarginBetweenCol) } + MARGIN_RIGHT;

  FFPDFAdapter := TFPDFAdapter.New
    .OnAcceptPageBreak(AcceptPageBreak)
    .OnHeader(PrintHeader)
    //.OnFooter(PrintFooter)
    ;

  FColWidth := (FFPDFAdapter.Parent.GetPageWidth - LMarginTotal) / FColNumber;
  //FColWidth := FColWidth - (Pred(FColNumber) * FMarginBetweenCol);
  //FColWidth := Trunc(FColWidth);

  FFPDFAdapter.AddPage();

  //Self.AddTxtColumns;
  Self.PreencherDados;
  FFPDFAdapter.Ln();
  FFPDFAdapter.Generate;
end;

function TColumnsReport.AcceptPageBreak: Boolean;
begin
  Result := False;

  //Método que aceita ou não quebra de página automática
  if FColCurrent < FColNumber then
  begin
    // Go to next column
    Self.SetCol(Succ(FColCurrent));
    FFPDFAdapter.Parent.SetY(Fy0);
    //Result := False;
  end
  else
  begin
    FFPDFAdapter.AddPage;
    Self.SetCol(1);
    // Page break
    //Result := True
  end;
end;

procedure TColumnsReport.SetCol(const ACol: Integer);
var
  LX: Double;
begin
  FColCurrent := ACol;
  //LX := (ACol * FColWidth) + FMarginLeft; //65 (FColWidth + 5)

  LX := (Pred(ACol) * FColWidth) + FMarginLeft; //65 (FColWidth + 5)

//  if ACol > 0 then
//    LX := LX + FMarginBetweenCol;

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
