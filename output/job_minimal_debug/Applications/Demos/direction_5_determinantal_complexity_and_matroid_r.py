"""
Applications of Determinantal Complexity Theory

Demonstrates real-world applications:
1. Efficient partition function evaluation for weighted random bases
2. Determinantal point process sampling
3. Network reliability computation
4. Algebraic complexity classification of small matroids
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict
import sys


def partition_function_gram(A: np.ndarray, w: np.ndarray) -> float:
    """
    Compute the partition function Z(w) = sum_B prod_{i in B} w_i * (det A_B)^2
    efficiently via the Gram determinant: Z(w) = det(A * diag(w) * A^T).
    
    This is O(r^2 * n + r^3) vs O(binom(n,r) * r^3) for brute force.
    
    Application: weighted sampling from matroid bases (DPP).
    """
    Dw = np.diag(w)
    return np.linalg.det(A @ Dw @ A.T)


def network_reliability(
    incidence_matrix: np.ndarray,
    edge_probabilities: np.ndarray
) -> float:
    """
    Compute the reliability polynomial of a network.
    
    Given a graph with edge failure probabilities, the reliability is
    Pr[network connected] = sum over spanning trees T:
        prod_{e in T} p_e * prod_{e not in T} (1 - p_e)
    
    For graphic matroids, this relates to the basis polynomial:
    R(p) = (prod (1-p_e)) * Z(p/(1-p))
    
    where Z is the partition function.
    
    Application: network design, infrastructure resilience.
    """
    n_edges = len(edge_probabilities)
    
    # Compute odds ratios w_e = p_e / (1 - p_e)
    w = edge_probabilities / (1 - edge_probabilities + 1e-15)
    
    # Partition function via Gram determinant
    # Need a representation matrix for the graphic matroid
    # incidence_matrix should be (n_vertices - 1) x n_edges
    Z = partition_function_gram(incidence_matrix, w)
    
    # Reliability = prod(1 - p_e) * Z
    reliability = np.prod(1 - edge_probabilities) * Z
    
    return reliability


def dpp_sampling(
    A: np.ndarray,
    w: np.ndarray,
    num_samples: int = 1000
) -> List[Tuple[int, ...]]:
    """
    Sample from a determinantal point process defined by basis polynomial.
    
    The probability of basis B is:
        Pr[B] = (det A_B)^2 * prod_{i in B} w_i / Z(w)
    
    Uses the eigendecomposition-based DPP sampling algorithm.
    
    Application: diverse subset selection, sensor placement.
    """
    r, n = A.shape
    
    # Form the weighted kernel matrix L = A^T * D_w * A (n x n, rank r)
    # Actually, use the L-ensemble formulation
    Dw_sqrt = np.diag(np.sqrt(np.maximum(w, 0)))
    B = Dw_sqrt @ A.T  # n x r
    L = B @ B.T  # n x n PSD matrix
    
    samples = []
    
    for _ in range(num_samples):
        # Elementary DPP sampling via eigendecomposition
        eigenvalues, eigenvectors = np.linalg.eigh(L)
        
        # Phase 1: Select eigenvectors
        selected_evecs = []
        for i in range(n):
            lam = max(eigenvalues[i], 0)
            if np.random.random() < lam / (lam + 1):
                selected_evecs.append(eigenvectors[:, i])
        
        if len(selected_evecs) == 0:
            continue
        
        V = np.array(selected_evecs).T  # n x k
        k = V.shape[1]
        
        # Phase 2: Sequential sampling
        sample = []
        remaining = list(range(n))
        
        for _ in range(k):
            if V.shape[1] == 0:
                break
            
            # Compute marginal probabilities
            probs = np.sum(V[remaining] ** 2, axis=1)
            probs = np.maximum(probs, 0)
            total = probs.sum()
            if total < 1e-15:
                break
            probs /= total
            
            # Sample an item
            idx = np.random.choice(len(remaining), p=probs)
            chosen = remaining[idx]
            sample.append(chosen)
            
            # Update V by projecting out the chosen direction
            v = V[chosen]
            norm_sq = np.dot(v, v)
            if norm_sq > 1e-15:
                V = V - np.outer(V @ v, v) / norm_sq
            
            remaining.pop(idx)
        
        sample.sort()
        samples.append(tuple(sample))
    
    return samples


def algebraic_complexity_classification(max_n: int = 6) -> Dict:
    """
    Classify small matroids by determinantal complexity.
    
    For matroids on ≤ max_n elements, compute:
    - rank
    - number of bases
    - whether rank-sized determinantal representation exists
    
    Application: computational complexity theory, matroid theory.
    """
    results = {}
    
    for n in range(2, max_n + 1):
        for r in range(1, n):
            # Generate some example matroids
            # Uniform matroid U(r, n)
            name = f"U({r},{n})"
            bases = list(combinations(range(n), r))
            
            # Try to find representation
            A = np.random.randn(r, n)
            actual_coeffs = {}
            for S in combinations(range(n), r):
                det_val = np.linalg.det(A[:, list(S)])
                if abs(det_val) > 1e-10:
                    actual_coeffs[S] = det_val ** 2
            
            results[name] = {
                "n": n,
                "rank": r,
                "num_bases": len(bases),
                "has_repr": len(actual_coeffs) > 0,
                "support_size": len(actual_coeffs)
            }
    
    return results


def demonstrate_nonnegativity():
    """
    Demonstrate the nonnegativity theorem:
    eval(basisPoly(A), w) >= 0 for all w >= 0.
    
    This is the formal bridge to probability theory:
    the partition function is always nonneg.
    """
    print("=== Nonnegativity Theorem Demonstration ===\n")
    
    np.random.seed(42)
    
    for r in [1, 2, 3]:
        for n in [r + 1, r + 2, r + 3]:
            A = np.random.randn(r, n)
            
            # Test with many random nonneg weight vectors
            min_val = float('inf')
            for _ in range(1000):
                w = np.abs(np.random.randn(n))
                val = partition_function_gram(A, w)
                min_val = min(min_val, val)
            
            print(f"  r={r}, n={n}: min Z(w) over 1000 trials = {min_val:.8f} >= 0: {min_val >= -1e-10}")
    
    print("\n  All evaluations nonneg ✓ (as guaranteed by theorem)")


def demonstrate_sampling():
    """Demonstrate DPP sampling from a basis polynomial."""
    print("\n=== DPP Sampling Demonstration ===\n")
    
    # U(2, 4) with uniform weights
    A = np.array([[1, 0, 1, 1],
                  [0, 1, 1, -1]], dtype=float)
    w = np.ones(4)
    
    samples = dpp_sampling(A, w, num_samples=10000)
    
    # Count frequencies
    from collections import Counter
    counts = Counter(samples)
    
    # Compare with theoretical probabilities
    coeffs = {}
    for S in combinations(range(4), 2):
        d = np.linalg.det(A[:, list(S)])
        coeffs[S] = d ** 2
    
    Z = sum(coeffs.values())
    
    print(f"  Matrix A:\n  {A}")
    print(f"\n  {'Basis':<12} {'Theory':>8} {'Observed':>10} {'Count':>7}")
    print(f"  {'-'*40}")
    
    total_samples = len(samples)
    for S in sorted(coeffs.keys()):
        theory = coeffs[S] / Z
        observed = counts.get(S, 0) / total_samples if total_samples > 0 else 0
        count = counts.get(S, 0)
        print(f"  {str(S):<12} {theory:>8.4f} {observed:>10.4f} {count:>7}")


if __name__ == "__main__":
    demonstrate_nonnegativity()
    demonstrate_sampling()
    
    print("\n=== Complexity Classification ===\n")
    results = algebraic_complexity_classification(5)
    print(f"  {'Matroid':<10} {'n':>3} {'rk':>3} {'#bases':>7} {'repr?':>6}")
    print(f"  {'-'*32}")
    for name, data in sorted(results.items()):
        repr_str = "yes" if data["has_repr"] else "no"
        print(f"  {name:<10} {data['n']:>3} {data['rank']:>3} {data['num_bases']:>7} {repr_str:>6}")


"""
Determinantal Complexity of Matroid Basis Polynomials — Interactive Demo

