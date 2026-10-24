# APB UART IP

## Overview

In this project, an APB-compliant UART IP is designed for the Lattice Certus-NX Versa Evaluation Board and verified through simulation. The RTL is written in plain Verilog and is vendor-neutral; it uses no Lattice primitives or IP.

The full design specification is in [specs.md](specs.md). This README summarizes it and adds how to run the simulation, the test results and the synthesis results.

### Features

For the purpose of this project, the UART is limited to the following specifications:
- Data mode: 8-bit only, not configurable
- Stop bit: 1-bit only, not configurable
- Baud Rate: 9600 by default; fixed at synthesis time (see *Parameters*)
- TX FIFO: none
- RX FIFO: depth of 16 by default; fixed at synthesis time (see *Parameters*)
- Sampling: 1x/bit sampling only

The resulting frame format is 8N1.

The UART is an APB2 (AMBA 2) completer with an 8-bit data bus and a 4-bit address bus. Software polls the `STATUS` register; interrupts are not implemented.

Errors are handled as follows:
- **Unmapped address access** - read returns 0, writes are ignored
- **Write to busy TX** - write is ignored
- **RX read when FIFO is empty** - returns stale, undefined data. FIFO will not underflow
- **Framing error on RX byte** - byte is dropped, `RX_ERR` status flag is raised
- **Byte received while RX FIFO is full** - byte is dropped, `RX_OVR` status flag is raised
    - EXCEPTION: When receive and a read happens in the same cycle, both are accepted & FIFO remains full.

### System Diagram

![System diagram](figs/sys_diagram.png)

All clocked submodules run with a 25 MHz source clock (on-board oscillator) and follow asynchronous active-low reset. `apb_interface` is combinational only and uses neither the clock nor the reset. At 25 MHz and 9600 baud rate, the bit period is 2604 clock cycles, which gives an actual baud rate of 9600.6 (+0.006% error).

The `RX_OVR` and `RX_ERR` flags are both instances of one `sticky_flag` module (`rx_ovr_flag` and `rx_err_flag`), where set takes priority over clear. Block diagrams of the APB interface and the receiver are in [figs/apb_diagram.png](figs/apb_diagram.png) and [figs/uart_rx_diagram.png](figs/uart_rx_diagram.png).

### Port table

| Port | Dir | Width | Description |
|-|-|-|-|
| `pclk` | in | 1 | module clock; must match `CLKI_FREQ_MHZ` (default 25 MHz) |
| `prstn` | in | 1 | asynchronous active-low reset |
| `paddr` | in | 4 | APB address signal |
| `psel` | in | 1 | APB select signal |
| `penable` | in | 1 | APB enable signal |
| `pwrite` | in | 1 | APB write signal |
| `pwdata` | in | 8 | APB write data signal |
| `prdata` | out | 8 | APB read data signal |
| `rxd` | in | 1 | incoming UART signal |
| `txd` | out | 1 | outgoing UART signal; `1` on reset |

To connect to a 32-bit APB bus, a wrapper zero-extends `prdata` to 32 bits, passes `pwdata[7:0]` to the UART, and passes `paddr[3:0]`. Support for APB3 can be added in the same wrapper by tying `PREADY` to `1` and `PSLVERR` to `0`.

### Parameters

Parameters are set at synthesis time; there is no runtime configuration.

| Parameter | Default | Legal range | Description |
|-|-|-|-|
| `CLKI_FREQ_MHZ` | 25 | integer; bit-period count must not exceed 65535 | frequency of `pclk` in MHz |
| `BAUD_RATE` | 9600 | integer; bit-period count must not exceed 65535 | UART baud rate |
| `RX_FIFO_DEPTH` | 16 | >= 2, powers of 2  only | number of bytes the RX FIFO can hold |

### Register Map

Registers are 8 bits wide and word-aligned. The register is selected by `paddr[3:2]`; `paddr[1:0]` are ignored. As required by APB2, every transfer completes in 1 CC (after ENABLE state) with no wait states.

| Offset | Name | Access | Reset | Description |
|-|-|-|-|-|
| `0x0` | `TXDATA` | WO | `0x00` | `[7:0]` byte to transmit. Write is ignored unless `TX_READY` = 1. Read returns 0 |
| `0x4` | `RXDATA` | RO, read pops FIFO | `0x00` | `[7:0]` oldest received byte. Read when FIFO is empty returns undefined data and does not pop. Write is ignored |
| `0x8` | `STATUS` | RO, bits 3 and 4 W1C | `0x03` | see bit fields below. Writing 1 to bit 3 or bit 4 clears that flag; writes to other bits are ignored |
| `0xC` | unmapped | - | - | read returns 0, write is ignored |

