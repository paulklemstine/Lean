"""
PRICE-2ADIC-LETTERS: numerical demonstrations.

Self-contained numerical companion to the paper
"The 2-adic Alphabet of the Price Tree, and the Emptiness of Gauss Magnitudes".

Everything below is elementary Python (standard library only, plus `cmath`/`math`).
Run with:  python3 demo.py

Contents
--------
1. The Price tree on Euclid parameters:  A:(m,n)->(m+n,2n), B:(m,n)->(2m,m-n),
   C:(m,n)->(2m,m+n).  Uniqueness and completeness against brute force (c <= 5000).
2. The letter laws:  last letter is A iff N = a = m^2-n^2 is 1 mod 4;
   second-to-last letter is A iff a mod 8 in {1,3}; the full mod-8 dictionary.
3. Sharpness: the B/C distinction is invisible modulo every power of 2.
4. The run law:  (# trailing A's of the address) = v_2(n) = v_2(b) - 1 when a = 1 mod 4.
5. Depth squeeze:  log_3(m+n) - 1 <= depth <= (m+n-3)/2, and the 3^d counting bound.
6. Berggren contrast: the last Berggren letter is 2-adically invisible at every depth.
7. Gauss magnitudes: |g| = sqrt(p) for every additive twist -- a constant, hence
   information-free, residue dial.
"""

from __future__ import annotations

import cmath
import math
from collections import deque
from typing import Dict, Iterable, List, Tuple

Pair = Tuple[int, int]
Triple = Tuple[int, int, int]

# ----------------------------------------------------------------------------
# 1. The Price tree on Euclid parameters
# ----------------------------------------------------------------------------

ROOT: Pair = (2, 1)


def is_valid(p: Pair) -> bool:
    """Primitive Euclid parameter pair: 0 < n < m, gcd(m,n)=1, m+n odd."""
    m, n = p
    return 0 < n < m and math.gcd(m, n) == 1 and (m + n) % 2 == 1


def step(letter: str, p: Pair) -> Pair:
    """One Price move on parameters.  Each move doubles one parameter."""
    m, n = p
    if letter == "A":
        return (m + n, 2 * n)
    if letter == "B":
        return (2 * m, m - n)
    if letter == "C":
        return (2 * m, m + n)
    raise ValueError(f"unknown Price letter {letter!r}")


def evaluate(word: str) -> Pair:
    """The node addressed by a Price word (read left to right from the root)."""
    p = ROOT
    for letter in word:
        p = step(letter, p)
    return p


def triple(p: Pair) -> Triple:
    """Euclid's triple (a, b, c) = (m^2-n^2, 2mn, m^2+n^2)."""
    m, n = p
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def letter_of(p: Pair) -> str:
    """The last letter of the address of a non-root node."""
    m, n = p
    if n % 2 == 0:
        return "A"
    return "B" if 2 * n < m else "C"


