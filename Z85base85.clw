  PROGRAM 
  !The Z85 version of Base 85
  !RFC Document: https://rfc.zeromq.org/spec/32/ 
  !Reference C: https://github.com/zeromq/rfc/blob/master/src/spec_32.c

  !Conversion of C code to Clarion. Main issues was C uses Zero based Arrays.

  !The Decode requires valid Z 85 without Whitespace or it will crash
  !with an out of range subscript.
   
  MAP
Z85_Encode    PROCEDURE(CONST *STRING DataToEncode, LONG LenToEncode=0),*STRING   
Z85_Decode    PROCEDURE(CONST *STRING EncodedData, LONG EncodedLen=0),*STRING   
  END

!    +------+------+------+------+------+------+------+------+
!    | 0x86 | 0x4F | 0xD2 | 0x6F | 0xB5 | 0x59 | 0xF7 | 0x5B |
!    +------+------+------+------+------+------+------+------+
!    SHALL encode as the following 10 characters:
!    +---+---+---+---+---+---+---+---+---+---+
!    | H | e | l | l | o | W | o | r | l | d |
!    +---+---+---+---+---+---+---+---+---+---+
Str STRING(256)
HelloEncode STRING('<86h,04Fh,0D2h,06Fh,0B5h,059h,0F7h,05Bh>')
HelloDecode STRING('HelloWorld') 
test_data_2 STRING( |
        '<08Eh,00Bh,0DDh,069h,076h,028h,0B9h,01Dh>' &|
        '<08Fh,024h,055h,087h,0EEh,095h,0C5h,0B0h>' &|
        '<04Dh,048h,096h,03Fh,079h,025h,098h,077h>' &|
        '<0B4h,09Ch,0D9h,006h,03Ah,0EAh,0D3h,0B7h>' )
test_encoded_2 STRING('JTKVSB%%)wK0E.X)V>+}o?pNmC{{O&4W4b!Ni{{Lh6')
        
EncStr  &STRING
DecStr  &STRING
  CODE 
!  This will crash the reference code.
!  White space is allowed in Z85 but not the reference
!   Str = 'Hello  <13,10> World'  
!   DecStr &= Z85_Decode(Str)  ; return 
  
  EncStr &= Z85_Encode(HelloEncode) 
  Message('Encode test should return "HelloWorld" '& |
            '||Result="' & EncStr &'"' & |
            '||Test ' & CHOOSE(EncStr=HelloDecode,'Worked!','Failed :('),'Z85_Encode')
  DISPOSE(EncStr)
  
  DecStr &= Z85_Decode(HelloDecode)
     Message('Z85_Decode test for ' & HelloDecode & |
             '||Output=' & DecStr & |
             '||Test ' & CHOOSE(DecStr=HelloEncode,'Worked!','Failed :('),'Z85_Decode' )   
  DISPOSE(DecStr)
 
  EncStr &= Z85_Encode(test_data_2)
  IF EncStr = test_encoded_2 THEN 
     Message('Worked Z85_Encode(test_data_2)' & |
             '||In=' & test_data_2 &'||Out='& EncStr,'test_data_2' )
  ELSE      
     Message('Failed Z85_Encode(test_data_2)','test_data_2')
  END
  
  DecStr &= Z85_Decode(test_encoded_2)
  IF DecStr <> test_data_2 THEN Message('Failed Z85_Decode(test_encoded_2)').
  
!======================================================================= 
Z85_Encode    PROCEDURE(CONST *STRING Data, LONG SizeData=0)
encoder STRING('0123456789' & |     !  0 -  9:  0 1 2 3 4 5 6 7 8 9
               'abcdefghij' & |     ! 10 - 19:  a b c d e f g h i j
               'klmnopqrst' & |     ! 20 - 29:  k l m n o p q r s t
               'uvwxyzABCD' & |     ! 30 - 39:  u v w x y z A B C D
               'EFGHIJKLMN' & |     ! 40 - 49:  E F G H I J K L M N
               'OPQRSTUVWX' & |     ! 50 - 59:  O P Q R S T U V W X
               'YZ.-:+=^!/' & |     ! 60 - 69:  Y Z . - : + = ^ ! /
               '*?&<<>()[]{{' & |   ! 70 - 79:  * ? & < > ( ) [ ] {
               '}@%$#'),STATIC      ! 80 - 84:  } @ % $ #          
