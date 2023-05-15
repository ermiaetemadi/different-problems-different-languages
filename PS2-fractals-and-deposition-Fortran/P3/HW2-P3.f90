program P1

   implicit none

    real, dimension(2) :: point
    integer, dimension(3000) :: eval_list   ! Matrix Rows
    complex, parameter :: C  = complex(-0.8, +0.16)
    character(len=*), parameter :: OUT_FILE = 'data-P3.txt' ! Output file.
    character(len=*), parameter :: PLT_SAVE = 'plot-save-P3.plt'   ! Save
    integer :: i, j, fu        ! An int for file stuff
    integer :: start_time   ! For benchmarking

   open (action='write', file=OUT_FILE, newunit=fu, status='replace')

    start_time = time()

    do i = 1, 3000
        do j = 1, 3000
            point = (/j, i/) - (/1500.0, 1500.0/)
            point = point / 1000
            eval_list(j) = eval_point(point)
        end do
        write (fu, *) eval_list
    end do
    close(fu)
    
    print *,  "\nPoints created in:" , time() - start_time , "seconds\n"
    
    call execute_command_line('gnuplot -p ' // PLT_SAVE)    ! Plot and save
    
    print *, "Points ploted in:" , time() - start_time , "seconds\n"


contains 

function eval_point(point_in)

    implicit none

    integer :: eval_point, n
    real, dimension(2) :: point_in
    complex :: comp_var

    comp_var = complex(point_in(1), point_in(2))

    do n = 1,100
        comp_var = comp_var ** 2 + C
        if (abs(comp_var) > 2) then
            eval_point = n
            exit
        end if
    end do

    eval_point = n

end function eval_point

end program P1
