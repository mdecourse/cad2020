Unit LibPlots;
{ $R+ }
{ $S- }
{=============================================================================
  Unit for generating 2D plots similar to D_2D
  (c) P.A. Simionescu 2018
=============================================================================}

INTERFACE

uses  LibInOut,LibMath;

const IsoPlot = TRUE;  {isotropic plot}
      FitBox  = FALSE; {non-isotropic plot}

var   ColorCode: Boolean;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure PlotTitle(Title:St50);
procedure NewPlot(Pln:Byte; Iso_Fit:Boolean; x1,y1,x2,y2:Word; Title:St50);

procedure UpdateLimitsX(Pln:Byte; vX:VDp; nPts:Word); {update Xmin,Xmax  }
procedure UpdateLimitsY(Pln:Byte; vY:VDp; nPts:Word); {update Ymin,Ymax  }

procedure ResizeX(Pln:Byte; kX:single); {resize Xmin & Xmax by factor k}
procedure Resizey(Pln:Byte; kY:single); {resize Ymin & Ymax by factor k}

function  GetXmin(Pln:Byte): double; {returns Xmin[Pln] }
function  GetXmax(Pln:Byte): double; {returns Xmax[Pln] }
procedure NewLimitsX(Pln:Byte; X_min,X_max: double); {set Xmin and Xmax}

function  GetYmin(Pln:Byte): double; {returns Ymin[Pln] }
function  GetYmax(Pln:Byte): double; {returns Ymax[Pln] }
procedure NewLimitsY(Pln:Byte; Y_min,Y_max: double); {set Ymin and Ymax}

procedure SetDivLine(Lout,Lin,Coef: single);
procedure GetDivLine(var Lout,Lin,Coef: single);
procedure SetDigitsDivs(Wid_Nr: Byte);
function  GetNoDigitsDivs: Byte;
procedure NiceDivs(min,max:double; var DV:double; var nVal:Byte; nValMax:Byte);

procedure DivL(XA,YA, XB,YB:double; nDiv:Byte; Alpha,Out_,In_:double);

procedure DivLT(XA,YA,XB,YB, valA,valB:double; nV,nDinT:Byte;
          ChOfs,Alpha:single; var PixOfsX:single);

procedure DivLV(XA,YA,XB,YB, valA,valB,D_val:double; nDinT:Byte;
          ChOfs,Alpha:single;  var PixOfsX:single);

procedure DXFScanLine(Pln:Byte);
procedure DXFScanPoint(Pln:Byte);
procedure PlotCurve(Pln:Byte; X,Y:VDp; nPts:Word; Color:Integer);

procedure SetMarker(M_Size:single;  M_Type:st02);

procedure PlotXaxis(Pln:Byte; Down0Up, nVal,nDiv:Byte; xLabel:st20);
procedure PlotYaxis(Pln:Byte; Lft0Rght,nVal,nDiv:Byte; yLabel:st20);

procedure PlotScanLine(Pln:Byte; X:double; MS:Integer);
procedure PlotScanPoint(Pln:Byte; X,Y:double; MS:Integer);

procedure Arc3pts(x1,y1,x2,y2,x3,y3:double);
procedure ArrowH(XA,YA,XB,YB:double; AC,Alpha:single);
procedure ArrowS(XA,YA,XB,YB:double; k,Alpha:single);
procedure Arrow(XA,YA,XB,YB:double; AC,Alpha:single);

procedure Point(Xp,Yp:double; PtSze: single; PTtype:ShortInt);
procedure Point1a(Xp,Yp:double; PtSze: single; PtLabel:St06);
{----------------------------------------------------------------------------}

IMPLEMENTATION

uses  CRT,Graph,LibGraph,LibGe2D,LibDXF;

type  D4 = array[1..4] of double;
      W4 = array[1..4] of Word;
      B4 = array[1..4] of Boolean;

var  Xmin, Xmax,      {limits over X axis for the at-most 4 plots}
     Ymin, Ymax: D4;  {limits over Y axis for the at-most 4 plots}
     xs1,ys1,
     xs2,ys2: W4;     {screen corners of the plot}
     FreezeXYLimits,  {TRUE = curve or one axis already drawn}
     IsoFit: B4;      {plot is isotropic or fits the blot box}

     Lout_,Lin_,       {lengths of outer and inner division lines }
     MarkSize,         {marker size in PlotXYaxes                            }
     Coef_: single;    {_Lout*_Coef - length of division lines between values}
     XYGraphCalls,     {no. of calls of PlotCurve and of DXF polylines       }
     WidNr,            {number of digits in the division numbers             }
     MarkType:Byte;    {marker type in PlotXYaxes                            }
     PutDXFScanLine,   {Put a scan line in DXF to be animated with M3D.LSP   }
     PutDXFScanPoint,  {Put a scan point in DXF to be animated with M3D.LSP  }
     TitleON,          {TRUE = do not duplicate title in the DXF file        }
     MarkScat:Boolean; {TRUE = scatter marker (default)                      }

     FillSettings_L: FillSettingsType;
     LineSettings_L: LineSettingsType;

     Color_L,
     LastCurvesColor: Word;

{============================================================================}
procedure PlotTitle(Title:St50); {Write Title on top of ViewPort..}
var ViewPort_L: ViewPortType;
    OldD_X_F  : Boolean;

BEGIN
  OldD_X_F:=D_X_F;
  if TitleON then SuspendDXF;
  Color_L:=GetColor;
  SetColorBGI_DXF(MaxColor);
  MySetTextStyle(SmallFont, HorizDir,1, TRUE);
  SetTextJustify(CenterText, TopText);
  GetViewSettings(ViewPort_L);
  with ViewPort_L do PDtext('',(x2-x1) DIV 2,0, 1.45,0, Title);
  SetColorBGI_DXF(Color_L);
  TitleON:=TRUE;
  if OldD_X_F then ResumeDXF;
END; {.. PlotTitle}

{----------------------------------------------------------------------------}
procedure NewPlot(Pln:Byte; Iso_Fit:Boolean; x1,y1,x2,y2:Word; Title:St50);

BEGIN
  FreezeXYLimits[Pln]:=FALSE;
  xs1[Pln]:=x1;
  ys1[Pln]:=y1;
  xs2[Pln]:=x2;
  ys2[Pln]:=y2;
  IsoFit[Pln]:=Iso_Fit;
  SetViewPort(x1,y1, x2,y2, ClipOn); {The plot will fit this view port..}
  Obj2Scr(Iso_Fit, -1.0,1.0, -1.0,1.0);
  PlotTitle(Title);
END; {..NewPlot2D}

{----------------------------------------------------------------------------}
procedure UpdateLimitsX(Pln:Byte; vX:VDp; nPts:Word); {update Xmin & Xmax}
var i: Word;
BEGIN {UpdateLimitsX..}
  if FreezeXYLimits[Pln] then Exit;
  for i:=1 to nPts do BEGIN
    if (vX[i] < Xmin[Pln]) then Xmin[Pln]:=vX[i];
    if (vX[i] > Xmax[Pln]) then Xmax[Pln]:=vX[i];
  END;
  if (Xmin[Pln] = Xmax[Pln]) then BEGIN
    Xmin[Pln]:=Xmin[Pln]-Max2(Xmin[Pln],1.0);
    Xmax[Pln]:=Xmax[Pln]+Max2(Xmax[Pln],1.0);
  END;
