unit LibMecIn;
{ $R+ }
{ $S- }
{=============================================================================
  Actuators to work with Assur group kinematic subroutines
  (c) P.A. Simionescu 2018
=============================================================================}

INTERFACE

uses CRT,DOS,Graph,
     LibMec2D,
     LibMath,
     LibDXF,
     LibGraph;

procedure Crank(Color:Integer; xP,yP,vxP,vyP,axP,ayP, xA,yA,vxA,vyA,axA,ayA,
          Phi,dPhi,ddPhi,AB:double; var xB,yB,vxB,vyB,axB,ayB:double);

procedure gCrank(Color:Integer; xA,yA,Phi,dPhi,ddPhi,AB:double;
          var xB,yB,vxB,vyB,axB,ayB:double);

procedure Slider(Color:Integer; xP,yP,vxP,vyP,axP,ayP, xQ,yQ,vxQ,vyQ,axQ,ayQ,
          AB, s,ds,dds:double;
          var xB,yB,vxB,vyB,axB,ayB, xA,yA,vxA,vyA,axA,ayA:double);

procedure gSlider(Color:Integer; xP,yP,xQ,yQ, AB, s,ds,dds:double;
          var xB,yB,vxB,vyB,axB,ayB, xA,yA,vxA,vyA,axA,ayA:double);

procedure RRRR(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xD,yD,vxD,vyD,axD,ayD,
          AB,BC,CD, ThB,dThB,ddThB:double;  ACD:shortint;
          var xB,yB,vxB,vyB,axB,ayB, xC,yC,vxC,vyC,axC,ayC, Delta:double);

procedure RTRTRc(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A, A0Q1, P1C, B0B,B0Q2,P2C, s1,ds1,dds1, s2,ds2,dds2:double;
          LftRgt:shortint; var xC,yC,vxC,vyC,axC,ayC, Delta:double);

procedure RTRTR(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A, A0Q1, P1C, B0B,B0Q2,P2C, s1,ds1,dds1, s2,ds2,dds2:double;
          LftRgt:shortint; var xC,yC,vxC,vyC,axC,ayC, Delta:double);

procedure RTRRc(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A,A0Q,PC,BC, s,ds,dds:double; LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);

procedure RTRR(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A,A0Q,PC,BC, s,ds,dds:double;  LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);


procedure RT_R_TRc(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A,A0Q1,P1C1,C1C,  B0B,B0Q2,P2C2,C2C,
          s1,ds1,dds1, s2,ds2,dds2:double; LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);

procedure RT_R_TR(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A,A0Q1,P1C1,C1C,  B0B,B0Q2,P2C2,C2C,
          s1,ds1,dds1, s2,ds2,dds2:double; LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);

procedure GetA0(var x_A0,y_A0: double);
procedure GetB0(var x_B0,y_B0: double);

procedure GetP(var x_P,y_P: double);
procedure GetQ(var x_Q,y_Q: double);

procedure GetC1(var x_C1,y_C1: double);
procedure GetC2(var x_C2,y_C2: double);

procedure GetP1(var x_P1,y_P1: double);
procedure GetP2(var x_P2,y_P2: double);

procedure GetQ1(var x_Q1,y_Q1: double);
procedure GetQ2(var x_Q2,y_Q2: double);

{============================================================================}

IMPLEMENTATION

uses  LibGe2D;

var OldD_X_F: Boolean;
    Delta_,
    xA0,yA0, xB0,yB0, xC1,yC1, xC2,yC2,
    xP1,yP1, xQ1,yQ1, xP2,yP2, xQ2,yQ2,
    xP,yP, xQ,yQ: double;

{----------------------------------------------------------------------------}
procedure Crank(Color:Integer; xP,yP,vxP,vyP,axP,ayP, xA,yA,vxA,vyA,axA,ayA,
          Phi,dPhi,ddPhi, AB:double; var xB,yB,vxB,vyB,axB,ayB:double);
{ Kinematics of an input member crank AB jointed to a mobile member PA.      }

var ABcosPhTh,ABsinPhTh, Theta,dTheta,ddTheta, xBB,yBB:double;

BEGIN {Crank..}

  Theta:=Atan2(yA-yP,xA-xP);
  AngPVA(xP,yP,vxP,vyP,axP,ayP, xA,yA,vxA,vyA,axA,ayA, Theta,dTheta,ddTheta);

  ABcosPhTh:=AB*cos(Phi+Theta);
  ABsinPhTh:=AB*sin(Phi+Theta);

  xBB:=xA+ABcosPhTh;
  yBB:=yA+ABsinPhTh;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen and to DXF}
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
    SetColorBGI_DXF(Abs(Color));
    Motor(X_p(xA),Y_p(yA),Atan2(yA-yP,xA-xP));
    if (Color > 0) then SkLine(X_p(xA),Y_p(yA),X_p(xBB),Y_p(yBB),JtSz,0);

    UpdateLimitsWS(xP,yP);
    UpdateLimitsWS(xA,yA);
    UpdateLimitsWS(xBB,yBB);
  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  xB:=xBB;    yB:=yBB;
  vxB:=InfD;  vyB:=InfD;

  if (dTheta > InfR) then Exit;  {no interest in vxB,vyB,axB,ayB..}
  vxB:=vxA-ABsinPhTh*(dPhi+dTheta);
  vyB:=vyA+ABcosPhTh*(dPhi+dTheta);

  axB:=InfD;  ayB:=InfD;
  if (ddTheta > InfR) then Exit;  {no interest in axB,ayB..}
  axB:=axA-ABcosPhTh*Sqr(dPhi+dTheta)-ABsinPhTh*(ddPhi+ddTheta);
  ayB:=ayA-ABsinPhTh*Sqr(dPhi+dTheta)+ABcosPhTh*(ddPhi+ddTheta);

END; {..Crank}

{----------------------------------------------------------------------------}
procedure gCrank(Color:Integer; xA,yA, Phi,dPhi,ddPhi, AB:double;
          var xB,yB,vxB,vyB,axB,ayB:double);
{ Solve the kinematics of an input member crank jointed to the ground        }

var ABcosPhi,ABsinPhi,xBB,yBB:double;

BEGIN {gCrank..}

  ABcosPhi:=AB*cos(Phi);
  ABsinPhi:=AB*sin(Phi);

  xBB:=xA+ABcosPhi;
  yBB:=yA+ABsinPhi;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen..}
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
    SetColorBGI_DXF(Abs(Color));
    gMotor(X_p(xA),Y_p(yA));
    if (Color > 0) then SkLine(X_p(xA),Y_p(yA),X_p(xBB),Y_p(yBB),JtSz,0);

    UpdateLimitsWS(xA,yA);
    UpdateLimitsWS(xBB,yBB);
  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  xB:=xBB;  yB:=yBB;

  vxB:=InfD;  vyB:=InfD;
  if (dPhi > InfR) then Exit; {no interest in vxB,vyB and axB,ayB..}
  vxB:=-ABsinPhi*dPhi;
  vyB:= ABcosPhi*dPhi;

  axB:=InfD;  ayB:=InfD;
  if (ddPhi > InfR) then Exit; {no interest in axB,ayB..}
  axB:=-ABcosPhi*Sqr(dPhi) - ABsinPhi*ddPhi;
  ayB:=-ABsinPhi*Sqr(dPhi) + ABcosPhi*ddPhi;

END; {..gCrank}

{----------------------------------------------------------------------------}
procedure Slider(Color:Integer; xP,yP,vxP,vyP,axP,ayP, xQ,yQ,vxQ,vyQ,axQ,ayQ,
 AB, s,ds,dds:double; var xB,yB,vxB,vyB,axB,ayB, xA,yA,vxA,vyA,axA,ayA:double);
{Solve the kinematics of a mobile sliding actuator. P and Q cannot coincide! }
{If (PQ > 5*JtSz) AND (AB > 5*JtSz) draw a piston inside a cylinder.         }
{If (PQ < 5*JtSz) OR  (AB > 5*JtSz) draw line PQ and a slider at (xA,yA).    }

var PQ, Theta,cTheta,sTheta,dTheta,ddTheta,
    xAA,yAA,xBB,yBB, x,y, ScrewTh0: double;

