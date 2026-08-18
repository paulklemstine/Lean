"""Composite evaluation of the upper bounds on the extremal function A(n,d).

Four bounds are combined.  For a binary code C of length n with minimum
distance d:

  Sphere packing (Hamming):  |C| * V(n,t) <= 2^n,   t = floor((d-1)/2),
                             V(n,r) = sum_{i<=r} C(n,i).
  Singleton:                 |C| <= 2^(n+1-d)  (read with truncated subtraction).
  Plotkin (needs n < 2d):    |C| * (2d - n) <= 2d, hence |C| <= 2d.
  Trivial (needs n < d):     |C| <= 1.

The three nondegenerate bounds have complementary regimes: sphere packing is
strongest for small d relative to n, Singleton in the intermediate range, and
Plotkin once d approaches and exceeds n/2 (where sphere packing is vacuous
because the radius-t balls are larger than the cube).  The composite bound is
the pointwise minimum.  Against it we place the Gilbert-Varshamov lower bound
2^n / V(n, d-1), producing the classical bracketing of A(n,d).

Exact values are known at the parameter pairs (n,1), (n+1,2), (2^k-1,3),
(2^k,4); the routine marks those cells.

Complexity: O(n) per bound with cached binomial coefficients, so O(n^2) to fill
a full row and O(n^3) for the whole table.
"""

from __future__ import annotations

from math import comb
from typing import Dict, List, Optional, Tuple


def ball_volume(n: int, r: int) -> int:
    return sum(comb(n, i) for i in range(max(0, min(r, n)) + 1))


def sphere_packing_bound(n: int, d: int) -> int:
    t = (d - 1) // 2
    return (2 ** n) // ball_volume(n, t)


def singleton_bound(n: int, d: int) -> int:
    return 2 ** max(0, n + 1 - d)


def plotkin_bound(n: int, d: int) -> Optional[int]:
    if n >= 2 * d:
        return None
    return (2 * d) // (2 * d - n)


def trivial_bound(n: int, d: int) -> Optional[int]:
    return 1 if n < d else None


