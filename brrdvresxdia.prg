// Programa   : BRRDVRESXDIA
// Fecha/Hora : 06/09/2024 05:11:40
// Propósito  : "Resumen de Venta Resumido por día todas las Series"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRRDVRESXDIA.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aFields  :={}

   oDp:cRunServer:=NIL

   IF Type("oRDVRESXDIA")="O" .AND. oRDVRESXDIA:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oRDVRESXDIA,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Resumen de Venta Resumido por día todas las Series para impresoras Fiscales " +IF(Empty(cTitle),"",cTitle)

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

    VALDIAXDIA(dDesde,dHasta)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

//   ENDIF

   aFields:=ACLONE(oDp:aFields) // genera los campos Virtuales

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oRDVRESXDIA

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oRDVRESXDIA","BRRDVRESXDIA.EDT")
// oRDVRESXDIA:CreateWindow(0,0,100,550)
   oRDVRESXDIA:Windows(0,0,aCoors[3]-160,MIN(2416,aCoors[4]-10),.T.) // Maximizado



   oRDVRESXDIA:cCodSuc  :=cCodSuc
   oRDVRESXDIA:lMsgBar  :=.F.
   oRDVRESXDIA:cPeriodo :=aPeriodos[nPeriodo]
   oRDVRESXDIA:cCodSuc  :=cCodSuc
   oRDVRESXDIA:nPeriodo :=nPeriodo
   oRDVRESXDIA:cNombre  :=""
   oRDVRESXDIA:dDesde   :=dDesde
   oRDVRESXDIA:cServer  :=cServer
   oRDVRESXDIA:dHasta   :=dHasta
   oRDVRESXDIA:cWhere   :=cWhere
   oRDVRESXDIA:cWhere_  :=cWhere_
   oRDVRESXDIA:cWhereQry:=""
   oRDVRESXDIA:cSql     :=oDp:cSql
   oRDVRESXDIA:oWhere   :=TWHERE():New(oRDVRESXDIA)
   oRDVRESXDIA:cCodPar  :=cCodPar // Código del Parámetro
   oRDVRESXDIA:lWhen    :=.T.
   oRDVRESXDIA:cTextTit :="" // Texto del Titulo Heredado
   oRDVRESXDIA:oDb      :=oDp:oDb
   oRDVRESXDIA:cBrwCod  :="RDVRESXDIA"
   oRDVRESXDIA:lTmdi    :=.T.
   oRDVRESXDIA:aHead    :={}
   oRDVRESXDIA:lBarDef  :=.T. // Activar Modo Diseño.
   oRDVRESXDIA:aFields  :=ACLONE(aFields)

   oRDVRESXDIA:nClrPane1:=oDp:nClrPane1
   oRDVRESXDIA:nClrPane2:=oDp:nClrPane2

   oRDVRESXDIA:nClrText1:=0
   oRDVRESXDIA:nClrText2:=0
   oRDVRESXDIA:nClrText3:=0
   oRDVRESXDIA:nClrText4:=0
   oRDVRESXDIA:nClrText5:=0


   AEVAL(oDp:aFields,{|a,n| oRDVRESXDIA:SET("COL_"+a[1],n)}) // Campos Virtuales en el Browse

   // Guarda los parámetros del Browse cuando cierra la ventana
   oRDVRESXDIA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oRDVRESXDIA)}

   oRDVRESXDIA:lBtnRun     :=.F.
   oRDVRESXDIA:lBtnMenuBrw :=.F.
   oRDVRESXDIA:lBtnSave    :=.F.
   oRDVRESXDIA:lBtnCrystal :=.F.
   oRDVRESXDIA:lBtnRefresh :=.F.
   oRDVRESXDIA:lBtnHtml    :=.T.
   oRDVRESXDIA:lBtnExcel   :=.T.
   oRDVRESXDIA:lBtnPreview :=.T.
   oRDVRESXDIA:lBtnQuery   :=.F.
   oRDVRESXDIA:lBtnOptions :=.T.
   oRDVRESXDIA:lBtnPageDown:=.T.
   oRDVRESXDIA:lBtnPageUp  :=.T.
   oRDVRESXDIA:lBtnFilters :=.T.
   oRDVRESXDIA:lBtnFind    :=.T.
   oRDVRESXDIA:lBtnColor   :=.T.
   oRDVRESXDIA:lBtnZoom    :=.F.
   oRDVRESXDIA:lBtnNew     :=.F.


   oRDVRESXDIA:nClrPane1:=16775408
   oRDVRESXDIA:nClrPane2:=16771797

   oRDVRESXDIA:nClrText :=0
   oRDVRESXDIA:nClrText1:=0
   oRDVRESXDIA:nClrText2:=0
   oRDVRESXDIA:nClrText3:=0




   oRDVRESXDIA:oBrw:=TXBrowse():New( IF(oRDVRESXDIA:lTmdi,oRDVRESXDIA:oWnd,oRDVRESXDIA:oDlg ))
   oRDVRESXDIA:oBrw:SetArray( aData, .F. )
   oRDVRESXDIA:oBrw:SetFont(oFont)

   oRDVRESXDIA:oBrw:lFooter     := .T.
   oRDVRESXDIA:oBrw:lHScroll    := .T.
   oRDVRESXDIA:oBrw:nHeaderLines:= 2
   oRDVRESXDIA:oBrw:nDataLines  := 1
   oRDVRESXDIA:oBrw:nFooterLines:= 1




   oRDVRESXDIA:aData            :=ACLONE(aData)

   AEVAL(oRDVRESXDIA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: RDV_SERFIS
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_SERFIS]
  oCol:cHeader      :='Serie'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  // Campo: SFI_IMPFIS
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_SFI_IMPFIS]
  oCol:cHeader      :='Impresora'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 72
