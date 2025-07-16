// Programa   : EDITFORMA30
// Fecha/Hora : 22/05/2006 10:52:43
// Propósito  : Calcular Forma 30
// Creado Por : Juan Navas
// Original   : Obtenido de LIQ_30 DP20 Creado por José Luis Ochoa
// Llamado por: DPMENU
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dFecha,cCodSuc,cNumReg,nAno,nMes,lFecha,dDesde,dHasta,lFrm,lSemana)
  LOCAL oBtn,oFont
  LOCAL oData,nLin
  LOCAL cTipDoc:="F30",cWhere,cCodPro:=EJECUTAR("GETCODSENIAT")
  LOCAL cPplReg:=cNumReg,cRefere:="",nPeriodo:=1
  LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
  LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
  LOCAL nHeight:=0 // Alto
  LOCAL nLines :=0 // Lineas
  LOCAL lEdit  :=.F. 

  DEFAULT dFecha :=FCHINIMES(oDp:dFecha)-1,;
          cCodSuc:=oDp:cSucMain ,;
          nAno   :=IF(ValType(dFecha)="A",YEAR(dFecha[1]),YEAR(dFecha)) ,;
          nMes   :=MONTH(dFecha),;
          lFecha :=.F.          ,;
          cNumReg:=NIL,;
          dDesde :=CTOD(""),;
          dHasta :=CTOD(""),;
          lSemana:=.T.

  IF Type("oLiq30")="O" .AND. oLiq30:oWnd:hWnd>0
    RETURN EJECUTAR("BRRUNNEW",oLiq30,GetScript())
  ENDIF

/*

  IF ValType(dFecha)="A"

    oDp:dDesde:=dFecha[1]
    oDp:dHasta:=dFecha[2]

  ELSE

    oDp:dDesde:=CTOD("01/01/"+LSTR(nAno))
    oDp:dhasta:=CTOD("31/12/"+LSTR(nAno))

  ENDIF

*/

  cWhere:="PLP_CODSUC"+GetWhere("=",oDp:cSucMain)+" AND PLP_TIPDOC"+GetWhere("=",cTipDoc)

  IF COUNT("DPDOCPROPROG",cWhere)=0
    cWhere:="PLP_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND PLP_TIPDOC"+GetWhere("=",cTipDoc)
  ENDIF

  IF Empty(cCodPro)
     MsgMemo("Requiere Registro del TESORO NACIONAL")
     RETURN .F.
  ENDIF

//  cPplReg:=cNumReg // 05/05/2020
// ? cPplReg,"cPplReg",ValType(cPplReg)

/*
  IF ValType(dFecha)="A"

     dDesde :=dFecha[1]
     dHasta :=dFecha[2]
     lSemana:=.T.
     nAno   :=YEAR(dFecha)
     nMes   :=MONTH(dFecha)

     dFecha :=SQLGET("DPDOCPROPROG","PLP_FECHA,PLP_REFERE","PLP_NUMREG"+GetWhere("=",cNumReg)+" AND "+cWhere)
     cRefere:=DPSQLROW(2,"")

  ELSE

     dFecha :=SQLGET("DPDOCPROPROG","PLP_FECHA,PLP_REFERE","PLP_NUMREG"+GetWhere("=",cNumReg)+" AND "+cWhere)
     cRefere:=DPSQLROW(2,"")
     lSemana:=("Sem"$cRefere)

     nAno   :=YEAR(dFecha)
     nMes   :=MONTH(dFecha)

     IF lSemana
       dDesde:=EJECUTAR("GETLUNES",dFecha)-7
       dHasta:=dDesde+7
     ELSE
       dDesde:=CTOD("01/"+STRZERO(nMes,2)+"/"+STRZERO(nAno,4))
       dHasta:=FCHFINMES(dDesde)
     ENDIF

     dFecha :=SQLGET("DPDOCPROPROG","PLP_FECHA","PLP_NUMREG"+GetWhere("=",cNumReg)+" AND "+cWhere)

     // 2da quincena del mes Pasado 28/12/2023
     IF DAY(dFecha)<=15 
        dHasta:=FchIniMes(dFecha)-1
        dDesde:="15/"+LSTR(MONTH(dHasta))+"/"+LSTR(YEAR(dHasta))
        dHasta:=CTOO(dHasta,"D")
     ELSE
        dDesde:=FchIniMes(dFecha)
        dHasta:=dDesde+14
     ENDIF

  ENDIF

*/

  dDesde:=IF(Empty(dDesde),dFecha,dDesde)
  dHasta:=IF(Empty(dHasta),dFecha,dHasta)

  IF Empty(cPplReg) .AND. ValType(cPplReg)="C"

    lEdit :=.T.
    dFecha:=oDp:dFecha

    IF !oDp:lConEsp

      dHasta:=FCHINIMES(dFecha)-1
      dDesde:=FCHINIMES(dDesde)

    ELSE

      IF DAY(dFecha)<15

        nPeriodo:=2
        dHasta:=FCHINIMES(dFecha)-1
        dDesde:=CTOD("16/"+LSTR(MONTH(dHasta))+"/"+LSTR(YEAR(dHasta)))

      ELSE

        nPeriodo:=1
        dDesde:=FCHINIMES(dFecha)
        dHasta:=CTOD("15/"+LSTR(MONTH(dDesde))+"/"+LSTR(YEAR(dDesde)))

      ENDIF

      IF LEFT(oDp:cTipCon,1)="F"

       cWhere:="F30_FECHA"+GetWhere("<=",dFecha)+" ORDER BY F30_FECHA DESC "
       dHasta:=SQLGET("VIEW_DPCALF30","F30_FCHDEC,F30_FECHA",cWhere)
       dDesde:=DPSQLROW(2)
       dFecha:=dHasta

      ENDIF

    ENDIF

  ENDIF

  PUBLICO("lTodas",.F.)

  oData:=DATASET("CONFIG","ALL")

  DPEDIT():New("Autoliquidación de IVA [Forma30]","forms\DPFORMA30.EDT","oLiq30",.T.)

  // FORMAL
  IF LEFT(oDp:cTipCon,1)="F"
    EJECUTAR("GETFCHTRIMESTRE",oLiq30:dFecha)
    oLiq30:aMeses :={"Ene-Mar","Abr-Jun","Jul-Sep","Oct-Dic"} 
    oLiq30:nMes   :=oDp:nAt_Trimestre // MONTH(oLiq30:dFecha)
  ELSE
    oLiq30:aMeses :={"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"} 
    oLiq30:nMes   :=MONTH(oLiq30:dFecha)
  ENDIF

  oLiq30:dFecha :=dFecha
  oLiq30:nAno   :=YEAR(oLiq30:dFecha)

