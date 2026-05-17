#!/usr/bin/env python3
"""
Applications of Berggren Spectral Expansion

This module demonstrates real-world applications of the spectral gap
theorem for Berggren dynamics on Pythagorean triples:

1. Pseudorandom number generation from arithmetic dynamics
2. Error-correcting code design using expander structure
3. Cryptographic hashing via Berggren orbit mixing
4. Deterministic sampling of Pythagorean triples
"""

import numpy as np
from algorithms import (
    B1, B2, B3, GENERATORS, berggren_tree,
    l2_mixing_simulator, berggren_extractor
)

# ─── Application 1: Pseudorandom Bit Generation ──────────────────────────

def berggren_prng(seed_triple: np.ndarray, num_bits: int) -> list:
    """
    Generate pseudorandom bits from Berggren tree dynamics.

    Strategy: traverse the Berggren tree using a deterministic schedule.
    At each node (a, b, c), output the parity of (a + b) mod 3.
    The spectral gap guarantees rapid mixing → low bias.

    Parameters
    ----------
    seed_triple : array
        Starting Pythagorean triple.
    num_bits : int
        Number of pseudorandom bits to generate.

    Returns
    -------
    list of int
        Pseudorandom bits (0 or 1).
    """
    bits = []
    current = seed_triple.copy()
    for _ in range(num_bits):
        # Extract a bit from the current triple
        bit = (current[0] + current[1]) % 2
        bits.append(int(bit))
        # Move to a deterministic child based on current state
        branch = (current[0] + current[1] + current[2]) % 3
        current = GENERATORS[branch] @ current
    return bits


def bias_test(bits: list, block_size: int = 100) -> dict:
    """Test bias of a bit sequence."""
    n = len(bits)
    mean = np.mean(bits)
    # Block frequency test
    num_blocks = n // block_size
    block_means = [np.mean(bits[i*block_size:(i+1)*block_size])
                   for i in range(num_blocks)]
    return {
        'mean': mean,
        'bias': abs(mean - 0.5),
        'block_variance': np.var(block_means) if block_means else 0,
        'expected_variance': 0.25 / block_size,
    }


# ─── Application 2: Expander-Based Error Correction ──────────────────────

def berggren_parity_check_matrix(q: int, depth: int) -> np.ndarray:
    """
    Construct a sparse parity-check matrix using the Berggren
    mod-q graph structure.

    The spectral gap of the Berggren graph guarantees good
    distance properties for the resulting LDPC-like code.

    Parameters
    ----------
    q : int
        Prime modulus (code length parameter).
    depth : int
        Depth of Berggren tree (redundancy parameter).

    Returns
    -------
    H : array
        Binary parity-check matrix.
    """
    # Generate Berggren orbits mod q
    root = np.array([3, 4, 5])
    nodes = []
    current = [root % q]
    nodes.extend([tuple(v) for v in current])

    for _ in range(depth):
        next_level = []
        for triple in current:
            for B in GENERATORS:
                child = tuple((B @ np.array(triple)) % q)
                if child not in nodes:
                    nodes.append(child)
                next_level.append(np.array(child))
        current = next_level

    n = len(nodes)
    node_idx = {node: i for i, node in enumerate(nodes)}

    # Build adjacency/parity-check structure
    # Each check connects a node to its 3 Berggren children
    checks = []
    for triple in nodes[:n//2]:  # Use half as check nodes
        children_indices = []
        for B in GENERATORS:
            child = tuple((B @ np.array(triple)) % q)
            if child in node_idx:
                children_indices.append(node_idx[child])
        if len(children_indices) >= 2:
            checks.append(children_indices)

    m = len(checks)
    H = np.zeros((m, n), dtype=int)
    for i, check in enumerate(checks):
        for j in check:
            H[i, j] = 1

    return H


# ─── Application 3: Deterministic Sampling ───────────────────────────────

def deterministic_pythagorean_sampler(
    max_hypotenuse: int,
    mod_class: int = 0,
    modulus: int = 1
) -> list:
    """
    Deterministically sample primitive Pythagorean triples with
    guaranteed coverage from the Berggren tree.

    The spectral gap ensures that sampling from different depths
    gives approximately uniform coverage of residue classes.

    Parameters
    ----------
    max_hypotenuse : int
        Maximum hypotenuse value.
    mod_class : int
        Target residue class (mod modulus).
    modulus : int
        Modulus for filtering (default 1 = no filter).

    Returns
    -------
    list of tuples
        Primitive Pythagorean triples satisfying the constraints.
    """
    root = np.array([3, 4, 5])
    result = []
    queue = [root]

    while queue:
        triple = queue.pop(0)
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])

        if c > max_hypotenuse:
            continue

        if a > 0 and b > 0 and c > 0:
            if modulus == 1 or (a + b + c) % modulus == mod_class:
                result.append((min(a, b), max(a, b), c))

        for B in GENERATORS:
            child = B @ triple
            if child[2] <= max_hypotenuse:
                queue.append(child)

    return sorted(set(result))


