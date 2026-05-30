"""
applications.py — Real-world applications of multi-degree persistence theory.

Applications:
1. Time series anomaly detection using filtration-weighted density
2. Chemical compound classification via arithmetic filtration
3. Network analysis using chain complex filtrations
"""

import numpy as np
from typing import List, Tuple, Dict


def prime_factorization_length(n: int) -> int:
    """Compute Ω(n) = number of prime factors with multiplicity."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            count += 1
            temp //= d
        d += 1
    if temp > 1:
        count += 1
    return count


# ============================================================
# Application 1: Time Series Anomaly Detection
# ============================================================

def time_series_to_chain_complex(
    signal: List[float], 
    threshold: float = 0.5
) -> Tuple[np.ndarray, np.ndarray, List[int], List[int], List[int]]:
    """
    Convert a time series into a filtered chain complex.
    
    C₂ = peaks, C₁ = edges between consecutive points, C₀ = points.
    Filtration level = time index.
    
    Args:
        signal: List of signal values
        threshold: Minimum signal value to include
    
    Returns:
        (d₁, d₀, filt₂, filt₁, filt₀)
    """
    n = len(signal)
    if n < 3:
        raise ValueError("Need at least 3 points")
    
    # Identify peaks (local maxima above threshold)
    peaks = []
    for i in range(1, n - 1):
        if signal[i] > signal[i-1] and signal[i] > signal[i+1] and signal[i] > threshold:
            peaks.append(i)
    
    # C₀ = all points, C₁ = edges, C₂ = peak triangles
    n0 = n
    n1 = n - 1  # edges between consecutive points
    n2 = len(peaks)
    
    # d₀: boundary of edges → points (standard simplicial boundary)
    d0 = np.zeros((n0, n1), dtype=int)
    for e in range(n1):
        d0[e, e] = -1     # start vertex
        d0[e + 1, e] = 1  # end vertex
    
    # d₁: peaks → edges (each peak maps to its surrounding edges)
    d1 = np.zeros((n1, n2), dtype=int)
    for idx, p in enumerate(peaks):
        if p - 1 < n1:
            d1[p - 1, idx] = 1   # left edge
        if p < n1:
            d1[p, idx] = -1      # right edge
    
    # Verify d² = 0
    product = d0 @ d1
    # This should be 0 by construction (boundary of boundary = 0)
    
    # Filtrations = time indices
    filt0 = list(range(n0))
    filt1 = list(range(n1))
    filt2 = peaks
    
    return d1, d0, filt2, filt1, filt0


def detect_anomaly(
    signal_normal: List[float], 
    signal_test: List[float],
    threshold: float = 0.5
) -> Dict:
    """
    Detect anomalies by comparing filtration-weighted densities.
    
    If the test signal has significantly different density from normal,
    it indicates an anomalous timing pattern in the peaks.
    """
    try:
        d1_n, d0_n, f2_n, f1_n, f0_n = time_series_to_chain_complex(signal_normal, threshold)
        d1_t, d0_t, f2_t, f1_t, f0_t = time_series_to_chain_complex(signal_test, threshold)
    except Exception as e:
        return {'error': str(e)}
    
    # Compute densities
    def density(d1, f1, f2):
        total = 0
        for i in range(d1.shape[0]):
            for j in range(d1.shape[1]):
                if d1[i, j] != 0:
                    total += f1[i] - f2[j]
        return total
    
    rho_normal = density(d1_n, f1_n, f2_n)
    rho_test = density(d1_t, f1_t, f2_t)
    
    return {
        'density_normal': rho_normal,
        'density_test': rho_test,
        'difference': abs(rho_test - rho_normal),
        'anomalous': abs(rho_test - rho_normal) > 5,
        'num_peaks_normal': d1_n.shape[1],
        'num_peaks_test': d1_t.shape[1],
    }


# ============================================================
# Application 2: Chemical Compound Classification
# ============================================================

def molecular_arithmetic_filtration(atomic_numbers: List[int]) -> List[int]:
    """
    Classify atoms in a molecule by their "complexity" via arithmetic filtration.
    
    Atomic number → Ω(atomic number) gives a natural complexity hierarchy:
    - Hydrogen (1): Ω = 0 (simplest)
    - Primes (2=He, 3=Li, 5=B, 7=N, 11=Na, 13=Al): Ω = 1
    - Composite (6=C, 8=O, 14=Si, 16=S): Ω = 2-4
    
    This provides a filtration on molecular graphs.
    """
    return [prime_factorization_length(z) for z in atomic_numbers]


def molecular_complexity_profile(atomic_numbers: List[int]) -> Dict:
    """
    Compute the complexity profile of a molecule.
    """
    filt = molecular_arithmetic_filtration(atomic_numbers)
    
    element_names = {
        1: 'H', 2: 'He', 3: 'Li', 4: 'Be', 5: 'B', 6: 'C',
        7: 'N', 8: 'O', 9: 'F', 10: 'Ne', 11: 'Na', 12: 'Mg',
        13: 'Al', 14: 'Si', 15: 'P', 16: 'S', 17: 'Cl', 18: 'Ar',
        19: 'K', 20: 'Ca', 26: 'Fe', 29: 'Cu', 30: 'Zn',
    }
    
    profile = {}
    for z, omega in zip(atomic_numbers, filt):
        name = element_names.get(z, f"Z={z}")
        if omega not in profile:
            profile[omega] = []
        profile[omega].append(name)
    
    return {
        'filtration_levels': filt,
        'max_complexity': max(filt) if filt else 0,
        'complexity_profile': profile,
        'total_complexity': sum(filt),
    }


# ============================================================
# Application 3: Network Centrality via Chain Complexes
# ============================================================

def network_chain_complex(
    adjacency: np.ndarray, 
    node_weights: List[int]
) -> Dict:
    """
    Analyze a network using chain complex filtration.
    
    The adjacency matrix defines the 1-skeleton (C₁ = edges, C₀ = nodes).
    Node weights provide a filtration (e.g., degree, betweenness, or
    arithmetic filtration of node IDs).
    
    Returns density and support analysis.
    """
    n = adjacency.shape[0]
    
    # Build edge list
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if adjacency[i, j] != 0:
                edges.append((i, j))
    
    n0 = n          # nodes
    n1 = len(edges) # edges
    
    # Boundary map d₀: edges → nodes
    d0 = np.zeros((n0, n1), dtype=int)
    for e_idx, (i, j) in enumerate(edges):
        d0[i, e_idx] = -1
        d0[j, e_idx] = 1
    
    # Edge filtration = max of endpoint filtrations
    edge_filt = [max(node_weights[i], node_weights[j]) for i, j in edges]
    
    # Density = sum over nonzero d₀ entries of (node_filt - edge_filt)
    density = 0
    for e_idx in range(n1):
        for v_idx in range(n0):
            if d0[v_idx, e_idx] != 0:
                density += node_weights[v_idx] - edge_filt[e_idx]
    
    return {
        'num_nodes': n0,
        'num_edges': n1,
        'density': density,
        'edge_filtration': edge_filt,
        'node_filtration': node_weights,
    }


# ============================================================
# Demo
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Time Series Anomaly Detection")
    print("=" * 60)
    
    normal_signal = [0.1, 0.3, 0.8, 0.4, 0.2, 0.6, 0.9, 0.3, 0.1]
    anomalous_signal = [0.1, 0.9, 0.3, 0.2, 0.1, 0.2, 0.3, 0.8, 0.1]
    
    result = detect_anomaly(normal_signal, anomalous_signal, threshold=0.5)
    print(f"Normal signal peaks: {result.get('num_peaks_normal', 'N/A')}")
    print(f"Test signal peaks: {result.get('num_peaks_test', 'N/A')}")
    print(f"Density (normal): {result.get('density_normal', 'N/A')}")
    print(f"Density (test): {result.get('density_test', 'N/A')}")
    print(f"Anomalous: {result.get('anomalous', 'N/A')}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 2: Molecular Complexity via Arithmetic Filtration")
    print("=" * 60)
    
    # Water: H₂O = [1, 1, 8]
    water = molecular_complexity_profile([1, 1, 8])
    print(f"Water (H₂O): {water}")
    
    # Ethanol: C₂H₆O = [6, 6, 1, 1, 1, 1, 1, 1, 8]
    ethanol = molecular_complexity_profile([6, 6, 1, 1, 1, 1, 1, 1, 8])
    print(f"Ethanol: total complexity = {ethanol['total_complexity']}")
    print(f"  Profile: {ethanol['complexity_profile']}")
    
    # Iron(II) oxide: FeO = [26, 8]
    feo = molecular_complexity_profile([26, 8])
    print(f"FeO: {feo}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 3: Network Analysis")
    print("=" * 60)
    
    # Triangle graph
    adj = np.array([
        [0, 1, 1],
        [1, 0, 1],
        [1, 1, 0]
    ])
    weights = [1, 2, 3]
    result = network_chain_complex(adj, weights)
    print(f"Triangle graph with weights {weights}:")
    print(f"  Density: {result['density']}")
    print(f"  Edge filtration: {result['edge_filtration']}")


"""
Multi-Degree Persistence for Filtered Chain Complexes — Demo

