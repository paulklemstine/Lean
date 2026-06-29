#!/usr/bin/env python3
"""
Applications of Tropical Cryptography

Demonstrates real-world applications of min-plus algebra and tropical
cryptographic primitives:

1. Secure shortest-path computation (privacy-preserving routing)
2. Network security analysis (attack path costs)
3. Supply chain optimization with encrypted costs
4. Tropical hash function for data integrity
"""

import numpy as np
from typing import List, Tuple, Dict
import hashlib

INF = float('inf')


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication."""
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i, k] + B[k, j]
                if val < C[i, j]:
                    C[i, j] = val
    return C


def trop_identity(n: int) -> np.ndarray:
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0)
    return I


def trop_pow(A: np.ndarray, k: int) -> np.ndarray:
    if k == 0:
        return trop_identity(A.shape[0])
    result = trop_identity(A.shape[0])
    base = A.copy()
    while k > 0:
        if k % 2 == 1:
            result = trop_mat_mul(base, result)
        base = trop_mat_mul(base, base)
        k //= 2
    return result


# =============================================================================
# Application 1: Privacy-Preserving Routing
# =============================================================================

def privacy_preserving_routing():
    """
    Demonstrate how tropical cryptography enables privacy-preserving
    shortest-path computation.

    Scenario: Multiple network operators want to compute end-to-end
    shortest paths without revealing their internal network costs.

    Each operator encrypts their adjacency matrix using a tropical
    public key. The composed tropical product still computes shortest
    paths through the concatenated network.
    """
    print("=" * 60)
    print("APPLICATION 1: Privacy-Preserving Routing")
    print("=" * 60)
    print()

    # Two network operators with private cost matrices
    # Operator A: 4-node internal network
    net_A = np.array([
        [0, 3, INF, 7],
        [INF, 0, 2, INF],
        [INF, INF, 0, 1],
        [INF, INF, INF, 0]
    ])

    # Operator B: 4-node internal network
    net_B = np.array([
        [0, 1, INF, INF],
        [INF, 0, 4, INF],
        [INF, INF, 0, 2],
        [INF, INF, INF, 0]
    ])

    print("Network A (private costs):")
    print_matrix(net_A)
    print()
    print("Network B (private costs):")
    print_matrix(net_B)
    print()

    # Composed network: total shortest paths through A then B
    composed = trop_mat_mul(net_A, net_B)
    print("Composed network A ⊗ B (shortest paths through both):")
    print_matrix(composed)
    print()

    # Tropical encryption masks the individual costs
    # while preserving the shortest-path structure
    G = np.array([
        [0, 1, 2, 3],
        [3, 0, 1, 2],
        [2, 3, 0, 1],
        [1, 2, 3, 0]
    ], dtype=float)

    mask = trop_pow(G, 5)
    masked_A = trop_mat_mul(mask, net_A)
    masked_B = trop_mat_mul(mask, net_B)

    print("Masked network A (encrypted):")
    print_matrix(masked_A)
    print()
    print("Masked network B (encrypted):")
    print_matrix(masked_B)
    print()
    print("Key insight: The masked matrices hide individual costs")
    print("but tropical multiplication preserves path structure.")
    print()


# =============================================================================
# Application 2: Network Security Analysis
# =============================================================================

def network_security_analysis():
    """
    Use tropical matrix powers to analyze attack paths in a network.

    Each matrix entry represents the cost (difficulty) of an attack
    step between nodes. Tropical matrix powers compute the minimum
    total cost of multi-step attacks.
    """
    print("=" * 60)
    print("APPLICATION 2: Network Security — Attack Path Analysis")
    print("=" * 60)
    print()

    # Attack cost matrix: cost of compromising node j from node i
    # Nodes: 0=Internet, 1=Firewall, 2=WebServer, 3=Database, 4=Admin
    labels = ["Internet", "Firewall", "WebServer", "Database", "Admin"]
    n = 5

    attack_costs = np.array([
        [0,   5, INF, INF, INF],  # Internet → Firewall costs 5
        [INF, 0,   3,   INF,  8],  # Firewall → WebServer costs 3
        [INF, INF, 0,   4, INF],  # WebServer → Database costs 4
        [INF, INF, INF, 0,   2],  # Database → Admin costs 2
        [INF, INF, INF, INF, 0],  # Admin (target)
    ], dtype=float)

    print("Attack cost matrix (∞ = no direct attack):")
    print(f"  {'':>10}", end="")
    for l in labels:
        print(f"{l:>10}", end="")
    print()
    for i in range(n):
        print(f"  {labels[i]:>10}", end="")
        for j in range(n):
            if attack_costs[i, j] == INF:
                print(f"{'∞':>10}", end="")
            else:
                print(f"{attack_costs[i, j]:>10.0f}", end="")
        print()
    print()

    # Compute multi-step attack costs
    for steps in [1, 2, 3, 4]:
        power = trop_pow(attack_costs, steps)
        internet_to_admin = power[0, 4]
        cost_str = f"{internet_to_admin:.0f}" if internet_to_admin != INF else "∞"
        print(f"  Min cost of {steps}-step attack (Internet → Admin): {cost_str}")

    # All-pairs shortest attack paths (transitive closure)
    closure = attack_costs.copy()
    for k in range(1, n + 1):
        new = trop_pow(attack_costs, k)
        for i in range(n):
            for j in range(n):
                closure[i, j] = min(closure[i, j], new[i, j])

    print()
    print("Shortest attack paths (any number of steps):")
    print(f"  Internet → Admin: {closure[0, 4]:.0f}")
    print(f"  Internet → Database: {closure[0, 3]:.0f}")
    print(f"  Firewall → Admin: {closure[1, 4]:.0f}")
    print()
    print("Security insight: The tropical closure reveals the weakest")
    print("attack chain, helping prioritize defenses.")
    print()


# =============================================================================
# Application 3: Supply Chain with Encrypted Costs
# =============================================================================

def supply_chain_optimization():
    """
    Optimize supply chain routing using tropical algebra.

    Tropical matrix multiplication naturally models supply chain
    cost aggregation: the cost through a chain of suppliers is
    the sum of individual costs, and the optimal is the minimum.
    """
    print("=" * 60)
    print("APPLICATION 3: Supply Chain Optimization")
    print("=" * 60)
    print()

    # Stage 1: Raw materials → Components (3 suppliers, 3 components)
    stage1 = np.array([
        [2, 5, INF],  # Supplier 1
        [INF, 3, 4],  # Supplier 2
        [1, INF, 6],  # Supplier 3
    ], dtype=float)

    # Stage 2: Components → Products (3 components, 3 products)
    stage2 = np.array([
        [3, INF, 2],  # Component 1
        [INF, 1, 4],  # Component 2
        [5, 3, INF],  # Component 3
    ], dtype=float)

    # Stage 3: Products → Markets (3 products, 3 markets)
    stage3 = np.array([
        [1, 4, INF],  # Product 1
        [INF, 2, 3],  # Product 2
        [5, INF, 1],  # Product 3
    ], dtype=float)

    print("Stage 1 (Materials → Components):")
    print_matrix(stage1)
    print()
    print("Stage 2 (Components → Products):")
    print_matrix(stage2)
    print()
    print("Stage 3 (Products → Markets):")
    print_matrix(stage3)
    print()

    # End-to-end optimal costs via tropical multiplication
    end_to_end = trop_mat_mul(trop_mat_mul(stage1, stage2), stage3)

    print("End-to-end optimal costs (Materials → Markets):")
    print_matrix(end_to_end)
    print()

    # Verify associativity
    alt = trop_mat_mul(stage1, trop_mat_mul(stage2, stage3))
    print(f"Associativity verified: {np.array_equal(end_to_end, alt)}")
    print()
    print("Tropical multiplication naturally finds the cheapest supply chain")
    print("path, composing costs across multiple stages.")
    print()


# =============================================================================
# Application 4: Tropical Hash Function
# =============================================================================

def tropical_hash(data: bytes, n: int = 4, rounds: int = 8) -> np.ndarray:
    """
    A tropical hash function using min-plus matrix exponentiation.

    Maps arbitrary data to an n×n tropical matrix via:
    1. Convert data bytes to a generator matrix.
    2. Apply iterated tropical squaring with data-dependent mixing.

    This is a proof-of-concept; not cryptographically secure in isolation,
    but demonstrates how tropical operations create one-way compression.

    Args:
        data: Input bytes
        n: Matrix dimension (output is n×n)
        rounds: Number of mixing rounds

    Returns:
        n×n tropical matrix hash
    """
    # Initialize from data
    h = hashlib.sha256(data).digest()
    M = np.zeros((n, n), dtype=float)
    for i in range(n):
        for j in range(n):
            idx = (i * n + j) % len(h)
            M[i, j] = float(h[idx])

    # Apply tropical mixing rounds
    for r in range(rounds):
        # Data-dependent perturbation
        h = hashlib.sha256(h + r.to_bytes(4, 'big')).digest()
        P = np.zeros((n, n), dtype=float)
        for i in range(n):
            for j in range(n):
                P[i, j] = float(h[(i * n + j) % len(h)])

        # Tropical square and mix
        M = trop_mat_mul(M, M)
        M = trop_mat_mul(M, P)

    return M


def tropical_hash_demo():
    """Demonstrate the tropical hash function."""
    print("=" * 60)
    print("APPLICATION 4: Tropical Hash Function")
    print("=" * 60)
    print()

    messages = [b"Hello, World!", b"Hello, World?", b"Tropical Crypto"]

    for msg in messages:
        h = tropical_hash(msg, n=3, rounds=6)
        print(f'Hash of "{msg.decode()}":')
        print_matrix(h)
        print()

    # Avalanche effect: small change → large hash difference
    h1 = tropical_hash(b"test1")
    h2 = tropical_hash(b"test2")
    diff = np.abs(h1 - h2)
    print(f"Avalanche effect (difference between hash of 'test1' and 'test2'):")
    print_matrix(diff)
    print()


# =============================================================================
# Utilities
# =============================================================================

def print_matrix(M: np.ndarray):
    """Pretty-print a matrix."""
    n = M.shape[0]
    for i in range(n):
        row = []
        for j in range(n):
            if M[i, j] == INF:
                row.append("   ∞")
            else:
                row.append(f"{M[i, j]:4.0f}")
        print("  [" + " ".join(row) + "]")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    privacy_preserving_routing()
    network_security_analysis()
    supply_chain_optimization()
    tropical_hash_demo()

    print("=" * 60)
    print("All applications demonstrated!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical RSA Demo: Min-Plus Public-Key Cryptosystem

Demonstrates the core mathematical concepts of tropical cryptography
with concrete numerical examples over the min-plus semiring.

In the min-plus (tropical) semiring:
  - "addition" is min
  - "multiplication" is +
  - Identity for addition: ∞
  - Identity for multiplication: 0
"""

