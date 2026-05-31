"""
Algorithms for Transfinite Cellular Automata Simulation

Implements the core algorithms for simulating 1D binary cellular automata
over finite and transfinite (omega-limit) time steps.
"""

from typing import Callable, Dict, List, Optional, Tuple

# Type aliases
Config = Dict[int, bool]  # Sparse representation: missing keys default to False
Rule = Callable[[bool, bool, bool], bool]


def get_cell(cfg: Config, i: int) -> bool:
    """Get the value of cell i, defaulting to False if not present."""
    return cfg.get(i, False)


def ca_step(rule: Rule, cfg: Config, window: Tuple[int, int]) -> Config:
    """Apply one step of a CA rule to a configuration within a window.

    Args:
        rule: A function (left, center, right) -> new_center.
        cfg: The current configuration (sparse dict).
        window: (lo, hi) inclusive bounds for simulation.

    Returns:
        New configuration after one step.
    """
    lo, hi = window
    new_cfg: Config = {}
    for i in range(lo, hi + 1):
        val = rule(get_cell(cfg, i - 1), get_cell(cfg, i), get_cell(cfg, i + 1))
        if val:
            new_cfg[i] = True
    return new_cfg


def ca_iter(rule: Rule, cfg: Config, n: int, window: Tuple[int, int]) -> Config:
    """Iterate a CA rule n times within a window.

    Args:
        rule: The CA rule function.
        cfg: Initial configuration.
        n: Number of steps.
        window: (lo, hi) simulation bounds.

    Returns:
        Configuration after n steps.
    """
    current = cfg
    for _ in range(n):
        current = ca_step(rule, current, window)
    return current


def detect_stability(
    rule: Rule,
    cfg: Config,
    window: Tuple[int, int],
    max_steps: int,
    stability_window: int = 50,
) -> Tuple[Config, Dict[int, bool]]:
    """Detect which cells have stabilized and compute approximate omega-limit.

    Args:
        rule: The CA rule function.
        cfg: Initial configuration.
        window: (lo, hi) simulation bounds.
        max_steps: Maximum number of steps to simulate.
        stability_window: Number of consecutive identical values to declare stability.

    Returns:
        (omega_limit, is_stable): The approximate omega-limit configuration
        and a dict indicating which cells are considered stable.
    """
    lo, hi = window
    current = cfg
    # Track stability for each cell
    stable_count: Dict[int, int] = {i: 0 for i in range(lo, hi + 1)}
    last_value: Dict[int, bool] = {i: get_cell(cfg, i) for i in range(lo, hi + 1)}

    for _ in range(max_steps):
        current = ca_step(rule, current, window)
        for i in range(lo, hi + 1):
            val = get_cell(current, i)
            if val == last_value[i]:
                stable_count[i] += 1
            else:
                stable_count[i] = 0
                last_value[i] = val

    omega_limit: Config = {}
    is_stable: Dict[int, bool] = {}
    for i in range(lo, hi + 1):
        is_stable[i] = stable_count[i] >= stability_window
        if is_stable[i]:
            if last_value[i]:
                omega_limit[i] = True
        # Oscillating cells default to False (omega-limit collapse)

    return omega_limit, is_stable


def is_fixed_point(rule: Rule, cfg: Config, window: Tuple[int, int]) -> bool:
    """Check if a configuration is a fixed point of the rule within a window.

    Args:
        rule: The CA rule function.
        cfg: Configuration to check.
        window: (lo, hi) bounds.

    Returns:
        True if applying the rule doesn't change the configuration.
    """
    stepped = ca_step(rule, cfg, window)
    lo, hi = window
    for i in range(lo, hi + 1):
        if get_cell(stepped, i) != get_cell(cfg, i):
            return False
    return True


def estimate_depth(
    rule: Rule,
    cfg: Config,
    window: Tuple[int, int],
    max_depth: int = 5,
    max_steps: int = 500,
    stability_window: int = 50,
) -> Tuple[Optional[int], List[Config]]:
    """Estimate the transfinite depth of a CA computation.

    Args:
        rule: The CA rule function.
        cfg: Initial configuration.
        window: (lo, hi) simulation bounds.
        max_depth: Maximum depth to check.
        max_steps: Max steps per omega-limit computation.
        stability_window: Stability detection threshold.

    Returns:
        (depth, levels): The estimated depth (or None if > max_depth),
        and the list of configurations at each transfinite level.
    """
    levels: List[Config] = [cfg]

    for d in range(max_depth + 1):
        if is_fixed_point(rule, levels[-1], window):
            return d, levels
        omega, _ = detect_stability(rule, levels[-1], window, max_steps, stability_window)
        levels.append(omega)

    return None, levels


# Standard CA rules

def or_rule(l: bool, c: bool, r: bool) -> bool:
    """OR rule: true if any neighbor is true."""
    return l or c or r


def and_rule(l: bool, c: bool, r: bool) -> bool:
    """AND rule: true only if all neighbors are true."""
    return l and c and r


def not_rule(_l: bool, c: bool, _r: bool) -> bool:
    """NOT rule: flips the center cell."""
    return not c


def xor_rule(l: bool, c: bool, r: bool) -> bool:
    """XOR rule: parity of all three cells."""
    return l ^ c ^ r


def majority_rule(l: bool, c: bool, r: bool) -> bool:
    """Majority rule: true if at least 2 of 3 are true."""
    return (int(l) + int(c) + int(r)) >= 2


def spreading_xor_rule(l: bool, c: bool, r: bool) -> bool:
    """A candidate depth-2 rule: OR-like spreading with XOR parity effect.
    
    Behaves like OR when the neighborhood has at most one true cell,
    but introduces parity effects when multiple cells are true.
    """
    count = int(l) + int(c) + int(r)
    if count == 0:
        return False
    elif count == 1:
        return True  # Spreading behavior
    else:
        return l ^ c ^ r  # Parity effect when congested


def compute_convergence_spectrum(
    rule: Rule,
    configs: List[Config],
    window: Tuple[int, int],
    max_depth: int = 5,
) -> Dict[Optional[int], int]:
    """Compute the convergence spectrum for a set of initial configurations.

    Args:
        rule: The CA rule function.
        configs: List of initial configurations to classify.
        window: Simulation bounds.
        max_depth: Maximum depth to check.

    Returns:
        A dict mapping depth -> count of configurations at that depth.
    """
    spectrum: Dict[Optional[int], int] = {}
    for cfg in configs:
        depth, _ = estimate_depth(rule, cfg, window, max_depth)
        spectrum[depth] = spectrum.get(depth, 0) + 1
    return spectrum
