!ASCII 85 Encode / Decode posted by Geoff Robinson on
!    https://clarionhub.com/t/converting-ascii85-to-binary/4047/7?u=carlbarnes
!
!Carl's Test code to verify they work with the same tests I ran against my code.
!Released under the MIT License 2021
!
!Base Program based on ScratchTheory from https://github.com/CarlTBarnes/StringTheory-Tools
!
!Defines: StringTheoryLinkMode=>1;StringTheoryDllMode=>0;_ABCLinkMode_=>1;_ABCDllMode_=>0

  PROGRAM  
    INCLUDE 'TplEqu.CLW'
    INCLUDE 'KeyCodes.CLW'
    INCLUDE('StringTheory.inc'),ONCE
    INCLUDE('BigBangTheory.INC'),ONCE   !From  https://github.com/CarlTBarnes/StringTheory-Tools
    MAP
Ascii85Encode        PROCEDURE  (StringTheory pSt,Long pWrapLen=75,Bool pAdobe=1)
Ascii85Decode        PROCEDURE  (StringTheory pSt),LONG !0=Worked, else Bad Byte
TestCode    PROCEDURE()
DB          PROCEDURE(STRING DebugMessage)   !Output Debug String
DBClear     PROCEDURE()                      !Clear DebugView Buffer  


      MODULE('api')
        OutputDebugString(*CSTRING cMsg),PASCAL,DLL(1),RAW,NAME('OutputDebugStringA')
        DebugBreak(),PASCAL,DLL(1) 
        GetLastError(),LONG,PASCAL,DLL(1) 
      END
    END

LeviDOTs  STRING('Man.is.distinguished,.not.only.by.his.reason,.but.by.this.singular.passion.from.other.animals,.which.is.a.lust.of.the.mind,.that.by.a.perseverance.of.delight.in.the.continued.and.indefatigable.generation.of.knowledge,.exceeds.the.short.vehemence.of.any.carnal.pleasure.')
Leviathan STRING('Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.')
LeviEncoded STRING('<<~9jqo^BlbD-BleB1DJ+*+F(f,q/0JhKF<<GL>Cj@.4Gp$d7F!,L7@<<6@)/0JDEF<<G%<<+EV:2F!,' & |
  'O<<DJ+*.@<<*K0@<<6L(Df-\0Ec5e;DffZ(EZee.Bl.9pF"AGXBPCsi+DGm>@3BB/F*&OCAfu2/AKY' & |
  'i(DIb:@FD,*)+C]U=@3BN#EcYf8ATD3s@q?d$AftVqCh[NqF<<G:8+EV:.+Cf>-FD5W8ARlolDIa' & |
  'l(DId<<j@<<?3r@:F%a+D58''ATD4$Bl@l3De:,-DJs`8ARoFb/0JMK@qB4^F!,R<<AKZ&-DfTqBG%G' & |
  '>uD.RTpAKYo''+CT/5+Cei#DII?(E,9)oF*2M7/c~>') 
WhiteSpace  STRING('<<~9jqo^BlbD-BleB1DJ+*+F(f,q/0JhKF<<GL>Cj@.4Gp$d7F!,L7@<<6@)/0JDEF<<G%<<+EV:2F!,' & |
  '<13,10,32>O<<DJ+*.@<<*K0@<<6L(Df-\0Ec5e;DffZ(EZee.Bl.9pF"AGXBPCsi+DGm>@3BB/F*&OCAfu2/AKY' & |
  '<13,10,9>i(DIb:@FD,*)+C]U=@3BN#EcYf8ATD3s@q?d$AftVqCh[NqF<<G:8+EV:.+Cf>-FD5W8ARlolDIa' & |
  '<13,10,11>l(DId<<j@<<?3r@:F%a+D58''ATD4$Bl@l3De:,-DJs`8ARoFb/0JMK@qB4^F!,R<<AKZ&-DfTqBG%G' & |
  '<13,10,12>>uD.RTpAKYo''+CT/5+Cei#DII?(E,9)oF*2M7/c~>') 

G_Bang BigBangTheory        !Globals
G_ST   StringTheory
G_Lne  StringTheory    
PassFail BYTE  !1=Pass 2=Fail
IconPass EQUATE(Icon:Tick)   
IconFail EQUATE(Icon:Cross)
Split75  BYTE(1)
Failed   LONG    !Ascii85Decode() returns fail point
    CODE
    TestCode()
    RETURN
