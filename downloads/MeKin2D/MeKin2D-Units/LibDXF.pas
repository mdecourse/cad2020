Unit LibDXF;
{ $R+ }
{ $S- }
{=============================================================================
  Unit for DXF file export
  (c) P.A. Simionescu 2018
=============================================================================}

INTERFACE

uses DOS,
     LibMath;

const Buf_Size = 1000;  {LnsBUF size (max 4095) If error 203 reduce value!}
      LaMsize  = M_max;  {Max size of LaM layer manager                    }
      {Nmax=18; Mmax=152; Omax=255; Pmax=502; Qmax=1002 [From LibMath]    }

type  PointOFsingle = record x,y: single; END;
      LineOFsingle  = record P1,P2: PointOFsingle; END;
      Poly_4 = array[1..4] of PointOfsingle;
      Poly_8 = array[1..8] of PointOfsingle;
      Str31  = string[31]; {31-character long string for layer names}

{---------  Both Slow and Ch    needed for Slow drawing of D_3D  !!!!---}
var Slow: Boolean;  {TRUE = confirm each FillPoly and Line command!}
    Ch: char;
{---------- To be deleted one day !!!! ------------}

var DrawPoint,      {TRUE  = PDline is of a LibPlots.Point entity }
    DmyFaces,       {TRUE  = dummy 3D-faces in use                }
    xyzOUT,         {TRUE  = write x,y,z of poliline to file      }
    D_X_F,          {FALSE = DXF output in progress but suspended }
    IncDXFont,      {TRUE  = increase by 15% the DXF font         }
    DXFon: Boolean; {TRUE  = DXF output in progress               }

    DXFchH,          {height of DXF text                          }
    DXFchW: double;  {width coefficient of DXF text               }

{----------------------------------------------------------------------------}
procedure InitDXFfile(FileName: PathStr);
procedure SuspendDXF;
procedure ResumeDXF;
procedure OutputXYZofPlines(xyzFName:NameStr; xyz_OUT:Boolean);

procedure IncDXFelev;
procedure DecDXFelev;
procedure ResetDXFelev;

function  ProperLayerName(L_Name:Str31):Str31;
procedure SetDXFlayer(L_Name:Str31);
function  GetDXFlayer:Str31;

procedure SetDXFcolor(Color: Word);
function  GetDXFcolor: Word;
procedure SetColorBGI_DXF(Color: Word);
procedure ScaleColorDXF(Xmin,Xmax,X: double);

procedure SetDXFLineStyle(Style: Word);
function  GetDXFLineStyle: Word;
procedure SetDXFLineTkns(Thiknes: double);
function  GetDXFLineTkns: double;
procedure SyncDXFLineStyleTkns;

procedure SetCoincDXF(MyCoinc: double);  {Set DXF coincidence accuracy }
function  GetCoincDXF: double; {Get DXF coincidence accuracy}

procedure SetColinDXF(MyColin: double); {Set DXF collinearity accuracy}
function  GetColinDXF: double; {Get DXF collinearity accuracy}

procedure DXFLine(L_Name:Str31; DXFelev, xA,yA,xB,yB: double);
procedure DXFcircle(L_Name:Str31; DXFelev, Xc,Yc, R: double);
procedure DXFarc(L_Name:Str31; xC,yC,StAng,EndAng,R: double);
procedure DXFPoint(L_Name:Str31; xA,yA: double);
procedure SetDXFchH(Font:Word; Inc_DXF_font:Boolean);
procedure DXFtext(L_Name:Str31; x0,y0:double; S: string);

procedure ExpectDXFplines; {standby for writing a polyline}
procedure AddVertexPline(L_Name:Str31; xA,yA: double);
procedure Add3DVertexPline(L_Name:Str31; xA,yA,zA: double);
procedure DXFplineEnd(L_Name:Str31); {write polyline suffix to DXF file}

procedure PD_line(L_Name:Str31; pX1,pY1,pX2,pY2: double);
procedure WaitForPline(L_Name:Str31; Thiknes: double; PL_Opt:Boolean);
procedure PDline (L_Name:Str31; pX1,pY1,pX2,pY2: double);
procedure vPDline(L_Name:Str31; var pX1,pY1,pX2,pY2: double; var Status:Byte);
procedure PDlinePtAng2(L_Name:Str31; pX,pY, cA,sA: double);
procedure PDlinePtAng(L_Name:Str31; pX,pY, Alpha: double);
procedure DischardPline(L_Name:Str31);
procedure DischardALLPoly;

procedure PDdrawPoly(L_Name:Str31; nEdges:Byte; P_8: Poly_8; ClosePoly: Boolean);
procedure PDfillPoly(L_Name:Str31; nEdges:Byte; P_8: Poly_8);

procedure PDcircle(L_Name:Str31; Xc,Yc,R: double);

procedure PDarc3pts(L_Name:Str31; X1,Y1, X2,Y2, X3,Y3: double);
procedure PDarc(L_Name:Str31; xC,yC, StAng,EndAng, R: double);

procedure PDtext(L_Name:Str31; x,Ofx, y,Ofy:double; S: string);
procedure PD_text(L_Name:Str31; x,Ofx, y,Ofy: double; S: string);

procedure CloseDXFfile;

{============================================================================}
IMPLEMENTATION

uses  Graph,
      LibGraph,
      LibGe2D,
      LibInOut,
      LibGIntf;
{     Unit_PCX;  }  {WritePCX for SLOW only!!!!!}

type  LayManager  = record
        FName : string[12]; {vertex file name   }
        LName : Str31;      {layer name         }
        NrVerts,            {number of vertices }
        PLtkns: double;     {polyline thickness }
        PLopt : Boolean;    {TRUE concatenates polylines read from FName }
        LColor: Word;       {layer color        }
      END;
      LnsBUF  = array[1..Buf_Size] of LineOFsingle;

var  LaM: array[1..LaMsize] of LayManager;
     Tfile,          {temporary ASCII file for vertices}
     xyzFile,        {x,y,z level-curve file           }
     DXFfile: text;  {the output DXF file              }

     EpsColin,EpsCoinc, {coincidence/collinearity parameters        }
     xA_1,yA_1,zA_1,    {previous vertex of the current polyline    }
     xA_2,yA_2,zA_2,    {2nd previous vertex of the current polyline}
     DXFelev,           {elevation of DXF entities          }
     PLineTkns:double;  {current thickness of DXF polylines }

     DXFLayerName: Str31;  {the name of the current layer  }

     DXFcolor : Word;      {color code of the DXF entities }

     DXFlnType: string[12]; {line type of DXF lines and polylines  }

{============================================================================}
{============================================================================}

procedure InitDXFfile(FileName: PathStr);
{Create file FileName.DXF, writes it with a DXF header and leaves it open.  }

BEGIN {InitDXFfile ..}
{$I-}
  Assign(DXFfile,FileName);
  Rewrite(DXFfile);
{$I+}
  if (IOResult <> 0) then Exit; {Inproper DXF file name ..}

  WriteLn(DXFfile,'999');
  WriteLn(DXFfile,'DXF R12 file generated with LibDXF subroutines -- (c) P.A. Simionescu 1997-2017');
  WriteLn(DXFfile,' 0');
  WriteLn(DXFfile,'SECTION');
  WriteLn(DXFfile,' 2');
  WriteLn(DXFfile,'HEADER');
  WriteLn(DXFfile,' 9');
  WriteLn(DXFfile,'$LTSCALE');
  WriteLn(DXFfile,' 40');
  WriteLn(DXFfile,'20.0'); {!!!}
  WriteLn(DXFfile,' 0');
  WriteLn(DXFfile,'ENDSEC');
  WriteLn(DXFfile,' 0');
  WriteLn(DXFfile,'SECTION');
  WriteLn(DXFfile,' 2');
  WriteLn(DXFfile,'TABLES');
  WriteLn(DXFfile,' 0');
  WriteLn(DXFfile,'TABLE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'LTYPE');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     9');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'LTYPE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'CONTINUOUS');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,'  3');
  WriteLn(DXFfile,'Solid _____________');
  WriteLn(DXFfile,' 72');
  WriteLn(DXFfile,'    65');
  WriteLn(DXFfile,' 73');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,' 40');
  WriteLn(DXFfile,'0.0');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'LTYPE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'DASHED');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,'  3');
  WriteLn(DXFfile,'Dashed - - - - - - -');
  WriteLn(DXFfile,' 72');
  WriteLn(DXFfile,'    65');
  WriteLn(DXFfile,' 73');
  WriteLn(DXFfile,'     2');
  WriteLn(DXFfile,' 40');
  WriteLn(DXFfile,'0.75');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'0.5');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'-0.25');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'LTYPE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'DASHED2');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,'  3');
  WriteLn(DXFfile,'Dashed (.5x) _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _');
  WriteLn(DXFfile,' 72');
  WriteLn(DXFfile,'    65');
  WriteLn(DXFfile,' 73');
  WriteLn(DXFfile,'     2');
  WriteLn(DXFfile,' 40');
  WriteLn(DXFfile,'0.375');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'0.25');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'-0.125');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'LTYPE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'DASHDOT');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,'  3');
  WriteLn(DXFfile,'Dash dot __ . __ . __ . __ . __ . __ . __ . __');
  WriteLn(DXFfile,' 72');
  WriteLn(DXFfile,'    65');
  WriteLn(DXFfile,' 73');
  WriteLn(DXFfile,'     4');
  WriteLn(DXFfile,' 40');
  WriteLn(DXFfile,'1.0');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'0.5');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'-0.25');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'0.0');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'-0.25');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'LTYPE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'DASHDOT2');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,'  3');
  WriteLn(DXFfile,'Dash dot (.5x) _._._._._._._._._._._._._._._.');
  WriteLn(DXFfile,' 72');
  WriteLn(DXFfile,'    65');
  WriteLn(DXFfile,' 73');
  WriteLn(DXFfile,'     4');
  WriteLn(DXFfile,' 40');
  WriteLn(DXFfile,'0.5');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'0.25');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'-0.125');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'0.0');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'-0.125');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'LTYPE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'DOT');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,'  3');
  WriteLn(DXFfile,'Dot . . . . . . . . . . . . . . . . . . . . . .');
  WriteLn(DXFfile,' 72');
  WriteLn(DXFfile,'    65');
  WriteLn(DXFfile,' 73');
  WriteLn(DXFfile,'     2');
  WriteLn(DXFfile,' 40');
  WriteLn(DXFfile,'0.25');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'0.0');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'-0.25');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'LTYPE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'DOT2');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,'  3');
  WriteLn(DXFfile,'Dot (.5x) .....................................');
  WriteLn(DXFfile,' 72');
  WriteLn(DXFfile,'    65');
  WriteLn(DXFfile,' 73');
  WriteLn(DXFfile,'     2');
  WriteLn(DXFfile,' 40');
  WriteLn(DXFfile,'0.125');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'0.0');
  WriteLn(DXFfile,' 49');
  WriteLn(DXFfile,'-0.125');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'ENDTAB');
  WriteLn(DXFfile,'0');
  WriteLn(DXFfile,'TABLE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'STYLE');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     2');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'STYLE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'STANDARD');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,' 40');
  WriteLn(DXFfile,'8.0');
  WriteLn(DXFfile,' 41');
  WriteLn(DXFfile,'0.85');
  WriteLn(DXFfile,' 50');
  WriteLn(DXFfile,'0.0');
  WriteLn(DXFfile,' 71');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,' 42');
  WriteLn(DXFfile,'8.0');
  WriteLn(DXFfile,'  3');
  WriteLn(DXFfile,'txt');
  WriteLn(DXFfile,'  4');
  WriteLn(DXFfile,'');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'STYLE');
  WriteLn(DXFfile,'  2');
  WriteLn(DXFfile,'GREEKS');
  WriteLn(DXFfile,' 70');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,' 40');
  WriteLn(DXFfile,'8.0');
  WriteLn(DXFfile,' 41');
  WriteLn(DXFfile,'0.85');
  WriteLn(DXFfile,' 50');
  WriteLn(DXFfile,'0.0');
  WriteLn(DXFfile,' 71');
  WriteLn(DXFfile,'     0');
  WriteLn(DXFfile,' 42');
  WriteLn(DXFfile,'8.0');
  WriteLn(DXFfile,'  3');
  WriteLn(DXFfile,'GREEKS');
  WriteLn(DXFfile,'  4');
  WriteLn(DXFfile,'');
  WriteLn(DXFfile,'  0');
  WriteLn(DXFfile,'ENDTAB');
  WriteLn(DXFfile,'0');
  WriteLn(DXFfile,'ENDSEC');
  WriteLn(DXFfile,'0');
  WriteLn(DXFfile,'SECTION');
  WriteLn(DXFfile,'2');
  WriteLn(DXFfile,'ENTITIES');
  WriteLn(DXFfile,'0');
  DXFon:=TRUE;
  D_X_F:=TRUE;
