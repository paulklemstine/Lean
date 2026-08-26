"""
Kernel Patterns, the Bell Numbers, and the Braid Arrangement
============================================================

Self-contained numerical demonstration of the results:

  1. The kernel pattern  pat(x)_i = min { j : x_j = x_i }  is invariant under
     any injective relabelling of the alphabet, and is a COMPLETE invariant of
     the diagonal symmetric-group action on tuples over a finite alphabet: two
     tuples are related by a permutation of the alphabet iff their kernel
     patterns coincide.  (A permutation witnessing the equivalence is built
     explicitly.)

  2. Kernel patterns of length n are exactly the fixed points of pat, i.e. the
     tuples p with p_i <= i and p_{p_i} = p_i, and they biject with the set
     partitions of {0,...,n-1}.  Their number is the Bell number B_n
     (1, 1, 2, 5, 15, 52, ...), and those with k blocks number S(n,k).

  3. Geometry: the flat L(x) = { v in R^n : x_i = x_j => v_i = v_j } of the
     braid arrangement {v_i = v_j} depends faithfully on pat(x); its dimension
     is the number of blocks.  Hence the intersection lattice has B_n elements,
     S(n,k) of dimension k.

  4. Order refinement: rank(v)_i = #{distinct values of v below v_i} is a
     complete invariant of the FACE of the braid arrangement.  A flat with k
     blocks carries exactly k! faces, so the faces number sum_k S(n,k) k!,
     the Fubini numbers 1, 1, 3, 13, 75, 541, ...; the n! chambers are the
     faces of injective tuples.

Run:  python3 demo.py
Only the standard library is used.
"""

from __future__ import annotations

from itertools import permutations, product
from math import comb, factorial
from typing import Dict, Hashable, List, Sequence, Set, Tuple

# ----------------------------------------------------------------------------
# 1. Canonical forms
# ----------------------------------------------------------------------------


def kernel_pattern(x: Sequence[Hashable]) -> Tuple[int, ...]:
    """pat(x)_i = index of the first occurrence of the value x_i.  O(n)."""
    first: Dict[Hashable, int] = {}
    out: List[int] = []
    for i, value in enumerate(x):
        if value not in first:
            first[value] = i
        out.append(first[value])
    return tuple(out)


def ordered_pattern(v: Sequence[float]) -> Tuple[int, ...]:
    """rank(v)_i = number of distinct values of v strictly below v_i.  O(n log n)."""
    order = {value: k for k, value in enumerate(sorted(set(v)))}
    return tuple(order[value] for value in v)


def blocks_of(p: Sequence[Hashable]) -> List[List[int]]:
    """The set partition induced by a tuple, blocks sorted by least element."""
    groups: Dict[Hashable, List[int]] = {}
    for i, value in enumerate(p):
        groups.setdefault(value, []).append(i)
    return sorted(groups.values(), key=min)


def is_pattern(p: Sequence[int]) -> bool:
    """Pointwise test: p is a kernel pattern iff p_i <= i and p_{p_i} = p_i."""
    return all(p[i] <= i for i in range(len(p))) and all(
        p[p[i]] == p[i] for i in range(len(p))
    )


# ----------------------------------------------------------------------------
# 2. Completeness of the invariant: build the witnessing permutation
# ----------------------------------------------------------------------------


def witness_permutation(
    x: Sequence[Hashable], y: Sequence[Hashable], alphabet: Sequence[Hashable]
) -> Dict[Hashable, Hashable] | None:
    """A permutation sigma of `alphabet` with sigma(x_i) = y_i for all i, or None.

    Implements the reconstruction proof: match used values via the tuples, then
    match the unused values by any bijection (possible since the alphabet is
    finite and the used parts are equinumerous).
    """
    if kernel_pattern(x) != kernel_pattern(y):
        return None
    sigma: Dict[Hashable, Hashable] = {}
    for a, b in zip(x, y):
        if a in sigma and sigma[a] != b:
            return None
        sigma[a] = b
    used_targets = set(sigma.values())
    free_sources = [a for a in alphabet if a not in sigma]
    free_targets = [b for b in alphabet if b not in used_targets]
    for a, b in zip(free_sources, free_targets):
        sigma[a] = b
    return sigma


# ----------------------------------------------------------------------------
# 3. Enumeration and counting
# ----------------------------------------------------------------------------


