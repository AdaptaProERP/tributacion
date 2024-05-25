// Programa   : BRCEPPDECL
// Fecha/Hora : 23/05/2024 02:21:27
// Propósito  : "Cálculo de Contribución Especial Pensiones"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cNumReg,lFecha)
   LOCAL aData,aFechas,cFileMem:="USER\BRCEPPDECL.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aFields  :={},cTipDoc:="CEP",dFecha

   oDp:cRunServer:=NIL

   IF Type("oCEPPDECL")="O" .AND. oCEPPDECL:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCEPPDECL,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Cálculo de Contribución Especial Pensiones" +IF(Empty(cTitle),"",cTitle)

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

/*
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
*/

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

//   ENDIF


   DEFAULT cNumReg:=EJECUTAR("GETNUMPLAFISCAL",oDp:cSucursal,cTipDoc,dHasta+1)

  // ? cNumReg,dHasta

   aFields:=ACLONE(oDp:aFields) // genera los campos Virtuales

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oCEPPDECL

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DpMdi(cTitle,"oCEPPDECL","BRCEPPDECL.EDT")
// oCEPPDECL:CreateWindow(0,0,100,550)
   oCEPPDECL:Windows(0,0,aCoors[3]-160,MIN(896,aCoors[4]-10),.T.) // Maximizado



   oCEPPDECL:cCodSuc  :=cCodSuc
   oCEPPDECL:lMsgBar  :=.F.
   oCEPPDECL:cPeriodo :=aPeriodos[nPeriodo]
   oCEPPDECL:cCodSuc  :=cCodSuc
   oCEPPDECL:nPeriodo :=nPeriodo
   oCEPPDECL:cNombre  :=""
   oCEPPDECL:dDesde   :=dDesde
   oCEPPDECL:cServer  :=cServer
   oCEPPDECL:dHasta   :=dHasta
   oCEPPDECL:cWhere   :=cWhere
   oCEPPDECL:cWhere_  :=cWhere_
   oCEPPDECL:cWhereQry:=""
   oCEPPDECL:cSql     :=oDp:cSql
   oCEPPDECL:oWhere   :=TWHERE():New(oCEPPDECL)
   oCEPPDECL:cCodPar  :=cCodPar // Código del Parámetro
   oCEPPDECL:lWhen    :=.T.
   oCEPPDECL:cTextTit :="" // Texto del Titulo Heredado
   oCEPPDECL:oDb      :=oDp:oDb
   oCEPPDECL:cBrwCod  :="CEPPDECL"
   oCEPPDECL:lTmdi    :=.T.
   oCEPPDECL:aHead    :={}
   oCEPPDECL:lBarDef  :=.T. // Activar Modo Diseño.
   oCEPPDECL:aFields  :=ACLONE(aFields)
   oCEPPDECL:cNumReg  :=cNumReg
   oCEPPDECL:lFecha   :=lFecha
   oCEPPDECL:dFecha   :=SQLGET("DPDOCPROPROG","PLP_FECHA","PLP_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                          "PLP_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                                          "PLP_NUMREG"+GetWhere("=",cNumReg))
   oCEPPDECL:nClrPane1:=oDp:nClrPane1
   oCEPPDECL:nClrPane2:=oDp:nClrPane2

   oCEPPDECL:nClrText1:=0
   oCEPPDECL:nClrText2:=0
   oCEPPDECL:nClrText3:=0
   oCEPPDECL:nClrText4:=0
   oCEPPDECL:nClrText5:=0


   AEVAL(oDp:aFields,{|a,n| oCEPPDECL:SET("COL_"+a[1],n)}) // Campos Virtuales en el Browse

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCEPPDECL:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCEPPDECL)}

   oCEPPDECL:lBtnRun     :=.F.
   oCEPPDECL:lBtnMenuBrw :=.F.
   oCEPPDECL:lBtnSave    :=.F.
   oCEPPDECL:lBtnCrystal :=.F.
   oCEPPDECL:lBtnRefresh :=.F.
   oCEPPDECL:lBtnHtml    :=.T.
   oCEPPDECL:lBtnExcel   :=.T.
   oCEPPDECL:lBtnPreview :=.T.
   oCEPPDECL:lBtnQuery   :=.F.
   oCEPPDECL:lBtnOptions :=.T.
   oCEPPDECL:lBtnPageDown:=.T.
   oCEPPDECL:lBtnPageUp  :=.T.
   oCEPPDECL:lBtnFilters :=.T.
   oCEPPDECL:lBtnFind    :=.T.
   oCEPPDECL:lBtnColor   :=.T.
   oCEPPDECL:lBtnZoom    :=.F.
   oCEPPDECL:lBtnNew     :=.F.


   oCEPPDECL:nClrPane1:=16775408
   oCEPPDECL:nClrPane2:=16771797

   oCEPPDECL:nClrText :=0
   oCEPPDECL:nClrText1:=0
   oCEPPDECL:nClrText2:=0
   oCEPPDECL:nClrText3:=0




   oCEPPDECL:oBrw:=TXBrowse():New( IF(oCEPPDECL:lTmdi,oCEPPDECL:oWnd,oCEPPDECL:oDlg ))
   oCEPPDECL:oBrw:SetArray( aData, .F. )
   oCEPPDECL:oBrw:SetFont(oFont)

   oCEPPDECL:oBrw:lFooter     := .T.
   oCEPPDECL:oBrw:lHScroll    := .T.
   oCEPPDECL:oBrw:nHeaderLines:= 2
   oCEPPDECL:oBrw:nDataLines  := 1
   oCEPPDECL:oBrw:nFooterLines:= 1




   oCEPPDECL:aData            :=ACLONE(aData)

   AEVAL(oCEPPDECL:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: CYC_CODCLA
  oCol:=oCEPPDECL:oBrw:aCols[oCEPPDECL:COL_CYC_CODCLA]
  oCol:cHeader      :='Clasificación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPDECL:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  // Campo: CLA_DESCRI
  oCol:=oCEPPDECL:oBrw:aCols[oCEPPDECL:COL_CLA_DESCRI]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPDECL:oBrw:aArrayData ) } 
  oCol:nWidth       := 360

  // Campo: SUM(HIS_MONTO)
  oCol:=oCEPPDECL:oBrw:aCols[3]
  oCol:cHeader      :='Monto'+CRLF+'Asignaciones'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPDECL:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCEPPDECL:oBrw:aArrayData[oCEPPDECL:oBrw:nArrayAt,3],;
                              oCol  := oCEPPDECL:oBrw:aCols[3],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[3],oCol:cEditPicture)


  // Campo: MONTOCEPP
  oCol:=oCEPPDECL:oBrw:aCols[oCEPPDECL:COL_MONTOCEPP]
  oCol:cHeader      :='Monto'+CRLF+'Pagar'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPDECL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCEPPDECL:oBrw:aArrayData[oCEPPDECL:oBrw:nArrayAt,oCEPPDECL:COL_MONTOCEPP],;
                              oCol  := oCEPPDECL:oBrw:aCols[oCEPPDECL:COL_MONTOCEPP],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oCEPPDECL:COL_MONTOCEPP],oCol:cEditPicture)


  // Campo: CUANTOS
  oCol:=oCEPPDECL:oBrw:aCols[oCEPPDECL:COL_CUANTOS]
  oCol:cHeader      :='Cant.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCEPPDECL:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCEPPDECL:oBrw:aArrayData[oCEPPDECL:oBrw:nArrayAt,oCEPPDECL:COL_CUANTOS],;
                              oCol  := oCEPPDECL:oBrw:aCols[oCEPPDECL:COL_CUANTOS],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oCEPPDECL:COL_CUANTOS],oCol:cEditPicture)


   oCEPPDECL:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCEPPDECL:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCEPPDECL:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCEPPDECL:nClrText,;
                                                 nClrText:=IF(.F.,oCEPPDECL:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCEPPDECL:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCEPPDECL:nClrPane1, oCEPPDECL:nClrPane2 ) } }

