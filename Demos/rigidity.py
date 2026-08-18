"""
Orbital Rigidity — numerical demonstrations.

A finite group G acting on a finite set X induces a diagonal action on X x X.
The orbits of that diagonal action are called *orbitals*.  Every orbital is
contained in a product orbit(x) x orbit(y) of two orbits, so the orbital
partition always refines the "square" of the orbit partition.  The Orbital
Rigidity Theorem says the refinement is an equality only for the trivial
action, and quantifies exactly how far from equality one always is:

    Variance identity      |G| (s - r^2) = sum_g ( F(g) - r )^2
    Sharp lower bound      |K| (n - r)^2 <= (|G| - |K|) (s - r^2)
    Equality classified    equality  <=>  F is constant off the kernel K
    Higher arity           s_{k+1} >= s_k * r, hence s_k > r^k for k >= 2
                           unless the action is trivial

Here n = |X|, r = #orbits on X, s = #orbits on X x X (orbitals),
F(g) = #fixed points of g on X, and K = {g : g acts trivially} is the kernel.

This script is self-contained: it builds small permutation groups by closure
from generators, computes every quantity above by brute force, and checks all
of the statements numerically.  Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]  # a permutation of {0, ..., n-1} given by images


# ----------------------------------------------------------------------
# Group machinery
# ----------------------------------------------------------------------

def compose(p: Perm, q: Perm) -> Perm:
    """Return the permutation (p . q), i.e. x |-> p(q(x))."""
    return tuple(p[q[i]] for i in range(len(q)))


def identity(n: int) -> Perm:
    """Return the identity permutation on n points."""
    return tuple(range(n))


def generate_group(n: int, generators: Sequence[Perm]) -> List[Perm]:
    """Close a set of generators under composition (breadth-first closure)."""
    elements: Dict[Perm, None] = {identity(n): None}
    frontier: List[Perm] = [identity(n)]
    while frontier:
        new_frontier: List[Perm] = []
        for element in frontier:
            for gen in generators:
                candidate = compose(gen, element)
                if candidate not in elements:
                    elements[candidate] = None
                    new_frontier.append(candidate)
        frontier = new_frontier
    return sorted(elements)


def cycle(n: int, points: Sequence[int]) -> Perm:
    """Return the cyclic permutation sending points[i] to points[i+1]."""
    image = list(range(n))
    for i, p in enumerate(points):
        image[p] = points[(i + 1) % len(points)]
    return tuple(image)


def product_of_cycles(n: int, cycles: Sequence[Sequence[int]]) -> Perm:
    """Return the permutation given as a product of disjoint cycles."""
    result = identity(n)
    for c in cycles:
        result = compose(cycle(n, c), result)
    return result


# ----------------------------------------------------------------------
# Orbit / fixed-point counting
# ----------------------------------------------------------------------

def fix_count(group_element: Perm, n: int) -> int:
    """Number of points of {0,...,n-1} fixed by a permutation."""
    return sum(1 for i in range(n) if group_element[i] == i)


def fix_count_tuples(group_element: Perm, n: int, k: int) -> int:
    """Number of k-tuples fixed by a permutation: F(g)^k."""
    return fix_count(group_element, n) ** k


def num_orbits_on_tuples(group: Sequence[Perm], n: int, k: int) -> int:
    """Number of orbits of G on X^k, computed by Burnside's lemma."""
    total = sum(fix_count_tuples(g, n, k) for g in group)
    assert total % len(group) == 0, "Burnside sum must be divisible by |G|"
    return total // len(group)


def orbits_direct(group: Sequence[Perm], n: int) -> List[List[int]]:
    """Explicit list of orbits on points (used to cross-check Burnside)."""
    seen = [False] * n
    orbits: List[List[int]] = []
    for x in range(n):
        if seen[x]:
            continue
        orbit = sorted({g[x] for g in group})
        for y in orbit:
            seen[y] = True
        orbits.append(orbit)
    return orbits


def orbitals_direct(group: Sequence[Perm], n: int) -> List[List[Tuple[int, int]]]:
    """Explicit list of orbitals (orbits of the diagonal action on X x X)."""
    seen = set()
    orbitals: List[List[Tuple[int, int]]] = []
    for pair in product(range(n), repeat=2):
        if pair in seen:
            continue
        orbital = sorted({(g[pair[0]], g[pair[1]]) for g in group})
        seen.update(orbital)
        orbitals.append(orbital)
    return orbitals


