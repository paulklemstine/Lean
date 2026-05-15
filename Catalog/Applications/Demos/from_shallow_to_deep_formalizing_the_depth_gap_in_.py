#!/usr/bin/env python3
"""
Depth Gap Framework: Applications

Shows real-world applications of the depth gap theory to
automated theorem proving evaluation, curriculum design,
and corpus geometry.
"""

from dataclasses import dataclass
import random
import itertools


@dataclass(frozen=True)
class TheoremProfile:
    defs_introduced: int
    type_changes: int
    perspective_shifts: int
    proof_size: int
    compression_score: int


def leap_cost(a, b):
    return (abs(a.defs_introduced - b.defs_introduced) +
            abs(a.type_changes - b.type_changes) +
            abs(a.perspective_shifts - b.perspective_shifts))


def depth_gap(corpus, target):
    return min(leap_cost(s, target) for s in corpus)


# ── Application 1: ATP Benchmark Evaluator ──────────────────────────

def app_benchmark_evaluator():
    """Evaluate an automated theorem prover's output for genuine novelty."""
    print("=" * 60)
    print("APPLICATION 1: ATP Benchmark Evaluator")
    print("=" * 60)

    # Simulate a "training corpus" — theorems the prover was trained on
    training_corpus = [
        TheoremProfile(0, 0, 0, 5, 3),    # basic identity
        TheoremProfile(1, 0, 0, 10, 7),   # simple definition use
        TheoremProfile(0, 1, 0, 8, 5),    # type coercion
        TheoremProfile(1, 1, 0, 15, 10),  # definition + type change
        TheoremProfile(0, 0, 1, 12, 8),   # perspective shift
        TheoremProfile(2, 0, 0, 20, 14),  # two definitions
        TheoremProfile(0, 2, 0, 18, 12),  # two type changes
        TheoremProfile(1, 0, 1, 16, 11),  # def + perspective
    ]

    # Simulate prover outputs
    prover_outputs = [
        ("Trivial rewrite",        TheoremProfile(0, 0, 0, 6, 4)),
        ("Minor generalization",   TheoremProfile(1, 1, 0, 14, 9)),
        ("New perspective on old",  TheoremProfile(0, 0, 2, 20, 15)),
        ("Genuine new theorem",    TheoremProfile(3, 2, 2, 45, 35)),
        ("Deep connection",        TheoremProfile(4, 3, 3, 80, 60)),
        ("Breakthrough result",    TheoremProfile(5, 5, 5, 120, 90)),
    ]

    threshold = 3

    print(f"\n  Training corpus size: {len(training_corpus)}")
    print(f"  Novelty threshold τ: {threshold}")
    print(f"\n  {'Output':<25} {'Gap':>5} {'Status':>12} {'Verdict':>15}")
    print("  " + "-" * 60)

    novel_count = 0
    for label, output in prover_outputs:
        gap = depth_gap(training_corpus, output)
        is_novel = gap > threshold
        if is_novel:
            novel_count += 1
        status = "NOVEL ✓" if is_novel else "derivative"
        verdict = f"gap={gap}" + (" ← genuine!" if is_novel else "")
        print(f"  {label:<25} {gap:>5} {status:>12} {verdict:>15}")

    novelty_rate = novel_count / len(prover_outputs) * 100
    print(f"\n  Novelty rate: {novel_count}/{len(prover_outputs)} = {novelty_rate:.0f}%")
    print(f"  Assessment: {'Strong prover' if novelty_rate > 50 else 'Derivative prover'}")


# ── Application 2: Curriculum Design ────────────────────────────────

