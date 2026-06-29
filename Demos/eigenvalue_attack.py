#!/usr/bin/env python3
"""
Tropical Spectral Cryptanalysis — Real-World Applications

Demonstrates applications of tropical spectral theory to:
1. Cryptanalysis of tropical matrix-based key exchange
2. Discrete-event system identification
3. Network timing analysis
4. Weighted automata identification
"""

import numpy as np
from typing import Tuple, List

NEGINF = float('-inf')


def trop_add(a: float, b: float) -> float:
    return max(a, b)


def trop_mul(a: float, b: float) -> float:
    if a == NEGINF or b == NEGINF:
        return NEGINF
    return a + b


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    m, p = A.shape
    _, n = B.shape
    C = np.full((m, n), NEGINF)
    for i in range(m):
        for j in range(n):
            for k in range(p):
                C[i, j] = trop_add(C[i, j], trop_mul(A[i, k], B[k, j]))
    return C


def trop_mat_pow(A: np.ndarray, n: int) -> np.ndarray:
    m = A.shape[0]
    result = np.full((m, m), NEGINF)
    np.fill_diagonal(result, 0.0)
    for _ in range(n):
        result = trop_mat_mul(result, A)
    return result


# ============================================================
# Application 1: Tropical Key Exchange Attack
# ============================================================

def app_key_exchange_attack():
    """
    Demonstrate a spectral attack on a simplified tropical key exchange.

    Protocol (simplified Tropical Diffie-Hellman):
    - Public: matrix G with known tropical eigenvalue λ
    - Alice picks secret exponent a, publishes G^a
    - Bob picks secret exponent b, publishes G^b
    - Shared secret: G^(a+b)

    Attack: Eve observes G^a, reads diagonal entry, recovers a.
    """
    print("=" * 60)
    print("APPLICATION 1: Tropical Key Exchange Attack")
    print("=" * 60)
    print()

    # Setup: diagonal tropical matrix (simplified for clarity)
    lam = 5.0
    m = 4
    G = np.full((m, m), NEGINF)
    np.fill_diagonal(G, lam)

    # Alice's secret
    alice_secret = 137

    # Bob's secret
    bob_secret = 89

    # Public values
    Ga = trop_mat_pow(G, alice_secret)
    Gb = trop_mat_pow(G, bob_secret)

    print("Public parameters:")
    print(f"  G = diag({lam}), size {m}×{m}")
    print(f"  Tropical eigenvalue λ = {lam}")
    print()
    print("Protocol execution:")
    print(f"  Alice's secret: a = {alice_secret}")
    print(f"  Bob's secret:   b = {bob_secret}")
    print(f"  Alice publishes: (G^a)_{{00}} = {Ga[0,0]}")
    print(f"  Bob publishes:   (G^b)_{{00}} = {Gb[0,0]}")
    print()

    # Eve's attack
    eve_a = Ga[0, 0] / lam
    eve_b = Gb[0, 0] / lam
    print("Eve's spectral attack:")
    print(f"  Recovered a = {Ga[0,0]} / {lam} = {int(eve_a)}")
    print(f"  Recovered b = {Gb[0,0]} / {lam} = {int(eve_b)}")

    # Eve computes shared secret
    shared = trop_mat_pow(G, alice_secret + bob_secret)
    eve_shared = trop_mat_pow(G, int(eve_a) + int(eve_b))
    print(f"  Eve's shared secret: (G^{{a+b}})_{{00}} = {eve_shared[0,0]}")
    print(f"  Real shared secret:  (G^{{a+b}})_{{00}} = {shared[0,0]}")
    print(f"  Match: {'✓' if abs(eve_shared[0,0] - shared[0,0]) < 1e-9 else '✗'}")
    print()
    print("CONCLUSION: The tropical key exchange is completely broken")
    print("when G is a scalar diagonal matrix. The eigenvalue λ acts")
    print("as a 'spectral trapdoor' that makes exponent recovery trivial.")
    print()


# ============================================================
# Application 2: Discrete-Event System Identification
# ============================================================

