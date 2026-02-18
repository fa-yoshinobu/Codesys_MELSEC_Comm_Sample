FUNCTION_BLOCK FB_SlmpWriteBitDevice
VAR_INPUT
    xExecute         : BOOL;
    sIp              : STRING;
    uiPort           : UINT;
    udiHeadDevNo     : UDINT := 100;
    uiDeviceCode     : UINT := 16#0090; // M
    xAutoSubCommand  : BOOL := TRUE;
    uiSubCommand     : UINT := 16#0001;
    uiPoints         : UINT := 1;
    aWriteBits       : ARRAY[0..SLMP_MAX_BIT_INDEX] OF BOOL;
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
    aLastResponse    : ARRAY[0..SLMP_LAST_RESPONSE_INDEX_MAX] OF BYTE;
    uiLastResponseLen: UINT;
    uiLastEndCode    : UINT;
END_VAR
VAR
    step             : INT := 0;
    xExecPrev        : BOOL := FALSE;

    fbCore           : FB_SlmpCore;

    tx               : ARRAY[0..SLMP_WRITE_TX_INDEX_MAX] OF BYTE;
    rx               : ARRAY[0..SLMP_LAST_RESPONSE_INDEX_MAX] OF BYTE;
    txLen            : LINT := 0;
    rxLen            : LINT := 0;
    lenReq           : UINT := 0;
    endCode          : UINT := 0;

    uiPointsReq      : UINT := 0;
    uiPointsEff      : UINT := 0;
    uiSubCmdEff      : UINT := 0;
    idx              : UINT := 0;
    iDataStart       : DINT := 21;
    iEndCodeStart    : DINT := 9;
    iMinRxLen        : LINT := 11;
    uiRxSerialNo     : UINT := 0;
    uiCopyLen        : UINT := 0;
    iPayloadBytes    : LINT := 0;
    iByteOffset      : DINT := 0;

    xStateTimeout    : BOOL := FALSE;
    xRetryTiming     : BOOL := FALSE;
    fbTimeout        : TON;
    fbReconnect      : TON;
END_VAR

// === IMPLEMENTATION ===
IF (xExecute AND NOT xExecPrev) THEN
    xBusy := TRUE;
    xDone := FALSE;
    xError := FALSE;
    diError := 0;
    uiRetryCount := 0;
    uiLastResponseLen := 0;
    uiLastEndCode := 0;
    FOR idx := 0 TO SLMP_LAST_RESPONSE_INDEX_MAX DO
        aLastResponse[idx] := 0;
    END_FOR;
    step := 10;
END_IF;
xExecPrev := xExecute;

xStateTimeout := (step = 20) OR (step = 40) OR (step = 50);
fbTimeout(IN := xStateTimeout, PT := tTimeout);
fbReconnect(IN := xRetryTiming, PT := tReconnectDelay);

IF (step <> 0) AND (step <> 80) AND fbTimeout.Q THEN
    diError := -2010;
    xError := TRUE;
    step := 90;
END_IF;

