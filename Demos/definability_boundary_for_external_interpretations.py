"""
The Definability Boundary for External Interpretations
======================================================

Numerical demonstrations of the theory of external interpretations:
maps  I : M -> V  assigning "meaning" to the elements of a structure M whose
symmetries form a group G.

The results demonstrated here are:

  1. Orbit Descent.       I is recoverable from structural truth  <=>  I is
                          constant on the orbits of G, and the recovery is unique.
  2. Meaning Collision.   Under the full symmetric group only constants survive.
  3. Counting.            #recoverable interpretations = |V| ^ #orbits, so the
                          total count factors as |V|^|M| = |V|^#orb * |V|^L
                          with the meaning-loss exponent L(M) = |M| - #orbits.
  4. Structure of L.      L is additive over disjoint unions, vanishes exactly on
                          rigid models (equivalently exactly when EVERY
                          interpretation is recoverable), and equals the
                          duplicate count  sum_orbits (|O| - 1).
  5. Burnside bridge.     2 ^ (sum_g |Fix g|) = (#recoverable Boolean interps)^|G|.
  6. Orbit normal form.   Every invariant subset of a finite model is a disjoint
                          union of orbits (completeness of the counting language).
  7. Expressivity gap.    The trivial invariant language defines no non-constant
                          interpretation, while orbit predicates do.
  8. Logical invariance.  Over a structureless carrier, a finite-arity
                          interpretation is recoverable iff it depends only on the
                          kernel (equality pattern) of the tuple: only equality is
                          logical.  Order is not recoverable.
  9. Infinite boundary.   Parity on the naturals is recoverable (trivial symmetry
                          group) yet its fibre is neither finite nor cofinite, so
                          it escapes the bounded invariant language.
 10. Reconstruction.      A permutation lies in G iff it preserves every
                          G-recoverable interpretation; more symmetry means
                          strictly fewer recoverable meanings.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

Perm = Tuple[int, ...]          # permutation of range(n) given as an image tuple
Orbit = FrozenSet[int]


# ---------------------------------------------------------------------------
# Permutation-group utilities
# ---------------------------------------------------------------------------

def identity(n: int) -> Perm:
    """The identity permutation of {0, ..., n-1}."""
    return tuple(range(n))


def compose(sigma: Perm, tau: Perm) -> Perm:
    """The permutation (sigma . tau), i.e. first tau then sigma."""
    return tuple(sigma[tau[i]] for i in range(len(tau)))


def generated_group(n: int, generators: Sequence[Perm]) -> List[Perm]:
    """Close a set of generators under composition: the subgroup they generate.

    Breadth-first closure; the group of a small model is tiny in practice.
    """
    group: Set[Perm] = {identity(n)}
    frontier: List[Perm] = [identity(n)]
    while frontier:
        new_frontier: List[Perm] = []
        for g in frontier:
            for s in generators:
                h = compose(s, g)
                if h not in group:
                    group.add(h)
                    new_frontier.append(h)
        frontier = new_frontier
    return sorted(group)


def symmetric_group(n: int) -> List[Perm]:
    """All n! permutations of {0, ..., n-1}."""
    return sorted(permutations(range(n)))


# ---------------------------------------------------------------------------
# Algorithm A: orbit partition by union-find over the generator action
# ---------------------------------------------------------------------------

def orbit_partition(n: int, group: Sequence[Perm]) -> List[Orbit]:
    """The partition of {0,...,n-1} into orbits of the given group.

    Union-find over the action of every group element; O(n |G| a(n)).
    """
    parent: List[int] = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[max(rx, ry)] = min(rx, ry)

    for g in group:
        for x in range(n):
            union(x, g[x])

    buckets: Dict[int, Set[int]] = {}
    for x in range(n):
        buckets.setdefault(find(x), set()).add(x)
    return sorted((frozenset(b) for b in buckets.values()), key=lambda o: min(o))


def num_orbits(n: int, group: Sequence[Perm]) -> int:
    """The number of orbits of the group on {0,...,n-1}."""
    return len(orbit_partition(n, group))


def meaning_loss(n: int, group: Sequence[Perm]) -> int:
    """The meaning-loss exponent L(M) = |M| - #orbits."""
    return n - num_orbits(n, group)


# ---------------------------------------------------------------------------
# Algorithm B: recoverability test and unique recovery
# ---------------------------------------------------------------------------

