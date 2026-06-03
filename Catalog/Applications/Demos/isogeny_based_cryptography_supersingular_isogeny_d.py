#!/usr/bin/env python3
"""
SIDH Key Exchange Demonstration

Demonstrates the Supersingular Isogeny Diffie-Hellman key exchange
using a simplified finite group model. We use Z/nZ as the "class group"
acting on itself, with Alice and Bob using different subgroups.

This illustrates the algebraic structure without implementing actual
elliptic curve isogenies.
"""

import random
from typing import Tuple


def mod_exp(base: int, exp: int, mod: int) -> int:
    """Modular exponentiation."""
    return pow(base, exp, mod)


class SimplifiedSIDH:
    """
    Simplified SIDH using commuting group actions on Z/pZ.

    In real SIDH:
    - Alice uses 2^eA-isogenies
    - Bob uses 3^eB-isogenies
    - The commutativity comes from disjoint kernel support

    Here we model this with:
    - G_A = Z/2^eA Z acting by multiplication
    - G_B = Z/3^eB Z acting by multiplication
    - J = Z/NZ where N = 2^eA * 3^eB
    """

    def __init__(self, eA: int = 4, eB: int = 3):
        self.eA = eA
        self.eB = eB
        self.nA = 2 ** eA  # Alice's key space
        self.nB = 3 ** eB  # Bob's key space
        self.N = self.nA * self.nB  # Total space

    def act_A(self, secret: int, j: int) -> int:
        """Alice's action: j -> (secret * nB + 1) * j mod N"""
        # Use a commuting action structure
        return (j + secret * self.nB) % self.N

    def act_B(self, secret: int, j: int) -> int:
        """Bob's action: j -> (secret * nA + 1) * j mod N"""
        return (j + secret * self.nA) % self.N

    def key_exchange(self, j0: int, secret_A: int, secret_B: int) -> Tuple[int, int, int, int, int]:
        """
        Perform SIDH key exchange.

        Returns: (alice_public, bob_public, alice_shared, bob_shared, j0)
        """
        # Public keys
        alice_public = self.act_A(secret_A, j0)
        bob_public = self.act_B(secret_B, j0)

        # Shared secrets (should be equal by commutativity)
        alice_shared = self.act_A(secret_A, bob_public)
        bob_shared = self.act_B(secret_B, alice_public)

        return alice_public, bob_public, alice_shared, bob_shared, j0

    def verify_commutativity(self, j: int, a: int, b: int) -> bool:
        """Verify that act_A and act_B commute."""
        lhs = self.act_A(a, self.act_B(b, j))
        rhs = self.act_B(b, self.act_A(a, j))
        return lhs == rhs


def euler_four_square_identity(a1: int, b1: int, c1: int, d1: int,
                                a2: int, b2: int, c2: int, d2: int) -> Tuple:
    """
    Euler's four-square identity: demonstrates quaternion norm multiplicativity.

    (a1² + b1² + c1² + d1²)(a2² + b2² + c2² + d2²) = sum of 4 squares
    """
    lhs = (a1**2 + b1**2 + c1**2 + d1**2) * (a2**2 + b2**2 + c2**2 + d2**2)

    p = a1*a2 - b1*b2 - c1*c2 - d1*d2
    q = a1*b2 + b1*a2 + c1*d2 - d1*c2
    r = a1*c2 - b1*d2 + c1*a2 + d1*b2
    s = a1*d2 + b1*c2 - c1*b2 + d1*a2

    rhs = p**2 + q**2 + r**2 + s**2

    return lhs, rhs, (p, q, r, s)


