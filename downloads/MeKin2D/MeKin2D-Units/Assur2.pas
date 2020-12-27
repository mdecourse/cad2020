unit Assur2;
{ $R+ }
{ $S- }
{=============================================================================
  Subroutines for solving the kinematics of all five diads
  (c) P.A. Simionescu 2018
=============================================================================}
{De protejat cand nu intereseaza viteze, acceleratii si reprezentari grafice}

INTERFACE

uses CRT,DOS,Graph,
     LibMec2D,
     LibMath,
     LibDXF,
     LibGraph;

procedure RRRc(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  AC,BC:double; LftRgt:shortint; var xC,yC,vxC,vyC,axC,ayC, Delta:double);

procedure RRR(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  AC,BC:double; LftRgt:shortint; var xC,yC,vxC,vyC,axC,ayC, Delta:double);


procedure RR_T(Color:Word; xA,yA,vxA,vyA,axA,ayA, xP,yP,vxP,vyP,axP,ayP,
  Th,dTh,ddTh, AC,BC,BQ:double; PlsMns:shortint; var xB,yB,vxB,vyB,
  axB,ayB, xC,yC,vxC,vyC,axC,ayC, xQ,yQ,vxQ,vyQ,axQ,ayQ, Delta:double);

procedure RRT_(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xP,yP,vxP,vyP,axP,ayP,
  xQ,yQ,vxQ,vyQ,axQ,ayQ, AC,BC:double; PlsMns:shortint; var xB,yB,vxB,vyB,
  axB,ayB, xC,yC,vxC,vyC,axC,ayC, Delta:double);

procedure RT_R(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  AC,BP,PQ:double; var xP,yP,vxP,vyP,axP,ayP, xC,yC,vxC,vyC,axC,ayC,
  xQ,yQ,vxQ,vyQ,axQ,ayQ, Delta:double);

procedure T_R_T(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  Th1,dTh1,ddTh1, Th2,dTh2,ddTh2, P1Q1,Q1C, P2Q2,Q2C:double;
  var xC,yC,vxC,vyC,axC,ayC, xP1,yP1,vxP1,vyP1,axP1,ayP1, xQ1,yQ1,vxQ1,vyQ1,
  axQ1,ayQ1, xP2,yP2,vxP2,vyP2,axP2,ayP2, xQ2,yQ2,vxQ2,vyQ2,axQ2,ayQ2:double;
  var OK:Boolean);

procedure _TRT_(Color:Word; xP1,yP1,vxP1,vyP1,axP1,ayP1, xQ1,yQ1,vxQ1,vyQ1,
  axQ1,ayQ1, xP2,yP2,vxP2,vyP2,axP2,ayP2, xQ2,yQ2,vxQ2,vyQ2,axQ2,ayQ2,
  AC,BC: double; var xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  xC,yC,vxC,vyC,axC,ayC: double; var OK:Boolean);

procedure T_RT_(Color:Word; xA,yA,vxA,vyA,axA,ayA, Th1,dTh1,ddTh1,
  xP2,yP2,vxP2,vyP2,axP2,ayP2, xQ2,yQ2,vxQ2,vyQ2,axQ2,ayQ2, P1Q1,Q1C,BC: double;  var xP1,yP1,vxP1,vyP1,axP1,ayP1,
  xQ1,yQ1,vxQ1,vyQ1,axQ1,ayQ1, xB,yB,vxB,vyB,axB,ayB, xC,yC,vxC,vyC,axC,ayC: double;  var OK:Boolean);

procedure R_T_T(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  Phi,dPhi,ddPhi, AD,DK,PQ,QC, Alpha1,Alpha2:double;  var xC,yC,
  vxC,vyC,axC,ayC, xD,yD,vxD,vyD,axD,ayD, xK,yK,vxK,vyK,axK,ayK,
  xP,yP,vxP,vyP,axP,ayP, xQ,yQ,vxQ,vyQ,axQ,ayQ:double; var OK:Boolean);

procedure RT_T_(Color:Word; xA,yA,vxA,vyA,axA,ayA, xP,yP,vxP,vyP,axP,ayP,
  xQ,yQ,vxQ,vyQ,axQ,ayQ, AC,BD,Alpha2:double; var xB,yB,vxB,vyB,axB,ayB,
  xC,yC,vxC,vyC,axC,ayC, xD,yD,vxD,vyD,axD,ayD:double; var OK:Boolean);

procedure R_TT_(Color:Word; xA,yA,vxA,vyA,axA,ayA, xP,yP,vxP,vyP,axP,ayP,
  xQ,yQ,vxQ,vyQ,axQ,ayQ, AD,DK,BC, Alpha1,Alpha2:double; var xB,yB,vxB,vyB,
  axB,ayB, xC,yC,vxC,vyC,axC,ayC, xD,yD,vxD,vyD,axD,ayD, xK,yK,vxK,vyK,
  axK,ayK:double; var OK:Boolean);

procedure RT__T(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  Phi,dPhi,ddPhi, AC,PQ,QD, Alpha2:double; var xC,yC,vxC,vyC,axC,ayC,
  xD,yD,vxD,vyD,axD,ayD, xP,yP,vxP,vyP,axP,ayP, xQ,yQ,vxQ,vyQ,axQ,ayQ:double;
  var OK:Boolean);


procedure _GG_(Color:Integer; var Angle: double;  xA,yA,vxA,vyA,axA,ayA,
  xB,yB,vxB,vyB,axB,ayB, xC,yC,vxC,vyC,axC,ayC,
  CD,k,GrAsRat:double; var xD,yD,vxD,vyD,axD,ayD:double);

procedure RGGR(Color:Integer; xA,yA,vxA,vyA,axA,ayA,  xD,yD,vxD,vyD,axD,ayD,
  AB, BC, CD, k, GrAsRat:double; PlsMns:Integer;
  var Th, xB,yB,vxB,vyB,axB,ayB ,xC,yC,vxC,vyC,axC,ayC:double);

procedure _GK_(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  BD,r,PQ,AC:double; var xP,yP,vxP,vyP,axP,ayP,xQ,yQ,vxQ,vyQ,axQ,ayQ:double);

{============================================================================}

IMPLEMENTATION

uses  LibGe2D;

{----------------------------------------------------------------------------}
procedure RRRc(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          AC,BC:double;  LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);
{ Solve the kinematics of a RRRc dyad                                         }

var xCC,yCC, Delta_:double;
    DashACB:Boolean;

BEGIN {RRRc ..}
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xB,yB);

  DashACB:=FALSE;

  Int2CirPVA(xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  AC,0.0,0.0, BC,0.0,0.0, LftRgt, xCC,yCC,vxC,vyC,axC,ayC, Delta_);

  if (Delta <> InfD) then Delta:=Delta_;  {..there is interest in Delta}
  if (Delta_ < 0.0) then DashACB:=TRUE;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Abs(Color));

    PDcircle('',X_p(xCC),Y_p(yCC),JtSz);  {pivot joint at C}

    if (JtSz > 0) then BEGIN
      if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
        gPivotJoint(X_p(xA),Y_p(yA)) {..ground pivot joint at A}
      else
        PDcircle('',X_p(xA),Y_p(yA),JtSz); {..pivot joint at A}

      if (vxB=0) AND (vyB=0) AND (axB=0) AND (ayB=0) then
        gPivotJoint(X_p(xB),Y_p(yB)) {..ground pivot joint at B}
      else
        PDcircle('',X_p(xB),Y_p(yB),JtSz); {..pivot joint at B}
    END;

    if DashACB then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth);  SyncDXFLineStyleTkns;
    END;
    SkLine(X_p(xA),Y_p(yA),X_p(xCC),Y_p(yCC),JtSz,JtSz);
    if (Color > 0) then SkLine(X_p(xB),Y_p(yB),X_p(xCC),Y_p(yCC),JtSz,JtSz);
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  xC:=xCC;
  yC:=yCC;
  _:=InfD;
END; {.. RRRc}

{----------------------------------------------------------------------------}
procedure RRR(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          AC,BC:double;  LftRgt:shortint;
          var xC,yC,vxC,vyC,axC,ayC, Delta:double);
{ Solves the kinematics of the RRR dyad using a vector loop approach }
{ LftRgt is the orientation of the triangular loop A-B-C             }

var Phi1,cPhi1,sPhi1, dPhi1,ddPhi1,
    Phi2,cPhi2,sPhi2, dPhi2,ddPhi2,
    a1,b1,c1, a2,b2,c2, xCC,yCC, Delta_: double;
    DashACB,OK: Boolean;

BEGIN {RRR ..}
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xB,yB);

  DashACB:=FALSE;

  a1:=2*AC*(xB-xA);
  b1:=2*AC*(yB-yA);
  c1:=AC*AC-BC*BC + (Sqr(xB-xA)+Sqr(yB-yA));

  a2:=2*BC*(xB-xA);
  b2:=2*BC*(yB-yA);
  c2:=AC*AC-BC*BC - (Sqr(xB-xA)+Sqr(yB-yA));

  Delta_:=a1*a1 + b1*b1 - c1*c1;
  if (Delta <> InfD) then Delta:=Delta_; {..there is interest in Delta}

  if (Delta_ < 0) then BEGIN
    Delta_:=0;
    DashACB:=TRUE;
  END;

{ Phi1:=Atan2(b1,a1) - LftRgt*Atan2(Sqrt(Delta_),c1); }
  Phi1:=2*Atan2(b1-LftRgt*Sqrt(Delta),a1+c1+EpsD);

  cPhi1:=cos(Phi1);
  sPhi1:=sin(Phi1);

{ Phi2:=Atan2(b2,a2) - LftRgt*Atan2(Sqrt(Delta_),c2); }
  Phi2:=2*Atan2(b2-LftRgt*Sqrt(Delta),a2+c2+EpsD);

  cPhi2:=cos(Phi2);
  sPhi2:=sin(Phi2);

  xCC:=xA+AC*cPhi1;
  yCC:=yA+AC*sPhi1;
  UpdateLimitsWS(xCC,yCC);

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Abs(Color));
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    PDcircle('',X_p(xCC),Y_p(yCC),JtSz);  {pivot joint at C}

    if (JtSz > 0) then BEGIN
      if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
        gPivotJoint(X_p(xA),Y_p(yA)) {..ground pivot joint at A}
      else
        PDcircle('',X_p(xA),Y_p(yA),JtSz); {..pivot joint at A}

      if (vxB=0) AND (vyB=0) AND (axB=0) AND (ayB=0) then
        gPivotJoint(X_p(xB),Y_p(yB)) {..ground pivot joint at B}
      else
        PDcircle('',X_p(xB),Y_p(yB),JtSz); {..pivot joint at B}
    END;

    if DashACB then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth); SyncDXFLineStyleTkns;
    END;
    if (Color > 0) OR DashACB then BEGIN
      SkLine(X_p(xB),Y_p(yB),X_p(xCC),Y_p(yCC),JtSz,JtSz);
      SkLine(X_p(xA),Y_p(yA),X_p(xCC),Y_p(yCC),JtSz,JtSz);
    END;
    SetLineStyle(SolidLn, 0, NormWidth);   SyncDXFLineStyleTkns;

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  xC:=xCC;   yC:=yCC;

  vxC:=InfD;  vyC:=InfD;
  if (vxA = InfD) OR (vyA = InfD) OR
  (vxB = InfD) OR (vyB = InfD) then Exit; {..no interest in vxC,vyC,axC,ayC}
  a1:=-AC*sPhi1;  b1:= BC*sPhi2;  c1:=vxB-vxA;
  a2:= AC*cPhi1;  b2:=-BC*cPhi2;  c2:=vyB-vyA;
  LinEq2(a1,b1,c1, a2,b2,c2, dPhi1, dPhi2, OK);
  if NOT OK then Exit;
  vxC:=vxA-AC*sPhi1*dPhi1;
  vyC:=vyA+AC*cPhi1*dPhi1;

  axC:=InfD;  ayC:=InfD;
  if (axA = InfD) OR (ayA = InfD) OR
  (axB = InfD) OR (ayB = InfD) then Exit; {..no interest in axC,ayC}
  c1:=axB-axA+AC*cPhi1*Sqr(dPhi1)-BC*cPhi2*Sqr(dPhi2);
  c2:=ayB-ayA+AC*sPhi1*Sqr(dPhi1)-BC*sPhi2*Sqr(dPhi2);
  LinEq2(a1,b1,c1, a2,b2,c2, ddPhi1, ddPhi2, OK);
  if NOT OK then Exit;
  axC:=axA-AC*cPhi1*Sqr(dPhi1)-AC*sPhi1*ddPhi1;
  ayC:=ayA-AC*sPhi1*Sqr(dPhi1)+AC*cPhi1*ddPhi1;

END; {.. RRR}

