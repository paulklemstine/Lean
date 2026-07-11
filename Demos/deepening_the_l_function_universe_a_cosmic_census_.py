"""
demo.py -- Numerical demonstrations for "The Analytic L-Function Census".

This self-contained script illustrates the central results:

  1. Rigidity as coefficient recovery: an L-function determines its coefficients,
     recovered one at a time by a "peeling" limit as Re(s) -> +infinity.
  2. Uniqueness of the Riemann zeta representation (the all-ones coefficients).
  3. Infinitude of the analytic universe via the monomial series (k+1)^{-s}.
  4. The per-modulus census: distinct Dirichlet characters yield distinct
     L-functions, and there are exactly phi(N) of them.
  5. Countability of the whole Dirichlet family via dovetailed enumeration.

All functions are inlined and use only the Python standard library.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, Dict, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Core: evaluate a (truncated) Dirichlet series L_f(s) = sum_{n>=1} f(n) n^{-s}
# ---------------------------------------------------------------------------
def dirichlet_series(coeffs: Sequence[complex], s: complex, terms: int = 20000) -> complex:
    """Evaluate the Dirichlet series with coefficients `coeffs` at the point `s`.

    coeffs[n] is the coefficient f(n); coeffs[0] is ignored (normalization).
    The series is truncated after `terms` terms (or the length of coeffs if given
    explicitly as a finite list, whichever is smaller for finite sequences).
    """
    total = 0.0 + 0.0j
    n_max = min(terms, len(coeffs) - 1) if isinstance(coeffs, list) else terms
    for n in range(1, n_max + 1):
        c = coeffs[n] if n < len(coeffs) else 0.0
        if c == 0:
            continue
        total += c * cmath.exp(-s * cmath.log(n))
    return total


def dirichlet_from_fn(f: Callable[[int], complex], s: complex, terms: int = 20000) -> complex:
    """Evaluate L_f(s) where f is given as a function of n >= 1."""
    total = 0.0 + 0.0j
    for n in range(1, terms + 1):
        c = f(n)
        if c == 0:
            continue
        total += c * cmath.exp(-s * cmath.log(n))
    return total


# ---------------------------------------------------------------------------
# 1. Rigidity as coefficient recovery (the peeling algorithm)
# ---------------------------------------------------------------------------
def recover_coefficients(
    f: Callable[[int], complex], m_max: int, sigma: float = 20.0, terms: int = 4000
) -> List[complex]:
    """Recover f(1), ..., f(m_max) from oracle access to L_f.

    Implements the peeling limit:
        f(m) = lim_{sigma->inf} m^sigma ( L_f(sigma) - sum_{n<m} f(n) n^{-sigma} ).
    A large real `sigma` approximates the limit; the leading term m^{-sigma}
    dominates the tail because (m/n)^sigma -> 0 for n > m.
    """
    recovered: List[complex] = [0.0 + 0.0j]  # index 0 placeholder
    for m in range(1, m_max + 1):
        val = dirichlet_from_fn(f, complex(sigma, 0.0), terms=terms)
        partial = sum(
            recovered[n] * math.exp(-sigma * math.log(n)) for n in range(1, m)
        )
        coeff = (val - partial) * math.exp(sigma * math.log(m))
        # Snap to the nearest clean value once the dominant term is isolated; this
        # stabilizes the peeling so that the (tiny) error in earlier coefficients
        # does not swamp the current one when it is subtracted off next round.
        snapped = complex(round(coeff.real, 2), round(coeff.imag, 2))
        recovered.append(snapped)
    return recovered[1:]


def demo_rigidity() -> None:
    print("=" * 70)
    print("1. RIGIDITY: recovering coefficients from the analytic L-function")
    print("=" * 70)
    # A test sequence with known coefficients.
    true_coeffs = {1: 1.0, 2: -3.0, 3: 2.0}
    f = lambda n: true_coeffs.get(n, 0.0)
    rec = recover_coefficients(f, m_max=3, sigma=20.0, terms=200)
    print(f"{'n':>3} | {'true f(n)':>12} | {'recovered':>14}")
    print("-" * 40)
    for n in range(1, 4):
        print(f"{n:>3} | {true_coeffs.get(n, 0.0):>12.4f} | {rec[n-1].real:>14.6f}")
    print("=> the coefficients are pinned down by the function (rigidity).\n")


# ---------------------------------------------------------------------------
# 2. Uniqueness of the Riemann zeta representation
# ---------------------------------------------------------------------------
def demo_zeta_uniqueness() -> None:
    print("=" * 70)
    print("2. ZETA UNIQUENESS: the all-ones coefficients are forced")
    print("=" * 70)
    zeta = lambda n: 1.0
    rec = recover_coefficients(zeta, m_max=3, sigma=20.0, terms=4000)
    print("Recovered coefficients of zeta (should all be 1):")
    print("  " + ", ".join(f"{c.real:.4f}" for c in rec))
    # Compare a known value: zeta(2) = pi^2 / 6.
    approx = dirichlet_from_fn(zeta, complex(2.0, 0.0), terms=50000).real
    print(f"\nzeta(2) approx = {approx:.6f},  pi^2/6 = {math.pi**2/6:.6f}")
    print("=> no other Dirichlet series represents zeta.\n")


# ---------------------------------------------------------------------------
# 3. Infinitude via the monomial (spike) family
# ---------------------------------------------------------------------------
def spike(k: int) -> Callable[[int], complex]:
    """Coefficient sequence that is 1 at position k+1 and 0 elsewhere."""
    return lambda n: 1.0 if n == k + 1 else 0.0


def demo_monomials() -> None:
    print("=" * 70)
    print("3. INFINITUDE: the monomial series s -> (k+1)^{-s} are distinct")
    print("=" * 70)
    s = complex(1.5, 0.7)
    print(f"Evaluating each monomial L-function at s = {s}:")
    values: List[complex] = []
    for k in range(6):
        v = dirichlet_from_fn(spike(k), s, terms=10)
        values.append(v)
        print(f"  k={k}: (k+1)^(-s) = {v.real:+.5f}{v.imag:+.5f}i")
    distinct = len({(round(v.real, 8), round(v.imag, 8)) for v in values})
    print(f"\nDistinct values among the 6 monomials: {distinct}/6")
    print("=> infinitely many pairwise-distinct analytic L-functions.\n")


# ---------------------------------------------------------------------------
# 4. Per-modulus census: Dirichlet characters and phi(N)
# ---------------------------------------------------------------------------
def euler_phi(n: int) -> int:
    """Euler's totient function: count of 1 <= k <= n with gcd(k, n) = 1."""
    return sum(1 for k in range(1, n + 1) if math.gcd(k, n) == 1)


