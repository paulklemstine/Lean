"""
The Berggren tree of primitive Pythagorean triples and its zeta functions.
=========================================================================

Numerical demonstration of the results of

    "A Zeta Function for the Berggren Tree: The Silver Critical Line,
     the Abscissa Theorem, and the Depth-Height Dichotomy".

Everything is self-contained: only the Python standard library is used.

Contents
--------
1.  The tree in Euclid-seed coordinates (m, n), with the three moves
        L(m,n) = (2m - n, m),  M(m,n) = (2m + n, m),  R(m,n) = (m + 2n, n)
    and hypotenuse c = m^2 + n^2, root (m,n) = (2,1) <-> (3,4,5).
2.  Verification of the seed bijection: words <-> admissible seeds.
3.  The growth dichotomy: silver speed limit c(w) <= 5(3+2sqrt2)^|w|,
    Pell spine exponential, outer spines quadratic.
4.  The counting function N(H) against its two proved bounds.
5.  The abscissa theorem: divergence at s <= 1, convergence for s > 1.
6.  The silver Ihara zeta Z(s) = 1/(1 - 3 eps^{-2s}): critical line,
    absence of zeros, periodicity, uniform simple residues.
7.  Prime hypotenuses = primes = 1 mod 4.
8.  The purely hyperbolic subtree spanned by the blocks MM and MR.
"""

from __future__ import annotations

import cmath
import math
from math import gcd, isqrt, log, pi, sqrt
from typing import Dict, Iterator, List, Sequence, Tuple

Seed = Tuple[int, int]

# --------------------------------------------------------------------------
# Fundamental constants
# --------------------------------------------------------------------------

EPS: float = 1.0 + sqrt(2.0)            # silver ratio, fundamental unit of Z[sqrt 2]
EPS_SQ: float = 3.0 + 2.0 * sqrt(2.0)   # = EPS**2, eigenvalue of the middle generator
LOG_EPS: float = log(EPS)
SIGMA0: float = log(3.0) / (2.0 * LOG_EPS)          # silver abscissa
POLE_SPACING: float = pi / LOG_EPS                   # gap between consecutive poles
RESIDUE: float = 1.0 / (2.0 * LOG_EPS)               # residue at every pole


# --------------------------------------------------------------------------
# 1.  The tree in Euclid-seed coordinates
# --------------------------------------------------------------------------

def is_seed(p: Seed) -> bool:
    """Admissibility: n < m, n >= 1, gcd(m,n) = 1, m + n odd."""
    m, n = p
    return n < m and n >= 1 and gcd(m, n) == 1 and (m + n) % 2 == 1


def mv_L(p: Seed) -> Seed:
    m, n = p
    return (2 * m - n, m)


def mv_M(p: Seed) -> Seed:
    m, n = p
    return (2 * m + n, m)


def mv_R(p: Seed) -> Seed:
    m, n = p
    return (m + 2 * n, n)


MOVES = {"L": mv_L, "M": mv_M, "R": mv_R}
ROOT: Seed = (2, 1)


def seed_of_word(word: str) -> Seed:
    """Apply the letters of `word` right-to-left to the root, as in the tree."""
    p = ROOT
    for letter in reversed(word):
        p = MOVES[letter](p)
    return p


def hyp(p: Seed) -> int:
    """Hypotenuse c = m^2 + n^2."""
    m, n = p
    return m * m + n * n


def triple(p: Seed) -> Tuple[int, int, int]:
    """The primitive Pythagorean triple (m^2 - n^2, 2mn, m^2 + n^2)."""
    m, n = p
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def words_of_length(d: int) -> Iterator[str]:
    """All 3^d words of length d over {L, M, R}."""
    if d == 0:
        yield ""
        return
    for prefix in words_of_length(d - 1):
        for letter in "LMR":
            yield prefix + letter


def unravel(p: Seed) -> str:
    """Recover the unique Berggren word of an admissible seed (descent algorithm).

    Letters are peeled off from the outside in, so they are emitted in the same
    order in which they appear in the word.
    """
    assert is_seed(p), f"{p} is not an admissible seed"
    letters: List[str] = []
    m, n = p
    while (m, n) != ROOT:
        if m < 2 * n:
            letters.append("L")
            m, n = n, 2 * n - m
        elif m - 2 * n < n:
            letters.append("M")
            m, n = n, m - 2 * n
        else:
            letters.append("R")
            m, n = m - 2 * n, n
    return "".join(letters)


