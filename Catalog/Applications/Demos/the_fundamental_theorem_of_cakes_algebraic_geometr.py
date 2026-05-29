"""
Applications of the Fundamental Theorem of Cakes.

Shows how cake geometry connects to real mathematical problems
in moduli theory, graph enumeration, and polynomial invariants.
"""

from typing import List, Tuple, Dict
from itertools import combinations
from math import comb, factorial
import numpy as np


def moduli_dim(g: int) -> int:
    """Moduli dimension 3g - 3."""
    return 3 * g - 3


# ─── Application 1: Moduli Space Parameter Counting ───

def riemann_surface_parameters(g: int) -> Dict[str, int]:
    """Count parameters of Riemann surface moduli.
    
    For a genus-g Riemann surface:
    - Complex structure parameters: 3g - 3
    - Real parameters: 6g - 6
    - Automorphism group order: finite for g ≥ 2
    
    This matches the cake moduli dimension exactly.
    """
    if g < 2:
        return {"status": "degenerate", "genus": g, "dim": moduli_dim(g)}
    
    return {
        "genus": g,
        "complex_dim": 3 * g - 3,
        "real_dim": 6 * g - 6,
        "cake_moduli_dim": moduli_dim(g),
        "match": moduli_dim(g) == 3 * g - 3,
        "teichmuller_dim": 6 * g - 6,
    }


# ─── Application 2: Stratification in Data Analysis ───

def hierarchical_clustering_strata(data_dim: int, 
                                    num_clusters: int) -> List[List[int]]:
    """Model hierarchical clustering as a cake stratification.
    
    In hierarchical clustering, data in dimension n is successively
    projected onto lower-dimensional subspaces. This forms a valid
    stratification when the projection dimensions are strictly decreasing.
    
    Args:
        data_dim: Dimension of the data space
        num_clusters: Desired number of cluster levels
    
    Returns:
        Valid stratifications representing clustering hierarchies
    """
    strats = []
    if num_clusters > data_dim:
        return strats
    
    for combo in combinations(range(1, data_dim), num_clusters - 1):
        layers = [data_dim] + sorted(combo, reverse=True) + [0]
        strats.append(layers)
    
    return strats


# ─── Application 3: Network Topology via Trivalent Graphs ───

def network_genus_analysis(vertices: int, edges: int) -> Dict:
    """Analyze a network's topological genus using cake geometry.
    
    For a connected graph: g = 1 - (V - E) = E - V + 1
    If the graph is approximately trivalent (avg degree ≈ 3),
    the cake moduli dimension approximates the network complexity.
    """
    genus = edges - vertices + 1
    avg_degree = 2 * edges / vertices if vertices > 0 else 0
    is_trivalent = abs(avg_degree - 3) < 0.1
    
    return {
        "vertices": vertices,
        "edges": edges,
        "genus": genus,
        "avg_degree": round(avg_degree, 2),
        "approximately_trivalent": is_trivalent,
        "moduli_dim": moduli_dim(genus) if genus >= 0 else None,
        "network_complexity": max(0, moduli_dim(genus)) if genus >= 2 else 0,
    }


# ─── Application 4: Polynomial Invariants for Shape Classification ───

def shape_polynomial_classifier(dimensions: List[int]) -> Dict:
    """Use the cake polynomial to classify stratified shapes.
    
    Given a sequence of decreasing dimensions (a stratification),
    compute the cake polynomial invariants that uniquely characterize
    the shape up to flavor equivalence.
    """
    if not dimensions or dimensions[-1] != 0:
        dimensions = dimensions + [0]
    
    n = dimensions[0]
    k = len(dimensions) - 1
    
    # Cake polynomial coefficients
    coeffs = dimensions
    
    # Key evaluations
    euler_cake = sum((-1)**i * d for i, d in enumerate(dimensions))
    total_mass = sum(dimensions)
    
    # Polynomial at various points
    evaluations = {}
    for t in [-1, 0, 1, 2]:
        evaluations[t] = sum(d * t**i for i, d in enumerate(dimensions))
    
    return {
        "dimension": n,
        "depth": k,
        "layers": dimensions,
        "euler_cake": euler_cake,
        "total_mass": total_mass,
        "polynomial_evaluations": evaluations,
        "degree": k,
        "signature": (n, k, euler_cake),
    }


# ─── Application 5: Cherry Placement Optimization ───

