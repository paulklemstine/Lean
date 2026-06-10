"""
Tropical Information Theory — Real-World Applications

Demonstrates how tropical channel capacity theory applies to:
1. Cryptographic channel analysis (side-channel leakage bounds)
2. Network routing optimization
3. DNA sequence analysis
4. Error-correcting code design
"""

import numpy as np
import sys

# Import core algorithms
sys.path.insert(0, '.')
from algorithms import (
    karp_max_cycle_mean, tropical_power_iteration,
    collatz_wielandt_value, log_channel_matrix,
    tropical_word_score, design_tropical_code,
    is_tropically_separated, tropical_decode,
    maxplus_multiply
)


# ============================================================
# Application 1: Side-Channel Leakage Analysis
# ============================================================

def side_channel_analysis():
    """
    Analyze side-channel leakage using tropical channel capacity.

    In a side-channel attack, the attacker observes noisy measurements
    correlated with secret data. The tropical capacity of the leakage
    channel provides worst-case bounds on information extraction.
    """
    print("=" * 60)
    print("APPLICATION 1: Side-Channel Leakage Analysis")
    print("=" * 60)

    # Model: 4-bit secret key, leakage through power consumption
    # Channel: P(observation | key_bit) with Hamming-weight-dependent noise
    n_states = 4  # 2-bit key

    # Leakage channel matrix (rows = key values, cols = observations)
    # Higher probability on diagonal = less noisy channel
    noise_level = 0.15
    P = np.full((n_states, n_states), noise_level / (n_states - 1))
    np.fill_diagonal(P, 1 - noise_level)

    print(f"\nLeakage channel (noise = {noise_level}):")
    print(f"P = \n{np.round(P, 3)}")

    # Compute tropical capacity
    A = log_channel_matrix(P)
    lam, x = tropical_power_iteration(A)

    print(f"\nLog-channel matrix:\n{np.round(A, 4)}")
    print(f"Tropical eigenvalue λ = {lam:.6f}")
    print(f"Tropical eigenvector x = {np.round(x, 4)}")
    print(f"exp(λ) = {np.exp(lam):.6f}")
    print(f"\nInterpretation: The worst-case single-query leakage rate")
    print(f"is bounded by |λ| = {abs(lam):.4f} nats per observation.")
    print(f"An attacker needs ≥ {int(np.ceil(np.log(n_states) / abs(lam)))} observations")
    print(f"to distinguish all {n_states} key values with high confidence.")

    # Compare different noise levels
    print(f"\nNoise level vs. tropical leakage bound:")
    print(f"{'Noise':>8s} {'λ':>10s} {'exp(λ)':>10s} {'Min queries':>12s}")
    for noise in [0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.49]:
        P_var = np.full((n_states, n_states), noise / (n_states - 1))
        np.fill_diagonal(P_var, 1 - noise)
        A_var = log_channel_matrix(P_var)
        lam_var, _ = tropical_power_iteration(A_var)
        min_queries = max(1, int(np.ceil(np.log(n_states) / max(abs(lam_var), 1e-10))))
        print(f"{noise:8.2f} {lam_var:10.4f} {np.exp(lam_var):10.4f} {min_queries:12d}")


# ============================================================
# Application 2: Network Routing Optimization
# ============================================================

