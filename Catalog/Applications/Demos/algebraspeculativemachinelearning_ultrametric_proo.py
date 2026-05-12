#!/usr/bin/env python3
"""
Ultrametric Proof Rate-Distortion Duality: Interactive Demonstrations

Demonstrates the theorems formalized in UltrametricProofRateDistortion.lean:
- Ultrametric ball dichotomy
- Spectral separation and code equality
- Rate-distortion curve computation
- Greedy observer basis selection
- Certified reconstruction
"""

import numpy as np
import itertools
import math


# ============================================================
# §1. Ultrametric Space Construction
# ============================================================

def make_tree_ultrametric(n: int) -> np.ndarray:
    """Construct an ultrametric distance matrix via single-linkage clustering.

    We build a random dendrogram (binary tree) and set d(i,j) = height of LCA.
    This always produces a valid ultrametric.
    """
    if n <= 1:
        return np.zeros((n, n))

    # Build a random dendrogram by iteratively merging clusters
    clusters = {i: [i] for i in range(n)}
    d = np.zeros((n, n))
    height = 1.0

    active = list(range(n))
    while len(active) > 1:
        np.random.shuffle(active)
        i, j = active[0], active[1]
        # Set distance between all pairs across these two clusters
        for a in clusters[i]:
            for b in clusters[j]:
                d[a, b] = height
                d[b, a] = height
        # Merge clusters
        clusters[i] = clusters[i] + clusters[j]
        del clusters[j]
        active.remove(j)
        height *= 2  # Exponentially increasing heights

    return d


def verify_ultrametric(d: np.ndarray) -> bool:
    """Verify the ultrametric (strong triangle) inequality."""
    n = d.shape[0]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if d[i, k] > max(d[i, j], d[j, k]) + 1e-10:
                    return False
    return True


# ============================================================
# §2. Ultrametric Ball Computation
# ============================================================

def compute_ball(d: np.ndarray, center: int, epsilon: float) -> set:
    """Compute the ε-ball around a center point."""
    n = d.shape[0]
    return {j for j in range(n) if d[center, j] <= epsilon + 1e-10}


def compute_partition(d: np.ndarray, epsilon: float) -> list:
    """Compute the canonical ε-ball partition."""
    n = d.shape[0]
    assigned = set()
    classes = []
    for i in range(n):
        if i not in assigned:
            ball = compute_ball(d, i, epsilon)
            classes.append(ball)
            assigned |= ball
    return classes


def verify_ball_dichotomy(d: np.ndarray, epsilon: float) -> bool:
    """Verify balls are equal or disjoint (Theorem 3.2)."""
    n = d.shape[0]
    for i in range(n):
        for j in range(i + 1, n):
            ball_i = compute_ball(d, i, epsilon)
            ball_j = compute_ball(d, j, epsilon)
            if ball_i & ball_j and ball_i != ball_j:
                return False
    return True


# ============================================================
# §3. Observer Families
# ============================================================

def make_lipschitz_observers(d: np.ndarray, epsilon: float) -> np.ndarray:
    """Create ε-Lipschitz observers that are also ε-separating.

    For each equivalence class, create an indicator observer that is 1 on
    the class and 0 elsewhere. This is both ε-Lipschitz and ε-separating.
    """
    partition = compute_partition(d, epsilon)
    n = d.shape[0]
    n_obs = len(partition)
    obs = np.zeros((n_obs, n))
    for idx, cls in enumerate(partition):
        for pt in cls:
            obs[idx, pt] = 1.0
    return obs


def compute_observer_code(obs: np.ndarray, x: int) -> tuple:
    """Compute the observer code of point x."""
    return tuple(obs[:, x])


def check_code_equality(obs: np.ndarray, x: int, y: int) -> bool:
    """Check if two points have the same observer code."""
    return np.allclose(obs[:, x], obs[:, y])


def compute_code_partition(obs: np.ndarray) -> list:
    """Partition points by observer code equality."""
    n = obs.shape[1]
    codes = {}
    for i in range(n):
        code = compute_observer_code(obs, i)
        if code not in codes:
            codes[code] = set()
        codes[code].add(i)
    return list(codes.values())


