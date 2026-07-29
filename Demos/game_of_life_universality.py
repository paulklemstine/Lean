#!/usr/bin/env python3
"""Numerical demonstrations of finite causal cones in Conway's Game of Life.

The program uses sparse sets of integer-coordinate live cells.  It demonstrates:
1. stability of the all-dead configuration;
2. exact local determinacy under changes outside a dependency cone;
3. the cardinality comparison |D_t(p)| <= 9**t;
4. agreement between full sparse evolution and memoized single-cell evaluation.

No third-party packages are required.
"""

from __future__ import annotations

from functools import lru_cache
from typing import Callable, Dict, FrozenSet, Iterable, List, Set, Tuple

Cell = Tuple[int, int]
LiveSet = Set[Cell]

NEIGHBOR_OFFSETS: Tuple[Cell, ...] = tuple(
    (dx, dy)
    for dx in (-1, 0, 1)
    for dy in (-1, 0, 1)
    if (dx, dy) != (0, 0)
)
CLOSED_OFFSETS: Tuple[Cell, ...] = ((0, 0),) + NEIGHBOR_OFFSETS


def translate(p: Cell, offset: Cell) -> Cell:
    """Add an integer offset to a cell."""
    return (p[0] + offset[0], p[1] + offset[1])


def neighbors(p: Cell) -> Tuple[Cell, ...]:
    """Return the eight Moore neighbors of p."""
    return tuple(translate(p, offset) for offset in NEIGHBOR_OFFSETS)


def closed_neighbors(p: Cell) -> Tuple[Cell, ...]:
    """Return p together with its eight Moore neighbors."""
    return tuple(translate(p, offset) for offset in CLOSED_OFFSETS)


def life_rule(currently_alive: bool, live_neighbor_count: int) -> bool:
    """Apply Conway's B3/S23 local transition rule."""
    return live_neighbor_count == 3 or (
        currently_alive and live_neighbor_count == 2
    )


def step(live: Set[Cell]) -> Set[Cell]:
    """Advance a finite-support Life configuration by one generation."""
    candidates: Set[Cell] = set(live)
    for p in live:
        candidates.update(neighbors(p))

    next_live: Set[Cell] = set()
    for p in candidates:
        count = sum(q in live for q in neighbors(p))
        if life_rule(p in live, count):
            next_live.add(p)
    return next_live


def evolve(live: Iterable[Cell], generations: int) -> Set[Cell]:
    """Evolve a finite-support configuration for a nonnegative number of steps."""
    if generations < 0:
        raise ValueError("generations must be nonnegative")
    state = set(live)
    for _ in range(generations):
        state = step(state)
    return state


def dependency_cone(target: Cell, depth: int) -> Set[Cell]:
    """Construct the recursively expanded dependency cone D_depth(target)."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    cone: Set[Cell] = {target}
    for _ in range(depth):
        cone = {q for p in cone for q in closed_neighbors(p)}
    return cone


def memoized_cell_value(
    initial: Callable[[Cell], bool], target: Cell, generations: int
) -> Tuple[bool, int]:
    """Evaluate one target cell recursively, returning value and cache size."""
    if generations < 0:
        raise ValueError("generations must be nonnegative")

    @lru_cache(maxsize=None)
    def value(p: Cell, t: int) -> bool:
        if t == 0:
            return initial(p)
        previous_center = value(p, t - 1)
        count = sum(value(q, t - 1) for q in neighbors(p))
        return life_rule(previous_center, count)

    answer = value(target, generations)
    return answer, value.cache_info().currsize


def render(live: Set[Cell], xmin: int, xmax: int, ymin: int, ymax: int) -> str:
    """Render a rectangular region as Unicode text."""
    rows: List[str] = []
    for y in range(ymax, ymin - 1, -1):
        rows.append("".join("█" if (x, y) in live else "·" for x in range(xmin, xmax + 1)))
    return "\n".join(rows)


def demonstrate_empty_stability() -> None:
    """Show that the all-dead configuration remains all dead."""
    print("\nDEMO 1 — Empty-universe stability")
    state = evolve(set(), 12)
    print(f"Live cells after 12 generations: {len(state)}")
    assert state == set()


def demonstrate_cone_sizes(max_depth: int = 6) -> None:
    """Compare actual recursive cone sizes with the certified 9^t bound."""
    print("\nDEMO 2 — Dependency-cone cardinalities")
    print(" t | actual | (2t+1)^2 | 9^t")
    print("---+--------+-----------+------")
    for t in range(max_depth + 1):
        actual = len(dependency_cone((0, 0), t))
        square_count = (2 * t + 1) ** 2
        bound = 9**t
        print(f"{t:2d} | {actual:6d} | {square_count:9d} | {bound:6d}")
        assert actual <= bound
        # This equality is shown numerically here; the packaged theorem only needs the bound.
        assert actual == square_count


def demonstrate_outside_independence() -> None:
    """Change cells outside a target cone and show the target is unchanged."""
    print("\nDEMO 3 — Independence from changes outside the cone")
    target = (0, 0)
    generations = 4
    cone = dependency_cone(target, generations)

    glider: Set[Cell] = {(0, 1), (1, 0), (-1, -1), (0, -1), (1, -1)}
    remote_changes: Set[Cell] = {
        (20, 20), (21, 20), (22, 20),
        (-30, 7), (-30, 8), (-30, 9),
    }
    assert remote_changes.isdisjoint(cone)

    state_a = evolve(glider, generations)
    state_b = evolve(glider | remote_changes, generations)
    value_a = target in state_a
    value_b = target in state_b
    print(f"Cone size: {len(cone)}")
    print(f"Target alive without remote changes: {value_a}")
    print(f"Target alive with remote changes:    {value_b}")
    assert value_a == value_b


def demonstrate_recursive_evaluator() -> None:
    """Compare sparse global evolution with memoized local evaluation."""
    print("\nDEMO 4 — Memoized local evaluator")
    initial_live: Set[Cell] = {
        (-1, 0), (0, 0), (1, 0),  # blinker
        (8, 8), (9, 8), (10, 8), # distant second blinker
    }
    target = (0, 1)
    generations = 7

    full_value = target in evolve(initial_live, generations)
    local_value, cached_subproblems = memoized_cell_value(
        lambda p: p in initial_live, target, generations
    )
    print(f"Full sparse evolution says target alive: {full_value}")
    print(f"Local recursive evaluator agrees:       {local_value}")
    print(f"Memoized spacetime subproblems:         {cached_subproblems}")
    print(f"Coarse leaf bound 9^t:                  {9**generations}")
    assert full_value == local_value


def demonstrate_blinker() -> None:
    """Display a familiar local pattern for two generations."""
    print("\nDEMO 5 — A local two-cycle")
    state: Set[Cell] = {(-1, 0), (0, 0), (1, 0)}
    for t in range(3):
        print(f"\nGeneration {t}")
        print(render(state, -2, 2, -2, 2))
        state = step(state)


def main() -> None:
    """Run all demonstrations and their internal consistency checks."""
    demonstrate_empty_stability()
    demonstrate_cone_sizes()
    demonstrate_outside_independence()
    demonstrate_recursive_evaluator()
    demonstrate_blinker()
    print("\nAll numerical demonstrations completed successfully.")


if __name__ == "__main__":
    main()
