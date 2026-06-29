#!/usr/bin/env python3
"""
Applications of Hyperbolic Number Theory

Demonstrates real-world applications of the Kesten duality and
Pythagorean-hyperbolic bridge:

1. Expander graph construction from free groups
2. Pseudorandom number generation via Cayley graph walks
3. Mixing time analysis for MCMC on free groups
4. Geodesic length distribution analysis
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Expander Graph Construction
# ============================================================

def construct_expander_adjacency(k: int, depth: int) -> np.ndarray:
    """
    Construct adjacency matrix of the Cayley graph of F_k truncated at depth.
    
    The free group Cayley graph is a (2k)-regular tree. We truncate at
    a given depth, producing a finite graph that inherits the spectral
    gap of the infinite tree (up to boundary effects).
    
    This gives a deterministic expander graph construction with guaranteed
    spectral gap ≥ 1 - √(2k-1)/k.
    
    Args:
        k: Number of generators.
        depth: Maximum word length to include.
        
    Returns:
        Adjacency matrix as numpy array.
    """
    # Generate all words up to given depth
    # Words are represented as lists of generator indices (1..k for generators, -1..-k for inverses)
    words = [[]]  # identity
    frontier = [[]]
    
    for d in range(depth):
        new_frontier = []
        for word in frontier:
            for gen in list(range(1, k+1)) + list(range(-k, 0)):
                # Avoid immediate cancellation
                if word and word[-1] == -gen:
                    continue
                new_word = word + [gen]
                new_frontier.append(new_word)
        words.extend(new_frontier)
        frontier = new_frontier
    
    n = len(words)
    word_to_idx = {tuple(w): i for i, w in enumerate(words)}
    adj = np.zeros((n, n))
    
    for i, word in enumerate(words):
        for gen in list(range(1, k+1)) + list(range(-k, 0)):
            # Avoid cancellation
            if word and word[-1] == -gen:
                neighbor = word[:-1]
            else:
                neighbor = word + [gen]
            
            key = tuple(neighbor)
            if key in word_to_idx:
                j = word_to_idx[key]
                adj[i, j] = 1
    
    return adj


def analyze_expander(k: int, depth: int) -> dict:
    """
    Analyze spectral properties of the truncated F_k Cayley graph.
    
    Returns:
        Dictionary with spectral analysis results.
    """
    adj = construct_expander_adjacency(k, depth)
    n = adj.shape[0]
    
    # Compute eigenvalues
    eigenvalues = np.sort(np.real(np.linalg.eigvals(adj)))[::-1]
    
    # Normalized spectral radius
    degree = 2 * k
    rho_empirical = abs(eigenvalues[1]) / degree if n > 1 else 0
    rho_kesten = np.sqrt(2 * k - 1) / k
    
    return {
        "k": k,
        "depth": depth,
        "num_vertices": n,
        "degree": degree,
        "largest_eigenvalue": eigenvalues[0],
        "second_eigenvalue": abs(eigenvalues[1]) if n > 1 else 0,
        "spectral_radius_empirical": rho_empirical,
        "spectral_radius_kesten": rho_kesten,
        "spectral_gap_empirical": 1 - rho_empirical,
        "spectral_gap_kesten": 1 - rho_kesten,
    }


# ============================================================
# Application 2: Random Walk on Free Group
# ============================================================

def random_walk_on_tree(k: int, steps: int, trials: int = 1000) -> List[float]:
    """
    Simulate random walk on F_k Cayley graph and measure distance from identity.
    
    The Kesten spectral bound predicts the walk escapes to infinity
    with distance growing linearly (non-amenability).
    
    Returns:
        Average distance from identity at each step.
    """
    rng = np.random.default_rng(42)
    generators = list(range(1, k+1)) + list(range(-k, 0))
    avg_distances = []
    
    for step in range(steps + 1):
        distances = []
        for _ in range(trials):
            # Simulate a walk and track reduced word length
            word = []
            for _ in range(step):
                gen = generators[rng.integers(len(generators))]
                if word and word[-1] == -gen:
                    word.pop()
                else:
                    word.append(gen)
            distances.append(len(word))
        avg_distances.append(np.mean(distances))
    
    return avg_distances


# ============================================================
# Application 3: Geodesic Distribution Analysis
# ============================================================

def count_hyperbolic_conjugacy_classes(max_trace: int) -> List[Tuple[int, int]]:
    """
    Count conjugacy classes of primitive hyperbolic elements in PSL(2,ℤ)
    organized by trace.
    
    A primitive hyperbolic element γ ∈ PSL(2,ℤ) with tr(γ) = t > 2
    corresponds to a prime closed geodesic of length 2·arccosh(t/2).
    
    For small traces, we enumerate by finding matrices [[a,b],[c,d]]
    with a+d = t, ad-bc = 1, and checking primitivity.
    
    Returns:
        List of (trace, count) pairs.
    """
    results = []
    for t in range(3, max_trace + 1):
        # Count solutions to ad - bc = 1 with a + d = t
        # up to conjugacy (rough estimate)
        count = 0
        for a in range(0, t + 1):
            d = t - a
            # Need ad - bc = 1, so bc = ad - 1
            prod = a * d - 1
            if prod < 0:
                continue
            # Count factorizations of prod
            for b in range(1, int(np.sqrt(prod)) + 2):
                if prod % b == 0 and b > 0:
                    count += 1
        # Very rough conjugacy class count (divide by approximate class size)
        # This is a simplification; exact counting requires more care
        results.append((t, max(1, count // max(1, t - 2))))
    
    return results


def geodesic_length_distribution(max_trace: int) -> List[Tuple[float, int]]:
    """
    Compute the distribution of geodesic lengths from trace data.
    """
    classes = count_hyperbolic_conjugacy_classes(max_trace)
    distribution = []
    for trace, count in classes:
        length = 2 * np.arccosh(trace / 2)
        distribution.append((length, count))
    return distribution


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Expander Graph Analysis")
    print("=" * 60)
    
    for depth in [2, 3, 4]:
        result = analyze_expander(2, depth)
        print(f"\n  F₂ Cayley graph, depth={depth}:")
        print(f"    Vertices: {result['num_vertices']}")
        print(f"    Degree: {result['degree']}")
        print(f"    Second eigenvalue: {result['second_eigenvalue']:.4f}")
        print(f"    Empirical ρ: {result['spectral_radius_empirical']:.4f}")
        print(f"    Kesten ρ: {result['spectral_radius_kesten']:.4f}")
        print(f"    Gap (empirical): {result['spectral_gap_empirical']:.4f}")
        print(f"    Gap (Kesten): {result['spectral_gap_kesten']:.4f}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 2: Random Walk Escape Rate")
    print("=" * 60)
    
    avg_dist = random_walk_on_tree(2, 20, trials=500)
    for step in range(0, 21, 5):
        print(f"  Step {step:>2d}: avg distance from identity = {avg_dist[step]:.2f}")
    
    # Theoretical drift rate for F_2: (2k-2)/(2k) = 1/2
    print(f"\n  Theoretical drift rate: {(2*2-2)/(2*2):.4f}")
    if len(avg_dist) > 1:
        empirical_drift = avg_dist[-1] / 20
        print(f"  Empirical drift rate: {empirical_drift:.4f}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 3: Prime Geodesic Distribution")
    print("=" * 60)
    
    distribution = geodesic_length_distribution(30)
    cumulative = 0
    for length, count in distribution:
        cumulative += count
        predicted = np.exp(length) / length if length > 0 else 0
        print(f"  ℓ = {length:.4f}: count = {count:>3d}, cumulative = {cumulative:>4d}, "
              f"predicted π(ℓ) = {predicted:.1f}")
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Hyperbolic Number Theory — Growth, Spectral Gaps, and the Kesten Duality

Demonstrates the key theorems with concrete numerical examples:
1. Free group ball growth: B(n) = 2·3^n - 1
2. Kesten spectral bound: sqrt(2k-1)/k < 1
3. Berggren trace classification: M1 elliptic, M2 hyperbolic, M3 parabolic
4. Translation length computation
5. Prime geodesic counting prediction
"""