END; {..UpdateLimitsXy}

{----------------------------------------------------------------------------}
procedure UpdateLimitsY(Pln:Byte; vY:VDp; nPts:Word); {update Ymin,Ymax}
var i: Word;
BEGIN {UpdateLimitsY..}
  if FreezeXYLimits[Pln] then Exit;
  for i:=1 to nPts do BEGIN
    if (vY[i] < Ymin[Pln]) then Ymin[Pln]:=vY[i];
    if (vY[i] > Ymax[Pln]) then Ymax[Pln]:=vY[i];
  END;
  if (Ymin[Pln] = Ymax[Pln]) then BEGIN
    Ymin[Pln]:=Ymin[Pln]-Max2(Ymin[Pln],1.0);
    Ymax[Pln]:=Ymax[Pln]+Max2(Ymax[Pln],1.0);
  END;
END; {..UpdateLimitsXy}

{----------------------------------------------------------------------------}
procedure ResizeX(Pln:Byte; kX:single); {resize Xmin & Xmax by factor kX}
var Aux: double;
BEGIN
  Aux:=kX*(Xmax[Pln]-Xmin[Pln]);
  Xmin[Pln]:=
   RoundNice(Xmin[Pln]-Aux,Xmin[Pln]-0.5*Aux,Xmin[Pln],WidNr);
  Xmax[Pln]:=
   RoundNice(Xmax[Pln],Xmax[Pln]+0.5*Aux,Xmax[Pln]+Aux,WidNr);
END; {..ResizeX}

{----------------------------------------------------------------------------}
procedure ResizeY(Pln:Byte; kY:single); {resize Xmin & Xmax by factor kY}
var Aux: double;
BEGIN
  Aux:=kY*(Ymax[Pln]-Ymin[Pln]);
  Ymin[Pln]:=RoundNice(Ymin[Pln]-Aux,Ymin[Pln]-0.5*Aux,Ymin[Pln], WidNr);
  Ymax[Pln]:=RoundNice(Ymax[Pln],Ymax[Pln]+0.5*Aux,Ymax[Pln]+Aux, WidNr);
END; {..ResizeX}

{----------------------------------------------------------------------------}
function GetXmin(Pln: Byte): double; {returns Xmin}
BEGIN
  GetXmin:=Xmin[Pln];
END; {..GetXmin}

{----------------------------------------------------------------------------}
function GetXmax(Pln: Byte): double; {returns Xmax..}
BEGIN
  GetXmax:=Xmax[Pln];
END; {..GetXmax}

{----------------------------------------------------------------------------}
function GetYmin(Pln: Byte): double; {returns Ymin..}
BEGIN
  GetYmin:=Ymin[Pln];
END; {..GetYmin}

{----------------------------------------------------------------------------}
function GetYmax(Pln: Byte): double; {returns Ymax..}
BEGIN
  GetYmax:=Ymax[Pln];
END; {..GetYmax}

{----------------------------------------------------------------------------}
procedure NewLimitsX(Pln:Byte; X_min,X_max:double); {sets Xmin and Xmax}
BEGIN
  Xmin[Pln]:=X_min;
  Xmax[Pln]:=X_max;
END; {..NewLimitsX}

{----------------------------------------------------------------------------}
procedure NewLimitsY(Pln:Byte; Y_min,Y_max:double); {sets Ymin and Ymax}
BEGIN
  Ymin[Pln]:=Y_min;
  Ymax[Pln]:=Y_max;
END; {..NewLimitsY}

{----------------------------------------------------------------------------}
procedure SetDivLine(Lout,Lin, Coef: single);
{ Set the outside and inside lengths of the major division line.             }
{ Minor division line has Lout*Coef outside length and same inside length Lin}

BEGIN
  Lout_ := Lout;
  Lin_  := Lin;
  Coef_ := Coef;
END; {..SetDivLine}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure GetDivLine(var Lout,Lin,Coef: single);
{ Get the outside and inside lengths and Coef of the division lines          }
BEGIN
  Lout := Lout_;
  Lin  := Lin_;
  Coef := Coef_;
END; {..GetDivLine}

{----------------------------------------------------------------------------}
procedure SetDigitsDivs(Wid_Nr: Byte);
{ Set the number of digits in the divisions values output by DivLT, DivLV    }
BEGIN
  WidNr:=Wid_Nr;
END; {..SetDigitsDivs}

{----------------------------------------------------------------------------}
function GetNoDigitsDivs: Byte;
{ Get the number of digits in the divisions values output by DivLT, DivLV    }
BEGIN
  GetNoDigitsDivs:=WidNr;
END; {..GetNoDigitsDivs}

{----------------------------------------------------------------------------}
procedure NiceDivs(min,max:double; var DV:double; var nVal:Byte; nValMax:Byte);
{ Make the divisions and values nicely assorted                              }
BEGIN
  if (nVal < 2) OR (nVal > nValMax) then nVal:=nValMax DIV 2;
  DV:=Abs(max-min);
  if (nVal = 2) then Exit;
  DV:=RoundNice(DV/(nVal-0.5),DV/(nVal-1),DV/(nVal-1.5), WidNr);
END; {..NiceDivs}

{----------------------------------------------------------------------------}
procedure DivL(XA,YA, XB,YB:double; nDiv:Byte; Alpha,Out_,In_:double);
{Draw nDivA equaly spaced segments transverse to A-B at angle Alpha (in RAD) }

{Out_ and In_ are the lengths on the positive and negative sides of Alpha}

var  X0,Y0,X1,Y1,X2,Y2:double;
     cA,sA:double; {cos(Alpha) sin(Alpha)}
     i:Byte;

BEGIN {DivL..}
  if (Alpha = InfD) then Exit;
  GetLineSettings(LineSettings_L);
  cA:=cos(Alpha);  sA:=sin(Alpha);
  if (Sqr(XA-XB)+Sqr(YA-YB) > 0.0) AND (nDIV > 1) then BEGIN
    nDIV:=nDIV-1;
    i:=0;
    for i:=0 to nDiv do BEGIN
      X0:=XA+(XB-XA)/nDIV*i;           Y0:=YA+(YB-YA)/nDIV*i;
      X1:=XA+(XB-XA)/nDIV*i+Out_*cA;   Y1:=YA+(YB-YA)/nDIV*i+Out_*sA;
      X2:=XA+(XB-XA)/nDIV*i-In_*cA;    Y2:=YA+(YB-YA)/nDIV*i-In_*sA;
      if ColorCode then BEGIN
        SetColor(ScaleColor(0,Sqrt(Sqr(XA-XB)+Sqr(YA-YB)), Sqrt(Sqr(XA-X0)+Sqr(YA-Y0))));
        ScaleColorDXF(0,Sqrt(Sqr(XA-XB)+Sqr(YA-YB)), Sqrt(Sqr(XA-X0)+Sqr(YA-Y0)))
      END;
      if (In_ > 4) then BEGIN {grid lines inside..}
{       if (((i > 0) AND (i < nDIV))) then BEGIN }
        if (i > 0) then BEGIN
          if (nDIV > 127) then
           SetLineStyle(SolidLn, 0, ThickWidth)
          else
           SetLineStyle(DottedLn, 0, NormWidth);
          SyncDXFLineStyleTkns;
          PD_line('_Grid_Lines',X0,Y0,X2,Y2);
        END;
        SetLineStyle(SolidLn, 0, NormWidth); SyncDXFLineStyleTkns;
        PD_line('_Divissions',X1,Y1,X0,Y0);
      END
      else PD_line('_Divissions',X1,Y1,X2,Y2);
    END;
  END;
  with LineSettings_L do BEGIN
    SetLineStyle(LineStyle,Pattern,Thickness);   SyncDXFLineStyleTkns;
  END;
  SetColorBGI_DXF(MaxColor);

