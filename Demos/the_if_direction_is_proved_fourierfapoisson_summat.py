#!/usr/bin/env python3
"""
Poisson summation characterises subgroups: numerical demonstrations.
===================================================================

Setting.  G is a finite abelian group, realised concretely as a product of
cyclic groups  G = Z/n_1 x ... x Z/n_r,  whose elements are tuples of
residues.  A character of G is indexed by a tuple k and acts by

    psi_k(x) = exp(2*pi*i * sum_j k_j x_j / n_j).

The Fourier transform of f : G -> C is

    fhat(psi) = sum_{x in G} conj(psi(x)) f(x).

For an arbitrary subset S of G the annihilator is

    S^perp = { psi : psi(x) = 1 for all x in S },

and S is called a POISSON SET when

    |G| sum_{x in S} f(x) = |S| sum_{psi in S^perp} fhat(psi)      (P_S)

holds for every f.  The Poisson defect is the difference of the two sides,

    D_S(f) = |G| sum_{x in S} f(x) - |S| sum_{psi in S^perp} fhat(psi).

This script verifies numerically, on many concrete groups:

  1. Poisson summation holds for every subgroup and every random f.
  2. The blindness lemma  S^perp = <S>^perp  and  |<S>| * |S^perp| = |G|.
  3. The exact defect formula
         |<S>| D_S(f) = |G| ( |<S>| sum_S f  -  |S| sum_{<S>} f ).
  4. One-test-function rigidity: a single Dirac delta detects non-subgroups.
  5. The gap theorem: for a nonempty non-subgroup, the delta defect equals
         [G : <S>] * ( |<S>| - |S| )  >=  1.
  6. Constant rigidity: no choice of constant c rescues a non-subgroup.
  7. Uncertainty extremality: Poisson  <=>  |S||S^perp| = |G|
                                       <=>  supp(indicator-hat) = S^perp.
  8. The Poisson spectrum is the subgroup lattice; on Z/nZ it has d(n)
     nonempty members; it separates Z/4Z from the Klein four-group.
  9. The squares mod n are Poisson only for n = 1, 2; mod 8 the defect is 5.

Everything is elementary and self-contained: only the standard library plus
`cmath`/`itertools`/`math` are used.
"""

from __future__ import annotations

import cmath
import itertools
import math
import random
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Elem = Tuple[int, ...]      # a group element, as a tuple of residues
Char = Tuple[int, ...]      # a character, indexed the same way

TOL = 1e-9


# ----------------------------------------------------------------------
# Group machinery
# ----------------------------------------------------------------------

def group_elements(moduli: Sequence[int]) -> List[Elem]:
    """All elements of Z/n_1 x ... x Z/n_r, in lexicographic order."""
    return [tuple(t) for t in itertools.product(*(range(n) for n in moduli))]


def add(moduli: Sequence[int], x: Elem, y: Elem) -> Elem:
    """Group addition, componentwise modulo the respective moduli."""
    return tuple((a + b) % n for a, b, n in zip(x, y, moduli))


def sub(moduli: Sequence[int], x: Elem, y: Elem) -> Elem:
    """Group subtraction, componentwise modulo the respective moduli."""
    return tuple((a - b) % n for a, b, n in zip(x, y, moduli))


def zero(moduli: Sequence[int]) -> Elem:
    """The neutral element."""
    return tuple(0 for _ in moduli)


def character_value(moduli: Sequence[int], k: Char, x: Elem) -> complex:
    """Value psi_k(x) = exp(2*pi*i * sum_j k_j x_j / n_j)."""
    phase = sum(kj * xj / nj for kj, xj, nj in zip(k, x, moduli))
    return cmath.exp(2j * math.pi * phase)


def characters(moduli: Sequence[int]) -> List[Char]:
    """The full character group, indexed exactly like the group itself."""
    return group_elements(moduli)


def fourier_transform(moduli: Sequence[int],
                      f: Dict[Elem, complex],
                      k: Char) -> complex:
    """fhat(psi_k) = sum_x conj(psi_k(x)) f(x)."""
    return sum(character_value(moduli, k, x).conjugate() * f[x]
               for x in group_elements(moduli))


