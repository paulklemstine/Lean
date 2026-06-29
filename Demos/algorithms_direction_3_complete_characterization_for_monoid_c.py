#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Monoid Right Detection and Compression Classification

Implements the computational methods behind the classification theorem:
  κ(BM) = 0 iff M is trivial, κ(BM) = 1 iff M is nontrivial.

Algorithms:
1. right_detects: O(n³) verification of the right detection property
2. right_regular_embedding: O(n²) computation of the Cayley representation
3. probe_complexity_single_obj: O(1) classification using the theorem
4. find_all_separators: O(n³) computation of all separating elements
5. monoid_validator: O(n³) validation of multiplication tables
"""

from typing import Optional


def is_valid_monoid(table: list[list[int]], n: int) -> tuple[bool, Optional[int], str]:
    """
    Validate a multiplication table as a monoid.
    
    Args:
        table: n×n multiplication table where table[i][j] = i * j
        n: order of the monoid
    
    Returns:
        (is_valid, identity, error_message)
    
    Time complexity: O(n³) for associativity check
    Space complexity: O(1) additional
    """
    # Check dimensions
    if len(table) != n or any(len(row) != n for row in table):
        return False, None, "Table dimensions don't match n"
    
    # Check closure
    for i in range(n):
        for j in range(n):
            if not (0 <= table[i][j] < n):
                return False, None, f"Product {i}*{j}={table[i][j]} out of range"
    
    # Find identity
    identity = None
    for e in range(n):
        if all(table[e][a] == a and table[a][e] == a for a in range(n)):
            identity = e
            break
    if identity is None:
        return False, None, "No identity element found"
    
    # Check associativity: (a*b)*c = a*(b*c)
    for a in range(n):
        for b in range(n):
            for c in range(n):
                lhs = table[table[a][b]][c]
                rhs = table[a][table[b][c]]
                if lhs != rhs:
                    return False, None, (
                        f"Associativity fails: ({a}*{b})*{c}={lhs} "
                        f"≠ {a}*({b}*{c})={rhs}"
                    )
    
    return True, identity, "Valid monoid"


def right_detects(table: list[list[int]], n: int) -> bool:
    """
    Check if a monoid satisfies the RightDetects property.
    
    RightDetects(M) := ∀ a ≠ b, ∃ c, a*c ≠ b*c
    
    For monoids, this always returns True (the identity separates),
    but this function verifies it computationally.
    
    Args:
        table: n×n multiplication table
        n: order of the monoid
    
    Returns:
        True iff RightDetects holds
    
    Time complexity: O(n³) worst case, O(n²) best case
    Space complexity: O(1) additional
    """
    for a in range(n):
        for b in range(a + 1, n):
            if not any(table[a][c] != table[b][c] for c in range(n)):
                return False
    return True


def right_regular_embedding(table: list[list[int]], n: int) -> dict[int, tuple[int, ...]]:
    """
    Compute the right regular representation ρ: M → End(M).
    
    ρ(a)(c) = a * c
    
    For monoids, this is always injective (distinct elements map to
    distinct endomorphisms).
    
    Args:
        table: n×n multiplication table
        n: order of the monoid
    
    Returns:
        Dictionary mapping each element to its transition function (as tuple)
    
    Time complexity: O(n²)
    Space complexity: O(n²) for the output
    """
    return {a: tuple(table[a][c] for c in range(n)) for a in range(n)}


def is_right_regular_injective(table: list[list[int]], n: int) -> bool:
    """
    Check if the right regular representation is injective.
    
    Equivalent to RightDetects by the theorem
    rightDetects_iff_rightRegular_injective.
    
    Time complexity: O(n²)
    Space complexity: O(n²) for the hash set
    """
    rre = right_regular_embedding(table, n)
    return len(set(rre.values())) == n


def find_all_separators(
    table: list[list[int]], n: int, a: int, b: int
) -> list[int]:
    """
    Find all elements c that separate a from b: a*c ≠ b*c.
    
    By the theorem, for any monoid with a ≠ b, at least c=identity works.
    
    Args:
        table: n×n multiplication table
        n: order
        a, b: distinct elements to separate
    
    Returns:
        List of all separating elements
    
    Time complexity: O(n)
    """
    return [c for c in range(n) if table[a][c] != table[b][c]]


def probe_complexity_single_obj(n: int) -> int:
    """
    Compute the probe complexity κ(BM) for a monoid of order n.
    
    By the classification theorem:
    - κ = 0 if n = 1 (trivial monoid)
    - κ = 1 if n ≥ 2 (nontrivial monoid)
    
    This is O(1) — the theorem gives the answer directly without
    needing the multiplication table.
    
    Args:
        n: order of the monoid (must be ≥ 1)
    
    Returns:
        0 or 1
    """
    if n < 1:
        raise ValueError("Monoid must have at least one element")
    return 0 if n == 1 else 1


def is_right_zero(table: list[list[int]], n: int, z: int) -> bool:
    """
    Check if z is a right zero: a * z = z for all a.
    
    Time complexity: O(n)
    """
    return all(table[a][z] == z for a in range(n))


def find_right_zeros(table: list[list[int]], n: int) -> list[int]:
    """
    Find all right zero elements.
    
    Time complexity: O(n²)
    """
    return [z for z in range(n) if is_right_zero(table, n, z)]


def separation_matrix(table: list[list[int]], n: int) -> list[list[list[int]]]:
    """
    Compute the full separation matrix.
    
    separation_matrix[a][b] = list of c such that a*c ≠ b*c.
    
    This gives a complete picture of which elements separate which pairs.
    The diagonal entries are empty (a always equals itself).
    
    Time complexity: O(n³)
    Space complexity: O(n³)
    """
    matrix = [[[] for _ in range(n)] for _ in range(n)]
    for a in range(n):
        for b in range(n):
            if a != b:
                matrix[a][b] = find_all_separators(table, n, a, b)
    return matrix


def minimal_separating_set(table: list[list[int]], n: int) -> set[int]:
    """
    Find a minimal set of elements C ⊆ M such that for all a ≠ b,
    there exists c ∈ C with a*c ≠ b*c.
    
    By the theorem, the identity element alone always suffices, so
    this always returns a singleton. But we implement the greedy
    algorithm for generality.
    
    Time complexity: O(n³) greedy
    """
    # Pairs to separate
    pairs = {(a, b) for a in range(n) for b in range(a + 1, n)}
    if not pairs:
        return set()
    
    selected: set[int] = set()
    unseparated = pairs.copy()
    
    while unseparated:
        # Greedy: pick the c that separates the most remaining pairs
        best_c = 0
        best_count = 0
        for c in range(n):
            count = sum(1 for a, b in unseparated if table[a][c] != table[b][c])
            if count > best_count:
                best_count = count
                best_c = c
        
        selected.add(best_c)
        unseparated = {(a, b) for a, b in unseparated
                       if table[a][best_c] == table[b][best_c]}
    
    return selected


if __name__ == "__main__":
    # Example usage
    print("=== Algorithms for Monoid Right Detection ===\n")
    
    # Z/3Z
    table = [[0,1,2],[1,2,0],[2,0,1]]
    n = 3
    valid, identity, msg = is_valid_monoid(table, n)
    print(f"Z/3Z: {msg}, identity={identity}")
    print(f"  RightDetects: {right_detects(table, n)}")
    print(f"  Right regular injective: {is_right_regular_injective(table, n)}")
    print(f"  κ(BM) = {probe_complexity_single_obj(n)}")
    print(f"  Right zeros: {find_right_zeros(table, n)}")
    print(f"  Minimal separating set: {minimal_separating_set(table, n)}")
    
    rre = right_regular_embedding(table, n)
    print(f"  Right regular representation:")
    for a, func in rre.items():
        print(f"    ρ({a}) = {func}")
    
    sep = separation_matrix(table, n)
    print(f"  Separation matrix (separators for each pair):")
    for a in range(n):
        for b in range(a+1, n):
            print(f"    ({a},{b}): separated by {sep[a][b]}")
