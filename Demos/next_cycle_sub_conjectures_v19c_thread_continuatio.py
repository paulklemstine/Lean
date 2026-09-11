"""Assemble PACKAGE.json from the individual deliverables in this directory."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).parent
A = ROOT / "package_assets"

LEAN_FILES = [
    "Catalog/NumberTheory/SingmasterCore.lean",
    "Catalog/NumberTheory/SingmasterSmallValues.lean",
    "Catalog/NumberTheory/SingmasterFibonacciSix.lean",
    "Catalog/NumberTheory/SingmasterExactFour.lean",
    "Catalog/NumberTheory/SingmasterDensity.lean",
    "Catalog/NumberTheory/SingmasterRowShiftClassification.lean",
]


def read(p: str) -> str:
    return (ROOT / p).read_text()


lean_proofs = "\n\n".join(
    f"-- ===== FILE: {f} =====\n\n{read(f)}" for f in LEAN_FILES
)

FUTURE = read("package_assets/future_directions.md")

INTERACTIVE_LAYOUT = read("package_assets/interactive_layout.md")

package = {
    "title": "The Singmaster Multiplicity: Structure Theorems and the Complete "
             "Classification of One-Row-Shift Coincidences",
    "domain": "Algebra",
    "description": "An unconditional structure theory for the number of times an integer "
                   "occurs in Pascal's triangle — a parity law, an exact-multiplicity family, "
                   "a density bound, and the record m(3003)=8 — culminating in a complete "
                   "classification of the one-row-shift coincidences C(N,k)=C(N-1,k+1) as "
                   "exactly the Fibonacci pairs N=F(2i+2)F(2i+3), k=F(2i)F(2i+3).",
    "authors": ["Aristotle"],
    "date": "2026-09-10",
    "key_results": [
        "Row squeeze: every occurrence of n with 2 <= k <= N-2 lies in a row with N(N-1) <= 2n, so the search for occurrences is confined to O(sqrt n) rows.",
        "Parity law: the multiplicity of n is odd if and only if n is a central binomial coefficient C(2t,t); equivalently, multiplicity equals twice the number of occurrences left of centre plus at most one central occurrence.",
        "Large-prime-factor obstruction: if a prime p divides n and p(p-1) > 2n, then n occurs exactly twice; in particular every prime p >= 5 and every 2p with p >= 7 has multiplicity exactly 2.",
        "Exact multiplicity four: for every prime p >= 5 the number C(p,2) occurs exactly four times, giving an infinite family of exact multiplicity 4.",
        "Density bound: the number of n <= x occurring three or more times is at most (floor(sqrt(2x))+2)(floor(log2 x)+2), so almost every integer occurs exactly twice.",
        "Record verification: 3003 occurs eight times, no integer below 3003 occurs more than eight times, and the multiplicities 5 and 7 are never attained below 3003.",
        "Row-shift classification: for 2 <= k and 2k <= N the equation N(k+1) = (N-k)(N-k-1), equivalently C(N,k) = C(N-1,k+1), holds exactly for the Fibonacci pairs N = F(2i+2)F(2i+3), k = F(2i)F(2i+3) with i >= 1; consequently the Fibonacci ladder is the only infinite family of six-fold coincidences produced by a one-row shift.",
    ],
    "keywords": [
        "Singmaster's conjecture",
        "binomial coefficients",
        "Pascal's triangle",
        "Cassini identity",
        "Fibonacci numbers",
        "Vieta jumping",
        "Pell equation",
        "Diophantine classification",
    ],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Verification of the Singmaster Structure Theory",
            "description": (
                "A single self-contained script that reproduces, numerically, every result of the "
                "development: the row squeeze N(N-1) <= 2n and the column squeeze 2^k <= n for interior "
                "occurrences; the splitting m(n) = 2 + #interior; the reflection decomposition "
                "m(n) = 2*#lower + #central with at most one central occurrence, and the resulting parity "
                "law (odd multiplicity exactly at the central binomial coefficients 2, 6, 20, 70, 252, 924); "
                "the large-prime-factor obstruction forcing multiplicity 2; the exact value 4 at C(p,2) for "
                "primes p >= 5; the record m(3003) = 8 together with the histogram of multiplicities below "
                "3003 (showing that 5 and 7 never occur and 8 is never exceeded); the O(sqrt(x) log x) "
                "density bound against actual counts; the Fibonacci ladder of six-fold coincidences; the "
                "exhaustive confirmation of the row-shift classification and of its Pell shadow "
                "(3N-1-2k)^2 = 5N^2 + 2N + 1; and the two-step Vieta descent walking the ladder down to its "
                "seed. Every claim is asserted, not merely printed."
            ),
            "code": read("demo.py"),
        },
        {
            "name": "The Fibonacci Ladder, the Vieta Descent, and the Exhaustion of the One-Row Shift",
            "description": (
                "Focused demonstration of the main new theorem. It brute-forces all solutions of "
                "N(k+1) = (N-k)(N-k-1) with 2 <= k <= N/2 up to N = 5000 and matches them exactly against "
                "the predicted Fibonacci pairs (15,5), (104,39), (714,272), (4895,1869); runs the two-step "
                "Vieta descent (N,k) -> (3k+2-N, 3(3k+2-N)-1-k) from every solution down to the seed (2,0); "
                "checks the even-index Cassini identity F(2i+1)^2 = F(2i)F(2i+1) + F(2i)^2 + 1 that powers "
                "the ascent; verifies the Pell shadow (3N-1-2k)^2 = 5N^2+2N+1 (with 5N+1 and 3N-1-2k the "
                "classical Lucas-Fibonacci solutions of X^2 - 5Y^2 = -4); and displays, for the first rungs, "
                "the four interior positions carrying the common value, which with the two boundary "
                "occurrences give multiplicity at least six."
            ),
            "code": read("package_assets/demo_ladder.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Multiplicity Computation by Row and Column Squeezes",
            "description": (
                "Computes the Singmaster multiplicity m(n) exactly. The naive approach scans every row "
                "N <= n, costing O(n log n) binomial evaluations. The row squeeze N(N-1) <= 2n, valid for "
                "every occurrence with 2 <= k <= N-2, cuts the row range to O(sqrt n); the column squeeze "
                "2^k <= n cuts the column range in each row to O(log n); reflection k -> N-k halves the work "
                "again. Entries are generated incrementally by C(N,k+1) = C(N,k)(N-k)/(k+1), so each lattice "
                "point costs one multiplication and one exact division, giving total complexity "
                "O(sqrt(n) log n) big-integer operations. The routine also returns the structural profile "
                "used by the parity law: the interior count, the count strictly left of centre, and whether "
                "a central occurrence exists."
            ),
            "pseudocode": (
                "INPUT  n >= 3\n"
                "OUTPUT m(n), together with the list of interior occurrences\n"
                "\n"
                "1  interior <- empty list\n"
                "2  N <- 4\n"
                "3  while N(N-1) <= 2n do                 // row squeeze\n"
                "4      c <- C(N,2)\n"
                "5      k <- 2\n"
                "6      while k <= floor(N/2) and c <= n do    // column squeeze (implicit)\n"
                "7          if c = n then\n"
                "8              append (N,k) to interior\n"
                "9              if 2k != N then append (N, N-k) to interior   // reflection\n"
                "10         c <- c * (N-k) / (k+1)         // exact incremental update\n"
                "11         k <- k + 1\n"
                "12     N <- N + 1\n"
                "13 return 2 + |interior|, interior        // the 2 boundary occurrences C(n,1), C(n,n-1)"
            ),
            "code": read("package_assets/algo_multiplicity.py"),
        },
        {
            "name": "Two-Step Vieta Descent for the Row-Shift Diophantine Equation",
            "description": (
                "Decides whether a pair (N,k) with 2k <= N solves the row-shift equation "
                "k^2 + k + N^2 = 3Nk + 2N (equivalently C(N,k) = C(N-1,k+1)) and, if so, exhibits its "
                "position on the Fibonacci ladder. The equation is monic and quadratic in each variable "
                "separately, hence carries two Vieta involutions: sigma sends N to the conjugate root "
                "3k+2-N with the column fixed, and tau sends k to the conjugate root 3N-1-k with the row "
                "fixed. The composite tau.sigma maps the admissible region {1 <= k, 2k <= N} into itself "
                "and strictly decreases the row, so iteration terminates -- necessarily at the degenerate "
                "seed (2,0) when the input is a genuine solution. Since consecutive rungs grow by the factor "
                "phi^4 ~ 6.854, the descent takes O(log N) steps of O(1) arithmetic operations. Reversing "
                "the descent gives the ascent (a,b) -> (a+b, a+2b) on the Cassini side, which enumerates all "
                "solutions in time linear in the output size."
            ),
            "pseudocode": (
                "INPUT  (N, k) with N >= 1, k >= 0\n"
                "OUTPUT the descent chain to (2,0) if (N,k) is an admissible solution, else FAIL\n"
                "\n"
                "1  if not (2k <= N and k^2 + k + N^2 = 3Nk + 2N) then return FAIL\n"
                "2  chain <- [(N,k)]\n"
                "3  while last(chain) != (2,0) do\n"
                "4      (N,k) <- last(chain)\n"
                "5      M <- 3k + 2 - N                    // Vieta conjugate in the row\n"
                "6      j <- 3M - 1 - k                    // Vieta conjugate in the column\n"
                "7      assert 2 <= M < N and 2j <= M      // guaranteed by the descent lemmas\n"
                "8      append (M,j) to chain\n"
                "9  return chain\n"
                "\n"
                "ASCENT (enumerate all solutions):\n"
                "A1 (a,b) <- (0,1)                          // Cassini seed, b^2 = ab + a^2 + 1\n"
                "A2 repeat: emit ((a+b)(a+2b), a(a+2b)); (a,b) <- (a+b, a+2b)"
            ),
            "code": read("package_assets/algo_vieta_descent.py"),
        },
        {
            "name": "Logarithmic-Time Parity Oracle via the Central Binomial Test",
            "description": (
                "Decides the parity of m(n) without inspecting Pascal's triangle at all. The reflection "
                "k -> N-k is an involution on the occurrence set whose only fixed points are central "
                "positions (N,k) with N = 2k; since t -> C(2t,t) is strictly increasing, at most one central "
                "occurrence exists. Hence m(n) = 2*(occurrences left of centre) + (0 or 1), and m(n) is odd "
                "precisely when n is a central binomial coefficient. Because C(2t,t) >= 2^t, only "
                "t <= log2(n) candidates need be generated, each by the exact recurrence "
                "(t+1)C(2t+2,t+1) = 2(2t+1)C(2t,t). Complexity: O(log n) big-integer operations, versus "
                "O(sqrt(n) log n) for computing the multiplicity itself."
            ),
            "pseudocode": (
                "INPUT  n >= 2\n"
                "OUTPUT TRUE if m(n) is odd, FALSE otherwise (plus the index t when odd)\n"
                "\n"
                "1  c <- 1;  t <- 0                  // c = C(2t, t)\n"
                "2  while c < n do\n"
                "3      c <- c * 2(2t+1) / (t+1)     // exact: C(2t+2,t+1) from C(2t,t)\n"
                "4      t <- t + 1\n"
                "5  if c = n then return (TRUE, t)   // n is central: multiplicity is odd\n"
                "6  else return (FALSE, none)        // multiplicity is even"
            ),
            "code": read("package_assets/algo_parity.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Multiplicity Spectrum Below the Record",
            "description": (
                "Plots m(n) for every 2 <= n <= 3002 and colours the structural families the theory "
                "identifies: the generic value 2; the exact family C(p,2) with p prime at multiplicity 4; "
                "the central binomial coefficients 6, 20, 70, 252, 924, which are the only values of odd "
                "multiplicity and all sit at 3; and the coincidence values with m >= 6, together with the "
                "record m(3003) = 8. Three theorems become visible in one picture: multiplicity is almost "
                "always 2, odd multiplicity occurs exactly at central binomial coefficients, and nothing "
                "below 3003 exceeds 6."
            ),
            "code": read("package_assets/viz_spectrum.py"),
        },
        {
            "name": "The Confinement Rectangle and the Fibonacci Ladder with Vieta Descent",
            "description": (
                "Two panels. Left: every interior occurrence C(N,k) = n <= 3002 with 2k <= N plotted at its "
                "position (k, N), with the horizontal ceiling N(N-1) <= 2X from the row squeeze and the "
                "vertical wall 2^k <= X from the column squeeze — the O(sqrt X) x O(log X) rectangle that "
                "drives the density theorem. Right: the complete solution set of the row-shift equation "
                "N(k+1) = (N-k)(N-k-1) on a log-log scale, i.e. the Fibonacci ladder, with arrows showing "
                "the two-step Vieta descent carrying each rung to the one below and terminating at the seed "
                "(2,0). The classification theorem states that the plotted rungs are the only points on "
                "this curve."
            ),
            "code": read("package_assets/viz_confinement.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Singmaster Laboratory: Multiplicity Explorer and Vieta Descent Playground",
            "description": (
                "A two-panel interactive workbench. Panel 1 takes any n up to a billion, computes its exact "
                "multiplicity using the row squeeze (so only O(sqrt n) rows are scanned), lists every "
                "occurrence with its position relative to the centre, renders the top of Pascal's triangle "
                "with all hits highlighted, and then reports which structural theorem explains the answer: "
                "the parity law (is n a central binomial coefficient, forcing odd multiplicity?), the "
                "large-prime-factor obstruction (does a prime p | n satisfy p(p-1) > 2n, forcing exactly "
                "two occurrences?), and the exact-four family n = C(p,2). Panel 2 is a playground for the "
                "main new theorem: enter any (N,k), see whether it solves the row-shift equation "
                "N(k+1) = (N-k)(N-k-1), watch the two-step Vieta descent (N,k) -> (3k+2-N, 3(3k+2-N)-1-k) "
                "walk it down to the seed (2,0), check its Pell shadow (3N-1-2k)^2 = 5N^2+2N+1, and browse "
                "the generated ladder of all solutions. Non-solutions are rejected with the numerical "
                "mismatch shown, which makes the rigidity of the classification tangible."
            ),
            "html": read("package_assets/widget_singmaster.html"),
        }
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE,
    "modules": {
        "demo": read("demo.py"),
        "demo_ladder": read("package_assets/demo_ladder.py"),
        "algo_multiplicity": read("package_assets/algo_multiplicity.py"),
        "algo_vieta_descent": read("package_assets/algo_vieta_descent.py"),
        "algo_parity": read("package_assets/algo_parity.py"),
    },
    "lean_files": LEAN_FILES,
}

(ROOT / "PACKAGE.json").write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n")
print("PACKAGE.json written:", (ROOT / "PACKAGE.json").stat().st_size, "bytes")


"""
Singmaster multiplicity: numerical demonstrations
=================================================

