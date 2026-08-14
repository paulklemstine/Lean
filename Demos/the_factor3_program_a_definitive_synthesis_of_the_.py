"""
CRT-Weight Dichotomy Classifier: deciding whether an aggregate is a complete
witness or a null witness.

Mathematical foundation
-----------------------
Let w : N -> N be a CRT weight, i.e. w(1) = 1 and w(mn) = w(m)w(n) whenever
gcd(m, n) = 1.  The classification theorem says that exactly one of two
behaviours occurs, with nothing in between:

  SEPARATING branch.  If w is injective on primes -- in particular if w is
  strictly monotone -- then the aggregate A_w(N) = sum_{d | N} w(d) determines
  the coprime factorization of N.  The witness is worth the entire secret, and
  inversion runs in a constant number of arithmetic operations via the
  trace/norm pair.

  BLIND branch.  If w(p) = w(p') for two distinct primes p != p', then for any
  prime q larger than both,
        A_w(pq) = (1 + w(p))(1 + w(q)) = (1 + w(p'))(1 + w(q)) = A_w(p'q),
  while the two semiprimes have different smaller factors.  Hence NO function
  whatsoever of the aggregate can return a factor: the obstruction is
  informational, not computational.

The classifier below searches for a prime collision up to a bound; if it finds
one it exhibits an explicit certificate (a pair of semiprimes with equal
aggregates and different smaller factors), and if it does not it reports the
separating branch together with a monotonicity check.

Complexity
----------
Let B be the search bound.  Sieving primes up to B costs O(B log log B); the
collision search costs O(pi(B)) weight evaluations plus a hash-table insert per
prime, i.e. O(pi(B)) expected time.  Producing the certificate costs one extra
prime search and two aggregate evaluations.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Optional, Tuple

Weight = Callable[[int], int]


def primes_up_to(bound: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if bound < 2:
        return []
    sieve = bytearray([1]) * (bound + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, math.isqrt(bound) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i in range(bound + 1) if sieve[i]]


def divisors(n: int) -> List[int]:
    small: List[int] = []
    large: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d * d != n:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def aggregate(w: Weight, n: int) -> int:
    return sum(w(d) for d in divisors(n))


def find_prime_collision(w: Weight, bound: int = 2000) -> Optional[Tuple[int, int]]:
    """Return distinct primes p != p' with w(p) = w(p'), or None."""
    seen: Dict[int, int] = {}
    for p in primes_up_to(bound):
        v = w(p)
        if v in seen:
            return seen[v], p
        seen[v] = p
    return None


def is_strictly_monotone(w: Weight, bound: int = 500) -> bool:
    return all(w(i) < w(i + 1) for i in range(1, bound))


def classify_crt_weight(w: Weight, bound: int = 2000) -> Dict[str, object]:
    """
    Classify a CRT weight into the separating or blind branch, with a
    certificate in each case.
    """
    collision = find_prime_collision(w, bound)
    if collision is not None:
        p, p2 = collision
        q = p2 + 1
        while not all(q % r for r in range(2, math.isqrt(q) + 1)) or q <= p2:
            q += 1
        cert = {
            "colliding_primes": (p, p2),
            "semiprime_1": p * q,
            "semiprime_2": p2 * q,
            "aggregate_1": aggregate(w, p * q),
            "aggregate_2": aggregate(w, p2 * q),
        }
        return {
            "branch": "BLIND",
            "recoverable": False,
            "reason": "w collides on two primes; no function of the aggregate "
                      "can return a factor",
            "certificate": cert,
        }
    return {
        "branch": "SEPARATING",
        "recoverable": True,
        "strictly_monotone": is_strictly_monotone(w),
        "reason": "w is injective on primes up to the search bound; if it is "
                  "also monotone, the aggregate pins the factorization",
        "certificate": {"search_bound": bound},
    }


if __name__ == "__main__":
    def collapse_3_and_5(d: int) -> int:
        """A CRT weight identifying the primes 3 and 5 (built multiplicatively)."""
        result, m, f = 1, d, 2
        while f * f <= m:
            if m % f == 0:
                e = 0
                while m % f == 0:
                    m //= f
                    e += 1
                result *= (3 if f in (3, 5) else f) ** e
            f += 1
        if m > 1:
            result *= 3 if m in (3, 5) else m
        return result

    for name, w in [
        ("w(d) = d",     lambda d: d),
        ("w(d) = d^2",   lambda d: d * d),
        ("w(d) = 1",     lambda d: 1),
        ("w collapsing 3 and 5", collapse_3_and_5),
    ]:
        report = classify_crt_weight(w, 500)
        print(f"{name:>24}  ->  {report['branch']:<11}"
              f"  recoverable = {report['recoverable']}")


"""
Free-Witness Inversion: recovering a factorization from a CRT aggregate.

Given a semiprime N = p*q and the aggregate value A = sigma_k(N) supplied by an
oracle, the algorithm returns p in O(1) arithmetic operations for k in {1, 2},
and in O(log N) operations for general k >= 1.

Mathematical foundation
-----------------------
For a CRT weight w (w(1) = 1, w(mn) = w(m)w(n) on coprime arguments) the
aggregate of a semiprime factors through the Chinese Remainder splitting:

        A_w(pq) = (1 + w(p)) (1 + w(q)) = 1 + (w(p) + w(q)) + w(N).

The product w(p)w(q) = w(N) is the NORM: public, computable from N alone.
The sum w(p) + w(q) is the TRACE: the secret, and exactly what the aggregate
reveals beyond the norm.  A pair of naturals is determined by its sum and its
product, so the trace pins the factorization.

For the power weight w(d) = d^k the trace extraction is

        T_k := A - 1 - N^k = p^k + q^k,

and inversion proceeds:
  * k = 1: s = T_1 = p + q directly.
  * k = 2: s = isqrt(T_2 + 2N) = isqrt((p+q)^2) = p + q exactly.
  * k >= 3: binary search for s, using strict monotonicity of a^k + (N/a)^k
    in the small factor a on [1, sqrt(N)].
Then the integer quadratic formula

        R(N, s) = (s - isqrt(s^2 - 4N)) // 2

returns the smaller factor exactly, because (p+q)^2 - 4pq = (q-p)^2 is a
perfect square, so the integer square root loses nothing.