!===========================================================================
TestCode   PROCEDURE
X      LONG
Txt    STRING(4000)
Window WINDOW('ST Ascii85 Test of Geoffs Functions '),AT(,,400,200),CENTER,GRAY,IMM,SYSTEM,FONT('Segoe UI',9),RESIZE
        BUTTON('1. Leviathan Encode '),AT(9,10),USE(?Test1)
        BUTTON('2. Leviathan Decode'),AT(9,30),USE(?Test2)
        BUTTON('3. WhiteSpace Decode'),AT(9,50),USE(?Test3)
        BUTTON('4. All 256 Characters'),AT(9,70),USE(?Test4)
        BUTTON('5. Various Length Tests'),AT(9,90),USE(?Test5)
        BUTTON('6. Hex 0,0,0,0 Z Tests'),AT(9,110),USE(?Test6)
        BUTTON('7. File ClaRun.DLL Encode Test'),AT(9,130),USE(?Test7)
        CHECK('Encode Split 75'),AT(140,132),USE(Split75)
        TEXT,AT(1,150),FULL,USE(txt),HVSCROLL
    END
    CODE
    SYSTEM{PROP:MsgModeDefault}=MSGMODE:CANCOPY
    OPEN(WINDOW)
    0{PROP:text}=clip(0{PROP:text}) &' - Library ' & system{PROP:LibVersion,2} &'.'& system{PROP:LibVersion,3}
    ACCEPT
        CASE EVENT()
        OF EVENT:OpenWindow 
        OF EVENT:Timer
        END
        CASE ACCEPTED()
        OF ?Test1       ; DO Test1Rtn
        OF ?Test2       ; DO Test2Rtn
        OF ?Test3       ; DO Test3Rtn
        OF ?Test4       ; DO Test4Rtn
        OF ?Test5       ; DO Test5Rtn 
        OF ?Test6       ; DO Test6Rtn 
        OF ?Test7       ; DO Test7Rtn 
        END
        CASE FIELD()
        END
    END
    CLOSE(WINDOW)
!========================================================================
Test1Rtn ROUTINE  !------------------------------------------------------
    DATA
Bang BigBangTheory
ST   StringTheory
Lne  StringTheory    
    CODE
    ST.SetValue(Leviathan)
    Bang.ValueView(ST,'Value to Encode')
    Ascii85Encode(St)
    Bang.ValueView(ST,'Encoded')

    ST.SetValue(Leviathan)
    Ascii85Encode(St,0)  !0= No Wrap
    Message('Leviathan Encoded Matches = ' & CHOOSE(St.GetValue()=LeviEncoded,'YES',' NO') )
    
Test2Rtn ROUTINE  !------------------------------------------------------
    DATA
Bang BigBangTheory
ST   StringTheory
Lne  StringTheory    
    CODE
    ST.SetValue(LeviEncoded)
    Bang.ValueView(ST,'Value to Decode')
    Failed = Ascii85Decode(St) 
        IF Failed THEN Message('Decode Failed @ ' & Failed ).
    Bang.ValueView(ST,'Decoded')
    Message('Leviathan Decoded Matches = ' & CHOOSE(St.GetValue()=Leviathan,'YES',' NO') )
    
Test3Rtn ROUTINE  !------------------------------------------------------ 
    DATA
Bang BigBangTheory
ST   StringTheory
Lne  StringTheory    
    CODE
    ST.SetValue(WhiteSpace)
    Bang.ValueView(ST,'Value to Decode')
    Failed = Ascii85Decode(St)
       IF Failed THEN Message('Decode Failed @ ' & Failed ).
    Bang.ValueView(ST,'Decoded')
    Message('Leviathan WhiteSpace Decoded Matches = ' & CHOOSE(St.GetValue()=Leviathan,'YES',' NO') )
    
Test4Rtn ROUTINE  !------------------------------------------------------ 
    DATA