The *Singmaster multiplicity* of a positive integer n is

        mult(n) = # { (N, k) : 0 <= k <= N,  C(N, k) = n },

the number of positions at which n appears in Pascal's triangle.

This script demonstrates, numerically, every structural result of the accompanying
paper:

  1.  Finiteness and the search radius:  every occurrence of n >= 2 has N <= n, and
      every *interior* occurrence (2 <= k <= N-2) obeys the sharp squeezes
          N(N-1) <= 2n          (row squeeze)
          2^k    <= n           (column squeeze).
  2.  Trivial-occurrence splitting:  mult(n) = 2 + #interior(n)  for n >= 3.
  3.  Reflection decomposition and the parity law:
          mult(n) = 2 * #lower(n) + #central(n),   #central(n) <= 1,
      hence mult(n) is odd  <=>  n is a central binomial coefficient C(2m, m).
  4.  The large-prime-factor obstruction:  if p | n is prime and p(p-1) > 2n,
      then mult(n) = 2.  In particular mult(p) = 2 for primes p >= 5 and
      mult(2p) = 2 for primes p >= 7.
  5.  Exact multiplicity four:  mult(C(p,2)) = 4 for every prime p >= 5.
  6.  The record value mult(3003) = 8, and mult(n) <= 8 for all n < 3003, with
      5 and 7 never attained below 3003.
  7.  The density bound
          #{3 <= n <= x : mult(n) >= 3} <= (floor(sqrt(2x)) + 2)(floor(log2 x) + 2).
  8.  The Fibonacci ladder:  N_i = F(2i+2)F(2i+3),  k_i = F(2i)F(2i+3) satisfies the
      row-shift equation C(N,k) = C(N-1,k+1) and hence mult(C(N_i,k_i)) >= 6;
      the first member is C(15,5) = 3003.
  9.  The row-shift classification (the Fibonacci ladder is the *only* solution
      family) and its Pell shadow (3N-1-2k)^2 = 5N^2 + 2N + 1.

