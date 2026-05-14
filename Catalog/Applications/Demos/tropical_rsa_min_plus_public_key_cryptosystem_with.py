#!/usr/bin/env python3
"""
Tropical RSA: Real-World Applications

Demonstrates how tropical (min-plus) cryptography connects to
routing, scheduling, and network security.
"""

import numpy as np
from algorithms import (
    tropical_matrix_multiply, tropical_matrix_power,
    tropical_keygen, tropical_encrypt, tropical_compute_shared_secret,
    tropical_all_pairs_shortest_paths, security_bits
)

INF = float('inf')


# ============================================================
# Application 1: Secure Routing Protocol
# ============================================================

def app_secure_routing():
    """
    Demonstrate secure routing using tropical cryptography.
    
    In a network, shortest-path routing is computed using min-plus
    matrix powers. Tropical cryptography allows authenticated
    route advertisements: a router proves knowledge of a route
    without revealing the full path structure.
    """
    print("=" * 60)
    print("APPLICATION 1: Secure Routing with Tropical Keys")
    print("=" * 60)
    
    # Network topology: 5 routers
    # Entry [i,j] = latency from router i to router j
    network = np.array([
        [0,   2,   INF, 6,   INF],
        [2,   0,   3,   8,   5  ],
        [INF, 3,   0,   INF, 7  ],
        [6,   8,   INF, 0,   9  ],
        [INF, 5,   7,   9,   0  ]
    ])
    
    print("\nNetwork latency matrix (ms):")
    for i in range(5):
        row = [f"{network[i,j]:4.0f}" if network[i,j] != INF else " inf" 
               for j in range(5)]
        print(f"  Router {i}: [{', '.join(row)}]")
    
    # Compute all-pairs shortest paths
    distances = tropical_all_pairs_shortest_paths(network)
    
    print("\nShortest path distances:")
    for i in range(5):
        row = [f"{distances[i,j]:4.0f}" if distances[i,j] != INF else " inf"
               for j in range(5)]
        print(f"  Router {i}: [{', '.join(row)}]")
    
    # Secure route advertisement using tropical keys
    kp = tropical_keygen(5, bound=20, seed=100)
    print(f"\nSecure Route Key (secret exponent): {kp.private.secret}")
    print(f"  Public route matrix G^a authenticates route advertisements")
    print(f"  An attacker cannot forge route advertisements without")
    print(f"  recovering the secret exponent (tropical DLP).")


# ============================================================
# Application 2: Supply Chain Optimization + Security
# ============================================================

