#!/usr/bin/env python3
"""
applications.py — Real-world applications of reflective convergence theory.

Demonstrates how the convergence theorems apply to:
1. Compiler optimization pass scheduling
2. Machine learning hyperparameter search
3. Software bug triage and resolution
4. Network routing protocol convergence
"""

from typing import FrozenSet, Dict, List, Tuple, Set
from dataclasses import dataclass
import random
import time


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 1: Compiler Optimization Pass Scheduling
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class CompilerState:
    """State of a program being optimized by compiler passes."""
    code_size: int
    dead_code: FrozenSet[str]
    inlined: FrozenSet[str]
    loop_unrolled: FrozenSet[str]

    def quality(self) -> int:
        """Higher is better: smaller code with more optimizations applied."""
        return 1000 - self.code_size + 10 * len(self.inlined) + 5 * len(self.loop_unrolled)


def compiler_improve(state: CompilerState) -> CompilerState:
    """
    One round of compiler optimization.

    This is a monotone inflationary operator on the CompilerState poset:
    - Dead code elimination: removes dead code (quality increases)
    - Inlining: inlines small functions (quality increases)
    - Loop unrolling: unrolls tight loops (quality increases)
    """
    # Remove one dead code block
    new_dead = state.dead_code
    new_size = state.code_size
    if new_dead:
        victim = min(new_dead)
        new_dead = new_dead - {victim}
        new_size = max(0, new_size - 10)

    # Inline one function (if any candidates exist)
    candidates = {"f1", "f2", "f3"} - state.inlined
    new_inlined = state.inlined
    if candidates:
        new_inlined = new_inlined | {min(candidates)}

    # Unroll one loop
    loop_candidates = {"loop_a", "loop_b"} - state.loop_unrolled
    new_unrolled = state.loop_unrolled
    if loop_candidates:
        new_unrolled = new_unrolled | {min(loop_candidates)}

    return CompilerState(
        code_size=new_size,
        dead_code=new_dead,
        inlined=new_inlined,
        loop_unrolled=new_unrolled,
    )


def demo_compiler_optimization():
    """Demonstrate compiler pass convergence."""
    print("═" * 70)
    print("APPLICATION 1: Compiler Optimization Pass Convergence")
    print("═" * 70)
    print()
    print("A compiler applies optimization passes iteratively.")
    print("By the reflective convergence theorem, passes stabilize.")
    print()

    initial = CompilerState(
        code_size=500,
        dead_code=frozenset({"unused_helper", "debug_print", "legacy_check"}),
        inlined=frozenset(),
        loop_unrolled=frozenset(),
    )

    current = initial
    for step in range(20):
        next_state = compiler_improve(current)
        print(f"  Step {step}: size={current.code_size}, "
              f"dead={len(current.dead_code)}, "
              f"inlined={len(current.inlined)}, "
              f"unrolled={len(current.loop_unrolled)}, "
              f"quality={current.quality()}")
        if next_state == current:
            print(f"  → FIXED POINT reached at step {step}!")
            break
        current = next_state
    print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 2: Software Bug Triage
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class BugTracker:
    """State of a bug tracking system."""
    open_bugs: FrozenSet[str]
    fixed_bugs: FrozenSet[str]
    tests_passing: int

    def weakness(self) -> FrozenSet[str]:
        return self.open_bugs


def bug_fix_improve(state: BugTracker) -> BugTracker:
    """Fix the highest-priority bug (alphabetically first as proxy)."""
    if not state.open_bugs:
        return state
    victim = min(state.open_bugs)
    return BugTracker(
        open_bugs=state.open_bugs - {victim},
        fixed_bugs=state.fixed_bugs | {victim},
        tests_passing=state.tests_passing + 5,
    )


