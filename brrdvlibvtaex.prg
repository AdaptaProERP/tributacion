// Programa   : BRRDVLIBVTAEX
// Fecha/Hora : 04/09/2024 10:19:15
// Propósito  : "Libro de ventas exentas según resume diario"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRRDVLIBVTAEX.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aFields  :={}

   oDp:cRunServer:=NIL

   IF Type("oRDVLIBVTAEX")="O" .AND. oRDVLIBVTAEX:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oRDVLIBVTAEX,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Libro de ventas y devoluciones exentas según resumen diario" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oRDVLIBVTAEX

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oRDVLIBVTAEX","BRRDVLIBVTAEX.EDT")
// oRDVLIBVTAEX:CreateWindow(0,0,100,550)
   oRDVLIBVTAEX:Windows(0,0,aCoors[3]-160,MIN(1188,aCoors[4]-10),.T.) // Maximizado

   oRDVLIBVTAEX:cCodSuc  :=cCodSuc
   oRDVLIBVTAEX:lMsgBar  :=.F.
   oRDVLIBVTAEX:cPeriodo :=aPeriodos[nPeriodo]
   oRDVLIBVTAEX:cCodSuc  :=cCodSuc
   oRDVLIBVTAEX:nPeriodo :=nPeriodo
   oRDVLIBVTAEX:cNombre  :=""
   oRDVLIBVTAEX:dDesde   :=dDesde
   oRDVLIBVTAEX:cServer  :=cServer
   oRDVLIBVTAEX:dHasta   :=dHasta
   oRDVLIBVTAEX:cWhere   :=cWhere
   oRDVLIBVTAEX:cWhere_  :=cWhere_
   oRDVLIBVTAEX:cWhereQry:=""
   oRDVLIBVTAEX:cSql     :=oDp:cSql
   oRDVLIBVTAEX:oWhere   :=TWHERE():New(oRDVLIBVTAEX)
   oRDVLIBVTAEX:cCodPar  :=cCodPar // Código del Parámetro
   oRDVLIBVTAEX:lWhen    :=.T.
   oRDVLIBVTAEX:cTextTit :="" // Texto del Titulo Heredado
   oRDVLIBVTAEX:oDb      :=oDp:oDb
   oRDVLIBVTAEX:cBrwCod  :="RDVLIBVTAEX"
   oRDVLIBVTAEX:lTmdi    :=.T.
   oRDVLIBVTAEX:aHead    :={}
   oRDVLIBVTAEX:lBarDef  :=.T. // Activar Modo Diseño.
   oRDVLIBVTAEX:aFields  :=ACLONE(aFields)

   oRDVLIBVTAEX:nClrPane1:=oDp:nClrPane1
   oRDVLIBVTAEX:nClrPane2:=oDp:nClrPane2

   oRDVLIBVTAEX:nClrText1:=0
   oRDVLIBVTAEX:nClrText2:=255
   oRDVLIBVTAEX:nClrText3:=0
   oRDVLIBVTAEX:nClrText4:=0
   oRDVLIBVTAEX:nClrText5:=0


   AEVAL(oDp:aFields,{|a,n| oRDVLIBVTAEX:SET("COL_"+a[1],n)}) // Campos Virtuales en el Browse

   // Guarda los parámetros del Browse cuando cierra la ventana
   oRDVLIBVTAEX:bValid   :={|| EJECUTAR("BRWSAVEPAR",oRDVLIBVTAEX)}

   oRDVLIBVTAEX:lBtnRun     :=.F.
   oRDVLIBVTAEX:lBtnMenuBrw :=.F.
   oRDVLIBVTAEX:lBtnSave    :=.F.
   oRDVLIBVTAEX:lBtnCrystal :=.T.
   oRDVLIBVTAEX:lBtnRefresh :=.F.
   oRDVLIBVTAEX:lBtnHtml    :=.T.
   oRDVLIBVTAEX:lBtnExcel   :=.T.
   oRDVLIBVTAEX:lBtnPreview :=.T.
   oRDVLIBVTAEX:lBtnQuery   :=.F.
   oRDVLIBVTAEX:lBtnOptions :=.T.
   oRDVLIBVTAEX:lBtnPageDown:=.T.
   oRDVLIBVTAEX:lBtnPageUp  :=.T.
   oRDVLIBVTAEX:lBtnFilters :=.T.
   oRDVLIBVTAEX:lBtnFind    :=.T.
   oRDVLIBVTAEX:lBtnColor   :=.T.
   oRDVLIBVTAEX:lBtnZoom    :=.F.
   oRDVLIBVTAEX:lBtnNew     :=.F.


   oRDVLIBVTAEX:nClrPane1:=16771538
   oRDVLIBVTAEX:nClrPane2:=16765864

   oRDVLIBVTAEX:nClrText :=0
   oRDVLIBVTAEX:nClrText1:=0
   oRDVLIBVTAEX:nClrText2:=0
   oRDVLIBVTAEX:nClrText3:=0




   oRDVLIBVTAEX:oBrw:=TXBrowse():New( IF(oRDVLIBVTAEX:lTmdi,oRDVLIBVTAEX:oWnd,oRDVLIBVTAEX:oDlg ))
   oRDVLIBVTAEX:oBrw:SetArray( aData, .F. )
   oRDVLIBVTAEX:oBrw:SetFont(oFont)

   oRDVLIBVTAEX:oBrw:lFooter     := .T.
   oRDVLIBVTAEX:oBrw:lHScroll    := .T.
   oRDVLIBVTAEX:oBrw:nHeaderLines:= 2
   oRDVLIBVTAEX:oBrw:nDataLines  := 1
   oRDVLIBVTAEX:oBrw:nFooterLines:= 1

   oRDVLIBVTAEX:aData            :=ACLONE(aData)

   AEVAL(oRDVLIBVTAEX:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: DIA
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_DIA]
  oCol:cHeader      :='DIA'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 8
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVLIBVTAEX:oBrw:aArrayData[oRDVLIBVTAEX:oBrw:nArrayAt,oRDVLIBVTAEX:COL_DIA],;
                              oCol  := oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_DIA],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVLIBVTAEX:COL_DIA],oCol:cEditPicture)


  // Campo: DESDE
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_DESDE]
  oCol:cHeader      :='#Inicial'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: HASTA
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_HASTA]
  oCol:cHeader      :='#Final'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: SERIE
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_SERIE]
  oCol:cHeader      :='Serie'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  // Campo: RIF
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_RIF]
  oCol:cHeader      :='RIF'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: NOMBRE
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_NOMBRE]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 368

  // Campo: ZETA
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_ZETA]
  oCol:cHeader      :='#Z'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  // Campo: TIPER
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_TIPER]
  oCol:cHeader      :='Tipo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  // Campo: TRANSAC
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_TRANSAC]
  oCol:cHeader      :='Transc'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 48

  // Campo: MTOEXE
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_MTOEXE]
  oCol:cHeader      :='Monto'+CRLF+'Exento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 128
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVLIBVTAEX:oBrw:aArrayData[oRDVLIBVTAEX:oBrw:nArrayAt,oRDVLIBVTAEX:COL_MTOEXE],;
                              oCol  := oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_MTOEXE],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVLIBVTAEX:COL_MTOEXE],oCol:cEditPicture)


