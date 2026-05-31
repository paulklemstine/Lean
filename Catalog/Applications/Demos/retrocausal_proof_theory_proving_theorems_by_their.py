#!/usr/bin/env python3
"""
Retrocausal Proof Theory: Interactive Demo

Demonstrates the core concepts:
1. Consequence narrowing on a concrete example
2. Unique survivor detection
3. Compression conjecture testing
4. Self-certifying proposition identification
5. Adaptive consequence selection
"""

import numpy as np
from algorithms import (
    HypothesisSpace, ConsequenceOracle,
    candidates_consistent_with, retrocausal_search,
    adaptive_consequence_selection, test_compression_conjecture,
    is_consequence_stable, is_self_certifying,
    compression_factor, proof_search_reduction
)


def demo_basic_narrowing():
    """Demo 1: Basic consequence narrowing on a small example."""
    print("=" * 60)
    print("DEMO 1: Consequence Narrowing")
    print("=" * 60)
    
    # 5 hypotheses, 4 worlds, 3 consequences
    hs = HypothesisSpace(
        n=5, m=4,
        eval=np.array([
            [True,  True,  False, False],  # H0: true in worlds 0,1
            [False, True,  True,  False],  # H1: true in worlds 1,2
            [True,  False, True,  False],  # H2: true in worlds 0,2
            [False, False, True,  True ],  # H3: true in worlds 2,3
            [True,  True,  True,  False],  # H4: true in worlds 0,1,2
        ])
    )
    
    co = ConsequenceOracle(
        k=3, m=4,
        test=np.array([
            [True,  True,  False, True ],  # C0: true in worlds 0,1,3
            [True,  False, True,  True ],  # C1: true in worlds 0,2,3
            [False, True,  True,  True ],  # C2: true in worlds 1,2,3
        ])
    )
    
    print("\nHypothesis Space (eval[h,w]):")
    for h in range(hs.n):
        worlds = [w for w in range(hs.m) if hs.eval[h, w]]
        print(f"  H{h}: holds in worlds {worlds}")
    
    print("\nConsequence Oracle (test[c,w]):")
    for c in range(co.k):
        worlds = [w for w in range(co.m) if co.test[c, w]]
        print(f"  C{c}: holds in worlds {worlds}")
    
    # Show progressive narrowing
    print("\nProgressive Narrowing:")
    for num_consequences in range(co.k + 1):
        consequences = set(range(num_consequences))
        candidates = candidates_consistent_with(hs, co, consequences)
        print(f"  After {num_consequences} consequences: "
              f"candidates = {sorted(candidates)} "
              f"(|C| = {len(candidates)})")
    
    print()


def demo_unique_survivor():
    """Demo 2: Unique survivor detection."""
    print("=" * 60)
    print("DEMO 2: Unique Survivor Detection")
    print("=" * 60)
    
    np.random.seed(42)
    n, m, k = 20, 10, 8
    hs = HypothesisSpace.random(n, m, density=0.3)
    co = ConsequenceOracle.random(k, m, density=0.6)
    
    consequences = list(range(k))
    candidates, steps = retrocausal_search(hs, co, consequences)
    
    print(f"\nHypothesis space: {n} candidates, {m} worlds, {k} consequences")
    print(f"Search terminated after {steps} consequence verifications")
    print(f"Surviving candidates: {sorted(candidates)}")
    
    if len(candidates) == 1:
        print(f"✓ UNIQUE SURVIVOR: H{list(candidates)[0]}")
    elif len(candidates) == 0:
        print("✗ INCONSISTENT: No candidates survive")
    else:
        print(f"◇ {len(candidates)} candidates remain — more consequences needed")
    
    # Show reduction
    reduction = proof_search_reduction(hs, co, set(consequences))
    print(f"Proof search reduction: {reduction}/{n} candidates eliminated "
          f"({100*reduction/n:.1f}%)")
    print()