//   oCEPPDECL:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCEPPDECL:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCEPPDECL:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCEPPDECL:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCEPPDECL:oBrw:bLDblClick:={|oBrw|oCEPPDECL:RUNCLICK() }

   oCEPPDECL:oBrw:bChange:={||oCEPPDECL:BRWCHANGE()}
   oCEPPDECL:oBrw:CreateFromCode()


   oCEPPDECL:oWnd:oClient := oCEPPDECL:oBrw

   oCEPPDECL:Activate({||oCEPPDECL:ViewDatBar()})

   oCEPPDECL:oPeriodo:ForWhen(.T.)

   oCEPPDECL:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCEPPDECL:lTmdi,oCEPPDECL:oWnd,oCEPPDECL:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCEPPDECL:oBrw:nWidth()

   oCEPPDECL:oBrw:GoBottom(.T.)
   oCEPPDECL:oBrw:Refresh(.T.)

   IF !File("FORMS\BRCEPPDECL.EDT")
     oCEPPDECL:oBrw:Move(44,0,896+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oCEPPDECL:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oCEPPDECL:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oCEPPDECL:oBrw:oLbx  :=oCEPPDECL    // MDI:GOTFOCUS()




 // Emanager no Incluye consulta de Vinculos

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\XSAVE.BMP";
           TOP PROMPT "Guardar";
           ACTION oCEPPDECL:GRABAR_CEPP()

    oBtn:cToolTip:="Incluir"



   IF oCEPPDECL:lBtnNew

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XNEW.BMP";
             TOP PROMPT "Incluir";
             ACTION oCEPPDECL:BRWADDNEWLINE()

      oBtn:cToolTip:="Incluir"

   ENDIF

   IF .F. .AND. Empty(oCEPPDECL:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oCEPPDECL:oBrw,oCEPPDECL:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oCEPPDECL:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CEPPDECL")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CEPPDECL"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCEPPDECL:oBrw,"CEPPDECL",oCEPPDECL:cSql,oCEPPDECL:nPeriodo,oCEPPDECL:dDesde,oCEPPDECL:dHasta,oCEPPDECL)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCEPPDECL:oBtnRun:=oBtn



       oCEPPDECL:oBrw:bLDblClick:={||EVAL(oCEPPDECL:oBtnRun:bAction) }


   ENDIF




IF oCEPPDECL:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCEPPDECL");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oCEPPDECL:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCEPPDECL:lBtnColor

     oCEPPDECL:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCEPPDECL:oBrw,oCEPPDECL,oCEPPDECL:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCEPPDECL,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCEPPDECL,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCEPPDECL:oBtnColor:=oBtn

ENDIF

IF oCEPPDECL:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Grabar";
             ACTION  EJECUTAR("DPBRWSAVE",oCEPPDECL:oBrw,oCEPPDECL:oFrm)
ENDIF

IF oCEPPDECL:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCEPPDECL),;
                  EJECUTAR("DPBRWMENURUN",oCEPPDECL,oCEPPDECL:oBrw,oCEPPDECL:cBrwCod,oCEPPDECL:cTitle,oCEPPDECL:aHead));
          WHEN !Empty(oCEPPDECL:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCEPPDECL:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oCEPPDECL:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCEPPDECL:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oCEPPDECL:oBrw,oCEPPDECL);
          ACTION EJECUTAR("BRWSETFILTER",oCEPPDECL:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCEPPDECL:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oCEPPDECL:oBrw);
          WHEN LEN(oCEPPDECL:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCEPPDECL:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oCEPPDECL:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCEPPDECL:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oCEPPDECL)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCEPPDECL:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oCEPPDECL:oBrw,oCEPPDECL:cTitle,oCEPPDECL:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCEPPDECL:oBtnXls:=oBtn