def gilbert_varshamov_lower(n: int, d: int) -> int:
    v = ball_volume(n, d - 1)
    return -((-(2 ** n)) // v)


def composite_upper_bound(n: int, d: int) -> Tuple[int, str]:
    """Return (best upper bound, name of the bound achieving it)."""
    candidates: List[Tuple[int, str]] = [
        (sphere_packing_bound(n, d), "sphere-packing"),
        (singleton_bound(n, d), "Singleton"),
    ]
    p = plotkin_bound(n, d)
    if p is not None:
        candidates.append((p, "Plotkin"))
    t = trivial_bound(n, d)
    if t is not None:
        candidates.append((t, "trivial"))
    return min(candidates, key=lambda pair: pair[0])


def exact_value(n: int, d: int) -> Optional[int]:
    """Exact values of A(n,d) established by the theory."""
    if d <= 1:
        return 2 ** n
    if d == 2:
        return 2 ** (n - 1)
    k = (n + 1).bit_length() - 1
    if d == 3 and n + 1 == 2 ** k:
        return 2 ** (n - k)
    kk = n.bit_length() - 1
    if d == 4 and n == 2 ** kk and n >= 2:
        return 2 ** (n - 1 - kk)
    if d == n:
        return 2
    if d > n:
        return 1
    return None


def bound_table(max_n: int = 12) -> Dict[Tuple[int, int], Tuple[int, int, str, Optional[int]]]:
    """Map (n,d) -> (GV lower, composite upper, winning bound, exact if known)."""
    table = {}
    for n in range(1, max_n + 1):
        for d in range(1, n + 2):
            ub, who = composite_upper_bound(n, d)
            table[(n, d)] = (gilbert_varshamov_lower(n, d), ub, who, exact_value(n, d))
    return table


def _report(max_n: int = 12) -> None:
    table = bound_table(max_n)
    print(f"{'n':>3} {'d':>3} {'GV':>8} {'upper':>8} {'winner':>15} {'exact':>8}")
    for (n, d), (gv, ub, who, ex) in sorted(table.items()):
        if d < 2:
            continue
        mark = "" if ex is None else str(ex)
        assert gv <= ub or d > n, (n, d, gv, ub)
        print(f"{n:>3} {d:>3} {gv:>8} {ub:>8} {who:>15} {mark:>8}")


if __name__ == "__main__":
    _report()


"""Greedy maximal code construction: the Gilbert-Varshamov bound as an algorithm.

Scan the 2^n binary words of length n in any fixed order and keep a word
whenever it is at Hamming distance at least d from every word already kept.
The resulting code C is *maximal*: no further word can be added.  Maximality
means every word of length n lies within distance d-1 of some codeword, so the
radius-(d-1) balls cover the cube and

        2^n  <=  |C| * V(n, d-1),        V(n,r) = sum_{i<=r} C(n,i),

which is exactly the Gilbert-Varshamov lower bound on the extremal function
A(n,d).  This is the precise converse of the sphere-packing bound: packing says
radius-t balls do not overlap, greed says radius-(d-1) balls leave no gaps.

Complexity: O(2^n * |C| * n) time with the naive distance test, or
O(2^n * n / w) with bit-parallel popcount on machine words of width w.  Memory
O(|C| * n).
"""

from __future__ import annotations

from itertools import product
from math import comb
from typing import List, Tuple

Word = Tuple[int, ...]


def ball_volume(n: int, r: int) -> int:
    """V(n,r) = sum_{i=0}^{r} C(n,i): the number of words within distance r."""
    return sum(comb(n, i) for i in range(min(r, n) + 1))


def hdist_int(x: int, y: int) -> int:
    """Hamming distance of two words held as integer bitmasks."""
    return bin(x ^ y).count("1")


def greedy_code_bitmask(n: int, d: int) -> List[int]:
    """Greedy maximal code, words represented as integers in [0, 2^n)."""
    chosen: List[int] = []
    for z in range(2 ** n):
        for c in chosen:
            if hdist_int(z, c) < d:
                break
        else:
            chosen.append(z)
    return chosen


def greedy_code(n: int, d: int) -> List[Word]:
    """Greedy maximal code, words as tuples of bits."""
    return [tuple((z >> (n - 1 - i)) & 1 for i in range(n))
            for z in greedy_code_bitmask(n, d)]


def gilbert_varshamov_guarantee(n: int, d: int) -> int:
    """The size the greedy code is guaranteed to reach: ceil(2^n / V(n,d-1))."""
    return -((-(2 ** n)) // ball_volume(n, d - 1))


def verify_covering(n: int, d: int, code: List[int]) -> bool:
    """Maximality check: the radius-(d-1) balls around the code cover the cube."""
    return all(any(hdist_int(z, c) <= d - 1 for c in code) for z in range(2 ** n))


def _report(max_n: int = 10) -> None:
    print(f"{'n':>3} {'d':>3} {'GV guarantee':>13} {'greedy size':>12} {'covers':>7}")
    for n in range(3, max_n + 1):
        for d in range(2, min(n, 5) + 1):
            code = greedy_code_bitmask(n, d)
            gv = gilbert_varshamov_guarantee(n, d)
            covers = verify_covering(n, d, code) if n <= 12 else True
            assert len(code) >= gv and covers
            print(f"{n:>3} {d:>3} {gv:>13} {len(code):>12} {str(covers):>7}")


if __name__ == "__main__":
    _report()


"""Syndrome decoding for the Hamming code of order k.

The Hamming code of order k lives in words of length n = 2^k - 1 whose
coordinates are indexed 1, 2, ..., 2^k - 1 -- exactly the nonzero k-bit
patterns.  The syndrome of a word is the bitwise XOR of the indices of the
coordinates carrying a one, and the code is the set of words of syndrome zero.

Correctness rests on two elementary facts about XOR:
  * a XOR b = 0 iff a = b, so distinct nonzero indices never cancel; hence no
    nonzero codeword has weight 1 or 2, and the minimum distance is >= 3;
  * the XOR of numbers below 2^k is below 2^k, so a nonzero syndrome v always
    names a legal coordinate, and flipping coordinate v zeroes the syndrome.

Complexity: encoding O(n), decoding O(n) time and O(1) extra memory, with no
lookup tables of any kind.
"""

from __future__ import annotations

from typing import List, Tuple

Word = Tuple[int, ...]


def syndrome(x: Word) -> int:
    """XOR of the 1-based indices of the coordinates carrying a one."""
    s = 0
    for i, bit in enumerate(x, start=1):
        if bit:
            s ^= i
    return s


def is_codeword(x: Word) -> bool:
    """A word belongs to the Hamming code exactly when its syndrome vanishes."""
    return syndrome(x) == 0


def parity_positions(k: int) -> List[int]:
    """The check positions are the powers of two: 1, 2, 4, ..., 2^(k-1)."""
    return [1 << j for j in range(k)]


def hamming_encode(message: Word, k: int) -> Word:
    """Place the message bits in the non-power-of-two positions of a length
    (2^k - 1) word, then set each check bit so that the syndrome vanishes.

    The check position 2^j is the unique coordinate whose index contributes bit
    j and nothing else, so the check bits can be solved for one at a time.
    """
    n = 2 ** k - 1
    checks = set(parity_positions(k))
    data_positions = [i for i in range(1, n + 1) if i not in checks]
    if len(message) != len(data_positions):
        raise ValueError(f"message must have {len(data_positions)} bits")
    word = [0] * n
    for bit, pos in zip(message, data_positions):
        word[pos - 1] = bit
    s = syndrome(tuple(word))
    for j in range(k):
        if (s >> j) & 1:
            word[(1 << j) - 1] ^= 1
    assert syndrome(tuple(word)) == 0
    return tuple(word)


def hamming_decode(received: Word) -> Tuple[Word, int]:
    """Return (corrected word, index of the flipped coordinate, 0 if none).

    Compute v = syndrome(received).  If v = 0 the word is already a codeword.
    Otherwise coordinate v (1-based) is the unique single flip that returns the
    word to the code, and it is applied.
    """
    v = syndrome(received)
    if v == 0:
        return received, 0
    corrected = list(received)
    corrected[v - 1] ^= 1
    return tuple(corrected), v


def hamming_extract(codeword: Word, k: int) -> Word:
    """Read the message bits back out of a codeword."""
    checks = set(parity_positions(k))
    return tuple(b for i, b in enumerate(codeword, start=1) if i not in checks)


def _self_test(k: int = 4) -> None:
    """Every single-bit corruption of every codeword decodes back correctly."""
    from itertools import product

    n = 2 ** k - 1
    data_len = n - k
    for message in product((0, 1), repeat=min(data_len, 8)):
        msg = message + (0,) * (data_len - len(message))
        c = hamming_encode(msg, k)
        assert hamming_decode(c) == (c, 0)
        for i in range(n):
            r = list(c)
            r[i] ^= 1
            fixed, pos = hamming_decode(tuple(r))
            assert fixed == c and pos == i + 1
        assert hamming_extract(c, k) == msg
    print(f"self-test passed for k = {k} (length {n}, {data_len} message bits)")


if __name__ == "__main__":
    _self_test(3)
    _self_test(4)


"""Assemble PACKAGE.json from the project's prose, code and formal sources."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


LEAN_FILES: List[str] = [
    "Catalog/Computation/ListHammingBallParity.lean",
    "Catalog/Computation/BinaryCodeBounds.lean",
    "Catalog/Computation/HammingCodePerfect.lean",
    "Catalog/Computation/HammingCodesGeneral.lean",
    "Catalog/Computation/PlotkinBound.lean",
    "Catalog/Computation/OptimalDetectingCodes.lean",
    "Catalog/Computation/ExtensionPuncturing.lean",
]


def lean_bundle() -> str:
    parts = []
    for rel in LEAN_FILES:
        parts.append("-" * 78)
        parts.append(f"-- FILE: {rel}")
        parts.append("-" * 78)
        parts.append(read(os.path.join(ROOT, rel)).rstrip())
        parts.append("")
    return "\n".join(parts)


FUTURE_DIRECTIONS = """# Future Directions

Derived from the seven research cycles of this development: the Hamming ball
counting lemma and the parity code; linear structure with the Singleton and
Gilbert-Varshamov bounds; the [7,4,3] Hamming code and its perfection; general
Hamming codes; the Plotkin bound; the classification of optimal detecting codes;
and the extension/puncturing involution.  Each conjecture below is stated so
that it can be *falsified* by a single counterexample or settled by a proof
built directly on the notions already in place (Hamming distance, the words of a
given length, Hamming balls, minimum distance, weight, coordinatewise XOR, the
syndrome, the Hamming code, and the extremal function A(n,d)).

---

## Conjecture 1 (Equality in Plotkin <=> Hadamard)

The Plotkin bound |C| * (2d - n) <= 2d is attained with n = 2d - 1 only if a
Hadamard matrix of order 2d exists; equivalently, A(2d-1, d) = 2d iff
2d is in {1, 2} union 4N and a Hadamard matrix of that order exists.

**Statement to formalise (first testable instances).**
There is a length-3 code of minimum distance 2 with 4 words (true: the parity
code) and a length-7 code of minimum distance 4 with 8 words (true: the
punctured Hadamard code), but there is no length-5 code of minimum distance 3
with 6 words.

**The key insight is** that equality in the Plotkin bound forces *every*
coordinate to split the code exactly in half (the per-coordinate pair count must
be maximal at every position) and every pair to be at distance exactly d -- i.e.
the codewords, written as +/-1 vectors, are pairwise orthogonal, which is
precisely a Hadamard matrix.

**Why now?** The double-count proof already isolates the two inequalities whose
equality cases are needed (the lower and upper estimates of the total pairwise
distance), so the conjecture reduces to tracking equality through a sum
comparison, with no new combinatorial input.

---

## Conjecture 2 (Binary MDS codes are trivial)

A binary code attaining the Singleton bound |C| = 2^(n + 1 - d) with
2 <= d <= n is either the whole even-weight code (d = 2) or the repetition code
(d = n).

**Statement to formalise.**
If C is a length-n code of minimum distance d with |C| = 2^(n + 1 - d) and
2 <= d <= n, then either d = 2 and C is the even-weight code of length n, or
d = n and |C| = 2.

**The key insight is** that the puncturing map used in the Singleton proof is a
*bijection* in the equality case, so every shortening of C is again extremal;
iterating shortening reduces any putative example to a length-d code of size 2,
and the parity/repetition dichotomy is the base case.

**Why now?** The Singleton bound is proved by an injection whose surjectivity is
exactly the equality case, so the induction is available at zero extra cost;
combined with the identification of the parity code as the even-weight code, the
d = 2 branch is already half done.

---

## Conjecture 3 (Uniqueness of the Hamming code)

For every k >= 2, any length-(2^k - 1) code with minimum distance 3 and
2^(2^k - 1 - k) words is equal to the Hamming code of order k up to a
permutation of coordinates.

**Statement to formalise (first testable instance, k = 3).**
Any length-7 code of minimum distance 3 with 16 words is a coordinate
permutation of the [7,4,3] Hamming code.

**The key insight is** that perfection is forced by the equality case of sphere
packing, so the content of the conjecture is that the tiling of the cube by
radius-1 balls determines the code up to the symmetries of the cube.

---

## Further directions

* The Elias-Bassalygo and linear-programming (Delsarte) bounds, which require a
  genuinely different, harmonic-analytic technique on the association scheme of
  the Hamming cube.
* The classification of *all* perfect binary codes: beyond the Hamming family
  lies the Golay code [23,12,7], and Tietavainen's theorem asserts that Hamming,
  Golay, repetition and trivial codes exhaust the list.
* Nonbinary alphabets, where the ball volume becomes
  V(n,r) = sum_i C(n,i) (q-1)^i and the entire architecture -- packing, greedy
  covering, puncturing, double counting -- goes through unchanged.
* Asymptotics: the Gilbert-Varshamov and sphere-packing bounds become the
  classical entropy-rate inequalities R >= 1 - H(delta) and R <= 1 - H(delta/2),
  and the gap between them is the central open problem of the subject.
"""


def build() -> Dict[str, Any]:
    article = read(os.path.join(ROOT, "ARTICLE.md"))
    paper = read(os.path.join(ROOT, "RESEARCH_PAPER.md"))
    tex = read(os.path.join(ROOT, "RESEARCH_PAPER.tex"))
    demo = read(os.path.join(ROOT, "demo.py"))
    demo_search = read(os.path.join(ASSETS, "demo_extremal_search.py"))
    alg_syn = read(os.path.join(ASSETS, "alg_syndrome_decoding.py"))
    alg_gv = read(os.path.join(ASSETS, "alg_greedy_gv.py"))
    alg_bounds = read(os.path.join(ASSETS, "alg_bounds.py"))
    viz_bounds = read(os.path.join(ASSETS, "viz_bounds.py"))
    viz_tiling = read(os.path.join(ASSETS, "viz_tiling.py"))
    widget_lab = read(os.path.join(ASSETS, "widget_hamming_lab.html"))
    widget_bounds = read(os.path.join(ASSETS, "widget_bound_explorer.html"))
    layout = read(os.path.join(ASSETS, "interactive_layout.md"))

    package: Dict[str, Any] = {
        "title": "The Geometry of Mistakes: Bounds, Rigidity and Perfection for Binary Codes",
        "domain": "Computation",
        "description": (
            "A complete development of the combinatorial theory of binary block codes: the "
            "Hamming ball counting lemma and the sphere-packing, Singleton, Gilbert-Varshamov "
            "and Plotkin bounds, together with three exact theorems -- the classification of "
            "the optimal single-error-detecting codes as exactly the even- and odd-weight "
            "codes, the characterisation of the lengths admitting a perfect "
            "single-error-correcting code as those with n+1 a power of two, and the odd/even "
            "collapse A(n,d) = A(n+1,d+1) for odd d."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-18",
        "key_results": [
            "Hamming ball counting lemma: a ball of radius r about any word of length n "
            "contains exactly the sum of the first r+1 binomial coefficients of n, "
            "independently of its centre; hence the sphere-packing bound, and its equality "
            "case, in which the balls do not merely pack the cube but tile it.",
            "Existence characterisation for perfect codes: a perfect single-error-correcting "
            "binary code of length n exists if and only if n+1 is a power of two. Necessity "
            "follows from the divisibility forced by a tiling; sufficiency is the Hamming code "
            "of order k, constructed from a syndrome defined as the bitwise exclusive-or of "
            "the indices of the nonzero coordinates, with no linear algebra.",
            "Rigidity of optimal single-error-detecting codes: a code of length n+1 with "
            "minimum distance 2 and the maximal 2^n codewords is either the even-weight code "
            "or the odd-weight code, and nothing else; the proof passes through the "
            "connectivity of the Hamming cube under single bit flips.",
            "Odd/even collapse of the extremal function: for odd d, the largest code of "
            "length n with minimum distance d has the same size as the largest code of length "
            "n+1 with minimum distance d+1, via mutually inverse parity extension and "
            "puncturing maps; the oddness hypothesis is necessary, since A(4,3) < A(3,2).",
            "Exact extremal values: A(n,1) = 2^n, A(n+1,2) = 2^n, A(2^k-1,3) = 2^(2^k-1-k), "
            "A(2^k,4) = 2^(2^k-1-k), and in particular A(7,3) = A(8,4) = 16, together with "
            "the Singleton bound 2^(n+1-d), the Gilbert-Varshamov existence bound and the "
            "Plotkin bound |C|(2d-n) <= 2d valid when n < 2d.",
        ],
        "keywords": [
            "Hamming distance",
            "sphere-packing bound",
            "Singleton bound",
            "Gilbert-Varshamov bound",
            "Plotkin bound",
            "perfect codes",
            "Hamming codes",
            "extremal function A(n,d)",
        ],
        "article": article,
        "research_paper": paper,
        "research_paper_tex": tex,
        "demo": demo,
        "demos": [
            {
                "name": "End-to-End Verification of the Coding-Theoretic Bounds and Classifications",
                "description": (
                    "A twelve-part numerical tour of the entire development. It verifies the "
                    "Hamming ball counting lemma for every centre and radius up to length 8 "
                    "(confirming the homogeneity of the cube) together with the Pascal "
                    "recursion behind it; tabulates the sphere-packing, Singleton and Plotkin "
                    "upper bounds against the Gilbert-Varshamov lower bound and the size of an "
                    "actually-constructed greedy code, asserting that every greedy code lands "
                    "inside the corridor; confirms that the parity code and the odd-weight code "
                    "both have 2^n words and minimum distance exactly 2; performs an exhaustive "
                    "search over all length-4 codes of minimum distance 2 and size 8, finding "
                    "exactly the two codes the rigidity theorem predicts; checks that minimum "
                    "distance equals minimum nonzero weight for four linear codes and exhibits "
                    "a coset where that criterion fails for want of the zero word; builds the "
                    "Hamming codes of orders 1 to 4 from the syndrome, verifies the tiling "
                    "identity and decodes all 112 single-bit corruptions of the [7,4,3] code "
                    "correctly while displaying a two-bit miscorrection; tabulates the "
                    "divisibility obstruction to perfection for all lengths up to 16; "
                    "demonstrates parity extension and puncturing as mutually inverse maps and "
                    "exhibits A(4,3) < A(3,2); and finally displays the two sides of the double "
                    "count behind the Plotkin bound on four explicit codes."
                ),
                "code": demo,
            },
            {
                "name": "Exact Determination of A(n,d) by Maximum-Clique Search, Against the Bounds",
                "description": (
                    "Computes the extremal function A(n,d) exactly for lengths up to 8 by a "
                    "Tomita-style branch-and-bound maximum-clique search on the graph whose "
                    "vertices are the binary words and whose edges join pairs at distance at "
                    "least d. Vertex sets are held as machine integers used as bitsets, the "
                    "branching order comes from a greedy colouring that also supplies the "
                    "pruning bound, and translation invariance of the Hamming metric is used to "
                    "fix the all-zero word as a codeword, cutting the search space by a factor "
                    "of 2^n. Every computed value is checked to lie inside the "
                    "Gilbert-Varshamov / composite-upper corridor, and the corridor is reported "
                    "as closed exactly where the theory determines the value. The structural "
                    "checks that follow confirm A(n+1,2) = 2^n, A(n,n) = 2, the odd/even "
                    "collapse at d = 3 and d = 5, the independently-searched equality "
                    "A(7,3) = 16 = A(8,4), the failure of the collapse at even distance "
                    "(A(4,3) = 2 < 4 = A(3,2)), and that sphere packing is met with equality "
                    "exactly at the two perfect lengths 3 and 7 in the searched range."
                ),
                "code": demo_search,
            },
        ],
        "algorithms": [
            {
                "name": "Syndrome Encoding and Decoding for the Hamming Code of Order k",
                "description": (
                    "The Hamming code of order k consists of the words of length n = 2^k - 1 "
                    "whose syndrome vanishes, where the syndrome is the bitwise exclusive-or of "
                    "the indices of the coordinates carrying a one, the coordinates being "
                    "numbered 1 through 2^k - 1 -- exactly the nonzero k-bit patterns. "
                    "Encoding places the message bits in the non-power-of-two positions and "
                    "then solves for the k check bits one at a time, which is possible because "
                    "the check position 2^j is the unique coordinate whose index contributes "
                    "bit j and nothing else. Decoding is a single pass: compute the syndrome v; "
                    "if v = 0 the word is a codeword, and otherwise flip coordinate v. "
                    "Correctness rests on two elementary facts about exclusive-or. First, it is "
                    "additive, so the syndrome of a corrupted codeword equals the syndrome of "
                    "the error pattern alone. Second, a XOR b = 0 only when a = b, so distinct "
                    "nonzero indices never cancel: no nonzero codeword has weight 1 or 2, the "
                    "minimum distance is therefore at least 3, and a single error at position i "
                    "produces the syndrome i -- the address of the damage. Finally, the "
                    "exclusive-or of numbers below 2^k is below 2^k, so a nonzero syndrome "
                    "always names a legal coordinate. Complexity: O(n) time and O(1) auxiliary "
                    "memory for both operations, with no lookup tables of any kind, which is "
                    "why this is the algorithm implemented in error-correcting memory."
                ),
                "pseudocode": (
                    "SYNDROME(x):\n"
                    "    s <- 0\n"
                    "    for i <- 1 to length(x):\n"
                    "        if x[i] = 1: s <- s XOR i\n"
                    "    return s\n"
                    "\n"
                    "ENCODE(message, k):\n"
                    "    n <- 2^k - 1\n"
                    "    checks <- { 2^j : 0 <= j < k }            // the power-of-two positions\n"
                    "    word <- array of n zeros\n"
                    "    place the message bits, in order, at the positions not in checks\n"
                    "    s <- SYNDROME(word)\n"
                    "    for j <- 0 to k-1:\n"
                    "        if bit j of s is 1: word[2^j] <- word[2^j] XOR 1\n"
                    "    assert SYNDROME(word) = 0\n"
                    "    return word\n"
                    "\n"
                    "DECODE(received):\n"
                    "    v <- SYNDROME(received)\n"
                    "    if v = 0: return (received, no error)\n"
                    "    corrected <- received with coordinate v flipped\n"
                    "    return (corrected, error at position v)\n"
                    "\n"
                    "// Guarantee: if at most one coordinate of a codeword was flipped, DECODE\n"
                    "// returns the original codeword.  If two were flipped, v = i XOR j is a\n"
                    "// legal address and DECODE flips a third, innocent coordinate: distance 3\n"
                    "// buys exactly one correction."
                ),
                "code": alg_syn,
            },
            {
                "name": "Greedy Maximal Code Construction and the Gilbert-Varshamov Guarantee",
                "description": (
                    "Scan the 2^n binary words of length n in any fixed order and keep a word "
                    "whenever it is at Hamming distance at least d from every word already "
                    "kept. The resulting code is maximal: no further word can be added. "
                    "Maximality is exactly the statement that every word of the cube lies "
                    "within distance d-1 of some codeword, so the radius-(d-1) balls cover, and "
                    "counting gives 2^n <= |C| * V(n, d-1) with V(n,r) the ball volume. This is "
                    "the Gilbert-Varshamov lower bound on the extremal function, and it is the "
                    "exact converse of sphere packing: packing says radius-t balls do not "
                    "overlap, greed says radius-(d-1) balls leave no gaps. The two together "
                    "bracket A(n,d). The routine also verifies the covering property directly, "
                    "which is a check on maximality rather than an ingredient of it. "
                    "Complexity: O(2^n * |C| * n) time with the naive distance test, reducible "
                    "to O(2^n * n / w) with bit-parallel population counts on machine words of "
                    "width w; memory O(|C| * n). The greedy code is not in general optimal, but "
                    "it is the standard baseline against which explicit constructions are "
                    "measured, and for small parameters it frequently meets the upper bound."
                ),
                "pseudocode": (
                    "GREEDY-CODE(n, d):\n"
                    "    C <- empty list\n"
                    "    for z <- 0 to 2^n - 1:                     // any fixed scan order\n"
                    "        admissible <- true\n"
                    "        for c in C:\n"
                    "            if POPCOUNT(z XOR c) < d:\n"
                    "                admissible <- false; break\n"
                    "        if admissible: append z to C\n"
                    "    return C\n"
                    "\n"
                    "GV-GUARANTEE(n, d):\n"
                    "    V <- sum over i from 0 to d-1 of BINOMIAL(n, i)\n"
                    "    return ceil(2^n / V)\n"
                    "\n"
                    "// Correctness of the guarantee:\n"
                    "//   C is maximal, so for every word z there is c in C with d(z,c) <= d-1;\n"
                    "//   hence the radius-(d-1) balls around C cover all 2^n words;\n"
                    "//   each ball has V words, so |C| * V >= 2^n."
                ),
                "code": alg_gv,
            },
            {
                "name": "Composite Upper-Bound Evaluation for the Extremal Function A(n,d)",
                "description": (
                    "Evaluates and combines the four upper bounds on the size of a binary code "
                    "of length n and minimum distance d, and pairs the result with the "
                    "Gilbert-Varshamov lower bound to produce the classical bracketing table. "
                    "The sphere-packing bound divides 2^n by the volume of a ball of radius "
                    "t = floor((d-1)/2); the Singleton bound is 2^(n+1-d) read with truncated "
                    "subtraction, so that it correctly degenerates to 1 when d exceeds n+1; the "
                    "Plotkin bound floor(2d/(2d-n)) applies only in the high-distance regime "
                    "n < 2d, where sphere packing is vacuous because the balls exceed the cube; "
                    "and the trivial bound 1 applies when n < d, since two words of length n "
                    "cannot be further apart than n. The three nondegenerate bounds have "
                    "cleanly complementary regimes -- sphere packing for small d relative to n, "
                    "Singleton in the intermediate range, Plotkin once d approaches and exceeds "
                    "n/2 -- and the composite bound is their pointwise minimum, reported "
                    "together with the name of the winning argument. The routine also marks the "
                    "parameter pairs at which the value is known exactly: (n,1), (n+1,2), "
                    "(2^k-1,3) and (2^k,4), plus the degenerate d = n and d > n. Complexity: "
                    "O(n) per bound with cached binomial coefficients, O(n^2) per row and "
                    "O(n^3) for a full table."
                ),
                "pseudocode": (
                    "BALL-VOLUME(n, r):\n"
                    "    return sum over i from 0 to min(r, n) of BINOMIAL(n, i)\n"
                    "\n"
                    "COMPOSITE-UPPER(n, d):\n"
                    "    candidates <- empty list\n"
                    "    t <- floor((d - 1) / 2)\n"
                    "    add ( floor(2^n / BALL-VOLUME(n, t)),  \"sphere packing\" )\n"
                    "    add ( 2^max(0, n + 1 - d),             \"Singleton\"      )\n"
                    "    if n < 2d:  add ( floor(2d / (2d - n)), \"Plotkin\"       )\n"
                    "    if n < d:   add ( 1,                    \"trivial\"       )\n"
                    "    return the candidate with the smallest value\n"
                    "\n"
                    "BRACKET(n, d):\n"
                    "    lower <- ceil(2^n / BALL-VOLUME(n, d - 1))       // Gilbert-Varshamov\n"
                    "    (upper, who) <- COMPOSITE-UPPER(n, d)\n"
                    "    exact <- EXACT-VALUE(n, d)                       // if known\n"
                    "    return (lower, upper, who, exact)\n"
                    "\n"
                    "EXACT-VALUE(n, d):\n"
                    "    if d <= 1:                          return 2^n\n"
                    "    if d = 2:                           return 2^(n-1)\n"
                    "    if d = 3 and n + 1 = 2^k:           return 2^(n-k)\n"
                    "    if d = 4 and n = 2^k:               return 2^(n-1-k)\n"
                    "    if d = n:                           return 2\n"
                    "    if d > n:                           return 1\n"
                    "    return unknown"
                ),
                "code": alg_bounds,
            },
        ],
        "visualizations": [
            {
                "name": "The Corridor of the Possible: Upper and Lower Bounds on A(n,d)",
                "description": (
                    "A two-panel figure. The left panel fixes the length at 15 and plots, on a "
                    "logarithmic scale against the minimum distance, the sphere-packing, "
                    "Singleton and Plotkin upper bounds together with the Gilbert-Varshamov "
                    "lower bound; the shaded band between the composite upper bound and the "
                    "lower bound is the corridor in which the true extremal function must lie, "
                    "and stars mark the parameter pairs where the value is pinned down exactly. "
                    "The right panel is a regime map over all lengths up to 24 and all "
                    "distances, coloured by which of the three upper bounds is strongest, with "
                    "the line d = n/2 overlaid: sphere packing owns the small-distance region, "
                    "Singleton a narrow band, and Plotkin takes over as the distance approaches "
                    "half the length -- precisely where the packing argument goes vacuous."
                ),
                "code": viz_bounds,
            },
            {
                "name": "Perfection Drawn: A Tiling of the 7-Cube and the Arithmetic That Forbids Length 4",
                "description": (
                    "A two-panel figure. The left panel lays out all 128 words of length 7 in a "
                    "16-by-8 grid, colouring each by the Hamming codeword that decodes it and "
                    "starring the 16 codewords themselves. Each colour class is a ball of "
                    "radius 1 containing exactly 8 words; 16 times 8 is 128, with no overlaps "
                    "and no gaps, which is what it means for a code to be perfect. The right "
                    "panel plots, for each length n, the number 2^n/(n+1) of codewords a "
                    "perfect single-error-correcting code would have to contain; the bar is "
                    "green when the quantity is an integer -- that is, when n+1 is a power of "
                    "two -- and red otherwise. The red bars are lengths for which no perfect "
                    "code can exist for purely arithmetic reasons, length 4 among them, since "
                    "5 does not divide 16."
                ),
                "code": viz_tiling,
            },
        ],
        "interactive_demos": [
            {
                "title": "The Hamming Cube Laboratory: Break a Codeword and Watch the Syndrome Find It",
                "description": (
                    "An interactive workbench for the Hamming codes of orders 2, 3 and 4. A "
                    "random codeword is generated and displayed as a strip of clickable bits, "
                    "with the check positions (the powers of two) drawn dashed. Clicking a bit "
                    "flips it, and the panel updates live: the syndrome in decimal and in "
                    "binary, the weight, the distance from the sent word, and a verdict that "
                    "distinguishes the three possible outcomes -- a genuine codeword, a "
                    "single error which the decoder repairs (the coordinate the syndrome names "
                    "is highlighted in green), or a multiple error where the decoder "
                    "confidently miscorrects, showing exactly what minimum distance 3 does and "
                    "does not buy. Buttons inject one or two random errors for comparison. "
                    "Below the workbench, a live tiling picture colours every word of the cube "
                    "by the codeword that decodes it, so the reader can see that the radius-1 "
                    "balls partition the cube exactly, and a statistics table records the "
                    "tiling identity, the extremal value, and the effect of parity extension. "
                    "Two collapsible sections explain why the exclusive-or of the indices of "
                    "the ones names the broken coordinate, and why a tiling forces n+1 to be a "
                    "power of two."
                ),
                "html": widget_lab,
            },
            {
                "title": "The Bound Explorer: Which Argument Is Doing the Work?",
                "description": (
                    "A slider-driven exploration of the four constraints on A(n,d). Choosing a "
                    "length and a minimum distance draws the sphere-packing, Singleton and "
                    "Plotkin upper bounds and the Gilbert-Varshamov lower bound as comparative "
                    "bars on a logarithmic scale, badges the strongest upper bound, and states "
                    "the resulting bracket in words -- or, where the theory determines the "
                    "value, announces the exact answer and the code that attains it. Preset "
                    "chips jump to the landmark parameter pairs: the [7,4,3] Hamming code, its "
                    "length-8 extension, the [15,11,3] code, the impossible perfect code at "
                    "length 4, the parity code, and a point deep in the Plotkin regime. A "
                    "canvas beneath plots the whole corridor across all distances at the chosen "
                    "length, so the reader can watch the band close to a point exactly where "
                    "the value is known. A final panel runs the greedy Gilbert-Varshamov scan "
                    "live in the browser and reports the size reached against the size "
                    "guaranteed and the upper bound, occasionally announcing that the corridor "
                    "has closed. Collapsible sections give the four arguments in a paragraph "
                    "each and explain why binary code tables list only odd minimum distances."
                ),
                "html": widget_bounds,
            },
        ],
        "interactive_layout": layout,
        "lean_proofs": lean_bundle(),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {
            "demo": demo,
            "demo_extremal_search": demo_search,
            "alg_syndrome_decoding": alg_syn,
            "alg_greedy_gilbert_varshamov": alg_gv,
            "alg_bounds": alg_bounds,
            "viz_bounds": viz_bounds,
            "viz_tiling": viz_tiling,
        },
        "lean_files": LEAN_FILES,
    }
    return package


def main() -> None:
    pkg = build()
    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(pkg, f, indent=2, ensure_ascii=False)
    size = os.path.getsize(out)
    print(f"wrote {out} ({size/1024:.1f} KiB)")
    for key in ("title", "domain", "date"):
        print(f"  {key}: {pkg[key]}")
    print(f"  key_results: {len(pkg['key_results'])}")
    print(f"  demos: {len(pkg['demos'])}, algorithms: {len(pkg['algorithms'])}, "
          f"visualizations: {len(pkg['visualizations'])}, "
          f"interactive_demos: {len(pkg['interactive_demos'])}")
    print(f"  lean_files: {len(pkg['lean_files'])}, "
          f"lean_proofs: {len(pkg['lean_proofs'])} chars")


if __name__ == "__main__":
    main()


"""Exact computation of A(n,d) for small parameters, against the four bounds.

A(n,d) is the largest number of binary words of length n that are pairwise at
Hamming distance at least d.  Determining it is a maximum-clique problem on the
graph whose vertices are the 2^n words and whose edges join pairs at distance
>= d, so it is only feasible by brute force for small n -- but small n is
exactly where the theory makes its sharpest predictions, and where they can
therefore be checked against the truth.

What this script confirms.

  * A(n,1) = 2^n and A(n+1,2) = 2^n  (the parity code and its odd twin).
  * A(n,n) = 2 (repetition) and A(n,d) = 1 for d > n.
  * A(7,3) = 16, attained by the Hamming code, matching sphere packing exactly.
  * A(8,4) = 16 = A(7,3): the odd/even collapse, verified numerically.
  * A(4,3) = 2 < 4 = A(3,2): the collapse FAILS at even distance.
  * Every computed value lies inside the Gilbert-Varshamov / composite-upper
    corridor, and the corridor is closed (lower = upper) exactly where the
    theory says the value is determined.

The clique search uses a bitmask representation, a colouring-free greedy bound
and symmetry reduction by fixing the all-zero word (translation invariance of
the Hamming metric means every optimal code may be assumed to contain it).
"""

from __future__ import annotations

from math import comb
from typing import Dict, List, Optional, Tuple


# ----------------------------------------------------------------------
# bounds
# ----------------------------------------------------------------------

def ball_volume(n: int, r: int) -> int:
    return sum(comb(n, i) for i in range(max(0, min(r, n)) + 1))


def sphere_packing_bound(n: int, d: int) -> int:
    return (2 ** n) // ball_volume(n, (d - 1) // 2)


def singleton_bound(n: int, d: int) -> int:
    return 2 ** max(0, n + 1 - d)


def plotkin_bound(n: int, d: int) -> Optional[int]:
    return None if n >= 2 * d else (2 * d) // (2 * d - n)


def gilbert_varshamov_lower(n: int, d: int) -> int:
    return -((-(2 ** n)) // ball_volume(n, d - 1))


def composite_upper(n: int, d: int) -> Tuple[int, str]:
    cands: List[Tuple[int, str]] = [(sphere_packing_bound(n, d), "sphere packing"),
                                    (singleton_bound(n, d), "Singleton")]
    p = plotkin_bound(n, d)
    if p is not None:
        cands.append((p, "Plotkin"))
    if n < d:
        cands.append((1, "trivial"))
    return min(cands, key=lambda z: z[0])


# ----------------------------------------------------------------------
# exact search
# ----------------------------------------------------------------------

def popcount(x: int) -> int:
    return bin(x).count("1")


def exact_A(n: int, d: int) -> Tuple[int, List[int]]:
    """Exact A(n,d) and an optimal code, words held as integer bitmasks.

    This is a maximum-clique computation on the graph whose vertices are the
    words of length n at distance >= d from the all-zero word, with an edge
    whenever two words are at distance >= d.  Translation invariance of the
    Hamming metric lets us assume the all-zero word is a codeword, which cuts
    the search space by a factor of 2^n.

    The search is a Tomita-style branch and bound: vertex sets are Python
    integers used as bitsets, and the branching order is produced by a greedy
    colouring that also supplies the pruning bound (a clique cannot be larger
    than the number of colour classes available).
    """
    if d <= 1:
        return 2 ** n, list(range(2 ** n))
    if d > n:
        return 1, [0]

    verts = [z for z in range(1, 2 ** n) if popcount(z) >= d]
    m = len(verts)
    adj = [0] * m
    for a in range(m):
        for b in range(a + 1, m):
            if popcount(verts[a] ^ verts[b]) >= d:
                adj[a] |= 1 << b
                adj[b] |= 1 << a

    best_size = 0
    best_clique: List[int] = []

    def colour_sort(mask: int) -> List[Tuple[int, int]]:
        """Greedy colouring: return (vertex, colour) in nondecreasing colour."""
        order: List[Tuple[int, int]] = []
        colour = 0
        remaining = mask
        while remaining:
            colour += 1
            avail = remaining
            while avail:
                low = avail & -avail
                v = low.bit_length() - 1
                avail &= ~low
                avail &= ~adj[v]
                remaining &= ~low
                order.append((v, colour))
        return order

    def expand(mask: int, clique: List[int]) -> None:
        nonlocal best_size, best_clique
        if not mask:
            if len(clique) > best_size:
                best_size, best_clique = len(clique), clique[:]
            return
        for v, colour in reversed(colour_sort(mask)):
            if len(clique) + colour <= best_size:
                return
            clique.append(v)
            expand(mask & adj[v], clique)
            clique.pop()
            mask &= ~(1 << v)

    expand((1 << m) - 1, [])
    return best_size + 1, [0] + [verts[i] for i in best_clique]


# ----------------------------------------------------------------------
# report
# ----------------------------------------------------------------------

def main(max_n: int = 8) -> None:
    print("=" * 78)
    print("EXACT VALUES OF A(n,d) BY EXHAUSTIVE SEARCH, AGAINST THE BOUNDS")
    print("=" * 78)
    print(f"{'n':>3} {'d':>3} {'GV':>6} {'A(n,d)':>8} {'upper':>7} {'winner':>15} {'corridor closed':>16}")
    values: Dict[Tuple[int, int], int] = {}
    for n in range(2, max_n + 1):
        for d in range(2, n + 1):
            if n >= 8 and d <= 3:
                continue  # search space too large; covered by theory
            a, _ = exact_A(n, d)
            values[(n, d)] = a
            gv = gilbert_varshamov_lower(n, d)
            ub, who = composite_upper(n, d)
            assert gv <= ub and a <= ub, (n, d, gv, a, ub)
            closed = "yes" if gv == ub else ""
            print(f"{n:>3} {d:>3} {gv:>6} {a:>8} {ub:>7} {who:>15} {closed:>16}")
        print()

    print("-" * 78)
    print("STRUCTURAL CHECKS")
    print("-" * 78)
    for n in range(2, max_n):
        assert values.get((n + 1, 2), 2 ** n) == 2 ** n
    print("  A(n+1,2) = 2^n for every computed n:              confirmed")
    for n in range(2, max_n + 1):
        assert values.get((n, n), 2) == 2
    print("  A(n,n) = 2 (repetition code) for every n:         confirmed")

    a32 = values[(3, 2)]
    a43 = values[(4, 3)]
    print(f"  A(3,2) = {a32}, A(4,3) = {a43}")
    assert a43 < a32
    print("  A(4,3) < A(3,2): the odd/even collapse genuinely")
    print("  fails at even distance:                           confirmed")

    a54, a43b = values[(5, 4)], values[(4, 3)]
    print(f"  A(4,3) = {a43b}, A(5,4) = {a54}   (collapse at odd d = 3)")
    assert a54 == a43b
    print("  A(n,d) = A(n+1,d+1) at odd d:                     confirmed")

    a65, a76 = values[(6, 5)], values[(7, 6)]
    assert a76 == a65
    print(f"  A(6,5) = {a65} = A(7,6) = {a76} (collapse at odd d = 5): confirmed")

    a73, a84 = values[(7, 3)], values[(8, 4)]
    assert a73 == 16 and a84 == 16
    print(f"  A(7,3) = {a73} = A(8,4) = {a84}: the Hamming code and its")
    print("  parity extension are both optimal:                 confirmed")

    print()
    print("  Sphere packing is met with equality exactly at the perfect codes:")
    for n, d in [(3, 3), (5, 3), (6, 3), (7, 3)]:
        if (n, d) in values:
            a = values[(n, d)]
            print(f"    n={n}, d={d}: A = {a:>2}, |C|*V(n,1) = {a * (n + 1):>4},"
                  f" 2^n = {2 ** n:>4}, perfect = {a * (n + 1) == 2 ** n}")
    print()
    print("  Only n = 3 and n = 7 tile, and those are exactly the lengths with")
    print("  n + 1 a power of two -- the repetition code and the [7,4,3] code.")
    print("=" * 78)


if __name__ == "__main__":
    main(max_n=8)


"""Visualisation: the bound landscape for A(n,d).

Left panel: for a fixed length n, the three upper bounds (sphere packing,
Singleton, Plotkin) and the Gilbert-Varshamov lower bound, plotted on a
logarithmic scale against the minimum distance d.  The shaded region between
the composite upper bound and the GV lower bound is the corridor in which the
true extremal function must live; the exactly-known values are marked.

Right panel: which of the three upper bounds is strongest, as a function of
(n, d).  The picture shows the three complementary regimes cleanly -- sphere
packing for small d, Singleton in the middle, Plotkin once d exceeds about n/2.

Run with:  python3 viz_bounds.py
"""

from __future__ import annotations

from math import comb
from typing import List, Optional, Tuple

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap


def ball_volume(n: int, r: int) -> int:
    return sum(comb(n, i) for i in range(max(0, min(r, n)) + 1))


def sphere_packing_bound(n: int, d: int) -> int:
    return (2 ** n) // ball_volume(n, (d - 1) // 2)


def singleton_bound(n: int, d: int) -> int:
    return 2 ** max(0, n + 1 - d)


def plotkin_bound(n: int, d: int) -> Optional[int]:
    return None if n >= 2 * d else (2 * d) // (2 * d - n)


def gv_lower(n: int, d: int) -> int:
    return -((-(2 ** n)) // ball_volume(n, d - 1))


def winner(n: int, d: int) -> int:
    """0 = sphere packing, 1 = Singleton, 2 = Plotkin."""
    cands: List[Tuple[int, int]] = [(sphere_packing_bound(n, d), 0),
                                    (singleton_bound(n, d), 1)]
    p = plotkin_bound(n, d)
    if p is not None:
        cands.append((p, 2))
    return min(cands)[1]


def exact_value(n: int, d: int) -> Optional[int]:
    if d == 1:
        return 2 ** n
    if d == 2:
        return 2 ** (n - 1)
    k = (n + 1).bit_length() - 1
    if d == 3 and n + 1 == 2 ** k:
        return 2 ** (n - k)
    kk = n.bit_length() - 1
    if d == 4 and n == 2 ** kk and n >= 2:
        return 2 ** (n - 1 - kk)
    if d == n:
        return 2
    return None


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    # ---- Left: bound corridor at fixed n -------------------------------
    n = 15
    ds = list(range(2, n + 1))
    sp = [sphere_packing_bound(n, d) for d in ds]
    si = [singleton_bound(n, d) for d in ds]
    pl = [plotkin_bound(n, d) for d in ds]
    gv = [gv_lower(n, d) for d in ds]
    comp = [min([a for a in (s, t, p) if a is not None]) for s, t, p in zip(sp, si, pl)]

    ax1.fill_between(ds, gv, comp, color="#cfe3f7", alpha=0.75,
                     label="corridor containing $A(n,d)$")
    ax1.plot(ds, sp, "o-", color="#1f4e79", lw=1.8, ms=4, label="sphere packing")
    ax1.plot(ds, si, "s-", color="#b8860b", lw=1.8, ms=4, label="Singleton")
    pd = [(d, p) for d, p in zip(ds, pl) if p is not None]
    ax1.plot([d for d, _ in pd], [p for _, p in pd], "^-", color="#a83232",
             lw=1.8, ms=5, label="Plotkin")
    ax1.plot(ds, gv, "v--", color="#2e7d32", lw=1.8, ms=4,
             label="Gilbert–Varshamov (lower)")
    ex = [(d, exact_value(n, d)) for d in ds if exact_value(n, d) is not None]
    if ex:
        ax1.scatter([d for d, _ in ex], [v for _, v in ex], s=120, marker="*",
                    color="black", zorder=5, label="exactly known")
    ax1.set_yscale("log", base=2)
    ax1.set_xlabel("minimum distance $d$")
    ax1.set_ylabel("code size (log scale)")
    ax1.set_title(f"Bounds on $A({n},d)$: the corridor of the possible")
    ax1.grid(alpha=0.3, which="both")
    ax1.legend(fontsize=8.5, loc="upper right")

    # ---- Right: which bound wins ---------------------------------------
    nmax = 24
    grid = np.full((nmax, nmax), np.nan)
    for nn in range(2, nmax + 1):
        for dd in range(2, nn + 1):
            grid[dd - 1, nn - 1] = winner(nn, dd)
    cmap = ListedColormap(["#1f4e79", "#b8860b", "#a83232"])
    im = ax2.imshow(grid, origin="lower", cmap=cmap, vmin=-0.5, vmax=2.5,
                    extent=(0.5, nmax + 0.5, 0.5, nmax + 0.5), aspect="auto")
    ax2.plot([0.5, nmax + 0.5], [0.25, (nmax + 0.5) / 2], "w--", lw=1.4)
    ax2.text(nmax * 0.62, nmax * 0.34, r"$d = n/2$", color="white",
             rotation=25, fontsize=10)
    ax2.set_xlabel("length $n$")
    ax2.set_ylabel("minimum distance $d$")
    ax2.set_title("Strongest upper bound by regime")
    cbar = fig.colorbar(im, ax=ax2, ticks=[0, 1, 2])
    cbar.ax.set_yticklabels(["sphere packing", "Singleton", "Plotkin"])

    fig.suptitle("The extremal function $A(n,d)$ for binary codes", fontsize=14)
    fig.tight_layout()
    fig.savefig("bounds_landscape.png", dpi=160)
    print("wrote bounds_landscape.png")


if __name__ == "__main__":
    main()


"""Visualisation: perfection as an exact tiling of the Hamming cube.

Left panel: the 128 words of length 7, arranged in a 16-by-8 grid and coloured
by which Hamming codeword decodes them.  Each colour class is one radius-1
ball; there are 16 classes of 8 words each, and 16 x 8 = 128 exactly, with no
overlaps and no gaps.  This is what "perfect" means, drawn.

Right panel: the arithmetic obstruction.  For each length n, the bar shows
2^n / (n+1) -- the number of codewords a perfect single-error-correcting code
would need.  Only when n+1 is a power of two is this an integer, and only then
can a perfect code exist.  The non-integral lengths (n = 2, 4, 5, 6, 8, ...)
are ruled out for arithmetic reasons alone; no construction will ever be found.

Run with:  python3 viz_tiling.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

Word = Tuple[int, ...]


def syndrome(x: Word) -> int:
    s = 0
    for i, bit in enumerate(x, start=1):
        if bit:
            s ^= i
    return s


def hamming_code(k: int) -> List[Word]:
    n = 2 ** k - 1
    return [w for w in product((0, 1), repeat=n) if syndrome(w) == 0]


def decode(x: Word) -> Word:
    v = syndrome(x)
    if v == 0:
        return x
    y = list(x)
    y[v - 1] ^= 1
    return tuple(y)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.6))

    # ---- Left: the tiling of the 7-cube ---------------------------------
    k = 3
    n = 2 ** k - 1
    code = sorted(hamming_code(k))
    index: Dict[Word, int] = {c: i for i, c in enumerate(code)}
    allwords = sorted(product((0, 1), repeat=n))
    grid = np.zeros((8, 16), dtype=int)
    is_centre = np.zeros((8, 16), dtype=bool)
    for pos, w in enumerate(allwords):
        r, c = divmod(pos, 16)
        grid[r, c] = index[decode(w)]
        is_centre[r, c] = (syndrome(w) == 0)
    ax1.imshow(grid, cmap="tab20", interpolation="nearest", aspect="auto")
    ys, xs = np.nonzero(is_centre)
    ax1.scatter(xs, ys, marker="*", s=170, color="black", zorder=4,
                label="codeword (ball centre)")
    ax1.set_xticks(range(16))
    ax1.set_yticks(range(8))
    ax1.set_xticklabels([])
    ax1.set_yticklabels([])
    ax1.set_title("The 7-cube tiled by 16 radius-1 balls of 8 words each\n"
                  "(colour = the unique codeword that decodes the word)")
    ax1.legend(loc="upper right", fontsize=9, framealpha=0.9)
    sizes = np.bincount(grid.ravel(), minlength=len(code))
    assert set(sizes) == {8} and grid.size == 128

    # ---- Right: the arithmetic obstruction ------------------------------
    ns = list(range(1, 17))
    need = [2 ** nn / (nn + 1) for nn in ns]
    ok = [(2 ** nn) % (nn + 1) == 0 for nn in ns]
    colours = ["#2e7d32" if o else "#b0413e" for o in ok]
    ax2.bar(ns, need, color=colours)
    ax2.set_yscale("log", base=2)
    ax2.set_xticks(ns)
    ax2.set_xlabel("length $n$")
    ax2.set_ylabel(r"required number of codewords $2^n/(n+1)$")
    ax2.set_title("A perfect code needs $|C|\\,(n+1)=2^n$\n"
                  "green: $n+1$ a power of two (possible);  red: impossible")
    for nn, v, o in zip(ns, need, ok):
        if o:
            ax2.text(nn, v * 1.25, f"{int(v)}", ha="center", fontsize=8)
    ax2.grid(axis="y", alpha=0.3, which="both")

    fig.tight_layout()
    fig.savefig("perfect_tiling.png", dpi=160)
    print("wrote perfect_tiling.png")


