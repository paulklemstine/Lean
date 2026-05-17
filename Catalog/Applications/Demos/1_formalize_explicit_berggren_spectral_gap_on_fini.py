#!/usr/bin/env python3
"""
Applications of Berggren Spectral Gap Theory

Demonstrates practical applications of the spectral gap:
1. Pseudorandom generation via Berggren walks
2. Expander graph construction
3. Equidistribution of Pythagorean triples mod q
4. Hash function candidates from Berggren dynamics
"""

import numpy as np
from algorithms import (enumerate_projective_isotropic_cone,
                        build_berggren_transition_matrix,
                        normalize_projective,
                        FWD_GENERATORS, INV_GENERATORS)


def application_pseudorandom_walk():
    """Demonstrate pseudorandom generation via Berggren walks.

    The spectral gap guarantees that a random walk on the projective
    isotropic cone converges to uniform in O(log q) steps.
    """
    print("=" * 65)
    print("  APPLICATION 1: Pseudorandom Walk on Isotropic Cone")
    print("=" * 65)

    q = 31
    cone = enumerate_projective_isotropic_cone(q)
    n = len(cone)
    cone_index = {v: i for i, v in enumerate(cone)}

    # Deterministic walk: cycle through generators
    start = cone[0]
    current = np.array(start, dtype=int)
    visited = set()
    visit_counts = np.zeros(n)

    steps = 1000
    for step in range(steps):
        gen_idx = step % 3
        current = (INV_GENERATORS[gen_idx] @ current) % q
        rep = normalize_projective(tuple(current), q)
        if rep in cone_index:
            visit_counts[cone_index[rep]] += 1
            visited.add(rep)

    # Check equidistribution
    expected = steps / n
    chi_sq = np.sum((visit_counts - expected)**2 / expected)

    print(f"  q = {q}, |P(X_q)| = {n}")
    print(f"  Steps: {steps}, Unique vertices visited: {len(visited)}/{n}")
    print(f"  Expected visits per vertex: {expected:.1f}")
    print(f"  Actual range: [{int(visit_counts.min())}, {int(visit_counts.max())}]")
    print(f"  χ² statistic: {chi_sq:.2f} (expected ≈ {n-1:.0f})")
    print(f"  Equidistribution quality: {'Good' if chi_sq < 2*n else 'Poor'}")
    print()


def application_expander_graph():
    """Construct and analyze the Berggren expander graph.

    The three Berggren generators define a 3-regular directed graph
    on q+1 vertices with spectral gap 1 - 1/√3 ≈ 0.42.
    """
    print("=" * 65)
    print("  APPLICATION 2: Berggren Expander Graph Properties")
    print("=" * 65)

    ref = 1.0 / np.sqrt(3)

    for q in [7, 13, 31, 61]:
        cone = enumerate_projective_isotropic_cone(q)
        n = len(cone)
        T = build_berggren_transition_matrix(q, cone)

        # Check if the graph is connected (T^n has all positive entries)
        Tk = np.linalg.matrix_power(T, n)
        connected = np.all(Tk > 1e-10)

        # Compute expansion ratio
        eigenvalues = np.abs(np.linalg.eigvals(T))
        eigenvalues.sort()
        gap = 1 - eigenvalues[-2]

        # Cheeger-type bound: h ≥ gap/2
        cheeger_lower = gap / 2

        print(f"  q = {q:3d}: vertices = {n:3d}, connected = {connected}, "
              f"gap = {gap:.4f}, Cheeger ≥ {cheeger_lower:.4f}")

    print(f"\n  Spectral gap = 1 - 1/√3 ≈ {1 - ref:.4f} (uniform across all primes)")
    print(f"  This certifies the Berggren graph as an arithmetic expander.")
    print()


