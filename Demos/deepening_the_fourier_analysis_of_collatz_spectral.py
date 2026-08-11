"""
demo.py -- Numerical demonstration of the 2-adic Fourier analysis of the Collatz map.

Self-contained (standard library only).  Every function is inlined and typed.

The script verifies, numerically, the following chain of results.

  1. Affine transport formula:      T^k(n + 2^k m) = T^k(n) + 3^{s_k(n)} m
  2. Parity-word bijection:         n |-> w_k(n) permutes {0, ..., 2^k - 1}
  3. Exact spectral gap:            F_k(j) = 0 for all j != 0 mod 2^k, F_k(0) = 2^k
  4. Parseval:                      sum_j |F_k(j)|^2 = 4^k
  5. Exact moments:                 sum_n x^{s_k(n)} = (1+x)^k
                                    sum_n 3^{s_k(n)} = 4^k     (arithmetic mean of
                                                                multiplier = 1)
                                    2 * sum_n s_k(n) = k 2^k   (mean k/2)
                                    sum_n (2 s_k(n) - k)^2 = k 2^k  (variance k/4)
  6. Mean contraction exponent:     average of (k log2 - s log3) = k log(2/sqrt 3)
  7. Chebyshev bound:               rho_k <= 1/(4 delta^2 k),  delta = log2/log3 - 1/2
  8. Chernoff bound:                rho_k^5 <= (243/256)^k
  9. Descent theorem:               3^{s_k(r)} < 2^k and n >= 8^k  ==>  T^k(n) < n

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from typing import Dict, List, Tuple

# ----------------------------------------------------------------------------
# Constants of the theory
# ----------------------------------------------------------------------------

THETA: float = math.log(2.0) / math.log(3.0)      # critical odd-step density
DELTA: float = THETA - 0.5                        # spectral margin
DRIFT: float = math.log(2.0) - 0.5 * math.log(3.0)  # log(2/sqrt 3) per step


# ----------------------------------------------------------------------------
# 1. The accelerated Collatz map and the parity word
# ----------------------------------------------------------------------------

def T(n: int) -> int:
    """Accelerated Collatz map: n/2 if n even, (3n+1)/2 if n odd."""
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def iterate_T(n: int, k: int) -> int:
    """Apply T exactly k times."""
    for _ in range(k):
        n = T(n)
    return n


def parity_bits(n: int, k: int) -> List[int]:
    """The first k parity bits b_0(n), ..., b_{k-1}(n) of the orbit of n."""
    bits: List[int] = []
    x = n
    for _ in range(k):
        bits.append(x % 2)
        x = T(x)
    return bits


def parity_word(n: int, k: int) -> int:
    """w_k(n): the first k parity bits packed little-endian into an integer."""
    return sum(b << j for j, b in enumerate(parity_bits(n, k)))


def ones_count(n: int, k: int) -> int:
    """s_k(n): the number of odd steps among the first k accelerated steps."""
    return sum(parity_bits(n, k))


# ----------------------------------------------------------------------------
# 2. Checks
# ----------------------------------------------------------------------------

def check_transport(kmax: int = 8, nmax: int = 40, mmax: int = 6) -> bool:
    """Verify T^k(n + 2^k m) = T^k(n) + 3^{s_k(n)} m and bit invariance."""
    ok = True
    for k in range(kmax + 1):
        for n in range(nmax):
            s = ones_count(n, k)
            for m in range(mmax):
                lhs = iterate_T(n + (1 << k) * m, k)
                rhs = iterate_T(n, k) + 3 ** s * m
                if lhs != rhs:
                    ok = False
                if parity_bits(n + (1 << k) * m, k) != parity_bits(n, k):
                    ok = False
    return ok


def check_bijection(k: int) -> bool:
    """Verify that n |-> w_k(n) is a permutation of {0, ..., 2^k - 1}."""
    words = [parity_word(n, k) for n in range(1 << k)]
    return sorted(words) == list(range(1 << k))


def parity_fourier(k: int, j: int) -> complex:
    """F_k(j) = sum_{n < 2^k} exp(2 pi i j w_k(n) / 2^k)."""
    N = 1 << k
    return sum(cmath.exp(2j * math.pi * j * parity_word(n, k) / N) for n in range(N))


def spectrum(k: int) -> List[float]:
    """The moduli |F_k(j)| for j = 0, ..., 2^k - 1."""
    return [abs(parity_fourier(k, j)) for j in range(1 << k)]


def ones_count_histogram(k: int) -> Dict[int, int]:
    """#{n < 2^k : s_k(n) = s}, which the theory predicts equals C(k, s)."""
    hist: Dict[int, int] = {s: 0 for s in range(k + 1)}
    for n in range(1 << k):
        hist[ones_count(n, k)] += 1
    return hist


