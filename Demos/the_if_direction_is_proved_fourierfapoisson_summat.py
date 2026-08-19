"""
Minimum Uncertainty Is a Subgroup
=================================

Numerical demonstrations of the classification of the extremals of the
Donoho-Stark uncertainty principle on a finite abelian group, and of the
rigidity of finite Poisson summation.

Everything is implemented from scratch with the standard library only.

A finite abelian group is represented as a tuple of moduli, e.g.

    (12,)      is  Z/12
    (2, 2)     is  Z/2 x Z/2
    (6, 2)     is  Z/6 x Z/2

Its elements are tuples of residues, and the character indexed by k is

    psi_k(x) = exp( 2*pi*i * sum_j k_j x_j / n_j ).

The discrete Fourier transform used throughout is

    fhat(psi) = sum_x conj(psi(x)) f(x),

with inversion f(x) = (1/N) sum_psi psi(x) fhat(psi) and Plancherel
sum_psi |fhat(psi)|^2 = N sum_x |f(x)|^2.

The results demonstrated:

  1. Coset modulations c * chi * 1_{a+K} are extremal:
     |supp f| * |supp fhat| = |G|.
  2. Conversely, every extremal function is a coset modulation, and its
     subgroup is the difference set of its support.
  3. The extremal spectrum of G is exactly the divisor set of |G|.
  4. If |supp f| does not divide |G| the uncertainty product overshoots by
     at least |supp f| - (|G| mod |supp f|).
  5. Poisson summation holds exactly for (subgroup, annihilator) pairs, and
     the |G| Dirac identities already certify it.
  6. The extremal class is closed under pointwise products and convolutions.
  7. An extremal probability distribution is uniform on a coset.
  8. Z/4 and Z/2 x Z/2 have the same extremal spectrum but different
     families of extremal supports.
"""

from __future__ import annotations

import cmath
import itertools
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

Elem = Tuple[int, ...]
Group = Tuple[int, ...]
Func = Dict[Elem, complex]

TOL: float = 1e-9


# ---------------------------------------------------------------------------
# Group arithmetic and characters
# ---------------------------------------------------------------------------


def elements(group: Group) -> List[Elem]:
    """All elements of Z/n_1 x ... x Z/n_r, in lexicographic order."""
    return [tuple(t) for t in itertools.product(*(range(n) for n in group))]


def order(group: Group) -> int:
    """The order |G| of the group."""
    n = 1
    for m in group:
        n *= m
    return n


def add(group: Group, x: Elem, y: Elem) -> Elem:
    """Group addition."""
    return tuple((a + b) % n for a, b, n in zip(x, y, group))


def sub(group: Group, x: Elem, y: Elem) -> Elem:
    """Group subtraction."""
    return tuple((a - b) % n for a, b, n in zip(x, y, group))


def zero(group: Group) -> Elem:
    """The neutral element."""
    return tuple(0 for _ in group)


def character(group: Group, k: Elem, x: Elem) -> complex:
    """The character psi_k evaluated at x: exp(2*pi*i * sum k_j x_j / n_j)."""
    phase = sum(2.0 * cmath.pi * (kj * xj) / nj for kj, xj, nj in zip(k, x, group))
    return cmath.exp(1j * phase)


# ---------------------------------------------------------------------------
# The discrete Fourier transform
# ---------------------------------------------------------------------------


def dft(group: Group, f: Func) -> Func:
    """fhat(k) = sum_x conj(psi_k(x)) f(x), indexed by the dual element k."""
    els = elements(group)
    out: Func = {}
    for k in els:
        total = 0j
        for x in els:
            fx = f.get(x, 0j)
            if fx != 0:
                total += character(group, k, x).conjugate() * fx
        out[k] = total
    return out


def idft(group: Group, fhat: Func) -> Func:
    """Inverse transform: f(x) = (1/N) sum_k psi_k(x) fhat(k)."""
    els = elements(group)
    n = order(group)
    return {
        x: sum(character(group, k, x) * fhat.get(k, 0j) for k in els) / n for x in els
    }


def support(f: Func, tol: float = TOL) -> Set[Elem]:
    """The set of points where f is (numerically) nonzero."""
    return {x for x, v in f.items() if abs(v) > tol}


