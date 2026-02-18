METHOD DecodeBitArray : BOOL

// === IMPLEMENTATION ===

DecodeBitArray := TRUE;

FOR idx := 0 TO (uiPointsEff - 1) DO
    iByteOffset := iDataStart + TO_DINT(idx / 2);
    byData := rx[iByteOffset];
    IF (idx MOD 2) = 0 THEN
        aBits[idx] := (byData AND 16#F0) <> 0;
    ELSE
        aBits[idx] := (byData AND 16#0F) <> 0;
    END_IF;
    IF idx <= SLMP_MAX_WORD_INDEX THEN
        IF aBits[idx] THEN
            aValues[idx] := 1;
        ELSE
            aValues[idx] := 0;
        END_IF;
    END_IF;
END_FOR;

uiReadBits := uiPointsEff;
uiReadWords := 0;

IF uiPointsEff > 0 THEN
    IF aBits[0] THEN
        uiValue0 := 1;
    ELSE
        uiValue0 := 0;
    END_IF;
END_IF;
