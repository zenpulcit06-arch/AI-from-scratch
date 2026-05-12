module Polynomial_reg
    use, intrinsic :: iso_fortran_env
    use Logistic_regression
    implicit none
    private
    public make_poly
    
contains
    function make_poly(x, degree, sample_size) result(poly)
        implicit none
        real(real64), allocatable :: poly (: ,:)
        integer(int64), intent(in) :: degree , sample_size
        real(real64), intent(in) :: x(:)
        integer(int64) :: i,j

        allocate(poly(sample_size, degree))
        do concurrent (i = 1:sample_size)
            do concurrent (j = 1 : degree)
                poly(i,j) = x(i)**j
            end do
        end do
    end function make_poly
end module Polynomial_reg

program main
    use, intrinsic :: iso_fortran_env
    use :: Logistic_regression
    use :: Polynomial_reg 
    implicit none
    real(real64), allocatable :: x(:), y(:), x_poly(: , :), x_scaled(: , :), sd(:), weight(:), mean(:),x_input(:)
    real(real64) :: bias, rate_of_learn, loss, mse, x_val, y_prediction
    integer(int64) :: degree, sample_size, iteration, mode, i,j
    character(len = 1000) :: filename
    
    print *, 'Enter degree of polynomial'
    read(*,*) degree

    print *, 'Enter rate of learning'
    read(*,*) rate_of_learn

    print *, 'Enter iteration'
    read(*,*) iteration

    print *, 'Enter sample size'
    read(*,*) sample_size
    allocate(x(sample_size), y(sample_size))
    allocate(mean(degree), sd(degree), weight(degree),x_input(degree))

    mode = 0
    print *, 'Enter 1 for manual entry or 2 for csv entry'
    read(*,*) mode
    if ( mode .eq. 2 ) then

        print *, 'Enter Filename'
        read(*,*) filename
        print *, 'Reading data from',trim(filename) ,'...'
        open(unit=10, file=trim(filename), status='old', action='read')

            do i = 1, sample_size
            read(10, *) x(i), y(i)
        end do

    close(10)
    print *, 'Data loaded successfully.'

    else
    do i = 1, sample_size

        print *, 'x',i
        read(*,*) x(i)

        print *, 'y',i
        read(*,*) y(i)
    end do
    end if
    
    x_poly = make_poly(x,degree,sample_size)
    
    print *,'Standerzising.....'
    call standardize(x_poly,degree,sample_size,mean,sd,x_scaled)

    print *, 'Fitting.....'
    call fit(y,x_scaled,sample_size,rate_of_learn,degree,weight,bias,iteration,loss,mse)

    print *, 'mean = ', mean
    print *, 'bias = ', bias
    print *, 'weight =', weight
    print *, 's.d. = ', sd
    print *, 'loss =', loss
    print *, 'mse = ', mse

    do while (.true.)
        print *, '-----------------------------------------'
        print *, 'Enter a value to predict (or -999 to exit):'
        read(*,*) x_val
        
        if (x_val == -999.0_real64) exit

        ! Expand and scale the input point
        do j = 1, degree
            x_input(j) = (x_val**j - mean(j)) / sd(j)
        end do
        
        y_prediction = sigmoid(dot_product(weight, x_input) + bias)
        
        print *, 'Input Value :', x_val
        print *, 'Probability :', y_prediction
        
        if (y_prediction >= 0.5_real64) then
            print *, 'Classification: POSITIVE (1)'
        else
            print *, 'Classification: NEGATIVE (0)'
        end if
    end do

    print *, 'Project completed. Press Enter to exit.'
    read(*,*)

end program main