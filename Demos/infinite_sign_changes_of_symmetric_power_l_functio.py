"""
Infinite Sign Changes of Symmetric-Power L-Function Coefficients
over Sums of m Squares — Numerical Demonstrations
================================================================

This self-contained script illustrates the main results:

  1. The four-square collapse: for every m >= 4, every natural number is a
     sum of m squares (Lagrange's theorem plus zero-padding), so the
     representability constraint is vacuous.

  2. The two-square boundary: the set of sums of two squares is a thin,
     density-zero set that misses the residue class 3 (mod 4).

  3. Sign oscillation of the normalised coefficients lambda_{sym^j f}(n)
     of a Hecke eigenform f (here the weight-12 cusp form Delta, whose
     coefficients are the Ramanujan tau values), and the resulting
     infinitely-many sign changes over sums of m squares for all even m.

Everything below uses only the Python standard library.
"""

from __future__ import annotations

import math
from typing import Dict, List, Tuple


# ---------------------------------------------------------------------------
# 1. Sums of m squares
# ---------------------------------------------------------------------------

def four_square_decomposition(n: int) -> Tuple[int, int, int, int]:
    """Return (a, b, c, d) with a^2 + b^2 + c^2 + d^2 = n (Lagrange).

    A direct search; Lagrange's four-square theorem guarantees a solution
    exists for every non-negative integer n.
    """
    if n < 0:
        raise ValueError("n must be non-negative")
    a = 0
    while a * a <= n:
        ra = n - a * a
        b = a
        while b * b <= ra:
            rb = ra - b * b
            c = b
            while c * c <= rb:
                rc = rb - c * c
                d = math.isqrt(rc)
                if d * d == rc:
                    return (a, b, c, d)
                c += 1
            b += 1
        a += 1
    raise RuntimeError("unreachable: Lagrange guarantees a decomposition")


def sum_of_m_squares_decomposition(m: int, n: int) -> List[int]:
    """Return a length-m list of non-negative integers whose squares sum to n.

    For m >= 4 this always succeeds: take a four-square decomposition and pad
    with (m - 4) zeros.  This is the algorithmic content of the *collapse*
    theorem: the constraint "n is a sum of m squares" is vacuous for m >= 4.
    """
    if m < 4:
        raise ValueError("this padding argument requires m >= 4")
    a, b, c, d = four_square_decomposition(n)
    return [a, b, c, d] + [0] * (m - 4)


def is_sum_of_two_squares(n: int) -> bool:
    """True iff n is a sum of two squares.

    Fermat/Euler: n is a sum of two squares iff every prime p == 3 (mod 4)
    divides n to an even power.
    """
    if n < 0:
        return False
    if n == 0:
        return True
    m = n
    p = 2
    while p * p <= m:
        if m % p == 0:
            e = 0
            while m % p == 0:
                m //= p
                e += 1
            if p % 4 == 3 and e % 2 == 1:
                return False
        p += 1
    # leftover prime factor m (if > 1)
    if m > 1 and m % 4 == 3:
        return False
    return True


# ---------------------------------------------------------------------------
# 2. Hecke eigenform data: the Ramanujan tau function
# ---------------------------------------------------------------------------

def ramanujan_tau(limit: int) -> List[int]:
    """Compute tau(0..limit) where Delta(q) = q * prod_{n>=1} (1 - q^n)^24.

    Returns a list T with T[n] = tau(n) (and T[0] = 0).  tau is the sequence
    of Fourier coefficients of the unique normalised weight-12 cusp form for
    SL(2, Z); it is a Hecke eigenform, so tau is multiplicative.
    """
    N = limit
    # series for prod_{n>=1} (1 - q^n)^24, up to q^N
    prod = [0] * (N + 1)
    prod[0] = 1
    for n in range(1, N + 1):
        # multiply current product by (1 - q^n)^24
        # (1 - q^n)^24 = sum_{k} C(24, k) (-1)^k q^{n k}
        binom = [math.comb(24, k) * (-1) ** k for k in range(24 + 1)]
        new = [0] * (N + 1)
        for i in range(N + 1):
            if prod[i] == 0:
                continue
            for k in range(25):
                j = i + n * k
                if j > N:
                    break
                new[j] += prod[i] * binom[k]
        prod = new
    # Delta = q * prod, so tau(n) = prod-coefficient at degree n-1
    tau = [0] * (N + 1)
    for n in range(1, N + 1):
        tau[n] = prod[n - 1]
    return tau


# ---------------------------------------------------------------------------
# 3. Symmetric-power coefficients lambda_{sym^j f}(n)
# ---------------------------------------------------------------------------

def primes_up_to(N: int) -> List[int]:
    sieve = [True] * (N + 1)
    if N >= 0:
        sieve[0] = False
    if N >= 1:
        sieve[1] = False
    for p in range(2, math.isqrt(N) + 1):
        if sieve[p]:
            for q in range(p * p, N + 1, p):
                sieve[q] = False
    return [p for p in range(2, N + 1) if sieve[p]]


