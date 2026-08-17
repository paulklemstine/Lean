"""
Numerical demonstration: Fourier energy, additive energy, and the collapse of the
covering bound.
=====================================================================================

Setting.  Let G be a finite abelian group and A, B subsets of G.  The representation
function

    r_{A,B}(c) = #{(a,b) in A x B : a + b = c}

has total mass |A||B| and support exactly the sumset A + B.  Writing 1_A^(psi) =
sum_{a in A} conj(psi(a)) for the Fourier transform of the indicator of A, the
*nonprincipal Fourier energy* is

    E = sum_{psi != 0} |1_A^(psi)|^2 |1_B^(psi)|^2,

and the Fourier covering bound reads

    |A + B| >= |G| (|A||B|)^2 / ((|A||B|)^2 + E).                              (star)

The *additive energy* is the purely combinatorial quantity

    Etil(A,B) = sum_c r_{A,B}(c)^2 = #{(a,b,a',b') : a + b = a' + b'}.

This script verifies, numerically and exactly:

  1. The energy identity      E = |G| * Etil - (|A||B|)^2                   [Theorem A]
  2. The collapse             RHS of (star) = (|A||B|)^2 / Etil             [Theorem B]
  3. The dichotomy            bound > |A|  <=>  |A + A| > |A|               [Theorem C]
  4. Closed forms for four families:
         Sidon sets                  Etil = 2k^2 - k,     bound = k^3/(2k-1)
         exponent-two Sidon sets     Etil = 3k^2 - 2k,    bound = k^3/(3k-2)
         intervals in Z/n            Etil = k(2k^2+1)/3,  bound = 3k^3/(2k^2+1)
         subgroups                   Etil = h^3,          bound = h
     instantiated on the parabola {(x, x^2)} in (Z/p)^2, on the radius-one Hamming
     ball {0, e_1, ..., e_n} in F_2^n, and on intervals {0, ..., k-1} in Z/n.

Everything is self-contained: groups are represented as tuples of residues, characters
are built explicitly from roots of unity, and the Fourier energy is evaluated by brute
force so that the identity is genuinely checked rather than assumed.
"""

from __future__ import annotations

import cmath
import itertools
from fractions import Fraction
from typing import Dict, Iterable, List, Sequence, Tuple

Elem = Tuple[int, ...]  # element of a product of cyclic groups


# ----------------------------------------------------------------------------------
# Group plumbing: G = Z/m_1 x ... x Z/m_d, elements are tuples of residues.
# ----------------------------------------------------------------------------------


def group_elements(moduli: Sequence[int]) -> List[Elem]:
    """All elements of Z/m_1 x ... x Z/m_d, in lexicographic order."""
    return [tuple(t) for t in itertools.product(*(range(m) for m in moduli))]


def add(x: Elem, y: Elem, moduli: Sequence[int]) -> Elem:
    """Group addition, coordinatewise modulo the given moduli."""
    return tuple((a + b) % m for a, b, m in zip(x, y, moduli))


def sumset(A: Iterable[Elem], B: Iterable[Elem], moduli: Sequence[int]) -> List[Elem]:
    """The sumset A + B."""
    A, B = list(A), list(B)
    return sorted({add(a, b, moduli) for a in A for b in B})


def rep_function(
    A: Sequence[Elem], B: Sequence[Elem], moduli: Sequence[int]
) -> Dict[Elem, int]:
    """The representation function r_{A,B}, as a dictionary supported on A + B."""
    r: Dict[Elem, int] = {}
    for a in A:
        for b in B:
            c = add(a, b, moduli)
            r[c] = r.get(c, 0) + 1
    return r


def additive_energy(
    A: Sequence[Elem], B: Sequence[Elem], moduli: Sequence[int]
) -> int:
    """Etil(A,B) = sum_c r_{A,B}(c)^2, an exact integer."""
    return sum(v * v for v in rep_function(A, B, moduli).values())


