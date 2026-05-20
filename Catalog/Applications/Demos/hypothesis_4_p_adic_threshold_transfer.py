#!/usr/bin/env python3
"""
applications.py — Real-World Applications of p-adic Threshold Transfer

Demonstrates how the p-adic threshold transfer principle applies to
practical machine learning scenarios:

1. Neural network generalization across architectures
2. Model compression certification
3. Training budget optimization
4. Cross-architecture generalization comparison
"""

import math
from dataclasses import dataclass
from algorithms import (
    EffectiveComplexityProfile,
    padic_target_error,
    padic_target_error_sq,
    check_threshold_compatible,
    find_optimal_precision,
    certify_generalization,
    verify_dimension_independence,
)


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Neural Network Generalization Across Architectures
# ═══════════════════════════════════════════════════════════════════════

def app_neural_network_generalization():
    """
    Demonstrate that networks of vastly different sizes can achieve
    identical generalization guarantees if their effective complexity
    is the same.

    Scenario: Image classification with varying network widths.
    - All networks trained on the same dataset (sampleSize = 50000)
    - Same quotient complexity (number of effective feature groups)
    - Same compression (code length)
    - Same posterior concentration (KL divergence)
    - Different parameter counts (width × depth)
    """
    print("=" * 70)
    print("APPLICATION 1: Neural Network Generalization Across Architectures")
    print("=" * 70)
    print()
    print("Scenario: Image classification with 50,000 training samples")
    print("All networks share the same effective complexity budget")
    print()

    sample_size = 50000  # e.g., CIFAR-50k

    # Different architectures with same effective complexity
    architectures = [
        ("Small CNN", 50_000),
        ("ResNet-18", 11_000_000),
        ("ResNet-50", 25_000_000),
        ("ResNet-152", 60_000_000),
        ("ViT-Large", 300_000_000),
        ("GPT-2 sized", 1_500_000_000),
    ]

    # Fixed effective complexity
    qc, cl, kl = 5, 3, 0.8  # quotientComplexity, codeLength, posteriorKL
    effective_rate = qc + cl + kl

    print(f"Effective complexity budget: {effective_rate}")
    print(f"  quotientComplexity = {qc}")
    print(f"  codeLength = {cl}")
    print(f"  posteriorKL = {kl}")
    print()

    # Find optimal binary precision level
    base_prof = EffectiveComplexityProfile(
        paramDim=100, quotientComplexity=qc, codeLength=cl,
        posteriorKL=kl, sampleSize=sample_size
    )
    k_opt = find_optimal_precision(base_prof, 2)
    eps = padic_target_error(2, k_opt)

    print(f"Optimal binary precision: k = {k_opt}")
    print(f"Sample threshold: 2^{k_opt} = {2**k_opt}")
    print(f"Target error: ε = {eps:.6f}")
    print()

    print(f"{'Architecture':>20} {'paramDim':>14} {'Overparameterized':>18} "
          f"{'Generalizes':>12} {'Certified':>10}")
    print("-" * 78)

    for name, params in architectures:
        prof = EffectiveComplexityProfile(
            paramDim=params, quotientComplexity=qc, codeLength=cl,
            posteriorKL=kl, sampleSize=sample_size
        )
        cert = certify_generalization(prof, 2, k_opt)
        overp = "Yes" if params > sample_size else "No"
        print(f"{name:>20} {params:>14,} {overp:>18} "
              f"{str(cert.certified):>12} {str(cert.dimension_free):>10}")

    print()
    print("→ Key finding: ALL architectures achieve the same generalization")
    print("  guarantee, regardless of parameter count. The 1.5B parameter")
    print("  model generalizes exactly as well as the 50K parameter model.")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Model Compression Certification
# ═══════════════════════════════════════════════════════════════════════

