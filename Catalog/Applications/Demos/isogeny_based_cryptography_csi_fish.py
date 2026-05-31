#!/usr/bin/env python3
"""
Demo: Isogeny-Based Cryptography — CSIDH and CSI-FiSh

Demonstrates the core algorithms formalized in Lean 4, using
Z/nZ as a stand-in for the class group action on supersingular curves.
"""

from algorithms import (
    CyclicGroupAction,
    CSIDHKeyExchange,
    CSIFiShSignature,
    IsogenyCayleyGraph,
    random_walk_distribution,
    total_variation_distance,
)


def demo_csidh():
    """Demonstrate CSIDH key exchange correctness."""
    print("=" * 60)
    print("CSIDH Key Exchange Demo")
    print("=" * 60)

    # Use Z/101Z as the class group (prime order for simplicity)
    n = 101
    group = CyclicGroupAction(n)
    csidh = CSIDHKeyExchange(group, base_point=0)

    # Generate keys for Alice and Bob
    alice_sk, alice_pk = csidh.keygen()
    bob_sk, bob_pk = csidh.keygen()

    print(f"\nGroup order: {n}")
    print(f"Base point: 0")
    print(f"\nAlice: secret = {alice_sk}, public = {alice_pk}")
    print(f"Bob:   secret = {bob_sk}, public = {bob_pk}")

    # Compute shared secrets
    alice_shared = csidh.shared_secret(alice_sk, bob_pk)
    bob_shared = csidh.shared_secret(bob_sk, alice_pk)

    print(f"\nAlice's shared secret: {alice_shared}")
    print(f"Bob's shared secret:   {bob_shared}")
    print(f"Secrets match: {alice_shared == bob_shared}")

    # Verify correctness for many random instances
    print("\nVerifying correctness for 1000 random key pairs...")
    all_correct = all(
        csidh.verify_correctness(
            __import__("secrets").randbelow(n),
            __import__("secrets").randbelow(n),
        )
        for _ in range(1000)
    )
    print(f"All correct: {all_correct}")
    print(f"(This is the machine-verified theorem shared_secret_agreement)")


def demo_csifish():
    """Demonstrate CSI-FiSh signature scheme."""
    print("\n" + "=" * 60)
    print("CSI-FiSh Signature Demo")
    print("=" * 60)

    n = 1009  # larger prime for security
    group = CyclicGroupAction(n)
    csifish = CSIFiShSignature(group, base_point=0, num_rounds=32)

    # Key generation
    sk, pk = csifish.keygen()
    print(f"\nGroup order: {n}")
    print(f"Signing key: {sk}")
    print(f"Verification key: {pk}")

    # Sign a message
    message = b"Hello, post-quantum world!"
    challenges, responses = csifish.sign(sk, message)
    print(f"\nMessage: {message.decode()}")
    print(f"Signature: {len(challenges)} challenge bits, {len(responses)} responses")

    # Verify
    valid = csifish.verify(pk, message, challenges, responses)
    print(f"Verification: {'PASS' if valid else 'FAIL'}")

    # Verify with wrong message
    wrong_message = b"Tampered message!"
    valid_wrong = csifish.verify(pk, wrong_message, challenges, responses)
    print(f"Verification with wrong message: {'PASS' if valid_wrong else 'FAIL'}")

    # Demonstrate special soundness
    print("\n--- Special Soundness Demo ---")
    r = __import__("secrets").randbelow(n)
    commitment = group.act(r, 0)  # R = r · x₀

    # Response for challenge 0
    z0 = r

    # Response for challenge 1
    z1 = group.multiply(r, group.inverse(sk))

    # Extract secret
    extracted = csifish.extract_secret(z0, z1)
    print(f"Original secret: {sk}")
    print(f"Extracted secret (z₀·z₁⁻¹): {extracted}")
    print(f"Extraction correct: {extracted == sk}")
    print(f"(This is the machine-verified theorem csifish_special_soundness)")


