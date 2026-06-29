#!/usr/bin/env python3
"""
Isogeny-Based Cryptography: Demonstration

Numerical examples illustrating the algebraic foundations of CSIDH,
CSI-FiSh, and the vectorization problem.
"""

from algorithms import (
    CyclicGroupAction, CSIDHParams, csidh_keygen, csidh_shared_secret,
    csifish_prove, csifish_extract, solve_vectorization,
    ga_commit, ga_extract_message, verify_cayley_diameter_conjecture,
    csidh_keyspace_size, challenge_space_size, cayley_diameter_bfs
)


def demo_csidh():
    """Demonstrate CSIDH key exchange."""
    print("=" * 60)
    print("DEMO 1: CSIDH Key Exchange (ℤ/101ℤ)")
    print("=" * 60)

    n = 101
    action = CyclicGroupAction(n)
    base = 0
    params = CSIDHParams(action=action, base_point=base)

    # Alice and Bob choose secrets
    alice_secret = 37
    bob_secret = 53

    alice_kp = csidh_keygen(params, alice_secret)
    bob_kp = csidh_keygen(params, bob_secret)

    print(f"  Group: ℤ/{n}ℤ,  Base point: {base}")
    print(f"  Alice: secret={alice_secret}, public={alice_kp.public}")
    print(f"  Bob:   secret={bob_secret}, public={bob_kp.public}")

    # Shared secret computation
    alice_shared = csidh_shared_secret(params, alice_secret, bob_kp.public)
    bob_shared = csidh_shared_secret(params, bob_secret, alice_kp.public)

    print(f"  Alice's shared secret: {alice_shared}")
    print(f"  Bob's shared secret:   {bob_shared}")
    print(f"  Agreement: {alice_shared == bob_shared} ✓")
    print(f"  (Expected: ({alice_secret} + {bob_secret}) mod {n} = {(alice_secret + bob_secret) % n})")
    print()


def demo_csifish():
    """Demonstrate CSI-FiSh identification and extraction."""
    print("=" * 60)
    print("DEMO 2: CSI-FiSh Special Soundness")
    print("=" * 60)

    n = 997
    action = CyclicGroupAction(n)
    base = 0
    params = CSIDHParams(action=action, base_point=base)

    secret = 421
    pk = action.act(secret, base)
    print(f"  Group: ℤ/{n}ℤ,  Secret: {secret},  Public key: {pk}")

    # Honest prover generates two transcripts with same randomness
    randomness = 789

    t0 = csifish_prove(params, secret, challenge=False, randomness=randomness)
    t1 = csifish_prove(params, secret, challenge=True, randomness=randomness)

    print(f"  Commitment R = {t0.commitment}")
    print(f"  Transcript 0 (c=0): z₀ = {t0.response}, verified={t0.verify(params, pk)}")
    print(f"  Transcript 1 (c=1): z₁ = {t1.response}, verified={t1.verify(params, pk)}")

    # Extract secret from the two transcripts
    extracted = csifish_extract(params, t0, t1)
    print(f"  Extracted secret: {extracted}")
    print(f"  Matches original: {extracted == secret} ✓")
    print()


def demo_vectorization():
    """Demonstrate the vectorization problem and GAIP reduction."""
    print("=" * 60)
    print("DEMO 3: Vectorization Problem (GAIP Reduction)")
    print("=" * 60)

    n = 1009
    action = CyclicGroupAction(n)
    base = 0
    params = CSIDHParams(action=action, base_point=base)

    a, b = 317, 541
    x1 = action.act(a, base)  # a · x₀
    x2 = action.act(b, base)  # b · x₀
    expected = action.act(action.multiply(a, b), base)  # (a·b) · x₀

    result = solve_vectorization(params, x1, x2)

    print(f"  Group: ℤ/{n}ℤ")
    print(f"  a = {a}, b = {b}")
    print(f"  x₁ = a·x₀ = {x1}, x₂ = b·x₀ = {x2}")
    print(f"  Vectorization result: (a·b)·x₀ = {result}")
    print(f"  Expected:             (a·b)·x₀ = {expected}")
    print(f"  Correct: {result == expected} ✓")
    print()


def demo_commitment():
    """Demonstrate the group-action commitment scheme."""
    print("=" * 60)
    print("DEMO 4: Group-Action Commitment Scheme")
    print("=" * 60)

    n = 509
    action = CyclicGroupAction(n)
    base = 0
    params = CSIDHParams(action=action, base_point=base)

    message = 42
    randomness = 173

    commitment = ga_commit(params, message, randomness)
    extracted = ga_extract_message(params, commitment)

    print(f"  Group: ℤ/{n}ℤ")
    print(f"  Message: {message}, Randomness: {randomness}")
    print(f"  Commitment: ({commitment.com1}, {commitment.com2})")
    print(f"  Extracted message: {extracted}")
    print(f"  Binding verified: {extracted == message} ✓")
    print()


