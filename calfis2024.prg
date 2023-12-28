// Programa   : CALFIS2024	
// Fecha/Hora : 27/12/2023 01:55:32
// Propósito  : Crear Calendario Fiscal 2024
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cRif,dDesdeP,dHastaP,oDb)
  LOCAL aData:={},nRif,I,aDias,nAno:=2024
  LOCAL cCodigo:=EJECUTAR("GETCODSENIAT")
  LOCAL lDelete:=.F.
  LOCAL nAt,aLine,aFechas:={},dFecha

  IF Empty(SQLGET("DPEMPRESA","EMP_RIF","EMP_CODIGO"+GetWhere("=",oDp:cEmpCod)))
     SQLUPDATE("DPEMPRESA","EMP_RIF",oDp:cRif,"EMP_CODIGO"+GetWhere("=",oDp:cEmpCod))
  ENDIF

  IF Empty(oDp:cRif)
     oDp:cRif:=SQLGET("DPEMPRESA","EMP_RIF","EMP_CODIGO"+GetWhere("=",oDp:cEmpCod))
  ENDIF

  DEFAULT cRif:=oDp:cRif

  // 14/08/2024, si esta vacio regresa
  IF Empty(cRif)
     RETURN .F.
  ENDIF

  cRif  :=ALLTRIM(cRif)
  nRif  :=VAL(RIGHT(cRif,1))
  dFecha:=CTOD("01/01/2024")

  IF !Empty(oDp:dFchInCalF)
    dFecha:=MAX(dFecha,oDp:dFchInCalF)
  ENDIF

  IF !Empty(oDp:dFchConEsp)
     dFecha:=MAX(dFecha,oDp:dFchConEsp)
  ENDIF

  oDp:dDesde:=dFecha
  oDp:dHasta:=CTOD("31/12/2024")

  DEFAULT dDesdeP:=oDp:dDesde,;
          dHastaP:=oDp:dHasta

  dDesdeP:=oDp:dDesde
  dHastaP:=oDp:dHasta

  DEFAULT oDp:cRif_IVSSO   :="G200040769",;
          oDp:cRif_INPSASEL:="G200032758",;
          oDp:cRif_MUNICIPI:="G200001488",; 
          oDp:cRif_banavih :="G200000856",;
          oDp:cRif_INCES   :="G200099224"      

