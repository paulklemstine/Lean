#!/usr/bin/env python3
"""
Demo: CSIDH/CSI-FiSh Isogeny-Based Cryptography

Demonstrates the core mathematical concepts:
1. Group action on a finite set (modeling class group action)
2. CSIDH key exchange
3. CSI-FiSh identification scheme
4. Random self-reducibility of GAIP
5. Cayley diameter conjecture verification
"""

import random
from typing import List, Tuple


def mod_action(g: int, x: int, n: int) -> int:
    """Group action of Z/nZ on itself by addition (models class group action)."""
    return (x + g) % n


def csidh_key_exchange(n: int, base: int, alice_secret: int, bob_secret: int):
    """Simulate CSIDH key exchange using Z/nZ action."""
    alice_public = mod_action(alice_secret, base, n)
    bob_public = mod_action(bob_secret, base, n)

    alice_shared = mod_action(alice_secret, bob_public, n)
    bob_shared = mod_action(bob_secret, alice_public, n)

    return {
        "alice_public": alice_public,
        "bob_public": bob_public,
        "alice_shared": alice_shared,
        "bob_shared": bob_shared,
        "agreement": alice_shared == bob_shared,
    }


def csifish_identification(n: int, base: int, secret: int, challenge: bool):
    """Simulate CSI-FiSh identification scheme."""
    pk = mod_action(secret, base, n)
    r = random.randint(0, n - 1)  # commitment randomness
    commitment = mod_action(r, base, n)

    if challenge:
        response = (r - secret) % n  # z = r * s^{-1} in additive notation
    else:
        response = r

    # Verification
    if challenge:
        check = mod_action(response, pk, n)
    else:
        check = mod_action(response, base, n)

    return {
        "pk": pk,
        "commitment": commitment,
        "challenge": challenge,
        "response": response,
        "verification": check == commitment,
    }


def special_soundness_extraction(n: int, base: int, z0: int, z1: int, pk: int):
    """Extract secret from two transcripts (special soundness)."""
    extracted = (z0 - z1) % n
    check = mod_action(extracted, base, n)
    return {"extracted_secret": extracted, "maps_to_pk": check == pk}


def rerandomize_gaip(n: int, base: int, target: int, r: int):
    """Rerandomize a GAIP instance."""
    new_base = mod_action(r, base, n)
    new_target = mod_action(r, target, n)
    # The connector (secret) is preserved
    original_secret = (target - base) % n
    new_secret = (new_target - new_base) % n
    return {
        "original_base": base,
        "original_target": target,
        "new_base": new_base,
        "new_target": new_target,
        "original_secret": original_secret,
        "new_secret": new_secret,
        "preserved": original_secret == new_secret,
    }


def verify_cayley_diameter(n: int) -> Tuple[bool, int]:
    """Verify Cayley diameter conjecture for Z/nZ with generators {+1, -1}."""
    expected_diameter = n // 2
    max_dist = 0
    for a in range(n):
        # Distance = min(a, n-a) = distance to 0 using ±1
        dist = min(a, n - a)
        max_dist = max(max_dist, dist)
    return max_dist <= expected_diameter, max_dist


def key_space_analysis(num_primes: int, bound: int):
    """Analyze CSIDH key space size."""
    key_space = (2 * bound + 1) ** num_primes
    security_bits = key_space.bit_length() - 1
    return {
        "num_primes": num_primes,
        "bound": bound,
        "key_space_size": key_space,
        "security_bits": security_bits,
    }


if __name__ == "__main__":
    print("=" * 60)
    print("CSIDH/CSI-FiSh Isogeny Cryptography Demo")
    print("=" * 60)

    # 1. CSIDH Key Exchange
    print("\n--- CSIDH Key Exchange (Z/101Z) ---")
    n = 101
    result = csidh_key_exchange(n, base=0, alice_secret=42, bob_secret=73)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # 2. CSI-FiSh Identification
    print("\n--- CSI-FiSh Identification ---")
    for challenge in [False, True]:
        result = csifish_identification(n, base=0, secret=42, challenge=challenge)
        print(f"  Challenge={challenge}: verified={result['verification']}")

    # 3. Special Soundness
    print("\n--- Special Soundness Extraction ---")
    secret = 42
    r = random.randint(0, n - 1)
    pk = mod_action(secret, 0, n)
    z0 = r  # response to challenge 0
    z1 = (r - secret) % n  # response to challenge 1
    result = special_soundness_extraction(n, 0, z0, z1, pk)
    print(f"  True secret: {secret}")
    print(f"  Extracted: {result['extracted_secret']}")
    print(f"  Correct: {result['maps_to_pk']}")

    # 4. Random Self-Reducibility
    print("\n--- Random Self-Reducibility ---")
    for r in [7, 23, 56, 89]:
        result = rerandomize_gaip(n, base=0, target=42, r=r)
        print(f"  r={r}: preserved={result['preserved']} "
              f"(secret={result['original_secret']}→{result['new_secret']})")

    # 5. Cayley Diameter Conjecture
    print("\n--- Cayley Diameter Conjecture Verification ---")
    for test_n in [5, 7, 11, 13, 17, 19, 23, 29, 37, 41, 97, 101]:
        valid, diameter = verify_cayley_diameter(test_n)
        expected = test_n // 2
        status = "✓" if valid else "✗"
        print(f"  n={test_n:3d}: diameter={diameter:2d}, "
              f"expected≤{expected:2d} {status}")

    # 6. Key Space Analysis
    print("\n--- CSIDH Key Space Analysis ---")
    configs = [(74, 5), (74, 10), (74, 20), (130, 10)]
    for np, b in configs:
        result = key_space_analysis(np, b)
        print(f"  n={np}, B={b}: |key space|≈2^{result['security_bits']} "
              f"({result['security_bits']} security bits)")

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Cayley Graph of Z/nZ with generators {+1, -1}

