#include <iostream>
#include <Eigen/Dense>

int main() {
  Eigen::Matrix2cd X;
  X << 0.0, 1.0,
       1.0, 0.0;
  
  Eigen::Matrix2cd Y;
  Y << 0, std::complex<double>(0.0, -1.0),
       std::complex<double>(0.0, 1.0), 0;
  
  Eigen::Matrix2cd Z;
  Z << 1.0, 0.0,
       0.0, -1.0;

  std::vector<std::pair<std::string, Eigen::Matrix2cd>> pauli_matrices;
  pauli_matrices.push_back(make_pair("X", X));
  pauli_matrices.push_back(make_pair("Y", Y));
  pauli_matrices.push_back(make_pair("Z", Z));

  Eigen::ComplexEigenSolver<Eigen::MatrixXcd> ces;
  
  for (auto &matrix_pair : pauli_matrices) {
    auto matrix = matrix_pair.second;
    std::cout << "pauli matrix: " << matrix_pair.first << std::endl << matrix << std::endl;
    ces.compute(matrix);

    auto eigenvalues = ces.eigenvalues();
    auto eigenvectors = ces.eigenvectors();

    std::cout << "eigenvalues:" << std::endl << eigenvalues << std::endl;
    std::cout << "eigenvectors:" << std::endl << eigenvectors << std::endl << std::endl;
  }

  return 0;
}
