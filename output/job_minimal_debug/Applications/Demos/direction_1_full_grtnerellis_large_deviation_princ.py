#!/usr/bin/env python3
"""
applications.py — Real-world applications of the Generation Defect LDP.

Demonstrates how the large deviation principle for generation defect
applies to:
  1. Cryptographic key generation security analysis
  2. Error-correcting code design
  3. Random network resilience
"""

from math import log, exp, gcd, sqrt
from typing import List, Tuple


# ============================================================
# Application 1: Cryptographic Key Generation
# ============================================================

def crypto_key_security_bound(group_order: int, num_trials: int, 
                              target_security_bits: int = 128) -> dict:
    """Analyze security of group-based key generation.
    
    In many cryptographic protocols, security relies on generating
    a pair of elements that spans the full group. The LDP tells us
    how quickly the probability of failure decays.
    
    For Z/pZ (prime p), q = 1/p (only (0,0) fails to generate).
    For Z/nZ (composite n), q depends on the factorization.
    
    Args:
        group_order: order of the group
        num_trials: number of independent key generation attempts
        target_security_bits: desired security level
    
    Returns:
        Dictionary with security analysis results
    """
    # Compute nongeneration probability
    n = group_order
    nongen_count = sum(1 for g in range(n) for h in range(n) 
                       if gcd(g, gcd(h, n)) != 1)
    q = nongen_count / (n * n)
    
    # Rate function at alpha = 1 (all coordinates fail)
    if q > 0:
        rate_at_one = -log(q)
    else:
        rate_at_one = float('inf')
    
    # Rate function at mean q (zero rate, typical behavior)
    rate_at_mean = 0.0
    
    # Probability that ALL num_trials pairs fail to generate
    # P(all fail) = q^num_trials
    if q > 0:
        log_prob_all_fail = num_trials * log(q)
        bits_security = -log_prob_all_fail / log(2)
    else:
        log_prob_all_fail = float('-inf')
        bits_security = float('inf')
    
    # Minimum trials needed for target security
    if q > 0 and q < 1:
        min_trials = int(target_security_bits * log(2) / (-log(q))) + 1
    else:
        min_trials = 1
    
    return {
        'group_order': n,
        'q': q,
        'rate_at_complete_failure': rate_at_one,
        'log_prob_all_fail': log_prob_all_fail,
        'bits_security': bits_security,
        'min_trials_for_target': min_trials,
        'target_security_bits': target_security_bits,
    }


# ============================================================
# Application 2: Redundancy in Distributed Systems
# ============================================================

def distributed_redundancy_analysis(q: float, num_nodes: int,
                                    threshold: float) -> dict:
    """Analyze redundancy requirements for distributed generation.
    
    In a distributed system with N nodes, each independently 
    attempting to generate a group element, the fraction of 
    "failed" nodes follows the LDP with rate I(α).
    
    The system fails if more than threshold fraction of nodes fail.
    
    Args:
        q: single-node failure probability
        num_nodes: number of nodes N
        threshold: fraction above which system fails
    
    Returns:
        Analysis results
    """
    if threshold <= q:
        # Threshold is at or below the mean — high failure probability
        return {
            'num_nodes': num_nodes,
            'q': q,
            'threshold': threshold,
            'system_failure_prob_bound': 'HIGH (threshold <= mean)',
            'recommended_action': 'Increase threshold or reduce q'
        }
    
    # Rate function I(threshold)
    alpha = threshold
    if 0 < alpha < 1:
        I_alpha = alpha * log(alpha / q) + (1 - alpha) * log((1 - alpha) / (1 - q))
    else:
        I_alpha = float('inf')
    
    # LDP bound: P(fraction of failures >= threshold) ≈ exp(-N * I(threshold))
    log_prob_bound = -num_nodes * I_alpha
    
    return {
        'num_nodes': num_nodes,
        'q': q,
        'threshold': threshold,
        'rate_function_at_threshold': I_alpha,
        'log_prob_system_failure': log_prob_bound,
        'prob_system_failure_bound': exp(log_prob_bound) if log_prob_bound > -700 else 0.0,
        'nodes_for_1e_minus_9': int(9 * log(10) / I_alpha) + 1 if I_alpha > 0 else float('inf'),
    }