def demo_bug_triage():
    """Demonstrate bug resolution convergence via weakness descent."""
    print("═" * 70)
    print("APPLICATION 2: Bug Triage — Weakness Descent in Action")
    print("═" * 70)
    print()
    print("Each cycle fixes the highest-priority bug.")
    print("By the weakness descent theorem, open bugs → ∅.")
    print()

    initial = BugTracker(
        open_bugs=frozenset({"auth_bypass", "crash_on_null", "memory_leak",
                            "race_condition", "sql_injection"}),
        fixed_bugs=frozenset(),
        tests_passing=80,
    )

    current = initial
    for step in range(10):
        w = current.weakness()
        print(f"  Step {step}: open={len(w)}, fixed={len(current.fixed_bugs)}, "
              f"tests={current.tests_passing}%")
        if not w:
            print(f"  → ALL BUGS FIXED at step {step}!")
            break
        next_state = bug_fix_improve(current)
        if next_state.weakness() == w:
            print(f"  → Weakness stabilized at step {step}")
            break
        current = next_state
    print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 3: Network Routing Convergence
# ═══════════════════════════════════════════════════════════════════════

def demo_routing_convergence():
    """Demonstrate distance-vector routing convergence."""
    print("═" * 70)
    print("APPLICATION 3: Network Routing Protocol Convergence")
    print("═" * 70)
    print()
    print("Distance-vector routing: each node improves its routing table")
    print("by learning from neighbors. This is a monotone map on a finite")
    print("poset of routing tables, guaranteed to converge.")
    print()

    # Simple 4-node network
    INF = 999
    # Direct link costs
    links = {
        (0, 1): 1, (1, 0): 1,
        (1, 2): 2, (2, 1): 2,
        (2, 3): 1, (3, 2): 1,
        (0, 3): 7, (3, 0): 7,
    }

    n = 4
    # Initialize distance tables
    dist = [[INF] * n for _ in range(n)]
    for i in range(n):
        dist[i][i] = 0
    for (i, j), c in links.items():
        dist[i][j] = c

    for step in range(10):
        changed = False
        new_dist = [row[:] for row in dist]
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    if (i, k) in links:
                        new_val = links[(i, k)] + dist[k][j]
                        if new_val < new_dist[i][j]:
                            new_dist[i][j] = new_val
                            changed = True

        print(f"  Step {step}: ", end="")
        for i in range(n):
            costs = [str(d) if d < INF else "∞" for d in dist[i]]
            print(f"  node{i}→[{','.join(costs)}]", end="")
        print()

        if not changed:
            print(f"  → CONVERGED at step {step}!")
            break
        dist = new_dist
    print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 4: ML Hyperparameter Grid Search
# ═══════════════════════════════════════════════════════════════════════

def demo_ml_hyperparameter():
    """Demonstrate convergence of greedy hyperparameter improvement."""
    print("═" * 70)
    print("APPLICATION 4: ML Hyperparameter Search Convergence")
    print("═" * 70)
    print()
    print("Greedy coordinate descent on a discrete hyperparameter grid.")
    print("Each step improves one hyperparameter. Convergence guaranteed")
    print("on finite grids by the reflective convergence theorem.")
    print()

    random.seed(42)

    # Discrete hyperparameter grid
    lr_options = [0.001, 0.01, 0.1]
    batch_options = [16, 32, 64, 128]
    depth_options = [2, 3, 4, 5]

    def score(lr: float, batch: int, depth: int) -> float:
        """Simulated validation accuracy (higher is better)."""
        # Peaked around lr=0.01, batch=64, depth=4
        return (90.0
                - 5 * abs(lr - 0.01) / 0.01
                - 2 * abs(batch - 64) / 64
                - 3 * abs(depth - 4)
                + random.gauss(0, 0.1))

    # Start with worst hyperparameters
    lr, batch, depth = 0.001, 16, 2
    random.seed(42)

    for step in range(20):
        current_score = score(lr, batch, depth)
        print(f"  Step {step}: lr={lr}, batch={batch}, depth={depth}, "
              f"score={current_score:.2f}")

        # Try improving each coordinate
        best_score = current_score
        best_config = (lr, batch, depth)
        improved = False

        for new_lr in lr_options:
            random.seed(42)
            s = score(new_lr, batch, depth)
            if s > best_score:
                best_score = s
                best_config = (new_lr, batch, depth)
                improved = True

        for new_batch in batch_options:
            random.seed(42)
            s = score(best_config[0], new_batch, depth)
            if s > best_score:
                best_score = s
                best_config = (best_config[0], new_batch, depth)
                improved = True

        for new_depth in depth_options:
            random.seed(42)
            s = score(best_config[0], best_config[1], new_depth)
            if s > best_score:
                best_score = s
                best_config = (best_config[0], best_config[1], new_depth)
                improved = True

        if not improved:
            print(f"  → CONVERGED at step {step}!")
            break

        lr, batch, depth = best_config
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   APPLICATIONS OF REFLECTIVE CONVERGENCE THEORY                    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_compiler_optimization()
    demo_bug_triage()
    demo_routing_convergence()
    demo_ml_hyperparameter()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
