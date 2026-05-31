"""
Algorithms for Transfinite Cellular Automata Computation

Type-hinted implementations of the core algorithms for simulating
cellular automata with transfinite (omega-limit) evolution.
"""

from typing import Callable, Dict, List, Optional, Tuple

# Type aliases
CAConfig = Dict[int, bool]  # sparse representation: position -> state
CARuleType = Callable[[bool, bool, bool], bool]


def wolfram_rule(n: int) -> CARuleType:
    """Create a CA rule from Wolfram numbering (0-255).

    Args:
        n: Rule number (0-255)

    Returns:
        A function (left, center, right) -> new_state
    """
    def rule(left: bool, center: bool, right: bool) -> bool:
        idx = (4 if left else 0) + (2 if center else 0) + (1 if right else 0)
        return bool((n >> idx) & 1)
    return rule


def or_rule(left: bool, center: bool, right: bool) -> bool:
    """OR rule: output is true if any input is true."""
    return left or center or right


def xor_rule(left: bool, center: bool, right: bool) -> bool:
    """XOR rule: output is XOR of left and right neighbors."""
    return left ^ right


def id_rule(left: bool, center: bool, right: bool) -> bool:
    """Identity rule: output equals center input."""
    return center


def ca_step(rule: CARuleType, cfg: CAConfig, bounds: Tuple[int, int]) -> CAConfig:
    """Apply a CA rule to a configuration for one step.

    Args:
        rule: The CA rule function
        cfg: Current configuration (sparse dict)
        bounds: (min_pos, max_pos) defining the simulation range

    Returns:
        New configuration after one step
    """
    lo, hi = bounds
    new_cfg: CAConfig = {}
    for i in range(lo - 1, hi + 2):  # extend bounds by 1
        left = cfg.get(i - 1, False)
        center = cfg.get(i, False)
        right = cfg.get(i + 1, False)
        new_cfg[i] = rule(left, center, right)
    return new_cfg


def ca_iter(rule: CARuleType, cfg: CAConfig, n: int,
            bounds: Tuple[int, int]) -> CAConfig:
    """Iterate a CA rule n times.

    Args:
        rule: The CA rule function
        cfg: Initial configuration
        n: Number of iterations
        bounds: Simulation bounds (extended by n at each step)

    Returns:
        Configuration after n iterations
    """
    current = cfg.copy()
    lo, hi = bounds
    for step in range(n):
        current = ca_step(rule, current, (lo - step, hi + step))
    return current


def detect_stabilization(rule: CARuleType, cfg: CAConfig, position: int,
                          max_steps: int, bounds: Tuple[int, int]
                          ) -> Tuple[str, Optional[bool]]:
    """Detect whether a cell eventually stabilizes.

    Args:
        rule: CA rule
        cfg: Initial configuration
        position: Cell position to monitor
        max_steps: Maximum simulation steps
        bounds: Simulation bounds

    Returns:
        ("stable", value) if stabilized,
        ("oscillating", None) if detected oscillation,
        ("undetermined", None) otherwise
    """
    history: List[bool] = []
    current = cfg.copy()
    lo, hi = bounds

    for step in range(max_steps):
        val = current.get(position, False)
        history.append(val)
        current = ca_step(rule, current, (lo - step, hi + step))

    # Check if last half is constant
    half = max_steps // 2
    if len(set(history[half:])) == 1:
        return ("stable", history[-1])

    # Check for oscillation: both values appear in second half
    second_half = set(history[half:])
    if True in second_half and False in second_half:
        return ("oscillating", None)

    return ("undetermined", None)


def compute_omega_limit(rule: CARuleType, cfg: CAConfig, max_steps: int,
                         bounds: Tuple[int, int]) -> CAConfig:
    """Approximate the omega-limit configuration.

    Simulates the CA for max_steps iterations and returns the eventual
    values of cells that have stabilized.

    Args:
        rule: CA rule
        cfg: Initial configuration
        max_steps: Number of simulation steps
        bounds: Simulation bounds

    Returns:
        Approximate omega-limit configuration
    """
    lo, hi = bounds
    # Collect history
    configs: List[CAConfig] = [cfg.copy()]
    current = cfg.copy()
    for step in range(max_steps):
        current = ca_step(rule, current, (lo - step, hi + step))
        configs.append(current.copy())

    # Compute eventual values
    omega_cfg: CAConfig = {}
    check_range = range(lo - max_steps, hi + max_steps + 1)

    half = max_steps // 2
    for pos in check_range:
        values = [c.get(pos, False) for c in configs[half:]]
        if len(set(values)) == 1:
            omega_cfg[pos] = values[0]
        else:
            omega_cfg[pos] = False  # oscillating -> false

    return omega_cfg


