"""
Numerical demonstrations for the converse of Poisson summation on a finite abelian group.

The mathematics
---------------
Let G be a finite abelian group with dual group Ghat of characters and discrete Fourier
transform

    fhat(psi) = sum_{x in G} conj(psi(x)) f(x).

A pair (S, T) with S subset of G, T subset of Ghat is a POISSON PAIR when

    |G| * sum_{x in S} f(x) = |S| * sum_{psi in T} fhat(psi)      for every f : G -> C.

Results demonstrated here:

  1. Delta reduction: the identity for all f is equivalent to the finite character-table
     system |S| * sum_{psi in T} conj(psi(a)) = |G| * [a in S], one equation per a in G.
  2. Rectangle criterion: for nonempty S, (S, T) is a Poisson pair iff psi(x) = 1 on all of
     S x T and |S| * |T| = |G|.
  3. Classification: the nonempty Poisson pairs are exactly (H, H^perp) for subgroups H.
  4. Area identity |S| * |T| = |G| and Lagrange's theorem |S| divides |G|.
  5. Enumeration: #{nonempty Poisson pairs} = #{subgroups of G}; for Z/n this is sigma_0(n).
  6. Prime order: exactly two nonempty Poisson pairs, ({0}, Ghat) and (G, {trivial}).
  7. Rectangle bound: every all-ones block of the character table has area at most |G|.
  8. Twisted regime: unimodular weights force cosets; arbitrary weights make every nonempty
     set a twisted Poisson set (witness S = {0,1} in Z/3, which is not a coset).
  9. Uncertainty extremals: |supp f| * |supp fhat| >= |G| with equality exactly for
     f = c * psi_1 * indicator(a + H).

Everything below is self-contained: only the standard library is used.
"""

from __future__ import annotations

import cmath
import itertools
import math
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Complex = complex
Group = Tuple[int, ...]          # element of Z/n1 x ... x Z/nk
Moduli = Tuple[int, ...]         # the list (n1, ..., nk)

TOL = 1e-9


# ---------------------------------------------------------------------------
# The group Z/n1 x ... x Z/nk, its characters, and the discrete Fourier transform
# ---------------------------------------------------------------------------

def group_elements(moduli: Moduli) -> List[Group]:
    """All elements of Z/n1 x ... x Z/nk, in lexicographic order."""
    return [tuple(t) for t in itertools.product(*(range(n) for n in moduli))]


def group_order(moduli: Moduli) -> int:
    """The order |G| of the group."""
    return math.prod(moduli)


def add(x: Group, y: Group, moduli: Moduli) -> Group:
    """Group addition, componentwise modulo the corresponding modulus."""
    return tuple((a + b) % n for a, b, n in zip(x, y, moduli))


def neg(x: Group, moduli: Moduli) -> Group:
    """Group negation."""
    return tuple((-a) % n for a, n in zip(x, moduli))


def character(k: Group, x: Group, moduli: Moduli) -> Complex:
    """
    The character psi_k evaluated at x:  psi_k(x) = exp(2 pi i sum_j k_j x_j / n_j).

    Characters of Z/n1 x ... x Z/nk are indexed by the group itself, so the dual group is
    represented by the same set of tuples.
    """
    phase = sum(kj * xj / nj for kj, xj, nj in zip(k, x, moduli))
    return cmath.exp(2j * cmath.pi * phase)


def dft(f: Dict[Group, Complex], moduli: Moduli) -> Dict[Group, Complex]:
    """Discrete Fourier transform fhat(psi_k) = sum_x conj(psi_k(x)) f(x)."""
    elts = group_elements(moduli)
    return {k: sum(character(k, x, moduli).conjugate() * f[x] for x in elts) for k in elts}


def inverse_dft(fh: Dict[Group, Complex], moduli: Moduli) -> Dict[Group, Complex]:
    """Fourier inversion: f(x) = (1/|G|) sum_k psi_k(x) fhat(psi_k)."""
    elts = group_elements(moduli)
    n = group_order(moduli)
    return {x: sum(character(k, x, moduli) * fh[k] for k in elts) / n for x in elts}


# ---------------------------------------------------------------------------
# Poisson pairs: the three equivalent tests
# ---------------------------------------------------------------------------

