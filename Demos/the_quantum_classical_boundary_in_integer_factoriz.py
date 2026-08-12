"""
Numerical demonstrations for
"Locating the Quantum-Classical Boundary in Period Finding".

Self-contained: standard library only (cmath, math, itertools, typing).
Run with:  python3 demo.py

Everything demonstrated here corresponds to a theorem stated in the paper:

  1. Sharp Peak Theorem          |C-hat(k)| = m if m | k, else 0 (exactly).
  2. Period extraction           k = j*m with gcd(j,r)=1  =>  k/n reduces to j/r.
  3. Rigidity                    peak-supported spectrum  <=>  r-periodic signal.
  4. Resolution bound            K < r  =>  two distinct period-r signals with
                                 identical Fourier samples at K frequencies.
  5. Small-order count           #{ord <= B} <= B * #{d | |G| : d <= B} <= B^2.
  6. Spectral hiding             N=15, a=7: fundamental bin is dominated by the
                                 second harmonic; peak picking returns a false
                                 period.
  7. Order-4 hiding criterion    (v0-v1+v2-v3)^2 > (v0-v2)^2 + (v1-v3)^2,
                                 and its density over N < 500.
  8. Uncertainty principle       #supp(v) * #supp(v-hat) >= n, with equality
                                 exactly for the coherent comb.
"""

from __future__ import annotations

import cmath
import math
from fractions import Fraction
from itertools import product
from typing import Callable, Dict, List, Optional, Sequence, Tuple

Complex = complex
Signal = List[Complex]

TOL = 1e-9


# --------------------------------------------------------------------------
# Core Fourier machinery (Definition 2.1 of the paper)
# --------------------------------------------------------------------------


def zeta(n: int) -> Complex:
    """The standard primitive n-th root of unity exp(2*pi*i/n)."""
    return cmath.exp(2j * cmath.pi / n)


def dft(v: Sequence[Complex]) -> Signal:
    """Forward transform  v-hat(k) = sum_x v(x) * zeta_n^(x k)."""
    n = len(v)
    w = zeta(n)
    return [sum(v[x] * w ** (x * k) for x in range(n)) for k in range(n)]


def idft(w: Sequence[Complex]) -> Signal:
    """Inverse transform  v(x) = (1/n) sum_k w(k) * zeta_n^(-x k)."""
    n = len(w)
    z = zeta(n)
    return [sum(w[k] * z ** (-x * k) for k in range(n)) / n for x in range(n)]


def support(v: Sequence[Complex], tol: float = TOL) -> List[int]:
    """Indices where the signal is (numerically) nonzero."""
    return [i for i, c in enumerate(v) if abs(c) > tol]


# --------------------------------------------------------------------------
# Number-theoretic helpers
# --------------------------------------------------------------------------


def multiplicative_order(a: int, N: int) -> Optional[int]:
    """Least r > 0 with a^r = 1 mod N, or None if gcd(a, N) != 1."""
    if math.gcd(a, N) != 1:
        return None
    x, r = a % N, 1
    while x != 1:
        x = (x * a) % N
        r += 1
    return r


def totient(n: int) -> int:
    """Euler's totient function."""
    return sum(1 for j in range(n) if math.gcd(j, n) == 1)


def divisors(n: int) -> List[int]:
    """All positive divisors of n."""
    return [d for d in range(1, n + 1) if n % d == 0]


# --------------------------------------------------------------------------
# The coherent comb (Definition 3.1)
# --------------------------------------------------------------------------


def comb_state(m: int, r: int, x0: int) -> Signal:
    """Indicator of {x < m*r : x = x0 mod r}: the coherent comb, m teeth."""
    return [1.0 + 0j if x % r == x0 else 0j for x in range(m * r)]


def comb_dft_closed_form(m: int, r: int, x0: int, k: int) -> Complex:
    """Theorem 3.3: zeta_{mr}^{x0 k} * (m if m | k else 0)."""
    return zeta(m * r) ** (x0 * k) * (m if k % m == 0 else 0)


# --------------------------------------------------------------------------
# 1. Sharp Peak Theorem
# --------------------------------------------------------------------------