/*
  // Campo: IGTF
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_IGTF]
  oCol:cHeader      :='Monto'+CRLF+'IGTF'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVLIBVTAEX:oBrw:aArrayData[oRDVLIBVTAEX:oBrw:nArrayAt,oRDVLIBVTAEX:COL_IGTF],;
                              oCol  := oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_IGTF],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVLIBVTAEX:COL_IGTF],oCol:cEditPicture)
*/

  // Campo: CAJ_MTOITF
  oCol:=oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_CAJ_MTOITF]
  oCol:cHeader      :='Monto'+CRLF+'IGTF'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVLIBVTAEX:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVLIBVTAEX:oBrw:aArrayData[oRDVLIBVTAEX:oBrw:nArrayAt,oRDVLIBVTAEX:COL_CAJ_MTOITF],;
                              oCol  := oRDVLIBVTAEX:oBrw:aCols[oRDVLIBVTAEX:COL_CAJ_MTOITF],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVLIBVTAEX:COL_CAJ_MTOITF],oCol:cEditPicture)


   oRDVLIBVTAEX:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oRDVLIBVTAEX:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oRDVLIBVTAEX:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oRDVLIBVTAEX:nClrText,;
                                                 nClrText:=IF(aLine[10]<0,oRDVLIBVTAEX:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oRDVLIBVTAEX:nClrPane1, oRDVLIBVTAEX:nClrPane2 ) } }

