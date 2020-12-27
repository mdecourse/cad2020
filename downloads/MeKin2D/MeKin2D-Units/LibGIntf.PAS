Unit LibGIntf;
{ $R+ }
{ $S- }

{=============================================================================
  Unit for graphic interfacing
  (c) P.A. Simionescu 2018
=============================================================================}

INTERFACE

{---------------------------------------------------------------------------}
procedure FullPort;    {set the view port to the entire screen     }

procedure DrawBorder;  {draw a border around the current view port }

procedure MainWindow(k:Byte); {main window in the graphic interface}

procedure Header(HoriPoz:Shortint; Msg:string); {put a header on the top    }
procedure Footer(HoriPoz:Shortint; Msg:string); {put a status line on bottom}

procedure ReadStrG(Msg:string;  var InStr:string;  Lgt:ShortInt);
function  ReadCh_G(Msg:string): Char;

{============================================================================}
IMPLEMENTATION

uses  CRT,
      Graph,
      LibGraph,
      LibInOut,
      LibMath,
      LibDXF;

var  ViewPort_L    : ViewPortType;
     FillSettings_L: FillSettingsType;
     LineSettings_L: LineSettingsType;
     Color_L: Word;

var  Ch: Char;

{============================================================================}
procedure FullPort;  {Set the view port to the entire screen  }
BEGIN
  SetViewPort(0, 0, MaxX, MaxY, ClipOn);
END;  {..FullPort}

{----------------------------------------------------------------------------}
procedure DrawBorder;
{Draw a border around the current view port on the screen and in the DXF file}

BEGIN
  SetColorBGI_DXF(MaxColor);
  GetLineSettings(LineSettings_L);
  SetLineStyle(SolidLn, 0, NormWidth);
  GetViewSettings(ViewPort_L);

  with ViewPort_L do BEGIN
    Rectangle(0, 0, x2-x1, y2-y1);
    ExpectDXFplines;
    AddVertexPline('0', p_X121(    0),p_Y121(    0));
    AddVertexPline('0', p_X121(x2-x1),p_Y121(    0));
    AddVertexPline('0', p_X121(x2-x1),p_Y121(y2-y1));
    AddVertexPline('0', p_X121(    0),p_Y121(y2-y1));
    AddVertexPline('0', p_X121(    0),p_Y121(    0));
    DXFplineEnd('0');
  END;

  with LineSettings_L do
    SetLineStyle(LineStyle,Pattern,Thickness);

END;  {..DrawBorder}

{----------------------------------------------------------------------------}
procedure MainWindow(k:Byte);  {Set the main window for the graphic interface}
{if (k = 0) set the linits only                                              }
{if (k = 1) set the linits and erase the whole screen                        }
{if (k >= 2) set the linits, erase the whole screen and draw a border around }

BEGIN
  MySetTextStyle(SmallFont, HorizDir,1, TRUE);
  if (k > 0) then ClearDevice;
  FullPort;
  if (k > 1) then BEGIN  {draw border..}
    SetViewPort(0,TextHeight('M')+3, MaxX,MaxY-(TextHeight('M')+5),ClipOff);
    DrawBorder;
  END;

  SetViewPort(1,TextHeight('M')+4, MaxX-1,MaxY-(TextHeight('M')+6),ClipOn);

END;  {..MainWindow}

{----------------------------------------------------------------------------}
procedure Header(HoriPoz: Shortint; Msg: string);
{If (Abs(HoriPoz) = 0) OR (HoriPoz = LeftText) then justify left             }
{If (Abs(HoriPoz) = 1) OR (HoriPoz = LeftText) then justify center           }
{If (Abs(HoriPoz) = 2) OR (HoriPoz = LeftText) then justify right            }
{If (HoriPoz < 0) then no border drown.                                      }
{If (HoriPoz = -1) then no border drown and Msg is writtemn to DXF file.     }

