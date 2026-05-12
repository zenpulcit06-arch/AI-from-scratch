module Linear_regression
    implicit none

    private 
    public fit , standardize
    
contains
subroutine fit(y,x,size_of_data, rate_of_learn, n_feature , weight , bias,iteration ,mse)
    use, intrinsic :: iso_fortran_env

    implicit none
    real(real64), intent(inout) :: y(:) ,x(: , :), bias 
    real(real64), intent(inout) :: mse
    real(real64), intent(in) :: rate_of_learn 
    integer(int64), intent(in) :: size_of_data, iteration, n_feature
    integer :: i
    real(real64), intent(inout) :: weight(:)
    real(real64) :: dw(n_feature), db 
    real(real64), allocatable :: y_predicted(:) 

    weight(:) = 0.0_real64
    bias = 0.0_real64
    allocate(y_predicted(size_of_data))

    do i = 1,iteration
        y_predicted = matmul(x,weight) + bias

        dw = (-2.0_real64/size_of_data)*matmul(transpose(x), y_predicted - y)
        db = (-2.0_real64/size_of_data)*sum(y_predicted - y)

        weight = weight + rate_of_learn*dw
        bias = bias + rate_of_learn*db

    end do

    y_predicted = matmul(x,weight) + bias
    mse = sum((y_predicted - y)**2)/size_of_data

    deallocate(y_predicted)

end subroutine fit

subroutine standardize(x,n_feature, size_of_data,mean,sd , z_score)
    use, intrinsic :: iso_fortran_env
    implicit none
    real(real64), intent(in) :: x(: , :)
    real(real64),  allocatable :: z_score(: , :)
    integer(int64), intent(in) :: n_feature, size_of_data
    real(real64), intent(inout) :: mean(n_feature) , sd(n_feature)
    integer(int64) :: j

    allocate(z_score(size_of_data,n_feature))

    do concurrent(j = 1:n_feature)
    mean(j) = (1.0_real64/size_of_data)*sum(x(:,j))
    sd(j) = sqrt(sum((x(:,j) - mean(j))**2)/size_of_data)

    if (sd(j) .gt. 1.0e-12_real64 ) then
        z_score(:,j) = (x(:,j) - mean(j))/sd(j)
    else 
        z_score(:,j) = 0.0_real64      
    end if
    end do

end subroutine standardize

end module Linear_regression
program main
    use, intrinsic :: iso_fortran_env
    use :: Linear_regression

    implicit none
    integer(int64) :: size_of_data,i,iteration,mode, n_feature , j
    real(real64), allocatable :: y(:) , x(:,:) , x_scalled(:,:)
    real(real64) :: y_predition,rate_of_learn, bias
    real(real64) :: mse
    real(real64), allocatable :: weight(:), x_input(:) , mean(:), sd(:)
    character(len = 1000):: filename

    print *, 'Enter size of data '
    read(*,*) size_of_data

    print *, 'Enter number of iteration '
    read(*,*) iteration

    print *, 'Enter number of features '
    read(*,*) n_feature

    allocate(weight(n_feature))
    allocate(x_input(n_feature))
    allocate(y(size_of_data))
    allocate(x(size_of_data,n_feature))
    allocate(mean(n_feature))
    allocate(sd(n_feature))

    weight = 0.0_real64
    x_input = 0.0_real64
    mean = 0.0_real64
    sd = 0.0_real64

    print *,'Enter rate of learn'
    read(*,*) rate_of_learn

    mode = 0
    print *, 'Enter 1 for manual entry or 2 for csv entry'
    read(*,*) mode
    if ( mode .eq. 2 ) then

        print *, 'Enter Filename'
        read(*,*) filename
        print *, 'Reading data from',trim(filename) ,'...'
        open(unit=10, file=trim(filename), status='old', action='read')

            do i = 1, size_of_data
            read(10, *) x(i, :), y(i)
        end do

    close(10)
    print *, 'Data loaded successfully.'

    else
    do i = 1, size_of_data
        do j = 1, n_feature
            print *, 'x',i,j
            read(*,*) x(i,j)
        end do

        print *, 'y',i
        read(*,*) y(i)
    end do
    end if

    print *, 'scalling data'
    call standardize(x,n_feature,size_of_data,mean,sd,x_scalled)
    print *, 'fitting the plot.....'
    call fit(y,x_scalled,size_of_data,rate_of_learn,n_feature,weight,bias,iteration,mse)
    mode = 0

    print *, 'mean =', mean
    print *, 's.d. =', sd
    print *, 'weight =', weight
    print *, 'mse =', mse

    do while (.true.)
        print *,'enter 1 to exit or enter 2 to continue'
        read(*,*) mode

        if ( mode .eq. 1 ) then
            exit
        end if

        print *, 'Enter value you want to predict'
        do j = 1 , n_feature
            print *,'Enter feature',j
            read(*,*) x_input(j)
        end do
        
        x_input = (x_input - mean)/sd
        y_predition = dot_product(weight,x_input) + bias

        print *, 'Your predicted value', y_predition
    end do

    print *, 'Press enter to close terminal'
    read(*,*)

    
end program main