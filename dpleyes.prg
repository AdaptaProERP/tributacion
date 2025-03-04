// Programa   : DPLEYES
// Fecha/Hora : 12/05/2004 00:53:10
// Propósito  : Visualizar Ley del Trabajo  
// Creado Por : Juan Navas
// Llamado por: NMCONCEPTOS
// Aplicación : Nómina
// Tabla      : DP\NMLEYTRA.DBF

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTitulo,cWhere)
  LOCAL aArticulo :={},aData
  LOCAL aMemo     :={}
  LOCAL aContenido:={}
  LOCAL aTodos    :={}
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oSintax,oMemo,oEjemplo,oGrp
  LOCAL cFind    :=SPACE(65),cSql


  DEFAULT cTitulo:="LEYES",;
          cWhere :=""

  IF COUNT("DPLEYES")=0
     EJECUTAR("DPLEYESIMPORTTXT")
  ENDIF

//  SELE A
//  USE DP\DPLEYES.DBF EXCLU ALIAS LEYES VIA "DBFCDX"
//
//  DBEVAL({||AADD(aArticulo      ,LEY_CAMPO ) ,;
//                 AADD(aMemo     ,LEY_TITULO) ,;
//                 AADD(aContenido,LEY_TEXTO )})
//

  cSql  :="SELECT LEY_ARTICU,LEY_TITULO,LEY_TEXTO FROM DPLEYES "+;
          IF(Empty(cWhere),""," WHERE "+cWhere)+;
          " ORDER BY CONCAT(LEY_CODIGO,LEY_ARTICU)"


  aData :=ASQL(cSql)

  AEVAL(aData,{|a,n|AADD(aArticulo ,a[1] ) ,;
                    AADD(aMemo     ,a[2] ) ,;
                    AADD(aContenido,a[3] )})
  

     
  aTodos:={aArticulo,aMemo,aContenido}
//  USE

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD
  DEFINE FONT oFontB NAME "Courier New"   SIZE 0, -12 BOLD

  oFrmLey:=DPEDIT():New(cTitulo,"DPLEYES.edt","oFrmLey",.T.)
  oFrmLey:cFileChm:="CAPITULO1.CHM"
  oFrmLey:cTopic  :="00M50"
  oFrmLey:lEscClose:=.T.
  oFrmLey:nBrowse  :=1

  oFrmLey:cFind   :=SPACE(65)
  oFrmLey:oSintax :=NIL
  oFrmLey:oMemo   :=NIL
  oFrmLey:oLey    :=NIL

  oFrmLey:aTodos  :=ACLONE(aTodos)
  oFrmLey:aArt    :=aTodos[1]
  oFrmLey:aDes    :=aTodos[2]
  oFrmLey:aLey    :=aTodos[3]

  @ 1.8,10   GROUP oGrp TO 3.5, 45.0 PROMPT "Buscar" FONT oFontB;
             COLOR CLR_BLACK,15724527

  @ 2.6,09.5 BMPGET oFrmLey:oSintax VAR oFrmLey:cFind FONT oFontB COLOR CLR_BLACK,CLR_WHITE;
             NAME   "BITMAPS\FIND.bmp";
             ACTION oFrmLey:FindText(oFrmLey);
             VALID  oFrmLey:FindText(oFrmLey)
 
  @ 3.8,10 GROUP oGrp TO 8.5-2.5, 45.0 PROMPT "Descripción" FONT oFontB;
           COLOR CLR_BLACK,15724527

  @ 4.8,14 GET oFrmLey:oMemo VAR oFrmLey:aDes[1] MEMO FONT oFontB COLOR CLR_BLACK,CLR_WHITE SIZE 190-140,50

oFrmLey:oMemo:bGotFocus:={|| oFrmLey:oBrw:nArrayAt:=oFrmLey:nBrowse}

  // Ejemplo
  @ 8.8-2.5,10 GROUP oGrp TO 13.5, 45.0 PROMPT "Contenido" FONT oFontB;
           COLOR CLR_BLACK,15724527

  @10.3-2.8,14 GET oFrmLey:oLey VAR oFrmLey:aLey[1] MEMO FONT oFontB COLOR CLR_BLACK,CLR_WHITE SIZE 190,40

  oBrw:=TXBrowse():New( oDlg )

