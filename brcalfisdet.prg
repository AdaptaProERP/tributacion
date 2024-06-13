// Programa   : BRCALFISDET
// Fecha/Hora : 14/01/2015 06:29:45
// Propósito  : "Detalle del Calendario Fiscal"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,lData,cCodPro)
   LOCAL aData,aFechas,cFileMem:="USER\BRCALFISDET.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aOptions:={},I
   LOCAL aProvee :={}

   oDp:cRunServer:=NIL

   IF Type("oCALFISDET")="O" .AND. oCALFISDET:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCALFISDET,GetScript())
   ENDIF

   DEFAULT lData:=.F.

   EJECUTAR("DPDOCPROPROGFIX")
   EJECUTAR("GETOPRIF")

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

//cTitle:="Detalle del Calendario Fiscal de Pagos y Obligaciones , SUC:"+cCodSuc +IF(Empty(cTitle),"",cTitle)
//cTitle:="Detalle del Calendario Fiscal y Obligaciones " +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   // Cada Empresa debe generar su Calendario fiscal   

   DEFAULT cCodSuc:=oDp:cSucursal 

   IF VALTYPE(cCodSuc)<>"C" .AND. ISSQLFIND("DPSUCURSAL","SUC_CODIGO"+GetWhere("=",oDp:cSucMain)) .AND.;
                                  SQLGET("DPSUCURSAL","SUC_ACTIVO","SUC_CODIGO"+GetWhere("=",oDp:cSucMain))
      cCodSuc:=oDp:cSucMain
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucMain,;
           nPeriodo:=10,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")

   DEFAULT cWhere  :="PLP_CODSUC"+GetWhere("=",cCodSuc)


   IF !Empty(oDp:dFchInCalF)
     cWhere:=cWhere + IF(Empty(cWhere),""," AND ")+"PLP_FECHA"+GetWhere(">=",oDp:dFchInCalF)
   ENDIF

   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)
 
      cCodPar:=ATAIL(_VECTOR(cWhere,"="))
 
      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   // 15/08/2023 Asume el ejercicio actual
   IF nPeriodo=oDp:nEjercicio 
      dDesde :=IF(Empty(dDesde),oDp:dFchInicio,dDesde)
      aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,dDesde,dDesde)
      dDesde :=aFechas[1]
      dHasta :=aFechas[2]
   ENDIF

   IF (!nPeriodo=oDp:nIndicada) .AND. (Empty(dDesde) .OR. Empty(dhasta))
      aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
      dDesde :=aFechas[1]
      dHasta :=aFechas[2]
   ENDIF

   cTitle:=IF(ISPCPRG(),oDp:cSys+" ","")+"Detalle del Calendario Fiscal de Pagos y Obligaciones , SUC:"+cCodSuc +IF(Empty(cTitle),"",cTitle)

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   IF (Empty(aData) .OR. Empty(aData[1,1])) 

      // 28/12/2023 MsgRun("Generando Calendario Fiscal","por favor Espere..",{||EJECUTAR("DPGENCALFISCSV")})
      EJECUTAR("CREARCALFIS")

      aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

      IF (Empty(aData) .OR. Empty(aData[1,1])) 
         MsgMemo("No fué Generado Calendario Fiscal Periodo "+DTOC(dDesde)+" - "+DTOC(dhasta)+CRLF+"Acceda al formulario Configurar Empresa y defina los parámetros"+CRLF+"Sucursal "+cCodSuc,"Pais :"+oDp:cCountry)
         EJECUTAR("DPLOADCNF")
         EJECUTAR("DPCONFIG")
      ENDIF

   ENDIF

   IF lData
      RETURN aData
   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   FOR I=1 TO LEN(aData)
     IF ASCAN(aOptions,aData[I,10])=0
       AADD(aOptions,aData[I,10])
     ENDIF
   NEXT I

   ADEPURA(aOptions,{|a,n| Empty(a)})

   AADD(aOptions,"Todos")