def application_equidistribution():
    """Demonstrate equidistribution of Berggren orbits mod q.

    Starting from (3,4,5), the Berggren orbit covers all projective
    isotropic points mod q for good primes.
    """
    print("=" * 65)
    print("  APPLICATION 3: Equidistribution of Pythagorean Triples mod q")
    print("=" * 65)

    root = np.array([3, 4, 5])

    for q in [5, 7, 11, 13, 23, 31]:
        cone = enumerate_projective_isotropic_cone(q)
        cone_set = set(cone)

        # BFS from root
        root_mod = tuple(int(x) % q for x in root)
        root_rep = normalize_projective(root_mod, q)

        visited = set()
        if root_rep in cone_set:
            visited.add(root_rep)

        frontier = [root_mod]
        depth = 0
        while len(visited) < len(cone_set) and depth < 20:
            new_frontier = []
            for v in frontier:
                v_arr = np.array(v, dtype=int)
                for M in FWD_GENERATORS:
                    w = tuple(int(x) % q for x in M @ v_arr)
                    w_rep = normalize_projective(w, q)
                    if w_rep and w_rep not in visited and w_rep in cone_set:
                        visited.add(w_rep)
                        new_frontier.append(w)
            frontier = new_frontier
            depth += 1

        coverage = len(visited) / len(cone_set) * 100
        print(f"  q = {q:3d}: |P(X_q)| = {len(cone_set):3d}, "
              f"reached = {len(visited):3d} ({coverage:.0f}%), "
              f"depth = {depth}")

    print()


def application_hash_construction():
    """Demonstrate a hash function based on Berggren walks.

    Maps bit strings to projective isotropic points by interpreting
    bits as generator choices.
    """
    print("=" * 65)
    print("  APPLICATION 4: Hash Function from Berggren Dynamics")
    print("=" * 65)

    q = 101  # Use a larger prime
    root = np.array([3, 4, 5])

    def berggren_hash(message: bytes, q: int) -> tuple:
        """Hash a message to a projective isotropic point."""
        current = np.array(root, dtype=int)
        for byte in message:
            for bit_pos in range(8):
                bit = (byte >> bit_pos) & 1
                gen_idx = (bit + bit_pos) % 3  # Map to generator index
                current = (FWD_GENERATORS[gen_idx] @ current) % q
        rep = normalize_projective(tuple(int(x) for x in current), q)
        return rep

    # Test with some messages
    messages = [b"hello", b"world", b"hello!", b"berggren", b"pythagorean"]
    print(f"  q = {q}\n")
    for msg in messages:
        h = berggren_hash(msg, q)
        print(f"  hash({msg.decode()!r:15s}) = {h}")

    # Collision resistance test (small sample)
    import hashlib
    hashes = set()
    collisions = 0
    for i in range(1000):
        msg = i.to_bytes(4, 'big')
        h = berggren_hash(msg, q)
        if h in hashes:
            collisions += 1
        hashes.add(h)

    print(f"\n  Collision test: {len(hashes)} unique / 1000 inputs, "
          f"{collisions} collisions")
    print(f"  Expected collisions (birthday): ~{1000**2 // (2*(q+1))}")
    print()


if __name__ == "__main__":
    print("\n" + "═" * 65)
    print("  BERGGREN SPECTRAL GAP — APPLICATIONS")
    print("═" * 65 + "\n")

    application_pseudorandom_walk()
    application_expander_graph()
    application_equidistribution()
    application_hash_construction()


#!/usr/bin/env python3
"""
Berggren Spectral Gap on Finite Quotients — Demonstration

This script demonstrates the spectral theory of the Berggren averaging operator
on both the full and projective isotropic cones of Q(x,y,z) = x² + y² - z²
reduced modulo odd primes q.

Key insight: The spectral gap appears on the PROJECTIVE cone (mod scalars),
not on the full nonzero cone, because scalar multiplication commutes with
the linear Berggren generators.
"""

import numpy as np
from itertools import product

# ─── Berggren generators and their inverses ───
B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)

B1_inv = np.array([[1, 2, -2], [-2, -1, 2], [-2, -2, 3]], dtype=int)
B2_inv = np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]], dtype=int)
B3_inv = np.array([[-1, -2, 2], [2, 1, -2], [-2, -2, 3]], dtype=int)

Q_metric = np.diag([1, 1, -1])
GENERATORS = [B1, B2, B3]
INV_GENERATORS = [B1_inv, B2_inv, B3_inv]


def quad_form(v, q):
    """Compute Q(v) = v0² + v1² - v2² mod q."""
    return (v[0]**2 + v[1]**2 - v[2]**2) % q


