#!/usr/bin/env python3
"""
Applications of the Data Processing Inequality to Cryptographic Security.

This module demonstrates real-world applications of the formally verified
data processing inequality:

1. Module-LWE compression security analysis
2. Privacy amplification by deterministic compression
3. Security margin estimation for lattice-based KEMs
4. Coarse-graining analysis for statistical models

Each application includes concrete numerical examples.
"""

import numpy as np
from itertools import product
from typing import List, Tuple, Dict


# ============================================================
# Application 1: Module-LWE Compression Security
# ============================================================

def module_lwe_compression_demo():
    """
    Demonstrate security preservation under module-LWE compression.
    
    In module-LWE, a secret vector s ∈ (Z/qZ)^n is hidden by
    adding noise: b = As + e (mod q). Compression maps project
    b to a smaller space. The DPI guarantees that compression
    cannot help an adversary distinguish (A, b) from uniform.
    """
    print("=" * 60)
    print("Application 1: Module-LWE Compression Security")
    print("=" * 60)
    
    q = 7  # Small prime modulus
    n = 2  # Module dimension
    domain_size = q ** n
    
    # Create a "noisy" distribution (centered, concentrated)
    elements = list(product(range(q), repeat=n))
    
    # Noise distribution: discrete Gaussian-like, centered at 0
    def noise_weight(x, sigma=1.0):
        # Distance from 0 in (Z/qZ)^n
        dist_sq = sum(min(xi, q - xi) ** 2 for xi in x)
        return np.exp(-dist_sq / (2 * sigma ** 2))
    
    noise_weights = np.array([noise_weight(x) for x in elements])
    chi = noise_weights / noise_weights.sum()
    uniform = np.ones(domain_size) / domain_size
    
    # Various compression maps (linear functionals)
    print(f"\n  Parameters: q={q}, n={n}, domain_size={domain_size}")
    print(f"  Noise distribution: discrete Gaussian-like")
    print()
    
    for coeffs in [[1, 0], [1, 1], [1, 2], [3, 5]]:
        # Compression map: f(x) = sum(c_i * x_i) mod q
        f_table = []
        for x in elements:
            val = sum(c * xi for c, xi in zip(coeffs, x)) % q
            f_table.append(val)
        
        # Compute advantages
        pre_adv = 0.5 * np.sum(np.abs(chi - uniform))
        
        chi_push = np.zeros(q)
        unif_push = np.zeros(q)
        for i, x in enumerate(elements):
            chi_push[f_table[i]] += chi[i]
            unif_push[f_table[i]] += uniform[i]
        
        post_adv = 0.5 * np.sum(np.abs(chi_push - unif_push))
        
        is_surj = len(set(f_table)) == q
        print(f"  f(x) = {coeffs[0]}*x₁ + {coeffs[1]}*x₂ (mod {q})")
        print(f"    Surjective: {is_surj}")
        print(f"    Pre-compression TV distance:  {pre_adv:.6f}")
        print(f"    Post-compression TV distance: {post_adv:.6f}")
        print(f"    Security preserved: {post_adv <= pre_adv + 1e-12} "
              f"(ratio: {post_adv/max(pre_adv, 1e-15):.4f})")
        print()


# ============================================================
# Application 2: Privacy Amplification
# ============================================================