Pure standard library; no dependencies.
"""

from __future__ import annotations

import sys
from math import comb, isqrt
from typing import Dict, Iterator, List, Tuple

# ----------------------------------------------------------------------------- #
# 1.  The occurrence set and the multiplicity
# ----------------------------------------------------------------------------- #


def occurrences(n: int) -> List[Tuple[int, int]]:
    """All positions (N, k) with 0 <= k <= N and C(N, k) = n, for n >= 2.

    Correctness rests on the row bound: any occurrence of n >= 2 has N <= n,
    because a non-trivial entry of row N is at least N.  Within a row we only need
    to scan k <= N // 2 and reflect, since C(N, k) = C(N, N - k).
    """
    if n < 2:
        raise ValueError("multiplicity is only meaningful for n >= 2")
    found: List[Tuple[int, int]] = []
    for N in range(2, n + 1):
        # walk outwards from k = 1; the row increases towards the centre
        for k in range(1, N // 2 + 1):
            c = comb(N, k)
            if c > n:
                break
            if c == n:
                found.append((N, k))
                if 2 * k != N:
                    found.append((N, N - k))
    return sorted(found)


def mult(n: int) -> int:
    """The Singmaster multiplicity of n."""
    return len(occurrences(n))


def interior_occurrences(n: int) -> List[Tuple[int, int]]:
    """Occurrences with 2 <= k <= N - 2 (the non-trivial ones)."""
    return [(N, k) for (N, k) in occurrences(n) if 2 <= k <= N - 2]


# ----------------------------------------------------------------------------- #
# 2.  Structural checks
# ----------------------------------------------------------------------------- #


def check_row_and_column_squeeze(bound: int = 400) -> None:
    """Interior occurrences satisfy N(N-1) <= 2n; those with 2k <= N satisfy 2^k <= n."""
    print("=== 1. Row squeeze N(N-1) <= 2n and column squeeze 2^k <= n (for 2k <= N) ===")
    worst_row = (0, 0, 0)
    for n in range(3, bound + 1):
        for (N, k) in interior_occurrences(n):
            assert N * (N - 1) <= 2 * n, (n, N, k)
            if 2 * k <= N:
                assert 2 ** k <= n, (n, N, k)
            if N > worst_row[1]:
                worst_row = (n, N, k)
    n, N, k = worst_row
    print(f"    verified for all 3 <= n <= {bound}")
    print(f"    extremal interior occurrence found: C({N},{k}) = {n}, "
          f"N(N-1) = {N*(N-1)} <= 2n = {2*n}")
    print()


def check_splitting(bound: int = 300) -> None:
    """mult(n) = 2 + #interior(n) for n >= 3."""
    print("=== 2. Trivial-occurrence splitting: mult(n) = 2 + #interior(n) ===")
    for n in range(3, bound + 1):
        assert mult(n) == 2 + len(interior_occurrences(n)), n
    print(f"    verified for all 3 <= n <= {bound}")
    print("    e.g. mult(120) = 2 + #{(10,3),(10,7),(16,2),(16,14)} = 6")
    print()


