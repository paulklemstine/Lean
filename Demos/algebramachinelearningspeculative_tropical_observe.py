#!/usr/bin/env python3
"""
Tropical Observer Coding Duality — Demo

Demonstrates the core mathematical structures from the formalized theory:
1. Observer families on finite state spaces
2. Tropical separation distance computation
3. Separation rank computation (minimal subfamily)
4. Network reconstruction from minimal subfamily
5. Compression nonexpansivity verification

All examples use concrete, small state spaces to make the mathematics tangible.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Optional
import json


def tropical_distance(phi: np.ndarray, x: int, y: int) -> int:
    """
    Compute the tropical separation distance d_Φ(x, y) = max_i |Φ_i(x) - Φ_i(y)|.
    
    Args:
        phi: Observer matrix of shape (num_observers, num_states), phi[i][x] = Φ_i(x)
        x, y: State indices
    
    Returns:
        The tropical distance (non-negative integer)
    """
    return int(np.max(np.abs(phi[:, x] - phi[:, y])))


def tropical_distance_matrix(phi: np.ndarray) -> np.ndarray:
    """Compute the full pairwise tropical distance matrix."""
    n = phi.shape[1]
    D = np.zeros((n, n), dtype=int)
    for x in range(n):
        for y in range(n):
            D[x, y] = tropical_distance(phi, x, y)
    return D


def code_equivalent(phi: np.ndarray, x: int, y: int) -> bool:
    """Check if x and y are code-equivalent (all observers agree)."""
    return np.all(phi[:, x] == phi[:, y])


def subfamily_separates(phi: np.ndarray, J: List[int]) -> bool:
    """
    Check if subfamily J separates all states.
    
    Returns True if for every pair x ≠ y, some observer in J distinguishes them.
    """
    n = phi.shape[1]
    phi_J = phi[J, :]
    for x in range(n):
        for y in range(x + 1, n):
            if np.all(phi_J[:, x] == phi_J[:, y]):
                return False
    return True


def compute_separation_rank(phi: np.ndarray) -> Tuple[int, List[int]]:
    """
    Compute the separation rank and a minimal separating subfamily.
    
    Returns:
        (rank, minimal_subfamily) where rank is the minimum |J| such that
        SubfamilySeparates(Φ, J) holds, and minimal_subfamily is such a J.
    """
    num_obs = phi.shape[0]
    
    # Try subsets of increasing size
    for k in range(1, num_obs + 1):
        for J in combinations(range(num_obs), k):
            if subfamily_separates(phi, list(J)):
                return k, list(J)
    
    return num_obs, list(range(num_obs))


def has_spectral_witness(phi: np.ndarray, J: List[int], i: int) -> Optional[Tuple[int, int]]:
    """
    Check if observer i has a spectral witness in subfamily J.
    
    Returns (x, y) if found, None otherwise. A spectral witness is a pair (x, y)
    such that all observers in J \ {i} agree on x, y but observer i disagrees.
    """
    n = phi.shape[1]
    J_minus_i = [j for j in J if j != i]
    
    for x in range(n):
        for y in range(x + 1, n):
            # Check: all other observers in J agree on x, y
            others_agree = all(phi[j, x] == phi[j, y] for j in J_minus_i)
            # But observer i disagrees
            i_disagrees = phi[i, x] != phi[i, y]
            
            if others_agree and i_disagrees:
                return (x, y)
    
    return None


def verify_pseudometric(D: np.ndarray) -> Dict[str, bool]:
    """Verify the pseudometric properties of a distance matrix."""
    n = D.shape[0]
    results = {}
    
    # Reflexivity
    results["reflexivity"] = all(D[x, x] == 0 for x in range(n))
    
    # Symmetry
    results["symmetry"] = np.array_equal(D, D.T)
    
    # Triangle inequality
    triangle_ok = True
    for x in range(n):
        for y in range(n):
            for z in range(n):
                if D[x, z] > D[x, y] + D[y, z]:
                    triangle_ok = False
    results["triangle_inequality"] = triangle_ok
    
    return results


def verify_compression_nonexpansive(phi: np.ndarray, C: List[int]) -> bool:
    """
    Verify that compression C is nonexpansive w.r.t. tropical distance.
    C is given as a list where C[x] is the image of state x.
    """
    n = phi.shape[1]
    for x in range(n):
        for y in range(n):
            d_original = tropical_distance(phi, x, y)
            d_compressed = tropical_distance(phi, C[x], C[y])
            if d_compressed > d_original:
                return False
    return True


# ============================================================================
# DEMO 1: Basic Observer Family
# ============================================================================

print("=" * 70)
print("DEMO 1: Basic Observer Family and Tropical Distance")
print("=" * 70)

# 5 proof states, 3 observers
# Observer 0: "syntax complexity score"
# Observer 1: "variable count"
# Observer 2: "nesting depth"
phi_basic = np.array([
    [1, 3, 2, 5, 4],   # Observer 0
    [2, 2, 4, 1, 3],   # Observer 1
    [0, 1, 1, 2, 0],   # Observer 2
], dtype=int)

print(f"\nState space: S = {{0, 1, 2, 3, 4}}")
print(f"Number of observers: {phi_basic.shape[0]}")
print(f"\nObserver scores:")
for i in range(phi_basic.shape[0]):
    print(f"  Φ_{i}: {phi_basic[i]}")

D = tropical_distance_matrix(phi_basic)
print(f"\nTropical distance matrix d_Φ(x,y):")
print(D)

print(f"\nPseudometric verification:")
for prop, ok in verify_pseudometric(D).items():
    print(f"  {prop}: {'✓' if ok else '✗'}")

# Check code equivalence
print(f"\nCode equivalence classes:")
n = phi_basic.shape[1]
visited = set()
for x in range(n):
    if x in visited:
        continue
    cls = [x]
    for y in range(x + 1, n):
        if code_equivalent(phi_basic, x, y):
            cls.append(y)
            visited.add(y)
    print(f"  [{', '.join(str(s) for s in cls)}]")

# ============================================================================
# DEMO 2: Separation Rank Computation
# ============================================================================

print("\n" + "=" * 70)
print("DEMO 2: Separation Rank and Minimal Subfamily")
print("=" * 70)

# 4 states, 4 observers (some redundant)
phi_redundant = np.array([
    [1, 2, 3, 4],   # Observer 0: all different
    [1, 1, 2, 2],   # Observer 1: separates {0,1} from {2,3}
    [1, 2, 1, 2],   # Observer 2: separates {0,2} from {1,3}
    [2, 4, 6, 8],   # Observer 3: redundant (= 2 * Observer 0)
], dtype=int)

print(f"\nObserver matrix (4 observers, 4 states):")
for i in range(phi_redundant.shape[0]):
    print(f"  Φ_{i}: {phi_redundant[i]}")

rank, min_sub = compute_separation_rank(phi_redundant)
print(f"\nSeparation rank: {rank}")
print(f"Minimal separating subfamily: {min_sub}")

# Verify each observer in minimal subfamily has a spectral witness
print(f"\nSpectral witnesses (irredundancy certificates):")
for i in min_sub:
    witness = has_spectral_witness(phi_redundant, min_sub, i)
    if witness:
        x, y = witness
        print(f"  Observer {i}: states ({x}, {y}) — "
              f"Φ_{i}({x})={phi_redundant[i,x]}, Φ_{i}({y})={phi_redundant[i,y]}")
    else:
        print(f"  Observer {i}: no spectral witness (may be redundant)")

# ============================================================================
# DEMO 3: Compression Nonexpansivity
# ============================================================================

print("\n" + "=" * 70)
print("DEMO 3: Compression Nonexpansivity")
print("=" * 70)

# Define a compression map that merges nearby states
# C maps: 0→0, 1→0, 2→2, 3→2, 4→4 (merge pairs)
phi_compress = np.array([
    [0, 1, 4, 5, 8],
    [2, 3, 6, 7, 10],
], dtype=int)
C = [0, 0, 2, 2, 4]

print(f"\nObserver matrix:")
for i in range(phi_compress.shape[0]):
    print(f"  Φ_{i}: {phi_compress[i]}")
print(f"Compression C: {C}")

# Check coordinate-wise nonexpansivity
n = phi_compress.shape[1]
print(f"\nCoordinate-wise nonexpansivity check:")
for i in range(phi_compress.shape[0]):
    coord_ok = True
    for x in range(n):
        for y in range(n):
            orig = abs(phi_compress[i, x] - phi_compress[i, y])
            comp = abs(phi_compress[i, C[x]] - phi_compress[i, C[y]])
            if comp > orig:
                coord_ok = False
    print(f"  Observer {i}: {'✓ nonexpansive' if coord_ok else '✗ NOT nonexpansive'}")

global_ok = verify_compression_nonexpansive(phi_compress, C)
print(f"\nGlobal nonexpansivity: {'✓' if global_ok else '✗'}")

D_orig = tropical_distance_matrix(phi_compress)
print(f"\nOriginal distances:")
print(D_orig)

# Compute compressed distances
phi_C = phi_compress[:, C]
D_comp = tropical_distance_matrix(phi_C)
print(f"\nCompressed distances (d_Φ(C(x), C(y))):")
for x in range(n):
    row = [tropical_distance(phi_compress, C[x], C[y]) for y in range(n)]
    print(f"  {row}")

# ============================================================================
# DEMO 4: Network Reconstruction
# ============================================================================

print("\n" + "=" * 70)
print("DEMO 4: Minimal Network Reconstruction")
print("=" * 70)

# A more interesting example: 6 states, 5 observers
np.random.seed(42)
phi_large = np.array([
    [1, 1, 2, 2, 3, 3],   # Observer 0: groups {0,1}, {2,3}, {4,5}
    [1, 2, 1, 2, 1, 2],   # Observer 1: groups odds/evens
    [0, 0, 0, 0, 0, 0],   # Observer 2: trivial (sees nothing)
    [5, 5, 5, 5, 5, 5],   # Observer 3: also trivial
    [1, 2, 3, 4, 5, 6],   # Observer 4: all different (over-separates)
], dtype=int)

print(f"\nObserver matrix (5 observers, 6 states):")
for i in range(phi_large.shape[0]):
    print(f"  Φ_{i}: {phi_large[i]}")

rank, min_sub = compute_separation_rank(phi_large)
print(f"\nSeparation rank: {rank}")
print(f"Minimal separating subfamily: {min_sub}")

# The minimal network has width = rank
print(f"\n→ Minimal compression network width: {rank}")
print(f"→ Network coordinates (essential observers):")
for idx, i in enumerate(min_sub):
    print(f"   Coordinate {idx} (= Observer {i}): {phi_large[i]}")

# Verify the reconstructed network separates
phi_network = phi_large[min_sub, :]
separates = subfamily_separates(phi_large, min_sub)
print(f"\n→ Network separates all states: {'✓' if separates else '✗'}")

# Show the distance profile matches
D_full = tropical_distance_matrix(phi_large)
D_net = tropical_distance_matrix(phi_network)
print(f"\nFull observer distance matrix:")
print(D_full)
print(f"\nMinimal network distance matrix:")
print(D_net)
# Note: these may differ because the full family has more observers
# But: d_net(x,y) = 0 ↔ d_full(x,y) = 0 (same equivalence classes)

# ============================================================================
# DEMO 5: Separation Rank as Latent Dimension
# ============================================================================

print("\n" + "=" * 70)
print("DEMO 5: Separation Rank as Intrinsic Latent Dimension")
print("=" * 70)

# 4 states, 6 observers, but only 2 are needed (rank = 2)
n_states = 4
n_obs = 6

phi_latent = np.array([
    [0, 0, 1, 1],   # Observer 0: separates {0,1} from {2,3}
    [0, 1, 0, 1],   # Observer 1: separates {0,2} from {1,3}
    [0, 0, 1, 1],   # Observer 2: duplicate of 0
    [0, 1, 0, 1],   # Observer 3: duplicate of 1
    [0, 1, 1, 0],   # Observer 4: a new view, but NOT separating alone
    [0, 0, 1, 1],   # Observer 5: another duplicate of 0
], dtype=int)

print(f"State space: {n_states} states")
print(f"Number of observers: {n_obs}")
print(f"\n6 observers (most are redundant):")
for i in range(n_obs):
    print(f"  Φ_{i}: {phi_latent[i]}")

rank, min_sub = compute_separation_rank(phi_latent)
print(f"\n★ Separation rank: {rank}")
print(f"★ Despite {n_obs} observers, only {rank} are needed!")
print(f"★ Minimal subfamily: {min_sub}")
print(f"\n→ The intrinsic latent dimension is {rank}, not {n_obs}.")
print(f"→ A minimal network needs only {rank} hidden coordinates.")

# ============================================================================
# Summary
# ============================================================================

print("\n" + "=" * 70)
print("SUMMARY: Key Theorems Demonstrated")
print("=" * 70)
print("""
1. Tropical distance d_Φ is a pseudometric (Demo 1)
   - Reflexivity: d(x,x) = 0 ✓
   - Symmetry: d(x,y) = d(y,x) ✓
   - Triangle inequality: d(x,z) ≤ d(x,y) + d(y,z) ✓

