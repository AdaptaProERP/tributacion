// Programa   : DPGACETARUN
// Fecha/Hora : 08/01/2025 17:23:36
// Prop�sito  :
// Creado Por :
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cGaceta,cField,oLbx)
   LOCAL cUrl

   CursorWait()

   DEFAULT cField :="GAC_URL",;
           cGaceta:=SQLGET("DPGACETA","GAC_NUMERO")

   cUrl:=SQLGET("DPGACETA",cField,"GAC_NUMERO"+GetWhere("=",cGaceta))

   EJECUTAR("WEBRUN",cUrl,.F.)

   SQLUPDATE("DPGACETA","GAC_VIEW",.T.,"GAC_NUMERO"+GetWhere("=",cGaceta))

   IF ValType(oLbx)="O"
      oLbx:Refresh(.F.)
   ENDIF

RETURN .T.
// EOF