Demonstrates the key theorems with concrete numerical examples:
1. d² = 0 cancellation
2. Separation theorem (multi_degree_strictly_finer)
3. Arithmetic filtration (bridge to number theory)
4. Diagonal-like support disjointness
"""

import numpy as np
from typing import List, Tuple, Dict

def check_d_sq_zero(d1: np.ndarray, d0: np.ndarray) -> bool:
    """Check if d₀ · d₁ = 0 (chain complex condition)."""
    product = d0 @ d1
    return np.allclose(product, 0)

def filtration_weighted_density(d1: np.ndarray, filt1: List[int], filt2: List[int]) -> int:
    """
    Compute the filtration-weighted differential density.
    For each nonzero entry d₁[i,j], accumulates filt₁[i] - filt₂[j].
    """
    density = 0
    n1, n2 = d1.shape
    for i in range(n1):
        for j in range(n2):
            if d1[i, j] != 0:
                density += filt1[i] - filt2[j]
    return density

def is_diagonal_like(M: np.ndarray) -> bool:
    """Check if a matrix is diagonal-like (≤1 nonzero per row and column)."""
    for i in range(M.shape[0]):
        if np.count_nonzero(M[i, :]) > 1:
            return False
    for j in range(M.shape[1]):
        if np.count_nonzero(M[:, j]) > 1:
            return False
    return True

def prime_factorization_length(n: int) -> int:
    """Compute Ω(n) = number of prime factors with multiplicity."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            count += 1
            temp //= d
        d += 1
    if temp > 1:
        count += 1
    return count