def network_routing():
    """
    Optimize network routing using tropical spectral theory.

    The tropical eigenvalue of the network adjacency matrix gives
    the optimal sustainable throughput rate. The eigenvector gives
    the optimal routing potentials.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Routing Optimization")
    print("=" * 60)

    # Network: 5 nodes with weighted links (log-bandwidth)
    # A[i][j] = log(bandwidth from i to j)
    n = 5
    A = np.full((n, n), -np.inf)

    # Add edges (bidirectional with possibly asymmetric bandwidth)
    edges = [
        (0, 1, 3.0), (1, 0, 2.5),  # Link 0-1
        (1, 2, 4.0), (2, 1, 4.0),  # Link 1-2
        (2, 3, 2.0), (3, 2, 2.0),  # Link 2-3
        (3, 4, 5.0), (4, 3, 3.0),  # Link 3-4
        (4, 0, 1.0), (0, 4, 1.5),  # Link 4-0
        (0, 2, 2.0), (2, 0, 2.0),  # Shortcut 0-2
        (1, 3, 1.0), (3, 1, 1.0),  # Shortcut 1-3
    ]
    for i, j, w in edges:
        A[i][j] = w

    print(f"\nNetwork adjacency (log-bandwidth):")
    print(f"A = \n{np.round(A, 1)}")

    lam, x = tropical_power_iteration(A)
    mcm = karp_max_cycle_mean(A)

    print(f"\nTropical eigenvalue λ = {lam:.4f}")
    print(f"Maximum cycle mean = {mcm:.4f}")
    print(f"Optimal sustainable throughput rate = {lam:.4f} (log-scale)")
    print(f"= {np.exp(lam):.4f} (linear scale)")
    print(f"\nRouting potentials (eigenvector):")
    for i in range(n):
        print(f"  Node {i}: potential = {x[i]:.4f}")

    # Find the critical cycle
    print(f"\nInterpretation: The network can sustain a flow rate of")
    print(f"exp({lam:.4f}) = {np.exp(lam):.4f} per time step on its")
    print(f"bottleneck cycle. The routing potentials indicate optimal")
    print(f"scheduling: higher potential = higher priority for forwarding.")


# ============================================================
# Application 3: DNA Sequence Scoring
# ============================================================

def dna_sequence_analysis():
    """
    Apply tropical coding theory to DNA sequence analysis.

    DNA sequences can be viewed as codewords over a 4-letter alphabet.
    The BLOSUM-like scoring matrix defines tropical word scores,
    and separation guarantees correct sequence identification.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: DNA Sequence Scoring")
    print("=" * 60)

    # Simplified nucleotide scoring matrix (BLOSUM-inspired)
    # A=0, C=1, G=2, T=3
    labels = ['A', 'C', 'G', 'T']
    A = np.array([
        [ 5, -1, -2, -1],  # A matches
        [-1,  5, -3, -2],  # C matches
        [-2, -3,  5, -2],  # G matches
        [-1, -2, -2,  5],  # T matches
    ], dtype=float)

    print(f"\nNucleotide scoring matrix:")
    print(f"     {'  '.join(labels)}")
    for i in range(4):
        print(f"  {labels[i]}  {A[i]}")

    # Reference sequences (as tuples of indices)
    sequences = {
        'Seq1': (0, 1, 2, 3, 0, 1),  # ACGTAC
        'Seq2': (3, 2, 1, 0, 3, 2),  # TGCATG
        'Seq3': (0, 0, 2, 2, 1, 1),  # AAGGCC
        'Seq4': (0, 1, 2, 3, 0, 0),  # ACGTAA (similar to Seq1)
    }

    print(f"\nReference sequences:")
    for name, seq in sequences.items():
        seq_str = ''.join(labels[s] for s in seq)
        self_score = tropical_word_score(A, seq, seq)
        print(f"  {name}: {seq_str}  (self-score = {self_score})")

    # Score matrix
    print(f"\nCross-score matrix:")
    names = list(sequences.keys())
    seqs = list(sequences.values())
    print(f"{'':>6s}", end='')
    for name in names:
        print(f"  {name:>6s}", end='')
    print()
    for i, name_i in enumerate(names):
        print(f"{name_i:>6s}", end='')
        for j, name_j in enumerate(names):
            score = tropical_word_score(A, seqs[i], seqs[j])
            print(f"  {score:6.1f}", end='')
        print()

    # Check separation for a subset
    code_indices = [0, 1, 2]  # Seq1, Seq2, Seq3
    code_seqs = [seqs[i] for i in code_indices]
    code_names = [names[i] for i in code_indices]

    # Find minimum separation
    min_gap = float('inf')
    for i in range(len(code_seqs)):
        for j in range(len(code_seqs)):
            if i != j:
                gap = tropical_word_score(A, code_seqs[i], code_seqs[i]) - \
                      tropical_word_score(A, code_seqs[i], code_seqs[j])
                min_gap = min(min_gap, gap)

    delta = min_gap / 2 - 0.5
    print(f"\nCodebook {{{', '.join(code_names)}}}:")
    print(f"  Minimum self-cross gap = {min_gap}")
    print(f"  δ-separation with δ = {delta:.1f}")
    print(f"  Tropically separated: {is_tropically_separated(A, max(delta, 0), code_seqs)}")

    # Decode a noisy sequence
    noisy = (0, 1, 1, 3, 0, 1)  # ACCTAC (one substitution from Seq1=ACGTAC)
    noisy_str = ''.join(labels[s] for s in noisy)
    print(f"\nDecoding noisy sequence: {noisy_str}")
    scores = [(tropical_word_score(A, seq, noisy), name)
              for seq, name in zip(code_seqs, code_names)]
    scores.sort(reverse=True)
    for score, name in scores:
        print(f"  {name}: score = {score}")
    print(f"  Decoded as: {scores[0][1]}")


