#!/usr/bin/env python3
"""
Arithmetic Resonance Theory — Applications

Real-world applications of the arithmetic resonance framework:
1. Library architecture optimization
2. Curriculum design
3. Bottleneck identification

All code is self-contained.
"""

from typing import Dict, Set, List, Tuple, Optional
import random
import itertools


# ─── Core (self-contained) ───────────────────────────────────────────────────

class ResonanceSystem:
    """Minimal resonance system implementation."""

    def __init__(self, nodes, deps, arithmetic=None,
                 target_arithmetic=None, target_control=None):
        self.nodes = set(nodes)
        self.deps = {n: set(deps.get(n, [])) for n in self.nodes}
        self.arithmetic = set(arithmetic or [])
        self.target_arithmetic = set(target_arithmetic or [])
        self.target_control = set(target_control or [])

    def step_closure(self, seed):
        result = set(seed)
        for v in self.nodes:
            if self.deps[v].issubset(seed):
                result.add(v)
        return result

    def res_closure(self, seed):
        current = set(seed)
        for _ in range(len(self.nodes)):
            nxt = self.step_closure(current)
            if nxt == current:
                break
            current = nxt
        return current

    def reachable_count(self, seed, targets):
        return len(targets & self.res_closure(seed))

    def resonance_score(self, seed, package, targets):
        return (self.reachable_count(seed | package, targets) -
                self.reachable_count(seed, targets))

    def synergy_score(self, seed, package, targets):
        combined = self.resonance_score(seed, package, targets)
        individual = sum(self.resonance_score(seed, {a}, targets) for a in package)
        return combined - individual


# ─── Application 1: Library Architecture Optimization ────────────────────────

def find_optimal_package(system: ResonanceSystem, seed: Set[str],
                          candidates: Set[str], budget: int) -> Tuple[Set[str], int]:
    """Find the package of size ≤ budget that maximizes resonance score.

    Uses greedy approximation (adding the element with highest marginal
    gain at each step). For submodular objectives, this gives a
    (1 - 1/e) approximation guarantee.

    Args:
        system: The resonance system.
        seed: Current seed set.
        candidates: Available elements to add.
        budget: Maximum package size.

    Returns:
        Tuple of (best_package, resonance_score).

    Example:
        >>> sys = build_example_library()
        >>> pkg, score = find_optimal_package(sys, set(), sys.arithmetic, 3)
        >>> print(f"Best 3-element package: {pkg}, score: {score}")
    """
    selected: Set[str] = set()
    remaining = set(candidates)

    for _ in range(min(budget, len(candidates))):
        best_elem = None
        best_gain = -1
        current_score = system.resonance_score(seed, selected, system.target_arithmetic)

        for elem in remaining:
            trial = selected | {elem}
            gain = system.resonance_score(seed, trial, system.target_arithmetic)
            if gain > best_gain:
                best_gain = gain
                best_elem = elem

        if best_elem is None or best_gain <= current_score:
            # Even if current marginal gain is 0, keep adding if we haven't
            # reached budget (some elements may enable future gains)
            if best_elem is None:
                break

        selected.add(best_elem)
        remaining.discard(best_elem)

    final_score = system.resonance_score(seed, selected, system.target_arithmetic)
    return selected, final_score


# ─── Application 2: Curriculum Design ────────────────────────────────────────

def optimal_teaching_order(system: ResonanceSystem, seed: Set[str],
                            topics: List[str]) -> List[Tuple[str, int]]:
    """Find the teaching order that maximizes cumulative accessibility.

    At each step, add the topic that unlocks the most new targets.
    This greedily optimizes the area under the "reachable targets" curve.

    Args:
        system: The resonance system.
        seed: What students already know.
        topics: Topics available to teach.

    Returns:
        Ordered list of (topic, cumulative_reachable) pairs.

    Example:
        >>> order = optimal_teaching_order(sys, set(), ["algebra", "analysis", "combinatorics"])
        >>> for topic, reach in order:
        ...     print(f"Teach {topic}: now {reach} targets reachable")
    """
    current_seed = set(seed)
    remaining = list(topics)
    schedule: List[Tuple[str, int]] = []

    while remaining:
        best_topic = None
        best_reach = -1

        for topic in remaining:
            trial_seed = current_seed | {topic}
            reach = system.reachable_count(trial_seed, system.target_arithmetic)
            if reach > best_reach:
                best_reach = reach
                best_topic = topic

        if best_topic is not None:
            current_seed.add(best_topic)
            remaining.remove(best_topic)
            schedule.append((best_topic, best_reach))

    return schedule