# --------------------------------------------------------------------------
# 2.  The seed bijection
# --------------------------------------------------------------------------

_SEED_CACHE: Dict[int, List[Seed]] = {}


def admissible_seeds_below(H: int) -> List[Seed]:
    """All admissible seeds with m^2 + n^2 <= H."""
    if H in _SEED_CACHE:
        return _SEED_CACHE[H]
    out: List[Seed] = []
    for m in range(2, isqrt(H) + 1):
        for n in range(1, m):
            if m * m + n * n > H:
                break
            if gcd(m, n) == 1 and (m + n) % 2 == 1:
                out.append((m, n))
    _SEED_CACHE[H] = out
    return out


def check_bijection(max_depth: int, H: int) -> None:
    print("2.  THE SEED BIJECTION")
    print("    ------------------")
    # (a) injectivity + admissibility on all words up to max_depth
    seen: Dict[Seed, str] = {}
    for d in range(max_depth + 1):
        for w in words_of_length(d):
            p = seed_of_word(w)
            assert is_seed(p), f"word {w!r} left the admissible set at {p}"
            assert p not in seen, f"collision: {w!r} and {seen[p]!r} both give {p}"
            seen[p] = w
    total = sum(3 ** d for d in range(max_depth + 1))
    print(f"    all {total} words of length <= {max_depth} give distinct admissible seeds")

    # (b) surjectivity: every admissible seed below H is reached, and unravels correctly
    for p in admissible_seeds_below(H):
        w = unravel(p)
        assert seed_of_word(w) == p, f"unravel failed at {p}"
    print(f"    every admissible seed with c <= {H} unravels to a word that regenerates it")
    print()


# --------------------------------------------------------------------------
# 3.  The growth dichotomy
# --------------------------------------------------------------------------

def demo_growth(max_depth: int = 8) -> None:
    print("3.  THE GROWTH DICHOTOMY")
    print("    --------------------")
    print("    silver speed limit:  c(w) <= 5 (3+2sqrt2)^|w|,  3+2sqrt2 = "
          f"{EPS_SQ:.6f}")
    print()
    print("      k    c(L^k)      c(M^k)  [Pell]     c(R^k)     limit 5(3+2r2)^k")
    for k in range(max_depth + 1):
        cl = hyp(seed_of_word("L" * k))
        cm = hyp(seed_of_word("M" * k))
        cr = hyp(seed_of_word("R" * k))
        limit = 5.0 * EPS_SQ ** k
        assert cl == 2 * k * k + 6 * k + 5
        assert cr == 4 * k * k + 8 * k + 5
        assert 4.0 * EPS_SQ ** k <= cm <= limit + 1e-9
        print(f"    {k:3d} {cl:10d} {cm:12d} {cr:10d} {limit:20.1f}")
    print()
    print("    L-spine  c = 2k^2 + 6k + 5   (quadratic  -> parabolic in effect)")
    print("    R-spine  c = 4k^2 + 8k + 5   (quadratic  -> parabolic in effect)")
    print("    M-spine  4(3+2r2)^k <= c <= 5(3+2r2)^k   (exponential, hyperbolic)")
    print()
    # maximal hypotenuse at each depth versus the speed limit
    print("      k   max_{|w|=k} c(w)   5(3+2r2)^k    ratio")
    for k in range(0, min(max_depth, 7) + 1):
        best = max(hyp(seed_of_word(w)) for w in words_of_length(k))
        limit = 5.0 * EPS_SQ ** k
        assert best <= limit + 1e-9
        print(f"    {k:3d} {best:17d} {limit:13.1f} {best / limit:8.4f}")
    print()


# --------------------------------------------------------------------------
# 4.  The counting function
# --------------------------------------------------------------------------

def count_nodes_below(H: int) -> int:
    """N(H) = #{w : c(w) <= H}, computed via the seed bijection."""
    return len(admissible_seeds_below(H))