def local_sympow_coeffs(theta: float, j: int, e_max: int) -> List[float]:
    """Local coefficients lambda_{sym^j f}(p^e) for e = 0..e_max.

    The Satake parameters of f at p are e^{+-i theta}.  The sym^j lift has
    the j+1 Satake roots z_i = e^{i (j - 2 i) theta}, i = 0..j.  The local
    Dirichlet series is prod_i 1 / (1 - z_i x), so lambda_{sym^j f}(p^e) is
    the complete homogeneous symmetric polynomial h_e of the roots, obtained
    here as the truncated power-series coefficient.  The roots come in
    conjugate pairs, so the result is real.
    """
    # roots as complex numbers
    roots = [complex(math.cos((j - 2 * i) * theta), math.sin((j - 2 * i) * theta))
             for i in range(j + 1)]
    series = [0j] * (e_max + 1)
    series[0] = 1 + 0j
    for z in roots:
        new = [0j] * (e_max + 1)
        # multiply series by 1/(1 - z x) = sum_e z^e x^e
        for e in range(e_max + 1):
            acc = 0j
            zk = 1 + 0j
            for k in range(e + 1):
                acc += series[e - k] * zk
                zk *= z
            new[e] = acc
        series = new
    return [c.real for c in series]


def symmetric_power_coefficients(j: int, N: int) -> List[float]:
    """Compute lambda_{sym^j f}(1..N) for f = Delta (weight 12).

    lambda_f(n) = tau(n) / n^{11/2} is the analytic normalisation making
    |lambda_f(p)| <= 2 (Deligne).  We build lambda_{sym^j f} multiplicatively
    from local factors at each prime.
    """
    tau = ramanujan_tau(N)
    lam = [0.0] * (N + 1)  # lambda_{sym^j f}(n)
    lam[1] = 1.0
    primes = primes_up_to(N)
    # precompute local coefficients at each prime
    for p in primes:
        # normalised lambda_f(p) = tau(p) / p^{11/2} = 2 cos theta_p
        lp = tau[p] / (p ** 5.5)
        lp = max(-2.0, min(2.0, lp))
        theta = math.acos(lp / 2.0)
        # max exponent e with p^e <= N
        e_max = 0
        while p ** (e_max + 1) <= N:
            e_max += 1
        loc = local_sympow_coeffs(theta, j, e_max)
        # fold this prime's local factor into lam via multiplicativity
        new = lam[:]
        for e in range(1, e_max + 1):
            pe = p ** e
            coeff = loc[e]
            base = 1
            while base * pe <= N:
                if base == 1 or (base % p != 0):
                    # base is coprime to p (base==1 handled), or not divisible
                    if base % p != 0:
                        n = base * pe
                        new[n] = lam[base] * coeff
                base += 1
        lam = new
    return lam


# ---------------------------------------------------------------------------
# 4. Sign-change counting
# ---------------------------------------------------------------------------

def sign_changes(values: List[float]) -> int:
    """Count sign changes in a sequence, ignoring exact zeros."""
    prev = 0
    changes = 0
    for v in values:
        s = (v > 0) - (v < 0)
        if s == 0:
            continue
        if prev != 0 and s != prev:
            changes += 1
        prev = s
    return changes


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_collapse(m_values: List[int], sample: List[int]) -> None:
    print("=" * 70)
    print("DEMO 1: The four-square collapse  (every n is a sum of m squares)")
    print("=" * 70)
    for m in m_values:
        ok = True
        for n in sample:
            decomp = sum_of_m_squares_decomposition(m, n)
            assert len(decomp) == m and sum(x * x for x in decomp) == n
        print(f"  m = {m:2d}: verified n is a sum of {m} squares for all "
              f"tested n in {min(sample)}..{max(sample)}  ->  constraint vacuous")
    print()


def demo_two_squares(N: int) -> None:
    print("=" * 70)
    print("DEMO 2: The two-square boundary is thin (density zero)")
    print("=" * 70)
    reps = [n for n in range(1, N + 1) if is_sum_of_two_squares(n)]
    print(f"  Sums of two squares up to {N}: {len(reps)} of {N} "
          f"({100 * len(reps) / N:.1f}%)")
    print(f"  First few: {reps[:15]}")
    missed3mod4 = [n for n in range(1, 40) if n % 4 == 3]
    print(f"  Every n == 3 (mod 4) is missed, e.g. {missed3mod4[:8]} ...")
    print()


def demo_sign_changes(j_values: List[int], N: int) -> None:
    print("=" * 70)
    print("DEMO 3: Sign changes of lambda_{sym^j f}(n), f = Delta (weight 12)")
    print("=" * 70)
    for j in j_values:
        lam = symmetric_power_coefficients(j, N)
        # over ALL n (== sums of m squares for any m >= 4)
        vals_all = [lam[n] for n in range(1, N + 1)]
        pos = sum(1 for v in vals_all if v > 0)
        neg = sum(1 for v in vals_all if v < 0)
        sc_all = sign_changes(vals_all)
        # over sums of two squares
        vals_two = [lam[n] for n in range(1, N + 1) if is_sum_of_two_squares(n)]
        sc_two = sign_changes(vals_two)
        pos2 = sum(1 for v in vals_two if v > 0)
        neg2 = sum(1 for v in vals_two if v < 0)
        print(f"  j = {j}:")
        print(f"     over all n (m >= 4): +{pos} / -{neg}, "
              f"{sc_all} sign changes up to {N}")
        print(f"     over sums of 2 sq  : +{pos2} / -{neg2}, "
              f"{sc_two} sign changes up to {N}")
    print()


def main() -> None:
    N = 2000
    demo_collapse(m_values=[4, 5, 8, 12, 20], sample=list(range(0, 60)))
    demo_two_squares(N=N)
    demo_sign_changes(j_values=[1, 2, 3, 4], N=N)
    print("Summary: for every even m >= 2, lambda_{sym^j f}(n) takes both")
    print("signs infinitely often over sums of m squares.  For m >= 4 this is")
    print("the unrestricted oscillation (collapse); m = 2 is the thin boundary.")


if __name__ == "__main__":
    main()
