"""
The one-bit cap of the cyclic sum channel: numerical demonstrations.

Setting
-------
Fix a modulus n >= 1 and draw a pair of exponents (a, b) uniformly from the
square {0, 1, ..., n-1}^2.  Two observables are attached to such a pair:

    the type pair   X(a, b) = (T(a), T(b)),   T(a) = n / gcd(a, n),
    the sum residue Y(a, b) = (a + b) mod n.

T(a) is the additive order of a in Z/nZ, i.e. the size of the cyclic subgroup
it generates; the type pair is the "coarse shape" of the pair, the sum residue
is the fine datum.  The channel capacity-like quantity studied here is the
mutual information, measured in bits,

    Ipair(n) = I(X ; Y) = log2(n) - H(Y | X).

This script verifies, numerically:

  1. the exact two-primary law     Ipair(2^k) = (4/3)(1 - 4^{-k});
  2. the universal upper envelope  Ipair(n) <= log2 n - avg log2 max(phi(T a), phi(T b));
  3. the primary closed form       Ipair(q^k) <= (1 - q^{-2k}) E(q),
                                   E(q) = q^2 log2 q/(q^2-1) - log2(q-1),
     and the uniform odd bound     E(q) <= 39/40 for odd primes q;
  4. additivity across coprime factorisations, Ipair(mn) = Ipair(m) + Ipair(n);
  5. the even/odd dichotomy: Ipair(n) > 1 for every even n != 2, Ipair(2) = 1,
     while an odd n needs many prime factors before it can break the cap;
  6. the quantitative positivity bound  Ipair(n) >= log2(n) / n^2.
"""

from __future__ import annotations

from collections import defaultdict
from math import gcd, log2
from typing import Dict, List, Tuple

# --------------------------------------------------------------------------
# Basic arithmetic helpers
# --------------------------------------------------------------------------


def order_type(n: int, a: int) -> int:
    """The additive order T(a) = n / gcd(a, n) of a in Z/nZ."""
    return n // gcd(a, n)


def totient(m: int) -> int:
    """Euler's totient phi(m), by trial division."""
    result, k, mm = m, 2, m
    while k * k <= mm:
        if mm % k == 0:
            while mm % k == 0:
                mm //= k
            result -= result // k
        k += 1
    if mm > 1:
        result -= result // mm
    return result


def prime_factorisation(n: int) -> Dict[int, int]:
    """The prime factorisation of n >= 1 as {prime: exponent}."""
    factors: Dict[int, int] = {}
    m, k = n, 2
    while k * k <= m:
        while m % k == 0:
            factors[k] = factors.get(k, 0) + 1
            m //= k
        k += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


# --------------------------------------------------------------------------
# The channel itself
# --------------------------------------------------------------------------


def shannon_entropy(counts: List[int]) -> float:
    """Shannon entropy in bits of the empirical distribution given by counts."""
    total = sum(counts)
    if total == 0:
        return 0.0
    return -sum((c / total) * log2(c / total) for c in counts if c > 0)


def ipair(n: int) -> float:
    """Mutual information I(type pair ; sum residue) in bits, by exact enumeration."""
    if n <= 1:
        return 0.0
    joint: Dict[Tuple[int, int], List[int]] = defaultdict(lambda: [0] * n)
    types = [order_type(n, a) for a in range(n)]
    for a in range(n):
        ta = types[a]
        for b in range(n):
            joint[(ta, types[b])][(a + b) % n] += 1
    total = n * n
    cond = 0.0
    for counts in joint.values():
        weight = sum(counts) / total
        cond += weight * shannon_entropy(counts)
    return log2(n) - cond


def envelope_average(n: int) -> float:
    """log2 n - average over the square of log2 max(phi(T a), phi(T b))."""
    tot = [totient(order_type(n, a)) for a in range(n)]
    acc = 0.0
    for a in range(n):
        for b in range(n):
            acc += log2(max(tot[a], tot[b]))
    return log2(n) - acc / (n * n)


def primary_envelope(q: int) -> float:
    """E(q) = q^2 log2 q / (q^2 - 1) - log2(q - 1)."""
    if q == 2:
        return 4.0 / 3.0
    return q * q * log2(q) / (q * q - 1) - log2(q - 1)


def primary_bound(q: int, k: int) -> float:
    """The closed-form upper bound (1 - q^{-2k}) E(q) for Ipair(q^k)."""
    return (1 - q ** (-2.0 * k)) * primary_envelope(q)


def two_power_law(k: int) -> float:
    """The exact value Ipair(2^k) = (4/3)(1 - 4^{-k})."""
    return (4.0 / 3.0) * (1 - 4.0 ** (-k))


def ipair_from_factorisation(n: int) -> float:
    """Ipair(n) reconstructed additively from its primary components."""
    return sum(ipair(p ** e) for p, e in prime_factorisation(n).items())


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_small_table(limit: int = 21) -> None:
    print("=" * 74)
    print("1. The channel on small moduli:  Ipair(n) = log2 n - H(sum residue | types)")
    print("=" * 74)
    print(f"{'n':>4} {'parity':>7} {'Ipair(n)':>11} {'envelope':>11} "
          f"{'log2 n / n^2':>13}  cap")
    for n in range(2, limit):
        value = ipair(n)
        env = envelope_average(n)
        assert value <= env + 1e-9, (n, value, env)
        assert value >= log2(n) / n ** 2 - 1e-9, n
        flag = "ABOVE" if value > 1 + 1e-12 else ("AT" if abs(value - 1) < 1e-12 else "below")
        print(f"{n:>4} {'even' if n % 2 == 0 else 'odd':>7} {value:>11.6f} "
              f"{env:>11.6f} {log2(n) / n ** 2:>13.6f}  {flag}")
    print("\nEvery even n != 2 is strictly above one bit; Ipair(2) = 1 exactly;")
    print("every odd n in this range is strictly below one bit.\n")


