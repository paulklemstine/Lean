"""
Algorithms for Matrix Group Growth Analysis

Implements the core computational methods for studying product-set growth
in GL(2, F_q), including generating pair enumeration, transversality detection,
and growth exponent computation.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Set
from itertools import product as iterproduct
import math


def make_field(q: int) -> dict:
    """Create arithmetic tables for GF(q) where q is prime."""
    assert all(q % i != 0 for i in range(2, int(q**0.5) + 1)) and q > 1, f"{q} is not prime"
    return {
        'q': q,
        'add': lambda a, b: (a + b) % q,
        'mul': lambda a, b: (a * b) % q,
        'neg': lambda a: (-a) % q,
        'inv': lambda a: pow(a, q - 2, q) if a != 0 else None,
        'sub': lambda a, b: (a - b) % q,
    }


def mat_mul(A: np.ndarray, B: np.ndarray, q: int) -> np.ndarray:
    """Multiply two 2x2 matrices over GF(q)."""
    return (A @ B) % q


def mat_det(M: np.ndarray, q: int) -> int:
    """Determinant of a 2x2 matrix over GF(q)."""
    return int((M[0, 0] * M[1, 1] - M[0, 1] * M[1, 0]) % q)


def mat_inv(M: np.ndarray, q: int) -> Optional[np.ndarray]:
    """Inverse of a 2x2 matrix over GF(q), or None if singular."""
    d = mat_det(M, q)
    if d == 0:
        return None
    d_inv = pow(int(d), q - 2, q)
    inv = np.array([
        [M[1, 1] * d_inv % q, (-M[0, 1]) * d_inv % q],
        [(-M[1, 0]) * d_inv % q, M[0, 0] * d_inv % q]
    ], dtype=int) % q
    return inv


def mat_to_tuple(M: np.ndarray) -> tuple:
    """Convert matrix to hashable tuple."""
    return tuple(M.flatten())


def tuple_to_mat(t: tuple) -> np.ndarray:
    """Convert tuple back to matrix."""
    return np.array(t, dtype=int).reshape(2, 2)


def enumerate_gl2(q: int) -> List[np.ndarray]:
    """Enumerate all elements of GL(2, GF(q))."""
    elements = []
    for a, b, c, d in iterproduct(range(q), repeat=4):
        M = np.array([[a, b], [c, d]], dtype=int)
        if mat_det(M, q) != 0:
            elements.append(M)
    return elements


def gl2_order(q: int) -> int:
    """Order of GL(2, GF(q)) for prime q."""
    return (q**2 - 1) * (q**2 - q)


def symmetric_closure(g: np.ndarray, h: np.ndarray, q: int) -> Set[tuple]:
    """Compute A = {1, g, g^{-1}, h, h^{-1}} as a set of tuples."""
    I = np.eye(2, dtype=int)
    g_inv = mat_inv(g, q)
    h_inv = mat_inv(h, q)
    elements = {mat_to_tuple(I)}
    for M in [g, g_inv, h, h_inv]:
        if M is not None:
            elements.add(mat_to_tuple(M))
    return elements


def product_set(A: Set[tuple], B: Set[tuple], q: int) -> Set[tuple]:
    """Compute product set A * B in GL(2, GF(q))."""
    result = set()
    for a_tup in A:
        a = tuple_to_mat(a_tup)
        for b_tup in B:
            b = tuple_to_mat(b_tup)
            result.add(mat_to_tuple(mat_mul(a, b, q)))
    return result


def compute_powers(A_set: Set[tuple], q: int, max_power: int = 10) -> List[int]:
    """Compute |A|, |A^2|, |A^3|, ... up to saturation or max_power."""
    sizes = [len(A_set)]
    current = A_set
    total = gl2_order(q)
    for _ in range(1, max_power):
        current = product_set(current, A_set, q)
        sizes.append(len(current))
        if len(current) == total:
            break
    return sizes


def has_distinct_eigenvalues(M: np.ndarray, q: int) -> bool:
    """Check if a 2x2 matrix over GF(q) has two distinct eigenvalues in GF(q).
    
    Eigenvalues satisfy λ² - tr(M)λ + det(M) = 0 over GF(q).
    The matrix has distinct eigenvalues iff the discriminant tr²-4det ≠ 0
    and is a quadratic residue mod q.
    """
    tr = int((M[0, 0] + M[1, 1]) % q)
    det = mat_det(M, q)
    disc = (tr * tr - 4 * det) % q
    if disc == 0:
        return False
    # Check if disc is a quadratic residue
    if q == 2:
        return disc != 0
    return pow(int(disc), (q - 1) // 2, q) == 1


def find_eigenvalues(M: np.ndarray, q: int) -> Optional[Tuple[int, int]]:
    """Find eigenvalues of a 2x2 matrix over GF(q), if they exist and are distinct."""
    tr = int((M[0, 0] + M[1, 1]) % q)
    det = mat_det(M, q)
    disc = (tr * tr - 4 * det) % q
    if disc == 0:
        return None
    # Find square root of disc
    sqrt_disc = None
    for x in range(q):
        if (x * x) % q == disc:
            sqrt_disc = x
            break
    if sqrt_disc is None:
        return None
    inv2 = pow(2, q - 2, q)
    lam1 = (tr + sqrt_disc) * inv2 % q
    lam2 = (tr - sqrt_disc) * inv2 % q
    if lam1 == lam2:
        return None
    return (int(lam1), int(lam2))


def find_eigenvectors(M: np.ndarray, q: int) -> Optional[Tuple[np.ndarray, np.ndarray]]:
    """Find eigenvectors for a matrix with distinct eigenvalues over GF(q)."""
    evals = find_eigenvalues(M, q)
    if evals is None:
        return None
    lam1, lam2 = evals
    vecs = []
    for lam in [lam1, lam2]:
        # (M - λI)v = 0
        A_mat = (M - lam * np.eye(2, dtype=int)) % q
        # Find nonzero kernel vector
        if A_mat[0, 0] == 0 and A_mat[0, 1] == 0:
            v = np.array([1, 0], dtype=int)
        elif A_mat[0, 0] != 0:
            # v = (-a01, a00)
            v = np.array([(-A_mat[0, 1]) % q, A_mat[0, 0] % q], dtype=int)
        else:
            v = np.array([1, 0], dtype=int)
        vecs.append(v)
    return tuple(vecs)


def is_transverse_pair(g: np.ndarray, h: np.ndarray, q: int) -> bool:
    """Check if (g, h) is a transverse pair: g has distinct eigenlines and
    h does not preserve them.
    
    A pair is transverse if g has distinct eigenvalues in GF(q) and h does
    not map each eigenline to an eigenline.
    """
    evecs = find_eigenvectors(g, q)
    if evecs is None:
        return False
    v1, v2 = evecs
    
    # Check if h preserves the eigenlines {span(v1), span(v2)}
    hv1 = mat_mul(h, v1.reshape(2, 1), q).flatten() % q
    hv2 = mat_mul(h, v2.reshape(2, 1), q).flatten() % q
    
    def is_scalar_multiple(u, v, q):
        """Check if u = c*v for some c in GF(q)."""
        if all(x == 0 for x in u):
            return True
        if all(x == 0 for x in v):
            return all(x == 0 for x in u)
        # Find which component of v is nonzero
        for i in range(len(v)):
            if v[i] != 0:
                c = u[i] * pow(int(v[i]), q - 2, q) % q
                return all((u[j] - c * v[j]) % q == 0 for j in range(len(v)))
        return False
    
    # h preserves eigenlines if hv1 ∈ span(v1) or span(v2), AND hv2 in the other
    hv1_in_v1 = is_scalar_multiple(hv1, v1, q)
    hv1_in_v2 = is_scalar_multiple(hv1, v2, q)
    hv2_in_v1 = is_scalar_multiple(hv2, v1, q)
    hv2_in_v2 = is_scalar_multiple(hv2, v2, q)
    
    preserves = (hv1_in_v1 and hv2_in_v2) or (hv1_in_v2 and hv2_in_v1)
    return not preserves


def generates_gl2(g: np.ndarray, h: np.ndarray, q: int) -> bool:
    """Check if {g, h} generates GL(2, GF(q)) by computing the subgroup closure."""
    total = gl2_order(q)
    I = np.eye(2, dtype=int)
    
    # BFS to generate subgroup
    seen = {mat_to_tuple(I)}
    queue = [I]
    gens = [g, h]
    g_inv = mat_inv(g, q)
    h_inv = mat_inv(h, q)
    if g_inv is not None:
        gens.append(g_inv)
    if h_inv is not None:
        gens.append(h_inv)
    
    idx = 0
    while idx < len(queue):
        if len(seen) == total:
            return True
        current = queue[idx]
        idx += 1
        for gen in gens:
            prod = mat_mul(current, gen, q)
            t = mat_to_tuple(prod)
            if t not in seen:
                seen.add(t)
                queue.append(prod)
    return len(seen) == total


def growth_exponent(sizes: List[int]) -> Optional[float]:
    """Compute log|A^3| / log|A| if both are > 1."""
    if len(sizes) < 3:
        return None
    a1 = sizes[0]
    a3 = sizes[2] if len(sizes) > 2 else sizes[-1]
    if a1 <= 1 or a3 <= 1:
        return None
    return math.log(a3) / math.log(a1)


def analyze_pair(g: np.ndarray, h: np.ndarray, q: int) -> Dict:
    """Full analysis of a generating pair (g, h) in GL(2, GF(q))."""
    total = gl2_order(q)
    A = symmetric_closure(g, h, q)
    sizes = compute_powers(A, q, max_power=6)
    
    saturated_at_3 = (len(sizes) > 2 and sizes[2] == total) if len(sizes) > 2 else False
    transverse = is_transverse_pair(g, h, q)
    g_has_distinct = has_distinct_eigenvalues(g, q)
    h_has_distinct = has_distinct_eigenvalues(h, q)
    exp = growth_exponent(sizes) if not saturated_at_3 and len(sizes) > 2 else None
    
    return {
        'g': g,
        'h': h,
        'q': q,
        'A_size': sizes[0],
        'sizes': sizes,
        'saturated_at_3': saturated_at_3,
        'transverse': transverse,
        'g_distinct_eigenvalues': g_has_distinct,
        'h_distinct_eigenvalues': h_has_distinct,
        'growth_exponent': exp,
        'gl2_order': total,
    }


def survey_pairs(q: int, max_pairs: int = 200) -> List[Dict]:
    """Survey generating pairs in GL(2, GF(q)) and compute growth statistics."""
    import random
    
    gl2 = enumerate_gl2(q)
    results = []
    attempted = 0
    
    # Sample random pairs
    random.seed(42)
    pairs_to_try = []
    for _ in range(max_pairs * 5):
        g = random.choice(gl2)
        h = random.choice(gl2)
        pairs_to_try.append((g, h))
    
    for g, h in pairs_to_try:
        if len(results) >= max_pairs:
            break
        if not generates_gl2(g, h, q):
            continue
        result = analyze_pair(g, h, q)
        results.append(result)
    
    return results


def compute_min_growth_exponent(results: List[Dict]) -> Optional[float]:
    """Compute the minimum growth exponent among non-saturated pairs."""
    exponents = [r['growth_exponent'] for r in results 
                 if r['growth_exponent'] is not None and not r['saturated_at_3']]
    return min(exponents) if exponents else None


if __name__ == '__main__':
    print("=" * 60)
    print("Matrix Group Growth Algorithm Tests")
    print("=" * 60)
    
    for q in [3, 5, 7]:
        print(f"\n--- GL(2, GF({q})) ---")
        print(f"Group order: {gl2_order(q)}")
        
        results = survey_pairs(q, max_pairs=50)
        n_gen = len(results)
        n_sat = sum(1 for r in results if r['saturated_at_3'])
        n_transverse = sum(1 for r in results if r['transverse'])
        min_exp = compute_min_growth_exponent(results)
        
        print(f"Generating pairs found: {n_gen}")
        print(f"Saturated at A^3: {n_sat}")
        print(f"Transverse pairs: {n_transverse}")
        if min_exp is not None:
            print(f"Min growth exponent (log|A^3|/log|A|): {min_exp:.4f}")
        
        # Show a few examples
        for r in results[:3]:
            print(f"  |A|={r['A_size']}, sizes={r['sizes'][:4]}, "
                  f"transverse={r['transverse']}, exp={r['growth_exponent']}")
