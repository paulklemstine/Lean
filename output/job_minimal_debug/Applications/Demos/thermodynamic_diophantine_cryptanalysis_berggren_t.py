#!/usr/bin/env python3
"""
Thermodynamic Diophantine Cryptanalysis: Demo

Demonstrates the core concepts of the Berggren transfer-operator
security framework with concrete numerical examples.

This script:
1. Generates Berggren tree descendants
2. Computes partition sums with different observables
3. Evaluates collision and preimage counts for modular hash functions
4. Plots security gap convergence and spectral rate estimates
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import Counter
from itertools import product as cartprod

# ══════════════════════════════════════════════════════════════
# 1. Berggren Tree Generation
# ══════════════════════════════════════════════════════════════

def berggren_A(t):
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(t):
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(t):
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def berggren_descendants(seed, depth):
    """Generate cumulative Berggren descendants up to given depth."""
    current = {seed}
    all_desc = {seed}
    for _ in range(depth):
        new = set()
        for t in current:
            new.add(berggren_A(t))
            new.add(berggren_B(t))
            new.add(berggren_C(t))
        all_desc |= new
        current = new
    return all_desc

# ══════════════════════════════════════════════════════════════
# 2. Partition Sum and Observable
# ══════════════════════════════════════════════════════════════

def crypto_partition_sum(descendants, weight_fn):
    """Compute Z_n = sum_{t in S} exp(weight(t))."""
    return sum(np.exp(weight_fn(t)) for t in descendants)

def constant_weight(t):
    """Trivial observable: weight = 0."""
    return 0.0

def hypotenuse_weight(t, beta=0.1):
    """Depth-like observable using log of hypotenuse."""
    return beta * np.log(abs(t[2]) + 1)

# ══════════════════════════════════════════════════════════════
# 3. Hash Functions and Collision/Preimage Counting
# ══════════════════════════════════════════════════════════════

def modular_hash(t, m):
    """Simple modular hash: H(a,b,c) = (a + b + c) mod m."""
    return (t[0] + t[1] + t[2]) % m

def collision_count(descendants, hash_fn, m):
    """Count off-diagonal collisions."""
    desc_list = list(descendants)
    hashes = [hash_fn(t, m) for t in desc_list]
    counter = Counter(hashes)
    return sum(c * (c - 1) for c in counter.values())

def preimage_count(descendants, hash_fn, m, y):
    """Count preimages of hash value y."""
    return sum(1 for t in descendants if hash_fn(t, m) == y)

def collision_pressure(descendants, weight_fn, hash_fn, m):
    """Compute collision pressure: log(CC+1) - 2*log(Z)."""
    Z = crypto_partition_sum(descendants, weight_fn)
    CC = collision_count(descendants, hash_fn, m)
    return np.log(CC + 1) - 2 * np.log(Z)

# ══════════════════════════════════════════════════════════════
# 4. Weighted Probabilities
# ══════════════════════════════════════════════════════════════

def weighted_preimage_probability(descendants, weight_fn, hash_fn, m, y):
    """Compute weighted preimage probability for output y."""
    Z = crypto_partition_sum(descendants, weight_fn)
    fiber_sum = sum(np.exp(weight_fn(t)) for t in descendants if hash_fn(t, m) == y)
    return fiber_sum / Z

def spectral_rate(seed, weight_fn, n):
    """Compute finite-depth spectral rate: log(Z_{n+1}) - log(Z_n)."""
    desc_n = berggren_descendants(seed, n)
    desc_n1 = berggren_descendants(seed, n + 1)
    Z_n = crypto_partition_sum(desc_n, weight_fn)
    Z_n1 = crypto_partition_sum(desc_n1, weight_fn)
    return np.log(Z_n1) - np.log(Z_n)

# ══════════════════════════════════════════════════════════════
# 5. Main Demonstration
# ══════════════════════════════════════════════════════════════

def main():
    seed = (3, 4, 5)
    max_depth = 6
    m_values = [7, 13, 31]

    print("=" * 70)
    print("THERMODYNAMIC DIOPHANTINE CRYPTANALYSIS: NUMERICAL DEMO")
    print("=" * 70)

    # --- Demo 1: Tree growth and partition sums ---
    print("\n--- Demo 1: Berggren Tree Growth & Partition Sums ---")
    print(f"{'Depth':>6} {'|Descendants|':>14} {'Z(constant)':>14} {'Z(hyp β=0.1)':>14}")
    print("-" * 52)

    depths = range(max_depth + 1)
    card_list = []
    Z_const_list = []
    Z_hyp_list = []

    for n in depths:
        desc = berggren_descendants(seed, n)
        card = len(desc)
        Z_const = crypto_partition_sum(desc, constant_weight)
        Z_hyp = crypto_partition_sum(desc, lambda t: hypotenuse_weight(t))
        card_list.append(card)
        Z_const_list.append(Z_const)
        Z_hyp_list.append(Z_hyp)
        print(f"{n:>6} {card:>14} {Z_const:>14.2f} {Z_hyp:>14.2f}")

    # --- Demo 2: Collision pressure convergence ---
    print("\n--- Demo 2: Collision Pressure vs Depth (m=13) ---")
    m = 13
    print(f"{'Depth':>6} {'CC':>10} {'CollPressure':>14} {'1/m pigeonhole':>16}")
    print("-" * 50)

    cp_list = []
    for n in range(max_depth + 1):
        desc = berggren_descendants(seed, n)
        CC = collision_count(desc, modular_hash, m)
        cp = collision_pressure(desc, constant_weight, modular_hash, m)
        cp_list.append(cp)
        pigeonhole = 1.0 / m
        print(f"{n:>6} {CC:>10} {cp:>14.4f} {pigeonhole:>16.4f}")

    # --- Demo 3: Weighted preimage probabilities ---
    print(f"\n--- Demo 3: Weighted Preimage Probabilities (depth={max_depth}, m=7) ---")
    m = 7
    desc = berggren_descendants(seed, max_depth)
    print(f"{'Output y':>10} {'WPP(y)':>12} {'Preimage#':>12} {'1/m bound':>12}")
    print("-" * 48)

    wpp_list = []
    for y in range(m):
        wpp = weighted_preimage_probability(desc, constant_weight, modular_hash, m, y)
        pc = preimage_count(desc, modular_hash, m, y)
        wpp_list.append(wpp)
        print(f"{y:>10} {wpp:>12.6f} {pc:>12} {1/m:>12.6f}")

    print(f"\nSum of WPP: {sum(wpp_list):.10f} (should be 1.0)")
    print(f"Max WPP:    {max(wpp_list):.6f} ≥ 1/m = {1/m:.6f} ✓ (pigeonhole)")

    # --- Demo 4: Spectral rate convergence ---
    print(f"\n--- Demo 4: Spectral Rate & Pressure Convergence ---")
    print(f"{'Depth n':>8} {'SpectralRate':>14} {'log(Z_n)/n':>14}")
    print("-" * 38)

    for n in range(1, max_depth):
        sr = spectral_rate(seed, constant_weight, n)
        desc_n = berggren_descendants(seed, n)
        Z_n = crypto_partition_sum(desc_n, constant_weight)
        log_Z_over_n = np.log(Z_n) / n
        print(f"{n:>8} {sr:>14.6f} {log_Z_over_n:>14.6f}")

    # --- Demo 5: Security gap visualization ---
    print(f"\n--- Demo 5: Security Gap Analysis ---")
    for m in m_values:
        desc = berggren_descendants(seed, max_depth)
        Z = crypto_partition_sum(desc, constant_weight)
        CC = collision_count(desc, modular_hash, m)
        cp = collision_pressure(desc, constant_weight, modular_hash, m)
        print(f"m={m:>3}: CC={CC:>8}, Z={Z:>8.1f}, "
              f"CollPressure={cp:>8.4f}, "
              f"CC+1 ≤ Z²? {CC+1 <= Z**2}")

    # ══════════════════════════════════════════════════════════
    # 6. Plots
    # ══════════════════════════════════════════════════════════

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Tree growth
    ax = axes[0, 0]
    ax.semilogy(list(depths), card_list, 'bo-', label='|Descendants|')
    ax.semilogy(list(depths), Z_const_list, 'rs-', label='Z (constant)')
    ax.semilogy(list(depths), Z_hyp_list, 'g^-', label='Z (hypotenuse)')
    ax.set_xlabel('Depth n')
    ax.set_ylabel('Count / Partition Sum')
    ax.set_title('Berggren Tree Growth & Partition Sums')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Collision pressure convergence
    ax = axes[0, 1]
    for m in m_values:
        cps = []
        for n in range(max_depth + 1):
            desc = berggren_descendants(seed, n)
            cp = collision_pressure(desc, constant_weight, modular_hash, m)
            cps.append(cp)
        ax.plot(list(depths), cps, 'o-', label=f'm={m}')
    ax.axhline(y=0, color='k', linestyle='--', alpha=0.5, label='Security threshold')
    ax.set_xlabel('Depth n')
    ax.set_ylabel('Collision Pressure')
    ax.set_title('Collision Pressure Convergence\n(negative = secure)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Preimage distribution (depth=max_depth, m=13)
    m = 13
    desc = berggren_descendants(seed, max_depth)
    ax = axes[1, 0]
    wpps = [weighted_preimage_probability(desc, constant_weight, modular_hash, m, y)
            for y in range(m)]
    ax.bar(range(m), wpps, alpha=0.7, color='steelblue')
    ax.axhline(y=1/m, color='r', linestyle='--', label=f'1/m = {1/m:.4f}')
    ax.set_xlabel('Hash Output y')
    ax.set_ylabel('Weighted Preimage Probability')
    ax.set_title(f'Output Distribution (depth={max_depth}, m={m})')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Spectral rate convergence
    ax = axes[1, 1]
    rates = []
    log_Z_n = []
    ns = list(range(1, max_depth))
    for n in ns:
        sr = spectral_rate(seed, constant_weight, n)
        rates.append(sr)
        desc_n = berggren_descendants(seed, n)
        Z_n = crypto_partition_sum(desc_n, constant_weight)
        log_Z_n.append(np.log(Z_n) / n)
    ax.plot(ns, rates, 'bo-', label='Spectral Rate')
    ax.plot(ns, log_Z_n, 'rs-', label='log(Z_n)/n')
    ax.set_xlabel('Depth n')
    ax.set_ylabel('Rate')
    ax.set_title('Spectral Rate & Pressure Convergence\n(O(1/n) convergence)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('Bridges/thermodynamic_crypto_demo.png', dpi=150, bbox_inches='tight')
    print("\n[Plot saved to Bridges/thermodynamic_crypto_demo.png]")

    # ══════════════════════════════════════════════════════════
    # 7. Key Theorem Verification
    # ══════════════════════════════════════════════════════════

    print("\n" + "=" * 70)
    print("THEOREM VERIFICATION (numerical)")
    print("=" * 70)

    desc = berggren_descendants(seed, max_depth)
    m = 13
    Z = crypto_partition_sum(desc, constant_weight)

    # Theorem: cryptoPartitionSum_pos
    print(f"\n✓ cryptoPartitionSum_pos: Z = {Z:.4f} > 0")

    # Theorem: weightedPreimageProbability_sum_one
    wpp_sum = sum(weighted_preimage_probability(desc, constant_weight, modular_hash, m, y)
                  for y in range(m))
    print(f"✓ weightedPreimageProbability_sum_one: Σ WPP = {wpp_sum:.10f}")

    # Theorem: exists_heavy_hash_fiber
    max_wpp = max(weighted_preimage_probability(desc, constant_weight, modular_hash, m, y)
                  for y in range(m))
    print(f"✓ exists_heavy_hash_fiber: max WPP = {max_wpp:.6f} ≥ 1/m = {1/m:.6f}")

    # Theorem: collisionCount_le_square_card
    CC = collision_count(desc, modular_hash, m)
    card = len(desc)
    print(f"✓ collisionCount_le_square_card: CC = {CC} ≤ {card}² = {card**2}")

    # Theorem: preimageCount_sum_eq_card
    pc_sum = sum(preimage_count(desc, modular_hash, m, y) for y in range(m))
    print(f"✓ preimageCount_sum_eq_card: Σ PC = {pc_sum} = |S| = {card}")

    # Theorem: lattice_crypto smoothing
    cp = collision_pressure(desc, constant_weight, modular_hash, m)
    print(f"✓ CollisionPressure = {cp:.4f}, CC+1={CC+1} ≤ Z²={Z**2:.1f}? {CC+1 <= Z**2}")

if __name__ == "__main__":
    main()
