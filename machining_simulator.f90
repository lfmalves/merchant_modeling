program machining_simulator
  use machining_types
  use machining_utils
  use machining_model
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

  subroutine print_results(mat, result)
    use machining_types
    implicit none
    type(Material), intent(in) :: mat
    type(MachiningResults), intent(in) :: result

    print *, '--------------------------------------------------------------------------'
    write(*,'(A45, F20.10)') 'Density (kg/m^3):', mat%density
    write(*,'(A45, F20.10)') 'Specific Heat (J/kg·K):', mat%Cp
    write(*,'(A45, F20.10)') 'Shear angle phi (deg):', result%phi_deg
    write(*,'(A45, F20.10)') 'Chip ratio r = t1 / t2:', result%chip_ratio
    write(*,'(A45, F20.10)') 'Shear force Fs (N):', result%Fs
    write(*,'(A45, F20.10)') 'Normal force Fn (N):', result%Fn
    write(*,'(A45, F20.10)') 'Shear stress tau_s (MPa):', result%tau_s
    write(*,'(A45, F20.10)') 'Specific Cutting Energy (J/mm^3):', result%SCE
    write(*,'(A45, F20.10)') 'Cutting Power (W):', result%power
    write(*,'(A45, ES20.10)') 'Approx. Temperature Rise (K):', result%delta_T
    write(*,'(A45, F20.10)') 'Machinability Index (proxy):', result%machinability_index
    write(*,'(A45, F20.10)') 'Estimated Surface Roughness Ra (µm):', result%Ra
    write(*,'(A45, A)') 'Thermal Zone:', trim(result%temp_zone)
    write(*,'(A45, A)') 'Thermal Damage Risk:', trim(result%thermal_damage_risk)
    print *, '--------------------------------------------------------------------------'
  end subroutine

end program machining_simulator