def app_discrete_event_system():
    """
    Demonstrate identification of a manufacturing system's cycle time.

    In max-plus linear systems, the state evolution is:
        x(k+1) = G ⊗ x(k)

    The tropical eigenvalue λ determines the system's throughput:
    one item exits every λ time units in steady state.

    By observing the system for n cycles, we can recover n from the
    accumulated timing, even if n is unknown.
    """
    print("=" * 60)
    print("APPLICATION 2: Discrete-Event System Identification")
    print("=" * 60)
    print()

    # A simple 3-machine manufacturing system
    # Machine i takes time G[i,i] to process
    # Transfer from machine j to machine i takes time G[i,j]
    G = np.array([
        [3.0,    7.0,    NEGINF],
        [NEGINF, 4.0,    6.0],
        [5.0,    NEGINF, 2.0]
    ])

    print("Manufacturing system (max-plus model):")
    print("  3 machines with processing + transfer times:")
    for i, row in enumerate(G):
        parts = []
        for j, v in enumerate(row):
            if v != NEGINF:
                parts.append(f"from M{j}: {v:.0f}")
        print(f"  Machine {i}: {', '.join(parts)}")
    print()

    # Compute cycle times for several iterations
    print("System timing evolution:")
    print(f"  {'Cycles':>7}  {'Return time M0':>15}  {'Δ per cycle':>12}")
    print("  " + "-" * 37)

    prev = None
    for n in range(1, 11):
        Gn = trop_mat_pow(G, n)
        d = Gn[0, 0]
        delta = f"{d - prev:>12.2f}" if prev is not None else "         —"
        print(f"  {n:>7}  {d:>15.2f}  {delta}")
        prev = d

    # The cycle time converges to the tropical eigenvalue
    # For this matrix, compute it approximately
    G10 = trop_mat_pow(G, 10)
    G9 = trop_mat_pow(G, 9)
    approx_lam = G10[0, 0] - G9[0, 0]
    print(f"\n  Approximate cycle time (λ): {approx_lam:.2f} time units")
    print(f"  Throughput: 1 item every {approx_lam:.2f} time units")

    # System identification: given observed timing, recover number of cycles
    observed = G10[0, 0]
    print(f"\n  Identification: observed total time = {observed:.2f}")
    print(f"  Estimated cycles = total / λ ≈ {observed / approx_lam:.1f}")
    print()


# ============================================================
# Application 3: Network Timing Analysis
# ============================================================

def app_network_timing():
    """
    Demonstrate tropical spectral analysis for network delay estimation.

    In a communication network, the max-plus power (G^n)_{ij} gives the
    maximum delay of any n-hop path from node j to node i.

    The tropical eigenvalue reveals the worst-case per-hop delay growth rate.
    """
    print("=" * 60)
    print("APPLICATION 3: Network Timing Analysis")
    print("=" * 60)
    print()

    # A 4-node network with link delays
    G = np.array([
        [NEGINF, 3.0,    NEGINF, 2.0],
        [1.0,    NEGINF, 4.0,    NEGINF],
        [NEGINF, NEGINF, NEGINF, 5.0],
        [3.0,    NEGINF, 1.0,    NEGINF]
    ])

    print("Network topology (link delays in ms):")
    for i in range(4):
        for j in range(4):
            if G[i, j] != NEGINF:
                print(f"  Node {j} → Node {i}: {G[i,j]:.0f} ms")
    print()

    print("Worst-case delay analysis:")
    print(f"  {'Hops':>5}  {'Max loop delay (node 0)':>25}  {'Per-hop growth':>15}")
    print("  " + "-" * 48)

    prev = None
    for n in range(1, 9):
        Gn = trop_mat_pow(G, n)
        d = Gn[0, 0]
        if d != NEGINF and prev is not None and prev != NEGINF:
            growth = f"{(d - prev):>15.2f} ms"
        else:
            growth = "             —"
        d_str = f"{d:>25.2f}" if d != NEGINF else "                     -inf"
        print(f"  {n:>5}  {d_str}  {growth}")
        prev = d

    print()
    print("  The per-hop growth rate converges to the maximum cycle mean,")
    print("  giving the network's worst-case delay growth rate.")
    print()


# ============================================================
# Application 4: Weighted Automaton Identification
# ============================================================