def kernel(group: Sequence[Perm], n: int) -> List[Perm]:
    """Elements acting trivially on every point."""
    ident = identity(n)
    return [g for g in group if g == ident]


# ----------------------------------------------------------------------
# The rigidity report for a single action
# ----------------------------------------------------------------------

def rigidity_report(name: str, n: int, generators: Sequence[Perm]) -> Dict[str, object]:
    """Compute every quantity in the rigidity theorems for one action."""
    group = generate_group(n, generators)
    order = len(group)
    fixities = [fix_count(g, n) for g in group]
    r = num_orbits_on_tuples(group, n, 1)
    s = num_orbits_on_tuples(group, n, 2)
    kernel_size = len(kernel(group, n))

    # cross-checks against direct enumeration
    assert r == len(orbits_direct(group, n)), "Burnside disagrees with direct orbit count"
    assert s == len(orbitals_direct(group, n)), "Burnside disagrees with direct orbital count"

    defect = s - r * r
    variance_sum = sum((f - r) ** 2 for f in fixities)
    weak_lhs = kernel_size * (n - r) ** 2
    sharp_rhs = (order - kernel_size) * defect
    off_kernel = sorted({f for g, f in zip(group, fixities) if g != identity(n)})
    constant_fixity = len(off_kernel) <= 1

    # the four theorems, checked
    assert order * defect == variance_sum, "variance identity failed"
    assert weak_lhs <= order * defect, "weak quantitative bound failed"
    assert weak_lhs <= sharp_rhs, "sharp quantitative bound failed"
    assert (weak_lhs == sharp_rhs) == (constant_fixity or n == r), \
        "classification of the equality case failed"
    assert (s == r * r) == (order == kernel_size), "rigidity at k = 2 failed"

    return {
        "name": name,
        "n": n,
        "order": order,
        "fixities": fixities,
        "r": r,
        "s": s,
        "defect": defect,
        "variance_sum": variance_sum,
        "weak_lhs": weak_lhs,
        "weak_rhs": order * defect,
        "sharp_rhs": sharp_rhs,
        "kernel_size": kernel_size,
        "constant_fixity": constant_fixity,
    }


def gallery() -> List[Tuple[str, int, List[Perm]]]:
    """A gallery of small permutation actions used throughout the paper."""
    return [
        ("trivial on 3 points", 3, []),
        ("Z/2 swap on 2 points", 2, [product_of_cycles(2, [[0, 1]])]),
        ("Z/2 transposition (0 1) on 3 points", 3, [product_of_cycles(3, [[0, 1]])]),
        ("Z/3 rotation on 3 points", 3, [product_of_cycles(3, [[0, 1, 2]])]),
        ("S_3 on 3 points", 3,
         [product_of_cycles(3, [[0, 1]]), product_of_cycles(3, [[0, 1, 2]])]),
        ("Z/2 double transposition on 4 points", 4,
         [product_of_cycles(4, [[0, 1], [2, 3]])]),
        ("Klein four regular on 4 points", 4,
         [product_of_cycles(4, [[0, 1], [2, 3]]), product_of_cycles(4, [[0, 2], [1, 3]])]),
        ("Z/4 regular on 4 points", 4, [product_of_cycles(4, [[0, 1, 2, 3]])]),
        ("D_4 on the square", 4,
         [product_of_cycles(4, [[0, 1, 2, 3]]), product_of_cycles(4, [[1, 3]])]),
        ("Z/5 regular on 5 points", 5, [product_of_cycles(5, [[0, 1, 2, 3, 4]])]),
        ("Z/3 on 5 points", 5, [product_of_cycles(5, [[0, 1, 2]])]),
        ("Klein four on 6 points", 6,
         [product_of_cycles(6, [[0, 1], [2, 3]]), product_of_cycles(6, [[2, 3], [4, 5]])]),
    ]


# ----------------------------------------------------------------------
# Presentation
# ----------------------------------------------------------------------

def print_main_table(reports: Iterable[Dict[str, object]]) -> None:
    header = (f"{'action':38s} {'n':>2s} {'|G|':>4s} {'r':>3s} {'s':>4s} "
              f"{'s-r^2':>6s} {'|K|(n-r)^2':>11s} {'(|G|-|K|)(s-r^2)':>17s} "
              f"{'|G|(s-r^2)':>11s} {'tight':>6s}")
    print(header)
    print("-" * len(header))
    for rep in reports:
        tight = "  YES" if rep["weak_lhs"] == rep["sharp_rhs"] else "   no"
        print(f"{rep['name']:38s} {rep['n']:2d} {rep['order']:4d} {rep['r']:3d} "
              f"{rep['s']:4d} {rep['defect']:6d} {rep['weak_lhs']:11d} "
              f"{rep['sharp_rhs']:17d} {rep['weak_rhs']:11d} {tight:>6s}")


