// Programa   : BRCEPPXDEF
// Fecha/Hora : 23/05/2024 01:27:05
// Propósito  : "Clasificación de Conceptos por Definir CEPP"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRCEPPXDEF.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aFields  :={}

   oDp:cRunServer:=NIL

   IF Type("oCEPPXDEF")="O" .AND. oCEPPXDEF:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCEPPXDEF,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Clasificación de Conceptos por Definir CEPP" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,dDesde,dDesde,dHasta)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,dDesde,dDesde,dHasta)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

   ENDIF

   aFields:=ACLONE(oDp:aFields) // genera los campos Virtuales

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oCEPPXDEF

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oCEPPXDEF","BRCEPPXDEF.EDT")
// oCEPPXDEF:CreateWindow(0,0,100,550)
   oCEPPXDEF:Windows(0,0,aCoors[3]-160,MIN(432,aCoors[4]-10),.T.) // Maximizado



   oCEPPXDEF:cCodSuc  :=cCodSuc
   oCEPPXDEF:lMsgBar  :=.F.
   oCEPPXDEF:cPeriodo :=aPeriodos[nPeriodo]
   oCEPPXDEF:cCodSuc  :=cCodSuc
   oCEPPXDEF:nPeriodo :=nPeriodo
   oCEPPXDEF:cNombre  :=""
   oCEPPXDEF:dDesde   :=dDesde
   oCEPPXDEF:cServer  :=cServer
   oCEPPXDEF:dHasta   :=dHasta
   oCEPPXDEF:cWhere   :=cWhere
   oCEPPXDEF:cWhere_  :=cWhere_
   oCEPPXDEF:cWhereQry:=""
   oCEPPXDEF:cSql     :=oDp:cSql
   oCEPPXDEF:oWhere   :=TWHERE():New(oCEPPXDEF)
   oCEPPXDEF:cCodPar  :=cCodPar // Código del Parámetro
   oCEPPXDEF:lWhen    :=.T.
   oCEPPXDEF:cTextTit :="" // Texto del Titulo Heredado
   oCEPPXDEF:oDb      :=oDp:oDb
   oCEPPXDEF:cBrwCod  :="CEPPXDEF"
   oCEPPXDEF:lTmdi    :=.T.
   oCEPPXDEF:aHead    :={}
   oCEPPXDEF:lBarDef  :=.T. // Activar Modo Diseño.
   oCEPPXDEF:aFields  :=ACLONE(aFields)
   oCEPPXDEF:aPropB   :=ATABLE([SELECT CLA_CODIGO FROM NMCLACON WHERE LEFT(CLA_CODIGO,4)='CEPP' ORDER BY CLA_CODIGO ])

   oCEPPXDEF:nClrPane1:=oDp:nClrPane1
   oCEPPXDEF:nClrPane2:=oDp:nClrPane2

   oCEPPXDEF:nClrText1:=0
   oCEPPXDEF:nClrText2:=0
   oCEPPXDEF:nClrText3:=0
   oCEPPXDEF:nClrText4:=0
   oCEPPXDEF:nClrText5:=0


   AEVAL(oDp:aFields,{|a,n| oCEPPXDEF:SET("COL_"+a[1],n)}) // Campos Virtuales en el Browse

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCEPPXDEF:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCEPPXDEF)}

   oCEPPXDEF:lBtnRun     :=.F.
   oCEPPXDEF:lBtnMenuBrw :=.F.
   oCEPPXDEF:lBtnSave    :=.F.
   oCEPPXDEF:lBtnCrystal :=.F.
   oCEPPXDEF:lBtnRefresh :=.F.
   oCEPPXDEF:lBtnHtml    :=.T.
   oCEPPXDEF:lBtnExcel   :=.T.
   oCEPPXDEF:lBtnPreview :=.T.
   oCEPPXDEF:lBtnQuery   :=.F.
   oCEPPXDEF:lBtnOptions :=.T.
   oCEPPXDEF:lBtnPageDown:=.T.
   oCEPPXDEF:lBtnPageUp  :=.T.
   oCEPPXDEF:lBtnFilters :=.T.
   oCEPPXDEF:lBtnFind    :=.T.
   oCEPPXDEF:lBtnColor   :=.T.
   oCEPPXDEF:lBtnZoom    :=.F.
   oCEPPXDEF:lBtnNew     :=.F.


   oCEPPXDEF:nClrPane1:=16775408
   oCEPPXDEF:nClrPane2:=16771797

   oCEPPXDEF:nClrText :=0
   oCEPPXDEF:nClrText1:=0
   oCEPPXDEF:nClrText2:=0
   oCEPPXDEF:nClrText3:=0


   oCEPPXDEF:oBrw:=TXBrowse():New( IF(oCEPPXDEF:lTmdi,oCEPPXDEF:oWnd,oCEPPXDEF:oDlg ))
   oCEPPXDEF:oBrw:SetArray( aData, .F. )
   oCEPPXDEF:oBrw:SetFont(oFont)

   oCEPPXDEF:oBrw:lFooter     := .T.
   oCEPPXDEF:oBrw:lHScroll    := .F.
   oCEPPXDEF:oBrw:nHeaderLines:= 2
   oCEPPXDEF:oBrw:nDataLines  := 1
   oCEPPXDEF:oBrw:nFooterLines:= 1

   oCEPPXDEF:aData            :=ACLONE(aData)

   AEVAL(oCEPPXDEF:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   
 // Campo: HIS_CODCON
  oCol:=oCEPPXDEF:oBrw:aCols[oCEPPXDEF:COL_HIS_CODCON]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPXDEF:oBrw:aArrayData ) } 
  oCol:nWidth       := 32

  // Campo: CON_DESCRI
  oCol:=oCEPPXDEF:oBrw:aCols[oCEPPXDEF:COL_CON_DESCRI]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPXDEF:oBrw:aArrayData ) } 
  oCol:nWidth       := 300

  // Campo: CYC_CODCLA
  oCol:=oCEPPXDEF:oBrw:aCols[oCEPPXDEF:COL_CYC_CODCLA]
  oCol:cHeader      :='Clasificación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPXDEF:oBrw:aArrayData ) } 
  oCol:nWidth       := 100

  oCol:aEditListTxt   :=oCEPPXDEF:aPropB
  oCol:aEditListBound :=oCEPPXDEF:aPropB
  oCol:nEditType      :=EDIT_LISTBOX
  oCol:bOnPostEdit    :={|oCol,uValue|oCEPPXDEF:GRABARCLASIFICA(oCol,uValue)}
  oCol:bEditBlock     :={||oCEPPXDEF:SETPROPIEDAD()}


   oCEPPXDEF:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCEPPXDEF:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCEPPXDEF:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCEPPXDEF:nClrText,;
                                                 nClrText:=IF(.F.,oCEPPXDEF:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCEPPXDEF:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCEPPXDEF:nClrPane1, oCEPPXDEF:nClrPane2 ) } }

