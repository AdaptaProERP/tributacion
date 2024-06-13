// Programa   : DPINIADDFIELD
// Fecha/Hora : 30/06/2017 23:17:57
// Propósito  : Crear Nuevos Campos en el Diccionario de Datos desde DPINI
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lNull,lRun,lAsk)
  LOCAL oTable,cTipIva:="NS",oFrm
  LOCAL cId:=EJECUTAR("DPINIADDFIELD_ID")
  LOCAL oData,aTablas:={},I,aConfig:={}
  LOCAL oDb:=OpenOdbc(oDp:cDsnConfig),cWhere,cSql,aChkSum:={},lChkSum,cLen:="",cCodEmp
  LOCAL aNo:={},oMenu,cFile,aVistas:={}
//  LOCAL cFileChk:=cId+".CHK",aFields:={},aFiles:={}
  LOCAL cFileChk:="ADD\"+oDp:cDsnConfig+"_"+cId+".ADD",aFields:={},aFiles:={},cAction

  DEFAULT lRun:=.F.,;
          lAsk:=.T.

  LMKDIR("ADD")

  // No debe mostrar los mensaje de incidencias, debera ser guardados 
  oDp:lMySqlError  :=GETINI("DATAPRO.INI","LMYSQLERROR")   // Indica si MySQL Arranca emitiendo mensaje nativos de la clase TMYSQL

  IF ValType(oDp:lMySqlError)<>"L"
     oDp:lMySqlError:=.T.
  ENDIF

  IF EJECUTAR("DBISTABLE",oDp:cDsnConfig,"DPTABLAS") .AND. !EJECUTAR("ISFIELDMYSQL",oDb,"DPTABLAS"  ,"TAB_VISTA")
     EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_VISTA" ,"L",01,0,"Vista")
  ENDIF

  IF FILE("DATADBF\DPTABLAS.DBF") .AND.  !EJECUTAR("DBISTABLE",oDp:cDsnConfig,"DPDATACNF")
     EJECUTAR("IMPORTDPTABLAS")
  ENDIF

  // resetear licencias
  IF LIC_RIF()="V055215029"
     SQLDELETE("DPPCLOG")
  ENDIF

  EJECUTAR("DPINIDELTEMPDXBX")
  EJECUTAR("DPLOADCNFCHKFCH") 

  IF !EJECUTAR("ISFIELDMYSQL",oDb,"DPLINK"    ,"LNK_ACTIVO") .OR.;
     !EJECUTAR("ISFIELDMYSQL",oDb,"DPVISTAS"  ,"VIS_PRGPRE") .OR.;
     !EJECUTAR("ISFIELDMYSQL",oDb,"DPTRIGGERS","TRG_WHEN")   .OR.;
     !EJECUTAR("ISFIELDMYSQL",oDb,"DPPROCESOS","PRC_INICIA") .OR.;
     !EJECUTAR("ISFIELDMYSQL",oDb,"DPIMPRXLS" ,"IXL_MEMMSG") .OR.;
     !EJECUTAR("ISFIELDMYSQL",oDb,"DPTABLAS"  ,"TAB_VISTA")

     FERASE(cFileChk)

  ELSE

    IF FILE(cFileChk) .AND. !lRun
     RETURN .T.
    ENDIF

  ENDIF

  AEVAL(DIRECTORY(oDp:cDsnConfig+"_*.*"),{|a,n| FERASE(a[1])})
 
  // recarga la tablas
  // ? "aqui loadtablas"

  EJECUTAR("DPCAMPOSADD","DPLINK"     ,"LNK_PRGPRE","C",30,0,"Programa Pre Ejecución"    )
  EJECUTAR("DPCAMPOSADD","DPLINK"     ,"LNK_ACTIVO","L",01,0,"Activo"            ,NIL,.T.,.T.,".T.")

  EJECUTAR("SETFIELDLONG","DPPROCESOS","PRC_INICIA",35)
  SQLUPDATE("DPPROCESOS","PRC_INICIA","Clientes y Facturación",[LEFT(PRC_INICIA,8)="Clientes"])

  EJECUTAR("DPCAMPOSADD","DPPROCESOS","PRC_INICIA","L",001,0,"Proceso Iniciado"     ,"",.T.,.F.,".F.")

  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_VISTA" ,"L",01,0,"Vista")
  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_REXSUC","L",01,0,"Restricción por Sucursal")
  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_REXUSU","L",01,0,"Restricción por Usuario")
  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_CATLGO","L",01,0,"Catálogo")
  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_CAMDES","C",20,0,"Campo Descripción")
  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
  EJECUTAR("DPCAMPOSADD" ,"DPVISTAS"  ,"VIS_PRGPRE","C",30,2,"Programa Prejecución")

  EJECUTAR("DPCAMPOSADD"   ,"DPTRIGGERS","TRG_WHEN","C",1,0,"Cuando se Ejecuta"    ,"",.T.,"B",["B"])

  LOADTABLAS(.T.)

  // Empresas sin Código
  IF FILE("DATADBF\DPTABLAS.DBF") .AND. COUNT("DPEMPRESA","EMP_CODIGO"+GetWhere("=",""))>0
     cCodEmp:=SQLINCREMENTAL("DPEMPRESA","EMP_CODIGO")
     SQLUPDATE("DPEMPRESA","EMP_CODIGO",cCodEmp,"EMP_CODIGO"+GetWhere("=",""))
  ENDIF
 
/*
12/05/2023 
  IF !lRun

     oData:=DATACNF("CNFADDFIELD","ALL")

     IF oData:Get("CNFADDFIELD","")<>cId
       oData:End()
     ELSE
       oData:End()
       RETURN
     ENDIF

  ENDIF
*/

  DEFAULT lNull:=.F.

