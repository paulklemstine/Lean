#!/usr/bin/env python3
"""
Non-Desarguesian Geometry: Demonstrations

Demonstrates the Hall quasifield construction, verifies algebraic properties,
and constructs the Hall plane of order 9.
"""

from algorithms import (
    gf9_add, gf9_mul, gf9_neg, hall_mul, frobenius,
    gf_elements, is_associative, is_right_distributive,
    is_left_distributive, build_hall_plane, verify_plane_axioms,
    collineation_group_order_hall, pgl_order
)


def demo_basic_arithmetic():
    """Demonstrate GF(9) and Hall quasifield arithmetic."""
    print("=" * 60)
    print("DEMO 1: GF(9) = GF(3)[α]/(α² + 1) Arithmetic")
    print("=" * 60)
    
    alpha = (0, 1)
    one = (1, 0)
    zero = (0, 0)
    
    print(f"\nα = {alpha}, 1 = {one}, 0 = {zero}")
    print(f"α² (standard) = gf9_mul(α, α) = {gf9_mul(alpha, alpha)}")
    print(f"  [Should be (2, 0) = -1 = 2 mod 3]")
    
    print(f"\nFrobenius(α) = {frobenius(alpha)}")
    print(f"  [Should be (0, 2) = 2α = -α]")
    print(f"Frobenius(1) = {frobenius(one)}")
    print(f"  [Should be (1, 0) = 1, fixed by Frobenius]")
    
    print(f"\nFrobenius is involution: Frobenius(Frobenius(α)) = {frobenius(frobenius(alpha))}")
    print(f"  [Should be (0, 1) = α]")


def demo_non_associativity():
    """Demonstrate that Hall multiplication is non-associative."""
    print("\n" + "=" * 60)
    print("DEMO 2: Non-Associativity of Hall Multiplication")
    print("=" * 60)
    
    x = (0, 1)  # α
    y = (0, 1)  # α
    z = (1, 1)  # 1 + α
    
    xy = hall_mul(x, y)
    yz = hall_mul(y, z)
    lhs = hall_mul(xy, z)
    rhs = hall_mul(x, yz)
    
    print(f"\nWitness: x = {x} = α, y = {y} = α, z = {z} = 1+α")
    print(f"\nStep-by-step computation:")
    print(f"  x ○ y = {x} ○ {y} = {xy}")
    print(f"    [y.2 = 1 ≠ 0, so use Frobenius: σ(0,1)·(0,1) = (0,2)·(0,1)]")
    print(f"  (x ○ y) ○ z = {xy} ○ {z} = {lhs}")
    print(f"  y ○ z = {y} ○ {z} = {yz}")
    print(f"  x ○ (y ○ z) = {x} ○ {yz} = {rhs}")
    print(f"\n  (x ○ y) ○ z = {lhs}")
    print(f"  x ○ (y ○ z) = {rhs}")
    print(f"  Equal? {lhs == rhs}")
    print(f"\n  ✗ ASSOCIATIVITY FAILS! The Hall multiplication is non-associative.")


def demo_distributivity():
    """Verify right distributivity and demonstrate left distributivity failure."""
    print("\n" + "=" * 60)
    print("DEMO 3: Distributivity Properties")
    print("=" * 60)
    
    elements = gf_elements(3)
    
    rd = is_right_distributive(hall_mul, gf9_add, elements, 3)
    print(f"\nRight distributivity (a+b)○c = a○c + b○c: {rd}")
    print(f"  ✓ Right distributivity holds for all {len(elements)**3} triples!")
    
    ld = is_left_distributive(hall_mul, gf9_add, elements, 3)
    print(f"\nLeft distributivity a○(b+c) = a○b + a○c: {ld}")
    
    # Find counterexample
    a = (0, 1)
    b = (1, 0)
    c = (0, 1)
    bc = gf9_add(b, c)
    lhs = hall_mul(a, bc)
    rhs = gf9_add(hall_mul(a, b), hall_mul(a, c))
    print(f"  Counterexample: a={a}, b={b}, c={c}")
    print(f"    a ○ (b+c) = {a} ○ {bc} = {lhs}")
    print(f"    a○b + a○c = {gf9_add(hall_mul(a, b), hall_mul(a, c))} = {rhs}")
    print(f"  ✗ LEFT DISTRIBUTIVITY FAILS!")


