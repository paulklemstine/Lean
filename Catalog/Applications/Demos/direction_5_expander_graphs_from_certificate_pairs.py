#!/usr/bin/env python3
"""
Applications of Certificate-Based Expander Graphs

Demonstrates real-world applications of the algebraic certificate → spectral
expansion pipeline:

1. Pseudorandom sampling of group elements
2. Robust communication network design
3. Derandomization via expander walks
4. Hash function construction from Cayley graphs

Keywords: derandomization, pseudorandom walks, robust networks, mixing time
"""

import numpy as np
from algorithms import (
    MatrixGroup, CertificateVerifier, CayleyGraph, SpectralAnalyzer,
    certificate_expansion_pipeline
)


# ============================================================================
# Application 1: Pseudorandom Group Element Sampling
# ============================================================================

def pseudorandom_sampling(q: int = 3, walk_length: int = 20, num_samples: int = 100):
    """Generate pseudorandom elements of GL₂(𝔽_q) via random walks on
    certified Cayley graphs.

    The mixing time theorem guarantees that after O(log|G|/gap) steps,
    the walk distribution is close to uniform. This provides a
    deterministic source of pseudorandom group elements.

    Args:
        q: Prime field size.
        walk_length: Number of steps per walk.
        num_samples: Number of independent walks.

    Returns:
        Distribution statistics.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 1: Pseudorandom Group Element Sampling")
    print("=" * 60)

    mg = MatrixGroup(q)
    cv = CertificateVerifier(q)
    gl2 = mg.enumerate_gl2()
    n = len(gl2)
    idx = {mg.to_tuple(A): i for i, A in enumerate(gl2)}

    # Find a certified pair
    singers = [A for A in gl2 if cv.is_singer_like(A)]
    prim_dets = [A for A in gl2 if cv.is_primitive_det(A)]

    g, h = None, None
    for sg in singers:
        for pd in prim_dets:
            if cv.generates_group(sg, pd, gl2):
                g, h = sg, pd
                break
        if g is not None:
            break

    if g is None:
        print("  No certified pair found.")
        return

    gi, hi = mg.inv(g), mg.inv(h)
    generators = [g, gi, h, hi]

    # Perform random walks
    visit_counts = np.zeros(n, dtype=int)

    for _ in range(num_samples):
        current = mg.identity()
        for _ in range(walk_length):
            gen = generators[np.random.randint(4)]
            current = mg.mul(current, gen)
        visit_counts[idx[mg.to_tuple(current)]] += 1

    # Analyze uniformity
    expected = num_samples / n
    chi_sq = np.sum((visit_counts - expected) ** 2 / expected)

    print(f"  Group: GL₂(𝔽_{q}), |G| = {n}")
    print(f"  Walk length: {walk_length}, Samples: {num_samples}")
    print(f"  Expected visits per element: {expected:.2f}")
    print(f"  Actual range: [{visit_counts.min()}, {visit_counts.max()}]")
    print(f"  χ² statistic: {chi_sq:.2f} (df = {n-1})")
    print(f"  Uniformity: {'Good' if chi_sq < 2 * n else 'Needs more steps'}")

    return visit_counts


# ============================================================================
# Application 2: Robust Communication Network Design
# ============================================================================

def robust_network_design(q: int = 3):
    """Design a robust communication network using certified Cayley graphs.

    Properties:
    - Sparse: each node has exactly 4 connections
    - Symmetric: all nodes are equivalent
    - Rapidly mixing: information spreads in O(log n) steps
    - Robust: removing a few edges doesn't disconnect

    Args:
        q: Prime field size (determines network size).

    Returns:
        Network statistics.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Robust Communication Network Design")
    print("=" * 60)

    results = certificate_expansion_pipeline(q, max_pairs=1)
    if not results:
        print("  No certified pair found.")
        return

    r = results[0]
    n = r['gl2_order']
    gap = r['spectral_gap']
    t_mix = r['mixing_time']

    print(f"  Network size: {n} nodes")
    print(f"  Degree: {r['degree']} (each node has 4 connections)")
    print(f"  Total edges: {n * r['degree'] // 2}")
    print(f"  Spectral gap: {gap:.6f}")
    print(f"  Broadcast time (mixing): ≤ {t_mix} rounds")
    print(f"  Edge density: {r['degree'] / (n - 1):.6f}")
    print(f"  Expansion ratio: {gap:.6f}")

    # Vertex expansion estimate (Cheeger inequality)
    cheeger_lower = gap / 2
    cheeger_upper = np.sqrt(2 * gap)
    print(f"\n  Cheeger bounds on edge expansion:")
    print(f"    h(G) ≥ {cheeger_lower:.6f}")
    print(f"    h(G) ≤ {cheeger_upper:.6f}")

    print(f"\n  Network properties:")
    print(f"    ✓ 4-regular (constant degree)")
    print(f"    ✓ Vertex-transitive (all nodes equivalent)")
    print(f"    ✓ Connected (spectral gap > 0)")
    print(f"    ✓ Rapidly mixing (O(log n) broadcast time)")