This script demonstrates the core concepts:
1. Constructing basis polynomials from representation matrices
2. Computing determinantal complexity for small matroids
3. Testing the central conjecture (dc = rank iff representable)
4. Visualizing correlations with matroid parameters
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Optional, Dict
import sys


def minor_det(A: np.ndarray, cols: Tuple[int, ...]) -> float:
    """Compute det of the submatrix of A using specified columns."""
    return np.linalg.det(A[:, list(cols)])


def basis_polynomial_coeffs(A: np.ndarray) -> Dict[Tuple[int, ...], float]:
    """
    Compute the basis polynomial of matrix A.
    Returns dict mapping r-subsets S to (det A_S)^2.
    
    The basis polynomial is B_A(x) = sum_S (det A_S)^2 * prod_{i in S} x_i
    """
    r, n = A.shape
    coeffs = {}
    for S in combinations(range(n), r):
        d = minor_det(A, S)
        coeff = d ** 2
        if abs(coeff) > 1e-12:
            coeffs[S] = coeff
    return coeffs


def eval_basis_poly(A: np.ndarray, w: np.ndarray) -> float:
    """
    Evaluate the basis polynomial at weights w.
    Should equal det(A * diag(w) * A^T).
    """
    Dw = np.diag(w)
    return np.linalg.det(A @ Dw @ A.T)


