FUNCTION F_SlmpClampPoints : UINT
VAR_INPUT
    uiPoints : UINT;
    xBitMode : BOOL;
END_VAR

// === IMPLEMENTATION ===
IF uiPoints = 0 THEN
    F_SlmpClampPoints := 0;
ELSIF xBitMode THEN
    IF uiPoints > SLMP_MAX_BIT_POINTS THEN
        F_SlmpClampPoints := SLMP_MAX_BIT_POINTS;
    ELSE
        F_SlmpClampPoints := uiPoints;
    END_IF;
ELSE
    IF uiPoints > SLMP_MAX_WORD_POINTS THEN
        F_SlmpClampPoints := SLMP_MAX_WORD_POINTS;
    ELSE
        F_SlmpClampPoints := uiPoints;
    END_IF;
END_IF;

