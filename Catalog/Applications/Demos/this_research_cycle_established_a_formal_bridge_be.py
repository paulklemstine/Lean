"""
Chromatic Capacity Theory: Real-World Applications

Demonstrates practical applications of chromatic capacity theory to:
1. Social network emotional diversity analysis
2. Communication channel design
3. Resource allocation under conflict constraints
"""

from math import log, factorial, comb
from typing import Dict, List, Set, Tuple, Optional


def desc_factorial(k: int, n: int) -> int:
    """Falling factorial k^{(n)}."""
    result = 1
    for i in range(n):
        result *= (k - i)
    return result


def chromatic_capacity(n: int, k: int) -> float:
    """Chromatic capacity C(K_n, k) = ln(k^{(n)}) / n."""
    if n == 0:
        return 0.0
    df = desc_factorial(k, n)
    if df <= 0:
        return float('-inf')
    return log(df) / n


# =============================================================
# APPLICATION 1: Social Network Emotional Diversity
# =============================================================

def analyze_emotional_diversity():
    """Analyze emotional diversity in a social network.
    
    Models a workplace social network where we assign emotional
    categories to individuals, requiring that connected individuals
    express sufficiently different emotions.
    """
    print("=" * 60)
    print("  APPLICATION 1: Workplace Emotional Diversity")
    print("=" * 60)
    
    # Define a workplace social network
    network = {
        "Manager":    ["Engineer1", "Engineer2", "Designer"],
        "Engineer1":  ["Manager", "Engineer2", "QA"],
        "Engineer2":  ["Manager", "Engineer1", "Designer"],
        "Designer":   ["Manager", "Engineer2", "Marketing"],
        "QA":         ["Engineer1", "Marketing"],
        "Marketing":  ["Designer", "QA", "Sales"],
        "Sales":      ["Marketing"],
    }
    
    # Compute max degree
    max_deg = max(len(friends) for friends in network.values())
    print(f"\n  Network has {len(network)} people, max degree Δ = {max_deg}")
    print(f"  Need at most Δ + 1 = {max_deg + 1} emotional categories")
    
    # Emotional categories (Ekman's six + neutral)
    emotions = ["Joy", "Sadness", "Anger", "Fear", "Surprise", "Disgust", "Neutral"]
    
    # Greedy coloring
    coloring: Dict[str, str] = {}
    for person in network:
        used = {coloring[f] for f in network[person] if f in coloring}
        for emotion in emotions:
            if emotion not in used:
                coloring[person] = emotion
                break
    
    print(f"\n  Emotional assignment (greedy coloring):")
    for person, emotion in coloring.items():
        print(f"    {person:12s} → {emotion}")
    
    unique_emotions = len(set(coloring.values()))
    print(f"\n  Distinct emotions used: {unique_emotions}")
    print(f"  Six Emotions Theorem applies: {'YES ✓' if max_deg <= 5 else 'NO (Δ > 5)'}")
    
    # Verify properness
    proper = all(
        coloring[p] != coloring[f]
        for p in network
        for f in network[p]
    )
    print(f"  Coloring is proper: {'YES ✓' if proper else 'NO ✗'}")


# =============================================================
# APPLICATION 2: Communication Channel Design
# =============================================================

