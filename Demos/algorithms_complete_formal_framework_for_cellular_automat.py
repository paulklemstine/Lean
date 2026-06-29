"""
Algorithms for Transfinite Cellular Automata Depth Theory.

Type-hinted implementations of core CA operations, convergence detection,
monotonicity testing, and depth classification.
"""

from typing import Callable, Dict, List, Optional, Tuple


# Type aliases
Config = List[bool]  # Finite approximation: periodic boundary
CARule = Callable[[bool, bool, bool], bool]


def or_rule(left: bool, center: bool, right: bool) -> bool:
    """OR rule: output true if any input is true."""
    return left or center or right


def not_rule(left: bool, center: bool, right: bool) -> bool:
    """NOT rule: flip the center cell."""
    return not center


def and_rule(left: bool, center: bool, right: bool) -> bool:
    """AND rule: output true only if all inputs are true."""
    return left and center and right


def id_rule(left: bool, center: bool, right: bool) -> bool:
    """Identity rule: keep center value."""
    return center


def ca_step(rule: CARule, cfg: Config) -> Config:
    """Apply one global step of the CA rule with periodic boundary."""
    n = len(cfg)
    if n == 0:
        return []
    return [rule(cfg[(i - 1) % n], cfg[i], cfg[(i + 1) % n]) for i in range(n)]


def ca_iter(rule: CARule, cfg: Config, steps: int) -> Config:
    """Iterate the CA rule for the given number of steps."""
    current = cfg[:]
    for _ in range(steps):
        current = ca_step(rule, current)
    return current


def is_fixed_point(rule: CARule, cfg: Config) -> bool:
    """Check if a configuration is a fixed point."""
    return ca_step(rule, cfg) == cfg


def detect_period(rule: CARule, cfg: Config, max_steps: int = 10000) -> Tuple[str, int]:
    """
    Detect the dynamical behavior of a configuration.

    Returns:
        ("fixed_point", 0) if cfg is already a fixed point
        ("converges", t) if cfg reaches a fixed point at step t
        ("periodic", p) if cfg enters a cycle of period p
        ("undetermined", max_steps) if no conclusion in max_steps
    """
    seen: Dict[tuple, int] = {}
    current = cfg[:]
    for t in range(max_steps):
        key = tuple(current)
        if key in seen:
            period = t - seen[key]
            if period == 1:
                return ("fixed_point", seen[key])
            else:
                return ("periodic", period)
        seen[key] = t
        current = ca_step(rule, current)
    return ("undetermined", max_steps)


def is_monotone_rule(rule: CARule) -> bool:
    """
    Check if a 3-input Boolean rule is monotone.

    A rule is monotone if whenever each input is ≤ the corresponding input
    in a second triple, the output is ≤ the second output.
    """
    for l1 in [False, True]:
        for c1 in [False, True]:
            for r1 in [False, True]:
                if not rule(l1, c1, r1):
                    continue
                # rule(l1,c1,r1) is True, check all dominating triples
                for l2 in [False, True]:
                    for c2 in [False, True]:
                        for r2 in [False, True]:
                            # Check if (l1,c1,r1) ≤ (l2,c2,r2)
                            if (l1 <= l2) and (c1 <= c2) and (r1 <= r2):
                                if not rule(l2, c2, r2):
                                    return False
    return True


def eca_rule(rule_number: int) -> CARule:
    """
    Return the Elementary Cellular Automaton rule function for a given rule number (0-255).

    The rule number encodes the truth table: bit (4*l + 2*c + r) of rule_number
    gives the output for neighborhood (l, c, r).
    """
    def rule(left: bool, center: bool, right: bool) -> bool:
        idx = (4 if left else 0) + (2 if center else 0) + (1 if right else 0)
        return bool((rule_number >> idx) & 1)
    return rule


def classify_eca_rules() -> Dict[str, List[int]]:
    """
    Classify all 256 ECA rules by convergence behavior.

    Returns dict with keys 'monotone', 'has_fixed_points', 'depth0_candidate',
    and lists of rule numbers.
    """
    result: Dict[str, List[int]] = {
        'monotone': [],
        'has_fixed_points': [],
        'depth0_candidate': [],
        'no_fixed_points': [],
    }

    for r in range(256):
        rule = eca_rule(r)

        if is_monotone_rule(rule):
            result['monotone'].append(r)

        # Check fixed points on small rings
        has_fp = False
        all_fp = True
        for size in [4, 6, 8]:
            for bits in range(2**size):
                cfg = [(bits >> i) & 1 == 1 for i in range(size)]
                if is_fixed_point(rule, cfg):
                    has_fp = True
                else:
                    all_fp = False

        if has_fp:
            result['has_fixed_points'].append(r)
        else:
            result['no_fixed_points'].append(r)

        if all_fp:
            result['depth0_candidate'].append(r)

    return result


def measure_spreading_speed(rule: CARule, size: int = 201, steps: int = 100) -> float:
    """
    Measure the spreading speed of a rule from a single true cell.

    Returns the ratio (radius of true region) / steps.
    """
    cfg = [False] * size
    cfg[size // 2] = True

    evolved = ca_iter(rule, cfg, steps)

    # Find the rightmost true cell
    rightmost = size // 2
    for i in range(size // 2, size):
        if evolved[i]:
            rightmost = i

    radius = rightmost - size // 2
    return radius / steps if steps > 0 else 0.0


def convergence_depth_estimate(rule: CARule, cfg: Config,
                                max_omega_steps: int = 3,
                                stabilization_window: int = 100) -> int:
    """
    Estimate the convergence depth of a rule from a given configuration.

    Repeatedly applies omega-limit approximation and checks for fixed points.
    Returns the estimated depth (0, 1, 2, ...) or -1 for apparent infinite depth.
    """
    current = cfg[:]

    for depth in range(max_omega_steps):
        if is_fixed_point(rule, current):
            return depth

        # Approximate omega-limit by iterating many steps
        current = ca_iter(rule, current, stabilization_window)

        # Check if it stabilized
        next_step = ca_step(rule, current)
        if current == next_step:
            return depth + 1

        # Check for periodicity
        behavior, period = detect_period(rule, current, max_steps=stabilization_window)
        if behavior == "periodic" and period > 1:
            return -1  # Infinite depth (periodic, no convergence)

    return -1  # Undetermined / likely infinite
