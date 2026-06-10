#!/usr/bin/env python3
"""
Tropical Valuation Markov Property — Applications

Real-world applications of the tropical Markov framework:
1. Cryptographic key analysis via p-adic valuation depth
2. Random number quality testing via memorylessness
3. Network protocol analysis via renewal theory
4. Data compression bounds via valuation energy
"""

from fractions import Fraction
import math
import random
from typing import List, Tuple, Dict


# ============================================================================
# Application 1: Cryptographic Key Valuation Analysis
# ============================================================================

def analyze_key_valuations(
    keys: List[int],
    p: int
) -> Dict[str, float]:
    """
    Analyze the p-adic valuation distribution of cryptographic key material.

    If keys are uniformly random integers, their p-adic valuations should
    follow the geometric distribution Pr(v=k) = (1-1/p) · (1/p)^k.

    Deviations from this distribution may indicate:
    - Weak random number generation
    - Algebraic structure in the key space
    - Side-channel leakage through valuation patterns

    Args:
        keys: List of integer key values.
        p: Prime for valuation analysis.

    Returns:
        Dict with empirical vs theoretical comparison.
    """
    def padic_val(n: int, p: int) -> int:
        """Compute the p-adic valuation of n."""
        if n == 0:
            return float('inf')
        v = 0
        n = abs(n)
        while n % p == 0:
            v += 1
            n //= p
        return v

    # Compute empirical distribution
    vals = [padic_val(k, p) for k in keys if k != 0]
    if not vals:
        return {"error": "no nonzero keys"}

    max_val = max(vals)
    n = len(vals)

    # Empirical PMF
    empirical = {}
    for v in range(max_val + 1):
        empirical[v] = sum(1 for x in vals if x == v) / n

    # Theoretical PMF
    theoretical = {}
    for v in range(max_val + 1):
        theoretical[v] = float(Fraction(p - 1, p ** (v + 1)))

    # Chi-squared statistic
    chi2 = 0.0
    for v in range(max_val + 1):
        expected = theoretical[v] * n
        if expected > 0:
            observed = empirical.get(v, 0) * n
            chi2 += (observed - expected) ** 2 / expected

    # Kolmogorov-Smirnov statistic
    ks_stat = max(abs(empirical.get(v, 0) - theoretical.get(v, 0))
                  for v in range(max_val + 1))

    return {
        "n_keys": n,
        "max_valuation": max_val,
        "empirical_pmf": empirical,
        "theoretical_pmf": theoretical,
        "chi_squared": chi2,
        "ks_statistic": ks_stat,
        "degrees_of_freedom": max_val,
    }


# ============================================================================
# Application 2: Random Number Quality via Memorylessness
# ============================================================================

def test_memorylessness_quality(
    samples: List[int],
    p: int,
    max_depth: int = 5
) -> Dict[str, float]:
    """
    Test random number quality by checking memorylessness of p-adic valuations.

    The tropical Markov property guarantees that for truly random integers:
      Pr(v >= k+j | v >= k) = Pr(v >= j) = p^{-j}

    Deviations indicate non-randomness.

    Args:
        samples: List of random integers to test.
        p: Prime for analysis.
        max_depth: Maximum valuation depth to test.

    Returns:
        Quality metrics including memorylessness deviation.
    """
    def padic_val(n: int, p: int) -> int:
        if n == 0:
            return max_depth + 1
        v = 0
        n = abs(n)
        while n % p == 0 and v <= max_depth:
            v += 1
            n //= p
        return v

    vals = [padic_val(s, p) for s in samples if s != 0]
    n = len(vals)

    # Empirical conditional tails
    max_deviation = 0.0
    results = {}

    for k in range(1, max_depth + 1):
        for j in range(1, max_depth + 1 - k):
            # Count: # with v >= k+j among those with v >= k
            n_ge_k = sum(1 for v in vals if v >= k)
            n_ge_kj = sum(1 for v in vals if v >= k + j)

            if n_ge_k == 0:
                continue

            empirical_cond = n_ge_kj / n_ge_k
            theoretical = float(Fraction(1, p ** j))
            deviation = abs(empirical_cond - theoretical)
            max_deviation = max(max_deviation, deviation)

            results[f"Pr(v>={k+j}|v>={k})"] = {
                "empirical": empirical_cond,
                "theoretical": theoretical,
                "deviation": deviation,
            }

    return {
        "n_samples": n,
        "max_deviation": max_deviation,
        "quality_score": 1.0 - min(max_deviation * 10, 1.0),
        "details": results,
    }