BEGIN {Slider..}

  PQ:=Sqrt(Sqr(xQ-xP)+Sqr(yQ-yP));
  if (PQ < EpsR) then Exit;  {..points P and Q cannot coincide}

  Theta:=0.0;
  AngPVA(xP,yP,vxP,vyP,axP,ayP, xQ,yQ,vxQ,vyQ,axQ,ayQ, Theta,dTheta,ddTheta);

  cTheta:=(xQ-xP)/PQ;
  sTheta:=(yQ-yP)/PQ;

  xBB:=xP + s*cTheta;
  yBB:=yP + s*sTheta;

  xAA:=xP + (s-AB)*cTheta;
  yAA:=yP + (s-AB)*sTheta;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen..}
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
    SetColorBGI_DXF(Abs(Color));
    if (R_p121(AB) < 5*JtSz) then BEGIN {draw line + Block ..}
      if (Color > 0) then PD_line('',X_p(xP),Y_p(yP),X_p(xQ),Y_p(yQ));
      Block(X_p(xBB),Y_p(yBB), Atan2(sTheta,cTheta));
    END
    else BEGIN {draw screw and block OR cylinder + piston ..}
      if (ScrewDiam < InfD) AND (ScrewPitch < InfD) then BEGIN
        ScrewTh0:=2*Pi*R_p121(Dist2pts2D(xP,yP,xAA,yAA))/ScrewPitch;
        x:=xP+(PQ+AB)*cTheta;
        y:=yP+(PQ+AB)*sTheta;
        LScrew(X_p(xP),Y_p(yP),X_p(xP),Y_p(yP),X_p(x),Y_p(y),ScrewTh0,JtSz);
        Block(X_p(xBB),Y_p(yBB), Atan2(sTheta,cTheta));
      END
      else BEGIN
        Cylinder(X_p(xP),Y_p(yP),X_p(xQ),Y_p(yQ));
        Piston(X_p(xAA),Y_p(yAA),X_p(xBB),Y_p(yBB));
      END;
    END;

    UpdateLimitsWS(xP,yP);
    UpdateLimitsWS(xQ,yQ);
    UpdateLimitsWS(xAA,yAA);
    UpdateLimitsWS(xBB,yBB);
  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  xA:=xAA;  yA:=yAA;
  xB:=xBB;  yB:=yBB;

  vxA:=InfD;  vyA:=InfD;
  vxB:=InfD;  vyB:=InfD;
  if (ds > InfR) then Exit; {no interest in vxB,vyB,axB,ayB..}
  vxB:=vxP+ds*cTheta-(yB-yP)*dTheta;
  vyB:=vyP+ds*sTheta+(xB-xP)*dTheta;
  vxA:=vxP+ds*cTheta-(yA-yP)*dTheta;
  vyA:=vyP+ds*sTheta+(xA-xP)*dTheta;

  axA:=InfD;  ayA:=InfD;
  axB:=InfD;  ayB:=InfD;
  if (dds > InfR) then Exit; {no interest in axB,ayB..}
  axB:=axP+dds*cTheta-ds*sTheta*dTheta-(vyB-vyP)*dTheta-(yB-yP)*ddTheta;
  ayB:=ayP+dds*sTheta+ds*cTheta*dTheta+(vxB-vxP)*dTheta+(xB-xP)*ddTheta;
  axA:=axP+dds*cTheta-ds*sTheta*dTheta-(vyA-vyP)*dTheta-(yA-yP)*ddTheta;
  ayA:=ayP+dds*sTheta+ds*cTheta*dTheta+(vxA-vxP)*dTheta+(xA-xP)*ddTheta;

END; {..Slider}

{----------------------------------------------------------------------------}
procedure gSlider(Color:Integer; xP,yP,xQ,yQ, AB, s,ds,dds:double;
          var xB,yB,vxB,vyB,axB,ayB, xA,yA,vxA,vyA,axA,ayA:double);
{Solve the kinematics of a grounded linear actuator.                         }
{If P and Q coincide it assumes the sliding axis to be horizontal.           }
{If (PQ > 5*JtSz) AND (AB > 5*JtSz) it draws a piston inside a cylinder.     }
{If (PQ < 5*JtSz) OR  (AB > 5*JtSz) it draws a slider block at (xB,yB).      }

var  PQ, cTheta,sTheta, xAA,yAA, xBB,yBB, x,y, ScrewTh0:double;

BEGIN  {gSlider..}

  PQ:=Sqrt(Sqr(xQ-xP)+Sqr(yQ-yP));
  if (PQ < EpsR) then BEGIN
    cTheta:=1.0;  sTheta:=0.0;
  END
  else BEGIN
    cTheta:=(xQ-xP)/PQ;
    sTheta:=(yQ-yP)/PQ;
  END;
  xBB:=xP+s*cTheta;
  yBB:=yP+s*sTheta;

  xAA:=xP+(s-AB)*cTheta;
  yAA:=yP+(s-AB)*sTheta;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
    SetColorBGI_DXF(Abs(Color));
    if (R_p121(PQ) < 5*JtSz) OR (R_p121(AB) < 5*JtSz) then BEGIN {draw line + Block}
      OldD_X_F:=D_X_F;
      if (LastNrLayer > 1) then SuspendDXF; {..1st frame has already been generated}
      PDlinePtAng('Ground',X_p(xP),Y_p(yP),Atan2(sTheta,cTheta));
      if OldD_X_F then ResumeDXF;
      Block(X_p(xBB),Y_p(yBB), Atan2(sTheta,cTheta));
    END
    else BEGIN {draw cylinder + piston ..}
      if (Color > 0) then BEGIN
        if (ScrewDiam < InfD) AND (ScrewPitch < InfD) then BEGIN
          ScrewTh0:=2*Pi*R_p121(Dist2pts2D(xP,yP,xAA,yAA))/ScrewPitch;
          x:=xP+(PQ+AB)*cTheta;
          y:=yP+(PQ+AB)*sTheta;
          LScrew(X_p(xP),Y_p(yP),X_p(xP),Y_p(yP),X_p(x),Y_p(y),ScrewTh0,JtSz);
          Block(X_p(xBB),Y_p(yBB), Atan2(sTheta,cTheta));
        END
        else BEGIN
          gCylinder(X_p(xP),Y_p(yP), X_p(xQ),Y_p(yQ));
          Piston(X_p(xAA),Y_p(yAA), X_p(xBB),Y_p(yBB));
        END;
      END
      else BEGIN
        SkLine(X_p(xAA),Y_p(yAA),X_p(xBB),Y_p(yBB),JtSz,JtSz);
        gBlock(X_p(0.5*(xP+xQ)),Y_p(0.5*(yP+yQ)), Atan2(sTheta,cTheta));
     END;
    END;

    UpdateLimitsWS(xP,yP);
    UpdateLimitsWS(xQ,yQ);
    UpdateLimitsWS(xBB,yBB);
    UpdateLimitsWS(xAA,yAA);
  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  xA:=xAA;  yA:=yAA;
  xB:=xBB;  yB:=yBB;

  vxA:=InfD;  vyA:=InfD;
  vxB:=InfD;  vyB:=InfD;
  if (ds > InfR) then Exit;  {no interest in vxB,vyB and axB,ayB..}
  vxB:=ds*cTheta;  vyB:=ds*sTheta;
  vxA:=vxB;        vyA:=vyB;

  axA:=InfD;  ayA:=InfD;
  axB:=InfD;  ayB:=InfD;
  if (dds > InfR) then Exit; {no interest in axB,ayB..}
  axB:=dds*cTheta;  ayB:=dds*sTheta;
  axA:=axB;         ayA:=ayB;
END; {..gSlider}

{----------------------------------------------------------------------------}
procedure RRRR(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xD,yD,vxD,vyD,axD,ayD,
          AB,BC,CD, ThB,dThB,ddThB:double; ACD:shortint;
          var xB,yB,vxB,vyB,axB,ayB, xC,yC,vxC,vyC,axC,ayC, Delta:double);
{Solve the kinematics of a four-bar ABCD powered floating joint B           }

var Delta_, cThB,sThB, AC,dAC,ddAC,
    xBB,yBB, vxBB,vyBB, axBB,ayBB, xCC,yCC, vxCC,vyCC, axCC,ayCC: double;
    DashABC, OK: Boolean;