END; {.. InitDXFfile}

{----------------------------------------------------------------------------}
procedure SuspendDXF; {Suspend DXF output ..}
BEGIN
  if DXFon then D_X_F:=FALSE;
END;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure ResumeDXF;  {Resume DXF output ..}
BEGIN
  if DXFon then D_X_F:=TRUE;
END;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure OutputXYZofPlines(xyzFName:NameStr; xyz_OUT:Boolean);
BEGIN
  if xyz_OUT then BEGIN
    xyzOUT:=TRUE;
    Assign(xyzFile,ImplicitFileName(xyzFName+'.xyz'));
    Rewrite(xyzFile);
  END
  else BEGIN
    xyzOUT:=FALSE;
    Close(xyzFile);
  END;
END;  {.. OutputXYZofPlines}

{----------------------------------------------------------------------------}
procedure IncDXFelev;
BEGIN
  if D_X_F then DXFelev:=DXFelev+1.0E-5;
END; {.. IncDXFelev}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure DecDXFelev;
BEGIN
  if D_X_F then DXFelev:=DXFelev-1.0E-5;
END; {.. DecDXFelev}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure ResetDXFelev;
BEGIN
  if D_X_F then DXFelev:=0.0;
END; {.. ResetDXFelev}

{----------------------------------------------------------------------------}
function ProperLayerName(L_Name:Str31):Str31;
{Eliminate '+' and ' ' and replace '.' with 'p' to a correct layer name      }
{Maximum length permitted 31 characters                                      }

var j: Byte;

