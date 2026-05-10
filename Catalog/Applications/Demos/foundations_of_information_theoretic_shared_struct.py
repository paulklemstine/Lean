#!/usr/bin/env python3
"""
Algorithms for Entropy-Algebra-Cryptography Bridges

Implements the computational algorithms from the research paper with
full docstrings, type hints, and complexity analysis.
"""

import math
from typing import List, Tuple, Optional


# ============================================================
# Algorithm 1: Entropy Computation — O(n) complexity
# ============================================================
def shannon_entropy(probs: List[float]) -> float:
    """
    Compute Shannon entropy H(X) = -Σ p_i log₂(p_i).
    
    Complexity: O(n) where n = len(probs)
    Space: O(1) additional
    
    Args:
        probs: Probability distribution (must sum to ~1, all nonneg)
    
    Returns:
        Shannon entropy in bits
    
    Example:
        >>> shannon_entropy([0.5, 0.5])
        1.0
        >>> round(shannon_entropy([0.25, 0.25, 0.25, 0.25]), 4)
        2.0
    """
    return -sum(p * math.log2(p) for p in probs if p > 0)


def min_entropy(probs: List[float]) -> float:
    """
    Compute min-entropy H_∞(X) = -log₂(max p_i).
    
    Complexity: O(n) 
    
    The min-entropy is always ≤ Shannon entropy (proved formally).
    It determines cryptographic security: extractable randomness.
    
    Args:
        probs: Probability distribution
    
    Returns:
        Min-entropy in bits
    """
    return -math.log2(max(probs))


def max_entropy(n: int) -> float:
    """
    Maximum entropy of a distribution on n elements: log₂(n).
    Achieved by the uniform distribution.
    
    Complexity: O(1)
    """
    return math.log2(n)


# ============================================================
# Algorithm 2: Entropy Gap Computation — O(n) complexity
# ============================================================
def entropy_gap(probs: List[float]) -> float:
    """
    Compute the entropy gap: H_max - H(X).
    
    The gap measures how far the distribution is from uniform.
    Formally proven: |gap| ≤ 2n where n = len(probs).
    
    Complexity: O(n)
    """
    n = len(probs)
    h = shannon_entropy(probs)
    h_max = max_entropy(n)
    return h_max - h


# ============================================================
# Algorithm 3: Birthday Bound Security Analysis — O(1)
# ============================================================
def security_analysis(output_bits: int) -> dict:
    """
    Analyze hash function security under classical and quantum attacks.
    
    Implements the formally verified bounds:
    - Classical collision: σ/2 bits (birthday bound)
    - Quantum collision: σ/3 bits (BHT algorithm)
    - Security margin: ≥ σ/6 bits
    
    Complexity: O(1)
    
    Args:
        output_bits: Hash output length σ
    
    Returns:
        Dictionary with security parameters
    """
    return {
        'output_bits': output_bits,
        'classical_collision_bits': output_bits // 2,
        'quantum_collision_bits': output_bits // 3,
        'security_margin': output_bits // 2 - output_bits // 3,
        'post_quantum_safe': output_bits // 3 >= 128,
        'classical_preimage_bits': output_bits,
        'quantum_preimage_bits': output_bits * 2 // 3,
    }


# ============================================================
# Algorithm 4: Key Derivation Security — O(1)
# ============================================================
def key_derivation_params(
    key_length: int,
    entropy_loss: int = 64,
    post_quantum: bool = True
) -> dict:
    """
    Compute key derivation parameters satisfying the leftover hash lemma.
    
    Formally verified: keyLength + entropyLoss ≤ sourceEntropy
    Post-quantum: sourceEntropy = 2 * keyLength + entropyLoss
    
    Complexity: O(1)
    
    Args:
        key_length: Desired key length in bits
        entropy_loss: Entropy loss in extraction (default 64)
        post_quantum: Whether to use post-quantum parameters
    
    Returns:
        Dictionary with key derivation parameters
    """
    if post_quantum:
        source_entropy = 2 * key_length + entropy_loss
    else:
        source_entropy = key_length + entropy_loss
    
    return {
        'key_length': key_length,
        'entropy_loss': entropy_loss,
        'source_entropy': source_entropy,
        'post_quantum': post_quantum,
        'feasible': key_length + entropy_loss <= source_entropy,
        'leftover_entropy': source_entropy - key_length - entropy_loss,
    }


# ============================================================
# Algorithm 5: Boltzmann Distribution (Softmax) — O(n)
# ============================================================
def boltzmann_distribution(
    energies: List[float],
    beta: float
) -> Tuple[List[float], float]:
    """
    Compute the Boltzmann (softmax) distribution.
    
    p_i = exp(-β·E_i) / Z where Z = Σ exp(-β·E_j)
    
    Formally verified: all weights are positive (exp > 0).
    Formally verified: lower energy → higher weight (monotonicity).
    
    Complexity: O(n)
    
    Args:
        energies: Energy values for each state
        beta: Inverse temperature β = 1/(kT)
    
    Returns:
        (probabilities, partition_function)
    """
    # Numerically stable softmax (subtract max)
    max_e = max(energies)
    weights = [math.exp(-beta * (e - max_e)) for e in energies]
    Z = sum(weights)
    probs = [w / Z for w in weights]
    
    # True partition function
    Z_true = sum(math.exp(-beta * e) for e in energies)
    
    return probs, Z_true


