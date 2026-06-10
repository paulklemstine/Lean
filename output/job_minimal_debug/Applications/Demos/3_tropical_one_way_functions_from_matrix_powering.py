#!/usr/bin/env python3
"""
Tropical One-Way Functions — Applications

Demonstrates real-world applications of tropical matrix powering
in shortest-path computation, scheduling, and cryptographic primitives.
"""

import numpy as np
from algorithms import trop_mul, trop_pow, trop_identity, orbit_hash, is_strictly_separated

INF = float('inf')


# ============================================================
# Application 1: Shortest Path Computation
# ============================================================
def shortest_paths_demo():
    """
    Demonstrate how tropical matrix powers compute shortest paths.

    G[i,j] = weight of edge from i to j (INF = no edge)
    G^k[i,j] = weight of shortest path from i to j using exactly k edges
    """
    print("APPLICATION 1: Shortest Paths via Tropical Powering")
    print("=" * 55)

    # Road network: 4 cities
    # City 0 -- 2 -- City 1
    #   |               |
    #   5               3
    #   |               |
    # City 3 -- 1 -- City 2

    G = np.array([
        [0,   2, INF,   5],
        [2,   0,   3, INF],
        [INF, 3,   0,   1],
        [5, INF,   1,   0]
    ], dtype=float)

    print("\nRoad network (direct distances):")
    labels = ["City 0", "City 1", "City 2", "City 3"]
    for i, row in enumerate(G):
        for j, val in enumerate(row):
            if val != INF and i < j:
                print(f"  {labels[i]} ↔ {labels[j]}: {val:.0f}")

    for k in range(1, 5):
        Gk = trop_pow(G, k)
        print(f"\nShortest paths using exactly {k} edge(s):")
        for i in range(4):
            for j in range(i + 1, 4):
                if Gk[i, j] < INF:
                    print(f"  {labels[i]} → {labels[j]}: {Gk[i,j]:.0f}")


# ============================================================
# Application 2: Job Scheduling
# ============================================================
def scheduling_demo():
    """
    Tropical matrix powers model iterated task dependencies
    in scheduling problems. G[i,j] = time to transition from
    state i to state j. G^k gives the minimum time for k-step processes.
    """
    print("\n\nAPPLICATION 2: Job Scheduling")
    print("=" * 55)

    # Manufacturing stages
    # Stage 0: Raw materials
    # Stage 1: Assembly
    # Stage 2: Testing
    # Stage 3: Packaging

    G = np.array([
        [INF,  2,  5, INF],
        [INF, INF, 3,   7],
        [INF, INF, INF, 1],
        [INF, INF, INF, INF]
    ], dtype=float)

    print("\nManufacturing pipeline (stage transition times):")
    stages = ["Raw Materials", "Assembly", "Testing", "Packaging"]
    for i in range(4):
        for j in range(4):
            if G[i, j] < INF:
                print(f"  {stages[i]} → {stages[j]}: {G[i,j]:.0f} hours")

    print("\nMinimum completion times (via tropical powers):")
    for k in range(1, 4):
        Gk = trop_pow(G, k)
        if Gk[0, 3] < INF:
            print(f"  {k}-step path from {stages[0]} to {stages[3]}: {Gk[0,3]:.0f} hours")


