Unit LibMath;
{ $R+ }
{ $S- }
{=============================================================================
  Unit for mathematical calculations
  (c) P.A. Simionescu 2018
=============================================================================}

INTERFACE

const InfD : double  = 1.0E+100;    {very large positive double            }
      EpsD : double  = 1.0E-100;    {very small positive double = almost 0 }
      InfR : real    = 1.0E+30;     {very large positive real              }
      EpsR : real    = 1.0E-30;     {very small positive real = almost 0   }
      InfI : Integer = 32767;       {largest Integer                       }
      InfLI: LongInt = 2147483647;  {largest Longint                       }
      RAD  : double  = Pi/180.0;    {coefficent for DEG to RAD conversion  }
      DEG  : double  = 180.0/Pi;    {coefficent for RAD to DEG conversion  }
      ee   : double  = 2.71828182845904523536;  {ln(ee) = 1.0              }

{     Maximum size of matrices below                                       }
      m_max=  102;      r_max= 5002;
      n_max=  252;      s_max=10002;
      o_max=  502;      t_max=20002;
      p_max= 1002;      u_max=50002;
      q_max= 2502;      w_max=75002;

type  VDm = array[1..m_max] of double;  {1..  102}
      VDn = array[1..n_max] of double;  {1..  252}
      VDo = array[1..o_max] of double;  {1..  502}
      VDp = array[1..p_max] of double;  {1.. 1002}
      VDq = array[1..q_max] of double;  {1.. 2502}
      VDr = array[1..r_max] of double;  {1.. 5002}
      VDs = array[1..s_max] of double;  {1..10002}
      VDt = array[1..t_max] of double;  {1..20002}
      VDu = array[1..u_max] of double;  {1..50002}
      VDw = array[1..w_max] of double;  {1..75002}

      VRm = array[1..m_max] of real;    {1..  102}
      VRn = array[1..n_max] of real;    {1..  252}
      VRo = array[1..o_max] of real;    {1..  502}
      VRp = array[1..p_max] of real;    {1.. 1002}
      VRq = array[1..q_max] of real;    {1.. 2502}
      VRr = array[1..r_max] of real;    {1.. 5002}
      VRs = array[1..s_max] of real;    {1..10002}
      VRt = array[1..t_max] of real;    {1..20002}

      VIm = array[1..m_max] of Integer; {1..  102}
      VIn = array[1..n_max] of Integer; {1..  252}
      VIo = array[1..o_max] of Integer; {1..  502}
      VIp = array[1..p_max] of Integer; {1.. 1002}
      VIq = array[1..q_max] of Integer; {1.. 2502}
      VIr = array[1..r_max] of Integer; {1.. 5002}
      VIs = array[1..s_max] of Integer; {1..10002}
      VIt = array[1..t_max] of Integer; {1..20002}

      MDmm = array[1..m_max, 1..m_max] of double;  {1.. 102 x 1.. 102}
      MDnn = array[1..n_max, 1..n_max] of double;  {1.. 252 x 1.. 252}
      MDoo = array[1..o_max, 1..o_max] of double;  {1.. 502 x 1.. 502}
      MDpp = array[1..p_max, 1..p_max] of double;  {1..1002 x 1..1002}

      argF1   = function(var DD: double): double;
      argF2   = function(var DD1,DD2: double): double;
      argFm   = function(var DD: VDm): double;
      paramF2 = procedure(t, r0,a,b: double; var x,y: double);


var   NrFev0: Longint;  {function call counter}
      _: double;


{----------------------------------------------------------------------------}
function j1n(n,j:Integer):Integer;

function RoundInt(DD: double): Integer;  {rounds within [-InfI .. InfI]      }
function RoundLongInt(DD: double): LongInt; {Rounds DD within [-InfLI..InfLI]}
function TruncInt(DD: double): Integer;  {truncate to [-InfI .. InfI]        }
function ForceReal(DD: double): real;    {truncate to [-InfR .. InfR]        }
function RoundMD(DD,MD: double): double; {rounds in multiples of MD          }
function Sgn(DD: double): shortint;        {sign function                      }
function SgnEps(DD,Eps: double): shortint; {if Abs(DD) < Eps returns 0 else sign of DD }


function Binary(DecNo:LongInt):string;   {binary conversion     }
function Bin2Hexa(BinNo:string):string;  {binary to hexadecimal }
function BinComp(BinNo:string):string;   {binary complement     }

function min2(D1,D2: double): double;       {return min of D1 & D2     }
function min3(D1,D2,D3: double): double;    {return min of D1,D2 & D3  }
function min4(D1,D2,D3,D4: double): double; {return min of D1..D4      }
function min6(D1,D2,D3,D4,D5,D6: double): double; {return min of D1..D6}

function Max2(D1,D2: double): double;       {return maximum of D1 & D2    }
function Max3(D1,D2,D3: double): double;    {return maximum of D1,D2 & D3 }
function Max4(D1,D2,D3,D4: double): double; {return maximum of D1..D4     }
function Max6(D1,D2,D3,D4,D5,D6: double): double; {return max of D1..D6   }

function min3int(y1,y2,y3: double): double; {parabolically interp. min of }
                {y1,y2,y3 assumed equally spaced                          }

function Log10(DD: double): double;     {decimal logarithm    }
function Pow(Arg,Expt: double): double; {power function       }
function Atan2(Dy,Dx: double): double;
function ArcSin(x: double): double;     {inverse sin function }
function ArcCos(x: double): double;     {inverse cos function }
function Tan2(sinAng,cosAng: double): double;
function Cot2(sinAng,cosAng: double): double;

function NghbrAng(Ang0,Ang: double): double; {bring Ang near Ang0 by +/- 2*Pi}

procedure LinEq2(a1,b1,c1, a2,b2,c2:double; var x,y:double; var OK:Boolean);
procedure LinEq3(a1,b1,c1,d1, a2,b2,c2,d2, a3,b3,c3,d3:double;
          var x,y,z:double; var OK:Boolean);

procedure MatMul(A,B: MDnn;  m,n,p:Byte;  var C: MDnn);

function  Integral(F1:argF1; x1,x2:double; n: Word): double;

procedure MinMaxParab3pts(xA,yA, xB,yB, xC,yC:double; var x,y:double);

procedure Intp1(x, x1,y1,x2,y2: double;  var y,a,b: double);
procedure Intp2(x, x1,y1,x2,y2,x3,y3: double; var y,a,b,c: double);
procedure Intp3(x, x1,y1,x2,y2,x3,y3,x4,y4: double; var y,a,b,c,d: double);

