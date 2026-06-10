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


#!/usr/bin/env python3
"""
Paley Type II Hadamard Matrices: Interactive Demonstrations

This script demonstrates the key mathematical constructions:
1. Difference set verification (Singer (7,3,1))
2. Paley Type II Hadamard matrix construction for q=5 (order 12)
3. Paley Type II Hadamard matrix construction for q=9 (order 20) — the non-prime breakthrough
4. Strongly regular Paley graphs (q=5 and q=13)
5. Doubly regular Paley tournaments (q=7)
"""

import numpy as np
from typing import List, Tuple, Set, Dict


def gf_elements(p: int, m: int) -> List[Tuple[int, ...]]:
    """Generate all elements of GF(p^m) as tuples (coefficients of polynomial rep)."""
    if m == 1:
        return [(a,) for a in range(p)]
    elif m == 2:
        return [(a, b) for a in range(p) for b in range(p)]
    else:
        raise NotImplementedError("Only m=1,2 supported")


def gf_mul(x: Tuple[int, ...], y: Tuple[int, ...], p: int, irred: List[int]) -> Tuple[int, ...]:
    """Multiply two elements in GF(p^m) given an irreducible polynomial."""
    m = len(x)
    if m == 1:
        return ((x[0] * y[0]) % p,)
    elif m == 2:
        # x = a + b*t, y = c + d*t, irred = t^2 + irred[1]*t + irred[0]
        a, b = x
        c, d = y
        # (a+bt)(c+dt) = ac + (ad+bc)t + bd*t^2
        # t^2 = -irred[1]*t - irred[0]
        e0 = (a * c - b * d * irred[0]) % p
        e1 = (a * d + b * c - b * d * irred[1]) % p
        return (e0, e1)
    raise NotImplementedError


def gf_sub(x: Tuple[int, ...], y: Tuple[int, ...], p: int) -> Tuple[int, ...]:
    """Subtract in GF(p^m)."""
    return tuple((a - b) % p for a, b in zip(x, y))


def find_squares(p: int, m: int, irred: List[int]) -> Set[Tuple[int, ...]]:
    """Find all nonzero squares in GF(p^m)."""
    elements = gf_elements(p, m)
    zero = tuple(0 for _ in range(m))
    nonzero = [e for e in elements if e != zero]
    squares = set()
    for e in nonzero:
        sq = gf_mul(e, e, p, irred)
        squares.add(sq)
    return squares


def quadratic_char(x: Tuple[int, ...], squares: Set[Tuple[int, ...]]) -> int:
    """Quadratic character: 0 for zero, 1 for square, -1 for non-square."""
    zero = tuple(0 for _ in range(len(x)))
    if x == zero:
        return 0
    return 1 if x in squares else -1


def build_jacobsthal(p: int, m: int = 1, irred: List[int] = None) -> np.ndarray:
    """Build the Jacobsthal matrix Q for GF(p^m)."""
    if irred is None:
        irred = [0]  # trivial for m=1
    elements = gf_elements(p, m)
    q = len(elements)
    squares = find_squares(p, m, irred)
    Q = np.zeros((q, q), dtype=int)
    for i, a in enumerate(elements):
        for j, b in enumerate(elements):
            diff = gf_sub(a, b, p)
            Q[i, j] = quadratic_char(diff, squares)
    return Q


def build_conference(Q: np.ndarray) -> np.ndarray:
    """Build the bordered conference matrix C from Jacobsthal matrix Q."""
    q = Q.shape[0]
    C = np.zeros((q + 1, q + 1), dtype=int)
    C[0, 1:] = 1
    C[1:, 0] = 1
    C[1:, 1:] = Q
    return C


def build_paley_type_II(Q: np.ndarray) -> np.ndarray:
    """Build the Paley Type II Hadamard matrix H of order 2(q+1)."""
    C = build_conference(Q)
    n = C.shape[0]
    I = np.eye(n, dtype=int)
    A = C + I
    B = C - I
    H = np.block([[A, B], [B, -A]])
    return H


