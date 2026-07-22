from __future__ import annotations
from typing import List

Matrix = List[List[int]]

Q_L: Matrix = [[1, 0, 0], [0, 1, 0], [0, 0, -1]]
GENS = {
    'A': [[1, -2, 2], [2, -1, 2], [2, -2, 3]],
    'B': [[1, 2, 2], [2, 1, 2], [2, 2, 3]],
    'C': [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]],
}


def matmul(M: Matrix, N: Matrix) -> Matrix:
    return [[sum(M[i][k] * N[k][j] for k in range(3)) for j in range(3)]
            for i in range(3)]


def transpose(M: Matrix) -> Matrix:
    return [[M[j][i] for j in range(3)] for i in range(3)]


def preserves_lorentz(M: Matrix) -> bool:
    return matmul(matmul(transpose(M), Q_L), M) == Q_L


def word_matrix(word: str) -> Matrix:
    M: Matrix = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    for k in word:
        M = matmul(M, GENS[k])
    return M


if __name__ == "__main__":
    for name, M in GENS.items():
        assert preserves_lorentz(M), name
    for w in ['AB', 'BCA', 'ABABC', 'CCCBA']:
        assert preserves_lorentz(word_matrix(w)), w
        print(f'word {w!r:8} preserves the Lorentz form: OK')