demo.py — Concrete demonstrations of reflective convergence theorems.

Shows how self-improving strategies converge to fixed points in finite
strategy spaces, with numerical examples and convergence traces.
"""

import itertools
from typing import Callable, TypeVar, List, Tuple, Set, FrozenSet

T = TypeVar('T')


def iterate_until_fixed(f: Callable[[T], T], x: T, max_iter: int = 1000) -> Tuple[List[T], int]:
    """Iterate f starting from x until a fixed point is reached or max_iter exceeded."""
    trace = [x]
    for i in range(max_iter):
        x_next = f(x)
        trace.append(x_next)
        if x_next == x:
            return trace, i
        x = x_next
    return trace, max_iter


def demo_basic_convergence():
    """Demo 1: Basic convergence of a monotone inflationary map on a finite poset."""
    print("=" * 70)
    print("DEMO 1: Monotone Inflationary Map on Finite Poset")
    print("=" * 70)
    print()
    print("Strategy space: integers {0, 1, 2, ..., 10}")
    print("Improvement operator: improve(s) = min(s + 1, 10)")
    print("Rank function: rank(s) = s")
    print()

    improve = lambda s: min(s + 1, 10)

    for start in [0, 3, 7, 10]:
        trace, steps = iterate_until_fixed(improve, start)
        print(f"  Starting from s={start}: {' → '.join(map(str, trace))}")
        print(f"    Fixed point reached at step {steps}: s* = {trace[-1]}")
    print()


def demo_weakness_descent():
    """Demo 2: Weakness descent — defect elimination converges."""
    print("=" * 70)
    print("DEMO 2: Weakness Descent — Defect Elimination")
    print("=" * 70)
    print()
    print("Defect universe: {0, 1, 2, 3, 4}")
    print("Improvement: remove the minimum unresolved defect")
    print()

    def improve_defects(s: FrozenSet[int]) -> FrozenSet[int]:
        if not s:
            return s
        return s - {min(s)}

    test_cases = [
        frozenset({0, 1, 2, 3, 4}),
        frozenset({2, 4}),
        frozenset({1, 3}),
        frozenset(),
    ]

    for start in test_cases:
        trace, steps = iterate_until_fixed(improve_defects, start)
        trace_str = ['{' + ','.join(map(str, sorted(s))) + '}' for s in trace]
        print(f"  Start: {trace_str[0]}")
        print(f"  Trace: {' → '.join(trace_str)}")
        print(f"  Converged in {steps} steps, weakness card: {len(start)} → 0")
        print()


def demo_research_strategy():
    """Demo 3: A concrete research strategy model with budget and defects."""
    print("=" * 70)
    print("DEMO 3: Research Strategy with Budget and Defects")
    print("=" * 70)
    print()

    class Strategy:
        def __init__(self, budget: int, unresolved: FrozenSet[str]):
            self.budget = budget
            self.unresolved = unresolved

        def __repr__(self):
            defects = ','.join(sorted(self.unresolved)) if self.unresolved else '∅'
            return f"(budget={self.budget}, defects={{{defects}}})"

        def __eq__(self, other):
            return self.budget == other.budget and self.unresolved == other.unresolved

        def __hash__(self):
            return hash((self.budget, self.unresolved))

        def rank(self):
            return self.budget * 10 - len(self.unresolved)

    def improve(s: Strategy) -> Strategy:
        new_budget = min(s.budget + 1, 5)
        new_defects = s.unresolved
        # Remove the lexicographically first defect if any
        if new_defects:
            victim = min(new_defects)
            new_defects = new_defects - {victim}
        return Strategy(new_budget, new_defects)

    initial = Strategy(0, frozenset({"gap_A", "gap_B", "gap_C", "notation"}))
    trace, steps = iterate_until_fixed(improve, initial)

    print(f"  Initial strategy: {initial}")
    print(f"  Rank function: budget*10 - |defects|")
    print()
    for i, s in enumerate(trace):
        marker = " ← fixed point!" if i == len(trace) - 1 and i > 0 else ""
        print(f"    Step {i}: {s}  (rank={s.rank()}){marker}")
    print(f"\n  Converged in {steps} steps.")
    print()


def demo_query_bound():
    """Demo 4: Query complexity bound on improvement outcomes."""
    print("=" * 70)
    print("DEMO 4: Query Complexity Bound")
    print("=" * 70)
    print()
    print("A k-query strategy can produce at most 2^k distinct outcomes.")
    print()

    for k in range(1, 6):
        # Simulate a random-ish decision function
        import random
        random.seed(42 + k)

        n_outcomes = 3 * k  # larger outcome space
        decide = {tuple(bits): random.randint(0, n_outcomes)
                  for bits in itertools.product([False, True], repeat=k)}
        distinct = len(set(decide.values()))
        bound = 2 ** k
        print(f"  k={k} queries: {distinct} distinct outcomes ≤ {bound} = 2^{k}  ✓")
    print()


def demo_idempotent_evidence():
    """Demo 5: Idempotent evidence aggregation."""
    print("=" * 70)
    print("DEMO 5: Idempotent Evidence Aggregation")
    print("=" * 70)
    print()
    print("In a Boolean semiring (OR, AND), rediscovering evidence is idempotent:")
    print()

    for a in [False, True]:
        result = a or a  # idempotent OR
        print(f"  evidence={a}: {a} ∨ {a} = {result}  (a ∨ a = a: {result == a})")

    print()
    print("In set union (idempotent addition), repeated discovery adds nothing:")
    a = frozenset({1, 2, 3})
    print(f"  A = {set(a)}")
    print(f"  A ∪ A = {set(a | a)}")
    print(f"  A ∪ A = A: {a | a == a}")
    print()


def demo_self_reference_bound():
    """Demo 6: Self-reference bound — non-trivial maps have fewer fixed points."""
    print("=" * 70)
    print("DEMO 6: Bounded Self-Reference")
    print("=" * 70)
    print()

    space = list(range(8))
    n = len(space)

    test_maps = [
        ("shift-right (mod 8)", lambda x: (x + 1) % 8),
        ("double (mod 8)", lambda x: (2 * x) % 8),
        ("max(x, 4)", lambda x: max(x, 4)),
        ("identity", lambda x: x),
    ]

    for name, f in test_maps:
        fixed = [x for x in space if f(x) == x]
        is_id = all(f(x) == x for x in space)
        status = "= |σ| (identity!)" if is_id else f"< {n} = |σ|  ✓"
        print(f"  {name}: fixed points = {fixed}, count = {len(fixed)} {status}")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║       REFLECTIVE CONVERGENCE: Concrete Demonstrations              ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_basic_convergence()
    demo_weakness_descent()
    demo_research_strategy()
    demo_query_bound()
    demo_idempotent_evidence()
    demo_self_reference_bound()

    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
visualizations.py — Generate charts for reflective convergence theory.

Produces:
1. convergence_trace.png — Rank progression during improvement iteration
2. weakness_descent.png — Weakness cardinality descent
3. convergence_basins.png — Basin of attraction diagram
4. phase_diagram.png — Convergence speed as function of initial rank
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, Tuple, Dict, FrozenSet
import base64
import io


def generate_convergence_trace():
    """Generate rank progression chart."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Multiple starting points on a finite poset
    max_rank = 20

    def improve(s: int) -> int:
        if s >= max_rank:
            return s
        return min(s + max(1, (max_rank - s) // 3), max_rank)

    starts = [0, 3, 7, 12, 18]
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0']

    for start, color in zip(starts, colors):
        trace = [start]
        current = start
        for _ in range(30):
            next_val = improve(current)
            trace.append(next_val)
            if next_val == current:
                break
            current = next_val

        ax.plot(range(len(trace)), trace, 'o-', color=color, linewidth=2,
                markersize=6, label=f'Start = {start}')
        # Mark fixed point
        ax.plot(len(trace) - 1, trace[-1], '*', color=color, markersize=15,
                markeredgecolor='black', markeredgewidth=1)

    ax.set_xlabel('Iteration Step', fontsize=14)
    ax.set_ylabel('Rank (Quality Score)', fontsize=14)
    ax.set_title('Reflective Convergence: Rank Progression to Fixed Points', fontsize=16)
    ax.legend(fontsize=12, loc='lower right')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=max_rank, color='red', linestyle='--', alpha=0.5, label='Maximum rank')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/convergence_trace.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  ✓ convergence_trace.png")


def generate_weakness_descent():
    """Generate weakness cardinality descent chart."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: multiple weakness descent traces
    defect_sets = [
        frozenset(range(15)),
        frozenset(range(0, 20, 2)),
        frozenset(range(5, 12)),
        frozenset({1, 3, 7, 11, 13, 17, 19}),
    ]

    colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
    labels = ['15 defects', '10 defects', '7 defects', '7 defects (sparse)']

    for defects, color, label in zip(defect_sets, colors, labels):
        cards = [len(defects)]
        current = defects
        while current:
            current = current - {min(current)}
            cards.append(len(current))

        ax1.plot(range(len(cards)), cards, 'o-', color=color, linewidth=2,
                markersize=5, label=label)

    ax1.set_xlabel('Iteration Step', fontsize=13)
    ax1.set_ylabel('|weakness(s)|', fontsize=13)
    ax1.set_title('Weakness Descent: Defect Elimination', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: staircase showing individual defects being removed
    defects = list(range(8))
    n = len(defects)

    for i, d in enumerate(defects):
        ax2.barh(d, n - i, left=0, height=0.8, alpha=0.7,
                color=plt.cm.RdYlGn(i / n))
        ax2.text(n - i + 0.1, d, f'removed at step {i}', va='center', fontsize=10)

    ax2.set_xlabel('Steps Remaining', fontsize=13)
    ax2.set_ylabel('Defect ID', fontsize=13)
    ax2.set_title('Defect Lifetime Diagram', fontsize=14)
    ax2.invert_yaxis()

    plt.tight_layout()
    plt.savefig('/workspace/request-project/weakness_descent.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  ✓ weakness_descent.png")


def generate_convergence_basins():
    """Generate basin of attraction visualization."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Strategy space: 2D grid with improvement toward nearest fixed point
    n = 20
    fixed_points = [(5, 5), (15, 15), (5, 15)]
    fp_colors = ['#2196F3', '#4CAF50', '#FF9800']

    def improve(x: int, y: int) -> Tuple[int, int]:
        """Move toward the nearest fixed point (Manhattan)."""
        best_fp = min(fixed_points, key=lambda fp: abs(fp[0] - x) + abs(fp[1] - y))
        nx = x + (1 if best_fp[0] > x else (-1 if best_fp[0] < x else 0))
        ny = y + (1 if best_fp[1] > y else (-1 if best_fp[1] < y else 0))
        return nx, ny

    # Color each cell by which fixed point it converges to
    basin_map = np.zeros((n, n))
    for x in range(n):
        for y in range(n):
            cx, cy = x, y
            for _ in range(100):
                ncx, ncy = improve(cx, cy)
                if (ncx, ncy) == (cx, cy):
                    break
                cx, cy = ncx, ncy

            for k, fp in enumerate(fixed_points):
                if (cx, cy) == fp:
                    basin_map[y, x] = k + 1
                    break

    cmap = matplotlib.colors.ListedColormap(['white', '#BBDEFB', '#C8E6C9', '#FFE0B2'])
    ax.imshow(basin_map, cmap=cmap, origin='lower', extent=[0, n, 0, n])

    # Draw some trajectories
    for start_x, start_y in [(2, 2), (18, 3), (10, 18), (12, 8), (3, 12)]:
        traj_x, traj_y = [start_x], [start_y]
        cx, cy = start_x, start_y
        for _ in range(50):
            ncx, ncy = improve(cx, cy)
            if (ncx, ncy) == (cx, cy):
                break
            traj_x.append(ncx)
            traj_y.append(ncy)
            cx, cy = ncx, ncy
        ax.plot(traj_x, traj_y, '-', color='gray', alpha=0.6, linewidth=1)
        ax.plot(traj_x[0], traj_y[0], 'o', color='black', markersize=5)

    # Mark fixed points
    for fp, color in zip(fixed_points, fp_colors):
        ax.plot(fp[0], fp[1], '*', color=color, markersize=20,
                markeredgecolor='black', markeredgewidth=1.5)

    ax.set_xlabel('Strategy Dimension 1', fontsize=13)
    ax.set_ylabel('Strategy Dimension 2', fontsize=13)
    ax.set_title('Convergence Basins: Three Fixed Points', fontsize=15)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/convergence_basins.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  ✓ convergence_basins.png")


def generate_phase_diagram():
    """Generate convergence speed phase diagram."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: convergence steps vs initial rank gap
    max_rank = 50
    gaps = list(range(0, max_rank + 1))
    steps_linear = [g for g in gaps]  # linear improvement
    steps_log = [max(0, int(np.ceil(np.log2(g + 1)))) for g in gaps]  # doubling improvement
    steps_sqrt = [max(0, int(np.ceil(np.sqrt(g)))) for g in gaps]  # sqrt improvement

    ax1.plot(gaps, steps_linear, '-', linewidth=2, color='#2196F3', label='Linear (improve +1)')
    ax1.plot(gaps, steps_sqrt, '-', linewidth=2, color='#4CAF50', label='Accelerating (√n)')
    ax1.plot(gaps, steps_log, '-', linewidth=2, color='#FF9800', label='Exponential (log n)')
    ax1.set_xlabel('Initial Rank Gap (max_rank - rank(s₀))', fontsize=13)
    ax1.set_ylabel('Steps to Convergence', fontsize=13)
    ax1.set_title('Convergence Speed vs Initial Gap', fontsize=14)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)

    # Right: heat map of convergence steps for 2D strategy space
    n = 30
    convergence_map = np.zeros((n, n))

    for x in range(n):
        for y in range(n):
            rank = x + y  # rank = sum of coordinates
            target = 2 * (n - 1)
            gap = target - rank
            convergence_map[y, x] = max(gap, 0)

    im = ax2.imshow(convergence_map, origin='lower', cmap='YlOrRd_r',
                     extent=[0, n, 0, n])
    plt.colorbar(im, ax=ax2, label='Steps to convergence')
    ax2.set_xlabel('Strategy Parameter 1', fontsize=13)
    ax2.set_ylabel('Strategy Parameter 2', fontsize=13)
    ax2.set_title('Convergence Heat Map (rank = x + y)', fontsize=14)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/phase_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  ✓ phase_diagram.png")


def png_to_base64(path: str) -> str:
    """Convert a PNG file to a base64 data URI."""
    with open(path, 'rb') as f:
        data = f.read()
    b64 = base64.b64encode(data).decode('utf-8')
    return f"data:image/png;base64,{b64}"


if __name__ == "__main__":
    print("Generating visualizations...")
    generate_convergence_trace()
    generate_weakness_descent()
    generate_convergence_basins()
    generate_phase_diagram()
    print("\nAll visualizations generated successfully.")
