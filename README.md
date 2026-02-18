# codesys_melsec

MELSEC SLMP (TCP/UDP) client sample for CODESYS (Raspberry Pi runtime).

## Support status
- Confirmed PLC series: `iQ-R`, `FX5U`, `FX5UC` only
- Protocol: SLMP 3E/4E, TCP/UDP
- Runtime: CODESYS (Raspberry Pi runtime)
- DWord FBs are experimental and not recommended for production

## Folder layout
- `src/PLC_PRG_Example1.st` (single PLC usage sample)
- `src/PLC_PRG_Example2.st` (multi PLC write sample)
- `src/SLMP_Function/*.st`

## Import order (recommended)
1. DUT: `src/SLMP_Function/SOCKADDRESS_IN.st`
2. Utility/GVL:
   - `src/SLMP_Function/F_SlmpAutoSubCommand.st`
   - `src/SLMP_Function/F_SlmpResolveSubCommand.st`
   - `src/SLMP_Function/F_SlmpIsBitSubCommand.st`
   - `src/SLMP_Function/F_SlmpClampPoints.st`
   - `src/SLMP_Function/F_SlmpNextSerialNo.st`
   - `src/SLMP_Function/F_SlmpEndCodeText.st`
   - `src/SLMP_Function/GVL_SlmpDeviceCode.st`
   - `src/SLMP_Function/GVL_SlmpSubCommand.st`
   - `src/SLMP_Function/GVL_SlmpSubCommandByDevice.st`
   - `src/SLMP_Function/GVL_SlmpRuntime.st`
3. Core FB:
   - `src/SLMP_Function/FB_SlmpCore.st`
   - `src/SLMP_Function/FB_SlmpCore.OpenAndConnect.st`
   - `src/SLMP_Function/FB_SlmpCore.SendBytes.st`
   - `src/SLMP_Function/FB_SlmpCore.RecvBytes.st`
   - `src/SLMP_Function/FB_SlmpCore.CloseSocket.st`
4. Read/Write FB:
   - `src/SLMP_Function/FB_SlmpReadWordDevice.st`
   - `src/SLMP_Function/FB_SlmpReadDWordDevice.st` (experimental / currently not working reliably)
   - `src/SLMP_Function/FB_SlmpReadBitDevice.st`
   - `src/SLMP_Function/FB_SlmpReadPlcInfo.st`
   - `src/SLMP_Function/FB_SlmpCloseConnection.st`
   - `src/SLMP_Function/FB_SlmpWriteWordDevice.st`
   - `src/SLMP_Function/FB_SlmpWriteDWordDevice.st` (experimental / currently not working reliably)
   - `src/SLMP_Function/FB_SlmpWriteBitDevice.st`
5. Service FB:
   - `src/SLMP_Function/FB_SlmpReadWordService.st`
   - `src/SLMP_Function/FB_SlmpWriteWordService.st`
   - `src/SLMP_Function/FB_SlmpReadBitService.st`
   - `src/SLMP_Function/FB_SlmpWriteBitService.st`
   - `src/SLMP_Function/FB_SlmpReadPlcInfoService.st`
6. Example:
   - `src/PLC_PRG_Example1.st`
   - `src/PLC_PRG_Example2.st`

## Quick start
1. Import objects in the recommended order.
2. Start with `src/PLC_PRG_Example1.st`.
3. Set PLC IP/Port and protocol flags (`xUseUdp`, `xUse4E`).
4. Trigger each request with 1-scan pulse on `xExecute`.
5. Check `xDone/xError/diError` and `sLastErrorText`.

## Implementation marker rule
- Insert `// === IMPLEMENTATION ===` between declaration and implementation.
- If `END_VAR` exists: put marker just after `END_VAR`.
- If `END_TYPE` exists: marker is not required.
- If neither exists: put marker near top (after signature line).

## Error code policy
- `diError >= 0`: MELSEC SLMP end code.
- `diError < 0`: local application error (socket/timeout/validation/retry).

