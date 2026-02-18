METHOD CloseSocket

// === IMPLEMENTATION ===

IF iSockSlot < 0 THEN
    RETURN;
END_IF;

IF GVL_SlmpRuntime.g_aSockHandle[iSockSlot] <> RTS_INVALID_HANDLE THEN
    SysSockClose(GVL_SlmpRuntime.g_aSockHandle[iSockSlot]);
    GVL_SlmpRuntime.g_aSockHandle[iSockSlot] := RTS_INVALID_HANDLE;
END_IF;
GVL_SlmpRuntime.g_aSockConnected[iSockSlot] := FALSE;
GVL_SlmpRuntime.g_aSockIp[iSockSlot] := '';
GVL_SlmpRuntime.g_aSockPort[iSockSlot] := 0;
GVL_SlmpRuntime.g_aSockUseUdp[iSockSlot] := FALSE;
iSockSlot := -1;
