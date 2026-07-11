"""
Numerical demonstration of the Seidel-energy results for complete bipartite
graphs under single edge deletion.

Results verified numerically here:

  * Seidel energy of K_{m,n}:            E(K_{m,n})   = 2 (m + n - 1)
  * Seidel energy of K_{m,n} minus one
    (cross) edge:                        E(K_{m,n}-e) = (m+n-2)
                                                        + sqrt((m+n-2)(m+n+6))
  * Sharp threshold: the energy strictly increases under a single edge
    deletion  <=>  m + n >= 4.
  * The published "both parts >= 3" conjecture is false; K_{2,2} already
    increases:  6 -> 2 + 2*sqrt(5) ~ 6.4721.

The demo builds the Seidel matrices explicitly, computes eigenvalues with a
standard numerical solver, and checks them against the closed-form formulas.

Requires only the Python standard library plus NumPy.
"""

from __future__ import annotations

import math
from typing import List, Tuple

import numpy as np


# --------------------------------------------------------------------------- #
#  Construction of Seidel matrices
# --------------------------------------------------------------------------- #
def seidel_matrix_Kmn(m: int, n: int) -> np.ndarray:
    """Return the Seidel matrix S = J - I - 2A of the complete bipartite
    graph K_{m,n}, with vertices 0..m-1 (left part) and m..m+n-1 (right part).

    Entry rule: 0 on the diagonal, -1 across adjacent (cross-part) pairs,
    +1 across non-adjacent (same-part) pairs.
    """
    v = m + n
    S = np.zeros((v, v), dtype=float)
    for i in range(v):
        for j in range(v):
            if i == j:
                S[i, j] = 0.0
            else:
                same_part = (i < m) == (j < m)
                # same part -> non-adjacent -> +1 ; different part -> adjacent -> -1
                S[i, j] = 1.0 if same_part else -1.0
    return S


def delete_cross_edge(S: np.ndarray, m: int, a: int, b: int) -> np.ndarray:
    """Delete the cross edge {a, b} (a in left part, b in right part) from the
    Seidel matrix by flipping the two symmetric entries from -1 to +1."""
    assert a < m <= b, "a must be in the left part and b in the right part"
    S2 = S.copy()
    S2[a, b] = 1.0
    S2[b, a] = 1.0
    return S2


# --------------------------------------------------------------------------- #
#  Energies: numerical (from eigenvalues) and closed-form
# --------------------------------------------------------------------------- #
def seidel_energy_numeric(S: np.ndarray) -> float:
    """Seidel energy = sum of |eigenvalue| of the symmetric matrix S."""
    eigenvalues = np.linalg.eigvalsh(S)
    return float(np.sum(np.abs(eigenvalues)))


def energy_Kmn_formula(m: int, n: int) -> float:
    """Closed form: E(K_{m,n}) = 2 (m + n - 1)."""
    return 2.0 * (m + n - 1)


def energy_deleted_formula(m: int, n: int) -> float:
    """Closed form: E(K_{m,n} - e) = (m+n-2) + sqrt((m+n-2)(m+n+6))."""
    N = m + n
    return (N - 2) + math.sqrt((N - 2) * (N + 6))


def energy_increases(m: int, n: int) -> bool:
    """Sharp threshold predicate: strict increase <=> m + n >= 4."""
    return (m + n) >= 4


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def verify_pair(m: int, n: int, a: int = 0, b: int | None = None) -> None:
    """Print a full comparison for a single (m, n), edge {a, b}."""
    if b is None:
        b = m  # first vertex of the right part
    S = seidel_matrix_Kmn(m, n)
    Sdel = delete_cross_edge(S, m, a, b)

    e_base_num = seidel_energy_numeric(S)
    e_del_num = seidel_energy_numeric(Sdel)
    e_base_frm = energy_Kmn_formula(m, n)
    e_del_frm = energy_deleted_formula(m, n)

    print(f"K_{{{m},{n}}}  (m+n = {m + n})")
    print(f"  E(K_mn)      numeric = {e_base_num:.10f}   formula = {e_base_frm:.10f}")
    print(f"  E(K_mn - e)  numeric = {e_del_num:.10f}   formula = {e_del_frm:.10f}")
    assert abs(e_base_num - e_base_frm) < 1e-8, "base energy mismatch"
    assert abs(e_del_num - e_del_frm) < 1e-8, "deleted energy mismatch"

    increased = e_del_num > e_base_num + 1e-9
    predicted = energy_increases(m, n)
    print(f"  strict increase? observed = {increased}   predicted (m+n>=4) = {predicted}")
    assert increased == predicted, "threshold prediction mismatch"
    print()


def spectrum_report(m: int, n: int) -> Tuple[List[float], List[float]]:
    """Return (base_spectrum, deleted_spectrum) rounded, and print them next to
    the predicted closed-form eigenvalues."""
    S = seidel_matrix_Kmn(m, n)
    Sdel = delete_cross_edge(S, m, 0, m)
    base = sorted(np.round(np.linalg.eigvalsh(S), 6).tolist())
    deleted = sorted(np.round(np.linalg.eigvalsh(Sdel), 6).tolist())

    N = m + n
    disc = math.sqrt((N - 2) * (N + 6))
    predicted_del = sorted(
        [-1.0] * (N - 3)
        + [1.0]
        + [((N - 4) + disc) / 2, ((N - 4) - disc) / 2]
    )
    print(f"Spectra for K_{{{m},{n}}}:")
    print(f"  base eigenvalues     : {base}")
    print(f"     predicted         : {sorted([-1.0]*(N-1) + [float(N-1)])}")
    print(f"  deleted eigenvalues  : {deleted}")
    print(f"     predicted         : {[round(x,6) for x in predicted_del]}")
    print()
    return base, deleted


def main() -> None:
    print("=" * 68)
    print("Seidel energy of complete bipartite graphs under edge deletion")
    print("=" * 68)
    print()

    print("--- Energy comparison across several (m, n) ---\n")
    for (m, n) in [(2, 2), (1, 3), (3, 3), (2, 15), (4, 4), (3, 6), (5, 7)]:
        verify_pair(m, n)

    print("--- Explicit spectra ---\n")
    spectrum_report(2, 2)
    spectrum_report(3, 3)

    print("--- The K_{2,2} counterexample to the 'both parts >= 3' conjecture ---\n")
    e0 = energy_Kmn_formula(2, 2)
    e1 = energy_deleted_formula(2, 2)
    print(f"  E(K_2,2)      = {e0:.6f}   (= 6)")
    print(f"  E(K_2,2 - e)  = {e1:.6f}   (= 2 + 2*sqrt(5) = {2 + 2*math.sqrt(5):.6f})")
    print(f"  strict increase with both parts of size 2: {e1 > e0}")
    print("  => the conjecture is false.\n")

    print("--- Boundary case: m+n = 3 (no increase) vs m+n = 4 (increase) ---\n")
    for (m, n) in [(1, 2), (1, 3)]:
        e0 = energy_Kmn_formula(m, n)
        e1 = energy_deleted_formula(m, n)
        rel = "increase" if e1 > e0 else "no increase"
        print(f"  K_{{{m},{n}}}: {e0:.4f} -> {e1:.4f}   ({rel})")
    print()
    print("All numerical checks passed.")


if __name__ == "__main__":
    main()
