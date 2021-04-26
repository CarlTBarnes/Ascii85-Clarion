                    MEMBER()
!--------------------------
! CbAscii85Class by Carl Barnes (c) April 2021 release under MIT License
!--------------------------
    INCLUDE('CbAscii85.INC'),ONCE
    MAP
    END

!_asciiOffset EQUATE(33)   !Val('!') which is first encode char
Pow85Grp     GROUP
    LONG(85*85*85*85)
    LONG(85*85*85)
    LONG(85*85)
    LONG(85)
    LONG(1)
             END
pow85 LONG,DIM(5),OVER(Pow85Grp) !private uint[] pow85 = { 85*85*85*85, 85*85*85, 85*85, 85, 1 };
!----------------------------------------
CbAscii85Class.Construct        PROCEDURE()
!----------------------------------------
    CODE 
    SELF.PrefixMark = '<<~' 
    SELF.SuffixMark = '~>' 
    SELF.LineLength = 75 
    SELF.EnforceMarks = true
    RETURN

!---------------------------------------
CbAscii85Class.Destruct PROCEDURE()
!---------------------------------------
    CODE
    SELF.Kill()
    RETURN
        
!-----------------------------------
CbAscii85Class.Init PROCEDURE(<USHORT LineLength>,<BOOL EnforceMarks>,<STRING PrefixMark>,<STRING SuffixMark>)
!-----------------------------------
    CODE
    IF ~OMITTED(LineLength)   THEN SELF.LineLength=LineLength.
    IF ~OMITTED(EnforceMarks) THEN SELF.EnforceMarks=EnforceMarks.
    IF ~OMITTED(PrefixMark)   THEN SELF.PrefixMark=CLIP(PrefixMark). !FYI: PString=String
    IF ~OMITTED(SuffixMark)   THEN SELF.SuffixMark=CLIP(SuffixMark). !ditto
    RETURN

!-----------------------------------
CbAscii85Class.Kill     PROCEDURE(BOOL KillDecode=1, BOOL KillEncode=1)
!-----------------------------------
    CODE
    IF KillDecode THEN
       DISPOSE(SELF.DecodedStr)
       SELF.DecodedSize = 0
       SELF.DecodedLen = 0
    END
    IF KillEncode THEN
       DISPOSE(SELF.EncodedStr)
       SELF.EncodedSize = 0
       SELF.EncodedLen = 0
    END
    RETURN

!-----------------------------------
CbAscii85Class.DecodeString  PROCEDURE(STRING s85)
    CODE
    RETURN SELF.DecodeString(s85) 
!-----------------------------------
CbAscii85Class.DecodeString  PROCEDURE(*STRING s85)
!-----------------------------------
Len_s85   LONG,AUTO
S1   LONG,AUTO
S2   LONG,AUTO
SX   LONG,AUTO
count LONG,AUTO    
cb LONG,AUTO !04/24 faster than BYTE
TupLong LONG,AUTO    !04/24 new calc method
Zeros LONG 
    CODE   
    CLEAR(SELF.ErrorMsg) 
    SELF.Kill(1,0)
    Len_s85=LEN(CLIP(s85)) 
    LOOP While Len_s85   !Strip White space off the end so can find ~>
        CASE VAL(s85[Len_s85])
        OF 9 TO 13 OROF 32 OROF 0 
           Len_s85 -= 1
        ELSE 
            BREAK
        END
    END
    S1=1 ; S2=Len_s85
    !-- strip prefix <~ and suffix ~> if present --
    IF  SELF._LenPrefix AND Len_s85 >= SELF._LenPrefix |
    AND SELF.PrefixMark = s85[1 : SELF._LenPrefix]     THEN
        S1 += SELF._LenPrefix      !Start loop after <~ prefix
    ELSIF SELF.EnforceMarks THEN
        DO MarksErrorRtn
    END
    IF  SELF._LenSuffix AND Len_s85 >= SELF._LenPrefix+SELF._LenSuffix |
    AND SELF.SuffixMark = s85[Len_s85 - SELF._LenSuffix+1 : Len_s85]   THEN
        S2 -= SELF._LenSuffix      !End loop before ~> suffix
    ELSIF SELF.EnforceMarks THEN
        DO MarksErrorRtn
    END
    IF Len_s85 < 1 OR S1 > S2 THEN
       SELF.ErrorMsg=S2-S1+1 & ' bytes to decode'
       RETURN False
    END
    LOOP SX=S1 TO S2   !Single 'z' decodes as <0,0,0,0> so need to zllocate 4 bytes
        CASE VAL(S85[SX]) 
        OF 122 OROF  121 ; Zeros += 1  !'z' 4 x 00h or 'y' is 4 x Spaces
        END
    END ! ; IF Zeros THEN message('Zeros=' & Zeros).
    SELF.DecodedSize = (Len_s85 - Zeros) / 5 * 4 + Zeros * 4 + 5
    SELF.DecodedStr &= NEW(STRING(SELF.DecodedSize))
    SELF.DecodedLen = 0

    TupLong=0 ; count=0 ; SELF._tuple=0 
    CLEAR(SELF._decodedBlock[])
    LOOP SX=S1 TO S2      !foreach (char c in s)
        cb=val(S85[Sx])
        CASE cb           !switch (c)
        OF 33 to 117  !of '!' to 'u'     !04/21/21 refactor this code block up here
           count += 1
           if count < 5 then