def demo_compression_conjecture():
    """Demo 3: Test the compression conjecture."""
    print("=" * 60)
    print("DEMO 3: Compression Conjecture Testing")
    print("=" * 60)
    
    np.random.seed(123)
    
    configs = [
        (100, 3, 20),
        (100, 5, 20),
        (100, 7, 20),
        (200, 5, 30),
        (200, 8, 30),
    ]
    
    print(f"\n{'n':>6} {'k':>4} {'m':>4} {'bound':>6} {'mean':>8} "
          f"{'max':>6} {'holds%':>8}")
    print("-" * 50)
    
    for n, k, m in configs:
        result = test_compression_conjecture(n, k, m, trials=500)
        print(f"{n:>6} {k:>4} {m:>4} {result['theoretical_bound']:>6} "
              f"{result['mean_survivors']:>8.2f} {result['max_survivors']:>6} "
              f"{result['conjecture_holds_pct']:>7.1f}%")
    
    print()


def demo_self_certifying():
    """Demo 4: Self-certifying proposition identification."""
    print("=" * 60)
    print("DEMO 4: Self-Certifying Propositions")
    print("=" * 60)
    
    np.random.seed(77)
    n, m, k = 8, 6, 5
    hs = HypothesisSpace.random(n, m, density=0.3)
    co = ConsequenceOracle.random(k, m, density=0.5)
    
    print(f"\nHypothesis space: {n} candidates, {m} worlds, {k} consequences")
    print()
    
    for target in range(n):
        result = is_self_certifying(hs, co, target)
        if result is not None:
            print(f"  H{target}: SELF-CERTIFYING via consequences {sorted(result)}")
        else:
            all_cons = candidates_consistent_with(hs, co, set(range(k)))
            if target in all_cons:
                print(f"  H{target}: not self-certifying "
                      f"(ambiguous with {sorted(all_cons - {target})})")
            else:
                print(f"  H{target}: eliminated by consequences")
    
    print()


def demo_adaptive_selection():
    """Demo 5: Adaptive consequence selection."""
    print("=" * 60)
    print("DEMO 5: Adaptive Consequence Selection")
    print("=" * 60)
    
    np.random.seed(99)
    n, m, k = 50, 15, 10
    hs = HypothesisSpace.random(n, m, density=0.3)
    co = ConsequenceOracle.random(k, m, density=0.5)
    
    # Compare random order vs adaptive
    random_order = list(range(k))
    _, random_steps = retrocausal_search(hs, co, random_order)
    
    adaptive_order = adaptive_consequence_selection(hs, co, set(range(k)))
    _, adaptive_steps = retrocausal_search(hs, co, adaptive_order)
    
    print(f"\nHypothesis space: {n} candidates, {m} worlds, {k} consequences")
    print(f"Random order:   {random_steps} steps to convergence")
    print(f"Adaptive order: {adaptive_steps} steps to convergence")
    print(f"Adaptive order selected: {adaptive_order}")
    
    # Show narrowing profile
    print("\nNarrowing profile (adaptive):")
    candidates = set(range(n))
    for i, c in enumerate(adaptive_order):
        candidates = {h for h in candidates
                      if all(True for _ in [1]  # dummy
                             if np.all(~hs.eval[h] | co.test[c]))}
        # Recompute properly
        new_candidates = set()
        for h in candidates:
            h_worlds = hs.eval[h]
            c_worlds = co.test[c]
            if np.all(~h_worlds | c_worlds):
                new_candidates.add(h)
        candidates = new_candidates
        print(f"  After C{c}: {len(candidates)} candidates remain")
        if len(candidates) <= 1:
            break
    
    print()


def demo_stability():
    """Demo 6: Consequence stability detection."""
    print("=" * 60)
    print("DEMO 6: Consequence Stability")
    print("=" * 60)
    
    np.random.seed(55)
    n, m, k = 10, 8, 6
    hs = HypothesisSpace.random(n, m, density=0.3)
    co = ConsequenceOracle.random(k, m, density=0.5)
    
    print(f"\nHypothesis space: {n} candidates, {m} worlds, {k} consequences")
    
    # Check stability at each subset size
    for size in range(k + 1):
        verified = set(range(size))
        candidates = candidates_consistent_with(hs, co, verified)
        stable = is_consequence_stable(hs, co, verified)
        status = "STABLE ✓" if stable else "not stable"
        print(f"  {size} consequences: {len(candidates)} candidates — {status}")
    
    print()


