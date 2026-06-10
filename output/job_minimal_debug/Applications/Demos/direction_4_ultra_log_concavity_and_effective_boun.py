#!/usr/bin/env python3
"""
Real-World Applications of Ultra-Log-Concavity

Demonstrates how Newton's inequalities apply to:
  1. Statistical mechanics: Fermionic partition functions
  2. Probability theory: Concentration of sums of Bernoulli variables
  3. Combinatorics: Mason's conjecture for matroids
  4. Information theory: Entropy bounds for ULC distributions
"""

import math
from typing import List, Tuple
from algorithms import esp_via_recurrence, maclaurin_averages, ulc_verify


# ──────────────────────────────────────────────────────────────────
# Application 1: Fermionic Partition Functions
# ──────────────────────────────────────────────────────────────────

def fermionic_partition(activities: List[float]) -> List[float]:
    """Compute the fermionic partition function Z_k for k-particle states.
    
    In a noninteracting fermionic system with m single-particle modes
    and activities z_1,...,z_m, the k-particle partition function is:
      Z_k = e_k(z_1,...,z_m)
    
    This is the coefficient of x^k in ∏(1 + z_i·x).
    
    By ULC, the particle-number distribution is ultra-log-concave:
      (Z_k/C(m,k))² ≥ (Z_{k-1}/C(m,k-1)) · (Z_{k+1}/C(m,k+1))
    
    This implies strong concentration of the particle number.
    """
    return esp_via_recurrence(activities)


def demo_fermionic():
    """Demonstrate ULC for a fermionic system."""
    print("=" * 70)
    print("APPLICATION 1: Fermionic Partition Functions")
    print("=" * 70)
    
    # System: 6 fermionic modes with different activities
    activities = [0.5, 1.0, 1.5, 2.0, 3.0, 4.0]
    m = len(activities)
    Z = fermionic_partition(activities)
    Z_total = sum(Z)
    
    print(f"\n  System: {m} fermionic modes")
    print(f"  Activities: {activities}")
    print(f"  Total partition function: Z = {Z_total:.4f}")
    print(f"\n  {'k':>3}  {'Z_k':>10}  {'P(N=k)':>10}  {'ẽ_k':>10}  {'ULC margin':>12}")
    print(f"  {'─'*3}  {'─'*10}  {'─'*10}  {'─'*10}  {'─'*12}")
    
    avgs = maclaurin_averages(activities)
    result = ulc_verify(activities)
    
    for k in range(m + 1):
        prob = Z[k] / Z_total
        margin = result.margins[k-1] if 1 <= k < m else float('nan')
        margin_str = f"{margin:12.6f}" if 1 <= k < m else "           –"
        print(f"  {k:3d}  {Z[k]:10.4f}  {prob:10.6f}  {avgs[k]:10.6f}  {margin_str}")
    
    print(f"\n  ULC verified: {result.is_ulc}")
    print(f"  Min margin: {result.min_margin:.6f} at k = {result.min_margin_k}")
    print(f"\n  Physical interpretation:")
    print(f"    The particle-number distribution is ultra-log-concave,")
    print(f"    which implies stronger concentration than any log-concave bound.")
    print(f"    This is a consequence of the Pauli exclusion principle.")


# ──────────────────────────────────────────────────────────────────
# Application 2: Concentration of Bernoulli Sums
# ──────────────────────────────────────────────────────────────────

def bernoulli_sum_distribution(probs: List[float]) -> List[float]:
    """Compute P(S = k) where S = X_1 + ... + X_m, X_i ~ Bernoulli(p_i).
    
    The distribution is proportional to e_k(p_1/(1-p_1), ..., p_m/(1-p_m))
    times ∏(1-p_i). By ULC, this distribution is ultra-log-concave,
    which gives sharp concentration bounds.
    """
    m = len(probs)
    # Odds ratios
    odds = [p / (1 - p) for p in probs]
    base = math.prod(1 - p for p in probs)
    
    esp = esp_via_recurrence(odds)
    dist = [base * esp[k] for k in range(m + 1)]
    return dist