def all_patterns(n: int) -> List[Tuple[int, ...]]:
    """Every kernel pattern of length n, by restricted-growth-string search."""
    out: List[Tuple[int, ...]] = []

    def extend(prefix: List[int]) -> None:
        if len(prefix) == n:
            out.append(tuple(prefix))
            return
        i = len(prefix)
        # the new index either opens a new block (representative i) or joins an
        # existing block, i.e. points at one of the representatives seen so far
        choices = sorted({prefix[j] for j in range(i)} | {i})
        for a in choices:
            prefix.append(a)
            extend(prefix)
            prefix.pop()

    extend([])
    return out


def all_ordered_patterns(n: int) -> List[Tuple[int, ...]]:
    """Every ordered pattern (weak order) of length n: partition + block order."""
    out: List[Tuple[int, ...]] = []
    for p in all_patterns(n):
        blocks = blocks_of(p)
        for order in permutations(range(len(blocks))):
            r = [0] * n
            for position, block in zip(order, blocks):
                for i in block:
                    r[i] = position
            out.append(tuple(r))
    return out


def stirling_second(n: int, k: int) -> int:
    """S(n,k) by the triangle recursion S(n+1,k+1) = (k+1)S(n,k+1) + S(n,k)."""
    table = [[0] * (k + 1) for _ in range(n + 1)]
    if k >= 0:
        table[0][0] = 1
    for m in range(n):
        for j in range(min(m + 1, k) + 1):
            if j + 1 <= k:
                table[m + 1][j + 1] = (j + 1) * table[m][j + 1] + table[m][j]
    return table[n][k]


def bell(n: int) -> int:
    """B_n by the binomial recursion B_{n+1} = sum_i C(n,i) B_{n-i}."""
    values = [1]
    for m in range(n):
        values.append(sum(comb(m, i) * values[m - i] for i in range(m + 1)))
    return values[n]


def fubini(n: int) -> int:
    """Ordered Bell number a_n = sum_k S(n,k) k!."""
    return sum(stirling_second(n, k) * factorial(k) for k in range(n + 1))


# ----------------------------------------------------------------------------
# 4. Geometry of the braid arrangement
# ----------------------------------------------------------------------------


def flat_basis(x: Sequence[Hashable]) -> List[List[float]]:
    """Basis of L(x) = {v : x_i = x_j => v_i = v_j}: block indicator vectors."""
    n = len(x)
    return [[1.0 if i in block else 0.0 for i in range(n)] for block in blocks_of(x)]


def flat_dimension(x: Sequence[Hashable]) -> int:
    """dim L(x) = number of blocks of the kernel of x."""
    return len(blocks_of(x))


def in_flat(v: Sequence[float], x: Sequence[Hashable]) -> bool:
    """Membership test for the flat cut out by x."""
    n = len(x)
    return all(v[i] == v[j] for i in range(n) for j in range(n) if x[i] == x[j])


def flats_equal(x: Sequence[Hashable], y: Sequence[Hashable]) -> bool:
    """L(x) = L(y), tested directly through the defining equations."""
    n = len(x)
    same_x = {(i, j) for i in range(n) for j in range(n) if x[i] == x[j]}
    same_y = {(i, j) for i in range(n) for j in range(n) if y[i] == y[j]}
    return same_x == same_y


def chamber_of(v: Sequence[float]) -> Tuple[int, ...] | None:
    """The permutation indexing the chamber of an injective vector, else None."""
    if len(set(v)) != len(v):
        return None
    return tuple(sorted(range(len(v)), key=lambda i: v[i]))


def same_face(v: Sequence[float], w: Sequence[float]) -> bool:
    """v and w lie in the same face iff they realise the same strict comparisons."""
    n = len(v)
    return all(
        (v[i] < v[j]) == (w[i] < w[j]) for i in range(n) for j in range(n)
    )


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

RULE = "=" * 78