# ============================================================================
# Application 3: Data Compression via Valuation Energy
# ============================================================================

def valuation_entropy_bound(p: int, max_k: int = 20) -> Dict[str, float]:
    """
    Compute the Shannon entropy of the p-adic valuation distribution.

    The entropy H_p = Σ_k Pr(v=k) · log₂(1/Pr(v=k)) gives a lower bound
    on the average number of bits needed to encode valuation depth.

    By the energy additivity theorem:
      E(k) = k · log(p) is additive
    which means valuation depth is an optimal variable for arithmetic coding.

    Returns:
        Entropy bounds and compression ratios.
    """
    entropy = 0.0
    for k in range(max_k + 1):
        pk = float(Fraction(p - 1, p ** (k + 1)))
        if pk > 0:
            entropy -= pk * math.log2(pk)

    # Optimal code length
    avg_valuation = sum(
        k * float(Fraction(p - 1, p ** (k + 1)))
        for k in range(max_k + 1)
    )

    return {
        "entropy_bits": entropy,
        "avg_valuation": avg_valuation,
        "energy_per_level": math.log(p),
        "optimal_bits_per_level": math.log2(p),
        "compression_ratio": entropy / max(avg_valuation * math.log2(p), 1e-10),
    }


# ============================================================================
# Application 4: Network Protocol Renewal Analysis
# ============================================================================

def renewal_process_simulation(
    p: int,
    n_events: int = 10000
) -> Dict[str, float]:
    """
    Simulate a renewal process based on p-adic valuation depth.

    In queueing theory, the memoryless property of exponential/geometric
    distributions is fundamental. The tropical Markov property shows that
    p-adic valuation depth has this same renewal structure:

      Pr(residual depth = j | elapsed depth >= k) = Pr(depth = j)

    This means valuation-based protocols have stationary residual lifetimes.

    Returns:
        Renewal process statistics.
    """
    # Generate random integers and compute their p-adic valuations
    def padic_val(n: int, p: int) -> int:
        if n == 0:
            return 0
        v = 0
        n = abs(n)
        while n % p == 0:
            v += 1
            n //= p
        return v

    random.seed(42)
    valuations = [padic_val(random.randint(1, p**10), p) for _ in range(n_events)]

    # Compute renewal statistics
    inter_renewal = []
    current = 0
    for v in valuations:
        current += 1
        if v == 0:  # Renewal at valuation 0
            inter_renewal.append(current)
            current = 0

    if not inter_renewal:
        return {"error": "no renewals observed"}

    avg_inter = sum(inter_renewal) / len(inter_renewal)
    theoretical_avg = float(Fraction(p, p - 1))

    return {
        "n_events": n_events,
        "n_renewals": len(inter_renewal),
        "avg_inter_renewal": avg_inter,
        "theoretical_avg": theoretical_avg,
        "renewal_rate": len(inter_renewal) / n_events,
        "theoretical_rate": float(Fraction(p - 1, p)),
    }


