// Programa   : BRCEPPRECXTRAB
// Fecha/Hora : 10/06/2024 18:07:53
// Propósito  : "Recibo por Trabajador Especial Pensiones"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodTra)
   LOCAL aData,aFechas,cFileMem:="USER\BRCEPPRECXTRAB.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aFields  :={}

   oDp:cRunServer:=NIL

   IF Type("oCEPPRECXTRAB")="O" .AND. oCEPPRECXTRAB:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCEPPRECXTRAB,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Recibo por Trabajador Especial Pensiones" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oCEPPRECXTRAB

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oCEPPRECXTRAB","BRCEPPRECXTRAB.EDT")
// oCEPPRECXTRAB:CreateWindow(0,0,100,550)
   oCEPPRECXTRAB:Windows(0,0,aCoors[3]-160,MIN(1012,aCoors[4]-10),.T.) // Maximizado



   oCEPPRECXTRAB:cCodSuc  :=cCodSuc
   oCEPPRECXTRAB:lMsgBar  :=.F.
   oCEPPRECXTRAB:cPeriodo :=aPeriodos[nPeriodo]
   oCEPPRECXTRAB:cCodSuc  :=cCodSuc
   oCEPPRECXTRAB:nPeriodo :=nPeriodo
   oCEPPRECXTRAB:cNombre  :=""
   oCEPPRECXTRAB:dDesde   :=dDesde
   oCEPPRECXTRAB:cServer  :=cServer
   oCEPPRECXTRAB:dHasta   :=dHasta
   oCEPPRECXTRAB:cWhere   :=cWhere
   oCEPPRECXTRAB:cWhere_  :=cWhere_
   oCEPPRECXTRAB:cWhereQry:=""
   oCEPPRECXTRAB:cSql     :=oDp:cSql
   oCEPPRECXTRAB:oWhere   :=TWHERE():New(oCEPPRECXTRAB)
   oCEPPRECXTRAB:cCodPar  :=cCodPar // Código del Parámetro
   oCEPPRECXTRAB:lWhen    :=.T.
   oCEPPRECXTRAB:cTextTit :="" // Texto del Titulo Heredado
   oCEPPRECXTRAB:oDb      :=oDp:oDb
   oCEPPRECXTRAB:cBrwCod  :="CEPPRECXTRAB"
   oCEPPRECXTRAB:lTmdi    :=.T.
   oCEPPRECXTRAB:aHead    :={}
   oCEPPRECXTRAB:lBarDef  :=.T. // Activar Modo Diseño.
   oCEPPRECXTRAB:aFields  :=ACLONE(aFields)

   oCEPPRECXTRAB:nClrPane1:=oDp:nClrPane1
   oCEPPRECXTRAB:nClrPane2:=oDp:nClrPane2

   oCEPPRECXTRAB:nClrText1:=0
   oCEPPRECXTRAB:nClrText2:=0
   oCEPPRECXTRAB:nClrText3:=0
   oCEPPRECXTRAB:nClrText4:=0
   oCEPPRECXTRAB:nClrText5:=0


   AEVAL(oDp:aFields,{|a,n| oCEPPRECXTRAB:SET("COL_"+a[1],n)}) // Campos Virtuales en el Browse

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCEPPRECXTRAB:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCEPPRECXTRAB)}

   oCEPPRECXTRAB:lBtnRun     :=.F.
   oCEPPRECXTRAB:lBtnMenuBrw :=.F.
   oCEPPRECXTRAB:lBtnSave    :=.F.
   oCEPPRECXTRAB:lBtnCrystal :=.F.
   oCEPPRECXTRAB:lBtnRefresh :=.F.
   oCEPPRECXTRAB:lBtnHtml    :=.T.
   oCEPPRECXTRAB:lBtnExcel   :=.T.
   oCEPPRECXTRAB:lBtnPreview :=.T.
   oCEPPRECXTRAB:lBtnQuery   :=.F.
   oCEPPRECXTRAB:lBtnOptions :=.T.
   oCEPPRECXTRAB:lBtnPageDown:=.T.
   oCEPPRECXTRAB:lBtnPageUp  :=.T.
   oCEPPRECXTRAB:lBtnFilters :=.T.
   oCEPPRECXTRAB:lBtnFind    :=.T.
   oCEPPRECXTRAB:lBtnColor   :=.T.
   oCEPPRECXTRAB:lBtnZoom    :=.F.
   oCEPPRECXTRAB:lBtnNew     :=.F.


   oCEPPRECXTRAB:nClrPane1:=16775408
   oCEPPRECXTRAB:nClrPane2:=16771797

   oCEPPRECXTRAB:nClrText :=0
   oCEPPRECXTRAB:nClrText1:=0
   oCEPPRECXTRAB:nClrText2:=0
   oCEPPRECXTRAB:nClrText3:=0

   oCEPPRECXTRAB:oBrw:=TXBrowse():New( IF(oCEPPRECXTRAB:lTmdi,oCEPPRECXTRAB:oWnd,oCEPPRECXTRAB:oDlg ))
   oCEPPRECXTRAB:oBrw:SetArray( aData, .F. )
   oCEPPRECXTRAB:oBrw:SetFont(oFont)

   oCEPPRECXTRAB:oBrw:lFooter     := .T.
   oCEPPRECXTRAB:oBrw:lHScroll    := .T.
   oCEPPRECXTRAB:oBrw:nHeaderLines:= 2
   oCEPPRECXTRAB:oBrw:nDataLines  := 1
   oCEPPRECXTRAB:oBrw:nFooterLines:= 1


   oCEPPRECXTRAB:aData            :=ACLONE(aData)

   AEVAL(oCEPPRECXTRAB:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

 

  // Campo: HIS_CODCON
  oCol:=oCEPPRECXTRAB:oBrw:aCols[oCEPPRECXTRAB:COL_HIS_CODCON]
  oCol:cHeader      :='Cód.'+CRLF+'Con.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPRECXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 32

  // Campo: CON_DESCRI
  oCol:=oCEPPRECXTRAB:oBrw:aCols[oCEPPRECXTRAB:COL_CON_DESCRI]
  oCol:cHeader      :='Descripción del Concepto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPRECXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 280

  // Campo: CYC_CODCLA
  oCol:=oCEPPRECXTRAB:oBrw:aCols[oCEPPRECXTRAB:COL_CYC_CODCLA]
  oCol:cHeader      :='Clasificación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPRECXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  // Campo: CLA_DESCRI
  oCol:=oCEPPRECXTRAB:oBrw:aCols[oCEPPRECXTRAB:COL_CLA_DESCRI]
  oCol:cHeader      :='Descripción de la Clasificación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPRECXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 280

  // Campo: HIS_MTODIV
  oCol:=oCEPPRECXTRAB:oBrw:aCols[oCEPPRECXTRAB:COL_HIS_MTODIV]
  oCol:cHeader      :='Monto'+CRLF+'Asignación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPRECXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCEPPRECXTRAB:oBrw:aArrayData[oCEPPRECXTRAB:oBrw:nArrayAt,oCEPPRECXTRAB:COL_HIS_MTODIV],;
                              oCol  := oCEPPRECXTRAB:oBrw:aCols[oCEPPRECXTRAB:COL_HIS_MTODIV],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oCEPPRECXTRAB:COL_HIS_MTODIV],oCol:cEditPicture)


  // Campo: MONTOCEPP
  oCol:=oCEPPRECXTRAB:oBrw:aCols[oCEPPRECXTRAB:COL_MONTOCEPP]
  oCol:cHeader      :='Monto'+CRLF+'CEPP'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPRECXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCEPPRECXTRAB:oBrw:aArrayData[oCEPPRECXTRAB:oBrw:nArrayAt,oCEPPRECXTRAB:COL_MONTOCEPP],;
                              oCol  := oCEPPRECXTRAB:oBrw:aCols[oCEPPRECXTRAB:COL_MONTOCEPP],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oCEPPRECXTRAB:COL_MONTOCEPP],oCol:cEditPicture)


   oCEPPRECXTRAB:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCEPPRECXTRAB:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCEPPRECXTRAB:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCEPPRECXTRAB:nClrText,;
                                                 nClrText:=IF(.F.,oCEPPRECXTRAB:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCEPPRECXTRAB:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCEPPRECXTRAB:nClrPane1, oCEPPRECXTRAB:nClrPane2 ) } }