def demo_cayley_diameter():
    """Verify the Cayley diameter conjecture."""
    print("=" * 60)
    print("DEMO 5: Cayley Diameter Conjecture")
    print("=" * 60)

    test_values = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 97, 101]
    results = verify_cayley_diameter_conjecture(test_values)

    print(f"  {'n':>5}  {'diameter':>8}  {'⌊n/2⌋':>6}  {'match':>5}")
    print(f"  {'─'*5}  {'─'*8}  {'─'*6}  {'─'*5}")
    for n, diameter, expected, matches in results:
        status = "✓" if matches else "✗"
        print(f"  {n:>5}  {diameter:>8}  {expected:>6}  {status:>5}")

    all_match = all(m for _, _, _, m in results)
    print(f"\n  Conjecture holds for all tested values: {all_match}")
    print()


def demo_security_parameters():
    """Show security parameter computations."""
    print("=" * 60)
    print("DEMO 6: Security Parameters")
    print("=" * 60)

    print("\n  CSIDH Key Space Size (2B+1)^n:")
    for n_primes in [37, 74]:
        for bound in [5, 10]:
            size = csidh_keyspace_size(n_primes, bound)
            bits = size.bit_length()
            print(f"    n={n_primes:>3}, B={bound:>3}: |K| ≈ 2^{bits}")

    print("\n  CSI-FiSh Challenge Space 2^n:")
    for rounds in [128, 256, 512]:
        size = challenge_space_size(rounds)
        print(f"    n={rounds:>3}: |C| = 2^{rounds}, soundness error = 2^{-rounds}")

    print()


def demo_connector_algebra():
    """Demonstrate connector algebra properties."""
    print("=" * 60)
    print("DEMO 7: Connector Algebra (Cocycle Properties)")
    print("=" * 60)

    n = 113
    action = CyclicGroupAction(n)

    # Pick three random points
    x, y, z = 17, 53, 89

    conn_xy = action.connector(x, y)
    conn_yz = action.connector(y, z)
    conn_zx = action.connector(z, x)

    triangle = (conn_xy + conn_yz + conn_zx) % n
    print(f"  Group: ℤ/{n}ℤ,  x={x}, y={y}, z={z}")
    print(f"  conn(x,y) = {conn_xy}")
    print(f"  conn(y,z) = {conn_yz}")
    print(f"  conn(z,x) = {conn_zx}")
    print(f"  Triangle: conn(x,y) + conn(y,z) + conn(z,x) = {triangle} (mod {n})")
    print(f"  Triangle identity holds: {triangle == 0} ✓")

    # Translation invariance
    g = 42
    gx = action.act(g, x)
    gy = action.act(g, y)
    conn_gx_gy = action.connector(gx, gy)
    print(f"\n  Translation invariance (g={g}):")
    print(f"  conn(g·x, g·y) = conn({gx}, {gy}) = {conn_gx_gy}")
    print(f"  conn(x, y) = {conn_xy}")
    print(f"  Equal: {conn_gx_gy == conn_xy} ✓")

    # Intermediate connector
    a, b = 31, 47
    ax = action.act(a, 0)
    abx = action.act(action.multiply(a, b), 0)
    conn_inter = action.connector(ax, abx)
    print(f"\n  Intermediate connector (a={a}, b={b}):")
    print(f"  conn(a·x₀, (a·b)·x₀) = conn({ax}, {abx}) = {conn_inter}")
    print(f"  Expected: b = {b}")
    print(f"  Correct: {conn_inter == b} ✓")
    print()


if __name__ == "__main__":
    demo_csidh()
    demo_csifish()
    demo_vectorization()
    demo_commitment()
    demo_cayley_diameter()
    demo_security_parameters()
    demo_connector_algebra()

    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""
Visualization: Cayley Graph Diameter and Isogeny Graph Structure

Standalone visualization script using matplotlib.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, Tuple, Dict


def cayley_diameter_bfs(n: int) -> int:
    """Compute Cayley graph diameter for ℤ/nℤ with generators {1, -1}."""
    if n <= 1:
        return 0
    visited = {0: 0}
    queue = [0]
    max_dist = 0
    while queue:
        current = queue.pop(0)
        for delta in [1, n - 1]:
            neighbor = (current + delta) % n
            if neighbor not in visited:
                visited[neighbor] = visited[current] + 1
                max_dist = max(max_dist, visited[neighbor])
                queue.append(neighbor)
    return max_dist