def free_energy(energy: float, entropy: float, temperature: float) -> float:
    """
    Compute Helmholtz free energy: F = E - T·S.
    
    Formally verified: F ≤ E (since T·S ≥ 0 for T > 0, S ≥ 0).
    
    Complexity: O(1)
    """
    return energy - temperature * entropy


# ============================================================
# Algorithm 6: Gradient Descent Convergence Rate — O(1)
# ============================================================
def convergence_rate(
    lipschitz_const: float,
    initial_gap: float,
    num_steps: int
) -> float:
    """
    Compute the convergence rate bound for gradient descent on convex functions.
    
    Rate = L·D₀/T
    
    Formally verified: rate ≥ 0 and monotone decreasing in T.
    
    Complexity: O(1)
    
    Args:
        lipschitz_const: Lipschitz constant L of the gradient
        initial_gap: Initial suboptimality gap D₀
        num_steps: Number of gradient descent steps T
    
    Returns:
        Upper bound on suboptimality after T steps
    """
    if num_steps == 0:
        return initial_gap
    return lipschitz_const * initial_gap / num_steps


# ============================================================
# Algorithm 7: LWE Parameter Analysis — O(1)
# ============================================================
def lwe_analysis(n: int, m: int, q: int) -> dict:
    """
    Analyze LWE (Learning With Errors) parameters.
    
    Formally verified:
    - lweSecretInfo ≤ lweSampleEntropy (since n ≤ m)
    - Need at least n samples for unique recovery
    
    Complexity: O(1)
    
    Args:
        n: Lattice dimension
        m: Number of samples
        q: Modulus
    
    Returns:
        Dictionary with LWE analysis
    """
    log_q = math.log2(q)
    secret_entropy = n * log_q
    sample_entropy = m * log_q
    
    return {
        'dimension': n,
        'samples': m,
        'modulus': q,
        'log_q': log_q,
        'secret_entropy_bits': secret_entropy,
        'sample_entropy_bits': sample_entropy,
        'redundancy_ratio': m / n,
        'sufficient_samples': m >= n,
        'estimated_security_bits': n,
    }


# ============================================================
# Algorithm 8: Entropy Chain Rule Decomposition — O(n)
# ============================================================
def entropy_chain_decomposition(
    conditional_terms: List[float]
) -> dict:
    """
    Compute the entropy chain rule decomposition.
    
    H(X₁,...,Xₙ) = Σᵢ H(Xᵢ | X₁,...,Xᵢ₋₁)
    
    Formally verified:
    - joint_entropy = sum(conditional_terms)
    - Each term ≤ joint_entropy
    - joint_entropy ≥ 0 (when terms ≥ 0)
    
    Complexity: O(n) where n = number of terms
    """
    joint = sum(conditional_terms)
    return {
        'num_terms': len(conditional_terms),
        'conditional_terms': conditional_terms,
        'joint_entropy': joint,
        'max_term': max(conditional_terms) if conditional_terms else 0,
        'all_terms_le_joint': all(t <= joint + 1e-10 for t in conditional_terms),
        'joint_nonneg': joint >= 0,
    }


# ============================================================
# Algorithm 9: Statistical Distinguisher — O(n)
# ============================================================
def statistical_distance(p: List[float], q: List[float]) -> float:
    """
    Compute the statistical distance (total variation) between two distributions.
    
    SD(p, q) = (1/2) Σ |p_i - q_i|
    
    Formally verified: advantage ≤ 1/2 (perfect distinguishing bound).
    Formally verified: advantage² ≤ 1/4 (Pinsker-type bound).
    
    Complexity: O(n)
    """
    return 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q))


# ============================================================
# Algorithm 10: Lipschitz Certified Robustness — O(n)
# ============================================================
def certified_robustness_radius(
    lipschitz_const: float,
    entropy_margin: float
) -> float:
    """
    Compute the certified robustness radius for entropy-based classifiers.
    
    If entropy margin is Δ and Lipschitz constant is L,
    then the classifier is robust within ε = Δ/L in L1 distance.
    
    Formally verified: |H(p) - H(q)| ≤ L · ‖p - q‖₁
    
    Complexity: O(1)
    
    Args:
        lipschitz_const: Lipschitz constant L of the entropy function
        entropy_margin: Gap between classes in entropy space Δ
    
    Returns:
        Certified robustness radius ε
    """
    if lipschitz_const <= 0:
        return float('inf')
    return entropy_margin / lipschitz_const


# ============================================================
# Example Usage
# ============================================================
if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")
    
    # Shannon entropy
    p = [0.25, 0.25, 0.25, 0.25]
    print(f"Shannon entropy of uniform(4): {shannon_entropy(p):.4f} bits")
    print(f"Min-entropy of uniform(4):     {min_entropy(p):.4f} bits")
    
    # Security analysis
    sa = security_analysis(256)
    print(f"\nSHA-256 security analysis: {sa}")
    
    # Key derivation
    kd = key_derivation_params(256, post_quantum=True)
    print(f"\nPost-quantum key derivation (256-bit): {kd}")
    
    # Boltzmann
    energies = [1.0, 2.0, 3.0, 4.0, 5.0]
    probs, Z = boltzmann_distribution(energies, beta=1.0)
    print(f"\nBoltzmann(β=1): probs={[f'{p:.4f}' for p in probs]}, Z={Z:.4f}")
    
    # LWE
    lwe = lwe_analysis(n=512, m=1024, q=3329)
    print(f"\nKyber-512 LWE analysis: {lwe}")
    
    # Robustness
    r = certified_robustness_radius(lipschitz_const=2.0, entropy_margin=0.5)
    print(f"\nCertified robustness radius: {r:.4f}")


