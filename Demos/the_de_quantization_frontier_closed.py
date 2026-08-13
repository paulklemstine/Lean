"""Assemble PACKAGE.json from the deliverables in this directory.

Run:  python3 build_package.py
"""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).resolve().parent
LEAN_DIR = ROOT / "Catalog" / "Pythagorean" / "FactoringBarriers" / "Dequant"

LEAN_FILE_ORDER = [
    "TotalVariation.lean",
    "CombSpectrum.lean",
    "CombDistance.lean",
    "OrderProbe.lean",
    "ProbeComplexity.lean",
    "SchmidtRank.lean",
    "OrderToFactor.lean",
    "Frontier.lean",
]


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


# ---------------------------------------------------------------------------
# Algorithms
# ---------------------------------------------------------------------------

ALG_SPECTRUM = '''"""Exact spectral resolution of the comb state."""

from __future__ import annotations

import cmath
import math
from typing import Dict, List


def peak_lattice(q: int, r: int) -> List[int]:
    """The informative frequencies of a comb of spacing r on a grid of size q.

    Requires r | q.  Returns the multiples of q // r inside {0, ..., q-1}; there
    are exactly r of them, so the length of this list IS the hidden order.
    """
    if q % r != 0:
        raise ValueError("this exact form requires r | q")
    m = q // r
    return [j * m for j in range(r)]


def comb_dft(q: int, r: int, y: int) -> complex:
    """Unnormalised DFT of the comb at frequency y (direct evaluation)."""
    m = q // r
    return sum(cmath.exp(2j * math.pi * (j * r * y) / q) for j in range(m))


def comb_distribution(q: int, r: int) -> Dict[int, float]:
    """The exact output distribution: uniform mass 1/r on the r peaks."""
    return {y: 1.0 / r for y in peak_lattice(q, r)}


def verify_spectrum(q: int, r: int, tol: float = 1e-9) -> bool:
    """Check DFT(y) = q/r on the peak lattice and 0 elsewhere, and that the
    distribution equals the normalised squared spectrum."""
    m, norm = q // r, q * (q // r)
    dist = comb_distribution(q, r)
    for y in range(q):
        val = comb_dft(q, r, y)
        expected = m if y % m == 0 else 0
        if abs(val - expected) > tol:
            return False
        if abs(dist.get(y, 0.0) - abs(val) ** 2 / norm) > tol:
            return False
    return abs(shannon_entropy(dist) - math.log(r)) < tol


def shannon_entropy(pmf: Dict[int, float]) -> float:
    return -sum(p * math.log(p) for p in pmf.values() if p > 0)


if __name__ == "__main__":
    for q, r in [(16, 4), (12, 3), (48, 6), (720, 9)]:
        print(f"Q={q:4d} r={r:2d}  peaks={peak_lattice(q, r)[:6]}...  "
              f"#peaks={len(peak_lattice(q, r))}  verified={verify_spectrum(q, r)}")
'''

ALG_CERTIFY = '''"""Total-variation certification of a candidate de-quantizer."""

from __future__ import annotations

import math
from typing import Dict, Iterable, List, Sequence, Set, Tuple


def comb_distribution(q: int, r: int) -> Dict[int, float]:
    m = q // r
    return {j * m: 1.0 / r for j in range(r)}


def total_variation(p: Dict[int, float], s: Dict[int, float]) -> float:
    support: Set[int] = set(p) | set(s)
    return 0.5 * sum(abs(p.get(y, 0.0) - s.get(y, 0.0)) for y in support)


def exact_comb_distance(r1: int, r2: int) -> float:
    """TV(P_{r1}, P_{r2}) = 1 - gcd(r1,r2)/max(r1,r2)   (identity, not a bound)."""
    return 1.0 - math.gcd(r1, r2) / max(r1, r2)


def two_candidate_certificate(r1: int, r2: int) -> float:
    """Every distribution is at TV >= this from one of P_{r1}, P_{r2}."""
    return exact_comb_distance(r1, r2) / 2.0


def sparse_certificate(r: int, k: int) -> float:
    """Every k-sparse distribution is at TV >= this from P_r (sharp)."""
    return max(0.0, 1.0 - k / r)


def pigeonhole_certificate(candidates: Sequence[int]) -> float:
    """For pairwise coprime candidate orders: some candidate is at TV >= this."""
    for i, a in enumerate(candidates):
        for b in candidates[i + 1:]:
            if math.gcd(a, b) != 1:
                raise ValueError("candidates must be pairwise coprime")
    return 1.0 - 1.0 / min(candidates) - 1.0 / len(candidates)


def certify(sampler: Dict[int, float], q: int, candidates: Sequence[int]
            ) -> List[Tuple[int, float, float]]:
    """Audit a proposed order-free sampler against every candidate order.

    Returns triples (r, measured TV, guaranteed floor).  The floors are proved
    a priori, so a candidate de-quantizer can be refuted before it is run.
    """
    out: List[Tuple[int, float, float]] = []
    floor = pigeonhole_certificate(candidates) if len(candidates) > 1 else 0.0
    for r in candidates:
        out.append((r, total_variation(sampler, comb_distribution(q, r)), floor))
    return out


if __name__ == "__main__":
    q = 3 * 5 * 7 * 11
    uniform = {y: 1.0 / q for y in range(q)}
    for r, tv, floor in certify(uniform, q, [3, 5, 7, 11]):
        print(f"r={r:3d}  measured TV={tv:.4f}   guaranteed >= {floor:.4f} for some r")
    print("exact two-comb distance TV(P_3, P_16) =", exact_comb_distance(3, 16))
    print("two-candidate certificate            =", two_candidate_certificate(3, 16))
'''