{----------------------------------------------------------------------------}
procedure RR_T(Color:Word; xA,yA,vxA,vyA,axA,ayA, xP,yP,vxP,vyP,axP,ayP,
          Th,dTh,ddTh, AC,BC,BQ:double; PlsMns:shortint;
          var xB,yB,vxB,vyB,axB,ayB, xC,yC,vxC,vyC,axC,ayC,
          xQ,yQ,vxQ,vyQ,axQ,ayQ,  Delta:double);

{ Solve the kinematics of the RR_T dyad.                                      }
{ If (xB = InfD) OR (yB = InfD) assumes that there is no interest in (xB,yB);}
{ If (xC = InfD) OR (yC = InfD) assumes that there is no interest in (xC,yC);}
{ If (vxA = InfD) OR (vyA = InfD) OR (vxP = InfD) OR (vyP = InfD) OR         }
{ (vxQ = InfD) OR (vyQ = InfD) it assumes that there is no interest in vxB,  }
{ vyB, vxC and vyC;                                                          }
{ If (axA = InfD) OR (ayA = InfD) OR (axP = InfD) OR (ayP = InfD) OR         }
{ (axQ = InfD) OR (ayQ = InfD) it assumes that there is no interest in axB,  }
{ ayB, axC and ayC;                                                          }

var xBB,yBB, xCC,yCC, xQQ,yQQ,
    s,ds,dds, Phi,dPhi,ddPhi,  cP,sP, cT,sT, Delta_,
    a1,b1,c1, a2,b2,c2: double;
    DashACB, OK: Boolean;

BEGIN {RR_T..}
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xQ,yQ);

  DashACB:=FALSE;

  cT:=cos(Th);
  sT:=sin(Th);

  Delta_:=Sqr((xP-xA)*cT + (yP-yA)*sT);
  Delta_:=Delta_ - 2*BC*((yP-yA)*cT-(xP-xA)*sT);
  Delta_:=Delta_ - Sqr(xP-xA)-Sqr(yP-yA)+Sqr(AC)-Sqr(BC);
  if (Delta <> InfD) then  Delta:=Delta_;  {there is interest in Delta}
  if (Delta_ < 0.0) then BEGIN  {dyad does not close ..}
    DashACB:=TRUE;
    Delta_:=0.0;
  END;

  s:=-((xP-xA)*cT+(yP-yA)*sT) + PlsMns*Sqrt(Delta_);

  xBB:=xP + s*cT;
  yBB:=yP + s*sT;
  UpdateLimitsWS(xBB,yBB);

  xCC:=xBB - BC*sT;
  yCC:=yBB + BC*cT;
  UpdateLimitsWS(xCC,yCC);

  xQQ:=xBB - BQ*cT;
  yQQ:=yBB - BQ*sT;
  UpdateLimitsWS(xQQ,yQQ);

  cP:=(xCC-xA)/AC;
  sP:=(yCC-yA)/AC;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color > Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Color);
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if (JtSz > 0) AND (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
     gPivotJoint(X_p(xA),Y_p(yA)) {ground pivot joint at A}
    else BEGIN {pivot joint at A ..}
      if OpaqueJoints then IncDXFelev;
      PDcircle('',X_p(xA),Y_p(yA),JtSz);
      if OpaqueJoints then DecDXFelev;
    END;

    if DashACB then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth);  SyncDXFLineStyleTkns;
    END;

    SkLine(X_p(xA),Y_p(yA),X_p(xCC),Y_p(yCC),JtSz,JtSz);
    LLine(X_p(xCC),Y_p(yCC),X_p(xBB),Y_p(yBB),X_p(xQQ),Y_p(yQQ),JtSz,0);
    PDcircle('',X_p(xCC),Y_p(yCC),JtSz); {pivot joint at C}

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if (vxP=0) AND (vyP=0) AND (axP=0) AND (ayP=0)
    AND (dTh=0) AND (ddTh=0) then
      gBlock(X_p(xP),Y_p(yP),Th)
    else
      Block(X_p(xP),Y_p(yP),Th);

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}

  xB:=xBB;  yB:=yBB;
  xC:=xCC;  yC:=yCC;
  xQ:=xQQ;  yQ:=yQQ;

  vxB:=InfD;  vyB:=InfD;
  vxC:=InfD;  vyC:=InfD;
  vxQ:=InfD;  vyQ:=InfD;
  if (vxA = InfD) OR (vyA = InfD) OR (dTh = InfD) then Exit;
  {there is interest in velocities ..}
  a1:=-AC*sP;  b1:=-cT;  c1:=vxP-vxA-(BC*cT+s*sT)*dTh;
  a2:= AC*cP;  b2:=-sT;  c2:=vyP-vyA-(BC*sT-s*cT)*dTh;
  LinEq2(a1,b1,c1, a2,b2,c2, dPhi, ds, OK);   if NOT OK then Exit;
  vxB:=vxP + ds*cT - s*sT*dTh;
  vyB:=vyP + ds*sT + s*cT*dTh;
  vxC:=vxB - BC*cT*dTh;
  vyC:=vyB - BC*sT*dTh;
  vxQ:=vxB + BQ*sT*dTh;
  vyQ:=vyB - BQ*cT*dTh;


  axB:=InfD;  ayB:=InfD;
  axC:=InfD;  ayC:=InfD;
  axQ:=InfD;  ayQ:=InfD;
  if (axA = InfD) OR (ayA = InfD) OR (ddTh = InfD) then Exit;
  {there is interest in accelerations..}
  c1:=axP-axA + (BC*sT-s*cT)*Sqr(dTh) - (BC*cT+s*sT)*ddTh;
  c1:=c1 - 2*ds*sT*dTh + AC*cP*Sqr(dPhi);
  c2:=ayP-ayA - (BC*cT+s*sT)*Sqr(dTh) - (BC*sT-s*cT)*ddTh;
  c2:=c2 + 2*ds*cT*dTh + AC*sP*Sqr(dPhi);
  LinEq2(a1,b1,c1, a2,b2,c2, ddPhi, dds, OK);   if NOT OK then Exit;

  axB:=axP + dds*cT - 2*ds*sT*dTh - s*cT*Sqr(dTh) - s*sT*ddTh;
  ayB:=ayP + dds*sT + 2*ds*cT*dTh - s*sT*Sqr(dTh) + s*cT*ddTh;
  axQ:=axB + BQ*cT*Sqr(dTh) + BQ*sT*ddTh;
  ayQ:=ayB + BQ*sT*Sqr(dTh) - BQ*cT*ddTh;
  axC:=axB + BC*sT*Sqr(dTh) - BC*cT*ddTh;
  ayC:=ayB - BC*cT*Sqr(dTh) - BC*sT*ddTh;

END; {..RR_T}

{----------------------------------------------------------------------------}
procedure RRT_(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xP,yP,vxP,vyP,axP,ayP,
          xQ,yQ,vxQ,vyQ,axQ,ayQ, AC,BC:double; PlsMns:shortint;
          var xB,yB,vxB,vyB,axB,ayB, xC,yC,vxC,vyC,axC,ayC, Delta:double);

{ Solve the kinematics of the RR_T dyad.                                      }
{ If (xB = InfD) OR (yB = InfD) assumes that there is no interest in (xB,yB);}
{ If (xC = InfD) OR (yC = InfD) assumes that there is no interest in (xC,yC);}
{ If (vxA = InfD) OR (vyA = InfD) OR (vxP = InfD) OR (vyP = InfD) OR         }
{ (vxQ = InfD) OR (vyQ = InfD) it assumes that there is no interest in vxB,  }
{ vyB, vxC and vyC;                                                          }
{ If (axA = InfD) OR (ayA = InfD) OR (axP = InfD) OR (ayP = InfD) OR         }
{ (axQ = InfD) OR (ayQ = InfD) it assumes that there is no interest in axB,  }
{ ayB, axC and ayC;                                                          }

var xBB,yBB, xCC,yCC, PQ, s,ds,dds, Phi,dPhi,ddPhi, cP,sP,
    Th,dTh,ddTh, cT,sT, Delta_, a1,b1,c1, a2,b2,c2: double;
    DashACB, OK: Boolean;

BEGIN {RR_T..}
  UpdateLimitsWS(xP,yP);
  UpdateLimitsWS(xQ,yQ);

  DashACB:=FALSE;

  PQ:=Sqrt(Sqr(xP-xQ)+Sqr(yP-yQ));
  Th:=0.0;
  if (PQ > EpsR) then BEGIN
    AngPVA(xP,yP,vxP,vyP,axP,ayP, xQ,yQ,vxQ,vyQ,axQ,ayQ, Th,dTh,ddTh);
    cT:=(xQ-xP)/PQ;  sT:=(yQ-yP)/PQ;
  END
  else BEGIN
    cT:=1.0;  sT:=0.0;
     dTh:=0.0;  ddTh:=0.0;
  END;

  Delta_:=Sqr((xP-xA)*cT + (yP-yA)*sT);
  Delta_:=Delta_ - 2*BC*((yP-yA)*cT-(xP-xA)*sT);
  Delta_:=Delta_ - Sqr(xP-xA)-Sqr(yP-yA)+Sqr(AC)-Sqr(BC);
  if (Delta <> InfD) then  Delta:=Delta_;  {there is interest in Delta}
  if (Delta_ < 0.0) then BEGIN  {dyad does not close ..}
    DashACB:=TRUE;
    Delta_:=0.0;
  END;

  s:=-((xP-xA)*cT + (yP-yA)*sT) + PlsMns*Sqrt(Delta_);

  xBB:=xP + s*cT;
  yBB:=yP + s*sT;
  UpdateLimitsWS(xBB,yBB);

  xCC:=xBB - BC*sT;
  yCC:=yBB + BC*cT;
  UpdateLimitsWS(xCC,yCC);

  cP:=(xCC-xA)/AC;
  sP:=(yCC-yA)/AC;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Abs(Color));
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if (JtSz > 0) AND (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA)) {ground pivot joint at A}
    else BEGIN {pivot joint at A ..}
      if OpaqueJoints then IncDXFelev;
      PDcircle('',X_p(xA),Y_p(yA),JtSz);
      if OpaqueJoints then DecDXFelev;
    END;

    if (Color > 0) then  if (vxP=0) AND (vyP=0) AND (axP=0) AND (ayP=0)
    AND (vxQ=0) AND (vyQ=0) AND (axQ=0) AND (ayQ=0) then
     GroundLine(X_p(xP),Y_p(yP),X_p(xQ),Y_p(yQ))
    else
     PDline('',X_p(xP),Y_p(yP),X_p(xQ),Y_p(yQ));

    Block(X_p(xBB),Y_p(yBB),Th);

    if OpaqueJoints then IncDXFelev;
    PDcircle('',X_p(xCC),Y_p(yCC),JtSz);  {pivot joint at C}

    if DashACB then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth);  SyncDXFLineStyleTkns;
    END;

    SkLine(X_p(xA),Y_p(yA),X_p(xCC),Y_p(yCC),JtSz,JtSz);
    SkLine(X_p(xBB),Y_p(yBB),X_p(xCC),Y_p(yCC),2*JtSz,JtSz);

    if OpaqueJoints then DecDXFelev;

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}

  xB:=xBB;  yB:=yBB;
  xC:=xCC;  yC:=yCC;

  vxB:=InfD;  vyB:=InfD;
  vxC:=InfD;  vyC:=InfD;
  vxQ:=InfD;  vyQ:=InfD;
  if (vxA = InfD) OR (vyA = InfD) OR (vxP = InfD) OR (vyP = InfD) OR
  (vxQ = InfD) OR (vyQ = InfD) then  Exit; {no interest in vel & accel ..}
  a1:=-AC*sP;  b1:=-cT;  c1:=vxP-vxA-(BC*cT+s*sT)*dTh;
  a2:= AC*cP;  b2:=-sT;  c2:=vyP-vyA-(BC*sT-s*cT)*dTh;
  LinEq2(a1,b1,c1, a2,b2,c2, dPhi, ds, OK);   if NOT OK then Exit;
  vxB:=vxP + ds*cT - s*sT*dTh;
  vyB:=vyP + ds*sT + s*cT*dTh;
  vxC:=vxB - BC*cT*dTh;
  vyC:=vyB - BC*sT*dTh;
  vxQ:=vxP + PQ*sT*dTh;
  vyQ:=vyP - PQ*cT*dTh;

  axB:=InfD;  ayB:=InfD;
  axC:=InfD;  ayC:=InfD;
  axQ:=InfD;  ayQ:=InfD;
  if (axA = InfD) OR (ayA = InfD) OR (axP = InfD) OR (ayP = InfD) OR
  (axQ = InfD) OR (ayQ = InfD) then Exit; {no interest in accelerations..}
  c1:=axP-axA + (BC*sT-s*cT)*Sqr(dTh) - (BC*cT+s*sT)*ddTh;
  c1:=c1 - 2*ds*sT*dTh + AC*cP*Sqr(dPhi);
  c2:=ayP-ayA - (BC*cT+s*sT)*Sqr(dTh) - (BC*sT-s*cT)*ddTh;
  c2:=c2 + 2*ds*cT*dTh + AC*sP*Sqr(dPhi);
  LinEq2(a1,b1,c1, a2,b2,c2, ddPhi, dds, OK);   if NOT OK then Exit;

  axB:=axP + dds*cT - 2*ds*sT*dTh - s*cT*Sqr(dTh) - s*sT*ddTh;
  ayB:=ayP + dds*sT + 2*ds*cT*dTh - s*sT*Sqr(dTh) + s*cT*ddTh;
  axC:=axB + BC*sT*Sqr(dTh) - BC*cT*ddTh;
  ayC:=ayB - BC*cT*Sqr(dTh) - BC*sT*ddTh;
  axQ:=axP + PQ*cT*Sqr(dTh) + PQ*sT*ddTh;
  ayQ:=ayP + PQ*sT*Sqr(dTh) - PQ*cT*ddTh;

