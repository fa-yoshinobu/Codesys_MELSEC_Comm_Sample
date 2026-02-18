PROGRAM PLC_PRG_Example1
VAR
    fbReadWord    : FB_SlmpReadWordService;
    fbWriteWord   : FB_SlmpWriteWordService;
    fbReadBit     : FB_SlmpReadBitService;
    fbWriteBit    : FB_SlmpWriteBitService;
    fbReadPlcInfo : FB_SlmpReadPlcInfoService;
    fbCloseAll    : FB_SlmpCloseConnection;

    // Pulse these from HMI/debug (1-scan ON recommended)
    xTrigReadWord    : BOOL := FALSE;
    xTrigWriteWord   : BOOL := FALSE;
    xTrigReadBit     : BOOL := FALSE;
    xTrigWriteBit    : BOOL := FALSE;
    xTrigReadPlcInfo : BOOL := FALSE;
    xTrigCloseAll    : BOOL := FALSE;

    // Connection settings (PLC1)
    sTargetIp      : STRING := '192.168.3.10';
    uiTargetPort   : UINT := 4001;
    xUse4EFrame    : BOOL := TRUE;
    xUseUdpFrame   : BOOL := TRUE; // FALSE: TCP, TRUE: UDP
    uiFrameSerialNo: UINT := 1;

    // Write buffers
    aWriteWords : ARRAY[0..SLMP_MAX_WORD_INDEX] OF UINT;
    aWriteBits  : ARRAY[0..SLMP_MAX_BIT_INDEX] OF BOOL;

    // Monitor outputs
    xReadWordDone    : BOOL;
    xWriteWordDone   : BOOL;
    xReadBitDone     : BOOL;
    xWriteBitDone    : BOOL;
    xReadPlcInfoDone : BOOL;

    uiWordRead0 : UINT;
    uiWordRead1 : UINT;
    xBitRead0   : BOOL;
    xBitRead1   : BOOL;
    xBitRead2   : BOOL;
    xBitRead3   : BOOL;

    uiPlcTypeCodeMon : UINT;
    xPlcRunMon       : BOOL;
    xPlcStopMon      : BOOL;
    uiPlcModeMon     : UINT;
    sPlcTypeNameMon  : STRING(16);

    sLastErrorText : STRING;
END_VAR

// === IMPLEMENTATION ===
// Example write data
aWriteWords[0] := 16#1234;
aWriteWords[1] := 16#5678;

aWriteBits[0] := TRUE;
aWriteBits[1] := FALSE;
aWriteBits[2] := TRUE;
aWriteBits[3] := TRUE;
aWriteBits[4] := FALSE;
aWriteBits[5] := FALSE;
aWriteBits[6] := TRUE;
aWriteBits[7] := FALSE;

fbReadWord(
    xExecute := xTrigReadWord,
    sIp := sTargetIp,
    uiPort := uiTargetPort,
    udiHeadDevNo := 100,
    uiDeviceCode := SLMP_DEV_D,
    uiPoints := 4,
    tTimeout := T#2S,
    uiRetryMax := 2,
    tReconnectDelay := T#500MS,
    xUse4E := xUse4EFrame,
    xUseUdp := xUseUdpFrame,
    uiSerialNo := uiFrameSerialNo
);

fbWriteWord(
    xExecute := xTrigWriteWord,
    sIp := sTargetIp,
    uiPort := uiTargetPort,
    udiHeadDevNo := 200,
    uiDeviceCode := SLMP_DEV_D,
    uiPoints := 2,
    tTimeout := T#2S,
    uiRetryMax := 2,
    tReconnectDelay := T#500MS,
    xUse4E := xUse4EFrame,
    xUseUdp := xUseUdpFrame,
    uiSerialNo := uiFrameSerialNo,
    aWriteValues := aWriteWords
);

