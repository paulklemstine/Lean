#!/usr/bin/env python3
"""
Algorithms for Berggren Spectral Expansion

This module implements the core algorithms underlying the spectral
theory of Berggren dynamics on primitive Pythagorean triples.

Algorithms:
1. Berggren tree generation with arbitrary depth
2. Spectral gap computation for the averaging operator
3. L² mixing simulator with convergence certificates
4. Deterministic extraction from Berggren dynamics
5. Mod-q orbit computation
"""

import numpy as np
from typing import List, Tuple, Optional

# ─── Berggren Generator Matrices ──────────────────────────────────────────

B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)
GENERATORS = [B1, B2, B3]
Q_LORENTZ = np.diag([1, 1, -1])


def is_pythagorean(triple: np.ndarray) -> bool:
    """Check if (a,b,c) is a Pythagorean triple: a² + b² = c²."""
    return triple[0]**2 + triple[1]**2 == triple[2]**2


def lorentz_form(v: np.ndarray) -> int:
    """Evaluate Q(v) = v₀² + v₁² - v₂²."""
    return int(v[0]**2 + v[1]**2 - v[2]**2)


# ─── Algorithm 1: Berggren Tree Generation ────────────────────────────────

def berggren_tree(root: np.ndarray, depth: int) -> List[np.ndarray]:
    """
    Generate all primitive Pythagorean triples in the Berggren tree
    up to the given depth.

    Complexity: O(3^depth) triples generated.

    Parameters
    ----------
    root : array of shape (3,)
        Starting triple, typically [3, 4, 5].
    depth : int
        Maximum depth to explore.

    Returns
    -------
    list of arrays
        All triples at all levels up to `depth`.

    Example
    -------
    >>> triples = berggren_tree(np.array([3, 4, 5]), 2)
    >>> len(triples)  # 1 + 3 + 9 = 13
    13
    """
    result = [root.copy()]
    current_level = [root.copy()]
    for _ in range(depth):
        next_level = []
        for triple in current_level:
            for B in GENERATORS:
                child = B @ triple
                result.append(child)
                next_level.append(child)
        current_level = next_level
    return result


# ─── Algorithm 2: Spectral Gap Computation ────────────────────────────────

def spectral_gap_sibling(k: int = 3) -> Tuple[float, np.ndarray]:
    """
    Compute the spectral gap of the complete graph K_k transition matrix.

    The transition matrix T has T[i,j] = 1/(k-1) if i ≠ j, 0 otherwise.
    Eigenvalues: 1 (multiplicity 1), -1/(k-1) (multiplicity k-1).
    Spectral gap: 1 - 1/(k-1) = (k-2)/(k-1).

    For k=3 (Berggren siblings): gap = 1/2, |λ₂| = 1/2.

    Parameters
    ----------
    k : int
        Number of vertices (default 3 for Berggren).

    Returns
    -------
    gap : float
        The spectral gap 1 - |λ₂|.
    eigenvalues : array
        All eigenvalues sorted by magnitude.
    """
    T = np.zeros((k, k))
    for i in range(k):
        for j in range(k):
            if i != j:
                T[i, j] = 1.0 / (k - 1)
    eigenvalues = np.sort(np.linalg.eigvalsh(T))[::-1]
    gap = 1.0 - abs(eigenvalues[1])
    return gap, eigenvalues


# ─── Algorithm 3: L² Mixing Simulator ─────────────────────────────────────

def l2_mixing_simulator(
    initial_distribution: np.ndarray,
    max_iterations: int = 50,
    tolerance: float = 1e-12
) -> dict:
    """
    Simulate L² mixing of a distribution under the Berggren sibling walk.

    Tracks: L² distance to uniform, contraction ratios, convergence iteration.

    Complexity: O(max_iterations × k²) where k = len(initial_distribution).

    Parameters
    ----------
    initial_distribution : array
        Starting probability distribution on k elements.
    max_iterations : int
        Maximum number of iterations.
    tolerance : float
        Convergence threshold for L² distance.

    Returns
    -------
    dict with keys:
        'l2_distances': list of L² distances² at each step
        'contraction_ratios': list of successive ratios
        'converged_at': iteration of convergence (or -1)
        'final_distribution': distribution after last iteration
        'theoretical_bound': list of (1/4)^k × initial L² distance²
    """
    k = len(initial_distribution)
    T = np.zeros((k, k))
    for i in range(k):
        for j in range(k):
            if i != j:
                T[i, j] = 1.0 / (k - 1)

    uniform = np.ones(k) / k
    f = initial_distribution.copy()
    initial_l2sq = np.sum((f - uniform)**2)

    l2_distances = []
    contraction_ratios = []
    converged_at = -1

    for step in range(max_iterations + 1):
        l2sq = np.sum((f - uniform)**2)
        l2_distances.append(l2sq)
        if step > 0 and l2_distances[step - 1] > 0:
            contraction_ratios.append(l2sq / l2_distances[step - 1])
        if l2sq < tolerance and converged_at == -1:
            converged_at = step
        f = T @ f

    rho_sq = 1.0 / (k - 1)**2
    theoretical = [rho_sq**step * initial_l2sq for step in range(max_iterations + 1)]

    return {
        'l2_distances': l2_distances,
        'contraction_ratios': contraction_ratios,
        'converged_at': converged_at,
        'final_distribution': f,
        'theoretical_bound': theoretical,
    }


# ─── Algorithm 4: Deterministic Extractor ──────────────────────────────────

