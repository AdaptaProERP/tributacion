// Programa   : GETQUINCENAFISCAL
// Fecha/Hora : 02/07/2024 12:07:51
// Prop�sito  : Obtiene la Fecha Fiscal
// Creado Por : Juan Navas
// Llamado por: Calendario Fiscal
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dDesde)
   LOCAL dHasta

   DEFAULT dDesde :=oDp:dFecha

   IF DAY(dDesde)<=15

      dDesde  :=FCHINIMES(dDesde)
      dDesde  :=dDesde-1
      dDesde  :=CTOD("15/"+LSTR(MONTH(dDesde))+"/"+LSTR(YEAR(dDesde)))
      dHasta  :=FCHFINMES(dDesde)

   ELSE

      dHasta  :=CTOD("15/"+LSTR(MONTH(dDesde))+"/"+LSTR(YEAR(dDesde)))
      dDesde  :=FCHINIMES(dHasta)
   
   ENDIF

   oDp:aLine:={dDesde,dHasta}

RETURN oDp:aLine
// EOF