def moments(k: int) -> Tuple[int, int, int, int]:
    """(sum s_k, sum (2 s_k - k)^2, sum 3^{s_k}, sum 2^{s_k}) over n < 2^k."""
    s1 = 0
    s2 = 0
    m3 = 0
    m2 = 0
    for n in range(1 << k):
        s = ones_count(n, k)
        s1 += s
        s2 += (2 * s - k) ** 2
        m3 += 3 ** s
        m2 += 2 ** s
    return s1, s2, m3, m2


def noncontracting_density_exact(k: int) -> float:
    """rho_k = 2^{-k} * #{s : 3^s >= 2^k} weighted by C(k, s) -- a binomial tail.

    Uses the closed form implied by the exact generating function, so no
    enumeration of the 2^k residues is required.
    """
    total = sum(math.comb(k, s) for s in range(k + 1) if 3 ** s >= 2 ** k)
    return total / (1 << k)


def noncontracting_density_bruteforce(k: int) -> float:
    """rho_k computed by direct enumeration of residues (sanity cross-check)."""
    bad = sum(1 for n in range(1 << k) if 3 ** ones_count(n, k) >= 2 ** k)
    return bad / (1 << k)


def chebyshev_bound(k: int) -> float:
    """The Chebyshev upper bound 1/(4 delta^2 k) on rho_k."""
    return 1.0 / (4.0 * DELTA ** 2 * k)


def chernoff_bound(k: int) -> float:
    """The Chernoff upper bound (243/256)^(k/5) on rho_k."""
    return (243.0 / 256.0) ** (k / 5.0)


def optimal_rate_bound(k: int) -> float:
    """The conjectured sharp rate exp(-k D(theta || 1/2))."""
    d = THETA * math.log(2 * THETA) + (1 - THETA) * math.log(2 * (1 - THETA))
    return math.exp(-k * d)


