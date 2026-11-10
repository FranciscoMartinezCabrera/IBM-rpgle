         ctl-opt copyright('Banco Exterior')
                 option(*srcstmt: *nodebugio: *nounref) nomain
                 datfmt(*iso) aut(*all) debug(*yes) alwnull(*usrctl);
       //----------------------------------------------------------------------/
       //   Banco Exterior
       //   Fecha de Creacion: 10/2026
       //   Modulo - Srvpgm de Validacion de Fechas
       //   Objetivo programa: Procedimientos exportables de validacion de fecha
       //                      de todo tipo: dia, mes, ano, formatos numericos,
       //                      caracter, rangos y reglas de negocio bancario.
       //
       //   Autor: E65295 - Francisco Martinez
       //----------------------------------------------------------------------/
       // BITACORA DE ACTUALIZACIONES
       //----------------------------------------------------------------------/
       // FECHA    | AUTOR  |       D E S C R I P C I O N
       //----------------------------------------------------------------------/
       // 29/10/26 | E65295 | Creacion inicial de procedimientos de fechas
       //----------------------------------------------------------------------/

         /include qddssrc,utcopfech1

       //=======================================================================
       // SECCION 1: VALIDACIONES DE COMPONENTES INDIVIDUALES (ANO, MES, DIA)
       //=======================================================================

       //-----------------------------------------------------------------------
       // Modulo  : EsAnoBisiesto
       // Objetivo: Determina si un ano es bisiesto segun calendario gregoriano
       //           *on  = Es bisiesto
       //           *off = No es bisiesto o ano invalido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc EsAnoBisiesto export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PAno        zoned(4:0);
        end-pi;

           if PAno > 0;
              if (%rem(PAno: 4) = 0 and %rem(PAno: 100) <> 0) or
                 (%rem(PAno: 400) = 0);
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaAno
       // Objetivo: Valida que el ano se encuentre en rango bancario estandar
       //           (1900 a 2099)
       //           *on  = Ano valido
       //           *off = Ano fuera de rango
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaAno export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PAno        zoned(4:0);
        end-pi;

           if PAno >= 1900 and PAno <= 2099;
              VResultados = *On;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaAnoRango
       // Objetivo: Valida que el ano este dentro de un rango especifico
       //           *on  = Ano valido dentro del rango
       //           *off = Ano fuera de rango
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaAnoRango export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PAno        zoned(4:0);
           PAnoMin     zoned(4:0);
           PAnoMax     zoned(4:0);
        end-pi;

           if PAnoMin <= PAnoMax and PAno >= PAnoMin and PAno <= PAnoMax;
              VResultados = *On;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaMes
       // Objetivo: Valida que el mes este comprendido entre 1 y 12
       //           *on  = Mes valido (1..12)
       //           *off = Mes invalido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaMes export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PMes        zoned(2:0);
        end-pi;

           if PMes >= 1 and PMes <= 12;
              VResultados = *On;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaDia
       // Objetivo: Valida que el dia este en rango generico (1 a 31)
       //           *on  = Dia valido
       //           *off = Dia invalido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaDia export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PDia        zoned(2:0);
        end-pi;

           if PDia >= 1 and PDia <= 31;
              VResultados = *On;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : DiasDelMes
       // Objetivo: Retorna los dias maximos que posee un mes para un ano dado
       //           considerando anos bisiestos (28, 29, 30 o 31)
       //           *on  = Mes y ano validos, dias calculados
       //           *off = Mes o ano invalidos
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc DiasDelMes export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PMes        zoned(2:0);
           PAno        zoned(4:0);
           PMaxDias    zoned(2:0);
        end-pi;

           PMaxDias = *zeros;

           if ValidaMes(PMes) and PAno > 0;
              Select;
                 When PMes = 1 or PMes = 3 or PMes = 5 or PMes = 7 or
                      PMes = 8 or PMes = 10 or PMes = 12;
                      PMaxDias = 31;
                      VResultados = *On;
                 When PMes = 4 or PMes = 6 or PMes = 9 or PMes = 11;
                      PMaxDias = 30;
                      VResultados = *On;
                 When PMes = 2;
                      if EsAnoBisiesto(PAno);
                         PMaxDias = 29;
                      else;
                         PMaxDias = 28;
                      endif;
                      VResultados = *On;
              Endsl;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaDiaEnMes
       // Objetivo: Valida si un dia es valido para el mes y ano especificos
       //           *on  = Dia valido para ese mes y ano
       //           *off = Dia invalido (ej: 29 feb en ano no bisiesto o 31 abri
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaDiaEnMes export;

        dcl-s VResultados ind inz(*off);
        dcl-s WMaxDias    zoned(2:0) inz(*zeros);

        dcl-pi *n ind;
           PDia        zoned(2:0);
           PMes        zoned(2:0);
           PAno        zoned(4:0);
        end-pi;

           if DiasDelMes(PMes: PAno: WMaxDias);
              if PDia >= 1 and PDia <= WMaxDias;
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //=======================================================================
       // SECCION 2: VALIDACIONES POR COMPONENTES SEPARADOS (DMA, AMD)
       //=======================================================================

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaDMA
       // Objetivo: Valida fecha recibiendo Dia, Mes y Ano de 4 digitos
       //           *on  = Fecha valida
       //           *off = Fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaDMA export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PDia        zoned(2:0);
           PMes        zoned(2:0);
           PAno        zoned(4:0);
        end-pi;

           if ValidaAno(PAno) and ValidaDiaEnMes(PDia: PMes: PAno);
              VResultados = *On;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaAMD
       // Objetivo: Valida fecha recibiendo Ano de 4 digitos, Mes y Dia
       //           *on  = Fecha valida
       //           *off = Fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaAMD export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PAno        zoned(4:0);
           PMes        zoned(2:0);
           PDia        zoned(2:0);
        end-pi;

           VResultados = ValidaFechaDMA(PDia: PMes: PAno);

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaDMA2
       // Objetivo: Valida fecha con ano de 2 digitos usando ventana de siglo
       //           (>= 40 -> 1940..1999; < 40 -> 2000..2039)
       //           *on  = Fecha valida
       //           *off = Fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaDMA2 export;

        dcl-s VResultados ind inz(*off);
        dcl-s WAno4       zoned(4:0);

        dcl-pi *n ind;
           PDia        zoned(2:0);
           PMes        zoned(2:0);
           PAno2       zoned(2:0);
        end-pi;

           if PAno2 >= 40;
              WAno4 = 1900 + PAno2;
           else;
              WAno4 = 2000 + PAno2;
           endif;

           VResultados = ValidaFechaDMA(PDia: PMes: WAno4);

           return VResultados;

        end-proc;

       //=======================================================================
       // SECCION 3: VALIDACIONES DE FECHAS NUMERICAS (FORMATOS IBM i / CORE)
       //=======================================================================

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaISO
       // Objetivo: Valida fecha numerica de 8 digitos en formato YYYYMMDD
       //           *on  = Fecha valida
       //           *off = Fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaISO export;

        dcl-s VResultados ind inz(*off);
        dcl-s WAno        zoned(4:0);
        dcl-s WMes        zoned(2:0);
        dcl-s WDia        zoned(2:0);

        dcl-pi *n ind;
           PFecha      zoned(8:0);
        end-pi;

           if PFecha >= 19000101 and PFecha <= 20991231;
              WAno = %div(PFecha: 10000);
              WMes = %div(%rem(PFecha: 10000): 100);
              WDia = %rem(PFecha: 100);

              VResultados = ValidaFechaAMD(WAno: WMes: WDia);
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaDMY
       // Objetivo: Valida fecha numerica de 8 digitos en formato DDMMYYYY
       //           *on  = Fecha valida
       //           *off = Fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaDMY export;

        dcl-s VResultados ind inz(*off);
        dcl-s WDia        zoned(2:0);
        dcl-s WMes        zoned(2:0);
        dcl-s WAno        zoned(4:0);

        dcl-pi *n ind;
           PFecha      zoned(8:0);
        end-pi;

           if PFecha > 0;
              WDia = %div(PFecha: 1000000);
              WMes = %div(%rem(PFecha: 1000000): 10000);
              WAno = %rem(PFecha: 10000);

              VResultados = ValidaFechaDMA(WDia: WMes: WAno);
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaMDY
       // Objetivo: Valida fecha numerica de 8 digitos en formato MMDDYYYY
       //           *on  = Fecha valida
       //           *off = Fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaMDY export;

        dcl-s VResultados ind inz(*off);
        dcl-s WMes        zoned(2:0);
        dcl-s WDia        zoned(2:0);
        dcl-s WAno        zoned(4:0);

        dcl-pi *n ind;
           PFecha      zoned(8:0);
        end-pi;

           if PFecha > 0;
              WMes = %div(PFecha: 1000000);
              WDia = %div(%rem(PFecha: 1000000): 10000);
              WAno = %rem(PFecha: 10000);

              VResultados = ValidaFechaDMA(WDia: WMes: WAno);
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFecha6DMY
       // Objetivo: Valida fecha numerica de 6 digitos en formato DDMMYY
       //           *on  = Fecha valida
       //           *off = Fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFecha6DMY export;

        dcl-s VResultados ind inz(*off);
        dcl-s WDia        zoned(2:0);
        dcl-s WMes        zoned(2:0);
        dcl-s WAno2       zoned(2:0);

        dcl-pi *n ind;
           PFecha      zoned(6:0);
        end-pi;

           if PFecha > 0;
              WDia  = %div(PFecha: 10000);
              WMes  = %div(%rem(PFecha: 10000): 100);
              WAno2 = %rem(PFecha: 100);

              VResultados = ValidaFechaDMA2(WDia: WMes: WAno2);
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFecha6YMD
       // Objetivo: Valida fecha numerica de 6 digitos en formato YYMMDD
       //           *on  = Fecha valida
       //           *off = Fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFecha6YMD export;

        dcl-s VResultados ind inz(*off);
        dcl-s WAno2       zoned(2:0);
        dcl-s WMes        zoned(2:0);
        dcl-s WDia        zoned(2:0);

        dcl-pi *n ind;
           PFecha      zoned(6:0);
        end-pi;

           if PFecha > 0;
              WAno2 = %div(PFecha: 10000);
              WMes  = %div(%rem(PFecha: 10000): 100);
              WDia  = %rem(PFecha: 100);

              VResultados = ValidaFechaDMA2(WDia: WMes: WAno2);
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaJuliana
       // Objetivo: Valida fecha numerica juliana de 7 digitos YYYYDDD
       //           *on  = Fecha juliana valida
       //           *off = Fecha juliana invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaJuliana export;

        dcl-s VResultados ind inz(*off);
        dcl-s WAno        zoned(4:0);
        dcl-s WDiaJul     zoned(3:0);
        dcl-s WMaxDias    zoned(3:0);

        dcl-pi *n ind;
           PFecha      zoned(7:0);
        end-pi;

           WAno    = %div(PFecha: 1000);
           WDiaJul = %rem(PFecha: 1000);

           if ValidaAno(WAno);
              if EsAnoBisiesto(WAno);
                 WMaxDias = 366;
              else;
                 WMaxDias = 365;
              endif;

              if WDiaJul >= 1 and WDiaJul <= WMaxDias;
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //=======================================================================
       // SECCION 4: VALIDACIONES DE FECHAS EN CADENA / CARACTER
       //=======================================================================

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaCharISO
       // Objetivo: Valida fecha en texto 'YYYY-MM-DD', 'YYYY/MM/DD' o 'YYYYMMDD
       //           *on  = Cadena representa una fecha ISO valida
       //           *off = Cadena invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaCharISO export;

        dcl-s VResultados ind inz(*off);
        dcl-s WStr        char(10);
        dcl-s WLen        int(5);
        dcl-s WDia        zoned(2:0);
        dcl-s WMes        zoned(2:0);
        dcl-s WAno        zoned(4:0);

        dcl-pi *n ind;
           PFechaStr   char(10);
        end-pi;

           WStr = %trim(PFechaStr);
           WLen = %len(%trim(WStr));

           Select;
              // Formato YYYY-MM-DD o YYYY/MM/DD (10 caracteres)
              When WLen = 10 and
                   (%check('0123456789': %subst(WStr: 1: 4)) = 0) and
                   (%check('0123456789': %subst(WStr: 6: 2)) = 0) and
                   (%check('0123456789': %subst(WStr: 9: 2)) = 0);
                   WAno = %dec(%subst(WStr: 1: 4): 4: 0);
                   WMes = %dec(%subst(WStr: 6: 2): 2: 0);
                   WDia = %dec(%subst(WStr: 9: 2): 2: 0);
                   VResultados = ValidaFechaAMD(WAno: WMes: WDia);

              // Formato YYYYMMDD (8 digitos continuos)
              When WLen = 8 and (%check('0123456789': WStr) = 0);
                   WAno = %dec(%subst(WStr: 1: 4): 4: 0);
                   WMes = %dec(%subst(WStr: 5: 2): 2: 0);
                   WDia = %dec(%subst(WStr: 7: 2): 2: 0);
                   VResultados = ValidaFechaAMD(WAno: WMes: WDia);

              Other;
                   VResultados = *Off;
           Endsl;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaCharDMY
       // Objetivo: Valida fecha en texto 'DD/MM/YYYY', 'DD-MM-YYYY' o 'DDMMYYYY
       //           *on  = Cadena representa una fecha DMY valida
       //           *off = Cadena invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaCharDMY export;

        dcl-s VResultados ind inz(*off);
        dcl-s WStr        char(10);
        dcl-s WLen        int(5);
        dcl-s WDia        zoned(2:0);
        dcl-s WMes        zoned(2:0);
        dcl-s WAno        zoned(4:0);

        dcl-pi *n ind;
           PFechaStr   char(10);
        end-pi;

           WStr = %trim(PFechaStr);
           WLen = %len(%trim(WStr));

           Select;
              // Formato DD/MM/YYYY o DD-MM-YYYY (10 caracteres)
              When WLen = 10 and
                   (%check('0123456789': %subst(WStr: 1: 2)) = 0) and
                   (%check('0123456789': %subst(WStr: 4: 2)) = 0) and
                   (%check('0123456789': %subst(WStr: 7: 4)) = 0);
                   WDia = %dec(%subst(WStr: 1: 2): 2: 0);
                   WMes = %dec(%subst(WStr: 4: 2): 2: 0);
                   WAno = %dec(%subst(WStr: 7: 4): 4: 0);
                   VResultados = ValidaFechaDMA(WDia: WMes: WAno);

              // Formato DDMMYYYY (8 digitos continuos)
              When WLen = 8 and (%check('0123456789': WStr) = 0);
                   WDia = %dec(%subst(WStr: 1: 2): 2: 0);
                   WMes = %dec(%subst(WStr: 3: 2): 2: 0);
                   WAno = %dec(%subst(WStr: 5: 4): 4: 0);
                   VResultados = ValidaFechaDMA(WDia: WMes: WAno);

              Other;
                   VResultados = *Off;
           Endsl;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaCharFormato
       // Objetivo: Valida fecha en texto segun formato RPG (*ISO,*EUR,*USA,*DMY
       //           *on  = Formato y fecha validos
       //           *off = Formato o fecha invalidos
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaCharFormato export;

        dcl-s VResultados ind inz(*off);
        dcl-s WFechaD     date;
        dcl-s WFmt        char(10);

        dcl-pi *n ind;
           PFechaStr   char(10);
           PFormato    char(10);
        end-pi;

           WFmt = %trim(%upper(PFormato));
           if %subst(WFmt: 1: 1) <> '*';
              WFmt = '*' + WFmt;
           endif;

           Monitor;
              Select;
                 When WFmt = '*ISO';
                    WFechaD = %date(%trim(PFechaStr): *ISO);
                 When WFmt = '*USA';
                    WFechaD = %date(%trim(PFechaStr): *USA);
                 When WFmt = '*EUR';
                    WFechaD = %date(%trim(PFechaStr): *EUR);
                 When WFmt = '*JIS';
                    WFechaD = %date(%trim(PFechaStr): *JIS);
                 When WFmt = '*DMY';
                    WFechaD = %date(%trim(PFechaStr): *DMY);
                 When WFmt = '*MDY';
                    WFechaD = %date(%trim(PFechaStr): *MDY);
                 When WFmt = '*YMD';
                    WFechaD = %date(%trim(PFechaStr): *YMD);
                 When WFmt = '*JUL';
                    WFechaD = %date(%trim(PFechaStr): *JUL);
                 Other;
                    WFechaD = %date(%trim(PFechaStr): *ISO);
              Endsl;
              VResultados = *On;
           On-error;
              VResultados = *Off;
           Endmon;

           return VResultados;

        end-proc;

       //=======================================================================
       // SECCION 5: VALIDACIONES DE NEGOCIO BANCARIO Y RANGOS
       //=======================================================================

       //-----------------------------------------------------------------------
       // Modulo  : ValidaRangoFechas
       // Objetivo: Valida que dos fechas ISO (YYYYMMDD) sean validas y que
       //           FechaDesde sea menor o igual a FechaHasta
       //           *on  = Rango valido
       //           *off = Rango invalido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaRangoFechas export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PFechaDesde zoned(8:0);
           PFechaHasta zoned(8:0);
        end-pi;

           if ValidaFechaISO(PFechaDesde) and ValidaFechaISO(PFechaHasta);
              if PFechaDesde <= PFechaHasta;
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaNoFutura
       // Objetivo: Valida que una fecha ISO (YYYYMMDD) sea valida y menor o
       //           igual a la fecha del sistema (hoy).
       //           *on  = Fecha valida e historica o de hoy
       //           *off = Fecha futura o invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaNoFutura export;

        dcl-s VResultados ind inz(*off);
        dcl-s WHoy        zoned(8:0);

        dcl-pi *n ind;
           PFecha      zoned(8:0);
        end-pi;

           if ValidaFechaISO(PFecha);
              WHoy = (%subdt(%date(): *years) * 10000) +
                     (%subdt(%date(): *months) * 100) +
                     %subdt(%date(): *days);
              if PFecha <= WHoy;
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaFutura
       // Objetivo: Valida que una fecha ISO (YYYYMMDD) sea valida y estrictamen
       //           mayor a la fecha del sistema (hoy).
       //           *on  = Fecha valida y futura
       //           *off = Fecha pasada, hoy o invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaFutura export;

        dcl-s VResultados ind inz(*off);
        dcl-s WHoy        zoned(8:0);

        dcl-pi *n ind;
           PFecha      zoned(8:0);
        end-pi;

           if ValidaFechaISO(PFecha);
              WHoy = (%subdt(%date(): *years) * 10000) +
                     (%subdt(%date(): *months) * 100) +
                     %subdt(%date(): *days);
              if PFecha > WHoy;
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaMayorIgualHoy
       // Objetivo: Valida que una fecha ISO (YYYYMMDD) sea valida y mayor o
       //           igual a la fecha de hoy.
       //           *on  = Fecha valida y >= hoy
       //           *off = Fecha pasada o invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaMayorIgualHoy export;

        dcl-s VResultados ind inz(*off);
        dcl-s WHoy        zoned(8:0);

        dcl-pi *n ind;
           PFecha      zoned(8:0);
        end-pi;

           if ValidaFechaISO(PFecha);
              WHoy = (%subdt(%date(): *years) * 10000) +
                     (%subdt(%date(): *months) * 100) +
                     %subdt(%date(): *days);
              if PFecha >= WHoy;
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : EsFinDeSemana
       // Objetivo: Determina si una fecha ISO (YYYYMMDD) corresponde a Sabado
       //           o Domingo.
       //           *on  = Es Sabado o Domingo
       //           *off = Es dia de semana (Lunes a Viernes) o fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc EsFinDeSemana export;

        dcl-s VResultados ind inz(*off);
        dcl-s WNroDia     zoned(1:0);
        dcl-s WNomDia     char(10);

        dcl-pi *n ind;
           PFecha      zoned(8:0);
        end-pi;

           if ObtenerDiaSemana(PFecha: WNroDia: WNomDia);
              if WNroDia = 1 or WNroDia = 7;
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : EsDiaHabil
       // Objetivo: Determina si una fecha ISO (YYYYMMDD) corresponde a dia
       //           laboral bancario estandar (Lunes a Viernes).
       //           *on  = Es dia laborable (Lunes a Viernes)
       //           *off = Es fin de semana o fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc EsDiaHabil export;

        dcl-s VResultados ind inz(*off);
        dcl-s WNroDia     zoned(1:0);
        dcl-s WNomDia     char(10);

        dcl-pi *n ind;
           PFecha      zoned(8:0);
        end-pi;

           if ObtenerDiaSemana(PFecha: WNroDia: WNomDia);
              if WNroDia >= 2 and WNroDia <= 6;
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaEdadMinima
       // Objetivo: Valida que a partir de una fecha de nacimiento (YYYYMMDD)
       //           la persona tenga al menos N anos de edad cumplidos.
       //           *on  = Cumple la edad minima requerida
       //           *off = Menor de la edad requerida o fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaEdadMinima export;

        dcl-s VResultados ind inz(*off);
        dcl-s WFechaNacD  date;
        dcl-s WHoyD       date;
        dcl-s WEdad       int(5);

        dcl-pi *n ind;
           PFechaNac   zoned(8:0);
           PEdadMin    zoned(3:0);
        end-pi;

           if ValidaFechaNoFutura(PFechaNac) and PEdadMin >= 0;
              WFechaNacD = %date(PFechaNac: *ISO);
              WHoyD = %date();
              WEdad = %diff(WHoyD: WFechaNacD: *years);
              if WEdad >= PEdadMin;
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ValidaFechaVencimiento
       // Objetivo: Valida si una fecha de vencimiento (YYYYMMDD) es valida y
       //           mayor o igual a una fecha base (si base=0, usa fecha actual)
       //           *on  = Vencimiento vigente (>= fecha base)
       //           *off = Vencido o fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ValidaFechaVencimiento export;

        dcl-s VResultados ind inz(*off);
        dcl-s WFechaBase  zoned(8:0);

        dcl-pi *n ind;
           PFechaVenc  zoned(8:0);
           PFechaBase  zoned(8:0);
        end-pi;

           if ValidaFechaISO(PFechaVenc);
              if PFechaBase = *zeros;
                 WFechaBase = (%subdt(%date(): *years) * 10000) +
                              (%subdt(%date(): *months) * 100) +
                              %subdt(%date(): *days);
              else;
                 WFechaBase = PFechaBase;
              endif;

              if ValidaFechaISO(WFechaBase);
                 if PFechaVenc >= WFechaBase;
                    VResultados = *On;
                 endif;
              endif;
           endif;

           return VResultados;

        end-proc;

       //=======================================================================
       // SECCION 6: CONVERSIONES, DESGLOSES Y UTILIDADES DE FECHAS
       //=======================================================================

       //-----------------------------------------------------------------------
       // Modulo  : ConvertirFechaDMYaISO
       // Objetivo: Convierte fecha DDMMYYYY a formato ISO YYYYMMDD validandola
       //           *on  = Conversion exitosa
       //           *off = Fecha DMY invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ConvertirFechaDMYaISO export;

        dcl-s VResultados ind inz(*off);
        dcl-s WDia        zoned(2:0);
        dcl-s WMes        zoned(2:0);
        dcl-s WAno        zoned(4:0);

        dcl-pi *n ind;
           PFechaDMY   zoned(8:0);
           PFechaISO   zoned(8:0);
        end-pi;

           PFechaISO = *zeros;

           if ValidaFechaDMY(PFechaDMY);
              WDia = %div(PFechaDMY: 1000000);
              WMes = %div(%rem(PFechaDMY: 1000000): 10000);
              WAno = %rem(PFechaDMY: 10000);

              PFechaISO = (WAno * 10000) + (WMes * 100) + WDia;
              VResultados = *On;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ConvertirFechaISOaDMY
       // Objetivo: Convierte fecha ISO YYYYMMDD a formato DDMMYYYY validandola
       //           *on  = Conversion exitosa
       //           *off = Fecha ISO invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ConvertirFechaISOaDMY export;

        dcl-s VResultados ind inz(*off);
        dcl-s WAno        zoned(4:0);
        dcl-s WMes        zoned(2:0);
        dcl-s WDia        zoned(2:0);

        dcl-pi *n ind;
           PFechaISO   zoned(8:0);
           PFechaDMY   zoned(8:0);
        end-pi;

           PFechaDMY = *zeros;

           if ValidaFechaISO(PFechaISO);
              WAno = %div(PFechaISO: 10000);
              WMes = %div(%rem(PFechaISO: 10000): 100);
              WDia = %rem(PFechaISO: 100);

              PFechaDMY = (WDia * 1000000) + (WMes * 10000) + WAno;
              VResultados = *On;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : DesglosarFechaISO
       // Objetivo: Separa fecha ISO (YYYYMMDD) en componentes Ano, Mes y Dia
       //           *on  = Fecha valida y desglosada
       //           *off = Fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc DesglosarFechaISO export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PFechaISO   zoned(8:0);
           PAno        zoned(4:0);
           PMes        zoned(2:0);
           PDia        zoned(2:0);
        end-pi;

           PAno = *zeros;
           PMes = *zeros;
           PDia = *zeros;

           if ValidaFechaISO(PFechaISO);
              PAno = %div(PFechaISO: 10000);
              PMes = %div(%rem(PFechaISO: 10000): 100);
              PDia = %rem(PFechaISO: 100);
              VResultados = *On;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ArmarFechaISO
       // Objetivo: Construye una fecha numerica YYYYMMDD a partir de Ano, Mes
       //           y Dia comprobando su validez.
       //           *on  = Componentes validos y fecha armada
       //           *off = Componentes invalidos
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ArmarFechaISO export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PAno        zoned(4:0);
           PMes        zoned(2:0);
           PDia        zoned(2:0);
           PFechaISO   zoned(8:0);
        end-pi;

           PFechaISO = *zeros;

           if ValidaFechaAMD(PAno: PMes: PDia);
              PFechaISO = (PAno * 10000) + (PMes * 100) + PDia;
              VResultados = *On;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : CalcularDiasDiferencia
       // Objetivo: Calcula los dias transcurridos entre dos fechas ISO
       //           (PFecha2 - PFecha1)
       //           *on  = Calculo exitoso
       //           *off = Alguna fecha es invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc CalcularDiasDiferencia export;

        dcl-s VResultados ind inz(*off);
        dcl-s WFecha1D    date;
        dcl-s WFecha2D    date;

        dcl-pi *n ind;
           PFecha1     zoned(8:0);
           PFecha2     zoned(8:0);
           PDias       packed(9:0);
        end-pi;

           PDias = *zeros;

           if ValidaFechaISO(PFecha1) and ValidaFechaISO(PFecha2);
              WFecha1D = %date(PFecha1: *ISO);
              WFecha2D = %date(PFecha2: *ISO);
              PDias = %diff(WFecha2D: WFecha1D: *days);
              VResultados = *On;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ObtenerDiaSemana
       // Objetivo: Retorna el numero de dia (1=Domingo..7=Sabado) y su nombre
       //           *on  = Fecha valida y dia obtenido
       //           *off = Fecha invalida
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ObtenerDiaSemana export;

        dcl-s VResultados ind inz(*off);
        dcl-s WFechaD     date;
        dcl-s WDiaSem     int(5) inz(0);

        dcl-pi *n ind;
           PFecha      zoned(8:0);
           PNroDia     zoned(1:0);
           PNomDia     char(10);
        end-pi;

           PNroDia = 0;
           PNomDia = *blanks;

           if ValidaFechaISO(PFecha);
              WFechaD = %date(PFecha: *ISO);
              Exec SQL
                 Set :WDiaSem = DAYOFWEEK(:WFechaD);

              if SQLCODE = 0 and WDiaSem >= 1 and WDiaSem <= 7;
                 PNroDia = WDiaSem;
                 Select;
                    When WDiaSem = 1;
                       PNomDia = 'DOMINGO';
                    When WDiaSem = 2;
                       PNomDia = 'LUNES';
                    When WDiaSem = 3;
                       PNomDia = 'MARTES';
                    When WDiaSem = 4;
                       PNomDia = 'MIERCOLES';
                    When WDiaSem = 5;
                       PNomDia = 'JUEVES';
                    When WDiaSem = 6;
                       PNomDia = 'VIERNES';
                    When WDiaSem = 7;
                       PNomDia = 'SABADO';
                 Endsl;
                 VResultados = *On;
              endif;
           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ObtenerNombreMes
       // Objetivo: Retorna el nombre en espanol correspondiente al mes (1..12)
       //           *on  = Mes valido y nombre retornado
       //           *off = Mes invalido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ObtenerNombreMes export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           PMes        zoned(2:0);
           PNomMes     char(12);
        end-pi;

           PNomMes = *blanks;

           if ValidaMes(PMes);
              Select;
                 When PMes = 1;
                      PNomMes = 'ENERO';
                 When PMes = 2;
                      PNomMes = 'FEBRERO';
                 When PMes = 3;
                      PNomMes = 'MARZO';
                 When PMes = 4;
                      PNomMes = 'ABRIL';
                 When PMes = 5;
                      PNomMes = 'MAYO';
                 When PMes = 6;
                      PNomMes = 'JUNIO';
                 When PMes = 7;
                      PNomMes = 'JULIO';
                 When PMes = 8;
                      PNomMes = 'AGOSTO';
                 When PMes = 9;
                      PNomMes = 'SEPTIEMBRE';
                 When PMes = 10;
                      PNomMes = 'OCTUBRE';
                 When PMes = 11;
                      PNomMes = 'NOVIEMBRE';
                 When PMes = 12;
                      PNomMes = 'DICIEMBRE';
              Endsl;

              VResultados = *On;

           endif;

           return VResultados;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : ObtenerFechaActualISO
       // Objetivo: Retorna la fecha actual del sistema en formato numerico
       //           (YYYYMMDD) y caracter ('YYYY-MM-DD')
       //           *on  = Retorna exitosamente
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2026
       //-----------------------------------------------------------------------
        Dcl-Proc ObtenerFechaActualISO export;

        dcl-s VResultados ind inz(*on);

        dcl-pi *n ind;
           PFechaNum   zoned(8:0);
           PFechaChar  char(10);
        end-pi;

           PFechaNum = (%subdt(%date(): *years) * 10000) +
                       (%subdt(%date(): *months) * 100) +
                       %subdt(%date(): *days);
           PFechaChar = %char(%date(): *ISO);

           return VResultados;

        end-proc;