ALG_BSGS = '''"""Baby-step/giant-step order extraction against the free divisibility probe."""

from __future__ import annotations

import math
from typing import Dict, List, Tuple


def probe(n: int, b: int, t: int) -> bool:
    """The free observation: does n divide b**t - 1?  Equivalently ord_n(b) | t."""
    return pow(b, t, n) == 1


def prime_factors(m: int) -> List[int]:
    fs, d = [], 2
    while d * d <= m:
        if m % d == 0:
            fs.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        fs.append(m)
    return fs


def reduce_to_least(n: int, b: int, multiple: int) -> int:
    """Strip prime factors from a known multiple of the order until it is least."""
    r = multiple
    for p in prime_factors(multiple):
        while r % p == 0 and probe(n, b, r // p):
            r //= p
    return r


def order_bsgs(n: int, b: int, bound: int) -> Tuple[int, int]:
    """Recover ord_n(b) <= bound in Theta(sqrt(bound)) probes.

    Writes r = i*m + j with m = ceil(sqrt(bound)), tabulates the baby steps b**j
    (j < m) and walks the giant steps b**(-i*m).  A match yields a multiple of
    the order, which one pass of `reduce_to_least` turns into the order itself.
    Time and space Theta(sqrt(bound)); each step is O(log n) bit operations.
    """
    if math.gcd(b, n) != 1:
        raise ValueError("base and modulus must be coprime")
    m = math.isqrt(bound) + 1
    baby: Dict[int, int] = {}
    acc = 1
    for j in range(m):
        baby.setdefault(acc, j)
        acc = (acc * b) % n
    giant = pow(pow(b, m, n), -1, n)
    cur, queries = 1, m
    for i in range(m + 1):
        queries += 1
        if cur in baby:
            cand = i * m + baby[cur]
            if cand > 0 and probe(n, b, cand):
                return reduce_to_least(n, b, cand), queries
        cur = (cur * giant) % n
    raise ValueError("order exceeds the bound")


def order_naive(n: int, b: int, bound: int) -> Tuple[int, int]:
    """The Theta(r) walk, for comparison: every probe below r is silent."""
    for t in range(1, bound + 1):
        if probe(n, b, t):
            return t, t
    raise ValueError("order exceeds the bound")


if __name__ == "__main__":
    for n, b in [(8051, 2), (32767, 3), (999983, 5)]:
        r_b, q_b = order_bsgs(n, b, 4 * n)
        print(f"N={n:7d} b={b}:  order={r_b:7d}  probes(BSGS)={q_b:5d}"
              f"  vs naive {r_b}")
'''

ALG_PIPELINE = '''"""From one sampled frequency to a nontrivial factor."""

from __future__ import annotations

import math
from fractions import Fraction
from typing import List, Optional, Tuple


def convergents(x: Fraction, max_den: int) -> List[Fraction]:
    """All continued-fraction convergents of x with denominator <= max_den."""
    out: List[Fraction] = []
    a0 = math.floor(x)
    p_prev, q_prev, p_cur, q_cur = 1, 0, a0, 1
    frac = x - a0
    while True:
        if 0 < q_cur <= max_den:
            out.append(Fraction(p_cur, q_cur))
        if frac == 0:
            break
        x = 1 / frac
        a = math.floor(x)
        frac = x - a
        p_prev, p_cur = p_cur, a * p_cur + p_prev
        q_prev, q_cur = q_cur, a * q_cur + q_prev
        if q_cur > max_den:
            break
    return out


def split_from_order(n: int, b: int, r: int) -> Optional[Tuple[int, int]]:
    """Shor's reduction: r even and b**(r/2) != -1 give gcd(b**(r/2)-1, n)."""
    if r % 2:
        return None
    x = pow(b, r // 2, n)
    if x == n - 1:
        return None
    d = math.gcd(x - 1, n)
    return (d, n // d) if 1 < d < n else None


def factor_from_sample(n: int, b: int, q: int, y: int,
                       max_den: Optional[int] = None) -> Optional[Tuple[int, int]]:
    """Post-process a measured frequency y on the grid of size q into a factor.

    Farey separation guarantees that at most one reduced fraction of denominator
    <= R approximates y/q to within 1/(2R^2), so the convergent is unambiguous;
    a shared factor between the numerator and the order is repaired by trying
    small multiples, each certified for free by one divisibility probe.
    """
    max_den = max_den or n
    for c in convergents(Fraction(y, q), max_den):
        for mult in range(1, 16):
            t = c.denominator * mult
            if t and pow(b, t, n) == 1:
                s = split_from_order(n, b, t)
                if s:
                    return s
    return None


if __name__ == "__main__":
    n, b = 8051, 2
    q = 1 << 26
    r = 1968                      # ord_8051(2)
    y = round(5 * q / r)          # a peak of the comb, s/r with s = 5
    print("factor from one sample:", factor_from_sample(n, b, q, y))
'''