Bang      BigBangTheory
STencode  StringTheory
STdecode  StringTheory 
All256    STRING(256)
A USHORT
    CODE 
  LOOP A=1 TO 256 ; All256[A]=CHR(A-1) ; END 
  LOOP A=256 TO 1 BY -1
       STencode.SetValue(All256) 
       Ascii85Encode(STencode)
       IF A > 250 THEN Bang.ValueView(STencode,'256 Encode Test #' & A) .

       STdecode.SetValue(STencode) 
       Failed =  Ascii85Decode(STdecode) 
          IF Failed THEN Message('Test #' & A &' Decode Failed @ ' & Failed ).
       
       IF STdecode.GetValue() <> All256 THEN  
           setclipboard('"' & STdecode.GetValue() &'"<13,10>"' & All256 &'"' )
           Message('A='& A &' All 256 DecodeString Does NOT Match Encode') 
           Break
       END 
       All256 = All256[256] & All256  !Rotate so high bye chnages
  END
  Message('High ASCII all 256 tests ' & CHOOSE(A=0,'PASSED',' Failed? ' & A ))

Test5Rtn ROUTINE  !---- Split code you can modify -------------------------------------------------- 
    DATA
Bang      BigBangTheory
STencode  StringTheory
STdecode  StringTheory 
Ln     LONG
    CODE 
  LOOP Ln=1 TO SIZE(Leviathan) BY 1
     !  STencode.SetValue(CLIP(Leviathan[1 : Ln]))   !Note CLIP() so no trailing spaces.
       STencode.SetValue(CLIP(LeviDOTs[1 : Ln]))     !Has Dots for Spaces so no trailing
       Ascii85Encode(STencode)   
       !Check the line wrapping at 75. 
       IF INRANGE(Ln,56,59) OR INRANGE(Ln,56+60,59+59) THEN 
          Bang.StringView('Clip Length=' & LEN(CLIP(LeviDOTs[1 : Ln])) & '  Ln=' & Ln & |
                    '  Encoded Length=' & STencode.Length() &'  Check Line Wrap 75?' &  |
                    '<13,10,13,10>To Encode:<13,10>' & LeviDOTs[1 : Ln] & |
                    '<13,10,13,10>Encoded:<13,10>' & STencode.GetValue(), |
                    'Ascii85Encode Length Test Ln=' & Ln) 
       END 

       STdecode.SetValue(STencode) 
       Failed =  Ascii85Decode(STdecode)
          IF Failed THEN Message('Test Ln#' & Ln &' Decode Failed @ ' & Failed ).
       
       IF STdecode.GetValue() <> LeviDOTs[1 : Ln] THEN  
           setclipboard('"' & STdecode.GetValue() &'"<13,10>"' &LeviDOTs[1 : Ln] &'"' )
           Message('Test Len='& Ln &' DecodeString Does NOT Match Encode') 
           Break
       END 
  END
  Message('Length Tests ' & CHOOSE(Ln=1+SIZE(LeviDOTs),'PASSED',' Failed? ' & Ln ))    

Test6Rtn ROUTINE  !------------------------------------------------------ 
    DATA
Bang      BigBangTheory
STencode  StringTheory
STdecode  StringTheory 
All256    STRING(256)
A USHORT
bAdobe  BYTE(1)
    CODE 
  !Below line works out the Encoded value that Decodes to 'Spaces----' is <9Eh,7Dh,5Ah,23h,FFh,94h,4Ah,82h>
  !STencode.SetValue('Spaces----') ; Ascii85Decode(STencode) ; bang.ValueView(STencode,'Spaces')
  !STencode.SetValue('-----') ; Ascii85Decode(STencode) ; bang.ValueView(STencode,'Spaces')

  !04/22/21 Added 'z' to 0,0,0,0 Zero test  .
  !         No change to Ascii85Decode, let StringTheory append expand string
  LOOP A=1 TO 20
       EXECUTE A
           All256=ALL(CHR(0),256)
           All256=ALL('aaaa<0,0,0,0>',256)             !Test 2
           All256=ALL('<0,0,0,0>aaaa',256)
           All256=ALL('<0,0,0>aaaa',256)               !#4 has 3 x 00
           All256=ALL('<0,0,0,0,0>aaaa',256)           !#5 has 5 x 00
           All256=ALL('<81h,82,83h,84h,0,0,0,0>',256)
           All256=ALL('<0,0,0,0,81h,82,83h,84h>',256) 
           All256='<9Eh,7Dh,5Ah,23h,FFh,94h,4Ah,82h>' & |   !#8  Spaces----
                    ALL(' {16}<25h,C8h,02h,1Ch>',256)       !    16 Spaces -----
           bAdobe=0                                         !#9 Spaces----yyyy----
           All256='<A1h,34h,CCh,15h,72h,DBh,9Dh,76h,28h>' & ALL(CHR(0),256) ! Test End
       ELSE   
           BREAK 
       END

       STencode.SetValue(All256) 
       Ascii85Encode(STencode,,bAdobe)
       Bang.ValueView(STencode,'Zero Encode Test #' & A) 

       STdecode.SetValue(STencode) 
       Failed = Ascii85Decode(STdecode)
          IF Failed THEN Message('Test #' & A &' Decode Failed @ ' & Failed ).
       
       IF STdecode.GetValue() <> All256 THEN  
           setclipboard('"' & STdecode.GetValue() &'"<13,10>"' & All256 &'"' )
           Message('A='& A &' All 256 DecodeString Does NOT Match Encode') 
           Break
       END 
  END


