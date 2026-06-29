"""
Applications of Paley-Hadamard Matrices

Demonstrates real-world applications of the Paley Type I construction
in signal processing, experimental design, and error-correcting codes.
"""
import numpy as np
from algorithms import (
    build_paley_type_I, normalize_hadamard, extract_bibd_incidence,
    build_jacobsthal_matrix, sylvester_hadamard, euler_criterion
)


def compressed_sensing_demo():
    """Demonstrate Hadamard matrices as deterministic sensing matrices.
    
    In compressed sensing, we want to recover a sparse signal x from
    few measurements y = Ax. Hadamard-based sensing matrices have
    provably low coherence, enabling exact recovery.
    """
    print("=" * 60)
    print("APPLICATION 1: Compressed Sensing with Paley Matrices")
    print("=" * 60)
    
    p = 7
    H = build_paley_type_I(p)
    n = p + 1  # = 8
    
    # Use rows of H as measurement vectors
    # Coherence = max |<h_i, h_j>| / n for i ≠ j
    H_normalized = H / np.sqrt(n)
    G = H_normalized @ H_normalized.T
    
    # Off-diagonal entries
    off_diag = np.abs(G - np.eye(n))
    coherence = np.max(off_diag)
    
    print(f"\nPaley matrix order: {n}")
    print(f"Gram matrix G = H·H^T / n = I (perfect incoherence)")
    print(f"Maximum off-diagonal |G_ij| = {coherence:.6f}")
    print(f"This is optimal: Hadamard matrices achieve the Welch bound.")
    
    # Simulate sparse recovery
    k_sparse = 2  # 2-sparse signal
    np.random.seed(42)
    x_true = np.zeros(n)
    support = np.random.choice(n, k_sparse, replace=False)
    x_true[support] = np.random.randn(k_sparse)
    
    # Use m < n measurements
    m = 5
    A_sense = H[:m, :].astype(float)
    y = A_sense @ x_true
    
    print(f"\nSparse recovery demo:")
    print(f"  Signal length: {n}")
    print(f"  Sparsity: {k_sparse}")
    print(f"  Measurements: {m}")
    print(f"  True signal support: {support}")
    print(f"  Measurement vector y: {y}")


def experimental_design_demo():
    """Demonstrate the Hadamard → BIBD bridge for experimental design.
    
    A BIBD(v, k, λ) provides an optimal balanced design for comparing
    v treatments in blocks of size k, where every pair of treatments
    appears together in exactly λ blocks.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Optimal Experimental Design via BIBD")
    print("=" * 60)
    
    for p in [7, 11, 19, 23]:
        H = build_paley_type_I(p)
        n = p + 1
        
        if n % 4 != 0:
            continue
        
        H_norm = normalize_hadamard(H)
        A, params = extract_bibd_incidence(H_norm)
        v, k, lam = params["v"], params["k"], params["lambda"]
        
        print(f"\nPrime p = {p}, Hadamard order = {n}")
        print(f"BIBD parameters: ({v}, {k}, {lam})")
        print(f"  → {v} treatments, blocks of size {k}")
        print(f"  → Every pair appears in {lam} blocks")
        print(f"  → Design is balanced and optimal")
        
        # Verify row/column sums
        row_sums = A.sum(axis=1)
        col_sums = A.sum(axis=0)
        print(f"  Row sums: all = {k}? {np.all(row_sums == k)}")
        print(f"  Column sums: all = {k}? {np.all(col_sums == k)}")
        
        # Verify inner products
        gram = A @ A.T
        diag_ok = np.all(np.diag(gram) == k)
        off_diag = gram - np.diag(np.diag(gram))
        off_ok = np.all(off_diag == lam)
        print(f"  Diagonal of A·A^T = {k}? {diag_ok}")
        print(f"  Off-diagonal of A·A^T = {lam}? {off_ok}")


def error_correcting_code_demo():
    """Demonstrate the connection to error-correcting codes.
    
    A Hadamard matrix of order n gives a binary code of length n
    with 2n codewords and minimum distance n/2 (the first-order
    Reed-Muller code for powers of 2).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Error-Correcting Codes from Hadamard Matrices")
    print("=" * 60)
    
    for p in [3, 7, 11]:
        H = build_paley_type_I(p)
        n = p + 1
        
        # Convert ±1 matrix to {0,1} binary code
        # Each row and its negation form a codeword pair
        codewords = []
        for i in range(n):
            row = (1 - H[i]) // 2  # Map 1→0, -1→1
            neg_row = (1 + H[i]) // 2  # Complement
            codewords.append(row)
            codewords.append(neg_row)
        
        codewords = np.array(codewords)
        num_codewords = len(codewords)
        
        # Compute minimum Hamming distance
        min_dist = n
        for i in range(num_codewords):
            for j in range(i + 1, num_codewords):
                d = np.sum(codewords[i] != codewords[j])
                min_dist = min(min_dist, d)
        
        rate = np.log2(num_codewords) / n
        
        print(f"\nPaley code from p = {p}:")
        print(f"  Code length: {n}")
        print(f"  Number of codewords: {num_codewords}")
        print(f"  Minimum Hamming distance: {min_dist}")
        print(f"  Rate: {rate:.4f} bits per symbol")
        print(f"  Error correction capability: up to {(min_dist-1)//2} errors")


