from typing import Sequence

def fisher_quadratic_form(p: Sequence[float], score: Sequence[Sequence[float]],
                          v: Sequence[float]) -> float:
    """Evaluate the Fisher length ||v||_G^2 via the sum-of-squares identity:
        v^T G v = sum_x p[x] * (sum_i v[i]*score[x][i])^2.
    This O(n*d) form is both faster than the O(d^2) bilinear form and manifestly
    nonnegative (fisher_posSemidef).
    """
    total = 0.0
    for x in range(len(p)):
        sv = sum(v[i]*score[x][i] for i in range(len(v)))
        total += p[x]*sv*sv
    return total
