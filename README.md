# Merchant's theory of chip formation (Fortran CLI Tool)

This is a practical and modular command-line application written in Fortran that simulates orthogonal metal cutting using classical mechanics. It's designed for engineers, researchers, and students interested in machining analysis, tool behavior, and thermal effects.

## ✨ Features

- Material database via `materials.csv`
- Calculates:
  - Shear angle and forces
  - Shear stress and specific cutting energy (SCE)
  - Cutting power and material removal rate (MRR)
  - Temperature rise and thermal zone classification
  - Machinability index (proxy)
- Modular Fortran codebase with clean structure
- Optional output to a file (`results.txt`)
- Easily extensible

## 📦 Build Instructions

```bash
chmod +x build.sh
./build.sh

