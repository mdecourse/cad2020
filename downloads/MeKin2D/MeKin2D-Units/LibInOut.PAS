Unit LibInOut;
{ $R+ }
{ $S- }
{=============================================================================
  Unit for I/O operations in text mode
  (c) P.A. Simionescu 2018
=============================================================================}

INTERFACE

uses  DOS,LibMath;

type D_file = file of double;
     R_file = file of real;
     St02   = string[02];
     St06   = string[06];
     St12   = string[12];
     St20   = string[20];
     St30   = string[30];
     St50   = string[50];
     v20St30 = array[1..20] of St30;

var  SpecialKey:Boolean; {distincts between for example <Back> and <G>}

procedure HaltCRT;
procedure BIP(Freq,Length:Word);
procedure WaitToGo(var CCh:Char);
function  IsKeyPressed(OrdKey:Byte):Boolean;
function  AKeyPressed(var CCh:Char):Boolean;

function  abcABC(Nr:Integer):Char;

function  Nr0to9(CCh:Char):Boolean;
function  Nr_0to9(CCh:Char):Boolean;
function  Dot0to9(CCh:Char):Boolean;
function  Dot_0to9(CCh:Char):Boolean;
function  Dot_0to9PlusEe(CCh:Char):Boolean;
function  EeProof(s:string):string;

procedure Blanks2Offs(var S:string; var Ofs:ShortInt);
function  UpCaseStr(s:string):string;
function  TrimString(s:string; L:shortint):string;
function  TrimBlanks(s:string):string;
function  AddBlanks(s:string; L:Shortint):string;
function  ProcBed(s:string; L:Shortint):string;
function  Trim0s(s:string):string;
function  Trim0sPI(s:string):string;
function  Add0s(s:string; L:Shortint):string;

function  MyVal(s:string):double;
function  PIform2Val(s:string):double;
function  RoundNice(Dmin,D,Dmax:double; W:Shortint):double;
function  MyRound(DD,FrDD:double):double;

function  MyStr(DD:double; L:Shortint):string;
function  MySt(DD:double; L:Shortint):string;
function  MySt2(DD:double; LL,L0:Shortint):string;
function  Val2PIform(DD:double; L:Shortint):string;

procedure Extract_Subs(s:string; colS:Byte; var SubS:string);
function  Extract1stNo(var s:string):double;
procedure Extract_V(s:string; colV:Byte; var V:double);
function  ReadLn1(var FT:text; Echo:Boolean):double;
procedure ReadLnN(var FT:text; var No:vDN; Echo:Boolean);

function  MyGetDate:string;
function  MyGetTime:string;
procedure StartWatch;
function  StopWatch:string;
function  GetLapsedTime
  (NrOfDays, hour0,min0,sec0,hund0, hour,min,sec,hund:Integer):string;

procedure InitCrt(FrameType:Byte);
procedure DialogWindow;
procedure FrameWindow(FrameType:Byte);
procedure HeaderT(Msg:string);
procedure FooterT(Color:Byte; Msg:string);
procedure CenterMsgT(Msg1,Msg2:string);

procedure ReadValue(Msg:string; Lgt:Byte;  Vmin,Vmax:Double;  var Val:Double);
function  ImplicitFileName(FileName:PathStr):PathStr;
function  MyGetDir(FileName:PathStr):DirStr;
function  GetName(FileName:PathStr):NameStr;
function  GetExt(FileName:PathStr):ExtStr;
procedure RenameFile(OldFileName,NewFileName:PathStr);

procedure BackUpFile(FileName:PathStr);
procedure UnDoBackUp(FileName:PathStr);

procedure EraseAll(FileName:PathStr);

procedure OpenReadFile(var FName:PathStr;  FNameS:PathStr);
procedure OpenWriteFile(var FName:PathStr;  FNameS:PathStr);

procedure ReadCR(var inSt:string; W:Shortint; Msg:St50);
procedure ReadNR(var inSt:string; W:Shortint; Msg:St50);
procedure ChosEdit(var vStr:v20St30; N,W:Shortint; var Choice:Byte; Msg:St50);
procedure Chose(vStr:v20St30; N,W:Shortint; var Choice:Byte);

procedure ModifyWithinLimits(var u:integer; du,umin,umax:integer);

procedure ReverseTextFile(FName:PathStr; HeadSize,RecSize:Byte);

procedure ConcatFiles(FName1:PathStr; FName2:PathStr);

procedure ViewASCIIfile(FName:PathStr; ViewMode:Byte;  var MaxNRcol:Byte;
          var RowStart,RowFin:LongInt; var OK:Boolean);

procedure wM3D(var F:text; s1:string; a,b,c,d,a1,b1,c1,d1,a2,b2,c2,d2:double; s2:St20);

{---------------------------------------------------------------------------}
IMPLEMENTATION

uses CRT;

type DateAndTime = record
       hour0,min0,sec0,hund0: Word;
       year0,month0,day0,dow0: Word;
     END;

var  FT: text;
     aFile: file;
     FD: D_file;
     Dir :  DirStr;
     Nme :  NameStr;
     Ext :  ExtStr;
     DirInfo: SearchRec;

     Int1BSave: Pointer;
     Shuttle,   {TRUE for "-selection & edit" in ReadCR}
     MyCrt: Boolean;
     DateTime0:DateAndTime;  {date & time when StartWatch was called}
     s0,sE: string;  {variables initialized in MyStr also visible in MySt}
     Ch: Char;  {transmitted beween ListDirsAndFiles and ReadCR }

{============================================================================}
procedure HaltCRT;
BEGIN
  Window(1,1,80,25);  ClrScr;  Halt;
END;  {..HaltCRT}

{----------------------------------------------------------------------------}
procedure BIP(Freq,Length:Word);
{Activate the internal speaker at frequency Freq for duration Length         }
var k:Byte;

BEGIN
  if (Freq = 0) AND (Length = 0) then BEGIN
    for k:=1 to 7 do BEGIN
      Sound(1800);  Delay(10);
    END;
  END
  else  BEGIN
    Sound(Freq);  Delay(Length);
  END;
  NoSound;
END;  {.. BIP}