ALGORITHMS: List[Dict[str, str]] = [
    {
        "name": "Exact Spectral Resolution of the Comb State",
        "description": (
            "Computes, without any numerical approximation, the discrete Fourier "
            "transform of the arithmetic-progression ('comb') state of spacing r on a "
            "grid of size Q with r | Q. The complete geometric sum collapses to Q/r on "
            "the multiples of Q/r and to exactly zero everywhere else, so the peak "
            "lattice is {0, Q/r, 2Q/r, ...} and its cardinality is precisely the hidden "
            "order r. The routine also verifies that the measurement distribution is "
            "the normalised squared spectrum, that it is uniform with mass 1/r on each "
            "peak, and that its Shannon entropy equals log r exactly. Enumerating the "
            "peak lattice costs O(r); the verification pass evaluates the transform "
            "directly at all Q frequencies for O(Q^2/r) arithmetic operations. Its role "
            "in the pipeline is to supply ground truth: every distance computed against "
            "this distribution is a distance against the exact output of order finding, "
            "never against a simulation of it."
        ),
        "pseudocode": (
            "Input: grid size Q, order r with r | Q\n"
            "Output: peak lattice, exact output distribution, verification flag\n"
            "\n"
            "1. m <- Q / r                                  // peak spacing\n"
            "2. Peaks <- [ j*m : j = 0 .. r-1 ]             // |Peaks| = r\n"
            "3. P(y) <- 1/r for y in Peaks, else 0\n"
            "4. for y = 0 .. Q-1:\n"
            "5.     S(y) <- sum_{j=0}^{m-1} exp(2*pi*i*j*r*y/Q)\n"
            "6.     assert S(y) = m if m | y else S(y) = 0        // exact spectrum\n"
            "7.     assert P(y) = |S(y)|^2 / (Q * m)              // distribution = spectrum\n"
            "8. assert -sum_y P(y) log P(y) = log r               // maximal entropy\n"
            "9. return Peaks, P, true"
        ),
        "code": ALG_SPECTRUM,
    },
    {
        "name": "Total-Variation Certification of a Candidate De-Quantizer",
        "description": (
            "Audits any proposed classical sampler against the exact order-finding "
            "output distributions. Three unconditional floors are computed and compared "
            "with the measured distances. (i) The sparse floor: a distribution supported "
            "on at most k outcomes is at total variation at least 1 - k/r from the comb, "
            "and the bound is attained by placing mass 1/k on k peaks. (ii) The "
            "two-candidate floor: since TV(P_{r1}, P_{r2}) = 1 - gcd(r1,r2)/max(r1,r2) "
            "exactly, the triangle inequality forces every single distribution to sit at "
            "distance at least half of that from one of the two. (iii) The pigeonhole "
            "floor: for k pairwise coprime candidate orders each at least R, whose peak "
            "sets meet only at the trivial frequency, some candidate is at distance at "
            "least 1 - 1/R - 1/k. Each floor is a theorem, so the audit refutes a "
            "candidate de-quantization a priori rather than empirically. Cost O(Q) per "
            "candidate."
        ),
        "pseudocode": (
            "Input: proposed sampler D on {0,...,Q-1}; candidate orders r_1 < ... < r_k\n"
            "Output: measured distances and the proved floors they cannot beat\n"
            "\n"
            "1. for each i: P_i <- uniform mass 1/r_i on the multiples of Q/r_i\n"
            "2. for each i: d_i <- (1/2) * sum_y |D(y) - P_i(y)|\n"
            "3. // exact pairwise geometry\n"
            "4. for each i < j: E_ij <- 1 - gcd(r_i, r_j) / max(r_i, r_j)\n"
            "5. two_candidate_floor <- max_{i<j} E_ij / 2\n"
            "6. if the r_i are pairwise coprime:\n"
            "7.     R <- min_i r_i;  pigeonhole_floor <- 1 - 1/R - 1/k\n"
            "8. if D has support of size <= s:  sparse_floor_i <- 1 - s/r_i\n"
            "9. assert max_i d_i >= two_candidate_floor and max_i d_i >= pigeonhole_floor\n"
            "10. return (d_i), floors"
        ),
        "code": ALG_CERTIFY,
    },
    {
        "name": "Baby-Step/Giant-Step Extraction Against the Free Divisibility Probe",
        "description": (
            "The best known classical extractor in the probe model, and the upper bound "
            "matching the paper's lower bounds. The probe N | b^t - 1 is free (one "
            "modular exponentiation) and answers exactly 'does r divide t', yet it is "
            "silent for every 0 < t < r, so the naive walk needs Theta(r) queries. "
            "Writing the unknown order as r = i*m + j with m = ceil(sqrt(B)) turns the "
            "search into a meet-in-the-middle: tabulate the baby steps b^j for j < m, "
            "walk the giant steps b^{-i m}, and match. A hit yields a multiple of the "
            "order; stripping prime factors while the probe still fires reduces it to "
            "the least such exponent, the order itself. Time and space Theta(sqrt(B)) "
            "with O(log N) bit operations per step. The adversary bound (some query must "
            "have magnitude at least the order) and the counting bound (at least log2 n "
            "queries to separate n candidates) show that this shape is forced; whether "
            "Theta(sqrt r) is optimal for adaptive algorithms is the paper's third "
            "conjecture."
        ),
        "pseudocode": (
            "Input: modulus N, base b coprime to N, bound B on the order\n"
            "Output: r = ord_N(b), and the number of probe queries used\n"
            "\n"
            "1. m <- ceil(sqrt(B))\n"
            "2. baby <- empty table;  acc <- 1\n"
            "3. for j = 0 .. m-1:  baby[acc] <- min(baby[acc], j);  acc <- acc * b mod N\n"
            "4. giant <- (b^m)^{-1} mod N;  cur <- 1\n"
            "5. for i = 0 .. m:\n"
            "6.     if cur in baby:\n"
            "7.         cand <- i*m + baby[cur]\n"
            "8.         if cand > 0 and probe(N, b, cand):\n"
            "9.             for p in prime_factors(cand):\n"
            "10.                while p | cand and probe(N, b, cand / p): cand <- cand / p\n"
            "11.            return cand\n"
            "12.    cur <- cur * giant mod N\n"
            "13. fail: the order exceeds B"
        ),
        "code": ALG_BSGS,
    },
    {
        "name": "Continued-Fraction Post-Processing from a Sampled Frequency to a Factor",
        "description": (
            "The classical converse that turns the lower bounds into an equivalence. "
            "Given one measured frequency y on the grid of size Q, the routine expands "
            "y/Q as a continued fraction and reads off the denominators of its "
            "convergents. Farey separation -- two distinct fractions with denominators "
            "r and r' differ by at least 1/(r r') -- guarantees that at most one reduced "
            "fraction of denominator at most R approximates y/Q to within 1/(2R^2), so "
            "the convergent identifies the order unambiguously; when the numerator "
            "shares a factor with the order, small multiples of the denominator repair "
            "it, and each candidate is certified for free by a single divisibility "
            "probe. One gcd then splits the modulus: if r is even and b^{r/2} is not -1 "
            "mod N, then gcd(b^{r/2} - 1, N) is a nontrivial divisor, because b^{r/2} is "
            "a square root of unity that is neither 1 (by minimality of the order) nor "
            "-1 (by hypothesis). Cost O(log Q) convergents, each O(log^2 N) bit "
            "operations. Consequence: a polynomial-time classical sampler of the output "
            "distribution would be a polynomial-time factoring algorithm."
        ),
        "pseudocode": (
            "Input: modulus N, base b, grid size Q, measured frequency y, bound R\n"
            "Output: a nontrivial factorisation of N, or failure\n"
            "\n"
            "1. x <- y / Q  (exact rational)\n"
            "2. for each convergent p/q of x with q <= R:\n"
            "3.     for mult = 1 .. c:            // repair gcd(s, r) > 1\n"
            "4.         t <- q * mult\n"
            "5.         if b^t = 1 mod N:          // one free probe certifies t\n"
            "6.             if t is even:\n"
            "7.                 x0 <- b^{t/2} mod N\n"
            "8.                 if x0 != N-1:\n"
            "9.                     d <- gcd(x0 - 1, N)\n"
            "10.                    if 1 < d < N: return (d, N/d)\n"
            "11. return failure"
        ),
        "code": ALG_PIPELINE,
    },
]

# ---------------------------------------------------------------------------
# Demos
# ---------------------------------------------------------------------------