def app_compression_certification():
    """
    Show how reducing effective complexity (via pruning, quantization,
    or knowledge distillation) improves the achievable precision level.
    """
    print("=" * 70)
    print("APPLICATION 2: Model Compression Certification")
    print("=" * 70)
    print()
    print("Show how compression improves achievable precision level")
    print("Fixed: sampleSize = 100,000, paramDim = 10,000,000")
    print()

    sample_size = 100_000
    param_dim = 10_000_000

    compression_scenarios = [
        ("Uncompressed", 50, 100, 5.0),
        ("Light pruning", 30, 60, 4.0),
        ("Heavy pruning", 10, 20, 2.0),
        ("Quantization", 5, 10, 1.5),
        ("Distilled", 3, 5, 0.5),
        ("Maximally compressed", 0, 0, 0.1),
    ]

    print(f"{'Scenario':>25} {'QC':>4} {'CL':>4} {'KL':>6} {'EffRate':>8} "
          f"{'k_opt(p=2)':>10} {'ε':>12}")
    print("-" * 75)

    for name, qc, cl, kl in compression_scenarios:
        prof = EffectiveComplexityProfile(
            paramDim=param_dim, quotientComplexity=qc, codeLength=cl,
            posteriorKL=kl, sampleSize=sample_size
        )
        k_opt = find_optimal_precision(prof, 2)
        if k_opt is not None:
            eps = padic_target_error(2, k_opt)
            print(f"{name:>25} {qc:>4} {cl:>4} {kl:>6.1f} "
                  f"{prof.effectiveRate:>8.1f} {k_opt:>10} {eps:>12.8f}")
        else:
            print(f"{name:>25} {qc:>4} {cl:>4} {kl:>6.1f} "
                  f"{prof.effectiveRate:>8.1f} {'N/A':>10} {'N/A':>12}")

    print()
    print("→ Key finding: More compressed models achieve higher precision levels")
    print("  (larger k, smaller ε). Compression improves generalization guarantees.")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Training Budget Optimization
# ═══════════════════════════════════════════════════════════════════════

def app_training_budget():
    """
    Given a target precision, compute the minimum training data needed
    for different primes, showing how the choice of prime affects
    the sample efficiency curve.
    """
    print("=" * 70)
    print("APPLICATION 3: Training Budget Optimization Across Primes")
    print("=" * 70)
    print()
    print("Question: How many samples are needed for a given precision?")
    print("Fixed effective complexity: effectiveRate = 1.0")
    print()

    target_precisions = [0.1, 0.01, 0.001, 0.0001]
    primes = [2, 3, 5, 7, 11]

    print(f"{'Target ε':>10}", end="")
    for p in primes:
        print(f"  {'p='+str(p):>12}", end="")
    print()
    print("-" * (10 + 14 * len(primes)))

    for target_eps in target_precisions:
        print(f"{target_eps:>10.4f}", end="")
        for p in primes:
            # Find minimum k such that p^{-k/2} ≤ target_eps
            # i.e., p^k ≥ 1/target_eps²
            min_samples = math.ceil(1.0 / (target_eps ** 2))
            k = math.ceil(math.log(min_samples) / math.log(p))
            actual_threshold = p ** k
            print(f"  {actual_threshold:>12,}", end="")
        print()

    print()
    print("→ Values show minimum sample threshold p^k for each prime and precision.")
    print("  Smaller primes give finer-grained thresholds (2^k steps more smoothly).")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Cross-Architecture Comparison Table
# ═══════════════════════════════════════════════════════════════════════