{----------------------------------------------------------------------------}
procedure WaitToGo(var CCh:Char);
{Wait for the user to press a key                                            }
BEGIN
  repeat until KeyPressed;
    CCh:=ReadKey;
  if (CCh = #0) then BEGIN
    CCh:=ReadKey;  SpecialKey:=TRUE;
  END
  else SpecialKey:=FALSE;
END;  {..WaitToGo}

{----------------------------------------------------------------------------}
function IsKeyPressed(OrdKey:Byte):Boolean;
{Returns TRUE if the user presses OrdKey else returns FALSE                  }
BEGIN
  IsKeyPressed:=FALSE;
  if KeyPressed then BEGIN {a key was pressed}
    Ch:=ReadKey;
    if (Ord(Ch) = OrdKey) then IsKeyPressed:=TRUE;
  END;
END;  {.. IsKeyPressed}

{----------------------------------------------------------------------------}
function AKeyPressed(var CCh:Char):Boolean;
{Returns TRUE & CCh if the user presses a key, else returns FALSE & CCh:=#0  }

BEGIN
  if KeyPressed then BEGIN {..a key was pressed}
    AKeyPressed:=TRUE;
    CCh:=ReadKey;
  END
  else BEGIN
    AKeyPressed:=FALSE;
    CCh:=#0;
  END;
END;  {.. AKeyPressed}

{----------------------------------------------------------------------------}
function abcABC(Nr:Integer):Char;
{Returns the Nr-th character from the list  a,b,c,d..z,A,B,C,D..Z,a,b,c...   }
BEGIN
  Nr:=Nr MOD 52;
  if (Nr > 26) then Nr:=Nr-58;
  abcABC:=Chr(96+Nr);
END;

{----------------------------------------------------------------------------}
function Nr0to9(CCh:Char):Boolean;
{Return TRUE case CCh of:  0,1,2,3,4,5,6,7,8,9                               }
BEGIN
  if (ORD(CCh) > 47) AND (ORD(CCh) < 58) then Nr0to9:=TRUE else Nr0to9:=FALSE;
END;  {.. Nr0to9}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function Nr_0to9(CCh:Char):Boolean;
{Return TRUE case CCh of:  -,0,1,2,3,4,5,6,7,8,9                             }
BEGIN
  if (ORD(CCh) = 45) OR Nr0to9(CCh) then Nr_0to9:=TRUE else Nr_0to9:=FALSE;
END;  {.. Nr0to9_}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function Dot0to9(CCh:Char):Boolean;
{Return TRUE case CCh of:  .,0,1,2,3,4,5,6,7,8,9                             }
BEGIN
  if (ORD(CCh) = 46) OR Nr0to9(CCh) then Dot0to9:=TRUE else Dot0to9:=FALSE;
END;  {..Dot0to9}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function Dot_0to9(CCh:Char):Boolean;
{Return TRUE case CCh of:  .,-,0,1,2,3,4,5,6,7,8,9                           }
BEGIN
  if (ORD(CCh)=45) OR Dot0to9(CCh) then Dot_0to9:=TRUE else Dot_0to9:=FALSE;
END;  {..Dot_0to9}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function Dot_0to9PlusEe(CCh:Char):Boolean;
{Return TRUE case CCh of: .,-,0,1,2,3,4,5,6,7,8,9,+,E,e                      }
BEGIN
  if (ORD(CCh)=43) OR (ORD(Upcase(CCh))=69) OR Dot_0to9(CCh) then
   Dot_0to9PlusEe:=TRUE
  else
   Dot_0to9PlusEe:=FALSE;
END;  {..Dot_0to9PlusEe}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
function EeProof(s:string):string;
{Change all that is not '.'  '-'  decimal or scientific number into spaces   }
var i:Byte;

BEGIN {EeProof..}
  for i:=1 to Length(s) do BEGIN
    if (NOT Dot_0to9PlusEe(s[i])) then s[i]:=' ';
    if (s[i]='e') then s[i]:='E';
    if (s[i]='+') then s[i]:='0'; {+1.5 goes to 01.5,  1.5E+5 goes to 1.5E05}
  END;
  for i:=1 to Length(s) do BEGIN
    if (s[i]='E') AND (NOT Dot0to9(s[i-1])) then s[i]:=' ';
    if (s[i]='E') AND (NOT Nr_0to9(s[i+1])) then s[i]:=' ';
  END;
  while (s[Length(s)] = 'E') do s[Length(s)]:=' ';
  EeProof:=s;
END;  {..EeProof}

{---------------------------------------------------------------------------}
procedure Blanks2Offs(var S:string; var Ofs:ShortInt);
BEGIN
  Ofs:=0;
  while (S[1] = ' ') AND (S <> '') do BEGIN
    Inc(Ofs);  Delete(S,1,1);
  END;
  while (S[Length(S)] = ' ') AND (S <> '') do BEGIN
    Dec(Ofs);  Delete(S,Length(S),1);
  END;
END; {..Blanks2Offs}

{----------------------------------------------------------------------------}
function UpCaseStr(s:string):string;
{Converts all the characters in s to their uppercase                         }
var i:Byte;
BEGIN
  for i:=1 to Length(s) do s[i]:=UpCase(s[i]);
  UpCaseStr:=s;
END;  {..UpCaseStr}

{----------------------------------------------------------------------------}
function TrimString(s:string; L:shortint):string;
{if L > 0 truncate s to the left else truncate right until Length(s) = Abs(L)}
BEGIN
  if (L < 0) then
    while (Length(s) > Abs(L)) do Delete(s,1,1) {erase to the left}
  else
    while (Length(s) > L) do Delete(s,Length(s),1); {erase to the right}
  TrimString:=s;
END;  {..TrimString}

{----------------------------------------------------------------------------}
function TrimBlanks(s:string):string;
{Erase all blanks to the left and to the right                               }
BEGIN
  while (s[Length(s)] = ' ') AND (Length(s) > 1) do Delete(s,Length(s),1);
  while (s[1] = ' ') AND (Length(s) > 1) do Delete(s,1,1);
  if (s = ' ')  then s:='';
  TrimBlanks:=s;
END;  {..TrimBlanks}

{----------------------------------------------------------------------------}
function AddBlanks(s:string; L:Shortint):string;
{Add blanks left of s until Length(s) = L. e.g. AddBlanks('1.5',5) -> '  1.5'}
BEGIN
  while (Length(s) < L) do Insert(' ',s,1);
  AddBlanks:=s;
END;  {..AddBlanks}

{----------------------------------------------------------------------------}
function ProcBed(s:string; L:Shortint):string;
{Make s exactly L character long e.g. ProcBed('1.5',6) returns '  1.5 '}
BEGIN
  while (Length(s) < L) do BEGIN
    Insert(' ',s,1);
    Insert(' ',s,Length(s));
  END;
  while (Length(s) > L) do Delete(s,Length(s),1);
  ProcBed:=s;
END;  {..ProcBed}

{----------------------------------------------------------------------------}
function Add0s(s:string; L:Shortint):string;
{Add zeros in front of s until Length(s) becomes L see examples below:       }
{Add0s('1.5',5)     returns '1.500'     Add0s('-1.5',5) returns '-1.50'       }
{Add0s('1.5E+22',8) returns '1.50E+22'  Add0s('-1.5',5) returns '-01.5'  }

BEGIN
  if (Pos('ã',s) > 0) then BEGIN  {do not touch forms of Pi..}
    Add0s:=s;  Exit;
  END;

  s:=UpCaseStr(s);
  s:=MySt(MyVal(s),L);

  if (Pos('.',s) = 0) AND (Length(s)+2 <= L) then BEGIN
    if (Pos('E',s) = 0) then
      Insert('.',s,Length(s)+1)  {..add decimal point at the end}
    else
      Insert('.',s,Pos('E',s));  {..add decimal point in front of E}
  END;

  if (Pos('.',s) > 0) then BEGIN
    while (Length(s) < L) do
     if Pos('E',s) = 0 then
       Insert('0',s,Length(s)+1)
     else
       Insert('0',s,Pos('E',s));
  END;

  Add0s:=s;
END;  {..Add0s}

{----------------------------------------------------------------------------}
function MyVal(s:string):double;
{IMPORTANT: in Turbo Pascal  Val('.') = 0.0  while  MyVal('.') = InfD.       }
{Converts a string to a number.   It also recognizes the following characters}
{and texts: . - o í x + * þ    | > v V ^ ! '[]' '\/' '/\' 'BLUE' 'GREEN'  }
{'CYAN' 'RED' 'MAGENTA' 'BROWN' 'GRAY' 'BLACK' 'LIGHTBLUE' 'LIGHTGREEN'      }
{'LIGHTCYAN' 'LIGHTMAGENTA' 'LIGHTRED' 'YELLOW' 'WHITE'                      }

var ErCode:Integer;  AuxExt:extended;

BEGIN {MyVal..}
  Val(s,AuxExt, ErCode);
  if (ErCode = 0) AND (s <> '.') then BEGIN
    MyVal:=AuxExt;   Exit;
  END;
  s:=TrimBlanks(UpCaseStr(s));
  MyVal:=InfD;
  if (s[1] = '=') AND (s[2] = '=') then Exit; {line break}
  if (s[1] = '-') AND (s[2] = '-') then Exit; {line break}
  if (s[1] = '!') AND (s[2] = '!') then BEGIN MyVal:=9.99*InfD; Exit; END; {reset all}
  if (s[1] = '~') AND (s[2] = '~') then BEGIN MyVal:=1.99*InfD; Exit; END; {no marker}

  if (s[1] = '#') AND (s[2] = '#') then BEGIN MyVal:=3*InfD; Exit; END; {label line 1,2,3,4..}
  if (s[1] = '#') AND (s[2] = 'a') then BEGIN MyVal:=4*InfD; Exit; END; {label line a,b,c,d..}
  if (s[1] = '#') then BEGIN
    {used to set color according to a value between 0 and 1 that follows '#'}
    delete(s,1,1);
    Val(s,AuxExt, ErCode);
    if (AuxExt >= 0) AND (AuxExt <= 1) then  MyVal:=(5+AuxExt)*InfD;
    Exit;
  END;

  if (s[1] = 'ì') OR (s[1] = 'í') OR (s[1] = '%') then
                       BEGIN MyVal:=1.01*InfD; Exit; END; {set marker to í}
  if (s[1] = 'o') then BEGIN MyVal:=1.02*InfD; Exit; END; {set marker to o}
  if (s[1] = 'ù') AND (s[2] = 'ù') then
                       BEGIN MyVal:=1.03*InfD; Exit; END; {set marker to ù}
  if (s[1] = 'þ') OR (s[1] = '[') then
                       BEGIN MyVal:=1.04*InfD; Exit; END; {set marker to þ}
  if (s[1] = '') OR (s[1] = '<') then
                       BEGIN MyVal:=1.05*InfD; Exit; END; {set marker to }
  if (s[1] = '') OR (s[1] = 'V') then
                       BEGIN MyVal:=1.06*InfD; Exit; END; {set marker to }
  if (s[1] = '') OR (s[1] = '^') then
                       BEGIN MyVal:=1.07*InfD; Exit; END; {set marker to }
  if (s[1] = '*') then BEGIN MyVal:=1.08*InfD; Exit; END; {set marker to *}
  if (s[1] = 'x') then BEGIN MyVal:=1.09*InfD; Exit; END; {set marker to x}
  if (s[1] = '+') then BEGIN MyVal:=1.10*InfD; Exit; END; {set marker to +}
  if (s[1] = '') OR (s[1] = '@') then
                       BEGIN MyVal:=1.11*InfD; Exit; END; {@ is }
  if (s[1] = '') OR (s[1] = '&') then
                       BEGIN MyVal:=1.12*InfD; Exit; END; { & is }
  if (s[1] = '') OR (s[1] = 'Q') OR (s[1] = 'q')then
                       BEGIN MyVal:=1.13*InfD; Exit; END; {q is }
  if (s[1] = '|') then BEGIN MyVal:=1.14*InfD; Exit; END; {arrow marker}
  if (s[1] = '>') then BEGIN MyVal:=1.15*InfD; Exit; END; {arrow marker}

  if (s = 'BLUE')         then BEGIN MyVal:=2.01*InfD; Exit; END; {1}
  if (s = 'GREEN')        then BEGIN MyVal:=2.02*InfD; Exit; END; {2}
  if (s = 'CYAN')         then BEGIN MyVal:=2.03*InfD; Exit; END; {3}
  if (s = 'RED')          then BEGIN MyVal:=2.04*InfD; Exit; END; {4}
  if (s = 'MAGENTA')      then BEGIN MyVal:=2.05*InfD; Exit; END; {5}
  if (s = 'BROWN')        then BEGIN MyVal:=2.06*InfD; Exit; END; {6}
  if (s = 'GRAY') OR (s = 'LIGHTGRAY') then
    BEGIN  MyVal:=2.07*InfD;  Exit;  END;  {7 = LightGray}
  if (s = 'BLACK') OR (s = 'DARKGRAY') then
    BEGIN  MyVal:=2.08*InfD;  Exit;  END;  {8 = DarkGray }
  if (s = 'LIGHTBLUE')    then BEGIN MyVal:=2.09*InfD; Exit; END; { 9}
  if (s = 'LIGHTGREEN')   then BEGIN MyVal:=2.10*InfD; Exit; END; {10}
  if (s = 'LIGHTCYAN')    then BEGIN MyVal:=2.11*InfD; Exit; END; {11}
  if (s = 'LIGHTMAGENTA') then BEGIN MyVal:=2.12*InfD; Exit; END; {12}
  if (s = 'LIGHTRED')     then BEGIN MyVal:=2.13*InfD; Exit; END; {13}
  if (s = 'YELLOW')       then BEGIN MyVal:=2.14*InfD; Exit; END; {14}
  if (s = 'WHITE')        then BEGIN MyVal:=2.15*InfD; Exit; END; {15}

END;  {..MyVal}

{----------------------------------------------------------------------------}
function PIform2Val(s:string):double;
{Convert string s of ##ã/# type to value.                                    }
{Example: '2PI/3' -> 2.094395 or '-PI'-> -3.14159265                         }
var Times,Over:double; s0:string;

BEGIN {PIform2Val..}
  s:=UpCaseStr(s);
  Delete(s,Pos('*',s),1);
  if (Pos('PI', s) = 0) AND (Pos('ã', s) = 0) then BEGIN {not ##ã/# form}
    PIform2Val:=MyVal(s);  Exit;
  END;
  s0:=s;
  while (s[Length(s)] <> 'P') AND (s[Length(s)] <> 'ã') do
   Delete(s,Length(s),1);
  Delete(s,Length(s),1);
  Times:=MyVal(s);
  if (Times >= InfD) then BEGIN
    if (s = '+') OR (s = '') then Times:=+1;
    if (s = '-') then Times:=-1;
  END;
  s:=s0;
  repeat {extract Over}
    Delete(s,1,1);
  until (s[1] = '/') OR (Length(s) = 0);
  Over:=MyVal(EeProof(s));
  if (Over >= InfD) then Over:=1;
  if (Times < InfD) AND (Over < InfD) AND (Over <> 0) then
   PIform2Val:=Times*Pi/Over
  else
   PIform2Val:=InfD;
END;  {..PIform2Val}

{----------------------------------------------------------------------------}
function Trim0s(s:string):string;
{Shorten as much as possible string s representing a number.                 }
{Examples: '001.2300' -> '1.23' or '001.20E+002' -> '1.2E2' etc.             }

var  D:double;  Code:Integer;

BEGIN {Trim0s..}
  s:=UpCaseStr(s);
  Val(s,D,Code);
  if (Code <> 0) then BEGIN
    s[Round(min2(Length(s),Code))]:='?'; Trim0s:=s; Exit;
  END;
  Delete(s,Pos('+',s),1);  {+1.20E+002 => 1.20E+002}
  if (s[1] = '-') then BEGIN {negative numbers}
    repeat {-00.2 => -.2}
      if (s[2] = '0') AND (Length(s) > 2) then Delete(s,2,1);
    until (Length(s) = 2) OR (s[2] <> '0');
    if Pos('.',s) = 2 then insert('0',s,2); {-.2 => -0.2}
  END
  else BEGIN {positive numbers}
    repeat {00.2 => .2}
      if (s[1] = '0') AND (Length(s) > 1) then Delete(s,1,1);
    until (Length(s) = 1) OR (s[1] <> '0');
    if Pos('.',s) = 1 then insert('0',s,1); {.2 => 0.2}
  END;

  if (Pos('E',s) > 0) then BEGIN {scientific number...}
    Str(D,s);  if (s[1] = ' ') then Delete(s,1,1);
    Delete(s,Pos('+',s),1);  { 1.2E+2 => 1.2E2 }
    repeat {1.00E3 => 1.E3}
      if (s[Pos('E',s)-1] = '0') then Delete(s,Pos('E',s)-1,1);
    until (s[Pos('E',s)-1] <> '0');
    if (s[Pos('E',s)-1] = '.') then Delete(s,Pos('E',s)-1,1); {1.E3 => 1E3}

    if (s[Pos('E',s)+1] = '-') then {1E-003 => 1E-3 }
      while (s[Length(s)] <> '-') AND (s[Pos('E',s)+2] = '0') do Delete(s,Pos('E',s)+2,1)
    else {1E003 -> 1E3}
      while (s[Pos('E',s)+1] = '0') AND (Pos('E',s) < Length(s)) do
        Delete(s,Pos('E',s)+1,1);
    {delete E if it is the last character: 1E00 => 1}
    if (Pos('E',s) = Length(s)) then Delete(s,Pos('E',s),1);
    if (s[1] = 'E') then s:='0';  {E-5 => 0}
    if (s[Length(s)] = '-') then Delete(s,Pos('E',s),2);  {1.2E- => 1.2}
  END;
  if (Pos('.',s) > 0) AND (Pos('E',s) = 0) then BEGIN {simple decimal number..}
    repeat {1000.00 -> 1000.}
      if (s[Length(s)] = '0') then Delete(s,Length(s),1);
    until (s[Length(s)] <> '0') OR (Length(s) = 1);
    if (s[Length(s)] = '.') then Delete(s,Length(s),1); {1000. -> 1000}
  END;

  if (s = '') OR (s = '-0') then s:='0';

  Trim0s:=s;
END;  {..Trim0s}

{----------------------------------------------------------------------------}
function Trim0sPI(s:string):string;
BEGIN
  if (Pos('PI', s) = 0) AND (Pos('ã', s) = 0) then {not ##ã/# form..}
   Trim0sPI:=Trim0s(s)
  else
   Trim0sPI:=Val2PIform(PIform2Val(s),2*Length(s)+1);
END;  {..Trim0sP}

{----------------------------------------------------------------------------}
function MyStr(DD:double; L:Shortint):string;
{ConvertS a number DD to a string of length W; W cannot be more than 22.     }

var My_Str:string;

{- - - - - - - - - - - - - - - - - -}
procedure FxLgthNr(DD:double; W:Shortint; var s:string);
var i:Integer;

BEGIN {FxLgthNr..}
  s:=Trim0s(s);
  if (Pos('E',s) > 0) then BEGIN {scientific number}
    {adds '.' if it hasn't one}
    if (Pos('.',s) = 0) then Insert('.',s,Pos('E',s));
    {adds '0' until the length of s equals W}
    while (Length(s) < W) do Insert('0',s,Pos('E',s));
    {erases decimal figures to the right until lenght of s equals W}
    while (Length(s) > W) AND (s[Pos('.',s)+1] <> 'E') do
      Delete(s,Pos('E',s)-1,1);
    {if there are no decimal figures left then delets '.' as well}
    if (Length(s) > W) AND (s[Pos('.',s)+1] = 'E') then
      Delete(s,Pos('.',s),1);
  END
  else BEGIN {decimal number..}
    {adds '.' if it hasn't one}
    if (Pos('.',s) = 0) then s:=Concat(s,'.');
    {adds '0' until the length of s equals W}
    while (Length(s) < W) do s:=Concat(s,'0');
    {erases decimal figures to the right until lenght becomes W}
    while (Length(s) > W) AND (Pos('.',s) < Length(s)) do Delete(s,Length(s),1);
    if (Length(s) = Pos('.',s)) then Delete(s,Pos('.',s),1);
  END;
  Val(s,DD,i);
  if (i <> 0) OR (Length(s) > W) then BEGIN  {insufficent space..}
    s:='';
    for i:=1 to W do s:=s+'*';
  END;
END;  {..FxLgthNr}

{- - - - - - - - - - - - - - - - - -}
BEGIN {MyStr..}
  if (L > 22) then L:=22;
  Str(DD,sE);
  if (sE = ' ') then Delete(sE,1,1);
  FxLgthNr(DD,L,sE);  {..write DD as scientific number}
  Str(DD:L:L,s0);
  FxLgthNr(DD,L,s0);  {..write DD as decimal number   }
  if Abs(DD-MyVal(s0)) <= Abs(DD-MyVal(sE))
  then My_Str:=s0
  else My_Str:=sE;
  if (s0[1] = '*') then MyStr:=s0;
  MyStr:=My_Str;
END;  {..MyStr}

{----------------------------------------------------------------------------}
function MySt(DD:double; L:Shortint):string;
{Convert a number DD to a string while erasing any unnecessary characters.   }
{If there are too many zeros, DD is output as a scientific number.           }
var AuxStr:string;

BEGIN {MySt..}
  AuxStr:=MyStr(DD, L); {calls MyStr to assign the global variables s0 & sE}
  s0:=TrimBlanks(Trim0s(s0));
  sE:=TrimBlanks(Trim0s(sE));
  if (s0[1] = '?') then BEGIN
    MySt:=sE; Exit;
  END;

  if (Abs(DD-MyVal(s0)) > Abs(DD-MyVal(sE))) AND (Abs(1-MyVal(s0)/DD) > 0.01) then
    MySt:=sE
  else
    MySt:=s0;
END;  {..MySt}

{----------------------------------------------------------------------------}
function MySt2(DD:double; LL,L0:Shortint):string;
{Convert DD to a string of width LL and number of decimals L0}

var s:string;

BEGIN
  Str(DD:LL:L0,s);
  if (Length(s) = LL) then MySt2:=TrimBlanks(s) else MySt2:=MyStr(DD,LL);
END;  {..MySt2}

{----------------------------------------------------------------------------}
function Val2PIform(DD:double; L:Shortint):string;
{Write DD as fraction of PI: ##ã/# with ##=(-31830..31830) and #=(2,3,4,6,9,10,12)  }

var  Mul:Integer;  sDD0,sDD:string;

{- - - - - - - - - - - - - - - - - -}
function NiceMul(Mul:Integer):string;
BEGIN
  NiceMul:=MySt(Mul,L);
  if (Mul =  1) then NiceMul:='';
  if (Mul = -1) then NiceMul:='-';
END;  {..NiceMul}
{- - - - - - - - - - - - - - - - - -}

BEGIN {Val2PIform..}
  sDD0:=MySt(DD,L);
  if (Abs(DD) <= 315) then BEGIN  {numbers between -100*Pi and 100*Pi..}
    sDD:=sDD0;
    Mul:=Round(DD/(PI/9));
    if (MySt(Mul*PI/12,L) = sDD0) then
      sDD:=NiceMul(Mul)+'ã'+'/12';
    if (MySt(Mul*PI/10,L) = sDD0) then
      sDD:=NiceMul(Mul)+'ã'+'/10';
    if (MySt(Mul*PI/9,L) = sDD0) then
      sDD:=NiceMul(Mul)+'ã'+'/9';
    Mul:=Round(DD/(PI/8));
    if (MySt(Mul*PI/8,L) = sDD0) then
      sDD:=NiceMul(Mul)+'ã'+'/8';
    Mul:=Round(DD/(PI/6));
    if (MySt(Mul*PI/6,L) = sDD0) then
      sDD:=NiceMul(Mul)+'ã'+'/6';
    Mul:=Round(DD/(PI/4));
    if (MySt(Mul*PI/4,L) = sDD0) then
      sDD:=NiceMul(Mul)+'ã'+'/4';
    Mul:=Round(DD/(PI/3));
    if (MySt(Mul*PI/3,L) = sDD0) then
      sDD:=NiceMul(Mul)+'ã'+'/3';
    Mul:=Round(DD/(PI/2));
    if (MySt(Mul*PI/2,L) = sDD0) then
      sDD:=NiceMul(Mul)+'ã'+'/2';
    Mul:=Round(DD/PI);
    if (MySt(Mul*PI,L) = sDD0) then
      sDD:=NiceMul(Mul)+'ã';
    if (Length(sDD) <= Length(sDD0))
      AND (Abs(DD-PIform2Val(sDD)) <= Abs(DD-MyVal(sDD0))) then sDD0:=sDD;
  END;
  Val2PIform:=sDD0;
END;  {..Val2PIform}

{----------------------------------------------------------------------------}
function RoundNice(Dmin,D,Dmax:double; W:Shortint):double;
{Round D between Dmin and Dmax to a nice value, up to W characters long.     }
{Example:  RoundNice(0.9, 1.1, 1.3) returns  1                               }

var j:Byte; D0,D5:double; S:string;

BEGIN {RoundNice..}
  if (Pos('ã', Val2PIform(D,15)) > 0) then BEGIN {##ã/# form number..}
    RoundNice:=D;  Exit;
  END;
  if (Dmin > Dmax) then BEGIN
    D5:=Dmin;  Dmin:=Dmax;  Dmax:=D5;
  END;
  if (D < Dmin) OR (D > Dmax) then D:=0.5*(Dmin+Dmax);
  j:=1;
  repeat
    repeat
      Inc(j);  S:=MyStr(D,j);
    until (MyVal(S) <> InfD);
    if (Pos('E',S) = 0) then S[Length(S)]:='0' else S[Pos('E',S)-1]:='0';
    D0:=MyVal(S);
  until (Dmin <= D0) AND (D0 <= Dmax) OR (j > W);

  j:=0;
  repeat
    repeat
      Inc(j);  S:=MyStr(D,j);
    until (MyVal(S) <> InfD);
    if (Pos('E',S) = 0) then S[Length(S)]:='5' else S[Pos('E',S)-1]:='5';
    D5:=MyVal(S);
  until (Dmin <= D5) AND (D5 <= Dmax) OR (j > W);

  if Length(MySt(D,W)) > Length(MySt(D0,W)) then D:=D0;
  if Length(MySt(D,W)) > Length(MySt(D5,W)) then RoundNice:=D5 else RoundNice:=D;
END;  {..RoundNice}

{----------------------------------------------------------------------------}
function MyRound(DD,FrDD:double):double;
{Rounds up to FrDD e.g. MyRound(1.6)=1.5}
BEGIN
  MyRound:=RoundLongInt(DD/FrDD)*FrDD;
END;

{----------------------------------------------------------------------------}
function Extract1stNo(var s:string):double;
{Extract the first number encountered in the string s                        }
{Ex: Extract1stNo('L=12.5  W=5.5') returns 12.5 and changes s to '  W=5.5'   }

var s0:string;

BEGIN  {Extract1stNo..}
  s:=EeProof(s);
  while (NOT Dot_0to9PlusEe(s[1])) AND (s <> '') do Delete(s,1,1);
  s0:='';
  while Dot_0to9PlusEe(s[1]) AND (s <> '') do BEGIN
    s0:=s0+s[1];
    Delete(s,1,1);
  END;
  Extract1stNo:=MyVal(s0);
END;  {..Extract1stNo}

{----------------------------------------------------------------------------}
procedure Extract_V(s:string; colV:Byte; var V:double);
{ V returns the value of the colV number in the string s. Examples:         }
{ for colV=2 and s='1.3  1.4  1.5  1.6'  V returns 1.4 i.e. the 2nd value   }
{ for colV=2 and s='1.3   .   1.5  1.6'  V will stay unchanged              }

var coln, {number of the current column}
    Ls,   {length of the string s      }
    LV,   {length of the substring corresponding to colV }
    PV,   {pos of the 1st character of the substring corresponding to colV }
    i     :integer;
    AuxStr:string;

BEGIN {Extract_V..}
  AuxStr:=TrimBlanks(s);
  V:=MyVal(AuxStr);
  if (V > InfD) OR ((V = InfD) AND (AuxStr[1] = '=')) then Exit;

  AuxStr:=EeProof(s);
  s:=AuxStr;
  Ls:=Length(s);
  i:=1;
  LV:=0;
  PV:=0;
  coln:=1;
  repeat
    if (s[i] <> ' ') AND (coln = colV) then Inc(LV);
    if (i > 1) then if (s[i-1] <> ' ') AND (s[i] = ' ') then BEGIN
       if (coln = colV) then BEGIN
         PV:=i-LV;
         i:=Ls;
       END;
       Inc(coln);
     END;
    Inc(i);
  until (i > Ls);
  if (coln = colV) then PV:=Ls-LV+1;
  AuxStr:=Copy(s,PV,LV);
  if (AuxStr = '.') OR (AuxStr = '-') then AuxStr:='';
  if (AuxStr = '') then V:=InfD else V:=MyVal(AuxStr)
END;  {..Extract_V}

{----------------------------------------------------------------------------}
procedure Extract_Subs(s:string; colS:Byte; var SubS:string);
{SubS returns the colVth substring of s, for columns of s separated by blanks}

var coln, {number of the current column}
    Ls,   {length of the string s      }
    i     :integer;

BEGIN  {Extract_Subs ..}
  s:=TrimBlanks(s);
  Ls:=Length(s);
  coln:=0;
  repeat
    SubS:='';
    i:=1;
    repeat
      if (s[i] <> ' ') then BEGIN
        SubS:=SubS+s[i];
        s[i]:=' ';
      END;
      Inc(i);
    until (s[i] = ' ') OR (i > Ls);
    Inc(coln);
    s:=TrimBlanks(s);
  until (coln = colS) OR (i > Ls);
END;  {.. Extract_Subs}

{----------------------------------------------------------------------------}
function ReadLn1(var FT:text; Echo:Boolean):double;
{Reads a line from text file FT and returns the first occuring number.       }
{If the line is blank it reads another line until not blank.                 }
{If Echo=TRUE then the line read is written on the screen.  Example:         }
{ 'W is five;         '   returns InfD                                       }
{ 'W1 = 0.555; q,r:1,2'   returns 0.555                                      }
{ 'W1 is 0.55         '   returns 1 (possible error!!)                       }

var  s,AuxStr:string;
     AuxD:double;

BEGIN {ReadLn1 ..}
  repeat
    ReadLn(FT,AuxStr);
    s:=AuxStr;
    while (s <> '') AND (s[1] <> '=') AND (s[1] <> ':') do Delete(s,1,1);
    if (s[1] = ':') then Delete(s,1,1);  {delete ':'}
    if (s[1] = '=') then Delete(s,1,1);  {delete '+'}
    AuxD:=Extract1stNo(s);
    if Echo OR (AuxD = InfD) then BEGIN
      if (AuxStr <> '') then BEGIN
        if (AuxD < InfD) then BEGIN
          TextColor(Yellow);
          Write(MySt(AuxD,8));
          NormVideo;
        END
        else TextColor(Red);
        GoToXY(10,WhereY);
        WriteLn(AuxStr);
        NormVideo;
      END;
    END;
    ReadLn1:=AuxD;
  until (TrimBlanks(AuxStr) <> '') OR Eof(FT);
END;  {..ReadLn1}

{----------------------------------------------------------------------------}
procedure ReadLnN(var FT:text; var No:vDN; Echo:Boolean);
{Reads a line from an ASCII file FT and stores in No the occuring numbers.   }
{If Echo=TRUE then the line read is written on the screen.  Example:         }
{ 'p1=0; q,r:1,2'  returns:No[1]=0, No[2]=1, No[3]=2, No[4..Nmax]=InfD       }
{ 'p1 is 0.55   '  returns:No[1]=1, No[2]=0.55, No[3..Nmax]=InfD.            }

var  s,AuxStr:string;    j:Byte;

BEGIN {ReadLnN ..}
  for j:=1 to N_max do No[j]:=InfD;
  ReadLn(FT,s);
  AuxStr:=s;
  j:=0;
  repeat
    while (AuxStr[1] <> '=') OR (AuxStr[1] <> ':') do Delete(s,1,1);
    No[j]:=Extract1stNo(AuxStr);
    if (No[j] <> InfD) then Inc(j);
  until (AuxStr = '');
  if (j = 0) then
    WriteLn(s,' ???????')
  else
    if Echo then WriteLn(s);
END; {..ReadLnN}

{----------------------------------------------------------------------------}
function Date2Str(Year,Month,Day,Day1_7:Word):string;
BEGIN
  Date2Str:=Add0s(MySt(Month,2),2)+'/'+Add0s(MySt(Day,2),2)+'/'+MyStr(Year,4);
END;  {.. Date2Str}

function Time2Str(Hour,Min,Sec,Hund:Word):string;
BEGIN
  if (Hour < 12) OR ((Hour = 12) AND (Min = 0)) then
    Time2Str:=Add0s(MyStr(Hour,2),2)+':'+Add0s(MyStr(Min,2),2)+' AM';
  if (Hour = 12) AND (Min > 0) then
    Time2Str:=Add0s(MyStr(Hour,2),2)+':'+Add0s(MyStr(Min,2),2)+' PM';
  if (Hour > 12) then
    Time2Str:=Add0s(MyStr(Hour-12,2),2)+':'+Add0s(MyStr(Min,2),2)+' PM';
END;  {.. Time2Str}

{----------------------------------------------------------------------------}
function MyGetDate:string;
var Year,Month,Day,Dow:Word;
BEGIN
  GetDate(Year,Month,Day,Dow);
  MyGetDate:=Date2Str(Year,Month,Day,Dow);
END;  {.. MyGetDate}

{----------------------------------------------------------------------------}
function MyGetTime:string;
var Hour,Min,Sec,Hund: Word;
BEGIN
  GetTime(Hour,Min,Sec,Hund);
  MyGettime:=Time2Str(Hour,Min,Sec,Hund);
END;  {.. MyGetTime}

{----------------------------------------------------------------------------}
function GetLapsedTime
  (NrOfDays, hour0,min0,sec0,hund0, hour,min,sec,hund:Integer):string;
{Returns as a string the time elapsed between dow0,..,hund0 and dow,..,hund. }

BEGIN {GetLapsedTime ..}
  if (hund < hund0) then BEGIN
    hund:=100+hund;  sec:=sec-1;
  END;
  if (sec < sec0) then BEGIN
    sec:=sec+60;  min:=min-1;
  END;
  if (min < min0) then BEGIN
    min:=min+60;  hour:=hour-1;
  END;
  if (hour < hour0) then BEGIN
    hour:=hour+24;  NrOfDays:=NrOfDays-1;
  END;

  hour:=hour-hour0;
  min :=min-min0;
  sec :=sec-sec0;
  hund:=hund-hund0;
  GetLapsedTime:=MySt(NrOfDays,3)+' day(s) + '
  +MySt(hour,5)+':'+MyStr(min,2)+':'+MyStr(sec,2)+'.'+MyStr(hund,2);
END;  {.. GetLapsedTime}

{----------------------------------------------------------------------------}
function GetNrOfDays(year0,month0,day0, year,month,day:Word):Word;
var Days,Days0:Word;
function DaysSinceJan(month:Word):Word;
BEGIN
  case month of
    1 : DaysSinceJan:=0;
    2 : DaysSinceJan:=31;
    3 : DaysSinceJan:=59;
    4 : DaysSinceJan:=90;
    5 : DaysSinceJan:=120;
    6 : DaysSinceJan:=151;
    7 : DaysSinceJan:=180;
    8 : DaysSinceJan:=212;
    9 : DaysSinceJan:=243;
    10: DaysSinceJan:=273;
    11: DaysSinceJan:=304;
    12: DaysSinceJan:=334;
  END;
END;  {.. DaysSinceJan}

BEGIN
  Days :=DaysSinceJan(month )+day;
  Days0:=DaysSinceJan(month0)+day0;
  if (year0 MOD 4 = 0) AND (month0 > 2) then BEGIN
    Inc(Days0);
    Inc(Days );
  END;

  GetNrOfDays:=365*(year-year0)+Days-Days0

END; {.. GetNrOfDays}

{----------------------------------------------------------------------------}
procedure StartWatch;
BEGIN
  with DateTime0 do BEGIN
    GetDate(year0,month0,day0, dow0);
    GetTime(hour0,min0,sec0,hund0);
    WriteLn(Date2Str(year0,month0,day0,dow0)+' -  '+Time2Str(hour0,min0,sec0,hund0));
  END;
END;  {.. StartWatch}

{----------------------------------------------------------------------------}
function StopWatch:string;
{Display the time ellapsed since calling StartWatch  }
var year,month,day,dow, hour,min,sec,hund, Day_Day0: Word;

BEGIN {StopWatch ..}
  GetTime(hour,min,sec,hund);
  GetDate(year,month,day,dow);
  with DateTime0 do BEGIN
    if (hour0 = 25) then BEGIN
      StopWatch:='Must call StartWatch first!';
      Exit;
    END;
    Day_Day0:=GetNrOfDays(year0,month0,day0, year,month,day);
    StopWatch:=GetLapsedTime(Day_Day0, hour0,min0,sec0,hund0, hour,min,sec,hund);
  END;
END;  {.. StopWatch}

{----------------------------------------------------------------------------}
procedure FrameWindow(FrameType:Byte);
{Draw a frame arround the current window in CRT mode.                        }
{case FrameType of 0:no frame; 1:'ÄÄÄÄ' frame; 2:'ÍÍÍÍ' frame.               }
var  i,Xmin,Xmax,Ymin,Ymax:Byte;  hl,vl,c11,c12,c21,c22:Char;

BEGIN {FrameWindow..}
  Xmin:=Lo(WindMin)+1;
  Ymin:=Hi(WindMin)+1;
  Xmax:=Lo(WindMax)+1;
  Ymax:=Hi(WindMax)+1;
  Window(1,1,80,25);
  case FrameType of
    1:BEGIN
       hl :='Ä';    vl:='³';
       c11:='Ú';   c12:='¿';
       c21:='À';   c22:='Ù';
    END;
    2:BEGIN
       hl :='Í';    vl:='º';
       c11:='É';   c12:='»';
       c21:='È';   c22:='¼';
    END;
  END;
  if FrameType <> 0 then BEGIN
    GoToXY(Xmin,Ymin);  Write(c11);
    GoToXY(Xmin,Ymax);  Write(c21);
    GoToXY(Xmax,Ymin);  Write(c12);
    GoToXY(Xmax,Ymax);  Write(c22);
    if Ymax = 25 then BEGIN
      GoToXY(1,Ymin-2);  InsLine;  WriteLn(' ');
    END;
    for i:=succ(Xmin) to pred(Xmax) do BEGIN
      GoToXY(i,Ymin);   Write(hl);
      GoToXY(i,Ymax);   Write(hl);
    END;
    for i:=succ(Ymin) to pred(Ymax) do BEGIN
      GoToXY(Xmin,i);   Write(vl);
      GoToXY(Xmax,i);   Write(vl);
    END;
  END;
  Window(Xmin+2,Ymin+1,Xmax-2,Ymax-1);
END;  {.. FrameWindow}

{----------------------------------------------------------------------------}
procedure DialogWindow;
{Make the (2,5, 79,21) window current window                                 }
BEGIN
  Window(2,5, 79,21);
END;  {.. DialogWindow}

{----------------------------------------------------------------------------}
procedure InitCrt(FrameType:Byte);
{Initialize CRT dialog interface and sets the frame border:                  }
{case FrameType of 0:no frame; 1:'ÄÄÄÄ' frame; 2:'ÍÍÍÍ' frame.               }

BEGIN {InitCrt ..}
  MyCrt:=TRUE;
  TextColor(LightGray);
  TextBackground(Black);
  ClrScr;
  Window(1,23,80,25);   FrameWindow(FrameType);  ClrScr;
  Window(1, 1,80, 3);   FrameWindow(FrameType);  ClrScr;
  Window(1, 1,80, 3);   FrameWindow(FrameType);  ClrScr;
  Window(1, 4,80,22);   FrameWindow(FrameType);  ClrScr;
  DialogWindow;
END;  {.. InitCrt}

{----------------------------------------------------------------------------}
procedure HeaderT(Msg:string);
{Write message Msg in the header window above the DialogWindow.              }
var  Xp,Yp:Byte;

BEGIN {HeaderT ..}
  Xp:=WhereX;   Yp:=WhereY;
  Window(3,2,78,2); {move to the top window  }
  ClrScr;           {...and clear its content }
  Msg:=TrimString(Msg,75);
  GoToXY((77-Length(Msg)) DIV 2,1);
  Write(Msg);
  DialogWindow;
  GotoXY(Xp,Yp);
END;  {..HeaderT}

{----------------------------------------------------------------------------}
procedure FooterT(Color:Byte; Msg:string);
{Write message Msg in the footer window below the DialogWindow in Color.              }
var Xp,Yp:Byte;

BEGIN {FooterT ..}
  Xp:=WhereX;   Yp:=WhereY;
  Window(3,24,78,24); {move to the bottom window}
  ClrScr;             {...and clear its content }
  Msg:=TrimString(Msg,75);
  if (Color < 0) then
    GoToXY((77-Length(Msg)) DIV 2,1)
  else
    GoToXY(1,1);
  TextColor(Abs(Color));
  Write(Msg);
  NormVideo;
  DialogWindow;
  GotoXY(Xp,Yp);
END;  {.. FooterT}

{----------------------------------------------------------------------------}
procedure CenterMsgT(Msg1,Msg2:string);
{Clear the dialog window and write Msg1 & Msg2 in the middle of the screen}
BEGIN  {CenterMsgT ..}
  TextColor(LightGray);
  TextBackground(Black);
  ClrScr;
  GoToXY((78-Length(Msg1)) DIV 2,7);  Write(Msg1);
  if (Msg2 <> '') then BEGIN
    GoToXY((78-Length(Msg2)) DIV 2,9);  Write(Msg2);
  END;
END;  {.. CenterMsgT}


{----------------------------------------------------------------------------}
procedure ReadValue(Msg:string; Lgt:Byte;  Vmin,Vmax:Double;  var Val:Double);
{Accepts a number Vmin < Vin < Vmax from keyboard          }
var AuxD: double;  AuxStr: string;
BEGIN  {ReadValue ..}
  if (Vmin > Vmax) then BEGIN
    AuxD:=Vmin; Vmin:=Vmax; Vmax:=AuxD;
  END;
  ClrScr;
  repeat
    GoToXY(1,1); ClrEol;
    Write(Msg);
    AuxStr:=Val2PIform(Val,Lgt);
    ReadNR(AuxStr,Lgt,'  between '+MySt(Vmin,7)+' and '+MySt(Vmax,7));
    AuxD:=PIform2Val(AuxStr);
  until (AuxD >= Vmin) AND (AuxD <= Vmax);
  Val:=AuxD;
{  with ViewPort do SetViewPort(x1,y1,x2,y2, Clip);}
END; {.. ReadValue}

{============================================================================}
procedure ReadCR(var inSt:string; W:Shortint; Msg:St50);
{Accept a string inSt in a W character-long window.                          }
{Msg (it can be blank) will be displayed to the right of the input window.   }
{NOTE:  wLgt = 72 is reserved for file handling with OpenRead/WriteFile      }
{ if (W < 0) then insert mode only and edit without scrolling                }
{ if the answer is <ESC> and ³wLgt³ = 76 then inSt:='' (for ListDirsAndFiles)}
{ if the answer is <ESC> and ³wLgt³ < 76 then inSt:=inSt0                    }
{ if the answer is <CR> from the begining the input string remains unchanged.}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure MyWrite(S:string; cX:Integer);
var i:Byte;
BEGIN
  for i:=1 to Length(S) do if (S[i] = ' ') then BEGIN
    Delete(S,i,1);
    Insert('ú', S, i);
  END;
  Write(S);
  GoToXY(cX,WhereY);
END; {.. MyWrite}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - -}

var  prX,prY: Byte;   inSt0: string;
     cX,sX: Integer; {cursor pos. & start position in inSt0 for editing window}
     Finish,InsMode,InsOnly: Boolean;

BEGIN  {ReadCR ..}
  InsOnly:=FALSE;
  InsMode:=FALSE;
  if (W < 0) then BEGIN
    W:=-W;  InsOnly:=TRUE;  InsMode:=TRUE;
  END;
  prX:=WhereX;  prY:=WhereY;
  GotoXY(prX+W+1,prY);
  Write(Msg);  {.. write Msg to the right}
  TextColor(DarkGray);
  TextBackground(LightGray);
  if MyCRT then
   Window(prX+1,prY+4,prX+1+W ,prY+4)
  else
   Window(prX,prY,prX+W,prY);

  inSt0:=TrimString(inSt,W);
  sX:=1;
  cX:=Length(inSt)+1;
  repeat
    if (cX < 1) then BEGIN
      cX:=1;  Dec(sX);
    END;
    if (cX > W) then BEGIN
      cX:=W;
      if NOT InsMode then Inc(sX);
    END;
    if (sX < 1) then sX:=1;
    if (sX > 255-W) then sX:=255-W;
    if (sX > W) AND InsOnly then sX:=W;
    if (cX > Length(inSt)+1) then cX:=Length(inSt)+1;
    ClrScr;
    if (Length(inSt) > W) then MyWrite(Copy(inSt,sX,W),cX) else MyWrite(inSt,cX);
    GoToXY(cX,1);
    WaitToGo(Ch);
    if SpecialKey then BEGIN
      if ((Ch = #82) AND NOT InsOnly) then InsMode:=NOT InsMode; {#82 = <INS>}
      if (Ch = #75) then Dec(cX) {.. <-}
      else
      if (Ch = #77) then Inc(cX) {.. ->}
      else
      if (Ch = #79) OR (Ch = #117) then BEGIN {<END> OR <Ctrl>+<END> ..}
        cX:=Round(min2(W,Length(inSt)-sX+2));
        if (Ch = #117) then sX:=Length(inSt)-W+1;
      END else
      if (Ch = #8) OR (Ch = #127) then BEGIN  {<Back> OR <Ctrl>+<Back> ..}
        cX:=1;
        if (Ch =#127) then sX:=1;  {.. <Ctrl>+<Back>}
      END {special key}
      else
      if (Ch = #83) then Delete(inSt,sX+cX-1,1); {.. <DEL>}
    END {.. special key}
    else
    BEGIN {.. simple key}
      if (Ch = #8) then BEGIN {.. <Back-space>}
        Dec(cX);
        if (cX > 0) then Delete(inSt,sX+cX-1,1);
      END
      else if (Ch <> #9) AND (Ch <> #13) then BEGIN {any key less <TAB> AND <CR>}
        if InsMode then BEGIN
          Delete(inSt,sX+cX-1,1);
          Insert(Ch,inSt,sX+cX-1);
        END
        else Insert(Ch,inSt,sX+cX-1);
        Inc(cX)
      END;
    END; {.. simple key}
    Finish:=(Ch = #9) OR (Ch = #10) OR (Ch = #13) OR (Ch = #27); {<TAB> OR <CR> OR <ESC>}
    Finish:=Finish OR (Shuttle AND ((Ch = #72) OR (Ch = #80) AND Specialkey)); { <> <> }
  until Finish;

  if (Ch = #27) then {<Ctrl>+<CR> or <ESC>}
    if (W = 76) then inSt:='' {when handling files} else inSt:=inSt0;

  if (Ch = #10) then inSt:='.'; {signal that <Ctrl>+<CR> has been pressed}

  NormVideo;
  ClrScr;
  Write(Copy(inSt,1,W));
  if MyCrt then DialogWindow else Window(1,1,80,25);
  if (Msg <> '') then BEGIN
    GoToXY(prX+W,prY);  ClrEol;
  END;
  GoToXY(prX,prY);

END;  {.. ReadCR}

{----------------------------------------------------------------------------}
procedure ReadNR(var inSt:string; W:Shortint; Msg:St50);
{Accept a string inSt representing a number in a wLgt character long window. }
{See ReadCR for details about wLgt and Msg.                                  }
{It also recognizes:'##PI/##' '+##PI/##' '-##PI/#' '-##*PI/3' etc.           }

BEGIN
  repeat
    ReadCR(inSt,W,Msg);
    inSt:=TrimString(TrimBlanks(inSt),W);
    {test to allows only numerical inputs:}
  until (PIform2Val(inSt) < InfD) OR (inSt = '.');
END;  {.. ReadNR}

{----------------------------------------------------------------------------}
procedure CircInc(var j:Byte; jMin,jMax:Byte);
{Circular increment function - see code.                                     }
BEGIN
  Inc(j);
  if (j < jMin) then j:=jMax;
  if (j > jMax) then j:=jMin;
END;  {.. CircInc}

{----------------------------------------------------------------------------}
procedure CircDec(var j:Byte; jMin,jMax:Byte);
{Circular decrement function - see code.                                     }
BEGIN
  Dec(j);
  if (j < jMin) then j:=jMax;
  if (j > jMax) then j:=jMin;
END;  {.. CircDec}

{----------------------------------------------------------------------------}
procedure ChosEdit(var vStr:v20St30; N,W:Shortint; var Choice:Byte; Msg:St50);
{Use arrows keys to scroll through vStr[1..N] and press <CR> to select.      }
{vStr[Choice] is the default option. The entries in vStr[j] can be adited.   }
{W is the text box size, vStr[Choice] is the actual selection.               }

var  AuxStr:string;

BEGIN {ChosEdit ..}
  if (Choice < 1) OR (Choice > N) then Choice:=1; {make sure limits are OK}
  Shuttle:=TRUE;
  repeat
    AuxStr:=vStr[Choice];
    ReadCR(AuxStr,W, Msg);
    vStr[Choice]:=Copy(AuxStr,1,30); {30 stands from the 30 in v20St30}
    if SpecialKey AND ((Ch = #72) OR (Ch = #80)) then BEGIN {<> OR <>}
      if (Ch = #72) then Choice:=Choice-1;  {<>}
      if (Ch = #80) then Choice:=Choice+1;  {<>}
    END;
    if (Choice < 1) then Choice:=N;
    if (Choice > N) then Choice:=1;
  until (Ch = #9) OR (Ch = #13) OR (Ch = #27); {<TAB> OR <CR> OR <ESC>}
  Shuttle:=FALSE;
END;  {.. ChosEdit}

{----------------------------------------------------------------------------}
procedure Chose(vStr:v20St30; N,W:Shortint; var Choice:Byte);
{Use arrows keys to scroll through vStr[1..N] and press <CR> to select.      }
{vStr[Choice] is the default option. The entries in vStr[j] can NOT be edited}
{W is the text box size, vStr[Choice] is the actual selection.               }

var  prX,prY, EscChoice:Byte;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure ChooseWrite(vStr_j:string);
BEGIN
  ClrScr;
  Write(TrimString(vStr_j,W));
  GoToXY(W DIV 2+1,1);
END;  {.. ChooseWrite}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

BEGIN {Choose ..}
  if (Choice < 1) OR (Choice > N) then Choice:=1; {make sure limits are OK}
  prX:=WhereX;  prY:=WhereY;
  TextColor(Black);
  TextBackground(LightGray);
  if MyCRT then
   Window(prX+1,prY+4,prX+1+W ,prY+4)
  else
   Window(prX,prY,prX+W,prY);
  EscChoice:=Choice;
  ChooseWrite(vStr[Choice]);
  repeat
    WaitToGo(Ch);
    if SpecialKey AND ((Ch = #80) OR (Ch = #81)) then repeat
      CircInc(Choice,1,N);
    until (vStr[Choice] <> '');
    if SpecialKey AND (Ch = #72) OR (Ch = #73) then repeat
      CircDec(Choice,1,N);
    until (vStr[Choice] <> '');
    ChooseWrite(vStr[Choice]);
  until ((Ch = #9) OR (Ch = #13) OR (Ch = #27));
  if (Ch = #27) then Choice:=EscChoice;
  NormVideo;
  ChooseWrite(vStr[Choice]);
  if MyCrt then DialogWindow else Window(1,1,80,25);
  GoToXY(prX,prY);
END;  {.. Choose}


{----------------------------------------------------------------------------}
procedure ModifyWithinLimits(var u:integer; du,umin,umax:integer);
BEGIN
  u:=u+du;
  if (u < umin) then u:=umin;
  if (u > umax) then u:=umax;
END;  {..ModifyWithinLimits}


{============================================================================}
function MyGetDir(FileName:PathStr):DirStr;
{Return the directory of FileName.                                           }
BEGIN
  FSplit(FileName, Dir,Nme,Ext);
  MyGetDir:=Dir;
END;  {.. MyGetDir}

{============================================================================}
function GetName(FileName:PathStr):NameStr;
{Return the name of FileName.                                                }
BEGIN
  FSplit(FileName, Dir,Nme,Ext);
  GetName:=Nme;
END;  {.. GetName}

{============================================================================}
function GetExt(FileName:PathStr):ExtStr;
{Return the extension of FileName.                                           }
BEGIN
  FSplit(FileName, Dir,Nme,Ext);
  GetExt:=UpCaseStr(Ext);
END;  {.. GetExt}

{============================================================================}
procedure RenameFile(OldFileName,NewFileName:PathStr);
var  aFile: file;
BEGIN  {RenameFile ..}
  if (OldFileName = NewFileName) then Exit;
{$I-}
  Assign(aFile,OldFileName); Reset(aFile);
{$I+}
  if (IOresult = 0) then Close(aFile) else Exit; {OldFileName does not exist - nothing to rename}

{$I-}
  Assign(aFile,NewFileName); Reset(aFile);
{$I+}
  if (IOresult = 0) then BEGIN {NewFileName exists; change its Ext. to OLD}
    Close(aFile);
    BackUpFile(NewFileName);
  END;
  Assign(aFile,OldFileName);
{$I-}
  Rename(aFile,NewFileName);
{$I+}
  if (IOresult <> 0) then Exit; {incorect file name NewFileName}
END;  {.. RenameFile}

{----------------------------------------------------------------------------}
procedure BackUpFile(FileName:PathStr);
{Change the current extenssion of FileName into .OLD                         }

BEGIN {BackUpFile ..}
{$I-}  Assign(aFile,FileName); Reset(aFile); {$I+}
  if (IOresult <> 0) then Exit; {FileName does not exist. Nothing to backup.}
  Close(aFile);
  FSplit(FileName, Dir,Nme,Ext);
{$I-} Assign(aFile, Dir+Nme+'.OLD'); Reset(aFile); {$I+}
  if (IOResult = 0) then BEGIN {file Dir+Nme.OLD exists..}
    Close(aFile);
    Erase(aFile);  {erase DirName.OLD}
  END;
  Assign(aFile,FileName);
  Rename(aFile,Dir+Nme+'.OLD');
END;  {.. BackUpFile}

{============================================================================}
procedure UnDoBackUp(FileName:PathStr);
{Change the extenssion of GetName(FileName).OLD to FileName                  }

BEGIN {UnDoBackUp ..}
  FSplit(FileName, Dir,Nme,Ext);
{$I-} Assign(aFile, Dir+Nme+'.OLD'); Reset(aFile); {$I+}
  if (IOresult <> 0) then Exit; {Nme(FileName).OLD does not exist. Nothing to undo}
{$I-} Assign(aFile,FileName); Reset(aFile); {$I+}
  if (IOResult = 0) then BEGIN {erase FileName to make room for the "undone"}
    Close(aFile);
    Erase(aFile); {erase FileName}
  END;
  Assign(aFile, Dir+Nme+'.OLD');
  Rename(aFile,FileName);
END;  {.. UnDoBackUp}

{============================================================================}
procedure EraseAll(FileName:PathStr);
{Erase FileName or all files of a certain type WITHOUT confirmation.         }
{Example: if FileName = '$*.TMP' then erases all file of the type $*.TMP     }

BEGIN  {EraseAll ..}
  FSplit(FileName, Dir, Nme, Ext);
  if (UpCaseStr(Ext) = '.PAS') then Exit;  {.."suicide" protection!!}
  FindFirst(FileName, Archive, DirInfo);
  while (DosError = 0) do BEGIN
    {$I-}
    Assign(aFile,Dir+DirInfo.Name);
    Reset(aFile);
    {$I+}
    if (IOresult = 0) then BEGIN
      Close(aFile);
      Erase(aFile);
    END;
    FindNext(DirInfo);
  END;
END;  {.. EraseAll}


{----------------------------------------------------------------------------}
function ImplicitFileName(FileName:PathStr):PathStr;
{Return an implicit file name with the first 5 letters of FileName as prefix }
{Example1: FileName = 'PLTGOOD.DXF' returns 'PLTGO001.DXF';                  }
{Example2: FileName = 'P.DXF' if P0000003.DXF exists returns 'P0000004.DXF'  }

var Num:Word;  NumC:double;

BEGIN {ImplicitFileName ..}
  FSplit(FileName, Dir, Nme, Ext);
  while (Length(Nme) < 5) do Nme:=Concat(Nme,'0');
  while (Length(Nme) > 5) do Delete(Nme,Length(Nme),1);
  Num:=0;
  NumC:=InfD;
  FindFirst(Dir+Nme+'*'+Ext, Archive, DirInfo);
  while DosError = 0 do BEGIN
    NumC:=MyVal(CopY(DirInfo.Name,6,3));
    if (NumC > Num) AND (NumC < InfD) then Num:=Round(NumC);
    FindNext(DirInfo);
  END;
  if (NumC = InfD) then NumC:=0;
  if (NumC <  999) then Num:=Round(NumC)+1 else Num:=0;
  Nme:=Nme+Trim0s(MySt(Num,4));
  while (Length(Nme) < 8) do Insert('0',Nme,6);
  ImplicitFileName:=Dir+Nme+Ext;
END;  {.. ImplicitFileName}

{----------------------------------------------------------------------------}
procedure ListDirsAndFiles(CCh:char; var P:PathStr);
{List all files with extenssion EXT in the directory DIR; allow editing and  }
{navigation with <Tab> and Arrow keys and selection with <Cr>.               }
{<Ctrl>+<Del> erases the selected file WITHOUT confirmation!                 }
{<Ctrl>+<R> renames the selected file.                                       }

var  s14,s14plus,AuxStr: string;
     iLR,iLRmax,iUD,iUDup,iUDdn,iUDmax,j,jmax: integer;
     ArrowKeys,RenFile: Boolean;

label Again0;

BEGIN {ListDirsAndFiles ..}
  Ch:=#0;
  Shuttle:=FALSE;
  ArrowKeys:=FALSE;
  iUDup:=1;  iUDdn:=15;
  iUD:=1;    iLR:=1;
Again0:
  AuxStr:=P;
  RenFile:=FALSE;
  j:=0;
  ClrScr;
  GoToXY(1,2);
  FSplit(P, Dir,Nme,Ext);
{- - - - - - - - - - - - - - - - - - - - - - - -}
  FindFirst(Dir+'*.*',AnyFile,DirInfo);
  while (DosError = 0) do BEGIN  {..list directories}
    with DirInfo do BEGIN
      if (Attr AND 16 <> 0) AND (Nme[1] <> '.') then BEGIN
        Inc(j);
        s14:=DirInfo.Name+'\';
        s14plus:=s14;
        if (j > (iUDup-1)*5) AND (j <= iUDdn*5) then BEGIN
          if ((j-1) MOD 5) = 0 then Write(^j^m) else Write('³');
          while (Length(s14) < 14) do s14:=' '+s14;
          s14:=Copy(s14,1,14);
          if ArrowKeys AND (j = (iUD-1)*5+iLR) then BEGIN
            {AuxStr:=TrimBlanks(s14plus+'*'+Ext);}
            AuxStr:=TrimBlanks(s14plus)+Nme+Ext;
            if (CCh = '') then TextColor(LightRed);
            if (CCh = '') then TextColor(LightGreen);
          END;
          Write(s14);
          NormVideo;
        END;
      END;
    END;
    FindNext(DirInfo);
  END;  {.. lists directories}
{- - - - - - - - - - - - - - - - - - - - - - - -}
  FindFirst(P, AnyFile, DirInfo);
  while (DosError = 0) do BEGIN  {lists files..}
    with DirInfo do if (Attr AND 24 = 0) then BEGIN
      Inc(j);
      s14:=DirInfo.Name;
      s14plus:=s14;
      if (j > (iUDup-1)*5) AND (j <= iUDdn*5) then BEGIN
        if ((j-1) MOD 5) = 0 then Write(^j^m) else Write('³');
        while (Length(s14) < 14) do s14:=' '+s14;
        s14:=Copy(s14,1,14);
        if ArrowKeys AND (j = (iUD-1)*5+iLR) then BEGIN
          AuxStr:=TrimBlanks(s14plus);
          if (CCh = '') then TextColor(LightRed);
          if (CCh = '') then TextColor(LightGreen);
        END;
        Write(s14);
        NormVideo;
      END;
    END;
    FindNext(DirInfo);
  END;  {.. lists files}
{- - - - - - - - - - - - - - - - - - - - - - - -}
  jmax:=j;
  if ((jmax MOD 5) = 0) then iUDmax:=jmax DIV 5 else iUDmax:=jmax DIV 5+1;
  GoToXY(1,1);

  if (CCh = '') then TextColor(LightRed);
  if (CCh = '') then TextColor(LightGreen);
  Write(CCh+' ');
  NormVideo;

  if ArrowKeys then repeat
    GoToXY(2,1);
    Write(TrimString(P,-76));
    WaitToGo(Ch);
    if (Ch = #27) then BEGIN
      P:='';  Exit;
    END;
    if (Ch = #4) then BEGIN  {<Ctrl>+<D> = delete file}
      EraseAll(Dir+AuxStr);
      iUDup:=1;  iUDdn:=15;
      iUD:=1;    iLR:=1;
      Ch:=#13;
      Exit;
    END;
    if (Ch = #72) then iUD:=iUD-1; {  }
    if (Ch = #80) then iUD:=iUD+1; {  }
    if (Ch = #75) then iLR:=iLR-1; { <- }
    if (Ch = #77) then iLR:=iLR+1; { -> }
    if (iLR < 1) AND (Ch <> #27) then BEGIN
      Ch:=#0; iLR:=1;
    END;
    if (iUD < 1) AND ((Ch <> #27)) then BEGIN
      Ch:=#0; iUD:=1;
    END;
    if (iUD > iUDmax) AND (Ch <> #27) then BEGIN
      Ch:=#0; iUD:=iUDmax;
    END;

    if (iUD < iUDup) then BEGIN
      iUDup:=iUD; iUDdn:=iUD+14;
    END;
    if (iUD > iUDdn) then BEGIN
      iUDup:=iUD-14; iUDdn:=iUD;
    END;

    if (iUD = iUDmax) then BEGIN
      iLRmax:=jmax MOD 5;
      if iLRmax = 0 then iLRmax:=5;
    END
    else iLRmax:=5;
    if (iLR > iLRmax) then iLR:=iLRmax;
    if (Ch = #80) OR (Ch = #72) OR (Ch = #77) OR (Ch = #75) then goto Again0;
    if (Ch = #18) then {<Ctrl>+<R> = rename file}
      RenFile:=TRUE;
  until (Ch = #13) OR RenFile;

  if (Ch = #13) then AuxStr:=Dir+AuxStr;
  P:=AuxStr;
  GoToXY(2,1);
  ReadCR(AuxStr,76,'');  {Ch value is transmitted from ReadCR}
  if (Ch = #9) OR RenFile then BEGIN {<TAB> OR <Ctrl>+<R>}
    if RenFile then BEGIN
      RenameFile(P,AuxStr);
      P:=Dir+Nme+Ext;
    END;
    ArrowKeys:=TRUE;
    iUD:=1;    iLR:=1;
    goto Again0;
  END;
  P:=AuxStr;
END;  {.. ListDirsAndFiles}

{----------------------------------------------------------------------------}
procedure OpenReadFile (var FName:PathStr;  FNameS:PathStr);
{Accept from keybord the path+name+extension of an input file FName.   }
{FNameS is the default path+name+extension for FName.                  }

BEGIN {OpenReadFile ..}
  if (FNameS = '') then FName:='*.*' else FName:=FNameS;
  Ch:=#0;
  repeat
    ClrScr;
    FSplit(FName, Dir, Nme, Ext);
    if (Dir = '') then GetDir(0,Dir);
    if (Dir[Length(Dir)] <> '\') then Dir:=Dir+'\';
    FName:=Dir+Nme+Ext;

    ListDirsAndFiles('',FName);
    if (FName = '') then Exit;
    {$I-}
    Assign(aFile, FName);
    Reset(aFile);
    Close(aFile);
    {$I+}
    if (IOresult = 0) then Exit; {file exists..}
  until FALSE;
END;  {.. OpenReadFile}

{============================================================================}
procedure OpenWriteFile(var FName:PathStr; FNameS:PathStr);
{ Accept from keyboard the name FName of an output file as follows:          }
{ OpenWriteFile('*.Ext','*.Ext')     imposes extension Ext                   }
{ OpenWriteFile('*.*','Nme.Ext')    excludes file Nme.Ext                    }
{ OpenWriteFile('*.Ext','Nme.Ext')  imposes Ext and excludes file Nme.Ext    }

var  ImpExt, {TRUE -> extension of FName is imposed and cannot be changed }
     ExcFile {TRUE -> FNameS has to be excluded                           }
     : Boolean;
     NmeS : NameStr;
     ExtS : ExtStr;

label  L_Exit;

BEGIN {OpenWriteFile ..}
  Ch:=#0;
  FName :=UpCaseStr(FName);
  FNameS:=UpCaseStr(FNameS);
  FSplit(FName , Dir, Nme , Ext );
  FSplit(FNameS, Dir, NmeS, ExtS);

  ImpExt:=FALSE;
  if (Ext = ExtS) AND (Ext <> '.*') then ImpExt:=TRUE;  {.. impose extension}
  ExcFile:=FALSE;
  if (Pos('*',FNameS) = 0) AND (FNameS <> '') then ExcFile:=TRUE;

  if (Dir = '') then GetDir(0,Dir);
  if (Dir[Length(Dir)] <> '\') then Dir:=Dir+'\';
  if (Nme = '') then Nme:='*';
  FName:=Dir+Nme+ExtS;
  repeat
    Ch:=#13;
    ListDirsAndFiles('',FName);
    if (FName = '') then Exit;
    FSplit(FName, Dir, Nme, Ext);
    if (ImpExt AND (UpCaseStr(Ext) <> ExtS)) then BEGIN
      Ext:=ExtS;
      FName:=Dir+'*'+ExtS;
    END;
    if (ExcFile AND (UpCaseStr(Nme+Ext) = UpCaseStr(NmeS+ExtS))) then
      FName:=Dir+'*'+Ext;

    {$I-}
    Assign(aFile,FName);  Reset(aFile);
    {$I+}
    if (IOresult = 0) then BEGIN {FName already exists..}
      Close(aFile);
      Bip(100,50);
      GoToXY(1,1);
      Write(' Over-write ',Nme,Ext,' file (Y/N)? '); ClrEol;
      Ch:=ReadKey;
      if (Upcase(Ch) = 'Y') then BEGIN {change ext of FName to .OLD}
        BackUpFile(FName);
        Ch:=#0;
        goto L_Exit;
      END;
      FName:=Dir+'*'+Ext;
    END
    else BEGIN {file does not exist..}
      {$I-} Rewrite(aFile); {$I+}
      if (IOresult = 0) then BEGIN {FName is a valid file name..}
        Close(aFile);
        Erase(aFile);
        goto L_Exit;
      END;
    END;  {..file does not exist}
  until FALSE;
  L_Exit:
  ClrScr;
END;  {.. OpenWriteFile}

{----------------------------------------------------------------------------}
procedure ConcatFiles(FName1:PathStr;  FName2:PathStr);
{Given text files FName1 and FName2, it appends FName2 to FName1             }

var FT1,FT2: Text;  Row: string;

BEGIN
{$I-}
  Assign(FT1,FName1);  Append(FT1);
{$I+}
  if (IOresult <> 0) then Exit;  {..FName1 file does not exist}

{$I-}
  Assign(FT2,FName2);  Reset(FT2);
{$I+}
  if (IOresult <> 0) then Exit;  {..FName2 file does not exist}

  while NOT Eof(FT2) do BEGIN
    ReadLn(FT2,Row);
    WriteLn(FT1,Row)
  END;

  Close(FT1);
  Close(FT2);
  Erase(FT2);
END;  {.. ConcatFiles}

{----------------------------------------------------------------------------}
procedure GoToRowNr(var FT:text; j:LongInt);
var i:LongInt; Row: string;
BEGIN  {GoToRowNr ..}
  Reset(FT);
  i:=1;
  while (NOT Eof(FT) AND (i < j)) do BEGIN
    ReadLn(FT,Row); Inc(i);
  END;
END;  {.. GoToRowNr}

{----------------------------------------------------------------------------}
procedure ReverseTextFile(FName:PathStr; HeadSize,RecSize:Byte);
{Given text file FName and record length RecSize, it rewrites the file  }
{with the records in reversed order                                     }

var  FT,FT1: Text;   Row: string;
     FileLgt: LongInt;   i,j,RecNr:Word;

BEGIN {ReverseTextFile ..}
{$I-}
  Assign(FT,FName);  Reset(FT);
{$I+}
  if (IOresult <> 0) then Exit;  {..file FName does not exist}

  Assign(FT1,'$RevFile.TMP');  Rewrite(FT1);

  FileLgt:=0;
  while (NOT Eof(FT)) do BEGIN {count lines in FT..}
    ReadLn(FT,Row);
    Inc(FileLgt);
  END;

  if (FileLgt > HeadSize + RecSize) then BEGIN
    Reset(FT);
    if (HeadSize > 0) then for i:=1 to HeadSize do BEGIN {copy header..}
      ReadLn(FT,Row);
      WriteLn(FT1,Row);
    END;
    RecNr:=(FileLgt-HeadSize) DIV RecSize;
    if RecNr <> (FileLgt-HeadSize)/RecSize then BEGIN
      WriteLn('Check ReverseTextFile input parameters.  <CR>..');
      ReadLn;
    END;
    for j:=RecNr-1 downto 0 do BEGIN
      GoToRowNr(FT,HeadSize + RecSize*j + 1);
      for i:=1 to RecSize do BEGIN
        ReadLn(FT,Row);
        WriteLn(FT1,Row);
      END;
    END;
  END;

  Close(FT1);
  Close(FT);
  Erase(FT);
  RenameFile('$RevFile.TMP',FName);
END;  {.. ReverseTextFile}

{---------------------------------------------------------------------------}
procedure ViewASCIIfile(FName:PathStr; ViewMode:Byte;  var MaxNRcol:Byte;
          var RowStart,RowFin:LongInt; var OK:Boolean);
{ View an ASCII file with or without showing rows and columns      }
{ ViewMode=0,1,2  view only, number rows; number rows & show ruler }

var  MaxRowLgt,        {maximum row length}
     ClmOfs: Integer;  {column offset     }
     jRuler,
     WinHgt,           {text window hight 16 or 17}
     NRcol: ShortInt;  {max number of columns extracted so far}
     Row, Ruler: string;
     Over255: Boolean;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure GetRuler(s:string; var NR_col:ShortInt);
{Return the occurence of group of numbers in s and generate the Ruler.       }

var Ls,      {total length of s          }
    WDcol,   {width of current column    }
    jFin,    {index of end current column}
    i:Byte;
    Str3:string[3];

BEGIN  {GetRuler ..}
  if (ViewMode < 2) then Exit;
  if (s = '') then Exit;
  s:=EeProof(s);
  while (s[Length(s)] = ' ') AND (Length(s) > 1) do Delete(s,Length(s),1);
  Ls:=Length(s);
  if (Ls = 255) then BEGIN
    Over255:=TRUE;  Ls:=Ls-1;
  END;
  NR_col:=0;  WDcol:=0;
  for i:=1 to Ls+1 do BEGIN
    if Dot_0to9PlusEe(s[i]) AND (i <= Ls) then BEGIN
      Inc(WDcol);
      s[i]:=' ';
    END
    else if (WDcol > 0) OR (i = Ls) then BEGIN
      Inc(NR_col);
      Str3:=MySt(NR_col,3);
      if (WDcol = 1) AND (NR_col > 9)  then WDcol:=2;
      if (WDcol = 2) AND (NR_col > 99) then WDcol:=3;
      s[Round(Max2(i-(WDcol DIV 2)-1,1))]:=Str3[1];
      if (NR_col > 9)  then s[i-(WDcol DIV 2)]:=Str3[2];
      if (NR_col > 9)  then s[Round(Max2(i-(WDcol DIV 2),2))]:=Str3[2];
      if (NR_col > 99) then s[Round(Max2(i-(WDcol DIV 2)+1,3))]:=Str3[3];
      WDcol:=0;
    END;
  END;
  Ruler:=s;
  if (NR_col = 0) then BEGIN
    Ruler:='';  for i:=1 to Ls do Ruler:=Ruler+'!';
  END;
END;  {.. GetRuler}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure WriteRow(var FT:text; j:LongInt; Where_Y:Byte);

var Row77:string[77];

BEGIN  {WriteRow ..}
  if Eof(FT) then Exit;
  ReadLn(FT,Row);
  Row77:='';
  if (ViewMode <> 0) then BEGIN
    while (Pos(#9,Row) > 0) do Row[Pos(#9,Row)]:='³';
    Row77:=MySt(j,5)+'³';
    while (Length(Row77) < 6) do Insert(' ',Row77,1);
    if (Length(Row)-ClmOfs > 71) then Row77[77]:='¯';
    GoToXY(1,Where_Y);
  END
  else
    Where_Y:=Where_Y-1;

  Row77:=Concat(Row77, Copy(Row, ClmOfs+1, 80));
  GoToXY(1,Where_Y);
  Write(Row77);
END;  {.. WriteRow}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
procedure WriteRowS(var j:LongInt);

var jY:Byte;

BEGIN  {WriteRowS ..}
  if (j < 1) then j:=1;
  if (j > RowFin) then j:=RowFin;
  GoToRowNr(FT,j);
  for jY:=1 to WinHgt do BEGIN
    WriteRow(FT, j+jY-1,jY+1);
    if (jY = jRuler) then GetRuler(Row,NRcol);
  END;
  j:=j+jY;
  GoToXY(1,1);
  if (ViewMode = 0) then Exit;
  Write('Colum:');

  TextColor(Yellow);
  if (ViewMode = 2) then Write(Copy(Ruler, ClmOfs+1, 72));
  NormVideo;
END;  {.. WriteRowS}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
var j:LongInt;
    AuxStr:string;

label LBack,LExit;

BEGIN  {ViewASCIIfile ..}
  OK:=FALSE;
  Over255:=FALSE;
  RowFin:=0;
  MaxRowLgt:=0;
  NRcol:=0;
  MaxNRcol:=0;

{$I-}
  Assign(FT,FName);  Reset(FT);
{$I+}
  if (IOresult <> 0) then Exit; {..file does not exist}

  if (ViewMode > 0) then WinHgt:=16
  else BEGIN
    WinHgt:=17;
    OK:=TRUE;
  END;

  while (NOT Eof(FT)) do BEGIN  {count rows in FT..}
    ReadLn(FT,Row);
    GetRuler(Row,NRcol);
    if (NRcol > MaxNRcol) then MaxNRcol:=NRcol;
    ClmOfs:=Length(Row);  {reuse ClmOfs variable}
    while (Row[ClmOfs] = ' ') do Dec(ClmOfs);
    if (MaxRowLgt < ClmOfs) then MaxRowLgt:=ClmOfs;
    Inc(RowFin);
    if IsKeyPressed(27) then goto LExit; {<Esc>}
  END;
  GetRuler(Row,NRcol);
  if (RowFin = 0) OR (MaxRowLgt = 0) then BEGIN
    ClrScr;
    CenterMsgT('Empty file!  Press any key..','');
    WaitToGo(Ch);  goto LExit;
  END;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  ClmOfs:=0;
  MaxRowLgt:=MaxRowLgt-50;
  if (MaxRowLgt < 0) then MaxRowLgt:=0;
  SpecialKey:=TRUE;
  Ch:=#0;
LBack:
  GoToXY(1,1);
  AuxStr:='KEYS: [Ctrl+] ';
  if (RowFin >= WinHgt) then AuxStr:='KEYS: <Tab> [Ctrl+] <PgUp> <PgDn> ';
  if (MaxRowLgt <> 0) then AuxStr:=AuxStr+' '+Chr(27)+Chr(26);
  AuxStr:=AuxStr+' <Esc>, <CR>..';
  FooterT(7,AuxStr);
  ClrScr;
  jRuler:=1;
  j:=1;  WriteRowS(j);
  repeat
    if (ViewMode > 0) then GoToXY(1,jRuler+1) else  GoToXY(1,jRuler);
    WaitToGo(Ch);
    if (Ch = #27) then goto LExit;  {<ESC>}
    if SpecialKey then BEGIN
      if (Ch = #75) then {}
        if (ClmOfs > 0) then ClmOfs:=ClmOfs-1 else Ch:=#0;
      if (Ch = #115) then {<Ctrl>+}
        if (ClmOfs > 0) then ClmOfs:=ClmOfs-10 else Ch:=#0;
      if (Ch = #77) then {}
        if (ClmOfs < MaxRowLgt) then ClmOfs:=ClmOfs+1 else Ch:=#0;
      if (Ch = #116) then {<Ctrl>+}
        if (ClmOfs < MaxRowLgt) then ClmOfs:=ClmOfs+10 else Ch:=#0;
      if (Ch = #73)  then  j:=j-WinHgt;  {<PgUp>}
      if (Ch = #132) then  j:=WinHgt;    {<Ctrl>+<PgUp>}
      if (Ch = #72)  then  j:=j-1;   {Arrow up}
      if (Ch = #80)  then  j:=j+1;   {Arrow down}
      if (Ch = #81)  then j:=j+WinHgt;  {<PgDn>}
      if (Ch = #118) then j:=RowFin+2;  {<Ctrl>+<PgDn>}
      if (j < 1) then j:=1;
      if (j > RowFin+2) then j:=RowFin+2;
      if (Ch = #8) OR (Ch = #127) then BEGIN  {<Back> OR <Ctrl>+<Back>..}
        ClmOfs:=0; j:=1;  Ch:=#72;
      END;
    END;
    if (Ch = #9)  then  BEGIN {Insert - use different row to extract ruller}
      jRuler:=jRuler+1;
      if (jRuler > WinHgt) OR (jRuler > RowFin) then jRuler:=1;
    END;
    if (Ch = #77) OR (Ch = #115) OR (Ch = #116) then Ch:=#75;  {move }
    if (Ch = #73) OR (Ch = #132) then Ch:=#72;  {move }
    if (Ch = #81) OR (Ch = #118) then Ch:=#80;  {move }
    if (ClmOfs < 0) then ClmOfs:=0;
    if (ClmOfs > MaxRowLgt) then ClmOfs:=MaxRowLgt;
    if (Ch = #9) OR (SpecialKey AND ((Ch = #72) OR (Ch = #75) OR (Ch = #80))) then BEGIN
      ClrScr;
      j:=j-WinHgt;
      WriteRowS(j);
    END;
    if (Ch = #80) AND Eof(FT) then Bip(60,300);
  until (Ch = #13); {..<CR>}

  if Over255 then BEGIN
    FooterT(7,'Any row longer than 255 will be truncated and the information lost!');
    Bip(60,300);  WaitToGo(Ch);
  END;
  OK:=TRUE;

LExit:
  Close(FT);
  RowStart:=Round(min2(j-WinHgt+jRuler-1,RowFin));
END;  {.. ViewASCIIfile}

{============================================================================}
procedure wM3D(var F:text; s1:string; a,b,c,d,a1,b1,c1,d1,a2,b2,c2,d2:double; s2:St20);
{Write an M3D-type line to ASCII file F.                                     }
var AuxStr:string;

BEGIN
  AuxStr:='('+TrimBlanks(S1);
  if (a  < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2(a,12,3));
  if (b  < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2( b,12,3));
  if (c  < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2( c,12,3));
  if (d  < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2( d,12,3));
  if (a1 < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2(a1,12,3));
  if (b1 < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2(b1,12,3));
  if (c1 < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2(c1,12,3));
  if (d1 < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2(d1,12,3));
  if (a2 < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2(a2,12,3));
  if (b2 < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2(b2,12,3));
  if (c2 < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2(c2,12,3));
  if (d2 < InfD) then AuxStr:=AuxStr+' '+Trim0s(MySt2(d2,12,3));
  AuxStr:=AuxStr+') '+TrimBlanks(S2);
  WriteLn(F,AuxStr);
END;  {.. wM3D}

{===========================================================================}
BEGIN
  MyCrt:=FALSE;  {MyCrt=TRUE after the first call of InitCrt}
  Shuttle:=FALSE;
  DateTime0.hour0:=25;
  ClrScr;
END.  {.. LibInOut}