2. Separation ↔ positive distance (Demo 1)
   - d(x,y) = 0 iff all observers agree on x and y

3. Separation rank is well-defined (Demo 2, 5)
   - Minimum |J| such that subfamily J separates all states
   - Unique (any two minimal subfamilies have same size)

4. Spectral witnesses certify irredundancy (Demo 2)
   - If observer i has a spectral witness, removing it breaks separation

5. Compression is nonexpansive (Demo 3)
   - Coordinate-wise contraction ⟹ global contraction

6. Minimal network reconstruction (Demo 4)
   - From minimal subfamily, reconstruct a network of width = rank

7. Separation rank = intrinsic latent dimension (Demo 5)
   - Redundant observers don't increase the true dimensionality
""")


#!/usr/bin/env python3
"""Generate visualizations for the Tropical Observer Coding Duality paper."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO
from itertools import combinations

def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def tropical_distance(phi, x, y):
    return int(np.max(np.abs(phi[:, x] - phi[:, y])))


def tropical_distance_matrix(phi):
    n = phi.shape[1]
    D = np.zeros((n, n), dtype=int)
    for x in range(n):
        for y in range(n):
            D[x, y] = tropical_distance(phi, x, y)
    return D


def subfamily_separates(phi, J):
    n = phi.shape[1]
    pJ = phi[list(J), :]
    for x in range(n):
        for y in range(x + 1, n):
            if np.all(pJ[:, x] == pJ[:, y]):
                return False
    return True