//   oCEPPRECXTRAB:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCEPPRECXTRAB:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCEPPRECXTRAB:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCEPPRECXTRAB:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCEPPRECXTRAB:oBrw:bLDblClick:={|oBrw|oCEPPRECXTRAB:RUNCLICK() }

   oCEPPRECXTRAB:oBrw:bChange:={||oCEPPRECXTRAB:BRWCHANGE()}
   oCEPPRECXTRAB:oBrw:CreateFromCode()


   oCEPPRECXTRAB:oWnd:oClient := oCEPPRECXTRAB:oBrw



   oCEPPRECXTRAB:Activate({||oCEPPRECXTRAB:ViewDatBar()})

   oCEPPRECXTRAB:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCEPPRECXTRAB:lTmdi,oCEPPRECXTRAB:oWnd,oCEPPRECXTRAB:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCEPPRECXTRAB:oBrw:nWidth()

   oCEPPRECXTRAB:oBrw:GoBottom(.T.)
   oCEPPRECXTRAB:oBrw:Refresh(.T.)

   IF !File("FORMS\BRCEPPRECXTRAB.EDT")
     oCEPPRECXTRAB:oBrw:Move(44,0,1012+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oCEPPRECXTRAB:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oCEPPRECXTRAB:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oCEPPRECXTRAB:oBrw:oLbx  :=oCEPPRECXTRAB    // MDI:GOTFOCUS()




 // Emanager no Incluye consulta de Vinculos


   IF oCEPPRECXTRAB:lBtnNew

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XNEW.BMP";
             TOP PROMPT "Incluir";
             ACTION oCEPPRECXTRAB:BRWADDNEWLINE()

      oBtn:cToolTip:="Incluir"

   ENDIF

   IF .F. .AND. Empty(oCEPPRECXTRAB:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oCEPPRECXTRAB:oBrw,oCEPPRECXTRAB:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oCEPPRECXTRAB:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CEPPRECXTRAB")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CEPPRECXTRAB"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCEPPRECXTRAB:oBrw,"CEPPRECXTRAB",oCEPPRECXTRAB:cSql,oCEPPRECXTRAB:nPeriodo,oCEPPRECXTRAB:dDesde,oCEPPRECXTRAB:dHasta,oCEPPRECXTRAB)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCEPPRECXTRAB:oBtnRun:=oBtn



       oCEPPRECXTRAB:oBrw:bLDblClick:={||EVAL(oCEPPRECXTRAB:oBtnRun:bAction) }


   ENDIF




IF oCEPPRECXTRAB:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCEPPRECXTRAB");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oCEPPRECXTRAB:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCEPPRECXTRAB:lBtnColor

     oCEPPRECXTRAB:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCEPPRECXTRAB:oBrw,oCEPPRECXTRAB,oCEPPRECXTRAB:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCEPPRECXTRAB,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCEPPRECXTRAB,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCEPPRECXTRAB:oBtnColor:=oBtn

ENDIF

IF oCEPPRECXTRAB:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Grabar";
             ACTION  EJECUTAR("DPBRWSAVE",oCEPPRECXTRAB:oBrw,oCEPPRECXTRAB:oFrm)
ENDIF

IF oCEPPRECXTRAB:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCEPPRECXTRAB),;
                  EJECUTAR("DPBRWMENURUN",oCEPPRECXTRAB,oCEPPRECXTRAB:oBrw,oCEPPRECXTRAB:cBrwCod,oCEPPRECXTRAB:cTitle,oCEPPRECXTRAB:aHead));
          WHEN !Empty(oCEPPRECXTRAB:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCEPPRECXTRAB:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oCEPPRECXTRAB:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCEPPRECXTRAB:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oCEPPRECXTRAB:oBrw,oCEPPRECXTRAB);
          ACTION EJECUTAR("BRWSETFILTER",oCEPPRECXTRAB:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCEPPRECXTRAB:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oCEPPRECXTRAB:oBrw);
          WHEN LEN(oCEPPRECXTRAB:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCEPPRECXTRAB:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oCEPPRECXTRAB:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCEPPRECXTRAB:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oCEPPRECXTRAB)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCEPPRECXTRAB:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oCEPPRECXTRAB:oBrw,oCEPPRECXTRAB:cTitle,oCEPPRECXTRAB:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCEPPRECXTRAB:oBtnXls:=oBtn

