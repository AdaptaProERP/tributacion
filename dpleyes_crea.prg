// Programa   : DPLEYES_CREA
// Fecha/Hora : 23/10/2024 05:34:36
// Propósito  : Crea tabla DPLEYES, realizar consultas
// Creado Por : Juan Navas
// Llamado por: DPINIADDFIELD       
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL aFields:={}
   LOCAL cCodigo,cDescri,lRun,cSql
   LOCAL oDb   :=OpenOdbc(oDp:cDsnConfig)
   LOCAL cTable:="DPLEYES" 

   IF !ISSQLFIND("DPTABLAS","TAB_NOMBRE"+GetWhere("=",cTable)      ) 

     AADD(aFields,{"LEY_CODIGO","C",020,0,"Código"   ,""})
     AADD(aFields,{"LEY_TEXTO" ,"M",010,0,"Texto"    ,""})
     AADD(aFields,{"LEY_ARTICU","C",020,0,"Artículo" ,""})
     AADD(aFields,{"LEY_TITULO","C",250,0,"Titulo"  ,""})

     EJECUTAR("DPTABLEADD"   ,cTable,"Leyes"    ,".CONFIGURACION",aFields)
     EJECUTAR("SETPRIMARYKEY",cTable,"LEY_CODIGO,LEY_ARTICU"     ,.T.)

     AEVAL(aFields,{|a,n|  EJECUTAR("DPCAMPOSADD" ,cTable,a[1],a[2],a[3],a[4],a[5])})

  ENDIF

  IF !EJECUTAR("DBISTABLE",oDb,cTable,.F.)
     Checktable(cTable)
  ENDIF

RETURN .T.
// EOF