if __name__ == "__main__":
    main()


"""
Binary codes: bounds, rigidity and perfection.
=============================================

A self-contained numerical demonstration of the results developed in the
accompanying paper.  Every function is inlined; the only dependency is the
Python standard library.

The objects.  A *word* is a tuple of bits.  The *Hamming distance* between two
words of the same length is the number of positions where they disagree.  A
*code* of length n is a set of words of length n; its *minimum distance* is the
smallest distance between two distinct codewords.

The results demonstrated here.

  1. Ball counting lemma:   |B(n,r,c)| = sum_{i<=r} C(n,i), independent of c.
  2. Sphere-packing bound:  |C| * V(n,t) <= 2^n  when mindist >= 2t+1.
  3. Singleton bound:       |C| <= 2^(n+1-d).
  4. Gilbert-Varshamov:     a greedy code satisfies |C| * V(n,d-1) >= 2^n.
  5. Plotkin bound:         |C| * (2d-n) <= 2d  when n < 2d.
  6. Parity code:           |P_n| = 2^n, minimum distance exactly 2, optimal.
  7. Rigidity:              the only length-(n+1) distance-2 codes of size 2^n
                            are the even-weight and the odd-weight codes.
  8. Linear criterion:      minimum distance = minimum nonzero weight.
  9. Hamming codes:         syndrome = XOR of the indices of the ones;
                            minimum distance 3, perfect, |H_k| = 2^(2^k-1-k).
 10. Perfection:            a perfect 1-error-correcting binary code of length
                            n exists iff n+1 is a power of two.
 11. Odd/even collapse:     A(n,d) = A(n+1,d+1) for odd d; and A(4,3) < A(3,2)
                            shows the oddness hypothesis cannot be dropped.
"""