def demo_canonical_form() -> None:
    print(RULE)
    print("1. THE KERNEL PATTERN AS A CANONICAL FORM")
    print(RULE)
    beads = ["red", "blue", "red", "green", "blue"]
    p = kernel_pattern(beads)
    print(f"  tuple             : {beads}")
    print(f"  kernel pattern    : {p}          (0-indexed first occurrences)")
    print(f"  induced partition : {blocks_of(beads)}")
    print(f"  idempotent?       : pat(pat(x)) == pat(x) -> {kernel_pattern(p) == p}")
    print(f"  fixed-point test  : p_i <= i and p_{{p_i}} = p_i -> {is_pattern(p)}")

    recoloured = ["purple", "orange", "purple", "yellow", "orange"]
    print(f"\n  relabelled tuple  : {recoloured}")
    print(f"  its pattern       : {kernel_pattern(recoloured)}   (unchanged)")

    merged = ["red", "blue", "red", "blue", "blue"]  # green -> blue: not injective
    print(f"\n  NON-injective recolouring (green -> blue): {merged}")
    print(f"  its pattern       : {kernel_pattern(merged)}   (changed, as it must)")


def demo_completeness() -> None:
    print("\n" + RULE)
    print("2. COMPLETENESS: EQUAL PATTERNS <=> SAME ORBIT")
    print(RULE)
    alphabet = list(range(4))
    n = 3
    tuples = list(product(alphabet, repeat=n))

    # brute-force orbits under the diagonal action of Sym(alphabet)
    orbit_of: Dict[Tuple[int, ...], int] = {}
    orbits: List[Set[Tuple[int, ...]]] = []
    for t in tuples:
        if t in orbit_of:
            continue
        orbit = {
            tuple(sigma[a] for a in t) for sigma in permutations(alphabet)
        }
        for member in orbit:
            orbit_of[member] = len(orbits)
        orbits.append(orbit)

    patterns_seen = {kernel_pattern(t) for t in tuples}
    print(f"  alphabet size m = {len(alphabet)}, tuple length n = {n}")
    print(f"  number of tuples                 : {len(tuples)}")
    print(f"  number of Sym(alphabet)-orbits   : {len(orbits)}")
    print(f"  number of distinct kernel patterns: {len(patterns_seen)}")
    print(f"  Bell number B_{n}                  : {bell(n)}")

    ok = all(
        (orbit_of[s] == orbit_of[t]) == (kernel_pattern(s) == kernel_pattern(t))
        for s in tuples
        for t in tuples
    )
    print(f"  same orbit  <=>  same pattern     : {ok}")

    x, y = (0, 2, 0), (3, 1, 3)
    sigma = witness_permutation(x, y, alphabet)
    print(f"\n  explicit witness for x = {x}, y = {y}:")
    print(f"    sigma = {sigma}")
    print(f"    sigma o x = {tuple(sigma[a] for a in x)}  (= y: {tuple(sigma[a] for a in x) == y})")

    print("\n  Sharpness (a proper subgroup does not suffice):")
    x1, y1 = (0,), (1,)
    print(f"    pat({x1}) = {kernel_pattern(x1)} = pat({y1}) = {kernel_pattern(y1)}")
    print("    but the trivial subgroup {id} cannot carry (0) to (1).")


def demo_bell_and_stirling() -> None:
    print("\n" + RULE)
    print("3. COUNTING: BELL AND STIRLING NUMBERS")
    print(RULE)
    print("   n | #patterns | B_n | S(n,0..n)                     | check")
    print("  ---+-----------+-----+-------------------------------+------")
    for n in range(7):
        pats = all_patterns(n)
        by_blocks = [
            sum(1 for p in pats if len(set(p)) == k) for k in range(n + 1)
        ]
        stirling = [stirling_second(n, k) for k in range(n + 1)]
        ok = (len(pats) == bell(n)) and (by_blocks == stirling)
        print(
            f"   {n} | {len(pats):9d} | {bell(n):3d} | {str(stirling):29s} | {ok}"
        )
    print("\n  Bell-Stirling identity  B_n = sum_k S(n,k):")
    for n in range(9):
        total = sum(stirling_second(n, k) for k in range(n + 1))
        print(f"    n = {n}:  sum_k S(n,k) = {total:6d}   B_n = {bell(n):6d}   "
              f"{total == bell(n)}")

    print("\n  Exhaustive fixed-point check over all n^n tuples (n <= 5):")
    for n in range(6):
        count = sum(1 for p in product(range(n), repeat=n) if is_pattern(p)) if n else 1
        print(f"    n = {n}: {n**n if n else 1:5d} candidates -> {count:3d} patterns "
              f"(B_{n} = {bell(n)})")


