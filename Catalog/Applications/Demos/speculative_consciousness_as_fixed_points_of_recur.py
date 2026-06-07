#!/usr/bin/env python3
"""
Self-Referential Types as Fixed Points: Numerical Demonstrations

Demonstrates the core mathematical results:
1. Reflection hierarchy convergence
2. Diagonal construction and Russell's paradox
3. Fixed point structure of inflationary operators
"""

import math
from typing import Callable, Set, FrozenSet


def reflection_hierarchy(phi: Callable[[float], float], levels: int = 20) -> list[float]:
    """Compute the reflection hierarchy: level(0) = 0, level(n+1) = phi(level(n))."""
    hierarchy = [0.0]
    for _ in range(levels):
        hierarchy.append(phi(hierarchy[-1]))
    return hierarchy


def find_fixed_points(phi: Callable[[float], float],
                      search_range: tuple[float, float] = (0, 10),
                      resolution: int = 10000,
                      tol: float = 1e-8) -> list[float]:
    """Find approximate fixed points of phi in the given range."""
    lo, hi = search_range
    fixed_pts = []
    for i in range(resolution + 1):
        x = lo + (hi - lo) * i / resolution
        if abs(phi(x) - x) < tol:
            if not fixed_pts or abs(x - fixed_pts[-1]) > tol * 100:
                fixed_pts.append(x)
    return fixed_pts


def diagonal_construction(extension: dict[int, set[int]], universe: set[int]) -> set[int]:
    """Construct the diagonal set: {a | a not in extension(a)}."""
    return {a for a in universe if a not in extension.get(a, set())}


def codiagonal_construction(extension: dict[int, set[int]], universe: set[int]) -> set[int]:
    """Construct the codiagonal set: {a | a in extension(a)}."""
    return {a for a in universe if a in extension.get(a, set())}


# ============================================================
# Demo 1: Reflection Hierarchy for sqrt(x + 1)
# ============================================================
print("=" * 60)
print("DEMO 1: Reflection Hierarchy")
print("Operator: Phi(x) = sqrt(x + 1)")
print("This is inflationary: x <= sqrt(x + 1) for x in [0, golden ratio]")
print("=" * 60)

phi_sqrt = lambda x: math.sqrt(x + 1)
hierarchy = reflection_hierarchy(phi_sqrt, levels=30)

# The golden ratio is the fixed point: phi^2 = phi + 1
golden = (1 + math.sqrt(5)) / 2
print(f"\nGolden ratio (theoretical fixed point): {golden:.10f}")
print(f"\nReflection hierarchy convergence:")
for i, val in enumerate(hierarchy):
    gap = abs(val - golden)
    marker = " <-- FIXED POINT!" if gap < 1e-10 else ""
    print(f"  level({i:2d}) = {val:.10f}  (gap to lfp: {gap:.2e}){marker}")
    if gap < 1e-14:
        print(f"  ... converged at level {i}")
        break

# Verify monotonicity (Theorem 9)
is_monotone = all(hierarchy[i] <= hierarchy[i+1] + 1e-15 for i in range(len(hierarchy)-1))
print(f"\nMonotonicity verified (Theorem 9): {is_monotone}")

# Verify bounded by lfp (Theorem 10)
is_bounded = all(val <= golden + 1e-10 for val in hierarchy)
print(f"Bounded by lfp (Theorem 10): {is_bounded}")


# ============================================================
# Demo 2: Diagonal Construction
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Diagonal Undecidability")
print("Type universe on {0, 1, 2, 3, 4}")
print("=" * 60)

universe = {0, 1, 2, 3, 4}

# Define a type universe: each element codes a subset
extension = {
    0: {1, 2},      # Type 0 contains elements 1 and 2
    1: {0, 1, 3},   # Type 1 contains elements 0, 1, and 3
    2: {2, 4},       # Type 2 contains elements 2 and 4
    3: {0, 3, 4},    # Type 3 contains elements 0, 3, and 4
    4: {1, 2, 3},    # Type 4 contains elements 1, 2, and 3
}

diag = diagonal_construction(extension, universe)
codiag = codiagonal_construction(extension, universe)

print(f"\nExtension map:")
for k, v in sorted(extension.items()):
    self_member = "✓" if k in v else "✗"
    print(f"  ext({k}) = {sorted(v)}  (self-member: {self_member})")

print(f"\nDiagonal (not self-members): {sorted(diag)}")
print(f"Codiagonal (self-members): {sorted(codiag)}")

# Verify partition (Theorem 17)
print(f"\nPartition check (Theorem 17):")
print(f"  diag ∪ codiag = universe? {diag | codiag == universe}")
print(f"  diag ∩ codiag = ∅?        {len(diag & codiag) == 0}")

