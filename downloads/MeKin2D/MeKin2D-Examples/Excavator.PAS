program P9_36B;

{=========================================================================
 Kinematic simulation of an excavator arm with shapes read from file
 Uses shape files: EXstick.XY, EXbody.XY and EXboom.XY  -- See also:  
 https://commons.wikimedia.org/wiki/File:Excavator_mechanism.gif
 (c) P.A. Simionescu 2018
=========================================================================}

uses Graph,    {Brown,Red,White,Magenta}
     LibMath,  {_}
     LibInOut, {IsKeyPressed}
     LibDXF,   {InitDXFfile,ResetDXFelev,DecDXFelev,SetDXFlayer}
     LibMecIn, {RTRR}
     Assur2,   {RRR}
     LibMec2D; {OpenMecGraph,NewFrame,PutGPoint,gShape,Shape,Offset}
               {SetJointSize,Locus,PutGPoint,CloseMecDXF,CloseMecDXF}

const nPoz = 45;   {..number of positions}

var i,j:Word;   L_R1,L_R2,L_R3,L_R4:shortint;  {..orientation}
    t, s1,s1min,s1max, s2,s2min,s2max, s3,s3min,s3max,
    xA1,yA1, xB1,yB1,  A1Q1,P1C1,B1C1,  xC1,yC1,
    xA2,yA2, xB2,yB2,  A2Q2,P2C2,B2C2,  xC2,yC2,
    xA3,yA3, xB3,yB3,  A3Q3,P3C3,B3C3,  xC3,yC3,
    xD,yD, C3E,DE, xE,yE,  x_A2,y_A2, x_B2,y_B2, x_A3,y_A3,
    x_B3,y_B3, x_D,y_D, x_F,y_F, xF,yF: double;

