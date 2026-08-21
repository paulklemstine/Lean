"""Algorithm C: certified abc hits of arbitrary size, without factoring anything.

The almost-isosceles spine of the tree consists of the triples

        T_n = (2n+1, 2n(n+1), 2n^2+2n+1),      n >= 1,

reached by the word A^(n-1).  For an odd base d >= 3 and an exponent k with
d <= 2^k, set n = d^(2^k) - 1.  Then two radical collapses occur simultaneously:

  * n + 1 = d^(2^k) is a pure power, so rad(n+1) = rad(d) <= d;
  * 2^(k+2) divides n (lifting the exponent, from the factorisation
    n = (d-1)(d+1)(d^2+1)...(d^(2^(k-1))+1)), so rad(n) <= n / 2^(k+1).

Hence, with a = 2n+1 and c = 2n^2+2n+1,

        rad(abc) <= a * 2 * floor(n / 2^(k+1)) * d * c  =:  B(d, k),

which gives the certified lower bound q >= 2 log c / log B(d, k) > 1 whenever
d <= 2^k.  Only big-integer arithmetic and two logarithms of big integers are
required, so hypotenuses with hundreds of digits are handled instantly, while
factoring them is hopeless.  Consecutive members satisfy c_{k+1} < c_k^2 <
4 c_{k+1}: the family is doubly exponentially sparse.
"""

from __future__ import annotations

import math
from typing import List, NamedTuple, Tuple


class CertifiedHit(NamedTuple):
    base: int
    exponent: int
    spine_parameter: int
    hypotenuse: int
    radical_upper_bound: int
    quality_lower_bound: float


def spine_triple(n: int) -> Tuple[int, int, int]:
    return (2 * n + 1, 2 * n * (n + 1), 2 * n * n + 2 * n + 1)