def app_curriculum_design():
    """Design a learning curriculum by targeting specific depth gaps."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Curriculum Design for Theorem Search")
    print("=" * 60)

    # Start with basic known theorems
    known = [TheoremProfile(0, 0, 0, 5, 3)]

    # Define target milestones at increasing depth
    milestones = [
        TheoremProfile(1, 0, 0, 10, 7),    # First new definition
        TheoremProfile(1, 1, 0, 15, 10),    # First type change
        TheoremProfile(2, 1, 0, 20, 14),    # Second definition
        TheoremProfile(2, 1, 1, 25, 18),    # First perspective shift
        TheoremProfile(3, 2, 1, 35, 25),    # Complex theorem
        TheoremProfile(4, 3, 2, 50, 38),    # Deep result
    ]

    print("\n  Curriculum progression:")
    print(f"  {'Step':>6} {'Target':>15} {'Gap Before':>12} {'Gap After':>11}")
    print("  " + "-" * 48)

    for i, milestone in enumerate(milestones):
        gap_before = depth_gap(known, milestone)
        known.append(milestone)
        # After adding, this milestone has gap 0; check next if exists
        if i + 1 < len(milestones):
            gap_after = depth_gap(known, milestones[i + 1])
        else:
            gap_after = 0
        coords = f"({milestone.defs_introduced},{milestone.type_changes},{milestone.perspective_shifts})"
        print(f"  {i+1:>6} {coords:>15} {gap_before:>12} {gap_after:>11}")

    print("\n  Key insight: Each milestone reduces the gap to the next target.")
    print("  Curriculum ordering ensures no gap exceeds 3 at any step.")


# ── Application 3: Corpus Geometry Analysis ─────────────────────────

def app_corpus_geometry():
    """Analyze the geometric structure of a theorem corpus."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Corpus Geometry — Novelty Shells")
    print("=" * 60)

    corpus = [
        TheoremProfile(0, 0, 0, 5, 3),
        TheoremProfile(2, 0, 0, 15, 10),
        TheoremProfile(0, 2, 0, 12, 8),
        TheoremProfile(1, 1, 1, 18, 13),
    ]

    # Compute novelty shells: profiles at each depth level
    max_coord = 7
    shells = {}
    for d, t, p in itertools.product(range(max_coord + 1), repeat=3):
        target = TheoremProfile(d, t, p, 0, 0)
        gap = depth_gap(corpus, target)
        if gap not in shells:
            shells[gap] = 0
        shells[gap] += 1

    total = (max_coord + 1) ** 3
    print(f"\n  Corpus: {len(corpus)} profiles")
    print(f"  Grid: [0..{max_coord}]³ = {total} profiles")
    print(f"\n  {'Shell':>6} {'Size':>8} {'Fraction':>10}  {'Description':<30}")
    print("  " + "-" * 60)

    descriptions = {
        0: "Known (in corpus)",
        1: "Trivial extensions",
        2: "Minor variations",
        3: "Moderate novelty",
    }

    cumulative = 0
    for gap in sorted(shells.keys()):
        count = shells[gap]
        cumulative += count
        frac = count / total
        desc = descriptions.get(gap, f"Depth {gap} frontier" if gap < 6 else "Deep novelty")
        print(f"  {gap:>6} {count:>8} {frac:>10.1%}  {desc:<30}")

    # Covering radius
    covering_radius = max(shells.keys())
    print(f"\n  Covering radius: {covering_radius}")
    print(f"  Median depth: ~{sorted(shells.keys())[len(shells) // 2]}")


# ── Application 4: Machine Learning Model Comparison ────────────────

