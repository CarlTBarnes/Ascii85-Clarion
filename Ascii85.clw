!Test CbAscii85Class 
  PROGRAM   
    INCLUDE('SystemString.INC'),ONCE
    INCLUDE('CbAscii85.INC'),ONCE 

    INCLUDE('BigBangString.INC'),ONCE   !From  https://github.com/CarlTBarnes/StringTheory-Tools
Bang BigBangString        !use to view strings and hex

Ascii85  CbAscii85Class   
NoWrap85 CbAscii85Class   
  MAP
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
All256 STRING(256)
A USHORT
Result BOOL
Ln     LONG
PassFail BYTE  !1=Pass 2=Fail
IconPass EQUATE(Icon:Tick)   
IconFail EQUATE(Icon:Cross)   
  CODE
  SYSTEM{PROP:MsgModeDefault}=MSGMODE:CANCOPY
  !DO UlongTestRtn   !ULong calc checks
  !DO FileTestRtn ; return 
  !GOTO Zero0000Label:
  !GOTO LengthTestsLabel:
  !GOTO All256Label:      !Test High Ascii on end and rotate to front
  !GOTO Hi256LenLabel:    !Test High Ascii at the Front for LONG/ULONG issue
  !DO ReadMeCodeRtn
  !--- Decode Test ---
  Result = Ascii85.DecodeString(LeviEncoded & |
                               ' <13,10,9,11,12,32,0>')  !Trailing whitespace
  IF ~Result THEN 
      Message('.DecodeString(LeviEncoded)  Failed Error=' & Ascii85.ErrorMsg,,IconFail) 
  ELSIF Ascii85.DecodedStr &= NULL THEN 
      Message('Bug .DecodeString(LeviEncoded) returned True but .DecodedStr is NULL')
  ELSE 
     SETCLIPBOARD(Ascii85.DecodedStr)
     PassFail=CHOOSE(Ascii85.DecodedStr=Leviathan,1,2)
     Message('DecodeString() Result=' & Result & ' Error=' & Ascii85.ErrorMsg & |
         '||DecodeString ' & |
         '|Size=' & Ascii85.DecodedSize & |
         '|Len='  & Ascii85.DecodedLen & | 
         '|Str='  & Ascii85.DecodedStr & |
         '||' & CHOOSE(PassFail,'PASSED = Leviathan','FAILED <<> Leviathan' ) ,|
         'Ascii85.DecodeString(LeviEncoded) ',CHOOSE(PassFail,IconPass,IconFail) )
  END  

  !--- Decode WhiteSpace Test ---
  Result = Ascii85.DecodeString(WhiteSpace) 
  IF ~Result THEN 
      Message('.DecodeString(WhiteSpace)  Failed Error=' & Ascii85.ErrorMsg ) 
  ELSIF Ascii85.DecodedStr &= NULL THEN 
      Message('Bug .DecodeString(WhiteSpace) returned True but .DecodedStr is NULL')
  ELSE 
     SETCLIPBOARD(Ascii85.DecodedStr)
     PassFail=CHOOSE(Ascii85.DecodedStr=Leviathan,1,2)
     Message('DecodeString() Result=' & Result & ' Error=' & Ascii85.ErrorMsg & |
         '||DecodeString ' & |
         '|Size=' & Ascii85.DecodedSize & |
         '|Len='  & Ascii85.DecodedLen & | 
         '|Str='  & Ascii85.DecodedStr & |
         '||' & CHOOSE(PassFail,'PASSED = Leviathan','FAILED <<> Leviathan' ) ,|
         'Ascii85.DecodeString(WhiteSpace) ',CHOOSE(PassFail,IconPass,IconFail))
  END  

  
  !--- Encode Test ---
  NoWrap85.LineLength=0   !No 13,10 to Match my LeviEncoded test
  Result = NoWrap85.EncodeString(Leviathan)
  Result = Ascii85.EncodeString(Leviathan)
      
  IF ~Result THEN 
      Message('.EncodeString(Leviathan)  Failed Error=' & Ascii85.ErrorMsg ) 
  ELSIF Ascii85.EncodedStr &= NULL THEN 
      Message('Bug .EncodeString(Leviathan) returned True but .EncodedStr is NULL')
  ELSE 
     SETCLIPBOARD(Ascii85.EncodedStr) 
     PassFail=CHOOSE(NoWrap85.EncodedStr=LeviEncoded,1,2)
     Message('EncodeString() Result=' & Result & ' Error=' & Ascii85.ErrorMsg & |
         '||EncodeString' & |
         '|Size=' & Ascii85.EncodedSize & |
         '|Len='  & Ascii85.EncodedLen & | 
         '|Str='  & Ascii85.EncodedStr & | 
         '||' & CHOOSE(PassFail,'PASSED = Leviathan','FAILED = Leviathan' ) ,|
         'Ascii85.EncodeString(Leviathan) ',CHOOSE(PassFail,IconPass,IconFail))
  END  