def uncertainty_product(group: Group, f: Func) -> int:
    """|supp f| * |supp fhat|."""
    return len(support(f)) * len(support(dft(group, f)))


def is_extremal(group: Group, f: Func) -> bool:
    """True when |supp f| * |supp fhat| = |G| (and f is nonzero)."""
    if not support(f):
        return False
    return uncertainty_product(group, f) == order(group)


def convolve(group: Group, u: Func, v: Func) -> Func:
    """(u * v)(x) = sum_y u(y) v(x - y)."""
    els = elements(group)
    return {
        x: sum(u.get(y, 0j) * v.get(sub(group, x, y), 0j) for y in els) for x in els
    }


def pointwise(u: Func, v: Func) -> Func:
    """Pointwise product."""
    return {x: u.get(x, 0j) * v.get(x, 0j) for x in set(u) | set(v)}


# ---------------------------------------------------------------------------
# Subgroups, cosets, coset modulations
# ---------------------------------------------------------------------------


def subgroup_generated(group: Group, gens: Iterable[Elem]) -> Set[Elem]:
    """The subgroup of G generated by the given elements (closure by BFS)."""
    seen: Set[Elem] = {zero(group)}
    frontier: List[Elem] = [zero(group)]
    gens = list(gens)
    while frontier:
        x = frontier.pop()
        for g in gens:
            y = add(group, x, g)
            if y not in seen:
                seen.add(y)
                frontier.append(y)
    return seen


def all_subgroups(group: Group) -> List[Set[Elem]]:
    """All subgroups of G, obtained by closing every subset of generators
    of size at most the rank + 1 (exhaustive for the small groups used here)."""
    els = elements(group)
    found: Set[frozenset] = set()
    for r in range(0, min(3, len(els)) + 1):
        for gens in itertools.combinations(els, r):
            found.add(frozenset(subgroup_generated(group, gens)))
    return [set(s) for s in sorted(found, key=lambda s: (len(s), sorted(s)))]


def annihilator(group: Group, subgroup: Set[Elem]) -> Set[Elem]:
    """K^perp = { k : psi_k(x) = 1 for all x in K }, as a set of dual indices."""
    return {
        k
        for k in elements(group)
        if all(abs(character(group, k, x) - 1.0) < TOL for x in subgroup)
    }


def coset_modulation(
    group: Group, subgroup: Set[Elem], a: Elem, chi: Elem, c: complex
) -> Func:
    """f(x) = c * psi_chi(x) for x in a + K, and 0 elsewhere."""
    cos = {add(group, a, k) for k in subgroup}
    return {
        x: (c * character(group, chi, x) if x in cos else 0j) for x in elements(group)
    }


def difference_set(group: Group, s: Set[Elem]) -> Set[Elem]:
    """S - S = { x - y : x, y in S }."""
    return {sub(group, x, y) for x in s for y in s}


def is_coset(group: Group, s: Set[Elem]) -> bool:
    """A nonempty S is a coset iff |S - S| = |S| (equivalently, iff S is
    closed under the parallelogram operation (x, y, z) -> x - y + z)."""
    return bool(s) and len(difference_set(group, s)) == len(s)


def is_parallelogram_closed(group: Group, s: Set[Elem]) -> bool:
    """Direct test of closure under (x, y, z) -> x - y + z."""
    return bool(s) and all(
        add(group, sub(group, x, y), z) in s for x in s for y in s for z in s
    )


# ---------------------------------------------------------------------------
# Structure extraction (Algorithm 2 of the paper)
# ---------------------------------------------------------------------------


def extract_structure(
    group: Group, f: Func
) -> Optional[Tuple[Set[Elem], Elem, Elem, complex]]:
    """For an extremal f, recover (K, a, chi, c) with f = c * psi_chi * 1_{a+K}.

    Returns None if f is not extremal.  The subgroup is recovered purely
    combinatorially, as the difference set of the support; the character index
    is then found by matching phases on the support.
    """
    if not is_extremal(group, f):
        return None
    s = support(f)
    a = sorted(s)[0]
    k_sub = difference_set(group, s)
    c_times_chi_a = f[a]
    for chi in elements(group):
        c = c_times_chi_a * character(group, chi, a).conjugate()
        candidate = coset_modulation(group, k_sub, a, chi, c)
        if all(abs(candidate[x] - f.get(x, 0j)) < 1e-7 for x in elements(group)):
            return k_sub, a, chi, c
    return None


