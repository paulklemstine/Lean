#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Lorentzian recognition complexity analysis.

Implements:
1. Multiindex enumeration and counting
2. Derivative tree construction
3. Certificate size computation
4. SAT-to-multiindex encoding
5. Hessian signature checking
"""

from math import comb, factorial, prod
from itertools import product as iterproduct
from typing import List, Tuple, Dict, Set, Optional, Generator
from dataclasses import dataclass, field
import numpy as np


# ============================================================
# Algorithm 1: Multiindex Enumeration
# ============================================================

def enumerate_multiindices(n: int, d: int) -> Generator[Tuple[int, ...], None, None]:
    """Generate all multiindices α : {0,...,n-1} → ℕ with ∑αᵢ = d.
    
    Uses recursive generation with pruning.
    
    Time: O(C(n+d-1, d) · n)
    Space: O(n) stack depth
    
    >>> list(enumerate_multiindices(2, 3))
    [(0, 3), (1, 2), (2, 1), (3, 0)]
    """
    if n == 0:
        if d == 0:
            yield ()
        return
    if n == 1:
        yield (d,)
        return
    for k in range(d + 1):
        for rest in enumerate_multiindices(n - 1, d - k):
            yield (k,) + rest


def multiindex_count(n: int, d: int) -> int:
    """Exact count using stars-and-bars formula.
    
    C(n + d - 1, d) = (n + d - 1)! / (d! · (n-1)!)
    
    Time: O(min(n, d))
    Space: O(1)
    
    >>> multiindex_count(2, 5)
    6
    >>> multiindex_count(3, 3)
    10
    """
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


# ============================================================
# Algorithm 2: Derivative Tree Construction
# ============================================================

@dataclass
class DerivativeNode:
    """A node in the derivative tree of a polynomial."""
    multiindex: Tuple[int, ...]
    depth: int
    children: List['DerivativeNode'] = field(default_factory=list)
    is_leaf: bool = False
    hessian: Optional[np.ndarray] = None
    
    def leaf_count(self) -> int:
        """Count leaves in this subtree."""
        if self.is_leaf:
            return 1
        return sum(child.leaf_count() for child in self.children)


def build_derivative_tree(n: int, d: int, max_depth: Optional[int] = None) -> DerivativeNode:
    """Build the full derivative tree for recognition of degree-d polys in n vars.
    
    The tree has depth d-2, with leaves at the quadratic level.
    Each internal node at depth k has n children (one per variable).
    
    Time: O(n^(d-2) · n)
    Space: O(n^(d-2) · n)
    
    Args:
        n: number of variables
        d: degree of polynomial
        max_depth: optional depth limit (default: d-2)
    
    Returns:
        Root node of the derivative tree
    """
    if max_depth is None:
        max_depth = max(0, d - 2)
    
    root = DerivativeNode(
        multiindex=tuple([0] * n),
        depth=0,
        is_leaf=(max_depth == 0)
    )
    
    def build_subtree(node: DerivativeNode):
        if node.depth >= max_depth:
            node.is_leaf = True
            return
        for var in range(n):
            child_mi = list(node.multiindex)
            child_mi[var] += 1
            child = DerivativeNode(
                multiindex=tuple(child_mi),
                depth=node.depth + 1
            )
            build_subtree(child)
            node.children.append(child)
    
    build_subtree(root)
    return root


def unique_leaves(tree: DerivativeNode) -> Set[Tuple[int, ...]]:
    """Extract unique leaf multiindices from a derivative tree.
    
    Multiple branches may reach the same multiindex (due to commutativity
    of partial derivatives), so the number of unique leaves equals
    multiIndexCount(n, d-2), not n^(d-2).
    """
    if tree.is_leaf:
        return {tree.multiindex}
    result = set()
    for child in tree.children:
        result.update(unique_leaves(child))
    return result


# ============================================================
# Algorithm 3: Certificate Size Computation
# ============================================================

def certificate_size(n: int, d: int) -> Dict[str, int]:
    """Compute certificate complexity metrics.
    
    Returns:
        Dictionary with exact count, upper bound, lower bounds.
    """
    if d < 2:
        exact = 1
    else:
        exact = multiindex_count(n, d - 2)
    
    upper = n ** (d - 2) if d >= 2 else 1
    lower_linear = max(0, d - 1) if n >= 2 else 0
    lower_exp = 2 ** ((d - 2) // 2) if d >= 4 and n > (d - 2) // 2 else 0
    
    return {
        'exact': exact,
        'upper_bound': upper,
        'lower_linear': lower_linear,
        'lower_exponential': lower_exp,
        'n': n,
        'd': d,
    }


def find_superpolynomial_witness(c: int, N: int = 2) -> Tuple[int, int, int]:
    """Find n, d such that numberOfQuadraticLeaves(n, d) > n^c.
    
    Guaranteed to terminate by Theorem D.
    
    Args:
        c: exponent of the polynomial bound
        N: minimum n value
    
    Returns:
        (n, d, leaf_count) with leaf_count > n^c
    """
    for n in range(max(N, 2), 1000):
        d = 2 * n
        leaves = multiindex_count(n, d - 2) if d >= 2 else 1
        if leaves > n ** c:
            return (n, d, leaves)
    raise RuntimeError("Should not reach here by theorem guarantee")


# ============================================================
# Algorithm 4: SAT-to-Multiindex Encoding
# ============================================================

def assignment_to_multiindex(tau: Tuple[bool, ...]) -> Tuple[int, ...]:
    """Encode Boolean assignment as multiindex in 2n variables.
    
    τ(i) = True  → α(2i) = 1, α(2i+1) = 0
    τ(i) = False → α(2i) = 0, α(2i+1) = 1
    
    Properties (proved in Lean):
    - Sum = n (assignmentToMultiindex_sum)
    - Injective (assignmentToMultiindex_injective)
    
    Time: O(n)
    Space: O(n)
    """
    result = []
    for b in tau:
        result.extend([1, 0] if b else [0, 1])
    return tuple(result)


def multiindex_to_assignment(alpha: Tuple[int, ...]) -> Optional[Tuple[bool, ...]]:
    """Decode a multiindex back to a Boolean assignment (partial inverse).
    
    Only works for multiindices in the image of assignment_to_multiindex.
    Returns None if alpha is not a valid encoding.
    """
    n = len(alpha) // 2
    if len(alpha) != 2 * n:
        return None
    result = []
    for i in range(n):
        if alpha[2*i] == 1 and alpha[2*i+1] == 0:
            result.append(True)
        elif alpha[2*i] == 0 and alpha[2*i+1] == 1:
            result.append(False)
        else:
            return None
    return tuple(result)


def binary_to_multiindex(f: Tuple[bool, ...], n: int, d: int) -> Tuple[int, ...]:
    """Injection from binary strings to multiindices.
    
    Maps f : Fin m → Bool to α : Fin n → ℕ with ∑α = d.
    
    Properties (proved in Lean):
    - Sum = d (binaryToMultiindex_sum)
    - Injective (binaryToMultiindex_injective)
    
    Requires: m < n and m ≤ d where m = len(f).
    """
    m = len(f)
    assert m < n and m <= d, f"Requires m={m} < n={n} and m ≤ d={d}"
    bits = [1 if b else 0 for b in f]
    slack = d - sum(bits)
    return tuple(bits + [slack] + [0] * (n - m - 1))


# ============================================================
# Algorithm 5: Hessian Signature Checking
# ============================================================

def polynomial_hessian(coeffs: Dict[Tuple[int, ...], float], n: int) -> np.ndarray:
    """Compute the Hessian matrix of a multivariate polynomial.
    
    H[i][j] = value of ∂²p/∂xᵢ∂xⱼ evaluated at x = 0.
    For homogeneous degree-2 polynomials, this captures all information.
    
    Time: O(|coeffs| · n²)
    """
    H = np.zeros((n, n))
    for mono, coeff in coeffs.items():
        if len(mono) != n or sum(mono) != 2:
            continue
        for i in range(n):
            for j in range(n):
                alpha = list(mono)
                if alpha[i] > 0:
                    fi = alpha[i]
                    alpha[i] -= 1
                    if alpha[j] > 0:
                        fj = alpha[j]
                        H[i][j] += coeff * fi * fj
                    alpha[i] += 1
    return H


def check_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if matrix has at most one positive eigenvalue.
    
    Time: O(n³) for eigenvalue computation
    """
    eigenvalues = np.linalg.eigvalsh(H)
    positive_count = sum(1 for ev in eigenvalues if ev > tol)
    return positive_count <= 1