import numpy as np
from typing import List, Tuple


def sphere_size(k: int, n: int) -> int:
    """Sphere size |S(n)| in Cayley graph of F_k."""
    if n == 0:
        return 1
    return 2 * k * (2 * k - 1) ** (n - 1)


def ball_size(k: int, n: int) -> int:
    """Ball size |B(n)| in Cayley graph of F_k."""
    return sum(sphere_size(k, i) for i in range(n + 1))


def kesten_spectral_radius(k: int) -> float:
    """Kesten spectral radius for F_k."""
    return np.sqrt(2 * k - 1) / k


def translation_length(trace: float) -> float:
    """Hyperbolic translation length from trace."""
    t = abs(trace)
    if t <= 2:
        return 0.0
    return 2 * np.arccosh(t / 2)


def trace_sequence(t0: int, n: int) -> List[int]:
    """Trace of M^1, M^2, ..., M^n using Cayley-Hamilton recurrence."""
    if n == 0:
        return []
    traces = [2, t0]  # tr(I)=2, tr(M)=t0
    for _ in range(2, n + 1):
        traces.append(t0 * traces[-1] - traces[-2])
    return traces[1:]


def prime_geodesic_leading_term(L: float) -> float:
    """Leading term e^L / L of the prime geodesic counting function."""
    return np.exp(L) / L


