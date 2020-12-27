unit LibMec2D;
{ $R+ }
{ $S- }
{=============================================================================
  Support subroutines for 2D kinematics simulation of mechanical systems
  (c) P.A. Simionescu 2018
=============================================================================}

INTERFACE

uses CRT, DOS, Graph,
     LibMath,
     LibInOut,
     LibDXF,
     LibGraph,
     LibGe2D,  {A_P_B}
     LibPlots;

const Left=-1;
      Right=1;
      SkipFrame = 1;

var LastNrLayer: Word;
    BumpPiston,      {if TRUE the piston impacts cylinder ends             }
    SimpleJoint,     {if TRUE ground joints are +&o and motors are +&o&O   }
    OpaqueJoints,    {if TRUE then sliding blocks will hide their rods etc.}
    MecOut: Boolean; {TRUE if a DXF file output in progress                }
    ScrewDiam,
    ScrewPitch,
    XminWS,XmaxWS,   {X limits of mechanism workspace                      }
    YminWS,YmaxWS,   {Y limits of mechanism workspace                      }
    LminCylPist,     {Cylinder+Piston minimum length in CylPiston          }
    JtSz,            {relative joint size                                  }
    RJtSz: double;   {absolute joint size                                  }


procedure OpenMecGraph(X_min,X_max,Y_min,Y_max:double);

procedure SetTitle(s:string);
procedure SetFooter(s:string);

procedure NewFrame(MS:Word);

procedure CloseMecDXF;

procedure CloseMecGraph(SaveD2DandXYfiles:Boolean);

procedure SetJointSize(JtSize:ShortInt);

procedure Int2Cir(xA,yA, xB,yB, r1,r2:double; LftRgt:Shortint;
          var xC,yC, Delta:double);

procedure Int2CirPVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          r1,dr1,ddr1, r2,dr2,ddr2:double; LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);

procedure VarDist(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB:double;
          var r,dr,ddr, Theta,dTheta,ddTheta:double);

procedure AngPVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB:double;
          var Theta,dTheta,ddTheta:double);

procedure Ang4PVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB
          ,xC,yC,vxC,vyC,axC,ayC,xD,yD,vxD,vyD,axD,ayD:double;
          var Theta,dTheta,ddTheta:double);

procedure Ang3PVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB
          ,xC,yC,vxC,vyC,axC,ayC:double; var Theta,dTheta,ddTheta:double);

procedure ntAccel(vX,vY,aX,aY:double; var anX,anY,atX,atY:double);

procedure Offset(Color:Integer; Style:Char; xA,yA,vxA,vyA,axA,ayA ,xB,yB
 ,vxB,vyB,axB,ayB, x1P,y1P:double; var xP,yP,vxP,vyP,axP,ayP:double);

procedure OffsetV(Color:Integer; Style:Char; xA,yA,vxA,vyA,axA,ayA ,xB,yB
 ,vxB,vyB,axB,ayB, AP,BP:double; APB:shortint; var xP,yP,vxP,vyP,axP,ayP:double);

procedure Spring(Color:Integer; xA,yA, xB,yB,Diam:double;nCoils:Byte);

procedure UpdateLimitsWS(x,y:double);

procedure PutRefSystem(ScaleX,ScaleY:real; LabelX,LabelY:String);

procedure PutAng(Color:Integer; x1,y1,x0,y0,x2,y2, ExtL:double; Dim:string);

procedure PutDist(Color:Integer; xA,yA,xB,yB, ExtL:double; Dim:string);

procedure PutPoint(Color:Integer; PtType:char; x,y:double; PtName:string);
procedure PutGPoint(Color:Integer; PtType:char; x,y:double; PtName:string);
procedure LockPoint(Color:Integer; x0,y0,x,y:double);
procedure PutSliderBlock(Color:Integer; x,y,xPrev,yPrev:double);

procedure LabelJoint(Color:Integer; x0,y0,xJ,yJ:double; JtName:string);
procedure LabelLink(Color:Integer; xA,yA,xB,yB:double; LinkName:string);

procedure PutText(Color:Integer; x,y:double; Txt0:string);
procedure PutGText(Color:Integer; x,y:double; Txt0:string);

procedure PutVector(Color:Integer; LnType:char; xA,yA, x_x,y_y, Scale:double;
          VecName:string);

procedure gShape(FxyName:PathStr; Color:Integer; xA,yA:double);
procedure Shape(FxyName:PathStr; Color:Integer; xA,yA, xB,yB:double);

procedure Base(Color:Integer; xA,yA, xB,yB, w, rA,rB:double);
procedure TaperLink(Color:Integer; xA,yA, xB,yB, rA, rB:double);
procedure Link(Color:Integer; xA,yA, xB,yB, w, rA,rB:double);
procedure LinkC(Color:Integer; xA,yA, xB,yB, R, w, rA, rB:double);
procedure Link3(Color:Integer; xA,yA, xB,yB, xC,yC, r:double);
procedure LinkN(Color, n:Integer;  vX,vY:VDn;  r:double);
procedure LinkL(Color:Integer;  X1,Y1, X2,Y2, X3,Y3, r:double);

procedure Locus(Color:Integer; xP,yP:double; Name:NameStr);
procedure CometLocus(Color:Integer; xP,yP:double; Name:NameStr);

procedure HodographXYn(Color,n:Integer; X,Y:VDo; Name:NameStr; SF:double);

procedure VelocityXYn(Color,n:Integer; X,Y:VDo; Name:NameStr; SF:double);
procedure VelocityXY3(Color:Integer; x0,y0, x1,y1, x2,y2, SF:double);

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

procedure SizeLinMotor(s:double; var A0Q,PC:double);

procedure GroundLine(xP,yP, xQ,yQ:double);

procedure SkLine(xA,yA, xB,yB, rA,rB:double);

procedure LLine(xA,yA, xC,yC, xB,yB, JtSzA,JtSzB:double);

procedure ZLine(xA,yA, xC1,yC1, xC2,yC2, xB,yB, JtSzA,JtSzB:double);

procedure gMotor(xP,yP:double);

procedure Motor(xP,yP, Alpha:double);

procedure gPivotJoint(xP,yP:double);
procedure gPivotJointFlipped(xP,yP:double);

procedure gCylinder(xP,yP, xQ,yQ:double);

procedure Cylinder(xP,yP, xQ,yQ:double);

procedure Piston(xA,yA, xB,yB:double);

procedure SetLminCylPiston(Lmin:double);
procedure CylPiston(xA,yA,xB,yB, Lmin:double);

procedure LCylPiston(xA,yA, xA0,yA0, xP,yP, xQ,yQ, xC,yC:double);

procedure LCylLPiston(xA,yA, xA0,yA0, xP,yP, xQ,yQ, xC0,yC0, xC,yC:double);

procedure Block(xP,yP, Alpha:double);
procedure gBlock(xP,yP, Alpha:double);

procedure SetPowerScrew(Diameter,Pitch:double);
procedure ReSetPowerScrew;
procedure LScrew(xA,yA,xB,yB,xC,yC, Theta0, JtSzA:double);

{============================================================================}

IMPLEMENTATION

var xCentScr, yTopScr, yBotmScr: double;
    MecTitle, MecFooter: string;
    LocalD_X_F: Boolean;

{----------------------------------------------------------------------------}
procedure UpdateLimitsWS(x,y:double);
{Uses x and y to update the left/right and up/down limits of the workspace   }
BEGIN
  if (x < XminWS) then XminWS:=x;
  if (x > XmaxWS) then XmaxWS:=x;
  if (y < YminWS) then YminWS:=y;
  if (y > YmaxWS) then YmaxWS:=y;
END; {..UpdateLimitsWS}

{----------------------------------------------------------------------------}
procedure Int2Cir(xA,yA, xB,yB, r1,r2:double; LftRgt:Shortint; var xC,yC, Delta: double);
{Calculates the intersection point (x,y) between two circles that  matches   }
{the LftRgt orientation. Uses Int2Circs() from unit LibMath                  }

var xC_,yC_, Delta_: double;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure ForceLimitsWS(var x,y, Dxy:double);
{Forces x and y to remain within the existing limits of the workspace}
var Dx,Dy:double;

BEGIN  {ForceLimitsWS..}
  Dx:=XmaxWS-XminWS;
  Dy:=YmaxWS-YminWS;
  if (Min2(Dx,Dy)/Max2(Dx,Dy) < 0.1) then BEGIN  {10 = WS max. aspect ratio}
    if (Dx < Dy) then BEGIN
      UpdateLimitsWS(XminWS-Dxy,YminWS);
      UpdateLimitsWS(XmaxWS+Dxy,YmaxWS);
    END;
    if (Dx > Dy) then BEGIN
      UpdateLimitsWS(XminWS,YminWS-Dxy);
      UpdateLimitsWS(XmaxWS,YminWS+Dxy);
    END;
  END;
  if (x < XminWS) AND (Abs(XminWS) <> InfD) then x:=XminWS;
  if (x > XmaxWS) AND (Abs(XmaxWS) <> InfD) then x:=XmaxWS;
  if (y < YminWS) AND (Abs(YminWS) <> InfD) then y:=YminWS;
  if (y > YmaxWS) AND (Abs(YmaxWS) <> InfD) then y:=YmaxWS;
END;  {..ForceLimitsWS}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - -}

BEGIN {Int2Cir..}

  Int2Circs12(xA,yA, xB,yB, r1,r2, xC,yC, xC_,yC_, Delta_);

  if (Delta < InfD) then  Delta:=Delta_;  {..there is interest in Delta}

  if (Sgn(S123(xA,yA, xC,yC, xB,yB)) <> sgn(LftRgt)) then BEGIN
   xC:=xC_;  yC:=yC_;
  END;

  if (Delta_ < -0.01) then BEGIN  {-0.01 might need adjustment !!!!}
    Delta_:=Max2(r1,r2);
    ForceLimitsWS(xC,yC, Delta_);
  END;

END; {..Int2Cir}

{----------------------------------------------------------------------------}
procedure Int2CirPVA(xA,yA, vxA,vyA, axA,ayA,  xB,yB, vxB,vyB, axB,ayB,
          r1,dr1,ddr1, r2,dr2,ddr2:double;  LftRgt:shortint;
          var xC,yC, vxC,vyC, axC,ayC, Delta:double);
{Returns the coordinates of the intersection point C between 2 circles that  }
{matches the sign of LftRgt, and its scalar velocities and accelerations.    }

var a1,b1,c1, a2,b2,c2, Delta_: double;
    OK: Boolean;

BEGIN  {Int2CirPVA..}
  Delta_:=0.0;

  Int2Cir(xA,yA, xB,yB, r1,r2, LftRgt, xC,yC, Delta_);

  if (Delta <> InfD) then Delta:=Delta_;  {there is interest in Delta}

  if (Delta_ < 0) then Exit; {..the loop does not close}

  if (vxA > InfR) OR (vyA > InfR) OR (vxB > InfR) OR (vyB > InfR) OR
  (dr1 > InfR) OR (dr2 > InfR) then BEGIN
    vxC:=InfD;
    vyC:=InfD;
    axC:=InfD;
    ayC:=InfD;
    Exit; {..no interest in vxC,vyC,axC & ayC}
  END;

  a1:=xC-xA;  b1:=yC-yA;  c1:=r1*dr1+a1*vxA+b1*vyA;
  a2:=xC-xB;  b2:=yC-yB;  c2:=r2*dr2+a2*vxB+b2*vyB;
  LinEq2(a1,b1,c1, a2,b2,c2, vxC,vyC, OK);
  if NOT OK then Exit;

  if (axA > InfR) OR (ayA > InfR) OR (axB > InfR) OR (ayB > InfR)
  OR (ddr1 > InfR) OR (ddr2 > InfR) then BEGIN
    axC:=InfD;
    ayC:=InfD;
    Exit; {..no interest in axC & ayC}
  END;
  c1:=dr1*dr1+r1*ddr1-Sqr(vxC-vxA)-Sqr(vyC-vyA)+a1*axA+b1*ayA;
  c2:=dr2*dr2+r2*ddr2-Sqr(vxC-vxB)-Sqr(vyC-vyB)+a2*axB+b2*ayB;

  LinEq2(a1,b1,c1, a2,b2,c2, axC, ayC, OK);

END;  {..Int2CirPVA}

{----------------------------------------------------------------------------}
procedure VarDist(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB:double;
          var r,dr,ddr, Theta,dTheta,ddTheta:double);

{Calculates distance r between points A-B, its first and second derivatives  }
{with respect to time dr and ddr, angle Theta between A-B and the OX axis,   }
{and the time derivatives of this angle dTheta and ddTheta. Angle Theta must }
{be intialized before calling VarDist to work with NghbrAng.                 }

var  a1,b1,c1, a2,b2,c2:double;   OK:Boolean;

BEGIN {VarDist..}

  r:=Dist2Pts2D(xA,yA, xB,yB);

  Theta:=NghbrAng(Theta, Atan2(yB-yA,xB-xA));

  if (vxA > InfR) OR (vyA > InfR) OR (vxB > InfR) OR (vyB > InfR) then Exit;
  a1:=cos(Theta);  b1:=-(yB-yA);  c1:=vxB-vxA;
  a2:=sin(Theta);  b2:=xB-xA;     c2:=vyB-vyA;
  dr:=InfD;
  dTheta:=InfD;
  LinEq2(a1,b1,c1, a2,b2,c2, dr, dTheta, OK);
  if NOT OK then Exit;

  if (axA > InfR) OR (ayA > InfR) OR (axB > InfR) OR (ayB > InfR) then Exit;
  c1:=axB-axA + dTheta*dr*a2 + dTheta*(vyB-vyA);
  c2:=ayB-ayA - dTheta*dr*a1 - dTheta*(vxB-vxA);
  ddr:=InfD;
  ddTheta:=InfD;
  LinEq2(a1,b1,c1, a2,b2,c2, ddr, ddTheta, OK);

END;  {..VarDist}

{----------------------------------------------------------------------------}
procedure AngPVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB:double;
          var Theta,dTheta,ddTheta:double);
{Finds angle Theta formed by vector A-B with the horizontal (fixed) axis OX  }
{and its 1st and 2nd time derivative dTheta and ddTheta. Theta must initialy }
{carry the value of the previous Theta and is needed for angle continuity.   }
{When first called, Theta can be assigned the value zero.                    }

BEGIN {AngPVA..}

  dTheta :=InfD;
  ddTheta:=InfD;

  if (xA = xB) AND (yA = yB) then Exit;

  Theta:=NghbrAng(Theta, Atan2(yB-yA,xB-xA));

  if (vxA > InfR) OR (vyA > InfR) OR (vxB > InfR) OR (vyB > InfR) then Exit;
  if (Abs(xB-xA) > Abs(yB-yA)) then
    dTheta:= (vyB-vyA)/(xB-xA)
  else
    dTheta:=-(vxB-vxA)/(yB-yA);

  if (axA > InfR) OR (ayA > InfR) OR (axB > InfR) OR (ayB > InfR) then Exit;
  if (Abs(xB-xA) > Abs(yB-yA)) then
    ddTheta:= (ayB-ayA+Sqr(dTheta)*(yB-yA))/(xB-xA)
  else
    ddTheta:=-(axB-axA+Sqr(dTheta)*(xB-xA))/(yB-yA);

END; {..AngPVA}

{----------------------------------------------------------------------------}
procedure Ang4PVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          xC,yC,vxC,vyC,axC,ayC, xD,yD,vxD,vyD,axD,ayD:double;
          var Theta,dTheta,ddTheta:double);
{Finds angle Theta between vectors A-B and C-D, and its 1st and 2nd time     }
{derivatives dTheta and ddTheta.  Theta must initialy carry the value of the }
{previous Theta and is needed for angle continuity. When first called, Theta }
{can be assigned the value zero.                                             }

var Theta1,dTh1,ddTh1, Theta2,dTh2,ddTh2:double;

BEGIN {Ang4PVA..}
  dTheta :=InfD;
  ddTheta:=InfD;
  if (xA = xB) AND (yA = yB) OR (xC = xD) AND (yC = yD) then BEGIN
    Theta:=0.0;  Exit;
  END;

  Theta:=NghbrAng(Theta,U2dirs2D(xB-xA,yB-yA, xD-xC,yD-yC));

  Theta1:=0.0;
  Theta2:=0.0;
  AngPVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB, Theta1,dTh1,ddTh1);
  AngPVA(xC,yC,vxC,vyC,axC,ayC, xD,yD,vxD,vyD,axD,ayD, Theta2,dTh2,ddTh2);
  Theta:=NghbrAng(Theta,Theta2-Theta1);

  if (vxA > InfR) OR (vyA > InfR) OR (vxB > InfR) OR (vyB > InfR) then Exit;
  dTheta:=dTh2-dTh1;

  if (axA > InfR) OR (ayA > InfR) OR (axB > InfR) OR (ayB > InfR) then Exit;
  ddTheta:=ddTh2-ddTh1;

END; {..Ang4PVA}