# Verify diagonal is not representable (Theorem 6)
for code in universe:
    if extension[code] == diag:
        print(f"\n  ERROR: diagonal is represented by {code}!")
        break
else:
    print(f"\n  Diagonal {sorted(diag)} is NOT representable (Theorem 6) ✓")

# Verify no surjective coding (Theorem 8)
all_extensions = set(frozenset(v) for v in extension.values())
print(f"\n  Number of codes: {len(extension)}")
print(f"  Number of distinct extensions: {len(all_extensions)}")
print(f"  Number of subsets of universe: {2**len(universe)}")
print(f"  Surjective? {len(all_extensions) >= 2**len(universe)} — impossible by Theorem 8")


# ============================================================
# Demo 3: Gödelian Gap and Density
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Gödelian Gap")
print("Operator: Phi(x) = (x + 2) / (x + 1) on [0, ∞)")
print("=" * 60)

# Phi(x) = (x + 2)/(x + 1) has fixed point at x = 1 (the golden ratio relative)
phi_rational = lambda x: (x + 2) / (x + 1)

fps = find_fixed_points(phi_rational, (0, 10), resolution=100000, tol=1e-9)
print(f"\nFixed points found: {fps}")
print(f"Theoretical fixed point: x = 1 (since (1+2)/(1+1) = 1.5 ≠ 1)")

# Actually solve: x = (x+2)/(x+1) => x(x+1) = x+2 => x^2 = 2 => x = sqrt(2)
sqrt2 = math.sqrt(2)
print(f"Corrected: x² + x = x + 2 => x² = 2 => x = √2 ≈ {sqrt2:.10f}")
fps_correct = find_fixed_points(phi_rational, (0, 5), resolution=100000, tol=1e-6)
print(f"Fixed points (broader tolerance): {[f'{x:.6f}' for x in fps_correct]}")

hierarchy_r = reflection_hierarchy(phi_rational, levels=50)
print(f"\nHierarchy convergence to √2:")
for i in [0, 1, 2, 3, 5, 10, 20, 50]:
    if i < len(hierarchy_r):
        print(f"  level({i:2d}) = {hierarchy_r[i]:.10f}  (gap: {abs(hierarchy_r[i]-sqrt2):.2e})")


# ============================================================
# Demo 4: Invariant Structure Closure
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Invariant Structure Closure")
print("Carrier = {{∅}, {0}, {0,1}, {0,1,2}} on universe {0,1,2}")
print("=" * 60)

carrier: list[frozenset[int]] = [
    frozenset(),
    frozenset({0}),
    frozenset({0, 1}),
    frozenset({0, 1, 2}),
]

def closure(S: frozenset[int], carrier: list[frozenset[int]]) -> frozenset[int]:
    """Compute closure: intersection of all carrier members containing S."""
    containing = [T for T in carrier if S <= T]
    if not containing:
        return frozenset({0, 1, 2})  # univ
    result = containing[0]
    for T in containing[1:]:
        result = result & T
    return result

print(f"\nClosure operator results:")
all_subsets_small = [frozenset()] + [frozenset({x for x in range(3) if (mask >> x) & 1}) for mask in range(1, 8)]
for S in sorted(all_subsets_small, key=lambda s: (len(s), sorted(s))):
    cl = closure(S, carrier)
    is_fp = cl == S
    marker = " ← FIXED POINT (in carrier)" if is_fp else ""
    s_str = str(set(S)) if S else '∅'
    cl_str = str(set(cl)) if cl else '∅'
    print(f"  cl({s_str:>9}) = {cl_str:<12}{marker}")

# Verify idempotence (Theorem 15)
print(f"\nIdempotence check (Theorem 15):")
all_idempotent = True
for S in all_subsets_small:
    cl1 = closure(S, carrier)
    cl2 = closure(cl1, carrier)
    if cl1 != cl2:
        print(f"  FAIL: cl(cl({set(S)})) = {set(cl2)} ≠ cl({set(S)}) = {set(cl1)}")
        all_idempotent = False
print(f"  All idempotent: {all_idempotent} ✓")

# Verify fixed points = carrier (Theorem 16)
computed_fps = {S for S in all_subsets_small if closure(S, carrier) == S}
carrier_set = set(carrier)
print(f"\nFixed point characterization (Theorem 16):")
print(f"  Fixed points: {[set(s) if s else '∅' for s in sorted(computed_fps, key=len)]}")
print(f"  Carrier:      {[set(s) if s else '∅' for s in sorted(carrier_set, key=len)]}")
print(f"  Equal: {computed_fps == carrier_set} ✓")


print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Diagonal Construction and Self-Membership"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Define a type universe
n = 8
universe = list(range(n))

