FUNCTION_BLOCK FB_SlmpReadPlcInfo
VAR_INPUT
    xExecute         : BOOL;
    sIp              : STRING;
    uiPort           : UINT;
    tTimeout         : TIME := T#2S;
    uiRetryMax       : UINT := 2;
    tReconnectDelay  : TIME := T#500MS;
    xUse4E           : BOOL := FALSE;
    xUseUdp          : BOOL := FALSE;
    uiSerialNo       : UINT := 1;
END_VAR
VAR_OUTPUT
    xBusy            : BOOL;
    xDone            : BOOL;
    xError           : BOOL;
    diError          : DINT;
    uiRetryCount     : UINT;
    aCpuTypeNameRaw  : ARRAY[0..15] OF BYTE;
    uiCpuTypeCode    : UINT;
    xPlcRun          : BOOL;
    xPlcStop         : BOOL;
    uiPlcMode        : UINT; // 0: unknown, 1: run, 2: stop
    aLastResponse    : ARRAY[0..SLMP_LAST_RESPONSE_INDEX_MAX] OF BYTE;
    uiLastResponseLen: UINT;
    uiLastEndCode    : UINT;
    aLastResponseCpuInfo : ARRAY[0..SLMP_LAST_RESPONSE_INDEX_MAX] OF BYTE;
    uiLastResponseCpuInfoLen : UINT;
    uiLastEndCodeCpuInfo : UINT;
    aLastResponseSm403 : ARRAY[0..SLMP_LAST_RESPONSE_INDEX_MAX] OF BYTE;
    uiLastResponseSm403Len : UINT;
    uiLastEndCodeSm403 : UINT;
END_VAR
VAR
    step             : INT := 0;
    xExecPrev        : BOOL := FALSE;

    fbCore           : FB_SlmpCore;

    tx               : ARRAY[0..31] OF BYTE;
    rx               : ARRAY[0..SLMP_LAST_RESPONSE_INDEX_MAX] OF BYTE;
    txLen            : LINT := 0;
    rxLen            : LINT := 0;
    lenReq           : UINT := 0;
    endCode          : UINT := 0;
    byModeData       : BYTE := 0;

    iDataStart       : DINT := 11;
    iEndCodeStart    : DINT := 9;
    iNeedRxLen       : LINT := 0;
    idx              : UINT := 0;
    uiCopyLen        : UINT := 0;

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
    uiCpuTypeCode := 0;
    xPlcRun := FALSE;
    xPlcStop := FALSE;
    uiPlcMode := 0;
    uiLastResponseLen := 0;
    uiLastEndCode := 0;
    uiLastResponseCpuInfoLen := 0;
    uiLastEndCodeCpuInfo := 0;
    uiLastResponseSm403Len := 0;
    uiLastEndCodeSm403 := 0;
    FOR idx := 0 TO 15 DO
        aCpuTypeNameRaw[idx] := 0;
    END_FOR;
    FOR idx := 0 TO SLMP_LAST_RESPONSE_INDEX_MAX DO
        aLastResponse[idx] := 0;
        aLastResponseCpuInfo[idx] := 0;
        aLastResponseSm403[idx] := 0;
    END_FOR;
    step := 10;
END_IF;
xExecPrev := xExecute;

xStateTimeout := (step = 20) OR (step = 40) OR (step = 50) OR (step = 60) OR (step = 70);
fbTimeout(IN := xStateTimeout, PT := tTimeout);
fbReconnect(IN := xRetryTiming, PT := tReconnectDelay);

IF (step <> 0) AND (step <> 80) AND fbTimeout.Q THEN
    diError := -3010;
    xError := TRUE;
    step := 90;
END_IF;