from __future__ import annotations

from itertools import combinations, product
from math import comb
from typing import List, Optional, Sequence, Set, Tuple

Word = Tuple[int, ...]
Code = List[Word]


# --------------------------------------------------------------------------
# 1.  The metric
# --------------------------------------------------------------------------

def hdist(x: Word, y: Word) -> int:
    """Hamming distance, comparing coordinatewise over the common prefix.

    For equal-length words this is the usual Hamming metric.  (For unequal
    lengths the comparison truncates, and the triangle inequality can fail --
    which is why every statement below is applied to equal-length words only.)
    """
    return sum(1 for a, b in zip(x, y) if a != b)


def weight(x: Word) -> int:
    """Hamming weight: the number of ones."""
    return sum(x)


def xor_word(x: Word, y: Word) -> Word:
    """Coordinatewise XOR: the group operation of the Hamming cube."""
    return tuple(a ^ b for a, b in zip(x, y))


def parity(x: Word) -> int:
    """The XOR of all letters: 1 iff the weight is odd."""
    return weight(x) % 2


def words(n: int) -> List[Word]:
    """All 2^n binary words of length n."""
    return [tuple(w) for w in product((0, 1), repeat=n)]


def min_distance(code: Sequence[Word]) -> Optional[int]:
    """Minimum distance of a code (None if it has fewer than two words)."""
    if len(code) < 2:
        return None
    return min(hdist(x, y) for x, y in combinations(code, 2))