def demo_variance_identity(reports: Iterable[Dict[str, object]]) -> None:
    print("\nVariance identity:  |G| (s - r^2) = sum_g (F(g) - r)^2")
    print("-" * 60)
    for rep in reports:
        print(f"{rep['name']:38s} {rep['weak_rhs']:6d} = {rep['variance_sum']:6d}  "
              f"F = {rep['fixities']}")


def demo_higher_arity() -> None:
    print("\nHigher-arity hierarchy:  s_k = #orbits on X^k  versus  r^k")
    print("-" * 72)
    print(f"{'action':30s} {'k':>2s} {'r^k':>8s} {'s_k':>8s} {'s_k - r^k':>10s} "
          f"{'s_k >= s_{k-1} r':>16s}")
    for name, n, gens in gallery():
        group = generate_group(n, gens)
        r = num_orbits_on_tuples(group, n, 1)
        previous = r
        for k in range(2, 5):
            s_k = num_orbits_on_tuples(group, n, k)
            chain_ok = s_k >= previous * r
            assert chain_ok, "Chebyshev chain inequality failed"
            trivial = len(kernel(group, n)) == len(group)
            assert (s_k == r ** k) == trivial, "higher-arity rigidity failed"
            print(f"{name[:30]:30s} {k:2d} {r ** k:8d} {s_k:8d} {s_k - r ** k:10d} "
                  f"{str(chain_ok):>16s}")
            previous = s_k


def demo_no_linear_lower_bound() -> None:
    print("\nWhy the defect is not controlled by |X|:")
    print("a single transposition on n points has s - r^2 = 1 for every n.")
    print("-" * 62)
    print(f"{'n':>3s} {'r':>4s} {'s':>5s} {'s-r^2':>6s} {'|K|(n-r)^2/(|G|-|K|)':>22s}")
    for n in range(2, 11):
        group = generate_group(n, [product_of_cycles(n, [[0, 1]])])
        r = num_orbits_on_tuples(group, n, 1)
        s = num_orbits_on_tuples(group, n, 2)
        kernel_size = len(kernel(group, n))
        bound = kernel_size * (n - r) ** 2 / (len(group) - kernel_size)
        print(f"{n:3d} {r:4d} {s:5d} {s - r * r:6d} {bound:22.3f}")


def demo_structural_criterion() -> None:
    """Orbits on X x Y are products of orbits iff each stabiliser G_x stays
    transitive on every G-orbit of Y.  With Y = X this forces triviality."""
    print("\nIndependence criterion (stabiliser transitivity) on X x Y:")
    print("-" * 62)
    n = 4
    group = generate_group(n, [product_of_cycles(4, [[0, 1, 2, 3]])])  # Z/4 on X = Y = 4 points

    def stabiliser(x: int) -> List[Perm]:
        return [g for g in group if g[x] == x]

    def orbit_of(subgroup: Sequence[Perm], y: int) -> List[int]:
        return sorted({g[y] for g in subgroup})

    independent = all(orbit_of(stabiliser(x), y) == orbit_of(group, y)
                      for x in range(n) for y in range(n))
    acts_trivially = all(g == identity(n) for g in group)
    assert independent == acts_trivially, "self-independence criterion failed"
    print(f"Z/4 acting regularly on 4 points: stabilisers transitive on all orbits? "
          f"{independent}")
    print(f"action trivial? {acts_trivially}   (the two agree, as the theorem demands)")

    trivial_group = generate_group(3, [])
    independent_trivial = all(
        sorted({g[y] for g in trivial_group if g[x] == x}) == sorted({g[y] for g in trivial_group})
        for x in range(3) for y in range(3))
    print(f"trivial action on 3 points: stabilisers transitive on all orbits? "
          f"{independent_trivial}")


def main() -> None:
    print("=" * 100)
    print("ORBITAL RIGIDITY — numerical demonstrations")
    print("=" * 100)
    reports = [rigidity_report(name, n, gens) for name, n, gens in gallery()]
    print_main_table(reports)
    demo_variance_identity(reports)
    demo_higher_arity()
    demo_no_linear_lower_bound()
    demo_structural_criterion()
    print("\nAll assertions passed: every rigidity statement holds on every example.")


if __name__ == "__main__":
    main()