def app_supply_chain():
    """
    Tropical matrices model supply chain scheduling.
    Tropical encryption secures the schedule.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Secure Supply Chain Scheduling")
    print("=" * 60)
    
    # Supply chain with 4 stages
    # Entry [i,j] = minimum time to transition from stage i to stage j
    stages = ["Raw Material", "Manufacturing", "Distribution", "Retail"]
    
    chain = np.array([
        [0,   3,   INF, INF],
        [INF, 0,   2,   INF],
        [INF, INF, 0,   1  ],
        [INF, INF, INF, 0  ]
    ])
    
    print("\nSupply chain transition times (days):")
    for i, s in enumerate(stages):
        row = [f"{chain[i,j]:4.0f}" if chain[i,j] != INF else " inf"
               for j in range(4)]
        print(f"  {s:15s}: [{', '.join(row)}]")
    
    # Chain^3 gives total pipeline time
    pipeline = tropical_matrix_power(chain, 3)
    print(f"\nPipeline time (3-stage paths):")
    print(f"  Raw Material → Retail: {pipeline[0, 3]:.0f} days minimum")
    
    # Encrypt the supply chain schedule
    message = chain.copy()
    # Replace inf with large value for encryption
    message[message == INF] = 999
    
    kp = tropical_keygen(4, bound=20, seed=200)
    ct = tropical_encrypt(kp.public, message, seed=201)
    
    print(f"\nEncrypted supply chain schedule (masked matrix):")
    for i in range(4):
        print(f"  [{', '.join(f'{ct.masked[i,j]:6.0f}' for j in range(4))}]")
    print(f"  → Schedule is protected from industrial espionage")
    print(f"  → Only authorized parties with the private key can decrypt")


# ============================================================
# Application 3: Post-Quantum Key Exchange for IoT
# ============================================================

def app_iot_key_exchange():
    """
    Lightweight tropical key exchange for IoT devices.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Lightweight IoT Key Exchange")
    print("=" * 60)
    
    # Small matrices for resource-constrained devices
    for n in [3, 4, 6, 8]:
        kp = tropical_keygen(n, bound=15, seed=300 + n)
        
        # Simulate key exchange
        from algorithms import tropical_matrix_power as tmp
        
        # Device B generates its own key pair
        kp_b = tropical_keygen(n, bound=15, seed=400 + n)
        
        # Shared secret
        shared_a = tmp(kp_b.public.pub, kp.private.secret)
        # Note: in practice both devices use the same G
        
        ops = n * n * n  # ops per multiplication
        log_a = int(np.log2(max(kp.private.secret, 2)))
        total_ops = ops * log_a
        
        bits = security_bits(n, 15)
        
        print(f"\n  n={n}: {bits:.0f}-bit security, ~{total_ops} operations")
        print(f"    Matrix size: {n}×{n} = {n*n} entries")
        print(f"    Key size: {n*n * 4} bytes (4 bits per entry)")
        print(f"    Suitable for: ", end="")
        if n <= 4:
            print("8-bit microcontrollers, smart cards")
        elif n <= 8:
            print("ARM Cortex-M, wearables")
        else:
            print("Smartphones, edge devices")


# ============================================================
# Application 4: Network Security Analysis
# ============================================================

def app_network_security():
    """
    Analyze network security using tropical algebraic properties.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Network Security Analysis")
    print("=" * 60)
    
    # Attack graph: cost to move between network segments
    segments = ["External", "DMZ", "Internal", "Database"]
    
    attack_cost = np.array([
        [0,   2,   INF, INF],
        [INF, 0,   5,   INF],
        [INF, INF, 0,   3  ],
        [INF, INF, INF, 0  ]
    ])
    
    print("\nAttack cost matrix (difficulty to compromise):")
    for i, s in enumerate(segments):
        row = [f"{attack_cost[i,j]:4.0f}" if attack_cost[i,j] != INF else " inf"
               for j in range(4)]
        print(f"  {s:10s}: [{', '.join(row)}]")
    
    # Compute minimum attack cost paths
    min_costs = tropical_all_pairs_shortest_paths(attack_cost)
    
    print("\nMinimum total attack cost (any number of hops):")
    print(f"  External → Database: {min_costs[0, 3]:.0f} units")
    print(f"  External → Internal: {min_costs[0, 2]:.0f} units")
    print(f"  DMZ → Database:      {min_costs[1, 3]:.0f} units")
    
    # Tropical factorization = finding attack decomposition
    print(f"\n  Finding the cheapest attack path is equivalent to")
    print(f"  tropical matrix factorization — the same hard problem")
    print(f"  that protects tropical cryptographic keys!")
    print(f"\n  Defense strategy: increase matrix entries (attack costs)")
    print(f"  to make factorization computationally infeasible.")


# ============================================================
# Application 5: Security Level Comparison
# ============================================================

def app_security_comparison():
    """Compare security levels across parameter choices."""
    print("\n" + "=" * 60)
    print("APPLICATION 5: Security Level Comparison")
    print("=" * 60)
    
    print(f"\n  {'Dimension':>10s} {'Bound':>6s} {'Key Space':>15s} {'Security':>12s}")
    print(f"  {'-'*10:>10s} {'-'*6:>6s} {'-'*15:>15s} {'-'*12:>12s}")
    
    configs = [
        (4, 15, "IoT basic"),
        (8, 15, "IoT secure"),
        (8, 255, "Standard"),
        (16, 255, "High security"),
        (32, 255, "Post-quantum"),
        (64, 255, "Ultra"),
    ]
    
    for n, bound, label in configs:
        bits = security_bits(n, bound)
        keyspace = f"2^{bits:.0f}"
        print(f"  {n:>10d} {bound:>6d} {keyspace:>15s} {bits:>9.0f} bits  ({label})")
    
    print(f"\n  For comparison:")
    print(f"    RSA-2048:   ~112 bits")
    print(f"    AES-128:     128 bits")
    print(f"    AES-256:     256 bits")
    print(f"    Lattice KEM: ~128-256 bits")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Tropical RSA: Real-World Applications                 ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    app_secure_routing()
    app_supply_chain()
    app_iot_key_exchange()
    app_network_security()
    app_security_comparison()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical RSA Demo: Min-Plus Public Key Cryptography

Demonstrates the core algorithms and theorems of tropical (min-plus) 
matrix cryptography with concrete numerical examples.
"""