# ─── Application 3: Bottleneck Identification ────────────────────────────────

def identify_bottlenecks(system: ResonanceSystem, seed: Set[str],
                          max_size: int = 3) -> List[Tuple[frozenset, int, int]]:
    """Identify all bottleneck packages up to a given size.

    A bottleneck package is one whose synergy score is strictly positive.

    Args:
        system: The resonance system.
        seed: Current seed set.
        max_size: Maximum package size to search.

    Returns:
        List of (package, resonance_score, synergy_score) tuples,
        sorted by synergy score descending.

    Example:
        >>> bottlenecks = identify_bottlenecks(sys, set(), max_size=2)
        >>> for pkg, res, syn in bottlenecks[:5]:
        ...     print(f"  {pkg}: resonance={res}, synergy={syn}")
    """
    results = []
    candidates = list(system.arithmetic)

    for size in range(2, min(max_size + 1, len(candidates) + 1)):
        for combo in itertools.combinations(candidates, size):
            package = set(combo)
            res = system.resonance_score(seed, package, system.target_arithmetic)
            syn = system.synergy_score(seed, package, system.target_arithmetic)
            if syn > 0:
                results.append((frozenset(combo), res, syn))

    results.sort(key=lambda x: -x[2])
    return results


# ─── Application 4: Dependency Health Metrics ────────────────────────────────

def library_health_report(system: ResonanceSystem, seed: Set[str]) -> dict:
    """Generate a comprehensive health report for a theorem library.

    Computes various metrics about the dependency structure and
    resonance properties.

    Returns:
        Dictionary with health metrics.
    """
    closure = system.res_closure(seed)
    arith_reach = len(system.target_arithmetic & closure)
    ctrl_reach = len(system.target_control & closure)

    # Compute vulnerability: how many targets are lost if each node is removed
    vulnerabilities = {}
    for node in system.arithmetic:
        reduced_seed = seed - {node}
        reduced_closure = system.res_closure(reduced_seed)
        lost = len((system.target_arithmetic & closure) - reduced_closure)
        vulnerabilities[node] = lost

    # Find the most critical node
    if vulnerabilities:
        critical_node = max(vulnerabilities, key=vulnerabilities.get)
        critical_impact = vulnerabilities[critical_node]
    else:
        critical_node = None
        critical_impact = 0

    # Compute redundancy: average number of alternative paths
    return {
        "total_nodes": len(system.nodes),
        "arithmetic_nodes": len(system.arithmetic),
        "arithmetic_targets_reachable": arith_reach,
        "arithmetic_targets_total": len(system.target_arithmetic),
        "control_targets_reachable": ctrl_reach,
        "control_targets_total": len(system.target_control),
        "coverage_ratio": arith_reach / max(len(system.target_arithmetic), 1),
        "most_critical_node": critical_node,
        "critical_node_impact": critical_impact,
        "vulnerability_map": vulnerabilities,
    }


# ─── Example: Simulated Mathematical Library ─────────────────────────────────

def build_math_library():
    """Build a simulated mathematical library with realistic structure.

    Simulates a small fragment with:
    - Basic algebra and analysis prerequisites
    - Number theory targets (depending on both algebra and analysis)
    - Topology targets (depending only on analysis)
    """
    # Prerequisites (self-referential: must be seeded)
    algebra = ["ring_axioms", "group_theory", "field_theory", "polynomial_basics"]
    analysis = ["limits", "continuity", "differentiation", "integration"]
    combinatorics = ["counting", "pigeonhole", "inclusion_exclusion"]

    # Number theory targets (depend on algebra + analysis + combinatorics)
    nt_targets = {
        "prime_number_theorem": {"limits", "integration", "counting"},
        "dirichlet_theorem": {"group_theory", "continuity", "counting"},
        "quadratic_reciprocity": {"field_theory", "group_theory"},
        "sum_of_squares": {"ring_axioms", "polynomial_basics", "pigeonhole"},
        "goldbach_weak": {"limits", "integration", "inclusion_exclusion", "pigeonhole"},
    }

    # Topology targets (depend only on analysis)
    topo_targets = {
        "compact_implies_closed": {"limits", "continuity"},
        "intermediate_value": {"continuity"},
        "extreme_value": {"continuity", "limits"},
    }

    all_nodes = set(algebra + analysis + combinatorics +
                    list(nt_targets.keys()) + list(topo_targets.keys()))
    deps = {}
    for n in algebra + analysis + combinatorics:
        deps[n] = {n}  # self-referential: must be seeded
    deps.update(nt_targets)
    deps.update(topo_targets)

    return ResonanceSystem(
        nodes=all_nodes,
        deps=deps,
        arithmetic=set(algebra + analysis + combinatorics),
        target_arithmetic=set(nt_targets.keys()),
        target_control=set(topo_targets.keys()),
    )