procedure GaussJordan(A:MDnn; B:VDn; var X:VDn; n:Byte; var OK:Boolean);
procedure SparseLin(A:MDnn; B:VDn; var X:VDn; n:integer; var RSQ: double);

procedure Zero     (F: argF1; a,b: double;  var x: double);
procedure ZeroStart(F: argF1; Step: double; var x: double);
procedure ZeroGrid (F: argF1; a,b: double; Npts:Word; var XX: VDn);

procedure Rat_Int(Xa,Ya: VDq; n: integer; x: double; var y,dy: double);
procedure SplineTg(var X,Y: VDq; n: integer; yp1,ypn: double; var Y2: VDq);
procedure IntSpline3(Xa,Ya,Y2a:VDq; i:integer; x:double; var y:double);
procedure IntBspline2(XX,YY:VDq; i:integer; t:double; var x,y:double);
procedure IntBspline3(XX,YY:VDq; i:integer; t:double; var x,y:double);

function  GaussRandom(Mean,StDev: double): double;

function  Average(Xn:VDm; n:Byte): double;
function  StanDev(Xn:VDm; n:Byte): double;
procedure AvgStDev(Xn:VDm; n:Byte; var Avg,StDev: double);

function EuclidGCD(a,b:Word): Word;  {greatest common divisor of A and B}


IMPLEMENTATION

uses CRT;

const LimFev0 = 10000; {maximum allowed nr of function calls in Zero subroutines}

{----------------------------------------------------------------------------}
function j1n(n,j:Integer):Integer;
{Forces j between 1 and n ..}
BEGIN
  j:=j MOD n;
  if (j < 1) then j:=n + j;
  j1n:=j;
END;

{----------------------------------------------------------------------------}
function  Binary(DecNo:LongInt):string;
{Convert DecNo to its binary representation                                  }

var Remainder,Quotient: LongInt;
    AuxStr: string;

BEGIN {Binary ..}
  Quotient:=DecNo;
  AuxStr:='';
  repeat
    Remainder:=Quotient MOD 2;
    if (Remainder = 0) then
      AuxStr:=Concat('0',AuxStr)
    else
      AuxStr:=Concat('1',AuxStr);
    Quotient:=Quotient DIV 2;
  until (Quotient = 0);
  Binary:=AuxStr;
END; {.. Binary}

{----------------------------------------------------------------------------}
function Bin2Hexa(BinNo:string):string;
{Converts a binary string to its hexadecimal representation  }
{Example: Bin2Hexa('1100100001101100') returns '$C86C'       }

var  Lgt,i: Byte;
     AuxStr,Str4: string;

BEGIN
  Lgt:=Length(BinNo);
  if (Lgt MOD 4) > 0 then Lgt:=Lgt+4;
  Lgt:=(Lgt DIV 4)*4;
  while (Length(BinNo) < Lgt) do Insert('0',BinNo,1);
  AuxStr:='$';
  for i:=0 to (Lgt DIV 4 -1) do BEGIN
    Str4:=Copy(BinNo,i*4+1,4);
    if Str4 = '0000' then AuxStr:=Concat(AuxStr,'0');
    if Str4 = '0001' then AuxStr:=Concat(AuxStr,'1');
    if Str4 = '0010' then AuxStr:=Concat(AuxStr,'2');
    if Str4 = '0011' then AuxStr:=Concat(AuxStr,'3');
    if Str4 = '0100' then AuxStr:=Concat(AuxStr,'4');
    if Str4 = '0101' then AuxStr:=Concat(AuxStr,'5');
    if Str4 = '0110' then AuxStr:=Concat(AuxStr,'6');
    if Str4 = '0111' then AuxStr:=Concat(AuxStr,'7');
    if Str4 = '1000' then AuxStr:=Concat(AuxStr,'8');
    if Str4 = '1001' then AuxStr:=Concat(AuxStr,'9');
    if Str4 = '1010' then AuxStr:=Concat(AuxStr,'A');
    if Str4 = '1011' then AuxStr:=Concat(AuxStr,'B');
    if Str4 = '1100' then AuxStr:=Concat(AuxStr,'C');
    if Str4 = '1101' then AuxStr:=Concat(AuxStr,'D');
    if Str4 = '1110' then AuxStr:=Concat(AuxStr,'E');
    if Str4 = '1111' then AuxStr:=Concat(AuxStr,'F');
  END;
  Bin2Hexa:=AuxStr;
END; {.. BinComp}

{----------------------------------------------------------------------------}
function BinComp(BinNo:string):string;
{Replace 0 with 1 and 1 with 0 in a binary number                            }
{Example: BinComp('1100100001101100') returns '0011011110010011'             }
var i: Byte;

BEGIN
  for i:=1 to Length(BinNo) do
    if (BinNo[i]='0') then BinNo[i]:='1' else BinNo[i]:='0';
  BinComp:=BinNo;
END; {.. BinComp}

