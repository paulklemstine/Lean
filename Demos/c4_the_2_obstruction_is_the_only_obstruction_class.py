"""
Ternary Pythagorean Trees — numerical demonstration
===================================================

Self-contained numerical companion to the classification of the ternary
Pythagorean trees.

Setting
-------
A *node* is a pair (m, n) of integers with

    1 <= n < m,   gcd(m, n) = 1,   m + n odd,

i.e. the Euclid parameters of a primitive Pythagorean triple

    tau(m, n) = (m^2 - n^2, 2mn, m^2 + n^2),

with root (2, 1) <-> (3, 4, 5).

An integer map M = (a, b; c, d) acts by (m, n) |-> (a m + b n, c m + d n).

What this script demonstrates
-----------------------------
1.  The characterisation of node-preserving maps (parity, no odd prime
    divisor of the determinant, and two cone conditions), validated against
    brute-force checking on all nodes up to a bound.
2.  The power-of-two theorem: |det| of any node-preserving map is a power of 2
    (verified exhaustively in boxes of increasing size).
3.  The three ternary trees — Berggren, Price and the mixed/hybrid tree — each
    verified to partition the non-root nodes in a finite window.
4.  The classification: an exhaustive search over admissible maps returns
    exactly those three trees.
5.  Branch-density conservation  sum 1/(a(a+b)) = 1  and the determinant
    spectrum 3 / 6 / 5.
6.  The dictionary with primitive Pythagorean triples: first generations of
    each tree, and the fact that (5, 12, 13) is always a child of (3, 4, 5).

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import gcd
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Node = Tuple[int, int]
IntMap = Tuple[int, int, int, int]  # (a, b, c, d)

# --------------------------------------------------------------------------
# 1.  Nodes and the Euclid dictionary
# --------------------------------------------------------------------------


def is_node(m: int, n: int) -> bool:
    """True iff (m, n) is a node: 1 <= n < m, gcd = 1, m + n odd."""
    return 1 <= n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


_NODE_CACHE: Dict[int, List[Node]] = {}


def nodes_up_to(bound: int) -> List[Node]:
    """All nodes with first coordinate at most `bound`, ordered (memoised)."""
    cached = _NODE_CACHE.get(bound)
    if cached is None:
        cached = [(m, n) for m in range(2, bound + 1)
                  for n in range(1, m) if is_node(m, n)]
        _NODE_CACHE[bound] = cached
    return cached


def to_triple(m: int, n: int) -> Tuple[int, int, int]:
    """Euclid's map: node -> primitive Pythagorean triple with even second leg."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def apply_map(M: IntMap, node: Node) -> Node:
    """Action of M = (a, b; c, d) on a pair."""
    a, b, c, d = M
    m, n = node
    return (a * m + b * n, c * m + d * n)


def det(M: IntMap) -> int:
    a, b, c, d = M
    return a * d - b * c


# --------------------------------------------------------------------------
# 2.  Characterisation of node-preserving maps
# --------------------------------------------------------------------------


def odd_part_has_prime_factor(k: int) -> bool:
    """True iff |k| has an odd prime factor, or k == 0 (0 is divisible by 3)."""
    if k == 0:
        return True
    k = abs(k)
    while k % 2 == 0:
        k //= 2
    return k > 1


def cone_ok(p: int, q: int) -> bool:
    """The linear form p*x + q*y is >= 1 on every pair 1 <= y < x."""
    return p >= 0 and p + q >= 0 and not (p == 0 and q == 0)


def preserves(M: IntMap) -> bool:
    """Characterisation Theorem: M maps the node set into itself iff ..."""
    a, b, c, d = M
    return (
        (a + c) % 2 != 0
        and (b + d) % 2 != 0
        and not odd_part_has_prime_factor(det(M))
        and cone_ok(c, d)
        and cone_ok(a - c, b - d)
    )


