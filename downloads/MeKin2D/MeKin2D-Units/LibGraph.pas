Unit LibGraph;
{ $R+ }
{ $S- }
{=============================================================================
  Unit for graphic operations
  (c) P.A. Simionescu 2018
=============================================================================}

INTERFACE

uses Graph;

var  ViewPort    : ViewPortType;
     FillSettings: FillSettingsType;
     TextSettings: TextSettingsType;
     LineSettings: LineSettingsType;

     MaxColor,            {drawing color     }
     MinColor,            {backgrownd color  }
     MaxX, MaxY: Word;    {screen resolution }
     PixChW,PixChH:Byte;  {width & height of a BGI character}

{---------------------------------------------------------------------------}
procedure InitGr(VideoMode: Byte);

procedure MySetTextStyle(Font,Dir:Word; ChSize:single; Inc_DXF_font:Boolean);

procedure HaltGr;

function  ScaleColor(X_min,X_max, X: double): Byte;

procedure Obj2Scr(One_2_One: Boolean;  X_min,X_max, Y_min,Y_max: double);
function  GetExtentX: double;  {Returns ExtentX calculated by Obj2Scr(..)}
function  GetExtentY: double;  {Returns ExtentY calculated by Obj2Scr(..)}

function  X_pI(X: double): Integer;  {X world  -> X screen-integer}
function  Y_pI(Y: double): Integer;  {Y world  -> Y screen-integer}

function  X_p(X: double): double;   {X world -> X screen-double }
function  Y_p(Y: double): double;   {Y world -> Y screen-double }

function  p_X(Xp: double): double;   {X screen -> X world }
function  p_Y(Yp: double): double;   {Y screen -> Y world }

function  p_X121(Xp: double): double;  {X screen -> X double based on One2One}
function  p_Y121(Yp: double): double;  {Y screen -> Y double based on One2One}

function  R_p121(R: double): double;  {Radius world -> Radius screen 1:1}
function  R_p(R: double): double;     {Radius world -> Radius screen    }

function  p2R121(Rp: double): double; {Radius screen -> Radius world 1:1}
function  p2R(Rp: double): double;    {Radius screen -> Radius world    }

{============================================================================}
IMPLEMENTATION

uses  Crt,Dos, LibInOut, LibMath, LibDXF;

var  ViewPort_L    : ViewPortType;
     FillSettings_L: FillSettingsType;
     LineSettings_L: LineSettingsType;

     One2One: Boolean;  {TRUE = isotrop immage space}
     ulcXp,ulcYp: Word; {viewport origin same with (ViewPort.x1,ViewPort.y1)}
     ulcX,ulcY,         {object space origin same with (X_min,Y_min)        }
     dXpdX,dYpdY,       {scale factors used by X_p(..),Y_p(..) etc.         }
     ExtentX,           {object space X-limits left & right extensions      }
     ExtentY:double;    {object space Y-limits up and down extensions       }


{----------------------------------------------------------------------------}
procedure InitGr(VideoMode: Byte);
var GraphDriver, GraphMode: integer;

BEGIN  {InitGr..}
  if (MaxX*MaxY <> 0) then Exit;   {..already in graph mode}

  GraphDriver:= DETECT;
  InitGraph(GraphDriver,GraphMode, ' ' );
  if (GraphResult <> grOk) then BEGIN
    Writeln('ImnitGraph error: ', GraphErrorMsg(GraphDriver));
    Halt;
  END;

  if (VideoMode = 1) then BEGIN
    MinColor:=Black;
    MaxColor:=White;
  END
  else BEGIN
    MinColor:=White;
    MaxColor:=DarkGray;
  END;

  SetBkColor(MinColor);
  SetColor(MaxColor);

  ClearDevice;

  MaxX:=GetMaxX;
  MaxY:=GetMaxY;

END;  {..InitGr}

{----------------------------------------------------------------------------}
procedure MySetTextStyle(Font,Dir:Word; ChSize:single; Inc_DXF_font:Boolean);
BEGIN
  if (MaxX*MaxY = 0) then Exit;  {.. not in graph mode}
  SetTextStyle(Font,Dir,Round(ChSize));
  PixChW:=TextWidth('H');     {.. width of BGI characters}
  PixChH:=TextHeight('³');    {.. height of BGI characters}
  SetDXFchH(Font,Inc_DXF_font);
END; {.. MySetTextStyle}