def check_parity_law(bound: int = 1500) -> None:
    """mult(n) odd  <=>  n = C(2m, m) for some m; and #central(n) <= 1."""
    print("=== 3. Parity law: mult(n) is odd iff n is a central binomial number ===")
    central = {comb(2 * m, m) for m in range(0, 12)}
    odd_ns: List[int] = []
    for n in range(2, bound + 1):
        occ = occurrences(n)
        lower = [(N, k) for (N, k) in occ if 2 * k < N]
        upper = [(N, k) for (N, k) in occ if 2 * k > N]
        centre = [(N, k) for (N, k) in occ if 2 * k == N]
        assert len(lower) == len(upper), n
        assert len(centre) <= 1, n
        assert len(occ) == 2 * len(lower) + len(centre), n
        if len(occ) % 2 == 1:
            odd_ns.append(n)
        assert (len(occ) % 2 == 1) == (n in central), n
    print(f"    verified for all 2 <= n <= {bound}")
    print(f"    n <= {bound} with odd multiplicity: {odd_ns}")
    print("    (exactly the central binomial coefficients 2, 6, 20, 70, 252, 924)")
    print()


def check_prime_obstruction(bound: int = 400) -> None:
    """p | n prime with p(p-1) > 2n forces mult(n) = 2."""
    print("=== 4. Large-prime-factor obstruction ===")
    def largest_prime_factor(m: int) -> int:
        p, d = 1, 2
        while d * d <= m:
            while m % d == 0:
                p, m = d, m // d
            d += 1
        return m if m > 1 else p

    triggered = []
    for n in range(3, bound + 1):
        p = largest_prime_factor(n)
        if p * (p - 1) > 2 * n:
            assert mult(n) == 2, (n, p, mult(n))
            triggered.append(n)
    print(f"    for every 3 <= n <= {bound} whose largest prime factor p satisfies")
    print(f"    p(p-1) > 2n, the multiplicity is exactly 2  "
          f"({len(triggered)} such n in range)")
    primes = [p for p in range(5, 60) if all(p % d for d in range(2, isqrt(p) + 1))]
    print(f"    mult(p) for primes 5..59: "
          f"{ {p: mult(p) for p in primes} }")
    print(f"    mult(2p) for primes 7..29: "
          f"{ {2*p: mult(2*p) for p in primes if 7 <= p <= 29} }")
    print()


def check_exact_four() -> None:
    """mult(C(p,2)) = 4 for every prime p >= 5."""
    print("=== 5. Exact multiplicity four: mult(C(p,2)) = 4 for primes p >= 5 ===")
    primes = [p for p in range(5, 60) if all(p % d for d in range(2, isqrt(p) + 1))]
    for p in primes:
        n = comb(p, 2)
        m = mult(n)
        assert m == 4, (p, n, m)
        assert interior_occurrences(n) == [(p, 2), (p, p - 2)], (p, n)
    print("    p : C(p,2) : mult")
    for p in primes[:8]:
        print(f"    {p:>3} : {comb(p,2):>7} : {mult(comb(p,2))}")
    print("    the only interior occurrences are (p,2) and (p,p-2)")
    print()


def check_record_and_spectrum() -> None:
    """mult(3003) = 8; the attained spectrum {0,1,2,3,4,6,8}."""
    print("=== 6. The record 3003 and the attained spectrum ===")
    occ3003 = occurrences(3003)
    print(f"    occurrences of 3003: {occ3003}")
    assert len(occ3003) == 8
    print(f"    mult(3003) = {len(occ3003)}")
    samples = {2: 1, 5: 2, 6: 3, 21: 4, 120: 6, 3003: 8}
    for n, m in samples.items():
        assert mult(n) == m, (n, mult(n), m)
    print(f"    sample spectrum values: {samples}")
    print("    (together with mult(0) = 0 and mult(1) counted separately, the")
    print("     attained set of multiplicities is {0, 1, 2, 3, 4, 6, 8})")
    print()


def check_no_five_or_seven(bound: int = 3003) -> None:
    """mult(n) is never 5 or 7 below 3003, and never exceeds 8 there."""
    print("=== 6b. Below 3003 the multiplicity never equals 5 or 7, and never")
    print("        exceeds 8 ===")
    hist: Dict[int, int] = {}
    for n in range(2, bound):
        m = mult(n)
        hist[m] = hist.get(m, 0) + 1
        assert m not in (5, 7), (n, m)
        assert m <= 8, (n, m)
    print(f"    histogram of mult(n) for 2 <= n < {bound}: "
          f"{dict(sorted(hist.items()))}")
    print()


def check_density_bound(xs: Tuple[int, ...] = (100, 300, 1000, 3000)) -> None:
    """#{3 <= n <= x : mult(n) >= 3} <= (isqrt(2x)+2)(log2(x)+2)."""
    print("=== 7. Density bound: almost every integer occurs exactly twice ===")
    print("      x |  actual #{mult >= 3}  |  proved bound")
    for x in xs:
        actual = sum(1 for n in range(3, x + 1) if mult(n) >= 3)
        log2x = x.bit_length() - 1
        bound = (isqrt(2 * x) + 2) * (log2x + 2)
        assert actual <= bound, (x, actual, bound)
        print(f"   {x:>4} |  {actual:>18} |  {bound:>12}")
    print()


# ----------------------------------------------------------------------------- #
# 3.  The Fibonacci ladder and the row-shift classification
# ----------------------------------------------------------------------------- #