BEGIN {RRRR ..}

  cThB:=cos(ThB);
  sThB:=sin(ThB);

  AC:=Sqrt(AB*AB + BC*BC + 2*AB*BC*cThB);

  if (dThB < InfR) then dAC:=-AB*BC/AC*sThB*dThB else dAC:=InfD;

  if (ddThB < InfR) then ddAC:=-AB*BC/AC*(cThB*dThB*dThB+sThB*ddThB) else ddAC:=InfD;

  Int2CirPVA(xA,yA,vxA,vyA,axA,ayA, xD,yD,vxD,vyD,axD,ayD,
  AC,dAC,ddAC, CD,0,0, ACD, xCC,yCC, vxCC,vyCC, axCC,ayCC, Delta_);

  if (Delta <> InfD) then Delta:=Delta_;

  if (Delta_ >= 0) then  BEGIN
    DashABC:=FALSE;
    Int2CirPVA(xA,yA,vxA,vyA,axA,ayA, xCC,yCC,vxCC,vyCC,axCC,ayCC,
    AB,0,0, BC,0,0, Sgn(sThB), xBB,yBB, vxBB,vyBB, axBB,ayBB, Delta_);
  END
  else BEGIN
    DashABC:=TRUE;
    xBB:=xA+(xCC-xA)*AB/(AB+BC);
    yBB:=yA+(yCC-yA)*AB/(AB+BC);
  END;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Abs(Color));
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    Motor(X_p(xBB),Y_p(yBB),Atan2(yBB-yA,xBB-xA)); {.. motor at B}
    PDcircle('',X_p(xCC),Y_p(yCC),JtSz);  {.. pivot joint at C}

    if (JtSz > 0) then BEGIN
      if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
        gPivotJoint(X_p(xA),Y_p(yA)) {..ground pivot joint at A}
      else
        PDcircle('',X_p(xA),Y_p(yA),JtSz); {..pivot joint at A}

      if (vxD=0) AND (vyD=0) AND (axD=0) AND (ayD=0) then
        gPivotJoint(X_p(xD),Y_p(yD)) {..ground pivot joint at D}
      else
        PDcircle('',X_p(xD),Y_p(yD),JtSz); {..pivot joint at D}
    END;

    if DashABC then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    if (Color > 0) OR DashABC then BEGIN
      SkLine(X_p(xA),Y_p(yA),X_p(xBB),Y_p(yBB),JtSz,1.6*JtSz);
      SkLine(X_p(xBB),Y_p(yBB),X_p(xCC),Y_p(yCC),JtSz,JtSz);
    END;
    SetLineStyle(SolidLn, 0, NormWidth);   SyncDXFLineStyleTkns;
    SkLine(X_p(xD),Y_p(yD),X_p(xCC),Y_p(yCC),JtSz,JtSz);

    UpdateLimitsWS(xA,yA);
    UpdateLimitsWS(xD,yD);
    UpdateLimitsWS(xCC,yCC);
    UpdateLimitsWS(xBB,yBB);
  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  xB:=xBB;   yB:=yBB;
  xC:=xCC;   yC:=yCC;

  vxB:=InfD;  vyB:=InfD;
  vxC:=InfD;  vyC:=InfD;
  axB:=InfD;  ayB:=InfD;
  axC:=InfD;  ayC:=InfD;

  if DashABC then Exit;

  if (dThB > InfR) OR (vxA > InfR) OR (vyA > InfR) OR
  (vxD > InfR) OR (vyD > InfR) then Exit; {..no interest in vel. & accel.}
  vxB:=vxBB;  vyB:=vyBB;
  vxC:=vxCC;  vyC:=vyCC;

  if (ddThB > InfR) OR  (axA > InfR) OR (ayA > InfR) OR
  (axD > InfR) OR (ayD > InfR) then Exit; {..no interest in accelerations}
  axB:=axBB;  ayB:=ayBB;
  axC:=axCC;  ayC:=ayCC;

END; {.. RRRR}

{----------------------------------------------------------------------------}
procedure RTRTRc(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A, A0Q1, P1C, B0B,B0Q2,P2C, s1,ds1,dds1, s2,ds2,dds2:double;
          LftRgt:shortint; var xC,yC,vxC,vyC,axC,ayC, Delta:double);
{ Solves the kinematics of the RTRTR chain using equations of constraint.   }

var DashPist1,DashPist2: Boolean;
    r1,dr1,ddr1, r2,dr2,ddr2: double;

BEGIN  {RTRTRc..}

  DashPist1:=FALSE;
  DashPist2:=FALSE;

  if (s1 < 0.0) then BEGIN {joint C bottoms cylinder 1}
    s1:=EpsR;
    if (ds1  <> InfD) then ds1 :=0;
    if (dds1 <> InfD) then dds1:=0;
    DashPist1:=TRUE;
  END;
  if (s2 <= 0.0) then BEGIN {joint C bottoms cylinder 2}
    s2:=EpsR;
    if (ds2  <> InfD) then ds2 :=0;
    if (dds2 <> InfD) then dds2:=0;
    DashPist2:=TRUE;
  END;

  if BumpPiston then BEGIN
    if (s1 > A0Q1+P1C) then BEGIN {piston 1 exits cylinder}
      s1:=A0Q1+P1C;
      if (ds1  <> InfD) then ds1 :=0;
      if (dds1 <> InfD) then dds1:=0;
      DashPist1:=TRUE;
    END;
    if (R_p121(P1C) > 5*JtSz) AND (s1 < Max2(P1C,A0Q1)) then BEGIN
      {do not allow P1 beyound A0 or C inside the cylinder}
      s1:=Max2(P1C,A0Q1);
      if (ds1  <> InfD) then ds1 :=0;
      if (dds1 <> InfD) then dds1:=0;
      DashPist1:=TRUE;
    END;

    if (s2 > B0Q2+P2C) then BEGIN {piston 2 exits cylinder}
      s2:=B0Q2+P2C;
      if (ds2  <> InfD) then ds2 :=0;
      if (dds2 <> InfD) then dds2:=0;
      DashPist2:=TRUE;
    END;
    if (R_p121(P2C) > 5*JtSz) AND (s2 < Max2(P2C,B0Q2)) then BEGIN
      {do not allow P1 beyound A0 or C inside the cylinder}
      s2:=Max2(P2C,B0Q2);
      if (ds2  <> InfD) then ds2 :=0;
      if (dds2 <> InfD) then dds2:=0;
      DashPist2:=TRUE;
    END;
  END;

  r1:=Sqrt(Sqr(A0A)+Sqr(s1));
  if ds1  > InfR then dr1:=InfD else dr1:=s1*ds1/r1;
  if dds1 > InfR then ddr1:=InfD else ddr1:=(ds1*ds1+s1*dds1-dr1*dr1)/r1;

  r2:=Sqrt(Sqr(B0B)+Sqr(s2));
  if ds2  > InfR then dr2:=InfD else dr2:=s2*ds2/r2;
  if dds2 > InfR then ddr2:=InfD else ddr2:=(ds2*ds2+s2*dds2-dr2*dr2)/r2;

  Delta_:=0.0;
  Int2CirPVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB
  ,r1,dr1,ddr1, r2,dr2,ddr2, LftRgt, xC,yC,vxC,vyC,axC,ayC, Delta_);

  if (Delta <> InfD) then Delta:=Delta_; {there is interest in Delta}

  if (Delta_ < 0) then BEGIN
    DashPist1:=TRUE;
    DashPist2:=TRUE;
  END;

  Int2Cir(xA,yA, xC,yC, A0A,s1, sgn(A0A), xA0,yA0, Delta_);

  if (s1 = EpsR) then BEGIN
    xQ1:=xA0;  YQ1:=YA0;
    xP1:=xC;   YP1:=yC;
  END
  else BEGIN
    xQ1:=xA0+A0Q1/s1*(xC-xA0);
    YQ1:=YA0+A0Q1/s1*(YC-YA0);
    xP1:=xC - P1C/s1*(xC-xA0);
    YP1:=yC - P1C/s1*(yC-yA0);
  END;

  Int2Cir(xB,yB, xC,yC, B0B,s2, sgn(B0B), xB0,yB0, Delta_);
  if (s2 = EpsR) then BEGIN
    xQ2:=xA0;  YQ2:=YA0;
    xP2:=xC;   YP2:=yC;
  END
  else BEGIN
    xQ2:=xB0+B0Q2/s2*(xC-xB0);
    YQ2:=yB0+B0Q2/s2*(yC-YB0);
    xP2:=xC - P2C/s2*(xC-xB0);
    YP2:=yC - P2C/s2*(yC-yB0);
  END;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen..}
    SetColorBGI_DXF(Color);
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if DashPist1 then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    if (R_p121(P1C) < 5*JtSz) then BEGIN  {draw line + Block #1..}
      LLine(X_p(xA),Y_p(yA),X_p(xA0),Y_p(yA0),X_p(xQ1),Y_p(yQ1),JtSz,0);
      Block(X_p(xC),Y_p(yC), Atan2((yC-yA0)/s1,(xC-xA0)/s1));
    END
    else {draw cylinder + piston #1..}
     LCylPiston(X_p(xA),Y_p(yA), X_p(xA0),Y_p(yA0)
     ,X_p(xP1),Y_p(yP1),X_p(xQ1),Y_p(yQ1), X_p(xC),Y_p(yC));

    if OpaqueJoints then IncDXFelev;

    if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA)) {ground pivot joint at A}
    else
      PDcircle('',X_p(xA),Y_p(yA),JtSz); {pivot joint at A}

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if DashPist2 then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    if (R_p121(P2C) < 5*JtSz) then BEGIN  {draw line + Block..}
      LLine(X_p(xB),Y_p(yB),X_p(xB0),Y_p(yB0),X_p(xQ2),Y_p(yQ2),JtSz,0);
      Block(X_p(xC),Y_p(yC), Atan2((yC-yB0)/s2,(xC-xB0)/s2));
    END
    else {draw cylinder + piston..}
      LCylPiston(X_p(xB),Y_p(yB), X_p(xB0),Y_p(yB0)
      ,X_p(xP2),Y_p(yP2),X_p(xQ2),Y_p(yQ2), X_p(xC),Y_p(yC));

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if OpaqueJoints then IncDXFelev;

    PDcircle('',X_p(xC),Y_p(yC),JtSz);  {pivot joint at C}

    if (vxB = 0) AND (vyB = 0) AND (axB = 0) AND (ayB = 0) then
      gPivotJoint(X_p(xB),Y_p(yB)) {ground pivot joint at B}
    else
      PDcircle('',X_p(xB),Y_p(yB),JtSz); {pivot joint at B}

    if OpaqueJoints then BEGIN
      DecDXFelev;
      DecDXFelev;
    END;

    UpdateLimitsWS(xA,yA);
    UpdateLimitsWS(xB,yB);
  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}