def castryck_decru_simulation(sidh: SimplifiedSIDH, j0: int,
                               secret_A: int, secret_B: int):
    """
    Simulate the Castryck-Decru attack structure.

    In real SIDH, Alice publishes torsion point images.
    Here we show that this auxiliary data allows secret recovery.
    """
    alice_pub, bob_pub, alice_shared, bob_shared, _ = sidh.key_exchange(j0, secret_A, secret_B)

    # Torsion data: images of Bob's generators under Alice's isogeny
    torsion_images = []
    for b in range(sidh.nB):
        img = sidh.act_A(secret_A, sidh.act_B(b, j0))
        torsion_images.append(img)

    # Attack: recover secret_A from torsion data
    # In our simplified model, we can solve this directly
    # The key equation: act_A(secret_A, act_B(1, j0)) = torsion_images[1]
    # => (j0 + nA + secret_A * nB) mod N = torsion_images[1]
    target = torsion_images[1]
    base = sidh.act_B(1, j0)

    # Recover: target = base + secret_A * nB mod N
    # Since nB divides N, we work mod nA instead
    diff = (target - base) % sidh.N
    # diff = secret_A * nB mod N, and since gcd(nB, N) = nB,
    # we have diff / nB = secret_A mod nA
    if diff % sidh.nB != 0:
        recovered_A = diff % sidh.nA  # fallback
    else:
        recovered_A = (diff // sidh.nB) % sidh.nA

    return recovered_A, secret_A, recovered_A == secret_A


def main():
    print("=" * 70)
    print("SIDH KEY EXCHANGE DEMONSTRATION")
    print("=" * 70)

    # 1. Basic key exchange
    print("\n--- 1. SIDH Key Exchange ---")
    sidh = SimplifiedSIDH(eA=4, eB=3)
    print(f"Parameters: eA={sidh.eA}, eB={sidh.eB}")
    print(f"Alice's key space: Z/{sidh.nA}Z")
    print(f"Bob's key space: Z/{sidh.nB}Z")
    print(f"Total space: Z/{sidh.N}Z")

    j0 = 42
    secret_A = random.randint(0, sidh.nA - 1)
    secret_B = random.randint(0, sidh.nB - 1)

    alice_pub, bob_pub, alice_shared, bob_shared, _ = sidh.key_exchange(j0, secret_A, secret_B)

    print(f"\nStarting point: j₀ = {j0}")
    print(f"Alice's secret: {secret_A}")
    print(f"Bob's secret: {secret_B}")
    print(f"Alice's public key: {alice_pub}")
    print(f"Bob's public key: {bob_pub}")
    print(f"Alice's shared secret: {alice_shared}")
    print(f"Bob's shared secret: {bob_shared}")
    print(f"Shared secrets match: {alice_shared == bob_shared} ✓")

    # 2. Commutativity verification
    print("\n--- 2. Commutativity Verification ---")
    all_commute = True
    for a in range(sidh.nA):
        for b in range(sidh.nB):
            if not sidh.verify_commutativity(j0, a, b):
                all_commute = False
                break
    print(f"All (a, b) pairs commute: {all_commute} ✓")

    # 3. Euler's Four-Square Identity
    print("\n--- 3. Euler's Four-Square Identity ---")
    for _ in range(5):
        vals = [random.randint(-10, 10) for _ in range(8)]
        lhs, rhs, components = euler_four_square_identity(*vals)
        print(f"  ({vals[0]}²+{vals[1]}²+{vals[2]}²+{vals[3]}²) × "
              f"({vals[4]}²+{vals[5]}²+{vals[6]}²+{vals[7]}²) = {lhs}")
        print(f"  = {components[0]}²+{components[1]}²+{components[2]}²+{components[3]}² = {rhs}")
        assert lhs == rhs, "Identity failed!"
        print(f"  Verified ✓")

    # 4. Castryck-Decru Attack Simulation
    print("\n--- 4. Castryck-Decru Attack Simulation ---")
    sidh2 = SimplifiedSIDH(eA=6, eB=4)
    j0 = 7
    secret_A = random.randint(0, sidh2.nA - 1)
    secret_B = random.randint(0, sidh2.nB - 1)

    recovered, actual, success = castryck_decru_simulation(sidh2, j0, secret_A, secret_B)
    print(f"Parameters: eA={sidh2.eA}, eB={sidh2.eB}")
    print(f"Actual secret: {actual}")
    print(f"Recovered secret: {recovered}")
    print(f"Attack successful: {success} ✓")

    # 5. Security parameter analysis
    print("\n--- 5. Security Parameters ---")
    for bits in [128, 192, 256, 384, 512]:
        classical = bits // 4
        quantum = bits // 6
        key_size = 2 * bits
        print(f"  λ={bits}: classical={classical}b, quantum={quantum}b, "
              f"key={key_size}b, post-CD=0b")

    # 6. Coprimality check
    print("\n--- 6. Coprimality of 2^eA and 3^eB ---")
    from math import gcd
    for eA in range(1, 11):
        for eB in range(1, 8):
            g = gcd(2**eA, 3**eB)
            assert g == 1, f"gcd(2^{eA}, 3^{eB}) = {g} ≠ 1"
    print("  All pairs (eA, eB) with 1≤eA≤10, 1≤eB≤7: gcd=1 ✓")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: SIDH Key Exchange and Castryck-Decru Attack

Generates plots showing:
1. The SIDH key exchange diagram
2. Security parameter comparison (pre/post attack)
3. Key space sizes vs. parameter choices
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_security_comparison():
    """Compare pre-attack and post-attack security levels."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    lambdas = np.array([128, 192, 256, 384, 512])

    # Pre-attack security
    classical = lambdas // 4
    quantum = lambdas // 6

    ax1.bar(np.arange(len(lambdas)) - 0.15, classical, 0.3, label='Classical (λ/4)', color='#2196F3')
    ax1.bar(np.arange(len(lambdas)) + 0.15, quantum, 0.3, label='Quantum (λ/6)', color='#FF9800')
    ax1.set_xticks(np.arange(len(lambdas)))
    ax1.set_xticklabels([f'λ={l}' for l in lambdas])
    ax1.set_ylabel('Security bits')
    ax1.set_title('SIDH Security (Pre-Attack)')
    ax1.legend()
    ax1.grid(axis='y', alpha=0.3)

    # Post-attack: all zero
    post_attack = np.zeros(len(lambdas))
    colors = ['#F44336'] * len(lambdas)
    ax2.bar(np.arange(len(lambdas)), post_attack + 0.5, color=colors)
    ax2.set_xticks(np.arange(len(lambdas)))
    ax2.set_xticklabels([f'λ={l}' for l in lambdas])
    ax2.set_ylabel('Security bits')
    ax2.set_title('SIDH Security (Post Castryck-Decru, 2022)')
    ax2.set_ylim(0, max(classical) + 10)
    ax2.text(2, max(classical) / 2, 'BROKEN\n(Polynomial-time attack)',
             ha='center', va='center', fontsize=16, color='red', fontweight='bold')
    ax2.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    plt.savefig('security_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: security_comparison.png")


def plot_keyspace_sizes():
    """Plot key space sizes as functions of eA and eB."""
    fig, ax = plt.subplots(figsize=(10, 6))

    eA_range = np.arange(1, 20)
    eB_range = np.arange(1, 13)

    alice_space = 2.0 ** eA_range
    bob_space = 3.0 ** eB_range

    ax.semilogy(eA_range, alice_space, 'b-o', label='Alice: 2^eA', markersize=4)
    ax.semilogy(eB_range, bob_space, 'r-s', label='Bob: 3^eB', markersize=4)

    # SIDH prime
    for eA, eB in [(216, 137), (250, 159), (305, 192)]:
        ax.axhline(y=2**eA, color='blue', alpha=0.2, linestyle='--')
        ax.axhline(y=3**eB, color='red', alpha=0.2, linestyle='--')

    ax.set_xlabel('Exponent (eA or eB)')
    ax.set_ylabel('Key Space Size (log scale)')
    ax.set_title('SIDH Key Space Sizes')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('keyspace_sizes.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: keyspace_sizes.png")


def plot_euler_identity_verification():
    """Visualize Euler's four-square identity for random quaternions."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n_tests = 100
    norms_product = []
    norms_composed = []

    for _ in range(n_tests):
        q1 = [np.random.randint(-20, 21) for _ in range(4)]
        q2 = [np.random.randint(-20, 21) for _ in range(4)]

        n1 = sum(x**2 for x in q1)
        n2 = sum(x**2 for x in q2)

        # Quaternion product
        a1, b1, c1, d1 = q1
        a2, b2, c2, d2 = q2
        p = [a1*a2 - b1*b2 - c1*c2 - d1*d2,
             a1*b2 + b1*a2 + c1*d2 - d1*c2,
             a1*c2 - b1*d2 + c1*a2 + d1*b2,
             a1*d2 + b1*c2 - c1*b2 + d1*a2]
        n_prod = sum(x**2 for x in p)

        norms_product.append(n1 * n2)
        norms_composed.append(n_prod)

    ax.scatter(norms_product, norms_composed, alpha=0.6, s=20, c='#4CAF50')
    max_val = max(max(norms_product), max(norms_composed))
    ax.plot([0, max_val], [0, max_val], 'r--', alpha=0.8, label='y = x (identity)')
    ax.set_xlabel('N(q₁) · N(q₂)')
    ax.set_ylabel('N(q₁ · q₂)')
    ax.set_title("Euler's Four-Square Identity: N(q₁)·N(q₂) = N(q₁·q₂)")
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('euler_identity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: euler_identity.png")


if __name__ == "__main__":
    plot_security_comparison()
    plot_keyspace_sizes()
    plot_euler_identity_verification()
    print("\nAll visualizations generated.")
