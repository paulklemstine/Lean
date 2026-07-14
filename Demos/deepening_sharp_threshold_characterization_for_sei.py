"""Numerical demonstration of the Seidel energy of complete bipartite graphs
K_{m,n} under the deletion of two independent (vertex-disjoint) cross edges.

We build the Seidel matrix S = J - I - 2A directly from the vertex labeling,
delete two independent edges, compute the eigenvalues numerically, and compare
the total Seidel energy (sum of absolute eigenvalues) against the closed-form
predictions derived in the accompanying paper:

    Base energy of K_{m,n}                :  2 (m + n - 1)
    Two-deletion characteristic polynomial:  (X+1)^{N-5}(X-1)^2(X+3)
                                             (X^2 - (N-4)X - (3N-11)),  N = m+n
    Two-deletion Seidel energy            :  (m+n) + sqrt((m+n+2)^2 - 32)

The main theorem asserts strict increase for all m, n >= 2 with m + n >= 5,
with no threshold obstruction.

This script is self-contained; it depends only on the standard library and
numpy.
"""

from __future__ import annotations

import math
from typing import List, Tuple

import numpy as np


def seidel_matrix_kmn(m: int, n: int) -> np.ndarray:
    """Return the Seidel matrix S = J - I - 2A of the complete bipartite graph
    K_{m,n}. Vertices 0..m-1 form the left part, m..m+n-1 the right part."""
    N = m + n
    A = np.zeros((N, N), dtype=float)
    for i in range(m):
        for j in range(m, N):
            A[i, j] = 1.0
            A[j, i] = 1.0
    J = np.ones((N, N), dtype=float)
    I = np.eye(N)
    return J - I - 2.0 * A


def delete_edge(S: np.ndarray, u: int, v: int) -> None:
    """Delete cross edge {u, v} in place: flip the Seidel entries from -1 to +1
    (i.e. add 2 to each of the symmetric off-diagonal entries)."""
    S[u, v] += 2.0
    S[v, u] += 2.0


def seidel_energy(S: np.ndarray) -> float:
    """Seidel energy: sum of absolute values of eigenvalues of the symmetric
    matrix S."""
    eigenvalues = np.linalg.eigvalsh(S)
    return float(np.sum(np.abs(eigenvalues)))


def base_energy_formula(m: int, n: int) -> float:
    """Closed-form base Seidel energy of K_{m,n}: 2(m + n - 1)."""
    return 2.0 * (m + n - 1)


def two_deletion_energy_formula(m: int, n: int) -> float:
    """Closed-form Seidel energy after deleting two independent edges:
    (m + n) + sqrt((m + n + 2)^2 - 32)."""
    N = m + n
    return N + math.sqrt((N + 2) ** 2 - 32)


def predicted_spectrum(m: int, n: int) -> List[float]:
    """The predicted Seidel spectrum of K_{m,n} minus two independent edges:
    {-1}^{N-5} u {1,1} u {-3} u {((N-4) +- sqrt((N+2)^2 - 32)) / 2}."""
    N = m + n
    disc = math.sqrt((N + 2) ** 2 - 32)
    spectrum: List[float] = [-1.0] * (N - 5)
    spectrum += [1.0, 1.0, -3.0]
    spectrum.append(((N - 4) + disc) / 2.0)
    spectrum.append(((N - 4) - disc) / 2.0)
    return sorted(spectrum)


def demo_single_case(m: int, n: int) -> None:
    """Full worked comparison for one graph K_{m,n}."""
    print(f"=== K_{{{m},{n}}}  (N = m + n = {m + n}) ===")

    S = seidel_matrix_kmn(m, n)
    base_numeric = seidel_energy(S)
    base_formula = base_energy_formula(m, n)
    print(f"  base energy   numeric = {base_numeric:.6f}   "
          f"formula 2(m+n-1) = {base_formula:.6f}")

    # Delete two independent edges: {0, m} and {1, m+1}.
    delete_edge(S, 0, m)          # left vertex 0  -- right vertex m (=b0)
    delete_edge(S, 1, m + 1)      # left vertex 1  -- right vertex m+1 (=b1)

    del_numeric = seidel_energy(S)
    del_formula = two_deletion_energy_formula(m, n)
    print(f"  2-del energy  numeric = {del_numeric:.6f}   "
          f"formula (m+n)+sqrt((m+n+2)^2-32) = {del_formula:.6f}")

    increased = del_numeric > base_numeric + 1e-9
    print(f"  strictly increased?  {increased}   "
          f"(gain = {del_numeric - base_numeric:+.6f})")

    # Compare full spectra.
    eig_numeric = sorted(float(x) for x in np.linalg.eigvalsh(S))
    eig_predicted = predicted_spectrum(m, n)
    max_err = max(abs(a - b) for a, b in zip(eig_numeric, eig_predicted))
    print(f"  max spectrum error (numeric vs predicted) = {max_err:.2e}")
    print()


def sweep(pairs: List[Tuple[int, int]]) -> None:
    """Verify the main theorem across a range of admissible (m, n)."""
    print("=== Sweep: strict increase across admissible (m, n) ===")
    print(f"  {'(m,n)':>10} {'base':>12} {'two-del':>14} {'gain':>12}  incr")
    all_ok = True
    for (m, n) in pairs:
        if m < 2 or n < 2 or m + n < 5:
            continue
        base = base_energy_formula(m, n)
        two = two_deletion_energy_formula(m, n)
        ok = two > base
        all_ok = all_ok and ok
        print(f"  {f'({m},{n})':>10} {base:12.5f} {two:14.5f} "
              f"{two - base:+12.5f}  {ok}")
    print(f"\n  main theorem holds on all sampled pairs: {all_ok}")
    print()


def matching_energy_formula(m: int, n: int, k: int) -> float:
    """Conjectural energy after deleting a matching of size k (k independent
    edges): (N + 2k - 4) + sqrt((N + 2)^2 - 16k), N = m + n, valid for
    N >= 2k + 1."""
    N = m + n
    return (N + 2 * k - 4) + math.sqrt((N + 2) ** 2 - 16 * k)


def demo_matching_conjecture(m: int, n: int) -> None:
    """Check the general k-matching conjecture numerically against a direct
    eigenvalue computation for a few k."""
    print(f"=== General k-matching conjecture for K_{{{m},{n}}} ===")
    N = m + n
    max_k = min(m, n)
    for k in range(1, max_k + 1):
        if N < 2 * k + 1:
            continue
        S = seidel_matrix_kmn(m, n)
        for t in range(k):                    # matching {t, m+t}, t=0..k-1
            delete_edge(S, t, m + t)
        numeric = seidel_energy(S)
        formula = matching_energy_formula(m, n, k)
        print(f"  k={k}: numeric = {numeric:.6f}   "
              f"formula (N+2k-4)+sqrt((N+2)^2-16k) = {formula:.6f}   "
              f"match = {abs(numeric - formula) < 1e-6}")
    print()


def main() -> None:
    # The smallest admissible witness: K_{2,3}, energy 8 -> 5 + sqrt(17).
    demo_single_case(2, 3)
    print(f"  (checkpoint) 5 + sqrt(17) = {5 + math.sqrt(17):.6f}\n")

    demo_single_case(3, 3)
    demo_single_case(4, 6)

    sweep([(m, n) for m in range(2, 8) for n in range(2, 8)])

    demo_matching_conjecture(6, 6)


if __name__ == "__main__":
    main()