def demo_cayley_graph():
    """Demonstrate Cayley graph properties and diameter conjecture."""
    print("\n" + "=" * 60)
    print("Cayley Graph & Diameter Conjecture Demo")
    print("=" * 60)

    print("\nTesting diameter conjecture: diameter(Z/nZ, {1,-1}) = ⌊n/2⌋")
    print(f"{'n':>5} | {'Diameter':>8} | {'Expected':>8} | {'Match':>5}")
    print("-" * 40)

    for n in [3, 5, 7, 11, 13, 17, 19, 23]:
        group = CyclicGroupAction(n)
        graph = IsogenyCayleyGraph(group, [1, n - 1])
        holds, actual, expected = graph.test_diameter_conjecture()
        print(f"{n:>5} | {actual:>8} | {expected:>8} | {'✓' if holds else '✗':>5}")


def demo_mixing():
    """Demonstrate random walk mixing on Cayley graphs."""
    print("\n" + "=" * 60)
    print("Random Walk Mixing Demo")
    print("=" * 60)

    n = 23
    group = CyclicGroupAction(n)
    generators = [1, n - 1]  # {+1, -1}

    print(f"\nGroup: Z/{n}Z, Generators: {{1, -1}}")
    print(f"Uniform distribution: 1/{n} ≈ {1/n:.4f}")
    print(f"\n{'Steps':>6} | {'TV Distance':>12} | {'Mixed?':>6}")
    print("-" * 35)

    for steps in [1, 2, 5, 10, 20, 50, 100]:
        dist = random_walk_distribution(group, generators, steps, num_samples=50000)
        tvd = total_variation_distance(dist, n)
        mixed = tvd < 0.05
        print(f"{steps:>6} | {tvd:>12.4f} | {'Yes' if mixed else 'No':>6}")

    print(f"\nMixing time ≈ O(n²) = O({n}²) = O({n**2})")
    print("(For the cycle graph Z/nZ with ±1 generators)")


def demo_collision_resistance():
    """Demonstrate collision resistance of the public key map."""
    print("\n" + "=" * 60)
    print("Collision Resistance Demo")
    print("=" * 60)

    n = 97
    group = CyclicGroupAction(n)
    base = 0

    print(f"\nGroup order: {n}")
    print(f"Testing public key map: g ↦ g · {base}")

    # The public key map is a bijection (no collisions possible)
    pk_map = {}
    collisions = 0
    for g in range(n):
        pk = group.act(g, base)
        if pk in pk_map:
            collisions += 1
            print(f"  COLLISION: pk({g}) = pk({pk_map[pk]}) = {pk}")
        pk_map[pk] = g

    print(f"Collisions found: {collisions}")
    print(f"Map is injective: {collisions == 0}")
    print(f"Map is surjective: {len(set(pk_map.keys())) == n}")
    print(f"(This is the machine-verified theorem no_collision_in_free_action)")


if __name__ == "__main__":
    demo_csidh()
    demo_csifish()
    demo_cayley_graph()
    demo_mixing()
    demo_collision_resistance()