# ---------------------------------------------------------------------------
# Poisson pairs (Definition 3.3, Lemma 3.4, Corollary 3.8)
# ---------------------------------------------------------------------------


def poisson_holds_for(group: Group, s: Set[Elem], t: Set[Elem], f: Func) -> bool:
    """Check N * sum_{x in S} f(x) = |S| * sum_{k in T} fhat(k) for one f."""
    n = order(group)
    fhat = dft(group, f)
    lhs = n * sum(f.get(x, 0j) for x in s)
    rhs = len(s) * sum(fhat[k] for k in t)
    return abs(lhs - rhs) < 1e-7


def poisson_dirac_test(group: Group, s: Set[Elem], t: Set[Elem]) -> bool:
    """The finite certificate: check only the |G| Dirac identities
    N * 1_S(y) = |S| * sum_{k in T} psi_k(y)."""
    n = order(group)
    for y in elements(group):
        lhs = n * (1.0 if y in s else 0.0)
        rhs = len(s) * sum(character(group, k, y) for k in t)
        if abs(lhs - rhs) > 1e-7:
            return False
    return True


# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------


def divisors(n: int) -> List[int]:
    """All positive divisors of n, ascending."""
    return [d for d in range(1, n + 1) if n % d == 0]


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ---------------------------------------------------------------------------
# Demonstration 1: coset modulations saturate the uncertainty principle
# ---------------------------------------------------------------------------


def demo_coset_modulations_are_extremal() -> None:
    banner("1. Coset modulations attain equality:  |supp f| * |supp fhat| = |G|")
    group: Group = (12,)
    n = order(group)
    print(f"G = Z/12,  |G| = {n}\n")
    print(f"{'subgroup K':<28}{'a':<8}{'chi':<7}{'|supp f|':>9}{'|supp fhat|':>13}"
          f"{'product':>9}")
    print("-" * 78)
    for k_sub in all_subgroups(group):
        a: Elem = (1,)
        chi: Elem = (5,)
        f = coset_modulation(group, k_sub, a, chi, 2 + 1j)
        sf, sh = len(support(f)), len(support(dft(group, f)))
        label = "{" + ",".join(str(x[0]) for x in sorted(k_sub)) + "}"
        if len(label) > 26:
            label = label[:23] + "...}"
        print(f"{label:<28}{a[0]:<8}{chi[0]:<7}{sf:>9}{sh:>13}{sf * sh:>9}")
    print("\nEvery product equals |G| = 12, as the classification predicts.")


# ---------------------------------------------------------------------------
# Demonstration 2: exhaustive verification on Z/4
# ---------------------------------------------------------------------------


def demo_exhaustive_z4() -> None:
    banner("2. Exhaustive census on Z/4 over the values {0, 1, -1, i, -i}")
    group: Group = (4,)
    els = elements(group)
    values: Sequence[complex] = (0j, 1 + 0j, -1 + 0j, 1j, -1j)

    total = 0
    nonzero = 0
    bound_ok = True
    extremals: List[Func] = []
    size_hist: Dict[int, int] = {d: 0 for d in range(5)}

    for combo in itertools.product(values, repeat=len(els)):
        f: Func = dict(zip(els, combo))
        total += 1
        s = support(f)
        if not s:
            continue
        nonzero += 1
        prod = uncertainty_product(group, f)
        if prod < 4:
            bound_ok = False
        if prod == 4:
            extremals.append(f)
            size_hist[len(s)] += 1

    print(f"functions tested / nonzero            : {total} / {nonzero}")
    print(f"uncertainty bound |supp f||supp fhat| >= 4 holds everywhere : {bound_ok}")
    print(f"number of extremals                   : {len(extremals)}")
    print("support-size distribution of extremals: "
          + ", ".join(f"size {d}: {size_hist[d]}" for d in range(5)))
    print("  (no extremal of support size 3, because 3 does not divide 4)")

    all_cosets = all(is_coset(group, support(f)) for f in extremals)
    flat = all(
        len({round(abs(f[x]), 9) for x in support(f)}) == 1 for f in extremals
    )
    freq_cosets = all(
        is_coset(group, support(dft(group, f))) for f in extremals
    )
    print(f"every extremal support is a coset     : {all_cosets}")
    print(f"every extremal is flat on its support : {flat}")
    print(f"every frequency support is a coset    : {freq_cosets}")

    bad: Func = {(0,): 1 + 0j, (1,): 1 + 0j, (2,): 0j, (3,): 0j}
    print(f"\nthe non-coset support {{0,1}}: product = "
          f"{uncertainty_product(group, bad)} > 4, so not extremal")