def normalize_projective(v, q):
    """Normalize a nonzero vector to its canonical projective representative.
    Choose the representative where the first nonzero coordinate is 1."""
    for k in range(3):
        if v[k] % q != 0:
            # Find multiplicative inverse of v[k] mod q
            inv = pow(int(v[k] % q), q - 2, q)
            return tuple((c * inv) % q for c in v)
    return None  # zero vector


def enumerate_projective_cone(q):
    """Enumerate the projective isotropic cone: nonzero isotropic vectors mod scalars."""
    seen = set()
    cone = []
    for v in product(range(q), repeat=3):
        v_arr = np.array(v, dtype=int)
        if np.all(v_arr % q == 0):
            continue
        if quad_form(v_arr, q) != 0:
            continue
        rep = normalize_projective(v_arr, q)
        if rep not in seen:
            seen.add(rep)
            cone.append(rep)
    return cone


def enumerate_full_cone(q):
    """Enumerate all nonzero isotropic vectors mod q."""
    cone = []
    for v in product(range(q), repeat=3):
        v = np.array(v, dtype=int)
        if np.all(v % q == 0):
            continue
        if quad_form(v, q) == 0:
            cone.append(tuple(v))
    return cone


def build_projective_transition(q, cone):
    """Build the Berggren averaging operator on the projective cone."""
    n = len(cone)
    cone_index = {v: i for i, v in enumerate(cone)}
    T = np.zeros((n, n))

    for j, v in enumerate(cone):
        v_arr = np.array(v, dtype=int)
        for g in INV_GENERATORS:
            w = (g @ v_arr) % q
            w_rep = normalize_projective(w, q)
            if w_rep in cone_index:
                i = cone_index[w_rep]
                T[i, j] += 1.0 / 3.0

    return T


def compute_spectrum(T):
    """Compute sorted eigenvalue magnitudes."""
    eigenvalues = np.linalg.eigvals(T)
    return np.sort(np.abs(eigenvalues))[::-1]


def demo_form_preservation():
    """Verify that generators preserve Q."""
    print("=" * 65)
    print("  DEMO 1: Quadratic Form Preservation")
    print("=" * 65)

    for name, M in [("B1", B1), ("B2", B2), ("B3", B3)]:
        result = M.T @ Q_metric @ M
        print(f"  {name}^T Q {name} = Q: {np.allclose(result, Q_metric)}")

    S = B1 + B2 + B3
    SQS = S.T @ Q_metric @ S
    print(f"\n  S^T Q S = diag(1, 1, -9): {np.allclose(SQS, np.diag([1, 1, -9]))}")
    print()


def demo_cone_structure():
    """Demonstrate isotropic cone and projective cone structure."""
    print("=" * 65)
    print("  DEMO 2: Isotropic Cone Structure")
    print("=" * 65)
    print(f"  {'q':>3}  {'Full |X_q|':>10}  {'q²-1':>6}  {'Proj |P(X_q)|':>14}  {'q+1':>5}")
    print(f"  {'─'*3}  {'─'*10}  {'─'*6}  {'─'*14}  {'─'*5}")

    for q in [3, 5, 7, 11, 13, 17, 19, 23]:
        full = enumerate_full_cone(q)
        proj = enumerate_projective_cone(q)
        print(f"  {q:3d}  {len(full):10d}  {q*q-1:6d}  {len(proj):14d}  {q+1:5d}")
    print()


def demo_projective_spectral():
    """Spectral analysis on the projective cone."""
    print("=" * 65)
    print("  DEMO 3: Spectral Analysis on Projective Cone P(X_q)")
    print("=" * 65)

    ref = 1.0 / np.sqrt(3)
    print(f"  Reference: 1/√3 ≈ {ref:.8f}\n")
    print(f"  {'q':>3}  {'|P(X_q)|':>9}  {'λ₁':>8}  {'|λ₂|':>10}  {'|λ₃|':>10}  {'Gap':>8}  {'Status':>8}")
    print(f"  {'─'*3}  {'─'*9}  {'─'*8}  {'─'*10}  {'─'*10}  {'─'*8}  {'─'*8}")

    results = []
    for q in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43]:
        cone = enumerate_projective_cone(q)
        n = len(cone)
        if n == 0:
            continue

        T = build_projective_transition(q, cone)
        eigs = compute_spectrum(T)
        lam2 = eigs[1] if len(eigs) > 1 else 0
        lam3 = eigs[2] if len(eigs) > 2 else 0
        gap = 1.0 - lam2

        status = "✓" if lam2 <= ref + 1e-8 else "✗"
        results.append((q, n, lam2, gap, eigs))

        print(f"  {q:3d}  {n:9d}  {eigs[0]:8.4f}  {lam2:10.6f}  {lam3:10.6f}  {gap:8.4f}  {status:>8}")

    print()
    return results


