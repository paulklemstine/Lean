"""
Cellular Automata at the Ordinals: Transfinite Computation
==========================================================

Numerical demonstrations of the spreading cellular automaton and its
transfinite (ordinal) behaviour.

The spreading rule on cells N = {0, 1, 2, ...}:

    spread(S) = {0} union {n + 1 : n in S}

i.e. cell 0 is a permanent source, and any other cell turns on iff its
left neighbour was on. This is a monotone, radius-1 cellular automaton.

Key facts demonstrated below:
  * spread^[k]({}) = {0, 1, ..., k-1}        (finite orbit)
  * spread^[k]({}) != N for every finite k   (never completes in finite time)
  * lfp(spread) = N                          (least fixed point = all cells)
  * stage omega (union of all finite stages) = N   (completes at omega)
  * closure ordinal is exactly omega

All functions are self-contained and type hinted. Configurations are
represented as frozensets of nonnegative integers (finite approximations
of the infinite line).
"""

from __future__ import annotations

from typing import Iterable, List, Set, Tuple


# --------------------------------------------------------------------------
# The spreading rule
# --------------------------------------------------------------------------
def spread(config: Set[int]) -> Set[int]:
    """Apply one step of the spreading cellular automaton.

    spread(S) = {0} union {n + 1 : n in S}.
    """
    return {0} | {n + 1 for n in config}


def spread_iterate(k: int) -> Set[int]:
    """Return spread^[k]({}), the configuration after k finite steps from empty."""
    config: Set[int] = set()
    for _ in range(k):
        config = spread(config)
    return config


def initial_segment(k: int) -> Set[int]:
    """Return {0, 1, ..., k-1} = Iio(k)."""
    return set(range(k))


# --------------------------------------------------------------------------
# Demo 1: finite orbit equals the initial segment  (Theorem: finite orbit)
# --------------------------------------------------------------------------
def demo_finite_orbit(max_k: int = 8) -> None:
    """Show that after k steps exactly cells {0, ..., k-1} are on."""
    print("=" * 68)
    print("Demo 1: finite orbit  spread^[k]({}) = {0, 1, ..., k-1}")
    print("=" * 68)
    for k in range(max_k + 1):
        cfg = spread_iterate(k)
        seg = initial_segment(k)
        match = "OK" if cfg == seg else "MISMATCH"
        print(f"  k={k:2d}:  spread^[k]({{}}) = {sorted(cfg)!s:<26}  [{match}]")
    print()


# --------------------------------------------------------------------------
# Demo 2: no finite stage completes  (Theorem: no finite stage completes)
# --------------------------------------------------------------------------
def demo_never_completes(max_k: int = 8) -> None:
    """Show that cell k is always still off after k steps."""
    print("=" * 68)
    print("Demo 2: no finite stage completes  (cell k is off after k steps)")
    print("=" * 68)
    for k in range(max_k + 1):
        cfg = spread_iterate(k)
        witness_off = k not in cfg  # cell k witnesses incompleteness
        print(f"  k={k:2d}:  cell {k} present? {k in cfg!s:<6} "
              f"-> proper subset of N: {witness_off}")
    print("  Conclusion: for every finite k, the configuration is a PROPER")
    print("  subset of the fully-on line.  The computation never finishes")
    print("  in finite time.\n")


# --------------------------------------------------------------------------
# Demo 3: completion at omega  (union of all finite stages)
# --------------------------------------------------------------------------
def stage_omega(bound: int) -> Set[int]:
    """Approximate the limit stage omega = union_{n} spread^[n]({}),
    restricted to cells < bound (the union is all of N in the limit)."""
    result: Set[int] = set()
    for n in range(bound + 1):
        result |= spread_iterate(n)
    return {c for c in result if c < bound}


