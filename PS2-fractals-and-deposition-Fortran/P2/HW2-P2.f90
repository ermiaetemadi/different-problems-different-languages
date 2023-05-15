program P1

   implicit none

    real(kind=8),parameter :: pi=4.D0*datan(1.D0)
    real, dimension(2) :: point
    character(len=*), parameter :: OUT_FILE = 'data-P2.txt' ! Output file.
    character(len=*), parameter :: PLT_SAVE = 'plot-save-P2.plt'   ! Save
    integer :: i, fu        ! An int for file stuff
    integer :: start_time   ! For benchmarking

   open (action='write', file=OUT_FILE, newunit=fu, status='replace')

    start_time = time()

   do i = 1, 1000000
    point = gen_point()
    write (fu, *) point(1), point(2)
   end do
   close(fu)

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

    do n = 1, 20
        call random_number(choose_rand)

        if ( choose_rand < 1.0/4 ) then
            call func1(gen_point)
        else if ( choose_rand < 2.0/4 ) then
            call func2(gen_point)
        else if (choose_rand < 3.0/4 ) then
            call func3(gen_point)
        else
            call func4(gen_point)
        end if

    end do

end function gen_point

! Our transformation functions
subroutine func1 (point_in)     ! Right leaf

    implicit none

    real, dimension(2) :: point_in
    real, dimension(2,2) :: Rot                !  Rotation
    real, dimension(2) :: v                  ! Translation  
    real :: r                                ! Scale
    real :: theta = -60.0 * (pi/180)

    Rot = transpose(reshape((/ cos(theta), -sin(theta), sin(theta), cos(theta) /), shape(Rot)))
    r = 1.0/5
    v = (/ 0.0, 0.025 /)
    point_in(1) = - point_in(1)     ! Mirror 
    point_in = r*matmul(Rot, point_in) + v

end subroutine func1

subroutine func2 (point_in)         ! Left leaf

    implicit none

    real, dimension(2) :: point_in
    real, dimension(2,2) :: Rot              ! Rotation
    real, dimension(2) :: v                  ! Translation  
    real :: r                                ! Scale
    real :: theta = 60.0 * (pi/180)

    Rot = transpose(reshape((/ cos(theta), -sin(theta), sin(theta), cos(theta) /), shape(Rot)))
    r = 1.0/5
    v = (/ 0.0, 0.05 /)
    point_in = r*matmul(Rot, point_in) + v
    
end subroutine func2

subroutine func3 (point_in)         ! Middle

    implicit none

    real, dimension(2) :: point_in
    real, dimension(2,2) :: Rot              !  Rotation
    real, dimension(2) :: v                  ! Translation  
    real :: r                                ! Scale
    real :: theta = -15.0 * (pi/180)

    Rot = transpose(reshape((/ cos(theta), -sin(theta), sin(theta), cos(theta) /), shape(Rot)))
    r = 0.8
    v = (/ 0.0, 0.075 /)
    point_in = r*matmul(Rot, point_in) + v
    
end subroutine func3

subroutine func4 (point_in)

    implicit none

    real, dimension(2) :: point_in
    real, dimension(2,2) :: Rot              !  Rotation
    real, dimension(2) :: v                  ! Translation  
    real :: rx, ry                                ! Scale
    real :: theta = -15.0 * (pi/180)

    Rot = transpose(reshape((/ cos(theta), -sin(theta), sin(theta), cos(theta) /), shape(Rot)))
    ry = 0.2
    rx = 1.0/100
    v = (/ 0.0, 0.0 /)
    point_in = matmul(Rot, point_in) + v
    point_in(1) = rx*point_in(1)
    point_in(2) = ry*point_in(2)
    
end subroutine func4

end program P1