def demo_bernoulli():
    """Demonstrate ULC for sums of independent Bernoulli variables."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Concentration of Bernoulli Sums")
    print("=" * 70)
    
    probs = [0.1, 0.3, 0.5, 0.7, 0.9]
    m = len(probs)
    dist = bernoulli_sum_distribution(probs)
    
    print(f"\n  Bernoulli parameters: {probs}")
    print(f"  Expected sum: {sum(probs):.2f}")
    print(f"\n  {'k':>3}  {'P(S=k)':>10}  {'log P(S=k)':>12}")
    print(f"  {'─'*3}  {'─'*10}  {'─'*12}")
    
    for k in range(m + 1):
        log_p = math.log(dist[k]) if dist[k] > 0 else float('-inf')
        print(f"  {k:3d}  {dist[k]:10.6f}  {log_p:12.4f}")
    
    # Verify ULC via odds ratios
    odds = [p / (1 - p) for p in probs]
    result = ulc_verify(odds)
    
    print(f"\n  ULC of odds-ratio ESP: {result.is_ulc}")
    print(f"  This gives P(S=k)²/C(m,k)² ≥ P(S=k-1)·P(S=k+1)/(C(m,k-1)·C(m,k+1))")
    print(f"  — sharper than standard log-concavity concentration bounds.")


# ──────────────────────────────────────────────────────────────────
# Application 3: Mason's Conjecture (Partition Matroids)
# ──────────────────────────────────────────────────────────────────

def demo_mason():
    """Demonstrate ULC for partition matroid rank sequences."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Mason's Conjecture for Partition Matroids")
    print("=" * 70)
    
    # Partition matroid: blocks of sizes b_1,...,b_m, capacity 1 per block
    # Independent sets of size k correspond to choosing 0 or 1 element from each block
    # Number of independent sets of size k = e_k(b_1,...,b_m)
    
    block_sizes = [3, 5, 7, 2, 4]
    m = len(block_sizes)
    
    print(f"\n  Partition matroid with {m} blocks of sizes {block_sizes}")
    
    I = esp_via_recurrence([float(b) for b in block_sizes])
    result = ulc_verify([float(b) for b in block_sizes])
    
    print(f"\n  {'k':>3}  {'I_k':>10}  {'ẽ_k':>10}  {'ULC margin':>12}")
    print(f"  {'─'*3}  {'─'*10}  {'─'*10}  {'─'*12}")
    
    avgs = result.maclaurin_avgs
    for k in range(m + 1):
        margin = result.margins[k-1] if 1 <= k < m else float('nan')
        margin_str = f"{margin:12.2f}" if 1 <= k < m else "           –"
        print(f"  {k:3d}  {I[k]:10.0f}  {avgs[k]:10.4f}  {margin_str}")
    
    print(f"\n  ULC verified: {result.is_ulc}")
    print(f"  This confirms Mason's conjecture for this partition matroid:")
    print(f"  the number of independent sets of each size satisfies ULC.")


# ──────────────────────────────────────────────────────────────────
# Application 4: Entropy Bounds for ULC Distributions
# ──────────────────────────────────────────────────────────────────

def shannon_entropy(dist: List[float]) -> float:
    """Compute Shannon entropy H = -Σ p_k log p_k."""
    total = sum(dist)
    return -sum(p/total * math.log(p/total) for p in dist if p > 0)


def binomial_entropy(m: int, p: float) -> float:
    """Compute entropy of Binomial(m, p)."""
    if p <= 0 or p >= 1:
        return 0.0
    dist = [math.comb(m, k) * p**k * (1-p)**(m-k) for k in range(m+1)]
    return shannon_entropy(dist)