END; {..DivL}

{----------------------------------------------------------------------------}
procedure DivLT(XA,YA,XB,YB, valA,valB:double; nV,nDinT:Byte;
          ChOfs,Alpha:single; var PixOfsX:single);
{divisions aligned at ends..}
{Write nV equidistant values within [valA..valB] along A-B, ofset with ChOfs }
{character-widths of the current text style. Between 2 such values draw nDinT}
{minor division lines of length Coef_*Lout_-Lin_.   Alpha [RAD] is the angle }
{from A-B to the outer division segment.  PixOfsX (+/-) returns the maximum  }
{offset in pixels from the axis line in the x direction.                     }

var S:St12;
    eOR_,     {E number or negative number prompter}
    NewWidNr, {adjusted WidNr from the one defined at the bottom of this program}
    i: Byte;
    X0,Y0,    {intersection of division line with ³AB³}
    X1,Y1,    {outside end of division line           }
    X2,Y2,    {inside end of division line            }
    cA,sA,    {cos(Alpha) sin(Alpha)                  }
    Aux,      {a current value within [valA..valB]    }
    Eps: double; {an almost zero value                   }

BEGIN {DivLT..}
  if (nV < 2) then Exit;
  if (Sqr(XA-XB)+Sqr(YA-YB) = 0.0) then Exit;
  if (Alpha = InfD) then Exit;

  if (valA > valB) then BEGIN  {make sure valA < valB..}
    Aux:=valA;  valA:=valB;  valB:=Aux;
    Aux:=XA;    XA:=XB;      XB:=Aux;
    Aux:=YA;    YA:=YB;      YB:=Aux;
  END;

  Aux:=(ValB-ValA)/(nV*nDinT+1.0);
  cA:=Abs(Aux-MyVal(MySt(Aux,WidNr)));  {..secondary use of variable cA!}
  nV:=nV-1;
  Aux:=(ValB-ValA)/(nV*nDinT+1);
  sA:=Abs(Aux-MyVal(MySt(Aux,WidNr)));  {..secondary use of variable sA!}
  Eps:=Max2(cA,sA);  {..Eps = almost zero taylored to [ValA..ValB] interval}

  cA:=cos(Alpha);
  sA:=sin(Alpha);

  NewWidNr:=0;
  for i:=0 to nV do BEGIN  {extract maximum length of division values..}
    Aux:=valB-(valB-valA)/nV*i;
    eOR_:=0;
    if (Abs(Aux) < Eps*i) then
      S:='0'  {..almost zero shown as 0}
    else
      S:=Trim0sPi(Val2PIform(Aux,WidNr));
    if (Pos('E',S) > 0) then Inc(eOR_);   {..extra digit for E-numbers}
    if (Pos('ã',S) > 0) then Inc(eOR_);   {..extra digit for ã-numbers}
    S:=Trim0sPi(Val2PIform(Aux,WidNr+eOR_));
    NewWidNr:=Round(Max2(Length(S),NewWidNr));
  END;

  PixOfsX:=0;
  for i:=0 to nV do BEGIN
    X0:=XB-(XB-XA)/nV*i;   Y0:=YB-(YB-YA)/nV*i;
    X1:=X0+Abs(Lout_)*cA;  Y1:=Y0+Abs(Lout_)*sA;
    Aux:=valB-(valB-valA)/nV*i;
    eOR_:=0;
    if (Abs(Aux) < Eps*i) then
      S:='0' {..almost zero shown as '0'}
    else BEGIN
      S:=Val2PIform(Aux,NewWidNr);
      S:=Trim0sPI(S)
    END;
    PDtext('_Text',X1,ChOfs*cA, Y1,ChOfs*sA, S);
    PixOfsX:=Max2(PixOfsX,TextWidth(S));
  END;

  if (nV = 1) then PixOfsX:=0; {..2 values only => enough room between them}
  if (nDint <= 0) then Exit;

  GetLineSettings(LineSettings_L);
  nV:=nV+nV*(nDint-1);
  for i:=0 to nV do BEGIN {put Divissions..}
    X0:=XA+(XB-XA)/nV*i;
    Y0:=YA+(YB-YA)/nV*i;
    if ((i MOD nDinT) = 0) OR (i = nV) then BEGIN {major division line..}
      X1:=X0+Lout_*cA;
      Y1:=Y0+Lout_*sA;
    END
    else BEGIN {minor division line..}
      X1:=X0+Coef_*Lout_*cA;
      Y1:=Y0+Coef_*Lout_*sA;
    END;
    X2:=X0-Lin_*cA;  {-cA=cos(Alpha-Pi)}
    Y2:=Y0-Lin_*sA;  {-sA=sin(Alpha-Pi)}

    if ColorCode then BEGIN
      SetColor(ScaleColor(0,Sqrt(Sqr(XA-XB)+Sqr(YA-YB)), Sqrt(Sqr(XA-X0)+Sqr(YA-Y0))));
      ScaleColorDXF(0,Sqrt(Sqr(XA-XB)+Sqr(YA-YB)), Sqrt(Sqr(XA-X0)+Sqr(YA-Y0)));
      SetLineStyle(SolidLn, 0, ThickWidth); SyncDXFLineStyleTkns; {thick divison lines..}
    END;
    if (Lin_ > 9) then BEGIN {grid lines..}
      SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
      PD_line('_Divissions',X0,Y0,X1,Y1); {outside portion of minor division line..}
      SetLineStyle(DottedLn, 0, NormWidth);  SyncDXFLineStyleTkns;
      PD_line('_Grid_Lines',X0,Y0,X2,Y2); {..grid line}
    END
    else
      PD_line('_Divissions',X1,Y1,X2,Y2); {minor division line..}
  END;

  PixOfsX:=cA*(Abs(Lout_)+PixOfsX+(1+ChOfs)*PixChW);

  with LineSettings_L do  {back to original line settings..}
   SetLineStyle(LineStyle,Pattern,Thickness); SyncDXFLineStyleTkns;

  SetColorBGI_DXF(MaxColor);

END; {..DivLT}

{----------------------------------------------------------------------------}
procedure DivLV(XA,YA,XB,YB, valA,valB, D_val:double; nDinT:Byte;
          ChOfs,Alpha:single;  var PixOfsX:single);
{Put values along A-B within valA & valB (centered at 0), spaced at D_val    }
{and offset by +/-ChOfs depending on SetTextJustify settings.                }
{Between 2 such values draw nDinT minor division lines.                      }
{Alpha in RAD is the angle formed by A-B and the division lines.             }
{PixOfsX returns the maximum extent of the text in the x direction, usefull  }
{if further labeling is done along A-B.                                      }

