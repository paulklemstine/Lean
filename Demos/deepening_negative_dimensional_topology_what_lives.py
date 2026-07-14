"""
Numerical demonstrations for "The Euler Characteristic in Negative Dimensions".

This self-contained module implements the arithmetic theory of
negative-dimensional formal spaces and verifies, on concrete examples, every
structural theorem from the accompanying paper:

    * the dimensional sign  sgn(d) = (-1)^d  for all integers d;
    * the Euler characteristic  chi(X) = sgn(dim X) * |pi_0(X)|;
    * the headline formula      dim X = -n  =>  chi(X) = (-1)^n * |pi_0(X)|;
    * additivity under disjoint union and multiplicativity under products;
    * the suspension calculus  chi(Sigma^n X) = (-1)^n chi(X);
    * stabilization of a (-n)-dimensional space to dimension 0;
    * the graded Euler characteristic and the genus formula chi = 2 - 2g.

Run with:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List, Tuple


# --------------------------------------------------------------------------
# The dimensional sign
# --------------------------------------------------------------------------

def sgn(d: int) -> int:
    """The dimensional sign sgn(d) = (-1)^d, valid for every integer d."""
    return 1 if d % 2 == 0 else -1


def sgn_is_homomorphism(a: int, b: int) -> bool:
    """Verify sgn(a + b) = sgn(a) * sgn(b)."""
    return sgn(a + b) == sgn(a) * sgn(b)


def sgn_is_parity_invariant(d: int) -> bool:
    """Verify sgn(-d) = sgn(d)."""
    return sgn(-d) == sgn(d)


# --------------------------------------------------------------------------
# Formal spaces and the Euler characteristic
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class FormalSpace:
    """A formal space: an integer dimension and a count of path components."""
    dim: int
    comp: int  # |pi_0(X)| >= 0


def chi(X: FormalSpace) -> int:
    """The Euler characteristic chi(X) = sgn(dim X) * |pi_0(X)|."""
    return sgn(X.dim) * X.comp


PT: FormalSpace = FormalSpace(dim=0, comp=1)  # the one-point space, chi = 1


def chi_neg_dim_formula(n: int, comp: int) -> int:
    """Right-hand side of the headline theorem: (-1)^n * comp for dim = -n."""
    return (-1) ** n * comp


def disjoint_union(X: FormalSpace, Y: FormalSpace) -> FormalSpace:
    """Disjoint union of equidimensional spaces: component counts add."""
    if X.dim != Y.dim:
        raise ValueError("disjoint union requires equal dimensions")
    return FormalSpace(dim=X.dim, comp=X.comp + Y.comp)


def product(X: FormalSpace, Y: FormalSpace) -> FormalSpace:
    """Product of formal spaces: dimensions add, component counts multiply."""
    return FormalSpace(dim=X.dim + Y.dim, comp=X.comp * Y.comp)


def suspension(X: FormalSpace) -> FormalSpace:
    """Suspension: raises dimension by one, preserves components."""
    return FormalSpace(dim=X.dim + 1, comp=X.comp)


def suspension_iter(n: int, X: FormalSpace) -> FormalSpace:
    """n-fold suspension: raises dimension by n."""
    return FormalSpace(dim=X.dim + n, comp=X.comp)


def stabilize(X: FormalSpace) -> Tuple[FormalSpace, int]:
    """
    Stabilize a space of dimension -n (n >= 0) up to dimension 0.

    Returns the stabilized space (of dimension 0) together with n, the number
    of suspensions applied. At dimension 0 the Euler characteristic reads off
    the number of path components.
    """
    if X.dim > 0:
        raise ValueError("stabilization defined for non-positive dimension")
    n = -X.dim
    return suspension_iter(n, X), n


# --------------------------------------------------------------------------
# The graded Euler characteristic
# --------------------------------------------------------------------------

def chi_graded(betti: Dict[int, int]) -> int:
    """Graded Euler characteristic sum_i (-1)^i b_i over the support of betti."""
    return sum(sgn(i) * b for i, b in betti.items())


def surface_betti(g: int) -> Dict[int, int]:
    """Betti numbers of the closed orientable genus-g surface."""
    return {0: 1, 1: 2 * g, 2: 1}


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_dimensional_sign() -> None:
    print("=" * 70)
    print("1. The dimensional sign sgn(d) = (-1)^d, all integers")
    print("=" * 70)
    for d in range(-4, 5):
        print(f"   sgn({d:>2}) = {sgn(d):>2}")
    assert all(sgn_is_homomorphism(a, b)
               for a in range(-6, 7) for b in range(-6, 7))
    assert all(sgn_is_parity_invariant(d) for d in range(-10, 11))
    print("   verified: sgn(a+b) = sgn(a)*sgn(b)  and  sgn(-d) = sgn(d)")


def demo_negative_dimension() -> None:
    print("\n" + "=" * 70)
    print("2. Euler characteristic in negative dimensions")
    print("=" * 70)
    print("   dim=-n, comp=k :  chi = (-1)^n * k")
    for n in range(0, 6):
        for k in (1, 3):
            X = FormalSpace(dim=-n, comp=k)
            got, expected = chi(X), chi_neg_dim_formula(n, k)
            assert got == expected
            print(f"   dim=-{n}, comp={k}:  chi = {got:>3}   (expected {expected:>3})")


def demo_additivity_multiplicativity() -> None:
    print("\n" + "=" * 70)
    print("3. Additivity under disjoint union, multiplicativity under products")
    print("=" * 70)
    A = FormalSpace(dim=-1, comp=2)
    B = FormalSpace(dim=-1, comp=5)
    U = disjoint_union(A, B)
    assert chi(U) == chi(A) + chi(B)
    print(f"   chi(A u B) = {chi(U)} = chi(A) + chi(B) = {chi(A)} + {chi(B)}")

    C = FormalSpace(dim=-2, comp=3)
    P = product(A, C)
    assert chi(P) == chi(A) * chi(C)
    print(f"   chi(A x C) = {chi(P)} = chi(A) * chi(C) = {chi(A)} * {chi(C)}")
    print(f"   one-point space: chi(pt) = {chi(PT)}  (monoid unit)")


def demo_suspension_stabilization() -> None:
    print("\n" + "=" * 70)
    print("4. Suspension calculus and stabilization to dimension 0")
    print("=" * 70)
    X = FormalSpace(dim=-3, comp=4)
    assert chi(suspension(X)) == -chi(X)
    print(f"   chi(Sigma X) = {chi(suspension(X))} = -chi(X) = -({chi(X)})")
    for n in range(0, 5):
        assert chi(suspension_iter(n, X)) == (-1) ** n * chi(X)
    print("   verified: chi(Sigma^n X) = (-1)^n chi(X) for n = 0..4")

    stab, n = stabilize(X)
    assert stab.dim == 0 and chi(stab) == X.comp
    print(f"   stabilize X (dim=-{n}) -> dim {stab.dim}, "
          f"chi = {chi(stab)} = |pi_0| = {X.comp}")
    # Consistency: (-1)^n chi(X) = |pi_0|
    assert (-1) ** n * chi(X) == X.comp


def demo_genus_formula() -> None:
    print("\n" + "=" * 70)
    print("5. Graded Euler characteristic: the genus formula chi = 2 - 2g")
    print("=" * 70)
    for g in range(0, 5):
        val = chi_graded(surface_betti(g))
        assert val == 2 - 2 * g
        name = {0: "sphere", 1: "torus"}.get(g, f"genus-{g} surface")
        print(f"   g={g:>1} ({name:>16}):  chi = {val:>3}  = 2 - 2*{g}")


def main() -> None:
    demo_dimensional_sign()
    demo_negative_dimension()
    demo_additivity_multiplicativity()
    demo_suspension_stabilization()
    demo_genus_formula()
    print("\nAll demonstrations verified successfully.")


if __name__ == "__main__":
    main()