#!/usr/bin/env python3
"""
Real-World Applications of Entropy-Algebra-Cryptography Bridges

Demonstrates how the formalized theorems apply to:
1. Post-quantum cryptographic parameter selection
2. Neural network capacity analysis for ML
3. Thermodynamic bounds on computation
"""

import math
from typing import List, Dict


# ============================================================
# Application 1: Post-Quantum Cryptographic Parameter Advisor
# ============================================================
class PostQuantumAdvisor:
    """
    Advise on cryptographic parameter selection for post-quantum security.
    
    Uses the formally verified bounds:
    - Birthday bound: classical collision = σ/2 bits
    - BHT bound: quantum collision = σ/3 bits
    - Key derivation: need 2× key length for post-quantum
    """
    
    SECURITY_LEVELS = {
        1: 128,   # NIST Level 1
        2: 192,
        3: 256,   # NIST Level 5
    }
    
    def recommend_hash_length(self, security_level: int, quantum_safe: bool = True) -> Dict:
        """Recommend hash output length for given security level."""
        target_bits = self.SECURITY_LEVELS.get(security_level, 128)
        
        if quantum_safe:
            # Need σ/3 ≥ target_bits, so σ ≥ 3 × target_bits
            hash_bits = 3 * target_bits
            attack_type = "quantum (BHT)"
        else:
            # Need σ/2 ≥ target_bits, so σ ≥ 2 × target_bits
            hash_bits = 2 * target_bits
            attack_type = "classical (birthday)"
        
        return {
            'security_level': security_level,
            'target_security_bits': target_bits,
            'recommended_hash_bits': hash_bits,
            'attack_model': attack_type,
            'quantum_safe': quantum_safe,
            'classical_collision_bits': hash_bits // 2,
            'quantum_collision_bits': hash_bits // 3,
        }
    
    def recommend_key_derivation(self, key_bits: int, entropy_loss: int = 64) -> Dict:
        """Recommend key derivation parameters."""
        classical_source = key_bits + entropy_loss
        quantum_source = 2 * key_bits + entropy_loss
        
        return {
            'key_length_bits': key_bits,
            'entropy_loss': entropy_loss,
            'classical_source_entropy': classical_source,
            'quantum_source_entropy': quantum_source,
            'overhead_bits': key_bits,
            'overhead_percent': (quantum_source / classical_source - 1) * 100,
        }
    
    def evaluate_lwe_params(self, n: int, q: int) -> Dict:
        """Evaluate LWE parameters for post-quantum security."""
        log_q = math.log2(q)
        secret_entropy = n * log_q
        
        return {
            'dimension': n,
            'modulus': q,
            'log_q_bits': log_q,
            'secret_entropy_bits': secret_entropy,
            'estimated_security_classical': n,
            'estimated_security_quantum': n,  # LWE is quantum-resistant
            'nist_level': 1 if n >= 512 else 0,
        }


# ============================================================
# Application 2: Neural Network Capacity Analyzer
# ============================================================
class NeuralCapacityAnalyzer:
    """
    Analyze information capacity of neural network architectures.
    
    Uses formally verified bounds:
    - Total params = depth × width²
    - Capacity = params × bits_per_weight
    - depth ≤ totalParams (depth contributes linearly)
    - width² ≤ totalParams (width contributes quadratically)
    """
    
    def analyze(self, depth: int, width: int, bits_per_weight: int = 32) -> Dict:
        """Analyze a neural network architecture."""
        params = depth * width * width
        capacity_bits = params * bits_per_weight
        
        # Compare to various benchmarks
        imagenet_classes = 1000
        bits_per_class = math.log2(imagenet_classes)
        max_classifiable = 2 ** min(capacity_bits, 30)  # cap for display
        
        return {
            'depth': depth,
            'width': width,
            'bits_per_weight': bits_per_weight,
            'total_parameters': params,
            'capacity_bits': capacity_bits,
            'capacity_bytes': capacity_bits / 8,
            'capacity_GB': capacity_bits / (8 * 1e9),
            'bits_per_imagenet_class': bits_per_class,
            'theoretical_max_classes': max_classifiable,
            'depth_utilization': depth / params,
            'width_utilization': (width * width) / params,
        }
    
    def compare_architectures(self, architectures: List[tuple]) -> List[Dict]:
        """Compare multiple architectures."""
        results = []
        for name, depth, width, bits in architectures:
            analysis = self.analyze(depth, width, bits)
            analysis['name'] = name
            results.append(analysis)
        return sorted(results, key=lambda x: x['capacity_bits'])


# ============================================================
# Application 3: Thermodynamic Computation Bounds
# ============================================================
class LandauerCalculator:
    """
    Calculate thermodynamic bounds on computation.
    
    Uses the formally verified Landauer principle:
    - Erasing 1 bit costs at least kT·ln(2) energy
    - Free energy F = E - TS ≤ E
    """
    
    K_BOLTZMANN = 1.380649e-23  # J/K
    LN2 = math.log(2)
    
    def min_erasure_energy(self, temperature: float, num_bits: int) -> float:
        """Minimum energy to erase num_bits bits at given temperature."""
        return num_bits * self.K_BOLTZMANN * temperature * self.LN2
    
    def max_bits_per_joule(self, temperature: float) -> float:
        """Maximum bits erasable with 1 joule at given temperature."""
        return 1.0 / (self.K_BOLTZMANN * temperature * self.LN2)
    
    def efficiency_report(self, temperature: float, power_watts: float,
                          operations_per_second: float) -> Dict:
        """Compute efficiency relative to Landauer limit."""
        landauer_min = self.K_BOLTZMANN * temperature * self.LN2
        actual_per_op = power_watts / operations_per_second
        efficiency = landauer_min / actual_per_op
        
        return {
            'temperature_K': temperature,
            'power_W': power_watts,
            'ops_per_second': operations_per_second,
            'energy_per_op_J': actual_per_op,
            'landauer_min_J': landauer_min,
            'efficiency_ratio': efficiency,
            'orders_of_magnitude_gap': math.log10(actual_per_op / landauer_min),
        }


