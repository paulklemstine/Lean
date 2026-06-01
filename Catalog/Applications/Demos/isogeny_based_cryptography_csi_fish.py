"""
Demo: Isogeny-Based Cryptography — CSI-FiSh

Demonstrates CSIDH key exchange, CSI-FiSh signatures,
multi-party key agreement, and the Cayley diameter conjecture.
"""
from algorithms import (
    CyclicGroupAction, CSIDHSimulator, CSIFiShIdentification,
    CSIFiShSignature, keyspace_size, verify_cayley_conjecture,
    multi_party_csidh
)


def demo_csidh_key_exchange():
    """Demonstrate CSIDH key exchange."""
    print("=" * 60)
    print("CSIDH Key Exchange (Simulated over Z/pZ)")
    print("=" * 60)

    p = 997  # A prime (stands in for the real CSIDH prime)
    sim = CSIDHSimulator(p)

    alice_secret, alice_public = sim.keygen()
    bob_secret, bob_public = sim.keygen()

    alice_shared = sim.shared_secret(alice_secret, bob_public)
    bob_shared = sim.shared_secret(bob_secret, alice_public)

    print(f"Prime p = {p}")
    print(f"Alice: secret = {alice_secret}, public = {alice_public}")
    print(f"Bob:   secret = {bob_secret}, public = {bob_public}")
    print(f"Alice's shared secret: {alice_shared}")
    print(f"Bob's shared secret:   {bob_shared}")
    print(f"Agreement: {alice_shared == bob_shared}")
    print()


def demo_csifish_identification():
    """Demonstrate CSI-FiSh identification protocol."""
    print("=" * 60)
    print("CSI-FiSh Identification Protocol")
    print("=" * 60)

    p = 997
    ident = CSIFiShIdentification(p)
    ga = CyclicGroupAction(p)

    # Setup
    secret = 42
    pk = ga.act(secret, 0)
    print(f"Secret key: {secret}")
    print(f"Public key: {pk}")

    # Run 10 rounds
    successes = 0
    for i in range(10):
        r, R = ident.commit(secret)
        challenge = (i % 2 == 0)
        response = ident.respond(r, secret, challenge)
        valid = ident.verify(pk, R, challenge, response)
        successes += int(valid)
        print(f"  Round {i+1}: challenge={int(challenge)}, response={response}, valid={valid}")

    print(f"All rounds valid: {successes == 10}")
    print()


def demo_special_soundness():
    """Demonstrate special soundness extraction."""
    print("=" * 60)
    print("Special Soundness: Secret Extraction")
    print("=" * 60)

    p = 997
    ident = CSIFiShIdentification(p)
    ga = CyclicGroupAction(p)

    secret = 42
    pk = ga.act(secret, 0)

    # Two transcripts with different challenges, same commitment
    r = 73
    R = ga.act(r, 0)

    z0 = ident.respond(r, secret, challenge=False)  # z0 = r
    z1 = ident.respond(r, secret, challenge=True)    # z1 = r - s

    extracted = ident.extract_secret(z0, z1)
    print(f"True secret: {secret}")
    print(f"Response to challenge 0: z₀ = {z0}")
    print(f"Response to challenge 1: z₁ = {z1}")
    print(f"Extracted secret (z₀ - z₁): {extracted}")
    print(f"Extraction correct: {extracted == secret}")
    print()


def demo_csifish_signature():
    """Demonstrate CSI-FiSh signature scheme."""
    print("=" * 60)
    print("CSI-FiSh Digital Signature")
    print("=" * 60)

    p = 997
    sig_scheme = CSIFiShSignature(p, num_rounds=16)
    ga = CyclicGroupAction(p)

    secret = 42
    pk = ga.act(secret, 0)
    message = b"Post-quantum signatures are here!"

    signature = sig_scheme.sign(secret, message)
    commitments, challenges, responses = signature

    valid = sig_scheme.verify(pk, message, signature)
    print(f"Message: {message.decode()}")
    print(f"Public key: {pk}")
    print(f"Signature rounds: {len(commitments)}")
    print(f"Signature valid: {valid}")

    # Test forgery detection
    fake_msg = b"This is a forged message"
    forged_valid = sig_scheme.verify(pk, fake_msg, signature)
    print(f"Forged message valid: {forged_valid}")
    print()


def demo_multi_party():
    """Demonstrate multi-party CSIDH key agreement."""
    print("=" * 60)
    print("Multi-Party CSIDH Key Agreement")
    print("=" * 60)

    p = 997
    ga = CyclicGroupAction(p)
    n_parties = 5
    secrets = [42, 73, 156, 289, 401]

    print(f"Number of parties: {n_parties}")
    print(f"Secrets: {secrets}")

    # Each party computes the shared key via the product
    shared = multi_party_csidh(secrets, p)
    print(f"Shared key: {shared}")

    # Verify permutation invariance
    import random
    shuffled = secrets.copy()
    random.shuffle(shuffled)
    shared2 = multi_party_csidh(shuffled, p)
    print(f"Shuffled secrets: {shuffled}")
    print(f"Shared key (shuffled): {shared2}")
    print(f"Permutation invariant: {shared == shared2}")
    print()