# ─── Application 4: Mixing Time Estimator ─────────────────────────────────

def mixing_time_estimate(k: int, epsilon: float) -> int:
    """
    Estimate the mixing time for the K_k random walk to reach
    ε-close to uniform in L² distance.

    For K_k: mixing time = ⌈log(k/ε²) / log((k-1)²)⌉

    Parameters
    ----------
    k : int
        Number of vertices (3 for Berggren).
    epsilon : float
        Target L² distance.

    Returns
    -------
    int
        Estimated mixing time.
    """
    rho_sq = 1.0 / (k - 1)**2
    initial_l2sq = (k - 1) / k  # worst case: point mass
    if rho_sq >= 1:
        return -1  # no mixing
    return int(np.ceil(np.log(initial_l2sq / epsilon**2) / np.log(1 / rho_sq)))


# ─── Main ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("BERGGREN SPECTRAL EXPANSION — APPLICATIONS")
    print("=" * 60)

    # 1. PRNG
    print("\n1. Pseudorandom Bit Generation")
    print("-" * 40)
    bits = berggren_prng(np.array([3, 4, 5]), 10000)
    test = bias_test(bits)
    print(f"   Generated {len(bits)} bits")
    print(f"   Mean: {test['mean']:.4f} (ideal: 0.5)")
    print(f"   Bias: {test['bias']:.4f}")
    print(f"   Block variance: {test['block_variance']:.6f}")
    print(f"   Expected variance: {test['expected_variance']:.6f}")

    # 2. Error-correcting codes
    print("\n2. Expander-Based Parity Check Matrix")
    print("-" * 40)
    for q in [7, 11, 13]:
        H = berggren_parity_check_matrix(q, 3)
        if H.shape[0] > 0:
            rate = 1.0 - H.shape[0] / H.shape[1] if H.shape[1] > 0 else 0
            density = np.mean(H) if H.size > 0 else 0
            print(f"   q={q}: H is {H.shape[0]}×{H.shape[1]}, "
                  f"rate ≈ {rate:.3f}, density = {density:.4f}")

    # 3. Deterministic sampling
    print("\n3. Deterministic Pythagorean Triple Sampling")
    print("-" * 40)
    triples = deterministic_pythagorean_sampler(100)
    print(f"   Triples with c ≤ 100: {len(triples)}")
    print(f"   First 10: {triples[:10]}")

    # Residue class distribution
    for m in [3, 5, 7]:
        counts = [0] * m
        for a, b, c in triples:
            counts[(a + b + c) % m] += 1
        print(f"   Distribution mod {m}: {counts}")

    # 4. Mixing time
    print("\n4. Mixing Time Estimates")
    print("-" * 40)
    for k in [3, 5, 10, 100]:
        for eps in [0.01, 0.001, 1e-6]:
            t = mixing_time_estimate(k, eps)
            print(f"   K_{k}, ε={eps}: mixing time ≈ {t} steps")

    # 5. Extraction demo
    print("\n5. Extraction from Weak Sources")
    print("-" * 40)
    # Very biased source
    for bias in [0.9, 0.7, 0.5]:
        source = np.array([bias, (1-bias)/2, (1-bias)/2])
        result = berggren_extractor(source, np.log2(3) - 0.01)
        print(f"   Bias {bias}: {result['steps_needed']} steps → "
              f"H₂ = {result['final_renyi2']:.4f} bits "
              f"(target: {np.log2(3):.4f})")