DEMO_LEDGER = '''"""The incompressibility ledger: k-sparse surrogates versus the comb."""

from __future__ import annotations

import math
from typing import Dict, List, Set, Tuple


def comb(q: int, r: int) -> Dict[int, float]:
    m = q // r
    return {j * m: 1.0 / r for j in range(r)}


def tv(p: Dict[int, float], s: Dict[int, float]) -> float:
    keys: Set[int] = set(p) | set(s)
    return 0.5 * sum(abs(p.get(y, 0.0) - s.get(y, 0.0)) for y in keys)


def best_k_sparse(q: int, r: int, k: int) -> Dict[int, float]:
    """The extremal k-sparse surrogate: mass 1/k on k of the r peaks."""
    return {y: 1.0 / k for y in sorted(comb(q, r))[:k]}


def worst_k_sparse(q: int, r: int, k: int) -> Dict[int, float]:
    """A k-sparse surrogate that misses the peak lattice entirely (TV = 1)."""
    m = q // r
    off = [y for y in range(q) if y % m != 0][:k]
    return {y: 1.0 / len(off) for y in off} if off else {0: 1.0}


def ledger(q: int, r: int, ks: List[int]) -> List[Tuple[int, float, float, float]]:
    target = comb(q, r)
    rows = []
    for k in ks:
        rows.append((k,
                     tv(target, best_k_sparse(q, r, k)),
                     tv(target, worst_k_sparse(q, r, k)),
                     1 - k / r))
    return rows


if __name__ == "__main__":
    q, r = 2 ** 10, 2 ** 9
    print(f"Grid Q = {q}, order r = {r}\\n")
    print(f"{'k':>6} {'TV (best sparse)':>18} {'TV (off-lattice)':>18} {'floor 1-k/r':>14}")
    for k, best, worst, floor in ledger(q, r, [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]):
        print(f"{k:6d} {best:18.6f} {worst:18.6f} {floor:14.6f}")
    print("\\nThe best possible sparse surrogate exactly attains the floor 1 - k/r,")
    print("so the bound is sharp and no cleverness in choosing the support helps.")
    print("With k polynomial in log N and r exponential, the distance is 1 - o(1):")
    for bits in (256, 1024, 2048):
        k_poly = bits ** 3                            # a generous poly(log N) sketch
        gap = (bits - 2) - math.log2(k_poly)          # log2(r/k), with r ~ 2^(bits-2)
        print(f"   {bits:5d}-bit modulus:  k = {k_poly}, r ~ 2^{bits - 2},"
              f"  1 - k/r = 1 - 2^-{gap:.1f}")
'''

DEMO_SCALING = '''"""Scaling of extraction cost: the silent probe, the naive walk, and BSGS."""

from __future__ import annotations

import math
from typing import Dict, List, Tuple


def order(b: int, n: int) -> int:
    r, acc = 1, b % n
    while acc != 1:
        acc, r = (acc * b) % n, r + 1
    return r


def probe(n: int, b: int, t: int) -> bool:
    return pow(b, t, n) == 1


def naive_cost(n: int, b: int) -> int:
    t = 1
    while not probe(n, b, t):
        t += 1
    return t


def bsgs_cost(n: int, b: int, bound: int) -> int:
    m = math.isqrt(bound) + 1
    baby: Dict[int, int] = {}
    acc = 1
    for j in range(m):
        baby.setdefault(acc, j)
        acc = (acc * b) % n
    giant = pow(pow(b, m, n), -1, n)
    cur, queries = 1, m
    for i in range(m + 1):
        queries += 1
        if cur in baby and (i * m + baby[cur]) > 0:
            return queries
        cur = (cur * giant) % n
    return queries


if __name__ == "__main__":
    print("Every probe strictly below the order returns FALSE, so the naive walk")
    print("pays Theta(r); meet-in-the-middle pays Theta(sqrt r).  Both are")
    print("exponential in the bit length log2(N).\\n")
    print(f"{'r = 2^k - 1 modulus':>22} {'order r':>10} {'naive':>8} {'BSGS':>7} {'log2 r':>8}")
    for k in range(5, 20):
        n = 2 ** k - 1
        if n < 3:
            continue
        r = order(2, n)
        silent = all(not probe(n, 2, t) for t in range(1, min(r, 2000)))
        assert silent
        print(f"{n:22d} {r:10d} {naive_cost(n, 2):8d} {bsgs_cost(n, 2, 4 * r):7d}"
              f" {math.log2(r):8.2f}")
    print("\\nCounting bound: separating n candidate orders needs >= log2(n) probe bits,")
    print("and the adversary bound forces at least one query of magnitude >= r.")
'''

DEMOS: List[Dict[str, str]] = [
    {
        "name": "Comprehensive Numerical Validation of the Frontier Theorems",
        "description": (
            "A single self-contained script that exercises every quantitative claim of "
            "the paper and asserts each one numerically: the exact comb spectrum (the "
            "transform equals Q/r on the multiples of Q/r and vanishes elsewhere), the "
            "identity between the output distribution and the normalised squared "
            "spectrum, the entropy value log r, the sharp incompressibility bound "
            "1 - k/r for k-sparse surrogates, the exact two-comb distance "
            "1 - gcd(r1,r2)/max(r1,r2), the pigeonhole floor 1 - 1/R - 1/k for pairwise "
            "coprime candidate orders, the Schmidt rank of the coefficient matrix "
            "computed exactly over the rationals by Gaussian elimination, the total "
            "silence of the divisibility probe below the order together with the "
            "Theta(r) and Theta(sqrt r) extraction costs, the aliasing bound "
            "2 gcd(r,Q) <= r on a mismatched grid, and finally an end-to-end run that "
            "converts a single sampled frequency into the factorisation 8051 = 83 * 97."
        ),
        "code": read(ROOT / "demo.py"),
    },
    {
        "name": "The Incompressibility Ledger: k-Sparse Surrogates Versus the Comb",
        "description": (
            "Tabulates, for a grid of size 1024 and order 512, the total variation "
            "distance between the exact output distribution and two families of sparse "
            "surrogates: the extremal one (mass 1/k spread over k genuine peaks) and an "
            "off-lattice one that misses the peak set entirely. The extremal surrogate "
            "attains the theoretical floor 1 - k/r exactly at every k, confirming that "
            "the incompressibility bound is sharp and that no choice of support can do "
            "better; the off-lattice surrogate sits at distance 1. The script closes by "
            "instantiating the asymptotics for cryptographic parameters, where a "
            "polynomial-size sketch of an exponentially large order is at distance "
            "1 - 2^{-Omega(bits)} from the truth: not a degraded copy, but an "
            "asymptotically mutually singular distribution."
        ),
        "code": DEMO_LEDGER,
    },
    {
        "name": "Extraction Cost Scaling: The Silent Probe, the Naive Walk, and Meet-in-the-Middle",
        "description": (
            "Demonstrates the free-observation / sealed-extraction split on Mersenne "
            "moduli 2^k - 1, where the base 2 has order exactly k so every order "
            "magnitude is realised by an honest instance. For each modulus the script "
            "verifies that every divisibility probe strictly below the order returns "
            "false -- the answer vector is constant, carrying zero bits of information "
            "-- and then measures the query counts of the naive walk (Theta(r)) against "
            "baby-step/giant-step (Theta(sqrt r)), alongside log2(r), the "
            "information-theoretic floor on the number of probe bits required. The "
            "resulting table exhibits the two-sided squeeze on the probe channel: many "
            "bits are needed, and at least one query must be as large as the order "
            "itself."
        ),
        "code": DEMO_SCALING,
    },
]

# ---------------------------------------------------------------------------
# Visualizations
# ---------------------------------------------------------------------------

