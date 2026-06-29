#!/usr/bin/env python3
"""
Berggren–Fourier Duality: Applications

Demonstrates real-world applications of the Berggren spectral framework:
1. Hidden triple identification (cryptographic analogy)
2. Orbit fingerprinting for triple classification
3. Spectral compression of triple-tree data
4. Noisy measurement robustness analysis
"""

import numpy as np
from itertools import product
from collections import defaultdict

# Berggren matrices
A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)
ROOT = np.array([3, 4, 5], dtype=int)


def act_mod(M: np.ndarray, v: tuple, m: int) -> tuple:
    """Apply matrix M to vector v modulo m."""
    result = (M @ np.array(v)) % m
    return tuple(int(x) for x in result)


# ============================================================
# Application 1: Hidden Triple Identification
# ============================================================

def app_hidden_triple():
    """
    Scenario: An oracle holds a secret Pythagorean triple (mod m).
    Using character queries, identify the triple with certainty.

    This mirrors the quantum hidden subgroup problem but for
    Berggren semigroup dynamics.
    """
    print("=" * 60)
    print("APPLICATION 1: Hidden Triple Identification")
    print("=" * 60)
    print()
    print("Scenario: An oracle holds a secret triple modulo m.")
    print("We identify it using spectral character queries.")
    print()

    m = 5
    Q = list(product(range(m), repeat=3))

    # Secret triple
    secret = (3, 4, 0)  # (3,4,5) mod 5
    print(f"  Modulus m = {m}, |Q| = {len(Q)}")
    print(f"  Secret triple: {secret}")

    # Use coordinate projection characters
    # chi_i_v(q) = 1 if q[i] == v else 0
    queries = 0
    candidates = list(Q)

    for coord in range(3):
        for val in range(m):
            if len(candidates) <= 1:
                break
            # Query: does coordinate `coord` equal `val`?
            answer = 1 if secret[coord] == val else 0
            queries += 1
            candidates = [q for q in candidates if
                         (1 if q[coord] == val else 0) == answer]
            if answer == 1:
                break  # found the value for this coordinate

    print(f"  Recovered: {candidates[0]}")
    print(f"  Correct: {candidates[0] == secret}")
    print(f"  Queries used: {queries}")
    print(f"  Theoretical bound: {len(Q)} (exhaustive)")
    print(f"  Speedup: {len(Q) / queries:.1f}x")


# ============================================================
# Application 2: Orbit Fingerprinting
# ============================================================

def app_orbit_fingerprint():
    """
    Use Berggren orbit structure to fingerprint and classify
    elements of PQMod(m) by their dynamical behavior.
    """
    print()
    print("=" * 60)
    print("APPLICATION 2: Orbit Fingerprinting")
    print("=" * 60)
    print()
    print("Classify elements by their Berggren orbit fingerprint.")
    print()

    m = 4
    Q = list(product(range(m), repeat=3))

    # Compute orbit fingerprint: (actA(q), actB(q), actC(q))
    fingerprints = defaultdict(list)
    for q in Q:
        fp = (act_mod(A, q, m), act_mod(B, q, m), act_mod(C, q, m))
        fingerprints[fp].append(q)

    print(f"  PQMod({m}): {len(Q)} elements")
    print(f"  Distinct orbit fingerprints: {len(fingerprints)}")

    # Show size distribution
    sizes = defaultdict(int)
    for fp, elems in fingerprints.items():
        sizes[len(elems)] += 1

    print(f"  Fingerprint class sizes:")
    for size, count in sorted(sizes.items()):
        print(f"    Size {size}: {count} classes")

    # Fixed points (self-loops under all generators)
    fixed = [q for q in Q if all(
        act_mod(M, q, m) == q for M in [A, B, C]
    )]
    print(f"  Fixed points (all generators): {len(fixed)}")
    if fixed:
        print(f"    Examples: {fixed[:5]}")


# ============================================================
# Application 3: Spectral Compression
# ============================================================