def app_weighted_automaton():
    """
    Demonstrate tropical spectral identification for weighted automata.

    A weighted automaton over max-plus assigns a weight to each input string.
    For a unary alphabet, the weight of the string of length n is:
        w(a^n) = α^T ⊗ G^n ⊗ β
    where α, β are initial/final weight vectors.

    The tropical eigenvalue of G determines the asymptotic weight growth.
    """
    print("=" * 60)
    print("APPLICATION 4: Weighted Automaton Identification")
    print("=" * 60)
    print()

    # Transition matrix of a 3-state weighted automaton
    G = np.array([
        [2.0,    1.0,    NEGINF],
        [3.0,    NEGINF, 2.0],
        [NEGINF, 4.0,    1.0]
    ])

    # Initial and final weight vectors
    alpha = np.array([0.0, NEGINF, NEGINF])  # start in state 0
    beta = np.array([0.0, 0.0, 0.0])          # all states are accepting

    print("Weighted automaton:")
    print(f"  States: {{0, 1, 2}}")
    print(f"  Initial state: 0")
    print(f"  All states accepting")
    print()

    print("Word weights:")
    print(f"  {'Length n':>9}  {'w(a^n)':>10}  {'Δw':>8}")
    print("  " + "-" * 30)

    prev_w = None
    for n in range(1, 13):
        Gn = trop_mat_pow(G, n)
        # Compute α^T ⊗ G^n ⊗ β
        # First: G^n ⊗ β
        Gn_beta = np.full(G.shape[0], NEGINF)
        for i in range(G.shape[0]):
            for j in range(G.shape[0]):
                Gn_beta[i] = trop_add(Gn_beta[i], trop_mul(Gn[i, j], beta[j]))

        # Then: α^T ⊗ (G^n ⊗ β)
        w = NEGINF
        for i in range(G.shape[0]):
            w = trop_add(w, trop_mul(alpha[i], Gn_beta[i]))

        delta = f"{w - prev_w:>8.2f}" if prev_w is not None and w != NEGINF else "      —"
        print(f"  {n:>9}  {w:>10.2f}  {delta}")
        prev_w = w

    print()
    print("  The weight increment Δw converges to the tropical eigenvalue,")
    print("  allowing identification of the automaton's spectral invariant")
    print("  from output observations alone.")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    app_key_exchange_attack()
    app_discrete_event_system()
    app_network_timing()
    app_weighted_automaton()


#!/usr/bin/env python3
"""
Tropical Spectral Cryptanalysis — Demonstration Script

Demonstrates the core theorems:
1. Tropical scalar diagonal power: (diag(λ))^n has diagonal entries n*λ
2. Exponent recovery: observing a diagonal entry reveals the secret exponent
3. Spectral fingerprint: the exponent is injectively encoded in diagonal entries
"""

import numpy as np

# ============================================================
# Tropical (max-plus) arithmetic
# ============================================================

NEGINF = float('-inf')  # tropical zero (additive identity)


