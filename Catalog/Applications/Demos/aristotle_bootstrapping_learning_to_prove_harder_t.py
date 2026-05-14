#!/usr/bin/env python3
"""
Curriculum Complexity — Applications

Demonstrates real-world applications of curriculum complexity theory:
1. Research planning for mathematical proof libraries
2. Course design optimization
3. Automated theorem prover scheduling
4. Knowledge dependency analysis
"""

from algorithms import DependencySystem
from typing import Dict, List, Set


# ============================================================================
# Application 1: Research Library Planning
# ============================================================================

def research_library_planning():
    """
    Model a proof library's theorem dependencies and compute
    the optimal research schedule.

    Demonstrates how curriculum complexity theory guides the
    development of formal mathematical libraries.
    """
    print("=" * 60)
    print("Application 1: Research Library Planning")
    print("=" * 60)

    # Model a simplified commutative algebra library
    library = {
        "Ring Axioms": [],
        "Ideal Definition": ["Ring Axioms"],
        "Module Definition": ["Ring Axioms"],
        "Prime Ideal": ["Ideal Definition"],
        "Maximal Ideal": ["Ideal Definition"],
        "Quotient Ring": ["Ideal Definition"],
        "Noetherian Ring": ["Ideal Definition", "Module Definition"],
        "Localization": ["Ring Axioms", "Module Definition"],
        "Primary Decomposition": ["Prime Ideal", "Noetherian Ring"],
        "Krull Dimension": ["Prime Ideal"],
        "Hilbert Basis": ["Noetherian Ring"],
        "Nakayama Lemma": ["Module Definition", "Maximal Ideal"],
        "Going Up": ["Prime Ideal", "Localization"],
        "Krull's Principal Ideal": ["Krull Dimension", "Noetherian Ring"],
        "Dimension Theory": ["Krull's Principal Ideal", "Primary Decomposition"],
    }

    ds = DependencySystem(library)
    print(f"\nLibrary size: {len(ds.theorems)} theorems")
    print(f"Maximum dependency depth: {ds.max_level()}")
    print(f"Minimum sequential research cycles: {ds.max_level() + 1}")

    schedule = ds.parallel_schedule()
    print(f"\nOptimal parallel research schedule:")
    for stage in sorted(schedule):
        theorems = sorted(schedule[stage])
        print(f"  Cycle {stage + 1} (can be proved in parallel):")
        for t in theorems:
            print(f"    - {t}")

    frontier = {"Dimension Theory", "Hilbert Basis"}
    print(f"\nFrontier: {frontier}")
    print(f"Minimum cycles to reach frontier: {ds.frontier_depth(frontier) + 1}")

    # Show critical path
    for target in frontier:
        chain = ds.dependency_chain(target)
        print(f"Critical path to {target}:")
        print(f"  {' → '.join(chain)}")
    print()


# ============================================================================
# Application 2: Course Design Optimization
# ============================================================================

def course_design():
    """
    Optimize a mathematics course layout using curriculum complexity.

    The theory guarantees the minimum number of "lecture rounds"
    needed to cover all topics, where each round can teach topics
    whose prerequisites have been covered.
    """
    print("=" * 60)
    print("Application 2: Course Design Optimization")
    print("=" * 60)

    # An introductory analysis course
    course = {
        "Real Numbers": [],
        "Sequences": ["Real Numbers"],
        "Limits": ["Sequences"],
        "Continuity": ["Limits"],
        "Differentiation": ["Continuity"],
        "Riemann Integration": ["Continuity"],
        "Series": ["Sequences"],
        "Power Series": ["Series", "Differentiation"],
        "Uniform Convergence": ["Series", "Continuity"],
        "Taylor's Theorem": ["Power Series", "Differentiation"],
        "Fundamental Theorem": ["Differentiation", "Riemann Integration"],
        "Improper Integrals": ["Riemann Integration", "Limits"],
    }

    ds = DependencySystem(course)

    print(f"\nCourse: {len(ds.theorems)} topics")
    print(f"Minimum lecture weeks needed: {ds.max_level() + 1}")

    print("\nOptimal weekly schedule:")
    schedule = ds.parallel_schedule()
    for week in sorted(schedule):
        topics = sorted(schedule[week])
        print(f"  Week {week + 1}: {', '.join(topics)}")

    print("\nFull curriculum order:")
    for i, topic in enumerate(ds.curriculum()):
        print(f"  {i+1:2d}. {topic} (depth {ds.level(topic)})")
    print()