def poisson_defect(
    S: Sequence[Group],
    T: Sequence[Group],
    f: Dict[Group, Complex],
    moduli: Moduli,
) -> float:
    """|G| sum_{x in S} f(x) - |S| sum_{psi in T} fhat(psi), as an absolute value."""
    n = group_order(moduli)
    fh = dft(f, moduli)
    lhs = n * sum(f[x] for x in S)
    rhs = len(S) * sum(fh[k] for k in T)
    return abs(lhs - rhs)


def is_poisson_pair_by_testing(
    S: Sequence[Group],
    T: Sequence[Group],
    moduli: Moduli,
    trials: int = 12,
    seed: int = 20260819,
) -> bool:
    """
    Test the *defining* condition on pseudorandom functions f.  This is a Monte Carlo check
    of Definition 3.1; it can only refute, never certify.  Used to corroborate the exact
    criteria below.
    """
    elts = group_elements(moduli)
    state = seed
    for _ in range(trials):
        f: Dict[Group, Complex] = {}
        for x in elts:
            state = (1103515245 * state + 12345) % (1 << 31)
            re = (state / (1 << 31)) * 2 - 1
            state = (1103515245 * state + 12345) % (1 << 31)
            im = (state / (1 << 31)) * 2 - 1
            f[x] = complex(re, im)
        if poisson_defect(S, T, f, moduli) > 1e-6 * group_order(moduli) ** 2:
            return False
    return True


def satisfies_character_table_condition(
    S: Sequence[Group], T: Sequence[Group], moduli: Moduli
) -> bool:
    """
    The delta reduction (Theorem 3.3): |S| sum_{psi in T} conj(psi(a)) = |G| [a in S]
    for every a in G.  Equivalent to the full Poisson identity.
    """
    n = group_order(moduli)
    Sset = set(S)
    for a in group_elements(moduli):
        lhs = len(S) * sum(character(k, a, moduli).conjugate() for k in T)
        rhs = n * (1.0 if a in Sset else 0.0)
        if abs(lhs - rhs) > TOL * n * n:
            return False
    return True


def is_all_ones_rectangle(
    S: Sequence[Group], T: Sequence[Group], moduli: Moduli
) -> bool:
    """Is the S x T block of the character table identically 1?"""
    return all(
        abs(character(k, x, moduli) - 1) <= TOL for x in S for k in T
    )


def satisfies_rectangle_criterion(
    S: Sequence[Group], T: Sequence[Group], moduli: Moduli
) -> bool:
    """
    The rectangle criterion (Theorem 5.3): for nonempty S, (S,T) is a Poisson pair iff the
    S x T block is all ones and |S| |T| = |G|.  Cost O(|S||T|) = O(|G|).
    """
    if not S:
        return False
    return is_all_ones_rectangle(S, T, moduli) and len(S) * len(T) == group_order(moduli)


# ---------------------------------------------------------------------------
# Subgroups, annihilators, brute-force enumeration
# ---------------------------------------------------------------------------

def subgroup_generated(gens: Iterable[Group], moduli: Moduli) -> Tuple[Group, ...]:
    """The subgroup of G generated by a set of elements (closure under addition)."""
    zero = tuple(0 for _ in moduli)
    seen = {zero}
    frontier = [zero]
    gens = list(gens)
    while frontier:
        x = frontier.pop()
        for g in gens:
            y = add(x, g, moduli)
            if y not in seen:
                seen.add(y)
                frontier.append(y)
    return tuple(sorted(seen))


def all_subgroups(moduli: Moduli) -> List[Tuple[Group, ...]]:
    """All subgroups of G, by taking the closure of every subset of generators."""
    elts = group_elements(moduli)
    found = set()
    # every subgroup of an abelian group of order n is generated by at most log2(n) elements
    max_gens = max(1, int(math.log2(group_order(moduli))) + 1)
    for r in range(0, max_gens + 1):
        for gens in itertools.combinations(elts, r):
            found.add(subgroup_generated(gens, moduli))
    return sorted(found, key=lambda H: (len(H), H))