def is_recoverable(interp: Sequence[object], orbits: Sequence[Orbit]) -> bool:
    """Orbit Descent: I is recoverable iff it is constant on every orbit."""
    return all(len({interp[x] for x in orbit}) == 1 for orbit in orbits)


def recover(interp: Sequence[object], orbits: Sequence[Orbit]) -> Dict[Orbit, object]:
    """The unique function on the orbit space inducing a recoverable I."""
    if not is_recoverable(interp, orbits):
        raise ValueError("interpretation is not recoverable: it collides on an orbit")
    return {orbit: interp[min(orbit)] for orbit in orbits}


# ---------------------------------------------------------------------------
# Algorithm C: orbit normal form for an invariant set
# ---------------------------------------------------------------------------

def is_invariant(subset: Set[int], group: Sequence[Perm]) -> bool:
    """Closure of a subset under the group action."""
    return all(g[x] in subset for g in group for x in subset)


def orbit_normal_form(subset: Set[int], orbits: Sequence[Orbit]) -> List[Orbit]:
    """Peel orbits off an invariant set one at a time (finite completeness).

    Returns the unique decomposition of the set as a disjoint union of orbits;
    raises if the set is not invariant.
    """
    remaining = set(subset)
    pieces: List[Orbit] = []
    while remaining:
        x = min(remaining)
        orbit = next(o for o in orbits if x in o)
        if not orbit <= remaining:
            raise ValueError("set is not invariant: it splits an orbit")
        pieces.append(orbit)
        remaining -= orbit
    return pieces


# ---------------------------------------------------------------------------
# Graphs
# ---------------------------------------------------------------------------

Graph = Tuple[int, FrozenSet[FrozenSet[int]]]   # (#vertices, set of edges)


def make_graph(n: int, edges: Iterable[Tuple[int, int]]) -> Graph:
    """A simple graph on {0,...,n-1}."""
    return (n, frozenset(frozenset(e) for e in edges))


def automorphism_group(graph: Graph) -> List[Perm]:
    """All adjacency-preserving permutations of the vertex set (brute force)."""
    n, edges = graph
    out: List[Perm] = []
    for sigma in permutations(range(n)):
        if frozenset(frozenset({sigma[a], sigma[b]}) for a, b in (tuple(e) for e in edges)) == edges:
            out.append(tuple(sigma))
    return sorted(out)


def degrees(graph: Graph) -> List[int]:
    """The vertex-degree interpretation of a graph."""
    n, edges = graph
    return [sum(1 for e in edges if v in e) for v in range(n)]


def path_graph(n: int) -> Graph:
    """The path 0 - 1 - ... - (n-1)."""
    return make_graph(n, [(i, i + 1) for i in range(n - 1)])


def cycle_graph(n: int) -> Graph:
    """The cycle 0 - 1 - ... - (n-1) - 0."""
    return make_graph(n, [(i, (i + 1) % n) for i in range(n)])


def complete_graph(n: int) -> Graph:
    """The complete graph on n vertices."""
    return make_graph(n, [(i, j) for i in range(n) for j in range(i + 1, n)])


def disjoint_union(g1: Graph, g2: Graph) -> Graph:
    """The disjoint union of two graphs, relabelling the second block."""
    n1, e1 = g1
    n2, e2 = g2
    shifted = [tuple(v + n1 for v in e) for e in e2]
    return make_graph(n1 + n2, [tuple(e) for e in e1] + shifted)


def rigid_graph() -> Graph:
    """A smallest asymmetric graph: 6 vertices, trivial automorphism group."""
    return make_graph(6, [(0, 2), (0, 3), (0, 5), (1, 2), (1, 4), (2, 3)])


# ---------------------------------------------------------------------------
# Models:  a carrier together with a group acting on it
# ---------------------------------------------------------------------------

Model = Tuple[int, List[Perm]]     # (carrier size, group of symmetries)


def model_of_graph(graph: Graph) -> Model:
    """The model given by a graph and its automorphism group."""
    return (graph[0], automorphism_group(graph))


def model_sum(m1: Model, m2: Model) -> Model:
    """The disjoint union of two models, acted on componentwise.

    This is the setting of the additivity theorem: the group acts on each
    summand separately, so no symmetry mixes the two blocks.
    """
    n1, g1 = m1
    n2, g2 = m2
    combined = [tuple(list(a) + [n1 + b for b in t]) for a in g1 for t in g2]
    return (n1 + n2, sorted(set(combined)))