END; {.. RR_T}

{----------------------------------------------------------------------------}
procedure RT_R(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          AC,BP,PQ:double; var xP,yP,vxP,vyP,axP,ayP,
          xC,yC,vxC,vyC,axC,ayC, xQ,yQ,vxQ,vyQ,axQ,ayQ, Delta:double);

{ Solve the kinematics of the RR_T dyad.                                      }
{ If (xB = InfD) OR (yB = InfD) assumes that there is no interest in (xB,yB);}
{ If (xC = InfD) OR (yC = InfD) assumes that there is no interest in (xC,yC);}
{ If (vxA = InfD) OR (vyA = InfD) OR (vxP = InfD) OR (vyP = InfD) OR         }
{ (vxQ = InfD) OR (vyQ = InfD) it assumes that there is no interest in vxB,  }
{ vyB, vxC and vyC;                                                          }
{ If (axA = InfD) OR (ayA = InfD) OR (axP = InfD) OR (ayP = InfD) OR         }
{ (axQ = InfD) OR (ayQ = InfD) it assumes that there is no interest in axB,  }
{ ayB, axC and ayC;                                                          }

var xPP,yPP, xCC,yCC, xQQ,yQQ,  cPhi,sPhi, Phi, dPhi,ddPhi, s,ds,dds,
    a1,b1,c1, a2,b2,c2, Delta_:double;
    DashBPQ,OK:Boolean;

BEGIN {RT_R ..}
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xB,yB);

  DashBPQ:=FALSE;

  s:=Sqr(xB-xA)+Sqr(yB-yA)-Sqr(AC-BP);
  if (s < 0) then BEGIN
    s:=0;  DashBPQ:=TRUE;
  END;
  s:=Sqrt(s);

  cPhi:=((AC-BP)*(xB-xA)-s*(yB-yA))/(Sqr(xB-xA)+Sqr(yB-yA));
  sPhi:=((AC-BP)*(yB-yA)+s*(xB-xA))/(Sqr(xB-xA)+Sqr(yB-yA));
  Phi:=Atan2(sPhi,cPhi);
  if DashBPQ then BEGIN
    cPhi:=cos(Phi);
    sPhi:=sin(Phi);
  END;

  xCC:=xA+AC*cPhi;
  yCC:=yA+AC*sPhi;
  UpdateLimitsWS(xCC,yCC);

  xPP:=xB+BP*cPhi;
  yPP:=yB+BP*sPhi;
  UpdateLimitsWS(xPP,yPP);

  xQQ:=xPP-PQ*sPhi;
  yQQ:=yPP+PQ*cPhi;
  UpdateLimitsWS(xQQ,yQQ);

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Abs(Color));
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if DashBPQ then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth);  SyncDXFLineStyleTkns;
    END;

    LLine(X_p(xB),Y_p(yB),X_p(xPP),Y_p(yPP),X_p(xQQ),Y_p(yQQ),JtSz,0);
    SkLine(X_p(xA),Y_p(yA),X_p(xCC),Y_p(yCC),JtSz,2*JtSz);

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    Block(X_p(xCC),Y_p(yCC),Phi+0.5*Pi);

    if OpaqueJoints then BEGIN
      IncDXFelev;
      IncDXFelev;
    END;
    if (JtSz > 0) AND (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA)) {ground pivot joint at A}
    else
      PDcircle('',X_p(xA),Y_p(yA),JtSz); {pivot joint at A}
    if OpaqueJoints then DecDXFelev;

    if (JtSz > 0) AND (vxB=0) AND (vyB=0) AND (axB=0) AND (ayB=0) then
      gPivotJoint(X_p(xB),Y_p(yB)) {ground pivot joint at B}
    else
      PDcircle('',X_p(xB),Y_p(yB),JtSz); {pivot joint at B}
    if OpaqueJoints then DecDXFelev;

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  xC:=xCC;  yC:=yCC;
  xP:=xPP;  yP:=yPP;
  xQ:=xQQ;  yQ:=yQQ;

  vxC:=InfD;  vyC:=InfD;
  vxP:=InfD;  vyP:=InfD;
  vxQ:=InfD;  vyQ:=InfD;
  if (vxA = InfD) OR (vyA = InfD) OR (vxB = InfD) OR (vyB = InfD)
   then Exit; {no interest in vel & accel ..}

  a1:=s*cPhi-(AC-BP)*sPhi;  b1:= sPhi;  c1:=vxB-vxA;
  a2:=s*sPhi+(AC-BP)*cPhi;  b2:=-cPhi;  c2:=vyB-vyA;
  LinEq2(a1,b1,c1, a2,b2,c2, dPhi,ds, OK);   if NOT OK then Exit;

  vxC:=vxA - AC*sPhi*dPhi;
  vyC:=vyA + AC*cPhi*dPhi;

  vxP:=vxB - BP*sPhi*dPhi;
  vyP:=vyB + BP*cPhi*dPhi;

  vxQ:=vxP - PQ*cPhi*dPhi;
  vyQ:=vyP - PQ*sPhi*dPhi;


  axC:=InfD;  ayC:=InfD;
  axP:=InfD;  ayP:=InfD;
  axQ:=InfD;  ayQ:=InfD;
  if (axA = InfD) OR (ayA = InfD) OR (axB = InfD) OR (ayB = InfD)
  then Exit; {no interest in accelerations..}

  c1:=axB-axA-2*ds*cPhi*dPhi + (s*sPhi+(AC-BP)*cPhi)*dPhi*dPhi;
  c2:=ayB-ayA-2*ds*sPhi*dPhi - (s*cPhi-(AC-BP)*sPhi)*dPhi*dPhi;
  LinEq2(a1,b1,c1, a2,b2,c2, ddPhi,dds, OK);   if NOT OK then Exit;

  axC:=axA-AC*( cPhi*dPhi*dPhi + sPhi*ddPhi);
  ayC:=ayA+AC*(-sPhi*dPhi*dPhi + cPhi*ddPhi);

  axP:=axB-BP*( cPhi*dPhi*dPhi + sPhi*ddPhi);
  ayP:=ayB+BP*(-sPhi*dPhi*dPhi + cPhi*ddPhi);

  axQ:=axP-PQ*(-sPhi*dPhi*dPhi + cPhi*ddPhi);
  ayQ:=ayP-PQ*( cPhi*dPhi*dPhi + sPhi*ddPhi);

END; {..RT_R}

{----------------------------------------------------------------------------}
procedure T_R_T(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          Th1,dTh1,ddTh1, Th2,dTh2,ddTh2,
          P1Q1,Q1C, P2Q2,Q2C:double;  var xC,yC,vxC,vyC,axC,ayC,
          xP1,yP1,vxP1,vyP1,axP1,ayP1, xQ1,yQ1,vxQ1,vyQ1,axQ1,ayQ1,
          xP2,yP2,vxP2,vyP2,axP2,ayP2, xQ2,yQ2,vxQ2,vyQ2,axQ2,ayQ2:double;
          var OK:Boolean);

{ Solve the kinematics of the TRT dyad in its T_R_T embodiment}

var cTh1,sTh1, cTh2,sTh2,
    Aux, xCC,yCC,vxCC,vyCC,
    a1,b1,c1,a2,b2,c2,
    xPP1,yPP1, xQQ1,yQQ1, xPP2,yPP2, xQQ2,yQQ2,
    s1,ds1,dds1, s2,ds2,dds2: double;