def demo_two_power_law(kmax: int = 8) -> None:
    print("=" * 74)
    print("2. The exact two-primary law:  Ipair(2^k) = (4/3)(1 - 4^{-k})")
    print("=" * 74)
    print(f"{'k':>3} {'2^k':>6} {'measured':>12} {'(4/3)(1-4^-k)':>16} {'error':>10}")
    for k in range(0, kmax + 1):
        n = 2 ** k
        predicted = two_power_law(k)
        measured = ipair(n) if n <= 2 ** 12 else float("nan")
        print(f"{k:>3} {n:>6} {measured:>12.9f} {predicted:>16.9f} "
              f"{abs(measured - predicted):>10.2e}")
        assert abs(measured - predicted) < 1e-9
    print("\nThe tower is strictly increasing with supremum 4/3, it hits the cap")
    print("exactly at k = 1 and exceeds it for every k >= 2.\n")


def demo_odd_primary_envelope(kmax: int = 4) -> None:
    print("=" * 74)
    print("3. Odd primary components stay strictly below the cap")
    print("=" * 74)
    print(f"{'q':>4} {'E(q)':>10} {'sup_k bound':>12}   measured Ipair(q^k), k = 1,2,...")
    for q in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
        measured = []
        for k in range(1, kmax + 1):
            if q ** k <= 2500:
                value = ipair(q ** k)
                assert value <= primary_bound(q, k) + 1e-9, (q, k)
                measured.append(f"{value:.6f}")
        print(f"{q:>4} {primary_envelope(q):>10.6f} {primary_envelope(q):>12.6f}   "
              + ", ".join(measured))
    worst = max(primary_envelope(q) for q in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31])
    print(f"\nWorst odd envelope E(3) = {primary_envelope(3):.6f} <= 39/40 = {39 / 40:.6f}")
    assert worst <= 39 / 40
    print("so no odd prime power ever reaches one bit.\n")


def demo_additivity() -> None:
    print("=" * 74)
    print("4. Additivity across coprime factorisations")
    print("=" * 74)
    print(f"{'n':>5} {'factorisation':>18} {'Ipair(n)':>11} {'sum of parts':>14}")
    for n in [6, 10, 12, 15, 18, 20, 21, 24, 30, 35, 36, 40, 45]:
        direct = ipair(n)
        parts = ipair_from_factorisation(n)
        fac = " * ".join(f"{p}^{e}" if e > 1 else f"{p}"
                         for p, e in sorted(prime_factorisation(n).items()))
        print(f"{n:>5} {fac:>18} {direct:>11.6f} {parts:>14.6f}")
        assert abs(direct - parts) < 1e-9, n
    print("\nThe channel splits as a sum over primary components, so the one-bit")
    print("cap is a statement about how the components add up.\n")


def demo_odd_cap_breakers() -> None:
    print("=" * 74)
    print("5. How an odd modulus can break the cap: a knapsack over odd primes")
    print("=" * 74)
    running = 0.0
    print(f"{'q':>4} {'sup_k Ipair(q^k)':>18} {'running total':>15}")
    for q in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
        best = max(ipair(q ** k) for k in range(1, 5) if q ** k <= 2500)
        running += best
        print(f"{q:>4} {best:>18.6f} {running:>15.6f}"
              + ("   <-- first crossing of one bit" if running > 1 >= running - best else ""))
    witness = 3 ** 2 * 5 * 7 * 11 * 13 * 17 * 19 * 23 * 29 * 31
    total = ipair_from_factorisation(witness)
    print(f"\nOdd witness n = {witness} = 3^2 * 5 * 7 * 11 * 13 * 17 * 19 * 23 * 29 * 31")
    print(f"Ipair(n) = {total:.6f} > 1: evenness is sufficient but NOT necessary.")
    assert total > 1
    print("An odd modulus needs at least eight distinct odd primes before the")
    print("running total of its primary contributions can cross one bit.\n")


def demo_dichotomy_scan(limit: int = 60) -> None:
    print("=" * 74)
    print("6. The corrected dichotomy, scanned")
    print("=" * 74)
    evens_above = [n for n in range(3, limit) if n % 2 == 0 and ipair(n) > 1]
    evens_not_above = [n for n in range(2, limit) if n % 2 == 0 and ipair(n) <= 1]
    odds_above = [n for n in range(3, limit, 2) if ipair(n) > 1]
    print(f"even n < {limit} strictly above the cap: all of them except n = 2 "
          f"({len(evens_above)} values)")
    print(f"even n < {limit} not strictly above the cap: {evens_not_above}")
    print(f"odd  n < {limit} above the cap: {odds_above} (none in this range)")
    omega_bound_ok = all(
        ipair(n) <= (39 / 40) * len(prime_factorisation(n)) + 1e-9
        for n in range(3, limit, 2)
    )
    print(f"odd bound  Ipair(n) <= (39/40) * omega(n)  holds on the scan: {omega_bound_ok}")
    assert evens_not_above == [2] and not odds_above and omega_bound_ok
    print()


def main() -> None:
    demo_small_table()
    demo_two_power_law()
    demo_odd_primary_envelope()
    demo_additivity()
    demo_odd_cap_breakers()
    demo_dichotomy_scan()
    print("All numerical checks passed.")


if __name__ == "__main__":
    main()
