// Programa   : WEBLEEGACETATODAS
// Fecha/Hora : 07/01/2025 07:54:41
// Propósito  : leer todas las gacetas
// Creado Por : Juan navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cUrl,aPag:={},I,nPag

//  cUrl:="http://spgoin.imprentanacional.gob.ve/cgi-win/be_alex.cgi?ultimo&Nombrebd=spgoin&tipodoc=GCTOF&Tsalida=T:GeneralGCTOF&RegIni=1361&PagIni=1&Sesion=1017819223"
//  EJECUTAR("WEBLEEGACETA",NIL,NIL,cUrl)

  AADD(aPag,{  1,1})
  AADD(aPag,{ 21,1})
  AADD(aPag,{ 41,1})
  AADD(aPag,{ 61,1})
  AADD(aPag,{ 81,1})
  AADD(aPag,{101,1})
  AADD(aPag,{121,1})
  AADD(aPag,{141,1})
  AADD(aPag,{161,1})
  AADD(aPag,{181,1})
  AADD(aPag,{201,11})
  AADD(aPag,{3541,178}) // total 178 

  nPag:=201+20
  FOR I=1 TO 150
    AADD(aPag,{nPag,1})
    nPag:=nPag+20
  NEXT I

  DpMsgRun("Procesando","Lectura de Gacetas",NIL,LEN(aPag))
  DpMsgSetTotal(LEN(aPag))


  FOR I=1 TO LEN(aPag)

    DpMsgSet(I,.T.,NIL,"Paginado "+LSTR(aPag[I,1]))

    cUrl:='http://spgoin.imprentanacional.gob.ve/cgi-win/be_alex.cgi?ultimo&Nombrebd=spgoin&tipodoc=GCTOF&Tsalida=T:GeneralGCTOF'+;
          '&RegIni='+LSTR(aPag[I,1])+'&PagIni='+LSTR(aPag[I,2])+'&Sesion=1526798423'

    EJECUTAR("WEBLEEGACETA",NIL,NIL,cUrl)

  NEXT I

  DpMsgClose()

RETURN .T.
/*
<br /><b><span id="GrpPagAnteriores"></span>( <a id="Pag1" class="PagIAntSig" href="javascript:GotoRegPag(1,1);">1</a>
)<span id="GrpPagPosteriores"><a id="Pag2" class="PagIAntSig" href="javascript:GotoRegPag(21,1);">2</a>
<a id="Pag3" class="PagIAntSig" href="javascript:GotoRegPag(41,1);">3</a>
<a id="Pag4" class="PagIAntSig" href="javascript:GotoRegPag(61,1);">4</a>
<a id="Pag5" class="PagIAntSig" href="javascript:GotoRegPag(81,1);">5</a>
<a id="Pag6" class="PagIAntSig" href="javascript:GotoRegPag(101,1);">6</a>
<a id="Pag7" class="PagIAntSig" href="javascript:GotoRegPag(121,1);">7</a>
<a id="Pag8" class="PagIAntSig" href="javascript:GotoRegPag(141,1);">8</a>
<a id="Pag9" class="PagIAntSig" href="javascript:GotoRegPag(161,1);">9</a>
<a id="Pag10" class="PagIAntSig" href="javascript:GotoRegPag(181,1);">10</a>
<a id="PagSiguiente" class="PagAntSig" href="javascript:GotoRegPag(21,1);">--&gt;</a>
<a id="PaginaUltima0" class="PaginaUltima" href="javascript:GotoRegPag(201,11);">...</a>
<a id="PaginaUltima1" class="PaginaUltima" href="javascript:GotoRegPag(3541,178);">178</a>
function GotoRegPag(iRegIni,iPagIni,id){
 var u='/cgi-win/be_alex.cgi?ultimo&Nombrebd=spgoin&tipodoc=GCTOF&Tsalida=T:GeneralGCTOF';
 if(id){
  if(ud[id])u=ud[id];
 }
 window.location=u+'&RegIni='+iRegIni+'&PagIni='+iPagIni+'&Sesion=1526798423';
}
*/

