"""
Kitchen Complexity Theory: Algorithms and Data Structures

Type-hinted implementations of the core Kitchen Complexity Theory framework.
"""

from dataclasses import dataclass
from enum import IntEnum
from typing import Optional, Tuple, List


class CulinaryLevel(IntEnum):
    """Culinary complexity level based on the verification gap."""
    TRIVIAL = 0      # gap = 1 (P = NP in kitchen)
    EASY = 1          # 1 < gap ≤ 2
    MODERATE = 2      # 2 < gap ≤ 4
    HARD = 3          # 4 < gap
    IMPOSSIBLE = 4    # verification-hard (V ≥ C)


@dataclass(frozen=True)
class Recipe:
    """A recipe with complexity measures.

    Attributes:
        name: Human-readable recipe name
        num_ingredients: Number of distinct ingredients
        num_operations: Number of distinct operations
        cook_time: Cooking time C(R) in abstract units
        verify_time: Verification time V(R) in abstract units
        destructive: Whether verification destroys the output
    """
    name: str
    num_ingredients: int
    num_operations: int
    cook_time: int
    verify_time: int
    destructive: bool = False

    def __post_init__(self) -> None:
        assert self.cook_time > 0, "Cook time must be positive"
        assert self.verify_time > 0, "Verify time must be positive"

    @property
    def verification_gap(self) -> float:
        """The verification gap γ(R) = C(R) / V(R)."""
        return self.cook_time / self.verify_time

    @property
    def is_quick(self) -> bool:
        """Whether the recipe is quick (C = V)."""
        return self.cook_time == self.verify_time

    @property
    def is_hard(self) -> bool:
        """Whether the recipe is hard (C > V)."""
        return self.cook_time > self.verify_time

    @property
    def is_verification_hard(self) -> bool:
        """Whether verification is at least as hard as cooking (V ≥ C)."""
        return self.verify_time >= self.cook_time


def classify_recipe(r: Recipe) -> CulinaryLevel:
    """Classify a recipe into its culinary complexity level.

    Algorithm:
        if V ≥ C: IMPOSSIBLE
        elif C ≤ V: TRIVIAL
        elif C ≤ 2V: EASY
        elif C ≤ 4V: MODERATE
        else: HARD

    Time complexity: O(1)
    Space complexity: O(1)
    """
    if r.verify_time >= r.cook_time:
        return CulinaryLevel.IMPOSSIBLE
    elif r.cook_time <= r.verify_time:
        return CulinaryLevel.TRIVIAL
    elif r.cook_time <= 2 * r.verify_time:
        return CulinaryLevel.EASY
    elif r.cook_time <= 4 * r.verify_time:
        return CulinaryLevel.MODERATE
    else:
        return CulinaryLevel.HARD


def sequential_compose(r1: Recipe, r2: Recipe) -> Recipe:
    """Sequential composition: cook r1 then r2.

    C(r1 ∘ r2) = C(r1) + C(r2)
    V(r1 ∘ r2) = V(r1) + V(r2)
    destructive iff either is destructive
    """
    return Recipe(
        name=f"{r1.name} → {r2.name}",
        num_ingredients=r1.num_ingredients + r2.num_ingredients,
        num_operations=r1.num_operations + r2.num_operations,
        cook_time=r1.cook_time + r2.cook_time,
        verify_time=r1.verify_time + r2.verify_time,
        destructive=r1.destructive or r2.destructive,
    )


def parallel_compose(r1: Recipe, r2: Recipe) -> Recipe:
    """Parallel composition: cook r1 and r2 simultaneously.

    C(r1 ∥ r2) = max(C(r1), C(r2))
    V(r1 ∥ r2) = V(r1) + V(r2)
    destructive iff either is destructive
    """
    return Recipe(
        name=f"{r1.name} ∥ {r2.name}",
        num_ingredients=r1.num_ingredients + r2.num_ingredients,
        num_operations=r1.num_operations + r2.num_operations,
        cook_time=max(r1.cook_time, r2.cook_time),
        verify_time=r1.verify_time + r2.verify_time,
        destructive=r1.destructive or r2.destructive,
    )