ENDIF

IF oCEPPRECXTRAB:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oCEPPRECXTRAB:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCEPPRECXTRAB:oBrw,NIL,oCEPPRECXTRAB:cTitle,oCEPPRECXTRAB:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCEPPRECXTRAB:oBtnHtml:=oBtn

ENDIF


IF oCEPPRECXTRAB:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oCEPPRECXTRAB:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCEPPRECXTRAB:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCEPPRECXTRAB")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oCEPPRECXTRAB:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCEPPRECXTRAB:oBtnPrint:=oBtn

   ENDIF

IF oCEPPRECXTRAB:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oCEPPRECXTRAB:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

  IF oCEPPRECXTRAB:lBtnZoom

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\ZOOM.BMP";
           TOP PROMPT "Zoom";
           ACTION IF(oCEPPRECXTRAB:oWnd:IsZoomed(),oCEPPRECXTRAB:oWnd:Restore(),oCEPPRECXTRAB:oWnd:Maximize())

    oBtn:cToolTip:="Maximizar"

 ENDIF





   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oCEPPRECXTRAB:oBrw:GoTop(),oCEPPRECXTRAB:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCEPPRECXTRAB:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oCEPPRECXTRAB:oBrw:PageDown(),oCEPPRECXTRAB:oBrw:Setfocus())

  ENDIF

  IF  oCEPPRECXTRAB:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oCEPPRECXTRAB:oBrw:PageUp(),oCEPPRECXTRAB:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oCEPPRECXTRAB:oBrw:GoBottom(),oCEPPRECXTRAB:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oCEPPRECXTRAB:Close()

  oCEPPRECXTRAB:oBrw:SetColor(0,oCEPPRECXTRAB:nClrPane1)

  IF oDp:lBtnText
     oCEPPRECXTRAB:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oCEPPRECXTRAB:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oCEPPRECXTRAB:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCEPPRECXTRAB:oBar:=oBar

  oBar:SetSize(NIL,100,.T.)

  nLin:=75 // 652
  nCol:=15

  // AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oCEPPRECXTRAB:oPeriodo  VAR oCEPPRECXTRAB:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oCEPPRECXTRAB:LEEFECHAS();
                WHEN oCEPPRECXTRAB:lWhen


  ComboIni(oCEPPRECXTRAB:oPeriodo )

  @ nLin, nCol+103 BUTTON oCEPPRECXTRAB:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCEPPRECXTRAB:oPeriodo:nAt,oCEPPRECXTRAB:oDesde,oCEPPRECXTRAB:oHasta,-1),;
                         EVAL(oCEPPRECXTRAB:oBtn:bAction));
                WHEN oCEPPRECXTRAB:lWhen


  @ nLin, nCol+130 BUTTON oCEPPRECXTRAB:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCEPPRECXTRAB:oPeriodo:nAt,oCEPPRECXTRAB:oDesde,oCEPPRECXTRAB:oHasta,+1),;
                         EVAL(oCEPPRECXTRAB:oBtn:bAction));
                WHEN oCEPPRECXTRAB:lWhen


  @ nLin, nCol+160 BMPGET oCEPPRECXTRAB:oDesde  VAR oCEPPRECXTRAB:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCEPPRECXTRAB:oDesde ,oCEPPRECXTRAB:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oCEPPRECXTRAB:oPeriodo:nAt=LEN(oCEPPRECXTRAB:oPeriodo:aItems) .AND. oCEPPRECXTRAB:lWhen ;
                FONT oFont

   oCEPPRECXTRAB:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oCEPPRECXTRAB:oHasta  VAR oCEPPRECXTRAB:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCEPPRECXTRAB:oHasta,oCEPPRECXTRAB:dHasta);
                SIZE 76-2,24;
                WHEN oCEPPRECXTRAB:oPeriodo:nAt=LEN(oCEPPRECXTRAB:oPeriodo:aItems) .AND. oCEPPRECXTRAB:lWhen ;
                OF oBar;
                FONT oFont

   oCEPPRECXTRAB:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oCEPPRECXTRAB:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oCEPPRECXTRAB:oPeriodo:nAt=LEN(oCEPPRECXTRAB:oPeriodo:aItems);
               ACTION oCEPPRECXTRAB:HACERWHERE(oCEPPRECXTRAB:dDesde,oCEPPRECXTRAB:dHasta,oCEPPRECXTRAB:cWhere,.T.);
               WHEN oCEPPRECXTRAB:lWhen

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

  oRep:=REPORTE("BRCEPPRECXTRAB",cWhere)
  oRep:cSql  :=oCEPPRECXTRAB:cSql
  oRep:cTitle:=oCEPPRECXTRAB:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCEPPRECXTRAB:oPeriodo:nAt,cWhere

  oCEPPRECXTRAB:nPeriodo:=nPeriodo


  IF oCEPPRECXTRAB:oPeriodo:nAt=LEN(oCEPPRECXTRAB:oPeriodo:aItems)

     oCEPPRECXTRAB:oDesde:ForWhen(.T.)
     oCEPPRECXTRAB:oHasta:ForWhen(.T.)
     oCEPPRECXTRAB:oBtn  :ForWhen(.T.)

     DPFOCUS(oCEPPRECXTRAB:oDesde)

  ELSE

     oCEPPRECXTRAB:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCEPPRECXTRAB:oDesde:VarPut(oCEPPRECXTRAB:aFechas[1] , .T. )
     oCEPPRECXTRAB:oHasta:VarPut(oCEPPRECXTRAB:aFechas[2] , .T. )

     oCEPPRECXTRAB:dDesde:=oCEPPRECXTRAB:aFechas[1]
     oCEPPRECXTRAB:dHasta:=oCEPPRECXTRAB:aFechas[2]

     cWhere:=oCEPPRECXTRAB:HACERWHERE(oCEPPRECXTRAB:dDesde,oCEPPRECXTRAB:dHasta,oCEPPRECXTRAB:cWhere,.T.)

     oCEPPRECXTRAB:LEERDATA(cWhere,oCEPPRECXTRAB:oBrw,oCEPPRECXTRAB:cServer,oCEPPRECXTRAB)

  ENDIF

  oCEPPRECXTRAB:SAVEPERIODO()

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

     IF !Empty(oCEPPRECXTRAB:cWhereQry)
       cWhere:=cWhere + oCEPPRECXTRAB:cWhereQry
     ENDIF

     oCEPPRECXTRAB:LEERDATA(cWhere,oCEPPRECXTRAB:oBrw,oCEPPRECXTRAB:cServer,oCEPPRECXTRAB)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCEPPRECXTRAB)
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
          " HIS_CODCON,  "+;
          " CON_DESCRI,"+;
          " CYC_CODCLA, "+;
          " CLA_DESCRI,  "+;
          " SUM(HIS_MONTO/FCH_VALCAM) AS HIS_MTODIV,  "+;
          " SUM((HIS_MONTO/FCH_VALCAM)*9/100) AS MONTOCEPP"+;
          " FROM NMFECHAS      "+;
          " INNER JOIN NMRECIBOS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO      "+;
          " INNER JOIN NMHISTORICO   ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC      "+;
          " INNER JOIN NMCONCEPTOS   ON HIS_CODCON=CON_CODIGO"+;
          " LEFT JOIN NMCLAXCON      ON CYC_CODCON=HIS_CODCON AND LEFT(CYC_CODCLA,4)='CEPP'  "+;
          " LEFT JOIN NMCLACON       ON CLA_CODIGO=CYC_CODCLA  "+;
          " WHERE LEFT(HIS_CODCON,1)='A'    "+;
          " GROUP BY HIS_CODCON,CYC_CODCLA  "+;
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

   DPWRITE("TEMP\BRCEPPRECXTRAB.SQL",cSql)

   // aData:=ASQL(cSql,oDb)

   oTable     :=OpenTable(cSql,.T.)
   aData      :=ACLONE(oTable:aDataFill)
   oDp:aFields:=ACLONE(oTable:aFields)
   oTable:End(.T.)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','',0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCEPPRECXTRAB:cSql   :=cSql
      oCEPPRECXTRAB:cWhere_:=cWhere

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
      AEVAL(oCEPPRECXTRAB:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCEPPRECXTRAB:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCEPPRECXTRAB.MEM",V_nPeriodo:=oCEPPRECXTRAB:nPeriodo
  LOCAL V_dDesde:=oCEPPRECXTRAB:dDesde
  LOCAL V_dHasta:=oCEPPRECXTRAB:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCEPPRECXTRAB)
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


    IF Type("oCEPPRECXTRAB")="O" .AND. oCEPPRECXTRAB:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCEPPRECXTRAB:cWhere_),oCEPPRECXTRAB:cWhere_,oCEPPRECXTRAB:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCEPPRECXTRAB:LEERDATA(oCEPPRECXTRAB:cWhere_,oCEPPRECXTRAB:oBrw,oCEPPRECXTRAB:cServer,oCEPPRECXTRAB)
      oCEPPRECXTRAB:oWnd:Show()
      oCEPPRECXTRAB:oWnd:Restore()

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

   oCEPPRECXTRAB:aHead:=EJECUTAR("HTMLHEAD",oCEPPRECXTRAB)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCEPPRECXTRAB)