{----------------------------------------------------------------------------}
function EuclidGCD(a,b:Word): Word;
{Return the greatest common divisor of two numbers using Euclid's algorithm  }
BEGIN
  repeat
    if (a > b) then a:=a-b;
    if (b > a) then b:=b-a;
  until (a = b);
  EuclidGCD:=a;
END; {.. EuclidGCD}

{----------------------------------------------------------------------------}
function TruncInt(DD: double): Integer; {Truncates DD within [-InfI..InfI] }
BEGIN
  if (DD > 1.0*InfI) then TruncInt:= InfI
   else
  if (DD < -1.0*InfI) then TruncInt:=-InfI
   else TruncInt:=Trunc(DD);
END; {.. TruncInt}

{----------------------------------------------------------------------------}
function RoundInt(DD: double): Integer; {Rounds DD within [-InfI..InfI]}
BEGIN
  if (DD > 1.0*InfI) then RoundInt:= InfI
   else
  if (DD < -1.0*InfI) then RoundInt:=-InfI
   else RoundInt:=Round(DD);
END; {.. RoundInt}

{----------------------------------------------------------------------------}
function RoundLongInt(DD: double): LongInt; {Rounds DD within [-InfLI..InfLI]}
BEGIN
  if (DD > 1.0*InfLI) then RoundLongInt:= InfLI
   else
  if (DD < -1.0*InfLI) then RoundLongInt:=-InfLI
   else RoundLongInt:=Round(DD);
END; {.. RoundInt}

{----------------------------------------------------------------------------}
function ForceReal(DD: double): real;  {Truncate DD to [-InfR .. InfR]       }
BEGIN
  if (DD > InfR) then  ForceReal:=InfR
   else
  if (DD < -InfR) then  ForceReal:=-InfR
   else ForceReal:=DD;
END; {.. ForceReal}

{----------------------------------------------------------------------------}
function  RoundMD(DD,MD: double): double;
{Rounds DD in multiples of MD e.g.  RoundMD(1.45,0.5)=1.5;      }
{RoundMD(1.74,0.5)=1.5;   RoundMD(1.74,2.0)=2.0                 }

BEGIN
  RoundMD:=RoundLongInt(DD/MD)*MD;
END;  {.. RoundMD}

{----------------------------------------------------------------------------}
function Sgn(DD: double): Shortint; {Return the sign of DD ..}
BEGIN
  if (DD = 0.0) then BEGIN
    Sgn:=0;
    Exit;
  END;
  if (DD > 0.0) then Sgn:=1 else Sgn:=-1;
END;  {.. Sgn}

{----------------------------------------------------------------------------}
function SgnEps(DD,Eps: double): shortint; {Return the sign of DD                  }
BEGIN
  if (Abs(DD) <= Eps) then SgnEps:=0
  else if (DD > 0.0) then SgnEps:=1 else SgnEps:=-1;
END;  {.. SgnEps}

{----------------------------------------------------------------------------}
function  Log10(DD: double): double; {Return the decimal logarithm of DD     }

const Log_e=0.434294481903251827651128918917;
var   i: Byte;

BEGIN
  if (DD <= 0.0) then BEGIN
    WriteLn('Eror Log(..) function. Negative or zero argument.');
    Log10:=InfD;
  END
  else Log10:=Log_e*Ln(DD);
END;  {.. Log}

{----------------------------------------------------------------------------}
function Pow(Arg,Expt: double): double;  {Return Arg at the power Expt }

var Q1,Q2: double;  i: Byte;

BEGIN
  if (Arg = 0.0) then Pow:=0.0
  else BEGIN
    if (Expt = 1.0) then BEGIN Pow:=Arg;             Exit;  END;
    if (Expt = 2.0) then BEGIN Pow:=Arg*Arg;         Exit;  END;
    if (Expt = 3.0) then BEGIN Pow:=Arg*Arg*Arg;     Exit;  END;
    if (Expt = 4.0) then BEGIN Pow:=Arg*Arg*Arg*Arg; Exit;  END;
    Q2:=Exp(Expt*Ln(Abs(Arg)));
    Q1:=0.5*Expt;
    if (Arg < 0) then BEGIN
      if (Frac(Abs(Q1)) = 0.5) then Pow:=-Q2
      else BEGIN
        if (Frac(Q1) <> 0) then BEGIN
          Pow:=InfD;
          Exit;
        END
        else BEGIN
          Pow:=Q2;
          Exit;
        END;
      END;
    END
    else Pow:=Q2;
  END;
END;  {.. Pow}

{----------------------------------------------------------------------------}
function min2(D1,D2: double): double;   {Returns the minimum of D1 and D2    }
BEGIN
  if (D1 < D2) then min2:=D1 else min2:=D2;
END; {.. min2}

{----------------------------------------------------------------------------}
function min3(D1,D2,D3: double): double; {Return the minimum of D1,D2 and D3 }
var min:double;
BEGIN
  if (D1 < D2) then min:=D1 else min:=D2;
  if (min > D3) then min:=D3;
  min3:=min;
END; {.. min3}

{----------------------------------------------------------------------------}
function min4(D1,D2,D3,D4: double): double; {Return min of D1,D2,D3 & D4}
var min:double;
BEGIN
  min4:=min2(min3(D1,D2,D3),D4);
END; {.. min4}

{----------------------------------------------------------------------------}
function min6(D1,D2,D3,D4,D5,D6: double): double; {Return min of D1..D6}
BEGIN
  min6:=min2(min3(D1,D2,D3),min3(D4,D5,D6));
END; {.. min6}

{----------------------------------------------------------------------------}
function Max2(D1,D2: double): double;  {Return the maximum of D1 and D2 }
BEGIN
  if (D1 > D2) then Max2:=D1 else Max2:=D2;
END; {.. Max2}

{----------------------------------------------------------------------------}
function Max3(D1,D2,D3: double): double; {Return max of D1,D2 & D3 }
var Max:double;
BEGIN
  if (D1  > D2) then Max:=D1 else Max:=D2;
  if (Max < D3) then Max:=D3;
  Max3:=Max;
END; {.. Max3}

{----------------------------------------------------------------------------}
function Max4(D1,D2,D3,D4: double): double; {Return max of D1..D4}
BEGIN
  Max4:=Max2(Max3(D1,D2,D3),D4);
END; {.. Max4}

{----------------------------------------------------------------------------}
function Max6(D1,D2,D3,D4,D5,D6: double): double; {Return max of D1..D6}
BEGIN
  Max6:=Max2(Max3(D1,D2,D3),Max3(D4,D5,D6));
END; {.. Max6}

{----------------------------------------------------------------------------}
function min3int(y1,y2,y3: double): double;
{returns the parabolicaly interp. min of  y1,y2,y3  assumed equaly spaced}
BEGIN
  if (y1 > y2) AND (y2 < y3) then
    min3int:=y2 - 0.125*(y3-y1)*(y3-y1)/(y1-2*y2+y3)
  else
    min3int:=min3(y1,y2,y3);
END; {.. min3int}


{----------------------------------------------------------------------------}
function ArcSin(x: double): double; {inverse Sin function}
BEGIN
  if Abs(x) > 1.0 then BEGIN
    ArcSin:=InfD; {.. x is not within [-1..1]}
    Exit;
  END;
  ArcSin:=ArcTan(x/Sqrt(1.0-x*x));
END; {.. ArcSin}

{----------------------------------------------------------------------------}
function ArcCos(x: double): double; {inverse Cos function}
BEGIN
  if Abs(x) > 1.0 then BEGIN
    ArcCos:=InfD; {.. x is not within [-1..1] }
    Exit;
  END;
  if Abs(x) < EpsR then
    ArcCos:=0.5*Pi
  else
    ArcCos:=ArcTan(Sqrt(1.0-x*x)/x);
END; {.. ArcCos}

{----------------------------------------------------------------------------}
function Atan2(Dy,Dx: double): double;
{Returns the ArcTan(Dy/Dx) within the interval [-Pi..Pi]    }

BEGIN
  if Abs(Dx) < EpsD then BEGIN
    if Abs(Dy) < EpsD then Atan2:=InfD
    else
      if (Dy > 0.0) then Atan2:=0.5*Pi else Atan2:=-0.5*Pi;
    Exit;
  END;
  if (Dx > 0.0) then
    Atan2:=ArcTan(Dy/Dx)
  else BEGIN
    if (Dy < 0.0) then
      Atan2:=ArcTan(Dy/Dx)-Pi
    else
      Atan2:=ArcTan(Dy/Dx)+Pi
  END;
END; {.. Atan2}

{----------------------------------------------------------------------------}
function Tan2(sinAng,cosAng: double): double;
BEGIN
  if Abs(cosAng) < EpsR then
    Tan2:=Sgn(sinAng*cosAng)*EpsR
  else
    Tan2:=sinAng/cosAng;
END; {.. Tan2}

{----------------------------------------------------------------------------}
function Cot2(sinAng,cosAng: double): double;
BEGIN
  if Abs(sinAng) < EpsR then
    Cot2:=Sgn(sinAng*cosAng)*EpsR
  else
    Cot2:=cosAng/sinAng;
END; {.. Tan2}

{----------------------------------------------------------------------------}
function NghbrAng(Ang0,Ang: double): double;
{Brings Ang closest Ang0 by adding/subtracting 2*Pi    }

var  DeltaAng,DeltaAng1,DeltaAng2,DeltaAng3: double;

BEGIN
  DeltaAng1:=Ang-Ang0-2*Pi*(TruncInt(Ang/(2*Pi))-TruncInt(Ang0/(2*Pi)));
  DeltaAng2:=DeltaAng1-2*Pi;
  DeltaAng3:=DeltaAng1+2*Pi;
  DeltaAng:=min3(Abs(DeltaAng1),Abs(DeltaAng2),Abs(DeltaAng3));
  if (Abs(DeltaAng1) = DeltaAng) then NghbrAng:=Ang0+DeltaAng1;
  if (Abs(DeltaAng2) = DeltaAng) then NghbrAng:=Ang0+DeltaAng2;
  if (Abs(DeltaAng3) = DeltaAng) then NghbrAng:=Ang0+DeltaAng3;
END; {.. NghbrAng}


{----------------------------------------------------------------------------}
function Integral(F1:argF1; x1,x2:double; n: Word): double;
{Integrate F1 by trapezoidal rule between x1 and x2                          }

var x,dx,F,Fant,Sum:double; i: Word;

BEGIN
  dx:=(x2-x1)/n;
  Fant:=F1(x1);
  Sum:=0.0;
  for i:=1 to n do BEGIN
    x:=x1+dx*i;    F:=F1(x);
    Sum:=Sum+0.5*(F+Fant)*dx;
    Fant:=F;
  END;
  Integral:=Sum;
END;  {.. Integral}

{----------------------------------------------------------------------------}
procedure LinEq2(a1,b1,c1,a2,b2,c2:double; var x,y:double; var OK:Boolean);
{Solves 2 simultaneus equations:  a1*x+b1*y=c1                               }
{                                 a2*x+b2*y=c2                               }
var Det: double;
BEGIN
  Det:=a1*b2-a2*b1;
  if (Abs(Det) < EpsD) then BEGIN
    OK:=False;
    x:=InfD;
    y:=InfD;
    Exit;
  END;
  OK:=True;
  x:=(b2*c1-b1*c2)/Det;
  y:=(a1*c2-a2*c1)/Det;
END; {.. LinEq2}

{----------------------------------------------------------------------------}
procedure LinEq3(a1,b1,c1,d1, a2,b2,c2,d2, a3,b3,c3,d3:double;
          var x,y,z:double; var OK:Boolean);
{Solves 3 simultaneus equations:  a1*x + b1*y + c1*z = d1   }
{                                 a2*x + b2*y + c2*z = d2   }
{                                 a3*x + b3*y + c3*z = d3   }
var Det: double;

function Det3(a1,b1,c1, a2,b2,c2, a3,b3,c3:double):double;
BEGIN
 Det3:=a1*b2*c3+a2*b3*c1+a3*b1*c2-a3*b2*c1-a1*b3*c2-a2*b1*c3;
END;

BEGIN
  Det:=Det3(a1,b1,c1, a2,b2,c2, a3,b3,c3);
  if (Abs(Det) < EpsD) then BEGIN
    OK:=False;
    x:=InfD;
    y:=InfD;
    z:=InfD;
    Exit;
  END;
  OK:=True;
  x:=Det3(d1,b1,c1, d2,b2,c2, d3,b3,c3)/Det;
  y:=Det3(a1,d1,c1, a2,d2,c2, a3,d3,c3)/Det;
  z:=Det3(a1,b1,d1, a2,b2,d2, a3,b3,d3)/Det;
END; {.. LinEq3}

{----------------------------------------------------------------------------}
procedure MinMaxParab3pts(xA,yA, xB,yB, xC,yC:double; var x,y:double);
{Find the extrema on the parabola through (xA,yA), (xB,yB), (xC,yC)          }

var  a,b,c, p12,q12,r12,p13,q13,r13: double;

BEGIN
  x:=xB;  y:=yB;

  p12:=Sqr(xB)-Sqr(xA);  q12:=xB-xA;  r12:=yB-yA;
  p13:=Sqr(xC)-Sqr(xA);  q13:=xC-xA;  r13:=yC-yA;

  if Abs(p13*q12-p12*q13) < EpsD then Exit;
  if Abs(q13*p12-q12*p13) < EpsD then Exit;

  a:=(r13*q12-r12*q13)/(p13*q12-p12*q13);
  b:=(r13*p12-r12*p13)/(q13*p12-q12*p13);
  c:=yA-a*Sqr(xA)-b*xA;

  x:=-0.5*b/a;      {x at extrema}
  y:= 0.5*b*x + c   {y at extrema}

END; {.. MinMaxParab3pts}

{============================================================================}
procedure Intp1(x, x1,y1,x2,y2: double;  var y,a,b: double);
{Interpolate y linearly at x located between x1 and x2                       }

BEGIN
  a:=0.0;
  b:=y1;
  if Abs(x2-x1) > EpsD then BEGIN
    a:=(y2-y1)/(x2-x1);
    b:=y1-a*x1;
  END;
  y:=a*x+b;
END; {.. Intp1}

{----------------------------------------------------------------------------}
procedure Intp2(x, x1,y1,x2,y2,x3,y3: double; var y, a,b,c: double);
{Interpolate y parabolically at x located between x1 and x3                  }

var OK: Boolean;

BEGIN
  LinEq2(x1*x1-x2*x2, x1-x2, y1-y2,
         x1*x1-x3*x3, x1-x3, y1-y3, a,b, OK);
  if OK then
    c:=y1-(a*x1*x1+b*x1)
  else BEGIN
    a:=0;
    b:=0;
    if Abs(x1-x2) < EpsD then Intp1(x,x1,y1,x3,y3,y,b,c);
    if Abs(x1-x3) < EpsD then Intp1(x,x1,y1,x2,y2,y,b,c);
    if Abs(x2-x3) < EpsD then Intp1(x,x1,y1,x2,y2,y,b,c);
  END;
  y:=a*x*x + b*x + c;
END; {.. Intp2}

{----------------------------------------------------------------------------}
procedure Intp3(x, x1,y1,x2,y2,x3,y3,x4,y4: double; var y,a,b,c,d: double);
{Interpolate y cubically at x located between x1 and x4                      }

var OK: Boolean;

BEGIN
  LinEq3(x1*x1*x1-x2*x2*x2, x1*x1-x2*x2, x1-x2, y1-y2,
         x1*x1*x1-x3*x3*x3, x1*x1-x3*x3, x1-x3, y1-y3,
         x1*x1*x1-x4*x4*x4, x1*x1-x4*x4, x1-x4, y1-y4, a,b,c, OK);
  if OK then
    d:=y1 - (a*x1*x1*x1 + b*x1*x1 + c*x1)
  else BEGIN
    a:=0;
    b:=0;
    c:=0;
    if Abs(x1-x2) < EpsD then Intp2(x, x1,y1,x3,y3,x4,y4, y, b,c,d);
    if Abs(x1-x3) < EpsD then Intp2(x, x1,y1,x2,y2,x4,y4, y, b,c,d);
    if Abs(x1-x4) < EpsD then Intp2(x, x1,y1,x2,y2,x3,y3, y, b,c,d);
    if Abs(x2-x3) < EpsD then Intp2(x, x1,y1,x2,y2,x4,y4, y, b,c,d);
    if Abs(x2-x4) < EpsD then Intp2(x, x1,y1,x2,y2,x3,y3, y, b,c,d);
    if Abs(x3-x4) < EpsD then Intp2(x, x1,y1,x2,y2,x3,y3, y, b,c,d);
    d:=y1-b*x1;
  END;
  y:=a*x*x*x + b*x*x +c*x + d;
END; {.. Intp3}

{============================================================================}
procedure MatMul(A,B: MDnn;  m,n,p:Byte;  var C: MDnn); {Return C = A*B  }
var i,j,k: Byte;

BEGIN {MatMul ..}
  for i:=1 to m do
    for j:=1 to p do BEGIN
      C[i,j]:=0.0;
      for k:=1 to n do C[i,j]:=C[i,j]+A[i,k]*B[k,j];
    END;
END;  {.. MatMul}

{============================================================================}
procedure Zero(F:argF1; a,b:double; var x:double);
{Solves F(x)=0 in the interval [a,b] using Zero algorithm due to Brent       }

const MachEps = 1.0E-16;  {floating point precision}

var c,d,e,Fa,Fb,Fc,Tol,m,p,q,r,s: double;

label Int, Ext;

BEGIN {Zero ..}
  Fa:=F(a); Inc(NrFev0);
  Fb:=F(b); Inc(NrFev0);
Int:
  c :=a;
  Fc:=Fa;
  d :=b-a;
  e :=d;
Ext:
  if (Abs(Fc) < Abs(Fb)) then BEGIN
    a:=b;
    b:=c;
    c:=a;
    Fa:=Fb;
    Fb:=Fc;
    Fc:=Fa;
  END;
  Tol:=2.0*MachEps*Abs(b);
  m:=0.5*(c-b);
  if (Abs(m) > Tol) AND (Fb <> 0.0) then  BEGIN
    if (Abs(e) < Tol) OR (Abs(Fa) <= Abs(Fb)) then BEGIN
      d:=e;
      e:=m;
    END
    else BEGIN
      s:=Fb/Fa;
      if (a = c) then BEGIN
        p:=2.0*m*s;
        q:=1.0-s;
      END
      else BEGIN
        q:=Fa/Fc;
        r:=Fb/Fc;
        p:=s*(2.0*m*q*(q-r)-(b-a)*(r-1.0));
        q:=(q-1.0)*(r-1.0)*(s-1.0);
      END;
      if (p > 0.0) then q:=-q else p:=-p;
      s:=e;
      e:=d;
      if (2.0*p < 3.0*m*q-Abs(Tol*q)) AND (p<Abs(0.5*s*q)) then d:=p/q
      else BEGIN
	d:=m;
	e:=d;
      END;
    END;
    a:=b;
    Fa:=Fb;
    if (Abs(d) > Tol) then b:=b+d else
    if (m > 0) then b:=b+Tol else b:=b-Tol;
    Fb:=F(b);
    Inc(NrFev0);
    if (NrFev0 > LimFev0) then BEGIN
      x:=(a+b)/2;
      Exit;
    END;
    if (Fb*Fc >= 0.0) then GoTo Int;
    GoTo Ext;
  END;
  x:=b;
END; {.. Zero}

{============================================================================}
procedure  ZeroStart(F: argF1; Step: double; var x: double);
{Returns the root of F closest to the initial value of x using Zero algorithm}

var  Fa,Xa, Fc,Xc, x1,x2: double;

BEGIN {ZeroStart ..}
  x1:=InfD;
  x2:=InfD;

  Xc:=x+Step;
  Fc:=F(Xc);
  if (Abs(F(x)) < Abs(Fc)) then Step:=-Step;
  NrFev0:=NrFev0+2;
  Xc:=x;
  repeat
    Xa:=Xc;
    Xc:=Xc+Step;
    Fa:=Fc;
    Inc(NrFev0); Fc:=F(Xc);
  until (Fa*Fc < 0.0) OR (NrFev0 > 0.5*LimFev0);
  if (Fa*Fc < 0.0) then Zero(F,Xa,Xc,x1);

  Step:=-Step;
  Xc:=x;
  Inc(NrFev0); Fc:=F(Xc);
  repeat
    Xa:=Xc;
    Xc:=Xc+Step;
    Fa:=Fc;
    Inc(NrFev0); Fc:=F(Xc);
  until (Fa*Fc < 0.0) OR (Abs(Xc-x) > Abs(x-x1)) OR (NrFev0 > LimFev0);
  if (Fa*Fc < 0.0) then Zero(F,Xa,Xc,x2);

  if Abs(F(x1)) > 0.1 then x1:=InfD; {x1 is a singularity}
  if Abs(F(x2)) > 0.1 then x2:=InfD; {x2 is a singularity}

  if (Abs(x-x1) < Abs(x-x2)) then x:=x1 else x:=x2;

  if(NrFev0 > LimFev0) then NrFev0:=LimFev0;

END; {.. ZeroStart}

{============================================================================}
procedure ZeroGrid (F: argF1; a,b: double; Npts:Word; var XX: VDn);
{Returns the first N_max roots of F(x) in the interval [a,b] using Zero alg.  }
{N_max is a constant defined in the interface section of unit LibMath.        }
{The roots are stored in XX[..], initially assigned InfD.                    }

var  dX, Xa,Xc, Fa,Fc, Xk: double;
     k: Byte;

BEGIN {ZeroGrid ..}
  for k:=1 to n_max do XX[k]:=InfD;
  Xc:=a;
  Fc:=F(Xc);  Inc(NrFev0);
  dX:=(b-a)/Npts;
  k:=1;
  repeat
    Xa:=Xc;
    Fa:=Fc;
    Xc:=Xc+dX;
    Fc:=F(Xc);  Inc(NrFev0);
    if (Fa*Fc < 0.0) then BEGIN
      Zero(F, Xa,Xc, Xk);
      if (Xk > Xa) AND (Xk < Xc) then BEGIN
        XX[k]:=Xk;
{
        if (k > 1) AND (Abs(Xk-XX[k-1]) < dX/2) then BEGIN
          Dec(k);
          XX[k]:=InfD;
        END;
}
        Inc(k);
      END;
    END;
  until (Xc > b) OR (k > N_max);
END; {.. ZeroGrid}

{============================================================================}
procedure GaussJordan(A:MDnn; B:VDn; var X:VDn; n:Byte; var OK:Boolean);
{ A[n,n] = the system matrix,  B[n] = the free term vector                   }
{ if (OK = FALSE) then A is singular                                         }

type  MatNI = array[1..N_max,1..3] of integer;

var W: ^MDnn;
    Index: ^MatNI;
    i,j,k,i1,j1, iRow,iCol: integer;
    Determ,Pivot,T,BIG: double;

{- - - - - - - - - - - - - - - - - - - - - - -}
procedure Swap(var D1,D2: double);
{Swaps D1 and D2 }
var Aux: double;
BEGIN
  Aux:=D1;  D1:=D2;  D2:=Aux;
END;  {.. Swap}

{- - - - - - - - - - - - - - - - - - - - - - -}
BEGIN {GaussJordan ..}
  New(W);
  New(Index);
  OK:=True;
  for i:=1 to n do BEGIN
    W^[i,1]:=B[i];
    Index^[i,3]:=0;
  END;
  Determ:=1.0;
  for i:=1 to n do BEGIN
    BIG:=0.0;
    for j:=1 to n do BEGIN
      if Index^[j,3] <> 1 then for k:=1 to n do BEGIN
        if Index^[k,3] > 1 then BEGIN
          OK:=False; { singular matrix }
          Dispose(W);
          Dispose(Index);
          Exit;
        END;
        if Index^[k,3] < 1 then if Abs(A[j,k]) > BIG then BEGIN
          iRow:=j;
          iCol:=k;
          BIG:=Abs(A[j,k]);
        END;
      END;
    END;
    Index^[iCol,3]:=Index^[iCol,3]+1;
    Index^[i,1]:=iRow;
    Index^[i,2]:=iCol;
    if iRow <> iCol then BEGIN
      Determ:=-Determ;
      for i1:=1 to n do Swap(A[iRow,i1],A[iCol,i1]);
      Swap(W^[iRow,1],W^[iCol,1]);
    END;
    Pivot:=A[iCol,iCol];
    if Pivot = 0.0 then BEGIN
      OK:=False; { singular matrix!}
      Dispose(W);
      Dispose(Index);
      Exit;
    END;
    Determ:=Determ*Pivot;
    A[iCol,iCol]:=1.0;
    for i1:=1 to n do A[iCol,i1]:=A[iCol,i1]/Pivot;
    W^[iCol,1]:=W^[iCol,1]/Pivot;
    for j1:=1 to n do BEGIN
      if (j1 <> iCol) then BEGIN
        T:=A[j1,iCol];
        A[j1,iCol]:=0.0;
        for i1:=1 to n do A[j1,i1]:=A[j1,i1]-A[iCol,i1]*T;
        W^[j1,1]:=W^[j1,1]-W^[iCol,1]*T;
      END;
    END;
  END;
  if NOT OK then BEGIN
    Dispose(W);
    Dispose(Index);
    Exit;
  END;
  for i:=1 to n do BEGIN
    i1:=n-i+1;
    if Index^[i1,1] <> Index^[i1,2] then BEGIN
      iRow:=Index^[i1,1];
      iCol:=Index^[i1,2];
      for k:=1 to n do Swap(A[k,iRow],A[k,iCol])
    END
  END;
  for k:=1 to n do if (Index^[k,3] <> 1) then BEGIN
    OK:=False; { Matrice singulara !! }
    Dispose(W);
    Dispose(Index);
    Exit;
  END;
  for i:=1 to n do X[i]:=W^[i,1];
  Dispose(W);
  Dispose(Index);
END; {.. GaussJordan}

{============================================================================}
procedure SparseLin(A:MDnn; B:VDn; var X:VDn; n:integer; var RSQ: double);

{ Solves the linear system A.X = B for the vector X[1, n] given the right-
 hand vector b[1,n], and given two functions, Asub(Xin,Xout) and
 ATsub(xin,xout), which respectively calculate AùX and ATùX for X given
 as their first arguments, returning the result in their second arguments.
 These subroutines should take every advantage of the sparseness of the
 matrix A. On input, X[1..n] should be set to a first guess of the desired
 solution (all zero components is fine). On output, X is the solution vector,
 and RSQ is the surn of the squares of the components of the residual vector
 AùX-B.  if this is not small, then the matrix is numerically singular and
 the solution represents a least-squares best approximation.                 }

const Eps=1.0E-18;  {r.m.s. accuracy desired}

var  j,iter,irst: integer;
     rp, gg, gam, Eps2, dgg, bsq, anum, aden: double;
     G, H, Xi, Xj: ^VDn;

label L1, L99;

{- - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure Asub(var X,Y: VDn; n: integer);
{Calculates AùX for a sparse matrix A }

var i,j: integer;

BEGIN
  for i:=1 to n do BEGIN
    Y[i]:=0.0;
    for j:=1 to n do Y[i]:=Y[i]+A[i,j]*X[j];
  END
END; {.. Asub}

{- - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure ATsub(var X,Y: VDn; n: integer);
{Calculate (A-Transpoosed)ùX for a sparse matrix A                           }

var i,j: integer;

BEGIN {ATsub ..}
  for i := 1 to n do BEGIN
    Y[i]:=0.0;
    for j:=1 to n do Y[i]:=Y[i]+A[j,i]*X[j]
  END;
END; {.. ATsub}
{- - - - - - - - - - - - - - - - - - - - - - - - - - -}

BEGIN {SparseLin ..}
  New(G);
  New(H);
  New(Xi);
  New(Xj);
  Eps2:=n*sqr(Eps); {Criterion for sum-squared residuals.       }
  irst:=0;          {first is the number of restarts attempted. }
L1:
  irst:=irst+1;
  Asub(X,Xi^,n);  {Evaluate the starting gradient}
  rp:=0.0;
  bsq:=0.0;
  for j:=1 to n do BEGIN
    bsq:=bsq+sqr(b[j]);  {and the magnitude of the right side. }
    Xi^[j]:=Xi^[j]-b[j];
    rp:=rp+sqr(Xi^[j]);
  END;
  ATsub(Xi^,G^,n);
  for j:=1 to n do BEGIN
    G^[j]:=-G^[j];
    H^[j]:= G^[j];
  END;
  for iter:=1 to 10*n do BEGIN  {main iteration loop.}
    Asub(H^,Xi^,n);
    anum:=0.0;
    aden:=0.0;
    for j:=1 to n do BEGIN
      anum:=anum+G^[j]*H^[j];
      aden:=aden+sqr(Xi^[j])
    END;
    if (aden = 0.0) then BEGIN
      WriteLn('Pause in routine SparseLin. Singular matrix.');
      ReadLn;
    END;
    anum:=anum/aden;
    for j:=1 to n do  BEGIN
      Xi^[j]:=X[j];
      X[j]:=X[j]+anum*H^[j];
    END;
    Asub(X,Xj^,n);
    RSQ:=0.0;
    for j:=1 to n do BEGIN
      Xj^[j]:=Xj^[j]-b[j];
      RSQ:=RSQ+sqr(Xj^[j])
    END;
    if (RSQ = rp) OR (RSQ <= bsq*Eps2) THEN {Converged - normal return.}
      goto L99;
    if (RSQ > rp) THEN BEGIN                {Not improving. do a restart.}
      for j := 1 to n do X[j]:=Xi^[j];
      if (irst >= 3) THEN goto L99;
      { Return if too many restarts. This is the normal return when we }
      { run into roundoff error before satisfying the return above.    }
      goto L1
    END;
    rp:=RSQ;
    ATsub(Xj^,Xi^,n);  {Compute gradient for next iteration.}
    gg:=0.0;
    dgg:=0.0;
    for j:=1 to n do BEGIN
      gg:=gg+sqr(G^[j]);
      dgg:=dgg+(Xi^[j]+G^[j])*Xi^[j]
    END;
    if (gg = 0.0) THEN goto L99;  {A rare, but normal, return.}
    gam:=dgg/gg;
    for j:=1 to n do BEGIN
      G^[j]:=-Xi^[j];
      H^[j]:=G^[j]+gam*H^[j];
    END;
  END;
L99:
  Dispose(Xj);
  Dispose(Xi);
  Dispose(H);
  Dispose(G)
END; {.. SparseLin}

{===========================================================================}
procedure Rat_Int(Xa,Ya: VDq; n: integer; x: double; var y,dy: double);
{Does a rational interpolation                                               }

var  ns,m,i: integer;
     w,t,hh,h,dd: double;
     C,D: ^VDq;

label L99;

BEGIN {Rat_Int ..}
  New(C);
  New(D);
  ns:=1;
  hh:=Abs(x-Xa[1]);
  for i:=1 to n do BEGIN
    h:=Abs(x-Xa[i]);
    if h = 0.0 then BEGIN
      y:=Ya[i];
      dy:=0.0;
      goto L99;
    END
    else if (h < hh) then BEGIN
      ns:=i;
      hh:=h;
    END;
    C^[i]:=Ya[i];
    D^[i]:=Ya[i]+EpsR;
  END;
  y:=Ya[ns];
  ns:=ns-1;
  for m:=1 to n-1 do BEGIN
    for i:=1 to n-m do BEGIN
      w:=C^[i+1]-D^[i];
      h:=Xa[i+m]-x;
      t:=(Xa[i]-x)*D^[i]/h;
      dd:=t-C^[i+1];
      if (dd = 0.0) then BEGIN
        WriteLn('Pause in routine RatInterp..');
        ReadLn;
      END;
      dd:=w/dd;
      D^[i]:=C^[i+1]*dd;
      C^[i]:=t*dd;
    END;
    if (2*ns < n-m) then dy:=C^[ns+1]
    else BEGIN
      dy:=D^[ns];
      ns:=ns-1;
    END;
    y:=y+dy;
  END;
L99:
  Dispose(C);
  Dispose(D);
END; {.. Rat_Int}

{----------------------------------------------------------------------------}
procedure SplineTg(var X,Y: VDq; n: integer; yp1,ypn: double; var Y2: VDq);
{ Return the 2nd derivative vector Y2[1..n] at points 1..n                   }
{ X[1..n], Y[1..n] are the control points                                    }
{ yp1, ypn are the 1st derivatives at control point 1 and n respectively     }

var i,k: integer;
    p,qn,sig,un: double;
    U: ^VDq;

{- - - - - - - - - - - - - - - - - - - - - -}
function Monotonic: Boolean;
var k: integer;
BEGIN
  Monotonic:=FALSE;
  for k:=2 to n-1 do if (X[k]-X[k-1])*(X[k+1]-X[k]) <= 0.0 then Exit;
  Monotonic:=TRUE;
END; {..Monotonic}
{- - - - - - - - - - - - - - - - - - - - - -}

BEGIN {SplineTg ..}
  if (n < 3) then BEGIN
    WriteLn('Number of nodes in SplineTg(..) must be greater than 2 !');
    Readln;  Exit;
  END;
  if NOT Monotonic then BEGIN
    WriteLn('X in SplineTg(..) must be monotonic!');
    Readln;  Exit;
  END;
  New(U);
  if (yp1 > InfR) then BEGIN
    Y2[1]:=0.0;
    U^[1]:=0.0;
  END
  else BEGIN
    Y2[1]:=-0.5;
    U^[1]:=(3.0/(X[2]-X[1]))*((Y[2]-Y[1])/(X[2]-X[1])-yp1);
  END;

  for i:=2 to n-1 do BEGIN
    sig:=(X[i]-X[i-1])/(X[i+1]-X[i-1]);
    p:=sig*Y2[i-1]+2.0;
    Y2[i]:=(sig-1.0)/p;
    U^[i]:=(Y[i+1]-Y[i])/(X[i+1]-X[i])-(Y[i]-Y[i-1])/(X[i]-X[i-1]);
    U^[i]:=(6.0*U^[i]/(X[i+1]-X[i-1])-sig*U^[i-1])/p;
  END;

  if (ypn > EpsR) then BEGIN
    qn:=0.0;
    un:=0.0;
  END
  else BEGIN
    qn:=0.5;
    un:=(3.0/(X[n]-X[n-1]))*(ypn-(Y[n]-Y[n-1])/(X[n]-X[n-1]));
  END;
  Y2[n]:=(un-qn*U^[n-1])/(qn*Y2[n-1]+1.0);

  for k:=n-1 downto 1 do Y2[k]:=Y2[k]*Y2[k+1]+U^[k];

  Dispose(U);
END; {.. SplineTg}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure IntSpline3(Xa,Ya,Y2a:VDq; i:integer; x:double; var y:double);
{Return y interpolated cubic-spline at x, where Xa,Ya are control points and }
{Ya2 is the second order derivative of Ya with respect to Xa at location x   }

var h,B,A: double;

BEGIN
  h:=Xa[i+1]-Xa[i];
  if (h = 0.0) then BEGIN
    WriteLn('Xa not monotonic in routine IntSpline3.');
    Readln;  Exit;
  END;
  A:=(Xa[i+1]-x)/h;
  B:=(x-Xa[i])/h;
  y:=A*Ya[i]+B*Ya[i+1];
  y:=y+((A*A*A-A)*Y2a[i]+(B*B*B-B)*Y2a[i+1])*Sqr(h)/6.0;
END; {.. IntSpline3}

{----------------------------------------------------------------------------}
procedure IntBspline2(XX,YY:VDq; i:integer; t:double; var x,y:double);
{Return x,y at knot t interpolated uniformly quadratic B_Spline              }
{between control points XX(i),YY(i) and XX(i+1),YY(i+1)                      }

var ax,bx,cx, ay,by,cy: double;

BEGIN {IntBspline2 ..}
  ax:=   XX[i-1] - 2*XX[i] + XX[i+1];
  bx:=-2*XX[i-1] + 2*XX[i];
  cx:=   XX[i-1] +   XX[i];

  ay:=   YY[i-1] - 2*YY[i] + YY[i+1];
  by:=-2*YY[i-1] + 2*YY[i];
  cy:=   YY[i-1] +   YY[i];

  x:=0.5*(ax*t*t + bx*t + cx);
  y:=0.5*(ay*t*t + by*t + cy);
END; {.. IntBspline2}

{----------------------------------------------------------------------------}
procedure IntBspline3(XX,YY:VDq; i:integer; t:double; var x,y:double);
{Return x,y at knot t interpolated uniformly cubic B_Spline                  }
{between control points XX(i),YY(i) and XX(i+1),YY(i+1)                      }

var ax,bx,cx,dx, ay,by,cy,dy: double;

BEGIN {IntBspline3 ..}
  ax:=  -XX[i-1] + 3*XX[i] - 3*XX[i+1] + XX[i+2];
  bx:= 3*XX[i-1] - 6*XX[i] + 3*XX[i+1];
  cx:=-3*XX[i-1]           + 3*XX[i+1];
  dx:=   XX[i-1] + 4*XX[i] +   XX[i+1];

  ay:=  -YY[i-1] + 3*YY[i] - 3*YY[i+1] + YY[i+2];
  by:= 3*YY[i-1] - 6*YY[i] + 3*YY[i+1];
  cy:=-3*YY[i-1]           + 3*YY[i+1];
  dy:=   YY[i-1] + 4*YY[i] +   YY[i+1];

  x:=(ax*t*t*t + bx*t*t + cx*t + dx)/6.0;
  y:=(ay*t*t*t + by*t*t + cy*t + dy)/6.0;
END; {.. IntBspline3}

{============================================================================}
function GaussRandom(Mean,StDev: double): double;
{Generate random numbers with mean Mean and standard deviation StDev         }
var  x1,x2,w,y1,y2: double;

BEGIN
  Randomize;
  repeat
    x1:=2.0*Random-1.0;
    x2:=2.0*Random-1.0;
    w:=x1*x1+x2*x2;
  until (w < 1.0);
  w:=Sqrt(-2.0*Ln(w)/w);
  GaussRandom:=Mean+0.5*w*(x1+x2)*StDev;
END; {.. GaussRandom}

{----------------------------------------------------------------------------}
function Average(Xn:VDm; n:Byte): double;
var i: Byte;    Avg: double;
BEGIN
  Avg:=0.0; for i:=1 to n do Avg:=Avg+Xn[i]; Average:=Avg/n;
END; {.. Average}

{----------------------------------------------------------------------------}
function  StanDev(Xn:VDm; n:Byte): double;
var i: Byte;    Avg,Sum2: double;
BEGIN
  Avg :=0.0;  for i:=1 to n do Avg:=Avg+Xn[i];  Avg:=Avg/n;
  Sum2:=0.0;  for i:=1 to n do Sum2:=Sum2+Sqr(Xn[i]-Avg);
  StanDev:=Sqrt(Sum2/n);
END; {.. StanDev}

{----------------------------------------------------------------------------}
procedure AvgStDev(Xn:VDm; n:Byte; var Avg,StDev: double);
var i: Byte;
BEGIN
  Avg:=0.0;
  for i:=1 to n do Avg:=Avg+Xn[i];
  Avg:=Avg/n;
  StDev:=0.0;
  for i:=1 to n do StDev:=StDev+Sqr(Xn[i]-Avg);
  StDev:=Sqrt(StDev/n);
END; {.. AvgStDev}

{============================================================================}
BEGIN
  NrFev0:=0;
  _:=InfD;
END. {.. LibMath}