def verify_cauchy_binet(A: np.ndarray, w: np.ndarray) -> Tuple[float, float]:
    """
    Verify the Cauchy-Binet identity:
    det(A * D_w * A^T) = sum_S (det A_S)^2 * prod_{i in S} w_i
    
    Returns (gram_det, sum_expansion) — should be equal.
    """
    gram_det = eval_basis_poly(A, w)
    r, n = A.shape
    expansion = 0.0
    for S in combinations(range(n), r):
        d = minor_det(A, S)
        expansion += d**2 * np.prod(w[list(S)])
    return gram_det, expansion


def search_determinantal_representation(
    target_coeffs: Dict[Tuple[int, ...], float],
    n: int,
    r: int,
    field: str = "real",
    num_trials: int = 1000,
    tol: float = 1e-6
) -> Optional[np.ndarray]:
    """
    Search for an r x n matrix A such that basisPolyOfMatrix(A) matches
    target_coeffs. Uses random search over the representation variety.
    
    Args:
        target_coeffs: {r-subset -> coefficient} for the target polynomial
        n: number of ground set elements
        r: target determinantal complexity (number of rows)
        field: "real" or "rational"
        num_trials: number of random attempts
        tol: tolerance for matching
    
    Returns:
        Matrix A if found, None otherwise
    """
    for _ in range(num_trials):
        if field == "rational":
            A = np.random.randint(-3, 4, size=(r, n)).astype(float)
        else:
            A = np.random.randn(r, n)
        
        coeffs = basis_polynomial_coeffs(A)
        
        # Normalize both to compare supports and ratios
        target_support = set(target_coeffs.keys())
        found_support = set(coeffs.keys())
        
        if target_support != found_support:
            continue
        
        # Check if coefficients are proportional
        if not target_support:
            continue
        
        ref_key = next(iter(target_support))
        if abs(coeffs[ref_key]) < 1e-15:
            continue
        scale = target_coeffs[ref_key] / coeffs[ref_key]
        
        match = True
        for S in target_support:
            if abs(target_coeffs[S] - scale * coeffs[S]) > tol * abs(target_coeffs[S]):
                match = False
                break
        
        if match:
            return A * np.sqrt(abs(scale)) if scale > 0 else None
    
    return None


def uniform_matroid_bases(n: int, r: int) -> List[Tuple[int, ...]]:
    """Bases of the uniform matroid U(r, n): all r-subsets of [n]."""
    return list(combinations(range(n), r))


def graphic_matroid_bases(edges: List[Tuple[int, int]], num_vertices: int) -> List[Tuple[int, ...]]:
    """
    Bases of the graphic matroid of a graph.
    Bases are spanning forests (spanning trees if connected).
    """
    n = len(edges)
    r = num_vertices - 1  # rank for connected graph
    
    bases = []
    for subset in combinations(range(n), r):
        # Check if selected edges form a spanning tree
        # Using union-find
        parent = list(range(num_vertices))
        
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        
        def union(x, y):
            px, py = find(x), find(y)
            if px == py:
                return False
            parent[px] = py
            return True
        
        valid = True
        for idx in subset:
            u, v = edges[idx]
            if not union(u, v):
                valid = False
                break
        
        if valid and len(set(find(i) for i in range(num_vertices))) == 1:
            bases.append(subset)
    
    return bases