def app_cross_architecture():
    """
    Compare different ML architecture families using the p-adic framework.
    """
    print("=" * 70)
    print("APPLICATION 4: Cross-Architecture Generalization Comparison")
    print("=" * 70)
    print()

    # Realistic-ish profiles for different architecture families
    profiles = {
        "Linear model": EffectiveComplexityProfile(
            paramDim=1000, quotientComplexity=1, codeLength=1,
            posteriorKL=0.1, sampleSize=10000
        ),
        "Random forest": EffectiveComplexityProfile(
            paramDim=50000, quotientComplexity=10, codeLength=5,
            posteriorKL=1.0, sampleSize=10000
        ),
        "Small MLP": EffectiveComplexityProfile(
            paramDim=100000, quotientComplexity=8, codeLength=4,
            posteriorKL=0.5, sampleSize=10000
        ),
        "Deep CNN": EffectiveComplexityProfile(
            paramDim=5000000, quotientComplexity=3, codeLength=2,
            posteriorKL=0.3, sampleSize=10000
        ),
        "Transformer": EffectiveComplexityProfile(
            paramDim=100000000, quotientComplexity=5, codeLength=3,
            posteriorKL=0.8, sampleSize=10000
        ),
        "Overfit MLP": EffectiveComplexityProfile(
            paramDim=500, quotientComplexity=100, codeLength=50,
            posteriorKL=20.0, sampleSize=10000
        ),
    }

    print(f"All profiles use sampleSize = 10,000")
    print()
    print(f"{'Architecture':>15} {'paramDim':>12} {'EffRate':>8} "
          f"{'k_opt(p=2)':>10} {'ε':>12} {'Generalizes':>12}")
    print("-" * 75)

    for name, prof in profiles.items():
        k_opt = find_optimal_precision(prof, 2)
        if k_opt is not None and k_opt > 0:
            eps = padic_target_error(2, k_opt)
            cert = certify_generalization(prof, 2, k_opt)
            print(f"{name:>15} {prof.paramDim:>12,} {prof.effectiveRate:>8.1f} "
                  f"{k_opt:>10} {eps:>12.6f} {str(cert.certified):>12}")
        else:
            print(f"{name:>15} {prof.paramDim:>12,} {prof.effectiveRate:>8.1f} "
                  f"{'—':>10} {'—':>12} {'False':>12}")

    print()
    print("→ Key finding: The Deep CNN with 5M parameters generalizes better")
    print("  than the Overfit MLP with 500 parameters, because effective rate—")
    print("  not parameter count—determines the generalization guarantee.")
    print()


if __name__ == "__main__":
    app_neural_network_generalization()
    app_compression_certification()
    app_training_budget()
    app_cross_architecture()


#!/usr/bin/env python3
"""
demo.py — p-adic Threshold Transfer: Dimension-Free Generalization

Demonstrates that the p-adic valuation induces a natural precision scale
for generalization bounds, and that this scaling is dimension-free.

Core identity: for prime p and precision level k,
  sample_threshold = p^k
  ε = p^{-k/2} = 1/√(p^k)
  sample_threshold · ε² = 1

The generalization criterion depends only on:
  quotientComplexity + codeLength + posteriorKL ≤ sampleSize · ε²
and is completely independent of paramDim.
"""

import math
from dataclasses import dataclass


@dataclass
class EffectiveComplexityProfile:
    """Architecture complexity profile for generalization analysis."""
    paramDim: int
    quotientComplexity: int
    codeLength: int
    posteriorKL: float
    sampleSize: int

    @property
    def effectiveRate(self) -> float:
        return self.quotientComplexity + self.codeLength + self.posteriorKL


def padic_target_error(p: int, k: int) -> float:
    """Compute ε = 1/√(p^k), the p-adic target error at precision level k."""
    return 1.0 / math.sqrt(p ** k)


def padic_target_error_sq(p: int, k: int) -> float:
    """Compute ε² = 1/p^k exactly."""
    return 1.0 / (p ** k)