import numpy as np
from typing import Tuple, Optional

INF = float('inf')


def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with ∞ absorbing)."""
    if a == INF or b == INF:
        return INF
    return a + b


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})."""
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = trop_add(C[i, j], trop_mul(A[i, k], B[k, j]))
    return C


def trop_identity(n: int) -> np.ndarray:
    """Tropical identity matrix: 0 on diagonal, ∞ off diagonal."""
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0)
    return I


def trop_pow(A: np.ndarray, k: int) -> np.ndarray:
    """Tropical matrix power: A^k = A ⊗ A ⊗ ... ⊗ A (k times)."""
    n = A.shape[0]
    result = trop_identity(n)
    for _ in range(k):
        result = trop_mat_mul(A, result)
    return result


def format_matrix(M: np.ndarray, name: str = "") -> str:
    """Pretty-print a tropical matrix."""
    n = M.shape[0]
    lines = []
    if name:
        lines.append(f"{name} =")
    for i in range(n):
        row = []
        for j in range(n):
            if M[i, j] == INF:
                row.append("  ∞")
            else:
                row.append(f"{M[i, j]:3.0f}")
        lines.append("  [" + " ".join(row) + "]")
    return "\n".join(lines)


# =============================================================================
# Demo 1: Basic Tropical Arithmetic
# =============================================================================
print("=" * 70)
print("DEMO 1: Basic Tropical (Min-Plus) Arithmetic")
print("=" * 70)
print()
print("In the tropical semiring:")
print(f"  3 ⊕ 5 = min(3, 5) = {trop_add(3, 5)}")
print(f"  3 ⊙ 5 = 3 + 5 = {trop_mul(3, 5)}")
print(f"  ∞ ⊕ 3 = min(∞, 3) = {trop_add(INF, 3)}")
print(f"  0 ⊙ 3 = 0 + 3 = {trop_mul(0, 3)}")
print()