#!/usr/bin/env python3
"""
Visualization: Cayley graph of Z/nZ with generators {+1, -1}.
Demonstrates the isogeny graph structure used in CSIDH.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def draw_cayley_graph(n: int, ax, title: str = ""):
    """Draw the Cayley graph of Z/nZ with generators {1, -1}."""
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    x = np.cos(angles)
    y = np.sin(angles)

    # Draw edges (each vertex connected to its neighbors)
    for i in range(n):
        j = (i + 1) % n
        ax.plot([x[i], x[j]], [y[i], y[j]], 'b-', linewidth=1.5, alpha=0.6)

    # Draw vertices
    ax.scatter(x, y, s=200, c='steelblue', zorder=5, edgecolors='navy', linewidth=1.5)
    for i in range(n):
        ax.annotate(str(i), (x[i], y[i]), ha='center', va='center',
                   fontsize=8, fontweight='bold', color='white', zorder=6)

    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.axis('off')


def draw_csidh_exchange(n: int, alice_sk: int, bob_sk: int, ax):
    """Visualize CSIDH key exchange on the Cayley graph."""
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    x = np.cos(angles)
    y = np.sin(angles)

    base = 0
    alice_pk = (alice_sk + base) % n
    bob_pk = (bob_sk + base) % n
    shared = (alice_sk + bob_sk + base) % n

    # Draw edges
    for i in range(n):
        j = (i + 1) % n
        ax.plot([x[i], x[j]], [y[i], y[j]], 'gray', linewidth=0.8, alpha=0.3)

    # Draw vertices
    ax.scatter(x, y, s=100, c='lightgray', zorder=4, edgecolors='gray', linewidth=0.5)

    # Highlight special vertices
    highlights = [
        (base, 'green', 'E₀ (base)', 300),
        (alice_pk, 'red', f'E_A (Alice pk={alice_pk})', 300),
        (bob_pk, 'blue', f'E_B (Bob pk={bob_pk})', 300),
        (shared, 'purple', f'Shared ({shared})', 400),
    ]

    for idx, color, label, size in highlights:
        ax.scatter(x[idx], y[idx], s=size, c=color, zorder=6, edgecolors='black',
                  linewidth=2)
        offset = 0.2
        ax.annotate(label, (x[idx] + offset * np.cos(angles[idx]),
                           y[idx] + offset * np.sin(angles[idx])),
                   fontsize=7, fontweight='bold', color=color,
                   ha='center', va='center')

    # Draw action arrows
    def draw_action_arrow(start, end, color, label):
        mid_angle = (angles[start] + angles[end]) / 2
        r = 1.15
        ax.annotate('', xy=(x[end], y[end]), xytext=(x[start], y[start]),
                   arrowprops=dict(arrowstyle='->', color=color, lw=2,
                                  connectionstyle='arc3,rad=0.3'))

    draw_action_arrow(base, alice_pk, 'red', f'[a]={alice_sk}')
    draw_action_arrow(base, bob_pk, 'blue', f'[b]={bob_sk}')
    draw_action_arrow(alice_pk, shared, 'blue', f'[b]')
    draw_action_arrow(bob_pk, shared, 'red', f'[a]')

    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)
    ax.set_aspect('equal')
    ax.set_title(f'CSIDH Key Exchange on Z/{n}Z\n'
                f'Alice: [a]={alice_sk}, Bob: [b]={bob_sk}, Shared={shared}',
                fontsize=11, fontweight='bold')
    ax.axis('off')


def draw_mixing_time(ax):
    """Plot random walk mixing time convergence."""
    np.random.seed(42)
    n = 23
    steps_list = list(range(1, 100))
    tvds = []
    num_samples = 2000

    for steps in steps_list:
        # Vectorized random walk
        increments = np.random.choice([1, -1], size=(num_samples, steps))
        positions = np.cumsum(increments, axis=1) % n
        final_positions = positions[:, -1]
        counts = np.bincount(final_positions, minlength=n).astype(float)
        dist = counts / num_samples
        tvd = 0.5 * np.sum(np.abs(dist - 1.0/n))
        tvds.append(tvd)

    ax.plot(steps_list, tvds, 'b-', linewidth=2, label='TV distance')
    ax.axhline(y=0.05, color='r', linestyle='--', alpha=0.7, label='ε = 0.05 threshold')
    ax.axhline(y=1/np.e, color='orange', linestyle=':', alpha=0.7, label='1/e threshold')

    # Mark approximate mixing time
    mix_time = next((s for s, t in zip(steps_list, tvds) if t < 0.05), None)
    if mix_time:
        ax.axvline(x=mix_time, color='green', linestyle='--', alpha=0.5)
        ax.annotate(f'τ_mix ≈ {mix_time}', (mix_time, 0.3),
                   fontsize=10, color='green', fontweight='bold')

    ax.set_xlabel('Random Walk Steps', fontsize=11)
    ax.set_ylabel('Total Variation Distance', fontsize=11)
    ax.set_title(f'Mixing Time: Random Walk on Z/{n}Z', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)


if __name__ == '__main__':
    fig, axes = plt.subplots(2, 2, figsize=(14, 14))

    draw_cayley_graph(11, axes[0, 0], 'Cayley Graph: Z/11Z')
    draw_cayley_graph(17, axes[0, 1], 'Cayley Graph: Z/17Z')
    draw_csidh_exchange(13, alice_sk=3, bob_sk=5, ax=axes[1, 0])
    draw_mixing_time(axes[1, 1])

    plt.tight_layout()
    plt.savefig('cayley_graphs.png', dpi=150, bbox_inches='tight')
    print('Saved cayley_graphs.png')
