METHOD BuildBitPayload : LINT

// === IMPLEMENTATION ===

BuildBitPayload := TO_LINT((uiPointsEff + 1) / 2);

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