def demo_counting(heights: Sequence[int] = (5, 50, 200, 1000, 10000, 100000)) -> None:
    print("4.  THE COUNTING FUNCTION N(H)")
    print("    --------------------------")
    print("    proved:   (1/3)(H/5)^sigma0  <=  N(H)  <=  (floor(sqrt H)+1)^2")
    print(f"    sigma0 = log 3 / (2 log(1+sqrt2)) = {SIGMA0:.6f}")
    print()
    print("        H      N(H)   (floor(rH)+1)^2    d_max   3^d   (1/3)(H/5)^s0   N(H)/H")
    for H in heights:
        N = count_nodes_below(H)
        upper = (isqrt(H) + 1) ** 2
        d = 0
        while 5.0 * EPS_SQ ** (d + 1) <= H:
            d += 1
        if 5.0 > H:
            d = 0
        silver_low = (1.0 / 3.0) * (H / 5.0) ** SIGMA0
        assert N <= upper, (H, N, upper)
        assert 3 ** d <= N, (H, N, d)
        assert silver_low <= N + 1e-9, (H, N, silver_low)
        print(f"    {H:7d} {N:9d} {upper:17d} {d:8d} {3 ** d:6d}"
              f" {silver_low:14.2f} {N / H:8.4f}")
    print()
    print("    N(H)/H tends to a positive constant: the true exponent is 1, not sigma0.")
    print()


# --------------------------------------------------------------------------
# 5.  The abscissa theorem
# --------------------------------------------------------------------------

def partial_tree_zeta(s: float, H: int) -> float:
    """Partial sum of sum_w c(w)^{-s} over all nodes with c(w) <= H."""
    return sum(hyp(p) ** (-s) for p in admissible_seeds_below(H))


def demo_abscissa(cutoffs: Sequence[int] = (10 ** 3, 10 ** 4, 10 ** 5, 10 ** 6)) -> None:
    print("5.  THE ABSCISSA THEOREM:  convergence  <=>  s > 1")
    print("    ---------------------------------------------")
    tested = [SIGMA0, log(1 + sqrt(2)), 0.9, 1.0, 1.1, 1.5, 2.0]
    labels = ["sigma0", "log eps", "0.9", "1.0 (critical)", "1.1", "1.5", "2.0"]
    header = "        s        " + "".join(f"{H:>13d}" for H in cutoffs)
    print(header)
    for s, lab in zip(tested, labels):
        row = "".join(f"{partial_tree_zeta(s, H):13.5f}" for H in cutoffs)
        print(f"    {lab:>14s} {row}")
    print()
    print("    For s <= 1 the partial sums keep climbing (divergence, driven by the")
    print("    fibres (m,n) = (2q, n) over primes q, contributing >= 1/(20 q) each).")
    print("    For s > 1 they visibly stabilise.")
    print()


# --------------------------------------------------------------------------
# 6.  The silver Ihara zeta and its critical line
# --------------------------------------------------------------------------

def silver_denom(s: complex) -> complex:
    """D(s) = 1 - 3 eps^{-2s}."""
    return 1.0 - 3.0 * cmath.exp(-2.0 * s * LOG_EPS)


def silver_zeta(s: complex) -> complex:
    """Z(s) = 1 / (1 - 3 eps^{-2s}), meromorphic on all of C."""
    return 1.0 / silver_denom(s)


def silver_pole(k: int) -> complex:
    """The k-th pole  s_k = sigma0 + i k pi / log eps."""
    return complex(SIGMA0, k * pi / LOG_EPS)