# ============================================================
# Application 4: Error-Correcting Code Design
# ============================================================

def error_correcting_codes():
    """
    Design error-correcting codes using tropical separation.

    The tropical framework provides a principled way to design codes
    where the scoring matrix captures the channel characteristics.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Tropical Error-Correcting Code Design")
    print("=" * 60)

    # Binary channel with asymmetric errors
    # 0→1 is more likely than 1→0
    A = np.array([
        [5.0, 1.0],
        [2.0, 5.0]
    ])

    print(f"\nScoring matrix (asymmetric binary channel):")
    print(f"A = \n{A}")
    print(f"(Higher diagonal = reward for correct symbol)")
    print(f"(A[0,1]=1 < A[1,0]=2 reflects asymmetric error cost)")

    for n in [3, 4, 5, 6]:
        for delta in [1.0, 2.0, 3.0]:
            code = design_tropical_code(A, n, delta)
            if len(code) >= 2:
                print(f"\n  Length {n}, δ={delta}: {len(code)} codewords")
                if len(code) <= 8:
                    for i, c in enumerate(code):
                        self_score = tropical_word_score(A, c, c)
                        print(f"    c{i} = {''.join(str(x) for x in c)} (self-score={self_score})")

    # Decoding demonstration
    print(f"\nDecoding demonstration (length 4, δ=2.0):")
    code = design_tropical_code(A, 4, 2.0)
    if len(code) >= 2:
        # Send first codeword, introduce error
        sent = code[0]
        received = list(sent)
        received[1] = 1 - received[1]  # Flip one bit
        received = tuple(received)
        print(f"  Sent:     {''.join(str(x) for x in sent)}")
        print(f"  Received: {''.join(str(x) for x in received)}")
        decoded_idx = np.argmax([tropical_word_score(A, c, received) for c in code])
        print(f"  Decoded:  {''.join(str(x) for x in code[decoded_idx])}")
        print(f"  Correct:  {code[decoded_idx] == sent}")


if __name__ == "__main__":
    side_channel_analysis()
    network_routing()
    dna_sequence_analysis()
    error_correcting_codes()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


"""
Tropical Channel Capacity — Concrete Numerical Demonstrations

