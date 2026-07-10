"""Numerical demonstrations for leading-term cancellation in a spectral
heat-kernel expansion.

The leading 1/N correction to a heat-kernel trace Z(t) = Tr e^{-tH} of a system
with energy levels E_i and first-order diagonal shifts d_i is the spectral
function

    L(t) = sum_i d_i * exp(-t * E_i).

This module illustrates the main theorems:

  * L(0) equals the trace sum_i d_i of the perturbation.
  * For a NON-DEGENERATE spectrum (all E_i distinct), L vanishes identically iff
    every d_i = 0.
  * For a GENERAL spectrum, L vanishes identically iff, for each distinct energy
    value v, the aggregate shift S(v) = sum_{E_i = v} d_i is zero (level-by-level
    balance).

All functions are self-contained and use only the Python standard library.
"""

from __future__ import annotations

import math
from collections import defaultdict
from typing import Dict, List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Core quantities
# --------------------------------------------------------------------------- #

def heat_kernel_leading(energies: Sequence[float], shifts: Sequence[float],
                        t: float) -> float:
    """Evaluate the leading spectral correction L(t) = sum_i d_i exp(-t E_i)."""
    if len(energies) != len(shifts):
        raise ValueError("energies and shifts must have equal length")
    return sum(d * math.exp(-t * e) for e, d in zip(energies, shifts))


def trace(shifts: Sequence[float]) -> float:
    """The trace of the perturbation, equal to L(0)."""
    return sum(shifts)


def aggregate_level_shifts(energies: Sequence[float], shifts: Sequence[float],
                           tol: float = 1e-12) -> Dict[float, float]:
    """Group shifts by energy level and return S(v) = sum_{E_i = v} d_i.

    Energies within `tol` of each other are treated as the same level; the
    representative key is the first energy seen for that level.
    """
    levels: Dict[float, float] = defaultdict(float)
    reps: List[float] = []
    for e, d in zip(energies, shifts):
        key = next((r for r in reps if abs(r - e) <= tol), None)
        if key is None:
            reps.append(e)
            key = e
        levels[key] += d
    return dict(levels)


# --------------------------------------------------------------------------- #
# Predicates derived from the theorems
# --------------------------------------------------------------------------- #

def is_non_degenerate(energies: Sequence[float], tol: float = 1e-12) -> bool:
    """True iff all energy levels are distinct (spectrum is non-degenerate)."""
    srt = sorted(energies)
    return all(abs(b - a) > tol for a, b in zip(srt, srt[1:]))


def cancels_identically(energies: Sequence[float], shifts: Sequence[float],
                        tol: float = 1e-12) -> bool:
    """Exact test of L == 0 for all t, via the level-by-level theorem.

    L vanishes identically iff every aggregate level shift S(v) is zero. This is
    an exact finite check: no transcendental evaluation is required.
    """
    return all(abs(s) <= tol for s in aggregate_level_shifts(energies, shifts,
                                                             tol).values())


def sampled_max_abs(energies: Sequence[float], shifts: Sequence[float],
                    ts: Sequence[float]) -> float:
    """Numerical sanity check: max |L(t)| over a set of sample temperatures."""
    return max(abs(heat_kernel_leading(energies, shifts, t)) for t in ts)


# --------------------------------------------------------------------------- #
# Vandermonde reconstruction (non-degenerate spectra)
# --------------------------------------------------------------------------- #

def reconstruct_shifts_from_samples(energies: Sequence[float],
                                    samples: Sequence[float]) -> List[float]:
    """Recover shifts d from integer-temperature samples L(0..n-1).

    For distinct energies, the map d -> (L(0), ..., L(n-1)) is multiplication by
    the invertible Vandermonde matrix in x_i = exp(-E_i). We solve the linear
    system by Gaussian elimination.
    """
    n = len(energies)
    if len(samples) != n:
        raise ValueError("need exactly n samples")
    x = [math.exp(-e) for e in energies]
    # Row k, column i: x_i^k ; augmented with samples.
    mat: List[List[float]] = [
        [x[i] ** k for i in range(n)] + [samples[k]] for k in range(n)
    ]
    # Gaussian elimination with partial pivoting.
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(mat[r][col]))
        if abs(mat[piv][col]) < 1e-15:
            raise ValueError("singular system (energies not distinct?)")
        mat[col], mat[piv] = mat[piv], mat[col]
        pivval = mat[col][col]
        mat[col] = [v / pivval for v in mat[col]]
        for r in range(n):
            if r != col and abs(mat[r][col]) > 0:
                factor = mat[r][col]
                mat[r] = [a - factor * b for a, b in zip(mat[r], mat[col])]
    return [mat[i][n] for i in range(n)]


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_trace() -> None:
    print("=" * 68)
    print("DEMO 1  --  L(0) equals the trace of the perturbation")
    print("=" * 68)
    energies = [0.0, 1.0, 2.5, 4.0]
    shifts = [0.7, -1.2, 0.3, 0.9]
    l0 = heat_kernel_leading(energies, shifts, 0.0)
    tr = trace(shifts)
    print(f"  energies = {energies}")
    print(f"  shifts   = {shifts}")
    print(f"  L(0)     = {l0:.6f}")
    print(f"  sum d_i  = {tr:.6f}")
    print(f"  equal?     {math.isclose(l0, tr)}")
    print()


