from __future__ import annotations
import math
from typing import Dict


def expected_edges(n: int, p: float) -> float:
    return math.comb(n, 2) * p


def expected_isolated(n: int, p: float) -> float:
    return n * (1.0 - p) ** (n - 1)


def expected_triangles(n: int, p: float) -> float:
    return math.comb(n, 3) * p ** 3


def expected_cliques(n: int, r: int, p: float) -> float:
    return math.comb(n, r) * p ** math.comb(r, 2)


def threshold_report(n: int, p: float, r: int = 3) -> Dict[str, float]:
    np_ = n * p
    regime = 'subcritical' if np_ < 1 else ('critical' if np_ == 1 else 'supercritical')
    return {
        'E_edges': expected_edges(n, p),
        'E_isolated': expected_isolated(n, p),
        'E_triangle': expected_triangles(n, p),
        'E_clique': expected_cliques(n, r, p),
        'triangle_regime': regime,
    }
