from typing import Tuple
Matrix = Tuple[Tuple[int, int], Tuple[int, int]]

def multiply(a: Matrix, b: Matrix) -> Matrix:
    return ((a[0][0]*b[0][0]+a[0][1]*b[1][0], a[0][0]*b[0][1]+a[0][1]*b[1][1]),
            (a[1][0]*b[0][0]+a[1][1]*b[1][0], a[1][0]*b[0][1]+a[1][1]*b[1][1]))

def trace_power(t: int, n: int) -> int:
    if n < 0: raise ValueError("n must be nonnegative")
    result: Matrix = ((1, 0), (0, 1))
    base: Matrix = ((t-1, 1), (t-2, 1))
    while n:
        if n & 1: result = multiply(result, base)
        base = multiply(base, base)
        n //= 2
    return result[0][0] + result[1][1]