BEGIN {T_R_T ..}
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xB,yB);

  cTh1:=cos(Th1);
  sTh1:=sin(Th1);
  cTh2:=cos(Th2);
  sTh2:=sin(Th2);

  a1:=cTh1;  b1:=-cTh2;  c1:=xA-xB+Q1C*sTh1+Q2C*sTh2;
  a2:=sTh1;  b2:=-sTh2;  c2:=yA-yB-Q1C*cTh1-Q2C*cTh2;
  LinEq2(a1,b1,c1, a2,b2,c2, s1,s2, OK);
  if OK then BEGIN
    xQQ1:=xA-s1*cTh1;
    yQQ1:=yA-s1*sTh1;
    UpdateLimitsWS(xQQ1,yQQ1);

    xPP1:=xQQ1-P1Q1*cTh1;
    yPP1:=yQQ1-P1Q1*sTh1;
    UpdateLimitsWS(xPP1,yPP1);

    xQQ2:=xB-s2*cTh2;
    yQQ2:=yB-s2*sTh2;
    UpdateLimitsWS(xQQ2,yQQ2);

    xPP2:=xQQ2-P2Q2*cTh2;
    yPP2:=yQQ2-P2Q2*sTh2;
    UpdateLimitsWS(xPP2,yPP2);

    xCC:=xQQ1+Q1C*sTh1;
    yCC:=yQQ1-Q1C*cTh1;
{   xCC:=xQQ2-Q2C*sTh2;    yCC:=yQQ2+Q2C*cTh2;  }
    UpdateLimitsWS(xCC,yCC);
  END;
{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color > Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Color);
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if NOT OK then BEGIN
      SetLineStyle(DashedLn, 0, NormWidth);  SyncDXFLineStyleTkns;
      PDline('',X_p(xA),Y_p(yA),X_p(xB),Y_p(yB));
    END;
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
    if OK then BEGIN
      LLine(X_p(xCC),Y_p(yCC),X_p(xQQ1),Y_p(yQQ1),X_p(xPP1),Y_p(yPP1),JtSz,0);
      LLine(X_p(xCC),Y_p(yCC),X_p(xQQ2),Y_p(yQQ2),X_p(xPP2),Y_p(yPP2),JtSz,0);
      PDcircle('',X_p(xCC),Y_p(yCC),JtSz); {pivot joint at C}
    END;

    if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then BEGIN
      if (GetDXFlayer <> '1') then SuspendDXF;
      gBlock(X_p(xA),Y_p(yA),Th1);
      ResumeDXF;
    END
    else Block(X_p(xA),Y_p(yA),Th1);
    if (vxB=0) AND (vyB=0) AND (axB=0) AND (ayB=0) then BEGIN
      if (GetDXFlayer <> '1') then SuspendDXF;
      gBlock(X_p(xB),Y_p(yB),Th2);
      ResumeDXF;
    END
    else Block(X_p(xB),Y_p(yB),Th2);

  END; {..draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  if NOT OK then Exit;
  xC :=xCC;   yC :=yCC;
  xP1:=xPP1;  yP1:=yPP1;
  xQ1:=xQQ1;  yQ1:=yQQ1;
  xP2:=xPP2;  yP2:=yPP2;
  xQ2:=xQQ2;  yQ2:=yQQ2;

  vxC :=InfD;   vyC :=InfD;
  vxP1:=InfD;   vyP1:=InfD;
  vxQ1:=InfD;   vyQ1:=InfD;
  vxP2:=InfD;   vyP2:=InfD;
  vxQ2:=InfD;   vyQ2:=InfD;
  if (dTh1 = InfD) OR (vxA = InfD) OR (vyA = InfD)
  OR (vxB = InfD) OR (vyB = InfD) then Exit; {no interest in vel & accel ..}

  c1:=vxA-vxB+dTh1*(yA-yCC)-dTh2*(yB-yCC);
  c2:=vyA-vyB-dTh1*(xA-xCC)+dTh2*(xB-xCC);
  LinEq2(a1,b1,c1, a2,b2,c2, ds1, ds2, OK);  if NOT OK then Exit;
  Aux :=vxA - ds1*cTh1 + dTh1*s1*sTh1;
  vxP1:=Aux + dTh1*P1Q1*sTh1;
  vxCC:=Aux + dTh1*Q1C*cTh1;
  vxC :=vxCC;
  vxQ1:=Aux;

  Aux :=vyA - ds1*sTh1 - dTh1*s1*cTh1;
  vyP1:=Aux - dTh1*P1Q1*cTh1;
  vyCC:=Aux + dTh1*Q1C*sTh1;
  vyC :=vyCC;
  vyQ1:=Aux;

  Aux :=vxB - ds2*cTh2 + dTh2*s2*sTh2;
  vxP2:=Aux + dTh2*P2Q2*sTh2;
  vxQ2:=Aux;

  Aux :=vyB - ds2*sTh2 - dTh2*s2*cTh2;
  vyP2:=Aux - dTh2*P2Q2*cTh2;
  vyQ2:=Aux;

  axC :=InfD;   ayC :=InfD;
  axP1:=InfD;   ayP1:=InfD;
  axQ1:=InfD;   ayQ1:=InfD;
  axP2:=InfD;   ayP2:=InfD;
  axQ2:=InfD;   ayQ2:=InfD;
  if (ddTh1 = InfD) OR (ddTh2 = InfD) OR (axA = InfD) OR (ayA = InfD)
  OR (axB = InfD) OR (ayB = InfD) then Exit;  {no interest in accel ..}
  c1:=axA-axB+ddTh1*(yA-yCC)+dTh1*(vyA-vyCC)-ddTh2*(yB-yCC)
  -dTh2*(vyB-vyCC)+dTh1*ds1*sTh1-dTh2*ds2*sTh2;
  c2:=ayA-ayB-ddTh1*(xA-xCC)+dTh1*(vxA-vxCC)+ddTh2*(xB-xCC)
  +dTh2*(vxB-vxCC)-dTh1*ds1*cTh1+dTh2*ds2*cTh2;
  LinEq2(a1,b1,c1, a2,b2,c2, dds1,dds2, OK);  if NOT OK then Exit;
  Aux :=axA - dds1*cTh1 + 2*dTh1*ds1*sTh1
  +ddTh1*s1*sTh1+Sqr(dTh1)*s1*cTh1;
  axP1:=Aux + ddTh1*P1Q1*sTh1 + Sqr(dTh1)*P1Q1*cTh1;
  axC :=Aux + ddTh1*Q1C*cTh1 - Sqr(dTh1)*Q1C*sTh1;
  axQ1:=Aux;

  Aux :=ayA - dds1*sTh1 - 2*dTh1*ds1*cTh1
  -ddTh1*s1*cTh1+Sqr(dTh1)*s1*sTh1;
  ayP1:=Aux - ddTh1*P1Q1*cTh1 + Sqr(dTh1)*P1Q1*sTh1;
  ayC :=Aux + ddTh1*Q1C*sTh1 - Sqr(dTh1)*Q1C*cTh1;
  ayQ1:=Aux;

  Aux :=axB - dds2*cTh2+2*dTh2*ds2*sTh2
  +ddTh2*s2*sTh2 + Sqr(dTh2)*s2*cTh2;
  axP2:=Aux + ddTh2*P2Q2*sTh2 + Sqr(dTh1)*P2Q2*cTh2;
  axQ2:=Aux;

  Aux :=ayB - dds2*sTh2 - 2*dTh2*ds2*cTh2
  -ddTh2*s2*cTh2 + Sqr(dTh2)*s2*sTh2;
  ayP2:=Aux - ddTh2*P2Q2*cTh2 + Sqr(dTh1)*P2Q2*sTh2;
  ayQ2:=Aux;

END;  {..T_R_T}

{----------------------------------------------------------------------------}
procedure _TRT_(Color:Word; xP1,yP1,vxP1,vyP1,axP1,ayP1,
          xQ1,yQ1,vxQ1,vyQ1,axQ1,ayQ1, xP2,yP2,vxP2,vyP2,axP2,ayP2,
          xQ2,yQ2,vxQ2,vyQ2,axQ2,ayQ2, AC,BC: double;
          var xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          xC,yC,vxC,vyC,axC,ayC: double; var OK:Boolean);

{ Solve the kinematics of the TRT dyad in its T_R_T embodiment}

var cTh1,sTh1, cTh2,sTh2, Th1,dTh1,ddTh1,
    Th2,dTh2,ddTh2, P1Q1,P2Q2, a1,b1,c1,a2,b2,c2,
    xAA,yAA, xBB,yBB, Aux, xCC,yCC,vxCC,vyCC,
    s1,ds1,dds1, s2,ds2,dds2: double;

BEGIN  {_TRT_..}
  UpdateLimitsWS(xP1,yP1);
  UpdateLimitsWS(xQ1,yQ1);
  UpdateLimitsWS(xP2,yP2);
  UpdateLimitsWS(xQ2,yQ2);

  P1Q1:=Sqrt(Sqr(xP1-xQ1)+Sqr(yP1-yQ1));
  Th1:=0.0;
  if (P1Q1 > EpsR) then BEGIN
    AngPVA(xP1,yP1,vxP1,vyP1,axP1,ayP1, xQ1,yQ1,vxQ1,vyQ1,axQ1,ayQ1
    ,Th1,dTh1,ddTh1);
    cTh1:=(xQ1-xP1)/P1Q1;  sTh1:=(yQ1-yP1)/P1Q1;
  END
  else BEGIN
    cTh1:=1.0;  sTh1:=0.0;
    dTh1:=0.0;
    ddTh1:=0.0;
  END;

  P2Q2:=Sqrt(Sqr(xP2-xQ2)+Sqr(yP2-yQ2));
  Th2:=0.0;
  if (P2Q2 > EpsR) then BEGIN
    AngPVA(xP2,yP2,vxP2,vyP2,axP2,ayP2, xQ2,yQ2,vxQ2,vyQ2,axQ2,ayQ2
    ,Th2,dTh2,ddTh2);
    cTh2:=(xQ2-xP2)/P2Q2;  sTh2:=(yQ2-yP2)/P2Q2;
  END
  else BEGIN
    cTh2:=1.0;  sTh2:=0.0;
    dTh2:=0.0;  ddTh2:=0.0;
  END;

  a1:=cTh1;  b1:=-cTh2;  c1:=xP2-xP1-AC*sTh1-BC*sTh2;
  a2:=sTh1;  b2:=-sTh2;  c2:=yP2-yP1+AC*cTh1+BC*cTh2;
  LinEq2(a1,b1,c1, a2,b2,c2, s1,s2, OK);  if NOT OK then Exit;

  xAA:=xP1+s1*cTh1;
  yAA:=yP1+s1*sTh1;
  xBB:=xP2+s2*cTh2;
  yBB:=yP2+s2*sTh2;
  xCC:=xAA+AC*sTh1;
  yCC:=yAA-AC*cTh1;
  UpdateLimitsWS(xCC,yCC);
  UpdateLimitsWS(xAA,yAA);
  UpdateLimitsWS(xBB,yBB);

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color > Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Color);
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;
    SkLine(X_p(xAA),Y_p(yAA),X_p(xCC),Y_p(yCC),0,JtSz);
    SkLine(X_p(xBB),Y_p(yBB),X_p(xCC),Y_p(yCC),0,JtSz);
    PDcircle('',X_p(xCC),Y_p(yCC),JtSz); {pivot joint at C}

    Block(X_p(xAA),Y_p(yAA),Th1);
    Block(X_p(xBB),Y_p(yBB),Th2);

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  xC:=xCC;  yC:=yCC;
  xA:=xAA;  yA:=yAA;
  xB:=xBB;  yB:=yBB;

  vxA:=InfD;   ayA:=InfD;
  vxB:=InfD;   ayB:=InfD;
  vxC:=InfD;   ayC:=InfD;
  if (vxP1 = InfD) OR (vyP1 = InfD) OR (vxQ1 = InfD) OR (vyQ1 = InfD)
  OR (vxP2 = InfD) OR (vyP2 = InfD) OR (vxQ2 = InfD) OR (vyQ2 = InfD)
  then Exit; {no interest in vel & accel ..}

  c1:=vxP2-vxP1+dTh1*(yCC-yP1)-dTh2*(yCC-yP2);
  c2:=vyP2-vyP1-dTh1*(xCC-xP1)+dTh2*(xCC-xP2);
  LinEq2(a1,b1,c1, a2,b2,c2, ds1, ds2, OK);  if NOT OK then Exit;

  Aux :=vxP1 + ds1*cTh1 - dTh1*s1*sTh1;
  vxB :=vxP2 + ds2*cTh2 - dTh2*s2*sTh2;
  vxCC:=Aux  + dTh1*AC*cTh1;
  vxC :=vxCC;
  vxA :=Aux;

  Aux :=vyP1 + ds1*sTh1 + dTh1*s1*cTh1;
  vyB :=vyP2 + ds2*sTh2 + dTh2*s2*cTh2;
  vyCC:=Aux  + dTh1*AC*sTh1;
  vyC :=vyCC;
  vyA :=Aux;

  axA:=InfD;   ayA:=InfD;
  axB:=InfD;   ayB:=InfD;
  axC:=InfD;   ayC:=InfD;
  if (axP1 = InfD) OR (ayP1 = InfD) OR (axQ1 = InfD) OR (ayQ1 = InfD)
  OR (axP2 = InfD) OR (ayP2 = InfD) OR (axQ2 = InfD) OR (ayQ2 = InfD)
  then Exit; {no interest in vel & accel ..}

  c1:=axP2-axP1+ddTh1*(yCC-yP1)-ddTh2*(yCC-yP2)+dTh1*(vyCC-vyP1)
  -dTh2*(vyCC-vyP2)+dTh1*ds1*sTh1-dTh2*ds2*sTh2;
  c2:=ayP2-ayP1-ddTh1*(xCC-xP1)+ddTh2*(xCC-xP2)-dTh1*(vxCC-vxP1)
  +dTh2*(vxCC-vxP2)-dTh1*ds1*cTh1+dTh2*ds2*sTh2;

  LinEq2(a1,b1,c1, a2,b2,c2, dds1,dds2, OK);  if NOT OK then Exit;

  Aux:=axP1 + dds1*cTh1 - 2*dTh1*ds1*sTh1
  - ddTh1*s1*sTh1 - Sqr(dTh1)*s1*cTh1;
  axB:=axP2 + dds2*cTh2 - 2*dTh2*s2*sTh2
  - ddTh2*s2*sTh2 - Sqr(dTh2)*s2*cTh2;
  axC:=Aux + ddTh1*AC*cTh1 - Sqr(dTh1)*AC*sTh1;
  axA:=Aux;

  Aux:=ayP1 + dds1*sTh1 + 2*dTh1*ds1*cTh1
  + ddTh1*s1*cTh1 - Sqr(dTh1)*s1*sTh1;
  ayB:=ayP2 + dds2*sTh2 + 2*dTh2*ds2*cTh2
  + ddTh2*s2*cTh2 - Sqr(dTh2)*s2*sTh2;
  ayC:=Aux + ddTh1*AC*sTh1 + Sqr(dTh1)*AC*cTh1;
  ayA:=Aux;

END;  {.._TRT_}

{----------------------------------------------------------------------------}
procedure T_RT_(Color:Word; xA,yA,vxA,vyA,axA,ayA, Th1,dTh1,ddTh1,
          xP2,yP2,vxP2,vyP2,axP2,ayP2, xQ2,yQ2,vxQ2,vyQ2,axQ2,ayQ2,
          P1Q1,Q1C,BC: double;  var xP1,yP1,vxP1,vyP1,axP1,ayP1,
          xQ1,yQ1,vxQ1,vyQ1,axQ1,ayQ1, xB,yB,vxB,vyB,axB,ayB,
          xC,yC,vxC,vyC,axC,ayC: double;  var OK:Boolean);

{ Solve the kinematics of the TRT dyad in its T_R_T embodiment }

var cTh1,sTh1, cTh2,sTh2, Th2,dTh2,ddTh2,
    a1,b1,c1, a2,b2,c2, s1,ds1,dds1, s2,ds2,dds2,
    Aux, xBB,yBB,xCC,yCC,vxCC,vyCC, xPP1,yPP1, xQQ1,yQQ1, P2Q2: double;

