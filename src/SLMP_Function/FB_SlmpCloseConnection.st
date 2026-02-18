FUNCTION_BLOCK FB_SlmpCloseConnection
VAR_INPUT
    xExecute : BOOL;
END_VAR
VAR_OUTPUT
    xDone    : BOOL;
END_VAR
VAR
    xExecPrev : BOOL := FALSE;
    iSlot     : INT := 0;
END_VAR

// === IMPLEMENTATION ===
xDone := FALSE;

IF xExecute AND (NOT xExecPrev) THEN
    FOR iSlot := 0 TO 7 DO
        IF GVL_SlmpRuntime.g_aSockHandle[iSlot] <> RTS_INVALID_HANDLE THEN
            SysSockClose(GVL_SlmpRuntime.g_aSockHandle[iSlot]);
            GVL_SlmpRuntime.g_aSockHandle[iSlot] := RTS_INVALID_HANDLE;
        END_IF;
        GVL_SlmpRuntime.g_aSockConnected[iSlot] := FALSE;
        GVL_SlmpRuntime.g_aSockIp[iSlot] := '';
        GVL_SlmpRuntime.g_aSockPort[iSlot] := 0;
        GVL_SlmpRuntime.g_aSockUseUdp[iSlot] := FALSE;

        GVL_SlmpRuntime.g_aLockOwner[iSlot] := 0;
        GVL_SlmpRuntime.g_aLockIp[iSlot] := '';
        GVL_SlmpRuntime.g_aLockPort[iSlot] := 0;
        GVL_SlmpRuntime.g_aLockUseUdp[iSlot] := FALSE;
    END_FOR;
    xDone := TRUE;
END_IF;

xExecPrev := xExecute;
