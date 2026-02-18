METHOD RecvBytes : LINT
VAR_INPUT
    pData    : POINTER TO BYTE;
    liMaxLen : LINT;
END_VAR
VAR
    fdRead   : SOCKET_FD_SET;
    tv       : SOCKET_TIMEVAL;
    diReady  : DINT := 0;
    rtResult : RTS_IEC_RESULT := 0;
END_VAR

// === IMPLEMENTATION ===
diLastError := 0;
IF iSockSlot < 0 THEN
    diLastError := -5;
    RecvBytes := 0;
    RETURN;
END_IF;

// Avoid blocking task: recv only when socket is readable.
rtResult := SysSockFdZero(fdRead);
rtResult := SysSockFdInit(GVL_SlmpRuntime.g_aSockHandle[iSockSlot], fdRead);
tv.tv_sec := 0;
tv.tv_usec := 0;
diReady := 0;
rtResult := SysSockSelect(
    SOCKET_FD_SETSIZE,
    ADR(fdRead),
    0,
    0,
    ADR(tv),
    ADR(diReady)
);
IF (rtResult <> 0) OR (diReady <= 0) THEN
    RecvBytes := 0;
    RETURN;
END_IF;

RecvBytes := SysSockRecv(GVL_SlmpRuntime.g_aSockHandle[iSockSlot], pData, liMaxLen, 0, ADR(res));
IF RecvBytes <= 0 THEN
    diLastError := -5;
    RecvBytes := 0;
END_IF;

