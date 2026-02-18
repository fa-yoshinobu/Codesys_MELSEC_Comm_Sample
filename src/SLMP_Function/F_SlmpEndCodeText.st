FUNCTION F_SlmpEndCodeText : STRING
VAR_INPUT
    uiEndCode : UINT;
END_VAR

// === IMPLEMENTATION ===
CASE uiEndCode OF
    16#0000: F_SlmpEndCodeText := 'OK';
    16#0050: F_SlmpEndCodeText := 'OUT_OF_RANGE';
    16#C051: F_SlmpEndCodeText := 'POINTS_OR_HEAD_DEVICE_ERROR';
    16#C052: F_SlmpEndCodeText := 'COMMAND_NOT_SUPPORTED';
    16#C053: F_SlmpEndCodeText := 'SUBCOMMAND_NOT_SUPPORTED';
    16#C054: F_SlmpEndCodeText := 'DATA_FORMAT_ERROR';
    16#C055: F_SlmpEndCodeText := 'WRITE_PROTECTED';
    16#C056: F_SlmpEndCodeText := 'CPU_BUSY';
    16#C061: F_SlmpEndCodeText := 'REQUEST_DATA_LENGTH_ERROR';
    16#CE10: F_SlmpEndCodeText := 'NETWORK_PARAMETER_ERROR';
    16#CE11: F_SlmpEndCodeText := 'DESTINATION_PARAMETER_ERROR';
ELSE
    F_SlmpEndCodeText := 'UNKNOWN_END_CODE';
END_CASE;

