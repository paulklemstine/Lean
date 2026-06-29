"""
Numerical demonstrations of the Fibonacci Law of Apparition.

For a prime p, the rank of apparition (entry point) alpha(p) is the least k > 0
with p | F_k.  The Law of Apparition states:

    for every prime p >= 7,  alpha(p) | (p - 1)  OR  alpha(p) | (p + 1).

This script demonstrates, with no external dependencies:

  1. The spine:  p | F_k  <=>  alpha(p) | k.
  2. The law:    alpha(p) divides p-1 or p+1, for all primes 7 <= p < N.
  3. The Fibonacci-Fermat law:  p | F_{p-1} or p | F_{p+1}.
  4. F_p^2 == 1 (mod p):  the engine residue, and F_p == (5|p) (mod p).
  5. Bounded RANK algorithm vs. naive scan, agreeing on alpha(p).

All Fibonacci-mod arithmetic uses fast doubling, so it scales to large p.
"""

from __future__ import annotations

from typing import Iterator, List, Tuple


# --------------------------------------------------------------------------- #
#  Fibonacci modulo m by fast doubling: returns (F_n mod m, F_{n+1} mod m).   #
# --------------------------------------------------------------------------- #
def fib_pair_mod(n: int, m: int) -> Tuple[int, int]:
    """Return (F_n mod m, F_{n+1} mod m) in O(log n) ring operations."""
    if m == 1:
        return (0, 0)
    if n == 0:
        return (0, 1 % m)
    a, b = fib_pair_mod(n >> 1, m)            # a = F_k, b = F_{k+1}, k = n//2
    c = (a * ((2 * b - a) % m)) % m            # F_{2k}
    d = (a * a + b * b) % m                     # F_{2k+1}
    if n & 1:
        return (d, (c + d) % m)                 # n odd:  (F_{2k+1}, F_{2k+2})
    return (c, d)                               # n even: (F_{2k},   F_{2k+1})


def fib_mod(n: int, m: int) -> int:
    """Return F_n mod m."""
    return fib_pair_mod(n, m)[0]


# --------------------------------------------------------------------------- #
#  Primality, divisors, Legendre symbol.                                      #
# --------------------------------------------------------------------------- #
def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
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


def primes_up_to(limit: int) -> Iterator[int]:
    """Yield primes p with 2 <= p < limit."""
    for n in range(2, limit):
        if is_prime(n):
            yield n


