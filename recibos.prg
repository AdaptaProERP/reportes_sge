// Reporte Creado Automáticamente por Datapro 
// Fecha      : 09/12/2004 Hora: 17:15:46
// Aplicación : 01
// Tabla      : NMRECIBOS           

//***     ******             ******      REPORTE MODIFICADO * * * * *           ******       ****  
// COPIAR ESTA INSTRUCCIÓN      EJECUTAR("NMRECIBO",oGenRep,cSql) ANTES DE CREAR NUEVAMENTE
// BAJO LA LINEA DE CODIGO NUMERO 37


#include "dpxBase.CH"
#include "DpxReport.ch"

PROCE MAIN(oGenRep)
     LOCAL cSql,oCursor,cMsg:="",oFont1,oFont2,oDb

     PRIVATE oReport,nLineas:=0

     IF oGenRep=NIL
       RETURN .F.
     ENDIF

     CursorWait()
/*
     // Aqui puede Personalizar la Consulta <QUERY>
     oGenRep:cSqlSelect    :="SELECT XCAMPO FROM NMRECIBOS"          // Nuevo Select
     oGenRep:cSqlInnerJoin:=" INNER JOIN TABLAB ON CAMPOA=CAMPOB " // Nuevo Inner Join
     oGenRep:cSqlOrderBy  :="ORDER BY XCAMPO"                      // Nuevo Order By
*/
     oGenRep:cWhere  :=oGenRep:BuildWhere()          // Where Según RANGO/CRITERIO
     cSql   :=oGenRep:BuildSql() // Genera Código SQL

     IF !ChkSql(cSql,@cMsg)      // Revisa Posible Ejecución SQL
        MensajeErr(cMsg,"Reporte <REPORTE>")
        Return .F.
     ENDIF

     IF !EJECUTAR("NMRECIBO",oGenRep,cSql)
        MensajeErr("No fué posible Encontrar Información","Consulta Vacia Reporte <REPORTE>")
        RETURN .F.
     ENDIF

     // 05/07/2024
     IF oDp:nVersion<=5.0 

        SELECTADDFIELD(oGenRep,",REC_MTOASG,REC_MTODED,REC_NETO ")

     ELSE

        oDb:=OpenOdbc(oDp:cDsnData)

        IF !EJECUTAR("ISFIELDMYSQL",oDb,"VIEW_NMRECIBOS","REC_CODTRA",.F.)
          EJECUTAR("VIEW_NMRECIBOS")
        ENDIF

        EJECUTAR("REPSELECTADDFIELD",oGenRep,",REC_MTOASG,REC_MTODED,REC_NETO ")

     ENDIF

     oGenRep:cSql:=STRTRAN(oGenRep:cSql,"NMRECIBOS","VIEW_NMRECIBOS")

     IF !oGenRep:OutPut(.T.) // Verifica el Dispositivo de Salida Inicial
         RETURN .F.
     ENDIF

     oCursor:=OpenTable(cSql,.T.)

     IF oCursor:RecCount()=0
        MensajeErr("No fué posible Encontrar Información","Consulta Vacia Reporte <REPORTE>")
        oCursor:End()
        Return .F.
     ENDIF

     oCursor:GoTop()

     DEFINE FONT oFont1 NAME "ARIAL" SIZE 0,-10
     DEFINE FONT oFont2 NAME "ARIAL" SIZE 0,-10 BOLD

     REPORT oReport TITLE  "Recibo de pago",;
            "Fecha: "+dtoc(Date())+" Hora: "+TIME();
            CAPTION "Recibo de pago" ;
            FOOTER "Página: "+str(oReport:nPage,3)+" Registros: "+alltrim(str(nLineas,5)) CENTER ;
            FONT oFont1,oFont2;
            PREVIEW

     oGenRep:SetDevice(oReport) // Asigna parámetros

     
     COLUMN TITLE "Código";
            DATA oCursor:HIS_CODCON;
            SIZE 4;
            LEFT 

     COLUMN TITLE "Concepto";
            DATA oCursor:CON_DESCRI;
            SIZE 40;
            LEFT 

     COLUMN TITLE "Medida";
            DATA oCursor:CON_REPRES;
            SIZE 6;
            LEFT 

     COLUMN TITLE "Variación";
            DATA oCursor:HIS_VARIAC;
            PICTURE "9,999,999,999.999";
            SIZE 12;
            RIGHT  

     COLUMN TITLE "Monto";
            DATA oCursor:HIS_MONTO;
            PICTURE "99,999,999,999.99";
            TOTAL ;
            FONT 2 ;
            SIZE 12;
            RIGHT  

     
      GROUP ON oCursor:REC_NUMERO;
            FONT 2;
            HEADER GROUP01();
            FOOTER ENDGRP01()

      GROUP ON oCursor:CODIGO;
            FONT 2;
            HEADER GROUP02();
            FOOTER ENDGRP02()

     END REPORT

     oReport:bSkip:={||oCursor:DbSkip()}

     ACTIVATE REPORT oReport ;
              WHILE !oCursor:Eof();
              ON STARTGROUP oReport:NewLine();
              ON STARTPAGE  RepBitmap();
              ON CHANGE ONCHANGE()

     oGenRep:OutPut(.F.) // Verifica el Dispositivo de Salida Final

     oFont1:End()
     oFont2:End()

