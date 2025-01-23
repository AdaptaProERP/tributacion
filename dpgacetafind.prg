// Programa   : DPGACETAFIND
// Fecha/Hora : 09/12/2006 14:34:16
// Propósito  : Buscar en Programas Fuentes
// Creado Por : Juan Navas
// Llamado por: DPPROGRAG/DPXBASE
// Aplicación : Programación
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oLbxGaceta)

   LOCAL oDlg,oFontB

   DEFAULT oDp:cText1 :=SPACE(40),;
           oDp:cText2 :=SPACE(40)

   DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -11 BOLD

   DPEDIT():New("Buscar en Gacetas Oficiales","forms\DPPROGFIND.EDT","oGagF",.T.)

   oGagF:lMsgBar:=.F.
   oGagF:nRadio :=1
   oGagF:oLbxGaceta:=oLbxGaceta

   @ 0.5,.5 SAY "Texto 1:" RIGHT SIZE 22,08 COLOR  NIL,oDp:nGris FONT oFontB
   @ 1.2,.5 SAY "Texto 2:" RIGHT SIZE 22,08 COLOR  NIL,oDp:nGris FONT oFontB

   @ 0.6,03.8 GET oDp:oText1 VAR oDp:cText1 SIZE 125,10 FONT oFontB UPDATE

   oDp:oText1:bKeyDown  :={|n| oGagF:oBtnSave:ForWhen(.T.)}
  

   @ 1.4,03.8 GET oDp:oText2 VAR oDp:cText2 SIZE 125,10 FONT oFontB UPDATE;
              VALID (oGagF:oBtnSave:ForWhen(.T.),.T.) 
        
   oDp:oText2:bKeyDown:={|n| oGagF:oBtnSave:ForWhen(.T.),;
                             IF(n=13,oGagF:PRGBUSCAR(),NIL)}

   oDp:oText2:bLostFocus:={|| oGagF:oBtnSave:ForWhen(.T.)}

   @ 02,10  RADIO oGagF:oRadio VAR oGagF:nRadio;
            ITEMS "&AND", "&OR" SIZE 60, 13 

   oGagF:Activate({||oGagF:INICIO()})

RETURN .T.


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oGagF:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -14 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          WHEN !Empty(ALLTRIM(oDp:cText1)+ALLTRIM(oDp:cText2));
          ACTION (oGagF:PRGBUSCAR())

   oBtn:cToolTip:="Guardar"

   oGagF:oBtnSave:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION (oGagF:Close()) CANCEL

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })

RETURN .T.

FUNCTION PRGBUSCAR()

   LOCAL cWhere:="GAC_NUMERO"+GetWhere("=",oDp:cText1)+" OR GAC_TEXTO "+GetWhere(" LIKE ","%"+ALLTRIM(oDp:cText1)+"%")

   CURSORWAIT()

   IF !Empty(oDp:cText2)

      cWhere:=cWhere +IIF(oGagF:nRadio=1," AND "," OR ")+;
            "GAC_TEXTO "+GetWhere(" LIKE ","%"+ALLTRIM(oDp:cText2)+"%")
   ENDIF

   IF EMPTY(COUNT("DPGACETA",cWhere))
      MensajeErr("No hay Gacetas Encontrados con el Criterio Solicitado")
      RETURN .F.
   ENDIF
   
   CURSORWAIT()

   IF ValType(oGagF:oLbxGaceta)="O"
      oGagF:oLbxGaceta:oWnd:End()
   ENDIF

   oGagF:Close()

   DPLBX("DPGACETA",NIL,cWhere)

RETURN .T.
// EOF


