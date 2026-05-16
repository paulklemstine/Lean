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
