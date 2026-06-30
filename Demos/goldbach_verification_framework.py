"""
Numerical demonstrations of the reflection principle for two-summand
representation counts, and its applications to the Goldbach framework.

For a set A of allowed summands and a target n, the (unordered) representation
count is

    r_A(n) = #{ p in {0..n} : p in A and (n - p) in A and p <= n - p }.

The reflection principle states: if A is symmetric about n/2 (closed under
k -> n - k on its elements <= n), then r_A(n) equals the number of elements of
A in the lower half {0, ..., floor(n/2)}.

This script verifies, by direct enumeration, the closed forms proved in the
accompanying paper:

  * r_full(n)            = floor(n/2) + 1            (all summands allowed)
  * r_A(n)              <= floor(n/2) + 1            (universal upper bound)
  * r_even(n)           = 0                          (n odd)
  * r_even(n)           = floor((n/2)/2) + 1         (n even)

and exhibits the Goldbach partition count g(n) together with the ternary
peel-off reduction n = 3 + (n - 3).
"""

from __future__ import annotations

from typing import Callable, List, Set


def representation_count(in_set: Callable[[int], bool], n: int) -> int:
    """Count unordered pairs (p, n - p) with both summands in the set.

    `in_set(k)` returns True iff k belongs to the summand set A.
    Each unordered pair {p, n - p} is counted once via the constraint p <= n - p.
    """
    return sum(
        1
        for p in range(n + 1)
        if in_set(p) and in_set(n - p) and p <= n - p
    )


def lower_half_count(in_set: Callable[[int], bool], n: int) -> int:
    """Number of elements of A in the lower half {0, ..., floor(n/2)}."""
    return sum(1 for p in range(n // 2 + 1) if in_set(p))


def is_even(k: int) -> bool:
    """Membership predicate for the set of even natural numbers."""
    return k % 2 == 0


def sieve_primes(limit: int) -> Set[int]:
    """Return the set of primes <= limit via the sieve of Eratosthenes."""
    if limit < 2:
        return set()
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return {i for i in range(limit + 1) if sieve[i]}


def goldbach_partition_count(n: int, primes: Set[int]) -> int:
    """Number of unordered prime pairs (p, q) with p + q = n, p <= q."""
    return representation_count(lambda k: k in primes, n)


def smallest_summand(n: int, primes: Set[int]) -> int:
    """Smallest prime p with n - p also prime (the smaller Goldbach summand)."""
    for p in sorted(primes):
        if p > n // 2:
            break
        if (n - p) in primes:
            return p
    return -1


def demo_reflection_principle() -> None:
    print("=" * 70)
    print("Reflection principle: r_A(n) == #(A in lower half)  for symmetric A")
    print("=" * 70)
    print(f"{'n':>5} | {'r_even(n)':>10} | {'lower-half':>10} | match")
    print("-" * 45)
    for n in range(0, 21, 2):  # even n: the even set is symmetric about n/2
        r = representation_count(is_even, n)
        lh = lower_half_count(is_even, n)
        print(f"{n:>5} | {r:>10} | {lh:>10} | {r == lh}")


def demo_unrestricted_and_bound() -> None:
    print("\n" + "=" * 70)
    print("Unrestricted count r_full(n) = floor(n/2)+1, and universal bound")
    print("=" * 70)
    print(f"{'n':>5} | {'r_full':>7} | {'floor(n/2)+1':>13} | {'g(n)':>5} | g<=bound")
    print("-" * 55)
    primes = sieve_primes(60)
    for n in range(2, 41, 2):
        r_full = representation_count(lambda k: True, n)
        bound = n // 2 + 1
        g = goldbach_partition_count(n, primes)
        print(f"{n:>5} | {r_full:>7} | {bound:>13} | {g:>5} | {g <= bound}")


def demo_even_dichotomy() -> None:
    print("\n" + "=" * 70)
    print("Even-summand parity dichotomy")
    print("=" * 70)
    print(f"{'n':>5} | parity | {'r_even':>7} | predicted")
    print("-" * 40)
    for n in range(0, 17):
        r = representation_count(is_even, n)
        if n % 2 == 1:
            pred = 0
        else:
            pred = (n // 2) // 2 + 1
        parity = "odd " if n % 2 else "even"
        print(f"{n:>5} | {parity} | {r:>7} | {pred}  ({'ok' if r == pred else 'FAIL'})")


def demo_goldbach_and_ternary() -> None:
    print("\n" + "=" * 70)
    print("Goldbach partitions and the ternary peel-off  n = 3 + (n - 3)")
    print("=" * 70)
    primes = sieve_primes(200)
    print(f"{'n':>5} | {'g(n)':>5} | {'smallest p':>10}")
    print("-" * 30)
    for n in range(4, 41, 2):
        g = goldbach_partition_count(n, primes)
        p = smallest_summand(n, primes)
        print(f"{n:>5} | {g:>5} | {p:>10}")

    print("\nTernary reduction for odd n >= 7  (n = 3 + p + q):")
    for n in range(7, 26, 2):
        m = n - 3  # even, >= 4
        p = smallest_summand(m, primes)
        q = m - p
        print(f"  {n} = 3 + {p} + {q}   (since {n} - 3 = {m} = {p} + {q})")


def verify_goldbach_up_to(limit: int) -> bool:
    """Confirm every even n in [4, limit] has at least one Goldbach partition."""
    primes = sieve_primes(limit)
    for n in range(4, limit + 1, 2):
        if goldbach_partition_count(n, primes) < 1:
            print(f"  COUNTEREXAMPLE at n = {n}")
            return False
    return True


def main() -> None:
    demo_reflection_principle()
    demo_unrestricted_and_bound()
    demo_even_dichotomy()
    demo_goldbach_and_ternary()
    print("\n" + "=" * 70)
    print("Computational verification of binary Goldbach up to 10000")
    print("=" * 70)
    ok = verify_goldbach_up_to(10000)
    print(f"  Every even n in [4, 10000] is a sum of two primes: {ok}")


if __name__ == "__main__":
    main()