BEGIN  {T_RT_..}
  UpdateLimitsWS(xA ,yA );
  UpdateLimitsWS(xP2,yP2);
  UpdateLimitsWS(xQ2,yQ2);

  cTh1:=cos(Th1);
  sTh1:=sin(Th1);

  P2Q2:=Sqrt(Sqr(xP2-xQ2)+Sqr(yP2-yQ2));
  Th2:=0.0;
  if (P1Q1 > EpsR) then BEGIN
    AngPVA(xP2,yP2,vxP2,vyP2,axP2,ayP2, xQ2,yQ2,vxQ2,vyQ2,axQ2,ayQ2
    ,Th2,dTh2,ddTh2);
    cTh2:=(xQ2-xP2)/P2Q2;  sTh2:=(yQ2-yP2)/P2Q2;
  END
  else BEGIN
    cTh2:=1.0;  sTh2:=0.0;
    dTh2:=0.0;  ddTh2:=0.0;
  END;

  a1:=cTh1;  b1:=cTh2;  c1:=xA-xP2+Q1C*sTh1+BC*sTh2;
  a2:=sTh1;  b2:=sTh2;  c2:=yA-yP2-Q1C*cTh1-BC*cTh2;
  LinEq2(a1,b1,c1, a2,b2,c2, s1,s2, OK);
  if OK then BEGIN
    xQQ1:=xA-s1*cTh1;
    yQQ1:=yA-s1*sTh1;
    xPP1:=xQQ1-P1Q1*cTh1;
    yPP1:=yQQ1-P1Q1*sTh1;
    xCC :=xQQ1+Q1C*sTh1;
    yCC :=yQQ1-Q1C*cTh1;
    xBB :=xP2+s2*cTh2;
    yBB :=yP2+s2*sTh2;
    UpdateLimitsWS(xPP1,yPP1);
    UpdateLimitsWS(xQQ1,yQQ1);
    UpdateLimitsWS(xBB,yBB);
    UpdateLimitsWS(xCC,yCC);
  END;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color > Black) AND (MaxX > 0) then BEGIN  {draw on screen..}
    SetColorBGI_DXF(Color);
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if OK then BEGIN
      LLine(X_p(xCC),Y_p(yCC),X_p(xQQ1),Y_p(yQQ1),X_p(xPP1),Y_p(yPP1),JtSz,0);
      SkLine(X_p(xBB),Y_p(yBB),X_p(xCC),Y_p(yCC),0,JtSz);
      PDcircle('',X_p(xCC),Y_p(yCC),JtSz); {pivot joint at C}
      Block(X_p(xBB),Y_p(yBB),Th2);
    END;
    if (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then BEGIN
      if (GetDXFlayer <> '1') then SuspendDXF;
      gBlock(X_p(xA),Y_p(yA),Th1);
      ResumeDXF;
    END
    else Block(X_p(xA),Y_p(yA),Th1);
  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  if NOT OK then Exit;
  xP1:=xPP1;  yP1:=yPP1;
  xQ1:=xQQ1;  yQ1:=yQQ1;
  xB:=xBB;  yB:=yBB;
  xC:=xCC;  yC:=yCC;

  vxB :=InfD;   vyB:=InfD;
  vxC :=InfD;   vyC:=InfD;
  vxP1:=InfD;   vyP1:=InfD;
  vxQ1:=InfD;   vyQ1:=InfD;
  if (dTh1 = InfD) OR (vxA = InfD) OR (vyA = InfD)
  OR (vxP2 = InfD) OR (vyP2 = InfD) OR (vxQ2 = InfD) OR (vyQ2 = InfD)
  then Exit; {no interest in vel & accel ..}

  c1:=vxA-vxP2-dTh1*(yCC-yA)+dTh2*(yCC-yP2);
  c2:=vyA-vyP2+dTh1*(xCC-xA)-dTh2*(xCC-xP2);
  LinEq2(a1,b1,c1, a2,b2,c2, ds1, ds2, OK);  if NOT OK then Exit;

  Aux :=vxA - ds1*cTh1 + dTh1*s1*sTh1;
  vxP1:=Aux + dTh1*P1Q1*sTh1;
  vxCC:=Aux + dTh1*Q1C*cTh1;
  vxC :=vxCC;
  vxQ1:=Aux;

  Aux :=vyA - ds1*sTh1 - dTh1*s1*cTh1;
  vyP1:=Aux - dTh1*P1Q1*cTh1;
  vyCC:=Aux + dTh1*Q1C*sTh1;
  vyC :=vyCC;
  vyQ1:=Aux;

  vxB :=vxP2 + ds2*cTh2 - dTh2*s2*sTh2;
  vyB :=vyP2 + ds2*sTh2 + dTh2*s2*cTh2;


  axB :=InfD;   ayB:=InfD;
  axC :=InfD;   ayC:=InfD;
  axP1:=InfD;   ayP1:=InfD;
  axQ1:=InfD;   ayQ1:=InfD;
  if (ddTh1 = InfD) OR (axA = InfD) OR (ayA = InfD)
  OR (axP2 = InfD) OR (ayP2 = InfD) OR (axQ2 = InfD) OR (ayQ2 = InfD)
  then Exit;  {no interest in accel ..}

  c1:=axA-axP2-ddTh1*(yCC-yA)+ddTh2*(yCC-yP2)-dTh1*(vyCC-vyA)
  +dTh2*(vyCC-vyP2)+dTh1*ds1*sTh1+dTh2*ds2*sTh2;
  c2:=ayA-ayP2+ddTh1*(xCC-xA)-ddTh2*(xCC-xP2)+dTh1*(vxCC-vxA)
  -dTh2*(vxCC-vxP2)-dTh1*ds1*cTh1-dTh2*ds2*sTh2;
  LinEq2(a1,b1,c1, a2,b2,c2, dds1,dds2, OK);  if NOT OK then Exit;

  Aux :=axA - dds1*cTh1 + 2*dTh1*ds1*sTh1
  +ddTh1*s1*sTh1+Sqr(dTh1)*s1*cTh1;
  axP1:=Aux + ddTh1*P1Q1*sTh1 + Sqr(dTh1)*P1Q1*cTh1;
  axC :=Aux + ddTh1*Q1C*cTh1 - Sqr(dTh1)*Q1C*sTh1;
  axQ1:=Aux;

  Aux :=ayA - dds1*sTh1 - 2*dTh1*ds1*cTh1
  -ddTh1*s1*cTh1+Sqr(dTh1)*s1*sTh1;
  ayP1:=Aux - ddTh1*P1Q1*cTh1 + Sqr(dTh1)*P1Q1*sTh1;
  ayC :=Aux + ddTh1*Q1C*sTh1 - Sqr(dTh1)*Q1C*cTh1;
  ayQ1:=Aux;

  axB:=axP2 + dds2*cTh2 - 2*dTh2*s2*sTh2
  - ddTh2*s2*sTh2 - Sqr(dTh2)*s2*cTh2;
  ayB:=ayP2 + dds2*sTh2 + 2*dTh2*ds2*cTh2
  + ddTh2*s2*cTh2 - Sqr(dTh2)*s2*sTh2;

END;  {..T_RT_}

{----------------------------------------------------------------------------}
procedure R_T_T(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
    Phi,dPhi,ddPhi, AD,DK,PQ,QC, Alpha1,Alpha2:double;
    var xC,yC,vxC,vyC,axC,ayC, xD,yD,vxD,vyD,axD,ayD, xK,yK,vxK,vyK,axK,ayK,
    xP,yP,vxP,vyP,axP,ayP, xQ,yQ,vxQ,vyQ,axQ,ayQ:double; var OK:Boolean);

{ Solve the kinematics of an RTT dyad in its R_T_T embodiment                }

var xCC,yCC, xDD,yDD, xKK,yKK, xPP,yPP, xQQ,yQQ, s1,ds1,dds1, s2,ds2,dds2,
    cP,sP,cPA2,sPA2,cPA21,sPA21, a1,b1,c1, a2,b2,c2, Aux:double;

BEGIN  {R_T_T ..}
  cP:=cos(Phi);
  sP:=sin(Phi);
  cPA2 :=cos(Phi+Alpha2);
  sPA2 :=sin(Phi+Alpha2);
  cPA21:=cos(Phi+Alpha2-Alpha1);
  sPA21:=sin(Phi+Alpha2-Alpha1);

  a1:=cPA21;  b1:=-cP;
  a2:=sPA21;  b2:=-sP;
  c1:=xB-xA+QC*cPA2-AD*sPA21;
  c2:=yB-yA+QC*sPA2+AD*cPA21;
  LinEq2(a1,b1,c1, a2,b2,c2, s1,s2, OK);
  if OK then BEGIN
    xDD:=xA + AD*sPA21;
    yDD:=yA - AD*cPA21;
    UpdateLimitsWS(xDD,yDD);

    xKK:=xDD + DK*cPA21;
    yKK:=yDD + DK*sPA21;
    UpdateLimitsWS(xKK,yKK);

    xQQ:=xB + s2*cP;
    yQQ:=yB + s2*sP;
    UpdateLimitsWS(xQQ,yQQ);

    xPP:=xQQ - PQ*cP;
    yPP:=yQQ - PQ*sP;
    UpdateLimitsWS(xPP,yPP);

    xCC:=xDD + s1*cPA21;
    yCC:=yDD + s1*sPA21;
    UpdateLimitsWS(xCC,yCC);
  END;
{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color > Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Color);
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if OK then BEGIN
      LLine(X_p(xA),Y_p(yA),X_p(xDD),Y_p(yDD),X_p(xKK),Y_p(yKK),JtSz,0);
      LLine(X_p(xPP),Y_p(yPP),X_p(xQQ),Y_p(yQQ),X_p(xCC),Y_p(yCC),0,0);
      Block(X_p(xCC),Y_p(yCC), Phi+Alpha2-Alpha1);
    END;

    if (JtSz > 0) AND (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA))  {ground pivot joint at A}
    else
      PDcircle('',X_p(xA),Y_p(yA),JtSz);  {pivot joint at A}

    if (JtSz > 0) AND (dPhi = 0) AND (ddPhi = 0) then
     gBlock(X_p(xB),Y_p(yB), Phi)
    else
     Block(X_p(xB),Y_p(yB), Phi);

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  if OK then BEGIN
    xC:=xCC;  yC:=yCC;
    xD:=xDD;  yD:=yDD;
    xK:=xKK;  yK:=yKK;
    xP:=xPP;  yP:=yPP;
    xQ:=xQQ;  yQ:=yQQ;
  END;

  vxB:=InfD;   vyB:=InfD;
  vxC:=InfD;   vyC:=InfD;
  vxD:=InfD;   vyD:=InfD;
  vxP:=InfD;   vyP:=InfD;
  vxQ:=InfD;   vyQ:=InfD;
  if (vxA = InfD) OR (vyA = InfD) OR
  (vxB = InfD) OR (vyB = InfD) then Exit; {no interest in vel & accel ..}

  c1:=vxB-vxA+(yB-yA)*dPhi;
  c2:=vyB-vyA+(xB-xA)*dPhi;
  LinEq2(a1,b1,c1, a2,b2,c2, ds1,ds2, OK);

  Aux:=vxA + dPhi*AD*cPA21; {..=vxD}
  vxK:=Aux - dPhi*DK*sPA21;
  vxD:=Aux;
  Aux:=vxB + ds2*cP - dPhi*s2*sP; {..=vxQ}
  vxP:=Aux + dPhi*PQ*sP;
  vxC:=Aux - dPhi*QC*sPA2;
  vxQ:=Aux;

  Aux:=vyA + dPhi*AD*sPA21; {..=vyD}
  vyK:=Aux + dPhi*DK*cPA21;
  vyD:=Aux;
  Aux:=vyB + ds2*sP + dPhi*s2*cP; {..=vyQ}
  vyP:=Aux - dPhi*PQ*cP;
  vyC:=Aux + dPhi*QC*cPA2;
  vyQ:=Aux;


  axB:=InfD;   ayB:=InfD;
  axC:=InfD;   ayC:=InfD;
  axD:=InfD;   ayD:=InfD;
  axP:=InfD;   ayP:=InfD;
  axQ:=InfD;   ayQ:=InfD;
  if (axA = InfD) OR (ayA = InfD) OR
  (axB = InfD) OR (ayB = InfD) then Exit; {no interest in vel & accel ..}

  c1:=axB-axA+ddPhi*(yB-yD)+dPhi*(vyB-vyA)+ds1*dPhi*sPA21-ds2*dPhi*sP;
  c2:=ayB-ayA-ddPhi*(xB-xD)-dPhi*(vxB-vxA)-ds1*dPhi*cPA21+ds2*dPhi*cP;
  LinEq2(a1,b1,c1, a2,b2,c2,dds1,dds2, OK);

  Aux:=axA + ddPhi*AD*cPA21 - Sqr(dPhi)*AD*sPA21; {..=axD}
  axK:=Aux - ddPhi*DK*sPA21 - Sqr(dPhi)*DK*cPA21;
  axD:=Aux;
  axQ:=axB + dds2*cP - 2*ds2*dPhi*sP - ddPhi*s2*sP - Sqr(dPhi)*s2*cP; {..=axQ}
  axP:=Aux + ddPhi*PQ*sP + Sqr(dPhi)*PQ*cP;
  axC:=Aux - ddPhi*QC*sPA2 - Sqr(dPhi)*QC*cPA2;
  axQ:=Aux;

  Aux:=ayA + ddPhi*AD*sPA21 + Sqr(dPhi)*AD*cPA21; {..=ayD}
  ayK:=Aux + ddPhi*DK*cPA21 - Sqr(dPhi)*DK*sPA21;
  vyD:=Aux;
  ayQ:=ayB + dds2*sP + 2*ds2*dPhi*cP + ddPhi*s2*cP - Sqr(dPhi)*s2*sP; {..=ayQ}
  ayP:=ayQ - ddPhi*PQ*cP + Sqr(dPhi)*PQ*sP;
  ayC:=ayQ + ddPhi*QC*cPA2 - Sqr(dPhi)*QC*sPA2;
  vyQ:=Aux;
  _:=InfD;
{
  xQ :=s1;
  yQ :=s2;
  vxQ:=ds1;
  vyQ:=ds2;
  axQ:=dds1;
  ayQ:=dds2;
}
END;  {..R_T_T}