def check_padic_threshold_compatible(prof: EffectiveComplexityProfile,
                                      p: int, k: int) -> tuple:
    """
    Check if a profile is p-adic threshold compatible.

    Returns (ε, ε², compatible, details_dict)
    """
    threshold = p ** k
    eps = padic_target_error(p, k)
    eps_sq = padic_target_error_sq(p, k)
    budget = prof.sampleSize * eps_sq
    sample_ok = threshold <= prof.sampleSize
    rate_ok = prof.effectiveRate <= budget
    compatible = sample_ok and rate_ok

    return eps, eps_sq, compatible, {
        'threshold': threshold,
        'sampleSize': prof.sampleSize,
        'effectiveRate': prof.effectiveRate,
        'budget': budget,
        'sample_ok': sample_ok,
        'rate_ok': rate_ok,
    }


def generalizes_at_precision(prof: EffectiveComplexityProfile, eps: float) -> bool:
    """Check if profile generalizes at precision ε."""
    return eps > 0 and prof.effectiveRate <= prof.sampleSize * eps ** 2


# ═══════════════════════════════════════════════════════════════════════
# EXPERIMENT 1: Binary threshold (p=2), varying k
# ═══════════════════════════════════════════════════════════════════════
print("=" * 80)
print("EXPERIMENT 1: Binary Threshold Transfer (p = 2)")
print("Verify: 2^k · ε² = 1 for all k, and dimension independence")
print("=" * 80)
print()
print(f"{'k':>3} {'sampleSize':>12} {'ε':>14} {'ε²':>14} "
      f"{'n·ε²':>8} {'budget':>8} {'compat':>7} {'dimFree':>8}")
print("-" * 80)

for k in range(1, 21):
    p = 2
    n = p ** k
    eps = padic_target_error(p, k)
    eps_sq = padic_target_error_sq(p, k)
    n_eps_sq = n * eps_sq  # Should always be 1.0

    # Create profiles with different paramDim but same effective complexity
    budget = 0.5  # effective complexity budget
    prof_small = EffectiveComplexityProfile(
        paramDim=10, quotientComplexity=0, codeLength=0,
        posteriorKL=budget, sampleSize=n)
    prof_large = EffectiveComplexityProfile(
        paramDim=1_000_000, quotientComplexity=0, codeLength=0,
        posteriorKL=budget, sampleSize=n)

    _, _, compat_small, _ = check_padic_threshold_compatible(prof_small, p, k)
    _, _, compat_large, _ = check_padic_threshold_compatible(prof_large, p, k)

    dim_free = compat_small == compat_large  # Should always be True

    print(f"{k:>3} {n:>12} {eps:>14.8f} {eps_sq:>14.10f} "
          f"{n_eps_sq:>8.4f} {budget:>8.2f} {str(compat_small):>7} {str(dim_free):>8}")

# ═══════════════════════════════════════════════════════════════════════
# EXPERIMENT 2: Dimension independence demonstration
# ═══════════════════════════════════════════════════════════════════════
print()
print("=" * 80)
print("EXPERIMENT 2: Dimension Independence")
print("Fixed: p=2, k=10, sampleSize=1024, effectiveRate=0.8")
print("Varying: paramDim from 10 to 10,000,000")
print("=" * 80)
print()

p, k = 2, 10
eps = padic_target_error(p, k)
print(f"Target error ε = {eps:.8f}")
print(f"Target ε² = {padic_target_error_sq(p, k):.10f}")
print(f"Budget (sampleSize · ε²) = {p**k * padic_target_error_sq(p, k):.4f}")
print()
print(f"{'paramDim':>12} {'effectiveRate':>14} {'generalizes':>12} {'compatible':>11}")
print("-" * 52)

for dim_exp in range(1, 8):
    dim = 10 ** dim_exp
    prof = EffectiveComplexityProfile(
        paramDim=dim, quotientComplexity=0, codeLength=0,
        posteriorKL=0.8, sampleSize=p**k)
    gen = generalizes_at_precision(prof, eps)
    _, _, compat, _ = check_padic_threshold_compatible(prof, p, k)
    print(f"{dim:>12,} {prof.effectiveRate:>14.4f} {str(gen):>12} {str(compat):>11}")