This script demonstrates the core theorems of tropical information theory
with concrete numerical examples, showing how channel capacity-like quantities
arise as max-plus eigenvalues and fixed points of Bellman operators.
"""

import numpy as np
from itertools import product

def trop_channel_op(A, x):
    """Tropical (max-plus) channel operator: (T_A x)_i = max_j (A_{ij} + x_j)"""
    n = A.shape[0]
    return np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)])

def is_tropical_eigenpair(A, lam, x, tol=1e-10):
    """Check if (lam, x) is a tropical eigenpair: T_A(x) = lam + x"""
    Tx = trop_channel_op(A, x)
    return np.allclose(Tx, lam + x, atol=tol)

def max_cycle_mean(A):
    """Compute the maximum cycle mean of matrix A using Karp's algorithm."""
    n = A.shape[0]
    # Floyd-Warshall style: compute max-plus powers
    # D[k][i][j] = max weight path from i to j of length exactly k
    D = [np.full((n, n), -np.inf) for _ in range(n + 1)]
    D[0] = np.where(np.eye(n, dtype=bool), 0, -np.inf)
    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                D[k][i][j] = max(D[k-1][i][m] + A[m][j] for m in range(n))
    # Karp's theorem: max cycle mean = max_i min_k (D[n][i][i] - D[k][i][i]) / (n - k)
    best = -np.inf
    for i in range(n):
        if D[n][i][i] == -np.inf:
            continue
        worst_over_k = np.inf
        for k in range(n):
            if D[k][i][i] == -np.inf:
                continue
            val = (D[n][i][i] - D[k][i][i]) / (n - k)
            worst_over_k = min(worst_over_k, val)
        if worst_over_k != np.inf:
            best = max(best, worst_over_k)
    return best

def find_tropical_eigenpair(A, max_iter=1000, tol=1e-12):
    """Find a tropical eigenpair using Karp's max cycle mean + power iteration."""
    n = A.shape[0]
    lam = max_cycle_mean(A)
    # Build eigenvector from reduced matrix
    B = A - lam
    # x_i = max over paths from 0 to i of sum of B-weights (length 0..n-1)
    # Use max-plus powers
    x = np.full(n, -np.inf)
    Bk = np.where(np.eye(n, dtype=bool), 0, -np.inf)  # Identity
    for k in range(n):
        for i in range(n):
            x[i] = max(x[i], Bk[0, i])
        # B^{k+1} = B^k ⊗ B
        Bk_new = np.full((n, n), -np.inf)
        for i in range(n):
            for j in range(n):
                Bk_new[i, j] = max(Bk[i, m] + B[m, j] for m in range(n))
        Bk = Bk_new
    x = x - x[0]  # Normalize
    return lam, x

def tropical_collatz_wielandt(A, x):
    """Compute sup_i (T_A x_i - x_i) for a given vector x."""
    Tx = trop_channel_op(A, x)
    return max(Tx - x)

def tropical_word_score(A, u, v):
    """Compute the tropical word score between codewords u, v."""
    return sum(A[u[t], v[t]] for t in range(len(u)))

# ============================================================
# Demo 1: Basic Tropical Operator Properties
# ============================================================
print("=" * 60)
print("DEMO 1: Tropical Channel Operator Properties")
print("=" * 60)

A = np.array([[3.0, 1.0, 2.0],
              [0.0, 4.0, 1.0],
              [2.0, 3.0, 5.0]])

x = np.array([1.0, -1.0, 2.0])
y = np.array([2.0, 0.0, 3.0])
c = 1.5

Tx = trop_channel_op(A, x)
Ty = trop_channel_op(A, y)

print(f"\nA = \n{A}")
print(f"x = {x}")
print(f"y = {y}")
print(f"T_A(x) = {Tx}")
print(f"T_A(y) = {Ty}")

# Monotonicity: x ≤ y implies T_A(x) ≤ T_A(y)
print(f"\nMonotonicity check (x ≤ y): {np.all(x <= y)}")
print(f"T_A(x) ≤ T_A(y): {np.all(Tx <= Ty)}")

# Additive homogeneity: T_A(x + c) = T_A(x) + c
Txc = trop_channel_op(A, x + c)
print(f"\nAdditive homogeneity: T_A(x + {c}) = {Txc}")
print(f"T_A(x) + {c} = {Tx + c}")
print(f"Equal: {np.allclose(Txc, Tx + c)}")

# ============================================================
# Demo 2: Tropical Eigenpair Computation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Tropical Eigenpair — The Capacity Fixed Point")
print("=" * 60)

