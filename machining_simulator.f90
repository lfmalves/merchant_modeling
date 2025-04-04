program machining_simulator
  use machining_types
  use machining_utils
  implicit none

  integer, parameter :: max_materials = 100
  type(Material) :: all_materials(max_materials), filtered_materials(max_materials)
  character(len=str_len) :: unique_categories(max_materials)
  integer :: n_materials, n_categories, n_filtered
  integer :: i, j, cat_choice, mat_choice
  character(len=str_len) :: selected_category
  logical :: category_found

  type(MachiningInputs) :: input
  type(MachiningResults) :: result
  type(Material) :: mat
  character(len=100) :: output_filename
  logical :: write_to_file
  character(len=200) :: line
  integer :: ios

  open(unit=10, file='materials.csv', status='old', action='read', iostat=ios)
  if (ios /= 0) then
    print *, 'Error opening materials.csv'
    stop
  end if

  read(10, *) ! Skip header
  n_materials = 0
  do
    read(10, '(A)', iostat=ios) line
    if (ios /= 0) exit
    n_materials = n_materials + 1
    call parse_csv_line(trim(line), all_materials(n_materials)%category, &
                        all_materials(n_materials)%name, &
                        all_materials(n_materials)%density, &
                        all_materials(n_materials)%Cp)
  end do
  close(10)

  n_categories = 0
  do i = 1, n_materials
    category_found = .false.
    do j = 1, n_categories
      if (trim(all_materials(i)%category) == trim(unique_categories(j))) then
        category_found = .true.
        exit
      end if
    end do
    if (.not. category_found) then
      n_categories = n_categories + 1
      unique_categories(n_categories) = trim(all_materials(i)%category)
    end if
  end do

  print *, 'Select a material category:'
  do i = 1, n_categories
    print *, i, ') ', trim(unique_categories(i))
  end do
  read *, cat_choice
  if (cat_choice < 1 .or. cat_choice > n_categories) stop 'Invalid category selection.'
  selected_category = trim(unique_categories(cat_choice))

  n_filtered = 0
  do i = 1, n_materials
    if (trim(all_materials(i)%category) == selected_category) then
      n_filtered = n_filtered + 1
      filtered_materials(n_filtered) = all_materials(i)
    end if
  end do

  print *, 'Select a specific material:'
  do i = 1, n_filtered
    print *, i, ') ', trim(filtered_materials(i)%name)
  end do
  read *, mat_choice
  if (mat_choice < 1 .or. mat_choice > n_filtered) stop 'Invalid material selection.'
  mat = filtered_materials(mat_choice)

  call get_command_argument(1, output_filename)
  write_to_file = trim(output_filename) /= ''

  print *, 'Enter rake angle (degrees):'
  read *, input%rake_angle_deg
  print *, 'Enter coefficient of friction (mu):'
  read *, input%mu
  print *, 'Enter uncut chip thickness t1 (mm):'
  read *, input%t1
  print *, 'Enter chip thickness t2 (mm):'
  read *, input%t2
  print *, 'Enter width of cut w (mm):'
  read *, input%w
  print *, 'Enter cutting speed Vc (m/s):'
  read *, input%Vc
  print *, 'Enter cutting force Fc (N):'
  read *, input%Fc
  print *, 'Enter thrust force Ft (N):'
  read *, input%Ft

  call calculate_machining(input, mat, result)
  call print_results(mat, result)

  if (write_to_file) then
    open(unit=20, file=trim(output_filename), status='replace')
    write(20, *) 'Material selected: ', trim(mat%name)
    write(20, *) 'Density (kg/m^3): ', mat%density
    write(20, *) 'Specific Heat (J/kg.K): ', mat%Cp
    write(20, *) 'Shear angle phi (deg): ', result%phi_deg
    write(20, *) 'Chip ratio r = t1 / t2: ', result%chip_ratio
    write(20, *) 'Shear force Fs (N): ', result%Fs
    write(20, *) 'Normal force Fn (N): ', result%Fn
    write(20, *) 'Shear stress tau_s (MPa): ', result%tau_s
    write(20, *) 'Specific Cutting Energy (J/mm^3): ', result%SCE
    write(20, *) 'Cutting Power (W): ', result%power
    write(20, *) 'Approx. Temperature Rise (K): ', result%delta_T
    write(20, *) 'Thermal Zone: ', trim(result%temp_zone)
    write(20, *) 'Machinability Index (proxy): ', result%machinability_index
    write(20, *) 'Estimated Surface Roughness Ra (µm): ', result%Ra
    write(20, *) 'Thermal Damage Risk: ', trim(result%thermal_damage_risk)
    close(20)
    print *, 'Results saved to ', trim(output_filename)
  end if

contains

  subroutine parse_csv_line(line, cat, mat, dens, cp)
    character(len=*), intent(in) :: line
    character(len=str_len), intent(out) :: cat, mat
    real(8), intent(out) :: dens, cp
    integer :: p1, p2, p3
    character(len=100) :: part1, part2, part3, part4

    p1 = index(line, ',')
    p2 = index(line(p1+1:), ',') + p1
    p3 = index(line(p2+1:), ',') + p2

    part1 = adjustl(line(1:p1-1))
    part2 = adjustl(line(p1+1:p2-1))
    part3 = adjustl(line(p2+1:p3-1))
    part4 = adjustl(line(p3+1:))

    cat = part1
    mat = part2
    read(part3, *) dens
    read(part4, *) cp
  end subroutine

  subroutine calculate_machining(input, mat, result)
    use machining_types
    use machining_utils
    type(MachiningInputs), intent(in) :: input
    type(Material), intent(in) :: mat
    type(MachiningResults), intent(out) :: result
    real(8) :: eta, rake_angle_rad, beta
    real(8) :: cos_phi, sin_phi, cos_beta_phi, sin_beta_phi

    eta = 0.8d0
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
    result%delta_T = (eta * result%Fs * result%Vs) / (mat%density * mat%Cp * input%Vc)
    result%power = input%Fc * input%Vc
    call classify_thermal_damage(result%delta_T, result%thermal_damage_risk)
    result%Ra = input%t1 / tan(result%phi)
    call classify_temperature_zone(result%delta_T, result%temp_zone)
    result%machinability_index = compute_machinability_index(result%SCE)
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

  subroutine print_results(mat, result)
    use machining_types
    type(Material), intent(in) :: mat
    type(MachiningResults), intent(in) :: result
    print *, '-----------------------------------------'
    print *, 'Material selected: ', trim(mat%name)
    print *, 'Density (kg/m^3): ', mat%density
    print *, 'Specific Heat (J/kg.K): ', mat%Cp
    print *, 'Shear angle phi (deg): ', result%phi_deg
    print *, 'Chip ratio r = t1 / t2: ', result%chip_ratio
    print *, 'Shear force Fs (N): ', result%Fs
    print *, 'Normal force Fn (N): ', result%Fn
    print *, 'Shear stress tau_s (MPa): ', result%tau_s
    print *, 'Specific Cutting Energy (J/mm^3): ', result%SCE
    print *, 'Cutting Power (W): ', result%power
    print *, 'Approx. Temperature Rise (K): ', result%delta_T
    print *, 'Thermal Zone: ', trim(result%temp_zone)
    print *, 'Machinability Index (proxy): ', result%machinability_index
    print *, 'Estimated Surface Roughness Ra (µm): ', result%Ra
    print *, 'Thermal Damage Risk: ', trim(result%thermal_damage_risk)
    print *, '-----------------------------------------'
  end subroutine

end program machining_simulator
