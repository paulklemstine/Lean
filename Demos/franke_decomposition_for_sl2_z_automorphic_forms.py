"""
Numerical demonstrations for the Franke decomposition of level-one spherical
automorphic forms on the modular surface X = SL(2, Z) \\ H.

The results illustrated here:

  1. Residue of the arithmetic scattering factor:
         (s - 1) * zeta(2s - 1)  ->  1/2   as s -> 1.
  2. Genuine blow-up: |zeta(2s - 1)| -> infinity as s -> 1.
  3. Algebraic skeleton: V = cusp (+) Eis is an internal direct sum, so every
     f in V has unique coordinates (c, a_1, ..., a_n). We solve for them in a
     finite-dimensional model.
  4. Level-one character count: exactly one Dirichlet character of conductor 1.

The script is self-contained. It uses `mpmath` for the Riemann zeta function if
available, otherwise falls back to an Euler-Maclaurin / series approximation so
it runs with only the standard library plus NumPy.
"""

from __future__ import annotations

from typing import List, Tuple
import cmath

import numpy as np

try:
    import mpmath as mp

    def riemann_zeta(u: complex) -> complex:
        """Riemann zeta via mpmath (accurate, includes analytic continuation)."""
        return complex(mp.zeta(u))

except Exception:  # pragma: no cover - fallback path

    def riemann_zeta(u: complex) -> complex:
        """Fallback zeta on Re(u) > 1 via a truncated Dirichlet series.

        Accurate enough for the demonstrations below, which sample points with
        Re(2s - 1) > 1.
        """
        total = 0.0 + 0.0j
        for n in range(1, 200_000):
            total += 1.0 / (n ** u)
        return total


def arithmetic_factor_residue_estimate(k: int) -> Tuple[complex, complex]:
    """Return (s, (s-1)*zeta(2s-1)) for s = 1 + 10**(-k) approaching 1 from
    the right along the real axis.

    By the Residue Theorem for the arithmetic scattering factor, the second
    entry converges to 1/2 as k -> infinity.
    """
    s = 1.0 + 10.0 ** (-k)
    value = (s - 1.0) * riemann_zeta(2.0 * s - 1.0)
    return complex(s), complex(value)


def blowup_magnitude(k: int) -> Tuple[complex, float]:
    """Return (s, |zeta(2s-1)|) for s = 1 + 10**(-k).

    The magnitude grows without bound as k -> infinity, witnessing that the pole
    of the Eisenstein series at s = 1 is genuine.
    """
    s = 1.0 + 10.0 ** (-k)
    return complex(s), abs(riemann_zeta(2.0 * s - 1.0))


def direct_sum_coordinates(
    cusp_basis: np.ndarray, eis_basis: np.ndarray, f: np.ndarray
) -> Tuple[np.ndarray, np.ndarray]:
    """Solve f = C @ c_coords + Eis @ a_coords in a finite-dimensional model.

    Parameters
    ----------
    cusp_basis : (d, p) array whose columns span the cusp subspace.
    eis_basis  : (d, n) array whose columns are the Laurent coefficients l_i.
    f          : (d,) vector to decompose.

    Returns
    -------
    (c_coords, a_coords): coordinates of the cusp part and the Eisenstein part.
    When [cusp_basis | eis_basis] is a basis of the ambient space, these are
    unique, illustrating the existence and uniqueness of the Franke splitting.
    """
    stacked = np.hstack([cusp_basis, eis_basis])
    solution, *_ = np.linalg.lstsq(stacked, f, rcond=None)
    p = cusp_basis.shape[1]
    return solution[:p], solution[p:]


def dirichlet_characters_of_conductor(conductor: int) -> int:
    """Number of Dirichlet characters of the given conductor.

    For conductor 1 this equals the order of the trivial group's character
    group, namely 1 -- the level-one uniqueness of the trivial character.
    """
    if conductor == 1:
        return 1
    # For general modulus q the count is Euler's totient phi(q).
    count = sum(1 for a in range(1, conductor + 1) if _gcd(a, conductor) == 1)
    return count


def _gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return a


def main() -> None:
    print("=" * 70)
    print("1. Residue of the arithmetic scattering factor  (s-1) * zeta(2s-1)")
    print("   Expected limit: 0.5")
    print("-" * 70)
    for k in range(1, 8):
        s, val = arithmetic_factor_residue_estimate(k)
        print(f"  s = 1 + 1e-{k}:  (s-1)*zeta(2s-1) = {val.real:.10f} "
              f"(imag {val.imag:+.2e})")

    print()
    print("=" * 70)
    print("2. Genuine blow-up of the arithmetic factor  |zeta(2s-1)|")
    print("   Expected behaviour: grows without bound")
    print("-" * 70)
    for k in range(1, 8):
        s, mag = blowup_magnitude(k)
        print(f"  s = 1 + 1e-{k}:  |zeta(2s-1)| = {mag:.4e}")

    print()
    print("=" * 70)
    print("3. Direct-sum coordinates: V = cusp (+) Eis")
    print("-" * 70)
    rng = np.random.default_rng(0)
    d = 5           # ambient dimension of the toy space of forms
    p = 3           # dimension of the cusp subspace
    n = 2           # number of Laurent coefficients (Eisenstein span)
    cusp_basis = rng.standard_normal((d, p))
    eis_basis = rng.standard_normal((d, n))
    # Build a form with known parts to check uniqueness of the recovery.
    true_c = np.array([1.0, -2.0, 0.5])
    true_a = np.array([3.0, -1.0])
    f = cusp_basis @ true_c + eis_basis @ true_a
    c_coords, a_coords = direct_sum_coordinates(cusp_basis, eis_basis, f)
    print("  recovered cusp coordinates :", np.round(c_coords, 6))
    print("  true cusp coordinates      :", true_c)
    print("  recovered Eisenstein coeffs:", np.round(a_coords, 6))
    print("  true Eisenstein coeffs     :", true_a)
    residual = np.linalg.norm(cusp_basis @ c_coords + eis_basis @ a_coords - f)
    print(f"  reconstruction error       : {residual:.2e}")

    print()
    print("=" * 70)
    print("4. Level-one character count")
    print("-" * 70)
    print("  Dirichlet characters of conductor 1:",
          dirichlet_characters_of_conductor(1), "(only the trivial character)")
    for q in (2, 3, 4, 5):
        print(f"  Dirichlet characters of conductor {q}:",
              dirichlet_characters_of_conductor(q))


if __name__ == "__main__":
    main()
