// Programa   : MEMOLEYES
// Fecha/Hora : 02/03/2025 19:40:50
// PropÛsito  : Resolver acentos de leyes PDF->TXT->MYSQL
// Creado Por : Juan Navas
// Llamado por: PA101
// AplicaciÛn :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cMemo)

   DEFAULT cMemo:=""

   cMemo:=STRTRAN(cMemo,[¬∞],[∞])
   cMemo:=STRTRAN(cMemo,"∫","")

   cMemo:=STRTRAN(cMemo,"√≥","Û")
   cMemo:=STRTRAN(cMemo,"√≠a","Ì")
   cMemo:=STRTRAN(cMemo,"√©","È")
   cMemo:=STRTRAN(cMemo,"√∫","˙")
   cMemo:=STRTRAN(cMemo,"√±","Ò")
   cMemo:=STRTRAN(cMemo,"√"+CHR(173),"Ì")
   cMemo:=STRTRAN(cMemo,"√°","·" ) // "Ì")
   cMemo:=STRTRAN(cMemo,"√"+CHR(226),"—")
   cMemo:=STRTRAN(cMemo,"√ë","—")
   cMemo:=STRTRAN(cMemo,"√â","…")
   cMemo:=STRTRAN(cMemo,"¬∫","∫")
// cMemo:=STRTRAN(cMemo,"√≥","·")
   cMemo:=STRTRAN(cMemo,CHR(13),"")
   cMemo:=STRTRAN(cMemo,"√","A")
   cMemo:=STRTRAN(cMemo,"Aö","˙")
   cMemo:=STRTRAN(cMemo,"Anica","˙nica")
   cMemo:=STRTRAN(cMemo,"‚ÄúZ‚Ä","ZETA")
   cMemo:=STRTRAN(cMemo,"‚ÄúZ¬ª","ZETA")
   cMemo:=STRTRAN(cMemo,"‚ÄúX¬ª","(X)EQUIS")
   cMemo:=STRTRAN(cMemo,"NA","N˙")
   cMemo:=STRTRAN(cMemo,"N˙","NA")
   cMemo:=STRTRAN(cMemo,"‚ÄúReporte 2‚Ä",[ìReporte 2î])
   cMemo:=STRTRAN(cMemo,"‚ÄúN de Control‚Ä¶‚Ä",[ìN∞ de ControlÖî])
   cMemo:=STRTRAN(cMemo,"nAmero",[n˙mero])

   cMemo:=STRTRAN(cMemo,"CAP√","CAPÕ")
   cMemo:=STRTRAN(cMemo,"√Åmbito",CHR(181)+"mbito") 

RETURN cMemo
// EOF
