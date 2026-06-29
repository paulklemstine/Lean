"""
demo.py — Numerical demonstrations for
"Thresholds, Rigidity, and Bounded Descent:
 Three Phase-Transition Phenomena in Finite and Arithmetic Structure"

This script illustrates three machine-verified results:

  1. Divisibility pigeonhole threshold:
     Any n+1 distinct integers in [1, 2n] contain a divisibility pair,
     while n of them can avoid one.  (Theorem `divisibility_pigeonhole`)

  2. Fibonacci divisibility rigidity:
     For m >= 3,  F_m | F_n  <=>  m | n.  (Theorem `fib_dvd_iff`,
     with forward direction `fib_dvd_of_dvd`).

  3. Finite Garden-of-Eden / bounded descent:
     - A self-map has an unreachable ("Garden-of-Eden") state iff it is
       not surjective (Theorem `exists_garden_of_eden_iff_not_surjective`).
     - On a finite poset, a monotone descending map stabilizes at a fixed
       point within |P| steps (Theorem `finite_garden_of_eden_descent`),
       with iterates forming a descending chain (Theorem `iterate_descends`).

Everything is self-contained: only the Python standard library is used.
Run with:  python3 demo.py
"""

from __future__ import annotations

from typing import Callable, Dict, List, Optional, Sequence, Tuple, TypeVar

A = TypeVar("A")


# ---------------------------------------------------------------------------
# 1. Divisibility pigeonhole
# ---------------------------------------------------------------------------

def odd_part(x: int) -> int:
    """Return the odd part of x: divide out every factor of 2.

    Mirrors the Lean definition `oddPart x = x / 2 ^ (x.factorization 2)`.
    """
    if x == 0:
        return 0
    while x % 2 == 0:
        x //= 2
    return x


def find_divisibility_pair(S: Sequence[int]) -> Optional[Tuple[int, int]]:
    """Return a pair (a, b) with a != b, a | b, drawn from S, or None.

    Uses the constructive pigeonhole argument: group by odd part, then any
    bucket of size >= 2 yields a divisibility pair (smaller power of two
    divides larger).
    """
    buckets: Dict[int, List[int]] = {}
    for x in S:
        buckets.setdefault(odd_part(x), []).append(x)
    for _core, group in buckets.items():
        if len(group) >= 2:
            group.sort()  # ascending; since shared odd part, smaller divides larger
            a, b = group[0], group[-1]
            return (a, b)
    return None


def max_antichain_top_half(n: int) -> List[int]:
    """The extremal divisibility-free set {n+1, ..., 2n} of size n in [1, 2n]."""
    return list(range(n + 1, 2 * n + 1))


