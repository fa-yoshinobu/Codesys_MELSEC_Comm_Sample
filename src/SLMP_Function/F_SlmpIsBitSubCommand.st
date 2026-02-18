FUNCTION F_SlmpIsBitSubCommand : BOOL
VAR_INPUT
    uiSubCommand : UINT;
END_VAR

// === IMPLEMENTATION ===
F_SlmpIsBitSubCommand := (uiSubCommand = SLMP_SUB_BIT) OR (uiSubCommand = SLMP_SUB_BIT2);

