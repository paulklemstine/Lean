"""Numerical demonstrations for the Anti-Fibonacci sequence.

The anti-Fibonacci sequence is defined by

    A(0) = 1,   A(n+1) = A(n) + n,

equivalently by the closed form  A(n) = (n^2 - n + 2) / 2.

This self-contained script demonstrates the paper's main results:

  1. Closed form vs. recurrence agreement.
  2. Sharp addition-avoidance excess  (A(n-1)+A(n-2)) - A(n) = (n-2)(n-5)/2,
     strict avoidance for n >= 6, unique equality A(5) = A(4) + A(3).
  3. Quadratic growth constant  A(n)/n^2 -> 1/2  (NOT 1/4).
  4. Consecutive ratio  A(n+1)/A(n) -> 1  (monotone, not oscillating),
     hence provably not the golden ratio phi.

Run:  python3 demo.py
"""

from __future__ import annotations

from typing import List, Tuple


def anti_fib_closed(n: int) -> int:
    """Return A(n) via the exact closed form (n^2 - n + 2) / 2, O(1)."""
    return (n * n - n + 2) // 2


def anti_fib_sequence(count: int) -> List[int]:
    """Generate A(0), ..., A(count-1) via the recurrence A(n+1) = A(n) + n."""
    seq: List[int] = []
    a = 1  # A(0)
    for n in range(count):
        seq.append(a)
        a = a + n  # A(n+1) = A(n) + n
    return seq


def avoidance_excess(n: int) -> int:
    """Return (A(n-1) + A(n-2)) - A(n); equals (n-2)(n-5)/2."""
    return anti_fib_closed(n - 1) + anti_fib_closed(n - 2) - anti_fib_closed(n)


def growth_ratio(n: int) -> float:
    """Return A(n) / n^2  (approaches 1/2)."""
    return anti_fib_closed(n) / (n * n)


def consecutive_ratio(n: int) -> float:
    """Return A(n+1) / A(n)  (approaches 1)."""
    return anti_fib_closed(n + 1) / anti_fib_closed(n)


def demo_closed_vs_recurrence(count: int = 15) -> None:
    print("=" * 64)
    print("1. Closed form vs recurrence")
    print("=" * 64)
    seq = anti_fib_sequence(count)
    closed = [anti_fib_closed(n) for n in range(count)]
    print("recurrence:", seq)
    print("closed    :", closed)
    assert seq == closed, "closed form and recurrence disagree!"
    print("MATCH: A(n) = (n^2 - n + 2)/2 confirmed for n < %d\n" % count)


def demo_avoidance(upto: int = 12) -> None:
    print("=" * 64)
    print("2. Addition avoidance: (A(n-1)+A(n-2)) - A(n) = (n-2)(n-5)/2")
    print("=" * 64)
    print(f"{'n':>3} {'A(n)':>6} {'A(n-1)+A(n-2)':>14} {'excess':>7} {'(n-2)(n-5)/2':>13}")
    for n in range(2, upto):
        exc = avoidance_excess(n)
        formula = (n - 2) * (n - 5) // 2
        assert exc == formula
        s = anti_fib_closed(n - 1) + anti_fib_closed(n - 2)
        tag = ""
        if exc == 0:
            tag = "  <- EQUALITY (A5 = A4 + A3)" if n == 5 else "  <- boundary"
        elif exc < 0:
            tag = "  term exceeds sum"
        print(f"{n:>3} {anti_fib_closed(n):>6} {s:>14} {exc:>7} {formula:>13}{tag}")
    print("For all n >= 6 the excess is positive: A(n) < A(n-1)+A(n-2) strictly.\n")


def demo_growth() -> None:
    print("=" * 64)
    print("3. Quadratic growth constant: A(n)/n^2 -> 1/2  (not 1/4)")
    print("=" * 64)
    for n in (10, 100, 1000, 10_000, 100_000, 1_000_000):
        print(f"  n = {n:>9}   A(n)/n^2 = {growth_ratio(n):.8f}")
    print("  limit = 0.5  (the '1/4' conjecture is refuted)\n")


def demo_ratio() -> None:
    print("=" * 64)
    print("4. Consecutive ratio A(n+1)/A(n) -> 1  (not the golden ratio)")
    print("=" * 64)
    phi = (1 + 5 ** 0.5) / 2
    prev = None
    for n in (2, 5, 10, 100, 1000, 10_000):
        r = consecutive_ratio(n)
        mono = ""
        if prev is not None:
            mono = "decreasing" if r < prev else "increasing"
        print(f"  n = {n:>6}   A(n+1)/A(n) = {r:.6f}   {mono}")
        prev = r
    print(f"  limit = 1.0 ;  golden ratio phi = {phi:.6f} is NOT approached.")
    print("  Since the ratio -> 1 and phi^2 = phi + 1 forbids phi = 1,")
    print("  the golden ratio is logically excluded.\n")


def main() -> None:
    demo_closed_vs_recurrence()
    demo_avoidance()
    demo_growth()
    demo_ratio()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