{----------------------------------------------------------------------------}
procedure Ang3PVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          xC,yC,vxC,vyC,axC,ayC:double; var Theta,dTheta,ddTheta:double);
{Finds angle Theta between vectors B-A and B-C, and its 1st and 2nd time     }
{derivatives dTheta and ddTheta.  Theta must initialy carry the value of the }
{previous Theta and is needed for angle continuity. When first called, Theta }
{can be assigned the value zero.                                             }

BEGIN {Ang3PVA..}

  Ang4PVA(xB,yB,vxB,vyB,axB,ayB, xA,yA,vxA,vyA,axA,ayA
  ,xB,yB,vxB,vyB,axB,ayB, xC,yC,vxC,vyC,axC,ayC, Theta,dTheta,ddTheta);

END; {..Ang3PVA}

{----------------------------------------------------------------------------}
procedure ntAccel(vX,vY,aX,aY:double; var anX,anY,atX,atY:double);
{given the x and y components of the velocity and acceleration of a point it }
{calculates the x and y components of its normal and tangential accelerations}

var vv:double;  {magnitude of the velocity vector}

BEGIN
  if (vX > InfR) OR (vY > InfR) OR (aX > InfR) OR (aY > InfR) then Exit;

  _:=InfD;

  atX:=InfD;  atY:=InfD;
  anX:=InfD;  anY:=InfD;
  vv:=vX*vX + vY*vY;

  if (vv < EpsR) then Exit;

  atX:=(aX*vX+aY*vY)*vX/vv;
  atY:=(aX*vX+aY*vY)*vY/vv;
  anX:=aX-atX;
  anY:=aY-atY;
END; {..ntAccel}

{----------------------------------------------------------------------------}
procedure Offset0(xA,yA, vxA,vyA, axA,ayA, xB,yB, vxB,vyB, axB,ayB,
          x1P,y1P:double; var xP,yP, vxP,vyP, axP,ayP:double);
{ Calculate the position, velocity and acceleration of a point P attached to }
{ a member A-B.  The subroutine is used by OffsetV.                          }

var Theta,dTheta,ddTheta, cTheta,sTheta:double;

BEGIN {Offset0 ..}
  _:=InfD;

  if (xA = xB) AND (yA = yB) then BEGIN
    xP:=xA;  yP:=yA;  Exit;
  END;

  Theta:=0.0;
  AngPVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB, Theta,dTheta,ddTheta);

  cTheta:=cos(Theta);
  sTheta:=sin(Theta);

  xP:=xA + x1P*cTheta - y1P*sTheta;
  yP:=yA + x1P*sTheta + y1P*cTheta;

  if (dTheta <> InfD) then BEGIN
    vxP:=vxA-dTheta*(yP-yA);
    vyP:=vyA+dTheta*(xP-xA);
  END;

  if (ddTheta <> InfD) then BEGIN
    axP:=axA-ddTheta*(yP-yA)-Sqr(dTheta)*(xP-xA);
    ayP:=ayA+ddTheta*(xP-xA)-Sqr(dTheta)*(yP-yA);
  END;
END; {.. Offset0}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure ArcWeld(Rarc, x0,y0, x1,y1, x2,y2, CW_CCW: double);
var x,y: double;
BEGIN
  if (Abs(CW_CCW) < 1.0E-6) then CW_CCW:=+1; {oscillates if 0-1-2 are colinear}
  A_P_B(x0,y0,x1,y1, Rarc, x1,y1);  {.. arc end-point 1}
  A_P_B(x0,y0,x2,y2, Rarc, x2,y2);  {.. arc end-point 2}
  x:=0.5*(x1+x2);  y:=0.5*(y1+y2);  {a point on the bisector of the angle}
  A_P_B(x0,y0,x,y, Rarc, x,y);  {the middle point of the arc}
  if (x0 = x) AND (y0 = y) then BEGIN {rotate (x1,y1) about (x0,y0) by +/-90 deg..}
    x:=x0-CW_CCW*(y1-y0);
    y:=y0+CW_CCW*(x1-x0);
  END
  else if S123(x1,y1,x,y,x2,y2)*CW_CCW < 0 then A_P_B(x0,y0,x,y,-Rarc,x,y);
  PDarc3pts('',X_p(x1),Y_p(y1), X_p(x),Y_p(y), X_p(x2),Y_p(y2));
END; {..ArcWeld}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure DrawOffset(Color:Integer; Style:Char; xA,yA,xB,yB,xP,yP, x1P:double);

var P3: Poly_8;

BEGIN
  SetColorBGI_DXF(Abs(Color));
  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

  if (Style = 'V') OR (Style = 'v') then BEGIN {open poliline A-P-B ..}
    P3[1].x:=X_p(xA);    P3[1].y:=Y_p(yA);
    P3[2].x:=X_p(xP);    P3[2].y:=Y_p(yP);
    P3[3].x:=X_p(xB);    P3[3].y:=Y_p(yB);
    PDdrawPoly('',3, P3, FALSE);
    Exit;
  END;
  if (Style = 'L') then BEGIN {open poliline A-B-P ..}
    P3[1].x:=X_p(xA);    P3[1].y:=Y_p(yA);
    P3[2].x:=X_p(xB);    P3[2].y:=Y_p(yB);
    P3[3].x:=X_p(xP);    P3[3].y:=Y_p(yP);
    PDdrawPoly('',3, P3, FALSE);
    Exit;
  END;
  if (Style = 'A') OR (Style = 'D') then BEGIN {triangle ABP..}
    P3[1].x:=X_p(xA);    P3[1].y:=Y_p(yA);
    P3[2].x:=X_p(xP);    P3[2].y:=Y_p(yP);
    P3[3].x:=X_p(xB);    P3[3].y:=Y_p(yB);
    if OpaqueJoints AND (Color > 0) then BEGIN
      SetFillStyle(SolidFill,Color);  {!!!}
      if OpaqueJoints then IncDXFelev;
      DmyFaces:=TRUE;
      PDfillPoly('',3, P3);
      PDdrawPoly('',3, P3, TRUE);
      DmyFaces:=FALSE;
      if OpaqueJoints then DecDXFelev;
    END;
    Exit;
  END;

  if (Style = 'T') then BEGIN { _|_ ..}
    PD_line('',X_p(xA),Y_p(yA), X_p(xB),Y_p(yB));
    PD_line('',X_p(xB),Y_p(yB), X_p(xP),Y_p(yP));
    Exit;
  END;

  if (Style = 'I') then BEGIN { _|_ without _ & _  ..}
    A_P_B(xA,yA,xB,yB, x1P, xB,yB);
    PD_line('',X_p(xB),Y_p(yB), X_p(xP),Y_p(yP));
    Exit;
  END;

{NOTE: Increase 1.8 in 1.8*RJtSz for a bigger "weld"!}
  if (Style = '/') then BEGIN {line A-P ..}
    ArcWeld(1.8*RJtSz, xA,yA,xB,yB,xP,yP, S123(xA,yA,xB,yB,xP,yP));
    if OpaqueJoints then A_P_B(xA,yA,xP,yP, RJtSz, xA,yA);
    PD_line('',X_p(xA),Y_p(yA), X_p(xP),Y_p(yP));
    Exit;
  END;

  if (Style = '\') then BEGIN {line B-P ..}
    ArcWeld(1.8*RJtSz, xB,yB,xA,yA,xP,yP, S123(xB,yB,xA,yA,xP,yP));
    if OpaqueJoints then A_P_B(xB,yB,xP,yP, RJtSz, xB,yB);
    PD_line('',X_p(xB),Y_p(yB), X_p(xP),Y_p(yP));
    Exit;
  END;

END;  {.. DrawOffset}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure Offset(Color:Integer; Style:Char; xA,yA,vxA,vyA,axA,ayA,
xB,yB,vxB,vyB,axB,ayB, x1P,y1P:double; var xP,yP,vxP,vyP,axP,ayP:double);
{ Find the position, velocity & acceleration of point P attached to member AB}
{ of local coordinates (x1P,y1P) relative to a reference frame with OX1 = AB.}
{ If Style = 'V' OR 'A' draw triangle ABP;                                   }
{ If Style = 'T' draw line AB and line PB' perpendicular to AB;              }
{ If Style = 'I' draw line AB;                                               }
{ If Style = '/' draw line AP;                                               }
{ If Style = '\' draw line BP;                                               }
{ If Color > 0 AND Style = A), triangle APB is filled with color;            }
{ If Color = 0 OR Style <> (T,I,/,\,V,A) nothing is drawn.                    }

var  xPP,yPP,vxPP,vyPP,axPP,ayPP: double;

BEGIN {Offset ..}
  Offset0(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB
  ,x1P,y1P, xPP,yPP, vxPP,vyPP, axPP,ayPP);

  if (Color <> 0) AND (MaxX*MaxY > 0) then BEGIN
    DrawOffset(Color,Style,xA,yA, xB,yB, xPP,yPP, x1P);
    UpdateLimitsWS(xPP,yPP);
  END;

  xP:=xPP;
  yP:=yPP;
  _:=InfD;

  if (vxA > InfR) OR (vyA > InfR) OR (vxB > InfR) OR (vyB > InfR) then Exit;
  vxP:=vxPP;
  vyP:=vyPP;

  if (axA > InfR) OR (ayA > InfR) OR (axB > InfR) OR (ayB > InfR) then Exit;
  axP:=axPP;
  ayP:=ayPP;

END; {.. Offset}

{----------------------------------------------------------------------------}
procedure OffsetV(Color:Integer; Style:Char; xA,yA,vxA,vyA,axA,ayA ,xB,yB
 ,vxB,vyB,axB,ayB, AP,BP:double; APB:shortint; var xP,yP,vxP,vyP,axP,ayP:double);
{ Find the position, velocity & acceleration of point P attached to member AB}
{ located at distance AP and BP, and triangle A-B-P is oriented as APB.      }
{ If Style = 'T' draw line AB and line PB' perpendicular to AB;              }
{ If Style = 'I' draw line AB;                                               }
{ If Style = '/' draw line AP;                                               }
{ If Style = '\' draw line BP;                                               }
{ If Style = 'V' OR 'A' draw triangle ABP;                                   }
{ If Color > 0 AND Style = A), triangle APB is filled with color;            }
{ If Color = 0 OR Style <> (T,I,/,\V,A) nothing is drawn.                    }

var xPP,yPP,vxPP,vyPP,axPP,ayPP, x1P,y1P,Delta: double;  OK:Boolean;

BEGIN {OffsetV ..}
  _:=InfD;

  Delta:=0.0;
  Int2CirPVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  AP,0,0, BP,0,0, APB, xPP,yPP,vxPP,vyPP,axPP,ayPP,Delta);

  if (Color <> 0) AND (MaxX*MaxY <> 0) then BEGIN
    if (Style = 'T') OR (Style = 'I') AND (Delta > 0) then
      x1P:=AP*cos(U3pts2D(xB,yB,xA,yA,xPP,yPP))
    else
      x1P:=0.0;
    DrawOffset(Color,Style,xA,yA, xB,yB, xPP,yPP,x1P);
    UpdateLimitsWS(xPP,yPP);
  END;

  xP:=xPP;
  yP:=yPP;

  if (vxA > InfR) OR (vyA > InfR) OR (vxB > InfR) OR (vyB > InfR) then Exit;
  vxP:=vxPP;
  vyP:=vyPP;

  if (axA > InfR) OR (ayA > InfR) OR (axB > InfR) OR (ayB > InfR) then Exit;
  axP:=axPP;
  ayP:=ayPP;

END; {.. OffsetV}

{----------------------------------------------------------------------------}
procedure Spring(Color:Integer; xA,yA, xB,yB, Diam:double; nCoils:Byte);
{Draw a spring from A to B of diameter Diam and number of coils nCoils   }

var  AB,cA,sA, x,y, xC,yC, xA0,yA0, xB0,yB0,
     Theta,pitch:double;
     j:Word;

BEGIN
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xB,yB);

  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  SetColorBGI_DXF(Abs(Color));
  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

  AB:=Sqrt(Sqr(xB-xA)+Sqr(yB-yA));
  if (AB < EpsD) then Exit;

  sA:=-(xB-xA)/AB;    cA:=(yB-yA)/AB;

  A_P_B(xA,yA,xB,yB, Diam, xA0,yA0);
  A_P_B(xB,yB,xA,yA, Diam, xB0,yB0);

  AB:=AB-2*Diam;

  if OpaqueJoints then BEGIN
    A_P_B(xA,yA,xB,yB, p2R121(JtSz), xA,yA);
    A_P_B(xB,yB,xA,yA, p2R121(JtSz), xB,yB);
  END;

  pitch:=AB/nCoils;

  ExpectDXFplines;
  MoveTo(X_pI(xA),Y_pI(yA));
  AddVertexPline('',xA,yA);
  LineTo(X_pI(xA0),Y_pI(yA0));
  AddVertexPline('',xA0,yA0);
  for j:=0 to nCoils*36 do BEGIN
    Theta:=2.0*Pi/36*j;
    xC:=0.5*Diam*sin(Theta);
    yC:=pitch*Theta/(2.0*Pi);
    x:=xA0 + xC*cA - yC*sA;
    y:=yA0 + xC*sA + yC*cA;
    AddVertexPline('',x,y);
    LineTo(X_pI(x),Y_pI(y));
  END;
  AddVertexPline('',xB,yB);
  LineTo(X_pI(xB),Y_pI(yB));
  DXFplineEnd('');

END; {..Spring}


{----------------------------------------------------------------------------}
procedure PutPoint(Color:Integer; PtType:char; x,y:double; PtName:string);

var xOfs:Integer;

BEGIN
  if (x > InfR) OR (y > InfR) then Exit;

  UpdateLimitsWS(x,y);

  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  SetColorBGI_DXF(Abs(Color));

  if (Color > 0) then BEGIN
    if OpaqueJoints then IncDXFelev;
    if (PtType = '.') then Point(X_p(x),Y_p(y),0,0);
    if (PtType = 'o') then PDcircle('',X_p(x),Y_p(y),0.50*JtSz);
    if (PtType = '0') then PDcircle('',X_p(x),Y_p(y),0.75*JtSz);
    if (PtType = 'O') then PDcircle('',X_p(x),Y_p(y),     JtSz);
    if (PtType = '+') then Point(X_p(x),Y_p(y),JtSz-1,10);
    if (PtType = 'x') then Point(X_p(x),Y_p(y),(JtSz-1)/2+1,9);
    if (PtType = 'X') then Point(X_p(x),Y_p(y),JtSz-1,9);
    if (PtType = '^') then gPivotJoint(X_p(x),Y_p(y));
    if (PtType = 'v') then gPivotJointFlipped(X_p(x),Y_p(y));
    if (PtType = '@') then gMotor(X_p(x),Y_p(y));
    if OpaqueJoints then DecDXFelev;
  END;

  xOfs:=0;
  while (PtName[Length(PtName)] = ' ') AND (Length(PtName) > 1) do BEGIN
    Dec(xOfs);
    Delete(PtName,Length(PtName),1);
  END;
  while (PtName[1] = ' ') AND (Length(PtName) > 1) do BEGIN
    Inc(xOfs);
    Delete(PtName,1,1);
  END;

  if (PtName[Length(PtName)] = '(') then PtName:=PtName+MySt(x,6)+','+MySt(y,6)+')';

  if (xOfs >= 0) then
    SetTextJustify(LeftText,CenterText)
  else
    SetTextJustify(RightText,CenterText);

  if (PtName <> '') then PD_text('',X_p(x),xOfs, Y_p(y),0, PtName);

END; {..PutPoint}


{----------------------------------------------------------------------------}
procedure PutGPoint(Color:Integer; PtType:char; x,y:double; PtName:string);

var LayerName:Str31;
    PutGPointD_X_F:Boolean;

BEGIN  {PutGPoint..}
  UpdateLimitsWS(x,y);

  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  PutGPointD_X_F:=D_X_F;

  if (PtName[1] = '+') then
    Delete(PtName,1,1)
  else
    if (LastNrLayer > 1) then D_X_F:=FALSE; {..1st M3D frame already generated}

  LayerName:=GetDXFlayer;
  SetDXFlayer('Ground');

  PutPoint(Abs(Color), PtType, x,y, PtName);

  SetDXFlayer(LayerName);
  D_X_F:=PutGPointD_X_F;

END; {..PutGPoint}

{----------------------------------------------------------------------------}
procedure LockPoint(Color:Integer; x0,y0,x,y:double);

var L,cA,sA,x1,y1,x2,y2: double;

BEGIN
  UpdateLimitsWS(x,y);
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit;
  SetColorBGI_DXF(Abs(Color));

  L:=Dist2Pts2D(x0,y0,x,y);
  cA:= (x-x0)/L;
  sA:=-(y-y0)/L;

  {Define (x1,y1) (x2,y2) about origine, then translate to (x,y) ..}
  RT2DcAsA(-JtSz,JtSz/3+1, cA,sA, X_p(x),Y_p(y), x1,y1);
  RT2DcAsA( JtSz,JtSz/3+1, cA,sA, X_p(x),Y_p(y), x2,y2);
  PD_line('',x1,y1, x2,y2);

  {Define (x1,y1) (x2,y2) about origine, then translate to (x,y) ..}
  RT2DcAsA(-JtSz,-JtSz/3-1, cA,sA, X_p(x),Y_p(y), x1,y1);
  RT2DcAsA( JtSz,-JtSz/3-1, cA,sA, X_p(x),Y_p(y), x2,y2);
  PD_line('',x1,y1, x2,y2);

END; {.. LockPoint}


{----------------------------------------------------------------------------}
procedure PutSliderBlock(Color:Integer; x,y,xPrev,yPrev:double);
var Alpha:double;

BEGIN
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit;

  SetColorBGI_DXF(Abs(Color));
  Alpha:=Atan2(y-yPrev,x-xPrev);

  if (Alpha < InfD) then Block(X_p(x),Y_p(y), Alpha);

END; {.. PutSliderBlock}


{----------------------------------------------------------------------------}
procedure LabelJoint(Color:Integer; x0,y0,xJ,yJ:double; JtName:string);
{Inserts JtName offset from (xJ,yJ) in the direction away from (x0,y0)   }

var  Dist0_J:double;   Offs:ShortInt;

BEGIN
  UpdateLimitsWS(xJ,yJ);

  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {zero color OR not in graphic mode}

  if TrimBlanks(JtName) = '' then Exit; {nothing to label..}

  SetColorBGI_DXF(Abs(Color));
  Dist0_J:=Dist2Pts2D(x0,y0, xJ,yJ);

  if (Dist0_J < EpsR) then
    SetTextJustify(CenterText,CenterText)
  else BEGIN
    SetTextJustify(Round(1-(xJ-x0)/Dist0_J),Round(1-(yJ-y0)/Dist0_J));
    Blanks2Offs(JtName, Offs);
    A_P_B(xJ,yJ,x0,y0, -0.5*RJtSz*Offs, xJ,yJ);
  END;

  PD_text('',X_p(xJ),0, Y_p(yJ),0, JtName);

END; {..LabelJoint}

{----------------------------------------------------------------------------}
procedure LabelLink(Color:Integer; xA,yA,xB,yB:double; LinkName:string);
{Inserts LinkName at coordinate (xA/2+xB/2,yA/2+yB/2)                        }

var  DistA_B:double;   Offs:ShortInt;

BEGIN
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xB,yB);

  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {zero color OR not in graphic mode}

  SetColorBGI_DXF(Abs(Color));

  DistA_B:=Dist2Pts2D(xA,yA, xB,yB);
  if TrimBlanks(LinkName) = '' then LinkName:=MySt(DistA_B,7);

  if (DistA_B < EpsR) then
    SetTextJustify(CenterText,CenterText)
  else BEGIN
    SetTextJustify(Round(1+(yB-yA)/DistA_B),Round(1-(xB-xA)/DistA_B));
    Blanks2Offs(LinkName, Offs);
  END;

  PD_text('',X_p(0.5*(xA+xB)),0, Y_p(0.5*(yA+yB)),0, LinkName);

