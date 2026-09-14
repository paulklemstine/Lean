"""
The Collatz-Berggren Bridge: numerical companion
=================================================

A self-contained numerical demonstration of the results in
"The Collatz-Berggren Bridge: Why the Lorentz Invariant Does Not Transfer,
and What Does".

Two ternary-looking trees are compared:

  * the BERGGREN TREE of primitive Pythagorean triples, generated from (3,4,5)
    by three fixed integer matrices A, B, C.  It is exactly ternary, it carries
    the conserved Lorentz form Q(a,b,c) = a^2 + b^2 - c^2 (identically 0 on the
    tree), and its Pell spine grows by the silver ratio squared (1+sqrt 2)^2.

  * the INVERSE SYRACUSE TREE (inverse odd-to-odd Collatz map): m is a
    predecessor of the odd number n iff 3m + 1 = 2^k n for some k >= 1.

The script verifies, numerically:

  1. Berggren branching is exactly 3; the Lorentz form is conserved and zero.
  2. The Pell spine ratio converges to 3 + 2 sqrt 2 and sits in the window
     (29/5, 6).
  3. Collatz predecessor fibres are EMPTY when 3 | n and INFINITE otherwise
     (rank-one combs: the orbit of L(x) = 4x + 1).
  4. The residue clock of a fibre modulo 3 has exact period 3, so exactly one
     member in three is dead.
  5. The rigidity obstruction: any quadratic conserved along Syracuse edges
     must be constant (witnesses 1, 5, 21 all mapping to 1).
  6. The word identity 2^S n = 3^L m + w(ks) and the cycle equation
     m (2^S - 3^L) = w(ks), with the two-sided weight bounds.
  7. The positive residue: an explicit embedding of the free ternary tree into
     the inverse Collatz tree, all of whose nodes are live and increasing.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, isqrt, log
from typing import Dict, Iterator, List, Sequence, Tuple

Triple = Tuple[int, int, int]

# --------------------------------------------------------------------------
# Part 1.  The Berggren tree of primitive Pythagorean triples
# --------------------------------------------------------------------------

BERGGREN_MATRICES: Dict[str, Tuple[Triple, Triple, Triple]] = {
    "A": ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    "B": ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    "C": ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}


def apply_step(letter: str, t: Triple) -> Triple:
    """Apply one Berggren letter (a 3x3 integer matrix) to a triple."""
    m = BERGGREN_MATRICES[letter]
    a, b, c = t
    return (
        m[0][0] * a + m[0][1] * b + m[0][2] * c,
        m[1][0] * a + m[1][1] * b + m[1][2] * c,
        m[2][0] * a + m[2][1] * b + m[2][2] * c,
    )


def lorentz(t: Triple) -> int:
    """The Lorentz form Q(a,b,c) = a^2 + b^2 - c^2."""
    a, b, c = t
    return a * a + b * b - c * c


def berggren_children(t: Triple) -> List[Triple]:
    """The three Berggren children of a triple."""
    return [apply_step(s, t) for s in ("A", "B", "C")]


def berggren_level(level: int, root: Triple = (3, 4, 5)) -> List[Triple]:
    """All 3^level triples at a given depth of the Berggren tree."""
    frontier: List[Triple] = [root]
    for _ in range(level):
        frontier = [c for t in frontier for c in berggren_children(t)]
    return frontier


def is_primitive_pythagorean(t: Triple) -> bool:
    a, b, c = t
    return a > 0 and b > 0 and c > 0 and a * a + b * b == c * c and gcd(gcd(a, b), c) == 1


def pell_spine(n: int, root: Triple = (3, 4, 5)) -> List[Triple]:
    """The all-B branch: (3,4,5) -> (21,20,29) -> (119,120,169) -> ..."""
    out = [root]
    t = root
    for _ in range(n):
        t = apply_step("B", t)
        out.append(t)
    return out


def demo_berggren() -> None:
    print("=" * 74)
    print("1.  THE BERGGREN TREE IS EXACTLY TERNARY, AND LORENTZ-NULL")
    print("=" * 74)
    root: Triple = (3, 4, 5)
    print(f"root {root}:  Q = {lorentz(root)}")
    for s in ("A", "B", "C"):
        child = apply_step(s, root)
        print(f"   {s} -> {str(child):>18}   Q = {lorentz(child):>2}   "
              f"primitive = {is_primitive_pythagorean(child)}")

    for level in range(1, 6):
        nodes = berggren_level(level)
        distinct = len(set(nodes))
        all_null = all(lorentz(t) == 0 for t in nodes)
        all_prim = all(is_primitive_pythagorean(t) for t in nodes)
        print(f"  level {level}: {len(nodes):>4} nodes, {distinct:>4} distinct "
              f"(= 3^{level}), Lorentz-null: {all_null}, all primitive: {all_prim}")

    print("\n  Branching number at every node of the first four levels:")
    counts = set()
    for level in range(4):
        for t in berggren_level(level):
            counts.add(len(set(berggren_children(t))))
    print(f"    observed child-counts = {sorted(counts)}   (exactly ternary)")


def demo_silver_window() -> None:
    print()
    print("=" * 74)
    print("2.  THE SILVER WINDOW ON THE PELL SPINE")
    print("=" * 74)
    silver_sq = (1 + 2 ** 0.5) ** 2
    print(f"  silver ratio squared (1+sqrt2)^2 = 3 + 2 sqrt 2 = {silver_sq:.10f}")
    print(f"  proved window: 29/5 = {29 / 5:.4f}  <  {silver_sq:.6f}  <  6")
    print()
    print("   n   hypotenuse c_n      c_n/c_{n-1}     5*29^n <= 5^n c_n    c_n <= 5*6^n")
    spine = pell_spine(9)
    prev = None
    for n, t in enumerate(spine):
        c = t[2]
        ratio = "" if prev is None else f"{c / prev:.8f}"
        lower_ok = 5 * 29 ** n <= 5 ** n * c
        upper_ok = c <= 5 * 6 ** n
        print(f"  {n:>2}   {c:>14}   {ratio:>14}          {str(lower_ok):>5}"
              f"               {str(upper_ok):>5}")
        prev = c
    # the recurrence c_{n+2} = 6 c_{n+1} - c_n
    cs = [t[2] for t in spine]
    rec_ok = all(cs[i + 2] == 6 * cs[i + 1] - cs[i] for i in range(len(cs) - 2))
    print(f"\n  recurrence c_(n+2) = 6 c_(n+1) - c_n holds: {rec_ok}")


# --------------------------------------------------------------------------
# Part 2.  The inverse Syracuse (odd-to-odd Collatz) tree
# --------------------------------------------------------------------------

def syracuse(n: int) -> int:
    """The odd-to-odd Collatz (Syracuse) map: strip all 2s from 3n+1."""
    if n % 2 == 0:
        raise ValueError("Syracuse map is defined on odd numbers")
    m = 3 * n + 1
    while m % 2 == 0:
        m //= 2
    return m


def is_syr_pred(m: int, n: int) -> bool:
    """m is an immediate predecessor of the odd n: 3m+1 = 2^k n with k >= 1."""
    if n % 2 == 0 or m <= 0 or m % 2 == 0:
        return False
    return syracuse(m) == n


def start_exp(n: int) -> int:
    """The minimal admissible exponent: 2 if n = 1 mod 3, else 1."""
    return 2 if n % 3 == 1 else 1


def pred_fam(n: int, j: int) -> int:
    """The j-th Collatz predecessor of a live node n (odd, 3 does not divide n)."""
    return (2 ** (start_exp(n) + 2 * j) * n - 1) // 3


def pred_fibre(n: int, count: int) -> List[int]:
    """The first `count` predecessors of n, in increasing order (empty if 3 | n)."""
    if n % 2 == 0 or n % 3 == 0:
        return []
    return [pred_fam(n, j) for j in range(count)]


def demo_collatz_fibres() -> None:
    print()
    print("=" * 74)
    print("3.  COLLATZ FIBRES: EMPTY OR INFINITE, NEVER TERNARY")
    print("=" * 74)
    print("  brute-force search for predecessors m <= 200000 of small odd n:\n")
    print("      n   3|n ?   predecessors found (m <= 200000)")
    for n in range(1, 26, 2):
        found = [m for m in range(1, 200001, 2) if syracuse(m) == n]
        dead = "yes" if n % 3 == 0 else " no"
        shown = ", ".join(str(x) for x in found[:6])
        more = " ..." if len(found) > 6 else ""
        print(f"  {n:>5}    {dead}    {shown if found else '(none)'}{more}")

    print("\n  The closed form: fibre(n) = orbit of L(x) = 4x+1 from the least"
          " predecessor.\n")
    for n in (1, 5, 7, 11, 13):
        fam = pred_fibre(n, 6)
        checks = all(is_syr_pred(m, n) for m in fam)
        step = all(fam[j + 1] == 4 * fam[j] + 1 for j in range(len(fam) - 1))
        print(f"    n = {n:>3}: {fam}")
        print(f"             all genuine predecessors: {checks};  "
              f"x -> 4x+1 recursion: {step}")

    print("\n  Dead nodes (3 | n) really have no predecessor at all:")
    for n in (3, 9, 15, 21):
        found = [m for m in range(1, 500001, 2) if syracuse(m) == n]
        print(f"    n = {n:>3}: predecessors with m <= 500000: {found}")


def demo_residue_clock() -> None:
    print()
    print("=" * 74)
    print("4.  THE RESIDUE CLOCK: ONE MEMBER IN THREE IS DEAD")
    print("=" * 74)
    print("  fibre over n = 1 and its residues mod 3 (theory: j -> (j+1) mod 3)\n")
    print("     j     predecessor      mod 3   predicted   live?")
    for j in range(9):
        m = pred_fam(1, j)
        print(f"  {j:>4}   {m:>14}   {m % 3:>5}   {(j + 1) % 3:>9}"
              f"   {'yes' if m % 3 else 'DEAD'}")
    ok = all(pred_fam(1, j) % 3 == (j + 1) % 3 for j in range(200))
    print(f"\n  clock identity verified for j < 200: {ok}")

    print("\n  eventual periodicity of a fibre mod m (period at most m):")
    for mod in (3, 5, 7, 9, 11):
        resid = [pred_fam(7, j) % mod for j in range(60)]
        period = next(p for p in range(1, mod + 1)
                      if all(resid[i] == resid[i + p] for i in range(mod + 5, 50)))
        print(f"    modulus {mod:>2}: residues {resid[:12]} ...  eventual period {period}")


def demo_rigidity() -> None:
    print()
    print("=" * 74)
    print("5.  RIGIDITY: NO POLYNOMIAL COLLATZ INVARIANT")
    print("=" * 74)
    print("  1, 5 and 21 are all predecessors of 1:")
    for m in (1, 5, 21, 85, 341):
        print(f"    3*{m} + 1 = {3 * m + 1} = 2^{(3 * m + 1).bit_length() - 1} * 1"
              f"   -> Syracuse({m}) = {syracuse(m)}")
    print("\n  A conserved quadratic alpha x^2 + beta x + gamma would have to take"
          "\n  the same value at 1, 5 and 21, forcing alpha = beta = 0:\n")
    # solve the 2x2 system from the two equations P(5) = P(1), P(21) = P(1)
    #   alpha (25 - 1) + beta (5 - 1) = 0
    #   alpha (441 - 1) + beta (21 - 1) = 0
    det = Fraction(24 * 20 - 4 * 440)
    print(f"    24 alpha +  4 beta = 0")
    print(f"   440 alpha + 20 beta = 0     determinant = {det}  (nonzero)")
    print(f"    => the only solution is alpha = beta = 0.")

    print("\n  Any candidate invariant fails immediately.  Sample scorecard for")
    print("  some natural guesses, evaluated on the fibre {1, 5, 21, 85} of 1:\n")
    guesses = {
        "x": lambda x: Fraction(x),
        "x^2": lambda x: Fraction(x) ** 2,
        "x mod 9": lambda x: Fraction(x % 9),
        "x mod 8": lambda x: Fraction(x % 8),
        "x^2 - 2x": lambda x: Fraction(x) ** 2 - 2 * x,
    }
    for name, f in guesses.items():
        vals = [f(m) for m in (1, 5, 21, 85)]
        print(f"    {name:>16}: {[str(v) for v in vals]}  constant: "
              f"{len(set(vals)) == 1}")
    print("\n  (By contrast the Lorentz form is constant -- identically 0 -- on"
          "\n   every node of the Berggren tree; see part 1.)")


# --------------------------------------------------------------------------
# Part 3.  The word calculus, growth and cycles
# --------------------------------------------------------------------------

def syr_weight(ks: Sequence[int]) -> int:
    """The affine cocycle w(ks): w([]) = 0, w(k::ks) = 3^|ks| + 2^k w(ks)."""
    # evaluated from the right, mirroring the recursion
    total = 0
    for idx in range(len(ks) - 1, -1, -1):
        total = 3 ** (len(ks) - idx - 1) + 2 ** ks[idx] * total
    return total


def syr_word(m: int, steps: int) -> Tuple[List[int], int]:
    """Run the Syracuse map `steps` times from odd m; return the valuation word
    and the endpoint."""
    ks: List[int] = []
    x = m
    for _ in range(steps):
        y = 3 * x + 1
        k = 0
        while y % 2 == 0:
            y //= 2
            k += 1
        ks.append(k)
        x = y
    return ks, x


def demo_word_identity() -> None:
    print()
    print("=" * 74)
    print("6.  THE WORD IDENTITY AND THE CYCLE EQUATION")
    print("=" * 74)
    print("  2^S * n = 3^L * m + w(ks),  S = sum of the word, L = its length\n")
    print("     m   steps   word                     L    S        check")
    for m, steps in ((7, 5), (27, 8), (11, 4), (1, 3), (9, 6)):
        ks, n = syr_word(m, steps)
        L, S = len(ks), sum(ks)
        lhs = 2 ** S * n
        rhs = 3 ** L * m + syr_weight(ks)
        print(f"  {m:>4}   {steps:>5}   {str(ks):<24} {L:>2}  {S:>3}   "
              f"{lhs} = {rhs}: {lhs == rhs}")

    print("\n  The only known cycle, 1 -> 1, has word [2]:")
    ks = [2]
    L, S, w = len(ks), sum(ks), syr_weight(ks)
    print(f"    L = {L}, S = {S}, w = {w};   m (2^S - 3^L) = 1 * ({2**S} - {3**L})"
          f" = {2**S - 3**L} = w: {2**S - 3**L == w}")
    print(f"    two-heavy test 2*3^L <= 2^S:  {2 * 3**L} <= {2**S}?"
          f"  {2 * 3**L <= 2**S}  (fails: the trivial cycle hugs the critical line)")

    print("\n  Two-sided weight bounds  3^L <= 3 w(ks)  and  2^L w(ks) <= 3^L 2^S:\n")
    print("     word                      L    S    w          lower   upper")
    for ks in ([1], [2], [1, 1], [1, 2, 1], [2, 2, 2], [1, 1, 1, 3], [4, 1, 2, 1, 1]):
        L, S, w = len(ks), sum(ks), syr_weight(ks)
        lo = 3 ** L <= 3 * w
        up = 2 ** L * w <= 3 ** L * 2 ** S
        print(f"  {str(ks):<24} {L:>2}  {S:>3}  {w:>9}    {str(lo):>5}   {str(up):>5}")

    print("\n  Consequence: every nonempty cycle needs 3^L < 2^S, i.e. S/L > log2 3")
    print(f"    log2 3 = {log(3, 2):.10f}")
    print("  and a cycle with 2*3^L <= 2^S obeys 2^L m <= 2*3^L, i.e. m <= 2(3/2)^L:\n")
    print("     L    bound 2*(3/2)^L      (cycle minimum would have to be below this)")
    for L in (1, 2, 3, 5, 10, 20, 40):
        bound = 2 * Fraction(3, 2) ** L
        print(f"  {L:>4}    {float(bound):>22.6f}")


# --------------------------------------------------------------------------
# Part 4.  The positive transfer: a ternary subtree inside the Collatz tree
# --------------------------------------------------------------------------

def live_idx(r: int, letter: str) -> int:
    """Index of the lift of a live node along a Berggren letter, as a function of
    the residue r = (least predecessor) mod 3."""
    if letter == "A":
        return 2 if r == 2 else 1
    if letter == "B":
        return 2 if r == 0 else 3
    if letter == "C":
        return 4 if r in (0, 1) else 5
    raise ValueError(letter)


def climb(n: int, letter: str) -> int:
    """Lift the live odd node n along a Berggren letter."""
    return pred_fam(n, live_idx(pred_fam(n, 0) % 3, letter))


def embed(word: Sequence[str]) -> int:
    """The image of a Berggren word under the ternary embedding, rooted at 1."""
    x = 1
    for s in word:
        x = climb(x, s)
    return x


def all_words(depth: int) -> Iterator[List[str]]:
    if depth == 0:
        yield []
        return
    for w in all_words(depth - 1):
        for s in ("A", "B", "C"):
            yield w + [s]


def demo_ternary_subtree() -> None:
    print()
    print("=" * 74)
    print("7.  WHAT DOES TRANSFER: A FREE TERNARY SUBTREE OF THE COLLATZ TREE")
    print("=" * 74)
    print("  root = 1;  each node has three lifts, all live, all strictly larger\n")
    for depth in range(3):
        for w in all_words(depth):
            v = embed(w)
            label = "".join(w) if w else "(root)"
            parent = embed(w[:-1]) if w else None
            edge = "" if parent is None else (
                f"   pred of {parent}: {is_syr_pred(v, parent)}")
            print(f"    {label:<8} -> {v:>14}   live: {v % 3 != 0}{edge}")
        print()

    print("  structural checks over all words of length <= 6:")
    ok_edge = ok_live = ok_grow = ok_distinct = True
    for depth in range(7):
        for w in all_words(depth):
            v = embed(w)
            ok_live &= (v % 3 != 0) and (v % 2 == 1)
            if w:
                p = embed(w[:-1])
                ok_edge &= is_syr_pred(v, p)
                ok_grow &= p < v
            kids = {embed(w + [s]) for s in ("A", "B", "C")}
            ok_distinct &= len(kids) == 3
    print(f"    every image is odd and live (3 does not divide it): {ok_live}")
    print(f"    every tree edge is a genuine Collatz predecessor edge: {ok_edge}")
    print(f"    the embedding strictly increases along edges:          {ok_grow}")
    print(f"    the three children of each node are distinct:          {ok_distinct}")
    print("\n  ... yet no invariant rides along: the Lorentz value of the Berggren")
    print("  node is always 0, while the image numbers are unrelated.  Shape")
    print("  transfers; conserved quantity does not.")


def demo_summary() -> None:
    print()
    print("=" * 74)
    print("SUMMARY OF THE FOUR OBSTRUCTIONS")
    print("=" * 74)
    rows = [
        ("branching number", "exactly 3", "0 (if 3|n) or infinite"),
        ("branching rank", "3 letters A,B,C", "1 letter L(x)=4x+1"),
        ("loops", "none (hypotenuse grows)", "self-loop at 1"),
        ("conserved form", "a^2+b^2-c^2 = 0", "no polynomial invariant"),
        ("growth exponent", "(1+sqrt2)^2 = 5.828...", "unbounded edge ratios"),
    ]
    print(f"  {'feature':<20}{'Berggren tree':<28}{'inverse Collatz tree'}")
    print("  " + "-" * 70)
    for a, b, c in rows:
        print(f"  {a:<20}{b:<28}{c}")
    print("\n  Verdict: the two ternary-looking trees are NOT two faces of one")
    print("  dynamics.  The Berggren shape embeds, the Lorentz invariant does not.")


def main() -> None:
    demo_berggren()
    demo_silver_window()
    demo_collatz_fibres()
    demo_residue_clock()
    demo_rigidity()
    demo_word_identity()
    demo_ternary_subtree()
    demo_summary()


if __name__ == "__main__":
    main()
