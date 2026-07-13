"""Numerical demonstrations for the L^p relaxation of the KNRS local-density conjecture.

This self-contained script illustrates, in the finite step-graphon model:

  1. The single-edge power-mean bound: for p >= 1 every rho-locally dense kernel W
     has ||W_{K2}||_{L^p} >= rho, while for 0 < p < 1 the two-block kernel drops below.
  2. The matching factorization ||W_{M2}||_{L^p} = ||W_{K2}||_{L^p}^2, and the
     consequent failure of the naive threshold C(n,2)/m = 3 for M2 (true threshold 1).
  3. The general k-block value  ||W_{k,F}||_{L^p} = rho^m * k^{m - (n-c)/p},
     giving counterexamples exactly for p < (n-c)/m.

Run with:  python demo.py
"""

from __future__ import annotations

from itertools import product
from math import comb
from typing import Callable, List, Tuple


# ----------------------------------------------------------------------------
# Core finite-model functionals
# ----------------------------------------------------------------------------
Kernel = List[List[float]]


def is_locally_dense(W: Kernel, rho: float, tol: float = 1e-12) -> bool:
    """Brute-force check that sum_{i,j in S} W[i][j] >= rho * |S|^2 for every S."""
    n: int = len(W)
    for mask in range(1 << n):
        S: List[int] = [i for i in range(n) if (mask >> i) & 1]
        total: float = sum(W[i][j] for i in S for j in S)
        if total + tol < rho * len(S) ** 2:
            return False
    return True


def edge_lp(W: Kernel, p: float) -> float:
    """||W_{K2}||_{L^p} = ( (1/N^2) sum_{i,j} W[i][j]^p )^{1/p}."""
    n: int = len(W)
    total: float = sum(W[i][j] ** p for i in range(n) for j in range(n))
    return (total / n ** 2) ** (1.0 / p)


def matching_lp(W: Kernel, p: float) -> float:
    """||W_{M2}||_{L^p} = ( (1/N^4) sum_{a,b,c,d} W[a][b]^p W[c][d]^p )^{1/p}."""
    n: int = len(W)
    total: float = 0.0
    for a, b, c, d in product(range(n), repeat=4):
        total += (W[a][b] ** p) * (W[c][d] ** p)
    return (total / n ** 4) ** (1.0 / p)


def two_block_kernel(rho: float) -> Kernel:
    """The counterexample kernel on 2 blocks: 2*rho on the diagonal, 0 off-diagonal."""
    return [[2.0 * rho if i == j else 0.0 for j in range(2)] for i in range(2)]


def k_block_pattern_norm(k: int, rho: float, p: float, n: int, m: int, c: int) -> float:
    """Closed form ||W_{k,F}||_{L^p} = rho^m * k^{m - (n-c)/p} from Proposition 5.2."""
    return rho ** m * k ** (m - (n - c) / p)


def block_threshold(n: int, m: int, c: int) -> float:
    """Corrected block-construction threshold (n - c) / m."""
    return (n - c) / m


def naive_threshold(n: int, m: int) -> float:
    """The (false in general) candidate formula C(n,2) / m."""
    return comb(n, 2) / m


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def demo_single_edge() -> None:
    print("=" * 70)
    print("DEMO 1: single edge K2 -- threshold is exactly p = 1")
    print("=" * 70)
    rho: float = 0.4
    W: Kernel = two_block_kernel(rho)
    print(f"two-block kernel with rho={rho}: {W}")
    print(f"locally dense? {is_locally_dense(W, rho)}")
    print(f"{'p':>6} | {'||W_K2||_Lp':>14} | {'rho':>6} | verdict")
    print("-" * 50)
    for p in [0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0]:
        val: float = edge_lp(W, p)
        verdict = "BELOW rho (counterexample)" if val < rho - 1e-12 else ">= rho (safe)"
        print(f"{p:>6} | {val:>14.6f} | {rho:>6} | {verdict}")
    print("Closed form: ||W_K2||_Lp = rho * 2^(1 - 1/p);  < rho iff p < 1.\n")


def demo_matching() -> None:
    print("=" * 70)
    print("DEMO 2: matching M2 -- naive C(4,2)/2 = 3 is WRONG; true threshold = 1")
    print("=" * 70)
    rho: float = 0.4
    W: Kernel = two_block_kernel(rho)
    print(f"naive threshold C(4,2)/2 = {naive_threshold(4, 2)}")
    print(f"corrected (n-c)/m = (4-2)/2 = {block_threshold(4, 2, 2)}")
    print(f"{'p':>6} | {'||W_M2||_Lp':>14} | {'edge^2':>12} | {'rho^2':>8} | verdict")
    print("-" * 66)
    for p in [0.5, 0.75, 1.0, 2.0]:
        m2: float = matching_lp(W, p)
        e2: float = edge_lp(W, p) ** 2
        below = m2 < rho ** 2 - 1e-12
        verdict = "counterexample" if below else "no counterexample"
        print(f"{p:>6} | {m2:>14.6f} | {e2:>12.6f} | {rho**2:>8.4f} | {verdict}")
    print("Note ||W_M2||_Lp = (||W_K2||_Lp)^2 exactly (factorization).")
    print("At p=2 < 3 there is NO counterexample, refuting the naive formula.\n")


def demo_general_blocks() -> None:
    print("=" * 70)
    print("DEMO 3: general k-block threshold (n-c)/m vs naive C(n,2)/m")
    print("=" * 70)
    patterns: List[Tuple[str, int, int, int]] = [
        ("edge K2", 2, 1, 1),
        ("matching M2", 4, 2, 2),
        ("matching M3", 6, 3, 3),
        ("matching M5", 10, 5, 5),
        ("triangle K3", 3, 3, 1),
        ("path P3 (2 edges)", 3, 2, 1),
    ]
    print(f"{'pattern':>18} | {'naive':>7} | {'(n-c)/m':>8} | {'gap':>7}")
    print("-" * 50)
    for name, n, m, c in patterns:
        nv: float = naive_threshold(n, m)
        bt: float = block_threshold(n, m, c)
        print(f"{name:>18} | {nv:>7.3f} | {bt:>8.3f} | {nv - bt:>7.3f}")
    print("\nVerifying the k-block closed form beats rho^m exactly when p < (n-c)/m:")
    rho, n, m, c = 0.1, 4, 2, 2  # M2
    for k in [2, 4, 8]:
        for p in [0.5, 1.0]:
            val = k_block_pattern_norm(k, rho, p, n, m, c)
            tag = "< rho^m" if val < rho ** m - 1e-15 else ">= rho^m"
            print(f"  k={k}, p={p}: ||W||={val:.3e}  vs rho^m={rho**m:.3e}  ({tag})")
    print()


def main() -> None:
    demo_single_edge()
    demo_matching()
    demo_general_blocks()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
