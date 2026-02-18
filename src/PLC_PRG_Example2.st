PROGRAM PLC_PRG_Example
VAR
    fbWriteWordPlc1 : FB_SlmpWriteWordService;
    fbWriteWordPlc2 : FB_SlmpWriteWordService;
    fbWriteWordPlc3 : FB_SlmpWriteWordService;
    fbWriteWordPlc4 : FB_SlmpWriteWordService;

    xEnableWritePlc1 : BOOL := TRUE;
    xEnableWritePlc2 : BOOL := TRUE;
    xEnableWritePlc3 : BOOL := TRUE;
    xEnableWritePlc4 : BOOL := TRUE;

    xTrigWritePlc1 : BOOL;
    xTrigWritePlc2 : BOOL;
    xTrigWritePlc3 : BOOL;
    xTrigWritePlc4 : BOOL;

    xWriteBusyPlc1 : BOOL;
    xWriteBusyPlc2 : BOOL;
    xWriteBusyPlc3 : BOOL;
    xWriteBusyPlc4 : BOOL;

    xWriteDonePlc1 : BOOL;
    xWriteDonePlc2 : BOOL;
    xWriteDonePlc3 : BOOL;
    xWriteDonePlc4 : BOOL;

    xWriteErrorPlc1 : BOOL;
    xWriteErrorPlc2 : BOOL;
    xWriteErrorPlc3 : BOOL;
    xWriteErrorPlc4 : BOOL;

    diWriteErrorPlc1 : DINT;
    diWriteErrorPlc2 : DINT;
    diWriteErrorPlc3 : DINT;
    diWriteErrorPlc4 : DINT;

    sLastErrorText  : STRING;

    sTargetIpPlc1    : STRING := '192.168.3.10';
    uiTargetPortPlc1 : UINT := 4001;
    sTargetIpPlc2    : STRING := '192.168.3.11';
    uiTargetPortPlc2 : UINT := 4001;
    sTargetIpPlc3    : STRING := '192.168.3.12';
    uiTargetPortPlc3 : UINT := 4001;
    sTargetIpPlc4    : STRING := '192.168.3.13';
    uiTargetPortPlc4 : UINT := 4001;

    xUse4EFrame      : BOOL := TRUE;
    xUseUdpFrame     : BOOL := TRUE; // FALSE: TCP, TRUE: UDP
    uiFrameSerialNo  : UINT := 1;

    aWriteWords      : ARRAY[0..SLMP_MAX_WORD_INDEX] OF UINT;
    udRandState      : UDINT := 16#12345678;
    uiIdx            : UINT;
END_VAR