//   oRDVLIBVTAEX:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
//   oRDVLIBVTAEX:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oRDVLIBVTAEX:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oRDVLIBVTAEX:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oRDVLIBVTAEX:oBrw:bLDblClick:={|oBrw|oRDVLIBVTAEX:RUNCLICK() }

   oRDVLIBVTAEX:oBrw:bChange:={||oRDVLIBVTAEX:BRWCHANGE()}
   oRDVLIBVTAEX:oBrw:CreateFromCode()


   oRDVLIBVTAEX:oWnd:oClient := oRDVLIBVTAEX:oBrw



   oRDVLIBVTAEX:Activate({||oRDVLIBVTAEX:ViewDatBar()})

   oRDVLIBVTAEX:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oRDVLIBVTAEX:lTmdi,oRDVLIBVTAEX:oWnd,oRDVLIBVTAEX:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oRDVLIBVTAEX:oBrw:nWidth()

   oRDVLIBVTAEX:oBrw:GoBottom(.T.)
   oRDVLIBVTAEX:oBrw:Refresh(.T.)

   IF !File("FORMS\BRRDVLIBVTAEX.EDT")
     oRDVLIBVTAEX:oBrw:Move(44,0,1188+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oRDVLIBVTAEX:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oRDVLIBVTAEX:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oRDVLIBVTAEX:oBrw:oLbx  :=oRDVLIBVTAEX    // MDI:GOTFOCUS()




 // Emanager no Incluye consulta de Vinculos


   IF oRDVLIBVTAEX:lBtnNew

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XNEW.BMP";
             TOP PROMPT "Incluir";
             ACTION oRDVLIBVTAEX:BRWADDNEWLINE()

      oBtn:cToolTip:="Incluir"

   ENDIF


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xbrowse.BMP";
            TOP PROMPT "Detalles";
            ACTION oRDVLIBVTAEX:VERDETALLES()

   oBtn:cToolTip:="Ver Detalles"

  DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Todos"},;
                                       "oRDVLIBVTAEX");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Ejecutar";
            ACTION oRDVLIBVTAEX:RDVCALCULAR()


      oBtn:cToolTip:="Opciones de Ejecucion"





   IF .F. .AND. Empty(oRDVLIBVTAEX:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oRDVLIBVTAEX:oBrw,oRDVLIBVTAEX:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oRDVLIBVTAEX:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","RDVLIBVTAEX")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","RDVLIBVTAEX"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oRDVLIBVTAEX:oBrw,"RDVLIBVTAEX",oRDVLIBVTAEX:cSql,oRDVLIBVTAEX:nPeriodo,oRDVLIBVTAEX:dDesde,oRDVLIBVTAEX:dHasta,oRDVLIBVTAEX)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oRDVLIBVTAEX:oBtnRun:=oBtn



       oRDVLIBVTAEX:oBrw:bLDblClick:={||EVAL(oRDVLIBVTAEX:oBtnRun:bAction) }


   ENDIF




IF oRDVLIBVTAEX:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oRDVLIBVTAEX");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oRDVLIBVTAEX:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oRDVLIBVTAEX:lBtnColor

     oRDVLIBVTAEX:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oRDVLIBVTAEX:oBrw,oRDVLIBVTAEX,oRDVLIBVTAEX:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oRDVLIBVTAEX,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oRDVLIBVTAEX,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oRDVLIBVTAEX:oBtnColor:=oBtn

ENDIF

IF oRDVLIBVTAEX:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Grabar";
             ACTION  EJECUTAR("DPBRWSAVE",oRDVLIBVTAEX:oBrw,oRDVLIBVTAEX:oFrm)
