"""
algorithms.py — Certified Expander Algorithms for Classical Groups

Implements the core algorithms for:
1. Certificate checking for generator pairs in classical groups
2. Cayley graph construction from generating sets
3. Spectral gap computation via adjacency matrix eigenvalues
4. Vertex expansion estimation

All algorithms operate on finite classical groups represented as
matrix groups over finite fields GF(q).
"""

import numpy as np
from itertools import product as iterproduct
from typing import List, Tuple, Optional, Dict, Any
from functools import lru_cache


# ============================================================
# Finite field arithmetic (GF(p) for prime p)
# ============================================================

class GFp:
    """Arithmetic in GF(p) for prime p."""

    def __init__(self, p: int):
        assert self._is_prime(p), f"{p} is not prime"
        self.p = p

    @staticmethod
    def _is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def neg(self, a: int) -> int:
        return (-a) % self.p

    def inv(self, a: int) -> int:
        assert a % self.p != 0, "Cannot invert zero"
        return pow(a, self.p - 2, self.p)

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p


# ============================================================
# Matrix operations over GF(p)
# ============================================================

def mat_mul_gfp(A: np.ndarray, B: np.ndarray, p: int) -> np.ndarray:
    """Matrix multiplication over GF(p)."""
    return np.mod(A.astype(int) @ B.astype(int), p).astype(int)


def mat_det_gfp(M: np.ndarray, p: int) -> int:
    """Determinant of a matrix over GF(p) using cofactor expansion."""
    n = M.shape[0]
    if n == 1:
        return int(M[0, 0]) % p
    if n == 2:
        return (int(M[0, 0]) * int(M[1, 1]) - int(M[0, 1]) * int(M[1, 0])) % p
    det = 0
    for j in range(n):
        minor = np.delete(np.delete(M, 0, axis=0), j, axis=1)
        cofactor = ((-1) ** j) * int(M[0, j]) * mat_det_gfp(minor, p)
        det = (det + cofactor) % p
    return det


def mat_inv_gfp(M: np.ndarray, p: int) -> Optional[np.ndarray]:
    """Matrix inverse over GF(p). Returns None if not invertible."""
    det = mat_det_gfp(M, p)
    if det == 0:
        return None
    n = M.shape[0]
    gf = GFp(p)
    det_inv = gf.inv(det)
    # Adjugate matrix
    adj = np.zeros_like(M)
    for i in range(n):
        for j in range(n):
            minor = np.delete(np.delete(M, i, axis=0), j, axis=1)
            adj[j, i] = ((-1) ** (i + j) * mat_det_gfp(minor, p) * det_inv) % p
    return adj.astype(int)


def mat_charpoly_gfp(M: np.ndarray, p: int) -> List[int]:
    """Characteristic polynomial of M over GF(p).

    Returns coefficients [c0, c1, ..., cn] where
    charpoly(x) = c0 + c1*x + ... + cn*x^n.
    """
    n = M.shape[0]
    # Use the Faddeev-LeVerrier algorithm
    coeffs = [0] * (n + 1)
    coeffs[n] = 1  # monic
    B = np.eye(n, dtype=int)
    for k in range(1, n + 1):
        BM = mat_mul_gfp(B, M, p)
        trace = sum(int(BM[i, i]) for i in range(n)) % p
        ck = (p - pow(k, p - 2, p) * trace % p) % p
        coeffs[n - k] = ck
        if k < n:
            B = (BM + ck * np.eye(n, dtype=int)) % p
    return coeffs


