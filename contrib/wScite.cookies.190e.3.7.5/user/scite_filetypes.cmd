@echo off
chcp 65001 1>NUL
::  ---- Wrapper for scite_filetypes.vbs install ----
::
:: 1) Export property "file.patterns" from all property files
:: 2) Keep only base entries (which dont use references) 
:: 3) Strip the filename prefixes which were added by FINDSTR
:: 4) Call scite_filetypes.vbs install
::
:: Mar2018 - Marcedo@habMalNeFrage.de
:: License: BSD-3-Clause
::
::

set DataFile=scite_filetypes.txt

pushd %~dp0%
:: Stupid "del" does not change ErrorLevel when the deletion failed. Working around... 
if exist scite_filetypes?.txt (del /F /Q scite_filetypes?.txt 1>NUL 2>NUL)
if exist scite_filetypes?.txt (
 echo ... Found an System locked %DataFile% please reboot or remove manually.
 goto DataFileErr
)

set arg2=%2
if ["%1"] equ ["/quite"] ( set arg1=install && goto main )

echo   ..About to soft-register Filetypes with mySciTE
call choice /C YN /M " Continue?  Yes/No" 
if %ERRORLEVEL% == 2 goto ende

:main
echo  .. Creating %DataFile%
:: collect file.patterns from all properties, ( prefixed with properties filename)
FINDSTR /SI "^file.patterns." *.properties > filetypes1.raw

:: Now filter unusable dupe entries (variable references) from above tmpfile. 
FINDSTR /SIV "$(" filetypes1.raw > filetypes2.raw

:: Finally, strip the file names, but keep the fileexts information. 
for /F "delims=: eol=# tokens=3" %%E in (filetypes2.raw) do (
 echo %%E>>%DataFile%
 if ["%1"] neq ["/quite"] echo %%E
) 

del *.raw?
echo  .. Parsing Filetypes in %DataFile% ..
cscript /NOLOGO scite_filetypes.vbs %arg1% %arg2%
if %ERRORLEVEL%==0 or %ERRORLEVEL%==969 goto :DataFileErr
echo  .. done with %ERRORLEVEL% Entries ..
echo.
popd
goto ende

:DataFileErr
pause
exit(969)

:ende