def bfs_distance_distribution(n: int) -> Dict[int, int]:
    """Compute the distribution of distances from 0 in ℤ/nℤ."""
    visited = {0: 0}
    queue = [0]
    dist_count: Dict[int, int] = {0: 1}
    while queue:
        current = queue.pop(0)
        for delta in [1, n - 1]:
            neighbor = (current + delta) % n
            if neighbor not in visited:
                d = visited[current] + 1
                visited[neighbor] = d
                dist_count[d] = dist_count.get(d, 0) + 1
                queue.append(neighbor)
    return dist_count


def csidh_keyspace_size(n: int, B: int) -> int:
    return (2 * B + 1) ** n


def plot_cayley_diameter():
    """Plot Cayley diameter vs n, comparing with ⌊n/2⌋."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Diameter vs n
    n_values = list(range(3, 102, 2))
    diameters = [cayley_diameter_bfs(n) for n in n_values]
    expected = [n // 2 for n in n_values]

    ax = axes[0]
    ax.plot(n_values, diameters, 'b-', linewidth=2, label='Computed diameter')
    ax.plot(n_values, expected, 'r--', linewidth=1.5, label='⌊n/2⌋')
    ax.set_xlabel('Group order n', fontsize=12)
    ax.set_ylabel('Cayley diameter', fontsize=12)
    ax.set_title('Cayley Graph Diameter of ℤ/nℤ', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 2: Distance distribution for a specific n
    n = 31
    dist = bfs_distance_distribution(n)
    distances = sorted(dist.keys())
    counts = [dist[d] for d in distances]

    ax = axes[1]
    ax.bar(distances, counts, color='steelblue', edgecolor='navy', alpha=0.8)
    ax.set_xlabel('Distance from origin', fontsize=12)
    ax.set_ylabel('Number of vertices', fontsize=12)
    ax.set_title(f'Distance Distribution in Cayley(ℤ/{n}ℤ)', fontsize=13)
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 3: Key space size (log scale)
    B_values = list(range(1, 21))
    for n_primes in [37, 50, 74]:
        sizes_bits = [float(n_primes) * np.log2(float(2*B+1)) for B in B_values]
        ax = axes[2]
        ax.plot(B_values, sizes_bits, 'o-', linewidth=2,
                label=f'n = {n_primes} primes', markersize=4)

    ax = axes[2]
    ax.axhline(y=128, color='gray', linestyle=':', label='128-bit security')
    ax.axhline(y=256, color='gray', linestyle='--', label='256-bit security')
    ax.set_xlabel('Exponent bound B', fontsize=12)
    ax.set_ylabel('Key space (bits)', fontsize=12)
    ax.set_title('CSIDH Key Space Size', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('cayley_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved cayley_analysis.png")


def plot_security_landscape():
    """Plot the security landscape of isogeny-based schemes."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Panel 1: Soundness error vs rounds
    rounds = np.arange(1, 513)
    soundness_error = 2.0 ** (-rounds)

    ax = axes[0]
    ax.semilogy(rounds, soundness_error, 'b-', linewidth=2)
    ax.axhline(y=2**(-128), color='red', linestyle='--', alpha=0.7,
               label='2⁻¹²⁸ target')
    ax.axvline(x=128, color='red', linestyle=':', alpha=0.5)
    ax.set_xlabel('Number of parallel rounds n', fontsize=12)
    ax.set_ylabel('Soundness error 2⁻ⁿ', fontsize=12)
    ax.set_title('CSI-FiSh Soundness Amplification', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 512)

    # Panel 2: Connector triangle identity verification
    test_ns = list(range(3, 200))
    triangle_values = []
    for n in test_ns:
        x, y, z = 1, n // 3, 2 * n // 3
        cxy = (y - x) % n
        cyz = (z - y) % n
        czx = (x - z) % n
        triangle_values.append((cxy + cyz + czx) % n)

    ax = axes[1]
    ax.scatter(test_ns, triangle_values, s=10, alpha=0.7, color='green')
    ax.set_xlabel('Group order n', fontsize=12)
    ax.set_ylabel('Triangle sum (mod n)', fontsize=12)
    ax.set_title('Connector Triangle Identity: ∑conn = 0', fontsize=13)
    ax.set_ylim(-0.5, 1.5)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('security_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved security_landscape.png")


if __name__ == "__main__":
    plot_cayley_diameter()
    plot_security_landscape()
    print("All visualizations generated.")