// IF .T.

  EJECUTAR("DPTIPDOCPROARC","INS","Inpsasel"           ,10,.T.,.T.)
  EJECUTAR("DPTIPDOCPROARC","PRM","Retención Municipal",10,.T.,.T.)

  EJECUTAR("CALFIS_IVSSO",dFecha,oDp:cRif_INPSASEL,"INS","Inpsasel"           ,lDelete,dDesdeP,dHastaP)
  EJECUTAR("CALFIS_IVSSO",dFecha,oDp:cRif_MUNICIPI,"PAT","Patente Municipal"  ,lDelete,dDesdeP,dHastaP)
  EJECUTAR("CALFIS_IVSSO",dFecha,oDp:cRif_banavih ,"HAB","Vivienda y Habitat" ,lDelete,dDesdeP,dHastaP)
  EJECUTAR("CALFIS_IVSSO",dFecha,oDp:cRif_IVSSO   ,"SSO","Seguro Social"      ,lDelete,dDesdeP,dHastaP)


  EJECUTAR("CALFIS_INCES",dFecha) // Calendario Fiscal INCES

  IF !LEFT(oDp:cTipCon,1)="O"
    // 2DA QUINCENA
    aData:={}
    AADD(aData,{0,0,"23","19","22","26","27","25","18","30","18","18","29","27"})
    AADD(aData,{1,1,"22","20","27","25","29","17","22","23","25","22","26","30"})
    AADD(aData,{2,2,"18","22","18","30","28","27","25","22","20","23","27","20"})
    AADD(aData,{3,3,"31","26","25","17","22","20","30","27","26","29","19","20"})
    AADD(aData,{4,4,"29","27","27","24","21","21","31","28","19","28","22","23"})
    AADD(aData,{5,5,"19","29","19","16","23","19","17","29","24","17","28","18"})
    AADD(aData,{6,6,"17","23","2e","29","31","26","19","20","23","21","18","19"})
    AADD(aData,{7,7,"26","16","29","23","17","18","29","16","30","25","21","26"})
    AADD(aData,{8,8,"30","28","26","22","20","25","26","26","17","31","25","17"})
    AADD(aData,{9,9,"25","21","21","18","30","28","23","21","27","30","20","16"})

    // 1ERA QUINCENA
    CREACALQUINCE(aData,.F.)

    aData:={}
    AADD(aData,{0,0,"08","08","14","03","10","07","03","14","09","02","15","09"})
    AADD(aData,{1,1,"05","09","15","12","14","05","01","06","10","04","14","13"})
    AADD(aData,{2,2,"03","06","05","08","07","12","08","02","04","07","11","05"})
    AADD(aData,{3,3,"10","15","08","02","15","06","15","12","11","14","01","12"})
    AADD(aData,{4,4,"12","09","12","05","02","13","11","13","03","11","06","06"})
    AADD(aData,{5,5,"04","14","13","09","08","03","04","15","06","08","12","02"})
    AADD(aData,{6,6,"02","07","11","11","09","10","02","08","05","03","13","03"})
    AADD(aData,{7,7,"09","05","94","04","03","04","10","05","12","10","05","11"})
    AADD(aData,{8,8,"15","02","07","10","13","14","09","07","02","09","08","04"})
    AADD(aData,{9,9,"11","01","06","15","06","11","12","09","13","15","07","10"})

    CREACALQUINCE(aData,.T.)

  ELSE
  
    // IVA MENSUAL CONTRIBUYENTE ORDINARIO
    EJECUTAR("CALFIS_IVSSO",dFecha,oDp:cRifSeniat,"F30","IVA Mensual",lDelete,dDesdeP,dHastaP)

  ENDIF

  // DPJ28
  // Partimos desde los 6 meses luego de la fecha del ejercicio
  aData:={}
  AADD(aData,{0,8,"15","08","14","10","10","14","09","14","09","09","15","09"})
  AADD(aData,{1,4,"12","09","12","12","14","13","11","13","10","11","14","13"})
  AADD(aData,{2,3,"10","15","08","08","15","12","15","12","11","14","11","12"})
  AADD(aData,{5,9,"11","14","13","09","16","11","12","09","13","08","12","10"})
  AADD(aData,{6,7,"09","16","11","11","09","18","10","08","12","10","13","11"})
  CREACALFISXML(aData,"F28")

  aData:={}
  AADD(aData,{0,8,"08","08","07","10","10","07","09","07","09","09","08","09"})
  AADD(aData,{1,4,"05","09","12","05","14","13","11","06","10","04","07","06"})
  AADD(aData,{2,3,"10","06","08","08","07","12","08","12","11","07","11","05"})
  AADD(aData,{5,9,"11","14","06","09","08","11","04","09","06","08","12","10"})
  AADD(aData,{6,7,"09","07","11","04","09","10","10","08","05","10","13","11"})
  CREACALFISXML(aData,"XML")

