#!/usr/bin/env python3
"""
Algorithms for Lorentzian Recognition Complexity Analysis

Implements the key algorithms from the research paper:
1. Multiindex enumeration and counting
2. Derivative tree construction  
3. Hessian signature testing
4. Certificate complexity estimation
5. SAT-to-branch encoding
"""

import math
import itertools
from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Multiindex Enumeration
# ============================================================

def enumerate_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Enumerate all weak compositions of d into n parts.
    
    Complexity: O(C(n+d-1, d)) time and space.
    
    Args:
        n: Number of variables (parts)
        d: Total weight (sum)
    
    Returns:
        List of tuples, each a multiindex alpha with sum(alpha) = d.
    
    Examples:
        >>> enumerate_multiindices(2, 2)
        [(0, 2), (1, 1), (2, 0)]
        >>> len(enumerate_multiindices(3, 3))
        10
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for first in range(d + 1):
        for rest in enumerate_multiindices(n - 1, d - first):
            result.append((first,) + rest)
    return result


def count_multiindices(n: int, d: int) -> int:
    """Count weak compositions of d into n parts.
    
    Formula: C(n+d-1, d)
    
    Complexity: O(min(n, d)) time, O(1) space.
    
    Args:
        n: Number of variables
        d: Total weight
    
    Returns:
        Number of multiindices = C(n+d-1, d)
    """
    return math.comb(n + d - 1, d)


# ============================================================
# Algorithm 2: Binary Multiindex Enumeration
# ============================================================