/*
  IF Empty(cNumReg)

     dDesde:=FCHINIMES(oDp:dFecha)

     IF DAY(oDp:dFecha)<=15 

        dDesde  :=dDesde-1
        nMes    :=MONTH(dDesde)
        dDesde  :=CTOD("16/"+LSTR(MONTH(dDesde))+"/"+LSTR(YEAR(dDesde)))
        dHasta  :=FCHFINMES(dDesde)
        nAno    :=YEAR(dHasta)
        nPeriodo:=2

     ELSE

        nMes    :=MONTH(dDesde)
        dHasta  :=CTOD("15/"+LSTR(MONTH(dDesde))+"/"+LSTR(YEAR(dDesde)))
        nAno    :=YEAR(dHasta)
        nPeriodo:=1

     ENDIF

     // dHasta:=FCHFINMES(oDp:dFecha)

     oLiq30:nMes   :=MONTH(dDesde)
     oLiq30:nAno   :=YEAR(dHasta)
     lSemana:=.T.

  ENDIF

  IF !oDp:lConEsp
     // LEFT(oDp:cTipCon,1)="O"
     dDesde:=FCHINIMES(dDesde)
     dHasta:=FCHFINMES(dDesde)
  ENDIF
 
*/

  oLiq30:nRadio :=nPeriodo
  oLiq30:oFecha :=NIL
  oLiq30:nRecord:=0
  oLiq30:lMsgBar:=.F.
  oLiq30:cCodSuc:=oDp:cSucursal
  oLiq30:cLugar :=oData:Get("cLugar" ,SPACE(30))
  oLiq30:cCodPro:=cCodPro // oData:Get("cSeniat",cCodPro)
  oLiq30:cNumero:=SPACE(10)
  oLiq30:cMemo   :=""
  oLiq30:cNombre :="Forma30"
  oLiq30:cAudita :="Forma 30"
  oLiq30:cTable  :=""
  oLiq30:cMemoTxt:=""
  oLiq30:cPplReg :=cPplReg //  cNumReg // Registro de Planificacion
  oLiq30:cNumReg :=cNumReg
  oLiq30:lFecha  :=lFecha
  oLiq30:lSemana :=lSemana
  oLiq30:lEdit   :=lEdit


  oLiq30:oDesde  :=NIL
  oLiq30:oHasta  :=NIL

  oLiq30:dDesde  :=dDesde
  oLiq30:dHasta  :=dHasta
  oLiq30:dFecha  :=dFecha
  oLiq30:lActivate:=.F.
  oLiq30:lMdiBar  :=.F.
  oLiq30:oNumReg  :=NIL
  oLiq30:lFacGub  :=.F. // Excluye facturas Gubernamental, REQUERIDO EN FORMA 30 28/12/2023
  oLiq30:oFecha   :=NIL


  oLiq30:SetScript("EDITFORMA30")

  IF cPplReg=NIL
    // oLiq30:cNumReg=NIL
    oLiq30:VALPLANIFICA(.F.)
  ENDIF
 
  oData:End(.F.)

  // SUCURSAL
  @ 2,1 GROUP oBtn TO 10, 21.5 PROMPT " Periodo "
  @ 9,1 GROUP oBtn TO 10, 21.5 PROMPT " Datos de la Planilla "
  @ 9,1 GROUP oBtn TO 10, 21.5 PROMPT " "+oDp:DPSUCURSAL+" "
  @ 9,1 GROUP oBtn TO 10, 21.5 PROMPT " Cta x Pagar [Tesorería Naciona]"
  @ 9,1 GROUP oBtn TO 10, 21.5 PROMPT " Transacciones [Desde-Hasta] "


  @ 3,2 SAY "Año" 
  @ 3,2 SAY IF(LEFT(oDp:cTipCon,1)="F","Trimestre","Mes")

  @ 0.5,3 GET oLiq30:oAno VAR oLiq30:nAno PICTURE "9999" SPINNER;
              VALID  oLiq30:DESDEHASTA();
              WHEN Empty(oLiq30:cPplReg) .AND. !oDp:lConEsp


// .AND. !oLiq30:lSemana) .OR. LEFT(oDp:cTipCon,1)="O"

  @ 2.0,3 COMBOBOX oLiq30:oMes VAR oLiq30:nMes ITEMS oLiq30:aMeses;
              WHEN Empty(oLiq30:cPplReg) .AND. !oDp:lConEsp ;
              ON CHANGE oLiq30:DESDEHASTA()

// .AND. !oLiq30:lSemana) .OR. LEFT(oDp:cTipCon,1)="O"


  // Debe buscar el Siguiente 
  @ 1,01 BUTTON oBtn PROMPT " > " ACTION oLiq30:NEXTMES(+1);
         WHEN Empty(oLiq30:cPplReg) .AND. !oDp:lConEsp

//oLiq30:lSemana ;

  oBtn:cToolTip:="Mes Siguiente"

  @ 1,10 BUTTON oBtn PROMPT " < " ACTION oLiq30:NEXTMES(-1);
         WHEN Empty(oLiq30:cPplReg) .AND. !oDp:lConEsp

