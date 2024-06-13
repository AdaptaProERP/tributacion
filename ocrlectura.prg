// Programa   : OCRLECTURA
// Fecha/Hora : 18/12/2023 10:06:47
// Propósito  : Ejecuta la Lectura de la Imagen
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cFileOrg,cFileOut,lRun,lView)
  LOCAL cUrl    :="https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-5.3.3.20231005.exe"
  LOCAL cFileTo :=oDp:cBin+"bin\"+SUBS(cUrl,RAT("/",cUrl)+1,LEN(cUrl))
  LOCAL cMemoBat:=MemoRead("CMDEXE.BAT")
  LOCAL cRunBat :="tesseract_run.bat"

  DEFAULT oDp:cBinOcr:="C:\Program Files\Tesseract-OCR\tesseract.exe",;
          cFileOrg   :=oDp:cBin+"ejemplo\CEPP.png"  ,;
          cFileOut   :=oDp:cBin+"temp\"+cFileName(cFileNoExt(cFileOrg)),;
          lView      :=.T.

  FERASE(cFileOut)

// cFileOrg   :=oDp:cBin+"pdf\MAYOR_AN3.pdf"
// ? cFileOrg,cFileOut

  IF !FILE(oDp:cBinOcr) 

     MsgMemo("No fué econtrado "+oDp:cBinOcr+CRLF+"Será descargado desde "+CRLF+cUrl+CRLF+"hacia en "+cFileTo,"Requiere Programa tesseract.exe",700,15	0)
     URLDownLoad(cUrl, cFileTo)

     IF FILE(cFileTo)

       MsgMemo("Será ejecutado el programa de instalación "+CRLF+cFileTo)

       IF !Empty(cMemoBat)

         cMemoBat:=STRTRAN(cMemoBat,"CMD.EXE",cFileTo)
         DpWrite(cRunBat,cMemoBat)

         CursorWait()
         WaitRun(cRunBat,0)
         SysRefresh(.T.)   

       ELSE

         WinExec(cFileTo)

       ENDIF
     
     ENDIF

  ENDIF

  cMemoBat:=[CALL "]+oDp:cBinOcr+["]+" "+cFileOrg+" "+cFileOut
  cRunBat :="tesseract_run.bat"

  
  FERASE(cFileOut)
  FERASE(cRunBat)
  DpWrite(cRunBat,cMemoBat)
  CursorWait()
  WaitRun(cRunBat,0)
  SysRefresh(.T.)   

  cFileOut:=cFileOut+".txt"

  IF FILE(cFileOut) .AND. lView
   VIEWRTF(cFileOut)
  ENDIF

RETURN .T.
// EOF