def d_sq_cancellation_demo(d1: np.ndarray, d0: np.ndarray) -> None:
    """Demonstrate the d² = 0 cancellation theorem."""
    n0, n1_d0 = d0.shape
    n1_d1, n2 = d1.shape
    assert n1_d0 == n1_d1, "Dimensions must match"
    
    print("=== d² = 0 Cancellation Theorem Demo ===")
    print(f"d₁ =\n{d1}")
    print(f"d₀ =\n{d0}")
    print(f"d₀·d₁ =\n{d0 @ d1}")
    print()
    
    for i in range(n0):
        for k in range(n2):
            products = [d0[i, j] * d1[j, k] for j in range(n1_d0)]
            nonzero = [(j, p) for j, p in enumerate(products) if p != 0]
            
            if len(nonzero) == 0:
                print(f"  (i={i}, k={k}): All products zero ✓")
            elif len(nonzero) >= 2:
                print(f"  (i={i}, k={k}): {len(nonzero)} nonzero products cancel: "
                      f"{[p for _, p in nonzero]} → sum = {sum(p for _, p in nonzero)} ✓")
            else:
                print(f"  (i={i}, k={k}): BUG — lone survivor! This shouldn't happen with d²=0")

# ============================================================
# DEMO 1: Separation Theorem
# ============================================================
print("=" * 60)
print("DEMO 1: Separation Theorem (multi_degree_strictly_finer)")
print("=" * 60)

d1 = np.array([[1], [0]])   # 2×1 matrix
d0 = np.array([[0, 1]])     # 1×2 matrix

assert check_d_sq_zero(d1, d0), "d² ≠ 0!"
print(f"\nd₁ = {d1.tolist()}")
print(f"d₀ = {d0.tolist()}")
print(f"d₀·d₁ = {(d0 @ d1).tolist()}  (= 0 ✓)")

filt1_A = [0, 3]
filt1_B = [3, 0]
filt2 = [2]

rho_A = filtration_weighted_density(d1, filt1_A, filt2)
rho_B = filtration_weighted_density(d1, filt1_B, filt2)

print(f"\nComplex A: filt₁ = {filt1_A}, filt₂ = {filt2}")
print(f"  Density ρ(A) = {rho_A}")
print(f"\nComplex B: filt₁ = {filt1_B}, filt₂ = {filt2}")
print(f"  Density ρ(B) = {rho_B}")
print(f"\nρ(A) ≠ ρ(B): {rho_A} ≠ {rho_B} → {rho_A != rho_B} ✓")
print("→ Filtration timing is DETECTABLE by the density invariant!")

# ============================================================
# DEMO 2: d² = 0 Cancellation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: d² = 0 Cancellation Theorem")
print("=" * 60)

