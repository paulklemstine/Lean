#!/usr/bin/env python3
"""Visualization: Proof space entropy profiles for different graph types."""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict

def make_digraph(n, edges):
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
    return n, adj

def ball_sizes(n, adj, v, max_k):
    sizes = []
    current = {v}
    for k in range(max_k + 1):
        sizes.append(len(current))
        exp = set()
        for u in current:
            exp |= adj[u]
        current = current | exp
    return sizes

def entropy_profile(sizes):
    profile = []
    for k in range(len(sizes) - 1):
        if sizes[k] > 0:
            profile.append(np.log(sizes[k+1] / sizes[k]))
        else:
            profile.append(0.0)
    return profile

def main():
    max_k = 12
    rng = np.random.default_rng(42)

    # Graph 1: Path (slow linear growth)
    n1 = 50
    edges1 = [(i, i+1) for i in range(n1-1)]
    _, adj1 = make_digraph(n1, edges1)

    # Graph 2: Binary tree (exponential then saturation)
    n2 = 63
    edges2 = []
    for i in range(31):
        if 2*i+1 < n2: edges2.append((i, 2*i+1))
        if 2*i+2 < n2: edges2.append((i, 2*i+2))
    _, adj2 = make_digraph(n2, edges2)

    # Graph 3: Random expander (fast saturation)
    n3 = 80
    edges3 = []
    for v in range(n3):
        for w in rng.choice(n3, size=5, replace=False):
            if w != v: edges3.append((v, int(w)))
    _, adj3 = make_digraph(n3, edges3)

    s1 = ball_sizes(n1, adj1, 0, max_k)
    s2 = ball_sizes(n2, adj2, 0, max_k)
    s3 = ball_sizes(n3, adj3, 0, max_k)

    e1 = entropy_profile(s1)
    e2 = entropy_profile(s2)
    e3 = entropy_profile(s3)

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))

    ks = list(range(max_k + 1))
    ax1.plot(ks, s1, 'o-', label=f'Path (n={n1})', linewidth=2)
    ax1.plot(ks, s2, 's-', label=f'Binary tree (n={n2})', linewidth=2)
    ax1.plot(ks, s3, '^-', label=f'Random expander (n={n3})', linewidth=2)
    ax1.set_xlabel('Steps k', fontsize=12)
    ax1.set_ylabel('Ball size', fontsize=12)
    ax1.set_title('Ball Growth Profiles', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    ks2 = list(range(max_k))
    ax2.bar(np.array(ks2) - 0.25, e1, width=0.25, label='Path', alpha=0.8)
    ax2.bar(np.array(ks2), e2, width=0.25, label='Binary tree', alpha=0.8)
    ax2.bar(np.array(ks2) + 0.25, e3, width=0.25, label='Random expander', alpha=0.8)
    ax2.set_xlabel('Step k', fontsize=12)
    ax2.set_ylabel('Entropy H(k) = log(b_{k+1}/b_k)', fontsize=12)
    ax2.set_title('Proof Space Entropy Profiles', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3, axis='y')

    for i, (e, label) in enumerate([(e1, 'Path'), (e2, 'Tree'), (e3, 'Expander')]):
        total = sum(e)
        ax2.annotate(f'Total H = {total:.2f}', xy=(max_k - 2, max(e) * (0.9 - i*0.15)),
                     fontsize=10, color=f'C{i}')

    plt.tight_layout()
    plt.savefig('entropy_profiles.png', dpi=150, bbox_inches='tight')
    print("Saved entropy_profiles.png")

if __name__ == '__main__':
    main()
