         ctl-opt copyright('Banco Exterior')
                 option(*srcstmt: *nodebugio: *nounref) nomain
                 datfmt(*iso) aut(*all) debug(*yes) alwnull(*usrctl);
       //----------------------------------------------------------------------/
       //   Banco Exterior
       //   Fecha de Creacion: 10/2024
       //   Modulo - Srvpgm de Monitor Plus Huella
       //   Objetivo programa: Procedimientos usados en Monitor Plus
       //
       //
       //   Autor: E65295 - Francisco Martinez
       //----------------------------------------------------------------------/
       // BITACORA DE ACTUALIZACIONES
       //----------------------------------------------------------------------/
       // FECHA    | AUTOR  |       D E S C R I P C I O N
       //----------------------------------------------------------------------/
       //          |        |
       //----------------------------------------------------------------------/

         /include qddssrc,hucopmoni1
         /include qddssrc,hudatmoni1

       //-----------------------------------------------------------------------
       // Modulo  : GetInformacionK10fsys
       // Objetivo: Busca descripción de Banco en K10fsys
       //           *on  = Retorna exitosamente
       //           *off = error
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetInformacionK10fsys export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           Pkey        char(16);
           Wfsysdata   char(100);
        end-pi;

           Exec SQL
              Select substr(fsysdata, 1, 100) into :Wfsysdata
                 from K10FSYS
                 Where FSYSKEY = :Pkey

              Fetch First 1 Row Only;;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetFieldsCliente
       // Objetivo: Busca Cliente por Id y devuelve Campos del Cumst
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetFieldsCliente export;

        Dcl-DS CumstMpDs qualified ;
           Wcusidn        Char(15);
           Wcusna1        Char(45);
           Wcusiad        Char(40);
           Wcuscun        Packed(9:0);
        End-DS;

        dcl-s VResultados ind inz(*off);
        dcl-s Wident     char(15) inz;

        dcl-pi *n  ind;
           Pcodigo       zoned(15);
           pReturnDS     likeds(CumstMpDs);
        end-pi;

           clear pReturnDS ;

           Exec SQL
              Select cusidn, cusna1, cusiad, cuscun
                     into :pReturnDS
                     From Cumst Where cuscun = :Pcodigo

              Fetch First 1 Row Only ;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : GetClienteRedc
       // Objetivo: Verifica Rif en REDC
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetClienteRedc export;

        dcl-s VResultados ind inz(*off);
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

               Fetch First 1 Row Only ;

              If SQLCODE= 0;
                 VResultados = *On;
              endif;

           return VResultados ;

        end-proc;
       //-----------------------------------------------------------------------
       // Modulo  : GetFieldsCuenta
       // Objetivo: Busca cuenta y devuelve Campos del AcmsT
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetFieldsCuenta export;

        Dcl-DS AcmstMpDs qualified ;
           Acmcun        Packed(9:0);
           acmopd        zoned(2:0);
           acmopm        zoned(2:0);
           acmopy        zoned(2:0);
           Acmbrn        Packed(3:0);
           acmuc1        Char(4);
        End-DS;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           Pcuenta     zoned(12:0);
           pReturnDS   likeds(AcmstMpDs);
        end-pi;

           clear pReturnDS;

           Exec SQL
              Select Acmcun, acmopd, acmopm, acmopy, AcmBrn, acmuc1
                     into :pReturnDS
                     From Acmst Where acmacc = :Pcuenta

              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetCodigoCliente1
       // Objetivo: Busca Codigo del cliente por la cuenta Acmst
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetCodigoCliente1 export;

        Dcl-S VResultados    Ind Inz(*Off);

        Dcl-PI *n ind;
           Pcuenta     zoned(12:0);
           Pcodcli     packed(9:0);
        End-PI;

           Exec SQL
              Select acmcun into :Pcodcli
                     From Acmst Where acmacc = :Pcuenta
              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetClienteCodigo
       // Objetivo: Busca Cliente por Codigo y devuelve Campos del Cumst
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetClienteCodigo export;

        Dcl-DS CumstDs qualified ;
           Wcuscun        Packed(9:0);
           Wcusidn        Char(15);
           Wcuslgt        Char(1);
           Wcusna1        Char(45);
           Wcusph1        Packed(11:0);
           Wcusiad        Char(40);
        End-DS;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n  ind;
           Pcuscun      Packed(9:0);
           pReturnDS    likeds(CumstDs);
        end-pi;

        //   clear pReturnDS;

           Exec SQL
              Select cuscun, cusidn, cuslgt, cusna1, cusph1, cusiad
                     into :pReturnDS
                     From Cumst Where cuscun = :Pcuscun
              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : FieldsClienteCedula1
       // Objetivo: Busca Cliente por cedula y devuelve Campos del Cumst
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc FieldsClienteCedula1 export;

        Dcl-DS CumstDs qualified ;
           Wcuscun        Packed(9:0);
           Wcusidn        Char(15);
           Wcuslgt        Char(1);
           Wcusna1        Char(45);
           Wcusph1        Packed(11:0);
           Wcusiad        Char(40);
        End-DS;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n  ind;
           Pcusidn      char(15);
           pReturnDS    likeds(CumstDs);
        end-pi;

           clear pReturnDS;

           Exec SQL
              Select cuscun, cusidn, cuslgt, cusna1, cusph1, cusiad
                     into :pReturnDS
                     From Cumstl3 Where cusidn = :Pcusidn
              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetCnofcdescripcion
       // Objetivo: Busca codigo en el Cnofc y trae descripcion
       //           *on  = Retorna exitosamente
       //           *off = transacci?n no existe
       // Autor   : Francisco Martinez
       // Fecha   : Noviembre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetCnofcdescripcion export;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           Ptipo     char(2);
           Pcodigo   char(4);
           pdescrip  char(30);
        end-pi;

           Exec SQL
              Select cnodsc into :pdescrip
                 From CNOFC Where cnocfl = :Ptipo and cnorcd = :Pcodigo

              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : InsertMonitorPlus
       // Objetivo: Graba trasa de Monitor Plus
       //           *on  = Retorna exitosamente
       //           *off = Fallido
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc InsertMonitorPlus export;

         Dcl-Ds MonitorPlusDs qualified ;
            Mtflg             Char(1);
            MtAno             Zoned(4);
            MtMes             Zoned(2);
            MtDia             Zoned(2);
            MtHora            Zoned(6);
            MtEvto            Char(5);
            MtUser            Char(10);
            MtLong            Zoned(5);
            MtDato            Char(2000);
         End-Ds ;

        Dcl-PI *n ind;
           pReturnDS likeds(MonitorPlusDs);
        End-PI;

        dcl-s VResultados ind inz(*off);

        Exec SQL
           Insert into MNPSNDPLU Values(:pReturnDS) ;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetFieldsCuentaPreapertura
       // Objetivo: Busca cuenta y devuelve Campos del Wkacm
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Noviembre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetFieldsCuentaPreapertura export;

        Dcl-DS AcmstMpDs qualified ;
           Acmcun        Packed(9:0);
           acmopd        zoned(2:0);
           acmopm        zoned(2:0);
           acmopy        zoned(2:0);
           Acmbrn        Packed(3:0);
           acmuc1        Char(4);
        End-DS;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n ind;
           Pcuenta     zoned(12:0);
           pReturnDS   likeds(AcmstMpDs);
        end-pi;

           clear pReturnDS;

           Exec SQL
              Select Acmcun, acmopd, acmopm, acmopy, AcmBrn, acmuc1
                     into :pReturnDS
                     From Wkacm Where acmacc = :Pcuenta

              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : FieldsClienteCedula2
       // Objetivo: Busca Cliente por cedula y devuelve Campos del Cumst
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc FieldsClienteCedula2 export;

        Dcl-DS Cumst2Ds qualified ;
           Wcusidn        Char(15);
           Wcusna1        Char(45);
           WcusBuc        Char(4);
           WcusGrp        Packed(9:0);
           WcusOfc        Char(4);
           WcusOf2        Char(4);
           Wcusweb        Char(40);
           Wcuscun        Packed(9:0);
        End-DS;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n  ind;
           Pcusidn      char(15);
           pReturnDS    likeds(Cumst2Ds);
        end-pi;

           clear pReturnDS;

           Exec SQL
              Select CusIdn, CusNa1, CusBuc, CusGrp,
                     CusOfc, CusOf2, Cusweb, Cuscun
                     into :pReturnDS
                     From Cumstl3 Where cusidn = :Pcusidn
              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetCodigoCliente2
       // Objetivo: Busca Cliente por cliente y devuelve Campos del Cumst
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetCodigoCliente2 export;

        Dcl-DS Cumst2Ds qualified ;
           Wcusidn        Char(15);
           Wcusna1        Char(45);
           WcusBuc        Char(4);
           WcusGrp        Packed(9:0);
           WcusOfc        Char(4);
           WcusOf2        Char(4);
           Wcusweb        Char(40);
           Wcuscun        Packed(9:0);
        End-DS;

        dcl-s VResultados ind inz(*off);

        dcl-pi *n  ind;
           Pcuscun      Packed(9:0);
           pReturnDS    likeds(Cumst2Ds);
        end-pi;

           clear pReturnDS;

           Exec SQL
              Select CusIdn, CusNa1, CusBuc, CusGrp,
                     CusOfc, CusOf2, Cusweb, Cuscun
                     into :pReturnDS
                     From Cumst Where cuscun = :Pcuscun
              Fetch First 1 Row Only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetEuser
       // Objetivo: Busca Codigo del cliente en Euser y trae el usuario
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Octubre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetEuser export;

        Dcl-PI *n ind;
           Pcodcli     packed(9:0);
           Pusuario    char(10);
        End-PI;

           Exec SQL
           Select eususr into :Pusuario
             from Euser  Where Euscun = :Pcodcli

             Fetch first row only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetEuserOficial
       // Objetivo: Busca Codigo del oficial en Euser y trae el nombre
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Noviembre 2024
       //-----------------------------------------------------------------------
        Dcl-Proc GetEuserOficial export;

        Dcl-PI *n ind;
           Poficial    char(4);
           Pnombre     char(45);
        End-PI;

           Exec SQL
           Select Eupnme into :Pnombre
             From Cnteupl1 Where eupofc = :Poficial

             Fetch first row only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetCodigoMonPlus
       // Objetivo: Busca Codigo de transacción Monitor Plus y
       //           devuelve Descripcion
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio 2025
       //-----------------------------------------------------------------------
        Dcl-Proc GetCodigoMonPlus export;

        Dcl-DS MonitorDs qualified ;
           Wdescrptra     Char(100);
           Wbitacora      Char(2);
           Wcanalibs      Char(2);
           Wcanalapi      Char(2);
        End-DS;


        Dcl-PI *n ind;
           PcodigoPlus char(10);
           PreturnDs   likeds(MonitorDs);
        End-PI;

           clear pReturnDS;

           Exec SQL
           Select Descriptra, Bitacora, CanalIbs, CanalApi
             into :PreturnDs
             From Hucodmonpl Where Codigomp = :PcodigoPlus
             Fetch first row only;

           If SQLCODE= 0;
              VResultados = *On;
           else;
              MonitorDs.Wdescrptra = 'NO EXISTE TRANSACCION ' +
              PcodigoPlus + ' EN TABLA DE TRANSACCIONES MP' ;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetGrupoEconomico
       // Objetivo: Busca Descripcion de grupo economico con acmuc1
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio 2025
       //-----------------------------------------------------------------------
        Dcl-Proc GetGrupoEconomico export;

        dcl-s VResultados ind inz(*off);

        Dcl-PI *n ind;
           P1       zoned(9) ;
           PDescrip char(30);
        End-PI;

           Exec SQL
           Select Cusna1 into :PDescrip
                  From Cumst Where Cuscun = :p1
                  Fetch first row only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetFirmantes
       // Objetivo: Busca firmantes en el Cumad
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio 2025
       //-----------------------------------------------------------------------
        Dcl-Proc GetFirmantes export;

        dcl-s VResultados ind inz(*off);
        dcl-s i          zoned(2) inz;

        Dcl-DS CumadDs qualified ;
           Wcumrcn        zoned(9:0);
           Wcumma1        Char(45);
        End-DS;

        Dcl-PI *n ind;
           Pidn        char(15);
           P11         char(12);
           P12         char(30);
           P21         char(12);
           P22         char(30);
           P31         char(12);
           P32         char(30);
        End-PI;

         i = *zeros ;
         Exec SQL
             Declare Firmantes Cursor for
             select cumma1, cumrcn from cumad
             where cumrtp = 'Z' and cumbni = :Pidn;

         Exec Sql Open Firmantes ;

         Exec Sql Fetch Firmantes Into :CumadDs ;

         Dow SqlCod = *zeros;
             VResultados = *On;
             i += 1;
             Select;
               When i = 1;
                    P11 = CumadDs.Wcumma1;
                    P12 = %CHAR(CumadDs.Wcumrcn);
               When i = 2;
                    P21 = CumadDs.Wcumma1;
                    P22 = %CHAR(CumadDs.Wcumrcn);
               When i = 3;
                    P31 = CumadDs.Wcumma1;
                    P32 = %CHAR(CumadDs.Wcumrcn);
               Other;
                    Leave;
             Endsl;
             Exec Sql Fetch Firmantes Into :CumadDs ;
          Enddo;

          Exec Sql Close Firmantes ;

          return VResultados ;

        end-proc;

       //-----------------------------------------------------------------------
       // Modulo  : GetOficial
       // Objetivo: Busca Nombre de oficial principal y secundario
       //           *on  = Retorna exitosamente
       //           *off = Cuenta no existe
       //
       // Autor   : Francisco Martinez
       // Fecha   : Julio 2025
       //-----------------------------------------------------------------------
        Dcl-Proc GetOficial export;

        dcl-s VResultados ind inz(*off);

        Dcl-PI *n ind;
           P1       char(4) ;
           PDescrip char(30);
        End-PI;

           Exec SQL
           Select Eupnme into :PDescrip
           From Cnteupl1 Where EUPOFC = :p1
           Fetch first row only;

           If SQLCODE= 0;
              VResultados = *On;
           endif;

           return VResultados ;

        end-proc;
