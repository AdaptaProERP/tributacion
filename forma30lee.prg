// Programa   : FORMA30LEE
// Fecha/Hora : 23/04/2008 02:46:58
// Propósito  : Visualiza la Forma 30
// Creado Por : Juan Navas
// Llamado por: FORMA30
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cAno,cMes,cCodSuc,cNumReg)
   LOCAL dFecha :=FCHINIMES(oDp:dFecha)-1
   LOCAL lF30Ant:=.F. // Determina si el Mes pasado hubo F30
   LOCAL aPla:={},aData:={},cTitle,aPlanilla:={},oData
   LOCAL cAno_:="",cMes_:="",cCodPro
   LOCAL cWhere :="" // Unica condicion para leer y Actualizar
   LOCAL cWhereA:="" // Unica Condición del Libro Anterior
   LOCAL dDesde,dHasta,oTable

   IF Type("oF30")="O" .AND. oF30:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oF30,GetScript())
   ENDIF

   IF Empty(cAno)

      cMes   :=STRZERO(MONTH(dFecha),2)
      cAno   :=STRZERO(YEAR(dFecha),4)
      cCodSuc:=oDp:cSucursal


      IF LEFT(oDp:cTipCon,1)="O"
         dDesde:=CTOD("01/"+cMes+"/"+cAno)
         dHasta:=FCHFINMES(dDesde)
      ENDIF

   ENDIF

   DEFAULT cNumReg:=""

   // Periodo Anterior
/*
 28/12/2023 innecesario
   dFecha:=FCHINIMES("01/"+cMes+"/"+cAno)-1
   cMes_ :=STRZERO(MONTH(dFecha),2)
   cAno_ :=STRZERO(YEAR(dFecha) ,4)
*/
   oData:=DATASET("CONFIG","ALL")
   cCodPro:=oData:Get("cSeniat",SPACE(10))
   oData:End()


   IF Empty(cNumReg)

     cWhere:="F30_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND F30_NUMREG"+GetWhere("=",cNumReg)

   ELSE

// 28/12/2023 
//     cWhere:="F30_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
//             "F30_ANO"   +GetWhere("=",cAno  )+" AND "+;
//             "F30_MES"   +GetWhere("=",cMes  )

     cWhere:="F30_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
             "F30_NUMREG"+GetWhere("=",cNumReg      )

   ENDIF

   oTable:=OpenTable("SELECT * FROM DPLIQFORMA30 WHERE "+cWhere,.T.)