RETURN NIL

/*
// En Cada Registro se puede Aplicar Fórmulas
// Es llamado por Skip()
*/
FUNCTION ONCHANGE()

   nLineas:=nLineas+1 // Es Posible Aplicar Fórmulas

/*
// Si Desea Imprimir lineas Adicionales que no esten vacias
  
*/
   
 // PrintMemo(CAMPOMEMO,1,.F.,1) // Imprimir Campo Memo


RETURN .T.

/*
// Imprime Campos Memos
*/
FUNCTION PrintMemo(cMemo,nCol,lData,nIni)
     LOCAL nFor,aLines

     IF Empty(cMemo)
        RETURN ""
     ENDIF

     // Inicio del Línea
     DEFAULT nIni:=1

     cMemo :=STRTRAN(cMemo,CHR(10),"") // Convierte el Campo Memo en Arreglos
     aLines:=_VECTOR(cMemo,CHR(13))

     IF lData // Requiera la Primera Línea de Datos
        Return aLines[1]
     ENDIF

//   oReport:BackLine(1) // Retroceder una Línea
//   oReport:Newline()   // Adelanta una Línea
     FOR nFor := nIni TO LEN(aLines)
         oReport:StartLine()
         oReport:Say(nCol,aLines[nFor])
         oReport:EndLine()
     NEXT
     oReport:Newline()

RETURN ""

/*
// Inicio en Cada Página
*/
STATIC FUNCTION RepBitMap()

  DEFAULT oDp:cLogoBmp:="BITMAPS\LOGO.BMP"

  oReport:SayBitmap(.3,.3, oDp:cLogoBmp,.5,.5)

RETURN NIL
/*
oRun : objeto de Ejecución
*/

/*
 Encabezado Grupo : Recibo Nro.
*/
FUNCTION GROUP01()
   LOCAL cExp:="",uValue:=""
   cExp  :="Recibo Nro.: "
   uValue:=oCursor:REC_NUMERO
   uValue:=cValtoChar(uValue)+" "+cValToChar(oCursor:CODIGO)
RETURN cExp+uValue

/*
 Finalizar Grupo : Recibo Nro.
*/
FUNCTION ENDGRP01()
   LOCAL cExp:="",uValue:="",cLines:=""
   cExp  :="Total Recibo Nro.:  "
   uValue:=oReport:aGroups[1]:cValue
   uValue:=uValue
   uValue:=cValtoChar(uValue)
   cLines:=ltrim(str(oReport:aGroups[1]:nCounter))
   cLines:=" ("+cLines+")"
RETURN cExp+uValue+cLines

/*
 Encabezado Grupo : Trabajador
*/
FUNCTION GROUP02()
   LOCAL cExp:="",uValue:=""
   cExp  :="Trabajador: "
   uValue:=oCursor:CODIGO
   uValue:=cValtoChar(uValue)+" "+cValToChar(oCursor:APELLIDO+oCursor:NOMBRE)
RETURN cExp+uValue

/*
 Finalizar Grupo : Trabajador
*/
FUNCTION ENDGRP02()
   LOCAL cExp:="",uValue:="",cLines:=""
   cExp  :="Total Trabajador:  "
   uValue:=oReport:aGroups[2]:cValue
   uValue:=uValue
   uValue:=cValtoChar(uValue)
   cLines:=ltrim(str(oReport:aGroups[2]:nCounter))
   cLines:=" ("+cLines+")"
RETURN cExp+uValue+cLines

/*
// JN 06/05/2024
// Agregar campos en el Select
*/

FUNCTION SELECTADDFIELD(oGenRep,cField)
   LOCAL nAt,cSelect


   IF oGenRep=NIL

     DEFAULT cSelect:="SELECT REC_NUMERO FROM NMRECIBOS",;
             cField :="REC_MTOASG"

   ELSE

     cSelect:=oGenRep:cSqlSelect   

   ENDIF

   nAt    :=AT(" FROM ",cSelect)

   cField :=IF(LEFT(cField,1)=",","",",")+cField

   IF nAt>0
     cSelect:=LEFT(cSelect,nAt)+cField+SUBS(cSelect,nAt,LEN(cSelect))
   ENDIF

   IF !oGenRep=NIL

      oGenRep:cSqlSelect:=cSelect
      oGenRep:BuildSql()

   ENDIF

RETURN cSelect
// EOF



// EOF 