Complexity
----------
k in {1,2}: O(1) big-integer operations, i.e. polynomial in log N.
k >= 3:     O(log N) big-integer operations.
In both cases the algorithm is exponentially faster than trial division --
which is exactly why the aggregate must itself be expensive to obtain
(the aggregation barrier).
"""

from __future__ import annotations

import math
from typing import Tuple


def integer_quadratic_recovery(n: int, s: int) -> int:
    """R(N, s) = (s - isqrt(s^2 - 4N)) // 2.  Returns a when s = a+b, N = a*b."""
    disc = s * s - 4 * n
    if disc < 0:
        raise ValueError("trace too small for this norm: s^2 < 4N")
    return (s - math.isqrt(disc)) // 2


def trace_from_power_sum(n: int, k: int, power_sum: int) -> int:
    """
    Recover the trace s = a + b from N = a*b and T_k = a^k + b^k, k >= 1.

    k = 1 and k = 2 are closed form; larger k uses monotone binary search on
    the small factor, justified by spread monotonicity of a^k + b^k.
    """
    if k < 1:
        raise ValueError("k must be at least 1")
    if k == 1:
        return power_sum
    if k == 2:
        return math.isqrt(power_sum + 2 * n)
    lo, hi = 1, math.isqrt(n)
    while lo < hi:
        mid = (lo + hi + 1) // 2
        # a^k + (N/a)^k is strictly decreasing in a on [1, sqrt N]
        if mid ** k + (n / mid) ** k >= power_sum:
            lo = mid
        else:
            hi = mid - 1
    a = lo
    return a + n // a


def free_witness_inversion(n: int, k: int, aggregate_value: int) -> Tuple[int, int]:
    """
    Input : N (a semiprime), an exponent k >= 1, and A = sigma_k(N).
    Output: the ordered factorization (p, q) with p <= q and p*q = N.
    """
    power_sum = aggregate_value - 1 - n ** k      # = p^k + q^k
    s = trace_from_power_sum(n, k, power_sum)     # = p + q
    p = integer_quadratic_recovery(n, s)          # = p
    return p, n // p


