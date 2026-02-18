METHOD DecodeReadData : BOOL

// === IMPLEMENTATION ===

DecodeReadData := TRUE;

IF xBitMode THEN
    DecodeReadData := DecodeBitArray();
ELSE
    DecodeReadData := DecodeWordArray();
END_IF;