def divisors(n: int) -> List[int]:
    """Return the sorted list of positive divisors of n (n >= 1)."""
    small: List[int] = []
    large: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def legendre_symbol(a: int, p: int) -> int:
    """Legendre symbol (a|p) for odd prime p, returned in {-1, 0, 1}."""
    a %= p
    if a == 0:
        return 0
    ls = pow(a, (p - 1) // 2, p)
    return ls - p if ls > 1 else ls


# --------------------------------------------------------------------------- #
#  Rank of apparition: naive scan and bounded (law-certified) algorithm.      #
# --------------------------------------------------------------------------- #
def rank_naive(p: int, bound: int = 10_000_000) -> int:
    """Least k > 0 with p | F_k, found by scanning k = 1, 2, 3, ... ."""
    a, b = 0, 1
    for k in range(1, bound + 1):
        a, b = b, (a + b) % p
        if a % p == 0:
            return k
    raise RuntimeError(f"no entry point found below bound for p={p}")


def rank_bounded(p: int) -> int:
    """
    Least k > 0 with p | F_k, computed by the Law of Apparition:
    test only the divisors of p-1 and p+1, in increasing order.
    Valid for primes p >= 7.
    """
    candidates = sorted(set(divisors(p - 1)) | set(divisors(p + 1)))
    for d in candidates:
        if fib_mod(d, p) == 0:
            return d
    raise RuntimeError(f"law of apparition violated for p={p}")  # never happens


# --------------------------------------------------------------------------- #
#  Demonstrations.                                                             #
# --------------------------------------------------------------------------- #
def demo_table(limit: int = 60) -> None:
    """Print alpha(p), its branch (p-1 / p+1), and the Legendre symbol (5|p)."""
    header = f"{'p':>4} | {'alpha(p)':>8} | {'p-1':>4} {'p+1':>4} | branch | (5|p) | p%5"
    print(header)
    print("-" * len(header))
    for p in primes_up_to(limit):
        if p < 7:
            continue
        a = rank_bounded(p)
        div_pm1 = (p - 1) % a == 0
        div_pp1 = (p + 1) % a == 0
        if div_pm1 and div_pp1:
            branch = "both"
        elif div_pm1:
            branch = "p-1"
        elif div_pp1:
            branch = "p+1"
        else:
            branch = "NONE!"  # would falsify the theorem
        print(f"{p:>4} | {a:>8} | {p-1:>4} {p+1:>4} | {branch:>6} |"
              f" {legendre_symbol(5, p):>5} | {p % 5}")


def verify_law(limit: int = 5000) -> None:
    """Check the law, the Fibonacci-Fermat law, and F_p^2==1 for primes < limit."""
    checked = 0
    for p in primes_up_to(limit):
        if p < 7:
            continue
        checked += 1

        # (2) Law of apparition.
        a = rank_bounded(p)
        assert (p - 1) % a == 0 or (p + 1) % a == 0, f"law fails at p={p}"

        # (1) Spine: bounded and naive agree (sample small primes for naive cost).
        if p < 400:
            assert a == rank_naive(p), f"rank mismatch at p={p}"

        # (3) Fibonacci-Fermat law.
        assert fib_mod(p - 1, p) == 0 or fib_mod(p + 1, p) == 0, \
            f"Fibonacci-Fermat fails at p={p}"

        # (4) Engine residue: F_p^2 == 1 (mod p) and F_p == (5|p) (mod p).
        fp = fib_mod(p, p)
        assert (fp * fp) % p == 1, f"F_p^2 != 1 at p={p}"
        assert fp % p == legendre_symbol(5, p) % p, f"F_p != (5|p) at p={p}"

    print(f"All checks passed for {checked} primes in [7, {limit}).")


def demo_spine(p: int = 11, kmax: int = 60) -> None:
    """Show that {k : p | F_k} is exactly the multiples of alpha(p)."""
    a = rank_bounded(p)
    hits = [k for k in range(1, kmax + 1) if fib_mod(k, p) == 0]
    print(f"p = {p}, alpha(p) = {a}")
    print(f"indices k <= {kmax} with p | F_k : {hits}")
    print(f"multiples of alpha(p) up to {kmax}: "
          f"{list(range(a, kmax + 1, a))}")
    assert hits == list(range(a, kmax + 1, a)), "spine violated"
    print("=> the entry indices are exactly the multiples of alpha(p).")


def demo_large_prime() -> None:
    """The bounded algorithm handles a large prime where naive scan is hopeless."""
    p = 1_000_000_007  # a well-known large prime
    a = rank_bounded(p)
    print(f"p = {p}")
    print(f"alpha(p) = {a}")
    print(f"(p-1) % alpha = {(p - 1) % a}, (p+1) % alpha = {(p + 1) % a}")
    print(f"F_alpha mod p = {fib_mod(a, p)} (should be 0)")


if __name__ == "__main__":
    print("=== 1. Rank table (alpha(p), branch, Legendre symbol) ===")
    demo_table(60)
    print()
    print("=== 2. The spine for p = 11 ===")
    demo_spine(11, 60)
    print()
    print("=== 3. Verifying the law for all primes below 5000 ===")
    verify_law(5000)
    print()
    print("=== 4. Bounded algorithm on a large prime ===")
    demo_large_prime()


"""
Visualization of the Fibonacci Law of Apparition.

Produces a scatter plot of the normalized rank alpha(p) / p against p for primes
7 <= p < N, coloured by which branch holds (alpha | p-1 vs alpha | p+1), with the
diagonal envelope alpha(p) <= p+1 drawn for reference.  Saves 'apparition.png'.

Self-contained except for matplotlib.
"""

from __future__ import annotations

from typing import List, Tuple

import matplotlib.pyplot as plt


def is_prime(n: int) -> bool:
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


def divisors(n: int) -> List[int]:
    small, large = [], []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def fib_pair_mod(n: int, m: int) -> Tuple[int, int]:
    if m == 1:
        return (0, 0)
    if n == 0:
        return (0, 1 % m)
    a, b = fib_pair_mod(n >> 1, m)
    c = (a * ((2 * b - a) % m)) % m
    d = (a * a + b * b) % m
    return (d, (c + d) % m) if n & 1 else (c, d)


def fib_mod(n: int, m: int) -> int:
    return fib_pair_mod(n, m)[0]


def rank_bounded(p: int) -> int:
    for d in sorted(set(divisors(p - 1)) | set(divisors(p + 1))):
        if fib_mod(d, p) == 0:
            return d
    raise RuntimeError("law violated")


def main(limit: int = 2000) -> None:
    xs_minus, ys_minus, xs_plus, ys_plus = [], [], [], []
    for p in range(7, limit):
        if not is_prime(p):
            continue
        a = rank_bounded(p)
        if (p - 1) % a == 0:
            xs_minus.append(p)
            ys_minus.append(a / p)
        else:
            xs_plus.append(p)
            ys_plus.append(a / p)

    plt.figure(figsize=(10, 6))
    plt.scatter(xs_minus, ys_minus, s=8, alpha=0.6,
                label=r"$\alpha(p)\mid p-1$  ($p\equiv\pm1\,\mathrm{mod}\,5$)")
    plt.scatter(xs_plus, ys_plus, s=8, alpha=0.6,
                label=r"$\alpha(p)\mid p+1$  ($p\equiv\pm2\,\mathrm{mod}\,5$)")
    plt.axhline(1.0, color="gray", linestyle="--", linewidth=1,
                label=r"envelope $\alpha(p)=p+1$")
    plt.xlabel("prime $p$")
    plt.ylabel(r"normalized rank $\alpha(p)/p$")
    plt.title("Fibonacci rank of apparition, coloured by branch")
    plt.legend(loc="lower right")
    plt.tight_layout()
    plt.savefig("apparition.png", dpi=150)
    print("saved apparition.png")


if __name__ == "__main__":
    main()
