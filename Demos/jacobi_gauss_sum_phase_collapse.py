"""
Jacobi Gauss-Sum Phase Collapse — numerical demonstrations.

For an odd modulus N the *Jacobi Gauss sum* is

    tau(N) = sum_{n=0}^{N-1} (n | N) * exp(2*pi*i*n/N),

where (n | N) is the Jacobi symbol.  For odd squarefree N one has |tau(N)| = sqrt(N),
and the central theorem demonstrated here is the PHASE COLLAPSE:

    tau(N) = sqrt(N)      if N = 1 (mod 4),
    tau(N) = i * sqrt(N)  if N = 3 (mod 4).

In particular, for a semiprime N = p*q the phase depends only on N mod 4 (equivalently,
only on whether p = q (mod 4)); it cannot separate the class (p,q) = (1,1) mod 4 from
(3,3) mod 4.  The mechanism is twisted multiplicativity plus quadratic reciprocity:

    tau(p*q) = (q|p) * (p|q) * g_p * g_q,          g_r = sum_{a mod r} (a|r) e^{2*pi*i*a/r},

with g_r = sqrt(r) for r = 1 (mod 4) and i*sqrt(r) for r = 3 (mod 4), while
(q|p)(p|q) = -1 exactly when p = q = 3 (mod 4) — precisely cancelling i*i = -1.

Self-contained: standard library only.
"""

from __future__ import annotations

import cmath
import math
from typing import Dict, Iterable, List, Tuple

# --------------------------------------------------------------------------------------
# Number-theoretic primitives
# --------------------------------------------------------------------------------------


