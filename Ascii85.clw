!Test CbAscii85Class 
  PROGRAM   

    INCLUDE('CbAscii85.INC'),ONCE
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
  CODE
  SYSTEM{PROP:MsgModeDefault}=MSGMODE:CANCOPY
  !GOTO Zero0000Label:
  !GOTO LengthTestsLabel:
  !GOTO All256Label:
  !DO ReadMeCodeRtn
  !--- Decode Test ---
  Result = Ascii85.DecodeString(LeviEncoded & |
                               ' <13,10,9,11,12,32,0>')  !Trailing whitespace
  IF ~Result THEN 
      Message('.DecodeString(LeviEncoded)  Failed Error=' & Ascii85.ErrorMsg ) 
  ELSIF Ascii85.DecodedStr &= NULL THEN 
      Message('Bug .DecodeString(LeviEncoded) returned True but .DecodedStr is NULL')
  ELSE 
     SETCLIPBOARD(Ascii85.DecodedStr)
     Message('DecodeString() Result=' & Result & ' Error=' & Ascii85.ErrorMsg & |
         '||DecodeString ' & |
         '|Size=' & Ascii85.DecodedSize & |
         '|Len='  & Ascii85.DecodedLen & | 
         '|Str='  & Ascii85.DecodedStr & |
         '||' & CHOOSE(Ascii85.DecodedStr=Leviathan,'Worked =.Leviathan Test','Failed =.Leviathan Test' ) ,|
         'Ascii85.DecodeString(LeviEncoded) ')
  END  

  !--- Decode WhiteSpace Test ---
  Result = Ascii85.DecodeString(WhiteSpace) 
  IF ~Result THEN 
      Message('.DecodeString(WhiteSpace)  Failed Error=' & Ascii85.ErrorMsg ) 
  ELSIF Ascii85.DecodedStr &= NULL THEN 
      Message('Bug .DecodeString(WhiteSpace) returned True but .DecodedStr is NULL')
  ELSE 
     SETCLIPBOARD(Ascii85.DecodedStr)
     Message('DecodeString() Result=' & Result & ' Error=' & Ascii85.ErrorMsg & |
         '||DecodeString ' & |
         '|Size=' & Ascii85.DecodedSize & |
         '|Len='  & Ascii85.DecodedLen & | 
         '|Str='  & Ascii85.DecodedStr & |
         '||' & CHOOSE(Ascii85.DecodedStr=Leviathan,'Worked =.Leviathan Test','Failed =.Leviathan Test' ) ,|
         'Ascii85.DecodeString(WhiteSpace) ')
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
     Message('EncodeString() Result=' & Result & ' Error=' & Ascii85.ErrorMsg & |
         '||EncodeString' & |
         '|Size=' & Ascii85.EncodedSize & |
         '|Len='  & Ascii85.EncodedLen & | 
         '|Str='  & Ascii85.EncodedStr & |
         '||' & CHOOSE(NoWrap85.EncodedStr=LeviEncoded,'Worked =.LeviEncoded Test','Failed =.LeviEncoded Test' ) ,|
         'Ascii85.EncodeString(Leviathan) ')
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
                   '||Ln='  & Ln &'|Encoded='& Leviathan[1 : Ln] &'|Decoded=' & Ascii85.DecodedStr  )
           Break
       END 

  END
  Message('Leviathan Length tests ' & CHOOSE(Ln = 1+ SIZE(Leviathan),'PASSED',' Failed ' & Ln))

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
                  '||Decode Len=' & Ascii85.DecodedLen &' Size=' & Ascii85.DecodedSize )
           Break
       END 
       All256 = All256[256] & All256  !Rotate so high bye chnages
  END
  Message('High ASCII all 256 test ' & CHOOSE(A=0,'PASSED',' Failed? ' & A ))

!===============================================================
Zero0000Label:  !-- Test 4 Char Zeros compressed to 'z'   
  LOOP A=1 TO 20
       EXECUTE A
           All256=ALL(CHR(0),256)
           All256=ALL('aaaa<0,0,0,0>',256)             !Test 2
           All256=ALL('<0,0,0,0>aaaa',256)
           All256=ALL('<0,0,0>aaaa',256)               !#4 has 3 x 00
           All256=ALL('<0,0,0,0,0>aaaa',256)           !#5 has 5 x 00
           All256=ALL('<81h,82,83h,84h,0,0,0,0>',256)
           All256=ALL('<0,0,0,0,81h,82,83h,84h>',256) 
           All256='<A1h,34h,CCh,15h,72h,DBh,9Dh,76h,28h>' & ALL(CHR(0),256) ! Test End
       ELSE   
           BREAK 
       END
       
       Result = Ascii85.EncodeString(All256,256)
       IF ~Result THEN 
           Message('Zero Test #'& A &' Encode FAILED ' & Ascii85.ErrorMsg,,ICON:Cross )
           Break
       ELSE 
         !Worked view encoed to see zzzzzzz 
!         SETCLIPBOARD('Len=' & Ascii85.EncodedLen &' Size='& Ascii85.EncodedSize &|
!                      '<13,10>'& Ascii85.EncodedStr) 
!         Message(CLIPBOARD(),'View Encode Zero #' & A)       
       END
       Result = Ascii85.DecodeString(Ascii85.EncodedStr)
       IF ~Result THEN 
           Message('Zero Test #'& A &' DecodeString Failed ' & Ascii85.ErrorMsg,,ICON:Cross )
           Break
       
       ELSIF Ascii85.DecodedStr <> All256 THEN  
           !setclipboard('"' & Ascii85.DecodedStr &'"<13,10>"' & All256 &'"' )
           Message('FAILED Zero Test #'& A &' DecodeString Does NOT Match Encode' & |
                  '||Decode Len=' & Ascii85.DecodedLen &' Size=' & Ascii85.DecodedSize ,|
                  'Zero Test ' & A, ICON:Cross)
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

  DO WrapCheckRtn
  
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