def fourier_energy(
    A: Sequence[Elem], B: Sequence[Elem], moduli: Sequence[int]
) -> float:
    """
    The nonprincipal Fourier energy, computed from the definition.

    Characters of Z/m_1 x ... x Z/m_d are indexed by the same tuples: the character
    psi_t sends x to exp(2 pi i sum_j t_j x_j / m_j).  We sum |1_A^|^2 |1_B^|^2 over
    all nontrivial t.  Cost: O(|G| (|A| + |B|)).
    """
    total = 0.0
    for t in group_elements(moduli):
        if all(tj == 0 for tj in t):
            continue  # skip the principal character
        sa = sum(
            cmath.exp(-2j * cmath.pi * sum(tj * aj / mj for tj, aj, mj in zip(t, a, moduli)))
            for a in A
        )
        sb = sum(
            cmath.exp(-2j * cmath.pi * sum(tj * bj / mj for tj, bj, mj in zip(t, b, moduli)))
            for b in B
        )
        total += abs(sa) ** 2 * abs(sb) ** 2
    return total


def covering_bound_spectral(
    A: Sequence[Elem], B: Sequence[Elem], moduli: Sequence[int]
) -> float:
    """The right-hand side of (star), evaluated through the Fourier energy."""
    N = 1
    for m in moduli:
        N *= m
    mass = len(A) * len(B)
    return N * mass**2 / (mass**2 + fourier_energy(A, B, moduli))


def covering_bound_combinatorial(
    A: Sequence[Elem], B: Sequence[Elem], moduli: Sequence[int]
) -> Fraction:
    """The second-moment ratio (|A||B|)^2 / Etil(A,B), exactly."""
    return Fraction((len(A) * len(B)) ** 2, additive_energy(A, B, moduli))


# ----------------------------------------------------------------------------------
# The families.
# ----------------------------------------------------------------------------------


def parabola(p: int) -> Tuple[List[Elem], List[int]]:
    """The Sidon set {(x, x^2)} inside (Z/p)^2; returns the set and the moduli."""
    return [(x, (x * x) % p) for x in range(p)], [p, p]


def hamming_ball(n: int) -> Tuple[List[Elem], List[int]]:
    """The radius-one Hamming ball {0, e_1, ..., e_n} in F_2^n."""
    pts: List[Elem] = [tuple(0 for _ in range(n))]
    for i in range(n):
        pts.append(tuple(1 if j == i else 0 for j in range(n)))
    return pts, [2] * n


def interval(n: int, k: int) -> Tuple[List[Elem], List[int]]:
    """The interval {0, 1, ..., k-1} inside Z/n (assume 2k <= n: no wraparound)."""
    return [(i,) for i in range(k)], [n]


def subgroup_of_cyclic(n: int, d: int) -> Tuple[List[Elem], List[int]]:
    """The subgroup of Z/n of index d (order n/d), i.e. the multiples of d."""
    assert n % d == 0
    return [(i,) for i in range(0, n, d)], [n]


# ----------------------------------------------------------------------------------
# Reporting helpers.
# ----------------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 84)
    print(title)
    print("=" * 84)


def analyse(name: str, A: Sequence[Elem], moduli: Sequence[int]) -> None:
    """Full report for the pair (A, A): both energies, both bounds, the sumset."""
    N = 1
    for m in moduli:
        N *= m
    k = len(A)
    etil = additive_energy(A, A, moduli)
    e_spec = fourier_energy(A, A, moduli)
    e_pred = N * etil - (k * k) ** 2
    bound_spec = covering_bound_spectral(A, A, moduli)
    bound_comb = covering_bound_combinatorial(A, A, moduli)
    S = sumset(A, A, moduli)
    print(f"{name}")
    print(f"    |G| = {N},  |A| = {k},  |A + A| = {len(S)}")
    print(f"    additive energy  Etil     = {etil}")
    print(f"    Fourier energy   E (spec) = {e_spec:.6f}")
    print(f"    Fourier energy   |G|Etil - (|A||A|)^2 = {e_pred}")
    print(f"    identity error            = {abs(e_spec - e_pred):.3e}")
    print(f"    covering bound (spectral) = {bound_spec:.6f}")
    print(f"    covering bound (2nd mom.) = {float(bound_comb):.6f}  = {bound_comb}")
    print(f"    collapse error            = {abs(bound_spec - float(bound_comb)):.3e}")
    print(
        f"    pigeonhole {k}  <  bound {float(bound_comb):.4f}  <=  truth {len(S)}"
        f"   [{'gain' if float(bound_comb) > k else 'NO gain (coset)'}]"
    )
    assert abs(e_spec - e_pred) < 1e-6 * max(1.0, abs(e_pred)), "energy identity failed"
    assert abs(bound_spec - float(bound_comb)) < 1e-6 * max(1.0, bound_spec), "collapse failed"
    assert float(bound_comb) <= len(S) + 1e-9, "covering bound violated"