def annihilator(H: Sequence[Group], moduli: Moduli) -> Tuple[Group, ...]:
    """H^perp = { psi : psi(x) = 1 for all x in H }, as a set of dual indices."""
    return tuple(
        k for k in group_elements(moduli)
        if all(abs(character(k, x, moduli) - 1) <= TOL for x in H)
    )


def pre_annihilator(T: Sequence[Group], moduli: Moduli) -> Tuple[Group, ...]:
    """T^perp = { a in G : psi(a) = 1 for all psi in T }; always a subgroup."""
    return tuple(
        a for a in group_elements(moduli)
        if all(abs(character(k, a, moduli) - 1) <= TOL for k in T)
    )


def brute_force_poisson_pairs(
    moduli: Moduli,
) -> List[Tuple[Tuple[Group, ...], Tuple[Group, ...]]]:
    """
    Exhaustive search over all 2^|G| * 2^|G| pairs of subsets, using the rectangle criterion.
    Feasible only for very small |G|; used to corroborate the enumeration theorem.
    """
    elts = group_elements(moduli)
    pairs = []
    subsets = [
        tuple(c) for r in range(1, len(elts) + 1) for c in itertools.combinations(elts, r)
    ]
    n = group_order(moduli)
    for S in subsets:
        for T in subsets:
            if len(S) * len(T) != n:
                continue
            if is_all_ones_rectangle(S, T, moduli):
                pairs.append((S, T))
    return pairs


def divisor_count(n: int) -> int:
    """sigma_0(n), the number of positive divisors of n."""
    return sum(1 for d in range(1, n + 1) if n % d == 0)


# ---------------------------------------------------------------------------
# Uncertainty principle
# ---------------------------------------------------------------------------

def support(f: Dict[Group, Complex]) -> List[Group]:
    """The set of points where f does not vanish."""
    return [x for x, v in f.items() if abs(v) > 1e-9]


def uncertainty_product(f: Dict[Group, Complex], moduli: Moduli) -> int:
    """|supp f| * |supp fhat|."""
    return len(support(f)) * len(support(dft(f, moduli)))


def modulated_coset_indicator(
    c: Complex, psi1: Group, a: Group, H: Sequence[Group], moduli: Moduli
) -> Dict[Group, Complex]:
    """The candidate extremal f = c * psi_1 * indicator(a + H)."""
    coset = {add(a, h, moduli) for h in H}
    return {
        x: (c * character(psi1, x, moduli) if x in coset else 0j)
        for x in group_elements(moduli)
    }


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_equivalent_tests() -> None:
    banner("1. Three equivalent formulations of the Poisson identity  (G = Z/6)")
    moduli = (6,)
    H = subgroup_generated([(2,)], moduli)          # {0,2,4}
    T = annihilator(H, moduli)                       # {0,3}
    print(f"  subgroup H            = {[h[0] for h in H]}")
    print(f"  annihilator H^perp    = {[k[0] for k in T]}")
    print(f"  |H| * |H^perp|        = {len(H)}*{len(T)} = {len(H)*len(T)}  (= |G| = 6)")
    print(f"  random-function test  : {is_poisson_pair_by_testing(H, T, moduli)}")
    print(f"  character-table test  : {satisfies_character_table_condition(H, T, moduli)}")
    print(f"  rectangle criterion   : {satisfies_rectangle_criterion(H, T, moduli)}")

    print("\n  A non-example, S = {0,1} (not a subgroup), T = {0,3}:")
    S = [(0,), (1,)]
    print(f"    random-function test: {is_poisson_pair_by_testing(S, T, moduli)}")
    print(f"    character-table test: {satisfies_character_table_condition(S, T, moduli)}")
    print(f"    rectangle criterion : {satisfies_rectangle_criterion(S, T, moduli)}")


def demo_classification() -> None:
    banner("2. Classification: every nonempty Poisson pair is (H, H^perp)  (G = Z/6)")
    moduli = (6,)
    pairs = brute_force_poisson_pairs(moduli)
    print(f"  exhaustive search found {len(pairs)} nonempty Poisson pairs:")
    for S, T in sorted(pairs, key=lambda p: len(p[0])):
        Hrec = pre_annihilator(T, moduli)
        ok = set(Hrec) == set(S) and set(annihilator(Hrec, moduli)) == set(T)
        print(
            f"    S = {str([x[0] for x in S]):<18} T = {str([k[0] for k in T]):<18}"
            f" |S||T| = {len(S)*len(T)}   S = (T^perp) and T = S^perp : {ok}"
        )
    subs = all_subgroups(moduli)
    print(f"\n  subgroups of Z/6: {[[h[0] for h in H] for H in subs]}")
    print(f"  #Poisson pairs = {len(pairs)}   #subgroups = {len(subs)}   sigma_0(6) = "
          f"{divisor_count(6)}")


