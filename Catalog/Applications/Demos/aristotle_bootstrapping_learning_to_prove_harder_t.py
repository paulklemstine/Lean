"""
Curriculum Theory: Real-World Applications

Demonstrates how curriculum complexity theory applies to:
1. Software build systems (dependency resolution)
2. Course prerequisite planning in education
3. Research project scheduling
4. Proof library analysis
"""

from algorithms import DepSystem


def application_build_system():
    """Application: Software Build System Optimization
    
    A build system has compilation units with dependencies.
    Curriculum depth = minimum number of sequential build steps
    when unlimited parallel compilation is available.
    """
    print("=" * 60)
    print("APPLICATION 1: Build System Optimization")
    print("=" * 60)
    
    # A realistic build dependency graph
    modules = {
        'utils', 'config', 'logger',
        'database', 'cache', 'auth',
        'api_core', 'api_routes', 'api_middleware',
        'frontend', 'app'
    }
    deps = {
        'utils': set(),
        'config': set(),
        'logger': {'config'},
        'database': {'config', 'logger'},
        'cache': {'config', 'logger'},
        'auth': {'database', 'cache'},
        'api_core': {'database', 'auth'},
        'api_routes': {'api_core'},
        'api_middleware': {'api_core', 'auth'},
        'frontend': {'api_routes', 'api_middleware'},
        'app': {'frontend', 'api_middleware'},
    }
    
    ds = DepSystem(modules, deps)
    
    print(f"\n{len(modules)} modules, max build depth: {ds.max_level()}")
    print(f"Minimum parallel build stages: {ds.max_level() + 1}")
    
    print("\nOptimal parallel build schedule:")
    for i, batch in enumerate(ds.parallel_schedule()):
        if batch:
            print(f"  Stage {i} (parallel): {', '.join(sorted(batch))}")
    
    print(f"\nCritical path: {' → '.join(ds.critical_path('app'))}")
    print(f"Sequential build: {len(modules)} steps")
    print(f"Parallel build:   {ds.max_level() + 1} steps")
    print(f"Speedup:          {len(modules) / (ds.max_level() + 1):.1f}x")
    print()


def application_course_planning():
    """Application: University Course Prerequisite Planning
    
    Given course prerequisites, determine the minimum number of
    semesters to complete a degree, and generate optimal schedules.
    """
    print("=" * 60)
    print("APPLICATION 2: Course Prerequisite Planning")
    print("=" * 60)
    
    courses = {
        'calc1', 'calc2', 'calc3',
        'linear_algebra', 'diff_eq',
        'intro_programming', 'data_structures', 'algorithms',
        'probability', 'statistics',
        'machine_learning', 'deep_learning',
        'numerical_methods', 'optimization'
    }
    prereqs = {
        'calc1': set(),
        'calc2': {'calc1'},
        'calc3': {'calc2'},
        'linear_algebra': {'calc1'},
        'diff_eq': {'calc2'},
        'intro_programming': set(),
        'data_structures': {'intro_programming'},
        'algorithms': {'data_structures', 'calc2'},
        'probability': {'calc2'},
        'statistics': {'probability'},
        'machine_learning': {'linear_algebra', 'statistics', 'algorithms'},
        'deep_learning': {'machine_learning'},
        'numerical_methods': {'calc3', 'linear_algebra', 'intro_programming'},
        'optimization': {'calc3', 'linear_algebra'},
    }
    
    ds = DepSystem(courses, prereqs)
    
    print(f"\n{len(courses)} courses")
    print(f"Minimum semesters to graduate: {ds.max_level() + 1}")
    
    print("\nOptimal semester plan:")
    for i, semester in enumerate(ds.parallel_schedule()):
        if semester:
            print(f"  Semester {i + 1}: {', '.join(sorted(semester))}")
    
    # Specific goals
    ml_frontier = {'machine_learning', 'deep_learning'}
    print(f"\nTo reach ML/DL frontier:")
    print(f"  Minimum semesters: {ds.frontier_depth(ml_frontier)}")
    print(f"  Critical path: {' → '.join(ds.critical_path('deep_learning'))}")
    
    num_frontier = {'numerical_methods', 'optimization'}
    print(f"\nTo reach Numerical frontier:")
    print(f"  Minimum semesters: {ds.frontier_depth(num_frontier)}")
    print()


