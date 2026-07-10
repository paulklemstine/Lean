"""Numerical demonstrations for
"The Collatz Map: Dynamics, a Min-Plus Stopping-Time Recurrence, and the Logic of Halting".

This self-contained script demonstrates, computationally:

  * the Collatz map T and orbit computation,
  * exact stopping time of powers of two (sigma(2^m) = m),
  * concrete long orbits (sigma(7) = 16, sigma(27) = 111),
  * orbit-invariance of the halting predicate,
  * the bounded (decidable) halting predicate and the search decomposition,
  * the min-plus / Bellman stopping-time recurrence sigma(n) = 1 + sigma(T(n)),
  * a tropical (min-plus) Bellman-Ford fixed-point sweep on a finite window.

Run:  python3 demo.py
"""
from __future__ import annotations

from typing import Dict, List, Optional


# ---------------------------------------------------------------------------
# The Collatz map and basic orbit machinery
# ---------------------------------------------------------------------------
def collatz(n: int) -> int:
    """The Collatz map T: halve an even number, otherwise 3n+1."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def orbit(n: int, max_steps: int = 10_000) -> List[int]:
    """Return the orbit [n, T(n), T^2(n), ...] up to and including the first 1."""
    seq = [n]
    while seq[-1] != 1 and len(seq) <= max_steps:
        seq.append(collatz(seq[-1]))
    return seq


def stopping_time(n: int, max_steps: int = 10_000) -> Optional[int]:
    """Least k with T^k(n) = 1, or None if not found within max_steps."""
    x, k = n, 0
    while x != 1:
        if k >= max_steps:
            return None
        x = collatz(x)
        k += 1
    return k


def reaches_within(b: int, n: int) -> bool:
    """Decidable bounded halting predicate: reaches 1 within b steps."""
    x = n
    for _ in range(b + 1):
        if x == 1:
            return True
        x = collatz(x)
    return False


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_powers_of_two(max_exp: int = 12) -> None:
    print("=" * 68)
    print("Powers of two: sigma(2^m) = m exactly (Theorem 5.1)")
    print("=" * 68)
    for m in range(max_exp + 1):
        n = 2 ** m
        st = stopping_time(n)
        assert st == m, f"expected {m}, got {st}"
        print(f"  2^{m:<2d} = {n:<6d}  stopping time = {st}")
    print("  All powers of two verified: sigma(2^m) = m.\n")


def demo_concrete_orbits() -> None:
    print("=" * 68)
    print("Concrete orbits (Proposition 6.1)")
    print("=" * 68)
    for n, expected in [(7, 16), (27, 111)]:
        seq = orbit(n)
        st = stopping_time(n)
        assert st == expected, f"sigma({n}) expected {expected}, got {st}"
        print(f"  n = {n}:  stopping time = {st}, peak = {max(seq)}")
        if n == 7:
            print("    orbit:", " -> ".join(map(str, seq)))
    print()


def demo_orbit_invariance(upto: int = 2000) -> None:
    print("=" * 68)
    print("Orbit invariance: Reaches(n) <=> Reaches(T(n)) for n != 1 (Thm 4.3)")
    print("=" * 68)
    ok = True
    for n in range(2, upto + 1):
        rn = stopping_time(n) is not None
        rtn = stopping_time(collatz(n)) is not None
        if rn != rtn:
            ok = False
            print(f"  MISMATCH at n = {n}")
    print(f"  Checked n = 2..{upto}: invariance holds = {ok}\n")


def demo_search_decomposition(n: int = 27) -> None:
    print("=" * 68)
    print("Search decomposition: Reaches(n) <=> exists b, ReachesWithin(b,n) (Thm 7.2)")
    print("=" * 68)
    st = stopping_time(n)
    print(f"  n = {n}, sigma(n) = {st}")
    for b in [st - 1, st, st + 5]:
        print(f"    ReachesWithin({b}, {n}) = {reaches_within(b, n)}")
    print("  The witness budget b must be at least sigma(n); no uniform bound exists.\n")


def demo_bellman_recurrence(upto: int = 2000) -> None:
    print("=" * 68)
    print("Min-plus / Bellman recurrence: sigma(n) = 1 + sigma(T(n)) (Thm 8.1)")
    print("=" * 68)
    ok = True
    for n in range(2, upto + 1):
        assert stopping_time(n) == 1 + stopping_time(collatz(n)), n
    print(f"  Verified sigma(n) = 1 + sigma(T(n)) for all n = 2..{upto}: {ok}\n")


def tropical_stopping_times(window: int = 64) -> Dict[int, float]:
    """Compute sigma on {1,...,window} by a tropical (min-plus) Bellman-Ford
    fixed-point sweep: sigma(1)=0, sigma(n)=inf otherwise, repeatedly relax
    sigma(n) = min(sigma(n), 1 + sigma(T(n))) until stable (Algorithm C).

    Successors T(n) may exceed the window; we extend lazily so relaxation is exact.
    """
    inf = float("inf")
    # Collect all reachable nodes from the window so relaxation is closed.
    nodes = set()
    for start in range(1, window + 1):
        x = start
        while x not in nodes:
            nodes.add(x)
            if x == 1:
                break
            x = collatz(x)
    sigma: Dict[int, float] = {v: (0.0 if v == 1 else inf) for v in nodes}
    changed = True
    while changed:
        changed = False
        for v in nodes:
            if v == 1:
                continue
            cand = 1 + sigma[collatz(v)]
            if cand < sigma[v]:
                sigma[v] = cand
                changed = True
    return {v: sigma[v] for v in range(1, window + 1)}


def demo_tropical_sweep(window: int = 32) -> None:
    print("=" * 68)
    print("Tropical Bellman-Ford sweep vs. direct stopping time (Algorithm C)")
    print("=" * 68)
    trop = tropical_stopping_times(window)
    ok = all(trop[n] == stopping_time(n) for n in range(1, window + 1))
    print(f"  min-plus fixed point matches sigma on 1..{window}: {ok}")
    print("  sample:", {n: int(trop[n]) for n in range(1, 11)}, "\n")


def main() -> None:
    demo_powers_of_two()
    demo_concrete_orbits()
    demo_orbit_invariance()
    demo_search_decomposition()
    demo_bellman_recurrence()
    demo_tropical_sweep()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
