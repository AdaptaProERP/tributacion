// Programa   : 
// Fecha/Hora : 23/12/2025 01:55:32
// Propósito  : Crear Calendario Fiscal 2025
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cRif,dDesdeP,dHastaP,oDb)
  LOCAL aData:={},nRif,I,aDias,nAno:=2025
  LOCAL cCodigo:=EJECUTAR("GETCODSENIAT")
  LOCAL lDelete:=.F.
  LOCAL nAt,aLine,aFechas:={},dFecha,dDesde,dHasta

  EJECUTAR("GETOPRIF")

  DEFAULT oDp:cRif_SENIAT  :="G200000031",;
          oDp:cRif_IVSSO   :="G200040769",;
          oDp:cRif_INPSASEL:="G200032758",;
          oDp:cRif_MUNICIPI:="G200001488",; 
          oDp:cRif_banavih :="G200000856",;
          oDp:cRif_INCES   :="G200099224"      

  IF Empty(cCodigo) .OR. !ISSQLFIND("DPPROVEEDOR","PRO_RIF"+GetWhere("=",oDp:cRif_SENIAT))
     EJECUTAR("DPENTESPUBIMPORT")
     cCodigo:=EJECUTAR("GETCODSENIAT")
  ENDIF

  DEFAULT cRif:=oDp:cRif

  // 14/08/2025, si esta vacio regresa
  IF Empty(cRif)
     RETURN .F.
  ENDIF

  SQLUPDATE("DPTIPDOCPRO","TDC_DESCRI","Pago de Retenciones de ISLR","TDC_TIPO"+GetWhere("=","XML")+" AND TDC_DESCRI"+GetWhere("=","Pago de Retenciones de IVA"))                                                                                                

  EJECUTAR("CEPP_DEFINE")

  lDelete:=.T.  

  IF lDelete .AND. ISPCPRG()
     SQLDELETE("DPPROVEEDORPROG")
     SQLDELETE("DPDOCPROPROG")
  ENDIF

  cRif  :=ALLTRIM(cRif)
  nRif  :=VAL(RIGHT(cRif,1))
  dFecha:=CTOD("01/01/2025")

  IF !Empty(oDp:dFchInCalF)
    dFecha:=MAX(dFecha,oDp:dFchInCalF)
  ENDIF

  IF !Empty(oDp:dFchConEsp)
     dFecha:=MAX(dFecha,oDp:dFchConEsp)
  ENDIF

  oDp:dDesde:=dFecha
  oDp:dHasta:=CTOD("31/12/2025")

  DEFAULT dDesdeP:=oDp:dDesde,;
          dHastaP:=oDp:dHasta

  dDesdeP:=oDp:dDesde
  dHastaP:=oDp:dHasta

  EJECUTAR("DPTIPDOCPROARC","INS","Inpsasel"           ,10,.T.,.T.)
  EJECUTAR("DPTIPDOCPROARC","PRM","Retención Municipal",10,.T.,.T.)
  EJECUTAR("DPTIPDOCPROARC","PAT","Patente Municipal"  ,10,.T.,.T.)

  IF !LEFT(oDp:cTipCon,1)="O"
    // 2DA QUINCENA
   
    aData:={}
    //               ENE FEB  MAR  ABR  MAY  JUN  JUL  AGO  SEP  OCT  NOV  DIC
    AADD(aData,{0,0,"08","10","07","01","05","06","03","06","02","13","14","08"})
    AADD(aData,{1,1,"14","04","12","04","02","04","10","05","09","03","06","04"})
    AADD(aData,{2,2,"10","06","10","07","07","02","07","04","05","06","10","11"})
    AADD(aData,{3,3,"03","13","17","14","14","11","14","11","10","01","05","03"})
    AADD(aData,{4,4,"07","11","12","11","13","12","15","01","03","10","13","12"})
    AADD(aData,{5,5,"02","05","06","08","15","03","04","14","12","07","11","09"})
    AADD(aData,{6,6,"06","14","11","10","09","09","02","12","11","09","12","02"})
    AADD(aData,{7,7,"09","07","05","03","06","05","09","07","04","14","03","10"})
    AADD(aData,{8,8,"15","03","14","09","12","13","08","13","08","08","07","01"})
    AADD(aData,{9,9,"13","12","13","02","08","10","11","08","01","02","04","05"})
    CREACALQUINCE(aData,.F.)


    // 1ERA QUINCENA
    aData:={}
    AADD(aData,{0,0,"23","18","21","15","20","25","17","21","16","30","25","23"})
    AADD(aData,{1,1,"28","19","24","25","16","20","21","20","29","20","20","22"})
    AADD(aData,{2,2,"31","21","20","21","22","19","23","19","18","21","28","29"})
    AADD(aData,{3,3,"20","26","31","29","30","23","28","26","23","16","17","19"})
    AADD(aData,{4,4,"22","25","26","30","28","27","30","15","17","29","24","30"})
    AADD(aData,{5,5,"21","20","19","22","29","16","22","29","22","23","27","26"})
    AADD(aData,{6,6,"17","27","28","28","26","26","26","27","24","27","26","17"})
    AADD(aData,{7,7,"24","24","18","24","19","17","31","22","19","31","19","18"})
    AADD(aData,{8,8,"29","17","27","23","27","30","25","28","26","24","21","15"})
    AADD(aData,{9,9,"27","28","25","16","23","18","29","25","25","17","18","16"})
    CREACALQUINCE(aData,.T.)


  ELSE
  
    // IVA MENSUAL CONTRIBUYENTE ORDINARIO
    EJECUTAR("CALFIS_IVSSO",dFecha,oDp:cRifSeniat,"F30","IVA Mensual",lDelete,dDesdeP,dHastaP)

  ENDIF

          
  // PENSIONES     ENE  FEB  MAR  ABR  MAY  JUN  JUL  AGO, SEP  OCT  NOV  DIC
  aData:={}
  AADD(aData,{0,0,"08","10","07","02","05","06","03","07","02","14","14","09"})
  AADD(aData,{1,1,"14","04","12","07","02","04","10","06","09","06","06","05"})
  AADD(aData,{2,2,"10","06","10","08","07","02","07","05","05","07","10","12"})
  AADD(aData,{3,3,"17","13","17","15","14","11","14","12","10","02","05","04"})
  AADD(aData,{4,4,"07","11","18","14","13","12","15","04","03","13","13","15"})
  AADD(aData,{5,5,"16","05","06","09","15","03","04","15","12","08","11","10"})
  AADD(aData,{6,6,"06","14","11","11","09","09","02","13","11","10","12","03"})
  AADD(aData,{7,7,"09","07","05","04","06","05","09","08","04","15","03","11"})
  AADD(aData,{8,8,"15","03","14","10","12","13","08","14","08","09","07","02"})
  AADD(aData,{9,9,"13","12","13","03","08","10","11","11","01","03","04","08"})

  CREACALFISXML(aData,"CEP")


  // DPJ28
  // Partimos desde los 6 meses luego de la fecha del ejercicio
  aData:={}
  //          RIF ENE  FEB  MAR  ABR  MAY  JUN  JUL  AGO, SEP  OCT  NOV  DIC
  AADD(aData,{0,8,"16","10","14","10","12","13","08","14","08","09","14","09"})
  AADD(aData,{1,4,"15","11","12","14","13","12","10","13","09","13","13","15"})
  AADD(aData,{2,3,"10","13","10","08","14","11","14","12","10","14","10","12"})
  AADD(aData,{5,9,"14","12","13","09","15","10","11","11","12","08","11","10"})
  AADD(aData,{6,7,"09","14","11","11","09","17","09","08","11","10","12","11"})


  CREACALFISXML(aData,"F28")
  aData:={}

  // RETENCIONES DE ISLR   
  //          RIF  ENE  FEB  MAR  ABR  MAY  JUN  JUL  AGO, SEP  OCT  NOV  DIC
  AADD(aData,{0,8,"08","10","07","10","12","06","08","07","08","09","07","09"})
  AADD(aData,{1,4,"07","11","12","07","13","12","10","06","09","06","06","05"})
  AADD(aData,{2,3,"10","06","10","08","07","11","07","12","10","07","10","04"})
  AADD(aData,{5,9,"14","12","06","09","08","10","04","11","05","08","11","10"})
  AADD(aData,{6,7,"09","07","11","04","09","09","09","08","04","10","12","11"})
  CREACALFISXML(aData,"XML")

  aData  :={}
  aFechas:={}

  /*
  // DPJ26 DEFINITIVA
  */
  IF Month(oDp:dFchCierre)=12 

     aData:={}

     AADD(aData,{2,3,"31/01/2025"})
     AADD(aData,{5,9,"28/02/2025"})
     AADD(aData,{0,8,"07/03/2025"})
     AADD(aData,{1,4,"12/03/2025"})
     AADD(aData,{6,7,"17/03/2025"})
     nAt    :=ASCAN(aData,{|a| (a[1]=nRif .OR. a[2]=nRif)})
     aLine  :=aData[nAt]

     ARREDUCE(aLine,1)
     ARREDUCE(aLine,1)

     AEVAL(aLine,{|a,n,dFecha| dFecha:=CTOD(a),AADD(aFechas,{dFecha,"Anual "+LSTR(nAno)})})

  ELSE

    // Calendario Irregular
    //              ENE  FEB  MAR ABR  MAY JUN  JUL  AGO  SEP  OCT  NOV  DIC
    AADD(aData,{0,8,"23","18","","23","20","25","17","26","17","20","21","16"})
    AADD(aData,{1,4,"22","19","","25","21","20","21","25","18","22","20","22"})
    AADD(aData,{2,3,"20","21","","21","22","19","23","22","19","23","17","19"})
    AADD(aData,{5,9,"21","20","","22","23","18","22","21","23","17","18","17"})
    AADD(aData,{6,7,"17","24","","24","19","26","18","20","22","21","19","18"})


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

  AADD(aData,{0,8,"09/10/2025","14/11/2025"})
  AADD(aData,{1,4,"13/10/2025","13/11/2025"})
  AADD(aData,{2,3,"14/10/2025","10/11/2025"})
  AADD(aData,{5,9,"08/10/2025","11/11/2025"})
  AADD(aData,{6,7,"10/10/2025","12/11/2025"})

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

  dDesde:=CTOD("01/01/2025")
  dHasta:=CTOD("31/12/2025")

  EJECUTAR("CALFISCALFONACIT",dDesde,dHasta,"FCT","G200077867")
  EJECUTAR("CALFISCALFONACIT",dDesde,dHasta,"ONA","G200090570")

  // Luego los parafiscales
  EJECUTAR("CALFIS_IVSSO",dFecha,oDp:cRif_INPSASEL,"INS","Inpsasel"           ,lDelete,dDesdeP,dHastaP)
  EJECUTAR("CALFIS_IVSSO",dFecha,oDp:cRif_MUNICIPI,"PAT","Patente Municipal"  ,lDelete,dDesdeP,dHastaP)
  EJECUTAR("CALFIS_IVSSO",dFecha,oDp:cRif_banavih ,"HAB","Vivienda y Habitat" ,lDelete,dDesdeP,dHastaP)
  EJECUTAR("CALFIS_IVSSO",dFecha,oDp:cRif_IVSSO   ,"SSO","Seguro Social"      ,lDelete,dDesdeP,dHastaP)

  EJECUTAR("CALFIS_INCES",dFecha) // Calendario Fiscal INCES

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

     dDesde:=FCHANUAL(oDp:dFchInicio,CTOD("01/01/2025"))
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