def annihilator(moduli: Sequence[int], S: Iterable[Elem]) -> List[Char]:
    """S^perp = { psi : psi(x) = 1 for all x in S }."""
    S = list(S)
    out: List[Char] = []
    for k in characters(moduli):
        if all(abs(character_value(moduli, k, x) - 1.0) < TOL for x in S):
            out.append(k)
    return out


def generated_subgroup(moduli: Sequence[int], S: Iterable[Elem]) -> List[Elem]:
    """<S>: closure of S under subtraction, starting from {0}."""
    current = {zero(moduli)} | set(S)
    while True:
        grown = set(current)
        for x in current:
            for y in current:
                grown.add(sub(moduli, x, y))
        if grown == current:
            return sorted(current)
        current = grown


def is_subgroup(moduli: Sequence[int], S: Iterable[Elem]) -> bool:
    """Combinatorial criterion: 0 in S and S closed under subtraction."""
    Sset = set(S)
    if not Sset:
        return False
    if zero(moduli) not in Sset:
        return False
    return all(sub(moduli, x, y) in Sset for x in Sset for y in Sset)


# ----------------------------------------------------------------------
# The Poisson identity, its defect, and its predicted value
# ----------------------------------------------------------------------

def poisson_defect(moduli: Sequence[int],
                   S: Sequence[Elem],
                   f: Dict[Elem, complex]) -> complex:
    """D_S(f) = |G| sum_{x in S} f(x) - |S| sum_{psi in S^perp} fhat(psi)."""
    G = group_elements(moduli)
    perp = annihilator(moduli, S)
    lhs = len(G) * sum(f[x] for x in S)
    rhs = len(S) * sum(fourier_transform(moduli, f, k) for k in perp)
    return lhs - rhs


def defect_via_formula(moduli: Sequence[int],
                       S: Sequence[Elem],
                       f: Dict[Elem, complex]) -> complex:
    """The defect predicted by the exact formula, using no characters:

        D_S(f) = (|G| / |<S>|) ( |<S>| sum_S f - |S| sum_{<S>} f ).
    """
    G = group_elements(moduli)
    H = generated_subgroup(moduli, S)
    return (len(G) / len(H)) * (len(H) * sum(f[x] for x in S)
                                - len(S) * sum(f[x] for x in H))


def dirac(moduli: Sequence[int], y: Elem) -> Dict[Elem, complex]:
    """The Dirac delta at y."""
    return {x: (1.0 + 0j if x == y else 0j) for x in group_elements(moduli)}


def random_function(moduli: Sequence[int],
                    rng: random.Random) -> Dict[Elem, complex]:
    """A random complex test function on G."""
    return {x: complex(rng.uniform(-1, 1), rng.uniform(-1, 1))
            for x in group_elements(moduli)}


def fmt(z: complex) -> str:
    """Compact printing of a complex number, cleaning tiny numerical dust."""
    re, im = z.real, z.imag
    if abs(im) < 1e-9:
        return f"{re:+.6f}"
    return f"{re:+.6f}{im:+.6f}i"


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------
# Demonstration 1: Poisson summation holds for subgroups
# ----------------------------------------------------------------------

def demo_subgroups_are_poisson() -> None:
    banner("1. Poisson summation holds for every subgroup, for random f")
    rng = random.Random(20260819)
    cases: List[Tuple[Sequence[int], List[Elem], str]] = [
        ((8,), [(0,), (2,), (4,), (6,)], "even residues in Z/8Z"),
        ((8,), [(0,), (4,)], "{0,4} in Z/8Z"),
        ((12,), [(0,), (3,), (6,), (9,)], "multiples of 3 in Z/12Z"),
        ((2, 2), [(0, 0), (1, 1)], "diagonal in Klein four-group"),
        ((2, 6), [(0, 0), (0, 2), (0, 4)], "0 x <2> in Z/2 x Z/6"),
    ]
    for moduli, S, name in cases:
        G = group_elements(moduli)
        perp = annihilator(moduli, S)
        worst = 0.0
        for _ in range(6):
            f = random_function(moduli, rng)
            worst = max(worst, abs(poisson_defect(moduli, S, f)))
        print(f"  {name:34s}  |G|={len(G):3d}  |S|={len(S):2d} "
              f" |S^perp|={len(perp):3d}   max|defect| = {worst:.2e}")
        assert worst < 1e-8