def analyze_channel_capacity():
    """Design communication channels using chromatic capacity.
    
    In a network where n stations must transmit simultaneously,
    each pair must use different frequencies. The chromatic capacity
    tells us the maximum information rate per station.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Communication Channel Design")
    print("=" * 60)
    
    print("\n  Scenario: n radio stations need distinct frequencies")
    print("  Available frequencies: k")
    print("  Channel capacity: C(n, k) = ln(P(K_n, k)) / n bits/station\n")
    
    print(f"  {'Stations':>8} {'Freq':>5} {'Colorings':>12} {'Capacity':>10} {'Bit rate':>10}")
    print(f"  {'-'*8:>8} {'-'*5:>5} {'-'*12:>12} {'-'*10:>10} {'-'*10:>10}")
    
    for n in [2, 3, 5, 10]:
        for k in [n, 2*n, 10*n]:
            if k >= n:
                df = desc_factorial(k, n)
                cap = chromatic_capacity(n, k)
                bit_rate = cap / log(2) if cap > 0 else 0
                print(f"  {n:>8} {k:>5} {df:>12,} {cap:>10.3f} {bit_rate:>10.3f}")
        print()
    
    # Information-theoretic insight
    print("  Key insight: Capacity approaches ln(k) as k >> n")
    print("  This means dense networks lose little capacity per station")
    for n in [2, 5, 10, 20]:
        k = 100
        cap = chromatic_capacity(n, k)
        max_cap = log(k)
        efficiency = cap / max_cap * 100
        print(f"    n={n:3d}, k={k}: efficiency = {efficiency:.1f}%")


# =============================================================
# APPLICATION 3: Resource Allocation
# =============================================================

def analyze_resource_allocation():
    """Resource allocation under conflict constraints.
    
    Given n tasks with pairwise conflicts, allocate k resource types
    such that conflicting tasks use different resources.
    The chromatic polynomial tells us how many valid allocations exist.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Task Resource Allocation")
    print("=" * 60)
    
    # Example: 5 tasks, some conflicting
    tasks = ["CompileA", "CompileB", "TestA", "TestB", "Deploy"]
    conflicts = [
        ("CompileA", "CompileB"),   # Can't compile simultaneously
        ("CompileA", "TestA"),      # Can't test while compiling
        ("CompileB", "TestB"),      # Same
        ("TestA", "TestB"),         # Tests interfere
        ("TestA", "Deploy"),        # Can't deploy while testing
        ("TestB", "Deploy"),        # Same
    ]
    
    n = len(tasks)
    m = len(conflicts)
    
    print(f"\n  {n} tasks, {m} conflict pairs")
    print(f"  This forms a graph with chromatic number ≥ 3\n")
    
    # For a complete graph K_n, P(K_n, k) = k^{(n)}
    # Our graph is not complete, but we can compute bounds
    print(f"  If fully conflicting (K_{n}): P(K_{n}, k) = k^{{({n})}}")
    for k in [3, 4, 5, 6, 10]:
        if k >= n:
            count = desc_factorial(k, n)
            print(f"    k={k:2d} resources: {count:>8,} valid allocations")
    
    print(f"\n  Lower bound (our sparse graph): more allocations than K_{n}")
    print(f"  Upper bound (empty graph): k^{n} = k^{n} allocations")
    for k in [3, 4, 5, 6, 10]:
        lower = desc_factorial(k, n)
        upper = k ** n
        print(f"    k={k:2d}: {lower:>8,} <= actual <= {upper:>8,}")
    
    # Greedy coloring of the conflict graph
    adj = {t: set() for t in tasks}
    for u, v in conflicts:
        adj[u].add(v)
        adj[v].add(u)
    
    resources = ["CPU-A", "CPU-B", "GPU-1", "GPU-2", "FPGA"]
    coloring: Dict[str, str] = {}
    for task in tasks:
        used = {coloring[f] for f in adj[task] if f in coloring}
        for res in resources:
            if res not in used:
                coloring[task] = res
                break
    
    print(f"\n  Resource assignment (greedy):")
    for task, res in coloring.items():
        print(f"    {task:12s} → {res}")
    
    used_resources = len(set(coloring.values()))
    print(f"\n  Resources used: {used_resources} out of {len(resources)} available")


if __name__ == "__main__":
    analyze_emotional_diversity()
    analyze_channel_capacity()
    analyze_resource_allocation()


"""
Chromatic Capacity Theory: Demonstrations

This module demonstrates the key results from our chromatic capacity theory,
showing how graph coloring connects to information theory and social networks.
"""

from math import factorial, log, comb
from typing import List, Tuple, Dict