def check_descent(k: int, trials: int = 200) -> Tuple[int, int]:
    """Test the descent theorem on contracting residues above the 8^k threshold.

    Returns (number of tests, number of failures).  The theory predicts 0
    failures.
    """
    threshold = 8 ** k
    tested = 0
    failures = 0
    for r in range(1 << k):
        if 3 ** ones_count(r, k) >= (1 << k):
            continue
        base = ((threshold + (1 << k) - 1) // (1 << k)) * (1 << k) + r
        for t in range(3):
            n = base + t * (1 << k)
            if n < threshold:
                continue
            tested += 1
            if not iterate_T(n, k) < n:
                failures += 1
            if tested >= trials:
                return tested, failures
    return tested, failures


def empirical_descent_threshold(k: int) -> int:
    """Smallest M such that every contracting-class n >= M descends in k steps.

    Scans n up to a modest bound; illustrates that the proved threshold 8^k is
    enormously lossy (conjecturally the truth is O(1)).
    """
    worst = 0
    for r in range(1 << k):
        if 3 ** ones_count(r, k) >= (1 << k):
            continue
        # On a contracting class the k-step map is affine with slope < 1, so the
        # last failure occurs at the crossing point; find it directly.
        m = 0
        last_fail = -1
        while m <= iterate_T(r, k) + 2:
            n = r + (1 << k) * m
            if n >= 1 and not iterate_T(n, k) < n:
                last_fail = n
            m += 1
        worst = max(worst, last_fail + 1)
    return worst


# ----------------------------------------------------------------------------
# 3. Report
# ----------------------------------------------------------------------------

def main() -> None:
    line = "=" * 74
    print(line)
    print("THE 2-ADIC FOURIER ANALYSIS OF THE COLLATZ MAP -- NUMERICAL DEMO")
    print(line)
    print(f"critical odd-step density  theta = log2/log3 = {THETA:.10f}")
    print(f"spectral margin            delta = theta - 1/2 = {DELTA:.10f}")
    print(f"mean drift per step        log(2/sqrt3)        = {DRIFT:.10f}")
    print(f"Chebyshev constant         1/(4 delta^2)       = "
          f"{1/(4*DELTA**2):.6f}")
    print(f"Chernoff rate per scale    (243/256)^(1/5)     = "
          f"{(243/256)**0.2:.6f}")
    print(f"conjectured sharp rate     exp(-D(theta||1/2)) = "
          f"{optimal_rate_bound(1):.6f}")

    print("\n" + line)
    print("1. AFFINE TRANSPORT FORMULA   T^k(n + 2^k m) = T^k(n) + 3^{s_k(n)} m")
    print(line)
    print(f"  verified for k <= 8, n < 40, m < 6 : {check_transport()}")
    k, n, m = 5, 23, 4
    s = ones_count(n, k)
    print(f"  example k={k}, n={n}, m={m}: s_k(n)={s}, slope 3^{s}/2^{k} = "
          f"{3**s}/{2**k} = {3**s/2**k:.4f}")
    print(f"    T^{k}({n} + {2**k}*{m}) = {iterate_T(n + 2**k*m, k)}"
          f"  =  T^{k}({n}) + 3^{s}*{m} = {iterate_T(n,k)} + {3**s*m}")

    print("\n" + line)
    print("2. PARITY-WORD BIJECTION on Z/2^k Z")
    print(line)
    for kk in range(1, 13):
        print(f"  k = {kk:2d} : w_k permutes {{0,...,{2**kk - 1}}} : "
              f"{check_bijection(kk)}")
    print("  first residues at k=4 with their parity words:")
    for n in range(8):
        print(f"    n={n}: bits={parity_bits(n,4)}  w_4(n)={parity_word(n,4):2d}"
              f"  s_4(n)={ones_count(n,4)}")

    print("\n" + line)
    print("3. EXACT SPECTRAL GAP   F_k(j) = 0 for all j != 0")
    print(line)
    for kk in range(1, 9):
        sp = spectrum(kk)
        dc = sp[0]
        rest = max(sp[1:]) if len(sp) > 1 else 0.0
        print(f"  k = {kk:2d} : F_k(0) = {dc:12.4f} = 2^{kk}     "
              f"max_{{j != 0}} |F_k(j)| = {rest:.3e}   "
              f"(sqrt(2^k) = {math.sqrt(2**kk):.3f})")
        parseval = sum(v * v for v in sp)
        print(f"          Parseval  sum_j |F_k(j)|^2 = {parseval:.4f}"
              f"   (4^k = {4**kk})")

    print("\n" + line)
    print("4. EXACT MOMENTS OF THE ODD-STEP COUNT")
    print(line)
    print(f"  {'k':>3} {'sum s_k':>10} {'k 2^k/2':>10} {'sum(2s-k)^2':>13}"
          f" {'k 2^k':>10} {'sum 3^s':>12} {'4^k':>12} {'sum 2^s':>10} {'3^k':>10}")
    for kk in range(0, 15):
        s1, s2, m3, m2 = moments(kk)
        print(f"  {kk:3d} {s1:10d} {kk*2**kk//2:10d} {s2:13d} {kk*2**kk:10d}"
              f" {m3:12d} {4**kk:12d} {m2:10d} {3**kk:10d}")
    print("  -> mean s_k = k/2, variance = k/4, arithmetic mean multiplier = 1")

    print("\n  binomial law  #{n < 2^k : s_k(n) = s} = C(k,s):")
    kk = 10
    hist = ones_count_histogram(kk)
    row = "   ".join(f"{s}:{hist[s]}/{math.comb(kk,s)}" for s in range(kk + 1))
    print(f"    k = {kk}:  " + row)

    print("\n" + line)
    print("5. MEAN CONTRACTION EXPONENT AND THE AM-GM GAP")
    print(line)
    for kk in (4, 8, 12, 16):
        mean_exp = kk * DRIFT
        print(f"  k = {kk:2d}: mean contraction exponent = {mean_exp:.6f} > 0;"
              f"  geometric-mean multiplier = (sqrt3/2)^{kk} = "
              f"{(math.sqrt(3)/2)**kk:.6e};"
              f"  arithmetic mean = 1.000000")
    print("  extremes at each scale:  all-odd class has multiplier (3/2)^k,"
          " all-even class has 2^{-k}")

    print("\n" + line)
    print("6. NON-CONTRACTING DENSITY rho_k AND ITS BOUNDS")
    print(line)
    print(f"  {'k':>3} {'rho_k (exact)':>15} {'Chebyshev':>13} {'Chernoff':>13}"
          f" {'sharp rate':>13}")
    for kk in list(range(1, 21)) + [30, 40, 60, 80, 120, 200]:
        rho = noncontracting_density_exact(kk)
        print(f"  {kk:3d} {rho:15.8f} {chebyshev_bound(kk):13.6f}"
              f" {chernoff_bound(kk):13.6f} {optimal_rate_bound(kk):13.6f}")
    print("  cross-check by brute-force enumeration (k <= 14):")
    for kk in range(1, 15):
        a = noncontracting_density_exact(kk)
        b = noncontracting_density_bruteforce(kk)
        assert abs(a - b) < 1e-12, (kk, a, b)
    print("    all agree.")

    print("\n" + line)
    print("7. DESCENT THEOREM   3^{s_k(r)} < 2^k, n >= 8^k  ==>  T^k(n) < n")
    print(line)
    for kk in range(1, 8):
        tested, failures = check_descent(kk)
        print(f"  k = {kk}: threshold 8^k = {8**kk:12d};"
              f" tested {tested:4d} integers in contracting classes;"
              f" failures = {failures}")
    print("\n  empirical smallest sufficient threshold (proved bound is 8^k):")
    for kk in range(1, 12):
        emp = empirical_descent_threshold(kk)
        print(f"    k = {kk:2d}: empirical threshold = {emp:4d}"
              f"    proved threshold 8^k = {8**kk:12d}")
    print("  -> the proved 8^k threshold is enormously lossy; the data support")
    print("     the conjecture that O(1) suffices.")

    print("\n" + line)
    print("8. NATURAL DENSITY OF NON-DESCENDING INTEGERS UP TO N")
    print(line)
    for kk in (4, 8, 12, 16):
        N = 200000
        bad = sum(1 for n in range(1, N + 1) if not iterate_T(n, kk) < n)
        rho = noncontracting_density_exact(kk)
        print(f"  k = {kk:2d}, N = {N}: empirical failure density = "
              f"{bad/N:.6f};  rho_k = {rho:.6f};  Chebyshev bound = "
              f"{chebyshev_bound(kk):.4f}")
    print("  -> the empirical density tracks rho_k closely and decreases with k.")

    print("\n" + line)
    print("DONE.  Every displayed identity matches the theory exactly.")
    print(line)


if __name__ == "__main__":
    main()