def check_recursive_lorentzian(coeffs: Dict[Tuple[int, ...], float], 
                                n: int, d: int) -> Tuple[bool, List[str]]:
    """Check if a polynomial is recursively Lorentzian.
    
    Returns (is_lorentzian, list_of_messages).
    
    Time: O(multiIndexCount(n, d-2) · n³)
    """
    messages = []
    
    # Check nonnegativity
    for mono, coeff in coeffs.items():
        if coeff < -1e-15:
            messages.append(f"Negative coefficient at {mono}: {coeff}")
            return False, messages
    
    if d < 2:
        messages.append("Degree < 2: trivially Lorentzian")
        return True, messages
    
    # Check all quadratic leaves
    leaf_count = 0
    for alpha in enumerate_multiindices(n, d - 2):
        leaf_count += 1
        # Compute iterated derivative
        deriv_coeffs = dict(coeffs)
        for var in range(n):
            for _ in range(alpha[var]):
                deriv_coeffs = _differentiate(deriv_coeffs, n, var)
        
        H = polynomial_hessian(deriv_coeffs, n)
        if not check_lorentzian_signature(H):
            messages.append(f"Leaf α={alpha}: Hessian has >1 positive eigenvalue")
            return False, messages
    
    messages.append(f"All {leaf_count} leaves passed Lorentzian check")
    return True, messages