# ============================================================================
# Application 3: Derandomization via Expander Walks
# ============================================================================

def derandomization_demo(q: int = 3):
    """Demonstrate derandomization using expander walks.

    Key idea: Instead of using n independent random bits, walk on the
    Cayley graph using O(log n) random bits. The expander property
    guarantees that the walk visits diverse elements.

    Args:
        q: Prime field size.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Derandomization via Expander Walks")
    print("=" * 60)

    results = certificate_expansion_pipeline(q, max_pairs=1)
    if not results:
        print("  No certified pair found.")
        return

    r = results[0]
    n = r['gl2_order']
    gap = r['spectral_gap']

    # Compare: fully random vs. expander walk
    bits_random = int(np.ceil(np.log2(n)))
    bits_walk = int(np.ceil(np.log2(4)))  # 2 bits per step
    steps_needed = r['mixing_time']
    total_bits_walk = bits_walk * steps_needed

    print(f"  Group size: |GL₂(𝔽_{q})| = {n}")
    print(f"\n  Fully random sampling:")
    print(f"    Bits per sample: {bits_random}")
    print(f"    For k samples: {bits_random} × k bits")

    print(f"\n  Expander walk sampling:")
    print(f"    Initial position: {bits_random} bits")
    print(f"    Per step: {bits_walk} bits (choose among 4 generators)")
    print(f"    Steps to mix: {steps_needed}")
    print(f"    For k samples: {bits_random} + {bits_walk} × {steps_needed} × k bits")

    print(f"\n  Savings for 10 samples:")
    random_bits = 10 * bits_random
    walk_bits = bits_random + 10 * bits_walk * steps_needed
    print(f"    Random: {random_bits} bits")
    print(f"    Walk:   {walk_bits} bits")
    if walk_bits < random_bits:
        print(f"    Savings: {random_bits - walk_bits} bits ({100*(1-walk_bits/random_bits):.0f}%)")
    else:
        print(f"    (Walk overhead for small groups; savings grow with |G|)")


# ============================================================================
# Application 4: Hash Function Construction
# ============================================================================

def hash_function_demo(q: int = 5):
    """Construct a hash function from the Cayley graph structure.

    Map a bit string to a group element by walking on the Cayley graph:
    each bit selects one of two generator pairs.

    Args:
        q: Prime field size.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 4: Cayley Graph Hash Function")
    print("=" * 60)

    mg = MatrixGroup(q)
    cv = CertificateVerifier(q)
    gl2 = mg.enumerate_gl2()
    idx = {mg.to_tuple(A): i for i, A in enumerate(gl2)}

    singers = [A for A in gl2 if cv.is_singer_like(A)]
    prim_dets = [A for A in gl2 if cv.is_primitive_det(A)]

    g, h = None, None
    for sg in singers:
        for pd in prim_dets:
            if cv.generates_group(sg, pd, gl2):
                g, h = sg, pd
                break
        if g is not None:
            break

    if g is None:
        print("  No certified pair found.")
        return

    gi, hi = mg.inv(g), mg.inv(h)

    def cayley_hash(bits: str) -> int:
        """Hash a bit string by walking on the Cayley graph."""
        current = mg.identity()
        for bit in bits:
            if bit == '0':
                current = mg.mul(current, g)
            else:
                current = mg.mul(current, h)
        return idx[mg.to_tuple(current)]

    print(f"  Group: GL₂(𝔽_{q}), |G| = {len(gl2)}")
    print(f"  Hash range: [0, {len(gl2) - 1}]")

    # Demo with some inputs
    test_inputs = ['0000', '0001', '0010', '0100', '1000',
                   '1111', '01010101', '10101010', '11001100']

    print(f"\n  Sample hashes:")
    for inp in test_inputs:
        h_val = cayley_hash(inp)
        print(f"    H('{inp}') = {h_val}")

    # Collision analysis
    n_tests = min(1000, 2 ** 10)
    hashes = set()
    collisions = 0
    for i in range(n_tests):
        bits = format(i, '010b')
        h_val = cayley_hash(bits)
        if h_val in hashes:
            collisions += 1
        hashes.add(h_val)

    print(f"\n  Collision analysis ({n_tests} inputs):")
    print(f"    Distinct outputs: {len(hashes)}/{min(n_tests, len(gl2))}")
    print(f"    Collisions: {collisions}")
    print(f"    Expansion property ensures good distribution")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF CERTIFICATE-BASED EXPANDER GRAPHS      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    pseudorandom_sampling(q=3, walk_length=15, num_samples=200)
    robust_network_design(q=3)
    derandomization_demo(q=3)
    hash_function_demo(q=5)


