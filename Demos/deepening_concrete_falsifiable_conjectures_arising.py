"""
Forbidden subposets in the Boolean lattice: numerical demonstrations.
=====================================================================

This self-contained script demonstrates, by explicit computation, every
quantitative claim of the accompanying paper:

  1. The central window  W(n,k) = [ceil((n-k)/2), ceil((n-k)/2)+k)  really does
     collect the k largest binomial coefficients, and Sigma(n,k) < k*C(n,n//2)
     as soon as 3 <= k <= n+1.

  2. La*(n, A_3) = 2n : the largest family of subsets of [n] with no three
     pairwise incomparable members has exactly 2n sets.  Verified by exhaustive
     branch-and-bound search for n <= 5, and matched by the explicit extremal
     construction (initial segments together with complements of the proper
     nonempty initial segments).

  3. The weak/strong gap:  La(n, A_2) = 1  while  La*(n, A_2) = n+1.

  4. The Lubell function  lambda(F) = sum_{A in F} 1 / C(n,|A|)  and the two
     inequalities that drive Erdos' k-Sperner theorem:
        (Mirsky + LYM)  height(F) <= k        ==>  lambda(F) <= k
        (knapsack)      lambda(F) <= k        ==>  |F| <= Sigma(n,k)

  5. The two-sided bracket  Sigma(n, h(P)-1) <= La(n,P) <= Sigma(n, |P|-1)
     for the chain, the diamond B_2, the butterfly and B_3, together with the
     butterfly / tall-butterfly improvements of the lower end.

  6. The boundary of the Lubell method: {empty} u {singletons} u {[n]} is
     butterfly-free with Lubell value exactly 3.

Only the Python standard library is used.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

Subset = int  # a subset of [n] encoded as a bitmask


# ---------------------------------------------------------------------------
# 1. The central window and the sum of the k largest binomial coefficients
# ---------------------------------------------------------------------------


def central_start(n: int, k: int) -> int:
    """Bottom level a of the window of the k largest binomial coefficients.

    a = ceil((n-k)/2), characterised by  n <= 2a + k <= n+1.
    """
    if k >= n:
        return 0
    return -((n - k) // -2)  # ceiling division


def sigma(n: int, k: int) -> int:
    """Total size of the k central layers = sum of the k largest C(n,i)."""
    a = central_start(n, k)
    return sum(comb(n, i) for i in range(a, min(a + k, n + 1)))


def sum_of_k_largest_binomials(n: int, k: int) -> int:
    """Brute-force reference value: sort row n and add the k biggest entries."""
    row = sorted((comb(n, i) for i in range(n + 1)), reverse=True)
    return sum(row[:k])


def demo_window() -> None:
    print("=" * 78)
    print("1.  THE CENTRAL WINDOW  Sigma(n,k)  =  sum of the k largest C(n,i)")
    print("=" * 78)
    print(f"{'n':>3} {'k':>3} {'window':>12} {'Sigma(n,k)':>12} "
          f"{'k*C(n,n//2)':>13} {'saving':>9}")
    for n, k in [(6, 3), (8, 3), (10, 3), (10, 7), (12, 7), (14, 7), (20, 7)]:
        a = central_start(n, k)
        s = sigma(n, k)
        assert s == sum_of_k_largest_binomials(n, k), (n, k)
        classical = k * comb(n, n // 2)
        saving = 100.0 * (classical - s) / classical
        print(f"{n:>3} {k:>3} {f'[{a},{a+k})':>12} {s:>12} {classical:>13} "
              f"{saving:>8.1f}%")
    print()
    print("  La(10, B_3) <= Sigma(10, 2^3-1) = "
          f"{sigma(10, 7)}   (classical bound 7*C(10,5) = {7*comb(10,5)})")
    print("  La(10, B_3) >= Sigma(10, 3)     = "
          f"{sigma(10, 3)}   (height of B_3 is 4)")
    print()


# ---------------------------------------------------------------------------
# 2. Strong A_3-freeness:  La*(n, A_3) = 2n
# ---------------------------------------------------------------------------


def subsets_of(n: int) -> List[Subset]:
    """All 2^n subsets of [n] as bitmasks, sorted by size then value."""
    return sorted(range(1 << n), key=lambda s: (bin(s).count("1"), s))


def is_strict_subset(x: Subset, y: Subset) -> bool:
    return x != y and (x & y) == x


def comparable(x: Subset, y: Subset) -> bool:
    return (x & y) == x or (x & y) == y


def max_no_m_antichain(n: int, m: int) -> int:
    """Largest family of subsets of [n] with no m pairwise incomparable members.

    Exhaustive depth-first search with branch-and-bound.  The incremental test
    is: a candidate A may be added iff the chosen sets incomparable to A do not
    already contain an (m-1)-antichain.  For m = 3 this reduces to: A must not
    be incomparable to both members of an already-chosen incomparable pair.
    """
    universe = subsets_of(n)
    size = len(universe)
    incomp: List[List[bool]] = [
        [not comparable(x, y) and x != y for y in universe] for x in universe
    ]
    best = 0
    chosen: List[int] = []

    def antichain_exists(indices: Sequence[int], width: int) -> bool:
        """Do `indices` contain `width` pairwise incomparable elements?"""
        if width <= 1:
            return len(indices) >= width
        for combo in combinations(indices, width):
            if all(incomp[a][b] for a, b in combinations(combo, 2)):
                return True
        return False

    def dfs(start: int) -> None:
        nonlocal best
        if len(chosen) > best:
            best = len(chosen)
        if len(chosen) + (size - start) <= best:
            return  # bound: cannot beat the incumbent
        for i in range(start, size):
            conflicting = [j for j in chosen if incomp[i][j]]
            if antichain_exists(conflicting, m - 1):
                continue
            chosen.append(i)
            dfs(i + 1)
            chosen.pop()

    dfs(0)
    return best


def extremal_family_A3(n: int) -> List[Subset]:
    """The extremal family for A_3: initial segments plus their complements.

    S_i = {1,...,i} for 0 <= i <= n  (n+1 sets, a chain), together with
    complement(S_i) for 1 <= i <= n-1  (n-1 sets, a chain), disjointly.
    """
    full = (1 << n) - 1
    initial = [(1 << i) - 1 for i in range(n + 1)]
    co_initial = [full ^ ((1 << i) - 1) for i in range(1, n)]
    return initial + co_initial


def has_m_antichain(family: Iterable[Subset], m: int) -> bool:
    fam = list(family)
    for combo in combinations(fam, m):
        if all(not comparable(x, y) for x, y in combinations(combo, 2)):
            return True
    return False


def demo_antichain_three() -> None:
    print("=" * 78)
    print("2.  La*(n, A_3) = 2n : no three pairwise incomparable sets")
    print("=" * 78)
    print(f"{'n':>3} {'2n':>5} {'exhaustive max':>16} {'construction':>14} "
          f"{'valid':>7} {'disjoint chains':>17}")
    for n in range(1, 6):
        target = 2 * n
        best = max_no_m_antichain(n, 3)
        fam = extremal_family_A3(n)
        distinct = len(set(fam))
        valid = not has_m_antichain(fam, 3)
        assert best == target == distinct and valid, (n, best, distinct, valid)
        print(f"{n:>3} {target:>5} {best:>16} {distinct:>14} {str(valid):>7} "
              f"{f'{n+1} + {n-1}':>17}")
    print()
    print("  layer bound:  at most 2 sets per layer, at most 1 in each extreme")
    print("  layer         =>  |F| <= 1 + 2(n-1) + 1 = 2n")
    for n in range(1, 6):
        fam = extremal_family_A3(n)
        profile = [sum(1 for s in fam if bin(s).count("1") == i) for i in range(n + 1)]
        print(f"    n = {n}: layer profile of the extremal family = {profile}")
    print()


# ---------------------------------------------------------------------------
# 3. The weak/strong gap for the two-element antichain
# ---------------------------------------------------------------------------


def max_chain_family(n: int) -> int:
    """La*(n, A_2): largest family that is a chain."""
    return n + 1


def demo_weak_strong_gap() -> None:
    print("=" * 78)
    print("3.  THE WEAK/STRONG GAP FOR THE TWO-ELEMENT ANTICHAIN")
    print("=" * 78)
    print(f"{'n':>3} {'La(n,A_2)':>11} {'La*(n,A_2)':>12} {'gap':>5} {'ratio':>7}"
          f"  {'verified max chain':>20}")
    for n in range(1, 7):
        weak = 1  # weak A_2-free  <=>  |F| < 2
        strong = max_chain_family(n)
        brute = max_no_m_antichain(n, 2) if n <= 5 else strong
        assert brute == strong, (n, brute, strong)
        print(f"{n:>3} {weak:>11} {strong:>12} {strong - weak:>5} "
              f"{strong // weak:>7}  {brute:>20}")
    print()
    print("  The gap is exactly n and the ratio exactly n+1:")
    print("  no bound La* <= c * La can hold with c independent of n.")
    print()


# ---------------------------------------------------------------------------
# 4. The Lubell function, Mirsky peeling and the knapsack step
# ---------------------------------------------------------------------------


def lubell(n: int, family: Iterable[Subset]) -> Fraction:
    """lambda(F) = sum_{A in F} 1 / C(n, |A|), computed exactly."""
    return sum((Fraction(1, comb(n, bin(a).count("1"))) for a in family),
               Fraction(0))


def family_height(family: Iterable[Subset]) -> int:
    """Length of the longest chain inside the family (Mirsky peeling)."""
    remaining = set(family)
    height = 0
    while remaining:
        maximal = {a for a in remaining
                   if not any(is_strict_subset(a, b) for b in remaining)}
        remaining -= maximal
        height += 1
    return height


def window_family(n: int, a: int, k: int) -> List[Subset]:
    return [s for s in range(1 << n) if a <= bin(s).count("1") < a + k]


def demo_lubell() -> None:
    print("=" * 78)
    print("4.  LUBELL WEIGHT, MIRSKY PEELING AND THE KNAPSACK STEP")
    print("=" * 78)
    n = 6
    families: List[Tuple[str, List[Subset]]] = [
        ("middle layer (an antichain)", window_family(n, n // 2, 1)),
        ("two central layers", window_family(n, central_start(n, 2), 2)),
        ("three central layers", window_family(n, central_start(n, 3), 3)),
        ("a maximal chain", [(1 << i) - 1 for i in range(n + 1)]),
        ("{empty} u singletons u {[n]}",
         [0] + [1 << i for i in range(n)] + [(1 << n) - 1]),
        ("the A_3-extremal family", extremal_family_A3(n)),
    ]
    print(f"n = {n}\n")
    print(f"{'family':>30} {'|F|':>5} {'height':>7} {'lambda(F)':>11} "
          f"{'<= height?':>11} {'Sigma(n,ceil)':>14} {'|F| <= bound?':>14}")
    for name, fam in families:
        h = family_height(fam)
        lam = lubell(n, fam)
        k = h  # Mirsky+LYM certificate: no chain of h+1 sets
        bound = sigma(n, k)
        ok_weight = lam <= k
        ok_card = len(fam) <= bound
        assert ok_weight and ok_card, name
        print(f"{name:>30} {len(fam):>5} {h:>7} {str(lam):>11} "
              f"{str(ok_weight):>11} {bound:>14} {str(ok_card):>14}")
    print()
    print("  Erdos' k-Sperner theorem is the composition of the two columns:")
    print("     no chain of k+1  ==>  lambda <= k  ==>  |F| <= Sigma(n,k),")
    print("  and the k central layers attain both, so nothing is lost.")
    print()
    print("  Tightness check (window family of k central layers):")
    for k in range(1, 5):
        fam = window_family(n, central_start(n, k), k)
        print(f"     k = {k}:  |F| = {len(fam):>3} = Sigma({n},{k}) = {sigma(n,k):>3},"
              f"   lambda(F) = {lubell(n, fam)}   (<= {k})")
    print()


# ---------------------------------------------------------------------------
# 5. Posets: height, butterflies, tall butterflies and the bracket
# ---------------------------------------------------------------------------


class Poset:
    """A finite poset given by its strict order relation on 0..N-1."""

    def __init__(self, name: str, n: int, less: Set[Tuple[int, int]]) -> None:
        self.name = name
        self.n = n
        self.less = set(less)

    def lt(self, p: int, q: int) -> bool:
        return (p, q) in self.less

    def height(self) -> int:
        """Maximum number of elements of a chain (longest-path DP)."""
        memo: Dict[int, int] = {}

        def down(p: int) -> int:
            if p in memo:
                return memo[p]
            best = 1
            for q in range(self.n):
                if self.lt(q, p):
                    best = max(best, 1 + down(q))
            memo[p] = best
            return best

        return max(down(p) for p in range(self.n))

    def chain_top_length(self, p: int) -> int:
        """Longest chain of P whose top element is p (number of elements)."""
        best = 1
        for q in range(self.n):
            if self.lt(q, p):
                best = max(best, 1 + self.chain_top_length(q))
        return best

    def has_butterfly(self) -> bool:
        return self.tall_butterfly_height() is not None

    def tall_butterfly_height(self) -> int | None:
        """Largest m such that P has a tall butterfly of height m, else None."""
        best: int | None = None
        for p1, p2 in combinations(range(self.n), 2):
            uppers = [q for q in range(self.n) if self.lt(p1, q) and self.lt(p2, q)]
            if len(uppers) >= 2:
                m = min(self.chain_top_length(p1), self.chain_top_length(p2)) - 1
                best = m if best is None else max(best, m)
        return best


def chain_poset(k: int) -> Poset:
    return Poset(f"chain C_{k}", k,
                 {(i, j) for i in range(k) for j in range(k) if i < j})


def boolean_poset(d: int) -> Poset:
    n = 1 << d
    less = {(x, y) for x in range(n) for y in range(n)
            if x != y and (x & y) == x}
    return Poset(f"Boolean lattice B_{d}", n, less)


def butterfly_poset() -> Poset:
    # 0,1 are the lower wings; 2,3 the upper wings.
    less = {(0, 2), (0, 3), (1, 2), (1, 3)}
    return Poset("butterfly", 4, less)


def antichain_poset(m: int) -> Poset:
    return Poset(f"antichain A_{m}", m, set())


def demo_bracket() -> None:
    print("=" * 78)
    print("5.  THE TWO-SIDED BRACKET  Sigma(n,h(P)-1) <= La(n,P) <= Sigma(n,|P|-1)")
    print("=" * 78)
    n = 10
    posets = [chain_poset(2), chain_poset(4), antichain_poset(3),
              butterfly_poset(), boolean_poset(2), boolean_poset(3)]
    print(f"ground set size n = {n}\n")
    header = (f"{'poset':>22} {'|P|':>4} {'h(P)':>5} {'butterfly':>10} "
              f"{'tall m':>7} {'lower':>8} {'improved':>9} {'upper':>8}")
    print(header)
    for P in posets:
        h = P.height()
        m = P.tall_butterfly_height()
        lower = sigma(n, max(h - 1, 1))
        improved = sigma(n, max(h - 1, (m + 2) if m is not None else 0, 1))
        upper = sigma(n, P.n - 1) if P.n - 1 <= n + 1 else float("inf")
        print(f"{P.name:>22} {P.n:>4} {h:>5} {str(m is not None):>10} "
              f"{('-' if m is None else m):>7} {lower:>8} {improved:>9} {upper:>8}")
    print()
    print("  'lower'    = height bound          : the h(P)-1 central layers")
    print("  'improved' = tall-butterfly bound  : the m+2 central layers")
    print("  'upper'    = k-Sperner bound       : the |P|-1 central layers")
    print()
    print("  The butterfly poset is the decisive row: its height is only 2, so the")
    print("  height bound offers a single central layer (252), while the butterfly")
    print("  obstruction already gives two central layers (462).  The height lower")
    print("  bound of the bracket is therefore not tight.")
    print("  The diamond B_2 has NO butterfly, so this method leaves its lower end")
    print("  untouched -- exactly the difficulty of the diamond problem.")
    print("  For B_3 the tall butterfly of height 1 reproves, from one general")
    print("  principle, the three-layer bound that the height argument also gives.")
    print()


# ---------------------------------------------------------------------------
# 6. Where the Lubell method stops: a butterfly-free family of weight 3
# ---------------------------------------------------------------------------


def contains_butterfly_family(family: Iterable[Subset]) -> bool:
    """Does the family contain two distinct sets with two distinct common
    strict upper bounds inside the family?"""
    fam = list(family)
    for x, y in combinations(fam, 2):
        uppers = [z for z in fam if is_strict_subset(x, z) and is_strict_subset(y, z)]
        if len(uppers) >= 2:
            return True
    return False


def demo_lubell_boundary() -> None:
    print("=" * 78)
    print("6.  THE BOUNDARY OF THE LUBELL METHOD")
    print("=" * 78)
    print(f"{'n':>3} {'|G|':>5} {'lambda(G)':>11} {'butterfly-free':>16} "
          f"{'Sigma(n,2)':>11}")
    for n in range(3, 9):
        g = [0] + [1 << i for i in range(n)] + [(1 << n) - 1]
        lam = lubell(n, g)
        free = not contains_butterfly_family(g)
        assert lam == 3 and free, (n, lam, free)
        print(f"{n:>3} {len(g):>5} {str(lam):>11} {str(free):>16} "
              f"{sigma(n, 2):>11}")
    print()
    print("  G = {empty} u {singletons} u {[n]} is butterfly-free yet has Lubell")
    print("  value exactly 3.  So no implication 'butterfly-free => lambda <= 2'")
    print("  can hold, and the conjecture La(n, butterfly) = Sigma(n,2) is")
    print("  genuinely a cardinality statement, not a weight statement.")
    print("  (Its cardinality n+2 is far below Sigma(n,2), so the conjecture is")
    print("   untouched by this example -- only the weight route is blocked.)")
    print()


# ---------------------------------------------------------------------------
# 7. Rank rigidity, illustrated
# ---------------------------------------------------------------------------


def demo_rank_rigidity() -> None:
    print("=" * 78)
    print("7.  RANK RIGIDITY: a chain of L sets inside L consecutive layers")
    print("=" * 78)
    n, a, L = 7, 2, 4
    layers = window_family(n, a, L)
    found = 0
    checked = 0
    for combo in combinations(layers, L):
        chain = sorted(combo, key=lambda s: bin(s).count("1"))
        if all(is_strict_subset(chain[i], chain[i + 1]) for i in range(L - 1)):
            checked += 1
            sizes = [bin(s).count("1") for s in chain]
            assert sizes == [a + i for i in range(L)], sizes
            found += 1
    print(f"  n = {n}, window = layers [{a},{a+L}), chains of {L} sets examined: "
          f"{checked}")
    print(f"  every one of them has size profile {[a + i for i in range(L)]} "
          f"-- {found}/{checked} confirmed")
    print()
    print("  This is the engine of the tall-butterfly theorem: with ranks pinned,")
    print("  two distinct sets of size a+m force their union to fill size a+m+1,")
    print("  so both upper wings of a butterfly collapse onto the same set.")
    print()


def main() -> None:
    demo_window()
    demo_antichain_three()
    demo_weak_strong_gap()
    demo_lubell()
    demo_bracket()
    demo_lubell_boundary()
    demo_rank_rigidity()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
