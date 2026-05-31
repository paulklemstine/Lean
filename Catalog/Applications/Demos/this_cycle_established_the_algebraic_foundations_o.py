"""
Tropical Recipe Complexity Theory — Demonstration

Numerical examples illustrating the main theorems and constructions.
"""

from algorithms import (
    RecipeStep, TropicalScheduleVector, Pipeline,
    classify_gap, tropical_matrix_multiply, tropical_spectral_radius,
    verify_gap_additivity, verify_gap_subadditivity,
    verify_gap_iteration, verify_tropical_distributive,
    verify_critical_path_bounds,
)


def demo_gap_theorems():
    """Demonstrate the three fundamental gap theorems."""
    print("=" * 60)
    print("DEMO 1: Gap Theorems")
    print("=" * 60)

    # Example recipe steps
    souffle = RecipeStep(create_time=45, verify_time=2)   # Hard to make, easy to taste
    salad = RecipeStep(create_time=10, verify_time=5)     # Easy to make, easy to check
    sauce = RecipeStep(create_time=30, verify_time=8)     # Medium difficulty

    print(f"\nSoufflé: create={souffle.create_time}, verify={souffle.verify_time}, gap={souffle.gap}")
    print(f"Salad:   create={salad.create_time}, verify={salad.verify_time}, gap={salad.gap}")
    print(f"Sauce:   create={sauce.create_time}, verify={sauce.verify_time}, gap={sauce.gap}")

    # Theorem 3.1: Gap additivity under sequential composition
    seq_result = souffle.seq(salad)
    print(f"\n--- Theorem 3.1: Gap Additivity (Sequential) ---")
    print(f"Soufflé then Salad: gap = {seq_result.gap}")
    print(f"Sum of gaps: {souffle.gap} + {salad.gap} = {souffle.gap + salad.gap}")
    print(f"Verified: {verify_gap_additivity(souffle, salad)}")

    # Theorem 3.2: Gap subadditivity under parallel composition
    par_result = souffle.par(sauce)
    print(f"\n--- Theorem 3.2: Gap Subadditivity (Parallel) ---")
    print(f"Soufflé || Sauce: gap = {par_result.gap}")
    print(f"Max of gaps: max({souffle.gap}, {sauce.gap}) = {max(souffle.gap, sauce.gap)}")
    print(f"Verified: {verify_gap_subadditivity(souffle, sauce)}")

    # Theorem 3.3: Linear gap scaling under iteration
    print(f"\n--- Theorem 3.3: Linear Gap Scaling (Iteration) ---")
    for n in [1, 2, 5, 10]:
        iterated = souffle.iterate(n)
        print(f"Soufflé × {n}: gap = {iterated.gap}, expected = {n * souffle.gap}, "
              f"verified = {verify_gap_iteration(souffle, n)}")