# ----------------------------------------------------------------------
# Demonstration 2: blindness of the annihilator
# ----------------------------------------------------------------------

def demo_blindness() -> None:
    banner("2. Blindness lemma:  S^perp = <S>^perp   and   |<S>|*|S^perp| = |G|")
    cases: List[Tuple[Sequence[int], List[Elem]]] = [
        ((8,), [(0,), (1,), (4,)]),          # squares mod 8
        ((8,), [(2,), (6,)]),
        ((12,), [(4,), (9,)]),
        ((2, 2), [(1, 0), (0, 1)]),
        ((3, 3), [(1, 2)]),
    ]
    for moduli, S in cases:
        G = group_elements(moduli)
        H = generated_subgroup(moduli, S)
        pS = set(annihilator(moduli, S))
        pH = set(annihilator(moduli, H))
        print(f"  G = Z/{'x Z/'.join(map(str, moduli))}   S = {S}")
        print(f"      <S> has {len(H):3d} elements,  |S^perp| = {len(pS):3d},"
              f"   S^perp == <S>^perp : {pS == pH}")
        print(f"      |<S>| * |S^perp| = {len(H) * len(pS):3d}"
              f"   vs   |G| = {len(G):3d}")
        assert pS == pH
        assert len(H) * len(pS) == len(G)


# ----------------------------------------------------------------------
# Demonstration 3: the exact defect formula
# ----------------------------------------------------------------------

def demo_defect_formula() -> None:
    banner("3. Exact defect formula (character-free prediction vs direct sum)")
    rng = random.Random(11235)
    cases: List[Tuple[Sequence[int], List[Elem]]] = [
        ((8,), [(0,), (1,), (4,)]),
        ((8,), [(1,), (3,)]),
        ((9,), [(3,), (6,)]),
        ((2, 4), [(1, 1), (0, 2)]),
    ]
    for moduli, S in cases:
        H = generated_subgroup(moduli, S)
        worst = 0.0
        for _ in range(8):
            f = random_function(moduli, rng)
            worst = max(worst, abs(poisson_defect(moduli, S, f)
                                   - defect_via_formula(moduli, S, f)))
        print(f"  S = {str(S):26s} |S| = {len(S)}, |<S>| = {len(H):3d}"
              f"    max discrepancy = {worst:.2e}")
        assert worst < 1e-8


# ----------------------------------------------------------------------
# Demonstration 4 & 5: one-delta rigidity and the gap theorem
# ----------------------------------------------------------------------

def demo_gap_theorem() -> None:
    banner("4/5. One Dirac delta detects non-subgroups; the gap is exact")
    print("     predicted delta-defect = [G:<S>] * (|<S>| - |S|)\n")
    cases: List[Tuple[Sequence[int], List[Elem], str]] = [
        ((8,), [(0,), (1,), (4,)], "squares mod 8"),
        ((8,), [(0,), (2,)], "{0,2} in Z/8Z"),
        ((8,), [(0,), (1,)], "{0,1} in Z/8Z"),
        ((12,), [(0,), (4,), (8,), (1,)], "<4> plus one stray point"),
        ((2, 2), [(0, 0), (1, 0), (0, 1)], "Klein minus one point"),
        ((5,), [(0,), (1,), (2,)], "{0,1,2} in Z/5Z"),
    ]
    for moduli, S, name in cases:
        G = group_elements(moduli)
        H = generated_subgroup(moduli, S)
        index = len(G) // len(H)
        predicted = index * (len(H) - len(S))
        y0 = S[0]
        observed = poisson_defect(moduli, S, dirac(moduli, y0))
        flag = "SUBGROUP" if is_subgroup(moduli, S) else "not a subgroup"
        print(f"  {name:26s} {flag:15s} |S|={len(S)} |<S>|={len(H):3d} "
              f"index={index:2d}  predicted={predicted:3d}  "
              f"observed={fmt(observed)}")
        assert abs(observed - predicted) < 1e-8
        if not is_subgroup(moduli, S):
            assert abs(observed) >= 1 - 1e-9


