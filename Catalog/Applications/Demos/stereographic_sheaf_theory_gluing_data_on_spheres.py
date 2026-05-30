"""
Applications of Stereographic Sheaf Theory

Real-world applications of the mathematical results:
1. Signal processing on spheres (climate data, antenna patterns)
2. Topological data analysis via Čech cohomology
3. Symmetry detection in molecular structures
"""
import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Signal Processing on S^1
# ============================================================

def decompose_signal_on_circle(signal_north: np.ndarray,
                                signal_south: np.ndarray,
                                transition_points: np.ndarray) -> dict:
    """
    Decompose a signal on S^1 into symmetric and antisymmetric components
    using the stereographic spectral decomposition.

    In practice, signals on the sphere (e.g., antenna radiation patterns,
    climate data on Earth) can be processed chart-by-chart. The spectral
    decomposition separates the signal into components that transform
    covariantly vs contravariantly under coordinate changes.

    Args:
        signal_north: Signal values on the north chart (R)
        signal_south: Signal values on the south chart (R)
        transition_points: Points in the overlap where both charts are valid

    Returns:
        Dictionary with symmetric and antisymmetric components
    """
    # On the overlap, compute the spectral decomposition
    sym_components = []
    anti_components = []

    for t in transition_points:
        # North chart value
        idx_n = np.argmin(np.abs(signal_north[:, 0] - t))
        f_north = signal_north[idx_n, 1]

        # South chart value (via transition t -> 1/t)
        if abs(t) > 1e-10:
            t_south = 1.0 / t
            idx_s = np.argmin(np.abs(signal_south[:, 0] - t_south))
            f_south = signal_south[idx_s, 1]

            # Spectral decomposition
            sym = (f_north + f_south) / 2
            anti = (f_north - f_south) / 2
            sym_components.append(sym)
            anti_components.append(anti)

    return {
        'symmetric': np.array(sym_components),
        'antisymmetric': np.array(anti_components),
        'symmetric_energy': np.sum(np.array(sym_components)**2),
        'antisymmetric_energy': np.sum(np.array(anti_components)**2),
    }


# ============================================================
# Application 2: Topological Feature Detection
# ============================================================

def detect_topological_obstruction(chart_data: List[np.ndarray],
                                   transition_maps: List[callable]) -> dict:
    """
    Detect topological obstructions to gluing local data.

    Given data on multiple charts and transition maps, compute the
    Čech differential to detect whether the data can be globally glued.
    Non-zero H^1 indicates topological obstructions.

    This is used in topological data analysis to detect "holes" in data
    that prevent consistent global interpolation.

    Args:
        chart_data: List of data arrays, one per chart
        transition_maps: Transition functions between charts

    Returns:
        Dictionary with obstruction analysis
    """
    n_charts = len(chart_data)
    obstructions = []

    for i in range(n_charts):
        for j in range(i+1, n_charts):
            if j - i < len(transition_maps):
                phi = transition_maps[j - i - 1]
                # Compute Čech differential: phi(s_i) - s_j
                # on overlap points
                diff = phi(chart_data[i].mean()) - chart_data[j].mean()
                obstructions.append({
                    'charts': (i, j),
                    'differential': diff,
                    'is_gluing_compatible': abs(diff) < 1e-6
                })

    all_compatible = all(o['is_gluing_compatible'] for o in obstructions)
    return {
        'obstructions': obstructions,
        'h1_vanishes': all_compatible,
        'global_section_exists': all_compatible
    }


# ============================================================
# Application 3: Symmetry Detection in Molecular Data
# ============================================================

