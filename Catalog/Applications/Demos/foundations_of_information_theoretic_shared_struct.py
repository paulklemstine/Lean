#!/usr/bin/env python3
"""
Algorithms for Information-Theoretic Cryptographic Security

Implements key algorithms from the research paper with full
docstrings, type hints, and complexity analysis.
"""

import math
from typing import List, Tuple, Optional
import random


class EntropyEstimator:
    """Estimates Shannon entropy from empirical frequency counts.

    Time complexity: O(n) for n samples
    Space complexity: O(|alphabet|) for alphabet size
    """

    def __init__(self):
        self.counts: dict = {}
        self.total: int = 0

    def update(self, symbol) -> None:
        """Add a symbol observation. O(1) amortized."""
        self.counts[symbol] = self.counts.get(symbol, 0) + 1
        self.total += 1

    def entropy(self) -> float:
        """Compute Shannon entropy in bits. O(|alphabet|).

        H(X) = -Σ p(x) log₂(p(x))
        """
        if self.total == 0:
            return 0.0
        H = 0.0
        for count in self.counts.values():
            if count > 0:
                p = count / self.total
                H -= p * math.log2(p)
        return H

    def min_entropy(self) -> float:
        """Compute min-entropy in bits. O(|alphabet|).

        H_∞(X) = -log₂(max_x P(X=x))

        This is the most conservative entropy measure and determines
        the guessing probability: P_guess = 2^(-H_∞).
        """
        if self.total == 0:
            return 0.0
        max_prob = max(c / self.total for c in self.counts.values())
        if max_prob == 0:
            return float('inf')
        return -math.log2(max_prob)

    def guessing_probability(self) -> float:
        """Optimal guessing probability. O(|alphabet|).

        P_guess = 2^(-H_∞(X)) = max_x P(X=x)
        """
        if self.total == 0:
            return 0.0
        return max(c / self.total for c in self.counts.values())


class CryptoSecurityAnalyzer:
    """Analyzes cryptographic security parameters.

    Computes brute-force costs, Grover speedups, and
    Landauer energy bounds for given security parameters.
    """

    BOLTZMANN_K = 1.380649e-23  # J/K
    ROOM_TEMP = 300  # K

    def __init__(self, key_bits: int, temperature: float = 300.0):
        self.key_bits = key_bits
        self.temperature = temperature
        self.kT = self.BOLTZMANN_K * temperature

    def classical_security_level(self) -> float:
        """Classical security level in bits. O(1)."""
        return self.key_bits

    def quantum_security_level(self) -> float:
        """Post-quantum security level (Grover halving). O(1).

        Grover's algorithm provides quadratic speedup:
        classical n bits → quantum n/2 bits.
        """
        return self.key_bits / 2

    def brute_force_operations(self) -> float:
        """Expected brute-force search operations. O(1).

        Returns 2^n / 2 for n-bit key space.
        Complexity: Ω(2^n) operations.
        """
        return 2**(self.key_bits) / 2

    def grover_operations(self) -> float:
        """Grover search operations. O(1).

        Returns O(2^(n/2)) for n-bit key space.
        This is optimal for unstructured search.
        """
        return 2**(self.key_bits / 2)

    def landauer_energy_bound(self) -> float:
        """Minimum energy to erase the key search space. O(1).

        E_min = 2^n · kT · ln(2) joules.
        This is the thermodynamic lower bound on attack energy.
        """
        return 2**self.key_bits * self.kT * math.log(2)

    def grover_landauer_energy(self) -> float:
        """Energy for Grover search with Landauer bound. O(1).

        E = 2^(n/2) · kT · ln(2) joules per oracle query.
        Total energy for quantum brute-force attack.
        """
        return 2**(self.key_bits / 2) * self.kT * math.log(2)

    def security_report(self) -> str:
        """Generate a comprehensive security report."""
        lines = [
            f"Security Analysis for {self.key_bits}-bit key",
            f"  Classical security:    {self.classical_security_level():.0f} bits",
            f"  Quantum security:      {self.quantum_security_level():.0f} bits",
            f"  Brute-force ops:       {self.brute_force_operations():.2e}",
            f"  Grover ops:            {self.grover_operations():.2e}",
            f"  Landauer energy:       {self.landauer_energy_bound():.2e} J",
            f"  Grover-Landauer:       {self.grover_landauer_energy():.2e} J",
        ]
        return "\n".join(lines)