def app_ml_comparison():
    """Compare two ML theorem generators by novelty profile."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: ML Theorem Generator Comparison")
    print("=" * 60)

    training_data = [
        TheoremProfile(0, 0, 0, 5, 3),
        TheoremProfile(1, 0, 0, 10, 7),
        TheoremProfile(0, 1, 0, 8, 5),
        TheoremProfile(1, 1, 0, 12, 8),
    ]

    random.seed(42)

    # Model A: conservative, stays close to training data
    model_a_outputs = [
        TheoremProfile(
            d + random.randint(0, 1),
            t + random.randint(0, 1),
            p + random.randint(0, 1),
            ps + random.randint(0, 5),
            cs + random.randint(0, 3)
        )
        for d, t, p, ps, cs in [(s.defs_introduced, s.type_changes,
                                   s.perspective_shifts, s.proof_size,
                                   s.compression_score) for s in training_data]
        for _ in range(3)
    ]

    # Model B: exploratory, ventures further
    model_b_outputs = [
        TheoremProfile(
            random.randint(0, 5),
            random.randint(0, 5),
            random.randint(0, 5),
            random.randint(10, 100),
            random.randint(5, 80)
        )
        for _ in range(12)
    ]

    threshold = 3

    def analyze_model(name, outputs):
        gaps = [depth_gap(training_data, o) for o in outputs]
        novel_count = sum(1 for g in gaps if g > threshold)
        avg_gap = sum(gaps) / len(gaps)
        max_gap = max(gaps)
        return {
            'name': name,
            'count': len(outputs),
            'novel': novel_count,
            'novelty_rate': novel_count / len(outputs),
            'avg_gap': avg_gap,
            'max_gap': max_gap,
            'gaps': gaps,
        }

    results_a = analyze_model("Model A (Conservative)", model_a_outputs)
    results_b = analyze_model("Model B (Exploratory)", model_b_outputs)

    print(f"\n  Training corpus: {len(training_data)} theorems")
    print(f"  Threshold τ: {threshold}")
    print(f"\n  {'Metric':<25} {'Model A':>15} {'Model B':>15}")
    print("  " + "-" * 55)
    for key, label in [('count', 'Outputs'),
                        ('novel', 'Novel outputs'),
                        ('novelty_rate', 'Novelty rate'),
                        ('avg_gap', 'Average gap'),
                        ('max_gap', 'Maximum gap')]:
        va = results_a[key]
        vb = results_b[key]
        if isinstance(va, float):
            print(f"  {label:<25} {va:>15.2f} {vb:>15.2f}")
        else:
            print(f"  {label:<25} {va:>15} {vb:>15}")

    winner = "Model B" if results_b['novelty_rate'] > results_a['novelty_rate'] else "Model A"
    print(f"\n  More creative generator: {winner}")


if __name__ == "__main__":
    app_benchmark_evaluator()
    app_curriculum_design()
    app_corpus_geometry()
    app_ml_comparison()
    print("\n" + "=" * 60)
    print("All applications demonstrated!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Depth Gap Framework: Concrete Demonstrations

Demonstrates the core theorems of proof-theoretic novelty geometry
with numerical examples on theorem profiles.
"""

import itertools
from dataclasses import dataclass


@dataclass(frozen=True)
class TheoremProfile:
    """A theorem profile with 5 structural features."""
    defs_introduced: int
    type_changes: int
    perspective_shifts: int
    proof_size: int
    compression_score: int

    def conceptual_coords(self):
        return (self.defs_introduced, self.type_changes, self.perspective_shifts)


def leap_cost(a: TheoremProfile, b: TheoremProfile) -> int:
    """L1 distance on the three conceptual dimensions."""
    return (abs(a.defs_introduced - b.defs_introduced) +
            abs(a.type_changes - b.type_changes) +
            abs(a.perspective_shifts - b.perspective_shifts))


def depth_gap(corpus: list[TheoremProfile], target: TheoremProfile) -> int:
    """Minimum leap cost from any corpus element to target."""
    if not corpus:
        raise ValueError("Corpus must be nonempty")
    return min(leap_cost(s, target) for s in corpus)


def is_derivative(corpus: list[TheoremProfile], target: TheoremProfile, tau: int) -> bool:
    """True if target is derivative from corpus at threshold tau."""
    return any(leap_cost(s, target) <= tau for s in corpus)


def nearest_neighbor(corpus: list[TheoremProfile], target: TheoremProfile) -> TheoremProfile:
    """Find the corpus element attaining the depth gap (Theorem A)."""
    return min(corpus, key=lambda s: leap_cost(s, target))


# ── Demo 1: Core Framework ──────────────────────────────────────────