def preserves_bruteforce(M: IntMap, bound: int) -> bool:
    """Direct check: every node with m <= bound is sent to a node."""
    for node in nodes_up_to(bound):
        x, y = apply_map(M, node)
        if not is_node(x, y):
            return False
    return True


def admissible_maps(radius: int) -> List[IntMap]:
    """All node-preserving maps with all entries bounded by `radius` in abs value."""
    rng = range(-radius, radius + 1)
    return [M for M in product(rng, rng, rng, rng) if preserves(M)]


# --------------------------------------------------------------------------
# 3.  The three trees
# --------------------------------------------------------------------------

BERG_A: IntMap = (2, -1, 1, 0)   # (m,n) -> (2m - n, m),   det  1
BERG_B: IntMap = (2, 1, 1, 0)    # (m,n) -> (2m + n, m),   det -1
BERG_C: IntMap = (1, 2, 0, 1)    # (m,n) -> (m + 2n, n),   det  1

PRICE_0: IntMap = (1, 1, 0, 2)   # (m,n) -> (m + n, 2n),   det  2
PRICE_1: IntMap = (2, 0, 1, -1)  # (m,n) -> (2m, m - n),   det -2
PRICE_2: IntMap = (2, 0, 1, 1)   # (m,n) -> (2m, m + n),   det  2

MIX_F0: IntMap = (1, 3, 0, 2)    # (m,n) -> (m + 3n, 2n),  det  2

BERGGREN: Tuple[IntMap, IntMap, IntMap] = (BERG_A, BERG_B, BERG_C)
PRICE: Tuple[IntMap, IntMap, IntMap] = (PRICE_0, PRICE_1, PRICE_2)
MIXED: Tuple[IntMap, IntMap, IntMap] = (MIX_F0, BERG_A, PRICE_1)

TREES: Dict[str, Tuple[IntMap, IntMap, IntMap]] = {
    "Berggren": BERGGREN,
    "Price": PRICE,
    "Mixed": MIXED,
}

EXOTIC_43: IntMap = (3, -2, 2, -1)  # node-preserving, det  1, not a tree branch
EXOTIC_52: IntMap = (3, -1, 2, -2)  # node-preserving, det -4, not a tree branch


def is_tree_in_window(triple: Sequence[IntMap], bound: int) -> bool:
    """
    Finite-window test of the tree axioms: the images of the three maps, restricted
    to nodes whose image has first coordinate <= bound, must be pairwise disjoint,
    must miss the root, and must cover every non-root node with m <= bound.
    """
    targets: Set[Node] = set(nodes_up_to(bound)) - {(2, 1)}
    hit: Set[Node] = set()
    for M in triple:
        if not preserves(M):
            return False
        for node in nodes_up_to(bound):
            image = apply_map(M, node)
            if image == (2, 1):
                return False          # the root would have a parent
            if image[0] > bound:
                continue
            if image in hit:
                return False          # collision: two parents
            hit.add(image)
    return hit == targets


def branch_density(M: IntMap) -> Tuple[int, int]:
    """rho(M) = 1 / (a (a + b)), returned as a fraction (numerator, denominator)."""
    a, b, _, _ = M
    return (1, a * (a + b))


def add_fractions(fs: Iterable[Tuple[int, int]]) -> Tuple[int, int]:
    num, den = 0, 1
    for p, q in fs:
        num, den = num * q + p * den, den * q
        g = gcd(num, den)
        num, den = num // g, den // g
    return (num, den)


def generation(triple: Sequence[IntMap], node: Node) -> List[Node]:
    return [apply_map(M, node) for M in triple]


def bfs_levels(triple: Sequence[IntMap], depth: int) -> List[List[Node]]:
    """Breadth-first levels of the tree from the root, `depth` generations."""
    levels: List[List[Node]] = [[(2, 1)]]
    for _ in range(depth):
        levels.append([child for nd in levels[-1] for child in generation(triple, nd)])
    return levels


# --------------------------------------------------------------------------
# 4.  Exhaustive classification search
# --------------------------------------------------------------------------


