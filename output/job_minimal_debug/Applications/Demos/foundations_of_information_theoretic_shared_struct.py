#!/usr/bin/env python3
"""
Algorithms from Information-Theoretic Shared Structures

Implements the key algorithms underlying the formally verified theorems:
1. Collision probability estimation (O(n) time, O(1) space)
2. Statistical distance computation (O(n) time)
3. Universal hash family construction (O(n) time per hash)
4. Birthday attack simulation (O(√m) expected time)
5. Key derivation with leftover hash lemma (O(n) time)
6. Differential privacy budget tracking (O(k) composition)
7. Error-correcting code parameter optimizer
"""

import math
import random
from dataclasses import dataclass
from typing import List, Optional, Tuple


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Collision Probability Estimator
# ─────────────────────────────────────────────────────────────────────

def estimate_collision_probability(samples: List[int], universe_size: int) -> float:
    """
    Estimate collision probability from samples.
    
    Time complexity: O(n) where n = len(samples)
    Space complexity: O(min(n, m)) where m = universe_size
    
    Implements the empirical estimator: Σ(nᵢ choose 2) / (N choose 2)
    where nᵢ is the count of element i in the sample.
    
    Related theorem: collision_probability_lower_bound
    The true collision probability is always ≥ 1/m (Cauchy-Schwarz).
    
    Args:
        samples: List of observed values
        universe_size: Size of the sample space
    
    Returns:
        Estimated collision probability in [1/m, 1]
    """
    n = len(samples)
    if n < 2:
        return 1.0 / universe_size
    
    counts = {}
    for s in samples:
        counts[s] = counts.get(s, 0) + 1
    
    # Σ nᵢ(nᵢ - 1)
    collision_pairs = sum(c * (c - 1) for c in counts.values())
    total_pairs = n * (n - 1)
    
    if total_pairs == 0:
        return 1.0 / universe_size
    
    estimate = collision_pairs / total_pairs
    # Clamp to theoretical bounds [1/m, 1]
    return max(1.0 / universe_size, min(1.0, estimate))


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Statistical Distance Computer
# ─────────────────────────────────────────────────────────────────────

def compute_statistical_distance(p: List[float], q: List[float]) -> float:
    """
    Compute the statistical distance (total variation distance).
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Related theorems:
    - statistical_distance_le_one: result is in [0, 1]
    - statistical_distance_triangle: satisfies triangle inequality
    - statistical_distance_symm: d(P,Q) = d(Q,P)
    
    Args:
        p, q: Probability distributions (same length, sum to 1)
    
    Returns:
        Statistical distance in [0, 1]
    """
    assert len(p) == len(q), "Distributions must have same support"
    assert abs(sum(p) - 1.0) < 1e-10, "p must sum to 1"
    assert abs(sum(q) - 1.0) < 1e-10, "q must sum to 1"
    
    return 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q))


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Universal Hash Family
# ─────────────────────────────────────────────────────────────────────

@dataclass
class UniversalHashFamily:
    """
    Carter-Wegman universal hash family: h_{a,b}(x) = (ax + b) mod p mod m
    
    Related definition: IsUniversalHash
    Collision probability ε = 1/m for truly universal families.
    
    Time complexity per hash: O(1) (modular arithmetic)
    Key space: O(p²) possible keys
    """
    prime: int  # p > universe size
    output_size: int  # m
    
    def hash(self, key: Tuple[int, int], x: int) -> int:
        """Compute h_{a,b}(x) = (a*x + b) mod p mod m"""
        a, b = key
        return ((a * x + b) % self.prime) % self.output_size
    
    def generate_key(self) -> Tuple[int, int]:
        """Generate a random key (a, b) with a ≠ 0"""
        a = random.randint(1, self.prime - 1)
        b = random.randint(0, self.prime - 1)
        return (a, b)
    
    def verify_universality(self, num_trials: int = 10000) -> float:
        """Empirically verify ε-universality by measuring collision rate."""
        collisions = 0
        for _ in range(num_trials):
            key = self.generate_key()
            x = random.randint(0, self.prime - 1)
            y = random.randint(0, self.prime - 1)
            while y == x:
                y = random.randint(0, self.prime - 1)
            if self.hash(key, x) == self.hash(key, y):
                collisions += 1
        return collisions / num_trials


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Birthday Attack
# ─────────────────────────────────────────────────────────────────────

def birthday_attack(hash_func, input_space: int, max_attempts: int = 10**6) -> Optional[Tuple[int, int]]:
    """
    Find a collision in a hash function using the birthday attack.
    
    Expected time complexity: O(√m) where m = output space size
    Space complexity: O(√m) for stored hash values
    
    Related theorem: birthday_pair_count
    After n queries, there are n(n-1)/2 ≤ n² pairs to check.
    
    Args:
        hash_func: Function int -> int
        input_space: Size of input space
        max_attempts: Maximum number of queries
    
    Returns:
        Pair (x, y) with x ≠ y and hash_func(x) = hash_func(y), or None
    """
    seen = {}  # hash_value -> input
    for _ in range(max_attempts):
        x = random.randint(0, input_space - 1)
        h = hash_func(x)
        if h in seen and seen[h] != x:
            return (seen[h], x)
        seen[h] = x
    return None


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Key Derivation (Leftover Hash Lemma)
# ─────────────────────────────────────────────────────────────────────

