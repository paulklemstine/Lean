"""
Numerical companion to
"Antichains, Height, and the Strict Growth of Boolean-Lattice Extremal Numbers".

Everything here is self-contained: subsets of the ground set [n] = {0, ..., n-1}
are encoded as integer bitmasks, families of subsets are Python frozensets of
bitmasks, and the Boolean lattice B_d is the family of all bitmasks on d atoms.

The script demonstrates, by exhaustive computation on small ground sets:

  1. weak / strong copies of B_d inside a family of sets;
  2. the extremal numbers La(n, B_d) and La*(n, B_d);
  3. the Antichain Augmentation Theorem: F weak B_d-free and L an antichain
     imply F u L is weak B_(d+1)-free;
  4. the lifting construction behind it: for every antichain A of B_(d+1)
     there is an order embedding B_d -> B_(d+1) whose image misses A;
  5. strict monotonicity  La(n, B_d) < La(n, B_(d+1))  for all n >= d, and its
     quantitative pigeonhole refinement
         2^n + n * La(n, B_d) <= (n + 1) * La(n, B_(d+1));
  6. the height criteria: height <= d implies weak B_d-freeness, and weak
     B_d-freeness implies height <= 2^d - 1, both thresholds being sharp.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

Mask = int
Family = Tuple[Mask, ...]


# ----------------------------------------------------------------------
# Basic subset arithmetic on bitmasks
# ----------------------------------------------------------------------

def popcount(x: Mask) -> int:
    """Number of elements of the set encoded by the bitmask `x`."""
    return bin(x).count("1")


def subset(a: Mask, b: Mask) -> bool:
    """True iff the set `a` is contained in the set `b`."""
    return a & ~b == 0


def strict_subset(a: Mask, b: Mask) -> bool:
    """True iff `a` is a proper subset of `b`."""
    return a != b and subset(a, b)


def all_subsets(n: int) -> List[Mask]:
    """All 2^n subsets of the ground set [n], as bitmasks."""
    return list(range(1 << n))


def show(mask: Mask, n: int) -> str:
    """Human-readable rendering of a subset of [n]."""
    elements = [str(i) for i in range(n) if mask >> i & 1]
    return "{" + ",".join(elements) + "}"


def show_family(fam: Iterable[Mask], n: int) -> str:
    items = sorted(fam, key=lambda m: (popcount(m), m))
    return "{ " + ", ".join(show(m, n) for m in items) + " }"


# ----------------------------------------------------------------------
# The Boolean lattice B_d and its order relations
# ----------------------------------------------------------------------

def boolean_lattice(d: int) -> List[Mask]:
    """The 2^d elements of B_d, listed in weakly increasing size."""
    return sorted(range(1 << d), key=lambda m: (popcount(m), m))


def lattice_relations(d: int) -> List[Tuple[int, int]]:
    """All strict order relations p < q of B_d, as index pairs into
    `boolean_lattice(d)`."""
    elems = boolean_lattice(d)
    rel: List[Tuple[int, int]] = []
    for i, p in enumerate(elems):
        for j, q in enumerate(elems):
            if strict_subset(p, q):
                rel.append((i, j))
    return rel


# ----------------------------------------------------------------------
# Weak and strong copies of B_d inside a family
# ----------------------------------------------------------------------

def contains_copy(family: Iterable[Mask], d: int, strong: bool = False) -> bool:
    """Does `family` contain a copy of B_d?

    A *weak* copy is an injection f : B_d -> family with
        p < q  =>  f(p) strictly contained in f(q).
    A *strong* copy additionally requires the converse implication, so that
    incomparable elements of B_d go to incomparable sets.

    The search is a straightforward backtracking over the elements of B_d in
    order of increasing size, so that every constraint involving a newly placed
    element and an already placed one can be tested immediately.
    """
    sets = sorted(set(family), key=lambda m: (popcount(m), m))
    elems = boolean_lattice(d)
    size = len(elems)
    if len(sets) < size:          # a copy of B_d needs 2^d distinct sets
        return False
    assign: List[Optional[Mask]] = [None] * size

    def compatible(i: int, value: Mask) -> bool:
        for j in range(i):
            other = assign[j]
            assert other is not None
            if other == value:
                return False
            p, q = elems[j], elems[i]
            # constraint coming from the pair (p, q)
            if strict_subset(p, q):
                if not strict_subset(other, value):
                    return False
            elif strong and strict_subset(other, value):
                return False
            # constraint coming from the pair (q, p)
            if strict_subset(q, p):
                if not strict_subset(value, other):
                    return False
            elif strong and strict_subset(value, other):
                return False
        return True

    def backtrack(i: int) -> bool:
        if i == size:
            return True
        for value in sets:
            if compatible(i, value):
                assign[i] = value
                if backtrack(i + 1):
                    return True
                assign[i] = None
        return False

    return backtrack(0)


def is_weak_free(family: Iterable[Mask], d: int) -> bool:
    """`family` contains no weak copy of B_d."""
    return not contains_copy(family, d, strong=False)


def is_strong_free(family: Iterable[Mask], d: int) -> bool:
    """`family` contains no strong copy of B_d."""
    return not contains_copy(family, d, strong=True)


# ----------------------------------------------------------------------
# Extremal numbers by exhaustive search
# ----------------------------------------------------------------------

def extremal_number(n: int, d: int, strong: bool = False) -> Tuple[int, Family]:
    """Compute La(n, B_d) (or La*(n, B_d) if `strong`) by exhaustive search,
    together with one extremal family.

    Freeness is a downward-closed property of families, so scanning candidate
    families in order of decreasing size and stopping at the first free one is
    correct and, in practice, terminates almost immediately.
    """
    ground = all_subsets(n)
    universe = len(ground)
    free = is_strong_free if strong else is_weak_free
    for size in range(universe, -1, -1):
        for combo in combinations(ground, size):
            if free(combo, d):
                return size, combo
    raise RuntimeError("unreachable: the empty family is always free")


# ----------------------------------------------------------------------
# Antichains, chains, heights
# ----------------------------------------------------------------------

def is_antichain(family: Iterable[Mask]) -> bool:
    """No member of `family` is properly contained in another."""
    items = list(family)
    return all(
        not strict_subset(a, b)
        for a in items
        for b in items
    )


def height(family: Iterable[Mask]) -> int:
    """The largest k for which `family` contains a chain of k sets."""
    items = sorted(set(family), key=popcount)
    best: Dict[Mask, int] = {}
    answer = 0
    for a in items:
        best[a] = 1 + max((best[b] for b in items if strict_subset(b, a)), default=0)
        answer = max(answer, best[a])
    return answer


def maximal_sets(family: Iterable[Mask]) -> Set[Mask]:
    """The maximal members of `family` — always an antichain."""
    items = set(family)
    return {a for a in items if not any(strict_subset(a, b) for b in items)}


def layers(n: int, a: int, k: int) -> Family:
    """The union of the k layers of sizes a, a+1, ..., a+k-1 in 2^[n]."""
    return tuple(m for m in all_subsets(n) if a <= popcount(m) < a + k)


# ----------------------------------------------------------------------
# The lifting construction:  an embedding B_d -> B_(d+1) avoiding an antichain
# ----------------------------------------------------------------------

def lift_up(d: int, up_set: Set[Mask]) -> Dict[Mask, Mask]:
    """The embedding B_d -> B_(d+1) determined by an up-set U of B_d:
    X is sent to X if X is not in U, and to X together with the new atom d
    otherwise.  This is an order embedding for *every* up-set U.
    """
    new_atom = 1 << d
    return {X: (X | new_atom if X in up_set else X) for X in range(1 << d)}


def is_order_embedding(d: int, phi: Dict[Mask, Mask]) -> bool:
    """Check that `phi` is injective and that X < Y iff phi(X) < phi(Y)."""
    values = list(phi.values())
    if len(set(values)) != len(values):
        return False
    for X in range(1 << d):
        for Y in range(1 << d):
            if strict_subset(X, Y) != strict_subset(phi[X], phi[Y]):
                return False
    return True


def embedding_avoiding_antichain(d: int, antichain: Set[Mask]) -> Dict[Mask, Mask]:
    """For an antichain A of B_(d+1), produce an order embedding
    B_d -> B_(d+1) whose image is disjoint from A.

    Take U = { X in B_d : some Z contained in X has its plain copy in A }.
    U is an up-set, so `lift_up(d, U)` is an order embedding.  If X is in U,
    witnessed by Z, then the image of X strictly contains the member Z of A,
    so it cannot itself lie in the antichain A; if X is not in U, its image is
    the plain copy of X, which is not in A by the definition of U.
    """
    up_set = {
        X for X in range(1 << d)
        if any(subset(Z, X) and Z in antichain for Z in range(1 << d))
    }
    return lift_up(d, up_set)


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------

def demo_extremal_table(max_n: int = 4, max_d: int = 4) -> Dict[Tuple[int, int], int]:
    print("=" * 72)
    print("1. Extremal numbers La(n, B_d) and La*(n, B_d) by exhaustive search")
    print("=" * 72)
    table: Dict[Tuple[int, int], int] = {}
    header = "  n  d    La(n,B_d)   La*(n,B_d)   2^n"
    print(header)
    for n in range(max_n + 1):
        for d in range(1, max_d + 2):
            weak, _ = extremal_number(n, d, strong=False)
            strong, _ = extremal_number(n, d, strong=True)
            table[(n, d)] = weak
            print(f"  {n}  {d}      {weak:5d}        {strong:5d}   {2**n:5d}")
    return table


def demo_strict_monotonicity(table: Dict[Tuple[int, int], int], max_n: int = 4) -> None:
    print()
    print("=" * 72)
    print("2. Strict monotonicity, and the pigeonhole refinement")
    print("     La(n, B_d) < La(n, B_(d+1))  exactly when d <= n")
    print("     2^n + n * La(n, B_d) <= (n + 1) * La(n, B_(d+1))")
    print("=" * 72)
    for n in range(max_n + 1):
        for d in range(1, max_n + 1):
            lo, hi = table[(n, d)], table[(n, d + 1)]
            strict = lo < hi
            expected = d <= n
            lhs = 2 ** n + n * lo
            rhs = (n + 1) * hi
            flag = "OK " if (strict == expected and lhs <= rhs) else "!! "
            print(f"  {flag}n={n} d={d}: La={lo:3d} La'={hi:3d} "
                  f"strict={strict} (predicted {expected})  "
                  f"pigeonhole {lhs} <= {rhs}")


def demo_antichain_augmentation(n: int = 4, d: int = 1, trials: int = 400) -> None:
    print()
    print("=" * 72)
    print("3. Antichain Augmentation: F weak B_d-free, L an antichain")
    print("   ==> F u L weak B_(d+1)-free")
    print("=" * 72)
    ground = all_subsets(n)
    checked = 0
    import random
    random.seed(20260806)
    for _ in range(trials):
        # a random family drawn from at most d size classes is weak B_d-free,
        # which gives us a plentiful supply of legitimate inputs F
        sizes = random.sample(range(n + 1), min(d, n + 1))
        fam = tuple(x for x in ground
                    if popcount(x) in sizes and random.random() < 0.75)
        if not is_weak_free(fam, d):
            continue
        level = random.randrange(n + 1)
        anti = tuple(x for x in ground if popcount(x) == level and random.random() < 0.7)
        union = tuple(sorted(set(fam) | set(anti)))
        assert is_antichain(anti)
        assert is_weak_free(union, d + 1), (fam, anti)
        checked += 1
    print(f"  d = {d}, ground set of size {n}: verified on {checked} random pairs (F, L),")
    print("  every union F u L was weak B_(d+1)-free, as the theorem predicts.")

    fam = layers(n, 1, d)          # d consecutive layers: weak B_d-free
    anti = layers(n, 1 + d, 1)     # the next layer: an antichain
    union = tuple(sorted(set(fam) | set(anti)))
    print(f"  Example: F = {show_family(fam, n)}")
    print(f"           L = {show_family(anti, n)}")
    print(f"  |F u L| = {len(union)}, weak B_{d+1}-free: {is_weak_free(union, d + 1)}")


def demo_lifting(max_d: int = 3, samples: int = 200) -> None:
    print()
    print("=" * 72)
    print("4. Lifting: every antichain of B_(d+1) is avoided by a copy of B_d")
    print("=" * 72)
    import random
    random.seed(11235)
    for d in range(0, max_d + 1):
        tested = 0
        for _ in range(samples):
            level = random.randrange(d + 2)
            anti = {m for m in range(1 << (d + 1))
                    if popcount(m) == level and random.random() < 0.6}
            phi = embedding_avoiding_antichain(d, anti)
            assert is_order_embedding(d, phi), (d, anti)
            assert not (set(phi.values()) & anti), (d, anti)
            tested += 1
        print(f"  d = {d}: {tested} random antichains of B_{d+1} tested; "
              "an order embedding avoiding each was produced.")


def demo_height(n: int = 4, max_d: int = 3) -> None:
    print()
    print("=" * 72)
    print("5. Height criteria: height <= d forces weak B_d-freeness,")
    print("   weak B_d-freeness forces height <= 2^d - 1, both sharp")
    print("=" * 72)
    for d in range(1, max_d + 1):
        fam = layers(n, 0, d) if d <= n + 1 else layers(n, 0, n + 1)
        h = height(fam)
        print(f"  d = {d}: the bottom {d} layers of 2^[{n}] have height {h}; "
              f"weak B_{d}-free = {is_weak_free(fam, d)}")
    # sharpness of the lower threshold: a full copy of B_d has height d+1
    d = 2
    copy = [0b000, 0b001, 0b010, 0b011]
    print(f"  Sharpness (lower): the family {show_family(copy, 3)} has height "
          f"{height(copy)} = {d}+1 and does contain a copy of B_{d}: "
          f"{contains_copy(copy, d)}")
    # sharpness of the upper threshold: a chain of 2^d - 1 sets is B_d-free
    for d in (2, 3):
        m = 2 ** d - 1
        if m <= n + 1:
            chain = [(1 << k) - 1 for k in range(m)]
            print(f"  Sharpness (upper): a chain of {m} = 2^{d}-1 sets in 2^[{n}] "
                  f"has height {height(chain)} and is weak B_{d}-free: "
                  f"{is_weak_free(chain, d)}")


def demo_few_sizes(n: int = 4) -> None:
    print()
    print("=" * 72)
    print("6. Few sizes: a family realizing at most d distinct sizes is weak B_d-free")
    print("=" * 72)
    import random
    random.seed(97)
    ground = all_subsets(n)
    for d in (1, 2, 3):
        ok = True
        for _ in range(200):
            sizes = random.sample(range(n + 1), min(d, n + 1))
            fam = tuple(x for x in ground
                        if popcount(x) in sizes and random.random() < 0.8)
            ok &= is_weak_free(fam, d)
        print(f"  d = {d}: 200 random families on at most {d} size classes, "
              f"all weak B_{d}-free: {ok}")


def demo_maximal_antichain_peeling(n: int = 4) -> None:
    print()
    print("=" * 72)
    print("7. Peeling maximal sets: the inductive engine behind the height theorem")
    print("=" * 72)
    fam = set(x for x in all_subsets(n) if popcount(x) in (1, 2, 3))
    step = 0
    while fam:
        top = maximal_sets(fam)
        assert is_antichain(top)
        print(f"  layer {step}: {len(top)} maximal sets, antichain = {is_antichain(top)}")
        fam -= top
        step += 1
    print(f"  the family was exhausted in {step} peeling steps = its height.")


def main() -> None:
    table = demo_extremal_table(max_n=4, max_d=4)
    demo_strict_monotonicity(table, max_n=4)
    demo_antichain_augmentation(n=4, d=1)
    demo_antichain_augmentation(n=4, d=2)
    demo_lifting(max_d=3)
    demo_height(n=4)
    demo_few_sizes(n=4)
    demo_maximal_antichain_peeling(n=4)
    print()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