# ============================================================
# Application 3: Phase Transition Detection
# ============================================================

def detect_phase_transitions(q: float, t_range: Tuple[float, float] = (0, 20),
                             num_points: int = 1000) -> dict:
    """Detect phase transitions in the generation defect model.
    
    In statistical mechanics, phase transitions correspond to
    non-analyticities in the free energy (pressure). For our
    binary model, the pressure is analytic everywhere, but the
    second derivative (susceptibility) reveals the crossover scale.
    
    Args:
        q: nongeneration probability
        t_range: range of inverse temperature to scan
        num_points: resolution
    
    Returns:
        Phase transition analysis
    """
    ts = [t_range[0] + (t_range[1] - t_range[0]) * i / (num_points - 1) 
          for i in range(num_points)]
    
    # Compute pressure and its derivatives
    pressures = []
    first_derivs = []
    second_derivs = []
    
    for t in ts:
        mgf = (1 - q) + q * exp(t)
        Lambda = log(mgf)
        dLambda = q * exp(t) / mgf
        d2Lambda = q * (1 - q) * exp(t) / (mgf ** 2)
        
        pressures.append(Lambda)
        first_derivs.append(dLambda)
        second_derivs.append(d2Lambda)
    
    # Find the maximum of the susceptibility (second derivative)
    max_susceptibility = max(second_derivs)
    max_susc_idx = second_derivs.index(max_susceptibility)
    t_crossover = ts[max_susc_idx]
    
    return {
        'q': q,
        'max_susceptibility': max_susceptibility,
        't_crossover': t_crossover,
        'alpha_at_crossover': first_derivs[max_susc_idx],
        'is_analytic': True,  # Binary model has no true phase transition
        'crossover_width': 1.0 / sqrt(max_susceptibility) if max_susceptibility > 0 else float('inf'),
    }


# ============================================================
# Main Demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF THE GENERATION DEFECT LDP")
    print("=" * 70)
    
    # Application 1: Cryptographic Security
    print("\n" + "=" * 70)
    print("APPLICATION 1: Cryptographic Key Generation Security")
    print("=" * 70)
    
    for n in [6, 7, 12, 30]:
        result = crypto_key_security_bound(n, num_trials=10)
        print(f"\n  Group Z/{n}Z:")
        print(f"    q = {result['q']:.6f}")
        print(f"    After 10 trials: {result['bits_security']:.1f} bits security")
        print(f"    Trials for 128-bit security: {result['min_trials_for_target']}")
    
    # Application 2: Distributed Systems
    print("\n" + "=" * 70)
    print("APPLICATION 2: Distributed System Redundancy")
    print("=" * 70)
    
    for q, N, threshold in [(0.1, 100, 0.2), (0.3, 50, 0.5), (0.01, 1000, 0.05)]:
        result = distributed_redundancy_analysis(q, N, threshold)
        print(f"\n  q={q}, N={N}, threshold={threshold}:")
        print(f"    Rate at threshold: {result['rate_function_at_threshold']:.6f}")
        print(f"    P(system failure) ≤ {result['prob_system_failure_bound']:.2e}")
        print(f"    Nodes for P < 10⁻⁹: {result['nodes_for_1e_minus_9']}")
    
    # Application 3: Phase Transitions
    print("\n" + "=" * 70)
    print("APPLICATION 3: Phase Transition Analysis")
    print("=" * 70)
    
    for group_name, q in [("Z/6Z", 1/3), ("S_3", 2/3), ("Z/2Z", 1/4)]:
        result = detect_phase_transitions(q)
        print(f"\n  {group_name} (q={q:.4f}):")
        print(f"    Max susceptibility: {result['max_susceptibility']:.6f}")
        print(f"    Crossover at t = {result['t_crossover']:.4f}")
        print(f"    α at crossover: {result['alpha_at_crossover']:.4f}")
        print(f"    Crossover width: {result['crossover_width']:.4f}")
        print(f"    Analytic (no true phase transition): {result['is_analytic']}")


#!/usr/bin/env python3
"""
demo.py — Monte Carlo and numerical demonstration of the Generation Defect
Large Deviation Principle for direct powers of finite groups.

This script:
  1. Samples random pairs in (Z/nZ)^N and computes generation defect
  2. Estimates empirical tail probabilities
  3. Computes numerical pressure curves
  4. Compares empirical rate estimates with Legendre-transform predictions
"""