fbReadBit(
    xExecute := xTrigReadBit,
    sIp := sTargetIp,
    uiPort := uiTargetPort,
    udiHeadDevNo := 1000,
    uiDeviceCode := SLMP_DEV_M,
    uiPoints := 8,
    tTimeout := T#2S,
    uiRetryMax := 2,
    tReconnectDelay := T#500MS,
    xUse4E := xUse4EFrame,
    xUseUdp := xUseUdpFrame,
    uiSerialNo := uiFrameSerialNo
);

fbWriteBit(
    xExecute := xTrigWriteBit,
    sIp := sTargetIp,
    uiPort := uiTargetPort,
    udiHeadDevNo := 1000,
    uiDeviceCode := SLMP_DEV_M,
    uiPoints := 8,
    tTimeout := T#2S,
    uiRetryMax := 2,
    tReconnectDelay := T#500MS,
    xUse4E := xUse4EFrame,
    xUseUdp := xUseUdpFrame,
    uiSerialNo := uiFrameSerialNo,
    aWriteBits := aWriteBits
);

fbReadPlcInfo(
    xExecute := xTrigReadPlcInfo,
    sIp := sTargetIp,
    uiPort := uiTargetPort,
    tTimeout := T#2S,
    uiRetryMax := 2,
    tReconnectDelay := T#500MS,
    xUse4E := xUse4EFrame,
    xUseUdp := xUseUdpFrame,
    uiSerialNo := uiFrameSerialNo
);

fbCloseAll(
    xExecute := xTrigCloseAll
);

xReadWordDone := fbReadWord.xDone;
xWriteWordDone := fbWriteWord.xDone;
xReadBitDone := fbReadBit.xDone;
xWriteBitDone := fbWriteBit.xDone;
xReadPlcInfoDone := fbReadPlcInfo.xDone;

uiWordRead0 := fbReadWord.aReadValues[0];
uiWordRead1 := fbReadWord.aReadValues[1];
xBitRead0 := fbReadBit.aReadBits[0];
xBitRead1 := fbReadBit.aReadBits[1];
xBitRead2 := fbReadBit.aReadBits[2];
xBitRead3 := fbReadBit.aReadBits[3];
uiPlcTypeCodeMon := fbReadPlcInfo.uiPlcTypeCode;
xPlcRunMon := fbReadPlcInfo.xPlcRun;
xPlcStopMon := fbReadPlcInfo.xPlcStop;
uiPlcModeMon := fbReadPlcInfo.uiPlcMode;
sPlcTypeNameMon := fbReadPlcInfo.sPlcTypeName;

IF fbReadWord.xError THEN
    IF fbReadWord.diError >= 0 THEN
        sLastErrorText := F_SlmpEndCodeText(uiEndCode := TO_UINT(fbReadWord.diError));
    ELSE
        sLastErrorText := 'LOCAL_ERROR';
    END_IF;
ELSIF fbWriteWord.xError THEN
    IF fbWriteWord.diError >= 0 THEN
        sLastErrorText := F_SlmpEndCodeText(uiEndCode := TO_UINT(fbWriteWord.diError));
    ELSE
        sLastErrorText := 'LOCAL_ERROR';
    END_IF;
ELSIF fbReadBit.xError THEN
    IF fbReadBit.diError >= 0 THEN
        sLastErrorText := F_SlmpEndCodeText(uiEndCode := TO_UINT(fbReadBit.diError));
    ELSE
        sLastErrorText := 'LOCAL_ERROR';
    END_IF;
ELSIF fbWriteBit.xError THEN
    IF fbWriteBit.diError >= 0 THEN
        sLastErrorText := F_SlmpEndCodeText(uiEndCode := TO_UINT(fbWriteBit.diError));
    ELSE
        sLastErrorText := 'LOCAL_ERROR';
    END_IF;
ELSIF fbReadPlcInfo.xError THEN
    IF fbReadPlcInfo.diError >= 0 THEN
        sLastErrorText := F_SlmpEndCodeText(uiEndCode := TO_UINT(fbReadPlcInfo.diError));
    ELSE
        sLastErrorText := 'LOCAL_ERROR';
    END_IF;
END_IF;