def verify_spectral_separation(d: np.ndarray, obs: np.ndarray, epsilon: float) -> dict:
    """Verify spectral separation at scale ε."""
    n = d.shape[0]
    coherent = True
    complete = True

    for i in range(n):
        for j in range(i + 1, n):
            close = d[i, j] <= epsilon + 1e-10
            same_code = check_code_equality(obs, i, j)
            if close and not same_code:
                coherent = False
            if same_code and not close:
                complete = False

    return {"coherent": coherent, "complete": complete,
            "spectrally_separating": coherent and complete}


# ============================================================
# §4. Rate-Distortion Computation
# ============================================================

def covering_number(d: np.ndarray, epsilon: float) -> int:
    """N(ε): number of distinct ε-balls."""
    return len(compute_partition(d, epsilon))


def rate_distortion_curve(d: np.ndarray) -> list:
    """Compute R(ε) = log₂(N(ε)) at all critical scales."""
    n = d.shape[0]
    all_dists = sorted(set(d[i, j] for i in range(n) for j in range(i + 1, n)))
    eps_values = [0] + [x - 0.01 for x in all_dists] + all_dists + [max(all_dists) * 1.5]
    eps_values = sorted(set(max(0, e) for e in eps_values))

    results = []
    for eps in eps_values:
        n_eps = covering_number(d, eps)
        rate = math.log2(n_eps) if n_eps > 0 else 0
        results.append((eps, rate, n_eps))
    return results


# ============================================================
# §5. Greedy Observer Basis Selection
# ============================================================

def greedy_observer_basis(d: np.ndarray, obs: np.ndarray, epsilon: float) -> list:
    """Select minimum observer basis greedily."""
    n = d.shape[0]
    n_obs = obs.shape[0]

    unseparated = set()
    for i in range(n):
        for j in range(i + 1, n):
            if d[i, j] > epsilon + 1e-10:
                unseparated.add((i, j))

    basis = []
    available = set(range(n_obs))

    while unseparated and available:
        best_obs = -1
        best_separated = set()

        for o in available:
            separated = {(i, j) for (i, j) in unseparated
                        if abs(obs[o, i] - obs[o, j]) > 1e-10}
            if len(separated) > len(best_separated):
                best_obs = o
                best_separated = separated

        if not best_separated:
            break

        basis.append(best_obs)
        available.discard(best_obs)
        unseparated -= best_separated

    return basis


def verify_basis(d: np.ndarray, obs: np.ndarray, epsilon: float, basis: list) -> bool:
    """Verify a basis separates all pairs at distance > ε."""
    n = d.shape[0]
    for i in range(n):
        for j in range(i + 1, n):
            if d[i, j] > epsilon + 1e-10:
                if not any(abs(obs[o, i] - obs[o, j]) > 1e-10 for o in basis):
                    return False
    return True


# ============================================================
# §6. Demonstrations
# ============================================================

def demo_ball_dichotomy():
    """Demonstrate the ultrametric ball dichotomy theorem."""
    print("=" * 60)
    print("DEMO 1: Ultrametric Ball Dichotomy")
    print("=" * 60)
    print()

    n = 8
    d = make_tree_ultrametric(n)
    print(f"Distance matrix ({n} points, dendrogram-based):")
    print(np.round(d, 1))
    print()

    is_ultra = verify_ultrametric(d)
    print(f"Ultrametric property verified: {is_ultra}")

    all_dists = sorted(set(d[i, j] for i in range(n) for j in range(i + 1, n)))
    print(f"Distinct distances: {[round(x, 1) for x in all_dists]}")
    print()

    for eps in all_dists:
        partition = compute_partition(d, eps)
        dichotomy_ok = verify_ball_dichotomy(d, eps)
        print(f"  ε = {eps:6.1f}: {len(partition)} classes, "
              f"dichotomy: {'✓' if dichotomy_ok else '✗'}")
        for cls in partition:
            print(f"    {sorted(cls)}")
    print()


