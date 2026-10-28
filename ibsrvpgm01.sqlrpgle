         ctl-opt copyright('Banco Exterior') ;
         ctl-Opt option(*srcstmt: *nodebugio: *nounref);
         ctl-opt nomain;
         ctl-opt datfmt(*iso) aut(*all) debug(*yes) alwnull(*usrctl);
       //----------------------------------------------------------------------/
       //   Banco Exterior
       //   Fecha de Creacion: 06/2023
       //   Modulo - Srvpgm de Almacenamiento
       //   Objetivo programa: Procedimientos usados en Almacenamiento
       //
       //
       //   Autor: Francisco Martinez
       //----------------------------------------------------------------------/
       // BITACORA DE ACTUALIZACIONES
       //----------------------------------------------------------------------/
       // FECHA    | AUTOR  |       D E S C R I P C I O N
       //----------------------------------------------------------------------/
       //          |        |
       //----------------------------------------------------------------------/

         /include qddssrc,ibcopy001
         /include qddssrc,ibdata001

       //-----------------------------------------------------------------------
       // Modulo  : LeeCntrlcnt
       // Objetivo: Lee registro de control Cntrlcnt
       //           *on  = Retorna exitosamente
       //           *off = error
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc LeeCntrlcnt export;

        Dcl-DS CntrlcntDs qualified ;
           Wcntrtc        zoned(3);
           Wcntbcu        Char(3);
           Wcntint        Char(2);
           Wcntrdd        zoned(2);
           Wcntrdm        zoned(2);
           Wcntrdy        zoned(2);
           Wcntnme        Char(35);
        End-DS;

        dcl-s VResultado ind inz(*off);

        dcl-pi *n ind;
           Pkey   char(2);
           pReturnDS likeds(CntrlcntDs);
        end-pi;

           clear pReturnDS;

           Exec SQL
              select cntrtc, cntbcu, cntint, cntrdd, cntrdm, cntrdy, cntnme
                     into :pReturnDS from cntrlcnt
                     where cntkey = :Pkey

              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultado = *On;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : ExisteCuenta
       // Objetivo: Busca cuenta y devuelve Saldo y Status
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc ExisteCuenta export;

        Dcl-PI *n ind;
           Pcuenta    zoned(12:0);
           Pmonto     packed(15:2);
           Pstatus    char(1);
        End-PI;

        dcl-s VResultado ind inz(*off);

           Exec SQL
              Select acmmnb * (-1), acmast into :Pmonto, :Pstatus
                     From Acmst    Where acmacc = :Pcuenta
              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultado = *On;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : statusCuenta
       // Objetivo: Busca cuenta y devuelve Status
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc statusCuenta export;

        Dcl-PI *n ind;
           Pcuenta     zoned(12:0);
           Pstatus     char(1);
        End-PI;

        dcl-s OperacionExitosa ind inz(*off);

           Exec SQL
              Select acmast into :Pstatus
                     From Acmst    Where acmacc = :Pcuenta
              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultado = *On;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : FieldsCuenta
       // Objetivo: Busca cuenta y devuelve Campos del AcmsT
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc FieldsCuenta export;

        Dcl-DS AcmstDs qualified ;
           Wacmacc        zoned(12:0);
           Wacmbnk        Char(2);
           Wacmccy        Char(3);
           Wacmaty        Char(4);
           Wacmbrn        Packed(3:0);
           Wacmgln        Packed(16:0);
           Wacmcun        Packed(9:0);
           Wacmmnb        Packed(15:2);
           Wacmast        Char(1);
           Wacmccn        Packed(8:0);
           Wacmacd        Char(2);
           Wacmwhf        Char(1);
           Wacmpro        Char(4);
           Wacmmgb        Packed(15:2);
           Wacmgav        Packed(15:2);
           Wacmnav        Packed(15:2);
           Wacmlsb        Packed(15:2);
        End-DS;

        dcl-s VResultado ind inz(*off);

        dcl-pi *n ind;
           Pcuenta     zoned(12:0);
           pReturnDS   likeds(AcmstDs);
        end-pi;

           clear pReturnDS;

           Exec SQL
              Select acmacc, acmbnk, acmccy, acmaty, acmbrn, acmgln, acmcun,
                     acmmnb * (-1), acmast, acmccn, acmacd, acmwhf, acmpro,
                     acmmgb, acmgav, acmnav, acmlsb into :pReturnDS
                     From Acmst Where acmacc = :Pcuenta

              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultado = *On;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : FieldsCliente
       // Objetivo: Busca Cliente por Id y devuelve Campos del Cumst
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc FieldsCliente export;

        Dcl-DS CumstDs qualified ;
           Wcuscun        Packed(9:0);
           Wcusidn        Char(15);
           Wcuslgt        Char(1);
           Wcusna1        Char(45);
           Wcusph1        Packed(11:0);
           Wcusiad        Char(40);
        End-DS;

        dcl-s VResultado ind inz(*off);
        dcl-s Wident     char(15) inz;

        dcl-pi *n  ind;
           Pcedula   char(10);
           pReturnDS likeds(CumstDs);
        end-pi;

           Wident = Pcedula ;
           clear pReturnDS ;

           Exec SQL
              Select cuscun, cusidn, cuslgt, cusna1, cusph1, cusiad
                     into :pReturnDS
                     From Cumst Where cusidn = :Wident

              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultado = *On;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : FieldsClienteCodigo
       // Objetivo: Busca Cliente por Codigo y devuelve Campos del Cumst
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc FieldsClienteCodigo export;

        Dcl-DS CumstDs qualified ;
           Wcuscun        Packed(9:0);
           Wcusidn        Char(15);
           Wcuslgt        Char(1);
           Wcusna1        Char(45);
           Wcusph1        Packed(11:0);
           Wcusiad        Char(40);
        End-DS;

        dcl-s VResultado ind inz(*off);

        dcl-pi *n  ind;
           Pcuscun        Packed(9:0);
           pReturnDS likeds(CumstDs);
        end-pi;

           clear pReturnDS;

           Exec SQL
              Select cuscun, cusidn, cuslgt, cusna1, cusph1, cusiad
                     into :pReturnDS
                     From Cumst    Where cuscun = :Pcuscun
              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultado = *On;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : DescripcionStatusCuenta
       // Objetivo: Retorna la Descripcion del status de la cuenta
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc DescripcionStatusCuenta export;

        dcl-s VResultado ind inz(*off);

        Dcl-PI *n ind;
           Wacmast    char(1);
           p2         char(20);
        End-PI;

          Select;
            when Wacmast = 'A';
                 p2 = 'ACTIVA';
            when Wacmast = 'C';
                 p2 = 'CANCELADA';
            when Wacmast = 'D';
                 p2 = 'DURMIENTE';
            when Wacmast = 'E';
                 p2 = 'EMBARGADA';
            when Wacmast = 'I';
                 p2 = 'SIN MOVIMIENTO';
            when Wacmast = 'O';
                 p2 = 'CONTROLADA';
            when Wacmast = 'T';
                 p2 = 'ACEPTA SOLO DEPOSITO';
            when Wacmast = 'P';
                 p2 = 'PRE APERTURADA';
            other;
                 p2 = 'INDEFINIDO ' + Wacmast ;
          endsl;

           VResultado = *On;

           return VResultado ;
        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : CnofComision
       // Objetivo: Busca codigo de comision en el Cnofc y la calcula
       //           *on  = Retorna exitosamente
       //           *off = transacci?n no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc CnofComision export;

        Dcl-DS CnofComiDs qualified ;
           Wcnocfl    Char(2);
           Wcnorcd    Char(4);
           Wcnodsc    Char(35);
           Wcnodcc    Char(2);
           Wcnoacd    Char(2);
           Wcnopaf    Char(1);
           Wcnocpc    Char(4);
           Wcnomxc    zoned(13:2);
           Wcnoscg    zoned(16);
        End-DS;

        dcl-s VResultado ind inz(*off);
        dcl-c Fijo const('F') ;

        dcl-pi *n ind;
           Ptipo     char(2);
           Pcodigo   char(4);
           pmonto    zoned(11:2);
           pcomision zoned(7:2);
           pReturnDS likeds(CnofComiDs) ;
        end-pi;

           clear pReturnDS ;

           Exec SQL
              Select cnocfl, cnorcd, cnodsc, cnodcc, cnoacd, cnopaf, cnomxc,
                     cnocpc, cnoscg  into :pReturnDS
                     From CNOFC Where cnocfl = :Ptipo and cnorcd = :Pcodigo

              Fetch First 1 Row Only;

           If SQLCODE= 0;
              if pReturnDS.Wcnopaf = Fijo ;
                 Pcomision = pReturnDS.WCnomxc ;
              else;
                 Pcomision = (Pmonto * pReturnDS.WCnomxc) / 100 ;
              endif;
              VResultado = *On;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : MsgError
       // Objetivo: Devuelve mensaje de error del MSSGS
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc MsgError export;

        Dcl-PI *n ind;
           Perror      zoned(4:0);
           Pmensaje    char(74);
        End-PI;

        dcl-s OperacionExitosa ind inz(*off);

           Exec SQL
              Select msstxt into :Pmensaje
                     From MSSGSL1 Where mssnum = :Perror and msslan = 'S'

           Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultado = *On;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : TasaBcv
       // Objetivo: Busca valor de la tasa segun la moneda en Ratex
       //           *on  = Retorna exitosamente
       //           *off = Fallido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc TasaBcv export;

        Dcl-DS TasaBcvDs qualified ;
           Wraxbnk        Char(2);
           Wraxccy        Char(3);
           Wraxexr        zoned(19:8);
           Wraxper        zoned(19:8);
           Wraxcya        Char(15);
           Wraxdsc        Char(35);
        End-DS;

        dcl-s VResultado ind inz(*off);

        dcl-pi *n ind;
           Pbanco    char(2);
           Pmoneda   char(3);
           pReturnDS likeds(TasaBcvDs);
        end-pi;

           clear pReturnDS;

           Exec SQL
              select ratbnk, ratccy, ratexr, ratper, ratcya, ratdsc
                     into :pReturnDS from rates
                     where ratbnk = :Pbanco and ratccy = :Pmoneda

              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultado = *On;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : Bloqueo
       // Objetivo: Bloquea monto en Acmst y graba en Uncol
       //           *on  = Retorna exitosamente
       //           *off = Fallido
       //
       // Autor   : Francisco Martinez
       // Fecha   :  Junio     2023
       //-----------------------------------------------------------------------
        Dcl-Proc BloqueoUncol export;

        Dcl-DS WbloqueUncolDS ;
           P1         char(2);
           P2         zoned(12:0);
           P3         Packed(3:0);
           P4         Packed(15:2);
           P5         zoned(2);
           P6         zoned(2);
           P7         zoned(2);
           P8         Packed(9:0);
           P9         Char(15);
           P10        Char(4);
           P11        Packed(12:0);
           P12        zoned(3);
        end-DS;

        Dcl-DS FechaDs ;
           Waa            Zoned(2:0) ;
           Wmm            Zoned(2:0) ;
           Wdd            Zoned(2:0) ;
        End-DS;

        dcl-s VResultado ind inz(*off);
        dcl-s Hora       zoned(7);

        dcl-pi *n ind;
           pReturnDS   likeds(WbloqueUncolDS);
           Wpfec       likeds(FechaDs);
        end-pi;

           FechaDs = Wpfec ;
           WbloqueUncolDS = pReturnDS ;
           Hora = %dec(%int(%Char(%time():*HMS0))) ;

           Exec SQL
              Insert Into Uncol (uncbnk, uncacc, uncbrn, uncflg, uncamn,
                     uncckn, uncdys, uncrdd, uncrdm, uncrdy, uncrdc, uncmdd,
                     uncmdm, uncmdy, uncmdc, unccun, uncrsn, uncsta,
                     unctel, unckbk, unckac, unchty, uncnrm, uncfus)
              Values (:P1, :P2, :P3, 'H', :P4, 0, :P12, :P5, :P6, :P7,
                      1, :Wpfec.Wdd, :Wpfec.Wmm, :Wpfec.waa, 1, :P8, :P9, 'A',
                      :hora, ' ', :P9, :P10, :P11, ' ');

           If SQLCODE= 0;
              Exec SQL
                 update Acmst set
                 acmham = acmham + :WbloqueUncolDS.p4 ,
                 acmmnb = acmmnb + :WbloqueUncolDS.p4
                 where acmacc = :WbloqueUncolDS.p2 ;
              If SQLCODE= 0;
                 VResultado = *on;
              endif ;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : Desbloqueo
       // Objetivo: Desbloquea monto en Acmst y graba en Uncol status
       //           *on  = Retorna exitosamente
       //           *off = Fallido
       //
       // Autor   : Francisco Martinez
       // Fecha   :  Junio     2023
       //-----------------------------------------------------------------------
        Dcl-Proc DesBloqueoUncol export;

        Dcl-DS WDesbloqueUncolDS ;
           P1         zoned(12:0);
           P2         zoned(15:2);
           P3         Char(15);
           P4         Char(4);
           P5         zoned(12:0);
        end-DS;

        dcl-s VResultado ind inz(*off);
        dcl-s WUNCSTA    char(1);

        Dcl-PI *n ind;
           pReturnDS  likeds(WDesbloqueUncolDS);
        end-pi;

           WDesbloqueUncolDS = pReturnDS ;

           Exec SQL
              select UNCSTA into :WUNCSTA from Uncol
              where uncacc = :P1 and uncamn = :P2 and uncsta = 'A'
              and uncflg = 'H' and uncfus <> 'C' and uncrsn = :P3
              and Unchty = :P4 and Uncnrm = :P5

           Fetch First 1 Row Only;

           If SQLCODE= 0;
              Exec SQL
                 update Uncol set UNCSTA = 'D'
                 where uncacc = :P1 and uncamn = :P2 and uncsta = 'A'
                 and uncflg = 'H' and uncfus <> 'C' and uncrsn = :P3
                 and Unchty = :P4 and Uncnrm = :P5

              Fetch First 1 Row Only ;

              If SQLCODE= 0;
                 Exec SQL
                    update Acmst set
                           acmham = acmham - :WDesbloqueUncolDS.p2 ,
                           acmmnb = acmmnb - :WDesbloqueUncolDS.p2
                    where acmacc = :WDesbloqueUncolDS.p1 ;

                 If SQLCODE= 0;
                    VResultado = *on;
                 endif ;
              endif;
           endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : FechaBloc
       // Objetivo: Calcula fecha de bloqueo
       //           *on  = Retorna exitosamente
       //           *off = Fallido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio 2023
       //-----------------------------------------------------------------------
        Dcl-Proc FechaBloc export;

        dcl-s VResultado ind inz(*off);
        dcl-s Wfecha DATE ;

        Dcl-DS FechaDs ;
           Waa            Zoned(4:0) Pos(1);
           Waa1           Zoned(2:0) Pos(3);
           Wmm            Zoned(2:0) Pos(5);
           Wdd            Zoned(2:0) Pos(7);
           Wfecha1        Zoned(6:0) Pos(3);
        End-DS;

        Dcl-DS FechaCntrlcntDs qualified ;
           Wcntrdd        zoned(2);
           Wcntrdm        Zoned(2);
           Wcntrdy        zoned(2);
        End-DS;

        Dcl-PI *n ind;
           P1    likeds(FechaCntrlcntDs);
           p2    zoned(3);
           p3    zoned(6);
        end-pi;

           Waa1 = p1.Wcntrdy ;
           Wmm = p1.Wcntrdm ;
           Wdd = p1.Wcntrdd ;

           Wfecha = %date(Wfecha1:*YMD);
           Wfecha += %days(p2);

           waa = %dec(%char(%dec(%subdt(WFecha:*years))):4:0) ;
           wmm = %dec(%char(%dec(%subdt(WFecha:*months))):2:0) ;
           wdd = %dec(%char(%dec(%subdt(WFecha:*days))):2:0) ;

           p3 = Wfecha1 ;

           VResultado = *on;

           Return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : BuscaIgtfBeca
       // Objetivo: Verifica si es cliente especial Beca
       //           *on  = Retorna exitosamente
       //           *off = Fallido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio 2023
       //-----------------------------------------------------------------------
        Dcl-Proc BuscaIgtfBeca export;

        dcl-s VResultado ind inz(*off);

        Dcl-PI *n ind;
           P1     char(10);
           P2     char(100);
        end-pi;

            clear P2 ;
            Exec SQL
               select rmnomb into :P2 from arc_seniat
                      where snrorif = :p1

            Fetch First 1 Row Only;

            If SQLCODE= 0;
               VResultado = *on;
            endif;

            Return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : BuscarDescripcionProducto
       // Objetivo: Busca Descripcion del Producto
       //           *on  = Retorna exitosamente
       //           *off = Fallido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Junio 2023
       //-----------------------------------------------------------------------
        Dcl-Proc BuscarDescripcionProducto export;

        dcl-s VResultado ind inz(*off);
        dcl-s Wdespro    char(15) inz(*blank);
        dcl-s Wdespro1   char(40) inz(*blank);
        dcl-S @NULL      Int(5)   Inz(-1);

        Dcl-PI *n ind;
           P1     char(4);
           P2     char(78);
        end-pi;

            Exec SQL
               select apcdsc into :p2
                      from apcls where apcbnk = '01' and apccde = :p1

            Fetch First 1 Row Only;

            If SQLCODE= 0;
               VResultado = *on;
            else;
               p2 = 'PRODUCTO INDEFINIDO ->' + P1 ;
            endif;

            Return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : BuscarProductoCanal
       // Objetivo: Busca si existe producto - canal
       //           *on  = Retorna exitosamente
       //           *off = Fallido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio 2023
       //-----------------------------------------------------------------------
        Dcl-Proc BuscarProductoCanal export;

        dcl-s VResultado ind inz(*off);

        Dcl-PI *n ind;
           Pcanal char(2);
           Pprod  char(4);
           Pstat  char(1);
        end-pi;

            Exec SQL
               select ibsta into :Pstat
                      from ibprocanal where ibcnl  = :pcanal and
                           ibpro  = :pprod and ibsta  = 'A'

            Fetch First 1 Row Only;

            If SQLCODE= 0;
               VResultado = *on;
            endif;

            Return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : ClienteRedc
       // Objetivo: Verifica Rif en REDC
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc ClienteRedc export;

        dcl-s VResultado ind inz(*off);
        dcl-s Wcedula    zoned(15:0) inz ;

        dcl-pi *n ind;
           Pnac         char(1);
           Pident       zoned(15:0);
           Pclicod      zoned(15:0);
        end-pi;

           Pclicod = *zeros ;
           Wcedula = Pident ;

           Exec SQL
              Select clicod into :Pclicod
                     from bducirftab where cirtid = :Pnac and
                          cirdes = :Wcedula and cirest = 'A'
               Fetch First 1 Row Only;

              If SQLCODE= 0;
                 VResultado = *On;
              endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : ClienteInterconex
       // Objetivo: Verifica si es afiliado en Ibafiliado
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc ClienteInterconex export ;

        dcl-s wrecords zoned(9:0);
        dcl-s Wusuario char(15);
        dcl-s VResultado ind inz(*off);

        dcl-pi *n ind;
           Pidentidad   char(20);
           Pcliente     Packed(9:0);
        end-pi;

           Exec SQL
              Select iblogusuar into :Wusuario
                     from ibafiliado where ibaficid = :Pidentidad
                     and IBAFISTS = 'A';

              If SQLCODE= 0;
                 Pcliente =  %int(%trim(Wusuario)) ;
                 VResultado = *On;
              endif;

           return VResultado ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : BuscarCuentaAlm
       // Objetivo: Busca si la Cuenta es de almacenamiento
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc BuscarCuentaAlm  export;

        dcl-s wrecords zoned(3:0);
        dcl-s VResultado ind inz(*off);

        dcl-pi *n ind;
           Pcliente     zoned(09);
           PcuentaAlm   char(04);
           Pcuenta      zoned(12);
        end-pi;

           Exec SQL
              Select acmacc into :Pcuenta
                     from acmstl0, ibprodalma
                     WHERE substr(char(acmacc), 7, 4) = :PcuentaAlm and
                           acmcun = :Pcliente and acmpro = ibcodpro ;

              If Sqlcode = 0 ;
                 VResultado = *On;
              endif;

           return VResultado ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetMonedaRates
       // Objetivo: Verifica que exista la Moneda de Almacemamiento
       //           *on  = Retorna exitosamente
       //           *off = Fallido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc GetMonedaRates export;

        dcl-s VResultado ind inz(*off);
        dcl-s Wrecords   zoned(9:0) inz ;

        dcl-pi *n ind;
           Pbanco    char(2);
           Pmoneda   char(3);
        end-pi;

           Exec SQL
              select Count(*) into :Wrecords from Rates
                     where ratbnk = :Pbanco and ratccy = :Pmoneda ;

           If Wrecords > 0 ;
              VResultado = *On;
           endif;

           return VResultado ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : AlicuotaIgtf
       // Objetivo: Busca valor de la alicuota del IGTF en Cntrltax
       //           *on  = Retorna exitosamente
       //           *off = Fallido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Agosto  2023
       //-----------------------------------------------------------------------
        Dcl-Proc AlicuotaIgtf export;

        Dcl-DS CntrltaxDs qualified ;
           taxprc        zoned(5:3);
           montoigtf     zoned(11:2);
        End-DS;

        dcl-s VResultado ind inz(*off);

        dcl-pi *n ind;
           Pbanco     char(2);
           Ptipo      char(3);
           Pmonto     zoned(11:2);
           pReturnDS  likeds(CntrltaxDs);
        end-pi;

           clear pReturnDS;

           if Pmonto > *zeros ;
              Exec SQL
                 select taxprc into :pReturnDS.taxprc
                        from Cntrltax
                        where taxbnk = :Pbanco and taxttp = :Ptipo

                 Fetch First 1 Row Only;

              If SQLCODE= 0;
                 pReturnDS.montoigtf = (Pmonto * pReturnDS.taxprc) / 100 ;
                 VResultado = *On;
              endif;
           endif;

           return VResultado ;

        end-proc;
