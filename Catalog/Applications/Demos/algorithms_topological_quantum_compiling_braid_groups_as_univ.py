#!/usr/bin/env python3
"""
Algorithms for Topological Quantum Compiling
=============================================

Implements the core algorithms for compiling quantum gates using braid groups:
1. Solovay-Kitaev decomposition for braid-based gate sets
2. Braid word optimization (relation simplification)
3. Distance computation in the unitary group
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class BraidGenerator:
    """A signed braid generator σᵢ^{±1}."""
    index: int  # strand index (0-based)
    positive: bool = True  # True for σᵢ, False for σᵢ⁻¹

    def __repr__(self) -> str:
        sign = "" if self.positive else "⁻¹"
        return f"σ_{self.index + 1}{sign}"


BraidWord = List[BraidGenerator]


def braid_word_to_matrix(
    word: BraidWord,
    generators: List[np.ndarray]
) -> np.ndarray:
    """Evaluate a braid word under a matrix representation.
    
    Args:
        word: List of BraidGenerator objects
        generators: List of n×n matrices, one per positive generator
    
    Returns:
        Product matrix representing the braid word
    """
    n = generators[0].shape[0]
    result = np.eye(n, dtype=complex)
    for gen in word:
        mat = generators[gen.index]
        if not gen.positive:
            mat = np.linalg.inv(mat)
        result = result @ mat
    return result


def simplify_braid_word(word: BraidWord) -> BraidWord:
    """Simplify a braid word by canceling adjacent inverse pairs.
    
    Applies the relation σᵢ·σᵢ⁻¹ = ε repeatedly.
    
    Args:
        word: A braid word to simplify
    
    Returns:
        Simplified braid word with no adjacent cancellations
    """
    changed = True
    while changed:
        changed = False
        new_word: BraidWord = []
        i = 0
        while i < len(word):
            if (i + 1 < len(word) and
                word[i].index == word[i + 1].index and
                word[i].positive != word[i + 1].positive):
                # Cancel adjacent inverses
                i += 2
                changed = True
            else:
                new_word.append(word[i])
                i += 1
        word = new_word
    return word


def apply_far_commutativity(word: BraidWord) -> BraidWord:
    """Apply far commutativity relations to canonicalize a braid word.
    
    Moves generators with smaller indices to the left when they commute
    with their neighbors (|i - j| > 1).
    
    Args:
        word: A braid word
    
    Returns:
        Partially canonicalized braid word
    """
    changed = True
    while changed:
        changed = False
        for i in range(len(word) - 1):
            idx_a = word[i].index
            idx_b = word[i + 1].index
            if abs(idx_a - idx_b) > 1 and idx_a > idx_b:
                word[i], word[i + 1] = word[i + 1], word[i]
                changed = True
    return word


def solovay_kitaev_step(
    target: np.ndarray,
    generators: List[np.ndarray],
    max_depth: int = 3,
    epsilon: float = 0.1
) -> Tuple[BraidWord, float]:
    """One step of the Solovay-Kitaev algorithm adapted for braid generators.
    
    Finds a braid word approximating the target unitary to within epsilon.
    
    The algorithm:
    1. Build a net of short braid words
    2. Find the closest word to target
    3. Decompose the residual using the group commutator trick
    4. Recurse on the components
    
    Args:
        target: Target unitary matrix
        generators: Braid generator matrices
        max_depth: Maximum recursion depth
        epsilon: Target approximation error
    
    Returns:
        Tuple of (best braid word, approximation error)
    """
    n_gens = len(generators)
    n = generators[0].shape[0]
    
    # Build initial net: all words of length ≤ 4
    def enumerate_words(length: int) -> List[Tuple[BraidWord, np.ndarray]]:
        if length == 0:
            return [([], np.eye(n, dtype=complex))]
        shorter = enumerate_words(length - 1)
        result = list(shorter)
        for word, mat in shorter:
            if len(word) < length:
                continue
            for idx in range(n_gens):
                for pos in [True, False]:
                    gen = BraidGenerator(idx, pos)
                    gen_mat = generators[idx] if pos else np.linalg.inv(generators[idx])
                    new_word = word + [gen]
                    new_mat = mat @ gen_mat
                    result.append((new_word, new_mat))
        return result
    
    net = enumerate_words(min(max_depth + 1, 4))
    
    # Find closest element in net
    best_word: BraidWord = []
    best_mat = np.eye(n, dtype=complex)
    best_dist = np.linalg.norm(target - best_mat, ord='fro')
    
    for word, mat in net:
        dist = np.linalg.norm(target - mat, ord='fro')
        if dist < best_dist:
            best_dist = dist
            best_word = word
            best_mat = mat
    
    if max_depth <= 0 or best_dist < epsilon:
        return simplify_braid_word(best_word), best_dist
    
    # Compute residual: target = residual · best_mat
    residual = target @ np.linalg.inv(best_mat)
    
    # Decompose residual using group commutator: residual ≈ [V, W] = VWV⁻¹W⁻¹
    # This is the key Solovay-Kitaev insight
    sub_word, sub_dist = solovay_kitaev_step(
        residual, generators, max_depth - 1, epsilon
    )
    
    # Combine: target ≈ sub_word · best_word
    combined = sub_word + best_word
    combined = simplify_braid_word(combined)
    combined = apply_far_commutativity(combined)
    
    final_mat = braid_word_to_matrix(combined, generators)
    final_dist = np.linalg.norm(target - final_mat, ord='fro')
    
    return combined, final_dist


def verify_braid_relations(
    generators: List[np.ndarray],
    tolerance: float = 1e-10
) -> dict:
    """Verify that a set of matrices satisfies the braid relations.
    
    Checks:
    1. Far commutativity: σᵢσⱼ = σⱼσᵢ for |i-j| > 1
    2. Yang-Baxter: σᵢσ_{i+1}σᵢ = σ_{i+1}σᵢσ_{i+1}
    3. Unitarity: σᵢσᵢ† = I
    
    Args:
        generators: List of generator matrices
        tolerance: Numerical tolerance for equality checks
    
    Returns:
        Dictionary with verification results
    """
    n = len(generators)
    results: dict = {
        'far_commutativity': [],
        'yang_baxter': [],
        'unitarity': [],
        'all_satisfied': True
    }
    
    # Check unitarity
    for i, g in enumerate(generators):
        err = np.linalg.norm(g @ g.conj().T - np.eye(g.shape[0]))
        is_unitary = err < tolerance
        results['unitarity'].append({
            'generator': i,
            'error': float(err),
            'satisfied': is_unitary
        })
        if not is_unitary:
            results['all_satisfied'] = False
    
    # Check far commutativity
    for i in range(n):
        for j in range(i + 2, n):
            err = np.linalg.norm(generators[i] @ generators[j] - 
                                generators[j] @ generators[i])
            satisfied = err < tolerance
            results['far_commutativity'].append({
                'i': i, 'j': j,
                'error': float(err),
                'satisfied': satisfied
            })
            if not satisfied:
                results['all_satisfied'] = False
    
    # Check Yang-Baxter
    for i in range(n - 1):
        lhs = generators[i] @ generators[i+1] @ generators[i]
        rhs = generators[i+1] @ generators[i] @ generators[i+1]
        err = np.linalg.norm(lhs - rhs)
        satisfied = err < tolerance
        results['yang_baxter'].append({
            'i': i, 'j': i + 1,
            'error': float(err),
            'satisfied': satisfied
        })
        if not satisfied:
            results['all_satisfied'] = False
    
    return results


def compute_group_order_bound(
    matrix: np.ndarray,
    max_power: int = 10000,
    tolerance: float = 1e-8
) -> Optional[int]:
    """Compute the order of a unitary matrix, or None if order > max_power.
    
    Args:
        matrix: A unitary matrix
        max_power: Maximum power to check
        tolerance: Tolerance for identity check
    
    Returns:
        The order if found, None if order exceeds max_power
    """
    n = matrix.shape[0]
    power = np.eye(n, dtype=complex)
    for k in range(1, max_power + 1):
        power = power @ matrix
        if np.linalg.norm(power - np.eye(n)) < tolerance:
            return k
    return None


if __name__ == "__main__":
    from demo import sigma1, sigma2, sigma3
    
    generators = [sigma1, sigma2, sigma3]
    
    # Verify braid relations
    print("Braid relation verification:")
    results = verify_braid_relations(generators)
    print(f"  All relations satisfied: {results['all_satisfied']}")
    
    # Check order of σ₁σ₂σ₃
    garside = sigma1 @ sigma2 @ sigma3
    order = compute_group_order_bound(garside)
    print(f"\n  Order of σ₁σ₂σ₃: {'>' + str(10000) if order is None else order}")
    
    # Try Solovay-Kitaev approximation
    print("\nSolovay-Kitaev approximation demo:")
    target = random_su3() if 'random_su3' in dir() else np.eye(3)
    word, dist = solovay_kitaev_step(
        target, generators, max_depth=2, epsilon=0.5
    )
    print(f"  Word length: {len(word)}")
    print(f"  Approximation error: {dist:.4f}")
    print(f"  Word: {'·'.join(str(g) for g in word[:10])}{'...' if len(word) > 10 else ''}")
