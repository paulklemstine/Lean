#!/usr/bin/env python3
"""
Demo: Quasifield Nucleus Defect Theory

Demonstrates the key concepts from the formalized theory:
1. Hall quasifield construction and multiplication table
2. Nucleus computation
3. Defect calculation
4. Collineation group bounds
5. Knuth orbit structure
"""

import numpy as np
from typing import List, Tuple, Set, Dict


def gf3_add(a: int, b: int) -> int:
    """Addition in GF(3)."""
    return (a + b) % 3


def gf3_mul(a: int, b: int) -> int:
    """Multiplication in GF(3)."""
    return (a * b) % 3


def gf3_neg(a: int) -> int:
    """Negation in GF(3)."""
    return (3 - a) % 3


def gf3_inv(a: int) -> int:
    """Multiplicative inverse in GF(3) (0 has no inverse)."""
    if a == 0:
        raise ValueError("0 has no inverse")
    return a  # In GF(3), 1^(-1) = 1, 2^(-1) = 2


# Hall quasifield of order 9
# Elements are pairs (a, b) in GF(3)^2
# Addition is componentwise
# Multiplication: (a1,b1) * (a2,b2) = (a1*a2 + alpha*b1*b2, a1*b2 + b1*a2)
# where alpha = 2 (non-square in GF(3), since x^2 ∈ {0,1} for x ∈ GF(3))
# But for Hall, we use Frobenius: (a1,b1)*(a2,b2) = (a1*a2 + alpha*b1*b2^p, a1*b2 + b1*a2^p)
# For GF(3), Frobenius is x -> x^3 = x (trivial), so we need a twist.
# Actually the standard Hall construction uses irreducible polynomial.
# Let's use: elements of GF(9) = GF(3)[x]/(x^2 + 1)
# Standard multiplication: (a+bx)(c+dx) = (ac - bd) + (ad + bc)x  [since x^2 = -1 = 2]
# Hall twist: for elements NOT in GF(3), replace one factor with its conjugate
# Hall multiplication: (a,b) * (c,d) = standard if (c,d) ∈ GF(3), else twisted

ALPHA = 2  # non-square in GF(3): -1 ≡ 2 mod 3


def pair_to_idx(a: int, b: int) -> int:
    """Convert (a,b) pair to index 0-8."""
    return a * 3 + b