# ---------------------------------------------------------------------------
# Brute-force counting
# ---------------------------------------------------------------------------

def count_all_interpretations(n: int, value_count: int) -> int:
    """|V|^|M|: the total number of external interpretations."""
    return value_count ** n


def count_recoverable_bruteforce(n: int, group: Sequence[Perm], value_count: int) -> int:
    """Enumerate every interpretation and count the recoverable ones."""
    orbits = orbit_partition(n, group)
    return sum(1 for I in product(range(value_count), repeat=n) if is_recoverable(I, orbits))


def fixed_point_sum(n: int, group: Sequence[Perm]) -> int:
    """sum over g in G of |Fix(g)|, the total number of fixed points."""
    return sum(sum(1 for x in range(n) if g[x] == x) for g in group)


# ---------------------------------------------------------------------------
# Tuple interpretations: kernels and logical invariance
# ---------------------------------------------------------------------------

def kernel(tup: Sequence[int]) -> FrozenSet[Tuple[int, int]]:
    """The equality pattern of a tuple: which coordinates coincide."""
    return frozenset((i, j) for i in range(len(tup)) for j in range(len(tup)) if tup[i] == tup[j])


def is_kernel_determined(interp: Callable[[Tuple[int, ...]], object],
                         carrier: int, arity: int) -> bool:
    """Does the interpretation depend only on the equality pattern of the tuple?"""
    seen: Dict[FrozenSet[Tuple[int, int]], object] = {}
    for tup in product(range(carrier), repeat=arity):
        k = kernel(tup)
        v = interp(tup)
        if k in seen and seen[k] != v:
            return False
        seen[k] = v
    return True


def is_perm_recoverable_tuple(interp: Callable[[Tuple[int, ...]], object],
                              carrier: int, arity: int) -> bool:
    """Is a tuple interpretation constant on orbits of the coordinatewise
    action of the full symmetric group of the carrier?"""
    for sigma in permutations(range(carrier)):
        for tup in product(range(carrier), repeat=arity):
            if interp(tuple(sigma[x] for x in tup)) != interp(tup):
                return False
    return True


# ---------------------------------------------------------------------------
# Reconstruction: which permutations preserve every recoverable interpretation
# ---------------------------------------------------------------------------

def preserving_permutations(n: int, group: Sequence[Perm], value_count: int = 2) -> List[Perm]:
    """All permutations of the carrier preserving every G-recoverable
    interpretation into a value set of the given size.

    Over a finite carrier this already recovers the orbit partition of G, and
    hence the largest group with the same recoverable theory."""
    orbits = orbit_partition(n, group)
    recoverables = [I for I in product(range(value_count), repeat=n)
                    if is_recoverable(I, orbits)]
    return sorted(tuple(sigma) for sigma in permutations(range(n))
                  if all(I[sigma[x]] == I[x] for I in recoverables for x in range(n)))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_orbit_descent() -> None:
    rule("1. ORBIT DESCENT AND MEANING COLLISION ON THE 3-PATH  0 - 1 - 2")
    g = path_graph(3)
    group = automorphism_group(g)
    orbits = orbit_partition(3, group)
    print(f"automorphism group has {len(group)} elements: {group}")
    print("  (identity and the endpoint swap (0 2), exactly as the theory predicts)")
    print(f"orbits: {[sorted(o) for o in orbits]}")

    labels = [0, 1, 2]
    deg = degrees(g)
    print(f"\nlabel interpretation   I = {labels}: recoverable = {is_recoverable(labels, orbits)}")
    print("  -> labels COLLIDE: the path cannot say which endpoint is vertex 0")
    print(f"degree interpretation  I = {deg}: recoverable = {is_recoverable(deg, orbits)}")
    print(f"  -> the unique recovery is {[(sorted(o), v) for o, v in recover(deg, orbits).items()]}")
    print("  -> degree also SEPARATES the midpoint from the endpoints:")
    print(f"     deg(0) = deg(2) = {deg[0]} and deg(1) = {deg[1]}, so it is as fine as")
    print("     structural truth permits.")

    print("\nclassification check: I is recoverable  <=>  I(0) = I(2)")
    ok = all(is_recoverable(I, orbits) == (I[0] == I[2])
             for I in product(range(3), repeat=3))
    print(f"  verified over all 3^3 = 27 interpretations into a 3-element value set: {ok}")