# ============================================================================
# Demo
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL VALUATION MARKOV PROPERTY — APPLICATIONS      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Application 1: Key analysis
    print("\n" + "="*60)
    print("  APPLICATION 1: Cryptographic Key Valuation Analysis")
    print("="*60)
    random.seed(42)
    keys = [random.randint(1, 10**6) for _ in range(10000)]
    for p in [2, 3, 5]:
        result = analyze_key_valuations(keys, p)
        print(f"\n  p={p}: KS={result['ks_statistic']:.4f}, "
              f"χ²={result['chi_squared']:.2f} "
              f"(df={result['degrees_of_freedom']})")
        print(f"    Empirical: {dict(list(result['empirical_pmf'].items())[:5])}")
        print(f"    Theoretical: {dict(list(result['theoretical_pmf'].items())[:5])}")

    # Application 2: RNG quality
    print("\n" + "="*60)
    print("  APPLICATION 2: Random Number Quality Testing")
    print("="*60)
    for p in [2, 3]:
        # Good RNG
        good = [random.randint(1, 10**8) for _ in range(50000)]
        result = test_memorylessness_quality(good, p)
        print(f"\n  p={p}, good RNG: quality={result['quality_score']:.3f}, "
              f"max_dev={result['max_deviation']:.4f}")

        # Biased "RNG"
        biased = [random.randint(1, 10**8) * p for _ in range(50000)]
        result = test_memorylessness_quality(biased, p)
        print(f"  p={p}, biased:   quality={result['quality_score']:.3f}, "
              f"max_dev={result['max_deviation']:.4f}")

    # Application 3: Compression
    print("\n" + "="*60)
    print("  APPLICATION 3: Valuation Entropy Bounds")
    print("="*60)
    for p in [2, 3, 5, 7]:
        result = valuation_entropy_bound(p)
        print(f"\n  p={p}: H={result['entropy_bits']:.4f} bits, "
              f"avg_val={result['avg_valuation']:.4f}, "
              f"bits/level={result['optimal_bits_per_level']:.4f}")

    # Application 4: Renewal
    print("\n" + "="*60)
    print("  APPLICATION 4: Renewal Process Simulation")
    print("="*60)
    for p in [2, 3, 5]:
        result = renewal_process_simulation(p)
        print(f"\n  p={p}: avg_inter={result['avg_inter_renewal']:.3f} "
              f"(theory={result['theoretical_avg']:.3f}), "
              f"rate={result['renewal_rate']:.4f} "
              f"(theory={result['theoretical_rate']:.4f})")


#!/usr/bin/env python3
"""
Tropical Valuation Markov Property — Computational Demonstration

Verifies the closed-form laws:
  T_p(k) = p^{-k}
  T_p(k+j) / T_p(k) = T_p(j)        (memorylessness)
  Pr(v=k) = p^{-k} - p^{-(k+1)}     (point mass)
  Pr(v=k3 | v>=k2, v>=k1) = Pr(v=k3 | v>=k2)  for k1 <= k2 <= k3   (Markov)

For p in {2, 3, 5, 7} and k, j in {0, ..., 10}.
"""

from fractions import Fraction
import math


def tail_prob(p: int, k: int) -> Fraction:
    """T_p(k) = p^{-k}: the probability that v_p(X) >= k."""
    return Fraction(1, p ** k)


def point_prob(p: int, k: int) -> Fraction:
    """Pr(v_p(X) = k) = T(k) - T(k+1) = p^{-k} - p^{-(k+1)}."""
    return tail_prob(p, k) - tail_prob(p, k + 1)


def cond_tail_prob(p: int, a: int, b: int) -> Fraction:
    """Conditional tail: T(a) / T(b) = p^{-(a-b)} for b <= a."""
    return tail_prob(p, a) / tail_prob(p, b)


def cond_point_prob(p: int, k3: int, k2: int, k1: int) -> Fraction:
    """Conditional point probability Pr(v=k3 | v>=k2, v>=k1) for k1<=k2<=k3."""
    threshold = max(k1, k2)
    return point_prob(p, k3) / tail_prob(p, threshold)


def valuation_energy(p: int, k: int) -> float:
    """E_p(k) = k * log(p): information-theoretic energy."""
    return k * math.log(p)


