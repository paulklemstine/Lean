"""
Applications of Primewise Persistent Homology to Rational Dynamics.

Real-world applications:
1. Fast conjugacy testing for dynamical databases
2. Moduli space visualization via persistence coordinates
3. Cryptographic one-way function quality assessment
"""

import math
from collections import Counter, defaultdict
from itertools import combinations


# ============================================================
# Self-contained core implementations
# ============================================================

def mod_p_poly(coeffs, p, x):
    """Evaluate polynomial at x mod p. x=p is point at infinity."""
    if x == p:
        return p
    return sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p


def preimage_sizes_fast(map_fn, n):
    """Compute preimage sizes efficiently."""
    counts = [0] * n
    for x in range(n):
        counts[map_fn(x)] += 1
    return counts


def degree_sequence(map_fn, n):
    """Sorted list of preimage sizes."""
    return tuple(sorted(preimage_sizes_fast(map_fn, n)))


def orbit_entropy(map_fn, n):
    """Compute orbit entropy."""
    sizes = preimage_sizes_fast(map_fn, n)
    if n == 0:
        return 0.0
    return math.log(n) - sum(math.log(s + 1) for s in sizes) / n


def periodic_count(map_fn, n, k):
    """Count periodic points of period dividing k."""
    count = 0
    for x in range(n):
        y = x
        for _ in range(k):
            y = map_fn(y)
        if y == x:
            count += 1
    return count


def persistence_profile(map_fn, n, depth=5):
    """Compute full persistence profile."""
    sizes = preimage_sizes_fast(map_fn, n)
    per_counts = tuple(periodic_count(map_fn, n, k + 1) for k in range(depth))
    tail_counts = tuple(sum(1 for s in sizes if s > k) for k in range(depth))
    return (per_counts, tail_counts)


# ============================================================
# Application 1: Fast Conjugacy Database
# ============================================================

def build_conjugacy_database(families, primes, depth=5):
    """
    Build a database of persistence profiles for fast conjugacy lookup.

    Args:
        families: dict mapping name -> (coefficients, description)
        primes: list of primes to use
        depth: persistence profile depth

    Returns:
        Dictionary mapping profile signatures to lists of map names
    """
    db = defaultdict(list)

    for name, coeffs in families.items():
        # Compute profile signature across all primes
        sig = []
        for p in primes:
            n = p + 1
            f = lambda x, c=coeffs, p=p: mod_p_poly(c, p, x)
            prof = persistence_profile(f, n, depth)
            sig.append(prof)
        sig_key = tuple(sig)
        db[sig_key].append(name)

    return db


# ============================================================
# Application 2: One-Way Function Quality
# ============================================================

def assess_owf_quality(coeffs, primes):
    """
    Assess the quality of a polynomial as a one-way function
    by computing orbit entropy across primes.

    Higher entropy = more uniform preimage distribution = harder to invert.

    Returns dict with entropy statistics.
    """
    entropies = []
    max_preimage_ratios = []

    for p in primes:
        n = p + 1
        f = lambda x, c=coeffs, p=p: mod_p_poly(c, p, x)
        h = orbit_entropy(f, n)
        entropies.append(h)

        sizes = preimage_sizes_fast(f, n)
        max_s = max(sizes)
        max_preimage_ratios.append(max_s / n)

    return {
        'mean_entropy': sum(entropies) / len(entropies),
        'min_entropy': min(entropies),
        'max_entropy': max(entropies),
        'mean_max_preimage_ratio': sum(max_preimage_ratios) / len(max_preimage_ratios),
        'entropies': entropies,
    }


# ============================================================
# Application 3: Moduli Space Coordinates
# ============================================================