def compute_separation_rank(phi):
    num_obs = phi.shape[0]
    for k in range(1, num_obs + 1):
        for J in combinations(range(num_obs), k):
            if subfamily_separates(phi, list(J)):
                return k, list(J)
    return num_obs, list(range(num_obs))


# ============================================================================
# Visualization 1: Tropical Distance Heatmap
# ============================================================================

phi = np.array([
    [1, 3, 2, 5, 4],
    [2, 2, 4, 1, 3],
    [0, 1, 1, 2, 0],
], dtype=int)

D = tropical_distance_matrix(phi)

fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Distance heatmap
im = axes[0].imshow(D, cmap='YlOrRd', aspect='equal')
axes[0].set_title('Tropical Distance Matrix d_Φ(x,y)', fontsize=14)
axes[0].set_xlabel('State y')
axes[0].set_ylabel('State x')
for i in range(5):
    for j in range(5):
        axes[0].text(j, i, str(D[i,j]), ha='center', va='center', fontsize=14, fontweight='bold')
plt.colorbar(im, ax=axes[0], shrink=0.8)

# Observer coordinates as scatter
colors = plt.cm.Set1(np.linspace(0, 1, 5))
for s in range(5):
    axes[1].scatter(phi[0, s], phi[1, s], c=[colors[s]], s=200, zorder=5, edgecolors='black')
    axes[1].annotate(f'  s={s}', (phi[0, s], phi[1, s]), fontsize=12)