!04/24              UL = (cb - 33) * pow85[count]   !Calc as ULONG to avoid negative
!04/24              SELF._tuple += UL               !Sum as ULONG
              TupLong = TupLong * 85 + cb - 33      !04/24 new calc method
           else ! count=5
!04/24              SELF._tuple += (cb - 33)        !04/24/21 =5 save * 1 and UL=
              SELF._tuple = TupLong * 85 + cb - 33  !04/24 new calc method
              SELF.DecodeBlock(4)
              count=0
              TupLong=0
           end

        OF 122 !of 'z'
           if ~count then
              SELF._tuple=0 ! CLEAR(SELF._decodedBlock[]) !Set to 0,0,0,0
              SELF.DecodeBlock(4)
           else
              SELF.ErrorMsg='The character "z" is invalid inside an ASCII85 block, found at position ' & SX
              RETURN False
           end

        OF 121 !of 'y'
           IF SELF.Y_4_Spaces AND ~count THEN
              SELF._tuple=20202020h !Set to 4 spaces
              SELF.DecodeBlock(4)
           ELSE
              SELF.ErrorMsg='Bad character "y" at position ' & SX & |
                            CHOOSE(~SELF.Y_4_Spaces,' n/a in Adobe ASCII85',' invalid inside an ASCII85 block')
              RETURN False  !throw new Exception("Bad character '" + c + "' found. ASCII85 only allows characters '!' to 'u'.");
           END

        OF 9 TO 13 OROF 32 OROF 0
           !White space C# was \n \r \t \0 \f \b - odd /b=8 backspace, no 32=space

        ELSE
            SELF.ErrorMsg='Bad character "' & CHOOSE(cb>=33 AND cb<=126,CHR(cb),'('& cb & ')') &'" found at position ' & SX & |
                          '. ASCII85 only allows characters ! to u (33-117).'
            RETURN False  !throw new Exception("Bad character '" + c + "' found. ASCII85 only allows characters '!' to 'u'.");

        END !CASE cb
    END     !LOOP SX

    !-- if we have some bytes left over at the end --
    IF count >= 2 THEN
!04/24       SELF._tuple += pow85[count] 
       SELF._tuple = TupLong * pow85[count] + pow85[count]  !04/25
       SELF.DecodeBlock(count-1)
    ELSIF count = 1 THEN
       SELF.ErrorMsg='The last block of ASCII85 data cannot be a single byte.'
       RETURN False
    END
    RETURN True

MarksErrorRtn ROUTINE
     SELF.ErrorMsg='ASCII85 encoded data should begin with "' & |
                    SELF.PrefixMark & '" and end with "' & SELF.SuffixMark &'"'
     RETURN False

!==========================================
CbAscii85Class.DecodeBlock PROCEDURE(BYTE bytes)
i BYTE,AUTO 
    CODE 
    LOOP i=1 TO bytes  !        for (int i = 0; i < bytes; i++)
!         _decodedBlock[i] = (byte)(_tuple >> 24 - (i * 8));   ! >> Right Shift
!         SELF._decodedBlock[i] = BSHIFT(SELF._tuple, -24 + (i-1) * 8) 
         SELF._decodedBlock[i] = SELF._tupByte[5-i]
         SELF.DecodedLen += 1
         SELF.DecodedStr[ SELF.DecodedLen ] = CHR(SELF._decodedBlock[i] )
    END
!04/24    SELF._tuple=0  4/24 no longer used for accume
    RETURN    

!===========================================================================
CbAscii85Class.EncodeString  PROCEDURE(STRING ba, LONG EncodeLength=0)!,BOOL
    CODE 
    RETURN SELF.EncodeString(ba,EncodeLength)