def demo_nondegenerate() -> None:
    print("=" * 68)
    print("DEMO 2  --  Distinct energies forbid nontrivial cancellation")
    print("=" * 68)
    energies = [0.0, 1.0]
    shifts = [1.0, -1.0]
    ts = [0.0, 0.5, 1.0, 2.0, 5.0]
    print(f"  E = {energies}, d = {shifts}   (opposite shifts, DISTINCT levels)")
    print(f"  non-degenerate? {is_non_degenerate(energies)}")
    for t in ts:
        print(f"    L({t:>3}) = {heat_kernel_leading(energies, shifts, t): .6f}")
    print(f"  cancels identically? {cancels_identically(energies, shifts)}")
    print("  -> consistent with: distinct levels => must have all d_i = 0")
    print()


def demo_degenerate_cancellation() -> None:
    print("=" * 68)
    print("DEMO 3  --  Degeneracy permits nontrivial cancellation")
    print("=" * 68)
    a, c = 1.3, 2.0
    energies = [a, a]
    shifts = [c, -c]
    ts = [0.0, 0.5, 1.0, 2.0, 5.0, 12.0]
    print(f"  E = {energies}, d = {shifts}   (opposite shifts, SAME level)")
    print(f"  non-degenerate? {is_non_degenerate(energies)}")
    print(f"  aggregate level shifts S(v) = {aggregate_level_shifts(energies, shifts)}")
    print(f"  max |L(t)| over samples = {sampled_max_abs(energies, shifts, ts):.2e}")
    print(f"  cancels identically? {cancels_identically(energies, shifts)}")
    print("  -> nonzero individual shifts, yet L == 0 for all t")
    print()


def demo_level_balance() -> None:
    print("=" * 68)
    print("DEMO 4  --  Level-by-level balance on a mixed spectrum")
    print("=" * 68)
    # Two degenerate levels (at 0.0 and 3.0) plus a simple level (at 1.0).
    energies = [0.0, 0.0, 0.0, 3.0, 3.0, 1.0]
    shifts = [2.0, -5.0, 3.0, 4.0, -4.0, 0.0]  # each level balances to 0
    print(f"  E = {energies}")
    print(f"  d = {shifts}")
    for v, s in aggregate_level_shifts(energies, shifts).items():
        print(f"    level v={v}:  S(v) = {s:+.3f}")
    print(f"  max |L(t)| over samples = "
          f"{sampled_max_abs(energies, shifts, [0.0, 0.7, 1.5, 3.0, 8.0]):.2e}")
    print(f"  cancels identically? {cancels_identically(energies, shifts)}")
    # Now break one level's balance and observe non-cancellation.
    broken = list(shifts)
    broken[0] += 1.0
    print(f"\n  perturb d[0] by +1 -> d = {broken}")
    for v, s in aggregate_level_shifts(energies, broken).items():
        print(f"    level v={v}:  S(v) = {s:+.3f}")
    print(f"  cancels identically? {cancels_identically(energies, broken)}")
    print()


def demo_vandermonde_reconstruction() -> None:
    print("=" * 68)
    print("DEMO 5  --  Reconstructing shifts from temperature samples")
    print("=" * 68)
    energies = [0.0, 0.6, 1.7, 3.1]
    true_shifts = [1.5, -2.0, 0.25, 0.9]
    samples = [heat_kernel_leading(energies, true_shifts, float(k))
               for k in range(len(energies))]
    recovered = reconstruct_shifts_from_samples(energies, samples)
    print(f"  energies      = {energies}")
    print(f"  true shifts   = {true_shifts}")
    print(f"  L(0..n-1)     = {[round(s, 6) for s in samples]}")
    print(f"  recovered     = {[round(r, 6) for r in recovered]}")
    err = max(abs(a - b) for a, b in zip(true_shifts, recovered))
    print(f"  max abs error = {err:.2e}")
    print()


def main() -> None:
    demo_trace()
    demo_nondegenerate()
    demo_degenerate_cancellation()
    demo_level_balance()
    demo_vandermonde_reconstruction()


if __name__ == "__main__":
    main()
