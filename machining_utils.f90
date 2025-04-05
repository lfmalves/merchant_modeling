module machining_utils
  use machining_types
  implicit none

  ! === Estimated parameters (FINE TUNABLE) ===
  real(8), parameter :: eta_shear = 0.8d0              ! Shear energy efficiency (usually between 0.7 and 0.9)
  real(8), parameter :: k_v = 0.1d0                    ! Cutting speed influence on Ra (based on the literature)
  real(8), parameter :: k_w = 2.0d0                    ! Tool wear influence on Ra (based on the literature)
  real(8), parameter :: n_v = 0.3d0                    ! Vc exponent (based on the literature)
  real(8), parameter :: chip_partition_ratio = 0.3d0   ! Fraction of heat carried by chip (usually between 0.2 and 0.4)
  real(8), parameter :: default_tool_wear = 0.5d0      ! Simulated tool wear [0=new, 1=worn]

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

  subroutine compute_enhanced_surface_roughness(input, phi, Ra)
    type(MachiningInputs), intent(in) :: input
    real(8), intent(in) :: phi
    real(8), intent(out) :: Ra
    real(8) :: wear_index
    wear_index = default_tool_wear
    Ra = (input%t1 / tan(phi)) * (1.0d0 + k_v * input%Vc**(-n_v) + k_w * wear_index)
  end subroutine

  subroutine compute_partitioned_temperature(input, mat, result)
    type(MachiningInputs), intent(in) :: input
    type(Material), intent(in) :: mat
    type(MachiningResults), intent(inout) :: result
    result%delta_T = (eta_shear * result%Fs * result%Vs * (1.0d0 - chip_partition_ratio)) / &
                     (mat%density * mat%Cp * input%Vc)
  end subroutine

  subroutine classify_thermal_damage(delta_T, risk)
    real(8), intent(in) :: delta_T
    character(len=30), intent(out) :: risk
    if (delta_T < 200.0d0) then
      risk = 'No risk'
    elseif (delta_T < 400.0d0) then
      risk = 'Moderate risk'
    elseif (delta_T < 600.0d0) then
      risk = 'High risk'
    else
      risk = 'Severe risk'
    end if
  end subroutine

end module machining_utils
