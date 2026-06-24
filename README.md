# High-Speed UART Protocol with Hardware Retransmission & Parity Verification

A high-performance, parameterizable Universal Asynchronous Receiver-Transmitter (UART) design implemented in Verilog. This architecture is designed for a custom baud rate of **3.90625 Mbps** using asymmetric clock domains, featuring a dual-stage metastability synchronizer, an internal packet-framing matrix, hardware-driven retransmission via a prioritized `load` mechanism, and strict midpoint validation.

---

## Technical Design Specifications

* **Baud Rate**: $3,906,250 \text{ bps}$ ($3.9 \text{ MHz}$)
* **Frame Configuration**: 11-bit custom packet structure:
  * `1 Start Bit` (Driven `LOW`)
  * `8 Data Bits` (LSB first)
  * `1 Parity Bit` (Odd Parity: P = ~(^data_in));
  * `1 Stop Bit` (Driven `HIGH`)
* **Clock Domains**:
  * **Transmitter Clock (`t_clk`)**: $16 \text{ ns}$ cycle duration ($62.5 \text{ MHz}$ base).
  * **Receiver Clock (`r_clk`)**: $5 \text{ ns}$ cycle duration ($200 \text{ MHz}$ base).

---

### 1. Top Module Core (`UART_Protocol`)
Located in `UART.v`, this top-level module encapsulates both the transmitter and receiver subsystems into a full-duplex core. It includes a hardware **metastability barrier (`stage2_sync`)** composed of two cascaded D-Flip-Flops (`d_ff`) to safely capture and stabilize the raw external serial line `Tx` into the receiver's clock domain.

### 2. Transmitter Subsystem
* **`baud_gen.v`**: Implements an explicit down-counter that divides the transmitter clock frequency down by a factor of 16 to generate synchronous periodic `baud_tick` assertions every $256 \text{ ns}$ ($\approx 260 \text{ ns}$ target baud rate window).
* **`frame_data` Module**: Automatically aggregates incoming 8-bit broadside data arrays with an embedded odd parity bit generated via reduction routing logic alongside static packet boundaries.
* **`transmitter` Engine**: Governed by sequential control shifting structures:
  * Prioritizes the `load` input signal over `send`. If `load` asserts, the system forces a retransmission of the previously shadowed internal cache register (`packet_load_ready`) to clear line collision errors.
  * Serially shifts out the data structure over the physical `Tx` wire via `packet_temp[0]` and maintains tracking up to bit window frame counter $b = 10$.

### 3. Receiver Subsystem
* **`Sample_gen.v`**: A clock dividing mechanism utilizing a 3-bit register to slice the receiver's master $5 \text{ ns}$ input clock down by a factor of 4. This produces a steady $20 \text{ ns}$ interval oversampling tick (`Sample_tick`), ensuring an exact $16\times$ oversampling matrix resolution per serial bit period.
* **`receiver` Core Engine**: Implements an algorithmic Finite State Machine (FSM) backed by a midpoint noise filter counter (`count_s`). 
  * Midpoint checks occur exactly when `count_s == SamplingWidth / 2` (Sample tick count index 8).
  * **FSM States**:
    * `idle`: Senses the initial falling edge transition of the serial `rx` wire.
    * `start`: Confirms valid entry condition if `rx` is still verified `LOW` at mid-bit phase.
    * `data`: Sweeps serial line values directly into intermediate array segments (`data_temp`).
    * `parity`: Re-evaluates incoming streams using odd parity check reduction: `rx == ~(^data_temp)`.
    * `stop`: Samples line for a valid trailing high termination. If successful, shifts data out to `data_correct` and moves to the `correct` terminal state.
    * `correct`: To give a confirmation on data received.Immedietely moves to the idle state to detect the falling edge. 
    * `error`: Asserts a recovery mode that fires the external `load` flag high to request immediate frame packet transmission corrections.

---

## Verification & Simulation Testbenches

The repository includes a comprehensive, self-checking simulation verification infrastructure using test components split across targeted test suites (`Uart_transmitter_tb.v`, `Uart_receiver_tb.v`, and `UART_tb.v`).

### 1. Transmitter Verification Sequence (`TX Suite`)
The transmitter environment subjects the `UART_TRANSMITTER` hardware to a dense series of structural state test scenarios
* **Test 1: Simple Data Transmission**: Validates standalone bit alignment accuracy by generating a clean transmission frame for data payload `0x24`.
* **Test 2: Suppressed Gate Validation**: Asserts a data vector (`0x45`) without pulsing the master `send` strobe to verify the transmitter correctly stays quiescent in its idle posture. It then applies the valid `send` pulse immediately after to verify normal activation.
* **Test 3: Mid-Frame Asynchronous Reset**: Fires a global hardware reset precisely 5 baud intervals into an active frame transmission sequence (`0x22`) to test recovery and pipeline flushing performance.
* **Test 4: Zero-Gap Back-to-Back Saturation**: Floods the pipeline sequentially with boundary payloads (`0x00`, `0x01`, `0x80`, `0xFF`) without inserting idle padding to test the stability of successive framing boundaries.
* **Test 5: Quiescent Idle Verification**: Pushes the system into an extended idle state lasting 44 baud periods to assert and cross-examine that the `busy` status flag settles completely back to a standard zero level.
* **Test 6: Post-Idle Recovery Pipeline**: Transmits alternating word packets (`0x55`, `0xAA`, `0x11`, `0x88`) immediately following a deep idle phase to check for timing skew anomalies during wakeup.
* **Test 7: Interrupted Over-Strobe Protection**: Attempts to flood the transmitter interface with new data inputs while it is already hard-locked processing an active bit-shifting routine, proving that incoming overwrites are rejected as long as the module reports a `busy` state.
* **Test 8: Prioritized Cache Load Retransmission**: Aborts an active cycle using a reset, confirms the core returns to idle, and then asserts the prioritized hardware `load` line high to force an immediate re-injection of the shadowed register back into circulation.

### 2. Receiver Verification Sequence (`RX Suite`)
The receiver test architecture runs parallel check structures using an embedded scoreboarding engine:
* **Test 1: Standard Packet Verification**: Forces a fully formatted bitstream pattern (`0x12`) down the serial pin to verify clean detection and tracking.
* **Test 2: Corrupted Mid-Packet Reset Phase**: Asserts a reset pulse exactly 128 clock ticks into an incoming stream to verify that invalid fragments are dismissed and the `done` register correctly stays low.
* **Test 3: Parity Violation Rejection**: Injects an explicit parity error into payload packet `0x07` to confirm the internal engine catches the anomaly, drops execution flags, and suppresses corrupted data.
* **Test 4: Deep Silence Noise Gate**: Leaves the line completely un-driven for 1280 sample ticks to confirm the state machine doesn't trip on idle lines.
* **Test 5: Multi-Packet Streaming Stream**: Backs four complete 11-bit frame packages together continuously to ensure no sampling alignment shifts occur across dense processing cycles.
* **Test 6: Framed Stop Bit Violation**: Deliberately breaks a frame boundary by feeding a `LOW` signal during the expected stop-bit window, proving the receiver drops the frame and flags an operational failure.
* **Test 7: High-Frequency Waveform Stressing**: Alternates high-frequency signal packets (`0x55`, `0xAA`, `0x0F`, `0xF0`) across the receiver to verify performance under high bit-transition densities.
* **Test 8: Phase Margin Drift Tolerance**: Artificially warps the baud rate frame windows out from a 320 to a skewed 324 scale metric to verify the FSM mid-bit oversampling matrix safely isolates and decodes misaligned data streams.
---