# ============================================================================
# Application 3: Automated Prover Scheduling
# ============================================================================

def prover_scheduling():
    """
    Schedule an automated theorem prover's work queue using
    curriculum complexity to minimize wall-clock time.

    Key insight: theorems at the same level can be attempted
    in parallel, but theorems at different levels must be
    sequential (each level may use results from prior levels).
    """
    print("=" * 60)
    print("Application 3: Automated Prover Scheduling")
    print("=" * 60)

    # Simulated proof obligations
    obligations = {
        "Lemma_base_1": [],
        "Lemma_base_2": [],
        "Lemma_base_3": [],
        "Lemma_combine_12": ["Lemma_base_1", "Lemma_base_2"],
        "Lemma_combine_23": ["Lemma_base_2", "Lemma_base_3"],
        "Theorem_A": ["Lemma_combine_12"],
        "Theorem_B": ["Lemma_combine_23"],
        "Main_Theorem": ["Theorem_A", "Theorem_B"],
    }

    ds = DependencySystem(obligations)

    print(f"\nProof obligations: {len(ds.theorems)}")
    print(f"Sequential depth: {ds.max_level()}")
    print(f"Minimum sequential rounds: {ds.max_level() + 1}")

    schedule = ds.parallel_schedule()
    print(f"\nParallel proving schedule:")
    total_parallel_work = 0
    for round_num in sorted(schedule):
        tasks = sorted(schedule[round_num])
        print(f"  Round {round_num + 1}: {tasks}")
        total_parallel_work += 1

    sequential_work = len(ds.theorems)
    print(f"\nSequential proofs needed: {sequential_work}")
    print(f"Parallel rounds needed: {total_parallel_work}")
    print(f"Speedup factor: {sequential_work / total_parallel_work:.1f}x")
    print()


# ============================================================================
# Application 4: Knowledge Dependency Analysis
# ============================================================================

def knowledge_analysis():
    """
    Analyze the knowledge structure of a mathematical domain
    to identify bottlenecks and critical dependencies.
    """
    print("=" * 60)
    print("Application 4: Knowledge Dependency Analysis")
    print("=" * 60)

    # A simplified machine learning theory dependency graph
    ml_theory = {
        "Linear Algebra Basics": [],
        "Probability Basics": [],
        "Calculus": [],
        "Convex Sets": ["Linear Algebra Basics"],
        "Gradient": ["Calculus", "Linear Algebra Basics"],
        "Expectation": ["Probability Basics", "Calculus"],
        "Convex Functions": ["Convex Sets", "Calculus"],
        "Gradient Descent": ["Gradient", "Convex Functions"],
        "Concentration Inequalities": ["Expectation"],
        "PAC Learning": ["Probability Basics", "Concentration Inequalities"],
        "VC Dimension": ["PAC Learning"],
        "Kernel Methods": ["Linear Algebra Basics", "Convex Functions"],
        "SVM Theory": ["Kernel Methods", "Convex Functions", "Gradient Descent"],
        "Generalization Bounds": ["VC Dimension", "Concentration Inequalities"],
        "Deep Learning Theory": ["Gradient Descent", "Generalization Bounds"],
    }

    ds = DependencySystem(ml_theory)

    print(f"\nDomain: ML Theory")
    print(f"Concepts: {len(ds.theorems)}")
    print(f"Maximum depth: {ds.max_level()}")

    # Find bottleneck concepts (most dependents)
    dependent_count = {}
    for t in ds.theorems:
        count = sum(1 for other in ds.theorems
                    if t in ds.deps.get(other, []))
        dependent_count[t] = count

    print("\nMost-depended-upon concepts (bottlenecks):")
    for t in sorted(dependent_count, key=lambda x: -dependent_count[x])[:5]:
        print(f"  {t}: {dependent_count[t]} direct dependents")

    # Find the longest critical path
    deepest = max(ds.theorems, key=lambda t: ds.level(t))
    chain = ds.dependency_chain(deepest)
    print(f"\nLongest critical path:")
    print(f"  {' → '.join(chain)}")
    print(f"  Length: {len(chain) - 1} (= level of {deepest})")

    # Frontier analysis
    frontier = {"Deep Learning Theory", "SVM Theory"}
    print(f"\nFrontier: {frontier}")
    print(f"  Minimum learning stages: {ds.frontier_depth(frontier) + 1}")
    for t in frontier:
        print(f"  Path to {t}: {' → '.join(ds.dependency_chain(t))}")
    print()


