// Programa   : DPLEYESIMPORTTXT
// Fecha/Hora : 03/03/2025 08:25:25
// Prop�sito  : Importar Leyes desde dp\<FILE.TXT>
// Creado Por : Juan Navas
// Llamado por: DPINIADDFIELD       
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

   EJECUTAR("PA141","DP\PA071.TXT"  ,"PA071"  ,.F.)
   EJECUTAR("PA141","DP\PA102.TXT"  ,"PA102"  ,.F.)
   EJECUTAR("PA141","DP\PA121.TXT"  ,"PA121"  ,.F.)
   EJECUTAR("PA141","DP\PA141.TXT"  ,"PA141"  ,.F.)
   EJECUTAR("PA141","DP\COT2020.TXT","COT",.F.)

RETURN
