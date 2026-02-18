FUNCTION_BLOCK FB_SlmpWriteDWordDevice
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
VAR_IN_OUT
    aWriteDWords     : ARRAY[0..SLMP_MAX_WORD_INDEX] OF UDINT;
END_VAR
VAR_OUTPUT
    xBusy            : BOOL;
    xDone            : BOOL;
    xError           : BOOL;
    diError          : DINT;
    uiRetryCount     : UINT;
    aLastResponse    : ARRAY[0..SLMP_LAST_RESPONSE_INDEX_MAX] OF BYTE;
    uiLastResponseLen: UINT;
    uiLastEndCode    : UINT;
END_VAR
VAR
    fbWriteWord      : FB_SlmpWriteWordDevice;
    aWriteWordsLocal : ARRAY[0..SLMP_MAX_WORD_INDEX] OF UINT;
    uiPointsEff      : UINT := 0;
    idx              : UINT := 0;
END_VAR

// === IMPLEMENTATION ===
uiPointsEff := uiPoints;
IF uiPointsEff > (SLMP_MAX_WORD_POINTS / 2) THEN
    uiPointsEff := SLMP_MAX_WORD_POINTS / 2;
END_IF;

FOR idx := 0 TO (uiPointsEff - 1) DO
    aWriteWordsLocal[idx * 2] := TO_UINT(aWriteDWords[idx] AND 16#0000FFFF);
    aWriteWordsLocal[idx * 2 + 1] := TO_UINT(SHR(aWriteDWords[idx], 16) AND 16#0000FFFF);
END_FOR;

fbWriteWord(
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
    uiSerialNo := uiSerialNo,
    aWriteValues := aWriteWordsLocal
);

xBusy := fbWriteWord.xBusy;
xDone := fbWriteWord.xDone;
xError := fbWriteWord.xError;
diError := fbWriteWord.diError;
uiRetryCount := fbWriteWord.uiRetryCount;
uiLastResponseLen := fbWriteWord.uiLastResponseLen;
uiLastEndCode := fbWriteWord.uiLastEndCode;
FOR idx := 0 TO SLMP_LAST_RESPONSE_INDEX_MAX DO
    aLastResponse[idx] := fbWriteWord.aLastResponse[idx];
END_FOR;