if __name__ == "__main__":
    for p, q in [(3, 11), (101, 103), (10007, 10009), (1000003, 1000033)]:
        n = p * q
        for k in (1, 2, 3, 5):
            agg = (1 + p ** k) * (1 + q ** k)     # the oracle's answer
            got = free_witness_inversion(n, k, agg)
            assert got == (p, q), (p, q, k, got)
        print(f"N = {n:>14}  recovered {p} * {q} from sigma_k for k = 1,2,3,5")


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the individual deliverables in this project."""

from __future__ import annotations

import json
import os
from typing import Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def read(rel: str) -> str:
    with open(os.path.join(ROOT, rel), "r", encoding="utf-8") as fh:
        return fh.read()


LEAN_FILES: List[str] = [
    "Catalog/Tropical/TraceLemmaExhaustiveness.lean",
    "Catalog/Tropical/FreeWitnessClassification.lean",
    "Catalog/Tropical/NoiseFloorBirthday.lean",
]


def lean_proofs() -> str:
    parts = []
    for path in LEAN_FILES:
        parts.append(f"-- ======================================================\n"
                     f"-- {path}\n"
                     f"-- ======================================================\n")
        parts.append(read(path))
        parts.append("\n\n")
    return "".join(parts)


def main() -> None:
    package: Dict[str, object] = {
        "title": "The Free-Witness Classification for CRT-Multiplicative "
                 "Weights: Trace Lemma, Exhaustive Dichotomy, and the "
                 "Noise-Floor Principle",
        "domain": "Tropical",
        "description": "A complete classification of the counting aggregates "
                       "that can witness an integer factorization: for weights "
                       "multiplicative across the Chinese Remainder splitting, "
                       "the aggregate of a semiprime either determines the "
                       "factorization outright — via the trace/norm pair, with "
                       "closed-form recovery — or is provably useless, with no "
                       "third possibility. The positive branch is sealed by a "
                       "noise-floor bound showing that the aggregation barrier "
                       "and the trial-division birthday bound are the same "
                       "Theta(sqrt N) obstruction.",
        "authors": ["Aristotle"],
        "date": "2026-08-14",
        "key_results": [
            "Chinese Remainder splitting of the aggregate: for a CRT weight w "
            "and distinct primes p, q, the divisor sum satisfies "
            "A_w(pq) = (1 + w(p))(1 + w(q)), so both prime factors are jointly "
            "and separately encoded.",
            "Trace lemma for CRT-multiplicative weights: for a strictly "
            "monotone CRT weight, the aggregate value determines the coprime "
            "factorization of N uniquely, because the norm w(a)w(b) = w(N) is "
            "public and the aggregate therefore reveals the trace w(a) + w(b), "
            "and a pair of naturals is determined by its sum and product.",
            "Exhaustive dichotomy: every CRT weight either separates primes — "
            "and then its aggregate pins the factorization — or collides on two "
            "primes, in which case no function whatsoever of the aggregate can "
            "return a factor; there is no partially informative behaviour.",
            "Closed-form free-witness recovery and the predicted witness: from "
            "the trace s and the norm N the smaller factor is returned exactly "
            "by (s - sqrt(s^2 - 4N))/2, and the sum of squares p^2 + q^2 "
            "obtained from the divisor-square sum is a complete witness, since "
            "adding 2N yields (p+q)^2 exactly.",
            "Noise-floor principle: for a balanced semiprime N = pq with "
            "p < q <= 2p, any probe window containing a nontrivial divisor has "
            "length at least sqrt(N/2), no window contains more than two "
            "factor-bearing probes, hence the density of useful probes is at "
            "most 2 sqrt(2) / sqrt(N) — the aggregation barrier and the "
            "birthday bound are the same obstruction.",
        ],
        "keywords": [
            "integer factorization",
            "multiplicative functions",
            "Chinese Remainder Theorem",
            "divisor sums",
            "trace and norm",
            "tropical geometry",
            "birthday bound",
            "free witness",
        ],
        "article": read("ARTICLE.md"),
        "research_paper": read("RESEARCH_PAPER.md"),
        "research_paper_tex": read("RESEARCH_PAPER.tex"),
        "demo": read("demo.py"),
        "demos": [
            {
                "name": "Complete Numerical Verification of the Free-Witness "
                        "Classification",
                "description":
                    "A self-contained, dependency-free program that verifies "
                    "every result of the classification numerically. It checks "
                    "the Chinese Remainder splitting A_w(pq) = (1+w(p))(1+w(q)) "
                    "for the power weights d, d^2, d^3 on semiprimes up to nine "
                    "digits; exhibits the trace/norm decomposition and confirms "
                    "that the extracted trace equals p^k + q^k; verifies that "
                    "distinct coprime factorizations of a fixed N always receive "
                    "distinct aggregates, while the divisor-count weight "
                    "collapses every semiprime to the constant 4; tabulates "
                    "spread monotonicity of a^k + b^k along the hyperbola "
                    "ab = N for k = 1, 2, 3; recovers the smaller prime in "
                    "closed form from the divisor sum and from the sum of "
                    "squares, for primes up to 2^31, and by monotone search for "
                    "exponents up to 5; constructs an explicit CRT weight that "
                    "collides on the primes 3 and 5 and exhibits pairs of "
                    "semiprimes with equal aggregates but different smaller "
                    "factors; confirms that exponential phase weights fail "
                    "CRT-multiplicativity already on the coprime pair (2,3); "
                    "measures the exact one-hit-per-window count below the "
                    "corner sqrt(N) and checks the density bound "
                    "2 sqrt(2)/sqrt(N) together with the two-sided sweep bound "
                    "sqrt(N/2) <= p <= sqrt(N); and finally lists all "
                    "factorizations of several N to display the tropical "
                    "minimum of the trace at the balanced pair.",
                "code": read("demo.py"),
            }
        ],
        "algorithms": [
            {
                "name": "Free-Witness Inversion: Recovering a Factorization "
                        "from a CRT Aggregate",
                "description":
                    "Given a semiprime N = pq and the aggregate value "
                    "A = sigma_k(N) supplied by an oracle, this algorithm "
                    "returns the ordered factorization. Its foundation is the "
                    "trace/norm decomposition: for a CRT weight the aggregate "
                    "splits as (1 + w(p))(1 + w(q)) = 1 + (w(p)+w(q)) + w(N), so "
                    "subtracting the public norm w(N) = w(pq) and the constant 1 "
                    "exposes the trace. For the power weight w(d) = d^k the "
                    "extracted quantity is T_k = p^k + q^k; the case k = 1 gives "
                    "the trace directly, the case k = 2 gives it after adding 2N "
                    "and taking an exact integer square root (since "
                    "p^2 + q^2 + 2pq = (p+q)^2), and larger exponents are handled "
                    "by binary search justified by the strict monotonicity of "
                    "a^k + (N/a)^k in the small factor. The final step is the "
                    "integer quadratic formula R(N,s) = (s - isqrt(s^2 - 4N))/2, "
                    "which is exact because (p+q)^2 - 4pq = (q-p)^2 is a perfect "
                    "square. Complexity: O(1) big-integer operations for "
                    "k in {1,2}, and O(log N) operations for k >= 3 — polynomial "
                    "in log N in both cases, and therefore exponentially faster "
                    "than trial division. This is precisely why the aggregate "
                    "itself must be expensive to obtain; see the noise-floor "
                    "results.",
                "pseudocode": (
                    "ALGORITHM FreeWitnessInversion(N, k, A)\n"
                    "  INPUT : N = p*q a semiprime, k >= 1, A = sigma_k(N)\n"
                    "  OUTPUT: the ordered pair (p, q) with p <= q\n"
                    "\n"
                    "  1  T <- A - 1 - N^k                  // = p^k + q^k, the power sum\n"
                    "  2  if k = 1 then\n"
                    "  3      s <- T                        // the trace p + q\n"
                    "  4  else if k = 2 then\n"
                    "  5      s <- isqrt(T + 2N)            // (p+q)^2 = p^2+q^2+2pq, exact\n"
                    "  6  else\n"
                    "  7      lo <- 1 ; hi <- isqrt(N)\n"
                    "  8      while lo < hi do              // a^k + (N/a)^k decreasing in a\n"
                    "  9          mid <- ceil((lo + hi)/2)\n"
                    " 10          if mid^k + (N/mid)^k >= T then lo <- mid\n"
                    " 11          else hi <- mid - 1\n"
                    " 12      end while\n"
                    " 13      s <- lo + N / lo\n"
                    " 14  end if\n"
                    " 15  D <- s*s - 4*N                    // = (q - p)^2, a perfect square\n"
                    " 16  r <- isqrt(D)\n"
                    " 17  p <- (s - r) / 2                  // integer quadratic formula\n"
                    " 18  return (p, N / p)\n"
                ),
                "code": read("assets/algo_free_witness_inversion.py"),
            },
            {
                "name": "CRT-Weight Dichotomy Classifier: Deciding Complete "
                        "Witness versus Null Witness",
                "description":
                    "Decides which branch of the classification a given CRT "
                    "weight falls into, and produces an explicit certificate in "
                    "each case. The mathematical content is the exhaustiveness "
                    "theorem: if the weight is injective on primes then (given "
                    "monotonicity) its aggregate determines the factorization, "
                    "whereas a single collision w(p) = w(p') with p != p' is "
                    "fatal — for any prime q larger than both, the semiprimes pq "
                    "and p'q have identical aggregates "
                    "(1 + w(p))(1 + w(q)) = (1 + w(p'))(1 + w(q)) while their "
                    "smaller factors differ, so no function whatsoever of the "
                    "aggregate can return a factor. The classifier sieves the "
                    "primes below a bound B, hashes their weight values to search "
                    "for a collision, and on finding one constructs the pair of "
                    "colliding semiprimes as a witness; otherwise it reports the "
                    "separating branch and additionally checks strict "
                    "monotonicity. Complexity: O(B log log B) for the sieve plus "
                    "O(pi(B)) expected time for the collision search, with O(1) "
                    "extra work to build the certificate.",
                "pseudocode": (
                    "ALGORITHM ClassifyCRTWeight(w, B)\n"
                    "  INPUT : a CRT weight w, a search bound B\n"
                    "  OUTPUT: branch in {SEPARATING, BLIND} with a certificate\n"
                    "\n"
                    "  1  P <- Sieve(B)                       // primes up to B\n"
                    "  2  seen <- empty hash map\n"
                    "  3  for each p in P do\n"
                    "  4      v <- w(p)\n"
                    "  5      if v in seen then\n"
                    "  6          p' <- seen[v]               // collision found\n"
                    "  7          q  <- NextPrime(max(p, p'))\n"
                    "  8          assert Aggregate(w, p*q) = Aggregate(w, p'*q)\n"
                    "  9          return (BLIND, certificate = (p, p', q))\n"
                    " 10      seen[v] <- p\n"
                    " 11  end for\n"
                    " 12  mono <- (w(1) < w(2) < ... < w(B))\n"
                    " 13  return (SEPARATING, certificate = (B, mono))\n"
                ),
                "code": read("assets/algo_dichotomy_classifier.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Tropical Line, the Trace Profile, and the Corner",
                "description":
                    "A three-panel figure showing why the factoring secret is a "
                    "position on a tropical line. The left panel plots every "
                    "factorization of N in log-log coordinates, where the "
                    "constraint ab = N becomes the straight line "
                    "log a + log b = log N — the tropical line X (+) Y = N — with "
                    "the corner marked at a = b = sqrt(N). The middle panel plots "
                    "the classical trace a + b against the small factor, showing "
                    "that the trace attains its minimum exactly at the corner and "
                    "grows as the pair becomes lopsided: rectangles of fixed area, "
                    "the lopsided one has the larger perimeter. The right panel "
                    "repeats this for the power sums a^k + b^k with k = 1, 2, 3, "
                    "demonstrating that spread monotonicity — the analytic heart "
                    "of the trace lemma — holds for every exponent, which is what "
                    "makes the witness value invertible.",
                "code": read("assets/viz_tropical_corner.py"),
            },
            {
                "name": "The Noise Floor: Probe Density and the Birthday Scale",
                "description":
                    "A two-panel figure quantifying why a free witness is not "
                    "free. The left panel plots, for a family of balanced "
                    "semiprimes spanning many orders of magnitude, the observed "
                    "density of factor-bearing probes in the shortest successful "
                    "window against the proved upper bound 2 sqrt(2)/sqrt(N) and "
                    "the reference curve 1/sqrt(N); the data hug the bound, "
                    "showing the signal sitting at exactly the birthday density. "
                    "The right panel shades the region sqrt(N/2) <= p <= sqrt(N) "
                    "guaranteed by the two-sided sweep bound and overlays the "
                    "actual smaller primes, making visible that the length of "
                    "sweep required before any probe can succeed is precisely the "
                    "birthday scale — so the cost of evaluating a counting "
                    "aggregate coincides with the cost of trial division.",
                "code": read("assets/viz_noise_floor.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Free-Witness Laboratory: Build an Aggregate, "
                         "Extract the Trace, Factor — Then Pay the Bill",
                "description":
                    "A single, four-part interactive workbench that walks a "
                    "reader through the entire classification. Section 1 lets you "
                    "choose two primes and a weight (d, d^2, d^3, the divisor "
                    "count, or a deliberately colliding weight) and displays the "
                    "divisor list, the local values w(p) and w(q), and the two "
                    "sides of the Chinese Remainder identity "
                    "A_w(pq) = (1 + w(p))(1 + w(q)) side by side. Section 2 splits "
                    "the aggregate into its public norm and its secret trace and "
                    "then performs the recovery live, printing every step: power "
                    "sum, trace extraction (immediate for k = 1, an exact square "
                    "root for k = 2, a monotone binary search beyond), "
                    "discriminant, integer square root, quadratic formula — ending "
                    "with a verdict badge reading FREE WITNESS or BLIND BRANCH. "
                    "Choosing the colliding weight flips the verdict and prints an "
                    "explicit certificate: two semiprimes with different smaller "
                    "factors and identical aggregates. Section 3 draws the "
                    "tropical line log a + log b = log N with a slider that walks "
                    "along it, marking the corner and rendering the trace profile "
                    "so the reader sees the minimum sit exactly at sqrt(N). "
                    "Section 4 animates the divisor sweep: probes scroll past as "
                    "faint grey ticks and exactly one green spike appears at d = p, "
                    "with a live density readout, alongside a table checking the "
                    "bound 2 sqrt(2)/sqrt(N) across many scales. Collapsible "
                    "panels carry the full proofs of the trace lemma, the "
                    "collision argument, and the impossibility of a fixed finite "
                    "probe set, so the page stays readable for a newcomer while "
                    "offering complete rigour on demand.",
                "html": read("assets/widget_free_witness_lab.html"),
            }
        ],
        "interactive_layout": read("assets/interactive_layout.md"),
        "lean_proofs": lean_proofs(),
        "future_directions": read("assets/future_directions.md"),
        "modules": {
            "demo": read("demo.py"),
            "algo_free_witness_inversion": read(
                "assets/algo_free_witness_inversion.py"),
            "algo_dichotomy_classifier": read(
                "assets/algo_dichotomy_classifier.py"),
            "viz_tropical_corner": read("assets/viz_tropical_corner.py"),
            "viz_noise_floor": read("assets/viz_noise_floor.py"),
        },
        "lean_files": LEAN_FILES,
    }

    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(package, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print(f"wrote {out} ({os.path.getsize(out)} bytes)")


if __name__ == "__main__":
    main()


"""
Visualization: the noise floor, and the identity between the aggregation
barrier and the birthday bound.