//   AEVAL(aData,{|a,n| AADD(aProvee,a[21+1])})
// ViewArray(aData)
// ViewArray(aProvee)
// aProvee:=EJECUTAR("AUNIQUE",aProvee)
// ViewArray(aProvee)
   aData  :=EJECUTAR("ADATASUBTOTAL",aData,2,.F.)
 
   ViewData(aData,cTitle)

   oDp:oFrm:=oCALFISDET
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oCALFISDET","BRCALFISDET.EDT")

   oCALFISDET:Windows(0,0,aCoors[3]-150,aCoors[4],.T.) // Maximizado

   oCALFISDET:cCodSuc  :=cCodSuc
   oCALFISDET:lMsgBar  :=.F.
   oCALFISDET:cPeriodo :=aPeriodos[nPeriodo]
   oCALFISDET:cCodSuc  :=cCodSuc
   oCALFISDET:nPeriodo :=nPeriodo
   oCALFISDET:cNombre  :="RIF="+oDp:cRif
   oCALFISDET:dDesde   :=dDesde
   oCALFISDET:cServer  :=cServer
   oCALFISDET:dHasta   :=dHasta
   oCALFISDET:cWhere   :=cWhere
   oCALFISDET:cWhere_  :=""
   oCALFISDET:cWhereQry:=""
   oCALFISDET:cSql     :=oDp:cSql
   oCALFISDET:oWhere   :=TWHERE():New(oCALFISDET)
   oCALFISDET:cCodPar  :=cCodPar // Código del Parámetro
   oCALFISDET:aOptions :=aOptions
   oCALFISDET:cCodPro  :=cCodPro
   oCALFISDET:aColors  :=ASQL("SELECT TDC_TIPO,TDC_CLRGRA FROM DPTIPDOCCLI WHERE TDC_CLRGRA>0")
   oCALFISDET:SetScript("BRCALFISDET")

   oCALFISDET:oBrw:=TXBrowse():New( oCALFISDET:oWnd )
   oCALFISDET:oBrw:SetArray( aData, .F. )
   oCALFISDET:oBrw:SetFont(oFont)

   oCALFISDET:oBrw:lFooter     := .T.
   oCALFISDET:oBrw:lHScroll    := .T.
   oCALFISDET:oBrw:nHeaderLines:= 2
   oCALFISDET:oBrw:nDataLines  := 1
   oCALFISDET:oBrw:nFooterLines:= 1

   oCALFISDET:aData            :=ACLONE(aData)
  oCALFISDET:nClrText :=0
  oCALFISDET:nClrPane1:=16774120
  oCALFISDET:nClrPane2:=16771797

   AEVAL(oCALFISDET:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oCol:=oCALFISDET:oBrw:aCols[1]
  oCol:cHeader      :='Fecha'+CRLF+'Actividad'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oCALFISDET:oBrw:aCols[2]
  oCol:cHeader      :='Mes'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 32

  oCol:=oCALFISDET:oBrw:aCols[3]
  oCol:cHeader      :='Día'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 32

  oCol:=oCALFISDET:oBrw:aCols[4]
  oCol:cHeader      :='Tipo'+CRLF+'Doc.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 35

  oCol:bClrStd      := {|oBrw,nClrText,aData|oBrw:=oCALFISDET:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                       nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                       nClrText:=IF(aData[23]>0 .AND. nClrText=0,aData[23],oBrw:aArrayData[oBrw:nArrayAt,17]),;
                                      {nClrText,iif( oBrw:nArrayAt%2=0, oCALFISDET:nClrPane1, oCALFISDET:nClrPane2 ) } }


  oCol:=oCALFISDET:oBrw:aCols[5]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 170


  oCol:bClrStd      := {|oBrw,nClrText,aData|oBrw:=oCALFISDET:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                       nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                       nClrText:=IF(aData[23]>0 .AND. nClrText=0,aData[23],oBrw:aArrayData[oBrw:nArrayAt,17]),;
                                      {nClrText,iif( oBrw:nArrayAt%2=0, oCALFISDET:nClrPane1, oCALFISDET:nClrPane2 ) } }

  oCol:=oCALFISDET:oBrw:aCols[6]
  oCol:cHeader      :='Referencia'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:bClrStd      := {|oBrw,nClrText,aData|oBrw:=oCALFISDET:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                       nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                       nClrText:=IF(aData[23]>0 .AND. nClrText=0,aData[23],oBrw:aArrayData[oBrw:nArrayAt,17]),;
                                      {nClrText,iif( oBrw:nArrayAt%2=0, oCALFISDET:nClrPane1, oCALFISDET:nClrPane2 ) } }



  oCol:=oCALFISDET:oBrw:aCols[7]
  oCol:cHeader      :='Fecha'+CRLF+'Registro'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 70


  oCol:=oCALFISDET:oBrw:aCols[8]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
//  oCol:bStrData     :={|nMonto|nMonto:= oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,8],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[8],'9,999,999,999,999.99')

  oCol:cEditPicture :='9,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,8],;
                              oCol   := oCALFISDET:oBrw:aCols[8],;
                              FDP(nMonto,oCol:cEditPicture)}


  oCol:=oCALFISDET:oBrw:aCols[9]
  oCol:cHeader      :='Dias'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,9],FDP(nMonto,'9999999')}
//oCol:cFooter      :=FDP(aTotal[9],'9999')

  oCol:=oCALFISDET:oBrw:aCols[10]
  oCol:cHeader      :='Estatus'+CRLF+'Registro'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       :=90

  oCol:=oCALFISDET:oBrw:aCols[11]
  oCol:cHeader      :='Fecha'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oCALFISDET:oBrw:aCols[12]
  oCol:cHeader      :='Dias'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,12],FDP(nMonto,'9999')}
//  oCol:cFooter      :=FDP(aTotal[12],'9999')


  oCol:=oCALFISDET:oBrw:aCols[13]
  oCol:cHeader      :='Estatus'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 65

  oCol:=oCALFISDET:oBrw:aCols[14]
  oCol:cHeader      :='Cbte.'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 60
/*
  oCol:=oCALFISDET:oBrw:aCols[15]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData     :={|nMonto|nMonto:= oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,15],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[15],'999,999,999.99')
*/

  oCol:=oCALFISDET:oBrw:aCols[15]
  oCol:cHeader      :='Cbte.'+CRLF+'Contable'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oCALFISDET:oBrw:aCols[16]
  oCol:cHeader      :='Dias'+CRLF+'x Transc'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,16],FDP(nMonto,'9999')}


  oCALFISDET:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))


  oCol:=oCALFISDET:oBrw:aCols[17]
  oCol:cHeader      :='Color'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oCALFISDET:oBrw:aCols[18]
  oCol:cHeader      :='Código'+CRLF+'CxP'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oCALFISDET:oBrw:aCols[19]
  oCol:cHeader      :='Número'+CRLF+'Documento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oCALFISDET:oBrw:aCols[20]
  oCol:cHeader      :='Código'+CRLF+'Planif.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 65

  oCol:=oCALFISDET:oBrw:aCols[21]
  oCol:cHeader      :='Número'+CRLF+'Planificación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 240


  oCol:=oCALFISDET:oBrw:aCols[22]
  oCol:cHeader      :='Institución'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 300


  oCol:=oCALFISDET:oBrw:aCols[23]
  oCol:cHeader      :='Color'+CRLF+'Tipo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,23],FDP(nMonto,'9999999')}

  oCol:=oCALFISDET:oBrw:aCols[24]
  oCol:cHeader      :='Monto'+CRLF+'Calculado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,24],;
                              oCol   := oCALFISDET:oBrw:aCols[24],;
                              FDP(nMonto,oCol:cEditPicture)}


  oCol:=oCALFISDET:oBrw:aCols[25]
  oCol:cHeader      :='Valor'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :=oDp:cPictValCam
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,25],;
                              oCol   := oCALFISDET:oBrw:aCols[25],;
                              FDP(nMonto,oCol:cEditPicture)}

  oCol:=oCALFISDET:oBrw:aCols[26]
  oCol:cHeader      :='Monto'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCALFISDET:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,26],;
                              oCol   := oCALFISDET:oBrw:aCols[26],;
                              FDP(nMonto,oCol:cEditPicture)}
 oCol:cFooter      :=FDP(aTotal[26],'9,999,999,999,999.99')