LengthTestsLabel:  
  !--- Loop test various lengths ---
  LOOP Ln=1 TO SIZE(Leviathan) 
       Result = Ascii85.EncodeString(Leviathan[1 : Ln])
       IF ~Result THEN 
           Message('Encode Failed ' & Ascii85.ErrorMsg & |
                   '||Ln='  & Ln &'|'& Leviathan[1 : Ln]  )
           Break
       END 

       Result = Ascii85.DecodeString(Ascii85.EncodedStr) !, NoWrap85.EncodedLen)
       IF ~Result THEN 
           Message('DecodeString Failed ' & Ascii85.ErrorMsg & |
                   '||Ln='  & Ln &'|'& Leviathan[1 : Ln] &'||'& Ascii85.EncodedStr,'Length Tests' )
           Break
       ELSIF Ascii85.DecodedStr &= NULL THEN
           Message('DecodeString return True but is NULL '  & |
                   '||Ln='  & Ln &'|'& Leviathan[1 : Ln]  )
           Break
       
       ELSIF Ascii85.DecodedStr <> Leviathan[1 : Ln] THEN 
           Message('DecodeString Does NOT Match Encode' & |
                   '||Ln='  & Ln &'|Encoded='& Leviathan[1 : Ln] &'|Decoded=' & Ascii85.DecodedStr |
                   ,,IconFail )
           Break
       END 

  END
  PassFail=CHOOSE(Ln = 1+ SIZE(Leviathan),1,2)
  Message('Leviathan Length tests ' & CHOOSE(PassFail,'PASSED',' Failed ' & Ln) |
          ,'Length Tests',CHOOSE(PassFail,IconPass,IconFail))

!===============================================================
All256Label:     !--- All 256 Characters --   
  NoWrap85.LineLength=0   !No 13,10 to Match my LeviEncoded test
  LOOP A=1 TO 256 ; All256[A]=CHR(A-1) ; END 
  LOOP A=256 TO 1 BY -1

       Result = NoWrap85.EncodeString(All256,256)
       IF ~Result THEN 
           Message('A='& A &' Encode All 256 Failed ' & NoWrap85.ErrorMsg )
           Break
       END
       Result = Ascii85.DecodeString(NoWrap85.EncodedStr)
       IF ~Result THEN 
           Message('A='& A &' DecodeString Failed ' & Ascii85.ErrorMsg )
           Break
       ELSIF Ascii85.DecodedStr &= NULL THEN
           Message('A='& A &' DecodeString return True but is NULL')
           Break
       
       ELSIF Ascii85.DecodedStr <> All256 THEN  
           setclipboard('"' & Ascii85.DecodedStr &'"<13,10>"' & All256 &'"' )
           Message('A='& A &' DecodeString Does NOT Match Encode' & |
                  '||Decode Len=' & Ascii85.DecodedLen &' Size=' & Ascii85.DecodedSize ,,IconFail)
           Break
       END 
       All256 = All256[256] & All256  !Rotate so high bye chnages
  END
  PassFail=CHOOSE(A=0,1,2)
  Message('High ASCII all 256 rotate test ' & CHOOSE(PassFail,'PASSED',' Failed ' & A) |
          ,'All 256',CHOOSE(PassFail,IconPass,IconFail))

!===============================================================
Hi256LenLabel:     !--- High ASCII characters of 256 to 1 byte length
  NoWrap85.LineLength=75   !No 13,10 to Match my LeviEncoded test
  LOOP A=1 TO 256 ; All256[A]=CHR(256-A) ; END  
  !Debug Bang.StringView(All256,'All256 Len Hi Tests')
  LOOP A=256 TO 1 BY -1
       All256=SUB(All256,1,A)                 !Change Length
       Result = NoWrap85.EncodeString(All256,A)
       IF ~Result THEN 
           Message('Len A='& A &' Encode Hi Length Failed ' & NoWrap85.ErrorMsg )
           Break
       ELSE 
           ! IF A=256 OR A<5 THEN Bang.StringView(NoWrap85.EncodedStr,'Len Hi 256: NoWrap85.EncodedStr').           
       END
       Result = Ascii85.DecodeString(NoWrap85.EncodedStr)
       IF ~Result THEN 
           Message('A='& A &' DecodeString Hi 256 Failed ' & Ascii85.ErrorMsg )
           Break
       ELSIF Ascii85.DecodedStr &= NULL THEN
           Message('A='& A &' DecodeString Hi 256 return True but is NULL')
           Break
       
       ELSIF Ascii85.DecodedStr <> All256 THEN  
           setclipboard('"' & Ascii85.DecodedStr &'"<13,10>"' & All256 &'"' )
           Message('A='& A &' DecodeString Hi 256 Len Test Does NOT Match Encode' & |
                  '||Decode Len=' & Ascii85.DecodedLen &' Size=' & Ascii85.DecodedSize ,,IconFail)
           Break
       ELSE
           ! IF A=256 OR A<5 THEN Bang.StringView(Ascii85.DecodedStr,'Len Hi 256: Ascii85.DecodedStr').
       END 
       !NO All256 = All256[256] & All256  !Rotate so high bye chnages
  END
  PassFail=CHOOSE(A=0,1,2)
  Message('High ASCII 256 Length tests ' & CHOOSE(PassFail,'PASSED',' Failed ' & A) |
          ,'Len Hi Ascii',CHOOSE(PassFail,IconPass,IconFail))