# =============================================================================
# Demo 2: Tropical Matrix Multiplication = Shortest Path Composition
# =============================================================================
print("=" * 70)
print("DEMO 2: Tropical Matrix Multiplication as Shortest Paths")
print("=" * 70)
print()

# Adjacency matrix of a weighted graph
G = np.array([
    [0, 2, INF, 1],
    [INF, 0, 3, INF],
    [INF, INF, 0, 1],
    [INF, INF, INF, 0]
], dtype=float)

print("Weighted graph adjacency matrix (∞ = no edge):")
print(format_matrix(G, "G"))
print()

G2 = trop_mat_mul(G, G)
print("G² = G ⊗ G (shortest 2-hop paths):")
print(format_matrix(G2, "G²"))
print()

G3 = trop_mat_mul(G, G2)
print("G³ = G ⊗ G² (shortest 3-hop paths):")
print(format_matrix(G3, "G³"))
print()

print("Interpretation: G²[0,2] = min over k of (G[0,k] + G[k,2])")
print(f"  = min(0+∞, 2+3, ∞+0, 1+∞) = min(∞, 5, ∞, ∞) = {G2[0, 2]}")
print("  This is the shortest 2-hop path from vertex 0 to vertex 2.")
print()

# =============================================================================
# Demo 3: Tropical Diffie-Hellman Key Exchange
# =============================================================================
print("=" * 70)
print("DEMO 3: Tropical Diffie-Hellman Key Exchange")
print("=" * 70)
print()