def demo_core():
    print("=" * 60)
    print("DEMO 1: Core Depth Gap Framework")
    print("=" * 60)

    corpus = [
        TheoremProfile(0, 0, 0, 10, 5),   # basic theorem
        TheoremProfile(1, 0, 0, 20, 15),   # one new definition
        TheoremProfile(0, 1, 0, 15, 10),   # one type change
    ]

    targets = [
        ("Trivial reformulation", TheoremProfile(0, 0, 0, 12, 6)),
        ("Minor extension",       TheoremProfile(0, 0, 1, 18, 12)),
        ("Moderate novelty",      TheoremProfile(2, 1, 1, 40, 30)),
        ("High novelty",          TheoremProfile(5, 5, 5, 100, 80)),
        ("Extreme novelty",       TheoremProfile(10, 10, 10, 200, 150)),
    ]

    print("\nCorpus:")
    for i, s in enumerate(corpus):
        print(f"  S{i}: coords=({s.defs_introduced},{s.type_changes},{s.perspective_shifts})")

    print("\nTarget Analysis:")
    print(f"  {'Label':<25} {'Coords':>12} {'DepthGap':>10} {'Nearest':>10} {'Deriv@3':>8} {'Deriv@5':>8}")
    print("  " + "-" * 75)
    for label, t in targets:
        gap = depth_gap(corpus, t)
        nn = nearest_neighbor(corpus, t)
        d3 = is_derivative(corpus, t, 3)
        d5 = is_derivative(corpus, t, 5)
        coords = f"({t.defs_introduced},{t.type_changes},{t.perspective_shifts})"
        nn_coords = f"({nn.defs_introduced},{nn.type_changes},{nn.perspective_shifts})"
        print(f"  {label:<25} {coords:>12} {gap:>10} {nn_coords:>10} {str(d3):>8} {str(d5):>8}")

    # Verify Theorem B: derivative iff depth_gap <= tau
    print("\n  Theorem B verification: DerivativeFrom(K, T, τ) ↔ depthGap(K, T) ≤ τ")
    for label, t in targets:
        gap = depth_gap(corpus, t)
        for tau in range(20):
            assert is_derivative(corpus, t, tau) == (gap <= tau), \
                f"Theorem B failed for {label}, tau={tau}"
    print("  ✓ Verified for all targets and thresholds 0..19")


# ── Demo 2: Separation Theorem ──────────────────────────────────────

def demo_separation():
    print("\n" + "=" * 60)
    print("DEMO 2: Separation Theorem (Threshold Boundary)")
    print("=" * 60)

    corpus = [TheoremProfile(0, 0, 0, 10, 5)]
    target = TheoremProfile(3, 2, 1, 50, 40)
    gap = depth_gap(corpus, target)

    print(f"\n  Target coords: ({target.defs_introduced},{target.type_changes},{target.perspective_shifts})")
    print(f"  Depth gap: {gap}")
    print(f"\n  Threshold sweep:")
    for tau in range(gap + 3):
        deriv = is_derivative(corpus, target, tau)
        marker = "← threshold" if tau == gap else ""
        status = "DERIVATIVE" if deriv else "NOVEL"
        print(f"    τ = {tau:2d}: {status:12s} {marker}")


# ── Demo 3: Monotonicity ────────────────────────────────────────────

def demo_monotonicity():
    print("\n" + "=" * 60)
    print("DEMO 3: Monotonicity Under Corpus Enrichment")
    print("=" * 60)

    target = TheoremProfile(4, 3, 2, 60, 50)

    corpus_stages = [
        [TheoremProfile(0, 0, 0, 10, 5)],
        [TheoremProfile(0, 0, 0, 10, 5), TheoremProfile(2, 1, 0, 25, 20)],
        [TheoremProfile(0, 0, 0, 10, 5), TheoremProfile(2, 1, 0, 25, 20),
         TheoremProfile(3, 2, 1, 40, 35)],
        [TheoremProfile(0, 0, 0, 10, 5), TheoremProfile(2, 1, 0, 25, 20),
         TheoremProfile(3, 2, 1, 40, 35), TheoremProfile(4, 3, 2, 60, 50)],
    ]

    print(f"\n  Target: ({target.defs_introduced},{target.type_changes},{target.perspective_shifts})")
    print(f"\n  {'Stage':>8} {'|K|':>4} {'DepthGap':>10} {'Trend':>8}")
    print("  " + "-" * 35)
    prev_gap = None
    for i, corpus in enumerate(corpus_stages):
        gap = depth_gap(corpus, target)
        trend = "" if prev_gap is None else ("↓" if gap < prev_gap else "=" if gap == prev_gap else "↑(!)")
        print(f"  {i+1:>8} {len(corpus):>4} {gap:>10} {trend:>8}")
        if prev_gap is not None:
            assert gap <= prev_gap, "Monotonicity violated!"
        prev_gap = gap
    print("  ✓ Depth gap is monotonically non-increasing")