def desc_factorial(k: int, n: int) -> int:
    """Compute the falling factorial k^{(n)} = k * (k-1) * ... * (k-n+1)."""
    result = 1
    for i in range(n):
        result *= (k - i)
    return result


def chromatic_capacity(n: int, k: int) -> float:
    """Compute the chromatic capacity C(K_n, k) = ln(k^{(n)}) / n."""
    if n == 0:
        return 0.0
    df = desc_factorial(k, n)
    if df <= 0:
        return float('-inf')
    return log(df) / n


def tropical_chromatic_val(n: int, k: int) -> int:
    """Compute the tropical chromatic value."""
    if n == 0:
        return 0
    return k - n + 1


def verify_pow_sub_bound(k: int, n: int) -> Tuple[int, int, bool]:
    """Verify the conjecture: k^n - k^{(n)} <= C(n,2) * k^{n-1}."""
    pow_val = k ** n
    desc_val = desc_factorial(k, n)
    diff = pow_val - desc_val
    bound = comb(n, 2) * (k ** (n - 1)) if n >= 1 else 0
    return diff, bound, diff <= bound


def print_separator(title: str):
    print(f"\n{'=' * 60}")
    print(f"  {title}")
    print(f"{'=' * 60}\n")


def demo_chromatic_polynomial():
    """Demonstrate the complete graph chromatic polynomial."""
    print_separator("Complete Graph Chromatic Polynomial P(K_n, k)")

    print("The chromatic polynomial P(K_n, k) counts proper k-colorings of K_n.")
    print("It equals the falling factorial k^{(n)} = k(k-1)...(k-n+1).\n")

    for n in range(1, 6):
        print(f"  K_{n}:")
        for k in [n, n + 1, n + 2, 5, 10]:
            if k >= n:
                df = desc_factorial(k, n)
                print(f"    P(K_{n}, {k:2d}) = {df:>10,}")
        print()


def demo_bounds():
    """Demonstrate upper and lower bounds on the chromatic polynomial."""
    print_separator("Bounds on the Chromatic Polynomial")

    print("Upper bound: k^{(n)} <= k^n")
    print("Lower bound: (k-n+1)^n <= k^{(n)}\n")

    for n in [2, 3, 4, 5]:
        for k in [n, 2 * n, 10]:
            if k >= n:
                lower = (k - n + 1) ** n
                actual = desc_factorial(k, n)
                upper = k ** n
                print(f"  n={n}, k={k:2d}: {lower:>10,} <= {actual:>10,} <= {upper:>10,}")
        print()


def demo_capacity():
    """Demonstrate chromatic capacity."""
    print_separator("Chromatic Capacity C(K_n, k) = ln(P(K_n, k)) / n")

    print("The chromatic capacity measures information content per vertex.\n")

    for n in [1, 2, 3, 4, 5]:
        print(f"  K_{n}:")
        for k in [n, n + 1, 2 * n, 10, 100]:
            if k >= n:
                cap = chromatic_capacity(n, k)
                print(f"    C(K_{n}, {k:3d}) = {cap:.4f} nats")
        print()


def demo_tropical():
    """Demonstrate tropical chromatic values."""
    print_separator("Tropical Chromatic Values")

    print("The tropical chromatic value T(n,k) = k - n + 1 detects colorability.\n")

    for n in [1, 2, 3, 4, 5]:
        print(f"  K_{n}: ", end="")
        for k in range(max(0, n - 2), n + 4):
            tv = tropical_chromatic_val(n, k)
            colorable = "✓" if tv > 0 else ("threshold" if tv == 0 else "✗")
            print(f"T({n},{k})={tv}({colorable}) ", end="")
        print()