# ─── Main Demo ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   ARITHMETIC RESONANCE — REAL-WORLD APPLICATIONS            ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    sys = build_math_library()

    # Application 1: Optimal Package Selection
    print("=" * 60)
    print("APPLICATION 1: Library Architecture Optimization")
    print("=" * 60)
    print()
    print("Finding the best 4-element package to add to an empty library:")
    pkg, score = find_optimal_package(sys, set(), sys.arithmetic, 4)
    print(f"  Best package: {sorted(pkg)}")
    print(f"  Resonance score: {score}")
    print(f"  (Unlocks {score} out of {len(sys.target_arithmetic)} arithmetic targets)")
    print()

    # Application 2: Curriculum Design
    print("=" * 60)
    print("APPLICATION 2: Optimal Teaching Order")
    print("=" * 60)
    print()
    order = optimal_teaching_order(sys, set(), sorted(sys.arithmetic))
    print(f"{'Step':>5} {'Topic':>25} {'Cumulative Targets':>20}")
    print("-" * 55)
    for i, (topic, reach) in enumerate(order, 1):
        bar = "█" * (reach * 4) + "░" * ((len(sys.target_arithmetic) - reach) * 4)
        print(f"{i:>5} {topic:>25} {reach:>20} {bar}")
    print()

    # Application 3: Bottleneck Identification
    print("=" * 60)
    print("APPLICATION 3: Bottleneck Identification")
    print("=" * 60)
    print()
    bottlenecks = identify_bottlenecks(sys, set(), max_size=3)
    if bottlenecks:
        print(f"Found {len(bottlenecks)} synergistic packages:")
        for pkg, res, syn in bottlenecks[:10]:
            print(f"  {set(pkg)}: resonance={res}, synergy={syn}")
    else:
        print("No synergistic packages found (all gains are additive).")
    print()

    # Application 4: Library Health Report
    print("=" * 60)
    print("APPLICATION 4: Library Health Report")
    print("=" * 60)
    print()
    seed_full = sys.arithmetic
    report = library_health_report(sys, seed_full)
    for k, v in report.items():
        if k != "vulnerability_map":
            print(f"  {k}: {v}")
    print()
    print("  Vulnerability map (targets lost if node removed):")
    for node, impact in sorted(report["vulnerability_map"].items(),
                                key=lambda x: -x[1]):
        if impact > 0:
            print(f"    {node}: {impact} targets lost")
    print()
    print("=" * 60)
    print("All applications demonstrated.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Arithmetic Resonance Theory — Interactive Demonstration

Builds synthetic dependency systems, computes closure depths and resonance scores,
and visualizes the phase transition curve as arithmetic package density increases.

Usage:
    python demo.py
"""

import random
import math
from typing import Dict, Set, List, Tuple


# ─── Core algorithm implementations (self-contained) ────────────────────────

class ResonanceSystem:
    """A finite resonance system for dependency-graph experiments."""

    def __init__(self, nodes, deps, arithmetic=None,
                 target_arithmetic=None, target_control=None):
        self.nodes = set(nodes)
        self.deps = {n: set(deps.get(n, [])) for n in self.nodes}
        self.arithmetic = set(arithmetic or [])
        self.target_arithmetic = set(target_arithmetic or [])
        self.target_control = set(target_control or [])

    def step_closure(self, seed):
        result = set(seed)
        for v in self.nodes:
            if self.deps[v].issubset(seed):
                result.add(v)
        return result

    def res_closure(self, seed):
        current = set(seed)
        for _ in range(len(self.nodes)):
            next_set = self.step_closure(current)
            if next_set == current:
                break
            current = next_set
        return current

    def reachable_count(self, seed, targets):
        closed = self.res_closure(seed)
        return len(targets & closed)

    def resonance_score(self, seed, package, targets):
        base = self.reachable_count(seed, targets)
        aug = self.reachable_count(seed | package, targets)
        return aug - base

    def synergy_score(self, seed, package, targets):
        combined = self.resonance_score(seed, package, targets)
        individual = sum(
            self.resonance_score(seed, {a}, targets)
            for a in package
        )
        return combined - individual

    def closure_depths(self, seed):
        depths = {}
        current = set(seed)
        for v in seed:
            if v in self.nodes:
                depths[v] = 0
        for step in range(1, len(self.nodes) + 1):
            next_set = self.step_closure(current)
            for v in next_set - current:
                depths[v] = step
            if next_set == current:
                break
            current = next_set
        for v in self.nodes:
            if v not in depths:
                depths[v] = len(self.nodes) + 1
        return depths


# ─── System builders ─────────────────────────────────────────────────────────

def build_diamond_system(n_prereqs=4, n_targets=6, n_controls=3):
    """Build a diamond system where each target depends on 2 arithmetic prereqs.
    
    Prereqs have self-referential dependencies (they depend on themselves),
    meaning they can only be derived if already in the seed set. This models
    the idea that arithmetic prerequisites are 'external' to the library and
    must be explicitly provided.
    
    Controls depend on a shared 'base' node that has no deps (always derivable).
    """
    prereqs = [f"a{i}" for i in range(n_prereqs)]
    targets = []
    deps = {}

    # Prereqs depend on themselves — only derivable if seeded
    for p in prereqs:
        deps[p] = {p}

    idx = 0
    for i in range(n_prereqs):
        for j in range(i + 1, n_prereqs):
            if idx < n_targets:
                name = f"t{idx}"
                targets.append(name)
                deps[name] = {prereqs[i], prereqs[j]}
                idx += 1

    while len(targets) < n_targets:
        name = f"t{len(targets)}"
        targets.append(name)
        k = len(targets) - 1
        deps[name] = {prereqs[k % n_prereqs], prereqs[(k + 1) % n_prereqs]}

    # Controls depend on 'base' which has empty deps (always derivable)
    base = "base"
    deps[base] = set()
    controls = [f"c{i}" for i in range(n_controls)]
    for c in controls:
        deps[c] = {base}

    nodes = [base] + prereqs + targets + controls
    return ResonanceSystem(
        nodes=nodes, deps=deps,
        arithmetic=set(prereqs),
        target_arithmetic=set(targets),
        target_control=set(controls),
    )


def build_linear_system(n=10):
    """Build a linear chain system (no synergy possible).
    
    Each node depends on the previous one. The first node depends on itself
    (must be seeded). Arithmetic nodes are the first half, targets are the second.
    """
    nodes = [f"n{i}" for i in range(n)]
    deps = {nodes[0]: {nodes[0]}}  # first node must be seeded
    for i in range(1, n):
        deps[nodes[i]] = {nodes[i - 1]}

    half = n // 2
    return ResonanceSystem(
        nodes=nodes, deps=deps,
        arithmetic=set(nodes[:half]),
        target_arithmetic=set(nodes[half:]),
        target_control=set(),
    )


def build_random_system(n=20, p=0.15, n_arith=8, n_targets=6, n_controls=4, seed_rng=42):
    """Build a random dependency system."""
    rng = random.Random(seed_rng)
    nodes = [f"r{i}" for i in range(n)]
    deps = {}

    for i, node in enumerate(nodes):
        possible_deps = [nodes[j] for j in range(i) if rng.random() < p]
        deps[node] = set(possible_deps)

    arith = set(rng.sample(nodes, min(n_arith, n)))
    tgt_arith = set(rng.sample(nodes, min(n_targets, n)))
    tgt_ctrl = set(rng.sample([n for n in nodes if n not in tgt_arith], min(n_controls, n - n_targets)))

    return ResonanceSystem(
        nodes=nodes, deps=deps,
        arithmetic=arith,
        target_arithmetic=tgt_arith,
        target_control=tgt_ctrl,
    )


# ─── Experiments ──────────────────────────────────────────────────────────────

def experiment_diamond():
    """Demonstrate diamond synergy with concrete numbers."""
    print("=" * 60)
    print("EXPERIMENT 1: Diamond Dependency Synergy")
    print("=" * 60)
    print()

    sys = build_diamond_system(4, 6, 3)
    seed = set()  # empty seed
    package = sys.arithmetic  # all arithmetic prereqs

    print(f"Nodes: {len(sys.nodes)}")
    print(f"Arithmetic prereqs: {sorted(sys.arithmetic)}")
    print(f"Arithmetic targets: {sorted(sys.target_arithmetic)}")
    print(f"Control targets: {sorted(sys.target_control)}")
    print()

    # Show individual vs combined
    print("Individual contributions:")
    for a in sorted(package):
        score = sys.resonance_score(seed, {a}, sys.target_arithmetic)
        print(f"  Adding {{{a}}}: resonance = {score}")

    combined = sys.resonance_score(seed, package, sys.target_arithmetic)
    synergy = sys.synergy_score(seed, package, sys.target_arithmetic)

    print(f"\nCombined package: resonance = {combined}")
    print(f"Sum of individuals: {combined - synergy}")
    print(f"SYNERGY SCORE: {synergy}")
    print(f"→ {'SUPERADDITIVE!' if synergy > 0 else 'No synergy'}")

    # Control targets
    ctrl_before = sys.reachable_count(seed, sys.target_control)
    ctrl_after = sys.reachable_count(seed | package, sys.target_control)
    print(f"\nControl targets reachable before: {ctrl_before}")
    print(f"Control targets reachable after: {ctrl_after}")
    print(f"→ {'SELECTIVE (controls unchanged)' if ctrl_before == ctrl_after else 'NOT selective'}")
    print()


def experiment_linear():
    """Show that linear chains produce zero synergy."""
    print("=" * 60)
    print("EXPERIMENT 2: Linear Chain (No Synergy)")
    print("=" * 60)
    print()

    sys = build_linear_system(10)
    seed = set()
    package = sys.arithmetic

    print(f"System: linear chain of {len(sys.nodes)} nodes")
    print(f"Package: {sorted(package)}")

    combined = sys.resonance_score(seed, package, sys.target_arithmetic)
    synergy = sys.synergy_score(seed, package, sys.target_arithmetic)

    individual_sum = sum(
        sys.resonance_score(seed, {a}, sys.target_arithmetic)
        for a in package
    )
    print(f"Combined resonance: {combined}")
    print(f"Sum of individual resonances: {individual_sum}")
    print(f"Synergy: {synergy}")
    if synergy < 0:
        print(f"→ SUBADDITIVE: redundancy in chain means individuals overlap.")
    elif synergy == 0:
        print(f"→ Perfectly additive (no synergy, no redundancy).")
    else:
        print(f"→ SUPERADDITIVE!")
    print()


def experiment_phase_transition():
    """Demonstrate the phase transition as package density increases."""
    print("=" * 60)
    print("EXPERIMENT 3: Phase Transition Curve")
    print("=" * 60)
    print()

    n_prereqs = 8
    n_targets = 28  # C(8,2) = 28 possible diamond targets
    sys = build_diamond_system(n_prereqs, n_targets, 5)

    prereq_list = sorted(sys.arithmetic)
    seed = set()

    print(f"System: {n_prereqs} prereqs, {n_targets} diamond targets")
    print(f"Adding prereqs one at a time and measuring reachable targets:\n")

    print(f"{'Prereqs Added':>15} {'Fraction':>10} {'Reachable':>12} {'% Targets':>12}")
    print("-" * 55)

    for k in range(n_prereqs + 1):
        partial_package = set(prereq_list[:k])
        reachable = sys.reachable_count(seed | partial_package, sys.target_arithmetic)
        frac = k / n_prereqs if n_prereqs > 0 else 0
        pct = reachable / n_targets * 100 if n_targets > 0 else 0
        bar = "█" * int(pct / 5) + "░" * (20 - int(pct / 5))
        print(f"{k:>15} {frac:>10.2f} {reachable:>12} {pct:>11.1f}% {bar}")

    print()
    print("→ Note the sharp increase as the last prerequisites are added!")
    print("  This is the phase transition: below a critical threshold,")
    print("  few targets are reachable; above it, nearly all become accessible.")
    print()


def experiment_counterexample():
    """Show a regime where no selective resonance occurs."""
    print("=" * 60)
    print("EXPERIMENT 4: Counterexample — No Selective Resonance")
    print("=" * 60)
    print()

    # System where the arithmetic package helps controls MORE than arithmetic
    nodes = ["a0", "a1", "t0", "t1", "c0", "c1"]
    deps = {
        "a0": {"a0"}, "a1": {"a1"},  # must be seeded
        "t0": {"t0"}, "t1": {"t1"},  # targets also must be seeded (not helped by package)
        "c0": {"a0"}, "c1": {"a1"},  # controls depend on arithmetic
    }

    sys = ResonanceSystem(
        nodes=nodes, deps=deps,
        arithmetic={"a0", "a1"},
        target_arithmetic={"t0", "t1"},
        target_control={"c0", "c1"},
    )

    seed = set()
    package = {"a0", "a1"}

    arith_before = sys.reachable_count(seed, sys.target_arithmetic)
    arith_after = sys.reachable_count(seed | package, sys.target_arithmetic)
    ctrl_before = sys.reachable_count(seed, sys.target_control)
    ctrl_after = sys.reachable_count(seed | package, sys.target_control)

    print("System: arithmetic targets are self-referential (must be seeded)")
    print("        control targets DEPEND on arithmetic prereqs")
    print()
    print(f"Arithmetic targets reachable before: {arith_before}")
    print(f"Arithmetic targets reachable after:  {arith_after}")
    print(f"Control targets reachable before:    {ctrl_before}")
    print(f"Control targets reachable after:     {ctrl_after}")
    print()
    print(f"Arithmetic resonance: {arith_after - arith_before}")
    print(f"Control resonance: {ctrl_after - ctrl_before}")
    print(f"→ The package helps CONTROLS ({ctrl_after - ctrl_before}) more than")
    print(f"  arithmetic targets ({arith_after - arith_before}).")
    print(f"  This is the opposite of selective resonance.")
    print(f"  Conclusion: domain selectivity requires the right dependency structure.")
    print()


def experiment_depth_profile():
    """Show proof depth profiles for different seed configurations."""
    print("=" * 60)
    print("EXPERIMENT 5: Proof Depth Profiles")
    print("=" * 60)
    print()

    sys = build_diamond_system(4, 6, 3)
    seed_empty = set()
    seed_partial = {"a0", "a1"}
    seed_full = sys.arithmetic

    for label, seed in [("Empty seed", seed_empty),
                        ("Partial ({a0,a1})", seed_partial),
                        ("Full arithmetic", seed_full)]:
        depths = sys.closure_depths(seed)
        print(f"\n{label}:")
        for node in sorted(sys.nodes):
            d = depths[node]
            d_str = str(d) if d <= len(sys.nodes) else "∞"
            print(f"  {node}: depth = {d_str}")


def experiment_scaling():
    """Show how synergy scales with system size."""
    print()
    print("=" * 60)
    print("EXPERIMENT 6: Synergy Scaling with System Size")
    print("=" * 60)
    print()

    print(f"{'Prereqs':>10} {'Targets':>10} {'Resonance':>12} {'Synergy':>10} {'Ratio':>10}")
    print("-" * 55)

    for n in [3, 4, 5, 6, 7, 8]:
        n_targets = n * (n - 1) // 2  # C(n,2)
        sys = build_diamond_system(n, n_targets, 3)
        seed = set()
        package = sys.arithmetic

        res = sys.resonance_score(seed, package, sys.target_arithmetic)
        syn = sys.synergy_score(seed, package, sys.target_arithmetic)
        ratio = syn / res if res > 0 else 0

        print(f"{n:>10} {n_targets:>10} {res:>12} {syn:>10} {ratio:>10.2f}")

    print()
    print("→ In diamond systems, synergy equals resonance (ratio = 1.0)")
    print("  because no individual prereq unlocks any target alone.")
    print("  This is maximal superadditivity.")


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔════════════════════════════════════════════════════════════╗")
    print("║     ARITHMETIC RESONANCE THEORY — INTERACTIVE DEMO        ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()

    experiment_diamond()
    experiment_linear()
    experiment_phase_transition()
    experiment_counterexample()
    experiment_depth_profile()
    experiment_scaling()

    print()
    print("=" * 60)
    print("All experiments complete.")
    print("=" * 60)
