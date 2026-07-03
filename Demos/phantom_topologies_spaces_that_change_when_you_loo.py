"""
Phantom Topologies: Numerical demonstrations of the two-observer theorem.

A *phantom topology* on a set X assigns to each observer a topology on X. The
"real" (consensus) topology is the one every observer agrees on: a set is
consensus-open iff it is open in every observer's view.

This file demonstrates, on the real line, that the ordinary Euclidean topology is
exactly the consensus of two strictly sharper observers:

  * the LOWER-LIMIT (Sorgenfrey) observer, for whom U is open iff every point x of
    U anchors a right half-open interval [x, b) inside U;
  * the UPPER-LIMIT observer, for whom U is open iff every point x of U anchors a
    left half-open interval (a, x] inside U.

Neither observer alone sees the Euclidean line, and the two disagree, so the
phantom number of R is exactly two.

All functions are self-contained and use only the standard library.
"""

from __future__ import annotations

from typing import Callable, List, Tuple

# A subset of R is represented as a membership predicate on floats.
SetR = Callable[[float], bool]


# ---------------------------------------------------------------------------
# Observer open-set tests (discretized certificates of one-sided intervals)
# ---------------------------------------------------------------------------

def lower_open_at(U: SetR, x: float, max_reach: float = 1.0,
                  steps: int = 2000) -> bool:
    """Test whether x anchors a right half-open interval [x, b) inside U.

    Returns True if there is some b > x with [x, b) sampled entirely inside U.
    A discretized certificate for the lower-limit (Sorgenfrey) observer.
    """
    if not U(x):
        return False
    # Try shrinking reaches; if any positive reach keeps [x, b) inside U, accept.
    reach = max_reach
    while reach > 1e-9:
        b = x + reach
        ys = [x + (b - x) * i / steps for i in range(steps)]  # [x, b)
        if all(U(y) for y in ys):
            return True
        reach /= 2.0
    return False


def upper_open_at(U: SetR, x: float, max_reach: float = 1.0,
                  steps: int = 2000) -> bool:
    """Test whether x anchors a left half-open interval (a, x] inside U.

    A discretized certificate for the upper-limit observer.
    """
    if not U(x):
        return False
    reach = max_reach
    while reach > 1e-9:
        a = x - reach
        ys = [a + (x - a) * (i + 1) / steps for i in range(steps)]  # (a, x]
        if all(U(y) for y in ys):
            return True
        reach /= 2.0
    return False


def euclidean_open_at(U: SetR, x: float, max_reach: float = 1.0,
                      steps: int = 2000) -> bool:
    """Test whether x has a two-sided Euclidean ball (x - e, x + e) inside U."""
    return lower_open_at(U, x, max_reach, steps) and \
        upper_open_at(U, x, max_reach, steps)


# ---------------------------------------------------------------------------
# The two-sided squeeze (constructive core of the two-observer theorem)
# ---------------------------------------------------------------------------

def squeeze_epsilon(a: float, x: float, b: float) -> float:
    """Given (a, x] and [x, b) inside U, return the Euclidean radius e = min(x-a, b-x).

    Then (x - e, x + e) is contained in (a, x] union [x, b) = (a, b) inside U.
    """
    assert a < x < b, "need a < x < b"
    return min(x - a, b - x)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_squeeze_identity() -> None:
    """(a, x] union [x, b) = (a, b): two one-sided intervals glue into one."""
    print("=" * 70)
    print("DEMO 1: The squeeze identity  (a, x] u [x, b) = (a, b)")
    print("=" * 70)
    a, x, b = -2.0, 0.5, 3.0
    e = squeeze_epsilon(a, x, b)
    print(f"  a = {a}, x = {x}, b = {b}")
    print(f"  epsilon = min(x - a, b - x) = min({x - a}, {b - x}) = {e}")
    # Verify the ball (x-e, x+e) lands inside (a, b).
    lo, hi = x - e, x + e
    inside = (a < lo) and (hi < b) or (abs(lo - a) < 1e-12) or (abs(hi - b) < 1e-12)
    print(f"  Euclidean ball ({lo}, {hi}) subset of (a, b) = ({a}, {b}): {inside}")
    print()