def demo_divisibility():
    """Demonstrate the cross-domain divisibility result."""
    print_separator("Cross-Domain: n! | k^{(n)} (Graph Coloring ↔ Number Theory)")

    print("The falling factorial k^{(n)} is always divisible by n!.")
    print("Equivalently, the binomial coefficient C(k,n) = k^{(n)}/n! is always an integer.\n")

    for n in [2, 3, 4, 5]:
        fact_n = factorial(n)
        print(f"  n={n}, {n}! = {fact_n}:")
        for k in [n, n + 1, n + 2, 10]:
            if k >= n:
                df = desc_factorial(k, n)
                quotient = df // fact_n
                assert df == fact_n * quotient, "Divisibility failed!"
                print(f"    k={k:2d}: k^({n}) = {df:>6,} = {fact_n} × {quotient} = {fact_n} × C({k},{n})")
        print()


def demo_conjecture():
    """Verify the testable conjecture computationally."""
    print_separator("Testable Conjecture: k^n - k^{(n)} <= C(n,2) * k^{n-1}")

    print("Computational verification:\n")

    all_pass = True
    for n in range(2, 8):
        for k in [n, n + 1, 2 * n, 10, 50, 100]:
            if k >= n:
                diff, bound, ok = verify_pow_sub_bound(k, n)
                status = "✓" if ok else "✗"
                if not ok:
                    all_pass = False
                print(f"  n={n}, k={k:3d}: diff={diff:>15,}, bound={bound:>15,} {status}")
        print()

    print(f"All cases passed: {'YES ✓' if all_pass else 'NO ✗'}")


