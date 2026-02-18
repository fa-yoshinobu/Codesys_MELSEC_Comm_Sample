FUNCTION_BLOCK FB_SlmpWriteBitService
VAR_INPUT
    xExecute        : BOOL;
    sIp             : STRING;
    uiPort          : UINT;
    udiHeadDevNo    : UDINT;
    uiDeviceCode    : UINT;
    uiPoints        : UINT;
    tTimeout        : TIME := T#2S;
    uiRetryMax      : UINT := 2;
    tReconnectDelay : TIME := T#500MS;
    xUse4E          : BOOL := FALSE;
    xUseUdp         : BOOL := FALSE;
    uiSerialNo      : UINT := 1;
END_VAR
VAR_IN_OUT
    aWriteBits      : ARRAY[0..SLMP_MAX_BIT_INDEX] OF BOOL;
END_VAR
VAR_OUTPUT
    xBusy           : BOOL;
    xDone           : BOOL;
    xError          : BOOL;
    diError         : DINT;
    uiRetryCount    : UINT;
    aLastResponse   : ARRAY[0..SLMP_LAST_RESPONSE_INDEX_MAX] OF BYTE;
    uiLastResponseLen : UINT;
    uiLastEndCode   : UINT;
END_VAR
VAR
    fbWriteBit      : FB_SlmpWriteBitDevice;
    udInstanceId    : UDINT := 0;

    xExecPrev       : BOOL := FALSE;
    xPending        : BOOL := FALSE;
    xActive         : BOOL := FALSE;
    xExecPulse      : BOOL := FALSE;
    iLockIdx        : INT := -1;

    udiHeadLatched  : UDINT := 0;
    uiDeviceLatched : UINT := 0;
    uiPointsLatched : UINT := 0;
    uiSerialActive  : UINT := 0;
    aWriteLatched   : ARRAY[0..SLMP_MAX_BIT_INDEX] OF BOOL;

    idx             : UINT;
    uiSerialEff     : UINT;
    iSlot           : INT;
    iFreeSlot       : INT;
    xLocked         : BOOL;
END_VAR

// === IMPLEMENTATION ===
IF udInstanceId = 0 THEN
    GVL_SlmpRuntime.g_udServiceInstanceCounter := GVL_SlmpRuntime.g_udServiceInstanceCounter + 1;
    udInstanceId := GVL_SlmpRuntime.g_udServiceInstanceCounter;
    IF udInstanceId = 0 THEN
        udInstanceId := 1;
    END_IF;
END_IF;

IF xExecute AND (NOT xExecPrev) THEN
    IF (NOT xPending) AND (NOT xActive) THEN
        udiHeadLatched := udiHeadDevNo;
        uiDeviceLatched := uiDeviceCode;
        uiPointsLatched := uiPoints;
        FOR idx := 0 TO SLMP_MAX_BIT_INDEX DO
            aWriteLatched[idx] := aWriteBits[idx];
        END_FOR;
        xDone := FALSE;
        xError := FALSE;
        diError := 0;
        uiRetryCount := 0;
        xPending := TRUE;
    END_IF;
END_IF;
xExecPrev := xExecute;

xExecPulse := FALSE;
IF xPending AND (NOT xActive) THEN
    xLocked := FALSE;
    iFreeSlot := -1;
    FOR iSlot := 0 TO 7 DO
        IF (GVL_SlmpRuntime.g_aLockOwner[iSlot] <> 0) AND
           (GVL_SlmpRuntime.g_aLockIp[iSlot] = sIp) AND
           (GVL_SlmpRuntime.g_aLockPort[iSlot] = uiPort) AND
           (GVL_SlmpRuntime.g_aLockUseUdp[iSlot] = xUseUdp) THEN
            xLocked := TRUE;
            EXIT;
        END_IF;
        IF (iFreeSlot < 0) AND (GVL_SlmpRuntime.g_aLockOwner[iSlot] = 0) THEN
            iFreeSlot := iSlot;
        END_IF;
    END_FOR;

    IF (NOT xLocked) AND (iFreeSlot >= 0) THEN
        GVL_SlmpRuntime.g_aLockOwner[iFreeSlot] := udInstanceId;
        GVL_SlmpRuntime.g_aLockIp[iFreeSlot] := sIp;
        GVL_SlmpRuntime.g_aLockPort[iFreeSlot] := uiPort;
        GVL_SlmpRuntime.g_aLockUseUdp[iFreeSlot] := xUseUdp;
        iLockIdx := iFreeSlot;

        xActive := TRUE;
        xExecPulse := TRUE;
        IF xUse4E THEN
            uiSerialActive := F_SlmpNextSerialNo(uiSeed := uiSerialNo);
        END_IF;
    END_IF;
END_IF;

IF xActive THEN
    IF xUse4E THEN
        uiSerialEff := uiSerialActive;
        IF uiSerialEff = 0 THEN
            uiSerialEff := 1;
        END_IF;
    ELSE
        uiSerialEff := uiSerialNo;
    END_IF;

    fbWriteBit(
        xExecute := xExecPulse,
        sIp := sIp,
        uiPort := uiPort,
        udiHeadDevNo := udiHeadLatched,
        uiDeviceCode := uiDeviceLatched,
        xAutoSubCommand := TRUE,
        uiSubCommand := 0,
        uiPoints := uiPointsLatched,
        aWriteBits := aWriteLatched,
        tTimeout := tTimeout,
        uiRetryMax := uiRetryMax,
        tReconnectDelay := tReconnectDelay,
        xUse4E := xUse4E,
        xUseUdp := xUseUdp,
        uiSerialNo := uiSerialEff
    );
ELSE
    xBusy := xPending;
    IF NOT xExecute THEN
        xDone := FALSE;
        xError := FALSE;
        diError := 0;
        uiRetryCount := 0;
    END_IF;
    RETURN;
END_IF;

xBusy := fbWriteBit.xBusy;
xDone := fbWriteBit.xDone;
xError := fbWriteBit.xError;
diError := fbWriteBit.diError;
uiRetryCount := fbWriteBit.uiRetryCount;
FOR idx := 0 TO SLMP_LAST_RESPONSE_INDEX_MAX DO
    aLastResponse[idx] := fbWriteBit.aLastResponse[idx];
END_FOR;
uiLastResponseLen := fbWriteBit.uiLastResponseLen;
uiLastEndCode := fbWriteBit.uiLastEndCode;

IF fbWriteBit.xDone OR fbWriteBit.xError THEN
    xPending := FALSE;
    xActive := FALSE;
    IF iLockIdx >= 0 THEN
        GVL_SlmpRuntime.g_aLockOwner[iLockIdx] := 0;
        GVL_SlmpRuntime.g_aLockIp[iLockIdx] := '';
        GVL_SlmpRuntime.g_aLockPort[iLockIdx] := 0;
        GVL_SlmpRuntime.g_aLockUseUdp[iLockIdx] := FALSE;
        iLockIdx := -1;
    END_IF;
END_IF;