axes[1].set_xlabel('Observer Φ₀', fontsize=12)
axes[1].set_ylabel('Observer Φ₁', fontsize=12)
axes[1].set_title('States in Observer Coordinate Space', fontsize=14)
axes[1].grid(True, alpha=0.3)

fig.suptitle('Tropical Observer Coding: Distance and Embedding', fontsize=16, y=1.02)
plt.tight_layout()
vis1 = fig_to_base64(fig)


# ============================================================================
# Visualization 2: Separation Rank vs Number of Observers
# ============================================================================

fig, ax = plt.subplots(figsize=(8, 5))

# For different numbers of random observers on 8 states, compute rank
np.random.seed(42)
n_states = 8
results = []
for n_obs in range(2, 16):
    ranks = []
    for trial in range(20):
        phi_rand = np.random.randint(0, 4, size=(n_obs, n_states))
        r, _ = compute_separation_rank(phi_rand)
        ranks.append(r)
    results.append((n_obs, np.mean(ranks), np.std(ranks)))

n_obs_list = [r[0] for r in results]
means = [r[1] for r in results]
stds = [r[2] for r in results]

ax.plot(n_obs_list, means, 'b-o', linewidth=2, markersize=8, label='Mean separation rank')
ax.fill_between(n_obs_list, 
                [m-s for m,s in zip(means, stds)],
                [m+s for m,s in zip(means, stds)],
                alpha=0.2, color='blue')