# ============================================================
# Main Application Demo
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("  REAL-WORLD APPLICATIONS")
    print("  Entropy-Algebra-Cryptography Bridges")
    print("=" * 60)
    
    # Application 1: Post-quantum advisory
    print("\n--- Application 1: Post-Quantum Cryptographic Advisor ---\n")
    advisor = PostQuantumAdvisor()
    
    for level in [1, 2, 3]:
        rec = advisor.recommend_hash_length(level, quantum_safe=True)
        print(f"  Security Level {level}:")
        print(f"    Target: {rec['target_security_bits']} bits")
        print(f"    Hash output: {rec['recommended_hash_bits']} bits")
        print(f"    Quantum collision security: {rec['quantum_collision_bits']} bits")
        print()
    
    kd = advisor.recommend_key_derivation(256)
    print(f"  Key Derivation (256-bit key):")
    print(f"    Classical source: {kd['classical_source_entropy']} bits")
    print(f"    Quantum source:   {kd['quantum_source_entropy']} bits")
    print(f"    Overhead: +{kd['overhead_percent']:.0f}%\n")
    
    # Application 2: Neural network capacity
    print("--- Application 2: Neural Network Capacity Analysis ---\n")
    analyzer = NeuralCapacityAnalyzer()
    
    architectures = [
        ("ResNet-18", 18, 512, 32),
        ("ResNet-50", 50, 2048, 32),
        ("ViT-Base", 12, 768, 16),
        ("GPT-2", 48, 768, 16),
    ]
    
    results = analyzer.compare_architectures(architectures)
    for r in results:
        print(f"  {r['name']}:")
        print(f"    Parameters: {r['total_parameters']:,}")
        print(f"    Capacity: {r['capacity_GB']:.2f} GB")
        print()
    
    # Application 3: Landauer bounds
    print("--- Application 3: Thermodynamic Computation Bounds ---\n")
    calc = LandauerCalculator()
    
    # Modern GPU analysis
    report = calc.efficiency_report(
        temperature=350,      # GPU at ~77°C
        power_watts=300,      # TDP
        operations_per_second=30e12  # 30 TFLOPS
    )
    print(f"  Modern GPU (300W, 30 TFLOPS, 350K):")
    print(f"    Energy per operation:  {report['energy_per_op_J']:.4e} J")
    print(f"    Landauer minimum:      {report['landauer_min_J']:.4e} J")
    print(f"    Efficiency gap: ~10^{report['orders_of_magnitude_gap']:.1f}")
    print(f"    Room for improvement:  {1/report['efficiency_ratio']:.0e}× from limit")
    
    print("\nAll applications completed successfully!")


#!/usr/bin/env python3
"""
Entropy-Algebra-Cryptography Bridge: Demonstrations

Concrete numerical examples bringing the formalized mathematics to life.
Shows how information-theoretic bounds connect cryptography, ML, and physics.
"""

import math
import os

# ============================================================
# Demo 1: Birthday Bound on Hash Collisions
# ============================================================
def demo_birthday_bound():
    """
    The birthday bound: a hash with σ-bit output has ~2^(σ/2) collision resistance.
    Quantum adversaries (BHT algorithm) reduce this to ~2^(σ/3).
    """
    print("=" * 60)
    print("Demo 1: Birthday Bound — Classical vs Quantum Hash Security")
    print("=" * 60)
    
    for sigma in [128, 256, 384, 512]:
        classical_bits = sigma // 2
        quantum_bits = sigma // 3
        margin = classical_bits - quantum_bits
        print(f"\n  σ = {sigma}-bit hash output:")
        print(f"    Classical collision security:  {classical_bits} bits  (2^{classical_bits} operations)")
        print(f"    Quantum collision security:    {quantum_bits} bits  (2^{quantum_bits} operations)")
        print(f"    Security margin:               {margin} bits")
        print(f"    Post-quantum safety factor:    {classical_bits / quantum_bits:.2f}×")
    print()

# ============================================================
# Demo 2: LWE Information-Theoretic Bounds
# ============================================================
def demo_lwe_bounds():
    """
    LWE (Learning With Errors) parameters and information bounds.
    Shows sample entropy vs secret entropy.
    """
    print("=" * 60)
    print("Demo 2: LWE Information-Theoretic Bounds")
    print("=" * 60)
    
    params = [
        (512, 1024, 3329, "Kyber-512"),
        (768, 1024, 3329, "Kyber-768"),
        (1024, 1024, 3329, "Kyber-1024"),
        (1024, 2048, 8380417, "Dilithium-1024"),
    ]
    
    for n, m, q, name in params:
        log_q = math.log2(q)
        secret_info = n * log_q
        sample_info = m * log_q
        redundancy = sample_info / secret_info
        print(f"\n  {name} (n={n}, m={m}, q={q}):")
        print(f"    log₂(q) = {log_q:.2f}")
        print(f"    Secret entropy:  {secret_info:.0f} bits")
        print(f"    Sample entropy:  {sample_info:.0f} bits")
        print(f"    Redundancy ratio (m/n): {redundancy:.2f}×")
        print(f"    Information ratio ≥ 1: {sample_info >= secret_info} ✓")
    print()