var  X_A,Y_A,
     X_B,Y_B,
     val_A, val_B,
     Aux: double;
     OldColorCode: Boolean;
     TxtLgt: Byte; {.. maximum division text length}
     nn: Integer;

BEGIN {DivLV..}
  OldColorCode:=ColorCode;  ColorCode:=FALSE; {supress color coding}

  PixOfsX:=0;
  if (valA = valB) OR (nDinT = 0) then  Exit;
  D_Val:=Abs(D_Val);

  if (valA > valB) then BEGIN  {make sure valA < valB..}
    Aux:=valA;  valA:=valB;  valB:=Aux;
    Aux:=XA;    XA:=XB;      XB:=Aux;
    Aux:=YA;    YA:=YB;      YB:=Aux;
  END;

  val_A:=RoundInt(valA/D_Val)*D_Val;
  val_B:=RoundInt(valB/D_Val)*D_Val;
  if (val_A < valA) then  val_A:=val_A+D_Val;
  if (val_B > valB) then  val_B:=val_B-D_Val;
  if (val_B-val_A < D_Val/(2*nDinT)) then BEGIN
    val_B:=valB;  val_A:=valA;
  END;

  nn:=RoundInt(Abs((val_B-val_A)/D_Val))+1;
  if (nn > 41) then nn:=41;
  X_A:=xA+(XB-XA)*(val_A-valA)/(valB-valA);
  Y_A:=YA+(YB-YA)*(val_A-valA)/(valB-valA);
  X_B:=xB-(XB-XA)*(valB-val_B)/(valB-valA);
  Y_B:=YB-(YB-YA)*(valB-val_B)/(valB-valA);

  DivLT(X_A,Y_A,X_B,Y_B, val_A,val_B, nn,nDinT, ChOfs,Alpha, PixOfsX);

  D_Val:=D_Val/nDinT;
  nn:=TruncInt((val_A-valA)/D_Val); {minor division lines before 1st value..}
  if (nn >= 1) then BEGIN {remaining minor division lines before 1st value..}
    Aux:=D_Val/(val_A-valA);
    XA:=X_A-(X_A-XA)*nn*Aux;
    YA:=Y_A-(Y_A-YA)*nn*Aux;
    DivL(X_A,Y_A, XA,YA, nn+1, Alpha, Coef_*Lout_,Lin_);
  END;
  nn:=TruncInt((valB-val_B)/D_Val); {minor division lines after last value..}
  if (nn >= 1) then BEGIN {remaining minor division lines after last value..}
    Aux:=D_Val/(valB-val_B);
    XB:=X_B+(XB-X_B)*nn*Aux;
    YB:=Y_B+(YB-Y_B)*nn*Aux;
    DivL(X_B,Y_B, XB,YB, nn+1, Alpha, Coef_*Lout_,Lin_);
  END;

  ColorCode:=OldColorCode; {restore color coding}
END; {..DivLV}

{============================================================================}
procedure SetMarker(M_Size:single;  M_Type:st02);
{ Set marker type and size in PlotCurve.                                     }
{ if M_Type[1] = '|' then put a markers at every data point.                 }
{ if M_Type[1] = ':' then put scatter markers (it can be ommited)            }
{ M_Type = '' '%' 'o' '.' '[]' '<>' 'v' '^' '*' 'x' '+' '@' '&' 'q'          }

BEGIN {SetMarker..}
  M_Type:=TrimBlanks(M_Type);
  if (M_Type[1] = '|') then BEGIN
     MarkScat:=FALSE;   Delete(M_Type,1,1);
  END;
  if (M_Type[1] = ':') then BEGIN
     MarkScat:=TRUE;   Delete(M_Type,1,1);
  END;
  Delete(M_Type,2,1);

  if (M_Type = '')   then MarkType:=0;   {no marker }
  if (M_Type = '%')  then MarkType:=1;   {í transparent round}
  if (M_Type = 'o')  then MarkType:=2;   {o background color filled round}
  if (M_Type = '.')  then MarkType:=3;   { solid round}
  if (M_Type = '[')  then MarkType:=4;   {þ}
  if (M_Type = '<')  then MarkType:=5;   {}
  if (M_Type = 'v')  OR
     (M_Type = 'V')  then MarkType:=6;   {}
  if (M_Type = '^')  then MarkType:=7;   {}
  if (M_Type = '*')  then MarkType:=8;   {*}
  if (M_Type = 'x')  then MarkType:=9;   {x}
  if (M_Type = '+')  then MarkType:=10;  {+}
  if (M_Type = '@')  then MarkType:=11;  {}
  if (M_Type = '&')  then MarkType:=12;  {}
  if (M_Type = 'q')  OR
     (M_Type = 'Q')  then MarkType:=13;  {}
  if (M_Type = '>')  then MarkType:=14;  {->-}

  MarkSize:=Min2(M_Size,10.0)
END; {..SetMarker}

{----------------------------------------------------------------------------}
procedure DXFScanLine(Pln:Byte);
BEGIN
  PutDXFScanLine:=TRUE;
END;

{----------------------------------------------------------------------------}
procedure DXFScanPoint(Pln:Byte);
BEGIN
  PutDXFScanPoint:=TRUE;
END;

{----------------------------------------------------------------------------}
procedure PlotCurve(Pln:Byte; X,Y:VDp; nPts:Word; Color:Integer);
{Plot inside curent viewport a line through (X[i],Y[i]) with i=1..nPts       }
{Line will be of color Color.  If  (Color < 0)  AND  SetMarker(..)  has been }
{called previously, it plots markers only w/o the connecting line.           }

var i:Integer;  Xi,Yi, Xant,Yant, XYi_XYMant:double;

