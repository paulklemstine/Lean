#!/usr/bin/env python3
"""
Algorithms for Computational Complexity of Recipes

Implements the core algorithms from the formal development:
1. Recipe classification (P/NP/Hard)
2. Tropical critical path scheduling
3. Recipe reduction composition
4. Parallel speedup analysis

All algorithms have docstrings, type hints, and complexity analysis.
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Dict, Optional
import math


# ============================================================
# Algorithm 1: Recipe Structure and Classification
# ============================================================

@dataclass
class Recipe:
    """
    A computational recipe with timing and complexity metadata.

    Attributes:
        name: Human-readable name
        cook_time: Time to prepare (must be > 0)
        verify_time: Time to verify result (must be > 0)
        outcomes: Number of distinguishable results (must be > 0)
        steps: Number of atomic operations

    Time complexity of all operations: O(1)
    Space complexity: O(1)
    """
    name: str
    cook_time: int
    verify_time: int
    outcomes: int
    steps: int

    def __post_init__(self):
        assert self.cook_time > 0
        assert self.verify_time > 0
        assert self.outcomes > 0

    @property
    def gap(self) -> int:
        """Complexity gap C - V. Time: O(1)."""
        return self.cook_time - self.verify_time

    @property
    def cv_ratio(self) -> float:
        """Complexity ratio C/V. Time: O(1)."""
        return self.cook_time / self.verify_time

    def classify(self) -> str:
        """
        Classify recipe into P, NP, or HARD.

        Returns:
            'P' if C ≤ V (easy to cook as to verify)
            'HARD' if C ≥ 2V (much harder to cook)
            'NP' if V < C < 2V (moderately harder)

        Time: O(1)
        """
        if self.cook_time <= self.verify_time:
            return "P"
        elif self.cook_time >= 2 * self.verify_time:
            return "HARD"
        else:
            return "NP"


# ============================================================
# Algorithm 2: Recipe Composition
# ============================================================

def sequential_compose(r1: Recipe, r2: Recipe) -> Recipe:
    """
    Sequentially compose two recipes: do r1 then r2.

    Properties (proved in Lean):
    - gap(result) = gap(r1) + gap(r2)
    - If both are NP, result is NP
    - If both are HARD, result is HARD

    Time: O(1)
    Space: O(1)
    """
    return Recipe(
        name=f"({r1.name} >> {r2.name})",
        cook_time=r1.cook_time + r2.cook_time,
        verify_time=r1.verify_time + r2.verify_time,
        outcomes=r1.outcomes * r2.outcomes,
        steps=r1.steps + r2.steps,
    )


def parallel_compose(r1: Recipe, r2: Recipe) -> Recipe:
    """
    Parallel compose two recipes: do r1 and r2 simultaneously.

    Properties (proved in Lean):
    - cook_time(par) ≤ cook_time(seq)
    - 2 * cook_time(par) ≥ cook_time(seq)

    Time: O(1)
    Space: O(1)
    """
    return Recipe(
        name=f"({r1.name} || {r2.name})",
        cook_time=max(r1.cook_time, r2.cook_time),
        verify_time=max(r1.verify_time, r2.verify_time),
        outcomes=r1.outcomes * r2.outcomes,
        steps=r1.steps + r2.steps,
    )


def iterate_sequential(r: Recipe, k: int) -> Recipe:
    """
    Iterate sequential composition k+1 times (i.e., k additional copies).

    Property (proved in Lean):
    - gap(result) = (k+1) * gap(r)
    - cook_time(result) = (k+1) * cook_time(r)

    Time: O(k)
    Space: O(1)
    """
    result = r
    for _ in range(k):
        result = sequential_compose(result, r)
    return result


# ============================================================
# Algorithm 3: Tropical Critical Path Scheduling
# ============================================================

def max_plus(a: int, b: int) -> int:
    """Tropical addition: max(a, b). Time: O(1)."""
    return max(a, b)


def seq_plus(a: int, b: int) -> int:
    """Tropical multiplication: a + b. Time: O(1)."""
    return a + b


@dataclass
class RecipeDAG:
    """
    A directed acyclic graph of recipe steps.

    Each step has a duration, and edges represent dependencies.
    The critical path determines the minimum completion time.

    Attributes:
        n: Number of steps
        durations: Duration of each step
        adj: Adjacency list (i -> j means i must finish before j starts)
    """
    n: int
    durations: List[int]
    adj: Dict[int, List[int]] = field(default_factory=dict)

    def add_dependency(self, i: int, j: int):
        """Add edge i -> j (i must finish before j)."""
        assert i < j, "Dependencies must respect topological order"
        self.adj.setdefault(j, []).append(i)

    def completion_time(self, j: int, memo: Optional[Dict[int, int]] = None) -> int:
        """
        Compute the earliest completion time of step j.

        Uses dynamic programming with memoization.

        Time: O(n + m) where m is the number of edges
        Space: O(n) for memoization
        """
        if memo is None:
            memo = {}
        if j in memo:
            return memo[j]

        pred_max = 0
        for i in self.adj.get(j, []):
            pred_max = max_plus(pred_max, self.completion_time(i, memo))

        result = seq_plus(self.durations[j], pred_max)
        memo[j] = result
        return result

    def makespan(self) -> int:
        """
        Compute the makespan (critical path length).

        Time: O(n + m)
        Space: O(n)
        """
        memo: Dict[int, int] = {}
        return max(self.completion_time(j, memo) for j in range(self.n))


def pipeline_makespan(durations: List[int]) -> int:
    """
    Compute the makespan of a simple pipeline.

    Properties (proved in Lean):
    - makespan ≤ sum(durations)
    - makespan ≥ max(durations) (each individual)

    Time: O(n)
    Space: O(1)
    """
    result = 0
    for d in durations:
        result = max_plus(result, d)
    return result


# ============================================================
# Algorithm 4: Recipe Reduction
# ============================================================

@dataclass
class RecipeReduction:
    """
    A reduction from source to target with bounded overhead.

    Properties (proved in Lean):
    - Reductions compose transitively
    - Identity reduction has zero overhead
    """
    source: Recipe
    target: Recipe
    overhead: int

    def verify(self) -> bool:
        """Check that the reduction bounds hold."""
        return (self.target.cook_time <= self.source.cook_time + self.overhead and
                self.target.verify_time <= self.source.verify_time + self.overhead)


def compose_reductions(f: RecipeReduction, g: RecipeReduction) -> RecipeReduction:
    """
    Compose two reductions transitively.

    Property (proved in Lean):
    - overhead(result) ≤ overhead(f) + overhead(g)

    Time: O(1)
    """
    return RecipeReduction(
        source=f.source,
        target=g.target,
        overhead=f.overhead + g.overhead,
    )


# ============================================================
# Algorithm 5: Batch Classification
# ============================================================

def classify_recipes(recipes: List[Recipe]) -> Dict[str, List[Recipe]]:
    """
    Classify a list of recipes into P, NP, and HARD categories.

    Time: O(n)
    Space: O(n)
    """
    result: Dict[str, List[Recipe]] = {"P": [], "NP": [], "HARD": []}
    for r in recipes:
        result[r.classify()].append(r)
    return result


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Create sample recipes
    recipes = [
        Recipe("Salad", 5, 5, 3, 3),
        Recipe("Pasta", 20, 3, 4, 8),
        Recipe("Soufflé", 45, 5, 6, 12),
        Recipe("Toast", 3, 2, 2, 2),
        Recipe("Sushi", 60, 8, 10, 15),
    ]

    # Classify
    classified = classify_recipes(recipes)
    for cls, rs in classified.items():
        print(f"{cls}: {[r.name for r in rs]}")

    # DAG scheduling example: a 3-course meal
    dag = RecipeDAG(4, [10, 20, 15, 5])
    dag.add_dependency(0, 2)  # appetizer before main
    dag.add_dependency(1, 2)  # sauce before main
    dag.add_dependency(2, 3)  # main before dessert plating
    print(f"\nMeal DAG makespan: {dag.makespan()} minutes")
    print(f"Sequential total: {sum(dag.durations)} minutes")
    print(f"Speedup: {sum(dag.durations) / dag.makespan():.2f}x")
