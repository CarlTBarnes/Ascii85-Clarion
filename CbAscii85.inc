    OMIT('_EndOfInclude_',_IFDef_CbAscii85_)
_IFDef_CbAscii85_  EQUATE(1)
!-----------------------------------------------------------
! CbAscii85Class by Carl Barnes (c) April 2021 release under MIT License
!
! Conversion of C# implementation of ASCII85 encoding. 
! by Jeff Atwood 
! https://github.com/coding-horror/ascii85
! http://www.codinghorror.com/blog/archives/000410.html
!-----------------------------------------------------------
!    INCLUDE('CbAscii85.INC'),ONCE      ! CbAscii85Class1  CLASS(CbAscii85Class).
!Ascii85Cls  CbAscii85Class
!   IF ~Ascii85Cls.DecodeString(My85text) THEN
!       failed see .ErrorMsg
!   ELSE
!       worked see .DecodedStr and .Decodedlen
!   END 
!-----------------------------------------------------------

!----------------- CbAscii85Class -----------------
CbAscii85Class    CLASS,TYPE,MODULE('CbAscii85.CLW'),LINK('CbAscii85.CLW',1),DLL(0)   !,_ABCLinkMode_),DLL(_ABCDllMode_)
!
!Properties
!----------             !Can set these with .Init(...)
LineLength   USHORT     !Default 75    Maximum line length for encoded ASCII85 string before CR,LF;
                        !                set to zero for one unbroken line (no CR,LF).
EnforceMarks bool       !Default TRUE  Add the Prefix and Suffix marks when encoding, and enforce their presence for decoding
PrefixMark   PSTRING(8) !Default "<~"  Prefix mark that identifies an encoded ASCII85 string, traditionally '<~'
SuffixMark   PSTRING(8) !Default "~>"  Suffix mark that identifies an encoded ASCII85 string, traditionally '~>'
Y_4_Spaces   bool       !Default False Like 'z' for Spaces, not Adobe compat, BtoA v4.2

!Methods
!-------------
Init            PROCEDURE(<USHORT LineLength>,<BOOL EnforceMarks>,<STRING PrefixMark>,<STRING SuffixMark>) 
Kill            PROCEDURE(BOOL KillDecode=1, BOOL KillEncode=1)
!---------------------------------------------------------- 
!If DecodeString() returns False then see .ErrorMsg
!If DecodeString() returns True  then .DecodedStr is STRING of .DecodedLen Bytes
DecodeString    PROCEDURE(STRING EncodedString),BOOL  !returns True if worked
DecodeString    PROCEDURE(*STRING EncodedString),BOOL !returns True if worked

DecodedStr          &STRING !Output of DecodeString
DecodedLen          LONG    !Length of DecodedStr w/o padding
DecodedSize         LONG    !String Size is a litte bigger than needed 

!----------------------------------------------------------
EncodeString    PROCEDURE(STRING Data2Encode,  LONG EncodeLength=0),BOOL
EncodeString    PROCEDURE(*STRING Data2Encode, LONG EncodeLength=0),BOOL

EncodedStr          &STRING !Output of EncodeString
EncodedLen          LONG    !Length of EncodedStr w/o padding
EncodedSize         LONG    !String Size is a litte bigger  

!-----------------------------------------------------------------
ErrorMsg      STRING(128)   !Error set when return False/Failed


!Properties Internal
!-------------------
_decodedBlock   BYTE,DIM(4),PROTECTED
_tuple          ULONG,PROTECTED         !private uint _tuple = 0;
_tupLong        LONG,OVER(_tuple),PROTECTED         !faster
_tupByte        BYTE,DIM(4),OVER(_tuple),PROTECTED  !be faster like Geoff
_linePos        LONG,PROTECTED
_LenPrefix      BYTE,OVER(PrefixMark)   !FYI: Byte is Over PString[0] is the LEN()
_LenSuffix      BYTE,OVER(SuffixMark)   !FYI: Byte is Over PString[0] is the LEN()

!Methods Internal
!----------------
Construct               PROCEDURE()
Destruct                PROCEDURE(),VIRTUAL
DecodeBlock             PROCEDURE(BYTE bytes),PROTECTED
EncodeBlock             PROCEDURE(LONG count),PROTECTED 
AppendString            PROCEDURE(string String2Append),PROTECTED 
AppendChar              PROCEDURE(BYTE OneChar2Append),PROTECTED 
                    END

    _EndOfInclude_