// oLiq30:lSemana ;

  oBtn:cToolTip:="Mes Anterior"

  @ 4,1 SAY "Código"

  @ 3,2 SAY oLiq30:oSayRecord PROMPT "Proceso"

  @ .1,06 BMPGET oLiq30:oCodSuc VAR oLiq30:cCodSuc;
                 VALID CERO(oLiq30:cCodSuc,NIL,.T.) .AND.;
                            oLiq30:FindCodSuc();
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPSUCURSAL",NIL,NIL),;
                         oDpLbx:GetValue("SUC_CODIGO",oLiq30:oCodSuc)); 
                 WHEN Empty(oLiq30:cPplReg);
                 SIZE 48,10

  @ 3,2 SAY oLiq30:oSucNombre PROMPT SQLGET("DPSUCURSAL","SUC_DESCRI","SUC_CODIGO"+GetWhere("=",oLiq30:cCodSuc));
            UPDATE

  @ 3,2 GET oLiq30:cLugar 

  @ 3,1 SAY "Lugar:" 

  @ 3,2 GET oLiq30:cNumero 

  @ 3,1 SAY "Planilla:" 

  /*
  // Proveedor del Seniat
  */

  @ 10,06 BMPGET oLiq30:oCodPro;
                 VAR   oLiq30:cCodPro;
                 VALID CERO(oLiq30:cCodPro,NIL,.T.) .AND.;
                            oLiq30:FindCodPro();
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPPROVEEDOR",NIL,NIL),;
                         oDpLbx:GetValue("PRO_CODIGO",oLiq30:oCodPro)); 
                 SIZE 48,10

  @ 10,2 SAY oLiq30:oProNombre PROMPT SQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",oLiq30:cCodPro));
            UPDATE

  @ 11,1 SAY "Código:" 

  @ 02,01 METER oLiq30:oMeter VAR oLiq30:nRecord

  @ 5,0 GET oLiq30:oMemo VAR oLiq30:cMemo MULTILINE READONLY



  @ 07, 20 BMPGET oLiq30:oDesde  VAR oLiq30:dDesde;
                  PICTURE "99/99/9999";
                  NAME "BITMAPS\Calendar.bmp";
                  ACTION LbxDate(oLiq30:oDesde ,oLiq30:dDesde);
                  SIZE 76,20;
                  WHEN oLiq30:lEdit ;
                  FONT oFont

  oLiq30:oDesde:cToolTip:="F6: Calendario"

  @ 07, 30     BMPGET oLiq30:oHasta  VAR oLiq30:dHasta;
               PICTURE "99/99/9999";
               NAME "BITMAPS\Calendar.bmp";
               ACTION LbxDate(oLiq30:oHasta,oLiq30:dHasta);
               SIZE 76,20;
               WHEN oLiq30:lEdit ;
               FONT oFont

  oLiq30:oHasta:cToolTip:="F6: Calendario"



 @ 02,18  RADIO oLiq30:oRadio VAR oLiq30:nRadio;
          ITEMS "&Primera Quincena", "&Segunda Quincena" SIZE 60, 13 ;
          ON CHANGE oLiq30:HACERQUINCENA();
          WHEN Empty(oLiq30:cPplReg) .AND. oDp:lConEsp

 
  oLiq30:Activate({|| oLiq30:oBar:=SETBOTBAR(oLiq30:oDlg,55,70)})

  SETSCRIPT(oLiq30:oScript)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

//? oLiq30:oScript:cProgram

  oBar:=oLiq30:oBar

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          TOP PROMPT "Ejecutar"; 
          ACTION (CursorWait(),;
                   oLiq30:CALFECHAS(),;
                   oLiq30:CALDEBITOS(oLiq30:dDesde,oLiq30:dHasta))

   oBtn:cToolTip:="Ejecutar"


// IF oDp:nVersion>=6.0

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\XBROWSE.BMP";
           TOP PROMPT "Detalles"; 
           ACTION EJECUTAR("BRLIQFORMA30",NIL,NIL,11,oLiq30:dDesde,oLiq30:dHasta," Desde Libro de Ventas ")

    oBtn:cToolTip:="Visualizar Detalles de Forma 30"


    DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\facturavta.BMP";
          TOP PROMPT "Ventas"; 
          MENU EJECUTAR("BRBTNMENU",{"Libro de Ventas"},"oLiq30");
          ACTION  oLiq30:VERVENTAS()

    oBtn:cToolTip:="Visualizar Ventas"

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\facturacompra.BMP";
           TOP PROMPT "Compras"; 
           MENU EJECUTAR("BRBTNMENU",{"Libro de Compras"},"oLiq30");
           ACTION  oLiq30:VERCOMPRAS()

    oBtn:cToolTip:="Visualizar Compras"

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\CONTABILIDAD.BMP";
           TOP PROMPT "Cuenta";
           ACTION  EJECUTAR("BRTIPDOCPROCTA","TDC_TIPO"+GetWhere("=","F30"))

    oBtn:cToolTip:="Cuenta Contable"

  


// ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oLiq30:Close()

  nLin:=32

//  oBar:SetSize(NIL,70,.T.)
  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oLiq30:oBar:aControls,{|o,n|nLin:=nLin+o:nWidth(),o:SetColor(CLR_BLACK,oDp:nGris) })

//  oLiq30:ViewDatBar()

  IF Empty(oLiq30:cNumReg)

    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD


   @ 2,nLin SAYREF oLiq30:oNumReg PROMPT " Sin Registro de Planificación " OF oLiq30:oBar;
            SIZE 210,20;
            PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont


  ELSE


   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD


   @ 2,nLin SAY "Registro " OF oLiq30:oBar;
            SIZE 90,20;
            PIXEL BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont



   @ 23,nLin SAY "Fecha Pago " OF oLiq30:oBar;
            SIZE 90,20;
            PIXEL BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont


   DEFAULT oLiq30:cNumReg:=""


   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD UNDERLINE

   @ 2,nLin+71+20 SAYREF oLiq30:oNumReg PROMPT " "+oLiq30:cNumReg+" " OF oLiq30:oBar;
               SIZE 90+110,20 ;
               PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont 

   IF !oLiq30:oNumReg=NIL
      SayAction(oLiq30:oNumReg,{||oLiq30:VERREGPLA()})
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD 

   @ 23,nLin+71+20 SAY oLiq30:oFecha PROMPT " "+DTOC(oLiq30:dFecha)+" " OF oLiq30:oBar;
               SIZE 90,20;
               COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont;
               PIXEL BORDER 

  ENDIF

  oLiq30:lActivate:=.T.

  IF !oDp:lConEsp
    // LEFT(oDp:cTipCon,1)="O"
    oLiq30:VALPLANIFICA(NIL,.T.)
  ENDIF

  IF !oDp:lConEsp .OR. LEFT(oDp:cTipCon,1)="F"
    // LEFT(oDp:cTipCon,1)="F"
    oLiq30:oRadio:Hide()
  ENDIF

  oLiq30:oDesde:VarPut(oLiq30:dDesde,.T.)
  oLiq30:oHasta:VarPut(oLiq30:dHasta,.T.)

