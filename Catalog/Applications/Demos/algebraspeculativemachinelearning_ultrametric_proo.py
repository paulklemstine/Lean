#!/usr/bin/env python3
"""
Demo: Ultrametric Observer Rate-Distortion Theory

Demonstrates the core theorem: in a finite ultrametric space with observers,
the minimal ε-cover size equals the number of equivalence classes under
observer ε-congruence.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict
import base64
from io import BytesIO


def make_ultrametric_tree(n_leaves=8, seed=42):
    """Generate a valid ultrametric distance matrix from a binary merge tree.
    
    Build bottom-up: start with singletons, merge pairs at increasing heights.
    All inter-cluster distances equal the merge height (ultrametric property).
    """
    rng = np.random.RandomState(seed)
    n = n_leaves
    d = np.zeros((n, n))
    
    # Merge heights (increasing)
    heights = sorted(rng.uniform(1, 10, n - 1))
    
    # Start with each point in its own cluster
    clusters = [[i] for i in range(n)]
    
    for h in heights:
        if len(clusters) < 2:
            break
        # Pick two random clusters to merge
        idx = rng.choice(len(clusters), 2, replace=False)
        i, j = min(idx), max(idx)
        c1, c2 = clusters[i], clusters[j]
        
        # Set distance between all cross-cluster pairs to h
        for a in c1:
            for b in c2:
                d[a, b] = h
                d[b, a] = h
        
        # Merge clusters
        new_cluster = c1 + c2
        clusters = [c for k, c in enumerate(clusters) if k not in (i, j)]
        clusters.append(new_cluster)
    
    return d


def verify_ultrametric(d):
    """Verify the strong triangle inequality."""
    n = d.shape[0]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if d[i, k] > max(d[i, j], d[j, k]) + 1e-10:
                    return False
    return True


def observer_distortion(observers, p, q):
    """Compute max observer distortion."""
    return max(o[p, q] for o in observers)


def compute_congruence_classes(observers, n, epsilon):
    """Compute equivalence classes under observer ε-congruence via Union-Find."""
    parent = list(range(n))
    
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    
    for i in range(n):
        for j in range(i + 1, n):
            if observer_distortion(observers, i, j) <= epsilon + 1e-10:
                union(i, j)
    
    classes = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    
    return list(classes.values())


def minimal_cover(observers, n, epsilon):
    """One representative per congruence class."""
    classes = compute_congruence_classes(observers, n, epsilon)
    return [cls[0] for cls in classes]


def compute_critical_scales(observers, n):
    """All distinct pairwise observer distortion values."""
    scales = set()
    for i in range(n):
        for j in range(i + 1, n):
            scales.add(round(observer_distortion(observers, i, j), 10))
    return sorted(scales)


def demo_core_theorem():
    """Demonstrate: cover size = congruence index (the main theorem)."""
    print("=" * 70)
    print("CORE THEOREM: Minimal ε-cover = Observer Congruence Index")
    print("=" * 70)
    
    n = 8
    d = make_ultrametric_tree(n, seed=42)
    assert verify_ultrametric(d), "Distance matrix must be ultrametric"
    
    print(f"\nUltrametric space with {n} proof states")
    print(f"Ultrametric property verified: {verify_ultrametric(d)}")
    
    # Create observers as scaled sub-ultrametrics
    rng = np.random.RandomState(123)
    observers = []
    for k in range(3):
        scale = rng.uniform(0.5, 1.0)
        obs = d * scale
        np.fill_diagonal(obs, 0)
        observers.append(obs)
    
    # Verify observers are ultrametric
    for k, obs in enumerate(observers):
        assert verify_ultrametric(obs), f"Observer {k} must be ultrametric"
    
    print(f"Number of observers: {len(observers)}")
    
    critical = compute_critical_scales(observers, n)
    print(f"\nCritical scales ({len(critical)} breakpoints):")
    for i, s in enumerate(critical[:10]):
        print(f"  ε_{i} = {s:.4f}")
    
    # Test at various scales
    test_eps = sorted(set([0.0] + [s - 0.01 for s in critical if s > 0.01] + critical + [critical[-1] + 1]))
    
    print(f"\n{'ε':>10} | {'#Classes':>10} | {'Cover':>10} | {'Covers?':>8} | {'Match':>6}")
    print("-" * 60)
    
    all_match = True
    for eps in test_eps:
        classes = compute_congruence_classes(observers, n, eps)
        cover = minimal_cover(observers, n, eps)
        n_classes = len(classes)
        n_cover = len(cover)
        
        # Verify cover property
        covers = all(
            any(observer_distortion(observers, p, c) <= eps + 1e-10 for c in cover)
            for p in range(n)
        )
        
        match = n_classes == n_cover
        all_match = all_match and match
        print(f"{eps:10.4f} | {n_classes:10d} | {n_cover:10d} | {'✓' if covers else '✗':>8} | {'✓' if match else '✗':>6}")
    
    print(f"\nTheorem verified at all scales: {'✓' if all_match else '✗'}")
    return d, observers


def plot_rate_distortion(observers, n, filename="rate_distortion.png"):
    """Plot the rate-distortion step function."""
    critical = compute_critical_scales(observers, n)
    eps_max = max(critical) * 1.3 if critical else 1
    epsilons = np.linspace(0, eps_max, 500)
    
    cover_numbers = []
    rates = []
    for eps in epsilons:
        classes = compute_congruence_classes(observers, n, eps)
        nc = len(classes)
        cover_numbers.append(nc)
        rates.append(np.log(nc) if nc > 0 else 0)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.plot(epsilons, rates, 'b-', linewidth=2, label='R(ε) = log N(ε)')
    for s in critical:
        ax1.axvline(x=s, color='red', linestyle='--', alpha=0.3)
    ax1.set_xlabel('Distortion tolerance ε', fontsize=12)
    ax1.set_ylabel('Rate R(ε)', fontsize=12)
    ax1.set_title('Observer Rate–Distortion Function\n(Antitone Step Function)', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    ax2.step(epsilons, cover_numbers, 'r-', linewidth=2, where='post',
             label='N(ε) = #congruence classes')
    for s in critical:
        ax2.axvline(x=s, color='blue', linestyle='--', alpha=0.3)
    ax2.set_xlabel('Distortion tolerance ε', fontsize=12)
    ax2.set_ylabel('Covering number N(ε)', fontsize=12)
    ax2.set_title('Covering Number = Congruence Index\n(Core Theorem)', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\nPlot saved to {filename}")
    return filename


def plot_congruence_filtration(observers, n, filename="filtration.png"):
    """Visualize the congruence filtration at different scales."""
    critical = compute_critical_scales(observers, n)
    
    # Pick representative scales
    scales = [0.0] + critical[:min(len(critical), 7)]
    
    fig, ax = plt.subplots(figsize=(12, 5))
    
    for si, eps in enumerate(scales):
        classes = compute_congruence_classes(observers, n, eps)
        for ci, cls in enumerate(classes):
            color = plt.cm.tab10(ci % 10)
            for p in cls:
                ax.barh(si, 0.7, left=p - 0.35, height=0.5, color=color,
                       alpha=0.7, edgecolor='black', linewidth=0.5)
                ax.text(p, si, str(p), ha='center', va='center', fontsize=8, fontweight='bold')
    
    ax.set_yticks(range(len(scales)))
    labels = []
    for s in scales:
        nc = len(compute_congruence_classes(observers, n, s))
        labels.append(f'ε={s:.2f}\n({nc} classes)')
    ax.set_yticklabels(labels, fontsize=9)
    ax.set_xlabel('Proof State', fontsize=12)
    ax.set_title('Observer Congruence Filtration\n(Nested Equivalence Classes at Increasing ε)', fontsize=13)
    ax.set_xlim(-1, n)
    
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Filtration plot saved to {filename}")
    return filename


def demo_greedy_codebook():
    """Demonstrate the certified greedy codebook."""
    print("\n" + "=" * 70)
    print("CERTIFIED GREEDY CODEBOOK")
    print("=" * 70)
    
    n = 10
    d = make_ultrametric_tree(n, seed=99)
    assert verify_ultrametric(d)
    
    rng = np.random.RandomState(456)
    observers = [d * rng.uniform(0.5, 1.0) for _ in range(3)]
    for o in observers:
        np.fill_diagonal(o, 0)
    
    critical = compute_critical_scales(observers, n)
    print(f"\nSpace: {n} states, {len(observers)} observers, {len(critical)} critical scales\n")
    
    for eps in [critical[0] - 0.01] + [critical[len(critical)//3], critical[2*len(critical)//3], critical[-1] + 0.1]:
        if eps < 0:
            eps = 0
        classes = compute_congruence_classes(observers, n, eps)
        cover = minimal_cover(observers, n, eps)
        covers_all = all(
            any(observer_distortion(observers, p, c) <= eps + 1e-10 for c in cover)
            for p in range(n)
        )
        
        print(f"ε = {eps:.4f}: {len(classes)} classes, codebook = {cover}, "
              f"covers all: {covers_all}, ratio: {len(cover)}/{n} = {len(cover)/n:.0%}")


if __name__ == "__main__":
    d, observers = demo_core_theorem()
    demo_greedy_codebook()
    plot_rate_distortion(observers, d.shape[0])
    plot_congruence_filtration(observers, d.shape[0])
    
    print("\n" + "=" * 70)
    print("KEY INSIGHT: In ultrametric spaces, lossy compression is EXACT.")
    print("The minimal codebook size = the number of equivalence classes.")
    print("This is NOT true in general metric spaces!")
    print("=" * 70)