def demo_sharp_peak(m: int = 5, r: int = 4, x0: int = 2) -> None:
    n = m * r
    c = comb_state(m, r, x0)
    spec = dft(c)
    print(f"\n[1] SHARP PEAK THEOREM   n = m*r = {m}*{r} = {n}, offset x0 = {x0}")
    print(f"    comb teeth (time support): {support(c)}   (size {len(support(c))} = m)")
    print("      k  |  |C-hat(k)|   predicted   m | k ?")
    for k in range(n):
        pred = abs(comb_dft_closed_form(m, r, x0, k))
        print(f"    {k:4d} |   {abs(spec[k]):8.5f}   {pred:8.5f}     {k % m == 0}")
        assert abs(abs(spec[k]) - pred) < 1e-8
    peaks = support(spec)
    print(f"    frequency support: {peaks}   (size {len(peaks)} = r)")
    print(f"    total energy sum |C-hat|^2 = {sum(abs(z)**2 for z in spec):.4f}"
          f"   (predicted n*m = {n*m})")
    assert len(peaks) == r and len(support(c)) == m


# --------------------------------------------------------------------------
# 2. Period extraction from a peak
# --------------------------------------------------------------------------


def period_from_peak(k: int, n: int) -> int:
    """Denominator of k/n in lowest terms (the continued-fraction step)."""
    return Fraction(k, n).denominator


def demo_period_extraction(m: int = 8, r: int = 6) -> None:
    n = m * r
    print(f"\n[2] PERIOD EXTRACTION   n = {n}, m = {m}, r = {r}")
    useful = 0
    for j in range(r):
        k = j * m
        den = period_from_peak(k, n)
        ok = math.gcd(j, r) == 1
        useful += ok
        flag = "recovers r" if den == r else f"gives {den}"
        print(f"    peak k = {j}*{m} = {k:3d}   gcd(j,r)={math.gcd(j,r)}   "
              f"k/n = {Fraction(k, n)}   -> {flag}")
        if ok:
            assert den == r
    print(f"    useful peaks: {useful} = phi({r}) = {totient(r)};  "
          f"per-run success probability {useful}/{r} = {useful/r:.3f}")
    assert useful == totient(r)


# --------------------------------------------------------------------------
# 3. Rigidity: peak-supported spectrum <=> r-periodic
# --------------------------------------------------------------------------


def demo_rigidity(m: int = 4, r: int = 3) -> None:
    n = m * r
    print(f"\n[3] RIGIDITY   n = {n} = {m}*{r}")
    # Build a random-looking spectrum supported only on multiples of m.
    spec: Signal = [0j] * n
    for idx, k in enumerate(range(0, n, m)):
        spec[k] = complex(1 + idx, 2 - idx)
    v = idft(spec)
    print("    signal reconstructed from a peak-supported spectrum:")
    print("      " + "  ".join(f"{z.real:+.3f}{z.imag:+.3f}i" for z in v))
    dev = max(abs(v[(x + r) % n] - v[x]) for x in range(n))
    print(f"    max |v(x+r) - v(x)| = {dev:.2e}   -> the signal is r-periodic")
    assert dev < 1e-8
    # Converse direction: an r-periodic signal has peak-supported spectrum.
    base = [3.0 + 0j, -1.0 + 2j, 0.5 - 1j]
    w = [base[x % r] for x in range(n)]
    ws = dft(w)
    off = max(abs(ws[k]) for k in range(n) if k % m != 0)
    print(f"    conversely, an r-periodic signal has max off-peak bin {off:.2e}")
    assert off < 1e-8


# --------------------------------------------------------------------------
# 4. Resolution bound: K < r samples cannot determine the period
# --------------------------------------------------------------------------


def demo_resolution_bound(r: int = 5, frequencies: Tuple[int, ...] = (0, 1, 3)) -> None:
    print(f"\n[4] RESOLUTION BOUND   period r = {r}, "
          f"K = {len(frequencies)} sampled frequencies {frequencies}")
    # A signal in the kernel of the sampling map: put a single unit mass on a
    # frequency that is NOT sampled, and invert.
    unsampled = [k for k in range(r) if k not in frequencies]
    ghost_spec: Signal = [0j] * r
    ghost_spec[unsampled[0]] = 1.0 + 0j
    ghost = idft(ghost_spec)
    v: Signal = [complex(x * x % 7) for x in range(r)]
    w = [v[x] + ghost[x] for x in range(r)]
    dv, dw = dft(v), dft(w)
    print(f"    signal v      : " + "  ".join(f"{z.real:+.3f}" for z in v))
    print(f"    signal w = v+u: " + "  ".join(f"{z.real:+.3f}" for z in w))
    print(f"    max |v - w| over time = {max(abs(a-b) for a, b in zip(v, w)):.4f}"
          f"   (the two signals are DISTINCT)")
    diff = max(abs(dv[k] - dw[k]) for k in frequencies)
    print(f"    max |v-hat(k) - w-hat(k)| over the sampled k = {diff:.2e}"
          f"   (the SAMPLES are identical)")
    assert diff < 1e-8 and max(abs(a - b) for a, b in zip(v, w)) > 0.1
    print(f"    => with K = {len(frequencies)} < r = {r} the period is "
          f"information-theoretically undetermined.")


