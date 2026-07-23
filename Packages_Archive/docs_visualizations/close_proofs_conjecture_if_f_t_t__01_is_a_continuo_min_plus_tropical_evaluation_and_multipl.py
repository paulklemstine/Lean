from itertools import product
from typing import List, Sequence

def term_val(coeffs: List[float], exps: List[List[float]],
             x: Sequence[float], i: int) -> float:
    return coeffs[i] + sum(e * xk for e, xk in zip(exps[i], x))

def trop_eval(coeffs: List[float], exps: List[List[float]],
              x: Sequence[float]) -> float:
    return min(term_val(coeffs, exps, x, i) for i in range(len(coeffs)))

def trop_mul(cP: List[float], eP: List[List[float]],
             cQ: List[float], eQ: List[List[float]]):
    coeffs, exps = [], []
    for i, j in product(range(len(cP)), range(len(cQ))):
        coeffs.append(cP[i] + cQ[j])
        exps.append([a + b for a, b in zip(eP[i], eQ[j])])
    return coeffs, exps