def demo_total_annihilation() -> None:
    rule("2. MAXIMAL SYMMETRY ANNIHILATES MEANING")
    for n in (2, 3, 4):
        group = symmetric_group(n)
        orbits = orbit_partition(n, group)
        recoverable = [I for I in product(range(3), repeat=n) if is_recoverable(I, orbits)]
        constants = [I for I in recoverable if len(set(I)) == 1]
        print(f"n = {n}: full symmetric group, {len(orbits)} orbit; "
              f"{len(recoverable)} recoverable interpretations into a 3-element value set, "
              f"all constant = {recoverable == constants}")
    print("\ncomplete graphs realise this: every permutation is an automorphism.")
    for n in (3, 4):
        kn = complete_graph(n)
        print(f"  K_{n}: |Aut| = {len(automorphism_group(kn))} = {n}! , "
              f"orbits = {len(orbit_partition(n, automorphism_group(kn)))}")
    print("\nsmallest meaning collision: the 2-element carrier under all permutations,")
    print("  the identity interpretation I(x) = x assigns different meanings to two")
    print("  indistinguishable elements, so it cannot be recovered:")
    print(f"  recoverable = {is_recoverable([0, 1], orbit_partition(2, symmetric_group(2)))}")


def demo_counting_and_exponent() -> None:
    rule("3. COUNTING, THE MEANING-LOSS EXPONENT, AND THE FACTORISATION")
    examples: List[Tuple[str, Model]] = [
        ("path P3      ", model_of_graph(path_graph(3))),
        ("path P4      ", model_of_graph(path_graph(4))),
        ("cycle C4     ", model_of_graph(cycle_graph(4))),
        ("cycle C5     ", model_of_graph(cycle_graph(5))),
        ("complete K4  ", model_of_graph(complete_graph(4))),
        ("rigid 6-graph", model_of_graph(rigid_graph())),
        ("P3 (+) P3    ", model_sum(model_of_graph(path_graph(3)),
                                    model_of_graph(path_graph(3)))),
    ]
    value_count = 3
    header = (f"{'structure':14}{'|M|':>5}{'#orb':>6}{'L(M)':>6}"
              f"{'all I':>9}{'recov.':>8}{'loss fac':>10}{'check':>7}")
    print(header)
    print("-" * len(header))
    for name, (n, group) in examples:
        orbits = orbit_partition(n, group)
        k = len(orbits)
        L = n - k
        total = count_all_interpretations(n, value_count)
        rec_formula = value_count ** k
        rec_brute = count_recoverable_bruteforce(n, group, value_count)
        loss = value_count ** L
        ok = (rec_formula == rec_brute) and (total == rec_formula * loss)
        print(f"{name:14}{n:>5}{k:>6}{L:>6}{total:>9}{rec_brute:>8}{loss:>10}{str(ok):>7}")
    print(f"\n(value set of size {value_count}; 'recov.' is a brute-force count over all")
    print(" interpretations, matched against the formula |V|^#orbits, and")
    print(" 'check' verifies  |V|^|M| = |V|^#orbits * |V|^L(M).)")

    print("\nORBIT DECOMPOSITION  L(M) = sum over orbits of (|O| - 1):")
    for name, (n, group) in examples:
        orbits = orbit_partition(n, group)
        dup = sum(len(o) - 1 for o in orbits)
        print(f"  {name}: sizes {sorted(len(o) for o in orbits)} -> duplicates {dup}, "
              f"L = {n - len(orbits)}, equal = {dup == n - len(orbits)}")