# Example 1: Simple symmetric channel
A1 = np.array([[0.0, 5.0],
               [5.0, 0.0]])
lam1, x1 = find_tropical_eigenpair(A1)
print(f"\nMatrix A1 (symmetric channel):\n{A1}")
print(f"Eigenvalue λ = {lam1:.6f}")
print(f"Eigenvector x = {x1}")
print(f"Max cycle mean = {max_cycle_mean(A1):.6f}")
print(f"Is eigenpair: {is_tropical_eigenpair(A1, lam1, x1)}")

# Example 2: Asymmetric channel
A2 = np.array([[0.0, 5.0],
               [3.0, 0.0]])
lam2, x2 = find_tropical_eigenpair(A2)
print(f"\nMatrix A2 (asymmetric channel):\n{A2}")
print(f"Eigenvalue λ = {lam2:.6f}")
print(f"Eigenvector x = {x2}")
print(f"Max cycle mean = {max_cycle_mean(A2):.6f}")
print(f"Is eigenpair: {is_tropical_eigenpair(A2, lam2, x2)}")

# Example 3: 3×3 channel
A3 = np.array([[1.0, 3.0, 2.0],
               [4.0, 2.0, 1.0],
               [2.0, 5.0, 3.0]])
lam3, x3 = find_tropical_eigenpair(A3)
print(f"\nMatrix A3 (3×3 channel):\n{A3}")
print(f"Eigenvalue λ = {lam3:.6f}")
print(f"Eigenvector x = {x3}")
print(f"Max cycle mean = {max_cycle_mean(A3):.6f}")
print(f"Is eigenpair: {is_tropical_eigenpair(A3, lam3, x3)}")

# ============================================================
# Demo 3: Collatz-Wielandt Characterization
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Collatz-Wielandt Variational Characterization")
print("=" * 60)

A = A2.copy()
lam, x_eig = find_tropical_eigenpair(A)

print(f"\nA = \n{A}")
print(f"Eigenvalue λ = {lam:.6f}")

# Show that for any vector y, max_i(T_A(y)_i - y_i) ≥ λ
test_vectors = [
    np.array([0.0, 0.0]),
    np.array([1.0, -1.0]),
    np.array([-2.0, 3.0]),
    np.array([10.0, -10.0]),
    x_eig.copy(),  # The eigenvector itself
]

print(f"\nCollatz-Wielandt bound: max_i(T_A(y)_i - y_i) ≥ λ = {lam:.6f}")
for y in test_vectors:
    cw = tropical_collatz_wielandt(A, y)
    print(f"  y = {str(y):>30s} → max excess = {cw:.6f} ≥ {lam:.6f}: {cw >= lam - 1e-10}")

# ============================================================
# Demo 4: Log-Channel Bridge
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Log-Channel Bridge — Stochastic to Tropical")
print("=" * 60)

# Binary symmetric channel with crossover probability p
p = 0.1
P_bsc = np.array([[1-p, p],
                   [p, 1-p]])
A_bsc = np.log(P_bsc)

print(f"\nBinary Symmetric Channel (p = {p}):")
print(f"P = \n{P_bsc}")
print(f"log(P) = \n{A_bsc}")
print(f"All log entries ≤ 0: {np.all(A_bsc <= 1e-10)}")

lam_bsc, x_bsc = find_tropical_eigenpair(A_bsc)
print(f"\nTropical eigenvalue = {lam_bsc:.6f}")
print(f"= log(1-p) = {np.log(1-p):.6f}")
print(f"Tropical eigenvector = {x_bsc}")

# Z-channel
P_z = np.array([[1.0, 0.0],
                [0.3, 0.7]])
# Add small epsilon to avoid log(0)
eps = 1e-10
P_z_smooth = P_z + eps
P_z_smooth = P_z_smooth / P_z_smooth.sum(axis=1, keepdims=True)
A_z = np.log(P_z_smooth)