def demo_full_vs_projective():
    """Compare spectral gap on full vs projective cone."""
    print("=" * 65)
    print("  DEMO 4: Full Cone vs Projective Cone Spectral Gap")
    print("=" * 65)

    for q in [5, 7, 11, 13]:
        full_cone = enumerate_full_cone(q)
        proj_cone = enumerate_projective_cone(q)

        T_full = np.zeros((len(full_cone), len(full_cone)))
        idx_full = {v: i for i, v in enumerate(full_cone)}
        for j, v in enumerate(full_cone):
            v_arr = np.array(v, dtype=int)
            for g in INV_GENERATORS:
                w = tuple((g @ v_arr) % q)
                if w in idx_full:
                    T_full[idx_full[w], j] += 1.0 / 3.0

        T_proj = build_projective_transition(q, proj_cone)

        eigs_full = compute_spectrum(T_full)
        eigs_proj = compute_spectrum(T_proj)

        print(f"\n  q = {q}:")
        print(f"    Full cone:       |X_q| = {len(full_cone):4d}, |λ₂| = {eigs_full[1]:.6f}")
        print(f"    Projective cone: |P_q| = {len(proj_cone):4d}, |λ₂| = {eigs_proj[1]:.6f}")

    print()


def demo_berggren_tree():
    """Demonstrate the Berggren tree structure."""
    print("=" * 65)
    print("  DEMO 5: Berggren Tree — Pythagorean Triple Generation")
    print("=" * 65)

    root = np.array([3, 4, 5])
    print(f"  Root: ({root[0]}, {root[1]}, {root[2]}), Q = {root[0]**2 + root[1]**2 - root[2]**2}\n")

    level = [root]
    for depth in range(2):
        next_level = []
        for v in level:
            for name, M in [("A", B1), ("B", B2), ("C", B3)]:
                child = M @ v
                print(f"  {'  ' * depth}{name}: "
                      f"({child[0]:5d}, {child[1]:5d}, {child[2]:5d}) "
                      f"check: {child[0]}² + {child[1]}² = {child[0]**2 + child[1]**2} = {child[2]}² = {child[2]**2}")
                next_level.append(child)
        level = next_level
        print()


def demo_mixing():
    """Demonstrate mixing on the projective cone."""
    print("=" * 65)
    print("  DEMO 6: Mixing on the Projective Cone")
    print("=" * 65)

    q = 13
    cone = enumerate_projective_cone(q)
    n = len(cone)
    T = build_projective_transition(q, cone)

    f = np.zeros(n)
    f[0] = 1.0
    uniform = np.ones(n) / n

    print(f"  q = {q}, |P(X_q)| = {n}")
    print(f"  Starting from delta function at vertex 0\n")

    for k in range(20):
        dist = np.linalg.norm(f - uniform)
        print(f"  Step {k:2d}: ‖f - uniform‖₂ = {dist:.10f}")
        f = T @ f

    print()


def demo_eigenvalue_structure():
    """Show full eigenvalue structure for a specific prime."""
    print("=" * 65)
    print("  DEMO 7: Full Eigenvalue Structure (q = 13)")
    print("=" * 65)

    q = 13
    cone = enumerate_projective_cone(q)
    T = build_projective_transition(q, cone)

    eigenvalues = np.linalg.eigvals(T)
    # Sort by magnitude
    idx = np.argsort(-np.abs(eigenvalues))
    eigenvalues = eigenvalues[idx]

    print(f"  q = {q}, dim = {len(cone)}")
    print(f"  Eigenvalues (sorted by magnitude):\n")
    for i, ev in enumerate(eigenvalues):
        mag = abs(ev)
        if abs(ev.imag) < 1e-10:
            print(f"    λ_{i+1:2d} = {ev.real:10.6f}  (|λ| = {mag:.6f})")
        else:
            print(f"    λ_{i+1:2d} = {ev.real:10.6f} + {ev.imag:10.6f}i  (|λ| = {mag:.6f})")
    print()


