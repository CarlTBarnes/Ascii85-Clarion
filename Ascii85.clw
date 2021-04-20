!Test CbAscii85Class 
  PROGRAM   

    INCLUDE('CbAscii85.INC'),ONCE
Ascii85  CbAscii85Class   
NoWrap85 CbAscii85Class   
  MAP
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
Result BOOL
Ln     LONG   
  CODE
  !DO ReadMeCodeRtn
  !--- Decode Test ---
  Result = Ascii85.DecodeString(LeviEncoded) 
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
  
  !--- Loop test various lengths ---
  LOOP Ln=1 TO SIZE(Leviathan) 
       Result = NoWrap85.EncodeString(Leviathan[1 : Ln])
       IF ~Result THEN 
           Message('Encode Failed ' & NoWrap85.ErrorMsg & |
                   '||Ln='  & Ln &'|'& Leviathan[1 : Ln]  )
           Break
       END 
       Result = Ascii85.DecodeString(NoWrap85.EncodedStr) !, NoWrap85.EncodedLen)
       IF ~Result THEN 
           Message('DecodeString Failed ' & Ascii85.ErrorMsg & |
                   '||Ln='  & Ln &'|'& Leviathan[1 : Ln]  )
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
  IF Ln = 1+ SIZE(Leviathan) THEN 
     Message('Length tests all passed')
  END 
  
  !Web Example
  IF ~NoWrap85.EncodeString('Ruby') |
  OR NoWrap85.EncodedStr <> '<<~;KZGo~>' THEN 
     Message('Ruby Encode Failed') 
  END 

  IF ~NoWrap85.DecodeString('<<~;KZGo~>') |
  OR NoWrap85.DecodedStr <> 'Ruby' THEN 
     Message('Ruby Decode Failed') 
  END 

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