def jacobi_symbol(a: int, n: int) -> int:
    """Jacobi symbol (a | n) for odd n >= 1, computed by reciprocity in O(log n) steps."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("Jacobi symbol requires an odd positive modulus")
    a %= n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (sufficient for the small moduli used)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def factorize(n: int) -> List[int]:
    """Return the multiset of prime factors of n in increasing order."""
    factors: List[int] = []
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors.append(d)
            m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors


def is_squarefree_odd(n: int) -> bool:
    """True when n is odd, at least 1, and squarefree."""
    if n % 2 == 0:
        return False
    fs = factorize(n)
    return len(set(fs)) == len(fs)


# --------------------------------------------------------------------------------------
# The Gauss sums
# --------------------------------------------------------------------------------------


def tau(N: int) -> complex:
    """The Jacobi Gauss sum tau(N) = sum_{n<N} (n|N) e^{2*pi*i*n/N}."""
    return sum(
        jacobi_symbol(n, N) * cmath.exp(2j * math.pi * n / N) for n in range(N)
    )


def gauss_sum_prime(p: int) -> complex:
    """The classical quadratic Gauss sum g_p (the same formula, p prime)."""
    if not is_prime(p) or p == 2:
        raise ValueError("g_p is defined here for odd primes")
    return tau(p)


def predicted_tau(N: int) -> complex:
    """Theoretical value: sqrt(N) if N = 1 (mod 4), i*sqrt(N) if N = 3 (mod 4)."""
    s = math.sqrt(N)
    return complex(s, 0.0) if N % 4 == 1 else complex(0.0, s)


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------

TEST_SEMIPRIMES: Tuple[int, ...] = (
    15, 21, 33, 35, 51, 65, 77, 85, 91, 115, 143, 187, 209,
)


def demo_semiprime_table(semiprimes: Iterable[int] = TEST_SEMIPRIMES) -> None:
    """Phase collapse on semiprimes: tau(N)/sqrt(N) is 1 or i, keyed by N mod 4 only."""
    print("=" * 84)
    print("1. PHASE COLLAPSE ON SEMIPRIMES:  tau(N)/sqrt(N) in {1, i}")
    print("=" * 84)
    header = f"{'N':>5} {'p,q':>9} {'(p%4,q%4)':>10} {'N%4':>4} " \
             f"{'tau(N)/sqrt(N)':>26} {'arg/pi':>8}"
    print(header)
    print("-" * len(header))
    for N in semiprimes:
        fs = factorize(N)
        p, q = fs[0], fs[1]
        t = tau(N)
        z = t / math.sqrt(N)
        arg_over_pi = cmath.phase(t) / math.pi
        print(
            f"{N:>5} {f'{p}x{q}':>9} {f'({p % 4},{q % 4})':>10} {N % 4:>4} "
            f"{f'{z.real:+.6f}{z.imag:+.6f}i':>26} {arg_over_pi:>8.4f}"
        )
    print()
    print("Observation: the value is exactly 1 when N = 1 (mod 4) and exactly i when")
    print("N = 3 (mod 4).  The classes (1,1) and (3,3) mod 4 are indistinguishable.")
    print()


def demo_collapse_pairs() -> None:
    """Explicit (1,1)-vs-(3,3) collisions: same phase, different factor residues."""
    print("=" * 84)
    print("2. STRUCTURAL ORTHOGONALITY:  (1,1) and (3,3) semiprimes share a phase")
    print("=" * 84)
    pairs: List[Tuple[int, int]] = [(65, 21), (85, 33), (145, 77), (205, 209)]
    for n_one_one, n_three_three in pairs:
        a, b = factorize(n_one_one)
        c, d = factorize(n_three_three)
        ta, tb = tau(n_one_one), tau(n_three_three)
        print(
            f"  N={n_one_one:>4} = {a}x{b} ({a % 4},{b % 4}) : arg = {cmath.phase(ta):+.6f}   |"
            f"   N'={n_three_three:>4} = {c}x{d} ({c % 4},{d % 4}) : arg = {cmath.phase(tb):+.6f}"
        )
    print()
    print("Both families satisfy N = 1 (mod 4) and both have argument 0: the phase")
    print("carries exactly one bit, namely N mod 4, which is public information.")
    print()


def demo_mechanism(p: int = 3, q: int = 7) -> None:
    """Verify tau(pq) = (q|p)(p|q) g_p g_q and watch the (3,3) cancellation."""
    print("=" * 84)
    print(f"3. THE MECHANISM:  tau({p}*{q}) = ({q}|{p})({p}|{q}) g_{p} g_{q}")
    print("=" * 84)
    gp, gq = gauss_sum_prime(p), gauss_sum_prime(q)
    eps = jacobi_symbol(q, p) * jacobi_symbol(p, q)
    rhs = eps * gp * gq
    lhs = tau(p * q)
    for r, g in ((p, gp), (q, gq)):
        closed = f"i*sqrt({r})" if r % 4 == 3 else f"sqrt({r})"
        print(f"  g_{r:<3}           = {g.real:+.9f}{g.imag:+.9f}i   (= {closed})")
    print(f"  reciprocity sign ({q}|{p})({p}|{q}) = {eps:+d}")
    print(f"  product of phase units i^[p=3] * i^[q=3] = "
          f"{(1j if p % 4 == 3 else 1) * (1j if q % 4 == 3 else 1)}")
    print(f"  RHS             = {rhs.real:+.9f}{rhs.imag:+.9f}i")
    print(f"  tau({p * q})           = {lhs.real:+.9f}{lhs.imag:+.9f}i")
    print(f"  agreement       : {abs(lhs - rhs) < 1e-9}")
    print()


def demo_squares_unconditional(moduli: Iterable[int] = (15, 21, 33, 35, 105, 165, 231)) -> None:
    """tau(N)^2 = +/- N with the sign given by N mod 4, for odd squarefree N."""
    print("=" * 84)
    print("4. UNCONDITIONAL SQUARE LAW:  tau(N)^2 = N  or  -N  according to N mod 4")
    print("=" * 84)
    print(f"{'N':>6} {'#prime factors':>15} {'N%4':>4} {'tau(N)^2':>28} {'|tau(N)|-sqrt(N)':>20}")
    for N in moduli:
        if not is_squarefree_odd(N):
            continue
        t = tau(N)
        sq = t * t
        print(f"{N:>6} {len(factorize(N)):>15} {N % 4:>4} "
              f"{f'{sq.real:+.6f}{sq.imag:+.6f}i':>28} {abs(t) - math.sqrt(N):>20.2e}")
    print()
    print("Note this holds for any number of prime factors, and needs no sign theorem.")
    print()


def demo_multiplicativity(pairs: Iterable[Tuple[int, int]] = ((3, 5), (5, 7), (15, 7), (11, 21))) -> None:
    """Twisted multiplicativity tau(mn) = (n|m)(m|n) tau(m) tau(n) for coprime m, n."""
    print("=" * 84)
    print("5. TWISTED MULTIPLICATIVITY:  tau(mn) = (n|m)(m|n) tau(m) tau(n)")
    print("=" * 84)
    for m, n in pairs:
        if math.gcd(m, n) != 1:
            continue
        lhs = tau(m * n)
        rhs = jacobi_symbol(n, m) * jacobi_symbol(m, n) * tau(m) * tau(n)
        print(f"  m={m:>3}, n={n:>3}:  |LHS - RHS| = {abs(lhs - rhs):.2e}   "
              f"twist = {jacobi_symbol(n, m) * jacobi_symbol(m, n):+d}")
    print()
    print("Primality is nowhere used: only coprimality of the two moduli.")
    print()


def demo_information_content(bound: int = 400) -> None:
    """How much factor information is in the phase?  Exactly one bit: N mod 4."""
    print("=" * 84)
    print("6. INFORMATION AUDIT:  the phase channel of tau over odd squarefree N")
    print("=" * 84)
    buckets: Dict[Tuple[int, str], int] = {}
    for N in range(3, bound, 2):
        if not is_squarefree_odd(N):
            continue
        t = tau(N)
        arg = cmath.phase(t)
        label = "0" if abs(arg) < 1e-6 else ("pi/2" if abs(arg - math.pi / 2) < 1e-6 else "other")
        buckets[(N % 4, label)] = buckets.get((N % 4, label), 0) + 1
    for key in sorted(buckets):
        print(f"  N = {key[0]} (mod 4),  arg tau(N) = {key[1]:>5} :  {buckets[key]} moduli")
    print()
    distinct_phases = len({k[1] for k in buckets})
    print(f"  distinct observed phases: {distinct_phases}  ->  log2 = "
          f"{math.log2(distinct_phases):.1f} bit of information, and it equals N mod 4,")
    print("  which any observer already knows.  Nothing about the factorisation leaks.")
    print()


def demo_predictions(moduli: Iterable[int] = TEST_SEMIPRIMES) -> None:
    """Compare computed tau(N) against the closed-form prediction."""
    print("=" * 84)
    print("7. CLOSED FORM CHECK:  tau(N) against sqrt(N) or i*sqrt(N)")
    print("=" * 84)
    worst = 0.0
    for N in moduli:
        err = abs(tau(N) - predicted_tau(N))
        worst = max(worst, err)
        print(f"  N = {N:>4}:  error = {err:.3e}")
    print(f"\n  worst-case error over the sample: {worst:.3e}\n")


def main() -> None:
    print()
    print("JACOBI GAUSS-SUM PHASE COLLAPSE — NUMERICAL DEMONSTRATIONS")
    print()
    demo_semiprime_table()
    demo_collapse_pairs()
    demo_mechanism(3, 7)
    demo_mechanism(3, 5)
    demo_squares_unconditional()
    demo_multiplicativity()
    demo_information_content()
    demo_predictions()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
