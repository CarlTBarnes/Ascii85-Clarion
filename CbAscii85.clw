                    MEMBER()
!--------------------------
! CbAscii85Class by Carl Barnes (c) April 2021 release under MIT License
!--------------------------
    INCLUDE('CbAscii85.INC'),ONCE
    MAP
    END

_asciiOffset EQUATE(33)   !private const int _asciiOffset = 33;
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
    IF ~OMITTED(PrefixMark)   THEN SELF.PrefixMark=PrefixMark.
    IF ~OMITTED(SuffixMark)   THEN SELF.SuffixMark=SuffixMark.
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
Len_Prfx  BYTE,AUTO
Len_Sufx  BYTE,AUTO
count LONG,AUTO    
cb BYTE,AUTO
UL ULONG,AUTO
Zeros LONG 
    CODE   
    CLEAR(SELF.ErrorMsg) 
    SELF.Kill(1,0)
    Len_s85=LEN(CLIP(s85)) 
    LOOP While Len_s85   !Strip White space off the end so can find ~>
        CASE VAL(s85[Len_s85])
        OF 10 OROF 13 OROF 9 OROF 0 OROF 12 OROF 8  OROF 11 OROF 32
           Len_s85 -= 1
        ELSE 
            BREAK
        END
    END
    S1=1 ; S2=Len_s85
    Len_Prfx=LEN(SELF.PrefixMark)
    Len_Sufx=LEN(SELF.SuffixMark)
    !-- strip prefix <~ and suffix ~> if present --
    IF Len_Prfx AND Len_s85 >= Len_Prfx |
    AND s85[1 : Len_Prfx]=SELF.PrefixMark THEN  !if (s.StartsWith(PrefixMark))
        S1 += Len_Prfx                          ! s = s.Substring(PrefixMark.Length);
    ELSIF SELF.EnforceMarks THEN 
        DO MarksErrorRtn
    END
    IF Len_Sufx AND Len_s85 >= Len_Prfx+Len_Sufx |
    AND s85[Len_s85 - Len_Sufx+1 : Len_s85]=SELF.SuffixMark THEN     
        S2 -= Len_Sufx                          !s = s.Substring(0, s.Length - SuffixMark.Length);
    ELSIF SELF.EnforceMarks THEN 
        DO MarksErrorRtn
    END
    IF Len_s85 < 1 OR S1 > S2 THEN
       SELF.ErrorMsg=S2-S1+1 & ' bytes to decode'
       RETURN False
    END 
    
    LOOP SX=S1 TO S2   !Single 'z' decodes as <0,0,0,0> so need to zllocate 4 bytes
        IF val(S85[Sx]) = 122 THEN Zeros += 1.  !122='z'
    END ! ; IF Zeros THEN message('Zeros=' & Zeros).
    SELF.DecodedSize = (Len_s85 - Zeros) / 5 * 4 + Zeros * 4 + 5
    SELF.DecodedStr &= NEW(STRING(SELF.DecodedSize))
    SELF.DecodedLen = 0

    SELF._tuple=0 ; count=0
    CLEAR(SELF._decodedBlock[])
    LOOP SX=S1 TO S2      !foreach (char c in s)
        cb=val(S85[Sx])
        CASE cb           !switch (c)
            OF 33 to 117  !of '!' to 'u'     !04/21/21 refactor this code block up here
               count += 1
               UL = (cb - _asciiOffset) * pow85[count]   !Calc as ULONG to avoid negative
               SELF._tuple += UL                         !Sum as ULONG
               if count = 5 then
                  SELF.DecodeBlock(4)
                  SELF._tuple=0
                  count=0
               end

            OF 122 !of 'z'
               if count <> 0 then
                  SELF.ErrorMsg='The character "z" is invalid inside an ASCII85 block, found at position ' & SX
                  RETURN False
               end
               CLEAR(SELF._decodedBlock[]) !Set to 0,0,0,0
               SELF.DecodeBlock(4)

              ! '\n'  '\r'   '\t'   '\0'    '\f'   '\b'
            OF   10 OROF 13 OROF 9 OROF 0 OROF 12 OROF 8
            OROF 11 OROF 32     !Was missing /v 11 and Space. C Library isspace() ' '	 /n /t /v /f /r

            ELSE
                SELF.ErrorMsg='Bad character "' & CHOOSE(cb>=33 AND cb<=126,CHR(cb),'('& cb & ')') &'" found at position ' & SX & |
                              '. ASCII85 only allows characters ! to u (33-117).'
                RETURN False  !throw new Exception("Bad character '" + c + "' found. ASCII85 only allows characters '!' to 'u'.");

        END !CASE cb

