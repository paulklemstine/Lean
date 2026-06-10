#!/usr/bin/env python3
"""
GL₃ Tropical Satake Finite Reconstruction — Interactive Demo

Demonstrates the main theorem: a tropical Hecke function on the bounded
dominant cone of GL₃ is uniquely determined by its Levi marginal restrictions
to the two chamber walls, subject to diagonal compatibility.

The reconstruction formula is:
    f(a, b, c) = f(a, b, b) + f(b, b, c) - f(b, b, b)

where f(a,b,b) is the levi23 marginal (α₂-wall) and f(b,b,c) is the levi12
marginal (α₁-wall, evaluated at the middle coordinate b).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import itertools
from typing import Dict, Tuple, Optional

# ──────────────────────────────────────────────────────────────────────
# 1.  Core Data Structures
# ──────────────────────────────────────────────────────────────────────

def dominant_weights(B: int):
    """Generate all dominant weights (a,b,c) with B >= a >= b >= c >= 0."""
    for a in range(B + 1):
        for b in range(a + 1):
            for c in range(b + 1):
                yield (a, b, c)

def dominant_pairs(B: int):
    """Generate all dominant pairs (x,y) with B >= x >= y >= 0."""
    for x in range(B + 1):
        for y in range(x + 1):
            yield (x, y)

def count_dominant_weights(B: int) -> int:
    return (B + 1) * (B + 2) * (B + 3) // 6

def count_dominant_pairs(B: int) -> int:
    return (B + 1) * (B + 2) // 2

# ──────────────────────────────────────────────────────────────────────
# 2.  Tropical Hecke Functions and the Reconstruction Formula
# ──────────────────────────────────────────────────────────────────────

def is_trop_hecke(f: Dict[Tuple, int], B: int) -> bool:
    """Check whether f satisfies the additive wall decomposition."""
    for a, b, c in dominant_weights(B):
        if f[(a, b, c)] != f[(a, b, b)] + f[(b, b, c)] - f[(b, b, b)]:
            return False
    return True

def extract_levi23(f: Dict[Tuple, int], B: int) -> Dict[Tuple, int]:
    """levi23(a,b) = f(a,b,b)."""
    return {(a, b): f[(a, b, b)] for a, b in dominant_pairs(B)}

def extract_levi12(f: Dict[Tuple, int], B: int) -> Dict[Tuple, int]:
    """levi12(a,c) = f(a,a,c)."""
    return {(a, c): f[(a, a, c)] for a, c in dominant_pairs(B)}

def check_diagonal_compat(levi23: Dict, levi12: Dict, B: int) -> bool:
    return all(levi23[(n, n)] == levi12[(n, n)] for n in range(B + 1))

def reconstruct(levi23: Dict, levi12: Dict, B: int) -> Dict[Tuple, int]:
    """f(a,b,c) = levi23(a,b) + levi12(b,c) - levi12(b,b)."""
    f = {}
    for a, b, c in dominant_weights(B):
        f[(a, b, c)] = levi23[(a, b)] + levi12[(b, c)] - levi12[(b, b)]
    return f

# ──────────────────────────────────────────────────────────────────────
# 3.  Example Tropical Hecke Functions
# ──────────────────────────────────────────────────────────────────────

def linear_hecke(B: int, alpha=3, beta=2, gamma=1):
    """f(a,b,c) = α·a + β·b + γ·c. Always Hecke (linear functions decompose trivially)."""
    return {(a, b, c): alpha * a + beta * b + gamma * c
            for a, b, c in dominant_weights(B)}

def product_hecke(B: int):
    """f(a,b,c) = a² + b·c. Satisfies Hecke because:
    f(a,b,b) + f(b,b,c) - f(b,b,b) = (a²+b²) + (b²+bc) - (b²+b²) = a² + bc = f(a,b,c)."""
    return {(a, b, c): a * a + b * c for a, b, c in dominant_weights(B)}

def exponential_hecke(B: int):
    """f(a,b,c) = 2^a + 2^c. Satisfies Hecke:
    f(a,b,b) + f(b,b,c) - f(b,b,b) = (2^a+2^b) + (2^b+2^c) - (2^b+2^b) = 2^a + 2^c."""
    return {(a, b, c): 2**a + 2**c for a, b, c in dominant_weights(B)}

def wall_sum_hecke(B: int):
    """f(a,b,c) = a·(a+1)/2 + c·(c+1)/2 — sum-of-triangulars.
    This only depends on a and c (not b), so it decomposes as g(a) + h(c).
    Hecke: f(a,b,b) + f(b,b,c) - f(b,b,b) = [T(a)+T(b)] + [T(b)+T(c)] - [T(b)+T(b)]
          = T(a) + T(c) = f(a,b,c) where T(n) = n(n+1)/2."""
    return {(a, b, c): a * (a + 1) // 2 + c * (c + 1) // 2
            for a, b, c in dominant_weights(B)}

def tropical_schur_21(B: int):
    """f(a,b,c) = 2a + b. Always Hecke (linear)."""
    return {(a, b, c): 2 * a + b for a, b, c in dominant_weights(B)}

# ──────────────────────────────────────────────────────────────────────
# 4.  Verification Demo
# ──────────────────────────────────────────────────────────────────────

def demo_roundtrip(name: str, f: Dict, B: int):
    """Demonstrate the full roundtrip: extract → reconstruct → compare."""
    print(f"\n{'='*60}")
    print(f"  Demo: {name} (B = {B})")
    print(f"{'='*60}")

    hecke_ok = is_trop_hecke(f, B)
    print(f"  Tropical Hecke condition: {'✓ PASS' if hecke_ok else '✗ FAIL'}")

    l23 = extract_levi23(f, B)
    l12 = extract_levi12(f, B)
    compat_ok = check_diagonal_compat(l23, l12, B)
    print(f"  Diagonal compatibility:   {'✓ PASS' if compat_ok else '✗ FAIL'}")

    f_recon = reconstruct(l23, l12, B)
    match = all(f[w] == f_recon[w] for w in dominant_weights(B))
    print(f"  Roundtrip reconstruction: {'✓ PASS' if match else '✗ FAIL'}")

    weights = list(dominant_weights(B))
    n_pairs = count_dominant_pairs(B)
    print(f"\n  Total dominant weights:  {len(weights)}")
    print(f"  Wall-23 data points:    {n_pairs}")
    print(f"  Wall-12 data points:    {n_pairs}")
    print(f"  Diagonal points:        {B + 1}")
    print(f"  Independent data:       {2 * n_pairs - (B + 1)}")

    print(f"\n  Sample reconstruction (first 8 weights):")
    for w in weights[:8]:
        a, b, c = w
        print(f"    f{w} = {f[w]:4d} = l23({a},{b}) + l12({b},{c}) - l12({b},{b})"
              f" = {l23[(a,b)]} + {l12[(b,c)]} - {l12[(b,b)]}")

    return hecke_ok and compat_ok and match

# ──────────────────────────────────────────────────────────────────────
# 5.  Bijection Verification (small cases)
# ──────────────────────────────────────────────────────────────────────

def verify_bijection_exhaustive(B: int, val_range: range):
    """Verify the bijection by checking both roundtrips exhaustively.
    This works over ℤ-valued functions (no range restriction on reconstructed values)."""
    pairs = list(dominant_pairs(B))
    n_p = len(pairs)

    # Generate all compatible datasets (l23, l12 with diagonal compat)
    compat_datasets = []
    for l23_vals in itertools.product(val_range, repeat=n_p):
        l23 = dict(zip(pairs, l23_vals))
        for l12_vals in itertools.product(val_range, repeat=n_p):
            l12 = dict(zip(pairs, l12_vals))
            if check_diagonal_compat(l23, l12, B):
                compat_datasets.append((l23, l12))

    # For each compatible dataset, reconstruct and verify roundtrip
    roundtrip_ok = 0
    hecke_ok = 0
    for l23, l12 in compat_datasets:
        f = reconstruct(l23, l12, B)
        if is_trop_hecke(f, B):
            hecke_ok += 1
        # Check roundtrip: extract marginals from reconstructed f
        l23_back = extract_levi23(f, B)
        l12_back = extract_levi12(f, B)
        if l23_back == l23 and l12_back == l12:
            roundtrip_ok += 1

    return len(compat_datasets), hecke_ok, roundtrip_ok

# ──────────────────────────────────────────────────────────────────────
# 6.  Visualization
# ──────────────────────────────────────────────────────────────────────

def plot_dominant_cone(B: int, f: Optional[Dict] = None, title: str = ""):
    """Plot the bounded dominant cone with optional function values."""
    fig = plt.figure(figsize=(12, 5))

    ax1 = fig.add_subplot(121, projection='3d')
    weights = list(dominant_weights(B))
    xs = [w[0] for w in weights]
    ys = [w[1] for w in weights]
    zs = [w[2] for w in weights]

    if f is not None:
        vals = [f[w] for w in weights]
        sc = ax1.scatter(xs, ys, zs, c=vals, cmap='viridis', s=80, edgecolors='k', linewidth=0.5)
        plt.colorbar(sc, ax=ax1, shrink=0.6, label='f value')
    else:
        colors = []
        for a, b, c in weights:
            if a == b and b == c:
                colors.append('red')
            elif a == b:
                colors.append('blue')
            elif b == c:
                colors.append('green')
            else:
                colors.append('gray')
        ax1.scatter(xs, ys, zs, c=colors, s=80, edgecolors='k', linewidth=0.5)

    ax1.set_xlabel('a'); ax1.set_ylabel('b'); ax1.set_zlabel('c')
    ax1.set_title(f'Dominant Cone (B={B})' if not title else title)

    # 2D projection
    ax2 = fig.add_subplot(122)
    legend_added = set()
    for a, b, c in weights:
        p, q = a - b, b - c
        if a == b and b == c:
            color, marker, lbl = 'red', 's', 'Diagonal'
        elif a == b:
            color, marker, lbl = 'blue', '^', 'α₁-wall (a=b)'
        elif b == c:
            color, marker, lbl = 'green', 'v', 'α₂-wall (b=c)'
        else:
            color, marker, lbl = 'gray', 'o', 'Interior'

        label = lbl if lbl not in legend_added else None
        legend_added.add(lbl)

        if f is not None:
            ax2.annotate(f'{f[(a,b,c)]}', (p, q), fontsize=7, ha='center', va='bottom')

        ax2.plot(p, q, marker=marker, color=color, markersize=8,
                 markeredgecolor='k', markeredgewidth=0.5, label=label)

    ax2.set_xlabel('p = a − b'); ax2.set_ylabel('q = b − c')
    ax2.set_title('Reduced coordinates')
    ax2.legend(loc='upper right', fontsize=8)
    ax2.set_aspect('equal'); ax2.grid(True, alpha=0.3)
    plt.tight_layout()
    return fig

def plot_reconstruction_diagram(B: int):
    """Visualize the reconstruction: walls → interior."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    weights = list(dominant_weights(B))
    f = product_hecke(B)
    l23 = extract_levi23(f, B)
    l12 = extract_levi12(f, B)

    for idx, (ax, title_text, show_interior) in enumerate(zip(axes,
        ['Original f(a,b,c) = a² + bc',
         'Extracted Wall Data',
         'Reconstructed f̂(a,b,c)'],
        [True, False, True])):

        ax.set_title(title_text, fontsize=11)
        f_show = f if idx != 2 else reconstruct(l23, l12, B)

        for a, b, c in weights:
            p, q = a - b, b - c
            is_wall = (a == b) or (b == c)

            if idx == 1 and not is_wall:
                ax.plot(p, q, 'o', color='lightgray', markersize=20,
                        markeredgecolor='gray', markeredgewidth=0.5)
                ax.annotate('?', (p, q), fontsize=10, ha='center', va='center', color='gray')
            else:
                if a == b and b == c:
                    color = 'red'
                elif a == b:
                    color = 'blue'
                elif b == c:
                    color = 'green'
                else:
                    color = 'orange'
                ax.plot(p, q, 'o', color=color, markersize=20,
                        markeredgecolor='k', markeredgewidth=0.5)
                ax.annotate(f'{f_show[(a,b,c)]}', (p, q), fontsize=8,
                            ha='center', va='center', weight='bold',
                            color='white' if color in ['blue', 'red'] else 'black')

        ax.set_xlabel('p = a − b'); ax.set_ylabel('q = b − c')
        ax.set_aspect('equal'); ax.grid(True, alpha=0.3)

    plt.suptitle(f'GL₃ Tropical Reconstruction (B={B})', fontsize=13, y=1.02)
    plt.tight_layout()
    return fig

