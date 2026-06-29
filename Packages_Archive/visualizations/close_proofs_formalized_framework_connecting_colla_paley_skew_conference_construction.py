from typing import List

Matrix = List[List[int]]

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True

def quadratic_character(a: int, q: int) -> int:
    a %= q
    if a == 0:
        return 0
    residues = {(x * x) % q for x in range(1, q)}
    return 1 if a in residues else -1

def skew_conference_matrix(q: int) -> Matrix:
    assert is_prime(q) and q % 4 == 3
    n = q + 1
    C: Matrix = [[0] * n for _ in range(n)]
    for j in range(1, n):
        C[0][j] = 1
        C[j][0] = -1
    for a in range(q):
        for b in range(q):
            C[a + 1][b + 1] = quadratic_character(a - b, q)
    return C

def paley_hadamard(q: int) -> Matrix:
    C = skew_conference_matrix(q)
    n = q + 1
    return [[(1 if i == j else 0) + C[i][j] for j in range(n)]
            for i in range(n)]