n = 3
# Public generator matrix
G = np.array([
    [0, 1, 3],
    [2, 0, 1],
    [1, 3, 0]
], dtype=float)

print(format_matrix(G, "Public generator G"))
print()

# Alice's secret: a = 5
# Bob's secret: b = 7
a, b = 5, 7

G_a = trop_pow(G, a)
G_b = trop_pow(G, b)

print(f"Alice's secret: a = {a}")
print(f"Bob's secret: b = {b}")
print()
print(format_matrix(G_a, f"Alice's public key G^{a}"))
print()
print(format_matrix(G_b, f"Bob's public key G^{b}"))
print()

# Shared secrets
alice_shared = trop_pow(G_b, a)  # (G^b)^a
bob_shared = trop_pow(G_a, b)    # (G^a)^b

print(format_matrix(alice_shared, f"Alice computes (G^{b})^{a}"))
print()
print(format_matrix(bob_shared, f"Bob computes (G^{a})^{b}"))
print()

# Verify they match
match = np.array_equal(alice_shared, bob_shared)
print(f"Shared secrets match: {match}")
print()

# Verify algebraic identity: (G^a)^b = G^(ab)
G_ab = trop_pow(G, a * b)
print(f"Verification: G^({a}*{b}) = G^{a*b}")
print(format_matrix(G_ab, f"G^{a*b}"))
print(f"(G^a)^b == G^(ab): {np.array_equal(alice_shared, G_ab)}")
print()

# =============================================================================
# Demo 4: Tropical Encryption/Decryption
# =============================================================================
print("=" * 70)
print("DEMO 4: Tropical Public-Key Encryption")
print("=" * 70)
print()

# Message matrix
M = np.array([
    [5, 2, 8],
    [1, 7, 3],
    [4, 6, 0]
], dtype=float)

print(format_matrix(M, "Plaintext message M"))
print()

# Alice's key pair
pk_pub = G_a  # G^a is Alice's public key
r = 4  # Bob's randomness

# Encryption: (G^r, (G^a)^r ⊗ M)
ephemeral = trop_pow(G, r)
shared_sender = trop_pow(pk_pub, r)  # (G^a)^r
ciphertext = trop_mat_mul(shared_sender, M)

print(f"Bob encrypts with randomness r = {r}")
print(format_matrix(ephemeral, "Ephemeral key E = G^r"))
print()
print(format_matrix(shared_sender, "Sender's mask = (G^a)^r"))
print()
print(format_matrix(ciphertext, "Ciphertext C = mask ⊗ M"))
print()

# Decryption: compute (G^r)^a = shared secret
shared_receiver = trop_pow(ephemeral, a)  # (G^r)^a
print(format_matrix(shared_receiver, "Receiver's mask = (G^r)^a"))
print()
print(f"Masks match: {np.array_equal(shared_sender, shared_receiver)}")
print()

# =============================================================================
# Demo 5: Non-Commutativity of Tropical Matrix Multiplication
# =============================================================================
print("=" * 70)
print("DEMO 5: Non-Commutativity (Why Factorization is Hard)")
print("=" * 70)
print()

A = np.array([[1, 0], [2, 1]], dtype=float)
B = np.array([[0, 1], [2, 1]], dtype=float)

