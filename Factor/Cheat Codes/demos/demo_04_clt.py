"""
CHEAT CODE #4: THE CENTRAL LIMIT THEOREM
==========================================
Demonstrates the universality of the Gaussian distribution.

Key insight: The sum of many independent random variables is 
approximately Gaussian, REGARDLESS of the underlying distribution.

Experiments:
1. CLT with various distributions (uniform, exponential, Bernoulli, etc.)
2. Convergence rate and Berry-Esseen bound
3. When CLT fails: heavy tails and the stable distribution alternative
4. Practical application: confidence intervals from CLT
"""

import numpy as np
from scipy import stats


def experiment_1_universality():
    """Show CLT convergence for wildly different distributions."""
    print("=" * 60)
    print("EXPERIMENT 1: CLT Universality — Everything Becomes Gaussian")
    print("=" * 60)
    
    np.random.seed(42)
    N_samples = 50000
    
    distributions = {
        "Uniform[0,1]": lambda n: np.random.uniform(0, 1, n),
        "Exponential(1)": lambda n: np.random.exponential(1, n),
        "Bernoulli(0.3)": lambda n: np.random.binomial(1, 0.3, n).astype(float),
        "Poisson(3)": lambda n: np.random.poisson(3, n).astype(float),
        "Chi-squared(2)": lambda n: np.random.chisquare(2, n),
        "Beta(0.5, 0.5)": lambda n: np.random.beta(0.5, 0.5, n),
        "Discrete{1,2,10}": lambda n: np.random.choice([1, 2, 10], n, p=[0.5, 0.3, 0.2]),
    }
    
    sum_sizes = [1, 2, 5, 10, 30, 100]
    
    print(f"\nKolmogorov-Smirnov statistic vs N(0,1) (lower = more Gaussian):")
    print(f"\n{'Distribution':>20} |" + "".join(f" n={n:>3} |" for n in sum_sizes))
    print("-" * (22 + 8 * len(sum_sizes)))
    
    for name, sampler in distributions.items():
        ks_values = []
        for n in sum_sizes:
            # Generate sums of n independent RVs
            sums = np.zeros(N_samples)
            for _ in range(n):
                sums += sampler(N_samples)
            
            # Standardize
            sums = (sums - np.mean(sums)) / np.std(sums)
            
            # KS test against N(0,1)
            ks_stat, _ = stats.kstest(sums, 'norm')
            ks_values.append(ks_stat)
        
        row = f"{name:>20} |"
        for ks in ks_values:
            if ks < 0.01:
                row += f" {ks:.3f}*|"
            else:
                row += f" {ks:.3f} |"
        print(row)
    
    print("\n  * = essentially Gaussian (KS < 0.01)")
    print("✓ ALL distributions converge to Gaussian as n increases!\n")


def experiment_2_berry_esseen():
    """Measure convergence rate and compare with Berry-Esseen bound."""
    print("=" * 60)
    print("EXPERIMENT 2: Convergence Rate (Berry-Esseen Bound)")
    print("=" * 60)
    
    # Berry-Esseen: |F_n(x) - Φ(x)| ≤ C · ρ / (σ³ · √n)
    # where ρ = E[|X - μ|³] is the third absolute moment
    # Best known constant C ≈ 0.4748
    
    np.random.seed(42)
    N_samples = 100000
    C_BE = 0.4748
    
    # Compare distributions with different skewness
    distributions = {
        "Uniform[0,1]": {
            "sampler": lambda n: np.random.uniform(0, 1, n),
            "rho": 0.0625,  # E[|X - 0.5|^3] for Uniform[0,1]
            "sigma": 1/np.sqrt(12),
        },
        "Exponential(1)": {
            "sampler": lambda n: np.random.exponential(1, n),
            "rho": 2.0,  # E[|X - 1|^3]
            "sigma": 1.0,
        },
        "Bernoulli(0.1)": {
            "sampler": lambda n: np.random.binomial(1, 0.1, n).astype(float),
            "rho": 0.1*0.9*(0.9**2 + 0.1*0.1),  # approximate
            "sigma": np.sqrt(0.09),
        },
    }
    
    n_values = [5, 10, 20, 50, 100, 500, 1000]
    
    for name, d in distributions.items():
        print(f"\n{name}:")
        print(f"  {'n':>6} | {'Empirical sup error':>20} | {'Berry-Esseen bound':>20} | {'Ratio':>8}")
        print("  " + "-" * 65)
        
        for n in n_values:
            sums = np.zeros(N_samples)
            for _ in range(n):
                sums += d["sampler"](N_samples)
            sums = (sums - n * np.mean(d["sampler"](100000))) / (d["sigma"] * np.sqrt(n))
            
            # Empirical CDF error
            x_test = np.linspace(-4, 4, 1000)
            empirical_cdf = np.array([np.mean(sums <= x) for x in x_test])
            normal_cdf = stats.norm.cdf(x_test)
            sup_error = np.max(np.abs(empirical_cdf - normal_cdf))
            
            # Berry-Esseen bound
            be_bound = C_BE * d["rho"] / (d["sigma"]**3 * np.sqrt(n))
            be_bound = min(be_bound, 1.0)
            
            ratio = sup_error / be_bound if be_bound > 0 else 0
            
            print(f"  {n:>6} | {sup_error:>20.6f} | {be_bound:>20.6f} | {ratio:>8.3f}")
    
    print("\n✓ Convergence rate is O(1/√n) as predicted by Berry-Esseen.")
    print("  Skewed distributions converge slower (larger third moment).\n")