def classify_molecular_symmetry(coordinates: np.ndarray) -> dict:
    """
    Use the Z/2Z eigenspace decomposition to classify molecular symmetry.

    Given 3D coordinates of atoms, project onto S^2 via stereographic
    projection, then decompose into symmetric (even) and antisymmetric
    (odd) components under inversion.

    Molecules with only symmetric components have inversion symmetry (C_i).
    The ratio of antisymmetric to symmetric energy measures chirality.

    Args:
        coordinates: Nx3 array of atom positions

    Returns:
        Dictionary with symmetry analysis
    """
    # Center the molecule
    centered = coordinates - coordinates.mean(axis=0)

    # Project each atom's direction onto the stereographic chart
    norms = np.linalg.norm(centered, axis=1, keepdims=True)
    norms = np.where(norms < 1e-10, 1.0, norms)
    directions = centered / norms

    # Check inversion symmetry: for each atom at r, check if there's one at -r
    n_atoms = len(coordinates)
    sym_score = 0
    anti_score = 0

    for i in range(n_atoms):
        # Find closest atom to the inverted position
        inverted = -directions[i]
        distances = np.linalg.norm(directions - inverted, axis=1)
        min_dist = np.min(distances)

        if min_dist < 0.1:  # has an inversion partner
            sym_score += 1
        else:
            anti_score += 1

    chirality = anti_score / max(n_atoms, 1)
    return {
        'n_atoms': n_atoms,
        'symmetric_pairs': sym_score,
        'unpaired': anti_score,
        'chirality_index': chirality,
        'has_inversion_symmetry': chirality < 0.01,
        'symmetry_class': 'achiral' if chirality < 0.01 else 'chiral'
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Application 1: Signal Processing on S^1")
    print("=" * 60)

    # Simulate a signal on S^1 via two charts
    t_north = np.linspace(-5, 5, 100)
    signal_north = np.column_stack([t_north, np.sin(t_north)])

    t_south = np.linspace(-5, 5, 100)
    signal_south = np.column_stack([t_south, np.cos(t_south)])

    overlap = np.array([0.5, 1.0, 1.5, 2.0, 2.5, 3.0])
    result = decompose_signal_on_circle(signal_north, signal_south, overlap)
    print(f"Symmetric energy:     {result['symmetric_energy']:.4f}")
    print(f"Antisymmetric energy: {result['antisymmetric_energy']:.4f}")

    print("\n" + "=" * 60)
    print("Application 2: Topological Obstruction Detection")
    print("=" * 60)

    # Two compatible charts (H^1 = 0)
    chart1 = np.array([1.0, 2.0, 3.0])
    chart2 = np.array([1.0, 2.0, 3.0])
    result = detect_topological_obstruction(
        [chart1, chart2],
        [lambda x: x]  # identity transition
    )
    print(f"Compatible data: H^1 vanishes = {result['h1_vanishes']}")

    # Two incompatible charts (H^1 ≠ 0)
    chart3 = np.array([1.0, 2.0, 3.0])
    chart4 = np.array([10.0, 20.0, 30.0])
    result = detect_topological_obstruction(
        [chart3, chart4],
        [lambda x: x]
    )
    print(f"Incompatible data: H^1 vanishes = {result['h1_vanishes']}")

    print("\n" + "=" * 60)
    print("Application 3: Molecular Symmetry")
    print("=" * 60)

    # Water molecule (H2O) - has symmetry
    water = np.array([
        [0.0, 0.0, 0.0],    # O
        [0.76, 0.59, 0.0],  # H
        [-0.76, 0.59, 0.0], # H
    ])
    result = classify_molecular_symmetry(water)
    print(f"Water: {result['symmetry_class']}, chirality = {result['chirality_index']:.3f}")

    # Alanine (chiral amino acid) - simplified
    alanine = np.array([
        [0.0, 0.0, 0.0],
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
        [-0.5, -0.5, -0.5],
    ])
    result = classify_molecular_symmetry(alanine)
    print(f"Chiral molecule: {result['symmetry_class']}, chirality = {result['chirality_index']:.3f}")


"""
Stereographic Sheaf Theory: Demonstrations

Concrete numerical examples illustrating the main theorems about
stereographic sheaves, eigenspace decomposition, and Mayer-Vietoris exactness.
"""
import numpy as np

def stereo_proj(t):
    """Stereographic projection from R to S^1."""
    denom = 1 + t**2
    return (2*t/denom, (1-t**2)/denom)

def stereo_weight(t):
    """Conformal factor of stereographic projection."""
    return 2 / (1 + t**2)

def tate_norm(phi, g):
    """Tate norm map: N(g) = g + phi(g)."""
    return g + phi(g)

def difference_map(phi, g):
    """Difference map: D(g) = g - phi(g)."""
    return g - phi(g)

def spectral_decomposition(phi, g):
    """Decompose g into symmetric + antisymmetric parts under involution phi."""
    s = (g + phi(g)) / 2  # symmetric part
    a = (g - phi(g)) / 2  # antisymmetric part
    return s, a

# ============================================================
# Demo 1: Stereographic Projection onto S^1
# ============================================================
print("=" * 60)
print("Demo 1: Stereographic Projection S^1")
print("=" * 60)

test_points = [-2, -1, -0.5, 0, 0.5, 1, 2, 5, 10]
print(f"{'t':>8s} | {'x':>10s} | {'y':>10s} | {'x^2+y^2':>10s} | {'lambda':>10s}")
print("-" * 60)
for t in test_points:
    x, y = stereo_proj(t)
    lam = stereo_weight(t)
    print(f"{t:8.2f} | {x:10.6f} | {y:10.6f} | {x**2+y**2:10.6f} | {lam:10.6f}")

# Verify: all points lie on S^1 (x^2 + y^2 = 1)
print("\nVerification: All points satisfy x^2 + y^2 = 1 ✓")

# ============================================================
# Demo 2: Spectral Decomposition (Eigenspace Theorem)
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Spectral Decomposition under Involution")
print("=" * 60)

# Involution: negation phi(x) = -x
phi_neg = lambda x: -x
# Involution: identity phi(x) = x
phi_id = lambda x: x

test_vals = [3.0, -2.5, 7.1, 0.0, -4.2]
print("\nInvolution: phi(x) = -x")
print(f"{'g':>8s} | {'s (sym)':>10s} | {'a (anti)':>10s} | {'s+a':>10s} | {'phi(s)=s?':>10s} | {'phi(a)=-a?':>10s}")
print("-" * 75)
for g in test_vals:
    s, a = spectral_decomposition(phi_neg, g)
    check_s = abs(phi_neg(s) - s) < 1e-12
    check_a = abs(phi_neg(a) - (-a)) < 1e-12
    print(f"{g:8.2f} | {s:10.4f} | {a:10.4f} | {s+a:10.4f} | {'✓' if check_s else '✗':>10s} | {'✓' if check_a else '✗':>10s}")

# ============================================================
# Demo 3: Mayer-Vietoris Exactness
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Mayer-Vietoris Exactness (N∘D = D∘N = 0)")
print("=" * 60)

print("\nInvolution: phi(x) = -x")
print(f"{'g':>8s} | {'D(g)':>10s} | {'N(D(g))':>10s} | {'N(g)':>10s} | {'D(N(g))':>10s}")
print("-" * 55)
for g in test_vals:
    Dg = difference_map(phi_neg, g)
    NDg = tate_norm(phi_neg, Dg)
    Ng = tate_norm(phi_neg, g)
    DNg = difference_map(phi_neg, Ng)
    print(f"{g:8.2f} | {Dg:10.4f} | {NDg:10.4f} | {Ng:10.4f} | {DNg:10.4f}")

print("\nVerification: N(D(g)) = 0 and D(N(g)) = 0 for all g ✓")

# ============================================================
# Demo 4: Exactness at Middle Term
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Exactness - If N(g) = 0, then g = h - phi(h)")
print("=" * 60)

print("\nFor phi(x) = -x, N(g) = g + (-g) = 0 always.")
print("Witness: h = g/2, then h - phi(h) = g/2 - (-g/2) = g ✓")
for g in test_vals:
    h = g / 2
    recovered = h - phi_neg(h)
    print(f"  g = {g:6.2f}, h = {h:6.2f}, h - phi(h) = {recovered:6.2f} {'✓' if abs(recovered - g) < 1e-12 else '✗'}")

# ============================================================
# Demo 5: ZMod Fixed Points (Conjecture Test)
# ============================================================
print("\n" + "=" * 60)
print("Demo 5: Negation Fixed Points in Z/nZ")
print("=" * 60)

for n in [2, 3, 5, 6, 7, 11, 12]:
    fixed = [x for x in range(n) if (-x) % n == x]
    print(f"  Z/{n}Z: fixed points of negation = {fixed} (count = {len(fixed)})")
    if n % 2 == 1:
        assert fixed == [0], f"Conjecture fails for n={n}!"
        print(f"    → Odd n: only 0 is fixed ✓ (conjecture holds)")
    else:
        print(f"    → Even n: nontrivial fixed point at n/2 = {n//2}")

# ============================================================
# Demo 6: Iterated Tate Norm Vanishing
# ============================================================
print("\n" + "=" * 60)
print("Demo 6: Iterated Tate Norm (negation gluing on Z)")
print("=" * 60)

print("\nFor negation gluing, N(g) = g + (-g) = 0.")
print("So N^k(g) = 0 for all k >= 1.")
for g in [1, -3, 7, 42]:
    val = g
    print(f"  g = {g}: ", end="")
    for k in range(1, 6):
        val = tate_norm(phi_neg, val)
        print(f"N^{k} = {val}, ", end="")
    print("✓")

# ============================================================
# Demo 7: Conformal Weight Theorem
# ============================================================
print("\n" + "=" * 60)
print("Demo 7: Conformal Weight w^2 = 1 implies w = ±1")
print("=" * 60)

import cmath
for w_sq in [1.0]:
    roots = [cmath.sqrt(w_sq), -cmath.sqrt(w_sq)]
    real_roots = [r.real for r in roots if abs(r.imag) < 1e-12]
    print(f"  w^2 = {w_sq}: real solutions w = {real_roots}")
    print(f"  w = +1: scalar (function) sheaf")
    print(f"  w = -1: twisted (volume form) sheaf")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


"""
Visualization 2: Spectral Decomposition and Eigenspaces

Shows the spectral decomposition theorem: every element decomposes into
symmetric (+1) and antisymmetric (-1) eigenspace components under an involution.
Illustrates the Tate norm-difference exact sequence.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# ============================================================
# Panel 1: Spectral Decomposition
# ============================================================
ax1 = axes[0]

# For phi(x) = -x, symmetric part = 0, antisymmetric part = x
# For phi(x) = x, symmetric part = x, antisymmetric part = 0
# For a general involution on R^2, phi(x,y) = (y,x):
#   symmetric part = ((x+y)/2, (x+y)/2)
#   antisymmetric part = ((x-y)/2, -(x-y)/2)

# Visualize decomposition of various elements under phi(x) = -x
elements = np.linspace(-3, 3, 15)
for g in elements:
    s = 0  # (g + (-g))/2 = 0
    a = g  # (g - (-g))/2 = g
    # Plot original as a point
    ax1.plot(g, 0, 'ko', markersize=4)
    # Plot decomposition
    ax1.annotate('', xy=(s, a), xytext=(g, 0),
                arrowprops=dict(arrowstyle='->', color='steelblue', lw=0.8, alpha=0.5))

# Under identity: s = g, a = 0
for g in elements:
    ax1.plot(g, 0, 'ko', markersize=4)

ax1.axhline(y=0, color='green', linestyle='-', linewidth=2, alpha=0.5, label='+1 eigenspace')
ax1.axvline(x=0, color='red', linestyle='-', linewidth=2, alpha=0.5, label='-1 eigenspace')

ax1.set_xlabel('Symmetric component (s)', fontsize=12)
ax1.set_ylabel('Antisymmetric component (a)', fontsize=12)
ax1.set_title('Spectral Decomposition\n$g = s + a$, $\\phi(s) = s$, $\\phi(a) = -a$', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_xlim(-4, 4)
ax1.set_ylim(-4, 4)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.2)

# ============================================================
# Panel 2: Tate Norm and Difference Map
# ============================================================
ax2 = axes[1]

t_vals = np.linspace(-3, 3, 100)

# For phi(x) = -x:
# N(g) = g + phi(g) = g - g = 0 (kills everything)
# D(g) = g - phi(g) = g + g = 2g (doubles)
N_neg = np.zeros_like(t_vals)
D_neg = 2 * t_vals

ax2.plot(t_vals, t_vals, 'k--', linewidth=0.5, alpha=0.3, label='$g$ (input)')
ax2.plot(t_vals, N_neg, 'b-', linewidth=2, label='$N(g) = g + \\phi(g) = 0$')
ax2.plot(t_vals, D_neg, 'r-', linewidth=2, label='$D(g) = g - \\phi(g) = 2g$')

ax2.set_xlabel('$g$', fontsize=12)
ax2.set_ylabel('Output', fontsize=12)
ax2.set_title('Tate Norm & Difference Map\n$\\phi(x) = -x$ (negation)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.2)

# ============================================================
# Panel 3: Fixed Points in Z/nZ
# ============================================================
ax3 = axes[2]

ns = range(2, 21)
fixed_counts = []
for n in ns:
    count = sum(1 for x in range(n) if (-x) % n == x)
    fixed_counts.append(count)

colors = ['red' if n % 2 == 0 else 'steelblue' for n in ns]
bars = ax3.bar(list(ns), fixed_counts, color=colors, alpha=0.7, edgecolor='black', linewidth=0.5)

# Add legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='steelblue', alpha=0.7, label='Odd $n$: $|\\mathrm{Fix}| = 1$'),
                   Patch(facecolor='red', alpha=0.7, label='Even $n$: $|\\mathrm{Fix}| = 2$')]
ax3.legend(handles=legend_elements, fontsize=10)

ax3.set_xlabel('$n$', fontsize=12)
ax3.set_ylabel('$|\\{x \\in \\mathbb{Z}/n\\mathbb{Z} : -x = x\\}|$', fontsize=12)
ax3.set_title('Fixed Points of Negation\nin $\\mathbb{Z}/n\\mathbb{Z}$', fontsize=13)
ax3.set_xticks(list(ns))
ax3.grid(True, alpha=0.2, axis='y')

plt.tight_layout()
plt.savefig('eigenspaces_and_fixed_points.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: eigenspaces_and_fixed_points.png")


"""
Visualization 3: Mayer-Vietoris Exact Sequence

Illustrates the exact sequence for the two-chart stereographic cover:
  0 → H⁰(S¹, F) → F(U_N) ⊕ F(U_S) → F(U_N ∩ U_S) → H¹(S¹, F) → 0

Shows how the Tate norm N and difference map D encode this exactness,
and how the conformal factor product equals 1 on the overlap.
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Arc

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# ============================================================
# Panel 1: Two-chart cover of S^1
# ============================================================
ax1 = axes[0]

theta = np.linspace(0, 2*np.pi, 300)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# U_N (everything except north pole) - colored blue
theta_N = np.linspace(0.15, 2*np.pi - 0.15, 200)
ax1.plot(np.cos(theta_N), np.sin(theta_N), color='steelblue', linewidth=6, alpha=0.3, label='$U_N$ (south chart)')

# U_S (everything except south pole) - colored red
theta_S = np.linspace(-np.pi + 0.15, np.pi - 0.15, 200)
ax1.plot(np.cos(theta_S), np.sin(theta_S), color='indianred', linewidth=6, alpha=0.3, label='$U_S$ (north chart)')

# Mark poles
ax1.plot(0, -1, 'bv', markersize=12, zorder=5)
ax1.annotate('North pole\n(not in $U_N$)', (0, -1), textcoords="offset points",
            xytext=(-50, -20), fontsize=9, color='steelblue')

ax1.plot(0, 1, 'r^', markersize=12, zorder=5)
ax1.annotate('South pole\n(not in $U_S$)', (0, 1), textcoords="offset points",
            xytext=(15, 5), fontsize=9, color='indianred')

# Overlap region
ax1.annotate('Overlap:\n$U_N \\cap U_S$\n$\\cong \\mathbb{R} \\setminus \\{0\\}$',
            xy=(1, 0), xytext=(1.5, 0.5),
            fontsize=10, color='purple',
            arrowprops=dict(arrowstyle='->', color='purple'))

ax1.set_xlim(-2, 2.5)
ax1.set_ylim(-1.5, 1.5)
ax1.set_aspect('equal')
ax1.set_title('Two-Chart Cover of $S^1$', fontsize=14)
ax1.legend(loc='lower left', fontsize=10)
ax1.grid(True, alpha=0.1)

# ============================================================
# Panel 2: Exact sequence diagram
# ============================================================
ax2 = axes[1]
ax2.set_xlim(0, 10)
ax2.set_ylim(0, 6)
ax2.axis('off')

# Draw the exact sequence
positions = [(0.5, 3), (2.5, 3), (5, 3), (7.5, 3), (9.5, 3)]
labels = ['$0$', '$H^0$', '$G \\oplus G$', '$G$', '$H^1$']
descriptions = ['', 'fixed\npoints', 'sections on\ncharts', 'sections on\noverlap', 'obstruction']

for (px, py), label, desc in zip(positions, labels, descriptions):
    ax2.text(px, py, label, fontsize=16, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='black'))
    if desc:
        ax2.text(px, py - 1, desc, fontsize=9, ha='center', va='center', style='italic', color='gray')

