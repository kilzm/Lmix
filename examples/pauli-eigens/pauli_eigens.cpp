#include <iostream>
#include <Eigen/Dense>

using namespace std;
using namespace Eigen;

int main() {
  Eigen::Matrix2cd X;
  X << 0.0, 1.0,
       1.0, 0.0;
  
  Eigen::Matrix2cd Y;
  Y << 0, complex<double>(0.0, -1.0),
       complex<double>(0.0, 1.0), 0;
  
  Eigen::Matrix2cd Z;
  Z << 1.0, 0.0,
       0.0, -1.0;

  vector<pair<string, Matrix2cd>> pauli_matrices;
  pauli_matrices.push_back(make_pair("X", X));
  pauli_matrices.push_back(make_pair("Y", Y));
  pauli_matrices.push_back(make_pair("Z", Z));

  Eigen::ComplexEigenSolver<Eigen::MatrixXcd> ces;
  
  for (auto &matrix_pair : pauli_matrices) {
    auto matrix = matrix_pair.second;
    std::cout << "pauli matrix: " << matrix_pair.first << endl << matrix << endl;
    ces.compute(matrix);

    auto eigenvalues = ces.eigenvalues();
    auto eigenvectors = ces.eigenvectors();

    std::cout << "eigenvalues:" << endl << eigenvalues << endl;
    std::cout << "eigenvectors:" << endl << eigenvectors << endl << endl;
  }

  return 0;
}