// ? oLiq30:cPplReg,"oLiq30:cPplReg"
// ? oLiq30:cPplReg,oLiq30:cNumReg,"cNumReg"

RETURN NIL

FUNCTION NEXTMES(nStep)

 IF LEFT(oDp:cTipCon,1)="O"

    IF nStep=1
      oLiq30:dDesde:=FCHFINMES(oLiq30:dDesde)+1
      oLiq30:dHasta:=FCHFINMES(oLiq30:dDesde)
    ELSE
      oLiq30:dDesde:=FCHINIMES(FCHINIMES(oLiq30:dDesde)-1)
      oLiq30:dHasta:=FCHFINMES(oLiq30:dDesde)
    ENDIF

    oLiq30:oDesde:Refresh(.T.)
    oLiq30:oHasta:Refresh(.T.)

  ELSE

     EJECUTAR("NEXTQUINCENA",oLiq30:oDesde,oLiq30:oHasta,nStep)

  ENDIF

  oLiq30:nAno:=YEAR(oLiq30:dHasta)
  oLiq30:oAno:Refresh(.T.)

  oLiq30:nMes:=MONTH(oLiq30:dHasta)
  oLiq30:oMes:Select(oLiq30:nMes)

  // oLiq30:VALPLANIFICA(.T.)
  oLiq30:VALPLANIFICA(NIL,.T.)


RETURN .T.


PROCE CALDEBITOS(dDesde,dHasta)
  LOCAL oData,oTable
  LOCAL aLineas:={}
  LOCAL cMemo,cBat,aBox,cMemoP,cVar,uValue,aLineas,nHandle,nLen,cLinea,cTemp,aReplace,xVar,nAt,cField,cFmt
  LOCAL cFileHtm,cFileOrg,nOpc,aFields,bBlq,cDos,cPeriodo,nContar,cCLAVE
  LOCAL cNumero,cDir,cEmpresa,cRif,cNit,cLugar,cMes,cAno,cDecAnt,dFecha,X,I,cWhereF
  LOCAL cMes_,cAno_,cWhere

  LOCAL nMto40:=0,nMto41:=0,nMto42:=0,nMto43:=0,nMto442:=0,nMto452:=0,nMto443:=0,nMto453:=0,nMto46:=0,nMto47:=0,nMto48:=0,nMto49:=0,nMto66:=0
  LOCAL nMto30:=0,nMto31:=0,nMto32:=0,nMto312:=0,nMto322:=0,nMto313:=0,nMto323:=0,nMto33:=0,nMto34:=0,nMto332:=0,nMto342:=0,nMto333:=0,nMto343:=0,nMto35:=0,nMto36:=0,nMto37:=0,nMto20:=0,nMto38:=0,nMto39:=0
  LOCAL nMto50:=0,nMto22:=0,nMto51:=0,nMto24:=0,nMto52:=0,nMto53:=0,nMto60:=0,nMto54:=0,nMto55:=0,nMto56:=0,nMto57:=0,nMto58:=0,nMto61:=0,nMto62:=0,nMto65:=0,nMto90:=0,nMto911:=0,nMto912:=0,nMto80:=0
  LOCAL nMto74:=0,nMto72:=0,nMto73:=0
  LOCAL nALIRED:=0,nALIADI

//  DEFAULT dDesde:=FCHINIMES(oDp:dFecha),;
//          dHasta:=FCHFINMES(oDp:dFecha)

  DEFAULT dDesde:=FCHINIMES(oDp:dFecha),;
          dHasta:=FCHFINMES(oDp:dFecha)

  // Determina el Numero de Planificación 
  oLiq30:VALPLANIFICA(.F.)

  IF oLiq30:lFecha .AND. !oLiq30:VALPLANIFICA()
     RETURN .F.
  ENDIF

  IF !SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_CODIGO"+GetWhere("=",oLiq30:cCodPro))=oLiq30:cCodPro .OR. Empty(oLiq30:cCodPro)
     MensajeErr(oDp:DPPROVEEDOR+" "+oLiq30:cCodPro+" no Existe")
     RETURN .T.
  ENDIF

  IF Empty(SQLGET("DPTIPDOCPRO","TDC_TIPO","TDC_TIPO"+GetWhere("=","F30"))) 

     MensajeErr("Es Necesario Crear Tipo de Documento F30")
     EJECUTAR("DPTIPDOCPRO",1,"F30")
     oTIPDOCPRO:oTDC_TIPO:VARPUT("F30",.T.)
     RETURN .F.

  ENDIF

  cWhere:="DOC_CODSUC"+GetWhere("=",oLiq30:cCodSuc)+" AND "+;
          "DOC_TIPDOC='F30' AND "+;
          "DOC_CODIGO"+GetWhere("=",oLiq30:cCodPro)+" AND "+;
          "DOC_FECHA "+GetWhere("=",dHasta      )+" AND "+;
          "DOC_TIPTRA='D'"

  cNumero:=SQLGET("DPDOCPRO","DOC_NUMERO,DOC_ESTADO,DOC_NETO",cWhere)

  IF !Empty(cNumero) .AND. !oDp:aRow[2]="AC"  .AND. oDp:aRow[3]>0
     MensajeErr("Documento F30, Número: "+cNumero+CRLF+;
                "Estado: "+SAYOPTIONS("DPDOCPRO","DOC_ESTADO",oDp:aRow[2]))
     RETURN .T.
  ENDIF

  oData:=DATASET("CONFIG","ALL")
  oData:Set("cLugar" ,oLiq30:cLugar )
  oData:Set("cSeniat",oLiq30:cCodPro)
  oData:Save()
  oData:End()

  cWhereF :=" AND "+GetWhereAnd("DOC_FECHA",dDesde,dHasta)
  
  cDos    :=":"+"/"+"/"
  cFileOrg:="SENIAT\FORMA30.HTM"
  LMKDIR(oDp:cDsnData) // Crea el Directorio

  cNumero :=oLiq30:cNumero
  cDir    :=oDp:cDir1
  cEmpresa:=oDp:cEmpresa
  cRif    :=oDp:cRif
  cLugar  :=ALLTRIM(oLiq30:cLugar )
  dFecha  :=dHasta
  cMes    :=STRZERO(MONTH(dFecha),2)
  cAno    :=STRZERO(YEAR(dFecha),4)

  cMes_   :=STRZERO(MONTH(FCHINIMES(dFecha)-1) , 2)
  cAno_   :=STRZERO(YEAR(FCHINIMES(dFecha)-1)  , 4)


  cFileHtm:=LOWER(oDp:cDsnData+"\FORMA30_"+cAno+"_"+ALLTRIM(CMES(dFecha))+".HTM")  // Archivo de Salid, Sugiere uno por Periodo
 

  oLiq30:oSayRecord:SetText("Leyendo Ventas")