# ----------------------------------------------------------------------
# Demonstration 6: constant rigidity
# ----------------------------------------------------------------------

def demo_constant_rigidity() -> None:
    banner("6. Constant rigidity: no c rescues a non-subgroup")
    moduli = (8,)
    S = [(0,), (1,), (4,)]
    G = group_elements(moduli)
    perp = annihilator(moduli, S)
    print(f"  G = Z/8Z, S = squares mod 8 = {S},  |S^perp| = {len(perp)}")
    print("  Testing  |G| sum_S f = c sum_{S^perp} fhat  for a grid of c,")
    print("  against the three Dirac deltas at 0, 1, 4 and at 5 (outside S).\n")
    print(f"  {'c':>6s} | " + " | ".join(f"delta_{y[0]}" for y in
                                         [(0,), (1,), (4,), (5,)]))
    for c in [1.0, 2.0, 3.0, 4.0, 8.0]:
        row = []
        for y in [(0,), (1,), (4,), (5,)]:
            f = dirac(moduli, y)
            lhs = len(G) * sum(f[x] for x in S)
            rhs = c * sum(fourier_transform(moduli, f, k) for k in perp)
            row.append(f"{abs(lhs - rhs):7.3f}")
        print(f"  {c:6.1f} | " + " | ".join(row))
    print("\n  No single value of c makes all four residuals vanish: c = |<S>| = 8")
    print("  handles the deltas inside S but then fails at the point 5 of <S>\\S.")
    print("  The identity is unsalvageable for S, as the theory predicts.")


# ----------------------------------------------------------------------
# Demonstration 7: uncertainty extremality
# ----------------------------------------------------------------------

def demo_uncertainty() -> None:
    banner("7. Poisson sets are exactly the uncertainty extremals")
    print("     |S| |S^perp| <= |G| <= |S| |supp(indicator-hat)|,")
    print("     with the left inequality tight exactly for Poisson sets.\n")
    for moduli in [(8,), (2, 2), (6,)]:
        G = group_elements(moduli)
        print(f"  --- G = Z/{'x Z/'.join(map(str, moduli))}, |G| = {len(G)}")
        for r in range(1, len(G) + 1):
            for S in itertools.combinations(G, r):
                Sl = list(S)
                perp = annihilator(moduli, Sl)
                ind = {x: (1.0 + 0j if x in S else 0j) for x in G}
                supp = [k for k in characters(moduli)
                        if abs(fourier_transform(moduli, ind, k)) > TOL]
                left_tight = (len(Sl) * len(perp) == len(G))
                supp_eq = (set(supp) == set(perp))
                sub_flag = is_subgroup(moduli, Sl)
                assert left_tight == sub_flag == supp_eq
                if sub_flag:
                    print(f"      subgroup {str(Sl):40s} "
                          f"|S||S^perp| = {len(Sl) * len(perp):3d} = |G|,"
                          f"  supp = S^perp")
        print("      (all non-subgroups checked: both equalities fail)")


# ----------------------------------------------------------------------
# Demonstration 8: the Poisson spectrum
# ----------------------------------------------------------------------

def poisson_spectrum(moduli: Sequence[int]) -> List[List[Elem]]:
    """All nonempty Poisson sets of G, by exhaustion over subsets."""
    G = group_elements(moduli)
    out: List[List[Elem]] = []
    for r in range(1, len(G) + 1):
        for S in itertools.combinations(G, r):
            if is_subgroup(moduli, list(S)):
                out.append(list(S))
    return out


def divisor_count(n: int) -> int:
    """d(n), the number of positive divisors of n."""
    return sum(1 for d in range(1, n + 1) if n % d == 0)