// ENDIF

  aData  :={}
  aFechas:={}

  IF Month(oDp:dFchCierre)=12 

     aData:={}

     AADD(aData,{2,3,"31/01/2024"})
     AADD(aData,{5,9,"29/02/2024"})
     AADD(aData,{0,8,"04/03/2024"})
     AADD(aData,{1,4,"12/03/2024"})
     AADD(aData,{6,7,"20/03/2024"})
     nAt    :=ASCAN(aData,{|a| (a[1]=nRif .OR. a[2]=nRif)})
     aLine  :=aData[nAt]
   
     ARREDUCE(aLine,1)
     ARREDUCE(aLine,1)

     AEVAL(aLine,{|a,n,dFecha| dFecha:=CTOD(a),AADD(aFechas,{dFecha,"Anual "+LSTR(nAno)})})

  ELSE

    // Calendario Irregular
    AADD(aData,{0,8,"23","19","","22","20","25","17","26","18","18","25","17"})
    AADD(aData,{1,4,"22","20","","24","21","21","19","23","19","22","22","23"})
    AADD(aData,{2,3,"18","22","","17","22","20","23","22","20","23","19","20"})
    AADD(aData,{5,9,"19","21","","18","23","19","22","21","24","17","20","18"})
    AADD(aData,{6,7,"17","23","","23","17","26","18","20","23","21","21","19"})

    //  nAt    :=ASCAN(aData,{|a,n| a[1]<=nRif .AND. nRif>=a[2]})
    nAt    :=ASCAN(aData,{|a| (a[1]=nRif .OR. a[2]=nRif)})
    aLine  :=aData[nAt]

    ARREDUCE(aLine,1)
    ARREDUCE(aLine,1)

    aLine  :={aLine[MONTH(dFecha)]}
    nAt    :=MONTH(dFecha)

    AEVAL(aLine,{|a,n,dFch| dFch:=CTOD(a+"/"+LSTR(MONTH(dFecha))+"/"+LSTR(nAno)),AADD(aFechas,{dFch,"DPJ26_"+LSTR(nAno)})})

  ENDIF

  FOR I=1 TO LEN(aFechas)
     oDp:dDesde:=aFechas[I,1]
     oDp:dHasta:=aFechas[I,1]
     EJECUTAR("SAVECALFIS","F26",cCodigo,{aFechas[I,1]},aFechas[I,2],lDelete,NIL,"Anual",NIL,NIL,oDb)
  NEXT I


  /*
  // Impuesto a las grandes Patrimonios
 
  */
  aData  :={}
  aFechas:={}
  aLine  :={}

  AADD(aData,{0,8,"09/10/2024","15/11/2024"})
  AADD(aData,{1,4,"11/10/2024","14/11/2024"})
  AADD(aData,{2,3,"14/10/2024","11/11/2024"})
  AADD(aData,{5,9,"08/10/2024","12/11/2024"})
  AADD(aData,{6,7,"10/10/2024","13/11/2024"})

  // Busca en la primera columna
  nAt    :=ASCAN(aData,{|a|a[1]=nRif})

  IF nAt>0

     aLine:={aData[nAt,3]}

  ELSE

     nAt  :=ASCAN(aData,{|a|a[2]=nRif})

     IF nAt>0
       aLine:={aData[nAt,4]}
     ENDIF

  ENDIF

  AEVAL(aLine,{|a,n,dFecha| dFecha:=CTOD(a),AADD(aFechas,{dFecha,"Anual "+LSTR(nAno)})})

  FOR I=1 TO LEN(aFechas)
     oDp:dDesde:=aFechas[I,1]
     oDp:dHasta:=aFechas[I,1]
     EJECUTAR("SAVECALFIS","IGP",cCodigo,{aFechas[I,1]},aFechas[I,2],lDelete,NIL,"Anual")
  NEXT I

  EJECUTAR("DPDOCPROPROGCALIVA")

  IF !Empty(oDp:dFchInCalF)
     SQLUPDATE("DPDOCPROPROG","PLP_ACTIVO",.F.,"PLP_FECHA"+GetWhere("<",dDesdeP)) // oDp:dFchInCalF))
   ENDIF

RETURN .T.