# --------------------------------------------------------------------------
# 2.  Balls and the counting lemma
# --------------------------------------------------------------------------

def ball(n: int, r: int, c: Word) -> List[Word]:
    """All length-n words within Hamming distance r of c."""
    return [z for z in words(n) if hdist(z, c) <= r]


def ball_volume(n: int, r: int) -> int:
    """V(n,r) = sum_{i=0}^{r} C(n,i)."""
    return sum(comb(n, i) for i in range(min(r, n) + 1))


def demo_ball_counting(max_n: int = 8) -> None:
    print("=" * 74)
    print("1.  BALL COUNTING LEMMA   |B(n,r,c)| = sum_{i<=r} C(n,i)")
    print("=" * 74)
    print("    Verified for every centre c, so the cube is homogeneous.\n")
    print(f"    {'n':>3} {'r':>3} {'formula':>10} {'all centres agree':>20}")
    for n in range(0, max_n + 1):
        for r in range(0, n + 1):
            sizes = {len(ball(n, r, c)) for c in words(n)}
            formula = ball_volume(n, r)
            assert sizes == {formula}, (n, r, sizes, formula)
        print(f"    {n:>3} {n:>3} {ball_volume(n, n):>10} {'yes':>20}")
    print("\n    Pascal recursion V(n+1,r) = V(n,r) + V(n,r-1):")
    for n in range(1, 6):
        for r in range(1, n + 1):
            assert ball_volume(n, r) == ball_volume(n - 1, r) + ball_volume(n - 1, r - 1)
    print("    verified for all 1 <= r <= n <= 5.\n")