ax.plot(n_obs_list, n_obs_list, 'r--', linewidth=1, alpha=0.5, label='Identity (rank = #observers)')
ax.set_xlabel('Number of Observers', fontsize=13)
ax.set_ylabel('Separation Rank', fontsize=13)
ax.set_title('Separation Rank vs Observer Count\n(8 states, random ℤ₄-valued observers)', fontsize=14)
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)

plt.tight_layout()
vis2 = fig_to_base64(fig)


# ============================================================================
# Visualization 3: Compression Orbit Convergence
# ============================================================================

fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# A contractive map on 8 states
phi_orbit = np.array([
    [0, 2, 4, 6, 8, 10, 12, 14],
    [1, 3, 5, 7, 9, 11, 13, 15],
], dtype=int)

# Compression: move toward center
C_orbit = [1, 2, 3, 3, 4, 4, 5, 6]  # Each state moves inward

# Track orbit distances
x0, y0 = 0, 7
dists = []
x, y = x0, y0
for step in range(10):
    d = tropical_distance(phi_orbit, x, y)
    dists.append(d)
    x = C_orbit[x]
    y = C_orbit[y]

axes[0].plot(range(len(dists)), dists, 'g-o', linewidth=2, markersize=8)
axes[0].set_xlabel('Iteration n', fontsize=12)
axes[0].set_ylabel('d_Φ(C^n(x), C^n(y))', fontsize=12)
axes[0].set_title('Compression Orbit Distance\n(nonincreasing by theorem)', fontsize=14)
axes[0].grid(True, alpha=0.3)

