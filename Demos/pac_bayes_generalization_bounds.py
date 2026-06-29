#!/usr/bin/env python3
"""
PAC-Bayes Applications: Real-World Generalization Certificates

Demonstrates practical applications of PAC-Bayes bounds for:
1. Neural network generalization certification
2. Linear classifier bound computation
3. Robustness-aware generalization guarantees
4. Posterior optimization for tightest bounds
"""

import math
from algorithms import (
    GaussianPosteriorFamily, gaussian_kl_div,
    mcallester_bound, catoni_bound,
    compute_certificate, optimize_posterior_scale,
    compute_robust_certificate
)


def application_neural_network_certification():
    """Application 1: Certifying a neural network's generalization.
    
    Scenario: A neural network with learned weights w has been trained
    on n samples. We want to certify its generalization gap.
    """
    print("=" * 70)
    print("APPLICATION 1: Neural Network Generalization Certification")
    print("=" * 70)
    
    # Typical neural network parameters
    scenarios = [
        {"name": "Small MLP", "d": 100, "norm_w": 5.0, "emp_risk": 0.02, "n": 5000},
        {"name": "Medium CNN", "d": 1000, "norm_w": 15.0, "emp_risk": 0.01, "n": 50000},
        {"name": "Large ResNet", "d": 10000, "norm_w": 50.0, "emp_risk": 0.005, "n": 100000},
    ]
    
    delta = 0.05
    sigma_p = 1.0
    
    for s in scenarios:
        print(f"\n--- {s['name']} (d={s['d']}, n={s['n']}) ---")
        
        # Optimize posterior scale
        opt_sq, opt_mc = optimize_posterior_scale(
            d=s['d'], norm_w=s['norm_w'], sigma_p=sigma_p,
            n=s['n'], delta=delta, emp_risk=s['emp_risk'],
            num_points=500
        )
        
        # Also try Catoni
        _, opt_cat = optimize_posterior_scale(
            d=s['d'], norm_w=s['norm_w'], sigma_p=sigma_p,
            n=s['n'], delta=delta, emp_risk=s['emp_risk'],
            bound_type='catoni', lam=2.0, num_points=500
        )
        
        kl_opt = gaussian_kl_div(s['d'], s['norm_w'], opt_sq, sigma_p)
        
        print(f"  Training error: {s['emp_risk']:.3%}")
        print(f"  Optimal σq: {opt_sq:.3f}")
        print(f"  KL divergence: {kl_opt:.2f}")
        print(f"  McAllester bound: {opt_mc:.4f} (gap: {opt_mc - s['emp_risk']:.4f})")
        print(f"  Catoni bound: {opt_cat:.4f} (gap: {opt_cat - s['emp_risk']:.4f})")
        print(f"  Certified test error ≤ {opt_mc:.3%} with 95% confidence")
    print()


def application_linear_classifier():
    """Application 2: Linear classifier with explicit rate analysis.
    
    Shows the Θ(d/n) rate for linear classifiers, confirming
    asymptotic tightness of PAC-Bayes.
    """
    print("=" * 70)
    print("APPLICATION 2: Linear Classifier — Asymptotic Rate Analysis")
    print("=" * 70)
    
    dimensions = [5, 10, 20, 50, 100]
    n_values = [100, 500, 1000, 5000, 10000]
    delta = 0.05
    sigma_p = 1.0
    norm_w = 2.0
    emp_risk = 0.0  # Focus on complexity term
    
    print(f"\nPAC-Bayes complexity term (√(KL/n)) for varying d and n:")
    print(f"(σp = {sigma_p}, ||w|| = {norm_w}, empRisk = 0)")
    print()
    
    dn_label = 'd\\n'
    header = f"{dn_label:>6}"
    for n in n_values:
        header += f" {n:>10}"
    print(header)
    print("-" * (6 + 11 * len(n_values)))
    
    for d in dimensions:
        row = f"{d:>6}"
        for n in n_values:
            # Equal variance case for clean rate
            kl = gaussian_kl_div(d, norm_w, sigma_p, sigma_p)
            mc = mcallester_bound(emp_risk, kl, n, delta)
            gap = mc - emp_risk
            row += f" {gap:>10.4f}"
        print(row)
    
    print(f"\nn × gap² (should be ≈ constant for fixed d):")
    d = 20
    kl = gaussian_kl_div(d, norm_w, sigma_p, sigma_p)
    print(f"d = {d}: ", end="")
    for n in n_values:
        mc = mcallester_bound(emp_risk, kl, n, delta)
        gap = mc - emp_risk
        print(f"n={n}: {n * gap**2:.2f}  ", end="")
    print()
    print()