def demo_tropical_distributive():
    """Demonstrate the tropical distributive law."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Distributive Law")
    print("=" * 60)

    r = RecipeStep(create_time=10, verify_time=3)
    s = RecipeStep(create_time=20, verify_time=8)
    t = RecipeStep(create_time=15, verify_time=5)

    lhs = r.seq(s.par(t))
    rhs = r.seq(s).par(r.seq(t))

    print(f"\nr = ({r.create_time}, {r.verify_time})")
    print(f"s = ({s.create_time}, {s.verify_time})")
    print(f"t = ({t.create_time}, {t.verify_time})")
    print(f"\nr.seq(s.par(t)): create={lhs.create_time}, verify={lhs.verify_time}")
    print(f"(r.seq(s)).par(r.seq(t)): create={rhs.create_time}, verify={rhs.verify_time}")
    print(f"Distributive law holds: {verify_tropical_distributive(r, s, t)}")
    print(f"\nThis is a + max(b,c) = max(a+b, a+c):")
    print(f"  10 + max(20,15) = 10 + 20 = {10 + max(20,15)}")
    print(f"  max(10+20, 10+15) = max(30, 25) = {max(10+20, 10+15)}")


def demo_critical_path():
    """Demonstrate critical path bounds."""
    print("\n" + "=" * 60)
    print("DEMO 3: Critical Path Bounds")
    print("=" * 60)

    durations = [10, 25, 15, 8, 30, 12]
    v = TropicalScheduleVector(durations)

    print(f"\nTask durations: {durations}")
    print(f"Critical path (max): {v.critical_path}")
    print(f"Sequential total (sum): {v.seq_total}")
    print(f"Average duration: {v.average_duration:.1f}")
    print(f"Parallelism speedup: {v.parallelism_speedup:.2f}x")
    print(f"\nBounds verified: {verify_critical_path_bounds(durations)}")
    print(f"  avg = {v.average_duration:.1f} ≤ critical_path = {v.critical_path} ≤ seq_total = {v.seq_total}")


def demo_pipeline():
    """Demonstrate pipeline throughput theory."""
    print("\n" + "=" * 60)
    print("DEMO 4: Pipeline Throughput")
    print("=" * 60)

    # A 5-stage cooking pipeline
    stages = [5, 12, 8, 3, 7]  # prep, cook, plate, garnish, serve
    p = Pipeline(stages)

    print(f"\nPipeline stages: {stages}")
    print(f"  (prep=5, cook=12, plate=8, garnish=3, serve=7)")
    print(f"Bottleneck (tropical eigenvalue): {p.bottleneck}")
    print(f"Latency: {p.latency}")
    print(f"Steady-state throughput: {p.steady_state_throughput():.4f} items/time")

    print(f"\nPipeline timing for k items:")
    for k in [1, 2, 5, 10, 50, 100]:
        total = p.throughput_time(k)
        effective_throughput = k / total if total > 0 else 0
        print(f"  k={k:3d}: total_time={total:5d}, throughput={effective_throughput:.4f}, "
              f"→ approaches {p.steady_state_throughput():.4f}")


def demo_complexity_classes():
    """Demonstrate recipe complexity classification."""
    print("\n" + "=" * 60)
    print("DEMO 5: Recipe Complexity Classes")
    print("=" * 60)

    # Trivial gap: create and verify grow at the same rate
    trivial_family = [(n + 5, n + 3) for n in range(1, 20)]
    print(f"\nTrivial gap family (constant gap=2):")
    print(f"  Classification: {classify_gap(trivial_family)}")

    # Linear gap: gap grows linearly
    linear_family = [(3 * n, n) for n in range(1, 20)]
    print(f"\nLinear gap family (gap=2n):")
    print(f"  Classification: {classify_gap(linear_family)}")

    # Superlinear gap: gap grows quadratically
    superlinear_family = [(n * n + n, n) for n in range(1, 20)]
    print(f"\nSuperlinear gap family (gap=n²):")
    print(f"  Classification: {classify_gap(superlinear_family)}")

    # Iteration produces linear gap
    step = RecipeStep(create_time=10, verify_time=3)  # gap = 7
    iter_family = [(step.iterate(n).create_time, step.iterate(n).verify_time)
                   for n in range(1, 20)]
    print(f"\nIterated step (gap=7) family:")
    print(f"  Classification: {classify_gap(iter_family)}")
    print(f"  (Theorem 6.1: iteration of positive-gap step → LINEAR)")


def demo_tropical_matrix():
    """Demonstrate tropical matrix operations for scheduling."""
    print("\n" + "=" * 60)
    print("DEMO 6: Tropical Matrix Algebra for Scheduling")
    print("=" * 60)

    NEG_INF = -10**18

    # A 3-stage pipeline as a tropical matrix
    # M[i][j] = time to go from stage i to stage j
    # Pipeline: 1 → 2 → 3
    M = [
        [NEG_INF, 5, NEG_INF],  # Stage 1: takes 5 units to reach stage 2
        [NEG_INF, NEG_INF, 8],  # Stage 2: takes 8 units to reach stage 3
        [3, NEG_INF, NEG_INF],  # Stage 3: takes 3 units to cycle back to stage 1
    ]

    print(f"\nTropical adjacency matrix (pipeline 1→2→3→1):")
    labels = ["S1", "S2", "S3"]
    for i, row in enumerate(M):
        entries = [f"{v:4d}" if v > NEG_INF else " -∞ " for v in row]
        print(f"  {labels[i]}: [{', '.join(entries)}]")

    sr = tropical_spectral_radius(M)
    print(f"\nTropical spectral radius: {sr:.2f}")
    print(f"  (= max cycle mean = (5+8+3)/3 = {(5+8+3)/3:.2f})")
    print(f"  This determines steady-state throughput: 1/{sr:.2f} = {1/sr:.4f} items/time")

    # M² in tropical algebra
    M2 = tropical_matrix_multiply(M, M)
    print(f"\nM² (tropical, 2-step paths):")
    for i, row in enumerate(M2):
        entries = [f"{v:4d}" if v > NEG_INF else " -∞ " for v in row]
        print(f"  {labels[i]}: [{', '.join(entries)}]")


def demo_gap_refinement():
    """Demonstrate gap refinement invariance."""
    print("\n" + "=" * 60)
    print("DEMO 7: Gap Refinement Invariance (Theorem 7.1)")
    print("=" * 60)

    original = RecipeStep(create_time=30, verify_time=10)
    print(f"\nOriginal step: create={original.create_time}, verify={original.verify_time}, gap={original.gap}")

    # Various refinements that preserve total times
    refinements = [
        (RecipeStep(15, 5), RecipeStep(15, 5)),
        (RecipeStep(20, 8), RecipeStep(10, 2)),
        (RecipeStep(25, 9), RecipeStep(5, 1)),
        (RecipeStep(30, 10), RecipeStep(0, 0)),
        (RecipeStep(10, 3), RecipeStep(20, 7)),
    ]

    for r1, r2 in refinements:
        composed = r1.seq(r2)
        print(f"\n  Split into ({r1.create_time},{r1.verify_time}) + ({r2.create_time},{r2.verify_time}):")
        print(f"    Composed: create={composed.create_time}, verify={composed.verify_time}, gap={composed.gap}")
        print(f"    Gap preserved: {composed.gap == original.gap}")


def demo_conjecture_test():
    """Test the falsifiable conjecture about gap ratio monotonicity."""
    print("\n" + "=" * 60)
    print("DEMO 8: Conjecture Testing — Gap Ratio Under Refinement")
    print("=" * 60)

    print("\nConjecture: The gap is exactly preserved under refinement")
    print("(splitting a task into subtasks with the same total times).")
    print("\nSearching for counterexamples...")

    counterexamples = 0
    tests = 0
    for c in range(1, 30):
        for v in range(0, c + 1):
            r = RecipeStep(c, v)
            for c1 in range(0, c + 1):
                for v1 in range(0, min(c1 + 1, v + 1)):
                    c2 = c - c1
                    v2 = v - v1
                    if v2 > c2:
                        continue
                    r1 = RecipeStep(c1, v1)
                    r2 = RecipeStep(c2, v2)
                    composed = r1.seq(r2)
                    tests += 1
                    if composed.gap != r.gap:
                        counterexamples += 1
                        print(f"  COUNTEREXAMPLE: ({c},{v}) split into ({c1},{v1})+({c2},{v2}), "
                              f"gap changed from {r.gap} to {composed.gap}")

    print(f"\nTests run: {tests}")
    print(f"Counterexamples found: {counterexamples}")
    if counterexamples == 0:
        print("✓ Conjecture confirmed by exhaustive search (c ≤ 29)")
    else:
        print("✗ Conjecture REFUTED")


if __name__ == "__main__":
    demo_gap_theorems()
    demo_tropical_distributive()
    demo_critical_path()
    demo_pipeline()
    demo_complexity_classes()
    demo_tropical_matrix()
    demo_gap_refinement()
    demo_conjecture_test()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


"""
Visualization: Gap Scaling Under Composition Operations