print(f"\nZ-Channel (smoothed):")
print(f"P ≈ \n{P_z}")
print(f"log(P) ≈ \n{np.round(A_z, 4)}")

lam_z, x_z = find_tropical_eigenpair(A_z)
print(f"Tropical eigenvalue = {lam_z:.6f}")

# ============================================================
# Demo 5: Tropical Decoding Theorem
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Tropical Decoding — Score Separation Guarantees")
print("=" * 60)

# Weight matrix for a binary alphabet
A_code = np.array([[5.0, 1.0],
                   [1.0, 5.0]])

# Codebook: three binary codewords of length 4
codewords = [
    (0, 0, 0, 0),
    (1, 1, 1, 1),
    (0, 1, 0, 1),
]

print(f"\nWeight matrix A =\n{A_code}")
print(f"\nCodebook:")
for i, c in enumerate(codewords):
    print(f"  c{i} = {c}")

# Check separation
print(f"\nSelf-scores and cross-scores:")
for i, u in enumerate(codewords):
    for j, v in enumerate(codewords):
        score = tropical_word_score(A_code, u, v)
        tag = " (self)" if i == j else ""
        print(f"  score(c{i}, c{j}) = {score:.1f}{tag}")

# Check tropical separation
min_gap = float('inf')
for i, u in enumerate(codewords):
    for j, v in enumerate(codewords):
        if i != j:
            gap = tropical_word_score(A_code, u, u) - tropical_word_score(A_code, u, v)
            min_gap = min(min_gap, gap)

delta = min_gap / 2 - 0.1
print(f"\nMinimum self-cross gap = {min_gap:.1f}")
print(f"δ-separation with δ = {delta:.1f}")
print(f"Decoding guaranteed: every codeword is uniquely identified by maximum score")

# ============================================================
# Demo 6: Idempotent Semiring Warning
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Idempotent Group Triviality")
print("=" * 60)
print("\nIn any additive group where a + a = a for all a:")
print("  a + a = a  =>  a = 0  (subtract a from both sides)")
print("This shows tropical algebra CANNOT be a ring with inverses.")
print("The max-plus semiring (ℝ ∪ {-∞}, max, +) has no additive inverses,")
print("which is essential — not a deficiency.")
print("This is formally proved as `idempotent_group_trivial` in our Lean code.")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


