# Ascii85-Clarion - Ascii85 Clarion Class 

ASCII 85 is binary-to-text encoding similar to Base 64 but is more efficient using 5 bytes to encode 4.
 Read more about in the [Wikipedia ASCII 85 article](https://en.wikipedia.org/wiki/Ascii85).

For discussion of this class see the [Clarion Hub post "Converting ASCII85 to Binary"](https://clarionhub.com/t/converting-ascii85-to-binary/4047?u=carlbarnes).

Jeff Atwood of Coding Horror published a C# ASCII 85 class on Github that I converted to Clarion.
 I tried to make as few changes as possile to the code ... at first
 ... but then changed the code to work better in Clarion. 
 One thing I decided to change was Jeff's style of `"IF Invalid THEN Report Error ELSE process data"`. 
 I flipped that to `"IF Valid THEN process data ELSE Report Error"`. 
 Is that cleaner code? I'd say yes, as long as the IF logic is just as understandable.
 
https://github.com/coding-horror/ascii85

The included Ascii85.clw project tests the class several ways and shows examples of usage.
 The FileTo85 example shows using System String Class to read a file and encode, write it, decode and write that.
 
The St_85test example includes Geoff Robinson's String Theory ASCII 85 class and code to test it.

The orignal class returned a string. In my class .DecodeString() and .EncodeString() methods return True/False.
 The actual STRING is in .DecodedStr or .EncodedStr.
  If the functions return False these strings will be NULL and crash if you try to use them.

```clarion
CbAscii85Class    CLASS,TYPE
LineLength   USHORT      !Default 75    Maximum line length for encoded ASCII85 string before CR,LF;
                         !                set to zero for one unbroken line (no CR,LF).
EnforceMarks BOOL        !Default TRUE  Add the Prefix and Suffix marks when encoding, and enforce their presence for decoding
PrefixMark   PSTRING(8)  !Default "<~"  Prefix mark that identifies an encoded ASCII85 string, traditionally '<~'
SuffixMark   PSTRING(8)  !Default "~>"  Suffix mark that identifies an encoded ASCII85 string, traditionally '~>'
Y_4_Spaces   BOOL        !Default False Like 'z' for Spaces, not Adobe compat, BtoA v4.2
ErrorMsg     STRING(128) !Error message set when DecodeString() return False/Failed

Init         PROCEDURE(<USHORT LineLength>,<BOOL EnforceMarks>,<STRING PrefixMark>,<STRING SuffixMark>) 
Kill         PROCEDURE(BOOL KillDecode=1, BOOL KillEncode=1)
!---------------------------------------------------------- 
DecodeString    PROCEDURE(STRING EncodedString),BOOL  !returns True if worked
DecodeString    PROCEDURE(*STRING EncodedString),BOOL !returns True if worked
                !If DecodeString() returns False then see .ErrorMsg
                !If DecodeString() returns True  then .DecodedStr is STRING of .DecodedLen Bytes
DecodedStr          &STRING !Output of DecodeString
DecodedLen          LONG    !Length of DecodedStr w/o padding
DecodedSize         LONG    !String Size may be litte bigger than needed 
!----------------------------------------------------------
EncodeString    PROCEDURE(STRING Data2Encode,  LONG EncodeLength=0),BOOL
EncodeString    PROCEDURE(*STRING Data2Encode, LONG EncodeLength=0),BOOL
                !If EncodeString() returns True  then .EncodedStr is STRING of .EncodedLen Bytes
EncodedStr          &STRING !Output of EncodeString
EncodedLen          LONG    !Length of EncodedStr w/o padding
EncodedSize         LONG    !String Size may be litte bigger than needed   
```
  
This has been tested with these standards:

```clarion
    INCLUDE('CbAscii85.INC'),ONCE
Ascii85  CbAscii85Class   

Leviathan STRING('Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.')
LeviEncoded STRING('<<~9jqo^BlbD-BleB1DJ+*+F(f,q/0JhKF<<GL>Cj@.4Gp$d7F!,L7@<<6@)/0JDEF<<G%<<+EV:2F!,' & |
  'O<<DJ+*.@<<*K0@<<6L(Df-\0Ec5e;DffZ(EZee.Bl.9pF"AGXBPCsi+DGm>@3BB/F*&OCAfu2/AKY' & |
  'i(DIb:@FD,*)+C]U=@3BN#EcYf8ATD3s@q?d$AftVqCh[NqF<<G:8+EV:.+Cf>-FD5W8ARlolDIa' & |
  'l(DId<<j@<<?3r@:F%a+D58''ATD4$Bl@l3De:,-DJs`8ARoFb/0JMK@qB4^F!,R<<AKZ&-DfTqBG%G' & |
  '>uD.RTpAKYo''+CT/5+Cei#DII?(E,9)oF*2M7/c~>') 
  
  CODE

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
  

```
