"""
Arithmetic Resonance Theory — Core Algorithms

Implements the closure operator, resonance detection, and synergy computation
for finite dependency systems, mirroring the formal Lean definitions.
"""

from typing import Dict, FrozenSet, Set, List, Tuple
from dataclasses import dataclass, field


@dataclass
class FiniteResonanceSystem:
    """A finite resonance system with dependency structure and target sets.

    Attributes:
        nodes: Set of all node identifiers.
        deps: Mapping from each node to its set of prerequisites.
        arithmetic: Distinguished arithmetic sublibrary nodes.
        target_arithmetic: Arithmetic target theorems.
        target_control: Control (non-arithmetic) target theorems.
    """
    nodes: Set[str]
    deps: Dict[str, Set[str]]
    arithmetic: Set[str] = field(default_factory=set)
    target_arithmetic: Set[str] = field(default_factory=set)
    target_control: Set[str] = field(default_factory=set)

    def __post_init__(self):
        # Ensure all nodes have dependency entries
        for node in self.nodes:
            if node not in self.deps:
                self.deps[node] = set()


def step_closure(system: FiniteResonanceSystem, seed: Set[str]) -> Set[str]:
    """One step of the closure operator.

    Adds all nodes whose dependencies are fully contained in the current set.

    Args:
        system: The resonance system.
        seed: Current set of known/derivable nodes.

    Returns:
        The expanded set after one derivation step.

    Complexity: O(|nodes| * max_degree)
    """
    result = set(seed)
    for v in system.nodes:
        if system.deps.get(v, set()).issubset(seed):
            result.add(v)
    return result


def closure_iter(system: FiniteResonanceSystem, n: int, seed: Set[str]) -> Set[str]:
    """Iterate the step closure operator n times.

    Args:
        system: The resonance system.
        n: Number of iterations.
        seed: Initial seed set.

    Returns:
        The set after n closure iterations.

    Complexity: O(n * |nodes| * max_degree)
    """
    current = set(seed)
    for _ in range(n):
        current = step_closure(system, current)
    return current


def res_closure(system: FiniteResonanceSystem, seed: Set[str]) -> Set[str]:
    """Compute the full closure (fixed point) of the seed set.

    Iterates step_closure |nodes| times, which suffices for stabilization
    by the Closure Stabilization Theorem (Theorem 1).

    Args:
        system: The resonance system.
        seed: Initial seed set.

    Returns:
        The closure of the seed set.

    Complexity: O(|nodes|^2 * max_degree)
    """
    return closure_iter(system, len(system.nodes), seed)


def reachable_count(system: FiniteResonanceSystem, seed: Set[str],
                    targets: Set[str]) -> int:
    """Count how many targets are reachable from the seed set.

    Args:
        system: The resonance system.
        seed: Initial seed set.
        targets: Set of target nodes.

    Returns:
        Number of targets in the closure of seed.
    """
    closed = res_closure(system, seed)
    return len(targets & closed)


def resonance_score(system: FiniteResonanceSystem, seed: Set[str],
                    package: Set[str], targets: Set[str]) -> int:
    """Compute the resonance score of adding a package to the seed.

    The resonance score is the number of additional targets unlocked.

    Args:
        system: The resonance system.
        seed: Initial seed set.
        package: Set of nodes to add.
        targets: Set of target nodes.

    Returns:
        Number of newly reachable targets.
    """
    base = reachable_count(system, seed, targets)
    augmented = reachable_count(system, seed | package, targets)
    return augmented - base


def synergy_score(system: FiniteResonanceSystem, seed: Set[str],
                  package: Set[str], targets: Set[str]) -> int:
    """Compute the synergy score: combined resonance minus sum of singletons.

    A positive synergy score indicates superadditive gain — the whole
    package unlocks more than the sum of individual contributions.

    Args:
        system: The resonance system.
        seed: Initial seed set.
        package: Set of nodes to add.
        targets: Set of target nodes.

    Returns:
        Synergy score (positive = superadditive).
    """
    combined = resonance_score(system, seed, package, targets)
    individual_sum = sum(
        resonance_score(system, seed, {a}, targets)
        for a in package
    )
    return combined - individual_sum


def detect_bottleneck_resonance(system: FiniteResonanceSystem, seed: Set[str],
                                 package: Set[str]) -> bool:
    """Detect whether a package creates bottleneck resonance.

    Returns True if:
    1. The package unlocks at least one arithmetic target
    2. All control targets are already reachable from the seed alone

    This mirrors the verified `detectBottleneckResonance` function in Lean.

    Args:
        system: The resonance system.
        seed: Initial seed set.
        package: Set of nodes to add.

    Returns:
        True if bottleneck resonance is detected.
    """
    base_closure = res_closure(system, seed)
    aug_closure = res_closure(system, seed | package)

    # Check: exists arithmetic target newly unlocked
    has_new_arith = any(
        t not in base_closure and t in aug_closure
        for t in system.target_arithmetic
    )

    # Check: all control targets already reachable
    controls_ok = all(
        c in base_closure
        for c in system.target_control
    )

    return has_new_arith and controls_ok