//   oTable:Browse()

   dDesde:=oTable:F30_DESDE
   dHasta:=oTable:F30_HASTA
   // 28/12/2023, ahora debe mostrar la fecha de declaracion
   dFecha:=oTable:F30_FECHA
   cMes_ :=STRZERO(MONTH(dFecha),2)
   cAno_ :=STRZERO(YEAR(dFecha) ,4)

   cMes  :=cMes_
   cAno  :=cAno_

   IF oTable:RecCount()=0 .AND. LEFT(oDp:cTipCon,1)="O"
      dDesde:=FCHINIMES(oDp:dFecha)
      dHasta:=FCHFINMES(dDesde)
   ENDIF

   oTable:End()

   IF ISSQLFIND("DPLIQFORMA30","F30_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                               "F30_ANO"   +GetWhere("=",cAno_  )+" AND "+;
                               "F30_MES"   +GetWhere("=",cMes_  ))
     lF30Ant:=.T.
 
   ENDIF

   AADD(aPla,{" "  , "DEBITOS FISCALES"           , "  " , "BASE IMPONIBLE" , " " , "DEBITO FISCAL"})
   AADD(aPla,{" 1" , "Ventas Internas No Grabadas", "40" , "F30_40"         , " " , ""})
   AADD(aPla,{" 2" , "Ventas Exportación         ", "41" , "F30_41"         , " " , ""})

   AADD(aPla,{" 3" , "Ventas Internas Grabadas   "+;
                     "Sólo por Alícuota General  ", "42" , "F30_42"         , "43", "F30_43"})

   AADD(aPla,{" 4" , "Ventas Internas Grabadas por "+;
                     "alícuota General más Adicional", "442" , "F30_442"         , "452", "F30_452"})


   AADD(aPla,{" 5" , "Ventas Internas Grabadas por "+;
                     "alícuota Reducida             ", "443" , "F30_443"         , "453", "F30_453"})


   AADD(aPla,{" 6" , "Total Ventas y Débitos Fiscales"+;
                     "para efectos de determinación ", "46" , "F30_46"         , "47", "F30_47"})

   AADD(aPla,{" 7" , "Ajustes a los créditos Fiscal"+;
                     "en periodos anteriores..........", "  " , "      "         , "48", "F30_48"})

   AADD(aPla,{" 8" , "Certificados de Débitos Fiscal"+;
                     "exonerados (recibidos entes exonerados)","  " , "      "      , "80", "F30_80"})

   AADD(aPla,{" 9" , "Total Débitos Fiscales        "      ,"  " , "      "      , "49", "F30_49"})


   //
   // Compras
   //

   AADD(aPla,{" "  , "CREDITOS FISCALES"                 , "  " , "BASE IMPONIBLE" , " " , "CREDITO FISCAL"})

   AADD(aPla,{"10" , "Compras no Gravadas y/o sin "+;
                     "derecho a crédito Fiscal"          , "30" , "F30_30"         , " " , ""})

   AADD(aPla,{"11" , "Importación Gravada por "+;
                     "alícuota General"                  , "31" , "F30_31"         , "32" , "F30_32"})

   AADD(aPla,{"12" , "Importación Gravada por "+;
                     "alícuota General más Adicional"    , "312" , "F30_312"        , "322", "F30_322"})

   AADD(aPla,{"13" , "Importación Gravada por "+;
                     "alícuota Reducida             "     , "313" , "F30_313"        , "323", "F30_323"})

   AADD(aPla,{"14" , "Compras Internas Gravadas "+;
                     "por Alícuota General          "     , "33"  , "F30_33"        , "34", "F30_34"})

   AADD(aPla,{"15" , "Compras Internas Gravadas "+;
                     "por Alícuota General + Adicional"   , "332" , "F30_332"      , "342", "F30_342"})

   AADD(aPla,{"16" , "Compras Internas Gravadas  "+;
                     "por Alícuota Reducida           "    , "333" , "F30_333"      , "343", "F30_343"})

   AADD(aPla,{"17" , "Total Compras y Créditos  "+;
                     "fiscales del Periodo           "      , "35" , "F30_35"        , "36", "F30_36"})

   AADD(aPla,{"18" , "Crédito Fiscales Totalmente Deducibles","  " , "      "      , "70", "F30_70"})

   AADD(aPla,{"19" , "Crédito Fiscales Producto de la"+;
                     "Aplicación del % Prorrata (Item36 - Item70 x %)"    ,"  " , "      "      , "37", "F30_37"})

   AADD(aPla,{"20" , "Total Créditos Fiscales deducibles "+;
                     "...realice operación (item 70 + Item 37)","  " , "      "      , "71", "F30_71"})

   AADD(aPla,{"21" , "Excedente Créditos Fiscales del mes "+;
                     "anterior (item 60 declaración Anterior)" ,"  " , "      "      , "20", "F30_20"})

   AADD(aPla,{"22" , "Reintegro Solicitado (Solo Exportadores"+;
                     ")"                                        ,"  " , "      "      , "21", "F30_21"})

   AADD(aPla,{"23" , "Reintegro Solicitado (Solo quien suministre"+;
                     " bienes o presten servicios en entes exoner"+;
                     "ados)"                                      ,"  " , "     "      , "81", "F30_81"})

   AADD(aPla,{"24" , "Ajustes a los Créditos Fiscales de Periodos"+;
                     " anteriores ...."                           ,"  " , "     "      , "38", "F30_38"})

   AADD(aPla,{"25" , "Certificados de Débitos Fiscales Exonerados"+;
                     "(Emitidos por Entes Exonerados"              ,"  " , "     "      , "82", "F30_82"})

   AADD(aPla,{"26" , "Total Créditos Fiscales."                    ,"  " , "     "      , "39", "F30_39"})


