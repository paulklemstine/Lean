"""
Numerical demonstrations for
    "Reliable Intuition as a Non-Computable Resource:
     Counting and Coding Barriers to a Ramanujan Oracle"

An oracle is a Boolean verdict map on encoded statements.  On a finite block of
N statements it restricts to a string in {0,1}^N.  This file demonstrates, with
fully self-contained code, the three pillars of the development:

  1. The diagonal (Cantor) construction: from any list of oracles we build one
     that is absent from the list.
  2. The Hamming-ball size formula: a radius-d ball contains exactly
     sum_{k<=d} C(N,k) points, independent of its center.
  3. The accuracy barrier: a family F of oracles with
     |F| * sum_{k<=d} C(N,k) < 2^N cannot cover every truth pattern, so some
     pattern is mispredicted by *every* oracle in F with more than d errors.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations, product
from math import comb, ceil, log2
from typing import Callable, List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. Oracles and the diagonal construction
# ---------------------------------------------------------------------------

Oracle = Callable[[int], bool]


def diagonal(enum: Callable[[int], Oracle]) -> Oracle:
    """The diagonal oracle of an enumeration `enum` of oracles.

    D(n) = not enum(n)(n).  By construction D differs from enum(n) at input n,
    hence D is not equal to any listed oracle.
    """
    return lambda n: not enum(n)(n)


def demo_diagonal(num_checks: int = 8) -> None:
    """Exhibit an oracle absent from a sample enumeration."""
    # A concrete enumeration: enum(k) answers `bit k of n is 1`.
    def enum(k: int) -> Oracle:
        return lambda n: bool((n >> k) & 1)

    d = diagonal(enum)
    print("=== 1. Diagonal construction (Cantor) ===")
    for k in range(num_checks):
        # D disagrees with enum(k) precisely at input k.
        disagree = d(k) != enum(k)(k)
        print(f"  input {k}: D(k)={int(d(k))}, enum(k)(k)={int(enum(k)(k))}, "
              f"disagree={disagree}")
    print("  => D differs from every listed oracle; not in the enumeration.\n")


# ---------------------------------------------------------------------------
# 2. Hamming distance and ball-size formula
# ---------------------------------------------------------------------------

def hamming(a: Tuple[int, ...], b: Tuple[int, ...]) -> int:
    """Number of coordinates where two equal-length bit tuples differ."""
    return sum(1 for x, y in zip(a, b) if x != y)


def ball_size_formula(N: int, d: int) -> int:
    """Closed form: |B_d(r)| = sum_{k=0}^{d} C(N,k)."""
    return sum(comb(N, k) for k in range(d + 1))


def ball_size_bruteforce(N: int, d: int, center: Tuple[int, ...]) -> int:
    """Direct count of length-N strings within Hamming distance d of `center`."""
    return sum(1 for t in product((0, 1), repeat=N) if hamming(center, t) <= d)


def demo_ball_size(N: int = 6) -> None:
    """Verify the ball-size formula for every center and radius."""
    print("=== 2. Hamming ball-size formula ===")
    all_ok = True
    for d in range(N + 1):
        formula = ball_size_formula(N, d)
        # Check independence of center on a few representative centers.
        for center in [tuple([0] * N), tuple([1] * N), tuple((i % 2) for i in range(N))]:
            brute = ball_size_bruteforce(N, d, center)
            ok = brute == formula
            all_ok &= ok
        print(f"  N={N}, d={d}: sum_C(N,k)={formula}  (brute-force matches: {ok})")
    print(f"  cube size 2^N = {2 ** N}; all centers agree: {all_ok}\n")


# ---------------------------------------------------------------------------
# 3. The accuracy barrier
# ---------------------------------------------------------------------------

def covering_threshold(N: int, d: int) -> float:
    """2^N / sum_{k<=d} C(N,k): a family below this size cannot cover the cube."""
    return (2 ** N) / ball_size_formula(N, d)


def find_uncovered_pattern(
    N: int, d: int, family: List[Tuple[int, ...]]
) -> Optional[Tuple[int, ...]]:
    """Return a truth pattern t with hamming(r,t) > d for all r in `family`,
    or None if the family happens to cover the whole cube."""
    for t in product((0, 1), repeat=N):
        if all(hamming(r, t) > d for r in family):
            return t
    return None


def demo_accuracy_barrier(N: int = 6, d: int = 1) -> None:
    """Show that a family below the covering threshold is defeated."""
    print("=== 3. Accuracy barrier ===")
    thr = covering_threshold(N, d)
    max_family = int(thr)  # any family this small must be defeated
    print(f"  N={N}, d={d}: ball size={ball_size_formula(N, d)}, "
          f"covering threshold 2^N/ballsize = {thr:.3f}")

    # Build a family strictly below threshold, e.g. the first `max_family` strings.
    all_strings = list(product((0, 1), repeat=N))
    family = all_strings[:max_family]
    product_val = len(family) * ball_size_formula(N, d)
    print(f"  |F|={len(family)}, |F|*ballsize={product_val} < 2^N={2 ** N}: "
          f"{product_val < 2 ** N}")

    witness = find_uncovered_pattern(N, d, family)
    print(f"  uncovered truth pattern: {witness}")
    if witness is not None:
        errs = [hamming(r, witness) for r in family]
        print(f"  min errors of any oracle in F on this pattern: {min(errs)} > d={d}")
    print("  => every oracle in F mispredicts this pattern with more than d errors.\n")


# ---------------------------------------------------------------------------
# 4. The 95% barrier: how the threshold explodes with the block size
# ---------------------------------------------------------------------------

def demo_95_percent(accuracy: float = 0.95) -> None:
    """Tabulate the exponential blow-up of the covering threshold at 95%."""
    print(f"=== 4. The {int(accuracy * 100)}% barrier: threshold blow-up ===")
    print(f"  {'N':>5} {'d=N-m':>7} {'ball size':>16} {'threshold 2^N/ball':>22}")
    for N in (20, 50, 100, 200, 400):
        m = ceil(accuracy * N)
        d = N - m
        ball = ball_size_formula(N, d)
        thr = (2 ** N) / ball
        print(f"  {N:>5} {d:>7} {ball:>16} {thr:>22.3e}")
    # Entropy estimate of the exponential rate.
    p = 1 - accuracy
    H = -p * log2(p) - (1 - p) * log2(1 - p)
    print(f"  binary entropy H({p:.2f}) = {H:.4f}; "
          f"threshold grows like 2^((1-H)N) = 2^({1 - H:.3f} N)\n")


# ---------------------------------------------------------------------------

def main() -> None:
    demo_diagonal()
    demo_ball_size(N=6)
    demo_accuracy_barrier(N=6, d=1)
    demo_95_percent(0.95)


if __name__ == "__main__":
    main()