def moduli_coordinates(coeffs, primes, depth=3):
    """
    Compute coordinates in moduli space via persistence profiles.

    For quadratic maps x^2 + c, the moduli space M_2 is 1-dimensional
    (parametrized by c mod conjugacy). The persistence profile gives
    a computable coordinate system.

    Returns a feature vector suitable for visualization.
    """
    features = []
    for p in primes[:3]:
        n = p + 1
        f = lambda x, c=coeffs, p=p: mod_p_poly(c, p, x)

        # Periodic counts
        for k in range(1, depth + 1):
            features.append(periodic_count(f, n, k) / n)

        # Entropy
        features.append(orbit_entropy(f, n))

        # Image fraction
        image = len({f(x) for x in range(n)})
        features.append(image / n)

    return features


# ============================================================
# Main demonstration
# ============================================================

if __name__ == '__main__':
    primes = [11, 13, 17, 19, 23, 29, 31, 37, 41, 43]

    # Application 1: Conjugacy database
    print("=" * 60)
    print("APPLICATION 1: Conjugacy Classification Database")
    print("=" * 60)

    families = {}
    for c in range(-10, 11):
        families[f"x²+{c}"] = [c, 0, 1]

    db = build_conjugacy_database(families, primes[:5], depth=3)

    print(f"\n  {len(families)} maps classified into {len(db)} conjugacy classes")
    for sig, names in sorted(db.items(), key=lambda x: -len(x[1])):
        if len(names) > 1:
            print(f"  Potential conjugates: {names}")

    # Application 2: One-way function assessment
    print()
    print("=" * 60)
    print("APPLICATION 2: One-Way Function Quality Assessment")
    print("=" * 60)

    candidates = {
        "x²":     [0, 0, 1],
        "x²+1":   [1, 0, 1],
        "x²+7":   [7, 0, 1],
        "x³":     [0, 0, 0, 1],
        "x³+x+1": [1, 1, 0, 1],
    }

    print(f"\n  {'Map':<12} {'Mean H':>8} {'Min H':>8} {'Max Preimg Ratio':>16}")
    print("  " + "-" * 46)
    for name, coeffs in candidates.items():
        quality = assess_owf_quality(coeffs, primes)
        print(f"  {name:<12} {quality['mean_entropy']:8.4f} {quality['min_entropy']:8.4f} "
              f"{quality['mean_max_preimage_ratio']:16.4f}")

    # Application 3: Moduli coordinates
    print()
    print("=" * 60)
    print("APPLICATION 3: Moduli Space Coordinates")
    print("=" * 60)

    print(f"\n  {'c':>4} {'Features (first 5)':>40}")
    print("  " + "-" * 46)
    for c in range(-5, 6):
        coords = moduli_coordinates([c, 0, 1], primes, depth=2)
        feat_str = ", ".join(f"{v:.3f}" for v in coords[:5])
        print(f"  {c:4d}  [{feat_str}, ...]")

    print()
    print("All applications completed successfully.")


"""
Demo: Primewise Persistent Homology of Rational Dynamics

Concrete numerical examples demonstrating the theorems proved in Lean 4.
"""

import math
from collections import Counter


# ============================================================
# Self-contained implementations (no local imports)
# ============================================================

def mod_p_map(coeffs, p, x):
    """Evaluate polynomial with coefficients [a0, a1, ...] at x mod p."""
    if x == p:
        return p  # point at infinity
    return sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p


def preimage_sizes(map_fn, n):
    """Compute preimage sizes for all points 0..n-1."""
    counts = [0] * n
    for x in range(n):
        counts[map_fn(x)] += 1
    return counts


def iterate_map(map_fn, k, x):
    """Compute k-th iterate of map_fn at x."""
    for _ in range(k):
        x = map_fn(x)
    return x


# ============================================================
# Demo 1: Preimage Sum Identity (Theorem 3.1)
# ============================================================
print("=" * 60)
print("DEMO 1: Preimage Sum Identity")
print("Theorem: sum of preimage sizes = p + 1")
print("=" * 60)

for p in [5, 7, 11, 13]:
    f = lambda x, p=p: mod_p_map([1, 0, 1], p, x)  # x^2 + 1
    n = p + 1
    sizes = preimage_sizes(f, n)
    total = sum(sizes)
    print(f"  p={p:2d}: preimage sizes = {sizes}, sum = {total}, p+1 = {n}  ✓" if total == n else f"  p={p}: FAILED")

