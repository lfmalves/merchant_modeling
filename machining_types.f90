module machining_types
  implicit none
  integer, parameter :: str_len = 60

  type :: Material
    character(len=str_len) :: category
    character(len=str_len) :: name
    real(8) :: density
    real(8) :: Cp
  end type Material

  type :: MachiningInputs
    real(8) :: rake_angle_deg, mu, t1, t2, w, Vc, Fc, Ft
  end type MachiningInputs

  type :: MachiningResults
    real(8) :: phi, phi_deg, chip_ratio
    real(8) :: Fs, Fn, shear_area, tau_s, SCE, Vs, delta_T, MRR, power, machinability_index
    real(8) :: Ra
    character(len=30) :: thermal_damage_risk
    character(len=20) :: temp_zone
  end type MachiningResults
end module machining_types