def demo_spectral_separation():
    """Demonstrate spectral separation (Theorem A)."""
    print("=" * 60)
    print("DEMO 2: Spectral Separation (Theorem A)")
    print("=" * 60)
    print()

    n = 8
    d = make_tree_ultrametric(n)
    print(f"Ultrametric verified: {verify_ultrametric(d)}")

    all_dists = sorted(set(d[i, j] for i in range(n) for j in range(i + 1, n)))

    for eps in all_dists:
        obs = make_lipschitz_observers(d, eps)
        ball_partition = compute_partition(d, eps)
        code_partition = compute_code_partition(obs)
        sep = verify_spectral_separation(d, obs, eps)

        partitions_match = (
            sorted([sorted(c) for c in ball_partition]) ==
            sorted([sorted(c) for c in code_partition])
        )

        print(f"\n  ε = {eps:.1f}:")
        print(f"    Ball partition:  {[sorted(c) for c in ball_partition]}")
        print(f"    Code partition:  {[sorted(c) for c in code_partition]}")
        print(f"    Partitions match: {'✓' if partitions_match else '✗'}")
        print(f"    Spectral sep:    {'✓' if sep['spectrally_separating'] else '✗'}")
    print()


def demo_rate_distortion():
    """Demonstrate the rate-distortion curve (Theorem C)."""
    print("=" * 60)
    print("DEMO 3: Rate-Distortion Curve")
    print("=" * 60)
    print()

    n = 16
    d = make_tree_ultrametric(n)
    print(f"Ultrametric verified: {verify_ultrametric(d)}")
    print()

    curve = rate_distortion_curve(d)
    print(f"  {'ε':>8s} | {'N(ε)':>6s} | {'R(ε)=log₂N':>12s}")
    print(f"  {'-' * 8} | {'-' * 6} | {'-' * 12}")
    prev_n = None
    for eps, rate, n_eps in curve:
        if n_eps != prev_n:
            print(f"  {eps:8.2f} | {n_eps:6d} | {rate:12.3f}")
            prev_n = n_eps

    print()
    print("The rate-distortion curve is a step function with jumps")
    print("at each distinct distance level — a uniquely ultrametric phenomenon.")
    print()


def demo_greedy_basis():
    """Demonstrate greedy observer basis selection (Theorem D)."""
    print("=" * 60)
    print("DEMO 4: Greedy Observer Basis Selection")
    print("=" * 60)
    print()

    n = 10
    d = make_tree_ultrametric(n)
    print(f"Ultrametric verified: {verify_ultrametric(d)}")

    all_dists = sorted(set(d[i, j] for i in range(n) for j in range(i + 1, n)))

    for eps in all_dists[:3]:
        obs = make_lipschitz_observers(d, eps)
        basis = greedy_observer_basis(d, obs, eps)
        is_valid = verify_basis(d, obs, eps, basis)
        n_classes = covering_number(d, eps)

        print(f"\n  ε = {eps:.1f}:")
        print(f"    Covering number N(ε) = {n_classes}")
        print(f"    Greedy basis size: {len(basis)}")
        print(f"    Certified: {'✓' if is_valid else '✗'}")
    print()


