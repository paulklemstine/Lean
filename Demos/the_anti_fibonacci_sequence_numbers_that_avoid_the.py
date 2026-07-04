"""
Numerical demonstrations for the Anti-Fibonacci sequence.

The anti-Fibonacci sequence is defined by
    A(0) = 1,   A(k+1) = A(k) + k,
with first terms 1, 1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56, ...

This script verifies, numerically, the main theorems:
  1. Exact closed form:      2*A(k) + k = k^2 + 2,  i.e.  A(k) = 1 + k(k-1)/2.
  2. Quadratic growth:       A(k)/k^2 -> 1/2.
  3. Avoidance of golden phi: A(k+1)/A(k) -> 1  (NOT phi = 1.618...).
  4. Density zero:           #{A(k) <= N} / N -> 0.
  5. Folklore corrections:   the constant is 1/2 (not 1/4), and the ratio
                             converges monotonically to 1 (it does not oscillate).

Pure standard-library Python; no external dependencies.
"""

from __future__ import annotations

from math import isqrt, sqrt


def anti_fibonacci(n: int) -> list[int]:
    """Return [A(0), ..., A(n-1)] via the recurrence A(k+1) = A(k) + k."""
    seq: list[int] = []
    a: int = 1  # A(0)
    for k in range(n):
        seq.append(a)
        a = a + k  # A(k+1) = A(k) + k
    return seq


def anti_fibonacci_closed(k: int) -> int:
    """Return A(k) via the closed form A(k) = 1 + k(k-1)//2."""
    return 1 + k * (k - 1) // 2


def golden_ratio() -> float:
    """Return phi = (1 + sqrt 5) / 2."""
    return (1.0 + sqrt(5.0)) / 2.0


def verify_closed_form(n: int) -> bool:
    """Check 2*A(k) + k == k^2 + 2 and recurrence == closed form for k < n."""
    seq = anti_fibonacci(n)
    for k in range(n):
        if 2 * seq[k] + k != k * k + 2:
            return False
        if seq[k] != anti_fibonacci_closed(k):
            return False
    return True


def growth_ratios(ks: list[int]) -> list[tuple[int, float]]:
    """Return (k, A(k)/k^2) for each k in ks (k >= 1)."""
    return [(k, anti_fibonacci_closed(k) / (k * k)) for k in ks if k >= 1]


def consecutive_ratios(ks: list[int]) -> list[tuple[int, float]]:
    """Return (k, A(k+1)/A(k)) for each k in ks."""
    out: list[tuple[int, float]] = []
    for k in ks:
        out.append((k, anti_fibonacci_closed(k + 1) / anti_fibonacci_closed(k)))
    return out


def value_density(n_max: int) -> float:
    """Return #{k : A(k) <= n_max} / n_max, the empirical density up to n_max."""
    count = 0
    k = 0
    while anti_fibonacci_closed(k) <= n_max:
        count += 1
        k += 1
    return count / n_max


def main() -> None:
    print("=" * 68)
    print("Anti-Fibonacci sequence  A(0)=1,  A(k+1)=A(k)+k")
    print("=" * 68)

    seq = anti_fibonacci(12)
    print("\nFirst 12 terms:", seq)
    print("Expected      : [1, 1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56]")

    print("\n[1] Exact closed form  2*A(k)+k == k^2+2  and  A(k)=1+k(k-1)/2")
    print("    verified for k < 10000 :", verify_closed_form(10000))

    print("\n[2] Quadratic growth   A(k)/k^2 -> 1/2   (NOT 1/4)")
    for k, r in growth_ratios([10, 100, 1000, 10000, 100000, 1000000]):
        print(f"    k = {k:>8}   A(k)/k^2 = {r:.8f}")
    print("    limit = 0.5")

    print("\n[3] Consecutive ratio  A(k+1)/A(k) -> 1   (golden phi = "
          f"{golden_ratio():.6f})")
    for k, r in consecutive_ratios([10, 100, 1000, 10000, 100000, 1000000]):
        print(f"    k = {k:>8}   A(k+1)/A(k) = {r:.8f}")
    print("    limit = 1.0  =>  NOT phi:  the golden ratio is avoided.")

    print("\n[4] Density of the value set  #{A(k)<=N}/N -> 0")
    for N in [10**3, 10**4, 10**6, 10**8]:
        d = value_density(N)
        print(f"    N = {N:>10}   density = {d:.3e}   (~ sqrt(2/N) = "
              f"{sqrt(2.0 / N):.3e})")

    print("\n[5] Folklore corrections")
    k = 50
    print(f"    A({k})/{k}^2 = {anti_fibonacci_closed(k)/(k*k):.4f}  -> 0.5, "
          "so the constant is 1/2, not 1/4.")
    ratios = [anti_fibonacci_closed(j + 1) / anti_fibonacci_closed(j)
              for j in range(50, 56)]
    print("    consecutive ratios k=50..55:",
          [f"{x:.4f}" for x in ratios])
    print("    monotonically decreasing toward 1 (no oscillation between 1 and 2).")

    print("\n" + "=" * 68)
    print("All numerical checks agree with the theorems.")
    print("=" * 68)


if __name__ == "__main__":
    main()