ENDIF

IF oRDVLIBVTAEX:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oRDVLIBVTAEX),;
                  EJECUTAR("DPBRWMENURUN",oRDVLIBVTAEX,oRDVLIBVTAEX:oBrw,oRDVLIBVTAEX:cBrwCod,oRDVLIBVTAEX:cTitle,oRDVLIBVTAEX:aHead));
          WHEN !Empty(oRDVLIBVTAEX:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oRDVLIBVTAEX:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oRDVLIBVTAEX:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oRDVLIBVTAEX:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oRDVLIBVTAEX:oBrw,oRDVLIBVTAEX);
          ACTION EJECUTAR("BRWSETFILTER",oRDVLIBVTAEX:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oRDVLIBVTAEX:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oRDVLIBVTAEX:oBrw);
          WHEN LEN(oRDVLIBVTAEX:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oRDVLIBVTAEX:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oRDVLIBVTAEX:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oRDVLIBVTAEX:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oRDVLIBVTAEX)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oRDVLIBVTAEX:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oRDVLIBVTAEX:oBrw,oRDVLIBVTAEX:cTitle,oRDVLIBVTAEX:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oRDVLIBVTAEX:oBtnXls:=oBtn

ENDIF

IF oRDVLIBVTAEX:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oRDVLIBVTAEX:HTMLHEAD(),EJECUTAR("BRWTOHTML",oRDVLIBVTAEX:oBrw,NIL,oRDVLIBVTAEX:cTitle,oRDVLIBVTAEX:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oRDVLIBVTAEX:oBtnHtml:=oBtn

ENDIF


IF oRDVLIBVTAEX:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oRDVLIBVTAEX:oBrw))

   oBtn:cToolTip:="Previsualización"

   oRDVLIBVTAEX:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRRDVLIBVTAEX")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oRDVLIBVTAEX:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oRDVLIBVTAEX:oBtnPrint:=oBtn

   ENDIF