Generates a circular Cayley graph showing the isogeny graph structure,
highlighting the diameter and random walk distribution.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def cayley_graph_visualization(n: int, save_path: str = "cayley_graph.png"):
    """Draw the Cayley graph of Z/nZ with generators {+1, -1}."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Cayley graph
    ax1 = axes[0]
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    x = np.cos(angles)
    y = np.sin(angles)

    # Draw edges (each node connects to +1 and -1)
    for i in range(n):
        j = (i + 1) % n
        ax1.plot([x[i], x[j]], [y[i], y[j]], 'b-', alpha=0.3, linewidth=0.8)

    # Color nodes by distance from 0
    distances = [min(i, n - i) for i in range(n)]
    scatter = ax1.scatter(x, y, c=distances, cmap='viridis', s=80, zorder=5,
                          edgecolors='black', linewidth=0.5)
    plt.colorbar(scatter, ax=ax1, label='Distance from base (BFS)')

    # Mark base point
    ax1.scatter([x[0]], [y[0]], c='red', s=200, zorder=10, marker='*',
                edgecolors='black', linewidth=1)
    ax1.set_title(f'Cayley Graph of Z/{n}Z\n(generators {{+1, -1}})', fontsize=12)
    ax1.set_aspect('equal')
    ax1.axis('off')
    ax1.annotate(f'Diameter = {max(distances)} = ⌊{n}/2⌋',
                 xy=(0, -1.3), fontsize=10, ha='center',
                 bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    # Right: Random walk distribution
    ax2 = axes[1]
    num_walks = 50000
    walk_lengths = [n, n**2 // 4, n**2 // 2, n**2]

    for t in walk_lengths:
        endpoints = []
        for _ in range(num_walks):
            pos = 0
            for _ in range(t):
                pos = (pos + np.random.choice([-1, 1])) % n
            endpoints.append(pos)

        counts = Counter(endpoints)
        frequencies = [counts.get(i, 0) / num_walks for i in range(n)]
        ax2.plot(range(n), frequencies, label=f't={t}', alpha=0.7)

    ax2.axhline(y=1/n, color='red', linestyle='--', alpha=0.5, label=f'Uniform (1/{n})')
    ax2.set_xlabel('Position in Z/nZ')
    ax2.set_ylabel('Frequency')
    ax2.set_title(f'Random Walk Distribution (n={n})\nafter t steps from 0', fontsize=12)
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {save_path}")


def key_space_visualization(save_path: str = "key_space.png"):
    """Visualize CSIDH key space growth."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Key space vs number of primes
    bounds = [5, 10, 20]
    n_range = range(1, 150)
    for B in bounds:
        sizes = [(2 * B + 1) ** n for n in n_range]
        bits = [s.bit_length() for s in sizes]
        ax1.plot(n_range, bits, label=f'B={B}')

    ax1.axhline(y=128, color='red', linestyle='--', alpha=0.5, label='128-bit security')
    ax1.axhline(y=256, color='orange', linestyle='--', alpha=0.5, label='256-bit security')
    ax1.set_xlabel('Number of primes (n)')
    ax1.set_ylabel('Security bits (log₂ key space)')
    ax1.set_title('CSIDH Key Space Growth')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0, 500)

    # Right: Soundness error vs repetitions
    t_range = range(1, 257)
    errors = [1.0 / (2 ** t) for t in t_range]
    ax2.semilogy(t_range, errors, 'b-')
    ax2.axhline(y=2**(-128), color='red', linestyle='--', alpha=0.5, label='2⁻¹²⁸')
    ax2.set_xlabel('Number of repetitions (t)')
    ax2.set_ylabel('Soundness error (2⁻ᵗ)')
    ax2.set_title('CSI-FiSh Soundness Error')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {save_path}")


if __name__ == "__main__":
    cayley_graph_visualization(23, "cayley_graph_23.png")
    cayley_graph_visualization(41, "cayley_graph_41.png")
    key_space_visualization("key_space.png")
    print("All visualizations generated.")
