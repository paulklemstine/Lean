"""Vandermonde determinant detector for the power-sum lower bound
(`powerSum_rank_ge`)."""
from __future__ import annotations
from fractions import Fraction
from typing import List, Sequence


def vandermonde_det(points: Sequence[Fraction]) -> Fraction:
    """det V = product over i<j of (t_j - t_i), where V[i][k] = points[i]**k.
    Nonzero iff the points are distinct. Complexity O(N^2)."""
    prod = Fraction(1)
    n = len(points)
    for j in range(n):
        for i in range(j):
            prod *= points[j] - points[i]
    return prod


def power_sum_sample_det(N: int) -> Fraction:
    """For p_N(x,y) = sum_{k<N} x^k y^k sampled at t_i = i, the evaluation matrix
    equals V V^T, so its determinant is (det V)^2 != 0, certifying rank >= N."""
    points: List[Fraction] = [Fraction(i) for i in range(N)]
    dV = vandermonde_det(points)
    return dV * dV
