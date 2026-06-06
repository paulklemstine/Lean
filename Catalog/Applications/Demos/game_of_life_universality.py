"""
Demo: Conway's Game of Life Simulation and Light Cone Visualization

Demonstrates the key results from our formalization:
1. GoL step function (B3/S23 rule)
2. Light cone propagation (speed of light = 1 in Chebyshev metric)
3. Perturbation bound: single-cell changes propagate at bounded speed
"""

from typing import Set, Tuple

# Type aliases
Cell = bool  # True = alive, False = dead
Config = Set[Tuple[int, int]]  # Set of alive cell positions


def gol_neighbors(x: int, y: int) -> list[tuple[int, int]]:
    """Return the 8 Moore neighbors of (x, y)."""
    return [(x+dx, y+dy) for dx in [-1, 0, 1] for dy in [-1, 0, 1]
            if (dx, dy) != (0, 0)]


def gol_step(alive: Config) -> Config:
    """One step of Conway's Game of Life (B3/S23 rule)."""
    # Count neighbors for all cells that could possibly change
    neighbor_count: dict[tuple[int, int], int] = {}
    for (x, y) in alive:
        for (nx, ny) in gol_neighbors(x, y):
            neighbor_count[(nx, ny)] = neighbor_count.get((nx, ny), 0) + 1

    new_alive: Config = set()
    # Check all cells with at least one alive neighbor
    for pos, count in neighbor_count.items():
        if pos in alive:
            if count in (2, 3):  # Survival
                new_alive.add(pos)
        else:
            if count == 3:  # Birth
                new_alive.add(pos)
    return new_alive


def gol_iter(alive: Config, steps: int) -> Config:
    """Iterate GoL for the given number of steps."""
    for _ in range(steps):
        alive = gol_step(alive)
    return alive


def chebyshev_dist(p: tuple[int, int], q: tuple[int, int]) -> int:
    """Chebyshev (L∞) distance between two points."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def light_cone(center: tuple[int, int], radius: int) -> set[tuple[int, int]]:
    """All positions within Chebyshev distance radius of center."""
    cx, cy = center
    return {(cx + dx, cy + dy)
            for dx in range(-radius, radius + 1)
            for dy in range(-radius, radius + 1)}


def demo_light_cone():
    """Demonstrate the light cone theorem: changes propagate at speed ≤ 1."""
    print("=" * 60)
    print("DEMO: Light Cone Theorem (Speed of Light = 1)")
    print("=" * 60)

    # Create two configs that differ at exactly one cell
    base_config: Config = {(0, 1), (1, 0), (1, 1), (1, 2), (2, 1)}  # Plus pattern
    perturbed_config: Config = base_config | {(5, 5)}  # Add one cell far away

    perturbation_point = (5, 5)
    print(f"\nBase config: {sorted(base_config)}")
    print(f"Perturbation at: {perturbation_point}")

    for t in range(5):
        base_t = gol_iter(base_config, t)
        pert_t = gol_iter(perturbed_config, t)

        # Find cells that differ
        diff = base_t.symmetric_difference(pert_t)

        # Check that all differences are within the light cone
        max_dist = max((chebyshev_dist(perturbation_point, p) for p in diff), default=0)

        print(f"\nt={t}: |base|={len(base_t)}, |pert|={len(pert_t)}, "
              f"|diff|={len(diff)}, max_dist_from_perturbation={max_dist}")
        assert max_dist <= t, f"Light cone violation! max_dist={max_dist} > t={t}"
        print(f"  ✓ All differences within light cone radius {t}")


def demo_glider():
    """Demonstrate a glider: a pattern that translates itself."""
    print("\n" + "=" * 60)
    print("DEMO: Glider (Moving Pattern)")
    print("=" * 60)

    # Standard glider
    glider: Config = {(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)}

    print("\nGlider evolution (period 4, translates by (1,1)):")
    for gen in range(5):
        state = gol_iter(glider, gen)
        min_x = min(x for x, y in state)
        min_y = min(y for x, y in state)
        shifted = {(x - min_x, y - min_y) for x, y in state}
        print(f"  Gen {gen}: {sorted(state)} (normalized: {sorted(shifted)})")


def demo_support_growth():
    """Demonstrate finite support growth bound."""
    print("\n" + "=" * 60)
    print("DEMO: Support Growth Bound")
    print("=" * 60)

    # R-pentomino: famous long-lived pattern
    rpent: Config = {(0, 1), (0, 2), (1, 0), (1, 1), (2, 1)}

    print("\nR-pentomino evolution (support size over time):")
    state = rpent
    for t in range(20):
        if t % 5 == 0:
            if state:
                min_x = min(x for x, y in state)
                max_x = max(x for x, y in state)
                min_y = min(y for x, y in state)
                max_y = max(y for x, y in state)
                diameter = max(max_x - min_x, max_y - min_y)
            else:
                diameter = 0
            print(f"  t={t:3d}: |support|={len(state):4d}, diameter={diameter}")
        state = gol_step(state)


def demo_translation_equivariance():
    """Demonstrate translation equivariance of GoL."""
    print("\n" + "=" * 60)
    print("DEMO: Translation Equivariance")
    print("=" * 60)

    config: Config = {(0, 0), (0, 1), (1, 0), (1, 1)}  # Block
    v = (3, -2)  # Translation vector

    # Translate then step
    translated = {(x + v[0], y + v[1]) for x, y in config}
    stepped_then = gol_step(translated)

    # Step then translate
    stepped = gol_step(config)
    then_translated = {(x + v[0], y + v[1]) for x, y in stepped}

    print(f"\nConfig: {sorted(config)}")
    print(f"Translation vector: {v}")
    print(f"Translate then step: {sorted(stepped_then)}")
    print(f"Step then translate: {sorted(then_translated)}")
    assert stepped_then == then_translated, "Translation equivariance violated!"
    print("✓ Translation equivariance confirmed!")


if __name__ == "__main__":
    demo_light_cone()
    demo_glider()
    demo_support_growth()
    demo_translation_equivariance()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
