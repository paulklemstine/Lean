"""
Numerical demonstrations for the prime-ideal zeta function of the Gaussian
field Q(i), illustrating the verified results:

  * gaussTerm encodes the p mod 4 splitting law in Z[i];
  * convergence for s > 1 (ceiling of the abscissa bracket);
  * divergence for s <= 1/2 (floor of the bracket, forced by inert primes);
  * strict positivity in the region of convergence;
  * the bridge inequality  P_{Q(i)}(s) <= 2 * P(s).

All functions are self-contained, type-hinted, and use only the standard
library.
"""

from __future__ import annotations

from typing import Iterator, List, Literal

SplitType = Literal["ramified", "split", "inert"]


def primes_up_to(n: int) -> List[int]:
    """Return all primes p with p <= n via a sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            sieve[i * i : n + 1 : i] = bytearray(len(range(i * i, n + 1, i)))
    return [i for i in range(2, n + 1) if sieve[i]]


def splitting_type(p: int) -> SplitType:
    """Classify the splitting of a rational prime p in the Gaussian integers Z[i]."""
    if p == 2:
        return "ramified"
    if p % 4 == 1:
        return "split"
    return "inert"


def gauss_term(s: float, p: int) -> float:
    """The per-prime term of the Gaussian prime-ideal zeta function.

    Mirrors the Lean definition `gaussTerm`:
        p = 2        ->  2^{-s}            (ramified, one ideal of norm 2)
        p % 4 == 1   ->  2 * p^{-s}        (split, two ideals of norm p)
        p % 4 == 3   ->  p^{-2s}           (inert, one ideal of norm p^2)
    """
    kind = splitting_type(p)
    if kind == "ramified":
        return 2.0 ** (-s)
    if kind == "split":
        return 2.0 * (p ** (-s))
    return p ** (-2.0 * s)


def prime_zeta_partial(s: float, n: int) -> float:
    """Partial sum of the rational prime zeta P(s) = sum_p p^{-s} for p <= n."""
    return sum(p ** (-s) for p in primes_up_to(n))


def gauss_prime_zeta_partial(s: float, n: int) -> float:
    """Partial sum of the Gaussian prime-ideal zeta over rational primes p <= n."""
    return sum(gauss_term(s, p) for p in primes_up_to(n))


def inert_partial(s: float, n: int) -> float:
    """Partial sum over the inert minorant sum_{p<=n} p^{-2s} (the divergence floor)."""
    return sum(p ** (-2.0 * s) for p in primes_up_to(n))


def demo_splitting_table(limit: int = 30) -> None:
    print("== Splitting of small rational primes in Z[i] ==")
    print(f"{'p':>4} | {'p mod 4':>7} | {'type':>9} | term contribution")
    print("-" * 50)
    s = 2.0
    for p in primes_up_to(limit):
        kind = splitting_type(p)
        if kind == "ramified":
            desc = "2^{-s}"
        elif kind == "split":
            desc = "2*p^{-s}"
        else:
            desc = "p^{-2s}"
        print(f"{p:>4} | {p % 4:>7} | {kind:>9} | {desc} = {gauss_term(s, p):.6f}")
    print()


def demo_convergence(s: float = 2.0) -> None:
    print(f"== Convergence for s = {s} > 1 (partial sums should stabilize) ==")
    for n in (10, 100, 1000, 10000, 100000):
        val = gauss_prime_zeta_partial(s, n)
        print(f"  p <= {n:>7}:  P_Q(i)(s) ~ {val:.10f}")
    print()


def demo_divergence(s: float = 0.5) -> None:
    print(f"== Divergence for s = {s} <= 1/2 (partial sums should grow) ==")
    for n in (10, 100, 1000, 10000, 100000):
        total = gauss_prime_zeta_partial(s, n)
        floor = inert_partial(s, n)
        print(f"  p <= {n:>7}:  P_Q(i) ~ {total:10.4f}   inert floor ~ {floor:10.4f}")
    print("  (The inert minorant alone diverges, dragging the whole series with it.)")
    print()


def demo_positivity(s: float = 1.5) -> None:
    print(f"== Strict positivity at s = {s} ==")
    val = gauss_prime_zeta_partial(s, 100000)
    ramified = gauss_term(s, 2)
    print(f"  P_Q(i)(s) ~ {val:.8f} > 0")
    print(f"  ramified prime 2 contributes 2^(-s) = {ramified:.8f} > 0 (the witness)")
    print()


def demo_bridge(s: float = 1.5) -> None:
    print(f"== Bridge inequality  P_Q(i)(s) <= 2 * P(s)  at s = {s} ==")
    n = 200000
    lhs = gauss_prime_zeta_partial(s, n)
    rhs = 2.0 * prime_zeta_partial(s, n)
    print(f"  P_Q(i)(s) ~ {lhs:.8f}")
    print(f"  2 * P(s)  ~ {rhs:.8f}")
    print(f"  inequality holds: {lhs <= rhs}")
    print()


def main() -> None:
    demo_splitting_table()
    demo_convergence(2.0)
    demo_divergence(0.5)
    demo_positivity(1.5)
    demo_bridge(1.5)


if __name__ == "__main__":
    main()
