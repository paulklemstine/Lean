#!/usr/bin/env python3
"""
Algorithms for Tropical Semigroup Hardness Amplification.

Implements the key algorithms from the research:
1. Tropical matrix power computation (min-plus semiring)
2. Hardness amplification parameter computation
3. Leftover hash lemma error estimation
4. Entropy accumulation for tropical sources
"""

import numpy as np
from typing import List, Tuple, Optional


# ─── Tropical (Min-Plus) Algebra ──────────────────────────────────────────

def tropical_add(a: float, b: float) -> float:
    """Tropical addition: a ⊕ b = min(a, b)."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a ⊙ b = a + b."""
    return a + b


def tropical_matrix_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix multiplication (min-plus).
    
    (A ⊙ B)[i,j] = min_k (A[i,k] + B[k,j])
    
    Time complexity: O(n³) where n is the matrix dimension.
    Space complexity: O(n²) for the result matrix.
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_matrix_power(G: np.ndarray, t: int) -> np.ndarray:
    """
    Compute G^t in the tropical (min-plus) semiring via repeated squaring.
    
    Time complexity: O(n³ · log t)
    Space complexity: O(n²)
    
    Args:
        G: n×n matrix with real entries
        t: positive integer exponent
    
    Returns:
        G^t in the min-plus semiring
    """
    n = G.shape[0]
    result = np.zeros((n, n))  # tropical identity: 0 on diagonal, inf elsewhere
    np.fill_diagonal(result, 0)
    result[result == 0] = np.inf
    np.fill_diagonal(result, 0)
    
    # Actually, the tropical identity has 0 on diagonal and inf off diagonal
    identity = np.full((n, n), np.inf)
    np.fill_diagonal(identity, 0)
    result = identity.copy()
    
    base = G.copy()
    while t > 0:
        if t % 2 == 1:
            result = tropical_matrix_mul(result, base)
        base = tropical_matrix_mul(base, base)
        t //= 2
    return result


# ─── Distribution Extraction from Tropical Actions ───────────────────────

def boltzmann_distribution(costs: np.ndarray, beta: float = 1.0) -> np.ndarray:
    """
    Extract a probability distribution from tropical costs via Boltzmann.
    
    p(x) = exp(-β · cost(x)) / Z(β)
    
    This is the bridge from tropical algebra to probability distributions.
    
    Args:
        costs: array of costs (tropical action outputs)
        beta: inverse temperature parameter
    
    Returns:
        Normalized probability distribution
    """
    weights = np.exp(-beta * costs)
    return weights / weights.sum()


def tropical_action_distribution(G: np.ndarray, t: int, 
                                  row: int = 0, beta: float = 1.0) -> np.ndarray:
    """
    Generate a distribution from a tropical matrix power action.
    
    1. Compute G^t in min-plus semiring
    2. Extract row `row` as cost vector
    3. Convert to probability via Boltzmann distribution
    
    This models the output of a tropical semigroup action instance.
    """
    Gt = tropical_matrix_power(G, t)
    costs = Gt[row]
    return boltzmann_distribution(costs, beta)


# ─── Information-Theoretic Quantities ────────────────────────────────────

def max_probability(p: np.ndarray) -> float:
    """Maximum probability (guessing probability / predictability)."""
    return float(p.max())


def min_entropy_bits(p: np.ndarray) -> float:
    """Min-entropy in bits: H∞(X) = -log₂(max_x p(x))."""
    return -np.log2(max_probability(p))


def collision_probability(p: np.ndarray) -> float:
    """Collision probability: Cp(X) = Σ_x p(x)²."""
    return float((p ** 2).sum())


def renyi_entropy(p: np.ndarray, alpha: float = 2.0) -> float:
    """
    Rényi entropy of order α.
    H_α(X) = 1/(1-α) · log₂(Σ_x p(x)^α)
    
    Special cases:
    - α → 1: Shannon entropy
    - α = 2: collision entropy = -log₂(Cp(X))
    - α → ∞: min-entropy
    """
    if alpha == 1.0:
        # Shannon entropy
        return -float((p * np.log2(p + 1e-300)).sum())
    elif np.isinf(alpha):
        return min_entropy_bits(p)
    else:
        return float(1.0 / (1.0 - alpha) * np.log2((p ** alpha).sum()))


# ─── Hardness Amplification Computations ─────────────────────────────────

def hardness_amplification_params(
    single_instance_maxprob: float,
    target_security_bits: float
) -> dict:
    """
    Compute hardness amplification parameters.
    
    Given:
    - δ = single-instance guessing probability
    - s = target security level in bits
    
    Computes:
    - m = number of independent instances needed
    - k = single-instance min-entropy
    - joint min-entropy = m·k
    - joint guessing probability ≤ δ^m
    
    Algorithm:
        m = ceil(s / (-log₂(δ)))
    
    Time complexity: O(1)
    """
    delta = single_instance_maxprob
    k = -np.log2(delta)  # single-instance min-entropy
    
    m = int(np.ceil(target_security_bits / k))
    
    return {
        'single_maxprob': delta,
        'single_min_entropy': k,
        'instances_needed': m,
        'joint_min_entropy': m * k,
        'joint_maxprob_bound': delta ** m,
        'target_security_bits': target_security_bits,
        'achieved_security_bits': m * k,
    }