def _differentiate(coeffs: Dict[Tuple[int, ...], float], 
                   n: int, var: int) -> Dict[Tuple[int, ...], float]:
    """Differentiate polynomial with respect to variable var."""
    result = {}
    for mono, coeff in coeffs.items():
        if mono[var] > 0:
            new_mono = list(mono)
            new_coeff = coeff * mono[var]
            new_mono[var] -= 1
            new_mono = tuple(new_mono)
            result[new_mono] = result.get(new_mono, 0) + new_coeff
    return result


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Example 1: Certificate size analysis
    print("Certificate Size Analysis")
    print("=" * 50)
    for n in [3, 5, 10]:
        for d in [4, 6, 8]:
            cs = certificate_size(n, d)
            print(f"n={n}, d={d}: exact={cs['exact']}, "
                  f"upper={cs['upper_bound']}, "
                  f"lower_exp={cs['lower_exponential']}")
    
    # Example 2: Boolean encoding
    print("\nBoolean Encoding Verification")
    print("=" * 50)
    n = 4
    all_assignments = list(iterproduct([False, True], repeat=n))
    all_multiindices = [assignment_to_multiindex(tau) for tau in all_assignments]
    print(f"n={n}: {len(all_assignments)} assignments → "
          f"{len(set(all_multiindices))} distinct multiindices")
    print(f"All weight {n}: {all(sum(mi) == n for mi in all_multiindices)}")
    print(f"All decodable: {all(multiindex_to_assignment(mi) is not None for mi in all_multiindices)}")
    
    # Example 3: Superpolynomial witnesses
    print("\nSuperpolynomial Witnesses")
    print("=" * 50)
    for c in [2, 3, 5]:
        n, d, leaves = find_superpolynomial_witness(c)
        print(f"c={c}: n={n}, d={d}, leaves={leaves:,} > n^c={n**c:,}")
    
    # Example 4: Simple Lorentzian check
    print("\nLorentzian Check: x² + 2xy + y²")
    print("=" * 50)
    coeffs = {(2, 0): 1.0, (1, 1): 2.0, (0, 2): 1.0}
    is_lor, msgs = check_recursive_lorentzian(coeffs, 2, 2)
    print(f"Is Lorentzian: {is_lor}")
    for msg in msgs:
        print(f"  {msg}")
