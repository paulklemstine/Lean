"""
demo.py — Numerical demonstrations of the unconditional Collatz cycle obstructions.

This script illustrates, with concrete computations, the formally verified results
about the Collatz step map

    T(n) = n / 2      if n is even,
    T(n) = 3n + 1     if n is odd.

It demonstrates:
  * T_even / T_odd        — parity evaluation rules
  * T_lt_of_even          — even steps strictly decrease positive inputs
  * T_gt_of_odd           — odd steps strictly increase inputs
  * T_no_fixed_point      — T has no positive fixed point
  * all_even_descent      — k consecutive even iterates divide by 2^k exactly
  * periodic_has_odd      — every positive periodic orbit contains an odd element

All functions are self-contained and type-hinted; the script runs under any CPython 3.8+.
"""

from __future__ import annotations

from typing import List, Tuple


# --------------------------------------------------------------------------- #
#  The Collatz step map and its iterate
# --------------------------------------------------------------------------- #
def T(n: int) -> int:
    """The Collatz step map: n/2 if n is even, else 3n+1."""
    if n % 2 == 0:
        return n // 2
    return 3 * n + 1


def iterate(n: int, k: int) -> int:
    """Apply T exactly k times: T^[k](n)."""
    for _ in range(k):
        n = T(n)
    return n


# --------------------------------------------------------------------------- #
#  Demonstration 1 — parity rules and the monotonicity dichotomy
# --------------------------------------------------------------------------- #
def demo_monotonicity(samples: List[int]) -> None:
    """Verify T_even, T_odd, T_lt_of_even, T_gt_of_odd on sample inputs."""
    print("=" * 70)
    print("Demo 1: parity rules and monotonicity dichotomy")
    print("=" * 70)
    for n in samples:
        if n % 2 == 0:
            assert T(n) == n // 2, "T_even violated"
            if n > 0:
                assert T(n) < n, "T_lt_of_even violated"
            print(f"  n={n:5d} (even): T(n)={T(n):5d} = n/2,  and T(n) < n  ✓")
        else:
            assert T(n) == 3 * n + 1, "T_odd violated"
            assert T(n) > n, "T_gt_of_odd violated"
            print(f"  n={n:5d} (odd) : T(n)={T(n):5d} = 3n+1, and T(n) > n  ✓")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 2 — no fixed points
# --------------------------------------------------------------------------- #
def demo_no_fixed_point(limit: int) -> None:
    """Confirm T_no_fixed_point: T(n) != n for all 0 < n <= limit."""
    print("=" * 70)
    print("Demo 2: no positive fixed point (T_no_fixed_point)")
    print("=" * 70)
    offenders = [n for n in range(1, limit + 1) if T(n) == n]
    assert offenders == [], f"fixed points found: {offenders}"
    print(f"  Checked all 1 <= n <= {limit}: NO n satisfies T(n) = n.  ✓")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 3 — all-even descent identity
# --------------------------------------------------------------------------- #
def all_even_run_length(n: int) -> int:
    """Largest k with T^[i](n) even for all 0 <= i < k (== the 2-adic valuation of n)."""
    k = 0
    while n % 2 == 0 and n > 0:
        n //= 2
        k += 1
    return k


def demo_all_even_descent(samples: List[int]) -> None:
    """Verify all_even_descent: a run of k even iterates gives T^[k](n) = n / 2^k."""
    print("=" * 70)
    print("Demo 3: all-even descent identity (all_even_descent)")
    print("=" * 70)
    for n in samples:
        k = all_even_run_length(n)
        lhs = iterate(n, k)
        rhs = n // (2 ** k)
        assert all(iterate(n, i) % 2 == 0 for i in range(k)), "premise broken"
        assert lhs == rhs, "all_even_descent violated"
        print(f"  n={n:6d}: first {k} iterates even => T^[{k}](n)={lhs} = n/2^{k}={rhs}  ✓")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 4 — every periodic orbit contains an odd element
# --------------------------------------------------------------------------- #
def find_period(n: int, max_steps: int = 10_000) -> int:
    """Smallest p > 0 with T^[p](n) = n, or 0 if none found within max_steps."""
    x = T(n)
    for p in range(1, max_steps + 1):
        if x == n:
            return p
        x = T(x)
    return 0


def demo_periodic_has_odd() -> None:
    """Confirm periodic_has_odd on the only known positive cycle {1,4,2}."""
    print("=" * 70)
    print("Demo 4: every periodic orbit contains an odd element (periodic_has_odd)")
    print("=" * 70)
    for n in (1, 2, 4):
        p = find_period(n)
        orbit = [iterate(n, i) for i in range(p)]
        odd_witness = next((x for x in orbit if x % 2 == 1), None)
        assert p > 0 and odd_witness is not None, "no odd element in cycle!"
        print(f"  start n={n}: period p={p}, orbit={orbit}, odd witness={odd_witness}  ✓")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 5 — trajectory profiling (stopping time and altitude)
# --------------------------------------------------------------------------- #
def trajectory(n: int, max_steps: int = 100_000) -> Tuple[List[int], str]:
    """Return (orbit until reaching 1, parity word) for the orbit of n."""
    orbit = [n]
    word = []
    steps = 0
    while n != 1 and steps < max_steps:
        word.append("E" if n % 2 == 0 else "O")
        n = T(n)
        orbit.append(n)
        steps += 1
    return orbit, "".join(word)


def demo_trajectories(samples: List[int]) -> None:
    """Show total stopping time, peak altitude, and odd-step count per trajectory."""
    print("=" * 70)
    print("Demo 5: trajectory profiles (stopping time, altitude, odd count)")
    print("=" * 70)
    print(f"  {'n':>6} {'steps':>7} {'peak':>8} {'#odd':>6}  parity word")
    for n in samples:
        orbit, word = trajectory(n)
        print(f"  {n:>6} {len(orbit)-1:>7} {max(orbit):>8} {word.count('O'):>6}  {word}")
    print()


# --------------------------------------------------------------------------- #
#  Main
# --------------------------------------------------------------------------- #
def main() -> None:
    demo_monotonicity([1, 2, 3, 4, 6, 7, 16, 27])
    demo_no_fixed_point(100_000)
    demo_all_even_descent([16, 24, 48, 96, 1024, 6])
    demo_periodic_has_odd()
    demo_trajectories([6, 7, 27, 97])
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
