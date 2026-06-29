#!/usr/bin/env python3
"""
Algorithms for LWE Hardness Reduction Analysis

Type-hinted implementations of key algorithms related to the
worst-case to average-case reduction for Learning with Errors.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class LWEParams:
    """Parameters for an LWE instance."""
    n: int       # dimension
    q: int       # modulus
    m: int       # number of samples
    alpha: float # error rate

    @property
    def error_width(self) -> float:
        """Error width αq."""
        return self.alpha * self.q

    @property
    def approx_factor(self) -> float:
        """Approximation factor γ = n/(αq)."""
        return self.n / (self.alpha * self.q)

    def is_valid(self) -> bool:
        """Check basic validity constraints."""
        return (self.n > 0 and self.q > 1 and self.m > 0
                and 0 < self.alpha < 1)


@dataclass
class NoiseFloodingParams:
    """Parameters for the noise flooding lemma."""
    signal_bound: float  # B: max signal magnitude
    noise_width: float   # s: Gaussian width
    stat_distance: float # ε: statistical distance

    @property
    def flood_ratio(self) -> float:
        """s/B: how much noise overwhelms signal."""
        return self.noise_width / self.signal_bound

    def is_sufficient(self) -> bool:
        """Check s/B ≥ 1/ε."""
        return self.flood_ratio >= 1.0 / self.stat_distance


@dataclass
class ReductionChain:
    """Multi-step hardness reduction."""
    step_losses: List[float]

    @property
    def num_steps(self) -> int:
        return len(self.step_losses)

    @property
    def total_loss(self) -> float:
        return sum(self.step_losses)

    def advantage_bound(self, hard_problem_advantage: float) -> float:
        """Lower bound on LWE advantage given hard problem advantage."""
        return hard_problem_advantage - self.total_loss


def regev_parameter_selection(security_bits: int) -> LWEParams:
    """Select LWE parameters for a given security level.

    Uses Regev's parameter choices:
    - n ≈ security_bits (dimension)
    - q = next_prime(n²) (modulus)
    - α = 1/(n·√n) (error rate, giving αq ≈ √n)
    - m = O(n log q) (samples)

    Args:
        security_bits: Target security level in bits

    Returns:
        LWEParams with appropriate parameters
    """
    n = security_bits
    q = _next_prime(n * n)
    alpha = 1.0 / (n * math.sqrt(n))
    m = int(n * math.log2(q)) + 1
    return LWEParams(n=n, q=q, m=m, alpha=alpha)


def bkz_attack_cost(params: LWEParams) -> float:
    """Estimate BKZ attack cost in log₂ operations.

    Uses the Core-SVP methodology:
    1. Compute optimal BKZ blocksize β
    2. Cost ≈ 2^(0.292β) for classical, 2^(0.265β) for quantum

    Args:
        params: LWE parameters

    Returns:
        Estimated log₂ of classical attack cost
    """
    if params.alpha * params.q <= 1:
        return float('inf')

    log_q = math.log2(params.q)
    log_sigma = math.log2(params.alpha * params.q)

    if log_q <= log_sigma:
        return float('inf')

    # Optimal blocksize via Hermite factor δ
    beta = params.n * log_q / (log_q - log_sigma)
    return 0.292 * beta


def hybrid_advantage_telescope(
    hybrid_probs: List[float]
) -> Tuple[float, List[float]]:
    """Compute the hybrid argument telescope.

    Given hybrid probabilities [p₀, p₁, ..., pₙ], computes:
    1. Total advantage |p₀ - pₙ|
    2. Per-step advantages |pᵢ - pᵢ₊₁|

    Returns:
        (total_advantage, per_step_advantages)
    """
    n = len(hybrid_probs) - 1
    if n <= 0:
        return (0.0, [])

    steps = [abs(hybrid_probs[i] - hybrid_probs[i+1]) for i in range(n)]
    total = abs(hybrid_probs[0] - hybrid_probs[-1])
    return (total, steps)


def noise_flooding_construct(
    signal_bound: float,
    target_distance: float
) -> NoiseFloodingParams:
    """Construct noise flooding parameters to achieve target distance.

    Given signal bound B and target statistical distance ε,
    compute the required noise width s ≥ B/ε.

    Args:
        signal_bound: Maximum signal magnitude B
        target_distance: Target statistical distance ε

    Returns:
        NoiseFloodingParams with s = B/ε
    """
    noise_width = signal_bound / target_distance
    return NoiseFloodingParams(
        signal_bound=signal_bound,
        noise_width=noise_width,
        stat_distance=target_distance
    )


def reduction_chain_construct(
    n: int,
    quantum: bool = True
) -> ReductionChain:
    """Construct the Regev reduction chain.

    The reduction has 3 main steps:
    1. GapSVP → BDD (loss: negligible in n)
    2. BDD → LWE (loss: quantum sampling error, negligible)
    3. LWE → Decision-LWE (loss: n · ε per hybrid step)

    Args:
        n: Security parameter
        quantum: Whether to use quantum reduction

    Returns:
        ReductionChain with per-step loss estimates
    """
    # Step 1: Lattice problem to BDD
    step1_loss = 2.0 ** (-n)  # negligible

    # Step 2: BDD to LWE (quantum sampling)
    if quantum:
        step2_loss = 2.0 ** (-n)  # negligible quantum error
    else:
        step2_loss = 2.0 ** (-n/2)  # classical has larger error

    # Step 3: Search-to-decision hybrid (n steps, each negligible)
    step3_loss = n * (2.0 ** (-n))

    return ReductionChain(step_losses=[step1_loss, step2_loss, step3_loss])


def gaussian_tail_probability(t: float) -> float:
    """Upper bound on Gaussian tail: Pr[|X| > t·σ] ≤ exp(-π·t²)."""
    return math.exp(-math.pi * t * t)


def _next_prime(n: int) -> int:
    """Find the smallest prime ≥ n."""
    if n <= 2:
        return 2
    candidate = n if n % 2 == 1 else n + 1
    while not _is_prime(candidate):
        candidate += 2
    return candidate


def _is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    for i in range(3, int(math.sqrt(n)) + 1, 2):
        if n % i == 0:
            return False
    return True


# Example usage
if __name__ == "__main__":
    # Construct parameters for 128-bit security
    params = regev_parameter_selection(128)
    print(f"Parameters: n={params.n}, q={params.q}, m={params.m}, "
          f"α={params.alpha:.6f}")
    print(f"Error width αq = {params.error_width:.4f}")
    print(f"Approx factor γ = {params.approx_factor:.4f}")
    print(f"BKZ attack cost: 2^{bkz_attack_cost(params):.1f}")

    # Noise flooding
    nf = noise_flooding_construct(signal_bound=100.0, target_distance=1e-6)
    print(f"\nNoise flooding: B={nf.signal_bound}, s={nf.noise_width:.0f}, "
          f"ε={nf.stat_distance}")
    print(f"Flood ratio: {nf.flood_ratio:.0f}, sufficient: {nf.is_sufficient()}")

    # Reduction chain
    chain = reduction_chain_construct(128, quantum=True)
    print(f"\nReduction chain ({chain.num_steps} steps):")
    for i, loss in enumerate(chain.step_losses):
        print(f"  Step {i+1}: loss = {loss:.2e}")
    print(f"  Total loss: {chain.total_loss:.2e}")