The `STATUS` register bit fields are as follows:

| Bit | Name | Access | Reset | Description |
|-|-|-|-|-|
| 0 | `TX_READY` | RO | 1 | transmitter is idle; a write to `TXDATA` is accepted |
| 1 | `RX_EMPTY` | RO | 1 | RX FIFO holds no bytes |
| 2 | `RX_FULL` | RO | 0 | RX FIFO holds `RX_FIFO_DEPTH` bytes |
| 3 | `RX_OVR` | W1C | 0 | byte received while RX FIFO full with no read request. Set takes priority over clear |
| 4 | `RX_ERR` | W1C | 0 | byte received with a bad stop bit (framing error). Set takes priority over clear |
| 7:5 | reserved | RO | 0 | - |

A typical UART transmit and receive sequence would take place as follows:
- **Transmit** - poll `STATUS` until `TX_READY` = 1, then write the byte to `TXDATA`.
- **Receive** - poll `STATUS` until `RX_EMPTY` = 0, then read `RXDATA`. Each read pops one byte.
- **Errors** - check `RX_OVR` and `RX_ERR` in `STATUS`, and write `0x18` to `STATUS` to clear both.

## Repository Structure

| Path | Contents |
|-|-|
| `specs.md` | design specification |
| `src/` | RTL (Verilog); top module is `uart_apb_top` |
| `tb/` | self-checking testbenches and the regression script `run_all.do` |
| `figs/` | system, APB interface and receiver diagrams |
| `uart_ip_demo/` | Lattice Radiant project for the Certus-NX (`LFD2NX-40-9BG256C`) |
| `refs/` | AMBA specifications (ARM IHI 0011A, ARM IHI 0024D) |

## Simulation

The testbenches are plain Verilog and self-checking: each one counts passed and failed checks and prints PASS or FAIL. No waveform inspection is needed.

- **Tool** - Questa Lattice OEM Edition 2025.2, bundled with Lattice Radiant / Propel 2026.1
- **Script** - `tb/run_all.do` compiles every file in `src/` and `tb/` with `vlog -lint`, runs every testbench, and prints one overall result. The exit code is 0 on PASS and 1 on FAIL.

From the project folder, create a working folder and run the regression:

```bash
mkdir sim
cd sim
vsim -c -do "do ../tb/run_all.do"
```

Expected output (end of the transcript):

```
================ regression summary ================
  fifo_tb_depth2       PASS (4049 checks)
  fifo_tb_depth16      PASS (4217 checks)
  uart_burst_tb        PASS (20 checks)
  uart_frame_err_tb    PASS (25 checks)
  uart_reg_tb          PASS (12 checks)
  uart_ovr_tb          PASS (34 checks)
====================================================
REGRESSION: PASS
```

## Test Results

All tests pass in one regression run (2026-10-25). `vlog -lint` reports 0 errors and 0 warnings.

| Test | Covers | Checks | Result |
|-|-|-|-|
| `fifo_tb` (`FIFO_DEPTH` = 2) | FIFO against a reference model of the RX FIFO Behavior table in [specs.md](specs.md); random and directed writes and reads | 4049 | PASS |
| `fifo_tb` (`FIFO_DEPTH` = 16) | same as above, at the default depth | 4217 | PASS |
| `uart_burst_tb` | `txd` looped back to `rxd`; 16 bytes sent without reading, a 17th byte dropped and `RX_OVR` set, all 16 bytes read back in order | 20 | PASS |
| `uart_frame_err_tb` | `rxd` driven directly; bad-stop-bit frames not written to the FIFO, receiver recovers on the next frame, `RX_ERR` set, sticky and cleared by W1C, set wins over clear in the same cycle | 25 | PASS |
| `uart_reg_tb` | `STATUS` reset value, unmapped offset `0xC`, `RXDATA` read when empty (no pop, no underflow), `TXDATA` write while busy ignored | 12 | PASS |
| `uart_ovr_tb` | `RX_OVR` not set when the FIFO fills exactly, set on overrun, sticky, cleared only by W1C at `STATUS`; set wins over clear; full FIFO with read and receive in the same cycle stores the byte | 34 | PASS |

## Synthesis Results