def demo_additivity_and_rigidity() -> None:
    rule("4. ADDITIVITY AND THE RIGIDITY CRITERION")
    print("The symmetry group acts on each summand separately, so no symmetry mixes")
    print("the two blocks -- this is exactly the setting of the additivity theorem.\n")
    pairs: List[Tuple[str, Model, str, Model]] = [
        ("P3", model_of_graph(path_graph(3)), "P3", model_of_graph(path_graph(3))),
        ("P3", model_of_graph(path_graph(3)), "C4", model_of_graph(cycle_graph(4))),
        ("K3", model_of_graph(complete_graph(3)), "P4", model_of_graph(path_graph(4))),
        ("C5", model_of_graph(cycle_graph(5)), "K4", model_of_graph(complete_graph(4))),
        ("K3", model_of_graph(complete_graph(3)), "rigid6",
         model_of_graph(rigid_graph())),
    ]
    print(f"{'M':>7}{'N':>8}{'L(M)':>7}{'L(N)':>7}{'L(M+N)':>9}{'additive':>10}")
    print("-" * 48)
    for na, ma, nb, mb in pairs:
        la = meaning_loss(*ma)
        lb = meaning_loss(*mb)
        mu = model_sum(ma, mb)
        lu = meaning_loss(*mu)
        print(f"{na:>7}{nb:>8}{la:>7}{lb:>7}{lu:>9}{str(lu == la + lb):>10}")

    print("\nCaveat worth noting: if instead one takes the FULL automorphism group of")
    print("a disjoint union of two isomorphic graphs, that group also swaps the two")
    print("copies, merging orbits and pushing the exponent above the sum.  For P3 + P3")
    print("the componentwise group gives L = 2, while the full group gives L = 4:")
    full = disjoint_union(path_graph(3), path_graph(3))
    print(f"  componentwise: L = "
          f"{meaning_loss(*model_sum(model_of_graph(path_graph(3)), model_of_graph(path_graph(3))))}"
          f",  full Aut: L = {meaning_loss(full[0], automorphism_group(full))}")
    print("Additivity is a statement about a fixed group acting blockwise, and this is")
    print("precisely what the hypothesis of the theorem asks for.")

    print("\nRIGIDITY: L(M) = 0  <=>  indistinguishable elements are equal")
    print("                    <=>  EVERY external interpretation is recoverable")
    rigid_examples: List[Tuple[str, Model]] = [
        ("P3               ", model_of_graph(path_graph(3))),
        ("K3               ", model_of_graph(complete_graph(3))),
        ("edge + isolate   ", model_of_graph(make_graph(3, [(0, 1)]))),
        ("rigid 6-graph    ", model_of_graph(rigid_graph())),
        ("trivial group, |M|=4", (4, generated_group(4, []))),
    ]
    for name, (n, group) in rigid_examples:
        orbits = orbit_partition(n, group)
        L = n - len(orbits)
        total = count_all_interpretations(n, 2)
        rec = count_recoverable_bruteforce(n, group, 2)
        rigid = all(len(o) == 1 for o in orbits)
        print(f"  {name}: L = {L}, rigid = {rigid}, "
              f"all Boolean interpretations recoverable = {rec == total} "
              f"({rec} of {total})")
    print("\nThe three columns move together exactly as the criterion predicts:")
    print("L = 0, rigidity, and total recoverability are the same condition.")


def demo_burnside() -> None:
    rule("5. THE BURNSIDE BRIDGE:  2^(sum_g |Fix g|)  =  (#recoverable Boolean I)^|G|")
    examples: List[Tuple[str, Graph]] = [
        ("path P3    ", path_graph(3)),
        ("path P4    ", path_graph(4)),
        ("cycle C4   ", cycle_graph(4)),
        ("cycle C5   ", cycle_graph(5)),
        ("complete K4", complete_graph(4)),
        ("rigid graph", rigid_graph()),
    ]
    print(f"{'structure':13}{'|G|':>5}{'sum|Fix|':>10}{'#orb':>6}{'R = 2^#orb':>12}"
          f"{'2^sum':>18}{'R^|G|':>18}{'ok':>5}")
    print("-" * 87)
    for name, g in examples:
        n, _ = g
        group = automorphism_group(g)
        s = fixed_point_sum(n, group)
        k = num_orbits(n, group)
        R = count_recoverable_bruteforce(n, group, 2)
        lhs = 2 ** s
        rhs = R ** len(group)
        print(f"{name:13}{len(group):>5}{s:>10}{k:>6}{R:>12}{lhs:>18}{rhs:>18}"
              f"{str(lhs == rhs):>5}")
    print("\nThe left side counts fixed points of symmetries; the right side counts")
    print("meanings the structure can hold.  They are the same number.")