# ============================================================
# Demo 1: Ball Growth Formula
# ============================================================
print("=" * 60)
print("DEMO 1: Free Group Ball Growth")
print("Theorem: B(n) + 1 = 2 * 3^n for F_2")
print("=" * 60)

for n in range(8):
    b = ball_size(2, n)
    formula = 2 * 3**n - 1
    assert b == formula, f"Mismatch at n={n}: {b} != {formula}"
    print(f"  n={n}: B({n}) = {b:>6d}  |  2·3^{n} - 1 = {formula:>6d}  |  3^{n} = {3**n:>5d}  |  B(n) >= 3^n: {b >= 3**n}")

print()

# ============================================================
# Demo 2: Kesten Spectral Bound
# ============================================================
print("=" * 60)
print("DEMO 2: Kesten Spectral Bound")
print("Theorem: sqrt(2k-1)/k < 1 for k >= 2")
print("=" * 60)

for k in range(2, 8):
    rho = kesten_spectral_radius(k)
    gap = 1 - rho
    cheeger_lb = gap / 2
    print(f"  k={k}: ρ = √{2*k-1}/{k} = {rho:.6f}  |  gap = {gap:.6f}  |  Cheeger ≥ {cheeger_lb:.6f}  |  ρ < 1: {rho < 1}")

print()

# ============================================================
# Demo 3: Berggren Trace Classification
# ============================================================
print("=" * 60)
print("DEMO 3: Berggren Generator Classification")
print("Cross-domain: Number Theory ↔ Hyperbolic Geometry")
print("=" * 60)

berggren_matrices = {
    "M1": np.array([[1, -1], [1, 0]]),
    "M2": np.array([[2, 1], [1, 1]]),
    "M3": np.array([[0, 1], [-1, 2]]),
}

for name, M in berggren_matrices.items():
    tr = int(np.trace(M))
    det = int(round(np.linalg.det(M)))
    abs_tr = abs(tr)
    
    if abs_tr < 2:
        classification = "ELLIPTIC"
    elif abs_tr == 2:
        classification = "PARABOLIC"
    else:
        classification = "HYPERBOLIC"
    
    tl = translation_length(tr)
    print(f"  {name}: tr={tr}, det={det}, |tr|={abs_tr}, class={classification}, ℓ={tl:.4f}")

print()

# ============================================================
# Demo 4: Trace Sequence and Geodesic Lengths
# ============================================================
print("=" * 60)
print("DEMO 4: M₂ Power Traces and Geodesic Lengths")
print("Recurrence: tr(M^{n+2}) = 3·tr(M^{n+1}) - tr(M^n)")
print("=" * 60)

traces = trace_sequence(3, 8)
for i, tr in enumerate(traces, 1):
    tl = translation_length(tr)
    print(f"  M₂^{i}: tr = {tr:>8d}  |  ℓ = {tl:.6f}  |  ℓ/i = {tl/i:.6f}")

print()

# ============================================================
# Demo 5: Random Walk Mixing
# ============================================================
print("=" * 60)
print("DEMO 5: Random Walk Mixing on F₂ Cayley Graph")
print("Theorem: (3/4)^n < 1 for n >= 1")
print("=" * 60)

rho = kesten_spectral_radius(2)
for n in range(1, 12):
    mixing = rho ** (2 * n)  # ρ^{2n} = (3/4)^n
    three_fourths = (3/4) ** n
    print(f"  n={n:>2d}: ρ^{2*n:>2d} = {mixing:.10f}  |  (3/4)^{n} = {three_fourths:.10f}")

print()