!===============================================================
Zero0000Label:  !-- Test 4 Char Zeros compressed to 'z'   
  LOOP A=1 TO 20
       Ascii85.Y_4_Spaces=FALSE     !Reset to Adobe compat without 'y'
       EXECUTE A
           All256=ALL(CHR(0),256)
           All256=ALL('aaaa<0,0,0,0>',256)             !Test 2
           All256=ALL('<0,0,0,0>aaaa',256)
           All256=ALL('<0,0,0>aaaa',256)               !#4 has 3 x 00
           All256=ALL('<0,0,0,0,0>aaaa',256)           !#5 has 5 x 00
           All256=ALL('<81h,82,83h,84h,0,0,0,0>',256)
           All256=ALL('<0,0,0,0,81h,82,83h,84h>',256)
           All256='<9Eh,7Dh,5Ah,23h,FFh,94h,4Ah,82h>' & |   !#8  Spaces----
                    ALL(' {16}<25h,C8h,02h,1Ch>',256)       !    16 Spaces -----    w/o y
           Ascii85.Y_4_Spaces=TRUE                          !#9 Spaces----yyyy----  with y                  
           All256='<A1h,34h,CCh,15h,72h,DBh,9Dh,76h,28h>' & ALL(CHR(0),256) ! Test End
       ELSE   
           BREAK 
       END
       
       Result = Ascii85.EncodeString(All256,256)
       IF ~Result THEN 
           Message('Zero Test #'& A &' Encode FAILED ' & Ascii85.ErrorMsg,,IconFail )
           Break
       ELSE 
           IF false THEN  !Worked TRUE to view encoded to see zzzzzzz yyyy
              SETCLIPBOARD('Len=' & Ascii85.EncodedLen &' Size='& Ascii85.EncodedSize &|
                          '<13,10>'& Ascii85.EncodedStr) 
              Message(CLIPBOARD(),'View Encode Zero #' & A)
           END 
       END

       Result = Ascii85.DecodeString(Ascii85.EncodedStr)
       IF ~Result THEN 
           Message('Zero Test #'& A &' DecodeString Failed ' & Ascii85.ErrorMsg,,ICON:Cross )
           Break
       
       ELSIF Ascii85.DecodedStr <> All256 THEN  
           setclipboard('"' & All256 &'"<13,10>"' & Ascii85.DecodedStr &'"<13,10>' )
!  Bang.StringView(All256,'Failed All256')
!  Bang.StringView(Ascii85.DecodedStr,'Failed Ascii85.DecodedStr')
           Message('FAILED Zero Test #'& A &' DecodeString Does NOT Match Encode' & |
                  '||Decode Len=' & Ascii85.DecodedLen &' Size=' & Ascii85.DecodedSize ,|
                  'Zero Test ' & A, IconFail)
           Break
       END 
  END
  
  !--- Web Example Ruby
  IF ~NoWrap85.EncodeString('Ruby') |
  OR NoWrap85.EncodedStr <> '<<~;KZGo~>' THEN 
     Message('Ruby Encode FAILED') 
  END 

  IF ~NoWrap85.DecodeString('<<~;KZGo~>') |
  OR NoWrap85.DecodedStr <> 'Ruby' THEN 
     Message('Ruby Decode FAILED') 
  END 

  DO FileTestRtn
  DO WrapCheckRtn
!------------------------------  
WrapCheckRtn ROUTINE 
    !Verify line wrapping at 75. Can have a 74 line if "~>" would push it to 76
    !I think I would rather have a 76 byte line than the ~> on its own
    LOOP A=56 TO SIZE(LeviDOTs)
        IF NOT ( INRANGE(A,56,59) OR INRANGE(A,56+59,120) ) THEN CYCLE. 
        Result = Ascii85.EncodeString(LeviDOTs[1 : A],A)
        SetClipboard('A=' & A & ' len=' & Ascii85.EncodedLen  & '<13,10><13,10>' & LeviDOTs[1 : A] &'<13,10><13,10>' & Ascii85.EncodedStr )
        IF 2=Message(Clipboard() &'<13,10><13,10>' & ALL('1234567890',75) &'  75' , |
                'Wrap Check ' & Ascii85.LineLength ,,|
                'Continue|Stop',,MSGMODE:FIXEDFONT + MSGMODE:CANCOPY ) THEN BREAK.
    END         
    EXIT 