def demo_geometry_flats() -> None:
    print("\n" + RULE)
    print("4. GEOMETRY: FLATS OF THE BRAID ARRANGEMENT")
    print(RULE)
    x = ["a", "b", "a", "c", "b"]
    print(f"  tuple x                : {x}")
    print(f"  flat L(x) = {{v : x_i = x_j => v_i = v_j}}")
    print(f"  basis (block indicators): {flat_basis(x)}")
    print(f"  dim L(x)               : {flat_dimension(x)}  = number of blocks")
    v = [7.0, -1.0, 7.0, 2.5, -1.0]
    print(f"  sample vector v        : {v}   in L(x)? {in_flat(v, x)}")
    w = [7.0, -1.0, 0.0, 2.5, -1.0]
    print(f"  perturbed w            : {w}   in L(x)? {in_flat(w, x)}")

    y = [10, 20, 10, 30, 20]
    print(f"\n  y = {y} has pattern {kernel_pattern(y)} = pattern of x "
          f"({kernel_pattern(x) == kernel_pattern(y)})")
    print(f"  L(x) = L(y)?           : {flats_equal(x, y)}")

    print("\n  Enumeration of the intersection lattice:")
    print("   n | #flats | B_n | flats by dimension (k = 0..n)")
    print("  ---+--------+-----+------------------------------")
    for n in range(6):
        pats = all_patterns(n)
        by_dim = [sum(1 for p in pats if flat_dimension(p) == k) for k in range(n + 1)]
        print(f"   {n} | {len(pats):6d} | {bell(n):3d} | {by_dim}")
    print("  (row n = 5: 1 + 15 + 25 + 10 + 1 = 52 flats, dimensions 1..5)")


def demo_faces_and_chambers() -> None:
    print("\n" + RULE)
    print("5. FACES, CHAMBERS, AND THE FUBINI NUMBERS")
    print(RULE)
    v = [3.1, 7.0, 3.1, -2.0, 7.0]
    print(f"  vector v            : {v}")
    print(f"  ordered pattern     : {ordered_pattern(v)}")
    print(f"  kernel pattern      : {kernel_pattern(v)}")
    print("  compatibility       : pat(rank(v)) == pat(v) -> "
          f"{kernel_pattern(ordered_pattern(v)) == kernel_pattern(v)}")

    stretched = [2 * t + 5 for t in v]  # strictly monotone reparametrisation
    print(f"\n  strictly monotone image t -> 2t+5: {stretched}")
    print(f"  ordered pattern     : {ordered_pattern(stretched)}   (unchanged)")
    print(f"  same face?          : {same_face(v, stretched)}")

    reordered = [3.1, 7.0, 3.1, 5.0, 7.0]  # -2.0 -> 5.0 changes the order
    print(f"\n  order-changing move : {reordered}")
    print(f"  ordered pattern     : {ordered_pattern(reordered)}   (changed)")
    print(f"  same kernel pattern?: {kernel_pattern(reordered) == kernel_pattern(v)}"
          "   (same flat, different face)")

    c = [0.4, 9.0, -3.0]
    print(f"\n  injective vector    : {c}")
    print(f"  chamber (sorting permutation, increasing): {chamber_of(c)}")

    print("\n  Face counts:")
    print("   n | #faces | Fubini a_n | #flats B_n | #chambers n! | k! fibre check")
    print("  ---+--------+------------+------------+--------------+---------------")
    for n in range(6):
        faces = all_ordered_patterns(n)
        fibres_ok = all(
            sum(1 for r in faces if kernel_pattern(r) == p) == factorial(len(set(p)))
            for p in all_patterns(n)
        )
        print(
            f"   {n} | {len(faces):6d} | {fubini(n):10d} | {bell(n):10d} | "
            f"{factorial(n):12d} | {fibres_ok}"
        )
    print("\n  Inequalities n! <= a_n and B_n <= a_n (every chamber is a face;")
    print("  every flat carries at least one face):")
    for n in range(8):
        print(f"    n = {n}: {factorial(n):6d} <= {fubini(n):6d} and "
              f"{bell(n):6d} <= {fubini(n):6d}")


def main() -> None:
    demo_canonical_form()
    demo_completeness()
    demo_bell_and_stirling()
    demo_geometry_flats()
    demo_faces_and_chambers()
    print("\n" + RULE)
    print("Summary for n = 5:  52 orbits = 52 flats,  541 faces,  120 chambers.")
    print(RULE)


if __name__ == "__main__":
    main()
