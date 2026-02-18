FUNCTION F_SlmpResolveSubCommand : UINT
VAR_INPUT
    uiDeviceCode    : UINT;
    xAutoSubCommand : BOOL;
    uiSubCommand    : UINT;
END_VAR

// === IMPLEMENTATION ===
IF xAutoSubCommand THEN
    F_SlmpResolveSubCommand := F_SlmpAutoSubCommand(uiDeviceCode := uiDeviceCode);
ELSE
    F_SlmpResolveSubCommand := uiSubCommand;
END_IF;

