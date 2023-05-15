program P1
    
   implicit none

    integer, parameter :: L = 200
    integer, dimension(L) :: h = 0
    integer, parameter :: steps = 50000 
    integer            :: color = 1
    real, dimension(5) :: mean_list, var_list
    integer :: i, j, fu        ! An int for file stuff
    integer :: start_time   ! For benchmarking
    double precision :: A_mat(5, 2), b_mat(5, 1), res_mat(5, 1)   ! Matrix spaces for least squares stuff
    character(len=*), parameter :: OUT_FILE = 'data-P4.txt' ! Output file.
    character(len=*), parameter :: PLT_SAVE = 'plot-save-P4.plt'   ! Save
    character(len=*), parameter :: VAR_FILE = 'var-P4.txt'  ! log of var for ploting




   open (action='write', file=OUT_FILE, newunit=fu, status='replace')


    start_time = time()

    do i = 1, steps
        j = get_rpos(L)
        h(j) = h(j) + 1

        if (mod(i, 10000) == 0) then
            mean_list(color) = calc_mean(real(h))
            var_list(color) = calc_variance(real(h))
            color = color + 1
        end if

        if (i == 50000)  then       ! An small thing which i don't know how to describe in this comment 
            color = color - 1 
        end if
            
        write (fu, *) j, h(j), color
    end do
    close(fu)
    
    print *,  "\nPoints created in:" , time() - start_time , "seconds\n"
    
    call execute_command_line('gnuplot -p ' // PLT_SAVE)    ! Plot and save
    
    print *, "Points ploted in:" , time() - start_time , "seconds\n"

    print *, "Mean h:", mean_list
    print *, "Var h:", var_list, "\n"

    A_mat(:, 1) = 1
    A_mat(:, 2) = log((/1000.0, 2000.0, 3000.0, 4000.0, 5000.0/))
    b_mat(:, 1) = log(var_list)

    res_mat = calc_LLS(A_mat, b_mat, 5, 2)

    print *, "Line coefficents:", res_mat(1:2, 1)
    
    open (action='write', file=VAR_FILE, newunit=fu, status='replace')
    do i = 1,5
        write (fu, *) A_mat(i, 2), b_mat(i, 1)
    end do
    close(fu)

    contains 

function get_rpos(L_in)     ! Selecting a random position

    implicit none

    integer :: get_rpos 
    integer :: L_in
    real :: rand_val

    call random_number(rand_val)
    get_rpos = floor((L_in - 1)*rand_val) + 1

end function get_rpos

function calc_mean(vec_in)      ! Calculates mean

    implicit none 

    real, dimension(:) :: vec_in
    real               :: calc_mean

    calc_mean = sum(vec_in) / size(vec_in)

end function calc_mean

function calc_variance(vec_in)      ! Calulates variacne

    real, dimension(:) :: vec_in
    real               :: mean, calc_variance
    real, dimension(size(vec_in)) :: delta

    mean = calc_mean(vec_in)
    delta = vec_in - mean
    calc_variance = dot_product(delta, delta) / size(vec_in)

end function calc_variance

function calc_LLS(A, b, N, M)     ! Calculates Linear Least Squares answer with LAPACK lib

    integer :: N
    integer :: M
    double precision, dimension(N, M) :: A
    double precision, dimension(N, 1) :: b
    double precision, dimension(N, 1) :: calc_LLS
    integer :: LWORK
    double precision :: A_copy(N,M), b_copy(N, 1), WORK(2*(N+M))
    integer :: info

    A_copy = A
    b_copy = b
    LWORK = 2*(N+M)

    
    call DGELS('N', N, M, 1, A_copy, N, b_copy, N, WORK, LWORK, info)
    
    print *, "DGELS info:", info, "\n"
    calc_LLS = b_copy

end function calc_LLS
end program P1