END; {..RTRTRc}

{----------------------------------------------------------------------------}
procedure RTRTR(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A, A0Q1, P1C, B0B,B0Q2,P2C, s1,ds1,dds1, s2,ds2,dds2:double;
          LftRgt:shortint; var xC,yC,vxC,vyC,axC,ayC, Delta:double);

{ Solves the kinematics of the RTRTR chain using vector loop method }

var DashPist1,DashPist2, OK: Boolean;
    AC,BC, Psi1,Psi2, a1,b1,c1, a2,b2,c2,
    Theta,cTh1,sTh1, cTh2,sTh2, dTh1,ddTh1, dTh2,ddTh2: double;

BEGIN {RTRR..}

  DashPist1:=FALSE;
  DashPist2:=FALSE;

  if (s1 < 0.0) then BEGIN {..joint C bottoms cylinder 1}
    s1:=EpsR;
    if (ds1  <> InfD) then ds1 :=0;
    if (dds1 <> InfD) then dds1:=0;
    DashPist1:=TRUE;
  END;
  if (s2 <= 0.0) then BEGIN {..joint C bottoms cylinder 2}
    s2:=EpsR;
    if (ds2  <> InfD) then ds2 :=0;
    if (dds2 <> InfD) then dds2:=0;
    DashPist2:=TRUE;
  END;

  if BumpPiston then BEGIN
    if (s1 > A0Q1+P1C) then BEGIN {piston 1 exits cylinder}
      s1:=A0Q1+P1C;
      if (ds1  <> InfD) then ds1 :=0;
      if (dds1 <> InfD) then dds1:=0;
      DashPist1:=TRUE;
    END;
    if (R_p121(P1C) > 5*JtSz) AND (s1 < Max2(P1C,A0Q1)) then BEGIN
      {do not allow P1 beyound A0 or allow C inside the cylinder}
      s1:=Max2(P1C,A0Q1);
      if (ds1  <> InfD) then ds1 :=0;
      if (dds1 <> InfD) then dds1:=0;
      DashPist1:=TRUE;
    END;

    if (s2 > B0Q2+P2C) then BEGIN {piston 2 exits cylinder}
      s2:=B0Q2+P2C;
      if (ds2  <> InfD) then ds2 :=0;
      if (dds2 <> InfD) then dds2:=0;
      DashPist2:=TRUE;
    END;
    if (R_p121(P2C) > 5*JtSz) AND (s2 < Max2(P2C,B0Q2)) then BEGIN
      {do not allow P2 beyound B0, or allow C inside the cylinder}
      s2:=Max2(P2C,B0Q2);
      if (ds2  <> InfD) then ds2 :=0;
      if (dds2 <> InfD) then dds2:=0;
      DashPist2:=TRUE;
    END;
  END; {..if BumpPiston}

  AC:=Sqrt(Sqr(A0A)+Sqr(s1));
  BC:=Sqrt(Sqr(B0B)+Sqr(s2));

  a1:=2*AC*(xB-xA);
  b1:=2*AC*(yB-yA);
  c1:=AC*AC-BC*BC+Sqr(xB-xA)+Sqr(yB-yA);
  a2:=2*BC*(xB-xA);
  b2:=2*BC*(yB-yA);
  c2:=AC*AC-BC*BC-Sqr(xB-xA)-Sqr(yB-yA);
  Delta_:=a1*a1+b1*b1-c1*c1;
  if (Delta <> InfD) then Delta:=Delta_; {there is interest in Delta}
  if (Delta_ < 0) then BEGIN
    Delta_:=0;
    DashPist1:=TRUE;
    DashPist2:=TRUE;
  END;
  Psi1:=Atan2(b1,a1)-LftRgt*Atan2(Sqrt(Delta_),c1);
  Psi2:=Atan2(b2,a2)-LftRgt*Atan2(Sqrt(Delta_),c2);

  a1:=s1;    b1:=A0A;  c1:=AC*cos(Psi1);
  a2:=-A0A;  b2:=s1;   c2:=AC*sin(Psi1);
  LinEq2(a1,b1,c1, a2,b2,c2, cTh1, sTh1, OK);
  if NOT OK then DashPist1:=TRUE;

  a1:=s2;    b1:=B0B;  c1:=BC*cos(Psi2);
  a2:=-B0B;  b2:=s2;   c2:=BC*sin(Psi2);
  LinEq2(a1,b1,c1, a2,b2,c2, cTh2, sTh2, OK);
  if NOT OK then DashPist2:=TRUE;

  xA0:=xA+A0A*sTh1;
  yA0:=yA-A0A*cTh1;
  xP1:=xA0+(s1-P1C)*cTh1;
  yP1:=yA0+(s1-P1C)*sTh1;
  xQ1:=xA0+A0Q1*cTh1;
  yQ1:=yA0+A0Q1*sTh1;

  xB0:=xB+B0B*sTh2;
  yB0:=yB-B0B*cTh2;
  xP2:=xB0+(s2-P2C)*cTh2;
  yP2:=yB0+(s2-P2C)*sTh2;
  xQ2:=xB0+B0Q2*cTh2;
  yQ2:=yB0+B0Q2*sTh2;

  xC:=0.5*((xA0+s1*cTh1)+(xB0+s2*cTh2));
  yC:=0.5*((yA0+s1*sTh1)+(yB0+s2*sTh2));

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen..}
    SetColorBGI_DXF(Color);

    if DashPist1 then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    if (R_p121(P1C) < 5*JtSz) AND (s1 <> 0.0) then BEGIN  {draw line + Block #1..}
      LLine(X_p(xA),Y_p(yA),X_p(xA0),Y_p(yA0),X_p(xQ1),Y_p(yQ1),JtSz,0);
      Block(X_p(xC),Y_p(yC), Atan2((yC-yA0)/s1,(xC-xA0)/s1));
    END
    else {draw cylinder + piston #1..}
      LCylPiston(X_p(xA),Y_p(yA), X_p(xA0),Y_p(yA0)
      ,X_p(xP1),Y_p(yP1),X_p(xQ1),Y_p(yQ1), X_p(xC),Y_p(yC));

    if OpaqueJoints then IncDXFelev;

    if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA)) {ground pivot joint at A}
    else
      PDcircle('',X_p(xA),Y_p(yA),JtSz); {pivot joint at A}

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if DashPist2 then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    if (R_p121(P2C) < 5*JtSz) AND (s2 <> 0.0) then BEGIN  {draw line + Block..}
      LLine(X_p(xB),Y_p(yB),X_p(xB0),Y_p(yB0),X_p(xQ2),Y_p(yQ2),JtSz,0);
      Block(X_p(xC),Y_p(yC), Atan2((yC-yB0)/s2,(xC-xB0)/s2));
    END
    else {draw cylinder + piston..}
      LCylPiston(X_p(xB),Y_p(yB), X_p(xB0),Y_p(yB0)
      ,X_p(xP2),Y_p(yP2),X_p(xQ2),Y_p(yQ2), X_p(xC),Y_p(yC));

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if OpaqueJoints then IncDXFelev;

    PDcircle('',X_p(xC),Y_p(yC),JtSz);  {pivot joint at C}

    if (vxB = 0) AND (vyB = 0) AND (axB = 0) AND (ayB = 0) then
      gPivotJoint(X_p(xB),Y_p(yB)) {ground pivot joint at B}
    else
      PDcircle('',X_p(xB),Y_p(yB),JtSz); {pivot joint at B}

    if OpaqueJoints then BEGIN
      DecDXFelev;
      DecDXFelev;
    END;

    UpdateLimitsWS(xA0,yA0);
    UpdateLimitsWS(xB0,yB0);
    UpdateLimitsWS(xC,yC);
    UpdateLimitsWS(xA,yA);
    UpdateLimitsWS(xB,yB);
  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}

  vxC:=InfD;  vyC:=InfD;
  if (vxA > InfR) OR (vyA > InfR) OR (vxB > InfR) OR (vyB > InfR)
  OR (ds1 > InfR) OR (ds2 > InfR) then Exit; {..no interest in vxC,vyC,axC,ayC}
  a1:=A0A*cTh1-s1*sTh1;
  b1:=s2*sTh2-B0B*cTh2;
  c1:=vxB-vxA-ds1*cTh1+ds2*cTh2;
  a2:=A0A*sTh1+s1*cTh1;
  b2:=-s2*cTh2-B0B*sTh2;
  c2:=vyB-vyA-ds1*sTh1+ds2*sTh2;
  LinEq2(a1,b1,c1, a2,b2,c2, dTh1, dTh2, OK);
  if NOT OK then Exit;
  vxC:=vxA+A0A*cTh1*dTh1+ds1*cTh1-s1*sTh1*dTh1;
  vyC:=vyA+A0A*sTh1*dTh1+ds1*sTh1+s1*cTh1*dTh1;

  axC:=InfD;   ayC:=InfD;
  if (axA > InfR) OR (ayA > InfR) OR (axB > InfR) OR (ayB > InfR)
  OR (dds1 > InfR) OR (dds2 > InfR) then Exit;  {..no interest in axC and ayC}

  c1:=axB-axA-dds1*cTh1+ds1*sTh1*dTh1+dds2*cTh2-ds2*sTh2*dTh2;
  c1:=c1-(-A0A*sTh1*dTh1-ds1*sTh1-s1*cTh1*dTh1)*dTh1;
  c1:=c1-(ds2*sTh2+s2*cTh2*dTh2+B0B*sTh2*dTh2)*dTh2;
  c2:=ayB-ayA-dds1*sTh1-ds1*cTh1*dTh1+dds2*sTh2+ds2*cTh2*dTh2;
  c2:=c2-(A0A*cTh1*dTh1+ds1*cTh1-s1*sTh1*dTh1)*dTh1;
  c2:=c2+(ds2*cTh2-s2*sTh2*dTh2+B0B*cTh2*dTh2)*dTh2;
  LinEq2(a1,b1,c1, a2,b2,c2, ddTh1, ddTh2, OK);
  if NOT OK then Exit;

  axC:=axA-A0A*sTh1*Sqr(dTh1)+A0A*cTh1*ddTh1+dds1*cTh1-ds1*sTh1*dTh1;
  axC:=axC - ds1*sTh1*dTh1-s1*cTh1*Sqr(dTh1)-s1*sTh1*ddTh1;
  ayC:=ayA+A0A*cTh1*Sqr(dTh1)+A0A*sTh1*ddTh1+dds1*sTh1+ds1*cTh1*dTh1;
  ayC:=ayC + ds1*cTh1*dTh1-s1*sTh1*Sqr(dTh1)+s1*cTh1*ddTh1;

