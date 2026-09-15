"""
The Congruent Number Laboratory
===============================

Numerical demonstrations for the area function of the Berggren tree of primitive
Pythagorean triples and its identification with the congruent number problem.

Everything here is exact integer / rational arithmetic; no floating point is used
for any arithmetic claim.

Contents
--------
1.  Euclid coordinates, the three Berggren moves, and the area A(m,n) = mn(m-n)(m+n).
2.  Verification that the tree enumerates every primitive Pythagorean triple exactly once.
3.  Squarefree parts of node areas  ->  certified congruent numbers.
4.  The three-way bridge: node  ->  rational triangle  ->  point on y^2 = x^3 - s^2 x.
5.  Unconditional non-congruence laws: no square area, no twice-a-square area,
    no area p*k^2 for primes p = 3 (mod 8).
6.  Structure of the area function: increment identities, 6x growth on the B branch,
    the Pell spine and its silver law, properness.
7.  Depth statistics: at what depth does each congruent number first appear?

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, isqrt
from typing import Dict, Iterator, List, Optional, Tuple

Seed = Tuple[int, int]
Triple = Tuple[int, int, int]


# ----------------------------------------------------------------------------------
# 1. Seeds, moves, area
# ----------------------------------------------------------------------------------

def is_admissible(m: int, n: int) -> bool:
    """A seed is admissible iff m > n > 0, gcd(m, n) = 1 and m - n is odd."""
    return m > n > 0 and gcd(m, n) == 1 and (m - n) % 2 == 1


def euclid_triple(m: int, n: int) -> Triple:
    """The primitive Pythagorean triple (m^2 - n^2, 2mn, m^2 + n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def euclid_area(m: int, n: int) -> int:
    """The area function of the tree:  A(m, n) = m n (m - n)(m + n)."""
    return m * n * (m - n) * (m + n)


def move_A(seed: Seed) -> Seed:
    m, n = seed
    return (2 * m - n, m)


def move_B(seed: Seed) -> Seed:
    m, n = seed
    return (2 * m + n, m)


def move_C(seed: Seed) -> Seed:
    m, n = seed
    return (m + 2 * n, n)


ROOT: Seed = (2, 1)
MOVES = {"A": move_A, "B": move_B, "C": move_C}


def tree_nodes(max_depth: int) -> Iterator[Tuple[str, Seed]]:
    """Breadth-first enumeration of the tree, yielding (address word, seed)."""
    frontier: List[Tuple[str, Seed]] = [("", ROOT)]
    for _ in range(max_depth + 1):
        new_frontier: List[Tuple[str, Seed]] = []
        for word, seed in frontier:
            yield word, seed
            for name, move in MOVES.items():
                new_frontier.append((word + name, move(seed)))
        frontier = new_frontier


def parent(seed: Seed) -> Optional[Tuple[str, Seed]]:
    """Invert the Berggren moves: return (move name, parent seed), or None at the root."""
    m, n = seed
    if (m, n) == ROOT:
        return None
    if m < 2 * n:                       # child of type A: (m, n) = (2p - q, p), q = 2n - m
        return ("A", (n, 2 * n - m))
    if m < 3 * n:                       # child of type B: (m, n) = (2p + q, p), q = m - 2n
        return ("B", (n, m - 2 * n))
    return ("C", (m - 2 * n, n))        # child of type C: (m, n) = (p + 2q, q), p = m - 2n


def address(seed: Seed) -> str:
    """The unique word in {A, B, C} leading from the root (2,1) to this seed."""
    word = ""
    cur = seed
    while True:
        step = parent(cur)
        if step is None:
            return word
        name, cur = step
        word = name + word


# ----------------------------------------------------------------------------------
# 2. Squarefree parts
# ----------------------------------------------------------------------------------

def factorize(n: int) -> Dict[int, int]:
    """Trial-division factorization (adequate for the sizes used in this demo)."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def squarefree_part(n: int) -> int:
    """The squarefree s with n = s * k^2 for some integer k."""
    s = 1
    for p, e in factorize(n).items():
        if e % 2 == 1:
            s *= p
    return s


def _spf_sieve(limit: int) -> List[int]:
    """Smallest-prime-factor sieve, used to factor the four small factors of an area."""
    spf = list(range(limit + 1))
    i = 2
    while i * i <= limit:
        if spf[i] == i:
            for j in range(i * i, limit + 1, i):
                if spf[j] == j:
                    spf[j] = i
        i += 1
    return spf


def squarefree_part_of_area(m: int, n: int, spf: List[int]) -> int:
    """Squarefree part of A(m,n), computed by factoring m, n, m-n, m+n separately.

    This is the efficient route: the four factors are pairwise coprime and small,
    whereas their product is of size O(m^4).
    """
    exponents: Dict[int, int] = {}
    for factor in (m, n, m - n, m + n):
        while factor > 1:
            p = spf[factor]
            while factor % p == 0:
                exponents[p] = exponents.get(p, 0) + 1
                factor //= p
    s = 1
    for p, e in exponents.items():
        if e % 2 == 1:
            s *= p
    return s


def cofactor(area: int, s: int) -> int:
    """The k with area = s * k^2, given the squarefree part s."""
    k2 = area // s
    k = isqrt(k2)
    assert k * k == k2 and s * k * k == area
    return k


def square_cofactor(n: int) -> int:
    """The k with n = squarefree_part(n) * k^2."""
    return cofactor(n, squarefree_part(n))


# ----------------------------------------------------------------------------------
# 3. The bridge to triangles and to the congruent number curve
# ----------------------------------------------------------------------------------

def rational_triangle_of_node(m: int, n: int) -> Tuple[Fraction, Fraction, Fraction, int]:
    """Scale the node's triangle down to area exactly s, the squarefree part.

    Returns (a, b, c, s) with a^2 + b^2 = c^2 and a*b/2 = s.
    """
    a, b, c = euclid_triple(m, n)
    area = euclid_area(m, n)
    s = squarefree_part(area)
    k = square_cofactor(area)
    return (Fraction(a, k), Fraction(b, k), Fraction(c, k), s)


def curve_point_of_triangle(a: Fraction, c: Fraction) -> Tuple[Fraction, Fraction]:
    """(a, b, c) of area N  ->  point (a(a+c)/2, a^2(a+c)/2) on y^2 = x^3 - N^2 x."""
    return (a * (a + c) / 2, a * a * (a + c) / 2)


def triangle_of_curve_point(n_area: Fraction, x: Fraction, y: Fraction
                            ) -> Tuple[Fraction, Fraction, Fraction]:
    """Inverse map: a point with x > 0, y != 0 back to a triangle of area N."""
    y = abs(y)
    return ((x * x - n_area * n_area) / y, 2 * n_area * x / y, (x * x + n_area * n_area) / y)


def on_curve(n_area: Fraction, x: Fraction, y: Fraction) -> bool:
    return y * y == x ** 3 - n_area * n_area * x


# ----------------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------------

def demo_tree_and_areas() -> None:
    print("=" * 78)
    print("1. The tree, its triples, and the area function A(m,n) = mn(m-n)(m+n)")
    print("=" * 78)
    print(f"{'address':<8}{'seed':<12}{'triple':<22}{'area':>12}   factorisation")
    for word, seed in tree_nodes(2):
        m, n = seed
        area = euclid_area(m, n)
        s, k = squarefree_part(area), square_cofactor(area)
        tag = "root" if word == "" else word
        print(f"{tag:<8}{str(seed):<12}{str(euclid_triple(m, n)):<22}{area:>12}"
              f"   = {s} * {k}^2")
    print()


def demo_enumeration_is_exact(bound: int = 60) -> None:
    print("=" * 78)
    print("2. The tree enumerates every primitive triple exactly once")
    print("=" * 78)
    direct = {(m, n) for m in range(2, bound + 1) for n in range(1, m)
              if is_admissible(m, n)}
    seen: Dict[Seed, str] = {}
    duplicates = 0
    for word, seed in tree_nodes(7):
        if seed in seen:
            duplicates += 1
        seen[seed] = word
    all_admissible = all(is_admissible(*s) for s in seen)
    reachable = all(address(s) is not None for s in direct)
    consistent = all(address(s) == seen[s] for s in seen if s in direct)
    print(f"nodes produced by the tree down to depth 7: {len(seen)} (= 1+3+...+3^7)")
    print(f"  every produced seed is admissible:        {all_admissible}")
    print(f"  duplicate productions:                    {duplicates}")
    print(f"admissible seeds with m <= {bound}:                {len(direct)}")
    print(f"  every one walks back to the root (2,1):   {reachable}")
    print(f"  its address matches the forward search:   {consistent}")
    deep = max(direct, key=lambda s: len(address(s)))
    print(f"  deepest such seed: {deep} at depth {len(address(deep))} "
          f"(depth is unbounded on any m-range)")
    print()


def demo_certified_congruent_numbers(bound: int = 60) -> None:
    print("=" * 78)
    print("3. Certified congruent numbers: squarefree parts of node areas")
    print("=" * 78)
    spf = _spf_sieve(2 * bound)
    best: Dict[int, Tuple[int, Seed, int]] = {}
    for m in range(2, bound + 1):
        for n in range(1, m):
            if not is_admissible(m, n):
                continue
            area = euclid_area(m, n)
            s = squarefree_part_of_area(m, n, spf)
            if s not in best or area < best[s][0]:
                best[s] = (area, (m, n), cofactor(area, s))
    small = sorted(s for s in best if s <= 120)
    print(f"congruent numbers <= 120 certified by a seed with m <= {bound}:")
    print("  " + ", ".join(map(str, small)))
    print()
    print(f"{'s':>5}  {'seed':<10}{'triple':<24}{'area':>12}   witness triangle of area s")
    for s in [5, 6, 7, 14, 15, 21, 30, 34, 41, 65, 210]:
        if s not in best:
            continue
        area, (m, n), k = best[s]
        a, b, c, s2 = rational_triangle_of_node(m, n)
        assert s2 == s and a * b == 2 * s and a * a + b * b == c * c
        print(f"{s:>5}  {str((m, n)):<10}{str(euclid_triple(m, n)):<24}{area:>12}"
              f"   ({a}, {b}, {c})")
    print()
    print("Fibonacci (1225) asked for a rational square differing from 5 by a square;")
    a, b, c, _ = rational_triangle_of_node(5, 4)
    x = c / 2
    print(f"  the seed (5,4) gives the triangle ({a}, {b}, {c}) of area 5, and with x = {x}:")
    print(f"  x^2 - 5 = {x * x - 5} = ({abs(a - b) / 2})^2,  "
          f"x^2 + 5 = {x * x + 5} = ({(a + b) / 2})^2")
    print()


def demo_curve_bridge() -> None:
    print("=" * 78)
    print("4. The bridge to the curve y^2 = x^3 - s^2 x")
    print("=" * 78)
    for seed in [(2, 1), (5, 4), (16, 9), (9, 8)]:
        a, b, c, s = rational_triangle_of_node(*seed)
        x, y = curve_point_of_triangle(a, c)
        ok = on_curve(Fraction(s), x, y)
        back = triangle_of_curve_point(Fraction(s), x, y)
        area_back = back[0] * back[1] / 2
        print(f"seed {str(seed):<8} s = {s:<4} triangle ({a}, {b}, {c})")
        print(f"     -> point (x, y) = ({x}, {y})   on curve: {ok}")
        print(f"     -> back to triangle {tuple(map(str, back))}, area = {area_back}")
    print()


def demo_non_congruence_laws(bound: int = 400) -> None:
    print("=" * 78)
    print("5. Unconditional laws: areas that never occur")
    print("=" * 78)
    bad_primes = [p for p in range(3, 200)
                  if all(p % d for d in range(2, isqrt(p) + 1)) and p % 8 == 3]
    spf = _spf_sieve(2 * bound)
    bad_prime_set = set(bad_primes)
    square_hits = twice_square_hits = prime_hits = 0
    checked = 0
    for m in range(2, bound + 1):
        for n in range(1, m):
            if not is_admissible(m, n):
                continue
            checked += 1
            s = squarefree_part_of_area(m, n, spf)
            if s == 1:
                square_hits += 1
            if s == 2:
                twice_square_hits += 1
            if s in bad_prime_set:
                prime_hits += 1
    print(f"nodes examined (m <= {bound}): {checked}")
    print(f"  nodes with square area          : {square_hits}   (theorem: 0, so 1 is not congruent)")
    print(f"  nodes with area twice a square  : {twice_square_hits}   (theorem: 0, so 2 is not congruent)")
    print(f"  nodes with area p*k^2, p=3 mod 8: {prime_hits}   (theorem: 0, Genocchi's theorem)")
    print(f"  primes p = 3 (mod 8) below 200, all provably non-congruent:")
    print("    " + ", ".join(map(str, bad_primes)))
    print()


def demo_structure() -> None:
    print("=" * 78)
    print("6. Structure of the area function")
    print("=" * 78)
    print("Exact increment identities (checked symbolically on samples):")
    ok_a = ok_b = ok_c = True
    for m in range(2, 40):
        for n in range(1, m):
            if not is_admissible(m, n):
                continue
            base = euclid_area(m, n)
            ok_a &= euclid_area(*move_A((m, n))) == base + 6 * m * m * (m - n) ** 2
            ok_c &= euclid_area(*move_C((m, n))) == base + 6 * n * n * (m + n) ** 2
            ok_b &= (euclid_area(*move_B((m, n)))
                     == 6 * base + m * (m + n) * (6 * m * m - m * n + 7 * n * n))
    print(f"  A(2m-n, m) = A + 6 m^2 (m-n)^2                       : {ok_a}")
    print(f"  A(m+2n, n) = A + 6 n^2 (m+n)^2                       : {ok_c}")
    print(f"  A(2m+n, m) = 6A + m(m+n)(6m^2 - mn + 7n^2)           : {ok_b}")
    print()
    print("The Pell spine (repeated B) and the silver law A_d = 2 t^2 + (-1)^(d+1) t:")
    seed = ROOT
    print(f"{'d':>3}  {'seed':<16}{'t = mn':>12}{'area':>16}{'silver law':>16}"
          f"{'ratio':>10}")
    prev = None
    for d in range(7):
        m, n = seed
        t = m * n
        area = euclid_area(m, n)
        law = 2 * t * t + (-1) ** (d + 1) * t
        ratio = "" if prev is None else f"{area / prev:.3f}"
        print(f"{d:>3}  {str(seed):<16}{t:>12}{area:>16}{law:>16}{ratio:>10}")
        assert area == law and area >= 6 ** (d + 1)
        prev = area
        seed = move_B(seed)
    print("  (the ratio tends to (1 + sqrt 2)^4 = 17 + 12 sqrt 2 = 33.97..., "
          "and always exceeds 6)")
    print()
    print("Properness: A(m,n) > m^2, so only finitely many nodes lie below any bound.")
    for X in [100, 1000, 10000, 100000]:
        count = sum(1 for m in range(2, isqrt(X) + 2) for n in range(1, m)
                    if is_admissible(m, n) and euclid_area(m, n) <= X)
        print(f"  nodes of area <= {X:>7}: {count:>4}   (all have m <= sqrt(X) = {isqrt(X)})")
    print()


def demo_depths(bound: int = 400) -> None:
    print("=" * 78)
    print("7. Depth statistics: where in the tree each congruent number first appears")
    print("=" * 78)
    spf = _spf_sieve(2 * bound)
    first: Dict[int, Tuple[int, Seed, str]] = {}
    for m in range(2, bound + 1):
        for n in range(1, m):
            if not is_admissible(m, n):
                continue
            s = squarefree_part_of_area(m, n, spf)
            word = address((m, n))
            if s not in first or len(word) < first[s][0]:
                first[s] = (len(word), (m, n), word)
    print(f"{'s':>5}{'depth':>7}  {'seed':<12}address")
    for s in sorted(k for k in first if k <= 100):
        depth, seed, word = first[s]
        print(f"{s:>5}{depth:>7}  {str(seed):<12}{word if word else '(root)'}")
    depths = [v[0] for v in first.values()]
    print()
    print(f"squarefree parts found with seeds m <= {bound}: {len(first)}")
    print(f"maximum first-appearance depth among them:   {max(depths)}")
    print("Small congruent numbers can hide very deep: 157 is congruent, but its")
    print("simplest triangle has a 45-digit numerator, so its first node lies far")
    print("beyond any depth reachable here.")
    print()


def main() -> None:
    demo_tree_and_areas()
    demo_enumeration_is_exact()
    demo_certified_congruent_numbers()
    demo_curve_bridge()
    demo_non_congruence_laws()
    demo_structure()
    demo_depths()
    print("=" * 78)
    print("Summary: the squarefree parts of the areas mn(m-n)(m+n) of the nodes of the")
    print("Berggren tree are exactly the congruent numbers, and the same data is exactly")
    print("the set of rational points with x > 0, y != 0 on y^2 = x^3 - s^2 x.")
    print("=" * 78)


if __name__ == "__main__":
    main()