def leftover_hash_error(
    source_min_entropy: float,
    output_bits: int,
    source_size_bits: float
) -> float:
    """
    Compute the leftover hash lemma extraction error.
    
    For a source with min-entropy H∞ and a universal hash family
    extracting ℓ output bits:
    
    ε ≤ 2^(-(H∞ - ℓ)/2)
    
    This is the statistical distance from uniform.
    
    Args:
        source_min_entropy: H∞ of the source in bits
        output_bits: number of bits to extract
        source_size_bits: log₂ of the source alphabet size
    
    Returns:
        Upper bound on extraction error (statistical distance)
    """
    if source_min_entropy <= output_bits:
        return 1.0  # Cannot extract more than min-entropy
    
    entropy_slack = source_min_entropy - output_bits
    return 2.0 ** (-entropy_slack / 2.0)


def amplified_extraction_params(
    single_instance_maxprob: float,
    single_alphabet_size: int,
    num_instances: int,
    output_bits: int
) -> dict:
    """
    Compute extraction parameters after hardness amplification.
    
    Given m independent tropical action instances, each with:
    - alphabet size |β|
    - max probability δ
    
    The joint source has:
    - alphabet size |β|^m
    - min-entropy ≥ m · (-log₂(δ))
    
    Extraction with universal hashing:
    - error ≤ 2^(-(m·k - ℓ)/2)
    
    Returns dict with all computed parameters.
    """
    delta = single_instance_maxprob
    k = -np.log2(delta)
    
    joint_min_entropy = num_instances * k
    joint_alphabet_bits = num_instances * np.log2(single_alphabet_size)
    
    error = leftover_hash_error(joint_min_entropy, output_bits, joint_alphabet_bits)
    
    return {
        'num_instances': num_instances,
        'single_min_entropy': k,
        'joint_min_entropy': joint_min_entropy,
        'joint_alphabet_bits': joint_alphabet_bits,
        'output_bits': output_bits,
        'extraction_error': error,
        'error_exponent': -np.log2(error) if error > 0 and error < 1 else float('inf'),
    }


# ─── Entropy Accumulation ────────────────────────────────────────────────

def entropy_accumulation(
    distributions: List[np.ndarray]
) -> dict:
    """
    Compute entropy accumulation for a sequence of independent sources.
    
    Verifies:
    1. Min-entropy additivity: H∞(joint) = Σ H∞(X_i)
    2. Collision probability multiplicativity: Cp(joint) = ∏ Cp(X_i)
    3. Guessing probability multiplicativity: maxProb(joint) = ∏ maxProb(X_i)
    
    Returns detailed analysis dict.
    """
    m = len(distributions)
    
    individual_maxprob = [max_probability(p) for p in distributions]
    individual_min_entropy = [min_entropy_bits(p) for p in distributions]
    individual_collision = [collision_probability(p) for p in distributions]
    
    product_maxprob = np.prod(individual_maxprob)
    sum_min_entropy = sum(individual_min_entropy)
    product_collision = np.prod(individual_collision)
    
    return {
        'num_sources': m,
        'individual_maxprob': individual_maxprob,
        'individual_min_entropy': individual_min_entropy,
        'individual_collision_prob': individual_collision,
        'joint_maxprob': product_maxprob,
        'joint_min_entropy': sum_min_entropy,
        'joint_collision_prob': product_collision,
        'min_single_entropy': min(individual_min_entropy),
        'entropy_lower_bound': m * min(individual_min_entropy),
    }


if __name__ == "__main__":
    print("=" * 60)
    print("HARDNESS AMPLIFICATION PARAMETER CALCULATOR")
    print("=" * 60)
    
    # Example: tropical action with maxProb = 0.3 on alphabet of size 8
    params = hardness_amplification_params(
        single_instance_maxprob=0.3,
        target_security_bits=128
    )
    
    print(f"\nSingle instance: maxProb = {params['single_maxprob']}")
    print(f"Single instance: min-entropy = {params['single_min_entropy']:.2f} bits")
    print(f"Target security: {params['target_security_bits']} bits")
    print(f"Instances needed: {params['instances_needed']}")
    print(f"Achieved security: {params['achieved_security_bits']:.2f} bits")
    print(f"Joint guessing prob: ≤ {params['joint_maxprob_bound']:.2e}")
    
    print("\n" + "=" * 60)
    print("EXTRACTION AFTER AMPLIFICATION")
    print("=" * 60)
    
    for m in [10, 20, 50, 100]:
        ext = amplified_extraction_params(
            single_instance_maxprob=0.3,
            single_alphabet_size=8,
            num_instances=m,
            output_bits=int(m * 0.5)  # extract half the entropy
        )
        print(f"\nm={m}: joint H∞={ext['joint_min_entropy']:.1f} bits, "
              f"extract {ext['output_bits']} bits, "
              f"error ≤ {ext['extraction_error']:.2e}")
    
    print("\n" + "=" * 60)
    print("TROPICAL MATRIX POWER EXAMPLE")
    print("=" * 60)
    
    np.random.seed(42)
    n = 4
    G = np.random.exponential(2.0, (n, n))
    
    dists = []
    for t in [3, 5, 7, 11]:
        p = tropical_action_distribution(G, t, row=0, beta=1.0)
        dists.append(p)
        print(f"t={t:>2}: H∞ = {min_entropy_bits(p):.4f} bits, maxProb = {max_probability(p):.4f}")
    
    acc = entropy_accumulation(dists)
    print(f"\nJoint min-entropy: {acc['joint_min_entropy']:.4f} bits")
    print(f"Lower bound (m·k_min): {acc['entropy_lower_bound']:.4f} bits")
    print(f"Joint collision prob: {acc['joint_collision_prob']:.6e}")