Test7Rtn ROUTINE  !------------------------------------------------------ 
    DATA
Bang      BigBangTheory 
LoadLen LONG 
STencode  StringTheory
STdecode  StringTheory  
Time1 LONG  
Time2 LONG 

    CODE
  IF ~STencode.LoadFile('ClaRun.DLL') THEN 
      Message('LoadFile ClaRun.DLL Failed ' & STencode.winErrorCode )
      EXIT
  END       
  LoadLen = STencode.Length() 

    Time1=CLOCK()
    Ascii85Encode(STencode,CHOOSE(~Split75,0,75))
    Time2=CLOCK()

    Message((Time2-Time1)/100 & ' seconds to Encode {50}' & |
            '||File loaded Bytes<9>=' & LoadLen & |
            '||Encoded Length<9>=' & STencode.Length() , |
            'Encode ClaRun.DLL',,'Decode 1 Seconds') 

   STdecode.SetValue(STencode) 

    Time1=CLOCK()
    Failed = Ascii85Decode(STdecode)
       IF Failed THEN Message('Decode Failed @ ' & Failed ).
    Time2=CLOCK()

    Message((Time2-Time1)/100 & ' seconds to Decode {50}' & |
            '||File loaded Bytes<9>=' & LoadLen & |
            '||Decode Length<9>=' & STdecode.Length() , |
            'Decode ClaRun.DLL') 
   
  
!========================================================================================
DB   PROCEDURE(STRING xMessage)
Prfx EQUATE('ScratchST: ')
sz   CSTRING(SIZE(Prfx)+SIZE(xMessage)+1),AUTO
  CODE 
  sz  = Prfx & CLIP(xMessage)
  OutputDebugString( sz )
!------------------
DBClear PROCEDURE()
DbgClear CSTRING('DBGVIEWCLEAR')    !Message to Clear the buffer. Must UPPER and first i.e. without a Prefix
    CODE 
    OutputDebugString(DbgClear)     !Call API directly, cannot have Prefix, must be first            

!========================================================== 
! Goeff's code posted 25-June-2021
! https://clarionhub.com/t/converting-ascii85-to-binary/4047/12?u=carlbarnes
!==========================================================
Ascii85Encode        PROCEDURE  (StringTheory pSt,Long pWrapLen=75,Bool pAdobe=1)
st       StringTheory
myLong   long,auto
myULong  ulong,over(myLong)
         group,pre(),over(myLong)
myStr1     string(1)
myStr2     string(1)
myStr3     string(1)
myStr4     string(1)
         end ! group
x        long,auto
y        long,auto
padChars long,auto
outLen   long,auto
outstr   String(5),auto
         group,pre(),over(outStr)