BEGIN  {Header ..}
  if (Length(Msg) > 80) then Msg:=TrimString(TrimBlanks(Msg),80);

  Color_L:=GetColor;
  GetViewSettings(ViewPort_L);
  GetFillSettings(FillSettings_L);
  GetLineSettings(LineSettings_L);

  SetColor(MaxColor);
  SetFillStyle(EmptyFill, MinColor);
  SetLineStyle(SolidLn, 0, NormWidth);
  SetTextJustify(Abs(HoriPoz),1);

  FullPort;

  Bar(0, 0, MaxX, (TextHeight('M')+3));  {erase old header..}

  if (HoriPoz >= 0) then Rectangle(0, 0, MaxX, (TextHeight('M')+3));

  if (Abs(HoriPoz) = 0) then  {justify left..}
    OutTextXY(2, (TextHeight('M') + 4) DIV 2, Msg);
  if (Abs(HoriPoz) = 2) then  {justify right..}
    OutTextXY(MaxX, (TextHeight('M') + 4) DIV 2, Msg);
  if (Abs(HoriPoz) = 1) then  {justify center..}
    OutTextXY(MaxX DIV 2, (TextHeight('M') + 4) DIV 2, Msg);

  with ViewPort_L do BEGIN
    SetViewPort(x1,y1,x2,y2,Clip);
    if (HoriPoz = -1) then BEGIN  {also write to DXF..}
      DXFtext('',0.5*(x2-x1),4*TextHeight('M'), Msg);
    END
  END;

  with ViewPort_L do
    SetViewPort(x1,y1, x2,y2, Clip);
  with FillSettings_L do
    SetFillStyle(Pattern, Color);
  with LineSettings_L do
    SetLineStyle(LineStyle,Pattern,Thickness);

  SetColor(Color_L);

END;  {.. Header}

{----------------------------------------------------------------------------}
procedure Footer(HoriPoz: Shortint; Msg: string);
{If (Abs(HoriPoz) = 0) OR (HoriPoz = LeftText) then justify left             }
{If (Abs(HoriPoz) = 1) OR (HoriPoz = LeftText) then justify center           }
{If (Abs(HoriPoz) = 2) OR (HoriPoz = LeftText) then justify right            }
{If (HoriPoz < 0) then no border drown.                                      }
{If (HoriPoz = -1) then no border drown and Msg is writtemn to DXF file.     }

BEGIN {Footer ..}
  if (Length(Msg) > 80) then Msg:=TrimString(TrimBlanks(Msg),80);

  Color_L:=GetColor;

  GetViewSettings(ViewPort_L);
  GetFillSettings(FillSettings_L);
  GetLineSettings(LineSettings_L);

  SetColor(MaxColor);
  SetFillStyle(EmptyFill, MinColor);
  SetLineStyle(SolidLn, 0, NormWidth);
  SetTextJustify(Abs(HoriPoz),1);

  FullPort;

  Bar(0, MaxY-(TextHeight('M')+5), MaxX, MaxY);  {.. erase old status Line}

  if (HoriPoz >= 0) then
    Rectangle(0, MaxY-(TextHeight('M')+5), MaxX, MaxY);
  if (Abs(HoriPoz) = 0) then  {justify left..}
    OutTextXY(2, MaxY-((TextHeight('M') + 5) DIV 2), Msg);
  if (Abs(HoriPoz) = 2) then  {justify right..}
    OutTextXY(MaxX, MaxY-((TextHeight('M') + 5) DIV 2), Msg);
  if (Abs(HoriPoz) = 1) then  {justify center..}
    OutTextXY(MaxX DIV 2, MaxY-((TextHeight('M') + 5) DIV 2), Msg);

  with ViewPort_L do BEGIN
    SetViewPort(x1,y1,x2,y2,Clip);
    if (HoriPoz = -1) then BEGIN  {also write to DXF..}
      DXFtext('',0.5*(x2-x1),(y1-y2)-4*TextHeight('M'), Msg);
    END
  END;

  with ViewPort_L do
    SetViewPort(x1,y1, x2,y2, Clip);
  with FillSettings_L do
    SetFillStyle(Pattern, Color);
  with LineSettings_L do
    SetLineStyle(LineStyle,Pattern,Thickness);

  SetColor(Color_L);

END;  {.. Footer}

{----------------------------------------------------------------------------}
procedure ReadStrG(Msg:string; var InStr:string; Lgt:ShortInt);
{Write a message and then accept a keyboard input InStr AT THE CURRENT POINT }
{InStr must be shorter than Lgt; if the input is <ESC> InStr does not change }
{If InStr < 0 it displays InStr after it erases to the right over length Lgt }

var cX,prX,prY: Word;
    ErCod0,ErCod: integer;
    InStr0:string;  AuxD: double;

label ReadCR_GLB_0;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure ClearLStr(pcX,pcY: Word; L: Byte);
{Erases the space from the current point over a length L                     }
BEGIN
  GetFillSettings(FillSettings_L);
  SetFillStyle(EmptyFill, MinColor);
  Bar(pcX,pcY-PixChH, pcX+(L+2)*PixChW, pcY+2);  {..erase old Line}
  with FillSettings_L do SetFillStyle(Pattern, Color);
  MoveTo(pcX,pcY);