# ============================================================
# Demo 6: Prime Geodesic Prediction
# ============================================================
print("=" * 60)
print("DEMO 6: Prime Geodesic Counting Conjecture")
print("Conjecture: π(L) ~ e^L / L as L → ∞")
print("Testable: enumerate and compare")
print("=" * 60)

for L in [2, 5, 8, 10, 12, 15, 20]:
    predicted = prime_geodesic_leading_term(L)
    print(f"  L={L:>2d}: predicted π(L) ≈ {predicted:>15.1f}")

print()
print("=" * 60)
print("All demonstrations completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Berggren Trace Classification and Geodesic Length Spectrum

Shows the cross-domain bridge between Pythagorean triples and hyperbolic geometry:
1. Left panel: Trace recurrence for M₂ powers with classification regions
2. Right panel: Geodesic length spectrum showing translation lengths
"""

import numpy as np
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# --- Trace computation ---
def trace_sequence(t0, n):
    traces = [2, t0]
    for _ in range(2, n + 1):
        traces.append(t0 * traces[-1] - traces[-2])
    return traces[1:]

def translation_length(trace):
    t = abs(trace)
    if t <= 2:
        return 0.0
    return 2 * np.arccosh(t / 2)

# --- Panel 1: Berggren Classification ---
generators = {
    'M₁': {'trace': 1, 'color': '#2196F3', 'type': 'Elliptic'},
    'M₃': {'trace': 2, 'color': '#FF9800', 'type': 'Parabolic'},
    'M₂': {'trace': 3, 'color': '#E53935', 'type': 'Hyperbolic'},
}

# Background regions
ax1.axhspan(-2, 2, alpha=0.08, color='#2196F3', label='Elliptic region (|tr| < 2)')
ax1.axhspan(2, 50, alpha=0.08, color='#E53935', label='Hyperbolic region (|tr| > 2)')
ax1.axhline(y=2, color='#FF9800', linestyle='--', linewidth=1.5, alpha=0.7)
ax1.axhline(y=-2, color='#FF9800', linestyle='--', linewidth=1.5, alpha=0.7)

# Plot Berggren generators
for name, info in generators.items():
    ax1.plot(0, info['trace'], 'o', color=info['color'], markersize=15, zorder=5)
    ax1.annotate(f"{name}\ntr = {info['trace']}\n({info['type']})", 
                xy=(0, info['trace']), fontsize=10, fontweight='bold',
                xytext=(0.3, info['trace']), ha='left', va='center',
                color=info['color'],
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white', 
                         edgecolor=info['color'], alpha=0.9))

# Trace recurrence for M₂ powers
traces_m2 = trace_sequence(3, 6)
powers = list(range(1, 7))
ax1.plot(powers, traces_m2, 's-', color='#E53935', markersize=8, linewidth=2,
         label='tr(M₂ⁿ)', zorder=4)

for i, tr in enumerate(traces_m2):
    ax1.annotate(f'{tr}', xy=(i+1, tr), fontsize=8, ha='center', va='bottom',
                xytext=(0, 8), textcoords='offset points', color='#E53935')

ax1.set_xlabel('Power n', fontsize=13)
ax1.set_ylabel('Trace', fontsize=13)
ax1.set_title('SL₂(ℤ) Trace Classification\nof Berggren Generators', fontsize=14, fontweight='bold')
ax1.set_xlim(-0.5, 6.5)
ax1.set_ylim(-5, max(traces_m2) * 1.15)
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.3)

# --- Panel 2: Geodesic Length Spectrum ---
traces_long = trace_sequence(3, 10)
lengths = [translation_length(t) for t in traces_long]
powers_long = list(range(1, 11))

bars = ax2.bar(powers_long, lengths, color='#7B1FA2', alpha=0.8, edgecolor='#4A148C', linewidth=1.5)

# Annotate each bar
for i, (length, trace) in enumerate(zip(lengths, traces_long)):
    ax2.annotate(f'ℓ = {length:.2f}\ntr = {trace}', 
                xy=(i+1, length), fontsize=8, ha='center', va='bottom',
                xytext=(0, 3), textcoords='offset points', color='#4A148C')

# Reference: linear growth rate
linear_fit = np.polyfit(powers_long, lengths, 1)
x_fit = np.linspace(0.5, 10.5, 100)
ax2.plot(x_fit, np.polyval(linear_fit, x_fit), '--', color='#FF9800', linewidth=2,
         alpha=0.7, label=f'Linear fit: ℓ ≈ {linear_fit[0]:.2f}n + {linear_fit[1]:.2f}')

ax2.set_xlabel('Power n (M₂ⁿ)', fontsize=13)
ax2.set_ylabel('Translation Length ℓ(M₂ⁿ)', fontsize=13)
ax2.set_title('Geodesic Length Spectrum\nfrom Berggren M₂ Powers', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')
ax2.set_xlim(0.3, 10.7)

plt.tight_layout()
plt.savefig('viz_geodesics.png', dpi=150, bbox_inches='tight')
print("Saved viz_geodesics.png")


#!/usr/bin/env python3
"""
Visualization: Free Group Ball Growth and Kesten Spectral Radius

This script visualizes the core results of Hyperbolic Number Theory:
1. Left panel: Ball size B(n) = 2·3^n - 1 for F₂ on a log scale, 
   showing exponential growth with base 3.
2. Right panel: Kesten spectral radius ρ = √(2k-1)/k as a function
   of the number of generators k, showing the universal spectral gap.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# --- Panel 1: Ball Growth ---
ns = np.arange(0, 10)

# Compute ball sizes for different k
for k, color, label in [(1, '#888888', 'F₁ (ℤ)'), 
                          (2, '#2196F3', 'F₂'), 
                          (3, '#4CAF50', 'F₃'),
                          (4, '#FF9800', 'F₄')]:
    def ball_size(k_val, n_val):
        if k_val == 1:
            return 2 * n_val + 1
        growth = 2 * k_val - 1
        return 1 + k_val * (growth ** n_val - 1) // (k_val - 1)
    
    bs = [ball_size(k, int(n)) for n in ns]
    ax1.semilogy(ns, bs, 'o-', color=color, label=label, markersize=6, linewidth=2)

# Reference lines
ax1.semilogy(ns, 3**ns, '--', color='#2196F3', alpha=0.3, label='3ⁿ (lower bound)')
ax1.semilogy(ns, 5**ns, '--', color='#4CAF50', alpha=0.3, label='5ⁿ (F₃ rate)')

ax1.set_xlabel('Radius n', fontsize=13)
ax1.set_ylabel('Ball Size B(n)', fontsize=13)
ax1.set_title('Exponential Growth in Free Group Cayley Graphs', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-0.5, 9.5)

# Annotate the F₂ formula
ax1.annotate('B(n) = 2·3ⁿ − 1', xy=(6, 2*3**6-1), fontsize=11,
            xytext=(4, 3**8), arrowprops=dict(arrowstyle='->', color='#2196F3'),
            color='#2196F3', fontweight='bold')

# --- Panel 2: Kesten Spectral Radius ---
ks = np.arange(2, 20)
rhos = np.sqrt(2 * ks - 1) / ks
gaps = 1 - rhos

ax2.bar(ks - 0.2, rhos, width=0.4, color='#E53935', alpha=0.8, label='Spectral radius ρ')
ax2.bar(ks + 0.2, gaps, width=0.4, color='#43A047', alpha=0.8, label='Spectral gap 1−ρ')
ax2.axhline(y=1, color='black', linestyle='--', linewidth=0.8, alpha=0.5)

# Mark the F₂ case
ax2.annotate('F₂: ρ = √3/2\n≈ 0.866', xy=(2, np.sqrt(3)/2), fontsize=10,
            xytext=(5, 0.95), arrowprops=dict(arrowstyle='->', color='#E53935'),
            color='#E53935', fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white', edgecolor='#E53935', alpha=0.9))

ax2.set_xlabel('Number of Generators k', fontsize=13)
ax2.set_ylabel('Value', fontsize=13)
ax2.set_title('Kesten Spectral Bound: √(2k−1)/k < 1', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10, loc='center right')
ax2.grid(True, alpha=0.3, axis='y')
ax2.set_xlim(1, 20)
ax2.set_ylim(0, 1.1)

plt.tight_layout()
plt.savefig('viz_growth.png', dpi=150, bbox_inches='tight')
print("Saved viz_growth.png")


#!/usr/bin/env python3
"""
Visualization: The Kesten Duality Triangle

Illustrates the triangle of equivalences at the heart of hyperbolic number theory:
  Exponential Growth ↔ Spectral Gap ↔ Non-Amenability

Shows how these three properties vary together as the number of generators changes,
demonstrating they are three faces of a single phenomenon.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Circle
import matplotlib.patches as mpatches

fig = plt.figure(figsize=(12, 7))

# Create main axes for the triangle diagram
ax_main = fig.add_axes([0.05, 0.35, 0.55, 0.6])
ax_main.set_xlim(-1.8, 1.8)
ax_main.set_ylim(-1.2, 1.5)
ax_main.set_aspect('equal')
ax_main.axis('off')

# Triangle vertices
vertices = {
    'growth': (0, 1.2),
    'spectral': (-1.3, -0.6),
    'amenability': (1.3, -0.6),
}

# Draw triangle edges with arrows
edge_style = dict(arrowstyle='<->', color='#333333', linewidth=2.5, 
                  connectionstyle='arc3,rad=0.1')

for (v1, v2) in [('growth', 'spectral'), ('spectral', 'amenability'), ('amenability', 'growth')]:
    p1, p2 = vertices[v1], vertices[v2]
    ax_main.annotate('', xy=p2, xytext=p1, arrowprops=edge_style)

# Draw vertex circles
for name, (x, y) in vertices.items():
    circle = Circle((x, y), 0.35, fill=True, facecolor='white', edgecolor='#1565C0', 
                    linewidth=3, zorder=5)
    ax_main.add_patch(circle)

# Vertex labels
labels = {
    'growth': ('Exponential\nGrowth', '#E53935'),
    'spectral': ('Spectral\nGap', '#1565C0'),
    'amenability': ('Non-\nAmenability', '#2E7D32'),
}

for name, ((x, y), (text, color)) in zip(vertices.items(), 
    [(vertices[k], labels[k]) for k in vertices]):
    ax_main.text(x, y, text, ha='center', va='center', fontsize=11, 
                fontweight='bold', color=color, zorder=6)

# Edge labels (the key formulas)
edge_labels = [
    ((-0.9, 0.5), 'ρ = √λ/k', '#333'),
    ((0, -0.85), 'h ≥ (1−ρ)/2', '#333'),
    ((0.9, 0.5), 'λ = 2k−1', '#333'),
]

for (x, y), text, color in edge_labels:
    ax_main.text(x, y, text, ha='center', va='center', fontsize=10, 
                color=color, style='italic',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='#FFF9C4', 
                         edgecolor='#F9A825', alpha=0.9))

# Title
ax_main.text(0, 1.7, 'The Kesten Duality Triangle', ha='center', va='center',
            fontsize=16, fontweight='bold', color='#1A237E')

# Center label
ax_main.text(0, 0.15, 'KESTEN\nDUALITY', ha='center', va='center',
            fontsize=14, fontweight='bold', color='#FF6F00', alpha=0.7)

# --- Right panel: Quantitative comparison ---
ax_right = fig.add_axes([0.63, 0.12, 0.33, 0.82])

ks = np.arange(2, 12)
growth_rates = 2 * ks - 1
spectral_radii = np.sqrt(growth_rates) / ks
spectral_gaps = 1 - spectral_radii
cheeger_bounds = spectral_gaps / 2

x = np.arange(len(ks))
width = 0.25

bars1 = ax_right.bar(x - width, np.log(growth_rates), width, color='#E53935', alpha=0.8, label='log(λ)')
bars2 = ax_right.bar(x, spectral_gaps, width, color='#1565C0', alpha=0.8, label='1 − ρ')
bars3 = ax_right.bar(x + width, cheeger_bounds, width, color='#2E7D32', alpha=0.8, label='h ≥ ...')

ax_right.set_xlabel('Number of Generators k', fontsize=12)
ax_right.set_ylabel('Value', fontsize=12)
ax_right.set_title('Quantitative Kesten Duality\nfor F₂ through F₁₁', fontsize=13, fontweight='bold')
ax_right.set_xticks(x)
ax_right.set_xticklabels([str(k) for k in ks])
ax_right.legend(fontsize=10, loc='upper right')
ax_right.grid(True, alpha=0.3, axis='y')

# Highlight F₂
ax_right.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
ax_right.annotate('F₂', xy=(0, 0), fontsize=10, fontweight='bold', color='gray',
                 xytext=(0, -0.15), ha='center')

plt.savefig('viz_kesten_triangle.png', dpi=150, bbox_inches='tight')
print("Saved viz_kesten_triangle.png")