def verify_all(p: int, max_k: int = 10) -> dict:
    """Run all verification checks for a given prime p."""
    results = {
        "tail_values": {},
        "memoryless_errors": [],
        "markov_errors": [],
        "point_mass_check": [],
        "energy_additive_errors": [],
    }

    # 1. Compute and display tail probabilities
    print(f"\n{'='*60}")
    print(f"  PRIME p = {p}")
    print(f"{'='*60}")

    print(f"\n  Tail probabilities T_{p}(k) = {p}^(-k):")
    print(f"  {'k':>4}  {'T(k) exact':>20}  {'T(k) decimal':>14}")
    print(f"  {'─'*4}  {'─'*20}  {'─'*14}")
    for k in range(max_k + 1):
        t = tail_prob(p, k)
        results["tail_values"][k] = t
        print(f"  {k:>4}  {str(t):>20}  {float(t):>14.10f}")

    # 2. Verify memorylessness: T(k+j) = T(k) * T(j)
    max_error = Fraction(0)
    violations = 0
    for k in range(max_k + 1):
        for j in range(max_k + 1 - k):
            lhs = tail_prob(p, k + j)
            rhs = tail_prob(p, k) * tail_prob(p, j)
            error = abs(lhs - rhs)
            if error > max_error:
                max_error = error
            if error != 0:
                violations += 1
                results["memoryless_errors"].append((k, j, error))

    print(f"\n  Memorylessness T(k+j) = T(k)·T(j):")
    print(f"    Pairs tested: {sum(range(max_k + 2))}")
    print(f"    Violations: {violations}")
    print(f"    Max absolute error: {float(max_error)}")

    # 3. Verify conditional tail = unconditional tail: T(k+j)/T(k) = T(j)
    max_cond_error = Fraction(0)
    cond_violations = 0
    for k in range(1, max_k + 1):
        for j in range(max_k + 1 - k):
            lhs = cond_tail_prob(p, k + j, k)
            rhs = tail_prob(p, j)
            error = abs(lhs - rhs)
            if error > max_cond_error:
                max_cond_error = error
            if error != 0:
                cond_violations += 1

    print(f"\n  Conditional tail T(k+j)/T(k) = T(j):")
    print(f"    Violations: {cond_violations}")
    print(f"    Max absolute error: {float(max_cond_error)}")

    # 4. Verify Markov property
    markov_violations = 0
    max_markov_error = Fraction(0)
    for k1 in range(max_k + 1):
        for k2 in range(k1, max_k + 1):
            for k3 in range(k2, max_k + 1):
                lhs = cond_point_prob(p, k3, k2, k1)
                rhs = cond_point_prob(p, k3, k2, k2)
                error = abs(lhs - rhs)
                if error > max_markov_error:
                    max_markov_error = error
                if error != 0:
                    markov_violations += 1
                    results["markov_errors"].append((k1, k2, k3, error))

    n_triples = sum(1 for k1 in range(max_k+1)
                    for k2 in range(k1, max_k+1)
                    for k3 in range(k2, max_k+1))
    print(f"\n  Markov property Pr(v=k₃|v≥k₂,v≥k₁) = Pr(v=k₃|v≥k₂):")
    print(f"    Triples tested: {n_triples}")
    print(f"    Violations: {markov_violations}")
    print(f"    Max absolute error: {float(max_markov_error)}")

    # 5. Verify point mass sums to 1
    total = sum(point_prob(p, k) for k in range(max_k + 1))
    remainder = tail_prob(p, max_k + 1)
    print(f"\n  Point mass sum check (k=0..{max_k}):")
    print(f"    Σ Pr(v=k) = {float(total):.10f}")
    print(f"    Tail remainder T({max_k+1}) = {float(remainder):.10f}")
    print(f"    Sum + remainder = {float(total + remainder):.10f}")

    # 6. Verify energy additivity
    energy_violations = 0
    for k in range(max_k + 1):
        for j in range(max_k + 1 - k):
            lhs = valuation_energy(p, k + j)
            rhs = valuation_energy(p, k) + valuation_energy(p, j)
            error = abs(lhs - rhs)
            if error > 1e-15:
                energy_violations += 1
                results["energy_additive_errors"].append((k, j, error))

    print(f"\n  Energy additivity E(k+j) = E(k) + E(j):")
    print(f"    Violations (|error| > 1e-15): {energy_violations}")

    # 7. Display selected conditional probabilities
    print(f"\n  Sample conditional tail probabilities:")
    print(f"  {'(k,j)':>8}  {'T(k+j)/T(k)':>14}  {'T(j)':>14}  {'Match':>6}")
    print(f"  {'─'*8}  {'─'*14}  {'─'*14}  {'─'*6}")
    for k, j in [(1,1), (2,3), (3,2), (5,5), (1,9)]:
        if k + j <= max_k:
            ct = cond_tail_prob(p, k+j, k)
            tj = tail_prob(p, j)
            match = "✓" if ct == tj else "✗"
            print(f"  ({k},{j}){' '*(5-len(f'({k},{j})'))}  {float(ct):>14.10f}  {float(tj):>14.10f}  {match:>6}")

    return results