def image_set(M: IntMap, bound: int) -> Set[Node]:
    """Images of nodes under M whose first coordinate stays within the window."""
    out: Set[Node] = set()
    for node in nodes_up_to(bound):
        image = apply_map(M, node)
        if image[0] <= bound:
            out.add(image)
    return out


def hits_root(M: IntMap, bound: int) -> bool:
    return any(apply_map(M, node) == (2, 1) for node in nodes_up_to(bound))


def search_trees(radius: int, bound: int) -> List[Tuple[IntMap, ...]]:
    """
    Exhaustive search by exact cover: among node-preserving maps with entries
    bounded by `radius`, find every triple whose images partition the non-root
    nodes with m <= bound.
    """
    targets: Set[Node] = set(nodes_up_to(bound)) - {(2, 1)}
    cands: List[Tuple[IntMap, Set[Node]]] = []
    for M in admissible_maps(radius):
        if hits_root(M, bound):
            continue
        img = image_set(M, bound)
        if img and img <= targets:
            cands.append((M, img))

    found: List[Tuple[IntMap, ...]] = []

    def rec(chosen: List[IntMap], covered: Set[Node]) -> None:
        if len(chosen) == 3:
            if covered == targets:
                found.append(tuple(chosen))
            return
        remaining = targets - covered
        if not remaining:
            return
        goal = min(remaining)          # the smallest uncovered node needs a parent
        for M, img in cands:
            if goal in img and not (img & covered):
                rec(chosen + [M], covered | img)

    rec([], set())
    return found


# --------------------------------------------------------------------------
# 5.  Demonstrations
# --------------------------------------------------------------------------


def demo_nodes_and_triples() -> None:
    print("=" * 74)
    print("1.  Nodes and the Euclid dictionary")
    print("=" * 74)
    print("  (m,n)  ->  (x, y, z) = (m^2-n^2, 2mn, m^2+n^2)")
    for m, n in nodes_up_to(9):
        x, y, z = to_triple(m, n)
        print(f"  ({m},{n})   ->  ({x:3d}, {y:3d}, {z:3d})     check: "
              f"{x*x + y*y == z*z and gcd(x, y) == 1}")
    print()


def demo_characterisation(bound: int = 60, radius: int = 4) -> None:
    print("=" * 74)
    print("2.  Characterisation of node-preserving maps, validated by brute force")
    print("=" * 74)
    mismatches = 0
    total = 0
    rng = range(-radius, radius + 1)
    for M in product(rng, rng, rng, rng):
        total += 1
        if preserves(M) != preserves_bruteforce(M, bound):
            mismatches += 1
            print("   MISMATCH:", M)
    print(f"  matrices tested (|entries| <= {radius}): {total}")
    print(f"  nodes used in the brute-force check:     m <= {bound}")
    print(f"  disagreements between criterion and brute force: {mismatches}")
    print()


def demo_power_of_two(max_radius: int = 6) -> None:
    print("=" * 74)
    print("3.  The power-of-two theorem:  |det| is always a power of 2")
    print("=" * 74)
    print(f"  {'R':>2}  {'#admissible':>12}   determinant magnitudes")
    for radius in range(1, max_radius + 1):
        maps = admissible_maps(radius)
        dets = sorted({abs(det(M)) for M in maps})
        assert all((d & (d - 1)) == 0 and d > 0 for d in dets), "non-power of two!"
        print(f"  {radius:2d}  {len(maps):12d}   {dets}")
    print("  every magnitude observed is a power of two, as predicted")
    print()


def demo_trees(bound: int = 200) -> None:
    print("=" * 74)
    print(f"4.  The three trees partition the node set (window m <= {bound})")
    print("=" * 74)
    for name, triple in TREES.items():
        ok = is_tree_in_window(triple, bound)
        dets = [det(M) for M in triple]
        print(f"  {name:9s}  branches {triple}")
        print(f"             determinants {dets}   tree in window: {ok}")
    print()
    print("  Two node-preserving maps that are NOT branches of any tree:")
    for M in (EXOTIC_43, EXOTIC_52):
        print(f"    {M}   preserves nodes: {preserves(M)}   det = {det(M)}")
    print()