def demo_entropy():
    """Demonstrate entropy bounds for ULC distributions."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Entropy Bounds for ULC Distributions")
    print("=" * 70)
    
    m = 6
    print(f"\n  Comparing entropies of ULC distributions on {{0,...,{m}}}")
    print(f"  Conjecture: Binomial(m, μ/m) maximizes entropy among ULC distributions")
    
    # Generate several ULC distributions from different weight vectors
    weight_sets = [
        [1.0, 2.0, 3.0, 4.0, 5.0, 6.0],
        [0.5, 1.0, 1.5, 2.0, 2.5, 3.0],
        [1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
        [0.1, 0.5, 1.0, 2.0, 5.0, 10.0],
    ]
    
    print(f"\n  {'Weights':>35}  {'μ':>6}  {'H(dist)':>8}  {'H(Bin)':>8}  {'H≤H_Bin?':>10}")
    print(f"  {'─'*35}  {'─'*6}  {'─'*8}  {'─'*8}  {'─'*10}")
    
    for w in weight_sets:
        esp = esp_via_recurrence(w)
        total = sum(esp)
        dist = [e / total for e in esp]
        mu = sum(k * dist[k] for k in range(m + 1))
        
        H = shannon_entropy(esp)
        H_bin = binomial_entropy(m, mu / m)
        
        label = str([round(x, 1) for x in w])
        check = "✓" if H <= H_bin + 1e-10 else "✗"
        print(f"  {label:>35}  {mu:6.3f}  {H:8.4f}  {H_bin:8.4f}  {check:>10}")


# ──────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Ultra-Log-Concavity                           ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    demo_fermionic()
    demo_bernoulli()
    demo_mason()
    demo_entropy()
    
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Ultra-Log-Concavity Interactive Demonstration

Demonstrates Newton's inequalities for elementary symmetric polynomials:
the Maclaurin averages ẽ_k = e_k(w)/C(m,k) form a log-concave sequence
when all weights are positive.

Usage:
    python demo.py           # Run all demonstrations
    python demo.py --visual  # Generate plots (requires matplotlib)
"""

import math
import sys
from itertools import combinations
from typing import List, Tuple

# ──────────────────────────────────────────────────────────────────
# Core mathematical functions
# ──────────────────────────────────────────────────────────────────

def elementary_symmetric(w: List[float], k: int) -> float:
    """Compute the k-th elementary symmetric polynomial e_k(w).
    
    e_k(w_1,...,w_m) = sum of all products of k distinct elements of w.
    """
    m = len(w)
    if k < 0 or k > m:
        return 0.0
    if k == 0:
        return 1.0
    return sum(math.prod(w[i] for i in combo)
               for combo in combinations(range(m), k))


def maclaurin_avg(w: List[float], k: int) -> float:
    """Compute the k-th Maclaurin average ẽ_k = e_k(w) / C(m,k).
    
    These are the normalized elementary symmetric polynomials.
    """
    m = len(w)
    binom = math.comb(m, k)
    if binom == 0:
        return 0.0
    return elementary_symmetric(w, k) / binom


def ulc_margin(w: List[float], k: int) -> float:
    """Compute the ultra-log-concavity margin at position k.
    
    margin = ẽ_k² - ẽ_{k-1} · ẽ_{k+1}
    Positive margin means ULC holds at this position.
    """
    return maclaurin_avg(w, k)**2 - maclaurin_avg(w, k-1) * maclaurin_avg(w, k+1)


def min_ulc_margin(w: List[float]) -> float:
    """Minimum ULC margin across all valid positions."""
    m = len(w)
    if m <= 1:
        return 0.0
    return min(ulc_margin(w, k) for k in range(1, m))


def weight_heterogeneity(w: List[float]) -> float:
    """Compute H = (w_max - w_min) / (w_max + w_min)."""
    wmax, wmin = max(w), min(w)
    return (wmax - wmin) / (wmax + wmin)


# ──────────────────────────────────────────────────────────────────
# Demonstrations
# ──────────────────────────────────────────────────────────────────

def demo_basic_ulc():
    """Demonstrate basic ultra-log-concavity for small examples."""
    print("=" * 70)
    print("DEMO 1: Ultra-Log-Concavity for Small Weight Vectors")
    print("=" * 70)
    
    examples = [
        [1.0, 2.0, 3.0],
        [1.0, 1.0, 1.0],
        [0.5, 1.0, 2.0, 4.0],
        [1.0, 1.0, 1.0, 1.0, 1.0],
        [1.0, 10.0, 100.0],
    ]
    
    for w in examples:
        m = len(w)
        print(f"\nWeights w = {w} (m = {m})")
        print(f"  Heterogeneity H = {weight_heterogeneity(w):.4f}")
        print(f"  {'k':>3}  {'e_k':>12}  {'C(m,k)':>8}  {'ẽ_k':>12}  {'margin':>12}  {'ULC?':>5}")
        print(f"  {'─'*3}  {'─'*12}  {'─'*8}  {'─'*12}  {'─'*12}  {'─'*5}")
        
        for k in range(m + 1):
            ek = elementary_symmetric(w, k)
            ck = math.comb(m, k)
            ek_tilde = maclaurin_avg(w, k)
            margin = ulc_margin(w, k) if 1 <= k < m else float('nan')
            ulc_ok = "  ✓" if 1 <= k < m and margin >= -1e-12 else ("  ✗" if 1 <= k < m else "  –")
            margin_str = f"{margin:12.6f}" if 1 <= k < m else "           –"
            print(f"  {k:3d}  {ek:12.4f}  {ck:8d}  {ek_tilde:12.6f}  {margin_str}  {ulc_ok}")
        
        min_margin = min_ulc_margin(w)
        print(f"  Minimum margin: {min_margin:.6f}")


