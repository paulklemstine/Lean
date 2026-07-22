from typing import List
Matrix = List[List[float]]
def pull_back_basis(inverse_matrix: Matrix) -> Matrix:
    # Columns of the inverse comparison matrix are the pulled-back standard basis.
    return [[inverse_matrix[row][column] for row in range(len(inverse_matrix))] for column in range(len(inverse_matrix))]