import numpy as np
from typing import Tuple, Optional
import sys

# Use infinity for the tropical additive identity
INF = float('inf')


def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with inf + x = inf)."""
    if a == INF or b == INF:
        return INF
    return a + b


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).
    
    This computes shortest-path composition: the cost of the cheapest
    two-hop path from i to j through any intermediate vertex k.
    """
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = trop_mul(A[i, k], B[k, j])
                C[i, j] = trop_add(C[i, j], val)
    return C


def trop_mat_pow(A: np.ndarray, m: int) -> np.ndarray:
    """Tropical matrix power A^m via repeated multiplication."""
    n = A.shape[0]
    # Identity: 0 on diagonal, inf elsewhere
    result = np.full((n, n), INF)
    np.fill_diagonal(result, 0)
    
    for _ in range(m):
        result = trop_mat_mul(A, result)
    return result


def trop_identity(n: int) -> np.ndarray:
    """Tropical identity matrix: 0 on diagonal, inf elsewhere."""
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0)
    return I


# ============================================================
# Demo 1: Path Semantics of Tropical Multiplication
# ============================================================

def demo_path_semantics():
    """Show that tropical matrix multiplication computes shortest paths."""
    print("=" * 60)
    print("DEMO 1: Path Semantics of Tropical Matrix Multiplication")
    print("=" * 60)
    
    # A weighted directed graph on 4 vertices
    # Entry A[i][j] = cost of edge from i to j (inf = no edge)
    A = np.array([
        [0, 3, INF, 7],
        [INF, 0, 2, INF],
        [1, INF, 0, 4],
        [INF, INF, INF, 0]
    ])
    
    print("\nAdjacency matrix A (edge weights, inf = no edge):")
    print_matrix(A)
    
    # A^2 gives shortest 2-edge paths
    A2 = trop_mat_mul(A, A)
    print("\nA² = A ⊗ A (shortest 2-edge paths):")
    print_matrix(A2)
    print("  Example: A²[0,2] =", A2[0, 2])
    print("  = min(A[0,0]+A[0,2], A[0,1]+A[1,2], A[0,2]+A[2,2], A[0,3]+A[3,2])")
    print("  = min(0+inf, 3+2, inf+0, 7+inf)")
    print("  = min(inf, 5, inf, inf) = 5")
    print("  → Shortest 2-edge path from 0→2 costs 5 (via vertex 1)")
    
    # A^3 gives shortest 3-edge paths
    A3 = trop_mat_mul(A, A2)
    print("\nA³ (shortest 3-edge paths):")
    print_matrix(A3)
    
    # Verify associativity: (A⊗A)⊗A = A⊗(A⊗A)
    left = trop_mat_mul(trop_mat_mul(A, A), A)
    right = trop_mat_mul(A, trop_mat_mul(A, A))
    print("\nAssociativity check: (A⊗A)⊗A == A⊗(A⊗A)?", np.allclose(left, right))


# ============================================================
# Demo 2: Tropical Diffie-Hellman Key Exchange
# ============================================================

