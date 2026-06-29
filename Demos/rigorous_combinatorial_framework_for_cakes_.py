#!/usr/bin/env python3
"""
Cake Moduli Demo: Numerical Examples

Demonstrates the key theorems from the cake moduli framework:
1. Superadditivity of moduli dimension under handle gluing
2. Additivity under boundary gluing
3. The moduli-Euler bridge
4. Tropical correspondence
5. Geometric classification
"""

from algorithms import (
    Cake, TropicalCake, DISK, PANTS, PUNCTURED_TORUS, ANNULUS,
    verify_superadditivity, verify_moduli_euler_bridge,
    iterated_handle_glue, build_gluing_tower, classify_surface
)


def demo_basic_invariants():
    """Show basic invariants of standard cakes."""
    print("=" * 60)
    print("§1. Basic Cake Invariants")
    print("=" * 60)

    cakes = [
        ("Disk", DISK),
        ("Annulus", ANNULUS),
        ("Pants", PANTS),
        ("Punctured Torus", PUNCTURED_TORUS),
        ("Genus-2 surface, 1 boundary", Cake(2, 1, 0, 1)),
        ("Sphere with 4 punctures", Cake(0, 0, 4, 1)),
    ]

    print(f"{'Name':<30} {'g':>3} {'b':>3} {'n':>3} {'χ':>4} {'dim':>5} {'type':>12}")
    print("-" * 60)
    for name, c in cakes:
        print(f"{name:<30} {c.genus:>3} {c.boundary:>3} {c.marked:>3} "
              f"{c.euler_char():>4} {c.moduli_dim():>5} {c.geom_type().value:>12}")
    print()


def demo_superadditivity():
    """Demonstrate the superadditivity theorem."""
    print("=" * 60)
    print("§2. Superadditivity Under Handle Gluing")
    print("=" * 60)
    print("Theorem: dim(C₁ ⊕ C₂) = dim(C₁) + dim(C₂) + 6")
    print()

    pairs = [
        (DISK, DISK, "Disk ⊕ Disk"),
        (PANTS, PANTS, "Pants ⊕ Pants"),
        (DISK, PANTS, "Disk ⊕ Pants"),
        (PUNCTURED_TORUS, DISK, "Punct. Torus ⊕ Disk"),
        (PUNCTURED_TORUS, PANTS, "Punct. Torus ⊕ Pants"),
        (Cake(2, 2, 3, 1), Cake(1, 1, 2, 1), "Complex ⊕ Complex"),
    ]

    print(f"{'Gluing':<30} {'dim₁':>5} {'dim₂':>5} {'sum':>5} {'dim_glue':>9} {'surplus':>8} {'✓':>3}")
    print("-" * 70)
    for c1, c2, name in pairs:
        d1, d2 = c1.moduli_dim(), c2.moduli_dim()
        glued = c1.handle_glue(c2)
        dg = glued.moduli_dim()
        verified, surplus = verify_superadditivity(c1, c2)
        mark = "✓" if verified else "✗"
        print(f"{name:<30} {d1:>5} {d2:>5} {d1+d2:>5} {dg:>9} {surplus:>8} {mark:>3}")
    print()


def demo_boundary_vs_handle():
    """Compare handle gluing (superadditive) vs boundary gluing (additive)."""
    print("=" * 60)
    print("§3. Handle Gluing vs Boundary Gluing")
    print("=" * 60)
    print("Handle: dim(C₁⊕C₂) = dim₁ + dim₂ + 6")
    print("Boundary: dim(C₁∪C₂) = dim₁ + dim₂")
    print("Gap = 6 always")
    print()

    pairs = [
        (DISK, DISK),
        (PANTS, PANTS),
        (DISK, PANTS),
        (PUNCTURED_TORUS, PANTS),
    ]

    print(f"{'C₁':<20} {'C₂':<20} {'handle':>7} {'boundary':>9} {'gap':>5}")
    print("-" * 65)
    for c1, c2 in pairs:
        h = c1.handle_glue(c2).moduli_dim()
        b = c1.boundary_glue(c2).moduli_dim()
        c1_name = f"g={c1.genus},b={c1.boundary}"
        c2_name = f"g={c2.genus},b={c2.boundary}"
        print(f"{c1_name:<20} {c2_name:<20} {h:>7} {b:>9} {h-b:>5}")
    print()