/*
<input type="hidden" name="Forma" id="FContinua-Forma" value="Ultimo" />
<input type="hidden" name="Nombrebd" id="FContinua-Nombrebd" value="spgoin" />
<br /><b><span id="GrpPagAnteriores"><a id="PagPrimera0" class="PagPrimera" href="javascript_inactivo:GotoRegPag(1,1);">1</a>
<a id="PagPrimera1" class="PagPrimera" href="javascript_inactivo:GotoRegPag(2661,128);">...</a>
<a id="PagAnterior" class="PagAntSig" href="javascript_inactivo:GotoRegPag(2841,138);">&lt;--</a>
<a id="Pag1" class="PagIAntSig" href="javascript_inactivo:GotoRegPag(2741,138);">138</a>
<a id="Pag2" class="PagIAntSig" href="javascript_inactivo:GotoRegPag(2761,138);">139</a>
<a id="Pag3" class="PagIAntSig" href="javascript_inactivo:GotoRegPag(2781,138);">140</a>
<a id="Pag4" class="PagIAntSig" href="javascript_inactivo:GotoRegPag(2801,138);">141</a>
<a id="Pag5" class="PagIAntSig" href="javascript_inactivo:GotoRegPag(2821,138);">142</a>
<a id="Pag6" class="PagIAntSig" href="javascript_inactivo:GotoRegPag(2841,138);">143</a>
</span>( <a id="Pag7" class="PagIAntSig" href="javascript_inactivo:GotoRegPag(2861,138);">144</a>
)<span id="GrpPagPosteriores"><a id="Pag8" class="PagIAntSig" href="javascript_inactivo:GotoRegPag(2881,138);">145</a>
<a id="Pag9" class="PagIAntSig" href="javascript_inactivo:GotoRegPag(2901,138);">146</a>
<a id="Pag10" class="PagIAntSig" href="javascript_inactivo:GotoRegPag(2921,138);">147</a>
<a id="PagSiguiente" class="PagAntSig" href="javascript_inactivo:GotoRegPag(2881,138);">--&gt;</a>
<a id="PaginaUltima0" class="PaginaUltima" href="javascript_inactivo:GotoRegPag(3061,148);">...</a>
<a id="PaginaUltima1" class="PaginaUltima" href="javascript_inactivo:GotoRegPag(3541,178);">178</a>


<script type="text/javascript_inactivo" language="javascript_inactivo">
<!--
var i0=-1;i1=-1;
function AxExtraeSubCadena(s,s0,s1){
 i0=-1;i1=-1;
 ret='';
 if(s0){
  i0=s.indexOf(s0);
  if(i0>=0){
   sub=s.substr(i0+s0.length);
   if(s1){
    i1=sub.indexOf(s1);
    if(i1>0){
     ret=sub.substr(0,i1);
     i1+=s0.length+s1.length;
    }
   }
  }
 }
 return ret;
}

ULTIMA PAGINA <a id="PaginaUltima1" class="PaginaUltima" href="javascript:GotoRegPag(3541,178);">178</a>
Se han ubicado <b>3555</b> registros en <b>Gacetas Oficiales </b> bajo las condiciones especificadas. <br /></div>

var AxResult={
nombrebd:'spgoin',
dir_iconos:'/alexandr/iconos/spgoin',
sesion:'1914134681',
anonimo:1,
acceso_perfil:'',
consulta:'ultimo&Nombrebd=spgoin&tipodoc=GCTOF&Tsalida=T:GeneralGCTOF&Sesion=1724506025',
consulta_dsi_doc:'',
acceso:'',
ext_acceso:'',
tipo_doc:'',
tipo_ref:'',
regini:1,
regini_pi:1,
recuperar_doc:20,
recuperar_pi:50,
pagini:1,
total_doc:3555,
total_pi:0,
total_doc_dsi:0,
regini_cons:0,
total_cons:0,
idioma:0,
tsalida:'T:GeneralGCTOF',
orden:'TA',
persistencia:'&Sesion=1914134681'
};

http://spgoin.imprentanacional.gob.ve/cgi-win/be_alex.cgi?ultimo&Nombrebd=spgoin&tipodoc=GCTOF&Tsalida=T:GeneralGCTOF&RegIni=2861&PagIni=138&Sesion=184673705
*/
