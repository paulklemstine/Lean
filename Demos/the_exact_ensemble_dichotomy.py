"""
The Exact Ensemble Dichotomy and Even Closed Walks
==================================================

Self-contained numerical demonstration of the results:

  1. The exact ensemble dichotomy:
         E[ prod_t W_{a_t b_t} ]  =  1  if loop-free and all edge multiplicities even
                                  =  0  otherwise,
     for the symmetric coin-flip matrix W (zero diagonal, i.i.d. uniform signs off it).

  2. The walk-counting dictionary:  E[tr(W^L)] = E(N, L),  the number of *even*
     closed walks of length L on N vertices (never stands still, every edge used an
     even number of times).  Verified by brute-force averaging over all 2^C(N,2)
     sign configurations.

  3. Exact vanishing of every odd moment at every finite N.

  4. Structural bounds: an even closed L-walk uses <= L/2 edges and visits
     <= L/2 + 1 vertices.

  5. Polynomiality:  E(N, L) = sum_r C(N, r) * b_{r,L}  with dimension-free shape
     counts b_{r,L}, vanishing for 2r > L + 2.

  6. The exact moment polynomials
         E(N, 2) = N(N-1),
         E(N, 4) = N(N-1)(2N-3),
         E(N, 6) = N(N-1)(5N^2 - 15N + 11).

  7. The Catalan law for top shapes:  b_{k+1, 2k} = C_k * (k+1)!  for k = 1, 2, 3,
     and the convergence  E[M_6] = 5 - 20/N + 26/N^2 - 11/N^3  ->  5 = C_3.

Run with:  python3 demo.py     (standard library only)
"""

from __future__ import annotations

from itertools import combinations, product
from math import comb, factorial
from typing import Dict, Iterator, List, Sequence, Tuple

Walk = Tuple[int, ...]
Edge = Tuple[int, int]
Config = Dict[Edge, int]


# ---------------------------------------------------------------------------
# Basic combinatorial machinery
# ---------------------------------------------------------------------------


def edge_of(u: int, v: int) -> Edge:
    """Canonical unordered pair {u, v}, encoded as a sorted tuple."""
    return (u, v) if u <= v else (v, u)


def edge_multiplicities(walk: Walk) -> Dict[Edge, int]:
    """Multiset of edges traversed by the cyclic closed walk `walk`."""
    length = len(walk)
    mult: Dict[Edge, int] = {}
    for t in range(length):
        e = edge_of(walk[t], walk[(t + 1) % length])
        mult[e] = mult.get(e, 0) + 1
    return mult


def is_even_closed_walk(walk: Walk) -> bool:
    """A closed walk is *even* if it never stands still and every edge
    multiplicity is even."""
    length = len(walk)
    for t in range(length):
        if walk[t] == walk[(t + 1) % length]:
            return False
    return all(m % 2 == 0 for m in edge_multiplicities(walk).values())


def even_closed_walks(n: int, length: int) -> Iterator[Walk]:
    """Enumerate all even closed walks of the given length on n vertices."""
    for walk in product(range(n), repeat=length):
        if is_even_closed_walk(walk):
            yield walk


def even_closed_walk_count(n: int, length: int) -> int:
    """E(N, L): the number of even closed walks of length L on N vertices."""
    return sum(1 for _ in even_closed_walks(n, length))


def shape_count(r: int, length: int) -> int:
    """b_{r,L}: even closed L-walks on r vertices that visit *every* vertex."""
    total = 0
    for walk in even_closed_walks(r, length):
        if len(set(walk)) == r:
            total += 1
    return total


def catalan(k: int) -> int:
    """The k-th Catalan number C_k = binom(2k, k) / (k + 1)."""
    return comb(2 * k, k) // (k + 1)


# ---------------------------------------------------------------------------
# Brute-force ensemble averaging
# ---------------------------------------------------------------------------


def all_configurations(n: int) -> Iterator[Config]:
    """All 2^C(n,2) sign assignments to the edges of the complete graph on n vertices."""
    pairs: List[Edge] = list(combinations(range(n), 2))
    for signs in product((-1, 1), repeat=len(pairs)):
        yield dict(zip(pairs, signs))


def matrix_of(config: Config, n: int) -> List[List[int]]:
    """The symmetric coin-flip matrix W with zero diagonal for a configuration."""
    mat = [[0] * n for _ in range(n)]
    for (i, j), s in config.items():
        mat[i][j] = s
        mat[j][i] = s
    return mat


def mat_mul(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]]) -> List[List[int]]:
    """Exact integer matrix product."""
    n = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]


def trace_power(mat: Sequence[Sequence[int]], power: int) -> int:
    """tr(M^power), computed exactly over the integers."""
    n = len(mat)
    acc: List[List[int]] = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
    for _ in range(power):
        acc = mat_mul(acc, mat)
    return sum(acc[i][i] for i in range(n))


