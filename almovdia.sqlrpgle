       ctl-opt copyright('Banco Exterior')
             main(Principal) dftactgrp(*no) actgrp(*caller)
             option(*srcstmt: *nodebugio: *nounref: *noshowcpy)
             datfmt(*iso) aut(*all) debug(*yes) alwnull(*usrctl)
             bnddir('IBBNDDIR01':'HUBNDDIR01') ;
       //----------------------------------------------------------------------/
       //   Banco Exterior
       //   Fecha de Creacion: 10/2026
       //   Modulo: Consulta Movimientos Diarios de cuentas de Almacenamiento
       //   Objetivo: Busca Movimientos de un dia del modulo de Almacenamiento
       //   Autor: E65295 - Francisco Martinez
       //----------------------------------------------------------------------/
       // BITACORA DE ACTUALIZACIONES
       //----------------------------------------------------------------------/
       // FECHA    | AUTOR  |       D E S C R I P C I O N
       //----------------------------------------------------------------------/
       //          |        |
       //----------------------------------------------------------------------/

         /include *libl/qddssrc,ibcopy001
         /include *libl/qddssrc,ibdata001
         /include *libl/qddssrc,hudatmoni1
         /include *libl/qddssrc,hucopmoni1

       // Estructura de Request y Response

         dcl-ds EstructuraRequestDs qualified;
          // * AREA FIJA
            leng             bindec(6)   ; // MSG-DATALENG
            program          char(8)     ; // NOMBRE_PROGRAMA
            ipclient         char(39)    ; // DIR_IP_CLIENTE
            idclient         char(20)    ; // ID_DEL_CLIENTE
          // * AREA DE ENTRADA
            hupfrifcli       char(15)    ; // RIF_COD_IBS
            hupfcuenta       char(20)    ; // CUENTA DE ALMACENAMIENTO
            hupffchmov       zoned(08)   ; // FECHA_MOV.AAAAMMDD
            position         zoned(09)   ; // INICIO_BUSQUEDA
            hupfcanal        char(2)     ; // CANAL
          // * AREA DE SALIDA
            code             char(4)     ; // CODIGO_RESP
            descriptio       char(80)    ; // MENSAJE_RESP
            hupfsigno        char(1)     ; // SIGNO SALDO
            hupfsalini       zoned(15:2) ; // SALDO_INICIAL
            hupfnumcre       zoned(7)    ; // TOTAL_CREDITOS
            hupftotcre       zoned(15:2) ; // MONTO_CREDITOS
            hupfnumdeb       zoned(7)    ; // TOTAL_DEBITOS
            hupftotdeb       zoned(15:2) ; // MONTO_DEBITOS
            hupftotpag       zoned(6)    ; // TOTAL_PAGINAS
            hupftotreg       zoned(9)    ; // TOTAL_REGISTROS
            hupfnumpag       zoned(6)    ; // NUMERO_PAGINA
            hupfnumreg       zoned(9)    ; // ULTIMA_POSICION
            hupffinpag       zoned(15:2) ; // SALDO FINAL PAGINA
            dcl-ds Response dim(500)     ; // Response
               hupffecope   char(16)     ; // FECHA_HORA_OPERACION
               hupffeccon   char(16)     ; // FECHA_HORA_CONTABLE
               hupfcodtra   char(4)      ; // CODIGO_DE_TRANSACCION
               hupfrefere   zoned(15)    ; // REFERENCIA
               hupfdestra   char(45)     ; // DESCRIPCION_TRANSACCION
               hupfdebcre   char(1)      ; // TIPO_DEB_CRE
               hupfmonto    zoned(15:2)  ; // MONTO_TRANSACCION
               hupfsigsal   char(1)      ; // SIGNO DISPONIBLE
               hupfsaldo    zoned(15:2)  ; // SALDO_CUENTA
            end-ds;
         end-ds;

         dcl-s Wlimite      zoned(4:0) inz ;
         dcl-s Wposicion    Zoned(9:0) inz ;

       //----------------------------------------------------------------------/
       // VARIABLES
       //----------------------------------------------------------------------/

         Dcl-ds WtotalCtaAlm  INZ;
            WregistroAlm Char(128) dim(500);
         End-ds;

         Dcl-pr cuentade20 extpgm('CUENTA20');
            PARM1 LIKE(Param1);
         End-pr;

         Dcl-pr QCmdExc  ExtPgm('QCMDEXC');
            Cmd          Char(200) Options(*VarSize) Const;
            CmdLen       Packed(15:5) Const;
         End-pr;

         Dcl-ds *N  Inz;
            DesCmd  Char(200) ;
         End-ds;

         dcl-s Wrif          char(10) inz ;
         dcl-s Wrif1         char(1) inz ;
         dcl-s Wcero         zoned(9:0) inz ;
         dcl-s Wposini       zoned(9:0) inz ;
         dcl-s Wpagineo      zoned(3:0) inz(500) ;
         dcl-s WclienteAlm   zoned(9:0) inz ;
         dcl-s WclienteAlm1  Packed(9:0) inz ;
         dcl-s Widentif      zoned(15:0) inz ;
         dcl-s wident20      char(20) inz ;
         dcl-s Wcodigocli    zoned(15:0) inz ;
         dcl-s DiaActual     ind inz(*off);
         dcl-s YearAnterior  ind inz(*off);
         dcl-S Param1        Char(34) inz;
         dcl-s cta20         char(20) inz;
         dcl-s Wlongitud     zoned(6) inz ;
         dcl-s Wacmofc       char(4) inz ;
         dcl-s Wacmaty       char(4) inz ;
         dcl-s Wcuenta1      zoned(12) inz ;
         dcl-s Wtipo         char(2) inz ; // Tipo cnofc
         dcl-s Wsucursal     char(4) inz ; // AGENCIA
         dcl-s WcuentaAlm4   char(4) inz ;
         dcl-s WcuentaAlm12  zoned(12:0) inz ;


         Dcl-Ds *N  INZ;
            wh_ofi         Zoned(4:0) Pos(1);
            ofi04          Char(4)    Pos(1) ;
         End-Ds;

         Dcl-Ds *N  INZ;
            wh_cta         Zoned(12:0) Pos(1);
            cta10          Char(10)   Pos(3) ;
         End-Ds;

         Dcl-ds Validacampos qualified  ;
            p1             char(20) ;
            p2             char(20) ;
            p3             zoned(08:0) ;
            p4             char(02) ;
         End-ds;

         Dcl-DS FechadesdeDs ;
            FechaDesde     zoned(8:0)  Pos(1);
            AÑodesde       zoned(2:0)  Pos(3);
            MesDesde       zoned(2:0)  Pos(5);
            diaDesde       zoned(2:0)  Pos(7);
         End-DS;

         Dcl-DS FechahastaDs ;
            Fechahasta     zoned(8:0)  Pos(1);
            AÑohasta       zoned(2:0)  Pos(3);
            Meshasta       zoned(2:0)  Pos(5);
            diahasta       zoned(2:0)  Pos(7);
         End-DS;

         Dcl-DS WmesdiaDs ;
            WfechaMov      zoned(8:0)  Pos(1);
            WaÑoMov        zoned(2:0)  Pos(3);
            WmesMov        zoned(2:0)  Pos(5);
            WdiaMov        zoned(2:0)  Pos(7);
         End-DS;

         Dcl-DS p1 likeds(EstructuraRequestDs) inz;

       //----------------------------------------------------------------------
       // Program Principal
       //----------------------------------------------------------------------

         Dcl-Proc Principal ;

       //----------------------------------------------------------------------
       // Entrada de parametros (Rafaga)
       //----------------------------------------------------------------------

          dcl-pi *n extpgm('ALMOVDIA');
             Parametros likeds(EstructuraRequestDs) ;
          end-pi ;

          Exec SQL SET option Commit=*NONE ;

          clear p1 ;
          p1 = Parametros ;

          Inicializa() ;

          DiaActual = *off ;
          if FechaCntrlcntDs.Wcntrdy = WaÑomov and
             FechaCntrlcntDs.Wcntrdm = WmesMov and
             FechaCntrlcntDs.Wcntrdd = WdiaMov ;
             DiaActual = *on ;
          endif;

          validacampos.p1 = P1.hupfrifcli ;
          validacampos.p2 = P1.hupfcuenta ;
          validacampos.p3 = P1.hupffchmov ;
          validacampos.p4 = P1.hupfcanal ;
          P1.code = '0000' ;
          P1.descriptio = *blank ;

          ValidarInput(validacampos:wfechadesde:P1.code:P1.descriptio) ;

          if P1.code = '0000';
             wfechadesde = P1.hupffchmov ;
             wfechahasta = P1.hupffchmov ;
             Wcodigocli = *zeros ;
             wrif = %trim(p1.hupfrifcli) ;
             wrif1 = %subst(p1.hupfrifcli:1:1);
             Widentif = %Int(%subst(p1.hupfrifcli:2:9));
             if ClienteRedc(Wrif1:Widentif:Wcodigocli) ;
                Wclientealm = Wcodigocli ;
                Wclientealm1 = Wcodigocli ;
             else;
                if FieldsCliente(wrif:CumstDs);
                   Wclientealm = CumstDs.Wcuscun ;
                   P1.code = '0000';
                else;
                   P1.code = '0308';
                   p1.descriptio = 'CLIENTE NO EXISTE ' + p1.hupfrifcli ;
                endif ;
             endif ;
          endif ;

          if P1.code = '0000';
             if P1.hupfcanal = '04' ;
                Wcuentaalm4 = %subst(P1.hupfcuenta:10:4) ;
                if BuscarCuentaAlm(Wclientealm:Wcuentaalm4:Wcuentaalm12) ;
                   Wcuenta = Wcuentaalm12;
                else ;
                   P1.code = '0310';
                   P1.descriptio = 'CLIENTE NO POSEE CUENTA DE ALMACENAMIENTO '
                                  + Wrif ;
                endif ;
             endif ;
          endif ;

          if P1.code = '0000';
             if not FieldsCuenta(Wcuenta:AcmstDs);
                P1.code = '0307';
                P1.descriptio = 'CUENTA NO EXISTE ' +  P1.hupfcuenta ;
             else;
                Wacmaty = AcmstDs.Wacmaty ;
             endif ;
          endif ;

          SaldoDs.WSaldo = *zeros;

          if P1.code = '0000';
             SaldoDs.Wcuenta = AcmstDs.Wacmacc;
             SaldoDs.WFechaDesde = Wfechadesde;
             SaldoDs.WFechaHasta = Wfechahasta;
             if P1.position = *zeros ;
                Vresultado = GetSaldoInicial(SaldoDs) ;
             else ;
                SaldoDs.WSaldo = p1.hupffinpag ;
             endif ;
             if DiaActual ;
                if CuentaMovTtran(SaldoDs) ;
                   clear FieldAlm01Ds;
                   if GetMovTtran01(wlim:wposini:SaldoDs:FieldAlm01Ds) ;
                      P1.code = '0000';
                      P1.descriptio = 'CONSULTA SATISFACTORIA' ;
                   else ;
                      P1.code = '0000';
                      P1.descriptio = 'CONSULTA SATISFACTORIA' ;
                   endif ;
                else ;
                   P1.code = '0000';
                   P1.descriptio = 'CONSULTA SATISFACTORIA' ;
                endif ;
             else ;
                if CuentaMovTrans(SaldoDs) ;
                   clear FieldAlm01Ds;
                   if GetMovTrans01(wlim:wposini:SaldoDs:FieldAlm01Ds) ;
                      P1.code = '0000';
                      P1.descriptio = 'CONSULTA SATISFACTORIA' ;
                   else ;
                      P1.code = '0000';
                      P1.descriptio = 'CONSULTA SATISFACTORIA' ;
                   endif ;
                else ;
                   P1.hupfsalini = SaldoDs.Wsaldo ;
                   if P1.position <> *zeros ;
                      SaldoDs.WSaldo = p1.hupffinpag ;
                   endif ;
                   P1.code = '0000';
                   P1.descriptio = 'CONSULTA SATISFACTORIA' ;
                endif ;
             endif ;
          endif ;

          select;
             when (p1.hupfsalini) < 0 ;
                   p1.hupfsigno = '-';
                   p1.hupfsalini =  p1.hupfsalini * -1 ;
             when (p1.hupfsalini) > 0 ;
                   p1.hupfsigno = '+';
             other;
                   p1.hupfsigno = ' ';
          endsl;

          Wlongitud = %len(%TRIM(p1)) ;
          p1.leng = Wlongitud ;
          Parametros = p1 ;

         end-proc  ;

        //----------------------------------------------------------------------
        // RUTINA DE INICIAL
        //----------------------------------------------------------------------
         Dcl-Proc Inicializa ;

             dcl-s Wpar char(1);

             P1.code = '0000';
             clear P1.hupftotpag ;
             clear P1.hupftotreg ;
             clear P1.hupfnumpag ;
             clear P1.hupfnumreg ;
             clear P1.response ;
             clear p1.hupfsalini ;
             clear CumstDs ;
             clear AcmstDs ;
             clear CumstDs ;
             clear AcmstDs ;
             clear CntrlcntDs ;
             clear ConsultaDs ;
             clear FechaCntrlcntDs ;
             Wposini = P1.position ;
             Wlim = 500 ;
             Monitor;
                WPos = %dec(P1.position:9:0) ;
             on-error ;
                Wpos = 0 ;
             endmon;

           // Get LeeCntrlcnt
             if LeeCntrlcnt(Banco:CntrlcntDs);
                FechaCntrlcntDs.Wcntrdd = CntrlcntDs.Wcntrdd ;
                FechaCntrlcntDs.Wcntrdm = CntrlcntDs.Wcntrdm ;
                FechaCntrlcntDs.Wcntrdy = CntrlcntDs.Wcntrdy ;
             endif;

             WfechaMov = p1.hupffchmov ;

        end-proc;
        //----------------------------------------------------------------------
        //  Validar Entrada
        //----------------------------------------------------------------------
         Dcl-Proc ValidarInput ;

         Dcl-DS hupfedo01Ds ;
            hupfrifcli      char(20) ;
            hupfcuenta      char(20) ;
            hupffchmov      zoned(08) ;
            hupfcanal       char(02) ;
         End-DS;

         dcl-s Wfecha10 char(10);

         dcl-pi *n ind;
            p8   likeds(hupfedo01Ds) ;
            Wfechadesde    zoned(8) ;
            P1code   char(4) ;
            p1descriptio   char(80) ;
         end-pi;

           for i = 1 to 1;

               if p8.hupfrifcli = *blank;
                  p1code = '0301';
                  p1descriptio = 'IDENTIFICACION EN BLANCO' ;
                  leave;
               endif;

               Wnac = %subst(p8.hupfrifcli:1:1) ;
               if Wnac <> 'V' and Wnac <> 'E' and Wnac  <> 'J' and
                  Wnac <> 'G' and Wnac <> 'P' ;
                  p1code = '0302';
                  p1descriptio = 'TIPO ID INCORRECTA ' + Wnac ;
                  leave;
               endif;

               if p8.hupfcuenta = *blank;
                  p1code = '0303';
                  p1descriptio = 'CODIGO DE SERVICIO EN BLANCO' ;
                  leave;
               endif;

               if p8.hupfcanal = *blank or p8.hupfcanal = '00' ;
                  p1code = '0311';
                  p1descriptio = 'CODIGO DE CANAL INCORRECTO ' +
                  p8.hupfcanal  ;
                  leave;
               endif;

               if p8.hupffchmov = *zeros ;
                  p1code = '0305';
                  p1descriptio = 'FECHA PARA LA CONSULTA ESTA EN CERO ' +
                                   %char(p8.hupffchmov);
                  leave;
               endif;

           endfor ;

           return vresultado;

         end-Proc ;
       //-----------------------------------------------------------------------
       // Modulo  : GetSaldoInicial
       // Objetivo: Trae el Saldo Inicial del dia consultado del SaldoTxt
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : agosto 2023
       //-----------------------------------------------------------------------
        Dcl-Proc GetSaldoInicial ;

        Dcl-DS SaldoInicialDs Qualified ;
           Wcuenta        zoned(20:0) ;
           Wfechaini      zoned(08:0) ;
           Wfechafin      zoned(08:0) ;
           Wsaldo         zoned(15:2) ;
        End-DS;

        dcl-s VResultado  ind inz(*off);
        dcl-s Wregistro   zoned(12:0) inz ;
        dcl-s Wconsec     zoned(12:0) inz ;
        dcl-s Wmontotr    zoned(15:2) inz ;
        dcl-s WFechadesde zoned(08:0) inz ;
        dcl-s WFechahasta zoned(08:0) inz ;
        dcl-s Wfecha10    char(10);
        dcl-s Wdate       Date  inz ;

        dcl-pi *n ind;
           pReturnDS   likeds(SaldoInicialDs) ;
        end-pi;

           SaldoInicialDs = pReturnDS ;

           Exec Sql
           Select Max(o_conse), Max(Rrn(saldotxt)) into :Wconsec, :Wregistro
                  from saldotxt
                  where o_traacc = :SaldoInicialDs.Wcuenta and
                  o_fecmov <= :SaldoInicialDs.Wfechaini ;

           If Wconsec <> 0 ;
              VResultado = *on;
              Exec Sql
                   Select o_saldo, o_traamt into
                   :SaldoInicialDs.Wsaldo, :Wmontotr
                   from saldotxt
                   where o_traacc = :SaldoInicialDs.Wcuenta and
                   o_conse = :Wconsec and Rrn(saldotxt) = :Wregistro ;
                   pReturnDS.Wsaldo = SaldoInicialDs.Wsaldo ;
           else;
              Exec Sql
              Select Min(o_conse), Min(Rrn(saldotxt)) into :Wconsec, :Wregistro
                     from saldotxt
                     where o_traacc = :SaldoInicialDs.Wcuenta and
                     o_fecmov >= :SaldoInicialDs.Wfechaini and
                     o_fecmov <= :SaldoInicialDs.Wfechafin;

              If Wconsec <> 0 ;
                 VResultado = *on;
                 Exec Sql
                      Select o_saldo, o_traamt into
                      :SaldoInicialDs.Wsaldo, :Wmontotr
                      from saldotxt
                      where o_traacc = :SaldoInicialDs.Wcuenta and
                      o_conse = :Wconsec and Rrn(saldotxt) = :Wregistro ;
                      pReturnDS.Wsaldo = SaldoInicialDs.Wsaldo - Wmontotr ;
              endif;
           endif;

           pReturnDS.Wsaldo = SaldoInicialDs.Wsaldo;

           return VResultado ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : CuentaMovTrans
       // Objetivo: Cuenta Movimiento en Transl5
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Agosto 2023
       //-----------------------------------------------------------------------
        Dcl-Proc CuentaMovTrans ;

        Dcl-DS SaldoInicialDs Qualified ;
           Wcuenta        zoned(20:0) ;
           Wfechaini      zoned(08:0) ;
           Wfechafin      zoned(08:0) ;
           Wsaldo         zoned(15:2) ;
        End-DS;

        Dcl-DS FechadesdeDs Qualified ;
           FechaDesde     zoned(8:0)  Pos(1);
           aÑodesde       zoned(2:0)  Pos(3);
           mesDesde       zoned(2:0)  Pos(5);
           diaDesde       zoned(2:0)  Pos(7);
        End-DS;

        dcl-s VResultado ind inz(*off);
        dcl-s Wresto         zoned(5:2)  inz ;

        dcl-pi *n ind;
           pReturnDS   likeds(SaldoInicialDs) ;
        end-pi;

           SaldoInicialDs = pReturnDS ;
           FechadesdeDs.Fechadesde = SaldoInicialDs.Wfechaini ;

           P1.hupftotreg = *zeros;
           P1.hupftotdeb = *zeros;
           P1.hupfnumdeb = *zeros;
           P1.hupftotcre = *zeros;
           P1.hupfnumcre = *zeros;

           Exec sql
              Select
                 sum(case when tradcc = '0' then traamt else 0 end),
                 sum(case when tradcc = '0' then 1 else 0 end),
                 sum(case when tradcc = '5' then traamt else 0 end),
                 sum(case when tradcc = '5' then 1 else 0 end)
                 into :P1.hupftotdeb, :P1.hupfnumdeb,
                      :P1.hupftotcre, :P1.hupfnumcre
               from transl5
               where travdy = :FechadesdeDs.aÑodesde and
                     travdm = :FechadesdeDs.mesdesde and
                     travdd = :FechadesdeDs.diadesde and
                     traacc = :SaldoInicialDs.Wcuenta ;

           P1.hupftotreg = P1.hupfnumcre + P1.hupfnumdeb ;
           if P1.hupftotreg > *zero ;
              P1.hupftotpag = P1.hupftotreg/Wpagineo ;
              Wresto = %rem(P1.hupftotreg:Wpagineo) ;
              if Wresto > 0 ;
                 P1.hupftotpag += 1 ;
              endif ;
              VResultado = *on ;
           endif ;

           return VResultado ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : CuentaMovTtran
       // Objetivo: Cuenta Movimiento del Ttranl1 - Transl5
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Agosto 2023
       //-----------------------------------------------------------------------
        Dcl-Proc CuentaMovTtran ;

        Dcl-DS SaldoInicialDs Qualified ;
           Wcuenta        zoned(20:0) ;
           Wfechaini      zoned(08:0) ;
           Wfechafin      zoned(08:0) ;
           Wsaldo         zoned(15:2) ;
        End-DS;

        Dcl-DS FechadesdeDs Qualified ;
           FechaDesde     zoned(8:0)  Pos(1);
           aÑodesde       zoned(2:0)  Pos(3);
           mesDesde       zoned(2:0)  Pos(5);
           diaDesde       zoned(2:0)  Pos(7);
        End-DS;

        dcl-s VResultado ind inz(*off);
        dcl-s Wnumcrettran   zoned(5:0)  inz ;
        dcl-s Wnumdebttran   zoned(5:0)  inz ;
        dcl-s Wtotcrettran   zoned(15:2) inz ;
        dcl-s Wtotdebttran   zoned(15:2) inz ;
        dcl-s Wresto         zoned(5:2)  inz ;

        dcl-pi *n ind;
           pReturnDS   likeds(SaldoInicialDs) ;
        end-pi;

           SaldoInicialDs = pReturnDS ;
           FechadesdeDs.Fechadesde = SaldoInicialDs.Wfechaini ;

           P1.hupftotreg = *zeros;
           P1.hupftotdeb = *zeros;
           P1.hupfnumdeb = *zeros;
           P1.hupftotcre = *zeros;
           P1.hupfnumcre = *zeros;

           Exec sql
              Select
                 sum(case when ttrdcc = '0' then ttramt else 0 end),
                 sum(case when ttrdcc = '0' then 1 else 0 end),
                 sum(case when ttrdcc = '5' then ttramt else 0 end),
                 sum(case when ttrdcc = '5' then 1 else 0 end)
                 into :Wtotdebttran, :Wnumdebttran,
                      :Wtotcrettran, :Wnumcrettran
              from ttranl1
              where ttrvdy = :FechadesdeDs.aÑodesde and
                    ttrvdm = :FechadesdeDs.mesdesde and
                    ttrvdd = :FechadesdeDs.diadesde and
                    ttracc = :SaldoInicialDs.Wcuenta ;

           P1.hupfnumdeb = P1.hupfnumdeb + Wnumdebttran ;
           P1.hupfnumcre = P1.hupfnumcre + Wnumcrettran ;
           P1.hupftotdeb = P1.hupftotdeb + Wtotdebttran ;
           P1.hupftotcre = P1.hupftotcre + Wtotcrettran ;
           P1.hupftotreg = P1.hupfnumcre + P1.hupfnumdeb ;

           if P1.hupftotreg > *zero ;
              P1.hupftotpag = P1.hupftotreg/Wpagineo ;
              Wresto = %rem(P1.hupftotreg:Wpagineo) ;
              if Wresto > 0 ;
                 P1.hupftotpag += 1 ;
              endif ;
              VResultado = *on ;
           endif ;

           return VResultado ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetMovTrans01
       // Objetivo: Consulta Movimiento en Transl5
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc GetMovTrans01 ;

        Dcl-DS SaldoInicialDs Qualified ;
           Wcuenta        zoned(20:0) ;
           Wfechaini      zoned(08:0) ;
           Wfechafin      zoned(08:0) ;
           Wsaldo         zoned(15:2) ;
        End-DS;

        Dcl-DS FechadesdeDs Qualified ;
           FechaDesde     zoned(8:0)  Pos(1);
           aÑodesde       zoned(2:0)  Pos(3);
           mesDesde       zoned(2:0)  Pos(5);
           diaDesde       zoned(2:0)  Pos(7);
        End-DS;

        Dcl-DS MovitransDs Qualified ;
           traacc         Zoned(12:0) ;
           trabdy         Zoned(02:0) ;
           trabdm         Zoned(02:0) ;
           trabdd         Zoned(02:0) ;
           tratim         Zoned(06:0) ;
           travdy         Zoned(02:0) ;
           travdm         Zoned(02:0) ;
           travdd         Zoned(02:0) ;
           trackn         Zoned(09:0) ;
           tratrn         Zoned(05:0) ;
           tracde         Char(2)     ;
           tradcc         Char(1)     ;
           tranar         Char(30)    ;
           traamt         Zoned(15:2) ;
           traacr         Zoned(12)   ;
           trabdc         Zoned(1)    ;
        End-DS;

        Dcl-DS FieldAlmDs Qualified ;
           hupffecope     Char(16)          ;
           hupffeccon     Char(16)          ;
           hupfcodtra     Char(04)          ;
           hupfrefere     Zoned(15)         ;
           hupfdestra     Char(45)          ;
           hupfdebcre     Char(1)           ;
           hupfmonto      Zoned(15:2)       ;
           hupfsigsal     Char(1)           ;
           hupfsaldo      Zoned(15:2)       ;
        End-DS;

        dcl-s VResultado ind inz(*off);
        dcl-s Ptotmov    zoned(04);
        dcl-s Wnum       zoned(1) inz;

        Dcl-DS Wreferencia ;
           Wref          zoned(12)  ;
           Wref1         zoned(9)   Pos(4);
        End-DS;


        dcl-pi *n ind;
           Plimite       zoned(4:0);
           Pposicion     zoned(9:0);
           pReturnDS     likeds(SaldoInicialDs) ;
           pReturn01DS   likeds(FieldAlmDs) ;
        end-pi;


           SaldoInicialDs = pReturnDS ;
           FechadesdeDs.Fechadesde = SaldoInicialDs.Wfechaini ;
           i = *zeros;
           Wtotcta = *zeros;

              Exec Sql
              Declare  MovimientosL5 Cursor For
              select traacc, trabdy, trabdm, trabdd, tratim, travdy, travdm,
                     travdd, trackn, tratrn, tracde, tradcc, tranar, traamt,
                     traacr, trabdc
              from transl5
              where travdy = :FechadesdeDs.aÑodesde and
                    travdm = :FechadesdeDs.mesdesde and
                    travdd = :FechadesdeDs.diadesde and
                    traacc = :SaldoInicialDs.Wcuenta

              order by traacc, trabdc, travdy, travdm, travdd, tratim

              limit :Plimite
              offset :Pposicion ;

              // Abre cursor
              Exec Sql
                 Open MovimientosL5 ;

              // Procesa registro
              Exec Sql
                 Fetch next from MovimientosL5 Into :MovitransDs;

              Dow Sqlcod = 0;
                  VResultado = *On;
                  Wtotcta += 1;
                  if Wtotcta <= Wpagineo;
                     i += 1;
                     Select;
                       when MovitransDs.tradcc = '0' ;
                            SaldoInicialDs.wsaldo -= MovitransDs.traamt;
                            pReturn01DS.hupfdebcre = 'D' ;
                       when MovitransDs.tradcc = '5' ;
                            SaldoInicialDs.wsaldo += MovitransDs.traamt;
                            pReturn01DS.hupfdebcre = 'C' ;
                     endSl;

                     if SaldoInicialDs.wsaldo <= 0;
                        pReturn01DS.hupfsigsal = '-';
                        pReturn01DS.hupfsaldo = -1 * SaldoInicialDs.wsaldo;
                     else;
                        pReturn01DS.hupfsigsal = '+';
                        pReturn01DS.hupfsaldo = SaldoInicialDs.wsaldo;
                     endif;

                     pReturn01DS.hupffecope = %Editc(MovitransDs.travdd:'X') +
                                        '/' + %Editc(MovitransDs.travdm:'X') +
                                        '/' + '20' + %char(MovitransDs.travdy) +
                                              %Editc(MovitransDs.tratim:'X') ;

                     pReturn01DS.hupffeccon = %Editc(MovitransDs.trabdd:'X') +
                                        '/' + %Editc(MovitransDs.trabdm:'X') +
                                        '/' + '20' + %char(MovitransDs.trabdy) +
                                              %Editc(MovitransDs.tratim:'X') ;

                     pReturn01DS.hupfcodtra = *blank ;
                     Wnum = %check('0123456789':%subst(MovitransDs.tranar:1:4));
                     if Wnum = *zeros;
                        pReturn01DS.hupfcodtra = %subst(MovitransDs.tranar:1:4);
                     endif ;

                     if MovitransDs.trackn > *zeros ;
                        pReturn01DS.hupfrefere = MovitransDs.trackn;
                     else ;
                        Wref = MovitransDs.traacr;
                        pReturn01DS.hupfrefere = Wref1;
                     endif ;

                     pReturn01DS.hupfdestra = MovitransDs.tranar;
                     pReturn01DS.hupfmonto  = MovitransDs.traamt;

                     P1.response(i) = pReturn01DS;

                  endif;
              // Lee nuevo registro
                  Exec Sql
                       Fetch next from MovimientosL5 Into :MovitransDs;
              Enddo;
              // Cierra Cursor
              Exec Sql Close MovimientosL5;

              pReturnDS.Wsaldo = SaldoInicialDs.Wsaldo ;

              if i > *zeros ;
                 P1.hupffinpag = p1.RESPONSE(i).HUPFSALDO ;
                 if Wposini > *zeros;
                    p1.hupfnumpag = Wposini/Wpagineo + 1 ;
                 else;
                    p1.hupfnumpag = 1 ;
                 endif;
                 p1.hupfnumreg = i * p1.hupfnumpag ;
              endif;

           return VResultado ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetMovTtran01
       // Objetivo: Consulta Movimiento en Ttranl1
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio   2023
       //-----------------------------------------------------------------------
        Dcl-Proc GetMovTtran01 ;

        Dcl-DS SaldoInicialDs Qualified ;
           Wcuenta        zoned(20:0) ;
           Wfechaini      zoned(08:0) ;
           Wfechafin      zoned(08:0) ;
           Wsaldo         zoned(15:2) ;
        End-DS;

        Dcl-DS FechadesdeDs Qualified ;
           FechaDesde     zoned(8:0)  Pos(1);
           aÑodesde       zoned(2:0)  Pos(3);
           mesDesde       zoned(2:0)  Pos(5);
           diaDesde       zoned(2:0)  Pos(7);
        End-DS;

        Dcl-DS MovttranDs Qualified ;
           Wttracc         Zoned(12:0) ;
           Wttrbdy         Zoned(02:0) ;
           Wttrbdm         Zoned(02:0) ;
           Wttrbdd         Zoned(02:0) ;
           Wttrtim         Zoned(06:0) ;
           Wttrvdy         Zoned(02:0) ;
           Wttrvdm         Zoned(02:0) ;
           Wttrvdd         Zoned(02:0) ;
           Wttrckn         Zoned(09:0) ;
           Wttrtrn         Zoned(05:0) ;
           Wttrcde         Char(2)     ;
           Wttrdcc         Char(1)     ;
           Wttrnar         Char(30)    ;
           Wttramt         Zoned(15:2) ;
           Wttracr         Zoned(12)   ;
           Wttrbdc         Zoned(1)    ;
        End-DS;

        Dcl-DS FieldAlmDs Qualified ;
           hupffecope     Char(16)          ;
           hupffeccon     Char(16)          ;
           hupfcodtra     Char(04)          ;
           hupfrefere     Zoned(15)         ;
           hupfdestra     Char(45)          ;
           hupfdebcre     Char(1)           ;
           hupfmonto      Zoned(15:2)       ;
           hupfsigsal     Char(1)           ;
           hupfsaldo      Zoned(15:2)       ;
        End-DS;

        dcl-s VResultado ind inz(*off);
        dcl-s Wnum       Zoned(1) inz;

        Dcl-DS Wreferencia ;
           Wref          zoned(12)  ;
           Wref1         zoned(9)   Pos(4);
        End-DS;

        dcl-pi *n ind;
           Plimite       zoned(4:0);
           Pposicion     zoned(9:0);
           pReturnDS     likeds(SaldoInicialDs) ;
           pReturn01DS   likeds(FieldAlmDs) ;
        end-pi;

           SaldoInicialDs = pReturnDS ;
           FechadesdeDs.Fechadesde = SaldoInicialDs.Wfechaini ;
           i = *zeros;
           Wtotcta = *zeros;

              Exec Sql
              Declare  MovimientosL2 Cursor For
              select ttracc, ttrbdy, ttrbdm, ttrbdd, ttrtim, ttrvdy, ttrvdm,
                     ttrvdd, ttrckn, ttrtrn, ttrcde, ttrdcc, ttrnar, ttramt,
                     ttracr, ttrbdc
              from ttranl1
              where ttrvdy = :FechadesdeDs.aÑodesde and
                    ttrvdm = :FechadesdeDs.mesdesde and
                    ttrvdd = :FechadesdeDs.diadesde and
                    ttracc = :SaldoInicialDs.Wcuenta

              order by ttracc, ttrbdc, ttrvdy, ttrvdm, ttrvdd, ttrtim

              limit :Plimite
              offset :Pposicion ;

              // Abre cursor
              Exec Sql
                 Open MovimientosL2 ;

              // Procesa registro
              Exec Sql
                 Fetch next from MovimientosL2 Into :MovttranDs;

              Dow Sqlcod = 0;
                  VResultado = *On;
                  Wtotcta += 1;
                  if Wtotcta <= Wpagineo;
                     i += 1;
                     Select;
                       when MovttranDs.Wttrdcc = '0' ;
                            SaldoInicialDs.wsaldo -= MovttranDs.Wttramt;
                            pReturn01DS.hupfdebcre = 'D' ;
                       when MovttranDs.Wttrdcc = '5' ;
                            SaldoInicialDs.wsaldo += MovttranDs.Wttramt;
                            pReturn01DS.hupfdebcre = 'C' ;
                     endSl;

                     if SaldoInicialDs.wsaldo <= 0;
                        pReturn01DS.hupfsigsal = '-';
                        pReturn01DS.hupfsaldo = -1 * SaldoInicialDs.wsaldo;
                     else;
                        pReturn01DS.hupfsigsal = '+';
                        pReturn01DS.hupfsaldo = SaldoInicialDs.wsaldo;
                     endif;

                     pReturn01DS.hupffecope = %Editc(MovttranDs.Wttrvdd:'X') +
                                        '/' + %Editc(MovttranDs.Wttrvdm:'X') +
                                        '/' + '20' + %char(MovttranDs.Wttrvdy) +
                                              %Editc(MovttranDs.Wttrtim:'X') ;

                     pReturn01DS.hupffeccon = %Editc(MovttranDs.Wttrbdd:'X') +
                                        '/' + %Editc(MovttranDs.Wttrbdm:'X') +
                                        '/' + '20' + %char(MovttranDs.Wttrbdy) +
                                              %Editc(MovttranDs.Wttrtim:'X') ;

                     pReturn01DS.hupfcodtra = *blank ;
                     Wnum = %check('0123456789':%subst(MovttranDs.Wttrnar:1:4));
                     if Wnum = *zeros;
                        pReturn01DS.hupfcodtra = %subst(MovttranDs.Wttrnar:1:4);
                     endif;

                     if MovttranDs.Wttrckn > *zeros ;
                        pReturn01DS.hupfrefere = MovttranDs.Wttrckn ;
                     else ;
                        Wref = MovttranDs.Wttracr ;
                        pReturn01DS.hupfrefere = Wref1;
                     endif ;

                     pReturn01DS.hupfdestra = MovttranDs.Wttrnar;
                     pReturn01DS.hupfmonto  = MovttranDs.Wttramt;

                     P1.response(i) = pReturn01DS;

                  endif;
              // Lee nuevo registro
                  Exec Sql
                       Fetch next from MovimientosL2 Into :MovttranDs;
              Enddo;
              // Cierra Cursor
              Exec Sql Close MovimientosL2;

              pReturnDS.Wsaldo = SaldoInicialDs.Wsaldo ;

              if i > *zeros ;
                 P1.hupffinpag = p1.RESPONSE(i).HUPFSALDO ;
                 if Wposini > *zeros;
                    p1.hupfnumpag = Wposini/Wpagineo + 1 ;
                 else;
                    p1.hupfnumpag = 1 ;
                 endif;
                 p1.hupfnumreg = i * p1.hupfnumpag ;
              endif;

           return VResultado ;

        end-proc;