# ----------------------------------------------------------------------------------
# Demonstration 1: the energy identity and the collapse, on random-ish sets.
# ----------------------------------------------------------------------------------


def demo_identity() -> None:
    banner("1.  E = |G| * Etil - (|A||B|)^2, and the collapse of the covering bound")
    print(
        "Every line checks the spectral quantity E against the combinatorial prediction,\n"
        "and the spectral covering bound against the second-moment ratio."
    )
    cases: List[Tuple[str, List[Elem], List[Elem], List[int]]] = [
        ("Z/12: A = {0,1,4,9}, B = {0,2,5}", [(0,), (1,), (4,), (9,)], [(0,), (2,), (5,)], [12]),
        ("Z/16: A = B = {0,1,3,7}", [(0,), (1,), (3,), (7,)], [(0,), (1,), (3,), (7,)], [16]),
        (
            "Z/3 x Z/3: A = B = {(0,0),(1,0),(0,1)}",
            [(0, 0), (1, 0), (0, 1)],
            [(0, 0), (1, 0), (0, 1)],
            [3, 3],
        ),
        (
            "F_2^4: A = B = ball of radius 1",
            hamming_ball(4)[0],
            hamming_ball(4)[0],
            [2] * 4,
        ),
    ]
    for name, A, B, moduli in cases:
        N = 1
        for m in moduli:
            N *= m
        etil = additive_energy(A, B, moduli)
        e_spec = fourier_energy(A, B, moduli)
        e_pred = N * etil - (len(A) * len(B)) ** 2
        bs = covering_bound_spectral(A, B, moduli)
        bc = covering_bound_combinatorial(A, B, moduli)
        print(f"\n  {name}")
        print(f"      Etil = {etil},  E(spectral) = {e_spec:.6f},  |G|Etil-(|A||B|)^2 = {e_pred}")
        print(f"      bound(spectral) = {bs:.8f}   bound(2nd moment) = {float(bc):.8f} = {bc}")
        print(f"      |A + B| = {len(sumset(A, B, moduli))}")
        assert abs(e_spec - e_pred) < 1e-6 * max(1.0, abs(e_pred))
        assert abs(bs - float(bc)) < 1e-6 * max(1.0, bs)
    print("\n  All identities verified to machine precision.")


# ----------------------------------------------------------------------------------
# Demonstration 2: the parabola in (Z/p)^2.
# ----------------------------------------------------------------------------------


def demo_parabola() -> None:
    banner("2.  Family I: the parabola P = {(x, x^2)} in (Z/p)^2  (a Sidon set)")
    print("  Predicted:  Etil = 2p^2 - p,  E = p^4 - p^3,  bound = p^3/(2p-1),")
    print("              |P + P| = p(p+1)/2,  pigeonhole = p.\n")
    print(f"  {'p':>3} {'Etil':>8} {'2p^2-p':>8} {'E':>14} {'p^4-p^3':>12}"
          f" {'bound':>10} {'p^3/(2p-1)':>12} {'|P+P|':>7} {'p(p+1)/2':>9}")
    for p in [3, 5, 7, 11]:
        A, moduli = parabola(p)
        etil = additive_energy(A, A, moduli)
        e = fourier_energy(A, A, moduli)
        b = float(covering_bound_combinatorial(A, A, moduli))
        S = sumset(A, A, moduli)
        print(
            f"  {p:>3} {etil:>8} {2*p*p-p:>8} {e:>14.2f} {p**4-p**3:>12}"
            f" {b:>10.4f} {p**3/(2*p-1):>12.4f} {len(S):>7} {p*(p+1)//2:>9}"
        )
        assert etil == 2 * p * p - p
        assert abs(e - (p**4 - p**3)) < 1e-6 * p**4
        assert len(S) == p * (p + 1) // 2
        assert b > p  # strictly beats pigeonhole
        assert len(S) <= (1 + 1 / (2 * p)) * b + 1e-9  # sharp to 1 + 1/(2p)
    print("\n  Gain over pigeonhole is a full power: p  ->  ~ p^2/2.")


