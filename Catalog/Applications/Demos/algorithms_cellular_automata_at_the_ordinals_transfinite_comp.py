"""
Ordinal Cellular Automata: Algorithms
======================================

Type-hinted implementations of the core algorithms for
ordinal cellular automata and transfinite computation.
"""

from typing import Callable, Optional
from dataclasses import dataclass


# --- Configuration Types ---

Config = list[bool]  # A configuration is a list of boolean cell states


@dataclass
class OrdinalCA:
    """An Ordinal Cellular Automaton.

    Attributes:
        rule: The local transition rule (Config → Config)
        name: Human-readable name
    """
    rule: Callable[[Config], Config]
    name: str = "OCA"

    def evolve_finite(self, config: Config, steps: int) -> Config:
        """Evolve for a finite number of steps."""
        current = config[:]
        for _ in range(steps):
            current = self.rule(current)
        return current

    def evolve_to_omega(self, config: Config, approx_steps: int = 1000) -> Config:
        """Approximate the limit at ω by running many finite steps.

        For monotone OCAs, the limit is reached when the configuration
        stabilizes (no change between consecutive steps).
        """
        current = config[:]
        for _ in range(approx_steps):
            next_config = self.rule(current)
            if next_config == current:
                break
            current = next_config
        return current

    def stabilization_step(self, config: Config, max_steps: int = 10000) -> Optional[int]:
        """Find the finite step at which the OCA stabilizes, if it does.

        Returns None if the OCA hasn't stabilized within max_steps.
        For the spreading OCA on finite configs, this always terminates.
        """
        current = config[:]
        for step in range(max_steps):
            next_config = self.rule(current)
            if next_config == current:
                return step
            current = next_config
        return None

    def computation_depth(self, initial: Config, target: Config,
                          max_steps: int = 10000) -> Optional[int]:
        """Find the ordinal depth at which target first appears.

        Returns the minimum step n such that rule^n(initial) = target,
        or None if not found within max_steps.
        """
        current = initial[:]
        for step in range(max_steps):
            if current == target:
                return step
            current = self.rule(current)
        return None


# --- Spreading Rule ---

def spread_rule(config: Config) -> Config:
    """The spreading rule: cell n becomes true if it or its left neighbor is true.

    This is monotone (preserves ≤) and inflationary (c ≤ spread(c)).
    """
    size = len(config)
    result = [False] * size
    for n in range(size):
        result[n] = config[n] or (config[n - 1] if n > 0 else False)
    return result


def make_spread_oca() -> OrdinalCA:
    """Create the canonical spreading OCA."""
    return OrdinalCA(rule=spread_rule, name="Spreading OCA")


# --- Cascade Rule Family ---

def cascade_rule(depth: int) -> Callable[[Config], Config]:
    """Create a cascade rule of given depth.

    The cascade rule of depth d requires d consecutive true cells
    to the left for propagation. Depth 1 = spreading rule.
    """
    def rule(config: Config) -> Config:
        size = len(config)
        result = [False] * size
        for k in range(size):
            if config[k]:
                result[k] = True
            elif k >= depth and all(config[k - 1 - i] for i in range(depth)):
                result[k] = True
        return result
    return rule


def make_cascade_oca(depth: int) -> OrdinalCA:
    """Create a cascade OCA of given depth."""
    return OrdinalCA(
        rule=cascade_rule(depth),
        name=f"Cascade OCA (depth {depth})"
    )


# --- Configuration Constructors ---

def seed_config(size: int) -> Config:
    """The seed configuration: only cell 0 is true."""
    config = [False] * size
    if size > 0:
        config[0] = True
    return config


def threshold_config(n: int, size: int) -> Config:
    """Threshold configuration: cells 0..n-1 are true."""
    return [k < n for k in range(size)]


def all_true(size: int) -> Config:
    """The all-true configuration."""
    return [True] * size


def all_false(size: int) -> Config:
    """The all-false (quiescent) configuration."""
    return [False] * size


# --- Transfinite Computation Hierarchy ---

@dataclass
class HierarchyLevel:
    """A level in the transfinite computation hierarchy."""
    ordinal_label: str  # e.g., "0", "1", ..., "ω"
    config: Config
    true_count: int
    is_fixed_point: bool


def compute_hierarchy(oca: OrdinalCA, initial: Config,
                      finite_levels: int = 20) -> list[HierarchyLevel]:
    """Compute the transfinite computation hierarchy.

    Returns levels 0, 1, ..., n, ω showing how the OCA evolves.
    """
    levels: list[HierarchyLevel] = []
    current = initial[:]

    for step in range(finite_levels):
        next_config = oca.rule(current)
        is_fp = (next_config == current)
        levels.append(HierarchyLevel(
            ordinal_label=str(step),
            config=current[:],
            true_count=sum(current),
            is_fixed_point=is_fp
        ))
        if is_fp:
            break
        current = next_config

    # Omega level
    omega_config = oca.evolve_to_omega(initial)
    omega_next = oca.rule(omega_config)
    levels.append(HierarchyLevel(
        ordinal_label="ω",
        config=omega_config,
        true_count=sum(omega_config),
        is_fixed_point=(omega_next == omega_config)
    ))

    return levels


# --- Omega-Jump Operator ---

def omega_jump(oca: OrdinalCA, config: Config,
               approx_steps: int = 1000) -> Config:
    """The ω-jump operator: evolves to the limit at ω.

    For monotone inflationary OCAs, this is the supremum of all
    finite iterates. Approximated by iterating until stabilization.
    """
    return oca.evolve_to_omega(config, approx_steps)


def verify_omega_jump_idempotent(oca: OrdinalCA, config: Config) -> bool:
    """Verify that the ω-jump is idempotent (for stabilized OCAs).

    Returns True if ω-jump(ω-jump(config)) = ω-jump(config).
    """
    first_jump = omega_jump(oca, config)
    second_jump = omega_jump(oca, first_jump)
    return first_jump == second_jump


if __name__ == "__main__":
    # Quick verification
    oca = make_spread_oca()
    SIZE = 50

    print("Spreading OCA Hierarchy:")
    hierarchy = compute_hierarchy(oca, seed_config(SIZE))
    for level in hierarchy:
        print(f"  Level {level.ordinal_label:>3s}: "
              f"{level.true_count:3d} true cells, "
              f"fixed_point={level.is_fixed_point}")

    print(f"\nω-jump idempotent: {verify_omega_jump_idempotent(oca, seed_config(SIZE))}")