CASE step OF
    0:
        xRetryTiming := FALSE;

    10:
        uiSubCmdEff := F_SlmpResolveSubCommand(
            uiDeviceCode := uiDeviceCode,
            xAutoSubCommand := xAutoSubCommand,
            uiSubCommand := uiSubCommand
        );

        uiPointsReq := uiPoints;
        IF uiPointsReq = 0 THEN
            diError := -2000;
            xError := TRUE;
            xBusy := FALSE;
            step := 0;
        ELSE
            uiPointsEff := F_SlmpClampPoints(uiPoints := uiPointsReq, xBitMode := TRUE);
        END_IF;

        IF NOT xError THEN
            step := 20;
        END_IF;

    20:
        IF fbCore.OpenAndConnect(sIp := sIp, uiPort := uiPort, xUseUdp := xUseUdp) THEN
            step := 30;
        ELSE
            CASE fbCore.diLastError OF
                -1: diError := -2001;
                -2: diError := -2005;
                -3: diError := -2002;
            ELSE
                diError := -2002;
            END_CASE;
            xError := TRUE;
            step := 90;
        END_IF;

    30:
        IF xUse4E THEN
            iDataStart := 25;
            iEndCodeStart := 13;
            iMinRxLen := 15;
        ELSE
            iDataStart := 21;
            iEndCodeStart := 9;
            iMinRxLen := 11;
        END_IF;

        iPayloadBytes := TO_LINT((uiPointsEff + 1) / 2);
        lenReq := TO_UINT(12 + TO_UINT(iPayloadBytes));

        IF xUse4E THEN
            tx[0] := 16#54; tx[1] := 16#00;
            tx[2] := TO_BYTE(uiSerialNo AND 16#00FF);
            tx[3] := TO_BYTE(SHR(uiSerialNo, 8) AND 16#00FF);
            tx[4] := 16#00; tx[5] := 16#00;
            tx[6] := 16#00;
            tx[7] := 16#FF;
            tx[8] := 16#FF; tx[9] := 16#03;
            tx[10] := 16#00;
            tx[11] := TO_BYTE(lenReq AND 16#00FF);
            tx[12] := TO_BYTE(SHR(lenReq, 8) AND 16#00FF);
            tx[13] := 16#10; tx[14] := 16#00;
            tx[15] := 16#01; tx[16] := 16#14;
            tx[17] := TO_BYTE(uiSubCmdEff AND 16#00FF);
            tx[18] := TO_BYTE(SHR(uiSubCmdEff, 8) AND 16#00FF);
            tx[19] := TO_BYTE(udiHeadDevNo AND 16#000000FF);
            tx[20] := TO_BYTE(SHR(udiHeadDevNo, 8) AND 16#000000FF);
            tx[21] := TO_BYTE(SHR(udiHeadDevNo, 16) AND 16#000000FF);
            tx[22] := TO_BYTE(uiDeviceCode AND 16#00FF);
            tx[23] := TO_BYTE(uiPointsEff AND 16#00FF);
            tx[24] := TO_BYTE(SHR(uiPointsEff, 8) AND 16#00FF);
        ELSE
            tx[0] := 16#50; tx[1] := 16#00;
            tx[2] := 16#00;
            tx[3] := 16#FF;
            tx[4] := 16#FF; tx[5] := 16#03;
            tx[6] := 16#00;
            tx[7] := TO_BYTE(lenReq AND 16#00FF);
            tx[8] := TO_BYTE(SHR(lenReq, 8) AND 16#00FF);
            tx[9] := 16#10; tx[10] := 16#00;
            tx[11] := 16#01; tx[12] := 16#14;
            tx[13] := TO_BYTE(uiSubCmdEff AND 16#00FF);
            tx[14] := TO_BYTE(SHR(uiSubCmdEff, 8) AND 16#00FF);
            tx[15] := TO_BYTE(udiHeadDevNo AND 16#000000FF);
            tx[16] := TO_BYTE(SHR(udiHeadDevNo, 8) AND 16#000000FF);
            tx[17] := TO_BYTE(SHR(udiHeadDevNo, 16) AND 16#000000FF);
            tx[18] := TO_BYTE(uiDeviceCode AND 16#00FF);
            tx[19] := TO_BYTE(uiPointsEff AND 16#00FF);
            tx[20] := TO_BYTE(SHR(uiPointsEff, 8) AND 16#00FF);
        END_IF;

        FOR idx := 0 TO ((uiPointsEff - 1) / 2) DO
            tx[iDataStart + TO_DINT(idx)] := 16#00;
        END_FOR;
        FOR idx := 0 TO (uiPointsEff - 1) DO
            iByteOffset := iDataStart + TO_DINT(idx / 2);
            IF aWriteBits[idx] THEN
                IF (idx MOD 2) = 0 THEN
                    tx[iByteOffset] := TO_BYTE(tx[iByteOffset] OR 16#10);
                ELSE
                    tx[iByteOffset] := TO_BYTE(tx[iByteOffset] OR 16#01);
                END_IF;
            END_IF;
        END_FOR;

        txLen := TO_LINT(iDataStart) + iPayloadBytes;
        step := 40;

    40:
        IF NOT fbCore.SendBytes(pData := ADR(tx[0]), liLen := txLen) THEN
            diError := -2003;
            xError := TRUE;
            step := 90;
        ELSE
            step := 50;
        END_IF;

    50:
        rxLen := fbCore.RecvBytes(pData := ADR(rx[0]), liMaxLen := SIZEOF(rx));
        IF rxLen > 0 THEN
            uiCopyLen := 0;
            IF rxLen > TO_LINT(SLMP_LAST_RESPONSE_INDEX_MAX + 1) THEN
                uiCopyLen := SLMP_LAST_RESPONSE_INDEX_MAX + 1;
            ELSE
                uiCopyLen := TO_UINT(rxLen);
            END_IF;
            uiLastResponseLen := uiCopyLen;
            IF uiCopyLen > 0 THEN
                FOR idx := 0 TO (uiCopyLen - 1) DO
                    aLastResponse[idx] := rx[idx];
                END_FOR;
            END_IF;
            IF rxLen < iMinRxLen THEN
                diError := -2004;
                xError := TRUE;
                step := 90;
            ELSE
                IF xUse4E THEN
                    uiRxSerialNo := TO_UINT(rx[2]) OR SHL(TO_UINT(rx[3]), 8);
                    IF uiRxSerialNo <> uiSerialNo THEN
                        // Drop stale frame and keep waiting until timeout.
                        rxLen := 0;
                        uiLastResponseLen := 0;
                    END_IF;
                END_IF;
            END_IF;
            IF (NOT xError) AND (rxLen > 0) THEN
                endCode := TO_UINT(rx[iEndCodeStart]) OR SHL(TO_UINT(rx[iEndCodeStart + 1]), 8);
                uiLastEndCode := endCode;
                IF endCode <> 0 THEN
                    diError := TO_DINT(endCode);
                    xError := TRUE;
                    step := 90;
                ELSE
                    xDone := TRUE;
                    xBusy := FALSE;
                    step := 90;
                END_IF;
            END_IF;
        END_IF;

    80:
        xRetryTiming := TRUE;
        IF fbReconnect.Q THEN
            xRetryTiming := FALSE;
            step := 10;
        END_IF;

    90:
        IF xError THEN
            fbCore.CloseSocket();
        END_IF;

        IF xError AND (uiRetryCount < uiRetryMax) THEN
            uiRetryCount := uiRetryCount + 1;
            xError := FALSE;
            step := 80;
        ELSE
            xBusy := FALSE;
            step := 0;
        END_IF;
END_CASE;