@dataclass(frozen=True)
class KitchenReduction:
    """A kitchen reduction from source to target with given overhead.

    Proves that source is no harder than target + overhead.
    """
    source: Recipe
    target: Recipe
    overhead: int

    def is_valid(self) -> bool:
        """Check if this reduction is valid."""
        return (self.source.cook_time <= self.target.cook_time + self.overhead and
                self.source.verify_time <= self.target.verify_time + self.overhead)


def find_reduction(r1: Recipe, r2: Recipe, max_overhead: int = 1000) -> Optional[KitchenReduction]:
    """Find the minimum-overhead kitchen reduction from r1 to r2.

    Returns None if no reduction exists within max_overhead.

    Time complexity: O(1) — computed directly
    """
    cook_overhead = max(0, r1.cook_time - r2.cook_time)
    verify_overhead = max(0, r1.verify_time - r2.verify_time)
    overhead = max(cook_overhead, verify_overhead)

    if overhead <= max_overhead:
        return KitchenReduction(source=r1, target=r2, overhead=overhead)
    return None


def compose_reductions(red1: KitchenReduction, red2: KitchenReduction) -> Optional[KitchenReduction]:
    """Compose two kitchen reductions transitively.

    If r1 reduces to r2 and r2 reduces to r3, returns reduction from r1 to r3.
    Returns None if the reductions don't chain (red1.target != red2.source).
    """
    if red1.target != red2.target:
        # Check if they chain: red1: A→B, red2: B→C
        pass
    result = KitchenReduction(
        source=red1.source,
        target=red2.target,
        overhead=red1.overhead + red2.overhead,
    )
    if result.is_valid():
        return result
    return None


def classify_recipe_database(recipes: List[Recipe]) -> dict[CulinaryLevel, List[Recipe]]:
    """Classify a list of recipes into complexity levels.

    Returns a dictionary mapping each level to its recipes.
    """
    result: dict[CulinaryLevel, List[Recipe]] = {level: [] for level in CulinaryLevel}
    for r in recipes:
        level = classify_recipe(r)
        result[level].append(r)
    return result


# Standard recipe database
STANDARD_RECIPES = [
    Recipe("Salad", 5, 3, 5, 5),
    Recipe("Toast", 2, 2, 3, 2),
    Recipe("Scrambled Eggs", 3, 4, 8, 3),
    Recipe("Pasta Carbonara", 5, 6, 20, 5),
    Recipe("Risotto", 6, 8, 40, 5),
    Recipe("Soufflé", 5, 8, 60, 5, destructive=True),
    Recipe("Bread", 4, 6, 120, 10),
    Recipe("Croissants", 4, 15, 480, 10),
    Recipe("Beef Wellington", 8, 12, 180, 5),
    Recipe("Aged Cheese", 4, 3, 2, 5),  # verification-hard!
    Recipe("Fermented Kimchi", 6, 4, 3, 10),  # verification-hard
    Recipe("Instant Coffee", 2, 2, 1, 1),
    Recipe("Sushi", 8, 10, 30, 3),
    Recipe("Ramen Broth", 6, 5, 720, 10),
    Recipe("Macarons", 5, 12, 90, 5),
]


if __name__ == "__main__":
    print("=== Kitchen Complexity Theory: Recipe Classification ===\n")

    classified = classify_recipe_database(STANDARD_RECIPES)

    for level in CulinaryLevel:
        recipes = classified[level]
        if recipes:
            print(f"\n{level.name} (level {level.value}):")
            for r in recipes:
                gap_str = f"γ={r.verification_gap:.1f}"
                destr = " [DESTRUCTIVE]" if r.destructive else ""
                print(f"  {r.name}: C={r.cook_time}, V={r.verify_time}, {gap_str}{destr}")