# ---------------------------------------------------------------------------
# Demonstration 3: the extremal spectrum is the divisor set
# ---------------------------------------------------------------------------


def demo_extremal_spectrum() -> None:
    banner("3. The extremal spectrum of G equals the divisor set of |G|")
    for group in [(4,), (2, 2), (6,), (12,), (6, 2)]:
        n = order(group)
        achievable = sorted({len(k) for k in all_subgroups(group)})
        # realise each size by an explicit extremal function and check it
        realised = []
        for k_sub in all_subgroups(group):
            f = coset_modulation(group, k_sub, zero(group), zero(group), 1 + 0j)
            if is_extremal(group, f):
                realised.append(len(k_sub))
        name = " x ".join(f"Z/{m}" for m in group)
        print(f"{name:<14} |G| = {n:>3}   subgroup orders {achievable}"
              f"   divisors {divisors(n)}")
        assert achievable == divisors(n) == sorted(set(realised))
    print("\nEvery divisor is realised by an explicit extremal function, and no"
          "\nother size occurs -- the extremal spectrum theorem.")


# ---------------------------------------------------------------------------
# Demonstration 4: the gap when the support size does not divide |G|
# ---------------------------------------------------------------------------


def demo_uncertainty_gap() -> None:
    banner("4. The uncertainty gap when |supp f| does not divide |G|")
    group: Group = (12,)
    n = order(group)
    print("G = Z/12.  For each support size s, the sharpened bound is")
    print("    s * |supp fhat| >= N + (s - N mod s)  when s does not divide N.\n")
    print(f"{'s':>3}{'s | 12?':>10}{'ceil(12/s)':>12}{'guaranteed product':>21}")
    print("-" * 48)
    for s in range(1, n + 1):
        divides = n % s == 0
        ceil_t = -(-n // s)
        guaranteed = n if divides else n + (s - n % s)
        print(f"{s:>3}{('yes' if divides else 'no'):>10}{ceil_t:>12}{guaranteed:>21}")

    print("\nEmpirical check for s = 5 on Z/12 (random 5-point supports):")
    import random

    random.seed(20260819)
    worst = None
    for _ in range(400):
        pts = random.sample(elements(group), 5)
        f: Func = {x: 0j for x in elements(group)}
        for p in pts:
            f[p] = complex(random.choice([1, -1, 2, 1j, -1j]))
        prod = uncertainty_product(group, f)
        worst = prod if worst is None else min(worst, prod)
    print(f"  smallest product observed: {worst}"
          f"   (guaranteed lower bound: {n + (5 - n % 5)})")


# ---------------------------------------------------------------------------
# Demonstration 5: structure extraction from a bare numerical equality
# ---------------------------------------------------------------------------


def demo_structure_extraction() -> None:
    banner("5. From a numerical coincidence to a subgroup: structure extraction")
    group: Group = (6, 2)
    n = order(group)
    k_sub = subgroup_generated(group, [(2, 0), (0, 1)])
    a: Elem = (1, 0)
    chi: Elem = (4, 1)
    c: complex = 0.5 - 1.5j
    f = coset_modulation(group, k_sub, a, chi, c)

    print(f"G = Z/6 x Z/2, |G| = {n}")
    print(f"hidden data:  K = {sorted(k_sub)},  a = {a},  chi = {chi},  c = {c}")
    print(f"observed:     |supp f| * |supp fhat| = {uncertainty_product(group, f)}"
          f" = |G|\n")

    recovered = extract_structure(group, f)
    assert recovered is not None
    k_rec, a_rec, chi_rec, c_rec = recovered
    print("recovered from f alone (support difference set + phase matching):")
    print(f"  K   = {sorted(k_rec)}")
    print(f"  a   = {a_rec}   (any point of the support; differs from the hidden a"
          " by an element of K)")
    print(f"  chi = {chi_rec}")
    print(f"  c   = {c_rec:.6g}")
    rebuilt = coset_modulation(group, k_rec, a_rec, chi_rec, c_rec)
    exact = all(abs(rebuilt[x] - f[x]) < 1e-9 for x in elements(group))
    print(f"\nsubgroup recovered correctly    : {k_rec == k_sub}   (the subgroup is"
          " unique)")
    print(f"coset representative consistent : {sub(group, a_rec, a) in k_sub}")
    print(f"reconstruction reproduces f     : {exact}")
    print("the character is determined only modulo the annihilator K^perp, and the"
          "\nscalar compensates, so (chi, c) may legitimately differ from the hidden"
          " pair.")


# ---------------------------------------------------------------------------
# Demonstration 6: rigidity of Poisson summation
# ---------------------------------------------------------------------------


def demo_poisson_rigidity() -> None:
    banner("6. Poisson summation holds exactly for (subgroup, annihilator) pairs")
    group: Group = (6,)
    n = order(group)
    print(f"G = Z/6, |G| = {n}\n")
    print(f"{'S':<20}{'T':<22}{'Dirac test':>12}{'random f test':>16}")
    print("-" * 72)

    import random

    random.seed(7)

    def random_f() -> Func:
        return {
            x: complex(random.uniform(-2, 2), random.uniform(-2, 2))
            for x in elements(group)
        }

    tests: List[Tuple[Set[Elem], Set[Elem], str]] = []
    for k_sub in all_subgroups(group):
        tests.append((k_sub, annihilator(group, k_sub), "subgroup"))
    # a non-subgroup set of the right size, paired with its "would-be" dual
    tests.append(({(0,), (1,)}, annihilator(group, {(0,), (3,)}), "non-subgroup"))
    tests.append(({(1,), (4,)}, annihilator(group, {(0,), (3,)}), "coset, not subgroup"))

    for s, t, _kind in tests:
        dirac = poisson_dirac_test(group, s, t)
        rnd = all(poisson_holds_for(group, s, t, random_f()) for _ in range(5))
        s_lab = "{" + ",".join(str(x[0]) for x in sorted(s)) + "}"
        t_lab = "{" + ",".join(str(x[0]) for x in sorted(t)) + "}"
        print(f"{s_lab:<20}{t_lab:<22}{str(dirac):>12}{str(rnd):>16}")

    print("\nThe Dirac test and the full test always agree: the |G| Dirac identities")
    print("already certify the identity for all test functions.  And only the")
    print("subgroup/annihilator pairs pass -- a coset that is not a subgroup fails.")


# ---------------------------------------------------------------------------
# Demonstration 7: the extremal class is closed under products and convolutions
# ---------------------------------------------------------------------------


def demo_algebra_closure() -> None:
    banner("7. Products and convolutions of extremals are zero or extremal")
    group: Group = (12,)
    subs = all_subgroups(group)
    import random

    random.seed(1234)

    pairs = 0
    prod_zero = 0
    conv_zero = 0
    prod_ok = 0
    conv_ok = 0
    for _ in range(60):
        k1 = random.choice(subs)
        k2 = random.choice(subs)
        u = coset_modulation(
            group, k1, random.choice(elements(group)),
            random.choice(elements(group)), complex(random.uniform(0.5, 2))
        )
        v = coset_modulation(
            group, k2, random.choice(elements(group)),
            random.choice(elements(group)), complex(0, random.uniform(0.5, 2))
        )
        pairs += 1

        w = pointwise(u, v)
        if not support(w):
            prod_zero += 1
        elif is_extremal(group, w):
            prod_ok += 1

        z = convolve(group, u, v)
        if not support(z):
            conv_zero += 1
        elif is_extremal(group, z):
            conv_ok += 1

    print(f"random extremal pairs tested on Z/12   : {pairs}")
    print(f"pointwise products: zero {prod_zero:>3}, extremal {prod_ok:>3},"
          f" other {pairs - prod_zero - prod_ok:>3}")
    print(f"convolutions      : zero {conv_zero:>3}, extremal {conv_ok:>3},"
          f" other {pairs - conv_zero - conv_ok:>3}")

    # convolution powers preserve the support size exactly
    k_sub = subgroup_generated(group, [(4,)])
    f = coset_modulation(group, k_sub, (1,), (3,), 1 + 0j)
    g = dict(f)
    sizes = [len(support(g))]
    for _ in range(4):
        g = convolve(group, f, g)
        sizes.append(len(support(g)))
    print(f"\nconvolution powers of a fixed extremal: support sizes {sizes}"
          " (conserved)")


# ---------------------------------------------------------------------------
# Demonstration 8: extremal probability distributions
# ---------------------------------------------------------------------------


def demo_extremal_distributions() -> None:
    banner("8. Extremal probability distributions are uniform on cosets")
    group: Group = (12,)
    n = order(group)
    print(f"G = Z/12.  All minimum-uncertainty distributions on G:\n")
    print(f"{'support':<34}{'p on support':>14}{'|supp p||supp phat|':>22}")
    print("-" * 72)
    for k_sub in all_subgroups(group):
        for a in [(0,), (1,)]:
            cos = sorted(add(group, a, k) for k in k_sub)
            p: Func = {
                x: (complex(1.0 / len(k_sub)) if x in set(cos) else 0j)
                for x in elements(group)
            }
            label = "{" + ",".join(str(x[0]) for x in cos) + "}"
            if len(label) > 32:
                label = label[:29] + "...}"
            print(f"{label:<34}{1.0 / len(k_sub):>14.4f}"
                  f"{uncertainty_product(group, p):>22}")
            if len(k_sub) in (1, n):
                break

    print("\nA non-uniform distribution on a coset, and a distribution on 5 atoms:")
    k_sub = subgroup_generated(group, [(4,)])  # {0,4,8}
    skew: Func = {x: 0j for x in elements(group)}
    for x, w in zip(sorted(k_sub), [0.5, 0.3, 0.2]):
        skew[x] = complex(w)
    print(f"  skewed on {{0,4,8}} (weights .5/.3/.2): product = "
          f"{uncertainty_product(group, skew)} > 12")
    five: Func = {x: 0j for x in elements(group)}
    for x in [(0,), (1,), (2,), (3,), (4,)]:
        five[x] = complex(0.2)
    print(f"  uniform on 5 atoms (5 does not divide 12): product = "
          f"{uncertainty_product(group, five)} >= 15")


# ---------------------------------------------------------------------------
# Demonstration 9: the spectrum sees only the order; the supports see more
# ---------------------------------------------------------------------------


def demo_order_four_separation() -> None:
    banner("9. Z/4 versus Z/2 x Z/2: same spectrum, different extremal supports")
    for group in [(4,), (2, 2)]:
        els = elements(group)
        cosets_of_size_two = set()
        for s in itertools.combinations(els, 2):
            ss = set(s)
            if is_parallelogram_closed(group, ss):
                cosets_of_size_two.add(frozenset(ss))
        spectrum = sorted({len(k) for k in all_subgroups(group)})
        name = " x ".join(f"Z/{m}" for m in group)
        print(f"{name:<14} spectrum {spectrum}    extremal supports of size 2: "
              f"{len(cosets_of_size_two)}")
        for c in sorted(cosets_of_size_two, key=lambda t: sorted(t)):
            print(f"                 {sorted(c)}")
    print("\nSame spectrum {1,2,4}; but 2 extremal supports of size 2 on Z/4 and 6 on")
    print("the Klein group -- the supports form a strictly finer invariant.")


# ---------------------------------------------------------------------------


def main() -> None:
    print(__doc__)
    demo_coset_modulations_are_extremal()
    demo_exhaustive_z4()
    demo_extremal_spectrum()
    demo_uncertainty_gap()
    demo_structure_extraction()
    demo_poisson_rigidity()
    demo_algebra_closure()
    demo_extremal_distributions()
    demo_order_four_separation()
    print()
    print("=" * 78)
    print("All demonstrations completed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