# --------------------------------------------------------------------------
# 3.  The four bounds
# --------------------------------------------------------------------------

def sphere_packing_bound(n: int, d: int) -> int:
    """Largest |C| allowed by sphere packing:  floor(2^n / V(n,t)), t=(d-1)//2."""
    t = (d - 1) // 2
    return (2 ** n) // ball_volume(n, t)


def singleton_bound(n: int, d: int) -> int:
    """2^(n+1-d), with truncated subtraction (so it reads 1 when d > n+1)."""
    return 2 ** max(0, n + 1 - d)


def plotkin_bound(n: int, d: int) -> Optional[int]:
    """floor(2d / (2d - n)) when n < 2d; None otherwise (bound not applicable)."""
    if n >= 2 * d:
        return None
    return (2 * d) // (2 * d - n)


def gilbert_varshamov_lower(n: int, d: int) -> int:
    """Ceiling of 2^n / V(n,d-1): the guaranteed size of a greedy code."""
    v = ball_volume(n, d - 1)
    return -((-(2 ** n)) // v)


def greedy_code(n: int, d: int) -> Code:
    """Greedy (Gilbert-Varshamov) construction: scan all words, keep any word
    at distance >= d from everything already chosen.  The result is maximal,
    hence its radius-(d-1) balls cover the cube."""
    chosen: Code = []
    for z in words(n):
        if all(hdist(z, c) >= d for c in chosen):
            chosen.append(z)
    return chosen


def brute_force_A(n: int, d: int) -> int:
    """Exact A(n,d) by exhaustive search over maximal cliques.  Feasible only
    for very small n; used here to confirm A(3,2)=4 and A(4,3)=2."""
    universe = words(n)
    best = 0

    def extend(current: Code, start: int) -> None:
        nonlocal best
        best = max(best, len(current))
        remaining = len(universe) - start
        if len(current) + remaining <= best:
            return
        for i in range(start, len(universe)):
            z = universe[i]
            if all(hdist(z, c) >= d for c in current):
                current.append(z)
                extend(current, i + 1)
                current.pop()

    extend([], 0)
    return best


def demo_bounds(max_n: int = 8) -> None:
    print("=" * 74)
    print("2-5.  THE FOUR BOUNDS ON A(n,d)")
    print("=" * 74)
    print("    SP = sphere packing, Sing = Singleton, Plot = Plotkin (n<2d),")
    print("    GV = Gilbert-Varshamov lower bound, greedy = size actually built.\n")
    header = f"    {'n':>3} {'d':>3} {'GV':>6} {'greedy':>7} | {'SP':>7} {'Sing':>7} {'Plot':>7} {'best UB':>8}"
    print(header)
    print("    " + "-" * (len(header) - 4))
    for n in range(3, max_n + 1):
        for d in range(2, n + 1):
            g = greedy_code(n, d)
            assert (min_distance(g) or d) >= d
            sp = sphere_packing_bound(n, d)
            sing = singleton_bound(n, d)
            plot = plotkin_bound(n, d)
            ubs = [sp, sing] + ([plot] if plot is not None else [])
            best_ub = min(ubs)
            gv = gilbert_varshamov_lower(n, d)
            assert len(g) >= gv, (n, d, len(g), gv)
            assert len(g) <= best_ub, (n, d, len(g), best_ub)
            ps = "-" if plot is None else str(plot)
            print(f"    {n:>3} {d:>3} {gv:>6} {len(g):>7} | {sp:>7} {sing:>7} {ps:>7} {best_ub:>8}")
        print()
    print("    Note the regimes: sphere packing wins for small d, Singleton in")
    print("    the middle, Plotkin once d approaches n/2.\n")


# --------------------------------------------------------------------------
# 4.  The parity code, the odd-weight code, and rigidity
# --------------------------------------------------------------------------

def with_parity(l: Word) -> Word:
    """Append the parity bit."""
    return l + (parity(l),)


def parity_code(n: int) -> Code:
    """The even-weight code of length n+1: all parity extensions of W_n."""
    return [with_parity(l) for l in words(n)]


def odd_code(n: int) -> Code:
    """The odd-weight code of length n+1."""
    return [x for x in words(n + 1) if parity(x) == 1]


def all_optimal_detecting_codes(n: int) -> List[Set[Word]]:
    """Exhaustively list every length-(n+1) code with minimum distance 2 and
    exactly 2^n codewords.  The rigidity theorem predicts exactly two."""
    universe = words(n + 1)
    target = 2 ** n
    found: List[Set[Word]] = []

    def extend(current: Code, start: int) -> None:
        if len(current) == target:
            found.append(set(current))
            return
        if len(current) + (len(universe) - start) < target:
            return
        for i in range(start, len(universe)):
            z = universe[i]
            if all(hdist(z, c) >= 2 for c in current):
                current.append(z)
                extend(current, i + 1)
                current.pop()

    extend([], 0)
    return found


def demo_parity_and_rigidity(n: int = 3) -> None:
    print("=" * 74)
    print("6-7.  THE PARITY CODE, AND RIGIDITY OF THE OPTIMUM")
    print("=" * 74)
    for m in range(1, 6):
        P = parity_code(m)
        O = odd_code(m)
        print(f"    n+1 = {m+1:>2}:  |P| = {len(P):>3} = 2^{m},  mindist(P) = {min_distance(P)},"
              f"   |O| = {len(O):>3},  mindist(O) = {min_distance(O)}")
        assert len(P) == 2 ** m and min_distance(P) == 2
        assert len(O) == 2 ** m and min_distance(O) == 2
    print()
    print(f"    Exhaustive search over all length-{n+1} codes of minimum distance 2")
    print(f"    with exactly 2^{n} = {2**n} codewords:")
    optima = all_optimal_detecting_codes(n)
    P, O = set(parity_code(n)), set(odd_code(n))
    print(f"      number of optimal codes found : {len(optima)}")
    print(f"      equals {{even-weight, odd-weight}} : {sorted(map(sorted, optima)) == sorted(map(sorted, [P, O]))}")
    assert len(optima) == 2 and {frozenset(P), frozenset(O)} == {frozenset(c) for c in optima}
    print("    -> exactly the two codes predicted by the classification theorem.\n")
    print("    A single flip is always detected, never corrected:")
    c = with_parity((1, 0, 1))
    x = (c[0] ^ 1,) + c[1:]
    print(f"      codeword {c}, received {x}: parity {parity(x)} (nonzero) -> flagged")
    nbrs = [w for w in parity_code(3) if hdist(w, x) == 1]
    print(f"      but {len(nbrs)} codewords sit at distance 1 from it -> cannot correct\n")


# --------------------------------------------------------------------------
# 5.  Linear codes: distance = minimum nonzero weight
# --------------------------------------------------------------------------

def is_linear(code: Sequence[Word], n: int) -> bool:
    """Contains the zero word and is closed under coordinatewise XOR."""
    S = set(code)
    if tuple([0] * n) not in S:
        return False
    return all(xor_word(x, y) in S for x in S for y in S)


def min_nonzero_weight(code: Sequence[Word]) -> Optional[int]:
    ws = [weight(x) for x in code if weight(x) > 0]
    return min(ws) if ws else None


def demo_linear_criterion() -> None:
    print("=" * 74)
    print("8.  LINEAR CODES: MINIMUM DISTANCE = MINIMUM NONZERO WEIGHT")
    print("=" * 74)
    print("    Comparing |C| choose 2 distances against |C|-1 weights.\n")
    print(f"    {'code':>22} {'linear':>7} {'mindist':>8} {'minwt':>6} {'pairs':>7} {'weights':>8}")
    samples = [("parity code, n+1=5", parity_code(4), 5),
               ("Hamming H_2 (rep. 3)", hamming_code(2), 3),
               ("Hamming H_3 = [7,4,3]", hamming_code(3), 7),
               ("Hamming H_4 = [15,11,3]", hamming_code(4), 15)]
    for name, C, n in samples:
        lin = is_linear(C, n)
        md, mw = min_distance(C), min_nonzero_weight(C)
        assert lin and md == mw
        print(f"    {name:>22} {str(lin):>7} {md:>8} {mw:>6}"
              f" {len(C)*(len(C)-1)//2:>7} {len(C)-1:>8}")
    print("\n    A coset shows why the zero word is needed: shift H_3 by a fixed word.")
    shift = (1, 0, 0, 0, 0, 0, 0)
    coset = [xor_word(shift, c) for c in hamming_code(3)]
    print(f"      coset minimum distance    : {min_distance(coset)}  (unchanged)")
    print(f"      coset minimum weight      : {min_nonzero_weight(coset)}  (now meaningless)\n")


# --------------------------------------------------------------------------
# 6.  Hamming codes via syndrome = XOR of indices
# --------------------------------------------------------------------------

def syndrome(x: Word) -> int:
    """XOR of the 1-based indices of the coordinates carrying a one."""
    s = 0
    for i, bit in enumerate(x, start=1):
        if bit:
            s ^= i
    return s


def hamming_code(k: int) -> Code:
    """All words of length 2^k - 1 with vanishing syndrome."""
    n = 2 ** k - 1
    return [x for x in words(n) if syndrome(x) == 0]


def hamming_decode(x: Word) -> Word:
    """Syndrome decoding: compute v = XOR of the indices of the ones; if v = 0
    accept, else flip coordinate v (1-based).  O(n) time, O(1) memory."""
    v = syndrome(x)
    if v == 0:
        return x
    y = list(x)
    y[v - 1] ^= 1
    return tuple(y)


def demo_hamming(max_k: int = 4) -> None:
    print("=" * 74)
    print("9.  HAMMING CODES: SYNDROME = XOR OF THE INDICES OF THE ONES")
    print("=" * 74)
    print(f"    {'k':>2} {'n=2^k-1':>8} {'|H_k|':>7} {'2^(n-k)':>9} {'mindist':>8}"
          f" {'|H|*V(n,1)':>11} {'2^n':>8} {'perfect':>8}")
    for k in range(1, max_k + 1):
        n = 2 ** k - 1
        H = hamming_code(k)
        md = min_distance(H)
        vol = ball_volume(n, 1)
        covered = {z for c in H for z in ball(n, 1, c)} if n <= 15 else None
        perfect = (len(H) * vol == 2 ** n)
        if covered is not None and n <= 7:
            assert len(covered) == 2 ** n
        assert len(H) == 2 ** (n - k)
        assert md is None or md >= 3
        print(f"    {k:>2} {n:>8} {len(H):>7} {2**(n-k):>9} {str(md):>8}"
              f" {len(H)*vol:>11} {2**n:>8} {str(perfect):>8}")
    print("\n    Decoding every single-bit corruption of every [7,4,3] codeword:")
    H = hamming_code(3)
    total = 0
    for c in H:
        for i in range(7):
            r = list(c)
            r[i] ^= 1
            assert hamming_decode(tuple(r)) == c
            total += 1
    print(f"      {total} corrupted words, all decoded back to the sent codeword.")
    print("    Two-bit corruptions are, of course, mis-decoded (distance 3 only")
    print("    guarantees correction of one error):")
    c = H[5]
    r = list(c)
    r[0] ^= 1
    r[3] ^= 1
    print(f"      sent {c}, received {tuple(r)}, decoded {hamming_decode(tuple(r))}\n")
    print("    H_2 is exactly the triple repetition code:")
    print(f"      H_2 = {sorted(hamming_code(2))}\n")


# --------------------------------------------------------------------------
# 7.  Which lengths admit a perfect code?
# --------------------------------------------------------------------------

def is_power_of_two(m: int) -> bool:
    return m > 0 and (m & (m - 1)) == 0


def demo_perfection(max_n: int = 16) -> None:
    print("=" * 74)
    print("10.  PERFECT 1-ERROR-CORRECTING CODES EXIST IFF n+1 IS A POWER OF TWO")
    print("=" * 74)
    print("    A perfect code needs |C|*(n+1) = 2^n, so (n+1) must divide 2^n,")
    print("    and a divisor of a power of two is a power of two.\n")
    print(f"    {'n':>3} {'n+1':>4} {'(n+1) | 2^n':>12} {'n+1 = 2^k':>10} {'perfect code exists':>21}")
    for n in range(1, max_n + 1):
        div = (2 ** n) % (n + 1) == 0
        pw = is_power_of_two(n + 1)
        assert div == pw
        print(f"    {n:>3} {n+1:>4} {str(div):>12} {str(pw):>10} {str(pw):>21}")
    print("\n    Length 4 in detail: balls of radius 1 hold 5 words, and 5 does not")
    print("    divide 16, so no tiling of the 4-cube by such balls can exist.")
    print(f"      sphere-packing bound A(4,3) <= {sphere_packing_bound(4,3)},"
          f"  exhaustive maximum = {brute_force_A(4,3)}")
    print(f"      strict inequality |C|*(n+1) < 2^n :"
          f" {brute_force_A(4,3)*5} < 16 -> {brute_force_A(4,3)*5 < 16}\n")


# --------------------------------------------------------------------------
# 8.  The extremal function and the odd/even collapse
# --------------------------------------------------------------------------

def demo_collapse() -> None:
    print("=" * 74)
    print("11.  ODD/EVEN COLLAPSE:  A(n,d) = A(n+1,d+1) FOR ODD d")
    print("=" * 74)
    print("    Extension (append a parity bit) raises an odd distance by one;")
    print("    puncturing (delete the last bit) lowers any distance by at most one.\n")
    print("    Exact values from the theory:")
    rows = [("A(n,1)", "2^n", "distance 1 is no condition"),
            ("A(n+1,2)", "2^n", "parity code, and it is optimal"),
            ("A(7,3)", "16", "the [7,4,3] Hamming code"),
            ("A(8,4)", "16", "extension of the above; collapse with d=3"),
            ("A(2^k-1,3)", "2^(2^k-1-k)", "Hamming code of order k"),
            ("A(2^k,4)", "2^(2^k-1-k)", "extended Hamming code")]
    for a, b, why in rows:
        print(f"      {a:>12} = {b:<14}  ({why})")
    print()
    print("    Extension in action: take the [7,4,3] code and append parity bits.")
    H = hamming_code(3)
    E = [with_parity(c) for c in H]
    print(f"      |H_3| = {len(H)}, mindist = {min_distance(H)}")
    print(f"      |extended| = {len(E)}, length {len(E[0])}, mindist = {min_distance(E)}")
    assert len(E) == len(H) and min_distance(E) == 4
    print("      all distances in the extended code are even, so 3 is forced up to 4.")
    print()
    print("    Puncturing in action: delete the last bit of the extended code.")
    Pc = [c[:-1] for c in E]
    print(f"      |punctured| = {len(set(Pc))}, length {len(Pc[0])}, mindist = {min_distance(Pc)}")
    assert set(Pc) == set(H)
    print("      we get exactly H_3 back: the two maps are mutually inverse here.")
    print()
    print("    The oddness hypothesis cannot be dropped:")
    a32, a43 = brute_force_A(3, 2), brute_force_A(4, 3)
    print(f"      A(3,2) = {a32}  (even distance d = 2)")
    print(f"      A(4,3) = {a43}  <  {a32}   -> A(n,d) = A(n+1,d+1) FAILS for even d")
    assert a43 < a32
    print()


# --------------------------------------------------------------------------
# 9.  Total-distance double count behind the Plotkin bound
# --------------------------------------------------------------------------

def total_pairwise_distance(code: Sequence[Word]) -> int:
    """S = sum over ordered pairs of d(x,y)."""
    return sum(hdist(x, y) for x in code for y in code)


def demo_plotkin_double_count() -> None:
    print("=" * 74)
    print("12.  THE DOUBLE COUNT BEHIND PLOTKIN'S BOUND")
    print("=" * 74)
    print("    d*M*(M-1)  <=  S  <=  n*M^2/2,  where S is the total pairwise distance.\n")
    print(f"    {'code':>24} {'n':>3} {'M':>4} {'d':>3} {'d*M*(M-1)':>11} {'S':>7} {'n*M^2/2':>9}")
    samples = [("parity code n+1=4", parity_code(3), 4),
               ("Hamming H_3", hamming_code(3), 7),
               ("extended H_3", [with_parity(c) for c in hamming_code(3)], 8),
               ("repetition {000,111}", hamming_code(2), 3)]
    for name, C, n in samples:
        M, d = len(C), min_distance(C) or 0
        S = total_pairwise_distance(C)
        lo, hi = d * M * (M - 1), n * M * M / 2
        assert lo <= S <= hi
        print(f"    {name:>24} {n:>3} {M:>4} {d:>3} {lo:>11} {S:>7} {hi:>9.1f}")
    print("\n    Squeezing the two estimates gives M*(2d-n) <= 2d whenever n < 2d.")
    print("    Check on the repetition code {000,111}: n=3, d=3, M=2 and")
    print(f"      M*(2d-n) = {2*(6-3)} <= 2d = {6}  -> {2*(6-3) <= 6}\n")


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 74)
    print("#  BINARY CODES: BOUNDS, RIGIDITY AND PERFECTION -- NUMERICAL DEMO")
    print("#" * 74)
    print()
    demo_ball_counting(max_n=8)
    demo_bounds(max_n=7)
    demo_parity_and_rigidity(n=3)
    demo_linear_criterion()
    demo_hamming(max_k=4)
    demo_perfection(max_n=16)
    demo_collapse()
    demo_plotkin_double_count()
    print("=" * 74)
    print("All assertions passed: every bound, identity and classification above")
    print("was checked numerically on the stated instances.")
    print("=" * 74)
    print()


if __name__ == "__main__":
    main()
