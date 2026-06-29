#!/usr/bin/env python3
"""
Algorithms for Tropical ElGamal and FO-Transform Analysis

Implements:
1. Tropical ElGamal key generation, encryption, decryption
2. Spreadness verification (exhaustive and sampling-based)
3. Collision counting for fiber analysis
4. Entropy estimation for ciphertext distributions
5. FO-transform precondition checker
"""

import numpy as np
from typing import Tuple, List, Dict, Optional, Set
from collections import Counter
import math


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 1: Tropical ElGamal PKE
# ═══════════════════════════════════════════════════════════════════════════

class TropicalElGamal:
    """
    Min-Plus ElGamal Public Key Encryption Scheme.
    
    KeyGen: Choose g ∈ ℤⁿ, s ∈ ℤ, compute h = g + s.
    Enc(msg, r): c₁ = g + r, c₂ = msg + min(h + r).
    Dec(c₁, c₂): msg = c₂ - min(c₁ + s).
    
    Time complexity:
        KeyGen: O(n)
        Enc: O(n) 
        Dec: O(n)
    Space complexity: O(n) for keys and ciphertexts.
    """
    
    def __init__(self, n: int, g: Optional[np.ndarray] = None,
                 s: Optional[int] = None):
        """
        Initialize scheme with dimension n.
        
        Args:
            n: Dimension of key vectors (security parameter).
            g: Generator vector (randomly sampled if None).
            s: Secret key (randomly sampled if None).
        """
        self.n = n
        self.g = g if g is not None else np.random.randint(-100, 100, size=n)
        self.s = s if s is not None else np.random.randint(-50, 50)
        self.h = self.g + self.s
    
    def encrypt(self, msg: int, r: np.ndarray) -> Tuple[np.ndarray, int]:
        """Encrypt message with randomness vector r ∈ ℤⁿ."""
        c1 = self.g + r
        c2 = msg + int(np.min(self.h + r))
        return c1, c2
    
    def decrypt(self, c1: np.ndarray, c2: int) -> int:
        """Decrypt ciphertext (c₁, c₂) using secret key s."""
        return c2 - int(np.min(c1 + self.s))
    
    def verify_correctness(self, msg: int, r: np.ndarray) -> bool:
        """Verify Dec(Enc(msg, r)) = msg."""
        c1, c2 = self.encrypt(msg, r)
        return self.decrypt(c1, c2) == msg


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 2: Spreadness Verification
# ═══════════════════════════════════════════════════════════════════════════

def verify_spreadness_exhaustive(
    scheme: TropicalElGamal,
    msg: int,
    rand_range: int
) -> Dict:
    """
    Exhaustively verify γ-spreadness for bounded randomness.
    
    Enumerates all r ∈ {-R,...,R}ⁿ and checks that the encryption
    map is injective (no collisions).
    
    Args:
        scheme: TropicalElGamal instance.
        msg: Message to encrypt.
        rand_range: R such that r ∈ {-R,...,R}ⁿ.
        
    Returns:
        Dictionary with verification results.
        
    Time complexity: O((2R+1)ⁿ · n)
    Space complexity: O((2R+1)ⁿ)
    """
    from itertools import product
    
    n = scheme.n
    values = list(range(-rand_range, rand_range + 1))
    
    ciphertexts: Dict[Tuple, np.ndarray] = {}
    collisions = 0
    total = 0
    
    for r_tuple in product(values, repeat=n):
        r = np.array(r_tuple)
        c1, c2 = scheme.encrypt(msg, r)
        ct_key = (tuple(c1), c2)
        
        if ct_key in ciphertexts:
            collisions += 1
        else:
            ciphertexts[ct_key] = r
        total += 1
    
    rand_space_size = total
    image_size = len(ciphertexts)
    entropy = math.log(image_size) if image_size > 0 else 0
    
    return {
        "rand_space_size": rand_space_size,
        "image_size": image_size,
        "collisions": collisions,
        "is_injective": collisions == 0,
        "entropy_lower_bound": entropy,
        "spread_ratio": image_size / rand_space_size if rand_space_size > 0 else 0,
    }


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 3: Sampling-Based Spreadness Estimation
# ═══════════════════════════════════════════════════════════════════════════

def estimate_spreadness_sampling(
    scheme: TropicalElGamal,
    msg: int,
    num_samples: int = 10000,
    rand_bound: int = 1000
) -> Dict:
    """
    Estimate spreadness via random sampling.
    
    Samples random r vectors and counts distinct ciphertexts.
    For injective encryption, expects no collisions.
    
    Args:
        scheme: TropicalElGamal instance.
        msg: Message to encrypt.
        num_samples: Number of random samples.
        rand_bound: Range for randomness sampling.
        
    Returns:
        Dictionary with estimation results.
        
    Time complexity: O(num_samples · n)
    Space complexity: O(num_samples)
    """
    n = scheme.n
    ciphertexts: Set[Tuple] = set()
    
    for _ in range(num_samples):
        r = np.random.randint(-rand_bound, rand_bound + 1, size=n)
        c1, c2 = scheme.encrypt(msg, r)
        ciphertexts.add((tuple(c1), c2))
    
    image_size = len(ciphertexts)
    collision_rate = 1 - image_size / num_samples
    
    return {
        "num_samples": num_samples,
        "distinct_ciphertexts": image_size,
        "collision_rate": collision_rate,
        "estimated_entropy": math.log(image_size) if image_size > 0 else 0,
        "injective_evidence": collision_rate < 0.001,
    }


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 4: Fiber Analysis (Collision Counting)
# ═══════════════════════════════════════════════════════════════════════════