{----------------------------------------------------------------------------}
procedure RT_T_(Color:Word; xA,yA,vxA,vyA,axA,ayA, xP,yP,vxP,vyP,axP,ayP,
          xQ,yQ,vxQ,vyQ,axQ,ayQ, AC,BD,Alpha2:double;
          var xB,yB,vxB,vyB,axB,ayB, xC,yC,vxC,vyC,axC,ayC,
          xD,yD,vxD,vyD,axD,ayD:double; var OK:Boolean);

{ Solve the kinematics of a RT_T_ dyad                                         }

var PQ, Phi,dPhi,ddPhi, xBB,yBB, xCC,yCC, xDD,yDD,
    s1,ds1,dds1, s2,ds2,dds2,
    cP,sP,cPA2,sPA2, a1,b1,c1, a2,b2,c2, Aux:double;

BEGIN  {R_T_T..}
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xP,yP);
  UpdateLimitsWS(xQ,yQ);

  PQ:=Sqrt(Sqr(xP-xQ)+Sqr(yP-yQ));
  Phi:=0.0;
  if (PQ > EpsR) then BEGIN
    AngPVA(xP,yP,vxP,vyP,axP,ayP, xQ,yQ,vxQ,vyQ,axQ,ayQ, Phi,dPhi,ddPhi);
    cP:=(xQ-xP)/PQ;
    sP:=(yQ-yP)/PQ;
  END
  else BEGIN
    cP:=1.0;
    sP:=0.0;
    dPhi:=0.0; ddPhi:=0.0;
  END;
  cPA2:=cos(Phi+Alpha2);
  sPA2:=sin(Phi+Alpha2);

  a1:=cPA2;  b1:=cP;
  a2:=sPA2;  b2:=sP;
  c1:=xA-xP+AC*sPA2;
  c2:=yA-yP-AC*cPA2;
  LinEq2(a1,b1,c1, a2,b2,c2, s1,s2, OK);
  if OK then BEGIN
    xBB:=xP + s2*CP;
    yBB:=yP + s2*SP;
    UpdateLimitsWS(xBB,yBB);

    xDD:=xBB + BD*cPA2;
    yDD:=yBB + BD*sPA2;
    UpdateLimitsWS(xDD,yDD);

    xCC:=xA + AC*sPA2;
    yCC:=yA - AC*cPA2;
    UpdateLimitsWS(xCC,yCC);
  END;

{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color > Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Color);
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if (JtSz > 0) AND (vxP=0) AND (vyP=0) AND (axP=0) AND (ayP=0)
    AND (vxQ=0) AND (vyQ=0) AND (axQ=0) AND (ayQ=0) then
     GroundLine(X_p(xP),Y_p(yP),X_p(xQ),Y_p(yQ))
    else
     PDline('',X_p(xP),Y_p(yP),X_p(xQ),Y_p(yQ));

    if OK then BEGIN
      PDline('',X_p(xBB),Y_p(yBB),X_p(xDD),Y_p(yDD));
      SkLine(X_p(xA),Y_p(yA),X_p(xCC),Y_p(yCC),JtSz,0);
      Block(X_p(xBB),Y_p(yBB), Phi);
      Block(X_p(xCC),Y_p(yCC), Phi+Alpha2);
    END;

    if (JtSz > 0) AND (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA))  {ground pivot joint at A}
    else
      PDcircle('',X_p(xA),Y_p(yA),JtSz);  {pivot joint at A}

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  if OK then BEGIN
    xB:=xBB;  yB:=yBB;
    xC:=xCC;  yC:=yCC;
    xD:=xDD;  yD:=yDD;
  END;

  vxB:=InfD;   vyB:=InfD;
  vxC:=InfD;   vyC:=InfD;
  vxD:=InfD;   vyD:=InfD;
  if (vxA = InfD) OR (vyA = InfD) OR (vxP = InfD) OR (vyP = InfD)
  OR (vxQ = InfD) OR (vyQ = InfD) then Exit; {no interest in vel & accel ..}

  c1:=vxA-vxP + (yA-yP)*dPhi;
  c2:=vyA-vyP - (xA-xP)*dPhi;
  LinEq2(a1,b1,c1, a2,b2,c2, ds1,ds2, OK);

  Aux:=vxP + ds2*cPA2 - dPhi*s2*sP; {..=vxB}
  vxD:=Aux - dPhi*BD*sPA2;
  vxB:=Aux;
  vxC:=vxA + dPhi*AC*cPA2;

  Aux:=vyP + ds2*sPA2 + dPhi*s2*cP; {..=vyB}
  vyD:=Aux + dPhi*BD*cPA2;
  vyB:=Aux;
  vyC:=vyA + dPhi*AC*sPA2;


  axB:=InfD;   ayB:=InfD;
  axC:=InfD;   ayC:=InfD;
  axD:=InfD;   ayD:=InfD;
  if (axA = InfD) OR (ayA = InfD) OR (axP = InfD) OR (ayP = InfD)
  OR (axQ = InfD) OR (ayQ = InfD) then Exit; {no interest in accel ..}

  c1:=axA-axP+ddPhi*(yA-yP)+dPhi*(vyA-vyP)+ds1*dPhi*sPA2+ds2*dPhi*sP;
  c2:=ayA-ayP-ddPhi*(xA-xP)-dPhi*(vxA-vxP)-ds1*dPhi*cPA2-ds2*dPhi*cP;
  LinEq2(a1,b1,c1, a2,b2,c2,dds1,dds2, OK);

  Aux:=axP + dds2*cP - 2*dPhi*ds2*sP - ddPhi*s2*sP - Sqr(dPhi)*s2*cP; {..=axB}
  axD:=Aux - ddPhi*BD*sPA2 - Sqr(dPhi)*BD*cPA2;
  axB:=Aux;
  axC:=axA + ddPhi*AC*cPA2 - Sqr(dPhi)*AC*sPA2;

  Aux:=ayP + dds2*sP + 2*dPhi*ds2*cP + ddPhi*s2*cP - Sqr(dPhi)*s2*sP; {..=ayB}
  ayD:=Aux + ddPhi*BD*cPA2 - Sqr(dPhi)*BD*sPA2;
  ayB:=Aux;
  ayC:=ayA + ddPhi*AC*sPA2 + Sqr(dPhi)*AC*cPA2;

END;  {..RT_T_}

{----------------------------------------------------------------------------}
procedure R_TT_(Color:Word; xA,yA,vxA,vyA,axA,ayA, xP,yP,vxP,vyP,axP,ayP,
          xQ,yQ,vxQ,vyQ,axQ,ayQ, AD,DK,BC, Alpha1,Alpha2:double; var xB,yB
          ,vxB,vyB,axB,ayB, xC,yC,vxC,vyC,axC,ayC, xD,yD,vxD,vyD,axD,ayD,
          xK,yK,vxK,vyK,axK,ayK:double; var OK:Boolean);

{ Solve the kinematics of a R_TT_ dyad                                       }

var PQ, Phi,dPhi,ddPhi, xBB,yBB, xCC,yCC, xDD,yDD, xKK,yKK,
    s1,ds1,dds1, s2,ds2,dds2, cP,sP,cPA2,sPA2,cPA21,sPA21,
    a1,b1,c1, a2,b2,c2, Aux:double;

BEGIN
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xP,yP);
  UpdateLimitsWS(xQ,yQ);

  PQ:=Sqrt(Sqr(xP-xQ)+Sqr(yP-yQ));
  Phi:=0.0;
  if (PQ > EpsR) then BEGIN
    AngPVA(xP,yP,vxP,vyP,axP,ayP, xQ,yQ,vxQ,vyQ,axQ,ayQ, Phi,dPhi,ddPhi);
    cP:=(xQ-xP)/PQ;  sP:=(yQ-yP)/PQ;
  END
  else BEGIN
    cP:=1.0;    sP:=0.0;
    dPhi:=0.0;  ddPhi:=0.0;
  END;
  cPA2 :=cos(Phi+Alpha2);
  sPA2 :=sin(Phi+Alpha2);
  cPA21:=cos(Phi+Alpha2-Alpha1);
  sPA21:=sin(Phi+Alpha2-Alpha1);

  a1:=cPA21;  b1:=-cP;
  a2:=sPA21;  b2:=-sP;
  c1:=xP-xA-AD*sPA21+BC*cPA2;
  c2:=yP-yA+AD*cPA21+BC*sPA2;
  LinEq2(a1,b1,c1, a2,b2,c2, s1,s2, OK);
  if OK then BEGIN
    xBB:=xP + s2*cP;
    yBB:=yP + s2*sP;
    UpdateLimitsWS(xBB,yBB);

    xDD:=xA + AD*sPA21;
    yDD:=yA - AD*cPA21;
    UpdateLimitsWS(xDD,yDD);

    xCC:=xDD + s1*cPA21;
    yCC:=yDD + s1*sPA21;
    UpdateLimitsWS(xCC,yCC);

    xKK:=xDD + DK*cPA21;
    yKK:=yDD + DK*sPA21;
    UpdateLimitsWS(xKK,yKK);
  END;
{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color > Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Color);
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if (JtSz > 0) AND (vxP=0) AND (vyP=0) AND (axP=0) AND (ayP=0)
    AND (vxQ=0) AND (vyQ=0) AND (axQ=0) AND (ayQ=0) then
     GroundLine(X_p(xP),Y_p(yP),X_p(xQ),Y_p(yQ))
    else
     PDline('',X_p(xP),Y_p(yP),X_p(xQ),Y_p(yQ));
    if OK then BEGIN
      LLine(X_p(xA),Y_p(yA),X_p(xDD),Y_p(yDD),X_p(xKK),Y_p(yKK),JtSz,0);
      PDline('',X_p(xBB),Y_p(yBB),X_p(xCC),Y_p(yCC));
      Block(X_p(xBB),Y_p(yBB), Phi);
      Block(X_p(xCC),Y_p(yCC), Phi+Alpha2-Alpha1);
    END;

    PDcircle('',X_p(xA),Y_p(yA),JtSz);  {pivot joint at A}

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  if OK then BEGIN
    xB:=xBB;  yB:=yBB;
    xC:=xCC;  yC:=yCC;
    xD:=xDD;  yD:=yDD;
    xK:=xKK;  yK:=yKK;
  END;

  vxB:=InfD;  vyB:=InfD;
  vxC:=InfD;  vyC:=InfD;
  vxD:=InfD;  vyD:=InfD;
  vxK:=InfD;  vyK:=InfD;
  if (vxA = InfD) OR (vyA = InfD) OR (vxP = InfD) OR (vyP = InfD)
  OR (vxQ = InfD) OR (vyQ = InfD) then Exit; {no interest in vel & accel ..}

  c1:=vxA-vxP + (yA-yP)*dPhi;
  c2:=vyA-vyP - (xA-xP)*dPhi;
  LinEq2(a1,b1,c1, a2,b2,c2, ds1,ds2, OK);

  vxB:=vxP + ds2*cP - dPhi*s2*sP;
  Aux:=vxA + dPhi*AD*cPA21;        {..=vxD}
  vxC:=Aux + ds1*cPA21 - dPhi*s1*sPA21;
  vxK:=Aux - dPhi*DK*sPA21;
  vxD:=Aux;

  vyB:=vyP + ds2*sP + dPhi*s2*cP;
  Aux:=vyA + dPhi*AD*sPA21;        {..=vyD}
  vyC:=Aux + ds1*sPA21 + dPhi*s1*cPA21;
  vyK:=Aux + dPhi*DK*cPA21;
  vyD:=Aux;


  axB:=InfD;  ayB:=InfD;
  axC:=InfD;  ayC:=InfD;
  axD:=InfD;  ayD:=InfD;
  axK:=InfD;  ayK:=InfD;
  if (axA = InfD) OR (ayA = InfD) OR (axP = InfD) OR (ayP = InfD)
  OR (axQ = InfD) OR (ayQ = InfD) then Exit; {no interest in accel ..}

  c1:=axA-axP+ddPhi*(yA-yP)+dPhi*(vyA-vyP)+ds1*dPhi*sPA2+ds2*dPhi*sP;
  c2:=ayA-ayP-ddPhi*(xA-xP)-dPhi*(vxA-vxP)-ds1*dPhi*cPA2-ds2*dPhi*cP;
  LinEq2(a1,b1,c1, a2,b2,c2,dds1,dds2, OK);

  axB:=axP + dds2*cP - 2*dPhi*ds2*sP - ddPhi*s2*sP - Sqr(dPhi)*s2*cP; {..=axB}
  Aux:=axA + ddPhi*AD*cPA21 - Sqr(dPhi)*AD*sPA21;   {..=axD}
  axC:=Aux + dds1*cPA21 - 2*dPhi*ds1*sPA21 - ddPhi*s1*sPA21 - Sqr(dPhi)*s1*cPA21;
  axK:=Aux - ddPhi*DK*sPA21 - Sqr(dPhi)*DK*cPA21;
  axD:=Aux;

  ayB:=ayP + dds2*sP + 2*ds2*dPhi*cP + ddPhi*s2*cP - Sqr(dPhi)*s2*sP; {..=ayB}
  Aux:=ayA + ddPhi*AD*sPA21 + Sqr(dPhi)*AD*cPA21;   {..=vyD}
  ayC:=Aux + dds1*sPA21 + 2*dPhi*ds1*cPA21 + ddPhi*s1*cPA21 - Sqr(dPhi)*s1*sPA21;
  ayK:=Aux + ddPhi*DK*cPA21 - Sqr(dPhi)*DK*sPA21;
  ayD:=Aux;