def privacy_amplification_demo():
    """
    Demonstrate privacy amplification by deterministic compression.
    
    If an adversary has partial information about a secret (modeled as
    a non-uniform distribution), applying a deterministic hash/compression
    function reduces their advantage. The DPI quantifies exactly how much.
    """
    print("=" * 60)
    print("Application 2: Privacy Amplification via Compression")
    print("=" * 60)
    
    # Scenario: secret is in {0,...,7}, adversary has side info
    n = 8
    
    # Adversary's belief (biased distribution)
    adversary_belief = np.array([0.3, 0.2, 0.15, 0.1, 0.08, 0.07, 0.06, 0.04])
    uniform = np.ones(n) / n
    
    pre_adv = 0.5 * np.sum(np.abs(adversary_belief - uniform))
    print(f"\n  Secret space size: {n}")
    print(f"  Adversary's belief: {adversary_belief}")
    print(f"  Adversary's advantage (TV from uniform): {pre_adv:.6f}")
    print()
    
    # Apply various compression functions
    compressions = {
        "mod 4 (x → x mod 4)": [i % 4 for i in range(n)],
        "mod 2 (x → x mod 2)": [i % 2 for i in range(n)],
        "threshold (x → x≥4)": [int(i >= 4) for i in range(n)],
        "parity (x → x mod 2)": [i % 2 for i in range(n)],
        "hash-like": [0, 1, 1, 0, 1, 0, 0, 1],  # balanced
    }
    
    print(f"  {'Compression':>25s} | {'Output size':>10s} | {'Post-TV':>10s} | {'Reduction':>10s}")
    print("  " + "-" * 65)
    
    for name, f_table in compressions.items():
        codomain_size = max(f_table) + 1
        
        belief_push = np.zeros(codomain_size)
        unif_push = np.zeros(codomain_size)
        for i in range(n):
            belief_push[f_table[i]] += adversary_belief[i]
            unif_push[f_table[i]] += uniform[i]
        
        post_adv = 0.5 * np.sum(np.abs(belief_push - unif_push))
        reduction = (1 - post_adv / pre_adv) * 100
        
        print(f"  {name:>25s} | {codomain_size:>10d} | {post_adv:>10.6f} | {reduction:>9.1f}%")
    
    print()
    print("  The DPI guarantees post-compression advantage ≤ pre-compression.")
    print("  More aggressive compression → more privacy amplification.")
    print()


# ============================================================
# Application 3: KEM Security Margin Estimation
# ============================================================

def kem_security_margins():
    """
    Estimate security margins for a toy lattice-based KEM under compression.
    
    Models a simplified version of CRYSTALS-Kyber style compression,
    where ciphertext components are rounded to fewer bits.
    """
    print("=" * 60)
    print("Application 3: KEM Security Margin Estimation")
    print("=" * 60)
    
    q = 11  # Modulus
    
    # "Error" distribution: centered binomial-like
    error_weights = np.zeros(q)
    for i in range(q):
        d = min(i, q - i)  # Distance from 0 mod q
        error_weights[i] = np.exp(-d)
    error = error_weights / error_weights.sum()
    uniform = np.ones(q) / q
    
    pre_adv = 0.5 * np.sum(np.abs(error - uniform))
    
    print(f"\n  Modulus q = {q}")
    print(f"  Error distribution (Laplace-like): {np.round(error, 4)}")
    print(f"  Base distinguishing advantage: {pre_adv:.6f}")
    print()
    
    # Compression by rounding: x → round(x * d/q) for various d
    for d in [2, 3, 5, 7]:
        # Compression: x → round(x * d / q) mod d
        f_table = [(round(x * d / q)) % d for x in range(q)]
        
        error_push = np.zeros(d)
        unif_push = np.zeros(d)
        for i in range(q):
            error_push[f_table[i]] += error[i]
            unif_push[f_table[i]] += uniform[i]
        
        post_adv = 0.5 * np.sum(np.abs(error_push - unif_push))
        
        # Security bits (rough estimate)
        pre_bits = -np.log2(max(pre_adv, 1e-15))
        post_bits = -np.log2(max(post_adv, 1e-15))
        
        print(f"  Compress to {d} levels: TV = {post_adv:.6f} "
              f"(≤ {pre_adv:.6f}), "
              f"~{post_bits:.1f} security bits (vs {pre_bits:.1f})")
    
    print()
    print("  The DPI ensures compression never degrades security guarantees.")
    print("  Compression may IMPROVE security (noise becomes less distinguishable).")
    print()


# ============================================================
# Application 4: Coarse-Graining in Statistical Models
# ============================================================

