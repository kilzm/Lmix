program mat_mult

  implicit none
  integer, parameter :: n = 4000
  real(8), allocatable :: A(:,:), B(:,:), C(:,:)
  integer :: i, j, k
  real(8) :: alpha, beta
  integer :: lda, ldb, ldc

  allocate(A(n, n), B(n, n), C(n, n))

  do i = 1, n
    do j = 1, n
      A(i, j) = i - j
      B(i, j) = i + j
    end do
  end do

  alpha = 1.0
  beta = 0.0

  lda = n
  ldb = n
  ldc = n

  call dgemm('T', 'T', n, n, n, alpha, A, lda, B, ldb, beta, C, ldc)

  write(*, '(A, F0.2)'), "C(1, 1): ", C(1, 1)

  deallocate(A, B, C)


end program mat_mult