def demo_enumeration() -> None:
    banner("3. Enumeration: #Poisson pairs = #subgroups = sigma_0(n) for Z/n")
    print(f"  {'n':>3} {'#Poisson pairs':>16} {'#subgroups':>12} {'sigma_0(n)':>12}")
    for n in range(1, 9):
        moduli = (n,)
        pairs = brute_force_poisson_pairs(moduli)
        subs = all_subgroups(moduli)
        print(f"  {n:>3} {len(pairs):>16} {len(subs):>12} {divisor_count(n):>12}")

    print("\n  Non-cyclic example G = Z/2 x Z/2 (Klein four-group):")
    moduli = (2, 2)
    pairs = brute_force_poisson_pairs(moduli)
    subs = all_subgroups(moduli)
    print(f"    #Poisson pairs = {len(pairs)}   #subgroups = {len(subs)}  "
          f"(expected 5: trivial, three of order 2, whole group)")


def demo_prime_order() -> None:
    banner("4. Groups of prime order: exactly two nonempty Poisson pairs")
    for p in (2, 3, 5, 7):
        moduli = (p,)
        pairs = brute_force_poisson_pairs(moduli)
        shapes = sorted((len(S), len(T)) for S, T in pairs)
        print(f"  p = {p}: {len(pairs)} pairs, shapes (|S|,|T|) = {shapes}")
    print("  In every case the survivors are ({0}, Ghat) and (G, {trivial character}).")


def demo_area_and_lagrange() -> None:
    banner("5. Area identity |S||T| = |G| and Lagrange's theorem")
    for moduli in [(6,), (8,), (2, 2), (2, 3)]:
        n = group_order(moduli)
        pairs = brute_force_poisson_pairs(moduli)
        areas = {len(S) * len(T) for S, T in pairs}
        divides = all(n % len(S) == 0 for S, T in pairs)
        print(f"  G of order {n:>2} {str(moduli):<8}: areas {areas}, |S| divides |G| for "
              f"all pairs: {divides}")


def demo_rectangle_bound() -> None:
    banner("6. Rectangle bound: every all-ones block has area at most |G|")
    moduli = (8,)
    n = group_order(moduli)
    elts = group_elements(moduli)
    best = 0
    worst_example = None
    subsets = [
        tuple(c) for r in range(1, len(elts) + 1) for c in itertools.combinations(elts, r)
    ]
    for S in subsets:
        for T in subsets:
            if len(S) * len(T) <= best:
                continue
            if is_all_ones_rectangle(S, T, moduli):
                best = len(S) * len(T)
                worst_example = (S, T)
    S, T = worst_example
    print(f"  |G| = {n}; largest all-ones rectangle has area {best}")
    print(f"    S = {[x[0] for x in S]},  T = {[k[0] for k in T]}")
    print(f"  bound |S||T| <= |G| is attained exactly by the Poisson pairs.")