END; {..RTRTR}

{----------------------------------------------------------------------------}
procedure RTRRc(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A,A0Q,PC,BC, s,ds,dds:double;  LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);

{ Solves the kinematics of the RTRR chain using equations of constraint }

var DashPist,DashBC,OK:Boolean;      r1,dr1,ddr1:double;

BEGIN  {RTRRc..}

  DashPist:=FALSE;
  DashBC  :=FALSE;

  if (s < 0.0) then BEGIN {joint C bottoms cylinder..}
    s:=0.0;
    if (ds  <> InfD) then ds :=0;
    if (dds <> InfD) then dds:=0;
    DashPist:=TRUE;
  END;
  if BumpPiston AND (s > A0Q+PC) then BEGIN
    s:=A0Q+PC;
    if (ds  <> InfD) then ds :=0;
    if (dds <> InfD) then dds:=0;
    DashPist:=TRUE;
  END;
  if BumpPiston AND (s < Max2(PC,A0Q)) then BEGIN
    s:=Max2(PC,A0Q);
    if (ds  <> InfD) then ds :=0;
    if (dds <> InfD) then dds:=0;
    DashPist:=TRUE;
  END;

  r1:=Sqrt(Sqr(A0A)+Sqr(s));
  if ds  > InfR then  dr1:=InfD else  dr1:=s*ds/r1;
  if dds > InfR then ddr1:=InfD else ddr1:=(ds*ds+s*dds-dr1*dr1)/r1;
  Delta_:=0.0;
  Int2CirPVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  r1,dr1,ddr1, BC,0.0,0.0, LftRgt, xC,yC,vxC,vyC,axC,ayC, Delta_);

  if (Delta <> InfD) then Delta:=Delta_;  {there is interest in Delta}
  if (Delta_ < 0.0) then BEGIN
    DashPist:=TRUE;
    DashBC:=TRUE;
  END;

  Int2Cir(xA,yA,xC,yC, A0A,s, Sgn(A0A), xA0,yA0, Delta);
  xQ:=xA0+A0Q/s*(xC-xA0);
  yQ:=yA0+A0Q/s*(yC-yA0);

  xP:=xC - PC/s*(xC-xA0);
  YP:=yC - PC/s*(yC-yA0);

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen..}
    SetColorBGI_DXF(Abs(Color));

    PDcircle('',X_p(xC),Y_p(yC),JtSz);  {pivot joint at C}

    if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA)) {ground pivot joint at A}
    else
      PDcircle('',X_p(xA),Y_p(yA),JtSz); {pivot joint at A}

    if DashPist then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    LCylPiston(X_p(xA),Y_p(yA), X_p(xA0),Y_p(yA0)
    ,X_p(xP),Y_p(yP),X_p(xQ),Y_p(yQ), X_p(xC),Y_p(yC));

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if (vxB = 0) AND (vyB = 0) AND (axB = 0) AND (ayB = 0) then
      gPivotJoint(X_p(xB),Y_p(yB)) {ground pivot joint at B}
    else
      PDcircle('',X_p(xB),Y_p(yB),JtSz); {pivot joint at B}

    if DashBC then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    SkLine(X_p(xB),Y_p(yB),X_p(xC),Y_p(yC),JtSz,JtSz);

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    UpdateLimitsWS(xA,yA);
    UpdateLimitsWS(xB,yB);
  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}

END; {..RTRRc}

{----------------------------------------------------------------------------}
procedure RTRR(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A,A0Q,PC,BC, s,ds,dds:double;  LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);

{ Solves the kinematics of the RTRR chain using the vector loop method  }

var DashPist, DashBC, OK: Boolean;
    AC, Phi1,Phi2, cPhi2,sPhi2, dPhi2,ddPhi2,
    a1,b1,c1, a2,b2,c2,
    Theta, cTh,sTh, dTh,ddTh, ScrewTh0: double;

