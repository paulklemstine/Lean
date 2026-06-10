#!/usr/bin/env python3
"""
Applications of Submodular Tropical Witnesses

Demonstrates real-world applications of the log-det submodularity framework:
1. Diverse subset selection via greedy maximization
2. Sensor placement optimization
3. Feature selection with diminishing returns
4. Kernel-based diversity sampling

Each application shows how the mathematical structure (submodularity,
diminishing returns, greedy bounds) translates to practical algorithms.
"""

import numpy as np
from itertools import combinations


def random_psd_kernel(n, seed=None, scale=1.0):
    """Generate a random PSD kernel."""
    if seed is not None:
        np.random.seed(seed)
    M = scale * np.random.randn(n, n)
    K = M.T @ M + 0.01 * np.eye(n)
    return K


def log_det(K, subset):
    """Compute log det K[S]."""
    if len(subset) == 0:
        return 0.0
    idx = list(subset)
    det_val = np.linalg.det(K[np.ix_(idx, idx)])
    return np.log(max(det_val, 1e-300))


def greedy_diverse_selection(K, k):
    """Greedy algorithm for maximizing log-det diversity.
    
    Selects k items from [n] to maximize log det K[S],
    exploiting the submodularity of log-det for PSD K.
    
    The (1-1/e) approximation guarantee holds because log-det
    is monotone and submodular for PSD kernels with positive
    diagonal entries.
    
    Args:
        K: n×n PSD kernel matrix
        k: number of items to select
    
    Returns:
        selected: list of selected indices
        values: list of cumulative log-det values
    """
    n = K.shape[0]
    selected = []
    values = [0.0]  # W(∅) = log(1) = 0
    
    for _ in range(k):
        best_gain = -np.inf
        best_elem = None
        
        for e in range(n):
            if e in selected:
                continue
            new_set = tuple(sorted(selected + [e]))
            gain = log_det(K, new_set) - values[-1]
            if gain > best_gain:
                best_gain = gain
                best_elem = e
        
        if best_elem is not None:
            selected.append(best_elem)
            values.append(values[-1] + best_gain)
    
    return selected, values


def sensor_placement_demo():
    """Demonstrate sensor placement using log-det submodularity.
    
    Scenario: Place k sensors from n candidate locations to maximize
    the information gathered (modeled by log-det of the kernel).
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 1: SENSOR PLACEMENT")
    print("=" * 60)
    
    n = 8
    k = 4
    
    # Create a kernel based on spatial correlation
    # Locations on a line with exponential decay correlation
    locations = np.linspace(0, 1, n)
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = np.exp(-2 * abs(locations[i] - locations[j]))
    K += 0.01 * np.eye(n)
    
    print(f"\n  {n} candidate sensor locations on [0, 1]")
    print(f"  Selecting {k} sensors to maximize information (log-det)")
    
    selected, values = greedy_diverse_selection(K, k)
    
    print(f"\n  Greedy selection order: {selected}")
    print(f"  Selected positions: {[f'{locations[i]:.3f}' for i in selected]}")
    print(f"  Final log-det value: {values[-1]:.4f}")
    
    # Show diminishing returns
    print(f"\n  Marginal gains (diminishing returns):")
    for i in range(k):
        gain = values[i + 1] - values[i]
        print(f"    Step {i+1}: added sensor {selected[i]} "
              f"(pos={locations[selected[i]]:.3f}), gain = {gain:.4f}")
    
    # Compare with uniform spacing
    uniform = list(range(0, n, n // k))[:k]
    uniform_val = log_det(K, tuple(sorted(uniform)))
    print(f"\n  Uniform spacing baseline: {uniform}, value = {uniform_val:.4f}")
    print(f"  Greedy improvement: {((values[-1] - uniform_val) / abs(uniform_val)) * 100:.1f}%")


def feature_selection_demo():
    """Demonstrate feature selection with diminishing returns.
    
    Shows how submodularity of log-det governs the marginal value
    of adding features to a model.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: FEATURE SELECTION")
    print("=" * 60)
    
    n = 6
    np.random.seed(123)
    
    # Create feature correlation kernel
    # Features have block-correlated structure
    K = np.eye(n)
    # Add correlations within blocks
    for i in range(0, n, 2):
        if i + 1 < n:
            K[i, i + 1] = K[i + 1, i] = 0.8
    K += 0.1 * np.ones((n, n))  # small global correlation
    
    print(f"\n  {n} candidate features with block correlation structure")
    print(f"  Block pairs: (0,1), (2,3), (4,5) have correlation 0.8")
    
    # Show greedy selection prefers diverse features
    selected, values = greedy_diverse_selection(K, n)
    
    print(f"\n  Full greedy ordering: {selected}")
    print(f"\n  Step-by-step analysis:")
    for i in range(n):
        gain = values[i + 1] - values[i]
        current_set = selected[:i + 1]
        print(f"    Step {i+1}: select feature {selected[i]}, "
              f"marginal gain = {gain:.4f}, "
              f"current set = {current_set}")
    
    print(f"\n  Key observation: Greedy avoids selecting both features")
    print(f"  from the same correlated pair until all pairs are covered.")
    print(f"  This is the diminishing returns property in action.")