out1       byte
out2       byte
out3       byte
out4       byte
out5       byte
         end ! group

  CODE
  if ~pSt._DataEnd then return.
  if pWrapLen < 0  then pWrapLen = 0.

  padChars = pSt._DataEnd % 4
  if padChars then padChars = 4 - padChars; pSt.append(all('<0>',padChars)).   ! pad with null chars
  outLen = (pSt._DataEnd * 5 / 4) + choose(~pAdobe,0,4)   ! adobe has 4 extra chars
  if pWraplen then outlen += 2 * int(outlen / pWrapLen).  ! add 2 chars for each line break  
  st.SetLength(outlen)  ! optional: preallocate output memory
  if pAdobe 
    st.setValue('<<~')
  else
    st.free()
  end
  loop x = 1 to pSt._DataEnd by 4
    ! swap endian-ness as we go...
    myStr1 = pSt.valueptr[x+3]
    myStr2 = pSt.valueptr[x+2]
    myStr3 = pSt.valueptr[x+1]
    myStr4 = pSt.valueptr[x]
    if ~myLong then st.append('z'); cycle.            ! short form for 0 (low-values)
    if ~pAdobe and myLong=20202020h then st.append('y'); cycle. ! short form for spaces - not supported by Adobe
    out5 = myULong%85 + 33   ! use Ulong first time in case top bit is on
    myUlong /= 85
    ! unrolled the loop - we use long from here as faster than ulong
    out4 = myLong%85 + 33
    mylong /= 85
    out3 = myLong%85 + 33
    mylong /= 85
    out2 = myLong%85 + 33
    mylong /= 85
    out1 = myLong%85 + 33
    st.append(outStr)
  end
  if padChars then st.setLength(st._DataEnd - padChars).
  if pAdobe   then st.append('~>').
  if pWrapLen
    st.splitEvery(pWrapLen)
    if pAdobe and len(st.getLine(st.records())) = 1
      ! do NOT split ending ~>
      st.deleteLine(st.records()) 
      st.setLine(st.records(),st.getLine(st.records())&'>')
    end
    st.join('<13,10>')
  end
  pSt._StealValue(st)    ! point our passed object to our output


Ascii85Decode        PROCEDURE  (StringTheory pSt) !,long  ! Declare Procedure
st        StringTheory
myGroup   group,pre()
myStr1      string(1)
myStr2      string(1)
myStr3      string(1)
myStr4      string(1)
myStr5      string(1)
myStr6      string(1)
myStr7      string(1)
          end ! group
myLong    long, over(myGroup)
myUlong   ulong,over(myGroup)
CurValue  long,auto   ! value of current character
x         long,auto
y         long
AdobePrfx long

  CODE
  if pSt._DataEnd > 3 and pSt.valuePtr[1 : 2] = '<<~' and pSt.valuePtr[pSt._dataEnd-1 : pSt._dataEnd] = '~>' 
    AdobePrfx = 2
    pSt.setLength(pSt._dataEnd - 2)
    x = 3
  else
    x = 1
  end
  st.setLength(pSt._DataEnd); free(st)  ! preallocate some space (optional)
  myLong = 0
  loop x = x to pSt._DataEnd
    curValue = val(pSt.valueptr[x])
    case curValue
    of 33 to 117
      y += 1
      if y < 5
        myLong = myLong*85 + curValue - 33
      else
        myUlong = myUlong*85 + curValue - 33
        myStr5 = myStr3;  myStr6 = myStr2; myStr7 = myStr1 ! swap endian-ness (reverse byte order)
        st.CatAddr(address(myStr4),4)
        y = 0
        myLong = 0
      end
    of 122 
      if y then return x+AdobePrfx.  ! error - 'z' within group of 5 chars
      st.append('<0,0,0,0>')         ! z used for zeroes (low-values)
    of 121
      if y then return x+AdobePrfx.  ! error - 'y' within group of 5 chars
      st.append('<32,32,32,32>')     ! y used for spaces
    of 8 to 13 
    orof 32
      ! valid formating character so just ignore it
    else
      ! error - dud/unexpected character so return position
      return x + AdobePrfx
    end !case
  end
  if y > 1 ! padding required?
    loop 4-y times    
      myLong = myLong*85 + 84  ! 84 = val('u') - 33 = 117 - 33
    end
    myUlong = myUlong*85 + 84
    case y
    of 2
      st.append(myStr4)
    of 3  ! myStr4 & myStr3
      myStr5 = myStr3
      st.CatAddr(address(myStr4),2)
    of 4  ! myStr4 & myStr3 & myStr2
      myStr5 = myStr3;  myStr6 = myStr2
      st.CatAddr(address(myStr4),3)
    end
  end
  pSt._StealValue(st)    ! point our passed object to our output
  return 0               ! all is well in the world (valid input decoded without error)  