#!/usr/bin/env python3
"""
Applications of Certified Expander Graphs from GL₂(𝔽_q)

This module demonstrates practical applications of certificate-driven
expander synthesis:

1. Deterministic network design — sparse communication topologies
2. Derandomization — converting randomized algorithms to deterministic ones
3. Error-correcting codes — expanding graphs for LDPC-like constructions
"""

import numpy as np
from itertools import product
from typing import List, Tuple


# ============================================================
# Helper: basic F_q matrix operations (self-contained)
# ============================================================

def mat_det_q(M, q):
    return int((M[0,0]*M[1,1] - M[0,1]*M[1,0]) % q)

def mat_mul_q(A, B, q):
    return (A @ B) % q

def mat_inv_q(M, q):
    d = mat_det_q(M, q)
    if d == 0: return None
    d_inv = pow(d, -1, q)
    return (d_inv * np.array([[M[1,1],-M[0,1]],[-M[1,0],M[0,0]]], dtype=int)) % q

def charpoly_irred(M, q):
    tr = int((M[0,0]+M[1,1]) % q)
    det = mat_det_q(M, q)
    disc = (tr*tr - 4*det) % q
    if disc == 0: return False
    return pow(int(disc), (q-1)//2, q) != 1

def is_prim_root(a, q):
    if a % q == 0: return False
    x = 1
    for k in range(1, q):
        x = (x*a) % q
        if x == 1: return k == q-1
    return False

def find_pair(q, limit=100):
    """Find a certified pair quickly."""
    I = np.eye(2, dtype=int)
    singers, prims = [], []
    for a,b,c,d in product(range(q), repeat=4):
        M = np.array([[a,b],[c,d]], dtype=int)
        det = mat_det_q(M, q)
        if det == 0: continue
        if np.array_equal(M % q, I): continue
        if charpoly_irred(M, q) and len(singers) < limit:
            singers.append(M % q)
        if is_prim_root(det, q) and len(prims) < limit:
            prims.append(M % q)
    # Test generation for first pair
    for g in singers[:20]:
        for h in prims[:20]:
            gl2_size = (q**2-1)*(q**2-q)
            generated = {tuple(I.flatten())}
            frontier = [I]
            g_inv, h_inv = mat_inv_q(g,q), mat_inv_q(h,q)
            if g_inv is None or h_inv is None: continue
            gens = [g, g_inv, h, h_inv]
            while frontier:
                nf = []
                for m in frontier:
                    for gen in gens:
                        p = mat_mul_q(m, gen, q)
                        t = tuple(p.flatten())
                        if t not in generated:
                            generated.add(t)
                            nf.append(p)
                            if len(generated) >= gl2_size:
                                return g, h
                frontier = nf
            if len(generated) >= gl2_size:
                return g, h
    return None, None


# ============================================================
# Application 1: Deterministic Network Design
# ============================================================

def design_communication_network(q: int) -> dict:
    """
    Design a sparse, highly-connected communication network using
    certified expander graphs.

    The network has |GL₂(𝔽_q)| = (q²-1)(q²-q) nodes, each connected
    to exactly 4 neighbors via the Cayley graph structure. Despite
    this extreme sparsity (4-regular), the network has rapid mixing
    and robust connectivity.

    Returns:
        Dictionary with network properties and adjacency data.
    """
    g, h = find_pair(q)
    if g is None:
        return {"error": "No certified pair found"}

    n_nodes = (q**2 - 1) * (q**2 - q)

    # Build adjacency list (more efficient than full matrix for applications)
    gl2 = []
    for a,b,c,d in product(range(q), repeat=4):
        M = np.array([[a,b],[c,d]], dtype=int)
        if mat_det_q(M, q) != 0:
            gl2.append(M)

    idx = {tuple(M.flatten()): i for i, M in enumerate(gl2)}
    g_inv, h_inv = mat_inv_q(g, q), mat_inv_q(h, q)
    gens = [g, g_inv, h, h_inv]

    adj_list = {}
    for i, M in enumerate(gl2):
        neighbors = []
        for gen in gens:
            prod = mat_mul_q(M, gen, q)
            neighbors.append(idx[tuple(prod.flatten())])
        adj_list[i] = neighbors

    return {
        "q": q,
        "n_nodes": n_nodes,
        "degree": 4,
        "edges": n_nodes * 2,  # 4-regular, each edge counted once per direction
        "density": 4.0 / n_nodes,
        "generators": {"g": g.tolist(), "h": h.tolist()},
        "adj_list_sample": {k: v for k, v in list(adj_list.items())[:5]},
    }


# ============================================================
# Application 2: Random Walk Simulation
# ============================================================

def simulate_random_walk(q: int, steps: int = 100) -> dict:
    """
    Simulate a random walk on the certified Cayley graph and measure
    convergence to the uniform distribution.

    Returns mixing time estimates and distribution snapshots.
    """
    g, h = find_pair(q)
    if g is None:
        return {"error": "No pair found"}

    gl2 = []
    for a,b,c,d in product(range(q), repeat=4):
        M = np.array([[a,b],[c,d]], dtype=int)
        if mat_det_q(M, q) != 0:
            gl2.append(M)

    n = len(gl2)
    idx = {tuple(M.flatten()): i for i, M in enumerate(gl2)}
    g_inv, h_inv = mat_inv_q(g, q), mat_inv_q(h, q)
    gens = [g, g_inv, h, h_inv]

    # Start from identity
    dist = np.zeros(n)
    dist[idx[tuple(np.eye(2, dtype=int).flatten())]] = 1.0

    uniform = np.ones(n) / n
    tv_distances = []

    for step in range(steps):
        new_dist = np.zeros(n)
        for i, M in enumerate(gl2):
            if dist[i] > 1e-15:
                for gen in gens:
                    j = idx[tuple(mat_mul_q(M, gen, q).flatten())]
                    new_dist[j] += dist[i] / 4.0
        dist = new_dist
        tv = 0.5 * np.sum(np.abs(dist - uniform))
        tv_distances.append(tv)

    # Estimate mixing time (time to reach TV < 1/4)
    mixing_time = next((t for t, tv in enumerate(tv_distances) if tv < 0.25), steps)

    return {
        "q": q,
        "group_size": n,
        "steps": steps,
        "mixing_time_estimate": mixing_time,
        "final_tv_distance": tv_distances[-1],
        "tv_distances": tv_distances[:20],
    }


# ============================================================
# Application 3: Hash Family Construction
# ============================================================

def construct_hash_family(q: int) -> dict:
    """
    Construct an almost-universal hash family from the Cayley graph.

    The expanding property guarantees that the hash family has good
    collision bounds, making it suitable for derandomization applications.
    """
    g, h = find_pair(q)
    if g is None:
        return {"error": "No pair found"}

    n = (q**2 - 1) * (q**2 - q)

    return {
        "q": q,
        "universe_size": n,
        "hash_family_size": 4,  # One hash per generator
        "collision_probability_bound": f"≤ 1/γ · 1/{n} where γ is spectral gap",
        "description": (
            f"Hash family from Cayley graph of GL₂(𝔽_{q}). "
            f"Each hash function h_s(x) = x·s maps GL₂ to itself. "
            f"The expanding property ensures low collision probability."
        )
    }


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    q = 5
    print("=" * 60)
    print("Application 1: Deterministic Network Design")
    print("=" * 60)
    net = design_communication_network(q)
    for k, v in net.items():
        if k != "adj_list_sample":
            print(f"  {k}: {v}")

    print("\n" + "=" * 60)
    print("Application 2: Random Walk Simulation")
    print("=" * 60)
    walk = simulate_random_walk(q, steps=50)
    print(f"  Group size: {walk.get('group_size', 'N/A')}")
    print(f"  Mixing time estimate: {walk.get('mixing_time_estimate', 'N/A')} steps")
    print(f"  Final TV distance: {walk.get('final_tv_distance', 'N/A'):.6f}")
    print(f"  First 10 TV distances: {[f'{d:.4f}' for d in walk.get('tv_distances', [])[:10]]}")

    print("\n" + "=" * 60)
    print("Application 3: Hash Family Construction")
    print("=" * 60)
    hf = construct_hash_family(q)
    for k, v in hf.items():
        print(f"  {k}: {v}")


#!/usr/bin/env python3
"""
Demo: Certified Expander Pairs for GL₂(𝔽_q)

This script searches for algebraically certified expander pairs (g, h)
in GL₂(𝔽_q) for small primes q, computes the Cayley graph spectrum,
and reports the spectral gap. The certificates are:
  - g is Singer-like: charpoly(g) is irreducible over 𝔽_q
  - h has primitive determinant: det(h) generates 𝔽_q×
  - (g, h) generate GL₂(𝔽_q)

Usage: python demo.py [q]  (default q=5)
"""

import numpy as np
from itertools import product
import sys


def zmod(q):
    """Arithmetic in Z/qZ."""
    return lambda x: x % q


def mat2_over_fq(q):
    """Generate all 2x2 matrices over F_q."""
    for a, b, c, d in product(range(q), repeat=4):
        yield np.array([[a, b], [c, d]], dtype=int)


def mat_det(M, q):
    """Determinant of 2x2 matrix mod q."""
    return (M[0, 0] * M[1, 1] - M[0, 1] * M[1, 0]) % q


def mat_mul(A, B, q):
    """Matrix multiplication mod q."""
    return (A @ B) % q


def mat_inv(M, q):
    """Inverse of 2x2 matrix mod q, or None if singular."""
    d = mat_det(M, q)
    if d == 0:
        return None
    d_inv = pow(int(d), -1, q)
    inv = np.array([[M[1, 1], -M[0, 1]], [-M[1, 0], M[0, 0]]], dtype=int)
    return (d_inv * inv) % q


def charpoly_coeffs(M, q):
    """Characteristic polynomial X^2 - tr(M)X + det(M) mod q. Returns (tr, det)."""
    tr = (M[0, 0] + M[1, 1]) % q
    det = mat_det(M, q)
    return tr, det


def is_irreducible_quadratic(tr, det, q):
    """Check if X^2 - tr*X + det is irreducible over F_q.
    A quadratic is irreducible iff it has no roots, i.e., discriminant is non-square."""
    disc = (tr * tr - 4 * det) % q
    if disc == 0:
        return False
    # Check if disc is a quadratic residue mod q
    return pow(int(disc), (q - 1) // 2, q) != 1


def is_singer_like(M, q):
    """Check if M is Singer-like: invertible with irreducible charpoly."""
    if mat_det(M, q) == 0:
        return False
    tr, det = charpoly_coeffs(M, q)
    return is_irreducible_quadratic(tr, det, q)


def multiplicative_order(a, q):
    """Order of a in (Z/qZ)×."""
    if a % q == 0:
        return 0
    x = a % q
    for k in range(1, q):
        if pow(int(x), k, q) == 1:
            return k
    return q - 1


def is_primitive_det(M, q):
    """Check if det(M) is a primitive root mod q."""
    d = mat_det(M, q)
    if d == 0:
        return False
    return multiplicative_order(d, q) == q - 1


def mat_to_tuple(M, q):
    """Convert matrix to hashable tuple."""
    return tuple((M % q).flatten())


def generates_gl2(g, h, q, max_size=None):
    """Check if g, h generate GL_2(F_q) by closure computation."""
    gl2_size = (q**2 - 1) * (q**2 - q)
    if max_size is None:
        max_size = gl2_size

    identity = np.eye(2, dtype=int)
    g_inv = mat_inv(g, q)
    h_inv = mat_inv(h, q)
    if g_inv is None or h_inv is None:
        return False

    generated = set()
    generated.add(mat_to_tuple(identity, q))
    frontier = [identity]

    generators = [g, g_inv, h, h_inv]

    while frontier:
        new_frontier = []
        for m in frontier:
            for gen in generators:
                prod = mat_mul(m, gen, q)
                t = mat_to_tuple(prod, q)
                if t not in generated:
                    generated.add(t)
                    new_frontier.append(prod)
                    if len(generated) >= max_size:
                        return len(generated) >= gl2_size
        frontier = new_frontier

    return len(generated) >= gl2_size


def cayley_graph_adjacency(g, h, q):
    """Build the adjacency matrix of Cay(GL_2(F_q), {g, g^-1, h, h^-1})."""
    # Enumerate GL_2(F_q)
    gl2_elements = []
    for M in mat2_over_fq(q):
        if mat_det(M, q) != 0:
            gl2_elements.append(M)

    n = len(gl2_elements)
    index_map = {}
    for i, M in enumerate(gl2_elements):
        index_map[mat_to_tuple(M, q)] = i

    g_inv = mat_inv(g, q)
    h_inv = mat_inv(h, q)
    generators = [g, g_inv, h, h_inv]

    A = np.zeros((n, n), dtype=float)
    for i, M in enumerate(gl2_elements):
        for gen in generators:
            prod = mat_mul(M, gen, q)
            j = index_map[mat_to_tuple(prod, q)]
            A[i, j] = 1.0

    return A / 4.0, gl2_elements


def compute_spectral_gap(A):
    """Compute spectral gap of normalized adjacency matrix."""
    eigenvalues = np.linalg.eigvalsh(A)
    eigenvalues = np.sort(eigenvalues)[::-1]
    # Largest eigenvalue should be 1 (for connected regular graph)
    lambda1 = eigenvalues[0]
    lambda2 = max(abs(eigenvalues[1]), abs(eigenvalues[-1]))
    gap = lambda1 - lambda2
    return gap, eigenvalues


def find_certified_pairs(q, max_pairs=5):
    """Find certified pairs (g, h) in GL_2(F_q)."""
    pairs = []
    identity = np.eye(2, dtype=int)

    # Find Singer-like elements
    singers = []
    for M in mat2_over_fq(q):
        if is_singer_like(M, q) and not np.array_equal(M % q, identity):
            singers.append(M)
    print(f"  Found {len(singers)} Singer-like elements")

    # Find primitive determinant elements
    primitives = []
    for M in mat2_over_fq(q):
        if is_primitive_det(M, q) and not np.array_equal(M % q, identity):
            primitives.append(M)
    print(f"  Found {len(primitives)} primitive-det elements")

    # Try pairs
    for g in singers[:50]:  # Limit search
        for h in primitives[:50]:
            if len(pairs) >= max_pairs:
                return pairs
            if generates_gl2(g, h, q):
                pairs.append((g % q, h % q))
    return pairs


def main():
    q = int(sys.argv[1]) if len(sys.argv) > 1 else 5

    if q < 5:
        print("q must be >= 5")
        return

    print(f"=" * 60)
    print(f"  Certified Expander Pairs for GL₂(𝔽_{q})")
    print(f"=" * 60)
    print(f"\n|GL₂(𝔽_{q})| = {(q**2 - 1) * (q**2 - q)}")
    print(f"\nSearching for certified pairs...")

    pairs = find_certified_pairs(q, max_pairs=3)

    if not pairs:
        print("No certified pairs found in search range.")
        return

    print(f"\nFound {len(pairs)} certified pair(s).")

    results = []
    for idx, (g, h) in enumerate(pairs):
        print(f"\n--- Pair {idx + 1} ---")
        print(f"g = {g.tolist()}")
        print(f"h = {h.tolist()}")
        tr, det = charpoly_coeffs(g, q)
        print(f"charpoly(g) = X² - {tr}X + {det} (irreducible over 𝔽_{q})")
        print(f"det(h) = {mat_det(h, q)} (order {multiplicative_order(mat_det(h, q), q)} in 𝔽_{q}×)")

        print(f"\nComputing Cayley graph spectrum...")
        A, _ = cayley_graph_adjacency(g, h, q)
        gap, eigenvalues = compute_spectral_gap(A)
        print(f"Spectral gap γ = {gap:.6f}")
        print(f"q · γ = {q * gap:.6f}")
        print(f"Top 5 eigenvalues: {eigenvalues[:5]}")
        print(f"Bottom 5 eigenvalues: {eigenvalues[-5:]}")
        results.append((g, h, gap))

    print(f"\n{'=' * 60}")
    print(f"  Summary for q = {q}")
    print(f"{'=' * 60}")
    min_gap = min(r[2] for r in results)
    print(f"Minimum spectral gap: {min_gap:.6f}")
    print(f"q · min(γ): {q * min_gap:.6f}")
    print(f"\nConjecture: q · γ ≥ C₀ for some absolute constant C₀ > 0")
    print(f"Observed value suggests C₀ ≈ {q * min_gap:.4f} (for q = {q})")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Projective Line Action of Singer-Like Elements

This script visualizes the action of Singer-like matrices on the projective
line P¹(F_q). It demonstrates the key geometric theorem: Singer-like elements
(those with irreducible characteristic polynomial) act WITHOUT fixed points
on P¹, in contrast to non-Singer elements that have 1 or 2 fixed points.

This geometric property is the engine of certified expansion: the absence
of fixed projective points forces the averaging operator to mix all
directions, preventing concentration on low-dimensional invariant subspaces.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def mod_inv(a, q):
    if a % q == 0: return None
    return pow(a, q-2, q)

def mat_det(M, q):
    return int((M[0,0]*M[1,1] - M[0,1]*M[1,0]) % q)

def charpoly_irred(M, q):
    tr = int((M[0,0]+M[1,1]) % q)
    det = mat_det(M, q)
    disc = (tr*tr - 4*det) % q
    if disc == 0: return False
    return pow(int(disc), (q-1)//2, q) != 1

def proj_line(q):
    pts = [(1, b) for b in range(q)] + [(0, 1)]
    return pts

def proj_action(M, pt, q):
    a, b = pt
    na = (int(M[0,0])*a + int(M[0,1])*b) % q
    nb = (int(M[1,0])*a + int(M[1,1])*b) % q
    if na != 0:
        inv = mod_inv(na, q)
        return (1, (inv * nb) % q)
    elif nb != 0:
        return (0, 1)
    raise ValueError("Singular")

def count_fixed_points(M, q):
    pts = proj_line(q)
    return sum(1 for p in pts if proj_action(M, p, q) == p)


q = 7  # Use q=7 for a clearer visualization

# Classify all invertible matrices by their projective fixed-point count
singer_fps = []
non_singer_fps = []
all_fps = {0: 0, 1: 0, 2: 0}

for a,b,c,d in product(range(q), repeat=4):
    M = np.array([[a,b],[c,d]], dtype=int)
    if mat_det(M, q) == 0: continue
    if np.array_equal(M%q, np.eye(2,dtype=int)): continue
    nfp = count_fixed_points(M, q)
    nfp = min(nfp, 2)  # cap
    all_fps[nfp] = all_fps.get(nfp, 0) + 1
    if charpoly_irred(M, q):
        singer_fps.append(nfp)
    else:
        non_singer_fps.append(nfp)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Distribution of fixed points for Singer vs non-Singer
labels = ['0 fixed pts', '1 fixed pt', '2 fixed pts']
singer_counts = [singer_fps.count(i) for i in range(3)]
non_singer_counts = [non_singer_fps.count(i) for i in range(3)]

x = np.arange(3)
w = 0.35
axes[0].bar(x - w/2, singer_counts, w, label='Singer-like', color='#2ca02c', alpha=0.8)
axes[0].bar(x + w/2, non_singer_counts, w, label='Non-Singer', color='#d62728', alpha=0.8)
axes[0].set_xticks(x)
axes[0].set_xticklabels(labels)
axes[0].set_ylabel('Count')
axes[0].set_title(f'Fixed Points on P¹(𝔽_{q})\nSinger-like vs Non-Singer', fontweight='bold')
axes[0].legend()
axes[0].text(0.5, 0.9, f'ALL Singer-like: 0 fixed points ✓',
             transform=axes[0].transAxes, fontsize=10, ha='center',
             color='#2ca02c', fontweight='bold')

# Plot 2: Orbit diagram for a Singer-like element
# Find a Singer-like element
singer_M = None
for a,b,c,d in product(range(q), repeat=4):
    M = np.array([[a,b],[c,d]], dtype=int)
    if mat_det(M, q) != 0 and charpoly_irred(M, q):
        singer_M = M % q
        break

pts = proj_line(q)
n_pts = len(pts)

# Draw the orbit structure
angles = np.linspace(0, 2*np.pi, n_pts, endpoint=False)
px = np.cos(angles)
py = np.sin(angles)

axes[1].set_xlim(-1.5, 1.5)
axes[1].set_ylim(-1.5, 1.5)
axes[1].set_aspect('equal')

for i, p in enumerate(pts):
    img = proj_action(singer_M, p, q)
    j = pts.index(img)
    # Draw arrow from p to image
    dx = px[j] - px[i]
    dy = py[j] - py[i]
    axes[1].annotate('', xy=(px[j]*0.9, py[j]*0.9),
                     xytext=(px[i]*0.9, py[i]*0.9),
                     arrowprops=dict(arrowstyle='->', color='steelblue', lw=1.5))
    label = f'({p[0]}:{p[1]})' if p[0] == 1 else '∞'
    axes[1].plot(px[i], py[i], 'ko', markersize=8)
    axes[1].text(px[i]*1.15, py[i]*1.15, label, ha='center', va='center', fontsize=8)

axes[1].set_title(f'Singer-like action on P¹(𝔽_{q})\n(No fixed points — all orbits are cycles)',
                  fontweight='bold')
axes[1].axis('off')

# Plot 3: Find a non-Singer element with fixed points and show its action
non_singer_M = None
for a,b,c,d in product(range(q), repeat=4):
    M = np.array([[a,b],[c,d]], dtype=int)
    if mat_det(M, q) != 0 and not charpoly_irred(M, q):
        nfp = count_fixed_points(M, q)
        if nfp >= 1 and not np.array_equal(M%q, np.eye(2,dtype=int)):
            non_singer_M = M % q
            break

axes[2].set_xlim(-1.5, 1.5)
axes[2].set_ylim(-1.5, 1.5)
axes[2].set_aspect('equal')

fixed_indices = []
for i, p in enumerate(pts):
    img = proj_action(non_singer_M, p, q)
    j = pts.index(img)
    if i == j:
        fixed_indices.append(i)
    axes[2].annotate('', xy=(px[j]*0.9, py[j]*0.9),
                     xytext=(px[i]*0.9, py[i]*0.9),
                     arrowprops=dict(arrowstyle='->', color='coral', lw=1.5))
    label = f'({p[0]}:{p[1]})' if p[0] == 1 else '∞'
    color = 'red' if i in fixed_indices else 'black'
    size = 12 if i in fixed_indices else 8
    axes[2].plot(px[i], py[i], 'o', color=color, markersize=size)
    axes[2].text(px[i]*1.15, py[i]*1.15, label, ha='center', va='center',
                fontsize=8, color=color, fontweight='bold' if i in fixed_indices else 'normal')

axes[2].set_title(f'Non-Singer action on P¹(𝔽_{q})\n(Has {len(fixed_indices)} fixed point(s) — shown in red)',
                  fontweight='bold')
axes[2].axis('off')

plt.suptitle('The Geometric Engine of Certified Expansion:\nSinger-Like Elements Have No Fixed Points on the Projective Line',
             fontsize=13, fontweight='bold', y=1.04)
plt.tight_layout()
plt.savefig('projective_action.png', dpi=150, bbox_inches='tight')
print("Saved projective_action.png")
print(f"\nSinger-like elements in GL₂(𝔽_{q}): {len(singer_fps)} (all have 0 fixed points)")
print(f"Non-Singer elements: {len(non_singer_fps)} ({non_singer_counts[1]} with 1 fixed pt, {non_singer_counts[2]} with 2)")


#!/usr/bin/env python3
"""
Visualization: Spectral Gap of Certified Cayley Graphs

This script computes and visualizes the eigenvalue spectrum of Cayley graphs
built from algebraically certified pairs in GL₂(𝔽_q) for small primes.
It shows how the spectral gap γ (distance from eigenvalue 1 to the next
largest eigenvalue) scales with q, testing the Uniform Certified Gap Conjecture.

The visualization reveals the representation-theoretic structure: distinct
clusters of eigenvalues corresponding to different irreducible representations
of GL₂(𝔽_q).
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


# Self-contained matrix operations over F_q
def mat_det(M, q):
    return int((M[0,0]*M[1,1] - M[0,1]*M[1,0]) % q)

def mat_mul(A, B, q):
    return (A @ B) % q

def mat_inv(M, q):
    d = mat_det(M, q)
    if d == 0: return None
    d_inv = pow(d, -1, q)
    return (d_inv * np.array([[M[1,1],-M[0,1]],[-M[1,0],M[0,0]]], dtype=int)) % q

def charpoly_irred(M, q):
    tr = int((M[0,0]+M[1,1]) % q)
    det = mat_det(M, q)
    disc = (tr*tr - 4*det) % q
    if disc == 0: return False
    return pow(int(disc), (q-1)//2, q) != 1

def is_prim(a, q):
    if a % q == 0: return False
    x = 1
    for k in range(1, q):
        x = (x*a) % q
        if x == 1: return k == q-1
    return False

def find_pair_fast(q):
    I = np.eye(2, dtype=int)
    singers, prims = [], []
    for a,b,c,d in product(range(q), repeat=4):
        M = np.array([[a,b],[c,d]], dtype=int)
        det = mat_det(M, q)
        if det == 0: continue
        if np.array_equal(M%q, I): continue
        if charpoly_irred(M, q): singers.append(M%q)
        if is_prim(det, q): prims.append(M%q)
        if len(singers) > 30 and len(prims) > 30: break

    gl2_size = (q**2-1)*(q**2-q)
    for g in singers[:15]:
        for h in prims[:15]:
            gen = {tuple(I.flatten())}
            front = [I]
            gi, hi = mat_inv(g,q), mat_inv(h,q)
            if gi is None or hi is None: continue
            gs = [g, gi, h, hi]
            while front:
                nf = []
                for m in front:
                    for gen_ in gs:
                        p = mat_mul(m, gen_, q)
                        t = tuple(p.flatten())
                        if t not in gen:
                            gen.add(t)
                            nf.append(p)
                            if len(gen) >= gl2_size:
                                return g, h
                front = nf
            if len(gen) >= gl2_size:
                return g, h
    return None, None

def compute_spectrum(g, h, q):
    gl2 = []
    for a,b,c,d in product(range(q), repeat=4):
        M = np.array([[a,b],[c,d]], dtype=int)
        if mat_det(M, q) != 0:
            gl2.append(M)
    n = len(gl2)
    idx = {tuple(M.flatten()): i for i, M in enumerate(gl2)}
    gi, hi = mat_inv(g, q), mat_inv(h, q)
    gs = [g, gi, h, hi]
    A = np.zeros((n, n))
    for i, M in enumerate(gl2):
        for gen in gs:
            j = idx[tuple(mat_mul(M, gen, q).flatten())]
            A[i, j] = 1.0
    A /= 4.0
    return np.linalg.eigvalsh(A)


# Compute spectra for q = 5 and q = 7
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

primes = [5, 7]
gaps = []

for idx, q in enumerate(primes):
    g, h = find_pair_fast(q)
    if g is None:
        continue
    eigs = compute_spectrum(g, h, q)
    eigs_sorted = np.sort(eigs)[::-1]
    gap = eigs_sorted[0] - max(abs(eigs_sorted[1]), abs(eigs_sorted[-1]))
    gaps.append((q, gap))

    # Histogram of eigenvalues
    axes[idx, 0].hist(eigs, bins=80, color='steelblue', alpha=0.8, edgecolor='navy')
    axes[idx, 0].axvline(x=1.0, color='red', linestyle='--', linewidth=2, label=f'λ₁ = 1')
    axes[idx, 0].axvline(x=eigs_sorted[1], color='orange', linestyle='--', linewidth=1.5,
                         label=f'λ₂ = {eigs_sorted[1]:.4f}')
    axes[idx, 0].set_title(f'Eigenvalue Spectrum: GL₂(𝔽_{q}), |G| = {len(eigs)}',
                           fontsize=12, fontweight='bold')
    axes[idx, 0].set_xlabel('Eigenvalue')
    axes[idx, 0].set_ylabel('Count')
    axes[idx, 0].legend(fontsize=9)
    axes[idx, 0].text(0.02, 0.95, f'γ = {gap:.5f}\nq·γ = {q*gap:.5f}',
                      transform=axes[idx, 0].transAxes, fontsize=10,
                      verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    # Sorted eigenvalues
    axes[idx, 1].plot(range(len(eigs_sorted)), eigs_sorted, 'b-', linewidth=0.5, alpha=0.7)
    axes[idx, 1].axhline(y=1.0, color='red', linestyle='--', alpha=0.5)
    axes[idx, 1].set_title(f'Sorted Eigenvalues: GL₂(𝔽_{q})', fontsize=12, fontweight='bold')
    axes[idx, 1].set_xlabel('Index')
    axes[idx, 1].set_ylabel('Eigenvalue')

plt.suptitle('Spectral Structure of Certified Cayley Graphs for GL₂(𝔽_q)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_gaps.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gaps.png")

for q, gap in gaps:
    print(f"q = {q}: γ = {gap:.6f}, q·γ = {q*gap:.6f}")