def demo_orbit_normal_form() -> None:
    rule("6. ORBIT NORMAL FORM: EVERY INVARIANT SET IS A UNION OF ORBITS")
    g = cycle_graph(6)
    group = automorphism_group(g)
    orbits = orbit_partition(6, group)
    print(f"C6: |Aut| = {len(group)}, orbits = {[sorted(o) for o in orbits]}")
    print("  (the cycle is vertex-transitive, so there is a single orbit)")

    h = disjoint_union(path_graph(3), complete_graph(3))
    n, _ = h
    hgroup = automorphism_group(h)
    horbits = orbit_partition(n, hgroup)
    print(f"\nP3 + K3 on {n} vertices: orbits = {[sorted(o) for o in horbits]}")
    invariant_count = 0
    for size in range(n + 1):
        for combo in product([0, 1], repeat=n):
            if sum(combo) != size:
                continue
            subset = {i for i in range(n) if combo[i]}
            if is_invariant(subset, hgroup):
                invariant_count += 1
                nf = orbit_normal_form(subset, horbits)
                if 0 < len(subset) < n:
                    print(f"  invariant set {sorted(subset)} = disjoint union of orbits "
                          f"{[sorted(o) for o in nf]}")
    print(f"  total invariant subsets: {invariant_count} = 2^{len(horbits)} = "
          f"{2 ** len(horbits)}  (one Boolean choice per orbit)")


def demo_expressivity_gap() -> None:
    rule("7. THE EXPRESSIVITY GAP: COUNTING MODALITIES ARE NECESSARY")
    g = path_graph(3)
    group = automorphism_group(g)
    orbits = orbit_partition(3, group)
    print("On P3 the orbits are {0,2} and {1}.  The orbit indicator of {0,2},")
    indicator = [1 if x in {0, 2} else 0 for x in range(3)]
    print(f"  chi(x) = {indicator},")
    print(f"  is recoverable: {is_recoverable(indicator, orbits)}")
    print("  and its fibres {0,2} and {1} are orbit predicates, so it is definable")
    print("  in the counting language.")
    print("\nIn the TRIVIAL invariant language (only the empty set and everything),")
    print("  a definable interpretation must have every fibre empty or total, i.e.")
    print("  must be constant.  chi is non-constant, so it is NOT definable there:")
    print(f"  chi constant = {len(set(indicator)) == 1}")
    print("\nHence as soon as a finite structure has two orbits, adding orbit-counting")
    print("modalities strictly increases expressive power.")


def demo_logical_invariance() -> None:
    rule("8. LOGICAL INVARIANCE: ONLY EQUALITY IS LOGICAL")
    carrier = 3
    print(f"carrier = a bare {carrier}-element set, symmetry group = all permutations")

    tests: List[Tuple[str, int, Callable[[Tuple[int, ...]], object]]] = [
        ("equality  [x = y]      ", 2, lambda t: t[0] == t[1]),
        ("inequality [x != y]    ", 2, lambda t: t[0] != t[1]),
        ("order     [x <  y]     ", 2, lambda t: t[0] < t[1]),
        ("first coord  x         ", 2, lambda t: t[0]),
        ("constant  true         ", 2, lambda t: True),
        ("all-distinct on triples", 3, lambda t: len(set(t)) == 3),
        ("x = y != z             ", 3, lambda t: t[0] == t[1] and t[1] != t[2]),
        ("x < y < z              ", 3, lambda t: t[0] < t[1] < t[2]),
    ]
    print(f"\n{'interpretation':26}{'arity':>7}{'recoverable':>14}{'kernel-determined':>20}"
          f"{'agree':>7}")
    print("-" * 74)
    for name, arity, f in tests:
        rec = is_perm_recoverable_tuple(f, carrier, arity)
        ker = is_kernel_determined(f, carrier, arity)
        print(f"{name:26}{arity:>7}{str(rec):>14}{str(ker):>20}{str(rec == ker):>7}")
    print("\nThe two columns agree in every case: recoverable <=> kernel-determined.")
    print("Order fails both: the pairs (0,1) and (1,0) have the same equality pattern")
    print("(both unequal) but opposite order values, so order COLLIDES with itself.")

    print("\nSHARPNESS: at infinite arity the classification breaks down.")
    print("  The sequences f(n) = 2n and g(n) = n are both injective, so they share")
    print("  the same (discrete) kernel; but g is surjective and f is not.")
    n_probe = 20
    f_img = {2 * n for n in range(n_probe)}
    g_img = {n for n in range(n_probe)}
    print(f"  first {n_probe} values: f hits {sorted(f_img)[:6]}..., "
          f"missing {sorted(set(range(n_probe)) - f_img)[:6]}...")
    print(f"  g hits every value below {n_probe}: {g_img == set(range(n_probe))}")
    print("  Surjectivity is permutation-invariant, hence recoverable, yet it is not")
    print("  determined by the kernel: finiteness of the arity is essential.")