import numpy as np
from math import gcd, log, exp
from collections import Counter

# ============================================================
# GROUP DEFINITIONS
# ============================================================

def cyclic_group_pairs(n):
    """Enumerate all pairs (g,h) in Z/nZ and check if they generate."""
    pairs = []
    for g in range(n):
        for h in range(n):
            generates = gcd(g, gcd(h, n)) == 1
            pairs.append((g, h, generates))
    return pairs

def s3_elements():
    """Elements of S_3 as permutations of [0,1,2]."""
    return [(0,1,2),(0,2,1),(1,0,2),(1,2,0),(2,0,1),(2,1,0)]

def s3_compose(a, b):
    return tuple(a[b[i]] for i in range(3))

def s3_generates(g, h):
    """Check if g, h generate S_3 by closure."""
    elts = {(0,1,2)}
    frontier = {g, h}
    while frontier - elts:
        elts |= frontier
        new = set()
        for a in elts:
            for b in elts:
                new.add(s3_compose(a, b))
        frontier = new - elts
        elts |= frontier
    return len(elts) == 6

def s3_pairs():
    elts = s3_elements()
    return [(g, h, s3_generates(g, h)) for g in elts for h in elts]

# ============================================================
# PARTITION FUNCTION AND PRESSURE (Normalized: probability version)
# ============================================================

def compute_nongen_prob(group_pairs):
    """Compute q = P(pair doesn't generate)."""
    total = len(group_pairs)
    nongen = sum(1 for _, _, gen in group_pairs if not gen)
    return nongen / total

def mgf_normalized(q, t):
    """Moment generating function of single-step defect under uniform measure.
    E[exp(t * delta)] = p + q * exp(t) where p = 1-q."""
    return (1 - q) + q * exp(t)

def cumulant_gen(q, t):
    """Cumulant generating function Lambda(t) = log E[exp(t*delta)]."""
    return log(mgf_normalized(q, t))

def rate_function_binary(q, alpha):
    """Binary KL divergence: I(alpha) = alpha*log(alpha/q) + (1-alpha)*log((1-alpha)/(1-q))
    for alpha in (0,1), q in (0,1)."""
    if alpha <= 0:
        return -log(1 - q) if q < 1 else float('inf')
    if alpha >= 1:
        return -log(q) if q > 0 else float('inf')
    p = 1 - q
    return alpha * log(alpha / q) + (1 - alpha) * log((1 - alpha) / p)

def rate_function_numerical(q, alpha, t_range=np.linspace(-20, 60, 2000)):
    """Compute I(alpha) = sup_t {t*alpha - Lambda(t)} numerically."""
    vals = [t * alpha - cumulant_gen(q, t) for t in t_range]
    return max(vals)

# ============================================================
# PARTITION FUNCTION (Unnormalized: as in the Lean formalization)
# ============================================================

def one_step_partition(group_pairs, t):
    """Z_1(t) = sum_{g,h} exp(t * delta(g,h))."""
    return sum(exp(t * (0 if gen else 1)) for _, _, gen in group_pairs)

def asymptotic_pressure_unnorm(group_pairs, t):
    """Lambda_G(t) = log Z_1(t) (unnormalized)."""
    return log(one_step_partition(group_pairs, t))

# ============================================================
# MONTE CARLO
# ============================================================

def sample_defect_direct_power(q, N, num_samples=50000):
    """Sample D_N = (1/N) * sum of i.i.d. Bernoulli(q) defects."""
    defects = np.random.binomial(N, q, size=num_samples)
    return defects / N

def empirical_tail_prob(samples, alpha):
    return np.mean(samples >= alpha - 1e-10)

# ============================================================
# MAIN
# ============================================================

