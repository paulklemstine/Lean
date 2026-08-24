"""
The Two-Adic Price Law — numerical demonstrations
==================================================

The Price tree is a ternary tree whose nodes are the *Euclid parameter pairs*
(m, n) with m > n > 0, gcd(m, n) = 1 and m, n of opposite parity.  Each such
pair encodes the primitive Pythagorean triple

    (m^2 - n^2,  2mn,  m^2 + n^2),

and the odd leg is  N = m^2 - n^2 = (m - n)(m + n).  The root is (2, 1) (the
triple (3, 4, 5)), and the three children of (m, n) are

    A : (m, n) |-> (m + n, 2n)
    B : (m, n) |-> (2m, m - n)
    C : (m, n) |-> (2m, m + n).

Every primitive pair is reached exactly once, so every node carries a unique
*address*: the word over {A, B, C} spelling the path from the root.

This script demonstrates, purely numerically, the Two-Adic Price Law:

  1. Reading the address BACKWARDS from the leaf, the letter at position 0 is A
     iff N = 1 (mod 4), and the letter at position 1 is A iff N mod 8 is in
     {1, 3}.  The pair of A-nesses at positions 0 and 1 is a BIJECTION with
     N mod 8 in {1, 3, 5, 7}.
  2. The run mechanism: with U = p + q = 2m and V = q - p = 2n (where p = m - n,
     q = m + n), an A step halves V and requires v2(U) = 1; a B or C step halves
     U and requires v2(U) >= 2.  Hence non-A steps decrement v2(U) by one and
     the first A of the address sits at position v2(U) - 1 = v2(m).
  3. Position 2 onwards is SEALED: no function of N whatsoever - hence no
     residue N mod 2^k, at any depth k - determines the A-ness of the letter at
     any position t >= 2.  Explicit twin families witness this, and the sealing
     survives even when the depth of the node is handed over as free side
     information.
  4. The mutual information I(N mod 2^k ; first two letters) saturates exactly
     at modulus 8.

Run:  python3 demo.py
"""

from __future__ import annotations

from collections import defaultdict
from math import gcd, log2
from typing import Dict, Iterator, List, Optional, Tuple

Pair = Tuple[int, int]

# ----------------------------------------------------------------------------
# 1. The tree: validity, moves, parent, addresses
# ----------------------------------------------------------------------------

ROOT: Pair = (2, 1)


def is_valid(p: Pair) -> bool:
    """A Euclid parameter pair: m > n > 0, coprime, of opposite parity."""
    m, n = p
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def odd_leg(p: Pair) -> int:
    """The odd leg N = m^2 - n^2 of the primitive triple of the node."""
    m, n = p
    return m * m - n * n


def step(letter: str, p: Pair) -> Pair:
    """One downward move of the Price tree."""
    m, n = p
    if letter == "A":
        return (m + n, 2 * n)
    if letter == "B":
        return (2 * m, m - n)
    if letter == "C":
        return (2 * m, m + n)
    raise ValueError(f"unknown letter {letter!r}")


def letter_of(p: Pair) -> str:
    """Which move produced this node: A if n is even, else B or C by size."""
    m, n = p
    if n % 2 == 0:
        return "A"
    return "B" if 2 * n < m else "C"