def transfinite_simulate(rule: CARuleType, cfg: CAConfig, num_levels: int,
                          steps_per_level: int, bounds: Tuple[int, int]
                          ) -> List[CAConfig]:
    """Simulate transfinite CA evolution for multiple limit steps.

    Args:
        rule: CA rule
        cfg: Initial configuration
        num_levels: Number of transfinite levels (omega-limits)
        steps_per_level: Finite steps to simulate at each level
        bounds: Initial simulation bounds

    Returns:
        List of configurations: [level_0, level_1, ..., level_n]
    """
    levels: List[CAConfig] = [cfg.copy()]
    current = cfg.copy()

    for level in range(num_levels):
        extended_bounds = (bounds[0] - steps_per_level * (level + 1),
                          bounds[1] + steps_per_level * (level + 1))
        omega = compute_omega_limit(rule, current, steps_per_level, extended_bounds)
        levels.append(omega)
        current = omega

    return levels


def classify_rule_depth(rule_number: int, max_steps: int = 500,
                         check_range: int = 50) -> Tuple[int, str]:
    """Classify a Wolfram rule by its transfinite depth from singleCell.

    Args:
        rule_number: Wolfram rule number (0-255)
        max_steps: Steps per level for simulation
        check_range: Spatial range to check

    Returns:
        (depth, classification) where depth is 0, 1, or -1 (infinite/unknown)
        and classification is "fixed", "depth-1", or "oscillating"
    """
    rule = wolfram_rule(rule_number)
    cfg: CAConfig = {0: True}
    bounds = (-1, 1)

    # Check if singleCell is already a fixed point
    stepped = ca_step(rule, cfg, bounds)
    is_fixed = all(cfg.get(i, False) == stepped.get(i, False)
                   for i in range(-check_range, check_range + 1))
    if is_fixed:
        return (0, "fixed")

    # Compute omega-limit
    omega = compute_omega_limit(rule, cfg, max_steps, (-check_range, check_range))

    # Check if omega-limit is a fixed point
    omega_stepped = ca_step(rule, omega, (-check_range - 1, check_range + 1))
    omega_fixed = all(omega.get(i, False) == omega_stepped.get(i, False)
                      for i in range(-check_range, check_range + 1))
    if omega_fixed:
        return (1, "depth-1")

    return (-1, "oscillating")


def compute_cell_depths(rule: CARuleType, cfg: CAConfig, max_levels: int,
                         steps_per_level: int, bounds: Tuple[int, int]
                         ) -> Dict[int, int]:
    """Compute the stabilization depth of each cell.

    Args:
        rule: CA rule
        cfg: Initial configuration
        max_levels: Maximum transfinite levels to check
        steps_per_level: Steps per level
        bounds: Simulation bounds

    Returns:
        Dictionary mapping cell position to depth (-1 if unstable)
    """
    levels = transfinite_simulate(rule, cfg, max_levels, steps_per_level, bounds)
    depths: Dict[int, int] = {}

    lo, hi = bounds
    for pos in range(lo - steps_per_level * max_levels,
                     hi + steps_per_level * max_levels + 1):
        for level_idx in range(len(levels)):
            level_cfg = levels[level_idx]
            if level_idx == 0:
                # Check if cell is in initial fixed point
                status, _ = detect_stabilization(
                    rule, levels[0], pos, min(steps_per_level, 100),
                    (lo, hi))
                if status == "stable":
                    depths[pos] = 0
                    break
            else:
                prev_cfg = levels[level_idx - 1]
                # Check if value changed from previous level
                if level_cfg.get(pos, False) == prev_cfg.get(pos, False):
                    depths.setdefault(pos, level_idx - 1)
                    break
        else:
            depths[pos] = -1  # unstable

    return depths
