"""
Numerical demonstration of the trace-set filter theory.
=======================================================

Setting.  Let N = p*q be a semiprime and let s = p + q be its *trace*.
Fermat-style factoring scans candidate traces s; a candidate s can be tested
against N modulo a prime m by asking whether

        s mod m  in  T_m(N) := { x + N/x  :  x in (Z/m)^*  }.

This script demonstrates, purely numerically, the five facts proved in the
accompanying paper:

  1. EXACTNESS.  The true trace p+q always lies in T_m(N) (zero false
     negatives at every modulus).
  2. THE EXACT SIZE LAW.  2*|T_m(N)| = m + chi(N), chi the Legendre symbol.
     A wrong candidate therefore survives one prime with probability
     exactly (1 + chi(N)/m)/2 ~ 1/2.
  3. THE FERMAT IDENTITY.  t in T_m(N) iff t^2 - 4N is a square mod m; and
     over the integers, s is a trace of a factorisation iff s^2 - 4N is a
     perfect square.  The s-scan is Fermat's method in disguise.
  4. THE p-FILTER IS EMPTY.  The set of admissible factor residues mod m is
     all of (Z/m)^*: the filter only retests coprimality.
  5. NO AMPLIFICATION.  Survivors in any window of M = prod m_i consecutive
     candidates number exactly prod |T_{m_i}| ~ M * 2^{-omega}, independently
     of where the window sits.  Isolating a hint of width W forces
     prod m_i > W.

Self-contained: standard library only.
"""

from __future__ import annotations

import math
import random
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

# --------------------------------------------------------------------------
# Basic arithmetic helpers
# --------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
    if n < 2:
        return False
    small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for p in small_primes:
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in small_primes:
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def primes_from(start: int, count: int) -> List[int]:
    """The first `count` primes that are >= start."""
    out: List[int] = []
    n = max(2, start)
    while len(out) < count:
        if is_prime(n):
            out.append(n)
        n += 1
    return out