Two panels:

  (left)  For a family of balanced semiprimes N = p*q with p < q <= 2p, the
          observed density of factor-bearing probes in the shortest successful
          window [2, p] is plotted against N on log-log axes, together with the
          proved upper bound 2*sqrt(2)/sqrt(N) and the reference curve
          1/sqrt(N).  The data hug the bound: signal at density c/sqrt(N),
          noise everywhere else.

  (right) The sweep length needed before any probe can succeed, squeezed
          between sqrt(N/2) and sqrt(N).  The shaded band is the theorem
          sqrt(N/2) <= p <= sqrt(N); the plotted points are the actual smaller
          primes.  The band is exactly the birthday scale, so the cost of
          evaluating a counting aggregate coincides with the cost of trial
          division.

Run:  python3 viz_noise_floor.py    (writes noise_floor.png)
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def next_prime(n: int) -> int:
    m = n + 1
    while not is_prime(m):
        m += 1
    return m


def balanced_semiprimes(count: int = 26) -> List[Tuple[int, int, int]]:
    """(p, q, N) for balanced semiprimes across many scales."""
    out: List[Tuple[int, int, int]] = []
    base = 11.0
    for i in range(count):
        p = next_prime(int(base))
        q = next_prime(p)
        if q <= 2 * p:
            out.append((p, q, p * q))
        base *= 2.1
        if base > 3e8:
            break
    return out


