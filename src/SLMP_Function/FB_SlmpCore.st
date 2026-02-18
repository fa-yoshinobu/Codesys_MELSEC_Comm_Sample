FUNCTION_BLOCK FB_SlmpCore
VAR_OUTPUT
    diLastError : DINT;
END_VAR
VAR
    iSockSlot      : INT := -1;
    res            : RTS_IEC_RESULT := 0;
    sa             : SOCKADDRESS_IN;
    ipAddr         : UDINT := 0;
    liRet          : LINT := 0;
END_VAR