def demo_moduli_euler_bridge():
    """Demonstrate dim = -3χ + 2n."""
    print("=" * 60)
    print("§4. Moduli-Euler Bridge: dim = -3χ + 2n")
    print("=" * 60)

    cakes = [
        Cake(g, b, n, 1)
        for g in range(4) for b in range(4) for n in range(4)
        if g + b + n <= 5
    ]

    all_verified = all(verify_moduli_euler_bridge(c) for c in cakes)
    print(f"Verified for {len(cakes)} cakes: {'ALL PASS ✓' if all_verified else 'FAILURES FOUND ✗'}")
    print()


def demo_gluing_tower():
    """Show moduli dimension growth under iterated handle gluing."""
    print("=" * 60)
    print("§5. Gluing Tower: Iterated Handle Gluing of Disks")
    print("=" * 60)
    print("Each handle gluing adds 6 to the moduli dimension")
    print()

    stages = build_gluing_tower(8, PANTS)
    print(f"{'Stage':>6} {'Genus':>6} {'Bound.':>7} {'dim':>6} {'Δdim':>6} {'χ':>4} {'Type':>12}")
    print("-" * 55)
    prev_dim = None
    for i, (c, d) in enumerate(stages):
        delta = "" if prev_dim is None else str(d - prev_dim)
        print(f"{i:>6} {c.genus:>6} {c.boundary:>7} {d:>6} {delta:>6} "
              f"{c.euler_char():>4} {c.geom_type().value:>12}")
        prev_dim = d
    print()


def demo_tropical():
    """Demonstrate the tropical moduli formula."""
    print("=" * 60)
    print("§6. Tropical Correspondence")
    print("=" * 60)
    print("For trivalent graphs: dim_trop = 3β₁ - 3 + ℓ")
    print()

    # Generate trivalent tropical cakes
    tropicals = []
    for v in range(0, 12, 2):  # interior vertices (must be even for trivalent)
        for l in range(1, 8):
            e = (3 * v + l) // 2
            if 2 * e == 3 * v + l:  # trivalent condition
                t = TropicalCake(e, l, v, 1)
                tropicals.append(t)

    print(f"{'Edges':>6} {'Leaves':>7} {'IntVtx':>7} {'β₁':>4} {'dim_trop':>9} {'3β₁-3+ℓ':>9} {'✓':>3}")
    print("-" * 50)
    for t in tropicals[:15]:
        formula = 3 * t.betti() - 3 + t.leaves
        verified = t.verify_tropical_formula()
        mark = "✓" if verified else "✗"
        print(f"{t.edge_count:>6} {t.leaves:>7} {t.interior_vertices:>7} "
              f"{t.betti():>4} {t.trop_moduli_dim():>9} {formula:>9} {mark:>3}")

    all_ok = all(t.verify_tropical_formula() for t in tropicals)
    print(f"\nAll {len(tropicals)} trivalent graphs verified: {'✓' if all_ok else '✗'}")
    print()


def demo_classification():
    """Show the geometric classification of surfaces."""
    print("=" * 60)
    print("§7. Geometric Classification")
    print("=" * 60)
    print()

    print("Surfaces by type:")
    for g in range(4):
        for b in range(5):
            c = classify_surface(g, b, 0)
            if c["moduli_dim"] >= -6 and c["moduli_dim"] <= 20:
                print(f"  g={g}, b={b}: χ={c['euler_char']:>3}, "
                      f"dim={c['moduli_dim']:>3}, type={c['geom_type']}")
    print()


if __name__ == "__main__":
    demo_basic_invariants()
    demo_superadditivity()
    demo_boundary_vs_handle()
    demo_moduli_euler_bridge()
    demo_gluing_tower()
    demo_tropical()
    demo_classification()
    print("All demos completed successfully.")