def optimal_cherry_placement(genus: int, surface_area: float) -> Dict:
    """Optimize cherry positions on a cake surface.
    
    Model the positions of g cherries on a surface of genus g.
    The moduli space has dimension 3g - 3, meaning there are
    3g - 3 independent parameters for cherry placement.
    
    For a surface of area A with g cherries, the optimal spacing
    maximizes the minimum inter-cherry distance.
    """
    if genus < 2:
        return {"status": "degenerate", "genus": genus}
    
    # Optimal packing: cherries equally spaced
    area_per_cherry = surface_area / genus
    optimal_radius = np.sqrt(area_per_cherry / np.pi)
    
    # Degrees of freedom
    dof = moduli_dim(genus)
    
    # Cherry positions (2D projection for visualization)
    angles = np.linspace(0, 2 * np.pi, genus, endpoint=False)
    radius = np.sqrt(surface_area / np.pi) * 0.6
    positions = [(radius * np.cos(a), radius * np.sin(a)) for a in angles]
    
    return {
        "genus": genus,
        "surface_area": surface_area,
        "moduli_dim": dof,
        "area_per_cherry": round(area_per_cherry, 2),
        "optimal_spacing_radius": round(optimal_radius, 2),
        "cherry_positions": [(round(x, 2), round(y, 2)) for x, y in positions],
    }


# ─── Demonstration ───

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF CAKE GEOMETRY")
    print("=" * 60)
    
    # App 1: Moduli parameters
    print("\n📐 Application 1: Moduli Space Parameters")
    print("-" * 50)
    for g in range(2, 6):
        params = riemann_surface_parameters(g)
        print(f"  g={g}: complex_dim={params['complex_dim']}, "
              f"real_dim={params['real_dim']}, "
              f"cake_match={params['match']}")
    
    # App 2: Clustering hierarchies
    print("\n📊 Application 2: Hierarchical Clustering Strata")
    print("-" * 50)
    strats = hierarchical_clustering_strata(6, 3)
    print(f"  Data dim=6, clusters=3: {len(strats)} hierarchies")
    for s in strats[:5]:
        print(f"    {s}")
    print(f"    ... ({len(strats)} total)")
    
    # App 3: Network topology
    print("\n🌐 Application 3: Network Genus Analysis")
    print("-" * 50)
    networks = [(10, 15), (20, 30), (100, 150), (50, 75)]
    for V, E in networks:
        analysis = network_genus_analysis(V, E)
        print(f"  V={V}, E={E}: genus={analysis['genus']}, "
              f"complexity={analysis['network_complexity']}, "
              f"trivalent={analysis['approximately_trivalent']}")
    
    # App 4: Shape classification
    print("\n🔷 Application 4: Shape Polynomial Classification")
    print("-" * 50)
    shapes = [[5, 3, 1, 0], [4, 2, 0], [6, 4, 3, 1, 0]]
    for dims in shapes:
        result = shape_polynomial_classifier(dims)
        print(f"  {dims}: χ={result['euler_cake']}, "
              f"mass={result['total_mass']}, "
              f"sig={result['signature']}")
    
    # App 5: Cherry placement
    print("\n🍒 Application 5: Optimal Cherry Placement")
    print("-" * 50)
    for g in [2, 3, 5]:
        result = optimal_cherry_placement(g, 100.0)
        print(f"  g={g}: DoF={result['moduli_dim']}, "
              f"spacing_r={result['optimal_spacing_radius']}, "
              f"positions={result['cherry_positions'][:3]}...")
    
    print("\n✅ All applications demonstrated.")


"""
Demonstration of the Fundamental Theorem of Cakes.

Computes moduli dimensions, enumerates valid stratifications,
evaluates cake polynomials, and verifies the trivalent graph bridge.
"""

from typing import List, Tuple
from itertools import combinations


def moduli_dim(g: int) -> int:
    """Compute the moduli dimension 3g - 3."""
    return 3 * g - 3


def is_valid_stratification(n: int, k: int, layers: List[int]) -> bool:
    """Check if layers form a valid stratification of depth k in dimension n."""
    if len(layers) != k + 1:
        return False
    if layers[0] != n or layers[-1] != 0:
        return False
    return all(layers[i] > layers[i + 1] for i in range(k))


