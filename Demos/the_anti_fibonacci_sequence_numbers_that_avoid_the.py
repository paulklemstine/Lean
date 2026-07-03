"""
The Anti-Fibonacci Sequence: numerical demonstrations.

The anti-Fibonacci sequence is defined by

    A(0) = 1,   A(n+1) = A(n) + n,

giving 1, 1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56, ...

It is governed by the closed form

    2*A(n) + n = n^2 + 2,     i.e.     A(n) = 1 + n*(n-1)//2.

This script demonstrates, purely numerically:

  1. the closed form matches the recurrence exactly;
  2. A(n)/n^2 -> 1/2  (quadratic growth, leading coefficient 1/2);
  3. A(n+1)/A(n) -> 1, monotonically after the second term,
     and this limit differs from the golden ratio phi = (1+sqrt5)/2;
  4. the Fibonacci relation A(n+2) = A(n+1) + A(n) holds exactly at n in {0, 3},
     with strict undershoot for all n >= 4.

Self-contained: standard library only.
"""

from __future__ import annotations

from math import isqrt
from typing import Dict, List, Tuple

PHI: float = (1.0 + 5.0 ** 0.5) / 2.0  # golden ratio ~ 1.618033988749895


def anti_fibonacci_recurrence(n_max: int) -> List[int]:
    """Return [A(0), ..., A(n_max)] via the recurrence A(k+1) = A(k) + k.

    Time O(n_max), space O(n_max).
    """
    seq: List[int] = [1]
    for k in range(n_max):
        seq.append(seq[-1] + k)
    return seq


def anti_fibonacci_closed(n: int) -> int:
    """Return A(n) via the closed form 1 + n*(n-1)//2 in O(1) integer arithmetic."""
    return 1 + n * (n - 1) // 2


def verify_closed_form(n_max: int) -> bool:
    """Check the closed form and the identity 2*A(n)+n = n^2+2 for 0 <= n <= n_max."""
    seq = anti_fibonacci_recurrence(n_max)
    for n in range(n_max + 1):
        if seq[n] != anti_fibonacci_closed(n):
            return False
        if 2 * seq[n] + n != n * n + 2:
            return False
    return True


def density_table(indices: List[int]) -> List[Tuple[int, int, float]]:
    """Return [(n, A(n), A(n)/n^2)] for each n in indices (n >= 1)."""
    rows: List[Tuple[int, int, float]] = []
    for n in indices:
        a = anti_fibonacci_closed(n)
        rows.append((n, a, a / (n * n)))
    return rows


def ratio_table(n_max: int) -> List[Tuple[int, float]]:
    """Return [(n, A(n+1)/A(n))] for 0 <= n <= n_max."""
    seq = anti_fibonacci_recurrence(n_max + 1)
    return [(n, seq[n + 1] / seq[n]) for n in range(n_max + 1)]


def fibonacci_coincidences(n_max: int) -> Dict[str, List[int]]:
    """Scan n in [0, n_max]: where does A(n+2) = A(n+1) + A(n)?

    Returns the coincidence indices and the indices where A strictly undershoots.
    """
    seq = anti_fibonacci_recurrence(n_max + 2)
    equal: List[int] = []
    undershoot: List[int] = []
    for n in range(n_max + 1):
        lhs = seq[n + 2]
        rhs = seq[n + 1] + seq[n]
        if lhs == rhs:
            equal.append(n)
        elif lhs < rhs:
            undershoot.append(n)
    return {"equal": equal, "undershoot": undershoot}


def is_perfect_square(m: int) -> bool:
    r = isqrt(m)
    return r * r == m


def main() -> None:
    print("=" * 66)
    print("The Anti-Fibonacci Sequence: A(0)=1, A(n+1)=A(n)+n")
    print("=" * 66)

    seq = anti_fibonacci_recurrence(11)
    print("\nFirst terms A(0..11):")
    print("  ", seq)

    print("\n[1] Closed form 2*A(n)+n = n^2+2 and A(n)=1+n(n-1)/2:")
    ok = verify_closed_form(2000)
    print(f"    Verified for 0 <= n <= 2000: {ok}")

    print("\n[2] Density: A(n)/n^2 -> 1/2")
    for n, a, r in density_table([10, 100, 1000, 10 ** 4, 10 ** 6]):
        print(f"    n={n:>8}  A(n)={a:>18}  A(n)/n^2 = {r:.8f}")

    print("\n[3] Consecutive ratio A(n+1)/A(n) -> 1  (phi = %.6f is NOT reached)" % PHI)
    for n, r in ratio_table(10):
        print(f"    n={n:>2}  A(n+1)/A(n) = {r:.6f}")
    for n in [100, 10_000, 1_000_000]:
        r = (anti_fibonacci_closed(n + 1)) / anti_fibonacci_closed(n)
        print(f"    n={n:>8}  A(n+1)/A(n) = {r:.10f}")
    print(f"    limit 1 differs from golden ratio phi by {PHI - 1.0:.6f}")

    print("\n[4] Fibonacci relation A(n+2) = A(n+1) + A(n):")
    res = fibonacci_coincidences(50)
    print(f"    Coincidence indices in [0,50]: {res['equal']}   (expected [0, 3])")
    print(f"    Strict undershoot for all n>=4: "
          f"{all(n >= 4 for n in res['undershoot']) and res['undershoot'][:1] == [4]}")
    print(f"    Check A(2)=A(1)+A(0): {seq[2]} = {seq[1]}+{seq[0]}")
    print(f"    Check A(5)=A(4)+A(3): {seq[5]} = {seq[4]}+{seq[3]}")

    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
