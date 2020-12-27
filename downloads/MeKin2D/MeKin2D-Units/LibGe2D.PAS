Unit LibGe2D;
{ $R+ }
{ $S- }
{=============================================================================
  Unit for 2D geometric calculations
  (c) P.A. Simionescu 2018
=============================================================================}

INTERFACE

uses  LibMath,
      LibMinn;

var  MaxEffEps2,         {maximum effective Eps in Coinc2Pts}
     MaxEffEps3:double;  {maximum effective Eps in Colin3Pts}

function  Dist2Pts2D(x1,y1, x2,y2: double): double;
procedure PerpPtLn2D(xA,yA,xB,yB,xC,yC: double; var x,y: double);
function  DistPtLn2D(xA,yA, xB,yB,  xC,yC: double): double;

function  U2dirs2D  (l1,m1,l2,m2: double): double;
function  U2dirs2D90(l1,m1, l2,m2: double): double;
function  U3pts2D   (x1,y1, x0,y0, x2,y2: double): double;
function  U3pts2D90 (x1,y1, x0,y0, x2,y2: double): double;

function  isFourBar(a,b,c,d: double): Boolean;

procedure RT2DcAsA(x1,y1,cosAlpha,sinAlpha,Dx,Dy: double; var x2,y2: double);

procedure RT2D(x1,y1, Alpha, Dx,Dy: double; var x2,y2: double);

function  isA_P_B(xA,yA,xB,yB,x,y: double):Boolean;

procedure A_P_B(xA,yA,xB,yB, AP:double; var x,y:double);

function  S123(x1,y1, x2,y2, x3,y3: double): double;

function  Coinc2Pts2D(xA,yA, xB,yB, Eps2: double): Boolean;
function  Colin3Pts2D(x1,y1, x2,y2, x3,y3, Eps3: double): Boolean;

procedure Circ3Pts(xA,yA,xB,yB,xC,yC: double; var R,x,y: double);
procedure Circ4Pts(x1,y1,x2,y2,x3,y3,x4,y4:double; var R,xK,yK:double);
procedure Circ5Pts(x1,y1,x2,y2,x3,y3,x4,y4,x5,y5: double; var R,xK,yK: double);

function  Rcurv3Pts (x1,y1, x2,y2, x3,y3: double): double;
function  Rcurv43Pts(x1,y1, x2,y2, x3,y3, x4,y4: double): double;
function  Rcurv4Pts (x1,y1, x2,y2, x3,y3, x4,y4: double): double;
function  Rcurv4PtsR(x1,y1, x2,y2, x3,y3, x4,y4: double): double;

procedure Int2Lns(x1,y1,x2,y2, x3,y3,x4,y4:double;
          var x,y:double; var OK:Boolean);

procedure Int2Circs12(xA,yA,xB,yB,r1,r2:double; var x1,y1,x2,y2, Delta: double);

procedure IntCircLn(xO,yO,r, xA,yA,xB,yB:double;
          var x1,y1,x2,y2:double; var OK:Boolean);

procedure IntParabCirc(a,b,c, xC,yC,r:double;
          var x,y:double; var OK:Boolean);

procedure TangSlopemToParab(a,b,c, m: double; var x,y:double);

procedure TangPointToCirc(xA,yA, xO,yO,r:double;
          var x1,y1,x2,y2:double; var OK:Boolean);

procedure ExtTang2Circ(xO1,yO1, r1, xO2,yO2,r2:double;
          var x1,y1,x2,y2, x1p,y1p,x2p,y2p:double; var OK:Boolean);

procedure CrosTang2Circ(xO1,yO1, r1, xO2,yO2,r2:double;
          var x1,y1,x2,y2, x1p,y1p,x2p,y2p:double; var OK:Boolean);

procedure TangPointToParab(xA,yA, a,b,c:double;
          var x1,y1,x2,y2:double; var OK:Boolean);

procedure TangComParabCirc(a0,b0,c0, xO,yO,r:double;
          var x,y, xA,yA:double; var OK:Boolean);

procedure GetCenterPtPtRad(xA,yA,xB,yB, R: double; var xO,yO: double);

procedure PtsOn123Arc(x1,y1, x2,y2, x3,y3, dAng: double;
          var x,y: VDo;  var n: Integer);
{----------------------------------------------------------------------------}

IMPLEMENTATION

{============================================================================}
function Dist2Pts2D(x1,y1, x2,y2: double): double;
{Returns the distance between 2 points                                       }
BEGIN
  Dist2Pts2D:=Sqrt(Sqr(x2-x1)+Sqr(y2-y1));
END;  {.. Dist2Pts2D}

{----------------------------------------------------------------------------}
procedure PerpPtLn2D(xA,yA, xB,yB,xC,yC: double; var x,y: double);
var xBA,yBA: double;  OK: Boolean;
BEGIN
  xBA:=xB-xA;
  yBA:=yB-yA;
  LinEq2(xBA,yBA,xBA*xC+yBA*yC, yBA,-xBA,yBA*xA-xBA*yA, x,y,OK);
  if NOT OK then BEGIN  {A, B & C are colinear points..}
    x:=xC;   y:=yC;
  END;
END; {.. PerpPtLn2D}

{----------------------------------------------------------------------------}
function DistPtLn2D(xA,yA, xB,yB,  xC,yC: double): double;
{Returns the distance between point (xC,yC) and line (xA,yA)-(xB,yB)      }
var x,y: double;
BEGIN
  PerpPtLn2D(xA,yA,xB,yB,xC,yC, x,y);
  DistPtLn2D:=Dist2Pts2D(x,y,xC,yC);