BEGIN {PlotCurve..}
  if (nPts > P_max) then nPts:=P_max;

  if (Xmin[Pln] = InfD) AND (Xmax[Pln] = -InfD) then
    UpdateLimitsX(Pln, X, nPts); {extract min & max of X[]..}

  if (Ymin[Pln] = InfD) AND (Ymax[Pln] = -InfD) then
    UpdateLimitsY(Pln, Y, nPts); {extract min & max of Y[]..}

  Inc(XYGraphCalls);

  SetViewPort(xs1[Pln],ys1[Pln], xs2[Pln],ys2[Pln], ClipOn);
  Obj2Scr(IsoFit[Pln], Xmin[Pln],Xmax[Pln], Ymin[Pln],Ymax[Pln]);
  Xmin[Pln]:=Xmin[Pln]-GetExtentX;
  Xmax[Pln]:=Xmax[Pln]+GetExtentX;
  Ymin[Pln]:=Ymin[Pln]-GetExtentY;
  Ymax[Pln]:=Ymax[Pln]+GetExtentY;

  SyncDXFLineStyleTkns;
  Color_L:=GetColor;
  SetColorBGI_DXF(Abs(Color));
  SyncDXFLineStyleTkns;
  LastCurvesColor:=Abs(Color);
  WaitForPline('G'+MySt(XYGraphCalls,3),-1,True);

  XYi_XYMant:=100*MarkSize;
  Xant:=X_p(X[1]);  Yant:=Y_p(Y[1]);
  if PutDXFScanPoint then BEGIN {first scan point..}
    Color_L:=GetColor;
    SetColorBGI_DXF(MaxColor);
    DXFcircle('1', 0.01, p_X121(Xant),p_Y121(Yant),MarkSize);
    SetColorBGI_DXF(Color_L);
  END;
  for i:=2 to nPts do BEGIN
    Xi:=X_p(X[i]); Yi:=Y_p(Y[i]);
    if (Color > 0) then
      PDline('G'+MySt(XYGraphCalls,3),Xant,Yant, Xi,Yi);
    XYi_XYMant:=XYi_XYMant+Dist2Pts2D(Xant,Yant, Xi,Yi);
    if (MarkType > 0) AND (XYi_XYMant > 6*MarkSize) then BEGIN {6 = marker spacing!!}
      SetDXFlayer('G'+MySt(XYGraphCalls,3)+'-markers');
      Point(Xi,Yi, MarkSize, MarkType);  {put marker @ current point}
      if MarkScat then XYi_XYMant:=0;
    END;
    Xant:=Xi;  Yant:=Yi;
    if PutDXFScanPoint OR PutDXFScanLine then BEGIN {scan point and line..}
      Color_L:=GetColor;
      SetColorBGI_DXF(MaxColor);
      GetLineSettings(LineSettings_L);
      SetLineStyle(DashedLn, 0, NormWidth);  SyncDXFLineStyleTkns;
      if PutDXFScanPoint then
        DXFcircle(MySt(i,3), 0.01, p_X121(Xant),p_Y121(Yant),MarkSize);
      if PutDXFScanLine then
        DXFLine(MySt(i,3),0.1,p_X121(Xant),p_Y121(Y_p(Ymin[Pln])),p_X121(Xant),p_Y121(Y_p(Ymax[Pln])));
      with LineSettings_L do
       SetLineStyle(LineStyle,Pattern,Thickness);  SyncDXFLineStyleTkns;
      SetColorBGI_DXF(Color_L);
    END;
  END; {..for}

  DischardPline('G'+MySt(XYGraphCalls,3));

  SetColorBGI_DXF(Color_L);

  if FreezeXYLimits[Pln] then Exit;
END; {..PlotCurve}

{----------------------------------------------------------------------------}
procedure PlotXaxis(Pln:Byte; Down0Up, nVal,nDiv: Byte; xLabel: st20);
{Plot X axis at Down0Up location and put nValX values and nDivX divisions    }
{Down0Up = (0,1,2) locate X axis at y=Ymin, y=0 or Y=Ymax respectively       }

var Dv: double;  {interval between 2 values over X-axis}
    AuxSing: single;

BEGIN {PlotXaxis..}
  MySetTextStyle(SmallFont, HorizDir,1, TRUE);
  Color_L:=GetColor;
  SetColorBGI_DXF(MaxColor);
  GetLineSettings(LineSettings_L);
  SetLineStyle(SolidLn, 0, NormWidth);   SyncDXFLineStyleTkns;

  SetViewPort(xs1[Pln],ys1[Pln],xs2[Pln],ys2[Pln], ClipOff);
  Obj2Scr(IsoFit[Pln], Xmin[Pln],Xmax[Pln], Ymin[Pln],Ymax[Pln]);

  if (Lin_ > 9) then
    if (Down0Up <> 1) then
      Lin_:=ys2[Pln]-ys1[Pln]  {will draw grid lines}
    else
      Lin_:=Lout_;

  if (nVal > 2) then
    NiceDivs(Xmin[Pln],Xmax[Pln], Dv,nVal, nVal+1)
  else
    Dv:=Xmax[Pln]-Xmin[Pln];

  if (Ymin[Pln]*Ymax[Pln] > 0) AND (Down0Up = 1) then Down0Up:=0;
  case Down0Up of
    0: BEGIN {X axis at the bottom}
        PD_line('0',0,ys2[Pln]-ys1[Pln],xs2[Pln]-xs1[Pln],ys2[Pln]-ys1[Pln]);
        SetTextJustify(CenterText,TopText);  {for divisions..}
        DivLV(0,ys2[Pln]-ys1[Pln],xs2[Pln]-xs1[Pln],ys2[Pln]-ys1[Pln],
        Xmin[Pln],Xmax[Pln], Dv,nDiv, 0.3, 0.5*Pi, AuxSing);
        SetTextJustify(RightText,TopText);  {for LabelX..}
        PDtext('_Text',xs2[Pln]-xs1[Pln],0, ys2[Pln]-ys1[Pln]+Lout_,1.5, xLabel);
      END;
    1: BEGIN {X axis at Y=0}
        PD_line('0',X_p(Xmin[Pln]),Y_p(0),X_p(Xmax[Pln]),Y_p(0));
        SetTextJustify(CenterText,TopText);  {for divisions}
        DivLV(X_p(Xmin[Pln]),Y_p(0),X_p(Xmax[Pln]),Y_p(0),
        Xmin[Pln],Xmax[Pln], Dv,nDiv, 0.3, 0.5*Pi, AuxSing);
        SetTextJustify(RightText,TopText);  {for LabelX}
        PDtext('_Text',xs2[Pln]-xs1[Pln],0, Y_p(0)+Lout_,1.5, xLabel);
      END;
    2: BEGIN {X axis on top}
        PD_line('0',0,0,xs2[Pln]-xs1[Pln],0);
        SetTextJustify(CenterText,BottomText);
        DivLV(0,0,xs2[Pln]-xs1[Pln],0, Xmin[Pln],Xmax[Pln], Dv,nDiv, 0.3,-0.5*Pi, AuxSing);
        SetTextJustify(RightText,BottomText);  {this works for LabelX}
        PDtext('_Text',xs2[Pln]-xs1[Pln],0, -Lout_,-1.5, xLabel);
      END;
  END;

  with LineSettings_L do
    SetLineStyle(LineStyle,Pattern,Thickness); SyncDXFLineStyleTkns;
  SetColorBGI_DXF(Color_L);

  FreezeXYLimits[Pln]:=TRUE;
END; {..PlotXaxis}

{----------------------------------------------------------------------------}
procedure PlotYaxis(Pln:Byte; Lft0Rght,nVal,nDiv:Byte; yLabel:st20);
{Plots a box and puts divisions and values acording to xDMU and yLMR }
{xDMU = (0,1,2) locate X axis at ymin, y=0 or ymax respectively      }
{yUCD = (0,1,2) locate Y axis at xmin, x=0 or xmax respectively      }

var Dv:double; {interval between 2 values over Y-axis}
    AuxSing: single;

