FUNCTION_BLOCK FB_SlmpReadDWordDevice
VAR_INPUT
    xExecute         : BOOL;
    sIp              : STRING;
    uiPort           : UINT;
    udiHeadDevNo     : UDINT := 0;
    uiDeviceCode     : UINT := 16#00C2; // LTN
    uiPoints         : UINT := 1; // number of 2-word points
    tTimeout         : TIME := T#2S;
    uiRetryMax       : UINT := 2;
    tReconnectDelay  : TIME := T#500MS;
    xUse4E           : BOOL := FALSE;
    xUseUdp          : BOOL := FALSE;
    uiSerialNo       : UINT := 0;
END_VAR
VAR_OUTPUT
    xBusy            : BOOL;
    xDone            : BOOL;
    xError           : BOOL;
    diError          : DINT;
    uiRetryCount     : UINT;
    uiReadPoints     : UINT; // number of 2-word points
    udiValue0        : UDINT;
    aReadDWords      : ARRAY[0..SLMP_MAX_WORD_INDEX] OF UDINT;
    aLastResponse    : ARRAY[0..SLMP_LAST_RESPONSE_INDEX_MAX] OF BYTE;
    uiLastResponseLen: UINT;
    uiLastEndCode    : UINT;
END_VAR
VAR
    fbReadWord       : FB_SlmpReadWordDevice;
    uiPointsEff      : UINT := 0;
    idx              : UINT := 0;
    udiLow           : UDINT := 0;
    udiHigh          : UDINT := 0;
END_VAR

// === IMPLEMENTATION ===
uiPointsEff := uiPoints;
IF uiPointsEff > (SLMP_MAX_WORD_POINTS / 2) THEN
    uiPointsEff := SLMP_MAX_WORD_POINTS / 2;
END_IF;

fbReadWord(
    xExecute := xExecute,
    sIp := sIp,
    uiPort := uiPort,
    udiHeadDevNo := udiHeadDevNo,
    uiDeviceCode := uiDeviceCode,
    xAutoSubCommand := FALSE,
    uiSubCommand := SLMP_SUB_WORD2,
    uiPoints := uiPointsEff,
    tTimeout := tTimeout,
    uiRetryMax := uiRetryMax,
    tReconnectDelay := tReconnectDelay,
    xUse4E := xUse4E,
    xUseUdp := xUseUdp,
    uiSerialNo := uiSerialNo
);

xBusy := fbReadWord.xBusy;
xDone := fbReadWord.xDone;
xError := fbReadWord.xError;
diError := fbReadWord.diError;
uiRetryCount := fbReadWord.uiRetryCount;
uiLastResponseLen := fbReadWord.uiLastResponseLen;
uiLastEndCode := fbReadWord.uiLastEndCode;
FOR idx := 0 TO SLMP_LAST_RESPONSE_INDEX_MAX DO
    aLastResponse[idx] := fbReadWord.aLastResponse[idx];
END_FOR;

IF fbReadWord.xDone THEN
    uiReadPoints := uiPointsEff;
    FOR idx := 0 TO (uiPointsEff - 1) DO
        udiLow := TO_UDINT(fbReadWord.aValues[idx * 2]);
        udiHigh := TO_UDINT(fbReadWord.aValues[idx * 2 + 1]);
        aReadDWords[idx] := udiLow OR SHL(udiHigh, 16);
    END_FOR;
    IF uiPointsEff > 0 THEN
        udiValue0 := aReadDWords[0];
    END_IF;
END_IF;