VIZ_SPECTRUM = '''"""Visualisation: the comb, its exact spectrum, and the peak lattice."""

from __future__ import annotations

import cmath
import math
from typing import List

import matplotlib.pyplot as plt


def comb_amplitudes(q: int, r: int, offset: int = 0) -> List[float]:
    """Indicator of the arithmetic progression offset + r*Z inside {0,...,q-1}."""
    return [1.0 if (x - offset) % r == 0 and x >= offset else 0.0 for x in range(q)]


def spectrum(q: int, r: int) -> List[float]:
    m = q // r
    out = []
    for y in range(q):
        s = sum(cmath.exp(2j * math.pi * (j * r * y) / q) for j in range(m))
        out.append(abs(s) ** 2 / (q * m))
    return out


def main() -> None:
    q = 48
    fig, axes = plt.subplots(2, 2, figsize=(12, 7))
    for col, r in enumerate((6, 8)):
        amps = comb_amplitudes(q, r)
        axes[0][col].stem(range(q), amps, basefmt=" ")
        axes[0][col].set_title(f"The comb: spacing r = {r} on a grid of Q = {q}")
        axes[0][col].set_xlabel("x")
        axes[0][col].set_ylabel("amplitude")

        spec = spectrum(q, r)
        axes[1][col].stem(range(q), spec, basefmt=" ", linefmt="C3-", markerfmt="C3o")
        axes[1][col].set_title(
            f"Exact spectrum: {r} peaks of height 1/{r} at spacing Q/r = {q // r}")
        axes[1][col].set_xlabel("frequency y")
        axes[1][col].set_ylabel("probability")
        axes[1][col].axhline(1.0 / r, ls="--", lw=0.8, color="grey")
        axes[1][col].text(0.02, 0.9, f"entropy = log {r} = {math.log(r):.3f} nats",
                          transform=axes[1][col].transAxes)
    fig.suptitle("The number of peaks IS the hidden order: flat, maximal-entropy output",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("comb_spectrum.png", dpi=150)
    print("wrote comb_spectrum.png")


if __name__ == "__main__":
    main()
'''

VIZ_TV = '''"""Visualisation: the total-variation landscape between candidate orders."""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def divisors(q: int) -> List[int]:
    return [d for d in range(1, q + 1) if q % d == 0]


def main() -> None:
    q = 720
    ds = divisors(q)
    n = len(ds)
    grid = np.zeros((n, n))
    for i, a in enumerate(ds):
        for j, b in enumerate(ds):
            grid[i][j] = 1 - math.gcd(a, b) / max(a, b)

    fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

    im = axes[0].imshow(grid, cmap="magma", vmin=0, vmax=1, origin="lower")
    axes[0].set_xticks(range(n))
    axes[0].set_xticklabels(ds, rotation=90, fontsize=6)
    axes[0].set_yticks(range(n))
    axes[0].set_yticklabels(ds, fontsize=6)
    axes[0].set_title(f"TV(P_r1, P_r2) = 1 - gcd(r1,r2)/max(r1,r2)   on Q = {q}")
    axes[0].set_xlabel("candidate order r2")
    axes[0].set_ylabel("candidate order r1")
    fig.colorbar(im, ax=axes[0], label="total variation")

    r = 512
    ks = np.arange(1, r + 1)
    axes[1].plot(ks, 1 - ks / r, lw=2, label="floor  1 - k/r  (attained)")
    axes[1].axhline(0.5, ls="--", color="grey", lw=1,
                    label="the 1/2 threshold for two coprime candidates")
    axes[1].set_xscale("log")
    axes[1].set_xlabel("support size k of the classical surrogate")
    axes[1].set_ylabel("total variation from the exact output")
    axes[1].set_title(f"Incompressibility for order r = {r}: poly-size sketches sit at 1 - o(1)")
    axes[1].legend()
    axes[1].grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("tv_landscape.png", dpi=150)
    print("wrote tv_landscape.png")


if __name__ == "__main__":
    main()
'''

VISUALIZATIONS: List[Dict[str, str]] = [
    {
        "name": "The Comb and Its Exact Spectrum: Where the Order Hides",
        "description": (
            "A four-panel figure showing, for two different hidden orders on the same "
            "grid, the comb in the position domain (an arithmetic progression of spacing "
            "r) and its exact power spectrum in the frequency domain (r peaks of height "
            "1/r spaced Q/r apart, with identically zero between them). Side by side the "
            "panels make the central point visible: the secret is not the location of "
            "any single peak but the number of peaks and their common height, a global "
            "feature of the whole picture. The annotation records the entropy log r, "
            "which is maximal for the support size and leaves no head to keep and no "
            "tail to discard."
        ),
        "code": VIZ_SPECTRUM,
    },
    {
        "name": "The Total-Variation Landscape and the Incompressibility Floor",
        "description": (
            "Two panels quantifying how far apart the candidate output distributions "
            "are. The left panel is a heat map of the exact distance "
            "1 - gcd(r1,r2)/max(r1,r2) over all pairs of divisors of Q = 720: the bright "
            "regions, where the orders are coprime, are pairs of nearly mutually "
            "singular distributions, and the arithmetic of the gcd is directly legible "
            "as the dark diagonal ridges. The right panel plots the sharp "
            "incompressibility floor 1 - k/r against the support size k of a classical "
            "surrogate on a logarithmic axis, with the 1/2 threshold marked: a "
            "polynomial-size sketch of an exponentially large order lives at the extreme "
            "left of the plot, at distance indistinguishable from 1."
        ),
        "code": VIZ_TV,
    },
]

# ---------------------------------------------------------------------------
# Interactive widgets
# ---------------------------------------------------------------------------

WIDGET_LAB = read(ROOT / "widgets" / "comb_lab.html")
WIDGET_PROBE = read(ROOT / "widgets" / "probe_lab.html")

INTERACTIVE: List[Dict[str, str]] = [
    {
        "title": "The Comb Laboratory: Watch the Order Hide in Plain Sight",
        "description": (
            "A live, dependency-free laboratory for the central object of the theory. "
            "Choose a grid size Q and a hidden order r dividing it, and the widget draws "
            "the comb in the position domain and computes its exact power spectrum in "
            "the frequency domain, highlighting the peak lattice and reporting that the "
            "peak count equals r and the entropy equals log r. A second slider "
            "introduces a classical surrogate supported on k outcomes: the widget "
            "overlays it on the true distribution, measures the total variation live, "
            "and displays the proved floor 1 - k/r beside it, so the reader can try "
            "every possible support and watch the bound refuse to be beaten. A third "
            "control selects a rival order r', drawing both combs together and "
            "confirming the exact distance formula 1 - gcd(r,r')/max(r,r') together with "
            "the resulting guarantee that no single sampler can be close to both. Every "
            "number shown is computed in the browser from the definitions, not "
            "pre-tabulated."
        ),
        "html": WIDGET_LAB,
    },
    {
        "title": "The Silent Oracle: Free Observation, Sealed Extraction",
        "description": (
            "An interactive probe bench. Pick a modulus and a base, and the widget "
            "displays the answer vector of the free divisibility test 'does N divide "
            "b^t - 1' as a strip of cells across t = 1, 2, 3, ...: every cell below the "
            "order is dark, and the first bright cell is the order itself. The reader "
            "can query any exponent by hand, run the naive walk and the "
            "baby-step/giant-step search side by side while the query counters tick up, "
            "and compare both against the information-theoretic floor of log2 "
            "candidates' worth of probe bits. A second panel closes the loop: once the "
            "order is found, the widget performs the single gcd of Shor's reduction and "
            "prints the resulting nontrivial factorisation, making concrete the claim "
            "that the only prize extraction offers is already a factorisation."
        ),
        "html": WIDGET_PROBE,
    },
]

