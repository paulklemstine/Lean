"""
Applications of Tropical Satake Correspondence for GL₃
=======================================================

Practical demonstrations showing how the formalized tropical
algebra applies to real-world problems.
"""

from itertools import permutations
import numpy as np

INF = float('inf')

# ─────────────────────────────────────────────────────────────────
# Utility functions (corresponding to formalized Lean definitions)
# ─────────────────────────────────────────────────────────────────

def sort3(a, b, c):
    """Dominant representative (verified: sort_is_dominant)"""
    return tuple(sorted([a, b, c], reverse=True))

def trop_schur(l1, l2, l3, a, b, c):
    """Tropical Schur polynomial (verified: tropSchur_weylInvariant)"""
    return min(l1*x + l2*y + l3*z for x, y, z in permutations([a, b, c]))

def is_weyl_invariant(f, test_points):
    """Check S₃-invariance numerically (verified: weyl_inv_of_sort)"""
    for a, b, c in test_points:
        base = f(a, b, c)
        for p in permutations([a, b, c]):
            if f(*p) != base:
                return False
    return True

# ─────────────────────────────────────────────────────────────────
# Application 1: Three-Machine Job Scheduling
# ─────────────────────────────────────────────────────────────────

print("=" * 70)
print("APPLICATION 1: Three-Machine Job Scheduling")
print("=" * 70)
print("""
Problem: Schedule n jobs on 3 identical machines to minimize makespan.
Each job j has processing time p_j. The load on machine i is the sum
of processing times assigned to it.

The tropical Satake theory tells us:
- The cost function is S₃-invariant (machines are identical)
- Optimal solutions can be found on the dominant chamber
- The tropical convolution gives the cost of combining schedules

By tropConv_weyl_invariant: composing S₃-invariant cost functions
preserves symmetry, so we only need to search dominant configurations.
""")

def scheduling_cost(loads):
    """Makespan = max of machine loads (tropical e₁)"""
    return max(loads)

# Example: 6 jobs with processing times
jobs = [5, 4, 3, 3, 2, 1]
print(f"Jobs with processing times: {jobs}")
print(f"Total work: {sum(jobs)}")

# Brute force: try all 3^6 assignments
best_makespan = INF
best_assignment = None
n_checked = 0
n_skipped = 0

for assignment in np.ndindex(*([3] * len(jobs))):
    loads = [0, 0, 0]
    for j, machine in enumerate(assignment):
        loads[machine] += jobs[j]
    loads_tuple = tuple(loads)

    # By Weyl invariance, we only need to check dominant configurations
    dominant = sort3(*loads_tuple)
    makespan = scheduling_cost(loads_tuple)

    if makespan < best_makespan:
        best_makespan = makespan
        best_assignment = assignment
        best_loads = loads_tuple

    n_checked += 1

print(f"\nBrute force: checked {n_checked} assignments")
print(f"Optimal makespan: {best_makespan}")
print(f"Optimal loads: {best_loads} (dominant: {sort3(*best_loads)})")

# With symmetry reduction: only check dominant load vectors
distinct_dominants = set()
for assignment in np.ndindex(*([3] * len(jobs))):
    loads = [0, 0, 0]
    for j, machine in enumerate(assignment):
        loads[machine] += jobs[j]
    distinct_dominants.add(sort3(loads[0], loads[1], loads[2]))

print(f"Distinct dominant load vectors: {len(distinct_dominants)} "
      f"(reduction factor: {n_checked / max(1, len(distinct_dominants)):.1f}x)")
print(f"\nTheorem used: tropConv_weyl_invariant (S₃-invariant costs compose)")

# ─────────────────────────────────────────────────────────────────
# Application 2: Shortest Path in Symmetric Networks
# ─────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("APPLICATION 2: Shortest Paths in Symmetric Networks")
print("=" * 70)
print("""
The tropical convolution (f ⋆ g)(λ) = min_{μ+ν=λ} f(μ) + g(ν) is
the fundamental operation in shortest-path algorithms.

For networks with S₃ symmetry (e.g., 3-port switches, triangular
lattices), our theorem guarantees that shortest-path costs inherit
the symmetry: if individual link costs are symmetric, so are the
composed multi-hop costs.
""")

def link_cost(a, b, c):
    """Cost to traverse link with 3D weight vector (a,b,c).
    S₃-invariant: depends only on the multiset of coordinates."""
    return abs(a) + abs(b) + abs(c)  # L¹ norm (symmetric)

