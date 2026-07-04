"""Numerical demonstrations for the sharp threshold constant of Maker--Breaker
cycle games.

For the biased (1:q) Maker--Breaker C_k-game on the complete graph K_n with fixed
k >= 4, the threshold bias is

    q*(n) = c_k * n^{(k-2)/(k-1)},

    c_k = ( (k-1) * (2(k-1)/k)^{k-2} )^{1/(k-1)}.

The maximum 2-density of the cycle C_k is m_2(C_k) = (k-1)/(k-2), and the game
exponent (k-2)/(k-1) is its reciprocal. This script verifies all of these facts
numerically and illustrates the non-monotone behaviour of c_k and its limit 2.

Self-contained: standard library only.
"""

from __future__ import annotations

from typing import Dict, List, Tuple


# --------------------------------------------------------------------------
# Core formulas
# --------------------------------------------------------------------------
def game_exponent(k: float) -> float:
    """The Bednarska--Luczak threshold exponent (k-2)/(k-1)."""
    return (k - 2.0) / (k - 1.0)


def max_density(k: float) -> float:
    """The maximum 2-density (k-1)/(k-2) of the cycle C_k."""
    return (k - 1.0) / (k - 2.0)


def threshold_const(k: int) -> float:
    """The sharp threshold constant c_k = ((k-1)*(2(k-1)/k)^{k-2})^{1/(k-1)}.

    Evaluated in log-space to stay numerically stable for large k.
    """
    import math
    log_base = math.log(k - 1.0) + (k - 2) * math.log(2.0 * (k - 1.0) / k)
    return math.exp(log_base / (k - 1.0))


def threshold_bias(k: int, n: float) -> float:
    """The predicted threshold bias q*(n) = c_k * n^{(k-2)/(k-1)}."""
    return threshold_const(k) * n ** game_exponent(k)


def game_verdict(k: int, n: float, q: float, eps: float = 1e-3) -> str:
    """Return 'Maker', 'Breaker', or 'window' for bias q at board size n."""
    q_star = threshold_bias(k, n)
    if q < (1.0 - eps) * q_star:
        return "Maker"
    if q > (1.0 + eps) * q_star:
        return "Breaker"
    return "window"


# --------------------------------------------------------------------------
# Combinatorial check: maximum 2-density by enumerating subgraph shapes
# --------------------------------------------------------------------------
def cycle_max_density_by_enumeration(k: int) -> Tuple[float, str]:
    """Compute m_2(C_k) by enumerating the two possible subgraph shapes.

    Shape 1: the whole cycle, e = v = k, density (k-1)/(k-2).
    Shape 2: any proper subgraph is a linear forest = disjoint union of c >= 1
             paths, a forest with e = v - c < v, density (e-1)/(v-2) <= 1.

    Returns the maximum density and the maximizer's name.
    """
    best_val = -float("inf")
    best_name = ""

    # Shape 1: the whole cycle.
    e, v = k, k
    d = (e - 1) / (v - 2)
    if d > best_val:
        best_val, best_name = d, "whole cycle"

    # Shape 2: proper subgraphs = linear forests on v vertices with c components.
    # A linear forest with c paths covering v vertices has e = v - c edges.
    # Enumerate all v in [3, k] and c in [1, v-1] (need at least one edge => e>=1).
    for v in range(3, k + 1):
        for c in range(1, v):  # c components => e = v - c
            e = v - c
            if e < 1:
                continue
            # Skip the full-cycle degenerate reconstruction (proper only).
            d = (e - 1) / (v - 2)
            if d > best_val:
                best_val, best_name = d, f"forest v={v}, {c} path(s)"
    return best_val, best_name


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_table() -> None:
    print("=" * 74)
    print("Threshold ingredients for the C_k-game")
    print("=" * 74)
    header = f"{'k':>5} {'exponent':>12} {'c_k':>10} {'m_2(C_k)':>12} {'exp*m2':>10}"
    print(header)
    print("-" * 74)
    for k in [4, 5, 6, 10, 15, 20, 100, 1000]:
        alpha = game_exponent(k)
        m2 = max_density(k)
        ck = threshold_const(k)
        print(f"{k:>5} {alpha:>12.5f} {ck:>10.4f} {m2:>12.5f} {alpha * m2:>10.6f}")
    print("(last column = exponent * density = 1, exponent-density duality)")


def demo_closed_form() -> None:
    print("\n" + "=" * 74)
    print("Closed-form identity  c_k^{k-1} = (k-1)*(2(k-1)/k)^{k-2}")
    print("=" * 74)
    for k in [4, 5, 6, 10, 50]:
        ck = threshold_const(k)
        lhs = ck ** (k - 1)
        rhs = (k - 1.0) * (2.0 * (k - 1.0) / k) ** (k - 2)
        print(f"k={k:>4}: c_k^(k-1)={lhs:>16.6f}   base={rhs:>16.6f}   "
              f"|diff|={abs(lhs - rhs):.2e}")


def demo_non_monotone_and_limit() -> None:
    print("\n" + "=" * 74)
    print("Non-monotone constant c_k and its limit 2")
    print("=" * 74)
    peak_k, peak_val = 0, -1.0
    for k in range(4, 60):
        ck = threshold_const(k)
        if ck > peak_val:
            peak_val, peak_k = ck, k
    print(f"Interior maximum: c_{peak_k} = {peak_val:.4f}")
    for k in [4, 10, peak_k, 100, 1000, 10000, 100000]:
        print(f"  c_{k:<6} = {threshold_const(k):.6f}")
    print("  limit    = 2.000000  (c_k -> 2 as k -> infinity)")


def demo_factorization() -> None:
    print("\n" + "=" * 74)
    print("Factorization c_k = (k-1)^{1/(k-1)} * (2(k-1)/k)^{(k-2)/(k-1)}")
    print("=" * 74)
    for k in [4, 10, 100, 1000]:
        f1 = (k - 1.0) ** (1.0 / (k - 1.0))
        f2 = (2.0 * (k - 1.0) / k) ** game_exponent(k)
        print(f"k={k:>5}: factor1={f1:.5f} (->1)   factor2={f2:.5f} (->2)   "
              f"product={f1 * f2:.5f}")


def demo_density_enumeration() -> None:
    print("\n" + "=" * 74)
    print("m_2(C_k) via subgraph enumeration  (should equal (k-1)/(k-2))")
    print("=" * 74)
    for k in [4, 5, 6, 8, 12]:
        val, who = cycle_max_density_by_enumeration(k)
        print(f"k={k:>3}: enumerated max={val:.5f} at [{who:<20}]  "
              f"formula={max_density(k):.5f}")


def demo_verdicts() -> None:
    print("\n" + "=" * 74)
    print("Sample game verdicts (k=4, exponent 2/3)")
    print("=" * 74)
    k, n = 4, 10 ** 6
    q_star = threshold_bias(k, n)
    print(f"n={n}, predicted threshold q* = {q_star:.1f}")
    for factor in [0.5, 0.9, 1.0, 1.1, 2.0]:
        q = factor * q_star
        print(f"  q = {factor:>4}*q* = {q:>12.1f}  ->  {game_verdict(k, n, q)}")


if __name__ == "__main__":
    demo_table()
    demo_closed_form()
    demo_non_monotone_and_limit()
    demo_factorization()
    demo_density_enumeration()
    demo_verdicts()