def trop_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)."""
    return max(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (ordinary addition)."""
    if a == NEGINF or b == NEGINF:
        return NEGINF
    return a + b


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication (max-plus)."""
    m, p = A.shape
    p2, n = B.shape
    assert p == p2
    C = np.full((m, n), NEGINF)
    for i in range(m):
        for j in range(n):
            for k in range(p):
                C[i, j] = trop_add(C[i, j], trop_mul(A[i, k], B[k, j]))
    return C


def trop_mat_pow(A: np.ndarray, n: int) -> np.ndarray:
    """Tropical matrix power: A^n (using tropical multiplication)."""
    m = A.shape[0]
    # Identity: diagonal of 0 (tropical one), off-diagonal -inf (tropical zero)
    result = np.full((m, m), NEGINF)
    np.fill_diagonal(result, 0.0)
    for _ in range(n):
        result = trop_mat_mul(result, A)
    return result


# ============================================================
# Demo 1: Tropical Diagonal Power Theorem
# ============================================================

def demo_diagonal_power():
    """Verify (diag(λ))^n has diagonal entries n*λ."""
    print("=" * 60)
    print("DEMO 1: Tropical Scalar Diagonal Power Theorem")
    print("=" * 60)
    print()

    lam = 3.5  # tropical eigenvalue
    m = 4      # matrix size

    G = np.full((m, m), NEGINF)
    np.fill_diagonal(G, lam)

    print(f"Matrix G = diag({lam}) of size {m}×{m}")
    print(f"Tropical eigenvalue λ = {lam}")
    print()
    print(f"{'n':>4}  {'(G^n)_00':>12}  {'n*λ':>12}  {'Match':>6}")
    print("-" * 40)

    for n in range(1, 11):
        Gn = trop_mat_pow(G, n)
        diag_val = Gn[0, 0]
        expected = n * lam
        match = abs(diag_val - expected) < 1e-10
        print(f"{n:>4}  {diag_val:>12.4f}  {expected:>12.4f}  {'✓' if match else '✗':>6}")

    print()
    print("✓ Confirmed: (G^n)_{ii} = n * λ for all tested n")
    print()


# ============================================================
# Demo 2: Exponent Recovery Attack
# ============================================================

def demo_exponent_recovery():
    """Demonstrate recovering a secret exponent from a diagonal observation."""
    print("=" * 60)
    print("DEMO 2: Tropical Eigenvalue Attack (Exponent Recovery)")
    print("=" * 60)
    print()

    lam = 2.7  # known tropical eigenvalue
    m = 3      # matrix size
    secret_a = 42  # secret exponent

    G = np.full((m, m), NEGINF)
    np.fill_diagonal(G, lam)

    # Compute G^a (this would be the "public" computation)
    Ga = trop_mat_pow(G, secret_a)

    # The attacker observes a diagonal entry
    observed_d = Ga[0, 0]

    # Recover the exponent
    recovered_a = observed_d / lam

    print(f"Setup:")
    print(f"  Matrix G = diag({lam}), size {m}×{m}")
    print(f"  Tropical eigenvalue λ = {lam}")
    print(f"  Secret exponent a = {secret_a}")
    print()
    print(f"Attack:")
    print(f"  Observed diagonal entry d = (G^a)_{{00}} = {observed_d}")
    print(f"  Recovered exponent a = d / λ = {observed_d} / {lam} = {recovered_a}")
    print(f"  Recovered a (integer) = {int(round(recovered_a))}")
    print()

    if int(round(recovered_a)) == secret_a:
        print("✓ SECRET EXPONENT SUCCESSFULLY RECOVERED!")
    else:
        print("✗ Recovery failed")
    print()


# ============================================================
# Demo 3: Spectral Fingerprint Injectivity
# ============================================================

def demo_spectral_fingerprint():
    """Show that different exponents always produce different diagonal entries."""
    print("=" * 60)
    print("DEMO 3: Spectral Fingerprint (Injectivity)")
    print("=" * 60)
    print()

    lam = 1.5
    m = 5
    G = np.full((m, m), NEGINF)
    np.fill_diagonal(G, lam)

    print(f"Matrix G = diag({lam}), size {m}×{m}")
    print(f"Verifying that n ↦ (G^n)_{{00}} is injective...")
    print()

    diag_values = {}
    collision = False
    for n in range(1, 101):
        Gn = trop_mat_pow(G, n)
        d = Gn[0, 0]
        if d in diag_values:
            print(f"COLLISION: n={n} and n={diag_values[d]} both give d={d}")
            collision = True
        diag_values[d] = n

    if not collision:
        print(f"✓ No collisions in exponents 1..100: the map is injective")
        print(f"  (This follows from λ ≠ 0 and the theorem")
        print(f"   tropical_pow_diag_recovers_exponent)")
    print()


# ============================================================
# Demo 4: Non-diagonal tropical matrix — eventual affine growth
# ============================================================

def demo_general_matrix():
    """Show eventual affine diagonal growth for a general tropical matrix."""
    print("=" * 60)
    print("DEMO 4: General Tropical Matrix — Eventual Affine Growth")
    print("=" * 60)
    print()

    # A 3x3 strongly connected tropical matrix
    G = np.array([
        [1.0, 3.0, NEGINF],
        [NEGINF, 2.0, 1.0],
        [4.0, NEGINF, 0.0]
    ])

    print("Matrix G:")
    for row in G:
        print("  [" + ", ".join(f"{x:6.1f}" if x != NEGINF else "  -inf" for x in row) + "]")
    print()

    # Compute cycle means for all simple cycles
    # Cycles: (0)→weight 1, (1)→weight 2, (2)→weight 0
    # Cycle (0,1): 3+(-inf) = -inf
    # Cycle (1,2): 1+0 = 1, mean 0.5? Wait...
    # Cycle (0,2): -inf, Cycle (2,0): 4+1=5, mean 2.5
    # Cycle (1,2,0): 1+4+3 = 8?  No: G[1,2]+G[2,0]+G[0,1] = 1+4+3 = 8, mean 8/3
    # Cycle (0,1,2): G[0,1]+G[1,2]+G[2,0] = 3+1+4 = 8, mean 8/3
    # Max cycle mean = 8/3 ≈ 2.667

    lam = 8.0 / 3.0  # maximum cycle mean
    print(f"Maximum cycle mean λ = 8/3 ≈ {lam:.4f}")
    print()

    print(f"{'n':>4}  {'(G^n)_00':>10}  {'(G^n)_11':>10}  {'(G^n)_22':>10}  {'n*λ':>10}  {'Δ_00':>8}")
    print("-" * 58)

    prev_d00 = None
    for n in range(1, 16):
        Gn = trop_mat_pow(G, n)
        d00 = Gn[0, 0]
        d11 = Gn[1, 1]
        d22 = Gn[2, 2]
        nlam = n * lam
        delta = f"{d00 - nlam:>8.4f}" if d00 != NEGINF else "    -inf"
        print(f"{n:>4}  {d00:>10.4f}  {d11:>10.4f}  {d22:>10.4f}  {nlam:>10.4f}  {delta}")
        prev_d00 = d00

    print()
    print("Observation: diagonal entries grow as n*λ + O(1),")
    print("confirming eventual affine growth with the cycle mean as slope.")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_diagonal_power()
    demo_exponent_recovery()
    demo_spectral_fingerprint()
    demo_general_matrix()


#!/usr/bin/env python3
"""
Generate visualizations for Tropical Spectral Cryptanalysis.
Saves figures as PNG files and returns base64 for JSON embedding.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io