def app_spectral_compression():
    """
    Demonstrate spectral compression: represent a sparse observable
    using far fewer Fourier coefficients than the full dimension.
    """
    print()
    print("=" * 60)
    print("APPLICATION 3: Spectral Compression")
    print("=" * 60)
    print()

    m = 3
    Q = sorted(list(product(range(m), repeat=3)))
    n = len(Q)
    print(f"  PQMod({m}): {n} elements")

    # Sparse observable: supported on only 3 elements
    support = [Q[0], Q[5], Q[20]]
    f = {q: 0.0 for q in Q}
    for s in support:
        f[s] = np.random.uniform(1, 10)

    sparsity = sum(1 for v in f.values() if abs(v) > 1e-10)
    print(f"  Observable sparsity: {sparsity}/{n}")

    # Full Fourier expansion needs n coefficients
    # But sparse observable can be represented with fewer

    # Compute all coefficients
    # Using indicator basis: coefficients = function values
    nonzero_coeffs = {q: f[q] for q in Q if abs(f[q]) > 1e-10}
    print(f"  Non-zero Fourier coefficients: {len(nonzero_coeffs)}")
    print(f"  Compression ratio: {n}/{len(nonzero_coeffs)} = "
          f"{n/max(len(nonzero_coeffs),1):.1f}x")

    # Verify reconstruction from sparse coefficients
    f_recon = {q: 0.0 for q in Q}
    for q_supp, coeff in nonzero_coeffs.items():
        for q in Q:
            if q == q_supp:
                f_recon[q] += coeff

    max_err = max(abs(f[q] - f_recon[q]) for q in Q)
    print(f"  Reconstruction error: {max_err:.2e}")


# ============================================================
# Application 4: Noisy Measurement Robustness
# ============================================================