// JN: Esto Genera Error, no tiene uso
//  cJoinDCli:=cJoinDCli+" AND "+GetWhereAnd("DOC_FECHA",dDesde,dHasta)

  oDp:oTableLibVta:=NIL
  // PROCE MAIN(lConEsp,lPlanilla,oLiq,cCodSuc,dDesde,dHasta,cNumero,lFecha,lFrm,lSemana,cRefere,nSemana,cWhereD)

  oTable:=EJECUTAR("DPLIBVTA",NIL,NIL,oLiq30,oLiq30:cCodSuc,oLiq30:dDesde,oLiq30:dHasta,NIL)


  IF oDp:oTableLibVta:ClassName()="TTABLE"
     oTable:=oDp:oTableLibVta
  ENDIF

  IF !oTable:ClassName()="TTABLE"
     MensajeErr("No fué Generado Objeto "+oTable:ClassName()+" Libro de Venta")
     RETURN .F.
  ENDIF

  nMto40:=0
  nMto42:=0  // Ventas Grabadas Alicuota General

  oTable:Gotop()

  WHILE !oTable:Eof()
 
     nMto40:=nMto40   + oTable:DOC_EXONER                                    // Ventas no Grabadas
 
     nMto41:=nMto41   + IIF( oTable:DOC_DESTIN='E'  , oTable:MOV_BASE   , 0) // Ventas Exportacion
     nMto42:=nMto42   + IIF( oTable:MOV_TIPIVA="GN" , oTable:MOV_BASE   , 0) // Total Ventas Tasa General
     nMto43:=nMto43   + IIF( oTable:MOV_TIPIVA="GN" , oTable:DOC_MTOIVA , 0) // Total Iva Tasa General

     nMto442:=nMto442 + IIF( oTable:MOV_TIPIVA="S1" , oTable:MOV_BASE   , 0) // Total Ventas Tasa Suntuaria
     nMto452:=nMto452 + IIF( oTable:MOV_TIPIVA="S1" , oTable:DOC_MTOIVA , 0) // Total Iva Tasa Suntuaria

     nMto443:=nMto443 + IIF( oTable:MOV_TIPIVA="RD" , oTable:MOV_BASE   , 0) // Total Ventas Tasa Reducida
     nMto453:=nMto453 + IIF( oTable:MOV_TIPIVA="RD" , oTable:DOC_MTOIVA , 0) // Total Iva Tasa Reducida

     // Retenciones del Periodo
     // nMto66:=nMto66 + IIF( oTable:DOC_TIPDOC="RTI" , oTable:DOC_MTORTI , 0) // Total Retenciones del Periodo
     // ? nMto66, "66"

     nMto66:=nMto66   + oTable:DOC_MTORTI

     oTable:DbSkip(1)

  ENDDO


  // CREDITOS FISCALES  ///////////////////////////////////////////////////////////////////////7

  oTable:=EJECUTAR("DPLIBCOM",NIL,NIL,oLiq30)

//oTable:BROWSE()

  IF !ValType(oTable)="O"
     MensajeErr("No fué Generado Objeto Libro de Compra")
     RETURN .F.
  ENDIF

//oTable:Browse()
  oTable:Gotop()

  WHILE !oTable:Eof()
 
     nMto30:=nMto30 + oTable:DOC_EXONER + oTable:DOC_NOSUJE                     // Compras no Grabadas

     nMto31:=nMto31 + IIF( oTable:DOC_ORIGEN='I'  , oTable:MOV_BASE , 0) // Compras importacion
     // nMto32:=nMto32
    
     // nMto312:=nMto312
     // nMto322:=nMto322

     // nMto313:=nMto313
     // nMto323:=nMto323

// ? oTable:MOV_BASE,"oTable:MOV_BASE "

     nMto33:=nMto33 + IIF( oTable:MOV_TIPIVA="GN" , oTable:MOV_BASE   , 0) // Compras Tasa Genera
     nMto34:=nMto34 + IIF( oTable:MOV_TIPIVA="GN" , oTable:DOC_MTOIVA , 0) // Compras Tasa Genera

     nMto332:=nMto332 + IIF( oTable:MOV_TIPIVA="S1" , oTable:MOV_BASE   , 0) // Total Compras Tasa Suntuaria
     nMto342:=nMto342 + IIF( oTable:MOV_TIPIVA="S1" , oTable:DOC_MTOIVA , 0) // Total Iva Tasa Suntuaria


     nMto333:=nMto333 + IIF( oTable:MOV_TIPIVA="RD" , oTable:MOV_BASE   , 0) // Total Compras Tasa Reducida
     nMto343:=nMto343 + IIF( oTable:MOV_TIPIVA="RD" , oTable:DOC_MTOIVA , 0) // Total Iva Tasa Reducida


     //     nMto66:=nMto66   + oTable:DOC_MTORTI
     // IVA Retenido en Compras.
     // nMto66:=nMto66 + IIF( oTable:DOC_TIPDOC="RTI" , oTable:DOC_MTORTI , 0) // Total Retenciones del Periodo

     oTable:DbSkip(1)

  ENDDO

  oTable:End()

  // Crédito Fiscal del Mes Anterior