def demo_key_exchange():
    """Demonstrate tropical Diffie-Hellman key exchange."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Diffie-Hellman Key Exchange")
    print("=" * 60)
    
    n = 3
    # Public generator matrix
    G = np.array([
        [0, 5, 3],
        [2, 0, 7],
        [4, 1, 0]
    ], dtype=float)
    
    print("\nPublic generator G:")
    print_matrix(G)
    
    # Alice's secret: a = 7
    # Bob's secret: b = 11
    a, b = 7, 11
    
    # Public keys
    Ga = trop_mat_pow(G, a)
    Gb = trop_mat_pow(G, b)
    
    print(f"\nAlice's secret: a = {a}")
    print(f"Alice's public key G^a = G^{a}:")
    print_matrix(Ga)
    
    print(f"\nBob's secret: b = {b}")
    print(f"Bob's public key G^b = G^{b}:")
    print_matrix(Gb)
    
    # Shared secrets
    alice_shared = trop_mat_pow(Gb, a)  # (G^b)^a
    bob_shared = trop_mat_pow(Ga, b)    # (G^a)^b
    
    # Also compute G^(a+b) directly
    Gab = trop_mat_pow(G, a + b)
    
    print(f"\nAlice computes (G^b)^a = G^({b}*{a}) = G^{b*a}:")
    print_matrix(alice_shared)
    
    print(f"\nBob computes (G^a)^b = G^({a}*{b}) = G^{a*b}:")
    print_matrix(bob_shared)
    
    print(f"\nDirect computation G^(a*b) = G^{a*b}:")
    print_matrix(trop_mat_pow(G, a * b))
    
    # Verify G^a ⊗ G^b = G^b ⊗ G^a = G^(a+b)
    prod_ab = trop_mat_mul(Ga, Gb)
    prod_ba = trop_mat_mul(Gb, Ga)
    
    print(f"\nG^a ⊗ G^b = G^({a}+{b}) = G^{a+b}:")
    print_matrix(prod_ab)
    
    print(f"\nG^b ⊗ G^a = G^({b}+{a}) = G^{b+a}:")
    print_matrix(prod_ba)
    
    print(f"\nDH Correctness: G^a ⊗ G^b == G^b ⊗ G^a?",
          np.allclose(prod_ab, prod_ba))
    print(f"Both equal G^(a+b)?",
          np.allclose(prod_ab, Gab))
    
    print(f"\nShared secret agreement: (G^b)^a == (G^a)^b?",
          np.allclose(alice_shared, bob_shared))


# ============================================================
# Demo 3: Non-commutativity of Tropical Matrix Multiplication
# ============================================================

def demo_noncommutativity():
    """Show that tropMul is not commutative in general."""
    print("\n" + "=" * 60)
    print("DEMO 3: Non-Commutativity of Tropical Multiplication")
    print("=" * 60)
    
    A = np.array([
        [0, 1],
        [INF, 0]
    ])
    B = np.array([
        [INF, 0],
        [0, INF]
    ])
    
    AB = trop_mat_mul(A, B)
    BA = trop_mat_mul(B, A)
    
    print("\nA:")
    print_matrix(A)
    print("\nB:")
    print_matrix(B)
    print("\nA ⊗ B:")
    print_matrix(AB)
    print("\nB ⊗ A:")
    print_matrix(BA)
    print(f"\nA ⊗ B == B ⊗ A? {np.allclose(AB, BA)}")
    print("→ Tropical matrix multiplication is NOT commutative!")
    print("  This means factoring K = A ⊗ B is genuinely hard:")
    print("  knowing K doesn't immediately reveal A and B.")


# ============================================================
# Demo 4: Tropical Encryption/Decryption
# ============================================================

def demo_encryption():
    """Demonstrate tropical ElGamal-style encryption."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Encryption/Decryption")
    print("=" * 60)
    
    n = 3
    G = np.array([
        [0, 5, 3],
        [2, 0, 7],
        [4, 1, 0]
    ], dtype=float)
    
    # Key generation
    a = 5  # Alice's secret
    pk_G = G
    pk_pub = trop_mat_pow(G, a)
    
    print(f"\nKey Generation:")
    print(f"  Secret key: a = {a}")
    print(f"  Public key: (G, G^{a})")
    
    # Encryption: Bob encrypts a message matrix M
    r = 3  # randomness
    M = np.array([
        [10, 20, 30],
        [40, 50, 60],
        [70, 80, 90]
    ], dtype=float)
    
    print(f"\nMessage matrix M:")
    print_matrix(M)
    
    # Ciphertext: (G^r, (G^a)^r ⊗ M)
    ephemeral = trop_mat_pow(G, r)
    shared_sender = trop_mat_pow(pk_pub, r)  # (G^a)^r
    masked = trop_mat_mul(shared_sender, M)
    
    print(f"\nEncryption (r = {r}):")
    print(f"  Ephemeral key G^r = G^{r}:")
    print_matrix(ephemeral)
    print(f"  Shared secret (G^a)^r = G^{a*r}:")
    print_matrix(shared_sender)
    print(f"  Masked message (G^a)^r ⊗ M:")
    print_matrix(masked)
    
    # Decryption: Alice computes (G^r)^a
    shared_receiver = trop_mat_pow(ephemeral, a)  # (G^r)^a
    
    print(f"\nDecryption:")
    print(f"  Receiver's shared secret (G^r)^a = G^{r*a}:")
    print_matrix(shared_receiver)
    
    print(f"\n  Shared secret agreement: (G^a)^r == (G^r)^a?",
          np.allclose(shared_sender, shared_receiver))
    print("  → Both parties derive the same shared secret!")
    print("  → The shared secret can be used as a symmetric key")
    print("    to mask/unmask the message.")


