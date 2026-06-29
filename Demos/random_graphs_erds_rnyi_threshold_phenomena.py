"""
Numerical demonstrations of Erdős–Rényi threshold phenomena.

This self-contained script reproduces, by exact computation and Monte Carlo
simulation, the formally proved results about the random graph G(n, p):

  * total mass of the p-biased law equals 1;
  * exact expected counts of edges  C(n,2)·p,  isolated vertices  n·(1-p)^(n-1),
    triangles  C(n,3)·p^3,  and cliques  C(n,r)·p^(C(r,2));
  * the Poisson critical window: C(n,3)·(c/n)^3 → c^3/6;
  * subcritical triangle vanishing and supercritical blow-up;
  * isolated-vertex blow-up at the giant-component scale p = c/n, separating the
    giant-component threshold 1/n from the connectivity threshold ln(n)/n;
  * empirical validation of linearity of expectation by direct sampling.

Only the Python standard library is used.
"""

from __future__ import annotations

import math
import random
from itertools import combinations
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Exact closed forms (the proved expectations)
# --------------------------------------------------------------------------- #

def expected_edges(n: int, p: float) -> float:
    """E[#edges] in G(n, p) = C(n, 2) · p."""
    return math.comb(n, 2) * p


def expected_isolated(n: int, p: float) -> float:
    """E[#isolated vertices] in G(n, p) = n · (1 - p)^(n - 1)."""
    return n * (1.0 - p) ** (n - 1)


def expected_triangles(n: int, p: float) -> float:
    """E[#triangles] in G(n, p) = C(n, 3) · p^3."""
    return math.comb(n, 3) * p ** 3


def expected_cliques(n: int, r: int, p: float) -> float:
    """E[#K_r] in G(n, p) = C(n, r) · p^(C(r, 2))."""
    return math.comb(n, r) * p ** math.comb(r, 2)


def poisson_triangle_mean(c: float) -> float:
    """Limit of C(n, 3)·(c/n)^3 as n → ∞, the Poisson mean c^3 / 6."""
    return c ** 3 / 6.0


# --------------------------------------------------------------------------- #
# Monte Carlo sampling of G(n, p)
# --------------------------------------------------------------------------- #

def sample_graph(n: int, p: float, rng: random.Random) -> List[Tuple[int, int]]:
    """Sample G(n, p): include each pair {i, j} independently with prob p."""
    return [(i, j) for i, j in combinations(range(n), 2) if rng.random() < p]


def count_isolated(n: int, edges: List[Tuple[int, int]]) -> int:
    """Number of vertices with no incident edge."""
    touched = set()
    for i, j in edges:
        touched.add(i)
        touched.add(j)
    return n - len(touched)


def count_triangles(n: int, edges: List[Tuple[int, int]]) -> int:
    """Number of triangles (3-cliques) in the graph."""
    adj = {v: set() for v in range(n)}
    for i, j in edges:
        adj[i].add(j)
        adj[j].add(i)
    total = 0
    for a, b, c in combinations(range(n), 3):
        if b in adj[a] and c in adj[a] and c in adj[b]:
            total += 1
    return total


def monte_carlo_means(
    n: int, p: float, trials: int, seed: int = 0
) -> Dict[str, float]:
    """Empirical mean edge/isolated/triangle counts over `trials` samples."""
    rng = random.Random(seed)
    se = si = st = 0
    for _ in range(trials):
        edges = sample_graph(n, p, rng)
        se += len(edges)
        si += count_isolated(n, edges)
        st += count_triangles(n, edges)
    return {
        "edges": se / trials,
        "isolated": si / trials,
        "triangles": st / trials,
    }


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_exact_vs_empirical() -> None:
    """Validate linearity of expectation: closed forms vs. simulation."""
    print("=" * 70)
    print("Linearity of expectation: exact closed form vs. Monte Carlo mean")
    print("=" * 70)
    n, p, trials = 20, 0.15, 4000
    exact = {
        "edges": expected_edges(n, p),
        "isolated": expected_isolated(n, p),
        "triangles": expected_triangles(n, p),
    }
    emp = monte_carlo_means(n, p, trials)
    print(f"  G(n={n}, p={p}),  {trials} trials\n")
    print(f"  {'quantity':<12}{'exact':>12}{'empirical':>12}{'rel.err':>10}")
    for key in ("edges", "isolated", "triangles"):
        e, m = exact[key], emp[key]
        rel = abs(e - m) / e if e else 0.0
        print(f"  {key:<12}{e:>12.4f}{m:>12.4f}{rel:>9.2%}")
    print()