oCol:bClrStd  := {|nClrText,uValue|uValue:=oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,2],;
                     nClrText:=COLOR_OPTIONS("DPSERIEFISCAL       ","SFI_IMPFIS",uValue),;
                     {nClrText,iif( oRDVRESXDIA:oBrw:nArrayAt%2=0, oRDVRESXDIA:nClrPane1, oRDVRESXDIA:nClrPane2 ) } } 

  // Campo: SFI_MODELO
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_SFI_MODELO]
  oCol:cHeader      :='Modelo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  // Campo: DESDE
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_DESDE]
  oCol:cHeader      :='#Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: HASTA
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_HASTA]
  oCol:cHeader      :='#Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: RDV_DESDE
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_DESDE]
  oCol:cHeader      :='Fecha'+CRLF+'Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: RDV_HASTA
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_HASTA]
  oCol:cHeader      :='Fecha'+CRLF+'Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: Z_DESDE
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_Z_DESDE]
  oCol:cHeader      :='Z'+CRLF+'Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  // Campo: Z_HASTA
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_Z_HASTA]
  oCol:cHeader      :='Z'+CRLF+'Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  // Campo: RDV_MTOEXE
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_MTOEXE]
  oCol:cHeader      :='Venta'+CRLF+'Exento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_RDV_MTOEXE],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_MTOEXE],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_RDV_MTOEXE],oCol:cEditPicture)


  // Campo: RDV_MTORD
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_MTORD]
  oCol:cHeader      :='Venta'+CRLF+'Reducida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_RDV_MTORD],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_MTORD],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_RDV_MTORD],oCol:cEditPicture)


  // Campo: RDV_MTOGN
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_MTOGN]
  oCol:cHeader      :='Venta'+CRLF+'General'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_RDV_MTOGN],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_MTOGN],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_RDV_MTOGN],oCol:cEditPicture)


  // Campo: RDV_NETO
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_NETO]
  oCol:cHeader      :='Venta'+CRLF+'Neto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_RDV_NETO],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_NETO],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_RDV_NETO],oCol:cEditPicture)


  // Campo: RDV_RECCO
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_RECCO]
  oCol:cHeader      :='#'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_RDV_RECCO],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDV_RECCO],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_RDV_RECCO],oCol:cEditPicture)


  // Campo: RDD_MTOEXE
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDD_MTOEXE]
  oCol:cHeader      :='Dev/Vta.'+CRLF+'Exento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_RDD_MTOEXE],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDD_MTOEXE],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_RDD_MTOEXE],oCol:cEditPicture)


  // Campo: RDD_MTORD
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDD_MTORD]
  oCol:cHeader      :='Dev/Vta.'+CRLF+'Reducia'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_RDD_MTORD],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDD_MTORD],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_RDD_MTORD],oCol:cEditPicture)


  // Campo: RDD_MTOGN
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDD_MTOGN]
  oCol:cHeader      :='Dev/Vta.'+CRLF+'General'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_RDD_MTOGN],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDD_MTOGN],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_RDD_MTOGN],oCol:cEditPicture)


  // Campo: RDD_NETO
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDD_NETO]
  oCol:cHeader      :='Dev/Vta.'+CRLF+'Neto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_RDD_NETO],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDD_NETO],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_RDD_NETO],oCol:cEditPicture)


  // Campo: RDD_RECCO
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDD_RECCO]
  oCol:cHeader      :='#Reg.'+CRLF+'Dev'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_RDD_RECCO],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_RDD_RECCO],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_RDD_RECCO],oCol:cEditPicture)


  // Campo: CAJ_MTODIV
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_CAJ_MTODIV]
  oCol:cHeader      :='Caja'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_CAJ_MTODIV],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_CAJ_MTODIV],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_CAJ_MTODIV],oCol:cEditPicture)


  // Campo: CAJ_MONTO
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_CAJ_MONTO]
  oCol:cHeader      :='Caja'+CRLF+'Bs'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_CAJ_MONTO],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_CAJ_MONTO],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_CAJ_MONTO],oCol:cEditPicture)


  // Campo: CAJ_MTOITF
  oCol:=oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_CAJ_MTOITF]
  oCol:cHeader      :='Monto'+CRLF+'IGTF'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRDVRESXDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt,oRDVRESXDIA:COL_CAJ_MTOITF],;
                              oCol  := oRDVRESXDIA:oBrw:aCols[oRDVRESXDIA:COL_CAJ_MTOITF],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oRDVRESXDIA:COL_CAJ_MTOITF],oCol:cEditPicture)


   oRDVRESXDIA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oRDVRESXDIA:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oRDVRESXDIA:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oRDVRESXDIA:nClrText,;
                                                 nClrText:=IF(.F.,oRDVRESXDIA:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oRDVRESXDIA:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oRDVRESXDIA:nClrPane1, oRDVRESXDIA:nClrPane2 ) } }