!-----------------------------------
CbAscii85Class.EncodeString  PROCEDURE(*STRING ba, LONG Len_Data=0)!,BOOL
!-----------------------------------
countDown LONG,AUTO
BX LONG,AUTO 
    CODE 
    CLEAR(SELF.ErrorMsg) 
    SELF.Kill(0,1)
    IF Len_Data=0 THEN Len_Data=LEN(CLIP(ba)).
    IF Len_Data < 1 THEN 
       SELF.ErrorMsg=Len_Data & ' bytes to encode'
       RETURN False    
    END
    SELF.EncodedSize = Len_Data / 4 * 5 + 5 + SELF._LenPrefix + SELF._LenSuffix
    IF SELF.LineLength THEN  
       SELF.EncodedSize += 2 * ( 2 + SELF.EncodedSize / SELF.LineLength) 
    END 
    SELF.EncodedStr &= NEW(STRING(SELF.EncodedSize))
    SELF.EncodedLen = 0
    SELF._linePos = 0
    SELF._tuple = 0
    countDown=4

    IF SELF.EnforceMarks AND SELF._LenPrefix THEN
       SELF.AppendString(SELF.PrefixMark) 
    END

    LOOP bx=1 TO Len_Data !foreach (byte b in ba)
        SELF._tupByte[countDown] = VAL(ba[bx])
        if countDown = 1 then
           if ~SELF._tuple then
              SELF.AppendChar(122)     !('z') encode 4 x 00h
           elsif ~SELF.Y_4_Spaces then
              SELF.EncodeBlock(5)      !n/a 'y' encode text w/o checking for spaces
           elsif SELF._tuple=20202020h then
              SELF.AppendChar(121)     !('y') encode 4 x spaces
           else
              SELF.EncodeBlock(5)      !('y') allowed encode text
           end
           SELF._tuple = 0
           countDown=4
        else
           countDown -= 1
        end 
    END !Loop bx 
    !-- if we have some bytes left over at the end --
    if countDown < 4 then  
        SELF.EncodeBlock(5-countDown) !(count + 1)
    end 

    IF SELF.EnforceMarks AND SELF._LenSuffix THEN
       SELF.AppendString(SELF.SuffixMark) 
    END 
    RETURN true 
  
!-----------------------------------------    
CbAscii85Class.EncodeBlock PROCEDURE(LONG count)
i LONG,AUTO
Encode5 BYTE,DIM(5),AUTO
    CODE
!    LOOP i = 5 TO 1 BY -1       ! for (int i = _encodedBlock.Length - 1; i >= 0; i--)
!        SELF._encodedBlock[i] = (SELF._tuple % 85) + _asciiOffset
!        SELF._tuple /= 85
!    END    
!---
    Encode5[5] = SELF._tuple   % 85 + 33 ; SELF._tuple /= 85
    Encode5[4] = SELF._tupLong % 85 + 33 ; SELF._tupLong /= 85
    Encode5[3] = SELF._tupLong % 85 + 33 ; SELF._tupLong /= 85
    Encode5[2] = SELF._tupLong % 85 + 33 ; SELF._tupLong /= 85
    Encode5[1] = SELF._tupLong % 85 + 33 ! no need  SELF._tupLong /= 85
    LOOP i=1 TO count
        SELF.AppendChar(Encode5[i])
    END
    RETURN
!-------------------------------------------------
CbAscii85Class.AppendString PROCEDURE(string s) 
    CODE
    !This is ONLY used for prefix / suffix marks
    !Original code worked this way that AppendString checked length before
!04/21/21 Do Not line wrap and have ~> on a line by itself where it can be "lost" instead have line +2 too long
!    IF SELF.LineLength > 0 AND SELF._linePos + SIZE(s) > SELF.LineLength THEN 
!       SELF._linePos = SIZE(s)
!       SELF.EncodedLen += 1 ; SELF.EncodedStr[SELF.EncodedLen] = '<13>'
!       SELF.EncodedLen += 1 ; SELF.EncodedStr[SELF.EncodedLen] = '<10>'
!    ELSE
        SELF._linePos += SIZE(s)
!    END
    SELF.EncodedStr[SELF.EncodedLen+1 : SELF.EncodedLen+SIZE(s)]=s 
    SELF.EncodedLen += SIZE(s)
    RETURN 

!-------------------------------------------------
CbAscii85Class.AppendChar PROCEDURE(BYTE Chr1)
    CODE 
!?    ASSERT(SELF.EncodedLen+3 <= SELF.EncodedSize,'Append Length='& SELF.EncodedLen &' Size='& SELF.EncodedSize)
    IF SELF._linePos >= SELF.LineLength AND SELF.LineLength THEN 
       SELF._linePos = 0
       SELF.EncodedLen += 1 ; SELF.EncodedStr[SELF.EncodedLen] = '<13>'
       SELF.EncodedLen += 1 ; SELF.EncodedStr[SELF.EncodedLen] = '<10>'
    END 
    SELF.EncodedLen += 1 
    SELF.EncodedStr[SELF.EncodedLen] = CHR(Chr1)  !sb.Append(c)
    SELF._linePos += 1
    RETURN