# ----------------------------------------------------------------------------------
# Demonstration 3: the Hamming ball in F_2^n.
# ----------------------------------------------------------------------------------


def demo_hamming() -> None:
    banner("3.  Family II: the radius-one Hamming ball in F_2^n  (exponent two)")
    print("  Predicted:  Etil = 3n^2 + 4n + 1,  E = 2^n(3n^2+4n+1) - (n+1)^4,")
    print("              bound = (n+1)^3/(3n+1),  |B + B| = 1 + n(n+1)/2.\n")
    print(f"  {'n':>3} {'Etil':>8} {'3n^2+4n+1':>10} {'E':>16} {'predicted E':>16}"
          f" {'bound':>9} {'|B+B|':>7} {'truth/bound':>12}")
    for n in [2, 3, 4, 5, 6, 7, 8]:
        A, moduli = hamming_ball(n)
        etil = additive_energy(A, A, moduli)
        e = fourier_energy(A, A, moduli)
        e_pred = 2**n * (3 * n * n + 4 * n + 1) - (n + 1) ** 4
        b = float(covering_bound_combinatorial(A, A, moduli))
        S = sumset(A, A, moduli)
        print(
            f"  {n:>3} {etil:>8} {3*n*n+4*n+1:>10} {e:>16.2f} {e_pred:>16}"
            f" {b:>9.4f} {len(S):>7} {len(S)/b:>12.4f}"
        )
        assert etil == 3 * n * n + 4 * n + 1
        assert abs(e - e_pred) < 1e-6 * max(1.0, abs(e_pred))
        assert len(S) == 1 + n * (n + 1) // 2
        assert len(S) <= 1.5 * b + 1e-9
    print("\n  The ratio truth/bound climbs towards exactly 3/2: the price of the")
    print("  collapsed diagonal (x + x = 0 piles k^2 units of energy onto the origin).")


# ----------------------------------------------------------------------------------
# Demonstration 4: intervals -- minimal doubling.
# ----------------------------------------------------------------------------------


def demo_intervals() -> None:
    banner("4.  Family III: intervals I_k = {0,...,k-1} in Z/n  (minimal doubling)")
    print("  Predicted:  Etil = k(2k^2+1)/3,  bound = 3k^3/(2k^2+1),  |I_k+I_k| = 2k-1.")
    print("  Accuracy is pinned to the window [3/4, 1) for every k >= 2.\n")
    print(f"  {'k':>3} {'n':>4} {'Etil':>8} {'k(2k^2+1)/3':>12} {'E':>14}"
          f" {'bound':>9} {'2k-1':>6} {'bound/truth':>12}")
    for k in [2, 3, 4, 5, 6, 8, 10]:
        n = 2 * k + 1
        A, moduli = interval(n, k)
        etil = additive_energy(A, A, moduli)
        e = fourier_energy(A, A, moduli)
        b = float(covering_bound_combinatorial(A, A, moduli))
        S = sumset(A, A, moduli)
        closed = k * (2 * k * k + 1) // 3
        print(
            f"  {k:>3} {n:>4} {etil:>8} {closed:>12} {e:>14.2f}"
            f" {b:>9.4f} {2*k-1:>6} {b/len(S):>12.4f}"
        )
        assert 3 * etil == k * (2 * k * k + 1)
        assert abs(e - (n * etil - k**4)) < 1e-6 * max(1.0, n * etil)
        assert len(S) == 2 * k - 1
        assert k < b < len(S) or k == 1  # beats pigeonhole, never tight
        assert 0.75 - 1e-12 <= b / len(S) < 1.0
    print("\n  Even at minimal doubling -- where no power gain is possible at all --")
    print("  the bound strictly beats pigeonhole, converging to (3/2)k against 2k-1.")


