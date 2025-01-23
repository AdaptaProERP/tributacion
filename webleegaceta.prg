// Programa   : WEBLEEGACETA
// Fecha/Hora : 07/01/2025 07:54:41
// Propósito  : leer las gacetas
// Creado Por : Juan navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dDesde,cWhere,cUrl)
  LOCAL cFecha:="",cMemo:="",cMemoG:="",cLine:="",cText:=[],cTipo,cRef:="",cGaceta:="",cRefView:="",cRefDown:=""
  LOCAL dFecha
  LOCAL nAt,I
  LOCAL aData:={}
  LOCAL oTable,oHttp,lUrl:=.F. 


// LOCAL aUrl :={}
// DEFAULT dDesde:=SQLGETMAX("DPGACETA","GAC_FECHA")
// DEFAULT lTodos:=.F. 

  IF Empty(cUrl)

    IF Empty(dFecha)
       cUrl:="http://spgoin.imprentanacional.gob.ve/cgi-win/be_alex.cgi?ultimo&Nombrebd=spgoin&tipodoc=GCTOF&Tsalida=T:GeneralGCTOF&Sesion=1724506025"
       cUrl:=GETULTIMAFCH(cUrl)
    ELSE
       cFecha:=STRTRAN(DTOC(dDesde),"/","-")
       cUrl:="http://spgoin.imprentanacional.gob.ve/cgi-win/be_alex.cgi?Forma=General&Nombrebd=spgoin&tipodoc=GCTOF&c09=FechaIso&t09=<="+cFecha+"&orden=FiD&Tsalida=T:GeneralGCTOF&sesion=1147470327"
    ENDIF
    
  ELSE

    lUrl:=.T. 
 
  ENDIF

  oHttp:=CreateObject("winhttp.winhttprequest.5.1")
  oHttp:Open("GET",cUrl,.T.) 
  oHttp:SetTimeouts(0, 60000, 30000, 120000)
  oHttp:Send()
  oHttp:WaitForResponse(90)

  cMemo:= oHttp:ResponseText()

  cText:=[<a class="DocTitulo"]
  nAt  :=AT(cText,cMemo)
  cMemo:=SUBS(cMemo,nAt-LEN(cText),LEN(cMemo))
  cMemo:=STRTRAN(cMemo,[<a href=],[**])
  cMemo:=STRTRAN(cMemo,CRLF,"")

  aData:=_VECTOR(cMemo,[href="/cgi])
  ARREDUCE(aData,1)
  ARREDUCE(aData,LEN(aData))

  FOR I=1 TO LEN(aData)

     cLine   :=SUBS(aData[I],7,LEN(aData[I]))
     nAt     :=AT(["],cLine)
     cRef    :="http://spgoin.imprentanacional.gob.ve/"+LEFT(cLine,nAt-1)
     cGaceta :=SUBS(cLine,nAt+2,6)
     cGaceta :=STRTRAN(cGaceta,"<","")
     nAt     :=AT([tor">],cLine)
     cTipo   :=SUBS(cLine,nAt+5,LEN(cLine))
     cTipo   :=LEFT(cTipo,AT("<",cTipo)-1)
     nAt     :=AT([</td><td>Pub],cLine)
     dFecha  :=STRTRAN(SUBS(cLine,nAt-10,10),"-","/")
     aData[I]:={cGaceta,cTipo,dFecha,cRef,.F.}

   NEXT I

   FOR I=1 TO LEN(aData)
     aData[I,5]:=ISSQLFIND("DPGACETA","GAC_NUMERO"+GetWhere("=",aData[I,1]))
   NEXT I

// ViewArray(aData)

   ADEPURA(aData,{|a,n| a[5]})

  LMKDIR("GACETAS")

  IF LEN(aData)>0

    oTable:=OpenTable("SELECT * FROM DPGACETA",.F.)

    IF !lUrl

     DpMsgRun("Procesando","Lectura de Gacetas",NIL,LEN(aData))
     DpMsgSetTotal(LEN(aData))

    ENDIF

    FOR I=1 TO LEN(aData)

      IF !lUrl
        DpMsgSet(I,.T.,NIL,"Gaceta "+aData[I,1]+" "+aData[I,3])
      ENDIF

      cUrl:=aData[I,4]
      oHttp:=CreateObject("winhttp.winhttprequest.5.1")
      oHttp:Open("GET",cUrl,.T.) 
      oHttp:SetTimeouts(0, 60000, 30000, 120000)
      oHttp:Send()
      oHttp:WaitForResponse(90)
      cMemo:= oHttp:ResponseText()

      DPWRITE("GACETAS\GO"+aData[I,1]+".HTML",cMemo)

      cMemoG  :=GACMEMO(cMemo)
      cMemoG  :=IIF(Empty(cMemoG),cMemo,cMemoG)
      cRefView:=GETREFVIEW(cMemo)
      cRefDown:=GETURLDOWN(cRefView,aData[I,1])

      oTable:Append()
      oTable:lAuditar:=.F.
      oTable:Replace("GAC_NUMERO",aData[I,1])
      oTable:Replace("GAC_TIPO"  ,aData[I,2])
      oTable:Replace("GAC_FECHA" ,aData[I,3])
      oTable:Replace("GAC_URLVER",cRefView  )
      oTable:Replace("GAC_URL"   ,aData[I,4])
      oTable:Replace("GAC_TEXTO" ,cMemoG    )
      oTable:Replace("GAC_URLGET",cRefDown  )
      oTable:Commit("")

   NEXT I

   oTable:End()

   IF !lUrl
     DpMsgClose()
   ENDIF

   SysRefresh(.T.)

  ENDIF

  IF !Empty(cWhere) .AND. COUNT("DPGACETA",cWhere)>0
     DPLBX("DPGACETA.LBX",NIL,cWhere)
  ENDIF

RETURN .T.

FUNCTION GACMEMO(cMemo)
  LOCAL cFecha:="",cUrl:="",cLine:="",cText:=[],cTipo,cRef:="",cGaceta:=""
  LOCAL dFecha
  LOCAL nAt,I
  LOCAL aData:={}

  cText:=[<a class="DocTitulo"]
  nAt  :=AT(cText,cMemo)
  cMemo:=SUBS(cMemo,nAt-LEN(cText),LEN(cMemo))
  cMemo:=STRTRAN(cMemo,[<a href=],[**])
  cMemo:=STRTRAN(cMemo,CRLF,"")

  aData:=_VECTOR(cMemo,[href="/cgi])
  ARREDUCE(aData,1)
  ARREDUCE(aData,LEN(aData))

  cMemo:=""

  FOR I=1 TO LEN(aData)

     cLine   :=SUBS(aData[I],7,LEN(aData[I]))
     nAt     :=AT(["],cLine)
     cRef    :="http://spgoin.imprentanacional.gob.ve/"+LEFT(cLine,nAt-1)
     cGaceta :=SUBS(cLine,nAt+2,6)
     cGaceta :=STRTRAN(cGaceta,"<","")
     nAt     :=AT([tor">],cLine)
     cTipo   :=SUBS(cLine,nAt+5,LEN(cLine))
     cTipo   :=LEFT(cTipo,AT("<",cTipo)-1)
     nAt     :=AT([</td><td>Pub],cLine)
     dFecha  :=STRTRAN(SUBS(cLine,nAt-10,10),"-","/")

     nAt     :=AT([">],cTipo)
     cTipo   :=SUBS(cTipo,nAt+2,LEN(cTipo))
     cMemo   :=cMemo+IF(Empty(cMemo),""," ")+cTipo

     aData[I]:={cGaceta,cTipo,dFecha,cRef,.F.}

  NEXT I

  cMemo:=IF(Empty(cMemo),"Indefinido",cMemo)

RETURN cMemo

/*
// URL visual
*/
FUNCTION GETREFVIEW(cMemo)
  LOCAL nAt,cText:=[Kb)</a>],cRef
 
  nAt  :=AT(cText,cMemo)
  cMemo:=LEFT(cMemo,nAt)

  nAt  :=RAT("href",cMemo)
  cMemo:=SUBS(cMemo,nAt+6,LEN(cMemo))
  nAt  :=AT(["],cMemo)
  cMemo:=LEFT(cMemo,nAt-1)

  cRef :="http://spgoin.imprentanacional.gob.ve"+cMemo

RETURN cRef

/*
// URL descarga
*/
FUNCTION GETURLDOWN(cUrl,cGaceta)
   LOCAL cRef,cMemo
   LOCAL nAt,cRef
   LOCAL cText:=[DescargarArchivoCompleto.gif]
   LOCAL oHttp:=CreateObject("winhttp.winhttprequest.5.1")

   oHttp:Open("GET",cUrl,.T.) 
   oHttp:SetTimeouts(0, 60000, 30000, 120000)
   oHttp:Send()
   oHttp:WaitForResponse(90)
   cMemo:= oHttp:ResponseText()

   DPWRITE("GACETAS\GO"+cGaceta+"_download.HTML",cMemo)

   nAt  :=AT(cText,cMemo)
   cMemo:=LEFT(cMemo,nAt)

   nAt  :=RAT("href",cMemo)
   cMemo:=SUBS(cMemo,nAt+6,LEN(cMemo))
   nAt  :=AT(["],cMemo)
   cMemo:=LEFT(cMemo,nAt-1)

   cRef :="http://spgoin.imprentanacional.gob.ve"+cMemo

RETURN cRef

/*
// Obtener la Ultima Fecha
*/
FUNCTION GETULTIMAFCH(cUrl)
   LOCAL cRef,cMemo
   LOCAL nAt,cRef
   LOCAL cText:=[ltimas Gacetas]
   LOCAL oHttp:=CreateObject("winhttp.winhttprequest.5.1")

   oHttp:Open("GET",cUrl,.T.) 
   oHttp:SetTimeouts(0, 60000, 30000, 120000)
   oHttp:Send()
   oHttp:WaitForResponse(90)
   cMemo:= oHttp:ResponseText()

   DPWRITE("GACETAS\GO_ULTIMA_FECHA_download.HTML",cMemo)

   nAt  :=AT(cText,cMemo)
   cMemo:=LEFT(cMemo,nAt)

   nAt  :=RAT("href",cMemo)
   cMemo:=SUBS(cMemo,nAt+6,LEN(cMemo))
   nAt  :=AT(["],cMemo)
   cMemo:=LEFT(cMemo,nAt-1)

   cRef :="http://spgoin.imprentanacional.gob.ve"+cMemo

RETURN cRef

/*
http://spgoin.imprentanacional.gob.ve/cgi-win/be_alex.cgi?ultimo&Nombrebd=spgoin&tipodoc=GCTOF&Tsalida=T:GeneralGCTOF&RegIni=181&PagIni=1&Sesion=1526798423
*/
// EOF