# --------------------------------------------------------------------------
# 5. Small-order count in a cyclic group
# --------------------------------------------------------------------------


def demo_small_order_count(p: int = 101) -> None:
    print(f"\n[5] SMALL-ORDER COUNT in (Z/{p}Z)^*   |G| = {p-1}")
    orders = {a: multiplicative_order(a, p) for a in range(1, p)}
    print("      B  | #{ord <= B} | B*#{d | |G|, d <= B} |  B^2  | |G|")
    for B in (2, 4, 8, 10, 16, 25):
        small = sum(1 for o in orders.values() if o is not None and o <= B)
        dbound = B * sum(1 for d in divisors(p - 1) if d <= B)
        print(f"    {B:4d} | {small:10d} | {dbound:20d} | {B*B:5d} | {p-1}")
        assert small <= dbound <= B * B or small <= B * B
        assert small <= dbound
    B = math.isqrt(p - 2)
    best = max(o for o in orders.values() if o is not None)
    witness = max((a for a in orders if orders[a] == best))
    print(f"    floor(sqrt(p-2)) = {B};  a = {witness} has order {best} > {B}")
    majority = sum(1 for o in orders.values() if o is not None and o > B)
    print(f"    bases of order > {B}: {majority} of {p-1} "
          f"({100*majority/(p-1):.1f}%)  [majority guaranteed when 2B^2 < |G|: "
          f"{2*B*B} < {p-1} is {2*B*B < p-1}]")
    assert best > B


# --------------------------------------------------------------------------
# 6-7. Spectral hiding in the value signal
# --------------------------------------------------------------------------


def value_signal(N: int, a: int, r: int) -> Signal:
    """The classical value signal x -> (a^x mod N), x = 0..r-1."""
    return [complex(pow(a, x, N)) for x in range(r)]


def hiding_criterion(N: int, a: int) -> Tuple[int, int, bool]:
    """Order-4 criterion: returns (|V(1)|^2, |V(2)|^2, fundamental_dominated)."""
    v = [pow(a, i, N) for i in range(4)]
    fund = (v[0] - v[2]) ** 2 + (v[1] - v[3]) ** 2
    harm = (v[0] - v[1] + v[2] - v[3]) ** 2
    return fund, harm, harm > fund


def demo_spectral_hiding() -> None:
    N, a = 15, 7
    r = multiplicative_order(a, N)
    v = value_signal(N, a, r)
    spec = dft(v)
    print(f"\n[6] SPECTRAL HIDING   N = {N}, a = {a}, order r = {r}")
    print(f"    residues a^x mod N: {[int(z.real) for z in v]}")
    for k in range(r):
        print(f"      V-hat({k}) = {spec[k].real:+7.3f} {spec[k].imag:+7.3f}i    "
              f"|V-hat({k})| = {abs(spec[k]):8.5f}")
    assert abs(spec[1] - (-3 - 6j)) < 1e-8 and abs(spec[2] - (-15)) < 1e-8
    print(f"    fundamental |V-hat(1)| = sqrt(45) = {math.sqrt(45):.5f}")
    print(f"    2nd harmonic |V-hat(2)| = {abs(spec[2]):.5f}")
    print("    => the fundamental is DOMINATED by the second harmonic.")
    winner = max(range(1, r), key=lambda k: abs(spec[k]))
    claimed = r // winner
    print(f"    naive peak picking selects k = {winner}, reporting period "
          f"{r}/{winner} = {claimed}")
    print(f"    check: {a}^{claimed} mod {N} = {pow(a, claimed, N)} "
          f"(should be 1 if {claimed} were the order)  ->  WRONG ANSWER")
    print(f"    all bins nonzero? {all(abs(z) > TOL for z in spec)}  "
          "(no frequency can be discarded)")
    assert winner == 2 and pow(a, claimed, N) != 1