def demo_certified_reconstruction():
    """Demonstrate certified reconstruction with distortion bound."""
    print("=" * 60)
    print("DEMO 5: Certified Reconstruction")
    print("=" * 60)
    print()

    n = 8
    d = make_tree_ultrametric(n)
    all_dists = sorted(set(d[i, j] for i in range(n) for j in range(i + 1, n)))
    eps = all_dists[len(all_dists) // 2] if all_dists else 1.0

    obs = make_lipschitz_observers(d, eps)
    print(f"ε = {eps:.1f}, ultrametric verified: {verify_ultrametric(d)}")
    print()

    codes = {}
    for i in range(n):
        code = compute_observer_code(obs, i)
        if code not in codes:
            codes[code] = []
        codes[code].append(i)

    print("Decoder classes (same-code groups):")
    all_ok = True
    for idx, (_, members) in enumerate(codes.items()):
        max_dist = 0
        for a, b in itertools.combinations(members, 2):
            max_dist = max(max_dist, d[a, b])
        ok = max_dist <= eps + 1e-10
        all_ok = all_ok and ok
        print(f"  Class {idx}: points {members}, max dist = {max_dist:.1f} ≤ ε = {eps:.1f}: {'✓' if ok else '✗'}")

    print(f"\nAll classes certified: {'✓' if all_ok else '✗'}")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    demo_ball_dichotomy()
    demo_spectral_separation()
    demo_rate_distortion()
    demo_greedy_basis()
    demo_certified_reconstruction()
    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    article = read_file('/workspace/request-project/ARTICLE.md')
    research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
    future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
    lean_proofs = read_file('/workspace/request-project/Speculative/AutoResearch/Bridges/UltrametricProofRateDistortion.lean')
    demo_code = read_file('/workspace/request-project/demo.py')
    algorithms_code = read_file('/workspace/request-project/algorithms.py')

    # Load visualization data
    viz_data = json.loads(read_file('/workspace/request-project/viz_data.json'))

    package = {
        "title": "Ultrametric Proof Rate-Distortion Duality via Observer Semimodules",
        "domain": "Non-Archimedean Information Theory / Bridges",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Ultrametric Rate-Distortion Demonstrations",
                "code": demo_code
            }
        ],
        "algorithms": [
            {
                "name": "Ultrametric Ball Partition",
                "pseudocode": "Input: Distance matrix d, scale ε\nOutput: Partition of points into ε-balls\n\nassigned ← ∅\npartition ← []\nfor each point i not in assigned:\n    ball ← {j | d(i,j) ≤ ε}\n    partition.append(ball)\n    assigned ← assigned ∪ ball\nreturn partition",
                "code": algorithms_code
            },
            {
                "name": "Greedy Observer Basis Selection",
                "pseudocode": "Input: Distance d, observers obs, scale ε\nOutput: Certified basis B\n\nunseparated ← {(x,y) | d(x,y) > ε}\nB ← ∅\nwhile unseparated ≠ ∅:\n    o* ← argmax_o |{(x,y) ∈ unseparated | obs(o,x) ≠ obs(o,y)}|\n    B ← B ∪ {o*}\n    unseparated ← unseparated \\ {(x,y) | obs(o*,x) ≠ obs(o*,y)}\nreturn B",
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {
                "name": "Rate-Distortion Curve",
                "data": viz_data['rate_distortion']
            },
            {
                "name": "Ultrametric Ball Partitions",
                "data": viz_data['ball_partition']
            },
            {
                "name": "Covering Number Hierarchy",
                "data": viz_data['covering_hierarchy']
            }
        ],
        "lean_proofs": lean_proofs
    }

    with open('/workspace/request-project/PACKAGE.json', 'w') as f:
        json.dump(package, f, ensure_ascii=False)

    print(f"PACKAGE.json generated ({os.path.getsize('/workspace/request-project/PACKAGE.json')} bytes)")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate visualizations for the ultrametric rate-distortion package."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import math
import json


def make_tree_ultrametric(n, seed=42):
    np.random.seed(seed)
    if n <= 1:
        return np.zeros((n, n))
    clusters = {i: [i] for i in range(n)}
    d = np.zeros((n, n))
    height = 1.0
    active = list(range(n))
    while len(active) > 1:
        np.random.shuffle(active)
        i, j = active[0], active[1]
        for a in clusters[i]:
            for b in clusters[j]:
                d[a, b] = height
                d[b, a] = height
        clusters[i] = clusters[i] + clusters[j]
        del clusters[j]
        active.remove(j)
        height *= 2
    return d


def compute_partition(d, epsilon):
    n = d.shape[0]
    assigned = set()
    classes = []
    for i in range(n):
        if i not in assigned:
            ball = {j for j in range(n) if d[i, j] <= epsilon + 1e-10}
            classes.append(ball)
            assigned |= ball
    return classes


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def make_rate_distortion_plot():
    """Generate rate-distortion curve plot."""
    n = 16
    d = make_tree_ultrametric(n)
    all_dists = sorted(set(d[i, j] for i in range(n) for j in range(i + 1, n)))

    epsilons = []
    rates = []
    for eps in [0] + all_dists + [max(all_dists) * 1.5]:
        n_eps = len(compute_partition(d, eps))
        epsilons.append(eps)
        rates.append(math.log2(n_eps) if n_eps > 0 else 0)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.step(epsilons, rates, where='post', linewidth=2, color='#2196F3')
    ax.fill_between(epsilons, rates, step='post', alpha=0.15, color='#2196F3')
    ax.set_xlabel('Distortion ε', fontsize=13)
    ax.set_ylabel('Rate R(ε) = log₂ N(ε)', fontsize=13)
    ax.set_title('Ultrametric Rate–Distortion Curve', fontsize=15, fontweight='bold')
    ax.set_xscale('log')
    ax.grid(True, alpha=0.3)

    for eps, rate in zip(epsilons, rates):
        if eps > 0:
            ax.plot(eps, rate, 'o', color='#E91E63', markersize=6, zorder=5)

    ax.annotate('Step-function behavior:\nuniquely ultrametric',
                xy=(epsilons[3], rates[3]),
                xytext=(epsilons[5], rates[1] + 0.5),
                fontsize=10, color='#333',
                arrowprops=dict(arrowstyle='->', color='#666'))

    return fig_to_base64(fig)


