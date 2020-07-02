rem @echo off
chcp 1250

set KONYVTAR=%1
if not defined KONYVTAR set KONYVTAR=.
if not exist %KONYVTAR% goto HIBA
set FAJLOK=%2
if not defined FAJLOK set FAJLOK=*.xls

rem for /f "usebackq delims=" %%i in (`dir /b %KONYVTAR%\%FAJLOK%`) do perl xls2csv.pl "%KONYVTAR%\%%i" > "%KONYVTAR%\%%i.csv" | type "%KONYVTAR%\%%i.csv" > "%0.tmp"
for /f "usebackq delims=" %%i in (`dir /b %KONYVTAR%\%FAJLOK%`) do perl xls2csv.pl "%KONYVTAR%\%%i" > "%KONYVTAR%\%%i.csv"

type *.csv > %0.tmp
zip -m %0.zip *.csv
copy %0.tmp %0.csv
del %0.tmp
goto KILEPES

:HIBA
echo Hiba történt!
echo Használat: %0 Könyvtárnév Fájlok
 
:KILEPES
pause
