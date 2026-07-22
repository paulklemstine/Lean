from __future__ import annotations
Matrix = tuple[tuple[int, int], tuple[int, int]]

def multiply(a: Matrix, b: Matrix) -> Matrix:
    return tuple(tuple(sum(a[i][k] * b[k][j] for k in range(2))
                       for j in range(2)) for i in range(2))  # type: ignore[return-value]

def matrix_coordinates(n: int) -> tuple[int, int]:
    if n < 0:
        raise ValueError("n must be nonnegative")
    result: Matrix = ((1, 0), (0, 1))
    base: Matrix = ((2, 1), (1, 2))
    while n:
        if n & 1:
            result = multiply(result, base)
        base = multiply(base, base)
        n //= 2
    return result[0][1], result[1][1]
