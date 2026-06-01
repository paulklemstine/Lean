def cantor_diagonal(matrix):
    n = len(matrix)
    return [1 - matrix[i][i] for i in range(n)]