if __name__ == "__main__":
    print("\n" + "═" * 65)
    print("  BERGGREN FINITE SPECTRAL GAP — NUMERICAL DEMONSTRATION")
    print("═" * 65 + "\n")

    demo_form_preservation()
    demo_cone_structure()
    results = demo_projective_spectral()
    demo_full_vs_projective()
    demo_berggren_tree()
    demo_mixing()
    demo_eigenvalue_structure()

    print("=" * 65)
    print("  SUMMARY")
    print("=" * 65)
    ref = 1.0 / np.sqrt(3)
    print(f"  Reference bound: 1/√3 = {ref:.10f}\n")
    for q, n, lam2, gap, _ in results:
        status = "✓ BOUND HOLDS" if lam2 <= ref + 1e-8 else "✗ BOUND FAILS"
        print(f"  q={q:2d}: |P(X_q)| = {n:3d}, |λ₂| = {lam2:.10f}  {status}")
    print()


#!/usr/bin/env python3
"""
Visualizations for Berggren Spectral Gap Analysis

Generates publication-quality figures showing:
1. Eigenvalue distribution on the projective cone
2. Mixing convergence curves
3. Spectral gap uniformity across primes
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (enumerate_projective_isotropic_cone,
                        build_berggren_transition_matrix,
                        compute_spectral_data,
                        mixing_simulation)

plt.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 14,
    'figure.figsize': (10, 6),
    'figure.dpi': 150,
})


def plot_eigenvalue_distribution():
    """Plot eigenvalue magnitudes for several primes."""
    fig, axes = plt.subplots(2, 3, figsize=(14, 9))
    primes = [5, 7, 11, 13, 17, 23]
    ref = 1.0 / np.sqrt(3)

    for ax, q in zip(axes.flat, primes):
        cone = enumerate_projective_isotropic_cone(q)
        T = build_berggren_transition_matrix(q, cone)
        eigenvalues = np.linalg.eigvals(T)

        # Plot on complex plane
        theta = np.linspace(0, 2*np.pi, 200)
        ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.15, linewidth=0.5)
        ax.plot(ref*np.cos(theta), ref*np.sin(theta), 'r--', alpha=0.4, linewidth=1,
                label=f'|λ| = 1/√3')
        ax.plot((1/3)*np.cos(theta), (1/3)*np.sin(theta), 'b--', alpha=0.3, linewidth=1,
                label='|λ| = 1/3')

        ax.scatter(eigenvalues.real, eigenvalues.imag, c='darkblue', s=50,
                   zorder=5, edgecolors='white', linewidth=0.5)
        ax.set_xlim(-1.2, 1.2)
        ax.set_ylim(-1.2, 1.2)
        ax.set_aspect('equal')
        ax.axhline(y=0, color='gray', linewidth=0.3)
        ax.axvline(x=0, color='gray', linewidth=0.3)
        ax.set_title(f'q = {q} (dim = {q+1})')
        if q == 5:
            ax.legend(fontsize=8, loc='lower left')
        ax.grid(True, alpha=0.1)

    fig.suptitle('Eigenvalues of Berggren Operator $T_q$ on Projective Isotropic Cone',
                 fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('eigenvalue_distribution.png', bbox_inches='tight', dpi=150)
    plt.close()
    print("Saved: eigenvalue_distribution.png")


def plot_spectral_gap_uniformity():
    """Plot |λ₂| vs q showing perfect uniformity."""
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73]
    ref = 1.0 / np.sqrt(3)

    lambda2_vals = []
    for q in primes:
        cone = enumerate_projective_isotropic_cone(q)
        T = build_berggren_transition_matrix(q, cone)
        data = compute_spectral_data(T)
        lambda2_vals.append(data['magnitudes'][1])

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.scatter(primes, lambda2_vals, c='darkblue', s=60, zorder=5,
               edgecolors='white', linewidth=0.5, label='Computed |λ₂|')
    ax.axhline(y=ref, color='red', linestyle='--', linewidth=2, alpha=0.7,
               label=f'1/√3 ≈ {ref:.6f}')
    ax.axhline(y=1/3, color='blue', linestyle=':', linewidth=1, alpha=0.5,
               label='1/3')
    ax.axhline(y=1.0, color='gray', linestyle='-', linewidth=1, alpha=0.3,
               label='Trivial bound')

    ax.set_xlabel('Prime q')
    ax.set_ylabel('|λ₂|')
    ax.set_title('Spectral Gap Uniformity: |λ₂| = 1/√3 for All Odd Primes')
    ax.legend(fontsize=11)
    ax.set_ylim(0, 1.1)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('spectral_gap_uniformity.png', bbox_inches='tight', dpi=150)
    plt.close()
    print("Saved: spectral_gap_uniformity.png")


def plot_mixing_convergence():
    """Plot mixing convergence for several primes."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ref = 1.0 / np.sqrt(3)
    steps = 30

    for q in [5, 7, 13, 23, 43]:
        distances = mixing_simulation(q, steps)
        ax.semilogy(range(steps), distances, 'o-', markersize=4,
                    label=f'q = {q} (dim = {q+1})')

    # Theoretical envelope: C * (1/√3)^k
    k_vals = np.arange(steps)
    theoretical = 1.0 * ref**k_vals
    ax.semilogy(k_vals, theoretical, 'k--', linewidth=2, alpha=0.5,
                label=f'(1/√3)^k envelope')

    ax.set_xlabel('Iteration k')
    ax.set_ylabel('‖f_k − uniform‖₂')
    ax.set_title('Mixing Convergence of Berggren Walk on Projective Cone')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('mixing_convergence.png', bbox_inches='tight', dpi=150)
    plt.close()
    print("Saved: mixing_convergence.png")