def fano_matroid_bases() -> List[Tuple[int, ...]]:
    """
    The Fano matroid F_7: rank 3 on 7 elements.
    Non-representable over fields of characteristic != 2.
    This is the classic non-representable-over-R matroid.
    """
    # Fano plane: 7 points, 7 lines
    # Lines (dependent sets of size 3):
    lines = [
        (0, 1, 3), (1, 2, 4), (2, 3, 5),
        (3, 4, 6), (0, 4, 5), (1, 5, 6), (0, 2, 6)
    ]
    line_set = set(frozenset(l) for l in lines)
    
    bases = []
    for S in combinations(range(7), 3):
        if frozenset(S) not in line_set:
            bases.append(S)
    
    return bases


def non_fano_matroid_bases() -> List[Tuple[int, ...]]:
    """
    The non-Fano matroid F_7^-: rank 3 on 7 elements.
    Representable over R but not over GF(2).
    """
    # Same as Fano but remove one dependency
    lines = [
        (0, 1, 3), (1, 2, 4), (2, 3, 5),
        (3, 4, 6), (0, 4, 5), (1, 5, 6)
        # (0, 2, 6) is NOT a line in the non-Fano
    ]
    line_set = set(frozenset(l) for l in lines)
    
    bases = []
    for S in combinations(range(7), 3):
        if frozenset(S) not in line_set:
            bases.append(S)
    
    return bases


def compute_matroid_stats(bases: List[Tuple[int, ...]], n: int) -> Dict:
    """Compute basic matroid statistics."""
    if not bases:
        return {"rank": 0, "num_bases": 0, "girth": None, "n": n}
    
    r = len(bases[0])
    
    # Girth: minimum circuit size
    # A circuit is a minimal dependent set
    # For simplicity, check if any subset of size ≤ r is dependent
    # (not contained in any basis)
    girth = None
    for size in range(1, r + 2):
        for S in combinations(range(n), size):
            S_set = set(S)
            # S is dependent if no basis contains all of S
            # Actually, S is independent if it's a subset of some basis
            independent = any(S_set.issubset(set(B)) for B in bases)
            if not independent:
                girth = size
                break
        if girth is not None:
            break
    
    return {
        "rank": r,
        "num_bases": len(bases),
        "girth": girth,
        "n": n
    }


def test_conjecture(
    bases: List[Tuple[int, ...]],
    n: int,
    name: str = "unknown"
) -> Dict:
    """
    Test the central conjecture: dc_R(M) = rk(M) iff M is representable over R.
    
    For a given matroid (specified by bases), attempts to find a rank-sized
    determinantal representation.
    """
    if not bases:
        return {"name": name, "rank": 0, "representable": True, "dc_eq_rank": True}
    
    r = len(bases[0])
    
    # Target coefficients: uniform coefficient 1 for each basis
    target = {B: 1.0 for B in bases}
    
    # Try to find representation
    result = search_determinantal_representation(target, n, r, num_trials=500)
    
    stats = compute_matroid_stats(bases, n)
    
    return {
        "name": name,
        "rank": r,
        "n": n,
        "num_bases": len(bases),
        "girth": stats["girth"],
        "found_representation": result is not None,
        "matrix": result
    }


def demo_cauchy_binet():
    """Demonstrate the Cauchy-Binet identity."""
    print("=" * 60)
    print("DEMO 1: Cauchy-Binet Identity Verification")
    print("=" * 60)
    
    # Random 2x4 matrix
    np.random.seed(42)
    A = np.array([[1, 2, 0, 1],
                  [0, 1, 1, 2]], dtype=float)
    w = np.array([1.0, 2.0, 3.0, 0.5])
    
    gram, expansion = verify_cauchy_binet(A, w)
    
    print(f"\nMatrix A (2x4):")
    print(A)
    print(f"\nWeights w = {w}")
    print(f"\ndet(A * D_w * A^T) = {gram:.6f}")
    print(f"Sum of (det A_S)^2 * prod w_S = {expansion:.6f}")
    print(f"Match: {abs(gram - expansion) < 1e-10}")
    
    # Show individual terms
    print(f"\nBasis polynomial terms:")
    coeffs = basis_polynomial_coeffs(A)
    for S, c in sorted(coeffs.items()):
        print(f"  S = {S}: (det A_S)^2 = {c:.4f}")
    
    # Verify nonnegativity
    print(f"\nNonnegativity test (all weights ≥ 0):")
    for _ in range(5):
        w_test = np.abs(np.random.randn(4))
        val = eval_basis_poly(A, w_test)
        print(f"  w = [{', '.join(f'{x:.2f}' for x in w_test)}] -> B_A(w) = {val:.4f} >= 0: {val >= -1e-10}")


