"""
Numerical demonstrations for
"The Moment Spectrum and the Dimension of the Leading-Term Cancellation Space".

We study the leading heat-kernel-type correction

    L(t) = sum_i d_i * exp(-t * E_i)

over a real spectrum E = (E_1, ..., E_n) with diagonal shifts d = (d_1, ..., d_n),
and illustrate the paper's main results:

  * Theorem A (moment spectrum): L(t) == 0 for all t  <=>  every spectral moment
      m_k = sum_i d_i * E_i^k  vanishes  <=>  every level sum s_v = sum_{E_j=v} d_j
      vanishes.
  * Theorem B/C (kernel realization & dimension formula): the cancellation space
      {d : L == 0} is the kernel of the level-aggregation map S(d)(v) = s_v, and
      has dimension exactly n - m, where m = #distinct energy levels.
  * Corollary D: nontrivial cancellation exists  <=>  m < n (degenerate spectrum).

Self-contained: standard library + math only (no third-party dependencies).
"""

from __future__ import annotations

import math
from collections import defaultdict
from typing import Dict, List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Core quantities
# --------------------------------------------------------------------------- #

def leading_term(E: Sequence[float], d: Sequence[float], t: float) -> float:
    """Evaluate L(t) = sum_i d_i * exp(-t * E_i)."""
    return sum(di * math.exp(-t * Ei) for Ei, di in zip(E, d))


def spectral_moment(E: Sequence[float], d: Sequence[float], k: int) -> float:
    """Evaluate the k-th spectral moment m_k = sum_i d_i * E_i^k (with 0^0 = 1)."""
    return sum(di * (Ei ** k) for Ei, di in zip(E, d))


def distinct_levels(E: Sequence[float], tol: float = 1e-9) -> List[float]:
    """Return the sorted distinct energy values, deduplicated up to tolerance."""
    values: List[float] = []
    for Ei in sorted(E):
        if not values or abs(Ei - values[-1]) > tol:
            values.append(Ei)
    return values


def level_sums(E: Sequence[float], d: Sequence[float],
               tol: float = 1e-9) -> Dict[float, float]:
    """Aggregate shift s_v = sum_{j : E_j = v} d_j for each distinct level v."""
    levels = distinct_levels(E, tol)
    sums: Dict[float, float] = {v: 0.0 for v in levels}
    for Ei, di in zip(E, d):
        # snap to the nearest recorded level
        v = min(levels, key=lambda w: abs(w - Ei))
        sums[v] += di
    return sums


# --------------------------------------------------------------------------- #
# Structural results
# --------------------------------------------------------------------------- #

def cancellation_dimension(E: Sequence[float], tol: float = 1e-9) -> int:
    """Dimension of the cancellation space: n - m (Theorem C)."""
    n = len(E)
    m = len(distinct_levels(E, tol))
    return n - m


def cancellation_basis(E: Sequence[float], tol: float = 1e-9) -> List[List[float]]:
    """
    A basis of the cancellation space (Algorithm 8.2).

    Group indices by energy level; for each level with anchor index a and each
    other member j, emit the vector e_j - e_a. These n - m vectors are linearly
    independent and each has zero level sum on every level.
    """
    n = len(E)
    levels = distinct_levels(E, tol)
    fibers: Dict[int, List[int]] = defaultdict(list)
    for idx, Ei in enumerate(E):
        v = min(range(len(levels)), key=lambda r: abs(levels[r] - Ei))
        fibers[v].append(idx)

    basis: List[List[float]] = []
    for members in fibers.values():
        anchor = members[0]
        for j in members[1:]:
            vec = [0.0] * n
            vec[j] = 1.0
            vec[anchor] = -1.0
            basis.append(vec)
    return basis


def cancels_for_all_t(E: Sequence[float], d: Sequence[float],
                      tol: float = 1e-9) -> bool:
    """Test whether L(t) == 0 for all t, via the level-sum criterion."""
    return all(abs(s) <= tol for s in level_sums(E, d, tol).values())


def moments_vanish(E: Sequence[float], d: Sequence[float],
                   kmax: int, tol: float = 1e-9) -> bool:
    """Check that spectral moments m_0, ..., m_kmax all vanish (Theorem A test)."""
    return all(abs(spectral_moment(E, d, k)) <= tol for k in range(kmax + 1))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_moment_equivalence() -> None:
    print("=" * 70)
    print("DEMO 1: Moment-spectrum equivalence (Theorem A)")
    print("=" * 70)
    E = [1.0, 1.0, 3.0]          # levels 1 (doubly degenerate) and 3
    d = [2.0, -2.0, 0.0]         # cancels: level sums both zero
    m = len(distinct_levels(E))
    ts = [-1.0, 0.0, 0.5, 2.0, 5.0]
    print(f"E = {E},  d = {d}")
    print("Level sums:", {round(k, 3): round(v, 12) for k, v in level_sums(E, d).items()})
    print("L(t) at several temperatures:")
    for t in ts:
        print(f"   L({t:+.1f}) = {leading_term(E, d, t): .3e}")
    print(f"First {m} moments:", [round(spectral_moment(E, d, k), 12) for k in range(m)])
    print(f"cancels_for_all_t = {cancels_for_all_t(E, d)},  "
          f"moments_vanish   = {moments_vanish(E, d, 2 * m)}")
    print()


def demo_dimension_formula() -> None:
    print("=" * 70)
    print("DEMO 2: Dimension formula  dim = n - m  (Theorem C)")
    print("=" * 70)
    spectra: List[Tuple[str, List[float]]] = [
        ("non-degenerate", [0.0, 1.0, 2.0, 3.0]),
        ("one coincidence", [0.0, 1.0, 1.0, 3.0]),
        ("two pairs", [5.0, 5.0, 7.0, 7.0]),
        ("all equal", [2.0, 2.0, 2.0, 2.0]),
    ]
    for name, E in spectra:
        n, m = len(E), len(distinct_levels(E))
        dim = cancellation_dimension(E)
        basis = cancellation_basis(E)
        assert dim == n - m == len(basis)
        print(f"{name:16s}: n={n}, m={m}, dim(cancellation)={dim}  (basis size {len(basis)})")
    print()


def demo_degeneracy_criterion() -> None:
    print("=" * 70)
    print("DEMO 3: Nontrivial cancellation exists  <=>  degenerate (Corollary D)")
    print("=" * 70)
    for E in ([0.0, 1.0], [4.0, 4.0], [1.0, 2.0, 2.0]):
        n, m = len(E), len(distinct_levels(E))
        degenerate = m < n
        dim = cancellation_dimension(E)
        print(f"E = {E}: degenerate={degenerate}, dim={dim}, "
              f"nontrivial cancellation possible = {dim > 0}")
    print()


def demo_basis_verification() -> None:
    print("=" * 70)
    print("DEMO 4: Every basis vector genuinely cancels L(t)")
    print("=" * 70)
    E = [1.0, 1.0, 1.0, 4.0, 4.0]
    basis = cancellation_basis(E)
    print(f"E = {E},  dim = {cancellation_dimension(E)}, basis vectors:")
    for b in basis:
        residual = max(abs(leading_term(E, b, t)) for t in (0.0, 0.3, 1.0, 2.5))
        print(f"   d = {b}   max|L(t)| = {residual: .3e}   cancels = {residual < 1e-9}")
    print()


if __name__ == "__main__":
    demo_moment_equivalence()
    demo_dimension_formula()
    demo_degeneracy_criterion()
    demo_basis_verification()
    print("All demonstrations completed.")
