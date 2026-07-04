"""
Numerical demonstrations for the Anti-Fibonacci sequence.

The anti-Fibonacci sequence is defined by
    A(0) = 1,   A(n+1) = A(n) + n,
producing 1, 1, 2, 4, 7, 11, 16, 22, 29, 37, 46, ...

This script verifies, purely numerically, the exact results proved in the
accompanying paper:

  * closed form            A(n) = 1 + n(n-1)/2
  * quadratic density      A(n) / n^2  -> 1/2
  * neighbor ratio         A(n+1)/A(n) -> 1   (never the golden ratio ~1.618)
  * cubic partial sums     6 * sum_{k<=n} A(k) = n^3 + 5n + 6
  * cubic Cesaro density   (sum_{k<=n} A(k)) / n^3 -> 1/6
  * square spectrum        m in range(A)  iff  8m - 7 is a perfect square
  * density zero           #{m < M : m in range(A)} ~ sqrt(2M)

Self-contained: standard library only.
"""

from __future__ import annotations

from math import isqrt, sqrt


# --------------------------------------------------------------------------
# Core generators and closed forms
# --------------------------------------------------------------------------
def anti_fib_iter(n_max: int) -> list[int]:
    """Return [A(0), ..., A(n_max)] via the recurrence A(n+1) = A(n) + n."""
    seq: list[int] = [1]
    for n in range(n_max):
        seq.append(seq[-1] + n)
    return seq


def anti_fib_closed(n: int) -> int:
    """Closed form A(n) = 1 + n(n-1)/2 in O(1)."""
    return 1 + n * (n - 1) // 2


def anti_fib_partial_sum_closed(n: int) -> int:
    """Closed form for sum_{k=0}^{n} A(k) = (n^3 + 5n + 6)/6 in O(1)."""
    return (n ** 3 + 5 * n + 6) // 6


def is_anti_fib(m: int) -> bool:
    """Membership test: m in range(A) iff 8m - 7 is a perfect square."""
    if m < 1:
        return False
    s = 8 * m - 7
    r = isqrt(s)
    return r * r == s


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_closed_form(n_max: int = 20) -> None:
    print("=== Closed form  A(n) = 1 + n(n-1)/2 ===")
    seq = anti_fib_iter(n_max)
    ok = all(seq[n] == anti_fib_closed(n) for n in range(n_max + 1))
    print(f"first terms: {seq[:11]}")
    print(f"recurrence matches closed form up to n={n_max}: {ok}")
    print()


def demo_quadratic_density(n_max: int = 1_000_000) -> None:
    print("=== Quadratic density  A(n)/n^2 -> 1/2 ===")
    for n in [10, 100, 1000, 10_000, 100_000, n_max]:
        val = anti_fib_closed(n) / n ** 2
        print(f"  n = {n:>9}:  A(n)/n^2 = {val:.8f}")
    print(f"  target                = {0.5:.8f}")
    print()


def demo_neighbor_ratio(n_max: int = 1_000_000) -> None:
    print("=== Neighbor ratio  A(n+1)/A(n) -> 1  (not the golden ratio) ===")
    golden = (1 + sqrt(5)) / 2
    for n in [1, 2, 3, 5, 10, 100, 10_000, n_max]:
        ratio = anti_fib_closed(n + 1) / anti_fib_closed(n)
        print(f"  n = {n:>9}:  A(n+1)/A(n) = {ratio:.6f}")
    print(f"  limit = 1.000000   (golden ratio = {golden:.6f}, never reached)")
    print()


def demo_cubic_partial_sums(n_max: int = 12) -> None:
    print("=== Cubic partial sums  6*sum_{k<=n} A(k) = n^3 + 5n + 6 ===")
    seq = anti_fib_iter(n_max)
    running = 0
    ok = True
    for n in range(n_max + 1):
        running += seq[n]
        lhs = 6 * running
        rhs = n ** 3 + 5 * n + 6
        ok = ok and (lhs == rhs)
        if n < 8:
            print(f"  n = {n}:  6*sum = {lhs:>4}   n^3+5n+6 = {rhs:>4}")
    print(f"identity holds up to n={n_max}: {ok}")
    print()


def demo_cesaro_density(n_max: int = 1_000_000) -> None:
    print("=== Cubic Cesaro density  (sum_{k<=n} A(k))/n^3 -> 1/6 ===")
    for n in [10, 100, 1000, 100_000, n_max]:
        val = anti_fib_partial_sum_closed(n) / n ** 3
        print(f"  n = {n:>9}:  sum/n^3 = {val:.8f}")
    print(f"  target                = {1/6:.8f}")
    print()


def demo_square_spectrum(m_max: int = 60) -> None:
    print("=== Square spectrum  m in range(A) iff 8m-7 is a perfect square ===")
    seq = set(anti_fib_iter(200))  # plenty of terms to cover m_max
    members = [m for m in range(1, m_max + 1) if is_anti_fib(m)]
    truth = [m for m in range(1, m_max + 1) if m in seq]
    print(f"  via 8m-7 test : {members}")
    print(f"  via generation: {truth}")
    print(f"  agree: {members == truth}")
    print()


def demo_density_zero(m_max: int = 1_000_000) -> None:
    print("=== Density zero  #{m < M : m in range(A)} ~ sqrt(2M) ===")
    for M in [100, 10_000, 1_000_000, m_max]:
        count = sum(1 for m in range(1, M) if is_anti_fib(m))
        print(f"  M = {M:>9}:  count = {count:>5}   sqrt(2M) = {sqrt(2*M):8.2f}   "
              f"density = {count / M:.2e}")
    print()


def main() -> None:
    demo_closed_form()
    demo_quadratic_density()
    demo_neighbor_ratio()
    demo_cubic_partial_sums()
    demo_cesaro_density()
    demo_square_spectrum()
    demo_density_zero(m_max=1_000_000)


if __name__ == "__main__":
    main()