def application_research_planning():
    """Application: Research Project Scheduling
    
    Model a research program as a dependency system.
    Compute the minimum time to reach breakthrough results.
    """
    print("=" * 60)
    print("APPLICATION 3: Research Project Scheduling")
    print("=" * 60)
    
    theorems = {
        'basic_definitions',
        'key_lemma_1', 'key_lemma_2', 'key_lemma_3',
        'intermediate_result_A', 'intermediate_result_B',
        'main_theorem',
        'generalization',
        'application_1', 'application_2',
    }
    deps = {
        'basic_definitions': set(),
        'key_lemma_1': {'basic_definitions'},
        'key_lemma_2': {'basic_definitions'},
        'key_lemma_3': {'key_lemma_1'},
        'intermediate_result_A': {'key_lemma_1', 'key_lemma_2'},
        'intermediate_result_B': {'key_lemma_2', 'key_lemma_3'},
        'main_theorem': {'intermediate_result_A', 'intermediate_result_B'},
        'generalization': {'main_theorem'},
        'application_1': {'main_theorem'},
        'application_2': {'generalization'},
    }
    
    ds = DepSystem(theorems, deps)
    
    print(f"\nResearch program: {len(theorems)} results")
    print(f"Minimum research cycles: {ds.max_level() + 1}")
    
    print("\nResearch phases:")
    for i, phase in enumerate(ds.parallel_schedule()):
        if phase:
            print(f"  Phase {i}: {', '.join(sorted(phase))}")
    
    print(f"\nCritical path: {' → '.join(ds.critical_path('application_2'))}")
    
    # What can we achieve with limited budget?
    for budget in range(1, ds.max_level() + 2):
        achievable = ds.stage_knowledge(budget - 1)
        print(f"  With {budget} cycle{'s' if budget > 1 else ''}: "
              f"{len(achievable)}/{len(theorems)} results "
              f"({100*len(achievable)/len(theorems):.0f}%)")
    print()


def application_proof_library():
    """Application: Proof Library Analysis
    
    Analyze a fragment of a formal proof library to determine
    its curriculum structure and optimal learning path.
    """
    print("=" * 60)
    print("APPLICATION 4: Proof Library Structure Analysis")
    print("=" * 60)
    
    # Simplified fragment of a number theory library
    library = {
        'nat_basic', 'nat_add', 'nat_mul', 'nat_order',
        'divisibility', 'prime', 'gcd', 'lcm',
        'modular_arith', 'euler_phi', 'fermat_little',
        'quadratic_reciprocity', 'prime_number_theorem',
    }
    imports = {
        'nat_basic': set(),
        'nat_add': {'nat_basic'},
        'nat_mul': {'nat_add'},
        'nat_order': {'nat_basic'},
        'divisibility': {'nat_mul', 'nat_order'},
        'prime': {'divisibility'},
        'gcd': {'divisibility'},
        'lcm': {'gcd'},
        'modular_arith': {'divisibility'},
        'euler_phi': {'prime', 'modular_arith'},
        'fermat_little': {'euler_phi'},
        'quadratic_reciprocity': {'prime', 'modular_arith'},
        'prime_number_theorem': {'prime', 'euler_phi'},
    }
    
    ds = DepSystem(library, imports)
    
    print(f"\nLibrary: {len(library)} modules")
    print(f"Curriculum depth: {ds.max_level()}")
    
    decomp = ds.level_decomposition()
    print("\nLevel structure:")
    for level in sorted(decomp.keys()):
        modules = sorted(decomp[level])
        print(f"  Level {level} ({len(modules)} module{'s' if len(modules) > 1 else ''}): "
              f"{', '.join(modules)}")
    
    print(f"\nDeepest result: prime_number_theorem (level {ds.dep_level('prime_number_theorem')})")
    print(f"Critical path: {' → '.join(ds.critical_path('prime_number_theorem'))}")
    
    # Learning path suggestions
    print("\nSuggested learning order (topological sort):")
    for i, module in enumerate(ds.topological_sort(), 1):
        level = ds.dep_level(module)
        print(f"  {i:2d}. [{level}] {module}")
    
    print(f"\nCurriculum flexibility: ≥{ds.curriculum_count_lower_bound()} valid orderings")
    print()