END; {.. DistPtLn2D}

{----------------------------------------------------------------------------}
function U2dirs2D(l1,m1, l2,m2: double): double;
{Returns the angle between vectors (l1,m1) and (l2,m2) within [-Pi/2..3/2*Pi]}
var  sU,cU:double;

BEGIN
  sU:=l1*m2-l2*m1;  {..unscalled sine of the angle from the cross product}
  cU:=l1*l2+m1*m2;  {..unscaled cosine of the angle from the dot product}
  U2dirs2D:=Atan2(sU,cU);
END;  {.. U2dirs2D}

{----------------------------------------------------------------------------}
function U3pts2D(x1,y1, x0,y0, x2,y2: double): double;
{Returns the angle between 1-0 and 0-2 within [-Pi/2..3/2*Pi]                }
BEGIN
  U3pts2D:=U2dirs2D(x1-x0,y1-y0, x2-x0,y2-y0);
END;  {.. U3pts2D}

{----------------------------------------------------------------------------}
function U2dirs2D90(l1,m1, l2,m2: double): double;
{Returns the angle between the vectors (l1,m1) and (l2,m2) within [0..Pi/2]  }
var  sU,cU:double;

BEGIN
  sU:=Abs(l1*m2 - l2*m1);   {.. sin from cross product  }
  cU:=Abs(l1*l2 + m1*m2);   {.. cos from the dot product}
  U2dirs2D90:=Atan2(su,cU);
END;  {.. U2dirs2D90}

{----------------------------------------------------------------------------}
function U3pts2D90(x1,y1, x0,y0, x2,y2: double): double;
{Returns the angle between 1-0 and 0-2 within the interval [0..Pi/2]         }
BEGIN
  U3pts2D90:=U2dirs2D90(x1-x0,y1-y0, x2-x0,y2-y0);
END;  {.. U3pts2D90}

{----------------------------------------------------------------------------}
procedure RT2DcAsA(x1,y1,cosAlpha,sinAlpha,Dx,Dy: double; var x2,y2: double);
{Rotate (x1,y1) by Alpha, translate by Dx,Dy and assign result to (x2,y2)    }
var x,y: double;

BEGIN
  x:=Dx+x1*cosAlpha-y1*sinAlpha;
  y:=Dy+x1*sinAlpha+y1*cosAlpha;
  x2:=x;
  y2:=y;
END; {.. RT2DcAsA}

{----------------------------------------------------------------------------}
procedure RT2D(x1,y1,Alpha,Dx,Dy: double; var x2,y2: double);
{Rotate (x1,y1) by Alpha, translate by Dx,Dy and assign result to (x2,y2)    }

BEGIN
  RT2DcAsA(x1,y1,cos(Alpha),sin(Alpha),Dx,Dy,x2,y2)
END; {.. RT2D}

{----------------------------------------------------------------------------}
function isA_P_B(xA,yA, xB,yB, x,y: double):Boolean;
{Returns true if point P(x,y) is located between A and B }
BEGIN
  if (xA-x)*(xB-x)+(yA-y)*(yB-y) < 0.0 then
    isA_P_B:=TRUE
  else
    isA_P_B:=FALSE;
END; {.. isA_P_B}

{----------------------------------------------------------------------------}
procedure A_P_B(xA,yA, xB,yB, AP:double; var x,y:double);
{Calculates the coordinates of point P on the line AB located at AP from A   }
var AB,newX,newY: double;

BEGIN
  x:=xA;
  y:=yA;
  AB:=Dist2Pts2D(xA,yA,xB,yB);
  if (AB < EpsR) then Exit;
  newX:=xA+(xB-xA)*AP/AB;
  newY:=yA+(yB-yA)*AP/AB;
  x:=newX;
  y:=newY;
END; {.. A_P_B}

{----------------------------------------------------------------------------}
function S123(x1,y1, x2,y2, x3,y3: double): double;
{Twice the area of 1-2-3 triangle calculated with the cross product 2-1 x 3-1}
{If the 1-2-3 loop is oriented ccw, then S123 > 0 .                          }

BEGIN
  S123:=(x2-x1)*(y3-y1) - (y2-y1)*(x3-x1);
END; {.. S123}

{----------------------------------------------------------------------------}
function isFourBar(a,b,c,d: double): Boolean;
BEGIN
  isFourBar:=TRUE;
  if (a+b+c+d) < 2*Max2(Max3(a,b,c),d) then isFourBar:=FALSE;
END; {.. isFourBar}

{----------------------------------------------------------------------------}
function Coinc2Pts2D(xA,yA, xB,yB, Eps2: double): Boolean;
{Check if points A and B coincide with precision Eps}

var A_B: double;

BEGIN
  Coinc2Pts2D:=TRUE;
  if (xA = xB) AND (yA = yB) then Exit;
  A_B:=Sqr(xA-xB)+Sqr(yA-yB);
  if (A_B  > Eps2) then Coinc2Pts2D:=FALSE;
  MaxEffEps2:=min2(MaxEffEps2,A_B); {retains minimum distance A_B squared}
END; {.. Coinc2Pts2D}

{----------------------------------------------------------------------------}
function Colin3Pts2D(x1,y1, x2,y2, x3,y3, Eps3: double): Boolean;
{Check if (x1,y1) (x2,y2) (x3,y3) are collinear with precision Eps3. }