//   oRDVRESXDIA:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oRDVRESXDIA:oBrw:bClrFooter            := {|| {0,14671839 }}

   oRDVRESXDIA:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oRDVRESXDIA:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oRDVRESXDIA:oBrw:bLDblClick:={|oBrw|oRDVRESXDIA:RUNCLICK() }

   oRDVRESXDIA:oBrw:bChange:={||oRDVRESXDIA:BRWCHANGE()}
   oRDVRESXDIA:oBrw:CreateFromCode()


   oRDVRESXDIA:oWnd:oClient := oRDVRESXDIA:oBrw



   oRDVRESXDIA:Activate({||oRDVRESXDIA:ViewDatBar()})

   oRDVRESXDIA:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oRDVRESXDIA:lTmdi,oRDVRESXDIA:oWnd,oRDVRESXDIA:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oRDVRESXDIA:oBrw:nWidth()

   oRDVRESXDIA:oBrw:GoBottom(.T.)
   oRDVRESXDIA:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRRDVRESXDIA.EDT")
//     oRDVRESXDIA:oBrw:Move(44,0,2416+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oRDVRESXDIA:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oRDVRESXDIA:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oRDVRESXDIA:oBrw:oLbx  :=oRDVRESXDIA    // MDI:GOTFOCUS()


 // Emanager no Incluye consulta de Vinculos


   IF oRDVRESXDIA:lBtnNew

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XNEW.BMP";
             TOP PROMPT "Incluir";
             ACTION oRDVRESXDIA:BRWADDNEWLINE()

      oBtn:cToolTip:="Incluir"

   ENDIF

   DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\Librodeventa.BMP";
             TOP PROMPT "Libro/Vta";
             ACTION oRDVRESXDIA:VERLIBROVENTA()

   IF .F. .AND. Empty(oRDVRESXDIA:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oRDVRESXDIA:oBrw,oRDVRESXDIA:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XBROWSE.BMP";
            TOP PROMPT "Detalles";
            ACTION oRDVRESXDIA:VERDETALLES()

   oBtn:cToolTip:="Ver detalles"



/*
   IF Empty(oRDVRESXDIA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","RDVRESXDIA")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","RDVRESXDIA"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oRDVRESXDIA:oBrw,"RDVRESXDIA",oRDVRESXDIA:cSql,oRDVRESXDIA:nPeriodo,oRDVRESXDIA:dDesde,oRDVRESXDIA:dHasta,oRDVRESXDIA)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oRDVRESXDIA:oBtnRun:=oBtn



       oRDVRESXDIA:oBrw:bLDblClick:={||EVAL(oRDVRESXDIA:oBtnRun:bAction) }


   ENDIF




IF oRDVRESXDIA:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oRDVRESXDIA");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oRDVRESXDIA:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oRDVRESXDIA:lBtnColor

     oRDVRESXDIA:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oRDVRESXDIA:oBrw,oRDVRESXDIA,oRDVRESXDIA:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oRDVRESXDIA,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oRDVRESXDIA,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oRDVRESXDIA:oBtnColor:=oBtn

ENDIF

IF oRDVRESXDIA:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Grabar";
             ACTION  EJECUTAR("DPBRWSAVE",oRDVRESXDIA:oBrw,oRDVRESXDIA:oFrm)
ENDIF

IF oRDVRESXDIA:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oRDVRESXDIA),;
                  EJECUTAR("DPBRWMENURUN",oRDVRESXDIA,oRDVRESXDIA:oBrw,oRDVRESXDIA:cBrwCod,oRDVRESXDIA:cTitle,oRDVRESXDIA:aHead));
          WHEN !Empty(oRDVRESXDIA:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oRDVRESXDIA:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oRDVRESXDIA:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oRDVRESXDIA:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oRDVRESXDIA:oBrw,oRDVRESXDIA);
          ACTION EJECUTAR("BRWSETFILTER",oRDVRESXDIA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oRDVRESXDIA:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oRDVRESXDIA:oBrw);
          WHEN LEN(oRDVRESXDIA:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oRDVRESXDIA:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oRDVRESXDIA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oRDVRESXDIA:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oRDVRESXDIA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oRDVRESXDIA:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oRDVRESXDIA:oBrw,oRDVRESXDIA:cTitle,oRDVRESXDIA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oRDVRESXDIA:oBtnXls:=oBtn

ENDIF

IF oRDVRESXDIA:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oRDVRESXDIA:HTMLHEAD(),EJECUTAR("BRWTOHTML",oRDVRESXDIA:oBrw,NIL,oRDVRESXDIA:cTitle,oRDVRESXDIA:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oRDVRESXDIA:oBtnHtml:=oBtn

ENDIF


IF oRDVRESXDIA:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oRDVRESXDIA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oRDVRESXDIA:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRRDVRESXDIA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oRDVRESXDIA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oRDVRESXDIA:oBtnPrint:=oBtn

   ENDIF

IF oRDVRESXDIA:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oRDVRESXDIA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

  IF oRDVRESXDIA:lBtnZoom

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\ZOOM.BMP";
           TOP PROMPT "Zoom";
           ACTION IF(oRDVRESXDIA:oWnd:IsZoomed(),oRDVRESXDIA:oWnd:Restore(),oRDVRESXDIA:oWnd:Maximize())

    oBtn:cToolTip:="Maximizar"

 ENDIF





   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oRDVRESXDIA:oBrw:GoTop(),oRDVRESXDIA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oRDVRESXDIA:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oRDVRESXDIA:oBrw:PageDown(),oRDVRESXDIA:oBrw:Setfocus())

  ENDIF

  IF  oRDVRESXDIA:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oRDVRESXDIA:oBrw:PageUp(),oRDVRESXDIA:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oRDVRESXDIA:oBrw:GoBottom(),oRDVRESXDIA:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oRDVRESXDIA:Close()

  oRDVRESXDIA:oBrw:SetColor(0,oRDVRESXDIA:nClrPane1)

  IF oDp:lBtnText
     oRDVRESXDIA:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oRDVRESXDIA:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oRDVRESXDIA:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oRDVRESXDIA:oBar:=oBar

    nCol:=2056
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oRDVRESXDIA:oPeriodo  VAR oRDVRESXDIA:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oRDVRESXDIA:LEEFECHAS();
                WHEN oRDVRESXDIA:lWhen


  ComboIni(oRDVRESXDIA:oPeriodo )

  @ nLin, nCol+103 BUTTON oRDVRESXDIA:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oRDVRESXDIA:oPeriodo:nAt,oRDVRESXDIA:oDesde,oRDVRESXDIA:oHasta,-1),;
                         EVAL(oRDVRESXDIA:oBtn:bAction));
                WHEN oRDVRESXDIA:lWhen


  @ nLin, nCol+130 BUTTON oRDVRESXDIA:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oRDVRESXDIA:oPeriodo:nAt,oRDVRESXDIA:oDesde,oRDVRESXDIA:oHasta,+1),;
                         EVAL(oRDVRESXDIA:oBtn:bAction));
                WHEN oRDVRESXDIA:lWhen


  @ nLin, nCol+160 BMPGET oRDVRESXDIA:oDesde  VAR oRDVRESXDIA:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRDVRESXDIA:oDesde ,oRDVRESXDIA:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oRDVRESXDIA:oPeriodo:nAt=LEN(oRDVRESXDIA:oPeriodo:aItems) .AND. oRDVRESXDIA:lWhen ;
                FONT oFont

   oRDVRESXDIA:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oRDVRESXDIA:oHasta  VAR oRDVRESXDIA:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRDVRESXDIA:oHasta,oRDVRESXDIA:dHasta);
                SIZE 76-2,24;
                WHEN oRDVRESXDIA:oPeriodo:nAt=LEN(oRDVRESXDIA:oPeriodo:aItems) .AND. oRDVRESXDIA:lWhen ;
                OF oBar;
                FONT oFont

   oRDVRESXDIA:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oRDVRESXDIA:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oRDVRESXDIA:oPeriodo:nAt=LEN(oRDVRESXDIA:oPeriodo:aItems);
               ACTION oRDVRESXDIA:HACERWHERE(oRDVRESXDIA:dDesde,oRDVRESXDIA:dHasta,oRDVRESXDIA:cWhere,.T.);
               WHEN oRDVRESXDIA:lWhen

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

  oRep:=REPORTE("BRRDVRESXDIA",cWhere)
  oRep:cSql  :=oRDVRESXDIA:cSql
  oRep:cTitle:=oRDVRESXDIA:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oRDVRESXDIA:oPeriodo:nAt,cWhere

  oRDVRESXDIA:nPeriodo:=nPeriodo


  IF oRDVRESXDIA:oPeriodo:nAt=LEN(oRDVRESXDIA:oPeriodo:aItems)

     oRDVRESXDIA:oDesde:ForWhen(.T.)
     oRDVRESXDIA:oHasta:ForWhen(.T.)
     oRDVRESXDIA:oBtn  :ForWhen(.T.)

     DPFOCUS(oRDVRESXDIA:oDesde)

  ELSE

     oRDVRESXDIA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oRDVRESXDIA:oDesde:VarPut(oRDVRESXDIA:aFechas[1] , .T. )
     oRDVRESXDIA:oHasta:VarPut(oRDVRESXDIA:aFechas[2] , .T. )

     oRDVRESXDIA:dDesde:=oRDVRESXDIA:aFechas[1]
     oRDVRESXDIA:dHasta:=oRDVRESXDIA:aFechas[2]

     cWhere:=oRDVRESXDIA:HACERWHERE(oRDVRESXDIA:dDesde,oRDVRESXDIA:dHasta,oRDVRESXDIA:cWhere,.T.)

     oRDVRESXDIA:LEERDATA(cWhere,oRDVRESXDIA:oBrw,oRDVRESXDIA:cServer,oRDVRESXDIA)

  ENDIF

  oRDVRESXDIA:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPDIARIO.DIA_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDIARIO.DIA_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDIARIO.DIA_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oRDVRESXDIA:cWhereQry)
       cWhere:=cWhere + oRDVRESXDIA:cWhereQry
     ENDIF

     oRDVRESXDIA:LEERDATA(cWhere,oRDVRESXDIA:oBrw,oRDVRESXDIA:cServer,oRDVRESXDIA)

   ENDIF

RETURN cWhere

FUNCTION LEERDATA(cWhere,oBrw,cServer,oRDVRESXDIA)
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

   IF ValType(oRDVRESXDIA)="O"
      // oRDVRESXDIA:VALDIAXDIA(oRDVRESXDIA:dDesde,oRDVRESXDIA:dHasta)
   ENDIF

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT"+;
          " RDV_SERFIS,"+;
          " SFI_IMPFIS,"+;
          " SFI_MODELO,  "+;
          " MIN(DIA_FECHA)  AS DESDE,  "+;
          " MAX(DIA_FECHA)  AS HASTA,"+;
          " MIN(RDV_DESDE)  AS RDV_DESDE,  "+;
          " MAX(RDV_HASTA)  AS RDV_HASTA,  "+;
          " MIN(RDV_ZETA)   AS Z_DESDE,  "+;
          " MAX(RDV_ZETA)   AS Z_HASTA,  "+;
          " SUM(RDV_MTOEXE) AS RDV_MTOEXE, "+;
          " SUM(RDV_MTORD)  AS RDV_MTORD, "+;
          " SUM(RDV_MTOGN)  AS RDV_MTOGN, "+;
          " SUM(RDV_NETO)   AS RDV_NETO,  "+;
          " SUM(RDV_RECCO)  AS RDV_RECCO, "+;
          " SUM(RDD_MTOEXE) AS RDD_MTOEXE,  "+;
          " SUM(RDD_MTORD)  AS RDD_MTORD, "+;
          " SUM(RDD_MTOGN)  AS RDD_MTOGN, "+;
          " SUM(RDD_NETO)   AS RDD_NETO,  "+;
          " SUM(RDD_RECCO)  AS RDD_RECCO,   "+;
          " SUM(CAJ_MTODIV) AS CAJ_MTODIV,"+;
          " SUM(CAJ_MONTO)  AS CAJ_MONTO, "+;
          " SUM(CAJ_MTOITF) AS CAJ_MTOITF"+;
          " FROM DPDIARIO  "+;
          " LEFT JOIN VIEW_RDVMENSUAL     ON RDV_FECHA=DIA_FECHA "+;
          " LEFT JOIN VIEW_RDDMENSUAL     ON RDD_FECHA=DIA_FECHA "+;
          " LEFT JOIN VIEW_RDCDIARIO_CAJA ON CAJ_FECHA=DIA_FECHA "+;
          [ LEFT JOIN DPSERIEFISCAL       ON (RDV_SERFIS=SFI_LETRA AND SFI_IMPFIS<>"Ninguna") OR (RDD_SERFIS=SFI_LETRA AND SFI_IMPFIS<>"Ninguna")]+;
          [ WHERE 1=1  ]+;  
          [ GROUP BY RDV_SERFIS]+;
          [ ORDER BY RDV_SERFIS,DIA_FECHA ]+;
          []

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

   DPWRITE("TEMP\BRRDVRESXDIA.SQL",cSql)

   // aData:=ASQL(cSql,oDb)

   oTable     :=OpenTable(cSql,.T.)
   aData      :=ACLONE(oTable:aDataFill)
   oDp:aFields:=ACLONE(oTable:aFields)
   oTable:End(.T.)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','',CTOD(""),CTOD(""),'','','','',0,0,0,0,0,0,0,0,0,0,0,0,0})
   ENDIF

        AEVAL(aData,{|a,n|aData[n,2]:=SAYOPTIONS("DPSERIEFISCAL","SFI_IMPFIS",a[2])})

   IF ValType(oBrw)="O"

      oRDVRESXDIA:cSql   :=cSql
      oRDVRESXDIA:cWhere_:=cWhere

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
      AEVAL(oRDVRESXDIA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oRDVRESXDIA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRRDVRESXDIA.MEM",V_nPeriodo:=oRDVRESXDIA:nPeriodo
  LOCAL V_dDesde:=oRDVRESXDIA:dDesde
  LOCAL V_dHasta:=oRDVRESXDIA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oRDVRESXDIA)
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


    IF Type("oRDVRESXDIA")="O" .AND. oRDVRESXDIA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oRDVRESXDIA:cWhere_),oRDVRESXDIA:cWhere_,oRDVRESXDIA:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oRDVRESXDIA:LEERDATA(oRDVRESXDIA:cWhere_,oRDVRESXDIA:oBrw,oRDVRESXDIA:cServer,oRDVRESXDIA)
      oRDVRESXDIA:oWnd:Show()
      oRDVRESXDIA:oWnd:Restore()

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

   oRDVRESXDIA:aHead:=EJECUTAR("HTMLHEAD",oRDVRESXDIA)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oRDVRESXDIA)
RETURN .T.

/*
// Agrega Nueva Linea
*/
FUNCTION BRWADDNEWLINE()
  LOCAL aLine  :=ACLONE(oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt])
  LOCAL nAt    :=ASCAN(oRDVRESXDIA:oBrw:aArrayData,{|a,n| Empty(a[1])})

  IF nAt>0
     RETURN .F.
  ENDIF

  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(aLine[n])})

  AADD(oRDVRESXDIA:oBrw:aArrayData,ACLONE(aLine))

  EJECUTAR("BRWCALTOTALES",oRDVRESXDIA:oBrw,.F.)

  oRDVRESXDIA:oBrw:nColSel:=1
  oRDVRESXDIA:oBrw:GoBottom()
  oRDVRESXDIA:oBrw:Refresh(.F.)
  oRDVRESXDIA:oBrw:nArrayAt:=LEN(oRDVRESXDIA:oBrw:aArrayData)
  oRDVRESXDIA:aLineCopy    :=ACLONE(aLine)

  DPFOCUS(oRDVRESXDIA:oBrw)

