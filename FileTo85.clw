!Example of using SystemString to Read a File, Encode it and Write it, decode it and write it
  PROGRAM

    INCLUDE('SystemString.INC'),ONCE
    INCLUDE('CbAscii85.INC'),ONCE 

  MAP
FileTo85Test PROCEDURE()
  END

    CODE
    COMPILE('**END 11**', _C110_)
  SYSTEM{PROP:MsgModeDefault}=MSGMODE:CANCOPY
    !end of COMPILE('**END 11**', _C11_)
    
    FileTo85Test()

FileTo85Test PROCEDURE()
TestFile    EQUATE('BigBangTheory.clw')     !This file is in my folder
SaveFile    STRING(64)
ErrCode LONG
SSread  SystemStringClass
SSwrite SystemStringClass
File85  CbAscii85Class
Result  BOOL
Time1 LONG  
Time2 LONG 
YCaption PSTRING(20)
    CODE
    File85.LineLength=100
    ErrCode = SSread.FromFile(TestFile)
    IF ErrCode THEN
       Message('Error ' & ErrCode & ' FromFile (reading file) ' & TestFile )
       RETURN
    END

    IF Message('FromFile Loaded: ' & TestFile & |
            '|File loaded Length ' & SSread.Length() , |
            'File 85 Test',,'Encode|Halt') =2 THEN HALT().
    
    SaveFile='FileTo85_Encode_Adobe.TXT'
    DO EncodeRtn 

    !Write same file with 'y' = 4 spaces B to A v4.2 allowed.     
    File85.Y_4_Spaces=1
    YCaption=' - Y 4 Space'
    SaveFile='FileTo85_Encode_BtoA_Yspaces.TXT'
    DO EncodeRtn 

    !--Now Decode and Write 
    SaveFile='FileTo85_Decode_BtoA_Yspaces.TXT'
    Result = File85.DecodeString(File85.EncodedStr)
    IF ~Result THEN 
        Message('Decode Failed ' & File85.ErrorMsg,'File Test' & YCaption)
    ELSIF File85.DecodedLen < 1
        Message('Bug DecodedLen = ' &  File85.DecodedLen ) 
    ELSE

        SSwrite.SetString(File85.DecodedStr[1 : File85.DecodedLen ])
        ErrCode = SSwrite.ToFile(SaveFile)
        IF ErrCode THEN
           Message('Error ' & ErrCode & ' ToFile (writing file) ' & SaveFile )
        ELSE
           Message('Saved Decoded to ' & SaveFile )
        END    
    
    END     
    
EncodeRtn ROUTINE 
    
    Time1=CLOCK()
 
    OMIT('**END 10**', _C110_)    !04/26 Clarion 10 and prior
        Result = File85.EncodeString(SSread.GetString()) !Has 42,732 <00,00,00,00> 
        !C10 did not have GetStringRef(),*STRING
        !    but you could add your own with RETURN SELF.S
    !end of COMPILE('**END 10**', _C11_)

    COMPILE('**END 11**', _C110_)    !04/26 Clarion 11+
        Result = File85.EncodeString(SSread.GetStringRef()) !Has 42,732 <00,00,00,00>
    !end of COMPILE('**END 11**', _C11_)

    
    Time2=CLOCK()
    IF ~Result THEN 
        Message('File Encode Failed ' & File85.ErrorMsg,'File Test' & YCaption)
        EXIT 
    ELSIF File85.EncodedStr &= NULL THEN 
        Message('Bug EncodedStr &= NULL') ; EXIT 
    ELSIF File85.EncodedLen < 1
        Message('Bug EncodedLen = ' &  File85.EncodedLen ) ; EXIT 
    END     

    IF Message((Time2-Time1)/100 & ' seconds to encode' & YCaption & ' {50}' & |
            '||File loaded Bytes<9>=' & SSread.Length() & |
            '||Encoded Length<9>=' & File85.EncodedLen & |
            '   Size=' & File85.EncodedSize & |
            '||Extra=' & File85.EncodedSize-File85.EncodedLen , |
            'Encode' & YCaption,'Save File|No Save') = 2 THEN EXIT.
            
    SSwrite.SetString(File85.EncodedStr[1 : File85.EncodedLen ])
    ErrCode = SSwrite.ToFile(SaveFile)
    IF ErrCode THEN
       Message('Error ' & ErrCode & ' ToFile (writing file) ' & SaveFile )
       EXIT
    ELSE
       Message('Saved Encoded to ' & SaveFile )
    END    
    
    
    