ENDIF

IF oCEPPDECL:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oCEPPDECL:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCEPPDECL:oBrw,NIL,oCEPPDECL:cTitle,oCEPPDECL:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCEPPDECL:oBtnHtml:=oBtn

ENDIF


IF oCEPPDECL:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oCEPPDECL:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCEPPDECL:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCEPPDECL")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oCEPPDECL:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCEPPDECL:oBtnPrint:=oBtn

   ENDIF

IF oCEPPDECL:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oCEPPDECL:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

  IF oCEPPDECL:lBtnZoom

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\ZOOM.BMP";
           TOP PROMPT "Zoom";
           ACTION IF(oCEPPDECL:oWnd:IsZoomed(),oCEPPDECL:oWnd:Restore(),oCEPPDECL:oWnd:Maximize())

    oBtn:cToolTip:="Maximizar"

 ENDIF





   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oCEPPDECL:oBrw:GoTop(),oCEPPDECL:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCEPPDECL:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oCEPPDECL:oBrw:PageDown(),oCEPPDECL:oBrw:Setfocus())

  ENDIF

  IF  oCEPPDECL:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oCEPPDECL:oBrw:PageUp(),oCEPPDECL:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oCEPPDECL:oBrw:GoBottom(),oCEPPDECL:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oCEPPDECL:Close()

  oCEPPDECL:oBrw:SetColor(0,oCEPPDECL:nClrPane1)

  IF oDp:lBtnText
     oCEPPDECL:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oCEPPDECL:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oCEPPDECL:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCEPPDECL:oBar:=oBar

  oBar:SetSize(0,100,.T.)

  nCol:=15
  nLin:=70

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oCEPPDECL:oPeriodo  VAR oCEPPDECL:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oCEPPDECL:LEEFECHAS();
                WHEN oCEPPDECL:lWhen .AND. .F.


  ComboIni(oCEPPDECL:oPeriodo )

  @ nLin, nCol+103 BUTTON oCEPPDECL:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCEPPDECL:oPeriodo:nAt,oCEPPDECL:oDesde,oCEPPDECL:oHasta,-1),;
                         EVAL(oCEPPDECL:oBtn:bAction));
                WHEN oCEPPDECL:lWhen


  @ nLin, nCol+130 BUTTON oCEPPDECL:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCEPPDECL:oPeriodo:nAt,oCEPPDECL:oDesde,oCEPPDECL:oHasta,+1),;
                         EVAL(oCEPPDECL:oBtn:bAction));
                WHEN oCEPPDECL:lWhen


  @ nLin, nCol+160 BMPGET oCEPPDECL:oDesde  VAR oCEPPDECL:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCEPPDECL:oDesde ,oCEPPDECL:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oCEPPDECL:oPeriodo:nAt=LEN(oCEPPDECL:oPeriodo:aItems) .AND. oCEPPDECL:lWhen ;
                FONT oFont

   oCEPPDECL:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oCEPPDECL:oHasta  VAR oCEPPDECL:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCEPPDECL:oHasta,oCEPPDECL:dHasta);
                SIZE 76-2,24;
                WHEN oCEPPDECL:oPeriodo:nAt=LEN(oCEPPDECL:oPeriodo:aItems) .AND. oCEPPDECL:lWhen ;
                OF oBar;
                FONT oFont

   oCEPPDECL:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oCEPPDECL:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oCEPPDECL:oPeriodo:nAt=LEN(oCEPPDECL:oPeriodo:aItems);
               ACTION oCEPPDECL:HACERWHERE(oCEPPDECL:dDesde,oCEPPDECL:dHasta,oCEPPDECL:cWhere,.T.);
               WHEN oCEPPDECL:lWhen .AND. .F.

  BMPGETBTN(oBar,oFont,13)

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