{----------------------------------------------------------------------------}
procedure HaltGr;
BEGIN
  if (MaxX*MaxY > 0) then CloseGraph;
  MaxX:=0; MaxY:=0; {..if MaxX*MaxY = 0 then not in graph mode!}
{  ClrScr; }
END;  {..HaltGr}

{============================================================================}
function ScaleColor(X_min,X_max, X: double): Byte;
{  Black   ³ 0 º Red       ³ 4 º DarkGray     ³  8º LightRed     ³ 12
   Blue    ³ 1 º Magenta   ³ 5 º LightBlue    ³  9º LightMagenta ³ 13
   Green   ³ 2 º Brown     ³ 6 º LightGreen   ³ 10º Yellow       ³ 14
   Cyan    ³ 3 º LightGray ³ 7 º LightCyan    ³ 11º White        ³ 15  }

var  Aux: double;

BEGIN
  if (X_min > X_max) then BEGIN
    Aux:=X_min;  X_min:=X_max;  X_max:=Aux;
  END;
  if (X < X_min) then X:=X_min;
  if (X > X_max) then X:=X_max;
  case Trunc(Abs(10.0*(X-X_min)/(X_max-X_min))) of
    0: ScaleColor:=1;    {Blue        }
    1: ScaleColor:=9;    {LightBlue   }
    2: ScaleColor:=3;    {Cyan        }
    3: ScaleColor:=2;    {Green       }
    4: ScaleColor:=10;   {LightGreen  }
    5: ScaleColor:=11;   {LightCyan   }
    6: ScaleColor:=13;   {LightMagenta}
    7: ScaleColor:=12;   {LightRed    }
    8: ScaleColor:=5;    {Magenta     }
    9,10: ScaleColor:=4; {Red         }
  END;
END;  {..ScaleColor}

{============================================================================}
procedure Obj2Scr(One_2_One: Boolean; X_min,X_max, Y_min,Y_max: double);
{Calculate  ulcX,ulcY, dXpdX,dYpdY  used by  X_pI(..), Y_pI(..), X_p(..),  }
{Y_p(..), pDR(..), p_X121(..), p_Y121(..)  and  DpR(..)                    }

var  Xasp,Yasp: Word;
     T1,T2: double;

BEGIN;  {Obj2Scr..}
  if (MaxX*MaxY = 0) then Exit;  {graphic mode ON..}

  if (Abs(X_min) >= InfD) OR (Abs(X_max) >= InfD) then Exit;
  if (Abs(Y_min) >= InfD) OR (Abs(Y_max) >= InfD) then Exit;

  if (X_min = X_max) then BEGIN
    X_min:=X_min-Max2(0.1*Abs(X_min),epsR);
    X_max:=X_max+Max2(0.1*Abs(X_max),epsR);
  END;
  if (Y_min = Y_max) then BEGIN
    Y_min:=Y_min-Max2(0.1*Abs(Y_min),epsR);
    Y_max:=Y_max+Max2(0.1*Abs(Y_max),epsR);
  END;

  One2One:=One_2_One;

  GetViewSettings(ViewPort_L);
  with ViewPort_L do BEGIN
    ulcXp:=x1;       ulcYp:=y1;
    dXpdX:=x2-x1;    dYpdY:=y2-y1;
  END;
  GetAspectRatio(Xasp,Yasp);
  T1:=dXpdX*Xasp/(dYpdY*Yasp);

  if (Abs(Y_max-Y_min) > epsR) then
   T2:=(X_max-X_min)/(Y_max-Y_min)
  else
   T2:=epsR;

  ExtentX:=0;
  ExtentY:=0;

  if One_2_One then BEGIN  {Isotropic = Unstretched graph..}
    {resize obj. space such that T1 = Abs(X_max-X_min)/(Y_min-Y_max)..}
    if (T1 > Abs(T2)) then BEGIN
      ExtentX:=0.5*(Abs(Y_max-Y_min)*T1-Abs(X_max-X_min));
      ExtentX:=Sgn(X_max-X_min)*ExtentX;
      X_min:=X_min - ExtentX;
      X_max:=X_max + ExtentX;
    END;
    if (T1 < Abs(T2)) then BEGIN
      ExtentY:=0.5*(Abs(X_max-X_min)/T1-Abs(Y_min-Y_max));
      ExtentY:=Sgn(Y_max-Y_min)*ExtentY;
      Y_min:=Y_min - ExtentY;
      Y_max:=Y_max + ExtentY;
    END;
  END; {..One_2_One}

  if (Abs(X_max-X_min) > 1.0E-100) then
    dXpdX:=dXpdX/(X_max-X_min)
  else
    dXpdX:=1.0E-100*Sgn(X_max-X_min);

  if (Abs(Y_min-Y_max) > 1.0E-100) then
    dYpdY:=dYpdY/(Y_min-Y_max)
  else
    dYpdY:=1.0E-100*Abs(Y_min-Y_max);

  ulcX:=X_min;  {obj. space X of upper-left corner}
  ulcY:=Y_max;  {obj. space Y of upper-left corner}

