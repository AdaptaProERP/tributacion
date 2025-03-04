// Programa   : PA141
// Fecha/Hora : 27/11/2024 22:20:24
// Contenido: https://github.com/AdaptaProERP/Nomina/blob/main/LOTTT.txt
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cFile,cCodigo,lReset)
   LOCAL aData :={},cMemo,I,cArticulo:="",cTitle:="",nAt
   LOCAL cArticulo,cTitulo,cWhere
   LOCAL oTable

/*
   DEFAULT cFile :="DP\PA141.TXT",;
           cCodigo:="PA141"
*/
/*
 DEFAULT cFile :="DP\PA071.TXT",;
           cCodigo:="PA071"
*/

/*
 DEFAULT cFile :="DP\PA102.TXT",;
           cCodigo:="PA102"
*/

/*
   DEFAULT cFile :="DP\PA121.TXT",;
           cCodigo:="PA121",;
           lReset:=.T.
*/

   DEFAULT cFile :="DP\COT2020.TXT",;
           cCodigo:="COT",;
           lReset:=.T.

   IF lReset
      SQLDELETE("DPLEYES","LEY_CODIGO"+GetWhere("=",cCodigo))
   ENDIF

   /*
   // Providencias
   */
   IF COUNT("DPLEYES","LEY_CODIGO"+GetWhere("=",cCodigo))>0
      RETURN .T.
   ENDIF

   cMemo:=MEMOREAD(cFile)

   cMemo:=STRTRAN(cMemo,[tÃ],[tí])
   cMemo:=STRTRAN(cMemo,CHR(13),"")

   aData :=_VECTOR(cMemo,CHR(10)) // CHR(10))

   cMemo :=""
   FOR I=1 TO LEN(aData)

      IF LEFT(aData[I],3)="Art"
         aData[I]:=cCodigo+SUBS(aData[I],10,LEN(aData[I]))
      ENDIF

      IF LEN(ALLTRIM(aData[I]))=7 .OR. LEN(ALLTRIM(aData[I]))=8
         aData[I]:=ALLTRIM(aData[I])+". "
      ENDIF

      cMemo:=cMemo+aData[I]+CHR(10) // IF(Empty(cMemo),"",CHR(10))+aData[I]

   NEXT I

   cMemo:=STRTRAN(cMemo,"artí­culos","jjjjjjjjjjj") // CHR(10))
   cMemo:=STRTRAN(cMemo,"Articulo","ARTICULO")
   cMemo:=STRTRAN(cMemo,"Artí­culo","ARTICULO")
   cMemo:=STRTRAN(cMemo," ARTICULO","ARTICULO")
   cMemo:=STRTRAN(cMemo,"Â°","") // CHR(10))
   cMemo:=STRTRAN(cMemo,"Ãº","ú")
   cMemo:=STRTRAN(cMemo,"Â","")
   cMemo:=STRTRAN(cMemo,"tí©r","tér")

   cMemo:=EJECUTAR("MEMOLEYES",cMemo)
   aData:=_VECTOR(cMemo,cCodigo) // CHR(10))

   FOR I=1 TO LEN(aData)

     IF LEFT(aData[I],7)="RTICULO"
        aData[I]:="A"+aData[I]
     ENDIF


      IF LEFT(aData[I],2)="OT" .OR. LEFT(aData[I],2)="A0" .OR.  LEFT(aData[I],2)="A1" .OR. LEFT(aData[I],3)="PA1"
         aData[I]:="ARTICULO "+SUBS(aData[I],LEN(cCodigo)+1,LEN(aData[I]))
      ENDIF



//     IF LEFT(aData[I],3)="ARTICULO"
//        aData[I]:="A"+aData[I]
//     ENDIF

     aData[I]:=STRTRAN(aData[I],"jjjjjjjjjjj","artí­culos")

     aData[I]:=STRTRAN(aData[I],"ARTICULO 1.","ARTICULO 01.")
     aData[I]:=STRTRAN(aData[I],"ARTICULO 2.","ARTICULO 02.")
     aData[I]:=STRTRAN(aData[I],"ARTICULO 3.","ARTICULO 03.")
     aData[I]:=STRTRAN(aData[I],"ARTICULO 4.","ARTICULO 04.")
     aData[I]:=STRTRAN(aData[I],"ARTICULO 5.","ARTICULO 05.")
     aData[I]:=STRTRAN(aData[I],"ARTICULO 6.","ARTICULO 06.")
     aData[I]:=STRTRAN(aData[I],"ARTICULO 7.","ARTICULO 07.")
     aData[I]:=STRTRAN(aData[I],"ARTICULO 8.","ARTICULO 08.")
     aData[I]:=STRTRAN(aData[I],"ARTICULO 9.","ARTICULO 09.")

     aData[I]:=STRTRAN(aData[I],"ARTICULO",cCodigo)

  NEXT I

  SQLDELETE("DPLEYES","LEY_CODIGO"+GetWhere("=",cCodigo))

  oTable:=OpenTable("SELECT * FROM DPLEYES",.F.)

  FOR I=1 TO LEN(aData)

     oTable:AppendBlank() // APPEND BLANK
     cArticulo:=""

     IF I=1 
       cArticulo:=cCodigo
       cTitulo  :=aData[I]
     ENDIF

     IF Empty(cArticulo)

      nAt      :=AT(".",aData[I])
      cArticulo:=LEFT(aData[I],nAt-1)
      cTitulo  :=SUBS(aData[I],nAt+1,LEN(aData[I]))

      nAt      :=AT(".",cTitulo)

      IF nAt=0
        nAt      :=AT(":",cTitulo)
      ENDIF

      IF nAt=0
        nAt      :=AT(",",cTitulo)
      ENDIF

      IF nAt>0
         cTitulo:=LEFT(cTitulo,nAt)
      ENDIF

      aData[I]:=STRTRAN(aData[I],cCodigo,"Artículo")

     ENDIF

     IF "COT"$cArticulo .AND. LEN(ALLTRIM(cArticulo))<7
       cArticulo:=STRTRAN(cArticulo,"COT ","COT 0")
     ENDIF

     cWhere:="LEY_ARTICU"+GetWhere("=",cArticulo)+" AND "+;
             "LEY_CODIGO"+GetWhere("=",cCodigo  )

     aData[I]:=STRTRAN(aData[I],CHR(10),CRLF)

     IF !ISSQLFIND("DPLEYES",cWhere)
       oTable:REPLACE("LEY_ARTICU",cArticulo)
       oTable:REPLACE("LEY_CODIGO",cCodigo)
       oTable:REPLACE("LEY_TITULO",cTitulo)
       oTable:REPLACE("LEY_TEXTO" ,aData[I])
       oTable:Commit("")
     ENDIF

  NEXT I

  oTable:End()

  EJECUTAR("DPLEYES")

RETURN NIL
// EOF

