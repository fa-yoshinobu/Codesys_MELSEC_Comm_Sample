METHOD SendBytes : BOOL
VAR_INPUT
    pData : POINTER TO BYTE;
    liLen : LINT;
END_VAR
VAR
    uiCopyLen : UINT := 0;
    idx       : UINT := 0;
END_VAR

// === IMPLEMENTATION ===
SendBytes := FALSE;
diLastError := 0;

IF iSockSlot < 0 THEN
    diLastError := -4;
    RETURN;
END_IF;

GVL_SlmpRuntime.g_iLastTxSockSlot := iSockSlot;
GVL_SlmpRuntime.g_uiLastTxLen := 0;
IF liLen > 0 THEN
    IF liLen > TO_LINT(SLMP_WRITE_TX_INDEX_MAX + 1) THEN
        uiCopyLen := SLMP_WRITE_TX_INDEX_MAX + 1;
    ELSE
        uiCopyLen := TO_UINT(liLen);
    END_IF;
    GVL_SlmpRuntime.g_uiLastTxLen := uiCopyLen;
    FOR idx := 0 TO (uiCopyLen - 1) DO
        GVL_SlmpRuntime.g_aLastTx[idx] := pData[idx];
    END_FOR;
END_IF;

liRet := SysSockSend(GVL_SlmpRuntime.g_aSockHandle[iSockSlot], pData, liLen, 0, ADR(res));
IF liRet <= 0 THEN
    diLastError := -4;
    CloseSocket();
    RETURN;
END_IF;

SendBytes := TRUE;

