program P1

   implicit none

    real, dimension(2) :: point
    character(len=*), parameter :: OUT_FILE = 'data-P1.txt' ! Output file.
    character(len=*), parameter :: PLT_SAVE = 'plot-save-P1.plt'   ! Save
    integer :: i, fu        ! An int for file stuff
    integer :: start_time   ! For benchmarking


    open (action='write', file=OUT_FILE, newunit=fu, status='replace')

    start_time = time()

   do i = 1, 50000
    point = gen_point()
    write (fu, *) point(1), point(2)
   end do

   print *,  "\nPoints created in:" , time() - start_time , "seconds\n"

    call execute_command_line("sed -i 's/E/e/g' " // OUT_FILE)  ! Find and replace E with e
    call execute_command_line('gnuplot -p ' // PLT_SAVE)    ! Plot and save

    print *, "Points ploted in:" , time() - start_time , "seconds\n"


contains 

! Point generator
function gen_point()

    implicit none      
    
    real, dimension(2) :: gen_point     ! Initial gen_Point
    real :: choose_rand             ! Random number between 0 and 1
    integer :: n                    ! Loop index

    call random_number(gen_point)       ! Random initial gen_point


    do n = 1, 30
        call random_number(choose_rand)

        if ( choose_rand < 1.0/3 ) then
            call func1(gen_point)

        else if ( choose_rand < 2.0/3 ) then
            call func2(gen_point)
        else
            call func3(gen_point)
        end if

    end do

end function gen_point

! Our transformation functions
subroutine func1 (point_in)

    real, dimension(2) :: point_in
    real, dimension(2) :: v                  ! Translation  
    real :: r                                ! Scale

    r = 1.0/2
    v = (/ 0.0, 0.0 /)
    point_in = r*point_in + v

end subroutine func1

subroutine func2 (point_in)

    real, dimension(2) :: point_in
    real, dimension(2) :: v                  ! Translation  
    real :: r                                ! Scale

    r = 1.0/2
    v = (/ 0.25, sqrt(3.0)/4 /)
    point_in = r*point_in + v
    
end subroutine func2

subroutine func3 (point_in)

    real, dimension(2) :: point_in
    real, dimension(2) :: v                  ! Translation  
    real :: r                                ! Scale

    r = 1.0/2
    v = (/ 0.5, 0.0 /)
    point_in = r*point_in + v
    
end subroutine func3

end program P1