//  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aTodos[1], .T. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oBrw:bChange:={|nAt,oBrw,nLen|;
                           oBrw :=oFrmLey:oBrw        ,;
                           nLen :=Len(oBrw:aArrayData),;
                           nAt  :=oBrw:nArrayAt       ,;
                           nAt  :=ASCAN(oFrmLey:aArt,oBrw:aArrayData[nAt]),;
                           oFrmLey:oMemo:SetText(oFrmLey:aDes[nAt])       ,;
                           oFrmLey:oLey:SetText(oFrmLey:aLey[nAt])        ,;
                           oFrmLey:nBrowse:=oFrmLey:oBrw:nArrayAt,;
                           oBrw:SetFocus()} 

  
  oBrw:aCols[1]:cHeader:="Artículo"
  oBrw:aCols[1]:cFooter:=" "+LSTR(Len(aTodos[1]))
  oBrw:aCols[1]:nWidth :=80

  oBrw:bLostFocus:={||oFrmLey:nBrowse:=oFrmLey:oBrw:nArrayAt}
// oBrw:bBotFocus :={||oFrmLey:oBrw:nArrayAt:=oFrmLey:nBrowse}


// oBrw:bLostFocus:={||oFrmLey:nBrowse:=oFrmLey:oBrw:nArrayAt}}
//  oBrw:bClrHeader:= {|| {0,14671839 }}
//  oBrw:bClrFooter:= {|| {0,14671839 }}

  oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oBrw:bClrStd := {|oBrw|oBrw:=oFrmLey:oBrw,{0, iif( oBrw:nArrayAt%2=0, oDp:nClrPane1, oDp:nClrPane2 ) } }
  oBrw:SetFont(oFont)

  oFrmLey:oBrw:=oBrw

  oBrw:CreateFromCode()

  oFrmLey:Activate({||oFrmLey:LeyBar(oFrmLey)})

  oDp:nDif:=(oDp:aCoors[3]-180-oFrmLey:oWnd:nHeight())
  oFrmLey:oWnd:SetSize(NIL,oDp:aCoors[3]-180,.T.)
  
  oGrp:SetSize(NIL,oGrp:nHeight()+(oDp:nDif-0),.T.)
  oBrw:SetSize(NIL,oBrw:nHeight()+(oDp:nDif-0),.T.)
  oFrmLey:oLey:SetSize(NIL,oFrmLey:oLey:nHeight()+(oDp:nDif-0),.T.)


  STORE NIL TO oBrw,aArticulo,oDlg,aTodos
  Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oFrmLey)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oFrmLey:oDlg

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52,60 OF oDlg 3D CURSOR oCursor


 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\TXT.BMP";
          TOP PROMPT "TXT"; 
          ACTION  oFrmLey:LEYVERTXT()

   oBtn:cToolTip:="Todos en TXT"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION (oFrmLey:oBrw:GoTop(),oFrmLey:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          TOP PROMPT "Próximo"; 
          ACTION (oFrmLey:oBrw:PageDown(),oFrmLey:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          TOP PROMPT "Previo"; 
          ACTION (oFrmLey:oBrw:PageUp(),oFrmLey:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION (oFrmLey:oBrw:GoBottom(),oFrmLey:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSAVE.BMP";
          TOP PROMPT "Grabar"; 
          ACTION  oFrmLey:LEYSAVE(oFrmLey)

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION oFrmLey:LeyPrint(oFrmLey)

   oBtn:cToolTip:="Imprimir"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Salir"; 
          ACTION oFrmLey:Close()

  oFrmLey:oBrw:SetColor(0,oDp:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

/*
// Grabar Función
*/
FUNCTION LEYSAVE(oFrmLey)
   LOCAL nAT:=oFrmLey:oBrw:nArrayAt,cArt:=oFrmLey:oBrw:aArrayData[nAt]

   IF !MsgYesNo("Desea Grabar Este Artículo "+cArt,"Grabar Artículo")
       RETURN .T.  
   ENDIF

   SELE A
   USE DP\DPLEYES.DBF EXCLU ALIAS LEYES VIA "DBFCDX"

   LOCATE FOR cArt==LEY_CAMPO

   IF FOUND()

        REPLACE  LEY_TITULO WITH oFrmLey:oMemo:GetText(),;
                 LEY_TEXTO  WITH oFrmLey:oLey:GetText()

   ENDIF

   USE

RETURN .T
/*
// Imprimir Función
*/
#include "report.ch"

FUNCTION LEYPRINT(oFrmLey)
     LOCAL nAT :=oFrmLey:oBrw:nArrayAt
     LOCAL aLine,I,cArt:="Artículo: "+oFrmLey:oBrw:aArrayData[nAt]
     LOCAL aMemo:={}
     
     PRIVATE oReport, nField

     aLine:=_VECTOR(oFrmLey:oMemo:GetText(),CHR(10))
     FOR I=1 TO LEN(aLine)
        AADD(aMemo,{IIF(I=1,"Descripción",""),STRTRAN(aLine[I],CHR(13),"")})
     NEXT I

     AADD(aMemo,{"",""})
     aLine:=_VECTOR(oFrmLey:oLey:GetText(),CHR(10))
     FOR I=1 TO LEN(aLine)
        AADD(aMemo,{IIF(I=1,"Contenido",""),STRTRAN(aLine[I],CHR(13),"")})
     NEXT I

     nField := 1

     REPORT oReport TITLE  "* LEY DEL TRABAJO *",;
            " REPORTE DE ARTICULO DE LEY ("+ALLTRIM(cArt)+")";
            PREVIEW CAPTION "L.O.T.: "+cArt

     COLUMN TITLE "REFERENCIA" DATA aMemo[nField][1] SIZE 10

     COLUMN TITLE "CONTENIDO" DATA aMemo[nField][2] SIZE 60

     END REPORT

     oReport:bSkip := {|| nField++}

     ACTIVATE REPORT oReport WHILE nField <= len(aMemo)

RETURN NIL

/*
// Buscar
*/
FUNCTION FindText(oFrmLey)
   LOCAL aArt  :={}
   LOCAL aDes  :={}
   LOCAL aLey  :={}
   LOCAL aTodos:=oFrmLey:aTodos
   LOCAL cText :=oFrmLey:cFind
   LOCAL I
   LOCAL aText :=_VECTOR(cText,"&"),cTex2:=""

   IF LEN(aText)>1
      cText:=ALLTRIM(aText[1])
      cTex2:=ALLTRIM(aText[2])
   ENDIF

   cText:=ALLTRIM(UPPE(cText))

   IF Empty(cText)
      IF Len(oFrmLey:oBrw:aArrayData)<>LEN(aTodos[1])
         oFrmLey:oBrw:aArrayData:=oFrmLey:aTodos[1]
         oFrmLey:oBrw:aCols[1]:cFooter:=" "+LSTR(Len(oFrmLey:aTodos[1]))
         oFrmLey:oBrw:GoTop()
         oFrmLey:oBrw:Refresh(.T.)
         Eval(oFrmLey:oBrw:bChange)
      ENDIF
      RETURN .T.
   ENDIF

   CURSORWAIT()

   FOR I=1 TO LEN(aTodos[1])

      IF !Empty(cTex2) 

       IF cText$aTodos[1,I] .OR. cText$UPPE(aTodos[2,I]) .OR. (cText$UPPE(aTodos[3,I]) .AND. cTex2$UPPE(aTodos[3,I]))
          AADD(aArt,aTodos[1,I])
       ENDIF

      ELSE

       IF cText$aTodos[1,I] .OR. cText$UPPE(aTodos[2,I]) .OR. cText$UPPE(aTodos[3,I])
          AADD(aArt,aTodos[1,I])
       ENDIF

      ENDIF
   NEXT 

   IF !Empty(aArt)
     oFrmLey:oBrw:nArrayAt  :=1
     oFrmLey:oBrw:aArrayData:=aArt
     oFrmLey:oBrw:aCols[1]:cFooter:=" "+LSTR(Len(aArt))
     oFrmLey:oBrw:GoTop()
     oFrmLey:oBrw:Refresh(.T.)
     Eval(oFrmLey:oBrw:bChange)
   ELSE
     oFrmLey:oSintax:MsgErr("Texto ["+cText+"] No Encontrado","Búsqueda sin Exito")
     RETURN .F.
   ENDIF

   CURSORARROW()

RETURN .T.

FUNCTION LEYVERTXT()
  LOCAL cMemo:="",I,nAt,oBrw:=oFrmLey:oBrw
  LOCAL cFile:="TEMP\LEYBUSCAR_"+LSTR(SECONDS())+".TXT"
  LOCAL oFont
  LOCAL cRaya:=REPLI("-",132)

  DEFINE FONT oFont     NAME "Courier"   SIZE 0, -10

  FOR I=1 TO LEN(oBrw:aArrayData)

      nAt  :=ASCAN(oFrmLey:aArt,oBrw:aArrayData[I])

      cMemo:=cMemo+IF(Empty(cMemo),"",CRLF+CRLF)+oBrw:aArrayData[I]+CRLF+oFrmLey:aLey[nAt]+CRLF+cRaya
 //     cMemo:=cMemo+IF(Empty(cMemo),"",CRLF+CRLF)+oFrmLey:aDes[nAt]+CRLF+oFrmLey:aLey[nAt]+CRLF+cRaya

  NEXT I

  cMemo:="Contenidos encontrados según "+oFrmLey:cFind+CRLF+cRaya+CRLF+cMemo
  DPWRITE(cFile,cMemo)

  VIEWRTF(cFile,"Contenidos encontrados según "+oFrmLey:cFind,oFont)

RETURN .T.

// EOF