def enumerate_binary_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Enumerate {0,1}-valued multiindices of weight d in n variables.
    
    These correspond to d-element subsets of {0,...,n-1} and hence
    to Boolean assignments with exactly d true variables.
    
    Complexity: O(C(n, d) * n) time and space.
    
    Args:
        n: Number of variables
        d: Weight (number of 1s)
    
    Returns:
        List of binary tuples with exactly d ones.
    """
    if d > n or d < 0:
        return []
    result = []
    for subset in itertools.combinations(range(n), d):
        alpha = tuple(1 if i in subset else 0 for i in range(n))
        result.append(alpha)
    return result


# ============================================================
# Algorithm 3: Derivative Tree Construction
# ============================================================

@dataclass
class DerivativeNode:
    """Node in the derivative tree of a polynomial.
    
    Each node represents a partial derivative of the original polynomial.
    The derivative_sequence records which variables were differentiated.
    """
    derivative_sequence: Tuple[int, ...]  # sequence of variable indices
    remaining_degree: int
    children: List['DerivativeNode']
    is_quadratic_leaf: bool
    
    def size(self) -> int:
        """Total number of nodes in this subtree."""
        return 1 + sum(c.size() for c in self.children)
    
    def leaf_count(self) -> int:
        """Number of quadratic leaves in this subtree."""
        if self.is_quadratic_leaf:
            return 1
        return sum(c.leaf_count() for c in self.children)


def build_derivative_tree(n: int, d: int, max_depth: Optional[int] = None) -> DerivativeNode:
    """Build the full derivative tree for a degree-d polynomial in n variables.
    
    The tree has depth d-2 (differentiating until degree 2 remains).
    Each internal node has n children (one per variable direction).
    Quadratic leaves are where Hessian signature is checked.
    
    Complexity: O(n^(d-2)) nodes, which is the point — exponential in d.
    
    WARNING: This grows very fast! Use max_depth to limit expansion.
    
    Args:
        n: Number of variables
        d: Degree of polynomial
        max_depth: Maximum tree depth to expand (None = full)
    
    Returns:
        Root of the derivative tree.
    """
    def build(seq: Tuple[int, ...], remaining: int, depth: int) -> DerivativeNode:
        if remaining <= 2:
            return DerivativeNode(
                derivative_sequence=seq,
                remaining_degree=remaining,
                children=[],
                is_quadratic_leaf=True
            )
        if max_depth is not None and depth >= max_depth:
            return DerivativeNode(
                derivative_sequence=seq,
                remaining_degree=remaining,
                children=[],
                is_quadratic_leaf=False
            )
        children = []
        for var in range(n):
            child = build(seq + (var,), remaining - 1, depth + 1)
            children.append(child)
        return DerivativeNode(
            derivative_sequence=seq,
            remaining_degree=remaining,
            children=children,
            is_quadratic_leaf=False
        )
    
    return build((), d, 0)


def count_distinct_leaves(n: int, d: int) -> int:
    """Count distinct quadratic leaves (accounting for derivative commutativity).
    
    Due to commutativity of mixed partials, many derivative sequences
    lead to the same result. The number of distinct leaves equals
    the number of multiindices of weight d-2 in n variables.
    
    Complexity: O(min(n, d)) time.
    
    Args:
        n: Number of variables
        d: Degree of polynomial
    
    Returns:
        Number of distinct quadratic leaves = C(n+d-3, d-2)
    """
    if d < 2:
        return 1
    return count_multiindices(n, d - 2)


# ============================================================
# Algorithm 4: Hessian Signature Testing
# ============================================================

def compute_hessian_diagonal(diagonal_entries: List[float]) -> List[List[float]]:
    """Compute Hessian matrix for a diagonal quadratic form.
    
    For Q(x) = sum_i d_i * x_i^2, the Hessian is 2 * diag(d).
    
    Args:
        diagonal_entries: The coefficients d_i
    
    Returns:
        Hessian matrix (2D list)
    """
    n = len(diagonal_entries)
    H = [[0.0] * n for _ in range(n)]
    for i in range(n):
        H[i][i] = 2.0 * diagonal_entries[i]
    return H


def check_lorentzian_signature_diagonal(diagonal: List[float]) -> Dict:
    """Check if a diagonal matrix has Lorentzian signature.
    
    A diagonal matrix has Lorentzian signature iff at most one
    diagonal entry is positive. This is the exact characterization
    proved in our formal development.
    
    Complexity: O(n) time.
    
    Args:
        diagonal: Diagonal entries of the matrix
    
    Returns:
        Dict with 'is_lorentzian', 'positive_count', 'witness_direction'
    """
    n = len(diagonal)
    positive_indices = [i for i, d in enumerate(diagonal) if d > 0]
    positive_count = len(positive_indices)
    
    result = {
        'is_lorentzian': positive_count <= 1,
        'positive_count': positive_count,
        'positive_indices': positive_indices,
    }
    
    if positive_count <= 1:
        # Witness: standard basis vector at the positive entry (or any if none)
        if positive_indices:
            witness = [0.0] * n
            witness[positive_indices[0]] = 1.0
        else:
            witness = [1.0] + [0.0] * (n - 1) if n > 0 else []
        result['witness_direction'] = witness
    else:
        # Obstruction: two positive entries prevent Lorentzian signature
        i, j = positive_indices[0], positive_indices[1]
        result['obstruction'] = (i, j)
    
    return result


# ============================================================
# Algorithm 5: Certificate Complexity Bounds
# ============================================================

def certificate_complexity_bounds(n: int, d: int) -> Dict:
    """Compute upper and lower bounds on certificate complexity.
    
    Upper bound: n^(d-2) from catalog's quadratic_leaf_count_le
    Lower bound: C(n, d-2) from our multiindex_count_ge_choose
    Exponential lower: 2^k when n = 2k and d = k + 2
    
    Args:
        n: Number of variables
        d: Degree
    
    Returns:
        Dict with bounds and analysis
    """
    if d < 2:
        return {
            'leaves': 1,
            'upper_bound': 1,
            'lower_bound': 1,
            'ratio': 1.0,
            'is_exponential_regime': False,
        }
    
    k = d - 2
    leaves = count_multiindices(n, k)
    upper = n ** k if n > 0 else 0
    lower = math.comb(n, k) if k <= n else 0
    
    # Check if we're in the exponential regime
    is_exp = (k >= 2 and n >= 2 * k)
    exp_lower = 2 ** (n // 2) if is_exp else None
    
    return {
        'n': n,
        'd': d,
        'derivative_depth': k,
        'exact_leaves': leaves,
        'upper_bound_n_pow_k': upper,
        'lower_bound_choose': lower,
        'exponential_lower': exp_lower,
        'upper_lower_ratio': upper / lower if lower > 0 else float('inf'),
        'is_exponential_regime': is_exp,
    }


# ============================================================
# Algorithm 6: SAT-to-Branch Encoding
# ============================================================

@dataclass
class CNFFormula:
    """A CNF formula over n Boolean variables."""
    num_vars: int
    clauses: List[List[Tuple[int, bool]]]  # List of clauses, each a list of (var, polarity)
    
    def evaluate(self, assignment: Tuple[bool, ...]) -> bool:
        """Check if assignment satisfies the formula."""
        for clause in self.clauses:
            if not any(assignment[v] == p for v, p in clause):
                return False
        return True
    
    def brute_force_solve(self) -> Optional[Tuple[bool, ...]]:
        """Find a satisfying assignment by brute force."""
        for bits in itertools.product([False, True], repeat=self.num_vars):
            if self.evaluate(bits):
                return bits
        return None
    
    def count_satisfying(self) -> int:
        """Count satisfying assignments."""
        count = 0
        for bits in itertools.product([False, True], repeat=self.num_vars):
            if self.evaluate(bits):
                count += 1
        return count
    
    def branch_obstruction_map(self) -> Dict[Tuple[int, ...], bool]:
        """Map each binary multiindex to whether it's 'obstructed'.
        
        An assignment is obstructed if it does NOT satisfy the formula.
        This is the core of the SAT-branch correspondence:
        obstructed branches ↔ unsatisfied assignments.
        """
        result = {}
        for bits in itertools.product([False, True], repeat=self.num_vars):
            alpha = tuple(1 if b else 0 for b in bits)
            result[alpha] = not self.evaluate(bits)
        return result


def sat_to_branch_analysis(formula: CNFFormula) -> Dict:
    """Analyze the SAT-to-branch correspondence for a CNF formula.
    
    Returns detailed analysis of how the formula maps to
    derivative tree branch structure.
    """
    total_assignments = 2 ** formula.num_vars
    satisfying = formula.count_satisfying()
    obstruction_map = formula.branch_obstruction_map()
    obstructed = sum(1 for v in obstruction_map.values() if v)
    
    return {
        'num_vars': formula.num_vars,
        'num_clauses': len(formula.clauses),
        'total_assignments': total_assignments,
        'satisfying_count': satisfying,
        'obstructed_count': obstructed,
        'is_satisfiable': satisfying > 0,
        'all_obstructed': obstructed == total_assignments,
        'obstruction_density': obstructed / total_assignments,
    }


# ============================================================
# Usage Examples
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # 1. Multiindex counting
    print("1. Multiindex counting:")
    for n, d in [(3, 2), (4, 3), (5, 2)]:
        exact = count_multiindices(n, d)
        binary = math.comb(n, d) if d <= n else 0
        print(f"   n={n}, d={d}: total={exact}, binary={binary}, "
              f"ratio={exact/binary:.2f}" if binary > 0 else f"   n={n}, d={d}: total={exact}")
    
    # 2. Certificate complexity
    print("\n2. Certificate complexity bounds:")
    for n, d in [(6, 5), (8, 6), (10, 7), (20, 12)]:
        bounds = certificate_complexity_bounds(n, d)
        print(f"   n={n}, d={d}: leaves={bounds['exact_leaves']}, "
              f"upper={bounds['upper_bound_n_pow_k']}, lower={bounds['lower_bound_choose']}")
    
    # 3. Diagonal Lorentzian testing
    print("\n3. Diagonal Lorentzian signature:")
    for diag in [[3, -1, -2], [2, 3, -1], [-1, -2, -3]]:
        result = check_lorentzian_signature_diagonal(diag)
        print(f"   diag={diag}: Lorentzian={result['is_lorentzian']}")
    
    # 4. SAT-branch analysis
    print("\n4. SAT-branch correspondence:")
    phi = CNFFormula(3, [
        [(0, True), (1, True)],
        [(1, False), (2, True)],
    ])
    analysis = sat_to_branch_analysis(phi)
    print(f"   Formula: {len(phi.clauses)} clauses, {phi.num_vars} vars")
    print(f"   Satisfying: {analysis['satisfying_count']}/{analysis['total_assignments']}")
    print(f"   Obstructed branches: {analysis['obstructed_count']}")
    print(f"   Obstruction density: {analysis['obstruction_density']:.2%}")