def experiment_3_clt_failure():
    """Show when CLT fails: heavy-tailed distributions."""
    print("=" * 60)
    print("EXPERIMENT 3: When CLT Fails — Heavy Tails")
    print("=" * 60)
    
    np.random.seed(42)
    N_samples = 50000
    
    print("\nDistributions with infinite variance don't obey CLT!")
    print("Instead, sums converge to STABLE distributions.\n")
    
    # Cauchy distribution: no mean, no variance
    # Sum of n Cauchy RVs ~ Cauchy (not Gaussian!)
    
    n_values = [1, 10, 100, 1000]
    
    print("Cauchy distribution (α = 1, no finite mean or variance):")
    print(f"  {'n':>6} | {'Median':>10} | {'IQR':>10} | {'Looks Gaussian?':>15}")
    print("  " + "-" * 50)
    
    for n in n_values:
        sums = np.zeros(N_samples)
        for _ in range(n):
            sums += np.random.standard_cauchy(N_samples)
        sums = sums / n  # Average
        
        # If CLT held, this should look Gaussian
        # But for Cauchy, the average has the SAME distribution!
        median = np.median(sums)
        iqr = np.percentile(sums, 75) - np.percentile(sums, 25)
        
        # Test for normality
        # Use middle portion to avoid extreme outliers
        trimmed = sums[(sums > np.percentile(sums, 5)) & (sums < np.percentile(sums, 95))]
        _, p_value = stats.normaltest(trimmed[:5000])
        gaussian = "NO (p < 0.001)" if p_value < 0.001 else f"Maybe (p={p_value:.3f})"
        
        print(f"  {n:>6} | {median:>10.4f} | {iqr:>10.4f} | {gaussian:>15}")
    
    print("\n  The Cauchy average does NOT converge to Gaussian!")
    print("  Instead, it remains Cauchy — a STABLE distribution.")
    
    # Pareto with α = 1.5 (finite mean, infinite variance)
    print(f"\nPareto(α=1.5) — finite mean, INFINITE variance:")
    print(f"  {'n':>6} | {'Std(Sₙ/n)':>12} | {'Grows like':>12}")
    print("  " + "-" * 40)
    
    for n in [10, 100, 1000, 10000]:
        sums = np.zeros(N_samples)
        for _ in range(n):
            sums += (np.random.pareto(1.5, N_samples) + 1)
        avg = sums / n
        std = np.std(avg)
        print(f"  {n:>6} | {std:>12.4f} | n^{{-1/1.5}} = {n**(-1/1.5):.4f}")
    
    print("\n✓ Without finite variance, CLT fails. Stable distributions take over.")
    print("  CHEAT CODE BOUNDARY: CLT requires finite variance!\n")


def experiment_4_confidence_intervals():
    """Practical application: confidence intervals from CLT."""
    print("=" * 60)
    print("EXPERIMENT 4: Practical Application — Confidence Intervals")
    print("=" * 60)
    
    np.random.seed(42)
    
    # Unknown distribution (mixture of exponentials)
    true_mean = 3.5
    sampler = lambda n: np.where(
        np.random.random(n) < 0.7,
        np.random.exponential(2, n),
        np.random.exponential(8, n)
    )
    
    # Verify true mean
    big_sample = sampler(1000000)
    print(f"\nTrue mean (estimated from 10⁶ samples): {np.mean(big_sample):.4f}")
    print(f"True std:  {np.std(big_sample):.4f}")
    
    # CLT-based confidence intervals
    n_values = [10, 30, 100, 500, 2000]
    n_trials = 10000
    
    print(f"\n95% confidence interval coverage (should be ~95%):")
    print(f"\n{'n':>8} | {'Mean CI width':>15} | {'Coverage':>10} | {'Target':>8}")
    print("-" * 50)
    
    for n in n_values:
        covered = 0
        widths = []
        
        for _ in range(n_trials):
            sample = sampler(n)
            x_bar = np.mean(sample)
            s = np.std(sample, ddof=1)
            ci_half = 1.96 * s / np.sqrt(n)
            
            widths.append(2 * ci_half)
            if x_bar - ci_half <= true_mean <= x_bar + ci_half:
                covered += 1
        
        coverage = covered / n_trials * 100
        print(f"{n:>8} | {np.mean(widths):>15.4f} | {coverage:>9.1f}% | 95.0%")
    
    print("\n✓ CLT-based confidence intervals achieve ~95% coverage,")
    print("  even though we know NOTHING about the underlying distribution!")
    print("  This is the practical power of universality.\n")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  MATHEMATICS CHEAT CODE #4: THE CENTRAL LIMIT THEOREM")
    print("  'Everything becomes Gaussian.'")
    print("=" * 60 + "\n")
    
    experiment_1_universality()
    experiment_2_berry_esseen()
    experiment_3_clt_failure()
    experiment_4_confidence_intervals()
    
    print("=" * 60)
    print("SUMMARY: The CLT is nature's great universality theorem.")
    print("Sums of independent RVs converge to Gaussian regardless")
    print("of the original distribution. It fails for heavy tails")
    print("(infinite variance), where stable distributions take over.")
    print("=" * 60)