def verify_hadamard(H: np.ndarray) -> bool:
    """Verify H is a Hadamard matrix: ±1 entries and H*H^T = n*I."""
    n = H.shape[0]
    if not np.all(np.abs(H) == 1):
        return False
    return np.array_equal(H @ H.T, n * np.eye(n, dtype=int))


def difference_set_check(D: Set[int], n: int) -> Tuple[int, int, int]:
    """Check if D ⊂ Z/nZ is a (v,k,λ)-difference set, return parameters."""
    v = n
    k = len(D)
    diff_counts = {}
    for d1 in D:
        for d2 in D:
            diff = (d1 - d2) % n
            if diff != 0:
                diff_counts[diff] = diff_counts.get(diff, 0) + 1
    lambdas = set(diff_counts.values())
    if len(lambdas) == 1:
        lam = lambdas.pop()
        return (v, k, lam)
    return (v, k, -1)  # Not a difference set


def incidence_matrix(D: Set[int], n: int) -> np.ndarray:
    """Build the incidence matrix M_{g,h} = [g-h ∈ D] for Z/nZ."""
    M = np.zeros((n, n), dtype=int)
    for g in range(n):
        for h in range(n):
            if (g - h) % n in D:
                M[g, h] = 1
    return M


def paley_adjacency(p: int) -> np.ndarray:
    """Build Paley graph adjacency matrix for F_p."""
    qr = {(a * a) % p for a in range(1, p)}
    A = np.zeros((p, p), dtype=int)
    for i in range(p):
        for j in range(p):
            if i != j and (i - j) % p in qr:
                A[i, j] = 1
    return A


# ============================================================
# DEMONSTRATIONS
# ============================================================

def demo_singer():
    """Demonstrate the Singer (7,3,1) difference set."""
    print("=" * 70)
    print("DEMO 1: Singer Difference Set (7, 3, 1)")
    print("=" * 70)
    D = {1, 2, 4}
    params = difference_set_check(D, 7)
    print(f"D = {D} in Z/7Z")
    print(f"Parameters: (v, k, λ) = {params}")
    
    M = incidence_matrix(D, 7)
    print(f"\nIncidence matrix M:")
    print(M)
    
    gram = M @ M.T
    print(f"\nM * M^T:")
    print(gram)
    
    I7 = np.eye(7, dtype=int)
    J7 = np.ones((7, 7), dtype=int)
    expected = 2 * I7 + J7  # (k-λ)I + λJ = 2I + J
    print(f"\nExpected (k-λ)I + λJ = 2I + J:")
    print(expected)
    print(f"\nGram identity verified: {np.array_equal(gram, expected)}")
    print()


def demo_paley_q5():
    """Demonstrate Paley Type II for q=5 (order 12)."""
    print("=" * 70)
    print("DEMO 2: Paley Type II Hadamard Matrix, q = 5 (order 12)")
    print("=" * 70)
    Q = build_jacobsthal(5)
    print("Jacobsthal matrix Q (5×5):")
    print(Q)
    
    H = build_paley_type_II(Q)
    print(f"\nHadamard matrix H (12×12):")
    print(H)
    
    is_had = verify_hadamard(H)
    print(f"\nH * H^T = 12 * I: {is_had}")
    print()