def demo_completion_at_omega(bound: int = 12) -> None:
    """Show that the union of all finite stages fills the whole line."""
    print("=" * 68)
    print("Demo 3: completion at stage omega  (union of all finite stages = N)")
    print("=" * 68)
    omega_cfg = stage_omega(bound)
    full = set(range(bound))
    print(f"  Cells below {bound} on at stage omega: {sorted(omega_cfg)}")
    print(f"  All cells below {bound}:                {sorted(full)}")
    print(f"  Every cell present at omega? {omega_cfg == full}")
    print("  Each cell n turns on at finite stage n+1, hence lies in the")
    print("  union taken at omega.  Stage omega = N.\n")


# --------------------------------------------------------------------------
# Demo 4: closure ordinal is exactly omega
# --------------------------------------------------------------------------
def is_fixed_point(config: Set[int], bound: int) -> bool:
    """Test whether config is a fixed point of spread, restricted to cells < bound."""
    stepped = {c for c in spread(config) if c < bound}
    restricted = {c for c in config if c < bound}
    return stepped == restricted


def demo_closure_ordinal(bound: int = 12) -> None:
    """Show finite stages are never fixed points but stage omega is."""
    print("=" * 68)
    print("Demo 4: closure ordinal is exactly omega")
    print("=" * 68)
    print("  Finite stages are strictly increasing (never fixed points):")
    for k in range(6):
        cfg = spread_iterate(k)
        nxt = spread_iterate(k + 1)
        strict = cfg != nxt
        print(f"    stage {k}: strictly grows to stage {k+1}? {strict}")
    omega_cfg = stage_omega(bound)
    # As a subset of the full line, N is the genuine fixed point.
    fixed = set(range(bound)) == omega_cfg and is_fixed_point(set(range(bound)), bound)
    print(f"  Stage omega equals N and N is a fixed point of spread: {fixed}")
    print("  => the least fixed point is first reached at omega, at no finite")
    print("     stage.  Closure ordinal = omega.\n")


# --------------------------------------------------------------------------
# Demo 5: a glimpse beyond omega  (grid rule with closure ordinal omega^2)
# --------------------------------------------------------------------------
def grid_spread(config: Set[Tuple[int, int]], width: int) -> Set[Tuple[int, int]]:
    """One step of a grid automaton whose closure ordinal is omega^2.

    Row 0 spreads like the 1-D automaton.  Row i+1 begins to fill (from
    its left source) only once row i is complete up to `width`.
    Cells are (row, col) with col in [0, width).
    """
    result: Set[Tuple[int, int]] = set(config)
    # row 0 always has a source and spreads rightward
    result.add((0, 0))
    for (r, c) in config:
        if c + 1 < width:
            result.add((r, c + 1))
    # a new row's source switches on once the row below is complete
    max_row = max((r for (r, _) in config), default=0)
    for r in range(max_row + 2):
        row_below_complete = all((r - 1, c) in config for c in range(width)) if r > 0 else True
        if row_below_complete:
            result.add((r, 0))
    return {(r, c) for (r, c) in result if 0 <= c < width}


def demo_grid_beyond_omega(width: int = 4, steps: int = 20) -> None:
    """Illustrate a grid rule whose completion requires omega-many omega-runs."""
    print("=" * 68)
    print("Demo 5: beyond omega -- a grid rule with closure ordinal omega^2")
    print("=" * 68)
    config: Set[Tuple[int, int]] = set()
    completed_rows: List[int] = []
    for t in range(steps):
        config = grid_spread(config, width)
        for r in range(width):
            if r not in completed_rows and all((r, c) in config for c in range(width)):
                completed_rows.append(r)
    print(f"  width={width}, after {steps} finite steps, completed rows: "
          f"{sorted(completed_rows)}")
    print("  Each row needs ~width finite steps AFTER the row below finishes;")
    print("  finishing infinitely many rows in sequence needs omega copies of")
    print("  omega, i.e. closure ordinal omega^2.\n")


# --------------------------------------------------------------------------
def main() -> None:
    demo_finite_orbit()
    demo_never_completes()
    demo_completion_at_omega()
    demo_closure_ordinal()
    demo_grid_beyond_omega()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