var ReqEps3, D1_3, MaxD123: double;

BEGIN
  Colin3Pts2D:=FALSE;
  if (x1 = InfD) OR (y1 = InfD) OR (x2 = InfD) OR (y2 = InfD) then Exit;
  D1_3:=Sqr(x1-x3)+Sqr(y1-y3); {..square distance between 1st and 3rd point}
  MaxD123:=Max3(Sqr(x1-x2)+Sqr(y1-y2), D1_3, Sqr(x2-x3)+Sqr(y2-y3));
  if (D1_3 = MaxD123) then BEGIN {points ordered 1-2-3 with 2 in the middle}
    ReqEps3:=4.0*Sqr((x2-x1)*(y3-y1)-(y2-y1)*(x3-x1))/(D1_3+EpsR); {..+EpsD to avoid 1/0}
    if (ReqEps3 <= Eps3) then Colin3Pts2D:=TRUE;
    MaxEffEps3:=min2(MaxEffEps3, ReqEps3);  {retain minimum required Eps3}
  END;
END; {.. Colin3Pts2D}

{----------------------------------------------------------------------------}
procedure Circ3Pts(xA,yA,xB,yB,xC,yC: double; var R,x,y: double);
{Calculates radius and center of a circle circumscribed to points A,B,C      }

var S1_3, T1,T2, a1,b1,c1, a2,b2,c2: double;  OK: Boolean;

BEGIN
  S1_3:=S123(xA,yA,xB,yB,xC,yC);
  a1:=2*(xC-xB);  b1:=2*(yC-yB);
  c1:=Sqr(xC)-Sqr(xB)+Sqr(yC)-Sqr(yB);
  a2:=2*(xA-xB);  b2:=2*(yA-yB);
  c2:=Sqr(xA)-Sqr(xB)+Sqr(yA)-Sqr(yB);

  LinEq2(a1,b1,c1,a2,b2,c2, x,y, OK);

  if OK then
    R:=sgn(S1_3)*Sqrt(Sqr(x-xB)+Sqr(y-yB))
  else BEGIN
    RT2D(xB,yB,0.5*Pi,xC,yC,x,y);  {rotate point (xC,yC) about (xB,yB) }
    R:=InfD;
  END;

{
  if (Abs(S1_3) > EpsR) then BEGIN
    T1:=(Sqr(xA)+Sqr(yA)-Sqr(xB)-Sqr(yB))/2;
    T2:=(Sqr(xA)+Sqr(yA)-Sqr(xC)-Sqr(yC))/2;
    x:=(T1*(yA-yC)-T2*(yA-yB))/S1_3;
    y:=(T2*(xA-xB)-T1*(xA-xC))/S1_3;
    R:=sgn(S1_3)*Sqrt(Sqr(x-xB)+Sqr(y-yB))
  END
  else BEGIN
    RT2D(xB,yB,Pi/2,xC,yC,x,y);
    R:=InfD;
  END;
}

END; {.. Circ3Pts}

{----------------------------------------------------------------------------}
procedure Circ4Pts(x1,y1,x2,y2,x3,y3,x4,y4: double; var R,xK,yK: double);
{Calculates radius & center of a circle through points 1 - Avg(2,3) - 4      }
var  x23,y23: double;
BEGIN
  x23:=0.5*(x2+x3);
  y23:=0.5*(y2+y3);
  Circ3Pts(x1,y1, x23,y23, x4,y4, R,xK,yK);
END; {.. Circ4Pts}

{----------------------------------------------------------------------------}
procedure Circ5Pts(x1,y1,x2,y2,x3,y3,x4,y4,x5,y5: double; var R,xK,yK: double);
{Calculates radius & center of a circle that best fits points 1..5           }
{Circ3Pts(x1,y1, xB,yB, x5,y5, R, xK,yK);   works OK                         }
{Circ3Pts(xA,yA, x3,y3, xC,yC, R, xK,yK);   not OK                           }
{Circ3Pts(xA,yA, xB,yB, xC,yC, R, xK,yK);   not OK                           }
{Circ3Pts(xA,yA, xB,yB, xC,yC, R, xK,yK);   not OK                           }

var  xA,yA, xB,yB, xC,yC: double;

BEGIN
{
  xA:=0.5*(x1+x2);
  yA:=0.5*(y1+y2);
  xC:=0.5*(x4+x5);
  yC:=0.5*(y4+y5);
  Circ3Pts(xA,yA, x3,y3, xC,yC, R, xK,yK);
  xB:=(x2+x3+x4)/3.0; yB:=(y2+y3+y4)/3.0;
  Circ3Pts(xA,yA, xB,yB, xC,yC, R, xK,yK);
}
  xB:=0.5*(x2+x4); yB:=0.5*(y2+y4);
  Circ3Pts(x1,y1, xB,yB, x5,y5, R, xK,yK);
END; {.. Circ5Pts}

{----------------------------------------------------------------------------}
function Rcurv3Pts(x1,y1,x2,y2,x3,y3: double): double;
{Returns the curvature k at x=(x1+x2+x3)/3 of a parabola through 3 points   }
{y(x)=a*x^2+b*x+c;  y'(x)=2*a*x+b;  y"(x)=2*a;  k=y"/(1+(y')^2)^1.5)        }

var  x,y, a,b,c, k: double;