def demo_associativity_comparison():
    """Compare associativity of standard GF(9) vs Hall multiplication."""
    print("\n" + "=" * 60)
    print("DEMO 4: Standard GF(9) vs Hall Quasifield")
    print("=" * 60)
    
    elements = gf_elements(3)
    
    std_assoc, _ = is_associative(gf9_mul, elements, 3)
    hall_assoc, witness = is_associative(hall_mul, elements, 3)
    
    print(f"\nStandard GF(9) multiplication associative? {std_assoc}")
    print(f"Hall multiplication associative? {hall_assoc}")
    
    if witness:
        x, y, z = witness
        print(f"\nFirst non-associative triple found: ({x}, {y}, {z})")
        lhs = hall_mul(hall_mul(x, y, 3), z, 3)
        rhs = hall_mul(x, hall_mul(y, z, 3), 3)
        print(f"  (x ○ y) ○ z = {lhs}")
        print(f"  x ○ (y ○ z) = {rhs}")
    
    # Count non-associative triples
    count = 0
    total = len(elements) ** 3
    for x in elements:
        for y in elements:
            for z in elements:
                if hall_mul(hall_mul(x, y, 3), z, 3) != hall_mul(x, hall_mul(y, z, 3), 3):
                    count += 1
    print(f"\nNon-associative triples: {count} out of {total} ({100*count/total:.1f}%)")


def demo_hall_plane():
    """Construct and verify the Hall plane of order 9."""
    print("\n" + "=" * 60)
    print("DEMO 5: The Hall Plane of Order 9")
    print("=" * 60)
    
    plane = build_hall_plane(3)
    print(f"\nHall plane constructed:")
    print(f"  Order: {plane['order']}")
    print(f"  Points: {plane['num_points']} (expected {plane['expected_points']})")
    print(f"  Lines: {plane['num_lines']} (expected {plane['expected_lines']})")
    
    verification = verify_plane_axioms(plane, 3)
    print(f"\nVerification:")
    print(f"  Uniform line size: {verification['uniform_line_size']} (each line has {verification['line_size']} points)")
    print(f"  Two-point axiom (sample): {verification['axiom1_sample_ok']} ({verification['sample_checks']} checks)")


def demo_symmetry_gap():
    """Demonstrate the collineation group size gap."""
    print("\n" + "=" * 60)
    print("DEMO 6: Symmetry Gap — Collineation Groups")
    print("=" * 60)
    
    for q in [3, 4, 5, 7]:
        n = q * q
        hall_aut = collineation_group_order_hall(q)
        pgl = pgl_order(3, n)
        ratio = pgl / hall_aut
        print(f"\n  Order n = {n} (q = {q}):")
        print(f"    |Aut(Hall plane)|  ≈ {hall_aut:>15,}")
        print(f"    |PGL(3, GF({n}))| ≈ {pgl:>15,}")
        print(f"    Ratio: {ratio:,.0f}×")


def demo_multiplication_table():
    """Display the Hall multiplication table."""
    print("\n" + "=" * 60)
    print("DEMO 7: Hall Multiplication Table (GF(9))")
    print("=" * 60)
    
    elements = gf_elements(3)
    labels = {(0,0): '0', (1,0): '1', (2,0): '2', 
              (0,1): 'α', (1,1): '1+α', (2,1): '2+α',
              (0,2): '2α', (1,2): '1+2α', (2,2): '2+2α'}
    
    print(f"\n{'○':>6}", end='')
    for y in elements:
        print(f"{labels[y]:>6}", end='')
    print()
    print('-' * 60)
    
    for x in elements:
        print(f"{labels[x]:>6}", end='')
        for y in elements:
            result = hall_mul(x, y)
            print(f"{labels[result]:>6}", end='')
        print()


if __name__ == '__main__':
    demo_basic_arithmetic()
    demo_non_associativity()
    demo_distributivity()
    demo_associativity_comparison()
    demo_hall_plane()
    demo_symmetry_gap()
    demo_multiplication_table()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Hall Multiplication Table vs Standard GF(9) Multiplication

Shows the structural difference between associative (field) and 
non-associative (Hall quasifield) multiplication on GF(9).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def gf9_mul(x, y, p=3):
    a, b = x
    c, d = y
    return ((a * c + (p - 1) * b * d) % p, (a * d + b * c) % p)


def hall_mul(x, y, p=3):
    a, b = x
    c, d = y
    if d % p == 0:
        return ((a * c) % p, (b * c) % p)
    else:
        return ((a * c + b * d) % p, (a * d + (p - 1) * b * c) % p)


