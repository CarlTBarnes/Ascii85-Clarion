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
Ascii85Decode        PROCEDURE  (StringTheory pSt)
TestCode    PROCEDURE()
DB          PROCEDURE(STRING DebugMessage)   !Output Debug String
DBClear     PROCEDURE()                      !Clear DebugView Buffer  


      MODULE('api')
        OutputDebugString(*CSTRING cMsg),PASCAL,DLL(1),RAW,NAME('OutputDebugStringA')
        DebugBreak(),PASCAL,DLL(1) 
        GetLastError(),LONG,PASCAL,DLL(1) 
      END
    END

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
        TEXT,AT(1,150),FULL,USE(txt),HVSCROLL
    END
    CODE
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
    Ascii85Decode(St)
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
    Ascii85Decode(St)
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
       Ascii85Decode(STdecode)    
       
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
!  LOOP Ln=SIZE(Leviathan) TO 1 BY -1 
  LOOP Ln=1 TO SIZE(Leviathan) BY 1
       STencode.SetValue(Leviathan[1 : Ln]) 
       Ascii85Encode(STencode)
       IF INRANGE(Ln,57,59) THEN 
          Bang.StringView('Length=' & Ln &'<13,10,13,10>Value=' & Leviathan[1 : Ln] & '<13,10,13,10>Encode=' & STencode.GetValue()) 
          !Bang.ValueView(STencode,'Len Encode Test #' & Ln) 
       END 

       STdecode.SetValue(STencode) 
       Ascii85Decode(STdecode)    
       
       IF STdecode.GetValue() <> Leviathan[1 : Ln] THEN  
           setclipboard('"' & STdecode.GetValue() &'"<13,10>"' &Leviathan[1 : Ln] &'"' )
           Message('Test Len='& Ln &' DecodeString Does NOT Match Encode') 
           Break
       END 
  END
  Message('Length Tests ' & CHOOSE(Ln=1+SIZE(Leviathan),'PASSED',' Failed? ' & Ln ))    
   
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
Ascii85Encode        PROCEDURE  (StringTheory pSt,Long pWrapLen=75,Bool pAdobe=1)
st       StringTheory
myLong   long,auto
myULong  ulong,over(myLong)
myStr    String(4),over(myLong)
tempStr  String(4),auto        
x        long,auto
y        long,auto
padChars long,auto
outLen   long,auto
out5     String(5),auto

  CODE
  if ~pSt._DataEnd then return.
  if pWrapLen < 0  then pWrapLen = 0.

  padChars = pSt._DataEnd % 4
  if padChars then padChars = 4 - padChars; pSt.append(all('<0>',padChars)).   ! pad with null chars
  outLen = (pSt._DataEnd * 5 / 4) + choose(~pAdobe,0,4)   ! adobe has 4 extra chars
  if pWraplen then outlen += 2 * int(outlen / pWrapLen).  ! add 2 chars for each line break  
  st.SetLength(outlen)  ! preallocate output memory (optional)
  if pAdobe 
    st.setValue('<<~')
  else
    st.free()
  end
  loop x = 1 to pSt._DataEnd by 4
    ! swap endian-ness as we go...
    myStr[1] = pSt.valueptr[x+3]
    myStr[2] = pSt.valueptr[x+2]
    myStr[3] = pSt.valueptr[x+1]
    myStr[4] = pSt.valueptr[x]
    if ~myLong then st.append('z'); cycle.  ! short form for 0 (low-values)
    if ~pAdobe and ~myStr then st.append('y'); cycle. ! short form for spaces - not supported by Adobe
    out5[5] = chr(myULong%85 + 33)          ! use Ulong first time in case top bit is on
    myUlong /= 85
    loop y = 4 to 2 by -1
      out5[y] = chr(myLong%85 + 33)         ! use long where possible as faster
      mylong /= 85
    end
    out5[1] = chr(myLong + 33)
    st.append(out5)
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
  pSt.SetValue(st)    !  pSt._StealValue(st)    ! point our passed object to our output
  RETURN 
!==========================================================
Ascii85Decode        PROCEDURE  (StringTheory pSt)
st       StringTheory
myLong   long
myUlong  ulong,over(myLong)
myStr    String(4),over(myLong)
x        long
y        long
padChars long

  CODE
  if pSt._DataEnd > 3 and pSt.startsWith('<<~') and pSt.endsWith('~>') 
    pSt.crop(3, pSt._DataEnd-2)  ! remove Adobe begin/end chars
  end
  x = 1
  loop 5 times
    loop x = x to pSt._DataEnd
      case val(pSt.valueptr[x])
      of 122; st.append('<0,0,0,0>')      !z used for zeroes (low-values)
      of 121; st.append('<32,32,32,32>')  !y used for spaces
      of 33 to 117
        y += 1
        if y < 5
          myLong = (myLong * 85) + val(pSt.valueptr[x]) - 33
        else
          myUlong = (myUlong * 85) + val(pSt.valueptr[x]) - 33 
          st.append(myStr[4])
          st.append(myStr[3])
          st.append(myStr[2])
          st.append(myStr[1])
          y = 0
          myLong = 0
        end
      end !case
    end
    if y ! padding required? 
      padChars += 1
      pSt.append('u')   ! pad with u char
    else
      break
    end
  end
  if padChars then st.setLength(st._DataEnd - padChars).
  pSt.SetValue(st)    ! pSt._StealValue(st)    ! point our passed object to our output
  RETURN 