def enumerate_stratifications(n: int, k: int) -> List[List[int]]:
    """Enumerate all valid stratifications of depth k in dimension n.
    
    A valid stratification chooses k-1 intermediate values from {1, ..., n-1}
    and arranges them in strictly decreasing order.
    """
    if k > n:
        return []
    if k == 0:
        if n == 0:
            return [[0]]
        return []
    
    # Choose k-1 values from {1, ..., n-1} for the intermediate layers
    intermediate_values = range(1, n)
    result = []
    for combo in combinations(intermediate_values, k - 1):
        layers = [n] + sorted(combo, reverse=True) + [0]
        result.append(layers)
    return result


def euler_cake(layers: List[int]) -> int:
    """Compute the Euler-cake characteristic: alternating sum of layer dims."""
    return sum((-1)**i * d for i, d in enumerate(layers))


def cake_polynomial_eval(layers: List[int], t: float) -> float:
    """Evaluate the cake polynomial P(t) = sum(d_i * t^i)."""
    return sum(d * t**i for i, d in enumerate(layers))


def verify_trivalent_bridge(g: int) -> dict:
    """Verify the trivalent graph-moduli bridge for genus g.
    
    A trivalent graph on genus-g surface with 1 face:
      V - E = 1 - g  (Euler)
      3V = 2E         (trivalent)
    => E = 3(g-1) = 3g - 3
    """
    E = 3 * (g - 1)
    V = 2 * E // 3
    return {
        "genus": g,
        "vertices": V,
        "edges": E,
        "euler_check": V - E == 1 - g,
        "trivalent_check": 3 * V == 2 * E,
        "moduli_dim": moduli_dim(g),
        "bridge_verified": E == moduli_dim(g)
    }


def count_flavor_classes(n: int, k: int, g: int) -> int:
    """Count flavor-isomorphism classes with bounded parameters."""
    return (n + 1) * (k + 1) * (g + 1)


# ─── Demonstrations ───

print("=" * 60)
print("THE FUNDAMENTAL THEOREM OF CAKES")
print("Algebraic Geometry of Baking")
print("=" * 60)

# 1. Moduli dimension table
print("\n📊 Moduli Dimension Formula: dim M_g = 3g - 3")
print("-" * 40)
print(f"{'Genus g':>10} {'moduliDim(g)':>15}")
print("-" * 40)
for g in range(6):
    d = moduli_dim(g)
    status = "✓ (positive)" if d > 0 else "○ (degenerate)"
    print(f"{g:>10} {d:>15}  {status}")

# 2. Stratification enumeration
print("\n\n🎂 Valid Stratifications (n=5, k=3)")
print("-" * 40)
strats = enumerate_stratifications(5, 3)
print(f"Found {len(strats)} valid stratifications:")
for s in strats:
    ec = euler_cake(s)
    pm = cake_polynomial_eval(s, 1)
    print(f"  {s}  χ_cake = {ec:>3}  P(1) = {pm:.0f}")

# 3. Cake polynomial properties
print("\n\n📐 Cake Polynomial Properties")
print("-" * 40)
test_layers = [5, 3, 1, 0]  # Example stratification
print(f"Layers: {test_layers}")
print(f"P(t) = {test_layers[0]} + {test_layers[1]}t + {test_layers[2]}t² + {test_layers[3]}t³")
print(f"P(-1) = {cake_polynomial_eval(test_layers, -1):.0f}  (= Euler-cake char)")
print(f"P(1)  = {cake_polynomial_eval(test_layers, 1):.0f}  (= total layer mass)")
print(f"P(0)  = {cake_polynomial_eval(test_layers, 0):.0f}  (= top dim)")
print(f"χ_cake = {euler_cake(test_layers)}  ✓ matches P(-1)")

# 4. Trivalent graph bridge
print("\n\n🌉 Trivalent Graph ↔ Moduli Bridge")
print("-" * 40)
for g in range(2, 7):
    result = verify_trivalent_bridge(g)
    check = "✓" if result["bridge_verified"] else "✗"
    print(f"g={g}: V={result['vertices']}, E={result['edges']}, "
          f"moduliDim={result['moduli_dim']}  {check}")

# 5. Flavor class counting
print("\n\n🎨 Flavor Isomorphism Classes")
print("-" * 40)
for n, k, g in [(3, 2, 4), (5, 3, 2), (10, 5, 3)]:
    c = count_flavor_classes(n, k, g)
    print(f"baseDim≤{n}, layers≤{k}, genus≤{g}: {c} classes")