NEGINF = float('-inf')


def trop_add(a, b):
    return max(a, b)

def trop_mul(a, b):
    if a == NEGINF or b == NEGINF:
        return NEGINF
    return a + b

def trop_mat_mul(A, B):
    m, p = A.shape
    _, n = B.shape
    C = np.full((m, n), NEGINF)
    for i in range(m):
        for j in range(n):
            for k in range(p):
                C[i, j] = trop_add(C[i, j], trop_mul(A[i, k], B[k, j]))
    return C

def trop_mat_pow(A, n):
    m = A.shape[0]
    result = np.full((m, m), NEGINF)
    np.fill_diagonal(result, 0.0)
    for _ in range(n):
        result = trop_mat_mul(result, A)
    return result


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def make_diagonal_growth_plot():
    """Plot 1: Affine diagonal growth for scalar diagonal matrices."""
    fig, ax = plt.subplots(figsize=(10, 6))

    lambdas = [1.0, 2.0, 3.0, 0.5]
    colors = ['#2196F3', '#F44336', '#4CAF50', '#FF9800']
    ns = np.arange(0, 21)

    for lam, color in zip(lambdas, colors):
        vals = [n * lam for n in ns]
        ax.plot(ns, vals, 'o-', color=color, label=f'λ = {lam}', markersize=4, linewidth=2)

    ax.set_xlabel('Exponent n', fontsize=14)
    ax.set_ylabel('Diagonal entry (G^n)_{ii}', fontsize=14)
    ax.set_title('Tropical Diagonal Power Growth: (G^n)_{ii} = n·λ', fontsize=16)
    ax.legend(fontsize=12, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 20.5)

    fig.savefig('/workspace/request-project/fig_diagonal_growth.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def make_exponent_recovery_plot():
    """Plot 2: Exponent recovery — observed value vs exponent."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    lam = 2.5
    ns = np.arange(1, 31)
    diag_vals = [n * lam for n in ns]

    # Left: forward map
    ax1.plot(ns, diag_vals, 'o-', color='#2196F3', markersize=5, linewidth=2)
    ax1.axhline(y=42 * lam, color='#F44336', linestyle='--', alpha=0.7, label=f'Observed d = {42*lam}')
    ax1.axvline(x=42, color='#F44336', linestyle='--', alpha=0.7)
    ax1.set_xlabel('Secret exponent a', fontsize=13)
    ax1.set_ylabel('Observed diagonal (G^a)_{ii}', fontsize=13)
    ax1.set_title('Forward Map: a → (G^a)_{ii}', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: recovery (inverse map)
    observed_range = np.linspace(0, 30 * lam, 100)
    recovered = observed_range / lam
    ax2.plot(observed_range, recovered, '-', color='#4CAF50', linewidth=2, label='a = d / λ')
    ax2.plot([42 * lam], [42], 'ro', markersize=10, zorder=5, label=f'Attack: d={42*lam} → a=42')
    ax2.set_xlabel('Observed diagonal value d', fontsize=13)
    ax2.set_ylabel('Recovered exponent a', fontsize=13)
    ax2.set_title('Spectral Attack: d → a = d/λ', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle(f'Tropical Eigenvalue Attack (λ = {lam})', fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_exponent_recovery.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def make_general_matrix_plot():
    """Plot 3: Eventual affine growth for a general tropical matrix."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    G = np.array([
        [1.0, 3.0, NEGINF],
        [NEGINF, 2.0, 1.0],
        [4.0, NEGINF, 0.0]
    ])
    lam = 8.0 / 3.0

    ns = range(1, 21)
    d00, d11, d22 = [], [], []
    for n in ns:
        Gn = trop_mat_pow(G, n)
        d00.append(Gn[0, 0])
        d11.append(Gn[1, 1])
        d22.append(Gn[2, 2])

    ns_arr = np.array(list(ns))

    # Left: raw diagonal entries
    ax1.plot(ns_arr, d00, 'o-', color='#2196F3', label='(G^n)_{00}', markersize=4)
    ax1.plot(ns_arr, d11, 's-', color='#F44336', label='(G^n)_{11}', markersize=4)
    ax1.plot(ns_arr, d22, '^-', color='#4CAF50', label='(G^n)_{22}', markersize=4)
    ax1.plot(ns_arr, [n * lam for n in ns], '--', color='gray', label=f'n·λ (λ={lam:.3f})', linewidth=2)
    ax1.set_xlabel('Exponent n', fontsize=13)
    ax1.set_ylabel('Diagonal entry value', fontsize=13)
    ax1.set_title('Diagonal Entries vs Exponent', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: deviation from n*lam
    dev00 = [d - n * lam for d, n in zip(d00, ns)]
    dev11 = [d - n * lam for d, n in zip(d11, ns)]
    dev22 = [d - n * lam for d, n in zip(d22, ns)]

    ax2.plot(ns_arr, dev00, 'o-', color='#2196F3', label='Δ_{00}', markersize=4)
    ax2.plot(ns_arr, dev11, 's-', color='#F44336', label='Δ_{11}', markersize=4)
    ax2.plot(ns_arr, dev22, '^-', color='#4CAF50', label='Δ_{22}', markersize=4)
    ax2.axhline(y=0, color='gray', linestyle='-', alpha=0.5)
    ax2.set_xlabel('Exponent n', fontsize=13)
    ax2.set_ylabel('Deviation from n·λ', fontsize=13)
    ax2.set_title('Periodic Correction Term', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('General Tropical Matrix: Eventual Affine-Periodic Growth', fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_general_matrix.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def make_injectivity_heatmap():
    """Plot 4: Heatmap showing distinct diagonal values for each exponent."""
    fig, ax = plt.subplots(figsize=(10, 6))

    lambdas = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]
    ns = range(1, 21)
    data = np.zeros((len(lambdas), len(list(ns))))

    for i, lam in enumerate(lambdas):
        for j, n in enumerate(ns):
            data[i, j] = n * lam

    im = ax.imshow(data, aspect='auto', cmap='viridis',
                   extent=[0.5, 20.5, -0.5, len(lambdas) - 0.5])
    ax.set_xlabel('Exponent n', fontsize=13)
    ax.set_ylabel('Eigenvalue λ', fontsize=13)
    ax.set_yticks(range(len(lambdas)))
    ax.set_yticklabels([f'{l:.1f}' for l in lambdas])
    ax.set_title('Tropical Spectral Fingerprint: (G^n)_{ii} = n·λ', fontsize=15)
    plt.colorbar(im, ax=ax, label='Diagonal entry value')

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_spectral_heatmap.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = make_diagonal_growth_plot()
    print(f"  ✓ fig_diagonal_growth.png ({len(b64_1)} chars)")
    b64_2 = make_exponent_recovery_plot()
    print(f"  ✓ fig_exponent_recovery.png ({len(b64_2)} chars)")
    b64_3 = make_general_matrix_plot()
    print(f"  ✓ fig_general_matrix.png ({len(b64_3)} chars)")
    b64_4 = make_injectivity_heatmap()
    print(f"  ✓ fig_spectral_heatmap.png ({len(b64_4)} chars)")
    print("Done!")