if __name__ == "__main__":
    print("\n" + "═" * 60)
    print("   RETROCAUSAL PROOF THEORY — DEMONSTRATION SUITE")
    print("═" * 60 + "\n")
    
    demo_basic_narrowing()
    demo_unique_survivor()
    demo_compression_conjecture()
    demo_self_certifying()
    demo_adaptive_selection()
    demo_stability()
    
    print("═" * 60)
    print("   All demos completed successfully.")
    print("═" * 60)


#!/usr/bin/env python3
"""
Visualization: Compression Conjecture Testing

Tests the retrocausal compression conjecture across different
parameter settings and visualizes the distribution of survivor counts.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def random_hypothesis_space(n, m, density=0.5):
    return np.random.random((n, m)) < density


def random_consequence_oracle(k, m, density=0.5):
    return np.random.random((k, m)) < density


def count_survivors(hs, co):
    n, m = hs.shape
    k = co.shape[0]
    count = 0
    for h in range(n):
        consistent = True
        for c in range(k):
            if not bool(np.all(~hs[h] | co[c])):
                consistent = False
                break
        if consistent:
            count += 1
    return count


def main():
    np.random.seed(123)
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))
    
    configs = [
        (100, 3, 20), (100, 5, 20), (100, 7, 20),
        (200, 5, 30), (200, 8, 30), (500, 10, 40),
    ]
    
    for ax, (n, k, m) in zip(axes.flat, configs):
        survivors = []
        trials = 500
        for _ in range(trials):
            hs = random_hypothesis_space(n, m)
            co = random_consequence_oracle(k, m)
            survivors.append(count_survivors(hs, co))
        
        bound = n // (2 ** k) + 1
        mean_s = np.mean(survivors)
        violations = sum(1 for s in survivors if s > bound)
        
        ax.hist(survivors, bins=max(20, max(survivors) - min(survivors) + 1),
                color='#2196F3', alpha=0.7, edgecolor='white')
        ax.axvline(bound, color='#F44336', linewidth=2, linestyle='--',
                   label=f'Bound: {bound}')
        ax.axvline(mean_s, color='#4CAF50', linewidth=2, linestyle=':',
                   label=f'Mean: {mean_s:.1f}')
        
        ax.set_title(f'n={n}, k={k}, m={m}\n'
                     f'Violations: {violations}/{trials} '
                     f'({100*violations/trials:.1f}%)')
        ax.set_xlabel('Surviving Candidates')
        ax.set_ylabel('Frequency')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Compression Conjecture: Distribution of Survivor Counts',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('compression_conjecture.png', dpi=150, bbox_inches='tight')
    print("Saved: compression_conjecture.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Idempotent Collapse Bridge

Demonstrates the connection between consequence filtering and
idempotent oracle dynamics from Dynamical Proof Complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def random_hypothesis_space(n, m, density=0.5):
    return np.random.random((n, m)) < density


def random_consequence_oracle(k, m, density=0.5):
    return np.random.random((k, m)) < density


def consequence_update(hs, co, c, candidates):
    """Apply consequence c to filter candidates."""
    result = set()
    for h in candidates:
        if bool(np.all(~hs[h] | co[c])):
            result.add(h)
    return result


def main():
    np.random.seed(42)
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Demo 1: Idempotence verification
    ax = axes[0]
    n, m, k = 100, 20, 10
    hs = random_hypothesis_space(n, m)
    co = random_consequence_oracle(k, m)
    
    sizes_once = []
    sizes_twice = []
    candidates_full = set(range(n))
    for c in range(k):
        after_once = consequence_update(hs, co, c, candidates_full)
        after_twice = consequence_update(hs, co, c, after_once)
        sizes_once.append(len(after_once))
        sizes_twice.append(len(after_twice))
    
    x = range(k)
    ax.bar([i - 0.15 for i in x], sizes_once, 0.3, color='#2196F3',
           label='After 1 application', alpha=0.8)
    ax.bar([i + 0.15 for i in x], sizes_twice, 0.3, color='#F44336',
           label='After 2 applications', alpha=0.8)
    ax.set_xlabel('Consequence Index')
    ax.set_ylabel('Candidate Set Size')
    ax.set_title('Idempotence: f(f(X)) = f(X)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Demo 2: Stabilization depth
    ax = axes[1]
    trials = 50
    stabilization_depths = []
    for _ in range(trials):
        hs_r = random_hypothesis_space(n, m)
        co_r = random_consequence_oracle(k, m)
        cands = set(range(n))
        depth = 0
        for c in range(k):
            new_cands = consequence_update(hs_r, co_r, c, cands)
            if new_cands == cands:
                break
            cands = new_cands
            depth += 1
        stabilization_depths.append(depth)
    
    ax.hist(stabilization_depths, bins=range(k + 2), color='#4CAF50',
            alpha=0.7, edgecolor='white')
    ax.set_xlabel('Stabilization Depth')
    ax.set_ylabel('Frequency')
    ax.set_title(f'Stabilization Depth Distribution\n(n={n}, k={k}, {trials} trials)')
    ax.grid(True, alpha=0.3)
    
    # Demo 3: Contraction visualization
    ax = axes[2]
    hs3 = random_hypothesis_space(50, 15)
    co3 = random_consequence_oracle(8, 15)
    
    sizes = [50]
    cands = set(range(50))
    for c in range(8):
        cands = consequence_update(hs3, co3, c, cands)
        sizes.append(len(cands))
    
    colors = plt.cm.RdYlGn(np.linspace(0.2, 0.8, len(sizes)))
    ax.bar(range(len(sizes)), sizes, color=colors, edgecolor='white')
    ax.set_xlabel('After Consequence #')
    ax.set_ylabel('Candidate Set Size')
    ax.set_title('Contraction: Monotone Narrowing')
    ax.set_xticks(range(len(sizes)))
    ax.set_xticklabels(['init'] + [str(i) for i in range(8)])
    ax.grid(True, alpha=0.3)
    
    plt.suptitle('Bridge to Dynamical Proof Complexity: Idempotent Oracle Collapse',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('idempotent_collapse.png', dpi=150, bbox_inches='tight')
    print("Saved: idempotent_collapse.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Consequence Narrowing Profile

Shows how the candidate set shrinks as consequences are verified,
demonstrating the monotonic narrowing property.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def random_hypothesis_space(n, m, density=0.5):
    return np.random.random((n, m)) < density


def random_consequence_oracle(k, m, density=0.5):
    return np.random.random((k, m)) < density


def is_consistent(hs_row, co_row):
    return bool(np.all(~hs_row | co_row))


def compute_narrowing_profile(hs, co):
    n, m = hs.shape
    k = co.shape[0]
    profile = [n]
    candidates = set(range(n))
    for c in range(k):
        candidates = {h for h in candidates if is_consistent(hs[h], co[c])}
        profile.append(len(candidates))
    return profile


def main():
    np.random.seed(42)
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    configs = [
        (50, 20, 8, "Small (n=50, k=8)"),
        (200, 30, 12, "Medium (n=200, k=12)"),
        (1000, 50, 15, "Large (n=1000, k=15)"),
    ]
    
    for ax, (n, m, k, title) in zip(axes, configs):
        for trial in range(20):
            hs = random_hypothesis_space(n, m)
            co = random_consequence_oracle(k, m)
            profile = compute_narrowing_profile(hs, co)
            alpha = 0.3 if trial > 0 else 1.0
            color = '#2196F3' if trial > 0 else '#F44336'
            ax.plot(range(k + 1), profile, '-o', markersize=3,
                    alpha=alpha, color=color, linewidth=1)
        
        # Theoretical bound
        theoretical = [n / (2 ** c) for c in range(k + 1)]
        ax.plot(range(k + 1), theoretical, '--', color='#4CAF50',
                linewidth=2, label='n/2^k bound')
        
        ax.set_xlabel('Consequences Verified')
        ax.set_ylabel('Surviving Candidates')
        ax.set_title(title)
        ax.set_yscale('log')
        ax.legend()
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Retrocausal Narrowing: Candidate Set Shrinks with Consequence Verification',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('narrowing_profile.png', dpi=150, bbox_inches='tight')
    print("Saved: narrowing_profile.png")


if __name__ == "__main__":
    main()