//   oCEPPXDEF:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCEPPXDEF:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCEPPXDEF:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCEPPXDEF:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCEPPXDEF:oBrw:bLDblClick:={|oBrw|oCEPPXDEF:RUNCLICK() }

   oCEPPXDEF:oBrw:bChange:={||oCEPPXDEF:BRWCHANGE()}
   oCEPPXDEF:oBrw:CreateFromCode()

   oCEPPXDEF:oWnd:oClient := oCEPPXDEF:oBrw

   oCEPPXDEF:Activate({||oCEPPXDEF:ViewDatBar()})

   oCEPPXDEF:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCEPPXDEF:lTmdi,oCEPPXDEF:oWnd,oCEPPXDEF:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCEPPXDEF:oBrw:nWidth()

   oCEPPXDEF:oBrw:GoBottom(.T.)
   oCEPPXDEF:oBrw:Refresh(.T.)

   IF !File("FORMS\BRCEPPXDEF.EDT")
     oCEPPXDEF:oBrw:Move(44,0,432+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oCEPPXDEF:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oCEPPXDEF:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oCEPPXDEF:oBrw:oLbx  :=oCEPPXDEF    // MDI:GOTFOCUS()




 // Emanager no Incluye consulta de Vinculos


   IF oCEPPXDEF:lBtnNew

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XNEW.BMP";
             TOP PROMPT "Incluir";
             ACTION oCEPPXDEF:BRWADDNEWLINE()

      oBtn:cToolTip:="Incluir"

   ENDIF

   IF .F. .AND. Empty(oCEPPXDEF:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oCEPPXDEF:oBrw,oCEPPXDEF:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oCEPPXDEF:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CEPPXDEF")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CEPPXDEF"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCEPPXDEF:oBrw,"CEPPXDEF",oCEPPXDEF:cSql,oCEPPXDEF:nPeriodo,oCEPPXDEF:dDesde,oCEPPXDEF:dHasta,oCEPPXDEF)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCEPPXDEF:oBtnRun:=oBtn



       oCEPPXDEF:oBrw:bLDblClick:={||EVAL(oCEPPXDEF:oBtnRun:bAction) }


   ENDIF




IF oCEPPXDEF:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCEPPXDEF");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oCEPPXDEF:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCEPPXDEF:lBtnColor

     oCEPPXDEF:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCEPPXDEF:oBrw,oCEPPXDEF,oCEPPXDEF:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCEPPXDEF,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCEPPXDEF,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCEPPXDEF:oBtnColor:=oBtn

ENDIF

IF oCEPPXDEF:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Grabar";
             ACTION  EJECUTAR("DPBRWSAVE",oCEPPXDEF:oBrw,oCEPPXDEF:oFrm)
ENDIF

IF oCEPPXDEF:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCEPPXDEF),;
                  EJECUTAR("DPBRWMENURUN",oCEPPXDEF,oCEPPXDEF:oBrw,oCEPPXDEF:cBrwCod,oCEPPXDEF:cTitle,oCEPPXDEF:aHead));
          WHEN !Empty(oCEPPXDEF:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCEPPXDEF:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oCEPPXDEF:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCEPPXDEF:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oCEPPXDEF:oBrw,oCEPPXDEF);
          ACTION EJECUTAR("BRWSETFILTER",oCEPPXDEF:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCEPPXDEF:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oCEPPXDEF:oBrw);
          WHEN LEN(oCEPPXDEF:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCEPPXDEF:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oCEPPXDEF:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCEPPXDEF:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oCEPPXDEF)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCEPPXDEF:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oCEPPXDEF:oBrw,oCEPPXDEF:cTitle,oCEPPXDEF:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCEPPXDEF:oBtnXls:=oBtn

