::...::..:::...::..::.:.::
::	SciTE Clean	::
::...::..:::...::..::.:.::

@echo off
mode 130,18
cd 3.7.0
del /S /Q *.dll *.exe *.properties *.a *.aps *.bsc  *.dsw *.idb *.ilc *.ild *.ilf *.ilk *.ils *.lib *.map *.ncb *.obj *.o *.opt *.pdb *.plg *.res *.sbr *.tds *.exp *.pyc *.orig *.rej 2>NUL
PAUSE
EXIT
