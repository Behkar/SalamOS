# SalamOS

A small monolithic operating system written in the **Salam** programming language, running on QEMU (i386 architecture).

## Features

- **Interactive Shell** with the following commands:
  - `help`, show help
  - `clear`, clear VGA screen
  - `mem`, show heap usage
  - `echo X`, print text X
  - `ticks`, show tick counter
  - `halt`, halt CPU
  - `exit`, exit QEMU
  - `reboot`, reset CPU
  - `version`, show OS version
  - `vga`, draw on VGA screen
  - `color`, colored text (ANSI)
- **Serial COM1** for I/O (QEMU `-serial stdio` support)
- **VGA text mode** (80×25) via `WriteAt`
- **ANSI colors** in serial output
- **Timer/PIT** (Programmable Interval Timer) at ~1000 Hz
- **Heap allocator** (bump allocator from baremetal runtime)
- **Multiboot header** for booting with GRUB/QEMU

## Prerequisites

| Tool | Description |
|------|-------------|
| `salam` | Salam language compiler (version ≥ 0.6.2) |
| `as` | GNU Assembler (for boot.s) |
| `clang` | C compiler (for runtime.c) |
| `ld.lld` | LLVM linker |
| `qemu-system-i386` | QEMU emulator |

### Install prerequisites (Ubuntu/Debian)

```sh
sudo apt install binutils clang lld qemu-system-x86
```

### Install Salam

```sh
{ curl -fsSL https://raw.githubusercontent.com/SalamLang/Salam/refs/heads/main/install.sh || wget -qO- https://raw.githubusercontent.com/SalamLang/Salam/refs/heads/main/install.sh; } | sh
```

## Build and Run

```sh
# 1. Assemble boot.s
as --32 boot.s -o boot.o

# 2. Compile runtime.c
clang --target=i686-unknown-none-elf -ffreestanding -fno-builtin \
  -fno-stack-protector -fno-pic -fno-pie -O2 \
  -c ~/.salam/bin/std/baremetal/runtime.c -o runtime.o

# 3. Compile main.salam
salam obj main.salam --target=i686-unknown-none --entry=_start \
  --linker-script=linker.ld --link-object=boot.o --output=main.o

# 4. Link
ld.lld -m elf_i386 -nostdlib -T linker.ld boot.o main.o runtime.o -o salamOS.elf

# 5. Run in QEMU
qemu-system-i386 -kernel salamOS.elf \
  -chardev stdio,id=ser0 -serial chardev:ser0 \
  -display none -no-reboot
```

## Project Structure

```
salamOS/
├── main.salam      # Main OS code (shell, commands, serial buffer)
├── boot.s          # Boot code (Multiboot header + _start)
├── linker.ld       # Linker script
└── README.md       # This file
```

## Completed ✅

- [x] Boot with Multiboot header in QEMU
- [x] Interactive shell with help/clear/mem/echo/ticks/halt/exit commands
- [x] Advanced commands: reboot, version, vga, color
- [x] Serial COM1 for I/O
- [x] VGA text mode (80×25) with WriteAt
- [x] ANSI colors in serial output
- [x] Timer/PIT at ~1000 Hz
- [x] Heap allocator (bump allocator from baremetal runtime)
- [x] Fixed `salam_out_flush` issue in freestanding mode
- [x] Fixed Vector method names (CamelCase: Len, Push, Pop)
- [x] Fixed inverted serial ready condition
- [x] Fixed `until` semantics (in Salam `until COND` = `while COND`)

## Roadmap (Future Work) 🚧

### Intermediate
- [ ] **History and Tab Completion**, store previous commands and auto-complete with Tab
- [ ] **Read tick from PIT**, update `ticks` from PIT channel 0
- [ ] **Multiple arguments in echo**, split arguments by space
- [ ] **VGA colors**, use different colors on VGA screen

### Advanced
- [ ] **IDT (Interrupt Descriptor Table)**, interrupt management
- [ ] **PS/2 Keyboard**, read from port 0x60 (IRQ1)
- [ ] **Advanced memory management**, paging, virtual memory
- [ ] **Simple filesystem**, ramdisk with header + file table + data
- [ ] **Multi-process support**, simple multitasking
- [ ] **Disk driver**, read/write from disk (ATA/IDE)

## Technical Notes

### `until` in Salam
In the Salam language, `until COND:` means **`while COND`** (not `while !COND`). So for a loop that runs "until condition is not met", you must write `until not COND:`.

### `salam_out_flush` in freestanding mode
The Salam compiler calls `salam_out_flush` in the generated IR for freestanding targets but does not declare it. Solution: add `extern: func salam_out_flush(): void end` in Salam code.

### Vector methods
In the new version of Salam, Vector methods are written in CamelCase: `Len()`, `Push()`, `Pop()` (not `len()`, `push()`, `pop()`).

### Multiboot header
The Multiboot header must be within the first 8 KB of the ELF file. In `linker.ld`, the `.multiboot` section is placed before `.text`.

## License

This project is licensed under the **GNU General Public License v3.0** (GPL-3.0).

See [https://www.gnu.org/licenses/gpl-3.0.html](https://www.gnu.org/licenses/gpl-3.0.html) for the full license text.

## Contributing

Contributions are welcome! Please open a Pull Request or create an Issue.


**Built with ❤️ using the [Salam](https://www.salamlang.ir) programming language**