ENDIF

IF oCEPPXDEF:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oCEPPXDEF:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCEPPXDEF:oBrw,NIL,oCEPPXDEF:cTitle,oCEPPXDEF:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCEPPXDEF:oBtnHtml:=oBtn

ENDIF


IF oCEPPXDEF:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oCEPPXDEF:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCEPPXDEF:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCEPPXDEF")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oCEPPXDEF:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCEPPXDEF:oBtnPrint:=oBtn

   ENDIF

IF oCEPPXDEF:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oCEPPXDEF:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

  IF oCEPPXDEF:lBtnZoom

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\ZOOM.BMP";
           TOP PROMPT "Zoom";
           ACTION IF(oCEPPXDEF:oWnd:IsZoomed(),oCEPPXDEF:oWnd:Restore(),oCEPPXDEF:oWnd:Maximize())

    oBtn:cToolTip:="Maximizar"

 ENDIF





   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oCEPPXDEF:oBrw:GoTop(),oCEPPXDEF:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCEPPXDEF:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oCEPPXDEF:oBrw:PageDown(),oCEPPXDEF:oBrw:Setfocus())

  ENDIF

  IF  oCEPPXDEF:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oCEPPXDEF:oBrw:PageUp(),oCEPPXDEF:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oCEPPXDEF:oBrw:GoBottom(),oCEPPXDEF:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oCEPPXDEF:Close()

  oCEPPXDEF:oBrw:SetColor(0,oCEPPXDEF:nClrPane1)

  IF oDp:lBtnText
     oCEPPXDEF:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oCEPPXDEF:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oCEPPXDEF:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCEPPXDEF:oBar:=oBar

    nCol:=72
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
//  nCol:=32
//  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  oBar:SetSize(NIL,100,.T.)
  nLin:=70
  nCol:=15
  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oCEPPXDEF:oPeriodo  VAR oCEPPXDEF:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oCEPPXDEF:LEEFECHAS();
                WHEN oCEPPXDEF:lWhen


  ComboIni(oCEPPXDEF:oPeriodo )

  @ nLin, nCol+103 BUTTON oCEPPXDEF:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCEPPXDEF:oPeriodo:nAt,oCEPPXDEF:oDesde,oCEPPXDEF:oHasta,-1),;
                         EVAL(oCEPPXDEF:oBtn:bAction));
                WHEN oCEPPXDEF:lWhen


  @ nLin, nCol+130 BUTTON oCEPPXDEF:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCEPPXDEF:oPeriodo:nAt,oCEPPXDEF:oDesde,oCEPPXDEF:oHasta,+1),;
                         EVAL(oCEPPXDEF:oBtn:bAction));
                WHEN oCEPPXDEF:lWhen


  @ nLin, nCol+160 BMPGET oCEPPXDEF:oDesde  VAR oCEPPXDEF:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCEPPXDEF:oDesde ,oCEPPXDEF:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oCEPPXDEF:oPeriodo:nAt=LEN(oCEPPXDEF:oPeriodo:aItems) .AND. oCEPPXDEF:lWhen ;
                FONT oFont

   oCEPPXDEF:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oCEPPXDEF:oHasta  VAR oCEPPXDEF:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCEPPXDEF:oHasta,oCEPPXDEF:dHasta);
                SIZE 76-2,24;
                WHEN oCEPPXDEF:oPeriodo:nAt=LEN(oCEPPXDEF:oPeriodo:aItems) .AND. oCEPPXDEF:lWhen ;
                OF oBar;
                FONT oFont

   oCEPPXDEF:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oCEPPXDEF:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oCEPPXDEF:oPeriodo:nAt=LEN(oCEPPXDEF:oPeriodo:aItems);
               ACTION oCEPPXDEF:HACERWHERE(oCEPPXDEF:dDesde,oCEPPXDEF:dHasta,oCEPPXDEF:cWhere,.T.);
               WHEN oCEPPXDEF:lWhen

  BMPGETBTN(oBar,oFont,13)

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})



RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRCEPPXDEF",cWhere)
  oRep:cSql  :=oCEPPXDEF:cSql
  oRep:cTitle:=oCEPPXDEF:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCEPPXDEF:oPeriodo:nAt,cWhere

  oCEPPXDEF:nPeriodo:=nPeriodo


  IF oCEPPXDEF:oPeriodo:nAt=LEN(oCEPPXDEF:oPeriodo:aItems)

     oCEPPXDEF:oDesde:ForWhen(.T.)
     oCEPPXDEF:oHasta:ForWhen(.T.)
     oCEPPXDEF:oBtn  :ForWhen(.T.)

     DPFOCUS(oCEPPXDEF:oDesde)

  ELSE

     oCEPPXDEF:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCEPPXDEF:oDesde:VarPut(oCEPPXDEF:aFechas[1] , .T. )
     oCEPPXDEF:oHasta:VarPut(oCEPPXDEF:aFechas[2] , .T. )

     oCEPPXDEF:dDesde:=oCEPPXDEF:aFechas[1]
     oCEPPXDEF:dHasta:=oCEPPXDEF:aFechas[2]

     cWhere:=oCEPPXDEF:HACERWHERE(oCEPPXDEF:dDesde,oCEPPXDEF:dHasta,oCEPPXDEF:cWhere,.T.)

     oCEPPXDEF:LEERDATA(cWhere,oCEPPXDEF:oBrw,oCEPPXDEF:cServer,oCEPPXDEF)

  ENDIF

  oCEPPXDEF:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "NMFECHAS.FCH_HASTA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('NMFECHAS.FCH_HASTA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('NMFECHAS.FCH_HASTA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oCEPPXDEF:cWhereQry)
       cWhere:=cWhere + oCEPPXDEF:cWhereQry
     ENDIF

     oCEPPXDEF:LEERDATA(cWhere,oCEPPXDEF:oBrw,oCEPPXDEF:cServer,oCEPPXDEF)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCEPPXDEF)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb,oTable
   LOCAL nAt,nRowSel

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT  "+;
          " HIS_CODCON,"+;
          " CON_DESCRI,"+;
          " CYC_CODCLA"+;
          " FROM NMFECHAS    "+;
          " INNER JOIN NMRECIBOS         ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO    "+;
          " INNER JOIN NMHISTORICO       ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC    "+;
          " INNER JOIN NMCONCEPTOS       ON HIS_CODCON=CON_CODIGO"+;
          " LEFT JOIN NMCLAXCON          ON CYC_CODCON=HIS_CODCON AND LEFT(CYC_CODCLA,4)='CEPP'"+;
          " WHERE LEFT(HIS_CODCON,1)='A' AND CYC_CODCLA IS NULL"+;
          "  GROUP BY HIS_CODCON,CYC_CODCLA"+;
""

