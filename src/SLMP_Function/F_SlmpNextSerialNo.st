FUNCTION F_SlmpNextSerialNo : UINT
VAR_INPUT
    uiSeed : UINT := 1;
END_VAR

// === IMPLEMENTATION ===
IF g_uiSlmpSerialCounter = 0 THEN
    IF uiSeed = 0 THEN
        g_uiSlmpSerialCounter := 1;
    ELSE
        g_uiSlmpSerialCounter := uiSeed;
    END_IF;
ELSE
    g_uiSlmpSerialCounter := g_uiSlmpSerialCounter + 1;
    IF g_uiSlmpSerialCounter = 0 THEN
        g_uiSlmpSerialCounter := 1;
    END_IF;
END_IF;

F_SlmpNextSerialNo := g_uiSlmpSerialCounter;