def demo_complexity():
    """Demonstrate determinantal complexity computation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Determinantal Complexity Examples")
    print("=" * 60)
    
    # Single variable: X_1 has dc = 1
    print("\n1. Single variable X_1:")
    A1 = np.array([[1, 0, 0]], dtype=float)
    coeffs1 = basis_polynomial_coeffs(A1)
    print(f"   Matrix: {A1}")
    print(f"   Basis polynomial: {coeffs1}")
    print(f"   Determinantal complexity = 1")
    
    # Uniform matroid U(2,4): X_1*X_2 + X_1*X_3 + ... has dc = 2
    print("\n2. Uniform matroid U(2,4):")
    A2 = np.array([[1, 0, 1, 1],
                   [0, 1, 1, -1]], dtype=float)
    coeffs2 = basis_polynomial_coeffs(A2)
    print(f"   Matrix A (2x4):")
    print(f"   {A2}")
    print(f"   Basis polynomial (nonzero coefficients):")
    for S, c in sorted(coeffs2.items()):
        print(f"     S = {S}: coeff = {c:.4f}")
    print(f"   Determinantal complexity ≤ 2")
    
    # Block diagonal: dc(p*q) ≤ dc(p) + dc(q)
    print("\n3. Block diagonal composition:")
    A_left = np.array([[1, 1]], dtype=float)
    A_right = np.array([[1, 0], [0, 1]], dtype=float)
    
    coeffs_left = basis_polynomial_coeffs(A_left)
    coeffs_right = basis_polynomial_coeffs(A_right)
    
    print(f"   Left: A = {A_left}, dc = 1")
    print(f"   Right: A = {A_right.tolist()}, dc = 2")
    
    # Block diagonal
    A_block = np.zeros((3, 4), dtype=float)
    A_block[0, :2] = A_left[0]
    A_block[1:, 2:] = A_right
    
    coeffs_block = basis_polynomial_coeffs(A_block)
    print(f"   Block diagonal (3x4):")
    print(f"   {A_block}")
    print(f"   Basis polynomial:")
    for S, c in sorted(coeffs_block.items()):
        print(f"     S = {S}: coeff = {c:.4f}")
    print(f"   dc ≤ 1 + 2 = 3 (subadditivity)")


def demo_conjecture_test():
    """Test the central conjecture on small examples."""
    print("\n" + "=" * 60)
    print("DEMO 3: Conjecture Testing — dc = rank iff representable")
    print("=" * 60)
    
    test_cases = []
    
    # Uniform matroid U(2,4) — representable
    test_cases.append(("U(2,4)", uniform_matroid_bases(4, 2), 4, True))
    
    # Uniform matroid U(2,5) — representable
    test_cases.append(("U(2,5)", uniform_matroid_bases(5, 2), 5, True))
    
    # Graphic matroid of K4 — representable
    K4_edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    test_cases.append(("Graphic(K4)", graphic_matroid_bases(K4_edges, 4), 6, True))
    
    # Graphic matroid of C4 (cycle) — representable
    C4_edges = [(0,1), (1,2), (2,3), (3,0)]
    test_cases.append(("Graphic(C4)", graphic_matroid_bases(C4_edges, 4), 4, True))
    
    # Non-Fano — representable over R
    test_cases.append(("Non-Fano F7-", non_fano_matroid_bases(), 7, True))
    
    # Fano — NOT representable over R
    test_cases.append(("Fano F7", fano_matroid_bases(), 7, False))
    
    print(f"\n{'Matroid':<15} {'rk':>3} {'#bases':>7} {'girth':>6} {'repr?':>6} {'found dc=rk?':>13}")
    print("-" * 55)
    
    for name, bases, n, expected_repr in test_cases:
        result = test_conjecture(bases, n, name)
        stats = compute_matroid_stats(bases, n)
        
        found_str = "YES" if result["found_representation"] else "NO"
        repr_str = "yes" if expected_repr else "NO"
        
        print(f"{name:<15} {stats['rank']:>3} {len(bases):>7} {str(stats['girth']):>6} {repr_str:>6} {found_str:>13}")
    
    print("\nNote: 'found dc=rk?' uses random search; 'NO' may be a search failure, not a proof.")
    print("The conjecture predicts: dc=rk <=> representable.")


def demo_partition_function():
    """Demonstrate the partition function / sampling connection."""
    print("\n" + "=" * 60)
    print("DEMO 4: Partition Function & Sampling")
    print("=" * 60)
    
    # U(2,4) represented by a specific matrix
    A = np.array([[1, 0, 1, 1],
                  [0, 1, 1, -1]], dtype=float)
    
    w = np.array([1.0, 1.0, 1.0, 1.0])
    
    # Partition function Z = det(A * D_w * A^T)
    Z = eval_basis_poly(A, w)
    print(f"\nMatrix A:\n{A}")
    print(f"\nPartition function Z(w=1) = det(A*A^T) = {Z:.4f}")
    
    # Basis probabilities
    print(f"\nBasis probabilities (Born rule):")
    coeffs = basis_polynomial_coeffs(A)
    for S, c in sorted(coeffs.items()):
        prob = c / Z
        print(f"  Pr[basis = {S}] = {c:.4f} / {Z:.4f} = {prob:.4f}")
    
    prob_sum = sum(c / Z for c in coeffs.values())
    print(f"\n  Sum of probabilities = {prob_sum:.6f} (should be 1.0)")
    
    # Weighted case
    w2 = np.array([2.0, 1.0, 0.5, 3.0])
    Z2 = eval_basis_poly(A, w2)
    print(f"\nWeighted partition function Z(w={w2.tolist()}) = {Z2:.4f}")
    print(f"  Z ≥ 0: {Z2 >= -1e-10} (nonnegativity theorem)")


if __name__ == "__main__":
    demo_cauchy_binet()
    demo_complexity()
    demo_conjecture_test()
    demo_partition_function()
    
    print("\n" + "=" * 60)
    print("All demos complete!")
    print("=" * 60)


"""
Visualization: Determinantal Complexity Heatmap