IF !Empty(oCEPPDECL:cNumReg)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD UNDERLINE

  @ nLin,nCol+400 SAYREF oCEPPDECL:oNumReg PROMPT " #Planificación "+oCEPPDECL:cNumReg+" " OF oBar;
                  SIZE 190,20 ;
                  PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont 

  IF !oCEPPDECL:oNumReg=NIL
     SayAction(oCEPPDECL:oNumReg,{||oCEPPDECL:VERREGPLA()})
  ENDIF

  @ nLin,nCol+620 SAYREF oCEPPDECL:oFecha PROMPT " Fecha Pago "+DTOC(oCEPPDECL:dFecha)+" " OF oBar;
                  SIZE 190,20 ;
                  PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont 

  SayAction(oCEPPDECL:oFecha,{||oCEPPDECL:VERREGPLA()})

ENDIF

//  @ nLin, nCol+500 SAY oCEPPDECL:cNumReg OF oBar FONT oFont BORDER PIXEL


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

  oRep:=REPORTE("BRCEPPDECL",cWhere)
  oRep:cSql  :=oCEPPDECL:cSql
  oRep:cTitle:=oCEPPDECL:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCEPPDECL:oPeriodo:nAt,cWhere

  oCEPPDECL:nPeriodo:=nPeriodo


  IF oCEPPDECL:oPeriodo:nAt=LEN(oCEPPDECL:oPeriodo:aItems)

     oCEPPDECL:oDesde:ForWhen(.T.)
     oCEPPDECL:oHasta:ForWhen(.T.)
     oCEPPDECL:oBtn  :ForWhen(.T.)

     DPFOCUS(oCEPPDECL:oDesde)

  ELSE

     oCEPPDECL:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCEPPDECL:oDesde:VarPut(oCEPPDECL:aFechas[1] , .T. )
     oCEPPDECL:oHasta:VarPut(oCEPPDECL:aFechas[2] , .T. )

     oCEPPDECL:dDesde:=oCEPPDECL:aFechas[1]
     oCEPPDECL:dHasta:=oCEPPDECL:aFechas[2]

     cWhere:=oCEPPDECL:HACERWHERE(oCEPPDECL:dDesde,oCEPPDECL:dHasta,oCEPPDECL:cWhere,.T.)

     oCEPPDECL:LEERDATA(cWhere,oCEPPDECL:oBrw,oCEPPDECL:cServer,oCEPPDECL)

  ENDIF

  oCEPPDECL:SAVEPERIODO()

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

     IF !Empty(oCEPPDECL:cWhereQry)
       cWhere:=cWhere + oCEPPDECL:cWhereQry
     ENDIF

     oCEPPDECL:LEERDATA(cWhere,oCEPPDECL:oBrw,oCEPPDECL:cServer,oCEPPDECL)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCEPPDECL)
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

   cSql:=" SELECT   "+;
          " CYC_CODCLA, "+;
          " CLA_DESCRI, "+;
          " SUM(HIS_MONTO), "+;
          " SUM(HIS_MONTO*9/100) AS MONTOCEPP,"+;
          " COUNT(*) AS CUANTOS "+;
          " FROM NMFECHAS     "+;
          " INNER JOIN NMRECIBOS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO     "+;
          " INNER JOIN NMHISTORICO   ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC     "+;
          " INNER JOIN NMCLAXCON     ON CYC_CODCON=HIS_CODCON AND LEFT(CYC_CODCLA,4)='CEPP' "+;
          " INNER JOIN NMCLACON      ON CLA_CODIGO=CYC_CODCLA "+;
          " WHERE LEFT(HIS_CODCON,1)='A'  "+;
          " GROUP BY CYC_CODCLA  "+;
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


   oDp:lExcluye:=.F.

   DPWRITE("TEMP\BRCEPPDECL.SQL",cSql)

   // aData:=ASQL(cSql,oDb)

   oTable     :=OpenTable(cSql,.T.)
   aData      :=ACLONE(oTable:aDataFill)
   oDp:aFields:=ACLONE(oTable:aFields)
   oTable:End(.T.)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',0,0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCEPPDECL:cSql   :=cSql
      oCEPPDECL:cWhere_:=cWhere

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
      AEVAL(oCEPPDECL:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCEPPDECL:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCEPPDECL.MEM",V_nPeriodo:=oCEPPDECL:nPeriodo
  LOCAL V_dDesde:=oCEPPDECL:dDesde
  LOCAL V_dHasta:=oCEPPDECL:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCEPPDECL)
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


    IF Type("oCEPPDECL")="O" .AND. oCEPPDECL:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCEPPDECL:cWhere_),oCEPPDECL:cWhere_,oCEPPDECL:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCEPPDECL:LEERDATA(oCEPPDECL:cWhere_,oCEPPDECL:oBrw,oCEPPDECL:cServer,oCEPPDECL)
      oCEPPDECL:oWnd:Show()
      oCEPPDECL:oWnd:Restore()

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

   oCEPPDECL:aHead:=EJECUTAR("HTMLHEAD",oCEPPDECL)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCEPPDECL)
