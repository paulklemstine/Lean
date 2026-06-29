#!/usr/bin/env python3
"""
Algorithms for Support Minor Theory

Implements the core algorithms for deletion-contraction duality
on polynomial supports with the exchange property (M-convexity).

Algorithms:
1. Exchange property verification (O(|S|^2 · n^2))
2. Support deletion and contraction
3. Minor chain computation
4. Support-Tutte invariant via deletion-contraction
5. Matroid basis support construction
"""

from typing import List, Tuple, Set, Dict, Optional, FrozenSet
from itertools import combinations
from collections import defaultdict
from functools import lru_cache


# Type aliases
Vector = Tuple[int, ...]
Support = List[Vector]


# ============================================================
# Algorithm 1: Exchange Property Verification
# ============================================================

def verify_exchange(S: Support, n: int) -> Tuple[bool, Optional[Tuple[Vector, Vector, int]]]:
    """
    Verify the symmetric exchange property for a support set S ⊆ ℕ^n.
    
    Algorithm:
        For each pair (x, y) in S × S:
            For each coordinate a with x[a] > y[a]:
                Search for b with y[b] > x[b] such that
                x - e_a + e_b ∈ S and y + e_a - e_b ∈ S.
    
    Time complexity: O(|S|^2 · n^2)
    Space complexity: O(|S|) for the hash set
    
    Args:
        S: List of n-dimensional integer vectors
        n: Dimension
    
    Returns:
        (True, None) if exchange holds
        (False, (x, y, a)) counterexample if it fails
    """
    S_set: Set[Vector] = set(S)
    
    for x in S:
        for y in S:
            for a in range(n):
                if x[a] > y[a]:
                    witness_found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            x_new = list(x)
                            x_new[a] -= 1
                            x_new[b] += 1
                            y_new = list(y)
                            y_new[a] += 1
                            y_new[b] -= 1
                            if tuple(x_new) in S_set and tuple(y_new) in S_set:
                                witness_found = True
                                break
                    if not witness_found:
                        return False, (x, y, a)
    return True, None


# ============================================================
# Algorithm 2: Support Deletion
# ============================================================

def deletion(S: Support, i: int) -> Support:
    """
    Support deletion at coordinate i.
    
    D_i(S) = {m ∈ S : m[i] = 0}
    
    This is the support-level analogue of setting x_i = 0 in a polynomial
    and retaining only the monomials that survive.
    
    Time complexity: O(|S|)
    Space complexity: O(|D_i(S)|)
    
    Args:
        S: Support set
        i: Coordinate index to delete
    
    Returns:
        Filtered support set
    """
    return [m for m in S if m[i] == 0]


def multi_deletion(S: Support, coords: List[int]) -> Support:
    """
    Support deletion at multiple coordinates simultaneously.
    
    D_A(S) = {m ∈ S : m[j] = 0 for all j ∈ A}
    
    Equivalent to iterated single deletion in any order.
    
    Time complexity: O(|S| · |A|)
    
    Args:
        S: Support set
        coords: List of coordinate indices to delete
    
    Returns:
        Filtered support set
    """
    coord_set = set(coords)
    return [m for m in S if all(m[j] == 0 for j in coord_set)]


# ============================================================
# Algorithm 3: Support Contraction
# ============================================================

def contraction(S: Support, i: int) -> Support:
    """
    Support contraction at coordinate i.
    
    C_i(S) = {m - min_val · e_i : m ∈ S, m[i] = min_val}
    where min_val = min{m[i] : m ∈ S}.
    
    This is the support-level analogue of dividing out the common
    x_i-power and projecting.
    
    Time complexity: O(|S|)
    Space complexity: O(|C_i(S)|)
    
    Args:
        S: Support set (must be nonempty)
        i: Coordinate index to contract
    
    Returns:
        Contracted support set
    """
    if not S:
        return []
    
    min_val = min(m[i] for m in S)
    result = []
    for m in S:
        if m[i] == min_val:
            m_new = list(m)
            m_new[i] = 0  # = m[i] - min_val
            result.append(tuple(m_new))
    return result


# ============================================================
# Algorithm 4: Loop and Coloop Detection
# ============================================================

def classify_coordinate(S: Support, i: int) -> str:
    """
    Classify coordinate i as loop, coloop, or regular.
    
    - Loop: all elements have positive i-value (deletion is empty)
    - Coloop: all elements have the same i-value
    - Regular: neither loop nor coloop
    
    Time complexity: O(|S|)
    
    Returns: "loop", "coloop", or "regular"
    """
    if not S:
        return "regular"
    
    vals = set(m[i] for m in S)
    
    if 0 not in vals:
        return "loop"
    elif len(vals) == 1:
        return "coloop"
    else:
        return "regular"


# ============================================================
# Algorithm 5: Support-Tutte Invariant
# ============================================================

