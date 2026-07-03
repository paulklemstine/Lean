"""
Numerical demonstrations for:

    Path-Minimality of Positive p-Energies for Connected Bipartite Graphs

This self-contained script illustrates the main results:

  1. Bipartite Balance:  for a reflection-antisymmetric spectrum (f(n-1-k) = -f(k)),
     the positive and negative p-energies coincide, for every real p.
  2. Path spectrum reflection:  lambda_{n-1-k} = -lambda_k  for the path P_n.
  3. Exact evaluation:  E_2^+(P_n) = n - 1.
  4. Path-minimality at p = 2:  every connected graph on n vertices has >= n-1 edges,
     and for bipartite graphs E_2^+(G) = |E(G)|, so the path minimizes E_2^+.
  5. Non-vacuity:  the triangle K_3 (non-bipartite) has E_p^+ != E_p^-.

Only the standard library is used (math), so it runs anywhere.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
#  Spectra                                                                     #
# --------------------------------------------------------------------------- #

def path_spectrum(n: int) -> List[float]:
    """Adjacency spectrum of the path graph P_n: lambda_k = 2 cos((k+1) pi / (n+1))."""
    return [2.0 * math.cos((k + 1) * math.pi / (n + 1)) for k in range(n)]


# --------------------------------------------------------------------------- #
#  Positive / negative p-energies                                             #
# --------------------------------------------------------------------------- #

def positive_p_energy(spectrum: List[float], p: float) -> float:
    """E_p^+ = sum of lambda^p over positive eigenvalues lambda."""
    return sum(lam ** p for lam in spectrum if lam > 0.0)


def negative_p_energy(spectrum: List[float], p: float) -> float:
    """E_p^- = sum of (-lambda)^p over negative eigenvalues lambda."""
    return sum((-lam) ** p for lam in spectrum if lam < 0.0)


# --------------------------------------------------------------------------- #
#  Structural checks                                                          #
# --------------------------------------------------------------------------- #

def is_reflection_antisymmetric(spectrum: List[float], tol: float = 1e-9) -> bool:
    """Check f(n-1-k) = -f(k) for a spectrum sorted in decreasing order."""
    s = sorted(spectrum, reverse=True)
    n = len(s)
    return all(abs(s[n - 1 - k] + s[k]) < tol for k in range(n))


def bipartite_balance_gap(spectrum: List[float], p: float) -> float:
    """|E_p^+ - E_p^-|; ~0 for reflection-antisymmetric (bipartite) spectra."""
    return abs(positive_p_energy(spectrum, p) - negative_p_energy(spectrum, p))


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #

def demo_reflection_and_balance() -> None:
    print("=" * 68)
    print("1-2. Path spectrum reflection and bipartite balance")
    print("=" * 68)
    for n in (3, 5, 8, 13):
        spec = path_spectrum(n)
        anti = is_reflection_antisymmetric(spec)
        print(f"\n P_{n}: eigenvalues = " + ", ".join(f"{x:+.4f}" for x in spec))
        print(f"      reflection-antisymmetric (lambda_(n-1-k) = -lambda_k)? {anti}")
        for p in (2.0, 2.5, 4.0):
            gap = bipartite_balance_gap(spec, p)
            print(f"      p={p:>3}:  E_p^+ = {positive_p_energy(spec, p):.6f}"
                  f"   E_p^- = {negative_p_energy(spec, p):.6f}"
                  f"   |gap| = {gap:.2e}")


def demo_exact_p2() -> None:
    print("\n" + "=" * 68)
    print("3. Exact evaluation:  E_2^+(P_n) = n - 1")
    print("=" * 68)
    print(f"\n {'n':>4} | {'E_2^+(P_n)':>14} | {'n-1':>6} | match")
    print(" " + "-" * 44)
    for n in range(2, 12):
        e2 = positive_p_energy(path_spectrum(n), 2.0)
        print(f" {n:>4} | {e2:>14.9f} | {n-1:>6} | {abs(e2-(n-1)) < 1e-7}")


def demo_minimality_p2() -> None:
    print("\n" + "=" * 68)
    print("4. Path-minimality at p=2 among connected graphs on 4 vertices")
    print("   (bipartite:  E_2^+ = |E|;  path P_4 attains the minimum n-1 = 3)")
    print("=" * 68)
    # Named 4-vertex connected graphs given by explicit adjacency spectra.
    phi = (1 + math.sqrt(5)) / 2
    graphs: List[Tuple[str, List[float], bool]] = [
        ("P_4  (path)",      path_spectrum(4),        True),
        ("C_4  (4-cycle)",   [2.0, 0.0, 0.0, -2.0],   True),
        ("K_4  (complete)",  [3.0, -1.0, -1.0, -1.0], False),
        ("star K_{1,3}",     [math.sqrt(3), 0.0, 0.0, -math.sqrt(3)], True),
    ]
    print(f"\n {'graph':<16} | {'E_2^+':>10} | {'#edges':>7} | bipartite")
    print(" " + "-" * 52)
    for name, spec, bip in graphs:
        e2 = positive_p_energy(spec, 2.0)
        edges = round(sum(x * x for x in spec) / 2)  # |E| = (1/2) sum lambda^2
        print(f" {name:<16} | {e2:>10.5f} | {edges:>7} | {bip}")
    print("\n Path P_4 has the fewest edges (3) and the smallest E_2^+ (=3).")


def demo_p4_vs_c4_sweep() -> None:
    print("\n" + "=" * 68)
    print("5. C_4 dominates P_4 for all p >= 2:")
    print("   E_p^+(C_4) = 2^p   vs   E_p^+(P_4) = phi^p + phi^{-p}")
    print("=" * 68)
    phi = (1 + math.sqrt(5)) / 2
    p4, c4 = path_spectrum(4), [2.0, 0.0, 0.0, -2.0]
    print(f"\n {'p':>5} | {'E_p^+(P_4)':>14} | {'E_p^+(C_4)':>14} | C_4 >= P_4")
    print(" " + "-" * 54)
    for p in (2.0, 2.5, 3.0, 4.0, 6.0):
        ep_path = positive_p_energy(p4, p)
        ep_cyc = positive_p_energy(c4, p)
        closed = phi ** p + phi ** (-p)
        assert abs(ep_path - closed) < 1e-6  # confirm closed form
        print(f" {p:>5} | {ep_path:>14.6f} | {ep_cyc:>14.6f} | {ep_cyc >= ep_path}")


def demo_nonvacuity_triangle() -> None:
    print("\n" + "=" * 68)
    print("6. Non-vacuity:  triangle K_3 is NOT bipartite, so E_p^+ != E_p^-")
    print("=" * 68)
    k3 = [2.0, -1.0, -1.0]
    print(f"\n K_3 spectrum = {k3}   reflection-antisymmetric? "
          f"{is_reflection_antisymmetric(k3)}")
    for p in (2.0, 3.0, 4.0):
        print(f"   p={p:>3}:  E_p^+ = {positive_p_energy(k3, p):.4f}"
              f"   E_p^- = {negative_p_energy(k3, p):.4f}"
              f"   gap = {bipartite_balance_gap(k3, p):.4f}")


def main() -> None:
    demo_reflection_and_balance()
    demo_exact_p2()
    demo_minimality_p2()
    demo_p4_vs_c4_sweep()
    demo_nonvacuity_triangle()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