def diversity_sampling_demo():
    """Demonstrate diversity sampling via DPP kernel optimization."""
    print("\n" + "=" * 60)
    print("  APPLICATION 3: DIVERSITY SAMPLING")
    print("=" * 60)
    
    n = 6
    k = 3
    
    # Create quality-diversity kernel
    # K_ij = q_i * q_j * S_ij where q = quality, S = similarity
    np.random.seed(456)
    qualities = np.random.uniform(0.5, 2.0, n)
    
    # Similarity based on random features
    features = np.random.randn(n, 3)
    norms = np.linalg.norm(features, axis=1, keepdims=True)
    features_normalized = features / norms
    S = features_normalized @ features_normalized.T
    
    K = np.outer(qualities, qualities) * S
    K += 0.1 * np.eye(n)  # regularize
    
    print(f"\n  {n} items with quality scores: "
          f"{[f'{q:.2f}' for q in qualities]}")
    print(f"  Selecting {k} diverse, high-quality items")
    
    # Greedy selection
    selected, values = greedy_diverse_selection(K, k)
    
    print(f"\n  Greedy selection: {selected}")
    print(f"  Selected qualities: {[f'{qualities[i]:.2f}' for i in selected]}")
    print(f"  Log-det diversity: {values[-1]:.4f}")
    
    # Compare with top-k by quality
    top_k = np.argsort(-qualities)[:k].tolist()
    top_k_val = log_det(K, tuple(sorted(top_k)))
    
    print(f"\n  Top-{k} by quality: {sorted(top_k)}")
    print(f"  Top-{k} qualities: {[f'{qualities[i]:.2f}' for i in sorted(top_k)]}")
    print(f"  Top-{k} log-det: {top_k_val:.4f}")
    
    improvement = values[-1] - top_k_val
    print(f"\n  Diversity-aware improvement: {improvement:.4f}")
    print(f"  The greedy algorithm balances quality and diversity,")
    print(f"  exploiting the submodularity of log-det.")


def submodularity_verification_demo():
    """Comprehensive verification of submodularity for random PSD kernels."""
    print("\n" + "=" * 60)
    print("  APPLICATION 4: SUBMODULARITY VERIFICATION")
    print("=" * 60)
    
    for n in [3, 4, 5]:
        num_trials = 50
        num_violations = 0
        max_deficit = 0.0
        
        for trial in range(num_trials):
            K = random_psd_kernel(n, seed=trial * 100 + n)
            
            # Check all pairs
            for A_size in range(n + 1):
                for A in combinations(range(n), A_size):
                    for B_size in range(n + 1):
                        for B in combinations(range(n), B_size):
                            A_set, B_set = set(A), set(B)
                            inter = tuple(sorted(A_set & B_set))
                            union = tuple(sorted(A_set | B_set))
                            
                            lhs = log_det(K, A) + log_det(K, B)
                            rhs = log_det(K, inter) + log_det(K, union)
                            
                            if lhs < rhs - 1e-8:
                                num_violations += 1
                                max_deficit = max(max_deficit, rhs - lhs)
        
        status = "PASS" if num_violations == 0 else "FAIL"
        print(f"\n  n = {n}: {status} ({num_trials} kernels, "
              f"{num_violations} violations, max deficit = {max_deficit:.2e})")