#!/usr/bin/env python3
"""
Expander Graphs from Certificate Pairs — Interactive Demo

Demonstrates the connection between algebraic certificate pairs in GL₂(𝔽_q)
and spectral expansion of Cayley graphs. Users can choose a prime q and explore
the spectral gaps of certified Cayley graphs.

Keywords: explicit expanders, Cayley graphs, spectral gap, finite linear groups,
Singer cycles, quasirandom groups, derandomization, mixing time
"""

import numpy as np
from itertools import product


def zmod_inv(a, q):
    """Multiplicative inverse of a in Z/qZ (0 if not invertible)."""
    return pow(int(a), q - 2, q) if a % q != 0 else 0


def mat_mul(A, B, q):
    """Multiply two 2x2 matrices over Z/qZ."""
    return np.array([
        [(A[0, 0] * B[0, 0] + A[0, 1] * B[1, 0]) % q,
         (A[0, 0] * B[0, 1] + A[0, 1] * B[1, 1]) % q],
        [(A[1, 0] * B[0, 0] + A[1, 1] * B[1, 0]) % q,
         (A[1, 0] * B[0, 1] + A[1, 1] * B[1, 1]) % q]
    ], dtype=int)


def mat_det(A, q):
    """Determinant of a 2x2 matrix over Z/qZ."""
    return (A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0]) % q


def mat_inv(A, q):
    """Inverse of a 2x2 matrix over Z/qZ."""
    d = mat_det(A, q)
    if d == 0:
        return None
    di = zmod_inv(d, q)
    return np.array([
        [(A[1, 1] * di) % q, ((-A[0, 1]) * di) % q],
        [((-A[1, 0]) * di) % q, (A[0, 0] * di) % q]
    ], dtype=int)


def mat_to_tuple(A):
    """Convert matrix to hashable tuple."""
    return (int(A[0, 0]), int(A[0, 1]), int(A[1, 0]), int(A[1, 1]))


def tuple_to_mat(t):
    """Convert tuple back to matrix."""
    return np.array([[t[0], t[1]], [t[2], t[3]]], dtype=int)


def enumerate_gl2(q):
    """Enumerate all elements of GL₂(𝔽_q)."""
    elements = []
    for a, b, c, d in product(range(q), repeat=4):
        A = np.array([[a, b], [c, d]], dtype=int)
        if mat_det(A, q) != 0:
            elements.append(A)
    return elements


def charpoly_coeffs(A, q):
    """Characteristic polynomial of 2x2 matrix: x² - tr(A)x + det(A)."""
    tr = (A[0, 0] + A[1, 1]) % q
    det = mat_det(A, q)
    return (1, (-tr) % q, det)  # x² + bx + c


def is_irreducible_charpoly(A, q):
    """Check if the characteristic polynomial of A is irreducible over 𝔽_q.
    For degree 2: irreducible iff has no roots in 𝔽_q."""
    _, b, c = charpoly_coeffs(A, q)
    for x in range(q):
        if (x * x + b * x + c) % q == 0:
            return False
    return True


def multiplicative_order(a, q):
    """Order of a in (Z/qZ)×."""
    if a % q == 0:
        return 0
    val = a % q
    o = 1
    current = val
    while current != 1:
        current = (current * val) % q
        o += 1
    return o


def is_primitive_root(a, q):
    """Check if a generates (Z/qZ)×."""
    return a % q != 0 and multiplicative_order(a, q) == q - 1


def is_singer_like(A, q):
    """Singer-like: irreducible characteristic polynomial."""
    return is_irreducible_charpoly(A, q)


def is_primitive_det(A, q):
    """Primitive determinant: det(A) generates (Z/qZ)×."""
    d = mat_det(A, q)
    return is_primitive_root(d, q)