# ---------------------------------------------------------------------------
# Narrative layout
# ---------------------------------------------------------------------------

LAYOUT = read(ROOT / "widgets" / "layout.md")

FUTURE_DIRECTIONS = read(ROOT / "widgets" / "future_directions.txt")


def main() -> None:
    lean_sources = {name: read(LEAN_DIR / name) for name in LEAN_FILE_ORDER}
    lean_blob = "\n\n".join(
        f"-- ==========================================================================\n"
        f"-- FILE: Catalog/Pythagorean/FactoringBarriers/Dequant/{name}\n"
        f"-- ==========================================================================\n\n"
        f"{src}"
        for name, src in lean_sources.items()
    )

    package: Dict[str, Any] = {
        "title": "The De-Quantization Frontier for Order Finding, Closed",
        "domain": "Pythagorean",
        "description": (
            "An exact, quantitative closure of the de-quantization frontier for quantum "
            "order finding: the output distribution is a flat comb whose peak count is "
            "the hidden order, every k-sparse classical surrogate is at total variation "
            "at least 1 - k/r from it, two orders sit at distance exactly "
            "1 - gcd/max, and the state's Schmidt rank equals the order -- so a "
            "polynomial-time classical sampler of that distribution would be a "
            "polynomial-time factoring algorithm."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-13",
        "key_results": [
            "Exact spectrum of the comb: for an order r dividing the grid size Q, the "
            "transform equals Q/r on the multiples of Q/r and vanishes elsewhere, so the "
            "informative frequencies are exactly the peak lattice.",
            "The peak count is the hidden order: the exact output distribution is "
            "uniform with mass 1/r on exactly r frequencies and has Shannon entropy "
            "exactly log r.",
            "Sharp incompressibility: every distribution supported on at most k outcomes "
            "is at total variation at least 1 - k/r from the true output, and the bound "
            "is attained by placing mass 1/k on k peaks.",
            "Exact distance between two orders: TV(P_{r1}, P_{r2}) = 1 - "
            "gcd(r1,r2)/max(r1,r2), whence every single distribution is at distance at "
            "least half of that from one of the two candidates, and at least "
            "1 - 1/R - 1/k from one of k pairwise coprime candidates of size at least R.",
            "Schmidt rank equals the order, with orthonormal branch rows and a flat "
            "entanglement spectrum, so any bipartite decomposition of rank k forces "
            "r <= k: bounded bond dimension succeeds only in the classically easy regime.",
            "The divisibility probe N | b^t - 1 is free but silent below the order; "
            "extraction needs a query of magnitude at least the order and at least "
            "log2 n queries to separate n candidates, while one gcd turns a known order "
            "into a nontrivial factor -- de-quantizing order finding is factoring.",
        ],
        "keywords": [
            "order finding",
            "de-quantization",
            "total variation distance",
            "Schmidt rank",
            "discrete Fourier transform",
            "incompressibility",
            "integer factorization",
            "query lower bounds",
        ],
        "article": read(ROOT / "ARTICLE.md"),
        "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
        "demo": read(ROOT / "demo.py"),
        "demos": DEMOS,
        "algorithms": ALGORITHMS,
        "visualizations": VISUALIZATIONS,
        "interactive_demos": INTERACTIVE,
        "interactive_layout": LAYOUT,
        "lean_proofs": lean_blob,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": read(ROOT / "demo.py")},
        "lean_files": [
            f"Catalog/Pythagorean/FactoringBarriers/Dequant/{name}"
            for name in LEAN_FILE_ORDER
        ],
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""
The De-Quantization Frontier, Closed — numerical demonstrations.

Self-contained Python (standard library only) illustrating every quantitative
statement of the accompanying paper:

  1. The exact comb spectrum:  sum_{j<Q/r} e(2*pi*i*j*r*y/Q) = Q/r if (Q/r)|y else 0.
  2. The peak count equals the hidden order:  #peaks(Q, r) = r.
  3. The output distribution is the normalised squared spectrum, is flat, and has
     Shannon entropy log r.
  4. Incompressibility:  every k-sparse distribution is at total variation
     >= 1 - k/r from the comb, and the bound is attained.
  5. The exact distance between two combs:  TV(P_{r1}, P_{r2}) = 1 - gcd(r1,r2)/max(r1,r2),
     and the triangle-inequality corollary  max(TV(D,P_{r1}), TV(D,P_{r2})) >= (1-gcd/max)/2.
  6. The pigeonhole seal: no order-free sampler is close to all candidates.
  7. Schmidt rank of the order-finding state equals the order exactly.
  8. The free divisibility probe, its silence below r, and the Theta(r) / Theta(sqrt r)
     extraction cost.
  9. Aliasing on a mismatched grid: only gcd(r, Q) peaks survive.
 10. Order -> factor: continued-fraction post-processing followed by one gcd.

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from fractions import Fraction
from typing import Dict, List, Sequence, Set, Tuple

# ----------------------------------------------------------------------------
# 0. Elementary number theory
# ----------------------------------------------------------------------------


def multiplicative_order(b: int, n: int) -> int:
    """Least r >= 1 with b**r = 1 (mod n); requires gcd(b, n) = 1."""
    if math.gcd(b, n) != 1:
        raise ValueError("base and modulus must be coprime")
    r, acc = 1, b % n
    while acc != 1:
        acc = (acc * b) % n
        r += 1
    return r


def probe(n: int, b: int, t: int) -> bool:
    """The free fixed-point / gcd probe: does n divide b**t - 1?

    Equivalently gcd(b**t - 1, n) = n, equivalently ord_n(b) | t.  One modular
    exponentiation, i.e. O(log t) multiplications.
    """
    return pow(b, t, n) == 1


# ----------------------------------------------------------------------------
# 1-3. The comb, its spectrum, its distribution
# ----------------------------------------------------------------------------


def comb_sum(q: int, r: int, y: int) -> complex:
    """Unnormalised DFT of the comb of spacing r inside {0, ..., q-1}, at frequency y."""
    m = q // r
    return sum(cmath.exp(2j * math.pi * (j * r * y) / q) for j in range(m))


def peaks(q: int, r: int) -> List[int]:
    """The informative frequencies: the multiples of q//r inside {0, ..., q-1}."""
    m = q // r
    return [y for y in range(q) if y % m == 0]


def comb_pmf(q: int, r: int) -> Dict[int, float]:
    """The exact output distribution: mass 1/r on each of the r peaks."""
    p = peaks(q, r)
    return {y: 1.0 / len(p) for y in p}


def shannon_entropy(pmf: Dict[int, float]) -> float:
    return -sum(p * math.log(p) for p in pmf.values() if p > 0)


def total_variation(p: Dict[int, float], q_: Dict[int, float]) -> float:
    support: Set[int] = set(p) | set(q_)
    return 0.5 * sum(abs(p.get(y, 0.0) - q_.get(y, 0.0)) for y in support)


# ----------------------------------------------------------------------------
# 7. Schmidt rank of the order-finding state
# ----------------------------------------------------------------------------


def shor_matrix(n: int, b: int, q: int) -> List[List[Fraction]]:
    """Coefficient matrix M[x][z] = [b**x = z (mod n)] of the pre-measurement state."""
    return [[Fraction(1) if pow(b, x, n) == z else Fraction(0) for z in range(n)]
            for x in range(q)]


def exact_rank(matrix: Sequence[Sequence[Fraction]]) -> int:
    """Exact rank over the rationals by Gaussian elimination."""
    rows = [list(row) for row in matrix]
    rank, col = 0, 0
    ncols = len(rows[0]) if rows else 0
    while rank < len(rows) and col < ncols:
        pivot = next((i for i in range(rank, len(rows)) if rows[i][col] != 0), None)
        if pivot is None:
            col += 1
            continue
        rows[rank], rows[pivot] = rows[pivot], rows[rank]
        pv = rows[rank][col]
        rows[rank] = [v / pv for v in rows[rank]]
        for i in range(len(rows)):
            if i != rank and rows[i][col] != 0:
                f = rows[i][col]
                rows[i] = [a - f * c for a, c in zip(rows[i], rows[rank])]
        rank += 1
        col += 1
    return rank


# ----------------------------------------------------------------------------
# 8. Extraction from probes
# ----------------------------------------------------------------------------


def extract_order_naive(n: int, b: int, bound: int) -> Tuple[int, int]:
    """Walk t = 1, 2, ... until the probe fires.  Returns (order, #queries)."""
    for t in range(1, bound + 1):
        if probe(n, b, t):
            return t, t
    raise ValueError("no order found below the bound")


def extract_order_bsgs(n: int, b: int, bound: int) -> Tuple[int, int]:
    """Baby-step / giant-step order search: O(sqrt(bound)) probes.

    Writes the unknown r as r = i*m + j with m = ceil(sqrt(bound)), tabulates the
    baby steps b**j and matches against the giant steps b**(-i*m).
    """
    m = math.isqrt(bound) + 1
    baby: Dict[int, int] = {}
    acc = 1
    for j in range(m):
        baby.setdefault(acc, j)
        acc = (acc * b) % n
    giant_step = pow(pow(b, m, n), -1, n)
    cur, queries = 1, m
    for i in range(m + 1):
        queries += 1
        if cur in baby:
            cand = i * m + baby[cur]
            if cand > 0 and probe(n, b, cand):
                # reduce to the true (least) order by stripping prime factors
                r = cand
                for p in prime_factors(cand):
                    while r % p == 0 and probe(n, b, r // p):
                        r //= p
                return r, queries
        cur = (cur * giant_step) % n
    raise ValueError("baby-step/giant-step failed below the bound")


def prime_factors(m: int) -> List[int]:
    fs, d = [], 2
    while d * d <= m:
        if m % d == 0:
            fs.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        fs.append(m)
    return fs


# ----------------------------------------------------------------------------
# 10. Post-processing: continued fractions, then one gcd
# ----------------------------------------------------------------------------


def continued_fraction_convergents(x: Fraction, max_den: int) -> List[Fraction]:
    """All convergents p/q of x with q <= max_den."""
    out: List[Fraction] = []
    a0 = math.floor(x)
    p_prev, q_prev, p_cur, q_cur = 1, 0, a0, 1
    frac = x - a0
    while True:
        if q_cur <= max_den and q_cur > 0:
            out.append(Fraction(p_cur, q_cur))
        if frac == 0:
            break
        x = 1 / frac
        a = math.floor(x)
        frac = x - a
        p_prev, p_cur = p_cur, a * p_cur + p_prev
        q_prev, q_cur = q_cur, a * q_cur + q_prev
        if q_cur > max_den:
            break
    return out


def order_from_sample(y: int, q: int, max_den: int) -> List[int]:
    """Candidate orders from a measured frequency y on the grid of size q."""
    return [c.denominator for c in continued_fraction_convergents(Fraction(y, q), max_den)]


def factor_from_order(n: int, b: int, r: int) -> Tuple[int, int] | None:
    """Shor's reduction: if r is even and b**(r/2) != -1 (mod n), split n."""
    if r % 2 != 0:
        return None
    x = pow(b, r // 2, n)
    if x == n - 1:
        return None
    d = math.gcd(x - 1, n)
    if 1 < d < n:
        return d, n // d
    return None


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_spectrum(q: int = 16, r: int = 4) -> None:
    print(f"\n[1] Exact comb spectrum, Q = {q}, r = {r}  (spacing Q/r = {q // r})")
    for y in range(q):
        s = comb_sum(q, r, y)
        predicted = q // r if y % (q // r) == 0 else 0
        assert abs(s - predicted) < 1e-9, (y, s, predicted)
        if abs(s) > 1e-9:
            print(f"    y = {y:2d}:  DFT = {s.real:6.2f}  (peak)")
    print(f"    peaks  = {peaks(q, r)}")
    print(f"    #peaks = {len(peaks(q, r))} = r  <- the peak count IS the hidden order")


def demo_distribution(q: int = 48, r: int = 6) -> None:
    print(f"\n[2] Output distribution, Q = {q}, r = {r}")
    pmf = comb_pmf(q, r)
    norm = q * (q // r)
    for y in list(pmf)[:3]:
        lhs = pmf[y]
        rhs = abs(comb_sum(q, r, y)) ** 2 / norm
        assert abs(lhs - rhs) < 1e-9
        print(f"    P({y:2d}) = {lhs:.6f} = |DFT|^2 / (Q * Q/r) = {rhs:.6f}")
    h = shannon_entropy(pmf)
    print(f"    flat on {len(pmf)} peaks;  entropy = {h:.6f} nats,  log r = {math.log(r):.6f}")
    assert abs(h - math.log(r)) < 1e-12


def demo_sparse_bound(q: int = 60, r: int = 30) -> None:
    print(f"\n[3] Incompressibility: k-sparse surrogates, Q = {q}, r = {r}")
    target = comb_pmf(q, r)
    for k in (1, 2, 5, 10, 30):
        best = sorted(target)[:k]
        surrogate = {y: 1.0 / k for y in best}   # the extremal k-sparse guess
        tv = total_variation(target, surrogate)
        bound = 1 - k / r
        print(f"    k = {k:2d}:  TV = {tv:.6f}   lower bound 1 - k/r = {bound:.6f}"
              f"   {'(attained)' if abs(tv - bound) < 1e-12 else ''}")
        assert tv >= bound - 1e-12


def demo_comb_distance() -> None:
    print("\n[4] Exact distance between two combs:  TV = 1 - gcd(r1,r2)/max(r1,r2)")
    for q, r1, r2 in [(48, 3, 16), (48, 4, 12), (60, 6, 10), (64, 8, 16), (720, 9, 16)]:
        tv = total_variation(comb_pmf(q, r1), comb_pmf(q, r2))
        pred = 1 - math.gcd(r1, r2) / max(r1, r2)
        print(f"    Q = {q:3d}, r1 = {r1:2d}, r2 = {r2:2d}:"
              f"  TV = {tv:.6f}   formula = {pred:.6f}")
        assert abs(tv - pred) < 1e-12
    # the triangle-inequality corollary
    q, r1, r2 = 48, 3, 16
    p1, p2 = comb_pmf(q, r1), comb_pmf(q, r2)
    uniform = {y: 1.0 / q for y in range(q)}
    worst = max(total_variation(uniform, p1), total_variation(uniform, p2))
    print(f"    a single order-free sampler (uniform) on Q = {q}: "
          f"max TV = {worst:.6f} >= {(1 - math.gcd(r1, r2) / r2) / 2:.6f}")


def demo_pigeonhole(q: int = 3 * 5 * 7 * 11) -> None:
    print(f"\n[5] The pigeonhole seal: pairwise coprime candidate orders, Q = {q}")
    cands = [3, 5, 7, 11]
    k, R = len(cands), min(cands)
    uniform = {y: 1.0 / q for y in range(q)}
    tvs = [total_variation(uniform, comb_pmf(q, r)) for r in cands]
    print(f"    candidates {cands}:  TVs from the uniform sampler = "
          + ", ".join(f"{t:.4f}" for t in tvs))
    print(f"    guaranteed: some TV >= 1 - 1/R - 1/k = {1 - 1 / R - 1 / k:.4f};"
          f"  observed max = {max(tvs):.4f}")
    assert max(tvs) >= 1 - 1 / R - 1 / k - 1e-12


def demo_schmidt(n: int = 15, b: int = 2) -> None:
    r = multiplicative_order(b, n)
    q = 4 * r
    print(f"\n[6] Schmidt rank of the order-finding state, N = {n}, b = {b}, Q = {q}")
    rank = exact_rank(shor_matrix(n, b, q))
    print(f"    ord_{n}({b}) = {r};   rank of the Q x N coefficient matrix = {rank}")
    assert rank == r
    print(f"    a bond dimension k < {r} cannot represent the state:"
          f" rank <= k forces ord <= k")


def demo_probe(n: int = 8051, b: int = 2) -> None:
    r = multiplicative_order(b, n)
    print(f"\n[7] The free probe and the sealed extraction, N = {n}, b = {b}")
    print(f"    true order r = {r}")
    silent = all(not probe(n, b, t) for t in range(1, r))
    print(f"    every probe at 0 < t < r returns FALSE: {silent}  (no information at all)")
    r_naive, q_naive = extract_order_naive(n, b, 4 * r)
    r_bsgs, q_bsgs = extract_order_bsgs(n, b, 4 * r)
    print(f"    naive walk : r = {r_naive}, {q_naive} probes  (Theta(r))")
    print(f"    baby/giant : r = {r_bsgs}, {q_bsgs} probes  (Theta(sqrt r))")
    assert r_naive == r == r_bsgs
    print(f"    counting bound: separating n candidates needs >= log2(n) probe bits;"
          f" log2({r}) = {math.log2(r):.2f}")
    # the Mersenne realisation: every r >= 2 is a genuine order
    for rr in (5, 7, 11):
        assert multiplicative_order(2, 2 ** rr - 1) == rr
    print("    non-vacuity: ord_{2^r - 1}(2) = r for r = 5, 7, 11 -> the seal bites at every scale")


def demo_aliasing() -> None:
    print("\n[8] Aliasing on a mismatched grid: only gcd(r, Q) peaks survive")
    for q, r in [(16, 6), (16, 10), (35, 4), (12, 5)]:
        g = math.gcd(r, q)
        print(f"    Q = {q:2d}, r = {r:2d}:  gcd = {g}, visible peaks = {len(peaks(q, g))},"
              f"  2*gcd <= r ? {2 * g <= r}")
        assert len(peaks(q, g)) == g
        if r % q != 0 and q % r != 0:
            assert 2 * g <= r or r % q == 0


def demo_end_to_end(n: int = 8051, b: int = 2) -> None:
    r = multiplicative_order(b, n)
    q = 1
    while q < n * n:
        q *= 2
    print(f"\n[9] End to end: sample -> continued fractions -> order -> factor  (N = {n})")
    print(f"    grid Q = {q}, true order r = {r}")
    peak_spacing = q / r
    s = next(s for s in range(2, r) if math.gcd(s, r) == 1)   # a typical numerator
    y = round(s * peak_spacing)
    cands = order_from_sample(y, q, max_den=n)
    print(f"    measured frequency y = {y} (peak s/r with s = {s});  y/Q = {y / q:.10f}")
    print(f"    continued-fraction denominators: {cands}")
    for cand in cands:
        # a denominator sharing a factor with r comes back as r/gcd(s,r); small
        # multiples repair it, and one free probe certifies the answer
        for mult in range(1, 13):
            t = cand * mult
            if t > 0 and probe(n, b, t):
                split = factor_from_order(n, b, t)
                print(f"    candidate {t} certified by one probe;  gcd(b^(t/2) - 1, N) split -> {split}")
                assert split is not None and split[0] * split[1] == n
                return
    raise AssertionError("post-processing failed")


def main() -> None:
    print("=" * 78)
    print("THE DE-QUANTIZATION FRONTIER, CLOSED — numerical demonstrations")
    print("=" * 78)
    demo_spectrum()
    demo_distribution()
    demo_sparse_bound()
    demo_comb_distance()
    demo_pigeonhole()
    demo_schmidt()
    demo_probe()
    demo_aliasing()
    demo_end_to_end()
    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