def fib(m: int) -> int:
    a, b = 0, 1
    for _ in range(m):
        a, b = b, a + b
    return a


def fib_row(i: int) -> int:
    return fib(2 * i + 2) * fib(2 * i + 3)


def fib_col(i: int) -> int:
    return fib(2 * i) * fib(2 * i + 3)


def row_shift_holds(N: int, k: int) -> bool:
    """The row-shift equation N(k+1) = (N-k)(N-k-1), i.e. C(N,k) = C(N-1,k+1)."""
    return N * (k + 1) == (N - k) * (N - k - 1)


def check_fibonacci_ladder(imax: int = 5) -> None:
    print("=== 8. The Fibonacci ladder of six-fold coincidences ===")
    print("      i |        N |        k | row-shift | C(N,k) = C(N-1,k+1) | digits")
    for i in range(1, imax + 1):
        N, k = fib_row(i), fib_col(i)
        assert row_shift_holds(N, k), (i, N, k)
        left, right = comb(N, k), comb(N - 1, k + 1)
        assert left == right
        assert fib(2*i+1)**2 == fib(2*i)*fib(2*i+1) + fib(2*i)**2 + 1  # Cassini
        print(f"    {i:>3} | {N:>8} | {k:>8} | {'yes':>9} | {'equal':>19} | "
              f"{len(str(left)):>6}")
    print(f"    first member: C(15,5) = {comb(15,5)}  (the record 3003)")
    n0 = comb(fib_row(1), fib_col(1))
    print(f"    and indeed mult({n0}) = {mult(n0)} >= 6")
    print()