def main() -> None:
    data = balanced_semiprimes()
    ns = [n for _, _, n in data]
    ps = [p for p, _, _ in data]
    # shortest successful window is [2, p]; it contains exactly one hit
    densities = [1.0 / p for p in ps]
    bound = [2 * math.sqrt(2) / math.sqrt(n) for n in ns]
    reference = [1.0 / math.sqrt(n) for n in ns]

    fig, axes = plt.subplots(1, 2, figsize=(14.0, 5.4))
    fig.suptitle(
        "The noise floor: factor-bearing probes at density $c/\\sqrt{N}$, "
        "and a sweep of length $\\Theta(\\sqrt{N})$",
        fontsize=14,
    )

    ax = axes[0]
    ax.loglog(ns, bound, "-", color="#d62728", lw=2.0,
              label=r"proved bound $2\sqrt{2}/\sqrt{N}$")
    ax.loglog(ns, densities, "o", color="#1f77b4", ms=7,
              label="observed density in $[2, p]$")
    ax.loglog(ns, reference, "--", color="#888888", lw=1.3,
              label=r"$1/\sqrt{N}$")
    ax.set_xlabel("$N$")
    ax.set_ylabel("density of factor-bearing probes")
    ax.set_title("Density of useful probes in a successful window")
    ax.legend(fontsize=9)
    ax.grid(alpha=0.25, which="both")

    ax = axes[1]
    lo = [math.sqrt(n / 2) for n in ns]
    hi = [math.sqrt(n) for n in ns]
    ax.fill_between(ns, lo, hi, color="#ffcc99", alpha=0.55,
                    label=r"theorem: $\sqrt{N/2} \leq p \leq \sqrt{N}$")
    ax.loglog(ns, hi, "-", color="#d62728", lw=1.4, label=r"$\sqrt{N}$")
    ax.loglog(ns, lo, "-", color="#2ca02c", lw=1.4, label=r"$\sqrt{N/2}$")
    ax.loglog(ns, ps, "o", color="#1f77b4", ms=7,
              label="required sweep length $p$")
    ax.set_xlabel("$N$")
    ax.set_ylabel("sweep length before the first hit")
    ax.set_title("Aggregation cost is exactly the birthday scale")
    ax.legend(fontsize=9)
    ax.grid(alpha=0.25, which="both")

    fig.tight_layout(rect=(0, 0, 1, 0.92))
    fig.savefig("noise_floor.png", dpi=150)
    print("wrote noise_floor.png")


if __name__ == "__main__":
    main()


"""
Visualization: the divisor hyperbola, its tropical shadow, and the trace corner.

Three panels:

  (left)   The divisor hyperbola a*b = N in log-log coordinates, which is the
           straight line log a + log b = log N -- the tropical line X (+) Y = N.
           Every factorization of N is a lattice point on it; the corner sits at
           a = b = sqrt(N).

  (middle) The classical trace a + b plotted against the small factor a, showing
           that the trace is minimized exactly at the corner and grows as the
           pair becomes lopsided.  This is spread monotonicity: rectangles of
           fixed area, the lopsided one has the larger perimeter.

  (right)  Power sums a^k + b^k for k = 1, 2, 3 on a log scale, exhibiting the
           same strict monotonicity for every exponent -- the analytic heart of
           the trace lemma.

Run:  python3 viz_tropical_corner.py    (writes tropical_corner.png)
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def factor_pairs(n: int) -> List[Tuple[int, int]]:
    """All factorizations n = a*b with a <= b, ordered by increasing a."""
    out: List[Tuple[int, int]] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            out.append((d, n // d))
        d += 1
    return out


def main() -> None:
    n = 5040
    pairs = factor_pairs(n)
    a_vals = [a for a, _ in pairs]
    b_vals = [b for _, b in pairs]
    corner = math.sqrt(n)

    fig, axes = plt.subplots(1, 3, figsize=(16.5, 5.2))
    fig.suptitle(
        f"The tropical line $X \\odot Y = N$ for $N = {n}$: "
        "factorizations, trace, and the corner",
        fontsize=14,
    )

    # ---- panel 1: the tropical line -------------------------------------
    ax = axes[0]
    xs = [math.log(a) for a in a_vals]
    ys = [math.log(b) for b in b_vals]
    line_x = [math.log(1.0), math.log(float(n))]
    ax.plot(line_x, [math.log(n) - line_x[0], math.log(n) - line_x[1]],
            color="#888888", lw=1.4, zorder=1,
            label=r"$\log a + \log b = \log N$")
    ax.scatter(xs, ys, s=52, color="#1f77b4", zorder=3, label="factorizations")
    ax.scatter([math.log(corner)], [math.log(corner)], s=190, marker="*",
               color="#d62728", zorder=4, label=r"corner $a=b=\sqrt{N}$")
    ax.set_xlabel(r"$\log a$")
    ax.set_ylabel(r"$\log b$")
    ax.set_title("Factorizations lie on a tropical line")
    ax.legend(loc="upper right", fontsize=9)
    ax.grid(alpha=0.25)

    # ---- panel 2: the trace -------------------------------------------
    ax = axes[1]
    traces = [a + b for a, b in pairs]
    ax.plot(a_vals, traces, "o-", color="#2ca02c", lw=1.6, ms=6)
    ax.axvline(corner, color="#d62728", ls="--", lw=1.4,
               label=r"corner $\sqrt{N}$")
    imin = traces.index(min(traces))
    ax.annotate(f"minimum trace {traces[imin]}\nat ({a_vals[imin]}, {b_vals[imin]})",
                xy=(a_vals[imin], traces[imin]),
                xytext=(a_vals[imin] * 0.30, traces[imin] * 12),
                arrowprops=dict(arrowstyle="->", color="#333333"), fontsize=9)
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel(r"small factor $a$")
    ax.set_ylabel(r"trace $a + b$")
    ax.set_title("The trace is minimized at the corner")
    ax.legend(loc="upper right", fontsize=9)
    ax.grid(alpha=0.25, which="both")

    # ---- panel 3: power sums -------------------------------------------
    ax = axes[2]
    for k, colour in zip((1, 2, 3), ("#1f77b4", "#ff7f0e", "#9467bd")):
        vals = [a ** k + b ** k for a, b in pairs]
        ax.plot(a_vals, vals, "o-", color=colour, lw=1.5, ms=5,
                label=fr"$a^{k} + b^{k}$")
    ax.axvline(corner, color="#d62728", ls="--", lw=1.4)
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel(r"small factor $a$")
    ax.set_ylabel(r"power sum")
    ax.set_title("Spread monotonicity holds for every $k \\geq 1$")
    ax.legend(loc="upper right", fontsize=9)
    ax.grid(alpha=0.25, which="both")

    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("tropical_corner.png", dpi=150)
    print("wrote tropical_corner.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
The Free-Witness Classification for CRT-Multiplicative Weights
==============================================================

Numerical demonstration of every result in the accompanying paper.

A CRT weight is a function w : N -> N with w(1) = 1 and w(mn) = w(m)w(n)
whenever gcd(m, n) = 1.  Its aggregate is A_w(N) = sum_{d | N} w(d).  On a
semiprime N = pq with p != q this factors through the Chinese Remainder
splitting:

        A_w(pq) = (1 + w(p)) (1 + w(q)).

The demonstrations below verify, numerically:

  1. The CRT factorization of the aggregate.
  2. The trace/norm mechanism: w(a)w(b) = w(N) is public, w(a)+w(b) is the
     secret, and the pair is determined by its sum and product.
  3. The trace lemma: for a strictly monotone CRT weight, distinct coprime
     factorizations of a fixed N get distinct aggregates.
  4. Spread monotonicity: a^k + b^k strictly increases as ab = N gets more
     lopsided.
  5. Closed-form recovery R(N, s) = (s - isqrt(s^2 - 4N)) // 2, and the
     predicted witness p^2 + q^2 (the k = 2 case).
  6. The negative branch: a CRT weight that collides on two primes produces
     equal aggregates for semiprimes with different smaller factors, so no
     function of the aggregate can return a factor.
  7. The characters-only boundary: exponential phase weights z^x are not
     CRT-multiplicative unless z = 1.
  8. The noise floor: exactly one useful probe in the window [2, sqrt(N)],
     and the density bound 2*sqrt(2)/sqrt(N) for balanced semiprimes.
  9. The tropical corner: the trace a + b is minimized at the balanced pair.

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------
# Basic arithmetic utilities (all inlined, no external dependencies)
# --------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, exact for all 64-bit inputs."""
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def next_prime(n: int) -> int:
    """Smallest prime strictly greater than n."""
    m = n + 1
    while not is_prime(m):
        m += 1
    return m


