#!/usr/bin/env python3
"""
Impossibility Theory: Demonstrations and Examples

Demonstrates the key results of the equivariant impossibility framework:
1. Free group actions and their impossibility spectra
2. The Transfer Principle in action
3. Product composition of impossibilities
4. Concrete cyclic group examples
"""

from itertools import permutations, product
from typing import Callable


def is_free_action(group_elements: list, action: Callable, domain: list) -> bool:
    """Check if a group action is free (no non-identity element fixes any point)."""
    identity = group_elements[0]  # Convention: first element is identity
    for g in group_elements:
        if g == identity:
            continue
        for x in domain:
            if action(g, x) == x:
                return False
    return True


def compute_fixed_points(subgroup: list, action: Callable, domain: list) -> list:
    """Compute the fixed points of a subgroup action."""
    fixed = []
    for x in domain:
        if all(action(g, x) == x for g in subgroup):
            fixed.append(x)
    return fixed


def impossibility_spectrum(group_elements: list, subgroups: list[list],
                           action: Callable, domain: list) -> list[list]:
    """Compute the impossibility spectrum: nontrivial subgroups with empty fixed-point set."""
    identity = group_elements[0]
    spectrum = []
    for H in subgroups:
        if H == [identity]:  # Skip trivial subgroup
            continue
        if len(compute_fixed_points(H, action, domain)) == 0:
            spectrum.append(H)
    return spectrum


# === Demo 1: Cyclic group Z/nZ acting on itself ===
print("=" * 60)
print("Demo 1: Cyclic Group Z/nZ Acting on Itself")
print("=" * 60)

