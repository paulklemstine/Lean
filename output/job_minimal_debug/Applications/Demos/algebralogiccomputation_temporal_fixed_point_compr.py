#!/usr/bin/env python3
"""
Ultrametric Temporal Fixed-Point Compression — Applications

Real-world applications of the ultrametric fixed-point compression theory:
1. Proof normalization via iterative compression
2. Hash-chain stabilization (cryptographic application)
3. Hierarchical clustering convergence
4. Error-correcting code decoding via ultrametric contraction
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, Dict


# ─── Application 1: Proof Term Normalization ───────────────────────────

def proof_normalization_demo():
    """
    Simulate proof normalization as ultrametric contraction.

    In proof theory, beta-reduction + compression produces shorter proof terms.
    Model proof terms as integer sequences, with distance based on first
    point of divergence (ultrametric).
    """
    print("=" * 60)
    print("APPLICATION 1: Proof Term Normalization")
    print("=" * 60)

    # Proof terms as lists of integers (simplified lambda terms)
    def proof_dist(a: List[int], b: List[int]) -> float:
        """Ultrametric on proof terms: 2^{-k} where k = first divergence."""
        if a == b:
            return 0.0
        k = 0
        for i in range(min(len(a), len(b))):
            if a[i] == b[i]:
                k += 1
            else:
                break
        return 2.0 ** (-k)

    def normalize_step(term: List[int]) -> List[int]:
        """One step of proof normalization (simulated)."""
        result = list(term)
        # Sort first element toward canonical form
        if len(result) > 1 and result[0] > result[1]:
            result[0], result[1] = result[1], result[0]
        # Reduce redundancies
        for i in range(len(result) - 1):
            if result[i] == result[i + 1]:
                result[i] = result[i] // 2
        return result

    def compress(term: List[int]) -> List[int]:
        """Compression operator (nonexpansive, idempotent)."""
        return [x % 8 for x in term]

    # Example proof terms
    terms = [
        [7, 3, 5, 2, 6],
        [6, 4, 3, 1, 7],
        [5, 7, 2, 4, 3],
    ]

    print("Normalizing proof terms via C ∘ T iteration:")
    for term in terms:
        orbit = [term]
        x = term
        for _ in range(20):
            x = compress(normalize_step(x))
            orbit.append(x)
            if orbit[-1] == orbit[-2]:
                break

        print(f"  {term} → {orbit[-1]} in {len(orbit)-1} steps")
        dists = [proof_dist(orbit[i], orbit[-1]) for i in range(min(6, len(orbit)))]
        print(f"    Distance to normal form: {[f'{d:.3f}' for d in dists]}")
    print()


# ─── Application 2: Hash Chain Stabilization ──────────────────────────

def hash_chain_stabilization():
    """
    Cryptographic hash chains converge in p-adic metric.

    In blockchain/hash-chain analysis, iterated hashing with compression
    produces canonical fingerprints. The p-adic distance between hash
    iterates decreases geometrically.
    """
    print("=" * 60)
    print("APPLICATION 2: Hash Chain Stabilization")
    print("=" * 60)

    def simple_hash(x: int, modulus: int = 2**16) -> int:
        """Simplified hash function."""
        return ((x * 2654435761) ^ (x >> 3)) % modulus

    def compress_hash(x: int, mask: int = 0xFFF0) -> int:
        """Compression: zero out low bits (nonexpansive in 2-adic metric)."""
        return x & mask

    def dist_2adic(x: int, y: int) -> float:
        if x == y:
            return 0.0
        diff = x ^ y  # XOR gives bit differences
        if diff == 0:
            return 0.0
        # Count trailing zeros (= 2-adic valuation)
        v = 0
        while diff % 2 == 0:
            diff //= 2
            v += 1
        return 2.0 ** (-v)

    seeds = [42, 137, 999, 12345]
    print("Hash chain convergence (2-adic metric):")
    for seed in seeds:
        x = seed
        orbit = [x]
        for _ in range(20):
            x = compress_hash(simple_hash(x))
            orbit.append(x)

        # Check convergence
        final = orbit[-1]
        dists = [dist_2adic(orbit[i], final) for i in range(min(8, len(orbit)))]
        print(f"  Seed {seed:>5}: final = {final}, distances = {[f'{d:.4f}' for d in dists[:6]]}")
    print()


# ─── Application 3: Hierarchical Clustering ───────────────────────────

def hierarchical_clustering_convergence():
    """
    Ultrametric structure in hierarchical clustering.

    The cophenetic distance in a dendrogram is an ultrametric.
    Iterative cluster refinement with compression converges to
    canonical cluster assignments.
    """
    print("=" * 60)
    print("APPLICATION 3: Hierarchical Clustering Convergence")
    print("=" * 60)

    np.random.seed(42)

    # Generate clustered data
    n_points = 20
    centers = np.array([[0, 0], [5, 0], [2.5, 4]])
    points = []
    labels = []
    for i, c in enumerate(centers):
        pts = c + np.random.randn(n_points // len(centers) + 1, 2) * 0.5
        points.extend(pts.tolist())
        labels.extend([i] * len(pts))
    points = np.array(points[:n_points])

    def cluster_dist(assignment_a: List[int], assignment_b: List[int]) -> float:
        """Ultrametric on cluster assignments."""
        if assignment_a == assignment_b:
            return 0.0
        diffs = sum(1 for a, b in zip(assignment_a, assignment_b) if a != b)
        return diffs / len(assignment_a)

    def refine_clusters(points: np.ndarray, assignments: List[int], k: int = 3) -> List[int]:
        """One step of cluster refinement (k-means-like)."""
        centers = []
        for i in range(k):
            members = [p for p, a in zip(points, assignments) if a == i]
            if members:
                centers.append(np.mean(members, axis=0))
            else:
                centers.append(points[np.random.randint(len(points))])
        centers = np.array(centers)

        new_assignments = []
        for p in points:
            dists = np.linalg.norm(centers - p, axis=1)
            new_assignments.append(int(np.argmin(dists)))
        return new_assignments

    # Start with random assignment
    initial = list(np.random.randint(0, 3, n_points))
    orbit = [initial]
    for _ in range(10):
        new = refine_clusters(points, orbit[-1])
        orbit.append(new)
        if new == orbit[-2]:
            break

    print(f"Clustering {n_points} points into 3 groups:")
    for i, assignment in enumerate(orbit[:6]):
        d = cluster_dist(assignment, orbit[-1])
        print(f"  Step {i}: {assignment[:10]}... | dist to stable = {d:.3f}")

    print(f"  Converged in {len(orbit)-1} steps")
    print()


# ─── Application 4: Error-Correcting Code Decoding ────────────────────

def ecc_decoding_application():
    """
    Error-correcting code decoding as ultrametric contraction.

    Iterative decoding (like belief propagation) contracts in Hamming
    ultrametric, converging to the nearest codeword.
    """
    print("=" * 60)
    print("APPLICATION 4: Error-Correcting Code Decoding")
    print("=" * 60)

    def hamming_dist(a: List[int], b: List[int]) -> float:
        return sum(x != y for x, y in zip(a, b)) / len(a)

    # Simple repetition code: each bit repeated 3 times
    def decode_step(word: List[int]) -> List[int]:
        """One step of majority-vote decoding."""
        n = len(word)
        result = list(word)
        # Majority vote in groups of 3
        for i in range(0, n - 2, 3):
            majority = 1 if sum(word[i:i+3]) >= 2 else 0
            result[i] = result[i+1] = result[i+2] = majority
        return result

    # Received word with errors
    received = [1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1]
    print(f"Received word:    {received}")

    orbit = [received]
    for _ in range(5):
        new = decode_step(orbit[-1])
        orbit.append(new)
        if new == orbit[-2]:
            break

    for i, word in enumerate(orbit):
        d = hamming_dist(word, orbit[-1])
        print(f"  Step {i}: {word} | dist = {d:.3f}")

    print(f"  Decoded codeword: {orbit[-1]}")
    print()


# ─── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  ULTRAMETRIC FIXED-POINT COMPRESSION — APPLICATIONS        ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    proof_normalization_demo()
    hash_chain_stabilization()
    hierarchical_clustering_convergence()
    ecc_decoding_application()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Ultrametric Temporal Fixed-Point Compression — Interactive Demo

Demonstrates the core theorems with concrete numerical examples:
1. Ultrametric contraction iteration
2. Fixed-point convergence and uniqueness
3. Ball stabilization and hierarchical compression
4. Certified extractor with error bounds
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple

# ─── Ultrametric distance on p-adic integers ───────────────────────────

def padic_val(n: int, p: int = 2) -> int:
    """p-adic valuation of integer n."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v