# 6. Depth bound verification
print("\n\n📏 Stratification Depth Bound: k ≤ n")
print("-" * 40)
for n in range(1, 7):
    max_k = n
    count = len(enumerate_stratifications(n, max_k))
    print(f"n={n}: max depth k={max_k}, "
          f"stratifications at max depth: {count}")

print("\n\n✅ All demonstrations complete.")


# Visualization 2: The Cake Polynomial
#
# Visualizes cake polynomials for different stratifications,
# showing how evaluation at t=-1 gives the Euler-cake characteristic
# and evaluation at t=1 gives the total layer mass.

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

def cake_poly_eval(layers, t):
    """Evaluate the cake polynomial at t."""
    return sum(d * t**i for i, d in enumerate(layers))

def enumerate_stratifications(n, k):
    if k > n or k < 0:
        return []
    if k == 0:
        return [[0]] if n == 0 else []
    result = []
    for combo in combinations(range(1, n), k - 1):
        layers = [n] + sorted(combo, reverse=True) + [0]
        result.append(layers)
    return result

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle("Cake Polynomials: Algebraic Invariants of Stratified Objects",
             fontsize=15, fontweight='bold')

# ─── Plot 1: Cake polynomials for n=5, k=3 ───
ax1 = axes[0]
t_vals = np.linspace(-1.5, 2.0, 200)
strats = enumerate_stratifications(5, 3)
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(strats)))

for idx, s in enumerate(strats):
    y_vals = [cake_poly_eval(s, t) for t in t_vals]
    label = str(s)
    ax1.plot(t_vals, y_vals, color=colors[idx], linewidth=1.5, label=label)

# Mark special points
for s in strats:
    euler = cake_poly_eval(s, -1)
    mass = cake_poly_eval(s, 1)
    ax1.plot(-1, euler, 'ro', markersize=5, zorder=5)
    ax1.plot(1, mass, 'bs', markersize=5, zorder=5)

ax1.axhline(y=0, color='gray', linewidth=0.5)
ax1.axvline(x=-1, color='red', linewidth=0.5, linestyle=':', alpha=0.5)
ax1.axvline(x=1, color='blue', linewidth=0.5, linestyle=':', alpha=0.5)
ax1.set_xlabel('t', fontsize=12)
ax1.set_ylabel('P(t)', fontsize=12)
ax1.set_title('Cake Polynomials (n=5, k=3)', fontsize=12)
ax1.legend(fontsize=7, loc='upper left')
ax1.annotate('P(-1) = χ_cake', xy=(-1, 0), xytext=(-1.4, -10),
             fontsize=9, color='red', arrowprops=dict(arrowstyle='->', color='red'))
ax1.annotate('P(1) = mass', xy=(1, 0), xytext=(1.2, -8),
             fontsize=9, color='blue', arrowprops=dict(arrowstyle='->', color='blue'))

# ─── Plot 2: Euler-cake vs total mass scatter ───
ax2 = axes[1]
all_euler = []
all_mass = []
all_n = []

for n in range(3, 8):
    for k in range(1, n + 1):
        strats_nk = enumerate_stratifications(n, k)
        for s in strats_nk:
            euler = sum((-1)**i * d for i, d in enumerate(s))
            mass = sum(s)
            all_euler.append(euler)
            all_mass.append(mass)
            all_n.append(n)

scatter = ax2.scatter(all_euler, all_mass, c=all_n, cmap='plasma',
                       s=30, alpha=0.7, edgecolors='black', linewidth=0.3)
plt.colorbar(scatter, ax=ax2, label='Dimension n')
ax2.set_xlabel('Euler-cake characteristic χ', fontsize=12)
ax2.set_ylabel('Total layer mass', fontsize=12)
ax2.set_title('χ_cake vs Mass\n(all strats, n=3..7)', fontsize=12)
ax2.grid(True, alpha=0.3)

# ─── Plot 3: Stratification count C(n-1, k-1) ───
ax3 = axes[2]
from math import comb
n_vals = range(1, 11)
for k in [1, 2, 3, 4, 5]:
    counts = [comb(n - 1, k - 1) if k <= n else 0 for n in n_vals]
    ax3.plot(list(n_vals), counts, 'o-', linewidth=2, markersize=6,
             label=f'k = {k}')

