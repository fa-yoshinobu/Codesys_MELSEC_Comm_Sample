METHOD BuildWritePayload : LINT

// === IMPLEMENTATION ===

IF xBitMode THEN
    BuildWritePayload := BuildBitPayload();
ELSE
    BuildWritePayload := BuildWordPayload();
END_IF;
