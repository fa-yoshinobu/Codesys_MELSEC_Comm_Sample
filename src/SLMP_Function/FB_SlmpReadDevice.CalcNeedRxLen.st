METHOD CalcNeedRxLen : LINT

// === IMPLEMENTATION ===

IF xBitMode THEN
    CalcNeedRxLen := iDataStart + TO_LINT((uiPointsEff + 1) / 2);
ELSE
    CalcNeedRxLen := iDataStart + TO_LINT(uiPointsEff) * 2;
END_IF;