Shows how the creation-verification gap behaves under sequential
composition (additive), parallel composition (subadditive), and
iteration (linear scaling).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def make_recipe_step(create_time: int, verify_time: int) -> dict:
    return {'c': create_time, 'v': verify_time, 'gap': create_time - verify_time}


def seq(r: dict, s: dict) -> dict:
    return make_recipe_step(r['c'] + s['c'], r['v'] + s['v'])


def par(r: dict, s: dict) -> dict:
    return make_recipe_step(max(r['c'], s['c']), max(r['v'], s['v']))


def iterate(r: dict, n: int) -> dict:
    return make_recipe_step(n * r['c'], n * r['v'])


def main():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Creation-Verification Gap: Algebraic Properties',
                 fontsize=16, fontweight='bold')

    # Panel 1: Gap additivity under sequential composition
    ax = axes[0, 0]
    r = make_recipe_step(20, 5)
    s = make_recipe_step(15, 8)
    ns = range(1, 16)
    seq_gaps = []
    sum_gaps = []
    current = make_recipe_step(0, 0)
    for i in range(15):
        step = r if i % 2 == 0 else s
        current = seq(current, step)
        seq_gaps.append(current['gap'])
        expected = ((i // 2 + 1) * r['gap'] + ((i + 1) // 2) * s['gap'])
        sum_gaps.append(expected)

    ax.plot(ns, seq_gaps, 'bo-', label='Actual gap', markersize=6)
    ax.plot(ns, sum_gaps, 'r--', label='Sum of individual gaps', linewidth=2)
    ax.set_xlabel('Number of sequential steps')
    ax.set_ylabel('Gap')
    ax.set_title('Theorem 3.1: Gap Additivity\n(Sequential Composition)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Gap subadditivity under parallel composition
    ax = axes[0, 1]
    test_cases = []
    for _ in range(200):
        c1, v1 = np.random.randint(1, 50), 0
        v1 = np.random.randint(0, c1 + 1)
        c2, v2 = np.random.randint(1, 50), 0
        v2 = np.random.randint(0, c2 + 1)
        r_test = make_recipe_step(c1, v1)
        s_test = make_recipe_step(c2, v2)
        p = par(r_test, s_test)
        test_cases.append((max(r_test['gap'], s_test['gap']), p['gap']))

    max_gaps = [t[0] for t in test_cases]
    par_gaps = [t[1] for t in test_cases]
    ax.scatter(max_gaps, par_gaps, alpha=0.5, s=20, c='steelblue')
    line_max = max(max(max_gaps), max(par_gaps))
    ax.plot([0, line_max], [0, line_max], 'r--', label='y = x (upper bound)')
    ax.set_xlabel('max(gap(r), gap(s))')
    ax.set_ylabel('gap(r ∥ s)')
    ax.set_title('Theorem 3.2: Gap Subadditivity\n(Parallel Composition)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Linear gap scaling under iteration
    ax = axes[1, 0]
    steps = [
        make_recipe_step(10, 3),   # gap = 7
        make_recipe_step(20, 12),  # gap = 8
        make_recipe_step(50, 5),   # gap = 45
    ]
    colors = ['steelblue', 'darkorange', 'seagreen']
    ns = range(0, 21)
    for step, color in zip(steps, colors):
        gaps = [iterate(step, n)['gap'] for n in ns]
        ax.plot(ns, gaps, 'o-', color=color, markersize=4,
                label=f'gap={step["gap"]} (c={step["c"]}, v={step["v"]})')

    ax.set_xlabel('Number of iterations n')
    ax.set_ylabel('gap(r^n)')
    ax.set_title('Theorem 3.3: Linear Gap Scaling\n(Iteration)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 4: Tropical distributive law verification
    ax = axes[1, 1]
    errors = []
    for _ in range(500):
        cr, vr = np.random.randint(1, 30), 0
        vr = np.random.randint(0, cr + 1)
        cs, vs_ = np.random.randint(1, 30), 0
        vs_ = np.random.randint(0, cs + 1)
        ct, vt = np.random.randint(1, 30), 0
        vt = np.random.randint(0, ct + 1)
        r_t = make_recipe_step(cr, vr)
        s_t = make_recipe_step(cs, vs_)
        t_t = make_recipe_step(ct, vt)
        lhs = seq(r_t, par(s_t, t_t))
        rhs = par(seq(r_t, s_t), seq(r_t, t_t))
        errors.append(abs(lhs['c'] - rhs['c']) + abs(lhs['v'] - rhs['v']))

    ax.hist(errors, bins=range(-1, 3), color='seagreen', edgecolor='black', alpha=0.8)
    ax.set_xlabel('|LHS - RHS| (should be 0)')
    ax.set_ylabel('Count')
    ax.set_title('Theorem 5.1: Tropical Distributive Law\n(500 random tests, all exact)')
    ax.set_xlim(-0.5, 2.5)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_gap_scaling.png', dpi=150, bbox_inches='tight')
    print("Saved viz_gap_scaling.png")


if __name__ == '__main__':
    np.random.seed(42)
    main()


"""
Visualization: Pipeline Throughput and Tropical Eigenvalues

Shows how pipeline throughput approaches the steady-state limit
determined by the bottleneck (tropical spectral radius), and
compares different pipeline configurations.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def pipeline_total_time(stage_times: list, k: int) -> int:
    """Total time for k items through a pipeline."""
    if k <= 0:
        return 0
    latency = sum(stage_times)
    bottleneck = max(stage_times)
    return latency + (k - 1) * bottleneck


def main():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Pipeline Throughput Theory: Tropical Spectral Radius',
                 fontsize=16, fontweight='bold')

    # Panel 1: Throughput convergence for different pipelines
    ax = axes[0, 0]
    pipelines = {
        'Balanced (5,5,5,5,5)': [5, 5, 5, 5, 5],
        'Bottleneck (2,2,15,2,2)': [2, 2, 15, 2, 2],
        'Gradient (3,5,7,9,11)': [3, 5, 7, 9, 11],
        'Kitchen (5,12,8,3,7)': [5, 12, 8, 3, 7],
    }
    colors = ['steelblue', 'darkorange', 'seagreen', 'mediumpurple']
    ks = range(1, 101)

    for (name, stages), color in zip(pipelines.items(), colors):
        throughputs = [k / pipeline_total_time(stages, k) for k in ks]
        steady_state = 1.0 / max(stages)
        ax.plot(ks, throughputs, color=color, label=f'{name}', linewidth=1.5)
        ax.axhline(y=steady_state, color=color, linestyle='--', alpha=0.4)

    ax.set_xlabel('Batch size k')
    ax.set_ylabel('Throughput (items/time)')
    ax.set_title('Throughput Convergence\n(dashed = steady-state limit)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 2: Latency vs batch size breakdown
    ax = axes[0, 1]
    stages = [5, 12, 8, 3, 7]
    latency = sum(stages)
    bottleneck = max(stages)
    ks_arr = np.arange(1, 51)
    total_times = [pipeline_total_time(stages, k) for k in ks_arr]
    latency_portion = [latency] * len(ks_arr)
    pipeline_portion = [(k - 1) * bottleneck for k in ks_arr]

    ax.fill_between(ks_arr, 0, latency_portion, alpha=0.4, color='steelblue',
                     label=f'Latency ({latency})')
    ax.fill_between(ks_arr, latency_portion,
                     [l + p for l, p in zip(latency_portion, pipeline_portion)],
                     alpha=0.4, color='darkorange',
                     label=f'Pipeline fill ((k-1)×{bottleneck})')
    ax.plot(ks_arr, total_times, 'k-', linewidth=2, label='Total time')
    ax.set_xlabel('Batch size k')
    ax.set_ylabel('Time')
    ax.set_title('Pipeline Time Decomposition\n(Kitchen pipeline)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: Critical path vs sequential total
    ax = axes[1, 0]
    np.random.seed(42)
    n_tasks_range = range(2, 31)
    ratios = []
    for n in n_tasks_range:
        trial_ratios = []
        for _ in range(100):
            durations = np.random.randint(1, 50, size=n)
            cp = np.max(durations)
            st = np.sum(durations)
            trial_ratios.append(st / cp)
        ratios.append((np.mean(trial_ratios), np.std(trial_ratios)))

    means = [r[0] for r in ratios]
    stds = [r[1] for r in ratios]
    ax.plot(list(n_tasks_range), means, 'bo-', markersize=4, label='Mean speedup')
    ax.fill_between(list(n_tasks_range),
                     [m - s for m, s in zip(means, stds)],
                     [m + s for m, s in zip(means, stds)],
                     alpha=0.2, color='steelblue')
    ax.plot(list(n_tasks_range), list(n_tasks_range), 'r--',
            label='Perfect linear speedup', alpha=0.5)
    ax.set_xlabel('Number of parallel tasks n')
    ax.set_ylabel('Parallelism speedup (seq_total / critical_path)')
    ax.set_title('Parallelism Speedup\n(100 random trials per n)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 4: Recipe complexity class visualization
    ax = axes[1, 1]
    ns = np.arange(1, 31)
    trivial_gaps = [2] * len(ns)
    linear_gaps = [3 * n for n in ns]
    super_gaps = [n * n for n in ns]

    ax.plot(ns, trivial_gaps, 'o-', color='seagreen', label='Trivial (gap=2)',
            markersize=4)
    ax.plot(ns, linear_gaps, 's-', color='darkorange', label='Linear (gap=3n)',
            markersize=4)
    ax.plot(ns, super_gaps, '^-', color='crimson', label='Superlinear (gap=n²)',
            markersize=4)
    ax.set_xlabel('Problem size n')
    ax.set_ylabel('Creation-Verification gap')
    ax.set_title('Recipe Complexity Classes\n(Gap Growth Rates)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')

    plt.tight_layout()
    plt.savefig('viz_pipeline_throughput.png', dpi=150, bbox_inches='tight')
    print("Saved viz_pipeline_throughput.png")


if __name__ == '__main__':
    main()


"""
Visualization: Tropical Matrix Powers and Scheduling Networks

Shows how tropical (max-plus) matrix powers compute multi-step
critical paths in scheduling networks, visualized as heatmaps.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


NEG_INF = -10**18


def tropical_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Max-plus matrix multiplication."""
    n, p = A.shape
    p2, m = B.shape
    assert p == p2
    C = np.full((n, m), NEG_INF, dtype=np.int64)
    for i in range(n):
        for j in range(m):
            for k in range(p):
                if A[i, k] > NEG_INF and B[k, j] > NEG_INF:
                    val = A[i, k] + B[k, j]
                    if val > C[i, j]:
                        C[i, j] = val
    return C


def tropical_power(M: np.ndarray, power: int) -> np.ndarray:
    """Compute M^power in max-plus semiring."""
    n = M.shape[0]
    result = np.full((n, n), NEG_INF, dtype=np.int64)
    np.fill_diagonal(result, 0)
    base = M.copy()
    while power > 0:
        if power % 2 == 1:
            result = tropical_multiply(result, base)
        base = tropical_multiply(base, base)
        power //= 2
    return result


def main():
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Tropical Matrix Powers: Multi-Step Critical Paths',
                 fontsize=16, fontweight='bold')

    # Define a 5-node scheduling network
    # Represents: prep → cook → plate, with parallel paths
    n = 5
    labels = ['Prep', 'Marinate', 'Cook', 'Plate', 'Serve']
    M = np.full((n, n), NEG_INF, dtype=np.int64)
    # Edges with weights (processing times)
    edges = [
        (0, 1, 5),   # Prep → Marinate
        (0, 2, 3),   # Prep → Cook (direct)
        (1, 2, 8),   # Marinate → Cook
        (2, 3, 4),   # Cook → Plate
        (2, 4, 6),   # Cook → Serve (shortcut)
        (3, 4, 2),   # Plate → Serve
        (1, 3, 7),   # Marinate → Plate (direct)
    ]
    for i, j, w in edges:
        M[i, j] = w

    powers = [1, 2, 3, 4, 5, 6]
    for idx, p in enumerate(powers):
        ax = axes[idx // 3, idx % 3]
        Mp = tropical_power(M, p)

        # Create display matrix (replace NEG_INF with NaN for visualization)
        display = np.where(Mp > NEG_INF, Mp, np.nan).astype(float)

        im = ax.imshow(display, cmap='YlOrRd', aspect='equal',
                        interpolation='nearest')

        # Add text annotations
        for i in range(n):
            for j in range(n):
                if Mp[i, j] > NEG_INF:
                    ax.text(j, i, f'{Mp[i, j]}', ha='center', va='center',
                            fontsize=9, fontweight='bold')
                else:
                    ax.text(j, i, '−∞', ha='center', va='center',
                            fontsize=8, color='gray')

        ax.set_xticks(range(n))
        ax.set_yticks(range(n))
        ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
        ax.set_yticklabels(labels, fontsize=8)
        ax.set_title(f'M^{p} (max {p}-step paths)', fontsize=11)
        plt.colorbar(im, ax=ax, shrink=0.8)

    plt.tight_layout()
    plt.savefig('viz_tropical_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved viz_tropical_heatmap.png")


if __name__ == '__main__':
    main()