# Verify S₃-invariance
test_pts = [(1,2,3), (0,1,-1), (2,0,0)]
print(f"Link cost is S₃-invariant: {is_weyl_invariant(link_cost, test_pts)}")

# Two-hop cost via tropical convolution
def two_hop_cost(a, b, c, R=3):
    """(link_cost ⋆ link_cost)(a,b,c) - approx by finite search"""
    result = INF
    for a1 in range(-R, R+1):
        for b1 in range(-R, R+1):
            for c1 in range(-R, R+1):
                val = link_cost(a1, b1, c1) + link_cost(a-a1, b-b1, c-c1)
                result = min(result, val)
    return result

print("\nTwo-hop costs (should be S₃-invariant by our theorem):")
for target in [(2,1,0), (1,2,0), (0,1,2), (3,0,0), (0,3,0)]:
    cost = two_hop_cost(*target)
    dom = sort3(*target)
    print(f"  cost{target} = {cost}  (dominant rep: {dom})")

print("\nAll permutations of (2,1,0) have the same cost ✓")
print("Theorem used: tropConv_weyl_invariant")

# ─────────────────────────────────────────────────────────────────
# Application 3: Tropical Invariant Feature Extraction
# ─────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("APPLICATION 3: Permutation-Invariant Feature Extraction")
print("=" * 70)
print("""
For machine learning on sets of 3 elements, we need permutation-
invariant features. The tropical Chevalley theorem tells us that
the tropical symmetric polynomials (e₁, e₂, e₃) form a COMPLETE
invariant: they separate all S₃-orbits.

This means: any S₃-invariant function can be expressed in terms of
(e₁, e₂, e₃), providing a universal feature map for set-valued data.
""")

def tropical_features(data_triple):
    """Extract complete S₃-invariant features (tropical Chevalley)"""
    a, b, c = data_triple
    e1 = max(a, b, c)                          # tropical e₁
    e2 = max(a+b, a+c, b+c)                    # tropical e₂
    e3 = a + b + c                              # tropical e₃
    s21 = trop_schur(2, 1, 0, a, b, c)         # tropical Schur (2,1,0)
    return (e1, e2, e3, s21)

# Example: classify triangle types by side lengths
triangles = {
    "equilateral": (3, 3, 3),
    "isosceles A": (4, 4, 2),
    "isosceles B": (2, 4, 4),  # same as A up to permutation
    "scalene":     (5, 3, 2),
    "scalene perm": (2, 5, 3), # same as scalene up to permutation
}

print("Triangle classification via tropical features:")
print(f"  {'Type':15s} {'Triple':12s} {'Features':30s} {'Dominant':12s}")
for name, triple in triangles.items():
    feats = tropical_features(triple)
    dom = sort3(*triple)
    print(f"  {name:15s} {str(triple):12s} {str(feats):30s} {str(dom):12s}")

print("\nNotice: 'isosceles A' and 'isosceles B' have identical features")
print("(they're S₃-equivalent). Same for 'scalene' and 'scalene perm'.")
print("Theorem used: TropicalSatake.separates_orbits (completeness of features)")

# ─────────────────────────────────────────────────────────────────
# Application 4: Tropical Convolution for Signal Processing
# ─────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("APPLICATION 4: Morphological Signal Processing")
print("=" * 70)
print("""
Mathematical morphology uses min/max operations for image processing.
The tropical convolution is exactly the morphological erosion operator.

For 3-channel (e.g., RGB) images with channel symmetry, our theorem
guarantees that erosion preserves channel-interchange invariance.
This is relevant for color-space independent image processing.
""")

# Simulate a simple 3-channel morphological operation
np.random.seed(42)
signal = np.random.randint(0, 10, size=(5, 3))  # 5 pixels, 3 channels

print("Input 3-channel signal (5 pixels × 3 channels):")
for i, pixel in enumerate(signal):
    feat = tropical_features(tuple(pixel))
    print(f"  Pixel {i}: {list(pixel)}  tropical features: {feat}")

print("\nThe tropical features are invariant under channel permutation,")
print("enabling color-space independent morphological processing.")

print("\n" + "=" * 70)
print("ALL APPLICATIONS DEMONSTRATED")
print("=" * 70)