END; {.. LabelLink}

{----------------------------------------------------------------------------}
procedure PutText(Color:Integer; x,y:double; Txt0:string);
{Writes Txt0 at point x,y. If 'n\' is present, will be used as line breaker. }

var Txt:string;  OffsY:Byte;

BEGIN {PutText..}
  if (TrimBlanks(Txt0) = '') then Exit; {nothng to write}

  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  SetColorBGI_DXF(Abs(Color));
  SetTextJustify(LeftText, CenterText);
  if (x = _) OR (y = _) then BEGIN
    if (y = _) then BEGIN
      y:=p_Y(0);
      SetTextJustify(CenterText, TopText);
    END;
    if (x = _) then BEGIN
      x:=p_X(0);
      SetTextJustify(LeftText, TopText);
    END;
  END
  else  UpdateLimitsWS(x,y);
  OffsY:=0;
  if (Pos('n\',Txt0) = 1) then Insert(' ',Txt0,1);

  while (Pos('n\',Txt0) > 1) do BEGIN
    Txt:=copy(Txt0,1,Pos('n\',Txt0)-1);
    Delete(Txt0,1,Pos('n\',Txt0)+1);
    PDtext('',X_p(x),0, Y_p(y),2*OffsY, Txt);
    Inc(OffsY);
  END;

  PDtext('',X_p(x),0, Y_p(y),2*OffsY, Txt0);

END; {..PutText}

{----------------------------------------------------------------------------}
procedure PutGText(Color:Integer; x,y:double; Txt0:string);

var LayerName:Str31;

BEGIN {PutGText..}

  if (TrimBlanks(Txt0) = '') then Exit; {nothng to write}

  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  LocalD_X_F:=D_X_F;
  if (LastNrLayer > 1) then D_X_F:=FALSE; {1st M3D frame has already been generated}

  LayerName:=GetDXFlayer;
  SetDXFlayer('Ground');

  PutText(Abs(Color), x,y, Txt0);

  SetDXFlayer(LayerName);  {..restore layer name}

  D_X_F:=LocalD_X_F;

END; {..PutGText}

{----------------------------------------------------------------------------}
procedure PutVector(Color:Integer; LnType:char; xA,yA, x_x,y_y, Scale:double;
          VecName:string);
{Draw a vector at (xA,yA) of (x_x*Scale) and (y_y*Scale) components. Also    }
{puts VecName extended from the vector tip in Color, or in MaxColor if Color < 0}
{Line type LnType is ':'dotted, '|'dashed, '='solid-thick else is solid-thin.}
{If Scale < 0 then draws log10(x_x)*Abs(Scale) and log10(y_y)*Abs(Scale) !   }

var  vX,vY: array [1..8] of double;
     x,y, xPrev,yPrev, xB,yB, AB, ArwHdSz, Ang:double;
     i:ShortInt;

BEGIN  {PutVector..}
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  if (Scale = 0) OR (Abs(x_x) <= 1.0E-15) AND (Abs(y_y) <= 1.0E-15) then Exit;

  if (Scale < 0) then BEGIN {logarithmize vector length..}
    AB:=Sqrt(x_x*x_x + y_y*y_y);
    Scale:=-Scale*Log10(AB+1)/(AB+EpsR);
  END;
  xB:=xA+x_x*Scale;
  yB:=yA+y_y*Scale;  {..(xB,yB) is the vector hed}

  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xB,yB);

  SetColorBGI_DXF(Abs(Color));
  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
  AB:=Dist2Pts2D(xA,yA,xB,yB);

  if (AB <  1.0E-6) then Exit;

  ArwHdSz:=Min2(0.5*R_p121(AB),3*JtSz);  {..calculate arrow-head length}

  if (LnType = '=') AND (ArwHdSz > 0.1*JtSz) then BEGIN  {polygonal arrow..}
    ArwHdSz:=p2R121(ArwHdSz);
    vX[1]:=0.0;                    vY[1]:=0.0;
    vX[2]:=ArwHdSz*cos(12.5*RAD);  vY[2]:=ArwHdSz*sin(12.5*RAD);
    vX[3]:=vX[2];                  vY[3]:=0.5*vY[2];
    vX[4]:=AB;                     vY[4]:=vY[3];
    vX[5]:=vX[4];                  vY[5]:=-vY[4];
    vX[6]:=vX[3];                  vY[6]:=-vY[3];
    vX[7]:=vX[2];                  vY[7]:=-vY[2];
    vX[8]:=0.0;                    vY[8]:=0.0;
    Ang:=Atan2(yA-yB,xA-xB);
    ExpectDXFplines;
    x:=InfD;   y:=InfD;
    for i:=1 to 8 do BEGIN
      xPrev:=x;   yPrev:=y;
      RT2D(vX[i],vY[i],Ang,xB,yB, x,y);  {..translate and rotate vertex (x,y)}
      AddVertexPline('',x,y);  {..write vertex to polyline}
      if (i > 1) then
        Line(RoundInt(X_p(xPrev)),RoundInt(Y_p(yPrev)),RoundInt(X_p(x)),RoundInt(Y_p(y)));
    END;
    DXFplineEnd('');
  END
  else BEGIN  {line-type arrow }
    ArrowH(X_p(xB),Y_p(yB),X_p(xA),Y_p(yA), ArwHdSz, 12.5); {..arrow head @ B}
    if (LnType = ':') then SetLineStyle(DottedLn, 0, NormWidth);
    if (LnType = '|') then SetLineStyle(DashedLn, 0, NormWidth);
    SyncDXFLineStyleTkns;
    PD_line('',X_p(xB),Y_p(yB), X_p(xA),Y_p(yA)); {..draw arrow stem}
  END;

  if (Color > 0) AND ((AB > RJtSz) OR (TrimBlanks(VecName) <> '')) then BEGIN
    SetColorBGI_DXF(MaxColor);
    SetTextJustify(Round(1-(xB-xA)/AB),Round(1-(yB-yA)/AB));
    A_P_B(xB,yB,xA,yA, -0.5*RJtSz, xB,yB);    {..move out 0.5 of joint size}
    PD_text('',X_p(xB),0, Y_p(yB),0, VecName);
{   Label vector tail                                        }
{   SetTextJustify(Round(1-(xA-xB)/AB),Round(1-(yA-yB)/AB)); }
{   A_P_B(xA,yA,xB,yB, -0.5*RJtSz, xA,yA);                   }
{   PD_text('',X_p(xA),0, Y_p(yA),0, VecName);               }
  END;

END; {..PutVector}

{----------------------------------------------------------------------------}
procedure PutRefSystem(ScaleX, ScaleY:real; LabelX,LabelY:String);
{Draw World reference frame i.e. origin at (0,0), OX pos. right, OY pos. up}

var LayerName:Str31;
    Offs:ShortInt;

BEGIN
  if (MaxX*MaxY = 0) then Exit;  {..not in graphic mode}

  LocalD_X_F:=D_X_F;
  if (LastNrLayer > 1) then D_X_F:=FALSE; {..1st M3D frame has been generated}

  LayerName:=GetDXFlayer;
  SetDXFlayer('Ground');

  SetColorBGI_DXF(MaxColor);
  SetLineStyle(SolidLn, 0, NormWidth);   SyncDXFLineStyleTkns;

  ScaleX:=ScaleX*10*JtSz;
  ScaleY:=ScaleY*10*JtSz;


  PD_line('',X_p(0)+ScaleX, Y_p(0), X_p(0),Y_p(0));
  PD_line('',X_p(0), Y_p(0)-ScaleY, X_p(0),Y_p(0));

  ArrowH(X_p(0)+ScaleX, Y_p(0), X_p(0),Y_p(0), 2*JtSz, 12.5);
  ArrowH(X_p(0), Y_p(0)-ScaleY, X_p(0),Y_p(0), 2*JtSz, 12.5);

  SetTextJustify(CenterText, CenterText);
  PD_text('Text',X_p(0)+ScaleX,-1, Y_p(0),0.5, LabelX);  {..put X label}

  SetTextJustify(LeftText, CenterText);
  PD_text('Text',X_p(0), 1, Y_p(0)-ScaleY,0.5, LabelY);  {..put Y label}

  SetDXFlayer(LayerName);

  D_X_F:=LocalD_X_F;

END; {..PutRefSystem}

{----------------------------------------------------------------------------}
procedure PutAng(Color:Integer; x1,y1, x0,y0, x2,y2,ExtL:double; Dim:string);
{if (x1 = x0) AND (y1 = y0) then measures angle from the OX axis             }
{Dim can be of the form  '|<Text>|' '|<Text' '<Text' 'Text' 'Text>|' etc.    }
{If Dim = '' the angle is not labeled or measured.   If Dim = one or more    }
{empty spaces, angle is measurd and displayed over Max2(Length(Dim),4).      }
{if Color > 0 draw an arc of radius ExtL*JtSz from line (x0,y0)-(x1,y1) to   }
{line (x0,y0)-(x2,y2), extension lines from (x0,y0) to (x1,y1) and/or from   }
{(x0,y0) to (x2,y2) and/or arrow head(s) based on '|', '<' '>' in Dim.       }
{If Color <> 0 put text Dim at the middle of the arc.                        }

var  x,y, ArwHdSz, cA,sA, Ang: double;
     W,D: Byte;  {..width and number of decimals of Dim}
     Put_CCW_arrow, Put_CW_arrow, Put_RefLn_1, Put_RefLn_2: Boolean;

BEGIN  {PutAng..}
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  if (x2 = x0) AND (y2 = y0) then Exit;
  if (x1 = x0) AND (y1 = y0) then BEGIN  {..measure angle about OX axis}
    x1:=x0 + 100.0;   y1:=y0;
  END;

  ExtL:=Abs(ExtL);
  if (ExtL > 25) then ExtL:=25;
  if (ExtL <  3) then ExtL:= 3;

  ArwHdSz:=1.3;  {..arrow-head length measured in joint sizes}
  cA:=0.5*ArwHdSz/ExtL;
  sA:=Sqrt(1.0 - cA*cA);
  ArwHdSz:=ArwHdSz*JtSz;  {..arrow head length in multiple of joint sizes}
  ExtL:=ExtL*RJtSz;   {..extension line length in multiple of joint sizes}

  A_P_B(x0,y0, x1,y1, ExtL, x1,y1);  {..dimension arc end-point 1}
  A_P_B(x0,y0, x2,y2, ExtL, x2,y2);  {..dimension arc end-point 2}

  x:=0.5*(x1+x2);  y:=0.5*(y1+y2);   {..a point on angle bisector}
  A_P_B(x0,y0, x,y, Abs(ExtL), x,y);  {..middle point of the arc  }
  if (x0 = x) AND (y0 = y) then BEGIN  {90 rot of (x1,y1) about (x0,y0)..}
    x:=x0-(y1-y0);
    y:=y0+(x1-x0);
  END
  else
    if (S123(x1,y1,x,y,x2,y2) < 0) then A_P_B(x0,y0,x,y,-ExtL,x,y);

  SetTextJustify(Round(1-(x-x0)/ExtL),Round(1-(y-y0)/ExtL));

  SetLineStyle(SolidLn, 0, NormWidth);   SyncDXFLineStyleTkns;
  SetColorBGI_DXF(Abs(Color));

  if (Color > 0) then
    PDarc3pts('',X_p(x1),Y_p(y1), X_p(x),Y_p(y), X_p(x2),Y_p(y2));

  ArwHdSz:=Min2(R_p121(Dist2Pts2D(x1,y1,x,y)+Dist2Pts2D(x,y,x2,y2)),ArwHdSz);

  if (Dim[1] <> '|') then Put_RefLn_2:=FALSE
  else BEGIN
    Put_RefLn_2:=TRUE;    Delete(Dim,1,1);
  END;
  if (Dim[1] <> '<') then Put_CCW_arrow:=FALSE
  else BEGIN
    Put_CCW_arrow:=TRUE;    Delete(Dim,1,1);
  END;

  if (Dim[Length(Dim)] <> '|') then Put_RefLn_1:=FALSE
  else BEGIN
    Put_RefLn_1:=TRUE;    Delete(Dim,Length(Dim),1);
  END;
  if (Dim[Length(Dim)] <> '>') then Put_CW_arrow:=FALSE
  else BEGIN
    Put_CW_arrow:=TRUE;    Delete(Dim,Length(Dim),1);
  END;

  W:=Length(Dim);
  if (W > 0) then BEGIN
{
    if (Pos('_',Dim) > 0) AND (Round(1-(x-x0)/ExtL) = 1) then
      A_P_B(x,y,x0,y0, -2.1*RJtSz, x,y)
    else
      A_P_B(x,y,x0,y0, -1.1*RJtSz, x,y);
}
    A_P_B(x,y,x0,y0, -1.1*RJtSz, x,y);  {..move x,y outwards to put text}

    if (TrimBlanks(Dim) = '') then BEGIN  {evaluate Dim ..}
      if (W < 4) then W:=7;
      if (W > 7) then D:=2 else D:=1;

      Ang:=U2dirs2D(x1-x0,y1-y0, x2-x0,y2-y0);
      if (S123(x1,y1, x,y, x2,y2) > 0) OR (Pos('<',Dim) > 0) then BEGIN
        if (Ang < 0) then Ang:=2*Pi+Ang; {positive angle ..}
      END
      else BEGIN
        if (Ang > 0) then Ang:=Ang-2*Pi; {negative angle ..}
      END;
{
      Ang:=U2dirs2D(x1-x0,y1-y0, x-x0,y-y0);
      Ang:=Ang+U2dirs2D(x-x0,y-y0, x2-x0,y2-y0);
}
      Dim:=MySt2(Ang*DEG,W,D);
      Dim:=Dim+'ø'; {..include the DEG simbol}
    END;
    PD_text('',X_p(x),0, Y_p(y),0, Dim);
  END;

  if (Color > 0) then BEGIN
    if Put_RefLn_1 then BEGIN  {draw reference line (x0,y0)-(x1,y1)..}
      A_P_B(x1,y1,x0,y0, -0.5*RJtSz, x,y);
      PD_line('',X_p(x0),Y_p(y0), X_p(x),Y_p(y));
    END;
    UpdateLimitsWS(x,y);
    if Put_RefLn_2 then BEGIN  {draw reference line (x0,y0)-(x2,y2)..}
      A_P_B(x2,y2,x0,y0, -0.5*RJtSz, x,y);
      PD_line('',X_p(x0),Y_p(y0), X_p(x),Y_p(y));
    END;
    UpdateLimitsWS(x,y);

    if Put_CCW_arrow then BEGIN
      {rotate (x0,y0) about (x2,y2) by Alpha to get arrow head end point (x,y)..}
      x:=x2 + (x0-x2)*cA - (y0-y2)*sA;
      y:=y2 + (x0-x2)*sA + (y0-y2)*cA;
      ArrowH(X_p(x2),Y_p(y2), X_p(x),Y_p(y), ArwHdSz, 12.0);
    END;
    if Put_CW_arrow then BEGIN
      {rotate (x1,y1) about (x0,y0) by -Alpha to get arrow head end point (x,y)..}
      x:=x1 + (x0-x1)*cA + (y0-y1)*sA;
      y:=y1 - (x0-x1)*sA + (y0-y1)*cA;
      ArrowH(X_p(x1),Y_p(y1), X_p(x),Y_p(y), ArwHdSz, 12.0);
    END;
  END;

END; {..PutAng}

{----------------------------------------------------------------------------}
procedure PutDist(Color:Integer; xA,yA,xB,yB, ExtL:double; Dim:string);
{Dim can be of the form  '|<Text>|' '|<Text' '<Text' 'Text' 'Text>|' etc.    }
{If Dim = '' dimension is not labeled nor measured.  If Dim = one or more    }
{empty spaces, dimension is measurd and displayed over Max2(Length(Dim),4).  }
{ExtL < 0 flipps the dimension about A-B.                                    }
{if Color > 0 draw dimension line, extension line(s) and arrow head(s)       }
{based on '|', '<' '>' in Dim.                                               }
{If Color <> 0 put text Dim at the middle of the dimension line.             }

var  AB, Gap, x,y, x_A,y_A, x_B,y_B, ArwHdSz: double;
     PutArrow_A, PutArrow_B, Put_RefLn_A, Put_RefLn_B: Boolean;

BEGIN  {PutDist..}
  if (Color = 0) OR (MaxX*+MaxY = 0) then Exit; {0 color OR not in graphic mode}

  ArwHdSz:=1.3*JtSz; {..arrow head length in multiple of joint sizes}

  AB:=Dist2Pts2D(xA,yA, xB,yB);

  if (AB < EpsR) then Exit;

  if (Dim[1] <> '|') then Put_RefLn_A:=FALSE
  else BEGIN  {will put arrow head at end A..}
    Put_RefLn_A:=TRUE;   Delete(Dim,1,1);
  END;
  if (Dim[1] <> '<') then PutArrow_A:=FALSE
  else BEGIN  {will put arrow head at end A..}
    PutArrow_A:=TRUE;    Delete(Dim,1,1);
  END;

  if (Dim[Length(Dim)] <> '|') then Put_RefLn_B:=FALSE
  else BEGIN  {will put arrow head at end B..}
    Put_RefLn_B:=TRUE;   Delete(Dim,Length(Dim),1);
  END;
  if (Dim[Length(Dim)] <> '>') then PutArrow_B:=FALSE
  else BEGIN  {will put arrow head at end B..}
    PutArrow_B:=TRUE;    Delete(Dim,Length(Dim),1);
  END;

  if (Dim = '') OR (AB <= EpsR) then Gap:=0
  else BEGIN
    if (TrimBlanks(Dim) = '') then BEGIN  {..measured distance}
      if Length(Dim) < 3 then
        Dim:=MySt(AB,Round(Max2(5,Length(Dim))))
      else
        Dim:=MyStr(AB,Round(Max2(5,Length(Dim))));
    END;
    Gap:=(1+Length(Dim))*PixChW;
    Gap:=Max2(Abs(xB-xA)/Gap,Abs(yB-yA)/PixChH);
    Gap:=1.25*p2R121(AB/Gap);  {..width of gap in the dimension line + 25%}
  END;

  SetColorBGI_DXF(Abs(Color));
  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

  if (Abs(ExtL) > 30) then ExtL:=20*Sgn(ExtL);

  if (Abs(ExtL) > EpsR) then BEGIN
    ExtL:=ExtL*RJtSz;

    A_P_B(xA,yA,xB,yB, ExtL+0.5*Sgn(ExtL)*RJtSz, x,y);
    x_A:=xA-(y-yA);  y_A:=yA+(x-xA);  {..rotate (x,y) about (xA,yA) by 90 deg}
    if (Color > 0) AND Put_RefLn_A then BEGIN  {..draw extension line @ A}
      PD_line('',X_p(xA),Y_p(yA), X_p(x_A),Y_p(y_A));
      UpdateLimitsWS(x_A,y_A);
    END;

    A_P_B(xB,yB,xA,yA, -(ExtL+0.5*Sgn(ExtL)*RJtSz), x,y);
    x_B:=xB-(y-yB);  y_B:=yB+(x-xB);  {..rotate x,y by 90 deg about (xB,yB)}
    if (Color > 0) AND Put_RefLn_B then BEGIN {..draw extension line @ B}
      PD_line('',X_p(xB),Y_p(yB), X_p(x_B),Y_p(y_B));
      UpdateLimitsWS(x_B,y_B);
    END;

    A_P_B(x_A,y_A,xA,yA, 0.5*RJtSz, x_A,y_A); {..end @ A of dimension line}
    A_P_B(x_B,y_B,xB,yB, 0.5*RJtSz, x_B,y_B); {..end @ B of dimension line}
  END
  else BEGIN
    x_A:=xA;  y_A:=yA;  {..end @ A of dimension line}
    x_B:=xB;  y_B:=yB;  {..end @ A of dimension line}
  END;

{- - - - - - - - - - - - - - - - -}

  if (Color > 0) then BEGIN
    ArwHdSz:=Min2(R_p121(AB),ArwHdSz);

    if PutArrow_A then
      ArrowH(X_p(x_A),Y_p(y_A), X_p(x_B),Y_p(y_B), ArwHdSz, 12.0);

    if PutArrow_B then
      ArrowH(X_p(x_B),Y_p(y_B), X_p(x_A),Y_p(y_A), ArwHdSz, 12.0);

    if (Dim = '') OR (AB < 1.5*Gap) then  {draw dimension line w/o gap..}
      PD_line('',X_p(x_A),Y_p(y_A), X_p(x_B),Y_p(y_B))
    else BEGIN  {draw dimension line with a gap..}
      A_P_B(x_A,y_A, x_B,y_B, 0.5*AB-0.5*Gap, x,y);
      PD_line('',X_p(x_A),Y_p(y_A), X_p(x),Y_p(y));
      A_P_B(x_B,y_B, x_A,y_A, 0.5*AB-0.5*Gap, x,y);
      PD_line('',X_p(x_B),Y_p(y_B), X_p(x),Y_p(y));
    END;
  END;

{- - - - - - - - - - - - - - - - -}

  if (Dim <> '') then BEGIN  {put Dim..}
    x:=0.5*(x_A+x_B);
    y:=0.5*(y_A+y_B); {..(x,y) is now the middle point of the dimension line}
    if (TrimBlanks(Dim) = '') then
      Dim:=MySt(AB,Round(Max2(5,Length(Dim))));  {..put the measured distance}
    if (AB > 1.5*Gap) then
      SetTextJustify(CenterText, CenterText)
    else BEGIN
      xA:=0.5*(xA+xB);
      yA:=0.5*(yA+yB); {..(xA,yA) is now the middle point on the line AB}
      SetTextJustify(Round(1.0-(x-xA)/Abs(ExtL)),Round(1.0-(y-yA)/Abs(ExtL)));
      A_P_B(x,y,xA,yA, -0.3*p2R121(PixChH), x,y);
    END;
    PD_text('',X_p(x),0,Y_p(y),0, Dim);
  END;

END; {..PutDist}

{----------------------------------------------------------------------------}
procedure gShape(FxyName:PathStr; Color:Integer; xA,yA:double);
{Draw a polyline read from file FxyName with (0,0) moved to (xA,yA).         }
{Multiple shapes are delimited by (InfD,InfD) or a line of '----------------'}
{Color is changed by adding a line of (2+Color/100)*InfD,(2+Color/100)*InfD  }
{If FxyName is a number rather than a file name, it will draw a circle       }
{centered at (xA,yA) and of radius FxyName.                                  }

var FTxy:Text;
    FDxy:file of double;
    Ext :ExtStr;
    AuxStr:string;
    InfColor,  x,y, xPrev,yPrev, AB: double;
    EndOfFile,D2Dfile: Boolean;

label NewPoly;

BEGIN {gShape ..}
  _:=InfD;

  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  Ext:=GetExt(FxyName);
{$I-}
  if (Ext = '.D2D') OR (Ext = '.$2D') then BEGIN
    Assign(FDxy,FxyName); Reset(FDxy);
    D2Dfile:=TRUE;
  END
  else if (FxyName <> '') then BEGIN
    Assign(FTxy,FxyName); Reset(FTxy);
    D2Dfile:=FALSE;
  END;

  LocalD_X_F:=D_X_F;

  if (LastNrLayer > 1) then D_X_F:=FALSE; {..1st M3D frame already generated}

  SetColorBGI_DXF(Abs(Color));
{$I+}

  if (IOResult <> 0) then BEGIN  {FxyName not found..}
    {draw a circle centered at (xA,yA) and of radius AB..}
    if (FxyName[1] = '-') then SetLineStyle(DashedLn, 0, NormWidth);
    if (FxyName[1] = '.') then SetLineStyle(DottedLn, 0, NormWidth);
    SyncDXFLineStyleTkns;
    AB:=Abs(Extract1stNo(FxyName));
    if (AB < InfR) then BEGIN
      PDcircle('Ground',X_p(xA),Y_p(yA),R_p121(AB));
      UpdateLimitsWS(xA+AB,yA+AB);
      UpdateLimitsWS(xA-AB,yA-AB);
    END;
    D_X_F:=LocalD_X_F;
    SetLineStyle(SolidLn, 0, NormWidth);
    SyncDXFLineStyleTkns;
    Exit;
  END;

  repeat  {extract color and the first vertex..}
    NewPoly:
    if D2Dfile then BEGIN
      Read(FDxy,x,y);  {..read line from D2D or $2D file}
      if (x > InfD) then InfColor:=100*(x/InfD-2.0);
      EndOfFile:=Eof(FDxy);
    END
    else BEGIN
      ReadLn(FTxy,AuxStr);  {..read line ASCII file}
      InfColor:=100*(MyVal(AuxStr)/InfD-2.0);
      x:=Extract1stNo(AuxStr);
      y:=Extract1stNo(AuxStr);
      EndOfFile:=Eof(FTxy)
    END;
    if (InfColor > 0) AND (InfColor < 16) then
      SetColorBGI_DXF(Round(InfColor));
  until ((x < InfD) AND (y < InfD)) OR EndOfFile;

  if NOT EndOfFile then BEGIN
    ExpectDXFplines;
    x:=x+xA;  y:=y+yA;  {..translate vertex (x,y)}
    AddVertexPline('Ground',x,y);  {..write first vertex}
    UpdateLimitsWS(x,y);
    x:=X_p(x);  y:=Y_p(y);  {..screen coordinates to be used w/ Line}

    if NOT EndOfFile then repeat  {read the rest of the vertices..}
      xPrev:=x;   yPrev:=y;
      if D2Dfile then BEGIN  {read line from D2D or $2D file..}
        Read(FDxy,x,y);
        if (x > InfD) then InfColor:=100*(x/InfD-2.0);
        EndOfFile:=Eof(FDxy);
      END
      else BEGIN  {read line from ASCII file..}
        ReadLn(FTxy,AuxStr);
        InfColor:=100*(MyVal(AuxStr)/InfD-2.0);
        x:=Extract1stNo(AuxStr);
        y:=Extract1stNo(AuxStr);
        EndOfFile:=Eof(FTxy)
      END;
      if (x >= InfD) OR (y >= InfD) then BEGIN  {polyline breaker..}
        DXFplineEnd('Ground');
        if (InfColor > 0) AND (InfColor < 16) then
          SetColorBGI_DXF(Round(InfColor))  {..new Color}
        else
          SetColorBGI_DXF(Abs(Color)); {..restore Color}
        GoTo NewPoly;
      END;
      x:=x+xA;  y:=y+yA;  {..translate vertex (x,y)}
      AddVertexPline('Ground',x,y);  {..add vertex to shape}
      UpdateLimitsWS(x,y);
      x:=X_p(x);  y:=Y_p(y);  {..screen coordinates to be used w/ Line}
      Line(RoundInt(xPrev),RoundInt(yPrev),RoundInt(x),RoundInt(y));
    until EndOfFile;

    DXFplineEnd('Ground');  {..close polyline}
  END;

  if D2Dfile then Close(FDxy) else Close(FTxy);

  D_X_F:=LocalD_X_F;

END; {.. gShape}

{----------------------------------------------------------------------------}
procedure Shape(FxyName:PathStr; Color:Integer; xA,yA,xB,yB:double);
{Draw a polyline read from file FxyName with (0,0) moved to (xA,yA) and OX   }
{passing through (xB,yB).  Multiple shapes are delimited by (InfD,InfD), and }
{color can be controlled by a line of (2+Color/100)*InfD,(2+Color/100)*InfD. }
{If FxyName does not exist, draws a circle centered at (xA,yA) and of radius }
{(xA,yA)-(xB,yB). If FxyName = '-' drawing line is dashed.  If FxyName= '.'  }
{drawing line is dotted.                                                     }

var FTxy:Text;
    FDxy:file of double;
    Ext :ExtStr;
    AuxStr:string;
    x,y, xPrev,yPrev, Ang, InfColor, AB:double;
    EndOfFile,D2Dfile:Boolean;

label NewPoly;

BEGIN {Shape ..}
  _:=InfD;

  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  Ext:=GetExt(FxyName);
  {$I-}
    if (Ext = '.D2D') OR (Ext = '.$2D') then BEGIN
      Assign(FDxy,FxyName);  Reset(FDxy);
      D2Dfile:=TRUE;
    END
    else if (FxyName <> '') then BEGIN
      Assign(FTxy,FxyName);  Reset(FTxy);
      D2Dfile:=FALSE;
    END;
  {$I+}

  SetColorBGI_DXF(Abs(Color));

  if (IOResult <> 0) OR ((FxyName = '')) then BEGIN  {FxyName not found..}
    SetLineStyle(SolidLn, 0, NormWidth);
    if (FxyName[1] = '-') then SetLineStyle(DashedLn, 0, NormWidth);
    if (FxyName[1] = '.') then SetLineStyle(DottedLn, 0, NormWidth);
    SyncDXFLineStyleTkns;
    AB:=Abs(Extract1stNo(FxyName));
    if (AB >= InfR) then AB:=Sqrt(Sqr(xB-xA)+Sqr(yB-yA));
    {draw a circle centered at (xA,yA) and of radius AB ..}
    PDcircle('',X_p(xA),Y_p(yA),R_p121(AB));
    UpdateLimitsWS(xA+AB,yA+AB);
    UpdateLimitsWS(xA-AB,yA-AB);
    SetLineStyle(SolidLn, 0, NormWidth);
    SyncDXFLineStyleTkns;
    Exit;
  END;

  AB:=Sqrt(Sqr(xB-xA)+Sqr(yB-yA));
  if (AB > 0.0) then Ang:=Atan2(yB-yA,xB-xA) else Ang:=0.0;

  repeat  {extract color and the first vertex..}
    NewPoly:
    if D2Dfile then BEGIN
      Read(FDxy,x,y);  {..read line from D2D or $2D file}
      if (x > InfD) then InfColor:=100*(x/InfD-2.0);
      EndOfFile:=Eof(FDxy);
    END
    else BEGIN
      ReadLn(FTxy,AuxStr);  {..read line ASCII file}
      InfColor:=100*(MyVal(AuxStr)/InfD-2.0);
      x:=Extract1stNo(AuxStr);
      y:=Extract1stNo(AuxStr);
      EndOfFile:=Eof(FTxy)
    END;
    if (InfColor > 0) AND (InfColor < 16) then BEGIN
      SetColorBGI_DXF(Round(InfColor));
    END
  until ((x < InfD) AND (y < InfD)) OR EndOfFile;

  if NOT EndOfFile then BEGIN
    ExpectDXFplines;

    RT2D(x,y,Ang,xA,yA, x,y);  {..translate and rotate vertex (x,y)}
    AddVertexPline('',x,y);  {..write first vertex}
    UpdateLimitsWS(x,y);
    x:=X_p(x);  y:=Y_p(y);  {..screen coordinates to be used w/ Line}

    if NOT EndOfFile then repeat  {read the rest of the vertices..}
      xPrev:=x;   yPrev:=y;
      if D2Dfile then BEGIN  {read line from D2D or $2D file..}
        Read(FDxy,x,y);
        if (x > InfD) then InfColor:=100*(x/InfD-2.0);
        EndOfFile:=Eof(FDxy);
      END
      else BEGIN  {read line from ASCII file..}
        ReadLn(FTxy,AuxStr);
        InfColor:=100*(MyVal(AuxStr)/InfD-2.0);
        x:=Extract1stNo(AuxStr);
        y:=Extract1stNo(AuxStr);
        EndOfFile:=Eof(FTxy)
      END;
      if (x >= InfD) OR (y >= InfD) then BEGIN  {polyline breaker..}
        DXFplineEnd('');
        if (InfColor > 0) AND (InfColor < 16) then
          SetColorBGI_DXF(Round(InfColor))  {..new Color}
        else
          SetColorBGI_DXF(Abs(Color)); {..restore Color}
        GoTo NewPoly;
      END;
      RT2D(x,y,Ang,xA,yA, x,y); {..translate and rotate vertex (x,y)}
      AddVertexPline('',x,y);  {..add vertex to shape}
      UpdateLimitsWS(x,y);
      x:=X_p(x);  y:=Y_p(y);  {..screen coordinates to be used w/ Line}
      Line(RoundInt(xPrev),RoundInt(yPrev),RoundInt(x),RoundInt(y));
    until EndOfFile;

    DXFplineEnd('');  {..close polyline}
  END;

  if D2Dfile then Close(FDxy) else Close(FTxy);

END;  {.. Shape}


{----------------------------------------------------------------------------}
procedure Locus(Color:Integer; xP,yP:double; Name:NameStr);
{Trace the path of P on the screen and write (xP,yP) to a temp file of double}
{PtName is the name of the temporary file with the extension .$2D            }
{If Color < 0 it only writes the locus to file!                              }

var FDxyTemp:file of double;
    x,y, xPrev,yPrev:double;

BEGIN {Locus ..}

  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  Name:=ProperLayerName(Name);

  {$I-}
   Assign(FDxyTemp,Name+'.$2D');
   Reset(FDxyTemp);
  {$I+}
  if (IOResult <> 0) then BEGIN  {FDxyTemp file does not exist - create one}
    Rewrite(FDxyTemp);
    x:=(2.0+0.01*Color)*InfD;
    Write(FDxyTemp,x,x);    {write color code to FDxyTemp      }
    Write(FDxyTemp,xP,yP);  {write 1st locus point to FDxyTemp }
  END
  else BEGIN
    if (Color > 0) then BEGIN
      SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
      SetColorBGI_DXF(Abs(Color));
      Read(FDxyTemp,x,x);  {..this is the color code of the polyline }
      Read(FDxyTemp,x,y);  {..read first vertex of the locus      }
      while NOT Eof(FDxyTemp) do BEGIN {draw polyline locus on the screen only ...}
        xPrev:=x;
        yPrev:=y;
        Read(FDxyTemp,x,y);
        Line(X_pI(xPrev),Y_pI(yPrev),X_pI(x),Y_pI(y));
      END;
    END;
    if MecOut then BEGIN {append latest segment to FDxyTemp & draw it on screen..}
      Seek(FDxyTemp,FileSize(FDxyTemp));
      Write(FDxyTemp,xP,yP);
      if (Color > 0) then Line(X_pI(x),Y_pI(y),X_pI(xP),Y_pI(yP));
    END;
  END;

  Close(FDxyTemp);

END; {.. Locus}

{----------------------------------------------------------------------------}
procedure CometLocus(Color:Integer; xP,yP:double; Name:NameStr);
{Trace the path of P on the screen and write (xP,yP) to a temp file of double}
{PtName is the name of the temporary file with the extension .$2D            }
{If Color < 0 it only writes the locus to file!                              }

var FDxyTemp:file of double;
    xPrev,yPrev, x,y:double;

BEGIN
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  {$I-}
   Assign(FDxyTemp,Name+'.$$D');
   Reset(FDxyTemp);
  {$I+}
  if (IOResult <> 0) then BEGIN {FDxyTemp file does not exist - create one..}
    Rewrite(FDxyTemp);
    Write(FDxyTemp,xP,yP);  {..write 1st locus point to FDxyTemp }
    Close(FDxyTemp);
    Exit;
  END;
  {append new locus point to FDxyTemp..}
  Seek(FDxyTemp, FileSize(FDxyTemp));
  Write(FDxyTemp, xP,yP);
  UpdateLimitsWS(xP,yP);

  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
  SetColorBGI_DXF(Abs(Color));

  if MecOut then ExpectDXFplines;

  Reset(FDxyTemp);
  x:=InfD;   y:=InfD;
  repeat
    xPrev:=x;  yPrev:=y;
    Read(FDxyTemp,x,y);  {..read vertex from file}
    if MecOut then AddVertexPline('',x,y);  {..write vertex to polyline}
    x:=X_p(x);  y:=Y_p(y);  {..screen coordinates to be used w/ Line}
    if (xPrev < InfD) then
      Line(RoundInt(xPrev),RoundInt(yPrev), RoundInt(x),RoundInt(y));
  until Eof(FDxyTemp);

  if MecOut then DXFplineEnd('');  {..close polyline}

  Close(FDxyTemp);
END; {.. CometLocus}

{----------------------------------------------------------------------------}
procedure HodographXYn(Color,n:Integer; X,Y:VDo; Name:NameStr; SF:double);
{Extracts the hodograph from polyline X[n],Y[n] and plots it on the screen }

var i:Word;
    CloseXY:Boolean;
    xP,yP:double;

procedure Get_xPyP(x0,y0, x1,y1, x2,y2:double; var xP,yP:double);
var R,V, xC,yC, cT,sT:double;
BEGIN
  Circ3Pts(x0,y0, x1,y1, x2,y2, R, xC,yC);
  if Abs(R) < 1.0E+9 then BEGIN
    V:=R*U3pts2D(x0,y0, xC,yC, x2,y2)*SF;
    cT:=(x1-xC)/R;
    sT:=(y1-yC)/R;
    xP:=x1 + V*cT;
    yP:=y1 + V*sT;
  END
  else BEGIN
    V:=(Dist2Pts2D(x0,y0,x1,y1) + Dist2Pts2D(x1,y1,x2,y2))*SF;
    cT:=(x2-x0)/V;
    sT:=(y2-y0)/V;
    xP:=x1 - V*sT;
    yP:=y1 + V*cT;
  END;
END;

BEGIN {HodographXYn ..}
  if (n < 3) OR (Color = 0) OR (MaxX*MaxY = 0) then Exit;

  if (Sqr(X[1]-X[n])+Sqr(Y[1]-Y[n]) < 1.0E-9) then CloseXY:=TRUE else CloseXY:=FALSE;

  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
  SetColorBGI_DXF(Abs(Color));
  SetDXFlayer(ProperLayerName(Name));

  if CloseXY then BEGIN
    X[n+1]:=X[2];  Y[n+1]:=Y[2];
    X[n+2]:=X[3];  Y[n+2]:=Y[3];
  END;

  for i:=2 to n+1 do BEGIN
    Get_xPyP(X[i-1],Y[i-1], X[i],Y[i], X[i+1],Y[i+1], xP,yP);
    Locus(Abs(Color), X[i],Y[i], 'H0'+Name);
    Locus(Abs(Color), xP,yP, 'H1'+Name);
    if (i = n+1) then Exit;
    PD_line(Name,X_p(X[i]),Y_p(Y[i]), X_p(xP),Y_p(yP));
  END;

END; {.. HodographXYn}

{----------------------------------------------------------------------------}
procedure VelocityXYn(Color,n:Integer; X,Y:VDo; Name:NameStr; SF:double);
{Extracts velocity vectors from polyline X[n],Y[n] and plots them on the screen }

var i:Word;
    CloseXY:Boolean;
    V, xP,yP, ArwHdSz:double;

procedure Get_xPyP(x0,y0, x1,y1, x2,y2:double; var xP,yP:double);
var R, xC,yC, cT,sT:double;
BEGIN
  Circ3Pts(x0,y0, x1,y1, x2,y2, R, xC,yC);
  if Abs(R) < 1.0E+9 then BEGIN
    V:=R*U3pts2D(x0,y0, xC,yC, x2,y2)*SF;
    cT:=(x1-xC)/R;
    sT:=(y1-yC)/R;
    xP:=x1 - V*sT;
    yP:=y1 + V*cT;
  END
  else BEGIN
    V:=(Dist2Pts2D(x0,y0,x1,y1) + Dist2Pts2D(x1,y1,x2,y2))*SF;
    cT:=(x2-x0)/V;
    sT:=(y2-y0)/V;
    xP:=x1 + V*cT;
    yP:=y1 + V*sT;
  END;
END;

BEGIN {VelocityXYn ..}
  if (n < 3) OR (Color = 0) OR (MaxX*MaxY = 0) then Exit;

  if (X[1] = X[n]) AND (Y[1] = Y[n]) then CloseXY:=TRUE else CloseXY:=FALSE;

  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
  SetColorBGI_DXF(Abs(Color));
  SetDXFlayer(ProperLayerName(Name));

  if CloseXY then BEGIN
    X[n+1]:=X[2];  Y[n+1]:=Y[2];
    X[n+2]:=X[3];  Y[n+2]:=Y[3];
  END;

  for i:=2 to n+1 do BEGIN
    Get_xPyP(X[i-1],Y[i-1], X[i],Y[i], X[i+1],Y[i+1], xP,yP);
    ArwHdSz:=Min2(0.5*R_p121(V),3*JtSz);  {..calculate arrow-head length}
   if (Color < 0) then BEGIN
      Locus(Abs(Color), xP-X[i],yP-Y[i], 'L_'+Name);
      if (i = n+1) then Exit;
      PD_line('', X_p(0),Y_p(0), X_p(xP-X[i]),Y_p(yP-Y[i]) );
      ArrowH(X_p(xP-X[i]),Y_p(yP-Y[i]), X_p(0),Y_p(0), ArwHdSz, 12.5); {..arrow head @ B}
    END
    else BEGIN
      Locus(Abs(Color), X[i],Y[i], 'L_'+Name);
      PD_line('', X_p(X[i]),Y_p(Y[i]), X_p(xP),Y_p(yP) );
      ArrowH(X_p(xP),Y_p(yP), X_p(X[i]),Y_p(Y[i]), ArwHdSz, 12.5); {..arrow head @ B}
    END;
  END;

END; {.. VelocityXYn}

{----------------------------------------------------------------------------}
procedure VelocityXY3(Color:Integer; x0,y0, x1,y1, x2,y2, SF:double);
{Extracts velocity vectors using 3 points and plots it on the screen }

var i:Word;   V, xP,yP, ArwHdSz:double;

procedure Get_xPyP(x0,y0, x1,y1, x2,y2:double; var xP,yP:double);
var R, xC,yC, cT,sT:double;
BEGIN
  Circ3Pts(x0,y0, x1,y1, x2,y2, R, xC,yC);
  if Abs(R) < 1.0E+9 then BEGIN
    V:=R*U3pts2D(x0,y0, xC,yC, x2,y2)*SF;
    cT:=(x1-xC)/R;
    sT:=(y1-yC)/R;
    xP:=x1 - V*sT;
    yP:=y1 + V*cT;
  END
  else BEGIN
    V:=(Dist2Pts2D(x0,y0,x1,y1) + Dist2Pts2D(x1,y1,x2,y2))*SF;
    cT:=(x2-x0)/V;
    sT:=(y2-y0)/V;
    xP:=x1 + V*cT;
    yP:=y1 + V*sT;
  END;
END;

BEGIN {VelocityXY3 ..}
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit;

  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
  SetColorBGI_DXF(Abs(Color));

  Get_xPyP(x0,y0, x1,y1, x2,y2, xP,yP);
  PD_line('', X_p(x1),Y_p(y1), X_p(xP),Y_p(yP) );
  ArwHdSz:=Min2(0.5*R_p121(V),3*JtSz);  {..calculate arrow-head length}
  ArrowH(X_p(xP),Y_p(yP), X_p(x1),Y_p(y1), ArwHdSz, 12.5);

END; {.. VelocityXY3}

{----------------------------------------------------------------------------}
procedure Jline(xA1,yA1, xB1,yB1, xB,yB, Ang, dAng: double);
{Draw a J stick from A1 to B1 and arched about point B over an angle Ang     }
{dAng is the angular increment                                               }

var  r,AB, cA,sA,cdA,sdA, xPrev,yPrev, x,y: double;
     nPts, i: Integer;

BEGIN {Jline ..}
  if (Ang > InfR) then BEGIN
    Ang:=0;  nPts:=0;
  END
  else
    nPts:=RoundInt(Ang/(dAng+EpsR));
  if (nPts <= 0) then nPts:=1;
  if (nPts > 36) then nPts:=36;
  dAng:=Ang/nPts;
  r:=Dist2Pts2D(xB,yB,xB1,yB1);
  if (r < EpsR) then r:=EpsR;
  AB:=Dist2Pts2D(xA1,yA1,xB1,yB1);
  AddVertexPline('',xA1,yA1);  UpdateLimitsWS(xA1,yA1);
  if (AB > EpsR) then BEGIN
    AddVertexPline('',xB1,yB1);  UpdateLimitsWS(xB1,yB1);
    Line(RoundInt(X_p(xA1)),RoundInt(Y_p(yA1))
    ,RoundInt(X_p(xB1)),RoundInt(Y_p(yB1)));
    cA:=(yB1-yA1)/AB;
    sA:=(xA1-xB1)/AB;
  END
  else BEGIN
    cA:=(xB1-xB)/r;
    sA:=(yA1-yB)/r;
  END;
  xPrev:=X_p(xB1);  yPrev:=y_p(yB1);
  for i:=1 to nPts do BEGIN
    cdA:=cos(dAng*i);
    sdA:=sin(dAng*i);
    x:=xB + r*(cA*cdA-sA*sdA);
    y:=yB + r*(sA*cdA+cA*sdA);
    if (nPts = 2) AND (i = 1) then BEGIN
      x:=xB;
      y:=yB;
    END;
    AddVertexPline('',x,y);  UpdateLimitsWS(x,y);
    x:=X_p(x);  y:=Y_p(y);  {screen coordinates to be used w/ Line }
    Line(RoundInt(xPrev),RoundInt(yPrev),RoundInt(x),RoundInt(y));
    xPrev:=x;  yPrev:=y;
  END;
END; {.. Jline}

{----------------------------------------------------------------------------}
procedure TaperLink(Color:Integer; xA,yA, xB,yB, rA, rB:double);
{Draw a trapezoidal link  A----------B  rounded with radius rA at end A, and }
{radius rB at end B.  If rA < 0 or rB < 0 the respective end is straight.    }

var AB,xA0,yA0,xA1,yA1,xA2,yA2, xB0,yB0,xB1,yB1,xB2,yB2,
    cA,sA, AngB201,AngA102,dAngA,dAngB: double;
    OK: Boolean;

BEGIN {TaperLink ..}
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  AB:=Sqrt(Sqr(xB-xA)+Sqr(yB-yA));

  if (AB < EpsR) then Exit;

  SetColorBGI_DXF(Abs(Color));
  if (Color < 0) then
    SetLineStyle(DashedLn, 0, NormWidth)
  else
    SetLineStyle(SolidLn, 0, NormWidth);
  SyncDXFLineStyleTkns;

  ExtTang2Circ(xA,yA,Abs(rA), xB,yB,Abs(rB)
  ,xA1,yA1,xB1,yB1, xA2,yA2,xB2,yB2,OK);

  if (Abs(Max2(rA,rA)) < AB/1000.0) OR (NOT OK) then  {draw a line only ..}
    SkLine(X_p(xA),Y_p(yA),X_p(xB),Y_p(yB),JtSz,JtSz)
{   PDline('',X_p(xA),Y_p(yA),X_p(xB),Y_p(yB)); }
  else BEGIN
    ExpectDXFplines;
    dAngA:=Pi/18;
    dAngB:=Pi/18;
    if Abs(rA) >= Abs(rB) then BEGIN
      AngB201:=2*U3pts2D90(xB,yB,xA,yA,xA1,yA1);
      AngA102:=2*Pi - AngB201;
      if (rA < 0) then dAngA:=0.5*AngA102;
      if (rB < 0) then dAngB:=AngB201;
    END
    else BEGIN
      AngA102:=2*U3pts2D90(xB,yB,xA,yA,xA1,yA1);
      AngB201:=2*Pi - AngA102;
      if (rA < 0) then dAngA:=AngA102;
      if (rB < 0) then dAngB:=0.5*AngB201;
    END;
    Jline(xA2,yA2, xB2,yB2, xB,yB, AngB201, dAngB);
    Jline(xB1,yB1, xA1,yA1, xA,yA, AngA102, dAngA);
    DXFplineEnd('');  {.. close polyline}
  END;

END; {.. TaperLink}

{----------------------------------------------------------------------------}
procedure Link(Color:Integer; xA,yA, xB,yB, w, rA, rB:double);
{Draw a rectangular link  A-B  fileted with radius rA at end A, and radius   }
{rB at end B.  If rA < 0 OR rB < 0 does chanfering instead of filleting.     }

var  AB, x0,y0, x1,y1, x2,y2, x3,y3, dAng, cA,sA: double;

BEGIN {Link ..}
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  AB:=Sqrt(Sqr(xB-xA)+Sqr(yB-yA));

  if (AB < EpsR) then Exit;

  SetColorBGI_DXF(Abs(Color));
  if (Color < 0) then
    SetLineStyle(DashedLn, 0, NormWidth)
  else
    SetLineStyle(SolidLn, 0, NormWidth);
  SyncDXFLineStyleTkns;

  if (Abs(w) < AB/1000.0) then  {draw a line only ..}
    SkLine(X_p(xA),Y_p(yA),X_p(xB),Y_p(yB),JtSz,JtSz)
{   PDline('',X_p(xA),Y_p(yA),X_p(xB),Y_p(yB)); }
  else BEGIN
    if (Abs(rA) >= 0.5*w) then rA:=Sgn(rA)*0.5*w - Sgn(rA)*1.0E-9;
    if (Abs(rB) >= 0.5*w) then rB:=Sgn(rB)*0.5*w - Sgn(rB)*1.0E-9;
    sA:=(yB-yA)/AB;
    cA:=(xB-xA)/AB;

    ExpectDXFplines;

    x1:=xA+0.5*w*sA;            y1:=yA-0.5*w*cA;
    x2:=xB+0.5*w*sA;            y2:=yB-0.5*w*cA;
    x0:=xB+(0.5*w-Abs(rB))*sA;  y0:=yB-(0.5*w-Abs(rB))*cA;
    x3:=x0+Abs(rB)*cA;          y3:=y0+Abs(rB)*sA;
    if (rB < 0) then dAng:=InfD else dAng:=Pi/18;
    Jline(x1,y1, x2,y2, x0,y0, Pi/2, dAng);

    x1:=x3;                     y1:=y3;
    x0:=xB-(0.5*w-Abs(rB))*sA;  y0:=yB+(0.5*w-Abs(rB))*cA;
    x2:=x0+Abs(rB)*cA;          y2:=y0+Abs(rB)*sA;
    x3:=xB-0.5*w*sA;            y3:=yB+0.5*w*cA;
    Jline(x1,y1, x2,y2, x0,y0, Pi/2, dAng);

    x1:=x3;                     y1:=y3;
    x2:=xA-0.5*w*sA;            y2:=yA+0.5*w*cA;
    x0:=xA-(0.5*w-Abs(rA))*sA;  y0:=yA+(0.5*w-Abs(rA))*cA;
    x3:=x0-Abs(rA)*cA;          y3:=y0-Abs(rA)*sA;
    if (rA < 0) then dAng:=InfD else dAng:=Pi/18;
    Jline(x1,y1, x2,y2, x0,y0, Pi/2, dAng);

    x1:=x3;                     y1:=y3;
    x0:=xA+(0.5*w-Abs(rA))*sA;  y0:=yA-(0.5*w-Abs(rA))*cA;
    x2:=x0-Abs(rA)*cA;          y2:=y0-Abs(rA)*sA;
    x3:=xA+0.5*w*sA;            y3:=yA-0.5*w*cA;
    Jline(x1,y1, x2,y2, x0,y0, Pi/2, dAng);

    DXFplineEnd('');  {.. close polyline}
  END;

END; {.. Link}

{----------------------------------------------------------------------------}
procedure LinkC(Color:Integer; xA,yA, xB,yB, R, w, rA, rB:double);
{Draw CCW an arched link from A to B of mean radius R and width w that is    }
{fileted with radius rA at end A, and radius rB at end B.  If rA < 0 or      }
{rB < 0 it chanfers instead of fillets that end.                             }

var StAng,EndAng, dAng, cSA,sSA, cEA,sEA, AB,
    xC,yC, x1,y1, x2,y2, x0,y0: double;

BEGIN {LinkC ..}
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  AB:=Sqrt(Sqr(xB-xA)+Sqr(yB-yA));

  if (AB < EpsR) then Exit;

  if (R  < 0) then BEGIN
    R:=-R;
    x0:=xA;  xA:=xB;  xB:=x0;
    y0:=yA;  yA:=yB;  yB:=x0;
  END;

  SetColorBGI_DXF(Abs(Color));
  if (Color < 0) then
    SetLineStyle(DashedLn, 0, NormWidth)
  else
    SetLineStyle(SolidLn, 0, NormWidth);
  SyncDXFLineStyleTkns;

  AB:=Dist2Pts2D(xA,yA, xB,yB);

  if (AB >= 2*R) OR (AB*AB/(4*R*R-AB*AB) <= 0.03) then BEGIN
    {R too small OR R too big i.e. angle subintended by AB < 10 deg ..}
    Link(Color, xA,yA, xB,yB, w, rA, rB);
    Exit;
  END;

  GetCenterPtPtRad(xA,yA,xB,yB, R, xC,yC);

  StAng :=Atan2(yA-yC,xA-xC);
  EndAng:=NghbrAng(StAng,Atan2(yB-yC,xB-xC));

  if (Abs(w) < 1E-3*AB) then BEGIN {draw an arch only ..}
    if OpaqueJoints then dAng:=2*Arctan(0.5*p2R121(JtSz)/R) else dAng:=0;
    PDarc('',X_p(xC),Y_p(yC),(StAng+dAng)*DEG,(EndAng-dAng)*DEG,R_p121(R));
    Exit;
  END;

  BEGIN
    if (Abs(rA) >= 0.5*w) then rA:=Sgn(rA)*0.5*w - Sgn(rA)*1.0E-9;
    if (Abs(rB) >= 0.5*w) then rB:=Sgn(rB)*0.5*w - Sgn(rB)*1.0E-9;

    sSA:=sin(StAng);   cSA:=cos(StAng);
    sEA:=sin(EndAng);  cEA:=cos(EndAng);

    ExpectDXFplines;

    x1:=xC + (R-w/2)*cSA - EpsR*sSA;
    y1:=yC + (R-w/2)*sSA + EpsR*cSA;
    x2:=xC + (R-w/2)*cSA;
    y2:=yC + (R-w/2)*sSA;
    x0:=xC + (R-w/2+Abs(rA))*cSA;
    y0:=yC + (R-w/2+Abs(rA))*sSA;
    if (rA < 0) then dAng:=InfD else dAng:=Pi/18;
    Jline(x1,y1, x2,y2, x0,y0, Pi/2, dAng);

    x0:=xC + (R+w/2-Abs(rA))*cSA;
    y0:=yC + (R+w/2-Abs(rA))*sSA;
    x1:=xC + (R-w/2+Abs(rA))*cSA + Abs(rA)*sSA;
    y1:=yC + (R-w/2+Abs(rA))*sSA - Abs(rA)*cSA;
    x2:=x0 + Abs(rA)*sSA;
    y2:=y0 - Abs(rA)*cSA;
    Jline(x1,y1, x2,y2, x0,y0, Pi/2, dAng);   {?}

    x1:=xC + (R+0.5*w)*cSA + EpsR*sSA;
    y1:=yC + (R+0.5*w)*sSA - EpsR*cSA;
    x2:=xC + (R+0.5*w)*cSA;
    y2:=yC + (R+0.5*w)*sSA;
    Jline(x1,y1, x2,y2, xC,yC, EndAng-StAng, Pi/32);

    if (rB < 0) then dAng:=InfD else dAng:=Pi/18;
    x0:=xC + (R+0.5*w-Abs(rB))*cEA;
    y0:=yC + (R+0.5*w-Abs(rB))*sEA;
    x1:=xC + (R+0.5*w)*cEA + EpsR*sEA;
    y1:=yC + (R+0.5*w)*sEA - EpsR*AB*cEA;
    x2:=xC + (R+0.5*w)*cEA;
    y2:=yC + (R+0.5*w)*sEA;
    Jline(x1,y1, x2,y2, x0,y0, Pi/2, dAng);

    x0:=xC + (R-0.5*w+Abs(rB))*cEA;
    y0:=yC + (R-0.5*w+Abs(rB))*sEA;
    x1:=xC + (R+0.5*w-Abs(rB))*cEA - Abs(rB)*sEA;
    y1:=yC + (R+0.5*w-Abs(rB))*sEA + Abs(rB)*cEA;
    x2:=x0 - Abs(rB)*sEA;
    y2:=y0 + Abs(rB)*cEA;
    Jline(x1,y1, x2,y2, x0,y0, Pi/2, dAng);

    x1:=xC + (R-0.5*w)*cEA - EpsR*sEA;
    y1:=yC + (R-0.5*w)*sEA + EpsR*cEA;
    x2:=xC + (R-0.5*w)*cEA;
    y2:=yC + (R-0.5*w)*sEA;
    Jline(x1,y1, x2,y2, xC,yC, -EndAng+StAng, -Pi/32);

    DXFplineEnd('');  {.. close polyline}
  END;

END; {..LinkC}

{----------------------------------------------------------------------------}
procedure Link3(Color:Integer; xA,yA,xB,yB,xC,yC, r:double);
{Draws a triangular link A-B-C fileted with radius r at each corner}

var  w, ABC, Ang, AB,AC,BC, xAB,yAB, xBA,yBA,
     xBC,yBC, xCB,yCB, xCA,yCA, xAC,yAC: double;

BEGIN {Link3..}
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  SetColorBGI_DXF(Abs(Color));
  if (Color < 0) then
    SetLineStyle(DashedLn, 0, NormWidth)
  else
    SetLineStyle(SolidLn, 0, NormWidth);
  SyncDXFLineStyleTkns;

  w:=2*Abs(r);

  AB:=Dist2Pts2D(xA,yA, xB,yB);
  AC:=Dist2Pts2D(xA,yA, xC,yC);
  BC:=Dist2Pts2D(xB,yB, xC,yC);

  ABC:=S123(xA,yA, xB,yB, xC,yC);

  if Abs(ABC) < EpsR then BEGIN
    if (AB > AC) then BEGIN
      if (AB > BC) then
        Link(Color, xA,yA, xB,yB, w, r, r)
      else
        Link(Color, xB,yB, xC,yC, w, r, r)
    END
    else BEGIN
      if (AC > BC) then
        Link(Color, xA,yA, xC,yC, w, r, r)
      else
        Link(Color, xB,yB, xC,yC, w, r, r)
    END;
    Exit;
  END;

  if (ABC < 0) then BEGIN  {swap B and C..}
    Ang:=xB; xB:=xC; xC:=Ang;
    Ang:=yB; yB:=yC; yC:=Ang;
    Ang:=AB; AB:=AC; AC:=Ang;
  END;

  if Abs(ABC)/Max3(AB,AC,BC) < 0.01*Min3(AB,AC,BC) then BEGIN
    if (AB = Max3(AB,AC,BC)) then Link(Color,xA,yA,xB,yB, w, r,r);
    if (AC = Max3(AB,AC,BC)) then Link(Color,xA,yA,xC,yC, w, r,r);
    if (BC = Max3(AB,AC,BC)) then Link(Color,xB,yB,xC,yC, w, r,r);
    Exit;
  END;

  if (r > 0) then w:=Pi/18  {reuse w as dAng in Jline..}
  else BEGIN
    w:=Pi/6;  r:=-r;
  END;

  xAB:=xA+r*(yB-yA)/AB;   yAB:=yA-r*(xB-xA)/AB;
  xBA:=xB+r*(yB-yA)/AB;   yBA:=yB-r*(xB-xA)/AB;
  xBC:=xB+r*(yC-yB)/BC;   yBC:=yB-r*(xC-xB)/BC;
  xCB:=xC+r*(yC-yB)/BC;   yCB:=yC-r*(xC-xB)/BC;
  xCA:=xC+r*(yA-yC)/AC;   yCA:=yC-r*(xA-xC)/AC;
  xAC:=xA+r*(yA-yC)/AC;   yAC:=yA-r*(xA-xC)/AC;

  ExpectDXFplines;
  Ang:=U3pts2D(xBA,yBA, xB,yB, xBC,yBC);
  Jline(xAB,yAB, xBA,yBA, xB,yB, Ang, w);

  Ang:=U3pts2D(xCB,yCB, xC,yC, xCA,yCA);
  Jline(xBC,yBC, xCB,yCB, xC,yC, Ang, w);

  Ang:=U3pts2D(xAC,yAC, xA,yA, xAB,yAB);
  Jline(xCA,yCA, xAC,yAC, xA,yA, Ang, w);

  DXFplineEnd('');

END; {.. Link3}

{----------------------------------------------------------------------------}
procedure LinkN(Color, n:Integer;  vX,vY:VDn;  r:double);
{Draws a polygonal link fileted with radius r at each of the N corner.       }
{The polygon must be oriented CCW, and should not exceed 12 vertices.        }

var ABC, Alpha, Theta, dAng, sinA, AB,BC, xA,yA, xB,yB, xC,yC,
    xA1,yA1, xB1,yB1, xB2,yB2, xC1,yC1: double;
    i,j,n0: Byte;

BEGIN  {LinkN..}
  if (Color = 0) OR (MaxX*MaxY = 0) or (n < 2) then Exit;
  if (n > N_max-2) then n:=N_max-2;
  r:=r;
  repeat
    n0:=n;
    if (n = 1) then Exit;
    if (n = 2) then BEGIN
      Link(Color, vX[1],vY[1], vX[2],vY[2], 2*r, r, r);   Exit;
    END;
    if (n = 3) then BEGIN
      Link3(Color, vX[1],vY[1], vX[2],vY[2], vX[3],vY[3], r);   Exit;
    END;
    vX[n+1]:=vX[1];  vY[n+1]:=vY[1];
    vX[n+2]:=vX[2];  vY[n+2]:=vY[2];
    i:=1;
    repeat {remove coincident & colinear vertices..}
      xA:=vX[i];    yA:=vY[i];
      xB:=vX[i+1];  yB:=vY[i+1];
      xC:=vX[i+2];  yC:=vY[i+2];
      AB:=Dist2Pts2D(xA,yA, xB,yB);
      BC:=Dist2Pts2D(xB,yB, xC,yC);
      if (AB < EpsR) then BEGIN  {eliminate A..}
        for j:=i to n+2 do BEGIN
          vX[j]:=vX[j+1];  vY[j]:=vY[j+1];
        END;
        n:=n-1;
        i:=1;
      END;
      if (BC < EpsR) OR Colin3Pts2D(xA,yA,xB,yB,xC,yC,Max2(AB,BC)/100) then BEGIN {eliminate B..}
        for j:=i+1 to n+2 do BEGIN
          vX[j]:=vX[j+1];  vY[j]:=vY[j+1];
        END;
        n:=n-1;
        i:=1;
      END;
      Inc(i);
    until (i = n);
  until (n0 = n);  {..remove coincident vertices}

  SetColorBGI_DXF(Abs(Color));
  if (Color < 0) then
    SetLineStyle(DashedLn, 0, NormWidth)
  else
    SetLineStyle(SolidLn, 0, NormWidth);
  SyncDXFLineStyleTkns;

  ExpectDXFplines;
  if (Abs(r) < EpsR) then BEGIN  {draw a polygon - no fillet..}
    for i:=1 to n do BEGIN
      xA:=vX[i];    yA:=vY[i];
      xB:=vX[i+1];  yB:=vY[i+1];
      AddVertexPline('',xA,yA);   UpdateLimitsWS(xA,yA);
      if (i = n) then AddVertexPline('',xB,yB);  UpdateLimitsWS(xB,yB);
      xA:=X_p(xA);   yA:=Y_p(yA);
      xB:=X_p(xB);   yB:=Y_p(yB);
      Line(RoundInt(xA),RoundInt(yA),RoundInt(xB),RoundInt(yB));
    END;  {.. for}
  END  {.. draw a polygon - no fillet}
  else
  BEGIN  {draw offset polygon with fillet..}
    if (r > 0) then dAng:=Pi/18  {reuse w as dAng in Jline..}
    else BEGIN
      dAng:=Pi/6;  r:=-r;
    END;
    for i:=1 to n do BEGIN
      xA:=vX[i];    yA:=vY[i];
      xB:=vX[i+1];  yB:=vY[i+1];
      xC:=vX[i+2];  yC:=vY[i+2];

      AB:=Dist2Pts2D(xA,yA, xB,yB);
      BC:=Dist2Pts2D(xB,yB, xC,yC);

      Alpha:=Abs(U3pts2D(xA,yA, xB,yB, xC,yC));
      ABC:=S123(xA,yA, xB,yB, xC,yC);
      if (ABC >= -1.0E-9) then BEGIN {offset on the outside & fillet..}
        if (Alpha < 1.0E-9) then Alpha:=Pi else Alpha:=Pi-Alpha;
        xA1:=xA+r*(yB-yA)/AB;   yA1:=yA-r*(xB-xA)/AB;
        xB2:=xB+r*(yB-yA)/AB;   yB2:=yB-r*(xB-xA)/AB;
        Jline(xA1,yA1, xB2,yB2, xB,yB, Alpha, dAng);
      END
      else BEGIN  {offset on the inside - no fillet..}
        xA1:=xA+r*(yB-yA)/AB;
        yA1:=yA-r*(xB-xA)/AB;

        if (Alpha < 1.0E-9) then Alpha:= Pi;
        sinA:=sin(0.5*Alpha);
        if (sinA >= 0) AND (sinA <  1.0E-9) then sinA:= Pi;
        if (sinA <  0) AND (sinA > -1.0E-9) then sinA:=-Pi;

        Theta:=U2dirs2D(1.0,0.0, xB-xA,yB-yA);
        xB1:=xB+r/sinA*cos(Theta+0.5*Alpha-Pi);
        yB1:=yB+r/sinA*sin(Theta+0.5*Alpha-Pi);

        AddVertexPline('',xA1,yA1);   UpdateLimitsWS(xA1,yA1);
        AddVertexPline('',xB1,yB1);   UpdateLimitsWS(xB1,yB1);

        A_P_B(xB,yB,xC,yC,AB-Dist2Pts2D(xA1,yA1,xB1,yB1),vX[i+1],vY[i+1]);
        xA1:=X_p(xA1);   yA1:=Y_p(yA1);
        xB1:=X_p(xB1);   yB1:=Y_p(yB1);
        Line(RoundInt(xA1),RoundInt(yA1), RoundInt(xB1),RoundInt(yB1));
      END;
    END; {.. for}
  END; {.. draw offset polygon with fillet}

  DXFplineEnd('');

END; {.. LinkN}

{----------------------------------------------------------------------------}
procedure LinkL(Color:Integer;  X1,Y1, X2,Y2, X3,Y3, r:double);
{Draws an L shaped link fileted with radius r at each corner.                }
var vX,vY:VDn;
BEGIN
  vX[1]:=X1;   vY[1]:=Y1;
  vX[2]:=X2;   vY[2]:=Y2;
  vX[3]:=X3;   vY[3]:=Y3;
  vX[4]:=X2;   vY[4]:=Y2;
  vX[5]:=X1;   vY[5]:=Y1;
  LinkN(Color,5,vX,vY,Abs(r));
END; {.. LinkL}

{----------------------------------------------------------------------------}
procedure Base(Color:Integer; xA,yA,xB,yB, w, rA,rB:double);
{Draws a rectangular link A------------B fileted with radius rA at end A, and}
{radius rB at end B.  If rA < 0 or rB < 0 it chanfers instead of filleting.  }

var LayerName:Str31;

BEGIN {Base..}
  if (Color = 0) OR (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  if (w = 0.0) then Exit;

  LocalD_X_F:=D_X_F;
  if (LastNrLayer > 1) then D_X_F:=FALSE; {..1st M3D frame already generated}

  LayerName:=GetDXFlayer;
  SetDXFlayer('Ground');
  Link(Color, xA,yA, xB,yB, w, rA,rB);

  SetDXFlayer(LayerName);

  D_X_F:=LocalD_X_F;

END; {.. Base}

{----------------------------------------------------------------------------}
procedure SetTitle(s:string);
BEGIN
  MecTitle:=s;
END;

{----------------------------------------------------------------------------}
procedure SetFooter(s:string);
BEGIN
  MecFooter:=s;
END;

{----------------------------------------------------------------------------}
procedure NewFrame(MS:Word);
BEGIN
  _:=InfD;  {..just in case it has been altered elsewhere}

  if (MaxX*MaxY = 0) then Exit; {not in graphic mode}

  if (MS = 0) then Exit;  {no screen refresh}

  Delay(MS);
  ClearViewPort;

 if (MecTitle <> '') OR (MecFooter <> '') then BEGIN  {put title/footer..}
    LocalD_X_F:=D_X_F;
    if (LastNrLayer >= 1) then D_X_F:=FALSE;
    SetColorBGI_DXF(MaxColor);
    if (MecTitle <> '') then BEGIN
      SetTextJustify(CenterText, TopText);
      PDtext('Ground',X_p(xCentScr),0, Y_p(yTopScr),0, MecTitle);
    END;
    if (MecFooter <> '') then BEGIN
      D_X_F:=FALSE; {comment this line to write footor to DXF!!}
      SetTextJustify(CenterText, BottomText);
      PDtext('Ground',X_p(xCentScr),0, Y_p(yBotmScr),0, MecFooter);
    END;
    D_X_F:=LocalD_X_F;
  END;

  if (NOT MecOut) then Exit;

  Inc(LastNrLayer);
  SetDXFlayer(MySt(LastNrLayer,4));

END; {.. NewFrame}

{----------------------------------------------------------------------------}
procedure OpenMecGraph(X_min,X_max,Y_min,Y_max:double);

BEGIN
  _:=InfD;  {..just in case it has been altered somewhere}

  if (MaxX*MaxY = 0) then BEGIN  {this first time OpenMecGraph is called..}
    MecOut:=TRUE;  {..MecOut changes to FALSE after calling CloseMecDXF}
    InitGr(1);     {..simulations are all on black screen}
  END;

  Obj2Scr(TRUE, X_min,X_max,Y_min,Y_max);  {..sets workspace limits}

  xCentScr:=0.5*(X_min+X_max);  {..x coordinate of the center of the screen }
  yTopScr :=Y_max;{+GetExtentY;}   {..y coordinate of the top of the screen    }
  yBotmScr:=Y_min;{+GetExtentY;}   {..y coordinate of the bottom of the screen }

  MySetTextStyle(SmallFont, HorizDir,1, FALSE);

{
  JtSz:=MyVal(MySt(p2R121(JtSz),5))/p2R121(1.0);
  ..this limits the number of decimals in anything that uses JtSz
}

  RJtSz:=p2R121(JtSz);  {..joint size in real units}

END; {.. OpenMecGraph}

{----------------------------------------------------------------------------}
procedure CloseMecDXF;
{Writes loci as polylines and close all DXF files }

var DirInfo:SearchRec;
    FDxyTemp:file of double;
    LayerName:Str31;
    x,y:double;   j:Byte;

BEGIN {CloseMecDXF..}
  if (MaxX*MaxY = 0) then Exit; {0 color OR not in graphic mode}

  FindFirst('*.$2D', Archive, DirInfo);
  while (DosError = 0) do BEGIN {convert $2D data to DXF polylines..}
    LayerName:=DirInfo.Name;
    for j:=1 to 4 do Delete(LayerName,Length(LayerName),1);
    Assign(FDxyTemp,DirInfo.Name);
    Reset(FDxyTemp);
    Read(FDxyTemp,x,x);  {..read polyline color from file}
    x:=(x/InfD-2.0)*100.0;
    SetColorBGI_DXF(RoundInt(Abs(x))); {.. set polyline color}
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    ExpectDXFplines;
    while NOT Eof(FDxyTemp) do BEGIN
      Read(FDxyTemp,x,y);
      AddVertexPline(LayerName, x,y);
    END;
    DXFplineEnd(LayerName);
    Close(FDxyTemp);
    FindNext(DirInfo);
  END;

  CloseDXFfile;

  MecOut:=FALSE; {No more DXF file output after this!}

  EraseAll('*.$$D');    {..erase leftover files}

END; {.. CloseMecDXF}

{----------------------------------------------------------------------------}
procedure CloseMecGraph(SaveD2DandXYfiles:Boolean);
{Closes graphics system and if RenD2D = TRUE convert $2D files to D2D }

var  FDxy:file of double;
     FTxy:text;
     DirInfo:SearchRec;

BEGIN
{$I-}
  if SaveD2DandXYfiles then BEGIN  {change .$2D & .$XY to .D2D & .XY respectively..}
    FindFirst('*.$2D', Archive, DirInfo);
    while (DosError = 0) do BEGIN {change .$2D to .D2D..}
      Assign(FDxy,DirInfo.Name);
      if (IOresult = 0) then
        RenameFile(DirInfo.Name,GetName(DirInfo.Name)+'.D2D');
      FindNext(DirInfo);
    END;

    FindFirst('*.$XY', Archive, DirInfo);
    while (DosError = 0) do BEGIN {change .$XY to .XY..}
      Assign(FTxy,DirInfo.Name);
      if (IOresult = 0) then
        RenameFile(DirInfo.Name,GetName(DirInfo.Name)+'.XY');
      FindNext(DirInfo);
    END;
  END
  else BEGIN
    EraseAll('*.$2D');  {erase temporary loci files}
    EraseAll('*.$XY');  {erase temporary envelope files}
  END;

  EraseAll('*.$$D');  {erase temporary comet loci files}
  HaltGr; {shuts down the graphics system and makes MaxX:=0 & MaxY:=0;}
  CloseDXFfile;
  MecOut:=FALSE; {no more DXF file output}
  LastNrLayer:=0;  {reset layer name index}

{$I+}

END; {.. CloseMecGraph}

{----------------------------------------------------------------------------}
procedure SizeLinMotor(s:double; var A0Q,PC:double);
{Stores lengths A0Q of piston and PC of cylinder so that the piston remains  }
{inside cylinder.  Must be called during the entire cycle; prior to this it  }
{must be activated by calling SizeLinMotor with s=InfD.                      }

BEGIN
  if (s > InfR) then BEGIN
    A0Q:=-InfD;
    PC := InfD;
  END;
  if (PC  > s) then PC:=s;
  if (A0Q < s-PC) then A0Q:=s-PC;
END; {.. SizeLinMotor}

{----------------------------------------------------------------------------}
procedure SetJointSize(JtSize:ShortInt);
{Set the relative and absolute joint size i.e. JtSz and RJtSz   }

BEGIN
  if (JtSize > 0) then SimpleJoint:=FALSE else SimpleJoint:=TRUE;

  JtSz:=Abs(JtSize);

  if (JtSize > 10) then JtSize:= 10;

  JtSz:=MyVal(MySt(p2R121(JtSz),5))/p2R121(1.0); {..limit nr. of decimals in anything that uses JtSz}

  RJtSz:=p2R121(JtSz); {..joint size in real units}

END; {.. SetJointSize}

{----------------------------------------------------------------------------}
procedure Ground_Hatch(X1,Y1, X3,Y3:double);
{Draw 3 hatch segments at (X1,Y1), (X3,Y3) and 1/2 between them at (X2,Y2)}

var D13, X2,Y2, X,Y, AuxX,AuxY, cTheta,sTheta:double;

BEGIN
  D13:=Sqrt(Sqr(X3-X1)+Sqr(Y3-Y1));
  if (D13 = 0.0) then Exit;

  if (X1 < X3) then BEGIN
      AuxX:=X1;  X1:=X3;  X3:=AuxX;
      AuxY:=Y1;  Y1:=Y3;  Y3:=AuxY;
  END;
  X2:=X1+0.5*(X3-X1);
  Y2:=Y1+0.5*(Y3-Y1);
  cTheta:=(X3-X1)/D13;
  sTheta:=(Y3-Y1)/D13;
  AuxX:=JtSz*(cTheta*0.707107 + sTheta*0.707107);
  AuxY:=JtSz*(sTheta*0.707107 - cTheta*0.707107);
  X:=X1+AuxX;
  Y:=Y1+AuxY;
  PD_line('Ground',X,Y,X1,Y1);
  X:=X2+AuxX;
  Y:=y2+AuxY;
  PD_line('Ground',X,Y,X2,Y2);
  X:=X3+AuxX;
  Y:=Y3+AuxY;
  PD_line('Ground',X,Y,X3,Y3);
END; {.. Ground_Hatch}

{----------------------------------------------------------------------------}
procedure SkLine(xA,yA,xB,yB, rA,rB:double);
{Draw a line from A to B but stop at rA from A and rB from B.  Useful when   }
{drawing lines connecting joints.                                            }

var xA1,yA1,xB1,yB1:double;

BEGIN {SkLine..}
  if (Dist2Pts2D(xA,yA,xB,yB) > (rA+rB)) then BEGIN
    A_P_B(xA,yA, xB,yB, rA,  xA1,yA1);
    A_P_B(xB,yB, xA,yA, rB,  xB1,yB1);
    PD_line('',xA1,yA1, xB1,yB1);
  END;
{ else PD_line('',xA,yA,xB,yB);}
END; {.. SkLine}

{----------------------------------------------------------------------------}
procedure LLine(xA,yA,xC,yC,xB,yB, JtSzA,JtSzB:double);
{Draw polyline A/C\B offset from A by JtSz and offset from B by JtSz}

BEGIN
  A_P_B(xA,yA,xC,yC, JtSzA, xA,yA);
  A_P_B(xB,yB,xC,yC, JtSzB, xB,yB);

  ExpectDXFplines;
  MoveTo(RoundInt(xA),RoundInt(yA));
  AddVertexPline('',p_X121(xA),p_Y121(yA));
  LineTo(RoundInt(xC),RoundInt(yC));
  AddVertexPline('',p_X121(xC),p_Y121(yC));
  LineTo(RoundInt(xB),RoundInt(yB));
  AddVertexPline('',p_X121(xB),p_Y121(yB));
  DXFplineEnd('');
END; {.. LLine}

{----------------------------------------------------------------------------}
procedure ZLine(xA,yA,xC1,yC1,xC2,yC2,xB,yB, JtSzA,JtSzB:double);
{Draw polyline A\C1_C2/B offset from A by JtSz and offset from B by JtSz}

BEGIN
  A_P_B(xA,yA,xC1,yC1, JtSzA, xA,yA);
  A_P_B(xB,yB,xC2,yC2, JtSzB, xB,yB);

  ExpectDXFplines;
  MoveTo(RoundInt(xA),RoundInt(yA));
  AddVertexPline('',p_X121(xA),p_Y121(yA));
  LineTo(RoundInt(xC1),RoundInt(yC1));
  AddVertexPline('',p_X121(xC1),p_Y121(yC1));
  LineTo(RoundInt(xC2),RoundInt(yC2));
  AddVertexPline('',p_X121(xC2),p_Y121(yC2));
  LineTo(RoundInt(xB),RoundInt(yB));
  AddVertexPline('',p_X121(xB),p_Y121(yB));
  DXFplineEnd('');
END; {.. ZLine}

{----------------------------------------------------------------------------}
procedure B_l_o_c_k(xP,yP, Alpha:double; Grounded:Boolean);
{ Draw a rectangle (a Block) at xP,yP and inclined by Alpha from horizontal }
{ It is used by subroutines Block(..) and gBlock(..) }

var ViewPort_L: ViewPortType;
    P4: Poly_8;
    a,b, cA,sA: double;

BEGIN {B_l_o_c_k..}
  GetViewSettings(ViewPort_L);
  with ViewPort_L do BEGIN
    if (xP < 0) OR (xP > x2-x1) then Exit;
    if (yP < 0) OR (yP > y2-y1) then Exit;
  END;
  cA:=cos(Alpha);  sA:=sin(Alpha);
  a:=3*JtSz;
  b:=2*JtSz;
  P4[1].x:=xP + a*cA+b*sA;   P4[1].y:=yP - a*sA+b*cA;
  P4[2].x:=xP - a*cA+b*sA;   P4[2].y:=yP + a*sA+b*cA;
  P4[3].x:=xP - a*cA-b*sA;   P4[3].y:=yP + a*sA-b*cA;
  P4[4].x:=xP + a*cA-b*sA;   P4[4].y:=yP - a*sA-b*cA;

  SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

  if OpaqueJoints then BEGIN  {opaque slide block..}
    SetFillStyle(SolidFill,MinColor);
    if OpaqueJoints then IncDXFelev;
    DmyFaces:=TRUE;
    PDdrawPoly('',4, P4,TRUE);
    PDfillPoly('',4, P4);
    DmyFaces:=FALSE;
    if OpaqueJoints then DecDXFelev;
  END
  else {transparent slide block..}
    PDdrawPoly('',4, P4,TRUE);

  if Grounded then BEGIN
    a:=2.7*JtSz;
    P4[1].x:=xP+a*cA+b*sA;  P4[1].y:=yP-a*sA+b*cA;
    P4[2].x:=xP-a*cA+b*sA;  P4[2].y:=yP+a*sA+b*cA;
    Ground_Hatch(P4[1].x,P4[1].y, P4[2].x,P4[2].y);
  END;

END; {.. B_l_o_c_k}

{----------------------------------------------------------------------------}
procedure Block(xP,yP, Alpha:double);
{ Draw a Block at angle Alpha from the horizontal }

BEGIN
  B_l_o_c_k(xP,yP, Alpha, FALSE);
END; {.. Block}

{----------------------------------------------------------------------------}
procedure gBlock(xP,yP, Alpha:double);
{ Draw a grounded Block at an angle Alpha from the horizontal }

var LayerName:Str31;

BEGIN
  LocalD_X_F:=D_X_F;
  if (LastNrLayer > 1) then D_X_F:=FALSE; {..1st M3D frame already generated}

  LayerName:=GetDXFlayer;
  SetDXFlayer('Ground');

  B_l_o_c_k(xP,yP, Alpha, TRUE);

  SetDXFlayer(LayerName);

  D_X_F:=LocalD_X_F;

END; {.. gBlock}

{----------------------------------------------------------------------------}
procedure GroundLine(xP,yP,xQ,yQ:double);
{ Draw a line from P to Q with ground simbol at end P }

var PQ, X,Y,cTheta,sTheta:double;

BEGIN
  LocalD_X_F:=D_X_F;
  if (LastNrLayer > 1) then D_X_F:=FALSE;  {..1st M3D frame was generated}

  PQ:=Sqrt(Sqr(xQ-xP)+Sqr(yQ-yP));
  if (PQ = 0.0) then BEGIN
    cTheta:=1.0;  sTheta:=0.0;
  END
  else BEGIN
    cTheta:=(xQ-xP)/PQ;
    sTheta:=(yQ-yP)/PQ;
  END;

  if (R_p121(PQ) > 5*JtSz) then BEGIN
    PD_line('Ground',xP,yP,xQ,yQ);
    A_P_B(xQ,yQ, xP,yP, 2*JtSz, X,Y);
    Ground_Hatch(xQ,yQ, X,Y);
  END
  else
    PDlinePtAng('Ground',xP,yP,Atan2(sTheta,cTheta));

  D_X_F:=LocalD_X_F;

END; {.. GroundLine}

{----------------------------------------------------------------------------}
procedure gMotor(xP,yP:double);
{ Draw a grounded motor at xP,yP with the ground shown as 3 hatch-lines }

var DSize:double;
    LayerName:Str31;

BEGIN {gMotor..}
  LocalD_X_F:=D_X_F;
  if (LastNrLayer > 1) then D_X_F:=FALSE; {..1st M3D frame already generated}

  LayerName:=GetDXFlayer;
  SetDXFLayer('Ground');

  PDcircle('',xP,yP,    JtSz);  {motor shaft}
  PDcircle('',xP,yP,1.6*JtSz);  {motor case }
  if SimpleJoint then BEGIN {+&o&O symbol ..}
    PD_line('',xP-2*JtSz,yP,xP+2*JtSz,yP);
    PD_line('',xP,yP-2*JtSz,xP,yP+2*JtSz);
  END
  else BEGIN {O & o & /\ & +..}
    DSize:=0.35*JtSz;
    SkLine(xP-2*JtSz,yP+2*JtSz,xP,yP,0.0,1.6*JtSz);    {1st leg}
    SkLine(xP+2*JtSz,yP+2*JtSz,xP,yP,0.0,1.6*JtSz);    {2nd leg}
    PD_line('Ground',xP-3*JtSz,yP+2*JtSz,xP+3*JtSz,yP+2*JtSz); {base plate}
    Ground_Hatch(xP+3*JtSz-DSize,yP+2*JtSz,xP-3*JtSz+DSize,yP+2*JtSz);
  END;

  SetDXFlayer(LayerName);

  D_X_F:=LocalD_X_F;

END; {.. gMotor}

{----------------------------------------------------------------------------}
procedure Motor(xP,yP,Alpha:double);
{ Draw a powered pivot joint at xP,yP }

var X1,Y1:double;

BEGIN
  PDcircle('',xP,yP,    JtSz);  {motor shaft}
  PDcircle('',xP,yP,1.6*JtSz);  {motor case }
  X1:=(4*JtSz)*cos(Alpha)+xP;
  Y1:=-(4*JtSz)*sin(Alpha)+yP;
  SkLine(X1,Y1, xP,yP, 0.0, 1.6*JtSz); {short ref. line}
END; {.. Motor}

{----------------------------------------------------------------------------}
procedure gPivotJoint(xP,yP:double);
{ Draw a grounded pin joint at xP,yP with the ground shown as 3 hatch-lines }

var LayerName:Str31;
    DSize:double;

BEGIN
  LocalD_X_F:=D_X_F;
  if (LastNrLayer > 1) then D_X_F:=FALSE; {..1st M3D frame already generated}

  LayerName:=GetDXFlayer;
  SetDXFlayer('Ground');
  if SimpleJoint then BEGIN  {+ & o symbol ..}
    PDcircle('',xP,yP, JtSz);
    PD_line('',xP-1.8*JtSz,yP,xP+1.8*JtSz,yP);
    PD_line('',xP,yP-1.8*JtSz,xP,yP+1.8*JtSz);
  END
  else BEGIN {o & /\ & __ & ///..}
    DSize:=0.35*JtSz;
    PDcircle('',xP,yP, JtSz);
    SkLine(xP-2*JtSz,yP+2*JtSz,xP,yP,0.0,JtSz); {1st leg}
    SkLine(xP+2*JtSz,yP+2*JtSz,xP,yP,0.0,JtSz); {2nd leg}
    PD_line('',xP-3*JtSz,yP+2*JtSz,xP+3*JtSz,yP+2*JtSz); {base plate}
    Ground_Hatch(xP+3*JtSz-DSize,yP+2*JtSz,xP-3*JtSz+DSize,yP+2*JtSz);
  END;

  SetDXFlayer(LayerName);

  D_X_F:=LocalD_X_F;

END; {.. gPivotJoint}

{----------------------------------------------------------------------------}
procedure gPivotJointFlipped(xP,yP:double);
{ Draw a grounded pin joint at xP,yP with the ground shown as 3 hatch-lines }

var LayerName:Str31;
    DSize:double;

BEGIN

  LocalD_X_F:=D_X_F;
  if (LastNrLayer > 1) then D_X_F:=FALSE;  {..1st M3D frame already generated}

  LayerName:=GetDXFlayer;
  SetDXFlayer('Ground');
  if SimpleJoint then BEGIN  {+&o symbol..}
    PDcircle('',xP,yP, JtSz);
    PD_line('',xP-1.8*JtSz,yP,xP+1.8*JtSz,yP);
    PD_line('',xP,yP-1.8*JtSz,xP,yP+1.8*JtSz);
  END
  else BEGIN {o & \/ & __ & ///..}
    DSize:=0.35*JtSz;
    PDcircle('',xP,yP, JtSz);
    SkLine(xP-2*JtSz,yP-2*JtSz,xP,yP,0.0,JtSz); {1st leg}
    SkLine(xP+2*JtSz,yP-2*JtSz,xP,yP,0.0,JtSz); {2nd leg}
    PD_line('',xP-3*JtSz,yP-2*JtSz,xP+3*JtSz,yP-2*JtSz); {base plate}
    Ground_Hatch(xP-3*JtSz+DSize,yP-2*JtSz,xP+3*JtSz+-DSize,yP-2*JtSz);
  END;

  SetDXFlayer(LayerName);

  D_X_F:=LocalD_X_F;

END; {.. gPivotJointFlipped}

{----------------------------------------------------------------------------}
procedure Cylinder(xP,yP,xQ,yQ:double);

var PQ,cTheta,sTheta, X,Y:double;

BEGIN
  PQ:=Sqrt(Sqr(xQ-xP)+Sqr(yQ-yP));
  if (PQ < EpsR) then Exit;  {P and Q coincide..}
  cTheta:=(xQ-xP)/PQ;
  sTheta:=(yQ-yP)/PQ;
  ExpectDXFplines;
  X:=xQ-2*JtSz*sTheta;
  Y:=yQ+2*JtSz*cTheta;
  MoveTo(RoundInt(X),RoundInt(Y));
  AddVertexPline('',p_X121(X),p_Y121(Y));
  X:=xP-2*JtSz*sTheta;
  Y:=yP+2*JtSz*cTheta;
  LineTo(RoundInt(X),RoundInt(Y));
  AddVertexPline('',p_X121(X),p_Y121(Y));
  X:=xP+2*JtSz*sTheta;
  Y:=yP-2*JtSz*cTheta;
  LineTo(RoundInt(X),RoundInt(Y));
  AddVertexPline('',p_X121(X),p_Y121(Y));
  X:=xQ+2*JtSz*sTheta;
  Y:=yQ-2*JtSz*cTheta;
  LineTo(RoundInt(X),RoundInt(Y));
  AddVertexPline('',p_X121(X),p_Y121(Y));
  DXFplineEnd('');
END; {.. Cylinder}

{----------------------------------------------------------------------------}
procedure gCylinder(xP,yP,xQ,yQ:double);
{ Draw a grounded cylinder with the bottom at xP,yP and top at xQ,yQ }

var  PQ,cTheta,sTheta, X,Y,X1,Y1,X2,Y2:double;

BEGIN

  LocalD_X_F:=D_X_F;
  if (LastNrLayer > 1) then D_X_F:=FALSE;  {..1st M3D frame already generated}

  PQ:=Sqrt(Sqr(xQ-xP)+Sqr(yQ-yP));
  if (PQ = 0.0) then Block(xP,yP, 0.0)
  else BEGIN
    cTheta:=(xQ-xP)/PQ;
    sTheta:=(yQ-yP)/PQ;

    ExpectDXFplines;
    X:=xQ-2*JtSz*sTheta;
    Y:=yQ+2*JtSz*cTheta;
    MoveTo(RoundInt(X),RoundInt(Y));
    AddVertexPline('Ground',p_X121(X),p_Y121(Y));
    X1:=xP-2*JtSz*sTheta;
    Y1:=yP+2*JtSz*cTheta;
    LineTo(RoundInt(X1),RoundInt(Y1));
    AddVertexPline('Ground',p_X121(X1),p_Y121(Y1));
    X2:=xP+2*JtSz*sTheta;
    Y2:=yP-2*JtSz*cTheta;
    LineTo(RoundInt(X2),RoundInt(Y2));
    AddVertexPline('Ground',p_X121(X2),p_Y121(Y2));
    X:=xQ+2*JtSz*sTheta;
    Y:=yQ-2*JtSz*cTheta;
    LineTo(RoundInt(X),RoundInt(Y));
    AddVertexPline('Ground',p_X121(X),p_Y121(Y));
    DXFplineEnd('Ground');
    Ground_Hatch(X1,Y1,X2,Y2);
  END;

  D_X_F:=LocalD_X_F;

END; {.. gCylinder}

{----------------------------------------------------------------------------}
procedure Piston(xA,yA,xB,yB:double);
var  AB, cTheta,sTheta, X1,Y1, X2,Y2:double;

BEGIN
  AB:=Sqrt(Sqr(xA-xB)+Sqr(yA-yB));
  if (AB <> 0.0) then BEGIN
    PD_line('',xA,yA,xB,yB);
    cTheta:=(xB-xA)/AB;
    sTheta:=(yB-yA)/AB;
    X1:=xA+2*JtSz*sTheta;  Y1:=YA-2*JtSz*cTheta;
    X2:=xA-2*JtSz*sTheta;  Y2:=YA+2*JtSz*cTheta;
    PD_line('',X1,Y1,X2,Y2);
  END;
END; {.. Piston}

{----------------------------------------------------------------------------}
procedure LPiston(xA,yA, xB0,yB0, xB,yB:double);
var  AB,cTheta,sTheta, X1,Y1,X2,Y2:double;

BEGIN
  AB:=Sqrt(Sqr(xA-xB0)+Sqr(yA-yB0));
  if (AB <> 0.0) then BEGIN
    LLine(xA,yA, xB0,yB0, xB,yB, 0,0);  {draw piston rod}
    cTheta:=(xB0-xA)/AB;
    sTheta:=(yB0-yA)/AB;
    X1:=xA+2*JtSz*sTheta;  Y1:=YA-2*JtSz*cTheta;
    X2:=xA-2*JtSz*sTheta;  Y2:=YA+2*JtSz*cTheta;
    PD_line('',X1,Y1,X2,Y2); {draw transverse short line - actual piston}
  END;
END; {.. LPiston}

{----------------------------------------------------------------------------}
procedure LCylPiston(xA,yA,xA0,yA0,xP,yP,xQ,yQ,xC,yC:double);

var x_C,y_C:double;

BEGIN
  A_P_B(xC,yC, xP,yP, JtSz, x_C,y_C);
  Piston(xP,yP, x_C,y_C);
  Cylinder(xA0,yA0, xQ,yQ);
  SkLine(xA,yA, xA0,yA0, JtSz,0);
END; {.. LCylPiston}

{----------------------------------------------------------------------------}
procedure SetLminCylPiston(Lmin:double);
BEGIN
  LminCylPist:=-R_p121(Lmin); {negative means it was set from the program}
END; {.. SetLminCylPiston}

{----------------------------------------------------------------------------}
procedure CylPiston(xA,yA,xB,yB, Lmin:double);
var xQ,yQ:double;
BEGIN
  if (LminCylPist >= 0) then BEGIN
    xQ:=Sqrt(Sqr(xA-xB)+Sqr(yA-yB));
    LminCylPist:=xQ;
  END;
  if (Lmin = 0) OR (Lmin > InfR) OR (LminCylPist < 0) then Lmin:=Abs(LminCylPist);
  JtSz:=JtSz*0.8;  {..to make the cylinder more slender}
  A_P_B(xA,yA,xB,yB, Lmin, xQ,yQ);
  Cylinder(xA,yA, xQ,yQ);
  Piston(xQ,yQ, xB,yB);
  JtSz:=JtSz*1.25;
END; {.. CylPiston}

{----------------------------------------------------------------------------}
procedure LCylLPiston(xA,yA, xA0,yA0, xP,yP, xQ,yQ, xC0,yC0, xC,yC:double);

var C0C:double;

BEGIN
  C0C:=Dist2Pts2D(xC0,yC0, xC,yC);
  if (C0C > JtSz) then BEGIN
    A_P_B(xC,yC, xC0,yC0, JtSz, xC,yC);
    LPiston(xP,yP, xC0,yC0, xC,yC);
  END
  else BEGIN
    A_P_B(xC0,yC0, xP,yP, Sqrt(JtSz*JtSz-C0C*C0C), xC,yC);
    Piston(xP,yP, xC,yC);
  END;
  Cylinder(xA0,yA0, xQ,yQ);
  SkLine(xA,yA, xA0,yA0, JtSz, 0);

END; {.. LCylLPiston}

{----------------------------------------------------------------------------}
procedure SetPowerScrew(Diameter,Pitch:double);
BEGIN
  if (Diameter < 0.0) then Diameter:=InfD;
  if (Pitch    < 0.0) then Pitch   :=InfD;

  if (Diameter > 1.0) then Diameter:=2.0;
  if (Pitch    > 4.0) then Pitch   :=6.0;
  ScrewDiam :=2*Diameter*JtSz;
  ScrewPitch:=Pitch*JtSz;
END;

{----------------------------------------------------------------------------}
procedure ReSetPowerScrew;
BEGIN
  ScrewDiam :=InfD;
  ScrewPitch:=InfD;
END;

{----------------------------------------------------------------------------}
procedure LScrew(xA,yA,xB,yB,xC,yC, Theta0, JtSzA:double);
{Draw line AC offset by JtSzA that extends with a helix from C to  B  }
{xA,yA,xB,yB,xC,yC are in screen coordinates                          }

var BC,Theta,x,y,xP,yP,sA,cA: double;
    j,nPts:Integer;

BEGIN
  A_P_B(xA,yA,xB,yB, JtSzA, xA,yA);

  BC:=Dist2pts2D(xB,yB,xC,yC);
  sA:=-(xC-xB)/BC;    cA:=(yC-yB)/BC;

  ExpectDXFplines;
  MoveTo(RoundInt(xA),RoundInt(yA));
  AddVertexPline('',p_X121(xA),p_Y121(yA));
  LineTo(RoundInt(xB),RoundInt(yB));
  AddVertexPline('',p_X121(xB),p_Y121(yB));

  nPts:=Round(BC/ScrewPitch*36);
  for j:=0 to nPts do BEGIN
    Theta:=2.0*Pi/36*j;
    xP:=0.5*ScrewDiam*(sin(Theta)*sin(Theta0)+cos(Theta)*cos(Theta0));
    yP:=ScrewPitch*Theta/(2.0*Pi);
    x:=xB + xP*cA - yP*sA;
    y:=yB + xP*sA + yP*cA;
    AddVertexPline('',p_X121(x),p_Y121(y));
    LineTo(RoundInt(x),RoundInt(y));
  END;

  DXFplineEnd('');

END; {.. LScrew}

{============================================================================}
{============================================================================}
BEGIN
  MecTitle:='';
  MecFooter:='';
  EraseAll('*.$$D');   {..Erase all .$2D leftover files                      }
  EraseAll('*.$2D');   {..Erase all .$2D leftover files                      }
  JtSz:=5;             {..default joint size - see SetJointSize              }
  OpaqueJoints:=FALSE; {..TRUE it hides lines of joints                      }
  SimpleJoint:=FALSE;  {..default joint appearence - see SetJointSize        }
  BumpPiston :=FALSE;  {..linear-motor pistons will not bump their cylinders }
  MecOut:=FALSE;       {..Turns back to FALSE after writing loci to DXF file }
  LastNrLayer:=0;  {..indexed by NewFrame. Layer 0 is not animated by M3D.LSP}
  XminWS:=InfD;  XmaxWS:=-InfD;   {..horizontal workspace limits             }
  YminWS:=InfD;  YmaxWS:=-InfD;   {..vertical workspace limits               }
  LminCylPist:=0;      {..retains the shortest Cylinder+Piston in CylPiston  }
  ScrewDiam :=InfD;
  ScrewPitch:=InfD;
END. {.. LibMec2D}
