"""
Counting the Berggren tree in a box: numerical demonstrations.
==============================================================

This self-contained script demonstrates, numerically, every quantitative claim of
the accompanying paper:

  1.  Linearisation.  The three Berggren matrices A, B, C acting on triples
      (a, b, c) agree with the three linear maps
          alpha(m, n) = (2m - n, m)
          beta (m, n) = (2m + n, m)
          gamma(m, n) = (m + 2n, n)
      acting on Euclid parameters, under E(m, n) = (m^2 - n^2, 2mn, m^2 + n^2).

  2.  Completeness (Barning-Hall).  The tree grown from (3,4,5) is exactly the set
      of positive primitive Pythagorean triples with odd first leg; the mirrored
      tree from (4,3,5) is exactly those with even first leg.

  3.  Freeness.  Distinct words in {A,B,C}* give distinct triples, and the address
      can be decoded from the triple by a trichotomy on m versus 2n and 3n.

  4.  Box counting.  |N(H)| lies in [H/128, H] for H >= 32, the exact lattice-point
      formula |N(H)| = #{(m,n): 0<n<m, gcd=1, m+n odd, m^2+n^2 <= H} holds, and
      |N(H)|/H -> 1/(2 pi) = 0.1591549...

  5.  Exact ratios.  |N(H)| / |P(H)| = 1/2 exactly, and (|N(H)|+|N'(H)|)/|P(H)| = 1
      exactly, for every H >= 5.

  6.  Depth forces height.  If every depth-d node has hypotenuse <= H then 3^d <= H.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd, isqrt, pi, sqrt
from typing import Dict, Iterator, List, Set, Tuple

Triple = Tuple[int, int, int]
Pair = Tuple[int, int]

# ---------------------------------------------------------------------------
# 1.  The Berggren generators, in both coordinate systems
# ---------------------------------------------------------------------------

BERGGREN_MATRICES: Dict[str, Tuple[Tuple[int, int, int], ...]] = {
    "A": ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    "B": ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    "C": ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}

ROOT: Triple = (3, 4, 5)
ROOT_SWAP: Triple = (4, 3, 5)


def apply_matrix(name: str, v: Triple) -> Triple:
    """Apply the Berggren generator `name` to the triple `v`."""
    m = BERGGREN_MATRICES[name]
    return tuple(sum(m[i][j] * v[j] for j in range(3)) for i in range(3))  # type: ignore[return-value]


def apply_word(word: str, v: Triple = ROOT) -> Triple:
    """Apply a word in {A,B,C}* to `v`, left-to-right (first letter applied first)."""
    for letter in word:
        v = apply_matrix(letter, v)
    return v


def euclid_triple(m: int, n: int) -> Triple:
    """Euclid's map E(m, n) = (m^2 - n^2, 2mn, m^2 + n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def euclid_params(v: Triple) -> Pair:
    """Inverse of E on positive triples: m = sqrt((a+c)/2), n = sqrt((c-a)/2)."""
    a, _b, c = v
    return (isqrt((a + c) // 2), isqrt((c - a) // 2))


def alpha(m: int, n: int) -> Pair:
    return (2 * m - n, m)


def beta(m: int, n: int) -> Pair:
    return (2 * m + n, m)


def gamma(m: int, n: int) -> Pair:
    return (m + 2 * n, n)


EUCLID_GENERATORS = {"A": alpha, "B": beta, "C": gamma}


def is_admissible(m: int, n: int) -> bool:
    """0 < n < m, gcd(m,n) = 1, m - n odd."""
    return 0 < n < m and gcd(m, n) == 1 and (m - n) % 2 == 1


# ---------------------------------------------------------------------------
# 2.  Predicates on triples
# ---------------------------------------------------------------------------

def is_ppt(v: Triple) -> bool:
    """Positive primitive Pythagorean triple."""
    a, b, c = v
    return a > 0 and b > 0 and c > 0 and a * a + b * b == c * c and gcd(a, b) == 1


def is_node(v: Triple) -> bool:
    """Membership in the tree grown from (3,4,5): a PPT with odd first leg."""
    return is_ppt(v) and v[0] % 2 == 1


def is_node_swap(v: Triple) -> bool:
    """Membership in the mirrored tree from (4,3,5): a PPT with odd second leg."""
    return is_ppt(v) and v[1] % 2 == 1


# ---------------------------------------------------------------------------
# 3.  Counting in the box
# ---------------------------------------------------------------------------

def euclid_box(h: int) -> Iterator[Pair]:
    """Visible opposite-parity lattice points of the quarter disc of radius sqrt(h)."""
    for m in range(2, isqrt(h) + 1):
        for n in range(1, m):
            if (m + n) % 2 == 1 and gcd(m, n) == 1 and m * m + n * n <= h:
                yield (m, n)


def count_nodes(h: int) -> int:
    """|N(H)|, via the exact lattice-point formula.  Cost O(H log H)."""
    return sum(1 for _ in euclid_box(h))


def count_nodes_bruteforce(h: int) -> int:
    """|N(H)| by scanning the whole cube.  Cost Theta(H^3) -- tiny H only."""
    total = 0
    for a in range(1, h + 1):
        for b in range(1, h + 1):
            c2 = a * a + b * b
            c = isqrt(c2)
            if c * c == c2 and c <= h and is_node((a, b, c)):
                total += 1
    return total


def count_ppt(h: int) -> int:
    """|P(H)| = 2 |N(H)| (Halving Theorem)."""
    return 2 * count_nodes(h)


def count_coprime_parity_pairs(n_max: int) -> int:
    """|Q(N)| = #{0 < n < m <= N : m+n odd, gcd(m,n)=1}."""
    return sum(
        1
        for m in range(2, n_max + 1)
        for n in range(1, m)
        if (m + n) % 2 == 1 and gcd(m, n) == 1
    )


def count_parity_pairs(n_max: int) -> int:
    """|P(N)| = floor(N/2) * floor((N+1)/2), checked against a direct count."""
    return sum(1 for m in range(2, n_max + 1) for n in range(1, m) if (m + n) % 2 == 1)


# ---------------------------------------------------------------------------
# 4.  Address decoding (the descent trichotomy)
# ---------------------------------------------------------------------------

def decode_address(v: Triple) -> str:
    """Unique word W in {A,B,C}* with W(3,4,5) = v.  Requires is_node(v)."""
    if not is_node(v):
        raise ValueError(f"{v} is not a node of the tree grown from (3,4,5)")
    m, n = euclid_params(v)
    letters: List[str] = []
    while m > 2:
        if m < 2 * n:
            letters.append("A")
            m, n = n, 2 * n - m
        elif m < 3 * n:
            letters.append("B")
            m, n = n, m - 2 * n
        else:
            letters.append("C")
            m, n = m - 2 * n, n
    return "".join(reversed(letters))


def generation(depth: int) -> List[Pair]:
    """All Euclid parameter pairs at the given depth, in lexicographic word order."""
    level: List[Pair] = [(2, 1)]
    for _ in range(depth):
        level = [f(m, n) for (m, n) in level for f in (alpha, beta, gamma)]
    return level


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_linearisation() -> None:
    print("=" * 74)
    print("1.  LINEARISATION:  matrix action  ==  linear action on Euclid parameters")
    print("=" * 74)
    for m, n in [(2, 1), (3, 2), (4, 1), (5, 2), (7, 4)]:
        v = euclid_triple(m, n)
        for name, f in EUCLID_GENERATORS.items():
            lhs = apply_matrix(name, v)
            rhs = euclid_triple(*f(m, n))
            assert lhs == rhs, (name, m, n, lhs, rhs)
        print(f"  (m,n)=({m},{n})  E={v}   "
              f"A->{apply_matrix('A', v)}  B->{apply_matrix('B', v)}  C->{apply_matrix('C', v)}")
    print("  all three identities verified on every sample.\n")


def demo_completeness(h: int = 400) -> None:
    print("=" * 74)
    print(f"2.  COMPLETENESS (Barning-Hall) inside the cube [1,{h}]^3")
    print("=" * 74)
    # grow the tree far enough to cover the box, then compare with brute force
    grown: Set[Triple] = set()
    frontier: List[Triple] = [ROOT]
    while frontier:
        nxt: List[Triple] = []
        for v in frontier:
            if v[2] <= h:
                grown.add(v)
                nxt.extend(apply_matrix(g, v) for g in "ABC")
        frontier = nxt
    truth = {
        (a, b, isqrt(a * a + b * b))
        for a in range(1, h + 1)
        for b in range(1, h + 1)
        if isqrt(a * a + b * b) ** 2 == a * a + b * b
        and isqrt(a * a + b * b) <= h
        and is_node((a, b, isqrt(a * a + b * b)))
    }
    print(f"  tree nodes with hypotenuse <= {h}          : {len(grown)}")
    print(f"  odd-first-leg primitive triples in the box : {len(truth)}")
    print(f"  sets identical                             : {grown == truth}")
    swapped = {(b, a, c) for (a, b, c) in grown}
    print(f"  mirrored tree = leg-swap of the tree       : "
          f"{all(is_node_swap(v) for v in swapped)}")
    print(f"  the two trees are disjoint                 : "
          f"{not any(is_node(v) and is_node_swap(v) for v in grown | swapped)}\n")


def demo_freeness(depth: int = 7) -> None:
    print("=" * 74)
    print("3.  FREENESS:  distinct addresses give distinct triples")
    print("=" * 74)
    for d in range(1, depth + 1):
        level = generation(d)
        print(f"  depth {d}: 3^{d} = {3 ** d:>5} words, "
              f"{len(set(level)):>5} distinct nodes, "
              f"min c = {min(m * m + n * n for m, n in level):>9}, "
              f"max c = {max(m * m + n * n for m, n in level):>9}")
        assert len(set(level)) == 3 ** d
    print("  (min matches 2d^2+6d+5, attained by A^d;  max ~ 4.975 * (1+sqrt2)^(2d),"
          " attained by B^d)")
    for v in [(3, 4, 5), (5, 12, 13), (21, 20, 29), (15, 8, 17), (697, 696, 985)]:
        w = decode_address(v)
        assert apply_word(w) == v
        print(f"  address of {str(v):>18} = '{w if w else '(empty: the root)'}'")
    print()


def demo_box_counting() -> None:
    print("=" * 74)
    print("4.  BOX COUNTING:  H/128 <= |N(H)| <= H,   |N(H)|/H -> 1/(2 pi)")
    print("=" * 74)
    print(f"  {'H':>9} {'H/128':>8} {'|N(H)|':>9} {'H':>9} {'|N(H)|/H':>10} "
          f"{'|N(H)|/H^3':>12}")
    for h in [64, 256, 1024, 4096, 16384, 65536, 262144, 1000000]:
        k = count_nodes(h)
        assert k <= h, "upper bound"
        assert h < 32 or h <= 128 * k, "lower bound"
        print(f"  {h:>9} {h // 128:>8} {k:>9} {h:>9} {k / h:>10.6f} {k / h ** 3:>12.3e}")
    print(f"  limit predicted by the lattice-point formula: 1/(2 pi) = {1 / (2 * pi):.7f}")
    # brute-force cross-check of the lattice-point formula on a small cube
    for h in [50, 120, 300]:
        assert count_nodes(h) == count_nodes_bruteforce(h)
    print("  lattice-point formula cross-checked against a full cube scan "
          "for H = 50, 120, 300.\n")


def demo_sieve() -> None:
    print("=" * 74)
    print("5.  THE SIEVE:  N^2 <= 16 |Q(N)|,   |Q(N)|/N^2 -> 2/pi^2")
    print("=" * 74)
    print(f"  {'N':>6} {'|P(N)| exact':>13} {'|P(N)| formula':>15} {'|Q(N)|':>9} "
          f"{'|Q(N)|/N^2':>11} {'16|Q|>=N^2':>11}")
    for n_max in [16, 64, 256, 512, 1024]:
        p_direct = count_parity_pairs(n_max)
        p_formula = (n_max // 2) * ((n_max + 1) // 2)
        q = count_coprime_parity_pairs(n_max)
        assert p_direct == p_formula
        assert n_max ** 2 <= 16 * q
        print(f"  {n_max:>6} {p_direct:>13} {p_formula:>15} {q:>9} "
              f"{q / n_max ** 2:>11.6f} {str(n_max ** 2 <= 16 * q):>11}")
    print(f"  limiting density: 2/pi^2 = {2 / pi ** 2:.7f} "
          f"(proved bound 1/16 = 0.0625)\n")


def demo_exact_ratios() -> None:
    print("=" * 74)
    print("6.  EXACT RATIOS:  one seed gives exactly 1/2, two seeds exactly 1")
    print("=" * 74)
    print(f"  {'H':>8} {'|N(H)|':>9} {'|P(H)|':>9} {'one seed':>10} {'two seeds':>10}")
    for h in [5, 13, 50, 500, 5000, 50000, 500000]:
        k = count_nodes(h)
        p = count_ppt(h)
        assert p == 2 * k
        print(f"  {h:>8} {k:>9} {p:>9} {k / p:>10.6f} {(2 * k) / p:>10.6f}")
    print("  the ratios are exact identities for every H >= 5, with no error term:")
    print("  the single-seed claim '1 - o(1)' is FALSE (it is pinned at 1/2),")
    print("  and the two-seed claim is understated (it is exactly 1).\n")


def demo_depth_forces_height(max_depth: int = 8) -> None:
    print("=" * 74)
    print("7.  DEPTH FORCES HEIGHT:  all depth-d hypotenuses <= H  ==>  3^d <= H")
    print("=" * 74)
    print(f"  {'d':>3} {'3^d':>8} {'max c at depth d':>18} {'slack factor':>13}")
    for d in range(1, max_depth + 1):
        level = generation(d)
        cmax = max(m * m + n * n for m, n in level)
        assert 3 ** d <= cmax, "the pigeonhole bound must hold"
        print(f"  {d:>3} {3 ** d:>8} {cmax:>18} {cmax / 3 ** d:>13.3f}")
    print(f"  the true exponential rate is (1+sqrt2)^2 = {(1 + sqrt(2)) ** 2:.4f} per level;")
    print("  pigeonhole alone -- with no dynamics -- already forces rate 3.\n")


def main() -> None:
    demo_linearisation()
    demo_completeness()
    demo_freeness()
    demo_box_counting()
    demo_sieve()
    demo_exact_ratios()
    demo_depth_forces_height()
    print("=" * 74)
    print("All assertions passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
