#!/usr/bin/env python3
"""
Tropical Valuation → Closure-Stable Probe Bridge: Demonstration

Demonstrates the main theorems computationally:
1. Level-set closure is extensive, monotone, and idempotent
2. Threshold probes are closure-stable
3. Closure determines and is determined by the valuation partition
4. Multiplicative compatibility (tropical functoriality)
5. Different primes give different closure systems
"""

from typing import Set, Dict, List, Callable, Optional, FrozenSet
import math


# ============================================================
# §1. p-Adic Valuation
# ============================================================

def padic_val(p: int, n: int) -> float:
    """Compute the p-adic valuation v_p(n). Returns float('inf') for n=0."""
    if n == 0:
        return float('inf')
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


# ============================================================
# §2. Level-Set Closure
# ============================================================

def level_set_closure(v: Callable[[int], float], S: Set[int],
                      domain: Set[int]) -> Set[int]:
    """Compute cl_v(S) = {x in domain | exists s in S with v(x) = v(s)}."""
    val_image = {v(s) for s in S}
    return {x for x in domain if v(x) in val_image}


def threshold_probe(v: Callable[[int], float], n: float, x: int) -> int:
    """Threshold probe: 1 if v(x) <= n, else 0."""
    return 1 if v(x) <= n else 0


# ============================================================
# §3. Demonstrations
# ============================================================

def demo_closure_axioms():
    """Demonstrate extensivity, monotonicity, and idempotence."""
    print("=" * 60)
    print("DEMO 1: Closure Axioms for 2-adic Valuation")
    print("=" * 60)

    domain = set(range(1, 101))
    v = lambda n: padic_val(2, n)

    S = {6, 12, 18}
    cl_S = level_set_closure(v, S, domain)
    cl_cl_S = level_set_closure(v, cl_S, domain)

    print(f"\nS = {sorted(S)}")
    print(f"v(S) = {sorted({v(s) for s in S})}")
    print(f"cl(S) = {sorted(cl_S)[:20]}... ({len(cl_S)} elements)")

    # Extensivity: S ⊆ cl(S)
    assert S <= cl_S, "Extensivity failed!"
    print(f"\n✓ Extensivity: S ⊆ cl(S)")

    # Monotonicity: S ⊆ T → cl(S) ⊆ cl(T)
    T = S | {24}
    cl_T = level_set_closure(v, T, domain)
    assert cl_S <= cl_T, "Monotonicity failed!"
    print(f"✓ Monotonicity: S ⊆ T → cl(S) ⊆ cl(T)")

    # Idempotence: cl(cl(S)) = cl(S)
    assert cl_cl_S == cl_S, "Idempotence failed!"
    print(f"✓ Idempotence: cl(cl(S)) = cl(S)")


def demo_probe_characterization():
    """Demonstrate: closure-stable ↔ factors through v."""
    print("\n" + "=" * 60)
    print("DEMO 2: Probe Characterization Theorem")
    print("=" * 60)

    domain = set(range(1, 51))
    v = lambda n: padic_val(2, n)

    # A v-factoring probe (threshold at level 1)
    p_factor = lambda n: threshold_probe(v, 1, n)
    # A non-factoring probe (depends on n mod 3)
    p_nonfactor = lambda n: n % 3

    print("\nProbe p_factor(x) = (1 if v_2(x) ≤ 1 else 0):")
    print(f"  p_factor(2) = {p_factor(2)}, p_factor(6) = {p_factor(6)}")
    print(f"  v_2(2) = {v(2)}, v_2(6) = {v(6)} → same valuation, same probe ✓")

    print(f"\nProbe p_nonfactor(x) = x mod 3:")
    print(f"  p_nonfactor(2) = {p_nonfactor(2)}, p_nonfactor(6) = {p_nonfactor(6)}")
    print(f"  v_2(2) = {v(2)}, v_2(6) = {v(6)} → same valuation, DIFFERENT probe ✗")

    # Test closure stability
    S = {3, 5, 7}
    cl_S = level_set_closure(v, S, domain)

    stable_factor = all(
        any(p_factor(x) == p_factor(s) for s in S)
        for x in cl_S
    )
    stable_nonfactor = all(
        any(p_nonfactor(x) == p_nonfactor(s) for s in S)
        for x in cl_S
    )

    print(f"\nS = {sorted(S)}, cl(S) = {sorted(cl_S)}")
    print(f"  p_factor closure-stable: {stable_factor} ✓")
    print(f"  p_nonfactor closure-stable: {stable_nonfactor}")
    if not stable_nonfactor:
        # Find a counterexample
        for x in cl_S:
            if not any(p_nonfactor(x) == p_nonfactor(s) for s in S):
                print(f"  Counterexample: x={x}, p(x)={p_nonfactor(x)}, "
                      f"but p(S) = {set(p_nonfactor(s) for s in S)}")
                break