def make_ball_partition_plot():
    """Generate ball partition visualization."""
    n = 8
    d = make_tree_ultrametric(n, seed=42)
    all_dists = sorted(set(d[i, j] for i in range(n) for j in range(i + 1, n)))

    fig, axes = plt.subplots(2, 3, figsize=(14, 8))
    fig.suptitle('Ultrametric Ball Partitions at Increasing Scales',
                 fontsize=15, fontweight='bold')

    colors = plt.cm.Set3(np.linspace(0, 1, n))

    for idx, (ax, eps) in enumerate(zip(axes.flat, all_dists[:6])):
        partition = compute_partition(d, eps)
        n_classes = len(partition)

        # Draw points with class coloring
        angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
        xs = np.cos(angles)
        ys = np.sin(angles)

        class_colors = plt.cm.Set2(np.linspace(0, 1, max(n_classes, 1)))

        for cidx, cls in enumerate(partition):
            for pt in cls:
                ax.plot(xs[pt], ys[pt], 'o', color=class_colors[cidx],
                       markersize=15, zorder=5)
                ax.annotate(str(pt), (xs[pt], ys[pt]),
                           ha='center', va='center', fontsize=8, fontweight='bold')

            # Draw convex hull-like boundary
            if len(cls) > 1:
                pts = sorted(cls)
                cx = np.mean([xs[p] for p in pts])
                cy = np.mean([ys[p] for p in pts])
                radius = max(np.sqrt((xs[p] - cx)**2 + (ys[p] - cy)**2) for p in pts) + 0.15
                circle = plt.Circle((cx, cy), radius, fill=False,
                                   edgecolor=class_colors[cidx], linewidth=2,
                                   linestyle='--', alpha=0.7)
                ax.add_patch(circle)

        ax.set_xlim(-1.8, 1.8)
        ax.set_ylim(-1.8, 1.8)
        ax.set_aspect('equal')
        ax.set_title(f'ε = {eps:.0f}  ({n_classes} classes)', fontsize=11)
        ax.axis('off')

    plt.tight_layout()
    return fig_to_base64(fig)


def make_covering_hierarchy_plot():
    """Generate covering number hierarchy plot."""
    n = 32
    d = make_tree_ultrametric(n, seed=123)
    all_dists = sorted(set(d[i, j] for i in range(n) for j in range(i + 1, n)))

    epsilons = [0] + all_dists
    covering_nums = [len(compute_partition(d, eps)) for eps in epsilons]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: covering number vs epsilon
    ax1.step(epsilons, covering_nums, where='post', linewidth=2, color='#4CAF50')
    ax1.set_xlabel('Scale ε', fontsize=12)
    ax1.set_ylabel('Covering number N(ε)', fontsize=12)
    ax1.set_title('Covering Number Hierarchy', fontsize=14, fontweight='bold')
    ax1.set_xscale('log')
    ax1.grid(True, alpha=0.3)

    # Right: log-log plot showing power-law decay
    pos_eps = [e for e in epsilons if e > 0]
    pos_cov = [len(compute_partition(d, e)) for e in pos_eps]
    ax2.loglog(pos_eps, pos_cov, 'o-', linewidth=2, color='#FF5722', markersize=6)
    ax2.set_xlabel('Scale ε (log)', fontsize=12)
    ax2.set_ylabel('N(ε) (log)', fontsize=12)
    ax2.set_title('Log-Log: Covering Number Decay', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3, which='both')

    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating rate-distortion plot...")
    rd_plot = make_rate_distortion_plot()
    print(f"  Generated ({len(rd_plot)} chars)")

    print("Generating ball partition plot...")
    bp_plot = make_ball_partition_plot()
    print(f"  Generated ({len(bp_plot)} chars)")

    print("Generating covering hierarchy plot...")
    ch_plot = make_covering_hierarchy_plot()
    print(f"  Generated ({len(ch_plot)} chars)")

    # Save for PACKAGE.json
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump({
            'rate_distortion': rd_plot,
            'ball_partition': bp_plot,
            'covering_hierarchy': ch_plot,
        }, f)

    print("All visualizations generated and saved.")