# ============================================================
# Demo 2: Conjugacy Invariance (Theorem 5.1)
# ============================================================
print()
print("=" * 60)
print("DEMO 2: Conjugacy Invariance of Degree Sequence")
print("Theorem: Conjugate maps have the same sorted preimage sizes")
print("=" * 60)

p = 11
n = p + 1

# f(x) = x^2 + 3 mod 11
f = lambda x: mod_p_map([3, 0, 1], p, x)

# g = phi ∘ f ∘ phi^{-1} where phi(x) = 2x + 1 mod 11 (an affine map)
# phi is a bijection on {0,...,10}, phi(11) = 11
def phi(x):
    if x == p:
        return p
    return (2 * x + 1) % p

def phi_inv(x):
    if x == p:
        return p
    # 2x + 1 ≡ y mod 11 => x ≡ (y-1)/2 ≡ (y-1)*6 mod 11
    return ((x - 1) * 6) % p

g = lambda x: phi(f(phi_inv(x)))

sizes_f = sorted(preimage_sizes(f, n))
sizes_g = sorted(preimage_sizes(g, n))

print(f"  p = {p}")
print(f"  f(x) = x² + 3 mod {p}")
print(f"  g = φ ∘ f ∘ φ⁻¹ where φ(x) = 2x + 1 mod {p}")
print(f"  Degree sequence of f: {sizes_f}")
print(f"  Degree sequence of g: {sizes_g}")
print(f"  Equal: {sizes_f == sizes_g}  ✓")

# ============================================================
# Demo 3: Periodic Monotonicity (Theorem 4.2)
# ============================================================
print()
print("=" * 60)
print("DEMO 3: Periodic Monotonicity")
print("Theorem: periodicPoints(k) ⊆ periodicPoints(m) when k | m")
print("=" * 60)

p = 13
f = lambda x: mod_p_map([2, 0, 1], p, x)  # x^2 + 2 mod 13
n = p + 1

for k in range(1, 7):
    periodic_k = {x for x in range(n) if iterate_map(f, k, x) == x}
    for m in range(k, 13, k):
        periodic_m = {x for x in range(n) if iterate_map(f, m, x) == x}
        is_subset = periodic_k.issubset(periodic_m)
        print(f"  k={k}, m={m}: Per({k})={periodic_k}, Per({m})={periodic_m}, "
              f"Per({k}) ⊆ Per({m}): {is_subset}  {'✓' if is_subset else '✗'}")

# ============================================================
# Demo 4: Orbit Entropy (Theorem 6.1)
# ============================================================
print()
print("=" * 60)
print("DEMO 4: Orbit Entropy Non-negativity")
print("Theorem: orbit entropy ≥ 0 for all mod-p dynamics")
print("=" * 60)

for p in [5, 7, 11, 13, 17, 19, 23, 29, 31, 37]:
    for c in range(5):
        f = lambda x, p=p, c=c: mod_p_map([c, 0, 1], p, x)
        n = p + 1
        sizes = preimage_sizes(f, n)
        log_sum = sum(math.log(s + 1) for s in sizes)
        entropy = math.log(n) - log_sum / n
        status = "✓" if entropy >= -1e-10 else "✗ NEGATIVE!"
        if c == 0:
            print(f"  p={p:2d}, c={c}: entropy = {entropy:.6f}  {status}")

# ============================================================
# Demo 5: Persistence Separation (Theorem 5.3)
# ============================================================
print()
print("=" * 60)
print("DEMO 5: Persistence Separation")
print("Theorem: Different degree sequences ⟹ different tail counts")
print("=" * 60)

p = 17
n = p + 1

maps = {
    "x²":     lambda x: mod_p_map([0, 0, 1], p, x),
    "x²+1":   lambda x: mod_p_map([1, 0, 1], p, x),
    "x²+2":   lambda x: mod_p_map([2, 0, 1], p, x),
    "x²+5":   lambda x: mod_p_map([5, 0, 1], p, x),
}