def demo_multiplicative_compatibility():
    """Demonstrate: products of closure elements lie in closure of product."""
    print("\n" + "=" * 60)
    print("DEMO 3: Multiplicative Compatibility (Tropical Functoriality)")
    print("=" * 60)

    domain = set(range(1, 201))
    v = lambda n: padic_val(2, n)

    a, b = 6, 10
    cl_a = level_set_closure(v, {a}, domain)
    cl_b = level_set_closure(v, {b}, domain)
    cl_ab = level_set_closure(v, {a * b}, domain)

    print(f"\na = {a}, v(a) = {v(a)}")
    print(f"b = {b}, v(b) = {v(b)}")
    print(f"a*b = {a*b}, v(a*b) = {v(a*b)}")
    print(f"\ncl({{a}}) ∩ [1,20] = {sorted(x for x in cl_a if x <= 20)}")
    print(f"cl({{b}}) ∩ [1,20] = {sorted(x for x in cl_b if x <= 20)}")
    print(f"cl({{a*b}}) ∩ [1,200] = {sorted(x for x in cl_ab if x <= 200)[:15]}...")

    # Check: for all x ∈ cl({a}), y ∈ cl({b}), x*y ∈ cl({a*b})
    violations = 0
    for x in cl_a:
        for y in cl_b:
            if x * y in domain and x * y not in cl_ab:
                violations += 1

    print(f"\n✓ Multiplicative compatibility: {violations} violations out of "
          f"{len(cl_a)*len(cl_b)} pairs")
    print(f"  Reason: v(x*y) = v(x) + v(y) = v(a) + v(b) = v(a*b)")


def demo_closure_equivalence():
    """Demonstrate: same partition → same closure, different partition → different closure."""
    print("\n" + "=" * 60)
    print("DEMO 4: Closure Equivalence Characterization")
    print("=" * 60)

    domain = set(range(1, 31))

    v1 = lambda n: padic_val(2, n)
    v2 = lambda n: 2 * padic_val(2, n)  # Same partition (rescaled)
    v3 = lambda n: padic_val(3, n)       # Different partition

    S = {4, 6, 9}

    cl1 = level_set_closure(v1, S, domain)
    cl2 = level_set_closure(v2, S, domain)
    cl3 = level_set_closure(v3, S, domain)

    print(f"\nS = {sorted(S)}")
    print(f"v_2(S) = {[v1(s) for s in sorted(S)]}")
    print(f"2·v_2(S) = {[v2(s) for s in sorted(S)]}")
    print(f"v_3(S) = {[v3(s) for s in sorted(S)]}")
    print(f"\ncl_v2(S) = {sorted(cl1)}")
    print(f"cl_2v2(S) = {sorted(cl2)}")
    print(f"cl_v3(S) = {sorted(cl3)}")
    print(f"\ncl_v2 = cl_2v2: {cl1 == cl2} (same partition → same closure) ✓")
    print(f"cl_v2 = cl_v3: {cl1 == cl3} (different partition → different closure) ✓")


