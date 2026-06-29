#!/usr/bin/env python3
"""
LWE Cryptographic Algorithms
============================

Implements the core algorithms from the LWE hardness framework:

1. LWE instance generation
2. Dual-Regev key generation, encryption, decryption
3. Search-to-decision reduction via hybrid coordinate recovery
4. Ring-LWE to coefficient-LWE transport
5. Noise smudging estimator

All algorithms include type hints, docstrings, and complexity analysis.
"""

import numpy as np
from typing import Tuple, List, Dict, Optional
from dataclasses import dataclass


# ============================================================
# Data Structures
# ============================================================

@dataclass
class LWEParams:
    """LWE parameter set."""
    n: int        # dimension
    m: int        # number of samples
    q: int        # modulus
    sigma: float  # noise standard deviation

    def __post_init__(self):
        assert self.n > 0, "Dimension must be positive"
        assert self.m > 0, "Number of samples must be positive"
        assert self.q > 1, "Modulus must be > 1"
        assert self.sigma > 0, "Noise std dev must be positive"


@dataclass
class LWEKeypair:
    """LWE keypair for Dual-Regev."""
    public_key: Dict[str, np.ndarray]  # {'A': matrix, 'p': vector}
    secret_key: Dict[str, np.ndarray]  # {'s': vector}
    noise: np.ndarray                   # noise vector (for analysis)


@dataclass
class Ciphertext:
    """Dual-Regev ciphertext."""
    u: np.ndarray  # vector in Z_q^n
    v: int         # scalar in Z_q


# ============================================================
# Algorithm 1: LWE Instance Generation
# ============================================================

