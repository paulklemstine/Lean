"""
Enumerative rigidity of antipodal maps between octahedral spheres.

This self-contained script demonstrates, numerically, the main results on
antipodally-equivariant simplicial maps between octahedral spheres S^m -> S^n.

Combinatorial model
-------------------
The octahedral n-sphere S^n is the boundary of the (n+1)-dimensional
cross-polytope.  Its vertices are pairs (axis, sign) with axis in {0,...,n}
and sign in {+1, -1}: n+1 antipodal pairs, 2(n+1) vertices.  A set of vertices
is a simplex iff it uses at most one vertex per axis.  The antipodal action
flips the sign.  A Z2-map f: S^m -> S^n is a simplicial map with
f(-v) = -f(v).

Main theorem
------------
    #{ Z2-maps S^m -> S^n } = 2^(m+1) * fallingfactorial(n+1, m+1)
                            = 2^(m+1) * (n+1)! / (n-m)!    (0 if m > n).

Corollaries verified below:
  * positivity  <=>  m <= n           (combinatorial Borsuk-Ulam; coind(S^n)=n)
  * diagonal m=n  =>  2^(n+1)*(n+1)!  (order of the hyperoctahedral group B_{n+1})
  * suspension:  #{S^{m+1}->S^{n+1}} = 2(n+2) * #{S^m->S^n}   (NOT invariant)

The closed form is cross-checked against an independent brute-force enumeration.
"""

from __future__ import annotations

from itertools import product, permutations
from math import factorial
from typing import Dict, Iterator, List, Tuple

# A signed vertex of S^n: (axis, sign) with sign in {+1, -1}.
Vertex = Tuple[int, int]
# A Z2-map is stored by its values on the positive vertices e_0,...,e_m.
PositiveData = Tuple[Vertex, ...]


# ---------------------------------------------------------------------------
# Closed-form count
# ---------------------------------------------------------------------------
def falling_factorial(base: int, length: int) -> int:
    """Falling factorial base^{\\underline{length}} = base*(base-1)*...  (length factors)."""
    result = 1
    for i in range(length):
        result *= (base - i)
    return result


def count_closed_form(m: int, n: int) -> int:
    """Exact number of Z2-maps S^m -> S^n via the closed form 2^(m+1)*(n+1)^{falling(m+1)}."""
    ff = falling_factorial(n + 1, m + 1)
    if ff <= 0:  # m > n forces a zero factor; count is 0
        return max(ff, 0)
    return 2 ** (m + 1) * ff


# ---------------------------------------------------------------------------
# Structured enumeration (via the classifying bijection)
# ---------------------------------------------------------------------------
def enumerate_maps(m: int, n: int) -> Iterator[PositiveData]:
    """Yield every Z2-map S^m -> S^n as its positive-vertex data.

    By the classifying bijection, a map is an injection of the m+1 source axes
    into the n+1 target axes together with an independent sign per source axis.
    """
    axes = range(n + 1)
    for injection in permutations(axes, m + 1):          # injective axis assignment
        for signs in product((1, -1), repeat=m + 1):     # one sign per source axis
            yield tuple((injection[i], signs[i]) for i in range(m + 1))


def count_structured(m: int, n: int) -> int:
    """Count Z2-maps by materializing them through the classifying bijection."""
    return sum(1 for _ in enumerate_maps(m, n))


# ---------------------------------------------------------------------------
# Independent brute-force enumeration (ground truth for small cases)
# ---------------------------------------------------------------------------
def sphere_vertices(d: int) -> List[Vertex]:
    """All 2(d+1) vertices of S^d."""
    return [(axis, sign) for axis in range(d + 1) for sign in (1, -1)]


def sphere_facets(d: int) -> List[Tuple[Vertex, ...]]:
    """The maximal simplices (facets) of S^d: one signed vertex per axis."""
    facets: List[Tuple[Vertex, ...]] = []
    for signs in product((1, -1), repeat=d + 1):
        facets.append(tuple((axis, signs[axis]) for axis in range(d + 1)))
    return facets


def is_simplex(vertices: Tuple[Vertex, ...]) -> bool:
    """A set of vertices is a simplex iff its axes are pairwise distinct."""
    axes = [v[0] for v in vertices]
    return len(set(axes)) == len(axes)


