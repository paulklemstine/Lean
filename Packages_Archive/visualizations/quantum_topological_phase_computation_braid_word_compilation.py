from __future__ import annotations
import cmath, math
from typing import List, Tuple

Mat = Tuple[Tuple[complex, complex], Tuple[complex, complex]]

def matmul(x: Mat, y: Mat) -> Mat:
    return ((x[0][0]*y[0][0] + x[0][1]*y[1][0], x[0][0]*y[0][1] + x[0][1]*y[1][1]),
            (x[1][0]*y[0][0] + x[1][1]*y[1][0], x[1][0]*y[0][1] + x[1][1]*y[1][1]))

def dagger(x: Mat) -> Mat:
    return ((x[0][0].conjugate(), x[1][0].conjugate()),
            (x[0][1].conjugate(), x[1][1].conjugate()))

def assemble_generators() -> Tuple[Mat, Mat]:
    phi = (1.0 + math.sqrt(5.0)) / 2.0
    tau = 1.0 / phi
    s = math.sqrt(tau)
    F = ((complex(tau), complex(s)), (complex(s), complex(-tau)))
    R = ((cmath.exp(-4j*math.pi/5), 0.0), (0.0, cmath.exp(3j*math.pi/5)))
    return R, matmul(matmul(F, R), F)

def compile_braid_word(word: List[int]) -> Mat:
    """Compile a B3 word into its 2x2 unitary (+/-1 = B1^{+-1}, +/-2 = B2^{+-1})."""
    b1, b2 = assemble_generators()
    table = {1: b1, -1: dagger(b1), 2: b2, -2: dagger(b2)}
    acc: Mat = ((1.0, 0.0), (0.0, 1.0))
    for letter in word:
        acc = matmul(acc, table[letter])
    return acc

if __name__ == "__main__":
    print(compile_braid_word([1, 2, 1]))
    print(compile_braid_word([2, 1, 2]))  # equals the previous by the braid relation
