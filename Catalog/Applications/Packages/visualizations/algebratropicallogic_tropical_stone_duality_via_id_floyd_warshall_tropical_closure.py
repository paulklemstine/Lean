#!/usr/bin/env python3
"""
Tropical Stone Duality: Core Algorithms

Implements the key algorithms from the tropical Stone duality theory:
1. Floyd-Warshall tropical closure
2. Spectrum computation (canonical potentials)
3. Essential edge extraction (minimal basis)
4. Separation verification
5. Reconstruction certification
"""

from itertools import product
from typing import List, Tuple, Set, Optional

INF = float('inf')

# Type aliases
CostMatrix = List[List[float]]
Potential = List[float]
Edge = Tuple[int, int, float]


def floyd_warshall_closure(n: int, rules: List[Edge]) -> CostMatrix:
    """Compute the shortest-path closure of weighted rules.

    This is the tropical analogue of transitive closure:
    in the min-plus semiring, shortest paths correspond to
    tropical matrix powers.

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        n: Number of formulas/vertices
        rules: List of (source, target, weight) triples

    Returns:
        n×n cost matrix satisfying triangle inequality
    """
    cost = [[INF] * n for _ in range(n)]
    for i in range(n):
        cost[i][i] = 0
    for src, tgt, wt in rules:
        cost[src][tgt] = min(cost[src][tgt], wt)

    for k in range(n):
        for i in range(n):
            if cost[i][k] >= INF:
                continue
            for j in range(n):
                if cost[k][j] >= INF:
                    continue
                new_cost = cost[i][k] + cost[k][j]
                if new_cost < cost[i][j]:
                    cost[i][j] = new_cost
    return cost


def compute_spectrum(cost: CostMatrix) -> List[Potential]:
    """Compute the canonical tropical spectrum.

    Returns the n canonical potentials, one per source vertex.
    Each canonical potential v_s assigns v_s(j) = cost(s, j).

    These are the fundamental dual objects in tropical Stone duality.

    Time complexity: O(n²) (just reading the cost matrix)

    Args:
        cost: n×n cost matrix

    Returns:
        List of n potential functions
    """
    n = len(cost)
    return [cost[s][:] for s in range(n)]


def verify_feasibility(cost: CostMatrix, potential: Potential) -> bool:
    """Verify that a potential is feasible (lies in the spectrum).

    A potential v is feasible if v(j) ≤ v(i) + cost(i,j) for all i,j.

    Time complexity: O(n²)

    Args:
        cost: n×n cost matrix
        potential: potential function to verify

    Returns:
        True if the potential is feasible
    """
    n = len(cost)
    for i in range(n):
        for j in range(n):
            vi, vj, cij = potential[i], potential[j], cost[i][j]
            bound = vi + cij if vi < INF and cij < INF else INF
            if vj > bound + 1e-10:
                return False
    return True


def verify_separation(cost: CostMatrix) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """Verify that the entailment is separated by canonical potentials.

    Two formulas i,j are separated if there exists a canonical
    potential v_s with v_s(i) ≠ v_s(j).

    Time complexity: O(n³)

    Args:
        cost: n×n cost matrix

    Returns:
        (True, None) if separated, (False, (i,j)) with witness of non-separation
    """
    n = len(cost)
    for i in range(n):
        for j in range(i + 1, n):
            separated = False
            for s in range(n):
                if cost[s][i] != cost[s][j]:
                    separated = True
                    break
            if not separated:
                return False, (i, j)
    return True, None


def extract_essential_edges(cost: CostMatrix) -> List[Edge]:
    """Extract the minimal set of essential edges.

    An edge (i,k) with finite cost is essential if there is no
    intermediate vertex j ≠ i,k with cost(i,j) + cost(j,k) ≤ cost(i,k).

    This implements the tropical analogue of irredundant axiom extraction.

    Time complexity: O(n³)

    Args:
        cost: n×n cost matrix

    Returns:
        List of essential edges (source, target, weight)
    """
    n = len(cost)
    essential = []
    for i in range(n):
        for k in range(n):
            if i == k or cost[i][k] >= INF:
                continue
            is_essential = True
            for j in range(n):
                if j == i or j == k:
                    continue
                if cost[i][j] < INF and cost[j][k] < INF:
                    if cost[i][j] + cost[j][k] <= cost[i][k]:
                        is_essential = False
                        break
            if is_essential:
                essential.append((i, k, cost[i][k]))
    return essential