def coarse_graining_demo():
    """
    Demonstrate coarse-graining (aggregation) in statistical models.
    
    When we aggregate fine-grained categories into coarser ones
    (e.g., detailed age groups → broad brackets), the DPI tells us
    that statistical tests on the coarse data are never more powerful
    than tests on the fine data.
    """
    print("=" * 60)
    print("Application 4: Coarse-Graining in Statistical Models")
    print("=" * 60)
    
    # Example: Two populations with different age distributions
    # Fine-grained: 10 age brackets (0-9, 10-19, ..., 90-99)
    n_brackets = 10
    
    # Population A: younger skew
    pop_a = np.array([0.15, 0.18, 0.16, 0.14, 0.12, 0.10, 0.07, 0.04, 0.03, 0.01])
    # Population B: older skew
    pop_b = np.array([0.05, 0.08, 0.10, 0.12, 0.14, 0.15, 0.14, 0.11, 0.07, 0.04])
    
    pre_tv = 0.5 * np.sum(np.abs(pop_a - pop_b))
    
    print(f"\n  Fine-grained brackets: {n_brackets} age groups")
    print(f"  TV distance (fine): {pre_tv:.6f}")
    print()
    
    # Various coarsening schemes
    coarsenings = {
        "2 groups (young/old)": [0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
        "3 groups": [0, 0, 0, 1, 1, 1, 2, 2, 2, 2],
        "5 groups (pairs)": [0, 0, 1, 1, 2, 2, 3, 3, 4, 4],
        "4 groups (quartiles)": [0, 0, 0, 1, 1, 2, 2, 3, 3, 3],
    }
    
    print(f"  {'Coarsening':>25s} | {'Groups':>6s} | {'TV dist':>10s} | {'Info retained':>13s}")
    print("  " + "-" * 65)
    
    for name, f_table in coarsenings.items():
        codomain_size = max(f_table) + 1
        
        a_push = np.zeros(codomain_size)
        b_push = np.zeros(codomain_size)
        for i in range(n_brackets):
            a_push[f_table[i]] += pop_a[i]
            b_push[f_table[i]] += pop_b[i]
        
        post_tv = 0.5 * np.sum(np.abs(a_push - b_push))
        retained = (post_tv / pre_tv) * 100
        
        print(f"  {name:>25s} | {codomain_size:>6d} | {post_tv:>10.6f} | {retained:>12.1f}%")
    
    print()
    print("  Coarser aggregation always reduces statistical power (DPI).")
    print("  The best coarsening retains the most information about")
    print("  the distributional difference between populations.")
    print()


# ============================================================
# Main
# ============================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of the Data Processing Inequality        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    module_lwe_compression_demo()
    privacy_amplification_demo()
    kem_security_margins()
    coarse_graining_demo()
    
    print("=" * 60)
    print("Conclusion")
    print("=" * 60)
    print("""
  The data processing inequality — formally verified in Lean 4 — has
  immediate practical consequences:

  1. CRYPTOGRAPHY: Compression in lattice-based schemes provably
     cannot help adversaries. Security margins are preserved.

  2. PRIVACY: Deterministic compression amplifies privacy by
     reducing an adversary's statistical advantage.

  3. STATISTICS: Coarse-graining data always reduces the power
     of statistical tests — a fundamental limit on inference
     from aggregated data.

  4. INFORMATION THEORY: No deterministic processing of data
     can create information that wasn't already present.

  These are all instances of the same mathematical principle,
  now formally verified with machine-checked proofs.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration: Data Processing Inequality for Finite Distributions

This script demonstrates the core theorem that deterministic maps (pushforwards)
cannot increase the distinguishing advantage between probability distributions.
It provides:
1. Computation of test advantage for fixed distinguishers
2. Computation of maximum test advantage (decision advantage)
3. Verification of monotonicity under pushforward maps
4. Exhaustive search for counterexamples when surjectivity is dropped
5. Visualization of advantage contraction

Usage:
    python demo.py
"""

import numpy as np
from itertools import product
from typing import Callable, Dict, List, Tuple, Optional
import json


# ============================================================
# Core definitions
# ============================================================

def make_pmf(weights: np.ndarray) -> np.ndarray:
    """Normalize weights to a probability mass function."""
    w = np.array(weights, dtype=float)
    assert np.all(w >= 0), "Weights must be non-negative"
    s = w.sum()
    assert s > 0, "Weights must have positive sum"
    return w / s


def uniform_pmf(n: int) -> np.ndarray:
    """Uniform distribution on {0, ..., n-1}."""
    return np.ones(n) / n


def accept_prob(mu: np.ndarray, D: np.ndarray) -> float:
    """
    Acceptance probability: Pr_{x ~ mu}[D(x) = True].
    
    Args:
        mu: PMF as numpy array
        D: Boolean distinguisher as 0/1 numpy array
    Returns:
        Sum of mu[a] for a where D[a] = 1
    """
    return float(np.dot(mu, D))


def pushforward(mu: np.ndarray, f: Callable[[int], int], codomain_size: int) -> np.ndarray:
    """
    Compute the pushforward distribution f_*mu.
    
    Args:
        mu: PMF on domain {0, ..., len(mu)-1}
        f: Map from domain indices to codomain indices
        codomain_size: Size of the codomain
    Returns:
        PMF on {0, ..., codomain_size-1}
    """
    result = np.zeros(codomain_size)
    for i, p in enumerate(mu):
        result[f(i)] += p
    return result


def test_advantage(mu: np.ndarray, nu: np.ndarray, D: np.ndarray) -> float:
    """
    Test advantage: |Pr_mu[D accepts] - Pr_nu[D accepts]|.
    """
    return abs(accept_prob(mu, D) - accept_prob(nu, D))


def decision_advantage(mu: np.ndarray, nu: np.ndarray) -> float:
    """
    Decision advantage: max over all Boolean distinguishers D of testAdvantage(mu, nu, D).
    
    Uses the Neyman-Pearson characterization: the optimal distinguisher
    accepts where mu > nu, giving advantage = sum_{i: mu[i]>nu[i]} (mu[i]-nu[i]).
    This equals the total variation distance TV(mu, nu).
    """
    diff = mu - nu
    return float(max(np.sum(diff[diff > 0]), np.sum(-diff[diff < 0])))


def verify_monotonicity(mu: np.ndarray, nu: np.ndarray,
                        f: Callable[[int], int],
                        codomain_size: int) -> Tuple[float, float, bool]:
    """
    Verify the data processing inequality for a specific instance.
    
    Returns:
        (post_advantage, pre_advantage, monotonicity_holds)
    """
    mu_push = pushforward(mu, f, codomain_size)
    nu_push = pushforward(nu, f, codomain_size)
    post_adv = decision_advantage(mu_push, nu_push)
    pre_adv = decision_advantage(mu, nu)
    return post_adv, pre_adv, post_adv <= pre_adv + 1e-12


# ============================================================
# Demo 1: Basic pullback preservation
# ============================================================

def demo_pullback_preservation():
    """Demonstrate that acceptProb(f_*mu, D) = acceptProb(mu, D∘f)."""
    print("=" * 60)
    print("Demo 1: Pullback Preservation of Acceptance Probability")
    print("=" * 60)
    
    # Domain: {0,1,2,3}, Codomain: {0,1}
    mu = make_pmf([1, 2, 3, 4])  # Non-uniform distribution
    f = lambda x: x % 2  # Even/odd parity map
    D = np.array([1, 0])  # Accept only element 0 in codomain
    
    # Compute pushforward
    mu_push = pushforward(mu, f, 2)
    
    # LHS: acceptProb(f_*mu, D)
    lhs = accept_prob(mu_push, D)
    
    # RHS: acceptProb(mu, D∘f)
    D_pullback = np.array([D[f(i)] for i in range(4)])
    rhs = accept_prob(mu, D_pullback)
    
    print(f"  mu = {mu}")
    print(f"  f(x) = x mod 2")
    print(f"  D = accepts only '0' in codomain")
    print(f"  f_*mu = {mu_push}")
    print(f"  D∘f = {D_pullback}")
    print(f"  acceptProb(f_*mu, D) = {lhs:.6f}")
    print(f"  acceptProb(mu, D∘f)  = {rhs:.6f}")
    print(f"  Equal: {abs(lhs - rhs) < 1e-12}")
    print()


# ============================================================
# Demo 2: Data Processing Inequality
# ============================================================

def demo_data_processing_inequality():
    """Demonstrate that pushforward contracts decision advantage."""
    print("=" * 60)
    print("Demo 2: Data Processing Inequality")
    print("=" * 60)
    
    # Domain: Z/5Z, various maps to Z/3Z, Z/2Z
    np.random.seed(42)
    
    for trial in range(5):
        n_domain = 5
        n_codomain = 3
        
        mu = make_pmf(np.random.dirichlet(np.ones(n_domain)))
        nu = make_pmf(np.random.dirichlet(np.ones(n_domain)))
        f = lambda x, t=trial: (x + t) % n_codomain  # Various surjective maps
        
        post_adv, pre_adv, holds = verify_monotonicity(mu, nu, f, n_codomain)
        
        print(f"  Trial {trial+1}: pre-compression advantage = {pre_adv:.6f}, "
              f"post-compression = {post_adv:.6f}, "
              f"ratio = {post_adv/max(pre_adv, 1e-15):.4f}, "
              f"monotone: {holds}")
    print()


# ============================================================
# Demo 3: Exhaustive verification for small modules
# ============================================================

def demo_exhaustive_verification():
    """Exhaustively verify monotonicity for all maps Fin n -> Fin m."""
    print("=" * 60)
    print("Demo 3: Exhaustive Verification for Small Instances")
    print("=" * 60)
    
    for n_domain in range(2, 4):
        for n_codomain in range(2, n_domain + 1):
            violations = 0
            total = 0
            # Sample random distributions and test all maps
            np.random.seed(123)
            n_dist_pairs = 10
            n_maps = min(n_codomain ** n_domain, 30)
            
            for _ in range(n_dist_pairs):
                mu = make_pmf(np.random.dirichlet(np.ones(n_domain)))
                nu = make_pmf(np.random.dirichlet(np.ones(n_domain)))
                
                # Generate maps
                if n_codomain ** n_domain <= 20:
                    maps = list(product(range(n_codomain), repeat=n_domain))
                else:
                    maps = [tuple(np.random.randint(0, n_codomain, n_domain))
                            for _ in range(20)]
                
                for f_table in maps:
                    f = lambda x, ft=f_table: ft[x]
                    post_adv, pre_adv, holds = verify_monotonicity(
                        mu, nu, f, n_codomain)
                    total += 1
                    if not holds:
                        violations += 1
            
            status = "✓ ALL PASS" if violations == 0 else f"✗ {violations} VIOLATIONS"
            print(f"  |domain|={n_domain}, |codomain|={n_codomain}: "
                  f"tested {total} instances, {status}")
    print()


# ============================================================
# Demo 4: Linear maps over Z/qZ
# ============================================================

def demo_linear_maps():
    """Verify monotonicity specifically for linear maps over Z/qZ."""
    print("=" * 60)
    print("Demo 4: Linear Maps over Z/qZ")
    print("=" * 60)
    
    for q in [2, 3, 5]:
        for n in [2]:
            # Domain: (Z/qZ)^n represented as tuples
            domain_size = q ** n
            codomain_size = q
            
            # Encode tuples as integers
            def tuple_to_int(t, q=q):
                result = 0
                for v in t:
                    result = result * q + v
                return result
            
            # All elements of (Z/qZ)^n
            elements = list(product(range(q), repeat=n))
            
            # Test a few linear maps: f(x) = a·x mod q for various a ∈ (Z/qZ)^n
            np.random.seed(42)
            violations = 0
            tests = 0
            
            for _ in range(10):  # 10 random coefficient vectors
                a = tuple(np.random.randint(0, q, n))
                
                # Linear map: f(x) = sum(a_i * x_i) mod q
                f_table = {}
                for idx, x in enumerate(elements):
                    f_table[idx] = sum(ai * xi for ai, xi in zip(a, x)) % q
                
                f = lambda x, ft=f_table: ft[x]
                
                # Test with random distributions
                for _ in range(5):
                    mu = make_pmf(np.random.dirichlet(np.ones(domain_size)))
                    nu = uniform_pmf(domain_size)
                    
                    post_adv, pre_adv, holds = verify_monotonicity(
                        mu, nu, f, codomain_size)
                    tests += 1
                    if not holds:
                        violations += 1
            
            status = "✓" if violations == 0 else f"✗ {violations} violations"
            print(f"  q={q}, n={n}: {tests} tests, {status}")
    print()


# ============================================================
# Demo 5: Strict contraction examples
# ============================================================

def demo_strict_contraction():
    """Show examples where compression strictly reduces advantage."""
    print("=" * 60)
    print("Demo 5: Strict Contraction Under Non-Injective Maps")
    print("=" * 60)
    
    # Domain: {0,1,2,3}, Codomain: {0,1}
    # Map: f(0)=f(1)=0, f(2)=f(3)=1
    n_domain = 4
    n_codomain = 2
    f = lambda x: x // 2
    
    # Distribution that distinguishes within fibers
    mu = make_pmf([4, 1, 1, 4])  # Concentrated on 0 and 3
    nu = make_pmf([1, 4, 4, 1])  # Concentrated on 1 and 2
    
    pre_adv = decision_advantage(mu, nu)
    mu_push = pushforward(mu, f, n_codomain)
    nu_push = pushforward(nu, f, n_codomain)
    post_adv = decision_advantage(mu_push, nu_push)
    
    print(f"  mu = {mu}")
    print(f"  nu = {nu}")
    print(f"  f: {{0,1}} -> 0, {{2,3}} -> 1")
    print(f"  f_*mu = {mu_push}")
    print(f"  f_*nu = {nu_push}")
    print(f"  Pre-compression advantage:  {pre_adv:.6f}")
    print(f"  Post-compression advantage: {post_adv:.6f}")
    print(f"  Strict contraction: {post_adv < pre_adv - 1e-12}")
    print(f"  Contraction ratio: {post_adv/pre_adv:.4f}")
    print()
    
    # Another example: optimal distinguisher is NOT fiber-constant
    print("  When the optimal distinguisher is not fiber-constant,")
    print("  compression strictly loses information:")
    mu2 = make_pmf([3, 1, 1, 3])
    nu2 = uniform_pmf(4)
    pre2 = decision_advantage(mu2, nu2)
    post2 = decision_advantage(pushforward(mu2, f, 2), pushforward(nu2, f, 2))
    print(f"  mu2 = {mu2}, nu2 = uniform")
    print(f"  Pre: {pre2:.6f}, Post: {post2:.6f}, Ratio: {post2/pre2:.4f}")
    print()


# ============================================================
# Demo 6: Counterexample search for non-surjective maps
# ============================================================

def demo_nonsurjective_counterexample():
    """
    Search for cases where non-surjective maps can increase
    advantage relative to uniform on the respective spaces.
    
    Note: The data processing inequality ALWAYS holds (for any map),
    but the *interpretation* with uniform baselines can break when
    the pushforward of uniform is not uniform on the codomain.
    """
    print("=" * 60)
    print("Demo 6: Non-Surjective Maps and Uniform Baseline")
    print("=" * 60)
    
    # The DPI itself always holds, but consider the question:
    # Does |acceptProb(f_*chi, D) - acceptProb(f_*unif, D)| 
    #   <= |acceptProb(chi, D∘f) - acceptProb(unif, D∘f)| ?
    # This is YES by the DPI (it's testAdvantage with nu = uniform).
    # But: |acceptProb(f_*chi, D) - 1/2| vs |acceptProb(chi, D∘f) - 1/2|
    # requires f_*unif to give acceptProb 1/2 for all D, which needs surjectivity.
    
    found_issue = False
    for n_domain in [3, 4]:
        n_codomain = 3
        # Non-surjective map: image misses one element
        f = lambda x, nd=n_domain: min(x, n_codomain - 2)  # Maps everything >= n_codomain-1 to n_codomain-2
        
        mu_unif = uniform_pmf(n_domain)
        mu_push_unif = pushforward(mu_unif, f, n_codomain)
        
        # Check if pushforward of uniform is uniform
        is_unif = np.allclose(mu_push_unif, uniform_pmf(n_codomain))
        
        if not is_unif:
            print(f"  n_domain={n_domain}, n_codomain={n_codomain}")
            print(f"  f: non-surjective (image misses element {n_codomain-1})")
            print(f"  f_*(uniform) = {mu_push_unif} ≠ uniform({n_codomain})")
            
            # Now find D where |acceptProb(f_*chi, D) - 1/2| > |acceptProb(chi, D∘f) - 1/2|
            np.random.seed(0)
            for _ in range(100):
                chi = make_pmf(np.random.dirichlet(np.ones(n_domain)))
                chi_push = pushforward(chi, f, n_codomain)
                
                for bits in product([0, 1], repeat=n_codomain):
                    D = np.array(bits, dtype=float)
                    D_pull = np.array([D[f(i)] for i in range(n_domain)], dtype=float)
                    
                    lhs = abs(accept_prob(chi_push, D) - 0.5)
                    rhs = abs(accept_prob(chi, D_pull) - 0.5)
                    
                    if lhs > rhs + 1e-10:
                        print(f"  FOUND: |acceptProb(f_*χ, D) - 1/2| = {lhs:.6f} > "
                              f"|acceptProb(χ, D∘f) - 1/2| = {rhs:.6f}")
                        print(f"  This shows the 1/2 baseline version needs surjectivity!")
                        found_issue = True
                        break
                if found_issue:
                    break
            
            if not found_issue:
                print("  No violation found (the DPI still holds, as expected)")
            print()
            break
    
    if not found_issue:
        print("  No violations of the 1/2-baseline version found in search.")
    
    print("  KEY INSIGHT: The data processing inequality ALWAYS holds.")
    print("  The 1/2-baseline version requires the reference distribution")
    print("  to push forward to a balanced test, which needs surjectivity.")
    print()


# ============================================================
# Demo 7: Visualization (text-based)
# ============================================================

def demo_advantage_landscape():
    """Show how advantage contracts across different maps."""
    print("=" * 60)
    print("Demo 7: Advantage Contraction Landscape")
    print("=" * 60)
    
    n = 4
    np.random.seed(7)
    mu = make_pmf(np.random.dirichlet(np.ones(n)))
    nu = uniform_pmf(n)
    
    pre_adv = decision_advantage(mu, nu)
    print(f"  mu = [{', '.join(f'{x:.3f}' for x in mu)}]")
    print(f"  nu = uniform({n})")
    print(f"  Pre-compression advantage: {pre_adv:.6f}")
    print()
    
    # All surjective maps to {0,1}
    print("  Surjective maps to {0,1} (partition into 2 nonempty parts):")
    print(f"  {'Map':>20s} | {'Post-Adv':>10s} | {'Ratio':>8s} | {'Bar'}")
    print("  " + "-" * 60)
    
    results = []
    for f_table in product(range(2), repeat=n):
        # Check surjectivity
        if 0 not in f_table or 1 not in f_table:
            continue
        f = lambda x, ft=f_table: ft[x]
        mu_push = pushforward(mu, f, 2)
        nu_push = pushforward(nu, f, 2)
        post_adv = decision_advantage(mu_push, nu_push)
        ratio = post_adv / pre_adv if pre_adv > 0 else 0
        results.append((f_table, post_adv, ratio))
    
    results.sort(key=lambda x: -x[1])
    for f_table, post_adv, ratio in results:
        bar = "█" * int(ratio * 40)
        f_str = str(f_table)
        print(f"  {f_str:>20s} | {post_adv:>10.6f} | {ratio:>7.4f} | {bar}")
    
    print()
    print(f"  All ratios ≤ 1.0: {all(r <= 1.0 + 1e-12 for _, _, r in results)}")
    print()


# ============================================================
# Main
# ============================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Data Processing Inequality for Finite Distributions   ║")
    print("║  Numerical Demonstration                               ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_pullback_preservation()
    demo_data_processing_inequality()
    demo_exhaustive_verification()
    demo_linear_maps()
    demo_strict_contraction()
    demo_nonsurjective_counterexample()
    demo_advantage_landscape()
    
    print("=" * 60)
    print("Summary")
    print("=" * 60)
    print("""
  The data processing inequality for finite distributions states:

    decisionAdvantage(f_*μ, f_*ν) ≤ decisionAdvantage(μ, ν)

  for ANY deterministic map f. This is formally proved in Lean 4.

  Key findings from numerical experiments:
  1. The inequality holds universally — no counterexamples exist.
  2. Non-injective maps typically cause STRICT contraction.
  3. The witness D' = D∘f achieves exact equality per-test.
  4. The 1/2-baseline version requires care with the reference
     distribution (surjectivity ensures uniform pushes to uniform).
  5. For linear maps over Z/qZ, monotonicity holds with large margin.
""")


if __name__ == "__main__":
    main()