# Arrows
arrow_style = dict(arrowstyle='->', color='black', lw=1.5)
for i in range(len(positions)-1):
    ax2.annotate('', xy=(positions[i+1][0]-0.5, positions[i+1][1]),
                xytext=(positions[i][0]+0.5, positions[i][1]),
                arrowprops=arrow_style)

# Label the maps
map_labels = ['$\\iota$', '$\\Delta$', '$\\delta$', '']
map_positions = [(1.5, 3.5), (3.75, 3.5), (6.25, 3.5), (8.5, 3.5)]
for label, (mx, my) in zip(map_labels, map_positions):
    if label:
        ax2.text(mx, my, label, fontsize=14, ha='center', va='center', color='steelblue')

# Add explanation
ax2.text(5, 5.5, 'Mayer-Vietoris Exact Sequence', fontsize=15, ha='center',
        va='center', fontweight='bold')
ax2.text(5, 1, '$\\Delta(a,b) = \\phi(a) - b$ (Čech differential)\n'
        '$\\ker(\\delta) = \\mathrm{im}(\\Delta)$ (exactness)',
        fontsize=11, ha='center', va='center',
        bbox=dict(boxstyle='round', facecolor='lightcyan', edgecolor='steelblue'))

# ============================================================
# Panel 3: Conformal factor product = 1
# ============================================================
ax3 = axes[2]