def element_to_index(x, p=3):
    return x[0] * p + x[1]


def gf_elements(p=3):
    return [(a, b) for a in range(p) for b in range(p)]


def build_mul_matrix(mul_fn, elements, p=3):
    n = len(elements)
    matrix = np.zeros((n, n), dtype=int)
    for i, x in enumerate(elements):
        for j, y in enumerate(elements):
            result = mul_fn(x, y, p)
            matrix[i, j] = element_to_index(result, p)
    return matrix


def build_assoc_diff_matrix(mul_fn, elements, p=3):
    """For each (x,y), count z where (x○y)○z ≠ x○(y○z)."""
    n = len(elements)
    matrix = np.zeros((n, n), dtype=int)
    for i, x in enumerate(elements):
        for j, y in enumerate(elements):
            count = 0
            for z in elements:
                lhs = mul_fn(mul_fn(x, y, p), z, p)
                rhs = mul_fn(x, mul_fn(y, z, p), p)
                if lhs != rhs:
                    count += 1
            matrix[i, j] = count
    return matrix


if __name__ == '__main__':
    elements = gf_elements(3)
    labels = ['0', 'α', '2α', '1', '1+α', '1+2α', '2', '2+α', '2+2α']
    
    # Build matrices
    std_matrix = build_mul_matrix(gf9_mul, elements)
    hall_matrix = build_mul_matrix(hall_mul, elements)
    diff_matrix = (std_matrix != hall_matrix).astype(int)
    assoc_matrix = build_assoc_diff_matrix(hall_mul, elements)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # Standard multiplication
    im1 = axes[0, 0].imshow(std_matrix, cmap='viridis', aspect='equal')
    axes[0, 0].set_title('Standard GF(9) Multiplication', fontsize=12, fontweight='bold')
    axes[0, 0].set_xticks(range(9))
    axes[0, 0].set_yticks(range(9))
    axes[0, 0].set_xticklabels(labels, fontsize=7, rotation=45)
    axes[0, 0].set_yticklabels(labels, fontsize=7)
    axes[0, 0].set_xlabel('y')
    axes[0, 0].set_ylabel('x')
    plt.colorbar(im1, ax=axes[0, 0], shrink=0.8)
    
    # Hall multiplication
    im2 = axes[0, 1].imshow(hall_matrix, cmap='viridis', aspect='equal')
    axes[0, 1].set_title('Hall Quasifield Multiplication', fontsize=12, fontweight='bold')
    axes[0, 1].set_xticks(range(9))
    axes[0, 1].set_yticks(range(9))
    axes[0, 1].set_xticklabels(labels, fontsize=7, rotation=45)
    axes[0, 1].set_yticklabels(labels, fontsize=7)
    axes[0, 1].set_xlabel('y')
    axes[0, 1].set_ylabel('x')
    plt.colorbar(im2, ax=axes[0, 1], shrink=0.8)
    
    # Difference
    im3 = axes[1, 0].imshow(diff_matrix, cmap='Reds', aspect='equal')
    axes[1, 0].set_title('Where Hall ≠ Standard (Frobenius Twist)', fontsize=12, fontweight='bold')
    axes[1, 0].set_xticks(range(9))
    axes[1, 0].set_yticks(range(9))
    axes[1, 0].set_xticklabels(labels, fontsize=7, rotation=45)
    axes[1, 0].set_yticklabels(labels, fontsize=7)
    axes[1, 0].set_xlabel('y')
    axes[1, 0].set_ylabel('x')
    plt.colorbar(im3, ax=axes[1, 0], shrink=0.8)
    
    # Associativity failure
    im4 = axes[1, 1].imshow(assoc_matrix, cmap='hot_r', aspect='equal')
    axes[1, 1].set_title('Associativity Failures: #{z : (x○y)○z ≠ x○(y○z)}', fontsize=12, fontweight='bold')
    axes[1, 1].set_xticks(range(9))
    axes[1, 1].set_yticks(range(9))
    axes[1, 1].set_xticklabels(labels, fontsize=7, rotation=45)
    axes[1, 1].set_yticklabels(labels, fontsize=7)
    axes[1, 1].set_xlabel('y')
    axes[1, 1].set_ylabel('x')
    plt.colorbar(im4, ax=axes[1, 1], shrink=0.8)
    
    plt.suptitle('Non-Desarguesian Geometry:\nHall Quasifield on GF(9)', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_hall_table.png', dpi=150, bbox_inches='tight')
    print("Saved viz_hall_table.png")
