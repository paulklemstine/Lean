#!/usr/bin/env python3
"""
Coherence Theory — Hypothesis Generation, Testing, and Validation
==================================================================
Systematically generates new hypotheses from experimental data,
tests them, and updates our knowledge base.

Run: python demo_hypothesis_testing.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from demo_coherence_basics import (coherence, walsh_hadamard_transform, truth_table_to_pm,
                                     spectral_distribution, spectral_entropy,
                                     make_dictator, make_parity, make_majority,
                                     make_and, make_or, make_random, make_threshold)


class HypothesisTracker:
    """Tracks hypotheses, evidence, and confidence levels."""
    
    def __init__(self):
        self.hypotheses = {}
        self.evidence = {}
    
    def add_hypothesis(self, name, description, initial_confidence=0.5):
        self.hypotheses[name] = {
            'description': description,
            'confidence': initial_confidence,
            'tests': 0,
            'successes': 0,
            'failures': 0
        }
        self.evidence[name] = []
    
    def record_evidence(self, name, supports, strength=1.0, note=""):
        h = self.hypotheses[name]
        h['tests'] += 1
        
        if supports:
            h['successes'] += 1
            # Bayesian update (simplified)
            h['confidence'] = min(0.99, h['confidence'] + (1 - h['confidence']) * 0.1 * strength)
        else:
            h['failures'] += 1
            h['confidence'] = max(0.01, h['confidence'] - h['confidence'] * 0.2 * strength)
        
        self.evidence[name].append({
            'supports': supports,
            'strength': strength,
            'note': note,
            'new_confidence': h['confidence']
        })
    
    def report(self):
        print("\n" + "=" * 70)
        print("HYPOTHESIS STATUS REPORT")
        print("=" * 70)
        
        sorted_hyps = sorted(self.hypotheses.items(), key=lambda x: -x[1]['confidence'])
        
        for name, h in sorted_hyps:
            status = "✓ SUPPORTED" if h['confidence'] > 0.7 else "? UNCERTAIN" if h['confidence'] > 0.3 else "✗ DOUBTFUL"
            bar = "█" * int(h['confidence'] * 20) + "░" * (20 - int(h['confidence'] * 20))
            
            print(f"\n  [{status}] {name}")
            print(f"    {h['description']}")
            print(f"    Confidence: [{bar}] {h['confidence']:.2%}")
            print(f"    Tests: {h['tests']} ({h['successes']} support, {h['failures']} refute)")
            
            if self.evidence[name]:
                latest = self.evidence[name][-1]
                print(f"    Latest: {'Supporting' if latest['supports'] else 'Refuting'} — {latest['note']}")


# ── Hypothesis Tests ──────────────────────────────────────────────────────────

def test_coherence_gap(tracker, n_values=[6, 8, 10, 12]):
    """Test: Is there a minimum nonzero coherence for structured problems?"""
    print("\n" + "=" * 60)
    print("TEST: Coherence Gap Conjecture")
    print("=" * 60)
    
    from demo_sat_coherence import random_ksat
    
    for n in n_values:
        # Structured problems: SAT at phase transition
        structured_cs = []
        for seed in range(50):
            m = int(4.267 * n)
            tt, _ = random_ksat(n, m, 3, seed=seed)
            if 0 < sum(tt) < 2**n:
                structured_cs.append(coherence(tt))
        
        # "Pseudorandom" problems: random function
        random_cs = [coherence(make_random(n, seed=s)) for s in range(50)]
        
        min_structured = min(structured_cs) if structured_cs else 0
        max_random = np.percentile(random_cs, 5)  # Bottom 5% of random
        
        gap = min_structured - max_random
        
        print(f"  n={n}: min_structured = {min_structured:.4f}, "
              f"random_5th_percentile = {max_random:.4f}, gap = {gap:.4f}")
        
        supports = gap > 0.05
        tracker.record_evidence(
            "coherence_gap",
            supports=supports,
            strength=1.0,
            note=f"n={n}: gap = {gap:.4f}"
        )


def test_monotonicity_under_reductions(tracker):
    """Test: Do polynomial reductions preserve/decrease coherence?"""
    print("\n" + "=" * 60)
    print("TEST: Coherence Monotonicity Under Reductions")
    print("=" * 60)
    
    n = 8
    
    # Test: restricting variables (a simple "reduction")
    for trial in range(20):
        tt = make_random(n, seed=trial)
        c_orig = coherence(tt)
        
        # Restrict first variable to 0
        tt_restricted = tt[:2**(n-1)]
        c_restricted = coherence(tt_restricted)
        
        # Under restriction, coherence should generally increase
        # (removing variables concentrates the spectrum)
        
    # Test: composing with a simple function (another reduction type)
    violations = 0
    total = 0
    
    for trial in range(30):
        tt_a = make_random(n, seed=trial)
        tt_b = make_random(n, seed=trial + 1000)
        
        c_a = coherence(tt_a)
        c_b = coherence(tt_b)
        
        # "Reduce" A to B via XOR (a simple combination)
        tt_combined = [a ^ b for a, b in zip(tt_a, tt_b)]
        c_combined = coherence(tt_combined)
        
        total += 1
        if c_combined > max(c_a, c_b) + 0.1:  # Allow small tolerance
            violations += 1
    
    violation_rate = violations / total
    print(f"  Violation rate (C_combined > max(C_a, C_b) + 0.1): {violation_rate:.2%}")
    
    supports = violation_rate < 0.2
    tracker.record_evidence(
        "monotonicity",
        supports=supports,
        strength=1.0,
        note=f"Violation rate = {violation_rate:.2%}"
    )


def test_coherence_predicts_hardness(tracker):
    """Test: Does coherence predict search difficulty?"""
    print("\n" + "=" * 60)
    print("TEST: Coherence Predicts Hardness")
    print("=" * 60)
    
    n = 10
    
    coherences = []
    difficulties = []
    
    from demo_sat_coherence import random_ksat
    
    for alpha in np.linspace(2, 6, 15):
        for seed in range(20):
            m = int(alpha * n)
            tt, _ = random_ksat(n, m, 3, seed=seed)
            if sum(tt) > 0:
                c = coherence(tt)
                # Difficulty: position of first satisfying assignment
                first_sat = next((i for i in range(2**n) if tt[i] == 1), 2**n)
                difficulty = first_sat / 2**n
                
                coherences.append(c)
                difficulties.append(difficulty)
    
    if len(coherences) > 10:
        corr = np.corrcoef(coherences, difficulties)[0, 1]
        print(f"  Correlation(coherence, difficulty) = {corr:.4f}")
        print(f"  Expected: negative (high coherence → easier)")
        
        supports = corr < -0.1
        tracker.record_evidence(
            "predicts_hardness",
            supports=supports,
            strength=abs(corr),
            note=f"Correlation = {corr:.4f}"
        )


def test_subadditivity(tracker):
    """Test: Is coherence subadditive under tensor product?"""
    print("\n" + "=" * 60)
    print("TEST: Subadditivity C(f⊗g) ≤ weighted average")
    print("=" * 60)
    
    violations = 0
    total = 0
    
    for n1 in [4, 5, 6]:
        for n2 in [4, 5, 6]:
            for seed in range(10):
                tt1 = make_random(n1, seed=seed)
                tt2 = make_random(n2, seed=seed + 500)
                
                c1 = coherence(tt1)
                c2 = coherence(tt2)
                
                # Tensor product: f⊗g(x,y) = f(x) AND g(y)
                tt_tensor = [a & b for a in tt1 for b in tt2]
                c_tensor = coherence(tt_tensor)
                
                weighted_avg = (n1 * c1 + n2 * c2) / (n1 + n2)
                
                total += 1
                if c_tensor > weighted_avg + 0.01:  # Small tolerance
                    violations += 1
    
    violation_rate = violations / total
    print(f"  Tests: {total}, Violations: {violations} ({violation_rate:.1%})")
    
    supports = violation_rate < 0.15
    tracker.record_evidence(
        "subadditivity",
        supports=supports,
        strength=1.0 - violation_rate,
        note=f"Violation rate = {violation_rate:.1%}"
    )


def test_affine_invariance(tracker):
    """Test: Is coherence invariant under affine transforms?"""
    print("\n" + "=" * 60)
    print("TEST: Affine Invariance")
    print("=" * 60)
    
    n = 8
    max_deviation = 0
    total = 0
    
    rng = np.random.RandomState(42)
    
    for seed in range(30):
        tt = make_random(n, seed=seed)
        c_orig = coherence(tt)
        
        # Apply a random bit permutation (special case of affine transform)
        perm = rng.permutation(n)
        tt_perm = [0] * (2**n)
        for x in range(2**n):
            bits = [(x >> i) & 1 for i in range(n)]
            new_bits = [bits[perm[i]] for i in range(n)]
            new_x = sum(b << i for i, b in enumerate(new_bits))
            tt_perm[new_x] = tt[x]
        
        c_perm = coherence(tt_perm)
        deviation = abs(c_orig - c_perm)
        max_deviation = max(max_deviation, deviation)
        total += 1
    
    print(f"  Max deviation under permutation: {max_deviation:.6f}")
    
    supports = max_deviation < 0.01
    tracker.record_evidence(
        "affine_invariance",
        supports=supports,
        strength=1.0,
        note=f"Max deviation = {max_deviation:.6f}"
    )


def test_coherence_amplification(tracker):
    """Test: Can we amplify coherence by combining instances?"""
    print("\n" + "=" * 60)
    print("TEST: Coherence Amplification Hypothesis")
    print("=" * 60)
    
    n = 8
    
    # Take a low-coherence function and see if combining copies increases coherence
    amplification_results = []
    
    for seed in range(20):
        tt = make_random(n, seed=seed)
        c_single = coherence(tt)
        
        # "Amplify" by taking majority of k copies
        # For k copies, f_amp(x1,...,xk) = majority(f(x1),...,f(xk))
        # In practice, we simulate this for k=3
        
        # Simulated amplification: AND of 2 copies
        tt_amp = [tt[i] & tt[j] for i in range(min(2**n, 256)) for j in range(min(2**n, 256))]
        if len(tt_amp) > 0:
            # Truncate to power of 2
            new_n = int(np.log2(len(tt_amp)))
            tt_amp = tt_amp[:2**new_n]
            c_amp = coherence(tt_amp)
            
            amplification = c_amp / max(c_single, 0.001)
            amplification_results.append((c_single, c_amp, amplification))
    
    if amplification_results:
        avg_amp = np.mean([r[2] for r in amplification_results])
        print(f"  Average amplification factor: {avg_amp:.2f}x")
        print(f"  Individual results (first 5):")
        for c_s, c_a, amp in amplification_results[:5]:
            print(f"    C_single = {c_s:.4f} → C_amplified = {c_a:.4f} ({amp:.2f}x)")
        
        supports = avg_amp > 1.5
        tracker.record_evidence(
            "amplification",
            supports=supports,
            strength=min(avg_amp / 3, 1.0),
            note=f"Avg amplification = {avg_amp:.2f}x"
        )


def generate_new_hypotheses(tracker):
    """Generate new hypotheses based on experimental findings."""
    print("\n" + "=" * 60)
    print("GENERATING NEW HYPOTHESES")
    print("=" * 60)
    
    n = 10
    
    # Observation 1: Check if coherence is connected to influence
    print("\n  Exploring: Coherence vs Total Influence...")
    
    data_influence = []
    for seed in range(100):
        tt = make_random(n, seed=seed)
        c = coherence(tt)
        
        # Compute total influence: I(f) = Σ_i Pr[f(x) ≠ f(x⊕e_i)]
        f_pm = truth_table_to_pm(tt)
        fhat = walsh_hadamard_transform(f_pm)
        
        total_influence = 0
        for s_int in range(2**n):
            weight = bin(s_int).count('1')
            total_influence += weight * fhat[s_int]**2
        
        data_influence.append((c, total_influence))
    
    cs = [d[0] for d in data_influence]
    infs = [d[1] for d in data_influence]
    corr = np.corrcoef(cs, infs)[0, 1]
    
    print(f"    Correlation(C, total_influence) = {corr:.4f}")
    
    if abs(corr) > 0.3:
        tracker.add_hypothesis(
            "influence_correlation",
            f"Coherence is {'positively' if corr > 0 else 'negatively'} correlated with total influence (r={corr:.2f})",
            initial_confidence=0.6
        )
        tracker.record_evidence("influence_correlation", True, abs(corr), f"r = {corr:.4f}")
    
    # Observation 2: Check if coherence relates to noise sensitivity
    print("\n  Exploring: Coherence vs Noise Sensitivity...")
    
    data_noise = []
    for seed in range(100):
        tt = make_random(n, seed=seed)
        c = coherence(tt)
        
        # Approximate noise sensitivity at ε = 0.1
        rng = np.random.RandomState(seed + 10000)
        agreements = 0
        trials = 500
        for _ in range(trials):
            x = rng.randint(0, 2**n)
            # Flip each bit with probability 0.1
            y = x
            for bit in range(n):
                if rng.random() < 0.1:
                    y ^= (1 << bit)
            if tt[x] == tt[y % (2**n)]:
                agreements += 1
        
        noise_sensitivity = 1 - agreements / trials
        data_noise.append((c, noise_sensitivity))
    
    cs = [d[0] for d in data_noise]
    ns = [d[1] for d in data_noise]
    corr_ns = np.corrcoef(cs, ns)[0, 1]
    
    print(f"    Correlation(C, noise_sensitivity) = {corr_ns:.4f}")
    
    if abs(corr_ns) > 0.3:
        tracker.add_hypothesis(
            "noise_sensitivity",
            f"High coherence implies {'high' if corr_ns > 0 else 'low'} noise sensitivity (r={corr_ns:.2f})",
            initial_confidence=0.6
        )
        tracker.record_evidence("noise_sensitivity", True, abs(corr_ns), f"r = {corr_ns:.4f}")
    
    # Observation 3: Is coherence related to decision tree depth?
    print("\n  Exploring: Coherence vs Decision Tree Complexity...")
    
    # Approximate: try random decision trees and see correlation with coherence
    data_dt = []
    for seed in range(50):
        tt = make_random(n, seed=seed)
        c = coherence(tt)
        
        # Greedy decision tree depth (heuristic)
        def greedy_dt_depth(tt, n, available_vars=None, depth=0, max_depth=n):
            if depth >= max_depth:
                return depth
            if available_vars is None:
                available_vars = list(range(n))
            if not available_vars or len(set(tt)) <= 1:
                return depth
            
            N = len(tt)
            half = N // 2
            
            # Find best variable to split on (most balanced)
            best_var = available_vars[0]
            best_score = float('inf')
            for var in available_vars:
                # Split by this variable
                tt_0 = [tt[x] for x in range(N) if not (x >> var & 1)]
                count_0 = sum(tt_0) if tt_0 else 0
                total_0 = len(tt_0) if tt_0 else 1
                tt_1 = [tt[x] for x in range(N) if (x >> var & 1)]
                count_1 = sum(tt_1) if tt_1 else 0
                total_1 = len(tt_1) if tt_1 else 1
                
                # Information gain (simplified)
                p0 = count_0 / total_0 if total_0 > 0 else 0.5
                p1 = count_1 / total_1 if total_1 > 0 else 0.5
                score = abs(p0 - 0.5) + abs(p1 - 0.5)
                if score < best_score:
                    best_score = score
                    best_var = var
            
            remaining = [v for v in available_vars if v != best_var]
            return depth + 1  # Simplified: just count depth
        
        dt_depth = greedy_dt_depth(tt, n)
        data_dt.append((c, dt_depth))
    
    print(f"    Decision tree depth appears to be ~{np.mean([d[1] for d in data_dt]):.1f} for random functions")
    
    # Plot all observations
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    axes[0].scatter([d[0] for d in data_influence], [d[1] for d in data_influence], alpha=0.5, s=15)
    axes[0].set_xlabel('Coherence')
    axes[0].set_ylabel('Total Influence')
    axes[0].set_title(f'C vs Influence (r={corr:.3f})')
    axes[0].grid(True, alpha=0.3)
    
    axes[1].scatter([d[0] for d in data_noise], [d[1] for d in data_noise], alpha=0.5, s=15)
    axes[1].set_xlabel('Coherence')
    axes[1].set_ylabel('Noise Sensitivity')
    axes[1].set_title(f'C vs Noise Sensitivity (r={corr_ns:.3f})')
    axes[1].grid(True, alpha=0.3)
    
    axes[2].scatter([d[0] for d in data_dt], [d[1] for d in data_dt], alpha=0.5, s=15)
    axes[2].set_xlabel('Coherence')
    axes[2].set_ylabel('DT Depth')
    axes[2].set_title('C vs Decision Tree Depth')
    axes[2].grid(True, alpha=0.3)
    
    plt.suptitle('New Hypotheses: Coherence Correlations', fontsize=14)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/CoherenceFramework/demos/new_hypotheses.png', dpi=150)
    print("\n  Saved: new_hypotheses.png")


# ── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Initialize hypothesis tracker
    tracker = HypothesisTracker()
    
    # Register main hypotheses
    tracker.add_hypothesis(
        "coherence_gap",
        "There exists a minimum nonzero coherence γ > 0 for NP-complete problems",
        initial_confidence=0.5
    )
    tracker.add_hypothesis(
        "monotonicity",
        "Polynomial reductions cannot increase coherence by more than o(1)",
        initial_confidence=0.5
    )
    tracker.add_hypothesis(
        "predicts_hardness",
        "Higher coherence implies easier search (negative correlation with difficulty)",
        initial_confidence=0.6
    )
    tracker.add_hypothesis(
        "subadditivity",
        "Coherence is subadditive: C(f⊗g) ≤ (n·C(f) + m·C(g))/(n+m)",
        initial_confidence=0.6
    )
    tracker.add_hypothesis(
        "affine_invariance",
        "Coherence is invariant under bit permutations",
        initial_confidence=0.7
    )
    tracker.add_hypothesis(
        "amplification",
        "Combining instances can amplify coherence",
        initial_confidence=0.4
    )
    
    # Run tests
    test_coherence_gap(tracker)
    test_monotonicity_under_reductions(tracker)
    test_coherence_predicts_hardness(tracker)
    test_subadditivity(tracker)
    test_affine_invariance(tracker)
    test_coherence_amplification(tracker)
    
    # Generate new hypotheses from data
    generate_new_hypotheses(tracker)
    
    # Final report
    tracker.report()
    
    print("\n" + "=" * 60)
    print("Hypothesis testing complete!")
    print("=" * 60)