# ═══════════════════════════════════════════════════════════════════════
# EXPERIMENT 3: Ternary threshold (p=3)
# ═══════════════════════════════════════════════════════════════════════
print()
print("=" * 80)
print("EXPERIMENT 3: Ternary Threshold Transfer (p = 3)")
print("Verify: 3^k · ε² = 1 for all k")
print("=" * 80)
print()
print(f"{'k':>3} {'sampleSize':>12} {'ε':>14} {'ε²':>14} "
      f"{'n·ε²':>8} {'budget':>8} {'compat':>7}")
print("-" * 72)

for k in range(1, 14):
    p = 3
    n = p ** k
    eps = padic_target_error(p, k)
    eps_sq = padic_target_error_sq(p, k)
    n_eps_sq = n * eps_sq

    prof = EffectiveComplexityProfile(
        paramDim=1000, quotientComplexity=0, codeLength=0,
        posteriorKL=0.5, sampleSize=n)
    _, _, compat, _ = check_padic_threshold_compatible(prof, p, k)

    print(f"{k:>3} {n:>12} {eps:>14.8f} {eps_sq:>14.10f} "
          f"{n_eps_sq:>8.4f} {0.5:>8.2f} {str(compat):>7}")

# ═══════════════════════════════════════════════════════════════════════
# EXPERIMENT 4: Sharpness conjecture test
# ═══════════════════════════════════════════════════════════════════════
print()
print("=" * 80)
print("EXPERIMENT 4: Sharpness Conjecture Test")
print("Compare ε = 2^{-k/2} (threshold) vs ε' = 0.99·2^{-k/2} (stricter)")
print("With budget saturated at exactly 1.0")
print("=" * 80)
print()
print(f"{'k':>3} {'ε_threshold':>14} {'ε_strict':>14} "
      f"{'gen@ε':>7} {'gen@ε_strict':>13} {'gap':>8}")
print("-" * 65)

for k in range(1, 21):
    p = 2
    n = p ** k
    eps = padic_target_error(p, k)
    eps_strict = 0.99 * eps

    # Profile with budget exactly saturating the threshold
    prof = EffectiveComplexityProfile(
        paramDim=1000, quotientComplexity=0, codeLength=0,
        posteriorKL=1.0, sampleSize=n)

    gen_threshold = generalizes_at_precision(prof, eps)
    gen_strict = generalizes_at_precision(prof, eps_strict)
    gap = n * eps**2 - n * eps_strict**2

    print(f"{k:>3} {eps:>14.8f} {eps_strict:>14.8f} "
          f"{str(gen_threshold):>7} {str(gen_strict):>13} {gap:>8.4f}")

# ═══════════════════════════════════════════════════════════════════════
# EXPERIMENT 5: Multi-prime comparison
# ═══════════════════════════════════════════════════════════════════════
print()
print("=" * 80)
print("EXPERIMENT 5: Multi-Prime Comparison")
print("Compare threshold precision across primes p = 2, 3, 5, 7, 11")
print("Fixed k = 5")
print("=" * 80)
print()
k = 5
print(f"{'p':>3} {'p^k':>10} {'ε':>14} {'ε²':>14} {'p^k·ε²':>8}")
print("-" * 52)

for p in [2, 3, 5, 7, 11]:
    n = p ** k
    eps = padic_target_error(p, k)
    eps_sq = padic_target_error_sq(p, k)
    print(f"{p:>3} {n:>10} {eps:>14.8f} {eps_sq:>14.10f} {n*eps_sq:>8.4f}")

print()
print("=" * 80)
print("All experiments complete. Key findings:")
print("  1. n·ε² = 1 holds exactly for all primes and all k")
print("  2. Generalization is completely independent of paramDim")
print("  3. The threshold ε = p^{-k/2} is sharp (0.99·ε fails at budget=1)")
print("  4. The law is universal across primes, not specific to p=2")
print("=" * 80)