if __name__ == "__main__":
    research_library_planning()
    course_design()
    prover_scheduling()
    knowledge_analysis()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Curriculum Complexity of Mathematics — Demonstration

This script demonstrates the core theorems of curriculum complexity theory
with concrete examples of mathematical dependency systems.
"""

import json
from collections import defaultdict, deque
from typing import Dict, List, Set, Tuple, Optional


def compute_levels(deps: Dict[str, List[str]]) -> Dict[str, int]:
    """
    Compute the dependency depth (level) of each theorem in a dependency system.

    Level 0: theorems with no dependencies
    Level n+1: theorems whose deepest dependency has level n

    This is the minimum stage at which each theorem becomes provable.

    >>> deps = {"C": ["A", "B"], "B": ["A"], "A": []}
    >>> levels = compute_levels(deps)
    >>> levels == {"A": 0, "B": 1, "C": 2}
    True
    """
    # Build the set of all theorems
    all_theorems = set(deps.keys())
    for dep_list in deps.values():
        all_theorems.update(dep_list)

    # Ensure all theorems appear in deps
    for t in all_theorems:
        if t not in deps:
            deps[t] = []

    levels = {}

    def compute_level(t: str, visited: Set[str] = None) -> int:
        if t in levels:
            return levels[t]
        if visited is None:
            visited = set()
        if t in visited:
            raise ValueError(f"Cycle detected involving {t}")
        visited.add(t)

        if not deps[t]:
            levels[t] = 0
        else:
            levels[t] = max(compute_level(d, visited) for d in deps[t]) + 1
        return levels[t]

    for t in all_theorems:
        compute_level(t)
    return levels


def compute_stage_knowledge(deps: Dict[str, List[str]], max_stage: int = None) -> Dict[int, Set[str]]:
    """
    Compute the stage knowledge sets: stageKnowledge(n) for n = 0, 1, 2, ...

    Stage 0: theorems with no dependencies
    Stage n+1: theorems whose dependencies are all in stage n

    Returns a dict mapping stage number to the cumulative set of known theorems.

    >>> deps = {"C": ["A", "B"], "B": ["A"], "A": []}
    >>> stages = compute_stage_knowledge(deps)
    >>> stages[0] == {"A"}
    True
    >>> stages[1] == {"A", "B"}
    True
    >>> stages[2] == {"A", "B", "C"}
    True
    """
    all_theorems = set(deps.keys())
    for dep_list in deps.values():
        all_theorems.update(dep_list)
    for t in all_theorems:
        if t not in deps:
            deps[t] = []

    if max_stage is None:
        max_stage = len(all_theorems)

    stages = {}
    for n in range(max_stage + 1):
        if n == 0:
            stages[n] = {t for t in all_theorems if not deps[t]}
        else:
            stages[n] = {t for t in all_theorems
                         if all(d in stages[n-1] for d in deps[t])}
    return stages


def topological_sort(deps: Dict[str, List[str]]) -> List[str]:
    """
    Compute a valid curriculum (topological sort) for a dependency system.

    Returns a list where every theorem appears after all its dependencies.

    >>> deps = {"C": ["A", "B"], "B": ["A"], "A": []}
    >>> curriculum = topological_sort(deps)
    >>> curriculum.index("A") < curriculum.index("B") < curriculum.index("C")
    True
    """
    all_theorems = set(deps.keys())
    for dep_list in deps.values():
        all_theorems.update(dep_list)
    for t in all_theorems:
        if t not in deps:
            deps[t] = []

    levels = compute_levels(deps)
    return sorted(all_theorems, key=lambda t: levels[t])


def frontier_depth(deps: Dict[str, List[str]], frontier: Set[str]) -> int:
    """
    Compute the frontier depth: the minimum number of stages to cover all
    frontier theorems.

    >>> deps = {"C": ["A", "B"], "B": ["A"], "A": [], "D": []}
    >>> frontier_depth(deps, {"C", "D"})
    2
    """
    levels = compute_levels(deps)
    return max(levels[t] for t in frontier)


# ============================================================================
# Example 1: Linear Algebra Curriculum
# ============================================================================

def example_linear_algebra():
    """A simplified dependency graph for a linear algebra course."""
    deps = {
        "Vector Spaces": [],
        "Linear Maps": ["Vector Spaces"],
        "Matrix Algebra": ["Vector Spaces"],
        "Determinants": ["Matrix Algebra"],
        "Eigenvalues": ["Linear Maps", "Determinants"],
        "Spectral Theorem": ["Eigenvalues"],
        "Jordan Form": ["Eigenvalues", "Matrix Algebra"],
    }

    print("=" * 60)
    print("Example 1: Linear Algebra Curriculum")
    print("=" * 60)

    levels = compute_levels(deps)
    print("\nDependency Depths (Levels):")
    for t in sorted(levels, key=lambda x: levels[x]):
        print(f"  Level {levels[t]}: {t}")

    stages = compute_stage_knowledge(deps)
    print("\nStage Knowledge Growth:")
    prev = set()
    for n in sorted(stages):
        new = stages[n] - prev
        if new:
            print(f"  Stage {n}: +{new}")
            prev = stages[n]

    curriculum = topological_sort(deps)
    print(f"\nValid Curriculum: {curriculum}")

    frontier = {"Spectral Theorem", "Jordan Form"}
    fd = frontier_depth(deps, frontier)
    print(f"\nFrontier {frontier}")
    print(f"  Minimum stages to reach frontier: {fd}")
    print()


# ============================================================================
# Example 2: Number Theory Curriculum
# ============================================================================

def example_number_theory():
    """A dependency graph for foundational number theory."""
    deps = {
        "Natural Numbers": [],
        "Divisibility": ["Natural Numbers"],
        "Primes": ["Divisibility"],
        "GCD": ["Divisibility"],
        "Bezout's Identity": ["GCD"],
        "Fundamental Theorem of Arithmetic": ["Primes", "Bezout's Identity"],
        "Euler's Totient": ["Fundamental Theorem of Arithmetic"],
        "Fermat's Little Theorem": ["Euler's Totient"],
        "Quadratic Reciprocity": ["Primes", "Euler's Totient"],
    }

    print("=" * 60)
    print("Example 2: Number Theory Curriculum")
    print("=" * 60)

    levels = compute_levels(deps)
    print("\nDependency Depths (Levels):")
    for t in sorted(levels, key=lambda x: levels[x]):
        print(f"  Level {levels[t]}: {t}")

    curriculum = topological_sort(deps)
    print(f"\nValid Curriculum: {curriculum}")

    frontier = {"Fermat's Little Theorem", "Quadratic Reciprocity"}
    fd = frontier_depth(deps, frontier)
    print(f"\nFrontier {frontier}")
    print(f"  Minimum stages to reach frontier: {fd}")
    print()


# ============================================================================
# Example 3: Demonstrating strict stage growth
# ============================================================================

def example_strict_growth():
    """Demonstrate that each stage with new theorems strictly extends the previous."""
    deps = {
        "A1": [], "A2": [],
        "B1": ["A1"], "B2": ["A1", "A2"],
        "C1": ["B1", "B2"],
        "D1": ["C1"],
    }

    print("=" * 60)
    print("Example 3: Strict Stage Growth (Bootstrapping)")
    print("=" * 60)

    levels = compute_levels(deps)
    stages = compute_stage_knowledge(deps)

    print("\nStage-by-stage knowledge growth:")
    for n in sorted(stages):
        stage_set = stages[n]
        new = stage_set - (stages[n-1] if n > 0 else set())
        if new or n == 0:
            strict = "⊂" if new and n > 0 else "="
            print(f"  Stage {n}: {sorted(stage_set)} "
                  f"{'  (new: ' + str(sorted(new)) + ')' if new else ''}")

    print("\nVerification of strict inclusion:")
    for n in range(max(stages)):
        new_at_n1 = stages[n+1] - stages[n]
        if new_at_n1:
            print(f"  Stage {n} ⊂ Stage {n+1}  "
                  f"(new theorems at level {n+1}: {sorted(new_at_n1)})")
        else:
            print(f"  Stage {n} = Stage {n+1}  (stabilized)")
    print()


# ============================================================================
# Example 4: Stabilization
# ============================================================================

def example_stabilization():
    """Show that stage knowledge stabilizes to the full set."""
    deps = {
        "T1": [], "T2": [],
        "T3": ["T1"],
        "T4": ["T2", "T3"],
        "T5": ["T4"],
    }

    print("=" * 60)
    print("Example 4: Knowledge Stabilization")
    print("=" * 60)

    all_theorems = set(deps.keys())
    stages = compute_stage_knowledge(deps, max_stage=10)

    print(f"\nTotal theorems: {len(all_theorems)}")
    for n in sorted(stages):
        complete = stages[n] == all_theorems
        print(f"  Stage {n}: {len(stages[n])}/{len(all_theorems)} theorems"
              f"{'  ✓ COMPLETE' if complete else ''}")
        if complete and n > 0 and stages[n-1] == all_theorems:
            print(f"  (Stabilized at stage {n-1})")
            break
    print()


if __name__ == "__main__":
    example_linear_algebra()
    example_number_theory()
    example_strict_growth()
    example_stabilization()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Curriculum Complexity — Visualizations

Generates figures illustrating the key concepts and theorems
of curriculum complexity theory.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import DependencySystem
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def visualize_stage_growth():
    """Visualize the monotone growth of stage knowledge."""
    deps = {
        "T1": [], "T2": [],
        "T3": ["T1"], "T4": ["T2"],
        "T5": ["T1", "T2"],
        "T6": ["T3", "T4"],
        "T7": ["T5", "T6"],
        "T8": ["T7"],
    }

    ds = DependencySystem(deps)
    max_stage = ds.max_level()

    stages = []
    for n in range(max_stage + 2):
        stages.append(len(ds.stage_knowledge(n)))

    fig, ax = plt.subplots(figsize=(10, 6))

    # Bar chart of cumulative knowledge
    x = range(len(stages))
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(stages)))
    bars = ax.bar(x, stages, color=colors, edgecolor='black', linewidth=0.5)

    # Add horizontal line for total
    ax.axhline(y=len(ds.theorems), color='red', linestyle='--',
               label=f'Total theorems = {len(ds.theorems)}', alpha=0.7)

    ax.set_xlabel('Stage n', fontsize=14)
    ax.set_ylabel('|stageKnowledge(n)|', fontsize=14)
    ax.set_title('Monotone Growth of Stage Knowledge\n(Stabilization Theorem)', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_xticks(x)

    # Annotate strict growth
    for i in range(1, len(stages)):
        if stages[i] > stages[i-1]:
            ax.annotate('⊂', xy=(i-0.5, (stages[i-1] + stages[i])/2),
                        fontsize=16, ha='center', color='green', fontweight='bold')

    plt.tight_layout()
    fig.savefig('/workspace/request-project/stage_growth.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def visualize_level_distribution():
    """Visualize the distribution of theorem levels in a dependency system."""
    deps = {
        "Ring Axioms": [],
        "Ideal Definition": ["Ring Axioms"],
        "Module Definition": ["Ring Axioms"],
        "Prime Ideal": ["Ideal Definition"],
        "Maximal Ideal": ["Ideal Definition"],
        "Quotient Ring": ["Ideal Definition"],
        "Noetherian Ring": ["Ideal Definition", "Module Definition"],
        "Localization": ["Ring Axioms", "Module Definition"],
        "Primary Decomposition": ["Prime Ideal", "Noetherian Ring"],
        "Krull Dimension": ["Prime Ideal"],
        "Hilbert Basis": ["Noetherian Ring"],
        "Nakayama Lemma": ["Module Definition", "Maximal Ideal"],
        "Going Up": ["Prime Ideal", "Localization"],
        "Krull's Principal Ideal": ["Krull Dimension", "Noetherian Ring"],
        "Dimension Theory": ["Krull's Principal Ideal", "Primary Decomposition"],
    }

    ds = DependencySystem(deps)

    # Count theorems at each level
    level_counts = {}
    for t in ds.theorems:
        lvl = ds.level(t)
        level_counts[lvl] = level_counts.get(lvl, 0) + 1

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Level histogram
    levels = sorted(level_counts.keys())
    counts = [level_counts[l] for l in levels]
    colors = plt.cm.RdYlGn_r(np.linspace(0.1, 0.9, len(levels)))
    ax1.bar(levels, counts, color=colors, edgecolor='black')
    ax1.set_xlabel('Dependency Depth (Level)', fontsize=13)
    ax1.set_ylabel('Number of Theorems', fontsize=13)
    ax1.set_title('Level Distribution\n(Commutative Algebra Library)', fontsize=14)
    ax1.set_xticks(levels)

    # Right: Parallel schedule timeline
    schedule = ds.parallel_schedule()
    y_pos = 0
    yticks = []
    ylabels = []
    for stage in sorted(schedule):
        theorems = sorted(schedule[stage])
        for t in theorems:
            ax2.barh(y_pos, 1, left=stage, height=0.7, color=colors[stage],
                     edgecolor='black', linewidth=0.5)
            ax2.text(stage + 0.5, y_pos, t, ha='center', va='center', fontsize=7)
            yticks.append(y_pos)
            ylabels.append('')
            y_pos += 1

    ax2.set_xlabel('Research Cycle', fontsize=13)
    ax2.set_title('Optimal Parallel Schedule', fontsize=14)
    ax2.set_yticks([])

    plt.tight_layout()
    fig.savefig('/workspace/request-project/level_distribution.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def visualize_frontier_optimality():
    """Visualize frontier depth and optimality."""
    deps = {
        "A": [], "B": [], "C": [],
        "D": ["A", "B"], "E": ["B", "C"],
        "F": ["D"], "G": ["D", "E"],
        "H": ["F", "G"],
    }

    ds = DependencySystem(deps)

    # Show multiple frontiers and their depths
    frontiers = [
        {"A", "B", "C"},
        {"D", "E"},
        {"F", "G"},
        {"H"},
        {"F", "H"},
    ]

    fig, ax = plt.subplots(figsize=(10, 6))

    frontier_labels = []
    frontier_depths = []
    for f in frontiers:
        label = ", ".join(sorted(f))
        depth = ds.frontier_depth(f)
        frontier_labels.append(f"{{{label}}}")
        frontier_depths.append(depth)

    colors = plt.cm.plasma(np.linspace(0.2, 0.8, len(frontiers)))
    bars = ax.barh(range(len(frontiers)), frontier_depths, color=colors,
                   edgecolor='black', linewidth=0.5)

    ax.set_yticks(range(len(frontiers)))
    ax.set_yticklabels(frontier_labels, fontsize=11)
    ax.set_xlabel('Frontier Depth (max level)', fontsize=13)
    ax.set_title('Frontier Optimality Theorem\nMinimum stages = max level over frontier', fontsize=14)

    # Annotate with exact values
    for i, (bar, depth) in enumerate(zip(bars, frontier_depths)):
        ax.text(depth + 0.05, i, f'{depth}', va='center', fontsize=12, fontweight='bold')

    ax.set_xlim(0, max(frontier_depths) + 0.5)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/frontier_optimality.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def visualize_dag():
    """Visualize a dependency DAG with level coloring."""
    deps = {
        "Axioms": [],
        "Groups": ["Axioms"],
        "Rings": ["Groups"],
        "Modules": ["Rings", "Groups"],
        "Fields": ["Rings"],
        "Galois": ["Fields", "Groups"],
        "Homological": ["Modules"],
    }

    ds = DependencySystem(deps)

    # Manual layout by level
    positions = {
        "Axioms": (3, 0),
        "Groups": (2, 1),
        "Rings": (4, 2),
        "Modules": (2, 3),
        "Fields": (5, 3),
        "Galois": (4, 4),
        "Homological": (1, 4),
    }

    fig, ax = plt.subplots(figsize=(10, 8))

    # Color by level
    max_level = ds.max_level()
    cmap = plt.cm.RdYlGn_r

    # Draw edges
    for t, dep_list in deps.items():
        for d in dep_list:
            x1, y1 = positions[d]
            x2, y2 = positions[t]
            ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                        arrowprops=dict(arrowstyle="->", color="gray",
                                        connectionstyle="arc3,rad=0.1",
                                        lw=1.5))

    # Draw nodes
    for t, (x, y) in positions.items():
        level = ds.level(t)
        color = cmap(level / max(max_level, 1))
        circle = plt.Circle((x, y), 0.35, color=color, ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, t, ha='center', va='center', fontsize=8,
                fontweight='bold', zorder=6)
        ax.text(x + 0.4, y + 0.3, f'L{level}', fontsize=9, color='blue',
                fontweight='bold', zorder=6)

    ax.set_xlim(-0.5, 7)
    ax.set_ylim(-0.5, 5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Theorem Dependency DAG\n(colored by level)', fontsize=16)

    # Legend
    for i in range(max_level + 1):
        ax.add_patch(mpatches.Rectangle((6, 4 - i * 0.5), 0.3, 0.3,
                                        color=cmap(i / max(max_level, 1)),
                                        ec='black'))
        ax.text(6.5, 4 - i * 0.5 + 0.15, f'Level {i}', fontsize=10, va='center')

    plt.tight_layout()
    fig.savefig('/workspace/request-project/dependency_dag.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1 = visualize_stage_growth()
    print("  ✓ Stage growth visualization")

    b64_2 = visualize_level_distribution()
    print("  ✓ Level distribution visualization")

    b64_3 = visualize_frontier_optimality()
    print("  ✓ Frontier optimality visualization")

    b64_4 = visualize_dag()
    print("  ✓ Dependency DAG visualization")

    print("\nAll visualizations saved as PNG files.")

    # Store base64 data for PACKAGE.json
    import json
    viz_data = {
        "stage_growth": b64_1,
        "level_distribution": b64_2,
        "frontier_optimality": b64_3,
        "dependency_dag": b64_4,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 data saved to viz_data.json")