def certify_reconstruction(cost: CostMatrix) -> dict:
    """Complete certified reconstruction pipeline.

    Given a cost matrix:
    1. Compute the canonical spectrum
    2. Extract essential edges (minimal basis)
    3. Verify the reconstruction is correct
    4. Verify separation

    Time complexity: O(n³)

    Args:
        cost: n×n cost matrix

    Returns:
        Dictionary with spectrum, basis, and certification results
    """
    n = len(cost)
    spectrum = compute_spectrum(cost)
    essential = extract_essential_edges(cost)
    is_sep, witness = verify_separation(cost)

    # Verify each canonical potential is feasible
    all_feasible = all(verify_feasibility(cost, pot) for pot in spectrum)

    # Reconstruct from essential edges and verify
    recon = floyd_warshall_closure(n, essential)
    reconstruction_correct = all(
        abs(cost[i][j] - recon[i][j]) < 1e-10
        if cost[i][j] < INF else recon[i][j] >= INF
        for i in range(n) for j in range(n)
    )

    # Verify irredundancy: removing any essential edge changes the closure
    is_irredundant = True
    for idx in range(len(essential)):
        reduced = essential[:idx] + essential[idx+1:]
        reduced_cost = floyd_warshall_closure(n, reduced)
        src, tgt, _ = essential[idx]
        if abs(reduced_cost[src][tgt] - cost[src][tgt]) < 1e-10:
            is_irredundant = False
            break

    total_finite = sum(1 for i in range(n) for j in range(n)
                       if i != j and cost[i][j] < INF)

    return {
        'n': n,
        'spectrum': spectrum,
        'essential_edges': essential,
        'is_separated': is_sep,
        'separation_witness': witness,
        'all_feasible': all_feasible,
        'reconstruction_correct': reconstruction_correct,
        'is_irredundant': is_irredundant,
        'total_finite_edges': total_finite,
        'essential_count': len(essential),
        'compression_ratio': len(essential) / total_finite if total_finite > 0 else 0,
    }


def tropical_matrix_power(cost: CostMatrix, k: int) -> CostMatrix:
    """Compute the k-th tropical matrix power.

    In the min-plus semiring, matrix multiplication corresponds to
    shortest paths of exactly k steps.

    Time complexity: O(n³ · k)

    Args:
        cost: n×n cost matrix
        k: power

    Returns:
        k-th tropical power of the cost matrix
    """
    n = len(cost)
    if k == 0:
        result = [[INF] * n for _ in range(n)]
        for i in range(n):
            result[i][i] = 0
        return result

    result = [row[:] for row in cost]
    for _ in range(k - 1):
        new_result = [[INF] * n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                for m in range(n):
                    if result[i][m] < INF and cost[m][j] < INF:
                        new_result[i][j] = min(new_result[i][j],
                                               result[i][m] + cost[m][j])
        result = new_result
    return result


if __name__ == "__main__":
    print("Tropical Stone Duality: Algorithm Demonstrations")
    print("=" * 50)

    # Example: 5-formula chain
    rules = [(0, 1, 1), (1, 2, 2), (2, 3, 1), (3, 4, 3)]
    cost = floyd_warshall_closure(5, rules)

    print("\n5-formula chain: 0→1→2→3→4")
    result = certify_reconstruction(cost)

    print(f"  Formulas: {result['n']}")
    print(f"  Separated: {result['is_separated']}")
    print(f"  All canonical potentials feasible: {result['all_feasible']}")
    print(f"  Essential edges: {result['essential_count']}")
    print(f"  Reconstruction correct: {result['reconstruction_correct']}")
    print(f"  Basis irredundant: {result['is_irredundant']}")
    print(f"  Compression: {result['total_finite_edges']} → "
          f"{result['essential_count']} "
          f"({result['compression_ratio']:.0%})")

    print("\n  Essential edge list:")
    for src, tgt, wt in result['essential_edges']:
        print(f"    φ{src} →(cost {int(wt)})→ φ{tgt}")

    # Example: random-looking graph
    print("\n\nComplex graph example:")
    rules2 = [
        (0, 1, 3), (0, 2, 1), (1, 3, 2), (2, 3, 4),
        (2, 1, 1), (3, 4, 1), (1, 4, 5)
    ]
    cost2 = floyd_warshall_closure(5, rules2)
    result2 = certify_reconstruction(cost2)

    print(f"  Essential edges: {result2['essential_count']}")
    print(f"  Reconstruction correct: {result2['reconstruction_correct']}")
    print(f"  Basis irredundant: {result2['is_irredundant']}")
    for src, tgt, wt in result2['essential_edges']:
        print(f"    φ{src} →(cost {int(wt)})→ φ{tgt}")