if __name__ == '__main__':
    print("=" * 60)
    print("  APPLICATIONS OF SUBMODULAR TROPICAL WITNESSES")
    print("=" * 60)
    
    sensor_placement_demo()
    feature_selection_demo()
    diversity_sampling_demo()
    submodularity_verification_demo()
    
    print("\n" + "=" * 60)
    print("  ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Submodularity of Tropical Witnesses for DPP Kernels

This script generates random PSD kernels, computes tropical leaf witnesses
(approximated via log-det), and checks all submodularity inequalities.
It also searches for counterexamples to the valuated matroid exchange axiom.

Mathematical Context:
  For a PSD kernel K on ground set [n], the principal minor map
    det_K(A) = det K[A]
  is log-submodular (Hadamard-Fischer inequality):
    det K[A] * det K[B] >= det K[A ∩ B] * det K[A ∪ B]
  
  Equivalently, W(A) = log det K[A] is a submodular set function.
"""

import numpy as np
from itertools import combinations
import sys


def random_psd_kernel(n, rank=None, seed=None):
    """Generate a random n×n positive semidefinite kernel matrix.
    
    Args:
        n: Size of the ground set
        rank: Rank of the kernel (default: full rank)
        seed: Random seed for reproducibility
    
    Returns:
        K: n×n PSD matrix
    """
    if seed is not None:
        np.random.seed(seed)
    if rank is None:
        rank = n
    M = np.random.randn(rank, n)
    K = M.T @ M
    # Add small diagonal for strict positivity
    K += 0.01 * np.eye(n)
    return K


def principal_minor(K, subset):
    """Compute det K[S] for a subset S.
    
    Args:
        K: n×n matrix
        subset: tuple/list of indices
    
    Returns:
        Determinant of the principal submatrix K[S, S]
    """
    if len(subset) == 0:
        return 1.0
    idx = list(subset)
    return np.linalg.det(K[np.ix_(idx, idx)])


def all_subsets(n):
    """Generate all subsets of {0, 1, ..., n-1}."""
    for r in range(n + 1):
        for s in combinations(range(n), r):
            yield s


def check_submodularity(W, n, verbose=False):
    """Check if W: 2^[n] → ℝ is submodular.
    
    Tests: W(A) + W(B) >= W(A∩B) + W(A∪B) for all A, B ⊆ [n].
    
    Returns:
        (is_submodular, violations): bool and list of violations
    """
    subsets = list(all_subsets(n))
    violations = []
    
    for A in subsets:
        for B in subsets:
            A_set, B_set = set(A), set(B)
            AB_inter = tuple(sorted(A_set & B_set))
            AB_union = tuple(sorted(A_set | B_set))
            
            lhs = W[A] + W[B]
            rhs = W[AB_inter] + W[AB_union]
            
            if lhs < rhs - 1e-10:  # numerical tolerance
                violations.append({
                    'A': A, 'B': B,
                    'deficit': rhs - lhs,
                    'W_A': W[A], 'W_B': W[B],
                    'W_inter': W[AB_inter], 'W_union': W[AB_union]
                })
                if verbose:
                    print(f"  VIOLATION: A={A}, B={B}, deficit={rhs-lhs:.6e}")
    
    return len(violations) == 0, violations


def check_diminishing_returns(W, n, verbose=False):
    """Check diminishing marginal returns: for A ⊆ B, e ∉ B:
    W(B ∪ {e}) - W(B) ≤ W(A ∪ {e}) - W(A)
    """
    subsets = list(all_subsets(n))
    violations = []
    
    for A in subsets:
        for B in subsets:
            A_set, B_set = set(A), set(B)
            if not A_set.issubset(B_set):
                continue
            for e in range(n):
                if e in B_set:
                    continue
                Ae = tuple(sorted(A_set | {e}))
                Be = tuple(sorted(B_set | {e}))
                
                marginal_B = W[Be] - W[B]
                marginal_A = W[Ae] - W[A]
                
                if marginal_B > marginal_A + 1e-10:
                    violations.append({
                        'A': A, 'B': B, 'e': e,
                        'marginal_A': marginal_A,
                        'marginal_B': marginal_B
                    })
    
    return len(violations) == 0, violations


def check_valuated_exchange(W, n, verbose=False):
    """Check valuated exchange axiom on equal-cardinality layers:
    For A, B with |A|=|B| and a ∈ A\B, ∃ b ∈ B\A:
    W(A) + W(B) ≤ W((A\{a})∪{b}) + W((B\{b})∪{a})
    """
    subsets = list(all_subsets(n))
    violations = []
    
    for A in subsets:
        for B in subsets:
            if len(A) != len(B):
                continue
            A_set, B_set = set(A), set(B)
            A_minus_B = A_set - B_set
            B_minus_A = B_set - A_set
            
            for a in A_minus_B:
                found_exchange = False
                for b in B_minus_A:
                    new_A = tuple(sorted((A_set - {a}) | {b}))
                    new_B = tuple(sorted((B_set - {b}) | {a}))
                    
                    if W[A] + W[B] <= W[new_A] + W[new_B] + 1e-10:
                        found_exchange = True
                        break
                
                if not found_exchange and len(B_minus_A) > 0:
                    violations.append({
                        'A': A, 'B': B, 'a': a,
                        'W_A': W[A], 'W_B': W[B]
                    })
    
    return len(violations) == 0, violations


def run_experiment(n, num_trials=10, seed_base=42):
    """Run submodularity and exchange experiments for ground set size n."""
    print(f"\n{'='*60}")
    print(f"  GROUND SET SIZE n = {n}")
    print(f"{'='*60}")
    
    sub_pass = 0
    dr_pass = 0
    exchange_pass = 0
    
    for trial in range(num_trials):
        K = random_psd_kernel(n, seed=seed_base + trial)
        
        # Compute W(A) = log det K[A] for all subsets
        W = {}
        for S in all_subsets(n):
            det_val = principal_minor(K, S)
            W[S] = np.log(max(det_val, 1e-300))  # avoid log(0)
        
        # Check submodularity
        is_sub, violations = check_submodularity(W, n)
        if is_sub:
            sub_pass += 1
        else:
            print(f"  Trial {trial}: SUBMODULARITY VIOLATION ({len(violations)} pairs)")
            for v in violations[:3]:
                print(f"    A={v['A']}, B={v['B']}, deficit={v['deficit']:.2e}")
        
        # Check diminishing returns
        is_dr, dr_violations = check_diminishing_returns(W, n)
        if is_dr:
            dr_pass += 1
        
        # Check valuated exchange
        is_ex, ex_violations = check_valuated_exchange(W, n)
        if is_ex:
            exchange_pass += 1
        else:
            print(f"  Trial {trial}: EXCHANGE VIOLATION ({len(ex_violations)} cases)")
            for v in ex_violations[:3]:
                print(f"    A={v['A']}, B={v['B']}, a={v['a']}")
    
    print(f"\n  Results ({num_trials} trials):")
    print(f"    Submodularity:        {sub_pass}/{num_trials} passed")
    print(f"    Diminishing returns:  {dr_pass}/{num_trials} passed")
    print(f"    Valuated exchange:    {exchange_pass}/{num_trials} passed")
    
    return sub_pass, dr_pass, exchange_pass


def visualize_witness_by_layer(K, n):
    """Print witness values organized by subset cardinality."""
    print(f"\n  Witness values by cardinality layer (n={n}):")
    print(f"  {'Layer':>6} {'#Subsets':>8} {'Min W':>10} {'Max W':>10} {'Mean W':>10}")
    print(f"  {'-'*48}")
    
    for r in range(n + 1):
        vals = []
        for S in combinations(range(n), r):
            det_val = principal_minor(K, S)
            w = np.log(max(det_val, 1e-300))
            vals.append(w)
        
        vals = np.array(vals)
        print(f"  {r:>6} {len(vals):>8} {vals.min():>10.4f} {vals.max():>10.4f} {vals.mean():>10.4f}")


def main():
    print("=" * 60)
    print("  TROPICAL WITNESS SUBMODULARITY EXPERIMENTS")
    print("  Testing the Hadamard-Fischer inequality computationally")
    print("=" * 60)
    
    # Run experiments for n = 4, 5, 6
    results = {}
    for n in [4, 5, 6]:
        sub, dr, ex = run_experiment(n, num_trials=20, seed_base=42 + n * 100)
        results[n] = (sub, dr, ex)
    
    # Detailed visualization for n = 4
    print("\n" + "=" * 60)
    print("  DETAILED VISUALIZATION (n = 4)")
    print("=" * 60)
    
    K = random_psd_kernel(4, seed=42)
    print(f"\n  Kernel matrix K:")
    for i in range(4):
        print(f"    [{', '.join(f'{K[i,j]:7.4f}' for j in range(4))}]")
    
    visualize_witness_by_layer(K, 4)
    
    # Summary
    print("\n" + "=" * 60)
    print("  SUMMARY")
    print("=" * 60)
    all_passed = all(r[0] == 20 for r in results.values())
    print(f"\n  All submodularity tests passed: {all_passed}")
    
    all_exchange = all(r[2] == 20 for r in results.values())
    print(f"  All valuated exchange tests passed: {all_exchange}")
    
    if all_passed:
        print("\n  CONCLUSION: No counterexample found to Hadamard-Fischer inequality.")
        print("  The tropical witness W(A) = log det K[A] appears to be submodular")
        print("  for all tested PSD kernels.")
    
    if all_exchange:
        print("\n  CONJECTURE SUPPORTED: The valuated exchange axiom holds for all")
        print("  tested PSD kernels on equal-cardinality layers.")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Exchange Axiom Analysis for Log-Det

This script visualizes the failure of the valuated matroid exchange axiom
for the log-det function. This is a key scientific finding: while log-det
is submodular (Hadamard-Fischer), it does NOT satisfy the valuated exchange
axiom on equal-cardinality layers.

The visualization shows:
1. Exchange deficit heatmap on 2-element subsets
2. Comparison of submodularity vs exchange on different cardinality layers
3. The gap between submodularity and valuated matroid structure
"""

import numpy as np
from itertools import combinations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def principal_minor(K, subset):
    if len(subset) == 0:
        return 1.0
    idx = list(subset)
    return np.linalg.det(K[np.ix_(idx, idx)])


def all_subsets(n):
    result = []
    for r in range(n + 1):
        for S in combinations(range(n), r):
            result.append(S)
    return result


def compute_log_det(K, n):
    W = {}
    for S in all_subsets(n):
        det_val = principal_minor(K, S)
        W[S] = np.log(max(det_val, 1e-300))
    return W


def random_psd_kernel(n, seed=42):
    np.random.seed(seed)
    M = np.random.randn(n, n)
    K = M.T @ M + 0.01 * np.eye(n)
    return K


n = 5
K = random_psd_kernel(n, seed=42)
W = compute_log_det(K, n)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: Exchange analysis on 2-element subsets ---
ax1 = axes[0]
subsets_2 = list(combinations(range(n), 2))
m = len(subsets_2)

# For each pair of 2-element subsets, compute exchange deficit
exchange_matrix = np.zeros((m, m))
for i, A in enumerate(subsets_2):
    for j, B in enumerate(subsets_2):
        A_set, B_set = set(A), set(B)
        if A_set == B_set:
            exchange_matrix[i, j] = 0
            continue
        
        A_minus_B = A_set - B_set
        B_minus_A = B_set - A_set
        
        if not A_minus_B or not B_minus_A:
            exchange_matrix[i, j] = 0
            continue
        
        # Check if exchange axiom holds: for each a ∈ A\B, ∃ b ∈ B\A
        min_deficit = np.inf
        for a in A_minus_B:
            best_exchange = -np.inf
            for b in B_minus_A:
                new_A = tuple(sorted((A_set - {a}) | {b}))
                new_B = tuple(sorted((B_set - {b}) | {a}))
                exchange_val = W[new_A] + W[new_B] - W[A] - W[B]
                best_exchange = max(best_exchange, exchange_val)
            min_deficit = min(min_deficit, best_exchange)
        
        exchange_matrix[i, j] = min_deficit

labels = [f'{{{s[0]},{s[1]}}}' for s in subsets_2]
im1 = ax1.imshow(exchange_matrix, cmap='RdYlGn', aspect='auto')
ax1.set_xticks(range(m))
ax1.set_yticks(range(m))
ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
ax1.set_yticklabels(labels, fontsize=8)
ax1.set_title('Exchange Deficit (2-element sets)', fontsize=12, fontweight='bold')
plt.colorbar(im1, ax=ax1, label='Min exchange value')

# Mark violations (negative values)
for i in range(m):
    for j in range(m):
        if exchange_matrix[i, j] < -1e-10:
            ax1.plot(j, i, 'rx', markersize=6, markeredgewidth=1.5)

# --- Panel 2: Submodularity vs Exchange by layer ---
ax2 = axes[1]

results = {'layer': [], 'sub_slack_mean': [], 'sub_slack_min': [],
           'exchange_pass_rate': []}

for r in range(1, n):
    subsets_r = list(combinations(range(n), r))
    
    # Submodularity slack on this layer
    slacks = []
    for A in subsets_r:
        for B in subsets_r:
            A_set, B_set = set(A), set(B)
            inter = tuple(sorted(A_set & B_set))
            union = tuple(sorted(A_set | B_set))
            slack = (W[A] + W[B]) - (W[inter] + W[union])
            slacks.append(slack)
    
    # Exchange pass rate on this layer
    total_tests = 0
    passed_tests = 0
    for A in subsets_r:
        for B in subsets_r:
            A_set, B_set = set(A), set(B)
            A_minus_B = A_set - B_set
            B_minus_A = B_set - A_set
            if not A_minus_B or not B_minus_A:
                continue
            
            all_exchanges_ok = True
            for a in A_minus_B:
                found = False
                for b in B_minus_A:
                    new_A = tuple(sorted((A_set - {a}) | {b}))
                    new_B = tuple(sorted((B_set - {b}) | {a}))
                    if W[A] + W[B] <= W[new_A] + W[new_B] + 1e-10:
                        found = True
                        break
                if not found:
                    all_exchanges_ok = False
                    break
            
            total_tests += 1
            if all_exchanges_ok:
                passed_tests += 1
    
    results['layer'].append(r)
    results['sub_slack_mean'].append(np.mean(slacks))
    results['sub_slack_min'].append(np.min(slacks))
    results['exchange_pass_rate'].append(
        passed_tests / total_tests if total_tests > 0 else 1.0)

x = results['layer']
ax2_twin = ax2.twinx()

bars = ax2.bar(np.array(x) - 0.15, results['sub_slack_mean'], 
               width=0.3, color='steelblue', alpha=0.7, label='Mean sub. slack')
ax2.bar(np.array(x) + 0.15, [max(0, s) for s in results['sub_slack_min']], 
        width=0.3, color='lightblue', alpha=0.7, label='Min sub. slack')

line = ax2_twin.plot(x, [r * 100 for r in results['exchange_pass_rate']], 
                     'ro-', linewidth=2, markersize=8, label='Exchange pass %')

ax2.set_xlabel('Cardinality Layer r', fontsize=12)
ax2.set_ylabel('Submodularity Slack', fontsize=12, color='steelblue')
ax2_twin.set_ylabel('Exchange Pass Rate (%)', fontsize=12, color='red')
ax2.set_title('Submodularity vs Exchange by Layer', fontsize=12, fontweight='bold')
ax2.set_xticks(x)

# Combined legend
lines1, labels1 = ax2.get_legend_handles_labels()
lines2, labels2 = ax2_twin.get_legend_handles_labels()
ax2.legend(lines1 + lines2, labels1 + labels2, fontsize=9, loc='upper right')

# --- Panel 3: Scatter plot of all pair deficits ---
ax3 = axes[2]

sub_slacks_all = []
exchange_slacks_all = []
colors = []

for A in all_subsets(n):
    for B in all_subsets(n):
        if len(A) != len(B) or len(A) == 0 or len(A) == n:
            continue
        A_set, B_set = set(A), set(B)
        
        # Submodularity slack
        inter = tuple(sorted(A_set & B_set))
        union = tuple(sorted(A_set | B_set))
        sub_slack = (W[A] + W[B]) - (W[inter] + W[union])
        
        # Exchange slack (best exchange value for worst element)
        A_minus_B = A_set - B_set
        B_minus_A = B_set - A_set
        if not A_minus_B or not B_minus_A:
            continue
        
        min_exchange = np.inf
        for a in A_minus_B:
            best = -np.inf
            for b in B_minus_A:
                new_A = tuple(sorted((A_set - {a}) | {b}))
                new_B = tuple(sorted((B_set - {b}) | {a}))
                best = max(best, W[new_A] + W[new_B] - W[A] - W[B])
            min_exchange = min(min_exchange, best)
        
        sub_slacks_all.append(sub_slack)
        exchange_slacks_all.append(min_exchange)
        colors.append(len(A))

scatter = ax3.scatter(sub_slacks_all, exchange_slacks_all, 
                     c=colors, cmap='viridis', alpha=0.5, s=15, edgecolors='none')
ax3.axhline(y=0, color='red', linestyle='--', linewidth=1, alpha=0.7, label='Exchange boundary')
ax3.axvline(x=0, color='blue', linestyle='--', linewidth=1, alpha=0.7, label='Submodularity boundary')
ax3.set_xlabel('Submodularity Slack (≥0 for submodular)', fontsize=11)
ax3.set_ylabel('Exchange Slack (≥0 for exchange)', fontsize=11)
ax3.set_title('Submodularity vs Exchange\n(per pair)', fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
plt.colorbar(scatter, ax=ax3, label='Cardinality |A|=|B|')

plt.suptitle(f'Log-Det: Submodular but NOT a Valuated Matroid Weight (n={n})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_exchange.png', dpi=150, bbox_inches='tight')
print("Saved viz_exchange.png")


#!/usr/bin/env python3
"""
Visualization: Greedy Algorithm Performance with Submodular Log-Det

This script visualizes the greedy algorithm for maximizing log-det diversity,
showing how the diminishing returns property (equivalent to submodularity)
enables efficient optimization.

Shows:
1. Greedy vs optimal performance across different cardinality constraints
2. Marginal gain curves demonstrating diminishing returns
3. Kernel structure and selected subsets
"""

import numpy as np
from itertools import combinations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def principal_minor(K, subset):
    if len(subset) == 0:
        return 1.0
    idx = list(subset)
    return np.linalg.det(K[np.ix_(idx, idx)])


def log_det(K, subset):
    det_val = principal_minor(K, subset)
    return np.log(max(det_val, 1e-300))


def greedy_selection(K, k):
    n = K.shape[0]
    selected = []
    values = [0.0]
    marginals = []
    
    for step in range(k):
        best_gain = -np.inf
        best_elem = None
        
        for e in range(n):
            if e in selected:
                continue
            new_set = tuple(sorted(selected + [e]))
            gain = log_det(K, new_set) - values[-1]
            if gain > best_gain:
                best_gain = gain
                best_elem = e
        
        selected.append(best_elem)
        values.append(values[-1] + best_gain)
        marginals.append(best_gain)
    
    return selected, values, marginals


def optimal_value(K, k):
    n = K.shape[0]
    best = -np.inf
    best_set = None
    for S in combinations(range(n), k):
        val = log_det(K, S)
        if val > best:
            best = val
            best_set = S
    return best, best_set


n = 6
np.random.seed(42)
M = np.random.randn(n, n)
K = M.T @ M + 0.05 * np.eye(n)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: Greedy vs Optimal ---
ax1 = axes[0]
greedy_vals = []
optimal_vals = []
ks = list(range(1, n + 1))

full_selected, full_values, full_marginals = greedy_selection(K, n)

for k in ks:
    greedy_vals.append(full_values[k])
    opt_val, _ = optimal_value(K, k)
    optimal_vals.append(opt_val)

ax1.plot(ks, optimal_vals, 'b-o', linewidth=2, markersize=8, label='Optimal', zorder=3)
ax1.plot(ks, greedy_vals, 'r--s', linewidth=2, markersize=8, label='Greedy', zorder=3)
ax1.fill_between(ks, greedy_vals, optimal_vals, alpha=0.1, color='blue')

# Add (1-1/e) bound
one_minus_inv_e = 1 - 1/np.e
for k in ks:
    bound = one_minus_inv_e * optimal_vals[k-1]
    ax1.plot(k, bound, 'g^', markersize=6, alpha=0.7)

ax1.plot([], [], 'g^', markersize=6, label=f'(1-1/e)·OPT ≈ {one_minus_inv_e:.3f}·OPT')

ax1.set_xlabel('Cardinality k', fontsize=12)
ax1.set_ylabel('log det K[S]', fontsize=12)
ax1.set_title('Greedy vs Optimal', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_xticks(ks)
ax1.grid(alpha=0.3)

# Add ratio annotations
for k in ks:
    ratio = greedy_vals[k-1] / optimal_vals[k-1] if optimal_vals[k-1] > 0 else 1.0
    ax1.annotate(f'{ratio:.2f}', (k, greedy_vals[k-1]), 
                textcoords="offset points", xytext=(10, -10),
                fontsize=8, color='red')

# --- Panel 2: Marginal gains ---
ax2 = axes[1]
bar_colors = plt.cm.Reds(np.linspace(0.3, 0.9, n))
bars = ax2.bar(range(1, n + 1), full_marginals, color=bar_colors, 
               edgecolor='darkred', linewidth=0.5)

# Add element labels
for i, (bar, elem) in enumerate(zip(bars, full_selected)):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
             f'elem {elem}', ha='center', va='bottom', fontsize=9)

ax2.set_xlabel('Step', fontsize=12)
ax2.set_ylabel('Marginal Gain', fontsize=12)
ax2.set_title('Diminishing Marginal Returns', fontsize=13, fontweight='bold')
ax2.set_xticks(range(1, n + 1))
ax2.grid(alpha=0.3, axis='y')

# Verify diminishing returns
is_diminishing = all(full_marginals[i] >= full_marginals[i+1] - 1e-10 
                     for i in range(len(full_marginals)-1))
ax2.text(0.95, 0.95, 
         f'Diminishing: {"✓" if is_diminishing else "✗"}',
         transform=ax2.transAxes, ha='right', va='top',
         fontsize=11, fontweight='bold',
         color='green' if is_diminishing else 'red',
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

# --- Panel 3: Kernel heatmap with greedy selection order ---
ax3 = axes[2]

# Reorder by greedy selection
order = full_selected
K_reordered = K[np.ix_(order, order)]

im3 = ax3.imshow(K_reordered, cmap='coolwarm', aspect='auto')
ax3.set_xticks(range(n))
ax3.set_yticks(range(n))
ax3.set_xticklabels([f'{order[i]}' for i in range(n)])
ax3.set_yticklabels([f'{order[i]}' for i in range(n)])
ax3.set_title('Kernel (greedy order)', fontsize=13, fontweight='bold')
plt.colorbar(im3, ax=ax3)

# Highlight diagonal
for i in range(n):
    ax3.add_patch(plt.Rectangle((i-0.5, i-0.5), 1, 1, 
                                fill=False, edgecolor='gold', linewidth=2))

# Add selection step annotations
for i in range(n):
    ax3.text(i, -0.7, f'step {i+1}', ha='center', fontsize=8, color='navy')

plt.suptitle(f'Greedy Optimization of Submodular Log-Det (n={n})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_greedy.png', dpi=150, bbox_inches='tight')
print("Saved viz_greedy.png")


#!/usr/bin/env python3
"""
Visualization: Submodularity of Log-Det for PSD Kernels

This script visualizes the submodularity structure of the log-det function
for positive semidefinite matrices. It shows:
1. A heatmap of log-det values across all subsets organized by cardinality
2. Diminishing marginal returns curves for different base sets
3. The submodularity deficit (how much slack the inequality has)

The visualization demonstrates that det K is log-submodular for PSD K
(the Hadamard-Fischer inequality), which is the algebraic engine behind
DPP negative dependence and tropical witness submodularity.
"""

import numpy as np
from itertools import combinations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def principal_minor(K, subset):
    if len(subset) == 0:
        return 1.0
    idx = list(subset)
    return np.linalg.det(K[np.ix_(idx, idx)])


def all_subsets(n):
    result = []
    for r in range(n + 1):
        for S in combinations(range(n), r):
            result.append(S)
    return result


def compute_log_det(K, n):
    W = {}
    for S in all_subsets(n):
        det_val = principal_minor(K, S)
        W[S] = np.log(max(det_val, 1e-300))
    return W


def random_psd_kernel(n, seed=42):
    np.random.seed(seed)
    M = np.random.randn(n, n)
    K = M.T @ M + 0.01 * np.eye(n)
    return K


# Setup
n = 5
K = random_psd_kernel(n, seed=42)
W = compute_log_det(K, n)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: Log-det values by cardinality layer ---
ax1 = axes[0]
for r in range(n + 1):
    subsets_r = [S for S in all_subsets(n) if len(S) == r]
    values = [W[S] for S in subsets_r]
    jitter = np.random.uniform(-0.15, 0.15, len(values))
    ax1.scatter(r + jitter, values, alpha=0.7, s=40, c='steelblue', edgecolors='navy', linewidths=0.5)
    ax1.plot([r - 0.25, r + 0.25], [np.mean(values)] * 2, 'r-', linewidth=2)

ax1.set_xlabel('Subset Cardinality |S|', fontsize=12)
ax1.set_ylabel('W(S) = log det K[S]', fontsize=12)
ax1.set_title('Log-Det Values by Layer', fontsize=13, fontweight='bold')
ax1.set_xticks(range(n + 1))
ax1.grid(alpha=0.3)

# --- Panel 2: Diminishing marginal returns ---
ax2 = axes[1]
colors = plt.cm.viridis(np.linspace(0, 0.8, n))

for base_size in range(n):
    # For each base set size, compute average marginal gain
    subsets_base = [S for S in all_subsets(n) if len(S) == base_size]
    avg_gains = []
    
    for base in subsets_base:
        base_set = set(base)
        for e in range(n):
            if e not in base_set:
                new = tuple(sorted(base_set | {e}))
                gain = W[new] - W[base]
                avg_gains.append(gain)
    
    if avg_gains:
        ax2.scatter([base_size] * len(avg_gains), avg_gains, 
                   alpha=0.3, s=20, c=[colors[base_size]])
        ax2.plot(base_size, np.mean(avg_gains), 'o', color=colors[base_size],
                markersize=10, markeredgecolor='black', markeredgewidth=1)

ax2.set_xlabel('Base Set Size |A|', fontsize=12)
ax2.set_ylabel('Marginal Gain W(A∪{e}) - W(A)', fontsize=12)
ax2.set_title('Diminishing Marginal Returns', fontsize=13, fontweight='bold')
ax2.set_xticks(range(n))
ax2.grid(alpha=0.3)

# Add trend line through means
means_x, means_y = [], []
for base_size in range(n):
    subsets_base = [S for S in all_subsets(n) if len(S) == base_size]
    gains = []
    for base in subsets_base:
        base_set = set(base)
        for e in range(n):
            if e not in base_set:
                new = tuple(sorted(base_set | {e}))
                gains.append(W[new] - W[base])
    if gains:
        means_x.append(base_size)
        means_y.append(np.mean(gains))

ax2.plot(means_x, means_y, 'k--', linewidth=2, alpha=0.5, label='Mean trend')
ax2.legend(fontsize=10)

# --- Panel 3: Submodularity slack histogram ---
ax3 = axes[2]
slacks = []
subsets = all_subsets(n)
for A in subsets:
    for B in subsets:
        A_set, B_set = set(A), set(B)
        inter = tuple(sorted(A_set & B_set))
        union = tuple(sorted(A_set | B_set))
        slack = (W[A] + W[B]) - (W[inter] + W[union])
        slacks.append(slack)

slacks = np.array(slacks)
# Remove near-zero slacks (when A ⊆ B or B ⊆ A)
nonzero_slacks = slacks[np.abs(slacks) > 1e-10]

ax3.hist(nonzero_slacks, bins=50, color='forestgreen', alpha=0.7, 
         edgecolor='darkgreen', linewidth=0.5)
ax3.axvline(x=0, color='red', linestyle='--', linewidth=2, label='Submodularity boundary')
ax3.set_xlabel('Slack: W(A)+W(B) - W(A∩B) - W(A∪B)', fontsize=12)
ax3.set_ylabel('Count', fontsize=12)
ax3.set_title('Submodularity Slack Distribution', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(alpha=0.3)

min_slack = slacks.min()
ax3.annotate(f'Min slack: {min_slack:.2e}', xy=(min_slack, 0),
            xytext=(min_slack + 0.5, ax3.get_ylim()[1] * 0.3),
            arrowprops=dict(arrowstyle='->', color='red'),
            fontsize=10, color='red')

plt.suptitle(f'Submodularity of Log-Det for {n}×{n} PSD Kernel\n'
             f'(Hadamard–Fischer Inequality Verification)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_submodularity.png', dpi=150, bbox_inches='tight')
print("Saved viz_submodularity.png")