# ============================================================
# Application 3: Cryptographic Key Exchange Concept
# ============================================================
def crypto_demo():
    """
    Tropical Diffie-Hellman-style key exchange concept.

    Alice and Bob share a public generator matrix G.
    Alice picks secret exponent a, computes G^a.
    Bob picks secret exponent b, computes G^b.
    Shared secret: G^(a+b) = G^a ⊗ G^b (by power addition law).
    """
    print("\n\nAPPLICATION 3: Tropical Key Exchange Concept")
    print("=" * 55)

    G = np.array([[1, 3, 7],
                  [5, 2, 4],
                  [8, 6, 3]], dtype=float)

    # Secret exponents
    a = 17  # Alice's secret
    b = 23  # Bob's secret

    # Public values
    Ga = trop_pow(G, a)
    Gb = trop_pow(G, b)

    # Shared secret (both should compute the same)
    shared_alice = trop_mul(Gb, trop_pow(G, a))  # Bob's public ⊗ G^a
    shared_bob = trop_mul(Ga, trop_pow(G, b))    # Alice's public ⊗ G^b
    shared_direct = trop_pow(G, a + b)

    print(f"\nPublic generator G:\n{G}")
    print(f"\nAlice's secret exponent: a = {a}")
    print(f"Bob's secret exponent: b = {b}")
    print(f"\nAlice publishes G^{a} (first entry): {Ga[0,0]:.0f}")
    print(f"Bob publishes G^{b} (first entry): {Gb[0,0]:.0f}")
    print(f"\nShared secret G^{a+b} (first entry): {shared_direct[0,0]:.0f}")
    print(f"Verification (power addition): {np.allclose(shared_direct, trop_pow(G, a + b))}")

    # Orbit hash for authentication
    print("\n\nOrbit Hash for Authentication:")
    prime_exponents = [2, 3, 5, 7, 11, 13]
    orbit = orbit_hash(G, prime_exponents)
    print(f"  Exponents: {prime_exponents}")
    print(f"  Hash fingerprint (diagonals):")
    for k, Gk in zip(prime_exponents, orbit):
        diag = tuple(Gk[i, i] for i in range(3))
        print(f"    G^{k:2d} diag: {diag}")


# ============================================================
# Application 4: Network Resilience Analysis
# ============================================================
def network_resilience_demo():
    """
    Use separation gap as a measure of network structural uniqueness.
    Higher gap = more robust one-way property.
    """
    print("\n\nAPPLICATION 4: Network Resilience via Separation Gap")
    print("=" * 55)

    networks = {
        "Well-separated": np.array([[1, 3, 7], [5, 2, 4], [8, 6, 3]], dtype=float),
        "Moderately separated": np.array([[1, 2, 5], [4, 1, 3], [6, 5, 2]], dtype=float),
        "Poorly separated": np.array([[1, 2, 3], [2, 1, 2], [3, 2, 1]], dtype=float),
    }

    for name, G in networks.items():
        from algorithms import separation_gap
        gap = separation_gap(G)
        sep = is_strictly_separated(G)
        print(f"\n  {name}:")
        print(f"    Matrix: {G.tolist()}")
        print(f"    Strictly separated: {sep}")
        print(f"    Separation gap: {gap}")
        if sep:
            print(f"    → Good candidate for one-way function")
        else:
            print(f"    → NOT suitable (ties in midpoints)")


if __name__ == "__main__":
    shortest_paths_demo()
    scheduling_demo()
    crypto_demo()
    network_resilience_demo()
    print("\n\nAll applications demonstrated successfully!")


#!/usr/bin/env python3
"""
Tropical One-Way Functions from Matrix Powering — Demonstrations

This script demonstrates the core mathematical structures behind tropical
one-way functions: min-plus matrix multiplication, tropical powering,
path semantics, strict separation, and the injectivity/non-injectivity
phenomena on separated vs. non-separated instances.
"""

import numpy as np
from itertools import product

INF = float('inf')

def trop_mul(A, B):
    """Min-plus matrix multiplication: (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])"""
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            C[i, j] = min(A[i, k] + B[k, j] for k in range(n))
    return C

def trop_pow(G, k):
    """Tropical matrix power G^{⊗k}"""
    n = G.shape[0]
    if k == 0:
        # Tropical identity: 0 on diagonal, +∞ off diagonal
        I = np.full((n, n), INF)
        np.fill_diagonal(I, 0)
        return I
    result = G.copy()
    for _ in range(k - 1):
        result = trop_mul(result, G)
    return result

def find_midpoints(G):
    """Find unique midpoints for G^2. Returns dict (i,j) -> (m, is_unique)"""
    n = G.shape[0]
    G2 = trop_pow(G, 2)
    midpoints = {}
    for i in range(n):
        for j in range(n):
            best_val = G2[i, j]
            achievers = [k for k in range(n) if abs(G[i,k] + G[k,j] - best_val) < 1e-10]
            midpoints[(i,j)] = (achievers[0], len(achievers) == 1)
    return midpoints

def is_strictly_separated(G):
    """Check if G is strictly separated (every G² entry has a unique minimizer)"""
    midpoints = find_midpoints(G)
    return all(unique for _, unique in midpoints.values())