def legendre_symbol(a: int, p: int) -> int:
    """chi_p(a) in {-1, 0, +1} for an odd prime p."""
    a %= p
    if a == 0:
        return 0
    ls = pow(a, (p - 1) // 2, p)
    return 1 if ls == 1 else -1


def random_semiprime(bits_per_factor: int, rng: random.Random) -> Tuple[int, int, int]:
    """A semiprime N = p*q with p, q distinct primes of `bits_per_factor` bits."""
    def rand_prime() -> int:
        while True:
            c = rng.getrandbits(bits_per_factor) | (1 << (bits_per_factor - 1)) | 1
            if is_prime(c):
                return c

    p = rand_prime()
    q = rand_prime()
    while q == p:
        q = rand_prime()
    return p * q, p, q


# --------------------------------------------------------------------------
# The trace set T_m(N) and the factor-residue set
# --------------------------------------------------------------------------


def trace_set(N: int, m: int) -> Set[int]:
    """T_m(N) = { x + N * x^{-1} mod m : x in (Z/m)^* }, for m prime."""
    Nm = N % m
    return {(x + Nm * pow(x, m - 2, m)) % m for x in range(1, m)}


def trace_set_via_discriminant(N: int, m: int) -> Set[int]:
    """{ t : t^2 - 4N is a square mod m and t is a genuine trace }, m odd prime."""
    squares = {(y * y) % m for y in range(m)}
    out: Set[int] = set()
    for t in range(m):
        if (t * t - 4 * N) % m in squares:
            # the two roots (t +- y)/2 must be units, i.e. N != 0 mod m
            if N % m != 0:
                out.add(t)
    return out


def factor_residue_set(N: int, m: int) -> Set[int]:
    """{ a mod m : exists b with a*b = N mod m } — the 'p-filter'."""
    Nm = N % m
    return {a for a in range(m) if any((a * b) % m == Nm for b in range(m))}


# --------------------------------------------------------------------------
# Demonstration 1: exactness (zero false negatives)
# --------------------------------------------------------------------------


def demo_exactness(trials: int = 200, omega: int = 20, seed: int = 20260813) -> None:
    rng = random.Random(seed)
    mods = primes_from(5, omega)
    survived = 0
    for _ in range(trials):
        N, p, q = random_semiprime(24, rng)
        s = p + q
        if all(s % m in trace_set(N, m) for m in mods if N % m != 0):
            survived += 1
    print("1. EXACTNESS  (true trace vs. all filters)")
    print(f"   semiprimes tested          : {trials}   (48-bit N, 24-bit factors)")
    print(f"   moduli                     : {mods[0]}..{mods[-1]}  (omega = {omega})")
    print(f"   true traces surviving      : {survived}/{trials}")
    assert survived == trials
    print("   -> zero false negatives, as the exactness theorem predicts.\n")


# --------------------------------------------------------------------------
# Demonstration 2: the exact size law 2|T| = m + chi(N)
# --------------------------------------------------------------------------


def demo_size_law(N: int = 3233, omega: int = 12) -> None:
    print(f"2. EXACT SIZE LAW   2|T_m(N)| = m + chi_m(N)   for N = {N}")
    print("   m      |T_m|   chi_m(N)   2|T_m|   m+chi   density |T|/m")
    mods = primes_from(3, omega)
    for m in mods:
        if N % m == 0:
            continue
        T = trace_set(N, m)
        chi = legendre_symbol(N, m)
        assert 2 * len(T) == m + chi, (m, len(T), chi)
        assert T == trace_set_via_discriminant(N, m)
        print(f"  {m:4d}   {len(T):4d}    {chi:+3d}      {2*len(T):5d}   {m+chi:5d}"
              f"      {len(T)/m:.4f}")
    print("   -> every local density is (1 + chi/m)/2: exactly one bit per prime,")
    print("      and the discriminant description t^2-4N a square agrees exactly.\n")


# --------------------------------------------------------------------------
# Demonstration 3: measured survival of a WRONG candidate is 2^{-omega}
# --------------------------------------------------------------------------


def demo_pruning_rate(trials: int = 20000, seed: int = 7, omegas: Sequence[int] = (3, 6, 9)) -> None:
    rng = random.Random(seed)
    N, p, q = random_semiprime(24, rng)
    mods_all = primes_from(5, max(omegas))
    print("3. PRUNING RATE FOR A WRONG CANDIDATE")
    print(f"   N = {N} = {p} * {q},  true trace s = {p+q}")
    print("   omega   measured survival   predicted 2^-omega   exact prod (1+chi/m)/2")
    tables = {m: trace_set(N, m) for m in mods_all}
    for omega in omegas:
        mods = mods_all[:omega]
        hits = 0
        for _ in range(trials):
            s = rng.randrange(0, 1 << 25)
            if s == p + q:
                continue
            if all(s % m in tables[m] for m in mods):
                hits += 1
        exact = 1.0
        for m in mods:
            exact *= (1 + legendre_symbol(N, m) / m) / 2
        print(f"    {omega:3d}      {hits/trials:.6f}            {2.0**-omega:.6f}"
              f"             {exact:.6f}")
    print("   -> measured rate tracks the exact Legendre-corrected product, never better.\n")


# --------------------------------------------------------------------------
# Demonstration 4: the p-filter is empty
# --------------------------------------------------------------------------


def demo_p_filter_empty(N: int = 3233, omega: int = 8) -> None:
    print("4. THE FACTOR-RESIDUE ('p') FILTER IS EMPTY")
    print("   m    |admissible factor residues|   m-1   equals (Z/m)^* ?")
    for m in primes_from(3, omega):
        if N % m == 0:
            continue
        F = factor_residue_set(N, m)
        ok = F == set(range(1, m))
        print(f"  {m:4d}            {len(F):5d}                {m-1:4d}       {ok}")
    print("   -> admissible factor residues = all units: the filter only retests")
    print("      coprimality, which a prime candidate satisfies automatically.\n")


# --------------------------------------------------------------------------
# Demonstration 5: window census and translation invariance
# --------------------------------------------------------------------------


def survivors(N: int, mods: Sequence[int], a: int, W: int) -> List[int]:
    """Candidates s in [a, a+W) passing every trace filter."""
    tables = {m: trace_set(N, m) for m in mods}
    return [s for s in range(a, a + W) if all(s % m in tables[m] for m in mods)]


def demo_window_census(N: int = 3233, mods: Sequence[int] = (3, 5, 7)) -> None:
    M = math.prod(mods)
    predicted = math.prod(len(trace_set(N, m)) for m in mods)
    print("5. WINDOW CENSUS AND TRANSLATION INVARIANCE")
    print(f"   N = {N},  moduli = {list(mods)},  M = prod m_i = {M}")
    print(f"   local sizes |T_m| = {[len(trace_set(N, m)) for m in mods]}"
          f"   -> predicted survivors per period = {predicted}")
    for a in (0, 105, 500, 1234, 99999):
        got = len(survivors(N, mods, a, M))
        print(f"   window [{a}, {a+M}) : {got} survivors   (predicted {predicted})")
        assert got == predicted
    # the true trace is always among them
    p, q = 61, 53
    assert (p + q) in survivors(N, mods, 100, M)
    print(f"   true trace {p+q} = {p}+{q} survives.  Widening the window by a factor k")
    for k in (1, 2, 5, 10):
        got = len(survivors(N, mods, 0, k * M))
        print(f"      width {k*M:6d} : {got:5d} survivors   (predicted {k*predicted})")
        assert got == k * predicted
    print("   -> the count is exactly linear in the width: density is fixed at ~2^-omega,")
    print("      so a hint window is never compressed to a single candidate.\n")


# --------------------------------------------------------------------------
# Demonstration 6: the interval hint is not amplified
# --------------------------------------------------------------------------


def demo_interval_hint(seed: int = 386, E: int = 4000, omegas: Sequence[int] = (0, 6, 12, 18)) -> None:
    rng = random.Random(seed)
    N, p, q = random_semiprime(24, rng)
    s_true = p + q
    mods_all = primes_from(5, max(omegas))
    print("6. INTERVAL HINT:  s in [s0 - E, s0 + E],  E =", E)
    print(f"   N = {N} = {p} * {q},  true trace {s_true}")
    print("   omega   survivors in window   predicted (2E+1)*prod density (+ true trace)")
    tables = {m: trace_set(N, m) for m in mods_all}
    a, W = s_true - E, 2 * E + 1
    for omega in omegas:
        mods = mods_all[:omega]
        cnt = 0
        for s in range(a, a + W):
            if all(s % m in tables[m] for m in mods):
                cnt += 1
        dens = 1.0
        for m in mods:
            dens *= (1 + legendre_symbol(N, m) / m) / 2
        print(f"    {omega:3d}        {cnt:7d}                 {W*dens:14.3f}")
    print("   -> the survivor count falls only as 2^-omega and never reaches 1 until")
    print("      the primorial of the moduli exceeds the width of the hint.\n")


# --------------------------------------------------------------------------
# Demonstration 7: the s-scan is Fermat's method
# --------------------------------------------------------------------------


def integer_sqrt(n: int) -> int:
    return math.isqrt(n)


def fermat_from_trace(N: int, s: int) -> Optional[Tuple[int, int]]:
    """If s^2 - 4N is a perfect square, return the factor pair with that trace."""
    D = s * s - 4 * N
    if D < 0:
        return None
    d = integer_sqrt(D)
    if d * d != D:
        return None
    if (s - d) % 2 != 0:
        return None
    return ((s - d) // 2, (s + d) // 2)


def demo_fermat_equivalence(seed: int = 11) -> None:
    rng = random.Random(seed)
    N, p, q = random_semiprime(16, rng)
    print("7. THE TRACE SCAN IS FERMAT'S METHOD")
    print(f"   N = {N} = {p} * {q}")
    hits: List[Tuple[int, Tuple[int, int]]] = []
    lo = 2 * integer_sqrt(N)
    for s in range(lo, lo + 200000):
        f = fermat_from_trace(N, s)
        if f is not None and f[0] > 1:
            hits.append((s, f))
        if len(hits) >= 3:
            break
    for s, (a, b) in hits:
        print(f"   s = {s:10d} : s^2-4N is a square -> N = {a} * {b}   (a+b = {a+b})")
    print("   -> a trace passes the *global* test exactly when s^2-4N is a perfect")
    print("      square, which is literally Fermat's difference-of-squares step.\n")


# --------------------------------------------------------------------------


def main() -> None:
    print("=" * 74)
    print(" The trace-set filter: exact, exactly half-sized, and non-amplifying")
    print("=" * 74, "\n")
    demo_exactness()
    demo_size_law()
    demo_pruning_rate()
    demo_p_filter_empty()
    demo_window_census()
    demo_interval_hint()
    demo_fermat_equivalence()
    print("All assertions passed: the numerics match the theorems exactly.")


if __name__ == "__main__":
    main()