def generates_gl2(g, h, q, gl2_elements):
    """Check if g, h generate GL₂(𝔽_q) by computing the closure."""
    gl2_set = set(mat_to_tuple(A) for A in gl2_elements)
    gi = mat_inv(g, q)
    hi = mat_inv(h, q)
    if gi is None or hi is None:
        return False

    generators = [g, gi, h, hi]
    generated = set()
    frontier = {mat_to_tuple(np.eye(2, dtype=int))}

    while frontier:
        new_frontier = set()
        for t in frontier:
            if t in generated:
                continue
            generated.add(t)
            A = tuple_to_mat(t)
            for gen in generators:
                product_mat = mat_mul(A, gen, q)
                pt = mat_to_tuple(product_mat)
                if pt not in generated and pt in gl2_set:
                    new_frontier.add(pt)
        frontier = new_frontier

    return len(generated) == len(gl2_elements)


def build_cayley_adjacency(generators, gl2_elements, q):
    """Build the adjacency matrix of the Cayley graph."""
    n = len(gl2_elements)
    idx = {mat_to_tuple(A): i for i, A in enumerate(gl2_elements)}
    adj = np.zeros((n, n), dtype=float)

    for i, A in enumerate(gl2_elements):
        for gen in generators:
            product_mat = mat_mul(A, gen, q)
            j = idx.get(mat_to_tuple(product_mat))
            if j is not None:
                adj[i, j] = 1.0

    return adj


def compute_spectral_gap(adj_matrix):
    """Compute the spectral gap of a regular graph from its adjacency matrix."""
    eigenvalues = np.linalg.eigvalsh(adj_matrix)
    eigenvalues = np.sort(eigenvalues)[::-1]
    d = eigenvalues[0]  # largest eigenvalue = degree
    if d < 1e-10:
        return 0.0
    # Normalize
    normalized = eigenvalues / d
    # Second largest in absolute value
    if len(normalized) < 2:
        return 1.0
    second = max(abs(normalized[1]), abs(normalized[-1]))
    return 1.0 - second