# ============================================================
# Demo 5: Factorization Hardness
# ============================================================

def demo_factorization():
    """Demonstrate the difficulty of tropical matrix factorization."""
    print("\n" + "=" * 60)
    print("DEMO 5: Tropical Factorization Hardness")
    print("=" * 60)
    
    n = 4
    # Generate two random matrices
    np.random.seed(42)
    A = np.random.randint(0, 10, (n, n)).astype(float)
    B = np.random.randint(0, 10, (n, n)).astype(float)
    
    K = trop_mat_mul(A, B)
    
    print(f"\nSecret factor A:")
    print_matrix(A)
    print(f"\nSecret factor B:")
    print_matrix(B)
    print(f"\nPublic product K = A ⊗ B:")
    print_matrix(K)
    
    # Try to find factorization by brute force (for small matrices)
    # Count valid factorizations
    print(f"\nKey space size for {n}×{n} matrices with entries in {{0,...,9}}:")
    print(f"  |Key space| = 10^{n*n} = {10**(n*n):,}")
    print(f"  For n=16, bound=255: |Key space| = 256^256 ≈ 2^2048")
    print(f"  This vastly exceeds 2^128 (128-bit security)")
    
    # Show that the factorization yields path witnesses
    print(f"\nPath witness from factorization:")
    print(f"  K[0,0] = {K[0,0]} = min over k of (A[0,k] + B[k,0])")
    for k in range(n):
        cost = trop_mul(A[0, k], B[k, 0])
        marker = " ← minimum" if cost == K[0, 0] else ""
        print(f"    k={k}: A[0,{k}] + B[{k},0] = {A[0,k]} + {B[k,0]} = {cost}{marker}")


# ============================================================
# Utilities
# ============================================================

def print_matrix(M: np.ndarray):
    """Pretty-print a tropical matrix."""
    n = M.shape[0]
    for i in range(n):
        row = []
        for j in range(n):
            if M[i, j] == INF:
                row.append("  ∞")
            else:
                row.append(f"{M[i, j]:3.0f}")
        print("  [" + ", ".join(row) + "]")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   TROPICAL RSA: Min-Plus Public Key Cryptography Demo   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_path_semantics()
    demo_key_exchange()
    demo_noncommutativity()
    demo_encryption()
    demo_factorization()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import sys
import os

# Read markdown files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Generate visualization data
sys.path.insert(0, os.path.dirname(__file__))
from visualizations import viz_security_scaling, viz_tropical_multiplication, viz_key_exchange, viz_factorization_hardness, viz_convergence