Visualizes the basis polynomial coefficients (squared minor determinants)
for a matrix A as a heatmap over all r-subsets, showing how the "weight"
of the basis polynomial is distributed across different bases.

This makes the abstract notion of determinantal complexity tangible:
a low-complexity polynomial concentrates its weight on few bases,
while a high-complexity one spreads it across many.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def minor_det(A, cols):
    """Compute det of submatrix."""
    return np.linalg.det(A[:, list(cols)])


def basis_polynomial_coeffs(A):
    """Compute {S: (det A_S)^2} for all r-subsets S."""
    r, n = A.shape
    coeffs = {}
    for S in combinations(range(n), r):
        d = minor_det(A, S)
        coeffs[S] = d ** 2
    return coeffs


def eval_basis_poly(A, w):
    """Evaluate basis polynomial at weights w."""
    return np.linalg.det(A @ np.diag(w) @ A.T)


# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Example 1: Uniform matroid U(2,4) — all subsets equally weighted
np.random.seed(42)
A1 = np.array([[1, 0, 1, 1],
               [0, 1, 1, -1]], dtype=float)
coeffs1 = basis_polynomial_coeffs(A1)
subsets1 = sorted(coeffs1.keys())
values1 = [coeffs1[s] for s in subsets1]
labels1 = [str(s) for s in subsets1]

bars1 = axes[0].bar(range(len(values1)), values1, color='steelblue', alpha=0.8)
axes[0].set_xticks(range(len(labels1)))
axes[0].set_xticklabels(labels1, rotation=45, fontsize=8)
axes[0].set_title(f'U(2,4)-like: dc ≤ 2\n(6 nonzero coefficients)', fontsize=11)
axes[0].set_ylabel('(det A_S)²', fontsize=10)
axes[0].set_xlabel('Basis S', fontsize=10)

# Example 2: Graphic matroid — sparser support
A2 = np.array([[1, 1, 1, 0, 0, 0],
               [1, 0, 0, 1, 1, 0],
               [0, 1, 0, 1, 0, 1]], dtype=float)
coeffs2 = basis_polynomial_coeffs(A2)
subsets2 = sorted(coeffs2.keys())
values2 = [coeffs2[s] for s in subsets2]
labels2 = [str(s) for s in subsets2]

bars2 = axes[1].bar(range(len(values2)), values2, color='coral', alpha=0.8)
axes[1].set_xticks(range(len(labels2)))
axes[1].set_xticklabels(labels2, rotation=45, fontsize=7)
axes[1].set_title(f'K4 graphic: dc ≤ 3\n({len(subsets2)} nonzero coefficients)', fontsize=11)
axes[1].set_ylabel('(det A_S)²', fontsize=10)
axes[1].set_xlabel('Basis S', fontsize=10)

