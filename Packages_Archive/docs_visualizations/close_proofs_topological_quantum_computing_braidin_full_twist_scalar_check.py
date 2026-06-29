from typing import Tuple

Complex = complex
Matrix2 = Tuple[Tuple[Complex, Complex], Tuple[Complex, Complex]]


def mat_mul(M: Matrix2, N: Matrix2) -> Matrix2:
    return (
        (M[0][0]*N[0][0]+M[0][1]*N[1][0], M[0][0]*N[0][1]+M[0][1]*N[1][1]),
        (M[1][0]*N[0][0]+M[1][1]*N[1][0], M[1][0]*N[0][1]+M[1][1]*N[1][1]),
    )


def full_twist(t: Complex) -> Matrix2:
    """(B1 B2)^3; equals t^3 * I with trace 2 t^3."""
    B1: Matrix2 = ((-t, 1.0 + 0j), (0j, 1.0 + 0j))
    B2: Matrix2 = ((1.0 + 0j, 0j), (t, -t))
    P = mat_mul(B1, B2)
    FT = mat_mul(mat_mul(P, P), P)
    scalar: Matrix2 = ((t**3, 0j), (0j, t**3))
    assert all(abs(FT[i][j] - scalar[i][j]) < 1e-9
               for i in range(2) for j in range(2))
    assert abs((FT[0][0] + FT[1][1]) - 2 * t**3) < 1e-9
    return FT