/*
   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF
*/
   IF !Empty(cWhere)
      cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)


   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRCEPPXDEF.SQL",cSql)

   // aData:=ASQL(cSql,oDb)

   oTable     :=OpenTable(cSql,.T.)
   aData      :=ACLONE(oTable:aDataFill)
   oDp:aFields:=ACLONE(oTable:aFields)
   oTable:End(.T.)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',''})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCEPPXDEF:cSql   :=cSql
      oCEPPXDEF:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:aData     :=NIL
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oCEPPXDEF:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCEPPXDEF:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCEPPXDEF.MEM",V_nPeriodo:=oCEPPXDEF:nPeriodo
  LOCAL V_dDesde:=oCEPPXDEF:dDesde
  LOCAL V_dHasta:=oCEPPXDEF:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCEPPXDEF)
RETURN .T.

/*
// Ejecución Cambio de Linea
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oCEPPXDEF")="O" .AND. oCEPPXDEF:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCEPPXDEF:cWhere_),oCEPPXDEF:cWhere_,oCEPPXDEF:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCEPPXDEF:LEERDATA(oCEPPXDEF:cWhere_,oCEPPXDEF:oBrw,oCEPPXDEF:cServer,oCEPPXDEF)
      oCEPPXDEF:oWnd:Show()
      oCEPPXDEF:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oCEPPXDEF:aHead:=EJECUTAR("HTMLHEAD",oCEPPXDEF)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCEPPXDEF)
RETURN .T.

/*
// Agrega Nueva Linea
*/
FUNCTION BRWADDNEWLINE()
  LOCAL aLine  :=ACLONE(oCEPPXDEF:oBrw:aArrayData[oCEPPXDEF:oBrw:nArrayAt])
  LOCAL nAt    :=ASCAN(oCEPPXDEF:oBrw:aArrayData,{|a,n| Empty(a[1])})

  IF nAt>0
     RETURN .F.
  ENDIF

  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(aLine[n])})

  AADD(oCEPPXDEF:oBrw:aArrayData,ACLONE(aLine))

  EJECUTAR("BRWCALTOTALES",oCEPPXDEF:oBrw,.F.)

  oCEPPXDEF:oBrw:nColSel:=1
  oCEPPXDEF:oBrw:GoBottom()
  oCEPPXDEF:oBrw:Refresh(.F.)
  oCEPPXDEF:oBrw:nArrayAt:=LEN(oCEPPXDEF:oBrw:aArrayData)
  oCEPPXDEF:aLineCopy    :=ACLONE(aLine)

  DPFOCUS(oCEPPXDEF:oBrw)

RETURN .T.

FUNCTION GRABARCLASIFICA(oCol,cCodCla,nCol)
  LOCAL aLine :=oCEPPXDEF:oBrw:aArrayData[oCEPPXDEF:oBrw:nArrayAt]
  LOCAL oTable,cCodCon:=aLine[1],lSelect:=.T.,cWhere

  DEFAULT nCol:=3

  oTable:=OpenTable("SELECT * FROM NMCLAXCON WHERE"+;
                     " CYC_CODCON"+GetWhere("=",cCodCon)+" AND "+;
                     " CYC_CODCLA"+GetWhere("=",cCodCla),.T.)
  oTable:lAuditar:=.F.

  IF lSelect .AND. oTable:RecCount()>0
     oTable:Delete(oTable:cWhere)
     oTable:End()

//     oConCla:nCuantos:=0
//     AEVAL(oConCla:oBrw:aArrayData,{|a,n| oConCla:nCuantos:=oConCla:nCuantos+IF(a[3],1,0)})
//     oBrw:aCols[1]:cFooter:= "#"+LSTR(oConCla:nCuantos)+"/"+LSTR(LEN(oConCla:oBrw:aArrayData))
//     oBrw:Refresh(.F.)

     RETURN .F.

  ENDIF

  IF oTable:RecCount()=0
     oTable:Append()
     cWhere:=""
  ELSE
     cWhere:=oTable:cWhere
  ENDIF

  oTable:Replace("CYC_CODCON",cCodCon)
  oTable:Replace("CYC_CODCLA",cCodCla)
  oTable:Commit(cWhere)
  oTable:End(.T.)

  oCEPPXDEF:oBrw:aArrayData[oCEPPXDEF:oBrw:nArrayAt,nCol]:=cCodCla
  oCEPPXDEF:oBrw:DrawLine(.T.)

RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