END; {..Obj2Scr}

{----------------------------------------------------------------------------}
function GetExtentX: double;  {Returns ExtentX evaluated by Obj2Scr(..) }
BEGIN
  GetExtentX:=ExtentX;
END;  {..GetExtentX}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function GetExtentY: double;  {Returns ExtentY evaluated by Obj2Scr(..) }
BEGIN
  GetExtentY:=ExtentY;
END;  {..GetExtentY}

{----------------------------------------------------------------------------}
function X_pI(X:double): Integer;  {X obj. -> X image integer..}
BEGIN
  X_pI:=RoundInt(dXpdX*(X-ulcX));
END;  {..X_pI}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function Y_pI(Y: double): Integer;  {Y obj. -> Y image integer..}
BEGIN
  Y_pI:=RoundInt(dYpdY*(Y-ulcY));
END; {..Y_pI}

{----------------------------------------------------------------------------}
function X_p(X: double): double;  {X object -> X image double..}
BEGIN
  X_p:=dXpdX*(X-ulcX);
END; {..X_p}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function Y_p(Y: double): double;  {Y object -> Y image double..}
BEGIN
  Y_p:=dYpdY*(Y-ulcY);
END; {..Y_p}

{----------------------------------------------------------------------------}
function p_X(Xp: double): double;  {X image -> X object..}
BEGIN
  p_X:=Xp/dXpdX+ulcX;
END; {..p_X}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function p_Y(Yp: double): double;  {Y image -> Y object..}
BEGIN
  p_Y:=Yp/dYpdY+ulcY;
END; {..p_Y}

{----------------------------------------------------------------------------}
function p_X121(Xp: double): double;  {X image -> X obj. based on One2One..}
BEGIN
{ if One2One then p_X121:=(Xp-ulcXp)/dXpdX+ulcX else p_X121:=Xp;}
  if One2One then p_X121:=Xp/dXpdX+ulcX else p_X121:=Xp;
END; {..p_X121}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function p_Y121(Yp: double): double;  {Y image -> Y obj. based on One2One..}
BEGIN
{ if One2One then p_Y121:=(Yp-ulcYp)/dYpdY+ulcY else p_Y121:=-Yp;}
  if One2One then p_Y121:=Yp/dYpdY+ulcY else p_Y121:=-Yp;
END; {..p_Y121}

{----------------------------------------------------------------------------}
function R_p121(R: double): double;  {R obj. -> R image based on One2One..}
BEGIN
  if One2One then R_p121:=R*Max2(Abs(dXpdX),Abs(dYpdY)) else R_p121:=R;
END; {..R_p121}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function R_p(R: double): double;  {R obj. -> R image..}
BEGIN
  R_p:=R*Max2(Abs(dXpdX),Abs(dYpdY));
END;  {..R_p}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function p2R121(Rp: double): double;  {R image -> R obj. based on One2One..}
BEGIN
  if One2One then p2R121:=Rp/Max2(Abs(dXpdX),Abs(dYpdY)) else p2R121:=Rp;
END;  {..p2R121}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function p2R(Rp: double): double;  {R image -> R object..}
BEGIN
  p2R:=Rp/Max2(Abs(dXpdX),Abs(dYpdY));
END;  {..p2R}

{============================================================================}
{============================================================================}
BEGIN
  MaxX:=0;  MaxY:=0;  {if MaxX*MaxY = 0 then not in graph mode}
  One2One:=FALSE;
  PixChW:=8;   {in lack of a better value width of BGI characters }
  PixChH:=8;   {in lack of a better value height of BGI characters}
  ulcXp:=0;    {default viewport X of upper-left corner           }
  ulcYp:=0;    {default viewport Y of upper-left corner           }
  ulcX :=0.0;  {default obj. space X of upper-left corner         }
  ulcY :=0.0;  {default obj. space Y of upper-left corner         }
  dXpdX:=1.0;  {default dXp/dX scale factor                       }
  dYpdY:=1.0;  {default dYp/dY scale factor                       }
  ExtentX:=0;
  ExtentY:=0;
END. {.. LibGraph}
