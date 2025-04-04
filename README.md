# 🛠️ Merchant's Theory of Chip Formation — Fortran CLI Simulator

A modular, open-source **command-line simulator** written in modern **Fortran**, this tool performs machining analysis based on **Merchant’s theory** of orthogonal cutting, which is a predictive model of chip formation that assumes a perfectly plastic workpiece and a sharp cutting edge.

Ideal for:
- 🧑‍🔧 Process engineers optimizing cutting conditions  
- 🎓 Students learning metal cutting theory  
- 🔬 Researchers studying thermal and mechanical phenomena in machining

---

## ✨ Features

- 📦 **Material database** with CSV support
- 📐 **Calculations include**:
  - Shear angle (ϕ) and chip ratio (t₁/t₂)
  - Shear force (Fs) and normal force (Fn)
  - Shear stress (τₛ) and cutting energy (SCE)
  - Material removal rate (MRR)
  - Cutting power and temperature rise (ΔT)
  - **Surface roughness (Ra) estimation**
  - **Thermal damage risk classification**
  - **Machinability index (proxy)**
- 🗂️ Optional output to `.txt` file
- 🔩 Clean modular structure using Fortran 90 modules
- 🔁 Easy to extend with new models or material properties

---

## 🏗️ Build Instructions

Make sure you have **gfortran** installed:

```bash
sudo apt install gfortran
```

Then build the simulator:

```bash
chmod +x build.sh
./build.sh
```

---

## 🚀 How to Run

### ✅ Basic usage (interactive)

```bash
./machining_simulator
```

### 💾 Save results to file

```bash
./machining_simulator results.txt
```

---

## 📥 User Inputs (Prompted Interactively)

1. Select a **material category** from the list (e.g., Steel, Aluminum, Plastics)
2. Select a **specific material** within that category
3. Enter the following cutting parameters:
   - `Rake angle` (degrees)
   - `Coefficient of friction` (μ)
   - `Uncut chip thickness t₁` (mm)
   - `Chip thickness t₂` (mm)
   - `Width of cut w` (mm)
   - `Cutting speed Vc` (m/s)
   - `Cutting force Fc` (N)
   - `Thrust force Ft` (N)

---

## 📊 What It Calculates

The program uses the input and material data to compute:

| Property                      | Description                                 |
|------------------------------|---------------------------------------------|
| **ϕ (Shear angle)**          | Based on Merchant’s theory                  |
| **Chip ratio (r)**           | r = t₁ / t₂                                 |
| **Forces (Fs, Fn)**          | Shear and normal forces on shear plane      |
| **Shear stress (τₛ)**        | Stress on the shear plane (MPa)             |
| **SCE**                      | Specific Cutting Energy (J/mm³)             |
| **MRR**                      | Material Removal Rate (mm³/s)               |
| **Cutting power**            | Power consumed during cutting (W)           |
| **ΔT (Temperature rise)**    | Temperature increase due to shear (K)       |
| **Thermal zone**             | Qualitative temperature classification      |
| **Ra (Surface roughness)**   | Estimated roughness in micrometers (µm)     |
| **Thermal damage risk**      | Qualitative risk assessment                 |
| **Machinability index**      | A proxy index (higher = easier to cut)      |

---

## 📁 Output Example (console or file)

```
-----------------------------------------
Material selected: Stainless Steel 316
Density (kg/m³): 8000.0
Specific Heat (J/kg·K): 500.0
Shear angle φ (deg): 18.28
Chip ratio r = t1 / t2: 1.00
Shear force Fs (N): -0.0075
Normal force Fn (N): 2.83
Shear stress τₛ (MPa): -0.00059
Specific Cutting Energy (J/mm³): 0.50
Cutting Power (W): 4.00
Approx. Temperature Rise (K): -1.58e-09
Thermal Zone: Low
Machinability Index (proxy): 2000.0
Estimated Surface Roughness Ra (µm): 6.05
Thermal Damage Risk: No risk
-----------------------------------------
```

---

## 🧩 How to Extend

- Add new materials to `materials.csv`
- Extend `machining_utils` with custom models (e.g., tool wear, heat partition)
- Use `compute_machinability_index` and `classify_thermal_damage` as templates for new features

---

## 🔓 License

This project is released under the [GNU GENERAL PUBLIC LICENSE](LICENSE). Contributions welcome!

---