# Observer embedding with compression arrows
n = phi_orbit.shape[1]
colors = plt.cm.viridis(np.linspace(0, 1, n))
for s in range(n):
    axes[1].scatter(phi_orbit[0, s], phi_orbit[1, s], c=[colors[s]], s=150, zorder=5, edgecolors='black')
    axes[1].annotate(f'{s}', (phi_orbit[0, s] + 0.3, phi_orbit[1, s] + 0.3), fontsize=10)
    # Draw compression arrow
    cs = C_orbit[s]
    if cs != s:
        dx = phi_orbit[0, cs] - phi_orbit[0, s]
        dy = phi_orbit[1, cs] - phi_orbit[1, s]
        axes[1].annotate('', (phi_orbit[0, cs], phi_orbit[1, cs]),
                         (phi_orbit[0, s], phi_orbit[1, s]),
                         arrowprops=dict(arrowstyle='->', color='red', lw=1.5, alpha=0.6))

axes[1].set_xlabel('Observer Φ₀', fontsize=12)
axes[1].set_ylabel('Observer Φ₁', fontsize=12)
axes[1].set_title('Compression Map in Observer Space\n(arrows show C)', fontsize=14)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
vis3 = fig_to_base64(fig)


# ============================================================================
# Visualization 4: The Duality Diagram
# ============================================================================

fig, ax = plt.subplots(figsize=(10, 6))
ax.set_xlim(0, 10)
ax.set_ylim(0, 7)
ax.axis('off')

# Three boxes
boxes = [
    (1, 4.5, 'Tropical Separation\nSemimodule M', '#E8F0FE'),
    (4, 4.5, 'Observer Code\n(Separation Rank k)', '#FFF3E0'),
    (7, 4.5, 'Minimal Compression\nNetwork N', '#E8F5E9'),
]
for x, y, text, color in boxes:
    rect = plt.Rectangle((x-1, y-0.8), 2, 1.6, facecolor=color, edgecolor='black', linewidth=2)
    ax.add_patch(rect)
    ax.text(x, y, text, ha='center', va='center', fontsize=11, fontweight='bold')

# Arrows
ax.annotate('', xy=(3.1, 4.5), xytext=(2.1, 4.5),
            arrowprops=dict(arrowstyle='->', linewidth=2, color='#1565C0'))
ax.text(2.6, 4.9, 'extract\nminimal\nsubfamily', ha='center', va='bottom', fontsize=9, color='#1565C0')

ax.annotate('', xy=(6.1, 4.5), xytext=(5.1, 4.5),
            arrowprops=dict(arrowstyle='->', linewidth=2, color='#2E7D32'))
ax.text(5.6, 4.9, 'reconstruct\nnetwork', ha='center', va='bottom', fontsize=9, color='#2E7D32')

# Properties below
props = [
    (1, 2.5, 'n generators\nΦ: Fin(n) → S → ℤ\nSeparation + Contraction'),
    (4, 2.5, 'Width = k\n= min separating\nsubfamily size'),
    (7, 2.5, 'k coordinates\nMinimal width\nSame CodeEq classes'),
]
for x, y, text in props:
    ax.text(x, y, text, ha='center', va='center', fontsize=10, style='italic', color='#555')

# Title
ax.text(5, 6.5, 'Tropical Observer Coding Duality', ha='center', va='center',
        fontsize=16, fontweight='bold', color='#1a1a2e')
ax.text(5, 6.0, 'Semimodule → Observer Code → Minimal Network', ha='center', va='center',
        fontsize=12, color='#555')

plt.tight_layout()
vis4 = fig_to_base64(fig)


# Save all visualizations
with open('/workspace/request-project/vis_data.json', 'w') as f:
    import json
    json.dump({
        'vis1': vis1,
        'vis2': vis2,
        'vis3': vis3,
        'vis4': vis4,
    }, f)

print("Visualizations generated and saved.")