def find_certified_pairs(q, max_pairs=5):
    """Find certified pairs in GL₂(𝔽_q)."""
    print(f"\n{'='*60}")
    print(f"  Searching for certified pairs in GL₂(𝔽_{q})")
    print(f"{'='*60}")

    gl2 = enumerate_gl2(q)
    print(f"  |GL₂(𝔽_{q})| = {len(gl2)}")

    # Find Singer-like elements
    singers = [A for A in gl2 if is_singer_like(A, q)]
    print(f"  Singer-like elements (irreducible charpoly): {len(singers)}")

    # Find primitive-determinant elements
    prim_dets = [A for A in gl2 if is_primitive_det(A, q)]
    print(f"  Primitive-determinant elements: {len(prim_dets)}")

    pairs = []
    tested = 0
    for g in singers:
        if len(pairs) >= max_pairs:
            break
        for h in prim_dets:
            if len(pairs) >= max_pairs:
                break
            tested += 1
            if tested % 100 == 0:
                print(f"  Tested {tested} pairs...")
            if generates_gl2(g, h, q, gl2):
                gi = mat_inv(g, q)
                hi = mat_inv(h, q)
                generators = [g, gi, h, hi]
                adj = build_cayley_adjacency(generators, gl2, q)
                gap = compute_spectral_gap(adj)
                pairs.append((g, h, gap))
                print(f"\n  ✓ Found certified pair #{len(pairs)}:")
                print(f"    g = {g.tolist()}, h = {h.tolist()}")
                print(f"    Spectral gap = {gap:.6f}")

    return pairs, gl2


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  EXPANDER GRAPHS FROM CERTIFICATE PAIRS                 ║")
    print("║  Algebraic Certificates → Spectral Expansion            ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    print("This demo explores the connection between algebraic")
    print("generation certificates in GL₂(𝔽_q) and spectral expansion")
    print("of the resulting Cayley graphs.")
    print()

    while True:
        print("\nChoose a prime q:")
        print("  [3] q = 3  (|GL₂| = 48, fast)")
        print("  [5] q = 5  (|GL₂| = 480, moderate)")
        print("  [7] q = 7  (|GL₂| = 2016, slower)")
        print("  [q] Quit")
        choice = input("\n  Your choice: ").strip()

        if choice.lower() == 'q':
            print("\nGoodbye!")
            break

        try:
            q = int(choice)
        except ValueError:
            print("  Invalid input.")
            continue

        if q not in [3, 5, 7]:
            print(f"  q = {q} not supported (use 3, 5, or 7).")
            continue

        pairs, gl2 = find_certified_pairs(q, max_pairs=3)

        if not pairs:
            print(f"\n  No certified pairs found for q = {q}.")
            continue

        # Summary
        gaps = [gap for _, _, gap in pairs]
        min_gap = min(gaps)
        max_gap = max(gaps)

        print(f"\n{'='*60}")
        print(f"  RESULTS SUMMARY for GL₂(𝔽_{q})")
        print(f"{'='*60}")
        print(f"  Certified pairs found: {len(pairs)}")
        print(f"  Smallest spectral gap: {min_gap:.6f}")
        print(f"  Largest spectral gap:  {max_gap:.6f}")

        # Test conjectural threshold
        print(f"\n  Conjecture test: gap ≥ 1/(C·q)")
        threshold = 0.01
        if min_gap >= threshold:
            print(f"    ✓ All gaps ≥ {threshold} — conjecture survives")
        else:
            print(f"    ✗ Some gap < {threshold} — conjecture may need revision")

        inv_q = 1.0 / q
        if min_gap >= inv_q:
            print(f"    ✓ All gaps ≥ 1/q = {inv_q:.4f} — strong form holds")
        else:
            print(f"    ~ Min gap {min_gap:.4f} < 1/q = {inv_q:.4f}")
            if min_gap >= inv_q / 2:
                print(f"    ✓ But gap ≥ 1/(2q) = {inv_q/2:.4f} — moderate form holds")

        # Mixing time estimate
        print(f"\n  Mixing time estimates (to TV distance ≤ 0.01):")
        for i, (g, h, gap) in enumerate(pairs):
            if gap > 0:
                t_mix = int(np.ceil((np.log(len(gl2)) + np.log(100)) / gap))
                print(f"    Pair {i+1}: t_mix ≤ {t_mix} steps")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Eigenvalue Spectrum of Certified Cayley Graphs

Visualizes the eigenvalue distribution of the normalized adjacency operator
for Cayley graphs constructed from certified matrix pairs in GL₂(𝔽_q).
The spectral gap (distance from 1 to the second eigenvalue) is highlighted.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import certificate_expansion_pipeline

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

for ax_idx, q in enumerate([3, 5]):
    ax = axes[ax_idx]
    results = certificate_expansion_pipeline(q, max_pairs=1)

    if not results:
        ax.text(0.5, 0.5, f'No certified pair found for q={q}',
                ha='center', va='center', transform=ax.transAxes)
        continue

    r = results[0]
    eigenvalues = np.array(r['eigenvalues'])
    gap = r['spectral_gap']

    # Histogram of eigenvalues
    ax.hist(eigenvalues, bins=50, color='steelblue', alpha=0.7,
            edgecolor='navy', linewidth=0.5)

    # Mark the trivial eigenvalue at 1
    ax.axvline(x=1.0, color='red', linewidth=2, linestyle='--',
               label=f'λ₁ = 1 (trivial)')

    # Mark the second eigenvalue
    second_ev = eigenvalues[1] if len(eigenvalues) >= 2 else 0
    ax.axvline(x=second_ev, color='green', linewidth=2, linestyle='-.',
               label=f'λ₂ = {second_ev:.4f}')

    # Shade the spectral gap
    ax.axvspan(second_ev, 1.0, alpha=0.15, color='green',
               label=f'Spectral gap = {gap:.4f}')

    ax.set_xlabel('Eigenvalue', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(f'Spectrum of Cayley Graph on GL₂(𝔽_{q})\n'
                 f'|G| = {r["gl2_order"]}, degree = {r["degree"]}',
                 fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)

plt.suptitle('Eigenvalue Spectra of Certificate-Based Cayley Graphs',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('eigenvalue_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved: eigenvalue_spectrum.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Gap vs. Field Size

Plots the spectral gap of certified Cayley graphs as a function of
the prime field size q, testing the conjecture that gap ≥ C/q for
some absolute constant C.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import certificate_expansion_pipeline

primes = [3, 5, 7]
gaps = []
sizes = []

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

for q in primes:
    print(f"Computing for q = {q}...")
    results = certificate_expansion_pipeline(q, max_pairs=2)
    if results:
        for r in results:
            gaps.append(r['spectral_gap'])
            sizes.append(q)

# Plot 1: Spectral gap vs q
ax1.scatter(sizes, gaps, c='steelblue', s=100, zorder=5, edgecolors='navy')
if gaps:
    # Fit 1/q curve
    q_range = np.linspace(2.5, max(primes) + 0.5, 100)
    C_est = np.mean([g * q_val for g, q_val in zip(gaps, sizes)])
    ax1.plot(q_range, C_est / q_range, 'r--', linewidth=2,
             label=f'C/q (C ≈ {C_est:.2f})')

    ax1.set_xlabel('Prime q', fontsize=13)
    ax1.set_ylabel('Spectral Gap', fontsize=13)
    ax1.set_title('Spectral Gap vs. Field Size\n'
                  'Testing conjecture: gap ≥ C/q', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

# Plot 2: q × gap (should be roughly constant if conjecture holds)
q_times_gap = [q_val * g for g, q_val in zip(gaps, sizes)]
ax2.bar(range(len(q_times_gap)), q_times_gap, color='steelblue',
        edgecolor='navy', alpha=0.7)
ax2.set_xlabel('Pair index', fontsize=13)
ax2.set_ylabel('q × gap', fontsize=13)
ax2.set_title('Product q × gap\n'
              '(Should be ≈ constant if gap ~ C/q)', fontsize=14)
ax2.axhline(y=np.mean(q_times_gap) if q_times_gap else 1,
            color='red', linestyle='--', linewidth=2,
            label=f'Mean = {np.mean(q_times_gap):.2f}' if q_times_gap else '')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.suptitle('Conjecture Test: Uniform Spectral Gap for Certified Pairs',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('gap_vs_q.png', dpi=150, bbox_inches='tight')
print("Saved: gap_vs_q.png")


#!/usr/bin/env python3
"""
Visualization: Mixing Time Convergence

Shows how the random walk on the certified Cayley graph converges to the
uniform distribution. Plots the L² distance from uniform as a function
of the number of steps, demonstrating exponential decay governed by the
spectral gap.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import MatrixGroup, CertificateVerifier, CayleyGraph, SpectralAnalyzer

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

for ax_idx, q in enumerate([3, 5]):
    ax = axes[ax_idx]

    mg = MatrixGroup(q)
    cv = CertificateVerifier(q)
    gl2 = mg.enumerate_gl2()
    n = len(gl2)

    # Find a certified pair
    singers = [A for A in gl2 if cv.is_singer_like(A)]
    prim_dets = [A for A in gl2 if cv.is_primitive_det(A)]

    g, h = None, None
    for sg in singers:
        for pd in prim_dets:
            if cv.generates_group(sg, pd, gl2):
                g, h = sg, pd
                break
        if g is not None:
            break

    if g is None:
        ax.text(0.5, 0.5, f'No pair found for q={q}',
                ha='center', va='center', transform=ax.transAxes)
        continue

    gi, hi = mg.inv(g), mg.inv(h)
    generators = [g, gi, h, hi]
    cayley = CayleyGraph(gl2, generators, mg)
    spectral = SpectralAnalyzer(cayley)
    gap = spectral.spectral_gap()

    # Compute walk distribution at each time step
    M = cayley.normalized_adjacency
    uniform = np.ones(n) / n

    # Start from identity
    identity_idx = {mg.to_tuple(A): i for i, A in enumerate(gl2)}
    p = np.zeros(n)
    p[identity_idx[mg.to_tuple(mg.identity())]] = 1.0

    max_steps = 40
    l2_distances = []

    for t in range(max_steps):
        diff = p - uniform
        l2_dist = np.sqrt(np.sum(diff ** 2))
        l2_distances.append(l2_dist)
        p = M.T @ p  # One step of the walk

    steps = range(max_steps)

    # Plot actual L² distance
    ax.semilogy(steps, l2_distances, 'b-o', markersize=3,
                label='Actual L² distance', linewidth=1.5)

    # Plot theoretical bound
    if gap > 0:
        alpha = 1 - gap
        theoretical = [l2_distances[0] * alpha ** t for t in steps]
        ax.semilogy(steps, theoretical, 'r--', linewidth=1.5,
                    label=f'Bound: (1-gap)^t, gap={gap:.4f}')

    ax.set_xlabel('Steps', fontsize=12)
    ax.set_ylabel('L² distance from uniform', fontsize=12)
    ax.set_title(f'Mixing on Cayley(GL₂(𝔽_{q}), S)\n'
                 f'|G| = {n}, gap = {gap:.4f}',
                 fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=1e-8)

plt.suptitle('Exponential Mixing of Random Walks on Certified Cayley Graphs',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mixing_time.png', dpi=150, bbox_inches='tight')
print("Saved: mixing_time.png")