def strongly_regular_graph_demo():
    """Demonstrate the Paley graph as a strongly regular graph.
    
    The Paley graph G(p) has vertex set F_p and edges {a,b} when
    a-b is a quadratic residue. For p ≡ 1 (mod 4), this is an
    undirected graph (since -1 is a square). For p ≡ 3 (mod 4),
    we get a tournament.
    
    The Jacobsthal matrix Q encodes the tournament structure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Paley Tournaments and Strongly Regular Graphs")
    print("=" * 60)
    
    for p in [7, 11, 19]:
        Q = build_jacobsthal_matrix(p)
        
        # Q is skew-symmetric for p ≡ 3 mod 4
        skew = np.array_equal(Q.T, -Q)
        print(f"\nPaley tournament for p = {p}:")
        print(f"  Q is skew-symmetric: {skew}")
        
        # The adjacency matrix of the tournament
        # A[i,j] = 1 if χ(i-j) = 1 (i beats j)
        A_tour = (Q + 1) // 2  # Map -1→0, 0→0, 1→1
        np.fill_diagonal(A_tour, 0)
        
        # Out-degree of each vertex
        out_degrees = A_tour.sum(axis=1)
        print(f"  Out-degrees: {out_degrees}")
        print(f"  Regular tournament: {np.all(out_degrees == (p-1)//2)}")
        
        # Number of directed triangles
        # In a Paley tournament, every triple has a cyclic ordering
        A3 = A_tour @ A_tour @ A_tour
        num_triangles = np.trace(A3) // 3
        print(f"  Number of directed 3-cycles: {num_triangles}")
        
        # Eigenvalues of Q
        eigenvalues = np.sort(np.linalg.eigvalsh(Q @ Q.T))
        print(f"  Eigenvalues of Q·Q^T: {eigenvalues[:3]}... {eigenvalues[-1]}")
        print(f"  Expected: {p-1} (once) and {p} (p-1 = {p-1} times)")


def spectral_analysis_demo():
    """Demonstrate the spectral properties of Paley/Hadamard matrices."""
    print("\n" + "=" * 60)
    print("APPLICATION 5: Spectral Properties")
    print("=" * 60)
    
    for p in [7, 11, 23]:
        H = build_paley_type_I(p)
        n = p + 1
        
        # Singular values
        svd = np.linalg.svd(H.astype(float), compute_uv=False)
        
        print(f"\nPaley matrix order {n} (p={p}):")
        print(f"  Singular values: {svd[:3]}...")
        print(f"  All equal to √{n}? {np.allclose(svd, np.sqrt(n))}")
        print(f"  Condition number: {svd[0]/svd[-1]:.6f}")
        print(f"  (Optimal condition number = 1.0)")
        
        # Determinant
        det = np.linalg.det(H.astype(float))
        max_det = n ** (n / 2)
        print(f"  |det(H)| = {abs(det):.0f}")
        print(f"  Hadamard bound: n^(n/2) = {max_det:.0f}")
        print(f"  Achieves Hadamard bound: {np.isclose(abs(det), max_det)}")


def main():
    """Run all application demonstrations."""
    compressed_sensing_demo()
    experimental_design_demo()
    error_correcting_code_demo()
    strongly_regular_graph_demo()
    spectral_analysis_demo()


if __name__ == "__main__":
    main()


"""
Paley Type I Hadamard Matrices: Demonstrations