BEGIN
  x:=(x1+x2+x3)/3.0;
  x:=x2;
  Intp2(x, x1,y1,x2,y2,x3,y3, y, a,b,c);
  k:=(2*a)/Pow(1.0+Sqr(2*a*x+b),1.5);
  if (Abs(k) > EpsD) then Rcurv3Pts:=1.0/k else Rcurv3Pts:=InfD;
END; {.. Rcurv3Pts}

{----------------------------------------------------------------------------}
function Rcurv43Pts(x1,y1,x2,y2,x3,y3,x4,y4: double): double;
{Returns the radius of curvature k around points 1,2,3,4,  using the average }
{coeficients a,b and c of the 4 possible parabolas through pts. 1,2,3,4      }
{y(x)=a*x^2+b*x+c; y'(x)=2*a*x+b; y"(x)=2*a; k=y"/(1+(y')^2)^1.5) where a,b,c}

var  x,y, a,b,c, a_,b_,c_, k: double;

BEGIN
  x:=(x1+x2+x3)/3.0;  Intp2(x, x1,y1,x2,y2,x3,y3, y, a, b, c);
  x:=(x1+x2+x4)/3.0;  Intp2(x, x1,y1,x2,y2,x4,y4, y, a_,b_,c_);
  a:=a+a_;  b:=b+b_;  c:=c+c_;
  x:=(x1+x3+x4)/3.0;  Intp2(x, x1,y1,x3,y3,x4,y4, y, a_,b_,c_);
  a:=a+a_;  b:=b+b_;  c:=c+c_;
  x:=(x2+x3+x4)/3.0;  Intp2(x, x2,y2,x3,y3,x4,y4, y, a_,b_,c_);
  a:=(a+a_)/4.0;
  b:=(b+b_)/4.0;
  c:=(c+c_)/4.0;
  k:=(2*a)/Pow(1.0+Sqr(2*a*x+b),1.5);
  if (Abs(k) > EpsD) then Rcurv43Pts:=1.0/k else Rcurv43Pts:=InfD;
END; {.. Rcurv43Pts}

