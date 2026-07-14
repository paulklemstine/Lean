"""
Fibonacci Pythagorean Triples --- numerical demonstration.

For each n, four consecutive Fibonacci numbers F_n, F_{n+1}, F_{n+2}, F_{n+3}
assemble into a right triangle via Euclid's parametrization with generators
p = F_{n+2}, q = F_{n+1}:

    a = F_n * F_{n+3}          =  p^2 - q^2   (leg)
    b = 2 * F_{n+1} * F_{n+2}  =  2 p q       (leg)
    c = F_{n+1}^2 + F_{n+2}^2  =  p^2 + q^2   (hypotenuse)

This script verifies, for a range of n, the identities:

    a^2 + b^2 = c^2                       (Pythagorean identity)
    c = F_{2n+3}                          (hypotenuse is odd-index Fibonacci)
    a * b = 2 * F_n F_{n+1} F_{n+2} F_{n+3}   (area = product of four Fibonaccis)
    a + b + c = 2 * F_{n+2} F_{n+3}       (perimeter)
    (a + b - c) / 2 = F_n * F_{n+1}       (inradius)
    c_{n+1} = 3 c_n - c_{n-1}             (hypotenuse recurrence)

All computations use exact integer arithmetic, so every check is exact.
"""

from __future__ import annotations

from typing import Dict, List, Tuple


def fib(n: int) -> int:
    """Return the n-th Fibonacci number (F_0 = 0, F_1 = 1) via fast doubling."""
    def _fd(k: int) -> Tuple[int, int]:
        # returns (F_k, F_{k+1})
        if k == 0:
            return (0, 1)
        a, b = _fd(k >> 1)
        c = a * (2 * b - a)          # F_{2m}
        d = a * a + b * b            # F_{2m+1}
        if k & 1:
            return (d, c + d)
        return (c, d)
    if n < 0:
        raise ValueError("n must be non-negative")
    return _fd(n)[0]


def fibonacci_triple(n: int) -> Tuple[int, int, int]:
    """Return the n-th Fibonacci Pythagorean triple (a, b, c)."""
    fn, fn1, fn2, fn3 = fib(n), fib(n + 1), fib(n + 2), fib(n + 3)
    a = fn * fn3
    b = 2 * fn1 * fn2
    c = fn1 * fn1 + fn2 * fn2
    return (a, b, c)


def triple_invariants(n: int) -> Dict[str, int]:
    """Compute the triple together with its geometric invariants."""
    a, b, c = fibonacci_triple(n)
    return {
        "n": n,
        "a": a,
        "b": b,
        "c": c,
        "area": a * b // 2,
        "perimeter": a + b + c,
        "inradius": (a + b - c) // 2,
    }


def check_identities(n: int) -> Dict[str, bool]:
    """Verify all closed-form identities for the n-th triple (exact integers)."""
    a, b, c = fibonacci_triple(n)
    fn, fn1, fn2, fn3 = fib(n), fib(n + 1), fib(n + 2), fib(n + 3)
    return {
        "pythagorean": a * a + b * b == c * c,
        "hypotenuse_is_fib": c == fib(2 * n + 3),
        "area_is_product": a * b == 2 * fn * fn1 * fn2 * fn3,
        "perimeter": a + b + c == 2 * fn2 * fn3,
        "inradius": (a + b - c) == 2 * fn * fn1,
    }


def hypotenuse_recurrence(n_max: int) -> List[int]:
    """Generate hypotenuses c_n = F_{2n+3} via c_{n+1} = 3 c_n - c_{n-1}."""
    seq: List[int] = [2, 5]  # c_0 = F_3 = 2, c_1 = F_5 = 5
    while len(seq) <= n_max:
        seq.append(3 * seq[-1] - seq[-2])
    return seq[: n_max + 1]


def main() -> None:
    print("=" * 78)
    print("Fibonacci Pythagorean Triples")
    print("=" * 78)

    header = f"{'n':>2} | {'a':>6} {'b':>7} {'c':>7} | {'area':>10} {'perim':>8} {'r':>6}"
    print(header)
    print("-" * len(header))
    for n in range(1, 9):
        inv = triple_invariants(n)
        print(
            f"{inv['n']:>2} | {inv['a']:>6} {inv['b']:>7} {inv['c']:>7} | "
            f"{inv['area']:>10} {inv['perimeter']:>8} {inv['inradius']:>6}"
        )

    print()
    print("Identity checks (all should be True):")
    all_ok = True
    for n in range(0, 40):
        checks = check_identities(n)
        ok = all(checks.values())
        all_ok = all_ok and ok
        if n < 5 or not ok:
            print(f"  n={n:>2}: {checks}")
    print(f"  ... verified for n = 0..39: {'ALL PASS' if all_ok else 'FAILURE'}")

    print()
    print("Hypotenuses via linear recurrence c_{n+1} = 3 c_n - c_{n-1}:")
    rec = hypotenuse_recurrence(8)
    direct = [fib(2 * n + 3) for n in range(9)]
    print(f"  recurrence : {rec}")
    print(f"  F_(2n+3)   : {direct}")
    print(f"  match      : {rec == direct}")

    print()
    print("Golden-ratio asymptotics of the leg ratio b/a (limit -> 2):")
    for n in [1, 5, 10, 20, 40]:
        a, b, _ = fibonacci_triple(n)
        print(f"  n={n:>2}: b/a = {b / a:.10f}")


if __name__ == "__main__":
    main()