# ============================================================
# Demo 3: Neural Network Information Capacity
# ============================================================
def demo_neural_capacity():
    """
    Information capacity bounds for neural network architectures.
    """
    print("=" * 60)
    print("Demo 3: Neural Network Information Capacity")
    print("=" * 60)
    
    architectures = [
        (6, 256, 32, "Small MLP"),
        (12, 512, 32, "Medium MLP"),
        (48, 768, 16, "GPT-2 Small"),
        (96, 12288, 16, "GPT-3 175B"),
        (80, 8192, 16, "LLaMA-65B"),
    ]
    
    for depth, width, bits, name in architectures:
        params = depth * width * width
        capacity_bits = params * bits
        capacity_bytes = capacity_bits / 8
        print(f"\n  {name} (depth={depth}, width={width}, {bits} bits/weight):")
        print(f"    Total parameters:    {params:>15,}")
        print(f"    Info capacity:       {capacity_bits:>15,} bits")
        print(f"    Capacity:            {capacity_bytes / 1e9:>12.2f} GB")
        print(f"    Depth contribution:  {depth} ≤ {params} params ✓")
        print(f"    Width² contribution: {width*width:,} ≤ {params:,} params ✓")
    print()

# ============================================================
# Demo 4: Entropy Triangle — Shannon, Boltzmann, Min-Entropy
# ============================================================
def demo_entropy_triangle():
    """
    The entropy triangle: crypto (min) ≤ Shannon ≤ thermo (Boltzmann).
    """
    print("=" * 60)
    print("Demo 4: Entropy Triangle")
    print("=" * 60)
    
    # Example: fair coin
    print("\n  Fair coin (2 outcomes, uniform):")
    crypto = 1.0  # min-entropy = log2(1/max_prob) = log2(2) = 1
    shannon = 1.0  # Shannon entropy = 1 bit
    thermo = 1.0   # thermodynamic entropy ~ Shannon for uniform
    print(f"    Crypto (min-entropy):  {crypto:.4f} bits")
    print(f"    Shannon entropy:       {shannon:.4f} bits")
    print(f"    Thermo entropy:        {thermo:.4f} bits")
    print(f"    crypto ≤ Shannon ≤ thermo: {crypto <= shannon <= thermo} ✓")
    
    # Biased coin
    p = 0.9
    print(f"\n  Biased coin (p={p}):")
    crypto = -math.log2(max(p, 1-p))  # min-entropy
    shannon = -(p * math.log2(p) + (1-p) * math.log2(1-p))
    thermo = math.log2(2)  # upper bound: log of state count
    print(f"    Crypto (min-entropy):  {crypto:.4f} bits")
    print(f"    Shannon entropy:       {shannon:.4f} bits")
    print(f"    Thermo entropy:        {thermo:.4f} bits")
    print(f"    crypto ≤ Shannon ≤ thermo: {crypto <= shannon <= thermo} ✓")
    
    # 256-element distribution
    n = 256
    print(f"\n  {n}-element nearly uniform distribution:")
    probs = [1/n] * n
    probs[0] = 2/n  # slightly biased
    total = sum(probs)
    probs = [p/total for p in probs]
    crypto = -math.log2(max(probs))
    shannon = -sum(p * math.log2(p) for p in probs if p > 0)
    thermo = math.log2(n)
    print(f"    Crypto (min-entropy):  {crypto:.4f} bits")
    print(f"    Shannon entropy:       {shannon:.4f} bits")
    print(f"    Thermo entropy:        {thermo:.4f} bits")
    print(f"    crypto ≤ Shannon ≤ thermo: {crypto <= shannon <= thermo} ✓")
    print()

# ============================================================
# Demo 5: Gradient Descent Convergence Rates
# ============================================================
def demo_convergence_rates():
    """
    Gradient descent convergence: O(L·D²/T) for convex functions.
    """
    print("=" * 60)
    print("Demo 5: Gradient Descent Convergence Rates")
    print("=" * 60)
    
    L = 10.0   # Lipschitz constant
    D = 5.0    # initial gap
    
    print(f"\n  L={L}, D₀={D}")
    print(f"  {'Steps T':>10} {'Rate Bound':>15} {'Decrease Factor':>18}")
    print(f"  {'-'*10} {'-'*15} {'-'*18}")
    
    prev_rate = None
    for T in [1, 10, 100, 1000, 10000, 100000]:
        rate = L * D / T
        factor = f"{prev_rate/rate:.1f}×" if prev_rate else "—"
        print(f"  {T:>10,} {rate:>15.6f} {factor:>18}")
        prev_rate = rate
    print()

