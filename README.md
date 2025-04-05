# 🛠️ Merchant's Theory of Chip Formation — Fortran CLI Simulator

A modular, open-source **command-line simulator** written in **modern Fortran**, this tool performs machining analysis based on **Merchant’s theory** of orthogonal cutting. It models chip formation assuming idealized shear deformation and sharp tool geometry, with extensions for thermal effects and surface finish prediction.

---

## 🎯 Use Cases

- 🧑‍🏭 **Process engineers** evaluating cutting efficiency and surface quality
- 🎓 **Students** studying metal cutting theory, forces, temperature rise, and chip mechanics
- 🔬 **Researchers** modeling chip-tool-workpiece interaction and heat transfer

---

## ✨ Features

- 📦 Reads material data from `materials.csv` (density, specific heat, category, name)
- 🔬 Physics-based calculations:
  - Shear angle (ϕ) and chip ratio
  - Shear force and normal force on shear plane
  - Shear stress and specific cutting energy (SCE)
  - Material removal rate (MRR)
  - Cutting power
  - Advanced temperature rise using chip-tool heat partitioning
  - Surface roughness prediction based on tool wear and cutting speed
  - Thermal damage classification
  - Machinability index proxy
- 💾 Optional output to `.txt` file
- 🔩 Clean, modular Fortran 90 code
- 🔁 Easily extensible with new models and inputs

---

## 🏗️ Build Instructions

```bash
sudo apt install gfortran
chmod +x build.sh
./build.sh
```

---

## 🚀 How to Run

### Interactive mode:
```bash
./machining_simulator
```

### Output to file:
```bash
./machining_simulator results.txt
```

---

## 📥 User Input Prompts

1. Select **material category**
2. Select **specific material**
3. Enter values for:
   - `Rake angle` (degrees)
   - `Coefficient of friction` (μ)
   - `Uncut chip thickness t₁` (mm)
   - `Chip thickness t₂` (mm)
   - `Width of cut w` (mm)
   - `Cutting speed Vc` (m/s)
   - `Cutting force Fc` (N)
   - `Thrust force Ft` (N)

---

## 🧮 What It Calculates

| Quantity                    | Description                                  |
|----------------------------|----------------------------------------------|
| Shear angle (ϕ)            | Based on Merchant’s theory                   |
| Chip ratio (r)             | t₁ / t₂                                      |
| Shear force (Fs), Normal force (Fn) | On shear plane                   |
| Shear stress (τₛ)          | Fs / shear area                              |
| Specific Cutting Energy    | Cutting energy per volume                    |
| MRR                        | Material removal rate (mm³/s)                |
| Cutting Power              | Fc × Vc (W)                                  |
| Temperature Rise (ΔT)      | Based on heat partitioning model             |
| Thermal Zone               | Low, Moderate, High (qualitative)            |
| Surface Roughness (Ra)     | Includes cutting speed and tool wear effects |
| Thermal Damage Risk        | Risk classification based on ΔT             |
| Machinability Index        | Inverse of SCE (proxy only)                  |

---

## 🔧 Tunable Model Parameters

The following constants are estimated based on common machining behavior. You can adjust them in the `machining_utils.f90` module:

```fortran
real(8), parameter :: eta_shear = 0.8d0              ! Efficiency of shear energy
real(8), parameter :: chip_partition_ratio = 0.3d0   ! Fraction of heat to chip
real(8), parameter :: default_tool_wear = 0.5d0      ! Wear index [0=new, 1=worn]
real(8), parameter :: k_v = 0.1d0                    ! Ra speed sensitivity
real(8), parameter :: k_w = 2.0d0                    ! Ra wear sensitivity
real(8), parameter :: n_v = 0.3d0                    ! Vc exponent in Ra model
```

### Example Impact

- Increase `chip_partition_ratio` to simulate better chip cooling
- Decrease `eta_shear` to simulate energy loss in vibration or friction
- Increase `k_w` to simulate aggressive wear effect on finish

---

## 📤 Sample Output

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

## 🔓 License

This project is released under the [GNU GPL v3 License](LICENSE).

Contributions, forks, and improvements are welcome!