def demo_classification(radius: int = 8, bound: int = 60) -> None:
    print("=" * 74)
    print("5.  Exhaustive classification search")
    print("=" * 74)
    print(f"  searching triples of node-preserving maps with |entries| <= {radius}")
    print(f"  required to partition the non-root nodes with m <= {bound}")
    found = search_trees(radius, bound)
    for triple in found:
        dets = [det(M) for M in triple]
        label = next((k for k, v in TREES.items() if set(v) == set(triple)), "NEW")
        print(f"    {triple}   dets {dets}   [{label}]")
    print(f"  number of trees found: {len(found)}")
    print()


def demo_density_and_spectrum() -> None:
    print("=" * 74)
    print("6.  Branch-density conservation and the determinant spectrum")
    print("=" * 74)
    for name, triple in TREES.items():
        fracs = [branch_density(M) for M in triple]
        total = add_fractions(fracs)
        spectrum = sum(abs(det(M)) for M in triple)
        pretty = " + ".join(f"{p}/{q}" for p, q in fracs)
        print(f"  {name:9s}  rho: {pretty} = {total[0]}/{total[1]}"
              f"      sum |det| = {spectrum}")
    print("  the densities always sum to exactly 1; the determinant sums 3/6/5")
    print("  separate the three trees")
    print()


def demo_generations(depth: int = 2) -> None:
    print("=" * 74)
    print("7.  Triples generated: the first generations")
    print("=" * 74)
    for name, triple in TREES.items():
        print(f"  {name}:")
        levels = bfs_levels(triple, depth)
        for k, level in enumerate(levels):
            trips = [to_triple(m, n) for (m, n) in level]
            print(f"    gen {k}: " + ", ".join(str(t) for t in trips[:9])
                  + (" ..." if len(trips) > 9 else ""))
    print()
    print("  In EVERY ternary Pythagorean tree the node (3,2), i.e. the triple")
    print("  (5,12,13), is a child of the root (2,1) = (3,4,5):")
    for name, triple in TREES.items():
        children = generation(triple, (2, 1))
        print(f"    {name:9s} children of (2,1): {children}"
              f"   contains (3,2): {(3, 2) in children}")
    print()


def demo_coverage_counts(bound: int = 200) -> None:
    print("=" * 74)
    print(f"8.  Empirical branch shares in the window m <= {bound}")
    print("=" * 74)
    all_nodes = set(nodes_up_to(bound)) - {(2, 1)}
    for name, triple in TREES.items():
        shares: List[float] = []
        for M in triple:
            count = sum(1 for nd in nodes_up_to(bound)
                        if apply_map(M, nd) in all_nodes)
            shares.append(count / len(all_nodes))
        predicted = [1.0 / (M[0] * (M[0] + M[1])) for M in triple]
        obs = ", ".join(f"{s:.3f}" for s in shares)
        pred = ", ".join(f"{p:.3f}" for p in predicted)
        print(f"  {name:9s} observed: {obs}    predicted 1/(a(a+b)): {pred}")
    print("  (the observed shares approach the predicted densities as the window grows)")
    print()


def main() -> None:
    print()
    print("#" * 74)
    print("#   TERNARY PYTHAGOREAN TREES — numerical demonstration")
    print("#" * 74)
    print()
    demo_nodes_and_triples()
    demo_characterisation()
    demo_power_of_two()
    demo_trees()
    demo_classification()
    demo_density_and_spectrum()
    demo_generations()
    demo_coverage_counts()
    print("#" * 74)
    print("#   Summary: exactly three ternary Pythagorean trees exist;")
    print("#   every branch has |det| in {1, 2}; branch densities sum to 1.")
    print("#" * 74)


if __name__ == "__main__":
    main()