END;  {.. ClearLStr}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure O_ut(pcX,pcY: Word);
{Outputs cursor "_"                                                          }
BEGIN
  MoveTo(pcX,pcY+2);
  OutText('_');
  MoveTo(pcX,pcY);
END;  {.. O_ut}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
BEGIN {ReadStrG ..}
  Color_L:=GetColor;
  SetColor(MaxColor);
  SetTextJustify(LeftText, BottomText);
  MySetTextStyle(TriplexFont,HorizDir,1,FALSE);

  MoveTo(20,MaxY);

  InStr0:=InStr;
  InStr:=TrimBlanks(InStr);
  Val(InStr,AuxD,ErCod0);  {if ErCod0 = 0 then the input is a number}
  while (Length(InStr) < Abs(Lgt)) do InStr:=Concat(InStr,' ');

  OutText(Msg);
  prX:=GetX;
  prY:=GetY+2;


ReadCR_GLB_0:
  ClearLStr(prX,prY,Abs(Lgt));
  OutText(InStr);
  O_ut(prX,prY);
  cX:=prX;
  if Lgt > 0 then repeat
    Ch:=ReadKey;
    if (Ch = #0) then BEGIN {Ch = special key}
      Ch:=ReadKey;
      if (Ch = #75) then BEGIN {<Ä}
        cX:=cX-PixChW;
        if (cX <= prX) then cX:=prX;
      END else
      if (Ch = #77) then BEGIN {Ä>}
        cX:=cX+PixChW;
        if (cX >= prX+Abs(Lgt)*PixChW) then cX:=prX+Abs(Lgt)*PixChW;
      END else
      if (Ch = #71) then cX:=prX {<Home>}
      else
      if (Ch = #79) then BEGIN {<End>}
        cX:=prX+Length(InStr)*PixChW;
        if (InStr = '') then cX:=prX
        else  while (InStr[(cX-prX) DIV PixChW] = ' ') do cX:=cX-PixChW;
      END
      else
      if (cX-prX <= Length(InStr)*PixChW) AND (Ch = #83) then BEGIN {<Delete>}
        Delete(InStr,1+(cX-prX) DIV PixChW,1);
        InStr:=Concat(InStr,' ');
      END;
    END
    else BEGIN {Ch = not a special key}
      if (Ch = #8) then BEGIN {<Back-space>}
        cX:=cX-PixChW;
        if (cX >= prX) then BEGIN
          Delete(InStr,(cX-prX) DIV PixChW+1,1);
          InStr:=Concat(InStr,' ');
        END else cX:=prX;
      END else
      if (Ch = #27) then InStr:=InStr0 { <ESC> }
      else if (Ch <> #13) AND (Ch <> #9) then BEGIN
        cX:=cX+PixChW;
        if (cX > prX+Abs(Lgt)*PixChW) then cX:=prX+Abs(Lgt)*PixChW
        else BEGIN
          Insert(Ch,InStr,(cX-prX) DIV PixChW);
          Delete(InStr,Abs(Lgt)+1,1);
        END
      END;
    END;
    ClearLStr(prX,prY,Abs(Lgt));
    OutText(InStr);
    O_ut(cX,prY);
  until (Ch = #13) OR (Ch = #27);
  InStr:=TrimBlanks(InStr);
  if (ErCod0 = 0) then BEGIN
    AuxD:=PIform2Val(InStr);
    if (Abs(AuxD) >= InfD) then BEGIN
      InStr:=InStr0;
      goto ReadCR_GLB_0;
    END;
  END;
  ClearLStr(prX,prY,Abs(Lgt));
  OutText(InStr);
  MoveTo(prX,prY);

  SetColor(Color_L);

  MySetTextStyle(SmallFont, HorizDir,1,FALSE); {!}

END;  {.. ReadStrG}

{----------------------------------------------------------------------------}
function ReadCh_G(Msg: string): Char;
{ Reads from the keyboard 1 character only in the Footer area.               }
{ The first char in Msg is the default answer; example: Msg:='YQuit (Y/N)? ' }
var ViewPort0: ViewPortType;  AUXstr:string;

BEGIN  {ReadCh_G ..}
  GetViewSettings(ViewPort0);
  Footer(1,'');
  FullPort;

  AUXstr:=Msg[1];   {..get the default answer character}
  Delete(Msg,1,1);
  ReadStrG(Msg, AUXstr, 1);
  AUXstr:=UpCaseStr(AUXstr[1]);
  Footer(1,'');
  ReadCh_G:=AUXstr[1];
  with ViewPort0 do SetViewPort(x1,y1,x2,y2, Clip);
END;  {.. ReadCh_G}

{============================================================================}
{============================================================================}

END.  {.. LibGIntf}
