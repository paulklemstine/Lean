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

def distance(x: Mat, y: Mat) -> float:
    """Frobenius distance, an upper bound proxy for the operator-norm distance."""
    return math.sqrt(sum(abs(x[i][j] - y[i][j])**2 for i in range(2) for j in range(2)))

def assemble_generators() -> Tuple[Mat, Mat]:
    phi = (1.0 + math.sqrt(5.0)) / 2.0
    tau = 1.0 / phi
    s = math.sqrt(tau)
    F = ((complex(tau), complex(s)), (complex(s), complex(-tau)))
    R = ((cmath.exp(-4j*math.pi/5), 0.0), (0.0, cmath.exp(3j*math.pi/5)))
    return R, matmul(matmul(F, R), F)

def gate_search(target: Mat, epsilon: float, max_len: int = 8) -> List[int]:
    """Breadth-first search for a braid word approximating ``target``."""
    b1, b2 = assemble_generators()
    gen = {1: b1, -1: dagger(b1), 2: b2, -2: dagger(b2)}
    identity: Mat = ((1.0, 0.0), (0.0, 1.0))
    frontier: List[Tuple[List[int], Mat]] = [([], identity)]
    best_word: List[int] = []
    best_dist: float = distance(identity, target)
    for _ in range(max_len):
        nxt: List[Tuple[List[int], Mat]] = []
        for word, m in frontier:
            for move, g in gen.items():
                w2 = word + [move]
                m2 = matmul(m, g)
                d = distance(m2, target)
                if d < best_dist:
                    best_dist, best_word = d, w2
                if best_dist <= epsilon:
                    return best_word
                nxt.append((w2, m2))
        frontier = nxt
    return best_word

if __name__ == "__main__":
    # Target: a phase gate diag(1, e^{i pi/4}).
    target: Mat = ((1.0, 0.0), (0.0, cmath.exp(1j*math.pi/4)))
    word = gate_search(target, epsilon=0.3, max_len=6)
    print("approximating word:", word)
