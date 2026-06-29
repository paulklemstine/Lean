from typing import List, Set
Matrix = List[List[int]]

def quadratic_residues(q: int) -> Set[int]:
    return {(x * x) % q for x in range(1, q)}

def chi(x: int, q: int, qr: Set[int]) -> int:
    r = x % q
    return 0 if r == 0 else (1 if r in qr else -1)

def bordered_conference(q: int) -> Matrix:
    qr = quadratic_residues(q)
    Q = [[chi(a - b, q, qr) for b in range(q)] for a in range(q)]
    n = q + 1
    C = [[0] * n for _ in range(n)]
    for j in range(1, n):
        C[0][j] = 1
    for i in range(1, n):
        C[i][0] = -1
    for i in range(1, n):
        for j in range(1, n):
            C[i][j] = Q[i - 1][j - 1]
    return C