RETURN .T.

/*
// Agrega Nueva Linea
*/
FUNCTION BRWADDNEWLINE()
  LOCAL aLine  :=ACLONE(oCEPPRECXTRAB:oBrw:aArrayData[oCEPPRECXTRAB:oBrw:nArrayAt])
  LOCAL nAt    :=ASCAN(oCEPPRECXTRAB:oBrw:aArrayData,{|a,n| Empty(a[1])})

  IF nAt>0
     RETURN .F.
  ENDIF

  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(aLine[n])})

  AADD(oCEPPRECXTRAB:oBrw:aArrayData,ACLONE(aLine))

  EJECUTAR("BRWCALTOTALES",oCEPPRECXTRAB:oBrw,.F.)

  oCEPPRECXTRAB:oBrw:nColSel:=1
  oCEPPRECXTRAB:oBrw:GoBottom()
  oCEPPRECXTRAB:oBrw:Refresh(.F.)
  oCEPPRECXTRAB:oBrw:nArrayAt:=LEN(oCEPPRECXTRAB:oBrw:aArrayData)
  oCEPPRECXTRAB:aLineCopy    :=ACLONE(aLine)

  DPFOCUS(oCEPPRECXTRAB:oBrw)

RETURN .T.


/*
// Genera Correspondencia Masiva
*/


// EOF