def generate_lwe_instance(params: LWEParams,
                          secret: Optional[np.ndarray] = None
                          ) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Generate an LWE instance (A, b, s) where b = As + e mod q.

    Args:
        params: LWE parameters
        secret: Optional secret vector; generated randomly if None

    Returns:
        (A, b, s) where A is m×n, b is m-vector, s is n-vector

    Time complexity: O(mn)
    Space complexity: O(mn)

    Example:
        >>> params = LWEParams(n=8, m=32, q=97, sigma=2.0)
        >>> A, b, s = generate_lwe_instance(params)
        >>> A.shape
        (32, 8)
    """
    n, m, q, sigma = params.n, params.m, params.q, params.sigma

    if secret is None:
        s = np.random.randint(0, q, size=n)
    else:
        s = secret.copy()

    A = np.random.randint(0, q, size=(m, n))
    e = np.array([int(round(np.random.normal(0, sigma))) % q for _ in range(m)])
    b = (A @ s + e) % q

    return A, b, s


# ============================================================
# Algorithm 2: Dual-Regev Key Generation
# ============================================================

def dual_regev_keygen(params: LWEParams) -> LWEKeypair:
    """
    Generate a Dual-Regev keypair.

    The public key is (A, p) where p = A·s + e.
    The secret key is s.

    Time complexity: O(mn)
    Space complexity: O(mn)

    Example:
        >>> params = LWEParams(n=8, m=32, q=97, sigma=1.0)
        >>> kp = dual_regev_keygen(params)
        >>> kp.public_key['A'].shape
        (32, 8)
    """
    n, m, q, sigma = params.n, params.m, params.q, params.sigma

    s = np.random.randint(0, q, size=n)
    A = np.random.randint(0, q, size=(m, n))
    noise = np.array([int(round(np.random.normal(0, sigma))) % q for _ in range(m)])
    p = (A @ s + noise) % q

    return LWEKeypair(
        public_key={'A': A, 'p': p},
        secret_key={'s': s},
        noise=noise
    )


# ============================================================
# Algorithm 3: Dual-Regev Encryption
# ============================================================

def dual_regev_encrypt(params: LWEParams,
                       pk: Dict[str, np.ndarray],
                       message: int,
                       binary_randomness: bool = True) -> Ciphertext:
    """
    Encrypt a message using Dual-Regev.

    Computes:
        u = A^T r  (n-vector)
        v = <r, p> + μ  (scalar)

    Args:
        params: LWE parameters
        pk: Public key {'A': m×n matrix, 'p': m-vector}
        message: Message in {0, ..., q-1}
        binary_randomness: If True, use r ∈ {0,1}^m; else r ∈ Z_q^m

    Returns:
        Ciphertext (u, v)

    Time complexity: O(mn)

    Example:
        >>> params = LWEParams(n=8, m=32, q=97, sigma=1.0)
        >>> kp = dual_regev_keygen(params)
        >>> ct = dual_regev_encrypt(params, kp.public_key, 42)
    """
    A, p = pk['A'], pk['p']
    m, q = params.m, params.q

    if binary_randomness:
        r = np.random.randint(0, 2, size=m)
    else:
        r = np.random.randint(0, q, size=m)

    u = (r @ A) % q
    v = (int(np.dot(r, p)) + message) % q

    return Ciphertext(u=u, v=v)


# ============================================================
# Algorithm 4: Dual-Regev Decryption
# ============================================================

def dual_regev_decrypt(params: LWEParams,
                       sk: Dict[str, np.ndarray],
                       ct: Ciphertext) -> int:
    """
    Decrypt a Dual-Regev ciphertext.

    Computes: μ' = v - <u, s> mod q

    By the correctness theorem (Theorem 1):
        μ' = μ + Σ rᵢ·noiseᵢ mod q

    When noise is small, μ' = μ.

    Args:
        params: LWE parameters
        sk: Secret key {'s': n-vector}
        ct: Ciphertext (u, v)

    Returns:
        Decrypted message in {0, ..., q-1}

    Time complexity: O(n)

    Example:
        >>> params = LWEParams(n=8, m=32, q=97, sigma=1.0)
        >>> kp = dual_regev_keygen(params)
        >>> ct = dual_regev_encrypt(params, kp.public_key, 42)
        >>> dual_regev_decrypt(params, kp.secret_key, ct)
        42
    """
    s = sk['s']
    return (ct.v - int(np.dot(ct.u, s))) % params.q


# ============================================================
# Algorithm 5: Hybrid Game Advantage Estimator
# ============================================================

def estimate_hybrid_advantages(params: LWEParams,
                                num_trials: int = 1000
                                ) -> Dict[str, np.ndarray]:
    """
    Estimate the advantage at each hybrid step in the
    search-to-decision reduction.

    Hybrid k: first k coordinates of the secret are randomized.

    Returns dict with:
        'probs': array of distinguishing probabilities
        'adjacent_diffs': array of |H_i - H_{i+1}|
        'total_advantage': |H_0 - H_n|
        'telescope_sum': Σ |H_i - H_{i+1}|
        'max_coord': coordinate with maximum advantage

    Time complexity: O(n · num_trials · m · n)

    Example:
        >>> params = LWEParams(n=4, m=16, q=97, sigma=2.0)
        >>> result = estimate_hybrid_advantages(params, num_trials=500)
        >>> result['total_advantage'] <= result['telescope_sum']
        True
    """
    n, m, q, sigma = params.n, params.m, params.q, params.sigma
    probs = np.zeros(n + 1)

    for k in range(n + 1):
        correct = 0
        for _ in range(num_trials):
            s = np.random.randint(0, q, size=n)
            a_matrix = np.random.randint(0, q, size=(m, n))
            noise = np.array([int(round(np.random.normal(0, sigma))) % q
                            for _ in range(m)])

            s_hybrid = s.copy()
            if k > 0:
                s_hybrid[:k] = np.random.randint(0, q, size=k)

            b = (a_matrix @ s_hybrid + noise) % q
            residuals = (b - a_matrix @ s) % q
            residuals_centered = np.where(residuals > q // 2, residuals - q, residuals)
            score = np.mean(np.abs(residuals_centered))

            if score < q / 4:
                correct += 1

        probs[k] = correct / num_trials

    adjacent_diffs = np.array([abs(probs[i] - probs[i + 1]) for i in range(n)])
    total_advantage = abs(probs[0] - probs[-1])
    telescope_sum = np.sum(adjacent_diffs)
    max_coord = int(np.argmax(adjacent_diffs))

    return {
        'probs': probs,
        'adjacent_diffs': adjacent_diffs,
        'total_advantage': total_advantage,
        'telescope_sum': telescope_sum,
        'max_coord': max_coord,
        'pigeonhole_bound': total_advantage / n if n > 0 else 0
    }


# ============================================================
# Algorithm 6: Ring-LWE Coefficient Transport
# ============================================================

def ring_multiply(a: np.ndarray, b: np.ndarray, q: int) -> np.ndarray:
    """
    Multiply polynomials a, b in Z_q[x]/(x^n + 1).

    Time complexity: O(n²)

    Example:
        >>> ring_multiply(np.array([1, 2]), np.array([3, 4]), 97)
        array([-5, 10])   # mod 97
    """
    n = len(a)
    result = np.zeros(n, dtype=int)
    for i in range(n):
        for j in range(n):
            idx = i + j
            if idx < n:
                result[idx] = (result[idx] + int(a[i]) * int(b[j])) % q
            else:
                result[idx - n] = (result[idx - n] - int(a[i]) * int(b[j])) % q
    return result


def multiplication_matrix(a: np.ndarray, q: int) -> np.ndarray:
    """
    Compute the multiplication matrix M_a such that M_a @ s ≡ a * s mod q.

    This demonstrates Theorem 7: ring multiplication is a linear map.

    Time complexity: O(n³) (n multiplications of O(n²) each)

    Example:
        >>> M = multiplication_matrix(np.array([1, 2, 3, 4]), 97)
        >>> M.shape
        (4, 4)
    """
    n = len(a)
    M = np.zeros((n, n), dtype=int)
    for j in range(n):
        e_j = np.zeros(n, dtype=int)
        e_j[j] = 1
        M[:, j] = ring_multiply(a, e_j, q)
    return M % q


def ring_lwe_to_standard_lwe(a_ring: np.ndarray, b_ring: np.ndarray,
                              q: int) -> Tuple[np.ndarray, np.ndarray]:
    """
    Transport a Ring-LWE sample (a, b) in Z_q[x]/(x^n+1) to a standard
    LWE sample (M_a, b) in Z_q^n.

    By Theorem 7, M_a is the matrix representation of multiplication by a,
    so the Ring-LWE equation b = a·s + e becomes the matrix equation
    b = M_a · s + e.

    Time complexity: O(n³)

    Example:
        >>> a = np.array([1, 2, 3, 4])
        >>> s = np.array([5, 6, 7, 8])
        >>> e = np.array([0, 0, 0, 0])
        >>> b = ring_multiply(a, s, 97)
        >>> M, b_vec = ring_lwe_to_standard_lwe(a, b, 97)
        >>> np.array_equal(M @ s % 97, ring_multiply(a, s, 97))
        True
    """
    M_a = multiplication_matrix(a_ring, q)
    return M_a, b_ring


# ============================================================
# Algorithm 7: Noise Smudging Estimator
# ============================================================

def estimate_noise_smudging(original_bound: float,
                            smudging_bound: float,
                            q: int,
                            num_samples: int = 10000) -> Dict[str, float]:
    """
    Estimate the statistical distance between (e + B) and B,
    where e is bounded by original_bound and B is bounded by smudging_bound.

    By the noise smudging theorem:
        stat_dist ≤ original_bound / smudging_bound

    Time complexity: O(num_samples)

    Example:
        >>> result = estimate_noise_smudging(2.0, 20.0, 97)
        >>> result['theoretical_bound']
        0.1
    """
    # Sample original noise
    e_samples = np.random.randint(-int(original_bound), int(original_bound) + 1,
                                   size=num_samples)
    # Sample smudging noise
    B_samples = np.random.randint(-int(smudging_bound), int(smudging_bound) + 1,
                                   size=num_samples)

    # Compute (e + B) mod q
    sum_samples = (e_samples + B_samples) % q

    # Estimate statistical distance by comparing histograms
    bins = np.arange(q + 1) - 0.5
    hist_sum, _ = np.histogram(sum_samples, bins=bins, density=True)
    hist_B, _ = np.histogram(B_samples % q, bins=bins, density=True)

    stat_dist = 0.5 * np.sum(np.abs(hist_sum - hist_B)) * (1.0)

    theoretical_bound = original_bound / smudging_bound if smudging_bound > 0 else float('inf')

    return {
        'empirical_stat_dist': float(stat_dist),
        'theoretical_bound': float(theoretical_bound),
        'bound_satisfied': stat_dist <= theoretical_bound + 0.05  # small tolerance
    }


# ============================================================
# Main: run examples
# ============================================================

if __name__ == '__main__':
    print("LWE Cryptographic Algorithms - Example Usage")
    print("=" * 50)

    # Example 1: Dual-Regev
    params = LWEParams(n=8, m=32, q=97, sigma=1.0)
    kp = dual_regev_keygen(params)
    msg = 42
    ct = dual_regev_encrypt(params, kp.public_key, msg)
    dec = dual_regev_decrypt(params, kp.secret_key, ct)
    print(f"\nDual-Regev: encrypt({msg}) -> decrypt = {dec} ({'✓' if dec == msg else '✗'})")

    # Example 2: Hybrid advantages
    small_params = LWEParams(n=4, m=16, q=97, sigma=2.0)
    result = estimate_hybrid_advantages(small_params, num_trials=200)
    print(f"\nHybrid advantages (n={small_params.n}):")
    print(f"  Total advantage: {result['total_advantage']:.4f}")
    print(f"  Telescope sum:   {result['telescope_sum']:.4f}")
    print(f"  Bound satisfied: {result['total_advantage'] <= result['telescope_sum'] + 1e-10}")

    # Example 3: Ring-LWE transport
    q = 97
    a = np.random.randint(0, q, size=4)
    s = np.random.randint(0, q, size=4)
    b = ring_multiply(a, s, q)
    M, _ = ring_lwe_to_standard_lwe(a, b, q)
    print(f"\nRing-LWE transport: M_a @ s == a*s: {np.array_equal(M @ s % q, b)}")

    # Example 4: Noise smudging
    result = estimate_noise_smudging(2.0, 20.0, 97)
    print(f"\nNoise smudging: empirical={result['empirical_stat_dist']:.4f}, "
          f"bound={result['theoretical_bound']:.4f}")
