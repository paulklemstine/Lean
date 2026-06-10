#!/usr/bin/env python3
"""
Algorithms for Cellular Automata Algebraic Geometry over GF(2)
===============================================================
Type-hinted implementations of core algorithms.
"""

from typing import List, Tuple, Dict, Optional
from itertools import product


def eca_local_rule(rule_num: int, left: int, center: int, right: int) -> int:
    """Apply ECA local rule by extracting bit from rule number.
    
    Args:
        rule_num: ECA rule number (0-255)
        left, center, right: Cell values in {0, 1}
    
    Returns:
        New center cell value in {0, 1}
    """
    idx = (left << 2) | (center << 1) | right
    return (rule_num >> idx) & 1


def eca_global_step(rule_num: int, state: List[int]) -> List[int]:
    """Global ECA step with periodic boundary conditions.
    
    Args:
        rule_num: ECA rule number (0-255)
        state: List of cell values, each in {0, 1}
    
    Returns:
        Updated state after one step
    """
    n = len(state)
    return [
        eca_local_rule(rule_num, state[(i-1) % n], state[i], state[(i+1) % n])
        for i in range(n)
    ]


def compute_algebraic_normal_form(rule_num: int) -> List[int]:
    """Compute the Algebraic Normal Form (ANF) coefficients.
    
    Every function GF(2)^3 -> GF(2) has a unique multilinear polynomial:
    g(a,b,c) = c0 + c1*a + c2*b + c3*c + c4*ab + c5*ac + c6*bc + c7*abc
    
    Uses Möbius inversion (inclusion-exclusion) over GF(2).
    
    Args:
        rule_num: ECA rule number (0-255)
    
    Returns:
        List of 8 coefficients [c0, c1, ..., c7] in {0, 1}
    """
    def g(a: int, b: int, c: int) -> int:
        return eca_local_rule(rule_num, a, b, c)
    
    c = [0] * 8
    c[0] = g(0,0,0)                                           # constant
    c[1] = g(0,0,0) ^ g(1,0,0)                                # a
    c[2] = g(0,0,0) ^ g(0,1,0)                                # b
    c[3] = g(0,0,0) ^ g(0,0,1)                                # c
    c[4] = g(0,0,0) ^ g(1,0,0) ^ g(0,1,0) ^ g(1,1,0)         # ab
    c[5] = g(0,0,0) ^ g(1,0,0) ^ g(0,0,1) ^ g(1,0,1)         # ac
    c[6] = g(0,0,0) ^ g(0,1,0) ^ g(0,0,1) ^ g(0,1,1)         # bc
    c[7] = (g(0,0,0) ^ g(1,0,0) ^ g(0,1,0) ^ g(0,0,1) ^
            g(1,1,0) ^ g(1,0,1) ^ g(0,1,1) ^ g(1,1,1))       # abc
    return c


def find_all_fixed_points(rule_num: int, n: int) -> List[Tuple[int, ...]]:
    """Find all fixed points of an ECA rule on n cells.
    
    Brute-force search over all 2^n states.
    
    Args:
        rule_num: ECA rule number
        n: Number of cells
    
    Returns:
        List of fixed-point states (as tuples of 0/1 values)
    """
    fixed_points = []
    for bits in product([0, 1], repeat=n):
        state = list(bits)
        if eca_global_step(rule_num, state) == state:
            fixed_points.append(bits)
    return fixed_points


def fixed_point_variety_dimension(rule_num: int, n: int) -> Optional[int]:
    """Compute the dimension of the fixed-point variety V(f_r - id).
    
    For linear rules, this is the dimension of the kernel of (T - I)
    where T is the transition matrix. For general rules, this is the
    log2 of the number of fixed points (which need not be a power of 2
    for nonlinear rules).
    
    Args:
        rule_num: ECA rule number
        n: Number of cells
    
    Returns:
        Dimension (log2 of fixed point count), or None if count is not a power of 2
    """
    count = len(find_all_fixed_points(rule_num, n))
    if count == 0:
        return -1  # empty variety
    if count & (count - 1) == 0:  # power of 2
        dim = 0
        while (1 << dim) < count:
            dim += 1
        return dim
    return None  # not a power of 2 (nonlinear rule)