FUNCTION CREACALQUINCE(aData,lIniMes)
  LOCAL aLine,dFecha,cDia,cRef,cMes
  LOCAL nAt
  LOCAL aFechas:={}

  DEFAULT lIniMes:=.T.

  nAt  :=ASCAN(aData,{|a| (a[1]=nRif .OR. nRif=a[2])})

  aLine:=aData[nAt]
  ARREDUCE(aLine,1)
  ARREDUCE(aLine,1)


  FOR I=1 TO LEN(aLine)

     cMes  :=STRZERO(I,2)
     cDia  :=aLine[I]
     nAt   :=AT("/",cDia)
     cDia  :=cDia+IF(nAt=0,"/"+cMes,"")

     dFecha:=CTOD(cDia+"/"+LSTR(nAno))

     IF !lIniMes
       cRef  :=CMES(FCHINIMES(dFecha)-1)
     ELSE
       cRef  :=CMES(FCHINIMES(dFecha))
     ENDIF

     cRef  :=IF(lIniMes,"1era Quincena","2da Quincena")+" de "+cRef
     // Semana "+LSTR(I)+"/"+LSTR(LEN(aLine))
     AADD(aFechas,{dFecha,cRef})

  NEXT I

  IF !Empty(dDesdeP) .AND. !Empty(dHastaP)
     ADEPURA(aFechas,{|a,n| !(a[1]>=dDesdeP .AND. a[1]<=dHastaP) })
  ENDIF

  FOR I=1 TO LEN(aFechas)
     oDp:dDesde:=aFechas[I,1]
     oDp:dHasta:=aFechas[I,1]
     EJECUTAR("SAVECALFIS","PRT",cCodigo,{aFechas[I,1]},aFechas[I,2],lDelete,NIL,"Quincenal",NIL)
     EJECUTAR("SAVECALFIS","F30",cCodigo,{aFechas[I,1]},aFechas[I,2],lDelete,NIL,"Quincenal",NIL)
     EJECUTAR("SAVECALFIS","A26",cCodigo,{aFechas[I,1]},aFechas[I,2],lDelete,NIL,"Quincenal",NIL)
     EJECUTAR("SAVECALFIS","ITF",cCodigo,{aFechas[I,1]},aFechas[I,2],lDelete,NIL,"Quincenal",NIL)
  NEXT I

  aData:={}

RETURN aFechas

FUNCTION CREACALFISXML(aData,cTipDoc)
LOCAL aLine,dFecha,cDia,cRef,cMes,nMes,nMin
  LOCAL nAt,dDesde
  LOCAL aFechas:={},aNew:={},I

  DEFAULT cTipDoc:="XML"

  nAt  :=ASCAN(aData,{|a| (a[1]=nRif .OR. nRif=a[2])})

  aLine:=aData[nAt]
  ARREDUCE(aLine,1)
  ARREDUCE(aLine,1)

  FOR I=1 TO LEN(aLine)
     cMes  :=STRZERO(I,2)
     cDia  :=aLine[I]
     nAt   :=AT("/",cDia)
     cDia  :=cDia+IF(nAt=0,"/"+cMes,"")
     dFecha:=cDia+"/"+LSTR(nAno)
     cRef  :="Mensual"
     AADD(aFechas,{CTOD(dFecha),cRef})
  NEXT I

  // Ejercicio Regular, seis meses despues
  IF cTipDoc="F28" 

     dDesde:=FCHANUAL(oDp:dFchInicio,CTOD("01/01/2024"))
     dDesde:=dDesde+180 // FchIniMes(oDp:dFchInicio+180)
     aNew  :={}


     FOR I=1 TO LEN(aFechas)
       IF aFechas[I,1]>=dDesde
          AADD(aNew,aFechas[I])
       ENDIF
     NEXT I

     aFechas:=ACLONE(aNew)

  ENDIF

  IF !Empty(dDesdeP) .AND. !Empty(dHastaP)
    ADEPURA(aFechas,{|a,n| !(a[1]>=dDesdeP .AND. a[1]<=dHastaP) })
  ENDIF

  FOR I=1 TO LEN(aFechas)
     oDp:dDesde:=aFechas[I,1]
     oDp:dHasta:=aFechas[I,1]
     EJECUTAR("SAVECALFIS",cTipDoc,cCodigo,{aFechas[I,1]},aFechas[I,2],lDelete,NIL,"Mensual",NIL)
  NEXT I

RETURN .T.
// EOF