def demo_uniform_equality():
    """Show that uniform weights give equality in ULC."""
    print("\n" + "=" * 70)
    print("DEMO 2: Uniform Weights Give Equality (ẽ_k = c^k)")
    print("=" * 70)
    
    for m in [3, 5, 8]:
        for c in [1.0, 2.0, 0.5]:
            w = [c] * m
            print(f"\n  m = {m}, c = {c}: ẽ_k = c^k")
            for k in range(m + 1):
                ek_tilde = maclaurin_avg(w, k)
                expected = c ** k
                print(f"    ẽ_{k} = {ek_tilde:.6f}  (expected c^{k} = {expected:.6f},"
                      f" diff = {abs(ek_tilde - expected):.2e})")


def demo_am_gm():
    """Show that ULC for m=2 is AM-GM."""
    print("\n" + "=" * 70)
    print("DEMO 3: ULC for m = 2 is AM-GM")
    print("=" * 70)
    
    pairs = [(1, 4), (2, 8), (3, 3), (1, 100), (0.1, 10)]
    for a, b in pairs:
        w = [float(a), float(b)]
        am = (a + b) / 2
        gm = math.sqrt(a * b)
        margin = ulc_margin(w, 1)
        print(f"\n  w = [{a}, {b}]")
        print(f"    AM = {am:.4f}, GM = {gm:.4f}")
        print(f"    ẽ₁² = {maclaurin_avg(w, 1)**2:.6f}")
        print(f"    ẽ₀·ẽ₂ = {maclaurin_avg(w, 0) * maclaurin_avg(w, 2):.6f}")
        print(f"    Margin = {margin:.6f} ≥ 0  ({'✓' if margin >= -1e-12 else '✗'})")
        print(f"    (This is (AM² - GM²) = ((a-b)/2)² = {((a-b)/2)**2:.6f})")


def demo_convergence_to_equality():
    """Animate convergence to equality as weights become uniform."""
    print("\n" + "=" * 70)
    print("DEMO 4: Convergence to Equality as Weights Become Uniform")
    print("=" * 70)
    
    m = 5
    w_base = [1.0, 2.0, 3.0, 4.0, 5.0]
    mean_w = sum(w_base) / m
    
    print(f"\n  Base weights: {w_base}")
    print(f"  Mean: {mean_w}")
    print(f"  Interpolating w(t) = (1-t)·w_base + t·mean toward uniform...")
    print(f"\n  {'t':>6}  {'min_margin':>12}  {'heterogeneity':>14}  {'status':>8}")
    print(f"  {'─'*6}  {'─'*12}  {'─'*14}  {'─'*8}")
    
    for t in [0.0, 0.1, 0.2, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99, 1.0]:
        w_t = [(1 - t) * wi + t * mean_w for wi in w_base]
        margin = min_ulc_margin(w_t)
        H = weight_heterogeneity(w_t)
        status = "equality" if abs(margin) < 1e-10 else "strict"
        print(f"  {t:6.2f}  {margin:12.8f}  {H:14.8f}  {status:>8}")