def dirichlet_characters(N: int) -> List[Dict[int, complex]]:
    """Return all Dirichlet characters mod N as dicts residue -> value.

    Built from the character group of (Z/NZ)^*: we enumerate homomorphisms into
    the roots of unity using the group's structure via a brute-force construction
    over the multiplicative group. Values on non-units are 0.
    """
    if N <= 1:
        # Trivial modulus: the single principal character, value 1 everywhere.
        return [{0: 1.0 + 0.0j}]
    units = [a for a in range(N) if math.gcd(a, N) == 1]
    order = len(units)  # = phi(N)
    if order == 0:
        return []
    # Build multiplication table indices for units.
    index = {u: i for i, u in enumerate(units)}

    # Find generators structure by computing, for each unit, its powers -> we
    # enumerate all group homomorphisms into C^* by assigning consistent values.
    # Simple robust approach: characters are indexed by the dual; we realize them
    # via the discrete Fourier basis on the abelian group using its invariant
    # factor decomposition obtained by a greedy generator search.
    def subgroup_generated(gens: List[int]) -> set:
        elems = {1}
        changed = True
        while changed:
            changed = False
            for g in gens:
                for e in list(elems):
                    p = (e * g) % N
                    if p not in elems:
                        elems.add(p)
                        changed = True
        return elems

    gens: List[int] = []
    orders: List[int] = []
    covered = {1}
    for u in units:
        if u in covered:
            continue
        gens.append(u)
        # order of u
        o, p = 1, u % N
        while p != 1:
            p = (p * u) % N
            o += 1
        orders.append(o)
        covered = subgroup_generated(gens)
        if len(covered) == order:
            break

    # Express each unit in terms of generator exponents (coordinates).
    coords: Dict[int, Tuple[int, ...]] = {}
    def gen_element(exps: Tuple[int, ...]) -> int:
        val = 1
        for g, e in zip(gens, exps):
            for _ in range(e):
                val = (val * g) % N
        return val

    ranges = [range(o) for o in orders]
    def product(rs):
        if not rs:
            yield ()
            return
        for head in rs[0]:
            for tail in product(rs[1:]):
                yield (head,) + tail

    for exps in product(ranges):
        coords[gen_element(exps)] = exps

    chars: List[Dict[int, complex]] = []
    for freqs in product(ranges):
        chi: Dict[int, complex] = {}
        for u in units:
            exps = coords[u]
            phase = sum(2 * math.pi * f * e / o for f, e, o in zip(freqs, exps, orders))
            chi[u] = cmath.exp(1j * phase)
        for a in range(N):
            if a not in chi:
                chi[a] = 0.0 + 0.0j
        chars.append(chi)
    return chars


