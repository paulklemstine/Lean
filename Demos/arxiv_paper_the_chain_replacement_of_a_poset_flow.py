"""
The chain replacement of a poset flow: numerical demonstrations.

This self-contained script illustrates, on explicit finite posets, every result of
the accompanying paper:

  1. Cone Theorem: the two-element chain {x, y} is the least element of the
     refinement poset Ch(x, y) of chains from x to y.
  2. Acyclicity of cones: for a finite poset with an element comparable to all
     others, the alternating face count of its order complex vanishes; sharpness
     is shown on the two-element antichain.
  3. Unique factorisation: concatenation is an order isomorphism
        Ch(x, y) x Ch(y, z)  ~=  { E in Ch(x, z) : y in E }
     with inverse "cut at y".
  4. Philip Hall's theorem: sum over chains from x to y of (-1)^|C| = -mu(x, y).
  5. Moebius function as reduced Euler characteristic of the open interval, and
     the cone-point vanishing criterion.
  6. Order-reflecting inclusions: transport/trace Galois coinsertion, sieve
     property (image is a lower set), and the splitting of the chain poset.
  7. Necessity of order-reflection: the two-element antichain inside the
     two-element chain.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from itertools import combinations, chain as iterchain
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

Element = object
Chain = FrozenSet[Element]


# ----------------------------------------------------------------------------
# Finite posets
# ----------------------------------------------------------------------------


class Poset:
    """A finite poset given by its ground set and its order relation."""

    def __init__(self, elements: Sequence[Element],
                 leq: Callable[[Element, Element], bool],
                 name: str = "poset") -> None:
        self.elements: List[Element] = list(elements)
        self.name = name
        self._leq: Dict[Tuple[int, int], bool] = {}
        for i, a in enumerate(self.elements):
            for j, b in enumerate(self.elements):
                self._leq[(i, j)] = bool(leq(a, b))
        self._index: Dict[Element, int] = {a: i for i, a in enumerate(self.elements)}
        self._check_partial_order()

    def _check_partial_order(self) -> None:
        n = len(self.elements)
        for i in range(n):
            assert self._leq[(i, i)], "reflexivity fails"
        for i in range(n):
            for j in range(n):
                if self._leq[(i, j)] and self._leq[(j, i)]:
                    assert i == j, "antisymmetry fails"
                for k in range(n):
                    if self._leq[(i, j)] and self._leq[(j, k)]:
                        assert self._leq[(i, k)], "transitivity fails"

    def leq(self, a: Element, b: Element) -> bool:
        return self._leq[(self._index[a], self._index[b])]

    def lt(self, a: Element, b: Element) -> bool:
        return a != b and self.leq(a, b)

    def comparable(self, a: Element, b: Element) -> bool:
        return self.leq(a, b) or self.leq(b, a)

    def closed_interval(self, x: Element, y: Element) -> List[Element]:
        return [a for a in self.elements if self.leq(x, a) and self.leq(a, y)]

    def open_interval(self, x: Element, y: Element) -> List[Element]:
        return [a for a in self.elements if self.lt(x, a) and self.lt(a, y)]

    def sub_poset(self, subset: Sequence[Element], name: str = "sub") -> "Poset":
        return Poset(list(subset), self.leq, name)


def chain_poset(n: int) -> Poset:
    """The linear order 0 < 1 < ... < n-1."""
    return Poset(list(range(n)), lambda a, b: a <= b, f"chain_{n}")


def boolean_lattice(n: int) -> Poset:
    """The Boolean lattice of subsets of {0, ..., n-1}, ordered by inclusion."""
    ground = list(range(n))
    subsets = [frozenset(s)
               for k in range(n + 1) for s in combinations(ground, k)]
    return Poset(subsets, lambda a, b: a <= b, f"B_{n}")


def antichain(n: int) -> Poset:
    """The n-element antichain: no two distinct elements are comparable."""
    return Poset(list(range(n)), lambda a, b: a == b, f"antichain_{n}")


# ----------------------------------------------------------------------------
# Chains from x to y and the refinement poset
# ----------------------------------------------------------------------------


def chains_from(P: Poset, x: Element, y: Element) -> List[Chain]:
    """All chains from x to y, as frozensets. Depth-first search on the last stop.

    A chain from x to y is a finite totally ordered subset of [x, y] containing
    both x and y. Enumerating by strictly increasing last stop produces each
    chain exactly once; cost O(|P|) per emitted chain.
    """
    if not P.leq(x, y):
        return []
    if x == y:
        return [frozenset([x])]
    out: List[Chain] = []

    def extend(prefix: List[Element]) -> None:
        last = prefix[-1]
        if last == y:
            out.append(frozenset(prefix))
            return
        for t in P.elements:
            if P.lt(last, t) and P.leq(t, y):
                extend(prefix + [t])

    extend([x])
    return out


def count_chains(P: Poset, x: Element, y: Element) -> int:
    """|Ch(x, y)| in O(n^2) via N(x, y) = sum_{x <= t < y} N(x, t), N(x, x) = 1."""
    if not P.leq(x, y):
        return 0
    memo: Dict[Element, int] = {}

    def N(z: Element) -> int:
        if z == x:
            return 1
        if z in memo:
            return memo[z]
        total = sum(N(t) for t in P.elements if P.leq(x, t) and P.lt(t, z))
        memo[z] = total
        return total

    return N(y)


def refinement_order(C: Chain, D: Chain) -> bool:
    """Refinement: C <= D iff C is a subset of D."""
    return C <= D


def refinement_poset(P: Poset, x: Element, y: Element) -> Poset:
    """The poset Ch(x, y) of chains from x to y, ordered by refinement."""
    return Poset(chains_from(P, x, y), refinement_order, f"Ch({x},{y})")


# ----------------------------------------------------------------------------
# Order complexes and alternating face counts
# ----------------------------------------------------------------------------


def order_complex_faces(P: Poset) -> List[FrozenSet[Element]]:
    """All faces of the order complex: totally ordered subsets, empty one included."""
    faces: List[FrozenSet[Element]] = []
    els = P.elements
    for k in range(len(els) + 1):
        for S in combinations(els, k):
            if all(P.comparable(a, b) for a, b in combinations(S, 2)):
                faces.append(frozenset(S))
    return faces


def alternating_face_count(P: Poset) -> int:
    """sum over faces C of the order complex of (-1)^|C|, empty face included."""
    return sum((-1) ** len(F) for F in order_complex_faces(P))


def cone_points(P: Poset) -> List[Element]:
    """Elements comparable with every element of P."""
    return [z for z in P.elements if all(P.comparable(z, a) for a in P.elements)]


# ----------------------------------------------------------------------------
# Moebius function
# ----------------------------------------------------------------------------


def mobius(P: Poset, x: Element, y: Element) -> int:
    """mu(x, y) by the classical recursion mu(x,y) = -sum_{x <= z < y} mu(x,z)."""
    if not P.leq(x, y):
        return 0
    if x == y:
        return 1
    return -sum(mobius(P, x, z)
                for z in P.elements if P.leq(x, z) and P.lt(z, y))


def chain_alt_sum(P: Poset, x: Element, y: Element) -> int:
    """sum over chains C from x to y of (-1)^|C|."""
    return sum((-1) ** len(C) for C in chains_from(P, x, y))


# ----------------------------------------------------------------------------
# Concatenation, cutting, transport, trace
# ----------------------------------------------------------------------------


def concat(C: Chain, D: Chain) -> Chain:
    """Concatenation of chains: union of carriers."""
    return C | D


def cut_left(P: Poset, E: Chain, y: Element) -> Chain:
    return frozenset(a for a in E if P.leq(a, y))


def cut_right(P: Poset, E: Chain, y: Element) -> Chain:
    return frozenset(a for a in E if P.leq(y, a))


def transport(f: Callable[[Element], Element], C: Chain) -> Chain:
    """Push a chain of P forward along an order embedding f."""
    return frozenset(f(a) for a in C)


def trace(P: Poset, f: Callable[[Element], Element], E: Chain) -> Chain:
    """Trace of a chain of Q along f: the preimage of E under f."""
    return frozenset(a for a in P.elements if f(a) in E)


def is_order_embedding(P: Poset, Q: Poset, f: Callable[[Element], Element]) -> bool:
    return all(P.leq(u, v) == Q.leq(f(u), f(v))
               for u in P.elements for v in P.elements)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_cone_theorem() -> None:
    print("=" * 78)
    print("1. CONE THEOREM: {x, y} is the least element of Ch(x, y)")
    print("=" * 78)
    for P, x, y in [(chain_poset(4), 0, 3),
                    (boolean_lattice(3), frozenset(), frozenset({0, 1, 2})),
                    (boolean_lattice(2), frozenset(), frozenset({0, 1}))]:
        Cs = chains_from(P, x, y)
        coarsest = frozenset([x, y])
        assert coarsest in Cs
        assert all(coarsest <= C for C in Cs)
        print(f"  {P.name:10s}  |Ch(x,y)| = {len(Cs):3d}   "
              f"coarsest chain contained in all of them: True   "
              f"(count check: {count_chains(P, x, y)})")
    print("  Boolean lattices give the ordered Bell numbers 1, 3, 13, 75:")
    print("   ", [count_chains(boolean_lattice(n), frozenset(),
                               frozenset(range(n))) for n in range(1, 5)])
    print()


def demo_acyclicity() -> None:
    print("=" * 78)
    print("2. ACYCLICITY OF CONES: alternating face count of the order complex")
    print("=" * 78)
    examples = [chain_poset(4), boolean_lattice(2), antichain(2), antichain(3)]
    for P in examples:
        zs = cone_points(P)
        chi = alternating_face_count(P)
        print(f"  {P.name:12s} cone points: {len(zs):2d}   "
              f"alternating face count: {chi:3d}   "
              f"{'(vanishes, as predicted)' if zs else '(no cone point)'}")
        if zs:
            assert chi == 0
    print("  Refinement posets always have a cone point, so their face count is 0:")
    for P, x, y in [(chain_poset(4), 0, 3),
                    (boolean_lattice(2), frozenset(), frozenset({0, 1}))]:
        R = refinement_poset(P, x, y)
        chi = alternating_face_count(R)
        print(f"    {R.name:14s} in {P.name:10s}: |Ch| = {len(R.elements):2d}, "
              f"alternating face count = {chi}")
        assert chi == 0
    print()


def demo_unique_factorisation() -> None:
    print("=" * 78)
    print("3. UNIQUE FACTORISATION: Ch(x,y) x Ch(y,z) ~= { E in Ch(x,z) : y in E }")
    print("=" * 78)
    tests = [(boolean_lattice(3), frozenset(), frozenset({0}),
              frozenset({0, 1, 2})),
             (chain_poset(5), 0, 2, 4)]
    for P, x, y, z in tests:
        left = chains_from(P, x, y)
        right = chains_from(P, y, z)
        through = [E for E in chains_from(P, x, z) if y in E]
        glued = {concat(C, D) for C in left for D in right}
        assert glued == set(through), "concatenation is not onto chains through y"
        assert len(glued) == len(left) * len(right), "concatenation is not injective"
        # inverse law and order-reflection
        for C in left:
            for D in right:
                E = concat(C, D)
                assert cut_left(P, E, y) == C and cut_right(P, E, y) == D
        ok_refl = all(
            (concat(C, D) <= concat(C2, D2)) == (C <= C2 and D <= D2)
            for C in left for D in right for C2 in left for D2 in right)
        print(f"  {P.name:10s}  |Ch(x,y)| = {len(left):3d}  |Ch(y,z)| = {len(right):3d}"
              f"  product = {len(left) * len(right):4d}"
              f"  |chains through y| = {len(through):4d}"
              f"  order-reflecting: {ok_refl}")
    print()


def demo_hall_theorem() -> None:
    print("=" * 78)
    print("4. PHILIP HALL'S THEOREM: sum_C (-1)^|C| = -mu(x, y)")
    print("=" * 78)
    for P in [chain_poset(5), boolean_lattice(3), antichain(3)]:
        bad = [(x, y) for x in P.elements for y in P.elements
               if chain_alt_sum(P, x, y) != -mobius(P, x, y)]
        print(f"  {P.name:12s}: checked all {len(P.elements) ** 2:3d} pairs, "
              f"mismatches: {len(bad)}")
        assert not bad
    P = boolean_lattice(3)
    bot, top = frozenset(), frozenset({0, 1, 2})
    print(f"    B_3: 13 chains from bottom to top, alternating sum "
          f"{chain_alt_sum(P, bot, top)} = -mu = {-mobius(P, bot, top)}, "
          f"mu = (-1)^3 = {mobius(P, bot, top)}")
    C4 = chain_poset(4)
    print(f"    chain 0<1<2<3: chains from 0 to 3 have sizes "
          f"{sorted(len(c) for c in chains_from(C4, 0, 3))}, "
          f"alternating sum {chain_alt_sum(C4, 0, 3)} = -mu(0,3) = "
          f"{-mobius(C4, 0, 3)}")
    print()


def demo_mobius_as_euler() -> None:
    print("=" * 78)
    print("5. MOEBIUS = REDUCED EULER CHARACTERISTIC OF THE OPEN INTERVAL")
    print("=" * 78)
    for P in [chain_poset(4), boolean_lattice(3)]:
        checked = 0
        for x in P.elements:
            for y in P.elements:
                if not P.lt(x, y):
                    continue
                I = P.sub_poset(P.open_interval(x, y), "open")
                assert alternating_face_count(I) == -mobius(P, x, y)
                checked += 1
        print(f"  {P.name:12s}: identity verified on all {checked} pairs x < y")
    print("  Vanishing criterion (a nonempty open interval with a cone point")
    print("  forces mu = 0):")
    for P in [chain_poset(5), boolean_lattice(3)]:
        hits, nocone = 0, 0
        for x in P.elements:
            for y in P.elements:
                if not P.lt(x, y):
                    continue
                I = P.sub_poset(P.open_interval(x, y), "open")
                if I.elements and cone_points(I):
                    assert mobius(P, x, y) == 0
                    hits += 1
                elif I.elements:
                    nocone += 1
        print(f"    {P.name:12s}: {hits:2d} intervals with nonempty interior having "
              f"a cone point (all with mu = 0); {nocone:2d} without one")
    print("    e.g. in the chain 0<1<2<3<4 the interior of (0,4) is the chain")
    print("    {1,2,3}, which has a cone point, and indeed mu(0,4) = "
          f"{mobius(chain_poset(5), 0, 4)}")
    print()


def demo_order_reflecting() -> None:
    print("=" * 78)
    print("6. ORDER-REFLECTING INCLUSIONS: coinsertion, sieve, splitting")
    print("=" * 78)
    Q = boolean_lattice(3)
    sub = [frozenset(), frozenset({0}), frozenset({0, 1}), frozenset({0, 1, 2})]
    P = Q.sub_poset(sub, "P (a 4-chain inside B_3)")
    f: Callable[[Element], Element] = lambda a: a  # the inclusion
    assert is_order_embedding(P, Q, f)
    x, y = frozenset(), frozenset({0, 1, 2})

    chP = chains_from(P, x, y)
    chQ = chains_from(Q, f(x), f(y))
    image = {transport(f, C) for C in chP}

    # trace is a retraction of transport
    assert all(trace(P, f, transport(f, C)) == C for C in chP)
    # Galois adjunction
    adjunction = all((transport(f, C) <= E) == (C <= trace(P, f, E))
                     for C in chP for E in chQ)
    # recognition: image = chains supported on f(P)
    fP = set(f(a) for a in P.elements)
    supported = {E for E in chQ if set(E) <= fP}
    # sieve property: image is a lower set for refinement
    lower = all(E2 in image for E in image for E2 in chQ if E2 <= E)
    upper = all(E2 not in image for E in chQ if E not in image
                for E2 in chQ if E <= E2)

    print(f"  |Ch_P| = {len(chP)},  |Ch_Q| = {len(chQ)},  "
          f"image of transport = {len(image)},  remainder = {len(chQ) - len(image)}")
    print(f"  trace o transport = id: True")
    print(f"  Galois adjunction f_* C <= E  <=>  C <= f^* E : {adjunction}")
    print(f"  recognition (image = chains supported on the image of P): "
          f"{image == supported}")
    print(f"  image is a lower set for refinement (sieve property): {lower}")
    print(f"  complement is an upper set: {upper}")
    print(f"  splitting |Ch_Q| = |Ch_P| + |remainder|: "
          f"{len(chQ)} = {len(image)} + {len(chQ) - len(image)}: "
          f"{len(chQ) == len(image) + (len(chQ) - len(image))}")
    assert adjunction and lower and upper and image == supported
    print()


def demo_order_reflection_necessary() -> None:
    print("=" * 78)
    print("7. ORDER-REFLECTION IS NECESSARY")
    print("=" * 78)
    P = antichain(2)          # {0, 1}, incomparable: the two-element antichain
    Q = chain_poset(2)        # 0 < 1
    g: Callable[[Element], Element] = lambda a: a
    injective = len({g(a) for a in P.elements}) == len(P.elements)
    monotone = all((not P.leq(u, v)) or Q.leq(g(u), g(v))
                   for u in P.elements for v in P.elements)
    reflecting = is_order_embedding(P, Q, g)
    target_chains = chains_from(Q, g(0), g(1))
    gP = {g(a) for a in P.elements}
    supported = [E for E in target_chains if set(E) <= gP]
    source_chains = chains_from(P, 0, 1)
    print(f"  P = two-element antichain, Q = two-element chain, g = identity on points")
    print(f"  g injective: {injective}   g monotone: {monotone}   "
          f"g order-reflecting: {reflecting}")
    print(f"  chains of Q from g(0) to g(1): {[sorted(E) for E in target_chains]}")
    print(f"  ... of which supported on the image of g: "
          f"{[sorted(E) for E in supported]}")
    print(f"  chains of P from 0 to 1: {source_chains}  (there are none)")
    print(f"  => a chain of the target supported on the image is NOT a transport;")
    print(f"     the trace g^-1({{0,1}}) = {{0,1}} is an ANTICHAIN, not a chain of P.")
    assert injective and monotone and not reflecting
    assert supported and not source_chains
    print()


def main() -> None:
    print()
    print("THE CHAIN REPLACEMENT OF A POSET FLOW - numerical demonstrations")
    print()
    demo_cone_theorem()
    demo_acyclicity()
    demo_unique_factorisation()
    demo_hall_theorem()
    demo_mobius_as_euler()
    demo_order_reflecting()
    demo_order_reflection_necessary()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