The design was synthesized, placed and routed with Lattice Radiant 2026.1.1 (Synplify Pro) for the Certus-NX `LFD2NX-40-9BG256C` (speed grade 9, 1.0 V), with a 25 MHz clock constraint on `pclk`. I/O pins are not assigned, since the design is not tested on hardware. Results are from the run of 2026-10-25.

| Resource | Used | Available |
|-|-|-|
| Registers | 102 | 32811 |
| LUT4s | 212 (154 logic, 12 distributed RAM, 46 ripple) | 32256 |
| PIOs | 25 | 185 |
| Block RAMs | 0 | 84 |
| DSP multipliers | 0 | 56 |

Timing is met at the 25 MHz target with no setup or hold errors:

| Corner | Target | Fmax (all paths) | Worst slack |
|-|-|-|-|
| setup, 85 °C | 25 MHz | 192.2 MHz | 34.797 ns |
| setup, 0 °C | 25 MHz | 193.3 MHz | - |
| hold, 0 °C | - | - | 0.082 ns |

Constraint coverage is 67%. The endpoints that are not covered are the I/O ports and asynchronous reset pins, which have no input/output delay constraints; this is expected for an IP block without board-level I/O timing.

## Limitations

- **1x sampling only** - each bit is sampled only once, near its centre. Oversampling or majority vote is not implemented.
- **No runtime configuration** - clock frequency, baud rate and FIFO depth are fixed at synthesis time.
- **8N1 only** - no parity and no 2-stop-bit support.
- **No TX FIFO** - software must wait for `TX_READY` before writing each byte.
- **No interrupts** - software must poll `STATUS`.
- **No APB wait states or error responses** - `PREADY` and `PSLVERR` are not implemented.
- **Simulation only** - the design is verified in simulation; it is not tested on hardware.

## Future Work

- Programmable baud rate (baud divisor register)
- 2-stop-bit support
- Interrupts
- TX FIFO
- Oversampling (16x) with majority vote
- Firmware for embedded use
- Hardware demonstration on the Certus-NX Versa Evaluation Board
  - FPGA: with wrapper module providing APB requester stimuli
  - Embedded: integrated with SoC design and using self-written firmware 

## AI Usage Disclosure

This project was developed with the help of Claude Code (Anthropic). Claude Code was used mainly as a learning aid: to better understand the APB protocol, register map design and UART design practice, so that the author could make their own design decisions. The author wrote the specification and the RTL. Claude Code wrote the testbenches, the diagrams and a first draft of this README.

### Design decisions

The major design decisions were made by the author. These include:
- **Scope** - 8N1 only, 9600 baud, no TX FIFO, 16-deep RX FIFO, 1x sampling, no interrupts, simulation only
- **Bus interface** - APB2 (AMBA 2) without `PREADY`/`PSLVERR`, 4-bit address and 8-bit data buses
- **Register map** - custom map (not 16550), offsets, bit fields, reset values and W1C clearing
- **Error handling** - empty-read, busy-TX, overrun and framing-error behavior, including the `RX_OVR` and `RX_ERR` flags
- **Architecture** - module partitioning, the shared `sticky_flag` module, and the signal naming convention

Claude Code's role in the design was advisory:
- **Explanations** - the APB protocol (setup and access phases, APB2 versus APB3 signals), register map conventions such as W1C flags, and the trade-offs between design options when asked
- **Reviews** - checking the RTL against the specification and reporting problems; the author decided whether and how to act on each finding
- **Minor suggestions** - housekeeping items, such as consistent port naming, comments and specification wording, some of which the author took up

### Files

| File | Created by | Claude Code's involvement |
|-|-|-|
| `specs.md` | Author | wording suggestions and edits where the author asked for them |
| `src/` (RTL) | Author (some modules adapted from an earlier project of the author's) | reviews only |
| `tb/` (testbenches, `run_all.do`) | Claude Code | written on the author's request; the author set what each test must cover |
| `figs/` (diagrams) | Claude Code | drawn and rendered on the author's request based on the written specification and RTL, reviewed by the author |
| `README.md` | Claude Code, edited by the author | derived from `specs.md`, keeping the author's wording where possible |
| `uart_ip_demo/` (Radiant project) | Author | none; Claude Code read the reports to fill in *Synthesis Results* |
| `refs/` | Arm (third party) | none |

Simulation regressions were run by Claude Code and by the author; the Radiant runs were done by the author.

## References

- ARM IHI 0011A, Chapter 5: AMBA APB
- ARM IHI 0024D, AMBA APB Protocol Specification (timing diagrams; `PREADY` read as always 1)