def compute_conjugate_rule(rule_num: int) -> int:
    """Compute the conjugate (complement-dual) of an ECA rule.
    
    The conjugate ḡ satisfies: ḡ(a,b,c) = 1 + g(1+a, 1+b, 1+c) over GF(2).
    
    Theorem: s is a fixed point of g iff (1+s) is a fixed point of ḡ.
    This pairs the 256 rules into 128 conjugate pairs with isomorphic varieties.
    
    Args:
        rule_num: ECA rule number
    
    Returns:
        Conjugate rule number
    """
    conj = 0
    for a, b, c in product([0, 1], repeat=3):
        idx = (a << 2) | (b << 1) | c
        val = 1 ^ eca_local_rule(rule_num, 1^a, 1^b, 1^c)
        conj |= (val << idx)
    return conj


def is_linear_rule(rule_num: int) -> bool:
    """Check if an ECA rule is linear (additive) over GF(2).
    
    A rule is linear iff its local function g satisfies:
    g(0,0,0) = 0 and g(a⊕a', b⊕b', c⊕c') = g(a,b,c) ⊕ g(a',b',c')
    
    There are exactly 8 linear rules over GF(2).
    
    Args:
        rule_num: ECA rule number
    
    Returns:
        True if the rule is linear
    """
    if eca_local_rule(rule_num, 0, 0, 0) != 0:
        return False
    for a, ap, b, bp, c, cp in product([0, 1], repeat=6):
        lhs = eca_local_rule(rule_num, a^ap, b^bp, c^cp)
        rhs = eca_local_rule(rule_num, a, b, c) ^ eca_local_rule(rule_num, ap, bp, cp)
        if lhs != rhs:
            return False
    return True


def classify_all_rules(n: int = 6) -> Dict[str, List[int]]:
    """Classify all 256 ECA rules by fixed-point variety properties.
    
    Args:
        n: Number of cells for classification
    
    Returns:
        Dictionary with classification categories
    """
    classification: Dict[str, List[int]] = {
        'empty_variety': [],       # No fixed points
        'single_point': [],        # Exactly one fixed point
        'linear_subspace': [],     # Fixed points form a subspace (power-of-2 count)
        'nonlinear_variety': [],   # Fixed points exist but count not power of 2
        'full_space': [],          # All states are fixed points
    }
    
    for r in range(256):
        fps = find_all_fixed_points(r, n)
        count = len(fps)
        
        if count == 0:
            classification['empty_variety'].append(r)
        elif count == 1:
            classification['single_point'].append(r)
        elif count == 2**n:
            classification['full_space'].append(r)
        elif count & (count - 1) == 0:
            classification['linear_subspace'].append(r)
        else:
            classification['nonlinear_variety'].append(r)
    
    return classification


def build_transition_matrix_gf2(rule_num: int, n: int) -> List[List[int]]:
    """Build the transition matrix for a LINEAR ECA rule over GF(2).
    
    For a linear rule g(a,b,c) = αa + βb + γc, the global step is
    a linear map whose matrix T has entries T_{i,j} determined by the
    local rule coefficients and the periodic boundary.
    
    Args:
        rule_num: ECA rule number (should be linear)
        n: Number of cells
    
    Returns:
        n×n transition matrix over GF(2)
    """
    # Build by applying the step to standard basis vectors
    T = []
    for j in range(n):
        basis_j = [0] * n
        basis_j[j] = 1
        col = eca_global_step(rule_num, basis_j)
        T.append(col)
    
    # Transpose: T[j] is the image of e_j, we want matrix[i][j]
    matrix = [[T[j][i] for j in range(n)] for i in range(n)]
    return matrix


if __name__ == "__main__":
    # Quick self-test
    print("Linear rules:", [r for r in range(256) if is_linear_rule(r)])
    print("Rule 110 ANF:", compute_algebraic_normal_form(110))
    print("Conjugate of Rule 110:", compute_conjugate_rule(110))
    
    clf = classify_all_rules(6)
    for cat, rules in clf.items():
        print(f"{cat}: {len(rules)} rules")