RETURN .T.

/*
// Agrega Nueva Linea
*/
FUNCTION BRWADDNEWLINE()
  LOCAL aLine  :=ACLONE(oCEPPDECL:oBrw:aArrayData[oCEPPDECL:oBrw:nArrayAt])
  LOCAL nAt    :=ASCAN(oCEPPDECL:oBrw:aArrayData,{|a,n| Empty(a[1])})

  IF nAt>0
     RETURN .F.
  ENDIF

  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(aLine[n])})

  AADD(oCEPPDECL:oBrw:aArrayData,ACLONE(aLine))

  EJECUTAR("BRWCALTOTALES",oCEPPDECL:oBrw,.F.)

  oCEPPDECL:oBrw:nColSel:=1
  oCEPPDECL:oBrw:GoBottom()
  oCEPPDECL:oBrw:Refresh(.F.)
  oCEPPDECL:oBrw:nArrayAt:=LEN(oCEPPDECL:oBrw:aArrayData)
  oCEPPDECL:aLineCopy    :=ACLONE(aLine)

  DPFOCUS(oCEPPDECL:oBrw)

RETURN .T.

FUNCTION GRABAR_CEPP()
    LOCAL aTotal:=ATOTALES(oCEPPDECL:oBrw:aArrayData)
    LOCAL nTotal:=aTotal[4]
    LOCAL cCodigo:=EJECUTAR("GETCODSENIAT")

    IF !MsgNoYes("Desea Registrar Documento por Pagar"+CRLF+"Monto "+ALLTRIM(FDP(nTotal,"99,999,999,999.99")))
       RETURN .T.
    ENDIF

    CursorWait()

    EJECUTAR("DPDOCPROPROGUP",oCEPPDECL:cCodSuc,NIL,"CEP",oCEPPDECL:cNumReg,nTotal,DPFECHA(),0)

    EJECUTAR("DPDOCPROPENDTE",cCodigo,"DOC_TIPDOC"+GetWhere("=","CEP"))

RETURN .T.

/*
// Genera Correspondencia Masiva
*/

FUNCTION VERREGPLA()
   LOCAL cWhere:="PLP_TIPDOC"+GetWhere("=","CEP")+" AND PLP_NUMREG"+GetWhere("=",oCEPPDECL:cNumReg)
   LOCAL cTitle:=NIL,lData:=NIL

RETURN EJECUTAR("BRCALFISDET",cWhere,oDp:cSucursal,11,CTOD(""),CTOD(""),cTitle,lData)


// EOF

