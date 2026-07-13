"""
The Algebra of Surprise: numerical demonstrations.

A *setup* is a finite, nonempty configuration of resolutions along a single
interpretive axis (the real line). Its *surprise* (humor) is the range

    humor(S) = max(S) - min(S),

the gap between its most divergent and most conservative readings. This module
demonstrates the algebra of surprise: the combination law, inflation under
juxtaposition, deflation under restriction, conditional subadditivity under a
shared pivot, and functoriality (monotonicity) under refinement.

Run:  python demo.py
"""

from __future__ import annotations

from typing import Iterable, Optional, Sequence


# --------------------------------------------------------------------------- #
# Core invariant
# --------------------------------------------------------------------------- #
def humor(setup: Iterable[float]) -> float:
    """Surprise of a setup: max - min over its resolutions.

    Raises ValueError on an empty setup (a setup must be nonempty).
    """
    values = list(setup)
    if not values:
        raise ValueError("a setup must be nonempty")
    return max(values) - min(values)


# --------------------------------------------------------------------------- #
# Combination operations
# --------------------------------------------------------------------------- #
def juxtapose(s: Iterable[float], t: Iterable[float]) -> set[float]:
    """Juxtaposition of two setups: the union of their resolutions."""
    return set(s) | set(t)


def restrict(s: Iterable[float], t: Iterable[float]) -> set[float]:
    """Restriction of two setups: the intersection of their resolutions."""
    return set(s) & set(t)


def humor_union_via_extremes(s: Sequence[float], t: Sequence[float]) -> float:
    """Combined surprise computed directly from the four extremal resolutions
    (Combination Law), without forming the union explicitly."""
    return max(max(s), max(t)) - min(min(s), min(t))


def shared_pivot(s: Iterable[float], t: Iterable[float]) -> Optional[float]:
    """Return some common resolution of s and t, or None if they are disjoint."""
    common = set(s) & set(t)
    return next(iter(common)) if common else None


def additive_defect(s: Sequence[float], t: Sequence[float]) -> float:
    """humor(S ∪ T) - humor(S) - humor(T).

    Nonpositive whenever S and T share a pivot (subadditivity); can be strictly
    positive when they are disjoint.
    """
    return humor(juxtapose(s, t)) - humor(s) - humor(t)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_combination_law() -> None:
    print("== Combination law: surprise of a union is set by four extremes ==")
    s = [1.0, 3.0, 4.0]
    t = [2.0, 8.0]
    direct = humor(juxtapose(s, t))
    via = humor_union_via_extremes(s, t)
    print(f"  S = {s},  T = {t}")
    print(f"  humor(S ∪ T) directly      = {direct}")
    print(f"  humor via four extremes    = {via}")
    assert abs(direct - via) < 1e-12
    print("  agree ✓\n")


def demo_inflation() -> None:
    print("== Juxtaposition is inflationary: combining never decreases surprise ==")
    s = [0.0, 2.0]
    t = [-5.0, 1.0, 7.0]
    hu = humor(juxtapose(s, t))
    print(f"  humor(S) = {humor(s)},  humor(T) = {humor(t)},  humor(S ∪ T) = {hu}")
    assert humor(s) <= hu and humor(t) <= hu
    print("  humor(S) ≤ humor(S ∪ T) and humor(T) ≤ humor(S ∪ T) ✓\n")


def demo_restriction() -> None:
    print("== Restriction is deflationary: intersecting never increases surprise ==")
    s = [0.0, 1.0, 2.0, 9.0]
    t = [1.0, 2.0, 3.0]
    inter = restrict(s, t)
    print(f"  S = {s},  T = {t},  S ∩ T = {sorted(inter)}")
    print(f"  humor(S ∩ T) = {humor(inter)},  humor(S) = {humor(s)}")
    assert humor(inter) <= humor(s)
    print("  humor(S ∩ T) ≤ humor(S) ✓\n")


def demo_subadditivity() -> None:
    print("== Conditional subadditivity: holds with a shared pivot ==")
    s = [1.0, 5.0]         # humor 4
    t = [5.0, 9.0]         # humor 4, shares pivot c = 5
    pivot = shared_pivot(s, t)
    print(f"  S = {s},  T = {t},  shared pivot c = {pivot}")
    print(f"  humor(S ∪ T) = {humor(juxtapose(s, t))}  vs  "
          f"humor(S) + humor(T) = {humor(s) + humor(t)}")
    assert humor(juxtapose(s, t)) <= humor(s) + humor(t)
    print("  subadditive ✓\n")

    print("== ... and fails without one (genuinely LAX, not strong) ==")
    a = [0.0]              # humor 0
    b = [100.0]            # humor 0, no shared pivot
    print(f"  A = {a},  B = {b},  shared pivot = {shared_pivot(a, b)}")
    print(f"  humor(A ∪ B) = {humor(juxtapose(a, b))}  >  "
          f"humor(A) + humor(B) = {humor(a) + humor(b)}")
    print(f"  additive defect = {additive_defect(a, b)} (> 0)\n")


def demo_functoriality() -> None:
    print("== Functoriality: refinement (⊆) is sent to inequality (≤) ==")
    s = [2.0, 4.0]
    t = [0.0, 2.0, 4.0, 10.0]   # S ⊆ T
    assert set(s) <= set(t)
    print(f"  S = {s} ⊆ T = {t}")
    print(f"  humor(S) = {humor(s)} ≤ humor(T) = {humor(t)}")
    assert humor(s) <= humor(t)
    print("  monotone under refinement ✓\n")


def main() -> None:
    demo_combination_law()
    demo_inflation()
    demo_restriction()
    demo_subadditivity()
    demo_functoriality()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