BEGIN {PlotYaxis ..}
  MySetTextStyle(SmallFont, HorizDir,1, TRUE);
  Color_L:=GetColor;
  SetColorBGI_DXF(MaxColor);
  GetLineSettings(LineSettings_L);
  SetLineStyle(SolidLn, 0, NormWidth);   SyncDXFLineStyleTkns;

  SetViewPort(xs1[Pln],ys1[Pln], xs2[Pln],ys2[Pln], ClipOff);
  Obj2Scr(IsoFit[Pln], Xmin[Pln],Xmax[Pln], Ymin[Pln],Ymax[Pln]);

  if (Lin_ > 9) then
    if (Lft0Rght <> 1) then
      Lin_:=xs2[Pln]-xs1[Pln]  {will draw grid lines}
    else
      Lin_:=Lout_;

  if (nVal > 2) then
    NiceDivs(Ymin[Pln],Ymax[Pln], Dv,nVal, nVal+1)
  else
    Dv:=Ymax[Pln]-Ymin[Pln];

  if ((Xmin[Pln] > 0) OR (Xmax[Pln] < 0)) AND (Lft0Rght = 1) then Lft0Rght:=0;

  SetTextJustify(RightText,CenterText);

  if (yLabel[1] <> ' ') then
    LastCurvesColor:=MaxColor
  else
    Delete(yLabel,1,1);

  case Lft0Rght of
   0: BEGIN {Y axis to the left}
       PD_line('0',0,ys2[Pln]-ys1[Pln],0,0);
       DivLV(0,ys2[Pln]-ys1[Pln], 0,0, Ymin[Pln],Ymax[Pln], Dv,nDiv, 0.5,Pi, AuxSing);
       SetColorBGI_DXF(LastCurvesColor);
       MySetTextStyle(SmallFont, VertDir,1, TRUE); {write LabelY vertically..}
       SetTextJustify(RightText,TopText);
       PDtext('_Text', AuxSing,-0.25, 0,0, yLabel);
      END;
   1: BEGIN {Y axis at X=0}
       PD_line('0',X_p(0),Y_p(Ymin[Pln]),X_p(0),Y_p(Ymax[Pln]));
       DivLV(X_p(0),Y_p(Ymin[Pln]),X_p(0),Y_p(Ymax[Pln]),
       Ymin[Pln],Ymax[Pln], Dv,nDiv, 0.5,Pi, AuxSing);
       SetColorBGI_DXF(LastCurvesColor);
       MySetTextStyle(SmallFont, VertDir,1, TRUE);  {write LabelY vertically..}
       SetTextJustify(RightText,TopText);
       PDtext('_Text', X_p(0)+AuxSing,-0.25, 0,0, yLabel);
      END;
  2: BEGIN {Y axis to the right}
       PD_line('0',xs2[Pln]-xs1[Pln],ys2[Pln]-ys1[Pln],xs2[Pln]-xs1[Pln],0);
       SetTextJustify(LeftText,CenterText);
       DivLV(xs2[Pln]-xs1[Pln],ys2[Pln]-ys1[Pln],xs2[Pln]-xs1[Pln],0,
       Ymin[Pln],Ymax[Pln], Dv,nDiv, 0.5,0.0, AuxSing);
       SetColorBGI_DXF(LastCurvesColor);
       MySetTextStyle(SmallFont, VertDir,1, TRUE);  {write LabelY vertically..}
       SetTextJustify(LeftText,TopText);
       PDtext('_Text', xs2[Pln]-xs1[Pln]+AuxSing,0.0, 0,0, yLabel);
      END;
  END;

  SetColorBGI_DXF(Color_L); {..restor color}
  LastCurvesColor:=MaxColor;  {reset LastCurvesColor}
  with LineSettings_L do
   SetLineStyle(LineStyle,Pattern,Thickness); SyncDXFLineStyleTkns;
  MySetTextStyle(SmallFont, HorizDir,1, TRUE);

  FreezeXYLimits[Pln]:=TRUE;
END; {..PlotYaxis}

{----------------------------------------------------------------------------}
procedure PlotScanLine(Pln:Byte; X:double; MS:Integer);
{Plot a vertical line at X, wait MS milliseconds and then delete it          }
{For MS < 0 delete the scan line at the next call with the same settings     }

var ViewPort_L: ViewPortType;

BEGIN  {PlotScanLine..}
  GetViewSettings(ViewPort_L);

  SetViewPort(xs1[Pln],ys1[Pln], xs2[Pln],ys2[Pln], ClipOn);
  Color_L:=GetColor;
  GetLineSettings(LineSettings_L);
  SetColor(MaxColor);
  SetLineStyle(DashedLn, 0, NormWidth);
  SetWriteMode(XORput); {XOR mode..}
  Obj2Scr(IsoFit[Pln], Xmin[Pln],Xmax[Pln], -1.0,1.0);

  Line(RoundInt(X_p(X)),0,RoundInt(X_p(X)),ys2[Pln]-ys1[Pln]);
  if (MS > 0) then BEGIN
    Delay(MS);
    Line(RoundInt(X_p(X)),0,RoundInt(X_p(X)),ys2[Pln]-ys1[Pln]);
  END;
  SetWriteMode(NormalPut); {NormalPut mode..}
  SetColor(Color_L);
  with LineSettings_L do SetLineStyle(LineStyle,Pattern,Thickness);
  with ViewPort_L do SetViewPort(x1,y1,x2,y2, Clip);
END; {..PlotScanLine}

{----------------------------------------------------------------------------}
procedure PlotScanPoint(Pln:Byte; X,Y:double; MS:Integer);
{Plot a marker at (X,Y), wait MS milliseconds                          }
{For MS < 0 delete the marker at the next call with the same settings  }

var ViewPort_L: ViewPortType;

BEGIN {PlotScanPoint..}
  GetViewSettings(ViewPort_L);
  SetViewPort(xs1[Pln],ys1[Pln], xs2[Pln],ys2[Pln], ClipOn);
  Color_L:=GetColor;
  GetLineSettings(LineSettings_L);
  SetColor(MaxColor);
  SetLineStyle(SolidLn, 0, NormWidth);
  SetLineStyle(SolidLn, 0, ThickWidth);
  SetWriteMode(XORput); {XOR mode..}
  Obj2Scr(IsoFit[Pln], Xmin[Pln],Xmax[Pln], Ymin[Pln],Ymax[Pln]);

  Line(X_pI(X)  ,Y_pI(Y)-2,X_pI(X)  ,Y_pI(Y)+2);
  Line(X_pI(X)-2,Y_pI(Y)  ,X_pI(X)+2,Y_pI(Y)  );

  if (MS > 0) then BEGIN
    Delay(2*MS);

  Line(X_pI(X)  ,Y_pI(Y)-2,X_pI(X)  ,Y_pI(Y)+2);
  Line(X_pI(X)-2,Y_pI(Y)  ,X_pI(X)+2,Y_pI(Y)  );

  END;

  SetWriteMode(NormalPut); {NormalPut mode..}
  SetColor(Color_L);
  with LineSettings_L do SetLineStyle(LineStyle,Pattern,Thickness);
  with ViewPort_L do SetViewPort(x1,y1,x2,y2, Clip);
END; {..PlotScanPoint}

{----------------------------------------------------------------------------}
procedure Arc3pts(x1,y1, x2,y2, x3,y3: double);
{Draw a circular arc subintended by 3 points (x1,y1),(x2,y2) and (x3,y3).    }

var  xC,yC,R,Teta,sT,cT: double; n,i: Integer;  OK: Boolean;

BEGIN {Arc3pts..}
  Circ3Pts(x1,y1, x2,y2, x3,y3, R, xC,yC);
  if (xC < InfD) then BEGIN  {circular arc..}
    Teta:=U3pts2D(x1,y1, xC,yC, x3,y3);
    if sgn(R) < 0 then Teta:=2*PI-Teta;

    n:=Round(Teta/(2*RAD));  {number of approximating segments}
    if (n < 2) then PD_line('',x1,y1,x3,y3)
    else BEGIN
      ExpectDXFplines;
      AddVertexPline('',p_X121(x2),p_Y121(y2));
      Teta:=sgn(R)*Teta/n;
      sT:=sin(Teta); cT:=cos(Teta);
      for i:=1 to n do BEGIN
        x2:=Round((x1-xC)*cT-(y1-yC)*sT+xC);
        y2:=Round((y1-yC)*cT+(x1-xC)*sT+yC);
        AddVertexPline('',p_X121(x2),p_Y121(y2));
      END;
      DXFplineEnd('');
    END;
  END
  else PD_line('',x1,y1,x2,y2);
