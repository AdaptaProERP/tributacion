// Programa   : MEMOLEYES
// Fecha/Hora : 02/03/2025 19:40:50
// Prop�sito  : Resolver acentos de leyes PDF->TXT->MYSQL
// Creado Por : Juan Navas
// Llamado por: PA101
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cMemo)

   DEFAULT cMemo:=""

   cMemo:=STRTRAN(cMemo,[°],[�])
   cMemo:=STRTRAN(cMemo,"�","")

   cMemo:=STRTRAN(cMemo,"ó","�")
   cMemo:=STRTRAN(cMemo,"ía","�")
   cMemo:=STRTRAN(cMemo,"é","�")
   cMemo:=STRTRAN(cMemo,"ú","�")
   cMemo:=STRTRAN(cMemo,"ñ","�")
   cMemo:=STRTRAN(cMemo,"�"+CHR(173),"�")
   cMemo:=STRTRAN(cMemo,"á","�" ) // "�")
   cMemo:=STRTRAN(cMemo,"�"+CHR(226),"�")
   cMemo:=STRTRAN(cMemo,"Ñ","�")
   cMemo:=STRTRAN(cMemo,"É","�")
   cMemo:=STRTRAN(cMemo,"º","�")
// cMemo:=STRTRAN(cMemo,"ó","�")
   cMemo:=STRTRAN(cMemo,CHR(13),"")
   cMemo:=STRTRAN(cMemo,"�","A")
   cMemo:=STRTRAN(cMemo,"A�","�")
   cMemo:=STRTRAN(cMemo,"Anica","�nica")
   cMemo:=STRTRAN(cMemo,"“Z�","ZETA")
   cMemo:=STRTRAN(cMemo,"“Z»","ZETA")
   cMemo:=STRTRAN(cMemo,"“X»","(X)EQUIS")
   cMemo:=STRTRAN(cMemo,"NA","N�")
   cMemo:=STRTRAN(cMemo,"N�","NA")
   cMemo:=STRTRAN(cMemo,"“Reporte 2�",[�Reporte 2�])
   cMemo:=STRTRAN(cMemo,"“N de Control…�",[�N� de Control��])
   cMemo:=STRTRAN(cMemo,"nAmero",[n�mero])

   cMemo:=STRTRAN(cMemo,"CAP�","CAP�")
   cMemo:=STRTRAN(cMemo,"Ámbito",CHR(181)+"mbito") 

RETURN cMemo
// EOF