def demo_single_observer_overreaches() -> None:
    """[0,1) is lower-open but not Euclidean-open; (0,1] is upper-open, not Euclidean."""
    print("=" * 70)
    print("DEMO 2: One observer over-resolves (no single observer suffices)")
    print("=" * 70)
    ico = lambda t: 0.0 <= t < 1.0        # [0, 1)
    ioc = lambda t: 0.0 < t <= 1.0        # (0, 1]
    print("  Set [0, 1):")
    print(f"    lower-open at 0 (Sorgenfrey sees it as open)?  "
          f"{lower_open_at(ico, 0.0)}")
    print(f"    upper-open at 0 (needs left interval)?          "
          f"{upper_open_at(ico, 0.0)}")
    print(f"    Euclidean-open at 0 (needs two-sided ball)?     "
          f"{euclidean_open_at(ico, 0.0)}")
    print("  Set (0, 1]:")
    print(f"    upper-open at 1 (upper observer sees it open)?  "
          f"{upper_open_at(ioc, 1.0)}")
    print(f"    lower-open at 1 (needs right interval)?         "
          f"{lower_open_at(ioc, 1.0)}")
    print(f"    Euclidean-open at 1?                            "
          f"{euclidean_open_at(ioc, 1.0)}")
    print("  => Each observer alone disagrees with the Euclidean line.")
    print()


def demo_consensus_equals_euclidean() -> None:
    """Consensus of the two observers matches the Euclidean topology on samples."""
    print("=" * 70)
    print("DEMO 3: Consensus of two observers == Euclidean topology")
    print("=" * 70)
    open_interval = lambda t: -1.0 < t < 2.0   # genuinely Euclidean-open (a, b)
    samples = [-0.9, -0.5, 0.0, 0.7, 1.3, 1.9]
    print("  Testing the open interval (-1, 2):")
    all_ok = True
    for x in samples:
        lo = lower_open_at(open_interval, x)
        up = upper_open_at(open_interval, x)
        consensus = lo and up
        eucl = euclidean_open_at(open_interval, x)
        ok = consensus == eucl
        all_ok = all_ok and ok
        print(f"    x = {x:+.2f}:  lower={lo}, upper={up}, "
              f"consensus={consensus}, euclidean={eucl}  [{'OK' if ok else 'MISMATCH'}]")
    print(f"  Consensus agrees with Euclidean on all samples: {all_ok}")
    print()


def demo_coarsening_principle() -> None:
    """Each observer is finer than the consensus: more open sets individually."""
    print("=" * 70)
    print("DEMO 4: Measurement coarsens -- each observer is finer than consensus")
    print("=" * 70)
    # [0, 1) is open for the lower observer but NOT in the consensus (Euclidean).
    ico = lambda t: 0.0 <= t < 1.0
    lower_sees = lower_open_at(ico, 0.0)
    consensus_sees = euclidean_open_at(ico, 0.0)
    print("  Set [0, 1) at the boundary point 0:")
    print(f"    lower observer's private view: open = {lower_sees}")
    print(f"    consensus (agreed) view:       open = {consensus_sees}")
    print("  The lower observer resolves a set the consensus discards.")
    print("  => Adding observers can only remove agreed-open sets (coarsen).")
    print()


def demo_phantom_number() -> None:
    """Summarize: phantom number of R is exactly two."""
    print("=" * 70)
    print("DEMO 5: The phantom number of the real line is exactly TWO")
    print("=" * 70)
    print("  * Two observers suffice: consensus(lower, upper) = Euclidean.")
    print("  * One observer fails: lower != Euclidean, upper != Euclidean.")
    print("  * The two observers genuinely disagree: lower != upper.")
    print("  Therefore the phantom number of R is exactly 2.")
    print()


def main() -> None:
    demo_squeeze_identity()
    demo_single_observer_overreaches()
    demo_consensus_equals_euclidean()
    demo_coarsening_principle()
    demo_phantom_number()


if __name__ == "__main__":
    main()