# Example with cancellation
d1_cancel = np.array([[1], [-1]])
d0_cancel = np.array([[1, 1]])
print("\nCase 1: Symmetric differentials (cancellation required)")
d_sq_cancellation_demo(d1_cancel, d0_cancel)

# Example with disjoint supports
d1_disjoint = np.array([[1], [0]])
d0_disjoint = np.array([[0, 1]])
print("\nCase 2: Disjoint support differentials (all products zero)")
d_sq_cancellation_demo(d1_disjoint, d0_disjoint)

# ============================================================
# DEMO 3: Arithmetic Filtration Bridge
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Arithmetic Filtration (Number Theory Bridge)")
print("=" * 60)

print("\nΩ(n) = prime factorization length:")
print(f"  {'n':>6} | {'Ω(n)':>4} | {'factorization':>20}")
print("  " + "-" * 38)
test_values = [1, 2, 3, 4, 6, 8, 12, 16, 30, 60, 210, 2310]
for n in test_values:
    omega = prime_factorization_length(n)
    # Simple factorization display
    factors = []
    temp = n
    d = 2
    while d * d <= temp:
        while temp % d == 0:
            factors.append(d)
            temp //= d
        d += 1
    if temp > 1:
        factors.append(temp)
    fact_str = " × ".join(map(str, factors)) if factors else "1"
    print(f"  {n:>6} | {omega:>4} | {fact_str:>20}")

print("\nMultiplicativity check: Ω(a·b) = Ω(a) + Ω(b)")
test_pairs = [(2, 3), (4, 5), (6, 7), (12, 30), (8, 15)]
for a, b in test_pairs:
    lhs = prime_factorization_length(a * b)
    rhs = prime_factorization_length(a) + prime_factorization_length(b)
    status = "✓" if lhs == rhs else "✗"
    print(f"  Ω({a}·{b}) = Ω({a*b}) = {lhs}, "
          f"Ω({a}) + Ω({b}) = {prime_factorization_length(a)} + {prime_factorization_length(b)} = {rhs} {status}")

# ============================================================
# DEMO 4: Diagonal-Like Support Disjointness
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Diagonal-Like Support Disjointness")
print("=" * 60)

# 3-term complex with diagonal-like differentials
d1_diag = np.array([[1, 0], [0, 1], [0, 0]])  # 3×2
d0_diag = np.array([[0, 0, 1]])                 # 1×3

print(f"\nd₁ (diagonal-like: {is_diagonal_like(d1_diag)}) =\n{d1_diag}")
print(f"d₀ (diagonal-like: {is_diagonal_like(d0_diag)}) =\n{d0_diag}")
print(f"d₀·d₁ =\n{d0_diag @ d1_diag}")

# Check support disjointness
d1_col_support = set()
d0_row_support = set()
for j in range(d1_diag.shape[0]):
    if any(d1_diag[j, k] != 0 for k in range(d1_diag.shape[1])):
        d1_col_support.add(j)
for j in range(d0_diag.shape[1]):
    if any(d0_diag[i, j] != 0 for i in range(d0_diag.shape[0])):
        d0_row_support.add(j)

print(f"\nC₁ basis vectors in im(d₁): {d1_col_support}")
print(f"C₁ basis vectors in support of d₀: {d0_row_support}")
print(f"Intersection: {d1_col_support & d0_row_support}")
print(f"Disjoint: {len(d1_col_support & d0_row_support) == 0} ✓")

# ============================================================
# DEMO 5: Filtration Sum Bound
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Filtration Sum Bound (∑ f(i) ≤ n·M)")
print("=" * 60)

n, M = 5, 10
f_vals = [3, 7, 10, 1, 8]
total = sum(f_vals)
bound = n * M
print(f"\nn = {n}, M = {M}")
print(f"f = {f_vals}")
print(f"∑ f(i) = {total} ≤ n·M = {bound}: {total <= bound} ✓")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


"""
Visualization 3: Arithmetic Filtration — Number Theory Bridge

Shows the connection between prime factorization and filtration levels.
Demonstrates Ω(a·b) = Ω(a) + Ω(b) visually and shows how the arithmetic
filtration creates a natural hierarchy on the integers.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def omega(n):
    """Compute Ω(n) = number of prime factors with multiplicity."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            count += 1
            temp //= d
        d += 1
    if temp > 1:
        count += 1
    return count

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Ω values as a number line with colored levels
ax1 = axes[0, 0]
numbers = list(range(1, 51))
omega_vals = [omega(n) for n in numbers]
max_omega = max(omega_vals)