def support_tutte(S: Support, n: int, x: int = 2, y: int = 2,
                   memo: Optional[Dict] = None) -> int:
    """
    Compute the support-Tutte invariant via deletion-contraction.
    
    Recurrence:
        T(∅) = 1
        T(S) = y · T(C_i(S))    if i is a loop
        T(S) = x · T(C_i(S))    if i is a coloop
        T(S) = T(D_i(S)) + T(C_i(S))  otherwise
    
    The recursion is well-founded because |D_i(S)| < |S| when i is regular
    and |C_i(S)| ≤ |S| always.
    
    Time complexity: O(2^|S| · n) worst case (with memoization, often much better)
    Space complexity: O(2^|S|) for memoization
    
    Args:
        S: Support set
        n: Dimension
        x, y: Tutte parameters
        memo: Memoization dictionary
    
    Returns:
        Integer value of the support-Tutte invariant at (x, y)
    """
    if memo is None:
        memo = {}
    
    key = frozenset(S)
    if key in memo:
        return memo[key]
    
    if not S:
        return 1
    
    # Find a coordinate to recurse on
    coord = None
    for i in range(n):
        vals = set(m[i] for m in S)
        if len(vals) > 1 or (len(vals) == 1 and 0 not in vals):
            coord = i
            break
    
    if coord is None:
        # All coordinates are constant zero
        memo[key] = 1
        return 1
    
    i = coord
    ctype = classify_coordinate(S, i)
    S_del = deletion(S, i)
    S_con = contraction(S, i)
    
    if ctype == "loop":
        result = y * support_tutte(S_con, n, x, y, memo)
    elif ctype == "coloop":
        result = x * support_tutte(S_con, n, x, y, memo)
    else:
        result = (support_tutte(S_del, n, x, y, memo) +
                  support_tutte(S_con, n, x, y, memo))
    
    memo[key] = result
    return result


# ============================================================
# Algorithm 6: Minor Chain Enumeration
# ============================================================

def enumerate_minors(S: Support, n: int, max_depth: int = 10) -> List[Tuple[str, Support]]:
    """
    Enumerate all minors of S up to a given depth.
    
    A minor is obtained by a sequence of deletions and contractions.
    
    Args:
        S: Initial support set
        n: Dimension
        max_depth: Maximum number of minor steps
    
    Returns:
        List of (operation_sequence, resulting_support) pairs
    """
    results = [("identity", S)]
    seen = {frozenset(S)}
    queue = [("", S)]
    
    for depth in range(max_depth):
        next_queue = []
        for ops, current in queue:
            for i in range(n):
                # Try deletion
                S_del = deletion(current, i)
                key_del = frozenset(S_del)
                if key_del not in seen:
                    seen.add(key_del)
                    label = f"{ops}D{i}," if ops else f"D{i},"
                    results.append((label, S_del))
                    next_queue.append((label, S_del))
                
                # Try contraction
                S_con = contraction(current, i)
                key_con = frozenset(S_con)
                if key_con not in seen:
                    seen.add(key_con)
                    label = f"{ops}C{i}," if ops else f"C{i},"
                    results.append((label, S_con))
                    next_queue.append((label, S_con))
        
        queue = next_queue
        if not queue:
            break
    
    return results


# ============================================================
# Algorithm 7: Matroid Support Construction
# ============================================================

def uniform_matroid_support(n: int, k: int) -> Tuple[Support, int]:
    """
    Construct the support of the uniform matroid U(k, n).
    
    The bases are all k-element subsets of {0, ..., n-1}.
    The support vectors are their indicator vectors.
    
    Returns: (support, dimension)
    """
    bases = list(combinations(range(n), k))
    support = []
    for B in bases:
        v = [0] * n
        for i in B:
            v[i] = 1
        support.append(tuple(v))
    return support, n


def degree_simplex_support(n: int, d: int) -> Tuple[Support, int]:
    """
    Construct the degree-d simplex on n variables.
    
    This is the set of all monomials x_1^{a_1} ... x_n^{a_n} with a_1 + ... + a_n = d.
    
    Returns: (support, dimension)
    """
    support = []
    
    def generate(remaining_vars, remaining_degree, current):
        if remaining_vars == 1:
            support.append(tuple(current + [remaining_degree]))
            return
        for val in range(remaining_degree + 1):
            generate(remaining_vars - 1, remaining_degree - val, current + [val])
    
    generate(n, d, [])
    return support, n


# ============================================================
# Main: Example Usage
# ============================================================

if __name__ == "__main__":
    print("Support Minor Theory — Algorithm Demonstrations")
    print("=" * 55)
    
    # Example 1: Uniform matroid
    S, n = uniform_matroid_support(4, 2)
    ok, _ = verify_exchange(S, n)
    print(f"\nU(2,4): {len(S)} bases, exchange = {ok}")
    print(f"  Tutte(2,2) = {support_tutte(S, n, 2, 2)}")
    
    # Example 2: Degree simplex
    S2, n2 = degree_simplex_support(3, 4)
    ok2, _ = verify_exchange(S2, n2)
    print(f"\nΔ(3,4): {len(S2)} monomials, exchange = {ok2}")
    print(f"  Tutte(2,2) = {support_tutte(S2, n2, 2, 2)}")
    
    # Example 3: Minor enumeration
    S3, n3 = uniform_matroid_support(3, 2)
    minors = enumerate_minors(S3, n3, max_depth=3)
    print(f"\nU(2,3): {len(minors)} distinct minors (depth ≤ 3)")
    for label, minor in minors:
        ok_m, _ = verify_exchange(minor, n3)
        print(f"  {label or 'id':15s} |S| = {len(minor):2d}  exchange = {ok_m}")