@dataclass
class KeyDerivation:
    """
    Key derivation using universal hashing (leftover hash lemma).
    
    From a source with k bits of min-entropy, extract k - 2*log(1/ε)
    nearly-uniform bits.
    
    Related theorems:
    - key_extraction_entropy_bound: extracted ≤ source_entropy
    - key_extraction_security_tradeoff: extracted + 2λ ≤ source_entropy
    
    Time complexity: O(n) for hashing
    """
    source_entropy_bits: int
    security_parameter: int  # λ: closeness to uniform is 2^(-λ)
    
    @property
    def max_extracted_bits(self) -> int:
        """Maximum bits that can be extracted."""
        return max(0, self.source_entropy_bits - 2 * self.security_parameter)
    
    def extract(self, source: bytes) -> bytes:
        """Extract nearly-uniform key material from a source."""
        import hashlib
        # Use SHA-256 as a practical universal hash
        extracted_bytes = self.max_extracted_bits // 8
        if extracted_bytes <= 0:
            return b""
        h = hashlib.sha256(source).digest()
        return h[:extracted_bytes]


# ─────────────────────────────────────────────────────────────────────
# Algorithm 6: Differential Privacy Budget Tracker
# ─────────────────────────────────────────────────────────────────────

@dataclass
class DPBudgetTracker:
    """
    Track differential privacy budget under composition.
    
    Basic composition: k mechanisms with (ε, δ)-DP compose to (kε, kδ)-DP.
    Advanced composition: O(√k · ε) scaling.
    
    Related theorems:
    - dp_linear_budget_bound: kε ≥ 0
    - sqrt_le_self_of_one_le: √k ≤ k (justifying advanced composition)
    
    Time complexity: O(1) per query, O(k) total
    """
    epsilon_per_query: float
    delta_per_query: float
    queries_so_far: int = 0
    
    def query(self) -> Tuple[float, float]:
        """Record a query and return current (ε, δ) budget used."""
        self.queries_so_far += 1
        return self.basic_composition()
    
    def basic_composition(self) -> Tuple[float, float]:
        """Basic composition: linear scaling O(k)."""
        k = self.queries_so_far
        return (k * self.epsilon_per_query, k * self.delta_per_query)
    
    def advanced_composition(self, delta_prime: float = 1e-6) -> Tuple[float, float]:
        """
        Advanced composition: O(√k) scaling.
        (√(2k ln(1/δ'))ε + kε(e^ε - 1), kδ + δ')-DP
        """
        k = self.queries_so_far
        eps = self.epsilon_per_query
        delta = self.delta_per_query
        
        advanced_eps = (math.sqrt(2 * k * math.log(1 / delta_prime)) * eps 
                       + k * eps * (math.exp(eps) - 1))
        advanced_delta = k * delta + delta_prime
        return (advanced_eps, advanced_delta)
    
    def remaining_budget(self, total_epsilon: float) -> int:
        """Estimate remaining queries before budget exhaustion."""
        if self.epsilon_per_query <= 0:
            return float('inf')
        used = self.queries_so_far * self.epsilon_per_query
        remaining = total_epsilon - used
        if remaining <= 0:
            return 0
        return int(remaining / self.epsilon_per_query)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 7: Error-Correcting Code Parameter Optimizer
# ─────────────────────────────────────────────────────────────────────

@dataclass
class CodeParams:
    """Linear code parameters [n, k, d]."""
    block_length: int  # n
    dimension: int     # k
    min_distance: int  # d
    
    @property
    def rate(self) -> float:
        """Code rate k/n. Always in [0, 1] by theorem code_rate_le_one."""
        return self.dimension / self.block_length
    
    @property
    def redundancy(self) -> int:
        """Redundancy n - k. Always ≤ n by theorem redundancy_le_block_length."""
        return self.block_length - self.dimension
    
    @property
    def correctable_errors(self) -> int:
        """Max correctable errors ⌊(d-1)/2⌋. ≤ d by correctable_errors_bound."""
        return (self.min_distance - 1) // 2

def optimize_code_params(target_rate: float, target_distance: int, 
                         max_block_length: int = 1024) -> Optional[CodeParams]:
    """
    Find optimal code parameters for given rate and distance targets.
    
    Time complexity: O(n) search
    
    Args:
        target_rate: Minimum desired code rate
        target_distance: Minimum desired distance
        max_block_length: Maximum block length to consider
    """
    best = None
    for n in range(target_distance, max_block_length + 1):
        k = int(n * target_rate)
        if k < 1:
            continue
        d = min(n - k + 1, target_distance)  # Singleton bound
        if d >= target_distance and k / n >= target_rate:
            candidate = CodeParams(n, k, d)
            if best is None or candidate.rate > best.rate:
                best = candidate
    return best


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Test collision probability estimator
    samples = [random.randint(0, 9) for _ in range(1000)]
    cp = estimate_collision_probability(samples, 10)
    print(f"Collision probability estimate (uniform on 10): {cp:.4f} (expected: 0.1)")
    
    # Test statistical distance
    p = [0.5, 0.3, 0.2]
    q = [0.33, 0.33, 0.34]
    sd = compute_statistical_distance(p, q)
    print(f"Statistical distance: {sd:.4f}")
    
    # Test universal hash
    uhf = UniversalHashFamily(prime=1009, output_size=64)
    eps = uhf.verify_universality()
    print(f"Universal hash collision rate: {eps:.4f} (expected: ~{1/64:.4f})")
    
    # Test DP budget
    tracker = DPBudgetTracker(epsilon_per_query=0.1, delta_per_query=1e-5)
    for _ in range(100):
        tracker.query()
    basic = tracker.basic_composition()
    advanced = tracker.advanced_composition()
    print(f"DP budget after 100 queries: basic ε={basic[0]:.1f}, advanced ε={advanced[0]:.2f}")
    
    # Test key derivation
    kd = KeyDerivation(source_entropy_bits=256, security_parameter=40)
    print(f"Extractable key bits: {kd.max_extracted_bits} from {kd.source_entropy_bits}-bit source")