//  IF FILE(cFileChk)
//      RETURN .T.
//  ENDIF

  IF oDp:lCreateConfig

   // La BD es nueva y fue creada cuando se Instalo,
   oData:=DATACNF("CNFADDFIELD","ALL")
   oData:Set("CNFADDFIELD",cid)
   oData:Save()
   oData:End()
   RETURN .T.

  ENDIF
  // Valores Nulos debe ser Convertidas

  IF oDp:oSay=NIL
    oFrm:=MSGRUNVIEW("Actualizando Diccionario de Datos R:"+cId)
  ELSE
    oDp:oSay:SetText("Actualizando Diccionario de Datos R:"+cId)
  ENDIF


  // EJECUTAR("DPDROPALL_FK",oDp:cDsnConfig)

  // Requiere evitar incidencia en el cambio del mapa de usuarios
  EJECUTAR("DPDROP_KEY","DPMAPAMNUCPO")
  EJECUTAR("DPDROP_FK" ,"DPMAPAMNUCPO",NIL,NIL,.T.)
  EJECUTAR("DPDROP_FK","DPMENU")

  EJECUTAR("DPCAMPOSADD","DPIMPRXLS","IXL_DEFPRG","M",NIL ,0,"Programa Fuente Definición")
  EJECUTAR("DPCAMPOSADD","DPIMPRXLS","IXL_ETQPRG","M",NIL ,0,"Programa Fuente Etiquetas")
  EJECUTAR("DPCAMPOSADD","DPIMPRXLS","IXL_MEMMSG","M",NIL ,0,"memo de Mensajes")

  EJECUTAR("DPCAMPOSADD","DPIMPRXLS","IXL_CIEFIN","L",NIL ,0,"Cerrar al Finalizar")
  EJECUTAR("DPCAMPOSADD","DPIMPRXLS","IXL_BROWSE","L",NIL ,0,"Browse")
  EJECUTAR("DPCAMPOSADD","DPIMPRXLS","IXL_SOLREF","L",NIL ,0,"Sólo referencias")

  SQLDELETE("DPCAMPOS","CAM_DESCRI IS NULL")

  EJECUTAR("DPCAMPOSADD","DPPCLOGAPP","PCL_AUTORI","L",01 ,0,"Autorizado",NIL,.T.,.T.,".T.")
  EJECUTAR("DPCAMPOSADD","DPPCLOGAPP","PCL_AUDITA","L",01 ,0,"Audita"    ,NIL,.T.,.T.,".T.")
  EJECUTAR("DPCAMPOSADD","DPPCLOGAPP","PCL_TITULO","C",250,0,"Titulo"    )
  EJECUTAR("DPCAMPOSADD","DPPCLOGAPP","PCL_FECHA" ,"D",8  ,0,"Fecha"     ,NIL,NIL,NIL,"oDp:dFecha")

  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_TIPO"  ,"C",001,0,"Soporte o Mejora",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_FILE"  ,"C",250,0,"Archivo",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_ZIPMAI","N",008,0,"Número de Digitalización Respaldo ZIP",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_FILMAI","N",008,0,"Número de Digitalización",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_RESALD","L",001,0,"incluye respaldo de la base de datos",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_RTFMAI","N",008,0,"Número de Digitalización RTF",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_AUTOID","N",010,0,"Registro Auto-Incremental AdaptaPro Server ",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_NUMLIC","C",040,0,"Número de Licencia",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_TYPE"  ,"C",003,0,"Tipo de Incidencia",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_CODCLI","C",010,0,"Código del Cliente",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPREGSOPORTE","RSP_TELEFO","C",250,0,"Teléfono y Ext"    ,NIL,.T.,NIL)


  IF !ISFIELD("DPUSUARIOS","OPE_ENCRIP")
     EJECUTAR("DPCAMPOSADD","DPUSUARIOS","OPE_ENCRIP" ,"L",01,0,"Encriptado")
     SQLUPDATE("DPUSUARIOS","OPE_ENCRIP",.F.,"OPE_ENCRIP IS NULL")
  ENDIF

  IF ISFIELD("DPUSUARIOS","OPE_ALLPC")
     SQLUPDATE("DPUSUARIOS","OPE_ALLPC" ,.T.     ,"OPE_ALLPC  IS NULL")
  ENDIF

  // oFrm:=MSGRUNVIEW("Actualizando Diccionario de Datos R:"+cId)
  // Crea tabla contentiva de Archivos

  oDb:EXECUTE("SET FOREIGN_KEY_CHECKS = 0")

 

  EJECUTAR("DPCAMPOSOPCADD","NMTABLIQ","LIQ_CAUSA","Culminación de Contrato" ,.T.,12016384,.T.)
  EJECUTAR("DPCAMPOSOPCADD","NMTABLIQ","LIQ_CAUSA","Despido Justificado"     ,.T.,16744576,.T.)
  EJECUTAR("DPCAMPOSOPCADD","NMTABLIQ","LIQ_CAUSA","Fallecimiento"           ,.T.,16744448,.T.)
  EJECUTAR("DPCAMPOSOPCADD","NMTABLIQ","LIQ_CAUSA","Injustificado <Despido>" ,.T.,16711808,.T.)
  EJECUTAR("DPCAMPOSOPCADD","NMTABLIQ","LIQ_CAUSA","Jubilado"                ,.T.,255     ,.T.)
  EJECUTAR("DPCAMPOSOPCADD","NMTABLIQ","LIQ_CAUSA","Pensionado"              ,.T.,33023   ,.T.)
  EJECUTAR("DPCAMPOSOPCADD","NMTABLIQ","LIQ_CAUSA","Renuncia"                ,.T.,16318588,.T.)
  EJECUTAR("DPCAMPOSOPCADD","NMTABLIQ","LIQ_CAUSA","Traslado a Otra Empresa" ,.T.,11731123,.T.)


  EJECUTAR("DPAUDTIPOSCREA","DINC","Incluir"  ,.T.)
  EJECUTAR("DPAUDTIPOSCREA","DCON","Consultar",.T.)
  EJECUTAR("DPAUDTIPOSCREA","DMOD","Modificar",.T.)
  EJECUTAR("DPAUDTIPOSCREA","DANU","Anular"   ,.T.)
  EJECUTAR("DPAUDTIPOSCREA","DELI","Eliminar" ,.T.)
  EJECUTAR("DPAUDTIPOSCREA","DIMP","Imprimir" ,.T.)
  EJECUTAR("DPAUDTIPOSCREA","RACT","Reactivar",.T.)
  EJECUTAR("DPAUDTIPOSCREA","DINC","Ingresar" ,.F.)
  EJECUTAR("DPAUDTIPOSCREA","DIMP","Imprimir" ,.T.)

  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"               ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"   },;
                                   {"19C10"     ,"19"        ,"10"        ,"C"         ,[EJECUTAR("BRDPAUDITORRES")],[]          ,1         ,[Resumen de Registros de Auditoría por Tabla]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","19C10"))

  EJECUTAR("DPTABLASSET_KEYAUD")

  EJECUTAR("DPFILEXPCCREA")
  SQLDELETE("DPINDEX",[IND_INDICE LIKE "%,%" OR IND_INDICE LIKE "%+%"  OR IND_INDICE LIKE "%.%"])

  EJECUTAR("DPINDEXUNIQUE") // quitar campos repetidos

  SQLUPDATE("DPCAMPOS","CAM_DEFAUL",".T.","CAM_TABLE"+GetWhere("=","DPCAMPOS")+" AND CAM_NAME"+GetWhere("=","CAM_DEFAUL")+" AND CAM_TYPE"+GetWhere("=","L")+;
            " AND CAM_DEFAUL"+GetWhere("<>",""))

// ? CLPCOPY(oDp:cSql)

  SQLUPDATE("DPMENU","MNU_CONDIC","","MNU_CONDIC"+GetWhere("=",[(]))
  SQLUPDATE("DPMENU","MNU_CONDIC","","MNU_CONDIC"+GetWhere("=",[)]))

  SQLUPDATE("DPCAMPOS","CAM_DEC",0,"CAM_TYPE"+GetWhere("<>","N"))
  SQLUPDATE("DPCAMPOS","CAM_TYPE","N","CAM_NAME"+GetWhere("=","TAB_CHKSUM"))

  SQLDELETE("DPCAMPOS","CAM_TABLE"+GetWhere("=","DPCBTEPROG")+" AND CAM_NAME"+GetWhere(" LIKE ","%CLB_%"))

  EJECUTAR("SETFIELDLONG","DPTABLAS","TAB_CHKSUM" ,10)
  EJECUTAR("SETFIELDLONG","DPMENU"  ,"MNU_TITULO" ,180)

  EJECUTAR("DPCAMPOSOP_UPDATE") // Agrega todas las opciones de los campos

  EJECUTAR("UNIQUETABLAS","DPCAMPOS","CAM_TABLE,CAM_NAME")
  EJECUTAR("CHKLOGICOS",.T.)

  EJECUTAR("DPCAMPOSADD","DPUSUARIOS"     ,"OPE_DIACLA","N",03,0,"Días para Validar Clave",NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPUSUARIO"   ,"EXU_FIELD" ,"C",20,0,"Campo",NIL)

  EJECUTAR("DPGRUREPFIX")

  EJECUTAR("DPLINKADD"  ,"DPBANCODIR"  ,"NMTRABAJADOR","BAN_CODIGO","BANCO"     ,.F.,.T.,.F.)
  EJECUTAR("DPLINKADD"  ,"NMTRABAJADOR","DPBANCODIR"  ,"BANCO"    ,"BAN_CODIGO",.F.,.F.,.F.,"BAN_NOMBRE")


  EJECUTAR("DPCAMPOSOPCADD","DPSUBMENU","SMN_TIPO","Consulta"   ,.T.,16744448,.T.)
  EJECUTAR("DPCAMPOSOPCADD","DPSUBMENU","SMN_TIPO","Menú"       ,.T.,5548032 ,.T.)
  EJECUTAR("DPCAMPOSOPCADD","DPSUBMENU","SMN_TIPO","Add-On"     ,.T.,3566592 ,.T.)
  EJECUTAR("DPCAMPOSOPCADD","DPSUBMENU","SMN_TIPO","Transacción",.T.,16731983,.T.)
  EJECUTAR("DPCAMPOSOPCADD","DPSUBMENU","SMN_TIPO","Sub-Menú"   ,.T.,16711935,.T.)


  oDb:EXECUTE([UPDATE dptablas SET TAB_DSN=".CONFIGURACION" WHERE TAB_DSN LIKE "%51%"])
  SQLUPDATE("DPTABLAS","TAB_DSN"   ,".CONFIGURACION","TAB_NOMBRE"+GetWhere("=","DPSUBMENU"))
  SQLUPDATE("DPTABLAS","TAB_DESCRI","Cuentas de Egreso","TAB_NOMBRE"+GetWhere("=","DPCTAEGRESO"))

  EJECUTAR("DPCAMPOSADD","DPUSUARIOS","OPE_MAPPRC","C",10,0,"Mapa de Procesos Automáticos"      ,NIL)
  EJECUTAR("DPPCLOGDIRAPLCREA")

  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_DPSTD" ,"M",010,0,"Lista de Archivos Actualizados DPSTD",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FCHSTD","D",008,0,"Fecha de Descarga DPSTD",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_HORSTD","C",008,0,"Hora  de Descarga DPSTD",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_SHD"   ,"C",030,0,"Serial Disco Duro",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_OS"    ,"C",120,0,"Sistema Operativo",NIL,NIL,NIL,"oDp:cOs")


  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FILDPX" ,"C",10,0,"Fecha+Hora Archivos DpXbase")
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FILREP" ,"C",10,0,"Fecha+Hora Archivos Reportes")
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FILRPT" ,"C",10,0,"Fecha+Hora Archivos Crystal")
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FILFRM" ,"C",10,0,"Fecha+Hora Archivos Forms")
 
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FCHDPX" ,"C",20,0,"Fecha+Hora Archivos DpXbase")
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FCHREP" ,"C",20,0,"Fecha+Hora Archivos Reportes")
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FCHRPT" ,"C",20,0,"Fecha+Hora Archivos Crystal")
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FCHFRM" ,"C",20,0,"Fecha+Hora Archivos Forms")

  EJECUTAR("SETFIELDLONG","dppclogdirapl","PCP_NOMBRE" ,40)

  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHFRM" ,20)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHREP" ,20)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHRPT" ,20)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHFRM" ,20)

  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FILDPX" ,10)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FILREP" ,10)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FILRPT" ,10)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FILFRM" ,10)

  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHFRM" ,20)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHREP" ,20)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHRPT" ,20)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHFRM" ,20)

  SQLUPDATE("DPMENU","MNU_CONDIC","","MNU_CONDIC"+GetWhere("=",")"))

  oDp:cTexto:=SQLGET("DPPCLOG","PC_NOMBRE")

  IF LEN(oDp:cTexto)<40
    EJECUTAR("DPDROPALL_FK",oDp:cDsnConfig) // Debe remover todas las claves foraneas.
    EJECUTAR("SETFIELDLONG","DPPCLOG","PC_NOMBRE" ,40)
  ENDIF

  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_ISDICD" ,"L",1,0,"Tiene Diccionario de Datos local")
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FCHDIC" ,"D",1,0,"Fecha del Diccionario de Datos")


  EJECUTAR("DPCAMPOSADD" ,"DPAUDITORIA","AUD_TCLAVE","C",120,0,"3ra Clave",NIL,.T.,.T.)
  EJECUTAR("DPCAMPOSADD" ,"DPAUDITORIA","AUD_CCLAVE","C",120,0,"4ra Clave",NIL,.T.,.T.)
  EJECUTAR("SETFIELDLONG","DPAUDITORIA","AUD_SCLAVE",120,0)

  EJECUTAR("DPINDEXADD","DPFORMYTAREASPROG","PFT_CODIGO,PFT_CODEMP,PFT_CODSUC,PFT_DESDE"      ,"Optimiza Crear Tareas"           ,"TAREAS")

  EJECUTAR("DPINDEXADD","DPAUDITORIA","AUD_USUARI,AUD_TIPO","Optimiza Usuario")

  EJECUTAR("DPCAMPOSADD","DPIMPRXLS"  ,"IXL_MINCOL","C",2 ,0,"Columna de Inicio",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPIMPRXLS"  ,"IXL_LINFIN","N",4 ,0,"Línea Final",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPIMPRXLS"  ,"IXL_PREDEF","C",20,0,"Predefinido",NIL,.T.,NIL) // Funcionalidades predefinidas
  EJECUTAR("DPCAMPOSADD","DPIMPRXLS"  ,"IXL_INTREF","L",1,0,"Integridad Referencial",NIL,.T.,.T.)
  EJECUTAR("DPCAMPOSADD","DPIMPRXLS"  ,"IXL_ALTER" ,"L",1,0,"Personalizado") // ,NIL,.T.,.T.)

  oDb:EXECUTE("UPDATE DPIMPRXLS SET IXL_ALTER=0 WHERE IXL_ALTER IS NULL")

  cSql:=[UPDATE DPCAMPOSOP SET OPC_CAMPO="IXL_PREDEF" WHERE OPC_CAMPO="IXL_TABLA"]
  oDb:EXECUTE(cSql)

  cSql:=[ UPDATE DPTABLAS ]+;
        [ INNER JOIN dpcampos ON CAM_TABLE=TAB_NOMBRE ]+;
        [ SET TAB_PRIMAR=CAM_NAME ]+;
        [ WHERE CAM_COMMAN LIKE "%PRIMA%" ]

  oDb:EXECUTE(cSql)

  EJECUTAR("DPCAMPOSADD","DPVIEWGRU"  ,"VIG_INDFIN","L",1 ,0,"Indices Financieros"      ,NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPVIEWGRU"  ,"VIG_INCFRM","L",1 ,0,"Incluido en el formulario",NIL,.T.,NIL)

  EJECUTAR("DPLINKADD"  ,"DPVIEWGRU"  ,"dpviewgrurun","VIG_CODIGO","VIR_CODGRU",.T.,.T.,.T.)

  EJECUTAR("DPSUBMENUCREA")

  oDp:oSay:=oDp:oMsgRun:oSay
// Tablas Innecesarias
  AADD(aNo,"DPFORMULAAXIACT")
  AADD(aNo,"DPEXPTECNICO")
  AADD(aNo,"DPCONTROL")

  oDb:EXECUTE([DELETE FROM DPTABLAS WHERE TAB_NOMBRE LIKE "%-%"])


  EJECUTAR("DPCAMPOSADD","DPCAMPOSOP","OPC_COLOR","N",10)

  aFields:={}

  AADD(aFields,{"ABR_CODIGO","C",006,0,"ID"     ,"PRIMARY KEY NOT NULL"})
  AADD(aFields,{"ABR_TEXTO" ,"C",060,0,"Texto"  ,""})

  // facilita asociarlo con Clientes,Proveedores, trabajadores
  EJECUTAR("DPTABLEADD","DPABREVIATURAS","Abreviaturas",".CONFIGURACION",aFields)

  EJECUTAR("SETFIELDLONG","DPCAMPOS","CAM_FORMAT" ,50)

  // Tabla utilizada en Nómina Tambien
  EJECUTAR("DPCAMPOSADD","DPDICDATFRX"   ,"DDF_ACTIVO","L",1,0,"Activo",NIL,.T.,.T.)
  EJECUTAR("DPCAMPOSADD","DPDICDATFRXGRU","CDD_ACTIVO","L",1,0,"Activo",NIL,.T.,.T.)

  EJECUTAR("DPLINKADD"  ,"DPDICDATFRXGRU"  ,"DPDICDATFRX","CDD_CODIGO","DDF_CODGRU",.T.,.T.,.T.)
  EJECUTAR("UNIQUETABLAS","DPCAMPOSOP","OPC_TABLE,OPC_CAMPO,OPC_TITULO")
  EJECUTAR("DPCOLORBRWCOLCREA")

  EJECUTAR("DPCAMPOSADD","DPADDON","ADD_NUMPOS" ,"N",04,0,"Posición de Presentación","",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPADDON","ADD_CLRTEXT","N",10,0,"Color Texto","",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPADDON","ADD_CLRPANE","N",10,0,"Color Fondo","",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPADDON","ADD_BTNTEXT","C",60,0,"Texto Boton","",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPADDON","ADD_RELEASE","C",60,0,"Release","",NIL,.F.)

  SQLUPDATE("DPCAMPOS","CAM_DESCRI","Anydesk;Id","CAM_NAME"+GetWhere("=","PDC_COMENT"))
  SQLUPDATE("DPCAMPOS","CAM_DESCRI","Anydesk;Id","CAM_NAME"+GetWhere("=","PDC_COMEN2"))

  EJECUTAR("DPBOTBARADD")

  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                   {"22P96"     ,"22"        ,"96"        ,"P"         ,[EJECUTAR("DPSQLRECOVER")],[.T.]               ,1         ,[Recuperar transacciones desde QUERY\*.SQL]},;
                                   NIL,.T.,"MNU_CODIGO"+GetWhere("=","22P96"))

  EJECUTAR("DSNTOVISTAS") // 07/09/2023 Asignar el DSN/BD de las Vistas

  EJECUTAR("SETFIELDLONG","DPAUDITORIA","AUD_SCLAVE" ,40)

  EJECUTAR("ADDONADD_ALL")

  IF oDp:cType="SGE"

    EJECUTAR("DPVIEWGRUADD")

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"   },;
                                     {"04C22"     ,"04"        ,"22"        ,"C"         ,[EJECUTAR("BRCAJINGDIVXCOL")],[],1 ,[Ingresos por Divisa en Columnas]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","04C22"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"            ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"   },;
                                     {"07O98"     ,"07"        ,"98"        ,"O"         ,[EJECUTAR("NMCONFIND")],[],1 ,[Buscar Texto en Conceptos]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","07O98"))


    SQLUPDATE("DPMENU","MNU_TITULO","Asientos Originados desde Facturación","MNU_CODIGO"+GetWhere("=","05C15"))

    SQLUPDATE("DPMENU","MNU_TITULO","Exportar Comprobantes","MNU_CODIGO"+GetWhere("=","05O77"))

    SQLUPDATE("DPMENU",{"MNU_CODIGO","MNU_VERTIC","MNU_HORIZO"},{"05C35","C","35"},"MNU_CODIGO"+GetWhere("=","05F35"))
    SQLUPDATE("DPMENU",{"MNU_CODIGO","MNU_VERTIC","MNU_HORIZO"},{"05C40","C","40"},"MNU_CODIGO"+GetWhere("=","05F40"))


    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"               ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"   },;
                                     {"05C42"     ,"05"        ,"42"        ,"C"         ,[EJECUTAR("RUNBRWAPLICA","Conciliación Compras")],[],1 ,[Conciliación de Asientos de Compra]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05C42"))


    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"               ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"   },;
                                     {"07F73"     ,"07"        ,"73"        ,"F"         ,[DPLBX("nmclacon.lbx")],[],1 ,[{&oDp:NMCLACON}]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05F73"))


    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"            ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"   },;
                                     {"08P43"     ,"08"        ,"43"        ,"P"         ,[EJECUTAR("BRCEPPDECL")],[],1 ,[Especial Pensiones]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","08P43"))

//  ? oDp:cSql

    SQLUPDATE("DPMENU","MNU_ACCION",[EJECUTAR("BRDPCBTEEDIT")],[MNU_CODIGO]+GetWhere("=","05O74"))

    SQLUPDATE("DPMENU","MNU_TITULO","Tesorería (Caja y Bancos)",[MNU_MODULO="04" AND MNU_HORIZO="00" AND MNU_VERTIC="A"])

    EJECUTAR("SETFIELDEFAULTALL")

    EJECUTAR("DPGRUCARACT_CREAR")

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"         ,"MNU_CONDIC"     ,"MNU_TIPO","MNU_TITULO" },;
                                     {"01F70"     ,"01"        ,"70"        ,"F"         ,[DPLBX("DPGRUCARACT")],[.T.]               ,1         ,[Características]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","01F70"))

    SQLUPDATE("DPMENU","MNU_TITULO","Productos del Inventario",[MNU_VERTIC='A' AND MNU_MODULO="01"])

    EJECUTAR("ADDONADD_ALL") 
    EJECUTAR("SGEUPDATEREPORT") // Actualizar Reportes

    EJECUTAR("SETTABLEPRIMARY") 
    EJECUTAR("UNIQUETABLAS","DPMENU","MNU_CODIGO") 

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC"},; 
                                     {"01C10"    ,"01"        ,"10"        ,"C"          },;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","01O01 "))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC"},; 
                                     {"03C20"    ,"03"        ,"20"        ,"C"          },;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","03O01"))



    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC"},; 
                                     {"03C25"    ,"03"        ,"20"        ,"C"          },;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","03O02"))

    aVistas:={}
    aVistas:={"DPCBTNUMASI","DPDIARIOCXC","DPDIARIOCXP","DPLIBINVFIN_MES","DPPLAFINRES","DPPLAFINRESDIA",;
              "DPASIENTOSCTAEJE","DPPRECIOXINVCANT","DPACTIVOSCTA"}

    AEVAL(aVistas,{|a,n| SQLUPDATE("DPVISTAS","VIS_DSN","<Multiple","VIS_VISTA"+GetWhere("=",a))})

// ? oDp:cSql

    aVistas:={}
    AADD(aVistas,{"NMFECHAMAX"        ,""}) //VIEW_NMFCHCANTREC"})
    AADD(aVistas,{"NMFCHCANTREC"      ,""}) // VIEW_NMRECIBOS"})  
    AADD(aVistas,{"DPDOCPROPROGDIARIO",""}) // VIEW_DPDOCPROPAG"})
    AADD(aVistas,{"DPCXCCXPPNF"       ,""}) // "VIEW_DPDIARIOCXC"})

    // 04/10/2023    AEVAL(aVistas,{|a,n| SQLUPDATE("DPVISTAS","VIS_PRGPRE",a[2],"VIS_VISTA"+GetWhere("=",a[1])),SysRefresh(.T.)})
    AEVAL(aVistas,{|a,n| SQLUPDATE("DPVISTAS","VIS_PRGPRE","","VIS_VISTA"+GetWhere("=",a[1])),SysRefresh(.T.)})

    SQLUPDATE("DPMENU",{"MNU_TITULO","MNU_ACCION"},{[{oDp:DPBANCODIR}],[DPLBX("DPBANCODIR.LBX")]},"MNU_CODIGO"+GetWhere("=","07F45")) // 25/08/2023

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                     {"10F68"     ,"10"        ,"68"        ,"F"         ,[EJECUTAR("BRVTALIBVTAXMES")],[.T.]               ,4         ,[Venta Calculada en Divisa $]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","10F68"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"     ,"MNU_TIPO","MNU_TITULO" },;
                                     {"10F20"     ,"10"        ,"20"        ,"F"         ,[EJECUTAR("BRDIARIOTRANS")],[.T.]               ,1         ,[Resumen de Transacciones]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","10F20"))


    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"     ,"MNU_TIPO","MNU_TITULO" },;
                                     {"10F30"     ,"10"        ,"30"        ,"F"         ,[EJECUTAR("BRVTAGRUVSGRU")],[.T.]               ,1         ,[Comparativo entre dos Periodos de Venta por Grupos]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","10F30"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"     ,"MNU_TIPO","MNU_TITULO" },;
                                     {"10F31"     ,"10"        ,"31"        ,"F"         ,[EJECUTAR("BRVTAMARVSMAR")],[.T.]               ,1         ,[Comparativo entre dos Periodos de Venta por Marca]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","10F31"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"     ,"MNU_TIPO","MNU_TITULO" },;
                                     {"10F32"     ,"10"        ,"32"        ,"F"         ,[EJECUTAR("BRVTAINVVSINV")],[.T.]               ,1         ,[Comparativo entre dos Periodos de Venta por Productos]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","10F32"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"     ,"MNU_TIPO","MNU_TITULO" },;
                                     {"10F34"     ,"10"        ,"34"        ,"F"         ,[EJECUTAR("BRVTACLIVSCLI")],[.T.]               ,1         ,[Comparativo entre dos Periodos de Venta por Cliente]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","10F34"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"     ,"MNU_TIPO","MNU_TITULO" },;
                                     {"10F36"     ,"10"        ,"36"        ,"F"         ,[EJECUTAR("BRVTAVENVSVEN")],[.T.]               ,1         ,[Comparativo entre dos Periodos de Venta por Vendedor]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","10F36"))

    SQLUPDATE("DPMENU","MNU_TIPO",4,"MNU_CODIGO"+GetWhere("=","10F36"))


    SQLUPDATE("DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_VERTIC","MNU_HORIZO"},{"03O04","03","O","04"},"MNU_TITULO"+GetWhere("=","{oDp:DPSERIEFISCAL}"))

    EJECUTAR("REPCLONE","DOCCXC","DOCCXC_DEB","Nota de Débito")
    EJECUTAR("REPCLONE","DOCCXC","DOCCXC_CRE","Nota de Crédito")

   

    EJECUTAR("DPMENUNOMADD")

    EJECUTAR("DPCAMPOSETDEF","DPCLIENTES"  ,"CLI_CODVEN",[&oDp:cCodVen])
    EJECUTAR("DPCAMPOSETDEF","DPCLIENTES"  ,"CLI_CODCLA",[&oDp:cCodCliCla])
    EJECUTAR("DPCAMPOSETDEF","DPCLIENTES"  ,"CLI_ACTIVI",[&oDp:cCodActEco])
    EJECUTAR("DPCAMPOSETDEF","DPCLIENTES"  ,"CLI_PAGELE",["N"])
    EJECUTAR("DPCAMPOSETDEF","DPCLIENTES"  ,"CLI_DESFIJ",["N"])

    EJECUTAR("DPCAMPOSETDEF","DPMOVINV"    ,"MOV_TIPIVA",["GN"])


    SQLDELETE("DPVISTAS","VIS_NOMBRE"+GetWhere("=","EASYDOCANU")) 
    SQLDELETE("DPVISTAS","VIS_NOMBRE"+GetWhere("=","EASYDOCMEN"))

    // 31/05/2023
    SQLUPDATE("DPMENU","MNU_ACCION",[EJECUTAR("BRREPPATEMP")],"MNU_CODIGO"+GetWhere("=","07O87"))
 
    SQLDELETE("DPMAPAMNUCPO","MXM_CODOPC"+GetWhere("=","01O58"))
    SQLDELETE("DPMENU","MNU_TITULO"+GetWhere("=","Edición Vertical de Trabajadores")+" AND MNU_CODIGO"+GetWhere("=","01O58"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                     {"07O97"     ,"07"        ,"97"        ,"O"         ,[EJECUTAR("NMTRABAJADOREDIT")],[.T.]               ,4         ,[{oDP:DPEXPTAREASDEF}]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","07O97"))

    SQLUPDATE("DPMENU","MNU_TITULO","ARC Prestadores de Servicios","MNU_TITULO"+GetWhere("=","ARC Proveedores"))

    SQLUPDATE("DPMENU","MNU_TITULO","Ausencias, Inasistencias y Reposos","MNU_TITULO"+GetWhere("=","Ausencias"))

    SQLUPDATE("DPCAMPOS","CAM_DEFAUL","",GetWhereOr("CAM_NAME",{"MOV_X","MOV_Y","MOV_Z","MOV_PESO","MOV_PESEXP","MOV_TOTDIV","MOV_ITEM_D"}))
    SQLUPDATE("DPCAMPOS","CAM_DEFAUL","","CAM_DEFAUL"+GetWhere("=",".F.")+" AND CAM_TYPE"+GetWhere("<>","L"))
    SQLUPDATE("DPCAMPOS","CAM_DEFAUL","","CAM_DEFAUL"+GetWhere("=",".T.")+" AND CAM_TYPE"+GetWhere("<>","L"))

    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_CODMON","&oDp:cMonedaExt")
    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_USUARI","&oDp:cUsuario")
    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_ENOTRA",["S"])

    EJECUTAR("DPCAMPOSOPCSETCOLOR")

    EJECUTAR("DPCAMPOSADD" ,"DPIPC"   ,"IPC_IPC" ,"N",19,5,"IPC")

    EJECUTAR("ADDONADD","EDC","Envio de Datos para Contabilidad")
    EJECUTAR("ADDONADD","DDC","Descargar Datos para Contabilidad")
    EJECUTAR("ADDONADD","VCS","Ventas a Consignación")

    SQLUPDATE("DPMENU","MNU_TITULO","Proveedores Ocasionales","MNU_TITULO"+GetWhere("=","Proveedores Esporádicos"))
    SQLUPDATE("DPMENU","MNU_TITULO","Proveedores Ocasionales","MNU_TITULO"+GetWhere("=","Proveedores Exporádicos"))
    SQLUPDATE("DPMENU","MNU_ACCION",[DPLBX("dpproveedor_ocasional.LBX")],"MNU_CODIGO"+GetWhere("=","04F91"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"   },;
                                     {"04O03"     ,"04"        ,"03"        ,"O"         ,[EJECUTAR("DPTIPDOCPRO_TES")],[]          ,1         ,[Tipo de Documento Prestador de Servicios y Tributos]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","04O03"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"          ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"   },;
                                     {"01F64"     ,"01"        ,"64"        ,"F"         ,[DPLBX("DPCATSAT.LBX")],[]          ,1         ,[{oDp:DPCATSAT}]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","01F64"))

// EJECUTAR("DPLINKADD","DPDOCPRO","DPDOCPROISLR","DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO,DOC_TIPTRA","RXP_CODSUC,RXP_DOCTIP,RXP_CODIGO,RXP_DOCNUM,RXP_TIPTRA",.T.,.T.,.T.)

    SQLUPDATE("DPMENU","MNU_TIPO",4,"MNU_CODIGO"+GetWhere("=","08F78"))
    SQLUPDATE("DPMENU","MNU_TIPO",1,"MNU_CODIGO"+GetWhere("=","05F30"))

    SQLUPDATE("DPMENU","MNU_TITULO","Documentos de Compras","MNU_CODIGO"+GetWhere("=","02A00"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05F32"     ,"05"        ,"32"        ,"F"         ,[EJECUTAR("DPEDITCTAINDF")],[.T.],1         ,[Asignar Cuentas para Indices Financieros]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05F32"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"             ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05F33"     ,"05"        ,"33"        ,"F"         ,[DPLBX("DPDPTO.LBX")]    ,[.T.]              ,1         ,[{oDp:DPDPTO}]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05F33"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"             ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05F34"     ,"05"        ,"34"        ,"F"         ,[DPLBX("DPCENCOS.LBX")]  ,[.T.]              ,4         ,[{oDp:DPCENCOS}]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05F34"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                          ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05P08"     ,"05"        ,"08"        ,"P"         ,[EJECUTAR("BRCBTFIJORES",NIL,NIL,11)],[],1         ,[Crear Comprobantes Fijos]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05P08"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05P13"     ,"05"        ,"13"        ,"P"         ,[EJECUTAR("DPFRXRUN")]       ,[.T.],1         ,[Indices Financieros]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05P13"))

    SQLDELETE("DPMENU","MNU_CODIGO"+GetWhere("=","05P98"))

//? oDp:cSql	

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"08F80"     ,"08"        ,"80"        ,"F"         ,[EJECUTAR("BRCALDEBFORMALR")],[.T.],1         ,[Resumen de Deberes Formales]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","08F80"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"08F85"     ,"08"        ,"85"        ,"F"         ,[EJECUTAR("BRCALDEBFORMAL")],[.T.],1         ,[Detalles de Deberes Formales]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","08F85"))


   EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO" },; 
                                   {"05C65"     ,"05"        ,"65"        ,"C"         ,[EJECUTAR("BRWCOMPROBACION")],[]          ,1         ,[Balance de Comprobación]},;
                                   NIL,.T.,"MNU_CODIGO"+GetWhere("=","05C65"))

   EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO" },; 
                                   {"05C67"     ,"05"        ,"67"        ,"C"         ,[EJECUTAR("BRWGANANCIAYP")],[]          ,1         ,[Estado de Ganancias y Pérdidas]},;
                                   NIL,.T.,"MNU_CODIGO"+GetWhere("=","05C67"))



  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"            ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"                },; 
                                    {"00M66"     ,"00"        ,"66"        ,"M"         ,[DPLBX("DPDPTOSEL.LBX",NIL,NIL,NIL,NIL,oDp:cCodDep)],[]          ,1         ,[Seleccionar {oDp:xDPDPTO} ]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","00M66"))

  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"            ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"                },; 
                                    {"04O15"    ,"04"        ,"15"        ,"O"         ,[EJECUTAR("CONFIGCXCDIV")],[]          ,1       ,[Definir Diferencial Cambiario]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","04O15"))

  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"            ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"                },; 
                                    {"04C15"    ,"04"        ,"15"        ,"C"         ,[EJECUTAR("BRCAJBCORES")],[]          ,1       ,[Resumen de Caja y Bancos]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","04C15"))

  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"            ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"                },; 
                                    {"04C20"    ,"04"        ,"20"        ,"C"         ,[EJECUTAR("BRCAJBCODET")],[]          ,1       ,[Detalle de Caja y Bancos]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","04C20"))

  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"            ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"                },; 
                                    {"04C25"    ,"04"        ,"25"        ,"C"         ,[EJECUTAR("BRDOCPRODOC")],[]          ,1       ,[Resumen de Documentos de Cuentas por Pagar]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","04C25"))

  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"            ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"                },; 
                                    {"04C27"    ,"04"        ,"27"        ,"C"         ,[EJECUTAR("FACSINFCHDEC")],[]          ,1       ,[Facturas de Compra sin Fecha de Declaración]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","04C27"))

  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"                },; 
                                    {"04C29"    ,"04"        ,"29"        ,"C"         ,[EJECUTAR("BRRECINGDOCXIMP")],[]          ,1       ,[Documentos Fiscales Creados desde Recibos de Ingresos por Imprimir]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","04C29"))

  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"                },; 
                                    {"04C30"    ,"04"        ,"30"        ,"C"         ,[EJECUTAR("BRDOCCLIXMOT")],[]          ,1       ,[Resumen de Documentos Creados desde Motivos]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","04C30"))



  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"            ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"                },; 
                                    {"08C50"    ,"08"        ,"50"        ,"C"         ,[EJECUTAR("BRDOCPRORTI")],[]          ,1       ,[Retenciones de IVA Facturas de Compra]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","08C50"))

  SQLUPDATE("DPMENU","MNU_TITULO","Calcular IGTF de Caja","MNU_CODIGO"+GetWhere("=","08P10"))

  EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"            ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO"                },; 
                                    {"08P45"    ,"08"        ,"45"        ,"P"         ,[EJECUTAR("BRARIANUALXCALC")],[]          ,1       ,[Calcular "A.R.I" por Trabajador]},;
                                    NIL,.T.,"MNU_CODIGO"+GetWhere("=","08P45"))

  SQLUPDATE("DPMENU","MNU_TIPO",4,"MNU_CODIGO"+GetWhere("=","08P45"))


  aFields:={}
  AADD(aFields,{"FYT_CONESP","L",001,0,"Especial"     ,""})
  AADD(aFields,{"FYT_CONORD","L",001,0,"Ordinario"    ,""})
  AADD(aFields,{"FYT_CONGUB","L",001,0,"Gubernamental",""})

  AEVAL(aFields,{|a,n|  EJECUTAR("DPCAMPOSADD" ,"DPFORMYTAREAS",a[1],a[2],a[3],a[4],a[5]),;
                        EJECUTAR("SETFIELDLONG","DPFORMYTAREAS",a[1],a[3],a[4])})

  SQLUPDATE("DPFORMYTAREAS","FYT_CONESP",.T.,"FYT_CONESP IS NULL")
  SQLUPDATE("DPFORMYTAREAS","FYT_CONORD",.T.,"FYT_CONORD IS NULL")
  SQLUPDATE("DPFORMYTAREAS","FYT_CONGUB",.T.,"FYT_CONGUB IS NULL")

  EJECUTAR("CREARLIBVTAMES")

    aFields:={}
    AADD(aFields,{"PFT_FILMAI","N",007,0,"Registro Digitalización"                    ,""})

    AEVAL(aFields,{|a,n|  EJECUTAR("DPCAMPOSADD" ,"DPFORMYTAREASPROG",a[1],a[2],a[3],a[4],a[5]),;
                          EJECUTAR("SETFIELDLONG","DPFORMYTAREASPROG",a[1],a[3],a[4])})

    SQLDELETE("DPMENU","MNU_CODIGO"+GetWhere("=","05O20"))

    IF ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","05P06")) .AND. ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","05P23"))
       SQLDELETE("DPMENU","MNU_CODIGO"+GetWhere("=","05P06"))
    ENDIF

    IF ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","05P07")) .AND. ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","05P24"))
       SQLDELETE("DPMENU","MNU_CODIGO"+GetWhere("=","05P07"))
    ENDIF

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"              ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05P23"     ,"05"        ,"23"        ,"P"         ,[EJECUTAR("BRASIENTOSTIP",NIL,NIL,10)],[.T.]        ,1         ,[Asignar Cuenta en Asientos Indefinidos por Código de Integración]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05P23"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                          ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05P24"     ,"05"        ,"24"        ,"P"         ,[EJECUTAR("BRASIENTOSINDEF",NIL,NIL,10)],[],1      ,[Asignar Cuenta en Asientos Indefinidos por Tipo de Documento]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05P24"))

    SQLUPDATE("DPMENU","MNU_TIPO",1,"MNU_CODIGO"+GetWhere("=","05P22"))
    SQLUPDATE("DPMENU","MNU_TIPO",4,"MNU_CODIGO"+GetWhere("=","05P24"))

    SQLUPDATE("DPMENU","MNU_TIPO",4,"MNU_CODIGO"+GetWhere("=","08F72"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"              ,"MNU_CONDIC"         ,"MNU_TIPO","MNU_TITULO"     },;
                                     {"08F75"     ,"08"        ,"75"        ,"F"         ,[EJECUTAR("BRDIGXEMPRESA")],[.T.],1         ,[Definir Cartelera Fiscal]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","08F75"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"              ,"MNU_CONDIC"         ,"MNU_TIPO","MNU_TITULO"     },;
                                     {"08F78"     ,"08"        ,"78"        ,"F"         ,[EJECUTAR("BRCARFISANUAL")],[.T.],1         ,[Digitalizar Cartelera Fiscal]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","08F78"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"               ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO" },; 
                                     {"05O52"   ,"05"        ,"52"        ,"O"         ,[EJECUTAR("DPASIENTOSCOL")],[],1,[Definir Columnas del Asiento]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05O52"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"               ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO" },; 
                                     {"05O55"   ,"05"        ,"55"        ,"O"         ,[DPLBX("DPNUMCBTE.LBX")],[],1,[Definir Número del Comprobante]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05O55"))

                                                                                             
    SQLUPDATE("DPMENU",{"MNU_TITULO"                    ,"MNU_ACCION"},;
                       {"Definir Número del Comprobante",[DPLBX("DPNUMCBTE.LBX")]},"MNU_CODIGO"+GetWhere("=","05O55"))

    cAction:=[EJECUTAR("BRPROCESOSACT","PRC_CLASIF"+GetWhere("=","Contables"),NIL,NIL,NIL,NIL,"Contables")]                          

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION" ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05O58"     ,"05"        ,"58"        ,"O"         ,cAction      ,[.T.],1         ,[Activar Procesos Automáticos para Contabilidad]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05O58"))


    IF !ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","04F41"))

      SQLUPDATE("DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO"},;
                         {"04F41"     ,"04"        ,"41"        },"MNU_CODIGO"+GetWhere("=","05F20"))

    
      EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"          ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                       {"08P09"     ,"08"        ,"09"        ,"P"         ,[EJECUTAR("DPLIBVTA")],[.T.]        ,4         ,[Libro de Ventas]},;
                                       NIL,.T.,"MNU_CODIGO"+GetWhere("=","08P09"))

    ENDIF

    SQLUPDATE("DPMENU","MNU_TIPO",1,"MNU_CODIGO"+GetWhere("=","08P13"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"          ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"08P14"     ,"08"        ,"14"        ,"P"         ,[EJECUTAR("BRARCANUALXCALC")],[.T.]        ,4       ,[ARC Proveedores]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","08P14"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"          ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"08P40"     ,"08"        ,"40"        ,"P"         ,[EJECUTAR("INCESTOCXP")],[.T.]        ,1       ,[Calcular INCES]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","08P40"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"          ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"08P42"     ,"08"        ,"42"        ,"P"         ,[EJECUTAR("IVSSOTOCXP","IVS")],[.T.]        ,1       ,[Calcular Seguro Social IVSSO]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","08P42"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"          ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"08P44"     ,"08"        ,"44"        ,"P"         ,[EJECUTAR("IVSSOTOCXP","HAB")],[.T.]        ,1       ,[Calcular Habitat y Vivienda]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","08P44"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"03O06"     ,"03"        ,"06"        ,"O"         ,[DPLBX("DPTIPDOCCLIMOT.LBX")],[.T.]        ,1       ,[{oDp:DPTIPDOCCLIMOT}]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","03O06"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05C60"     ,"05"        ,"60"        ,"C"         ,[EJECUTAR("BREJERRESRES")]   ,[.T.]        ,1       ,[Ecuación del Patrimonio de los Ejercicios]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05C60"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05C62"     ,"05"        ,"62"        ,"C"         ,[EJECUTAR("BCANUAL")]   ,[.T.]        ,1       ,[Resumen por Ejercicio Contable]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05C62"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05C70"     ,"05"        ,"70"        ,"C"         ,[EJECUTAR("BRMAYVSBALCOM")]  ,[.T.]        ,1       ,[Comparativo Balance Comprobación Vs Mayor Analítico]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05C70"))


    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05C75"     ,"05"        ,"75"        ,"C"         ,[EJECUTAR("BRWMAYORANALITICO",NIL,oDp:dFchInicio,oDp:dFchCierre)]    ,[.T.]        ,1       ,[Mayor Analítico]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05C75"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05C77"     ,"05"        ,"77"        ,"C"         ,[EJECUTAR("BRACCENCOSVER",NIL,NIL,10,oDp:dFchInicio,oDp:dFchCierre)]  ,[.T.]     ,1       ,[Vertical por Centro de Costos]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05C77"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05C79"     ,"05"        ,"79"        ,"C"         ,[EJECUTAR("BRRESASIXCOS",NIL,NIL,10,oDp:dFchInicio,oDp:dFchCierre)]  ,[.T.]     ,1       ,[Resultados por Centro de Costos]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05C79"))



    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"07C10"     ,"07"        ,"10"        ,"C"         ,[EJECUTAR("BRINDROTLABORAL",NIL,NIL,oDp:nIndefinida,CTOD(""),CTOD(""))]  ,[.T.]     ,1       ,[Indice de Rotación de Laboral]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","07C10"))

    IF !ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","04F42"))

      SQLUPDATE("DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO"},;
                         {"04F42"     ,"04"        ,"42"        },"MNU_CODIGO"+GetWhere("=","05F21"))

      SQLUPDATE("DPMENU","MNU_TIPO",4,"MNU_CODIGO"+GetWhere("=","04F42"))

    ENDIF


    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"          ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"07F80"     ,"07"        ,"80"        ,"F"         ,[EJECUTAR("NMCONFIG")],[.T.]        ,4         ,[Configuración de Nómina]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","07F80"))

    SQLUPDATE("DPMENU","MNU_TIPO",1,"MNU_CODIGO"+GetWhere("=","08P11"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"             ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"08P12"     ,"08"        ,"12"        ,"P"         ,[EJECUTAR("BRRESIMPMUN")],[.T.]        ,4         ,[Impuesto Patente Municipal]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","08P12"))


    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"          ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"22P95"     ,"22"        ,"95"        ,"P"         ,[EJECUTAR("DPTABLASIMPORTDATA")],[.T.]        ,1   ,[Importar Registros desde Otra Base de Datos]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","22P95"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"          ,"MNU_CONDIC"             ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05O64"     ,"05"        ,"64"        ,"O"         ,[EJECUTAR("DPIMPRXLSASIENTOSXLS")],[.T.]        ,1   ,[Importar Asientos desde Excel]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05O64"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"             ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05O65"     ,"05"        ,"65"        ,"O"         ,[EJECUTAR("BRBALINIDIV")],[.T.]        ,4         ,[Cargar Balance Inicial]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","05O65"))

    SQLUPDATE("DPMENU","MNU_TIPO",4,"MNU_CODIGO"+GetWhere("=","05O58"))
    SQLUPDATE("DPMENU","MNU_TIPO",1,"MNU_CODIGO"+GetWhere("=","05O63"))
    SQLUPDATE("DPMENU","MNU_TIPO",1,"MNU_CODIGO"+GetWhere("=","05O60"))

    SQLUPDATE("DPMENU","MNU_TIPO",4,"MNU_CODIGO"+GetWhere("=","22P93"))


    // Replantear Contabilidad 09/03/2023

    IF !ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","05O60"))
      SQLUPDATE("DPMENU",{"MNU_CODIGO","MNU_VERTIC","MNU_HORIZO"},{"05O60","O","60"},"MNU_CODIGO"+GetWhere("=","05P60"))
    ENDIF

    IF !ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","05O61"))

      SQLUPDATE("DPMENU",{"MNU_CODIGO","MNU_VERTIC","MNU_HORIZO"},{"05O61","O","61"},"MNU_CODIGO"+GetWhere("=","05P61"))

      SQLUPDATE("DPMENU","MNU_TIPO",4,"MNU_CODIGO"+GetWhere("=","05O58"))
      SQLUPDATE("DPMENU","MNU_TIPO",1,"MNU_CODIGO"+GetWhere("=","05O63"))
      SQLUPDATE("DPMENU","MNU_TIPO",1,"MNU_CODIGO"+GetWhere("=","05O61"))

    ENDIF

    IF !ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","05O70"))
      SQLUPDATE("DPMENU",{"MNU_CODIGO","MNU_VERTIC","MNU_HORIZO"},{"05O70","O","70"},"MNU_CODIGO"+GetWhere("=","05P22"))
    ENDIF

    IF !ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","05O71"))
      SQLUPDATE("DPMENU",{"MNU_CODIGO","MNU_VERTIC","MNU_HORIZO"},{"05O71","O","71"},"MNU_CODIGO"+GetWhere("=","05P23"))
      SQLUPDATE("DPMENU","MNU_TIPO",1,"MNU_CODIGO"+GetWhere("=","05O72"))
    ENDIF

    IF !ISSQLFIND("DPMENU","MNU_CODIGO"+GetWhere("=","05O72"))
      SQLUPDATE("DPMENU",{"MNU_CODIGO","MNU_VERTIC","MNU_HORIZO"},{"05O72","O","72"},"MNU_CODIGO"+GetWhere("=","05P24"))
    ENDIF

    EJECUTAR("DPADDMENUNOM")

    SQLUPDATE("DPMENU","MNU_TITULO","Registro local de Personalizaciones"           ,"MNU_CODIGO"+GetWhere("=","19F75"))
    SQLUPDATE("DPMENU","MNU_TITULO","Subir Personalizaciones hacia AdaptaPro Server","MNU_CODIGO"+GetWhere("=","19O01"))
    SQLUPDATE("DPMENU","MNU_TITULO","Recuperación local de Personalizaciones"       ,"MNU_CODIGO"+GetWhere("=","20P74"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO" },;
                                     {"07F15"     ,"07"        ,"15"        ,"F"         ,[DPLBX("NMTRABAJADOR.LBX")]  ,[]          ,1         ,[Browse de Trabajador con Datos Básicos]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","07F15"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO" },;
                                     {"03F12"     ,"03"        ,"12"        ,"F"         ,[DPLBX("DPCLIENTESBRW.LBX")] ,[]          ,1         ,[Browse de Clientes con Datos Básicos]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","03F12"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"         ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"19O75"     ,"19"        ,"75"        ,"O"         ,[EJECUTAR("DOCMD")]  ,[.T.]        ,1       ,[Ejecutar Comando]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","19O75"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"         ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"19O78"     ,"19"        ,"78"        ,"O"         ,[EJECUTAR("QRFORM")]  ,[.T.]        ,1       ,[Crear Código QR]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","19O78"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                    ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"19O79"     ,"19"        ,"79"        ,"O"         ,[EJECUTAR("ASCIIFROMCODEBAR")]  ,[.T.]        ,1       ,[Explorar Caracteres del Lector de Barras]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","19O79"))



    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"         ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05O74"     ,"05"        ,"74"        ,"O"         ,[EJECUTAR("DPASIENTOSFIND")]  ,[.T.]        ,1       ,[Editar/Modificar Comprobantes y Asientos Contables]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05O74"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"         ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05O75"     ,"05"        ,"75"        ,"O"         ,[EJECUTAR("DPASIENTOSFIND")]  ,[.T.]        ,1       ,[Buscar Asientos por Descripción ]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05O75"))

    SQLUPDATE("DPMENU","MNU_TIPO",4,"MNU_CODIGO"+GetWhere("=","05O75"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"         ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05O77"     ,"05"        ,"77"        ,"O"         ,[EJECUTAR("BRASIENTOSEXP")]  ,[.T.]        ,1       ,[Expotar Comprobantes]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05O77"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"         ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"05O78"     ,"05"        ,"78"        ,"O"         ,[EJECUTAR("DPCBTIMPORT")]  ,[.T.]  ,1       ,[Importar Comprobantes]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","05O78"))


  ENDIF

  SQLDELETE([DPLINK],[LNK_TABLES="DPCAJAINST" AND LNK_TABLED="DPCTA"])

  EJECUTAR("DPCAMPOSADD" ,"DPVISTAS","VIS_PRGPRE"    ,"C",30,2,"Programa Prejecución")
  EJECUTAR("SETFIELDLONG","DPCAMPOS","CAM_FORMAT" ,35)

  EJECUTAR("SETFIELDLONG","DPUSUARIOS","OPE_CLAMD5",250,0	)
  EJECUTAR("SETFIELDLONG","DPUSUARIOS","OPE_NOMMD5",250,0	)

  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FILDPX" ,10)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FILREP" ,10)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FILRPT" ,10)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FILFRM" ,10)

  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHFRM" ,20)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHREP" ,20)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHRPT" ,20)
  EJECUTAR("SETFIELDLONG","DPPCLOG","PC_FCHFRM" ,20)

  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_RIFLIC","C",15,0,"Rif;Licencia"   ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_EMPIDD","C",04,0,"Clave;Descarga" ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_FCHDWN","D",08,0,"Ultima;Descarga",NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_PERIOD","C",15,0,"Periodo;Envio",NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_ENVAUT","L",01,0,"Envio;Automático",NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_INICXC","L",01,0,"Copiar CxC",NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_INICXP","L",01,0,"Copiar CxP",NIL)

  EJECUTAR("CREATERECORD","DPGRUREP",{"GRR_CODIGO"  ,"GRR_DESCRI"  },; 
                                     {STRZERO(701,8),"Trabajadores"},;
                                      NIL,.T.,"GRR_CODIGO"+GetWhere("=",STRZERO(701,8)))

  EJECUTAR("CREATERECORD","DPGRUREP",{"GRR_CODIGO"  ,"GRR_DESCRI"  },; 
                                     {STRZERO(700,8),"Pista	s de Auditoria"},;
                                      NIL,.T.,"GRR_CODIGO"+GetWhere("=",STRZERO(700,8)))

  SQLUPDATE("DPREPORTES","REP_GRUPO",STRZERO(701,8),[REP_GRUPO="00000700" AND LEFT(REP_TABLA,2)="NM"])

  IF oDp:cType="NOM"

    SQLUPDATE("DPMENU","MNU_ACCION",[EJECUTAR("REPGRU",STRZERO(701,8))],"MNU_CODIGO"+GetWhere("01I01"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                 ,"MNU_CONDIC","MNU_TIPO","MNU_TITULO" },;
                                     {"01F15"     ,"01"        ,"15"        ,"F"         ,[DPLBX("NMTRABAJADOR.LBX")]  ,[]          ,1         ,[Browse de Trabajador con Datos Básicos]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","01F15"))

    SQLDELETE("DPINDEX","IND_TABLA"+GetWhere("=","NMCLACONOCI"))
    SQLDELETE("DPINDEX","IND_TABLA"+GetWhere("=","NMGRUCONOCI"))

    SQLDELETE("DPLINK" ,"LNK_TABLES"+GetWhere("=","NMCLACONOCI"))
    SQLDELETE("DPLINK" ,"LNK_TABLES"+GetWhere("=","NMGRUCONOCI"))

    EJECUTAR("DPLINKADD","NMGRUCONOCI","NMCLACONOCI","CNC_GRUCON","CDC_GRUPO",.T.,.T.,.T.)

  ELSE

    SQLUPDATE("DPMENU","MNU_ACCION",[EJECUTAR("REPGRU",STRZERO(701,8))],"MNU_CODIGO"+GetWhere("07I01"))

  ENDIF


  cWhere:="CAM_TABLE"+GetWhere("=","DPPCLOG")+" AND "+GetWhereOr("CAM_NAME",{"PC_FCHREP","PC_FCHRPT","PC_FCHFRM"})
  SQLUPDATE("DPCAMPOS",{"CAM_TYPE","CAM_LEN"},{"C",10},cWhere)

  cWhere:="CAM_TABLE"+GetWhere("=","DPUSUARIOS")+" AND "+GetWhereOr("CAM_NAME",{"OPE_FILTRO"})
  SQLUPDATE("DPCAMPOS","CAM_DEFAUL",".T.",cWhere)

  CheckTable("DPPCLOG")

  EJECUTAR("SETFIELDLONG","DPCAMPOSOP","OPC_CAMPO" ,20)

  EJECUTAR("DPMENUDELMACROS") // Remover &en Textos del Menu

  // Remueve Tablas de Nómina Innecesarios
  IF oDp:cType="NOM"
     AADD(aNo,"DPMOVINV")
     AADD(aNo,"DPDOCPRO")
     AADD(aNo,"DPDOCCLI")
     AADD(aNo,"DPTIPDOCCLI")
     AADD(aNo,"DPTIPDOCPRO")
     AADD(aNo,"DPACTIVOS")
     AADD(aNo,"DPDEPRECIAACT")
     AADD(aNo,"DPCLIENTES")
     AADD(aNo,"DPMOVINV_HIS")
  ENDIF

// ? "AQUI NUEVAMENTE VA REVISAR LA ESTRUCTURA"

  AEVAL(aNo,{|a,n| SQLDELETE("DPTABLAS","TAB_NOMBRE"+GetWhere("=",a))})
  AEVAL(aNo,{|a,n| SQLDELETE("DPCAMPOS","CAM_TABLE" +GetWhere("=",a))})
  AEVAL(aNo,{|a,n| SQLDELETE("DPINDEX" ,"IND_TABLA" +GetWhere("=",a))})
  AEVAL(aNo,{|a,n| SQLDELETE("DPLINK"  ,"LNK_TABLES"+GetWhere("=",a))})
  AEVAL(aNo,{|a,n| SQLDELETE("DPLINK"  ,"LNK_TABLED"+GetWhere("=",a))})

  SQLDELETE("DPLINK",[LNK_TABLED="DPCTA" AND LNK_TABLES="DPCODINT"])

  EJECUTAR("DPLINKADD","DPMENU","DPMAPAMNUCPO","MNU_CODIGO","MXM_CODOPC",.T.,.T.,.T.)

  AEVAL(aNo,{|a,n| FERASE("STRUCT\"+a+".TXT")})


  EJECUTAR("DPTRIGGERSFIX")
  EJECUTAR("DPDEPURALINK") // Remueve Enlaces innecesarios

//  EJECUTAR("DSNCHECKTABLE",oDp:cDsnConfig)

  oDp:oDpSetNull:=lNull

  oDp:lSayCheckTable:=.F.

  // Evita la Pregunta si desea Actualizar el Diccionario de Datos.
  IF !lRun
     DPWRITE(cFileChk,cFileChk)
     RETURN .T.
  ENDIF

  IF lAsk .AND. !MsgNoYes("Desea Actualizar Diccionario de Datos ["+oDp:cDsnConfig+"]"+CRLF+" Revisión "+RIGHT(cId,4)+" Opción NO recomendada")

    oData:=DATACNF("CNFADDFIELD","ALL")
    oData:Set("CNFADDFIELD",cid)
    oData:Save()
    oData:End()

    cSql:=" SET FOREIGN_KEY_CHECKS = 1"
    oDb:Execute(cSql)


    RETURN .T.

  ENDIF

  oDp:oSay:SetText("Removiendo Claves de "+oDp:cDsnConfig)
  EJECUTAR("DPDROPALL_FK",oDp:cDsnConfig,.T.)

  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS" ,"TAB_CHKSUM","N",19,0,"CheckSum")
  EJECUTAR("SETFIELDLONG","DPTABLAS","TAB_CHKSUM" ,19)

  CLOSE ALL
  SELECT A
  USE "DATADBF\DPTABLAS.DBF"
// SET FILTER TO TAB_CONFIG=.T. .AND. LEFT(TAB_NOMBRE,5)<>"VIEW_"
  SET FILTER TO LEFT(TAB_NOMBRE,5)<>"VIEW_"

  lChkSum:=FIELDPOS("TAB_CHKSUM")>0

  GO TOP
  DBEVAL({||AADD(aTablas,A->TAB_NOMBRE),;
            AADD(aConfig,A->TAB_CONFIG),;
            AADD(aChkSum,IF(lChkSum,A->TAB_CHKSUM,0))})
  USE

  MsgRun("Revisando Tablas de Diccionario de Datos "+oDp:cDsnConfig)

// Vistas Vacias
  IF EJECUTAR("DBISTABLE",oDp:cDsnConfig,"DPVISTAS")
     SQLDELETE("DPVISTAS","VIS_VISTA"+GetWhere("=",""))
  ENDIF

// ? "aQUITAR,DPINIADDFIELD"
//RETURN .T.

  cLen:=LSTR(LEN(aTablas))

  EJECUTAR("DPTRIGGERSDELA",oDp:cDsnConfig)


  FOR I=1 TO LEN(aTablas)


     IF !ISSQLFIND("DPTABLAS","TAB_NOMBRE"+GetWhere("=",aTablas[I]))

       IF ValType(oDp:oSay)="O"

//         oDp:oSay:SetText("Nueva Tabla "+aTablas[I]+" ("+LSTR(I)+"/"+LSTR(LEN(aTablas)))+")"
         EJECUTAR("DPTABLANODICCDAT",aTablas[I])

       ELSE

         MsgRun("Tabla "+aTablas[I]+" ("+LSTR(LEN(aTablas))+"/"+LSTR(I)+")","Por favor espere..",{||EJECUTAR("DPTABLANODICCDAT",aTablas[I])})

       ENDIF

       IF !ISSQLFIND("DPTABLAS","TAB_NOMBRE"+GetWhere("=",aTablas[I]))
          EJECUTAR("DPFILSTRTAB",aTablas[I],.T.)
       ENDIF

     ELSE

       cFile:="STRUCT\"+aTablas[I]+".TXT"

       IF !FILE(cFile)
          EJECUTAR("EJMIMPDATOS",aTablas[I])
       ENDIF

       EJECUTAR("DPFILSTRTAB",aTablas[I],aConfig[I],aChkSum[I]) // Agrega los Campos Nuevos
       

     ENDIF
 
     SysRefresh(.T.)

/*
     ELSE

       // Debe Actualizar la estructura
       EJECUTAR("DPFILSTRTAB",aTablas[I],.T.)

     ENDIF

     IF !oDb:File(aTablas[I])
        Checktable(aTablas[I])
     ENDIF
*/

     SysRefresh(.T.)

  NEXT I

  oTable:=OpenTable("SELECT TAB_NOMBRE,TAB_CHKSUM FROM DPTABLAS WHERE TAB_CONFIG=1",.T.)

  WHILE !oTable:Eof()


     // Si no Existe la Crea
     cFile:="STRUCT\"+ALLTRIM(oTable:TAB_NOMBRE)+".TXT"

     IF !FILE(cFile)
         EJECUTAR("EJMIMPDATOS",oTable:TAB_NOMBRE)
     ENDIF


     IF ValType(oDp:oSay)="O"

       oDp:oSay:SetText("Importando Tablas "+ALLTRIM(oTable:TAB_NOMBRE)+" "+LSTR(oTable:RecNo())+"/"+LSTR(oTable:RecCount()))

       EJECUTAR("DPFILSTRTAB",oTable:TAB_NOMBRE,.T.,oTable:TAB_CHKSUM)

     ELSE

       MsgRun("Actualizando Tabla "+ALLTRIM(oTable:TAB_NOMBRE)+" "+LSTR(oTable:RecNo())+"/"+LSTR(oTable:RecCount()),"Por favor espere..",{||EJECUTAR("DPFILSTRTAB",oTable:TAB_NOMBRE,.T.,oTable:TAB_CHKSUM)})

     ENDIF

     oTable:DbSkip()

  ENDDO

  oTable:GoTop()

  WHILE !oTable:Eof()

     IF !oDb:File(oTable:TAB_NOMBRE)
        Checktable(oTable:TAB_NOMBRE)
     ENDIF

     oTable:DbSkip()

  ENDDO
	
  oTable:End()

  SQLUPDATE("DPCAMPOS","CAM_TYPE","C","CAM_TYPE"+GetWhere("=","1")+" OR CAM_NAME"+GetWhere("=","TRG_NOMBRE"))

  cSql:="UPDATE DPCAMPOS SET CAM_TYPE='C'  WHERE  CAM_TYPE='1' OR CAM_NAME='TRG_NOMBRE' "

  oDb:Execute(cSql)

  EJECUTAR("DPCAMPOSADD","DPVISTAS"  ,"VIS_PRGPRE" ,"C",20,0,"Programa DpXbase Pre Construcción ")
  SQLUPDATE("DPVISTAS"  ,"VIS_PRGPRE","CLICAT_FUNC","VIS_VISTA"+GetWhere("=","EPED_CLIENTES"))

  EJECUTAR("DPCAMPOSADD","DPTRIGGERS "  ,"TRG_FECHA" ,"D",8,0,"Fecha")
  EJECUTAR("DPCAMPOSADD","DPTRIGGERS "  ,"TRG_HORA"  ,"C",8,0,"Hora")
  EJECUTAR("DPCAMPOSADD","DPTRIGGERS "  ,"TRG_NOMBRE","C",120,0,"Nombre")
  EJECUTAR("DPCAMPOSADD","DPTRIGGERS "  ,"TRG_ACTIVO","L",01 ,0,"Activo",NIL,.T.,.T.,".T.")

  EJECUTAR("DPCAMPOSADD","DPINTREF"     ,"INT_DXBASE","C",30 ,0,"Programa DpXbase")
  EJECUTAR("DPCAMPOSADD","DPINTREF"     ,"INT_MODO"  ,"C",20 ,0,"Modo")
  EJECUTAR("DPCAMPOSADD","DPINTREF"     ,"INT_SQLERR","M",10 ,0,"Mensaje SQL")
  EJECUTAR("DPCAMPOSADD","DPINTREF"     ,"INT_SQL"   ,"M",10 ,0,"Sentencia SQL")


  EJECUTAR("DPCAMPOSADD","DPPCLOGAPP","PCL_AUTORI","L",01 ,0,"Autorizado",NIL,.T.,.T.,".T.")
  EJECUTAR("DPCAMPOSADD","DPPCLOGAPP","PCL_AUDITA","L",01 ,0,"Audita"    ,NIL,.T.,.T.,".T.")
  EJECUTAR("DPCAMPOSADD","DPPCLOGAPP","PCL_NOMBRE","C",250,0,"Nombre"    ,NIL,.T.,.T.,".T.")

  EJECUTAR("DPCAMPOSADD","DPPCLOGAPP","PCL_TITULO","C",250,0,"Titulo"    )
  EJECUTAR("DPCAMPOSADD","DPPCLOGAPP","PCL_FECHA" ,"D",8  ,0,"Fecha"     ,NIL,NIL,NIL,"oDp:dFecha")

  EJECUTAR("SETFIELDLONG","DPCAMPOS"  ,"CAM_COMMAN" ,80)
  EJECUTAR("SETFIELDLONG","DPLINK"    ,"LNK_PRGPRE" ,30)
  EJECUTAR("SETFIELDLONG","DPLINK"    ,"LNK_PRGPOS" ,30)

// EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_CHKSUM","N",19,0,"CheckSum")

  EJECUTAR("SETFIELDLONG","DPTABLAS"  ,"TAB_CHKSUM",19)

//EJECUTAR("DPCAMPOSADD" ,"DPDATACNF"  ,"TAB_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])

  EJECUTAR("DPCAMPOSADD" ,"DPCAMPOS"  ,"CAM_FORMAT" ,"C",20,0,"Formato",NIL,.T.,"")
  EJECUTAR("DPCAMPOSADD" ,"DPCAMPOS"  ,"CAM_HORA"   ,"C",08,0,"Hora",NIL,.T.,"")
  EJECUTAR("DPCAMPOSADD" ,"DPCAMPOS"  ,"CAM_DEFAUL" ,"C",200,0,"Hora",NIL,.T.,"")

  EJECUTAR("DPCAMPOSADD","DPDIRAPL","DIR_LOCAL","L",01,0,"Adaptación Local")
  EJECUTAR("DPCAMPOSADD","DPDIRAPL","DIR_SIZE" ,"N",10,0,"Tamaño del Archivo")

  EJECUTAR("DPCAMPOSADD","DPFORMYTAREAS","FYT_NIVPRI","N"  ,2,0,"Nivel de Prioridad")
         
  EJECUTAR("DPCAMPOSOPCADD","DPREGSOPORTE","RSP_PRIORID","1. Inmediata"       ,.T.)
  EJECUTAR("DPCAMPOSOPCADD","DPREGSOPORTE","RSP_PRIORID","2. Alta (4 Horas)"  ,.T.)
  EJECUTAR("DPCAMPOSOPCADD","DPREGSOPORTE","RSP_PRIORID","3. Media (24 Horas)",.T.)
  EJECUTAR("DPCAMPOSOPCADD","DPREGSOPORTE","RSP_PRIORID","4. Baja (72 Horas)" ,.T.)

  EJECUTAR("DPCAMPOSOPCADD","DPEMPRESA","EMP_TIPFCH","Ultima Fecha Conocida",.T.)

  EJECUTAR("DPCAMPOSOPCADD","DPEMPRESA","EMP_EMGTIP","On Line con ePedidos" ,.T.)
  EJECUTAR("DPCAMPOSOPCADD","DPEMPRESA","EMP_EMGTIP","Sincronización con ePedidos" ,.T.)
  EJECUTAR("DPCAMPOSOPCADD","DPEMPRESA","EMP_EMGTIP","eManager Consultas" ,.T.)


  EJECUTAR("DPREGSOPORTESET") // Tipos de Soporte FIX

  EJECUTAR("DPCAMPOSADD","DPUSUARIOS"  ,"OPE_MAPBAR" ,"C",060 ,0,"Mapa por Barras",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPUSUARIOS"  ,"OPE_MINOFF" ,"N",03  ,0,"Minutos Registro",NIL,.T.,NIL)

  EJECUTAR("DPCAMPOSADD","DPBOTBAR"    ,"BOT_ACTIVO" ,"L",001 ,0,"Registro Activo",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPBOTBAR"    ,"BOT_FECHA"  ,"D",008 ,0,"Fecha",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPBOTBAR"    ,"BOT_HORA"   ,"C",008 ,0,"Hora",NIL,.T.,NIL)

  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_DPSTD" ,"M",10 ,0,"Lista de Archivos Actualizados DPSTD",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_FCHSTD","D",8  ,0,"Fecha de Descarga DPSTD",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_HORSTD","C",8  ,0,"Hora  de Descarga DPSTD",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_EDOACT","C",250,0,"Estado de la Actualización del Sistema",NIL,.T.,NIL)
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_EVLLAVE","M",10,0,"Llave de Evaluación"  ,"",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_MASTER","L",01 ,0,"Master Descargar AdaptaPro Server"    ,NIL,.T.,.T.,".F.")
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_ACTBD" ,"L",01 ,0,"Actualización de la BD"               ,NIL,.T.,.T.,".F.")

  // Tiene como objetivo, replicar todos los PC la llave dp\adaptapro.dp cuado la llave activa es producción
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_TIPLLA","C",05 ,0,"Tipo de Llave TEST,PROD,PREP")
  EJECUTAR("DPCAMPOSADD","DPPCLOG"  ,"PC_LLAVEP","M",10,0,"LLave de Producción")


  EJECUTAR("DPCAMPOSADD","DPBOTBAR"     ,"BOT_ACTIVO","L",01,0,"Activo"            ,NIL,.T.,.T.,".T.")
  EJECUTAR("DPCAMPOSADD","DPBRW"        ,"BRW_ALTER" ,"L",01,0,"Alterado"          ,NIL,.T.,.T.,".T.")
  EJECUTAR("DPCAMPOSADD","DPBRW"        ,"BRW_RGOFCH","L",01,0,"Rango Fecha Simple",NIL,.T.,.T.,".T.")
  EJECUTAR("DPCAMPOSADD","DPBRW"        ,"BRW_WNDWID","N",04,0,"Ancho Ventana"     ) //,NIL,.T.,.T.,".T.")

  EJECUTAR("SETFIELDLONG","DPBRW","BRW_TITLE",250)

  EJECUTAR("DPCAMPOSADD","DPLINK"       ,"LNK_LNKDEL","L",01,0,"Reparar Delete"   ,"",.T.,.F.,".F.")
  EJECUTAR("DPCAMPOSADD","DPLINK"       ,"LNK_LNKADD","L",01,0,"Reparar Agregando","",.T.,.F.,".F.")

//  EJECUTAR("DPCAMPOSADD","DPLINK","LNK_LNKDEL","L",01,0,"Reparar Delete"   ,"",.T.,.F.,".F.")
//  EJECUTAR("DPCAMPOSADD","DPLINK","LNK_LNKADD","L",01,0,"Reparar Agregando","",.T.,.F.,".F.")

  EJECUTAR("DPCAMPOSADD","DPFILEEMP"    ,"FIL_REFRES","L",01,0,"Refresca en Cada Reproducción","",.T.,.F.,".F.")
  EJECUTAR("DPCAMPOSADD","DPVISTAS"     ,"VIS_INDICA","L",01,0,"Crear para Indicadores","",.T.,.F.,".F.")
  EJECUTAR("DPCAMPOSADD","DPVISTAS"     ,"VIS_PRGPRE","C",20,0,"Programa DpXbase Pre Construcción ","",.T.,.F.,"")
  EJECUTAR("DPCAMPOSADD","DPVISTAS"     ,"VIS_VISTA" ,"C",030,0,"Nombre de la Vista")
  EJECUTAR("DPCAMPOSADD","DPVISTAS"     ,"VIS_AUTO"  ,"L",01,0,"Auto Generada",NIL,.T.,.F.,".F.")


  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_EMGTIP","C",01,0,"Tipo de Afiliación eManager","",NIL,NIL,["Ninguna"])
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_EM_ID" ,"C",80,0,"Id eManager",NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_EMDOM" ,"C",80,0,"Dominio"    ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_EMLOG" ,"C",80,0,"Login"      ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_EMPASS","C",80,0,"Clave"      ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_TABUPD","M",10,0,"Lista de Tablas por Actualizar"     ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_VISUPD","M",10,0,"Lista de Vistas por Actualizar"     ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_EM_AFI","N",04,0,"Id BD eManager"     ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_FCHPRM","D",08,0,"Fecha Planificada para la Reconversion Monetaria" ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_FCHERM","D",08,0,"Fecha Ejecución de la Reconversion Monetaria"     ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_REGUNI","N",08,0,"Cantidad Registros Unitarios"                     ,NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_CHKUNI","L",01,0,"Revisión de Registros con Valores Unitarios","",.T.,.F.,".F.")
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_FCHULT","D",8,0,"Ultima Fecha")
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_TIPFCH","C",1,0,"Tipo de Fecha")
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_MYSQLV","C",10,0,"Versión MySql")
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_CODSER","C",06,0,"Código de Servidor")
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_IDUP"  ,"C",30,0,"Id de Subida")
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_IDDOWN","C",30,0,"Id de Descarga")
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_RIFLIC","C",15,0,"Rif;Licencia",NIL)
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_FCHDWN","D",08,0,"Ultima;Descarga",NIL)


  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_FCHCHK","D",08,0,"Fecha de Revisión de Base de Datos"               ,"",.T.,"","&oDp:dFchChkFch")
  EJECUTAR("DPCAMPOSADD","DPEMPRESA","EMP_BDVER" ,"C",10,0,"Versión de la BD"                                 ,"",.T.,"","&oDp:cBdVersion") // V51:R1806
        
  // Algunos Proceso son Pesados y seran Gestionados por Tiempo
  EJECUTAR("DPCAMPOSADD","DPPROCESOS","PFP_ERPMSG","C",250,0,"Mensaje Panel ERP"    ,NIL)
  EJECUTAR("DPCAMPOSADD","DPPROCESOS","PRC_INICIA","L",001,0,"Proceso Iniciado"     ,"",.T.,.F.,".F.")
  EJECUTAR("DPCAMPOSADD","DPPROCESOS","PRC_FIN"   ,"L",001,0,"Proceso Concluido"    ,"",.T.,.F.,".F.")
  EJECUTAR("DPCAMPOSADD","DPPROCESOS","PRC_SAVE"  ,"L",001,0,"Guardar Traza"        ,"",.T.,.F.,".F.")
  EJECUTAR("DPCAMPOSADD","DPPROCESOS","PRC_ACTIVO","L",001,0,"Activo"               ,"",.T.,.F.,".F.")
  EJECUTAR("DPCAMPOSADD","DPPROCESOS","PRC_FCHRUN","D",008,0,"Fecha Ejecución"      ,"",.T.,CTOD(""),[CTOD("")])
  EJECUTAR("DPCAMPOSADD","DPPROCESOS","PRC_SPEAK" ,"L",001,0,"SPEAK Activo"         ,"",.T.,.F.,".F.")

  EJECUTAR("DPCAMPOSOPCADD","DPPROCESOS","PRC_CLASIF","Técnico",.F.) // Procesos de Aspectos Técnicos 

  EJECUTAR("DPCAMPOSADD","DPPROCESOSMEMO","PFP_MEMO" ,"M",010,0,"Mensaje Error"         ,"")
  EJECUTAR("DPCAMPOSADD","DPPROCESOSMEMO","PFP_ALTER","L",01 ,0,"Personalizado"         ,"")


  EJECUTAR("DPCAMPOSADD"   ,"DPTRIGGERS","TRG_WHEN","C",1,0,"Cuando se Ejecuta"    ,"",.T.,"B",["B"])
  EJECUTAR("DPCAMPOSOPCADD","DPTRIGGERS","TRG_WHEN","Before",.T.)
  EJECUTAR("DPCAMPOSOPCADD","DPTRIGGERS","TRG_WHEN","After",.T.)

  EJECUTAR("SETFIELDLONG","DPTRIGGERS"     ,"TRG_NOMBRE" ,120)

  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_EMANAG","L",01,0,"Emanager"  ,"",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_USUARI","L",01,0,"Usuario"   ,"",NIL,.T.)
  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_GERENC","L",01,0,"Gerencia"  ,"",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_VENDED","L",01,0,"Vendedor"  ,"",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_CLIENT","L",01,0,"Cliente"   ,"",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_TRABAJ","L",01,0,"Trabajador","",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_MEMRUN","M",10,0,"Memo Run"  ,"",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_EMANAG","L",01,0,"Emanager"  ,"",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_TMDI"  ,"L",01,0,"Formulario TMDI"  ,"",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_MULTIS","L",01,0,"Multi Select"  ,"",NIL,.F.)
  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_SORT"  ,"L",01,0,"Ordenado"      ,"",NIL,.F.)

  IF COUNT("DPBRW","WHERE BRW_WIDTH IS NULL")>0
     SQLUPDATE("DPBRW","BRW_TITLE" ,"","BRW_TITLE  IS NULL")
     SQLUPDATE("DPBRW","BRW_SUMCOL","","BRW_SUMCOL IS NULL")
     SQLUPDATE("DPBRW","BRW_WIDTH" ,"","BRW_WIDTH  IS NULL")
  ENDIF

  EJECUTAR("SETFIELDLONG","DPPROGRA"     ,"PRG_CODIGO" ,20)

  EJECUTAR("DPCAMPOSADD","DPPROGRA"    ,"PRG_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
  EJECUTAR("DPCAMPOSADD","DPTABLAS"    ,"TAB_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
  EJECUTAR("DPCAMPOSADD","DPMENU"      ,"MNU_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
  EJECUTAR("DPCAMPOSADD","DPBRW"       ,"BRW_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
  EJECUTAR("DPCAMPOSADD","DPVISTAS"    ,"VIS_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
  EJECUTAR("DPCAMPOSADD","DPBOTBAR"    ,"BOT_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
  EJECUTAR("DPCAMPOSADD","DPCAMPOS"    ,"CAM_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
  EJECUTAR("DPCAMPOSADD","DPPROCESOS"  ,"PRC_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
  EJECUTAR("DPCAMPOSADD","DPBOTBAR"    ,"BOT_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
  EJECUTAR("DPCAMPOSADD","DPTRIGGERS"  ,"TRG_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])

  EJECUTAR("DPCAMPOSADD","DPNOTIFICARELEASE","NRE_ACTIVO" ,"L",01,0,"Registro Activo",NIL,.T.,.T.,".T.") // Por defecto se Genera 
  EJECUTAR("DPCAMPOSADD","DPFORMYTAREASPROG","PFT_OPEN"  ,"L",01,0,"Formalidad Declaración Abierta",NIL,.T.,.T.,".T.") // Por defecto se Genera 
//EJECUTAR("DPCAMPOSADD","DPFORMYTAREASPROG","PFT_OPENR" ,"L",01,0,"Formalidad Registro Abierta",NIL,.T.,.T.,".T.") // Por defecto se Genera 
  EJECUTAR("DPCAMPOSADD","DPBRW"            ,"BRW_EMANAG","L",01,0,"Emanager",NIL,NIL,.F.)

  // 15/03/2016
  EJECUTAR("SETFIELDLONG","DPCAMPOS"  ,"CAM_COMMAN" ,80)
  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_VISTA" ,"L",01,0,"Vista")
  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_REXSUC","L",01,0,"Restricción por Sucursal")
  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_REXUSU","L",01,0,"Restricción por Usuario")
  EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_CAMDES","C",20,0,"Campo Descripción")
         
  EJECUTAR("DPCAMPOSADD","DPTABLAS","TAB_VISTA","L",1)

  EJECUTAR("DPCAMPOSADD","DPPROCESOSMEMO","PFP_MSGERR","M",10,0,"Mensaje de Incidencia")


  EJECUTAR("DPCAMPOSADD","DPADDON","ADD_ESHOP"  ,"L",01,0,"Adquisición desde eAdaptaPro"      ,"",NIL,.F.)

  EJECUTAR("DPAADONCREA",.T.) // Crea los campos

  EJECUTAR("DPBOTBARNEW") // Migrado desde DPINI
  EJECUTAR("DPMENUNEW")   // Migrado desde DPINI

  EJECUTAR("DPCREASTRUCT")

  EJECUTAR("DPCONFIGCHK") // Revisa Estrctura e Integridad Referencial BD DPCONFIG

  SQLDELETE("DPTABLAS","TAB_NOMBRE"+GetWhere("=","DPDOCPLATILLA"))

  IF COUNT("DPEMPRESA")=0
     EJECUTAR("DPEMPRESACREA",STRZERO(0,4))
  ENDIF

  EJECUTAR("DPLINKFIX") // Busca incidencias de integridad referencial

  EJECUTAR("DPEMPUSUARIODEPURA") // Depurar Permisos por Empresas

  EJECUTAR("DPTRIGGERSDEL",NIL,"DPEMPUSUARIO") 

  SQLUPDATE("DPEMPRESA","EMP_CODIGO","DEMO","EMP_CODIGO"+GetWhere("=","")) // Codigo Vacio Empresa de Pruebas

  // Remover Campos Inncesarios
  SQLDELETE("DPCAMPOS","CAM_TABLE"+GetWhere("=","DPDOCPROCTA")+" AND CAM_NAME"+GetWhere("CCD_CODMON"))
  SQLDELETE("DPCAMPOS","CAM_TABLE"+GetWhere("=","DPDOCCLICTA")+" AND CAM_NAME"+GetWhere("CCD_CODMON"))
       
/*
  oMenu:=Ope
  IF COUNT("DPMENU",cWhere)>0
    SQLUPDATE("DPMENU",{"MNU_MODULO","MNU_HORIZO","MNU_CODIGO"},{"08","68","08T68"},cWhere)
  ENDIF
*/


  IF COUNT("DPMENU","MNU_CODIGO"+GetWhere("=","03T96"))=0

    cWhere:="MNU_TITULO"+GetWhere("=","Registro Diario Resumen de Ventas")+" AND MNU_CODIGO"+GetWhere("=","03T96")

    oMenu:=OpenTable("SELECT * FROM DPMENU WHERE "+cWhere,.T.)

    IF oMenu:RecCount()>0 .AND. .F.
      oMenu:Replace("MNU_MODULO","08")
      oMenu:Replace("MNU_HORIZO","68")
      oMenu:Replace("MNU_CODIGO","08T68")
      oMenu:Commit(oMenu:cWhere)
    ENDIF

    oMenu:End()

  ENDIF

  // Vistas, vacias genera inicidencias
  SQLDELETE("DPVISTAS","VIS_DEFINE"+GetWhere("=",""))

  // Importar Vistas
  EJECUTAR("DPVISTASIMPORT") 

  EJECUTAR("DSNINDEX",oDp:cDsnConfig)

  IF COUNT("DPTABLAS","TAB_CHKSUM=0 OR TAB_CHKSUM IS NULL")>0 
     MsgRun("Actualizando ChkSum en DPTABLAS","Por favor espere..",{||EJECUTAR("DPTABLASSETCHKSUM")})
  ENDIF


  EJECUTAR("DPLINKADD","DPTABLAS","DPCAMPOS"  ,"TAB_NOMBRE","CAM_TABLE",.T.,.T.,.T.)
  EJECUTAR("DPLINKADD","DPTABLAS","DPCAMPOSOP","TAB_NOMBRE","OPC_TABLE"  ,.T.,.T.,.T.)

  EJECUTAR("DPDICCDATOS_UPDATE")

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)
	
  EJECUTAR("DPLNKDEL_HIS")
  // Guarda en DATACNF
  oData:=DATACNF("CNFADDFIELD","ALL")
  oData:Set("CNFADDFIELD",cid)
  oData:Save()
  oData:End()

  DPWRITE(cFileChk,cFileChk)

  DpMsgClose()

RETURN NIL
// EOF