# Random extension map (seeded for reproducibility)
np.random.seed(42)
extension = {}
for a in universe:
    size = np.random.randint(0, n)
    extension[a] = set(np.random.choice(universe, size=size, replace=False))

# Compute membership matrix
matrix = np.zeros((n, n), dtype=int)
for code in universe:
    for elem in universe:
        if elem in extension[code]:
            matrix[code][elem] = 1

# Compute diagonal and codiagonal
diagonal = [a for a in universe if a not in extension[a]]
codiagonal = [a for a in universe if a in extension[a]]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Membership matrix with diagonal highlighted
im = ax1.imshow(matrix, cmap='Blues', aspect='equal', vmin=0, vmax=1)
for i in range(n):
    for j in range(n):
        color = 'white' if matrix[i][j] else 'black'
        if i == j:
            color = 'red' if i in diagonal else 'green'
            ax1.add_patch(plt.Rectangle((j-0.5, i-0.5), 1, 1, fill=False,
                                        edgecolor=color, linewidth=3))
        ax1.text(j, i, str(matrix[i][j]), ha='center', va='center',
                color=color, fontsize=12, fontweight='bold' if i == j else 'normal')

ax1.set_xticks(range(n))
ax1.set_yticks(range(n))
ax1.set_xlabel('Element', fontsize=12)
ax1.set_ylabel('Code', fontsize=12)
ax1.set_title('Type Universe Membership Matrix\n(diagonal entries highlighted)', fontsize=13)

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='none', edgecolor='red', linewidth=2, label=f'Diagonal (not self-member): {diagonal}'),
    Patch(facecolor='none', edgecolor='green', linewidth=2, label=f'Codiagonal (self-member): {codiagonal}'),
]
ax1.legend(handles=legend_elements, loc='upper right', fontsize=9)

# Plot 2: Partition visualization
categories = ['Diagonal\n(not self-referential)' if a in diagonal else 'Codiagonal\n(self-referential)' for a in universe]
colors = ['#ff6b6b' if a in diagonal else '#51cf66' for a in universe]
bars = ax2.bar(range(n), [1]*n, color=colors, edgecolor='black', linewidth=1.5)

for i, bar in enumerate(bars):
    ax2.text(bar.get_x() + bar.get_width()/2., 0.5,
            f'{i}', ha='center', va='center', fontsize=14, fontweight='bold')

ax2.set_xticks([])
ax2.set_yticks([])
ax2.set_title('Self-Membership Partition (Theorem 17)\nEvery element is in exactly one class', fontsize=13)

legend_elements2 = [
    Patch(facecolor='#ff6b6b', label=f'Diagonal: a ∉ ext(a) — {len(diagonal)} elements'),
    Patch(facecolor='#51cf66', label=f'Codiagonal: a ∈ ext(a) — {len(codiagonal)} elements'),
]
ax2.legend(handles=legend_elements2, loc='upper right', fontsize=10)
ax2.set_ylim(0, 1.5)

plt.suptitle('Diagonal Undecidability: The Russell/Cantor Construction', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('diagonal_construction.png', dpi=150, bbox_inches='tight')
print("Saved diagonal_construction.png")


#!/usr/bin/env python3
"""Visualization: Reflection Hierarchy Convergence"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def reflection_hierarchy(phi, levels):
    h = [0.0]
    for _ in range(levels):
        h.append(phi(h[-1]))
    return h

# Three different operators
operators = {
    r'$\Phi(x) = \sqrt{x+1}$': (lambda x: math.sqrt(x + 1), (1 + math.sqrt(5)) / 2),
    r'$\Phi(x) = \frac{x+2}{x+1}$': (lambda x: (x + 2) / (x + 1), math.sqrt(2)),
    r'$\Phi(x) = \cos(x) + x/2$': (lambda x: math.cos(x) + x / 2, None),
}

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for ax, (name, (phi, fp)) in zip(axes, operators.items()):
    hierarchy = reflection_hierarchy(phi, 30)
    if fp is None:
        fp = hierarchy[-1]

    ax.plot(range(len(hierarchy)), hierarchy, 'b.-', markersize=8, linewidth=1.5, label='level(n)')
    ax.axhline(y=fp, color='r', linestyle='--', linewidth=2, label=f'lfp ≈ {fp:.4f}')
    ax.fill_between(range(len(hierarchy)), hierarchy, fp, alpha=0.1, color='blue')
    ax.set_xlabel('Level n', fontsize=12)
    ax.set_ylabel('reflectionLevel(Φ, n)', fontsize=12)
    ax.set_title(name, fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 20)

plt.suptitle('Reflection Hierarchy Convergence to Least Fixed Point', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('hierarchy_convergence.png', dpi=150, bbox_inches='tight')
print("Saved hierarchy_convergence.png")