# ----------------------------------------------------------------------------------
# Demonstration 5: the dichotomy, and subgroups as the equality case.
# ----------------------------------------------------------------------------------


def demo_dichotomy() -> None:
    banner("5.  The dichotomy: the bound beats pigeonhole iff |A + A| > |A|")
    print("  Exhaustive check over all nonempty subsets of Z/8 and of Z/3 x Z/3.\n")
    for moduli in ([8], [3, 3]):
        G = group_elements(moduli)
        checked = exceptions = 0
        witnesses: List[str] = []
        for size in range(1, len(G) + 1):
            for A in itertools.combinations(G, size):
                A = list(A)
                b = float(covering_bound_combinatorial(A, A, moduli))
                S = sumset(A, A, moduli)
                gain = b > len(A) + 1e-12
                doubling = len(S) > len(A)
                assert gain == doubling, (A, b, len(S))
                checked += 1
                if not gain:
                    exceptions += 1
                    if len(witnesses) < 6:
                        witnesses.append(
                            f"{sorted(A)}  |A|={len(A)}  |A+A|={len(S)}  bound={b:.3f}"
                        )
        print(f"  G = {'x'.join('Z/'+str(m) for m in moduli)}: "
              f"{checked} subsets checked, dichotomy holds in every case.")
        print(f"  {exceptions} sets with no gain (all cosets of subgroups); examples:")
        for w in witnesses:
            print(f"      {w}")
        print()
    print("  Subgroups: the equality case  Etil = h^3,  bound = h = |H + H|.")
    for n, d in [(12, 2), (12, 3), (12, 4), (16, 2)]:
        H, moduli = subgroup_of_cyclic(n, d)
        h = len(H)
        etil = additive_energy(H, H, moduli)
        e = fourier_energy(H, H, moduli)
        b = float(covering_bound_combinatorial(H, H, moduli))
        print(
            f"      H = {d}Z/{n}Z:  h = {h},  Etil = {etil} = h^3 = {h**3},"
            f"  E = {e:.2f} = |G|h^3 - h^4 = {n*h**3 - h**4},  bound = {b:.4f} = h"
        )
        assert etil == h**3
        assert abs(e - (n * h**3 - h**4)) < 1e-6 * max(1.0, n * h**3)
        assert abs(b - h) < 1e-12


# ----------------------------------------------------------------------------------
# Demonstration 6: the accuracy hierarchy across the doubling spectrum.
# ----------------------------------------------------------------------------------


def demo_accuracy() -> None:
    banner("6.  Accuracy of the bound across the doubling spectrum")
    print(f"  {'family':<34}{'|A|':>5}{'sigma=|A+A|/|A|':>18}{'bound/truth':>14}")
    rows: List[Tuple[str, List[Elem], List[int]]] = []
    for p in [5, 7, 11]:
        A, m = parabola(p)
        rows.append((f"parabola in (Z/{p})^2 (Sidon)", A, m))
    for n in [4, 6, 8]:
        A, m = hamming_ball(n)
        rows.append((f"Hamming ball in F_2^{n}", A, m))
    for k in [4, 8, 16]:
        A, m = interval(2 * k + 1, k)
        rows.append((f"interval I_{k} in Z/{2*k+1}", A, m))
    for (n, d) in [(12, 2), (16, 4)]:
        H, m = subgroup_of_cyclic(n, d)
        rows.append((f"subgroup of order {len(H)} in Z/{n}", H, m))
    for name, A, moduli in rows:
        b = float(covering_bound_combinatorial(A, A, moduli))
        S = sumset(A, A, moduli)
        print(f"  {name:<34}{len(A):>5}{len(S)/len(A):>18.3f}{b/len(S):>14.4f}")
    print()
    print("  Sidon -> 1 (asymptotically exact); exponent two -> 2/3; intervals in")
    print("  [3/4, 1); subgroups exactly 1 but with no gain over pigeonhole.")


def main() -> None:
    print(__doc__)
    demo_identity()
    demo_parabola()
    demo_hamming()
    demo_intervals()
    demo_dichotomy()
    demo_accuracy()
    banner("All assertions passed.")


if __name__ == "__main__":
    main()