def demo_silver_zeta() -> None:
    print("6.  THE SILVER IHARA ZETA  Z(s) = 1/(1 - 3 eps^{-2s})")
    print("    -------------------------------------------------")
    print(f"    critical line  Re s = sigma0 = {SIGMA0:.9f}")
    print(f"    pole spacing   pi / log eps  = {POLE_SPACING:.9f}")
    print(f"    residue        1/(2 log eps) = {RESIDUE:.9f}")
    print()

    # (a) Dirichlet series equals the closed form on Re s > sigma0
    print("    (a)  sum_k 3^k eps^{-2ks}  =  Z(s)   for Re s > sigma0")
    for s in (complex(0.8, 0.0), complex(1.0, 2.0), complex(2.5, -1.0)):
        series = sum(3 ** k * cmath.exp(-2.0 * s * k * LOG_EPS) for k in range(400))
        closed = silver_zeta(s)
        print(f"         s = {s!s:>16}   series = {series:.8f}   closed = {closed:.8f}"
              f"   |diff| = {abs(series - closed):.2e}")
        assert abs(series - closed) < 1e-9
    print()

    # (b) the poles really are where the theorem says
    print("    (b)  |D(s)| on a grid: zeros occur only at Re s = sigma0, Im s in "
          "(pi/log eps) Z")
    print("            Re s \\ Im s" + "".join(f"{t:>11.3f}" for t in
                                               (0.0, 1.0, POLE_SPACING, 2 * POLE_SPACING)))
    for sigma in (SIGMA0 - 0.20, SIGMA0 - 0.02, SIGMA0, SIGMA0 + 0.02, SIGMA0 + 0.20):
        row = "".join(f"{abs(silver_denom(complex(sigma, t))):11.5f}" for t in
                      (0.0, 1.0, POLE_SPACING, 2 * POLE_SPACING))
        print(f"         {sigma:12.6f}{row}")
    print("         (the vanishing entries are exactly the row Re s = sigma0 at")
    print("          imaginary parts 0, pi/log eps, 2 pi/log eps)")
    print()

    # (c) no zeros
    print("    (c)  no zeros: |Z(s)| = 1/|D(s)| > 0 wherever D(s) != 0; sample minima")
    worst = min(abs(silver_zeta(complex(0.1 + 0.05 * i, -6.0 + 0.05 * j)))
                for i in range(40) for j in range(240)
                if abs(silver_denom(complex(0.1 + 0.05 * i, -6.0 + 0.05 * j))) > 1e-6)
    print(f"         min |Z| over a 40 x 240 grid = {worst:.6f}  (> 0)")
    print()

    # (d) functional equation
    print("    (d)  functional equation  Z(s + i pi/log eps) = Z(s)")
    for s in (complex(1.0, 0.3), complex(0.4, -2.2), complex(3.0, 5.0)):
        a, b = silver_zeta(s), silver_zeta(s + 1j * POLE_SPACING)
        print(f"         s = {s!s:>16}   |Z(s) - Z(s + i pi/log eps)| = {abs(a - b):.2e}")
        assert abs(a - b) < 1e-9
    print()

    # (e) simple poles with uniform residue
    print("    (e)  simple poles, residue 1/(2 log eps) at EVERY pole")
    print("           k        pole s_k                 numerical residue        error")
    for k in (-2, -1, 0, 1, 2, 7):
        s_k = silver_pole(k)
        assert abs(silver_denom(s_k)) < 1e-9
        # residue by the Cauchy integral (1/2 pi i) oint Z ds  on a small circle
        n_pts, r = 4096, 1e-3
        acc = 0j
        for j in range(n_pts):
            theta = 2.0 * pi * j / n_pts
            z = s_k + r * cmath.exp(1j * theta)
            acc += silver_zeta(z) * r * cmath.exp(1j * theta)
        res = acc / n_pts
        print(f"        {k:4d}   {s_k.real:.6f}{s_k.imag:+.6f}i    {res.real:.9f}"
              f"{res.imag:+.9f}i   {abs(res - RESIDUE):.2e}")
        assert abs(res - RESIDUE) < 1e-6
    print()


# --------------------------------------------------------------------------
# 7.  Prime hypotenuses
# --------------------------------------------------------------------------

def primes_up_to(N: int) -> List[int]:
    sieve = bytearray([1]) * (N + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, isqrt(N) + 1):
        if sieve[p]:
            sieve[p * p::p] = bytearray(len(sieve[p * p::p]))
    return [i for i in range(N + 1) if sieve[i]]


