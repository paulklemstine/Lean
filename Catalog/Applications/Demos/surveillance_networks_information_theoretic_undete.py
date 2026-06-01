#!/usr/bin/env python3
"""
Surveillance Networks: Privacy-Utility Tradeoff Demo

Demonstrates the key results from the formal theory:
1. Privacy-Surveillance Mutual Exclusion
2. Packing bounds on channel image size
3. Fiber product bounds
4. Quantitative privacy defect
"""

import itertools
from typing import Dict, List, Tuple

def generate_all_configs(n: int) -> List[Tuple[Tuple[bool, ...], ...]]:
    """Generate all 2^(n^2) network configurations on n nodes."""
    edges = list(itertools.product([False, True], repeat=n*n))
    configs = []
    for e in edges:
        adj = tuple(tuple(e[i*n + j] for j in range(n)) for i in range(n))
        configs.append(adj)
    return configs

def edge_distortion(g1, g2) -> int:
    """Hamming distance between two adjacency matrices."""
    n = len(g1)
    return sum(1 for i in range(n) for j in range(n) if g1[i][j] != g2[i][j])

def channel_image_size(encode, configs) -> int:
    """Number of distinct codes in the channel's image."""
    return len(set(encode(g) for g in configs))

def is_trivial(encode, configs) -> bool:
    """Check if channel maps all configs to the same code."""
    return len(set(encode(g) for g in configs)) <= 1

def is_injective(encode, configs) -> bool:
    """Check if channel is injective."""
    return channel_image_size(encode, configs) == len(configs)

def privacy_defect(encode, configs) -> float:
    """Compute privacy defect: 0 = max privacy, 1 = no privacy."""
    N = len(configs)
    if N <= 1:
        return 0.0
    return (channel_image_size(encode, configs) - 1) / (N - 1)

def max_fiber_size(encode, configs) -> int:
    """Largest preimage of any code value."""
    fibers: Dict = {}
    for g in configs:
        c = encode(g)
        fibers[c] = fibers.get(c, 0) + 1
    return max(fibers.values()) if fibers else 0

# --- Demo 1: Privacy-Surveillance Exclusion ---
print("=" * 60)
print("Demo 1: Privacy-Surveillance Mutual Exclusion")
print("=" * 60)

for n in [1, 2]:
    configs = generate_all_configs(n)
    N = len(configs)
    print(f"\nn = {n}: {N} configurations (2^{n*n})")

    identity = lambda g: g
    print(f"  Identity channel: image_size = {channel_image_size(identity, configs)}, "
          f"injective = {is_injective(identity, configs)}, "
          f"trivial = {is_trivial(identity, configs)}")

    constant = lambda g: 0
    print(f"  Constant channel: image_size = {channel_image_size(constant, configs)}, "
          f"injective = {is_injective(constant, configs)}, "
          f"trivial = {is_trivial(constant, configs)}")

# --- Demo 2: Packing Bound ---
print("\n" + "=" * 60)
print("Demo 2: Packing Bound")
print("=" * 60)

n = 2
configs = generate_all_configs(n)

D = 1
packing = [configs[0]]
for g in configs[1:]:
    if all(edge_distortion(g, p) > 2 * D for p in packing):
        packing.append(g)

print(f"n = {n}, D = {D}")
print(f"Packing set size (separation > {2*D}): {len(packing)}")
print(f"→ Any channel with distortion ≤ {D} needs ≥ {len(packing)} codes")

# --- Demo 3: Privacy Defect Curve ---
print("\n" + "=" * 60)
print("Demo 3: Privacy Defect vs Channel Granularity")
print("=" * 60)

n = 2
configs = generate_all_configs(n)

def make_hash_channel(n_val, mod):
    def encode(g):
        return sum(g[i][j] * (2 ** (i * n_val + j)) for i in range(n_val) for j in range(n_val)) % mod
    return encode

print(f"n = {n}, total configs = {len(configs)}")
print(f"{'Mod':>6} {'Image Size':>12} {'Privacy Defect':>16} {'Max Fiber':>10}")
for mod in [1, 2, 4, 8, 16]:
    ch = make_hash_channel(n, mod)
    img = channel_image_size(ch, configs)
    pd = privacy_defect(ch, configs)
    mf = max_fiber_size(ch, configs)
    print(f"{mod:>6} {img:>12} {pd:>16.4f} {mf:>10}")

# --- Demo 4: Fiber Product Bound ---
print("\n" + "=" * 60)
print("Demo 4: Fiber Product Bound (Pigeonhole)")
print("=" * 60)

N = len(configs)
for mod in [1, 2, 4, 8, 16]:
    ch = make_hash_channel(n, mod)
    img = channel_image_size(ch, configs)
    mf = max_fiber_size(ch, configs)
    product = img * mf
    status = "✓" if product >= N else "✗"
    print(f"  mod={mod:>2}: image_size={img:>2} × max_fiber={mf:>2} = {product:>3} ≥ {N} {status}")

# --- Demo 5: Trivial Channel Distortion ---
print("\n" + "=" * 60)
print("Demo 5: Trivial Channel Must Incur Distortion")
print("=" * 60)

