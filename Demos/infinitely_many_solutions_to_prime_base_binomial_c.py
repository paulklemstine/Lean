"""
Prime-Base Binomial Congruences: numerical demonstrations.

This self-contained script demonstrates the main results of the accompanying
paper on the congruence

        C(q*n, n) == q**n   (mod n).

Results demonstrated:
  * Theorem A (Prime fibre): every prime p solves the congruence, for every
    base q, because both sides reduce to q modulo p (Lucas + Fermat).
  * Theorem B (Central valuation): v_q( C(q^{t+1}, q^t) ) == 1.
  * Theorem C (Exact valuation of A_t): with
        A_t = C(q^{t+1}, q^t) - q^{q^t},
    the base q divides A_t exactly once (q | A_t, q^2 does not divide A_t).
  * The residual R_t = A_t / q is coprime to q and seeds the composite search.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import comb
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Core arithmetic helpers                                                      #
# --------------------------------------------------------------------------- #
def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    i = 3
    while i * i <= n:
        if n % i == 0:
            return False
        i += 2
    return True


def q_adic_valuation(n: int, q: int) -> int:
    """Exponent of the prime q in the integer n (v_q(n)); v_q(0) := +infinity."""
    if n == 0:
        raise ValueError("v_q(0) is undefined (infinite)")
    n = abs(n)
    v = 0
    while n % q == 0:
        n //= q
        v += 1
    return v


def base_q_digits(n: int, q: int) -> List[int]:
    """Digits of n in base q, least significant first."""
    if n == 0:
        return [0]
    digits: List[int] = []
    while n > 0:
        digits.append(n % q)
        n //= q
    return digits


def digit_sum(n: int, q: int) -> int:
    """Base-q digit sum s_q(n)."""
    return sum(base_q_digits(n, q))


def A_value(q: int, t: int) -> int:
    """A_t = C(q^{t+1}, q^t) - q^{q^t}, computed exactly with big integers."""
    return comb(q ** (t + 1), q ** t) - q ** (q ** t)


def congruent(q: int, n: int) -> bool:
    """Test whether n solves C(q*n, n) == q**n (mod n), computed modulo n."""
    if n == 1:
        return True
    lhs = comb(q * n, n) % n
    rhs = pow(q, n, n)
    return lhs == rhs


# --------------------------------------------------------------------------- #
# Demonstration 1: the prime fibre                                            #
# --------------------------------------------------------------------------- #
def demo_prime_fibre(q: int, limit: int) -> None:
    print(f"\n=== Demo 1: Prime fibre for base q = {q} (n < {limit}) ===")
    solutions = [n for n in range(1, limit) if congruent(q, n)]
    primes = [n for n in solutions if is_prime(n)]
    composites = [n for n in solutions if not is_prime(n) and n > 1]
    print(f"  solutions : {solutions}")
    print(f"  primes    : {primes}")
    print(f"  composites: {composites}")
    all_primes = [p for p in range(2, limit) if is_prime(p)]
    missing = [p for p in all_primes if p not in solutions]
    print(f"  every prime below {limit} is a solution: {missing == []}")
    # Verify the two-step reduction on a few primes:
    for p in all_primes[:6]:
        lhs = comb(q * p, p) % p
        rhs = pow(q, p, p)
        print(f"    p={p:2d}: C(qp,p) mod p = {lhs}, q^p mod p = {rhs}, "
              f"both == q mod p ({q % p})")


# --------------------------------------------------------------------------- #
# Demonstration 2: central valuation and exact valuation of A_t               #
# --------------------------------------------------------------------------- #
def demo_valuation(q: int, t_max: int) -> None:
    print(f"\n=== Demo 2: Valuations for base q = {q} ===")
    print("   t | v_q(C(q^{t+1},q^t)) | A_t                 | v_q(A_t) | R_t = A_t/q")
    for t in range(1, t_max + 1):
        C = comb(q ** (t + 1), q ** t)
        vC = q_adic_valuation(C, q)
        A = A_value(q, t)
        vA = q_adic_valuation(A, q)
        R = A // q
        print(f"  {t:2d} | {vC:^19d} | {A:<19d} | {vA:^8d} | {R}")
        assert vC == 1, "Theorem B failed!"
        assert vA == 1, "Theorem C failed!"
        assert R % q != 0, "Residual should be coprime to q!"
    print(f"  Theorem B (v_q of central coeff = 1) and Theorem C "
          f"(v_q(A_t) = 1) verified for t = 1..{t_max}.")


# --------------------------------------------------------------------------- #
# Demonstration 3: residual factorization and the composite gates             #
# --------------------------------------------------------------------------- #
def factorize(n: int, bound: int = 10_000_000) -> Dict[int, int]:
    """Prime factorization of n as {prime: exponent}.

    Trial division is capped at ``bound``; any remaining cofactor larger than
    ``bound**2`` is recorded under its own key (it is either a prime or a
    product of large primes) so the demo stays fast on huge residuals.
    """
    n = abs(n)
    factors: Dict[int, int] = {}
    d = 2
    while d <= bound and d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def demo_composite_search(q: int, t_max: int) -> None:
    print(f"\n=== Demo 3: Composite search n = q^t * p for base q = {q} ===")
    for t in range(1, t_max + 1):
        R = A_value(q, t) // q
        fac = factorize(R)
        candidates: List[Tuple[int, int]] = []
        for p in fac:
            if p == q:
                continue
            gate = digit_sum((q - 1) * p, q) >= (q - 1) * t
            if gate:
                n = q ** t * p
                # Verifying the congruence needs C(q*n, n) mod n; the exact
                # binomial is astronomically large, so we only re-check when n
                # is small enough to compute quickly.
                solves = congruent(q, n) if n <= 200_000 else "n too large to re-check here"
                candidates.append((p, n))
                print(f"  t={t}: p={p} | s_q((q-1)p)={digit_sum((q-1)*p, q)} "
                      f">= (q-1)t={(q-1)*t} | n=q^t*p={n} | solves={solves}")
        if not candidates:
            print(f"  t={t}: R_t={R} factors={fac} -> no pair clears both gates")


# --------------------------------------------------------------------------- #
# Main                                                                         #
# --------------------------------------------------------------------------- #
def main() -> None:
    print("Prime-Base Binomial Congruences  ---  numerical demonstrations")
    print("=" * 64)
    demo_prime_fibre(q=2, limit=40)
    demo_prime_fibre(q=3, limit=40)
    demo_valuation(q=2, t_max=4)
    demo_valuation(q=3, t_max=3)
    demo_composite_search(q=2, t_max=4)
    demo_composite_search(q=3, t_max=2)
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