def demo_paley_q9():
    """Demonstrate Paley Type II for q=9 — the breakthrough non-prime case."""
    print("=" * 70)
    print("DEMO 3: Paley Type II Hadamard Matrix, q = 9 = 3² (order 20)")
    print("         *** THE NON-PRIME FINITE FIELD BREAKTHROUGH ***")
    print("=" * 70)
    
    # GF(9) = F_3[x]/(x^2+1): irreducible polynomial x^2+1 over F_3
    # Represented as: irred = [1, 0] meaning t^2 + 0*t + 1 = t^2 + 1
    irred = [1, 0]
    elements = gf_elements(3, 2)
    squares = find_squares(3, 2, irred)
    
    print(f"GF(9) = F_3[t]/(t² + 1)")
    print(f"Elements: {elements}")
    print(f"Nonzero squares: {sorted(squares)}")
    print(f"Number of squares: {len(squares)} (= (q-1)/2 = 4)")
    
    Q = build_jacobsthal(3, 2, irred)
    print(f"\nJacobsthal matrix Q (9×9):")
    print(Q)
    print(f"Q is symmetric: {np.array_equal(Q, Q.T)}")
    print(f"Q * Q^T diagonal (should be q-1=8): {np.diag(Q @ Q.T)}")
    
    H = build_paley_type_II(Q)
    print(f"\nHadamard matrix H (20×20):")
    print(H)
    
    is_had = verify_hadamard(H)
    print(f"\nH * H^T = 20 * I: {is_had}")
    
    if is_had:
        print("\n*** SUCCESS: Paley Type II construction verified for non-prime q = 9 ***")
        print("This proves the finite-field abstraction works beyond prime fields.")
    print()


def demo_paley_graph():
    """Demonstrate Paley graph SRG properties."""
    print("=" * 70)
    print("DEMO 4: Paley Graphs as Strongly Regular Graphs")
    print("=" * 70)
    
    for p, params in [(5, (5, 2, 0, 1)), (13, (13, 6, 2, 3))]:
        n, k, a, c = params
        A = paley_adjacency(p)
        print(f"\nPaley graph on F_{p}:")
        print(f"  Adjacency matrix ({p}×{p}):")
        for row in A:
            print(f"    {row}")
        print(f"  Degree (row sums): {A.sum(axis=1)}")
        
        # Check SRG: A² = (a-c)A + (k-c)I + cJ
        A2 = A @ A
        I_n = np.eye(p, dtype=int)
        J_n = np.ones((p, p), dtype=int)
        expected = (a - c) * A + (k - c) * I_n + c * J_n
        is_srg = np.array_equal(A2, expected)
        print(f"  Expected SRG({n},{k},{a},{c})")
        print(f"  A² = {a-c}·A + {k-c}·I + {c}·J: {is_srg}")
    print()


def demo_paley_tournament():
    """Demonstrate Paley tournament doubly regular properties."""
    print("=" * 70)
    print("DEMO 5: Paley Tournament on F_7 (Doubly Regular)")
    print("=" * 70)
    
    p = 7
    qr = {(a * a) % p for a in range(1, p)}
    print(f"Quadratic residues mod {p}: {sorted(qr)}")
    
    T = np.zeros((p, p), dtype=int)
    for i in range(p):
        for j in range(p):
            if i != j and (j - i) % p in qr:
                T[i, j] = 1
    
    print(f"\nTournament matrix T:")
    print(T)
    print(f"Out-degrees: {T.sum(axis=1)} (should all be {(p-1)//2})")
    print(f"T + T^T = J - I: {np.array_equal(T + T.T, np.ones((p,p),dtype=int) - np.eye(p,dtype=int))}")
    
    gram = T.T @ T
    print(f"\nT^T * T:")
    print(gram)
    
    lam = (p - 3) // 4
    I_p = np.eye(p, dtype=int)
    J_p = np.ones((p, p), dtype=int)
    expected = ((p + 1) // 4) * I_p + lam * J_p
    print(f"Expected ((p+1)/4)I + ((p-3)/4)J = {(p+1)//4}I + {lam}J:")
    print(expected)
    print(f"Match: {np.array_equal(gram, expected)}")
    print()


if __name__ == "__main__":
    demo_singer()
    demo_paley_q5()
    demo_paley_q9()
    demo_paley_graph()
    demo_paley_tournament()
    
    print("=" * 70)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 70)