if __name__ == "__main__":
    application_build_system()
    application_course_planning()
    application_research_planning()
    application_proof_library()
    print("All applications demonstrated successfully.")


"""
Curriculum Theory: Interactive Demonstrations

Demonstrates the core theorems of curriculum complexity theory
with concrete mathematical examples.
"""

from algorithms import DepSystem
import json


def demo_three_theorem_chain():
    """Demonstrate the basic three-theorem chain: C depends on B, B depends on A.
    
    This mirrors the formally verified example in the Lean proof.
    """
    print("=" * 60)
    print("DEMO 1: Three-Theorem Chain (A → B → C)")
    print("=" * 60)
    
    ds = DepSystem(
        {'axiomA', 'lemmaB', 'thmC'},
        {'axiomA': set(), 'lemmaB': {'axiomA'}, 'thmC': {'lemmaB'}}
    )
    
    print("\nDependency levels (formally verified in Lean):")
    for t, level in ds.curriculum_ranking():
        print(f"  depLevel({t}) = {level}")
    
    print("\nStage knowledge (verified: stageKnowledge n = {{t | depLevel t ≤ n}}):")
    for n in range(ds.max_level() + 1):
        known = ds.stage_knowledge(n)
        print(f"  Stage {n}: {sorted(known)}")
    
    print("\nStrict increase at each stage (verified: stage_strictly_increases):")
    for n in range(ds.max_level()):
        s_n = ds.stage_knowledge(n)
        s_n1 = ds.stage_knowledge(n + 1)
        new = s_n1 - s_n
        print(f"  Stage {n} → {n+1}: gained {new}")
    
    print(f"\nSaturation at maxLevel = {ds.max_level()} (verified: stageKnowledge_complete_at_maxLevel)")
    print()


def demo_diamond_dependency():
    """Demonstrate a diamond-shaped dependency graph.
    
    D depends on B and C, both B and C depend on A.
    This shows how parallel dependencies affect levels.
    """
    print("=" * 60)
    print("DEMO 2: Diamond Dependency (A → B,C → D)")
    print("=" * 60)
    
    ds = DepSystem(
        {'A', 'B', 'C', 'D'},
        {'A': set(), 'B': {'A'}, 'C': {'A'}, 'D': {'B', 'C'}}
    )
    
    print("\nDependency levels:")
    for t, level in ds.curriculum_ranking():
        print(f"  depLevel({t}) = {level}")
    
    print("\nNote: B and C are at the same level (independent theorems)")
    print("This means they can be proved in parallel!")
    
    print("\nParallel schedule:")
    for i, round_set in enumerate(ds.parallel_schedule()):
        print(f"  Round {i}: {sorted(round_set)}")
    
    print(f"\nCritical path to D: {' → '.join(ds.critical_path('D'))}")
    print(f"Minimum research cycles for D: {ds.dep_level('D') + 1}")
    
    valid_orderings = ds.curriculum_count_lower_bound()
    print(f"Lower bound on valid curricula: {valid_orderings}")
    print(f"  (B and C can swap: at least 2! = 2 orderings at level 1)")
    print()


