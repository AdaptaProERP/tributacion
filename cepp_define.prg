// Programa   : CEPP_DEFINE
// Fecha/Hora : 21/05/2024 20:58:26
// Prop�sito  : ley de proteccion 
// Creado Por :
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cRif)
 
  EJECUTAR("NMCLACON_ADD","CEPP_SALARIALES"     ,"Conceptos Salariales")
  EJECUTAR("NMCLACON_ADD","CEPP_NOREMUNERATIVO" ,"Beneficios Sociales no remunerativo")
  EJECUTAR("NMCLACON_ADD","CEPP_BONOSNOSALARIAL","Bonificaciones no Salariales")
  EJECUTAR("NMCLACON_ADD","CEPP_NOAPLICA"       ,"No Aplica")

  IF !ISSQLFIND("NMCONSTANTES","CNS_CODIGO"+GetWhere("=","301")) 

     EJECUTAR("CREATERECORD","NMCONSTANTES",{"CNS_CODIGO","CNS_DESCRI"      ,"CNS_TIPO" ,"CNS_VALOR"  },;
                                            {"301"      ,"% CEPP GO-6806"   ,"N"        ,"9"          },;
                                             NIL,.T.,"CNS_CODIGO"+GetWhere("=","301"))
  
  ENDIF

  IF !ISSQLFIND("NMCONSTANTES","CNS_CODIGO"+GetWhere("=","302")) 

     EJECUTAR("CREATERECORD","NMCONSTANTES",{"CNS_CODIGO","CNS_DESCRI"               ,"CNS_TIPO" ,"CNS_VALOR"  },;
                                            {"302"       ,"Salario M�nimo en USD$"   ,"N"        ,"130"        },;
                                             NIL,.T.,"CNS_CODIGO"+GetWhere("=","302"))

  ENDIF

RETURN .T.
// EOF