def demo_hiding_criterion_and_density(limit: int = 500) -> None:
    print(f"\n[7] ORDER-4 HIDING CRITERION and its density (N < {limit})")
    print("     (N, a)  residues        |V(1)|^2   |V(2)|^2   hidden?")
    for (N, a) in [(15, 7), (15, 13), (20, 13), (39, 31), (16, 7)]:
        if multiplicative_order(a, N) != 4:
            continue
        fund, harm, hidden = hiding_criterion(N, a)
        res = [pow(a, i, N) for i in range(4)]
        print(f"    {str((N,a)):>9}  {str(res):<15} {fund:8d}   {harm:8d}   {hidden}")
        # cross-check against the numerically computed transform
        spec = dft(value_signal(N, a, 4))
        assert (abs(spec[1]) < abs(spec[2])) == hidden
    total = hits = 0
    for N in range(3, limit):
        for a in range(2, N):
            if math.gcd(a, N) != 1:
                continue
            if multiplicative_order(a, N) == 4:
                total += 1
                hits += hiding_criterion(N, a)[2]
    print(f"    exhaustive scan: {hits} of {total} order-4 pairs hide the "
          f"fundamental  ({100*hits/total:.1f}%)")


# --------------------------------------------------------------------------
# 8. Uncertainty principle and comb extremality
# --------------------------------------------------------------------------


def demo_uncertainty(n: int = 12) -> None:
    print(f"\n[8] DISCRETE UNCERTAINTY PRINCIPLE   n = {n}")
    print("    signal                        #supp(v)  #supp(v-hat)   product   >= n?")

    def report(name: str, v: Signal) -> Tuple[int, int]:
        s, t = len(support(v)), len(support(dft(v)))
        print(f"    {name:<28} {s:8d}  {t:12d}   {s*t:7d}   {s*t >= n}")
        assert s * t >= n
        return s, t

    delta: Signal = [0j] * n
    delta[3] = 1.0 + 0j
    report("single spike", delta)
    report("constant", [1.0 + 0j] * n)
    report("pseudorandom", [complex((7 ** x) % 13) for x in range(n)])
    report("two spikes", [1.0 + 0j if x in (0, 5) else 0j for x in range(n)])

    print("\n    coherent combs (extremal cases):")
    for m, r in [(1, 12), (2, 6), (3, 4), (4, 3), (6, 2), (12, 1)]:
        s, t = report(f"comb m={m}, r={r}", comb_state(m, r, 0))
        assert s * t == n, "the comb must SATURATE the bound"
    print("    every comb attains  #supp(v) * #supp(v-hat) = m*r = n  exactly.")


# --------------------------------------------------------------------------
# Side-by-side summary: same transform, two inputs
# --------------------------------------------------------------------------


def demo_boundary_summary() -> None:
    print("\n[9] THE BOUNDARY IN ONE PICTURE   (same transform, two inputs)")
    N, a = 15, 7
    r = 4
    m = 4                      # register n = m*r = 16
    n = m * r
    classical = dft(value_signal(N, a, r))
    quantum = dft(comb_state(m, r, 1))
    print(f"    classical value signal (N={N}, a={a}, length {r}):")
    print("       " + "  ".join(f"{abs(z):7.3f}" for z in classical))
    print(f"       nonzero bins: {len(support(classical))}/{r}  "
          f"max non-DC bin at k = "
          f"{max(range(1, r), key=lambda k: abs(classical[k]))} (false period)")
    print(f"    coherent comb (n = {n}, r = {r}, m = {m}):")
    print("       " + "  ".join(f"{abs(z):5.2f}" for z in quantum))
    print(f"       nonzero bins: {len(support(quantum))}/{n}  "
          f"peak height {max(abs(z) for z in quantum):.2f} = m  "
          f"(period recovered exactly)")


def main() -> None:
    print("=" * 78)
    print(" The quantum-classical boundary in period finding: numerical evidence")
    print("=" * 78)
    demo_sharp_peak()
    demo_period_extraction()
    demo_rigidity()
    demo_resolution_bound()
    demo_small_order_count()
    demo_spectral_hiding()
    demo_hiding_criterion_and_density()
    demo_uncertainty()
    demo_boundary_summary()
    print("\nAll assertions passed: every numerical check matches the theorems.")


if __name__ == "__main__":
    main()