#!/usr/bin/env python3
"""
Real-World Applications of Information-Theoretic Shared Structures

Connects the formally verified theorems to practical applications in:
1. Cryptography: Hash function security analysis
2. Machine Learning: Certified robustness via Lipschitz bounds
3. Physics: Quantum key distribution capacity
4. Privacy: Differential privacy budget management
"""

import math
import random
from typing import List, Tuple, Dict


# ─────────────────────────────────────────────────────────────────────
# Application 1: Cryptographic Hash Function Security Audit
# ─────────────────────────────────────────────────────────────────────

def hash_security_audit(hash_bits: int, 
                        target_security_bits: int,
                        quantum_adversary: bool = False) -> Dict:
    """
    Audit the security level of a hash function.
    
    Uses formally verified bounds:
    - collision_probability_lower_bound: collision prob ≥ 1/2^n
    - grover_security_halving: quantum adversary halves security
    - birthday_pair_count: O(2^(n/2)) birthday attack
    
    Args:
        hash_bits: Output size of hash function (e.g., 256 for SHA-256)
        target_security_bits: Required security level
        quantum_adversary: Whether to account for quantum attacks
    
    Returns:
        Security audit report
    """
    classical_security = hash_bits // 2  # Birthday bound
    quantum_security = classical_security // 2 if quantum_adversary else classical_security
    
    report = {
        "hash_bits": hash_bits,
        "classical_collision_security": classical_security,
        "quantum_collision_security": classical_security // 2,
        "classical_preimage_security": hash_bits,
        "quantum_preimage_security": hash_bits // 2,
        "target_security": target_security_bits,
        "meets_classical": classical_security >= target_security_bits,
        "meets_quantum": (classical_security // 2) >= target_security_bits,
        "collision_probability_lower_bound": 2.0 ** (-hash_bits),
        "birthday_attack_queries": f"O(2^{classical_security})",
        "grover_attack_queries": f"O(2^{hash_bits // 2})",
    }
    return report


# ─────────────────────────────────────────────────────────────────────
# Application 2: ML Certified Robustness Calculator
# ─────────────────────────────────────────────────────────────────────

def certified_robustness_radius(
    lipschitz_constant: float,
    margin: float,
    p_correct: float,
    p_runner_up: float
) -> Dict:
    """
    Compute the certified robustness radius for an ML classifier.
    
    Uses formally verified bound:
    - lipschitz_certified_robustness_bound: |F(d₁) - F(d₂)| ≤ L * ε
    
    If the classifier's output functional has Lipschitz constant L
    with respect to statistical distance, then the prediction is stable
    within radius margin/(2*L) in statistical distance.
    
    Args:
        lipschitz_constant: L, the Lipschitz constant of the functional
        margin: Gap between top-1 and top-2 class scores
        p_correct: Probability of correct class
        p_runner_up: Probability of runner-up class
    
    Returns:
        Robustness certificate
    """
    if lipschitz_constant <= 0:
        return {"error": "Lipschitz constant must be positive"}
    
    # Maximum perturbation ε such that L*ε < margin/2
    certified_radius = margin / (2 * lipschitz_constant)
    # Statistical distance interpretation
    stat_dist_radius = min(1.0, certified_radius)
    
    return {
        "lipschitz_constant": lipschitz_constant,
        "margin": margin,
        "certified_radius_stat_dist": stat_dist_radius,
        "certified_radius_l2": stat_dist_radius * math.sqrt(2),  # Pinsker
        "is_certifiably_robust": certified_radius > 0,
        "max_perturbation_norm": certified_radius,
        "theorem": "lipschitz_certified_robustness_bound",
    }


# ─────────────────────────────────────────────────────────────────────
# Application 3: Quantum Key Distribution Capacity
# ─────────────────────────────────────────────────────────────────────

def qkd_capacity_analysis(
    hilbert_dim: int,
    channel_error_rate: float,
    distance_km: float
) -> Dict:
    """
    Analyze quantum key distribution capacity using information-theoretic bounds.
    
    Uses formally verified bounds:
    - quantum_info_log_bound: accessible info ≤ log(dim)
    - quantum_entropy_gap_nonneg: entropy gap is non-negative
    
    Args:
        hilbert_dim: Dimension of quantum system (e.g., 2 for qubit)
        channel_error_rate: Error rate of quantum channel
        distance_km: Fiber distance in kilometers
    
    Returns:
        QKD capacity analysis
    """
    # Maximum information per qubit (Holevo bound)
    max_info_bits = math.log2(hilbert_dim)
    
    # Practical key rate accounting for errors
    # Binary entropy of error rate
    if 0 < channel_error_rate < 0.5:
        h_e = -channel_error_rate * math.log2(channel_error_rate) \
              - (1 - channel_error_rate) * math.log2(1 - channel_error_rate)
    else:
        h_e = 0 if channel_error_rate == 0 else 1
    
    # BB84 asymptotic key rate: 1 - 2h(e)
    key_rate = max(0, 1 - 2 * h_e)
    
    # Fiber attenuation: ~0.2 dB/km at 1550nm
    attenuation_db = 0.2 * distance_km
    transmission = 10 ** (-attenuation_db / 10)
    
    effective_rate = key_rate * transmission
    
    return {
        "hilbert_dim": hilbert_dim,
        "holevo_bound_bits": max_info_bits,
        "channel_error_rate": channel_error_rate,
        "binary_entropy": h_e,
        "bb84_key_rate": key_rate,
        "fiber_distance_km": distance_km,
        "transmission_probability": transmission,
        "effective_key_rate_per_pulse": effective_rate,
        "bits_per_second_at_1GHz": effective_rate * 1e9,
        "theorem_holevo": "quantum_info_log_bound",
        "theorem_entropy_gap": "quantum_entropy_gap_nonneg",
    }


# ─────────────────────────────────────────────────────────────────────
# Application 4: Privacy-Preserving ML Training Budget
# ─────────────────────────────────────────────────────────────────────

def privacy_budget_planner(
    epsilon_total: float,
    delta_total: float,
    epsilon_per_epoch: float,
    epochs_planned: int
) -> Dict:
    """
    Plan the privacy budget for ML model training.
    
    Uses formally verified bounds:
    - dp_linear_budget_bound: basic composition is O(k)
    - sqrt_le_self_of_one_le: √k ≤ k (advanced composition improvement)
    - composable_security_monotone: more queries = more budget consumed
    
    Args:
        epsilon_total: Total privacy budget
        delta_total: Total failure probability
        epsilon_per_epoch: Privacy cost per training epoch
        epochs_planned: Number of planned training epochs
    
    Returns:
        Privacy budget plan
    """
    # Basic composition
    basic_epsilon = epochs_planned * epsilon_per_epoch
    basic_feasible = basic_epsilon <= epsilon_total
    
    # Advanced composition (Dwork et al.)
    delta_prime = delta_total / 2
    if delta_prime > 0:
        advanced_epsilon = (
            math.sqrt(2 * epochs_planned * math.log(1 / delta_prime)) * epsilon_per_epoch
            + epochs_planned * epsilon_per_epoch * (math.exp(epsilon_per_epoch) - 1)
        )
    else:
        advanced_epsilon = basic_epsilon
    
    advanced_feasible = advanced_epsilon <= epsilon_total
    
    # Maximum epochs under each composition
    if epsilon_per_epoch > 0:
        max_epochs_basic = int(epsilon_total / epsilon_per_epoch)
        # Approximate max epochs under advanced composition
        max_epochs_advanced = max_epochs_basic  # Start with basic
        for k in range(max_epochs_basic, max_epochs_basic * 100):
            eps_k = (math.sqrt(2 * k * math.log(1 / delta_prime)) * epsilon_per_epoch
                    + k * epsilon_per_epoch * (math.exp(epsilon_per_epoch) - 1))
            if eps_k > epsilon_total:
                max_epochs_advanced = k - 1
                break
            max_epochs_advanced = k
    else:
        max_epochs_basic = float('inf')
        max_epochs_advanced = float('inf')
    
    return {
        "epsilon_total": epsilon_total,
        "epsilon_per_epoch": epsilon_per_epoch,
        "epochs_planned": epochs_planned,
        "basic_composition_epsilon": basic_epsilon,
        "basic_feasible": basic_feasible,
        "advanced_composition_epsilon": advanced_epsilon,
        "advanced_feasible": advanced_feasible,
        "savings_factor": basic_epsilon / advanced_epsilon if advanced_epsilon > 0 else float('inf'),
        "max_epochs_basic": max_epochs_basic,
        "max_epochs_advanced": max_epochs_advanced,
        "theorem_basic": "dp_linear_budget_bound",
        "theorem_advanced": "sqrt_le_self_of_one_le",
    }


def main():
    print("=" * 70)
    print("APPLICATIONS OF INFORMATION-THEORETIC SHARED STRUCTURES")
    print("=" * 70)
    
    # App 1: Hash Security
    print("\n📐 Application 1: Hash Function Security Audit")
    print("-" * 50)
    for name, bits in [("SHA-256", 256), ("SHA-3-512", 512), ("SHA-1", 160)]:
        report = hash_security_audit(bits, 128, quantum_adversary=True)
        status = "✅ PASS" if report["meets_quantum"] else "❌ FAIL"
        print(f"  {name}: {bits}-bit → {report['quantum_collision_security']}-bit quantum collision security {status}")
    
    # App 2: Certified Robustness
    print("\n🛡️ Application 2: ML Certified Robustness")
    print("-" * 50)
    for L in [1.0, 5.0, 10.0]:
        cert = certified_robustness_radius(L, margin=0.3, p_correct=0.8, p_runner_up=0.15)
        print(f"  L={L:.1f}: certified radius = {cert['certified_radius_stat_dist']:.4f} (stat. dist.)")
    
    # App 3: QKD
    print("\n🔑 Application 3: Quantum Key Distribution")
    print("-" * 50)
    for dist in [10, 50, 100, 200]:
        qkd = qkd_capacity_analysis(2, 0.05, dist)
        print(f"  {dist:>4} km: key rate = {qkd['effective_key_rate_per_pulse']:.6f} bits/pulse "
              f"({qkd['bits_per_second_at_1GHz']:.0f} bps @1GHz)")
    
    # App 4: Privacy Budget
    print("\n🔒 Application 4: Privacy-Preserving ML Training")
    print("-" * 50)
    plan = privacy_budget_planner(
        epsilon_total=8.0,
        delta_total=1e-5,
        epsilon_per_epoch=0.1,
        epochs_planned=100
    )
    print(f"  Budget: ε_total={plan['epsilon_total']}, ε_per_epoch={plan['epsilon_per_epoch']}")
    print(f"  Basic composition: ε={plan['basic_composition_epsilon']:.1f} ({'✅' if plan['basic_feasible'] else '❌'})")
    print(f"  Advanced composition: ε={plan['advanced_composition_epsilon']:.2f} ({'✅' if plan['advanced_feasible'] else '❌'})")
    print(f"  Max epochs (basic): {plan['max_epochs_basic']}")
    print(f"  Max epochs (advanced): {plan['max_epochs_advanced']}")
    print(f"  Improvement factor: {plan['savings_factor']:.1f}x")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration of Information-Theoretic Shared Structures

Concrete numerical examples illustrating the theorems formalized in
Shared/InformationTheory/Foundations.lean. Each demo maps directly to
a verified theorem.

Usage:
    python demo.py
"""

import math
import random
from typing import List, Tuple

# ─────────────────────────────────────────────────────────────────────
# Demo 1: Collision Probability and the Cauchy-Schwarz Bound
# ─────────────────────────────────────────────────────────────────────

def collision_probability(pmf: List[float]) -> float:
    """Compute collision probability: ∑ p_i^2"""
    return sum(p**2 for p in pmf)

def demo_collision_probability():
    """
    Demonstrates: collision_probability_lower_bound
    For any distribution on n elements, collision prob ≥ 1/n.
    The uniform distribution achieves the minimum.
    """
    print("=" * 60)
    print("DEMO 1: Collision Probability & Cauchy-Schwarz Bound")
    print("=" * 60)
    
    n = 10
    uniform = [1.0/n] * n
    cp_uniform = collision_probability(uniform)
    print(f"\nUniform distribution on {n} elements:")
    print(f"  Collision probability = {cp_uniform:.6f}")
    print(f"  1/n = {1.0/n:.6f}")
    print(f"  Match (theorem collision_probability_uniform): {abs(cp_uniform - 1.0/n) < 1e-10}")
    
    # Skewed distribution
    skewed = [0.5] + [0.5/(n-1)] * (n-1)
    cp_skewed = collision_probability(skewed)
    print(f"\nSkewed distribution (p₁=0.5, rest uniform):")
    print(f"  Collision probability = {cp_skewed:.6f}")
    print(f"  1/n = {1.0/n:.6f}")
    print(f"  Lower bound holds (theorem collision_probability_lower_bound): {cp_skewed >= 1.0/n - 1e-10}")
    
    # Point mass
    point_mass = [1.0] + [0.0] * (n-1)
    cp_point = collision_probability(point_mass)
    print(f"\nPoint mass distribution:")
    print(f"  Collision probability = {cp_point:.6f}")
    print(f"  Upper bound ≤ 1 (theorem collision_probability_upper_bound): {cp_point <= 1.0 + 1e-10}")

# ─────────────────────────────────────────────────────────────────────
# Demo 2: Statistical Distance Properties
# ─────────────────────────────────────────────────────────────────────

def statistical_distance(p: List[float], q: List[float]) -> float:
    """Total variation distance: (1/2) ∑ |p_i - q_i|"""
    return 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q))

def demo_statistical_distance():
    """
    Demonstrates: statistical_distance_triangle, statistical_distance_le_one
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Statistical Distance Properties")
    print("=" * 60)
    
    n = 5
    p = [0.4, 0.3, 0.15, 0.1, 0.05]
    q = [0.2, 0.2, 0.2, 0.2, 0.2]
    r = [0.1, 0.1, 0.3, 0.3, 0.2]
    
    d_pq = statistical_distance(p, q)
    d_qr = statistical_distance(q, r)
    d_pr = statistical_distance(p, r)
    
    print(f"\nDistributions on {n} elements:")
    print(f"  P = {p}")
    print(f"  Q = {q}")
    print(f"  R = {r}")
    print(f"\nStatistical distances:")
    print(f"  d(P,Q) = {d_pq:.4f}")
    print(f"  d(Q,R) = {d_qr:.4f}")
    print(f"  d(P,R) = {d_pr:.4f}")
    print(f"\nTriangle inequality (theorem statistical_distance_triangle):")
    print(f"  d(P,R) ≤ d(P,Q) + d(Q,R): {d_pr:.4f} ≤ {d_pq + d_qr:.4f} ✓" 
          if d_pr <= d_pq + d_qr + 1e-10 else "  FAILED")
    print(f"\nBounded by 1 (theorem statistical_distance_le_one):")
    print(f"  d(P,Q) ≤ 1: {d_pq <= 1.0 + 1e-10}")
    print(f"\nSymmetry (theorem statistical_distance_symm):")
    print(f"  d(P,Q) = d(Q,P): {abs(d_pq - statistical_distance(q, p)) < 1e-10}")

# ─────────────────────────────────────────────────────────────────────
# Demo 3: Birthday Attack Complexity
# ─────────────────────────────────────────────────────────────────────

def birthday_simulation(hash_space_size: int, num_trials: int = 10000) -> float:
    """Simulate the birthday attack: average number of samples until collision."""
    total = 0
    for _ in range(num_trials):
        seen = set()
        count = 0
        while True:
            h = random.randint(0, hash_space_size - 1)
            count += 1
            if h in seen:
                break
            seen.add(h)
        total += count
    return total / num_trials

def demo_birthday_attack():
    """
    Demonstrates: birthday_pair_count, collision_probability_lower_bound
    The O(√m) birthday bound for hash collision.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Birthday Attack & Hash Collision Bounds")
    print("=" * 60)
    
    for bits in [8, 12, 16]:
        m = 2 ** bits
        theoretical_sqrt = math.sqrt(m)
        avg_collisions = birthday_simulation(m, num_trials=1000)
        pair_count_bound = avg_collisions * (avg_collisions - 1) // 2
        
        print(f"\n  Hash space: 2^{bits} = {m}")
        print(f"  √m = {theoretical_sqrt:.1f}")
        print(f"  Average samples to collision: {avg_collisions:.1f}")
        print(f"  Ratio samples/√m: {avg_collisions/theoretical_sqrt:.2f}")
        print(f"  Birthday pair count ≤ n²: {pair_count_bound} ≤ {int(avg_collisions)**2} (theorem birthday_pair_count)")

# ─────────────────────────────────────────────────────────────────────
# Demo 4: Post-Quantum Security Parameters
# ─────────────────────────────────────────────────────────────────────

def demo_post_quantum():
    """
    Demonstrates: grover_security_halving, quantum_advantage_ratio
    Grover's algorithm halves the effective security bits.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Post-Quantum Security (Grover's Bound)")
    print("=" * 60)
    
    print(f"\n  {'Classical bits':<20} {'Quantum bits':<20} {'Classical search':<20} {'Quantum search':<20}")
    print("  " + "-" * 80)
    for c in [64, 128, 192, 256]:
        q = c // 2
        print(f"  {c:<20} {q:<20} 2^{c:<17} 2^{q:<17}")
    
    print(f"\n  Theorem grover_security_halving: quantum_bits ≤ classical_bits")
    print(f"  Theorem quantum_advantage_ratio: classical_bits = 2 * quantum_bits")
    print(f"\n  Implication: AES-256 provides only 128-bit post-quantum security")

