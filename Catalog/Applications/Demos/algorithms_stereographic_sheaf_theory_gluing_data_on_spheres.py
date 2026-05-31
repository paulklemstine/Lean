#!/usr/bin/env python3
"""
Stereographic Sheaf Theory: Core Algorithms

Type-hinted implementations of the key algorithms from the
stereographic sheaf cohomology framework.
"""

from typing import List, Tuple, Set, Callable, Optional
from dataclasses import dataclass
import numpy as np


@dataclass
class SGDatum:
    """A stereographic gluing datum: an involutive group endomorphism."""
    phi: Callable[[int], int]
    modulus: int  # working in Z/nZ

    def apply(self, x: int) -> int:
        return self.phi(x) % self.modulus

    def is_involutive(self) -> bool:
        return all(
            self.apply(self.apply(x)) == x % self.modulus
            for x in range(self.modulus)
        )


@dataclass
class CechCohomology:
    """Result of a Čech cohomology computation."""
    h0: List[int]          # Elements of H⁰ (fixed points)
    h1_generators: List[int]  # Representatives of H¹
    ker_norm: List[int]    # Kernel of norm map
    im_diff: Set[int]      # Image of difference map


def compute_cech_cohomology(datum: SGDatum) -> CechCohomology:
    """
    Compute Čech cohomology H⁰ and H¹ for a two-chart cover.

    Algorithm:
    1. H⁰ = {g ∈ G : φ(g) = g}  (fixed points)
    2. ker(N) = {g ∈ G : g + φ(g) = 0}  (kernel of norm)
    3. im(D) = {g - φ(g) : g ∈ G}  (image of difference)
    4. H¹ = ker(N) / im(D)

    Complexity: O(|G|) for finite groups
    """
    n = datum.modulus
    elements = list(range(n))

    # H⁰: fixed points
    h0 = [g for g in elements if datum.apply(g) == g % n]

    # Norm map: N(g) = g + φ(g)
    ker_norm = [g for g in elements if (g + datum.apply(g)) % n == 0]

    # Difference map: D(g) = g - φ(g)
    im_diff = set((g - datum.apply(g)) % n for g in elements)

    # H¹ representatives: elements of ker(N) not in im(D)
    h1_gens = [g for g in ker_norm if g not in im_diff]

    return CechCohomology(
        h0=h0,
        h1_generators=h1_gens,
        ker_norm=ker_norm,
        im_diff=im_diff
    )


def eigenspace_decomposition(
    g: float,
    phi: Callable[[float], float]
) -> Tuple[float, float]:
    """
    Decompose g into ±1 eigenspace components under involution phi.

    Returns (s, a) where:
    - s = (g + φ(g))/2  (symmetric, +1 eigenspace)
    - a = (g - φ(g))/2  (antisymmetric, -1 eigenspace)
    - g = s + a
    - φ(s) = s, φ(a) = -a

    Requires: phi is an involution (phi ∘ phi = id)
    """
    phi_g = phi(g)
    s = (g + phi_g) / 2
    a = (g - phi_g) / 2
    return s, a


def stereo_projection(t: float) -> Tuple[float, float]:
    """
    Stereographic projection R → S¹.

    Maps t to (2t/(1+t²), (1-t²)/(1+t²)) on the unit circle.
    """
    d = 1 + t**2
    return (2*t / d, (1 - t**2) / d)


def stereo_inverse(x: float, y: float) -> Optional[float]:
    """
    Inverse stereographic projection S¹ → R.

    Given (x, y) on S¹ with y ≠ -1, returns t such that stereo(t) = (x, y).
    """
    if abs(1 + y) < 1e-15:
        return None  # South pole, not in chart
    return x / (1 + y)


def conformal_factor(t: float) -> float:
    """The conformal factor λ(t) = 2/(1+t²)."""
    return 2.0 / (1 + t**2)


def tate_norm(
    datum: SGDatum,
    g: int
) -> int:
    """Tate norm map: N(g) = g + φ(g) mod n."""
    return (g + datum.apply(g)) % datum.modulus


def tate_difference(
    datum: SGDatum,
    g: int
) -> int:
    """Tate difference map: D(g) = g - φ(g) mod n."""
    return (g - datum.apply(g)) % datum.modulus


def iterated_norm(
    datum: SGDatum,
    g: int,
    iterations: int
) -> int:
    """Apply the Tate norm map n times."""
    result = g
    for _ in range(iterations):
        result = tate_norm(datum, result)
    return result


def descent_sections(
    datum_gluing: SGDatum,
    datum_antipodal: SGDatum
) -> List[int]:
    """
    Compute descended sections: elements fixed by both involutions.

    These are sections of the descended sheaf on the quotient space.
    """
    n = datum_gluing.modulus
    assert n == datum_antipodal.modulus
    return [
        g for g in range(n)
        if datum_gluing.apply(g) == g % n
        and datum_antipodal.apply(g) == g % n
    ]


def verify_tate_complex(datum: SGDatum) -> bool:
    """
    Verify the Tate complex property: N∘D = 0 and D∘N = 0.

    Returns True if the complex property holds for all elements.
    """
    n = datum.modulus
    for g in range(n):
        d_g = tate_difference(datum, g)
        n_d_g = tate_norm(datum, d_g)
        if n_d_g != 0:
            return False

        n_g = tate_norm(datum, g)
        d_n_g = tate_difference(datum, n_g)
        if d_n_g != 0:
            return False
    return True


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("Stereographic Sheaf Algorithms - Demo")
    print("=" * 50)

    # Negation datum on Z/pZ for various primes
    for p in [2, 3, 5, 7, 11, 13]:
        datum = SGDatum(phi=lambda x, p=p: (-x) % p, modulus=p)
        assert datum.is_involutive(), f"Not involutive for p={p}"

        cohom = compute_cech_cohomology(datum)
        complex_ok = verify_tate_complex(datum)

        print(f"\np={p}: negation datum")
        print(f"  H⁰ = {cohom.h0} (size {len(cohom.h0)})")
        print(f"  ker(N) = {cohom.ker_norm}")
        print(f"  im(D) = {sorted(cohom.im_diff)}")
        print(f"  H¹ generators = {cohom.h1_generators}")
        print(f"  Tate complex verified: {complex_ok}")

    # Eigenspace decomposition examples
    print("\n\nEigenspace Decomposition (φ = negation):")
    print("-" * 40)
    for g in [1.0, 2.5, -3.7, 0.0, np.pi]:
        s, a = eigenspace_decomposition(g, lambda x: -x)
        print(f"  g={g:8.4f} → s={s:8.4f}, a={a:8.4f} "
              f"(check: s+a={s+a:8.4f})")