default_config = configs[0]
distortions = [edge_distortion(g, default_config) for g in configs]
max_dist = max(distortions)
avg_dist = sum(distortions) / len(distortions)
nonzero = sum(1 for d in distortions if d > 0)

print(f"Constant channel (reconstruct as all-zeros):")
print(f"  Max distortion: {max_dist}")
print(f"  Average distortion: {avg_dist:.2f}")
print(f"  Configs with nonzero distortion: {nonzero}/{len(configs)}")

print("\nAll demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Privacy-Utility Tradeoff Curve

Generates a plot showing the fundamental tradeoff between privacy
(measured by privacy defect) and surveillance accuracy (measured by
worst-case distortion) for finite network surveillance channels.
"""

import itertools
import random
import math
from typing import List, Tuple, Dict, Callable

# --- Inline utility functions ---

def generate_all_configs(n: int) -> list:
    configs = []
    for bits in itertools.product([False, True], repeat=n * n):
        adj = tuple(tuple(bits[i * n + j] for j in range(n)) for i in range(n))
        configs.append(adj)
    return configs

def edge_distortion(g1, g2) -> int:
    n = len(g1)
    return sum(1 for i in range(n) for j in range(n) if g1[i][j] != g2[i][j])

def channel_image_size(encode, configs) -> int:
    return len(set(encode(g) for g in configs))

def privacy_defect(encode, configs) -> float:
    N = len(configs)
    if N <= 1:
        return 0.0
    return (channel_image_size(encode, configs) - 1) / (N - 1)

def optimal_reconstruction(encode, configs):
    fibers: Dict = {}
    for g in configs:
        c = encode(g)
        if c not in fibers:
            fibers[c] = []
        fibers[c].append(g)
    reconstruction = {}
    for code, fiber in fibers.items():
        best_config = None
        best_max_dist = float('inf')
        for candidate in fiber:
            max_dist = max(edge_distortion(candidate, g) for g in fiber)
            if max_dist < best_max_dist:
                best_max_dist = max_dist
                best_config = candidate
        reconstruction[code] = best_config
    default = configs[0]
    return lambda c: reconstruction.get(c, default)

def worst_case_distortion(encode, decode, configs) -> int:
    return max(edge_distortion(g, decode(encode(g))) for g in configs)

# --- Main visualization ---

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    n = 2
    configs = generate_all_configs(n)
    N = len(configs)

    random.seed(42)

    # Sample many random channels
    points = []
    for trial in range(500):
        num_codes = random.randint(1, N)
        mapping = {g: random.randint(0, num_codes - 1) for g in configs}
        encode = lambda g, m=mapping: m[g]
        decode = optimal_reconstruction(encode, configs)
        pd = privacy_defect(encode, configs)
        wcd = worst_case_distortion(encode, decode, configs)
        points.append((pd, wcd))

    # Add extremes
    # Trivial channel
    encode_triv = lambda g: 0
    decode_triv = optimal_reconstruction(encode_triv, configs)
    points.append((privacy_defect(encode_triv, configs),
                    worst_case_distortion(encode_triv, decode_triv, configs)))

    # Identity channel
    id_map = {g: i for i, g in enumerate(configs)}
    encode_id = lambda g, m=id_map: m[g]
    decode_id = optimal_reconstruction(encode_id, configs)
    points.append((privacy_defect(encode_id, configs),
                    worst_case_distortion(encode_id, decode_id, configs)))

    pds = [p[0] for p in points]
    wcds = [p[1] for p in points]

    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    ax.scatter(pds, wcds, alpha=0.4, s=20, c='steelblue', label='Random channels')

    # Mark extremes
    ax.scatter([0], [wcds[-2]], s=200, c='red', marker='*', zorder=5,
               label='Trivial (max privacy)')
    ax.scatter([1], [0], s=200, c='green', marker='*', zorder=5,
               label='Identity (max surveillance)')

    # Forbidden region
    ax.axhline(y=0, color='green', linestyle='--', alpha=0.3, label='Zero distortion line')
    ax.axvline(x=0, color='red', linestyle='--', alpha=0.3, label='Zero defect line')

    ax.fill_between([-0.05, 0.02], -0.5, -0.1, alpha=0.15, color='purple')
    ax.text(0.01, -0.3, 'Forbidden\nRegion', fontsize=10, ha='center',
            color='purple', fontweight='bold')

    ax.set_xlabel('Privacy Defect (0 = private, 1 = exposed)', fontsize=13)
    ax.set_ylabel('Worst-Case Distortion (0 = perfect surveillance)', fontsize=13)
    ax.set_title(f'Privacy-Utility Tradeoff for {n}-Node Networks\n'
                 f'({N} configurations, Theorem 1: corners mutually exclusive)',
                 fontsize=14)
    ax.legend(loc='upper right', fontsize=10)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.5, max(wcds) + 0.5)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('privacy_utility_tradeoff.png', dpi=150, bbox_inches='tight')
    print("Saved: privacy_utility_tradeoff.png")

except ImportError:
    print("matplotlib not available; skipping visualization")