def plot_dimension_comparison(max_B: int = 8):
    """Compare dimensions: total weights vs independent wall data."""
    Bs = list(range(1, max_B + 1))
    n_weights = [count_dominant_weights(B) for B in Bs]
    n_indep = [2 * count_dominant_pairs(B) - (B + 1) for B in Bs]
    n_constraints = [nw - ni for nw, ni in zip(n_weights, n_indep)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(Bs, n_weights, 'o-', color='steelblue', linewidth=2, markersize=8,
             label='|DomWt(B)| — total weights')
    ax1.plot(Bs, n_indep, 's-', color='darkorange', linewidth=2, markersize=8,
             label='Independent wall data')
    ax1.fill_between(Bs, n_indep, n_weights, alpha=0.15, color='red',
                     label='Hecke constraints')
    ax1.set_xlabel('Bound B', fontsize=12)
    ax1.set_ylabel('Count', fontsize=12)
    ax1.set_title('Degrees of Freedom', fontsize=13)
    ax1.legend(fontsize=9); ax1.grid(True, alpha=0.3)

    ax2.plot(Bs, n_constraints, 'D-', color='crimson', linewidth=2, markersize=8)
    ax2.set_xlabel('Bound B', fontsize=12)
    ax2.set_ylabel('Number of Hecke constraints', fontsize=12)
    ax2.set_title('Interior Points = Hecke Constraints', fontsize=13)
    ax2.grid(True, alpha=0.3)

    for i, B in enumerate(Bs):
        ax2.annotate(f'{n_constraints[i]}', (B, n_constraints[i]),
                     fontsize=9, textcoords='offset points', xytext=(5, 5))

    plt.tight_layout()
    return fig

# ──────────────────────────────────────────────────────────────────────
# 7.  Main
# ──────────────────────────────────────────────────────────────────────

def main():
    print("=" * 60)
    print("  GL₃ Tropical Satake Finite Reconstruction — Demo")
    print("=" * 60)

    B = 4
    all_pass = True

    # Demo 1: Linear
    all_pass &= demo_roundtrip("Linear f(a,b,c) = 3a + 2b + c", linear_hecke(B), B)

    # Demo 2: Product
    all_pass &= demo_roundtrip("Product f(a,b,c) = a² + bc", product_hecke(B), B)

    # Demo 3: Exponential
    all_pass &= demo_roundtrip("Exponential f(a,b,c) = 2^a + 2^c", exponential_hecke(B), B)

    # Demo 4: Triangle-number
    all_pass &= demo_roundtrip("Triangle-number f(a,b,c) = T(a) + T(c)", wall_sum_hecke(B), B)

    # Demo 5: Tropical Schur
    all_pass &= demo_roundtrip("Tropical Schur s_{(2,1,0)} = 2a + b", tropical_schur_21(B), B)

    # Exhaustive bijection verification
    print(f"\n{'='*60}")
    print(f"  Exhaustive Bijection Verification (small B)")
    print(f"{'='*60}")
    for B_small in [1, 2]:
        vr = range(0, 3)
        n_compat, n_hecke, n_rt = verify_bijection_exhaustive(B_small, vr)
        print(f"\n  B={B_small}, wall values in {list(vr)}:")
        print(f"    Compatible datasets:         {n_compat}")
        print(f"    → all reconstructions Hecke? {n_hecke} / {n_compat}"
              f"  {'✓' if n_hecke == n_compat else '✗'}")
        print(f"    → all roundtrips match?      {n_rt} / {n_compat}"
              f"  {'✓' if n_rt == n_compat else '✗'}")
        if n_hecke == n_compat and n_rt == n_compat:
            print(f"    BIJECTION VERIFIED ✓")

    # Dimension analysis
    print(f"\n{'='*60}")
    print(f"  Dimension Analysis")
    print(f"{'='*60}")
    print(f"  {'B':>3}  {'|DomWt|':>8}  {'|DomPr|':>8}  {'Indep':>8}  {'Constraints':>12}")
    print(f"  {'─'*3}  {'─'*8}  {'─'*8}  {'─'*8}  {'─'*12}")
    for B_val in range(1, 9):
        nw = count_dominant_weights(B_val)
        np_ = count_dominant_pairs(B_val)
        ni = 2 * np_ - (B_val + 1)
        print(f"  {B_val:3d}  {nw:8d}  {np_:8d}  {ni:8d}  {nw - ni:12d}")

    # Visualizations
    print(f"\n{'='*60}")
    print(f"  Generating visualizations...")
    print(f"{'='*60}")

    fig1 = plot_dominant_cone(3)
    fig1.savefig('gl3_dominant_cone.png', dpi=150, bbox_inches='tight')
    print("  Saved: gl3_dominant_cone.png")

    fig2 = plot_reconstruction_diagram(3)
    fig2.savefig('gl3_reconstruction.png', dpi=150, bbox_inches='tight')
    print("  Saved: gl3_reconstruction.png")

    fig3 = plot_dimension_comparison()
    fig3.savefig('gl3_dimension_comparison.png', dpi=150, bbox_inches='tight')
    print("  Saved: gl3_dimension_comparison.png")

    fig4 = plot_dominant_cone(4, product_hecke(4), title='Hecke Function a² + bc (B=4)')
    fig4.savefig('gl3_hecke_function.png', dpi=150, bbox_inches='tight')
    print("  Saved: gl3_hecke_function.png")

    plt.close('all')

    print(f"\n  {'All roundtrip demos passed!' if all_pass else 'Some demos FAILED!'}")
    print(f"  All demos complete! ✓")

if __name__ == "__main__":
    main()