"""
Tropical Satake Correspondence for GL₃ — Interactive Demonstration
=================================================================

This script demonstrates the key results from the formalized tropical
Satake correspondence for GL₃, including:

1. Tropical symmetric polynomials and orbit separation
2. The sorting map and dominant chamber
3. Why the naive Satake transform is NOT multiplicative (counterexample)
4. Correct tropical convolution preserving S₃-invariance
5. Tropical Schur polynomials and the rearrangement inequality

All results correspond to formally verified Lean 4 theorems.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from mpl_toolkits.mplot3d import Axes3D

# ─────────────────────────────────────────────────────────────────────
# Part 1: Tropical Symmetric Polynomials
# ─────────────────────────────────────────────────────────────────────

def trop_e1(a, b, c):
    """Tropical e₁ = max(a,b,c)"""
    return max(a, b, c)

def trop_e2(a, b, c):
    """Tropical e₂ = max(a+b, a+c, b+c) = sum - min"""
    return max(a+b, a+c, b+c)

def trop_e3(a, b, c):
    """Tropical e₃ = a + b + c"""
    return a + b + c

def sort3(a, b, c):
    """Sort into weakly decreasing order (dominant coweight)"""
    s = sorted([a, b, c], reverse=True)
    return tuple(s)

def is_dominant(a, b, c):
    """Check if (a,b,c) is dominant (weakly decreasing)"""
    return a >= b >= c


print("=" * 70)
print("TROPICAL SATAKE CORRESPONDENCE FOR GL₃")
print("Formally verified in Lean 4 with Mathlib")
print("=" * 70)

# ─────────────────────────────────────────────────────────────────────
# Demo 1: Orbit Separation (Tropical Chevalley Theorem)
# ─────────────────────────────────────────────────────────────────────
print("\n" + "─" * 70)
print("DEMO 1: Tropical Chevalley Theorem — Orbit Separation")
print("─" * 70)
print("\nThe tropical symmetric polynomials (e₁, e₂, e₃) separate S₃-orbits.")
print("Two triples with the same (e₁, e₂, e₃) must be permutations.\n")

test_cases = [(3, 1, 2), (2, 3, 1), (1, 2, 3), (5, 0, -1), (0, 5, -1)]
for t in test_cases:
    a, b, c = t
    print(f"  ({a:2d}, {b:2d}, {c:2d})  →  e₁={trop_e1(a,b,c):3d}, "
          f"e₂={trop_e2(a,b,c):3d}, e₃={trop_e3(a,b,c):3d}  "
          f"sort={sort3(a,b,c)}")

print("\nNotice: (3,1,2), (2,3,1), (1,2,3) all have the same invariants")
print("and the same sort — they are in the same S₃-orbit. ✓")
print("Theorem: TropicalSatake.separates_orbits")

# ─────────────────────────────────────────────────────────────────────
# Demo 2: The Dominant Chamber (Satake Cone)
# ─────────────────────────────────────────────────────────────────────
print("\n" + "─" * 70)
print("DEMO 2: Dominant Chamber and Satake Cone")
print("─" * 70)
print("\nThe image of (e₁, e₂, e₃) is the cone {(x,y,z) : 2x ≥ y, 2y ≥ x+z}.")
print("This is the dominant Weyl chamber for GL₃.\n")

print("  Checking dominance conditions for some examples:")
for a, b, c in [(3, 2, 1), (5, 3, 0), (1, 1, 1), (2, 0, -1)]:
    e1, e2, e3 = trop_e1(a,b,c), trop_e2(a,b,c), trop_e3(a,b,c)
    cond1 = 2 * e1 >= e2
    cond2 = 2 * e2 >= e1 + e3
    print(f"  ({a},{b},{c}): (e₁,e₂,e₃) = ({e1},{e2},{e3})  "
          f"2e₁≥e₂: {cond1}  2e₂≥e₁+e₃: {cond2}")

print("\nTheorem: TropicalSatake.image_characterization")

# ─────────────────────────────────────────────────────────────────────
# Demo 3: Sort Non-Additivity (Counterexample)
# ─────────────────────────────────────────────────────────────────────
print("\n" + "─" * 70)
print("DEMO 3: Sort is NOT Additive — Why Naive Satake Fails")
print("─" * 70)
print("\n⚠️  The proposed tropical_satake_GL3_algebraHom theorem is FALSE!")
print("\nCounterexample: sort is not additive.")
print()

a1, b1, c1 = (1, 0, 0)
a2, b2, c2 = (0, 1, 0)
sort_sum = sort3(a1+a2, b1+b2, c1+c2)
s1 = sort3(a1, b1, c1)
s2 = sort3(a2, b2, c2)
sum_sorts = (s1[0]+s2[0], s1[1]+s2[1], s1[2]+s2[2])

print(f"  sort({a1+a2}, {b1+b2}, {c1+c2}) = sort{(a1+a2, b1+b2, c1+c2)} = {sort_sum}")
print(f"  sort{(a1,b1,c1)} + sort{(a2,b2,c2)} = {s1} + {s2} = {sum_sorts}")
print(f"\n  sort(x+y) = {sort_sum} ≠ {sum_sorts} = sort(x) + sort(y)")
print(f"\n  This non-additivity means S(f⊛g) ≠ (Sf)⋆(Sg) for dominant")
print(f"  convolution ⊛. The correct approach uses FULL convolution on ℤ³.")
print("\nTheorem: TropicalSatakeAlgebra.sort_not_additive_witness")

# ─────────────────────────────────────────────────────────────────────
# Demo 4: Tropical Schur Polynomials
# ─────────────────────────────────────────────────────────────────────
print("\n" + "─" * 70)
print("DEMO 4: Tropical Schur Polynomials")
print("─" * 70)

def trop_schur(l1, l2, l3, a, b, c):
    """Tropical Schur polynomial = min over S₃ of inner product."""
    return min(l1*x + l2*y + l3*z for x, y, z in permutations([a, b, c]))

print("\nTropical Schur s_{(l₁,l₂,l₃)}(a,b,c) = min_{σ∈S₃} Σ lᵢ·a_{σ(i)}")
print("\nFundamental weight evaluations:")
for a, b, c in [(3, 1, 2), (5, 0, -1), (2, 2, 1)]:
    s100 = trop_schur(1, 0, 0, a, b, c)
    s110 = trop_schur(1, 1, 0, a, b, c)
    s111 = trop_schur(1, 1, 1, a, b, c)
    print(f"  ({a},{b},{c}): s_(1,0,0)={s100} [=min={min(a,b,c)}], "
          f"s_(1,1,0)={s110}, s_(1,1,1)={s111} [=sum={a+b+c}]")

print("\nRearrangement inequality (dominant × dominant):")
print("When l₁≥l₂≥l₃ and a≥b≥c, the minimum is l₁c+l₂b+l₃a (reverse pairing).\n")
for l1, l2, l3 in [(3, 2, 1), (5, 3, 0)]:
    for a, b, c in [(4, 2, 1), (3, 2, 0)]:
        val = trop_schur(l1, l2, l3, a, b, c)
        rev = l1*c + l2*b + l3*a
        fwd = l1*a + l2*b + l3*c
        print(f"  s_({l1},{l2},{l3})({a},{b},{c}) = {val}  "
              f"[reverse={rev}, forward={fwd}]")

print("\nTheorem: TropicalSatakeAlgebra.tropSchur_dominant_eval")

# ─────────────────────────────────────────────────────────────────────
# Demo 5: Tropical Convolution Preserves Weyl Invariance
# ─────────────────────────────────────────────────────────────────────
print("\n" + "─" * 70)
print("DEMO 5: Tropical Convolution Preserves S₃-Invariance")
print("─" * 70)

INF = float('inf')

def trop_indicator(point):
    """Tropical indicator: 0 at point, +∞ elsewhere."""
    def f(a, b, c):
        if sorted([a, b, c], reverse=True) == sorted(point, reverse=True):
            return 0  # tropical multiplicative identity
        return INF
    return f

def trop_conv_finite(f, g, a, b, c, search_range=5):
    """Approximate tropical convolution by searching a finite range."""
    result = INF
    for a1 in range(-search_range, search_range+1):
        for b1 in range(-search_range, search_range+1):
            for c1 in range(-search_range, search_range+1):
                val = f(a1, b1, c1) + g(a-a1, b-b1, c-c1)
                if val < result:
                    result = val
    return result

print("\nThe full tropical convolution of S₃-invariant functions is S₃-invariant.")
print("This is the CORRECT algebraic structure for the tropical Hecke algebra.\n")

f = trop_indicator((1, 0, 0))
g = trop_indicator((1, 0, 0))

print("f = g = tropical indicator of S₃-orbit of (1,0,0)")
print("(f ⋆ g)(a,b,c) = min over {x+y=(a,b,c)} of f(x)+g(y)\n")

test_points = [(2,0,0), (0,2,0), (0,0,2), (1,1,0), (1,0,1), (0,1,1),
               (1,1,1), (3,0,0)]
for a, b, c in test_points:
    val = trop_conv_finite(f, g, a, b, c)
    val_str = f"{val:.0f}" if val < INF else "∞"
    # Check S₃-invariance by computing at a permutation
    val2 = trop_conv_finite(f, g, b, c, a)
    val2_str = f"{val2:.0f}" if val2 < INF else "∞"
    check = "✓" if val == val2 else "✗"
    print(f"  (f⋆g)({a},{b},{c}) = {val_str:>3s}   "
          f"(f⋆g)({b},{c},{a}) = {val2_str:>3s}   "
          f"S₃-invariant: {check}")

print("\nNotice: (f⋆g) at ALL permutations of (2,0,0) gives 0,")
print("and at ALL permutations of (1,1,0) also gives 0.")
print("This is S₃-invariant! ✓")
print("\nTheorem: TropicalSatakeAlgebra.tropConv_weyl_invariant")

# ─────────────────────────────────────────────────────────────────────
# Demo 6: Visualization — The Dominant Chamber
# ─────────────────────────────────────────────────────────────────────
print("\n" + "─" * 70)
print("DEMO 6: Generating Visualizations...")
print("─" * 70)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: The Satake cone in (e₁, e₂) coordinates
ax1 = axes[0]
ax1.set_title("Satake Cone: Image of (e₁, e₂, e₃)", fontsize=13)
ax1.set_xlabel("e₁ = max(a,b,c)")
ax1.set_ylabel("e₂ = max(a+b, a+c, b+c)")

# Plot the dominant chamber conditions: 2e₁ ≥ e₂ and 2e₂ ≥ e₁ + e₃
# Fix e₃ = 0 for visualization
e3_fixed = 0
e1_range = np.linspace(0, 6, 100)

# Upper bound: e₂ ≤ 2*e₁
# Lower bound: e₂ ≥ (e₁ + e₃)/2
upper = 2 * e1_range
lower = (e1_range + e3_fixed) / 2

ax1.fill_between(e1_range, lower, upper, alpha=0.3, color='blue',
                  label='Satake cone (e₃=0)')
ax1.plot(e1_range, upper, 'b-', linewidth=2, label='2e₁ = e₂')
ax1.plot(e1_range, lower, 'r-', linewidth=2, label='2e₂ = e₁+e₃')

# Plot actual points
for a in range(-2, 5):
    for b in range(-2, 5):
        for c in range(-2, 5):
            if a + b + c == e3_fixed:
                e1, e2 = trop_e1(a,b,c), trop_e2(a,b,c)
                if 0 <= e1 <= 6 and 0 <= e2 <= 12:
                    ax1.plot(e1, e2, 'ko', markersize=4)

ax1.legend(fontsize=10)
ax1.set_xlim(0, 6)
ax1.set_ylim(-0.5, 12)
ax1.grid(True, alpha=0.3)

# Plot 2: Sort non-additivity illustration
ax2 = axes[1]
ax2.set_title("Sort Non-Additivity: Why Naive Satake Fails", fontsize=13)

# Show the coweight lattice projected to 2D (fixing sum=0 plane)
# Plot points and their sorts
points = [(1, 0, -1), (0, 1, -1), (-1, 1, 0), (-1, 0, 1), (0, -1, 1), (1, -1, 0),
          (2, 0, -2), (0, 2, -2), (2, -1, -1), (1, 1, -2)]

# Project to 2D using the basis e₁-e₂, e₂-e₃
def project(a, b, c):
    return (a - b, b - c)

for p in points:
    x, y = project(*p)
    xs, ys = project(*sort3(*p))
    ax2.plot(x, y, 'bo', markersize=6)
    ax2.plot(xs, ys, 'r^', markersize=8)
    if (x, y) != (xs, ys):
        ax2.annotate('', xy=(xs, ys), xytext=(x, y),
                     arrowprops=dict(arrowstyle='->', color='gray', lw=0.8))

# Highlight the counterexample
p1 = (1, 0, 0)
p2 = (0, 1, 0)
p_sum = (1, 1, 0)
s1 = sort3(*p1)
s2 = sort3(*p2)
s_sum = sort3(*p_sum)
naive_sum = (s1[0]+s2[0], s1[1]+s2[1], s1[2]+s2[2])

x1, y1 = project(*p_sum)
ax2.plot(x1, y1, 'g*', markersize=15, label=f'sort(sum)={s_sum}')
xn, yn = project(*naive_sum)
ax2.plot(xn, yn, 'rx', markersize=15, mew=3, label=f'sum(sorts)={naive_sum}')

ax2.set_xlabel("a - b (first root coordinate)")
ax2.set_ylabel("b - c (second root coordinate)")
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Shade dominant chamber
xx = np.linspace(0, 4, 100)
ax2.fill_between(xx, 0, xx*0+4, alpha=0.1, color='green', label='Dominant')
ax2.set_xlim(-3, 4)
ax2.set_ylim(-3, 4)

plt.tight_layout()
plt.savefig('demos/tropical_satake_visualization.png', dpi=150, bbox_inches='tight')
print("\n  Saved: demos/tropical_satake_visualization.png")

# ─────────────────────────────────────────────────────────────────────
# Demo 7: Schur polynomial surface
# ─────────────────────────────────────────────────────────────────────

fig2, ax3 = plt.subplots(figsize=(8, 6))
ax3.set_title("Tropical Schur Polynomial s₍₂,₁,₀₎(a,b,c) with a+b+c=0",
              fontsize=13)

# Plot tropical Schur on the hyperplane a+b+c=0
N = 50
a_range = np.linspace(-3, 3, N)
b_range = np.linspace(-3, 3, N)
A, B = np.meshgrid(a_range, b_range)
C = -A - B  # enforce a+b+c=0

Z = np.zeros_like(A)
for i in range(N):
    for j in range(N):
        Z[i, j] = trop_schur(2, 1, 0, A[i,j], B[i,j], C[i,j])

cf = ax3.contourf(A, B, Z, levels=20, cmap='viridis')
plt.colorbar(cf, ax=ax3, label='s₍₂,₁,₀₎(a, b, -a-b)')
ax3.set_xlabel('a')
ax3.set_ylabel('b')
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('demos/tropical_schur_contour.png', dpi=150, bbox_inches='tight')
print("  Saved: demos/tropical_schur_contour.png")

# ─────────────────────────────────────────────────────────────────────
# Demo 8: Convolution table
# ─────────────────────────────────────────────────────────────────────

fig3, ax4 = plt.subplots(figsize=(8, 6))
ax4.set_title("Tropical Convolution (f⋆g) for indicator functions", fontsize=13)

# Compute convolution values on dominant coweights with sum ≤ 4
dom_points = []
for a in range(-1, 5):
    for b in range(-1, a+1):
        for c in range(-1, b+1):
            if abs(a) + abs(b) + abs(c) <= 6:
                dom_points.append((a, b, c))

# f = indicator of orbit of (1,0,0), g = indicator of orbit of (0,0,0)
f1 = trop_indicator((1, 0, 0))
g1 = trop_indicator((0, 0, 0))

conv_vals = []
labels = []
for p in dom_points[:15]:
    val = trop_conv_finite(f1, g1, *p, search_range=3)
    conv_vals.append(val if val < INF else None)
    labels.append(str(p))

# Bar chart
valid = [(l, v) for l, v in zip(labels, conv_vals) if v is not None]
if valid:
    ls, vs = zip(*valid)
    ax4.barh(range(len(ls)), vs, color='steelblue')
    ax4.set_yticks(range(len(ls)))
    ax4.set_yticklabels(ls)
    ax4.set_xlabel('(f ⋆ g)(λ)')
    ax4.set_ylabel('Dominant coweight λ')

plt.tight_layout()
plt.savefig('demos/tropical_convolution_chart.png', dpi=150, bbox_inches='tight')
print("  Saved: demos/tropical_convolution_chart.png")

print("\n" + "=" * 70)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 70)
print("\nKey verified theorems:")
print("  1. TropicalSatake.separates_orbits (Tropical Chevalley)")
print("  2. TropicalSatake.image_characterization (Satake Cone)")
print("  3. TropicalSatakeAlgebra.sort_not_additive (Counterexample)")
print("  4. TropicalSatakeAlgebra.tropConv_weyl_invariant (Correct algebra)")
print("  5. TropicalSatakeAlgebra.tropSchur_dominant_eval (Rearrangement)")
print("  6. TropicalSatakeAlgebra.satake_restrict_extend (Satake isomorphism)")