!Idea: Z85 was made to use to avoid some characters
!      Make a Clarion version that avoids < and { use , and ; also can use |\`~" 
!      This could work in JSlarve Data to Clarion
!      Read https://en.wikipedia.org/wiki/Binary-to-text_encoding  

encoded_size  LONG 
encoded  &STRING  
char_nbr LONG  !uint
byte_nbr LONG  !uint
value    ULONG !uint32_t
divisor  LONG  !uint 
PadSize  BYTE    !Carl Added Padding spaces on end to multiple of 4
    CODE 
    if SizeData=0 then SizeData=len(clip(Data)).
    ! if (SizeData % 4) then return 'error'. !//  Accepts only byte arrays bounded to 4 bytes
    PadSize = SizeData % 4
    IF PadSize THEN PadSize=4-PadSize.
    
    encoded_size = (SizeData + PadSize) * 5 / 4
    encoded &= NEW(STRING(encoded_size))         !char *encoded = malloc (encoded_size + 1);
    LOOP byte_nbr = 1 TO SizeData + PadSize
        if byte_nbr <= SizeData then 
           value = value * 256 + VAL(data[byte_nbr])   !//  Accumulate value in base 256 (binary) 
        else 
           value = value * 256 + 32 !Space Padding
        end
        if (byte_nbr % 4 = 0) then 
            divisor = 85 * 85 * 85 * 85   !//  Output value in base 85
            loop while (divisor) 
                char_nbr += 1            
                encoded[char_nbr] = encoder[1 + value / divisor % 85]
                divisor /= 85 
            end
            value = 0
        end !if
    end !loop
  assert (char_nbr = encoded_size)
    return encoded
!=================================================================
!  --------------------------------------------------------------------------
! Decode an encoded string; size of return will be LEN(EncData) * 4 / 5.
! This REQUIRES the EncData be valid, only the 85 characters. 
! This does not support whitespace (32,13,10,9,11)
Z85_Decode  PROCEDURE(CONST *STRING EncData, LONG EncData_size=0)!,STRING
!Maps base 85 to base 256 - We chop off lower 32 and higher 128 ranges
!This Map is for ZERO based Arrays[] so you must +1 for Clarion 
!For Each Encoder character this is its [VAL()] = Sequence in Encoder 
!So '1' is 2nd (1 in C) in Encoder, which is 31h=49-32=18 so here [18]=1
decoder STRING( |                          ! []   []    
   '< 0 ,44h, 0 ,54h,53h,52h,48h, 0 >'&|   !  1 -  8  !  32 -  39  20h
   '<4Bh,4Ch,46h,41h, 0 ,3Fh,3Eh,45h>'&|   !  9 - 16  !  40 -  47  28h
   '<00h,01h,02h,03h,04h,05h,06h,07h>'&|   ! 17 - 24  !  48 -  55  30h 0123456789
   '<08h,09h,40h, 0 ,49h,42h,4Ah,47h>'&|   ! 25 - 32  !  56 -  63  38h
   '<51h,24h,25h,26h,27h,28h,29h,2Ah>'&|   ! 33 - 40  !  64 -  71  40h
   '<2Bh,2Ch,2Dh,2Eh,2Fh,30h,31h,32h>'&|   ! 41 - 48  !  72 -  79
   '<33h,34h,35h,36h,37h,38h,39h,3Ah>'&|   ! 49 - 56  !  80 -  87
   '<3Bh,3Ch,3Dh,4Dh, 0 ,4Eh,43h, 0 >'&|   ! 57 - 64  !  88 -  95
   '< 0 ,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh,10h>'&|   ! 65 - 72  !  96 - 103
   '<11h,12h,13h,14h,15h,16h,17h,18h>'&|   ! 73 - 80  ! 104 - 111
   '<19h,1Ah,1Bh,1Ch,1Dh,1Eh,1Fh,20h>'&|   ! 81 - 88  ! 112 - 119
   '<21h,22h,23h,4Fh, 0 ,50h, 0 , 0 >'&|   ! 89 - 96  ! 120 - 127
   ''),STATIC
Decoded         &STRING  
decoded_size    LONG  
byte_nbr        LONG  
char_nbr        LONG  
divisor         LONG  
value           ULONG  
    CODE
    !//  Accepts only strings bounded to 5 bytes
    if EncData_size=0 then EncData_size = len(clip(EncData)).
    if EncData_size % 5 then 
       Decoded &= NEW(STRING(40)) 
       Decoded='Length must be mutiple of 5 = ' & EncData_size
       return Decoded
    end
    decoded_size = EncData_size * 4 / 5 
    Decoded &= NEW(STRING(decoded_size))  !  byte *decoded = malloc (decoded_size);
    loop char_nbr = 1 TO EncData_size  !while (char_nbr < strlen (string))
        !//  Accumulate value in base 85 
        value = value * 85 + VAL(decoder[VAL(EncData[char_nbr]) - 32 +1])
        !                    ^^^^ Invalid Base 85 will have Out of Range Subscript ^^^   
        if char_nbr % 5 = 0 then            
            divisor = 256 * 256 * 256  !//  Output value in base 256
            loop while (divisor)
                byte_nbr += 1
                decoded [byte_nbr] = CHR(value / divisor % 256)
                divisor /= 256  
            end !loop 
            value = 0
        end !if
    end !loop
  assert (byte_nbr=decoded_size)
    return decoded

!#############################################################################
    OMIT('**END C Code**')

//  Basic language taken from CZMQ's prelude
typedef unsigned char byte;
#define streq(s1,s2) (!strcmp ((s1), (s2)))

//  Maps base 256 to base 85
static char encoder [85 + 1] = {
    "0123456789" 
    "abcdefghij" 
    "klmnopqrst" 
    "uvwxyzABCD"
    "EFGHIJKLMN" 
    "OPQRSTUVWX" 
    "YZ.-:+=^!/" 
    "*?&<>()[]{" 
    "}@%$#"
};

//  Maps base 85 to base 256
//  We chop off lower 32 and higher 128 ranges
static byte decoder [96] = {
    0x00, 0x44, 0x00, 0x54, 0x53, 0x52, 0x48, 0x00, 
    0x4B, 0x4C, 0x46, 0x41, 0x00, 0x3F, 0x3E, 0x45, 
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 
    0x08, 0x09, 0x40, 0x00, 0x49, 0x42, 0x4A, 0x47, 
    0x51, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 
    0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 
    0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 
    0x3B, 0x3C, 0x3D, 0x4D, 0x00, 0x4E, 0x43, 0x00, 
    0x00, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 
    0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 
    0x21, 0x22, 0x23, 0x4F, 0x00, 0x50, 0x00, 0x00
};

//  --------------------------------------------------------------------------
//  Encode a byte array as a string

char *
Z85_encode (byte *data, size_t size)
{
    //  Accepts only byte arrays bounded to 4 bytes
    if (size % 4)
        return NULL;
    
    size_t encoded_size = size * 5 / 4;
    char *encoded = malloc (encoded_size + 1);
    uint char_nbr = 0;
    uint byte_nbr = 0;
    uint32_t value = 0;
    while (byte_nbr < size) {
        //  Accumulate value in base 256 (binary)
        value = value * 256 + data [byte_nbr++];
        if (byte_nbr % 4 == 0) {
            //  Output value in base 85
            uint divisor = 85 * 85 * 85 * 85;
            while (divisor) {
                encoded [char_nbr++] = encoder [value / divisor % 85];
                divisor /= 85;
            }
            value = 0;
        }
    }
    assert (char_nbr == encoded_size);
    encoded [char_nbr] = 0;
    return encoded;
}

    
//  --------------------------------------------------------------------------
//  Decode an encoded string into a byte array; size of array will be
//  strlen (string) * 4 / 5.

byte *
Z85_decode (char *string)
{
    //  Accepts only strings bounded to 5 bytes
    if (strlen (string) % 5)
        return NULL;
    
    size_t decoded_size = strlen (string) * 4 / 5;
    byte *decoded = malloc (decoded_size);

    uint byte_nbr = 0;
    uint char_nbr = 0;
    uint32_t value = 0;
    while (char_nbr < strlen (string)) {
        //  Accumulate value in base 85
        value = value * 85 + decoder [(byte) string [char_nbr++] - 32];
        if (char_nbr % 5 == 0) {
            //  Output value in base 256
            uint divisor = 256 * 256 * 256;
            while (divisor) {
                decoded [byte_nbr++] = value / divisor % 256;
                divisor /= 256;
            }
            value = 0;
        }
    }
    assert (byte_nbr == decoded_size);
    return decoded;
}
    
    !end of OMIT('**END C Code**')