METHOD OpenAndConnect : BOOL
VAR_INPUT
    sIp    : STRING;
    uiPort : UINT;
    xUseUdp : BOOL := FALSE;
END_VAR
VAR
    iSlot  : INT;
    iFree  : INT;
END_VAR

// === IMPLEMENTATION ===
OpenAndConnect := FALSE;
diLastError := 0;

// Reuse already bound and connected slot for same destination.
IF iSockSlot >= 0 THEN
    IF GVL_SlmpRuntime.g_aSockConnected[iSockSlot] AND
       (GVL_SlmpRuntime.g_aSockIp[iSockSlot] = sIp) AND
       (GVL_SlmpRuntime.g_aSockPort[iSockSlot] = uiPort) AND
       (GVL_SlmpRuntime.g_aSockUseUdp[iSockSlot] = xUseUdp) THEN
        OpenAndConnect := TRUE;
        RETURN;
    END_IF;
    iSockSlot := -1;
END_IF;

// Find existing connected slot for destination, or a free slot.
iFree := -1;
FOR iSlot := 0 TO 7 DO
    IF GVL_SlmpRuntime.g_aSockConnected[iSlot] AND
       (GVL_SlmpRuntime.g_aSockIp[iSlot] = sIp) AND
       (GVL_SlmpRuntime.g_aSockPort[iSlot] = uiPort) AND
       (GVL_SlmpRuntime.g_aSockUseUdp[iSlot] = xUseUdp) THEN
        iSockSlot := iSlot;
        OpenAndConnect := TRUE;
        RETURN;
    END_IF;

    IF (iFree < 0) AND (NOT GVL_SlmpRuntime.g_aSockConnected[iSlot]) THEN
        iFree := iSlot;
    END_IF;
END_FOR;

IF iFree < 0 THEN
    diLastError := -6; // no free shared socket slot
    RETURN;
END_IF;

IF xUseUdp THEN
    GVL_SlmpRuntime.g_aSockHandle[iFree] := SysSockCreate(SOCKET_AF_INET, SOCKET_DGRAM, SOCKET_IPPROTO_UDP, ADR(res));
ELSE
    GVL_SlmpRuntime.g_aSockHandle[iFree] := SysSockCreate(SOCKET_AF_INET, SOCKET_STREAM, SOCKET_IPPROTO_IP, ADR(res));
END_IF;
IF GVL_SlmpRuntime.g_aSockHandle[iFree] = RTS_INVALID_HANDLE THEN
    diLastError := -1;
    RETURN;
END_IF;

liRet := SysSockInetAddr(sIp, ADR(ipAddr));
IF liRet <> 0 THEN
    diLastError := -2;
    SysSockClose(GVL_SlmpRuntime.g_aSockHandle[iFree]);
    GVL_SlmpRuntime.g_aSockHandle[iFree] := RTS_INVALID_HANDLE;
    RETURN;
END_IF;

sa.sin_family := SOCKET_AF_INET;
sa.sin_port := SysSockHtons(uiPort);
sa.sin_addr := ipAddr;

liRet := SysSockConnect(GVL_SlmpRuntime.g_aSockHandle[iFree], ADR(sa), SIZEOF(sa));
IF liRet <> 0 THEN
    diLastError := -3;
    SysSockClose(GVL_SlmpRuntime.g_aSockHandle[iFree]);
    GVL_SlmpRuntime.g_aSockHandle[iFree] := RTS_INVALID_HANDLE;
    RETURN;
END_IF;

GVL_SlmpRuntime.g_aSockConnected[iFree] := TRUE;
GVL_SlmpRuntime.g_aSockIp[iFree] := sIp;
GVL_SlmpRuntime.g_aSockPort[iFree] := uiPort;
GVL_SlmpRuntime.g_aSockUseUdp[iFree] := xUseUdp;
iSockSlot := iFree;
OpenAndConnect := TRUE;