def demo_primes(H: int = 20000) -> None:
    print("7.  PRIME HYPOTENUSES = PRIMES CONGRUENT TO 1 MOD 4")
    print("    -----------------------------------------------")
    seeds = admissible_seeds_below(H)
    hyps = {hyp(p) for p in seeds}
    # every hypotenuse is 1 mod 4
    assert all(c % 4 == 1 for c in hyps)
    prime_hyps = sorted(c for c in hyps if _is_prime(c))
    target = [p for p in primes_up_to(H) if p % 4 == 1]
    assert prime_hyps == target, (prime_hyps[:10], target[:10])
    print(f"    every hypotenuse with c <= {H} satisfies c = 1 (mod 4):  verified")
    print(f"    prime hypotenuses below {H}: {len(prime_hyps)}")
    print(f"    primes = 1 (mod 4) below {H}: {len(target)}   -- identical sets")
    print(f"    first ten: {prime_hyps[:10]}")
    print()
    for p in prime_hyps[:6]:
        for q in seeds:
            if hyp(q) == p:
                print(f"      c = {p:6d}  seed {q}  triple {triple(q)}  word "
                      f"{unravel(q)!r}")
                break
    print()
    print("    Dirichlet density of prime hypotenuses inside the primes = 1/2.")
    print()


def _is_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in range(2, isqrt(n) + 1):
        if n % p == 0:
            return False
    return True


# --------------------------------------------------------------------------
# 8.  The purely hyperbolic subtree
# --------------------------------------------------------------------------

BLOCKS = {"1": "MM", "0": "MR"}


def block_word(bits: str) -> str:
    return "".join(BLOCKS[b] for b in bits)


def demo_subtree(max_bits: int = 12) -> None:
    print("8.  THE PURELY HYPERBOLIC SUBTREE  (blocks MM and MR)")
    print("    -------------------------------------------------")
    lo = log(2.0) / log(2.5)
    hi_div = log(2.0) / log(EPS_SQ ** 2)
    print(f"    proved: converges for s > log 2 / log(5/2)      = {lo:.6f}")
    print(f"            diverges  for 0 < s < log 2 / log((3+2r2)^2) = {hi_div:.6f}")
    print(f"            hence converges at s = 1 (where the full tree zeta diverges)")
    print()
    print("      d   #nodes   min c        max c     5(5/2)^d      5(3+2r2)^{2d}")
    for d in range(0, min(max_bits, 10) + 1):
        cs = [hyp(seed_of_word(block_word(format(i, f"0{d}b") if d else "")))
              for i in range(2 ** d)]
        lo_b, hi_b = 5.0 * 2.5 ** d, 5.0 * EPS_SQ ** (2 * d)
        assert min(cs) >= lo_b - 1e-9 and max(cs) <= hi_b + 1e-9
        print(f"    {d:3d} {len(cs):8d} {min(cs):8d} {max(cs):12d} {lo_b:12.1f}"
              f" {hi_b:18.1f}")
    print()
    print("    partial sums of the subtree zeta:")
    print("           s        sum over d <= 20")
    for s in (0.15, 0.5, 0.8, 1.0, 1.5):
        total = 0.0
        for d in range(0, 21):
            if d <= 12:
                total += sum(hyp(seed_of_word(block_word(format(i, f"0{d}b") if d else "")))
                             ** (-s) for i in range(2 ** d))
            else:
                # tail bounded above by the proved geometric estimate
                total += 2 ** d * (5.0 * 2.5 ** d) ** (-s)
        print(f"      {s:8.2f}   {total:18.6f}")
    print()
    print("    At s = 1 the sum is finite; at s = 0.15 < 0.1966 it blows up.")
    print()


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

def main() -> None:
    print("=" * 78)
    print("  THE BERGGREN TREE AND ITS ZETA FUNCTIONS -- NUMERICAL DEMONSTRATION")
    print("=" * 78)
    print()
    print("1.  THE TREE")
    print("    --------")
    print(f"    root seed {ROOT} -> triple {triple(ROOT)}")
    for w in ("L", "M", "R", "LM", "MM", "MR", "RRR"):
        p = seed_of_word(w)
        print(f"    word {w!r:>6}  seed {str(p):>10}  triple {str(triple(p)):>22}"
              f"  c = {hyp(p)}")
    print()

    check_bijection(max_depth=6, H=5000)
    demo_growth()
    demo_counting()
    demo_abscissa()
    demo_silver_zeta()
    demo_primes()
    demo_subtree()

    print("=" * 78)
    print("  All assertions passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