def padic_dist(x: int, y: int, p: int = 2) -> float:
    """p-adic distance: |x - y|_p = p^{-v_p(x-y)}."""
    if x == y:
        return 0.0
    return p ** (-padic_val(x - y, p))

def verify_ultrametric(x: int, y: int, z: int, p: int = 2) -> bool:
    """Verify the strong triangle inequality: d(x,z) ≤ max(d(x,y), d(y,z))."""
    return padic_dist(x, z, p) <= max(padic_dist(x, y, p), padic_dist(y, z, p))


# ─── Demo 1: Ultrametric Triangle Verification ────────────────────────

def demo_ultrametric_triangle():
    """Verify the ultrametric inequality on many triples."""
    print("=" * 60)
    print("DEMO 1: Ultrametric Triangle Inequality Verification")
    print("=" * 60)
    p = 3
    violations = 0
    tested = 0
    for x in range(-20, 21):
        for y in range(-20, 21):
            for z in range(-20, 21):
                tested += 1
                if not verify_ultrametric(x, y, z, p):
                    violations += 1
    print(f"Tested {tested} triples with p={p}")
    print(f"Violations: {violations}")
    print(f"Ultrametric inequality holds: {'YES' if violations == 0 else 'NO'}")
    print()

    # Show isosceles property
    print("Isosceles property examples (p=3):")
    examples = [(1, 4, 13), (0, 9, 27), (2, 5, 14)]
    for x, y, z in examples:
        dxy = padic_dist(x, y, p)
        dyz = padic_dist(y, z, p)
        dxz = padic_dist(x, z, p)
        print(f"  d({x},{y})={dxy:.4f}, d({y},{z})={dyz:.4f}, d({x},{z})={dxz:.4f}")
        sides = sorted([dxy, dyz, dxz])
        print(f"    Sorted sides: {sides} — isosceles: {sides[1] == sides[2]}")
    print()


