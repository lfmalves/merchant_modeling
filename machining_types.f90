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


module machining_utils
  use machining_types
  implicit none
contains

  subroutine classify_temperature_zone(delta_T, zone)
    real(8), intent(in) :: delta_T
    character(len=20), intent(out) :: zone
    if (delta_T < 200.0d0) then
      zone = 'Low'
    elseif (delta_T < 400.0d0) then
      zone = 'Moderate'
    else
      zone = 'High'
    end if
  end subroutine

  function compute_machinability_index(SCE) result(index)
    real(8), intent(in) :: SCE
    real(8) :: index
    if (SCE > 0.0d0) then
      index = 1000.0d0 / SCE
    else
      index = 0.0d0
    end if
  end function

end module machining_utils
