VAR_GLOBAL
    g_uiSlmpSerialCounter : UINT := 0;
    g_udServiceInstanceCounter : UDINT := 0;
    g_aLockOwner : ARRAY[0..7] OF UDINT := [0,0,0,0,0,0,0,0];
    g_aLockIp : ARRAY[0..7] OF STRING := ['','','','','','','',''];
    g_aLockPort : ARRAY[0..7] OF UINT := [0,0,0,0,0,0,0,0];
    g_aLockUseUdp : ARRAY[0..7] OF BOOL := [FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];

    g_aSockHandle : ARRAY[0..7] OF RTS_IEC_HANDLE := [
        RTS_INVALID_HANDLE, RTS_INVALID_HANDLE, RTS_INVALID_HANDLE, RTS_INVALID_HANDLE,
        RTS_INVALID_HANDLE, RTS_INVALID_HANDLE, RTS_INVALID_HANDLE, RTS_INVALID_HANDLE
    ];
    g_aSockConnected : ARRAY[0..7] OF BOOL := [FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];
    g_aSockIp : ARRAY[0..7] OF STRING := ['','','','','','','',''];
    g_aSockPort : ARRAY[0..7] OF UINT := [0,0,0,0,0,0,0,0];
    g_aSockUseUdp : ARRAY[0..7] OF BOOL := [FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];

    g_aLastTx : ARRAY[0..SLMP_WRITE_TX_INDEX_MAX] OF BYTE := [0];
    g_uiLastTxLen : UINT := 0;
    g_iLastTxSockSlot : INT := -1;
END_VAR