//  nMto20:=SQLGET("DPLIQFORMA30","F30_60","F30_CODSUC"+GetWhere("=",oLiq30:cCodSuc)+;
//                                         " AND F30_ANO"+GetWhere("=",cAno_       )+;
//                                         " AND F30_MES"+GetWhere("=",cMes_       ))


 // Aqui Generamos en HTML
  aFields:={}
  AADD(aFields,"cNumero")    // N£mero de Planilla
  AADD(aFields,"cDir")       // Direcci¢n o Domicilio
  AADD(aFields,"cEmpresa")   // Nombre de la Empresa 
  AADD(aFields,"cRif")       // N£mero del Rif      
  AADD(aFields,"cLugar")     // Lugar                
  AADD(aFields,"cMes")       // Mes
  AADD(aFields,"cAno")       // A¤o
  AADD(aFields,"dFecha")     // Fecha 
  AADD(aFields,"nMto312",), AADD(aFields,"nMto322"), AADD(aFields,"nMto313"), AADD(aFields,"nMto323")
  AADD(aFields,"nMto332",), AADD(aFields,"nMto342"), AADD(aFields,"nMto333"), AADD(aFields,"nMto343")
  AADD(aFields,"nMto442",), AADD(aFields,"nMto452"), AADD(aFields,"nMto443"), AADD(aFields,"nMto453")
  AADD(aFields,"nMto911",), AADD(aFields,"nMto912"), AADD(aFields,"nMto40"),  AADD(aFields,"nMto41")
  AADD(aFields,"nMto42" ,), AADD(aFields,"nMto43"),  AADD(aFields,"nMto46"),  AADD(aFields,"nMto47")
  AADD(aFields,"nMto48" ,), AADD(aFields,"nMto49"),  AADD(aFields,"nMto30"),  AADD(aFields,"nMto31")
  AADD(aFields,"nMto32" ,), AADD(aFields,"nMto33"),  AADD(aFields,"nMto34"),  AADD(aFields,"nMto35")
  AADD(aFields,"nMto36" ,), AADD(aFields,"nMto37"),  AADD(aFields,"nMto20"),  AADD(aFields,"nMto38")
  AADD(aFields,"nMto39" ,), AADD(aFields,"nMto50"),  AADD(aFields,"nMto22"),  AADD(aFields,"nMto51")
  AADD(aFields,"nMto24" ,), AADD(aFields,"nMto52"),  AADD(aFields,"nMto53"),  AADD(aFields,"nMto60")
  AADD(aFields,"nMto54" ,), AADD(aFields,"nMto55"),  AADD(aFields,"nMto56"),  AADD(aFields,"nMto57")
  AADD(aFields,"nMto58" ,), AADD(aFields,"nMto61"),  AADD(aFields,"nMto62"),  AADD(aFields,"nMto65")
  AADD(aFields,"nMto90" ,), AADD(aFields,"nMto66"),  AADD(aFields,"nMto74"),  AADD(aFields,"nMto73")
  AADD(aFields,"nMto74" ,)
  nContar:=0

  aLineas:=oLiq30:LEEFORMA30() // Lee las Lineas desde FORMA30.HTM

 // Revisa las Variables
  aReplace:={}
  nContar :=0 
  bBlq    :=MACROEJE("{|a,i|xVar$a}")

  FOR I=1 TO LEN(aFields)

     cVar   :=ALLTRIM(aFields[I])

     IF TYPE(cVar)="U"

        MensajeErr("Variable "+cVar+" no Definida")

     ELSE

        uValue:=MacroEje(cVar)

        IF "NMTO"$UPPE(cVar) .AND. ValType(uValue)="N"
//         MOVER(STR(uValue,14,2),cVar)
//         MOVER(FDP(uValue,"999,999,999,999.99"),cVar)
          MOVER(uValue,cVar)
        ENDIF

        AADD(aReplace,cVar) 
     ENDIF

  NEXT I

  oLiq30:oSayRecord:SetText("Grabando Resultados")

  oLiq30:SAVEFORMA30()

  AUDITAR("PROC" , , "DPLIQFORMA30" ,"Cálculo de Forma30 "+DTOC(dHasta) )

  EJECUTAR("FORMA30LEE",cAno,cMes,oLiq30:cCodSuc,oLiq30:cPplReg)

/*

  cTemp  :="TEMP\F30"+cTempFile()+".HTML"
  fErase(cTemp)
  fCreate(cTemp) 
  nHandle :=fopen(cTemp,1) 
  nContar :=0

  oLiq30:oSayRecord:SetText("Generando "+cFileHtm)

  oLiq30:oMeter:SetTotal(LEN(aLineas))

  WHILE nContar<LEN(aLineas)

    nContar:=nContar+1
    oLiq30:oMeter:Set(nContar)

    cMemo  :=aLineas[nContar]
    bBlq   :=MACROEJE("{|a,i,cVar|cVar:=MACROEJE(a),cMemo:=STRTRAN(cMemo,aReplace[i],cVar)}")
    AEVAL(aFields,bBlq)
    aLineas[nContar]:=cMemo
    fwrite(nHandle,cMemo+CHR(13)+CHR(10))

  ENDDO 

  FCLOSE(nHandle)

  IF FILE(cTemp) .AND. LEN(aLineas)>0
  
    MsgRun("Ejecutando "+cTemp,"Ejecutando"+cTemp,;
              {||SHELLEXECUTE(oDp:oFrameDp:hWND,"open",cTemp)}) 

  ENDIF

*/


  oLiq30:oSayRecord:SetText(cFileHtm+" Creado Exitosamente")

RETURN

// Lectura del Formato Htm
FUNCTION LEEFORMA30()
  LOCAL aLineas :={},nContar:=0,nLen:=0,cLinea
  LOCAL nHandle 

  IF !FILE("SENIAT\FORMA30.HTM")
     RETURN {}
  ENDIF

  nHandle := fopen("SENIAT\FORMA30.HTM")

  WHILE fmove2next(nhandle)
    cLinea := sfreadline(nhandle),nContar:=nContar+1,nLen:=nLen+LEN(cLinea)+2
    AADD(aLineas,cLinea)
  ENDDO

  FCLOSE(nHandle)