def demo_keyspace():
    """Demonstrate key space size analysis."""
    print("=" * 60)
    print("CSIDH Key Space Analysis")
    print("=" * 60)

    print(f"{'n primes':>10} {'bound B':>10} {'key space':>20} {'security bits':>15}")
    print("-" * 60)
    for n in [37, 74, 111]:
        for B in [5, 10, 20]:
            ks = keyspace_size(n, B)
            bits = ks.bit_length()
            print(f"{n:>10} {B:>10} {ks:>20,.0f}{'...' if ks > 10**15 else ''} {bits:>15}")
    print()


def demo_cayley_conjecture():
    """Test the Cayley diameter conjecture."""
    print("=" * 60)
    print("Cayley Diameter Conjecture Verification")
    print("=" * 60)

    print(f"{'n':>5} {'diameter ⌊n/2⌋':>15} {'conjecture holds':>20}")
    print("-" * 45)
    for n in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 97, 101]:
        d = n // 2
        holds = verify_cayley_conjecture(n)
        print(f"{n:>5} {d:>15} {str(holds):>20}")
    print()


if __name__ == "__main__":
    demo_csidh_key_exchange()
    demo_csifish_identification()
    demo_special_soundness()
    demo_csifish_signature()
    demo_multi_party()
    demo_keyspace()
    demo_cayley_conjecture()


"""
Visualization: Cayley Graph of Z/nZ with generators {+1, -1}

This standalone script visualizes the Cayley graph structure
that underlies isogeny-based cryptography like CSIDH.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_cayley_graph(n: int, ax, title: str = ""):
    """Draw the Cayley graph of Z/nZ with generators {+1, -1}."""
    angles = [2 * np.pi * k / n for k in range(n)]
    xs = [np.cos(a) for a in angles]
    ys = [np.sin(a) for a in angles]

    # Draw edges (each node connects to neighbors ±1)
    for k in range(n):
        next_k = (k + 1) % n
        ax.plot([xs[k], xs[next_k]], [ys[k], ys[next_k]],
                'b-', alpha=0.3, linewidth=1)

    # Draw nodes
    ax.scatter(xs, ys, s=200, c='steelblue', zorder=5, edgecolors='navy')

    # Label nodes
    for k in range(n):
        offset = 1.15
        ax.text(xs[k] * offset, ys[k] * offset, str(k),
                ha='center', va='center', fontsize=8, fontweight='bold')

    # Highlight diameter path
    diameter = n // 2
    path_nodes = list(range(diameter + 1))
    for i in range(len(path_nodes) - 1):
        k1, k2 = path_nodes[i], path_nodes[i + 1]
        ax.plot([xs[k1], xs[k2]], [ys[k1], ys[k2]],
                'r-', linewidth=2.5, alpha=0.7, zorder=4)

    ax.scatter([xs[0]], [ys[0]], s=300, c='gold', zorder=6,
               edgecolors='darkgoldenrod', linewidth=2, marker='*')
    ax.scatter([xs[diameter]], [ys[diameter]], s=300, c='red', zorder=6,
               edgecolors='darkred', linewidth=2, marker='D')

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(f"{title}\nDiameter = ⌊{n}/2⌋ = {diameter}", fontsize=10)
    ax.axis('off')


def draw_keyspace_growth():
    """Plot key space growth as function of parameters."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Key space vs number of primes
    B = 5
    ns = range(1, 80)
    sizes = [(2 * B + 1) ** n for n in ns]
    bits = [s.bit_length() for s in sizes]

    ax1.plot(list(ns), bits, 'b-', linewidth=2)
    ax1.axhline(y=128, color='r', linestyle='--', label='128-bit security')
    ax1.axhline(y=256, color='g', linestyle='--', label='256-bit security')
    ax1.set_xlabel('Number of primes (n)', fontsize=12)
    ax1.set_ylabel('Security bits (log₂ key space)', fontsize=12)
    ax1.set_title(f'Key Space Growth (B = {B})', fontsize=13)
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Key space vs bound
    n = 37
    Bs = range(1, 30)
    sizes2 = [(2 * b + 1) ** n for b in Bs]
    bits2 = [s.bit_length() for s in sizes2]

    ax2.plot(list(Bs), bits2, 'b-', linewidth=2)
    ax2.axhline(y=128, color='r', linestyle='--', label='128-bit security')
    ax2.axhline(y=256, color='g', linestyle='--', label='256-bit security')
    ax2.set_xlabel('Exponent bound (B)', fontsize=12)
    ax2.set_ylabel('Security bits (log₂ key space)', fontsize=12)
    ax2.set_title(f'Key Space Growth (n = {n})', fontsize=13)
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('keyspace_growth.png', dpi=150, bbox_inches='tight')
    print("Saved keyspace_growth.png")


def main():
    # Cayley graphs for small primes
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    primes = [5, 7, 11, 13, 17, 19]

    for ax, p in zip(axes.flat, primes):
        draw_cayley_graph(p, ax, f"Z/{p}Z Cayley Graph")

    fig.suptitle("Cayley Graphs of Cyclic Groups\n(Models of CSIDH Isogeny Graphs)",
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('cayley_graphs.png', dpi=150, bbox_inches='tight')
    print("Saved cayley_graphs.png")

    # Key space growth
    draw_keyspace_growth()


if __name__ == "__main__":
    main()