BEGIN {RTRR..}

  DashPist:=FALSE;
  DashBC:=FALSE;

  if (s <= 0.0) then BEGIN {joint C bottoms cylinder 1}
    s:=EpsR;
    if (ds  <> InfD) then ds :=0;
    if (dds <> InfD) then dds:=0;
    DashPist:=TRUE;
  END;

  if BumpPiston then BEGIN
    if (s > A0Q+PC) then BEGIN {piston exits cylinder ..}
      s:=A0Q+PC;
      if (ds  <> InfD) then ds :=0;
      if (dds <> InfD) then dds:=0;
      DashPist:=TRUE;
    END;
    if (R_p121(PC) > 5*JtSz) AND (s < Max2(PC,A0Q)) then BEGIN
      {do not allow P1 beyound A0 or C inside the cylinder}
      s:=Max2(PC,A0Q);
      if (ds  <> InfD) then ds :=0;
      if (dds <> InfD) then dds:=0;
      DashPist:=TRUE;
    END;
  END;

  AC:=Sqrt(Sqr(A0A)+Sqr(s));

  a1:=2*AC*(xB-xA);
  b1:=2*AC*(yB-yA);
  c1:=AC*AC-BC*BC+Sqr(xB-xA)+Sqr(yB-yA);
  a2:=2*BC*(xB-xA);
  b2:=2*BC*(yB-yA);
  c2:=AC*AC-BC*BC-Sqr(xB-xA)-Sqr(yB-yA);
  Delta_:=a1*a1+b1*b1-c1*c1;
  if (Delta <> InfD) then Delta:=Delta_; {there is interest in Delta}
  if (Delta_ < 0) then BEGIN
    Delta_:=0;
    DashPist:=TRUE;
    DashBC:=TRUE;
  END;
  Phi1:=Atan2(b1,a1)-LftRgt*Atan2(Sqrt(Delta_),c1);
  Phi2:=Atan2(b2,a2)-LftRgt*Atan2(Sqrt(Delta_),c2);
  cPhi2:=cos(Phi2);
  sPhi2:=sin(Phi2);

  a1:=s;     b1:=A0A;  c1:=AC*cos(Phi1);
  a2:=-A0A;  b2:=s;    c2:=AC*sin(Phi1);
  LinEq2(a1,b1,c1, a2,b2,c2, cTh, sTh, OK);
  if NOT OK then DashPist:=TRUE;

  xA0:=xA+A0A*sTh;
  yA0:=yA-A0A*cTh;
  xP:=xA0+(s-PC)*cTh;
  yP:=yA0+(s-PC)*sTh;
  xQ:=xA0+A0Q*cTh;
  yQ:=yA0+A0Q*sTh;

  xC:=0.5*((xA0+s*cTh)+(xB+BC*cPhi2));
  yC:=0.5*((yA0+s*sTh)+(yB+BC*sPhi2));

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen ..}

    SetColorBGI_DXF(Abs(Color));

    if DashPist then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;

    if (ScrewDiam < InfD) AND (ScrewPitch < InfD) then BEGIN
      ScrewTh0:=2*Pi*R_p121(Dist2pts2D(xA0,yA0,xC,yC))/ScrewPitch;
      LScrew(X_p(xA),Y_p(yA),X_p(xA0),Y_p(yA0),X_p(xQ),Y_p(yQ),ScrewTh0,JtSz);
      Block(X_p(xC),Y_p(yC), Atan2((yC-yA0)/s,(xC-xA0)/s));
    END
    else BEGIN
      if (R_p121(PC) < 5*JtSz) then BEGIN  {draw line + Block #1..}
        LLine(X_p(xA),Y_p(yA),X_p(xA0),Y_p(yA0),X_p(xQ),Y_p(yQ),JtSz,0);
        Block(X_p(xC),Y_p(yC), Atan2((yC-yA0)/s,(xC-xA0)/s));
      END
      else {draw cylinder + piston #1..}
       LCylPiston(X_p(xA),Y_p(yA), X_p(xA0),Y_p(yA0)
       ,X_p(xP),Y_p(yP),X_p(xQ),Y_p(yQ), X_p(xC),Y_p(yC));
    END;

    if OpaqueJoints then IncDXFelev;

    if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA)) {ground pivot joint at A}
    else
      PDcircle('',X_p(xA),Y_p(yA),JtSz); {pivot joint at A}

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if (Color > 0) then BEGIN
      if DashBC then BEGIN
        SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
      END;
      SkLine(X_p(xB),Y_p(yB),X_p(xC),Y_p(yC),JtSz,JtSz);
    END;

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if OpaqueJoints then IncDXFelev;

    PDcircle('',X_p(xC),Y_p(yC),JtSz);  {pivot joint at C}

    if (vxB = 0) AND (vyB = 0) AND (axB = 0) AND (ayB = 0) then
      gPivotJoint(X_p(xB),Y_p(yB)) {ground pivot joint at B}
    else
      PDcircle('',X_p(xB),Y_p(yB),JtSz); {pivot joint at B}

    if OpaqueJoints then BEGIN
      DecDXFelev;
      DecDXFelev;
    END;

    UpdateLimitsWS(xC,yC);
    UpdateLimitsWS(xA0,yA0);
    UpdateLimitsWS(xA,yA);
    UpdateLimitsWS(xB,yB);
  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}

  vxC:=InfD;  vyC:=InfD;
  if (vxA > InfR) OR (vyA > InfR) OR (vxB > InfR) OR (vyB > InfR)
  OR (ds > InfR) then Exit; {..no interest in vxC,vyC,axC,ayC}

  a1:=A0A*cTh-s*sTh; b1:= BC*sPhi2; c1:=vxB-vxA-ds*cTh;
  a2:=A0A*sTh+s*cTh; b2:=-BC*cPhi2; c2:=vyB-vyA-ds*sTh;
  LinEq2(a1,b1,c1, a2,b2,c2, dTh, dPhi2, OK);
  if NOT OK then Exit;

  vxC:=vxA+A0A*cTh*dTh+ds*cTh-s*sTh*dTh;
  vyC:=vyA+A0A*sTh*dTh+ds*sTh+s*cTh*dTh;

  axC:=InfD;  ayC:=InfD;
  if (axA > InfR) OR (ayA > InfR) OR (axB > InfR) OR (ayB > InfR)
  OR (dds > InfR) then Exit; {..no interest in axC and ayC}

  c1:=axB-axA-dds*cTh+ds*sTh*dTh;
  c1:=c1-(-A0A*sTh*dTh-ds*sTh-s*cTh*dTh)*dTh;
  c1:=c1-BC*cPhi2*Sqr(dPhi2);
  c2:=ayB-ayA-dds*sTh-ds*cTh*dTh;
  c2:=c2-(A0A*cTh*dTh+ds*cTh-s*sTh*dTh)*dTh;
  c2:=c2-BC*sPhi2*Sqr(dPhi2);
  LinEq2(a1,b1,c1, a2,b2,c2, ddTh, ddPhi2, OK);  if NOT OK then Exit;

  axC:=axA-A0A*sTh*Sqr(dTh)+A0A*cTh*ddTh+dds*cTh-ds*sTh*dTh;
  axC:=axC-ds*sTh*dTh-s*cTh*Sqr(dTh)-s*sTh*ddTh;
  ayC:=ayA+A0A*cTh*Sqr(dTh)+A0A*sTh*ddTh+dds*sTh+ds*cTh*dTh;
  ayC:=ayC+ds*cTh*dTh-s*sTh*Sqr(dTh)+s*cTh*ddTh;
END; {..RTRR}

{----------------------------------------------------------------------------}
procedure RT_R_TRc(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A,A0Q1,P1C1,C1C,  B0B,B0Q2,P2C2,C2C,
          s1,ds1,dds1, s2,ds2,dds2:double; LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);

{ Solves the kinematics of the RTRTR chain using equations of constraint }

var DashPist1, DashPist2: Boolean;
    r1,dr1,ddr1, r2,dr2,ddr2: double;