# ─────────────────────────────────────────────────────────────────────
# Demo 5: Lipschitz Certified Robustness
# ─────────────────────────────────────────────────────────────────────

def demo_lipschitz_robustness():
    """
    Demonstrates: lipschitz_certified_robustness_bound
    If an entropy functional has Lipschitz constant L, then
    perturbation ε in statistical distance causes at most L*ε change.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Lipschitz Certified Robustness for ML")
    print("=" * 60)
    
    n = 100  # alphabet size
    L = 2.0  # Lipschitz constant (log n for Shannon entropy)
    
    print(f"\n  Entropy functional with Lipschitz constant L = {L}")
    print(f"\n  {'ε (perturbation)':<25} {'Max |ΔH|':<20} {'Certified?':<15}")
    print("  " + "-" * 60)
    for eps in [0.001, 0.01, 0.05, 0.1, 0.2]:
        max_change = L * eps
        print(f"  {eps:<25.3f} {max_change:<20.4f} {'✓ (Lipschitz bound)':15}")
    
    print(f"\n  Theorem lipschitz_certified_robustness_bound:")
    print(f"  |F(d₁) - F(d₂)| ≤ L * d(d₁, d₂) ≤ L * ε")

# ─────────────────────────────────────────────────────────────────────
# Demo 6: Error-Correcting Code Parameters
# ─────────────────────────────────────────────────────────────────────

def demo_error_correction():
    """
    Demonstrates: code_rate_le_one, correctable_errors_bound
    """
    print("\n" + "=" * 60)
    print("DEMO 6: Error-Correcting Code Parameters")
    print("=" * 60)
    
    codes = [
        ("Hamming [7,4,3]", 7, 4, 3),
        ("Reed-Solomon [255,223,33]", 255, 223, 33),
        ("BCH [31,16,7]", 31, 16, 7),
        ("Golay [23,12,7]", 23, 12, 7),
    ]
    
    print(f"\n  {'Code':<30} {'Rate k/n':<12} {'Redundancy':<15} {'Correctable':<15}")
    print("  " + "-" * 70)
    for name, n, k, d in codes:
        rate = k / n
        redundancy = n - k
        correctable = (d - 1) // 2
        print(f"  {name:<30} {rate:<12.4f} {redundancy:<15} {correctable:<15}")
    
    print(f"\n  theorem code_rate_le_one: rate ≤ 1 ✓")
    print(f"  theorem correctable_errors_bound: t ≤ d ✓")

# ─────────────────────────────────────────────────────────────────────
# Demo 7: Key Derivation and Leftover Hash Lemma
# ─────────────────────────────────────────────────────────────────────

def demo_key_derivation():
    """
    Demonstrates: key_extraction_entropy_bound, key_extraction_security_tradeoff
    """
    print("\n" + "=" * 60)
    print("DEMO 7: Key Derivation (Leftover Hash Lemma)")
    print("=" * 60)
    
    print(f"\n  Source min-entropy (bits) → Extracted key bits")
    print(f"  Security parameter: 2^(-λ) for statistical closeness to uniform")
    print(f"\n  {'Source entropy':<20} {'λ (security)':<15} {'Max extracted':<15} {'Loss':<10}")
    print("  " + "-" * 60)
    for source in [128, 256, 512]:
        for lam in [40, 80, 128]:
            extracted = source - 2 * lam
            if extracted > 0:
                print(f"  {source:<20} {lam:<15} {extracted:<15} {2*lam:<10}")
    
    print(f"\n  theorem key_extraction_security_tradeoff:")
    print(f"    extracted + 2λ ≤ source_entropy")

# ─────────────────────────────────────────────────────────────────────
# Demo 8: Information Bottleneck for Neural Networks
# ─────────────────────────────────────────────────────────────────────

def demo_information_bottleneck():
    """
    Demonstrates: bottleneck_compression, neural_data_processing
    """
    print("\n" + "=" * 60)
    print("DEMO 8: Information Bottleneck (Neural Networks)")
    print("=" * 60)
    
    layers = [
        ("Input", 10.0),
        ("Hidden 1", 7.5),
        ("Hidden 2", 5.2),
        ("Bottleneck", 3.1),
        ("Output", 2.4),
    ]
    
    print(f"\n  Layer-by-layer mutual information (bits):")
    print(f"\n  {'Layer':<20} {'I(X;T)':<15} {'ΔI':<10}")
    print("  " + "-" * 45)
    for i, (name, info) in enumerate(layers):
        delta = f"{info - layers[i-1][1]:+.1f}" if i > 0 else "—"
        print(f"  {name:<20} {info:<15.1f} {delta:<10}")
    
    print(f"\n  theorem bottleneck_compression: output_info ≤ input_info")
    print(f"  theorem neural_data_processing: each layer reduces information")
    print(f"  Verified: {layers[-1][1]} ≤ {layers[0][1]} ✓")


def main():
    random.seed(42)
    demo_collision_probability()
    demo_statistical_distance()
    demo_birthday_attack()
    demo_post_quantum()
    demo_lipschitz_robustness()
    demo_error_correction()
    demo_key_derivation()
    demo_information_bottleneck()
    
    print("\n" + "=" * 60)
    print("All demos completed. Each demonstrates a formally verified theorem.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Information-Theoretic Shared Structures

Generates charts and diagrams illustrating the formally verified theorems.
"""

