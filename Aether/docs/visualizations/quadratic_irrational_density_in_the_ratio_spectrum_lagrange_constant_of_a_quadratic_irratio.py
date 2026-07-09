from fractions import Fraction
from math import isqrt
from typing import List

def cf_of_quadratic(D: int, num_terms: int) -> List[int]:
    a0 = isqrt(D)
    terms: List[int] = [a0]
    P, Q, a = 0, 1, a0
    for _ in range(num_terms - 1):
        P = a * Q - P
        Q = (D - P * P) // Q
        if Q == 0:
            break
        a = (a0 + P) // Q
        terms.append(a)
    return terms

def eval_cf(terms: List[int]) -> Fraction:
    value = Fraction(terms[-1])
    for a in reversed(terms[:-1]):
        value = a + 1 / value
    return value

def lagrange_constant_sqrt(D: int, depth: int = 400) -> float:
    terms = cf_of_quadratic(D, depth)
    best = 0.0
    window = min(len(terms) - 2, 60)
    for i in range(1, window):
        forward = float(eval_cf(terms[i:i + 40]))
        back = terms[max(0, i - 40):i][::-1]
        backward = float(eval_cf([0] + back)) if back else 0.0
        best = max(best, forward + backward)
    return best