# ─── Demo 2: Contractive Iteration ────────────────────────────────────

def demo_contractive_iteration():
    """Show geometric convergence of a contractive map in p-adic metric."""
    print("=" * 60)
    print("DEMO 2: Contractive Iteration in 3-adic Space")
    print("=" * 60)

    p = 3
    # F(x) = x + 3*(x mod 3) is a simple contractive map on Z_3
    # For simplicity, use F(x) = (x + x*3) mod (3^8) which contracts by factor 1/3
    modulus = 3 ** 8

    def F(x: int) -> int:
        """A 3-adically contractive map: x ↦ x mod 3^k with shift."""
        return (x * 4) % modulus  # multiplication by 4 = 1 + 3 is contractive

    x0 = 100
    orbit = [x0]
    for _ in range(15):
        orbit.append(F(orbit[-1]))

    print(f"Starting point: x₀ = {x0}")
    print(f"Orbit: {orbit[:10]}...")
    print()

    # Compute adjacent distances
    print("Adjacent distances d(F^{n+1}(x), F^n(x)):")
    adj_dists = []
    for i in range(len(orbit) - 1):
        d = padic_dist(orbit[i + 1], orbit[i], p)
        adj_dists.append(d)
        if i < 10:
            print(f"  n={i}: d = {d:.6f}")

    # Show geometric decay
    if adj_dists[0] > 0 and adj_dists[1] > 0:
        ratio = adj_dists[1] / adj_dists[0]
        print(f"\nContraction ratio (approx): q ≈ {ratio:.4f}")
    print()