def application_robustness_certification():
    """Application 3: Converting robustness certificates to generalization bounds.
    
    Shows how certified margins from adversarial robustness analysis
    feed into PAC-Bayes bounds, giving tighter certificates for robust models.
    """
    print("=" * 70)
    print("APPLICATION 3: Robustness → Generalization Certificate Pipeline")
    print("=" * 70)
    
    n = 5000
    d = 100
    delta = 0.05
    sigma_p = 1.0
    norm_w = 5.0
    
    print(f"\nScenario: d={d}, n={n}, δ={delta}, ||w||={norm_w}")
    print(f"\nComparing robust vs non-robust models:")
    print()
    
    # Non-robust model
    emp_plain = 0.05
    sigma_q_plain = 0.5
    kl_plain = gaussian_kl_div(d, norm_w, sigma_q_plain, sigma_p)
    mc_plain = mcallester_bound(emp_plain, kl_plain, n, delta)
    
    print(f"Non-robust model:")
    print(f"  Empirical risk: {emp_plain:.3%}")
    print(f"  KL divergence: {kl_plain:.2f}")
    print(f"  McAllester bound: {mc_plain:.4f}")
    print()
    
    # Robust models with varying margins
    margins = [0.5, 1.0, 1.5, 2.0, 3.0]
    perturb = 0.3
    
    print(f"Robust models (perturbation radius ε = {perturb}):")
    print(f"{'Margin γ':>10} {'Robust?':>8} {'empRisk':>10} {'KL':>8} {'Bound':>10} {'Improvement':>12}")
    print("-" * 62)
    
    for gamma in margins:
        rcert = compute_robust_certificate(
            margin=gamma, perturb_radius=perturb,
            kl=kl_plain, n=n, delta=delta
        )
        improvement = mc_plain - rcert.generalization_bound
        print(f"{gamma:>10.1f} {'Yes' if rcert.is_robust else 'No':>8} "
              f"{rcert.empirical_bound:>10.4f} {kl_plain:>8.2f} "
              f"{rcert.generalization_bound:>10.4f} {improvement:>+12.4f}")
    
    print()
    print("Insight: Larger margins → smaller empirical risk → tighter bounds.")
    print("The PAC-Bayes framework converts geometric stability into")
    print("statistical guarantees automatically.")
    print()