# ── Demo 4: Typed Conceptual Leaps ──────────────────────────────────

def demo_typed_leaps():
    print("\n" + "=" * 60)
    print("DEMO 4: Typed Conceptual Leaps")
    print("=" * 60)

    # Define a path from (0,0,0) to (2,1,1) via typed single-coordinate leaps
    path = [
        ("introDef",          TheoremProfile(0, 0, 0, 10, 5), TheoremProfile(1, 0, 0, 15, 10)),
        ("introDef",          TheoremProfile(1, 0, 0, 15, 10), TheoremProfile(2, 0, 0, 20, 15)),
        ("typeChange",        TheoremProfile(2, 0, 0, 20, 15), TheoremProfile(2, 1, 0, 25, 18)),
        ("perspectiveShift",  TheoremProfile(2, 1, 0, 25, 18), TheoremProfile(2, 1, 1, 30, 22)),
    ]

    start = path[0][1]
    end = path[-1][2]
    direct_cost = leap_cost(start, end)

    print(f"\n  Start: ({start.defs_introduced},{start.type_changes},{start.perspective_shifts})")
    print(f"  End:   ({end.defs_introduced},{end.type_changes},{end.perspective_shifts})")
    print(f"  Direct leap cost: {direct_cost}")
    print(f"  Path length: {len(path)} leaps")
    print(f"\n  Path:")
    for i, (kind, src, tgt) in enumerate(path):
        cost = leap_cost(src, tgt)
        print(f"    Leap {i+1}: {kind:<20} cost={cost}  "
              f"({src.defs_introduced},{src.type_changes},{src.perspective_shifts}) → "
              f"({tgt.defs_introduced},{tgt.type_changes},{tgt.perspective_shifts})")

    print(f"\n  ✓ leap_cost(start, end) = {direct_cost} ≤ path_length = {len(path)}")
    assert direct_cost <= len(path)


# ── Demo 5: Novelty Spectrum ────────────────────────────────────────

def demo_spectrum():
    print("\n" + "=" * 60)
    print("DEMO 5: Novelty Spectrum of a Corpus")
    print("=" * 60)

    corpus = [
        TheoremProfile(0, 0, 0, 10, 5),
        TheoremProfile(1, 0, 0, 20, 15),
        TheoremProfile(0, 1, 0, 15, 10),
        TheoremProfile(1, 1, 0, 25, 20),
    ]

    # Sample a grid of targets and compute depth gaps
    max_coord = 6
    gap_histogram = {}
    for d, t, p in itertools.product(range(max_coord + 1), repeat=3):
        target = TheoremProfile(d, t, p, 0, 0)
        gap = depth_gap(corpus, target)
        gap_histogram[gap] = gap_histogram.get(gap, 0) + 1

    print(f"\n  Corpus size: {len(corpus)}")
    print(f"  Grid: [0..{max_coord}]³ = {(max_coord + 1)**3} profiles")
    print(f"\n  {'DepthGap':>10} {'Count':>8} {'Fraction':>10}  Bar")
    print("  " + "-" * 50)
    total = sum(gap_histogram.values())
    for gap in sorted(gap_histogram.keys()):
        count = gap_histogram[gap]
        frac = count / total
        bar = "█" * int(frac * 40)
        print(f"  {gap:>10} {count:>8} {frac:>10.1%}  {bar}")


if __name__ == "__main__":
    demo_core()
    demo_separation()
    demo_monotonicity()
    demo_typed_leaps()
    demo_spectrum()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Depth Gap Framework: Visualizations