class LatticeSecurityEstimator:
    """Estimates security of lattice-based cryptographic schemes.

    Models LWE/Ring-LWE parameter selection with security estimation.
    Time complexity: O(1) for parameter computation.
    """

    def __init__(self, dim: int, modulus: int, error_stddev: float):
        self.dim = dim
        self.modulus = modulus
        self.error_stddev = error_stddev

    def security_bits_estimate(self) -> float:
        """Rough BKZ security estimate. O(1).

        Security ≈ 0.265 · n · log₂(q/σ) for standard LWE.
        This is a simplified Core-SVP estimate.
        """
        if self.error_stddev <= 0 or self.modulus <= 0:
            return 0.0
        ratio = self.modulus / self.error_stddev
        if ratio <= 1:
            return 0.0
        return 0.265 * self.dim * math.log2(ratio)

    def lwe_key_size(self) -> int:
        """Standard LWE key size in bits. O(1).

        Key size = n² · ⌈log₂(q)⌉ bits.
        Complexity class: O(n² · log q).
        """
        log_q = math.ceil(math.log2(self.modulus))
        return self.dim * self.dim * log_q

    def ring_lwe_key_size(self) -> int:
        """Ring-LWE key size in bits. O(1).

        Key size = n · ⌈log₂(q)⌉ bits.
        Complexity class: O(n · log q).
        Quadratic improvement over standard LWE.
        """
        log_q = math.ceil(math.log2(self.modulus))
        return self.dim * log_q

    def lll_approximation_factor(self) -> float:
        """LLL algorithm approximation factor. O(1).

        Factor = 2^((n-1)/2) for n-dimensional lattice.
        LLL runs in O(n⁵ · log³ B) time.
        """
        return 2**((self.dim - 1) / 2)


class LinearCryptanalysis:
    """Implements linear cryptanalysis bias and complexity analysis.

    The piling-up lemma governs bias composition across cipher rounds.
    """

    def __init__(self, round_biases: List[float]):
        """Initialize with per-round biases.

        Args:
            round_biases: List of bias values ε_i ∈ [0, 0.5] for each round.
        """
        self.round_biases = round_biases

    def total_bias(self) -> float:
        """Compute total bias via piling-up lemma. O(r) for r rounds.

        Total bias = 2^(r-1) · ∏ε_i
        """
        r = len(self.round_biases)
        if r == 0:
            return 0.0
        product = 1.0
        for eps in self.round_biases:
            product *= eps
        return 2**(r - 1) * product

    def data_complexity(self) -> float:
        """Known plaintexts needed for attack. O(r).

        Complexity = O(1/ε²) where ε is total bias.
        """
        eps = self.total_bias()
        if eps == 0:
            return float('inf')
        return 1.0 / eps**2

    def success_probability(self, num_pairs: int) -> float:
        """Estimate attack success probability. O(r).

        Uses normal approximation to the bias statistic.
        """
        eps = self.total_bias()
        if eps == 0:
            return 0.0
        # Rough estimate: success ~ 1 - exp(-2 * n * eps^2)
        exponent = -2 * num_pairs * eps**2
        return 1.0 - math.exp(max(exponent, -700))


class PACLearner:
    """PAC learning sample complexity calculator.

    Computes information-theoretic bounds on learning.
    """

    def __init__(self, vc_dim: int, epsilon: float, delta: float):
        self.vc_dim = vc_dim
        self.epsilon = epsilon
        self.delta = delta

    def sample_lower_bound(self) -> float:
        """Information-theoretic lower bound: Ω(d/ε).

        This bound holds for any learning algorithm.
        """
        return self.vc_dim / self.epsilon

    def sample_upper_bound(self) -> float:
        """PAC upper bound: O((d/ε²) · log(1/(εδ))).

        Achieved by ERM (Empirical Risk Minimization).
        """
        return (self.vc_dim * math.log(1 / (self.epsilon * self.delta))) / self.epsilon**2

    def rademacher_bound(self, n_samples: int) -> float:
        """Rademacher complexity generalization bound.

        Gap ≈ √(vc_dim / n_samples)
        """
        if n_samples == 0:
            return float('inf')
        return math.sqrt(self.vc_dim / n_samples)


class LipschitzRobustness:
    """Certified robustness analysis via Lipschitz bounds.

    For a model f with Lipschitz constant L and margin γ at point x:
    - Certified radius = γ / L
    - All points within radius have same classification
    """

    def __init__(self, lipschitz_const: float, margin: float):
        self.L = lipschitz_const
        self.margin = margin

    def certified_radius(self) -> float:
        """Certified robustness radius: γ/L."""
        return self.margin / self.L

    def is_certifiably_robust(self, perturbation_norm: float) -> bool:
        """Check if perturbation is within certified radius."""
        return perturbation_norm < self.certified_radius()

    def required_margin(self, target_radius: float) -> float:
        """Margin needed for target robustness radius."""
        return target_radius * self.L