RETURN aLineas

FUNCTION SAVEFORMA30()
   LOCAL oTable,cWhere:="",I,cVar,cField,uValue

   cWhere:="F30_CODSUC"+GetWhere("=",oLiq30:cCodSuc)+" AND "+;
           "F30_DESDE" +GetWhere("=",oLiq30:dDesde )+" AND "+;
           "F30_HASTA" +GetWhere("=",oLiq30:dHasta )

   SQLDELETE("DPLIQFORMA30",cWhere)

   // segun calendario fiscal
   cWhere:="F30_CODSUC"+GetWhere("=",oLiq30:cCodSuc)+" AND "+;
           "F30_NUMREG"+GetWhere("=",oLiq30:cNumReg)

   SQLDELETE("DPLIQFORMA30",cWhere)

   oTable:=OpenTable("SELECT * FROM DPLIQFORMA30 ",.F.)
   oTable:cWhere:=""
   oTable:Append()
   oTable:cWhere:=""

   oTable:Replace("F30_CODSUC",oLiq30:cCodSuc)
   oTable:Replace("F30_ANO"   ,cAno)
   oTable:Replace("F30_MES"   ,cMes)
   oTable:Replace("F30_NUMREG",oLiq30:cNumReg)
   oTable:Replace("F30_FECHA" ,oLiq30:dFecha) // Fecha de Pago segun calendario fiscal

   oTable:Replace("F30_DESDE",oLiq30:dDesde)
   oTable:Replace("F30_HASTA",oLiq30:dHasta)

   FOR I=1 TO LEN(aFields)

      cVar   :=ALLTRIM(aFields[I])

      IF "NMTO"$UPPE(cVar) 

         cField :="F30_"+SUBS(cVar,5,4)
         uValue :=MacroEje(cVar)
         oTable:Replace(cField,uValue)

      ENDIF
   
   NEXT I

   oTable:Commit(oTable:cWhere)

   // oTable:Browse()
  
   EJECUTAR("FORMA30CALC", cAno  , cMes , oLiq30:cCodSuc,oLiq30:cPplReg,oLiq30:dDesde,oLiq30:dHasta,oLiq30:dFecha )
   oTable:End()

RETURN .T.      

FUNCTION FINDCODSUC()

  IF !ISSQLGET("DPSUCURSAL","SUC_CODIGO",oLiq30:cCodSuc)
    oLiq30:oCodSuc:KeyBoard(VK_F6)
  ENDIF

  oLiq30:oSucNombre:Refresh(.T.)

RETURN .T.

FUNCTION FINDCODPRO()

  IF !ISSQLGET("DPPROVEEDOR","PRO_CODIGO",oLiq30:cCodPro)
     oLiq30:oCodPro:KeyBoard(VK_F6)
  ENDIF

  oLiq30:oProNombre:Refresh(.T.)

RETURN .T.

FUNCTION CALFECHAS()
 LOCAL dDesde:=oLiq30:dDesde,dHasta:=oLiq30:dHasta 

 oLiq30:dDesde:=CTOO(oLiq30:dDesde,"D")
 oLiq30:dHasta:=CTOO(oLiq30:dHasta,"D")

RETURN .T.

/*
// Valida que la Fecha no pertenece a Planificación
*/
FUNCTION VALPLANIFICA(lValida,lReset)
  LOCAL cNumero,dFecha:=oDp:dFecha
//,dDesde,dHasta
  LOCAL cWhere
  LOCAL dDesde:=oLiq30:dDesde,dHasta:=oLiq30:dHasta

  DEFAULT lReset:=.F.

  IF !Empty(oLiq30:cPplReg) .AND. !lReset
     RETURN .T.
  ENDIF

  // Quinceal debe buscar en la Quincena Siguiente, 05/12/2021 AL 31/12/2021, Corresponde calendario quincema enero

  DEFAULT lValida:=.T.

  cNumero:=EJECUTAR("GETNUMPLAFISCAL",oLiq30:cCodSuc,"F30",oLiq30:dHasta)

// ? oDp:cSql,cNumero
// ? "AQUI VALIDA VALPLANIFICA",cNumero

  IF !Empty(cNumero)

     cWhere:="  PLP_CODSUC"+GetWhere("=",oLiq30:cCodSuc)+;
             "  AND PLP_TIPDOC"+GetWhere("=","F30")+;
             "  AND PLP_NUMREG"+GetWhere("=",cNumero)

     dFecha:=SQLGET("DPDOCPROPROG","PLP_FECHA",cWhere)

     // Caso de Contribuyente FORMAL

     IF LEFT(oDp:cTipCon,1)="F"

       cWhere:="F30_FECHA"+GetWhere("=",dFecha)
       dHasta:=SQLGET("VIEW_DPCALF30","F30_FCHDEC,F30_FECHA",cWhere)
       dDesde:=DPSQLROW(2)
       dFecha:=dHasta

     ELSE

       IF !oDp:lConEsp

         dHasta:=FCHINIMES(dFecha)-1
         dDesde:=FCHINIMES(dDesde)

       ELSE

         IF DAY(dFecha)<15
            oLiq30:nRadio:=2
            dHasta:=FCHINIMES(dFecha)-1
            dDesde:=CTOD("16/"+LSTR(MONTH(dHasta))+"/"+LSTR(YEAR(dHasta)))
         ELSE
            oLiq30:nRadio:=1
            dDesde:=FCHINIMES(dFecha)
            dHasta:=CTOD("15/"+LSTR(MONTH(dDesde))+"/"+LSTR(YEAR(dDesde)))
        ENDIF

        // oLiq30:oRadio:Refresh(.T.)

       ENDIF

       oLiq30:nMes:=MONTH(dDesde)

     ENDIF


     IF ValType(oLiq30:oDesde)="O"
        oLiq30:oDesde:VarPut(dDesde,.T.)
        oLiq30:oHasta:VarPut(dHasta,.T.)
     ELSE
        oLiq30:dDesde:=dDesde
        oLiq30:dHasta:=dHasta
     ENDIF

     // ? dDesde,dHasta
     // ? dFecha,"<-dFecha",oLiq30:dHasta,dDesde,dHasta

     IF oLiq30:oFecha<>NIL
        oLiq30:dFecha:=dFecha
        oLiq30:oFecha:Refresh(.T.)
     ENDIF

  ENDIF

  IF !Empty(cNumero) 

    // oLiq30:cPplReg :=cNumero
    oLiq30:cNumReg :=cNumero
    oLiq30:dFecha  :=dFecha

    IF ValType(oLiq30:oNumReg)="O"
      oLiq30:oNumReg:SetText(" "+cNumero)
    ENDIF

  ELSE

    IF ValType(oLiq30:oNumReg)="O"
      oLiq30:oNumReg:SetText("Indefinida")
    ENDIF

    oLiq30:cPplReg :=cNumero
    oLiq30:cNumReg :=cNumero
    oLiq30:dFecha  :=CTOD("")

  ENDIF

  IF ValType(oLiq30:oFecha)="O"
    oLiq30:oFecha:Refresh(.T.)
  ENDIF

  IF Empty(cNumero) .AND. lValida .AND. LEFT(oDp:cTipCon,1)<>"O"

    oLiq30:oAno:MsgErr("Fecha "+DTOC(oLiq30:dDesde)+" - "+DTOC(oLiq30:dHasta)+CRLF+"No Posee registro de Planificación "+cNumero,oLiq30:cTitle)

    IF LEFT(oDp:cTipCon,1)="O"
       RETURN .T.
    ENDIF

    RETURN .F.
  ENDIF