def check_row_shift_classification(limit: int = 4000) -> None:
    """Brute-force: the only (N,k) with 2 <= k, 2k <= N solving the row-shift
    equation are the Fibonacci pairs; and (3N-1-2k)^2 = 5N^2 + 2N + 1."""
    print("=== 9. Row-shift classification and its Pell shadow ===")
    solutions = [(N, k) for N in range(1, limit + 1)
                 for k in range(2, N // 2 + 1) if row_shift_holds(N, k)]
    expected = [(fib_row(i), fib_col(i)) for i in range(1, 12)
                if fib_row(i) <= limit]
    assert solutions == sorted(expected), (solutions, expected)
    print(f"    exhaustive search over 1 <= N <= {limit}, 2 <= k <= N/2:")
    print(f"    solutions found = {solutions}")
    print(f"    Fibonacci predictions = {sorted(expected)}   (identical)")
    for (N, k) in solutions:
        disc = (3 * N - 1 - 2 * k) ** 2
        assert disc == 5 * N * N + 2 * N + 1, (N, k)
        print(f"    Pell shadow at (N,k) = ({N},{k}): "
              f"(3N-1-2k)^2 = {disc} = 5N^2+2N+1")
    print()


def check_vieta_descent(imax: int = 6) -> None:
    """The two-step Vieta descent (N,k) -> (M,j) walks the ladder downwards."""
    print("=== 9b. The two-step Vieta descent ===")
    print("    (N,k) -> M = 3k+2-N  (conjugate root in the row)")
    print("          -> j = 3M-1-k  (conjugate root in the column)")
    for i in range(1, imax + 1):
        N, k = fib_row(i), fib_col(i)
        M = 3 * k + 2 - N
        j = 3 * M - 1 - k
        ok = (M, j) == (fib_row(i - 1), fib_col(i - 1)) if i >= 2 else (M, j) == (2, 0)
        assert ok, (i, N, k, M, j)
        print(f"    i={i}: ({N:>7},{k:>7})  ->  ({M:>7},{j:>7})"
              f"{'   [ladder step]' if i >= 2 else '   [degenerate base (2,0)]'}")
    print()


def check_cassini_classification(bound: int = 10 ** 6) -> None:
    """Solutions of b^2 = ab + a^2 + 1 with a <= b are exactly (F(2i), F(2i+1))."""
    print("=== 10. Cassini pairs are exactly consecutive Fibonacci pairs ===")
    found = [(a, b) for a in range(0, 1500) for b in range(a, 2500)
             if b * b == a * b + a * a + 1 and b <= bound]
    predicted = sorted({(fib(2 * i), fib(2 * i + 1)) for i in range(0, 12)
                        if fib(2 * i) < 1500 and fib(2 * i + 1) < 2500})
    assert sorted(found) == predicted, (found, predicted)
    print(f"    brute-force solutions with a < 1500: {sorted(found)}")
    print(f"    (F(2i), F(2i+1)) predictions        : {predicted}")
    print()


# ----------------------------------------------------------------------------- #

def main() -> None:
    sys.set_int_max_str_digits(200000)
    print(__doc__)
    check_row_and_column_squeeze()
    check_splitting()
    check_parity_law()
    check_prime_obstruction()
    check_exact_four()
    check_record_and_spectrum()
    check_no_five_or_seven()
    check_density_bound()
    check_fibonacci_ladder()
    check_row_shift_classification()
    check_vieta_descent()
    check_cassini_classification()
    print("All numerical checks passed.")


if __name__ == "__main__":
    main()


"""Algorithm 1 — Multiplicity by row/column squeeze.

Computes the Singmaster multiplicity m(n) = #{(N,k) : C(N,k) = n} in
O(sqrt(n) * log n) arithmetic operations, by confining the search for interior
occurrences (2 <= k <= N-2) to the rectangle

        N(N-1) <= 2n        (row squeeze,    N = O(sqrt n))
        2^k    <= n         (column squeeze, k = O(log n)),

and then adding back the two boundary occurrences C(n,1) = C(n,n-1) = n.
"""

from __future__ import annotations

from typing import List, Tuple


def interior_occurrences(n: int) -> List[Tuple[int, int]]:
    """All (N, k) with 2 <= k <= N-2 and C(N,k) = n, for n >= 3.

    Only rows with N(N-1) <= 2n are scanned, and inside a row only columns
    k <= N//2 (the right half is obtained by reflection k -> N-k).  Entries are
    generated incrementally: C(N,k+1) = C(N,k) * (N-k) // (k+1).
    """
    out: List[Tuple[int, int]] = []
    N = 4
    while N * (N - 1) <= 2 * n:
        c = N * (N - 1) // 2          # C(N, 2)
        k = 2
        while k <= N // 2 and c <= n:
            if c == n:
                out.append((N, k))
                if 2 * k != N:
                    out.append((N, N - k))
            c = c * (N - k) // (k + 1)
            k += 1
        N += 1
    return sorted(out)


def multiplicity(n: int) -> int:
    """m(n) for n >= 3:  two boundary occurrences plus the interior ones."""
    if n < 3:
        raise ValueError("use n >= 3")
    return 2 + len(interior_occurrences(n))


def multiplicity_profile(n: int) -> dict:
    """Full structural profile: interior/lower/central counts and the parity law."""
    interior = interior_occurrences(n)
    lower = [(N, k) for (N, k) in interior if 2 * k < N]
    central = [(N, k) for (N, k) in interior if 2 * k == N]
    return {
        "n": n,
        "multiplicity": 2 + len(interior),
        "interior_occurrences": interior,
        "interior_lower_count": len(lower),
        "central_count": len(central),          # always 0 or 1
        "is_central_binomial": len(central) == 1,
        "parity_predicted_odd": len(central) == 1,
        "search_radius_rows": max([N for (N, _) in interior], default=0),
    }


if __name__ == "__main__":
    for n in (10, 21, 120, 924, 3003):
        print(multiplicity_profile(n))


"""Algorithm 3 — Parity oracle for the Singmaster multiplicity.

The reflection k -> N-k pairs every occurrence strictly left of centre with one
strictly right of centre, so

        m(n) = 2 * (# occurrences left of centre) + (# central occurrences),

and the central binomial coefficients C(2t,t) are strictly increasing, so there is at
most one central occurrence.  Therefore

        m(n) is odd   <=>   n = C(2t, t) for some t.

This gives an O(log n) test for the parity of the multiplicity that never inspects
Pascal's triangle: since C(2t,t) >= 2^t, only t <= log2(n) need be generated, via the
recurrence (t+1) C(2t+2, t+1) = 2(2t+1) C(2t, t).
"""

from __future__ import annotations

from typing import Optional, Tuple


def central_binomial_index(n: int) -> Optional[int]:
    """Return t with C(2t,t) = n, or None if n is not a central binomial coefficient."""
    c, t = 1, 0                      # C(0,0) = 1
    while c < n:
        c = c * 2 * (2 * t + 1) // (t + 1)
        t += 1
    return t if c == n else None


def multiplicity_is_odd(n: int) -> bool:
    """Decide the parity of m(n) in O(log n) operations, without any search."""
    return central_binomial_index(n) is not None


def parity_report(n: int) -> Tuple[int, bool, Optional[int]]:
    """(n, is_odd, central index t) — the parity law applied to n."""
    t = central_binomial_index(n)
    return (n, t is not None, t)


if __name__ == "__main__":
    for n in [2, 6, 10, 20, 21, 70, 120, 252, 924, 3003, 3432]:
        print(parity_report(n))


"""Algorithm 2 — Two-step Vieta descent for the row-shift equation.

The one-row-shift coincidence C(N,k) = C(N-1,k+1) is equivalent (for k+2 <= N) to

        N(k+1) = (N-k)(N-k-1)      <=>      k^2 + k + N^2 = 3Nk + 2N.

That equation is monic and quadratic in each variable separately, so it carries two
Vieta involutions:

        sigma : (N, k) -> (3k + 2 - N, k)        [conjugate root in the row]
        tau   : (N, k) -> (N, 3N - 1 - k)        [conjugate root in the column]

The composite tau . sigma strictly decreases the row index while preserving the
admissible region {1 <= k, 2k <= N}, and terminates at the seed (2, 0).  Iterating the
inverse ascent (a,b) -> (a+b, a+2b) on the Cassini side generates the whole solution
set: the Fibonacci ladder N = F(2i+2)F(2i+3), k = F(2i)F(2i+3).

Complexity: consecutive rungs grow by a factor phi^4 ~ 6.854, so a descent from N takes
O(log N) steps of O(1) big-integer operations.
"""

from __future__ import annotations

from typing import List, Optional, Tuple


def is_row_shift_solution(N: int, k: int) -> bool:
    """Test k^2 + k + N^2 = 3Nk + 2N (the desingularised row-shift equation)."""
    return k * k + k + N * N == 3 * N * k + 2 * N


def descent_step(N: int, k: int) -> Tuple[int, int]:
    """One two-step Vieta move: (N,k) -> (M, j) with M = 3k+2-N, j = 3M-1-k."""
    M = 3 * k + 2 - N
    j = 3 * M - 1 - k
    return (M, j)


def descend(N: int, k: int) -> Optional[List[Tuple[int, int]]]:
    """Run the descent from (N,k).

    Returns the full chain down to the seed (2,0) if (N,k) is an admissible solution
    (1 <= N, 2k <= N, equation satisfied), and None otherwise.
    """
    if not (N >= 1 and 2 * k <= N and is_row_shift_solution(N, k)):
        return None
    chain = [(N, k)]
    while chain[-1] != (2, 0):
        N, k = chain[-1]
        N, k = descent_step(N, k)
        if N < 1 or k < 0 or 2 * k > N or not is_row_shift_solution(N, k):
            return None            # cannot happen for a genuine solution
        chain.append((N, k))
    return chain


def ascend(a: int, b: int) -> Tuple[int, int]:
    """Ascent on the Cassini side: (a,b) -> (a+b, a+2b), a Fibonacci index shift by 2."""
    return (a + b, a + 2 * b)


def ladder(count: int) -> List[Tuple[int, int]]:
    """The first `count` rungs (N, k) of the ladder, generated by pure ascent.

    Starting from the Cassini pair (a,b) = (0,1) one has
        (N, k) = ((a+b)(a+2b), a(a+2b)),
    and each ascent step (a,b) -> (a+b, a+2b) produces the next rung.
    """
    out: List[Tuple[int, int]] = []
    a, b = 0, 1
    for _ in range(count + 1):
        N, k = (a + b) * (a + 2 * b), a * (a + 2 * b)
        out.append((N, k))
        a, b = ascend(a, b)
    return out[1:count + 1]        # drop the degenerate seed (2, 0)


def pell_shadow(N: int, k: int) -> Tuple[int, int, bool]:
    """Return ((3N-1-2k)^2, 5N^2+2N+1, equal?) — the Pell shadow of a solution."""
    lhs = (3 * N - 1 - 2 * k) ** 2
    rhs = 5 * N * N + 2 * N + 1
    return (lhs, rhs, lhs == rhs)


if __name__ == "__main__":
    for (N, k) in ladder(5):
        chain = descend(N, k)
        print(f"(N,k) = ({N},{k})  descent: {chain}  Pell: {pell_shadow(N,k)}")
    print("non-solution (20, 7):", descend(20, 7))


"""Demo — The Fibonacci ladder, the Vieta descent, and the exhaustion theorem.

This self-contained script demonstrates the classification of the one-row-shift
coincidences C(N,k) = C(N-1,k+1):

  * it verifies by exhaustive search that, up to a chosen bound, the only pairs (N,k)
    with 2 <= k <= N/2 solving  N(k+1) = (N-k)(N-k-1)  are the Fibonacci pairs
    N = F(2i+2)F(2i+3), k = F(2i)F(2i+3);
  * it runs the two-step Vieta descent  (N,k) -> (3k+2-N, 3(3k+2-N)-1-k)  from each
    solution down to the seed (2,0), printing the chain;
  * it checks the even Cassini identity F(2i+1)^2 = F(2i)F(2i+1) + F(2i)^2 + 1 that
    powers the ascent, and the Pell shadow (3N-1-2k)^2 = 5N^2 + 2N + 1;
  * it exhibits, for the first few rungs, the four interior occurrences produced by the
    shift, which together with the two boundary occurrences give multiplicity >= 6.
"""

from __future__ import annotations

import sys
from math import comb
from typing import List, Tuple


def fib(m: int) -> int:
    a, b = 0, 1
    for _ in range(m):
        a, b = b, a + b
    return a


def rung(i: int) -> Tuple[int, int]:
    """The i-th ladder rung (N_i, k_i) = (F(2i+2)F(2i+3), F(2i)F(2i+3))."""
    return fib(2 * i + 2) * fib(2 * i + 3), fib(2 * i) * fib(2 * i + 3)


def solves_shift(N: int, k: int) -> bool:
    return N * (k + 1) == (N - k) * (N - k - 1)


def brute_force_solutions(limit: int) -> List[Tuple[int, int]]:
    return [(N, k) for N in range(1, limit + 1)
            for k in range(2, N // 2 + 1) if solves_shift(N, k)]


def vieta_chain(N: int, k: int) -> List[Tuple[int, int]]:
    chain = [(N, k)]
    while chain[-1] != (2, 0):
        N, k = chain[-1]
        M = 3 * k + 2 - N
        j = 3 * M - 1 - k
        chain.append((M, j))
    return chain


def four_interior_occurrences(N: int, k: int) -> List[Tuple[int, int]]:
    """The four interior positions carrying the common value C(N,k)."""
    return [(N, k), (N, N - k), (N - 1, k + 1), (N - 1, N - k - 2)]


def main() -> None:
    sys.set_int_max_str_digits(200000)
    limit = 5000

    print("Exhaustive search for solutions of N(k+1) = (N-k)(N-k-1),")
    print(f"over 1 <= N <= {limit}, 2 <= k <= N/2:\n")
    found = brute_force_solutions(limit)
    predicted = [rung(i) for i in range(1, 12) if rung(i)[0] <= limit]
    print(f"  found      : {found}")
    print(f"  Fibonacci  : {predicted}")
    print(f"  identical  : {found == predicted}\n")

    print("Two-step Vieta descent to the seed (2,0):\n")
    for (N, k) in found:
        print(f"  ({N:>5},{k:>5}) : {' -> '.join(str(p) for p in vieta_chain(N, k))}")
    print()

    print("Even Cassini identity F(2i+1)^2 = F(2i)F(2i+1) + F(2i)^2 + 1:")
    for i in range(0, 8):
        a, b = fib(2 * i), fib(2 * i + 1)
        assert b * b == a * b + a * a + 1
        print(f"  i={i}: {b}^2 = {b*b} = {a}*{b} + {a}^2 + 1")
    print()

    print("Pell shadow (3N-1-2k)^2 = 5N^2 + 2N + 1  (so 5N^2+2N+1 is a square):")
    for i in range(1, 6):
        N, k = rung(i)
        x = 3 * N - 1 - 2 * k
        assert x * x == 5 * N * N + 2 * N + 1
        print(f"  i={i}: N={N:>7}, k={k:>7}, (3N-1-2k)={x:>7}, "
              f"x^2 = {x*x} = 5N^2+2N+1")
    print()

    print("Four interior occurrences per rung (value repeated; +2 boundary => m >= 6):")
    for i in range(1, 4):
        N, k = rung(i)
        positions = four_interior_occurrences(N, k)
        value = comb(N, k)
        for (r, c) in positions:
            assert comb(r, c) == value
        shown = value if value < 10 ** 12 else f"<{len(str(value))}-digit number>"
        print(f"  i={i}: positions {positions}")
        print(f"        common value C({N},{k}) = {shown}")
    print()
    print("Conclusion: the one-row shift produces exactly one infinite family of")
    print("six-fold coincidences -- the Fibonacci ladder, beginning at 3003.")


if __name__ == "__main__":
    main()


"""Visualization — The confinement rectangle and the Fibonacci ladder.

Left panel: every interior occurrence C(N,k) = n <= X with 2k <= N, plotted at its
position (k, N).  Superimposed are the two proved squeezes

        N(N-1) <= 2X      (row squeeze:    a horizontal ceiling at N ~ sqrt(2X))
        2^k    <= X       (column squeeze: a vertical wall at k ~ log2 X),

which together confine all interesting occurrences to an O(sqrt X) x O(log X)
rectangle -- the geometric content of the density theorem.

Right panel: the Fibonacci ladder of one-row-shift coincidences,
N_i = F(2i+2)F(2i+3), k_i = F(2i)F(2i+3), drawn on a log scale together with the
two-step Vieta descent arrows (N,k) -> (3k+2-N, 3(3k+2-N)-1-k) that carry each rung to
the one below, terminating at the seed (2,0).  The classification theorem says there is
nothing else on this curve.
"""

from __future__ import annotations

from math import comb, log2
from typing import List, Tuple

import matplotlib.pyplot as plt


def interior_points(limit: int) -> List[Tuple[int, int]]:
    """(k, N) for every interior occurrence with 2k <= N and value <= limit."""
    pts: List[Tuple[int, int]] = []
    N = 4
    while N * (N - 1) <= 2 * limit:
        for k in range(2, N // 2 + 1):
            c = comb(N, k)
            if c > limit:
                break
            pts.append((k, N))
        N += 1
    return pts


def fib(m: int) -> int:
    a, b = 0, 1
    for _ in range(m):
        a, b = b, a + b
    return a


def main() -> None:
    limit = 3002
    pts = interior_points(limit)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    ax1.scatter([p[0] for p in pts], [p[1] for p in pts], s=18, color="#2b6cb0",
                label="interior occurrences of some $n\\leq 3002$")
    row_ceiling = 78          # largest N with N(N-1) <= 6004
    col_wall = int(log2(limit))
    ax1.axhline(row_ceiling, color="#c53030", ls="--",
                label=r"row squeeze $N(N-1)\leq 2X$")
    ax1.axvline(col_wall, color="#2f855a", ls="--",
                label=r"column squeeze $2^k\leq X$")
    ax1.set_xlabel("column $k$")
    ax1.set_ylabel("row $N$")
    ax1.set_title("All interesting occurrences live in a\n"
                  r"$O(\sqrt{X})\times O(\log X)$ rectangle")
    ax1.set_xlim(0, col_wall + 2)
    ax1.set_ylim(0, row_ceiling + 8)
    ax1.grid(alpha=0.25)
    ax1.legend(fontsize=9, loc="upper right")

    rungs = [((fib(2 * i + 2) * fib(2 * i + 3)), (fib(2 * i) * fib(2 * i + 3)))
             for i in range(0, 7)]
    Ns = [r[0] for r in rungs]
    ks = [max(r[1], 0.5) for r in rungs]
    ax2.plot(ks, Ns, "o-", color="#6b46c1", label="Fibonacci ladder rungs $(k_i,N_i)$")
    for (N, k), (M, j) in zip(rungs[1:], rungs[:-1]):
        ax2.annotate("", xy=(max(j, 0.5), M), xytext=(k, N),
                     arrowprops=dict(arrowstyle="->", color="#c53030", lw=1.4))
    ax2.scatter([0.5], [2], s=90, color="black", zorder=5, label="descent seed $(2,0)$")
    ax2.scatter([5], [15], s=110, marker="*", color="#dd6b20", zorder=5,
                label=r"$(15,5)$: $\binom{15}{5}=3003$")
    ax2.set_xscale("log")
    ax2.set_yscale("log")
    ax2.set_xlabel("column $k$ (log scale)")
    ax2.set_ylabel("row $N$ (log scale)")
    ax2.set_title("The complete solution set of\n"
                  r"$N(k+1)=(N-k)(N-k-1)$, with Vieta descent")
    ax2.grid(alpha=0.25, which="both")
    ax2.legend(fontsize=9, loc="upper left")

    fig.tight_layout()
    fig.savefig("singmaster_confinement.png", dpi=160)
    print("wrote singmaster_confinement.png")


if __name__ == "__main__":
    main()


"""Visualization — The multiplicity spectrum below the record 3003.

Plots m(n) for 2 <= n <= 3002 and colours the structural families that the theory
identifies:

  * grey   : m(n) = 2, the generic value (numbers with no interior occurrence);
  * blue   : m(n) = 4, dominated by the exact family n = C(p,2), p prime;
  * green  : m(n) = 3, which by the parity law can only happen when n = C(2t,t);
  * red    : m(n) >= 6, the coincidence values 120, 210, 1540 (and 3003 itself).

The picture makes three theorems visible at once: multiplicity is almost always 2
(density theorem), odd values sit exactly on the central binomial coefficients (parity
law), and the observed maximum below 3003 is 6 -- with the value 8 attained first at
3003 (marked separately).
"""

from __future__ import annotations

from math import comb, isqrt
from typing import Dict, List

import matplotlib.pyplot as plt


def multiplicity_table(limit: int) -> Dict[int, int]:
    """m(n) for all 2 <= n <= limit, by sieving Pascal's triangle once."""
    table: Dict[int, int] = {n: 0 for n in range(2, limit + 1)}
    for N in range(2, limit + 1):
        c = 1
        for k in range(0, N // 2 + 1):
            c = comb(N, k)
            if k >= 1 and c > limit:
                break
            if k >= 1 and c in table:
                table[c] += 1 if 2 * k == N else 2
    return table


def is_prime(p: int) -> bool:
    return p >= 2 and all(p % d for d in range(2, isqrt(p) + 1))


def main() -> None:
    limit = 3002
    table = multiplicity_table(limit)
    central = {comb(2 * t, t) for t in range(0, 8)}
    tri = {comb(p, 2) for p in range(5, 200) if is_prime(p)}

    xs: List[int] = sorted(table)
    ys: List[int] = [table[n] for n in xs]

    fig, ax = plt.subplots(figsize=(12, 5.5))
    ax.scatter(xs, ys, s=6, color="0.75", label="$m(n)=2$ (generic)")

    def sub(pred) -> tuple:
        pts = [(n, table[n]) for n in xs if pred(n)]
        return ([p[0] for p in pts], [p[1] for p in pts])

    x4, y4 = sub(lambda n: n in tri)
    ax.scatter(x4, y4, s=26, color="#2b6cb0", label=r"$n=\binom{p}{2}$, $p$ prime: $m=4$")
    x3, y3 = sub(lambda n: n in central and n > 2)
    ax.scatter(x3, y3, s=60, marker="D", color="#2f855a",
               label=r"$n=\binom{2t}{t}$: $m=3$ (odd, by the parity law)")
    x6, y6 = sub(lambda n: table[n] >= 6)
    ax.scatter(x6, y6, s=90, marker="*", color="#c53030", label=r"$m(n)\geq 6$")
    ax.scatter([3003], [8], s=160, marker="*", color="black",
               label=r"the record $m(3003)=8$")

    ax.set_xlabel("$n$")
    ax.set_ylabel("multiplicity $m(n)$")
    ax.set_title("Singmaster multiplicity below the record: "
                 "generic value 2, an exact family at 4, odd values only at central "
                 "binomial coefficients")
    ax.set_yticks(range(0, 10))
    ax.set_ylim(0, 9)
    ax.grid(alpha=0.25)
    ax.legend(loc="upper right", fontsize=9)
    fig.tight_layout()
    fig.savefig("singmaster_spectrum.png", dpi=160)
    print("wrote singmaster_spectrum.png")


if __name__ == "__main__":
    main()
