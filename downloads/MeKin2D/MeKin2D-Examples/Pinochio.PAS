program Pinokio;

{========================================================================
 Animate Pinochio on a tricycle character.  Uses shape file Pinochio.XY
 https://commons.wikimedia.org/wiki/File:Animated_Pinochio.gif 
 https://commons.wikimedia.org/wiki/File:Mechanical_Pinochio.gif
 (c) P.A. Simionescu 2015
========================================================================}

uses Graph,    {Red}
     LibMath,  {_}
     LibInOut, {IsKeyPressed}
     LibDXF,   {InitDXFfile}
     LibMecIn, {gCrank}
     Assur2,
     LibMec2D; {OpenMecGraph,NewFrame,SetJointSize,OffsetV,CloseMecDXF}

const nPoz =36;  {..number of positions}

var i,ZO:Integer;
    Theta, Ang1, O1A,O2B,AB,BC,DE,CE, PM, MQ, k,
    xO1,yO1, xO2,yO2, xA,yA, xB,yB, xC1,yC1, xC2,yC2,
    xD,yD, xE1,yE1, xE2,yE2, xP,yP, xQ,yQ, xM,yM,
    x_D,y_D, x_P,y_P, x_Q,y_Q: double;

BEGIN
  ZO:=1;
  InitDXFfile('Pinochio.DXF');  {..DXF file for M3D animation}
  xO1:=9.20;  yO1:=-3.91;
  xO2:=0.0;   yO2:=0.0;  {..motor location}
  O1A:=0.8;   {O1A link length}
  O2B:=8.334; {O2B link length}
  AB:=4.55;   {AB link length}
  BC:=1.45;   {BC1=BC2 link lengths}
  DE:=4.60;   {DE1=DE2 link lengths}
  CE:=5.20;   {C1E=C2E link lengths}
  PM:=3.20;   {PM1=PM2 link lengths}
  MQ:=3.10;   {MQ1=MQ2 link lengths}
  x_D:=1.50;   y_D:=4.20;
  x_P:=1.65;   y_P:=8.52;
  x_Q:=7.54;   y_Q:=7.5376;

  k:=-2.6/2.0;
  k:=-1.5;
  OpenMecGraph(-1,10, -8.5,14);
  SetJointSize(2);
  i:=0;
  Ang1:=0; {important for _GG_}
  repeat
    if (i > 110) then BEGIN
      Ang1:=0; {important for _GG_}
      CloseMecDXF;   i:=0;
    END;
    NewFrame(0);
    Theta:=2*Pi/nPoz*i;

    PutGpoint(White,'^', xO1,yO1 ,'');
    gCrank(White, xO1,yO1, Theta,_,_, O1A, xA,yA,_,_,_,_);
    PutPoint(White,'o', xA,yA,'');
    LabelJoint(ZO*White, xO1,yO1,xA,yA,'   A');

    PutGpoint(White,'^', xO2,yO2 ,'');
    RRR(ZO*Blue,xA,yA,_,_,_,_,xO2,yO2,0,0,0,0, AB,O2B, +1, xB,yB,_,_,_,_, _);
    PutPoint(White,'O', xB,yB,'');
    LabelJoint(ZO*White, xO2,yO2,xB,yB,'    B');

    _GG_(Red,Ang1,xO1,yO1,_,_,_,_,xA,yA,_,_,_,_,xB,yB,_,_,_,_,BC,k,1.0,xC1,yC1,_,_,_,_);

    PutPoint(White,'O', xC1,yC1,'');
    LabelJoint(ZO*White, xB,yB,xC1,yC1,' C_1');
    Offset(Red,'I',xB,yB,_,_,_,_ ,xC1,yC1,_,_,_,_, -BC,0, xC2,yC2,_,_,_,_);
    PutPoint(White,'O', xC2,yC2,'');
    LabelJoint(ZO*White, xB,yB,xC2,yC2,' C_2');

    Shape('Pinochio.XY', Cyan, xO2,yO2, xB,yB);

    Offset(0,' ',xO2,yO2,_,_,_,_ ,xB,yB,_,_,_,_,x_D,y_D, xD,yD,_,_,_,_);
    Offset(0,' ',xO2,yO2,_,_,_,_ ,xB,yB,_,_,_,_,x_P,y_P, xP,yP,_,_,_,_);
    Offset(0,' ',xO2,yO2,_,_,_,_ ,xB,yB,_,_,_,_,x_Q,y_Q, xQ,yQ,_,_,_,_);

    PutPoint(White,'O', xD,yD ,'');
    PutPoint(ZO*White,'O', xD,yD ,'D ');
    RRR(0,xD,yD,_,_,_,_,xC1,yC1,_,_,_,_, DE,CE, -1, xE1,yE1,_,_,_,_, _);
    TaperLink(Brown, xD ,yD , xE1,yE1, 0.70,0.30);
    TaperLink(Brown, xE1,yE1, xC1,yC1, 0.30,0.25);
    PutPoint(White,'O', xE1,yE1 ,'');
    LabelJoint(ZO*White, xO2,yO2,xE1,yE1,'     E_1');

    RRR(0,xD,yD,_,_,_,_,xC2,yC2,_,_,_,_, DE,CE, -1, xE2,yE2,_,_,_,_, _);
    TaperLink(Brown, xD ,yD , xE2,yE2, 0.70,0.30);
    TaperLink(Brown, xE2,yE2, xC2,yC2, 0.30,0.25);
    PutPoint(White,'O', xE2,yE2 ,'');
    LabelJoint(ZO*White, xO2,yO2,xE2,yE2,'     E_2');

    PutPoint(White,'O', xP,yP ,'');
    PutPoint(White,'O', xQ,yQ,'');
    RRR(0,xP,yP,_,_,_,_,xQ,yQ,_,_,_,_, PM,MQ, +1, xM,yM,_,_,_,_, _);
    TaperLink(Brown, xP,yP, xM,yM, 0.45,0.25);
    TaperLink(Brown, xM,yM, xQ,yQ, 0.25,0.15);
    PutPoint(White,'O', xM,yM ,'');
    LabelJoint(ZO*White, (xO1+xO2)/2,(yO1+yO2)/2,xM,yM,'     M');
    PutPoint(ZO*White,' ',xP,yP,'P ');
    PutPoint(ZO*White,' ',xQ,yQ,'  Q');

    Inc(i);
  until IsKeyPressed(27) OR NOT MecOut;

  CloseMecGraph(FALSE);

END.
