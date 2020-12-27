program Elliptic_Trammel;

{=========================================================================
 Simulates an Elliptic Trammel driven with a crank from its middle point
 https://commons.wikimedia.org/wiki/File:Ellipsograph01.gif
 (c) P.A. Simionescu 2018
=========================================================================}

uses Graph,LibMath,LibInOut,LibDXF,LibMecIn,Assur2,LibMec2D;

var nPoz,i:Integer;
    Phi,
    xO,yO, xA,yA, xB,yB, xC,yC,
    xP,yP, xQ,yQ, OC, CP,CQ, Dx,Dy:double;
    PlsMnsA,PlsMnsB:ShortInt;

BEGIN
  InitDXFfile('ElipTram.DXF');
  nPoz:=72;

  OC:=8;
  CP:=12;
  CQ:=16;
  xO:=0;  yO:=0;
  Dx:=0.5*CQ+1.3*OC;
  Dy:=0.5*CP+1.3*OC;

  OpenMecGraph(-1.1*(CQ+OC),1.1*(CQ+OC),-1.1*(CP+OC),1.1*(CP+OC));
  SetJointSize(5);
  OpaqueJoints:=FALSE;
  i:=0;
  repeat
    if (i > nPoz) then BEGIN
      i:=0;  CloseMecDXF;
    END;
    NewFrame(50);
    Phi:=2*Pi*i/nPoz;

    PlsMnsA:=-1;
    if (Phi > Pi/2) AND (Phi < 3*Pi/2) then PlsMnsA:=+1;

    PlsMnsB:=+1;
    if (Phi > Pi) then PlsMnsB:=-1;

    gCrank(Blue,xO,yO,Phi,_,_,OC, xC,yC,_,_,_,_);
    PutGPoint(White,' ',xO,yO,'O  ');

    RRT_(Red,xC,yC,_,_,_,_,xO+Dx,yO,0,0,0,0,xO-Dx,yO,0,0,0,0
    ,OC,0,PlsMnsA,xA,yA,_,_,_,_, xA,yA,_,_,_,_, _);

    RRT_(Red,xC,yC,_,_,_,_,xO,yO-Dy,0,0,0,0,xO,yO+Dy,0,0,0,0
    ,OC,0,PlsMnsB,xB,yB,_,_,_,_, xB,yB,_,_,_,_, _);

    Offset(0,' ',xC,yC,_,_,_,_, xA,yA,_,_,_,_,-CP,0, xP,yP,_,_,_,_);

    Offset(0,' ',xP,yP,_,_,_,_, xC,yC,_,_,_,_,CP+CQ,0, xQ,yQ,_,_,_,_);

    Link(White, xP,yP, xQ,yQ, OC/5, OC/10, OC/10);

    Locus(Green, xP,yP,'P');
    Locus(Cyan, xQ,yQ,'Q');

    PutPoint(Blue,'O',xC,yC,'');
    PutPoint(White,'o',xP,yP,'');
    PutPoint(White,'o',xQ,yQ,'');

    LabelJoint(White,xO,yO,xC,yC,'   C');
    LabelJoint(White,xC,yC,xA,yA,'    A');
    LabelJoint(White,xC,yC,xB,yB,'    B');
    LabelJoint(White,xC,yC,xP,yP,' P');
    LabelJoint(White,xC,yC,xQ,yQ,' Q');

    Inc(i);
  until IsKeyPressed(27);

  CloseMecGraph(FALSE);

END.