def count_bruteforce(m: int, n: int) -> int:
    """Directly count equivariant simplicial maps S^m -> S^n on positive data.

    An equivariant map is fixed by images of positive vertices e_0,...,e_m.
    We range over ALL 2(n+1) target vertices for each e_i (no shortcuts), then
    keep exactly those assignments whose induced map is simplicial: it suffices
    to check that the image of the all-positive facet is a simplex.
    """
    targets = sphere_vertices(n)
    total = 0
    for data in product(targets, repeat=m + 1):
        # induced map is simplicial iff the images of e_0,...,e_m form a simplex
        if is_simplex(tuple(data)):
            total += 1
    return total


# ---------------------------------------------------------------------------
# Derived quantities
# ---------------------------------------------------------------------------
def coindex(n: int, search_up_to: int = 12) -> int:
    """coind(S^n): the largest m with a Z2-map S^m -> S^n; equals n."""
    best = -1
    for m in range(search_up_to + 1):
        if count_closed_form(m, n) > 0:
            best = m
    return best


def hyperoctahedral_order(k: int) -> int:
    """Order of the hyperoctahedral (signed permutation) group B_k = 2^k * k!."""
    return 2 ** k * factorial(k)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_count_table(max_m: int = 3, max_n: int = 4) -> None:
    print("Exact counts  #{ Z2-maps S^m -> S^n } = 2^(m+1) * (n+1)^{falling(m+1)}")
    header = "m\\n | " + "".join(f"{n:>8}" for n in range(max_n + 1))
    print(header)
    print("-" * len(header))
    for m in range(max_m + 1):
        row = f"{m:>3} | " + "".join(f"{count_closed_form(m, n):>8}" for n in range(max_n + 1))
        print(row)
    print()


def demo_cross_check(max_m: int = 3, max_n: int = 4) -> None:
    print("Cross-check: closed form vs structured vs brute-force enumeration")
    ok = True
    for m in range(max_m + 1):
        for n in range(max_n + 1):
            c = count_closed_form(m, n)
            s = count_structured(m, n)
            b = count_bruteforce(m, n)
            match = (c == s == b)
            ok = ok and match
            flag = "OK " if match else "!!!"
            print(f"  m={m} n={n}: closed={c:>6}  structured={s:>6}  brute={b:>6}  {flag}")
    print(f"All agree: {ok}\n")


def demo_borsuk_ulam(max_n: int = 5) -> None:
    print("Combinatorial Borsuk-Ulam:  a Z2-map S^m -> S^n exists iff m <= n")
    for n in range(max_n + 1):
        c = coindex(n)
        print(f"  coind(S^{n}) = {c}   (no map S^{n+1} -> S^{n}: count = {count_closed_form(n + 1, n)})")
    print()


def demo_hyperoctahedral(max_n: int = 4) -> None:
    print("Self-maps of S^n number 2^(n+1)*(n+1)! = |B_{n+1}| (hyperoctahedral group)")
    for n in range(max_n + 1):
        c = count_closed_form(n, n)
        b = hyperoctahedral_order(n + 1)
        print(f"  #self-maps(S^{n}) = {c:>6}   |B_{n+1}| = {b:>6}   equal: {c == b}")
    print()


def demo_suspension(max_step: int = 4) -> None:
    print("Suspension growth of the count:  #{S^(m+1)->S^(n+1)} = 2(n+2) * #{S^m->S^n}")
    m, n = 1, 2
    for _ in range(max_step):
        c0 = count_closed_form(m, n)
        c1 = count_closed_form(m + 1, n + 1)
        ratio = c1 // c0 if c0 else None
        print(f"  #(S^{m}->S^{n})={c0:>7}   #(S^{m+1}->S^{n+1})={c1:>9}   ratio={ratio}  2(n+2)={2*(n+2)}")
        m, n = m + 1, n + 1
    print("  (The excess n-m stays fixed while the count grows: existence is stable, the value is not.)\n")


def main() -> None:
    print("=" * 72)
    print("Enumerative rigidity of antipodal maps between octahedral spheres")
    print("=" * 72, "\n")
    demo_count_table()
    demo_cross_check()
    demo_borsuk_ulam()
    demo_hyperoctahedral()
    demo_suspension()


if __name__ == "__main__":
    main()
