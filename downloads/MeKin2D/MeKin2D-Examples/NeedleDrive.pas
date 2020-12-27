program Needle_Drive;

{=========================================================================
 Simulates the mechanism of a sewing machine
 https://commons.wikimedia.org/wiki/File:Needle_Drive.gif
 (c) P.A. Simionescu 2018
=========================================================================}

uses Graph,LibMath,LibInOut,LibDXF,LibMecIn,Assur2,LibMec2D;

var nPoz,i:Integer;  
    Phi,xO,yO,xA,yA,OA,xB,yB,AB,xP,yP,xQ,yQ,PQ, 
    x_C,y_C,xC,yC,xD,yD,CD,xE,yE,DE,x_F,y_F,xF,yF:double;

BEGIN
  InitDXFfile('NeeDrive.DXF');
  OA:=15; AB:=43; CD:=23; DE:=25; xO:=0; yO:=0; xP:=3; yP:=-63; 
  xQ:=3; yQ:=-23; x_C:=10; y_C:=12; xE:=-15; yE:=23; x_F:=-8; y_F:=25;
  nPoz:=72;
  PQ:=Abs(yP-yQ);
  OpenMecGraph(-15,15,-99,47);
  i:=0;
  repeat
    if (i > nPoz) then BEGIN  i:=0; CloseMecDXF;  END;
    NewFrame(5);
    Phi:=2*Pi*i/nPoz;
    gCrank(Green,xO,yO,Phi,_,_,OA, xA,yA,_,_,_,_);
    RR_T(Red,xA,yA,_,_,_,_,xP,yP,0,0,0,0,0.5*Pi,0,0,AB,0,PQ,Left, xB,yB,_,_,_,_,xB,yB,_,_,_,_,xQ,yQ,_,_,_,_,_);
    Offset(Blue,'V',xO,yO,_,_,_,_,xA,yA,_,_,_,_,x_C,y_C,xC,yC,_,_,_,_);
    RRR(Magenta,xC,yC,_,_,_,_,xE,yE,0,0,0,0,CD,DE, Right,xD,yD,_,_,_,_,_);
    Offset(Brown,'/',xD,yD,_,_,_,_,xC,yC,_,_,_,_,x_F,y_F,xF,yF,_,_,_,_);
    Locus(Cyan, xF,yF,'F');

    LabelJoint(White,xC,yC,xD,yD,'    D');
    PutGPoint(White,' ',xO,yO,'O  ');
    PutPoint (White,' ',xA,yA,'  A');
    PutPoint (White,' ',xB,yB,'  B');
    PutPoint (White,' ',xC,yC,'C  ');
    PutGPoint(White,' ',xE,yE,'E  ');
    PutPoint (White,' ',xF,yF,' F');
    PutGPoint(White,' ',xP,yP,'P  ');
    PutPoint (White,' ', xQ,yQ ,'Q ');
    Inc(i);
  until IsKeyPressed(27);
  CloseMecGraph(FALSE);
END.