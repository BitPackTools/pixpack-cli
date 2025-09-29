# pixpack-cli
A lightweight steganography tool for Windows that hides encrypted files inside PNG images using batch scripts.

<div align="center">
  <img src="https://github.com/BitPackTools/pixpack-cli/blob/main/logo/logo.png" alt="PixPack Logo" width="300">
</div>


## Features

- **Pack**: Compress and encrypt files/folders with 7z, then embed them into PNG images
- **Unpack**: Extract hidden encrypted archives from PNG files
- **Password protection**: All embedded content is encrypted
- **Preserves image**: The PNG remains a valid image file after embedding
- **Command-line interface**: Simple batch scripts for easy automation

## Requirements

- Windows
- **7zr.exe** (7-Zip standalone executable) - must be placed in the same directory as the scripts

# PixPack

## New GUI Versions (2025-09-29)

Two new dialog-based batch files have been added:

- `pixpack_pack_dialog.bat` — Pack files with a simple selection dialog.  
- `pixpack_unpack_dialog.bat` — Unpack files with a simple selection dialog.  

These scripts provide a more user-friendly interface compared to the command-line versions.

## Installer (`install.bat`)

The `install.bat` script automates the registration of PixPack in the Windows context menu for `.png` files.

### What it does

1. Detects the full paths of the batch files in the same folder as the installer.  
2. Generates a temporary `.reg` file containing the necessary Windows Registry entries.  
3. Imports the `.reg` file into the system registry (administrator privileges required).

### Result

After running `install.bat`:

- Right-clicking a `.png` file will show two new context menu options:  
  - **Pack with PixPack** — runs `pixpack_pack_dialog.bat`.  
  - **Unpack with PixPack** — runs `pixpack_unpack_dialog.bat`.

This allows quick access to PixPack functionality directly from Windows Explorer without opening a command prompt.

**Note:** You must run `install.bat` as Administrator for the registry changes to take effect.


## Usage

**Packing Example:**
```cmd
pixpack_pack.bat "photo.png" "secret_file" "packed_photo.png" "mypassword123"
```

**Unpacking Example:**
```cmd
pixpack_unpack.bat "packed_photo.png" "C:\path\to\extracted_files" "mypassword123"
```

## How it works

1. **Packing**: Creates an encrypted 7z archive of your files, then appends it to the end of a PNG image
2. **Unpacking**: Copies the packed PNG with a .zip extension, allowing 7z to extract the embedded archive (ZIP format can handle extra data at the beginning)

The resulting PNG file looks and behaves like a normal image, but contains your hidden encrypted data at the end.

## Installation

1. Download the latest release
2. Download **7zr.exe** from the [official 7-Zip website](https://www.7-zip.org/download.html)
3. Place `7zr.exe` in the same directory as the pixpack batch files
4. Run the scripts from command line

## License

This project is licensed under the BSD 3-Clause License - see below for details.

### 7-Zip License Notice

This software uses **7zr.exe** (7-Zip standalone executable) which is licensed under the GNU LGPL license and unRAR license restriction. 

- 7-Zip Copyright (C) 1999-2025 Igor Pavlov
- 7-Zip is free software distributed under the GNU LGPL (except for unRAR code)
- More information: https://www.7-zip.org/license.txt

---

## BSD 3-Clause License

Copyright (c) 2025, pixpack contributors
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