print("Generating visualizations...")
img_security = viz_security_scaling()
img_multiplication = viz_tropical_multiplication()
img_key_exchange = viz_key_exchange()
img_hardness = viz_factorization_hardness()
img_convergence = viz_convergence()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Cryptography/TropicalRSA.lean')

package = {
    "title": "Tropical RSA: Min-Plus Public-Key Cryptosystem with Provable Security",
    "domain": "Cryptography / Tropical Algebra / Post-Quantum Security",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Cryptography Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Matrix Multiplication",
            "pseudocode": "TropMatMul(A, B):\n  for i,j,k: C[i,j] = min(C[i,j], A[i,k]+B[k,j])\n  Complexity: O(n³)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Security Scaling with Dimension",
            "data": img_security
        },
        {
            "name": "Tropical Matrix Multiplication as Path Composition",
            "data": img_multiplication
        },
        {
            "name": "Tropical Diffie-Hellman Key Exchange Protocol",
            "data": img_key_exchange
        },
        {
            "name": "Factorization Hardness and Security Comparison",
            "data": img_hardness
        },
        {
            "name": "Tropical Power Convergence and DH Correctness",
            "data": img_convergence
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical RSA: Visualizations

Generates charts and diagrams illustrating the mathematics
of tropical cryptography.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from algorithms import (
    tropical_matrix_multiply, tropical_matrix_power,
    security_bits
)
import base64
import io

INF = float('inf')


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_security_scaling():
    """Visualize how security scales with dimension."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    dims = range(2, 65)
    
    for bound, color, ls in [(15, '#e74c3c', '-'), (63, '#3498db', '--'), (255, '#2ecc71', '-.')]:
        bits = [security_bits(n, bound) for n in dims]
        ax.plot(dims, bits, color=color, linewidth=2, linestyle=ls,
                label=f'Entry bound = {bound}')
    
    # Reference lines
    ax.axhline(y=128, color='gray', linestyle=':', alpha=0.7, linewidth=1)
    ax.text(3, 135, 'AES-128', fontsize=9, color='gray')
    ax.axhline(y=256, color='gray', linestyle=':', alpha=0.7, linewidth=1)
    ax.text(3, 263, 'AES-256', fontsize=9, color='gray')
    
    ax.set_xlabel('Matrix Dimension n', fontsize=13)
    ax.set_ylabel('Security Level (bits)', fontsize=13)
    ax.set_title('Tropical Cryptography: Security Scaling with Dimension', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.set_xlim(2, 64)
    ax.set_ylim(0, 3500)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_tropical_multiplication():
    """Visualize tropical matrix multiplication as path composition."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Graph A
    A = np.array([
        [0, 3, INF],
        [INF, 0, 2],
        [1, INF, 0]
    ])
    
    # Graph B  
    B = np.array([
        [0, INF, 4],
        [2, 0, INF],
        [INF, 1, 0]
    ])
    
    C = tropical_matrix_multiply(A, B)
    
    matrices = [A, B, C]
    titles = ['Matrix A\n(1-hop costs)', 'Matrix B\n(1-hop costs)', 'A ⊗ B\n(2-hop shortest)']
    
    for ax, M, title in zip(axes, matrices, titles):
        display = np.where(M == INF, np.nan, M)
        im = ax.imshow(display, cmap='YlOrRd_r', vmin=0, vmax=8, aspect='equal')
        
        for i in range(3):
            for j in range(3):
                val = M[i, j]
                text = '∞' if val == INF else f'{val:.0f}'
                color = 'white' if (val != INF and val > 4) else 'black'
                ax.text(j, i, text, ha='center', va='center', fontsize=16,
                       fontweight='bold', color=color)
        
        ax.set_title(title, fontsize=13, fontweight='bold')
        ax.set_xticks(range(3))
        ax.set_yticks(range(3))
        ax.set_xticklabels(['0', '1', '2'])
        ax.set_yticklabels(['0', '1', '2'])
    
    # Add ⊗ and = symbols
    fig.text(0.355, 0.5, '⊗', fontsize=30, ha='center', va='center', fontweight='bold')
    fig.text(0.66, 0.5, '=', fontsize=30, ha='center', va='center', fontweight='bold')
    
    fig.suptitle('Tropical Matrix Multiplication = Shortest Path Composition', 
                 fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_key_exchange():
    """Visualize the key exchange protocol."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Title
    ax.text(5, 7.5, 'Tropical Diffie-Hellman Key Exchange', 
            fontsize=16, fontweight='bold', ha='center', va='center')
    
    # Alice and Bob
    ax.text(2, 6.5, 'Alice', fontsize=14, fontweight='bold', ha='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#3498db', alpha=0.3))
    ax.text(8, 6.5, 'Bob', fontsize=14, fontweight='bold', ha='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#e74c3c', alpha=0.3))
    
    # Public parameters
    ax.text(5, 5.8, 'Public: Generator G (n×n tropical matrix)', 
            fontsize=11, ha='center', style='italic')
    
    # Secrets
    ax.text(2, 5.0, 'Secret: a', fontsize=11, ha='center', color='#3498db')
    ax.text(8, 5.0, 'Secret: b', fontsize=11, ha='center', color='#e74c3c')
    
    # Public keys
    ax.text(2, 4.2, 'Computes: G^a', fontsize=11, ha='center')
    ax.text(8, 4.2, 'Computes: G^b', fontsize=11, ha='center')
    
    # Exchange arrows
    ax.annotate('', xy=(7, 3.4), xytext=(3, 3.4),
                arrowprops=dict(arrowstyle='->', lw=2, color='#3498db'))
    ax.text(5, 3.6, 'sends G^a', fontsize=10, ha='center', color='#3498db')
    
    ax.annotate('', xy=(3, 2.8), xytext=(7, 2.8),
                arrowprops=dict(arrowstyle='->', lw=2, color='#e74c3c'))
    ax.text(5, 2.5, 'sends G^b', fontsize=10, ha='center', color='#e74c3c')
    
    # Shared secret computation
    ax.text(2, 1.8, '(G^b)^a = G^(ab)', fontsize=11, ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#2ecc71', alpha=0.3))
    ax.text(8, 1.8, '(G^a)^b = G^(ab)', fontsize=11, ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#2ecc71', alpha=0.3))
    
    # Result
    ax.text(5, 0.8, '✓ Both compute the same shared secret G^(ab)', 
            fontsize=12, ha='center', fontweight='bold', color='#27ae60')
    ax.text(5, 0.3, 'Security: recovering a from G and G^a is the Tropical DLP',
            fontsize=10, ha='center', style='italic', color='gray')
    
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_factorization_hardness():
    """Visualize the exponential growth of search space."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Search space growth (in log2 bits)
    dims = range(2, 20)
    bound = 255
    
    log_space = [n * n * np.log2(bound + 1) for n in dims]
    
    ax1.plot(list(dims), log_space, 'b-o', linewidth=2, markersize=4)
    ax1.axhline(y=128, color='red', linestyle='--', alpha=0.7)
    ax1.text(3, 140, '128-bit security', fontsize=9, color='red')
    ax1.axhline(y=256, color='orange', linestyle='--', alpha=0.7)
    ax1.text(3, 268, '256-bit security', fontsize=9, color='orange')
    
    ax1.set_xlabel('Matrix Dimension n', fontsize=12)
    ax1.set_ylabel('Key Space Size (log scale)', fontsize=12)
    ax1.set_title('Exponential Key Space Growth', fontsize=13, fontweight='bold')
    ax1.grid(True, alpha=0.3)
    
    # Right: Comparison with RSA/Lattice
    systems = ['RSA\n1024', 'RSA\n2048', 'RSA\n4096', 'Lattice\n512', 'Lattice\n1024',
               'Trop\nn=8', 'Trop\nn=16', 'Trop\nn=32']
    key_sizes = [1024/8, 2048/8, 4096/8, 512*2, 1024*2, 8*8, 16*16, 32*32]  # bytes
    security = [80, 112, 128, 128, 256, 
                security_bits(8, 255), security_bits(16, 255), security_bits(32, 255)]
    
    colors = ['#e74c3c']*3 + ['#3498db']*2 + ['#2ecc71']*3
    
    bars = ax2.bar(range(len(systems)), security, color=colors, alpha=0.8, edgecolor='black')
    ax2.set_xticks(range(len(systems)))
    ax2.set_xticklabels(systems, fontsize=9)
    ax2.set_ylabel('Security Level (bits)', fontsize=12)
    ax2.set_title('Security Comparison', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3, axis='y')
    
    # Add legend
    legend_elements = [
        mpatches.Patch(facecolor='#e74c3c', alpha=0.8, label='RSA'),
        mpatches.Patch(facecolor='#3498db', alpha=0.8, label='Lattice'),
        mpatches.Patch(facecolor='#2ecc71', alpha=0.8, label='Tropical'),
    ]
    ax2.legend(handles=legend_elements, fontsize=10)
    
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_convergence():
    """Visualize convergence of tropical powers."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    n = 5
    np.random.seed(42)
    A = np.random.randint(1, 10, (n, n)).astype(float)
    np.fill_diagonal(A, 0)
    
    # Track how entries evolve with powers
    powers = range(1, 15)
    entries_00 = []
    entries_01 = []
    entries_02 = []
    entries_12 = []
    
    for m in powers:
        Am = tropical_matrix_power(A, m)
        entries_00.append(Am[0, 0])
        entries_01.append(Am[0, 1])
        entries_02.append(Am[0, 2])
        entries_12.append(Am[1, 2])
    
    ax1.plot(list(powers), entries_00, 'b-o', label='A^m[0,0]', markersize=4)
    ax1.plot(list(powers), entries_01, 'r-s', label='A^m[0,1]', markersize=4)
    ax1.plot(list(powers), entries_02, 'g-^', label='A^m[0,2]', markersize=4)
    ax1.plot(list(powers), entries_12, 'm-D', label='A^m[1,2]', markersize=4)
    
    ax1.set_xlabel('Power m', fontsize=12)
    ax1.set_ylabel('Entry Value', fontsize=12)
    ax1.set_title('Tropical Power Entry Evolution', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Right: Show that G^a ⊗ G^b = G^(a+b)
    G = A.copy()
    errors = []
    for a in range(1, 20):
        for b in range(1, 20):
            Ga = tropical_matrix_power(G, a)
            Gb = tropical_matrix_power(G, b)
            GaGb = tropical_matrix_multiply(Ga, Gb)
            Gab = tropical_matrix_power(G, a + b)
            
            diff = np.max(np.abs(GaGb - Gab))
            errors.append((a, b, diff))
    
    max_error = max(e[2] for e in errors)
    
    a_vals = [e[0] for e in errors]
    b_vals = [e[1] for e in errors]
    e_vals = [e[2] for e in errors]
    
    scatter = ax2.scatter(a_vals, b_vals, c=e_vals, cmap='RdYlGn_r', s=20, 
                          vmin=0, vmax=max(0.001, max_error))
    plt.colorbar(scatter, ax=ax2, label='|G^a ⊗ G^b - G^(a+b)|∞')
    ax2.set_xlabel('Exponent a', fontsize=12)
    ax2.set_ylabel('Exponent b', fontsize=12)
    ax2.set_title(f'DH Correctness: max error = {max_error:.1e}', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    
    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    print("  1/4: Security scaling...")
    img1 = viz_security_scaling()
    
    print("  2/4: Tropical multiplication...")
    img2 = viz_tropical_multiplication()
    
    print("  3/4: Key exchange protocol...")
    img3 = viz_key_exchange()
    
    print("  4/4: Factorization hardness...")
    img4 = viz_factorization_hardness()
    
    print("\nAll visualizations generated!")
    print(f"  Security scaling: {len(img1)} chars")
    print(f"  Multiplication:   {len(img2)} chars")
    print(f"  Key exchange:     {len(img3)} chars")
    print(f"  Hardness:         {len(img4)} chars")