IF oRDVLIBVTAEX:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oRDVLIBVTAEX:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

  IF oRDVLIBVTAEX:lBtnZoom

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\ZOOM.BMP";
           TOP PROMPT "Zoom";
           ACTION IF(oRDVLIBVTAEX:oWnd:IsZoomed(),oRDVLIBVTAEX:oWnd:Restore(),oRDVLIBVTAEX:oWnd:Maximize())

    oBtn:cToolTip:="Maximizar"

 ENDIF





   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oRDVLIBVTAEX:oBrw:GoTop(),oRDVLIBVTAEX:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oRDVLIBVTAEX:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oRDVLIBVTAEX:oBrw:PageDown(),oRDVLIBVTAEX:oBrw:Setfocus())

  ENDIF

  IF  oRDVLIBVTAEX:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oRDVLIBVTAEX:oBrw:PageUp(),oRDVLIBVTAEX:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oRDVLIBVTAEX:oBrw:GoBottom(),oRDVLIBVTAEX:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oRDVLIBVTAEX:Close()

  oRDVLIBVTAEX:oBrw:SetColor(0,oRDVLIBVTAEX:nClrPane1)

  IF oDp:lBtnText
     oRDVLIBVTAEX:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oRDVLIBVTAEX:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oRDVLIBVTAEX:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oRDVLIBVTAEX:oBar:=oBar

    nCol:=828
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  // nCol:=32
  // AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  oBar:SetSize(nil,100,.T.)
  nCol:=32
  nLiN:=70
  // AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  oRDVLIBVTAEX:nRecord:=0

  @ nLin,nCol+400 METER oRDVLIBVTAEX:oMeter VAR oRDVLIBVTAEX:nRecord OF oBar SIZE 150,20 PIXEL 


  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oRDVLIBVTAEX:oPeriodo  VAR oRDVLIBVTAEX:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oRDVLIBVTAEX:LEEFECHAS();
                WHEN oRDVLIBVTAEX:lWhen


  ComboIni(oRDVLIBVTAEX:oPeriodo )

  @ nLin, nCol+103 BUTTON oRDVLIBVTAEX:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oRDVLIBVTAEX:oPeriodo:nAt,oRDVLIBVTAEX:oDesde,oRDVLIBVTAEX:oHasta,-1),;
                         EVAL(oRDVLIBVTAEX:oBtn:bAction));
                WHEN oRDVLIBVTAEX:lWhen


  @ nLin, nCol+130 BUTTON oRDVLIBVTAEX:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oRDVLIBVTAEX:oPeriodo:nAt,oRDVLIBVTAEX:oDesde,oRDVLIBVTAEX:oHasta,+1),;
                         EVAL(oRDVLIBVTAEX:oBtn:bAction));
                WHEN oRDVLIBVTAEX:lWhen


  @ nLin, nCol+160 BMPGET oRDVLIBVTAEX:oDesde  VAR oRDVLIBVTAEX:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRDVLIBVTAEX:oDesde ,oRDVLIBVTAEX:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oRDVLIBVTAEX:oPeriodo:nAt=LEN(oRDVLIBVTAEX:oPeriodo:aItems) .AND. oRDVLIBVTAEX:lWhen ;
                FONT oFont

   oRDVLIBVTAEX:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oRDVLIBVTAEX:oHasta  VAR oRDVLIBVTAEX:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRDVLIBVTAEX:oHasta,oRDVLIBVTAEX:dHasta);
                SIZE 76-2,24;
                WHEN oRDVLIBVTAEX:oPeriodo:nAt=LEN(oRDVLIBVTAEX:oPeriodo:aItems) .AND. oRDVLIBVTAEX:lWhen ;
                OF oBar;
                FONT oFont

   oRDVLIBVTAEX:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oRDVLIBVTAEX:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oRDVLIBVTAEX:oPeriodo:nAt=LEN(oRDVLIBVTAEX:oPeriodo:aItems);
               ACTION oRDVLIBVTAEX:HACERWHERE(oRDVLIBVTAEX:dDesde,oRDVLIBVTAEX:dHasta,oRDVLIBVTAEX:cWhere,.T.);
               WHEN oRDVLIBVTAEX:lWhen

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

  oRep:=REPORTE("BRRDVLIBVTAEX",cWhere)
  oRep:cSql  :=oRDVLIBVTAEX:cSql
  oRep:cTitle:=oRDVLIBVTAEX:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oRDVLIBVTAEX:oPeriodo:nAt,cWhere

  oRDVLIBVTAEX:nPeriodo:=nPeriodo


  IF oRDVLIBVTAEX:oPeriodo:nAt=LEN(oRDVLIBVTAEX:oPeriodo:aItems)

     oRDVLIBVTAEX:oDesde:ForWhen(.T.)
     oRDVLIBVTAEX:oHasta:ForWhen(.T.)
     oRDVLIBVTAEX:oBtn  :ForWhen(.T.)

     DPFOCUS(oRDVLIBVTAEX:oDesde)

  ELSE

     oRDVLIBVTAEX:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oRDVLIBVTAEX:oDesde:VarPut(oRDVLIBVTAEX:aFechas[1] , .T. )
     oRDVLIBVTAEX:oHasta:VarPut(oRDVLIBVTAEX:aFechas[2] , .T. )

     oRDVLIBVTAEX:dDesde:=oRDVLIBVTAEX:aFechas[1]
     oRDVLIBVTAEX:dHasta:=oRDVLIBVTAEX:aFechas[2]

     cWhere:=oRDVLIBVTAEX:HACERWHERE(oRDVLIBVTAEX:dDesde,oRDVLIBVTAEX:dHasta,oRDVLIBVTAEX:cWhere,.T.)

     oRDVLIBVTAEX:LEERDATA(cWhere,oRDVLIBVTAEX:oBrw,oRDVLIBVTAEX:cServer,oRDVLIBVTAEX)

  ENDIF

  oRDVLIBVTAEX:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPDOCCLI.DOC_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDOCCLI.DOC_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDOCCLI.DOC_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oRDVLIBVTAEX:cWhereQry)
       cWhere:=cWhere + oRDVLIBVTAEX:cWhereQry
     ENDIF

     oRDVLIBVTAEX:LEERDATA(cWhere,oRDVLIBVTAEX:oBrw,oRDVLIBVTAEX:cServer,oRDVLIBVTAEX)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oRDVLIBVTAEX)
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
          " DAY(DOC_FECHA) AS DIA, "+;
          " DOC_PLAEXP AS DESDE, "+;
          " DOC_FACAFE AS HASTA, "+;
          " DOC_SERFIS AS SERIE, "+;
          " DOC_CODIGO AS RIF, "+;
          " CONCAT(IF(DOC_TIPDOC='RDV','VENTA','DEVOLUCION'),' MAQUINA FISCAL',' ',SFI_SERIMP) AS NOMBRE, "+;
          " DOC_GIRNUM  AS ZETA, "+;
          " 'PN' AS TIPER, "+;
          " IF(DOC_TIPDOC='RDV','01-REG','03-REG') AS TRANSAC,	 "+;
          " DOC_MTOEXE AS MTOEXE, "+;
          " CAJ_MTOITF  "+;
          " FROM DPDOCCLI  "+;
          " INNER JOIN DPTIPDOCCLI ON TDC_TIPO=DOC_TIPDOC "+;
          " LEFT JOIN DPSERIEFISCAL ON DOC_SERFIS=SFI_LETRA "+;
          " LEFT JOIN VIEW_RDCDIARIO_CAJA  ON  DOC_CODSUC=CAJ_CODSUC AND DOC_FECHA=CAJ_FECHA AND CAJ_SERFIS=DOC_SERFIS "+;
          " WHERE DOC_FACAFE<>'' AND DOC_SERFIS<>'' AND (DOC_TIPDOC='RDV' OR DOC_TIPDOC='RDD') "+;
          " ORDER BY DOC_FECHA "+;
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

   DPWRITE("TEMP\BRRDVLIBVTAEX.SQL",cSql)

   // aData:=ASQL(cSql,oDb)

   oTable     :=OpenTable(cSql,.T.)
   aData      :=ACLONE(oTable:aDataFill)
   oDp:aFields:=ACLONE(oTable:aFields)
   oTable:End(.T.)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{0,'','','','','','','','',0,0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oRDVLIBVTAEX:cSql   :=cSql
      oRDVLIBVTAEX:cWhere_:=cWhere

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
      AEVAL(oRDVLIBVTAEX:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oRDVLIBVTAEX:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRRDVLIBVTAEX.MEM",V_nPeriodo:=oRDVLIBVTAEX:nPeriodo
  LOCAL V_dDesde:=oRDVLIBVTAEX:dDesde
  LOCAL V_dHasta:=oRDVLIBVTAEX:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oRDVLIBVTAEX)
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


    IF Type("oRDVLIBVTAEX")="O" .AND. oRDVLIBVTAEX:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oRDVLIBVTAEX:cWhere_),oRDVLIBVTAEX:cWhere_,oRDVLIBVTAEX:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oRDVLIBVTAEX:LEERDATA(oRDVLIBVTAEX:cWhere_,oRDVLIBVTAEX:oBrw,oRDVLIBVTAEX:cServer,oRDVLIBVTAEX)
      oRDVLIBVTAEX:oWnd:Show()
      oRDVLIBVTAEX:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