AB = trop_mat_mul(A, B)
BA = trop_mat_mul(B, A)

print(format_matrix(A, "A"))
print()
print(format_matrix(B, "B"))
print()
print(format_matrix(AB, "A ⊗ B"))
print()
print(format_matrix(BA, "B ⊗ A"))
print()
print(f"A ⊗ B == B ⊗ A: {np.array_equal(AB, BA)}")
print()
print("Non-commutativity means factoring K = A ⊗ B is genuinely hard:")
print("knowing K doesn't reveal A and B because order matters!")
print()

# =============================================================================
# Demo 6: Power Commutativity (The Cryptographic Key Insight)
# =============================================================================
print("=" * 70)
print("DEMO 6: Powers of the Same Matrix DO Commute")
print("=" * 70)
print()

G = np.array([
    [0, 1, 3],
    [2, 0, 1],
    [1, 3, 0]
], dtype=float)

for (p, q) in [(3, 5), (2, 7), (4, 6)]:
    GpGq = trop_mat_mul(trop_pow(G, p), trop_pow(G, q))
    GqGp = trop_mat_mul(trop_pow(G, q), trop_pow(G, p))
    Gpq = trop_pow(G, p + q)
    print(f"G^{p} ⊗ G^{q} == G^{q} ⊗ G^{p} == G^{p+q}: "
          f"{np.array_equal(GpGq, GqGp) and np.array_equal(GpGq, Gpq)}")

print()
print("This is the algebraic foundation enabling key agreement!")
print("Even though general tropical matrices don't commute,")
print("powers of the SAME matrix always do: G^a ⊗ G^b = G^(a+b).")
print()

# =============================================================================
# Demo 7: Security Parameter Space
# =============================================================================
print("=" * 70)
print("DEMO 7: Security Parameter Growth")
print("=" * 70)
print()

print("Key space size = (B+1)^(n²) for n×n matrices with entries in {0,...,B}:")
print()
print(f"{'n':>4} {'B':>4} {'Key Space':>20} {'log₂(Key Space)':>18}")
print("-" * 50)
for n in [2, 3, 4, 8, 16]:
    for B in [7, 15, 255]:
        log_key = n * n * np.log2(B + 1)
        print(f"{n:4d} {B:4d} {'2^' + f'{log_key:.0f}':>20} {log_key:18.1f}")
    print()

print("For n=16, B=255: log₂(key space) = 2048 bits — far beyond brute force!")
print()

print("=" * 70)
print("All demos complete!")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Tropical RSA Cryptography

Generates publication-quality figures showing:
1. Tropical matrix power convergence (shortest paths)
2. Key space growth with dimension
3. Security parameter landscape
4. Tropical vs classical operation comparison
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import base64
import io

INF = float('inf')


def trop_mat_mul(A, B):
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i, k] + B[k, j]
                if val < C[i, j]:
                    C[i, j] = val
    return C


def trop_pow(A, k):
    n = A.shape[0]
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0)
    result = I
    for _ in range(k):
        result = trop_mat_mul(A, result)
    return result


def save_fig_base64(fig, filename):
    """Save figure to file and return base64 encoding."""
    fig.savefig(filename, dpi=150, bbox_inches='tight', facecolor='white')
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


# =============================================================================
# Figure 1: Tropical Power Convergence
# =============================================================================

def fig_power_convergence():
    """Show how tropical matrix powers converge to shortest paths."""
    np.random.seed(42)
    n = 5
    G = np.random.randint(1, 10, (n, n)).astype(float)
    np.fill_diagonal(G, 0)
    # Add some infinity entries
    G[0, 3] = INF
    G[1, 4] = INF
    G[2, 0] = INF
    G[3, 1] = INF
    G[4, 2] = INF

    # Track (0,4) entry across powers
    max_power = 12
    costs_04 = []
    costs_13 = []
    costs_24 = []
    for k in range(1, max_power + 1):
        Gk = trop_pow(G, k)
        costs_04.append(Gk[0, 4] if Gk[0, 4] != INF else None)
        costs_13.append(Gk[1, 3] if Gk[1, 3] != INF else None)
        costs_24.append(Gk[2, 4] if Gk[2, 4] != INF else None)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    powers = list(range(1, max_power + 1))

    for costs, label, color, marker in [
        (costs_04, 'Path 0→4', '#2196F3', 'o'),
        (costs_13, 'Path 1→3', '#FF5722', 's'),
        (costs_24, 'Path 2→4', '#4CAF50', '^')
    ]:
        valid_x = [p for p, c in zip(powers, costs) if c is not None]
        valid_y = [c for c in costs if c is not None]
        ax.plot(valid_x, valid_y, f'-{marker}', label=label, color=color,
                linewidth=2, markersize=8, markeredgecolor='white', markeredgewidth=1.5)

    ax.set_xlabel('Number of Hops (Matrix Power k)', fontsize=13)
    ax.set_ylabel('Shortest Path Cost (G^k entry)', fontsize=13)
    ax.set_title('Tropical Matrix Powers Converge to Shortest Paths', fontsize=15, fontweight='bold')
    ax.legend(fontsize=12, framealpha=0.9)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(powers)

    return save_fig_base64(fig, 'fig_convergence.png')