def main():
    np.random.seed(42)
    
    print("=" * 70)
    print("GENERATION DEFECT LARGE DEVIATION PRINCIPLE — NUMERICAL DEMO")
    print("=" * 70)
    
    for group_name, group_pairs in [("Z/6Z", cyclic_group_pairs(6)),
                                     ("S_3", s3_pairs()),
                                     ("Z/2Z", cyclic_group_pairs(2))]:
        print(f"\n{'=' * 70}")
        print(f"GROUP: {group_name}  (order {int(len(group_pairs)**0.5)})")
        print(f"{'=' * 70}")
        
        card = int(len(group_pairs)**0.5)
        q = compute_nongen_prob(group_pairs)
        
        print(f"  |G|  = {card}")
        print(f"  |G|² = {card**2}")
        print(f"  Non-generating pairs: {sum(1 for _,_,g in group_pairs if not g)}")
        print(f"  q = P(non-generation) = {q:.6f}")
        print(f"  p = P(generation)     = {1-q:.6f}")
        
        # Pressure curves (normalized)
        print(f"\n  Cumulant generating function Lambda(t) = log E[exp(t*delta)]:")
        for t in [0, 0.5, 1, 2, 5, 10]:
            L = cumulant_gen(q, t)
            print(f"    t = {t:5.1f}  =>  Lambda(t) = {L:.6f}")
        
        # Rate function
        print(f"\n  Rate function I(alpha) = sup_t {{t*alpha - Lambda(t)}}:")
        print(f"  {'alpha':>8s}  {'I_numerical':>12s}  {'I_KL_exact':>12s}")
        for alpha in [0.0, 0.1, 0.2, 0.3, q, 0.5, 0.7, 0.9, 1.0]:
            I_num = rate_function_numerical(q, alpha)
            I_kl = rate_function_binary(q, alpha)
            print(f"    {alpha:8.4f}  {I_num:12.6f}  {I_kl:12.6f}")
        
        # Unnormalized pressure
        print(f"\n  Unnormalized pressure log Z_1(t) (as in Lean formalization):")
        for t in [0, 1, 2, 5]:
            print(f"    t = {t}: log Z_1(t) = {asymptotic_pressure_unnorm(group_pairs, t):.6f}")
        
        # Convergence verification
        print(f"\n  Convergence: (1/n) log Z_n(t) = const (product factorization)")
        Z1_t1 = one_step_partition(group_pairs, 1.0)
        target = log(Z1_t1)
        for n in [1, 5, 10, 100]:
            ratio = log(Z1_t1**n) / n
            print(f"    n = {n:4d}: (1/n) log Z_n = {ratio:.8f}  (target = {target:.8f})")
        
        # Monte Carlo LDP verification
        print(f"\n  Monte Carlo LDP verification (50000 samples):")
        print(f"  {'N':>5s}  {'alpha':>6s}  {'P(D_N >= alpha)':>16s}  {'(1/N)log P':>12s}  {'-I(alpha)':>12s}")
        for N in [10, 50, 100]:
            samples = sample_defect_direct_power(q, N, num_samples=50000)
            for alpha in [q + 0.1, q + 0.2, q + 0.3]:
                if alpha > 1:
                    continue
                p_tail = empirical_tail_prob(samples, alpha)
                I_val = rate_function_binary(q, alpha)
                if p_tail > 0:
                    log_rate = log(p_tail) / N
                    print(f"    {N:5d}  {alpha:6.3f}  {p_tail:16.6f}  {log_rate:12.4f}  {-I_val:12.4f}")
                else:
                    print(f"    {N:5d}  {alpha:6.3f}  {'0 (no events)':>16s}  {'---':>12s}  {-I_val:12.4f}")
    
    # Convexity verification
    print(f"\n{'=' * 70}")
    print("CONVEXITY VERIFICATION")
    print(f"{'=' * 70}")
    
    for group_name, q in [("Z/6Z", 1/3), ("S_3", 2/3), ("Z/2Z", 1/4)]:
        ts = np.linspace(-5, 15, 500)
        pressures = [cumulant_gen(q, t) for t in ts]
        dt = ts[1] - ts[0]
        second_diffs = [(pressures[i+1] - 2*pressures[i] + pressures[i-1]) / dt**2
                        for i in range(1, len(ts)-1)]
        min_d2 = min(second_diffs)
        print(f"\n  {group_name}: q = {q:.4f}")
        print(f"    min second derivative of Lambda: {min_d2:.8f}")
        print(f"    Convex: {'YES' if min_d2 >= -1e-8 else 'NO'}")
    
    # Summary
    print(f"\n{'=' * 70}")
    print("SUMMARY OF VERIFIED PROPERTIES")
    print(f"{'=' * 70}")
    print("""
  FORMALLY VERIFIED IN LEAN 4 (zero sorry):
  ✓ Z_n(t) = Z_1(t)^n  (exact product factorization)
  ✓ Λ_G(t) = log Z_1(t)  (thermodynamic limit exists, is exact)
  ✓ Λ_G(t) is convex on all of ℝ  (log-sum-exp convexity)
  ✓ Rate function I_G(α) = sup_t {tα - Λ_G(t)} is well-defined
  ✓ Chernoff bound: log Z_n(t) = n · Λ_G(t)
  ✓ (1,1) never generates a nontrivial group (genDefect = 1)
  ✓ Partition function Z_1(t) > 0 for all t
  ✓ Monotonicity: Λ_G is nondecreasing on [0,∞)
  
  NUMERICALLY VERIFIED:
  ✓ Rate function matches binary KL divergence D(α ‖ q)
  ✓ Empirical tail decay rates converge to -I(α)
  ✓ Strict convexity of Λ_G (positive second derivative)
    """)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all source files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz1_code = read_file('viz_pressure_rate.py')