def demo_pigeonhole(n: int = 10) -> None:
    print("=" * 70)
    print(f"1. DIVISIBILITY PIGEONHOLE  (range [1, {2 * n}], n = {n})")
    print("=" * 70)

    antichain = max_antichain_top_half(n)
    pair = find_divisibility_pair(antichain)
    print(f"  Top-half set of size {len(antichain)}: {antichain}")
    print(f"    divisibility pair found? {pair}  (None = no pair, as expected)")

    # Add one more element -> n+1 elements -> a pair is forced.
    forced = antichain + [n // 2 if n // 2 >= 1 else 1]
    forced = sorted(set(forced))
    pair2 = find_divisibility_pair(forced)
    print(f"  Adding one element -> size {len(forced)}: {forced}")
    print(f"    forced divisibility pair: {pair2}")

    # Exhaustive check: NO set of size n+1 in [1, 2n] avoids a pair.
    from itertools import combinations
    universe = range(1, 2 * n + 1)
    counterexample_found = False
    for combo in combinations(universe, n + 1):
        if find_divisibility_pair(combo) is None:
            counterexample_found = True
            break
    print(f"  Exhaustive search over all (n+1)-subsets of [1,{2*n}]:")
    print(f"    any divisibility-free (n+1)-set? {counterexample_found}  "
          f"(False confirms the threshold is sharp)")
    print()


# ---------------------------------------------------------------------------
# 2. Fibonacci divisibility rigidity
# ---------------------------------------------------------------------------

def fib(k: int) -> int:
    """k-th Fibonacci number, F_0 = 0, F_1 = 1, F_2 = 1, ..."""
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a


def fib_divides_value(m: int, n: int) -> bool:
    """Direct value-level test: does F_m divide F_n?"""
    fm = fib(m)
    if fm == 0:
        return fib(n) == 0
    return fib(n) % fm == 0


def fib_divides_decision(m: int, n: int) -> bool:
    """O(1) index-level decision valid for m >= 3 (Theorem fib_dvd_iff)."""
    return n % m == 0


def demo_fibonacci(upper: int = 16) -> None:
    print("=" * 70)
    print(f"2. FIBONACCI DIVISIBILITY RIGIDITY  (indices up to {upper})")
    print("=" * 70)

    # Verify the iff for m >= 3 across a grid, and show it FAILS for m in {1,2}.
    mismatches_ge3: List[Tuple[int, int]] = []
    mismatches_small: List[Tuple[int, int]] = []
    for m in range(1, upper + 1):
        for n in range(1, upper + 1):
            value_level = fib_divides_value(m, n)
            index_level = (n % m == 0)
            if m >= 3:
                if value_level != index_level:
                    mismatches_ge3.append((m, n))
            else:
                if value_level != index_level:
                    mismatches_small.append((m, n))

    print(f"  For m >= 3:  (F_m | F_n) == (m | n) for all tested pairs? "
          f"{len(mismatches_ge3) == 0}")
    print(f"    counterexamples for m >= 3: {mismatches_ge3}  (empty = rigidity holds)")
    print(f"  For m in {{1, 2}}: mismatches (where F_m=1 divides every F_n): "
          f"{len(mismatches_small)} found")
    print(f"    e.g. first few: {mismatches_small[:6]}")
    print("    -> this is exactly why the threshold m >= 3 is necessary.")

    # Show the O(1) decision matches the value test for m >= 3.
    ok = all(
        fib_divides_decision(m, n) == fib_divides_value(m, n)
        for m in range(3, upper + 1)
        for n in range(1, upper + 1)
    )
    print(f"  O(1) index-decision agrees with value-level test (m >= 3)? {ok}")
    print()


# ---------------------------------------------------------------------------
# 3. Garden of Eden / bounded descent
# ---------------------------------------------------------------------------

def is_garden_of_eden(F: Callable[[A], A], domain: Sequence[A], y: A) -> bool:
    """y has no preimage under F (restricted to `domain`)."""
    return all(F(x) != y for x in domain)


def find_gardens_of_eden(F: Callable[[A], A], domain: Sequence[A]) -> List[A]:
    """All Garden-of-Eden states; nonempty iff F is not surjective on domain."""
    image = {F(x) for x in domain}
    return [y for y in domain if y not in image]


def is_surjective(F: Callable[[A], A], domain: Sequence[A]) -> bool:
    return {F(x) for x in domain} == set(domain)


def is_injective(F: Callable[[A], A], domain: Sequence[A]) -> bool:
    return len({F(x) for x in domain}) == len(set(domain))


def descent_fixed_point(F: Callable[[int], int], x: int, card_P: int
                        ) -> Tuple[int, int]:
    """Iterate descending F from x; return (steps, fixed_point), steps <= card_P."""
    cur = x
    for n in range(card_P + 1):
        nxt = F(cur)
        if nxt == cur:
            return (n, cur)
        cur = nxt
    raise RuntimeError("descending map on finite poset must stabilize")


def demo_garden_of_eden(N: int = 16) -> None:
    print("=" * 70)
    print(f"3. GARDEN OF EDEN & BOUNDED DESCENT  (state space {{0,...,{N}}})")
    print("=" * 70)
    domain = list(range(N + 1))

    # (a) Non-surjective map has Garden-of-Eden states.
    F_halve: Callable[[int], int] = lambda x: x // 2  # descending, monotone
    goe = find_gardens_of_eden(F_halve, domain)
    print(f"  F(x) = floor(x/2):  surjective? {is_surjective(F_halve, domain)}")
    print(f"    Garden-of-Eden states (no preimage): {goe}")
    print(f"    exists GoE  <=>  not surjective :  "
          f"{(len(goe) > 0) == (not is_surjective(F_halve, domain))}")

    # (b) Finite Moore-Myhill shadow: surjective <=> injective.
    shift: Callable[[int], int] = lambda x: (x + 1) % (N + 1)  # a bijection
    print(f"  F(x) = (x+1) mod {N+1}:  surjective? {is_surjective(shift, domain)}  "
          f"injective? {is_injective(shift, domain)}")
    print(f"    (on finite spaces these always agree)")

    # (c) Iterates of a descending map form a descending chain + bounded stop.
    print(f"  Descending chain check for F(x)=floor(x/2) from x={N}:")
    orbit: List[int] = [N]
    cur = N
    while F_halve(cur) != cur:
        cur = F_halve(cur)
        orbit.append(cur)
    descending = all(orbit[i + 1] <= orbit[i] for i in range(len(orbit) - 1))
    print(f"    orbit: {orbit}")
    print(f"    non-increasing? {descending}")

    steps, fp = descent_fixed_point(F_halve, N, card_P=len(domain))
    print(f"    reached fixed point {fp} in {steps} steps "
          f"(bound |P| = {len(domain)}).")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    demo_pigeonhole(n=10)
    demo_fibonacci(upper=16)
    demo_garden_of_eden(N=16)
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