END; {..Arc3pts}

{----------------------------------------------------------------------------}
procedure ArrowH(XA,YA,XB,YB:double; AC, Alpha:single);
{Draw an arrow head at A oriented from B to A; AC is the length of the side- }
{segment and Alpha (in degrees) is the angle between AB and AC.              }

var ViewPort_L: ViewPortType;
    Alfa0, X,Y: single;
    PLine_Tkns: double;

BEGIN {ArrowH..}
  GetViewSettings(ViewPort_L);
  with ViewPort_L do BEGIN
    if (XA < 0) OR (XA > x2-x1) then Exit;
    if (YA < 0) OR (YA > y2-y1) then Exit;
  END;

  if (Sqr(XA-XB)+Sqr(YA-YB) > 0.0) then BEGIN
    ExpectDXFplines;
    Alpha:=Alpha*RAD;
    Alfa0:=Atan2(YB-YA,XB-XA);
    X:=XA+AC*cos(Alfa0+Alpha);
    Y:=YA+AC*sin(Alfa0+Alpha);
    AddVertexPline('',p_X121(X),p_Y121(Y));
    AddVertexPline('',p_X121(XA),p_Y121(YA));
    Line(RoundInt(X),RoundInt(Y),RoundInt(XA),RoundInt(YA));
    X:=XA+AC*cos(Alfa0-Alpha);
    Y:=YA+AC*sin(Alfa0-Alpha);
    AddVertexPline('',p_X121(X),p_Y121(Y));
    Line(RoundInt(X),RoundInt(Y),RoundInt(XA),RoundInt(YA));
    DXFplineEnd('');
  END;
END; {..ArrowH}

{----------------------------------------------------------------------------}
procedure Arrow(XA,YA,XB,YB: double; AC, Alpha:single);
{Draw an arrow from B to A with the head at A; AC is the length of the side- }
{segment and Alpha (deg) is the angle between AB & AC.                       }

BEGIN {Arrow..}
  GetLineSettings(LineSettings);
  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
  if (Sqr(XA-XB)+Sqr(YA-YB) > 0.0) then BEGIN
    PD_Line('',XA,YA,XB,YB);
    ArrowH(XA,YA,XB,YB, AC, Alpha);
  END;
  with LineSettings do
   SetLineStyle(LineStyle,Pattern,Thickness);  SyncDXFLineStyleTkns;
END; {..Arrow}

{----------------------------------------------------------------------------}
procedure ArrowS(XA,YA,XB,YB:double; k,Alpha:single);
{Proportional arrow for gradient plot in D_3D                                }
{Draw an arrow from B to A with the head at A; k is the fraction of the arrow}
{length that gives the side-segment; Alpha (deg) is the angle between AB & AC}
var AB: double;

BEGIN {ArrowS..}
  GetLineSettings(LineSettings);
  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
  AB:=Sqr(XA-XB)+Sqr(YA-YB);
  if (AB > 0.0) then BEGIN
    PD_Line('',XA,YA,XB,YB);
    ArrowH(XA,YA,XB,YB, k*Sqrt(AB), Alpha);
  END;
  with LineSettings do
   SetLineStyle(LineStyle,Pattern,Thickness);  SyncDXFLineStyleTkns;
END; {..Arrow}

{----------------------------------------------------------------------------}
procedure Point(Xp,Yp:double; PtSze: single; PTtype:ShortInt);
{Put at (Xp,Yp) a point of type PoinType and size PtSze.  Case PTtype of:    }
{ 0: .   1: ì   2: o   3:    4: þ   5:    6:    7:    8: *   9: x        }
{10: +  11:   12:   13:   14: |  20: [dummy rectangle]  else  nothing.    }

var ViewPort_L: ViewPortType;
    P_8: Poly_8;
    TxtHgt,TxtLgt: Byte;