def demo_twisted() -> None:
    banner("7. Twisted regime: cosets, phases, and the collapse without unimodularity")
    moduli = (6,)
    H = subgroup_generated([(2,)], moduli)
    T = annihilator(H, moduli)
    a = (1,)
    coset = [add(a, h, moduli) for h in H]
    n = group_order(moduli)

    # twisted identity over the coset, with weight w(psi) = psi(a)
    f = {x: complex(math.cos(3.1 * x[0]), math.sin(1.7 * x[0])) for x in group_elements(moduli)}
    fh = dft(f, moduli)
    lhs = n * sum(f[x] for x in coset)
    rhs = len(coset) * sum(character(k, a, moduli) * fh[k] for k in T)
    print(f"  coset 1 + H = {[x[0] for x in coset]}, weights w(psi_k) = psi_k(1), |w| = 1")
    print(f"    twisted identity defect = {abs(lhs - rhs):.3e}   (should be ~0)")
    print(f"    untwisted defect        = {poisson_defect(coset, T, f, moduli):.3e}"
          f"   (nonzero: the phase is necessary)")

    # collapse: any nonempty S with T = Ghat and non-unimodular weights read off 1_S
    moduli3 = (3,)
    S = [(0,), (1,)]
    n3 = group_order(moduli3)
    indicator = {x: (1.0 + 0j if x in set(S) else 0j) for x in group_elements(moduli3)}
    ind_hat = dft(indicator, moduli3)
    w = {k: ind_hat[k].conjugate() / len(S) for k in group_elements(moduli3)}
    g = {x: complex(1.3 * x[0] - 0.7, 0.4 - 0.9 * x[0]) for x in group_elements(moduli3)}
    gh = dft(g, moduli3)
    lhs = n3 * sum(g[x] for x in S)
    rhs = len(S) * sum(w[k] * gh[k] for k in group_elements(moduli3))
    print(f"\n  S = {{0,1}} in Z/3 is not a coset (2 does not divide 3), yet")
    print(f"    twisted identity defect with weights w = conj(1_S^)/|S| : {abs(lhs - rhs):.3e}")
    print(f"    weight moduli |w(psi_k)| = "
          f"{[round(abs(w[k]), 4) for k in group_elements(moduli3)]}  (not all 1)")
    print("  So unimodularity is exactly the dividing line between rigidity and vacuity.")


def demo_uncertainty() -> None:
    banner("8. Uncertainty principle and its extremals")
    moduli = (12,)
    n = group_order(moduli)
    H = subgroup_generated([(4,)], moduli)     # {0,4,8}, order 3
    f = modulated_coset_indicator(2.5 - 1j, (5,), (1,), H, moduli)
    prod = uncertainty_product(f, moduli)
    print(f"  G = Z/12, H = {[h[0] for h in H]}, a = 1, psi_1 = psi_5, c = 2.5 - i")
    print(f"    supp f      = {sorted(x[0] for x in support(f))}")
    print(f"    supp fhat   = {sorted(k[0] for k in support(dft(f, moduli)))}")
    print(f"    product     = {prod}   (|G| = {n}: equality, so f is extremal)")

    print("\n  Comparisons (the product is always >= |G| = 12; equality flags an extremal):")
    for name, g in [
        ("indicator of {0,1,2}", {x: (1 + 0j if x[0] in (0, 1, 2) else 0j)
                                  for x in group_elements(moduli)}),
        ("single spike at 7", {x: (1 + 0j if x[0] == 7 else 0j)
                               for x in group_elements(moduli)}),
        ("indicator of {0,3,6,9} (a subgroup)", {x: (1 + 0j if x[0] % 3 == 0 else 0j)
                                                 for x in group_elements(moduli)}),
    ]:
        print(f"    {name:<38} product = {uncertainty_product(g, moduli):>3}")


def demo_delta_reduction_cost() -> None:
    banner("9. Why the delta reduction matters: from infinitely many tests to |G| equations")
    moduli = (6,)
    H = subgroup_generated([(3,)], moduli)
    T = annihilator(H, moduli)
    print(f"  S = {[h[0] for h in H]}, T = {[k[0] for k in T]}")
    print("  The defining condition quantifies over all f : G -> C (a 6-dimensional complex")
    print("  space, so infinitely many test functions). The delta reduction replaces it by")
    print("  exactly |G| = 6 scalar equations on the character table:")
    for a in group_elements(moduli):
        lhs = len(H) * sum(character(k, a, moduli).conjugate() for k in T)
        rhs = group_order(moduli) * (1 if a in set(H) else 0)
        print(f"    a = {a[0]}:  |S| * sum_psi conj(psi(a)) = {lhs.real:6.2f}"
              f"{lhs.imag:+.2f}i    |G| * [a in S] = {rhs}")


def main() -> None:
    print(__doc__)
    demo_equivalent_tests()
    demo_classification()
    demo_enumeration()
    demo_prime_order()
    demo_area_and_lagrange()
    demo_rectangle_bound()
    demo_twisted()
    demo_uncertainty()
    demo_delta_reduction_cost()
    print()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
