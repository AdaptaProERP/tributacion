// Programa   : CREARCALFIS
// Fecha/Hora : 09/12/2017 00:09:16
// Propósito  : Crear Calendario Fiscal para HTML
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dDesde,dHasta,lView,lDelete)
   LOCAL nYear:=YEAR(oDp:dFecha),cWhere:=""
   LOCAL cNumEje:=""
   LOCAL oDb  :=OpenOdbc(oDp:cDsnData)
   LOCAL cSql :=" SET FOREIGN_KEY_CHECKS = 0"
   LOCAL cSucZero:="000000"

   oDb:Execute(cSql)

   DEFAULT lView:=.F.

   DEFAULT dDesde :=oDp:dFchInicio,;
           dHasta :=oDp:dFchCierre,;
           lDelete:=.F.

   IF COUNT("DPIVATIP")=0
      EJECUTAR("DPIVATIPCREA")
   ENDIF

   IF COUNT("DPIVATIP","TIP_CODIGO"+GetWhere("=","EX"))=0
     EJECUTAR("DPIVATIP_CREA","EX","Exento",0)
   ENDIF

// 08/02/2024 solo debe valir si existe el año en curso.
//   IF !Empty(dDesde)
//      cWhere:=" AND "+GetWhereAnd("PLP_FECHA",dDesde,dHasta)
//   ENDIF

   EJECUTAR("DPEMPGETRIF")

   IF ISSQLFIND("DPSUCURSAL","SUC_CODIGO"+GetWhere("=",cSucZero)) .AND.;
      SQLGET("DPSUCURSAL","SUC_ACTIVO","SUC_CODIGO"+GetWhere("=",cSucZero)) .AND.;
      COUNT("DPSUCURSAL")=2 .AND.;
      COUNT("DPDOCPPROPROG","PLP_CODSUC"+GetWhere("=",cSucZero))>1 

      SQLDELETE("DPSUCURSAL","SUC_CODIGO"+GetWhere("=",cSucZero))
      SQLDELETE("DPDOCPROPROG","PLP_CODSUC"+GetWhere("=",cSucZero))

   ENDIF

   EJECUTAR("DPEMPGETRIF")

// ?   YEAR(dDesde)=2022, COUNT("DPDOCPROPROG","YEAR(PLP_FECHA)=2022 AND PLP_TIPDOC"+GetWhere("=","F30")+cWhere) ,oDp:cSql

   IF YEAR(dDesde)=2022 .AND. COUNT("DPDOCPROPROG","YEAR(PLP_FECHA)=2022 AND PLP_TIPDOC"+GetWhere("=","F30")+cWhere)=0 
     EJECUTAR("DPENTESPUBIMPORT")
     DpMsgRun("Procesando","Generando Calendario Fiscal 2022",NIL,0)
     EJECUTAR("CALFIS2022",NIL,dDesde,dHasta)
     // MsgRun("Generando Calendario Fiscal 2022","Procesando",{|| EJECUTAR("CALFIS2022",NIL,dDesde,dHasta)})
     DpMsgClose()
   ENDIF


   // innecesario 10/01/2024
   // Si necesita ingresar al 2023, debe hacer el calendario

   IF YEAR(dDesde)=2023 .AND. COUNT("DPDOCPROPROG","YEAR(PLP_FECHA)=2023 AND PLP_TIPDOC"+GetWhere("=","F30")+cWhere)=0 .AND. !Empty(oDp:cRif)
     EJECUTAR("DPENTESPUBIMPORT")
     DpMsgRun("Procesando","Generando Calendario Fiscal 2023",NIL,0)
     EJECUTAR("ENTGUBTOPROVEE")
     cNumEje:=EJECUTAR("GETNUMEJE",CTOD("31/12/2023"),.T.)
     dDesde:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_NUMERO"+GetWhere("=",cNumEje))
     dHasta:=DPSQLROW(2)
     EJECUTAR("CALFIS2023",NIL,CTOD("01/01/2023"),dDesde,dHasta)
     DpMsgClose()
   ENDIF

   // 27/12/2023
   IF COUNT("DPDOCPROPROG","YEAR(PLP_FECHA)=2024 AND PLP_TIPDOC"+GetWhere("=","F30")+cWhere)=0 .AND. !Empty(oDp:cRif)
     EJECUTAR("DPENTESPUBIMPORT")
     DpMsgRun("Procesando","Generando Calendario Fiscal 2024",NIL,0)
     EJECUTAR("ENTGUBTOPROVEE")
     cNumEje:=EJECUTAR("GETNUMEJE",CTOD("31/12/2024"),.T.)
     dDesde:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_NUMERO"+GetWhere("=",cNumEje))
     dHasta:=DPSQLROW(2)
     EJECUTAR("CALFIS2024",NIL,CTOD("01/01/2024"),dDesde,dHasta)
     DpMsgClose()
   ENDIF

   IF COUNT("DPDOCPROPROG","PLP_FCHDEC"+GetWhere("=",CTOD("")))>0
      EJECUTAR("DPLIBCOMSETFECHA")
   ENDIF

   // 27/12/2023 innecesaria
   // FONA,DEPORTES 
   //   IF COUNT("DPDOCPROPROG","YEAR(PLP_FECHA)=2023 AND PLP_TIPDOC"+GetWhere("=","FCT")+cWhere)=0 
   //   EJECUTAR("CALFIS2023ADD")
   // ENDIF

   // IVA MENSUAL CONTRIBUYENTE ORDINARIO Según el ejercicio contable
   EJECUTAR("DPEMPGETRIF")

   IF LEFT(oDp:cTipCon,1)="O" .AND. COUNT("DPDOCPROPROG","YEAR(PLP_FECHA)"+GetWhere("=",YEAR(dDesde))+" AND PLP_TIPDOC"+GetWhere("=","F30")+cWhere)=0 .AND. !Empty(oDp:cRif)
      EJECUTAR("CALFIS_IVSSO",oDp:dFecha,oDp:cRifSeniat,"F30","IVA Mensual",lDelete,dDesdeP,dHastaP)
   ENDIF

   EJECUTAR("CEPP_CALFIS2024")

   cWhere:=NIL

   cSql :=" SET FOREIGN_KEY_CHECKS = 1"

   oDb:Execute(cSql)

   IF lView
     EJECUTAR("BRCALFISDET",NIL,oDp:cSucursal,10,oDp:dFchInicio,oDp:dFchCierre)
   ENDIF

RETURN NIL
// EOF