BEGIN {Point..}
  GetViewSettings(ViewPort_L);
  with ViewPort_L do BEGIN
    if (Xp < 0) OR (Xp > x2-x1) then Exit;
    if (Yp < 0) OR (Yp > y2-y1) then Exit;
  END;
  if (PtSze <= 0) then PTtype:=0;
  DmyFaces :=TRUE;
  DrawPoint:=TRUE;
  GetLineSettings(LineSettings_L);
  SetLineStyle(SolidLn, 0, NormWidth); SyncDXFLineStyleTkns;
  if (PTtype > 1) AND (PTtype < 8) OR (PTtype = 20) then IncDXFelev;
  case PTtype of
    0: BEGIN
      PutPixel(RoundInt(Xp),RoundInt(Yp),GetColor);
      DXFPoint('',p_X121(Xp),p_Y121(Yp));
    END;
    1: PDcircle('',Xp,Yp,PtSze); {ì i.e. empty round}
    2: BEGIN {o i.e. background-collor-filled circle}
      Color_L:=GetColor;    GetFillSettings(FillSettings);
      SetColor(MinColor);   SetFillStyle(SolidFill,MinColor);
       PieSlice(RoundInt(Xp),RoundInt(Yp),0,360,RoundInt(PtSze));
      with FillSettings do SetFillStyle(Pattern,Color);
      SetColor(Color_L);
      PDcircle('',Xp,Yp,PtSze);
    END;
    3: BEGIN { solid round}
      GetFillSettings(FillSettings);
      SetFillStyle(SolidFill,GetColor);
       PieSlice(RoundInt(Xp),RoundInt(Yp),0,360,RoundInt(PtSze));
      with FillSettings do SetFillStyle(Pattern,Color);
      PDcircle('',Xp,Yp,PtSze);
    END;
    4: BEGIN {þ}
      P_8[1].x:=Xp-0.85*PtSze;  P_8[1].y:=Yp-0.85*PtSze;
      P_8[2].x:=Xp+0.85*PtSze;  P_8[2].y:=Yp-0.85*PtSze;
      P_8[3].x:=Xp+0.85*PtSze;  P_8[3].y:=Yp+0.85*PtSze;
      P_8[4].x:=Xp-0.85*PtSze;  P_8[4].y:=Yp+0.85*PtSze;
      PDfillPoly('',4, P_8);
      PDdrawPoly('',4, P_8,TRUE);
    END;
    5: BEGIN {}
      P_8[1].x:=Xp-PtSze;  P_8[1].y:=Yp;
      P_8[2].x:=Xp;        P_8[2].y:=Yp-1.25*PtSze;
      P_8[3].x:=Xp+PtSze;  P_8[3].y:=Yp;
      P_8[4].x:=Xp;        P_8[4].y:=Yp+1.25*PtSze;
      PDdrawPoly('',4, P_8,TRUE);
      PDfillPoly('',4, P_8);
    END;
    6: BEGIN {}
      P_8[1].x:=Xp;        P_8[1].y:=Yp+1.2*PtSze;
      P_8[2].x:=Xp-PtSze;  P_8[2].y:=Yp-PtSze+1.0;
      P_8[3].x:=Xp+PtSze;  P_8[3].y:=Yp-PtSze+1.0;
      PDdrawPoly('',3, P_8,TRUE);
      PDfillPoly('',3, P_8);
    END;
    7: BEGIN {}
      P_8[1].x:=Xp;         P_8[1].y:=Yp-1.2*PtSze;
      P_8[2].x:=Xp-PtSze;   P_8[2].y:=Yp+PtSze-1.0;
      P_8[3].x:=Xp+PtSze;   P_8[3].y:=Yp+PtSze-1.0;
      PDdrawPoly('',3, P_8,TRUE);
      PDfillPoly('',3, P_8);
    END;
    8: BEGIN {*}
      PD_Line('',Xp,Yp-PtSze,Xp,Yp+PtSze);
      PD_Line('',Xp-PtSze,Yp,Xp+PtSze,Yp);
      PD_Line('',Xp-0.707*PtSze,Yp-0.707*PtSze,Xp+0.707*PtSze,Yp+0.707*PtSze);
      PD_Line('',Xp-0.707*PtSze,Yp+0.707*PtSze,Xp+0.707*PtSze,Yp-0.707*PtSze);
    END;
    9: BEGIN {x}
      PD_Line('',Xp-PtSze,Yp-PtSze,Xp+PtSze,Yp+PtSze);
      PD_Line('',Xp-PtSze,Yp+PtSze,Xp+PtSze,Yp-PtSze);
    END;
    10: BEGIN {+}
      PD_Line('',Xp-PtSze,Yp,Xp+PtSze,Yp);
      PD_Line('',Xp,Yp-PtSze,Xp,Yp+PtSze);
    END;
    11: BEGIN {}
      PDcircle('',Xp,Yp,0.8*PtSze);
      PD_Line('',Xp-PtSze,Yp-PtSze,Xp-0.566*PtSze,Yp-0.566*PtSze);
      PD_Line('',Xp-PtSze,Yp+PtSze,Xp-0.566*PtSze,Yp+0.566*PtSze);
      PD_Line('',Xp+PtSze,Yp+PtSze,Xp+0.566*PtSze,Yp+0.566*PtSze);
      PD_Line('',Xp+PtSze,Yp-PtSze,Xp+0.566*PtSze,Yp-0.566*PtSze);
    END;
    12: BEGIN {}
      PDcircle('',Xp,Yp,0.8*PtSze);
      Arrow(Xp+1.3*PtSze,Yp-1.3*PtSze,Xp+0.5657*PtSze,Yp-0.5657*PtSze,PtSze,45);
    END;
    13: BEGIN {}
      PDcircle('',Xp,Yp,0.8*PtSze);
      PD_Line('',Xp,Yp+0.8*PtSze,Xp,Yp+2.0*PtSze);
      PD_Line('',Xp-0.6*PtSze,Yp+1.4*PtSze, Xp+0.6*PtSze,Yp+1.4*PtSze);
    END;
    14: PD_Line('',Xp,Yp-PtSze,Xp,Yp+PtSze); {|}
  END;
  if (PTtype > 1) AND (PTtype < 8) OR (PTtype = 20) then DecDXFelev;
  with LineSettings_L do SetLineStyle(LineStyle,Pattern,Thickness);
  SyncDXFLineStyleTkns;
  DmyFaces :=FALSE;
  DrawPoint:=FALSE;
END; {..Point}

{----------------------------------------------------------------------------}
procedure Point1a(Xp,Yp:double; PtSze: single; PtLabel:St06);
{Put at (Xp,Yp) a 2-character text PtLabel              }
{If PtSze is negative, then it obscures the background  }

var ViewPort_L: ViewPortType;
    P_8: Poly_8;
    TxtHgt,TxtLgt: Byte;

BEGIN {Point1a ..}
  GetViewSettings(ViewPort_L);
  with ViewPort_L do BEGIN
    if (Xp < 0) OR (Xp > x2-x1) then Exit;
    if (Yp < 0) OR (Yp > y2-y1) then Exit;
  END;
  if (PtSze < 0) then BEGIN
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    20: BEGIN dummy rectangle to cover text
    TxtHgt:=TextHeight('8');
    TxtLgt:=TextWidth('8');
    P_8[1].x:=Xp-0.65*TxtLgt*PtSze;  P_8[1].y:=Yp-0.35*TxtHgt;
    P_8[2].x:=Xp+0.65*TxtLgt*PtSze;  P_8[2].y:=Yp-0.35*TxtHgt;
    P_8[3].x:=Xp+0.65*TxtLgt*PtSze;  P_8[3].y:=Yp+0.35*TxtHgt;
    P_8[4].x:=Xp-0.65*TxtLgt*PtSze;  P_8[4].y:=Yp+0.35*TxtHgt;
    Color_L:=GetColor;
    SetColor(MinColor);
    PDfillPoly('',4, P_8);
    SetColor(Color_L);
    END;
}
    P_8[1].x:=Xp+1.25*PtSze;  P_8[1].y:=Yp;
    P_8[2].x:=Xp;             P_8[2].y:=Yp+1.25*PtSze;
    P_8[3].x:=Xp-1.25*PtSze;  P_8[3].y:=Yp;
    P_8[4].x:=Xp;             P_8[4].y:=Yp-1.25*PtSze;
    Color_L:=GetColor;   GetFillSettings(FillSettings);
    SetColor(MinColor);  SetFillStyle(SolidFill,MinColor);
    IncDXFelev;
    DmyFaces:=TRUE;
    PDfillPoly(GetDXFlayer+'_hide',4, P_8);
    DecDXFelev;
    DmyFaces:=FALSE;
    SetColor(Color_L);
  END;
  SetTextJustify(CenterText, CenterText);

  PDtext('',Xp,0, Yp,0, TrimBlanks(PtLabel));

END; {.. Point1a}

{============================================================================}
BEGIN
  {Default settings and values:  }
  for WidNr:=1 to 4 do BEGIN
    FreezeXYLimits[WidNr]:=FALSE;
    IsoFit[WidNr]:=FALSE;
    {Default plot box corners 140,500,80,400..}
    xs1[WidNr]:=140;    ys1[WidNr]:=80;
    xs2[WidNr]:=500;    ys2[WidNr]:=400;
    {Reset X,Y limits..}
    Xmin[WidNr]:=InfD;  Xmax[WidNr]:=-InfD;
    Ymin[WidNr]:=InfD;  Ymax[WidNr]:=-InfD;
  END;
  XYGraphCalls:=0;   {no. of calls of PlotCurve and of DXF polylines      }
  MarkType:=0;       {default marker type in PlotCurve i.e. no marker     }
  MarkSize:=2.5;     {default marker size in PlotCurve                    }
  Lout_:=4.0;        {major division-line length toward the value         }
  Lin_ :=1.0;        {major division-line length opposite the value       }
  Coef_:=0.75;       {_Coef*_Lout = minor division-line length            }
  ColorCode:=FALSE;  {color axis divisions according to value             }
  MarkScat :=TRUE;   {scatter markers in PlotCurve (not every data point) }
  TitleON:=FALSE;    {PutTitle has not been called yet                    }
  PutDXFScanLine:=FALSE;
  PutDXFScanPoint:=FALSE;
  WidNr:=7;          {no. of digits per value in DivLT and DivLV          }
END. {.. LibPlots}