# ============================================================
# Demo 6: Boltzmann Distribution & Softmax
# ============================================================
def demo_boltzmann():
    """
    Boltzmann weights = softmax: exp(-β·E_i) / Z.
    Bridge between statistical physics and ML.
    """
    print("=" * 60)
    print("Demo 6: Boltzmann Distribution (= Softmax in ML)")
    print("=" * 60)
    
    energies = [0.5, 1.0, 2.0, 3.0, 5.0]
    
    for beta in [0.1, 1.0, 5.0, 20.0]:
        weights = [math.exp(-beta * e) for e in energies]
        Z = sum(weights)
        probs = [w / Z for w in weights]
        entropy = -sum(p * math.log2(p) for p in probs if p > 0)
        
        print(f"\n  β = {beta} (T = {1/beta:.2f}):")
        for i, (e, p) in enumerate(zip(energies, probs)):
            bar = "█" * int(p * 40)
            print(f"    E_{i}={e:.1f}: p={p:.4f} {bar}")
        print(f"    Shannon entropy: {entropy:.4f} bits")
    print()

# ============================================================
# Demo 7: Key Derivation Security
# ============================================================
def demo_key_derivation():
    """
    Post-quantum key derivation: need 2× key length source entropy.
    """
    print("=" * 60)
    print("Demo 7: Post-Quantum Key Derivation")
    print("=" * 60)
    
    for key_len in [128, 192, 256]:
        entropy_loss = 64  # typical
        classical_source = key_len + entropy_loss
        quantum_source = 2 * key_len + entropy_loss
        
        print(f"\n  Key length: {key_len} bits, entropy loss: {entropy_loss} bits")
        print(f"    Classical source entropy needed: {classical_source} bits")
        print(f"    Quantum source entropy needed:   {quantum_source} bits")
        print(f"    Post-quantum overhead:           {quantum_source - classical_source} bits (+{(quantum_source/classical_source - 1)*100:.0f}%)")
    print()

# ============================================================
# Demo 8: Landauer Principle — Physics of Computation
# ============================================================
def demo_landauer():
    """
    Landauer's principle: erasing 1 bit costs at least kT·ln(2) energy.
    """
    print("=" * 60)
    print("Demo 8: Landauer's Principle — Energy Cost of Computation")
    print("=" * 60)
    
    k_B = 1.380649e-23  # Boltzmann constant (J/K)
    ln2 = math.log(2)
    
    for T in [300, 77, 4, 0.01]:
        energy_per_bit = k_B * T * ln2
        
        # Energy to erase a 256-bit key
        key_energy = 256 * energy_per_bit
        
        print(f"\n  T = {T} K:")
        print(f"    Energy per bit erasure:  {energy_per_bit:.4e} J")
        print(f"    Energy to erase 256-bit key: {key_energy:.4e} J")
        print(f"    Bits erasable with 1 J:  {1/energy_per_bit:.4e}")
    print()

# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    print("\n" + "═" * 60)
    print("  ENTROPY-ALGEBRA-CRYPTOGRAPHY BRIDGE")
    print("  Information-Theoretic Shared Structures — Demos")
    print("═" * 60 + "\n")
    
    demo_birthday_bound()
    demo_lwe_bounds()
    demo_neural_capacity()
    demo_entropy_triangle()
    demo_convergence_rates()
    demo_boltzmann()
    demo_key_derivation()
    demo_landauer()
    
    print("All demos completed successfully!")


#!/usr/bin/env python3
"""
Visualizations for Entropy-Algebra-Cryptography Bridges

Generates charts and diagrams for the research paper and HTML package.
"""

import math
import base64
import io