def analyze_fibers(
    scheme: TropicalElGamal,
    msg: int,
    rand_range: int
) -> Dict:
    """
    Analyze the fiber structure of the encryption map.
    
    For each ciphertext c in the image, compute |F_c| = |{r : Enc(r) = c}|.
    For injective encryption, all fibers have size 1.
    
    Args:
        scheme: TropicalElGamal instance.
        msg: Message to encrypt.
        rand_range: Range for exhaustive enumeration.
        
    Returns:
        Dictionary with fiber analysis.
        
    Time complexity: O((2R+1)ⁿ · n)
    """
    from itertools import product
    
    n = scheme.n
    values = list(range(-rand_range, rand_range + 1))
    
    fiber_sizes: Counter = Counter()
    
    for r_tuple in product(values, repeat=n):
        r = np.array(r_tuple)
        c1, c2 = scheme.encrypt(msg, r)
        ct_key = (tuple(c1), c2)
        fiber_sizes[ct_key] += 1
    
    sizes = list(fiber_sizes.values())
    
    return {
        "num_ciphertexts": len(fiber_sizes),
        "max_fiber_size": max(sizes),
        "min_fiber_size": min(sizes),
        "mean_fiber_size": np.mean(sizes),
        "all_singletons": all(s == 1 for s in sizes),
        "fiber_size_distribution": dict(Counter(sizes)),
    }


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 5: FO Precondition Checker
# ═══════════════════════════════════════════════════════════════════════════

def check_fo_preconditions(
    scheme: TropicalElGamal,
    num_correctness_tests: int = 100,
    num_injectivity_tests: int = 1000,
    spreadness_rand_range: int = 3
) -> Dict:
    """
    Check all three FO-transform preconditions:
    1. Correctness: Dec(Enc(msg, r)) = msg
    2. Injectivity: r₁ ≠ r₂ ⟹ Enc(msg, r₁) ≠ Enc(msg, r₂)
    3. γ-Spreadness: |Image| ≥ |Rand|
    
    Args:
        scheme: TropicalElGamal instance.
        num_correctness_tests: Number of correctness trials.
        num_injectivity_tests: Number of injectivity trials.
        spreadness_rand_range: Range for spreadness verification.
        
    Returns:
        Dictionary with all precondition results.
    """
    # 1. Correctness
    correctness_ok = True
    for _ in range(num_correctness_tests):
        msg = np.random.randint(-1000, 1000)
        r = np.random.randint(-100, 100, size=scheme.n)
        if not scheme.verify_correctness(msg, r):
            correctness_ok = False
            break
    
    # 2. Injectivity (sampling)
    inj_result = estimate_spreadness_sampling(
        scheme, msg=42, num_samples=num_injectivity_tests
    )
    
    # 3. Spreadness (exhaustive for small range)
    spread_result = verify_spreadness_exhaustive(
        scheme, msg=42, rand_range=spreadness_rand_range
    )
    
    return {
        "correctness": correctness_ok,
        "injectivity_evidence": inj_result["injective_evidence"],
        "spreadness_verified": spread_result["is_injective"],
        "entropy_lower_bound": spread_result["entropy_lower_bound"],
        "rand_space_size": spread_result["rand_space_size"],
        "image_size": spread_result["image_size"],
        "all_fo_preconditions_met": (
            correctness_ok and 
            inj_result["injective_evidence"] and 
            spread_result["is_injective"]
        ),
    }


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 6: Entropy Growth Analysis
# ═══════════════════════════════════════════════════════════════════════════

def entropy_growth_analysis(
    dimensions: List[int],
    rand_range: int = 2,
    msg: int = 0
) -> List[Dict]:
    """
    Analyze how ciphertext entropy grows with key dimension n.
    
    For each dimension n, computes the entropy lower bound
    γ = log|Image| and compares with log|Rand|.
    
    Args:
        dimensions: List of key dimensions to test.
        rand_range: Range for randomness vectors.
        msg: Message to encrypt.
        
    Returns:
        List of results for each dimension.
    """
    results = []
    
    for n in dimensions:
        scheme = TropicalElGamal(n)
        spread = verify_spreadness_exhaustive(scheme, msg, rand_range)
        
        rand_size = spread["rand_space_size"]
        image_size = spread["image_size"]
        
        results.append({
            "dimension": n,
            "rand_space_size": rand_size,
            "image_size": image_size,
            "log_rand": math.log(rand_size) if rand_size > 0 else 0,
            "log_image": math.log(image_size) if image_size > 0 else 0,
            "spread_ratio": image_size / rand_size if rand_size > 0 else 0,
            "is_perfectly_spread": image_size == rand_size,
        })
    
    return results


if __name__ == "__main__":
    print("Tropical ElGamal — Algorithm Demonstrations")
    print("=" * 60)
    
    # Basic scheme
    scheme = TropicalElGamal(n=3, g=np.array([2, -1, 5]), s=7)
    
    # Check FO preconditions
    print("\n1. FO Precondition Check:")
    result = check_fo_preconditions(scheme)
    for k, v in result.items():
        print(f"   {k}: {v}")
    
    # Fiber analysis
    print("\n2. Fiber Analysis (rand_range=2):")
    fibers = analyze_fibers(scheme, msg=42, rand_range=2)
    for k, v in fibers.items():
        print(f"   {k}: {v}")
    
    # Entropy growth
    print("\n3. Entropy Growth with Dimension:")
    growth = entropy_growth_analysis([1, 2, 3], rand_range=2)
    for r in growth:
        print(f"   n={r['dimension']}: |Rand|={r['rand_space_size']}, "
              f"|Image|={r['image_size']}, γ={r['log_image']:.3f}")