//   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
       oRDVLIBVTAEX:RDVTODOS()
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oRDVLIBVTAEX:aHead:=EJECUTAR("HTMLHEAD",oRDVLIBVTAEX)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oRDVLIBVTAEX)
RETURN .T.

/*
// Agrega Nueva Linea
*/
FUNCTION BRWADDNEWLINE()
  LOCAL aLine  :=ACLONE(oRDVLIBVTAEX:oBrw:aArrayData[oRDVLIBVTAEX:oBrw:nArrayAt])
  LOCAL nAt    :=ASCAN(oRDVLIBVTAEX:oBrw:aArrayData,{|a,n| Empty(a[1])})

  IF nAt>0
     RETURN .F.
  ENDIF

  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(aLine[n])})

  AADD(oRDVLIBVTAEX:oBrw:aArrayData,ACLONE(aLine))

  EJECUTAR("BRWCALTOTALES",oRDVLIBVTAEX:oBrw,.F.)

  oRDVLIBVTAEX:oBrw:nColSel:=1
  oRDVLIBVTAEX:oBrw:GoBottom()
  oRDVLIBVTAEX:oBrw:Refresh(.F.)
  oRDVLIBVTAEX:oBrw:nArrayAt:=LEN(oRDVLIBVTAEX:oBrw:aArrayData)
  oRDVLIBVTAEX:aLineCopy    :=ACLONE(aLine)

  DPFOCUS(oRDVLIBVTAEX:oBrw)