def demo_infinite_boundary() -> None:
    rule("9. THE INFINITE BOUNDARY: PARITY IS RECOVERABLE BUT NOT DEFINABLE")
    print("Take the naturals with the TRIVIAL symmetry group.  Indistinguishability")
    print("is then equality, so EVERY interpretation is orbit-constant, hence")
    print("recoverable.  In particular parity is recoverable.")
    print("\nNow take the bounded invariant language of finite-or-cofinite sets.")
    print("Definability there requires each fibre to be finite or cofinite.")
    for n in (10, 100, 1000, 10000):
        evens = sum(1 for k in range(n) if k % 2 == 0)
        odds = n - evens
        print(f"  among the first {n:>5} naturals: {evens:>5} even, {odds:>5} odd")
    print("\nBoth counts grow without bound (k -> 2k injects into the evens and")
    print("k -> 2k+1 into the odds), so the fibre of parity is neither finite nor")
    print("cofinite.  Parity is recoverable but undefinable: on infinite carriers,")
    print("orbit constancy is STRICTLY WEAKER than definability in a bounded language.")
    print("\nNote the contrast: in the MAXIMAL invariant language (all invariant sets)")
    print("the evens are invariant here, so parity is definable there.  What fails is")
    print("expressive capacity, not invariance -- and on finite carriers no such gap")
    print("can open, since a finite invariant algebra is already all invariant sets.")


def demo_reconstruction() -> None:
    rule("10. RECONSTRUCTION: THE THEORY DETERMINES THE SYMMETRIES")
    print("A permutation lies in the symmetry group exactly when it preserves every")
    print("recoverable interpretation.  Over a finite carrier this already pins down")
    print("the orbit partition, hence the largest group with the same theory.\n")
    examples: List[Tuple[str, Graph]] = [
        ("path P3    ", path_graph(3)),
        ("cycle C4   ", cycle_graph(4)),
        ("complete K3", complete_graph(3)),
        ("edge+isolate", make_graph(3, [(0, 1)])),
    ]
    for name, g in examples:
        n, _ = g
        group = automorphism_group(g)
        preserving = preserving_permutations(n, group)
        orbits_g = orbit_partition(n, group)
        orbits_p = orbit_partition(n, preserving)
        print(f"{name}: |Aut| = {len(group):>2}, "
              f"|{{sigma : sigma preserves every recoverable I}}| = {len(preserving):>2}, "
              f"same orbits = {orbits_g == orbits_p}")

    print("\nMORE SYMMETRY MEANS STRICTLY FEWER MEANINGS.  On a 4-element carrier:")
    n = 4
    chain: List[Tuple[str, List[Perm]]] = [
        ("trivial group     ", generated_group(n, [])),
        ("one transposition ", generated_group(n, [(1, 0, 2, 3)])),
        ("two transpositions", generated_group(n, [(1, 0, 2, 3), (0, 1, 3, 2)])),
        ("cyclic C4         ", generated_group(n, [(1, 2, 3, 0)])),
        ("full symmetric    ", symmetric_group(n)),
    ]
    print(f"{'group':20}{'|G|':>5}{'#orbits':>10}{'L(M)':>7}"
          f"{'#recoverable Boolean I':>26}")
    print("-" * 68)
    for name, grp in chain:
        k = num_orbits(n, grp)
        print(f"{name:20}{len(grp):>5}{k:>10}{n - k:>7}"
              f"{count_recoverable_bruteforce(n, grp, 2):>26}")
    print("\nAs the group grows the orbits coarsen, the exponent L rises, and the")
    print("stock of recoverable meanings shrinks -- strictly, whenever the group")
    print("genuinely grows in a way that merges orbits.")


def main() -> None:
    print(__doc__)
    demo_orbit_descent()
    demo_total_annihilation()
    demo_counting_and_exponent()
    demo_additivity_and_rigidity()
    demo_burnside()
    demo_orbit_normal_form()
    demo_expressivity_gap()
    demo_logical_invariance()
    demo_infinite_boundary()
    demo_reconstruction()
    print()
    print("=" * 78)
    print("All demonstrations completed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