def demo_all():
    """Run all algorithm demonstrations."""
    print("=" * 60)
    print("  ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Entropy estimation
    print("\n━━━ Entropy Estimation ━━━")
    est = EntropyEstimator()
    random.seed(42)
    for _ in range(10000):
        est.update(random.choice("ABCD"))
    print(f"Uniform over ABCD: H = {est.entropy():.4f} bits (expected: 2.0)")
    print(f"Min-entropy: H_∞ = {est.min_entropy():.4f} bits")
    print(f"Guessing prob: {est.guessing_probability():.4f}")

    # Biased source
    est2 = EntropyEstimator()
    for _ in range(10000):
        r = random.random()
        if r < 0.5:
            est2.update('A')
        elif r < 0.75:
            est2.update('B')
        elif r < 0.9:
            est2.update('C')
        else:
            est2.update('D')
    print(f"\nBiased source: H = {est2.entropy():.4f} bits")
    print(f"Min-entropy: H_∞ = {est2.min_entropy():.4f} bits")

    # Security analysis
    print("\n━━━ Security Analysis ━━━")
    for bits in [128, 256]:
        analyzer = CryptoSecurityAnalyzer(bits)
        print(f"\n{analyzer.security_report()}")

    # Lattice security
    print("\n━━━ Lattice Security (Kyber-like) ━━━")
    for n, q, sigma in [(256, 3329, 3.19), (512, 3329, 3.19), (768, 3329, 2.75), (1024, 3329, 2.29)]:
        lat = LatticeSecurityEstimator(n, q, sigma)
        print(f"n={n}: security≈{lat.security_bits_estimate():.0f} bits, "
              f"LWE key={lat.lwe_key_size()} bits, "
              f"RLWE key={lat.ring_lwe_key_size()} bits")

    # Linear cryptanalysis
    print("\n━━━ Linear Cryptanalysis ━━━")
    biases = [0.1] * 8
    lc = LinearCryptanalysis(biases)
    print(f"8 rounds, bias=0.1 each:")
    print(f"  Total bias: {lc.total_bias():.2e}")
    print(f"  Data complexity: {lc.data_complexity():.2e} pairs")

    # PAC learning
    print("\n━━━ PAC Learning Bounds ━━━")
    for d in [10, 100, 1000]:
        pac = PACLearner(d, 0.05, 0.05)
        print(f"VC dim={d}: lower={pac.sample_lower_bound():.0f}, "
              f"upper={pac.sample_upper_bound():.0f}")

    # Lipschitz robustness
    print("\n━━━ Certified Robustness ━━━")
    for L in [1.0, 10.0, 100.0]:
        rob = LipschitzRobustness(L, 0.5)
        print(f"L={L}: radius={rob.certified_radius():.4f}, "
              f"robust to ε=0.01: {rob.is_certifiably_robust(0.01)}")


if __name__ == "__main__":
    demo_all()


#!/usr/bin/env python3
"""
Real-World Applications of Information-Theoretic Cryptographic Security

Demonstrates practical applications in:
1. Post-quantum cryptographic parameter selection
2. Machine learning certified robustness
3. Thermodynamic computing bounds
4. Communication system design
"""

import math
from typing import Dict, List, Tuple


# ============================================================
# Application 1: Post-Quantum Cryptographic Parameter Selection
# ============================================================

class PostQuantumParameterSelector:
    """Selects parameters for lattice-based post-quantum cryptography.

    Uses the entropy-security duality to translate desired security
    levels into concrete LWE/Ring-LWE parameters.

    Application: lattice_crypto parameter selection for NIST standards.
    """

    NIST_LEVELS = {
        1: 128,   # At least as hard as AES-128
        2: 192,   # At least as hard as SHA-256/SHA3-256
        3: 192,   # At least as hard as AES-192
        4: 256,   # At least as hard as SHA-384/SHA3-384
        5: 256,   # At least as hard as AES-256
    }

    def __init__(self, target_security_bits: int):
        self.target_bits = target_security_bits

    def min_lattice_dimension(self) -> int:
        """Minimum lattice dimension for target security.

        Uses simplified Core-SVP estimate:
        n ≈ target_bits / (0.265 · log₂(q/σ))
        """
        log_ratio = math.log2(3329 / 3.19)  # Kyber-like parameters
        return math.ceil(self.target_bits / (0.265 * log_ratio))

    def recommended_params(self) -> Dict[str, int]:
        """Recommended parameter set."""
        n = self.min_lattice_dimension()
        # Round up to power of 2 for Ring-LWE efficiency
        n_rounded = 2**math.ceil(math.log2(n))
        return {
            "dimension": n_rounded,
            "modulus": 3329,
            "classical_security": self.target_bits,
            "quantum_security": self.target_bits // 2,
            "public_key_bytes": n_rounded * 12 // 8,
            "ciphertext_bytes": n_rounded * 12 // 8 + 32,
        }

    def compare_nist_levels(self) -> str:
        """Compare all NIST security levels."""
        lines = ["NIST Security Level Comparison:"]
        lines.append(f"{'Level':>6} {'Bits':>6} {'Dim n':>8} {'PK (B)':>10} {'CT (B)':>10}")
        lines.append("-" * 45)
        for level, bits in self.NIST_LEVELS.items():
            selector = PostQuantumParameterSelector(bits)
            params = selector.recommended_params()
            lines.append(
                f"{level:>6} {bits:>6} {params['dimension']:>8} "
                f"{params['public_key_bytes']:>10} {params['ciphertext_bytes']:>10}"
            )
        return "\n".join(lines)


# ============================================================
# Application 2: ML Certified Robustness
# ============================================================

class CertifiedRobustnessAnalyzer:
    """Analyzes certified robustness of ML models using Lipschitz bounds.

    Connects information-theoretic capacity to robustness guarantees.

    Application: lipschitz_certified_robustness for neural_network safety.
    """

    def __init__(self, lipschitz_const: float, num_classes: int):
        self.L = lipschitz_const
        self.num_classes = num_classes

    def certified_radius(self, margin: float) -> float:
        """Certified ℓ₂ robustness radius."""
        return margin / self.L

    def entropy_capacity(self, epsilon: float) -> float:
        """Information-theoretic capacity within ε-ball.

        Maximum number of distinguishable inputs ≈ (L·ε)^d / d!
        For classification, bounded by number of classes.
        """
        return min(self.L * epsilon, self.num_classes)

    def accuracy_robustness_tradeoff(self, margins: List[float]) -> List[Tuple[float, float]]:
        """Compute accuracy-robustness tradeoff curve.

        For each margin value, compute the certified radius.
        Higher accuracy often requires smaller margins.
        """
        return [(m, self.certified_radius(m)) for m in margins]

    def report(self, test_margins: List[float]) -> str:
        """Generate robustness analysis report."""
        lines = [f"Certified Robustness Analysis (L={self.L}, classes={self.num_classes})"]
        lines.append(f"{'Margin':>10} {'Radius':>12} {'ε-capacity':>12}")
        lines.append("-" * 38)
        for m in test_margins:
            r = self.certified_radius(m)
            cap = self.entropy_capacity(r)
            lines.append(f"{m:>10.4f} {r:>12.6f} {cap:>12.4f}")
        return "\n".join(lines)


# ============================================================
# Application 3: Thermodynamic Computing Bounds
# ============================================================

class ThermodynamicComputer:
    """Computes energy bounds for information processing.

    Based on Landauer's principle: erasing 1 bit costs ≥ kT·ln(2).

    Application: hamiltonian computing energy analysis.
    """

    BOLTZMANN = 1.380649e-23  # J/K
    AVOGADRO = 6.022e23

    def __init__(self, temperature: float = 300.0):
        self.T = temperature
        self.kT = self.BOLTZMANN * temperature

    def landauer_energy_per_bit(self) -> float:
        """Minimum energy per bit erasure: kT·ln(2)."""
        return self.kT * math.log(2)

    def attack_energy_classical(self, key_bits: int) -> float:
        """Minimum energy for classical brute-force attack.

        Energy = 2^n · kT · ln(2) joules.
        """
        return 2**key_bits * self.landauer_energy_per_bit()

    def attack_energy_quantum(self, key_bits: int) -> float:
        """Minimum energy for quantum (Grover) attack.

        Energy = 2^(n/2) · kT · ln(2) joules.
        """
        return 2**(key_bits/2) * self.landauer_energy_per_bit()

    def reversible_computing_advantage(self, ops: int) -> Tuple[float, float]:
        """Compare irreversible vs reversible computing energy.

        Irreversible: ops · kT · ln(2)
        Reversible: can approach 0 (limited by control overhead)
        """
        irrev = ops * self.landauer_energy_per_bit()
        rev = 0.01 * irrev  # Rough estimate of practical reversible computing
        return (irrev, rev)

    def physical_limits_report(self) -> str:
        """Report on physical limits of computation."""
        lines = [f"Thermodynamic Computing Limits at T={self.T}K"]
        lines.append(f"kT = {self.kT:.4e} J")
        lines.append(f"Landauer bound = {self.landauer_energy_per_bit():.4e} J/bit")
        lines.append(f"\nEnergy for cryptographic attacks:")
        lines.append(f"{'Key bits':>10} {'Classical (J)':>15} {'Quantum (J)':>15} {'Sun output':>12}")
        lines.append("-" * 55)
        sun_power = 3.846e26  # W
        for n in [64, 128, 192, 256]:
            E_c = self.attack_energy_classical(n)
            E_q = self.attack_energy_quantum(n)
            sun_years = E_c / (sun_power * 3.15e7)
            lines.append(f"{n:>10} {E_c:>15.2e} {E_q:>15.2e} {sun_years:>12.2e} yr")
        return "\n".join(lines)


# ============================================================
# Application 4: Communication System Design
# ============================================================

class ChannelDesigner:
    """Designs communication systems using Shannon capacity bounds.

    Application: lattice_crypto communication efficiency.
    """

    def __init__(self, bandwidth_hz: float, noise_power_dbm: float):
        self.bandwidth = bandwidth_hz
        self.noise_power = 10**(noise_power_dbm/10) / 1000  # Convert dBm to W

    def capacity(self, signal_power_w: float) -> float:
        """Shannon capacity in bits/second.

        C = B · log₂(1 + P/N)
        """
        snr = signal_power_w / self.noise_power
        return self.bandwidth * math.log2(1 + snr)

    def required_snr(self, target_rate_bps: float) -> float:
        """Required SNR for target data rate.

        SNR = 2^(R/B) - 1
        """
        spectral_eff = target_rate_bps / self.bandwidth
        return 2**spectral_eff - 1

    def efficiency_report(self, powers: List[float]) -> str:
        """Generate channel efficiency report."""
        lines = [f"Channel Design: BW={self.bandwidth/1e6:.1f} MHz"]
        lines.append(f"{'Power (W)':>10} {'SNR (dB)':>10} {'Capacity':>15} {'Efficiency':>12}")
        lines.append("-" * 50)
        for P in powers:
            snr = P / self.noise_power
            C = self.capacity(P)
            eff = C / self.bandwidth  # bits/s/Hz
            lines.append(
                f"{P:>10.4f} {10*math.log10(snr):>10.1f} "
                f"{C/1e6:>12.2f} Mbps {eff:>8.2f} b/s/Hz"
            )
        return "\n".join(lines)


def main():
    print("=" * 60)
    print("  REAL-WORLD APPLICATIONS")
    print("=" * 60)

    # Post-quantum crypto
    print("\n" + "━" * 50)
    selector = PostQuantumParameterSelector(256)
    print(selector.compare_nist_levels())

    # ML robustness
    print("\n" + "━" * 50)
    analyzer = CertifiedRobustnessAnalyzer(10.0, 10)
    margins = [0.01, 0.05, 0.1, 0.5, 1.0, 2.0]
    print(analyzer.report(margins))

    # Thermodynamic bounds
    print("\n" + "━" * 50)
    thermo = ThermodynamicComputer()
    print(thermo.physical_limits_report())

    # Channel design
    print("\n" + "━" * 50)
    channel = ChannelDesigner(20e6, -90)  # 20 MHz, -90 dBm noise
    powers = [0.001, 0.01, 0.1, 1.0, 10.0]
    print(channel.efficiency_report(powers))

    print("\n" + "=" * 60)
    print("  Applications completed.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Information-Theoretic Cryptographic Security: Demonstrations

Concrete numerical examples illustrating the theorems from the
formal verification framework connecting entropy, cryptography,
lattice security, and machine learning.
"""

import math

def brute_force_cost(n: int) -> float:
    """Expected evaluations for brute-force search on n-bit key: 2^n / 2."""
    return 2**n / 2

def grover_cost(n: int) -> float:
    """Quantum search cost via Grover's algorithm: O(2^(n/2))."""
    return 2**(n/2)

def birthday_bound(n: int) -> float:
    """Birthday attack collision queries for n-bit hash: O(2^(n/2))."""
    return 2**(n/2)

def landauer_energy(n: int, kT: float = 4.11e-21) -> float:
    """Minimum energy to erase n bits at temperature T (default: room temp).
    E = n * kT * ln(2), where kT ≈ 4.11×10⁻²¹ J at 300K."""
    return n * kT * math.log(2)

def awgn_capacity(P: float, N: float) -> float:
    """AWGN channel capacity: C = (1/2) * log2(1 + P/N) bits per channel use."""
    return 0.5 * math.log2(1 + P / N)

def pac_sample_complexity(d: int, eps: float, delta: float) -> float:
    """PAC learning sample complexity: O(d/eps^2 + log(1/delta)/eps^2)."""
    return (d + math.log(1/delta)) / eps**2

def lipschitz_robustness_radius(L: float, margin: float) -> float:
    """Certified robustness radius = margin / Lipschitz constant."""
    return margin / L

def piling_up_bias(per_round_bias: float, rounds: int) -> float:
    """Piling-up lemma: total bias = (2*eps)^r / 2."""
    return (2 * per_round_bias)**rounds / 2

def linear_cryptanalysis_pairs(bias: float) -> float:
    """Known plaintext pairs needed for linear cryptanalysis: O(1/eps^2)."""
    return 1 / bias**2


def main():
    print("=" * 70)
    print("  INFORMATION-THEORETIC CRYPTOGRAPHIC SECURITY DEMONSTRATIONS")
    print("=" * 70)

    # 1. Brute-force vs Grover search
    print("\n━━━ 1. Brute-Force vs Quantum Search Complexity ━━━")
    print(f"{'Key bits':>10} {'Classical':>18} {'Quantum (Grover)':>18} {'Speedup':>10}")
    print("-" * 60)
    for n in [64, 128, 192, 256]:
        classical = brute_force_cost(n)
        quantum = grover_cost(n)
        print(f"{n:>10} {classical:>18.2e} {quantum:>18.2e} {classical/quantum:>10.2e}")

    # 2. Landauer energy bounds
    print("\n━━━ 2. Landauer Energy Bounds for Cryptographic Attacks ━━━")
    print(f"{'Key bits':>10} {'Energy (J)':>18} {'Energy (kWh)':>18}")
    print("-" * 50)
    for n in [128, 256, 512]:
        # Use log-scale computation to avoid overflow
        log10_E = n * math.log10(2) + math.log10(4.11e-21 * math.log(2))
        print(f"{n:>10} {'10^' + f'{log10_E:.1f}':>18} {'10^' + f'{log10_E - math.log10(3.6e6):.1f}':>18}")

    # 3. Birthday bound for hash functions
    print("\n━━━ 3. Birthday Bound for Hash Collision Resistance ━━━")
    print(f"{'Hash bits':>10} {'Collision queries':>20} {'Preimage queries':>20}")
    print("-" * 55)
    for n in [128, 160, 256, 384, 512]:
        print(f"{n:>10} {birthday_bound(n):>20.2e} {2.0**n:>20.2e}")

    # 4. AWGN Channel Capacity
    print("\n━━━ 4. AWGN Channel Capacity (Shannon Bound) ━━━")
    print(f"{'SNR (dB)':>10} {'P/N':>10} {'Capacity':>15}")
    print("-" * 40)
    for snr_db in [0, 3, 6, 10, 20, 30]:
        pn = 10**(snr_db/10)
        C = awgn_capacity(pn, 1.0)
        print(f"{snr_db:>10} {pn:>10.2f} {C:>15.4f} bits")

    # 5. PAC Learning Sample Complexity
    print("\n━━━ 5. PAC Learning Sample Complexity ━━━")
    print(f"{'VC dim':>8} {'epsilon':>10} {'delta':>10} {'Samples needed':>18}")
    print("-" * 50)
    for d in [10, 50, 100, 500]:
        for eps in [0.1, 0.01]:
            samples = pac_sample_complexity(d, eps, 0.05)
            print(f"{d:>8} {eps:>10.3f} {0.05:>10.3f} {samples:>18.0f}")

    # 6. Lipschitz Certified Robustness
    print("\n━━━ 6. Lipschitz Certified Robustness ━━━")
    print(f"{'Lipschitz L':>12} {'Margin γ':>10} {'Radius γ/L':>12}")
    print("-" * 38)
    for L in [1.0, 5.0, 10.0, 50.0, 100.0]:
        margin = 0.5
        r = lipschitz_robustness_radius(L, margin)
        print(f"{L:>12.1f} {margin:>10.3f} {r:>12.6f}")

    # 7. Piling-up Lemma for Linear Cryptanalysis
    print("\n━━━ 7. Piling-Up Lemma: Bias Decay in Block Ciphers ━━━")
    print(f"{'Rounds':>8} {'Bias/round':>12} {'Total bias':>15} {'Pairs needed':>15}")
    print("-" * 55)
    for bias in [0.25, 0.1, 0.05]:
        for r in [4, 8, 16]:
            total = piling_up_bias(bias, r)
            pairs = linear_cryptanalysis_pairs(total) if total > 0 else float('inf')
            print(f"{r:>8} {bias:>12.4f} {total:>15.2e} {pairs:>15.2e}")

    # 8. Entropy-Security Duality
    print("\n━━━ 8. Entropy-Security Duality ━━━")
    print(f"{'Min-entropy':>12} {'Guess prob':>15} {'Security bits':>15}")
    print("-" * 45)
    for k in [8, 16, 32, 64, 128, 256]:
        p_guess = 2**(-k)
        print(f"{k:>12} {p_guess:>15.2e} {k:>15}")

    # 9. LWE Parameters
    print("\n━━━ 9. Lattice-Based Cryptography Parameters ━━━")
    print(f"{'Dimension n':>12} {'Modulus q':>10} {'Key size (LWE)':>16} {'Key size (RLWE)':>17}")
    print("-" * 60)
    for n in [256, 512, 768, 1024]:
        q = 3329  # Kyber modulus
        log_q = math.ceil(math.log2(q))
        lwe_key = n * n * log_q  # bits
        rlwe_key = n * log_q  # bits
        print(f"{n:>12} {q:>10} {lwe_key:>16} {rlwe_key:>17}")

    print("\n" + "=" * 70)
    print("  All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Information-Theoretic Cryptographic Security

Generates charts and diagrams showing key mathematical relationships.
"""

import math

def generate_svg_security_comparison():
    """Generate SVG comparing classical vs quantum security levels."""
    width, height = 600, 400
    margin = 60

    key_sizes = [64, 128, 192, 256, 384, 512]
    classical = [2**(n/2) for n in key_sizes]  # normalized
    quantum = [2**(n/4) for n in key_sizes]  # Grover halves

    # Use log scale
    classical_log = [n for n in key_sizes]  # log2 of 2^n = n
    quantum_log = [n/2 for n in key_sizes]  # log2 of 2^(n/2) = n/2

    max_val = max(classical_log)
    plot_w = width - 2*margin
    plot_h = height - 2*margin

    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}">']
    svg.append('<rect width="100%" height="100%" fill="white"/>')

    # Title
    svg.append(f'<text x="{width/2}" y="25" text-anchor="middle" font-size="16" font-weight="bold">Classical vs Quantum Security Level</text>')

    # Axes
    svg.append(f'<line x1="{margin}" y1="{height-margin}" x2="{width-margin}" y2="{height-margin}" stroke="black" stroke-width="2"/>')
    svg.append(f'<line x1="{margin}" y1="{margin}" x2="{margin}" y2="{height-margin}" stroke="black" stroke-width="2"/>')

    # Labels
    svg.append(f'<text x="{width/2}" y="{height-10}" text-anchor="middle" font-size="12">Key Size (bits)</text>')
    svg.append(f'<text x="15" y="{height/2}" text-anchor="middle" font-size="12" transform="rotate(-90, 15, {height/2})">Security Level (bits)</text>')

    # Plot classical
    points_c = []
    points_q = []
    for i, n in enumerate(key_sizes):
        x = margin + (i / (len(key_sizes)-1)) * plot_w
        y_c = height - margin - (classical_log[i] / max_val) * plot_h
        y_q = height - margin - (quantum_log[i] / max_val) * plot_h
        points_c.append(f"{x},{y_c}")
        points_q.append(f"{x},{y_q}")

        # X-axis labels
        svg.append(f'<text x="{x}" y="{height-margin+20}" text-anchor="middle" font-size="10">{n}</text>')

    # Y-axis labels
    for v in [0, 128, 256, 384, 512]:
        y = height - margin - (v / max_val) * plot_h
        svg.append(f'<text x="{margin-5}" y="{y+4}" text-anchor="end" font-size="10">{v}</text>')
        svg.append(f'<line x1="{margin}" y1="{y}" x2="{width-margin}" y2="{y}" stroke="#eee" stroke-width="1"/>')

    # Lines
    svg.append(f'<polyline points="{" ".join(points_c)}" fill="none" stroke="#2196F3" stroke-width="3"/>')
    svg.append(f'<polyline points="{" ".join(points_q)}" fill="none" stroke="#F44336" stroke-width="3"/>')

    # Dots
    for p in points_c:
        x, y = p.split(',')
        svg.append(f'<circle cx="{x}" cy="{y}" r="5" fill="#2196F3"/>')
    for p in points_q:
        x, y = p.split(',')
        svg.append(f'<circle cx="{x}" cy="{y}" r="5" fill="#F44336"/>')

    # Legend
    svg.append(f'<rect x="{width-180}" y="40" width="160" height="50" fill="white" stroke="#ccc"/>')
    svg.append(f'<line x1="{width-170}" y1="55" x2="{width-140}" y2="55" stroke="#2196F3" stroke-width="3"/>')
    svg.append(f'<text x="{width-135}" y="59" font-size="11">Classical (n bits)</text>')
    svg.append(f'<line x1="{width-170}" y1="75" x2="{width-140}" y2="75" stroke="#F44336" stroke-width="3"/>')
    svg.append(f'<text x="{width-135}" y="79" font-size="11">Quantum (n/2 bits)</text>')

    svg.append('</svg>')
    return '\n'.join(svg)


def generate_svg_entropy_landscape():
    """Generate SVG showing the entropy-security-complexity triangle."""
    width, height = 500, 450

    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}">']
    svg.append('<rect width="100%" height="100%" fill="white"/>')

    # Title
    svg.append(f'<text x="{width/2}" y="25" text-anchor="middle" font-size="16" font-weight="bold">Entropy-Security-Complexity Triangle</text>')

    # Triangle vertices
    cx, cy = width/2, 250
    r = 150
    # Top: Entropy, Bottom-left: Security, Bottom-right: Complexity
    tx, ty = cx, cy - r  # top
    lx, ly = cx - r*0.866, cy + r*0.5  # bottom-left
    rx, ry = cx + r*0.866, cy + r*0.5  # bottom-right

    # Triangle
    svg.append(f'<polygon points="{tx},{ty} {lx},{ly} {rx},{ry}" fill="#E3F2FD" stroke="#1565C0" stroke-width="2"/>')

    # Labels
    svg.append(f'<text x="{tx}" y="{ty-15}" text-anchor="middle" font-size="14" font-weight="bold" fill="#1565C0">Entropy</text>')
    svg.append(f'<text x="{tx}" y="{ty-2}" text-anchor="middle" font-size="10" fill="#666">H(X) bits</text>')

    svg.append(f'<text x="{lx-10}" y="{ly+20}" text-anchor="middle" font-size="14" font-weight="bold" fill="#C62828">Security</text>')
    svg.append(f'<text x="{lx-10}" y="{ly+33}" text-anchor="middle" font-size="10" fill="#666">2⁻ⁿ advantage</text>')

    svg.append(f'<text x="{rx+10}" y="{ry+20}" text-anchor="middle" font-size="14" font-weight="bold" fill="#2E7D32">Complexity</text>')
    svg.append(f'<text x="{rx+10}" y="{ry+33}" text-anchor="middle" font-size="10" fill="#666">O(2ⁿ) ops</text>')

    # Edge labels
    mx_tl = (tx+lx)/2 - 30
    my_tl = (ty+ly)/2
    svg.append(f'<text x="{mx_tl}" y="{my_tl}" text-anchor="middle" font-size="9" fill="#555" transform="rotate(-60, {mx_tl}, {my_tl})">Min-entropy → Guessing</text>')

    mx_tr = (tx+rx)/2 + 30
    my_tr = (ty+ry)/2
    svg.append(f'<text x="{mx_tr}" y="{my_tr}" text-anchor="middle" font-size="9" fill="#555" transform="rotate(60, {mx_tr}, {my_tr})">Entropy → Search space</text>')

    mx_b = (lx+rx)/2
    my_b = (ly+ry)/2 + 15
    svg.append(f'<text x="{mx_b}" y="{my_b}" text-anchor="middle" font-size="9" fill="#555">Grover: O(2^(n/2))</text>')

    # Center annotation
    svg.append(f'<text x="{cx}" y="{cy}" text-anchor="middle" font-size="11" fill="#333">Information</text>')
    svg.append(f'<text x="{cx}" y="{cy+14}" text-anchor="middle" font-size="11" fill="#333">Duality</text>')

    # Application boxes
    apps = [
        (70, 390, "Crypto", "#E8EAF6"),
        (195, 390, "ML", "#E8F5E9"),
        (320, 390, "Physics", "#FFF3E0"),
        (445, 390, "Algebra", "#FCE4EC"),
    ]
    for x, y, label, color in apps:
        svg.append(f'<rect x="{x-35}" y="{y-12}" width="70" height="24" rx="4" fill="{color}" stroke="#999"/>')
        svg.append(f'<text x="{x}" y="{y+4}" text-anchor="middle" font-size="11">{label}</text>')

    # Arrows from triangle to apps
    svg.append(f'<text x="{width/2}" y="370" text-anchor="middle" font-size="10" fill="#888">Cross-Domain Bridges</text>')

    svg.append('</svg>')
    return '\n'.join(svg)


def generate_svg_bias_decay():
    """Generate SVG showing piling-up lemma bias decay."""
    width, height = 500, 350
    margin = 50

    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}">']
    svg.append('<rect width="100%" height="100%" fill="white"/>')
    svg.append(f'<text x="{width/2}" y="25" text-anchor="middle" font-size="14" font-weight="bold">Piling-Up Lemma: Bias Decay</text>')

    # Axes
    svg.append(f'<line x1="{margin}" y1="{height-margin}" x2="{width-margin}" y2="{height-margin}" stroke="black" stroke-width="1.5"/>')
    svg.append(f'<line x1="{margin}" y1="{margin}" x2="{margin}" y2="{height-margin}" stroke="black" stroke-width="1.5"/>')
    svg.append(f'<text x="{width/2}" y="{height-10}" text-anchor="middle" font-size="11">Number of Rounds</text>')
    svg.append(f'<text x="12" y="{height/2}" text-anchor="middle" font-size="11" transform="rotate(-90, 12, {height/2})">Total Bias (log scale)</text>')

    plot_w = width - 2*margin
    plot_h = height - 2*margin
    rounds = list(range(1, 17))
    colors = ["#2196F3", "#F44336", "#4CAF50", "#FF9800"]
    biases_list = [0.4, 0.3, 0.2, 0.1]

    for bi, eps in enumerate(biases_list):
        points = []
        for r in rounds:
            total = (2*eps)**r
            if total > 0:
                log_val = math.log10(total)
            else:
                log_val = -20
            x = margin + ((r-1) / (len(rounds)-1)) * plot_w
            # Map log_val from [-20, 0] to plot area
            y = height - margin - ((log_val + 20) / 20) * plot_h
            y = max(margin, min(height-margin, y))
            points.append(f"{x},{y}")
        svg.append(f'<polyline points="{" ".join(points)}" fill="none" stroke="{colors[bi]}" stroke-width="2"/>')

    # Legend
    for bi, eps in enumerate(biases_list):
        ly = 50 + bi * 18
        svg.append(f'<line x1="{width-140}" y1="{ly}" x2="{width-110}" y2="{ly}" stroke="{colors[bi]}" stroke-width="2"/>')
        svg.append(f'<text x="{width-105}" y="{ly+4}" font-size="10">ε = {eps}</text>')

    svg.append('</svg>')
    return '\n'.join(svg)


if __name__ == "__main__":
    # Generate and save SVGs
    with open("security_comparison.svg", "w") as f:
        f.write(generate_svg_security_comparison())
    print("Generated security_comparison.svg")

    with open("diagram.svg", "w") as f:
        f.write(generate_svg_entropy_landscape())
    print("Generated diagram.svg")

    with open("bias_decay.svg", "w") as f:
        f.write(generate_svg_bias_decay())
    print("Generated bias_decay.svg")
