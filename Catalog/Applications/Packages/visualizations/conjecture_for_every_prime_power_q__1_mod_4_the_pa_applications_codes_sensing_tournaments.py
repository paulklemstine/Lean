#!/usr/bin/env python3
"""
Applications of Paley-Hadamard Constructions

Demonstrates real-world applications:
1. Error-correcting codes from Hadamard matrices
2. Compressed sensing measurement matrices
3. Pseudorandom number generation from Paley sequences
4. Tournament scheduling from doubly regular tournaments
"""

import numpy as np
from algorithms import GF, paley_type_II, paley_adjacency_matrix, jacobsthal_matrix


# ============================================================
# APPLICATION 1: HADAMARD ERROR-CORRECTING CODES
# ============================================================

def hadamard_code(H: np.ndarray) -> np.ndarray:
    """
    Construct a Hadamard code from a Hadamard matrix.
    
    The rows of H (and their negations) form a code with:
    - 2n codewords of length n
    - minimum distance n/2
    - rate log₂(2n)/n
    
    This is an optimal first-order Reed-Muller code.
    
    Args:
        H: n×n Hadamard matrix (±1 entries)
    
    Returns:
        Code matrix with 2n rows (codewords), each of length n,
        entries in {0, 1} (mapping 1→0, -1→1).
    """
    n = H.shape[0]
    # Convert ±1 to 0/1: 1→0, -1→1
    code = np.vstack([H, -H])
    binary = ((1 - code) // 2).astype(int)
    return binary


def demonstrate_hadamard_code():
    """Show Hadamard code properties for the q=9 Paley construction."""
    print("=" * 60)
    print("APPLICATION 1: Hadamard Error-Correcting Codes")
    print("=" * 60)
    
    F = GF(9)
    H = paley_type_II(F)
    n = H.shape[0]
    
    code = hadamard_code(H)
    num_codewords = code.shape[0]
    
    # Compute minimum Hamming distance
    min_dist = n
    for i in range(num_codewords):
        for j in range(i + 1, num_codewords):
            dist = np.sum(code[i] != code[j])
            min_dist = min(min_dist, dist)
    
    print(f"Hadamard matrix order: n = {n}")
    print(f"Code parameters:")
    print(f"  Number of codewords: {num_codewords}")
    print(f"  Codeword length: {n}")
    print(f"  Minimum Hamming distance: {min_dist}")
    print(f"  Error correction capability: up to {(min_dist-1)//2} errors")
    print(f"  Rate: log₂({num_codewords})/{n} = {np.log2(num_codewords)/n:.4f}")
    print(f"  Relative distance: {min_dist}/{n} = {min_dist/n:.4f}")
    print()


# ============================================================
# APPLICATION 2: COMPRESSED SENSING
# ============================================================

def compressed_sensing_demo():
    """Demonstrate Hadamard matrices as measurement matrices for compressed sensing."""
    print("=" * 60)
    print("APPLICATION 2: Compressed Sensing Measurement Matrices")
    print("=" * 60)
    
    # Use the order-20 Paley Hadamard matrix
    F = GF(9)
    H = paley_type_II(F)
    n = H.shape[0]  # 20
    
    # Select m < n random rows as measurements
    m = 12  # number of measurements
    np.random.seed(42)
    selected_rows = np.sort(np.random.choice(n, m, replace=False))
    Phi = H[selected_rows, :].astype(float) / np.sqrt(n)
    
    # Create a sparse signal (s-sparse in standard basis)
    s = 3  # sparsity
    x_true = np.zeros(n)
    support = np.random.choice(n, s, replace=False)
    x_true[support] = np.random.randn(s) * 5
    
    # Measure
    y = Phi @ x_true
    
    # Simple recovery via least-norm solution (for demonstration)
    x_recovered = Phi.T @ np.linalg.solve(Phi @ Phi.T, y)
    
    error = np.linalg.norm(x_true - x_recovered) / max(np.linalg.norm(x_true), 1e-10)
    
    print(f"Signal dimension: n = {n}")
    print(f"Number of measurements: m = {m}")
    print(f"Signal sparsity: s = {s}")
    print(f"Measurement matrix: {m}×{n} submatrix of Paley-Hadamard")
    print(f"Recovery relative error: {error:.6f}")
    print(f"Mutual coherence of Phi: {compute_coherence(Phi):.4f}")
    print()


def compute_coherence(Phi: np.ndarray) -> float:
    """Compute the mutual coherence of a measurement matrix."""
    n = Phi.shape[1]
    # Normalize columns
    norms = np.linalg.norm(Phi, axis=0)
    Phi_norm = Phi / norms
    G = np.abs(Phi_norm.T @ Phi_norm)
    np.fill_diagonal(G, 0)
    return float(np.max(G))


# ============================================================
# APPLICATION 3: PSEUDORANDOM SEQUENCES
# ============================================================

def paley_sequence(p: int) -> np.ndarray:
    """
    Generate the Paley sequence of length p (Legendre symbol sequence).
    
    The sequence s_i = χ(i) for i = 0, ..., p-1 where χ is the
    quadratic character mod p.
    
    Properties:
    - Balanced: approximately equal +1s and -1s (off by 1 due to χ(0)=0)
    - Low autocorrelation: |∑ s_i · s_{i+τ}| ≤ 1 for τ ≠ 0
    - Pseudorandom: passes many standard statistical tests
    """
    seq = np.zeros(p, dtype=int)
    qr = {(a * a) % p for a in range(1, p)}
    for i in range(p):
        if i == 0:
            seq[i] = 0
        elif i in qr:
            seq[i] = 1
        else:
            seq[i] = -1
    return seq


def demonstrate_pseudorandomness():
    """Show pseudorandom properties of Paley/Legendre sequences."""
    print("=" * 60)
    print("APPLICATION 3: Pseudorandom Sequences from Paley Graphs")
    print("=" * 60)
    
    for p in [13, 29, 53, 97]:
        seq = paley_sequence(p)
        
        # Balance
        plus_count = np.sum(seq == 1)
        minus_count = np.sum(seq == -1)
        
        # Autocorrelation
        autocorr = np.zeros(p, dtype=int)
        for tau in range(p):
            autocorr[tau] = sum(
                seq[i] * seq[(i + tau) % p] for i in range(p)
            )
        
        max_off_diag = max(abs(autocorr[tau]) for tau in range(1, p))
        
        print(f"\nLegendre sequence mod {p}:")
        print(f"  +1 count: {plus_count}, -1 count: {minus_count}")
        print(f"  Autocorrelation at τ=0: {autocorr[0]}")
        print(f"  Max |autocorrelation| for τ≠0: {max_off_diag}")
        print(f"  Normalized: {max_off_diag/p:.4f} (≤ 1/p = {1/p:.4f} expected)")
    print()


# ============================================================
# APPLICATION 4: TOURNAMENT SCHEDULING
# ============================================================

def paley_tournament_schedule(p: int) -> list:
    """
    Generate a doubly regular tournament schedule for p teams.
    
    Uses the Paley tournament on F_p (for p ≡ 3 mod 4):
    Team i beats team j iff (j - i) is a quadratic residue mod p.
    
    The resulting tournament is:
    - Regular: each team wins (p-1)/2 games
    - Doubly regular: for any two teams, exactly (p-3)/4 teams
      lose to both of them
    
    This is optimal for fairness in round-robin tournaments.
    """
    qr = {(a * a) % p for a in range(1, p)}
    schedule = []
    for i in range(p):
        wins = [j for j in range(p) if i != j and (j - i) % p in qr]
        schedule.append((i, wins))
    return schedule


def demonstrate_tournament():
    """Show tournament scheduling from Paley construction."""
    print("=" * 60)
    print("APPLICATION 4: Fair Tournament Scheduling")
    print("=" * 60)
    
    p = 7
    schedule = paley_tournament_schedule(p)
    
    print(f"\nPaley tournament for {p} teams (p ≡ 3 mod 4):")
    print(f"Each team plays {p-1} games, wins {(p-1)//2}")
    print(f"\nSchedule:")
    for team, wins in schedule:
        print(f"  Team {team} beats teams {wins}")
    
    # Verify doubly regular property
    lam = (p - 3) // 4
    print(f"\nDoubly regular parameter λ = (p-3)/4 = {lam}")
    print("Verification (teams that lose to both i and j):")
    for i in range(min(3, p)):
        for j in range(i + 1, min(4, p)):
            common = sum(
                1 for k in range(p)
                if k != i and k != j
                and (i - k) % p in {(a * a) % p for a in range(1, p)}
                and (j - k) % p in {(a * a) % p for a in range(1, p)}
            )
            print(f"  Teams {i},{j}: {common} common losses (expected {lam})")
    print()


# ============================================================
# APPLICATION 5: GRAPH EXPANSION AND QUASIRANDOMNESS
# ============================================================

def demonstrate_expansion():
    """Show expansion properties of Paley graphs."""
    print("=" * 60)
    print("APPLICATION 5: Graph Expansion from Paley Graphs")
    print("=" * 60)
    
    for q in [13, 29, 53]:
        F = GF(q)
        A = paley_adjacency_matrix(F)
        
        # Compute eigenvalues of A
        eigenvalues = np.sort(np.linalg.eigvalsh(A.astype(float)))[::-1]
        
        k = (q - 1) // 2  # degree
        lambda2 = abs(eigenvalues[1])
        
        print(f"\nPaley graph on F_{q}:")
        print(f"  Vertices: {q}, Degree: k = {k}")
        print(f"  Largest eigenvalue: λ₁ = {eigenvalues[0]:.2f} (= k = {k})")
        print(f"  Second eigenvalue: |λ₂| = {lambda2:.2f}")
        print(f"  Spectral gap: k - |λ₂| = {k - lambda2:.2f}")
        print(f"  Expansion ratio: k/|λ₂| = {k/lambda2:.2f}")
        print(f"  Ramanujan bound: √(q-1) = {np.sqrt(q-1):.2f}")
        print(f"  Ramanujan? |λ₂| ≤ 2√(k-1): {lambda2 <= 2*np.sqrt(k-1) + 0.01}")
    print()


if __name__ == "__main__":
    demonstrate_hadamard_code()
    compressed_sensing_demo()
    demonstrate_pseudorandomness()
    demonstrate_tournament()
    demonstrate_expansion()
    
    print("=" * 60)
    print("ALL APPLICATIONS DEMONSTRATED")
    print("=" * 60)