def poly_is_irreducible_gfp(coeffs: List[int], p: int) -> bool:
    """Check if a polynomial over GF(p) is irreducible.

    Uses trial division by all polynomials of degree <= deg/2.
    """
    n = len(coeffs) - 1  # degree
    if n <= 0:
        return False
    if n == 1:
        return True

    gf = GFp(p)

    def poly_mod(a: List[int], b: List[int]) -> List[int]:
        """Compute a mod b over GF(p)."""
        a = list(a)
        while len(a) >= len(b):
            if a[-1] != 0:
                coeff = gf.mul(a[-1], gf.inv(b[-1]))
                shift = len(a) - len(b)
                for i in range(len(b)):
                    a[i + shift] = gf.sub(a[i + shift], gf.mul(coeff, b[i]))
            a.pop()
        while a and a[-1] == 0:
            a.pop()
        return a if a else [0]

    # Generate all monic polynomials of degree 1 to n//2
    for deg in range(1, n // 2 + 1):
        # Enumerate all monic polynomials of this degree
        for lower_coeffs in iterproduct(range(p), repeat=deg):
            trial = list(lower_coeffs) + [1]  # monic
            remainder = poly_mod(coeffs, trial)
            if all(c == 0 for c in remainder):
                return False
    return True


# ============================================================
# Certificate checking
# ============================================================

def check_regular_toral(M: np.ndarray, p: int) -> bool:
    """Check if M is 'regular toral': its characteristic polynomial is irreducible.

    For a matrix over GF(p), irreducible charpoly implies:
    - M has no eigenvalues in GF(p)
    - M has no proper invariant subspace
    - The centralizer of M is as small as possible (a maximal torus)

    Args:
        M: Square matrix with entries in {0, ..., p-1}
        p: Prime defining the base field

    Returns:
        True if the characteristic polynomial of M is irreducible over GF(p)
    """
    charpoly = mat_charpoly_gfp(M, p)
    return poly_is_irreducible_gfp(charpoly, p)


def check_no_common_eigenvector(s: np.ndarray, t: np.ndarray, p: int) -> bool:
    """Check that s and t have no common eigenvector over GF(p).

    Enumerates all nonzero vectors in GF(p)^n and checks if any
    is an eigenvector for both s and t.

    Args:
        s, t: Square matrices with entries in {0, ..., p-1}
        p: Prime defining the base field

    Returns:
        True if s and t have no common eigenvector
    """
    n = s.shape[0]
    for v_tuple in iterproduct(range(p), repeat=n):
        v = np.array(v_tuple, dtype=int)
        if np.all(v == 0):
            continue
        sv = mat_mul_gfp(s, v.reshape(-1, 1), p).flatten()
        # Check if sv = c*v for some c
        is_s_eigenvec = False
        for c in range(p):
            if np.all(sv == (c * v) % p):
                is_s_eigenvec = True
                break
        if not is_s_eigenvec:
            continue
        tv = mat_mul_gfp(t, v.reshape(-1, 1), p).flatten()
        for d in range(p):
            if np.all(tv == (d * v) % p):
                return False  # Found common eigenvector
    return True


def check_classical_certificate(s: np.ndarray, t: np.ndarray, p: int) -> Dict[str, Any]:
    """Full certificate check for a generator pair (s, t).

    Checks:
    1. Both s and t are invertible (nonzero determinant)
    2. s has irreducible characteristic polynomial (regular toral)
    3. s and t have no common eigenvector

    Args:
        s, t: Square matrices with entries in {0, ..., p-1}
        p: Prime defining the base field

    Returns:
        Dictionary with certificate status and diagnostics
    """
    result = {
        "s_det": mat_det_gfp(s, p),
        "t_det": mat_det_gfp(t, p),
        "s_invertible": mat_det_gfp(s, p) != 0,
        "t_invertible": mat_det_gfp(t, p) != 0,
        "s_charpoly": mat_charpoly_gfp(s, p),
        "s_regular_toral": False,
        "no_common_eigenvector": False,
        "certificate_valid": False,
    }
    if not result["s_invertible"] or not result["t_invertible"]:
        return result

    result["s_regular_toral"] = check_regular_toral(s, p)
    result["no_common_eigenvector"] = check_no_common_eigenvector(s, t, p)
    result["certificate_valid"] = (
        result["s_regular_toral"] and result["no_common_eigenvector"]
    )
    return result


# ============================================================
# Symplectic form and Sp_4(GF(p))
# ============================================================

def symplectic_form_4() -> np.ndarray:
    """Standard 4x4 symplectic form matrix J = [[0, I], [-I, 0]]."""
    return np.array([
        [0, 0, 1, 0],
        [0, 0, 0, 1],
        [-1, 0, 0, 0],
        [0, -1, 0, 0]
    ], dtype=int)


def is_symplectic(M: np.ndarray, p: int) -> bool:
    """Check if M preserves the standard symplectic form: M^T J M = J (mod p)."""
    J = symplectic_form_4()
    product = mat_mul_gfp(mat_mul_gfp(M.T % p, J % p, p), M, p)
    return np.all(product % p == J % p)


def orthogonal_form_3() -> np.ndarray:
    """Standard 3x3 identity form (for SO_3)."""
    return np.eye(3, dtype=int)


def is_orthogonal(M: np.ndarray, p: int) -> bool:
    """Check if M preserves the standard quadratic form: M^T M = I (mod p)."""
    product = mat_mul_gfp(M.T % p, M, p)
    return np.all(product % p == np.eye(M.shape[0], dtype=int) % p)


# ============================================================
# Cayley graph construction
# ============================================================

def enumerate_subgroup(generators: List[np.ndarray], p: int,
                       max_size: int = 100000) -> List[np.ndarray]:
    """Enumerate the subgroup generated by a set of matrices over GF(p).

    Uses BFS to enumerate all elements reachable by multiplication.

    Args:
        generators: List of generating matrices
        p: Prime field characteristic
        max_size: Maximum group size before stopping

    Returns:
        List of all group elements as matrices
    """
    n = generators[0].shape[0]
    identity = np.eye(n, dtype=int)

    def mat_to_key(M):
        return tuple(M.flatten() % p)

    seen = {mat_to_key(identity)}
    queue = [identity.copy()]
    elements = [identity.copy()]

    all_gens = []
    for g in generators:
        all_gens.append(g % p)
        g_inv = mat_inv_gfp(g, p)
        if g_inv is not None:
            all_gens.append(g_inv % p)

    idx = 0
    while idx < len(queue) and len(elements) < max_size:
        current = queue[idx]
        idx += 1
        for gen in all_gens:
            product = mat_mul_gfp(current, gen, p)
            key = mat_to_key(product)
            if key not in seen:
                seen.add(key)
                queue.append(product.copy())
                elements.append(product.copy())

    return elements


def build_cayley_adjacency(elements: List[np.ndarray],
                           generators: List[np.ndarray],
                           p: int) -> np.ndarray:
    """Build the adjacency matrix of the Cayley graph.

    Args:
        elements: List of group elements
        generators: Symmetric generating set
        p: Prime field characteristic

    Returns:
        Adjacency matrix (numpy array)
    """
    n = len(elements)

    def mat_to_key(M):
        return tuple(M.flatten() % p)

    index_map = {mat_to_key(e): i for i, e in enumerate(elements)}

    # Symmetric generating set: S ∪ S⁻¹
    sym_gens = []
    for g in generators:
        sym_gens.append(g % p)
        g_inv = mat_inv_gfp(g, p)
        if g_inv is not None:
            sym_gens.append(g_inv % p)

    adj = np.zeros((n, n), dtype=int)
    for i, elem in enumerate(elements):
        for gen in sym_gens:
            product = mat_mul_gfp(elem, gen, p)
            key = mat_to_key(product)
            if key in index_map:
                j = index_map[key]
                adj[i, j] = 1

    return adj


def compute_spectral_gap(adj_matrix: np.ndarray) -> Dict[str, float]:
    """Compute the spectral gap of a graph from its adjacency matrix.

    The spectral gap is λ₁ - λ₂ where λ₁ is the largest eigenvalue
    and λ₂ is the second largest eigenvalue (in absolute value).

    For a d-regular graph, λ₁ = d and the normalized spectral gap
    is 1 - |λ₂|/d.

    Args:
        adj_matrix: Symmetric adjacency matrix

    Returns:
        Dictionary with spectral data
    """
    eigenvalues = np.sort(np.real(np.linalg.eigvalsh(adj_matrix)))[::-1]
    lambda_1 = eigenvalues[0]
    # Second largest in absolute value
    remaining = eigenvalues[1:]
    lambda_2_abs = max(abs(remaining)) if len(remaining) > 0 else 0

    normalized_gap = 1 - lambda_2_abs / lambda_1 if lambda_1 > 0 else 0

    return {
        "eigenvalues": eigenvalues.tolist(),
        "lambda_1": float(lambda_1),
        "lambda_2": float(eigenvalues[1]) if len(eigenvalues) > 1 else 0,
        "lambda_2_abs": float(lambda_2_abs),
        "spectral_gap": float(lambda_1 - lambda_2_abs),
        "normalized_gap": float(normalized_gap),
        "degree": float(lambda_1),
    }


def compute_vertex_expansion(elements: List[np.ndarray],
                              generators: List[np.ndarray],
                              p: int,
                              sample_sizes: Optional[List[int]] = None) -> Dict[str, Any]:
    """Estimate vertex expansion by sampling subsets.

    For each sample size k, takes random subsets A of size k and
    computes |∂A|/|A| where ∂A is the vertex boundary.

    Args:
        elements: Group elements
        generators: Symmetric generating set
        p: Prime field characteristic
        sample_sizes: Sizes of subsets to test

    Returns:
        Dictionary with expansion estimates
    """
    n = len(elements)
    if sample_sizes is None:
        sample_sizes = [k for k in [1, 2, 5, 10, n // 4, n // 2]
                        if 0 < k <= n // 2]

    def mat_to_key(M):
        return tuple(M.flatten() % p)

    index_map = {mat_to_key(e): i for i, e in enumerate(elements)}

    sym_gens = []
    for g in generators:
        sym_gens.append(g % p)
        g_inv = mat_inv_gfp(g, p)
        if g_inv is not None:
            sym_gens.append(g_inv % p)

    results = {}
    for k in sample_sizes:
        if k > n // 2:
            continue
        min_expansion = float('inf')
        num_trials = min(50, max(1, 1000 // k))
        for _ in range(num_trials):
            subset_indices = np.random.choice(n, size=k, replace=False)
            subset = set(subset_indices)
            boundary = set()
            for idx in subset_indices:
                elem = elements[idx]
                for gen in sym_gens:
                    prod = mat_mul_gfp(elem, gen, p)
                    key = mat_to_key(prod)
                    if key in index_map:
                        j = index_map[key]
                        if j not in subset:
                            boundary.add(j)
            expansion = len(boundary) / k if k > 0 else 0
            min_expansion = min(min_expansion, expansion)
        results[k] = {
            "subset_size": k,
            "min_boundary_ratio": float(min_expansion),
            "trials": num_trials,
        }

    return results


# ============================================================
# GL_2(GF(p)) baseline
# ============================================================

def enumerate_gl2(p: int) -> List[np.ndarray]:
    """Enumerate all elements of GL_2(GF(p))."""
    elements = []
    for a, b, c, d in iterproduct(range(p), repeat=4):
        M = np.array([[a, b], [c, d]], dtype=int)
        if mat_det_gfp(M, p) != 0:
            elements.append(M)
    return elements


def find_certified_pairs_gl2(p: int, max_pairs: int = 10) -> List[Tuple[np.ndarray, np.ndarray]]:
    """Find certified generator pairs in GL_2(GF(p)).

    A certified pair (s, t) has:
    - s with irreducible characteristic polynomial
    - No common eigenvector between s and t

    Args:
        p: Prime field characteristic
        max_pairs: Maximum number of pairs to find

    Returns:
        List of certified pairs
    """
    elements = enumerate_gl2(p)
    certified = []

    # Find elements with irreducible charpoly
    regular_toral = [M for M in elements if check_regular_toral(M, p)]

    for s in regular_toral[:max_pairs * 2]:
        for t in elements:
            if np.array_equal(s, t):
                continue
            if check_no_common_eigenvector(s, t, p):
                certified.append((s, t))
                if len(certified) >= max_pairs:
                    return certified
                break

    return certified


# ============================================================
# Search for certified pairs in specific classical groups
# ============================================================

def find_certified_pairs_sp4(p: int, max_pairs: int = 5) -> List[Dict[str, Any]]:
    """Search for certified generator pairs in Sp_4(GF(p)).

    Systematically searches for pairs (s, t) where:
    - Both s, t preserve the standard symplectic form
    - s has irreducible characteristic polynomial
    - The pair satisfies the classical certificate

    Args:
        p: Prime field characteristic
        max_pairs: Maximum number of pairs to return

    Returns:
        List of dictionaries with pair info and certificate data
    """
    results = []
    J = symplectic_form_4()

    # Generate candidate symplectic matrices
    candidates = []
    # Try random symplectic matrices
    np.random.seed(42)
    attempts = 0
    while len(candidates) < 200 and attempts < 5000:
        attempts += 1
        # Generate a random matrix and try to make it symplectic
        # Use the fact that [[A, B], [C, D]] is symplectic iff
        # A^T C = C^T A, B^T D = D^T B, A^T D - C^T B = I
        A = np.random.randint(0, p, (2, 2))
        B = np.random.randint(0, p, (2, 2))
        M = np.block([[A, B], [np.zeros((2, 2), dtype=int), np.zeros((2, 2), dtype=int)]])
        # Complete to symplectic if possible
        if mat_det_gfp(A, p) != 0:
            A_inv_T = mat_inv_gfp(A.T % p, p)
            if A_inv_T is not None:
                D = mat_mul_gfp(A_inv_T, (np.eye(2, dtype=int) + mat_mul_gfp(B.T % p, np.zeros((2, 2), dtype=int), p)), p)
                # Simpler: set C=0, D = (A^T)^{-1}
                C = np.zeros((2, 2), dtype=int)
                D = A_inv_T
                M = np.block([[A, B], [C, D]]) % p
                if is_symplectic(M, p):
                    candidates.append(M)

    # Also try some structured candidates
    for a in range(1, p):
        for b in range(p):
            # Upper triangular symplectic
            A = np.array([[a, b], [0, pow(a, p - 2, p)]], dtype=int) % p
            B_mat = np.array([[0, 1], [0, 0]], dtype=int)
            C_mat = np.zeros((2, 2), dtype=int)
            D_mat = np.array([[pow(a, p - 2, p), (p - b * pow(a, p - 2, p) * pow(a, p - 2, p)) % p],
                             [0, a]], dtype=int) % p
            M = np.block([[A, B_mat], [C_mat, D_mat]]) % p
            if is_symplectic(M, p) and mat_det_gfp(M, p) != 0:
                candidates.append(M)

    # Check certificates
    for i, s in enumerate(candidates):
        if not check_regular_toral(s, p):
            continue
        for j, t in enumerate(candidates):
            if i == j:
                continue
            cert = check_classical_certificate(s, t, p)
            if cert["certificate_valid"]:
                results.append({
                    "s": s.tolist(),
                    "t": t.tolist(),
                    "certificate": cert,
                    "group": f"Sp_4(GF({p}))",
                })
                if len(results) >= max_pairs:
                    return results

    return results


def find_certified_pairs_so3(p: int, max_pairs: int = 5) -> List[Dict[str, Any]]:
    """Search for certified generator pairs in SO_3(GF(p)).

    Args:
        p: Prime field characteristic (odd)
        max_pairs: Maximum number of pairs to return

    Returns:
        List of dictionaries with pair info and certificate data
    """
    results = []

    # Enumerate SO_3(GF(p)) elements (small enough for p=3,5)
    candidates = []
    for entries in iterproduct(range(p), repeat=9):
        M = np.array(entries, dtype=int).reshape(3, 3)
        if is_orthogonal(M, p) and mat_det_gfp(M, p) == 1:
            candidates.append(M)

    for i, s in enumerate(candidates):
        if not check_regular_toral(s, p):
            continue
        for j, t in enumerate(candidates):
            if i == j:
                continue
            cert = check_classical_certificate(s, t, p)
            if cert["certificate_valid"]:
                results.append({
                    "s": s.tolist(),
                    "t": t.tolist(),
                    "certificate": cert,
                    "group": f"SO_3(GF({p}))",
                })
                if len(results) >= max_pairs:
                    return results

    return results


# ============================================================
# Full pipeline: certificate → spectral gap
# ============================================================

def certified_expander_pipeline(s: np.ndarray, t: np.ndarray, p: int,
                                 group_name: str = "unknown") -> Dict[str, Any]:
    """Run the full certified expander pipeline on a generator pair.

    1. Check classical certificate
    2. Enumerate the generated subgroup
    3. Build the Cayley graph
    4. Compute spectral gap
    5. Estimate vertex expansion

    Args:
        s, t: Generator matrices
        p: Prime field characteristic
        group_name: Name of the group for reporting

    Returns:
        Complete pipeline results
    """
    # Step 1: Certificate
    cert = check_classical_certificate(s, t, p)

    # Step 2: Enumerate subgroup
    elements = enumerate_subgroup([s, t], p)
    subgroup_order = len(elements)

    # Step 3: Cayley graph
    adj = build_cayley_adjacency(elements, [s, t], p)

    # Step 4: Spectral gap
    spectral = compute_spectral_gap(adj)

    # Step 5: Vertex expansion
    expansion = compute_vertex_expansion(elements, [s, t], p)

    return {
        "group": group_name,
        "prime": p,
        "certificate": cert,
        "subgroup_order": subgroup_order,
        "spectral": spectral,
        "expansion": expansion,
        "s": s.tolist(),
        "t": t.tolist(),
    }


if __name__ == "__main__":
    # Example: GL_2(GF(3))
    print("=" * 60)
    print("Certified Expander Pipeline — GL_2(GF(3))")
    print("=" * 60)

    p = 3
    # A matrix with irreducible charpoly over GF(3): x^2 + 1
    s = np.array([[0, 1], [2, 0]], dtype=int)  # charpoly = x^2 + 2 (irreducible mod 3)
    t = np.array([[1, 1], [0, 1]], dtype=int)  # upper triangular

    result = certified_expander_pipeline(s, t, p, "GL_2(GF(3))")

    print(f"\nCertificate valid: {result['certificate']['certificate_valid']}")
    print(f"  s regular toral: {result['certificate']['s_regular_toral']}")
    print(f"  s charpoly: {result['certificate']['s_charpoly']}")
    print(f"  No common eigenvector: {result['certificate']['no_common_eigenvector']}")
    print(f"\nSubgroup order: {result['subgroup_order']}")
    print(f"GL_2(GF(3)) order: {(3**2 - 1) * (3**2 - 3)}")
    print(f"\nSpectral data:")
    print(f"  Degree: {result['spectral']['degree']:.0f}")
    print(f"  Lambda_2 (abs): {result['spectral']['lambda_2_abs']:.4f}")
    print(f"  Normalized gap: {result['spectral']['normalized_gap']:.4f}")
    print(f"\nVertex expansion estimates:")
    for k, data in result['expansion'].items():
        print(f"  |A|={k}: min boundary ratio = {data['min_boundary_ratio']:.4f}")
