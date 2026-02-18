TYPE SOCKADDRESS_IN :

STRUCT
    sin_family : INT;
    sin_port   : UINT;
    sin_addr   : UDINT;
    sin_zero   : ARRAY[0..7] OF BYTE;
END_STRUCT
END_TYPE
