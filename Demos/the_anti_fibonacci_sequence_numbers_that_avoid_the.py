"""
Numerical demonstrations for the Greedy Anti-Fibonacci Sequence.

The greedy anti-Fibonacci sequence starts at 1 and repeatedly appends the
smallest positive integer not yet used that is NOT the sum of two consecutive
earlier terms. This script demonstrates the main theorems:

  * The greedy simulation produces exactly the positive non-multiples of 3.
  * The closed form  A(k) = floor((3k+2)/2)  matches the simulation.
  * The structural identity  A(k) + A(k+1) = 3(k+1).
  * Linear growth:  A(n)/n -> 3/2.
  * Consecutive ratio:  A(n+1)/A(n) -> 1  (avoids the golden ratio phi).
  * The avoided set is exactly the positive multiples of 3 (density 1/3).

Run:  python demo.py
"""

from __future__ import annotations

from typing import List, Set, Tuple


# ---------------------------------------------------------------------------
# 1. The honest greedy simulation
# ---------------------------------------------------------------------------
def greedy_anti_fibonacci(n_terms: int) -> Tuple[List[int], Set[int]]:
    """Simulate the greedy rule directly.

    At each step, append the smallest positive integer that has not yet
    appeared and is not equal to any consecutive sum A(i) + A(i+1) of earlier
    terms. Returns the list of terms and the set of avoided (forbidden) values.
    """
    if n_terms <= 0:
        return [], set()
    terms: List[int] = [1]
    forbidden: Set[int] = set()
    used: Set[int] = {1}
    while len(terms) < n_terms:
        # register the newest consecutive sum
        s = terms[-1] + terms[-2] if len(terms) >= 2 else None
        if s is not None:
            forbidden.add(s)
        candidate = terms[-1] + 1
        while candidate in used or candidate in forbidden:
            candidate += 1
        terms.append(candidate)
        used.add(candidate)
    # record the final consecutive sum for completeness
    if len(terms) >= 2:
        forbidden.add(terms[-1] + terms[-2])
    return terms, forbidden


# ---------------------------------------------------------------------------
# 2. The closed form
# ---------------------------------------------------------------------------
def anti_fib(k: int) -> int:
    """Closed form of the k-th term (0-indexed):  floor((3k+2)/2)."""
    return (3 * k + 2) // 2


def consecutive_sum(k: int) -> int:
    """A(k) + A(k+1), which equals 3*(k+1)."""
    return anti_fib(k) + anti_fib(k + 1)


# ---------------------------------------------------------------------------
# 3. Demonstrations
# ---------------------------------------------------------------------------
def demo_first_terms() -> None:
    print("=" * 68)
    print("First 12 terms: greedy simulation vs. closed form")
    print("=" * 68)
    terms, forbidden = greedy_anti_fibonacci(12)
    closed = [anti_fib(k) for k in range(12)]
    print(f"  greedy      : {terms}")
    print(f"  closed form : {closed}")
    print(f"  match       : {terms == closed}")
    print(f"  non-mult-of-3: {terms == [m for m in range(1, 40) if m % 3 != 0][:12]}")
    print(f"  avoided set (multiples of 3): {sorted(forbidden)[:8]}")


def demo_structural_identity() -> None:
    print("\n" + "=" * 68)
    print("Structural identity  A(k) + A(k+1) = 3(k+1)")
    print("=" * 68)
    for k in range(8):
        s = consecutive_sum(k)
        print(f"  A({k}) + A({k+1}) = {anti_fib(k)} + {anti_fib(k+1)} = {s}"
              f"   (3*{k+1} = {3*(k+1)}, divisible by 3: {s % 3 == 0})")


def demo_avoidance() -> None:
    print("\n" + "=" * 68)
    print("Avoidance: no term is ever a consecutive sum")
    print("=" * 68)
    terms = set(anti_fib(k) for k in range(200))
    sums = set(consecutive_sum(k) for k in range(200))
    overlap = terms & sums
    print(f"  #terms (k<200)        : {len(terms)}")
    print(f"  #consecutive sums     : {len(sums)}")
    print(f"  overlap (should be 0) : {len(overlap)}")
    print(f"  every term % 3 != 0   : {all(t % 3 != 0 for t in terms)}")
    print(f"  every sum   % 3 == 0  : {all(s % 3 == 0 for s in sums)}")


def demo_asymptotics() -> None:
    print("\n" + "=" * 68)
    print("Asymptotics:  A(n)/n -> 3/2   and   A(n+1)/A(n) -> 1")
    print("=" * 68)
    phi = (1 + 5 ** 0.5) / 2
    print(f"  (for reference, golden ratio phi = {phi:.6f})")
    print(f"  {'n':>10} {'A(n)':>12} {'A(n)/n':>12} {'A(n+1)/A(n)':>14}")
    for n in [10, 100, 1_000, 10_000, 100_000, 1_000_000]:
        a_n = anti_fib(n)
        ratio_lin = a_n / n
        ratio_con = anti_fib(n + 1) / a_n
        print(f"  {n:>10} {a_n:>12} {ratio_lin:>12.6f} {ratio_con:>14.6f}")
    print("  -> A(n)/n approaches 1.5, consecutive ratio approaches 1.0")


def demo_density() -> None:
    print("\n" + "=" * 68)
    print("Densities: terms have density 2/3, avoided set density 1/3")
    print("=" * 68)
    for N in [1_000, 10_000, 100_000, 1_000_000]:
        terms = sum(1 for m in range(1, N + 1) if m % 3 != 0)
        avoided = sum(1 for m in range(1, N + 1) if m % 3 == 0)
        print(f"  N={N:>9}: term density = {terms/N:.5f}, "
              f"avoided density = {avoided/N:.5f}")


def demo_folklore_correction() -> None:
    print("\n" + "=" * 68)
    print("Folklore correction: the quadratic list is lazy-caterer numbers")
    print("=" * 68)

    def lazy_caterer(n: int) -> int:
        return 1 + n * (n - 1) // 2

    lc = [lazy_caterer(n) for n in range(1, 9)]
    print(f"  lazy-caterer q(n) = 1 + C(n,2): {lc}")
    print(f"  (this is the '1,2,4,7,11,16,...' quadratic list)")
    # These are NOT sum-avoiding: q(3)+q(4) = q(5)
    q3, q4, q5 = lazy_caterer(3), lazy_caterer(4), lazy_caterer(5)
    print(f"  q(3)+q(4) = {q3}+{q4} = {q3+q4} = q(5) = {q5}  "
          f"-> a term IS a consecutive sum, so NOT anti-Fibonacci")


def main() -> None:
    demo_first_terms()
    demo_structural_identity()
    demo_avoidance()
    demo_asymptotics()
    demo_density()
    demo_folklore_correction()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