Creates publication-quality figures illustrating the depth gap theory.
"""

import itertools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap


class TheoremProfile:
    def __init__(self, d, t, p, ps=0, cs=0):
        self.defs_introduced = d
        self.type_changes = t
        self.perspective_shifts = p
        self.proof_size = ps
        self.compression_score = cs


def leap_cost(a, b):
    return (abs(a.defs_introduced - b.defs_introduced) +
            abs(a.type_changes - b.type_changes) +
            abs(a.perspective_shifts - b.perspective_shifts))


def depth_gap(corpus, target):
    return min(leap_cost(s, target) for s in corpus)


# ── Figure 1: Depth Gap Heatmap (2D slice) ──────────────────────────

def fig_heatmap():
    corpus = [
        TheoremProfile(0, 0, 0),
        TheoremProfile(3, 0, 0),
        TheoremProfile(0, 3, 0),
        TheoremProfile(2, 2, 0),
    ]

    N = 12
    gaps = np.zeros((N, N))
    for i in range(N):
        for j in range(N):
            target = TheoremProfile(i, j, 0)
            gaps[j, i] = depth_gap(corpus, target)

    fig, ax = plt.subplots(figsize=(8, 7))
    cmap = LinearSegmentedColormap.from_list('novelty',
        ['#2ecc71', '#f1c40f', '#e74c3c', '#8e44ad'], N=20)
    im = ax.imshow(gaps, origin='lower', cmap=cmap, interpolation='nearest',
                   extent=[-0.5, N-0.5, -0.5, N-0.5])
    cbar = plt.colorbar(im, ax=ax, label='Depth Gap (Conceptual Distance)')

    # Mark corpus points
    for s in corpus:
        ax.plot(s.defs_introduced, s.type_changes, 'w*', markersize=15,
                markeredgecolor='black', markeredgewidth=1.5)

    # Draw threshold contour
    ax.contour(np.arange(N), np.arange(N), gaps, levels=[3],
               colors='white', linewidths=2, linestyles='--')

    ax.set_xlabel('Definitions Introduced', fontsize=13)
    ax.set_ylabel('Type Changes', fontsize=13)
    ax.set_title('Novelty Landscape: Depth Gap from Known Corpus\n'
                 '(★ = corpus elements, dashed = derivative threshold τ=3)',
                 fontsize=13)
    plt.tight_layout()
    plt.savefig('fig_depth_gap_heatmap.png', dpi=150)
    plt.close()
    print("  Saved fig_depth_gap_heatmap.png")


# ── Figure 2: Separation Theorem ────────────────────────────────────

def fig_separation():
    corpus = [TheoremProfile(0, 0, 0)]

    taus = list(range(15))
    targets = [
        ("Close (1,0,0)", TheoremProfile(1, 0, 0)),
        ("Medium (3,2,0)", TheoremProfile(3, 2, 0)),
        ("Far (5,4,3)", TheoremProfile(5, 4, 3)),
    ]

    fig, ax = plt.subplots(figsize=(9, 5))
    colors = ['#2ecc71', '#3498db', '#e74c3c']

    for (label, target), color in zip(targets, colors):
        gap = depth_gap(corpus, target)
        deriv = [1 if any(leap_cost(s, target) <= tau for s in corpus) else 0
                 for tau in taus]
        ax.step(taus, deriv, where='mid', linewidth=2.5, color=color, label=f'{label} (gap={gap})')
        ax.axvline(x=gap, color=color, linestyle=':', alpha=0.5)

    ax.fill_between(taus, 0, 1, alpha=0.08, color='gray')
    ax.set_xlabel('Threshold τ', fontsize=13)
    ax.set_ylabel('Derivative? (1=Yes, 0=No)', fontsize=13)
    ax.set_title('Separation Theorem: Sharp Phase Transition at Depth Gap',
                 fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(-0.1, 1.2)
    ax.set_yticks([0, 1])
    ax.set_yticklabels(['Novel', 'Derivative'])
    plt.tight_layout()
    plt.savefig('fig_separation.png', dpi=150)
    plt.close()
    print("  Saved fig_separation.png")


# ── Figure 3: Monotonicity Under Corpus Growth ──────────────────────

def fig_monotonicity():
    target = TheoremProfile(6, 5, 4)
    additions = [
        TheoremProfile(0, 0, 0),
        TheoremProfile(2, 1, 0),
        TheoremProfile(3, 2, 1),
        TheoremProfile(4, 3, 2),
        TheoremProfile(5, 4, 3),
        TheoremProfile(6, 5, 4),
    ]

    corpus = []
    gaps = []
    for a in additions:
        corpus.append(a)
        gaps.append(depth_gap(corpus, target))

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(range(1, len(gaps)+1), gaps, 'o-', color='#2c3e50', markersize=10,
            linewidth=2.5, markerfacecolor='#e74c3c', markeredgecolor='#2c3e50')

    for i, (g, a) in enumerate(zip(gaps, additions)):
        ax.annotate(f'({a.defs_introduced},{a.type_changes},{a.perspective_shifts})',
                    (i+1, g), textcoords="offset points", xytext=(10, 5),
                    fontsize=9, color='#7f8c8d')

    ax.set_xlabel('Corpus Size |K|', fontsize=13)
    ax.set_ylabel('Depth Gap', fontsize=13)
    ax.set_title('Monotonicity: Depth Gap Decreases as Corpus Grows\n'
                 f'Target: ({target.defs_introduced},{target.type_changes},{target.perspective_shifts})',
                 fontsize=13)
    ax.set_xticks(range(1, len(gaps)+1))
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('fig_monotonicity.png', dpi=150)
    plt.close()
    print("  Saved fig_monotonicity.png")


# ── Figure 4: Novelty Spectrum Distribution ─────────────────────────

def fig_spectrum():
    corpus = [
        TheoremProfile(0, 0, 0),
        TheoremProfile(2, 0, 0),
        TheoremProfile(0, 2, 0),
        TheoremProfile(1, 1, 1),
    ]

    max_coord = 8
    all_gaps = []
    for d, t, p in itertools.product(range(max_coord + 1), repeat=3):
        target = TheoremProfile(d, t, p)
        all_gaps.append(depth_gap(corpus, target))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Histogram
    max_gap = max(all_gaps)
    bins = np.arange(-0.5, max_gap + 1.5)
    ax1.hist(all_gaps, bins=bins, color='#3498db', edgecolor='#2c3e50',
             alpha=0.8, rwidth=0.85)
    ax1.axvline(x=3, color='#e74c3c', linestyle='--', linewidth=2,
                label='τ=3 threshold')
    ax1.set_xlabel('Depth Gap', fontsize=13)
    ax1.set_ylabel('Count', fontsize=13)
    ax1.set_title('Novelty Spectrum: Distribution of Depth Gaps', fontsize=13)
    ax1.legend(fontsize=11)

    # Cumulative
    sorted_gaps = np.sort(all_gaps)
    cdf = np.arange(1, len(sorted_gaps) + 1) / len(sorted_gaps)
    ax2.step(sorted_gaps, cdf, where='post', color='#2c3e50', linewidth=2.5)
    ax2.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)
    ax2.axvline(x=3, color='#e74c3c', linestyle='--', linewidth=2,
                label='τ=3 threshold')

    # Shade derivative region
    ax2.fill_between([0, 3], 0, 1, alpha=0.1, color='#2ecc71')
    ax2.fill_between([3, max_gap], 0, 1, alpha=0.1, color='#e74c3c')
    ax2.text(1.5, 0.85, 'Derivative\nRegion', ha='center', fontsize=11,
             color='#27ae60')
    ax2.text(max_gap * 0.6, 0.85, 'Novel\nRegion', ha='center', fontsize=11,
             color='#c0392b')

    ax2.set_xlabel('Depth Gap', fontsize=13)
    ax2.set_ylabel('Cumulative Fraction', fontsize=13)
    ax2.set_title('Cumulative Distribution of Novelty', fontsize=13)
    ax2.legend(fontsize=11)

    plt.tight_layout()
    plt.savefig('fig_spectrum.png', dpi=150)
    plt.close()
    print("  Saved fig_spectrum.png")


if __name__ == "__main__":
    print("Generating visualizations...")
    fig_heatmap()
    fig_separation()
    fig_monotonicity()
    fig_spectrum()
    print("All visualizations generated!")