BEGIN
  InitDXFfile('Excavator.DXF');

  s1min:=0.65;  s1max:=0.90;  {..piston #1 motion range}
  s2min:=0.60;  s2max:=0.90;  {..piston #2 motion range}
  s3min:=0.45;  s3max:=0.65;  {..piston #3 motion range}

  L_R1:=+1;  L_R2:=-1;  {..orientation of loops A1-B1-C1 & A2-B2-C2}
  L_R3:=-1;  L_R4:=-1;  {..orientation of loops A3-B3-C3 & C3-E-D  }

  xA1 := 0.5000;  yA1 := 0.4239;  {..coord. of ground joint A1   }
  xB1 := 0.3940;  yB1 := 0.5869;  {..coord. of ground joint B1   }
  x_A2:= 0.9265;  y_A2:= 0.1753;  {..relative coord. of joint A2 }
  x_B2:= 1.3477;  y_B2:=-0.4554;  {..relative coord. of joint B2 }
  x_A3:=-0.0392;  y_A3:=-0.2010;  {..relative coord. of joint A3 }
  x_B3:=-0.5951;  y_B3:=-0.3253;  {..relative coord. of joint B3 }
  x_D :=-0.7013;  y_D :=-0.3751;  {..relative coord. of joint D  }
  x_F :=-0.0974;  y_F :=-0.3859;  {..relative coord. of point F  }
  B1C1:=0.7306;   B2C2:= 0.2062;  B3C3:=0.1635;
  C3E := 0.1584;  DE  := 0.1177;

  P1C1:=0.8*s1min;  A1Q1:=1.2*(s1max-P1C1);
  P2C2:=0.8*s2min;  A2Q2:=1.2*(s2max-P2C2);
  P3C3:=0.8*s3min;  A3Q3:=1.2*(s3max-P3C3);

  OpenMecGraph(-0.53,2.77,-1.1,2.2);
  SetJointSize(-2);
  i:=0;
  repeat
    if (i > nPoz) then BEGIN
      CloseMecDXF;  i:=0;
    END;
    NewFrame(50);
    t:=i/nPoz;   {..t = time}
    s1:=0.5*(s1min+s1max)+0.5*(s1max-s1min)*cos(2*Pi*t-Pi/8);
    s2:=0.5*(s2min+s2max)+0.5*(s2max-s2min)*cos(2*Pi*t+Pi/4);
    s3:=0.5*(s3min+s3max)+0.5*(s3max-s3min)*cos(2*Pi*t-Pi/8);

    gShape('EXbody.XY',Brown,0,0);

    RTRR(-Magenta,xA1,yA1,0,0,0,0,xB1,yB1,0,0,0,0,0
    ,A1Q1,P1C1,B1C1,s1,_,_,L_R1,xC1,yC1,_,_,_,_,_);

    Shape('EXboom.XY',Brown,xB1,yB1,xC1,yC1);

    Offset(0,' ',xB1,yB1,_,_,_,_,xC1,yC1,_,_,_,_
    ,x_A2,y_A2,xA2,yA2,_,_,_,_);

    Offset(0,' ',xB1,yB1,_,_,_,_,xC1,yC1,_,_,_,_
    ,x_B2,y_B2,xB2,yB2,_,_,_,_);

    RTRR(-Magenta,xA2,yA2,_,_,_,_,xB2,yB2,_,_,_,_
    ,0,A2Q2,P2C2,B2C2,s2,_,_,L_R2,xC2,yC2,_,_,_,_,_);

    Shape('EXstick.XY',Brown,xB2,yB2,xC2,yC2);

    Offset(0,' ',xB2,yB2,_,_,_,_,xC2,yC2,_,_,_,_
    ,x_A3,y_A3,xA3,yA3,_,_,_,_);

    Offset(0,' ',xB2,yB2,_,_,_,_,xC2,yC2,_,_,_,_
    ,x_B3,y_B3,xB3,yB3,_,_,_,_);

    Offset(0,' ',xB2,yB2,_,_,_,_,xC2,yC2,_,_,_,_
    ,x_D ,y_D, xD,yD,_,_,_,_);

    RTRR(Magenta,xA3,yA3,_,_,_,_,xB3,yB3,_,_,_,_
    ,0,A3Q3,P3C3,B3C3,s3,_,_,L_R3,xC3,yC3,_,_,_,_,_);


    RRRc(Red,xC3,yC3,_,_,_,_,xD,yD,_,_,_,_,C3E,DE,L_R4,xE,yE,_,_,_,_,_);

    Offset(0,' ',xD,yD,_,_,_,_,xE,yE,_,_,_,_,x_F,y_F,xF,yF,_,_,_,_);

    Locus(LightBlue,xF,yF,'F');

    PutGPoint(White,' ',xA1,yA1,'A_1 ');
    PutGPoint(White,' ',xB1,yB1,'B_1 ');
    PutPoint (White,' ',xC1,yC1,' C_1');
    PutPoint (White,' ',xA2,yA2,'A_2 ');
    PutPoint (White,' ',xB2,yB2,' B_2');
    PutPoint (White,' ',xC2,yC2,' C_2');
    PutPoint (White,' ',xA3,yA3,' A_3');
    PutPoint (White,' ',xB3,yB3,'B_3 ');
    PutPoint (White,' ',xC3,yC3,' C_3');
    PutPoint (White,' ',xD ,yD,'D ');
    PutPoint (White,' ',xE ,yE,' E');
    LabelJoint(White,xE,yE,xF,yF,' F');

    if (i < nPoz) AND MecOut then BEGIN
      DecDXFelev;  DecDXFelev;  DecDXFelev;
      for j:=i+1 to nPoz do BEGIN
        SetDXFlayer(MySt(j,3));
        Shape('ExBucket.XY',LightGray,xD,yD,xE,yE);
        SetDXFlayer(MySt(LastNrLayer,3));
      END;
      ResetDXFelev;
    END;
    Shape('EXbucket.XY',DarkGray,xD,yD,xE,yE);


    Inc(i);
  until (NOT MecOut) AND IsKeyPressed(27);
  CloseMecGraph(FALSE);

  WriteLn(XminWS:6:3,' < x < ',XmaxWS:6:3);  {workspace limits..}
  Write(YminWS:6:3,' < y < ',YmaxWS:6:3,' <CR>..');  ReadLn;
END.