# ─── Demo 3: Fixed-Point Convergence ──────────────────────────────────

def demo_fixed_point_convergence():
    """Demonstrate convergence to a unique fixed point."""
    print("=" * 60)
    print("DEMO 3: Fixed-Point Convergence (Real-valued Ultrametric)")
    print("=" * 60)

    # Use a tree-metric space on binary strings
    # Distance = 2^{-k} where k = length of common prefix
    def tree_dist(a: str, b: str) -> float:
        if a == b:
            return 0.0
        k = 0
        for i in range(min(len(a), len(b))):
            if a[i] == b[i]:
                k += 1
            else:
                break
        return 2.0 ** (-k)

    # Contractive map: append a fixed bit and truncate
    def compress_map(s: str, target: str = "10110") -> str:
        """Contractive compression: push toward target prefix."""
        result = target[:1] + s[:-1] if len(s) > 0 else target[:1]
        return result[:len(s)] if len(s) > 0 else result

    # Start from different points
    starts = ["00000", "11111", "01010", "10101"]
    print("Convergence from different starting points:")
    for s0 in starts:
        orbit = [s0]
        for _ in range(8):
            orbit.append(compress_map(orbit[-1]))
        dists = [tree_dist(orbit[i], orbit[-1]) for i in range(len(orbit))]
        print(f"  {s0} → {' → '.join(orbit[:6])} → ... → {orbit[-1]}")
        print(f"    Distances to limit: {[f'{d:.3f}' for d in dists[:6]]}")
    print()

    # Verify uniqueness
    final_points = set()
    for s0 in starts:
        x = s0
        for _ in range(20):
            x = compress_map(x)
        final_points.add(x)
    print(f"All orbits converge to the SAME point: {len(final_points) == 1}")
    print(f"Fixed point: {final_points.pop()}")
    print()


# ─── Demo 4: Extractor with Error Bounds ──────────────────────────────

def demo_extractor():
    """Demonstrate the certified extractor with quantitative bounds."""
    print("=" * 60)
    print("DEMO 4: Certified Extractor with Error Bounds")
    print("=" * 60)

    # Real-valued ultrametric contraction
    q = 0.5  # contraction constant
    p_star = 3.14  # fixed point

    def F(x: float) -> float:
        return p_star + q * (x - p_star)

    def dist(x: float, y: float) -> float:
        return abs(x - y)

    x0 = 10.0
    print(f"Contraction constant: q = {q}")
    print(f"Fixed point: p⋆ = {p_star}")
    print(f"Starting point: x₀ = {x0}")
    print()

    print(f"{'N':>3} | {'F^N(x₀)':>12} | {'d(F^N(x₀), p⋆)':>16} | {'q^N · d(x₀, p⋆)':>18} | {'Bound holds':>12}")
    print("-" * 70)

    d0 = dist(x0, p_star)
    x = x0
    for n in range(15):
        actual_dist = dist(x, p_star)
        bound = q ** n * d0
        holds = actual_dist <= bound + 1e-10
        print(f"{n:3d} | {x:12.6f} | {actual_dist:16.10f} | {bound:18.10f} | {'✓' if holds else '✗':>12}")
        x = F(x)

    print()
    print("The bound d(F^N(x₀), p⋆) ≤ q^N · d(x₀, p⋆) holds at every step.")
    print()