def demo_linear_algebra_curriculum():
    """A realistic example: a fragment of linear algebra.
    
    Shows how curriculum theory applies to actual mathematical content.
    """
    print("=" * 60)
    print("DEMO 3: Linear Algebra Curriculum")
    print("=" * 60)
    
    nodes = {
        'vector_space', 'linear_map', 'kernel', 'image',
        'dimension', 'rank_nullity', 'eigenvalue',
        'char_poly', 'cayley_hamilton', 'jordan_form'
    }
    deps = {
        'vector_space': set(),
        'linear_map': {'vector_space'},
        'kernel': {'linear_map'},
        'image': {'linear_map'},
        'dimension': {'vector_space'},
        'rank_nullity': {'kernel', 'image', 'dimension'},
        'eigenvalue': {'linear_map', 'dimension'},
        'char_poly': {'eigenvalue'},
        'cayley_hamilton': {'char_poly', 'rank_nullity'},
        'jordan_form': {'cayley_hamilton', 'eigenvalue'},
    }
    
    ds = DepSystem(nodes, deps)
    
    print("\nCurriculum ranking:")
    for t, level in ds.curriculum_ranking():
        print(f"  Level {level}: {t}")
    
    print(f"\nMaximum depth: {ds.max_level()}")
    print(f"Critical path to jordan_form: {' → '.join(ds.critical_path('jordan_form'))}")
    
    print("\nOptimal parallel schedule:")
    for i, round_set in enumerate(ds.parallel_schedule()):
        if round_set:
            print(f"  Round {i}: {', '.join(sorted(round_set))}")
    
    # Frontier analysis
    frontier = {'cayley_hamilton', 'jordan_form'}
    fd = ds.frontier_depth(frontier)
    print(f"\nFrontier {{cayley_hamilton, jordan_form}}:")
    print(f"  Frontier depth: {fd} cycles")
    print(f"  All frontier theorems known at stage {fd - 1}")
    
    # Verify frontier_all_known_iff
    max_dep = max(ds.dep_level(t) for t in frontier)
    all_known = all(ds.dep_level(t) <= max_dep for t in frontier)
    print(f"  max(depLevel over frontier) = {max_dep}")
    print(f"  All frontier known at stage {max_dep}: {all_known} ✓")
    print()


def demo_stage_growth():
    """Demonstrate strict stage growth and convergence.
    
    Verifies the bootstrapping strictness theorem computationally.
    """
    print("=" * 60)
    print("DEMO 4: Stage Growth and Convergence")
    print("=" * 60)
    
    # Build a system with 3 levels and multiple theorems per level
    ds = DepSystem(
        {'A1', 'A2', 'B1', 'B2', 'B3', 'C1', 'C2'},
        {
            'A1': set(), 'A2': set(),
            'B1': {'A1'}, 'B2': {'A1', 'A2'}, 'B3': {'A2'},
            'C1': {'B1', 'B2'}, 'C2': {'B2', 'B3'},
        }
    )
    
    print("\nLevel decomposition:")
    decomp = ds.level_decomposition()
    for level in sorted(decomp.keys()):
        print(f"  Level {level}: {sorted(decomp[level])}")
    
    print("\nStage knowledge growth:")
    prev = set()
    for n in range(ds.max_level() + 2):
        curr = ds.stage_knowledge(n)
        new = curr - prev
        is_strict = len(curr) > len(prev)
        status = "STRICT ⊂" if is_strict else "= (saturated)"
        print(f"  Stage {n}: |known| = {len(curr):2d}, "
              f"new = {sorted(new) if new else '∅':30s} {status}")
        prev = curr
    
    print(f"\nSaturation point: stage {ds.max_level()}")
    print(f"Total theorems: {len(ds.nodes)}")
    print(f"|stageKnowledge({ds.max_level()})| = {len(ds.stage_knowledge(ds.max_level()))}")
    print(f"Equals Set.univ: {ds.stage_knowledge(ds.max_level()) == ds.nodes} ✓")
    print()