/*
// AutoLiquidación
*/

   AADD(aPla,{"c."  , "AUTOLIQUIDACION"                             , "  " , "              " , " " , "             "})

   AADD(aPla,{"27" , "Total Cuota Tributaria del Periodo"+;
                     "                               "          ,"  " , "     "      , "53", "F30_53"})

   AADD(aPla,{"28" , "Execedente de Crédito para el mes"+;
                     " siguiente                      "          ,"  " , "     "      , "60", "F30_60"})

   AADD(aPla,{"29" , "Impuesto Pagado en Declaracion(es)"+;
                     "sustituida(s)"                              , "22" , "F30_22"         , " " , ""})

   AADD(aPla,{"30" , "Retenciones Descontadas en declaracion(es)"+;
                     " sustituida(s)"                              , "51" , "F30_51"         , " " , ""})

   AADD(aPla,{"31" , "Percepciones descontadas en declaració(es)"+;
                     " sustituida(s)"                              , "24" , "F30_24"         , " " , ""})

   AADD(aPla,{"32" , "Sub-Total de Impuesto a Pagar (Item 53 - "+;
                     " Item 22 - Item 51 - Item 24 > 0 )"           , "  " , "      "         , "78" , "F30_78"})

   AADD(aPla,{"33" , "Retenciones Acumuladas por Descontar"+;
                     " "                                             , "54" , "F30_54"         , " " , ""})
   AADD(aPla,{"34" , "Retenciones del Periodo             "+;
                     " "                                             , "66" , "F30_66"         , " " , ""})

   AADD(aPla,{"35" , "Créditos Adquiridos por Cesión de "+;
                     "Retenciones"                                    , "72" , "F30_72"         , " " , ""})

   AADD(aPla,{"36" , "Recuperación de Retenciones Solici"+;
                     "tado       "                                    , "73" , "F30_73"         , " " , ""})

   AADD(aPla,{"37" , "Total Retenciones..."+;
                     "            "                                   , "74" , "F30_74"         , " " , ""})

   AADD(aPla,{"38" , "Retenciones Soportadas y Descontadas "+;
                     "                                "             , "  " , "      "         , "55" , "F30_55"})

   AADD(aPla,{"39" , "Saldo de Retenciones de IVA no"+;
                     " Aplicado "                                    , "67" , "F30_67"         , " " , ""})


   AADD(aPla,{"40" , "Sub-Total Impuesto a Pagar (Realice "+;
                     " item 78 - Item 55)              "             , "  " , "      "         , "56" , "F30_56"})

   AADD(aPla,{"41" , "Percepciones Acumuladas en Imp"+;
                     "ortaciones por Descontar"                      , "57" , "F30_57"         , " " , ""})

   AADD(aPla,{"42" , "Percepciones del Periodo"+;
                     ""                                               , "68" , "F30_68"         , " " , ""})

   AADD(aPla,{"43" , "Créditos Adquiridos por cesión de"+;
                     " percepciones"                                   , "75" , "F30_75"         , " " , ""})

   AADD(aPla,{"44" , "Recuperación de Percepciones Soli"+;
                     "citado       "                                   , "76" , "F30_76"         , " " , ""})

   AADD(aPla,{"45" , "Total Percepciones               "+;
                     "             "                                   , "77" , "F30_77"         , " " , ""})

   AADD(aPla,{"46" , "Percepciones en Aduanas Decontadas  "+;
                     "                                "             , "  " , "      "            , "58" , "F30_58"})

   AADD(aPla,{"47" , "Saldo de Percepción en Aduanas no"+;
                     " Aplicado    "                                   , "69" , "F30_69"         , " " , ""})

   AADD(aPla,{"48" , "TOTAL A PAGAR (Item 56 - Item 58)"+;
                     "                                "             , "  " , "      "            , "90" , "F30_90"})
   aPlanilla:=ACLONE(aPla)

   aData :=LEELIQ30(aPla,cAno,cMes,cCodSuc,cWhere)
   cTitle:="Resultado de la Forma 30 [ "+LSTR(DAY(dFecha))+" - "+ALLTRIM(CMES(cMes))+" - "+cAno+" ]"

   ViewData(aPla,cAno,cMes,oDp:cSucursal,cTitle,cNumReg)

RETURN NIL