RETURN .T.

FUNCTION VERDETALLES()
  LOCAL aLine  :=ACLONE(oRDVLIBVTAEX:oBrw:aArrayData[oRDVLIBVTAEX:oBrw:nArrayAt])
  LOCAL cLetra :=aLine[4]
  LOCAL cCodSuc:=SQLGET("DPSERIEFISCAL","SFI_CODSUC","SFI_LETRA"+GetWhere("=",cLetra))
  LOCAL dDesde :=CTOD(LSTR(aLine[1])+SUBS(DTOC(oRDVLIBVTAEX:dDesde),3,10))
  LOCAL dHasta :=dDesde,lZeta:=NIL,cTitle:=NIL
  LOCAL cWhere :="DOC_TIPDOC"+GetWhere("=",IF(aLine[9]='01-REG',"TIK","DEV"))+" AND DOC_SERFIS"+GetWhere("=",cLetra)

RETURN EJECUTAR("BRTICKETPOS",cWhere,cCodSuc,oDp:nDiario,dDesde,dHasta,cTitle,lZeta,cLetra)

/*
// Genera Correspondencia Masiva
*/
FUNCTION RDVCALCULAR()
  LOCAL aLine  :=ACLONE(oRDVLIBVTAEX:oBrw:aArrayData[oRDVLIBVTAEX:oBrw:nArrayAt])
  LOCAL dDesde :=CTOD(LSTR(aLine[1])+SUBS(DTOC(oRDVLIBVTAEX:dDesde),3,10))
  LOCAL dHasta :=dDesde,lZeta:=NIL,cTitle:=NIL
  LOCAL cSerie :=aLine[4]
  LOCAL cCodSuc:=SQLGET("DPSERIEFISCAL","SFI_CODSUC","SFI_LETRA"+GetWhere("=",cSerie))

  CursorWait()

  // cCodSuc,dDesde,dHasta,aTipDoc,lReset,cSerie,cZeta
  EJECUTAR("TIKTORDV",cCodSuc,dDesde,dHasta,NIL,.T.,cSerie)
  oRDVLIBVTAEX:BRWREFRESCAR()

RETURN .T.

FUNCTION RDVTODOS()
  LOCAL I,aLine,dDesde,dHasta,cSerie,cCodSuc

  CursorWait()

  oRDVLIBVTAEX:oMeter:SETTOTAL(LEN(oRDVLIBVTAEX:oBrw:aArrayData))

  FOR I=1 TO LEN(oRDVLIBVTAEX:oBrw:aArrayData)

     oRDVLIBVTAEX:oMeter:SET(I)
     CURSORWAIT()

     aLine  :=ACLONE(oRDVLIBVTAEX:oBrw:aArrayData[I])
     dDesde :=CTOD(LSTR(aLine[1])+SUBS(DTOC(oRDVLIBVTAEX:dDesde),3,10))
     dHasta :=dDesde,lZeta:=NIL,cTitle:=NIL
     cSerie :=aLine[4]
     cCodSuc:=SQLGET("DPSERIEFISCAL","SFI_CODSUC","SFI_LETRA"+GetWhere("=",cSerie))

     EJECUTAR("TIKTORDV",cCodSuc,dDesde,dHasta,NIL,.T.,cSerie)
     
  NEXT I

  oRDVLIBVTAEX:BRWREFRESCAR()
  oRDVLIBVTAEX:oMeter:SETTOTAL(0)

  CursorArrow()

RETURN .T.



/*
// Genera Correspondencia Masiva
*/


// EOF