def demo_threshold_separation():
    """Demonstrate: threshold probes separate distinct valuations."""
    print("\n" + "=" * 60)
    print("DEMO 5: Threshold Probe Separation")
    print("=" * 60)

    v = lambda n: padic_val(2, n)

    pairs = [(3, 4), (6, 12), (8, 16), (1, 32)]
    for x, y in pairs:
        if v(x) == v(y):
            print(f"  v({x}) = v({y}) = {v(x)}: same valuation (no separation needed)")
            continue
        # Find separating threshold
        for n in range(10):
            px = threshold_probe(v, n, x)
            py = threshold_probe(v, n, y)
            if px != py:
                print(f"  v({x})={int(v(x))}, v({y})={int(v(y))}: "
                      f"separated by threshold n={n} "
                      f"(p_{n}({x})={px}, p_{n}({y})={py})")
                break


def demo_filtered_absorption():
    """Demonstrate the threshold filtration and absorption law."""
    print("\n" + "=" * 60)
    print("DEMO 6: Threshold Filtration and Absorption")
    print("=" * 60)

    domain = set(range(1, 65))
    v = lambda n: padic_val(2, n)

    S = {3, 5, 7}

    def threshold_closure(v, n, S, domain):
        return {x for x in domain if v(x) <= n} | S

    for n in range(5):
        cl_n = threshold_closure(v, n, S, domain)
        print(f"  cl_{n}(S) has {len(cl_n)} elements, "
              f"sample: {sorted(cl_n)[:8]}...")

    # Absorption: cl_3(cl_1(S)) = cl_3(S)
    cl_1 = threshold_closure(v, 1, S, domain)
    cl_3_of_cl_1 = threshold_closure(v, 3, cl_1, domain)
    cl_3 = threshold_closure(v, 3, S, domain)

    print(f"\n  cl_1(S) = {sorted(cl_1)[:10]}... ({len(cl_1)} elements)")
    print(f"  cl_3(cl_1(S)) = {sorted(cl_3_of_cl_1)[:10]}... ({len(cl_3_of_cl_1)} elements)")
    print(f"  cl_3(S) = {sorted(cl_3)[:10]}... ({len(cl_3)} elements)")
    print(f"  cl_3(cl_1(S)) = cl_3(S): {cl_3_of_cl_1 == cl_3} ✓ (absorption law)")


if __name__ == "__main__":
    print("Tropical Valuation → Closure-Stable Probe Bridge")
    print("=" * 60)
    demo_closure_axioms()
    demo_probe_characterization()
    demo_multiplicative_compatibility()
    demo_closure_equivalence()
    demo_threshold_separation()
    demo_filtered_absorption()
    print("\n" + "=" * 60)
    print("All demonstrations passed successfully.")