FUNCTION ViewData(aData,cAno,cMes,cCodSuc,cTitle,cNumReg)
   LOCAL oBrw,oFont,oFontB
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

/*
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD
   oF30:=DPEDIT():New(cTitle,"FORMA30LEE.EDT","oF30",.T.)
*/

//ViewArray(aPla)

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oF30","FORMA30LEE.EDT")
   oF30:Windows(0,0,aCoors[3]-(140+oDp:oBar:nHeight()),MIN(900,aCoors[4]-10),.T.) // Maximizado

   oF30:cAno     :=cAno
   oF30:cMes     :=cMes
   oF30:cCodSuc  :=cCodSuc
   oF30:cCodPro  :=cCodPro
   oF30:cNombre  :=""
   oF30:lMsgBar  :=.F.
   oF30:aPlanilla:=aPlanilla
   oF30:cNumReg  :=cNumReg

   oF30:nClrBarra:=12566463

   oF30:dDesde   :=dDesde
   oF30:dHasta   :=dHasta
   oF30:cWhere   :=cWhere

   IF ValType(ATAIL(aPla)[6])="C"
     oF30:nMonto   :=VAL(STRTRAN(ATAIL(aPla)[6],",",""))
   ELSE
     oF30:nMonto   :=ATAIL(aPla)[6]
   ENDIF

   oF30:nMonto:=CTOO(oF30:nMonto,"N")

   oF30:cEdit    :="F30_82,F30_57,F30_68,F30_75,F30_76,F30_80,F30_20,F30_21,F30_54,F30_81"+;
                    IIF(!lF30Ant,",F30_48","")  