"""
Tropical Information Theory — Visualizations

Generates figures showing key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def trop_channel_op(A, x):
    n = A.shape[0]
    return np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)])


def max_cycle_mean(A):
    n = A.shape[0]
    D = [np.full((n, n), -np.inf) for _ in range(n + 1)]
    D[0] = np.where(np.eye(n, dtype=bool), 0, -np.inf)
    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                D[k][i][j] = max(D[k-1][i][m] + A[m][j] for m in range(n))
    best = -np.inf
    for i in range(n):
        if D[n][i][i] == -np.inf: continue
        worst_over_k = np.inf
        for k in range(n):
            if D[k][i][i] == -np.inf: continue
            val = (D[n][i][i] - D[k][i][i]) / (n - k)
            worst_over_k = min(worst_over_k, val)
        if worst_over_k != np.inf:
            best = max(best, worst_over_k)
    return best


# ============================================================
# Figure 1: Collatz-Wielandt Landscape
# ============================================================

def plot_cw_landscape():
    """Plot the CW excess landscape for a 2x2 matrix."""
    A = np.array([[0.0, 5.0], [3.0, 0.0]])
    lam = max_cycle_mean(A)

    # On S = {x : x_0 = 0}, parameterized by x_1
    x1_range = np.linspace(-5, 8, 500)
    excesses = []

    for x1 in x1_range:
        x = np.array([0.0, x1])
        Tx = trop_channel_op(A, x)
        excess = max(Tx - x)
        excesses.append(excess)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.plot(x1_range, excesses, 'b-', linewidth=2, label='max excess $\\phi(x)$')
    ax.axhline(y=lam, color='r', linestyle='--', linewidth=1.5,
               label=f'Eigenvalue $\\lambda = {lam:.1f}$')
    ax.set_xlabel('$x_1$ (with $x_0 = 0$)', fontsize=14)
    ax.set_ylabel('$\\max_i (T_A(x)_i - x_i)$', fontsize=14)
    ax.set_title('Collatz-Wielandt Excess Landscape\nA = [[0, 5], [3, 0]]', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    # Mark the minimum
    min_idx = np.argmin(excesses)
    ax.plot(x1_range[min_idx], excesses[min_idx], 'ro', markersize=10,
            label=f'Minimum at $x_1 = {x1_range[min_idx]:.1f}$')
    ax.legend(fontsize=12)

    return fig_to_base64(fig)


# ============================================================
# Figure 2: Power Iteration Convergence
# ============================================================

def plot_power_iteration():
    """Show convergence of normalized power iteration."""
    A = np.array([[1.0, 3.0, 2.0],
                  [4.0, 2.0, 1.0],
                  [2.0, 5.0, 3.0]])
    lam_true = max_cycle_mean(A)

    x = np.zeros(3)
    iterations = 20
    lam_history = []
    x_history = [x.copy()]

    for k in range(iterations):
        Tx = trop_channel_op(A, x)
        lam_k = Tx[0]
        x = Tx - Tx[0]
        lam_history.append(lam_k)
        x_history.append(x.copy())

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Eigenvalue convergence
    ax1.plot(range(1, iterations+1), lam_history, 'bo-', linewidth=1.5, markersize=5)
    ax1.axhline(y=lam_true, color='r', linestyle='--', label=f'$\\lambda^* = {lam_true:.4f}$')
    ax1.set_xlabel('Iteration $k$', fontsize=13)
    ax1.set_ylabel('$\\lambda^{(k)}$', fontsize=13)
    ax1.set_title('Eigenvalue Convergence', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Eigenvector components
    x_arr = np.array(x_history)
    for i in range(3):
        ax2.plot(range(iterations+1), x_arr[:, i], 'o-', linewidth=1.5, markersize=4,
                label=f'$x_{i}$')
    ax2.set_xlabel('Iteration $k$', fontsize=13)
    ax2.set_ylabel('$x_i^{(k)}$', fontsize=13)
    ax2.set_title('Eigenvector Convergence', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Power Iteration for 3×3 Matrix', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


# ============================================================
# Figure 3: Log-Channel Bridge
# ============================================================

def plot_log_channel():
    """Show the log-channel bridge from stochastic to tropical."""
    noise_levels = np.linspace(0.01, 0.49, 50)
    trop_eigenvalues = []
    shannon_capacities = []

    for p in noise_levels:
        P = np.array([[1-p, p], [p, 1-p]])
        A = np.log(P)
        lam = max_cycle_mean(A)
        trop_eigenvalues.append(lam)
        # Shannon capacity of BSC: 1 - H(p) in bits
        H_p = -p * np.log2(p) - (1-p) * np.log2(1-p) if 0 < p < 1 else 0
        shannon_capacities.append((1 - H_p) * np.log(2))  # Convert to nats

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(noise_levels, trop_eigenvalues, 'b-', linewidth=2, label='Tropical eigenvalue $\\lambda$')
    ax1.plot(noise_levels, np.log(1 - noise_levels), 'r--', linewidth=1.5,
             label='$\\log(1-p)$')
    ax1.set_xlabel('Crossover probability $p$', fontsize=13)
    ax1.set_ylabel('Tropical eigenvalue (nats)', fontsize=13)
    ax1.set_title('BSC: Tropical Eigenvalue vs. Noise', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    ax2.plot(noise_levels, [-e for e in trop_eigenvalues], 'b-', linewidth=2,
             label='$-\\lambda$ (tropical)')
    ax2.plot(noise_levels, shannon_capacities, 'r--', linewidth=2,
             label='Shannon capacity (nats)')
    ax2.set_xlabel('Crossover probability $p$', fontsize=13)
    ax2.set_ylabel('Rate (nats)', fontsize=13)
    ax2.set_title('BSC: Tropical vs. Shannon Capacity', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Log-Channel Bridge: Classical ↔ Tropical', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


# ============================================================
# Figure 4: Tropical Code Separation
# ============================================================

def plot_code_separation():
    """Visualize tropical code separation in score space."""
    A = np.array([[5.0, 1.0], [1.0, 5.0]])

    # All binary codewords of length 3
    from itertools import product
    all_words = list(product(range(2), repeat=3))

    # Compute score matrix
    n = len(all_words)
    scores = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            scores[i, j] = sum(A[all_words[i][t], all_words[j][t]] for t in range(3))

    # Self-scores
    self_scores = np.diag(scores)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Score heatmap
    im = ax1.imshow(scores, cmap='YlOrRd', aspect='auto')
    labels = [''.join(str(b) for b in w) for w in all_words]
    ax1.set_xticks(range(n))
    ax1.set_xticklabels(labels, rotation=45, fontsize=9)
    ax1.set_yticks(range(n))
    ax1.set_yticklabels(labels, fontsize=9)
    ax1.set_title('Tropical Score Matrix', fontsize=14)
    ax1.set_xlabel('Codeword $v$', fontsize=12)
    ax1.set_ylabel('Codeword $u$', fontsize=12)
    plt.colorbar(im, ax=ax1, label='score(u, v)')

    # Self-cross gaps
    codebook = [all_words[0], all_words[3], all_words[5], all_words[7]]  # 000, 011, 101, 111
    cb_labels = [''.join(str(b) for b in w) for w in codebook]
    gaps = []
    for i, u in enumerate(codebook):
        for j, v in enumerate(codebook):
            if i != j:
                gap = sum(A[u[t], u[t]] for t in range(3)) - sum(A[u[t], v[t]] for t in range(3))
                gaps.append((cb_labels[i], cb_labels[j], gap))

    gap_labels = [f"{g[0]}→{g[1]}" for g in gaps]
    gap_vals = [g[2] for g in gaps]

    colors = ['green' if v > 0 else 'red' for v in gap_vals]
    ax2.barh(range(len(gaps)), gap_vals, color=colors, alpha=0.7)
    ax2.set_yticks(range(len(gaps)))
    ax2.set_yticklabels(gap_labels, fontsize=9)
    ax2.axvline(x=0, color='black', linewidth=1)
    ax2.set_xlabel('Self-score − Cross-score', fontsize=12)
    ax2.set_title('Score Gaps (Separation Check)', fontsize=14)
    ax2.grid(True, alpha=0.3, axis='x')

    fig.suptitle('Tropical Code Separation Analysis', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    img1 = plot_cw_landscape()
    print(f"✓ CW landscape: {len(img1)} chars")

    img2 = plot_power_iteration()
    print(f"✓ Power iteration: {len(img2)} chars")

    img3 = plot_log_channel()
    print(f"✓ Log-channel bridge: {len(img3)} chars")

    img4 = plot_code_separation()
    print(f"✓ Code separation: {len(img4)} chars")

    # Save as standalone HTML for preview
    html = f"""<!DOCTYPE html>
<html><head><title>Tropical Information Theory Visualizations</title></head>
<body style="max-width: 900px; margin: auto; font-family: sans-serif;">
<h1>Tropical Information Theory — Visualizations</h1>
<h2>1. Collatz-Wielandt Excess Landscape</h2>
<img src="{img1}" style="width:100%">
<h2>2. Power Iteration Convergence</h2>
<img src="{img2}" style="width:100%">
<h2>3. Log-Channel Bridge</h2>
<img src="{img3}" style="width:100%">
<h2>4. Tropical Code Separation</h2>
<img src="{img4}" style="width:100%">
</body></html>"""
    with open('visualizations.html', 'w') as f:
        f.write(html)
    print("✓ Saved visualizations.html")
    print("Done!")
