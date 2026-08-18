"""
Trace distributions of finite group actions
===========================================

Numerical demonstration of the following facts, for a finite group G acting on a
finite set X:

    trace distribution   tr(X) = {| |X^g| : g in G |}   (a multiset, |G| entries)
    orbit spectrum       N_k(X) = # G-orbits on ordered k-tuples from X

  (1) GRADED BURNSIDE LEMMA
          N_k(X) * |G| = sum_{g in G} |X^g|^k = p_k( tr(X) )
      i.e. the orbit spectrum is the sequence of power sums of tr(X).

  (2) MAIN THEOREM
          tr(X) = tr(Y)  <=>  N_k(X) = N_k(Y) for all k <= max(|X|,|Y|)
      and then automatically for ALL k (rigidity of the orbit spectrum).

  (3) GROUP-ORDER THRESHOLD
          tr(X) = tr(Y)  <=>  N_k(X) = N_k(Y) for all k < 2|G|,
      independent of the sizes of X and Y.

  (4) SHARPNESS
      * alternating binomial pair (A_n, B_n): distinct multisets with values in
        {0..n} whose power sums agree for all k < n and differ at k = n by n!.
      * regular G-set vs one-point G-set: N_0 and N_1 agree for every G, but
        N_2 differs whenever |G| >= 2, so a "k <= 1" theorem is impossible.

  (5) RECONSTRUCTION
      Lagrange / Vandermonde inversion recovers the whole fixed-point histogram
      from the first |X|+1 orbit counts.

Self-contained: standard library only.  Run with `python demo.py`.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations, product
from math import comb, factorial
from typing import Dict, List, Sequence, Tuple

Perm = Tuple[int, ...]  # a permutation of {0,...,n-1} given as an image tuple


# ----------------------------------------------------------------------------
# Permutation-group plumbing
# ----------------------------------------------------------------------------

def fixed_count(p: Perm) -> int:
    """|X^g| for the permutation g = p acting on X = {0,...,degree-1}."""
    return sum(1 for x, y in enumerate(p) if x == y)


# ----------------------------------------------------------------------------
# The two invariants
# ----------------------------------------------------------------------------

def trace_distribution(group: Sequence[Perm]) -> List[int]:
    """The multiset {| |X^g| : g in G |}, returned as a sorted list of |G| entries."""
    return sorted(fixed_count(g) for g in group)


def trace_histogram(group: Sequence[Perm], degree: int) -> List[int]:
    """Coefficient vector of the q-series Z_X(q) = sum_g q^{|X^g|}: entry m is
    the number of group elements fixing exactly m points."""
    hist = [0] * (degree + 1)
    for g in group:
        hist[fixed_count(g)] += 1
    return hist


def power_sum(multiset: Sequence[int], k: int) -> int:
    """p_k(A) = sum_{a in A} a^k, with the convention 0^0 = 1."""
    return sum(1 if (a == 0 and k == 0) else a ** k for a in multiset)


def orbit_count_burnside(group: Sequence[Perm], k: int) -> int:
    """N_k(X) via the graded Burnside lemma: (1/|G|) * sum_g |X^g|^k.

    Cost O(|G|) big-integer powers -- independent of the number n^k of tuples.
    """
    total = sum(1 if (fixed_count(g) == 0 and k == 0) else fixed_count(g) ** k
                for g in group)
    assert total % len(group) == 0, "graded Burnside must give an exact division"
    return total // len(group)


def orbit_count_bruteforce(group: Sequence[Perm], degree: int, k: int) -> int:
    """N_k(X) by literally enumerating the n^k tuples and merging orbits.

    Exponential; used only to certify `orbit_count_burnside` on small inputs.
    """
    seen: set = set()
    count = 0
    for tup in product(range(degree), repeat=k):
        if tup in seen:
            continue
        count += 1
        for g in group:
            seen.add(tuple(g[x] for x in tup))
    return count


# ----------------------------------------------------------------------------
# Power-sum rigidity: reconstruction by Lagrange / Vandermonde inversion
# ----------------------------------------------------------------------------

def lagrange_weights(nodes: Sequence[int], j0: int) -> List[Fraction]:
    """Coefficients lambda_k of the Lagrange basis polynomial L_{j0}(x) =
    prod_{j != j0} (x-j)/(j0-j) = sum_k lambda_k x^k."""
    coeffs: List[Fraction] = [Fraction(1)]
    for j in nodes:
        if j == j0:
            continue
        denom = Fraction(j0 - j)
        # multiply current polynomial by (x - j)/denom
        shifted = [Fraction(0)] + coeffs           # x * coeffs
        scaled = [c * (-j) for c in coeffs] + [Fraction(0)]
        coeffs = [(a + b) / denom for a, b in zip(shifted, scaled)]
    return coeffs


def reconstruct_multiplicities(power_sums: Sequence[int],
                               nodes: Sequence[int]) -> List[int]:
    """Given p_0,...,p_{n} of a multiset supported inside `nodes`, recover the
    multiplicity of each node.  This is the effective form of the vanishing
    lemma: apply the dual functional given by the Lagrange basis polynomial."""
    out: List[int] = []
    for j0 in nodes:
        lam = lagrange_weights(nodes, j0)
        value = sum(l * p for l, p in zip(lam, power_sums))
        assert value.denominator == 1, "multiplicity must be an integer"
        out.append(int(value))
    return out


# ----------------------------------------------------------------------------
# The alternating binomial extremal pair
# ----------------------------------------------------------------------------

def binom_pair(n: int) -> Tuple[List[int], List[int]]:
    """(A_n, B_n): the positive and negative parts of the n-th finite-difference
    measure, as multisets on {0,...,n}, each returned as a sorted list."""
    a: List[int] = []
    b: List[int] = []
    for k in range(n + 1):
        target = a if (n - k) % 2 == 0 else b
        target.extend([k] * comb(n, k))
    return sorted(a), sorted(b)


# ----------------------------------------------------------------------------
# Example G-sets
# ----------------------------------------------------------------------------

def cyclic_group(n: int) -> List[Perm]:
    """Z/n acting on itself by translation (the regular action)."""
    return [tuple((x + s) % n for x in range(n)) for s in range(n)]


def symmetric_group(n: int) -> List[Perm]:
    """S_n in its natural action on n points."""
    return [tuple(p) for p in permutations(range(n))]


def trivial_action(order: int) -> List[Perm]:
    """A group of the given order acting trivially on 1 point."""
    return [(0,)] * order


def z4_on_four_points() -> List[Perm]:
    """Z/4 acting on X = (Z/4 mod {0,2}) + point + point, four points total:
    points 0,1 form the 2-element transitive piece; 2 and 3 are fixed."""
    out = []
    for s in range(4):
        img = [(x + s) % 2 for x in range(2)] + [2, 3]
        out.append(tuple(img))
    return out


def z4_on_two_plus_two() -> List[Perm]:
    """Z/4 acting on two copies of the 2-element transitive Z/4-set."""
    out = []
    for s in range(4):
        img = [(x + s) % 2 for x in range(2)] + [2 + (x + s) % 2 for x in range(2)]
        out.append(tuple(img))
    return out


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------

def banner(text: str) -> None:
    print()
    print("=" * 78)
    print(text)
    print("=" * 78)


def q_series_string(hist: Sequence[int]) -> str:
    parts = []
    for m, c in enumerate(hist):
        if c == 0:
            continue
        if m == 0:
            parts.append(f"{c}")
        elif c == 1:
            parts.append(f"q^{m}")
        else:
            parts.append(f"{c}q^{m}")
    return " + ".join(parts) if parts else "0"


def describe(name: str, group: Sequence[Perm], degree: int, kmax: int = 6) -> None:
    td = trace_distribution(group)
    hist = trace_histogram(group, degree)
    spec = [orbit_count_burnside(group, k) for k in range(kmax + 1)]
    print(f"{name}")
    print(f"  |G| = {len(group)},  |X| = {degree}")
    print(f"  trace distribution  tr(X) = {td}")
    print(f"  q-series            Z_X(q) = {q_series_string(hist)}")
    print(f"  orbit spectrum      N_0..N_{kmax} = {spec}")


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_graded_burnside() -> None:
    banner("1. GRADED BURNSIDE:  N_k(X) * |G| = sum_g |X^g|^k")
    cases: List[Tuple[str, List[Perm], int]] = [
        ("Z/2 regular on 2 points", cyclic_group(2), 2),
        ("Z/3 regular on 3 points", cyclic_group(3), 3),
        ("Z/4 on 2+1+1 points", z4_on_four_points(), 4),
        ("S_3 natural on 3 points", symmetric_group(3), 3),
        ("S_4 natural on 4 points", symmetric_group(4), 4),
    ]
    for name, group, degree in cases:
        td = trace_distribution(group)
        print(f"\n{name}:  tr(X) = {td}")
        print("   k | N_k (Burnside) | N_k (brute force) | p_k(tr) | N_k*|G|")
        for k in range(0, 5):
            nb = orbit_count_burnside(group, k)
            bf = orbit_count_bruteforce(group, degree, k) if degree ** k <= 20000 else None
            pk = power_sum(td, k)
            bfs = str(bf) if bf is not None else "  (skipped)"
            ok = "OK" if (bf is None or bf == nb) else "MISMATCH"
            assert bf is None or bf == nb
            assert nb * len(group) == pk
            print(f"   {k} | {nb:14d} | {bfs:>17} | {pk:7d} | {nb*len(group):7d}  {ok}")


def demo_main_theorem() -> None:
    banner("2. MAIN THEOREM AND RIGIDITY:  regular Z/2-set  vs  one-point Z/2-set")
    X, dX = cyclic_group(2), 2
    Y, dY = trivial_action(2), 1
    describe("X = Z/2 acting on itself by translation", X, dX, kmax=6)
    print()
    describe("Y = Z/2 acting trivially on one point", Y, dY, kmax=6)

    M = max(dX, dY)
    print(f"\n  theoretical window: k <= max(|X|,|Y|) = {M}")
    for k in range(0, M + 3):
        nx, ny = orbit_count_burnside(X, k), orbit_count_burnside(Y, k)
        tag = "agree" if nx == ny else "DIFFER  <-- first separation"
        print(f"    k = {k}:  N_k(X) = {nx:5d},  N_k(Y) = {ny:5d}   {tag}")
        if nx != ny:
            print(f"    separation occurs at k = {k} <= {M}, as the theorem allows.")
            break
    print("\n  N_0 and N_1 agree: Burnside's lemma alone is blind.")
    print("  So no theorem with range k <= 1 can be true.")


def demo_group_order_threshold() -> None:
    banner("3. GROUP-ORDER THRESHOLD 2|G| BEATS max(|X|,|Y|)+1 FOR BIG SETS")
    n = 2000
    # Z/2 acting on n points: an involution with `f` fixed points.
    def involution_with_fixed(n: int, fixed: int) -> List[Perm]:
        img = list(range(n))
        movable = list(range(fixed, n))
        for i in range(0, len(movable) - 1, 2):
            a, b = movable[i], movable[i + 1]
            img[a], img[b] = b, a
        return [tuple(range(n)), tuple(img)]

    X = involution_with_fixed(n, 0)
    Y = involution_with_fixed(n, 2)
    print(f"  X: Z/2 on {n} points, non-identity element fixes {fixed_count(X[1])}")
    print(f"  Y: Z/2 on {n} points, non-identity element fixes {fixed_count(Y[1])}")
    print(f"  naive window  max(|X|,|Y|)+1 = {n+1}")
    print(f"  group window  2|G|           = {2*len(X)}")
    for k in range(0, 2 * len(X)):
        nx, ny = orbit_count_burnside(X, k), orbit_count_burnside(Y, k)
        print(f"    k = {k}:  N_k(X) = {nx},  N_k(Y) = {ny}   "
              f"{'agree' if nx == ny else 'DIFFER'}")
    print("  The two are separated inside k < 4 -- no need to look at 2000-tuples.")


def demo_sharpness_binomial() -> None:
    banner("4. SHARPNESS: the alternating binomial pair (A_n, B_n)")
    for n in range(1, 7):
        A, B = binom_pair(n)
        agree = all(power_sum(A, k) == power_sum(B, k) for k in range(n))
        gap = power_sum(A, n) - power_sum(B, n)
        support = sorted(set(A) | set(B))
        assert agree and A != B and gap == factorial(n)
        assert support == list(range(n + 1))
        print(f"\n  n = {n}")
        print(f"    A_n = {A}")
        print(f"    B_n = {B}")
        print(f"    |A_n| = |B_n| = {len(A)} = 2^(n-1)")
        print(f"    power sums p_0..p_{n-1} agree: {agree}")
        print(f"    p_{n}(A) - p_{n}(B) = {gap} = {n}! = {factorial(n)}")
        print(f"    joint support = {support}  (size {len(support)} = n+1)")
    print("\n  So n power sums never suffice for values bounded by n; n+1 always do.")


def demo_reconstruction() -> None:
    banner("5. RECONSTRUCTION: fixed-point histogram from the first |X|+1 orbit counts")
    cases: List[Tuple[str, List[Perm], int]] = [
        ("S_4 natural on 4 points", symmetric_group(4), 4),
        ("Z/4 on 2+1+1 points", z4_on_four_points(), 4),
        ("Z/4 on 2+2 points", z4_on_two_plus_two(), 4),
        ("Z/5 regular on 5 points", cyclic_group(5), 5),
    ]
    for name, group, degree in cases:
        m = len(group)
        nodes = list(range(degree + 1))
        # The observer sees only the orbit counts.
        observed = [orbit_count_burnside(group, k) for k in range(degree + 1)]
        power_sums = [nk * m for nk in observed]
        recovered = reconstruct_multiplicities(power_sums, nodes)
        truth = trace_histogram(group, degree)
        assert recovered == truth
        print(f"\n  {name}  (|G| = {m}, |X| = {degree})")
        print(f"    observed N_0..N_{degree}   = {observed}")
        print(f"    implied  p_0..p_{degree}   = {power_sums}")
        print(f"    recovered histogram      = {recovered}")
        print(f"    true histogram           = {truth}   -> match: "
              f"{recovered == truth}")
        print(f"    recovered Z_X(q)         = {q_series_string(recovered)}")


def demo_equal_spectra_nonisomorphic() -> None:
    banner("6. EQUAL SPECTRA, NON-ISOMORPHIC ACTIONS: the invariant is unordered")
    # The Klein four-group V = {e, a, b, ab}.  Consider two 4-point V-sets:
    #     X = V/<a>  +  V/<b>            Y = V/<a>  +  V/<ab>
    # They are NOT isomorphic as V-sets (the element acting without fixed points
    # is ab for X and b for Y), yet their MULTISETS of marks coincide.
    names = ["e", "a", "b", "ab"]

    def coset_action(kernel: str, elt: str) -> Tuple[int, int]:
        """Action of `elt` on the 2-point V-set V/<kernel>: identity or a swap."""
        trivial = {"e", kernel}
        return (0, 1) if elt in trivial else (1, 0)

    def two_block_action(k1: str, k2: str) -> Dict[str, Perm]:
        out: Dict[str, Perm] = {}
        for elt in names:
            p1 = coset_action(k1, elt)
            p2 = coset_action(k2, elt)
            out[elt] = (p1[0], p1[1], 2 + p2[0], 2 + p2[1])
        return out

    X = two_block_action("a", "b")
    Y = two_block_action("a", "ab")

    print("  X = V/<a> + V/<b>,   Y = V/<a> + V/<ab>   (both on 4 points)")
    print("\n  pointwise marks |Z^g|:")
    print("     g   :  " + "  ".join(f"{n:>3}" for n in names))
    print("     X   :  " + "  ".join(f"{fixed_count(X[n]):>3}" for n in names))
    print("     Y   :  " + "  ".join(f"{fixed_count(Y[n]):>3}" for n in names))

    gx, gy = list(X.values()), list(Y.values())
    tx, ty = trace_distribution(gx), trace_distribution(gy)
    print(f"\n  tr(X) = {tx}")
    print(f"  tr(Y) = {ty}      equal as multisets: {tx == ty}")
    print(f"  spectrum of X : {[orbit_count_burnside(gx,k) for k in range(7)]}")
    print(f"  spectrum of Y : {[orbit_count_burnside(gy,k) for k in range(7)]}")

    assert tx == ty
    assert [fixed_count(X[n]) for n in names] != [fixed_count(Y[n]) for n in names]
    assert all(orbit_count_burnside(gx, k) == orbit_count_burnside(gy, k)
               for k in range(12))
    print("\n  The pointwise mark functions DIFFER (so X and Y are not isomorphic")
    print("  V-sets), yet every orbit count agrees -- verified for k <= 11.")
    print("  The orbit spectrum sees the multiset of marks and nothing finer.")


def demo_q_series_functoriality() -> None:
    banner("7. FUNCTORIALITY: marks add on disjoint unions, multiply on products")
    G = cyclic_group(4)          # Z/4 regular on 4 points
    H = z4_on_four_points()      # Z/4 on 2+1+1 points
    mg = [fixed_count(g) for g in G]
    mh = [fixed_count(g) for g in H]
    print(f"  marks of X (Z/4 regular)   : {mg}")
    print(f"  marks of Y (Z/4 on 2+1+1)  : {mh}")
    print(f"  marks of X + Y (disjoint)  : {[x + y for x, y in zip(mg, mh)]}")
    print(f"  marks of X x Y (product)   : {[x * y for x, y in zip(mg, mh)]}")
    # Spectrum of the disjoint union, computed straight from the marks.
    sum_marks = [x + y for x, y in zip(mg, mh)]
    prod_marks = [x * y for x, y in zip(mg, mh)]
    for label, marks in (("X + Y", sum_marks), ("X x Y", prod_marks)):
        spec = [sum(1 if (m == 0 and k == 0) else m ** k for m in marks) // len(G)
                for k in range(6)]
        print(f"  spectrum of {label}: {spec}")


def main() -> None:
    print(__doc__)
    demo_graded_burnside()
    demo_main_theorem()
    demo_group_order_threshold()
    demo_sharpness_binomial()
    demo_reconstruction()
    demo_equal_spectra_nonisomorphic()
    demo_q_series_functoriality()
    banner("ALL CHECKS PASSED")


if __name__ == "__main__":
    main()