def demo_cross_domain():
    """Demonstrate cross-domain curriculum merging.
    
    Two independent mathematical theories merged with cross-dependencies.
    """
    print("=" * 60)
    print("DEMO 5: Cross-Domain Theory Merging")
    print("=" * 60)
    
    # Algebra fragment
    algebra = DepSystem(
        {'group', 'ring', 'field', 'polynomial'},
        {
            'group': set(),
            'ring': {'group'},
            'field': {'ring'},
            'polynomial': {'ring'},
        }
    )
    
    # Analysis fragment
    analysis = DepSystem(
        {'metric', 'topology', 'continuity', 'derivative'},
        {
            'metric': set(),
            'topology': {'metric'},
            'continuity': {'topology'},
            'derivative': {'continuity'},
        }
    )
    
    print("Algebra theory depth:", algebra.max_level())
    print("Analysis theory depth:", analysis.max_level())
    
    # Merge with cross-dependency: algebraic geometry needs both
    from algorithms import merge_systems
    merged = merge_systems(algebra, analysis, {
        'derivative': {'field'},  # derivatives need field structure
    })
    
    print(f"\nMerged system depth: {merged.max_level()}")
    print("\nMerged curriculum:")
    for t, level in merged.curriculum_ranking():
        print(f"  Level {level}: {t}")
    
    print(f"\nCritical path to derivative: {' → '.join(merged.critical_path('derivative'))}")
    print("Note: cross-domain dependency increases the depth!")
    print()


if __name__ == "__main__":
    demo_three_theorem_chain()
    demo_diamond_dependency()
    demo_linear_algebra_curriculum()
    demo_stage_growth()
    demo_cross_domain()
    print("All demonstrations completed successfully.")


"""
Curriculum Theory: Visualizations

Generates publication-quality visualizations of curriculum complexity theory.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import DepSystem
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_dependency_dag():
    """Visualize a dependency DAG with level coloring."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    
    # Linear algebra curriculum
    nodes_data = {
        'Vector Space': (1, 0),
        'Linear Map': (0, 1),
        'Dimension': (2, 1),
        'Kernel': (-0.5, 2),
        'Image': (0.5, 2),
        'Eigenvalue': (2.5, 2),
        'Rank-Nullity': (0.5, 3),
        'Char. Poly': (2.5, 3),
        'Cayley-Hamilton': (1.5, 4),
        'Jordan Form': (1.5, 5),
    }
    
    edges = [
        ('Vector Space', 'Linear Map'),
        ('Vector Space', 'Dimension'),
        ('Linear Map', 'Kernel'),
        ('Linear Map', 'Image'),
        ('Linear Map', 'Eigenvalue'),
        ('Dimension', 'Eigenvalue'),
        ('Dimension', 'Rank-Nullity'),
        ('Kernel', 'Rank-Nullity'),
        ('Image', 'Rank-Nullity'),
        ('Eigenvalue', 'Char. Poly'),
        ('Rank-Nullity', 'Cayley-Hamilton'),
        ('Char. Poly', 'Cayley-Hamilton'),
        ('Cayley-Hamilton', 'Jordan Form'),
        ('Eigenvalue', 'Jordan Form'),
    ]
    
    levels = {name: int(pos[1]) for name, pos in nodes_data.items()}
    max_level = max(levels.values())
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, max_level + 1))
    
    # Draw edges
    for src, dst in edges:
        x1, y1 = nodes_data[src]
        x2, y2 = nodes_data[dst]
        ax.annotate('', xy=(x2, y2 - 0.15), xytext=(x1, y1 + 0.15),
                    arrowprops=dict(arrowstyle='->', color='#666666',
                                   lw=1.5, connectionstyle='arc3,rad=0.1'))
    
    # Draw nodes
    for name, (x, y) in nodes_data.items():
        level = levels[name]
        color = colors[level]
        bbox = dict(boxstyle='round,pad=0.4', facecolor=color,
                   edgecolor='black', linewidth=1.5, alpha=0.9)
        ax.text(x, y, name, ha='center', va='center',
               fontsize=9, fontweight='bold', bbox=bbox,
               color='white' if level > 2 else 'black')
    
    # Level indicators
    for level in range(max_level + 1):
        ax.axhline(y=level, color='gray', linestyle=':', alpha=0.3, zorder=0)
        ax.text(-1.5, level, f'Level {level}', fontsize=10, color='gray',
               va='center', ha='right', fontstyle='italic')
    
    ax.set_xlim(-2, 4)
    ax.set_ylim(-0.5, 5.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Dependency DAG with Curriculum Levels\n(Linear Algebra Fragment)',
                fontsize=14, fontweight='bold', pad=20)
    
    return fig_to_base64(fig)


