#!/usr/bin/env python3
"""Numerical demonstrations of gauge-invariant periodic-grid obstructions.

The script uses exact integer arithmetic and no third-party dependencies. It
computes curvature and torus periods, applies gauge shifts, reconstructs a
height when possible, and contrasts periodic holonomy with the filtration
2^k Z.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Sequence

Grid = list[list[int]]


@dataclass(frozen=True)
class Obstruction:
    """Curvature table and the two fundamental periods."""

    curvature: Grid
    period_x: int
    period_y: int

    @property
    def vanishes(self) -> bool:
        return (
            self.period_x == 0
            and self.period_y == 0
            and all(value == 0 for row in self.curvature for value in row)
        )


def validate_pair(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]]) -> tuple[int, int]:
    """Validate two nonempty rectangular grids and return (m, n).

    Storage is row-major: grid[j][i] is the value at vertex (i, j).
    """
    if not a or not a[0]:
        raise ValueError("grids must be nonempty")
    n, m = len(a), len(a[0])
    if len(b) != n or any(len(row) != m for row in a) or any(len(row) != m for row in b):
        raise ValueError("a and b must have the same nonempty rectangular shape")
    return m, n


def obstruction(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]]) -> Obstruction:
    """Compute tile curvature and horizontal/vertical torus periods exactly."""
    m, n = validate_pair(a, b)
    curvature = [
        [
            a[j][i]
            + b[j][(i + 1) % m]
            - a[(j + 1) % n][i]
            - b[j][i]
            for i in range(m)
        ]
        for j in range(n)
    ]
    return Obstruction(
        curvature=curvature,
        period_x=sum(a[0][i] for i in range(m)),
        period_y=sum(b[j][0] for j in range(n)),
    )


def gradient(g: Sequence[Sequence[int]]) -> tuple[Grid, Grid]:
    """Return the periodic horizontal and vertical discrete derivatives of g."""
    if not g or not g[0] or any(len(row) != len(g[0]) for row in g):
        raise ValueError("g must be a nonempty rectangular grid")
    n, m = len(g), len(g[0])
    dx = [[g[j][(i + 1) % m] - g[j][i] for i in range(m)] for j in range(n)]
    dy = [[g[(j + 1) % n][i] - g[j][i] for i in range(m)] for j in range(n)]
    return dx, dy


def gauge_shift(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]], g: Sequence[Sequence[int]]) -> tuple[Grid, Grid]:
    """Add the discrete gradient of g to the increment field (a, b)."""
    m, n = validate_pair(a, b)
    if len(g) != n or any(len(row) != m for row in g):
        raise ValueError("g must have the same shape as a and b")
    dx, dy = gradient(g)
    return (
        [[a[j][i] + dx[j][i] for i in range(m)] for j in range(n)],
        [[b[j][i] + dy[j][i] for i in range(m)] for j in range(n)],
    )


def increments_from_height(h: Sequence[Sequence[int]]) -> tuple[Grid, Grid]:
    """Construct a developable increment field as the gradient of h."""
    return gradient(h)


def reconstruct_height(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]]) -> Grid:
    """Reconstruct a potential with value zero at (0, 0), or raise ValueError.

    The obstruction test is complete: reconstruction is attempted exactly when
    every tile curvature and both periods vanish.
    """
    m, n = validate_pair(a, b)
    obs = obstruction(a, b)
    if not obs.vanishes:
        raise ValueError(f"field is not developable: {obs}")

    h = [[0 for _ in range(m)] for _ in range(n)]
    for i in range(1, m):
        h[0][i] = h[0][i - 1] + a[0][i - 1]
    for i in range(m):
        for j in range(1, n):
            h[j][i] = h[j - 1][i] + b[j - 1][i]

    aa, bb = increments_from_height(h)
    if aa != [list(row) for row in a] or bb != [list(row) for row in b]:
        raise ArithmeticError("internal reconstruction check failed")
    return h


def format_grid(grid: Sequence[Sequence[int]]) -> str:
    """Format a rectangular integer grid for terminal output."""
    return "\n".join("  " + " ".join(f"{value:4d}" for value in row) for row in grid)


def demo_global_waterfall() -> None:
    """Show a flat 3x3 waterfall with nonzero horizontal holonomy."""
    a = [[-1] * 3 for _ in range(3)]
    b = [[0] * 3 for _ in range(3)]
    before = obstruction(a, b)
    g = [[i - j for i in range(3)] for j in range(3)]
    shifted_a, shifted_b = gauge_shift(a, b, g)
    after = obstruction(shifted_a, shifted_b)

    print("1. Flat but globally impossible waterfall")
    print("   curvature:")
    print(format_grid(before.curvature))
    print(f"   periods: ({before.period_x}, {before.period_y})")
    print("   checker gauge:")
    print(format_grid(g))
    print("   shifted horizontal increments:")
    print(format_grid(shifted_a))
    print(f"   obstruction unchanged: {before == after}\n")
    assert before == after and not before.vanishes


def demo_developable_surface() -> None:
    """Construct, gauge-shift, and reconstruct a nonconstant height field."""
    original_h = [[i * i - 2 * j for i in range(4)] for j in range(3)]
    a, b = increments_from_height(original_h)
    g = [[(i + 2 * j) % 5 for i in range(4)] for j in range(3)]
    shifted_a, shifted_b = gauge_shift(a, b, g)
    recovered = reconstruct_height(shifted_a, shifted_b)
    expected = [
        [original_h[j][i] + g[j][i] - original_h[0][0] - g[0][0] for i in range(4)]
        for j in range(3)
    ]

    print("2. Developable field and potential reconstruction")
    print(f"   original obstruction vanishes: {obstruction(a, b).vanishes}")
    print(f"   shifted obstruction vanishes:  {obstruction(shifted_a, shifted_b).vanishes}")
    print("   reconstructed shifted height:")
    print(format_grid(recovered))
    print(f"   equals h + g up to a constant: {recovered == expected}\n")
    assert recovered == expected


def demo_local_defect() -> None:
    """Show a single altered edge producing nonzero tile curvature."""
    a = [[0] * 4 for _ in range(3)]
    b = [[0] * 4 for _ in range(3)]
    a[1][2] = 1
    obs = obstruction(a, b)
    nonzero = [(i, j, obs.curvature[j][i]) for j in range(3) for i in range(4) if obs.curvature[j][i] != 0]

    print("3. Local impossibility certificate")
    print(f"   nonzero curvature tiles (i, j, value): {nonzero}")
    print(f"   developable: {obs.vanishes}\n")
    assert nonzero and not obs.vanishes


def demo_power_of_two_filtration() -> None:
    """Illustrate strict descent and finite approximations to zero intersection."""
    levels = 7
    witnesses = [(k, 2**k, 2**k % (2 ** (k + 1)) != 0) for k in range(levels)]
    bound = 64
    common = [z for z in range(-bound, bound + 1) if all(z % (2**k) == 0 for k in range(levels))]

    print("4. Nonperiodic power-of-two filtration")
    print("   strictness witnesses (k, 2^k, excluded from next level):")
    print(f"   {witnesses}")
    print(f"   integers in [-{bound}, {bound}] divisible by 2^k for k < {levels}: {common}")
    print("   This is infinite descent, not a closed periodic ascent.\n")
    assert all(flag for _, _, flag in witnesses)


def main() -> None:
    """Run all exact demonstrations."""
    print("Gauge-Invariant Obstructions to Periodic Impossible Figures\n")
    demo_global_waterfall()
    demo_developable_surface()
    demo_local_defect()
    demo_power_of_two_filtration()


if __name__ == "__main__":
    main()