def berggren_extractor(
    source_distribution: np.ndarray,
    target_entropy_bits: float,
    max_steps: int = 100
) -> dict:
    """
    Deterministic extractor using Berggren dynamics.

    Given a weak source (non-uniform distribution), apply iterated
    Berggren sibling walk to extract near-uniform output.

    The number of steps needed is:
        t = ⌈log(initial_L2² / ε²) / log(4)⌉

    Parameters
    ----------
    source_distribution : array
        Input weak source on k elements.
    target_entropy_bits : float
        Target Rényi-2 entropy in bits.
    max_steps : int
        Safety limit on iterations.

    Returns
    -------
    dict with keys:
        'output_distribution': extracted distribution
        'steps_needed': number of iterations used
        'final_renyi2': achieved Rényi-2 entropy
        'target_renyi2': target entropy
        'entropy_trajectory': Rényi-2 entropy at each step
    """
    k = len(source_distribution)
    T = np.zeros((k, k))
    for i in range(k):
        for j in range(k):
            if i != j:
                T[i, j] = 1.0 / (k - 1)

    f = source_distribution.copy()
    entropy_trajectory = []

    for step in range(max_steps + 1):
        cp = np.sum(f**2)
        h2 = -np.log2(cp) if cp > 0 else float('inf')
        entropy_trajectory.append(h2)
        if h2 >= target_entropy_bits:
            return {
                'output_distribution': f.copy(),
                'steps_needed': step,
                'final_renyi2': h2,
                'target_renyi2': target_entropy_bits,
                'entropy_trajectory': entropy_trajectory,
            }
        f = T @ f

    cp = np.sum(f**2)
    return {
        'output_distribution': f.copy(),
        'steps_needed': max_steps,
        'final_renyi2': -np.log2(cp) if cp > 0 else float('inf'),
        'target_renyi2': target_entropy_bits,
        'entropy_trajectory': entropy_trajectory,
    }


# ─── Algorithm 5: Mod-q Orbit Computation ─────────────────────────────────

def berggren_orbit_mod_q(
    root: np.ndarray,
    q: int,
    depth: int
) -> dict:
    """
    Compute the Berggren orbit modulo q.

    For a prime q, reduce the Berggren tree modulo q and track
    collisions (distinct triples mapping to the same residue class).

    Parameters
    ----------
    root : array
        Starting triple (e.g., [3, 4, 5]).
    q : int
        Modulus (should be prime, ≥ 5).
    depth : int
        Tree depth to explore.

    Returns
    -------
    dict with keys:
        'orbit_size': number of distinct residue classes visited
        'total_nodes': total number of nodes generated
        'collision_rate': fraction of nodes that collide
        'orbit_elements': set of distinct (a mod q, b mod q, c mod q)
    """
    visited = set()
    total = 0
    current = [root % q]
    visited.add(tuple(root % q))
    total += 1

    for _ in range(depth):
        next_level = []
        for triple in current:
            for B in GENERATORS:
                child = (B @ triple) % q
                visited.add(tuple(child))
                next_level.append(child)
                total += 1
        current = next_level

    return {
        'orbit_size': len(visited),
        'total_nodes': total,
        'collision_rate': 1.0 - len(visited) / total if total > 0 else 0,
        'orbit_elements': visited,
    }


# ─── Main: Run All Algorithms ─────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("BERGGREN SPECTRAL EXPANSION — ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # 1. Tree generation
    print("\n1. Berggren Tree Generation (depth 3)")
    triples = berggren_tree(np.array([3, 4, 5]), 3)
    print(f"   Generated {len(triples)} triples")
    print(f"   All Pythagorean: {all(is_pythagorean(t) for t in triples)}")
    hypotenuses = sorted(set(t[2] for t in triples))
    print(f"   Hypotenuses: {hypotenuses[:10]}...")

    # 2. Spectral gap
    print("\n2. Spectral Gap Computation")
    for k in [3, 4, 5, 10]:
        gap, eigs = spectral_gap_sibling(k)
        print(f"   K_{k}: gap = {gap:.4f}, |λ₂| = {abs(eigs[1]):.4f}")

    # 3. Mixing simulation
    print("\n3. L² Mixing Simulation")
    result = l2_mixing_simulator(np.array([0.9, 0.08, 0.02]))
    print(f"   Initial L²: {result['l2_distances'][0]:.6f}")
    print(f"   After 10 steps: {result['l2_distances'][10]:.12f}")
    print(f"   Converged at step: {result['converged_at']}")
    print(f"   Contraction ratio: {np.mean(result['contraction_ratios'][:5]):.4f} (theory: 0.25)")

    # 4. Extractor
    print("\n4. Deterministic Extractor")
    weak_source = np.array([0.7, 0.2, 0.1])
    target = np.log2(3) - 0.01  # near-uniform
    ext = berggren_extractor(weak_source, target)
    print(f"   Input H₂: {ext['entropy_trajectory'][0]:.4f} bits")
    print(f"   Target H₂: {target:.4f} bits")
    print(f"   Steps needed: {ext['steps_needed']}")
    print(f"   Output H₂: {ext['final_renyi2']:.4f} bits")
    print(f"   Output dist: {ext['output_distribution']}")

    # 5. Mod-q orbits
    print("\n5. Mod-q Orbit Analysis")
    root = np.array([3, 4, 5])
    for q in [5, 7, 11, 13, 17, 23, 29, 31]:
        orb = berggren_orbit_mod_q(root, q, 4)
        print(f"   q={q:3d}: orbit size = {orb['orbit_size']:4d}, "
              f"total = {orb['total_nodes']:4d}, "
              f"collision rate = {orb['collision_rate']:.3f}")