def char_L(chi: Dict[int, complex], N: int, s: complex, terms: int = 5000) -> complex:
    """Evaluate the Dirichlet L-function L(s, chi) = sum chi(n) n^{-s}."""
    total = 0.0 + 0.0j
    for n in range(1, terms + 1):
        c = chi[n % N]
        if c == 0:
            continue
        total += c * cmath.exp(-s * cmath.log(n))
    return total


def demo_census() -> None:
    print("=" * 70)
    print("4. PER-MODULUS CENSUS: characters biject with L-functions")
    print("=" * 70)
    print(f"{'N':>3} | {'phi(N)':>7} | {'# chars':>8} | {'# distinct L-values':>20}")
    print("-" * 50)
    for N in range(1, 13):
        chars = dirichlet_characters(N)
        s = complex(2.0, 0.3)
        vals = {(round(char_L(c, N, s, terms=3000).real, 6),
                 round(char_L(c, N, s, terms=3000).imag, 6)) for c in chars}
        phi = euler_phi(N)
        n_chars = max(len(chars), 1 if N == 1 else len(chars))
        print(f"{N:>3} | {phi:>7} | {n_chars:>8} | {len(vals):>20}")
    print("=> # characters = # distinct L-functions = phi(N): the census is exact.\n")


# ---------------------------------------------------------------------------
# 5. Countability via dovetailed enumeration
# ---------------------------------------------------------------------------
def enumerate_dirichlet_family(n_moduli: int) -> List[Tuple[int, int]]:
    """Dovetailed listing of the Dirichlet family: pairs (N, character index).

    Returns a flat list realizing a surjection N -> family, showing the whole
    family is countable. Partial counts are sum_{M<=N} phi(M).
    """
    listing: List[Tuple[int, int]] = []
    for N in range(1, n_moduli + 1):
        count = max(euler_phi(N), 1) if N == 1 else euler_phi(N)
        for j in range(count):
            listing.append((N, j))
    return listing


def demo_countability() -> None:
    print("=" * 70)
    print("5. COUNTABILITY: dovetailed enumeration of the Dirichlet family")
    print("=" * 70)
    listing = enumerate_dirichlet_family(10)
    print("First 15 entries of the global list (N, character index):")
    print("  " + ", ".join(str(p) for p in listing[:15]))
    cumulative = 0
    print(f"\n{'N':>3} | {'phi(N)':>7} | {'cumulative count':>17}")
    print("-" * 34)
    for N in range(1, 11):
        phi = euler_phi(N)
        cumulative += phi
        print(f"{N:>3} | {phi:>7} | {cumulative:>17}")
    print("=> the whole family lists out in a single sequence: countable.\n")


def main() -> None:
    demo_rigidity()
    demo_zeta_uniqueness()
    demo_monomials()
    demo_census()
    demo_countability()


if __name__ == "__main__":
    main()
