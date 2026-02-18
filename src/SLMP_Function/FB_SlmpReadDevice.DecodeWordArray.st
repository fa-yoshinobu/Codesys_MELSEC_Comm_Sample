METHOD DecodeWordArray : BOOL

// === IMPLEMENTATION ===

DecodeWordArray := TRUE;

FOR idx := 0 TO (uiPointsEff - 1) DO
    aValues[idx] := TO_UINT(rx[iDataStart + TO_DINT(idx) * 2]) OR SHL(TO_UINT(rx[iDataStart + TO_DINT(idx) * 2 + 1]), 8);
END_FOR;

uiReadWords := uiPointsEff;
uiReadBits := 0;
uiValue0 := aValues[0];