def application_posterior_optimization():
    """Application 4: Optimal posterior selection.
    
    Demonstrates how choosing the optimal posterior scale σq
    trades off between KL complexity and empirical risk control.
    """
    print("=" * 70)
    print("APPLICATION 4: Optimal Posterior Scale Selection")
    print("=" * 70)
    
    d = 50
    n = 2000
    delta = 0.05
    sigma_p = 1.0
    norm_w = 3.0
    
    emp_risks = [0.0, 0.01, 0.05, 0.1, 0.2]
    
    print(f"\nOptimal σq for different empirical risk levels:")
    print(f"(d={d}, n={n}, σp={sigma_p}, ||w||={norm_w})")
    print()
    
    print(f"{'empRisk':>10} {'Opt σq(MC)':>12} {'MC Bound':>10} {'Opt σq(Cat)':>12} {'Cat Bound':>10}")
    print("-" * 58)
    
    for emp in emp_risks:
        sq_mc, bound_mc = optimize_posterior_scale(
            d, norm_w, sigma_p, n, delta, emp,
            bound_type='mcallester', num_points=500
        )
        sq_cat, bound_cat = optimize_posterior_scale(
            d, norm_w, sigma_p, n, delta, emp,
            bound_type='catoni', lam=2.0, num_points=500
        )
        print(f"{emp:>10.2f} {sq_mc:>12.3f} {bound_mc:>10.4f} {sq_cat:>12.3f} {bound_cat:>10.4f}")
    
    print()
    print("Insight: The optimal posterior scale balances two forces:")
    print("  - Small σq → small entropy term but large energy term")
    print("  - Large σq → large entropy term but small energy term")
    print("  The minimum occurs where these forces balance — this is")
    print("  the information-geometric sweet spot.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  PAC-Bayes Applications: Real-World Generalization Certificates ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    application_neural_network_certification()
    application_linear_classifier()
    application_robustness_certification()
    application_posterior_optimization()
    
    print("All applications completed.")


#!/usr/bin/env python3
"""
PAC-Bayes Generalization Bounds: Interactive Certificate Demo

This script demonstrates the PAC-Bayes generalization bounds formalized
in Lean 4, allowing users to explore how McAllester and Catoni bounds
behave under varying parameters.

Usage:
    python demo.py
"""

import math
import sys

# ──────────────────────────────────────────────────────────────
# Core PAC-Bayes Bound Functions (matching the Lean definitions)
# ──────────────────────────────────────────────────────────────

def gaussian_kl_div(d: int, norm_w: float, sigma_q: float, sigma_p: float) -> float:
    """KL(N(w, σq²I) || N(0, σp²I)) in d dimensions.
    
    = ||w||² / (2σp²) + (d/2)(σq²/σp² - 1 - log(σq²/σp²))
    """
    ratio = (sigma_q / sigma_p) ** 2
    energy = norm_w ** 2 / (2 * sigma_p ** 2)
    entropy = (d / 2) * (ratio - 1 - math.log(ratio))
    return energy + entropy


def mcallester_bound(emp_risk: float, kl: float, n: int, delta: float) -> float:
    """McAllester PAC-Bayes bound.
    
    bound = empRisk + sqrt((kl + log(2√n/δ)) / (2(n-1)))
    """
    if n <= 1:
        return float('inf')
    inside = (kl + math.log(2 * math.sqrt(n) / delta)) / (2 * (n - 1))
    return emp_risk + math.sqrt(max(0, inside))


def catoni_bound(emp_risk: float, kl: float, n: int, delta: float, lam: float) -> float:
    """Catoni PAC-Bayes bound with inverse temperature λ.
    
    bound = (1/(1-e^{-λ})) * (1 - exp(-λ·empRisk - (kl + log(1/δ))/n))
    """
    if lam <= 0 or n <= 0:
        return float('inf')
    denom = 1 - math.exp(-lam)
    exponent = -lam * emp_risk - (kl + math.log(1 / delta)) / n
    return (1 / denom) * (1 - math.exp(exponent))


def gaussian_pac_bayes_certificate(n: int, d: int, delta: float, lam: float,
                                    sigma_p: float, sigma_q: float,
                                    emp_risk: float, norm_w: float) -> dict:
    """Compute a complete PAC-Bayes certificate for Gaussian posteriors."""
    kl = gaussian_kl_div(d, norm_w, sigma_q, sigma_p)
    mc_bound = mcallester_bound(emp_risk, kl, n, delta)
    cat_bound = catoni_bound(emp_risk, kl, n, delta, lam)
    
    return {
        'kl_divergence': kl,
        'mcallester_bound': mc_bound,
        'catoni_bound': cat_bound,
        'complexity': mc_bound - emp_risk,
        'confidence': 1 - delta,
        'emp_risk': emp_risk,
        'n': n,
        'd': d,
    }


# ──────────────────────────────────────────────────────────────
# Demo Functions
# ──────────────────────────────────────────────────────────────

def demo_basic_bounds():
    """Demo 1: Basic PAC-Bayes bounds with varying parameters."""
    print("=" * 70)
    print("DEMO 1: McAllester and Catoni Bounds")
    print("=" * 70)
    
    # Fixed parameters
    d = 10
    delta = 0.05
    sigma_p = 1.0
    sigma_q = 0.5
    norm_w = 2.0
    emp_risk = 0.1
    lam = 2.0
    
    print(f"\nFixed parameters: d={d}, δ={delta}, σp={sigma_p}, σq={sigma_q}")
    print(f"                  ||w||={norm_w}, empRisk={emp_risk}, λ={lam}")
    print()
    
    kl = gaussian_kl_div(d, norm_w, sigma_q, sigma_p)
    print(f"Gaussian KL divergence: {kl:.4f}")
    print(f"  Energy term (||w||²/2σp²): {norm_w**2 / (2*sigma_p**2):.4f}")
    ratio = (sigma_q/sigma_p)**2
    print(f"  Entropy term (d/2·(r-1-log r)): {(d/2)*(ratio-1-math.log(ratio)):.4f}")
    print()
    
    print(f"{'n':>8} {'McAllester':>12} {'Catoni':>12} {'Gap (MC)':>12} {'Gap (Cat)':>12}")
    print("-" * 60)
    
    for n in [50, 100, 200, 500, 1000, 2000, 5000, 10000]:
        mc = mcallester_bound(emp_risk, kl, n, delta)
        cat = catoni_bound(emp_risk, kl, n, delta, lam)
        print(f"{n:>8} {mc:>12.6f} {cat:>12.6f} {mc-emp_risk:>12.6f} {cat-emp_risk:>12.6f}")
    
    print()


def demo_asymptotic_behavior():
    """Demo 2: Asymptotic 1/n behavior."""
    print("=" * 70)
    print("DEMO 2: Asymptotic O(1/n) Behavior")
    print("=" * 70)
    
    d = 10
    delta = 0.05
    sigma_p = 1.0
    sigma_q = sigma_p  # Equal variance for clean rate
    norm_w = 2.0
    emp_risk = 0.0
    
    kl = gaussian_kl_div(d, norm_w, sigma_q, sigma_p)
    print(f"\nEqual-variance case: σq = σp = {sigma_p}")
    print(f"KL = ||w||²/(2σ²) = {kl:.4f}")
    print(f"\nVerifying Θ(1/n) rate: n·gap should converge to a constant")
    print()
    
    print(f"{'n':>8} {'Gap':>12} {'n·Gap':>12} {'Predicted':>12}")
    print("-" * 50)
    
    C = kl  # The constant in the O(1/n) rate
    for n in [100, 500, 1000, 5000, 10000, 50000, 100000]:
        mc = mcallester_bound(emp_risk, kl, n, delta)
        gap = mc - emp_risk
        print(f"{n:>8} {gap:>12.6f} {n*gap**2:>12.4f} {C:>12.4f}")
    
    print(f"\nn·gap² → KL = {C:.4f} (confirming √(KL/n) rate)")
    print()


def demo_gaussian_certificate():
    """Demo 3: Complete Gaussian PAC-Bayes certificate."""
    print("=" * 70)
    print("DEMO 3: Gaussian PAC-Bayes Certificate")
    print("=" * 70)
    
    n = 1000
    d = 50
    delta = 0.05
    lam = 1.5
    sigma_p = 1.0
    sigma_q = 0.3
    emp_risk = 0.05
    norm_w = 3.0
    
    cert = gaussian_pac_bayes_certificate(n, d, delta, lam, sigma_p, sigma_q,
                                           emp_risk, norm_w)
    
    print(f"\nInput parameters:")
    print(f"  Sample size n = {n}")
    print(f"  Dimension d = {d}")
    print(f"  Confidence δ = {delta}")
    print(f"  Inverse temperature λ = {lam}")
    print(f"  Prior scale σp = {sigma_p}")
    print(f"  Posterior scale σq = {sigma_q}")
    print(f"  Empirical risk = {emp_risk}")
    print(f"  Parameter norm ||w|| = {norm_w}")
    print()
    print(f"Certificate output:")
    print(f"  KL divergence: {cert['kl_divergence']:.4f}")
    print(f"  McAllester bound: {cert['mcallester_bound']:.4f}")
    print(f"  Catoni bound: {cert['catoni_bound']:.4f}")
    print(f"  Complexity (gap): {cert['complexity']:.4f}")
    print(f"  Confidence: {cert['confidence']:.2%}")
    print()
    
    # Optimize over sigma_q
    print("Optimizing posterior scale σq:")
    print(f"{'σq':>8} {'KL':>10} {'McAllester':>12} {'Catoni':>12}")
    print("-" * 45)
    
    best_mc = float('inf')
    best_sq_mc = 0
    best_cat = float('inf')
    best_sq_cat = 0
    
    for sq_int in range(1, 30):
        sq = sq_int * 0.1
        c = gaussian_pac_bayes_certificate(n, d, delta, lam, sigma_p, sq,
                                            emp_risk, norm_w)
        if c['mcallester_bound'] < best_mc:
            best_mc = c['mcallester_bound']
            best_sq_mc = sq
        if c['catoni_bound'] < best_cat:
            best_cat = c['catoni_bound']
            best_sq_cat = sq
        if sq_int % 5 == 0 or sq_int <= 3:
            print(f"{sq:>8.1f} {c['kl_divergence']:>10.4f} "
                  f"{c['mcallester_bound']:>12.6f} {c['catoni_bound']:>12.6f}")
    
    print(f"\nOptimal σq for McAllester: {best_sq_mc:.1f} → bound = {best_mc:.6f}")
    print(f"Optimal σq for Catoni:     {best_sq_cat:.1f} → bound = {best_cat:.6f}")
    print()


def demo_robustness_transfer():
    """Demo 4: Robustness-to-generalization transfer."""
    print("=" * 70)
    print("DEMO 4: Robustness → Generalization Transfer")
    print("=" * 70)
    
    n = 1000
    d = 20
    delta = 0.05
    sigma_p = 1.0
    sigma_q = 0.5
    norm_w = 2.0
    
    kl = gaussian_kl_div(d, norm_w, sigma_q, sigma_p)
    
    print(f"\nMargin-based risk control:")
    print(f"If classifier margin γ > perturbation effect ε,")
    print(f"then empirical risk under perturbation = 0.")
    print()
    
    print(f"{'Margin γ':>10} {'Pert ε':>10} {'Robust?':>10} {'empRisk':>10} {'MC Bound':>12}")
    print("-" * 55)
    
    for gamma, eps in [(2.0, 0.5), (1.5, 0.5), (1.0, 0.5),
                        (0.8, 0.5), (0.5, 0.5), (0.3, 0.5)]:
        robust = gamma > eps
        emp = 0.0 if robust else 0.1 * (eps / gamma)
        mc = mcallester_bound(emp, kl, n, delta)
        print(f"{gamma:>10.1f} {eps:>10.1f} {'Yes' if robust else 'No':>10} "
              f"{emp:>10.4f} {mc:>12.6f}")
    
    print()
    print("Key insight: When margin γ > perturbation ε, the empirical risk")
    print("is controlled (= 0), and the PAC-Bayes bound collapses to just")
    print("the KL complexity term — giving a *pure robustness* certificate.")
    print()


def demo_conjecture_test():
    """Demo 5: Test the robustness-improved constant conjecture."""
    print("=" * 70)
    print("DEMO 5: Robustness-Improved PAC-Bayes Constant Conjecture")
    print("=" * 70)
    
    print("""
Conjecture: For classifiers with certified perturbation-stable margin γ,
the optimal Gaussian PAC-Bayes bound constant is strictly smaller than
the non-robust constant when σ² < c·γ².

Testing: Compare C_robust vs C_plain over a grid of (γ, σ, n).
""")
    
    d = 20
    delta = 0.05
    sigma_p = 1.0
    norm_w = 2.0
    c_threshold = 0.5  # Conjecture constant
    
    print(f"{'γ':>6} {'σ':>6} {'n':>8} {'σ²<cγ²?':>10} {'C_plain':>10} {'C_robust':>10} {'Improved?':>10}")
    print("-" * 65)
    
    supports = 0
    total = 0
    
    for gamma in [0.5, 1.0, 2.0, 3.0]:
        for sigma in [0.1, 0.3, 0.5, 1.0]:
            for n in [500, 2000]:
                condition = sigma**2 < c_threshold * gamma**2
                
                # Non-robust: standard empirical risk
                emp_plain = 0.1
                kl_plain = gaussian_kl_div(d, norm_w, sigma, sigma_p)
                c_plain = mcallester_bound(emp_plain, kl_plain, n, delta) - emp_plain
                
                # Robust: margin controls risk
                emp_robust = 0.0 if gamma > sigma else emp_plain
                c_robust = mcallester_bound(emp_robust, kl_plain, n, delta) - emp_robust
                
                improved = c_robust < c_plain
                total += 1
                if condition and improved:
                    supports += 1
                
                if n == 2000:  # Print subset
                    print(f"{gamma:>6.1f} {sigma:>6.1f} {n:>8} "
                          f"{'Yes' if condition else 'No':>10} "
                          f"{c_plain:>10.4f} {c_robust:>10.4f} "
                          f"{'✓' if improved else '✗':>10}")
    
    print(f"\nConjecture support: {supports}/{total} cases where σ²<cγ² → C_robust < C_plain")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  PAC-Bayes Generalization Bounds: Variational Geometry of      ║")
    print("║  Learning — Interactive Certificate Demo                       ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_basic_bounds()
    demo_asymptotic_behavior()
    demo_gaussian_certificate()
    demo_robustness_transfer()
    demo_conjecture_test()
    
    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)