BEGIN {ProperLayerName ..}
  j:=1;
  repeat
    if (L_Name[j] = #32) OR (L_Name[j] = #43)
    OR (L_Name[j] = #42) OR (L_Name[j] = #63) then BEGIN
      {delete any blank, + ? or *}
      Delete(L_Name,j,1);
      Dec(j);
    END;
    if (L_Name[j] = #46) then L_Name[j]:='_';  {replace '.' with '_'}
    Inc(j);
  until (j > Length(L_Name));

  if (Length(L_Name) = 0) then L_Name:='_NoName';

  ProperLayerName:=L_Name;

END; {.. ProperLayerName}

{----------------------------------------------------------------------------}
procedure SetDXFlayer(L_Name:Str31);  {Make L_Name current layer ..}
BEGIN
  DXFLayerName:=ProperLayerName(L_Name);
END; {.. SetDXFlayer}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function GetDXFlayer:Str31;  {Get the name of the current layer ..}
BEGIN
  GetDXFlayer:=DXFLayerName;
END; {.. GetDXFlayer}

{----------------------------------------------------------------------------}
procedure SetDXFcolor(Color: Word);
BEGIN
  DXFcolor:=Color;
END; {.. SetDXFcolor}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function GetDXFcolor: Word;
BEGIN
  GetDXFcolor:=DXFcolor;
END; {.. GetDXFcolor}

{----------------------------------------------------------------------------}
procedure SetColorBGI_DXF(Color: Word);
{Sets current color to both BGI and DXF such that VGA color matches DXF color}
{ Black ≥0 (7)∫ Red       ≥4 (1)∫ DarkGray   ≥ 8 (8)∫ LightRed     ≥12    ∫  }
{ Blue  ≥1 (5)∫ Magenta   ≥5 (6)∫ LightBlue  ≥ 9    ∫ LightMagenta ≥13    ∫  }
{ Green ≥2 (3)∫ Brown     ≥6    ∫ LightGreen ≥10    ∫ Yellow       ≥14    ∫  }
{ Cyan  ≥3 (4)∫ LightGray ≥7 (9)∫ LightCyan  ≥11    ∫ White        ≥15 (7)∫  }

BEGIN
  SetColor(Color);
  case Color of
     1: DXFcolor:=172;  {blue         }
     2: DXFcolor:=82;   {green        }
     3: DXFcolor:=150;  {cyan         }
     4: DXFcolor:=10;   {red          }
     5: DXFcolor:=200;  {magenta      }
     6: DXFcolor:=24;   {brown        }
     7: DXFcolor:=9;    {light gray   }
     8: DXFcolor:=7;    {8 = dark gray, 7 = black}
     9: DXFcolor:=170;  {light blue   }
    10: DXFcolor:=90;   {light green  }
    11: DXFcolor:=130;  {light cyan   }
    12: DXFcolor:=11;   {light red    }
    13: DXFcolor:=230;  {light magenta}
    14: DXFcolor:=50;   {yellow       }
    else DXFcolor:=7;   {black/white  }
  END;
END; {.. SyncDXFcolor}

{----------------------------------------------------------------------------}
procedure ScaleColorDXF(Xmin,Xmax, X: double);
{Set DXF color = 20,40,60,80,100,120,140,160,180,162 based on Xmin Û X ÛXmax }
var Aux: double;
BEGIN
  if (Xmax < Xmin) then BEGIN
    Aux:=Xmin;  Xmin:=Xmax;  Xmax:=Aux;
  END;
  if (X < Xmin) then X:=Xmin;
  if (X > Xmax) then X:=Xmax;
  Aux:=Trunc(21-20*(X-Xmin)/(Xmax-Xmin));
  if (Aux < 19) then DXFcolor:=Round(Aux*10)
  else
  if (Aux >= 20) then DXFcolor:=204
  else
  DXFcolor:=192;
END; {.. ScaleColorDXF}

{----------------------------------------------------------------------------}
procedure SetDXFLineStyle(Style:Word);
BEGIN
  case Style of
     0: DXFlnType:='CONTINUOUS'; {SolidLn  ƒƒƒƒƒƒƒƒƒ}
     1: DXFlnType:='DOT';        {DottedLn ˘˘˘˘˘˘˘˘˘}
     2: DXFlnType:='CENTER';     {CenterLn ƒ-˘ƒ-˘ƒ-˘}
     3: DXFlnType:='DASHED';     {DashedLn ƒ ƒ ƒ ƒ -}
    else
     DXFlnType:='BYLAYER';
  END; {.. case}
END; {.. SetDXFLineStyle}

{----------------------------------------------------------------------------}
function GetDXFLineStyle:Word;
BEGIN
  if DXFlnType = 'CONTINUOUS' then GetDXFLineStyle:=0;  {SolidLn  ƒƒƒƒƒƒƒƒƒ}
  if DXFlnType = 'DOT'        then GetDXFLineStyle:=1;  {DottedLn ˘˘˘˘˘˘˘˘˘}
  if DXFlnType = 'CENTER'     then GetDXFLineStyle:=2;  {CenterLn ƒ-˘ƒ-˘ƒ-˘}
  if DXFlnType = 'DASHED'     then GetDXFLineStyle:=3;  {DashedLn ƒ ƒ ƒ ƒ -}
  if DXFlnType = 'BYLAYER'    then GetDXFLineStyle:=100;
END; {.. GetDXFLineStyle}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure SetDXFLineTkns(Thiknes: double);
BEGIN
  PLineTkns:=p2R121(Thiknes);
END; {.. SetDXFLineTkns}

{----------------------------------------------------------------------------}
function GetDXFLineTkns: double;
BEGIN
  GetDXFLineTkns:=PLineTkns;
END; {.. GetDXFLineTkns}

{----------------------------------------------------------------------------}
procedure SyncDXFLineStyleTkns;
{Synchronizes DXF line style and thickness with those in Graph               }

BEGIN {SyncDXFLineStyleTkns ..}
  GetLineSettings(LineSettings);
  with LineSettings do BEGIN
    case LineStyle of
       0: DXFlnType:='CONTINUOUS'; {SolidLn   ƒƒƒƒƒ}
       1: DXFlnType:='DOT';        {DottedLn  ˘˘˘˘˘}
       2: DXFlnType:='CENTER';     {CenterLn  ƒ-˘ƒ-}
       3: DXFlnType:='DASHED';     {DashedLn  ƒ ƒ ƒ}
      else
       DXFlnType:='BYLAYER';
    END; {.. case}
    if (Thickness = 1) then PLineTkns:=0.0 else PLineTkns:=p2R121(1.0);
  END;
END; {.. SyncDXFLineStyleTkns}

{----------------------------------------------------------------------------}
procedure SetCoincDXF(MyCoinc: double);  {Set DXF coincidence accuracy }
BEGIN
  EpsCoinc:=MyCoinc;
END; {.. SetCoincDXF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure SetColinDXF(MyColin: double); {Set DXF collinearity accuracy}
BEGIN
  EpsColin:=MyColin;
END; {.. SetColinDXF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function GetCoincDXF: double; {Get DXF coincidence accuracy}
BEGIN
  GetCoincDXF:=EpsCoinc;
END; {.. GetCoincDXF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function GetColinDXF: double; {Get DXF collinearity accuracy}
BEGIN
  GetColinDXF:=EpsCoinc;
END; {.. GetColinDXF}

{----------------------------------------------------------------------------}
procedure DXFtext(L_Name:Str31; x0,y0: double; S: string);
{Write a string S to DXF file that starts at coordinate (x0,y0).             }
{TP6 Greek font is limited to: ‡·Á‚ÎÓÈÊ„Â‰ÌËÍ -- DXFtext recognizes:         }
{248 ¯  and   224 ‡; 225 ·; 231 Á;  235 Î; 233 È; 227 „; 237 Ì;              }
{      Horizontal     ≥      Vertical       }
{ ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ }
{  LeftText   ≥   0   ≥ BottomText ≥   0    }
{  CenterText ≥   1   ≥ CenterText ≥   1    }
{  RightText  ≥   2   ≥ TopText    ≥   2    }

var  V_Port: ViewPortType;
     O_90,DXF_Horiz,DXF_Vert,i: Byte;
     TextStyle: string;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure BGI2DXFHorVer(TXTdir,BGI_H,BGI_V:Byte; var TXTang,DXF_H,DXF_V:Byte);
BEGIN
  DXF_H:=BGI_H;
  DXF_V:=BGI_V;
  if (TXTdir = 0) then {horizontal text ..}
    TXTang:=0
  else BEGIN  {vertical text ..}
    TXTang:=90;
    if (BGI_H = 0) then x0:=x0 + 0.42857*DXFchH else
    if (BGI_H = 1) then x0:=x0 + 0.50000*DXFchH else
    if (BGI_H = 2) then x0:=x0 + 0.48596*DXFchH;

    if (BGI_H = 0) AND (BGI_V = 0) then DXF_V:=2; { (0,0)->(0,2) }
    if (BGI_H = 0) AND (BGI_V = 1) then BEGIN     { (0,1)->(1,2) }
      DXF_H:=1;
      DXF_V:=2;
    END;
    if (BGI_H = 0) AND (BGI_V = 2) then DXF_H:=2; { (0,2)->(2,2) }
    if (BGI_H = 1) AND (BGI_V = 0) then BEGIN  { (1,0)->(0,1) }
      DXF_H:=0;
      DXF_V:=1;
    END;
    if (BGI_H = 1) AND (BGI_V = 2) then BEGIN { (1,2)->(2,1) }
      DXF_H:=2;
      DXF_V:=1;
    END;
    if (BGI_H = 2) AND (BGI_V = 0) then DXF_H:=0; { (2,0)->(0,0) }
    if (BGI_H = 2) AND (BGI_V = 1) then BEGIN     { (2,1)->(1,0) }
      DXF_H:=1;
      DXF_V:=0;
    END;
    if (BGI_H = 2) AND (BGI_V = 2) then DXF_Vert:=0; { (2,2)->(2,0) }
  END;
END;  {..BGI2DXFHorVer}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

BEGIN {DXFtext ..}
  if (NOT D_X_F) then Exit;

  if (S = '') then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  GetTextSettings(TextSettings);
  with TextSettings do {screen text settings to DXF text settings..}
    BGI2DXFHorVer(Direction,Horiz,Vert,O_90,DXF_Horiz,DXF_Vert);

  TextStyle:='STANDARD';
  for i:=1 to Length(S) do BEGIN
    if (Pos('¯',S) <> 0) then BEGIN {convert ¯ to %%d..}
      Insert('%%d',S,Pos('¯',S));  Delete(S,Pos('¯',S),1);
    END;
    if (Pos('‡',S) <> 0) then BEGIN  {convert '‡' to GREEKS 'a'..}
      Insert('a',S,Pos('‡',S));  Delete(S,Pos('‡',S),1);
      TextStyle:='GREEKS';
    END;
    if (Pos('·',S) <> 0) then BEGIN {TP6 Greek font limited to: ‡·Á‚ÎÓÈÊ„Â‰ÌËÍ}
      Insert('b',S,Pos('·',S));  Delete(S,Pos('·',S),1);
      TextStyle:='GREEKS';
    END;
    if (Pos('Á',S) <> 0) then BEGIN {TP6 Greek font limited to: ‡·Á‚ÎÓÈÊ„Â‰ÌËÍ}
      Insert('g',S,Pos('Á',S));  Delete(S,Pos('Á',S),1);
      TextStyle:='GREEKS';
    END;
    if (Pos('Î',S) <> 0) then BEGIN  {TP6 Greek font limited to: ‡·Á‚ÎÓÈÊ„Â‰ÌËÍ}
      Insert('d',S,Pos('Î',S));  Delete(S,Pos('Î',S),1);
      TextStyle:='GREEKS';
    END;
    if (Pos('È',S) <> 0) then BEGIN  {TP6 Greek font limited to: ‡·Á‚ÎÓÈÊ„Â‰ÌËÍ}
      Insert('Q',S,Pos('È',S));  Delete(S,Pos('È',S),1);
      TextStyle:='GREEKS';
    END;
    if (Pos('„',S) <> 0) then BEGIN  {TP6 Greek font limited to: ‡·Á‚ÎÓÈÊ„Â‰ÌËÍ}
      Insert('p',S,Pos('„',S));  Delete(S,Pos('„',S),1);
      TextStyle:='GREEKS';
    END;
    if (Pos('Ì',S) <> 0) then BEGIN
      Insert('f',S,Pos('Ì',S));  Delete(S,Pos('Ì',S),1);
      TextStyle:='GREEKS';
    END;
  END;  {..for}

  GetViewSettings(V_Port);
  with V_Port do BEGIN
    WriteLn(DXFfile,'TEXT');
    WriteLn(DXFfile,'8');
    WriteLn(DXFfile,L_Name);
    WriteLn(DXFfile,'62');
    WriteLn(DXFfile,DXFcolor:1);
    WriteLn(DXFfile,'10');
    WriteLn(DXFfile,'0.0');  {in a nice DXF, these 0.0's should be the    }
    WriteLn(DXFfile,'20');   {..x,y of the Bottom-Left corner of the text }
    WriteLn(DXFfile,'0.0');
    WriteLn(DXFfile,'30');
    WriteLn(DXFfile,DXFelev);
    WriteLn(DXFfile,'40');
    WriteLn(DXFfile,DXFchH:8:4);
    WriteLn(DXFfile,'1');
    WriteLn(DXFfile,S);
    WriteLn(DXFfile,'50');
    WriteLn(DXFfile,O_90:2);
    WriteLn(DXFfile,'41');
    WriteLn(DXFfile,DXFchW:8:4);
    WriteLn(DXFfile,'7');
    WriteLn(DXFfile,TextStyle);  {STANDARD or GREEK}
    WriteLn(DXFfile,'72');
    WriteLn(DXFfile,DXF_Horiz:8);
    WriteLn(DXFfile,'11');
    WriteLn(DXFfile,x0);
    WriteLn(DXFfile,'21');
    WriteLn(DXFfile,y0);
    WriteLn(DXFfile,'31');
    WriteLn(DXFfile,DXFelev);
    WriteLn(DXFfile,'73');
    WriteLn(DXFfile,(DXF_Vert+1):2);
    WriteLn(DXFfile,'0');
  END;

END; {.. DXFtext}

{----------------------------------------------------------------------------}
procedure DXFPoint(L_Name:Str31; xA,yA: double);
{Write a point of coordinates (xA,yA) in the DXF file                        }

BEGIN
  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  WriteLn(DXFfile,'POINT');
  WriteLn(DXFfile,'8');
  WriteLn(DXFfile,L_Name);
  WriteLn(DXFfile,'62');
  WriteLn(DXFfile,DXFcolor:1);
  WriteLn(DXFfile,'10');
  WriteLn(DXFfile,xA);
  WriteLn(DXFfile,'20');
  WriteLn(DXFfile,yA);
  WriteLn(DXFfile,'30');
  WriteLn(DXFfile,DXFelev);
  WriteLn(DXFfile,'0');
END; {.. DXFPoint}

{----------------------------------------------------------------------------}
procedure DXFLine(L_Name:Str31; DXFelev,xA,yA,xB,yB: double);
{Write a line from (xA,yA) to (xB,yB) in the DXF file                        }

BEGIN
  if (NOT D_X_F) then Exit;

  if (xA = xB) AND (yA = yB) then Exit; {skip zero-length lines}

  if (L_Name = '') then L_Name:=DXFLayerName;

  WriteLn(DXFfile,'LINE');
  WriteLn(DXFfile,'8');
  WriteLn(DXFfile,L_Name);
  WriteLn(DXFfile,'6');
  WriteLn(DXFfile,DXFlnType);
  WriteLn(DXFfile,'62');
  WriteLn(DXFfile,DXFcolor:1);

  WriteLn(DXFfile,'10');
  WriteLn(DXFfile,xA);
  WriteLn(DXFfile,'20');
  WriteLn(DXFfile,yA);
  WriteLn(DXFfile,'30');
  WriteLn(DXFfile,DXFelev);
  WriteLn(DXFfile,'11');
  WriteLn(DXFfile,xB);
  WriteLn(DXFfile,'21');
  WriteLn(DXFfile,yB);
  WriteLn(DXFfile,'31');
  WriteLn(DXFfile,DXFelev);
  WriteLn(DXFfile,'0');
END; {.. DXFLine}

{----------------------------------------------------------------------------}
procedure ExpectDXFplines; {standby for writing a polyline}
{ (xA_1,yA_1,zA_1) is the previous vertex of the current polyline            }
{ (xA_2,yA_2,zA_2) is the 2nd previous vertex of the current polyline        }
BEGIN
  if (NOT D_X_F) then Exit;
  zA_1:=DXFelev;
  zA_2:=DXFelev;
  xA_1:=InfD;   {reset previous vertex    }
  xA_2:=InfD;   {reset 2nd previous vertex}
END; {.. ExpectDXFplines}

{----------------------------------------------------------------------------}
procedure AddVertexPline(L_Name:Str31; xA,yA: double);
{Add a new vertex (xA,yA) to the current polyline                            }
{ (xA_1,yA_1,zA_1) is the previous vertex of the current polyline            }
{ (xA_2,yA_2,zA_2) is the 2nd previous vertex of the current polyline        }

BEGIN {AddVertexPline ..}
  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  if (xA_1 < InfD) AND (xA < InfD) then BEGIN {at least 2 valid vertices}
    if (xA_2 = InfD) then BEGIN {write poliline header ..}
      WriteLn(DXFfile,'PolyLine');
      WriteLn(DXFfile,'8');
      WriteLn(DXFfile,L_Name);
      WriteLn(DXFfile,'6');
      WriteLn(DXFfile,DXFlnType);
      WriteLn(DXFfile,'66');
      WriteLn(DXFfile,'1');
      WriteLn(DXFfile,'62');
      WriteLn(DXFfile,DXFcolor:1);
      WriteLn(DXFfile,'10');
      WriteLn(DXFfile,'0.0');
      WriteLn(DXFfile,'20');
      WriteLn(DXFfile,'0.0');
      WriteLn(DXFfile,'30');
      WriteLn(DXFfile,DXFelev);
      WriteLn(DXFfile,'70');
      WriteLn(DXFfile,'128');
      WriteLn(DXFfile,'40');
      WriteLn(DXFfile,PLineTkns:6:3);
      WriteLn(DXFfile,'41');
      WriteLn(DXFfile,PLineTkns:6:3);
      WriteLn(DXFfile,'0');
    END
    else {check collinearity}
    if Colin3Pts2D(xA_2,yA_2,xA_1,yA_1,xA,yA, EpsColin) then BEGIN
      xA_1:=xA; yA_1:=yA;  {eliminate middle point ..}
      Exit;
    END;
    {write 2D vertex}
    WriteLn(DXFfile,'VERTEX');
    WriteLn(DXFfile,'8');
    WriteLn(DXFfile,L_Name);
    WriteLn(DXFfile,'10');
    WriteLn(DXFfile,xA_1);
    WriteLn(DXFfile,'20');
    WriteLn(DXFfile,yA_1);
    WriteLn(DXFfile,'30');
    WriteLn(DXFfile,DXFelev);
    WriteLn(DXFfile,'0');
  END;
  xA_2:=xA_1;  yA_2:=yA_1;
  xA_1:=xA;    yA_1:=yA;
END; {.. AddVertexPline}

{----------------------------------------------------------------------------}
procedure Add3DVertexPline(L_Name:Str31; xA,yA,zA: double);
{Add a new 3D vertex (xA,yA,zA) to the current polyline                      }

BEGIN {Add3DVertexPline ..}
  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  if (xA_1 < InfD) AND (xA < InfD) then BEGIN {at least 2 valid vertices}
    if (xA_2 = InfD) then BEGIN {write poliline header}
      WriteLn(DXFfile,'PolyLine');
      WriteLn(DXFfile,'8');
      WriteLn(DXFfile,L_Name);
      WriteLn(DXFfile,'6');
      WriteLn(DXFfile,DXFlnType);
      WriteLn(DXFfile,'66');
      WriteLn(DXFfile,'1');
      WriteLn(DXFfile,'62');
      WriteLn(DXFfile,DXFcolor:1);
      WriteLn(DXFfile,'10');
      WriteLn(DXFfile,'0.0');
      WriteLn(DXFfile,'20');
      WriteLn(DXFfile,'0.0');
      WriteLn(DXFfile,'30');
      WriteLn(DXFfile,DXFelev);
      WriteLn(DXFfile,'70');
      WriteLn(DXFfile,'128');
      WriteLn(DXFfile,'40');
      WriteLn(DXFfile,PLineTkns:6:3);
      WriteLn(DXFfile,'41');
      WriteLn(DXFfile,PLineTkns:6:3);
      WriteLn(DXFfile,'0');
    END;
    {write 3D vertex}
    WriteLn(DXFfile,'VERTEX');
    WriteLn(DXFfile,'8');
    WriteLn(DXFfile,L_Name);
    WriteLn(DXFfile,'10');
    WriteLn(DXFfile,xA_1);
    WriteLn(DXFfile,'20');
    WriteLn(DXFfile,yA_1);
    WriteLn(DXFfile,'30');
    WriteLn(DXFfile,zA_1);
    WriteLn(DXFfile,'70');
    WriteLn(DXFfile,'32');
    WriteLn(DXFfile,'0');
  END;
  xA_2:=xA_1;  yA_2:=yA_1;  zA_2:=yA_1;
  xA_1:=xA;    yA_1:=yA;    zA_1:=zA;
END; {.. Add3DVertexPline}

{----------------------------------------------------------------------------}
procedure DXFplineEnd(L_Name:Str31);  {Close the polyline in L_Name}

BEGIN
  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  if (xA_2 < InfD) then BEGIN
    WriteLn(DXFfile,'VERTEX');
    WriteLn(DXFfile,'8');
    WriteLn(DXFfile,L_Name);
    WriteLn(DXFfile,'10');
    WriteLn(DXFfile,xA_1);
    WriteLn(DXFfile,'20');
    WriteLn(DXFfile,yA_1);
    if (zA_2 = zA_1) then BEGIN
      WriteLn(DXFfile,'30');
      WriteLn(DXFfile,DXFelev);
      WriteLn(DXFfile,'0');
    END
    else BEGIN
      WriteLn(DXFfile,'30');
      WriteLn(DXFfile,zA_1);
      WriteLn(DXFfile,'70');
      WriteLn(DXFfile,'32');
      WriteLn(DXFfile,'0');
    END;
    WriteLn(DXFfile,'SEQEND');
    WriteLn(DXFfile,'8');
    WriteLn(DXFfile,L_Name);
    WriteLn(DXFfile,'0');
  END;
END; {.. DXFplineEnd}

{============================================================================}
procedure WaitForPline(L_Name:Str31; Thiknes: double; PL_Opt:Boolean);
{Reserve 1 record in LaM for L_Name.  If (Thiknes < 0) then it sets the      }
{polyline thickness as PLineTkns (the current thickness) rather than Thiknes }

var LaMpos,i: Byte;

BEGIN {WaitForPline ..}
  if (NOT D_X_F) then Exit;

  if (L_Name = '-') then Exit; {Line segment}

  if (L_Name = '') then L_Name:=DXFLayerName;

  LaMpos:=0;
  i:=1;
  while (i < LaMsize) do BEGIN
    if (LaM[i].LName = L_Name) then Exit;  {the record already exists }
    if (LaM[i].LName = '++') then BEGIN    {found a spare place in LaM}
      LaMpos:=i;
      i:=LaMsize; {.. exit while loop}
    END;
    Inc(i);
  END;
  if (LaMpos = 0) then Exit; {no more room in LaM}
  with LaM[LaMpos] do BEGIN
    LName :=L_Name;   {set layer name}
    LColor:=DXFcolor; {set layer color}
    PLopt:=PL_Opt;    {if TRUE then optimize polyline}
    if (Thiknes <= 0) then PLtkns:=PLineTkns else PLtkns:=p2R121(Thiknes);
    if PL_Opt then BEGIN  {creates a temporary ASCII vertex file}
      FName:='~POLY'+Trim0s(MyStr(LaMpos,4))+'.$xy';
      Assign(Tfile,FName);
      Rewrite(Tfile);
      Close(Tfile);
      NrVerts:=0;
    END;
  END;
END; {..WaitForPline}

{----------------------------------------------------------------------------}
function ClipLineOK(var pX1,pY1,pX2,pY2: double): Boolean;
var V_Port : ViewPortType;
BEGIN
  ClipLineOK:=FALSE;
  GetViewSettings(V_Port);
  with V_Port do if Clip then BEGIN
    {V_Port clipping and 1/0 protection at <!> ..}
    if (pX1 < 0) AND (pX2 < 0) then Exit;
    if ((pX1 > (x2-x1)) AND (pX2 > x2-x1)) then Exit;
    if (pY1 < 0) AND (pY2 < 0) then Exit;
    if (pY1 > (y2-y1)) AND (pY2 > (y2-y1)) then Exit;
    if (pX1 < 0) then BEGIN
      pY1:=pY1-(pY2-pY1)/(pX2-pX1)*pX1; pX1:=0;
    END;
    if (pX2 < 0) then BEGIN
      pY2:=pY1-(pY2-pY1)*pX1/(pX2-pX1); pX2:=0;
    END;
    if (pY1 < 0) then BEGIN
      pX1:=pX1-(pX2-pX1)*pY1/(pY2-pY1); pY1:=0;
    END;
    if (pY2 < 0) then BEGIN
      pX2:=pX1-(pX2-pX1)*pY1/(pY2-pY1); pY2:=0;
    END;
    if (pX1 > (x2-x1)) then BEGIN
      if (pX2 = pX1) then Exit;
      pY1:=pY1+(pY2-pY1)*(x2-x1-pX1)/(pX2-pX1); pX1:=x2-x1;
    END;
    if (pX2 > (x2-x1)) then BEGIN
      if (pX2 = pX1) then Exit;
      pY2:=pY1+(pY2-pY1)*(x2-x1-pX1)/(pX2-pX1); pX2:=x2-x1;
    END;
    if (pY1 > (y2-y1)) then BEGIN
      if (pY2 = pY1) then Exit;
      pX1:=pX1+(pX2-pX1)*(y2-y1-pY1)/(pY2-pY1); pY1:=y2-y1;
    END;
    if (pY2 > (y2-y1)) then BEGIN
      if (pY2 = pY1) then Exit;
      pX2:=pX2+(pX1-pX2)*(y2-y1-pY2)/(pY1-pY2); pY2:=y2-y1;
    END;
  END; {.. Clip}
  ClipLineOK:=TRUE;
END; {.. ClipLineOK}

{----------------------------------------------------------------------------}
procedure PD_line(L_Name:Str31; pX1,pY1,pX2,pY2: double);
{Draw a linie from pX1,pY1 to pX2,pY2 on the screen and in the DXF file      }

BEGIN
  if (pX1 = pX2) AND (pY1 = pY2) then Exit; {end-points coincide ..}

  if NOT ClipLineOK(pX1,pY1,pX2,pY2) then Exit;

  Line(RoundLongInt(pX1),RoundLongInt(pY1),RoundLongInt(pX2),RoundLongInt(pY2));

  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  DXFLine(L_Name,DXFelev,p_X121(pX1),p_Y121(pY1), p_X121(pX2),p_Y121(pY2));

END; {.. PD_line}

{----------------------------------------------------------------------------}
procedure PDline(L_Name:Str31; pX1,pY1,pX2,pY2: double);
{Draw a linie from pX1,pY1 to pX2,pY2 on the screen and in the DXF file      }
{The line may be added to other lines in layer L_Name to form a polyline     }
var  LaMpos,i: Byte;

BEGIN
  if (pX1 = pX2) AND (pY1 = pY2) then Exit; {end-points coincide ..}

  if NOT ClipLineOK(pX1,pY1,pX2,pY2) then Exit;

  Line(RoundLongInt(pX1),RoundLongInt(pY1),RoundLongInt(pX2),RoundLongInt(pY2));

{TO BE REMOVED ONE DAY - !!!!!}
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
if Slow then BEGIN
  WaitToGo(Ch);
  if Ch = #27 then BEGIN WritePCX('ScrCopy.PCX', Slow); Halt; END;
END;
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  LaMpos:=0;
  for i:=1 to LaMsize do if (L_Name = LaM[i].LName) then LaMpos:=i;

  if (LaMpos = 0) then {no entry in LAM for this polyline}
    DXFLine(L_Name,DXFelev,p_X121(pX1),p_Y121(pY1), p_X121(pX2),p_Y121(pY2))
  else
  with LaM[LaMpos] do BEGIN
    if PLopt then BEGIN  {write verteces in ~POLY*.$xy file}
      Assign(Tfile,FName);
      Append(Tfile);
      WriteLn(Tfile,ForceReal(p_X121(pX1)),' ',ForceReal(p_Y121(pY1))
      ,' ',ForceReal(p_X121(pX2)),' ',ForceReal(p_Y121(pY2)));
      Close(Tfile);
      NrVerts:=NrVerts+2;
    END
    else BEGIN
      ExpectDXFplines;
      AddVertexPline(LName, p_X121(pX1),p_Y121(pY1));
      AddVertexPline(LName, p_X121(pX2),p_Y121(pY2));
      DXFplineEnd(LName);
    END;
  END; {.. with LaM[LaMpos]}
END; {.. PDline}

{----------------------------------------------------------------------------}
procedure vPDline(L_Name:Str31; var pX1,pY1,pX2,pY2: double; var Status:Byte);
{Same as PDline but pX1,pY1,pX2,pY2 return the cuts with ViewPort edges.     }
{If both end-points are outside and the line crosses the ViewPort, ie it is  }
{a 'curtain', then will be ploted only if Status is transmitted as 0.        }
{Status returns 00 if the line is totally inside ViewPort                    }
{Status returns 10 if the line has end 1 outside ViewPort and end 2 inside   }
{Status returns 02 if the line has end 2 outside ViewPort and end 1 inside   }
{Status returns 12,22,14,24 if the line is a curtain                         }
{Status returns 100 if end points coincide                                   }
{Status returns 200 if the line is totaly outside ViewPort                   }

var V_Port: ViewPortType;
    LaMpos,i,LocalStatus: Byte;

BEGIN  {vPDline ..}
  if (pX1 = pX2) AND (pY1 = pY2) then BEGIN {end-points coincide ..}
    Status:=100;
    Exit;
  END;

  GetViewSettings(V_Port);
  with V_Port do BEGIN {V_Port clip and 1/0.0 protection at <!> ..}
    if (pX1 < 0) AND (pX2 < 0) then BEGIN
      pX1:=0;  pX2:=0; Status:=200;
      Exit;
    END;
    if ((pX1 > (x2-x1)) AND (pX2 > x2-x1)) then BEGIN
      pX1:=x2-x1;  pX2:=x2-x1;  Status:=200;
      Exit;
    END;
    if (pY1 < 0) AND (pY2 < 0) then BEGIN
      pY1:=0; pY2:=0;  Status:=200;
      Exit;
    END;
    if (pY1 > (y2-y1)) AND (pY2 > (y2-y1)) then BEGIN
      pY1:=y2-y1; pY2:=y2-y1;  Status:=200;
      Exit;
    END;

    LocalStatus:=00;
    if (pX1 < 0) then BEGIN
      pY1:=pY1-(pY2-pY1)/(pX2-pX1)*pX1; pX1:=0;
      LocalStatus:=LocalStatus+10;
    END;
    if (pX2 < 0) then BEGIN
      pY2:=pY1-(pY2-pY1)*pX1/(pX2-pX1); pX2:=0;
      LocalStatus:=LocalStatus+02;
    END;
    if (pY1 < 0) then BEGIN
      pX1:=pX1-(pX2-pX1)*pY1/(pY2-pY1); pY1:=0;
      LocalStatus:=LocalStatus+10;
    END;
    if (pY2 < 0) then BEGIN
      pX2:=pX1-(pX2-pX1)*pY1/(pY2-pY1); pY2:=0;
      LocalStatus:=LocalStatus+02;
    END;
    if (pX1 > (x2-x1)) then BEGIN
      LocalStatus:=LocalStatus+10;
      if (pX2 = pX1) then  Exit;
      pY1:=pY1+(pY2-pY1)*(x2-x1-pX1)/(pX2-pX1); pX1:=x2-x1; {<!>}
    END;
    if (pX2 > (x2-x1)) then BEGIN
      LocalStatus:=LocalStatus+02;
      if (pX2 = pX1) then  Exit;
      pY2:=pY1+(pY2-pY1)*(x2-x1-pX1)/(pX2-pX1); pX2:=x2-x1;
    END;
    if (pY1 > (y2-y1)) then BEGIN
      LocalStatus:=LocalStatus+10;
      if (pY2 = pY1) then  Exit;
      pX1:=pX1+(pX2-pX1)*(y2-y1-pY1)/(pY2-pY1); pY1:=y2-y1;
    END;
    if (pY2 > (y2-y1)) then BEGIN
      LocalStatus:=LocalStatus+02;
      if (pY2 = pY1) then  Exit;
      pX2:=pX2+(pX1-pX2)*(y2-y1-pY2)/(pY1-pY2); pY2:=y2-y1;
    END;
  END; {.. with V_Port}

  if (LocalStatus >= 12) AND ((Status < 12) OR (Status > 24)) then BEGIN
    {the line is a curtain, but is not drawn ..}
    Status:=LocalStatus;  Exit; {<!!>}
  END;

  Status:=LocalStatus;

  Line(RoundLongInt(pX1),RoundLongInt(pY1),RoundLongInt(pX2),RoundLongInt(pY2));

  if (NOT D_X_F) then  Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  LaMpos:=0;
  for i:=1 to LaMsize do if (L_Name = LaM[i].LName) then LaMpos:=i;

  if (LaMpos = 0) then BEGIN {no entry in LAM for this polyline ..}
    DXFLine(L_Name,DXFelev,p_X121(pX1),p_Y121(pY1), p_X121(pX2),p_Y121(pY2));
    Exit;
  END;

  with LaM[LaMpos] do BEGIN
    if PLopt then BEGIN  {write vertices in ~POLY*.$xy file}
      Assign(Tfile,FName);  Append(Tfile);
      WriteLn(Tfile,ForceReal(p_X121(pX1)),' ',ForceReal(p_Y121(pY1)),' '
      ,ForceReal(p_X121(pX2)),' ',ForceReal(p_Y121(pY2)));
      Close(Tfile);
      NrVerts:=NrVerts+2;
    END
    else BEGIN
      ExpectDXFplines;
      AddVertexPline(LName, p_X121(pX1),p_Y121(pY1));
      AddVertexPline(LName, p_X121(pX2),p_Y121(pY2));
      DXFplineEnd(LName);
    END;
  END; {.. with LaM[LaMpos]}
END; {.. vPDline}

{----------------------------------------------------------------------------}
procedure PDlinePtAng2(L_Name:Str31; pX,pY, cA,sA: double);
{Draw on screen & to DXF an infinite linie through (pX,pY) and of angle Atan(sA/cA)    }

var V_Port: ViewPortType;
    m,n,pX1,pY1,pX2,pY2:double;

BEGIN
  GetViewSettings(V_Port);
  with V_Port do BEGIN  {get V_Port-border intersection points}
    if (sA = 0.0) then BEGIN
      pX1:=0.0;    pY1:=pY;
      pX2:=x2-x1;  pY2:=pY;
    END
    else
    if (sA = 1.0) OR (sA = -1.0) then BEGIN
      pX1:=pX;  pY1:=0.0;
      pX2:=pX;  pY2:=y2-y1;
    END
    else BEGIN
      m:=-sA/cA;   {slope      }
      n:=pY-m*pX;  {Y intercept}
      pX1:=0.0;    pY1:=n;
      pX2:=x2-x1;  pY2:=m*(x2-x1)+n;
{     pX1:=-n/m; pY1:=0.0;  pX2:=(y2-y1-n)/m; pY2:=y2-y1;   }
    END;
  END;
  PDline(L_Name, pX1,pY1,pX2,pY2);
END; {.. PDlinePtAng2}

{----------------------------------------------------------------------------}
procedure PDlinePtAng(L_Name:Str31; pX,pY, Alpha: double);
{Draw on screen and in DXF a linie through (pX,pY) and at angle Alpha in RAD}

BEGIN
  PDlinePtAng2(L_Name, pX,pY, cos(Alpha),sin(Alpha));
END; {.. PDlinePtAng}

{----------------------------------------------------------------------------}
procedure DischardPline(L_Name:Str31);
{Optimize verteces in 'L_Name' and write the corresponding polyline to DXF}

var  LaMpos: Byte;
     nLinBUF,   {number of lines in BUF^ }
     LftEd,     {index of the left-end coordinate of the current poliline }
     RgtEd,     {index of the right-end coordinate of the current poliline}
     i,j: Word;
     OK: Boolean;
     BUF: ^LnsBUF;
     AuxL: LineOFsingle;
     AuxP: PointOFsingle;
     x_1,y_1,x_2,y_2: double;
     OldDXFcolor: Byte;  {color code of the DXF entities        }

{- - - - - - - - - - - - - - - - - - - - - - - - - - - -}
function zFrom(LayName:Str31):Str31;
{Delete 'c'and replace '_' with '.' to change LayName into a number }
BEGIN
  Delete(LayName,1,1);
  if (Pos('_',LayName) > 0) then LayName[Pos('_',LayName)]:='.';
  zFrom:=LayName;
END;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - -}

BEGIN  {DischardPline ..}
  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  LaMpos:=0;  {finds the record for L_Name}
  for i:=1 to LaMsize do if (L_Name = LaM[i].LName) then LaMpos:=i;
  if (LaMpos = 0) OR (NOT LaM[LaMPos].PLopt) then Exit;

  OldDXFcolor:=DXFcolor;
  with LaM[LaMpos] do BEGIN
    Assign(Tfile,FName);  Reset(Tfile);
    DXFcolor:=LColor;
    PLineTkns:=PLtkns; {make current the thickness from LayManager}
    if (NrVerts > 0) then BEGIN

      New(BUF); {!!! - If error 203 reduce Buf_Size above ..}

      repeat  {transfer data from Tfile to BUF ..}
        nLinBUF:=0;
        while NOT Eof(Tfile) AND (nLinBUF < Buf_Size) do BEGIN
          Read(Tfile,x_1);
          Read(Tfile,y_1);
          Read(Tfile,x_2);
          ReadLn(Tfile,y_2);
          if (nLinBUF > 0) then BEGIN {check for identical previous segments ..}
            i:=0;
            repeat
              Inc(i);
              OK:=FALSE;
              if NOT Coinc2Pts2D(BUF^[i].P1.x, BUF^[i].P1.y,
                 x_1, y_1, EpsCoinc) then OK:=TRUE;
              if NOT Coinc2Pts2D(BUF^[i].P2.x, BUF^[i].P2.y,
                 x_2, y_2, EpsCoinc) then OK:=TRUE;
              if OK then BEGIN
                OK:=FALSE;
                if NOT Coinc2Pts2D(BUF^[i].P1.x, BUF^[i].P1.y,
                   x_2, y_2, EpsCoinc) then OK:=TRUE;
                if NOT Coinc2Pts2D(BUF^[i].P2.x, BUF^[i].P2.y,
                   x_1, y_1, EpsCoinc) then OK:=TRUE;
              END;
            until (NOT OK) OR (i = nLinBUF);
          END
          else OK:=TRUE;
          if OK then BEGIN
            Inc(nLinBUF);
            BUF^[nLinBUF].P1.x:=x_1;
            BUF^[nLinBUF].P1.y:=y_1;
            BUF^[nLinBUF].P2.x:=x_2;
            BUF^[nLinBUF].P2.y:=y_2;
          END;
        END; {.. while NOT Eof(Tfile)}
{- - - - - - - - - - - - - - - - - - - - - - -}
        RgtEd:=0;
        repeat {until (RgtEd >= nLinBUF)}
          Inc(RgtEd);
          LftEd:=RgtEd;
          i:=RgtEd+1;
          while (i <= nLinBUF) do BEGIN {arrange segments back-to-back ..}
{- - - - - - - - - - - - - - - - - - - - - - -}
            OK:=FALSE;
            if Coinc2Pts2D(BUF^[LftEd].P1.x, BUF^[LftEd].P1.y,
              BUF^[i].P1.x, BUF^[i].P1.y, EpsCoinc) then BEGIN
              {ends coincide to the left if inverted ..}
              OK:=TRUE;
              AuxP:=BUF^[i].P1;
              BUF^[i].P1:=BUF^[i].P2;
              BUF^[i].P2:=AuxP;
            END
            else {ends coincide as they are ..}
              OK:=Coinc2Pts2D(BUF^[LftEd].P1.x,BUF^[LftEd].P1.y,
              BUF^[i].P2.x,BUF^[i].P2.y, EpsCoinc);

            if OK then BEGIN {move to the left ..}
              AuxL:=BUF^[i];
              for j:=i downto LftEd+1 do BUF^[j]:=BUF^[j-1];
              BUF^[LftEd]:=AuxL;
              Inc(RgtEd);
              i:=RgtEd;
            END; {.. move to the left}
{- - - - - - - - - - - - - - - - - - - - - - -}
            if (NOT OK) then BEGIN {no fit to the left ..}
              if Coinc2Pts2D(BUF^[RgtEd].P2.x,BUF^[RgtEd].P2.y,
                BUF^[i].P2.x,BUF^[i].P2.y, EpsCoinc) then BEGIN
                {ends coincide to the right if inverted ..}
                OK:=TRUE;
                AuxP:=BUF^[i].P1;
                BUF^[i].P1:=BUF^[i].P2;
                BUF^[i].P2:=AuxP;
              END
              else {ends coincide as they are ..}
                OK:=Coinc2Pts2D(BUF^[RgtEd].P2.x,BUF^[RgtEd].P2.y,
                BUF^[i].P1.x,BUF^[i].P1.y, EpsCoinc);

              if (OK AND (RgtEd+1 < i)) then BEGIN {move to the right ..}
                Inc(RgtEd);
                AuxL:=BUF^[i];
                for j:=i downto RgtEd+1 do BUF^[j]:=BUF^[j-1];
                BUF^[RgtEd]:=AuxL;
                i:=RgtEd;
              END; {.. move to the right}
            END;
{- - - - - - - - - - - - - - - - - - - - - - -}
            Inc(i);
          END; {.. arrange segments back-to-back}
        until (RgtEd >= nLinBUF);
{- - - - - - - - - - - - - - - - - - - - - - -}
        AuxL:=BUF^[1];
        with AuxL do BEGIN {write 1st segment to DXF ..}
          ExpectDXFplines;
          AddVertexPline(LName, P1.x,P1.y);
          AddVertexPline(LName, P2.x,P2.y);
          if xyzOUT then BEGIN
            WriteLn(xyzFile,'----------------------------------------------');
            WriteLn(xyzFile,P1.x,' ',P1.y,' ',zFrom(LName));
            WriteLn(xyzFile,P2.x,' ',P2.y,' ',zFrom(LName));
          END;
        END;  {.. write 1st segment to DXF}

        for i:=2 to nLinBUF do BEGIN
          if Coinc2Pts2D(AuxL.P2.x,AuxL.P2.y, BUF^[i].P1.x,BUF^[i].P1.y, EpsCoinc) then BEGIN
            AddVertexPline(LName, BUF^[i].P2.x,BUF^[i].P2.y); {write next vertex to DXF}
            if xyzOUT then
              WriteLn(xyzFile,BUF^[i].P2.x,' ',BUF^[i].P2.y,' ',zFrom(LName));
          END
          else BEGIN {close old polyline and begin a new one ..}
            DXFplineEnd(LName);
            ExpectDXFplines;
            AddVertexPline(LName, BUF^[i].P1.x,BUF^[i].P1.y);
            AddVertexPline(LName, BUF^[i].P2.x,BUF^[i].P2.y);
            if xyzOUT then BEGIN
              WriteLn(xyzFile,'----------------------------------------------');
              WriteLn(xyzFile,BUF^[i].P1.x,' ',BUF^[i].P1.y,' ',zFrom(LName));
              WriteLn(xyzFile,BUF^[i].P2.x,' ',BUF^[i].P2.y,' ',zFrom(LName));
            END;
          END;
          AuxL:=BUF^[i];
        END; {.. for i:=2 to nLinBUF}
        DXFplineEnd(LName);
{- - - - - - - - - - - - - - - - - - - - - - -}
      until Eof(Tfile); {.. transfer data from Tfile to BUF}
      Dispose(BUF);
    END; {.. (NrVerts > 0)}
    LName:='++';  {.. record is now 'Empty'}
    Close(Tfile);
    Erase(Tfile);  {.. erase the respective '~POLY*.$xy' file}
  END; {.. with LaM[LaMpos]}

  DXFcolor:=OldDXFcolor;

END; {.. DischardPline}

{----------------------------------------------------------------------------}
procedure DischardALLPoly;
var i: Byte;
BEGIN
  if (NOT D_X_F) then Exit;
  for i:=1 to LaMsize do BEGIN
    if (LaM[i].LName <> '++') AND (LaM[i].NrVerts > 0) then
     DischardPline(LaM[i].LName);
    LaM[i].LName:='++';
  END;
END; {.. DischardALLPoly}

{============================================================================}
procedure PDcircle(L_Name:Str31;  Xc,Yc, R: double);
{Draw a circle on the screen and to the DXF file                             }
{var V_Port : ViewPortType;   }

BEGIN
  Circle(RoundLongInt(Xc),RoundLongInt(Yc),RoundLongInt(R));
  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  Xc:=p_X121(Xc);
  Yc:=p_Y121(Yc);

  R:=p2R121(R);

{ Check if the center of the circle is inside ViewPort ..}
{
  GetViewSettings(V_Port);
  with V_Port do if Clip then BEGIN
    if (Xc < -R) then Exit;
    if (Xc > x2-x1+R) then Exit;
    if (Yc < -R) then Exit;
    if (Yc > Y2-Y1+R) then Exit;
  END;
}
  DXFcircle(L_Name,DXFelev,Xc,Yc,R);
END; {.. PDcircle}

{----------------------------------------------------------------------------}
procedure DXFcircle(L_Name:Str31; DXFelev, Xc,Yc, R: double);
{Write a circle to the DXF file                             }

BEGIN
  if (NOT D_X_F) then Exit;

  if R = 0.0 then Exit; {skip zero-R circles}

  if (L_Name = '') then L_Name:=DXFLayerName;

  WriteLn(DXFfile,'CIRCLE');
  WriteLn(DXFfile,'8');
  WriteLn(DXFfile,L_Name);
  WriteLn(DXFfile,'6');
  WriteLn(DXFfile,DXFlnType);
  WriteLn(DXFfile,'62');
  WriteLn(DXFfile,DXFcolor:1);
  WriteLn(DXFfile,'10');
  WriteLn(DXFfile,Xc);
  WriteLn(DXFfile,'20');
  WriteLn(DXFfile,Yc);
  WriteLn(DXFfile,'30');
  WriteLn(DXFfile,DXFelev);
  WriteLn(DXFfile,'40');
  WriteLn(DXFfile,R);
  WriteLn(DXFfile,'0');

END; {.. DXFcircle}

{----------------------------------------------------------------------------}
procedure PDarc(L_Name:Str31; xC,yC, StAng,EndAng, R: double);
{Draw an arc on the screen and to the DXF file                               }
var Delta_Angle: double;

BEGIN
  Delta_Angle:=EndAng-StAng;
  if (Delta_Angle < 0) then Delta_Angle:=360+Delta_Angle;
  if (Round(StAng)  < 0) then BEGIN
    StAng:=StAng+360;
    EndAng:=StAng+Delta_Angle;
  END;
  if (Round(EndAng) < 0) then BEGIN
    EndAng:=EndAng+360;
    StAng:=EndAng-Delta_Angle;
  END;


  Arc(RoundLongInt(xC),RoundLongInt(yC),RoundLongInt(StAng),RoundLongInt(EndAng),RoundLongInt(R));

  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  xC:=p_X121(xC);
  yC:=p_Y121(yC);
  R:=p2R121(R);

{ Check if the arc is inside ViewPort !!!!
  GetViewSettings(ViewPort);
  with ViewPort do if Clip then BEGIN
    if (Xc < -R) then Exit;
    if (Xc > x2-x1+R) then Exit;
    if (Yc < -R) then Exit;
    if (Yc > Y2-Y1+R) then Exit;
  END;
}
  DXFarc(L_Name,xC,yC,StAng,EndAng,R);

END; {.. PDarc}

{----------------------------------------------------------------------------}
procedure PDarc3pts(L_Name:Str31; x1,y1, x2,y2, x3,y3: double);
{Draw an arc on the screen and to the DXF file                               }
var  AuxD, xC,yC, StAng,EndAng, R123: double;

BEGIN
  Circ3Pts(x1,y1,x2,y2,x3,y3, R123, xC,yC);

  if (Abs(R123) > 1.0E6) then BEGIN {straight line not arc ..}
    PDline(L_Name, x1,y1,x3,y3);
    Exit;
  END;

  if (R123 >= 0) then BEGIN
    StAng :=U3pts2D(xC+R123,-yC, xC,-yC, x3,-y3)*DEG;
    EndAng:=U3pts2D(xC+R123,-yC, xC,-yC, x1,-y1)*DEG;
  END
  else BEGIN
    StAng :=U3pts2D(xC-R123,-yC, xC,-yC, x1,-y1)*DEG;
    EndAng:=U3pts2D(xC-R123,-yC, xC,-yC, x3,-y3)*DEG;
    R123:=-R123;
  END;

{  if (StAng < 0) then WaitToGo(Ch); }
{
  if (StAng < 0) then StAng:=360+StAng;
  if (EndAng < 0) then EndAng:=360+EndAng;
  if StAng > EndAng then BEGIN
    AuxD:=StAng;  StAng:=EndAng;  EndAng:=AuxD;
  END;
}

  PDarc(L_Name, xC,yC, StAng,EndAng, R123);

END; {.. PDarc3pts}

{----------------------------------------------------------------------------}
procedure DXFarc(L_Name:Str31; xC,yC,StAng,EndAng,R: double);
{Write an arc to the DXF file                             }

BEGIN
  if (NOT D_X_F) then Exit;

  if (R = 0.0) OR (Abs(StAng-EndAng) < 1.0E-3) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  WriteLn(DXFfile,'ARC');
  WriteLn(DXFfile,'8');
  WriteLn(DXFfile,L_Name);
  WriteLn(DXFfile,'62');
  WriteLn(DXFfile,DXFcolor:1);
  WriteLn(DXFfile,'10');
  WriteLn(DXFfile,Xc);
  WriteLn(DXFfile,'20');
  WriteLn(DXFfile,Yc);
  WriteLn(DXFfile,'30');
  WriteLn(DXFfile,DXFelev);
  WriteLn(DXFfile,'40');
  WriteLn(DXFfile,R);
  WriteLn(DXFfile,'50');
  WriteLn(DXFfile,StAng);
  WriteLn(DXFfile,'51');
  WriteLn(DXFfile,EndAng);
  WriteLn(DXFfile,'0');
END; {.. DXFarc}

{----------------------------------------------------------------------------}
procedure DXF3Dface(L_Name:Str31; VizCOD: Byte; P_4: Poly_4);
{Write a planar 3D-face in the DXF file                                      }

var V_Port: ViewPortType;
    i: Byte;
    CompleteOut: Boolean;

BEGIN
  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  if DmyFaces then VizCOD:=15 else Exit;
  GetViewSettings(V_Port);
{- - - - - - - - - - - - - - - - - - - - - - -}
  CompleteOut:=TRUE;
  with V_Port do BEGIN {check if the polygon is inside plot window ..}
    for i:=1 to 4 do BEGIN
      if (P_4[i].x > 0) AND (P_4[i].x < x2-x1) AND
       (P_4[i].y > 0) AND (P_4[i].y < y2-y1) then CompleteOut:=FALSE;
      {Convert from screen space to object space ..}
      P_4[i].x:=p_X121(P_4[i].x);
      P_4[i].y:=p_Y121(P_4[i].y);
    END;
    if Clip AND CompleteOut then Exit;
  END; {.. with}

  WriteLn(DXFfile,'3DFACE');
  WriteLn(DXFfile,'8');
  WriteLn(DXFfile,L_Name);
  WriteLn(DXFfile,'62');
  WriteLn(DXFfile,DXFcolor:1);
  WriteLn(DXFfile,'10');
  WriteLn(DXFfile,P_4[1].x);
  WriteLn(DXFfile,'20');
  WriteLn(DXFfile,P_4[1].y);
  WriteLn(DXFfile,'30');
  WriteLn(DXFfile,DXFelev);
  WriteLn(DXFfile,'11');
  WriteLn(DXFfile,P_4[2].x);
  WriteLn(DXFfile,'21');
  WriteLn(DXFfile,P_4[2].y);
  WriteLn(DXFfile,'31');
  WriteLn(DXFfile,DXFelev);
  WriteLn(DXFfile,'12');
  WriteLn(DXFfile,P_4[3].x);
  WriteLn(DXFfile,'22');
  WriteLn(DXFfile,P_4[3].y);
  WriteLn(DXFfile,'32');
  WriteLn(DXFfile,DXFelev);
  WriteLn(DXFfile,'13');
  WriteLn(DXFfile,P_4[4].x);
  WriteLn(DXFfile,'23');
  WriteLn(DXFfile,P_4[4].y);
  WriteLn(DXFfile,'33');
  WriteLn(DXFfile,DXFelev);
  WriteLn(DXFfile,'70');
  WriteLn(DXFfile,VizCOD:5);
  WriteLn(DXFfile,'0');
END; {.. DXF3Dface}

{----------------------------------------------------------------------------}
procedure PDdrawPoly(L_Name:Str31; nEdges:Byte; P_8: Poly_8; ClosePoly: Boolean);
{Draw on the screen and to DXF a poligon of maximum 8 vertices. }

type  Poly9 = array[1..9] of PointType; {integers for DrawPoly}
var   P9: Poly9; i: Byte;

BEGIN {PDdrawPoly ..}
  for i:=1 to nEdges do BEGIN
    P9[i].x:=RoundLongInt(P_8[i].x);
    P9[i].y:=RoundLongInt(P_8[i].y);
  END;
  if ClosePoly then  BEGIN
    P9[i+1].x:=P9[1].x;
    P9[i+1].y:=P9[1].y;
    DrawPoly(nEdges+1, P9); {this is a Pascal function}
  END
  else
    DrawPoly(nEdges, P9); {this is a Pascal function}

  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  ExpectDXFplines;
  for i:=1 to Abs(nEdges) do
   AddVertexPline(L_Name, p_X121(P_8[i].x),p_Y121(P_8[i].y));

  if ClosePoly then
    AddVertexPline(L_Name, p_X121(P_8[1].x),p_Y121(P_8[1].y));

  DXFplineEnd(L_Name);
END; {.. PDdrawPoly}

{----------------------------------------------------------------------------}
procedure SetDXFchH(Font:Word; Inc_DXF_font:Boolean);
BEGIN
  IncDXFont:=Inc_DXF_font;

  if (Font = SmallFont) then
    DXFchH:=Round(p2R121(PixChH)*85)/100;  {..85/100 of screen height}

  if IncDXFont OR (Font <> SmallFont) then
    DXFchH:=Round(p2R121(PixChH)*100)/100;  {..100/100 screen height}
END; {.. SetDXFchH}

{----------------------------------------------------------------------------}
procedure PDfillPoly(L_Name:Str31; nEdges:Byte; P_8:Poly_8);
{Draw w/ FillPoly on the screen and to DXF a poligon of maximum 8 vertices.  }
{Subroutine designed to be used by D_3D.PAS primarely.                       }

type Poly8 = array[1..8] of PointType;
var  P8: Poly8;
     P_4: Poly_4;
     i: Byte;

BEGIN {PDfillPoly ..}
  for i:=1 to nEdges do BEGIN
    P8[i].x:=RoundLongInt(P_8[i].x);
    P8[i].y:=RoundLongInt(P_8[i].y);
  END;
  FillPoly(nEdges, P8);

{TO BE REMOVED ONE DAY - !!!!!}
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
if Slow then BEGIN
  WaitToGo(Ch);
  if Ch = #27 then BEGIN WritePCX('ScrCopy.PCX', Slow); Halt; END;
END;
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

  if (NOT D_X_F) then Exit;

  if (L_Name = '') then L_Name:=DXFLayerName;

  P_4[1]:=P_8[1];
  P_4[2]:=P_8[2];
  P_4[3]:=P_8[3];
  if (nEdges > 3) then P_4[4]:=P_8[4];
  if nEdges = 4 then DXF3Dface(L_Name,0,P_4) {1234}
  else case nEdges of
    3: BEGIN
      P_4[4]:=P_8[3];
      DXF3Dface(L_Name,0,P_4); {1233}
    END;
    8: BEGIN
      DXF3Dface(L_Name,8,P_4); {1234}
      P_4[2]:=P_8[4];
      P_4[3]:=P_8[5];
      P_4[4]:=P_8[6];
      DXF3Dface(L_Name,9,P_4); {1456}
      P_4[2]:=P_8[6];
      P_4[3]:=P_8[7];
      P_4[4]:=P_8[8];
      DXF3Dface(L_Name,1,P_4); {1678}
    END;
    7: BEGIN
      DXF3Dface(L_Name,8,P_4); {1234}
      P_4[2]:=P_8[4];
      P_4[3]:=P_8[4];
      P_4[4]:=P_8[7];
      DXF3Dface(L_Name,7,P_4); {1447}
      P_4[1]:=P_8[4];
      P_4[2]:=P_8[5];
      P_4[3]:=P_8[6];
      DXF3Dface(L_Name,8,P_4); {4567}
    END;
    6: BEGIN
      DXF3Dface(L_Name,8,P_4); {1234}
      P_4[2]:=P_8[4];
      P_4[3]:=P_8[5];
      P_4[4]:=P_8[6];
      DXF3Dface(L_Name,1,P_4); {1456}
    END;
    5: BEGIN
      DXF3Dface(L_Name,8,P_4); {1234}
      P_4[2]:=P_8[4];
      P_4[3]:=P_8[4];
      P_4[4]:=P_8[5];
      DXF3Dface(L_Name,3,P_4); {1445}
    END;
  END; {.. case}
END; {.. PDfillPoly}

function FitText(x,y,xS,yS:double; S: string): string;
{Fits text to view port                                }
var V_Port: ViewPortType;
BEGIN
  FitText:='';
  GetViewSettings(V_Port);
  with V_Port do if Clip then BEGIN
    if (xS+Length(S)*PixChW < 0) then Exit;
    if (yS-Length(S)*PixChW > MaxX) then Exit;
    if (xS+2*PixChH < 0) then Exit;
    if (yS-2*PixChH > MaxY) then Exit;
    GetTextSettings(TextSettings);
    with TextSettings do if (Direction = 0) then BEGIN
      while (x+x1-(0.5*Length(S)*PixChW)*Horiz < 0) AND (Length(S) > 1) do BEGIN
        Delete(S,1,1);  {..delete from left of string}
        S[1]:='Æ';
      END;
      while (x+x1+(0.5*Length(S)*PixChW)*(2-Horiz) > MaxX)
      AND (Length(S) > 1) do BEGIN
        Delete(S,Length(S),1);  {..delete from right of string}
        S[Length(S)]:='Ø';
      END;
    END; {..with}
  END;
  FitText:=S;
END;  {.. FitText}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure PDtext(L_Name:Str31; x,Ofx, y,Ofy: double; S: string);
{Write a string on the screen and in the DXF file.                           }
{Ofx and Ofy are the horizontal offset and vertical offset of the string.    }
{NOTE AutoCAD STANDARD font has the width/height ratio of characters like 8,H}
{g,h etc. equal to w/h=0.667.  'width ratio' WR changes the standard w/h such}
{that w becomes w = h*0.667*WR.                                              }

var xt,yt:double;
    ViewPort: ViewPortType;

BEGIN  {PDtext..}
  GetTextSettings(TextSettings);

  with TextSettings do BEGIN
    SetDXFchH(Font,IncDXFont);

    if (Direction = HorizDir) then BEGIN
      xt:=x + Ofx*PixChW;
      yt:=y + Ofy*PixChH;
    END
    else BEGIN
      xt:=x + Ofx*PixChH;
      yt:=y + Ofy*PixChW;
    END;
  END;

  S:=FitText(x,y,xt,yt,S);

  if (S = '') then Exit;

  GetViewSettings(ViewPort);
  FullPort;
  with ViewPort do BEGIN
    OutTextXY(TruncInt(x1+xt),TruncInt(y1+yt), S);
    SetViewPort(x1,y1, x2,y2, Clip);
  END;


  if (L_Name = '') then L_Name:=DXFLayerName;
  DXFtext(L_Name, p_X121(xt), p_Y121(yt), S);

END;  {..PDtext}

{----------------------------------------------------------------------------}
procedure PD_text(L_Name:Str31; x,Ofx, y,Ofy: double; S: string);
{Same as PDtext but when encountering '_' subscripts the rest of S up to '^' }
{and when encountering '^' superscripts the rest of S up to '_'              }
{Alternate between GREEK and ROMAN texts in DXF with '^_' or '_^' separators!}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
function ZerOrTrueLgt(Scr:string):ShortInt;
var TrueLgt:ShortInt;   SameLgt:Boolean;
BEGIN
  SameLgt:=TRUE;
  TrueLgt:=Length(Scr);
  while (Scr <> '') do BEGIN
    if (Scr[1] = '_') OR (Scr[1] = '^') then BEGIN
      Dec(TrueLgt);
      SameLgt:=FALSE;
    END;
    Delete(Scr,1,1);
  END;
  if SameLgt then ZerOrTrueLgt:=0 else ZerOrTrueLgt:=TrueLgt;
END; {..ZerOrTrueLgt}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

var  UpDn:double;
     SL:string;
     Ofs:ShortInt;

BEGIN  {PD_text ..}
  GetTextSettings(TextSettings);
  with TextSettings do BEGIN
    Blanks2Offs(S,Ofs);
    if (Direction = HorizDir) then
      Ofx:=Ofx+Ofs-0.4*ZerOrTrueLgt(S)*(Horiz DIV 2);
    if (Direction = VertDir ) then
      Ofy:=Ofy-Ofs+0.5*ZerOrTrueLgt(S)*(Vert DIV 2);
    repeat
      SL:=S;
      UpDn:=0;
      if (Pos('_',S) > 0) AND ((Pos('_',S) < Pos('^',S)) OR (Pos('^',S) = 0)) then BEGIN
        UpDn:=0.40;
        Delete(SL,Pos('_',SL),Length(SL));
        Delete(S,1,Pos('_',S));
      END
      else
      if (Pos('^',S) > 0) AND ((Pos('^',S) < Pos('_',S)) OR (Pos('_',S) = 0)) then BEGIN
        UpDn:=-0.40;
        Delete(SL,Pos('^',SL),Length(SL));
        Delete(S,1,Pos('^',S));
      END;

      PDtext(L_Name, x,Ofx, y,Ofy, SL);  {PDtext updates TextSettings!!}

      if (UpDn <> 0) then BEGIN
        if (Direction = HorizDir) then BEGIN
          SetTextJustify(LeftText, Vert);
          Ofx:=Ofx + 0.5*(2-Horiz)*Length(SL);
          Ofy:=Ofy + UpDn;
        END;
        if (Direction = VertDir) then BEGIN
          SetTextJustify(Horiz, BottomText);
          Ofx:=Ofx + UpDn;
          Ofy:=Ofy - 0.5*(2-Vert)*Length(SL);
        END;
      END;
    until (UpDn = 0);
  END; {..with}
END;  {..PD_text}

{----------------------------------------------------------------------------}
procedure CloseDXFfile;  {Write end-of-file lines to DXF file..}

BEGIN
  if (NOT DXFon) then Exit;
  Append(DXFfile);
  WriteLn(DXFfile,'ENDSEC');
  WriteLn(DXFfile,'0');
  WriteLn(DXFfile,'EOF');
  Close(DXFfile);
  DXFon:=FALSE;
  D_X_F:=FALSE;
END; {.. CloseDXFfile}

{============================================================================}
{============================================================================}
var  k: Word;

BEGIN {LibDXF ..}
  Slow:=FALSE;   {This is for debugging only !!}

  EraseAll('*.$xy');  {erase temp files leftover from LibDXF}
  DXFon:=FALSE;
  D_X_F:=FALSE;
  IncDXFont:=TRUE;  {By default, SmallFont will be 15% bigger in DXF}
  xyzOUT:=FALSE;
  xA_1:=0; yA_1:=0; zA_1:=0;  {..previous vertex of current polyline    }
  xA_2:=0; yA_2:=0; zA_2:=0;  {..2nd previous vertex of current polyline}
  for k:=1 to LaMsize do LaM[k].LName:='++';  {..reset layer manager}
  DXFlnType:='CONTINUOUS';  {..polyline type}
  DXFLayerName:='0';  {..implicit DXF layer name                }
  PLineTkns:=0.0;     {..default polyline thickness             }
  EpsCoinc :=0.0;     {..polyline vertice coincidence precision }
  EpsColin :=0.0;     {..polyline vertice coliniarity precision }
  DXFelev  :=0.0;     {..default DXF elevation                  }
  DXFcolor :=7;       {..default DXF color = white              }
  DmyFaces :=FALSE;
  DrawPoint:=FALSE;
  DXFchH:=7.00;  {default DXF text height - it is changed in PDtext!  }
  DXFchW:=0.85;  {default DXF text width factor - remains unchanged!  }
END. {.. LibDXF}