def parent(p: Pair) -> Pair:
    """The Price parent of a non-root node (inverse of the appropriate move)."""
    m, n = p
    if n % 2 == 0:
        return (m - n // 2, n // 2)
    if 2 * n < m:
        return (m // 2, m // 2 - n)
    return (m // 2, n - m // 2)


def address(p: Pair) -> str:
    """The unique Price address of a primitive parameter pair."""
    word: List[str] = []
    while p != ROOT:
        word.append(letter_of(p))
        p = parent(p)
    return "".join(reversed(word))


def bfs_nodes(c_bound: int) -> List[Pair]:
    """All Price-tree nodes whose hypotenuse is at most `c_bound`, by breadth-first search."""
    out: List[Pair] = []
    queue: deque[Pair] = deque([ROOT])
    while queue:
        p = queue.popleft()
        if triple(p)[2] > c_bound:
            continue
        out.append(p)
        for letter in "ABC":
            queue.append(step(letter, p))
    return out


def brute_force_triples(c_bound: int) -> List[Triple]:
    """All primitive Pythagorean triples with hypotenuse at most `c_bound`, by direct search."""
    out: List[Triple] = []
    m = 2
    while m * m + 1 <= c_bound:
        for n in range(1, m):
            if is_valid((m, n)) and m * m + n * n <= c_bound:
                out.append(triple((m, n)))
        m += 1
    return sorted(out)


def demo_uniqueness_completeness(c_bound: int = 5000) -> None:
    print("=" * 72)
    print(f"1. UNIQUENESS AND COMPLETENESS  (hypotenuse c <= {c_bound})")
    print("=" * 72)
    nodes = bfs_nodes(c_bound)
    tree_triples = sorted(triple(p) for p in nodes)
    brute = brute_force_triples(c_bound)
    print(f"  tree nodes found           : {len(nodes)}")
    print(f"  distinct triples from tree : {len(set(tree_triples))}  (duplicates: "
          f"{len(tree_triples) - len(set(tree_triples))})")
    print(f"  brute-force triples        : {len(brute)}")
    print(f"  missing from tree          : {len(set(brute) - set(tree_triples))}")
    print(f"  extra in tree              : {len(set(tree_triples) - set(brute))}")
    print(f"  root triple                : {triple(ROOT)}")
    print("  children of the root       : "
          f"{triple(step('A', ROOT))}, {triple(step('B', ROOT))}, {triple(step('C', ROOT))}")
    print("  (Berggren's root children would include (21,20,29) -- this is Price's tree.)")
    # round trip: address(evaluate(w)) == w
    words = all_words(6)
    bad = [w for w in words if address(evaluate(w)) != w]
    print(f"  address(evaluate(w)) == w for all {len(words)} words of length <= 6 : {not bad}")
    print()


def all_words(max_len: int) -> List[str]:
    words = [""]
    frontier = [""]
    for _ in range(max_len):
        frontier = [w + c for w in frontier for c in "ABC"]
        words.extend(frontier)
    return words


# ----------------------------------------------------------------------------
# 2. The letter laws
# ----------------------------------------------------------------------------

def demo_letter_laws(depth: int = 8) -> None:
    print("=" * 72)
    print(f"2. THE LETTER LAWS  (all {(3 ** (depth + 1) - 1) // 2} words of length <= {depth})")
    print("=" * 72)
    words = all_words(depth)
    ok0 = ok1 = 0
    table: Dict[int, set] = {r: set() for r in (1, 3, 5, 7)}
    for w in words:
        if not w:
            continue
        a = triple(evaluate(w))[0]
        assert a % 2 == 1, "the odd leg is always odd: modulus 2 is vacuous"
        ok0 += (w[-1] == "A") == (a % 4 == 1)
        if len(w) >= 2:
            ok1 += (w[-2] == "A") == (a % 8 in (1, 3))
            key = "A" if w[-2] == "A" else "*"
            key += "A" if w[-1] == "A" else "*"
            table[a % 8].add(key)
    print(f"  'last letter = A'  <=>  a = 1 (mod 4)          : verified on {ok0} words")
    print(f"  'previous letter = A'  <=>  a mod 8 in {{1,3}}   : verified on {ok1} words")
    print("  mod-8 dictionary of the last two letters (read from the leaf, '*' = B or C):")
    for r in (1, 3, 5, 7):
        pats = ",".join(sorted(table[r]))
        print(f"      a = {r} (mod 8)   ->   {pats}")
    print("  (residues 0,2,4,6 never occur: the odd leg is odd.)")
    print()


# ----------------------------------------------------------------------------
# 3. Sharpness: B vs C is 2-adically invisible
# ----------------------------------------------------------------------------

def demo_bc_blindness(k_max: int = 12) -> None:
    print("=" * 72)
    print("3. SHARPNESS: THE B/C BIT IS INVISIBLE MODULO EVERY POWER OF 2")
    print("=" * 72)
    print("  witness node r = (2^k + 1, 2^k);  its B- and C-children agree mod 2^k")
    print("   k   B-child triple                C-child triple                agree mod 2^k")
    for k in range(1, k_max + 1):
        r = (2 ** k + 1, 2 ** k)
        assert is_valid(r)
        pb, pc = step("B", r), step("C", r)
        tb, tc = triple(pb), triple(pc)
        agree = all((x - y) % 2 ** k == 0 for x, y in zip(tb, tc))
        assert letter_of(pb) == "B" and letter_of(pc) == "C"
        assert tb != tc
        if k <= 6:
            print(f"  {k:2d}   {str(tb):28s}  {str(tc):28s}  {agree}")
        else:
            assert agree
    print(f"  verified for all k = 1..{k_max}: distinct triples, same residues mod 2^k.")
    print("  Hence no function of 2-adic residues can decide the B/C letter.")
    print()


# ----------------------------------------------------------------------------
# 4. The run law
# ----------------------------------------------------------------------------

def v2(n: int) -> int:
    """2-adic valuation of a positive integer."""
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def trailing_a(word: str) -> int:
    k = 0
    for ch in reversed(word):
        if ch != "A":
            break
        k += 1
    return k


def demo_run_law(depth: int = 8) -> None:
    print("=" * 72)
    print("4. THE RUN LAW:  trailing A's  =  v_2(n)  =  v_2(b) - 1  when a = 1 (mod 4)")
    print("=" * 72)
    words = all_words(depth)
    checked = 0
    for w in words:
        m, n = evaluate(w)
        a, b, _ = triple((m, n))
        run = trailing_a(w)
        assert run == v2(n), (w, run, v2(n))
        expected = v2(b) - 1 if a % 4 == 1 else 0
        assert run == expected, (w, run, expected)
        checked += 1
    print(f"  verified on all {checked} nodes of depth <= {depth}: no exceptions.")
    for w in ["", "A", "AA", "AAA", "BAA", "CABAAAA"]:
        m, n = evaluate(w)
        a, b, c = triple((m, n))
        print(f"   word {w or '(root)':10s} (m,n)=({m},{n})  triple=({a},{b},{c})  "
              f"run={trailing_a(w)}  v2(n)={v2(n)}  v2(b)-1={v2(b) - 1}")
    print()


# ----------------------------------------------------------------------------
# 5. Depth squeeze and the counting bound
# ----------------------------------------------------------------------------

def demo_depth_and_counting(depth: int = 8) -> None:
    print("=" * 72)
    print("5. DEPTH SQUEEZE AND EXPONENTIAL COUNTING")
    print("=" * 72)
    print("   d   3^d words   min(m+n)   max(m+n)   lower bound 2d+3   upper bound 3^(d+1)")
    for d in range(0, depth + 1):
        sums = [sum(evaluate(w)) for w in all_words_exact(d)]
        lo, hi = min(sums), max(sums)
        assert lo >= 2 * d + 3 and hi <= 3 ** (d + 1)
        print(f"  {d:2d}   {3 ** d:9d}   {lo:8d}   {hi:8d}   {2 * d + 3:16d}   {3 ** (d + 1):18d}")
    print()
    print("  Consequence (counting): at least 3^d primitive triples have m+n <= 3^(d+1).")
    for d in range(0, 6):
        bound = 3 ** (d + 1)
        actual = sum(1 for m in range(2, bound + 1) for n in range(1, m)
                     if m + n <= bound and is_valid((m, n)))
        print(f"   d={d}: guaranteed >= {3 ** d:5d};  actual count with m+n <= {bound:4d} is {actual}")
    print()


def all_words_exact(d: int) -> Iterable[str]:
    frontier = [""]
    for _ in range(d):
        frontier = [w + c for w in frontier for c in "ABC"]
    return frontier


# ----------------------------------------------------------------------------
# 6. Berggren contrast
# ----------------------------------------------------------------------------

def berggren_step(letter: str, p: Pair) -> Pair:
    """Berggren's moves on Euclid parameters: A:(2m-n,m), B:(2m+n,m), C:(m+2n,n)."""
    m, n = p
    if letter == "A":
        return (2 * m - n, m)
    if letter == "B":
        return (2 * m + n, m)
    if letter == "C":
        return (m + 2 * n, n)
    raise ValueError(letter)


def demo_berggren_contrast(k_max: int = 12) -> None:
    print("=" * 72)
    print("6. BERGGREN CONTRAST: THE BERGGREN LETTER IS 2-ADICALLY INVISIBLE")
    print("=" * 72)
    print("  The A- and B-children of (m,n) have triples differing by (8mn, 4mn, 8mn).")
    for p in [(2, 1), (3, 2), (4, 1), (5, 2)]:
        ta, tb = triple(berggren_step("A", p)), triple(berggren_step("B", p))
        m, n = p
        print(f"   node {p}: A-child {ta}, B-child {tb}, "
              f"difference {(tb[0] - ta[0], tb[1] - ta[1], tb[2] - ta[2])} "
              f"= (8mn,4mn,8mn) with mn={m * n}")
    print("  witness family r = (2^k+1, 2^k): the A- and B-children agree mod 2^k.")
    for k in range(1, k_max + 1):
        r = (2 ** k + 1, 2 ** k)
        ta, tb = triple(berggren_step("A", r)), triple(berggren_step("B", r))
        assert ta != tb
        assert all((x - y) % 2 ** k == 0 for x, y in zip(ta, tb))
        if k <= 4:
            print(f"   k={k}: A-child {ta}, B-child {tb}")
    print(f"  verified for all k = 1..{k_max}.")
    print("  Price letters live at 2; Berggren letters do not.")
    print()


# ----------------------------------------------------------------------------
# 7. Gauss magnitudes are an information-free dial
# ----------------------------------------------------------------------------

def legendre(x: int, p: int) -> int:
    """Legendre symbol (x|p) for an odd prime p."""
    x %= p
    if x == 0:
        return 0
    return 1 if pow(x, (p - 1) // 2, p) == 1 else -1


def gauss_sum(p: int, a: int = 1) -> complex:
    """Quadratic Gauss sum with the additive character twisted by a: sum_x (x|p) e(a x / p)."""
    return sum(legendre(x, p) * cmath.exp(2j * cmath.pi * a * x / p) for x in range(p))


def demo_gauss_dial(primes: Tuple[int, ...] = (3, 5, 7, 11, 13, 17, 19, 23, 29, 31)) -> None:
    print("=" * 72)
    print("7. GAUSS MAGNITUDES: A CONSTANT, HENCE INFORMATION-FREE, RESIDUE DIAL")
    print("=" * 72)
    print("    p   p mod 4      g^2 (numeric)     closed form     max |g| deviation over twists")
    for p in primes:
        g = gauss_sum(p)
        g2 = g * g
        closed = p if p % 4 == 1 else -p
        mags = [abs(gauss_sum(p, a)) for a in range(1, p)]
        spread = max(mags) - min(mags)
        assert abs(g2 - closed) < 1e-8 * p
        assert spread < 1e-8 * p
        assert abs(abs(g) - math.sqrt(p)) < 1e-8 * p
        print(f"  {p:3d}   {p % 4:7d}   {g2.real:+11.6f}{g2.imag:+.1e}i   "
              f"{closed:+8d}      {spread:.2e}")
    print()
    print("  For every prime and every twist a, |g| = sqrt(p) exactly: the magnitude")
    print("  feature is constant across residue classes.  A constant feature selects")
    print("  either all classes or none, so the density of the surviving set is 0 or 1")
    print("  and the sieving speedup it buys is exactly 1 -- zero bits of information,")
    print("  strictly below the universal cap of 4/3 for residue dials.")
    print("  The *sign* of g^2, by contrast, is a genuine (but tiny) dial of modulus 4.")
    print()


def main() -> None:
    demo_uniqueness_completeness()
    demo_letter_laws()
    demo_bc_blindness()
    demo_run_law()
    demo_depth_and_counting()
    demo_berggren_contrast()
    demo_gauss_dial()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
