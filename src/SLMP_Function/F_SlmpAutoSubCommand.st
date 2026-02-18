FUNCTION F_SlmpAutoSubCommand : UINT
VAR_INPUT
    uiDeviceCode : UINT;
END_VAR

// === IMPLEMENTATION ===
CASE uiDeviceCode OF
    SLMP_DEV_D: F_SlmpAutoSubCommand := SLMP_SUB_DEF_D;
    SLMP_DEV_M: F_SlmpAutoSubCommand := SLMP_SUB_DEF_M;
    SLMP_DEV_X: F_SlmpAutoSubCommand := SLMP_SUB_DEF_X;
    SLMP_DEV_Y: F_SlmpAutoSubCommand := SLMP_SUB_DEF_Y;
    SLMP_DEV_L: F_SlmpAutoSubCommand := SLMP_SUB_DEF_L;
    SLMP_DEV_SM: F_SlmpAutoSubCommand := SLMP_SUB_DEF_SM;
    SLMP_DEV_SD: F_SlmpAutoSubCommand := SLMP_SUB_DEF_SD;
    SLMP_DEV_F: F_SlmpAutoSubCommand := SLMP_SUB_DEF_F;
    SLMP_DEV_V: F_SlmpAutoSubCommand := SLMP_SUB_DEF_V;
    SLMP_DEV_R: F_SlmpAutoSubCommand := SLMP_SUB_DEF_R;
    SLMP_DEV_W: F_SlmpAutoSubCommand := SLMP_SUB_DEF_W;
    SLMP_DEV_B: F_SlmpAutoSubCommand := SLMP_SUB_DEF_B;
    SLMP_DEV_TS: F_SlmpAutoSubCommand := SLMP_SUB_DEF_TS;
    SLMP_DEV_TC: F_SlmpAutoSubCommand := SLMP_SUB_DEF_TC;
    SLMP_DEV_TN: F_SlmpAutoSubCommand := SLMP_SUB_DEF_TN;
    SLMP_DEV_LTS: F_SlmpAutoSubCommand := SLMP_SUB_DEF_LTS;
    SLMP_DEV_LTC: F_SlmpAutoSubCommand := SLMP_SUB_DEF_LTC;
    SLMP_DEV_LTN: F_SlmpAutoSubCommand := SLMP_SUB_DEF_LTN;
    SLMP_DEV_STS: F_SlmpAutoSubCommand := SLMP_SUB_DEF_STS;
    SLMP_DEV_STC: F_SlmpAutoSubCommand := SLMP_SUB_DEF_STC;
    SLMP_DEV_STN: F_SlmpAutoSubCommand := SLMP_SUB_DEF_STN;
    SLMP_DEV_LSTS: F_SlmpAutoSubCommand := SLMP_SUB_DEF_LSTS;
    SLMP_DEV_LSTC: F_SlmpAutoSubCommand := SLMP_SUB_DEF_LSTC;
    SLMP_DEV_LSTN: F_SlmpAutoSubCommand := SLMP_SUB_DEF_LSTN;
    SLMP_DEV_CS: F_SlmpAutoSubCommand := SLMP_SUB_DEF_CS;
    SLMP_DEV_CC: F_SlmpAutoSubCommand := SLMP_SUB_DEF_CC;
    SLMP_DEV_CN: F_SlmpAutoSubCommand := SLMP_SUB_DEF_CN;
    SLMP_DEV_LCS: F_SlmpAutoSubCommand := SLMP_SUB_DEF_LCS;
    SLMP_DEV_LCC: F_SlmpAutoSubCommand := SLMP_SUB_DEF_LCC;
    SLMP_DEV_LCN: F_SlmpAutoSubCommand := SLMP_SUB_DEF_LCN;
    SLMP_DEV_SB: F_SlmpAutoSubCommand := SLMP_SUB_DEF_SB;
    SLMP_DEV_SW: F_SlmpAutoSubCommand := SLMP_SUB_DEF_SW;
    SLMP_DEV_ZR: F_SlmpAutoSubCommand := SLMP_SUB_DEF_ZR;
    SLMP_DEV_DX: F_SlmpAutoSubCommand := SLMP_SUB_DEF_DX;
    SLMP_DEV_DY: F_SlmpAutoSubCommand := SLMP_SUB_DEF_DY;
    SLMP_DEV_S: F_SlmpAutoSubCommand := SLMP_SUB_DEF_S;
    SLMP_DEV_Z: F_SlmpAutoSubCommand := SLMP_SUB_DEF_Z;
    SLMP_DEV_LZ: F_SlmpAutoSubCommand := SLMP_SUB_DEF_LZ;
    SLMP_DEV_RD: F_SlmpAutoSubCommand := SLMP_SUB_DEF_RD;
ELSE
    F_SlmpAutoSubCommand := SLMP_SUB_WORD;
END_CASE;