BEGIN  {RT_R_TRc..}

  if (s1 < EpsR) then BEGIN  {point C1 bottoms cylinder #1..}
    s1:=EpsR;
    if (ds1  <> InfD) then ds1 :=0;
    if (dds1 <> InfD) then dds1:=0;
    DashPist1:=TRUE;  {..draw piston #1 in dashed line}
  END
  else DashPist1:=FALSE;
  if (s2 = EpsR) then BEGIN  {point C2 bottoms cylinder #2..}
    s2:=EpsR;
    if (ds2  <> InfD) then ds2 :=0;
    if (dds2 <> InfD) then dds2:=0;
    DashPist2:=TRUE;  {..draw piston #2 in dashed line}
  END
  else DashPist2:=FALSE;

  if BumpPiston then BEGIN
    if (s1 > A0Q1+P1C1) then BEGIN {piston #1 exits cylinder..}
      s1:=A0Q1+P1C1;  {..force it to remain inside}
      if (ds1  <> InfD) then ds1 :=0;
      if (dds1 <> InfD) then dds1:=0;
      DashPist1:=TRUE;  {..draw piston #1 in dashed line}
    END;
    if (R_p121(P1C1) > 5*JtSz) AND (s1 < Max2(P1C1,A0Q1)) then BEGIN
      s1:=Max2(P1C1,A0Q1);  {..force P1=A0 or C1=Q1 }
      if (ds1  <> InfD) then ds1 :=0;
      if (dds1 <> InfD) then dds1:=0;
      DashPist1:=TRUE;  {..draw piston #1 in dashed line}
    END;
    if (s2 > B0Q2+P2C2) then BEGIN {piston #2 exits cylinder..}
      s2:=B0Q2+P2C2;
      if (ds2  <> InfD) then ds2 :=0;
      if (dds2 <> InfD) then dds2:=0;
      DashPist2:=TRUE;  {..draw piston #2 in dashed line}
    END;
    if (R_p121(P2C2) > 5*JtSz) AND (s2 < Max2(P2C2,B0Q2)) then BEGIN
      s2:=Max2(P2C2,B0Q2);   {..force P2=B0 or C2=Q2 }
      if (ds2  <> InfD) then ds2 :=0;
      if (dds2 <> InfD) then dds2:=0;
      DashPist2:=TRUE;  {..draw piston #2 in dashed line}
    END;
  END; {..BumpPiston}

  r1:=Sqrt(Sqr(A0A-C1C)+Sqr(s1));
  if (ds1 <> InfD) AND (ds2 <> InfD) then BEGIN
    dr1:=ds1*s1/r1;
    dr2:=ds2*s2/r2;
  END
  else BEGIN
    dr1:=InfD;   ddr1:=InfD;
  END;

  r2:=Sqrt(Sqr(B0B-C2C)+Sqr(s2));
  if (dds1 < InfD) AND (dds2 < InfD) then BEGIN
    ddr1:=(ds1*ds1+s1*dds1-dr1*dr1)/r1;
    ddr2:=(ds2*ds2+s2*dds2-dr2*dr2)/r2;
  END
  else BEGIN
    dr2:=InfD;   ddr2:=InfD;
  END;

  Int2CirPVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB
  ,r1,dr1,ddr1, r2,dr2,ddr2, LftRgt, xC,yC,vxC,vyC,axC,ayC, Delta);
  if (Delta < 0) then BEGIN
    DashPist1:=TRUE;
    DashPist2:=TRUE;
  END;

  r1:=Sqrt(Sqr(C1C)+Sqr(s1));
  Int2Cir(xA,yA, xC,yC, A0A,r1, sgn(A0A), xA0,yA0, _);

  r1:=Sqrt(Sqr(A0A)+Sqr(s1));
  Int2Cir(xA,yA, xC,yC, r1,C1C, sgn(C1C), xC1,yC1, _);

  A_P_B(xC1,yC1, xA0,yA0, P1C1, xP1,yP1);
  A_P_B(xA0,yA0, xC1,yC1, A0Q1, xQ1,yQ1);

  r2:=Sqrt(Sqr(C2C)+Sqr(s2));
  Int2Cir(xB,yB, xC,yC, B0B,r2, sgn(B0B), xB0,yB0, _);

  r2:=Sqrt(Sqr(B0B)+Sqr(s2));
  Int2Cir(xB,yB, xC,yC, r2,C2C, sgn(C2C), xC2,yC2, _);

  A_P_B(xC2,yC2, xB0,yB0, P2C2, xP2,yP2);
  A_P_B(xB0,yB0, xC2,yC2, B0Q2, xQ2,yQ2);

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen..}
    SetColorBGI_DXF(Color);

    if DashPist1 then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    if (R_p121(P1C1) < 5*JtSz) then BEGIN  {draw line + Block #1..}
      LLine(X_p(xA),Y_p(yA),X_p(xA0),Y_p(yA0),X_p(xQ1),Y_p(yQ1),JtSz,0);
      Block(X_p(xC),Y_p(yC), Atan2((yC-yA0)/s1,(xC-xA0)/s1));
    END
    else {draw cylinder + piston #1..}
      LCylLPiston(X_p(xA),Y_p(yA), X_p(xA0),Y_p(yA0), X_p(xP1),Y_p(yP1)
      ,X_p(xQ1),Y_p(yQ1), X_p(xC1),Y_p(yC1), X_p(xC),Y_p(yC));

    if OpaqueJoints then IncDXFelev;

    if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA)) {ground pivot joint at A}
    else
      PDcircle('',X_p(xA),Y_p(yA),JtSz); {pivot joint at A}

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if DashPist2 then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    if (R_p121(P2C2) < 5*JtSz) then BEGIN  {draw line + Block..}
      LLine(X_p(xB),Y_p(yB),X_p(xB0),Y_p(yB0),X_p(xQ2),Y_p(yQ2),JtSz,0);
      Block(X_p(xC),Y_p(yC), Atan2((yC-yB0)/s2,(xC-xB0)/s2));
    END
    else {draw cylinder + piston..}
      LCylLPiston(X_p(xB),Y_p(yB), X_p(xB0),Y_p(yB0), X_p(xP2),Y_p(yP2)
      ,X_p(xQ2),Y_p(yQ2), X_p(xC2),Y_p(yC2), X_p(xC),Y_p(yC));

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if OpaqueJoints then IncDXFelev;

    PDcircle('',X_p(xC),Y_p(yC),JtSz);  {pivot joint at C}

    if (vxB = 0) AND (vyB = 0) AND (axB = 0) AND (ayB = 0) then
     gPivotJoint(X_p(xB),Y_p(yB)) {ground pivot joint at B}
    else
     PDcircle('',X_p(xB),Y_p(yB),JtSz); {pivot joint at B}

    if OpaqueJoints then BEGIN
      DecDXFelev;
      DecDXFelev;
    END;

    UpdateLimitsWS(xA0,yA0);
    UpdateLimitsWS(xC1,yC1);
    UpdateLimitsWS(xB0,yB0);
    UpdateLimitsWS(xC2,yC2);
    UpdateLimitsWS(xA,yA);
    UpdateLimitsWS(xB,yB);
  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}

END; {..RT_R_TRc}

{----------------------------------------------------------------------------}
procedure RT_R_TR(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          A0A,A0Q1,P1C1,C1C, B0B,B0Q2,P2C2,C2C,
          s1,ds1,dds1, s2,ds2,dds2:double; LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);

{ Solves the kinematics of the RTRTR chain using a vector loop method }

var DashPist1, DashPist2, OK: Boolean;
    AC,BC, Psi1,Psi2,  a1,b1,c1, a2,b2,c2,
    Theta, cTh1,sTh1, cTh2,sTh2, dTh1,ddTh1, dTh2,ddTh2: double;

BEGIN {RT_R_TR..}

  if (s1 < EpsR) then BEGIN  {point C1 bottoms cylinder #1..}
    s1:=EpsR;
    if (ds1  <> InfD) then ds1 :=0;
    if (dds1 <> InfD) then dds1:=0;
    DashPist1:=TRUE;  {..draw piston #1 in dashed line}
  END
  else DashPist1:=FALSE;
  if (s2 = EpsR) then BEGIN  {point C2 bottoms cylinder #2..}
    s2:=EpsR;
    if (ds2  <> InfD) then ds2 :=0;
    if (dds2 <> InfD) then dds2:=0;
    DashPist2:=TRUE;  {..draw piston #2 in dashed line}
  END
  else DashPist2:=FALSE;

  if BumpPiston then BEGIN
    if (s1 > A0Q1+P1C1) then BEGIN {piston #1 exits cylinder..}
      s1:=A0Q1+P1C1;  {..force it to remain inside}
      if (ds1  <> InfD) then ds1 :=0;
      if (dds1 <> InfD) then dds1:=0;
      DashPist1:=TRUE;  {..draw piston #1 in dashed line}
    END;
    if (R_p121(P1C1) > 5*JtSz) AND (s1 < Max2(P1C1,A0Q1)) then BEGIN
      s1:=Max2(P1C1,A0Q1);  {..force P1=A0 or C1=Q1 }
      if (ds1  <> InfD) then ds1 :=0;
      if (dds1 <> InfD) then dds1:=0;
      DashPist1:=TRUE;  {..draw piston #1 in dashed line}
    END;
    if (s2 > B0Q2+P2C2) then BEGIN {piston #2 exits cylinder..}
      s2:=B0Q2+P2C2;
      if (ds2  <> InfD) then ds2 :=0;
      if (dds2 <> InfD) then dds2:=0;
      DashPist2:=TRUE;  {..draw piston #2 in dashed line}
    END;
    if (R_p121(P2C2) > 5*JtSz) AND (s2 < Max2(P2C2,B0Q2)) then BEGIN
      s2:=Max2(P2C2,B0Q2);   {..force P2=B0 or C2=Q2 }
      if (ds2  <> InfD) then ds2 :=0;
      if (dds2 <> InfD) then dds2:=0;
      DashPist2:=TRUE;  {..draw piston #2 in dashed line}
    END;
  END; {..BumpPiston}

  AC:=Sqrt(Sqr(A0A-C1C)+Sqr(s1));
  BC:=Sqrt(Sqr(B0B-C2C)+Sqr(s2));

  a1:=2*AC*(xB-xA);
  b1:=2*AC*(yB-yA);
  c1:=AC*AC-BC*BC+Sqr(xB-xA)+Sqr(yB-yA);
  Delta_:=a1*a1+b1*b1-c1*c1;
  if (Delta <> InfD) then Delta:=Delta_;  {there is interest in Delta}
  if (Delta_ < 0) then BEGIN
    Delta_:=0;
    DashPist1:=TRUE;
    DashPist2:=TRUE;
  END;
  Psi1:=Atan2(b1,a1)-LftRgt*Atan2(Sqrt(Delta_),c1);
  a2:=2*BC*(xB-xA);
  b2:=2*BC*(yB-yA);
  c2:=AC*AC-BC*BC-Sqr(xB-xA)-Sqr(yB-yA);
  Psi2:=Atan2(b2,a2)-LftRgt*Atan2(Sqrt(Delta_),c2);

  a1:=s1;        b1:=A0A-C1C;  c1:=AC*cos(Psi1);
  a2:=-A0A+C1C;  b2:=s1;       c2:=AC*sin(Psi1);
  LinEq2(a1,b1,c1, a2,b2,c2, cTh1, sTh1, OK);
  if NOT OK then DashPist1:=TRUE;

  a1:=s2;        b1:=B0B-C2C;  c1:=BC*cos(Psi2);
  a2:=-B0B+C2C;  b2:=s2;       c2:=BC*sin(Psi2);
  LinEq2(a1,b1,c1, a2,b2,c2, cTh2, sTh2, OK);
  if NOT OK then DashPist2:=TRUE;

  xC:=xA+(A0A-C1C)*sTh1+s1*cTh1;
  xC:=0.5*(xC + xB+(B0B-C2C)*sTh2+s2*cTh2);
  yC:=yA-(A0A-C1C)*cTh1+s1*sTh1;
  yC:=0.5*(yC + yB-(B0B-C2C)*cTh2+s2*sTh2);

  xA0:=xA+A0A*sTh1;
  yA0:=yA-A0A*cTh1;
  xC1:=xC + C1C*sTh1;
  yC1:=yC - C1C*cTh1;
  xP1:=xA0+(s1-P1C1)*cTh1;
  yP1:=yA0+(s1-P1C1)*sTh1;
  xQ1:=xA0+A0Q1*cTh1;
  yQ1:=yA0+A0Q1*sTh1;

  xB0:=xB+B0B*sTh2;
  yB0:=yB-B0B*cTh2;
  xC2:=xC+C2C*sTh2;
  yC2:=yC-C2C*cTh2;
  xP2:=xB0+(s2-P2C2)*cTh2;
  yP2:=yB0+(s2-P2C2)*sTh2;
  xQ2:=xB0+B0Q2*cTh2;
  yQ2:=yB0+B0Q2*sTh2;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen..}
    SetColorBGI_DXF(Color);

    if DashPist1 then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    if (R_p121(P1C1) < 5*JtSz) then BEGIN  {draw line + Block #1..}
      LLine(X_p(xA),Y_p(yA),X_p(xA0),Y_p(yA0),X_p(xQ1),Y_p(yQ1),JtSz,0);
      Block(X_p(xC),Y_p(yC), Atan2((yC-yA0)/s1,(xC-xA0)/s1));
    END
    else {draw cylinder + piston #1..}
      LCylLPiston(X_p(xA),Y_p(yA), X_p(xA0),Y_p(yA0),X_p(xP1),Y_p(yP1)
      ,X_p(xQ1),Y_p(yQ1), X_p(xC1),Y_p(yC1), X_p(xC),Y_p(yC));

    if OpaqueJoints then IncDXFelev;

    if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA)) {ground pivot joint at A}
    else
      PDcircle('',X_p(xA),Y_p(yA),JtSz); {..pivot joint at A}

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if DashPist2 then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    if (R_p121(P2C2) < 5*JtSz) then BEGIN  {draw line + Block..}
      LLine(X_p(xB),Y_p(yB),X_p(xB0),Y_p(yB0),X_p(xQ2),Y_p(yQ2),JtSz,0);
      Block(X_p(xC),Y_p(yC), Atan2((yC-yB0)/s2,(xC-xB0)/s2));
    END
    else {draw cylinder + piston..}
      LCylLPiston(X_p(xB),Y_p(yB), X_p(xB0),Y_p(yB0),X_p(xP2),Y_p(yP2)
      ,X_p(xQ2),Y_p(yQ2), X_p(xC2),Y_p(yC2), X_p(xC),Y_p(yC));

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if OpaqueJoints then IncDXFelev;

    PDcircle('',X_p(xC),Y_p(yC),JtSz);  {pivot joint at C}

    if (vxB = 0) AND (vyB = 0) AND (axB = 0) AND (ayB = 0) then
     gPivotJoint(X_p(xB),Y_p(yB)) {ground pivot joint at B}
    else
     PDcircle('',X_p(xB),Y_p(yB),JtSz); {pivot joint at B}

    if OpaqueJoints then BEGIN
      DecDXFelev;
      DecDXFelev;
    END;

    UpdateLimitsWS(xA,yA);
    UpdateLimitsWS(xB,yB);
    UpdateLimitsWS(xC,yC);
    UpdateLimitsWS(xA0,yA0);
    UpdateLimitsWS(xC1,yC1);
    UpdateLimitsWS(xB0,yB0);
    UpdateLimitsWS(xC2,yC2);
  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}

  vxC:=InfD;  vyC:=InfD;
  if (vxA > InfR) OR (vyA > InfR) OR (vxB > InfR) OR (vyB > InfR)
  OR (ds1 > InfR) OR (ds2 > InfR) then Exit; {..no interest in vxC,vyC,axC,ayC}
  a1:=(A0A-C1C)*cTh1-s1*sTh1;
  b1:=s2*sTh2-(B0B-C2C)*cTh2;
  c1:=vxB-vxA-ds1*cTh1+ds2*cTh2;
  a2:=(A0A-C1C)*sTh1+s1*cTh1;
  b2:=-s2*cTh2-(B0B-C2C)*sTh2;
  c2:=vyB-vyA-ds1*sTh1+ds2*sTh2;
  LinEq2(a1,b1,c1, a2,b2,c2, dTh1, dTh2, OK);
  if NOT OK then Exit;
  vxC:=vxA+(A0A-C1C)*cTh1*dTh1+ds1*cTh1-s1*sTh1*dTh1;
  vyC:=vyA+(A0A-C1C)*sTh1*dTh1+ds1*sTh1+s1*cTh1*dTh1;


  axC:=InfD;  ayC:=InfD;
  if (axA > InfR) OR (ayA > InfR) OR (axB > InfR) OR (ayB > InfR)
  OR (dds1 > InfR) OR (dds2 > InfR) then Exit; {..no interest in axC and ayC}

  c1:=axB-axA-dds1*cTh1+ds1*sTh1*dTh1+dds2*cTh2-ds2*sTh2*dTh2;
  c1:=c1-(-(A0A-C1C)*sTh1*dTh1-ds1*sTh1-s1*cTh1*dTh1)*dTh1;
  c1:=c1-(ds2*sTh2+s2*cTh2*dTh2+(B0B-C2C)*sTh2*dTh2)*dTh2;
  c2:=ayB-ayA-dds1*sTh1-ds1*cTh1*dTh1+dds2*sTh2+ds2*cTh2*dTh2;
  c2:=c2-((A0A-C1C)*cTh1*dTh1+ds1*cTh1-s1*sTh1*dTh1)*dTh1;
  c2:=c2+(ds2*cTh2-s2*sTh2*dTh2+(B0B-C2C)*cTh2*dTh2)*dTh2;
  LinEq2(a1,b1,c1, a2,b2,c2, ddTh1, ddTh2, OK);
  if NOT OK then Exit;

  axC:=axA-(A0A-C1C)*sTh1*Sqr(dTh1)+(A0A-C1C)*cTh1*ddTh1
       +dds1*cTh1-ds1*sTh1*dTh1;
  axC:=axC-ds1*sTh1*dTh1-s1*cTh1*Sqr(dTh1)-s1*sTh1*ddTh1;
  ayC:=ayA+(A0A-C1C)*cTh1*Sqr(dTh1)+(A0A-C1C)*sTh1*ddTh1
       +dds1*sTh1+ds1*cTh1*dTh1;
  ayC:=ayC+ds1*cTh1*dTh1-s1*sTh1*Sqr(dTh1)+s1*cTh1*ddTh1;

END; {..RT_R_TR}

{----------------------------------------------------------------------------}
procedure GetA0(var x_A0,y_A0: double);
BEGIN
  x_A0:=xA0;  y_A0:=yA0;
END;
procedure GetB0(var x_B0,y_B0: double);
BEGIN
  x_B0:=xB0;  y_B0:=yB0;
END;

procedure GetP(var x_P,y_P: double);
BEGIN
  x_P:=xP;  y_P:=yP;
END;
procedure GetQ(var x_Q,y_Q: double);
BEGIN
  x_Q:=xQ;  y_Q:=yQ;
END;

procedure GetC1(var x_C1,y_C1: double);
BEGIN
  x_C1:=xC1;  y_C1:=yC1;
END;
procedure GetC2(var x_C2,y_C2: double);
BEGIN
  x_C2:=xC2;  y_C2:=yC2;
END;

procedure GetP1(var x_P1,y_P1: double);
BEGIN
  x_P1:=xP1;  y_P1:=yP1;
END;
procedure GetQ1(var x_Q1,y_Q1: double);
BEGIN
  x_Q1:=xQ1;  y_Q1:=yQ1;
END;

procedure GetP2(var x_P2,y_P2: double);
BEGIN
  x_P2:=xP2;  y_P2:=yP2;
END;
procedure GetQ2(var x_Q2,y_Q2: double);
BEGIN
  x_Q2:=xQ2;  y_Q2:=yQ2;
END;

{----------------------------------------------------------------------------}

END. {..LibMecIn}

