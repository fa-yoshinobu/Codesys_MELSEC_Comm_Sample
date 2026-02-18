VAR_GLOBAL CONSTANT
    // LITE preset (active)
    SLMP_MAX_WORD_POINTS : UINT := 120;
    SLMP_MAX_BIT_POINTS : UINT := 960;
    SLMP_MAX_WORD_INDEX : UINT := 119;
    SLMP_MAX_BIT_INDEX : UINT := 959;

    // Buffer sizes for LITE preset (active)
    SLMP_READ_RX_INDEX_MAX : UINT := 511;
    SLMP_WRITE_TX_INDEX_MAX : UINT := 1023;
    SLMP_LAST_RESPONSE_INDEX_MAX : UINT := 63;

    (*
    // FULL preset (commented out)
    SLMP_MAX_WORD_POINTS : UINT := 960;
    SLMP_MAX_BIT_POINTS : UINT := 7168;
    SLMP_MAX_WORD_INDEX : UINT := 959;
    SLMP_MAX_BIT_INDEX : UINT := 7167;

    // Buffer sizes for FULL preset (commented out)
    SLMP_READ_RX_INDEX_MAX : UINT := 4095;
    SLMP_WRITE_TX_INDEX_MAX : UINT := 4095;
    SLMP_LAST_RESPONSE_INDEX_MAX : UINT := 255;
    *)
END_VAR
