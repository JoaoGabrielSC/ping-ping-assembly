# Ping-Pong Game - Assembly x86

A classic Pong/Ping-Pong game implementation written in x86 Assembly language for the Embedded Systems course project (2025/1).

## Author

**João Gabriel Santos Custódio**  
Embedded Systems Laboratory Project - 2025/1

## Description

This project implements a fully functional Pong game in 16-bit x86 Assembly language. The game features:

- **Ball Physics**: Realistic ball movement with collision detection
- **Player Paddle**: Controllable paddle with smooth movement
- **Score System**: Real-time score tracking (Player vs Computer)
- **Speed Control**: Adjustable game speed during gameplay
- **VGA Graphics**: 640x480 16-color graphics mode
- **Sound**: Keyboard interrupt handling for responsive controls

## Game Features

### Controls

- **↑ Arrow Key**: Move paddle up
- **↓ Arrow Key**: Move paddle down  
- **+ Key**: Increase game speed
- **- Key**: Decrease game speed
- **ESC Key**: Exit game

### Graphics

- Resolution: 640x480 pixels
- Color mode: 16 colors
- Real-time rendering with collision detection
- Smooth ball and paddle animations

## Requirements

- **DOSBox**: Installed and configured
- **Bash**: Linux/macOS or WSL on Windows to execute scripts
- **Make**: Build automation tool
- **NASM**: Netwide Assembler (included in project)

## Installation & Setup

1. Clone the repository:

```bash
git clone https://github.com/JoaoGabrielSC/ping-ping-assembly.git
cd ping-ping-assembly
```

2. Ensure DOSBox is installed on your system

3. Make the run script executable:

```bash
chmod +x run.sh
```

## Usage

The project includes a Makefile with several convenient targets:

### `make run-game`

Runs the pre-compiled game executable in DOSBox:

```bash
make run-game
```

### `make build-run`

Builds the assembly source code and runs the game:

```bash
make build-run
```

### `make clean`

Removes generated object and listing files:

```bash
make clean
```

### `make help`

Shows all available commands:

```bash
make help
```

## Manual Compilation

If you prefer to compile manually:

1. Start DOSBox
2. Mount the project directory
3. Use the included NASM assembler:

```
nasm16.exe JGS.asm
freelink.exe JGS.obj
JGS.exe
```

## Project Structure

```
├── JGS.asm           # Main assembly source code
├── JGS.exe           # Compiled executable
├── Makefile          # Build automation
├── run.sh            # DOSBox execution script
├── DOSBox.conf       # DOSBox configuration
├── NASM16.exe        # 16-bit NASM assembler
├── FREELINK.exe      # Linker for DOS
├── asm/              # Additional assembly modules
│   └── MODE13H/      # Graphics mode utilities
└── dosbox.app/       # DOSBox application (macOS)
```

## Technical Details

### Assembly Implementation

- **Segment Architecture**: Uses classic DOS segment model
- **Interrupt Handling**: Custom keyboard interrupt (INT 9h)
- **Graphics**: VGA mode 12h (640x480, 16 colors)
- **Memory Management**: Stack and data segment organization

### Key Algorithms

- **Bresenham's Line Algorithm**: For paddle and boundary rendering
- **Circle Drawing**: Custom circle fill algorithm for ball
- **Collision Detection**: Precise boundary and paddle collision
- **Score Rendering**: Dynamic text rendering system

### Performance Optimizations

- Efficient memory usage with segment registers
- Optimized drawing routines
- Minimal interrupt overhead
- Direct VGA memory access

## Game Logic

1. **Initialization**: Set up graphics mode and interrupts
2. **Game Loop**:
   - Update ball position
   - Check collisions (walls, paddle)
   - Handle user input
   - Update score
   - Render frame
3. **Exit**: Restore previous video mode and exit

## Troubleshooting

### Common Issues

**DOSBox not found**: Ensure DOSBox is installed and in your PATH

```bash
# macOS with Homebrew
brew install dosbox

# Ubuntu/Debian
sudo apt-get install dosbox
```

**Permission denied on run.sh**: Make the script executable

```bash
chmod +x run.sh
```

**Assembly errors**: Ensure you're using the included NASM16.exe for 16-bit compatibility

## Learning Outcomes

This project demonstrates:

- Low-level programming concepts
- Graphics programming fundamentals  
- Interrupt handling and system programming
- Assembly language optimization techniques
- Real-time game development principles

## License

This project is part of an academic assignment for the Embedded Systems course. Feel free to study and learn from the implementation.

## Contributing

This is an academic project, but suggestions and improvements are welcome! Please feel free to:

- Report bugs
- Suggest optimizations
- Share learning insights

---

**Note**: This game runs in a DOS environment through DOSBox. For the best experience, ensure DOSBox is properly configured with appropriate CPU cycles.`