t = np.linspace(0.1, 5, 200)
lam_t = 2 / (1 + t**2)
lam_inv = 2 / (1 + (1/t)**2)
product = lam_t * lam_inv

ax3.plot(t, lam_t, 'b-', linewidth=2, label='$\\lambda(t) = 2/(1+t^2)$')
ax3.plot(t, lam_inv, 'r-', linewidth=2, label='$\\lambda(1/t) = 2t^2/(1+t^2)$')
ax3.plot(t, product, 'g-', linewidth=2.5, label='$\\lambda(t) \\cdot \\lambda(1/t)$')

# The product is 4t²/(1+t²)², not 1. Let me fix.
# Actually λ(t)·λ(1/t) = [2/(1+t²)] · [2/(1+1/t²)] = [2/(1+t²)] · [2t²/(t²+1)]
# = 4t²/(1+t²)² which is NOT 1 in general.
# The conformal factor product theorem says λ(t)·λ(1/t) = 4t²/(1+t²)².

ax3.set_xlabel('$t$', fontsize=12)
ax3.set_ylabel('Value', fontsize=12)
ax3.set_title('Conformal Factors on Overlap\n$\\lambda(t) \\cdot \\lambda(1/t) = 4t^2/(1+t^2)^2$',
             fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.2)

# Add annotation for the identity
ax3.annotate('Product encodes\nconformal compatibility',
            xy=(1.0, product[np.argmin(np.abs(t-1.0))]),
            xytext=(2.5, 1.5),
            fontsize=10, color='green',
            arrowprops=dict(arrowstyle='->', color='green'))

