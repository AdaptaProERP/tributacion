// Programa   : CEPP_CALFIS2024
// Fecha/Hora : 21/05/2024 20:58:26
// Propósito  : ley de proteccion 
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cRif,lDelete,lView)
  LOCAL dDesde:=MAX(oDp:dFchInicio,FCHINIMES(oDp:dFecha))
  LOCAL dHasta:=oDp:dFchCierre
  LOCAL nRif,aData:={},nAt,aFechas:={},aLine,cRef,I,cMes,cDia,lIniMes:=.T.,dFecha,nAno:=2024
  LOCAL cTipDoc:="CEP"
  LOCAL cCodigo:=EJECUTAR("GETCODSENIAT")


  EJECUTAR("CEPP_DEFINE")
  EJECUTAR("DPEMPGETRIF")
  EJECUTAR("DPTIPDOCPROCREA",cTipDoc,"Contribución Especial Pensiones","D",NIL,.T.)

  DEFAULT oDp:cRif_SENIAT  :="G200000031"

  DEFAULT cRif   :=oDp:cRif,;
          lDelete:=.F.,;
          lView  :=.F.

  IF Empty(cRif)
     RETURN .F.
  ENDIF

  dHasta:=FCHANUAL(dHasta,oDp:dFecha)
  cRif  :=ALLTRIM(cRif)
  nRif  :=VAL(RIGHT(cRif,1))

  IF !YEAR(dDesde)>=2024
     RETURN .F.
  ENDIF

  aData:={}
  //              ENE ,FEB ,MAR ,ABR ,MAY ,JUN ,JUL ,AGO ,SEP ,OCT ,NOV ,DIC
  AADD(aData,{0,0,"00","00","00","00","00","07","03","14","09","02","15","09"})
  AADD(aData,{1,1,"00","00","00","00","00","05","01","06","10","04","14","13"})
  AADD(aData,{2,2,"00","00","00","00","00","12","08","02","04","07","11","05"})
  AADD(aData,{3,3,"00","00","00","00","00","06","15","12","11","14","01","12"})
  AADD(aData,{4,4,"00","00","00","00","00","13","11","13","03","11","06","06"})
  AADD(aData,{5,5,"00","00","00","00","00","18","04","15","06","08","12","02"})
  AADD(aData,{6,6,"00","00","00","00","00","10","02","08","05","03","13","03"})
  AADD(aData,{7,7,"00","00","00","00","00","04","10","05","12","10","05","11"})
  AADD(aData,{8,8,"00","00","00","00","00","14","09","07","02","09","08","04"})
  AADD(aData,{9,9,"00","00","00","00","00","11","12","09","13","15","07","10"})

  nAt  :=ASCAN(aData,{|a| (a[1]=nRif .OR. nRif=a[2])})

  aLine:=aData[nAt]
  ARREDUCE(aLine,1)
  ARREDUCE(aLine,1)

  FOR I=1 TO LEN(aLine)

     cMes  :=STRZERO(I,2)
     cDia  :=aLine[I]

     nAt   :=AT("/",cDia)
     cDia  :=cDia+IF(nAt=0,"/"+cMes,"")
     dFecha:=CTOD("")
     cRef  :=""
 
     IF VAL(cDia)>0
       dFecha:=CTOD(cDia+"/"+LSTR(nAno))
       cRef  :=CMES(FCHINIMES(dFecha))
     ENDIF

     AADD(aFechas,{dFecha,cRef})

  NEXT I

  IF !Empty(dDesde) .AND. !Empty(dHasta)
     ADEPURA(aFechas,{|a,n| !(a[1]>=dDesde .AND. a[1]<=dHasta) })
  ENDIF

  IF lDelete
     SQLDELETE("DPDOCPROPROG","PLP_TIPDOC"+GetWhere("=",cTipDoc)+" AND YEAR(PLP_FECHA)"+GetWhere("=",nAno))
  ENDIF

  FOR I=1 TO LEN(aFechas)
     oDp:dDesde:=aFechas[I,1]
     oDp:dHasta:=aFechas[I,1]
     EJECUTAR("SAVECALFIS",cTipDoc,cCodigo,{aFechas[I,1]},aFechas[I,2],lDelete,NIL,"Mensual",NIL)
  NEXT I

  IF lView
     EJECUTAR("BRCALFISDET","PLP_TIPDOC"+GetWhere("=",cTipDoc))
  ENDIF

RETURN .T.
// EOF