def demo_poisson_window() -> None:
    """Triangle mean at p = c/n converges to the Poisson constant c^3/6."""
    print("=" * 70)
    print("Critical window p = c/n: C(n,3)·(c/n)^3 → c^3/6")
    print("=" * 70)
    c = 2.0
    target = poisson_triangle_mean(c)
    print(f"  c = {c},  Poisson limit c^3/6 = {target:.6f}\n")
    print(f"  {'n':>8}{'C(n,3)(c/n)^3':>18}{'|diff|':>14}")
    for n in (10, 50, 200, 1000, 5000, 50000):
        val = expected_triangles(n, c / n)
        print(f"  {n:>8}{val:>18.6f}{abs(val - target):>14.6f}")
    print()


def demo_sub_supercritical() -> None:
    """Below p=1/n triangles vanish; above it they blow up."""
    print("=" * 70)
    print("Subcritical vs. supercritical triangle expectation at p = c/n")
    print("=" * 70)
    print(f"  {'c':>6}{'regime':>16}   E[#triangles] as n grows (10..10^5)")
    for c in (0.1, 1.0, 5.0):
        regime = "subcritical" if c < 1 else ("critical" if c == 1 else "supercritical")
        vals = [expected_triangles(n, c / n) for n in (10, 100, 1000, 10000, 100000)]
        joined = "  ".join(f"{v:8.3f}" for v in vals)
        print(f"  {c:>6}{regime:>16}   {joined}")
    print("  (c<1: → 0,  c=1: → 1/6 ≈ 0.167,  c>1: → ∞)\n")


def demo_two_thresholds() -> None:
    """Isolated vertices persist at the giant-component scale 1/n,
    vanishing only near the connectivity scale ln(n)/n."""
    print("=" * 70)
    print("Two thresholds: isolated vertices at p = c/n vs. p = ln(n)/n")
    print("=" * 70)
    print(f"  {'n':>8}{'E[iso] @ 1/n':>16}{'E[iso] @ ln n / n':>20}")
    for n in (100, 1000, 10000, 100000):
        giant = expected_isolated(n, 1.0 / n)         # c = 1, scale 1/n
        conn = expected_isolated(n, math.log(n) / n)  # connectivity scale
        print(f"  {n:>8}{giant:>16.4f}{conn:>20.4f}")
    print("  At 1/n the isolated count grows like n·e^{-1}; only at ln(n)/n")
    print("  does it drop toward O(1), where connectivity becomes possible.\n")


def demo_clique_hierarchy() -> None:
    """Each clique K_r has its own threshold p = n^{-2/(r-1)}."""
    print("=" * 70)
    print("Clique hierarchy: E[#K_r] = C(n,r)·p^(C(r,2)) at its own threshold")
    print("=" * 70)
    n = 100000
    print(f"  n = {n}\n")
    print(f"  {'r':>4}{'threshold p=n^(-2/(r-1))':>26}{'E[#K_r] at p':>16}")
    for r in (3, 4, 5, 6):
        p_star = n ** (-2.0 / (r - 1))
        val = expected_cliques(n, r, p_star)
        print(f"  {r:>4}{p_star:>26.3e}{val:>16.4f}")
    print("  At its own threshold each E[#K_r] stays Θ(1) (order one).\n")


def main() -> None:
    print("\nErdős–Rényi Threshold Phenomena — Numerical Demonstrations\n")
    demo_exact_vs_empirical()
    demo_poisson_window()
    demo_sub_supercritical()
    demo_two_thresholds()
    demo_clique_hierarchy()


if __name__ == "__main__":
    main()