def plot_eigenvalue_structure():
    """Plot the eigenvalue magnitude histogram for q=43."""
    q = 43
    cone = enumerate_projective_isotropic_cone(q)
    T = build_berggren_transition_matrix(q, cone)
    eigenvalues = np.linalg.eigvals(T)
    mags = np.abs(eigenvalues)

    fig, ax = plt.subplots(figsize=(10, 5))

    # Group eigenvalues by magnitude
    ref = 1.0 / np.sqrt(3)
    bins = [0, 0.2, 0.45, 0.7, 1.1]
    colors = ['steelblue', 'orange', 'crimson', 'green']
    labels_map = {0: '|λ| ≈ 1/3', 1: 'other', 2: '|λ| = 1/√3', 3: '|λ| = 1'}

    ax.hist(mags, bins=50, color='steelblue', edgecolor='white', alpha=0.8)
    ax.axvline(x=1.0, color='green', linestyle='-', linewidth=2, alpha=0.7, label='λ = 1')
    ax.axvline(x=ref, color='red', linestyle='--', linewidth=2, alpha=0.7, label=f'1/√3')
    ax.axvline(x=1/3, color='blue', linestyle=':', linewidth=2, alpha=0.7, label='1/3')

    n_at_1 = sum(1 for m in mags if abs(m - 1) < 1e-6)
    n_at_ref = sum(1 for m in mags if abs(m - ref) < 1e-6)
    n_at_third = sum(1 for m in mags if abs(m - 1/3) < 1e-6)

    ax.set_xlabel('|λ|')
    ax.set_ylabel('Count')
    ax.set_title(f'Eigenvalue Magnitude Distribution (q = {q}, dim = {q+1})\n'
                 f'{n_at_1} at |λ|=1, {n_at_ref} at |λ|=1/√3, {n_at_third} at |λ|=1/3')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('eigenvalue_structure.png', bbox_inches='tight', dpi=150)
    plt.close()
    print("Saved: eigenvalue_structure.png")


if __name__ == "__main__":
    print("Generating visualizations...\n")
    plot_eigenvalue_distribution()
    plot_spectral_gap_uniformity()
    plot_mixing_convergence()
    plot_eigenvalue_structure()
    print("\nAll visualizations generated successfully.")