def certify_hit(d: int, k: int) -> CertifiedHit:
    """Certify that the spine node with n = d^(2^k) - 1 has quality > 1."""
    if d < 3 or d % 2 == 0:
        raise ValueError("d must be an odd integer >= 3")
    if d > 2 ** k:
        raise ValueError("the balance condition d <= 2^k fails")
    n = d ** (2 ** k) - 1
    a, _, c = spine_triple(n)
    bound = a * 2 * (n // 2 ** (k + 1)) * d * c
    q_lower = 2.0 * math.log(c) / math.log(bound)
    return CertifiedHit(d, k, n, c, bound, q_lower)


def sparsity_check(d: int, k: int) -> Tuple[bool, bool]:
    """Verify c_{k+1} < c_k^2 and c_k^2 < 4 c_{k+1} for the base-d family."""
    c_k = spine_triple(d ** (2 ** k) - 1)[2]
    c_next = spine_triple(d ** (2 ** (k + 1)) - 1)[2]
    return c_next < c_k * c_k, c_k * c_k < 4 * c_next


if __name__ == "__main__":
    results: List[CertifiedHit] = []
    for d in (3, 5, 7, 9):
        for k in range(2, 8):
            if d <= 2 ** k:
                results.append(certify_hit(d, k))
    for r in results:
        digits = len(str(r.hypotenuse))
        print(f"d = {r.base}, k = {r.exponent}: c has {digits:>4} digits, "
              f"certified q >= {r.quality_lower_bound:.6f}  "
              f"{'HIT' if r.quality_lower_bound > 1 else '--'}")
    print("\nsparsity (base 3):", [sparsity_check(3, k) for k in range(2, 6)])


"""Algorithm B: breadth-first scan of the Berggren tree and its quality spectrum.

The primitive Pythagorean triples are the nodes of a ternary tree rooted at
(3,4,5) whose edges are the three Berggren matrices.  Each matrix strictly
increases the hypotenuse (indeed by a factor at most 3 + 2 sqrt 2, the squared
silver ratio), so a breadth-first traversal pruned at a hypotenuse cutoff X
terminates and enumerates every primitive triple with hypotenuse <= X exactly
once.

Cost: one radical computation per node; empirically about 0.16 X nodes have
hypotenuse below X, so the scan is O(X sqrt(X)) with trial division and
O(X log X) with a sieve-based smallest-prime-factor table.
"""

from __future__ import annotations

import math
from collections import deque
from typing import Dict, Iterator, List, Tuple

Triple = Tuple[int, int, int]

BERGGREN: Dict[str, Tuple[Tuple[int, int, int], ...]] = {
    "A": ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    "B": ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    "C": ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}


def smallest_prime_factor_table(limit: int) -> List[int]:
    """Sieve of smallest prime factors up to limit (inclusive)."""
    spf = list(range(limit + 1))
    i = 2
    while i * i <= limit:
        if spf[i] == i:
            for j in range(i * i, limit + 1, i):
                if spf[j] == j:
                    spf[j] = i
        i += 1
    return spf


def radical_with_table(n: int, spf: List[int]) -> int:
    """rad(n) using a smallest-prime-factor table."""
    result, m = 1, n
    while m > 1:
        p = spf[m]
        result *= p
        while m % p == 0:
            m //= p
    return result


def apply_step(step: str, t: Triple) -> Triple:
    m = BERGGREN[step]
    return tuple(sum(m[i][j] * t[j] for j in range(3)) for i in range(3))  # type: ignore[return-value]


def scan(limit: int) -> Iterator[Tuple[Triple, str, float]]:
    """Yield (triple, word, quality) for every node with hypotenuse <= limit."""
    spf = smallest_prime_factor_table(limit)
    queue: deque[Tuple[Triple, str]] = deque([((3, 4, 5), "")])
    while queue:
        t, word = queue.popleft()
        a, b, c = t
        # a primitive Pythagorean triple has pairwise coprime entries
        rad = radical_with_table(a, spf) * radical_with_table(b, spf) * radical_with_table(c, spf)
        yield t, word, 2.0 * math.log(c) / math.log(rad)
        for step in "ABC":
            u = apply_step(step, t)
            if u[2] <= limit:
                queue.append((u, word + step))


if __name__ == "__main__":
    LIMIT = 200_000
    data = sorted(scan(LIMIT), key=lambda r: -r[2])
    hits = [r for r in data if r[2] > 1.0]
    print(f"nodes with c <= {LIMIT}: {len(data)}")
    print(f"abc hits (q > 1):       {len(hits)}  ({100 * len(hits) / len(data):.2f}%)")
    print(f"quality range: {data[-1][2]:.6f} .. {data[0][2]:.6f}")
    for t, word, q in data[:5]:
        print(f"  q = {q:.6f}  {t}  depth {len(word)}  word {word}")


"""Algorithm A: exact rational threshold test for the abc quality of a Pythagorean triple.

Decides q(a,b,c) > m/k, where q = 2 log c / log rad(abc), using only exact
integer arithmetic: by the threshold dictionary,

        q > m/k   <=>   rad(abc)^m < c^(2k),
        q < m/k   <=>   c^(2k)     < rad(abc)^m.

No logarithm is ever evaluated, so the verdict is certified rather than
numerical.  A primitive Pythagorean triple has pairwise coprime entries, so
rad(abc) = rad(a) rad(b) rad(c) and only three small factorisations are needed.
"""

from __future__ import annotations

from math import gcd
from typing import Literal, Tuple


def radical(n: int) -> int:
    """Product of the distinct primes dividing n; O(sqrt(n)) trial division."""
    if n <= 0:
        raise ValueError("radical needs a positive integer")
    result, m, p = 1, n, 2
    while p * p <= m:
        if m % p == 0:
            result *= p
            while m % p == 0:
                m //= p
        p += 1 if p == 2 else 2
    if m > 1:
        result *= m
    return result


def triple_radical(a: int, b: int, c: int) -> int:
    """rad(abc) for a primitive Pythagorean triple, via pairwise coprimality."""
    if a * a + b * b != c * c:
        raise ValueError("not a Pythagorean triple")
    if gcd(a, b) != 1:
        raise ValueError("triple is not primitive")
    return radical(a) * radical(b) * radical(c)


def compare_quality(a: int, b: int, c: int, m: int, k: int) -> Literal["<", "=", ">"]:
    """Exactly compare q(a,b,c) with the rational m/k."""
    if m <= 0 or k <= 0:
        raise ValueError("m and k must be positive")
    lhs = triple_radical(a, b, c) ** m      # rad(abc)^m
    rhs = c ** (2 * k)                      # c^(2k)
    if lhs < rhs:
        return ">"
    if lhs > rhs:
        return "<"
    return "="


def is_abc_hit(a: int, b: int, c: int) -> bool:
    """True exactly when q(a,b,c) > 1, i.e. rad(abc) < c^2."""
    return triple_radical(a, b, c) < c * c


def quality_bracket(a: int, b: int, c: int, denominator: int = 1000) -> Tuple[int, int]:
    """Bracket q(a,b,c) between consecutive multiples of 1/denominator, exactly.

    Returns (m, m+1) with m/denominator < q < (m+1)/denominator (binary search
    on m, each step a single big-integer comparison).
    """
    lo, hi = 0, 2 * denominator  # q < 2 for every triple encountered in practice
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if compare_quality(a, b, c, mid, denominator) == ">":
            lo = mid
        else:
            hi = mid
    return lo, hi


if __name__ == "__main__":
    record = (36207, 18424, 40625)
    print("rad(abc) =", triple_radical(*record))
    print("q > 5/4 ?", compare_quality(*record, 5, 4))
    print("q < 4/3 ?", compare_quality(*record, 4, 3))
    lo, hi = quality_bracket(*record)
    print(f"certified bracket: {lo}/1000 < q < {hi}/1000")


"""Assemble PACKAGE.json from the deliverable files in the project."""

from __future__ import annotations

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"
sys.path.insert(0, str(A))

from content import FUTURE_DIRECTIONS, INTERACTIVE_LAYOUT  # noqa: E402


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


lean_files = ["Catalog/Logic/BerggrenAbcQuality.lean", "Catalog/Logic/BerggrenAbcSpectrum.lean"]
lean_proofs = "\n\n".join(
    f"-- ===== {f} =====\n\n{read(ROOT / f)}" for f in lean_files
)

future_directions = FUTURE_DIRECTIONS
interactive_layout = INTERACTIVE_LAYOUT

package = {
    "title": "The Exact Quality Spectrum of a\u00b2+b\u00b2=c\u00b2: the Berggren Tree as a Solvable Model of the abc Conjecture",
    "domain": "Logic",
    "description": (
        "Every primitive Pythagorean triple is an abc triple, and the ternary tree of such triples "
        "has a completely explicit abc quality theory: the radical collapse rad(a\u00b2b\u00b2c\u00b2) = rad(abc) "
        "turns every quality threshold into an exact integer inequality, yielding an unconditional floor "
        "q > 2/3, a silver-ratio depth law, an explicit infinite family of abc hits, and a precise "
        "identification of the one remaining obstruction as abc-strength."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-21",
    "key_results": [
        "Radical collapse: for any Pythagorean triple, rad(a\u00b2b\u00b2c\u00b2) = rad(abc), so the abc quality of the node is q = 2 log c / log rad(abc)",
        "Threshold dictionary: q > m/k holds exactly when rad(abc)^m < c^(2k); in particular q > 1 exactly when rad(abc) < c\u00b2 and q < 2 exactly when rad(abc) > c",
        "Unconditional lower edge: every node of the tree has q \u2265 2 log c / (3 log c \u2212 log 2) > 2/3, so the floor 2/3 is approached no faster than 1/log c",
        "Universal silver-ratio depth law: every step multiplies the hypotenuse by at most (1 + \u221a2)\u00b2 = 3 + 2\u221a2, so a node at depth n has c \u2264 5(3 + 2\u221a2)\u207f and the depth-n quality window is 2/3 < q \u2264 2(log 5 + n log(3 + 2\u221a2)) / log rad(abc)",
        "Infinitely many abc hits: for odd d \u2265 3 with d \u2264 2\u1d4f, the almost-isosceles node with parameter n = d^(2\u1d4f) \u2212 1 has quality above 1, and this family is doubly exponentially sparse (only O(log log X) members below X)",
        "Conditional sharp bound: an effective abc inequality C\u00b9\u00b2 \u2264 K\u00b7rad(ABC)\u00b9\u00b3 forces q \u2264 13/10 for every node with K \u2264 c\u2074, and the full conjecture forces q \u2264 1 + 2\u03b5 beyond a threshold; the best node found, (36207, 18424, 40625), satisfies 5/4 < q < 4/3",
    ],
    "keywords": [
        "abc conjecture", "quality", "radical", "Pythagorean triples", "Berggren tree",
        "silver ratio", "lifting the exponent", "Pell numbers",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Verification of the Quality Spectrum of the Pythagorean abc Family",
            "description": (
                "A seven-part self-contained computation that reproduces every quantitative claim of the "
                "theory. It verifies the radical collapse rad(a\u00b2b\u00b2c\u00b2) = rad(abc) on sample nodes; "
                "evaluates the explicit spectrum points (3,4,5), (5,12,13), (7,24,25), (105,88,137) and the "
                "record node (36207, 18424, 40625); checks the two exact criteria q > 1 \u21d4 rad(abc) < c\u00b2 and "
                "q < 2 \u21d4 rad(abc) > c on every tree node with hypotenuse up to 200000; confirms the proved "
                "lower edge 2 log c/(3 log c \u2212 log 2) and its transparent form 2/3 + 2 log 2/(9 log c); tests "
                "the universal silver-ratio bound c \u2264 5(3 + 2\u221a2)\u207f at every node and displays the Pell "
                "branch that attains it; lists the abc hits on the almost-isosceles spine together with "
                "factorisation-free certified quality lower bounds for the family n = d^(2\u1d4f) \u2212 1 up to "
                "109-digit hypotenuses; and finally scans the tree, reporting the hit density and a histogram "
                "of the whole quality distribution."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Quality Under Berggren Descent: the Non-Monotonicity of abc Hits Along a Branch",
            "description": (
                "Takes deep nodes of the tree, reconstructs them from their generating words, and then peels "
                "the words off one letter at a time using the inverse Berggren matrices, printing the triple, "
                "its radical and its quality at every step of the descent to (3,4,5). The output exhibits the "
                "proved non-monotonicity: (5,12,13) has q \u2248 0.8598, its child (7,24,25) has q \u2248 1.2040 (a hit), "
                "and that child's child (105,88,137) falls back to q \u2248 0.7769. Along the eight-step descent "
                "from the record node the quality crosses the hit threshold three times, so hits are created "
                "and destroyed along a branch rather than accumulated \u2014 there is no uphill route."
            ),
            "code": read(A / "demo_descent.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Exact Rational Threshold Test for the abc Quality via the Radical Dictionary",
            "description": (
                "Decides, with certified integer arithmetic and no floating point whatsoever, whether the "
                "quality q = 2 log c / log rad(abc) of a Pythagorean node exceeds a given rational m/k. The "
                "mathematical foundation is the threshold dictionary: since log rad(abc) > 0, the inequality "
                "q > m/k is equivalent to rad(abc)^m < c^(2k). Because a primitive Pythagorean triple has "
                "pairwise coprime entries, rad(abc) = rad(a)rad(b)rad(c) and only three small factorisations "
                "are needed instead of one factorisation of the large product abc. Complexity: O(\u221ac) trial "
                "division per entry (or O(log c) with a precomputed smallest-prime-factor sieve), plus "
                "O(log(mk)) big-integer multiplications for the comparison. A binary search over m with fixed "
                "k = 1000 brackets the quality between consecutive thousandths using O(log k) comparisons, "
                "which is how the certified bracket 1.265 < q(36207, 18424, 40625) < 1.266 is obtained."
            ),
            "pseudocode": (
                "function RADICAL(n):\n"
                "    r <- 1; m <- n; p <- 2\n"
                "    while p*p <= m:\n"
                "        if p divides m:\n"
                "            r <- r * p\n"
                "            while p divides m: m <- m / p\n"
                "        p <- next candidate (3, 5, 7, ...)\n"
                "    if m > 1: r <- r * m\n"
                "    return r\n"
                "\n"
                "function TRIPLE_RADICAL(a, b, c):\n"
                "    assert a^2 + b^2 = c^2 and gcd(a, b) = 1\n"
                "    // primitivity implies a, b, c are pairwise coprime\n"
                "    return RADICAL(a) * RADICAL(b) * RADICAL(c)\n"
                "\n"
                "function COMPARE_QUALITY(a, b, c, m, k):\n"
                "    L <- TRIPLE_RADICAL(a, b, c)^m\n"
                "    R <- c^(2k)\n"
                "    if L < R: return \">\"      // q > m/k\n"
                "    if L > R: return \"<\"      // q < m/k\n"
                "    return \"=\"\n"
                "\n"
                "function QUALITY_BRACKET(a, b, c, D):\n"
                "    lo <- 0; hi <- 2D          // q < 2 in every observed case\n"
                "    while hi - lo > 1:\n"
                "        mid <- floor((lo + hi)/2)\n"
                "        if COMPARE_QUALITY(a, b, c, mid, D) = \">\": lo <- mid\n"
                "        else: hi <- mid\n"
                "    return (lo, hi)            // lo/D < q < hi/D, certified"
            ),
            "code": read(A / "algo_threshold.py"),
        },
        {
            "name": "Breadth-First Enumeration of the Berggren Tree and its Quality Spectrum",
            "description": (
                "Enumerates every primitive Pythagorean triple with hypotenuse below a cutoff X exactly once "
                "and computes its abc quality. The tree is rooted at (3,4,5) and its edges are the three "
                "Berggren matrices; each matrix strictly increases the hypotenuse (by a factor at most the "
                "squared silver ratio 3 + 2\u221a2), so pruning the breadth-first search at the cutoff is both "
                "correct and terminating, and no triple is generated twice because each triple corresponds to "
                "a unique word in {A, B, C}. Radicals are obtained from a smallest-prime-factor sieve of size "
                "X, so the whole scan costs O(X log log X) for the sieve plus O(log c) per node; empirically "
                "there are about 0.16X nodes with hypotenuse below X, giving 159139 nodes for X = 10\u2076. This "
                "is the procedure behind the observed spectrum [0.692, 1.2659], the hit density of roughly "
                "0.4%, and the identification of the record node (36207, 18424, 40625) at depth 8."
            ),
            "pseudocode": (
                "input: cutoff X\n"
                "SPF <- sieve of smallest prime factors up to X\n"
                "Q <- queue containing ((3,4,5), empty word)\n"
                "while Q is nonempty:\n"
                "    ((a,b,c), w) <- pop front of Q\n"
                "    R <- RAD(a, SPF) * RAD(b, SPF) * RAD(c, SPF)   // entries pairwise coprime\n"
                "    output (a, b, c), w, quality 2*log(c)/log(R)\n"
                "    for M in {M_A, M_B, M_C}:\n"
                "        (a', b', c') <- M * (a, b, c)\n"
                "        if c' <= X: push ((a',b',c'), w + label(M)) onto Q\n"
                "\n"
                "// correctness: every Berggren step strictly increases c, and each\n"
                "// primitive triple is the image of exactly one word in {A,B,C}*"
            ),
            "code": read(A / "algo_scan.py"),
        },
        {
            "name": "Factorisation-Free Certification of abc Hits of Arbitrary Size",
            "description": (
                "Produces abc hits with hypotenuses of hundreds of digits and certifies q > 1 for each, "
                "without factoring any large integer. The construction lives on the almost-isosceles spine "
                "T_n = (2n+1, 2n(n+1), 2n\u00b2+2n+1) of the tree. For an odd base d \u2265 3 and exponent k with "
                "d \u2264 2\u1d4f one takes n = d^(2\u1d4f) \u2212 1, which triggers two simultaneous radical collapses: "
                "n + 1 is a pure power of d, so rad(n+1) = rad(d) \u2264 d; and the factorisation "
                "n = (d\u22121)(d+1)(d\u00b2+1)\u00b7\u00b7\u00b7(d^(2^(k\u22121))+1) shows 2^(k+2) divides n, whence "
                "rad(n) \u2264 n/2^(k+1). Submultiplicativity of the radical then gives the explicit bound "
                "rad(abc) \u2264 B(d,k) = (2n+1)\u00b72\u00b7\u230an/2^(k+1)\u230b\u00b7d\u00b7c, and the certified quality lower bound "
                "q \u2265 2 log c / log B(d,k), which exceeds 1 exactly under the balance condition d \u2264 2\u1d4f. "
                "Complexity is dominated by computing d^(2\u1d4f) by repeated squaring: O(k) big-integer "
                "multiplications on numbers of O(2\u1d4f log d) bits. The same routine verifies the sparsity "
                "relations c_{k+1} < c_k\u00b2 < 4c_{k+1}, which show that the family contributes only "
                "O(log log X) hits below X."
            ),
            "pseudocode": (
                "input: odd base d >= 3, exponent k with d <= 2^k\n"
                "n <- d^(2^k) - 1                       // repeated squaring\n"
                "a <- 2n + 1;  c <- 2n^2 + 2n + 1\n"
                "// collapse 1: n + 1 = d^(2^k) is a pure power  =>  rad(n+1) <= d\n"
                "// collapse 2: 2^(k+2) | n                      =>  rad(n) <= n / 2^(k+1)\n"
                "B <- a * 2 * floor(n / 2^(k+1)) * d * c          // upper bound for rad(abc)\n"
                "qlow <- 2*log(c) / log(B)\n"
                "assert qlow > 1                                  // guaranteed when d <= 2^k\n"
                "return certificate (d, k, n, c, B, qlow)\n"
                "\n"
                "// sparsity: with c_k the hypotenuse for exponent k,\n"
                "//   c_{k+1} < c_k^2 < 4 c_{k+1}, so #{members below X} = O(log log X)"
            ),
            "code": read(A / "algo_certified_hits.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Quality Spectrum: Scatter Against Hypotenuse and Histogram of the Distribution",
            "description": (
                "Two panels computed from every node of the tree with hypotenuse below 200000. The left panel "
                "plots the quality q = 2 log c / log rad(abc) against log c, colouring points by depth, and "
                "overlays the proved lower edge 2 log c/(3 log c \u2212 log 2), the asymptotic floor q = 2/3, and "
                "the hit threshold q = 1; the cloud visibly hugs the proved edge from above and thins out "
                "rapidly above 1. The right panel is the histogram of the same qualities on a logarithmic "
                "count scale, showing the unimodal bulk peaked near q \u2248 0.73 and the thin tail of abc hits."
            ),
            "code": read(A / "viz_spectrum.py"),
        },
        {
            "name": "The Silver-Ratio Depth Law: Hypotenuse Growth Along Every Branch",
            "description": (
                "Plots log c against depth for every node with hypotenuse below 400000, together with the "
                "universal ceiling log 5 + n log(3 + 2\u221a2) coming from the fact that a single Berggren step "
                "multiplies the hypotenuse by at most the squared silver ratio, the Pell lower bound 5^(n+1), "
                "and the all-B (Pell) branch that attains the ceiling. An inset shows the ratio "
                "c_n/(5(3 + 2\u221a2)\u207f) along that branch converging to about 0.995, confirming that 3 + 2\u221a2 is "
                "the exact growth constant of the tree and that the numerator of the quality is pinned by "
                "depth alone."
            ),
            "code": read(A / "viz_silver_growth.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "Walking the Berggren Tree: an Interactive abc Quality Explorer",
            "description": (
                "A single-page laboratory for the whole theory. Start at (3,4,5) and descend with the three "
                "Berggren matrices (or ascend to the parent with their inverses), and watch the node's data "
                "update live: the prime factorisations of a, b and c, the product abc, the radical "
                "rad(abc) = rad(a\u00b2b\u00b2c\u00b2), the exact hit test rad(abc) < c\u00b2, the depth ceiling "
                "5(3 + 2\u221a2)\u207f, and the quality itself on a bar scaled between the proved floor 2/3 and the "
                "abstract ceiling 2, with the abc record 1.63 marked. The right-hand panel plots the whole "
                "spectrum of the tree \u2014 every node with hypotenuse below 60000 \u2014 against log c, with hits "
                "highlighted, the proved lower edge drawn as a curve, and your own walk traced in red on top, "
                "so the non-monotonicity of quality under descent is immediately visible. One-click jumps go "
                "to the first hit (7,24,25), to the record node (36207, 18424, 40625) at word CCCACCBC, and "
                "twenty steps down the almost-isosceles spine."
            ),
            "html": read(A / "widget.html"),
        }
    ],
    "interactive_layout": interactive_layout,
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {"demo": read(ROOT / "demo.py")},
    "lean_files": lean_files,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""Long-form text blocks embedded into PACKAGE.json (future directions and the
interactive notebook narrative)."""

FUTURE_DIRECTIONS: str = r'''# Future directions: the Berggren tree as a solvable model of `abc`

## What this cycle established

The Berggren ternary tree of primitive Pythagorean triples is a fully explicit family of `abc`
triples: for a node `a² + b² = c²` we have `rad(a²b²c²) = rad(abc)` and
`q = log(c²)/log(rad abc)`. The results proved are:

1. **Structure.** Every node is a positive primitive Pythagorean triple with legs `≥ 3`.
2. **Exact thresholds.** `q > 1 ↔ rad(abc) < c²`, `q < 2 ↔ rad(abc) > c`, and rational
   thresholds `m/k` are equivalent to `rad^m` vs `c^{2k}` comparisons.
3. **Lower edge (unconditional).** `q > 2/3` for every node, because `2ab ≤ c²` forces
   `rad(abc) ≤ abc ≤ c³/2`.
4. **Upper edge.** `q < 2` for every node whose `abc`-product satisfies `abc ≤ rad(abc)²`;
   the residual gap is only `Θ(1/log c)`, so *no uniform* `2 − ε` follows from this mechanism —
   a uniform gap is genuinely `abc`-strength. Under an effective `abc` bound with constant `K`
   one gets `q ≤ 13/10` for all nodes with `K ≤ c⁴`, and under the Masser–Oesterlé conjecture
   one gets `q ≤ 1 + 2ε` for all `c` beyond an (ineffective) threshold.
5. **Hits exist, infinitely often, for every odd base.** For odd `d ≥ 3` and `d ≤ 2^k`, the
   `A`-spine node with parameter `n = d^{2^k} − 1` has `q > 1`; these hits are doubly
   exponentially sparse (`c(k+1) ≈ c(k)²`).
6. **Explicit spectrum data.** `q(3,4,5) < 1 < q(7,24,25)`, `q(105,88,137) < 1` (quality is not
   monotone under descent), and `5/4 < q(36207,18424,40625) < 4/3` — the best node found by an
   exhaustive scan stays far below the `abc` record `≈ 1.63`.
7. **Silver-ratio growth.** Along the Pell branch, `5^{n+1} ≤ c_n ≤ 5·(3+2√2)^n`, and the
   depth-`n` quality obeys the exact identity `q_n · log rad = 2 log c_n`.
8. **Universal depth law.** The silver ratio governs the *whole* tree, not just the Pell branch:
   every Berggren step multiplies the hypotenuse by at most `3 + 2√2` (from `a + b ≤ √2 c`), so
   every node at depth `n` satisfies `c ≤ 5(3+2√2)^n` and the depth-`n` quality window is
   `2/3 < q ≤ 2(log 5 + n log(3+2√2))/log rad(abc)`. The entire depth dependence of the spectrum
   is therefore carried by the radical alone.
9. **Rate at the lower edge.** The bound in 3 is quantitative: `q ≥ 2 log c/(3 log c − log 2)`,
   hence `q ≥ 2/3 + 2 log 2/(9 log c)`. So `2/3` can only be approached along nodes with
   `c → ∞`, and never faster than `1/log c`.

The moonshot ("the supremum is attained and the distribution law at depth `n` is exact") is
**not** established, and the analysis says why: the supremum question for this family is
equivalent to an `abc`-strength statement, while the distribution law is controlled by the
radicals of `n(n+1)` along the spine, which are as hard as the general `abc` heuristics.

## Directions

### 1. Sharp lower edge
Is the constant `2 log 2 / 9` in `q ≥ 2/3 + 2 log 2/(9 log c)` optimal? Equivalently: how often
is `abc` squarefree along the tree, and how close to `c³/2` can `rad(abc)` come? A sharp answer
requires unconditional lower bounds for the density of nodes with `abc` squarefree — a
squarefree-values problem for a quaternary form.

### 2. The high-quality region
Characterize the set of words in `{A,B,C}*` whose nodes are hits. The data show hits at depths
`6, 8, 22, 118, …` with no evident pattern, and the non-monotonicity result rules out
branch-monotone descriptions. Is the language of hit-words non-regular? Non-context-free?

### 3. Denser provable hit families
The `n = d^{2^k} − 1` family produces only `O(log log X)` hits below `X`. Can a Pythagorean
family with `≫ X^δ` hits below `X` be produced — for example by exploiting simultaneous
power-richness of `n`, `n+1` and `2n² + 2n + 1` along a two-parameter subfamily of the tree?

### 4. Other spines
The `A`-spine (almost-isosceles) and `B`-spine (Pell) are analysed here. The `C`-spine and mixed
periodic words `w^∞` give further one-parameter families with linear-recurrence hypotenuses,
each with its own quality law of the shape `q_n log rad = 2 log c_n`. A uniform treatment of all
eventually periodic words would define the "quality of a branch" as a function on the boundary
of the tree.

### 5. Distribution at depth `n`
Conditional on standard heuristics for the radicals of polynomial values, predict the limiting
distribution of `q` over the `3^n` nodes at depth `n` — numerics show a stable unimodal shape
peaked near `0.73` — and test the prediction against deep scans.

### 6. Beyond squares
The collapse `rad(a^r b^s c^t) = rad(abc)` holds for arbitrary exponents. Applying the
dictionary to Fermat–Catalan-type equations `x^p + y^q = z^r` with `1/p + 1/q + 1/r < 1` would
extend the model, at the cost of losing the tree structure.

### 7. Effective constants
The conditional ceiling `13/10` uses the shape `C¹² ≤ K·rad(ABC)¹³`; other effective shapes give
other explicit ceilings. Determining the best ceiling obtainable from currently known effective
results — which are far weaker than the conjecture — would give the first unconditional
numerical upper bound for the supremum of the quality over the tree, if any is achievable.
'''

INTERACTIVE_LAYOUT: str = r'''# The Oldest Equation Meets the Hardest Conjecture

### A guided tour of the quality spectrum of $a^2+b^2=c^2$

Addition and multiplication do not get along. Multiplication has perfect structure — unique
factorization into primes. Addition destroys it: add two numbers with beautiful factorizations
and the sum can be a stubborn prime. Almost every hard problem in number theory is a symptom of
this tension, and the **$abc$ conjecture** is its sharpest formulation.

This page builds, from scratch, an *exactly solvable model* of that conjecture — built out of the
oldest equation in mathematics.

---

## 1. Measuring the clash: radicals and quality

For a positive integer $n$, the **radical** $\operatorname{rad}(n)$ is the product of the distinct
primes dividing $n$. It throws away all repetition:

$$\operatorname{rad}(12)=\operatorname{rad}(2^2\cdot3)=6,\qquad
\operatorname{rad}(1000)=\operatorname{rad}(2^35^3)=10,\qquad
\operatorname{rad}(30)=30 .$$

A radical is small exactly when the number is *rich in repeated prime factors*.

Now take three coprime positive integers with $A+B=C$. The **quality** of the triple is

$$q(A,B,C)=\frac{\log C}{\log\operatorname{rad}(ABC)} .$$

Quality above $1$ means the sum has outrun the radical — the triple is an **$abc$ hit**. The
conjecture of Masser and Oesterlé says that for every $\varepsilon>0$ only finitely many triples
have $q>1+\varepsilon$.

<details>
<summary><b>Why "quality" is the right scale — click to expand</b></summary>

If $q(A,B,C)=Q$ then $C=\operatorname{rad}(ABC)^{Q}$ by definition. So $Q$ measures, on a
logarithmic scale, how much bigger the sum is than the "square-free content" of the whole triple.
Hits are rare but real: $1+8=9$ has $\operatorname{rad}(72)=6$, hence $q=\log 9/\log 6\approx1.226$.
The reigning record is Reyssat's $2+3^{10}\cdot109=23^5$, with $q\approx1.6299$. No triple with
$q\ge2$ has ever been found, and remarkably, even the ceiling $q<2$ is **not** a theorem.
Read more about the conjecture at the
[ABC@Home project's overview](https://en.wikipedia.org/wiki/Abc_conjecture).
</details>

The problem with the general conjecture is that its parameter space is formless. There is no
natural infinite family of $abc$ triples whose qualities we can actually *describe*. Unless…

---

## 2. Every right triangle is an $abc$ triple

Take a primitive Pythagorean triple, $a^2+b^2=c^2$ with $\gcd(a,b)=1$. Read it as

$$\underbrace{a^2}_{A}+\underbrace{b^2}_{B}=\underbrace{c^2}_{C} .$$

That is an $abc$ triple. Its quality is $q=\log(c^2)/\log\operatorname{rad}(a^2b^2c^2)$.

And here the first miracle happens. **Radicals ignore exponents**: $\operatorname{rad}(n^2)=\operatorname{rad}(n)$,
because squaring changes no prime's presence, only its multiplicity. Therefore

$$\operatorname{rad}(a^2b^2c^2)=\operatorname{rad}(abc)
\qquad\Longrightarrow\qquad
\boxed{\,q(a,b,c)=\frac{2\log c}{\log\operatorname{rad}(abc)}\,}$$

The three squares — the hard part of any $abc$ instance — simply evaporate.

<details>
<summary><b>The consequence: every threshold becomes an integer inequality</b></summary>

Since $\log\operatorname{rad}(abc)>0$, we may clear denominators in $q>m/k$ and exponentiate:

$$q>\frac mk \iff \operatorname{rad}(abc)^{m}<c^{2k},
\qquad
q<\frac mk \iff c^{2k}<\operatorname{rad}(abc)^{m}.$$

In particular:

* **$q>1$ exactly when $\operatorname{rad}(abc)<c^2$** (the node is a hit);
* **$q<2$ exactly when $\operatorname{rad}(abc)>c$**.

No analysis remains. Every question about the spectrum is a comparison of two explicit integers —
which is exactly why every number below can be *certified*, not merely estimated.
</details>

---

## 3. The tree of all right triangles

Primitive Pythagorean triples are not a scattered set: they form a perfect ternary tree. The root
is $(3,4,5)$, and the three children of a node $(a,b,c)$ are obtained by the matrices

$$
M_A=\begin{pmatrix}1&-2&2\\2&-1&2\\2&-2&3\end{pmatrix},\quad
M_B=\begin{pmatrix}1&2&2\\2&1&2\\2&2&3\end{pmatrix},\quad
M_C=\begin{pmatrix}-1&2&2\\-2&1&2\\-2&2&3\end{pmatrix}.
$$

Every primitive triple appears **exactly once**, at the end of exactly one finite word in
$\{A,B,C\}$; inverting the matrices marches any triple back to $(3,4,5)$.

So: walk it yourself. Descend with $A$, $B$, $C$; climb back with the parent button; watch the
factorizations, the radical, the exact hit test $\operatorname{rad}(abc)<c^2$, and the quality
move in real time against the backdrop of the whole spectrum.

{{interactive_demo:0}}

**Three things to try.**
1. Press $A$ twice from the root: $(3,4,5)\to(5,12,13)\to(7,24,25)$. The quality goes
   $0.9464 \to 0.8598 \to 1.2040$ — the third node is a hit, because $24=2^3\cdot3$ and $25=5^2$
   make $\operatorname{rad}(abc)=210$ tiny against $c^2=625$.
2. Then press $B$: you land on $(105,88,137)$ and the quality *collapses* to $0.7769$. Quality is
   **not monotone** along the tree.
3. Jump to the record node $(36207,18424,40625)$ — eight steps from the root, quality $1.2659$,
   the best in an exhaustive scan of all $159{,}139$ nodes with hypotenuse below $10^6$.

---

## 4. The floor: no node is ever dull

How bad can a Pythagorean triple be as $abc$ material? Not very — and this is a *theorem*, not a
statistic.

> **Theorem (lower edge).** Every Pythagorean triple with legs at least $3$ satisfies
> $$q(a,b,c)\ \ge\ \frac{2\log c}{3\log c-\log 2}\ >\ \frac23,
> \qquad\text{equivalently}\qquad q\ \ge\ \frac23+\frac{2\log 2}{9\log c}.$$

<details>
<summary><b>Proof in three lines — click to reveal</b></summary>

From $(a-b)^2\ge0$ and $a^2+b^2=c^2$ we get $2ab\le c^2$, hence $abc\le c^3/2$. The radical never
exceeds its argument, so $\operatorname{rad}(abc)\le c^3/2$ and therefore
$\log\operatorname{rad}(abc)\le 3\log c-\log 2$. Dividing the fixed positive numerator $2\log c$ by a
*smaller* denominator only increases the ratio:
$$q=\frac{2\log c}{\log\operatorname{rad}(abc)}\ \ge\ \frac{2\log c}{3\log c-\log 2}\ >\ \frac{2\log c}{3\log c}=\frac23 .$$
The refined form follows from the identity
$\frac{2L}{3L-\log2}-\frac23-\frac{2\log2}{9L}=\frac{2(\log2)^2}{9L(3L-\log2)}>0$ with $L=\log c$. $\blacksquare$
</details>

The number $2/3$ has a meaning: it is the quality of a triple whose product $abc$ is completely
**squarefree**, so that $\operatorname{rad}(abc)=abc\approx c^3$. The floor of the tree's spectrum is
exactly the squarefree regime, where the $abc$ mechanism has nothing to exploit. And the theorem
says the floor can only be approached along nodes with $c\to\infty$, at the glacial rate $1/\log c$.

Here is the full spectrum, with that proved edge drawn through it:

{{visualization:0}}

Notice how the cloud presses down against the green curve but never crosses it, and how the hits
above $q=1$ form a thin scatter — under half a percent of all nodes.

---

## 5. The silver ratio runs the whole tree

The second structural miracle is about *growth*. Every Pythagorean triple satisfies
$a+b\le\sqrt2\,c$, and each Berggren matrix produces a hypotenuse of the form $c'=3c\pm2(a\mp b)$.
Therefore

$$c'\ \le\ 3c+2\sqrt2\,c=(3+2\sqrt2)\,c,\qquad 3+2\sqrt2=(1+\sqrt2)^2\approx 5.8284 .$$

The constant is the square of the **silver ratio** $1+\sqrt2$ — the analogue of the golden ratio
for $\sqrt2$, and not a coincidence: it is the fundamental unit hiding in the quadratic form
$a^2+b^2-c^2$.

> **Theorem (universal depth law).** Every node at depth $n$, along *any* of the $3^n$ paths,
> has $c\le5(3+2\sqrt2)^n$; hence its quality lies in the window
> $$\frac23\ <\ q\ \le\ \frac{2\bigl(\log5+n\log(3+2\sqrt2)\bigr)}{\log\operatorname{rad}(abc)} .$$

{{visualization:1}}

The bound is sharp: along the all-$B$ branch the hypotenuses are the Pell-type numbers
$5,29,169,985,5741,\dots$ obeying $c_{n+1}=6c_n-c_{n-1}$, and they sit within half a percent of
$5(3+2\sqrt2)^n$ forever.

**This is the conceptual heart of the whole story.** In $q=2\log c/\log\operatorname{rad}(abc)$,
the *numerator* is fixed by depth alone — the tree's geometry pins it. All $3^n$ different
qualities at depth $n$ differ only through the **denominator**. The tree cleanly splits the $abc$
problem into a geometric half, which it solves exactly, and a multiplicative half, which is the
conjecture itself.

---

## 6. Hits forever: engineering small radicals

Can we *prove* that the tree contains infinitely many hits? Yes — with the oldest trick in the
$abc$ book.

Walk down using only $A$. The nodes are the almost-isosceles triples

$$T_n=(2n+1,\ 2n(n+1),\ 2n^2+2n+1),\qquad c=b+1 .$$

Their product is $abc=(2n+1)\cdot2n(n+1)\cdot(2n^2+2n+1)$, so the radical is small exactly when
**both** $n$ and $n+1$ are rich in repeated prime factors. That can be engineered.

> **Theorem (infinitely many hits).** Let $d\ge3$ be odd and let $k$ satisfy $d\le2^k$. Then the
> spine node with parameter $n=d^{2^k}-1$ has quality $q>1$. In particular, for every bound $N$
> there is a node with hypotenuse exceeding $N$ and $q>1$.

<details>
<summary><b>The two collapses that make it work</b></summary>

* $n+1=d^{2^k}$ is a **pure power**, so $\operatorname{rad}(n+1)=\operatorname{rad}(d)\le d$: an
  astronomically large number contributes only $d$ to the radical.
* $n$ factors as $(d-1)(d+1)(d^2+1)(d^4+1)\cdots(d^{2^{k-1}}+1)$. Since $d$ is odd, $(d-1)(d+1)$ is
  divisible by $8$ and each of the remaining $k-1$ factors is even, so $2^{k+2}\mid n$ — this is
  [lifting the exponent](https://en.wikipedia.org/wiki/Lifting-the-exponent_lemma) in its
  simplest form. Consequently $\operatorname{rad}(n)\le n/2^{k+1}$.

Combining with submultiplicativity of the radical,
$$\operatorname{rad}(abc)\ \le\ (2n+1)\cdot2\cdot\frac{n}{2^{k+1}}\cdot d\cdot c\ =\ \frac{(2n+1)n\,d}{2^{k}}\,c
\ \le\ (2n^2+n)\,c\ <\ c^2 ,$$
the last step using $d\le2^k$. By the dictionary of §2, $q>1$. $\blacksquare$

The condition $d\le2^k$ is exactly the balance point between the two collapses.
</details>

This construction is also an **algorithm**: it certifies hits with hypotenuses of hundreds of
digits without factoring anything, because the proof itself supplies an upper bound for the
radical.

{{algorithm:2}}

There is a catch, and it is the honest heart of the matter: consecutive members satisfy
$c_{k+1}<c_k^2<4c_{k+1}$, so each step nearly *squares* the hypotenuse. The family delivers only
about $\log\log X$ hits below $X$. The mechanism we can control is doubly exponentially sparse —
a numerical echo of why $abc$ hits are so hard to find in the wild.

---

## 7. Certified arithmetic, no floating point

Because every threshold is an integer inequality, no claim on this page rests on numerics. To
decide $q>m/k$ you compare $\operatorname{rad}(abc)^m$ with $c^{2k}$ — and since the entries of a
primitive triple are pairwise coprime, $\operatorname{rad}(abc)=\operatorname{rad}(a)\operatorname{rad}(b)\operatorname{rad}(c)$,
so only three small factorizations are needed.

{{algorithm:0}}

A binary search over $m$ with $k=1000$ brackets any node's quality between consecutive
thousandths. For the record node this yields the certificate

$$\frac{1265}{1000}\ <\ q(36207,18424,40625)\ <\ \frac{1266}{1000},$$

and with $k=4$, $k=3$ the exact bracket $\tfrac54<q<\tfrac43$.

To see the whole spectrum, enumerate the tree breadth-first — each matrix strictly increases the
hypotenuse, so pruning at a cutoff is correct and terminating, and no triple is ever produced
twice:

{{algorithm:1}}

Run the full verification suite yourself — it checks the radical collapse, both threshold
criteria on every node up to hypotenuse $200{,}000$, the lower edge and its rate, the silver-ratio
ceiling, the certified hit family, and the histogram of the spectrum:

{{demo:0}}

And watch the quality oscillate as you descend a branch:

{{demo:1}}

---

## 8. The ceiling — and what remains genuinely hard

At the other end of the spectrum, $q<2$ needs only $\operatorname{rad}(abc)>c$. If the product is
not extravagantly powerful — say $abc\le\operatorname{rad}(abc)^2$, which holds whenever $abc$ is
squarefree — then combining with $2c\le ab$ (true for every Pythagorean triple with legs $\ge3$)
gives $2c^2\le\operatorname{rad}(abc)^2$, hence $q<2$.

But the *size* of that gap is only $\Theta(1/\log c)$: it shrinks as triples grow. **No uniform
bound $q\le2-\varepsilon$ over the tree follows**, and that is not a weakness of the argument.

<details>
<summary><b>Why the supremum question is exactly as hard as $abc$</b></summary>

By the dictionary, "$q\le 2-\varepsilon$ for all nodes" says $\operatorname{rad}(abc)\ge c^{2/(2-\varepsilon)}$
for all nodes — a power-saving lower bound on the radical of a Pythagorean product. Conversely,
a *single* effective $abc$ inequality of the shape $C^{12}\le K\operatorname{rad}(ABC)^{13}$
immediately gives, for every node with $K\le c^4$,
$$c^{24}\le KR^{13}\le c^4R^{13}\ \Longrightarrow\ c^{20}\le R^{13}\ \Longrightarrow\ q=\frac{2\log c}{\log R}\le\frac{13}{10},$$
a clean gap of $7/10$ below the ceiling. And under the full Masser–Oesterlé conjecture, for every
$\varepsilon>0$ all nodes with $c$ beyond a threshold satisfy $q\le1+2\varepsilon$: the limiting
spectrum is squeezed into $(2/3,1]$.

So the supremum of the tree's quality is not a computation waiting to be done — it is the
conjecture, restricted to this family.
</details>

---

## 9. What the model is for

Here is the balance sheet.

| Ingredient | Status in the tree |
|---|---|
| Membership: is each node a genuine $abc$ triple? | **Exact** — every node is primitive Pythagorean with legs $\ge3$ |
| The radical | **Exact** — $\operatorname{rad}(a^2b^2c^2)=\operatorname{rad}(abc)$ |
| Quality thresholds | **Exact** — integer inequalities, no floating point |
| Growth | **Exact** — the squared silver ratio $3+2\sqrt2$ |
| Lower edge | **Exact** — $q>2/3$, with rate $1/\log c$ |
| Existence of hits | **Exact** — infinitely many, explicitly parametrized |
| Density of hits, supremum, depth-$n$ distribution | **Open** — and provably $abc$-strength |

The best node in the tree has quality $1.2659$, far below the global record $1.6299$: the most
structured family of $abc$ triples we possess turns out to be a *mediocre* producer of extreme
hits. The record-setters are not structured; they are lucky.

In physics one studies the harmonic oscillator not because springs are interesting, but because
an exactly solvable case shows what the approximate answer should look like. The Berggren tree is
the harmonic oscillator of the $abc$ conjecture: every degree of freedom except the essential one
has been integrated out, and the essential one — how small a radical can be — stands alone in the
denominator of a single logarithm.

---

### Where to go next

* [Pythagorean triples and the Berggren/Barning–Hall tree](https://en.wikipedia.org/wiki/Tree_of_primitive_Pythagorean_triples)
* [The $abc$ conjecture](https://en.wikipedia.org/wiki/Abc_conjecture) and its tables of high-quality hits
* [The silver ratio $1+\sqrt2$](https://en.wikipedia.org/wiki/Silver_ratio) and Pell numbers
* Open problems from this work: the optimal constant at the lower edge, the language of hit-words,
  denser provable hit families, and the depth-$n$ distribution law.
'''


"""Demo: how the abc quality behaves under Berggren descent.

Every primitive Pythagorean triple descends to (3,4,5) in finitely many steps by
applying the inverses of the three Berggren matrices.  This demo follows that
descent from several deep nodes, printing at each step the triple, the radical
rad(abc) = rad(a^2 b^2 c^2), and the quality q = 2 log c / log rad(abc).

The output makes two proved facts visible:

  * quality is NOT monotone along the tree: (5,12,13) has q < 1, its child
    (7,24,25) has q > 1, and that child's child (105,88,137) has q < 1 again;
  * the descent path always terminates at (3,4,5), whose quality 0.9464 is
    itself below the hit threshold, so hits are created and destroyed along a
    branch rather than accumulated.

Self-contained; standard library only.
"""

from __future__ import annotations

import math
from typing import Dict, List, Tuple

Triple = Tuple[int, int, int]

MATS: Dict[str, Tuple[Tuple[int, int, int], ...]] = {
    "A": ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    "B": ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    "C": ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}
INVS: Dict[str, Tuple[Tuple[int, int, int], ...]] = {
    "A": ((1, 2, -2), (-2, -1, 2), (-2, -2, 3)),
    "B": ((1, 2, -2), (2, 1, -2), (-2, -2, 3)),
    "C": ((-1, -2, 2), (2, 1, -2), (-2, -2, 3)),
}


def apply(m: Tuple[Tuple[int, int, int], ...], t: Triple) -> Triple:
    return tuple(sum(m[i][j] * t[j] for j in range(3)) for i in range(3))  # type: ignore[return-value]


def radical(n: int) -> int:
    r, m, p = 1, n, 2
    while p * p <= m:
        if m % p == 0:
            r *= p
            while m % p == 0:
                m //= p
        p += 1 if p == 2 else 2
    if m > 1:
        r *= m
    return r


def triple_radical(t: Triple) -> int:
    """rad(abc): the entries of a primitive triple are pairwise coprime."""
    return radical(t[0]) * radical(t[1]) * radical(t[2])


def quality(t: Triple) -> float:
    return 2.0 * math.log(t[2]) / math.log(triple_radical(t))


def descend(word: str) -> List[Tuple[str, Triple]]:
    """Build the node reached by `word`, then peel the word off one step at a time."""
    t: Triple = (3, 4, 5)
    for s in word:
        t = apply(MATS[s], t)
    path: List[Tuple[str, Triple]] = [(word, t)]
    while word:
        s, word = word[-1], word[:-1]
        t = apply(INVS[s], t)
        path.append((word, t))
    return path


def report(word: str) -> None:
    print(f"\nDescent from the node at word {word!r}:")
    print(f"  {'word':<12}{'triple':>26}{'rad(abc)':>14}{'quality':>11}   hit?")
    for w, t in descend(word):
        q = quality(t)
        print(f"  {(w or '(root)'):<12}{str(t):>26}{triple_radical(t):>14}{q:>11.6f}"
              f"   {'HIT' if q > 1 else ''}")


def main() -> None:
    print("Quality under Berggren descent")
    print("q(a,b,c) = 2 log c / log rad(abc),  a hit is q > 1")
    for word in ("AAB", "CCCACCBC", "ACCCBA"):
        report(word)
    print("\nObserve: along every descent the quality oscillates across the")
    print("threshold q = 1.  No branch is monotone, and the root itself is not a hit.")


if __name__ == "__main__":
    main()


"""Visualization: the silver-ratio depth law of the Berggren tree.

Every Berggren step multiplies the hypotenuse by at most (1 + sqrt 2)^2 =
3 + 2 sqrt 2 ~ 5.8284, so a node at depth n satisfies c <= 5 (3 + 2 sqrt 2)^n.
The bound is attained, up to half a percent, along the all-B branch, whose
hypotenuses obey the Pell-type recursion c_{n+1} = 6 c_n - c_{n-1}.

The figure plots log c against depth for every node with hypotenuse below a
cutoff, together with the universal ceiling log 5 + n log(3 + 2 sqrt 2) and the
Pell branch itself; the inset shows the empirical ratio c_n / (5 (3+2sqrt2)^n)
converging to ~0.995.

Run:  python viz_silver_growth.py   (writes berggren_silver_growth.png)
"""

from __future__ import annotations

import math
from collections import deque
from typing import List, Tuple

import matplotlib.pyplot as plt

SILVER = 3.0 + 2.0 * math.sqrt(2.0)
CUTOFF = 400_000

BERGGREN = {
    "A": ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    "B": ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    "C": ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}


def collect(cutoff: int) -> Tuple[List[int], List[float]]:
    depths: List[int] = []
    logs: List[float] = []
    queue: deque[Tuple[Tuple[int, int, int], int]] = deque([((3, 4, 5), 0)])
    while queue:
        t, depth = queue.popleft()
        depths.append(depth)
        logs.append(math.log(t[2]))
        for step in "ABC":
            m = BERGGREN[step]
            u = tuple(sum(m[i][j] * t[j] for j in range(3)) for i in range(3))
            if u[2] <= cutoff:
                queue.append((u, depth + 1))  # type: ignore[arg-type]
    return depths, logs


def pell_branch(steps: int) -> List[int]:
    seq = [5, 29]
    while len(seq) < steps:
        seq.append(6 * seq[-1] - seq[-2])
    return seq[:steps]


def main() -> None:
    depths, logs = collect(CUTOFF)
    max_depth = max(depths)
    fig, ax = plt.subplots(figsize=(9, 6))
    ax.scatter(depths, logs, s=5, alpha=0.35, color="#3b6ea5", label="tree nodes")
    ns = list(range(max_depth + 1))
    ax.plot(ns, [math.log(5) + n * math.log(SILVER) for n in ns], color="crimson", lw=2,
            label=r"ceiling $\log 5 + n\log(3+2\sqrt2)$")
    ax.plot(ns, [(n + 1) * math.log(5) for n in ns], color="seagreen", lw=1.6, ls="--",
            label=r"$5^{\,n+1}$ (Pell lower bound)")
    pell = pell_branch(min(max_depth + 1, 12))
    ax.plot(range(len(pell)), [math.log(c) for c in pell], "o-", color="black", ms=4,
            label="all-$B$ (Pell) branch")
    ax.set_xlabel("depth $n$ in the tree")
    ax.set_ylabel(r"$\log c$")
    ax.set_title("Silver-ratio depth law: the hypotenuse is pinned by depth")
    ax.legend(loc="lower right", fontsize=9)

    inset = fig.add_axes((0.19, 0.62, 0.28, 0.24))
    pell_long = pell_branch(14)
    inset.plot(range(len(pell_long)),
               [c / (5.0 * SILVER ** n) for n, c in enumerate(pell_long)], "o-", ms=3,
               color="black")
    inset.axhline(1.0, ls=":", color="crimson")
    inset.set_title(r"$c_n/(5\,(3+2\sqrt2)^n)$", fontsize=9)
    inset.tick_params(labelsize=7)

    fig.tight_layout()
    fig.savefig("berggren_silver_growth.png", dpi=150)
    print("wrote berggren_silver_growth.png")


if __name__ == "__main__":
    main()


"""Visualization: the quality spectrum of the Berggren tree.

Left panel  — scatter of quality q = 2 log c / log rad(abc) against log c for
every node of the tree with hypotenuse below the cutoff, with the proved lower
edge 2 log c / (3 log c - log 2) drawn as a solid curve, the asymptotic floor
q = 2/3 as a dashed line, and the hit threshold q = 1 as a dotted line.

Right panel — histogram of the same qualities, showing the unimodal bulk near
q ~ 0.73 and the thin tail of abc hits above 1.

Run:  python viz_spectrum.py       (writes berggren_quality_spectrum.png)
"""

from __future__ import annotations

import math
from collections import deque
from typing import List, Tuple

import matplotlib.pyplot as plt

Triple = Tuple[int, int, int]

BERGGREN = {
    "A": ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    "B": ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    "C": ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}
CUTOFF = 200_000


def smallest_prime_factor_table(limit: int) -> List[int]:
    spf = list(range(limit + 1))
    i = 2
    while i * i <= limit:
        if spf[i] == i:
            for j in range(i * i, limit + 1, i):
                if spf[j] == j:
                    spf[j] = i
        i += 1
    return spf


def radical(n: int, spf: List[int]) -> int:
    result, m = 1, n
    while m > 1:
        p = spf[m]
        result *= p
        while m % p == 0:
            m //= p
    return result


def collect(cutoff: int) -> Tuple[List[float], List[float], List[int]]:
    spf = smallest_prime_factor_table(cutoff)
    logs: List[float] = []
    quals: List[float] = []
    depths: List[int] = []
    queue: deque[Tuple[Triple, int]] = deque([((3, 4, 5), 0)])
    while queue:
        (a, b, c), depth = queue.popleft()
        rad = radical(a, spf) * radical(b, spf) * radical(c, spf)
        logs.append(math.log(c))
        quals.append(2.0 * math.log(c) / math.log(rad))
        depths.append(depth)
        for step in "ABC":
            m = BERGGREN[step]
            u = tuple(sum(m[i][j] * (a, b, c)[j] for j in range(3)) for i in range(3))
            if u[2] <= cutoff:
                queue.append((u, depth + 1))  # type: ignore[arg-type]
    return logs, quals, depths


def main() -> None:
    logs, quals, depths = collect(CUTOFF)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.2))

    sc = ax1.scatter(logs, quals, c=depths, s=4, cmap="viridis", alpha=0.65)
    xs = [x / 100.0 for x in range(170, int(100 * math.log(CUTOFF)) + 1)]
    ax1.plot(xs, [2 * x / (3 * x - math.log(2)) for x in xs], color="crimson", lw=2,
             label=r"proved edge  $2\log c/(3\log c-\log 2)$")
    ax1.axhline(2 / 3, ls="--", color="black", lw=1, label=r"floor  $q=2/3$")
    ax1.axhline(1.0, ls=":", color="darkorange", lw=1.6, label=r"hit threshold  $q=1$")
    ax1.set_xlabel(r"$\log c$")
    ax1.set_ylabel(r"quality $q = 2\log c/\log \mathrm{rad}(abc)$")
    ax1.set_title(f"Quality spectrum of the Berggren tree ($c \\leq {CUTOFF}$)")
    ax1.legend(loc="upper right", fontsize=9)
    fig.colorbar(sc, ax=ax1, label="depth in the tree")

    ax2.hist(quals, bins=90, color="#3b6ea5", edgecolor="white")
    ax2.axvline(2 / 3, ls="--", color="black", lw=1)
    ax2.axvline(1.0, ls=":", color="darkorange", lw=1.6)
    ax2.set_yscale("log")
    ax2.set_xlabel("quality $q$")
    ax2.set_ylabel("number of nodes (log scale)")
    hits = sum(1 for q in quals if q > 1)
    ax2.set_title(f"{len(quals)} nodes, {hits} hits ({100*hits/len(quals):.2f}%)")

    fig.tight_layout()
    fig.savefig("berggren_quality_spectrum.png", dpi=150)
    print("wrote berggren_quality_spectrum.png")


if __name__ == "__main__":
    main()


"""
The Berggren tree as a solvable model of the abc conjecture
===========================================================

Numerical companion to "The Exact Quality Spectrum of a^2 + b^2 = c^2".

Every primitive Pythagorean triple a^2 + b^2 = c^2 is an instance of the abc
situation A + B = C with A = a^2, B = b^2, C = c^2.  Its abc quality is

        q(a, b, c) = log(c^2) / log(rad(a^2 b^2 c^2)) = 2 log c / log rad(abc),

the second equality because a^2 b^2 c^2 and abc have exactly the same prime
divisors.  The primitive triples form a ternary tree rooted at (3, 4, 5) whose
edges are the three Berggren matrices; this script computes the quality
spectrum of that tree and checks, numerically, every bound proved in the paper:

  * the exact thresholds  q > 1  <=>  rad(abc) < c^2   and
                          q < 2  <=>  rad(abc) > c;
  * the unconditional lower edge  q > 2/3, with the sharpened rate
        q >= 2 log c / (3 log c - log 2) >= 2/3 + 2 log 2 / (9 log c);
  * the universal silver-ratio depth law  c <= 5 (3 + 2 sqrt 2)^n at depth n,
    together with the Pell lower bound 5^(n+1) <= c_n along the B-spine;
  * the explicit infinite family of abc hits (q > 1) on the A-spine,
        n = d^(2^k) - 1  for odd d >= 3 with d <= 2^k,
    and its double-exponential sparsity;
  * the record node (36207, 18424, 40625) with 5/4 < q < 4/3.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import math
from collections import deque
from typing import Dict, Iterator, List, Sequence, Tuple

Triple = Tuple[int, int, int]

# --------------------------------------------------------------------------
# 1. Radicals and quality
# --------------------------------------------------------------------------


def radical(n: int) -> int:
    """Product of the distinct primes dividing n (rad 1 = 1)."""
    if n <= 0:
        raise ValueError("radical is defined for positive integers")
    result, m, p = 1, n, 2
    while p * p <= m:
        if m % p == 0:
            result *= p
            while m % p == 0:
                m //= p
        p += 1 if p == 2 else 2
    if m > 1:
        result *= m
    return result


def quality(a: int, b: int, c: int) -> float:
    """abc quality of the triple a^2 + b^2 = c^2, i.e. 2 log c / log rad(abc)."""
    return 2.0 * math.log(c) / math.log(radical(a * b * c))


def radical_collapse_check(a: int, b: int, c: int) -> bool:
    """Verify rad(a^2 b^2 c^2) = rad(abc) for a single triple."""
    return radical(a * a * b * b * c * c) == radical(a * b * c)


# --------------------------------------------------------------------------
# 2. The Berggren tree
# --------------------------------------------------------------------------

BERGGREN: Dict[str, Tuple[Tuple[int, int, int], ...]] = {
    "A": ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    "B": ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    "C": ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}

ROOT: Triple = (3, 4, 5)


def apply_step(step: str, t: Triple) -> Triple:
    """Apply one Berggren matrix to a triple."""
    m = BERGGREN[step]
    return tuple(sum(m[i][j] * t[j] for j in range(3)) for i in range(3))  # type: ignore[return-value]


def apply_path(path: str) -> Triple:
    """Follow a word in {A, B, C} from the root (3, 4, 5)."""
    t = ROOT
    for step in path:
        t = apply_step(step, t)
    return t


def tree_nodes(hyp_limit: int) -> Iterator[Tuple[Triple, str]]:
    """Breadth-first enumeration of all tree nodes with hypotenuse <= hyp_limit."""
    queue: deque[Tuple[Triple, str]] = deque([(ROOT, "")])
    while queue:
        t, path = queue.popleft()
        yield t, path
        for step in "ABC":
            u = apply_step(step, t)
            if u[2] <= hyp_limit:
                queue.append((u, path + step))


def is_primitive_pythagorean(t: Triple) -> bool:
    a, b, c = t
    return a * a + b * b == c * c and math.gcd(a, b) == 1 and min(a, b) >= 3


# --------------------------------------------------------------------------
# 3. The A-spine and the explicit hit family
# --------------------------------------------------------------------------


def spine_triple(n: int) -> Triple:
    """The A-spine node with parameter n: (2n+1, 2n(n+1), 2n^2+2n+1)."""
    return (2 * n + 1, 2 * n * (n + 1), 2 * n * n + 2 * n + 1)


def spine_hit_criterion(n: int) -> bool:
    """Sufficient arithmetic criterion for the A-spine node n to satisfy q > 1."""
    a, _, c = spine_triple(n)
    return a * (2 * radical(n) * radical(n + 1)) < c


def hit_family_parameter(d: int, k: int) -> int:
    """Spine parameter n = d^(2^k) - 1 of the explicit hit family."""
    return d ** (2 ** k) - 1


def hit_family_quality_lower_bound(d: int, k: int) -> float:
    """A certified lower bound for the quality of the family member (d, k).

    No factorisation is needed.  The proof supplies rad(n) <= n / 2^(k+1)
    (because 2^(k+2) divides n = d^(2^k) - 1), rad(n+1) = rad(d) <= d, and
    rad(abc) <= a * 2 rad(n) rad(n+1) * c; the quality is then at least
    2 log c / log(that bound).
    """
    n = hit_family_parameter(d, k)
    a, _, c = spine_triple(n)
    bound = a * 2 * (n // 2 ** (k + 1)) * d * c
    return 2.0 * math.log(c) / math.log(bound)


# --------------------------------------------------------------------------
# 4. Bounds proved in the paper
# --------------------------------------------------------------------------

SILVER: float = 3.0 + 2.0 * math.sqrt(2.0)  # (1 + sqrt 2)^2 = 5.8284...


def lower_edge_bound(c: int) -> float:
    """The proved lower bound 2 log c / (3 log c - log 2) on the quality."""
    lc = math.log(c)
    return 2.0 * lc / (3.0 * lc - math.log(2.0))


def lower_edge_rate(c: int) -> float:
    """The weaker but transparent bound 2/3 + 2 log 2 / (9 log c)."""
    return 2.0 / 3.0 + 2.0 * math.log(2.0) / (9.0 * math.log(c))


def depth_quality_ceiling(a: int, b: int, c: int, depth: int) -> float:
    """The depth-n quality ceiling 2 (log 5 + n log(3 + 2 sqrt 2)) / log rad(abc)."""
    return 2.0 * (math.log(5.0) + depth * math.log(SILVER)) / math.log(radical(a * b * c))


# --------------------------------------------------------------------------
# 5. Demonstrations
# --------------------------------------------------------------------------


def demo_radical_collapse() -> None:
    print("=" * 74)
    print("1. Radical collapse:  rad(a^2 b^2 c^2) = rad(abc)")
    print("=" * 74)
    samples: Sequence[Triple] = [ROOT, (5, 12, 13), (7, 24, 25), (105, 88, 137), (21, 20, 29)]
    for t in samples:
        a, b, c = t
        print(
            f"  {str(t):>18}  rad(abc) = {radical(a*b*c):>9}   "
            f"rad(a^2b^2c^2) = {radical(a*a*b*b*c*c):>9}   "
            f"{'OK' if radical_collapse_check(a, b, c) else 'FAIL'}"
        )
    print()


def demo_explicit_spectrum_points() -> None:
    print("=" * 74)
    print("2. Explicit points of the spectrum (and non-monotonicity under descent)")
    print("=" * 74)
    chain: Sequence[Tuple[str, Triple]] = [
        ("", ROOT),
        ("A", (5, 12, 13)),
        ("AA", (7, 24, 25)),
        ("AAB", (105, 88, 137)),
    ]
    for path, t in chain:
        a, b, c = t
        assert apply_path(path) == t, (path, t)
        print(
            f"  path {(path or 'root'):<5} {str(t):>18}  rad(abc) = {radical(a*b*c):>8}  "
            f"q = {quality(a, b, c):.6f}  {'HIT (q>1)' if quality(a,b,c) > 1 else ''}"
        )
    print("  -> quality falls, rises above 1, then falls again: descent does not")
    print("     move the quality monotonically.")
    a, b, c = 36207, 18424, 40625
    print(f"\n  Record node {(a, b, c)} reached by the word CCCACCBC:")
    print(f"     rad(abc) = {radical(a*b*c)},  q = {quality(a, b, c):.6f}")
    print(f"     bracket 5/4 = 1.25 < q < 4/3 = {4/3:.6f}:  "
          f"{'OK' if 1.25 < quality(a,b,c) < 4/3 else 'FAIL'}")
    print()


def demo_thresholds() -> None:
    print("=" * 74)
    print("3. Exact thresholds:  q > 1 <=> rad(abc) < c^2 ;  q < 2 <=> rad(abc) > c")
    print("=" * 74)
    ok = True
    for t, _ in tree_nodes(200_000):
        a, b, c = t
        r = radical(a * b * c)
        q = quality(a, b, c)
        ok &= (q > 1) == (r < c * c)
        ok &= (q < 2) == (r > c)
    print(f"  Both criteria verified on every tree node with c <= 200000: "
          f"{'OK' if ok else 'FAIL'}")
    print()


def demo_lower_edge() -> None:
    print("=" * 74)
    print("4. Lower edge:  q > 2/3, at rate 1/log c")
    print("=" * 74)
    worst: Tuple[float, Triple] = (10.0, ROOT)
    ok = True
    for t, _ in tree_nodes(200_000):
        a, b, c = t
        q = quality(a, b, c)
        ok &= q > lower_edge_bound(c) - 1e-12
        ok &= q > lower_edge_rate(c) - 1e-12
        if q < worst[0]:
            worst = (q, t)
    print(f"  Proved bounds hold at every node with c <= 200000: {'OK' if ok else 'FAIL'}")
    print(f"  Smallest observed quality: q = {worst[0]:.6f} at {worst[1]}")
    print("  Bound values as c grows (the edge 2/3 = 0.6667 is approached like 1/log c):")
    for c in (10 ** e for e in range(1, 9)):
        print(f"     c = 10^{len(str(c))-1:<2}  2 log c/(3 log c - log 2) = "
              f"{lower_edge_bound(c):.6f}   2/3 + 2log2/(9 log c) = {lower_edge_rate(c):.6f}")
    print()


def demo_silver_depth_law() -> None:
    print("=" * 74)
    print("5. Silver-ratio depth law:  c <= 5 (3 + 2 sqrt 2)^n at depth n")
    print("=" * 74)
    print(f"  silver constant 3 + 2 sqrt 2 = {SILVER:.6f}")
    ok = True
    for t, path in tree_nodes(2_000_000):
        ok &= math.log(t[2]) <= math.log(5.0) + len(path) * math.log(SILVER) + 1e-9
    print(f"  Verified for every node with c <= 2000000: {'OK' if ok else 'FAIL'}")
    print("  The B-spine (all-B path) is the extremal branch; its hypotenuses are Pell:")
    t = ROOT
    for n in range(8):
        print(f"     n = {n}:  c_n = {t[2]:>10}   5^(n+1) = {5**(n+1):>10} <= c_n <= "
              f"{5.0 * SILVER ** n:>14.1f}   ratio to 5*silver^n = "
              f"{t[2] / (5.0 * SILVER ** n):.4f}")
        t = apply_step("B", t)
    print()


def demo_hits() -> None:
    print("=" * 74)
    print("6. Infinitely many abc hits on the A-spine, and their sparsity")
    print("=" * 74)
    print("  A-spine parameters n <= 60 with q > 1:")
    hits: List[int] = []
    for n in range(1, 61):
        a, b, c = spine_triple(n)
        if quality(a, b, c) > 1:
            hits.append(n)
    for n in hits:
        a, b, c = spine_triple(n)
        print(f"     n = {n:>3}   {str((a, b, c)):>22}   q = {quality(a, b, c):.5f}")
    print("  The coarse sufficient criterion (2n+1) * 2 rad(n) rad(n+1) < c only")
    print("  triggers once the radicals of n and n+1 are genuinely small; e.g.")
    for n in (3, 49, 80, 728):
        a, b, c = spine_triple(n)
        print(f"     n = {n:>4}:  rad(n) = {radical(n):>5}, rad(n+1) = {radical(n+1):>5}, "
              f"criterion {str(spine_hit_criterion(n)):>5}, actual q = {quality(a, b, c):.5f}")
    print("\n  The proved family n = d^(2^k) - 1 (d odd >= 3, d <= 2^k).")
    print("  Certified lower bounds for the quality, obtained without factoring:")
    for d in (3, 5, 7):
        for k in (2, 3, 4, 5, 6):
            if d <= 2 ** k:
                n = hit_family_parameter(d, k)
                c = spine_triple(n)[2]
                qlb = hit_family_quality_lower_bound(d, k)
                print(f"     d = {d}, k = {k}:  c has {len(str(c)):>4} digits,   "
                      f"q >= {qlb:.6f}  {'HIT (q > 1)' if qlb > 1 else '--'}")
    print("\n  Double-exponential sparsity of the base-3 family (c_{k+1} ~ c_k^2):")
    prev = None
    for k in range(2, 7):
        n = hit_family_parameter(3, k)
        c = spine_triple(n)[2]
        if prev is not None:
            print(f"     k = {k}:  digits(c_k) = {len(str(c)):>5}   "
                  f"c_k < c_{{k-1}}^2 : {c < prev * prev}   "
                  f"c_{{k-1}}^2 < 4 c_k : {prev * prev < 4 * c}")
        prev = c
    print("  => only O(log log X) members of this family below X.\n")


def demo_spectrum_scan() -> None:
    print("=" * 74)
    print("7. Scan of the spectrum")
    print("=" * 74)
    limit = 300_000
    data: List[Tuple[float, Triple, str]] = [
        (quality(*t), t, path) for t, path in tree_nodes(limit)
    ]
    data.sort(reverse=True)
    n_nodes = len(data)
    n_hits = sum(1 for q, _, _ in data if q > 1)
    print(f"  Nodes with hypotenuse <= {limit}: {n_nodes}")
    print(f"  abc hits (q > 1): {n_hits}  ({100.0 * n_hits / n_nodes:.2f}%)")
    print(f"  Observed range: {data[-1][0]:.6f} <= q <= {data[0][0]:.6f}")
    print("  Top five nodes by quality:")
    for q, t, path in data[:5]:
        print(f"     q = {q:.6f}   {str(t):>26}   depth {len(path):>3}   word {path[:12]}"
              f"{'...' if len(path) > 12 else ''}")
    print("  Histogram of the quality spectrum:")
    edges = [0.6 + 0.05 * i for i in range(16)]
    for lo, hi in zip(edges, edges[1:]):
        count = sum(1 for q, _, _ in data if lo <= q < hi)
        bar = "#" * min(60, count * 60 // max(1, n_nodes // 8))
        print(f"     [{lo:.2f}, {hi:.2f})  {count:>6}  {bar}")
    print("  Note: nothing observed comes close to the abc record quality ~ 1.63.\n")


def main() -> None:
    print()
    print("THE BERGGREN TREE AS A SOLVABLE MODEL OF THE abc CONJECTURE")
    print("Numerical verification of the quality spectrum\n")
    demo_radical_collapse()
    demo_explicit_spectrum_points()
    demo_thresholds()
    demo_lower_edge()
    demo_silver_depth_law()
    demo_hits()
    demo_spectrum_scan()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