/*
  oCALFISDET:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oCALFISDET:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                          nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                         {nClrText,iif( oBrw:nArrayAt%2=0, oCALFISDET:nClrPane1, oCALFISDET:nClrPane2 ) } }
*/

  oCALFISDET:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oCALFISDET:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                          nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                         {nClrText,iif( oBrw:nArrayAt%2=0, oCALFISDET:nClrPane1, oCALFISDET:nClrPane2 ) } }


//  oCALFISDET:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
//  oCALFISDET:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oCALFISDET:oBrw:bClrFooter     := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oCALFISDET:oBrw:bClrHeader     := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oCALFISDET:oBrw:bLDblClick:={|oBrw|oCALFISDET:oRep:=oCALFISDET:RUNCLICK() }

  oCALFISDET:oBrw:bChange:={||oCALFISDET:BRWCHANGE()}

//  oCALFISDET:oBrw:aCols[23]:Hide()

  oCALFISDET:oBrw:CreateFromCode()

//? LEN(oCALFISDET:oBrw:aCols)

  oCALFISDET:oBrw:aCols[17]:lHide:=.T. // DelCol(17)
// oCALFISDET:oBrw:aCols[23]:lHide:=.T. // DelCol(22)
// oCALFISDET:oBrw:aCols[23]:Hide()

  oCALFISDET:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCALFISDET)}

  EJECUTAR("BRWRESTOREPAR",oCALFISDET)