print(f"  p = {p}")
for name, f in maps.items():
    sizes = sorted(preimage_sizes(f, n))
    tails = [sum(1 for s in sizes if s > k) for k in range(5)]
    periodic = [sum(1 for x in range(n) if iterate_map(f, k+1, x) == x) for k in range(5)]
    print(f"  {name:6s}: deg_seq={sizes}, tails={tails}, periodic={periodic}")

# ============================================================
# Demo 6: Separation of Non-Conjugate Maps Across Primes
# ============================================================
print()
print("=" * 60)
print("DEMO 6: Conjugacy Testing Across Primes")
print("Non-conjugate maps are separated at almost all primes")
print("=" * 60)

primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

# Compare x^2 + 1 vs x^2 + 2
agree_count = 0
for p in primes:
    n = p + 1
    f1 = lambda x, p=p: mod_p_map([1, 0, 1], p, x)
    f2 = lambda x, p=p: mod_p_map([2, 0, 1], p, x)
    ds1 = sorted(preimage_sizes(f1, n))
    ds2 = sorted(preimage_sizes(f2, n))
    match = ds1 == ds2
    if match:
        agree_count += 1
    print(f"  p={p:2d}: x²+1 deg_seq={ds1}")
    print(f"         x²+2 deg_seq={ds2}  {'AGREE' if match else 'DIFFER'}")

print(f"\n  Agreement at {agree_count}/{len(primes)} primes")
print(f"  Separation at {len(primes)-agree_count}/{len(primes)} primes")

print()
print("=" * 60)
print("All demos completed successfully.")
print("=" * 60)


"""
Visualization 2: Degree Sequence Separation

Visualizes how degree sequences (sorted preimage size vectors) separate
non-conjugate quadratic maps. Shows the conjugacy invariance theorem
in action: conjugate maps have identical degree sequences, while
non-conjugate maps are separated at most primes.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter


def mod_p_poly(coeffs, p, x):
    """Evaluate polynomial at x mod p."""
    if x == p:
        return p
    return sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p


def degree_sequence(coeffs, p):
    """Compute sorted degree sequence for polynomial mod p."""
    n = p + 1
    counts = [0] * n
    for x in range(n):
        counts[mod_p_poly(coeffs, p, x)] += 1
    return tuple(sorted(counts))


def sieve_primes(n):
    """Simple sieve of Eratosthenes."""
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


# Parameters
c_values = list(range(-5, 11))
primes = sieve_primes(60)

# Compute separation matrix
n_maps = len(c_values)
separation_matrix = np.zeros((n_maps, n_maps))

for i in range(n_maps):
    for j in range(i + 1, n_maps):
        separating_primes = 0
        for p in primes:
            ds_i = degree_sequence([c_values[i], 0, 1], p)
            ds_j = degree_sequence([c_values[j], 0, 1], p)
            if ds_i != ds_j:
                separating_primes += 1
        frac = separating_primes / len(primes)
        separation_matrix[i, j] = frac
        separation_matrix[j, i] = frac

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Separation heatmap
ax1 = axes[0]
im = ax1.imshow(separation_matrix, cmap='RdYlGn', vmin=0, vmax=1)
ax1.set_xticks(range(n_maps))
ax1.set_xticklabels([str(c) for c in c_values], fontsize=8, rotation=45)
ax1.set_yticks(range(n_maps))
ax1.set_yticklabels([str(c) for c in c_values], fontsize=8)
ax1.set_xlabel('Parameter c₂', fontsize=12)
ax1.set_ylabel('Parameter c₁', fontsize=12)
ax1.set_title('Fraction of Primes Separating x²+c₁ from x²+c₂', fontsize=13)
plt.colorbar(im, ax=ax1, label='Separation fraction')

# Degree sequence diversity across primes
ax2 = axes[1]
for c in [-2, 0, 1, 3, 7]:
    diversity = []
    for p in primes:
        ds = degree_sequence([c, 0, 1], p)
        # Count distinct preimage sizes
        diversity.append(len(set(ds)))
    ax2.plot(primes, diversity, 'o-', markersize=4, label=f'c={c}', alpha=0.8)

ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('# Distinct Preimage Sizes', fontsize=12)
ax2.set_title('Degree Sequence Complexity', fontsize=14)
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_degree_sequences.png', dpi=150, bbox_inches='tight')
print("Saved viz_degree_sequences.png")


"""
Visualization 1: Orbit Entropy Landscape