RETURN .T.

/*
// Dia por Dia, 
*/
FUNCTION VALDIAXDIA(dDesde,dHasta)
   LOCAL cSql,oTable,cWhere:=""

   cWhere:=GetWhereOr("DOC_TIPDOC",{"TIK","DEV"})

   IF !Empty(dDesde)
      cWhere:=cWhere+" AND "+GetWhereAnd("DOC_FECHA",dDesde,dHasta)
   ENDIF

   cWhere:=cWhere+" AND RDV_FECHA IS NULL "

   cSql:=[ SELECT DOC_CODSUC,DOC_SERFIS,DOC_FECHA,RDV_FECHA,SFI_IMPFIS ]+;
         [ FROM dpdoccli ]+;
         [ INNER JOIN dpseriefiscal  ON DOC_SERFIS=SFI_LETRA AND SFI_IMPFIS<>"Ninguna" ]+;
         [ LEFT JOIN VIEW_RDVMENSUAL ON DOC_CODSUC=RDV_CODSUC AND DOC_SERFIS=RDV_SERFIS AND RDV_FECHA=DOC_FECHA  ]+;
         [ WHERE ]+cWhere+;
         [ GROUP BY DOC_CODSUC,DOC_SERFIS,DOC_FECHA ]

    oTable:=OpenTable(cSql,.T.)

    IF oTable:RecCount()>0

       MsgRun("Realizando Cierres desde "+DTOC(dDesde)+" "+DTOC(dHasta),"Por Favor Espere...")
       CursorWait()

       DbEval({||EJECUTAR("TIKTORDV",oTable:DOC_CODSUC,oTable:DOC_FECHA,oTable:DOC_FECHA,NIL,.T.,oTable:DOC_SERFIS)})