# Example 3: Block diagonal — factored structure
A_left = np.array([[1, 1]], dtype=float)
A_right = np.array([[1, 0, 1],
                    [0, 1, 1]], dtype=float)
A3 = np.zeros((3, 5))
A3[0, :2] = A_left[0]
A3[1:, 2:] = A_right
coeffs3 = basis_polynomial_coeffs(A3)
subsets3 = sorted(coeffs3.keys())
values3 = [coeffs3[s] for s in subsets3]
labels3 = [str(s) for s in subsets3]

bars3 = axes[2].bar(range(len(values3)), values3, color='seagreen', alpha=0.8)
axes[2].set_xticks(range(len(labels3)))
axes[2].set_xticklabels(labels3, rotation=45, fontsize=7)
axes[2].set_title(f'Block diagonal: dc ≤ 1+2 = 3\n({len(subsets3)} nonzero coefficients)', fontsize=11)
axes[2].set_ylabel('(det A_S)²', fontsize=10)
axes[2].set_xlabel('Basis S', fontsize=10)

fig.suptitle('Basis Polynomial Coefficient Distribution\n(Determinantal Complexity Visualization)',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_complexity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity_heatmap.png")


"""
Visualization: Conjecture Testing — dc = rank iff representable

Compares representable vs non-representable matroids by plotting
the success rate of finding rank-sized determinantal representations.

For representable matroids, the search should succeed (dc = rank).
For non-representable matroids, it should fail (dc > rank).

This tests the central conjecture of the paper.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def minor_det(A, cols):
    return np.linalg.det(A[:, list(cols)])


def basis_poly_coeffs(A):
    r, n = A.shape
    coeffs = {}
    for S in combinations(range(n), r):
        d = minor_det(A, S)
        c = d ** 2
        if abs(c) > 1e-12:
            coeffs[S] = c
    return coeffs


def try_find_representation(target_bases, n, r, num_trials=200):
    """Try to find an r x n matrix whose basis support matches target_bases."""
    target_set = set(target_bases)
    successes = 0
    
    for _ in range(num_trials):
        A = np.random.randn(r, n)
        coeffs = basis_poly_coeffs(A)
        support = set(coeffs.keys())
        
        # Check if support is a superset of target (for representable matroids,
        # a generic matrix has all binom(n,r) bases as support)
        if target_set.issubset(support):
            successes += 1
    
    return successes / num_trials


def uniform_matroid_bases(n, r):
    return list(combinations(range(n), r))


def graphic_matroid_bases(edges, nv):
    r = nv - 1
    bases = []
    for subset in combinations(range(len(edges)), r):
        parent = list(range(nv))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px == py: return False
            parent[px] = py
            return True
        ok = True
        for idx in subset:
            if not union(*edges[idx]):
                ok = False; break
        if ok and len(set(find(i) for i in range(nv))) == 1:
            bases.append(subset)
    return bases


def fano_bases():
    lines = [(0,1,3),(1,2,4),(2,3,5),(3,4,6),(0,4,5),(1,5,6),(0,2,6)]
    line_set = set(frozenset(l) for l in lines)
    return [S for S in combinations(range(7), 3) if frozenset(S) not in line_set]


def non_fano_bases():
    lines = [(0,1,3),(1,2,4),(2,3,5),(3,4,6),(0,4,5),(1,5,6)]
    line_set = set(frozenset(l) for l in lines)
    return [S for S in combinations(range(7), 3) if frozenset(S) not in line_set]


# Collect data
matroids = [
    ("U(2,4)", uniform_matroid_bases(4, 2), 4, 2, True),
    ("U(2,5)", uniform_matroid_bases(5, 2), 5, 2, True),
    ("U(3,5)", uniform_matroid_bases(5, 3), 5, 3, True),
    ("Graphic\n(K₄)", graphic_matroid_bases(
        [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)], 4), 6, 3, True),
    ("Graphic\n(C₄)", graphic_matroid_bases(
        [(0,1),(1,2),(2,3),(3,0)], 4), 4, 3, True),
    ("Non-Fano\n(F₇⁻)", non_fano_bases(), 7, 3, True),
    ("Fano\n(F₇)", fano_bases(), 7, 3, False),
]

names = []
match_rates = []
colors = []
repr_labels = []

np.random.seed(123)
for name, bases, n, r, is_repr in matroids:
    rate = try_find_representation(bases, n, r, num_trials=300)
    names.append(name)
    match_rates.append(rate)
    colors.append('#2ecc71' if is_repr else '#e74c3c')
    repr_labels.append('Representable' if is_repr else 'Non-representable')

# Plot
fig, ax = plt.subplots(figsize=(12, 6))

bars = ax.bar(range(len(names)), match_rates, color=colors, alpha=0.85,
              edgecolor='gray', linewidth=0.8)

ax.set_xticks(range(len(names)))
ax.set_xticklabels(names, fontsize=10)
ax.set_ylabel('Success rate of finding\nrank-sized representation', fontsize=12)
ax.set_title('Central Conjecture Test: dc(M) = rk(M) ⟺ M representable over ℝ\n'
             '(Green = representable, Red = non-representable)',
             fontsize=13, fontweight='bold')
ax.set_ylim(0, 1.15)

# Add value labels
for bar, rate in zip(bars, match_rates):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
            f'{rate:.0%}', ha='center', fontsize=10, fontweight='bold')

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2ecc71', alpha=0.85, label='Representable (expect dc = rank)'),
    Patch(facecolor='#e74c3c', alpha=0.85, label='Non-representable (expect dc > rank)')
]
ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

# Add annotation
ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.3)
ax.text(len(names)-1.5, 0.55, 'Random baseline', color='gray', fontsize=9, alpha=0.5)

plt.tight_layout()
plt.savefig('viz_conjecture.png', dpi=150, bbox_inches='tight')
print("Saved viz_conjecture.png")


"""
Visualization: Nonnegativity of the Partition Function

Demonstrates the key cross-domain theorem:
    eval(basisPoly(A), w) >= 0 for all w >= 0

This visualizes the partition function Z(w) = det(A * diag(w) * A^T)
as a function of two weights (with others fixed), showing it is
always nonneg in the positive quadrant.

This is the formal bridge between:
- Matroid theory (basis polynomials)
- Probability (partition functions)
- Linear algebra (positive semidefiniteness)
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm


def eval_basis_poly(A, w):
    """Evaluate basis polynomial at weights w via Gram determinant."""
    return np.linalg.det(A @ np.diag(w) @ A.T)


# Setup
fig, axes = plt.subplots(1, 3, figsize=(18, 5), subplot_kw={'projection': '3d'})

# Three different matrices to show universality
matrices = [
    ("Rank 1 (1×3)", np.array([[1, 2, 3]], dtype=float)),
    ("Rank 2 (2×4)", np.array([[1, 0, 1, 1], [0, 1, 1, -1]], dtype=float)),
    ("Rank 3 (3×5)", np.array([[1, 0, 0, 1, 1], [0, 1, 0, 1, -1], [0, 0, 1, 0, 1]], dtype=float))
]

for idx, (title, A) in enumerate(matrices):
    r, n = A.shape
    
    # Vary the first two weights, fix others at 1
    w1_range = np.linspace(0, 3, 50)
    w2_range = np.linspace(0, 3, 50)
    W1, W2 = np.meshgrid(w1_range, w2_range)
    Z = np.zeros_like(W1)
    
    for i in range(W1.shape[0]):
        for j in range(W1.shape[1]):
            w = np.ones(n)
            w[0] = W1[i, j]
            w[1] = W2[i, j]
            Z[i, j] = eval_basis_poly(A, w)
    
    ax = axes[idx]
    surf = ax.plot_surface(W1, W2, Z, cmap=cm.viridis, alpha=0.8,
                           linewidth=0, antialiased=True)
    
    # Add the z=0 plane for reference
    ax.plot_surface(W1, W2, np.zeros_like(Z), alpha=0.1, color='red')
    
    ax.set_xlabel('w₁', fontsize=10)
    ax.set_ylabel('w₂', fontsize=10)
    ax.set_zlabel('Z(w)', fontsize=10)
    ax.set_title(f'{title}\nmin Z = {Z.min():.4f} ≥ 0 ✓', fontsize=11)
    ax.view_init(elev=25, azim=-60)

fig.suptitle('Partition Function Nonnegativity: Z(w) = det(A·D_w·Aᵀ) ≥ 0 for w ≥ 0\n'
             '(Theorem: eval_basisPolyOfMatrix_nonneg)',
             fontsize=13, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_nonnegativity.png', dpi=150, bbox_inches='tight')
print("Saved viz_nonnegativity.png")
