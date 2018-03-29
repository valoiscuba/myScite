 ' Objective
 '======================================================
 ' This sample VBScript is for (re)setting file associations for SciTE
 ' Just writes itself at the end of suggested Apps in the "open File" Dialogue.
 ' so former choosen Apps keep their precedence until the User chooses otherwise.
 '
 ' written in "WonderFull" vbs - as Powershell is really bloaty.
 ' Refer the below link for StdRegProv WMI class
 ' https://msdn.microsoft.com/en-us/library/aa393664(VS.85).aspx 
 '=======================================================
 Const HKEY_CLASSES_ROOT	= &H80000000
 Const HKEY_CURRENT_USER	= &H80000001
 Const HKEY_LOCAL_MACHINE	= &H80000002
 Const HKEY_USERS								= &H80000003

 ' Ther's much depreceated Information in the Net, even from MS which still refers to use machine wide HKCR for file Exts.
 ' But modifying that mostly needs root privs to change and myScite has dropped to be XP Compatible for a while now. 
 ' So we rely to use HKCU to reach our goals  and dont require admin privs - since we only touch stuff within our own User profile.

 Const FILE_EXT_PATH	= "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\"
 Const FILE_EXT_PATH_CLS	= "Software\Classes\"

 if instr(1,wscript.fullName,"cscript") then bConsole=true
 
 function main()
  Dim arg0 ' either not given or any of the verbs install / uninstall
  Dim action ' currently - 10 for uninstall or 11 for install
  Dim cntExt ' contains the number of written strFileExts.
  Dim cntTyp ' contains the number of parsed myScite fileTypes
  
  if WScript.Arguments.count > 0 then arg0 = WScript.Arguments.Item(0)
  
  if LCase(arg0)="uninstall" then
    if bConsole then wscript.echo(" We do an -UNInstall- ") 
   action = 10 
  elseif LCase(arg0)="install" then  
    if bConsole then wscript.echo(" We do an -Install- ")
   action = 11
  else
   if bConsole then wscript.echo(" Defaulting to action -Install- ")
   action = 11
  end if
  
  ' Open myScites known filetypes List.
  Set oFso = CreateObject("scripting.FilesystemObject")
  Set oFileExt = oFso.OpenTextFile("scite_filetypes.txt", 1, True) ' forRead, CreateFlag
  if  isNull(oFileExt) then
   Wscript.echo("scite_filetypes.txt not found") 
   exit function
  end if
   
  ' Iterate through. Treat lines beginning with # as a comment. 
  while Not oFileExt.AtEndOfStream
   dim strExt, startMark,arrExt

   sChar = oFileExt.Read(1)
   if sChar="#" Then oFileExt.SkipLine ' Comment
   
   ' Just in case someone edited the file to be partly UNiX Formatted
   if  sChar=vbCR or sChar=vbLF  then 
     oFileExt.SkipLine()
     cntTyp=cntTyp+1
     
     ' Remove trash from the result
     strDesc=Replace(strDesc,"=","")
     strExt=Replace(strExt,"*","")
     strExt=Replace(strExt,vbCR,"")
     
     'if bConsole then wscript.echo(" ..Registering: " & strDesc)
     ' Create an Array from the gathered Stuff.
     ' Iterate through and register each filetype. 
     arrExt=split(strExt,";")
     for each strEle in arrExt
       if left(strEle,1)="." then
        cntExt=cntExt+1         
        if action=11 then result=assoc_ext_with_scite(strEle)
        if action=10 then result=unassoc_ext_with_scite(strEle)
       end if
     next
    
    startMark=0 : strDesc="" :strExt="":strEle=""
   end if
 
   if startMark=0 then
     strDesc=strDesc+sChar
   else
     strExt=strExt+sChar
   end if 
   
   if sChar= "=" Then startMark=1
  wend

  oFileExt.close()
  'MsgBox("Status:" & cntExt & "Einträge verarbeitet" )
  main=cntTyp
 end function


 ' ~~~~ Functions

 private function ClearKey(objReg, iRootKey, strRegKey)
 '
 ' DeleteKey cant handle recursion itself so put a little wrapper around:
 ' (Only Delete the SubKeys, dont Delete the Key itself) 
 '
  dim iKeyExist, arrSubkeys
    if strRegKey="" then exit Function
    iKeyExist = objReg.EnumKey(iRootKey , strRegKey	, arrSubkeys)   
    if typeName(arrSubkeys) = "Null" then exit function
    if iKeyExist>0  then exit function
    for each strSubKey in arrSubKeys
       'if bConsole then wscript.echo("Removed: " & strRegKey & "\" & strSubKey)
      ClearKey= objReg.DeleteKey(iRootKey , strRegKey & "\" & strSubKey)   			
    next  
 end function
 
 ' VbScript WTF.. If you init that objReg only once for reusal in globalSope, its creating unpredictable entries within the registry...
 ' Took me half the day to get to that "perfectly amusing" Fact. 
 
 private function Assoc_ext_with_scite(strFileExt) 
 '
 ' Registers all mySciTE known Filetypes
 '
 
 'todo - handle special: .bas .hta .js .msi .ps1 .reg .vb .vbs .wsf in Key UseLocalMachineSoftwareClassesWhenImpersonating
 'Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileAssociation
 
 Dim objReg ' Initialize WMI service and connect to the class StdRegProv
 strComputer = "." ' Computer name to be connected - '.' refers to the local machine
 Set objReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")

 Dim iKeyExist
 Dim strComputer
 Dim autofileExt

   autofileExt=replace(strFileExt,".","") & "_auto_file"   

   ' ... yodaForce ...
   ' handle eventually defect Entries by starting Clean with every not currently used handler resetted.
 
   ' enumKey Method: https://msdn.microsoft.com/de-de/library/windows/desktop/aa390387(v=vs.85).aspx
   ' Returns: 0==KeyExist, 2==KeyNotExist 
  
   iKeyExist = objReg.EnumKey(HKEY_CURRENT_USER, FILE_EXT_PATH & strFileExt & "\UserChoice", arrSubkeys)   
  
   ' Dont reset the ext if a user already selected a program to handle it. (Key UserChoice exists) 
    if iKeyExist = 2 and Err.Number = 0 Then 
     ' Clear the strFileExt in currentUser\....\strFileExts
     result=ClearKey(objReg,HKEY_CURRENT_USER , FILE_EXT_PATH & strFileExt)
     ' Also Clear the strFileExt within currentUser\Applications
     result=ClearKey(objReg,HKEY_CURRENT_USER ,  FILE_EXT_PATH_CLS &  autofileExt)
     ' Optional: Clear the autoFileExt within Depreceated HKCR
     result=ClearKey(objReg,HKEY_CLASSES_ROOT ,  autoFileExt)
    end if
  
   ' ...Key (re)creation starts here....
   iKeyExist = objReg.EnumKey(HKEY_CURRENT_USER, FILE_EXT_PATH & strFileExt & "\OpenWithProgIDs", arrSubkeys) 
        
   ' Create it if it does not exist
   ' CreateKey Method - https://msdn.microsoft.com/en-us/library/aa389385(v=vs.85).aspx
   if iKeyExist = 2 and Err.Number = 0 Then	
    result = result + objReg.CreateKey(HKEY_CURRENT_USER, FILE_EXT_PATH  & strFileExt)
    result = result + objReg.CreateKey(HKEY_CURRENT_USER, FILE_EXT_PATH  & strFileExt & "\OpenWithList")
    result = result + objReg.CreateKey(HKEY_CURRENT_USER, FILE_EXT_PATH  & strFileExt & "\OpenWithProgIDs")
   end if

   ' Modify the Key
   ' SetStringValue Method - http://msdn.microsoft.com/en-us/library/windows/desktop/aa393600(v=vs.85).aspx		
   if result=0 and Err.Number = 0 then	
   '1AC14E77-02E7-4E5D-B744-2EB1AE5198B7 is just the UUID equivalent for %systemroot%\system32
    result = result + objReg.setStringValue(HKEY_CURRENT_USER, FILE_EXT_PATH & strFileExt & "\OpenWithList","a","{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\OpenWith.exe")  
    result = result +  objReg.setStringValue(HKEY_CURRENT_USER, FILE_EXT_PATH & strFileExt & "\OpenWithList","y","SciTE.exe")
    result = result + objReg.setStringValue(HKEY_CURRENT_USER, FILE_EXT_PATH & strFileExt & "\OpenWithList","MRUList","ya")
    result = result + objReg.setStringValue(HKEY_CURRENT_USER, FILE_EXT_PATH & strFileExt & "\OpenWithProgIDs","Applications\Scite.exe","")
   End If
   
   ' Above Stuff returns Zero on success.
   ' if anything gone wrong, we will see that here:
   'wscript.Echo("Status: Error? " & Err.Number & " resultCode? " & result)

   if result=0 and Err.Number = 0 then 
    assoc_ext_with_scite=0
    'if bConsole then wscript.echo("Created / Modified strFileExt " & strFileExt )
   else
    assoc_ext_with_scite=99
   end if
   set objReg=Nothing
 end function

 private function unassoc_ext_with_scite(strFileExt)
 '
 ' curently simply removes subkey OpenWithProgIDs
 ' which will cause Explorer to show the openFileWith Handler again.
 '
 '
  Dim objReg ' Initialize WMI service and connect to the class StdRegProv
   
   strComputer = "." ' Computer name to be connected - '.' refers to the local machine
   Set objReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
   result=objReg.deleteKey(HKEY_CURRENT_USER, FILE_EXT_PATH &  strFileExt & "\OpenWithProgIDs") 

   if (result=0 or result=2) and Err.Number = 0 then 
    unassoc_ext_with_scite=0
    'if bConsole then wscript.echo("Modified strFileExt " & strFileExt )
   else
    unassoc_ext_with_scite=99
   end if

   set objReg=Nothing
  end function
 
 wscript.quit(main)