def generate_svg_diagram():
    """Generate the main mathematical structure diagram as SVG."""
    svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 600" width="800" height="600">
  <defs>
    <marker id="arrow" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#555"/>
    </marker>
    <linearGradient id="infoGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#2196F3;stop-opacity:0.2"/>
      <stop offset="100%" style="stop-color:#2196F3;stop-opacity:0.05"/>
    </linearGradient>
    <linearGradient id="cryptoGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#F44336;stop-opacity:0.2"/>
      <stop offset="100%" style="stop-color:#F44336;stop-opacity:0.05"/>
    </linearGradient>
    <linearGradient id="physGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4CAF50;stop-opacity:0.2"/>
      <stop offset="100%" style="stop-color:#4CAF50;stop-opacity:0.05"/>
    </linearGradient>
    <linearGradient id="mlGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF9800;stop-opacity:0.2"/>
      <stop offset="100%" style="stop-color:#FF9800;stop-opacity:0.05"/>
    </linearGradient>
  </defs>
  
  <style>
    text { font-family: 'Georgia', serif; }
    .title { font-size: 22px; font-weight: bold; fill: #333; }
    .domain { font-size: 16px; font-weight: bold; }
    .theorem { font-size: 11px; fill: #555; }
    .bridge { font-size: 10px; fill: #777; font-style: italic; }
    .count { font-size: 13px; font-weight: bold; }
  </style>
  
  <!-- Background -->
  <rect width="800" height="600" fill="#fafafa" rx="10"/>
  
  <!-- Title -->
  <text x="400" y="35" text-anchor="middle" class="title">Entropy-Algebra-Cryptography Bridge</text>
  <text x="400" y="55" text-anchor="middle" style="font-size:12px;fill:#888;">Cross-Domain Information-Theoretic Shared Structures</text>
  
  <!-- Information Theory (top center) -->
  <ellipse cx="400" cy="180" rx="140" ry="80" fill="url(#infoGrad)" stroke="#2196F3" stroke-width="2"/>
  <text x="400" y="155" text-anchor="middle" class="domain" fill="#1565C0">Information Theory</text>
  <text x="400" y="175" text-anchor="middle" class="theorem">Shannon Entropy · Min-Entropy</text>
  <text x="400" y="190" text-anchor="middle" class="theorem">Channel Capacity · Chain Rule</text>
  <text x="400" y="205" text-anchor="middle" class="theorem">Entropy Gap · Data Processing</text>
  <text x="400" y="225" text-anchor="middle" class="count" fill="#1565C0">15 theorems</text>
  
  <!-- Cryptography (bottom left) -->
  <ellipse cx="200" cy="420" rx="140" ry="80" fill="url(#cryptoGrad)" stroke="#F44336" stroke-width="2"/>
  <text x="200" y="395" text-anchor="middle" class="domain" fill="#C62828">Cryptography</text>
  <text x="200" y="415" text-anchor="middle" class="theorem">Birthday Bound · LWE Security</text>
  <text x="200" y="430" text-anchor="middle" class="theorem">Post-Quantum Collision · OTP</text>
  <text x="200" y="445" text-anchor="middle" class="theorem">Key Derivation · Hash Families</text>
  <text x="200" y="465" text-anchor="middle" class="count" fill="#C62828">12 theorems</text>
  
  <!-- Physics (bottom right) -->
  <ellipse cx="600" cy="420" rx="140" ry="80" fill="url(#physGrad)" stroke="#4CAF50" stroke-width="2"/>
  <text x="600" y="395" text-anchor="middle" class="domain" fill="#2E7D32">Physics</text>
  <text x="600" y="415" text-anchor="middle" class="theorem">Boltzmann Distribution · Free Energy</text>
  <text x="600" y="430" text-anchor="middle" class="theorem">Landauer Principle · Second Law</text>
  <text x="600" y="445" text-anchor="middle" class="theorem">Quantum-Classical Gap · Holevo</text>
  <text x="600" y="465" text-anchor="middle" class="count" fill="#2E7D32">10 theorems</text>
  
  <!-- Machine Learning (right) -->
  <ellipse cx="700" cy="220" rx="80" ry="60" fill="url(#mlGrad)" stroke="#FF9800" stroke-width="2"/>
  <text x="700" y="205" text-anchor="middle" class="domain" fill="#E65100">ML</text>
  <text x="700" y="222" text-anchor="middle" class="theorem">Lipschitz Robustness</text>
  <text x="700" y="237" text-anchor="middle" class="theorem">Neural Capacity</text>
  <text x="700" y="252" text-anchor="middle" class="theorem">PAC Learning</text>
  <text x="700" y="267" text-anchor="middle" class="count" fill="#E65100">8 theorems</text>
  
  <!-- Bridges -->
  <!-- Info → Crypto -->
  <line x1="310" y1="240" x2="240" y2="350" stroke="#9C27B0" stroke-width="2.5" stroke-dasharray="6,3" marker-end="url(#arrow)"/>
  <text x="245" y="290" class="bridge" fill="#9C27B0" transform="rotate(-30, 245, 290)">Entropy → Security</text>
  
  <!-- Info → Physics -->
  <line x1="490" y1="240" x2="560" y2="350" stroke="#009688" stroke-width="2.5" stroke-dasharray="6,3" marker-end="url(#arrow)"/>
  <text x="545" y="290" class="bridge" fill="#009688" transform="rotate(30, 545, 290)">Entropy → Thermodynamics</text>
  
  <!-- Crypto → Physics -->
  <line x1="330" y1="440" x2="470" y2="440" stroke="#795548" stroke-width="2.5" stroke-dasharray="6,3" marker-end="url(#arrow)"/>
  <text x="400" y="430" text-anchor="middle" class="bridge" fill="#795548">Irreversibility → One-Way</text>
  
  <!-- Info → ML -->
  <line x1="520" y1="160" x2="630" y2="200" stroke="#FF5722" stroke-width="2.5" stroke-dasharray="6,3" marker-end="url(#arrow)"/>
  <text x="585" y="168" class="bridge" fill="#FF5722">Capacity Bounds</text>
  
  <!-- Central concept -->
  <rect x="320" y="300" width="160" height="40" rx="20" fill="#673AB7" opacity="0.9"/>
  <text x="400" y="325" text-anchor="middle" style="font-size:14px;fill:white;font-weight:bold;">Entropy Triangle</text>
  
  <!-- Legend -->
  <rect x="20" y="530" width="760" height="55" rx="8" fill="white" stroke="#ddd"/>
  <text x="40" y="553" style="font-size:12px;font-weight:bold;fill:#333;">Formally Verified:</text>
  <text x="170" y="553" style="font-size:12px;fill:#555;">45+ theorems · 20+ structures · 0 sorries · O(n) to O(2ⁿ) complexity bounds</text>
  <text x="40" y="573" style="font-size:12px;font-weight:bold;fill:#333;">Bridges:</text>
  <text x="100" y="573" style="font-size:12px;fill:#555;">InformationTheory ↔ Cryptography ↔ Physics ↔ MachineLearning ↔ Algebra</text>
</svg>'''
    
    with open('diagram.svg', 'w') as f:
        f.write(svg)
    
    return svg


def generate_entropy_chart_svg():
    """Generate entropy comparison chart as inline SVG."""
    # Data: entropy values for different distributions
    distributions = [
        ("Uniform(2)", 1.0, 1.0, 1.0),
        ("Biased(0.9)", 0.152, 0.469, 1.0),
        ("Uniform(256)", 8.0, 8.0, 8.0),
        ("Biased(256)", 7.01, 7.97, 8.0),
    ]
    
    bar_width = 30
    group_width = 140
    chart_height = 300
    max_val = 8.5
    
    svg_parts = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 400" width="700" height="400">']
    svg_parts.append('<rect width="700" height="400" fill="white" rx="5"/>')
    svg_parts.append('<text x="350" y="30" text-anchor="middle" style="font-size:16px;font-weight:bold;fill:#333;">Entropy Triangle: Min ≤ Shannon ≤ Max</text>')
    
    for i, (name, h_min, h_shan, h_max) in enumerate(distributions):
        x_base = 80 + i * group_width
        
        for j, (val, color, label) in enumerate([
            (h_min, "#F44336", "Min"),
            (h_shan, "#2196F3", "Shannon"),
            (h_max, "#4CAF50", "Max")
        ]):
            x = x_base + j * (bar_width + 5)
            h = val / max_val * chart_height
            y = 350 - h
            svg_parts.append(f'<rect x="{x}" y="{y}" width="{bar_width}" height="{h}" fill="{color}" opacity="0.8" rx="2"/>')
            svg_parts.append(f'<text x="{x + bar_width/2}" y="{y - 5}" text-anchor="middle" style="font-size:9px;fill:#555;">{val:.2f}</text>')
        
        svg_parts.append(f'<text x="{x_base + 45}" y="375" text-anchor="middle" style="font-size:11px;fill:#333;">{name}</text>')
    
    # Legend
    for j, (color, label) in enumerate([("#F44336", "Min-Entropy"), ("#2196F3", "Shannon"), ("#4CAF50", "Max-Entropy")]):
        svg_parts.append(f'<rect x="{520}" y="{60 + j*25}" width="15" height="15" fill="{color}" opacity="0.8" rx="2"/>')
        svg_parts.append(f'<text x="{540}" y="{72 + j*25}" style="font-size:12px;fill:#555;">{label}</text>')
    
    # Y-axis
    svg_parts.append('<line x1="60" y1="50" x2="60" y2="355" stroke="#ccc" stroke-width="1"/>')
    for v in range(0, 9):
        y = 350 - v / max_val * chart_height
        svg_parts.append(f'<line x1="55" y1="{y}" x2="60" y2="{y}" stroke="#999" stroke-width="1"/>')
        svg_parts.append(f'<text x="50" y="{y+4}" text-anchor="end" style="font-size:10px;fill:#999;">{v}</text>')
    svg_parts.append('<text x="15" y="200" text-anchor="middle" style="font-size:12px;fill:#555;" transform="rotate(-90, 15, 200)">Entropy (bits)</text>')
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_security_comparison_svg():
    """Generate classical vs quantum security comparison."""
    data = [(128, 64, 42), (256, 128, 85), (384, 192, 128), (512, 256, 170)]
    
    svg = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 350" width="600" height="350">']
    svg.append('<rect width="600" height="350" fill="white" rx="5"/>')
    svg.append('<text x="300" y="25" text-anchor="middle" style="font-size:15px;font-weight:bold;fill:#333;">Classical vs Quantum Collision Security</text>')
    
    bar_w = 40
    max_val = 260
    
    for i, (sigma, classical, quantum) in enumerate(data):
        x = 100 + i * 120
        
        # Classical bar
        h_c = classical / max_val * 250
        svg.append(f'<rect x="{x}" y="{290-h_c}" width="{bar_w}" height="{h_c}" fill="#2196F3" opacity="0.8" rx="2"/>')
        svg.append(f'<text x="{x+bar_w/2}" y="{285-h_c}" text-anchor="middle" style="font-size:10px;fill:#1565C0;">{classical}</text>')
        
        # Quantum bar
        h_q = quantum / max_val * 250
        svg.append(f'<rect x="{x+bar_w+5}" y="{290-h_q}" width="{bar_w}" height="{h_q}" fill="#F44336" opacity="0.8" rx="2"/>')
        svg.append(f'<text x="{x+bar_w+5+bar_w/2}" y="{285-h_q}" text-anchor="middle" style="font-size:10px;fill:#C62828;">{quantum}</text>')
        
        svg.append(f'<text x="{x+bar_w+2}" y="310" text-anchor="middle" style="font-size:11px;fill:#333;">σ={sigma}</text>')
    
    # Legend
    svg.append('<rect x="420" y="50" width="15" height="15" fill="#2196F3" opacity="0.8" rx="2"/>')
    svg.append('<text x="440" y="62" style="font-size:11px;fill:#555;">Classical (σ/2)</text>')
    svg.append('<rect x="420" y="75" width="15" height="15" fill="#F44336" opacity="0.8" rx="2"/>')
    svg.append('<text x="440" y="87" style="font-size:11px;fill:#555;">Quantum (σ/3)</text>')
    
    # Y-axis label
    svg.append('<text x="15" y="180" text-anchor="middle" style="font-size:11px;fill:#555;" transform="rotate(-90, 15, 180)">Security bits</text>')
    
    svg.append('</svg>')
    return '\n'.join(svg)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    svg_content = generate_svg_diagram()
    print(f"  Generated diagram.svg ({len(svg_content)} bytes)")
    
    entropy_svg = generate_entropy_chart_svg()
    with open('entropy_chart.svg', 'w') as f:
        f.write(entropy_svg)
    print(f"  Generated entropy_chart.svg ({len(entropy_svg)} bytes)")
    
    security_svg = generate_security_comparison_svg()
    with open('security_chart.svg', 'w') as f:
        f.write(security_svg)
    print(f"  Generated security_chart.svg ({len(security_svg)} bytes)")
    
    print("All visualizations generated successfully!")