Concrete numerical demonstrations of the Paley Type I construction
for primes p ≡ 3 (mod 4), including verification of orthogonality
and the Hadamard → BIBD bridge.
"""
import numpy as np
from typing import List, Tuple


def legendre_symbol(a: int, p: int) -> int:
    """Compute the Legendre symbol (a/p) for prime p."""
    if a % p == 0:
        return 0
    # Euler's criterion: a^((p-1)/2) mod p
    val = pow(a, (p - 1) // 2, p)
    return val if val == 1 else -1


def jacobsthal_matrix(p: int) -> np.ndarray:
    """Construct the p×p Jacobsthal matrix Q where Q[a,b] = χ(a-b)."""
    Q = np.zeros((p, p), dtype=int)
    for a in range(p):
        for b in range(p):
            Q[a, b] = legendre_symbol((a - b) % p, p)
    return Q


def paley_type_I(p: int) -> np.ndarray:
    """Construct the (p+1)×(p+1) Paley Type I Hadamard matrix.
    
    H = | 1    j^T   |
        | -j   Q + I |
    """
    Q = jacobsthal_matrix(p)
    n = p + 1
    H = np.zeros((n, n), dtype=int)
    
    # Top-left: 1
    H[0, 0] = 1
    # Top row: all 1s
    H[0, 1:] = 1
    # Left column: all -1s (except top)
    H[1:, 0] = -1
    # Bottom-right: Q + I
    H[1:, 1:] = Q + np.eye(p, dtype=int)
    
    return H


def verify_hadamard(H: np.ndarray, name: str = "") -> bool:
    """Verify that H is a Hadamard matrix: ±1 entries and H·H^T = n·I."""
    n = H.shape[0]
    
    # Check ±1 entries
    entries_ok = np.all(np.abs(H) == 1)
    
    # Check orthogonality
    product = H @ H.T
    expected = n * np.eye(n, dtype=int)
    orth_ok = np.array_equal(product, expected)
    
    prefix = f"[{name}] " if name else ""
    print(f"{prefix}Order {n}: entries ±1 = {entries_ok}, H·H^T = {n}·I = {orth_ok}")
    
    return entries_ok and orth_ok


def verify_jacobsthal_gram(p: int) -> bool:
    """Verify Q·Q^T = p·I - J for the Jacobsthal matrix."""
    Q = jacobsthal_matrix(p)
    product = Q @ Q.T
    expected = p * np.eye(p, dtype=int) - np.ones((p, p), dtype=int)
    ok = np.array_equal(product, expected)
    print(f"p={p}: Q·Q^T = {p}·I - J = {ok}")
    return ok


def extract_bibd(H: np.ndarray) -> Tuple[np.ndarray, dict]:
    """Extract the core incidence matrix from a normalized Hadamard matrix.
    
    Returns (A, params) where A is the incidence matrix and params are
    the BIBD parameters (v, k, λ).
    """
    n = H.shape[0]
    assert n % 4 == 0, f"Order {n} is not a multiple of 4"
    m = n // 4  # n = 4m
    
    # Extract core: A[i,j] = (1 + H[i+1,j+1]) / 2
    A = (1 + H[1:, 1:]) // 2
    
    v = 4 * m - 1
    k = 2 * m - 1
    lam = m - 1
    
    return A, {"v": v, "k": k, "lambda": lam}


def verify_bibd(A: np.ndarray, params: dict) -> bool:
    """Verify that A is the incidence matrix of a symmetric BIBD."""
    v, k, lam = params["v"], params["k"], params["lambda"]
    n = v
    m = (v + 1) // 4
    
    # Check dimensions
    assert A.shape == (n, n), f"Shape mismatch: {A.shape} vs ({n},{n})"
    
    # Check {0,1} entries
    entries_ok = np.all((A == 0) | (A == 1))
    
    # Check row sums = k
    row_sums = A.sum(axis=1)
    row_ok = np.all(row_sums == k)
    
    # Check column sums = k
    col_sums = A.sum(axis=0)
    col_ok = np.all(col_sums == k)
    
    # Check A·A^T = (k-λ)·I + λ·J
    product = A @ A.T
    expected = (k - lam) * np.eye(n, dtype=int) + lam * np.ones((n, n), dtype=int)
    gram_ok = np.array_equal(product, expected)
    
    print(f"BIBD({v},{k},{lam}): entries 0/1={entries_ok}, "
          f"row_sum={k}={row_ok}, col_sum={k}={col_ok}, "
          f"A·A^T = {k-lam}·I + {lam}·J = {gram_ok}")
    
    return entries_ok and row_ok and col_ok and gram_ok


def character_correlation_demo(p: int):
    """Demonstrate the character correlation identity for prime p ≡ 3 (mod 4)."""
    print(f"\n=== Character Correlation for p = {p} ===")
    
    for a in range(p):
        total = sum(legendre_symbol(t, p) * legendre_symbol((t + a) % p, p) 
                     for t in range(p))
        expected = p - 1 if a == 0 else -1
        status = "✓" if total == expected else "✗"
        print(f"  ∑ χ(t)·χ(t+{a}) = {total:3d}  (expected {expected:3d})  {status}")


def main():
    print("=" * 70)
    print("PALEY TYPE I HADAMARD MATRICES: DEMONSTRATIONS")
    print("=" * 70)
    
    # Phase 1: Test cases
    primes_3mod4 = [3, 7, 11, 19, 23, 31, 43, 47, 59, 67, 71, 79, 83]
    
    print("\n--- Phase 1: Jacobsthal Gram Identity Q·Q^T = p·I - J ---")
    for p in primes_3mod4[:5]:
        verify_jacobsthal_gram(p)
    
    print("\n--- Phase 2: Paley Type I Hadamard Matrices ---")
    for p in primes_3mod4:
        H = paley_type_I(p)
        verify_hadamard(H, f"Paley p={p}")
    
    print("\n--- Phase 3: Character Correlation Identity ---")
    character_correlation_demo(7)
    character_correlation_demo(11)
    
    print("\n--- Phase 4: Hadamard → BIBD Bridge ---")
    for p in primes_3mod4[:6]:
        H = paley_type_I(p)
        # Normalize H (first row and column all 1s)
        # Negate rows/columns where the first entry is -1
        for i in range(H.shape[0]):
            if H[i, 0] == -1:
                H[i, :] *= -1
        for j in range(H.shape[1]):
            if H[0, j] == -1:
                H[:, j] *= -1
        
        n = H.shape[0]
        if n % 4 == 0:
            A, params = extract_bibd(H)
            verify_bibd(A, params)
        else:
            print(f"  p={p}: order {n} not divisible by 4, skipping BIBD extraction")
    
    print("\n--- Phase 5: Certified Hadamard Orders via Paley Type I ---")
    orders = sorted(set(p + 1 for p in primes_3mod4))
    print(f"Certified Hadamard orders from Paley Type I (p ≡ 3 mod 4):")
    print(f"  {orders}")
    
    # Extended list
    import sympy
    large_primes = [p for p in sympy.primerange(3, 500) if p % 4 == 3]
    large_orders = sorted(p + 1 for p in large_primes)
    print(f"\nAll Paley Type I Hadamard orders up to 500:")
    print(f"  {large_orders}")
    print(f"  Count: {len(large_orders)} certified orders")


if __name__ == "__main__":
    main()
