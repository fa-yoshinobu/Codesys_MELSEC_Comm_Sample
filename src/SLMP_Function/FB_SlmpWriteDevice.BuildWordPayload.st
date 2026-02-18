METHOD BuildWordPayload : LINT

// === IMPLEMENTATION ===

BuildWordPayload := TO_LINT(uiPointsEff) * 2;

FOR idx := 0 TO (uiPointsEff - 1) DO
    tx[iDataStart + TO_DINT(idx) * 2] := TO_BYTE(aWriteValuesLocal[idx] AND 16#00FF);
    tx[iDataStart + TO_DINT(idx) * 2 + 1] := TO_BYTE(SHR(aWriteValuesLocal[idx], 8) AND 16#00FF);
END_FOR;