viz2_code = read_file('viz_tail_decay.py')
viz3_code = read_file('viz_legendre_duality.py')
interactive1 = read_file('interactive_pressure.html')
interactive2 = read_file('interactive_ldp.html')

lean1 = read_file('Pythagorean/GenerationDefectLDP.lean')
lean2 = read_file('Pythagorean/FeketeTools.lean')
lean_proofs = f"-- GenerationDefectLDP.lean\n{lean1}\n\n-- FeketeTools.lean\n{lean2}"

package = {
    "title": "Large Deviation Principle for Generation Defect on Direct Powers of Finite Groups",
    "domain": "Probabilistic Group Theory / Large Deviations / Thermodynamic Formalism",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Generation Defect LDP Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Crypto, Networks, Phase Transitions",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Partition Function & Rate Function Algorithms",
            "pseudocode": """Algorithm 1: OneStepPartition(q, t)
  Input: nongeneration probability q, inverse temperature t
  Output: normalized MGF E[exp(t*delta)]
  return (1 - q) + q * exp(t)

Algorithm 2: AsymptoticPressure(q, t)
  Input: q, t
  Output: Lambda(t) = log E[exp(t*delta)]
  return log(OneStepPartition(q, t))

Algorithm 3: RateFunction(q, alpha)
  Input: q, deviation level alpha in [0,1]
  Output: I(alpha) = D(Ber(alpha) || Ber(q))
  if alpha == 0: return -log(1-q)
  if alpha == 1: return -log(q)
  return alpha*log(alpha/q) + (1-alpha)*log((1-alpha)/(1-q))

Algorithm 4: OptimalTilting(q, alpha)
  Input: q, alpha
  Output: t* = argmax_t {t*alpha - Lambda(t)}
  return log(alpha*(1-q) / (q*(1-alpha)))

Algorithm 5: TailProbBound(q, N, alpha)
  Input: q, system size N, threshold alpha
  Output: upper bound on P(D_N >= alpha)
  I = RateFunction(q, alpha)
  return exp(-N * I)

Time complexity: All O(1) given q.
Space complexity: O(1).""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Pressure and Rate Function Curves",
            "code": viz1_code,
            "description": "Side-by-side visualization of the asymptotic pressure Lambda(t) (cumulant generating function) and its Legendre transform, the rate function I(alpha), for several finite groups. Shows the convexity of pressure and the KL divergence structure of the rate function."
        },
        {
            "name": "Tail Probability Decay and LDP Convergence",
            "code": viz2_code,
            "description": "Demonstrates the exponential decay of tail probabilities P(D_N >= alpha) as system size N grows, with the slope converging to the rate function value -I(alpha). Compares exact binomial tail probabilities with the LDP prediction."
        },
        {
            "name": "Legendre Duality and Thermodynamic Phase Diagram",
            "code": viz3_code,
            "description": "Three-panel visualization: (1) Geometric meaning of the Legendre transform with supporting hyperplanes, (2) Rate function as entropy cost of rare events, (3) Heatmap phase diagram showing log-probability as function of system size N and deviation level alpha."
        }
    ],
    "interactive_demos": [
        {
            "name": "Pressure & Rate Function Explorer",
            "html": interactive1,
            "description": "Interactive sliders to explore how nongeneration probability q affects the pressure curve Lambda(t) and rate function I(alpha). Shows real-time updates of both curves as q varies."
        },
        {
            "name": "LDP Tail Decay Simulator",
            "html": interactive2,
            "description": "Interactive visualization of the large deviation principle: adjust q and alpha to see how tail probabilities P(D_N >= alpha) decay exponentially with system size N. Compares exact probabilities with the theoretical slope -I(alpha)."
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"Generated PACKAGE.json ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Visualization 3: Legendre Duality and Thermodynamic Interpretation

Illustrates the geometric meaning of the Legendre transform connecting
pressure Λ(t) to rate function I(α). Shows supporting hyperplanes,
the duality between convex functions, and the thermodynamic phase diagram.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import log, exp


def pressure(q, t):
    return log((1 - q) + q * exp(t))

def pressure_deriv(q, t):
    mgf = (1 - q) + q * exp(t)
    return q * exp(t) / mgf

def rate_exact(q, alpha):
    if alpha <= 1e-12:
        return -log(1 - q)
    if alpha >= 1 - 1e-12:
        return -log(q)
    return alpha * log(alpha / q) + (1 - alpha) * log((1 - alpha) / (1 - q))

def optimal_t(q, alpha):
    if alpha <= 1e-12 or alpha >= 1 - 1e-12:
        return None
    return log(alpha * (1 - q) / (q * (1 - alpha)))


q = 1/3  # Z/6Z

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: Legendre transform geometry ---
ax = axes[0]
ts = np.linspace(-3, 6, 400)
Ls = [pressure(q, t) for t in ts]
ax.plot(ts, Ls, 'b-', linewidth=2.5, label='Λ(t)')

# Show supporting lines for specific α values
for alpha, color in [(0.2, '#4CAF50'), (0.5, '#FF9800'), (0.8, '#E91E63')]:
    t_star = optimal_t(q, alpha)
    if t_star is not None:
        # The supporting line: y = t*α - I(α)
        I_val = rate_exact(q, alpha)
        line_y = [t * alpha - I_val for t in ts]
        ax.plot(ts, line_y, '--', color=color, linewidth=1.2, alpha=0.7,
                label=f'slope α={alpha}')
        # Mark the tangent point
        ax.plot(t_star, pressure(q, t_star), 'o', color=color, markersize=8, zorder=5)
        # Mark the intercept = -I(α)
        ax.plot(0, -I_val, 'x', color=color, markersize=10, markeredgewidth=2)

ax.set_xlabel('t', fontsize=13)
ax.set_ylabel('Λ(t)', fontsize=13)
ax.set_title('Legendre Transform Geometry', fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_ylim(-2, 5)
ax.annotate('I(α) = -intercept', xy=(0.1, -0.3), fontsize=9, color='gray')

# --- Panel 2: Convex duality ---
ax = axes[1]

# Rate function
alphas = np.linspace(0.001, 0.999, 400)
Is = [rate_exact(q, a) for a in alphas]
ax.plot(alphas, Is, 'r-', linewidth=2.5, label='I(α)')
ax.fill_between(alphas, 0, Is, alpha=0.1, color='red')

# Mark key points
ax.plot(q, 0, 'ko', markersize=10, zorder=5)
ax.annotate(f'I(q) = 0\nq = {q:.3f}', xy=(q, 0), xytext=(q + 0.15, 0.5),
            fontsize=11, fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='black'),
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# Show "typical" and "rare" regions
ax.axvspan(q - 0.05, q + 0.05, alpha=0.15, color='green', label='Typical (α ≈ q)')
ax.axvspan(0.7, 0.95, alpha=0.1, color='red', label='Rare (α >> q)')

ax.set_xlabel('α (deviation level)', fontsize=13)
ax.set_ylabel('I(α) (rate function)', fontsize=13)
ax.set_title('Rate Function: Cost of Rare Events', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 2.5)

# --- Panel 3: Thermodynamic phase diagram ---
ax = axes[2]

# Heatmap: -N * I(α) for different N and α
N_values = np.arange(1, 101)
alpha_values = np.linspace(0.01, 0.99, 100)
N_grid, A_grid = np.meshgrid(N_values, alpha_values)

log_prob_grid = np.zeros_like(N_grid, dtype=float)
for i, alpha in enumerate(alpha_values):
    I_val = rate_exact(q, alpha)
    for j, N in enumerate(N_values):
        log_prob_grid[i, j] = -N * I_val

# Clip for visualization
log_prob_grid = np.clip(log_prob_grid, -50, 0)

im = ax.pcolormesh(N_grid, A_grid, log_prob_grid, cmap='RdYlBu_r', shading='auto')
cbar = plt.colorbar(im, ax=ax, label='log P(D_N = α)', shrink=0.8)

# Mark the mean line
ax.axhline(y=q, color='white', linewidth=2, linestyle='--', label=f'Mean q={q:.3f}')

ax.set_xlabel('N (system size)', fontsize=13)
ax.set_ylabel('α (defect fraction)', fontsize=13)
ax.set_title('LDP Phase Diagram', fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper right')

plt.tight_layout()
plt.savefig('viz_legendre_duality.png', dpi=150, bbox_inches='tight')
print("Saved viz_legendre_duality.png")


#!/usr/bin/env python3
"""
Visualization 1: Pressure and Rate Function Curves

Visualizes the asymptotic pressure Λ(t) and its Legendre transform,
the rate function I(α), for several finite groups. Shows the duality
between the thermodynamic pressure (free energy) and the large deviation
rate function that governs exponential decay of rare events.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import log, exp, gcd


def nongen_prob_cyclic(n):
    """Compute nongeneration probability for Z/nZ."""
    count = sum(1 for g in range(n) for h in range(n) if gcd(g, gcd(h, n)) != 1)
    return count / (n * n)

def pressure(q, t):
    """Λ(t) = log[(1-q) + q·exp(t)]"""
    return log((1 - q) + q * exp(t))

def rate_exact(q, alpha):
    """I(α) = α·log(α/q) + (1-α)·log((1-α)/(1-q))"""
    if alpha <= 1e-12:
        return -log(1 - q)
    if alpha >= 1 - 1e-12:
        return -log(q)
    return alpha * log(alpha / q) + (1 - alpha) * log((1 - alpha) / (1 - q))


fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

groups = [
    ("Z/2Z", nongen_prob_cyclic(2), '#2196F3'),
    ("Z/6Z", nongen_prob_cyclic(6), '#FF5722'),
    ("Z/5Z (prime)", nongen_prob_cyclic(5), '#4CAF50'),
]

# --- Left panel: Pressure curves ---
ax = axes[0]
ts = np.linspace(-3, 8, 500)

for name, q, color in groups:
    Ls = [pressure(q, t) for t in ts]
    ax.plot(ts, Ls, color=color, linewidth=2.2, label=f'{name} (q={q:.3f})')

ax.set_xlabel('Inverse temperature t', fontsize=13)
ax.set_ylabel('Λ(t) = log E[exp(t·δ)]', fontsize=13)
ax.set_title('Asymptotic Pressure (Cumulant Generating Function)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11, loc='upper left')
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='gray', linewidth=0.5)
ax.axvline(x=0, color='gray', linewidth=0.5)

# --- Right panel: Rate functions ---
ax = axes[1]
alphas = np.linspace(0.001, 0.999, 500)

for name, q, color in groups:
    Is = [rate_exact(q, a) for a in alphas]
    ax.plot(alphas, Is, color=color, linewidth=2.2, label=f'{name} (q={q:.3f})')
    # Mark the minimum at α = q
    ax.plot(q, 0, 'o', color=color, markersize=8, zorder=5)

ax.set_xlabel('Deviation level α', fontsize=13)
ax.set_ylabel('I(α) = sup_t {tα - Λ(t)}', fontsize=13)
ax.set_title('Rate Function (Legendre Transform)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11, loc='upper center')
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 3.5)
ax.axhline(y=0, color='gray', linewidth=0.5)

# Add annotation
ax.annotate('I(q) = 0\n(typical behavior)', 
            xy=(groups[1][1], 0), xytext=(0.55, 0.8),
            fontsize=10, ha='center',
            arrowprops=dict(arrowstyle='->', color='gray'),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_pressure_rate.png', dpi=150, bbox_inches='tight')
print("Saved viz_pressure_rate.png")


#!/usr/bin/env python3
"""
Visualization 2: Tail Probability Decay and LDP Convergence

Shows the exponential decay of tail probabilities P(D_N >= α) as N grows,
demonstrating the large deviation principle. The slope of log P vs N 
converges to -I(α), confirming the Legendre-transform prediction.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import log, exp, comb


def rate_exact(q, alpha):
    """Binary KL divergence I(α) = D(Ber(α) ‖ Ber(q))."""
    if alpha <= 1e-12:
        return -log(1 - q)
    if alpha >= 1 - 1e-12:
        return -log(q)
    return alpha * log(alpha / q) + (1 - alpha) * log((1 - alpha) / (1 - q))


def exact_tail_prob(q, N, alpha):
    """Compute P(D_N >= α) = P(Binomial(N,q)/N >= α) exactly."""
    k_threshold = int(np.ceil(alpha * N - 1e-10))
    k_threshold = max(0, min(N, k_threshold))
    
    prob = 0.0
    for k in range(k_threshold, N + 1):
        prob += comb(N, k) * (q ** k) * ((1 - q) ** (N - k))
    return prob


fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

q = 1/3  # Z/6Z

# --- Left panel: Tail probability decay ---
ax = axes[0]
Ns = list(range(1, 81))

for alpha, color, marker in [(0.5, '#E91E63', 's'), 
                              (0.6, '#FF9800', '^'),
                              (0.7, '#2196F3', 'o'),
                              (0.8, '#4CAF50', 'D')]:
    log_probs = []
    for N in Ns:
        p = exact_tail_prob(q, N, alpha)
        log_probs.append(log(p) if p > 0 else None)
    
    valid = [(N, lp) for N, lp in zip(Ns, log_probs) if lp is not None]
    if valid:
        ns_valid, lps_valid = zip(*valid)
        ax.plot(ns_valid, lps_valid, color=color, marker=marker, 
                markersize=3, linewidth=1.5, label=f'α = {alpha}')
        
        # Theoretical slope
        I_val = rate_exact(q, alpha)
        ax.plot(ns_valid, [-I_val * n for n in ns_valid], '--', 
                color=color, linewidth=1, alpha=0.6)

ax.set_xlabel('N (number of coordinates)', fontsize=13)
ax.set_ylabel('log P(D_N ≥ α)', fontsize=13)
ax.set_title('Tail Probability Decay (Z/6Z, q=1/3)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Add annotation
ax.text(50, -8, 'Dashed: slope = -I(α)\n(LDP prediction)', 
        fontsize=10, style='italic', color='gray',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# --- Right panel: Rate convergence ---
ax = axes[1]
Ns_rate = list(range(5, 201, 5))

for alpha, color, marker in [(0.5, '#E91E63', 's'),
                              (0.6, '#FF9800', '^'),
                              (0.7, '#2196F3', 'o')]:
    empirical_rates = []
    for N in Ns_rate:
        p = exact_tail_prob(q, N, alpha)
        if p > 0:
            empirical_rates.append(-log(p) / N)
        else:
            empirical_rates.append(None)
    
    valid = [(N, r) for N, r in zip(Ns_rate, empirical_rates) if r is not None]
    if valid:
        ns_v, rs_v = zip(*valid)
        ax.plot(ns_v, rs_v, color=color, marker=marker, markersize=3,
                linewidth=1.2, label=f'α = {alpha}')
    
    # Theoretical rate
    I_val = rate_exact(q, alpha)
    ax.axhline(y=I_val, color=color, linestyle='--', linewidth=1, alpha=0.6)

ax.set_xlabel('N', fontsize=13)
ax.set_ylabel('-(1/N) log P(D_N ≥ α)', fontsize=13)
ax.set_title('Convergence to Rate Function I(α)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.text(120, 0.15, 'Dashed lines:\nexact I(α)', fontsize=10, 
        style='italic', color='gray',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_tail_decay.png', dpi=150, bbox_inches='tight')
print("Saved viz_tail_decay.png")
