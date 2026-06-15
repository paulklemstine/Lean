from typing import List
Matrix = List[List[int]]

def add_identity(C: Matrix) -> Matrix:
    n = len(C)
    return [[C[i][j] + (1 if i == j else 0) for j in range(n)] for i in range(n)]

def sub_identity(H: Matrix) -> Matrix:
    n = len(H)
    return [[H[i][j] - (1 if i == j else 0) for j in range(n)] for i in range(n)]