def detect_selective_resonance(system: FiniteResonanceSystem, seed: Set[str],
                                package: Set[str]) -> dict:
    """Full selective resonance analysis.

    Returns a detailed report including resonance scores, synergy scores,
    and per-target reachability analysis.

    Args:
        system: The resonance system.
        seed: Initial seed set.
        package: Arithmetic package to evaluate.

    Returns:
        Dictionary with analysis results.
    """
    base_closure = res_closure(system, seed)
    aug_closure = res_closure(system, seed | package)

    arith_score = resonance_score(system, seed, package, system.target_arithmetic)
    ctrl_score = resonance_score(system, seed, package, system.target_control)
    syn = synergy_score(system, seed, package, system.target_arithmetic)
    is_bottleneck = detect_bottleneck_resonance(system, seed, package)

    newly_unlocked = [
        t for t in system.target_arithmetic
        if t not in base_closure and t in aug_closure
    ]

    return {
        "is_bottleneck_resonance": is_bottleneck,
        "arithmetic_resonance_score": arith_score,
        "control_resonance_score": ctrl_score,
        "synergy_score": syn,
        "newly_unlocked_targets": newly_unlocked,
        "total_reachable_before": len(base_closure),
        "total_reachable_after": len(aug_closure),
    }


def closure_depth_profile(system: FiniteResonanceSystem,
                           seed: Set[str]) -> Dict[str, int]:
    """Compute the proof depth of each node from the given seed.

    The proof depth is the minimum number of closure steps needed
    to derive the node, or |nodes|+1 if not reachable.

    Args:
        system: The resonance system.
        seed: Initial seed set.

    Returns:
        Dictionary mapping each node to its proof depth.
    """
    depths: Dict[str, int] = {}
    current = set(seed)
    bound = len(system.nodes) + 1

    # Mark seed nodes as depth 0
    for v in seed:
        depths[v] = 0

    for step in range(1, len(system.nodes) + 1):
        next_set = step_closure(system, current)
        new_nodes = next_set - current
        for v in new_nodes:
            depths[v] = step
        if not new_nodes:
            break
        current = next_set

    # Mark unreachable nodes
    for v in system.nodes:
        if v not in depths:
            depths[v] = bound

    return depths


# === Factory functions for common system types ===

def make_diamond_system(n_prereqs: int = 4, n_targets: int = 6,
                        n_controls: int = 3) -> Tuple[FiniteResonanceSystem, Set[str], Set[str]]:
    """Create a diamond dependency system for testing.

    Creates arithmetic prerequisites a_0, ..., a_{n-1}, arithmetic targets
    t_0, ..., t_{m-1} (each depending on two distinct prerequisites), and
    control targets c_0, ..., c_{k-1} (with no dependencies).

    Returns:
        Tuple of (system, seed_set, arithmetic_package).
    """
    prereqs = [f"a_{i}" for i in range(n_prereqs)]
    targets = [f"t_{i}" for i in range(n_targets)]
    controls = [f"c_{i}" for i in range(n_controls)]

    nodes = set(prereqs + targets + controls)
    deps: Dict[str, Set[str]] = {}

    # Prerequisites have no dependencies
    for p in prereqs:
        deps[p] = set()

    # Each target depends on two different prerequisites
    target_idx = 0
    for i in range(n_prereqs):
        for j in range(i + 1, n_prereqs):
            if target_idx < n_targets:
                deps[targets[target_idx]] = {prereqs[i], prereqs[j]}
                target_idx += 1

    # Fill remaining targets if needed
    for k in range(target_idx, n_targets):
        deps[targets[k]] = {prereqs[k % n_prereqs], prereqs[(k + 1) % n_prereqs]}

    # Controls have no dependencies
    for c in controls:
        deps[c] = set()

    system = FiniteResonanceSystem(
        nodes=nodes,
        deps=deps,
        arithmetic=set(prereqs),
        target_arithmetic=set(targets),
        target_control=set(controls),
    )

    # Seed: just the controls (they're self-derivable)
    seed = set()
    package = set(prereqs)

    return system, seed, package


if __name__ == "__main__":
    # Quick self-test
    system, seed, package = make_diamond_system(4, 6, 3)

    print("=== Diamond System Test ===")
    print(f"Nodes: {len(system.nodes)}")
    print(f"Package: {package}")
    print(f"Seed: {seed}")

    result = detect_selective_resonance(system, seed, package)
    for k, v in result.items():
        print(f"  {k}: {v}")

    print(f"\nSynergy score: {synergy_score(system, seed, package, system.target_arithmetic)}")
    print(f"Bottleneck resonance: {detect_bottleneck_resonance(system, seed, package)}")