RETURN .T.

FUNCTION BTNMENU(nOption,cOption)
  LOCAL cWhere,cCodSuc:=oDp:cSucursal
  LOCAL cNumero:=oLiq30:cPplReg,lFecha,lFrm:=.F.

  oLiq30:CALFECHAS()

// ? nOption,cOption,"nOption,cOption"

  IF nOption=1 .AND. cOption="Libro de Ventas"
     EJECUTAR("DPLIBVTA",NIL,NIL,NIL,cCodSuc,oLiq30:dDesde,oLiq30:dHasta,NIL,.T.)
     RETURN .T.
  ENDIF

  IF nOption=1 .AND. cOption="Libro de Compras"
     EJECUTAR("DPLIBCOM",NIL,NIL,NIL,NIL,oLiq30:dDesde,oLiq30:dHasta,cNumero,.T.)
     RETURN .T.
  ENDIF

RETURN .T.


FUNCTION VERVENTAS()
  LOCAL cWhere,cCodSuc:=oDp:cSucursal,nPeriodo:=12,cTitle:=NIL

  oLiq30:CALFECHAS()

  EJECUTAR("BRSERFISCAL",cWhere,cCodSuc,nPeriodo,oLiq30:dDesde,oLiq30:dHasta,cTitle)

RETURN .T.

FUNCTION VERCOMPRAS()
  LOCAL cWhere,cCodSuc:=oDp:cSucursal,nPeriodo:=12,cTitle:=NIL

  oLiq30:CALFECHAS()

  EJECUTAR("BRDOCPRORET",cWhere,cCodSuc,nPeriodo,oLiq30:dDesde,oLiq30:dHasta,cTitle)

RETURN .T.

FUNCTION VERREGPLA()
   LOCAL cWhere:="PLP_TIPDOC"+GetWhere("=","F30")+" AND PLP_NUMREG"+GetWhere("=",oLiq30:cNumReg)
   LOCAL cTitle:=NIL,lData:=NIL

RETURN EJECUTAR("BRCALFISDET",cWhere,oDp:cSucursal,11,CTOD(""),CTOD(""),cTitle,lData)


FUNCTION HACERQUINCENA()
   LOCAL dDesde,dHasta,nMes,nAno,nPeriodo,cMes

   IF !oLiq30:lActivate
      RETURN .F.
   ENDIF

   dDesde:=FCHINIMES(oDp:dFecha)

   IF oLiq30:nRadio=2

      dDesde  :=dDesde-1
      nMes    :=MONTH(dDesde)
      dDesde  :=CTOD("16/"+LSTR(MONTH(dDesde))+"/"+LSTR(YEAR(dDesde)))
      dHasta  :=FCHFINMES(dDesde)
      nAno    :=YEAR(dHasta)
      nPeriodo:=2

   ELSE

      nMes    :=MONTH(dDesde)
      dHasta  :=CTOD("15/"+LSTR(MONTH(dDesde))+"/"+LSTR(YEAR(dDesde)))
      nAno    :=YEAR(dHasta)
      nPeriodo:=1

   ENDIF

   oLiq30:oDesde:VarPut(dDesde,.T.)
   oLiq30:oHasta:VarPut(dHasta,.T.)

   oLiq30:oMes:Select(nMes)
   oLiq30:oAno:VarPut(nAno,.T.)

   // oLiq30:VALPLANIFICA(.F.)
   oLiq30:VALPLANIFICA(NIL,.T.)


RETURN .T.

FUNCTION DESDEHASTA()

  oLiq30:dDesde:=CTOD(LSTR(DAY(oLiq30:dDesde))+"/"+LSTR(oLiq30:oMes:nAt)+"/"+LSTR(oLiq30:nAno))
  oLiq30:dHasta:=CTOD(LSTR(DAY(oLiq30:dHasta))+"/"+LSTR(oLiq30:oMes:nAt)+"/"+LSTR(oLiq30:nAno))

  IF LEFT(oDp:cTipCon,1)="O"
    oLiq30:dDesde:=CTOD("01/"+LSTR(oLiq30:nMes)+"/"+LSTR(oLiq30:nAno))
    oLiq30:dHasta:=FCHFINMES(oLiq30:dDesde)
  ENDIF


  oLiq30:oDesde:Refresh(.T.)
  oLiq30:oHasta:Refresh(.T.)

  oLiq30:VALPLANIFICA(NIL,.T.)

RETURN .T.
// EOF