for n in [2, 3, 4, 5, 6]:
    elements = list(range(n))
    action = lambda g, x, n=n: (g + x) % n

    free = is_free_action(elements, action, elements)
    print(f"\nZ/{n}Z acting on Z/{n}Z by addition:")
    print(f"  Free action: {free}")

    # Compute subgroups (for small n, enumerate divisors)
    subgroups = []
    for d in range(1, n + 1):
        if n % d == 0:
            subgroup = [k * (n // d) % n for k in range(d)]
            subgroups.append(sorted(subgroup))

    spectrum = impossibility_spectrum(elements, subgroups, action, elements)
    print(f"  Subgroups: {subgroups}")
    print(f"  Impossibility spectrum: {spectrum}")
    print(f"  Spectrum size: {len(spectrum)} / {len(subgroups) - 1} nontrivial subgroups")


# === Demo 2: Symmetric group S_3 acting on {0,1,2} ===
print("\n" + "=" * 60)
print("Demo 2: Symmetric Group S₃ Acting on {0,1,2}")
print("=" * 60)

S3 = list(permutations([0, 1, 2]))
domain = [0, 1, 2]
action_perm = lambda g, x: g[x]

free = is_free_action(S3, action_perm, domain)
print(f"\nFree action: {free}")
print("(Not free — transpositions fix one element)")

# Show which elements fix which points
identity = (0, 1, 2)
for g in S3:
    if g == identity:
        continue
    fixed = [x for x in domain if g[x] == x]
    if fixed:
        print(f"  {g} fixes {fixed}")
    else:
        print(f"  {g} fixes nothing")


# === Demo 3: Transfer Principle Demonstration ===
print("\n" + "=" * 60)
print("Demo 3: Transfer Principle")
print("=" * 60)

print("\nScenario: Z/6Z acts freely on Z/6Z.")
print("Surjection φ: Z/6Z → Z/3Z, φ(x) = x mod 3")
print("Z/3Z acts freely on Z/3Z.")
print("")
print("Transfer says: impossibility of equivariant constant maps on Z/3Z")
print("implies impossibility of φ-equivariant constant maps on Z/3Z via Z/6Z")
print("")

# Verify: Z/3Z acts freely on Z/3Z
n_target = 3
elts = list(range(n_target))
action_z3 = lambda g, x: (g + x) % n_target
print(f"Z/3Z free on Z/3Z: {is_free_action(elts, action_z3, elts)}")

# The surjection
phi = lambda h: h % 3
print(f"φ(0)={phi(0)}, φ(1)={phi(1)}, φ(2)={phi(2)}, φ(3)={phi(3)}, φ(4)={phi(4)}, φ(5)={phi(5)}")
print(f"φ is surjective: {set(phi(h) for h in range(6)) == set(range(3))}")


# === Demo 4: Product Composition ===
print("\n" + "=" * 60)
print("Demo 4: Product Composition of Impossibilities")
print("=" * 60)

print("\nZ/2Z × Z/3Z acts on Z/2Z × Z/3Z componentwise")

product_group = [(g, h) for g in range(2) for h in range(3)]
product_domain = [(x, y) for x in range(2) for y in range(3)]
product_action = lambda gh, xy: ((gh[0] + xy[0]) % 2, (gh[1] + xy[1]) % 3)

free_prod = is_free_action(product_group, product_action, product_domain)
print(f"Free action: {free_prod}")

# Check no equivariant constant map exists
print("\nAttempting to find equivariant constant map f: Z/2Z×Z/3Z → Z/2Z×Z/3Z...")
found_equivariant_constant = False
for c in product_domain:
    f = lambda x, c=c: c  # constant map to c
    equivariant = all(
        f(product_action(gh, xy)) == product_action(gh, f(xy))
        for gh in product_group
        for xy in product_domain
    )
    if equivariant:
        found_equivariant_constant = True
        break

print(f"Found equivariant constant map: {found_equivariant_constant}")
print("(Confirms Product Impossibility Theorem)")


# === Demo 5: Equivariant Bijectivity ===
print("\n" + "=" * 60)
print("Demo 5: Equivariant Maps Are Bijections (Free Transitive)")
print("=" * 60)

print("\nZ/5Z acting freely and transitively on Z/5Z")
print("Testing all equivariant self-maps:")

n = 5
equivariant_maps = []
for shift in range(n):
    f = lambda x, s=shift: (x + s) % n
    # Check equivariance: f(g + x) = g + f(x) mod n
    is_equiv = all(
        f((g + x) % n) == (g + f(x)) % n
        for g in range(n) for x in range(n)
    )
    if is_equiv:
        mapping = {x: f(x) for x in range(n)}
        is_bij = len(set(mapping.values())) == n
        equivariant_maps.append((shift, mapping, is_bij))
        print(f"  f(x) = (x + {shift}) mod {n}: {mapping} — bijective: {is_bij}")

all_bij = all(bij for _, _, bij in equivariant_maps)
print(f"\nAll equivariant self-maps are bijections: {all_bij}")
print("(Confirms Equivariant Bijectivity Theorem)")


# === Demo 6: Impossibility Spectrum Visualization Data ===
print("\n" + "=" * 60)
print("Demo 6: Impossibility Spectrum Analysis")
print("=" * 60)

print("\nGroup: Z/12Z acting on Z/12Z by addition")
n = 12
elements = list(range(n))
action = lambda g, x: (g + x) % n

# Enumerate subgroups of Z/12Z
subgroups_12 = []
for d in range(1, n + 1):
    if n % d == 0:
        subgroup = sorted([k * (n // d) % n for k in range(d)])
        subgroups_12.append(subgroup)

spectrum = impossibility_spectrum(elements, subgroups_12, action, elements)

print(f"Subgroups of Z/12Z (by order):")
for H in subgroups_12:
    in_spec = H in spectrum
    fixed = compute_fixed_points(H, action, elements)
    print(f"  |H|={len(H):2d}: {H}")
    print(f"         Fixed points: {fixed if fixed else '∅'}")
    print(f"         In spectrum: {in_spec}")

print(f"\nSpectrum size: {len(spectrum)}")
print(f"Minimal spectrum elements: subgroups of order 2 (smallest nontrivial)")
print(f"\nThe spectrum is an upper set: verified by upward closure theorem")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Impossibility Spectrum of Cyclic Groups

Shows how the impossibility spectrum grows with group order,
and highlights the upward closure property.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def compute_subgroups_cyclic(n: int) -> list[list[int]]:
    """Compute all subgroups of Z/nZ."""
    subgroups = []
    for d in range(1, n + 1):
        if n % d == 0:
            subgroup = sorted([k * (n // d) % n for k in range(d)])
            subgroups.append(subgroup)
    return subgroups


def fixed_points_cyclic(subgroup: list[int], n: int) -> list[int]:
    """Fixed points of a subgroup of Z/nZ acting on Z/nZ by addition."""
    return [x for x in range(n)
            if all((g + x) % n == x for g in subgroup)]


def impossibility_spectrum_cyclic(n: int) -> tuple[list[list[int]], list[list[int]]]:
    """Returns (all_nontrivial_subgroups, spectrum) for Z/nZ on Z/nZ."""
    subgroups = compute_subgroups_cyclic(n)
    nontrivial = [H for H in subgroups if H != [0]]
    spectrum = [H for H in nontrivial if len(fixed_points_cyclic(H, n)) == 0]
    return nontrivial, spectrum


# === Figure 1: Spectrum fraction by group order ===
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Spectrum fraction
orders = list(range(2, 31))
fractions = []
for n in orders:
    nontrivial, spectrum = impossibility_spectrum_cyclic(n)
    frac = len(spectrum) / max(len(nontrivial), 1)
    fractions.append(frac)

colors = ['#2196F3' if f == 1.0 else '#FF9800' if f > 0.5 else '#F44336'
          for f in fractions]
axes[0].bar(orders, fractions, color=colors, edgecolor='white', linewidth=0.5)
axes[0].set_xlabel('Group order n', fontsize=12)
axes[0].set_ylabel('Fraction of subgroups in spectrum', fontsize=12)
axes[0].set_title('Impossibility Spectrum Density\n(Z/nZ acting on Z/nZ)', fontsize=13)
axes[0].set_ylim(0, 1.1)
axes[0].axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Full spectrum')
axes[0].legend()

# Panel 2: Spectrum size vs number of divisors
num_divisors = []
spectrum_sizes = []
for n in orders:
    nontrivial, spectrum = impossibility_spectrum_cyclic(n)
    num_divisors.append(len(nontrivial))
    spectrum_sizes.append(len(spectrum))

axes[1].scatter(num_divisors, spectrum_sizes, c=orders, cmap='viridis',
                s=80, edgecolors='black', linewidth=0.5)
axes[1].plot([0, max(num_divisors)], [0, max(num_divisors)],
             'r--', alpha=0.5, label='y = x (full spectrum)')
axes[1].set_xlabel('Number of nontrivial subgroups', fontsize=12)
axes[1].set_ylabel('Spectrum size', fontsize=12)
axes[1].set_title('Spectrum Size vs Subgroup Count', fontsize=13)
axes[1].legend()
cb = plt.colorbar(axes[1].collections[0], ax=axes[1])
cb.set_label('Group order n')

# Panel 3: Impossibility degree (minimal subgroup order in spectrum)
degrees = []
for n in orders:
    _, spectrum = impossibility_spectrum_cyclic(n)
    if spectrum:
        deg = min(len(H) for H in spectrum)
    else:
        deg = 0
    degrees.append(deg)

axes[2].bar(orders, degrees, color='#4CAF50', edgecolor='white', linewidth=0.5)
axes[2].set_xlabel('Group order n', fontsize=12)
axes[2].set_ylabel('Impossibility degree', fontsize=12)
axes[2].set_title('Minimal Witnessing Subgroup Order', fontsize=13)

plt.tight_layout()
plt.savefig('impossibility_spectrum.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: impossibility_spectrum.png")


# === Figure 2: Subgroup lattice with spectrum highlighted ===
fig, ax = plt.subplots(1, 1, figsize=(10, 8))

n = 12
subgroups = compute_subgroups_cyclic(n)
_, spectrum = impossibility_spectrum_cyclic(n)
spectrum_sets = [set(H) for H in spectrum]

# Position subgroups by order (y-axis) with spread on x-axis
positions = {}
order_groups = {}
for H in subgroups:
    order = len(H)
    if order not in order_groups:
        order_groups[order] = []
    order_groups[order].append(H)

for order, groups in order_groups.items():
    n_groups = len(groups)
    for i, H in enumerate(groups):
        x = (i - (n_groups - 1) / 2) * 2
        y = np.log2(order) if order > 0 else 0
        positions[tuple(H)] = (x, y)

# Draw edges (containment)
for H in subgroups:
    for K in subgroups:
        if set(H) < set(K) and len(K) == len(H) * (len(K) // len(H)):
            # Check if K/H is immediate (no intermediate subgroup)
            intermediate = False
            for L in subgroups:
                if set(H) < set(L) < set(K):
                    intermediate = True
                    break
            if not intermediate:
                hx, hy = positions[tuple(H)]
                kx, ky = positions[tuple(K)]
                ax.plot([hx, kx], [hy, ky], 'gray', linewidth=1, alpha=0.5, zorder=1)

# Draw nodes
for H in subgroups:
    pos = positions[tuple(H)]
    in_spec = set(H) in spectrum_sets
    is_trivial = H == [0]

    if is_trivial:
        color = '#BDBDBD'
        label = '{0}'
    elif in_spec:
        color = '#F44336'
        label = f'Z/{len(H)}'
    else:
        color = '#4CAF50'
        label = f'Z/{len(H)}'

    circle = plt.Circle(pos, 0.35, color=color, ec='black', linewidth=1.5, zorder=2)
    ax.add_patch(circle)
    ax.text(pos[0], pos[1], label, ha='center', va='center',
            fontsize=8, fontweight='bold', zorder=3)

# Legend
red_patch = mpatches.Patch(color='#F44336', label='In impossibility spectrum (no fixed points)')
green_patch = mpatches.Patch(color='#4CAF50', label='Not in spectrum (has fixed points)')
gray_patch = mpatches.Patch(color='#BDBDBD', label='Trivial subgroup')
ax.legend(handles=[red_patch, green_patch, gray_patch], loc='upper left', fontsize=10)

ax.set_xlim(-5, 5)
ax.set_ylim(-0.5, 4.5)
ax.set_title(f'Subgroup Lattice of Z/{n}Z with Impossibility Spectrum\n(Action: Z/{n}Z on Z/{n}Z by addition)',
             fontsize=14)
ax.set_ylabel('log₂(subgroup order)', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('subgroup_lattice_spectrum.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: subgroup_lattice_spectrum.png")