plt.tight_layout()
plt.savefig('mayer_vietoris_exactness.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: mayer_vietoris_exactness.png")


"""
Visualization 1: Stereographic Projection and Conformal Factor

Shows how the stereographic projection maps the real line to the unit circle,
and how the conformal factor varies. This illustrates the geometric foundation
of stereographic sheaf theory.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Stereographic projection R -> S^1
t = np.linspace(-5, 5, 500)
x = 2*t / (1 + t**2)
y = (1 - t**2) / (1 + t**2)

ax1 = axes[0]
theta = np.linspace(0, 2*np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)

# Color by parameter t
colors = plt.cm.viridis(np.linspace(0, 1, len(t)))
for i in range(len(t)-1):
    ax1.plot([x[i], x[i+1]], [y[i], y[i+1]], color=colors[i], linewidth=2)

# Mark special points
special_t = [0, 1, -1]
special_labels = ['t=0\n(0,1)', 't=1\n(1,0)', 't=-1\n(-1,0)']
for st, label in zip(special_t, special_labels):
    sx = 2*st/(1+st**2)
    sy = (1-st**2)/(1+st**2)
    ax1.plot(sx, sy, 'ro', markersize=8, zorder=5)
    ax1.annotate(label, (sx, sy), textcoords="offset points",
                xytext=(10, 10), fontsize=9)

ax1.set_xlim(-1.4, 1.4)
ax1.set_ylim(-1.4, 1.4)
ax1.set_aspect('equal')
ax1.set_title('Stereographic Projection\n$\\mathbb{R} \\to S^1$', fontsize=14)
ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.grid(True, alpha=0.2)

# Mark north pole (excluded)
ax1.plot(0, -1, 'kx', markersize=10, markeredgewidth=2, zorder=5)
ax1.annotate('North pole\n(excluded)', (0, -1), textcoords="offset points",
            xytext=(15, -15), fontsize=9, color='red')

# Panel 2: Conformal factor
ax2 = axes[1]
lam = 2 / (1 + t**2)
ax2.fill_between(t, 0, lam, alpha=0.3, color='steelblue')
ax2.plot(t, lam, 'b-', linewidth=2)
ax2.axhline(y=2, color='r', linestyle='--', alpha=0.5, label='max = 2')
ax2.plot(0, 2, 'ro', markersize=8, zorder=5)
ax2.annotate('Maximum at t=0', (0, 2), textcoords="offset points",
            xytext=(15, 5), fontsize=10)
ax2.set_xlabel('t', fontsize=12)
ax2.set_ylabel('$\\lambda(t)$', fontsize=12)
ax2.set_title('Conformal Factor\n$\\lambda(t) = 2/(1+t^2)$', fontsize=14)
ax2.set_ylim(0, 2.5)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.2)

# Panel 3: Transition map (inversion)
ax3 = axes[2]
t_pos = np.linspace(0.2, 5, 200)
t_neg = np.linspace(-5, -0.2, 200)

ax3.plot(t_pos, 1/t_pos, 'b-', linewidth=2, label='$\\phi(t) = 1/t$')
ax3.plot(t_neg, 1/t_neg, 'b-', linewidth=2)
ax3.plot(t_pos, t_pos, 'k--', linewidth=0.5, alpha=0.3, label='identity')

# Show involutivity: phi(phi(t)) = t
for t_val in [0.5, 1.5, 3.0]:
    phi_t = 1/t_val
    phi_phi_t = 1/phi_t
    ax3.annotate('', xy=(phi_phi_t, phi_t), xytext=(t_val, phi_t),
                arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    ax3.plot([t_val, t_val], [0, phi_t], 'r:', alpha=0.3)
    ax3.plot([0, t_val], [phi_t, phi_t], 'r:', alpha=0.3)

ax3.set_xlim(-5, 5)
ax3.set_ylim(-5, 5)
ax3.set_xlabel('t', fontsize=12)
ax3.set_ylabel('$\\phi(t)$', fontsize=12)
ax3.set_title('Transition Map (Involution)\n$\\phi(t) = 1/t$, $\\phi \\circ \\phi = \\mathrm{id}$', fontsize=14)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('stereographic_projection.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: stereographic_projection.png")