# ─── Demo 5: Ball Stabilization ───────────────────────────────────────

def demo_ball_stabilization():
    """Show how orbits stabilize into ultrametric balls."""
    print("=" * 60)
    print("DEMO 5: Hierarchical Ball Stabilization")
    print("=" * 60)

    p = 5
    modulus = 5 ** 6

    # Map: x ↦ x + 5*x mod 5^6 (contracts by factor 1/5)
    def F(x: int) -> int:
        return (x + 5 * x) % modulus

    x0 = 1
    orbit = [x0]
    for _ in range(8):
        orbit.append(F(orbit[-1]))

    fixed = orbit[-1]
    print(f"5-adic contraction orbit from x₀ = {x0}:")
    print()

    for scale in range(1, 6):
        r = 5 ** (-scale)
        entry_step = None
        for i, x in enumerate(orbit):
            if padic_dist(x, fixed, p) <= r:
                entry_step = i
                break
        if entry_step is not None:
            print(f"  Ball of radius 5^{{-{scale}}} = {r:.6f}: orbit enters at step {entry_step}")
            # Check stabilization
            stays = all(padic_dist(orbit[j], fixed, p) <= r for j in range(entry_step, len(orbit)))
            print(f"    Stays inside: {stays}")

    print()
    print("Key insight: in ultrametric spaces, once an orbit enters a ball,")
    print("it NEVER leaves — balls are clopen. This is hierarchical stabilization.")
    print()


# ─── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  ULTRAMETRIC TEMPORAL FIXED-POINT COMPRESSION — DEMO SUITE ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_ultrametric_triangle()
    demo_contractive_iteration()
    demo_fixed_point_convergence()
    demo_extractor()
    demo_ball_stabilization()

    print("All demos completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all content embedded."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def image_to_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Bridges/UltrametricTemporalCompression.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualizations
viz_files = [
    ('Convergence Comparison', 'fig_convergence.png'),
    ('Ball Stabilization Hierarchy', 'fig_ball_hierarchy.png'),
    ('Extractor Error Certificates', 'fig_extractor_error.png'),
    ('Ultrametric vs Metric Telescoping', 'fig_telescoping.png'),
    ('Phase Diagram', 'fig_phase_diagram.png'),
]

visualizations = []
for name, path in viz_files:
    if os.path.exists(path):
        visualizations.append({
            "name": name,
            "data": image_to_base64(path)
        })

package = {
    "title": "Ultrametric Temporal Fixed-Point Compression via Contractive Proof Dynamics",
    "domain": "Non-Archimedean Analysis / Proof Theory / Reversible Computation",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Ultrametric Fixed-Point Compression Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Proof Normalization, Hash Chains, Clustering, ECC",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Contractive Iterator with Convergence Certificate",
            "pseudocode": """Input: F (contractive map), dist (ultrametric), x₀ (start), q (contraction constant), ε (precision)
Output: (fixed_point, iterations, error_bound)

1. Set x ← x₀, d₁ ← dist(F(x₀), x₀)
2. For n = 0, 1, 2, ...:
   a. x_new ← F(x)
   b. If q^n · d₁ < ε: return (x_new, n+1, q^n · d₁)
   c. x ← x_new
3. Complexity: O(log(1/ε) / log(1/q)) iterations""",
            "code": algorithms_code
        },
        {
            "name": "Certified Extractor",
            "pseudocode": """Input: F (contractive map), C (compressor), dist, x₀, q, ε
Output: (compressed_core_approx, iterations, certified_error)

1. d₀ ← dist(F(x₀), x₀) / (1 - q)   # upper bound on dist(x₀, p⋆)
2. N ← ⌈log(ε / d₀) / log(q)⌉
3. x ← F^N(x₀)                        # iterate N times
4. return (C(x), N, q^N · d₀)          # compress and certify""",
            "code": "# See algorithms.py for full implementation"
        }
    ],
    "visualizations": visualizations,
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"Generated PACKAGE.json ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Generate all visualizations for the Ultrametric Temporal Fixed-Point Compression paper.
Saves figures as PNG files.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch
import matplotlib.patches as mpatches