def app_noisy_reconstruction():
    """
    Analyze robustness of reconstruction when character
    measurements are corrupted by noise.
    """
    print()
    print("=" * 60)
    print("APPLICATION 4: Noisy Measurement Robustness")
    print("=" * 60)
    print()

    m = 3
    Q = sorted(list(product(range(m), repeat=3)))
    n = len(Q)

    # Build indicator characters
    chars = {}
    for a in Q:
        chars[a] = lambda q, a=a: 1.0 if q == a else 0.0

    # Compute separation gap
    # delta = min over distinct x,y of max over chi of |chi(x) - chi(y)|
    delta = float('inf')
    for i in range(len(Q)):
        for j in range(i + 1, len(Q)):
            x, y = Q[i], Q[j]
            max_diff = max(abs(chars[a](x) - chars[a](y)) for a in Q)
            delta = min(delta, max_diff)

    print(f"  PQMod({m}): {n} elements")
    print(f"  Separation gap δ = {delta}")
    print(f"  Noise tolerance: ε < δ/2 = {delta/2}")

    # Test reconstruction under various noise levels
    hidden = Q[13]  # arbitrary hidden point
    np.random.seed(123)

    print(f"\n  Hidden point: {hidden}")
    print(f"  {'Noise level':>12} {'Success':>8} {'Error':>8}")
    print(f"  {'-'*12} {'-'*8} {'-'*8}")

    for noise_level in [0.0, 0.1, 0.2, 0.3, 0.49, 0.5, 0.7, 1.0]:
        successes = 0
        trials = 100
        for _ in range(trials):
            # Noisy oracle
            noise = {a: np.random.uniform(-noise_level, noise_level) for a in Q}
            noisy_oracle = lambda a, h=hidden, n=noise: chars[a](h) + n[a]

            # Nearest-neighbor reconstruction
            best_q = None
            best_dist = float('inf')
            for q in Q:
                dist = sum((noisy_oracle(a) - chars[a](q))**2 for a in Q)
                if dist < best_dist:
                    best_dist = dist
                    best_q = q

            if best_q == hidden:
                successes += 1

        rate = successes / trials
        print(f"  {noise_level:>12.2f} {rate:>7.0%} {'✓' if rate > 0.9 else '✗':>8}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Berggren–Fourier Duality: Applications                ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    app_hidden_triple()
    app_orbit_fingerprint()
    app_spectral_compression()
    app_noisy_reconstruction()

    print()
    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Berggren–Fourier Duality: Demonstrations and Numerical Examples

This script demonstrates the key theorems of the Berggren–Fourier Duality
framework with concrete numerical examples:
1. Berggren generator actions on Pythagorean triples
2. Finite quotient orbit structure
3. Character separation verification
4. Fourier expansion computation
5. Certified reconstruction algorithm
"""

import numpy as np
from itertools import product

# ============================================================
# Berggren Generators
# ============================================================

A = np.array([[1, -2, 2],
              [2, -1, 2],
              [2, -2, 3]], dtype=int)

B = np.array([[1, 2, 2],
              [2, 1, 2],
              [2, 2, 3]], dtype=int)

C = np.array([[-1, 2, 2],
              [-2, 1, 2],
              [-2, 2, 3]], dtype=int)

ROOT = np.array([3, 4, 5], dtype=int)


def generate_berggren_tree(depth=4):
    """Generate Berggren tree to given depth."""
    triples = [ROOT]
    current_level = [ROOT]
    for d in range(depth):
        next_level = []
        for t in current_level:
            for M, name in [(A, 'A'), (B, 'B'), (C, 'C')]:
                child = M @ t
                next_level.append(child)
                triples.append(child)
        current_level = next_level
    return triples


def verify_pythagorean(t):
    """Verify that t = (a, b, c) is a Pythagorean triple."""
    return t[0]**2 + t[1]**2 == t[2]**2


# ============================================================
# Demo 1: Berggren Tree Generation
# ============================================================

def demo_tree_generation():
    print("=" * 60)
    print("DEMO 1: Berggren Tree Generation")
    print("=" * 60)
    print(f"\nRoot triple: {ROOT}")
    print(f"  Pythagorean: {ROOT[0]}² + {ROOT[1]}² = {ROOT[0]**2} + {ROOT[1]**2} = {ROOT[2]**2} = {ROOT[2]}² ✓")

    print("\nFirst generation:")
    for M, name in [(A, 'A'), (B, 'B'), (C, 'C')]:
        child = M @ ROOT
        check = "✓" if verify_pythagorean(child) else "✗"
        print(f"  {name} · (3,4,5) = ({child[0]},{child[1]},{child[2]})  "
              f"  {child[0]}² + {child[1]}² = {child[0]**2 + child[1]**2} = {child[2]**2} = {child[2]}² {check}")

    triples = generate_berggren_tree(3)
    print(f"\nTotal triples generated (depth 3): {len(triples)}")
    print(f"All Pythagorean: {all(verify_pythagorean(t) for t in triples)}")
    all_distinct = len(set(tuple(t) for t in triples)) == len(triples)
    print(f"All distinct: {all_distinct}")


# ============================================================
# Demo 2: Finite Quotient Orbits
# ============================================================

def compute_orbits_mod(m, max_depth=6):
    """Compute orbit structure of PQMod(m)."""
    A_mod = A % m
    B_mod = B % m
    C_mod = C % m

    root_mod = tuple(ROOT % m)
    visited = {root_mod}
    frontier = [root_mod]

    for _ in range(max_depth):
        next_frontier = []
        for t in frontier:
            tv = np.array(t)
            for M in [A_mod, B_mod, C_mod]:
                child = tuple((M @ tv) % m)
                if child not in visited:
                    visited.add(child)
                    next_frontier.append(child)
        if not next_frontier:
            break
        frontier = next_frontier

    return visited


def demo_quotient_orbits():
    print("\n" + "=" * 60)
    print("DEMO 2: Finite Quotient Orbit Structure")
    print("=" * 60)

    for m in [2, 3, 4, 5, 7]:
        orbits = compute_orbits_mod(m)
        total = m ** 3
        print(f"\n  PQMod({m}): {total} total elements, "
              f"{len(orbits)} reachable from root")
        if m <= 3:
            print(f"    Orbit elements: {sorted(orbits)}")


# ============================================================
# Demo 3: Character Separation
# ============================================================

def make_indicator_chars(Q):
    """Create indicator function character family for finite set Q."""
    chars = {}
    for a in Q:
        def chi(q, a=a):
            return 1 if q == a else 0
        chars[a] = chi
    return chars


def verify_separation(Q, chars):
    """Verify that chars separates all points of Q."""
    Q_list = list(Q)
    for i in range(len(Q_list)):
        for j in range(i + 1, len(Q_list)):
            x, y = Q_list[i], Q_list[j]
            separated = False
            for name, chi in chars.items():
                if chi(x) != chi(y):
                    separated = True
                    break
            if not separated:
                return False, (x, y)
    return True, None


def demo_separation():
    print("\n" + "=" * 60)
    print("DEMO 3: Character Separation Verification")
    print("=" * 60)

    for m in [2, 3, 4]:
        Q = set(product(range(m), repeat=3))
        chars = make_indicator_chars(Q)
        sep, pair = verify_separation(Q, chars)
        print(f"\n  PQMod({m}): |Q| = {len(Q)}, |chars| = {len(chars)}")
        print(f"    Separation verified: {sep}")


# ============================================================
# Demo 4: Fourier Expansion
# ============================================================

def demo_fourier_expansion():
    print("\n" + "=" * 60)
    print("DEMO 4: Fourier Expansion Computation")
    print("=" * 60)

    # Small example: Q = {0, 1, 2} (Fin 3)
    Q = [0, 1, 2]
    n = len(Q)

    # Character basis: indicator functions
    chi = np.eye(n)  # chi[i][q] = delta_{i,q}

    print(f"\n  Q = {Q}, |Q| = {n}")
    print(f"  Character matrix (indicator basis):")
    print(f"    {chi}")

    # Test observable
    f = np.array([3.0, -1.0, 7.0])
    print(f"\n  Observable f = {f}")

    # Fourier coefficients: solve chi^T * coeff = f
    # Since chi = I, coefficients = f
    coeff = np.linalg.solve(chi, f)
    print(f"  Fourier coefficients: {coeff}")

    # Verify reconstruction
    f_reconstructed = chi.T @ coeff
    print(f"  Reconstructed: {f_reconstructed}")
    print(f"  Match: {np.allclose(f, f_reconstructed)}")

    # Non-trivial example with random "characters"
    print("\n  --- Non-trivial character basis ---")
    np.random.seed(42)
    Q5 = list(range(5))
    n5 = 5

    # Random linearly independent "characters"
    chars5 = np.random.randn(n5, n5)
    while abs(np.linalg.det(chars5)) < 0.1:
        chars5 = np.random.randn(n5, n5)

    f5 = np.array([1.0, -2.0, 3.0, 0.5, -1.5])
    coeff5 = np.linalg.solve(chars5.T, f5)

    # f(q) = sum_i coeff_i * chi_i(q) = sum_i coeff_i * chars5[i][q]
    f5_recon = np.array([sum(coeff5[i] * chars5[i][q] for i in range(n5)) for q in range(n5)])

    print(f"  Q = {Q5}, |Q| = {n5}")
    print(f"  Observable f = {f5}")
    print(f"  Fourier coefficients: {np.round(coeff5, 4)}")
    print(f"  Reconstructed: {np.round(f5_recon, 4)}")
    print(f"  Match: {np.allclose(f5, f5_recon)}")


# ============================================================
# Demo 5: Certified Reconstruction
# ============================================================

def reconstruct_point(Q, chars, oracle):
    """
    Exhaustive-search reconstruction algorithm.
    Given oracle access to chi(x) for unknown x, finds x.

    Args:
        Q: finite set of points
        chars: dict of character_name -> character_function
        oracle: function from character_name -> measurement value

    Returns:
        The unique point matching all measurements, or None.
    """
    queries = 0
    for q in Q:
        match = True
        for name, chi in chars.items():
            queries += 1
            if oracle(name) != chi(q):
                match = False
                break
        if match:
            return q, queries
    return None, queries


def demo_reconstruction():
    print("\n" + "=" * 60)
    print("DEMO 5: Certified Reconstruction Algorithm")
    print("=" * 60)

    m = 3
    Q = list(product(range(m), repeat=3))
    chars = make_indicator_chars(Q)

    # Test reconstruction for several hidden points
    test_points = [(0, 0, 0), (1, 2, 0), (2, 1, 2), (0, 2, 1)]

    for hidden in test_points:
        # Oracle: returns chi(hidden) for any character chi
        oracle = lambda name, h=hidden: chars[name](h)
        result, queries = reconstruct_point(Q, chars, oracle)
        status = "✓" if result == hidden else "✗"
        print(f"  Hidden: {hidden} → Recovered: {result} "
              f"({queries} queries) {status}")

    print(f"\n  Query bound: |Q| × |chars| = {len(Q)} × {len(chars)} = {len(Q) * len(chars)}")


# ============================================================
# Demo 6: Tropical Decomposition
# ============================================================

def demo_tropical():
    print("\n" + "=" * 60)
    print("DEMO 6: Tropical (Max-Plus) Decomposition")
    print("=" * 60)

    # Q = {0, 1, 2}, tropical characters = shifted indicators
    Q = [0, 1, 2]
    n = len(Q)

    # Tropical characters: chi_i(q) = 0 if q == i, else -infinity
    NEG_INF = -10**9

    def trop_chi(i, q):
        return 0 if q == i else NEG_INF

    # Observable
    f = [3, -1, 7]
    print(f"  Observable f = {f}")

    # Tropical decomposition: f(q) = max_i (c_i + chi_i(q))
    # With indicator chars: c_i + chi_i(q) = c_i if q == i, else -inf
    # So f(q) = c_q, meaning c_i = f(i)
    coeffs = list(f)
    print(f"  Tropical coefficients: {coeffs}")

    # Verify
    for q in Q:
        val = max(coeffs[i] + trop_chi(i, q) for i in range(n))
        print(f"    f({q}) = max_i(c_i + χ_i({q})) = {val} (expected {f[q]}) "
              f"{'✓' if val == f[q] else '✗'}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Berggren–Fourier Duality: Numerical Demonstrations    ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_tree_generation()
    demo_quotient_orbits()
    demo_separation()
    demo_fourier_expansion()
    demo_reconstruction()
    demo_tropical()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Berggren–Fourier Duality: Visualizations

Generates publication-quality figures:
1. Berggren tree structure
2. Orbit structure of PQMod(m)
3. Character evaluation matrix heatmap
4. Reconstruction convergence
5. Noisy reconstruction phase diagram
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import product
from collections import defaultdict
import base64
from io import BytesIO

# Berggren matrices
A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)
ROOT = np.array([3, 4, 5], dtype=int)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def save_fig(fig, filename: str):
    """Save figure to file."""
    fig.savefig(filename, dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    plt.close(fig)


# ============================================================
# Figure 1: Berggren Tree
# ============================================================

def plot_berggren_tree(depth=3):
    """Visualize the Berggren tree to given depth."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    nodes = {}
    positions = {}

    # BFS to assign positions
    root_label = "(3,4,5)"
    nodes[""] = ROOT.copy()
    positions[""] = (0.5, 1.0)

    queue = [("", ROOT.copy(), 0.0, 1.0, 1.0)]
    all_edges = []

    for d in range(depth):
        next_queue = []
        for path, triple, x_min, x_max, y in queue:
            cx = (x_min + x_max) / 2
            positions[path] = (cx, y)
            nodes[path] = triple

            width = (x_max - x_min) / 3
            for i, (name, M) in enumerate([('A', A), ('B', B), ('C', C)]):
                child = M @ triple
                child_path = path + name
                child_x_min = x_min + i * width
                child_x_max = child_x_min + width
                child_y = y - 1.0 / depth

                nodes[child_path] = child
                all_edges.append((path, child_path, name))
                next_queue.append((child_path, child, child_x_min, child_x_max, child_y))

        queue = next_queue

    # Assign final positions for last level
    for path, triple, x_min, x_max, y in queue:
        cx = (x_min + x_max) / 2
        positions[path] = (cx, y)
        nodes[path] = triple

    # Draw edges
    colors = {'A': '#e74c3c', 'B': '#3498db', 'C': '#2ecc71'}
    for parent, child, gen in all_edges:
        px, py = positions[parent]
        cx, cy = positions[child]
        ax.plot([px, cx], [py, cy], color=colors[gen], linewidth=1.5, alpha=0.6)

    # Draw nodes
    for path, triple in nodes.items():
        x, y = positions[path]
        label = f"({triple[0]},{triple[1]},{triple[2]})"
        fontsize = 7 if len(path) <= 1 else 5
        bbox_props = dict(boxstyle='round,pad=0.2', facecolor='lightyellow',
                         edgecolor='gray', alpha=0.9)
        ax.text(x, y, label, fontsize=fontsize, ha='center', va='center',
               bbox=bbox_props)

    # Legend
    for name, color in colors.items():
        ax.plot([], [], color=color, linewidth=3, label=f'Generator {name}')
    ax.legend(loc='upper left', fontsize=10)

    ax.set_xlim(-0.02, 1.02)
    ax.set_ylim(-0.05, 1.1)
    ax.set_title('Berggren Tree of Primitive Pythagorean Triples', fontsize=14, fontweight='bold')
    ax.axis('off')

    return fig


# ============================================================
# Figure 2: Orbit Structure Heatmap
# ============================================================

def plot_orbit_structure():
    """Visualize orbit sizes for different moduli."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, m in enumerate([3, 5, 7]):
        ax = axes[idx]
        Q = list(product(range(m), repeat=3))

        # Compute orbit from root
        root = tuple(ROOT % m)
        visited = {root}
        frontier = [root]
        for _ in range(30):
            nf = []
            for t in frontier:
                for M in [A, B, C]:
                    child = tuple(int(x) for x in (M @ np.array(t)) % m)
                    if child not in visited:
                        visited.add(child)
                        nf.append(child)
            if not nf:
                break
            frontier = nf

        # Create grid showing which elements are in orbit
        grid = np.zeros((m, m * m))
        for q in Q:
            row = q[0]
            col = q[1] * m + q[2]
            grid[row, col] = 2 if q in visited else 1

        im = ax.imshow(grid, cmap='RdYlGn', aspect='auto', interpolation='nearest')
        ax.set_title(f'PQMod({m})\n{len(visited)}/{len(Q)} reachable',
                    fontsize=11, fontweight='bold')
        ax.set_xlabel('(b, c) index', fontsize=9)
        ax.set_ylabel('a index', fontsize=9)

    plt.suptitle('Berggren Orbit Structure in Finite Quotients', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


# ============================================================
# Figure 3: Character Evaluation Matrix
# ============================================================

def plot_character_matrix():
    """Visualize the character evaluation matrix for a small quotient."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    m = 2
    Q = sorted(list(product(range(m), repeat=3)))
    n = len(Q)

    # Indicator character matrix
    M_ind = np.eye(n)
    ax = axes[0]
    im = ax.imshow(M_ind, cmap='Blues', aspect='equal')
    ax.set_title(f'Indicator Characters (m={m})\nIdentity Matrix', fontsize=11, fontweight='bold')
    ax.set_xlabel('Point index q', fontsize=10)
    ax.set_ylabel('Character index χ', fontsize=10)
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Random linearly independent "characters"
    np.random.seed(42)
    M_rand = np.random.randn(n, n)
    # Ensure invertible
    M_rand = M_rand @ M_rand.T + 0.5 * np.eye(n)

    ax = axes[1]
    im = ax.imshow(M_rand, cmap='RdBu_r', aspect='equal')
    ax.set_title(f'General Character Basis (m={m})\nInvertible Matrix', fontsize=11, fontweight='bold')
    ax.set_xlabel('Point index q', fontsize=10)
    ax.set_ylabel('Character index χ', fontsize=10)
    plt.colorbar(im, ax=ax, shrink=0.8)

    plt.suptitle('Character Evaluation Matrices', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


# ============================================================
# Figure 4: Reconstruction Convergence
# ============================================================

def plot_reconstruction_convergence():
    """Show how candidates are eliminated during reconstruction."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    m = 3
    Q = sorted(list(product(range(m), repeat=3)))
    n = len(Q)
    hidden = Q[13]

    # Track candidate elimination
    chars_list = list(Q)  # indicator chars
    candidates_remaining = [n]
    queries = [0]

    remaining = set(Q)
    q_count = 0
    for a in chars_list:
        if len(remaining) <= 1:
            break
        chi_val = 1 if hidden == a else 0
        q_count += 1
        remaining = {q for q in remaining if (1 if q == a else 0) == chi_val}
        candidates_remaining.append(len(remaining))
        queries.append(q_count)

    ax.step(queries, candidates_remaining, where='post', linewidth=2.5,
           color='#e74c3c', label='Candidates remaining')
    ax.axhline(y=1, color='#2ecc71', linestyle='--', linewidth=1.5,
              label='Target: unique identification')
    ax.fill_between(queries, candidates_remaining, alpha=0.1, color='#e74c3c',
                   step='post')

    ax.set_xlabel('Number of Character Queries', fontsize=12)
    ax.set_ylabel('Candidate Points Remaining', fontsize=12)
    ax.set_title(f'Reconstruction Convergence (PQMod({m}), hidden={hidden})',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(0, n + 1)
    ax.grid(True, alpha=0.3)

    return fig


# ============================================================
# Figure 5: Noisy Reconstruction Phase Diagram
# ============================================================

def plot_noise_phase_diagram():
    """Show reconstruction success rate vs noise level."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    m = 3
    Q = sorted(list(product(range(m), repeat=3)))
    n = len(Q)
    chars = {}
    for a in Q:
        chars[a] = lambda q, a=a: 1.0 if q == a else 0.0

    noise_levels = np.linspace(0, 1.5, 30)
    success_rates = []

    hidden = Q[13]
    trials = 200
    np.random.seed(42)

    for noise_level in noise_levels:
        successes = 0
        for _ in range(trials):
            noise = {a: np.random.uniform(-noise_level, noise_level) for a in Q}
            # Nearest-neighbor reconstruction
            best_q = None
            best_dist = float('inf')
            for q in Q:
                dist = sum((chars[a](hidden) + noise[a] - chars[a](q))**2 for a in Q)
                if dist < best_dist:
                    best_dist = dist
                    best_q = q
            if best_q == hidden:
                successes += 1
        success_rates.append(successes / trials)

    ax.plot(noise_levels, success_rates, linewidth=2.5, color='#3498db',
           label='Success rate')
    ax.axvline(x=0.5, color='#e74c3c', linestyle='--', linewidth=1.5,
              label='δ/2 = 0.5 (theoretical threshold)')
    ax.fill_between(noise_levels, success_rates, alpha=0.1, color='#3498db')

    ax.set_xlabel('Noise Level ε', fontsize=12)
    ax.set_ylabel('Reconstruction Success Rate', fontsize=12)
    ax.set_title(f'Noisy Reconstruction Phase Transition (PQMod({m}))',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(-0.05, 1.1)
    ax.grid(True, alpha=0.3)

    return fig


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = plot_berggren_tree()
    save_fig(fig1, "berggren_tree.png")
    print("  ✓ berggren_tree.png")

    fig2 = plot_orbit_structure()
    save_fig(fig2, "orbit_structure.png")
    print("  ✓ orbit_structure.png")

    fig3 = plot_character_matrix()
    save_fig(fig3, "character_matrix.png")
    print("  ✓ character_matrix.png")

    fig4 = plot_reconstruction_convergence()
    save_fig(fig4, "reconstruction_convergence.png")
    print("  ✓ reconstruction_convergence.png")

    fig5 = plot_noise_phase_diagram()
    save_fig(fig5, "noise_phase_diagram.png")
    print("  ✓ noise_phase_diagram.png")

    print("\nAll visualizations saved.")