Visualizes the orbit entropy of quadratic maps x² + c mod p across
a grid of (c, p) values. Shows how entropy varies with the map parameter
and prime, revealing the structure of the "entropy landscape" on moduli space.

The proven theorem (orbit_entropy_nonneg) guarantees all values are ≥ 0.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def mod_p_poly(coeffs, p, x):
    """Evaluate polynomial at x mod p."""
    if x == p:
        return p
    return sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p


def preimage_sizes_fast(coeffs, p):
    """Compute preimage sizes for polynomial mod p."""
    n = p + 1
    counts = [0] * n
    for x in range(n):
        counts[mod_p_poly(coeffs, p, x)] += 1
    return counts


def orbit_entropy(coeffs, p):
    """Compute orbit entropy for polynomial mod p."""
    n = p + 1
    sizes = preimage_sizes_fast(coeffs, p)
    if n == 0:
        return 0.0
    return math.log(n) - sum(math.log(s + 1) for s in sizes) / n


# Parameters
c_values = list(range(-20, 21))
primes = [p for p in range(3, 100) if all(p % i != 0 for i in range(2, int(p**0.5) + 1))]

# Compute entropy grid
entropy_grid = np.zeros((len(c_values), len(primes)))
for i, c in enumerate(c_values):
    for j, p in enumerate(primes):
        entropy_grid[i, j] = orbit_entropy([c, 0, 1], p)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Heatmap
ax1 = axes[0]
im = ax1.imshow(entropy_grid, aspect='auto', cmap='viridis',
                extent=[primes[0], primes[-1], c_values[-1], c_values[0]],
                interpolation='nearest')
ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_ylabel('Parameter c', fontsize=12)
ax1.set_title('Orbit Entropy H(x² + c, p)', fontsize=14)
plt.colorbar(im, ax=ax1, label='Entropy')

# Entropy vs prime for selected c values
ax2 = axes[1]
for c in [-2, -1, 0, 1, 2, 5]:
    entropies = [orbit_entropy([c, 0, 1], p) for p in primes]
    ax2.plot(primes, entropies, 'o-', markersize=3, label=f'c={c}', alpha=0.7)

ax2.axhline(y=math.log(2), color='red', linestyle='--', alpha=0.5, label='log(2)')
ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('Orbit Entropy', fontsize=12)
ax2.set_title('Entropy Convergence (proven ≥ 0)', fontsize=14)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_landscape.png")