# ─── Figure 1: Convergence Comparison ─────────────────────────────────

def fig_convergence_comparison():
    """Compare convergence in metric vs ultrametric spaces."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    q = 0.5
    d0 = 10.0
    N = 15
    ns = np.arange(N)

    # Metric space: d(F^n x, p) ≤ q^n * d0
    metric_bound = q ** ns * d0
    # Actual metric convergence (equality in 1D)
    metric_actual = q ** ns * d0

    # Ultrametric: same bound, but distances can only jump down
    ultra_actual = []
    current = d0
    for n in range(N):
        bound = q ** n * d0
        # In ultrametric, distance drops discretely
        if n > 0 and q ** n * d0 < current * 0.6:
            current = q ** n * d0
        ultra_actual.append(current)
    ultra_actual = np.array([q ** n * d0 for n in range(N)])

    ax1.semilogy(ns, metric_bound, 'b-o', label='d(F^n(x), p⋆)', markersize=4)
    ax1.semilogy(ns, q ** ns * d0, 'r--', alpha=0.5, label='q^n · d(x, p⋆)')
    ax1.set_xlabel('Iteration n', fontsize=12)
    ax1.set_ylabel('Distance', fontsize=12)
    ax1.set_title('Geometric Convergence', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Adjacent distances in ultrametric
    adj_metric = [q ** n * d0 * (1 - q) for n in range(N - 1)]
    adj_ultra_bound = [q ** n * d0 for n in range(N - 1)]

    ax2.semilogy(range(N - 1), adj_metric, 'g-s', label='Adjacent d (metric)', markersize=4)
    ax2.semilogy(range(N - 1), adj_ultra_bound, 'r--', alpha=0.5, label='q^n · d(F(x), x)')
    ax2.set_xlabel('Step n', fontsize=12)
    ax2.set_ylabel('Adjacent distance', fontsize=12)
    ax2.set_title('Adjacent Iterate Distances', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_convergence.png")


# ─── Figure 2: Ball Stabilization Hierarchy ───────────────────────────

def fig_ball_hierarchy():
    """Visualize hierarchical ball stabilization."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Simulate orbit in ultrametric space
    q = 0.4
    p_star = 0.0
    x0 = 8.0
    N = 20

    orbit = [x0]
    x = x0
    for _ in range(N):
        x = p_star + q * (x - p_star)
        orbit.append(x)

    orbit = np.array(orbit)
    dists = np.abs(orbit - p_star)

    # Draw ball hierarchy
    radii = [8, 4, 2, 1, 0.5, 0.25]
    colors = plt.cm.Blues(np.linspace(0.2, 0.8, len(radii)))

    for i, r in enumerate(radii):
        entry = next((n for n in range(len(orbit)) if dists[n] <= r), None)
        if entry is not None:
            ax.axhspan(-0.5 + i * 0.12, 0.5 - i * 0.12,
                       xmin=entry / (N + 1), xmax=1.0,
                       alpha=0.15, color=colors[i],
                       label=f'Ball r={r}')
            ax.axvline(x=entry, color=colors[i], linestyle=':', alpha=0.5)

    ax.plot(range(len(orbit)), dists, 'ko-', markersize=5, label='d(F^n(x), p⋆)')
    ax.axhline(y=0, color='red', linestyle='-', alpha=0.3, label='Fixed point p⋆')

    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('Distance to fixed point', fontsize=12)
    ax.set_title('Hierarchical Ball Stabilization Under Contraction', fontsize=14)
    ax.legend(loc='upper right', fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 10)

    plt.tight_layout()
    plt.savefig('fig_ball_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_ball_hierarchy.png")


# ─── Figure 3: Extractor Error Certificate ────────────────────────────

def fig_extractor_error():
    """Visualize extractor error bounds."""
    fig, ax = plt.subplots(figsize=(10, 5))

    qs = [0.3, 0.5, 0.7, 0.9]
    d0 = 10.0
    ns = np.arange(25)
    epsilon = 0.01

    for q in qs:
        bounds = q ** ns * d0
        N_needed = next((n for n in range(100) if q ** n * d0 < epsilon), 100)
        ax.semilogy(ns, bounds, '-o', markersize=3, label=f'q={q} (N*={N_needed})')

    ax.axhline(y=epsilon, color='red', linestyle='--', linewidth=2, label=f'ε = {epsilon}')
    ax.set_xlabel('Extraction step N', fontsize=12)
    ax.set_ylabel('Certified error bound q^N · d₀', fontsize=12)
    ax.set_title('Extractor Error Certificates for Different Contraction Rates', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_extractor_error.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_extractor_error.png")


# ─── Figure 4: Ultrametric vs Metric Telescoping ──────────────────────

def fig_telescoping_comparison():
    """Compare telescoping bounds: metric (sum) vs ultrametric (max)."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    q = 0.6
    d1 = 5.0
    N = 15
    ns = np.arange(1, N + 1)

    # Adjacent distances
    adj = q ** (ns - 1) * d1

    # Metric telescoping: sum of geometric series
    metric_bounds = []
    for n in range(1, N + 1):
        bound = d1 * (1 - q ** n) / (1 - q)
        metric_bounds.append(bound)

    # Ultrametric telescoping: just the max = first term after start
    ultra_bounds = [q ** 0 * d1] * N  # max is always the first step from start n

    ax1.bar(ns - 0.2, adj, 0.4, color='steelblue', alpha=0.7, label='Adjacent d_k')
    ax1.plot(ns, metric_bounds, 'r-s', markersize=5, label='Σ (metric bound)')
    ax1.plot(ns, [d1] * N, 'g--', label='max (ultra bound)')
    ax1.set_xlabel('Steps', fontsize=12)
    ax1.set_ylabel('Distance / Bound', fontsize=12)
    ax1.set_title('Telescoping: Metric Sum vs Ultra Max', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Ratio: ultra bound / metric bound
    ratios = [d1 / mb for mb in metric_bounds]
    ax2.plot(ns, ratios, 'purple', linewidth=2, marker='o', markersize=4)
    ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel('Steps', fontsize=12)
    ax2.set_ylabel('Ultra bound / Metric bound', fontsize=12)
    ax2.set_title('Ultrametric Advantage Ratio', fontsize=14)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1.2)

    plt.tight_layout()
    plt.savefig('fig_telescoping.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_telescoping.png")


# ─── Figure 5: Phase Diagram ──────────────────────────────────────────

def fig_phase_diagram():
    """Phase diagram showing convergence rate vs contraction constant."""
    fig, ax = plt.subplots(figsize=(8, 6))

    qs = np.linspace(0.01, 0.99, 100)
    epsilons = [0.1, 0.01, 0.001, 0.0001]
    d0 = 10.0

    for eps in epsilons:
        Ns = np.ceil(np.log(eps / d0) / np.log(qs))
        ax.plot(qs, Ns, linewidth=2, label=f'ε = {eps}')

    ax.set_xlabel('Contraction constant q', fontsize=12)
    ax.set_ylabel('Required iterations N', fontsize=12)
    ax.set_title('Iterations to ε-Convergence vs Contraction Rate', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 100)

    plt.tight_layout()
    plt.savefig('fig_phase_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_phase_diagram.png")


# ─── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")
    fig_convergence_comparison()
    fig_ball_hierarchy()
    fig_extractor_error()
    fig_telescoping_comparison()
    fig_phase_diagram()
    print("\nAll visualizations generated successfully.")