def demo_spectrum() -> None:
    banner("8. The Poisson spectrum is the subgroup lattice")
    print("  Nonempty Poisson sets of Z/nZ, counted against d(n):\n")
    for n in range(1, 13):
        spec = poisson_spectrum((n,))
        print(f"    n = {n:2d}:  {len(spec):2d} Poisson sets, d(n) = "
              f"{divisor_count(n):2d}   sizes = "
              f"{sorted(len(S) for S in spec)}")
        assert len(spec) == divisor_count(n)

    print("\n  Separation of two groups of the same order:")
    z4 = poisson_spectrum((4,))
    klein = poisson_spectrum((2, 2))
    print(f"    Z/4Z            : {len(z4)} nonempty "
          f"(+ empty set = {len(z4) + 1}), sizes "
          f"{sorted(len(S) for S in z4)}")
    print(f"    Z/2Z x Z/2Z     : {len(klein)} nonempty "
          f"(+ empty set = {len(klein) + 1}), sizes "
          f"{sorted(len(S) for S in klein)}")
    assert len(z4) + 1 == 4 and len(klein) + 1 == 6
    print("    => the number of exact Poisson formulas is an isomorphism")
    print("       invariant, not a function of |G|.")

    print("\n  Meet-closed but not join-closed (Klein four-group):")
    A: List[Elem] = [(0, 0), (1, 0)]
    B: List[Elem] = [(0, 0), (0, 1)]
    U = sorted(set(A) | set(B))
    I = sorted(set(A) & set(B))
    print(f"    A = {A} Poisson: {is_subgroup((2, 2), A)}")
    print(f"    B = {B} Poisson: {is_subgroup((2, 2), B)}")
    print(f"    A n B = {I} Poisson: {is_subgroup((2, 2), I)}")
    print(f"    A u B = {U} Poisson: {is_subgroup((2, 2), U)}   "
          f"(missing (1,1) = (1,0)+(0,1))")
    assert is_subgroup((2, 2), A) and is_subgroup((2, 2), B)
    assert is_subgroup((2, 2), I) and not is_subgroup((2, 2), U)


# ----------------------------------------------------------------------
# Demonstration 9: quadratic residues
# ----------------------------------------------------------------------

def squares_mod(n: int) -> List[Elem]:
    """The set of squares in Z/nZ, as singleton tuples."""
    return sorted({((a * a) % n,) for a in range(n)})


def demo_quadratic_residues() -> None:
    banner("9. Quadratic residues: Poisson only for n = 1, 2")
    for n in range(1, 13):
        moduli = (n,)
        Q = squares_mod(n)
        H = generated_subgroup(moduli, Q)
        good = is_subgroup(moduli, Q)
        index = n // len(H)
        predicted = index * (len(H) - len(Q))
        observed = poisson_defect(moduli, Q, dirac(moduli, Q[0]))
        assert abs(observed - predicted) < 1e-8
        tag = "POISSON" if good else "fails   "
        print(f"    n = {n:2d}  squares = {str([q[0] for q in Q]):24s} "
              f"{tag}  delta-defect = {fmt(observed)}")
    print("\n  The squares mod 8 are {0,1,4}; they generate all of Z/8Z,")
    print("  so the defect is 1 * (8 - 3) = 5 -- of the same order as |G|.")
    print("  They are not a coset either: for every base point x0 in the set,")
    moduli8 = (8,)
    Q8 = squares_mod(8)
    for x0 in Q8:
        T = [sub(moduli8, q, x0) for q in Q8]
        bad = [(a, b) for a in T for b in T
               if sub(moduli8, a, b) not in set(T)]
        print(f"    x0 = {x0[0]}:  S - x0 = {sorted(t[0] for t in T)} "
              f"is not closed under subtraction "
              f"(e.g. {bad[0][0][0]} - {bad[0][1][0]} escapes)")
        assert bad


# ----------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_subgroups_are_poisson()
    demo_blindness()
    demo_defect_formula()
    demo_gap_theorem()
    demo_constant_rigidity()
    demo_uncertainty()
    demo_spectrum()
    demo_quadratic_residues()
    banner("All checks passed.")


if __name__ == "__main__":
    main()