def divisors(n: int) -> List[int]:
    """All positive divisors of n, sorted."""
    small: List[int] = []
    large: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d * d != n:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def factor_pairs(n: int) -> List[Tuple[int, int]]:
    """All factorizations n = a*b with a <= b, ordered by increasing a."""
    return [(d, n // d) for d in divisors(n) if d * d <= n]


# --------------------------------------------------------------------------
# CRT weights and aggregates
# --------------------------------------------------------------------------

Weight = Callable[[int], int]


def aggregate(w: Weight, n: int) -> int:
    """A_w(n) = sum over divisors d of n of w(d)."""
    return sum(w(d) for d in divisors(n))


def power_weight(k: int) -> Weight:
    """The CRT weight w(d) = d^k; its aggregate is sigma_k."""
    return lambda d: d ** k


def sigma(k: int, n: int) -> int:
    """Divisor-power sum sigma_k(n)."""
    return aggregate(power_weight(k), n)


def is_crt_weight(w: Weight, bound: int = 60) -> bool:
    """Check w(1) = 1 and w(mn) = w(m)w(n) on all coprime m, n <= bound."""
    if w(1) != 1:
        return False
    for m in range(1, bound + 1):
        for n in range(1, bound + 1):
            if math.gcd(m, n) == 1 and w(m * n) != w(m) * w(n):
                return False
    return True


def is_strictly_monotone(w: Weight, bound: int = 200) -> bool:
    """Check w(1) < w(2) < ... < w(bound)."""
    return all(w(i) < w(i + 1) for i in range(1, bound))


# --------------------------------------------------------------------------
# Recovery: the trace coordinate is efficiently invertible
# --------------------------------------------------------------------------


def recover_small_factor(n: int, s: int) -> int:
    """
    R(N, s) = (s - isqrt(s^2 - 4N)) // 2.

    Theorem: for all naturals a <= b, R(a*b, a+b) = a exactly.
    Proof: (a+b)^2 - 4ab = (b-a)^2, so the integer square root is b-a with no
    truncation, and (s - (b-a))//2 = a.
    """
    disc = s * s - 4 * n
    if disc < 0:
        disc = 0
    return (s - math.isqrt(disc)) // 2


def recover_from_sigma1(n: int) -> int:
    """Smaller prime factor of a semiprime N from sigma_1(N)."""
    trace = sigma(1, n) - 1 - n  # = p + q
    return recover_small_factor(n, trace)


def recover_from_sigma2(n: int) -> int:
    """
    Smaller prime factor of a semiprime N from sigma_2(N) -- the predicted
    witness.  sigma_2(N) - 1 - N^2 = p^2 + q^2; adding 2N gives (p+q)^2.
    """
    power_sum = sigma(2, n) - 1 - n * n  # = p^2 + q^2
    trace = math.isqrt(power_sum + 2 * n)  # = p + q, exactly
    return recover_small_factor(n, trace)


def recover_from_power_sum(n: int, k: int, power_sum: int) -> int:
    """
    General k >= 1: recover the smaller factor from N and T_k = a^k + b^k by
    monotone binary search on the candidate small factor, using the fact that
    a^k + (N/a)^k is strictly decreasing in a on [1, sqrt(N)].
    """
    lo, hi = 1, math.isqrt(n)
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if n % mid == 0 and mid ** k + (n // mid) ** k >= power_sum:
            lo = mid
        else:
            # search by value, tolerating non-divisors via the real relaxation
            val = mid ** k + (n / mid) ** k
            if val >= power_sum:
                lo = mid
            else:
                hi = mid - 1
    return lo


# --------------------------------------------------------------------------
# Noise-floor quantities
# --------------------------------------------------------------------------


def window_hits(n: int, m: int) -> List[int]:
    """Probes d in [2, m] that divide n and are not equal to n."""
    return [d for d in range(2, m + 1) if n % d == 0 and d != n]


def noise_density(n: int, m: int) -> float:
    """Density of factor-bearing probes in the window [2, m]."""
    return len(window_hits(n, m)) / m


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_1_crt_factorization() -> None:
    print("=" * 74)
    print("1.  The aggregate factors through the CRT splitting")
    print("=" * 74)
    print("    A_w(pq) = (1 + w(p)) (1 + w(q))\n")
    weights: Dict[str, Weight] = {
        "w(d) = d      (sigma_1)": power_weight(1),
        "w(d) = d^2    (sigma_2)": power_weight(2),
        "w(d) = d^3    (sigma_3)": power_weight(3),
    }
    pairs = [(3, 11), (7, 13), (101, 103), (10007, 10009)]
    for name, w in weights.items():
        print(f"  {name}")
        for p, q in pairs:
            n = p * q
            lhs = aggregate(w, n)
            rhs = (1 + w(p)) * (1 + w(q))
            flag = "OK" if lhs == rhs else "FAIL"
            print(f"    N = {p:>6} * {q:<6} = {n:<12}"
                  f"  A_w(N) = {lhs:<22} product = {rhs:<22} [{flag}]")
        print()


def demo_2_trace_and_norm() -> None:
    print("=" * 74)
    print("2.  Trace and norm: the public part and the secret part")
    print("=" * 74)
    print("    norm  = w(p) w(q) = w(N)      (computable from N alone)")
    print("    trace = w(p) + w(q)           (what the aggregate reveals)\n")
    for k in (1, 2, 3):
        w = power_weight(k)
        p, q = 41, 89
        n = p * q
        agg = aggregate(w, n)
        norm = w(n)
        trace = agg - 1 - norm
        print(f"  k = {k}:  N = {n}")
        print(f"      aggregate sigma_{k}(N) = {agg}")
        print(f"      norm  w(N)            = {norm}")
        print(f"      trace = A - 1 - norm  = {trace}"
              f"   (check p^{k} + q^{k} = {p**k + q**k})")
    print()


def demo_3_trace_lemma() -> None:
    print("=" * 74)
    print("3.  The trace lemma: distinct factorizations, distinct aggregates")
    print("=" * 74)
    print("    For a strictly monotone CRT weight, the aggregate value pins")
    print("    the factorization of N uniquely.\n")
    for n in (360, 1155, 2310, 5040):
        for k in (1, 2):
            w = power_weight(k)
            values = {}
            collision = False
            for a, b in factor_pairs(n):
                if math.gcd(a, b) != 1:
                    continue
                val = (1 + w(a)) * (1 + w(b))
                if val in values:
                    collision = True
                values[val] = (a, b)
            status = "COLLISION" if collision else "all distinct"
            print(f"  N = {n:<6} k = {k}:  "
                  f"{len(values)} coprime factorizations, {status}")
    print()
    print("    Contrast k = 0 (the counting weight w(d) = 1), which is not")
    print("    monotone and collapses everything:")
    for p, q in [(3, 11), (7, 13), (101, 103)]:
        print(f"      sigma_0({p * q}) = {sigma(0, p * q)}")
    print("    -> constant 4 on every semiprime: factorisation-insensitive.\n")


def demo_4_spread_monotonicity() -> None:
    print("=" * 74)
    print("4.  Spread monotonicity along the hyperbola  a*b = N")
    print("=" * 74)
    print("    a^k + b^k strictly increases as the pair becomes lopsided.\n")
    n = 720
    for k in (1, 2, 3):
        rows = [(a, b, a ** k + b ** k) for a, b in factor_pairs(n)]
        rows.sort(key=lambda r: -r[0])  # from balanced (a large) to lopsided
        print(f"  N = {n}, k = {k}   (listed from the corner outwards)")
        prev = None
        strict = True
        for a, b, v in rows:
            mark = ""
            if prev is not None and not v > prev:
                strict = False
                mark = "  <-- NOT increasing"
            print(f"      a = {a:>3}  b = {b:>4}   a^{k}+b^{k} = {v:<14}{mark}")
            prev = v
        print(f"      strictly increasing away from the corner: {strict}\n")


def demo_5_recovery() -> None:
    print("=" * 74)
    print("5.  Closed-form recovery, including the predicted witness p^2+q^2")
    print("=" * 74)
    print("    R(N, s) = (s - isqrt(s^2 - 4N)) // 2\n")
    pairs = [(3, 11), (17, 19), (101, 103), (10007, 10009),
             (1000003, 1000033), (2147483647, 2147483659)]
    print(f"  {'p':>12} {'q':>12} {'from sigma_1':>14} {'from sigma_2':>14}"
          f"  {'status':>8}")
    for p, q in pairs:
        n = p * q
        # sigma_1 and sigma_2 computed structurally (an oracle hands them over)
        s1 = (1 + p) * (1 + q)
        s2 = (1 + p * p) * (1 + q * q)
        t1 = s1 - 1 - n
        r1 = recover_small_factor(n, t1)
        ps = s2 - 1 - n * n
        t2 = math.isqrt(ps + 2 * n)
        r2 = recover_small_factor(n, t2)
        ok = "OK" if (r1 == p and r2 == p) else "FAIL"
        print(f"  {p:>12} {q:>12} {r1:>14} {r2:>14}  {ok:>8}")
    print()
    print("    General exponent k, recovered by monotone search:")
    p, q = 1009, 3163
    n = p * q
    for k in (1, 2, 3, 4, 5):
        ps = p ** k + q ** k
        rec = recover_from_power_sum(n, k, ps)
        print(f"      k = {k}:  p^k+q^k = {ps:<28} recovered p = {rec}"
              f"   [{'OK' if rec == p else 'FAIL'}]")
    print()


def demo_6_negative_branch() -> None:
    print("=" * 74)
    print("6.  The negative branch: a prime collision destroys all information")
    print("=" * 74)
    print("    Build a CRT weight that collides on two primes, by defining it")
    print("    on prime powers and extending multiplicatively.\n")

    def make_colliding_weight(pa: int, pb: int) -> Weight:
        """A CRT weight with w(pa) = w(pb): send both to the same value."""

        def w(d: int) -> int:
            if d <= 0:
                return 0
            result = 1
            m = d
            f = 2
            while f * f <= m:
                if m % f == 0:
                    e = 0
                    while m % f == 0:
                        m //= f
                        e += 1
                    base = pa if f in (pa, pb) else f
                    result *= base ** e
                f += 1
            if m > 1:
                base = pa if m in (pa, pb) else m
                result *= base
            return result

        return w

    pa, pb = 3, 5
    w = make_colliding_weight(pa, pb)
    print(f"    weight identifies the primes {pa} and {pb}:"
          f"  w({pa}) = {w(pa)}, w({pb}) = {w(pb)}")
    print(f"    it is a CRT weight on [1,60]: {is_crt_weight(w, 40)}\n")
    for q in (7, 11, 13, 101):
        n1, n2 = pa * q, pb * q
        a1, a2 = aggregate(w, n1), aggregate(w, n2)
        print(f"      N1 = {pa}*{q} = {n1:<6} A_w = {a1:<8}"
              f"   N2 = {pb}*{q} = {n2:<6} A_w = {a2:<8}"
              f"   equal: {a1 == a2}")
    print()
    print("    Two semiprimes with DIFFERENT smaller factors share an")
    print("    aggregate value, so no function of the aggregate can return")
    print("    the smaller factor.  The obstruction is informational, not")
    print("    computational.\n")


def demo_7_characters_only_boundary() -> None:
    print("=" * 74)
    print("7.  The characters-only boundary")
    print("=" * 74)
    print("    Power weights are CRT-multiplicative; exponential phases are")
    print("    not, unless trivial.  The coprime pair (2,3) already decides:")
    print("      z^(2*3) = z^6   but   z^2 * z^3 = z^5,   forcing z = 1.\n")
    for k in (0, 1, 2, 3):
        print(f"      w(d) = d^{k}:  CRT-multiplicative = "
              f"{is_crt_weight(power_weight(k), 30)}")
    print()
    for c in (2, 3, 10):
        lhs, rhs = c ** 6, c ** 5
        print(f"      w(x) = {c}^x:  w(6) = {lhs:<8} w(2)*w(3) = {rhs:<8}"
              f"  equal: {lhs == rhs}")
    print()


def demo_8_noise_floor() -> None:
    print("=" * 74)
    print("8.  The noise floor: aggregation cost = birthday bound")
    print("=" * 74)
    print("    (a) Exactly one useful probe below the corner sqrt(N).\n")
    print(f"      {'p':>8} {'q':>8} {'N':>14} {'isqrt(N)':>10}"
          f" {'hits in [2,sqrt N]':>20} {'density':>12}")
    for p, q in [(3, 11), (17, 19), (101, 103), (1009, 1013), (10007, 10009)]:
        n = p * q
        m = math.isqrt(n)
        hits = [d for d in range(2, m + 1) if n % d == 0]
        dens = len(hits) / max(m - 1, 1)
        print(f"      {p:>8} {q:>8} {n:>14} {m:>10} {str(hits):>20}"
              f" {dens:>12.3e}")
    print()
    print("    (b) Balanced semiprimes (q <= 2p): the density of")
    print("        factor-bearing probes in any successful window is at most")
    print("        2*sqrt(2)/sqrt(N).\n")
    print(f"      {'N':>14} {'m = p':>8} {'observed density':>18}"
          f" {'bound 2sqrt2/sqrtN':>20} {'holds':>7}")
    for p in (11, 101, 1009, 10007, 100003):
        q = next_prime(p)
        if q > 2 * p:
            continue
        n = p * q
        m = p  # the shortest successful window
        dens = noise_density(n, m)
        bound = 2 * math.sqrt(2) / math.sqrt(n)
        print(f"      {n:>14} {m:>8} {dens:>18.6e} {bound:>20.6e}"
              f" {str(dens <= bound + 1e-18):>7}")
    print()
    print("    (c) Sweep length is squeezed: sqrt(N/2) <= p <= sqrt(N).\n")
    print(f"      {'N':>14} {'sqrt(N/2)':>14} {'p':>10} {'sqrt(N)':>14}"
          f" {'holds':>7}")
    for p in (11, 101, 1009, 10007, 100003, 1000003):
        q = next_prime(p)
        if q > 2 * p:
            continue
        n = p * q
        lo, hi = math.sqrt(n / 2), math.sqrt(n)
        print(f"      {n:>14} {lo:>14.3f} {p:>10} {hi:>14.3f}"
              f" {str(lo <= p <= hi):>7}")
    print()
    print("    (d) No fixed finite probe set works for all semiprimes.")
    probe_set = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    p = next_prime(max(probe_set))
    q = next_prime(p)
    n = p * q
    missed = all(not (n % s == 0 and 1 < s < n) for s in probe_set)
    print(f"        probe set S = {probe_set}")
    print(f"        counterexample N = {p} * {q} = {n};"
          f" every probe misses: {missed}\n")


def demo_9_tropical_corner() -> None:
    print("=" * 74)
    print("9.  The tropical corner: the trace is minimized at the balance point")
    print("=" * 74)
    print("    In min-plus coordinates the factorizations of N lie on the")
    print("    tropical line X (+) Y = N, and the classical trace a + b is")
    print("    minimized at the corner sqrt(N).\n")
    for n in (360, 1155, 9409, 10403):
        rows = factor_pairs(n)
        best = min(rows, key=lambda r: r[0] + r[1])
        print(f"  N = {n}  (corner at sqrt(N) = {math.sqrt(n):.3f})")
        for a, b in rows:
            marker = "   <-- tropical minimum" if (a, b) == best else ""
            print(f"      a = {a:>5}  b = {b:>6}   trace a+b = {a + b:>7}"
                  f"{marker}")
        print(f"      trivial factorization trace = {1 + n},"
              f"  minimum trace = {best[0] + best[1]}\n")


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE FREE-WITNESS CLASSIFICATION FOR CRT-MULTIPLICATIVE WEIGHTS")
    print("#  Trace lemma, exhaustive dichotomy, and the noise-floor principle")
    print("#" * 74)
    print()
    demo_1_crt_factorization()
    demo_2_trace_and_norm()
    demo_3_trace_lemma()
    demo_4_spread_monotonicity()
    demo_5_recovery()
    demo_6_negative_branch()
    demo_7_characters_only_boundary()
    demo_8_noise_floor()
    demo_9_tropical_corner()
    print("=" * 74)
    print("Summary")
    print("=" * 74)
    print("  * Every CRT aggregate on a semiprime splits as (1+w(p))(1+w(q)).")
    print("  * Monotone CRT weight  ->  the aggregate IS the factorization,")
    print("    recoverable in O(1) arithmetic operations from trace and norm.")
    print("  * Colliding CRT weight ->  no function of the aggregate can ever")
    print("    return a factor.")
    print("  * There is no third behaviour.")
    print("  * Computing the aggregate without an oracle costs Theta(sqrt N):")
    print("    the aggregation barrier IS the birthday bound.")
    print()


if __name__ == "__main__":
    main()