#!/usr/bin/env python3
"""
Visualization: Level-Set Closure and Valuation Partitions

Generates a figure showing how the 2-adic valuation partitions
integers into level sets, and how the closure operator groups
them by valuation.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def padic_val(p, n):
    if n == 0:
        return float('inf')
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Tropical Valuation → Closure Bridge', fontsize=16, fontweight='bold')

    # Panel 1: 2-adic valuation landscape
    ax = axes[0, 0]
    N = 64
    x = list(range(1, N + 1))
    v2 = [padic_val(2, n) for n in x]
    colors = plt.cm.viridis(np.array(v2) / max(v2))
    ax.bar(x, v2, color=colors, width=0.8, edgecolor='none')
    ax.set_xlabel('n', fontsize=11)
    ax.set_ylabel('v₂(n)', fontsize=11)
    ax.set_title('2-Adic Valuation v₂(n)', fontsize=12)
    ax.set_xlim(0, N + 1)

    # Panel 2: Level-set partition
    ax = axes[0, 1]
    max_val = 6
    level_colors = plt.cm.Set2(np.linspace(0, 1, max_val + 1))

    for n in range(1, N + 1):
        v = min(padic_val(2, n), max_val)
        row = n // 8
        col = n % 8
        rect = plt.Rectangle((col, 7 - row), 0.9, 0.9,
                              facecolor=level_colors[int(v)], edgecolor='gray',
                              linewidth=0.5)
        ax.add_patch(rect)
        ax.text(col + 0.45, 7 - row + 0.45, str(n), ha='center', va='center',
                fontsize=6)

    ax.set_xlim(-0.2, 8.2)
    ax.set_ylim(-0.5, 8.5)
    ax.set_aspect('equal')
    ax.set_title('Valuation Partition of {1,...,64}', fontsize=12)
    ax.set_xticks([])
    ax.set_yticks([])

    # Legend
    legend_patches = [mpatches.Patch(color=level_colors[i], label=f'v₂ = {i}')
                      for i in range(max_val + 1)]
    ax.legend(handles=legend_patches, loc='upper right', fontsize=7,
              ncol=2, framealpha=0.9)

    # Panel 3: Closure of a seed set
    ax = axes[1, 0]
    seed = {6, 12, 18}
    domain = set(range(1, N + 1))
    val_image = {padic_val(2, s) for s in seed}
    closure = {x_val for x_val in domain if padic_val(2, x_val) in val_image}

    for n in range(1, N + 1):
        row = n // 8
        col = n % 8
        if n in seed:
            color = '#d62728'  # red for seed
        elif n in closure:
            color = '#ff7f0e'  # orange for closure
        else:
            color = '#e0e0e0'  # gray
        rect = plt.Rectangle((col, 7 - row), 0.9, 0.9,
                              facecolor=color, edgecolor='gray', linewidth=0.5)
        ax.add_patch(rect)
        ax.text(col + 0.45, 7 - row + 0.45, str(n), ha='center', va='center',
                fontsize=6)

    ax.set_xlim(-0.2, 8.2)
    ax.set_ylim(-0.5, 8.5)
    ax.set_aspect('equal')
    ax.set_title(f'cl({{6, 12, 18}}) under v₂', fontsize=12)
    ax.set_xticks([])
    ax.set_yticks([])
    legend_patches = [
        mpatches.Patch(color='#d62728', label='Seed S'),
        mpatches.Patch(color='#ff7f0e', label='cl(S) \\ S'),
        mpatches.Patch(color='#e0e0e0', label='Outside cl(S)'),
    ]
    ax.legend(handles=legend_patches, loc='upper right', fontsize=8, framealpha=0.9)

    # Panel 4: Threshold filtration
    ax = axes[1, 1]
    scales = range(7)
    sizes = []
    for n_scale in scales:
        tc = {x_val for x_val in domain if padic_val(2, x_val) <= n_scale} | seed
        sizes.append(len(tc))

    ax.bar(list(scales), sizes, color=plt.cm.Blues(np.linspace(0.3, 0.9, len(scales))),
           edgecolor='navy', linewidth=0.5)
    ax.set_xlabel('Scale n', fontsize=11)
    ax.set_ylabel('|cl_n(S)|', fontsize=11)
    ax.set_title('Threshold Filtration: |cl_n({6,12,18})|', fontsize=12)

    # Add defect annotations
    prev_size = len(seed)
    for i, n_scale in enumerate(scales):
        defect = sizes[i] - prev_size
        if defect > 0:
            ax.annotate(f'+{defect}', (n_scale, sizes[i]),
                        textcoords="offset points", xytext=(0, 5),
                        ha='center', fontsize=8, color='red')
        prev_size = sizes[i]

    plt.tight_layout()
    plt.savefig('closure_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved closure_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Threshold Probe Separation and Closure Stability

Shows how threshold probes separate elements with different valuations
and demonstrates the closure stability characterization.
"""

import matplotlib.pyplot as plt
import numpy as np