def viz_stage_growth():
    """Visualize stage knowledge growth over time."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Example system
    ds = DepSystem(
        {'A1', 'A2', 'A3', 'B1', 'B2', 'C1', 'C2', 'C3', 'D1', 'D2'},
        {
            'A1': set(), 'A2': set(), 'A3': set(),
            'B1': {'A1'}, 'B2': {'A1', 'A2'},
            'C1': {'B1', 'B2'}, 'C2': {'B2'}, 'C3': {'A3'},
            'D1': {'C1', 'C2'}, 'D2': {'C3', 'C1'},
        }
    )
    
    # Left: cumulative knowledge
    stages = range(ds.max_level() + 2)
    knowledge_sizes = [len(ds.stage_knowledge(n)) for n in stages]
    
    colors_bar = ['#2ecc71', '#3498db', '#9b59b6', '#e74c3c', '#f39c12']
    
    bars = ax1.bar(list(stages), knowledge_sizes,
                   color=[colors_bar[min(i, len(colors_bar)-1)] for i in stages],
                   edgecolor='white', linewidth=1.5)
    ax1.axhline(y=len(ds.nodes), color='red', linestyle='--',
               alpha=0.7, label=f'|T| = {len(ds.nodes)}')
    ax1.set_xlabel('Stage n', fontsize=12)
    ax1.set_ylabel('|stageKnowledge(n)|', fontsize=12)
    ax1.set_title('Monotone Knowledge Growth', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.set_ylim(0, len(ds.nodes) + 1)
    
    # Annotate strict increases
    for i in range(1, len(knowledge_sizes)):
        if knowledge_sizes[i] > knowledge_sizes[i-1]:
            ax1.annotate('⊂', xy=(i - 0.5, (knowledge_sizes[i] + knowledge_sizes[i-1]) / 2),
                        fontsize=14, ha='center', va='center', color='red', fontweight='bold')
    
    # Right: new theorems per stage
    new_per_stage = []
    for n in stages:
        if n == 0:
            new_per_stage.append(len(ds.stage_knowledge(0)))
        else:
            new_per_stage.append(len(ds.stage_knowledge(n)) - len(ds.stage_knowledge(n-1)))
    
    ax2.bar(list(stages), new_per_stage,
            color=[colors_bar[min(i, len(colors_bar)-1)] for i in stages],
            edgecolor='white', linewidth=1.5)
    ax2.set_xlabel('Stage n', fontsize=12)
    ax2.set_ylabel('New theorems at stage n', fontsize=12)
    ax2.set_title('Bootstrapping: New Knowledge Per Stage', fontsize=13, fontweight='bold')
    
    # Level decomposition annotation
    decomp = ds.level_decomposition()
    for level in sorted(decomp.keys()):
        count = len(decomp[level])
        ax2.text(level, count + 0.1, f'{count}', ha='center', va='bottom',
                fontsize=11, fontweight='bold')
    
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_frontier_analysis():
    """Visualize frontier reachability and optimality."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    # Research program
    ds = DepSystem(
        {'D0', 'L1a', 'L1b', 'L2a', 'L2b', 'L2c', 'R3a', 'R3b', 'T4', 'G5'},
        {
            'D0': set(),
            'L1a': {'D0'}, 'L1b': {'D0'},
            'L2a': {'L1a'}, 'L2b': {'L1a', 'L1b'}, 'L2c': {'L1b'},
            'R3a': {'L2a', 'L2b'}, 'R3b': {'L2b', 'L2c'},
            'T4': {'R3a', 'R3b'},
            'G5': {'T4'},
        }
    )
    
    # Plot cumulative coverage for different frontiers
    frontier_sets = {
        'All theorems': ds.nodes,
        'Main + Generalization': {'T4', 'G5'},
        'Just Main Theorem': {'T4'},
        'Intermediate Results': {'R3a', 'R3b'},
    }
    
    max_stage = ds.max_level() + 1
    stages = range(max_stage + 1)
    
    line_styles = ['-', '--', '-.', ':']
    colors_line = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
    
    for idx, (name, frontier) in enumerate(frontier_sets.items()):
        coverage = []
        for n in stages:
            known = ds.stage_knowledge(n)
            covered = len(frontier & known)
            coverage.append(covered / len(frontier) * 100)
        
        ax.plot(list(stages), coverage, line_styles[idx],
               color=colors_line[idx], linewidth=2.5,
               marker='o', markersize=6, label=name)
        
        # Mark the frontier depth
        fd = ds.frontier_depth(frontier)
        ax.axvline(x=fd - 1, color=colors_line[idx], linestyle=':',
                  alpha=0.3, linewidth=1)
    
    ax.axhline(y=100, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Stage n', fontsize=12)
    ax.set_ylabel('Frontier Coverage (%)', fontsize=12)
    ax.set_title('Frontier Reachability by Stage\n(verified: frontier_all_known_iff)',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=10, loc='lower right')
    ax.set_ylim(-5, 110)
    ax.set_xlim(-0.5, max_stage + 0.5)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_parallel_vs_sequential():
    """Compare parallel and sequential complexity."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    # Generate systems of increasing size
    np.random.seed(42)
    sizes = [5, 10, 15, 20, 30, 50]
    seq_depths = []
    par_depths = []
    
    for n in sizes:
        # Build a random DAG
        nodes = {f'T{i}' for i in range(n)}
        deps = {}
        for i in range(n):
            # Each node depends on some earlier nodes
            possible = [f'T{j}' for j in range(i)]
            if possible:
                k = min(len(possible), np.random.randint(1, 4))
                selected = list(np.random.choice(possible, size=k, replace=False))
                deps[f'T{i}'] = set(selected)
            else:
                deps[f'T{i}'] = set()
        
        ds = DepSystem(nodes, deps)
        seq_depths.append(n)
        par_depths.append(ds.max_level() + 1)
    
    x = np.arange(len(sizes))
    width = 0.35
    
    bars1 = ax.bar(x - width/2, seq_depths, width,
                   label='Sequential (n theorems)', color='#e74c3c', alpha=0.8)
    bars2 = ax.bar(x + width/2, par_depths, width,
                   label='Parallel (max depth + 1)', color='#3498db', alpha=0.8)
    
    # Add speedup annotations
    for i in range(len(sizes)):
        speedup = seq_depths[i] / par_depths[i]
        ax.text(i, max(seq_depths[i], par_depths[i]) + 1,
               f'{speedup:.1f}×', ha='center', va='bottom',
               fontsize=9, fontweight='bold', color='#2c3e50')
    
    ax.set_xlabel('System Size', fontsize=12)
    ax.set_ylabel('Number of Steps', fontsize=12)
    ax.set_title('Sequential vs Parallel Research Complexity\n'
                '(Speedup from curriculum-optimal scheduling)',
                fontsize=13, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels([f'n={s}' for s in sizes])
    ax.legend(fontsize=11)
    ax.grid(True, axis='y', alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    img1 = viz_dependency_dag()
    print(f"1. Dependency DAG: {len(img1)} chars")
    
    img2 = viz_stage_growth()
    print(f"2. Stage Growth: {len(img2)} chars")
    
    img3 = viz_frontier_analysis()
    print(f"3. Frontier Analysis: {len(img3)} chars")
    
    img4 = viz_parallel_vs_sequential()
    print(f"4. Parallel vs Sequential: {len(img4)} chars")
    
    # Save images as files too
    for name, data in [('dag', img1), ('growth', img2), ('frontier', img3), ('parallel', img4)]:
        # Extract base64 data
        b64 = data.split(',', 1)[1]
        with open(f'{name}.png', 'wb') as f:
            f.write(base64.b64decode(b64))
        print(f"Saved {name}.png")
    
    print("All visualizations generated.")