/* Se inhabilito F30_20
   oF30:cEdit    :="F30_82,F30_57,F30_68,F30_75,F30_76,F30_80,F30_21,F30_81,F30_20"+;
                    IIF(!lF30Ant,",F30_48","")
*/

   oF30:oBrw:=TXBrowse():New( oF30:oWnd )

   oF30:oBrw:SetArray( aData, .F. )
   oF30:oBrw:SetFont(oFontB)

   oF30:oBrw:lHeader     := .F.
   oF30:oBrw:lFooter     := .F.
   oF30:oBrw:lHScroll    := .F.
   oF30:oBrw:nDataLines  :=2
   oF30:oBrw:nHeaderLines:=0

   AEVAL(oF30:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

// oF30:oBrw:aCols[1]:cHeader      :="Titulo"
   oF30:oBrw:aCols[1]:nWidth       :=30

   oF30:oBrw:aCols[1]:bClrStd      := {|oBrw,nClrText,aData,nClrPane1,nClrPane2|oBrw:=oF30:oBrw,;
                                        nClrPane1:=12566463,nClrPane2:=12566463,;
                                        nClrPane2:=IIF(oBrw:nArrayAt=1 .OR. oBrw:nArrayAt=11 .OR. oBrw:nArrayAt=29 .OR. oBrw:nArrayAt=51, oDp:nLbxClrHeaderPane,nClrPane2),;
                                        aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                        nClrText:=0,;
                                        {nClrText,iif( oBrw:nArrayAt%2=0, nClrPane1, nClrPane2) } }

   oF30:oBrw:aCols[2]:nWidth       :=340+100

   oF30:oBrw:aCols[3]:nWidth       :=30
   oF30:oBrw:aCols[3]:bClrStd      := {|oBrw,nClrText,aData,nClrPane1,nClrPane2|oBrw:=oF30:oBrw,;
                                        nClrPane1:=16770764,nClrPane2:=16566954,;
                                        nClrPane2:=IIF(oBrw:nArrayAt=1 .OR. oBrw:nArrayAt=11 .OR. oBrw:nArrayAt=29 .OR. oBrw:nArrayAt=51, oDp:nLbxClrHeaderPane,nClrPane2),;
                                        aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                        nClrText:=5197647,;
                                        {nClrText,iif( oBrw:nArrayAt%2=0, nClrPane1, nClrPane2) } }


   oF30:oBrw:aCols[5]:bClrStd       := oF30:oBrw:aCols[3]:bClrStd
   oF30:oBrw:aCols[5]:nWidth       :=30

   oF30:oBrw:aCols[4]:nWidth       :=150
   oF30:oBrw:aCols[4]:nDataStrAlign:= AL_RIGHT
   oF30:oBrw:aCols[4]:nHeadStrAlign:= AL_RIGHT

// oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane

   oF30:oBrw:aCols[4]:bClrStd      := {|oBrw,nClrText,aData,nClrPane1,nClrPane2,cCol|oBrw:=oF30:oBrw,;
                                        nClrPane1:=16770764,nClrPane2:=16566954,;
                                        nClrPane2:=IIF(oBrw:nArrayAt=1 .OR. oBrw:nArrayAt=11 .OR. oBrw:nArrayAt=29 .OR. oBrw:nArrayAt=51, oDp:nLbxClrHeaderPane,nClrPane2),;
                                        aData    :=oBrw:aArrayData[oBrw:nArrayAt]  ,;
                                        cCol     :=oF30:aPlanilla[oBrw:nArrayAt,4] ,;
                                        nClrText :=IIF( cCol$oF30:cEdit , CLR_HBLUE,0),;
                                        {nClrText,iif( oBrw:nArrayAt%2=0, nClrPane1, nClrPane2) } }


   oF30:oBrw:aCols[6]:nWidth       :=150
   oF30:oBrw:aCols[6]:nDataStrAlign:= AL_RIGHT
   oF30:oBrw:aCols[6]:nHeadStrAlign:= AL_RIGHT

   oF30:oBrw:aCols[6]:bClrStd      := {|oBrw,nClrText,aData,nClrPane1,nClrPane2,cCol|oBrw:=oF30:oBrw,;
                                        nClrPane1:=16770764,nClrPane2:=16566954,;
                                        nClrPane2:=IIF(oBrw:nArrayAt=1 .OR. oBrw:nArrayAt=11 .OR. oBrw:nArrayAt=29 .OR. oBrw:nArrayAt=51, oDp:nLbxClrHeaderPane,nClrPane2),;
                                        aData    :=oBrw:aArrayData[oBrw:nArrayAt]  ,;
                                        cCol     :=oF30:aPlanilla[oBrw:nArrayAt,6] ,;
                                        nClrText :=IIF( cCol$oF30:cEdit , CLR_HBLUE,0),;
                                        {nClrText,iif( oBrw:nArrayAt%2=0, nClrPane1, nClrPane2) } }



   oF30:oBrw:bClrStd               := {|oBrw,nClrText,aData,nClrPane1,nClrPane2|oBrw:=oF30:oBrw,;
                                        nClrPane1:=16770764,nClrPane2:=16566954,;
                                        nClrPane2:=IIF(oBrw:nArrayAt=1 .OR. oBrw:nArrayAt=11 .OR. oBrw:nArrayAt=29 .OR. oBrw:nArrayAt=51, oDp:nLbxClrHeaderPane,nClrPane2),;
                                        aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                        nClrText:=0,;
                                        {nClrText,iif( oBrw:nArrayAt%2=0, nClrPane1, nClrPane2) } }

   oF30:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oF30:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oF30:oBrw:bKeyDown({|nkey| IF(nKey>30, oF30:SETCOLEDIT(nKey) , NIL) })
   oF30:oBrw:CreateFromCode()

   oF30:oBrw:aCols[4]:bLDClickData := {||oF30:SETCOLEDIT()}  // Editar Columna
   oF30:oBrw:aCols[6]:bLDClickData := {||oF30:SETCOLEDIT()}  // Editar Columna

   oF30:oWnd:oClient := oF30:oBrw

   oF30:Activate({||oF30:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oF30:oDlg,nLin:=400

   DEFINE CURSOR oCursor HAND

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oF30:oFontBtn   :=oFont    
   oF30:nClrPaneBar:=oDp:nGris
   oF30:oBrw:oLbx  :=oF30

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP";
          TOP PROMPT "Grabar"; 
          ACTION  oF30:GRABARFORMA30()

   oBtn:cToolTip:="Grabar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CBTEPAGO.BMP",NIL,"BITMAPS\CBTEPAGOG.BMP";
          TOP PROMPT "Pagar"; 
          WHEN oF30:nMonto>0; 
          ACTION oF30:HACERPAGO()

   oBtn:cToolTip:="Realizar Pago"
   oF30:oBtnPago:=oBtn


   DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\facturavta.BMP";
           TOP PROMPT "Ventas"; 
           MENU EJECUTAR("BRBTNMENU",{"Libro de Ventas"},"oF30");
           ACTION  oF30:VERVENTAS()

   oBtn:cToolTip:="Visualizar Ventas"
  

   DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\facturacompra.BMP";
           TOP PROMPT "Compras"; 
           MENU EJECUTAR("BRBTNMENU",{"Libro de Compras"},"oF30");
           ACTION  oF30:VERCOMPRAS()

    oBtn:cToolTip:="Visualizar Compras"
  


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CXP.BMP",NIL,"BITMAPS\CXPG.BMP";
          TOP PROMPT "CxP"; 
          ACTION EJECUTAR("DPPROVEEDORDOC",oF30:cCodPro)

   oBtn:cToolTip:="Ver Documentos por Pagar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION   oF30:IMPRIMIR()

   oBtn:cToolTip:="Listar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          TOP PROMPT "Excel"; 
          ACTION  (EJECUTAR("BRWTOEXCEL",oF30:oBrw,oF30:cTitle,oF30:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION  (oF30:oBrw:GoTop(),oF30:oBrw:Setfocus())
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          TOP PROMPT "Avance"; 
          ACTION  (oF30:oBrw:PageDown(),oF30:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          TOP PROMPT "Anterior"; 
          ACTION  (oF30:oBrw:PageUp(),oF30:oBrw:Setfocus())
*/

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION  (oF30:oBrw:GoBottom(),oF30:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oF30:Close()

  oF30:oBrw:SetColor(0,16770764)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  nLin:=32
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),nLin:=nLin+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 UNDERLINE BOLD

  @ 2,nLin+71 SAYREF oF30:oNumReg PROMPT IF(Empty(oF30:cNumReg),"Indefinido"," "+oF30:cNumReg+" ") OF oBar;
              SIZE 90,20;
              PIXEL FONT oFont COLOR CLR_WHITE,16744448


  IF !Empty(oF30:oNumReg)
     SayAction(oF30:oNumReg,{||oF30:VERREGPLA()})
  ENDIF

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 2,nLin SAY "Registro " OF oBar;
           SIZE 70,20;
           PIXEL BORDER RIGHT FONT oFont COLOR oDp:nClrYellowText,oDp:nClrYellow

  @ 20,nLin SAY "Periodo " OF oBar;
            SIZE 70,20;
            PIXEL BORDER RIGHT FONT oFont COLOR oDp:nClrYellowText,oDp:nClrYellow

  @ 20,nLin+71 SAY " "+DTOC(oF30:dDesde)+" "+DTOC(oF30:dHasta)+" " OF oBar;
              SIZE 90+90,20;
              PIXEL BORDER FONT oFont COLOR oDp:nClrLabelText,oDp:nClrLabelPane


  oF30:oBrw:GoTop(.t.)

RETURN .T.


FUNCTION LEELIQ30(aData,cAno,cMes,cCodSuc,cWhere)
   LOCAL oTable,nAt,cField,I,nAt,cValor,U

//   oTable:=OpenTable("SELECT * FROM DPLIQFORMA30 WHERE F30_CODSUC"+GetWhere("=",cCodSuc)+;
//                                                "  AND F30_ANO"+GetWhere("=",cAno)+" AND F30_MES"+GetWhere("=",cMes),.T.)

   DEFAULT cWhere:=oF30:cWhere

   oTable:=OpenTable("SELECT * FROM DPLIQFORMA30 WHERE "+cWhere,.T.)

// ? cWhere,"cWhere"
// F30_CODSUC"+GetWhere("=",cCodSuc)+;
// "  AND F30_ANO"+GetWhere("=",cAno)+" AND F30_MES"+GetWhere("=",cMes),.T.)

   FOR I=1 TO LEN(aData)

      FOR U=4 TO 6

        cField:=aData[I,U]
        nAt   :=oTable:FieldPos(cField)
 
        IF nAt>0
           cValor:=TRAN(oTable:FieldGet(nAt),"999,999,999,999,999.99")
           aData[I,U]:=cValor
         ENDIF

      NEXT U
     
   NEXT I

   oTable:End()

RETURN aData

FUNCTION GRABARFORMA30()
   LOCAL cCodigo:=EJECUTAR("GETCODSENIAT")
   CursorWait()
   // EJECUTAR("FORMA30CALC", oF30:cAno  , oF30:cMes , oF30:cCodSuc ,oF30:cNumReg ,oF30:cWhere )
   EJECUTAR("FORMA30CALC",oF30:cAno,oF30:cMes,oF30:cCodSuc,oF30:cNumReg,oF30:dDesde,oF30:dHasta,oF30:cWhere)

   EJECUTAR("DPPROVEEDORDOC",cCodigo,NIL,"F30") //,cNumero)

RETURN .T.

FUNCTION IMPRIMIR()
   LOCAL oRep,cTitle:=oF30:cTitle

   cTitle:=cTitle+ " ["+ALLTRIM(CMES(VAL(oF30:cMes)))+"] Año "+oF30:cAno

   oRep:=REPORTE("DPLIQFORMA30",NIL,NIL,NIL,cTitle)

   oRep:aCargo:=ACLONE(oF30:oBrw:aArrayData)

RETURN .T.

/*
// Aqui se Edita la Columna
*/
FUNCTION SETCOLEDIT(nKey)
   LOCAL nAt :=oF30:oBrw:nArrayAt
   LOCAL nCol:=oF30:oBrw:nColSel
   LOCAL nRow:=oF30:oBrw:nRowSel
   LOCAL cCol:=oF30:aPlanilla[nAt,nCol]

   IF !Empty(cCol) .AND. cCol$oF30:cEdit

     oF30:cField          :=cCol
     oF30:oBrw:aCols[nCol]:nEditType    :=1
     oF30:oBrw:aCols[nCol]:oFontGet     :=oF30:oBrw:oFont
     oF30:oBrw:aArrayData[oF30:oBrw:nArrayAt,nCol]:=VAL(oF30:oBrw:aArrayData[oF30:oBrw:nArrayAt,nCol])
     oF30:oBrw:aCols[nCol]:cEditPicture :="9,999,999,999,999.99"
     oF30:oBrw:aCols[nCol]:bOnPostEdit  :={|oCol,uValue,nLastKey,nCol|oCol:nEditType:=0,oCol:bOnPostEdit:=NIL,;
                                           oF30:PUTCOLVALUE(oCol,uValue,nLastKey,nCol)}

     IF Empty(nKey)
       oF30:oBrw:KeyBoard(13)
     ENDIF

   ENDIF

RETURN .T.

FUNCTION PUTCOLVALUE(oCol,uValue,nLastKey,nCol)

   LOCAL nCol:=oF30:oBrw:nColSel

   oF30:oBrw:aArrayData[oF30:oBrw:nArrayAt,nCol]:=TRAN(uValue,"9,999,999,999,999.99")
   oF30:oBrw:DrawLine(.T.)

   oF30:SAVECOLF30(uValue)

   AEVAL(oF30:oBrw:aCols,{|oCol|oCol:nEditType:=0})

RETURN .T.

FUNCTION SAVECOLF30(uValue)
   LOCAL cWhere,aData:=ACLONE(oF30:aPlanilla)
   LOCAL nAt :=oF30:oBrw:nArrayAt
   LOCAL nCol:=oF30:oBrw:nColSel
   LOCAL nRow:=oF30:oBrw:nRowSel

/*
   cWhere:="F30_CODSUC"+GetWhere("=",oF30:cCodSuc)+" AND "+;
           "F30_ANO"   +GetWhere("=",oF30:cAno   )+" AND "+;
           "F30_MES"   +GetWhere("=",oF30:cMes   )
*/

   cWhere:=oF30:cWhere

   CursorWait()

   // Grabar
   SQLUPDATE("DPLIQFORMA30",oF30:cField,uValue,cWhere)

   // Calcular
   EJECUTAR("FORMA30CALC",oF30:cAno,oF30:cMes,oF30:cCodSuc,oF30:cNumReg,oF30:dDesde,oF30:dHasta,oF30:cWhere)

   // Lee
   aData:=oF30:LEELIQ30(aData,oF30:cAno,oF30:cMes,oF30:cCodSuc)
   oF30:oBrw:aArrayData:=ACLONE(aData)
   oF30:oBrw:Refresh(.T.)

   oF30:oBrw:nArrayAt:=nAt
   oF30:oBrw:nColSel:=nCol
   oF30:oBrw:nRowSel:=nRow
   oF30:oBrw:GoDown(.T.)
   oF30:nMonto:=VAL(STRTRAN(ATAIL(aData)[6],",",""))
   oF30:oBtnPago:ForWhen(.t.)

RETURN .T.

/*
// Realizar Comprobante de Pago
*/
FUNCTION HACERPAGO()
  LOCAL oDocPro,oData,cTipDoc:="F30",cEstado
  LOCAL cWhere,oTable,cNumero,dFecha

  // Fecha
  dFecha:=FCHFINMES(CTOD("01/"+oF30:cMes+"/"+oF30:cAno))

  cWhere:="DOC_CODSUC"+GetWhere("=",oF30:cCodSuc)+" AND "+;
          "DOC_TIPDOC='F30' AND "+;
          "DOC_CODIGO"+GetWhere("=",oF30:cCodPro)+" AND "+;
          "DOC_FECHA "+GetWhere("=",dFecha )+" AND "+;
          "DOC_TIPTRA='D'"

  cNumero:=SQLGET("DPDOCPRO","DOC_NUMERO,DOC_ESTADO",cWhere)
  cEstado:=DPSQLROW(2,"") // oDp:aRow[2]

  IF cEstado<>"AC"
     MensajeErr("Documento "+cNumero+" no está Activo "+CRLF+;
                "Estado Actual:"+SAYOPTIONS("DPDOCPRO","DOC_ESTADO",cEstado),"No es Posible Realizar el Pago")
     RETURN .F.
  ENDIF

  EJECUTAR("DPDOCPROPAG",oF30:cCodSuc,cTipDoc,oF30:cCodPro,cNumero)

  oF30:Close()

RETURN .T.

FUNCTION VERREGPLA()
   LOCAL cWhere:="PLP_TIPDOC"+GetWhere("=","F30")+" AND PLP_NUMREG"+GetWhere("=",oF30:cNumReg)
   LOCAL cTitle:=NIL,lData:=NIL

RETURN EJECUTAR("BRCALFISDET",cWhere,oDp:cSucursal,11,CTOD(""),CTOD(""),cTitle,lData)

FUNCTION BTNMENU(nOption,cOption)
  LOCAL cWhere,cCodSuc:=oDp:cSucursal
  LOCAL lFecha,lFrm:=.F.
  LOCAL dDesde:=oF30:dDesde,dHasta:=oF30:dHasta,cNumero:=oF30:cNumReg

  IF nOption=1 .AND. cOption="Libro de Ventas"
     EJECUTAR("DPLIBVTA",NIL,NIL,NIL,cCodSuc,dDesde,dHasta,NIL,.T.)
     RETURN .T.
  ENDIF

  IF nOption=1 .AND. cOption="Libro de Compras"
     EJECUTAR("DPLIBCOM",NIL,NIL,NIL,NIL,dDesde,dHasta,cNumero,.T.)
     RETURN .T.
  ENDIF

RETURN .T.

FUNCTION VERCOMPRAS()
  LOCAL cWhere,cCodSuc:=oDp:cSucursal,nPeriodo:=12,cTitle:=NIL
  LOCAL dDesde:=oF30:dDesde,dHasta:=oF30:dHasta

  EJECUTAR("BRDOCPRORET",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)

RETURN .T.

FUNCTION VERVENTAS()
  LOCAL cWhere,cCodSuc:=oDp:cSucursal,nPeriodo:=12,cTitle:=NIL
  LOCAL dDesde:=oF30:dDesde,dHasta:=oF30:dHasta

  // LOCAL cWhere,cCodSuc:=oDp:cSucursal,nPeriodo:=12,cTitle:=NIL
  // oLiq30:CALFECHAS()

  EJECUTAR("BRSERFISCAL",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)

RETURN .T.



// EOF