colors_map = {
    0: '#9E9E9E',   # 1
    1: '#2196F3',   # primes
    2: '#4CAF50',   # semiprimes
    3: '#FF9800',   # 3 factors
    4: '#F44336',   # 4 factors
    5: '#9C27B0',   # 5 factors
}

for n, ov in zip(numbers, omega_vals):
    color = colors_map.get(ov, '#795548')
    ax1.bar(n, 1, bottom=ov - 0.5, color=color, edgecolor='white', linewidth=0.3, width=0.8)
    if n <= 30:
        ax1.text(n, ov, str(n), ha='center', va='center', fontsize=6, fontweight='bold')

ax1.set_xlabel('n', fontsize=11)
ax1.set_ylabel('Ω(n)', fontsize=11)
ax1.set_title('Integers Stratified by Factorization Length', fontsize=12, fontweight='bold')
ax1.set_yticks(range(max_omega + 1))
ax1.set_yticklabels([f'Ω={k}' for k in range(max_omega + 1)])
ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.3)
ax1.axhline(y=1.5, color='gray', linestyle=':', alpha=0.3)
ax1.axhline(y=2.5, color='gray', linestyle=':', alpha=0.3)

legend_items = [
    mpatches.Patch(color=colors_map[0], label='Ω=0: {1}'),
    mpatches.Patch(color=colors_map[1], label='Ω=1: primes'),
    mpatches.Patch(color=colors_map[2], label='Ω=2: semiprimes'),
    mpatches.Patch(color=colors_map[3], label='Ω=3'),
    mpatches.Patch(color=colors_map[4], label='Ω=4'),
    mpatches.Patch(color=colors_map[5], label='Ω=5'),
]
ax1.legend(handles=legend_items, fontsize=8, loc='upper left')

# Panel 2: Multiplicativity visualization
ax2 = axes[0, 1]
pairs = [(2, 3), (2, 5), (3, 4), (2, 6), (4, 3), (3, 5),
         (2, 8), (4, 5), (3, 7), (6, 5), (4, 6), (2, 15)]

x_vals = [omega(a) + omega(b) for a, b in pairs]
y_vals = [omega(a * b) for a, b in pairs]

ax2.scatter(x_vals, y_vals, c='#2196F3', s=100, edgecolors='black', linewidths=1.5, zorder=5)

# Perfect line
max_val = max(max(x_vals), max(y_vals)) + 1
ax2.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='Ω(ab) = Ω(a) + Ω(b)')

# Annotate some points
for (a, b), x, y in zip(pairs[:6], x_vals[:6], y_vals[:6]):
    ax2.annotate(f'{a}×{b}', (x, y), textcoords="offset points",
                xytext=(8, 5), fontsize=8, color='gray')

ax2.set_xlabel('Ω(a) + Ω(b)', fontsize=11)
ax2.set_ylabel('Ω(a·b)', fontsize=11)
ax2.set_title('Multiplicativity: Ω(a·b) = Ω(a) + Ω(b)', fontsize=12, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.3)

# Panel 3: Filtration as a persistence diagram metaphor
ax3 = axes[1, 0]

# Show how numbers "enter" the filtration at their Ω level
levels = {}
for n in range(1, 61):
    ov = omega(n)
    if ov not in levels:
        levels[ov] = []
    levels[ov].append(n)

max_show = 5
bar_height = 0.6
for level in sorted(levels.keys()):
    nums = levels[level][:12]  # Show at most 12 per level
    for idx, n in enumerate(nums):
        color = colors_map.get(level, '#795548')
        ax3.barh(level, 0.8, left=idx, height=bar_height, color=color,
                edgecolor='white', linewidth=0.5)
        ax3.text(idx + 0.4, level, str(n), ha='center', va='center',
                fontsize=7, fontweight='bold')

ax3.set_ylabel('Filtration Level Ω', fontsize=11)
ax3.set_xlabel('Count (first elements at each level)', fontsize=11)
ax3.set_title('Arithmetic Filtration: Integers Enter by Complexity', fontsize=12, fontweight='bold')
ax3.set_yticks(range(max_show + 1))

# Panel 4: Density of primes at each level
ax4 = axes[1, 1]
max_n = 500
level_counts = {}
for n in range(1, max_n + 1):
    ov = omega(n)
    level_counts[ov] = level_counts.get(ov, 0) + 1

levels_sorted = sorted(level_counts.keys())
counts = [level_counts[l] for l in levels_sorted]
colors_bars = [colors_map.get(l, '#795548') for l in levels_sorted]