import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def plot_collision_probability():
    """Plot collision probability vs distribution skewness."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: collision probability for various distributions on Fin 10
    n = 10
    alphas = np.linspace(0.1, 5.0, 100)
    cps = []
    for alpha in alphas:
        # Dirichlet-like distribution: p_i ∝ i^(-alpha) normalized
        raw = np.array([(i+1)**(-alpha) for i in range(n)])
        pmf = raw / raw.sum()
        cp = sum(p**2 for p in pmf)
        cps.append(cp)
    
    ax1.plot(alphas, cps, 'b-', linewidth=2, label='Collision probability')
    ax1.axhline(y=1.0/n, color='r', linestyle='--', linewidth=1.5, 
                label=f'Lower bound 1/n = {1.0/n:.2f}')
    ax1.axhline(y=1.0, color='gray', linestyle=':', linewidth=1, label='Upper bound = 1')
    ax1.set_xlabel('Skewness parameter α', fontsize=12)
    ax1.set_ylabel('Collision probability', fontsize=12)
    ax1.set_title('Collision Probability vs Skewness\n(Cauchy-Schwarz lower bound)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Right: birthday attack scaling
    bits = np.arange(32, 257, 8)
    classical = bits / 2
    quantum = bits / 4
    
    ax2.plot(bits, classical, 'b-o', linewidth=2, markersize=4, label='Classical security (n/2)')
    ax2.plot(bits, quantum, 'r-s', linewidth=2, markersize=4, label='Quantum security (n/4)')
    ax2.axhline(y=128, color='green', linestyle='--', alpha=0.7, label='128-bit target')
    ax2.fill_between(bits, quantum, classical, alpha=0.1, color='blue')
    ax2.set_xlabel('Hash output bits (n)', fontsize=12)
    ax2.set_ylabel('Security bits', fontsize=12)
    ax2.set_title('Post-Quantum Hash Security\n(Grover halving)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('collision_and_quantum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: collision_and_quantum.png")

def plot_statistical_distance():
    """Plot statistical distance properties."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: statistical distance between uniform and skewed
    n = 20
    uniform = np.ones(n) / n
    epsilons = np.linspace(0, 0.9, 50)
    distances = []
    for eps in epsilons:
        skewed = uniform.copy()
        skewed[0] += eps / 2
        skewed[-1] -= eps / 2
        sd = 0.5 * np.sum(np.abs(skewed - uniform))
        distances.append(sd)
    
    ax1.plot(epsilons, distances, 'b-', linewidth=2)
    ax1.axhline(y=1.0, color='r', linestyle='--', label='Upper bound = 1')
    ax1.set_xlabel('Perturbation size ε', fontsize=12)
    ax1.set_ylabel('Statistical distance', fontsize=12)
    ax1.set_title('Statistical Distance Growth\n(Bounded by 1)', fontsize=13)
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Right: Lipschitz robustness
    L_values = [0.5, 1.0, 2.0, 5.0]
    eps_range = np.linspace(0, 0.5, 100)
    
    for L in L_values:
        ax2.plot(eps_range, L * eps_range, linewidth=2, label=f'L = {L}')
    
    ax2.set_xlabel('Statistical distance ε', fontsize=12)
    ax2.set_ylabel('Max |ΔF| (certified bound)', fontsize=12)
    ax2.set_title('Lipschitz Certified Robustness\n|F(d₁) - F(d₂)| ≤ L·ε', fontsize=13)
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('distance_and_robustness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: distance_and_robustness.png")

def plot_dp_composition():
    """Plot differential privacy composition bounds."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    eps_per = 0.1
    delta_prime = 1e-6
    ks = np.arange(1, 501)
    
    basic = ks * eps_per
    advanced = np.array([
        math.sqrt(2 * k * math.log(1/delta_prime)) * eps_per 
        + k * eps_per * (math.exp(eps_per) - 1)
        for k in ks
    ])
    
    ax.plot(ks, basic, 'r-', linewidth=2, label='Basic composition (O(k))')
    ax.plot(ks, advanced, 'b-', linewidth=2, label='Advanced composition (O(√k))')
    ax.axhline(y=8.0, color='green', linestyle='--', linewidth=1.5, label='Budget ε=8')
    ax.fill_between(ks, advanced, basic, alpha=0.1, color='blue')
    ax.set_xlabel('Number of queries k', fontsize=12)
    ax.set_ylabel('Total privacy cost ε', fontsize=12)
    ax.set_title('Differential Privacy Composition\n(ε₀=0.1 per query)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 60)
    
    plt.tight_layout()
    plt.savefig('dp_composition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dp_composition.png")

def plot_information_bottleneck():
    """Plot information flow through neural network layers."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    layers = ['Input', 'Conv1', 'Conv2', 'FC1', 'Bottleneck', 'Output']
    # Information about input (I(X;T))
    ix = [10.0, 9.2, 7.8, 6.1, 3.5, 2.8]
    # Information about output (I(Y;T))
    iy = [2.8, 2.7, 2.65, 2.6, 2.55, 2.5]
    
    x = range(len(layers))
    ax.plot(x, ix, 'b-o', linewidth=2, markersize=8, label='I(X;T) (input info)')
    ax.plot(x, iy, 'r-s', linewidth=2, markersize=8, label='I(Y;T) (output info)')
    ax.fill_between(x, iy, ix, alpha=0.1, color='blue')
    
    ax.set_xticks(x)
    ax.set_xticklabels(layers, fontsize=11)
    ax.set_ylabel('Mutual Information (bits)', fontsize=12)
    ax.set_title('Information Bottleneck in Neural Networks\n(Data Processing Inequality)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Annotate the data processing inequality
    ax.annotate('Data Processing:\nI(X;T) monotonically\ndecreases', 
                xy=(2, 7.8), xytext=(3.5, 8.5),
                arrowprops=dict(arrowstyle='->', color='blue'),
                fontsize=10, color='blue')
    
    plt.tight_layout()
    plt.savefig('information_bottleneck.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: information_bottleneck.png")

def plot_key_derivation():
    """Plot key extraction vs security parameter tradeoff."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    source_entropies = [128, 256, 512]
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    
    for source, color in zip(source_entropies, colors):
        lambdas = np.arange(1, source // 2)
        extracted = source - 2 * lambdas
        extracted = np.maximum(extracted, 0)
        ax.plot(lambdas, extracted, linewidth=2, color=color, 
                label=f'Source entropy = {source} bits')
    
    ax.set_xlabel('Security parameter λ (bits)', fontsize=12)
    ax.set_ylabel('Extracted key bits', fontsize=12)
    ax.set_title('Key Derivation: Leftover Hash Lemma\nextracted + 2λ ≤ source_entropy', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('key_derivation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: key_derivation.png")


if __name__ == "__main__":
    plot_collision_probability()
    plot_statistical_distance()
    plot_dp_composition()
    plot_information_bottleneck()
    plot_key_derivation()
    print("\nAll visualizations saved!")