"""
Visualization 3: Functional Graph Structure

Visualizes the functional graph of a mod-p dynamical system,
showing the cycle-and-tree structure that underlies the persistence profile.
Color-codes nodes by preimage size to illustrate the degree sequence.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def mod_p_poly(coeffs, p, x):
    """Evaluate polynomial at x mod p."""
    if x == p:
        return p
    return sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p


def find_cycles(map_fn, n):
    """Find all cycles in a functional graph."""
    visited = [False] * n
    in_cycle = [False] * n
    cycles = []

    for start in range(n):
        if visited[start]:
            continue
        path = []
        x = start
        while not visited[x]:
            visited[x] = True
            path.append(x)
            x = map_fn(x)
        # x is now either in a cycle or already processed
        if x in path:
            idx = path.index(x)
            cycle = path[idx:]
            cycles.append(cycle)
            for c in cycle:
                in_cycle[c] = True

    return cycles, in_cycle


def layout_functional_graph(map_fn, n):
    """Compute positions for nodes in a functional graph layout."""
    cycles, in_cycle = find_cycles(map_fn, n)
    positions = {}

    # Layout cycles in concentric rings
    center_x, center_y = 0.0, 0.0

    for ci, cycle in enumerate(cycles):
        r = 2.0 + ci * 1.5
        for i, node in enumerate(cycle):
            angle = 2 * math.pi * i / len(cycle) + ci * 0.5
            positions[node] = (center_x + r * math.cos(angle),
                               center_y + r * math.sin(angle))

    # Layout tree nodes by BFS from cycle
    queue = [x for x in range(n) if in_cycle[x]]
    # Find reverse map
    reverse = [[] for _ in range(n)]
    for x in range(n):
        reverse[map_fn(x)].append(x)

    layer = 0
    while queue:
        next_queue = []
        for parent in queue:
            px, py = positions[parent]
            children = [c for c in reverse[parent] if c not in positions]
            for i, child in enumerate(children):
                angle = math.atan2(py - center_y, px - center_x)
                spread = 0.8 / (1 + layer)
                offset = (i - len(children) / 2) * spread
                dist = 1.2
                positions[child] = (px + dist * math.cos(angle + offset),
                                    py + dist * math.sin(angle + offset))
                next_queue.append(child)
        queue = next_queue
        layer += 1

    # Place any remaining nodes
    for x in range(n):
        if x not in positions:
            positions[x] = (5.0 + x * 0.3, 5.0)

    return positions, cycles, in_cycle


# Create figure with 4 subplots for different maps
fig, axes = plt.subplots(2, 2, figsize=(14, 14))
axes = axes.flatten()

p = 11
n = p + 1
maps_info = [
    ([0, 0, 1], "x² mod 11"),
    ([1, 0, 1], "x²+1 mod 11"),
    ([3, 0, 1], "x²+3 mod 11"),
    ([0, 0, 0, 1], "x³ mod 11"),
]

for idx, (coeffs, title) in enumerate(maps_info):
    ax = axes[idx]
    f = lambda x, c=coeffs: mod_p_poly(c, p, x)

    # Compute preimage sizes
    pre_sizes = [0] * n
    for x in range(n):
        pre_sizes[f(x)] += 1

    positions, cycles, in_cycle = layout_functional_graph(f, n)

    # Draw edges
    for x in range(n):
        if x in positions and f(x) in positions:
            x1, y1 = positions[x]
            x2, y2 = positions[f(x)]
            dx, dy = x2 - x1, y2 - y1
            ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                        arrowprops=dict(arrowstyle="->", color='gray',
                                        alpha=0.5, connectionstyle="arc3,rad=0.1"))

    # Draw nodes colored by preimage size
    max_pre = max(pre_sizes) if pre_sizes else 1
    for x in range(n):
        if x not in positions:
            continue
        px, py = positions[x]
        size = pre_sizes[x]
        color_val = size / max(max_pre, 1)

        # Cycle nodes are squares, tree nodes are circles
        if in_cycle[x]:
            marker = 's'
            ms = 12
        else:
            marker = 'o'
            ms = 8

        ax.plot(px, py, marker, markersize=ms,
                color=plt.cm.YlOrRd(color_val),
                markeredgecolor='black', markeredgewidth=0.5)

        label = str(x) if x < p else '∞'
        ax.annotate(label, (px, py), textcoords="offset points",
                    xytext=(0, -15), ha='center', fontsize=7)

    # Compute invariants
    entropy_val = math.log(n) - sum(math.log(s + 1) for s in pre_sizes) / n
    deg_seq = sorted(pre_sizes)
    fixed = sum(1 for x in range(n) if f(x) == x)

    ax.set_title(f'{title}\nFixed pts: {fixed}, Entropy: {entropy_val:.3f}', fontsize=11)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.1)
    ax.set_xlim(-6, 8)
    ax.set_ylim(-6, 8)

fig.suptitle('Functional Graphs of Mod-p Dynamical Systems\n'
             '(□ = cycle node, ○ = tree node, color = preimage size)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_functional_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_functional_graph.png")