#!/usr/bin/env python3
"""Visualization: Moduli dimension landscape for surfaces by genus and boundary count."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def moduli_dim(g, n, b):
    return 6 * g - 6 + 2 * n + 3 * b

def euler_char(g, b):
    return 2 - 2 * g - b

def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Plot 1: Moduli dimension heatmap
    ax = axes[0]
    G = np.arange(0, 8)
    B = np.arange(0, 10)
    GG, BB = np.meshgrid(G, B)
    DD = 6 * GG - 6 + 3 * BB  # n=0
    im = ax.imshow(DD, origin='lower', aspect='auto', cmap='RdYlBu_r',
                   extent=[-0.5, 7.5, -0.5, 9.5])
    ax.set_xlabel('Genus g', fontsize=12)
    ax.set_ylabel('Boundary components b', fontsize=12)
    ax.set_title('Moduli Dimension (n=0)', fontsize=14)
    plt.colorbar(im, ax=ax, label='dim = 6g - 6 + 3b')

    # Annotate geometric types
    for g in G:
        for b in B:
            chi = euler_char(g, b)
            d = moduli_dim(g, 0, b)
            color = 'white' if abs(d) > 15 else 'black'
            ax.text(g, b, str(d), ha='center', va='center', fontsize=7, color=color)

    # Plot 2: Superadditivity demonstration
    ax = axes[1]
    n_gluings = range(1, 10)
    base_dim = 3  # pants
    dims_handle = [base_dim + i * (base_dim + 6) for i in range(len(n_gluings))]
    dims_handle = [base_dim]
    dims_boundary = [base_dim]
    for i in range(1, 10):
        dims_handle.append(dims_handle[-1] + base_dim + 6)
        dims_boundary.append(dims_boundary[-1] + base_dim)

    x = list(range(len(dims_handle)))
    ax.plot(x, dims_handle, 'ro-', linewidth=2, markersize=8, label='Handle gluing (+6 each)')
    ax.plot(x, dims_boundary, 'bs-', linewidth=2, markersize=8, label='Boundary gluing (+0 each)')
    ax.fill_between(x, dims_boundary, dims_handle, alpha=0.2, color='red',
                    label=f'Surplus = 6 × n')
    ax.set_xlabel('Number of gluings', fontsize=12)
    ax.set_ylabel('Moduli dimension', fontsize=12)
    ax.set_title('Superadditivity Gap', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 3: Geometric type regions
    ax = axes[2]
    g_range = np.linspace(0, 5, 200)
    b_range = np.linspace(0, 10, 200)
    GG, BB = np.meshgrid(g_range, b_range)
    CHI = 2 - 2 * GG - BB

    # Color by type
    colors = np.zeros_like(CHI)
    colors[CHI > 0] = 1   # spherical
    colors[CHI == 0] = 0  # flat (rare in continuous grid)
    colors[CHI < 0] = -1  # hyperbolic

    ax.contourf(GG, BB, CHI, levels=[-20, -0.001, 0.001, 20],
                colors=['#ff6b6b', '#ffd93d', '#6bcb77'], alpha=0.7)
    ax.contour(GG, BB, CHI, levels=[0], colors='black', linewidths=2)

    # Plot standard cakes
    cakes = [(0, 1, 'Disk'), (0, 2, 'Annulus'), (0, 3, 'Pants'),
             (1, 0, 'Torus'), (1, 1, 'P.Torus'), (2, 0, 'g=2')]
    for g, b, name in cakes:
        chi = euler_char(g, b)
        marker = 'o' if chi > 0 else ('s' if chi == 0 else '^')
        ax.plot(g, b, marker, markersize=10, color='black', zorder=5)
        ax.annotate(name, (g, b), textcoords="offset points",
                   xytext=(8, 5), fontsize=9)

    ax.set_xlabel('Genus g', fontsize=12)
    ax.set_ylabel('Boundary components b', fontsize=12)
    ax.set_title('Geometric Classification', fontsize=14)
    ax.text(0.2, 0.3, 'Spherical\n(χ > 0)', fontsize=11, color='darkgreen',
            transform=ax.transAxes)
    ax.text(0.5, 0.7, 'Hyperbolic\n(χ < 0)', fontsize=11, color='darkred',
            transform=ax.transAxes)

    plt.tight_layout()
    plt.savefig('moduli_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved moduli_landscape.png")

if __name__ == "__main__":
    main()