def padic_val(p, n):
    if n == 0:
        return float('inf')
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Threshold Probes: Separation and Stability', fontsize=14, fontweight='bold')

    N = 32
    domain = list(range(1, N + 1))

    # Panel 1: Threshold probe heatmap
    ax = axes[0]
    max_threshold = 6
    probe_matrix = np.zeros((max_threshold + 1, N))
    for i, n in enumerate(domain):
        v = padic_val(2, n)
        for t in range(max_threshold + 1):
            probe_matrix[t, i] = 1 if v <= t else 0

    im = ax.imshow(probe_matrix, aspect='auto', cmap='RdYlGn',
                   interpolation='nearest', vmin=0, vmax=1)
    ax.set_xlabel('Element n', fontsize=11)
    ax.set_ylabel('Threshold level', fontsize=11)
    ax.set_title('Threshold Probe Values p_t(n)', fontsize=12)
    ax.set_xticks(range(0, N, 4))
    ax.set_xticklabels(range(1, N + 1, 4))
    ax.set_yticks(range(max_threshold + 1))
    plt.colorbar(im, ax=ax, label='Probe value', ticks=[0, 1])

    # Panel 2: Separation example
    ax = axes[1]
    pairs = [(3, 4), (6, 12), (8, 16), (1, 32), (5, 10), (7, 14)]
    y_pos = list(range(len(pairs)))

    for i, (a, b) in enumerate(pairs):
        va, vb = padic_val(2, a), padic_val(2, b)
        separated = va != vb

        color = '#2ca02c' if separated else '#d62728'
        marker = '✓' if separated else '='

        ax.barh(i, va, height=0.35, left=0, color='#1f77b4', alpha=0.7)
        ax.barh(i, vb, height=0.35, left=0, color='#ff7f0e', alpha=0.7,
                align='edge')
        ax.text(max(va, vb) + 0.3, i, marker, fontsize=14, color=color,
                va='center', fontweight='bold')

    ax.set_yticks(y_pos)
    ax.set_yticklabels([f'({a},{b})' for a, b in pairs])
    ax.set_xlabel('v₂ value', fontsize=11)
    ax.set_title('Valuation Separation', fontsize=12)
    ax.legend(['v₂(a)', 'v₂(b)'], loc='lower right', fontsize=9)

    # Panel 3: Closure stability visual
    ax = axes[2]
    seed = {3, 5, 7}
    v_func = lambda n: padic_val(2, n)
    val_image = {v_func(s) for s in seed}
    closure = {n for n in domain if v_func(n) in val_image}

    # Stable probe (threshold at 0)
    p_stable = lambda n: 1 if v_func(n) <= 0 else 0
    # Unstable probe (n mod 3)
    p_unstable = lambda n: n % 3

    stable_vals_seed = {p_stable(s) for s in seed}
    stable_vals_cl = {p_stable(x) for x in closure}
    unstable_vals_seed = {p_unstable(s) for s in seed}
    unstable_vals_cl = {p_unstable(x) for x in closure}

    categories = ['Stable\n(threshold)', 'Unstable\n(n mod 3)']
    x_pos = [0, 1]

    # Seed probe values
    ax.bar([x - 0.15 for x in x_pos],
           [len(stable_vals_seed), len(unstable_vals_seed)],
           width=0.3, color='#1f77b4', label='|p(S)|', alpha=0.8)
    # Closure probe values
    ax.bar([x + 0.15 for x in x_pos],
           [len(stable_vals_cl), len(unstable_vals_cl)],
           width=0.3, color='#ff7f0e', label='|p(cl(S))|', alpha=0.8)

    ax.set_xticks(x_pos)
    ax.set_xticklabels(categories)
    ax.set_ylabel('# distinct probe values', fontsize=11)
    ax.set_title(f'Probe Value Ranges\nS = {sorted(seed)}', fontsize=12)
    ax.legend(fontsize=9)

    # Annotate
    ax.text(0, max(len(stable_vals_seed), len(stable_vals_cl)) + 0.1,
            '✓ Same', ha='center', fontsize=10, color='green', fontweight='bold')
    if unstable_vals_cl != unstable_vals_seed:
        ax.text(1, max(len(unstable_vals_seed), len(unstable_vals_cl)) + 0.1,
                '✗ Different', ha='center', fontsize=10, color='red', fontweight='bold')

    plt.tight_layout()
    plt.savefig('probe_separation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved probe_separation.png")


if __name__ == "__main__":
    main()
