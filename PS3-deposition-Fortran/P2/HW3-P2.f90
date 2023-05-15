program P1
    
   implicit none

    integer, parameter :: L = 200
    integer :: h(L) = 0
    integer, parameter :: steps = 30000
    integer, parameter :: exp_steps = 500000
    integer, parameter :: n_colors = 5      ! Number of colors used in ploting
    integer, parameter :: n_samples = 100      ! Number of samples form mean and variance
    integer, parameter :: n_exp = 100      ! Number of expriments for calculating mean and variance
    real, dimension(n_samples) :: mean_list = 0, var_list = 0 
    integer :: color = 1
    integer :: i, j, j_dest, k, fu        ! int for loop and file stuff
    integer :: start_time   ! For benchmarking
    integer :: sat_index    ! Saturation point index
    double precision :: A_mat(n_samples, 2), b_mat(n_samples, 1), res_mat(n_samples, 1)   ! Matrix spaces for least squares stuff
    character(len=*), parameter :: OUT_FILE = 'data-P2.txt' ! Output file.
    character(len=*), parameter :: PLT_SAVE = 'plot-P2.plt'   ! Save
    character(len=*), parameter :: VAR_FILE = 'var-P2.txt'  ! log of var for ploting



    call random_seed()       ! Restartig the seed so we are sure we have the randomness

   open (action='write', file=OUT_FILE, newunit=fu, status='replace')
    start_time = time()

    do i = 1, steps
        j = get_rpos(L)
        j_dest = find_dest(j)
        if (j==j_dest) then
            h(j) = h(j) + 1
        else
            h(j) = h(j_dest)
        end if

        if (mod(i, steps/n_colors) == 0) then
            color = color + 1
        end if

        if (i == steps)  then       ! An small thing which i don't know how to describe in this comment 
            color = color - 1 
        end if
            
        write (fu, *) j, h(j), color
    end do
    close(fu)
    
    print *,  "\nPoints created in:" , time() - start_time , "seconds\n"
    start_time = time()

    
    call execute_command_line('gnuplot -p ' // PLT_SAVE)    ! Plot and save
    
    print *, "Points ploted in:" , time() - start_time , "seconds\n"


    start_time = time()

    do i = 1, n_exp
        h = 0
        color = 1       ! This color won't be displayed
        do k = 1, exp_steps
            j = get_rpos(L)
            j_dest = find_dest(j)
            if (j==j_dest) then
                h(j) = h(j) + 1
            else
                h(j) = h(j_dest)
            end if

            if (mod(k, exp_steps/n_samples) == 0) then
                mean_list(color) = mean_list(color) + calc_mean(real(h)) / n_exp
                var_list(color) = var_list(color) + calc_variance(real(h)) / n_exp
                color = color + 1
            end if

        end do
    end do

    ! print *, "Mean h:", mean_list
    ! print *, "Var h:", var_list, "\n"

    A_mat(:, 1) = 1
    A_mat(:, 2) = log((/ (1.0*i*(exp_steps/n_samples), i=1,n_samples) /))
    b_mat(:, 1) = log(var_list)

    sat_index = 11       ! Based on previous results

    res_mat = calc_LLS(A_mat(1:sat_index, :), b_mat(1:sat_index, :), sat_index, 2)      ! Fitting a line for power law regime

    print *, "Line coefficents:", res_mat(1:2, 1)
    print *, "w_s: ", calc_mean(real(b_mat(sat_index+1:n_samples, 1)))           ! w_s can be estimated by the mean of variance in saturated regime 
    
    open (action='write', file=VAR_FILE, newunit=fu, status='replace')
    do i = 1,n_samples
        write (fu, *) A_mat(i, 2), b_mat(i, 1)
    end do
    close(fu)

    print *,  "\n Huge points calculated in:" , time() - start_time , "seconds\n"


    contains 

function get_rpos(L_in)     ! Selecting a random position

    implicit none

    integer :: get_rpos 
    integer :: L_in
    real(kind = 16) :: rand_val

    call random_number(rand_val)
    
    do while (rand_val == 1.0)
        call random_number(rand_val)
    end do

    get_rpos = floor((L_in)  * rand_val) + 1

end function get_rpos

function find_dest(j_in)      ! Finding the particle's destination
    
    implicit none
    
    integer :: j_in,j_l, j_r, find_dest

    j_l = j_in - 1
    j_r = j_in + 1
    
    if (j_l == 0) then
        j_l = 200
    end if

    if (j_r == 201) then
        j_r = 1
    end if

    find_dest = j_in

    if (h(j_l) > h(j_in)) then

        if (h(j_l) > h(j_r)) then
            find_dest = j_l
        else if (h(j_l) < h(j_r)) then
            find_dest = j_r

        end if

    else if (h(j_r) > h(j_in)) then
        find_dest = j_r
    
    end if

end function find_dest

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
