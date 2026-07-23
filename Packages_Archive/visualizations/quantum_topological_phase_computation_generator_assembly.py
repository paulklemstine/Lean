from __future__ import annotations
import cmath, math
from typing import Tuple

Mat = Tuple[Tuple[complex, complex], Tuple[complex, complex]]

def matmul(x: Mat, y: Mat) -> Mat:
    return ((x[0][0]*y[0][0] + x[0][1]*y[1][0], x[0][0]*y[0][1] + x[0][1]*y[1][1]),
            (x[1][0]*y[0][0] + x[1][1]*y[1][0], x[1][0]*y[0][1] + x[1][1]*y[1][1]))

def assemble_generators() -> Tuple[Mat, Mat]:
    """Return (B1, B2) = (R, F R F) for the single-qubit Fibonacci model."""
    phi: float = (1.0 + math.sqrt(5.0)) / 2.0
    tau: float = 1.0 / phi
    s: float = math.sqrt(tau)
    F: Mat = ((complex(tau), complex(s)), (complex(s), complex(-tau)))
    R: Mat = ((cmath.exp(-4j*math.pi/5), 0.0), (0.0, cmath.exp(3j*math.pi/5)))
    B1: Mat = R
    B2: Mat = matmul(matmul(F, R), F)
    return B1, B2

if __name__ == "__main__":
    b1, b2 = assemble_generators()
    print("B1 =", b1)
    print("B2 =", b2)