!------------------------------    
FileTestRtn ROUTINE !Test if a Bug file can be Encoded and Decoded 
    DATA
SSC  SystemStringClass
Time1 LONG  
Time2 LONG
YTest BYTE 
YCaption PSTRING(20) 
File85  CbAscii85Class
    CODE     
    !IF SSC.FromFile('BigBangTheory.clw') THEN  !source text file will have many 4 spaces to compress
    IF SSC.FromFile('ClaRun.DLL') THEN          !This has 54 spaces that are in 4's 
       Message('FromFile ClaRun.DLL Failed ')
       EXIT 
    END        
    IF Message('ClaRun.DLL file loaded Length ' & SSC.Length() &|
            '||This will make 2 passes, second tests "Y 4 Spaces"' & |
            '||Click to Encode, it takes 3 seconds', |
            'File Test',,'Encode 3 Seconds|Halt') =2 THEN HALT().

    LOOP YTest=0 TO 1
        !File85.LineLength=0
        File85.Y_4_Spaces = YTest
        YCaption=CHOOSE(YTest=0,'',' - Y 4 Spaces')
        Time1=CLOCK()
        Result = File85.EncodeString(SSC.GetStringRef()) !Has 42,732 <00,00,00,00>
        Time2=CLOCK()
           IF ~Result THEN 
               Message('File Encode Failed ' & File85.ErrorMsg,'File Test' & YCaption,IconFail )
               EXIT 
           END     
        IF Message((Time2-Time1)/100 & ' seconds to encode' & YCaption & ' {50}' & |
                '||File loaded Bytes<9>=' & SSC.Length() & |
                '||Encoded Length<9>=' & File85.EncodedLen & |
                '   Size=' & File85.EncodedSize & |
                '||Extra=' & File85.EncodedSize-File85.EncodedLen , |
                'Encode ClaRun.DLL' & YCaption,,'Decode 1 Second|Halt') =2 THEN HALT.

        Time1=CLOCK()
        Result = File85.DecodeString(File85.EncodedStr) 
        Time2=CLOCK()
           IF ~Result THEN 
               Message('File DecodeString Failed ' & File85.ErrorMsg,'File Tests' & YCaption,IconFail )
               
           ELSIF File85.DecodedStr &= NULL THEN
               Message('DecodeString return True but is NULL ','File Tests' & YCaption,IconFail )
           
           ELSIF File85.DecodedStr <> SSC.GetString() THEN 
               Message((Time2-Time1)/100 & ' seconds to decode' & YCaption & ' {50}' & |
                       '||File DecodeString Does NOT Match Encode' & |
                       '||File Lengfth='  & SSC.Length() &'|Decoded length=' & File85.DecodedLen |
                       ,'Decode ClaRun.DLL' & YCaption,IconFail )

           ELSE 
               IF Message((Time2-Time1)/100 & ' seconds to decode' & YCaption & ' {50}' & |
                       '||File DecodeString PASSED' & |
                       '||Input File Length<9>='  & SSC.Length() &|
                       '|Decoded length<9>=' & File85.DecodedLen, |
                       'Decode ClaRun.DLL' & YCaption,IconPass , |
                       CHOOSE(YTest=0,'Encode Y 4 Spaces|Halt','Close|Halt') ) =2 THEN HALT.
               
           END 
       END    !Loop YTest
    EXIT     

!---------------------------------------------
UlongTestRtn ROUTINE !Confirms ULong on Left-side = Longs on Right-side
    DATA
L LONG
U ULONG
    CODE
    L=2000000000
    U=L*2 + 13    !Overflows Long to go Negative, Confirms works
    Message(' {50}|Long<9>=' & L & '|L*2+13<9>=' & L*2+13 &'||ULong<9>=' & U) 
    EXIT
!---------------------------------------------    

ReadMeCodeRtn ROUTINE

  IF ~Ascii85.DecodeString(LeviEncoded)  THEN 
      Message('.DecodeString(LeviEncoded)  Failed Error=' & Ascii85.ErrorMsg ) 
  ELSE 
     SETCLIPBOARD(Ascii85.DecodedStr)
     Message('DecodeString()||' & Ascii85.DecodedStr,'Ascii85')
  END   

  IF ~Ascii85.EncodeString(Leviathan)  THEN 
      Message('.EncodeString(Leviathan)  Failed Error=' & Ascii85.ErrorMsg ) 
  ELSE 
     SETCLIPBOARD(Ascii85.EncodedStr)
     Message('EncodeString()||' & Ascii85.EncodedStr,'Ascii85')
  END   
  
  RETURN 