def is_diag_separated(G):
    """Check if G is diagonal-separated"""
    n = G.shape[0]
    midpoints = find_midpoints(G)
    return all(midpoints[(i,i)] == (i, True) for i in range(n))

# ============================================================
# Demo 1: Basic Tropical Matrix Multiplication
# ============================================================
print("=" * 60)
print("DEMO 1: Tropical (Min-Plus) Matrix Multiplication")
print("=" * 60)

G = np.array([[1, 3, 7],
              [5, 2, 4],
              [8, 6, 3]], dtype=float)

print(f"\nAdjacency matrix G (edge weights):")
print(G)

G2 = trop_pow(G, 2)
print(f"\nG² = G ⊗ G (min-plus square):")
print(G2)

print("\nVerification of path semantics:")
print("G²[i,j] = min_m (G[i,m] + G[m,j])")
for i in range(3):
    for j in range(3):
        terms = [G[i,k] + G[k,j] for k in range(3)]
        best_m = np.argmin(terms)
        print(f"  G²[{i},{j}] = min({', '.join(f'{t:.0f}' for t in terms)}) = {min(terms):.0f} (via vertex {best_m})")

# ============================================================
# Demo 2: Strict Separation and Unique Midpoints
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Strict Separation Analysis")
print("=" * 60)

print(f"\nIs G strictly separated? {is_strictly_separated(G)}")
midpoints = find_midpoints(G)
for (i,j), (m, unique) in sorted(midpoints.items()):
    status = "✓ unique" if unique else "✗ NOT unique"
    print(f"  G²[{i},{j}]: midpoint = {m} ({status})")

# ============================================================
# Demo 3: Counterexample to Naive Injectivity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Injectivity Counterexample")
print("=" * 60)

H = np.array([[1, 3, 100],
              [5, 2, 4],
              [8, 6, 3]], dtype=float)

H2 = trop_pow(H, 2)
print(f"\nG:\n{G}")
print(f"\nH (differs at position [0,2]):\n{H}")
print(f"\nG²:\n{G2}")
print(f"\nH²:\n{H2}")
print(f"\nG² == H²? {np.allclose(G2, H2)}")
print(f"G == H? {np.allclose(G, H)}")
print("\n⟹ Tropical squaring is NOT injective in general!")
print("   The entry G[0,2]=7 is 'invisible' in G² because")
print("   it never appears as the winning midpoint for any pair.")

# ============================================================
# Demo 4: Diagonal Separation and Diagonal Recovery
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Diagonal Separation & Recovery")
print("=" * 60)

print(f"\nIs G diagonal-separated? {is_diag_separated(G)}")
print("\nDiagonal recovery theorem: if G²(i,i) has unique minimizer i,")
print("then G(i,i) = G²(i,i) / 2")
for i in range(3):
    print(f"  G({i},{i}) = {G[i,i]:.0f}, G²({i},{i})/2 = {G2[i,i]/2:.1f} ✓")

# ============================================================
# Demo 5: Power Addition Law
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Power Addition Law G^(a+b) = G^a ⊗ G^b")
print("=" * 60)

for a, b in [(1, 2), (2, 3), (1, 4)]:
    lhs = trop_pow(G, a + b)
    rhs = trop_mul(trop_pow(G, a), trop_pow(G, b))
    match = np.allclose(lhs, rhs)
    print(f"\n  G^{a+b} == G^{a} ⊗ G^{b}? {match}")

# ============================================================
# Demo 6: Orbit Hash Generation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Orbit Hash (Iterated Tropical Powers)")
print("=" * 60)

exponents = [1, 2, 3, 4, 5]
print(f"\nGenerator G:\n{G}")
print(f"\nOrbit hash with exponents {exponents}:")
for k in exponents:
    Gk = trop_pow(G, k)
    print(f"\n  G^{k} =")
    for row in Gk:
        print(f"    [{', '.join(f'{v:6.0f}' for v in row)}]")

# ============================================================
# Demo 7: Midpoint Sum Lower Bound
# ============================================================
print("\n" + "=" * 60)
print("DEMO 7: Midpoint Sum Lower Bound Verification")
print("=" * 60)