END; {..R_TT_}

{----------------------------------------------------------------------------}
procedure RT__T(Color:Word; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
          Phi,dPhi,ddPhi, AC,PQ,QD, Alpha2:double; var xC,yC,vxC,vyC,axC,ayC,
          xD,yD,vxD,vyD,axD,ayD, xP,yP,vxP,vyP,axP,ayP,
          xQ,yQ,vxQ,vyQ,axQ,ayQ:double; var OK:Boolean);

{ Solve the kinematics of a RT__T dyad                                       }

var xCC,yCC, xPP,yPP, xQQ,yQQ, xDD,yDD,
    s1,ds1,dds1, s2,ds2,dds2,
    cP,sP,cPA2,sPA2, a1,b1,c1, a2,b2,c2, Aux:double;

BEGIN
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xB,yB);

  cP   :=cos(Phi);
  sP   :=sin(Phi);
  cPA2 :=cos(Phi+Alpha2);
  sPA2 :=sin(Phi+Alpha2);

  a1:=cPA2;  b1:=-cP;
  a2:=sPA2;  b2:=-sP;
  c1:=xA-xB+AC*sPA2;
  c2:=yA-yB-AC*cPA2;
  LinEq2(a1,b1,c1, a2,b2,c2, s1,s2, OK);
  if OK then BEGIN
    xQQ:=xB - s2*cP;
    yQQ:=yB - s2*sP;
    UpdateLimitsWS(xQQ,yQQ);

    xDD:=xQQ + QD*cPA2;
    yDD:=yQQ + QD*sPA2;
    UpdateLimitsWS(xDD,yDD);

    xPP:=xQQ - PQ*cP;
    yPP:=yQQ - PQ*sP;
    UpdateLimitsWS(xPP,yPP);

    xCC:=xA + AC*sPA2;
    yCC:=yA - AC*cPA2;
    UpdateLimitsWS(xCC,yCC);
  END;
{- - - - - - - - - - - - - - - - - - - - - - -}
  if (Color > Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Color);
    SetLineStyle(SolidLn, 0, NormWidth);  SyncDXFLineStyleTkns;

    if OK then BEGIN
      LLine(X_p(xPP),Y_p(yPP),X_p(xQQ),Y_p(yQQ),X_p(xDD),Y_p(yDD),0,0);
      SkLine(X_p(xA),Y_p(yA),X_p(xCC),Y_p(yCC),JtSz,0);
      Block(X_p(xCC),Y_p(yCC), Phi+Alpha2);
    END;

    if (JtSz > 0) AND (vxB=0) AND (vyB=0) AND (axB=0) AND (ayB=0)
    AND (dPhi = 0) AND (ddPhi = 0) then
     gBlock(X_p(xB),Y_p(yB),Phi)
    else
     Block(X_p(xB),Y_p(yB),Phi);

    if (JtSz > 0) AND (vxA=0) AND (vyA=0) AND (axA=0) AND (ayA=0) then
      gPivotJoint(X_p(xA),Y_p(yA))  {ground pivot joint at A}
    else
      PDcircle('',X_p(xA),Y_p(yA),JtSz);  {pivot joint at A}

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - -}
  if OK then BEGIN
    xD:=xDD;  yD:=yDD;
    xC:=xCC;  yC:=yCC;
    xP:=xPP;  yP:=yPP;
    xQ:=xQQ;  yQ:=yQQ;
  END;

  vxC:=InfD;  vyC:=InfD;
  vxD:=InfD;  vyD:=InfD;
  vxP:=InfD;  vyP:=InfD;
  vxQ:=InfD;  vyQ:=InfD;
  if (vxA = InfD) OR (vyA = InfD) OR (vxB = InfD) OR (vyB = InfD)
  OR (dPhi = InfD) then Exit; {no interest in vel & accel ..}

  c1:=vxA-vxB + (yA-yB)*dPhi;
  c2:=vyA-vyB - (xA-xB)*dPhi;
  LinEq2(a1,b1,c1, a2,b2,c2, ds1,ds2, OK);


  axC:=InfD;  ayC:=InfD;
  axD:=InfD;  ayD:=InfD;
  axP:=InfD;  ayP:=InfD;
  axQ:=InfD;  ayQ:=InfD;
  if (axA = InfD) OR (ayA = InfD) OR (axP = InfD) OR (ayP = InfD)
  OR (axQ = InfD) OR (ayQ = InfD) then Exit; {no interest in accel ..}

  c1:=axA-axP+ddPhi*(yA-yP)+dPhi*(vyA-vyP)+ds1*dPhi*sPA2+ds2*dPhi*sP;
  c2:=ayA-ayP-ddPhi*(xA-xP)-dPhi*(vxA-vxP)-ds1*dPhi*cPA2-ds2*dPhi*cP;
  LinEq2(a1,b1,c1, a2,b2,c2,dds1,dds2, OK);

END; {.. RT__T}


{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
procedure _GG_(Color:Integer; var Angle: double;  xA,yA,vxA,vyA,axA,ayA,
          xB,yB,vxB,vyB,axB,ayB,  xC,yC,vxC,vyC,axC,ayC,
          CD,k,GrAsRat:double; var xD,yD,vxD,vyD,axD,ayD:double);
{ Calculates xD,yD,vxD,vyD,axD,ayD of point D on gear 2 centers at C, meshing}
{ with gear 1 centerd at B that has point A attached to it.                  }

var Th0,dTh0,ddTh0, Th1,dTh1,ddTh1, Th2,dTh2,ddTh2,
    xDD,yDD, r1, r2, BC, x1,y1,x2,y2, x1p,y1p,x2p,y2p: double;
    OK: Boolean;

BEGIN {_GG_ ..}
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xB,yB);
  UpdateLimitsWS(xC,yC);

  Th1:=Angle; {.. for continuity!!}
  Ang3PVA(xC,yC,vxC,vyC,axC,ayC, xB,yB,vxB,vyB,axB,ayB,
  xA,yA,vxA,vyA,axA,ayA, Th1,dTh1,ddTh1);
  Angle:=Th1;
  Th2  :=Th1/k;
  dTh2 :=dTh1/k;
  ddTh2:=ddTh1/k;

  Th0:=0;
  Ang3PVA(xB+10,yB,0,0,0,0, xB,yB,vxB,vyB,axB,ayB,
  xC,yC,vxC,vyC,axC,ayC, Th0,dTh0,ddTh0);

  Th2  :=Th0   + Th2;    {Th2 is now Th02 !!}
  dTh2 :=dTh0  + dTh2;
  ddTh2:=ddTh0 + ddTh2;

  xDD:=xC - CD*cos(Th2);
  yDD:=yC - CD*sin(Th2);
  UpdateLimitsWS(xDD,yDD);

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    GrAsRat:=Abs(GrAsRat);
    SetColorBGI_DXF(Abs(Color));
    SetLineStyle(DashedLn, 0, NormWidth);   SyncDXFLineStyleTkns;
    BC:=Sqrt(Sqr(xB-xC)+Sqr(yB-yC));

    if (GrAsRat > 1) then GrAsRat:=1.0;
    if (GrAsRat < 0.1) then GrAsRat:=0.1;

    BC:=BC*GrAsRat;  {gap between sprockets}
    r1:=BC/(1+Abs(k));
    r2:=BC-r1;
    if (k <> 0) then BEGIN
      PDcircle('',X_p(xB),Y_p(yB),R_p121(r1));
      PDcircle('',X_p(xC),Y_p(yC),R_p121(r2));
    END;
    if (k > 0) then BEGIN
      ExtTang2Circ(xB,yB,r1, xC,yC,r2, x1,y1,x2,y2, x1p,y1p,x2p,y2p, OK);
      if OK then BEGIN
        PDline('',X_p(x1),Y_p(y1),X_p(x2),Y_p(y2));
        PDline('',X_p(x1p),Y_p(y1p),X_p(x2p),Y_p(y2p));
      END;
    END;
    if (k < 0) AND (GrAsRat < 1) then BEGIN
      CrosTang2Circ(xB,yB,r1, xC,yC,r2, x1,y1,x2,y2, x1p,y1p,x2p,y2p, OK);
      if OK then BEGIN
        PDline('',X_p(x1),Y_p(y1),X_p(x2),Y_p(y2));
        PDline('',X_p(x1p),Y_p(y1p),X_p(x2p),Y_p(y2p));
      END;
    END;

    SetLineStyle(SolidLn, 0, NormWidth);   SyncDXFLineStyleTkns;
    SkLine(X_p(xC),Y_p(yC),X_p(xDD),Y_p(yDD),JtSz,0);
    if (r1 < Dist2Pts2D(xA,yA,xB,yB)) then
      LockPoint(Color,xB,yB,xB+r1*cos(Th0+Th1),yB+r1*sin(Th0+Th1));
    if (r2 < CD) then
      LockPoint(Color,xC,yC,xC-r2*cos(Th2),yC-r2*sin(Th2));

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
  xD :=xDD;    yD :=yDD;
  vxD:=InfD;   vyD:=InfD;
  axD:=InfD;   ayD:=InfD;

  if (vxA = InfD) OR (vyA = InfD) OR
  (vxB = InfD) OR (vyB = InfD) OR (vxC = InfD) OR (vyC = InfD) then Exit;
  vxD:=vxC + (yC-yDD)*dTh2;
  vyD:=vyC - (xC-xDD)*dTh2;

  if (axA = InfD) OR (ayA = InfD) OR
  (axB = InfD) OR (ayB = InfD) OR (axC = InfD) OR (ayC = InfD) then Exit;
  axD:=axC + (vyC-vyD)*dTh2 + (yC-yDD)*ddTh2;
  ayD:=ayC - (vxC-vxD)*dTh2 - (xC-xDD)*ddTh2;

END; {.. _GG_}

{----------------------------------------------------------------------------}
procedure RGGR(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xD,yD,vxD,vyD,axD,ayD,
  AB,BC,CD, k, GrAsRat:double; PlsMns:Integer;
  var Th, xB,yB,vxB,vyB,axB,ayB ,xC,yC,vxC,vyC,axC,ayC:double);
{ Returns xB,yB,vxB,vyB,axB,ayB and xC,yC,vxC,vyC,axC,ayC of centers B and C }
{ of two meshing gears centerd at B and C.                                   }

var Ph1,dPh1,ddPh1, Ph2,dPh2,ddPh2, Ph3,dPh3,ddPh3,
    Th1,dTh1,ddTh1, Th2,dTh2,ddTh2, a1,b1,c1, Delta, AD,
    xBB,yBB, xCC,yCC, r1,r2, x1,y1,x2,y2, x1p,y1p,x2p,y2p,
    cTh,sTh, cPh1,sPh1, cPh3,sPh3: double;
    OK,OKc: Boolean;