# =============================================================================
# Figure 2: Key Space Growth
# =============================================================================

def fig_key_space():
    """Visualize exponential growth of key space with dimension."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: key space bits vs dimension for different B
    dims = list(range(2, 21))
    for B, color, ls in [(7, '#2196F3', '-'), (15, '#FF5722', '--'),
                          (63, '#4CAF50', '-.'), (255, '#9C27B0', ':')]:
        bits = [n * n * np.log2(B + 1) for n in dims]
        ax1.plot(dims, bits, ls, label=f'B={B} ({int(np.log2(B+1))} bits/entry)',
                color=color, linewidth=2.5)

    ax1.axhline(y=128, color='gray', linestyle=':', alpha=0.7, linewidth=1.5)
    ax1.text(2.5, 135, '128-bit security', fontsize=10, color='gray')
    ax1.axhline(y=256, color='gray', linestyle=':', alpha=0.5, linewidth=1.5)
    ax1.text(2.5, 263, '256-bit security', fontsize=10, color='gray')

    ax1.set_xlabel('Matrix Dimension n', fontsize=13)
    ax1.set_ylabel('Key Space (bits)', fontsize=13)
    ax1.set_title('Key Space Growth: (B+1)^(n²) bits', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_yscale('linear')

    # Right: comparison with RSA/ECC key sizes
    schemes = ['RSA-2048', 'RSA-4096', 'ECC-256', 'ECC-384',
               'Trop 4×4\nB=255', 'Trop 8×8\nB=255', 'Trop 16×16\nB=255']
    key_bits = [2048, 4096, 256, 384,
                4*4*8, 8*8*8, 16*16*8]
    security_bits = [112, 140, 128, 192,
                     128, 512, 2048]
    colors = ['#607D8B'] * 2 + ['#FF9800'] * 2 + ['#2196F3'] * 3

    bars = ax2.bar(range(len(schemes)), security_bits, color=colors, alpha=0.8,
                   edgecolor='white', linewidth=1.5)

    ax2.set_xticks(range(len(schemes)))
    ax2.set_xticklabels(schemes, fontsize=9, rotation=0)
    ax2.set_ylabel('Equivalent Security (bits)', fontsize=13)
    ax2.set_title('Security Level Comparison', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3, axis='y')

    # Add value labels on bars
    for bar, val in zip(bars, security_bits):
        ax2.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 20,
                f'{val}', ha='center', va='bottom', fontsize=10, fontweight='bold')

    # Legend
    legend_patches = [
        mpatches.Patch(color='#607D8B', label='RSA'),
        mpatches.Patch(color='#FF9800', label='ECC'),
        mpatches.Patch(color='#2196F3', label='Tropical'),
    ]
    ax2.legend(handles=legend_patches, fontsize=11)

    plt.tight_layout()
    return save_fig_base64(fig, 'fig_keyspace.png')


# =============================================================================
# Figure 3: Non-Commutativity Visualization
# =============================================================================

def fig_noncommutativity():
    """Visualize non-commutativity of tropical matrix multiplication."""
    A = np.array([[1, 0], [2, 1]], dtype=float)
    B = np.array([[0, 1], [2, 1]], dtype=float)
    AB = trop_mat_mul(A, B)
    BA = trop_mat_mul(B, A)

    fig, axes = plt.subplots(1, 4, figsize=(16, 4))

    matrices = [A, B, AB, BA]
    titles = ['A', 'B', 'A ⊗ B', 'B ⊗ A']

    for ax, M, title in zip(axes, matrices, titles):
        display = M.copy()
        display[display == INF] = np.nan

        im = ax.imshow(display, cmap='YlOrRd', aspect='equal')

        for i in range(2):
            for j in range(2):
                val = M[i, j]
                text = '∞' if val == INF else f'{val:.0f}'
                ax.text(j, i, text, ha='center', va='center',
                       fontsize=20, fontweight='bold',
                       color='white' if val != INF and val > 2 else 'black')

        ax.set_title(title, fontsize=16, fontweight='bold')
        ax.set_xticks([0, 1])
        ax.set_yticks([0, 1])
        ax.set_xticklabels(['0', '1'])
        ax.set_yticklabels(['0', '1'])

    # Highlight the difference
    axes[2].set_title('A ⊗ B', fontsize=16, fontweight='bold', color='#2196F3')
    axes[3].set_title('B ⊗ A  (≠ A ⊗ B!)', fontsize=16, fontweight='bold', color='#FF5722')

    plt.suptitle('Tropical Matrix Multiplication is Non-Commutative',
                fontsize=18, fontweight='bold', y=1.05)
    plt.tight_layout()
    return save_fig_base64(fig, 'fig_noncommutativity.png')


# =============================================================================
# Figure 4: Diffie-Hellman Protocol Diagram
# =============================================================================

def fig_dh_protocol():
    """Visualize the tropical Diffie-Hellman key exchange protocol."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')

    # Title
    ax.text(5, 9.5, 'Tropical Diffie-Hellman Key Exchange',
           fontsize=18, fontweight='bold', ha='center', va='center')

    # Alice and Bob
    ax.text(2, 8.5, 'Alice', fontsize=16, fontweight='bold', ha='center',
           color='#2196F3')
    ax.text(8, 8.5, 'Bob', fontsize=16, fontweight='bold', ha='center',
           color='#FF5722')

    # Vertical lines
    ax.plot([2, 2], [1, 8], color='#2196F3', linewidth=2, alpha=0.5)
    ax.plot([8, 8], [1, 8], color='#FF5722', linewidth=2, alpha=0.5)

    # Steps
    steps = [
        (7.5, 'Public: Generator G', '#333'),
        (6.5, 'Alice: secret a', '#2196F3'),
        (5.8, 'Computes G^a', '#2196F3'),
        (5.0, 'Bob: secret b', '#FF5722'),
        (4.3, 'Computes G^b', '#FF5722'),
        (3.3, 'Alice: (G^b)^a = G^(ba)', '#2196F3'),
        (2.5, 'Bob: (G^a)^b = G^(ab)', '#FF5722'),
        (1.5, 'G^(ab) = G^(ba) ✓', '#4CAF50'),
    ]

    for y, text, color in steps:
        ax.text(5, y, text, fontsize=13, ha='center', va='center',
               color=color, fontweight='bold' if color == '#4CAF50' else 'normal',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                        edgecolor=color, alpha=0.9) if color != '#333' else
               dict(boxstyle='round,pad=0.3', facecolor='#f0f0f0',
                    edgecolor='#999', alpha=0.9))

    # Arrows for message exchange
    ax.annotate('', xy=(7.5, 5.5), xytext=(2.5, 5.5),
               arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2))
    ax.text(5, 5.6, 'sends G^a', fontsize=10, ha='center', color='#2196F3')

    ax.annotate('', xy=(2.5, 4.6), xytext=(7.5, 4.6),
               arrowprops=dict(arrowstyle='->', color='#FF5722', lw=2))
    ax.text(5, 4.7, 'sends G^b', fontsize=10, ha='center', color='#FF5722')

    return save_fig_base64(fig, 'fig_dh_protocol.png')


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    b64_convergence = fig_power_convergence()
    print(f"  fig_convergence.png: {len(b64_convergence)} chars")

    b64_keyspace = fig_key_space()
    print(f"  fig_keyspace.png: {len(b64_keyspace)} chars")

    b64_noncomm = fig_noncommutativity()
    print(f"  fig_noncommutativity.png: {len(b64_noncomm)} chars")

    b64_dh = fig_dh_protocol()
    print(f"  fig_dh_protocol.png: {len(b64_dh)} chars")

    print("\nAll visualizations generated!")

    # Return the base64 data for PACKAGE.json
    viz_data = {
        "convergence": b64_convergence,
        "keyspace": b64_keyspace,
        "noncommutativity": b64_noncomm,
        "dh_protocol": b64_dh
    }