def parent(p: Pair) -> Pair:
    """Invert the move that produced p."""
    m, n = p
    if n % 2 == 0:
        return (m - n // 2, n // 2)
    if 2 * n < m:
        return (m // 2, m // 2 - n)
    return (m // 2, n - m // 2)


def address(p: Pair) -> str:
    """The word over {A,B,C} spelling the path from the root down to p."""
    word: List[str] = []
    while p != ROOT:
        word.append(letter_of(p))
        p = parent(p)
    return "".join(reversed(word))


def letter_at(p: Pair, t: int) -> str:
    """The letter at position t counted BACKWARDS from the leaf."""
    for _ in range(t):
        p = parent(p)
    return letter_of(p)


def depth(p: Pair) -> int:
    """The length of the address, i.e. the distance from the root."""
    return len(address(p))


def v2(x: int) -> int:
    """The 2-adic valuation of a positive integer."""
    k = 0
    while x % 2 == 0:
        x //= 2
        k += 1
    return k


def all_nodes(bound: int) -> Iterator[Pair]:
    """All valid Euclid pairs with m < bound."""
    for m in range(2, bound):
        for n in range(1, m):
            if is_valid((m, n)):
                yield (m, n)


def evaluate(word: str) -> Pair:
    """The node reached from the root by following an address word."""
    p = ROOT
    for ch in word:
        p = step(ch, p)
    return p


# ----------------------------------------------------------------------------
# 2. The two visible clicks
# ----------------------------------------------------------------------------

def check_two_clicks(bound: int = 300) -> Dict[str, int]:
    """Positions 0 and 1 are read off N mod 8; check exhaustively."""
    bad0 = bad1 = tested = 0
    for p in all_nodes(bound):
        if depth(p) < 2:
            continue
        tested += 1
        N = odd_leg(p)
        if (letter_at(p, 0) == "A") != (N % 4 == 1):
            bad0 += 1
        if (letter_at(p, 1) == "A") != (N % 8 in (1, 3)):
            bad1 += 1
    return {"tested": tested, "violations_pos0": bad0, "violations_pos1": bad1}


def mod8_dictionary(bound: int = 300) -> Dict[int, set]:
    """Which (A-ness at 0, A-ness at 1) patterns occur in each class mod 8."""
    table: Dict[int, set] = defaultdict(set)
    for p in all_nodes(bound):
        if depth(p) < 2:
            continue
        table[odd_leg(p) % 8].add(
            (letter_at(p, 0) == "A", letter_at(p, 1) == "A")
        )
    return dict(sorted(table.items()))


def b_versus_c(bound: int = 300) -> Dict[str, int]:
    """B occurs iff N = 3 mod 4 AND q < 3p: a congruence plus a pure size rule."""
    bad = nB = nC = 0
    for p in all_nodes(bound):
        m, n = p
        small, big = m - n, m + n
        predicted_B = (odd_leg(p) % 4 == 3) and (big < 3 * small)
        actual = letter_of(p)
        if (actual == "B") != predicted_B:
            bad += 1
        nB += actual == "B"
        nC += actual == "C"
    return {"violations": bad, "count_B": nB, "count_C": nC}


# ----------------------------------------------------------------------------
# 3. The run mechanism
# ----------------------------------------------------------------------------

def check_run_laws(bound: int = 400) -> Dict[str, int]:
    """First-A law (n odd) and A-run law (n even), checked exhaustively."""
    bad_first_A = bad_A_run = 0
    for p in all_nodes(bound):
        m, n = p
        d = depth(p)
        if n % 2 == 1:
            k = v2(m)  # = v2(U) - 1 with U = p + q = 2m
            if k < d:
                if letter_at(p, k) != "A":
                    bad_first_A += 1
                if any(letter_at(p, t) == "A" for t in range(k)):
                    bad_first_A += 1
        else:
            k = v2(n)  # = v2(V) - 1 with V = q - p = 2n
            if k < d:
                if letter_at(p, k) == "A":
                    bad_A_run += 1
                if any(letter_at(p, t) != "A" for t in range(k)):
                    bad_A_run += 1
    return {"violations_first_A": bad_first_A, "violations_A_run": bad_A_run}


def valuation_trace(p: Pair) -> List[Tuple[str, int, int]]:
    """Trace (letter, v2(U), v2(V)) up the tree from a node to the root."""
    out: List[Tuple[str, int, int]] = []
    while p != ROOT:
        m, n = p
        small, big = m - n, m + n
        out.append((letter_of(p), v2(big + small), v2(big - small)))
        p = parent(p)
    return out


# ----------------------------------------------------------------------------
# 4. The sealing families
# ----------------------------------------------------------------------------

def twin_X(y: int) -> Pair:
    """Twin from the factorisation N = 1 * N of N = 6y + 9."""
    return (3 * y + 5, 3 * y + 4)


def twin_Y(y: int) -> Pair:
    """Twin from the factorisation N = 3 * (2y + 3) of N = 6y + 9."""
    return (y + 3, y)


def check_twin_family(limit: int = 400) -> Dict[str, int]:
    """The twins agree at positions 0, 1 and always disagree at position 2."""
    checked = bad = 0
    for y in range(9, limit):
        if y % 3 == 0:
            continue
        X, Y = twin_X(y), twin_Y(y)
        assert is_valid(X) and is_valid(Y)
        assert odd_leg(X) == odd_leg(Y) == 6 * y + 9
        checked += 1
        same01 = all(
            (letter_at(X, t) == "A") == (letter_at(Y, t) == "A") for t in (0, 1)
        )
        split2 = (letter_at(X, 2) == "A") != (letter_at(Y, 2) == "A")
        if not (same01 and split2):
            bad += 1
    return {"checked": checked, "violations": bad}


def big_X(s: int) -> Pair:
    """All-positions family, twin of valuation exactly t = s + 2."""
    W = 10 * 2 ** s - 3
    return (2 ** (s + 2) * W + 1, 2 ** (s + 2) * W)


def big_Y(s: int) -> Pair:
    """All-positions family, twin of valuation t + 1 = s + 3."""
    return (12 * 2 ** s - 1, 2 ** (s + 3))


def check_all_positions(s_max: int = 10) -> List[Tuple[int, int, bool, bool]]:
    """For each t = s + 2, the pair agrees below t and splits at t."""
    rows: List[Tuple[int, int, bool, bool]] = []
    for s in range(0, s_max + 1):
        t = s + 2
        X, Y = big_X(s), big_Y(s)
        assert is_valid(X) and is_valid(Y)
        assert odd_leg(X) == odd_leg(Y)
        agree = all(
            (letter_at(X, u) == "A") == (letter_at(Y, u) == "A") for u in range(t)
        )
        split = (letter_at(X, t) == "A") != (letter_at(Y, t) == "A")
        rows.append((t, odd_leg(X), agree, split))
    return rows


def ds_X(s: int) -> Pair:
    """Equal-depth family, address A^(t-1) B A^t with t = s + 3."""
    return (2 ** (s + 4) + 1, 2 ** (s + 3))


def ds_Y(s: int) -> Pair:
    """Equal-depth family, address C A^(t-3) C A^(t+1) with t = s + 3."""
    M = 2 ** (s + 4) * (3 * 2 ** (s + 1) + 1)
    return (M + 1, M)


def check_equal_depth(s_max: int = 6) -> List[Tuple[int, int, int, int, bool]]:
    """Equal-depth splitting pairs: same odd leg, same depth, split at t."""
    rows: List[Tuple[int, int, int, int, bool]] = []
    for s in range(0, s_max + 1):
        t = s + 3
        X, Y = ds_X(s), ds_Y(s)
        assert is_valid(X) and is_valid(Y)
        assert odd_leg(X) == odd_leg(Y)
        dX, dY = depth(X), depth(Y)
        ok = (
            dX == dY
            and all(
                (letter_at(X, u) == "A") == (letter_at(Y, u) == "A")
                for u in range(t)
            )
            and (letter_at(X, t) == "A") != (letter_at(Y, t) == "A")
        )
        rows.append((t, odd_leg(X), dX, dY, ok))
    return rows


def find_splitting_pairs(bound: int, position: int) -> List[Tuple[int, Pair, Pair]]:
    """Search for same-odd-leg pairs disagreeing at a given position."""
    by_leg: Dict[int, List[Pair]] = defaultdict(list)
    for p in all_nodes(bound):
        if depth(p) > position:
            by_leg[odd_leg(p)].append(p)
    out: List[Tuple[int, Pair, Pair]] = []
    for N, nodes in by_leg.items():
        for i in range(len(nodes)):
            for j in range(i + 1, len(nodes)):
                a, b = nodes[i], nodes[j]
                if (letter_at(a, position) == "A") != (letter_at(b, position) == "A"):
                    out.append((N, a, b))
    return sorted(out)


# ----------------------------------------------------------------------------
# 5. Information capacity of the residue dial
# ----------------------------------------------------------------------------

def entropy(counts: List[int]) -> float:
    total = sum(counts)
    return -sum((c / total) * log2(c / total) for c in counts if c > 0)


def nodes_at_depth(level: int) -> Iterator[Pair]:
    """All 3^level nodes at a fixed distance from the root."""
    frontier: List[Pair] = [ROOT]
    for _ in range(level):
        frontier = [step(ch, p) for p in frontier for ch in "ABC"]
    return iter(frontier)


def mutual_information(nodes: List[Pair], k: int, positions: Tuple[int, ...]) -> float:
    """I(N mod 2^k ; the tuple of A-nesses at the given positions), in bits."""
    joint: Dict[Tuple[int, Tuple[bool, ...]], int] = defaultdict(int)
    px: Dict[int, int] = defaultdict(int)
    py: Dict[Tuple[bool, ...], int] = defaultdict(int)
    total = 0
    for p in nodes:
        if depth(p) <= max(positions):
            continue
        x = odd_leg(p) % (2 ** k)
        y = tuple(letter_at(p, t) == "A" for t in positions)
        joint[(x, y)] += 1
        px[x] += 1
        py[y] += 1
        total += 1
    if total == 0:
        return 0.0
    return (
        entropy(list(px.values()))
        + entropy(list(py.values()))
        - entropy(list(joint.values()))
    )


# ----------------------------------------------------------------------------
# 6. Report
# ----------------------------------------------------------------------------

def main() -> None:
    line = "=" * 74
    print(line)
    print("THE TWO-ADIC PRICE LAW — numerical demonstration")
    print(line)

    print("\n[0] Orientation: a few nodes, their triples and their addresses")
    print(f"{'node':>12} {'triple':>20} {'N':>8} {'address':>14} {'N mod 8':>8}")
    for p in [(2, 1), (5, 2), (7, 4), (17, 16), (13, 8), (53, 52)]:
        m, n = p
        trip = (m * m - n * n, 2 * m * n, m * m + n * n)
        print(f"{str(p):>12} {str(trip):>20} {odd_leg(p):>8} "
              f"{address(p) or '(root)':>14} {odd_leg(p) % 8:>8}")

    print("\n[1] Two visible clicks: positions 0 and 1 versus N mod 8")
    res = check_two_clicks(300)
    print(f"    nodes tested (m < 300, depth >= 2): {res['tested']}")
    print(f"    position 0 is A  <=>  N = 1 (mod 4):   "
          f"{res['violations_pos0']} violations")
    print(f"    position 1 is A  <=>  N mod 8 in {{1,3}}: "
          f"{res['violations_pos1']} violations")
    print("\n    The mod-8 dictionary (observed patterns of (A at 0, A at 1)):")
    for r, pats in mod8_dictionary(300).items():
        for pat in sorted(pats):
            print(f"      N = {r} (mod 8)  ->  A at position 0: {pat[0]!s:>5}, "
                  f"A at position 1: {pat[1]!s:>5}")

    print("\n[2] The B/C split is a SIZE rule, never a congruence")
    bc = b_versus_c(300)
    print(f"    'letter = B  <=>  N = 3 (mod 4) and q < 3p': "
          f"{bc['violations']} violations")
    print(f"    counts among nodes with m < 300:  B: {bc['count_B']}, "
          f"C: {bc['count_C']}")
    print(f"    empirical P(B) / P(B or C) = "
          f"{bc['count_B'] / (bc['count_B'] + bc['count_C']):.4f}")

    print("\n[3] The run mechanism: v2(U) counts down, the first A lands at v2(U)-1")
    runs = check_run_laws(400)
    print(f"    first-A law (n odd):   {runs['violations_first_A']} violations")
    print(f"    A-run law (n even):    {runs['violations_A_run']} violations")
    demo_node = (41, 14)
    print(f"    trace for {demo_node}, address {address(demo_node)}:")
    print(f"      {'letter':>8} {'v2(U)':>7} {'v2(V)':>7}")
    for lt, u, v in valuation_trace(demo_node):
        print(f"      {lt:>8} {u:>7} {v:>7}")

    print("\n[4] Sealing at position 2: the twin family X(y), Y(y)")
    tw = check_twin_family(400)
    print(f"    y < 400 with 3 does not divide y: {tw['checked']} twins, "
          f"{tw['violations']} violations")
    for y in (10, 13, 14):
        X, Y = twin_X(y), twin_Y(y)
        print(f"      y = {y:>3}: N = {odd_leg(X):>5},  {str(X):>10} "
              f"[{address(X)}]  vs  {str(Y):>8} [{address(Y)}]")
    smallest = find_splitting_pairs(60, 2)[:3]
    print("    smallest same-odd-leg pairs splitting at position 2 (m < 60):")
    for N, a, b in smallest:
        print(f"      N = {N:>4}: {str(a):>10} [{address(a)}]  vs  "
              f"{str(b):>10} [{address(b)}]")

    print("\n[5] Sealing at EVERY position t >= 2")
    print(f"      {'t':>3} {'common odd leg':>16} {'agree below t':>15} "
          f"{'split at t':>12}")
    for t, N, agree, split in check_all_positions(10):
        print(f"      {t:>3} {N:>16} {str(agree):>15} {str(split):>12}")

    print("\n[6] Even the DEPTH does not unlock the address")
    print(f"      {'t':>3} {'odd leg':>18} {'depth X':>8} {'depth Y':>8} "
          f"{'splits':>7}")
    for t, N, dX, dY, ok in check_equal_depth(6):
        print(f"      {t:>3} {N:>18} {dX:>8} {dY:>8} {str(ok):>7}")

    print("\n[7] Capacity of the residue dial: I(N mod 2^k ; first two letters)")
    level = 9
    pop = [p for p in nodes_at_depth(level) if depth(p) > 2]
    print(f"    population: all {len(pop)} nodes at distance {level} from the root")
    print(f"      {'k':>3} {'modulus':>9} {'bits':>8}")
    for k in range(1, 8):
        mi = mutual_information(pop, k, (0, 1))
        print(f"      {k:>3} {2 ** k:>9} {mi:>8.3f}")
    print("    The dial saturates exactly at modulus 8: past 8 nothing is added.")
    print("    (The saturation value is twice the entropy of a 1/3-biased bit,")
    print("     2 * H(1/3) = 1.837 bits, for this uniform-over-level population.)")

    print("\n[8] Where the information at position 2 lives")
    print(f"      {'k':>3} {'modulus':>9} {'I(N mod 2^k ; letters 0,1,2)':>30}")
    for k in range(1, 8):
        mi = mutual_information(pop, k, (0, 1, 2))
        print(f"      {k:>3} {2 ** k:>9} {mi:>30.3f}")
    print("    Adding the third letter does not raise the ceiling: the residue")
    print("    sees the first two letters and nothing else.")

    print("\n" + line)
    print("Summary: exactly two clicks of 2-adic visibility, then sealed.")
    print(line)


if __name__ == "__main__":
    main()