def expected_trace_power(n: int, power: int) -> float:
    """E[tr(W^power)] by exhaustive averaging over all sign configurations."""
    configs = list(all_configurations(n))
    total = sum(trace_power(matrix_of(g, n), power) for g in configs)
    return total / len(configs)


def expected_monomial(n: int, steps: Sequence[Tuple[int, int]]) -> float:
    """E[ prod_t W_{a_t b_t} ] by exhaustive averaging."""
    configs = list(all_configurations(n))
    total = 0
    for g in configs:
        prod = 1
        for a, b in steps:
            if a == b:
                prod = 0
                break
            prod *= g[edge_of(a, b)]
        total += prod
    return total / len(configs)


# ---------------------------------------------------------------------------
# Closed-form moment polynomials
# ---------------------------------------------------------------------------


def moment_poly_two(n: int) -> int:
    return n * (n - 1)


def moment_poly_four(n: int) -> int:
    return n * (n - 1) * (2 * n - 3)


def moment_poly_six(n: int) -> int:
    return n * (n - 1) * (5 * n * n - 15 * n + 11)


def count_from_shapes(n: int, shapes: Dict[int, int]) -> int:
    """Assemble E(N, L) = sum_r C(N, r) * b_{r,L} from a shape table."""
    return sum(comb(n, r) * b for r, b in shapes.items())


def normalized_moment_six(n: int) -> float:
    """E[ (1/N) tr( (W/sqrt N)^6 ) ] = (N-1)(5N^2 - 15N + 11) / N^3."""
    return (n - 1) * (5 * n * n - 15 * n + 11) / n**3


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_dichotomy() -> None:
    print("=" * 74)
    print("1. THE EXACT ENSEMBLE DICHOTOMY")
    print("=" * 74)
    print("   E[prod W_{a b}] is always exactly 0 or 1 -- never anything between.\n")
    n = 4
    examples: List[Tuple[str, List[Tuple[int, int]]]] = [
        ("single step (0,1)                 ", [(0, 1)]),
        ("(0,1),(1,0)  -- edge used twice   ", [(0, 1), (1, 0)]),
        ("(0,1),(1,2)  -- two odd edges     ", [(0, 1), (1, 2)]),
        ("(0,1)x2, (2,3)x2                  ", [(0, 1), (1, 0), (2, 3), (3, 2)]),
        ("(0,1)x3      -- odd multiplicity  ", [(0, 1), (0, 1), (1, 0)]),
        ("(0,1)x4                           ", [(0, 1)] * 4),
        ("loop (2,2) with even partner      ", [(2, 2), (0, 1), (1, 0)]),
    ]
    print(f"   {'family of steps':<36}{'loop-free':>10}{'all even':>10}{'E[.]':>8}")
    for label, steps in examples:
        mult = {}
        for a, b in steps:
            e = edge_of(a, b)
            mult[e] = mult.get(e, 0) + 1
        loop_free = all(a != b for a, b in steps)
        all_even = all(m % 2 == 0 for m in mult.values())
        value = expected_monomial(n, steps)
        predicted = 1.0 if (loop_free and all_even) else 0.0
        assert abs(value - predicted) < 1e-12, (label, value, predicted)
        print(f"   {label:<36}{str(loop_free):>10}{str(all_even):>10}{value:>8.0f}")
    print("\n   All averages matched the dichotomy exactly.\n")


def demo_dictionary() -> None:
    print("=" * 74)
    print("2. EVERY TRACE MOMENT IS A COUNT OF EVEN CLOSED WALKS")
    print("=" * 74)
    print("   E[tr(W^L)] = E(N, L), verified by brute force over all 2^C(N,2) configs.\n")
    print(f"   {'N':>3}{'L':>4}{'E[tr(W^L)]  (brute force)':>28}{'even closed walks':>22}")
    for n in (2, 3, 4):
        for length in (1, 2, 3, 4, 5, 6):
            avg = expected_trace_power(n, length)
            cnt = even_closed_walk_count(n, length)
            assert abs(avg - cnt) < 1e-9, (n, length, avg, cnt)
            print(f"   {n:>3}{length:>4}{avg:>28.4f}{cnt:>22}")
    print("\n   Identical in every case -- an exact identity, not an asymptotic.\n")


def demo_odd_vanishing() -> None:
    print("=" * 74)
    print("3. ALL ODD MOMENTS VANISH EXACTLY, AT EVERY FINITE N")
    print("=" * 74)
    print("   Length = sum of edge multiplicities; even multiplicities force even length.\n")
    print(f"   {'N':>3}   " + "".join(f"L={L:<7}" for L in (1, 3, 5, 7)))
    for n in range(1, 6):
        row = "".join(f"{even_closed_walk_count(n, L):<9}" for L in (1, 3, 5, 7))
        for L in (1, 3, 5, 7):
            assert even_closed_walk_count(n, L) == 0
        print(f"   {n:>3}   {row}")
    print("\n   Every entry is zero: no approximation, no limit.\n")


