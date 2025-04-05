module machining_model
  use machining_types
  implicit none
contains

  subroutine calculate_machining(input, mat, result)
    use machining_types
    use machining_utils
    type(MachiningInputs), intent(in) :: input
    type(Material), intent(in) :: mat
    type(MachiningResults), intent(out) :: result
    real(8) :: rake_angle_rad, beta
    real(8) :: cos_phi, sin_phi, cos_beta_phi, sin_beta_phi

    rake_angle_rad = input%rake_angle_deg * atan(1.0d0) / 45.0d0
    beta = atan(input%mu)
    result%chip_ratio = input%t1 / input%t2
    result%phi = 0.25d0 * 4.0d0 * atan(1.0d0) - 0.5d0 * (beta - rake_angle_rad)
    result%phi_deg = result%phi * 45.0d0 / atan(1.0d0)

    cos_phi = cos(result%phi)
    sin_phi = sin(result%phi)
    cos_beta_phi = cos(beta - result%phi)
    sin_beta_phi = sin(beta - result%phi)

    result%Fs = input%Fc * cos_beta_phi - input%Ft * sin_beta_phi
    result%Fn = input%Fc * sin_beta_phi + input%Ft * cos_beta_phi
    result%shear_area = (input%t1 / sin_phi) * input%w
    result%tau_s = result%Fs / result%shear_area
    result%MRR = input%t1 * input%w * input%Vc
    result%SCE = input%Fc * input%Vc / result%MRR
    result%Vs = input%Vc / cos_phi
    result%power = input%Fc * input%Vc

    call compute_partitioned_temperature(input, mat, result)
    call classify_thermal_damage(result%delta_T, result%thermal_damage_risk)
    call compute_enhanced_surface_roughness(input, result%phi, result%Ra)
    call classify_temperature_zone(result%delta_T, result%temp_zone)
    result%machinability_index = compute_machinability_index(result%SCE)
  end subroutine
  
end module machining_model