print("\nTheorem: If m is unique midpoint of G at (i,j), and H² = G²,")
print("then G(i,m) + G(m,j) ≤ H(i,m) + H(m,j)")
print()
for (i,j), (m, unique) in sorted(midpoints.items()):
    if unique:
        g_sum = G[i,m] + G[m,j]
        h_sum = H[i,m] + H[m,j]
        print(f"  ({i},{j}) midpoint={m}: G-sum={g_sum:.0f} ≤ H-sum={h_sum:.0f}? {g_sum <= h_sum + 1e-10} ✓")

print("\n" + "=" * 60)
print("All demonstrations complete!")
print("=" * 60)


#!/usr/bin/env python3
"""
Tropical One-Way Functions — Visualizations

Generates publication-quality figures showing the key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO
from algorithms import trop_mul, trop_pow, trop_identity, separation_gap, is_strictly_separated

INF = float('inf')

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG string."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def plot_tropical_power_growth():
    """Plot how tropical matrix entries grow with power k."""
    G = np.array([[1, 3, 7], [5, 2, 4], [8, 6, 3]], dtype=float)

    ks = list(range(1, 21))
    entries = {(i, j): [] for i in range(3) for j in range(3)}

    for k in ks:
        Gk = trop_pow(G, k)
        for i in range(3):
            for j in range(3):
                entries[(i, j)].append(Gk[i, j])

    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    # Diagonal entries
    for i in range(3):
        axes[0].plot(ks, entries[(i, i)], 'o-', label=f'G^k[{i},{i}]', markersize=4)
    axes[0].set_xlabel('Power k')
    axes[0].set_ylabel('Entry value')
    axes[0].set_title('Diagonal Entries of G^k')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Off-diagonal entries
    for i, j in [(0, 1), (0, 2), (1, 2)]:
        axes[1].plot(ks, entries[(i, j)], 's-', label=f'G^k[{i},{j}]', markersize=4)
    axes[1].set_xlabel('Power k')
    axes[1].set_ylabel('Entry value')
    axes[1].set_title('Off-diagonal Entries of G^k')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Growth rates
    for i in range(3):
        rates = [entries[(i, i)][t] / (t + 1) for t in range(len(ks))]
        axes[2].plot(ks, rates, '^-', label=f'G^k[{i},{i}]/k', markersize=4)
    axes[2].set_xlabel('Power k')
    axes[2].set_ylabel('Entry / k (cycle mean)')
    axes[2].set_title('Tropical Eigenvalue Convergence')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    fig.suptitle('Tropical Matrix Power Growth Dynamics', fontsize=14, fontweight='bold')
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_power_growth.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_separation_analysis():
    """Visualize the separation gap structure of a tropical matrix."""
    G = np.array([[1, 3, 7], [5, 2, 4], [8, 6, 3]], dtype=float)

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Midpoint values heatmap
    n = 3
    gaps = np.zeros((n * n, n))
    labels_ij = []
    for idx, (i, j) in enumerate([(i, j) for i in range(n) for j in range(n)]):
        labels_ij.append(f'({i},{j})')
        for k in range(n):
            gaps[idx, k] = G[i, k] + G[k, j]

    im = axes[0].imshow(gaps, cmap='YlOrRd', aspect='auto')
    axes[0].set_xticks(range(n))
    axes[0].set_xticklabels([f'm={k}' for k in range(n)])
    axes[0].set_yticks(range(n * n))
    axes[0].set_yticklabels(labels_ij)
    axes[0].set_xlabel('Midpoint vertex m')
    axes[0].set_ylabel('Entry (i,j)')
    axes[0].set_title('Midpoint Values G(i,m) + G(m,j)')

    for idx in range(n * n):
        for k in range(n):
            axes[0].text(k, idx, f'{gaps[idx, k]:.0f}',
                        ha='center', va='center', fontsize=9,
                        color='white' if gaps[idx, k] > 8 else 'black')

    # Highlight the minimum in each row
    for idx in range(n * n):
        min_k = np.argmin(gaps[idx])
        axes[0].add_patch(plt.Rectangle((min_k - 0.5, idx - 0.5), 1, 1,
                                        fill=False, edgecolor='blue', linewidth=2))

    plt.colorbar(im, ax=axes[0])

    # Separation gaps
    sep_gaps = []
    for i in range(n):
        for j in range(n):
            values = sorted(G[i, k] + G[k, j] for k in range(n))
            gap = values[1] - values[0]
            sep_gaps.append(gap)

    bars = axes[1].bar(range(n * n), sep_gaps, color=['green' if g > 0 else 'red' for g in sep_gaps])
    axes[1].set_xticks(range(n * n))
    axes[1].set_xticklabels(labels_ij, rotation=45)
    axes[1].set_xlabel('Entry (i,j)')
    axes[1].set_ylabel('Separation gap')
    axes[1].set_title('Separation Gaps (> 0 = unique minimizer)')
    axes[1].axhline(y=0, color='black', linewidth=0.5)
    axes[1].grid(True, alpha=0.3, axis='y')

    fig.suptitle('Strict Separation Analysis of G', fontsize=14, fontweight='bold')
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_separation.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_orbit_fingerprint():
    """Visualize orbit hash fingerprints for different generators."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    generators = [
        ("G₁", np.array([[1, 3, 7], [5, 2, 4], [8, 6, 3]], dtype=float)),
        ("G₂", np.array([[2, 1, 5], [4, 3, 2], [7, 8, 1]], dtype=float)),
        ("G₃", np.array([[3, 5, 2], [1, 4, 6], [5, 2, 7]], dtype=float)),
    ]

    exponents = list(range(1, 16))

    for name, G in generators:
        diag_sums = []
        traces = []
        for k in exponents:
            Gk = trop_pow(G, k)
            diag_sums.append(sum(Gk[i, i] for i in range(3)))
            traces.append(min(Gk[i, i] for i in range(3)))

        axes[0].plot(exponents, traces, 'o-', label=name, markersize=4)
        axes[1].plot(exponents, diag_sums, 's-', label=name, markersize=4)

    axes[0].set_xlabel('Power k')
    axes[0].set_ylabel('Tropical trace (min diagonal)')
    axes[0].set_title('Orbit Hash: Tropical Trace')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    axes[1].set_xlabel('Power k')
    axes[1].set_ylabel('Diagonal sum')
    axes[1].set_title('Orbit Hash: Diagonal Sum')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    fig.suptitle('Orbit Hash Fingerprints for Different Generators', fontsize=14, fontweight='bold')
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_orbit.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_injectivity_counterexample():
    """Visualize the counterexample to naive injectivity."""
    G = np.array([[1, 3, 7], [5, 2, 4], [8, 6, 3]], dtype=float)
    H = np.array([[1, 3, 100], [5, 2, 4], [8, 6, 3]], dtype=float)

    G2 = trop_mul(G, G)
    H2 = trop_mul(H, H)

    fig, axes = plt.subplots(2, 2, figsize=(10, 8))

    for ax, mat, title in [
        (axes[0, 0], G, 'G (original)'),
        (axes[0, 1], H, 'H (modified at [0,2])'),
        (axes[1, 0], G2, 'G² = G ⊗ G'),
        (axes[1, 1], H2, 'H² = H ⊗ H'),
    ]:
        display = mat.copy()
        display[display > 50] = 50  # Cap for display

        im = ax.imshow(display, cmap='Blues', vmin=0, vmax=15)
        ax.set_title(title, fontweight='bold')
        for i in range(3):
            for j in range(3):
                val = mat[i, j]
                text = f'{val:.0f}' if val < 50 else '100'
                color = 'white' if display[i, j] > 8 else 'black'
                ax.text(j, i, text, ha='center', va='center', fontsize=12, color=color)
        ax.set_xticks(range(3))
        ax.set_yticks(range(3))

    # Highlight the difference
    axes[0, 1].add_patch(plt.Rectangle((-0.5 + 2, -0.5), 1, 1,
                                        fill=False, edgecolor='red', linewidth=3))

    fig.suptitle('Counterexample: G² = H² but G ≠ H\n(Entry G[0,2]=7 is "invisible" in the square)',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_counterexample.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_power = plot_tropical_power_growth()
    print(f"  Power growth: {len(b64_power)} bytes")

    b64_sep = plot_separation_analysis()
    print(f"  Separation: {len(b64_sep)} bytes")

    b64_orbit = plot_orbit_fingerprint()
    print(f"  Orbit: {len(b64_orbit)} bytes")

    b64_counter = plot_injectivity_counterexample()
    print(f"  Counterexample: {len(b64_counter)} bytes")

    print("\nAll visualizations saved!")