def demo_emotional_network():
    """Demonstrate the emotional graph coloring concept."""
    print_separator("Emotional Network: Six Emotions Theorem")

    print("In a social network with max degree Δ, we need at most Δ+1 emotional categories.")
    print("For sparse networks (Δ ≤ 5), Ekman's 6 basic emotions always suffice.\n")

    # Example: a social network
    network = {
        "Alice": ["Bob", "Charlie"],
        "Bob": ["Alice", "Diana", "Eve"],
        "Charlie": ["Alice", "Frank"],
        "Diana": ["Bob"],
        "Eve": ["Bob", "Frank"],
        "Frank": ["Charlie", "Eve"]
    }

    # Compute degrees
    print("  Social network adjacency:")
    max_deg = 0
    for person, friends in network.items():
        deg = len(friends)
        max_deg = max(max_deg, deg)
        print(f"    {person}: {friends} (degree {deg})")

    print(f"\n  Maximum degree Δ = {max_deg}")
    print(f"  Colors needed: at most Δ + 1 = {max_deg + 1}")

    emotions = ["happy", "sad", "angry", "afraid", "surprised", "disgusted"]

    # Greedy coloring
    people = list(network.keys())
    coloring: Dict[str, str] = {}
    for person in people:
        used = {coloring[f] for f in network[person] if f in coloring}
        for emotion in emotions:
            if emotion not in used:
                coloring[person] = emotion
                break

    print(f"\n  Proper coloring (greedy):")
    for person, emotion in coloring.items():
        print(f"    {person} → {emotion}")

    # Verify properness
    proper = True
    for person, friends in network.items():
        for friend in friends:
            if coloring[person] == coloring[friend]:
                proper = False
    print(f"\n  Coloring is proper: {'YES ✓' if proper else 'NO ✗'}")
    print(f"  Colors used: {len(set(coloring.values()))}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    CHROMATIC CAPACITY THEORY: INTERACTIVE DEMO          ║")
    print("║    Graph Coloring × Information Theory × Social Science ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_chromatic_polynomial()
    demo_bounds()
    demo_capacity()
    demo_tropical()
    demo_divisibility()
    demo_conjecture()
    demo_emotional_network()


"""
Visualization: Chromatic Polynomial Bounds Heatmap

Creates a heatmap showing the ratio k^{(n)} / k^n (how close the chromatic
polynomial is to the naive upper bound) and the deficit bound verification.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def desc_factorial(k: int, n: int) -> int:
    """Compute falling factorial."""
    result = 1
    for i in range(n):
        result *= max(0, k - i)
    return result


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Ratio k^{(n)} / k^n
ax1 = axes[0]
n_range = range(1, 16)
k_range = range(1, 31)
ratio_matrix = np.zeros((len(list(n_range)), len(list(k_range))))

for i, n in enumerate(n_range):
    for j, k in enumerate(k_range):
        if k >= n and k > 0:
            df = desc_factorial(k, n)
            ratio_matrix[i, j] = df / (k ** n)
        else:
            ratio_matrix[i, j] = 0

im1 = ax1.imshow(ratio_matrix, aspect='auto', origin='lower',
                  extent=[0.5, 30.5, 0.5, 15.5],
                  cmap='viridis', vmin=0, vmax=1)
plt.colorbar(im1, ax=ax1, label='$k^{(n)} / k^n$')
ax1.set_xlabel('Number of colors $k$', fontsize=13)
ax1.set_ylabel('Graph size $n$', fontsize=13)
ax1.set_title('Chromatic Efficiency: $k^{(n)}/k^n$', fontsize=14, fontweight='bold')

# Draw the diagonal k = n (colorability threshold)
ax1.plot([1, 15], [1, 15], 'r--', linewidth=2, alpha=0.7, label='$k = n$ (threshold)')
ax1.legend(loc='upper right', fontsize=10)

# Right: Deficit ratio (k^n - k^{(n)}) / (C(n,2) * k^{n-1})
ax2 = axes[1]
deficit_matrix = np.zeros((len(list(range(2, 13))), len(list(range(2, 31)))))
n_range2 = range(2, 13)
k_range2 = range(2, 31)

for i, n in enumerate(n_range2):
    for j, k in enumerate(k_range2):
        if k >= n:
            deficit = k**n - desc_factorial(k, n)
            bound = comb(n, 2) * k**(n-1)
            if bound > 0:
                deficit_matrix[i, j] = deficit / bound
            else:
                deficit_matrix[i, j] = 0
        else:
            deficit_matrix[i, j] = np.nan

im2 = ax2.imshow(deficit_matrix, aspect='auto', origin='lower',
                  extent=[1.5, 30.5, 1.5, 12.5],
                  cmap='RdYlGn_r', vmin=0, vmax=1)
plt.colorbar(im2, ax=ax2, label='Deficit / Bound ratio')
ax2.set_xlabel('Number of colors $k$', fontsize=13)
ax2.set_ylabel('Graph size $n$', fontsize=13)
ax2.set_title('Deficit Bound: $(k^n - k^{(n)}) / (\\binom{n}{2} k^{n-1})$',
              fontsize=14, fontweight='bold')

# Add text annotation
ax2.text(20, 4, 'Ratio < 1\n(bound holds)', fontsize=11, 
         ha='center', va='center', color='darkgreen',
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.tight_layout()
plt.savefig('bounds_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: bounds_heatmap.png")


"""
Visualization: Chromatic Polynomial Landscape

Visualizes the chromatic polynomial P(K_n, k) = k^{(n)} as a function of k
for various values of n, showing the falling factorial structure and the
sharp threshold at k = n where colorability begins.
"""

import numpy as np
import matplotlib.pyplot as plt


def desc_factorial(k: int, n: int) -> int:
    """Compute falling factorial k^{(n)} = k(k-1)...(k-n+1)."""
    result = 1
    for i in range(n):
        result *= max(0, k - i)
    return result


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Chromatic polynomial P(K_n, k) vs k
ax1 = axes[0]
k_values = np.arange(0, 12)
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
labels = ['$K_1$', '$K_2$', '$K_3$', '$K_4$', '$K_5$']

for n in range(1, 6):
    p_values = [desc_factorial(int(k), n) for k in k_values]
    ax1.plot(k_values, p_values, 'o-', color=colors[n-1], label=labels[n-1],
             linewidth=2, markersize=6)
    # Mark the threshold where colorings become possible
    ax1.axvline(x=n, color=colors[n-1], linestyle=':', alpha=0.3)

ax1.set_xlabel('Number of colors $k$', fontsize=13)
ax1.set_ylabel('Number of proper colorings $P(K_n, k)$', fontsize=13)
ax1.set_title('Chromatic Polynomial of Complete Graphs', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_ylim(-50, 2500)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(range(12))

# Right panel: Chromatic capacity C(K_n, k) = ln(P(K_n,k))/n
ax2 = axes[1]
k_fine = np.arange(1, 21)

for n in range(1, 6):
    cap_values = []
    for k in k_fine:
        df = desc_factorial(int(k), n)
        if df > 0 and n > 0:
            cap_values.append(np.log(df) / n)
        else:
            cap_values.append(np.nan)
    ax2.plot(k_fine, cap_values, 'o-', color=colors[n-1], label=labels[n-1],
             linewidth=2, markersize=4)

# Add the theoretical maximum ln(k)
k_cont = np.linspace(1, 20, 100)
ax2.plot(k_cont, np.log(k_cont), 'k--', linewidth=1.5, alpha=0.5, label='$\\ln(k)$ (max)')

ax2.set_xlabel('Number of colors $k$', fontsize=13)
ax2.set_ylabel('Chromatic capacity $C(K_n, k)$ (nats)', fontsize=13)
ax2.set_title('Chromatic Capacity: Information per Vertex', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('chromatic_polynomial_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: chromatic_polynomial_landscape.png")


"""
Visualization: Tropical Chromatic Phase Diagram

Visualizes the tropical chromatic value T(n,k) = k - n + 1, showing the
phase transition between colorable and non-colorable regimes. The tropical
semiring reveals the sharp threshold structure of graph coloring.
"""

import numpy as np
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Tropical phase diagram
ax1 = axes[0]
n_vals = np.arange(1, 16)
k_vals = np.arange(0, 21)
N, K = np.meshgrid(n_vals, k_vals)
T = K - N + 1

# Color by sign: positive (colorable), zero (threshold), negative (not colorable)
cmap = plt.cm.RdBu
im = ax1.contourf(N, K, T, levels=np.arange(-14, 16, 1), cmap=cmap, alpha=0.8)
ax1.contour(N, K, T, levels=[0], colors='black', linewidths=3)

plt.colorbar(im, ax=ax1, label='Tropical value $T(n,k) = k - n + 1$')
ax1.set_xlabel('Graph size $n$', fontsize=13)
ax1.set_ylabel('Number of colors $k$', fontsize=13)
ax1.set_title('Tropical Phase Diagram', fontsize=14, fontweight='bold')

# Add phase labels
ax1.text(3, 15, 'COLORABLE\n$T > 0$', fontsize=14, fontweight='bold',
         ha='center', va='center', color='darkblue',
         bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.7))
ax1.text(12, 5, 'NOT\nCOLORABLE\n$T < 0$', fontsize=14, fontweight='bold',
         ha='center', va='center', color='darkred',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.7))

# Draw threshold line k = n - 1
ax1.plot(n_vals, n_vals - 1, 'k-', linewidth=3, label='Threshold: $k = n-1$')
ax1.legend(fontsize=11, loc='upper left')

# Right: Capacity scaling
ax2 = axes[1]
k_max = 100
k_range = np.arange(1, k_max + 1)

for n in [1, 2, 3, 5, 10, 20]:
    capacities = []
    for k in k_range:
        # Compute k^{(n)}
        df = 1
        for i in range(n):
            df *= max(0, k - i)
        if df > 0 and n > 0:
            capacities.append(np.log(df) / n)
        else:
            capacities.append(np.nan)
    
    ax2.plot(k_range, capacities, linewidth=2, label=f'$n = {n}$')

# Theoretical maximum
ax2.plot(k_range, np.log(k_range), 'k--', linewidth=1.5, alpha=0.5, label='$\\ln(k)$')

ax2.set_xlabel('Number of colors $k$', fontsize=13)
ax2.set_ylabel('Capacity $C(K_n, k)$ (nats)', fontsize=13)
ax2.set_title('Chromatic Capacity Convergence', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10, ncol=2)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, k_max)
ax2.set_ylim(0, 5)

plt.tight_layout()
plt.savefig('tropical_phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_phase_diagram.png")