CASE step OF
    0:
        xRetryTiming := FALSE;

    10:
        step := 20;

    20:
        IF fbCore.OpenAndConnect(sIp := sIp, uiPort := uiPort, xUseUdp := xUseUdp) THEN
            step := 30;
        ELSE
            CASE fbCore.diLastError OF
                -1: diError := -3001;
                -2: diError := -3005;
                -3: diError := -3002;
            ELSE
                diError := -3002;
            END_CASE;
            xError := TRUE;
            step := 90;
        END_IF;

    30:
        lenReq := 6; // monitor timer(2) + command(2) + subcommand(2)

        IF xUse4E THEN
            iDataStart := 15;
            iEndCodeStart := 13;
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
            tx[15] := 16#01; tx[16] := 16#01;
            tx[17] := 16#00; tx[18] := 16#00;
            txLen := 19;
        ELSE
            iDataStart := 11;
            iEndCodeStart := 9;
            tx[0] := 16#50; tx[1] := 16#00;
            tx[2] := 16#00;
            tx[3] := 16#FF;
            tx[4] := 16#FF; tx[5] := 16#03;
            tx[6] := 16#00;
            tx[7] := TO_BYTE(lenReq AND 16#00FF);
            tx[8] := TO_BYTE(SHR(lenReq, 8) AND 16#00FF);
            tx[9] := 16#10; tx[10] := 16#00;
            tx[11] := 16#01; tx[12] := 16#01;
            tx[13] := 16#00; tx[14] := 16#00;
            txLen := 15;
        END_IF;

        step := 40;

    40:
        IF NOT fbCore.SendBytes(pData := ADR(tx[0]), liLen := txLen) THEN
            diError := -3003;
            xError := TRUE;
            step := 90;
        ELSE
            step := 50;
        END_IF;

    50:
        rxLen := fbCore.RecvBytes(pData := ADR(rx[0]), liMaxLen := SIZEOF(rx));
        IF rxLen > 0 THEN
            // Auto-detect response frame type from subheader.
            IF (rxLen >= 15) AND (rx[0] = 16#D4) AND (rx[1] = 16#00) THEN
                iDataStart := 15;
                iEndCodeStart := 13;
            ELSIF (rxLen >= 11) AND (rx[0] = 16#D0) AND (rx[1] = 16#00) THEN
                iDataStart := 11;
                iEndCodeStart := 9;
            END_IF;
            uiCopyLen := 0;
            IF rxLen > TO_LINT(SLMP_LAST_RESPONSE_INDEX_MAX + 1) THEN
                uiCopyLen := SLMP_LAST_RESPONSE_INDEX_MAX + 1;
            ELSE
                uiCopyLen := TO_UINT(rxLen);
            END_IF;
            uiLastResponseLen := uiCopyLen;
            uiLastResponseCpuInfoLen := uiCopyLen;
            IF uiCopyLen > 0 THEN
                FOR idx := 0 TO (uiCopyLen - 1) DO
                    aLastResponse[idx] := rx[idx];
                    aLastResponseCpuInfo[idx] := rx[idx];
                END_FOR;
            END_IF;
            iNeedRxLen := TO_LINT(iEndCodeStart) + 2;
            IF rxLen < iNeedRxLen THEN
                diError := -3004;
                xError := TRUE;
                step := 90;
            ELSE
                IF iEndCodeStart = 13 THEN
                    IF (TO_UINT(rx[2]) OR SHL(TO_UINT(rx[3]), 8)) <> uiSerialNo THEN
                        // Drop stale frame and keep waiting until timeout.
                        rxLen := 0;
                        uiLastResponseLen := 0;
                        uiLastResponseCpuInfoLen := 0;
                    END_IF;
                END_IF;
            END_IF;
            IF (NOT xError) AND (rxLen > 0) THEN
                endCode := TO_UINT(rx[iEndCodeStart]) OR SHL(TO_UINT(rx[iEndCodeStart + 1]), 8);
                uiLastEndCode := endCode;
                uiLastEndCodeCpuInfo := endCode;
                IF endCode <> 0 THEN
                    diError := TO_DINT(endCode);
                    xError := TRUE;
                    step := 90;
                ELSE
                    iNeedRxLen := TO_LINT(iDataStart) + 18; // 16-byte name + 2-byte code
                    IF rxLen < iNeedRxLen THEN
                        diError := -3004;
                        xError := TRUE;
                        step := 90;
                    ELSE
                        FOR idx := 0 TO 15 DO
                            aCpuTypeNameRaw[idx] := rx[iDataStart + TO_DINT(idx)];
                        END_FOR;
                        uiCpuTypeCode := TO_UINT(rx[iDataStart + 16]) OR SHL(TO_UINT(rx[iDataStart + 17]), 8);
                        step := 60;
                    END_IF;
                END_IF;
            END_IF;
        END_IF;

    60:
        lenReq := 12;
        IF xUse4E THEN
            iDataStart := 15;
            iEndCodeStart := 13;
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
            tx[15] := 16#01; tx[16] := 16#04;
            tx[17] := 16#01; tx[18] := 16#00;
            tx[19] := TO_BYTE(403 AND 16#000000FF);
            tx[20] := TO_BYTE(SHR(403, 8) AND 16#000000FF);
            tx[21] := TO_BYTE(SHR(403, 16) AND 16#000000FF);
            tx[22] := TO_BYTE(SLMP_DEV_SM AND 16#00FF);
            tx[23] := 16#01;
            tx[24] := 16#00;
            txLen := 25;
        ELSE
            iDataStart := 11;
            iEndCodeStart := 9;
            tx[0] := 16#50; tx[1] := 16#00;
            tx[2] := 16#00;
            tx[3] := 16#FF;
            tx[4] := 16#FF; tx[5] := 16#03;
            tx[6] := 16#00;
            tx[7] := TO_BYTE(lenReq AND 16#00FF);
            tx[8] := TO_BYTE(SHR(lenReq, 8) AND 16#00FF);
            tx[9] := 16#10; tx[10] := 16#00;
            tx[11] := 16#01; tx[12] := 16#04;
            tx[13] := 16#01; tx[14] := 16#00;
            tx[15] := TO_BYTE(403 AND 16#000000FF);
            tx[16] := TO_BYTE(SHR(403, 8) AND 16#000000FF);
            tx[17] := TO_BYTE(SHR(403, 16) AND 16#000000FF);
            tx[18] := TO_BYTE(SLMP_DEV_SM AND 16#00FF);
            tx[19] := 16#01;
            tx[20] := 16#00;
            txLen := 21;
        END_IF;

        IF NOT fbCore.SendBytes(pData := ADR(tx[0]), liLen := txLen) THEN
            diError := -3003;
            xError := TRUE;
            step := 90;
        ELSE
            step := 70;
        END_IF;

    70:
        rxLen := fbCore.RecvBytes(pData := ADR(rx[0]), liMaxLen := SIZEOF(rx));
        IF rxLen > 0 THEN
            // Auto-detect response frame type from subheader.
            IF (rxLen >= 15) AND (rx[0] = 16#D4) AND (rx[1] = 16#00) THEN
                iDataStart := 15;
                iEndCodeStart := 13;
            ELSIF (rxLen >= 11) AND (rx[0] = 16#D0) AND (rx[1] = 16#00) THEN
                iDataStart := 11;
                iEndCodeStart := 9;
            END_IF;
            uiCopyLen := 0;
            IF rxLen > TO_LINT(SLMP_LAST_RESPONSE_INDEX_MAX + 1) THEN
                uiCopyLen := SLMP_LAST_RESPONSE_INDEX_MAX + 1;
            ELSE
                uiCopyLen := TO_UINT(rxLen);
            END_IF;
            uiLastResponseLen := uiCopyLen;
            uiLastResponseSm403Len := uiCopyLen;
            IF uiCopyLen > 0 THEN
                FOR idx := 0 TO (uiCopyLen - 1) DO
                    aLastResponse[idx] := rx[idx];
                    aLastResponseSm403[idx] := rx[idx];
                END_FOR;
            END_IF;
            iNeedRxLen := TO_LINT(iEndCodeStart) + 2;
            IF rxLen < iNeedRxLen THEN
                diError := -3004;
                xError := TRUE;
                step := 90;
            ELSE
                IF iEndCodeStart = 13 THEN
                    IF (TO_UINT(rx[2]) OR SHL(TO_UINT(rx[3]), 8)) <> uiSerialNo THEN
                        // Drop stale frame and keep waiting until timeout.
                        rxLen := 0;
                        uiLastResponseLen := 0;
                        uiLastResponseSm403Len := 0;
                    END_IF;
                END_IF;
            END_IF;
            IF (NOT xError) AND (rxLen > 0) THEN
                endCode := TO_UINT(rx[iEndCodeStart]) OR SHL(TO_UINT(rx[iEndCodeStart + 1]), 8);
                uiLastEndCode := endCode;
                uiLastEndCodeSm403 := endCode;
                IF endCode <> 0 THEN
                    diError := TO_DINT(endCode);
                    xError := TRUE;
                    step := 90;
                ELSE
                    iNeedRxLen := TO_LINT(iDataStart) + 1;
                    IF rxLen < iNeedRxLen THEN
                        diError := -3004;
                        xError := TRUE;
                        step := 90;
                    ELSE
                        byModeData := rx[iDataStart];
                        xPlcRun := (byModeData AND 16#F0) <> 0;
                        xPlcStop := NOT xPlcRun;
                        IF xPlcRun THEN
                            uiPlcMode := 1;
                        ELSE
                            uiPlcMode := 2;
                        END_IF;
                        xDone := TRUE;
                        xBusy := FALSE;
                        step := 90;
                    END_IF;
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
