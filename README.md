# SlBMP1 Image Slanter

SlBMP1 is a utility that processes 1-bit BMP images, shifting each row to the right by an amount equal to its row number. It combines C for file handling and an assembly function for efficient bitwise manipulation.

## Features

- **Supports 1-bit BMP Images** – Works with black-and-white bitmap images.
- **Bit-Level Manipulation** – Rotates each row efficiently using assembly.
- **Hybrid C/Assembly Implementation** – C handles file I/O, while assembly processes the image.
- **Cross-Platform Build** – Supports both 32-bit and 64-bit architectures.
- **Debug-Friendly** – Includes configurations for debugging with Visual Studio Code.

## Input vs Output

Below is an example of an input BMP and the processed output:

| Input Image | Output Image |
|------------|-------------|
|![fox](https://github.com/user-attachments/assets/62d6b04e-abd5-4f42-a9b1-64fbc84ca1db) | ![output](https://github.com/user-attachments/assets/676a7ecb-c956-4ed9-a353-8a207f0193b9) |

## Build and Run

### Build
Run the following command to compile the project:
```sh
make
```

### Run
Process an image by running:
```sh
./slbmp1 input.bmp output.bmp
```

## Debugging

The project is configured for debugging in Visual Studio Code:
- **Launch Configuration** – `launch.json` includes `cppdbg` settings.
- **Build Task** – Uses `make` for compilation.
- **GDB Integration** – Supports Intel-style disassembly for debugging.

## Technology Stack

- **C Language** – Handles file operations and high-level processing.
- **Assembly Language** – Optimized for efficient bit-level operations.
- **Make** – Automates the build process.
- **Visual Studio Code** – Configured with debugging and task automation.

## Credits

Developed to demonstrate low-level programming skills in C and assembly, focusing on efficient bit manipulation and image processing.

---