/*
  FOR I=8 TO 22
    oCALFISDET:oBrw:DelCol(6)
  NEXT I
*/
  oCALFISDET:oWnd:oClient := oCALFISDET:oBrw

  oCALFISDET:Activate({||oCALFISDET:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oCALFISDET:oWnd
   LOCAL nLin:=0

   oCALFISDET:oBrw:GoBottom(.T.)
   oCALFISDET:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 


   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oCALFISDET:oFontBtn   :=oFont    
   oCALFISDET:nClrPaneBar:=oDp:nGris
   oCALFISDET:oBrw:oLbx  :=oCALFISDET

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          TOP PROMPT "Ejecutar"; 
          ACTION oCALFISDET:RUNCALFISCAL()

   oBtn:cToolTip:="Ejecutar"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\SENIAT.BMP";
          TOP PROMPT "SENIAT"; 
          ACTION oCALFISDET:CALFISSENIAT()

   oBtn:cToolTip:="SENIAT"
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\MATH.BMP";
          TOP PROMPT "Sub-Total"; 
          ACTION EJECUTAR("BRSUBTOTAL",oCALFISDET:oBrw,2,NIL,.F.)

   oBtn:cToolTip:="Incluir Sub-Total"
*/


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PROVEEDORES.BMP";
          TOP PROMPT "X Inst."; 
          ACTION EJECUTAR("BRCALFISRESINST",NIL,oCALFISDET:cCodSuc,oCALFISDET:nPeriodo,oCALFISDET:dDesde,oCALFISDET:dHasta)

   oBtn:cToolTip:="Por Institución"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP",NIL,"BITMAPS\XBROWSEG.BMP";
          WHEN ISRELEASE("18.12");
          TOP PROMPT "Anual"; 
          ACTION  oCALFISDET:RUNCALANUAL()

   oBtn:cToolTip:="Visualizar Calendario Anual"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSEFECHA.BMP";
          TOP PROMPT "Mensual"; 
          ACTION EJECUTAR("FRMCALFISCAL",oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt,1],oCALFISDET:cCodPro)

   oBtn:cToolTip:="Mensual"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CALENDAR.BMP";
          TOP PROMPT "Directo"; 
          ACTION oCALFISDET:RUNCALFISCAL(.T.)

   oBtn:cToolTip:="Ejecutar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\MOVIE.BMP";
          TOP PROMPT "Video"; 
          ACTION EJECUTAR("WEBRUN","https://youtu.be/oopV0SRzJDM?t=387",.F.)

   oBtn:cToolTip:="Ejecutar Video"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom"; 
          ACTION IF(oCALFISDET:oWnd:IsZoomed(),oCALFISDET:oWnd:Restore(),oCALFISDET:oWnd:Maximize())

   oBtn:cToolTip:="Maximizar"



/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CALENDAR.BMP";
          ACTION oCALFISDET:RUNCALFISCAL(.T.)

   oBtn:cToolTip:="Según Fecha"

*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CBTEPAGO.BMP";
          TOP PROMPT "Pagar"; 
          ACTION oCALFISDET:PAGAR()

   oBtn:cToolTip:="Ejecutar Pago"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION  EJECUTAR("BRWSETFIND",oCALFISDET:oBrw)

   oBtn:cToolTip:="Buscar"

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
            TOP PROMPT "Filtrar"; 
              ACTION  EJECUTAR("BRWSETFILTER",oCALFISDET:oBrw)
*/


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oCALFISDET:oBrw,oCALFISDET);
          TOP PROMPT "Filtrar"; 
          ACTION EJECUTAR("BRWSETFILTER",oCALFISDET:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
            TOP PROMPT "Opciones"; 
              ACTION  EJECUTAR("BRWSETOPTIONS",oCALFISDET:oBrw);
          WHEN LEN(oCALFISDET:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
            TOP PROMPT "Refrescar"; 
              ACTION  oCALFISDET:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
            TOP PROMPT "Crystal"; 
              ACTION  EJECUTAR("BRWTODBF",oCALFISDET)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
              ACTION  (EJECUTAR("BRWTOEXCEL",oCALFISDET:oBrw,oCALFISDET:cTitle,oCALFISDET:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   oCALFISDET:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (EJECUTAR("BRWTOHTML",oCALFISDET:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oCALFISDET:oBtnHtml:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
            TOP PROMPT "Preview"; 
              ACTION  (EJECUTAR("BRWPREVIEW",oCALFISDET:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCALFISDET:oBtnPreview:=oBtn

/*
   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCALFISDET")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
              TOP PROMPT "Imprimir"; 
              ACTION  oCALFISDET:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCALFISDET:oBtnPrint:=oBtn

   ENDIF
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oCALFISDET:oBrw:GoTop(),oCALFISDET:oBrw:Setfocus())
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
              ACTION  (oCALFISDET:oBrw:PageDown(),oCALFISDET:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oCALFISDET:oBrw:PageUp(),oCALFISDET:oBrw:Setfocus())

*/

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oCALFISDET:oBrw:GoBottom(),oCALFISDET:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
              ACTION  oCALFISDET:Close()

  oCALFISDET:oBrw:SetColor(0,oCALFISDET:nClrPane1)

  EVAL(oCALFISDET:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCALFISDET:oBar:=oBar

  // nLin:=338+200+30+40+40
//  nLin:=32
//  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  nLin:=420
  //
  // Campo : Periodo
  //

  @ 10+60, nLin COMBOBOX oCALFISDET:oPeriodo  VAR oCALFISDET:cPeriodo ITEMS aPeriodos;
                SIZE 80,140;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oCALFISDET:LEEFECHAS()
  ComboIni(oCALFISDET:oPeriodo )

  @ 10+60, nLin+103-15 BUTTON oCALFISDET:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCALFISDET:oPeriodo:nAt,oCALFISDET:oDesde,oCALFISDET:oHasta,-1),;
                         EVAL(oCALFISDET:oBtn:bAction))



  @ 10+60, nLin+130-15 BUTTON oCALFISDET:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCALFISDET:oPeriodo:nAt,oCALFISDET:oDesde,oCALFISDET:oHasta,+1),;
                         EVAL(oCALFISDET:oBtn:bAction))


  @ 10+60, nLin+170-15 BMPGET oCALFISDET:oDesde  VAR oCALFISDET:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCALFISDET:oDesde ,oCALFISDET:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oCALFISDET:oPeriodo:nAt=LEN(oCALFISDET:oPeriodo:aItems);
                FONT oFont

   oCALFISDET:oDesde:cToolTip:="F6: Calendario"

  @ 10+60, nLin+252-15 BMPGET oCALFISDET:oHasta  VAR oCALFISDET:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCALFISDET:oHasta,oCALFISDET:dHasta);
                SIZE 80,23;
                WHEN oCALFISDET:oPeriodo:nAt=LEN(oCALFISDET:oPeriodo:aItems);
                OF oBar;
                FONT oFont

   oCALFISDET:oHasta:cToolTip:="F6: Calendario"

   @ 10+60, nLin+335-15 BUTTON oCALFISDET:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oCALFISDET:oPeriodo:nAt=LEN(oCALFISDET:oPeriodo:aItems);
               ACTION oCALFISDET:HACERWHERE(oCALFISDET:dDesde,oCALFISDET:dHasta,oCALFISDET:cWhere,.T.)

  oCALFISDET:cOptions:=ATAIL(oCALFISDET:aOptions)

  @ 10+60, nLin+350 COMBOBOX oCALFISDET:oOptions  VAR oCALFISDET:cOptions ITEMS oCALFISDET:aOptions ;
                SIZE 95,140;
                PIXEL;
                OF oBar;
                FONT oFont;
                WHEN LEN(oCALFISDET:oOptions:aItems)>1;
                ON CHANGE oCALFISDET:CHANGEOPTIONS()

  ComboIni(oCALFISDET:oOptions)

  oBar:SetSize(NIL,75+25,.T.)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 45+25,015 SAY " "+oDp:cRif     OF oBar SIZE 094,20 BORDER PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
  @ 45+25,112 SAY " "+oDp:cEmpresa OF oBar SIZE 300,20 BORDER PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  IF !Empty(oCALFISDET:cCodPro)

    oBar:SetSize(NIL,75+25+25,.T.)

    @ 75+18,015 SAY " "+oCALFISDET:cCodPro OF oBar SIZE 094,20 BORDER PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
    @ 75+18,112 SAY " "+SQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",oCALFISDET:cCodPro)) OF oBar SIZE 480,20 BORDER PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  ELSE


    oBar:SetSize(NIL,75+25,.T.)


  ENDIF

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
  oCALFISDET:RUNCALFISCAL()
RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRCALFISDET",cWhere)
  oRep:cSql  :=oCALFISDET:cSql
  oRep:cTitle:=oCALFISDET:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCALFISDET:oPeriodo:nAt,cWhere

  oCALFISDET:nPeriodo:=nPeriodo

  IF oCALFISDET:oPeriodo:nAt=LEN(oCALFISDET:oPeriodo:aItems)

     oCALFISDET:oDesde:ForWhen(.T.)
     oCALFISDET:oHasta:ForWhen(.T.)
     oCALFISDET:oBtn  :ForWhen(.T.)

     DPFOCUS(oCALFISDET:oDesde)

  ELSE

     oCALFISDET:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCALFISDET:oDesde:VarPut(oCALFISDET:aFechas[1] , .T. )
     oCALFISDET:oHasta:VarPut(oCALFISDET:aFechas[2] , .T. )

     oCALFISDET:dDesde:=oCALFISDET:aFechas[1]
     oCALFISDET:dHasta:=oCALFISDET:aFechas[2]

     cWhere:=oCALFISDET:HACERWHERE(oCALFISDET:dDesde,oCALFISDET:dHasta,oCALFISDET:cWhere,.T.)

     oCALFISDET:LEERDATA(cWhere,oCALFISDET:oBrw,oCALFISDET:cServer)

  ENDIF

  oCALFISDET:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDOCPROPROG.PLP_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDOCPROPROG.PLP_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF

   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oCALFISDET:cWhereQry)
       cWhere:=cWhere + oCALFISDET:cWhereQry
     ENDIF

     oCALFISDET:LEERDATA(cWhere,oCALFISDET:oBrw,oCALFISDET:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={},I,nMes:=MONTH(oDp:dFecha)
   LOCAL oDb,aOptions:={}

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

/*
   cSql:= "  SELECT  "+;
          "  PLP_FECHA, "+;
          "  MONTHNAME(PLP_FECHA) AS MES, "+;
          "  DAYNAME(PLP_FECHA) AS DIA, "+;
          "  PLP_TIPDOC, "+;
          "  PLP_REFERE, "+;
          "  PLP_NUMREG, "+;
          "  DOC_FECHA  AS FCHREG, "+;
          "  IF(DOC_NETO<>0,DOC_NETO,PLP_MTOCAL) AS DOC_NETO, "+;
          "  DOC_FECHA-PLP_FECHA AS DIASDOC, "+;
          "  '' AS REGESTATUS, "+;
          "  PAG_FECHA  AS FCHPAGO, "+;
          "  PAG_FECHA-DOC_FECHA AS DIASPAG, "+;
          "  '' AS PAGESTATUS, "+;
          "  PAG_PAGNUM AS PAGNUMERO, "+;
          "  DOC_CBTNUM AS CBTNUM, "+;
          "  0 AS DIAS, "+;
          "  0 AS COLOR,PRO_CODIGO,DOC_NUMERO,PGC_NUMERO,TDC_DESCRI,PRO_NOMBRE "+;
          "  FROM DPDOCPROPROG   "+;
          "  INNER JOIN DPTIPDOCPRO      ON PLP_TIPDOC=TDC_TIPO   AND TDC_TRIBUT=1 AND TDC_ACTIVO=1  "+;
          "  INNER JOIN DPPROVEEDOR      ON PLP_CODIGO=PRO_CODIGO      "+;
          "  INNER JOIN DPPROVEEDORPROG  ON PLP_CODSUC=PGC_CODSUC AND  "+;
          "                                 PLP_CODIGO=PGC_CODIGO AND  "+;
          "                                 PLP_TIPDOC=PGC_TIPDOC AND  "+;
          "                                 PLP_REFERE=PGC_REFERE      "+;
          "  LEFT  JOIN       DPDOCPRO   ON PLP_CODSUC=DOC_CODSUC AND  "+;
          "                                 PLP_TIPDOC=DOC_TIPDOC AND  "+;
          "                                 PLP_CODIGO=DOC_CODIGO AND  "+;
          "                                 PLP_NUMREG=DOC_PPLREG AND  "+;
          "                                 PLP_NUMDOC=DOC_NUMERO AND  "+;
          "                                 DOC_TIPTRA='D'   "+;
          "  LEFT  JOIN VIEW_DPDOCPROPAG ON DOC_CODSUC=PAG_CODSUC AND "+;
          "                                 DOC_TIPDOC=PAG_TIPDOC AND "+;
          "  							 DOC_CODIGO=PAG_CODIGO AND "+;
          "  							 DOC_NUMERO=PAG_NUMERO     "+;
          "  WHERE "+cWhere+;
          "  GROUP BY PLP_FECHA,PLP_TIPDOC,PLP_REFERE,PLP_NUMREG "+;
          "  ORDER BY PLP_FECHA   "+;
          ""
*/
 cSql:= "  SELECT  "+;
          "  PLP_FECHA, "+;
          "  MONTHNAME(PLP_FECHA) AS MES, "+;
          "  DAYNAME(PLP_FECHA) AS DIA, "+;
          "  PLP_TIPDOC, "+;
          "  TDC_DESCRI, "+;
          "  PLP_REFERE, "+;
          "  DOC_FECHA  AS FCHREG, "+;
          "  IF(DOC_NETO=0 OR DOC_NETO IS NULL ,PLP_MTOCAL,DOC_NETO), "+;
          "  DOC_FECHA-PLP_FECHA AS DIASDOC, "+;
          "  '' AS REGESTATUS, "+;
          "  PAG_FECHA  AS FCHPAGO, "+;
          "  PAG_FECHA-DOC_FECHA AS DIASPAG, "+;
          "  '' AS PAGESTATUS, "+;
          "  PAG_PAGNUM AS PAGNUMERO, "+;
          "  DOC_CBTNUM AS CBTNUM, "+;
          "  0 AS DIAS, "+;
          "  0 AS COLOR,PRO_CODIGO,DOC_NUMERO,PGC_NUMERO,PLP_NUMREG,PRO_NOMBRE,TDC_CLRGRA,PLP_MTOCAL,PLP_VALCAM,"+;
          "  PLP_MTOCAL/PLP_VALCAM AS PLP_MTODIV "+;
          "  FROM DPDOCPROPROG   "+;
          "  INNER JOIN DPTIPDOCPRO      ON PLP_TIPDOC=TDC_TIPO   AND TDC_TRIBUT=1 AND TDC_ACTIVO=1 "+;
          "  INNER JOIN DPPROVEEDOR      ON PLP_CODIGO=PRO_CODIGO      "+;
          "  INNER JOIN DPPROVEEDORPROG  ON PLP_CODSUC=PGC_CODSUC AND  "+;
          "                                 PLP_CODIGO=PGC_CODIGO AND  "+;
          "                                 PLP_TIPDOC=PGC_TIPDOC AND  "+;
          "                                 PLP_REFERE=PGC_REFERE      "+;
          "  LEFT  JOIN       DPDOCPRO   ON PLP_CODSUC=DOC_CODSUC AND  "+;
          "                                 PLP_TIPDOC=DOC_TIPDOC AND  "+;
          "                                 PLP_CODIGO=DOC_CODIGO AND  "+;
          "                                 PLP_NUMREG=DOC_PPLREG AND  "+;
          "                                 PLP_NUMDOC=DOC_NUMERO AND  "+;
          "                                 DOC_TIPTRA='D'   "+;
          "  LEFT  JOIN VIEW_DPDOCPROPAG ON DOC_CODSUC=PAG_CODSUC AND "+;
          "                                 DOC_TIPDOC=PAG_TIPDOC AND "+;
          "  							 DOC_CODIGO=PAG_CODIGO AND "+;
          "  							 DOC_NUMERO=PAG_NUMERO     "+;       
          "  WHERE "+cWhere+;
          "  GROUP BY PLP_FECHA,PLP_TIPDOC,PLP_REFERE,PLP_NUMREG "+;
          "  ORDER BY PLP_FECHA   "+;
          ""

   aData:=ASQL(cSql,oDb)


   AEVAL(aData,{|a,n| aData[n,2] :=LEFT(CMES(a[1]),3)   ,;
                      aData[n,3] :=LEFT(CSEMANA(a[1]),3),;
                      aData[n,16]:=a[1]-oDp:dFecha})


   DPWRITE("TEMP\BRCALFISDET.SQL",cSql)


   FOR I=1 TO LEN(aData)

      IF Empty(aData[I,7]) .AND. aData[I,16]<0
        aData[I,10]:="Extemporáneo"
        aData[I,17]:=CLR_HRED
      ENDIF

      IF Empty(aData[I,7]) .AND. MONTH(aData[I,1])=nMes .AND. aData[I,16]>0
        aData[I,10]:="Por Realizar"
        aData[I,17]:=26316
      ENDIF

      IF !Empty(aData[I,7]) 
        aData[I,10]:="Registrado"
        aData[I,17]:=CLR_HBLUE
      ENDIF

      IF !Empty(aData[I,11]) 
        aData[I,10]:="Pagado"
        aData[I,17]:=CLR_GREEN
      ENDIF


      IF !Empty(aData[I,10]) .AND.!Empty(aData[I,7])
        aData[I,13]:=IIF(Empty(aData[I,15]),"Sin Efecto","Por Pagar")
      ENDIF

   NEXT I

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
   ENDIF

   IF ValType(oBrw)="O"

      oCALFISDET:cSql   :=cSql
      oCALFISDET:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1
/*
      oCol:=oCALFISDET:oBrw:aCols[9]
      oCol:cFooter      :=FDP(aTotal[9],'999,999,999.99')
      oCol:=oCALFISDET:oBrw:aCols[12]
      oCol:cFooter      :=FDP(aTotal[12],'999,999,999.99')

      oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      oBrw:RefreshFooters()
*/
      EJECUTAR("BRWCALTOTALES",oBrw,.T.)

      FOR I=1 TO LEN(aData)
        IF ASCAN(aOptions,aData[I,10])=0
          AADD(aOptions,aData[I,10])
        ENDIF
      NEXT I

      ADEPURA(aOptions,{|a,n| Empty(a)})

      AADD(aOptions,"Todos")

      oCALFISDET:oOptions:aItems:=ACLONE(aOptions)


      AEVAL(oCALFISDET:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCALFISDET:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCALFISDET.MEM",V_nPeriodo:=oCALFISDET:nPeriodo
  LOCAL V_dDesde:=oCALFISDET:dDesde
  LOCAL V_dHasta:=oCALFISDET:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCALFISDET)
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
    LOCAL cWhere:=oCALFISDET:cWhere_
    LOCAL cWhereD

    IF Empty(cWhere)
       cWhere:=oCALFISDET:cWhere
    ENDIF

    cWhereD:=oCALFISDET:HACERWHERE(oCALFISDET:dDesde,oCALFISDET:dHasta,oCALFISDET:cWhere,.T.)
    cWhere :=IF(Empty(cWhere),cWhereD,cWhere)

    IF Type("oCALFISDET")="O" .AND. oCALFISDET:oWnd:hWnd>0

      oCALFISDET:LEERDATA(cWhere,oCALFISDET:oBrw,oCALFISDET:cServer)
      oCALFISDET:oWnd:Show()
      oCALFISDET:oWnd:Maximize()

    ENDIF

RETURN NIL

FUNCTION RUNCALFISCAL(lFecha)
  LOCAL x       :=EJECUTAR("GETCODSENIAT")
  LOCAL aLine   :=oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt]
  LOCAL dFecha  :=aLine[1]
  LOCAL cTipDoc :=aLine[4]
  LOCAL cRefere :=aLine[5]
  LOCAL cNumReg :=aLine[20+1] // aLine[6]
  LOCAL dHasta  :=FCHINIMES(dFecha)-1
  LOCAL dDesde  :=FCHINIMES(dHasta)
  LOCAL cCodSuc :=oCALFISDET:cCodSuc
  LOCAL cCodPro :=aLine[18]
  LOCAL cNumItem:=aLine[20]
  LOCAL cCodPro,oTable,cSql,cWhere:=nil
  
  DEFAULT lFecha:=.F.

   //lFecha:=.T.

  // Debe buscar si el Registro Anterio tiene Documento

  cSql:= "  SELECT  "+;
         "  PLP_FECHA,PLP_REFERE "+;
         "  FROM DPDOCPROPROG   "+;
         "  INNER JOIN DPPROVEEDORPROG ON PLP_CODSUC=PGC_CODSUC AND   "+;
         "                                PLP_CODIGO=PGC_CODIGO AND  "+;
         "                                PLP_TIPDOC=PGC_TIPDOC AND  "+;
         "                                PLP_NUMERO=PGC_NUMERO AND  "+;
         "                                PLP_REFERE=PGC_REFERE   "+;
         "  LEFT  JOIN DPDOCPRO ON PLP_CODSUC=DOC_CODSUC AND  "+;
         "                         PLP_TIPDOC=DOC_TIPDOC AND  "+;
         "                         PLP_CODIGO=DOC_CODIGO AND  "+;
         "                         PLP_NUMREG=DOC_PPLREG AND  "+;
         "                         DOC_TIPTRA='D'   "+;
         "  WHERE PLP_CODSUC"+GetWhere("=",oCALFISDET:cCodSuc)+;
         "    AND PLP_TIPDOC"+GetWhere("=",cTipDoc)+;
         "    AND PLP_FECHA" +GetWhere("<",dFecha) +;
         "    AND DOC_NUMERO IS NULL" +;
         "  ORDER BY PLP_FECHA DESC LIMIT 1  "




  IF lFecha

   // obtiene la Primera Fecha de PlanificacióN

    cSql:= "  SELECT  "+; 
           "  PLP_FECHA,PLP_REFERE "+;
           "  FROM DPDOCPROPROG   "+;
           "  INNER JOIN DPPROVEEDORPROG ON PLP_CODSUC=PGC_CODSUC AND   "+;
           "                                PLP_CODIGO=PGC_CODIGO AND  "+;
           "                                PLP_TIPDOC=PGC_TIPDOC AND  "+;
           "                                PLP_NUMERO=PGC_NUMERO AND  "+;
           "                                PLP_REFERE=PGC_REFERE   "+;
           "  LEFT  JOIN DPDOCPRO ON PLP_CODSUC=DOC_CODSUC AND  "+;
           "                         PLP_TIPDOC=DOC_TIPDOC AND  "+;
           "                         PLP_CODIGO=DOC_CODIGO AND  "+;
           "                         PLP_NUMREG=DOC_PPLREG AND  "+;
           "                         DOC_TIPTRA='D'   "+;
           "  WHERE PLP_CODSUC"+GetWhere("=",oCALFISDET:cCodSuc)+;
           "    AND PLP_TIPDOC"+GetWhere("=",cTipDoc)+;
           "  ORDER BY PLP_FECHA LIMIT 1  "


  ENDIF

  oTable:=OpenTable(cSql,.T.)
  dFecha:=oTable:PLP_FECHA
  oTable:End()

// oTable:browse()
// ? oDp:dFchInCalF,"fecha de inicio del calendario fiscal"
// ? CLPCOPY(cSql),"Busca el compromiso anterior si fue pagado o no"

  IF lFecha
     dFecha:=IF(!Empty(dFecha),FCHINIMES(dFecha)-1,oDp:dFecha)
  ENDIF

  IF !Empty(oTable:PLP_FECHA) .AND. !lFecha .AND. oTable:PLP_FECHA>=oDp:dFchInCalF

     aLine:={}
     AADD(aLine,{"Tipo Documento",cTipDoc})
     AADD(aLine,{"Referencia"    ,oTable:PLP_REFERE})
     AADD(aLine,{"Fecha"         ,DTOC(oTable:PLP_FECHA)})
     AADD(aLine,{"Registro"      ,cNumReg})

     EJECUTAR("MSGBROWSE",aLine,"Periodo no Ejecutado",NIL  ,200  ,NIL       ,NIL  ,.T.)

     aLine  :=oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt]

     // RETURN .F.

  ENDIF


  IF cTipDoc="PRT"
    oCALFISDET:RUNPRT(dFecha,cTipDoc,cRefere,cNumReg)
    RETURN 
  ENDIF

  IF cTipDoc="XML"
     EJECUTAR("DPISLRXML",oCALFISDET:cCodSuc,dDesde,dhasta,cNumReg,dFecha,oCALFISDET)
     RETURN 
  ENDIF

  // Emitir Forma30
  IF cTipDoc="F30"

/*
     IF lFecha 
        IF "Sema"$aLine[5]
           lFecha:=.F.
        ENDIF
     ENDIF
*/

     EJECUTAR("FORMA30",dFecha,oCALFISDET:cCodSuc,cNumReg,dFecha,NIL,lFecha,NIL,NIL,NIL,.F.) // lFecha)

     RETURN 
  ENDIF

  // Calcular ITF (Efectivo)
  IF cTipDoc="ITF"
     // EJECUTAR("ITFCAL",dFecha,oCALFISDET:cCodSuc,cNumReg,lFecha)
     EJECUTAR("ITFCAL",dFecha,oCALFISDET:cCodSuc,cNumReg,dFecha,NIL,lFecha,NIL,NIL,NIL,.F.) // lFecha)
     RETURN 
  ENDIF

  IF cTipDoc="F28" .AND. ISRELEASE("17.01")
     EJECUTAR("FORMA28",dFecha,oCALFISDET:cCodSuc,cNumReg,lFecha)
     RETURN 
  ENDIF

  IF cTipDoc="F26" 
//.AND. ISRELEASE("17.01")
     EJECUTAR("FORMA26",dFecha,oCALFISDET:cCodSuc,cNumReg,lFecha)
     RETURN 
  ENDIF

  IF cTipDoc="F23" .AND. ISRELEASE("17.01")
     EJECUTAR("FORMA23",dFecha,oCALFISDET:cCodSuc,cNumReg,lFecha)
     RETURN 
  ENDIF

  IF cTipDoc="CEP" 

     IF lFecha
       dDesde:=FCHINIMES(FCHFINMES(dDesde)-1)
       dHasta:=FCHFINMES(dDesde)
     ELSE
       dHasta:=FCHFINMES(oDp:dFecha)
       dDesde:=FCHINIMES(dHasta)
     ENDIF

     RETURN EJECUTAR("BRCEPPDECL",cWhere,oCALFISDET:cCodSuc,oDp:nMensual,dDesde,dHasta,NIL,cNumReg,lFecha)

  ENDIF


  IF cTipDoc="A30" 

     IF !ISRELEASE("18.08",.T.)
       RETURN .F.
     ENDIF

     // dFecha,cCodSuc,cNumReg,nAno,nMes,lFecha,dDesde,dHasta,lFrm,lSemana

     EJECUTAR("FORMAA30",dFecha,oCALFISDET:cCodSuc,cNumReg,lFecha)
// ,dDesde,dHasta,lFrm,.F.emana)
     RETURN 

  ENDIF

  IF cTipDoc="A26" 

    // IF !ISRELEASE("18.08",.T.)
    //   RETURN .F.
    // ENDIF

     dFecha :=aLine[1]

     EJECUTAR("FORMAA26",dFecha,oCALFISDET:cCodSuc,cNumReg,NIL,NIL,lFecha,cRefere)

     RETURN 

  ENDIF

  // SEGURO SOCIAL
  // ? cTipDoc,"cTipDoc"
  IF cTipDoc="SSO" 

      //  dFecha,cRegPla,cTipDoc,aCodCon,cCodPro,nPeriodo)
     dFecha  :=aLine[1]

     IF EJECUTAR("CALFISINCESTOCXP",dFecha,cNumReg,cTipDoc,oDp:aConIvsso,oDp:cRifIvsso,4)
        RETURN .T.
     ENDIF

  ENDIF

  IF cTipDoc="INC" 

     //  dFecha,cRegPla,cTipDoc,aCodCon,cCodPro,nPeriodo)
     dFecha  :=aLine[1]
     IF EJECUTAR("CALFISINCESTOCXP",dFecha,cNumItem,cTipDoc,oDp:aConInces,oDp:cRifInces,6)
        RETURN .T.
     ENDIF

  ENDIF

  IF cTipDoc="HAB" 

     //  dFecha,cRegPla,cTipDoc,aCodCon,cCodPro,nPeriodo)
     dFecha  :=aLine[1]

     IF EJECUTAR("CALFISINCESTOCXP",dFecha,cNumItem,cTipDoc,oDp:aConHabit,oDp:cRifHabit,6)
        RETURN .T.
     ENDIF

  ENDIF

  EJECUTAR("DOCPROPROGREG",cCodSuc,cNumReg,cNumItem,cCodPro)

RETURN .T.

/*
// Retenciones de ISLR, Se Calcula del mes pasado
*/
FUNCTION RUNPRT(dFecha,cTipDoc,cRefere,cNumReg)
  LOCAL aLine   :=oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt]
  LOCAL dHasta  :=FCHINIMES(dFecha)-1
  LOCAL dDesde  :=FCHINIMES(dHasta)
  LOCAL nPeriodo:=2

  DEFAULT dFecha:=aLine[1]

  IF ("2"$cRefere)
     nPeriodo:=3
  ENDIF

  IF "Sema"$cRefere

    nPeriodo:=LEFT(ALLTRIM(STRTRAN(cRefere,"Semana","")),1)
    nPeriodo:=VAL(nPeriodo)


    dFecha:=aLine[1]
    // dFecha  :=IF(Empty(dFecha),aLine[1],dFecha)

    dHasta:=EJECUTAR("GETLUNES",dFecha)-1
    dDesde:=dHasta-6

// ? dDesde,dHasta

    EJECUTAR("DPLIBRTITXT",NIL,YEAR(dHasta),Month(dHasta),nPeriodo,cNumReg,dFecha,oCALFISDET,nPeriodo,cRefere,dDesde,dHasta)
    RETURN 
  ENDIF

//  ? cRefere

  EJECUTAR("DPLIBRTITXT",NIL,YEAR(dHasta),Month(dHasta),nPeriodo,cNumReg,dFecha,oCALFISDET,0)

RETURN .T.

FUNCTION PAGAR()
  LOCAL aLine  :=oCALFISDET:oBrw:aArrayData[oCALFISDET:oBrw:nArrayAt]
  LOCAL dFecha :=aLine[1]
  LOCAL cTipDoc:=aLine[4]
  LOCAL cRefere:=aLine[5]
  LOCAL cNumReg:=aLine[6]
  LOCAL cCodigo:=aLine[18] // EJECUTAR("GETCODSENIAT")
  LOCAL nMonto :=aLine[08] // aLine[15]
  LOCAL cDescri:=ALLTRIM(SQLGET("DPTIPDOCPRO","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc)))

  IF Empty(nMonto)
//     MensajeErr("Registro "+cNumReg+" Sin Efecto para Pagar, Monto Cero")
     EJECUTAR("XSCGMSGERR","Registro "+cNumReg+" Sin Efecto para Pagar, Monto Cero","Pago de "+cTipDoc)
     RETURN .F.
  ENDIF

  IF Empty(cCodigo)
     RETURN .F.
  ENDIF

RETURN EJECUTAR("DPDOCPROPAG",oCALFISDET:cCodSuc,cTipDoc,cCodigo,cNumReg)

/*
// Filtrar por Opciones Segun estatus
*/
FUNCTION CHANGEOPTIONS()
  LOCAL nLastKey:=NIL,oCol:=oCALFISDET:oBrw:aCols[10]

  oCALFISDET:oBrw:nColSel:=10

  IF "Todos"$oCALFISDET:cOptions
    oCALFISDET:BRWREFRESCAR()
  ELSE
    EJECUTAR("BRWFILTER",oCol,oCALFISDET:cOptions,nLastKey)
  ENDIF

  oCALFISDET:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(oCALFISDET:oBrw:aArrayData))

RETURN NIL

FUNCTION RUNCALANUAL()

   EJECUTAR("CALFILREGANUAL",oCALFISDET:dHasta)

RETURN .T.

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oCALFISDET)

FUNCTION GETCLRGRA(cTipDoc,nClrText)
  LOCAL nAt   :=ASCAN(oCALFISDET:aColors,{|a,n|a[1]=cTipDoc})
  LOCAL nColor:=IF(nAt>0,oCALFISDET:aColors[nAt,2],nClrText)
RETURN nColor

FUNCTION CALFISSENIAT()
  LOCAL cCodPro:=EJECUTAR("GETCODSENIAT")
  LOCAL cWhere :="PLP_CODIGO"+GetWhere("=",cCodPro),lData:=NIL,cTitle:=NIL

  oCALFISDET:CLOSE()

RETURN EJECUTAR("BRCALFISDET",cWhere,oCALFISDET:cCodSuc,oCALFISDET:nPeriodo,oCALFISDET:dDesde,oCALFISDET:dHasta,cTitle,lData,cCodPro)
// EOF
