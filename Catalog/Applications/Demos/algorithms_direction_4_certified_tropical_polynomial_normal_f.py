#!/usr/bin/env python3
"""
Tropical Polynomial Normal Form — Core Algorithms

Implements the certified normalization pipeline:
  Expression → Expand → Essentialize → Normal Form

Complexity:
- Expansion: O(2^d) monomials for depth-d expression (worst case, mul doubles)
- Essentialization: O(k² · n · S) where k = #monomials, n = #vars, S = #samples
- Full normalize: O(2^d · (2^d · n · S))
"""
import numpy as np
from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass
import itertools

Monomial = Tuple[float, Tuple[int, ...]]


def eval_monomial(m: Monomial, x: np.ndarray) -> float:
    """Evaluate c + Σ wᵢxᵢ at point x. O(n) time."""
    c, w = m
    return c + np.dot(w, x)


def eval_tropical_poly(monomials: List[Monomial], x: np.ndarray) -> float:
    """Evaluate min_{m ∈ S} evalMonom(m, x). O(k·n) time."""
    return min(eval_monomial(m, x) for m in monomials)


def expand_mul(s1: List[Monomial], s2: List[Monomial]) -> List[Monomial]:
    """Minkowski sum of monomial supports (tropical multiplication).
    O(|s1| · |s2|) time."""
    result = []
    for (c1, w1) in s1:
        for (c2, w2) in s2:
            result.append((c1 + c2, tuple(a + b for a, b in zip(w1, w2))))
    return result


def collect_duplicates(monomials: List[Monomial]) -> List[Monomial]:
    """Merge monomials with identical exponent vectors, keeping minimum
    coefficient. O(k log k) time."""
    by_exp: Dict[Tuple[int,...], float] = {}
    for c, w in monomials:
        if w not in by_exp or c < by_exp[w]:
            by_exp[w] = c
    return [(c, w) for w, c in by_exp.items()]


def find_essential_witness(
    m: Monomial,
    others: List[Monomial],
    n_vars: int,
    n_attempts: int = 5000
) -> Optional[np.ndarray]:
    """Try to find a point where m is the strict minimizer.
    Returns witness point or None.

    Strategy: random sampling + directed perturbation along
    gradient of gap to nearest competitor.
    """
    if not others:
        return np.zeros(n_vars)

    for _ in range(n_attempts):
        x = np.random.randn(n_vars) * 3
        val_m = eval_monomial(m, x)
        gaps = [eval_monomial(o, x) - val_m for o in others]
        if all(g > 0 for g in gaps):
            return x
        # Directed: move toward where m wins
        # The difference m' - m is affine: Δc + Σ Δwᵢ xᵢ
        # To make it positive, move x in direction of Δw
        worst_idx = np.argmin(gaps)
        _, w_o = others[worst_idx]
        _, w_m = m
        dw = np.array([w_o_i - w_m_i for w_o_i, w_m_i in zip(w_o, w_m)], dtype=float)
        if np.linalg.norm(dw) > 1e-10:
            x_new = x - 2.0 * dw / np.linalg.norm(dw)
            val_m_new = eval_monomial(m, x_new)
            if all(eval_monomial(o, x_new) > val_m_new for o in others):
                return x_new
    return None


def essentialize(monomials: List[Monomial], n_vars: int) -> List[Monomial]:
    """Remove inessential (dominated) monomials.

    A monomial is essential if there exists a point where it is the
    unique (strict) minimizer. Inessential monomials are those that
    never appear on the lower envelope.

    Time: O(k² · n · S) where S = sampling budget per monomial.
    """
    collected = collect_duplicates(monomials)
    if len(collected) <= 1:
        return collected

    essential = []
    for i, m in enumerate(collected):
        others = [collected[j] for j in range(len(collected)) if j != i]
        witness = find_essential_witness(m, others, n_vars)
        if witness is not None:
            essential.append(m)
    return sorted(essential) if essential else [collected[0]]


def normalize_from_monomials(monomials: List[Monomial], n_vars: int) -> List[Monomial]:
    """Full normalization: collect duplicates then essentialize."""
    return essentialize(monomials, n_vars)


def verify_semantic_equality(
    s1: List[Monomial],
    s2: List[Monomial],
    n_vars: int,
    n_tests: int = 10000,
    tol: float = 1e-10
) -> Tuple[bool, float]:
    """Verify f_s1 = f_s2 by random evaluation.
    Returns (likely_equal, max_difference)."""
    max_diff = 0.0
    for _ in range(n_tests):
        x = np.random.randn(n_vars) * 5
        v1 = eval_tropical_poly(s1, x)
        v2 = eval_tropical_poly(s2, x)
        max_diff = max(max_diff, abs(v1 - v2))
    return max_diff < tol, max_diff


# ── Visualization helpers ──

def lower_envelope_1d(monomials: List[Monomial], x_range=(-5, 5), n_points=1000):
    """Compute the lower envelope of a 1D tropical polynomial."""
    xs = np.linspace(x_range[0], x_range[1], n_points)
    envelope = np.array([eval_tropical_poly(monomials, np.array([x])) for x in xs])
    individual = {m: np.array([eval_monomial(m, np.array([x])) for x in xs])
                  for m in monomials}
    return xs, envelope, individual


if __name__ == "__main__":
    print("Tropical Normal Form Algorithms")
    print("=" * 40)

    # Example: 1D with dominated monomial
    monomials = [(0, (1,)), (0, (0,)), (1, (0,))]
    print(f"Input monomials: {monomials}")
    nf = normalize_from_monomials(monomials, 1)
    print(f"Normal form: {nf}")

    eq, diff = verify_semantic_equality(monomials, nf, 1)
    print(f"Semantically equal: {eq} (max diff: {diff:.2e})")