function Func(var Th0:double): double;
BEGIN
  cTh:=cos(Th0);
  sTh:=sin(Th0);
  a1:=2*((xA-xD)*AB + (xA-xD)*BC*cTh + (yA-yD)*BC*sTh);
  b1:=2*((yA-yD)*AB + (yA-yD)*BC*cTh - (xA-xD)*BC*sTh);
  c1:=CD*CD-AB*AB-BC*BC-Sqr(xA-xD)-Sqr(yA-yD)-2*AB*BC*cTh;
  Delta:=a1*a1 + b1*b1 - c1*c1;
  if (Delta < 0) then BEGIN
    Delta:=0;
    OK:=FALSE;
  END;
  Ph1:=Atan2(b1,a1) - PlsMns*Atan2(Sqrt(Delta),c1);
  cPh1:=cos(Ph1);
  sPh1:=sin(Ph1);
  cPh3:=(AB*cPh1+BC*cTh*cPh1-BC*sTh*sPh1+xA-xD)/CD;
  sPh3:=(AB*sPh1+BC*sTh*cPh1+BC*cTh*sPh1+yA-yD)/CD;
  xBB:=xA + AB*cPh1;
  yBB:=yA + AB*sPh1;
  xCC:=xD  +CD*cPh3;
  yCC:=yD + CD*sPh3;
  Th1:=U3pts2D(xCC,yCC, xBB,yBB, xA,yA);
  Th2:=U3pts2D(xBB,yBB, xCC,yCC, xD,yD);
  Func:=Th1-Th2*k;
END; {.. Func}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure FindZero(var Th0: double; D_Th: double; var Succes: Boolean);
var  vF0, vF_1, Th_1: double;   n: integer;
BEGIN
  Succes:=TRUE;
  vF0:=Func(Th0);
  n:=0;
  repeat
    Th_1:=Th0;
    vF_1:=vF0;
    Th0:=Th0+D_Th;
    vF0:=Func(Th0);
    n:=n+1;
    if (vF0 > 0) AND (vF0 > vF_1) then D_Th:=-D_Th;
    if (vF0 < 0) AND (vF0 < vF_1) then D_Th:=-D_Th;
  until (vF0*vF_1 < 0.0) OR (n >= 500);
  {a zero of Func(..) is bracketed by Th_1 and Th0 ..}
  repeat {secant method (1) ..}
    if Abs(vF0 - vF_1) < EpsR then vF0:=vF0+EpsR;
    Th:=Th0-vF0*(Th0-Th_1)/(vF0-vF_1);
    Th_1:=Th0;
    vF_1:=vF0;
    Th0:=Th;
    vF0:=Func(Th0);
    n:=n+1;
  until (n >= 1000) OR (Abs(Th0 - Th_1) < 1.0E-9);
  if (n >= 1000) then Succes:=FALSE;
END; {.. FindZero}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
BEGIN {RGGR ..}
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xD,yD);
  AD:=Dist2Pts2D(xA,yA,xD,yD);
  OK:=FALSE;
  if isFourBar(AB,BC,CD,AD) then BEGIN
    FindZero(Th,0.02*Pi,OK); {.. return Th & refresh xBB,yBB,xCC,yCC, Phi1,Phi2,Th1,Th2}
    UpdateLimitsWS(xBB,yBB);
    UpdateLimitsWS(xCC,yCC);
  END;
  if NOT OK then BEGIN
    xBB:=xA;  yBB:=yA;
    xCC:=xD;  yCC:=yD;
  END;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    GrAsRat:=Abs(GrAsRat);
    SetColorBGI_DXF(Abs(Color));

    SetLineStyle(DashedLn, 0, NormWidth);   SyncDXFLineStyleTkns;

    if (GrAsRat > 1) then GrAsRat:=1.0;
    if (GrAsRat < 0.1) then GrAsRat:=0.1;

    r1:=BC*GrAsRat/(1+Abs(k));
    r2:=BC*GrAsRat-r1;
    if (k <> 0) then BEGIN
      PDcircle('',X_p(xBB),Y_p(yBB),R_p121(r1));
      PDcircle('',X_p(xCC),Y_p(yCC),R_p121(r2));
    END;

    if OK then BEGIN
      if (k > 0) then BEGIN
        ExtTang2Circ(xBB,yBB,r1, xCC,yCC,r2, x1,y1,x2,y2, x1p,y1p,x2p,y2p, OKc);
        if OKc then BEGIN
          PDline('',X_p(x1),Y_p(y1),X_p(x2),Y_p(y2));
          PDline('',X_p(x1p),Y_p(y1p),X_p(x2p),Y_p(y2p));
        END;
      END;
      if (k < 0) AND (GrAsRat < 1) then BEGIN
        CrosTang2Circ(xBB,yBB,r1, xCC,yCC,r2, x1,y1,x2,y2, x1p,y1p,x2p,y2p, OKc);
        if OKc then BEGIN
          PDline('',X_p(x1),Y_p(y1),X_p(x2),Y_p(y2));
          PDline('',X_p(x1p),Y_p(y1p),X_p(x2p),Y_p(y2p));
        END;
      END;
      SetLineStyle(SolidLn, 0, NormWidth);   SyncDXFLineStyleTkns;
      SkLine(X_p(xA),Y_p(yA), X_p(xBB),Y_p(yBB), JtSz,JtSz);
      SkLine(X_p(xBB),Y_p(yBB), X_p(xCC),Y_p(yCC), JtSz,JtSz);
      SkLine(X_p(xCC),Y_p(yCC), X_p(xD),Y_p(yD), JtSz,JtSz);
      PDcircle('',X_p(xBB),Y_p(yBB), JtSz); {..pivot joint at B}
      PDcircle('',X_p(xCC),Y_p(yCC), JtSz); {..pivot joint at C}
    END
    else
      SkLine(X_p(xA),Y_p(yA), X_p(xD),Y_p(yD), JtSz,JtSz);

    SetLineStyle(SolidLn, 0, NormWidth);   SyncDXFLineStyleTkns;
    PDcircle('',X_p(xA),Y_p(yA), JtSz); {..pivot joint at A}
    PDcircle('',X_p(xD),Y_p(yD), JtSz); {..pivot joint at D}

    if OK AND (r1 < AB) then
      LockPoint(Color,xA,yA, xA+(AB-r1)*cPh1,yA+(AB-r1)*sPh1);

    if OK AND (r2 < CD) then
      LockPoint(Color,xD,yD, xD+(CD-r2)*cPh3,yD+(CD-r2)*sPh3);

  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

  xB:=xBB;   yB:=yBB;
  xC:=xCC;   yC:=yCC;

  vxB:=InfD;  vyB:=InfD;   axB:=InfD;   ayB:=InfD;
  vxC:=InfD;  vyC:=InfD;   axC:=InfD;   ayC:=InfD;

  if (vxA = InfD) OR (vyA = InfD) OR (vxB = InfD) OR (vyB = InfD) then Exit;

  if (axA = InfD) OR (ayA = InfD) OR (axB = InfD) OR (ayB = InfD) then Exit;

END; {.. RGGR}

{----------------------------------------------------------------------------}
procedure _GK_(Color:Integer; xA,yA,vxA,vyA,axA,ayA, xB,yB,vxB,vyB,axB,ayB,
  BD,r,PQ,AC:double; var xP,yP,vxP,vyP,axP,ayP, xQ,yQ,vxQ,vyQ,axQ,ayQ:double);
{Returns xP,yP,vxP,vyP,axP,ayP of point P on a gear centered at Q that meshes}
{with rack B-D. A-C is the gear mount, and C is the gear-rack contact point  }

var Th,dTh,ddTh, Ph,dPh,ddPh, cPh,sPh, cTh,sTh, cPhTh,sPhTh,
    a1,b1,c1,a2,b2,c2, s,ds,dds, Delta, xQQ,yQQ,xPP,yPP,
    xC,yC,vxC,vyC,axC,ayC, xD,yD,vxD,vyD,axD,ayD: double;
    OK: Boolean;

BEGIN {_GK_ ..}
  UpdateLimitsWS(xA,yA);
  UpdateLimitsWS(xB,yB);

  a1:=xB-xA;
  b1:=yB-yA;
  c1:=AC;
  Delta:=Sqr(a1)+Sqr(b1)-Sqr(c1);
  if (Delta > 0) then
    Ph:=Atan2(b1,a1) + Sgn(AC)*Atan2(Sqrt(Delta),c1)
  else
    Ph:=0.0;
  cPh:=cos(Ph);
  sPh:=sin(Ph);
  s:=(xA-xB+yA-yB+AC*sPh+AC*cPh)/(cPh-sPh);
  Th:=s/r;
  cTh:=cos(Th);
  sTh:=sin(Th);
  cPhTh:=cPh*cTh-sPh*sTh;
  sPhTh:=sPh*cTh+cPh*sTh;

  xC:=xB - s*sPh;
  yC:=yB + s*cPh;

  xQQ:=xA + (AC-r)*cPh;
  yQQ:=yA + (AC-r)*sPh;

  xPP:=xQQ + PQ*cPhTh;
  yPP:=yQQ + PQ*sPhTh;
  UpdateLimitsWS(xPP,yPP);

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
  if (Color <> Black) AND (MaxX > 0) then BEGIN {draw on screen ..}
    SetColorBGI_DXF(Abs(Color));

    SetLineStyle(DashedLn, 0, NormWidth);   SyncDXFLineStyleTkns;

    xD:=xB - BD*sPh;
    yD:=yB + BD*cPh;

    PDcircle('',X_p(xQQ),Y_p(yQQ),R_p121(r));

    if (Color < 0) then PDline('',X_p(xB),Y_p(yB),X_p(xD),Y_p(yD));
    SetLineStyle(SolidLn, 0, NormWidth);   SyncDXFLineStyleTkns;
    SkLine(X_p(xQQ),Y_p(yQQ),X_p(xPP),Y_p(yPP),JtSz,0);

    if (Abs(AC) > r) then LockPoint(Color,xQQ,yQQ,xQQ+r*cPhTh,yQQ+r*sPhTh);

    PDcircle('',X_p(xQQ),Y_p(yQQ),JtSz);
    if (Color < 0) then BEGIN
      SkLine(X_p(xC),Y_p(yC),X_p(xQQ),Y_p(yQQ),0,JtSz);
      SkLine(X_p(xQQ),Y_p(yQQ),X_p(xA),Y_p(yA),JtSz,0);
    END;
  END; {.. draw on screen}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
  xP :=xPP;    yP :=yPP;
  xQ :=xQQ;    yQ :=yQQ;
  vxP:=InfD;   vyP:=InfD;  axP:=InfD;   ayP:=InfD;
  vxQ:=InfD;   vyQ:=InfD;  axQ:=InfD;   ayQ:=InfD;

  if (vxA = InfD) OR (vyA = InfD) OR (vxB = InfD) OR (vyB = InfD) then Exit;
  a1:= sPh;  b1:=yA-yB;  c1:=vxB-vxA;
  a2:=-cPh;  b2:=xB-xA;  c2:=vyB-vyA;
  LinEq2(a1,b1,c1, a2,b2,c2, ds, dPh, OK);
  if NOT OK then Exit;
  dTh:=ds/r;
  vxC:=vxB - ds*sPh - s*cPh*dPh;
  vyC:=vyB + ds*cPh - s*sPh*dPh;

  vxQ:=vxA - (AC-r)*sPh*dPh;
  vyQ:=vyA + (AC-r)*cPh*dPh;

  vxP:=vxQ - PQ*sPhTh*(dPh+dTh);
  vyP:=vyQ + PQ*cPhTh*(dPh+dTh);

  if (axA = InfD) OR (ayA = InfD) OR (axB = InfD) OR (ayB = InfD) then Exit;
  c1:=axB-axA - ds*cPh*dPh + (vyB-vyA)*dPh;
  c2:=ayB-ayA - ds*sPh*dPh - (vxB-vxA)*dPh;
  LinEq2(a1,b1,c1, a2,b2,c2, dds, ddPh, OK);
  if NOT OK then Exit;
  ddTh:=dds/r;
  axC:=axB - dds*sPh - ds*cPh*dPh - ds*cPh*dPh + s*sPh*dPh*dPh - s*cPh*ddPh;
  ayC:=ayB + dds*cPh - ds*sPh*dPh - ds*sPh*dPh - s*cPh*dPh*dPh - s*sPh*ddPh;

  axQ:=axA - (AC-r)*cPh*dPh*dPh - (AC-r)*sPh*ddPh;
  ayQ:=ayA - (AC-r)*sPh*dPh*dPh + (AC-r)*cPh*ddPh;

  axP:=axQ - PQ*cPhTh*Sqr(dPh+dTh) - PQ*sPhTh*(ddPh+ddTh);
  ayP:=ayQ - PQ*sPhTh*Sqr(dPh+dTh) + PQ*cPhTh*(ddPh+ddTh);
END; {.. _GK_}

{----------------------------------------------------------------------------}



END.