/*
       WHILE !oTable:Eof()

          MsgRun("Realizando Cierre "+DTOC(oTable:DOC_FECHA)+" Serie:"+oTable:DOC_SERFIS+" "+LSTR(oTable:Recno())+"/"+LSTR(oTable:RecCount()),"Por Favor Espere...")

          EJECUTAR("TIKTORDV",oTable:DOC_CODSUC,oTable:DOC_FECHA,oTable:DOC_FECHA,NIL,.T.,oTable:DOC_SERFIS)
         oTable:DbSkip()
       ENDDO
*/	
    ENDIF

//    ? CLPCOPY(oDp:cSql)

    oTable:End()
    CursorArrow()

RETURN NIL
/*
// Genera Correspondencia Masiva
*/

FUNCTION VERDETALLES()
  LOCAL aLine  :=ACLONE(oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt])
  LOCAL cLetra :=aLine[1],dDesde:=aLine[4],dHasta:=aLine[5],lZeta:=NIL,cTitle
  LOCAL cWhere :=NIL,cCodSuc:=SQLGET("DPSERIEFISCAL","SFI_CODSUC","SFI_LETRA"+GetWhere("=",aLine[1]))
  
RETURN EJECUTAR("BRTICKETPOS",cWhere,cCodSuc,oDp:nDiario,dDesde,dHasta,cTitle,lZeta,cLetra)

FUNCTION VERLIBROVENTA()
  LOCAL aLine  :=ACLONE(oRDVRESXDIA:oBrw:aArrayData[oRDVRESXDIA:oBrw:nArrayAt])
  LOCAL cLetra :=aLine[1],dDesde:=aLine[4],dHasta:=aLine[5],lZeta:=NIL,cTitle
  LOCAL cWhere :=NIL,cCodSuc:=SQLGET("DPSERIEFISCAL","SFI_CODSUC","SFI_LETRA"+GetWhere("=",aLine[1]))
  
RETURN EJECUTAR("BRRDVLIBVTAEX",cWhere,cCodSuc,oDp:nDiario,dDesde,dHasta,cTitle,lZeta,cLetra)
// EOF