// === IMPLEMENTATION ===
// Generate random data for 100 words (D0..D99) every scan.
FOR uiIdx := 0 TO 99 DO
    udRandState := udRandState * 1664525 + 1013904223;
    aWriteWords[uiIdx] := TO_UINT(udRandState AND 16#0000FFFF);
END_FOR;

// Do not retrigger while busy. Re-run after done or error.
xTrigWritePlc1 := xEnableWritePlc1 AND (NOT fbWriteWordPlc1.xBusy);
xTrigWritePlc2 := xEnableWritePlc2 AND (NOT fbWriteWordPlc2.xBusy);
xTrigWritePlc3 := xEnableWritePlc3 AND (NOT fbWriteWordPlc3.xBusy);
xTrigWritePlc4 := xEnableWritePlc4 AND (NOT fbWriteWordPlc4.xBusy);

fbWriteWordPlc1(
    xExecute := xTrigWritePlc1,
    sIp := sTargetIpPlc1,
    uiPort := uiTargetPortPlc1,
    udiHeadDevNo := 0,
    uiDeviceCode := SLMP_DEV_D,
    uiPoints := 100,
    tTimeout := T#2S,
    uiRetryMax := 2,
    tReconnectDelay := T#500MS,
    xUse4E := xUse4EFrame,
    xUseUdp := xUseUdpFrame,
    uiSerialNo := uiFrameSerialNo,
    aWriteValues := aWriteWords
);

fbWriteWordPlc2(
    xExecute := xTrigWritePlc2,
    sIp := sTargetIpPlc2,
    uiPort := uiTargetPortPlc2,
    udiHeadDevNo := 0,
    uiDeviceCode := SLMP_DEV_D,
    uiPoints := 100,
    tTimeout := T#2S,
    uiRetryMax := 2,
    tReconnectDelay := T#500MS,
    xUse4E := xUse4EFrame,
    xUseUdp := xUseUdpFrame,
    uiSerialNo := uiFrameSerialNo,
    aWriteValues := aWriteWords
);

fbWriteWordPlc3(
    xExecute := xTrigWritePlc3,
    sIp := sTargetIpPlc3,
    uiPort := uiTargetPortPlc3,
    udiHeadDevNo := 0,
    uiDeviceCode := SLMP_DEV_D,
    uiPoints := 100,
    tTimeout := T#2S,
    uiRetryMax := 2,
    tReconnectDelay := T#500MS,
    xUse4E := xUse4EFrame,
    xUseUdp := xUseUdpFrame,
    uiSerialNo := uiFrameSerialNo,
    aWriteValues := aWriteWords
);

fbWriteWordPlc4(
    xExecute := xTrigWritePlc4,
    sIp := sTargetIpPlc4,
    uiPort := uiTargetPortPlc4,
    udiHeadDevNo := 0,
    uiDeviceCode := SLMP_DEV_D,
    uiPoints := 100,
    tTimeout := T#2S,
    uiRetryMax := 2,
    tReconnectDelay := T#500MS,
    xUse4E := xUse4EFrame,
    xUseUdp := xUseUdpFrame,
    uiSerialNo := uiFrameSerialNo,
    aWriteValues := aWriteWords
);

xWriteBusyPlc1 := fbWriteWordPlc1.xBusy;
xWriteBusyPlc2 := fbWriteWordPlc2.xBusy;
xWriteBusyPlc3 := fbWriteWordPlc3.xBusy;
xWriteBusyPlc4 := fbWriteWordPlc4.xBusy;

xWriteDonePlc1 := fbWriteWordPlc1.xDone;
xWriteDonePlc2 := fbWriteWordPlc2.xDone;
xWriteDonePlc3 := fbWriteWordPlc3.xDone;
xWriteDonePlc4 := fbWriteWordPlc4.xDone;

xWriteErrorPlc1 := fbWriteWordPlc1.xError;
xWriteErrorPlc2 := fbWriteWordPlc2.xError;
xWriteErrorPlc3 := fbWriteWordPlc3.xError;
xWriteErrorPlc4 := fbWriteWordPlc4.xError;

diWriteErrorPlc1 := fbWriteWordPlc1.diError;
diWriteErrorPlc2 := fbWriteWordPlc2.diError;
diWriteErrorPlc3 := fbWriteWordPlc3.diError;
diWriteErrorPlc4 := fbWriteWordPlc4.diError;

IF xWriteErrorPlc1 THEN
    IF diWriteErrorPlc1 >= 0 THEN
        sLastErrorText := F_SlmpEndCodeText(uiEndCode := TO_UINT(diWriteErrorPlc1));
    ELSE
        sLastErrorText := 'LOCAL_ERROR';
    END_IF;
ELSIF xWriteErrorPlc2 THEN
    IF diWriteErrorPlc2 >= 0 THEN
        sLastErrorText := F_SlmpEndCodeText(uiEndCode := TO_UINT(diWriteErrorPlc2));
    ELSE
        sLastErrorText := 'LOCAL_ERROR';
    END_IF;
ELSIF xWriteErrorPlc3 THEN
    IF diWriteErrorPlc3 >= 0 THEN
        sLastErrorText := F_SlmpEndCodeText(uiEndCode := TO_UINT(diWriteErrorPlc3));
    ELSE
        sLastErrorText := 'LOCAL_ERROR';
    END_IF;
ELSIF xWriteErrorPlc4 THEN
    IF diWriteErrorPlc4 >= 0 THEN
        sLastErrorText := F_SlmpEndCodeText(uiEndCode := TO_UINT(diWriteErrorPlc4));
    ELSE
        sLastErrorText := 'LOCAL_ERROR';
    END_IF;
END_IF;