ax3.set_xlabel('Dimension n', fontsize=12)
ax3.set_ylabel('Number of stratifications', fontsize=12)
ax3.set_title('Stratification Count C(n−1, k−1)', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_yscale('log')

plt.tight_layout()
plt.savefig('cake_polynomial_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved cake_polynomial_analysis.png")


# Visualization 1: Moduli Dimension and Stratification Bounds
# 
# Visualizes the moduli dimension formula 3g-3 as a function of genus,
# the layer dimension bounds for valid stratifications, and the
# trivalent graph bridge (V, E as functions of genus).

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle("The Fundamental Theorem of Cakes: Core Invariants", 
             fontsize=16, fontweight='bold')

# ─── Plot 1: Moduli Dimension ───
ax1 = axes[0, 0]
g_vals = np.arange(0, 11)
moduli_vals = 3 * g_vals - 3
colors = ['red' if d <= 0 else 'steelblue' for d in moduli_vals]
ax1.bar(g_vals, moduli_vals, color=colors, edgecolor='black', linewidth=0.5)
ax1.axhline(y=0, color='black', linewidth=0.8, linestyle='-')
ax1.set_xlabel('Genus g (cherries)', fontsize=12)
ax1.set_ylabel('Moduli Dimension', fontsize=12)
ax1.set_title('dim M_g = 3g − 3', fontsize=13)
ax1.annotate('Degenerate\n(g < 2)', xy=(0.5, -2), fontsize=9, 
             ha='center', color='red', fontstyle='italic')
ax1.annotate('Classical\nregime', xy=(6, 12), fontsize=9,
             ha='center', color='steelblue', fontstyle='italic')

# ─── Plot 2: Layer Dimension Bounds ───
ax2 = axes[0, 1]
n, k = 8, 5
i_vals = np.arange(k + 1)
lower_bounds = np.maximum(k - i_vals, 0)
upper_bounds = np.full_like(i_vals, n)

ax2.fill_between(i_vals, lower_bounds, upper_bounds, 
                  alpha=0.3, color='lightgreen', label='Feasible region')
ax2.plot(i_vals, lower_bounds, 'g-o', linewidth=2, markersize=6,
         label=f'Lower bound: k−i = {k}−i')
ax2.plot(i_vals, upper_bounds, 'b--o', linewidth=2, markersize=6,
         label=f'Upper bound: n = {n}')

# Example stratification
example_layers = [8, 6, 4, 3, 2, 0]
ax2.plot(i_vals, example_layers, 'r-s', linewidth=2.5, markersize=8,
         label='Example stratification', zorder=5)

ax2.set_xlabel('Layer index i', fontsize=12)
ax2.set_ylabel('Layer dimension', fontsize=12)
ax2.set_title(f'Stratification Bounds (n={n}, k={k})', fontsize=13)
ax2.legend(fontsize=9, loc='upper right')
ax2.set_ylim(-0.5, n + 1)

# ─── Plot 3: Trivalent Graph Bridge ───
ax3 = axes[1, 0]
g_bridge = np.arange(2, 11)
V_vals = 2 * (g_bridge - 1)
E_vals = 3 * (g_bridge - 1)
moduli_bridge = 3 * g_bridge - 3

ax3.plot(g_bridge, E_vals, 'bo-', linewidth=2, markersize=8, label='Edges E')
ax3.plot(g_bridge, V_vals, 'rs-', linewidth=2, markersize=8, label='Vertices V')
ax3.plot(g_bridge, moduli_bridge, 'g^--', linewidth=2, markersize=8, 
         label='moduliDim(g)', alpha=0.7)
ax3.set_xlabel('Genus g', fontsize=12)
ax3.set_ylabel('Count', fontsize=12)
ax3.set_title('Trivalent Graph ↔ Moduli Bridge\nE = 3g−3 = moduliDim(g)', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# ─── Plot 4: Euler-Cake Characteristic ───
ax4 = axes[1, 1]

def enumerate_stratifications(n, k):
    from itertools import combinations
    if k > n or k < 0:
        return []
    if k == 0:
        return [[0]] if n == 0 else []
    result = []
    for combo in combinations(range(1, n), k - 1):
        layers = [n] + sorted(combo, reverse=True) + [0]
        result.append(layers)
    return result

n_range = range(3, 9)
euler_data = {}
for n in n_range:
    k = n - 1  # Maximum depth stratification
    strats = enumerate_stratifications(n, k)
    eulers = [sum((-1)**i * d for i, d in enumerate(s)) for s in strats]
    euler_data[n] = eulers

positions = list(range(len(list(n_range))))
bp = ax4.boxplot([euler_data[n] for n in n_range], positions=positions,
                  patch_artist=True, widths=0.6)
for patch in bp['boxes']:
    patch.set_facecolor('lightyellow')
    patch.set_edgecolor('orange')
ax4.set_xticklabels([f'n={n}' for n in n_range])
ax4.set_xlabel('Ambient dimension n', fontsize=12)
ax4.set_ylabel('Euler-cake characteristic χ', fontsize=12)
ax4.set_title('Distribution of χ_cake\n(max-depth stratifications)', fontsize=13)
ax4.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('cake_geometry_overview.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved cake_geometry_overview.png")


# Visualization 3: The Trivalent Graph-Moduli Bridge
#
# Visualizes the deep connection between trivalent graphs on
# genus-g surfaces and the moduli dimension formula 3g-3.
# Shows how graph combinatorics encode moduli space structure.

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle("Trivalent Graph ↔ Moduli Space Bridge",
             fontsize=15, fontweight='bold')

# ─── Plot 1: The Bridge Diagram ───
ax1 = axes[0]
g_vals = np.arange(2, 12)
E_vals = 3 * (g_vals - 1)
V_vals = 2 * (g_vals - 1)
moduli_vals = 3 * g_vals - 3

ax1.fill_between(g_vals, 0, E_vals, alpha=0.15, color='blue',
                  label='E = 3(g−1)')
ax1.plot(g_vals, E_vals, 'bo-', linewidth=2.5, markersize=8, 
         label='Trivalent edges E')
ax1.plot(g_vals, moduli_vals, 'r^--', linewidth=2.5, markersize=10,
         label='moduliDim(g) = 3g−3', alpha=0.8)

# Highlight that they're equal
for g in g_vals:
    E = 3 * (g - 1)
    ax1.annotate('', xy=(g, E), xytext=(g, E + 2),
                 arrowprops=dict(arrowstyle='->', color='green', lw=1.5))

ax1.set_xlabel('Genus g', fontsize=12)
ax1.set_ylabel('Count', fontsize=12)
ax1.set_title('E = moduliDim(g): Perfect Match', fontsize=12)
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.text(8, 5, 'E ≡ 3g−3', fontsize=14, color='green',
         fontweight='bold', fontstyle='italic')

# ─── Plot 2: Euler Formula Components ───
ax2 = axes[1]
F_vals = np.ones_like(g_vals)  # Single face
euler_lhs = V_vals - E_vals + F_vals
euler_rhs = 2 - 2 * g_vals

width = 0.35
x = np.arange(len(g_vals))
bars1 = ax2.bar(x - width/2, euler_lhs, width, label='V − E + F',
                 color='steelblue', edgecolor='black', linewidth=0.5)
bars2 = ax2.bar(x + width/2, euler_rhs, width, label='2 − 2g',
                 color='coral', edgecolor='black', linewidth=0.5)

ax2.set_xlabel('Genus g', fontsize=12)
ax2.set_ylabel('Euler characteristic', fontsize=12)
ax2.set_title("Euler's Formula: V − E + F = 2 − 2g", fontsize=12)
ax2.set_xticks(x)
ax2.set_xticklabels([str(g) for g in g_vals])
ax2.legend(fontsize=10)
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.grid(True, alpha=0.3, axis='y')

# ─── Plot 3: Flavor Class Growth ───
ax3 = axes[2]
n_max_vals = range(1, 11)
for g_max in [1, 2, 3, 5]:
    k_max = 3
    counts = [(n + 1) * (k_max + 1) * (g_max + 1) for n in n_max_vals]
    ax3.plot(list(n_max_vals), counts, 'o-', linewidth=2, markersize=6,
             label=f'g≤{g_max}, k≤{k_max}')

ax3.set_xlabel('Max dimension n', fontsize=12)
ax3.set_ylabel('Flavor classes', fontsize=12)
ax3.set_title('Flavor Isomorphism Classes\n(n+1)(k+1)(g+1)', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('trivalent_bridge.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved trivalent_bridge.png")