def demo_structure_bounds() -> None:
    print("=" * 74)
    print("4. STRUCTURAL BOUNDS: <= L/2 EDGES AND <= L/2 + 1 VERTICES")
    print("=" * 74)
    for length in (2, 4, 6):
        n = 5
        max_edges = 0
        max_vertices = 0
        for walk in even_closed_walks(n, length):
            max_edges = max(max_edges, len(edge_multiplicities(walk)))
            max_vertices = max(max_vertices, len(set(walk)))
        assert 2 * max_edges <= length
        assert 2 * max_vertices <= length + 2
        print(
            f"   L = {length}:  max distinct edges = {max_edges} (bound {length // 2}),"
            f"  max distinct vertices = {max_vertices} (bound {length // 2 + 1})"
        )
    print("\n   Both bounds are attained -- the extremal walks are doubled trees.\n")


def demo_polynomiality() -> None:
    print("=" * 74)
    print("5. POLYNOMIALITY:  E(N, L) = sum_r C(N, r) * b_{r,L}")
    print("=" * 74)
    print("   The shape counts b_{r,L} do not depend on N at all.\n")
    for length in (2, 4, 6):
        shapes = {}
        for r in range(0, length // 2 + 2):
            b = shape_count(r, length)
            if b:
                shapes[r] = b
        pretty = "  +  ".join(f"{b} * C(N,{r})" for r, b in sorted(shapes.items()))
        print(f"   L = {length}:  E(N, {length}) = {pretty}")
        for n in range(0, 8):
            direct = even_closed_walk_count(n, length) if n else 0
            assembled = count_from_shapes(n, shapes)
            assert direct == assembled, (n, length, direct, assembled)
        print(f"             verified against direct enumeration for N = 0 .. 7")
    print()


def demo_exact_polynomials() -> None:
    print("=" * 74)
    print("6. THE EXACT MOMENT POLYNOMIALS")
    print("=" * 74)
    print("   E(N,2) = N(N-1),  E(N,4) = N(N-1)(2N-3),  E(N,6) = N(N-1)(5N^2-15N+11)\n")
    header = f"   {'N':>3}{'E(N,2)':>12}{'formula':>12}{'E(N,4)':>12}{'formula':>12}"
    header += f"{'E(N,6)':>12}{'formula':>12}"
    print(header)
    for n in range(0, 6):
        c2 = even_closed_walk_count(n, 2)
        c4 = even_closed_walk_count(n, 4)
        c6 = even_closed_walk_count(n, 6)
        f2, f4, f6 = moment_poly_two(n), moment_poly_four(n), moment_poly_six(n)
        assert (c2, c4, c6) == (f2, f4, f6), (n, c2, c4, c6, f2, f4, f6)
        print(f"   {n:>3}{c2:>12}{f2:>12}{c4:>12}{f4:>12}{c6:>12}{f6:>12}")
    print("\n   Enumeration and closed form agree exactly.\n")


def demo_catalan_and_limit() -> None:
    print("=" * 74)
    print("7. TOP SHAPES ARE CATALAN, AND THE SIXTH MOMENT CONVERGES TO 5")
    print("=" * 74)
    print("   Conjectured law:  b_{k+1, 2k} = C_k * (k+1)!\n")
    print(f"   {'k':>3}{'b_{k+1,2k}':>14}{'C_k':>8}{'(k+1)!':>10}{'C_k*(k+1)!':>14}")
    for k in (1, 2, 3):
        b = shape_count(k + 1, 2 * k)
        predicted = catalan(k) * factorial(k + 1)
        assert b == predicted, (k, b, predicted)
        print(f"   {k:>3}{b:>14}{catalan(k):>8}{factorial(k + 1):>10}{predicted:>14}")
    print("\n   Leading coefficients are therefore the Catalan numbers 1, 2, 5.\n")
    print("   Expected normalised sixth moment  (N-1)(5N^2-15N+11)/N^3  ->  C_3 = 5:\n")
    print(f"   {'N':>8}{'E[M_6]':>14}{'defect from 5':>18}{'N * defect':>14}")
    for n in (2, 5, 10, 50, 100, 1000, 10000):
        m6 = normalized_moment_six(n)
        defect = 5 - m6
        print(f"   {n:>8}{m6:>14.6f}{defect:>18.6f}{n * defect:>14.4f}")
    print("\n   N * defect -> 20: the finite-size correction is exactly -20/N + O(1/N^2).\n")


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE EXACT ENSEMBLE DICHOTOMY AND THE COMBINATORICS OF EVEN CLOSED WALKS")
    print("#" * 74)
    print()
    demo_dichotomy()
    demo_dictionary()
    demo_odd_vanishing()
    demo_structure_bounds()
    demo_polynomiality()
    demo_exact_polynomials()
    demo_catalan_and_limit()
    print("=" * 74)
    print("All assertions passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