def idx_to_pair(i: int) -> Tuple[int, int]:
    """Convert index 0-8 to (a,b) pair."""
    return (i // 3, i % 3)


def hall_add(i: int, j: int) -> int:
    """Addition in Hall quasifield."""
    a1, b1 = idx_to_pair(i)
    a2, b2 = idx_to_pair(j)
    return pair_to_idx(gf3_add(a1, a2), gf3_add(b1, b2))


def hall_neg(i: int) -> int:
    """Negation in Hall quasifield."""
    a, b = idx_to_pair(i)
    return pair_to_idx(gf3_neg(a), gf3_neg(b))


def gf9_std_mul(i: int, j: int) -> int:
    """Standard GF(9) multiplication: GF(3)[x]/(x^2+1)."""
    a1, b1 = idx_to_pair(i)
    a2, b2 = idx_to_pair(j)
    # (a1 + b1*x)(a2 + b2*x) = a1*a2 + (a1*b2 + b1*a2)*x + b1*b2*x^2
    # x^2 = -1 = 2 in GF(3)
    c = gf3_add(gf3_mul(a1, a2), gf3_mul(ALPHA, gf3_mul(b1, b2)))
    d = gf3_add(gf3_mul(a1, b2), gf3_mul(b1, a2))
    return pair_to_idx(c, d)


def gf9_conjugate(i: int) -> int:
    """Conjugate in GF(9): (a,b) -> (a, -b)."""
    a, b = idx_to_pair(i)
    return pair_to_idx(a, gf3_neg(b))


def hall_mul(i: int, j: int) -> int:
    """Hall quasifield multiplication.
    If j is in GF(3) (b-component = 0), use standard multiplication.
    Otherwise, use twisted multiplication with conjugate."""
    _, b2 = idx_to_pair(j)
    if b2 == 0:
        return gf9_std_mul(i, j)
    else:
        # Hall twist: multiply i by conjugate of j, then adjust
        # Hall: (a1,b1) * (a2,b2) = (a1*a2 + alpha*b1*b2^q, a1*b2 + b1*a2^q)
        # where q = 3 and x^3 = x in GF(3), so Frobenius is trivial
        # The actual twist uses the OTHER irreducible: swap roots
        j_conj = gf9_conjugate(j)
        return gf9_std_mul(i, j_conj)


def compute_multiplication_table(mul_fn) -> np.ndarray:
    """Compute 9x9 multiplication table."""
    table = np.zeros((9, 9), dtype=int)
    for i in range(9):
        for j in range(9):
            table[i][j] = mul_fn(i, j)
    return table


def check_right_distributivity(mul_fn) -> bool:
    """Check (a+b)*c = a*c + b*c for all a,b,c."""
    for a in range(9):
        for b in range(9):
            for c in range(9):
                lhs = mul_fn(hall_add(a, b), c)
                rhs = hall_add(mul_fn(a, c), mul_fn(b, c))
                if lhs != rhs:
                    return False
    return True


def check_left_distributivity(mul_fn) -> bool:
    """Check a*(b+c) = a*b + a*c for all a,b,c."""
    for a in range(9):
        for b in range(9):
            for c in range(9):
                lhs = mul_fn(a, hall_add(b, c))
                rhs = hall_add(mul_fn(a, b), mul_fn(a, c))
                if lhs != rhs:
                    return False
    return True


def compute_left_nucleus(mul_fn) -> Set[int]:
    """Compute left nucleus: {a | a(bc) = (ab)c for all b,c}."""
    nucleus = set()
    for a in range(9):
        in_nucleus = True
        for b in range(9):
            for c in range(9):
                if mul_fn(a, mul_fn(b, c)) != mul_fn(mul_fn(a, b), c):
                    in_nucleus = False
                    break
            if not in_nucleus:
                break
        if in_nucleus:
            nucleus.add(a)
    return nucleus


def compute_middle_nucleus(mul_fn) -> Set[int]:
    """Compute middle nucleus: {b | a(bc) = (ab)c for all a,c}."""
    nucleus = set()
    for b in range(9):
        in_nucleus = True
        for a in range(9):
            for c in range(9):
                if mul_fn(a, mul_fn(b, c)) != mul_fn(mul_fn(a, b), c):
                    in_nucleus = False
                    break
            if not in_nucleus:
                break
        if in_nucleus:
            nucleus.add(b)
    return nucleus


def compute_right_nucleus(mul_fn) -> Set[int]:
    """Compute right nucleus: {c | a(bc) = (ab)c for all a,b}."""
    nucleus = set()
    for c in range(9):
        in_nucleus = True
        for a in range(9):
            for b in range(9):
                if mul_fn(a, mul_fn(b, c)) != mul_fn(mul_fn(a, b), c):
                    in_nucleus = False
                    break
            if not in_nucleus:
                break
        if in_nucleus:
            nucleus.add(c)
    return nucleus


def compute_defect(total_size: int, nucleus_size: int) -> int:
    """Compute defect: |Q| - |N_l|."""
    return total_size - nucleus_size


def pgl_order(q: int) -> int:
    """Order of PGL(3,q) = q^3 * (q^3 - 1) * (q^2 - 1)."""
    return q**3 * (q**3 - 1) * (q**2 - 1)


def hall_collineation_bound(q: int) -> int:
    """Upper bound on Hall plane collineation group order."""
    return q**2 * (q**2 - 1) * q * (q - 1)


def symmetry_ratio(q: int) -> float:
    """Ratio PGL(3,q^2) / Hall collineation bound."""
    return pgl_order(q**2) / hall_collineation_bound(q)


def knuth_orbit_size(nl: int, nm: int, nr: int) -> int:
    """Compute Knuth orbit size from nucleus triple.
    S3 acts by permuting (nl, nm, nr).
    Orbit size = 6 / |stabilizer|."""
    triple = (nl, nm, nr)
    orbit = set()
    perms = [
        (nl, nm, nr), (nl, nr, nm), (nm, nl, nr),
        (nm, nr, nl), (nr, nl, nm), (nr, nm, nl)
    ]
    for p in perms:
        orbit.add(p)
    return len(orbit)


def main():
    print("=" * 70)
    print("QUASIFIELD NUCLEUS DEFECT THEORY — DEMONSTRATION")
    print("=" * 70)

    # 1. Standard GF(9) (Desarguesian case)
    print("\n1. STANDARD GF(9) — FIELD (DESARGUESIAN)")
    print("-" * 50)

    nl_gf9 = compute_left_nucleus(gf9_std_mul)
    nm_gf9 = compute_middle_nucleus(gf9_std_mul)
    nr_gf9 = compute_right_nucleus(gf9_std_mul)

    print(f"   Left nucleus size:   |N_l| = {len(nl_gf9)}")
    print(f"   Middle nucleus size: |N_m| = {len(nm_gf9)}")
    print(f"   Right nucleus size:  |N_r| = {len(nr_gf9)}")
    print(f"   Defect: δ = 9 - {len(nl_gf9)} = {compute_defect(9, len(nl_gf9))}")
    print(f"   Right distributive: {check_right_distributivity(gf9_std_mul)}")
    print(f"   Left distributive:  {check_left_distributivity(gf9_std_mul)}")

    # 2. Hall quasifield of order 9
    print("\n2. HALL QUASIFIELD H₉ — NON-DESARGUESIAN")
    print("-" * 50)

    nl_hall = compute_left_nucleus(hall_mul)
    nm_hall = compute_middle_nucleus(hall_mul)
    nr_hall = compute_right_nucleus(hall_mul)

    print(f"   Left nucleus size:   |N_l| = {len(nl_hall)}")
    print(f"   Middle nucleus size: |N_m| = {len(nm_hall)}")
    print(f"   Right nucleus size:  |N_r| = {len(nr_hall)}")
    print(f"   Left nucleus elements: {sorted(nl_hall)}")
    print(f"   Defect: δ = 9 - {len(nl_hall)} = {compute_defect(9, len(nl_hall))}")
    print(f"   Right distributive: {check_right_distributivity(hall_mul)}")
    print(f"   Left distributive:  {check_left_distributivity(hall_mul)}")

    # Find associativity failure witness
    print("\n   Associativity failures:")
    count = 0
    for a in range(9):
        for b in range(9):
            for c in range(9):
                lhs = hall_mul(a, hall_mul(b, c))
                rhs = hall_mul(hall_mul(a, b), c)
                if lhs != rhs:
                    if count < 3:
                        pa, pb, pc = idx_to_pair(a), idx_to_pair(b), idx_to_pair(c)
                        print(f"   a={pa}, b={pb}, c={pc}: "
                              f"a(bc)={idx_to_pair(lhs)} ≠ (ab)c={idx_to_pair(rhs)}")
                    count += 1
    print(f"   Total associativity failures: {count} / {9**3}")

    # 3. Defect-Symmetry comparison
    print("\n3. DEFECT-SYMMETRY DUALITY")
    print("-" * 50)
    for q in [3, 4, 5, 7, 8]:
        pgl = pgl_order(q**2)
        hall_bound = hall_collineation_bound(q)
        ratio = pgl / hall_bound if hall_bound > 0 else float('inf')
        defect = q**2 - q
        print(f"   q={q}: PGL(3,{q**2})={pgl:>15,}, "
              f"Hall bound={hall_bound:>10,}, "
              f"ratio≈{ratio:>8.0f}, "
              f"defect={defect}")

    # 4. Knuth orbits
    print("\n4. KNUTH S₃ ORBIT STRUCTURE")
    print("-" * 50)
    examples = [
        ("Field GF(q)", 9, 9, 9),
        ("Hall (q=3)", 3, 3, 3),
        ("Generic semifield", 2, 4, 8),
        ("Symmetric semifield", 4, 4, 8),
    ]
    for name, nl, nm, nr in examples:
        orbit = knuth_orbit_size(nl, nm, nr)
        print(f"   {name:30s}: nuclei=({nl},{nm},{nr}), orbit size={orbit}")

    # 5. Falsified conjecture
    print("\n5. FALSIFIED CONJECTURE: δ² < q³")
    print("-" * 50)
    for q in range(2, 10):
        defect = q * (q - 1)
        d_sq = defect ** 2
        q_cubed = q ** 3
        status = "✓ holds" if d_sq < q_cubed else "✗ FAILS"
        print(f"   q={q}: δ={defect}, δ²={d_sq}, q³={q_cubed} → {status}")

    # 6. Prime order theorem
    print("\n6. PRIME ORDER THEOREM: PRIMES FORCE FIELDS")
    print("-" * 50)
    for p in [2, 3, 5, 7, 11, 13]:
        divisors = [d for d in range(2, p) if p % d == 0]
        print(f"   p={p:3d}: proper divisors ≥ 2: {divisors if divisors else 'none'} "
              f"→ nucleus must be GF({p})")

    print("\n" + "=" * 70)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Quasifield Defect Theory

Generates plots showing:
1. Defect growth for Hall quasifields
2. Symmetry loss ratio vs field order
3. Nucleus chain structure
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def hall_defect(q):
    return q * (q - 1)

def pgl_order(q):
    return q**3 * (q**3 - 1) * (q**2 - 1)

def hall_collineation(q):
    return q**2 * (q**2 - 1) * q * (q - 1)

def symmetry_ratio(q):
    return pgl_order(q**2) / max(1, hall_collineation(q))


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Defect growth
qs = np.arange(2, 20)
defects = [hall_defect(q) for q in qs]
orders = [q**2 for q in qs]

ax1 = axes[0, 0]
ax1.plot(qs, defects, 'bo-', label='Defect δ = q(q-1)', markersize=4)
ax1.plot(qs, orders, 'r^-', label='Order q²', markersize=4)
ax1.plot(qs, qs, 'gs-', label='Nucleus |N_ℓ| = q', markersize=4)
ax1.set_xlabel('Base field order q')
ax1.set_ylabel('Size')
ax1.set_title('Hall Quasifield: Defect vs Order')
ax1.legend()
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Plot 2: Symmetry loss
ratios = [symmetry_ratio(q) for q in qs]
q4 = [q**4 for q in qs]

ax2 = axes[0, 1]
ax2.plot(qs, ratios, 'ro-', label='PGL/Hall ratio', markersize=4)
ax2.plot(qs, q4, 'b--', label='q⁴ (theoretical)', markersize=4)
ax2.set_xlabel('Base field order q')
ax2.set_ylabel('Symmetry ratio')
ax2.set_title('Symmetry Loss: Desarguesian vs Hall')
ax2.legend()
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

# Plot 3: Falsified conjecture
defect_sq = [hall_defect(q)**2 for q in qs]
q_cubed = [q**3 for q in qs]

ax3 = axes[1, 0]
ax3.plot(qs, defect_sq, 'ro-', label='δ²', markersize=4)
ax3.plot(qs, q_cubed, 'b^-', label='q³', markersize=4)
ax3.axvline(x=3, color='gray', linestyle=':', alpha=0.7, label='First failure (q=3)')
ax3.fill_between(qs, defect_sq, q_cubed,
                  where=[d > c for d, c in zip(defect_sq, q_cubed)],
                  alpha=0.2, color='red', label='Conjecture fails')
ax3.set_xlabel('Base field order q')
ax3.set_ylabel('Value')
ax3.set_title('Falsified Conjecture: δ² vs q³')
ax3.legend(fontsize=8)
ax3.set_yscale('log')
ax3.grid(True, alpha=0.3)

# Plot 4: Nucleus proportions
ax4 = axes[1, 1]
nuc_fractions = [q / q**2 for q in qs]
defect_fractions = [hall_defect(q) / q**2 for q in qs]

ax4.bar(qs - 0.2, nuc_fractions, 0.4, label='Nucleus fraction |N_ℓ|/|Q|', color='green', alpha=0.7)
ax4.bar(qs + 0.2, defect_fractions, 0.4, label='Defect fraction δ/|Q|', color='red', alpha=0.7)
ax4.set_xlabel('Base field order q')
ax4.set_ylabel('Fraction of total')
ax4.set_title('Nucleus vs Defect as Fraction of |Q|')
ax4.legend()
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('defect_theory_plots.png', dpi=150, bbox_inches='tight')
print("Saved: defect_theory_plots.png")


#!/usr/bin/env python3
"""
Visualization: Knuth Orbit Structure for Semifields

Shows how the S₃ action on semifields permutes nucleus triples.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations


def knuth_orbit(nl, nm, nr):
    orbit = set()
    for p in permutations((nl, nm, nr)):
        orbit.add(p)
    return orbit


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Orbit sizes for various nucleus triples
examples = {
    'Field (q,q,q)': [(q, q, q) for q in range(2, 10)],
    'Hall (q,q,q)': [(q, q, q) for q in range(2, 10)],
    'Generic (a,b,c)': [(2, 3, 5), (2, 4, 8), (3, 5, 7), (2, 3, 7), (4, 8, 16)],
    'Symmetric (a,a,b)': [(2, 2, 4), (3, 3, 9), (4, 4, 16), (2, 2, 8)],
}

ax1 = axes[0]
orbit_sizes = {1: 0, 2: 0, 3: 0, 6: 0}

# Generate many random triples
np.random.seed(42)
for _ in range(1000):
    nl, nm, nr = sorted(np.random.randint(2, 20, 3))
    size = len(knuth_orbit(nl, nm, nr))
    orbit_sizes[size] = orbit_sizes.get(size, 0) + 1

sizes = sorted(orbit_sizes.keys())
counts = [orbit_sizes[s] for s in sizes]

bars = ax1.bar(sizes, counts, color=['green', 'blue', 'orange', 'red'], alpha=0.7, width=0.6)
ax1.set_xlabel('Orbit Size')
ax1.set_ylabel('Count (out of 1000 random triples)')
ax1.set_title('Distribution of Knuth Orbit Sizes')
ax1.set_xticks(sizes)
for bar, count in zip(bars, counts):
    ax1.text(bar.get_x() + bar.get_width()/2., bar.get_height(),
             f'{count}', ha='center', va='bottom')

# Plot 2: Specific orbit visualization
ax2 = axes[1]
specific_triples = [
    ((3, 3, 3), 'Field GF(9)'),
    ((2, 4, 8), 'Generic'),
    ((3, 3, 9), 'Symmetric'),
    ((5, 5, 5), 'Field GF(25)'),
    ((2, 2, 2), 'Field GF(4)'),
    ((3, 9, 27), 'Tower'),
]

y_pos = np.arange(len(specific_triples))
orbit_sizes_specific = [len(knuth_orbit(*t[0])) for t in specific_triples]
colors = ['green' if s == 1 else 'blue' if s == 3 else 'red' for s in orbit_sizes_specific]

ax2.barh(y_pos, orbit_sizes_specific, color=colors, alpha=0.7)
ax2.set_yticks(y_pos)
ax2.set_yticklabels([f'{t[1]}\n{t[0]}' for t in specific_triples])
ax2.set_xlabel('Knuth Orbit Size')
ax2.set_title('Knuth Orbit Size for Specific Semifields')
ax2.set_xlim(0, 7)

for i, (size, triple) in enumerate(zip(orbit_sizes_specific, specific_triples)):
    ax2.text(size + 0.1, i, f'|orbit| = {size}', va='center')

plt.tight_layout()
plt.savefig('knuth_orbits.png', dpi=150, bbox_inches='tight')
print("Saved: knuth_orbits.png")