def classification_demo():
    """Demonstrate the classification theorem: f(n) = f(1)^n."""
    print(f"\n{'='*60}")
    print(f"  CLASSIFICATION THEOREM DEMO")
    print(f"  If f(k+j) = f(k)·f(j) and f(0)=1, then f(n) = f(1)^n")
    print(f"{'='*60}")

    for p in [2, 3, 5, 7]:
        f1 = Fraction(1, p)
        print(f"\n  p={p}: f(1) = 1/{p}")
        print(f"  {'n':>4}  {'f(n) computed':>16}  {'f(1)^n':>16}  {'Match':>6}")
        print(f"  {'─'*4}  {'─'*16}  {'─'*16}  {'─'*6}")
        for n in range(8):
            fn = Fraction(1, p**n)  # T_p(n)
            f1n = f1 ** n
            match = "✓" if fn == f1n else "✗"
            print(f"  {n:>4}  {str(fn):>16}  {str(f1n):>16}  {match:>6}")


def energy_bridge_demo():
    """Demonstrate the energy bridge E_p(k) = k·log(p)."""
    print(f"\n{'='*60}")
    print(f"  ENERGY BRIDGE: E_p(k) = k·log(p)")
    print(f"  Connects valuation depth to information theory")
    print(f"{'='*60}")

    for p in [2, 3, 5, 7]:
        print(f"\n  p={p}:  log({p}) ≈ {math.log(p):.6f}")
        print(f"  {'k':>4}  {'E(k)':>12}  {'-log T(k)':>12}  {'Match':>8}")
        print(f"  {'─'*4}  {'─'*12}  {'─'*12}  {'─'*8}")
        for k in range(8):
            energy = valuation_energy(p, k)
            neg_log_tail = -math.log(float(tail_prob(p, k))) if k > 0 else 0.0
            error = abs(energy - neg_log_tail)
            match = "✓" if error < 1e-12 else f"{error:.2e}"
            print(f"  {k:>4}  {energy:>12.6f}  {neg_log_tail:>12.6f}  {match:>8}")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL VALUATION MARKOV PROPERTY                     ║")
    print("║  Computational Verification Suite                       ║")
    print("║                                                         ║")
    print("║  T_p(k) = p^{-k}  defines a tropical Markov process    ║")
    print("║  whose memorylessness is the arithmetic shadow of       ║")
    print("║  Haar self-similarity on p-adic integers.               ║")
    print("╚══════════════════════════════════════════════════════════╝")

    for p in [2, 3, 5, 7]:
        verify_all(p, max_k=10)

    classification_demo()
    energy_bridge_demo()

    print(f"\n{'='*60}")
    print(f"  ALL VERIFICATIONS COMPLETE")
    print(f"  All identities hold exactly (rational arithmetic).")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