!04/21/21 refactor this code block and move first into CASE OF '!' TO 'u'
!        if processChar then
!           !_tuple += ((uint)(c - _asciiOffset) * pow85[count]);
!           !count++;                !Zero based pow85[] array so ++ after
!            count += 1              !One  based in Clarion so ++ before
!
!           !Below right side is being calculated as LONG and going negative and WRONG on high ASCII
!           !alternate change, changed Pow85 from LONG to ULONG. Leaving UL here as obvious
!!            SELF._tuple += (cb - _asciiOffset) * pow85[count]   !<- Wrong High ASCII
!            UL = (cb - _asciiOffset) * pow85[count]   !Calc as ULONG
!            SELF._tuple += UL                         !Sum as ULONG
!
!            if count = 5 then           ! count=_encodedBlock.Length)
!                SELF.DecodeBlock(4)     !Appends .DecodedStr
!                SELF._tuple = 0
!                count = 0
!            end !If
!        end ! if (processChar)
    END !LOOP SX=S1 TO S2

    !-- if we have some bytes left over at the end --
    if count <> 0 then
        if count = 1 then 
            SELF.ErrorMsg='The last block of ASCII85 data cannot be a single byte.'
            RETURN False
        end !if (count = 1)
        count -= 1
        SELF._tuple += pow85[count+1]
        SELF.DecodeBlock(count)        !also does ms.WriteByte(_decodedBlock[i]);
    end !if (count <> 0)    

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
         SELF._decodedBlock[i] = BSHIFT(SELF._tuple, -24 + (i-1) * 8) 
         SELF.DecodedLen += 1
         SELF.DecodedStr[ SELF.DecodedLen ] = CHR(SELF._decodedBlock[i] )
    END 
    RETURN    

!===========================================================================
CbAscii85Class.EncodeString  PROCEDURE(STRING ba, LONG EncodeLength=0)!,BOOL
    CODE 
    RETURN SELF.EncodeString(ba,EncodeLength)
!-----------------------------------
CbAscii85Class.EncodeString  PROCEDURE(*STRING ba, LONG Len_Data=0)!,BOOL
!-----------------------------------
Len_Prfx  BYTE,AUTO
Len_Sufx  BYTE,AUTO
count LONG
BX LONG,AUTO
b  BYTE,AUTO 
    CODE 
    CLEAR(SELF.ErrorMsg) 
    SELF.Kill(0,1)
    Len_Prfx=LEN(SELF.PrefixMark)
    Len_Sufx=LEN(SELF.SuffixMark)
    IF Len_Data=0 THEN Len_Data=LEN(CLIP(ba)).
    IF Len_Data < 1 THEN 
       SELF.ErrorMsg=Len_Data & ' bytes to encode'
       RETURN False    
    END
    SELF.EncodedSize = Len_Data / 4 * 5 + 5 + Len_Prfx + Len_Sufx
    IF SELF.LineLength THEN  
       SELF.EncodedSize += 2 * ( 2 + SELF.EncodedSize / SELF.LineLength) 
    END 
    SELF.EncodedStr &= NEW(STRING(SELF.EncodedSize))
    SELF.EncodedLen = 0
    SELF._linePos = 0
    SELF._tuple = 0

    IF SELF.EnforceMarks AND Len_Prfx THEN
       SELF.AppendString(SELF.PrefixMark) 
    END

    LOOP bx=1 TO Len_Data !foreach (byte b in ba)
        b = VAL(ba[bx]) 
        if count >= 4-1 then ! >= _decodedBlock.Length - 1) Every 4th byte zero based
            SELF._tupByte[1] = b  !SELF._tuple = BOR(SELF._tuple,b)     ! _tuple |= b;
            if SELF._tuple = 0 then 
               SELF.AppendChar(122) !('z')
            else
               SELF.EncodeBlock(5)
            end 
            SELF._tuple = 0
            count = 0           
        else 
          !    _tuple   |= (uint) (b << (24 - (count * 8)));
          ! SELF._tuple = BOR(SELF._tuple, BSHIFT(b , (24 - (count * 8))) ) 
            SELF._tupByte[4-count] = b
            count += 1
        end 
    END !Loop bx 

    !-- if we have some bytes left over at the end --
    if count > 0 then
        SELF.EncodeBlock(count + 1)
    end 

    IF SELF.EnforceMarks AND Len_Sufx THEN
       SELF.AppendString(SELF.SuffixMark) 
    END 
    RETURN true 
  
!-----------------------------------------    
CbAscii85Class.EncodeBlock PROCEDURE(BYTE count)
i LONG,AUTO  
    CODE
!    LOOP i = 5 TO 1 BY -1       ! for (int i = _encodedBlock.Length - 1; i >= 0; i--)
!        SELF._encodedBlock[i] = (SELF._tuple % 85) + _asciiOffset
!        SELF._tuple /= 85
!    END    
!---
    SELF._encodedBlock[5] = SELF._tuple   % 85 + 33 ; SELF._tuple /= 85
    SELF._encodedBlock[4] = SELF._tupLong % 85 + 33 ; SELF._tupLong /= 85
    SELF._encodedBlock[3] = SELF._tupLong % 85 + 33 ; SELF._tupLong /= 85
    SELF._encodedBlock[2] = SELF._tupLong % 85 + 33 ; SELF._tupLong /= 85
    SELF._encodedBlock[1] = SELF._tupLong % 85 + 33 ! no need  SELF._tupLong /= 85

    LOOP i=1 TO count           ! for (int i = 0; i < count; i++)
        SELF.AppendChar(SELF._encodedBlock[i])   
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
    IF SELF._linePos >= SELF.LineLength AND SELF.LineLength THEN 
       SELF._linePos = 0
       SELF.EncodedLen += 1 ; SELF.EncodedStr[SELF.EncodedLen] = '<13>'
       SELF.EncodedLen += 1 ; SELF.EncodedStr[SELF.EncodedLen] = '<10>'
    END 
    SELF.EncodedLen += 1 
    SELF.EncodedStr[SELF.EncodedLen] = CHR(Chr1)  !sb.Append(c)
    SELF._linePos += 1
    RETURN