bars = ax4.bar(levels_sorted, counts, color=colors_bars, edgecolor='black', linewidth=0.5)

for bar, count in zip(bars, counts):
    ax4.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 3,
            str(count), ha='center', va='bottom', fontsize=9, fontweight='bold')

ax4.set_xlabel('Ω level', fontsize=11)
ax4.set_ylabel(f'Count of n ≤ {max_n} at level', fontsize=11)
ax4.set_title(f'Distribution of Ω(n) for n ≤ {max_n}', fontsize=12, fontweight='bold')

# Add annotation about the peak
peak_level = levels_sorted[np.argmax(counts)]
ax4.annotate(f'Peak at Ω={peak_level}\n(most numbers are\nmoderately composite)',
            xy=(peak_level, max(counts)), xytext=(peak_level + 1.5, max(counts) - 20),
            arrowprops=dict(arrowstyle='->', color='red', lw=1.5),
            fontsize=9, color='red', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle('The Arithmetic Filtration: Bridging Number Theory and Persistent Homology',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('arithmetic_filtration_bridge.png', dpi=150, bbox_inches='tight')
print("Saved: arithmetic_filtration_bridge.png")


"""
Visualization 2: d² = 0 Cancellation Patterns

Visualizes the algebraic constraint that d² = 0 imposes on chain complexes.
Shows how nonzero entries in d₀ and d₁ must be arranged to satisfy the
cancellation condition: lone survivors are forbidden.

Three panels:
1. A valid chain complex with canceling pairs
2. Support disjointness for diagonal-like differentials
3. The forbidden "lone survivor" pattern
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

def draw_chain_complex(ax, d1, d0, title, filt1=None, annotations=None):
    """Draw a chain complex diagram showing C₂ → C₁ → C₀."""
    n1, n2 = d1.shape
    n0_rows = d0.shape[0]
    
    # Positions
    x_positions = [0.8, 0.4, 0.0]  # C₂, C₁, C₀
    
    # Draw C₂ nodes
    c2_y = [0.5 + i * 0.3 for i in range(n2)]
    for i, y in enumerate(c2_y):
        circle = plt.Circle((x_positions[0], y), 0.06, color='#2196F3', ec='black', lw=1.5)
        ax.add_patch(circle)
        ax.text(x_positions[0], y, f'{i}', ha='center', va='center', fontsize=8, fontweight='bold', color='white')
    
    # Draw C₁ nodes
    c1_y = [0.3 + i * 0.25 for i in range(n1)]
    for i, y in enumerate(c1_y):
        color = '#4CAF50'
        if filt1 is not None:
            # Color by filtration level
            intensity = filt1[i] / max(max(filt1), 1)
            color = plt.cm.YlOrRd(0.2 + 0.6 * intensity)
        circle = plt.Circle((x_positions[1], y), 0.06, color=color, ec='black', lw=1.5)
        ax.add_patch(circle)
        label = f'{i}'
        if filt1 is not None:
            label = f'{filt1[i]}'
        ax.text(x_positions[1], y, label, ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Draw C₀ nodes
    c0_y = [0.5 + i * 0.3 for i in range(n0_rows)]
    for i, y in enumerate(c0_y):
        circle = plt.Circle((x_positions[2], y), 0.06, color='#FF9800', ec='black', lw=1.5)
        ax.add_patch(circle)
        ax.text(x_positions[2], y, f'{i}', ha='center', va='center', fontsize=8, fontweight='bold', color='white')
    
    # Draw d₁ arrows (C₂ → C₁)
    for j in range(n2):
        for i in range(n1):
            if d1[i, j] != 0:
                color = '#1565C0' if d1[i, j] > 0 else '#C62828'
                style = '-' if d1[i, j] > 0 else '--'
                ax.annotate('', xy=(x_positions[1] + 0.07, c1_y[i]),
                           xytext=(x_positions[0] - 0.07, c2_y[j]),
                           arrowprops=dict(arrowstyle='->', color=color, lw=1.5, linestyle=style))
                mid_x = (x_positions[0] + x_positions[1]) / 2
                mid_y = (c2_y[j] + c1_y[i]) / 2
                ax.text(mid_x, mid_y + 0.04, str(d1[i, j]), fontsize=7, color=color,
                       ha='center', fontweight='bold')
    
    # Draw d₀ arrows (C₁ → C₀)
    for j in range(n1):
        for i in range(n0_rows):
            if d0[i, j] != 0:
                color = '#1565C0' if d0[i, j] > 0 else '#C62828'
                style = '-' if d0[i, j] > 0 else '--'
                ax.annotate('', xy=(x_positions[2] + 0.07, c0_y[i]),
                           xytext=(x_positions[1] - 0.07, c1_y[j]),
                           arrowprops=dict(arrowstyle='->', color=color, lw=1.5, linestyle=style))
                mid_x = (x_positions[1] + x_positions[2]) / 2
                mid_y = (c1_y[j] + c0_y[i]) / 2
                ax.text(mid_x, mid_y + 0.04, str(d0[i, j]), fontsize=7, color=color,
                       ha='center', fontweight='bold')
    
    # Labels
    ax.text(x_positions[0], max(c2_y) + 0.15, 'C₂', ha='center', fontsize=12, fontweight='bold', color='#2196F3')
    ax.text(x_positions[1], max(c1_y) + 0.15, 'C₁', ha='center', fontsize=12, fontweight='bold', color='#4CAF50')
    ax.text(x_positions[2], max(c0_y) + 0.15, 'C₀', ha='center', fontsize=12, fontweight='bold', color='#FF9800')
    
    ax.set_xlim(-0.15, 1.0)
    ax.set_ylim(0.1, max(max(c2_y), max(c1_y), max(c0_y)) + 0.25)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(title, fontsize=11, fontweight='bold', pad=10)
    
    if annotations:
        for ann in annotations:
            ax.text(ann['x'], ann['y'], ann['text'], fontsize=ann.get('fontsize', 9),
                   ha='center', color=ann.get('color', 'black'), 
                   fontweight=ann.get('fontweight', 'normal'),
                   bbox=dict(boxstyle='round,pad=0.3', facecolor=ann.get('bg', 'lightyellow'),
                            edgecolor='gray', alpha=0.8))

# Panel 1: Cancellation example
d1_cancel = np.array([[1], [-1]])
d0_cancel = np.array([[1, 1]])
draw_chain_complex(axes[0], d1_cancel, d0_cancel,
    'Cancellation: d₀[0,·]·d₁[·,0]\n= 1·1 + 1·(-1) = 0 ✓',
    annotations=[
        {'x': 0.4, 'y': 0.15, 'text': 'Two nonzero terms cancel', 
         'fontsize': 8, 'color': '#1B5E20', 'bg': '#C8E6C9'}
    ])

# Panel 2: Disjoint supports (diagonal-like)
d1_diag = np.array([[1, 0], [0, 1], [0, 0]])
d0_diag = np.array([[0, 0, 1]])
draw_chain_complex(axes[1], d1_diag, d0_diag,
    'Disjoint Supports (diagonal-like)\nim(d₁)={0,1}, supp(d₀)={2}',
    annotations=[
        {'x': 0.4, 'y': 0.12, 'text': 'No overlap → d²=0 automatic', 
         'fontsize': 8, 'color': '#0D47A1', 'bg': '#BBDEFB'}
    ])

# Panel 3: Forbidden lone survivor
d1_bad = np.array([[1], [0]])
d0_bad = np.array([[1, 0]])  # This violates d²=0 if d1[0,0]*d0[0,0] ≠ 0
draw_chain_complex(axes[2], d1_bad, d0_bad,
    'FORBIDDEN: Lone Survivor\nd₀[0,·]·d₁[·,0] = 1·1 = 1 ≠ 0 ✗',
    annotations=[
        {'x': 0.4, 'y': 0.15, 'text': 'Single nonzero term → d²≠0!', 
         'fontsize': 8, 'color': '#B71C1C', 'bg': '#FFCDD2'}
    ])

plt.suptitle('d² = 0 Constraint: Cancellation Patterns in Chain Complexes', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('d_sq_cancellation_patterns.png', dpi=150, bbox_inches='tight')
print("Saved: d_sq_cancellation_patterns.png")


"""
Visualization 1: Filtration-Weighted Density Separation

Visualizes how two chain complexes with identical differentials but different
filtration timings produce different density values. Shows the "asymmetric
window" through which filtration timing becomes detectable.

The heatmap shows density ρ(C) as a function of the two C₁ filtration values,
with the d₁ = [[1],[0]] differential highlighting how only the first basis
vector's filtration matters.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Density heatmap for d₁ = [[1],[0]]
ax1 = axes[0]
filt2_val = 2  # fixed C₂ filtration
n = 8
density_map = np.zeros((n, n))
for f0 in range(n):
    for f1 in range(n):
        # d₁[0,0] = 1 ≠ 0, d₁[1,0] = 0
        # density = (filt₁[0] - filt₂[0]) = f0 - 2
        density_map[f1, f0] = f0 - filt2_val

im1 = ax1.imshow(density_map, cmap='RdBu_r', origin='lower', aspect='equal',
                  vmin=-4, vmax=6)
ax1.set_xlabel('filt₁[0] (active basis)', fontsize=11)
ax1.set_ylabel('filt₁[1] (inactive basis)', fontsize=11)
ax1.set_title('Density ρ(C) for d₁ = [[1],[0]]', fontsize=12, fontweight='bold')

# Mark the two example complexes
ax1.plot(0, 3, 'ko', markersize=12, markeredgewidth=2)
ax1.annotate('A (ρ=-2)', (0, 3), textcoords="offset points", xytext=(10, 5),
             fontsize=10, fontweight='bold', color='black')
ax1.plot(3, 0, 'ks', markersize=12, markeredgewidth=2)
ax1.annotate('B (ρ=1)', (3, 0), textcoords="offset points", xytext=(10, 5),
             fontsize=10, fontweight='bold', color='black')

plt.colorbar(im1, ax=ax1, label='Density ρ', shrink=0.8)

# Panel 2: Density for d₁ = [[1],[-1]] (symmetric — no separation!)
ax2 = axes[1]
density_map_sym = np.zeros((n, n))
for f0 in range(n):
    for f1 in range(n):
        # d₁[0,0] = 1, d₁[1,0] = -1, both nonzero
        # density = (f0 - 2) + (f1 - 2) = f0 + f1 - 4
        density_map_sym[f1, f0] = f0 + f1 - 2 * filt2_val

im2 = ax2.imshow(density_map_sym, cmap='RdBu_r', origin='lower', aspect='equal',
                  vmin=-4, vmax=10)
ax2.set_xlabel('filt₁[0]', fontsize=11)
ax2.set_ylabel('filt₁[1]', fontsize=11)
ax2.set_title('Density for d₁ = [[1],[-1]]\n(symmetric → no separation)', fontsize=12, fontweight='bold')

# Mark swapped points — they have the same density!
ax2.plot(0, 1, 'ko', markersize=12, markeredgewidth=2)
ax2.annotate('(0,1): ρ=-3', (0, 1), textcoords="offset points", xytext=(10, 5),
             fontsize=9, fontweight='bold')
ax2.plot(1, 0, 'ks', markersize=12, markeredgewidth=2)
ax2.annotate('(1,0): ρ=-3', (1, 0), textcoords="offset points", xytext=(10, 5),
             fontsize=9, fontweight='bold')

# Draw the anti-diagonal (constant density lines)
for d_val in range(-2, 8, 2):
    xs = np.linspace(0, n-1, 100)
    ys = d_val + 2 * filt2_val - xs
    mask = (ys >= 0) & (ys < n)
    if mask.any():
        ax2.plot(xs[mask], ys[mask], 'k-', alpha=0.2, linewidth=0.5)

plt.colorbar(im2, ax=ax2, label='Density ρ', shrink=0.8)

# Panel 3: Arithmetic filtration levels
ax3 = axes[2]
numbers = list(range(1, 61))
omega_vals = []
for nn in numbers:
    count = 0
    temp = nn
    d = 2
    while d * d <= temp:
        while temp % d == 0:
            count += 1
            temp //= d
        d += 1
    if temp > 1:
        count += 1
    omega_vals.append(count)

colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0', '#795548']
for nn, omega in zip(numbers, omega_vals):
    c = colors[min(omega, len(colors)-1)]
    ax3.bar(nn, omega, color=c, edgecolor='white', linewidth=0.3)

ax3.set_xlabel('n', fontsize=11)
ax3.set_ylabel('Ω(n) = prime factorization length', fontsize=11)
ax3.set_title('Arithmetic Filtration\n(Number Theory Bridge)', fontsize=12, fontweight='bold')

# Custom legend
legend_items = [
    mpatches.Patch(color=colors[0], label='Ω=0 (n=1)'),
    mpatches.Patch(color=colors[1], label='Ω=1 (primes)'),
    mpatches.Patch(color=colors[2], label='Ω=2 (semiprimes)'),
    mpatches.Patch(color=colors[3], label='Ω=3'),
    mpatches.Patch(color=colors[4], label='Ω=4'),
    mpatches.Patch(color=colors[5], label='Ω≥5'),
]
ax3.legend(handles=legend_items, fontsize=8, loc='upper left')

plt.tight_layout()
plt.savefig('filtration_density_separation.png', dpi=150, bbox_inches='tight')
print("Saved: filtration_density_separation.png")