## Socket reuse
- `FB_SlmpCore` uses a shared socket pool by destination (`IP/PORT/Protocol`).
- If multiple service FB instances target the same `IP/PORT/Protocol`, they reuse the same connection slot.
- Different PLC destinations use different pool slots and separate connections.
- `FB_SlmpCloseConnection` closes all shared slots and clears global lock table (recovery use).

## Receive behavior
- `FB_SlmpCore.RecvBytes` checks readability with `SysSockSelect` (timeout 0), then calls `SysSockRecv`.
- If no data is ready, it returns `0` immediately and device FBs keep waiting until their own `tTimeout`.
- This avoids task freeze when cable is unplugged; timeout/retry handling remains in each device FB state machine.
- Last sent frame is stored in `GVL_SlmpRuntime.g_aLastTx` / `g_uiLastTxLen` / `g_iLastTxSockSlot`.

## Operation notes
- Run communication FBs in a dedicated low-priority task (avoid main control task blocking impact).
- `xExecute` is edge-triggered in service FBs. For retry after completion/error, pulse OFF->ON again.
- After link down/up recovery, pulse `FB_SlmpCloseConnection` once to clear shared sockets/locks before re-trigger.
- For unstable links, increase `tTimeout` (for example `T#3S` to `T#5S`) before raising `uiRetryMax`.
- `ping` success does not guarantee SLMP success; verify protocol (`TCP/UDP`), port, and PLC SLMP settings.

## Concurrent call safety
- `FB_SlmpReadWordService/FB_SlmpWriteWordService/FB_SlmpReadBitService/FB_SlmpWriteBitService/FB_SlmpReadPlcInfoService` can run from multiple instances.
- Calls to the same destination (`IP/PORT/Protocol`) are serialized by an internal global lock table.
- Calls to different destinations can proceed independently with different socket-pool slots.

## Bit packing policy
- Bit write/read order is aligned between payload build and decode.
- For bit write payload nibble layout, refer to:
  - `src/SLMP_Function/FB_SlmpWriteBitDevice.st`
  - `src/SLMP_Function/FB_SlmpReadBitDevice.st`

## 4E frame support
- 3E/4E can be switched per call.
- Parameters:
  - `xUse4E` (`FALSE`: 3E, `TRUE`: 4E)
  - `xUseUdp` (`FALSE`: TCP, `TRUE`: UDP)
  - `uiSerialNo` (4E serial number)
- Available in:
  - `FB_SlmpReadWordService`
  - `FB_SlmpReadBitService`
  - `FB_SlmpWriteWordService`
  - `FB_SlmpWriteBitService`
  - `FB_SlmpReadPlcInfoService`
- In each service FB, 4E serial is incremented per request automatically.
- Serial source is shared globally (`GVL_SlmpRuntime.g_uiSlmpSerialCounter`).
- 4E response serial is checked.
- If serial mismatches, the frame is treated as stale, discarded, and the FB keeps waiting until `tTimeout`.

## 2-Word devices
- `FB_SlmpReadDWordDevice` / `FB_SlmpWriteDWordDevice` are currently not working reliably.
- They are not used in `src/PLC_PRG_Example2.st`.
- For now, use `Word/Bit` FBs only in production.

## PLC info
- `FB_SlmpReadPlcInfoService` reads:
  - `aPlcTypeNameRaw[0..15]`
  - `uiPlcTypeCode`
  - operation mode from `SM403`:
    - `xPlcRun`
    - `xPlcStop`
    - `uiPlcMode` (`1`: RUN, `2`: STOP)

## Known limitations
- Max tested PLC count in sample: 4 (`PLC_PRG_Example2.st`).
- If link is unstable, local timeout errors (`diError < 0`, e.g. `-2010`) can occur even when `ping` is reachable.
- Some devices/subcommands depend on PLC model/parameter settings.
