"""
A Complexity Theory of Recipes: numerical demonstrations.

Every recipe is modelled by two non-negative integers:

    C(R) = cooking time      (resource to produce the dish)
    V(R) = verification time (resource to taste and judge the dish)

Recipes are classified as:

    quick        C == V   (kitchen analogue of P = NP)
    traditional  V <  C   (kitchen analogue of P != NP)
    overhard     C <  V   (verification is harder than production)

and are called 'physical' when V <= C.

This self-contained script demonstrates:
  1. the trichotomy classification and cooking ratio,
  2. the commutative-monoid composition of recipes,
  3. additivity of speedup over physical recipes,
  4. linear scaling under repetition,
  5. the Batch Quickness Theorem.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import List


@dataclass(frozen=True)
class Recipe:
    """A recipe modelled by cooking time C and verification time V."""

    name: str
    cook: int  # C(R)
    verify: int  # V(R)


# --------------------------------------------------------------------------- #
# Classification
# --------------------------------------------------------------------------- #
def is_quick(r: Recipe) -> bool:
    """C(R) == V(R): the kitchen analogue of P = NP."""
    return r.cook == r.verify


def is_traditional(r: Recipe) -> bool:
    """V(R) < C(R): the kitchen analogue of P != NP."""
    return r.verify < r.cook


def is_overhard(r: Recipe) -> bool:
    """C(R) < V(R): verifying is strictly harder than cooking."""
    return r.cook < r.verify


def is_physical(r: Recipe) -> bool:
    """V(R) <= C(R): verification never slower than production."""
    return r.verify <= r.cook


def classify(r: Recipe) -> str:
    """Return the unique class of a recipe (trichotomy)."""
    if is_quick(r):
        return "quick"
    if is_traditional(r):
        return "traditional"
    return "overhard"


def cooking_ratio(r: Recipe) -> float:
    """rho(R) = C(R)/V(R); == 1 quick, > 1 traditional, < 1 overhard."""
    if r.verify == 0:
        return float("inf") if r.cook > 0 else 1.0
    return r.cook / r.verify


def speedup(r: Recipe) -> int:
    """Truncated slack C(R) - V(R) (never negative)."""
    return max(r.cook - r.verify, 0)


# --------------------------------------------------------------------------- #
# Composition (commutative monoid), repetition, batching
# --------------------------------------------------------------------------- #
EMPTY = Recipe("(empty)", 0, 0)


def seq(r: Recipe, s: Recipe) -> Recipe:
    """Sequential composition: cook r, then s. Times add."""
    return Recipe(f"({r.name} then {s.name})", r.cook + s.cook, r.verify + s.verify)


def repeat_recipe(n: int, r: Recipe) -> Recipe:
    """Cook n servings of r in sequence."""
    result = EMPTY
    for _ in range(n):
        result = seq(r, result)
    return Recipe(f"{n}x {r.name}", result.cook, result.verify)


def batch(menu: List[Recipe]) -> Recipe:
    """Compose an entire menu in sequence."""
    result = EMPTY
    for r in menu:
        result = seq(result, r)
    return Recipe("menu", result.cook, result.verify)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
CORPUS: List[Recipe] = [
    Recipe("Green salad", 8, 8),
    Recipe("Cheese plate", 5, 5),
    Recipe("Roast chicken", 90, 3),
    Recipe("Sourdough bread", 1440, 2),
    Recipe("Beef stock", 300, 4),
    Recipe("Souffle", 40, 60),
]


def demo_classification() -> None:
    print("=" * 68)
    print("1. TRICHOTOMY: every recipe is quick, traditional, or overhard")
    print("=" * 68)
    print(f"{'Recipe':<16}{'C':>6}{'V':>6}  {'class':<12}{'rho=C/V':>9}")
    for r in CORPUS:
        print(f"{r.name:<16}{r.cook:>6}{r.verify:>6}  "
              f"{classify(r):<12}{cooking_ratio(r):>9.2f}")
    # verify exactly one class holds for each
    for r in CORPUS:
        flags = [is_quick(r), is_traditional(r), is_overhard(r)]
        assert sum(flags) == 1, "trichotomy violated!"
    print("Checked: exactly one class holds for each recipe.\n")


def demo_monoid() -> None:
    print("=" * 68)
    print("2. COMPOSITION forms a commutative monoid")
    print("=" * 68)
    a, b, c = CORPUS[0], CORPUS[2], CORPUS[4]
    # associativity / commutativity / identity (on the (C,V) data)
    def data(r: Recipe) -> tuple:
        return (r.cook, r.verify)

    assert data(seq(seq(a, b), c)) == data(seq(a, seq(b, c)))
    assert data(seq(a, b)) == data(seq(b, a))
    assert data(seq(EMPTY, a)) == data(a) == data(seq(a, EMPTY))
    print("Checked: associativity, commutativity, and empty-recipe identity.\n")


def demo_speedup_additive() -> None:
    print("=" * 68)
    print("3. SPEEDUP is additive over physical recipes")
    print("=" * 68)
    physical = [r for r in CORPUS if is_physical(r)]
    pairs = [(physical[0], physical[2]), (physical[2], physical[4]),
             (physical[3], physical[2])]
    for r, s in pairs:
        lhs = speedup(seq(r, s))
        rhs = speedup(r) + speedup(s)
        assert lhs == rhs
        print(f"sp({r.name} then {s.name}) = {lhs} = "
              f"{speedup(r)} + {speedup(s)}")
    print("Checked: speedup adds over physical recipes.\n")


def demo_scaling() -> None:
    print("=" * 68)
    print("4. LINEAR SCALING: n servings scale C and V by n, class preserved")
    print("=" * 68)
    r = CORPUS[2]  # Roast chicken (traditional)
    for n in (1, 3, 10):
        rn = repeat_recipe(n, r)
        assert rn.cook == n * r.cook and rn.verify == n * r.verify
        assert classify(rn) == classify(r)
        print(f"{n:>3} servings: C={rn.cook:>6} V={rn.verify:>4}  "
              f"class={classify(rn)}")
    print("Checked: repetition scales linearly and preserves class.\n")


def demo_batch_quickness() -> None:
    print("=" * 68)
    print("5. BATCH QUICKNESS: a physical menu is quick iff every dish is")
    print("=" * 68)
    all_quick = [r for r in CORPUS if is_quick(r)]          # two salads
    with_slow = all_quick + [CORPUS[2]]                     # + roast chicken

    b1 = batch(all_quick)
    b2 = batch(with_slow)
    assert all(is_physical(r) for r in all_quick + with_slow)

    print(f"Menu of only quick dishes : C={b1.cook} V={b1.verify} -> "
          f"{classify(b1)}  (quick: {is_quick(b1)})")
    print(f"Same menu + one slow dish : C={b2.cook} V={b2.verify} -> "
          f"{classify(b2)}  (quick: {is_quick(b2)})")

    assert is_quick(b1) == all(is_quick(r) for r in all_quick)
    assert is_quick(b2) == all(is_quick(r) for r in with_slow)
    print("Checked: the whole menu is quick exactly when each dish is.\n")


def main() -> None:
    demo_classification()
    demo_monoid()
    demo_speedup_additive()
    demo_scaling()
    demo_batch_quickness()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