{----------------------------------------------------------------------------}
function Rcurv4Pts(x1,y1,x2,y2,x3,y3,x4,y4: double): double;
{Returns the radius of curvature k at x of a cubic through 4 points       }
{ k=y"/(1+(y')^2)^1.5), where  y(x)=a*x^3+b*x^2+c*x+d;                    }
{ y'(x)=3*a*x^2+2*b*x+c;  y"(x)=6*a*x+2*b;                                }

var x,y, a,b,c,d, k: double;

BEGIN
{ x:=(x2+x3)/2;  }
  x:=(x1+x2+x3+x4)/4;
  Intp3(x, x1,y1,x2,y2,x3,y3,x4,y4, y, a,b,c,d);
  k:=(6*a*x+2*b)/Pow(1.0+Sqr(3*a*x*x+2*b*x+c),1.5);
  if (Abs(k) > EpsD) then Rcurv4Pts:=1.0/k else Rcurv4Pts:=InfD;
END; {.. Rcurv4Pts}

{----------------------------------------------------------------------------}
function Rcurv4PtsR(x1,y1,x2,y2,x3,y3,x4,y4: double): double;
{Returns the radius of curvature k at x=(x1+x2+x3+x4)/4 of a cubic through 4 }
{points. It first rotate points 1..4 to make line 1-4 horizontal, then uses  }
{k=y"/(1+(y')^2)^1.5),  where y(x)=a*x^3+b*x^2+c*x+d;  y'(x)=3*a*x^2+2*b*x+c;}
{y"(x)=6*a*x+2*b;                                                            }

var  D14, cA,sA, x,y, a,b,c,d, k: double;

BEGIN
  D14:=Dist2Pts2D(x1,y1,x4,y4);
  if (D14 > EpsD) then BEGIN {rotate pts 1,2,3 and 4}
    cA:= (x4-x1)/D14;
    sA:=-(y4-y1)/D14;
    RT2DcAsA(x1,y1, cA,sA, 0,0, x1,y1);
    RT2DcAsA(x2,y2, cA,sA, 0,0, x2,y2);
    RT2DcAsA(x3,y3, cA,sA, 0,0, x3,y3);
    RT2DcAsA(x4,y4, cA,sA, 0,0, x4,y4);
  END;
  x:=(x1+x2+x3+x4)/4;
  x:=(x2+x3)/2;
  Intp3(x, x1,y1,x2,y2,x3,y3,x4,y4, y, a,b,c,d);
  k:=(6*a*x+2*b)/Pow(1.0+Sqr(3*a*x*x+2*b*x+c),1.5);
  if (Abs(k) > EpsD) then Rcurv4PtsR:=1.0/k else Rcurv4PtsR:=InfD;
END; {.. Rcurv4PtsR}

{----------------------------------------------------------------------------}
procedure Int2Lns(x1,y1,x2,y2, x3,y3,x4,y4:double;
          var x,y:double; var OK:Boolean);
{Calculates the intersection point between two lines}

var T0:double;

BEGIN
  OK:=FALSE;
  x:=InfD;  y:=InfD;
  T0:=(x3*y1-x4*y1-x3*y2+x4*y2-x1*y3+x2*y3+x1*y4-x2*y4);
  if (Abs(T0) < epsR) then Exit;
  x:=(x2*x3*y1-x2*x4*y1-x1*x3*y2+x1*x4*y2-x1*x4*y3+x2*x4*y3+x1*x3*y4-x2*x3*y4)/T0;
  y:=(x2*y1*y3-x4*y1*y3-x1*y2*y3+x4*y2*y3-x2*y1*y4+x3*y1*y4+x1*y2*y4-x3*y2*y4)/T0;
  OK:=TRUE;
END; {.. Int2Lns}

{----------------------------------------------------------------------------}
procedure OLDInt2Circles(xA,yA, xB,yB, r1,r2:double; var x1,y1,x2,y2, Delta: double);
{Calculates the coordinates of the intersection points between two circles.  }
{If Delta < 0 then it calculates (x1,y1) & (x2,y2) assuming Delta = 0.       }

var a,b, Delta_: double;

BEGIN
  if (Abs(xA-xB) > Abs(yA-yB)) then BEGIN
    a:=(yB-yA)/(xA-xB);
    b:=0.5*(xA+xB-a*(yA+yB)+(r2*r2-r1*r1)/(xA-xB));
    Delta:=Sqr(a*b-a*xA-yA)-(a*a+1)*(b*b-2*b*xA+xA*xA+yA*yA-r1*r1);
    Delta_:=Delta;  if (Delta_ < 0) then Delta_:=0;
    y1:=(-a*b+a*xA+yA-Sqrt(Delta_))/(a*a+1);
    x1:=a*y1+b;
    y2:=(-a*b+a*xA+yA+Sqrt(Delta_))/(a*a+1);
    x2:=a*y2+b;
  END
  else BEGIN
    if (Abs(yA-yB) < EpsR) then BEGIN
      a:=(xB-xA)/(yA-yB);
      b:=0.5*(yA+yB-a*(xA+xB)+(r2*r2-r1*r1)/( EpsR*Sgn(yA-yB) ));
    END
    else BEGIN
      a:=(xB-xA)/(yA-yB);
      b:=0.5*(yA+yB-a*(xA+xB)+(r2*r2-r1*r1)/(yA-yB));
    END;
    Delta:=Sqr(a*b-a*yA-xA)-(a*a+1)*(b*b-2*b*yA+xA*xA+yA*yA-r1*r1);
    Delta_:=Delta;  if (Delta_ < 0) then Delta_:=0;
    x1:=(-a*b+a*yA+xA - Sqrt(Delta_))/(a*a+1);
    y1:=a*x1+b;
    x2:=(-a*b+a*yA+xA + Sqrt(Delta_))/(a*a+1);
    y2:=a*x2+b;
  END;
END; {.. Int2Cir}

{----------------------------------------------------------------------------}
procedure Int2Circs12(xA,yA, xB,yB, r1,r2:double; var x1,y1,x2,y2, Delta: double);
{Calculates the coordinates of the intersection points between two circles.  }
{If Delta < 0 then it calculates (x1,y1) & (x2,y2) assuming Delta = 0.       }

var a,b, LocalDelta: double;

BEGIN
  if (Abs(xA-xB) < Abs(yA-yB)) then BEGIN
    if (Abs(yA-yB) <= 1.0E-9) then BEGIN
      a:=(xB-xA)/(1.0E-9*Sgn(yA-yB));
      b:=0.5*(yA+yB-a*(xA+xB)+(r2*r2-r1*r1)/(1.0E-9*Sgn(yA-yB)));
    END
    else BEGIN
      a:=(xB-xA)/(yA-yB);
      b:=0.5*(yA+yB-a*(xA+xB)+(r2*r2-r1*r1)/(yA-yB));
    END;
    Delta:=Sqr(a*b-a*yA-xA)-(a*a+1)*(b*b-2*b*yA+xA*xA+yA*yA-r1*r1);
    LocalDelta:=Delta;  if (LocalDelta < 0.0) then LocalDelta:=0.0;
    x1:=(-a*b+a*yA+xA-Sqrt(LocalDelta))/(a*a+1);
    y1:=a*x1+b;
    x2:=(-a*b+a*yA+xA+Sqrt(LocalDelta))/(a*a+1);
    y2:=a*x2+b;
  END
  else BEGIN
    if (Abs(xA-xB) <= EpsR) then BEGIN
      a:=(yB-yA)/(EpsR);
      b:=0.5*(xA+xB-a*(yA+yB)+(r2*r2-r1*r1)/(EpsR));
    END
    else BEGIN
      a:=(yB-yA)/(xA-xB);
      b:=0.5*(xA+xB-a*(yA+yB)+(r2*r2-r1*r1)/(xA-xB));
    END;
    Delta:=Sqr(a*b-a*xA-yA)-(a*a+1.0)*(b*b-2*b*xA+xA*xA+yA*yA-r1*r1);
    LocalDelta:=Delta;
    if (LocalDelta < 0.0) then LocalDelta:=0.0;
    y1:=(-a*b+a*xA+yA-Sqrt(LocalDelta))/(a*a+1);
    x1:=a*y1+b;
    y2:=(-a*b+a*xA+yA+Sqrt(LocalDelta))/(a*a+1);
    x2:=a*y2+b;
  END;
END; {.. Int2Circs12}

{----------------------------------------------------------------------------}
procedure IntCircLn(xO,yO,r, xA,yA,xB,yB:double;
          var x1,y1, x2,y2:double; var OK:Boolean);
{Calculates the intersection point between a circle and a line}

var Delta: double;

BEGIN
  OK:=FALSE;
  xA:=xA-xO;   yA:=yA-yO;
  xB:=xB-xO;   yB:=yB-yO;

  if (Sqr(xB-xA)+Sqr(yB-yA) < EpsD) then Exit;

  Delta:=r*r*(Sqr(xB-xA)+Sqr(yB-yA)) - Sqr(xA*yB-xB*yA);
  if (Delta < 0) then Exit;

  if (Abs(xA-xB) > Abs(yA-yB)) AND TRUE then BEGIN
    x1:=(-(yB-yA)*(xB*yA-xA*yB) - (xB-xA)*Sqrt(Delta))/(Sqr(xB-xA)+Sqr(yB-yA));
    y1:=(yB-yA)/(xB-xA)*x1 + (xB*yA-xA*yB)/(xB-xA);

    x2:=(-(yB-yA)*(xB*yA-xA*yB) + (xB-xA)*Sqrt(Delta))/(Sqr(xB-xA)+Sqr(yB-yA));
    y2:=(yB-yA)/(xB-xA)*x2 + (xB*yA-xA*yB)/(xB-xA);
  END
  else BEGIN
    y1:=(-(xB-xA)*(yB*xA-yA*xB) - (yB-yA)*Sqrt(Delta))/(Sqr(yB-yA)+Sqr(xB-xA));
    x1:=(xB-xA)/(yB-yA)*y1 + (yB*xA-yA*xB)/(yB-yA);

    y2:=(-(xB-xA)*(yB*xA-yA*xB) + (yB-yA)*Sqrt(Delta))/(Sqr(yB-yA)+Sqr(xB-xA));
    x2:=(xB-xA)/(yB-yA)*y2 + (yB*xA-yA*xB)/(yB-yA);
  END;

  x1:=x1+xO;
  y1:=y1+yO;
  x2:=x2+xO;
  y2:=y2+yO;
  OK:=TRUE;
END; {.. IntCircLn}

{----------------------------------------------------------------------------}
procedure TangSlopemToParab(a,b,c, m: double; var x,y:double);

BEGIN
  x:=InfD;
  y:=InfD;
  if (Abs(a) < 1.0/InfD) OR (a = InfD) then Exit;
  x:=(m-b)/(2.0*a);
  y:=a*x*x+b*x+c;
END; {.. TangSlopemToParab}

{----------------------------------------------------------------------------}
procedure TangPointToCirc(xA,yA, xO,yO,r:double;
          var x1,y1,x2,y2:double; var OK:Boolean);
{Returns tangency points x1,y1 & x2,y2 between a circle centered at xO,yO and}
{radius r, and the tangent to that circle from external point xA,yA.         }

var Delta: double;

BEGIN
  OK:=FALSE;
  x1:=InfD;  y1:=InfD;
  x2:=InfD;  y2:=InfD;
  xA:=xA-xO;
  yA:=yA-yO;
  Delta:=xA*xA + yA*yA - r*r;
  if (Delta < 0) then Exit;
  if Abs(xA) > Abs(yA) then BEGIN
    y1:=(r*r*yA - r*xA*Sqrt(Delta))/(xA*xA + yA*yA);
    x1:=(r*r - yA*y1)/xA;
    y2:=(r*r*yA + r*xA*Sqrt(Delta))/(xA*xA + yA*yA);
    x2:=(r*r - yA*y2)/xA;
  END
  else BEGIN
    x1:=(r*r*xA - r*yA*Sqrt(Delta))/(xA*xA + yA*yA);
    y1:=(r*r - xA*x1)/yA;
    x2:=(r*r*xA + r*yA*Sqrt(Delta))/(xA*xA + yA*yA);
    y2:=(r*r - xA*x2)/yA;
  END;
  x1:=x1+xO;
  y1:=y1+yO;
  x2:=x2+xO;
  y2:=y2+yO;
  OK:=TRUE;
END; {.. TangPointToCirc}

{----------------------------------------------------------------------------}
procedure ExtTang2Circ(xO1,yO1, r1, xO2,yO2,r2:double;
          var x1,y1,x2,y2, x1p,y1p,x2p,y2p:double; var OK:Boolean);
{Returns the external tangency points between two circles.  }
var O1O2,cTh,sTh,cA,sA,x,y: double;

BEGIN
  OK:=FALSE;
  x1:=InfD;      y1:=InfD;
  x2:=InfD;      y2:=InfD;
  x1p:=InfD;     y1p:=InfD;
  x2p:=InfD;     y2p:=InfD;
  O1O2:=Sqrt(Sqr(xO2-xO1)+Sqr(yO2-yO1));
  cTh:= (xO2-xO1)/O1O2;
  sTh:= (yO2-yO1)/O1O2;
  cA:=(r1-r2)/O1O2;
  if Abs(cA) > 1.0 then Exit;
  sA:=Sqrt(1.0-cA*cA);

  x:=r1*cA;       y:=r1*sA;
  x1:=(x*cTh-y*sTh)+xO1;
  y1:=(x*sTh+y*cTh)+yO1;
  x:=O1O2+r2*cA;  y:=r2*sA;
  x2:=(x*cTh-y*sTh)+xO1;
  y2:=(x*sTh+y*cTh)+yO1;

  x:=r1*cA;       y:=-r1*sA;
  x1p:=(x*cTh-y*sTh)+xO1;
  y1p:=(x*sTh+y*cTh)+yO1;
  x:=O1O2+r2*cA;  y:=-r2*sA;
  x2p:=(x*cTh-y*sTh)+xO1;
  y2p:=(x*sTh+y*cTh)+yO1;

  OK:=TRUE;
END; {.. ExtTang2Circ}

{----------------------------------------------------------------------------}
procedure CrosTang2Circ(xO1,yO1, r1, xO2,yO2,r2:double;
          var x1,y1,x2,y2, x1p,y1p,x2p,y2p:double; var OK:Boolean);
{Returns the external tangency points between two circles.  }
var O1O2,cTh,sTh,cA,sA,x,y: double;

BEGIN
  OK:=FALSE;
  x1:=InfD;      y1:=InfD;
  x2:=InfD;      y2:=InfD;
  x1p:=InfD;     y1p:=InfD;
  x2p:=InfD;     y2p:=InfD;
  O1O2:=Sqrt(Sqr(xO2-xO1)+Sqr(yO2-yO1));
  cTh:= (xO2-xO1)/O1O2;
  sTh:= (yO2-yO1)/O1O2;
  cA:=(r1+r2)/O1O2;
  if Abs(cA) > 1.0 then Exit;
  sA:=Sqrt(1.0-cA*cA);

  x:=r1*cA;       y:=r1*sA;
  x1:=(x*cTh-y*sTh)+xO1;
  y1:=(x*sTh+y*cTh)+yO1;
  x:=O1O2-r2*cA;  y:=-r2*sA;
  x2:=(x*cTh-y*sTh)+xO1;
  y2:=(x*sTh+y*cTh)+yO1;

  x:=r1*cA;       y:=-r1*sA;
  x1p:=(x*cTh-y*sTh)+xO1;
  y1p:=(x*sTh+y*cTh)+yO1;
  x:=O1O2-r2*cA;  y:=r2*sA;
  x2p:=(x*cTh-y*sTh)+xO1;
  y2p:=(x*sTh+y*cTh)+yO1;

  OK:=TRUE;
END; {.. CrosTang2Circ}

{----------------------------------------------------------------------------}
procedure TangPointToParab(xA,yA, a,b,c:double;
          var x1,y1,x2,y2:double; var OK:Boolean);
{Returns the 2 tangency points x1,y1 & x2,y2 on the parabola y=ax*x+b*x+c    }
{with a line passing through external point (xA,yA).                         }

var Delta: double;

BEGIN
  OK:=FALSE;
  x1:=InfD;  y1:=InfD;
  x2:=InfD;  y2:=InfD;
  if (Abs(a) < EpsD) then Exit;
  Delta:=xA*xA + (b*xA-yA+c)/a;
  if (Delta < 0) then Exit;
  x1:=xA - Sqrt(Delta);   y1:=a*x1*x1 + b*x1 + c;
  x2:=xA + Sqrt(Delta);   y2:=a*x1*x1 + b*x1 + c;
  OK:=TRUE;
END; {.. TangPointToParab}

{----------------------------------------------------------------------------}
procedure TangComParabCirc(a0,b0,c0, xO,yO,r:double;
          var x,y, xA,yA:double; var OK:Boolean);

{Returns pts. (x,y) & (xA,yA) of the common tangent to a parabola and a circle}
{(x,y) and (xA,yA) must be passed to the subroutine as initial guesses        }

var J11,  J12, J13,  J21, J22, J23,  J31, J32, J33,
    _J11,_J12,_J13, _J21,_J22,_J23, _J31,_J32,_J33,
    f1,f2,f3,
    x_1,xA_1,yA_1, a,b,c: double;
    nIter: Byte;

{- - - - - - - - - - - - - - - - - - -}
procedure f3x1(x,xA,yA: double);
BEGIN
  if Abs(yA) < EpsD then BEGIN
    OK:=FALSE;  Exit;
  END;
  f1:=xA*xA + yA*yA - r*r;
  f2:=2*a*x + xA/yA + b;
  f3:=a*x*x*yA + x*xA + b*x*yA + c*yA - r*r;
END; {..f3x1}

procedure J3x3(x,xA,yA: double);
BEGIN
  if Abs(yA) < EpsD then BEGIN
    OK:=FALSE;  Exit;
  END;
  J11:=0;                 J12:=2*xA;    J13:=2*yA;
  J21:=2*a;               J22:=1.0/yA;  J23:=-xA/(yA*yA);
  J31:=2*a*x*yA+xA+b*yA;  J32:=x;       J33:=a*x*x+b*x+c;
END; {..J3x3}

procedure InvJ3x3(x,xA,yA: double);
var DD: double;
BEGIN
  DD:=J11*(J22*J33-J23*J32)-J12*(J21*J33-J23*J31)+J13*(J21*J32-J22*J31);
  if Abs(DD) < EpsD then BEGIN
    OK:=FALSE;  Exit;
  END;
  _J11:= (J22*J33-J23*J32)/DD;
  _J21:=-(J21*J33-J23*J31)/DD;
  _J31:= (J21*J32-J22*J31)/DD;
  _J12:=-(J12*J33-J13*J32)/DD;
  _J22:= (J11*J33-J13*J31)/DD;
  _J32:=-(J11*J32-J12*J31)/DD;
  _J13:= (J12*J23-J13*J22)/DD;
  _J23:=-(J11*J23-J13*J21)/DD;
  _J33:= (J11*J22-J12*J21)/DD;
END; {.. InvJ3x3}
{- - - - - - - - - - - - - - - - - - -}

BEGIN {TangComParabCirc ..}
  xA:=xA-xO;
  yA:=yA-yO;
  if Abs(yA) < EpsD then yA:=EpsR;
  x:=x-xO;
  y:=y-yO;
  a:=a0;
  b:=b0+2*a0*xO;
  c:=a0*xO*xO+b0*xO+c0-yO;
  OK:=TRUE;
  nIter:=0;
  repeat {Multivariate Newton-Rapson iteration ..}
    J3x3(x,xA,yA);
    if OK then InvJ3x3(x,xA,yA);
    if OK then f3x1(x,xA,yA);
    if OK then BEGIN
      x_1 :=x;
      xA_1:=xA;
      yA_1:=yA;
      x :=x_1  - (_J11*f1 + _J12*f2 + _J13*f3);
      xA:=xA_1 - (_J21*f1 + _J22*f2 + _J23*f3);
      yA:=yA_1 - (_J31*f1 + _J32*f2 + _J33*f3);
    END;
    Inc(nIter);
    if (nIter > 100) then OK:=FALSE;
  until (Max3(Abs(f1),Abs(f2),Abs(f3)) < 1.0E-12) OR NOT OK;
  y:=a*x*x+b*x+c;

  xA:=xA+xO; {move back to where the circle is centered at (xO,yO) ..}
  yA:=yA+yO;
  x :=x+xO;
  y :=y+yO;
END; {.. TangComParabCirc}

{----------------------------------------------------------------------------}
procedure IntParabCirc(a,b,c, xC,yC, r:double;
          var x,y:double; var OK:Boolean);
{Uses Newton-Rapson to calculate the intersection point closest to (x,y) of a}
{parabola of eq. ax*x+bx+c and a circle centerd at (xC,yC) and radis r.      }

var xPrev,fPrev: double;
    nIter: Byte;

{- - - - - - - - - - - - - - - - - - -}
function f(X: double): double;  {Function to find the zero of}
{f(x) = Sqr(x-xC) + Sqr(a*xx+b*x+c-yC) -r*r                  }
BEGIN
  f:=a*a*X*X*X*X + 2*a*b*X*X*X + (1+b*b+2*a*(c-yC))*X*X
  + 2*(b*(c-yC)-xC)*X + xC*xC+Sqr(c-yC)-r*r;
END; {..f}

function df(x: double): double;  {First derivative of f(x) }
BEGIN
  dF:=4*a*a*X*X*X + 6*a*b*X*X + 2*(1+b*b+2*a*(c-yC))*X
  + 2*(b*(c-yC)-xC);
END; {..df}
{- - - - - - - - - - - - - - - - - - -}

BEGIN
  OK:=TRUE;
  nIter:=0;
  repeat {Newton-Rapson iteration to find the zero of f(x) ..}
    xPrev:=x;
    fPrev:=f(xPrev);
    x:=xPrev-fPrev/df(xPrev);
    Inc(nIter);
    if (nIter > 50) then OK:=FALSE;
  until (Abs(fPrev) < 1.0E-12) OR NOT OK;
  y:=a*x*x+b*x+c;
END; {.. IntParabCirc}

{----------------------------------------------------------------------------}
procedure GetCenterPtPtRad(xA,yA,xB,yB, R: double; var xO,yO: double);
{Returns the center of the circle of radius R through pts. (xA,yA) & (xB,yB) }
{situated to the left of line A-B.                                           }

var xOp,yOp,Delta: double;

BEGIN
  xO:=InfD;
  yO:=InfD;
  Int2Circs12(xA,yA, xB,yB, R,R, xO,yO, xOp,yOp, Delta);
  if (Delta < 0) then Exit;
  if S123(xA,yA, xO,yO, xB,yB) > 0 then BEGIN
    xO:=xOp;
    yO:=yOp;
  END;
END;  {.. GetCenterPtPtRad}

{----------------------------------------------------------------------------}
procedure PtsOn123Arc(x1,y1, x2,y2, x3,y3, dAng: double;
          var x,y: VDo;  var n: Integer);
{Return vectors x & y with n (calculated) points spaced at dAng along the arc}
{through 1, 2 and 3.  The sequence of the n point will be 1 - 2 - 3 as well. }
{NOTE: Interior point 3 can only accidentally occur in the series.           }

var R123, StAng, EndAng, Ang, xC,yC, xj,yj: double;
    j: Integer;

BEGIN
  Circ3Pts(x1,y1, x2,y2, x3,y3, R123, xC,yC);

  if (R123 >= 0) then BEGIN
    StAng :=U3pts2D(xC+R123,yC, xC,yC, x1,y1);
    EndAng:=U3pts2D(xC+R123,yC, xC,yC, x3,y3);
    if (StAng > EndAng) then BEGIN
      EndAng:=EndAng+2*Pi;
    END;
  END
  else BEGIN
    R123:=-R123;
    StAng :=U3pts2D(xC-R123,yC, xC,yC, x3,y3);
    EndAng:=U3pts2D(xC-R123,yC, xC,yC, x3,y3);
    if (StAng < EndAng) then BEGIN
      StAng:=StAng-2*Pi;
    END;
  END;

  n:=Round(Min2(o_max,Max2(2,(EndAng-StAng)/dAng)));
  for j:=1 to n do BEGIN
    Ang:=StAng + (j-1)*(EndAng-StAng)/(n-1);
    x[j]:=xC + R123*cos(Ang);
    y[j]:=yC + R123*sin(Ang);
  END;

END; {.. PtsOn123Arc}


{============================================================================}
BEGIN
  MaxEffEps2:=InfD;
  MaxEffEps3:=InfD;
END. {.. LibGe2D}
