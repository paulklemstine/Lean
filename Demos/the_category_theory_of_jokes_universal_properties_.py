"""
The Metric Geometry of Surprise -- Numerical Demonstrations
===========================================================

A "setup" is a finite nonempty collection of real-valued *resolutions* laid out
along a single interpretive axis. The most conservative reading is the minimum
(the "expected resolution", playing the role of a limit); the most divergent
reading is the maximum (the "subverting resolution", playing the role of a
colimit). The *surprise* (or humor) of a setup is the gap between these poles:

        H(S) = max(S) - min(S).

This script demonstrates the main theorems:
  * nonnegativity of surprise,
  * the vanishing characterization (surprise = 0 iff all readings coincide),
  * monotonicity under enrichment,
  * the diameter identity (surprise = greatest pairwise distance),
  * the universal (extremal) properties of the two poles,
  * 2-Lipschitz stability under reinterpretation.

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Iterable, Sequence


# --------------------------------------------------------------------------- #
#  Core invariant                                                             #
# --------------------------------------------------------------------------- #
def humor(setup: Sequence[float]) -> float:
    """Surprise of a setup: the range max(S) - min(S).

    Runs in O(n) time and O(1) extra space over the n readings.
    """
    if not setup:
        raise ValueError("a setup must contain at least one resolution")
    return max(setup) - min(setup)


def expected_resolution(setup: Sequence[float]) -> float:
    """The most conservative reading (the 'limit' of the setup)."""
    return min(setup)


def subverting_resolution(setup: Sequence[float]) -> float:
    """The most divergent reading (the 'colimit' of the setup)."""
    return max(setup)


def diameter(setup: Sequence[float]) -> float:
    """Greatest pairwise distance between readings, computed directly in O(n^2).

    By the diameter identity this must equal humor(setup).
    """
    pts = list(setup)
    if len(pts) == 1:
        return 0.0
    return max(abs(x - y) for x, y in combinations(pts, 2))


def humor_after_reinterpretation(
    setup: Sequence[float], f: Callable[[float], float]
) -> float:
    """Surprise of the reinterpreted setup f(S)."""
    return humor([f(x) for x in setup])


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def demo_basic_properties() -> None:
    print("=" * 68)
    print("1. Basic properties of surprise")
    print("=" * 68)
    examples = {
        "pure pun (single reading)": [3.0],
        "pun (all readings coincide)": [2.0, 2.0, 2.0],
        "mild observational joke": [0.0, 0.3, 1.0],
        "well-built narrative joke": [0.0, 1.5, 4.0],
        "absurdist leap": [0.0, 0.2, 12.0],
    }
    for label, S in examples.items():
        H = humor(S)
        print(f"  {label:32s}  expected={expected_resolution(S):5.1f} "
              f"subverting={subverting_resolution(S):5.1f}  H={H:5.2f}")
        assert H >= 0.0, "surprise must be nonnegative"
    print("  [checked] surprise is always >= 0\n")


def demo_vanishing() -> None:
    print("=" * 68)
    print("2. Vanishing characterization: H(S)=0  iff  all readings coincide")
    print("=" * 68)
    cases = [[5.0], [7.0, 7.0, 7.0], [1.0, 1.0, 2.0], [0.0, 3.0]]
    for S in cases:
        all_equal = all(x == S[0] for x in S)
        H = humor(S)
        print(f"  S={str(S):20s}  H={H:5.2f}  all-equal={all_equal}")
        assert (H == 0.0) == all_equal
    print("  [checked] H(S)=0 exactly when there is nothing to subvert\n")


def demo_monotonicity() -> None:
    print("=" * 68)
    print("3. Monotonicity: enriching a setup never decreases surprise")
    print("=" * 68)
    S = [0.0, 1.0, 2.0]
    T = S + [5.0]          # enrich with a wilder reading
    U = T + [-3.0]         # enrich again
    print(f"  S={S}   H(S)={humor(S):.2f}")
    print(f"  T=S+[5.0]        H(T)={humor(T):.2f}")
    print(f"  U=T+[-3.0]       H(U)={humor(U):.2f}")
    assert humor(S) <= humor(T) <= humor(U)
    print("  [checked] H(S) <= H(T) <= H(U)\n")


def demo_diameter_identity() -> None:
    print("=" * 68)
    print("4. Diameter identity: surprise = greatest pairwise distance")
    print("=" * 68)
    import random
    random.seed(1)
    for _ in range(5):
        n = random.randint(1, 8)
        S = [round(random.uniform(-10, 10), 2) for _ in range(n)]
        H, D = humor(S), diameter(S)
        print(f"  n={n:2d}  H(S)={H:7.2f}  diameter={D:7.2f}  match={abs(H-D) < 1e-9}")
        assert abs(H - D) < 1e-9
    print("  [checked] O(n) range equals O(n^2) diameter (coordinate-free)\n")


def demo_universal_properties() -> None:
    print("=" * 68)
    print("5. Universal properties of the poles (least / greatest element)")
    print("=" * 68)
    S = [3.0, -1.0, 4.0, 1.0, 5.0, -2.0]
    lo, hi = expected_resolution(S), subverting_resolution(S)
    assert lo in S and all(lo <= x for x in S)   # least element
    assert hi in S and all(x <= hi for x in S)   # greatest element
    print(f"  S={S}")
    print(f"  expected (limit)   = {lo}  is <= every reading and lies in S")
    print(f"  subverting(colimit)= {hi}  is >= every reading and lies in S")
    print("  [checked] the two poles are the least/greatest elements\n")


def demo_stability() -> None:
    print("=" * 68)
    print("6. Stability: |H(f(S)) - H(S)| <= 2*eps  when |f(x)-x| <= eps")
    print("=" * 68)
    import random
    random.seed(2)
    S = [0.0, 1.0, 2.5, 4.0, 6.0]
    eps = 0.5

    def f(x: float) -> float:
        # a reinterpretation nudging each reading by at most eps
        return x + random.uniform(-eps, eps)

    H0 = humor(S)
    H1 = humor_after_reinterpretation(S, f)
    print(f"  H(S)      = {H0:.4f}")
    print(f"  H(f(S))   = {H1:.4f}")
    print(f"  |diff|    = {abs(H1 - H0):.4f}   bound 2*eps = {2*eps:.4f}")
    assert abs(H1 - H0) <= 2 * eps + 1e-9
    print("  [checked] surprise is 2-Lipschitz under bounded reinterpretation")

    # sharpness: push max up by eps and min down by eps
    def f_extreme(x: float) -> float:
        if x == max(S):
            return x + eps
        if x == min(S):
            return x - eps
        return x

    H2 = humor_after_reinterpretation(S, f_extreme)
    print(f"  worst-case reinterpretation: |diff|={abs(H2-H0):.4f} = 2*eps "
          f"(bound is sharp)\n")


def main() -> None:
    demo_basic_properties()
    demo_vanishing()
    demo_monotonicity()
    demo_diameter_identity()
    demo_universal_properties()
    demo_stability()
    print("All demonstrations completed and all assertions passed.")


if __name__ == "__main__":
    main()