def demo_tropical_conjecture():
    """Test the tropical ULC margin bound conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 5: Testing Tropical ULC Margin Bound Conjecture")
    print("=" * 70)
    
    import random
    random.seed(42)
    
    n_tests = 10000
    n_pass = 0
    n_fail = 0
    min_ratio = float('inf')
    worst_case = None
    
    for _ in range(n_tests):
        m = random.randint(3, 15)
        w = sorted([random.uniform(0.1, 10.0) for _ in range(m)], reverse=True)
        wmax, wmin = w[0], w[-1]
        
        for k in range(1, m):
            lhs = ulc_margin(w, k)
            rhs = (wmax - wmin)**2 / (4 * m**2 * wmax * wmin) * (k * (m - k)) / (m - 1)
            
            if lhs < rhs - 1e-12:
                n_fail += 1
                if worst_case is None:
                    worst_case = (w, k, lhs, rhs)
            else:
                n_pass += 1
                if rhs > 1e-15:
                    ratio = lhs / rhs
                    if ratio < min_ratio:
                        min_ratio = ratio
    
    print(f"\n  Tests: {n_tests} weight vectors, {n_pass + n_fail} total (k,w) pairs")
    print(f"  Passed: {n_pass}")
    print(f"  Failed: {n_fail}")
    print(f"  Tightest ratio (LHS/RHS): {min_ratio:.4f}")
    
    if worst_case:
        w, k, lhs, rhs = worst_case
        print(f"\n  Counterexample found!")
        print(f"    w = {[round(x, 3) for x in w]}")
        print(f"    k = {k}, LHS = {lhs:.8f}, RHS = {rhs:.8f}")
    else:
        print(f"\n  No counterexample found — conjecture holds in all tested cases.")


def demo_visual():
    """Generate visual plots (requires matplotlib)."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib not available — skipping visual demos.")
        return
    
    # Plot 1: Maclaurin averages vs binomial coefficients
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Panel 1: Maclaurin averages for different weight vectors
    ax = axes[0, 0]
    weight_sets = {
        'uniform [2,2,2,2,2]': [2.0]*5,
        'mild [1,2,3,4,5]': [1,2,3,4,5],
        'extreme [0.1,1,10,100,1000]': [0.1,1,10,100,1000],
    }
    for label, w in weight_sets.items():
        m = len(w)
        ks = list(range(m + 1))
        ek_tildes = [maclaurin_avg(w, k) for k in ks]
        ax.semilogy(ks, [max(e, 1e-15) for e in ek_tildes], 'o-', label=label)
    ax.set_xlabel('k')
    ax.set_ylabel('Maclaurin average ẽ_k (log scale)')
    ax.set_title('Maclaurin Averages for Various Weights')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: ULC margins
    ax = axes[0, 1]
    for label, w in weight_sets.items():
        m = len(w)
        ks = list(range(1, m))
        margins = [ulc_margin(w, k) for k in ks]
        ax.plot(ks, margins, 'o-', label=label)
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5, label='ULC boundary')
    ax.set_xlabel('k')
    ax.set_ylabel('ULC margin')
    ax.set_title('Ultra-Log-Concavity Margins')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Margin vs heterogeneity
    ax = axes[1, 0]
    import random
    random.seed(123)
    hs, margins_list = [], []
    for _ in range(500):
        m = 5
        w = sorted([random.uniform(0.1, 10.0) for _ in range(m)], reverse=True)
        hs.append(weight_heterogeneity(w))
        margins_list.append(min_ulc_margin(w))
    ax.scatter(hs, margins_list, s=5, alpha=0.3)
    ax.set_xlabel('Weight heterogeneity H')
    ax.set_ylabel('Minimum ULC margin')
    ax.set_title('ULC Margin vs Weight Heterogeneity (m=5)')
    ax.grid(True, alpha=0.3)
    
    # Panel 4: Convergence to equality
    ax = axes[1, 1]
    m = 8
    w_base = list(range(1, m+1))
    mean_w = sum(w_base) / m
    ts = np.linspace(0, 1, 100)
    margins_conv = []
    for t in ts:
        w_t = [(1-t)*wi + t*mean_w for wi in w_base]
        margins_conv.append(min_ulc_margin(w_t))
    ax.plot(ts, margins_conv, 'b-', linewidth=2)
    ax.set_xlabel('Interpolation parameter t')
    ax.set_ylabel('Minimum ULC margin')
    ax.set_title('Convergence to Equality (m=8)')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('ulc_demo.png', dpi=150)
    print(f"  Plot saved to ulc_demo.png")


# ──────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Ultra-Log-Concavity: Newton's Inequalities Demo               ║")
    print("║  The Hidden Convexity in Every Polynomial                       ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    demo_basic_ulc()
    demo_uniform_equality()
    demo_am_gm()
    demo_convergence_to_equality()
    demo_tropical_conjecture()
    
    if "--visual" in sys.argv:
        print("\n" + "=" * 70)
        print("VISUAL DEMO: Generating plots...")
        print("=" * 70)
        demo_visual()
    
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
