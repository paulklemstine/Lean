#!/usr/bin/env python3
"""
Applications of Tagged-Card TASEP Theory

Demonstrates real-world applications and connections of the tagged-card
dynamics framework:

1. Card shuffling efficiency estimation
2. Traffic flow modeling via exclusion processes
3. Sorting network analysis
4. Communication network packet routing
"""
import numpy as np
from typing import List, Tuple, Dict


# ============================================================
# Application 1: Shuffle Quality Assessment
# ============================================================

def shuffle_quality_by_tagged_card(n: int, num_shuffles: int, 
                                    num_trials: int = 5000) -> Dict:
    """
    Assess shuffle quality by tracking tagged card displacement.
    
    A good shuffle should move each card to a position approximately
    uniformly distributed. The variance of the tagged card position
    serves as a proxy for mixing quality.
    
    For a perfectly mixed deck: Var(pos_j) = (n²-1)/12 ≈ n²/12.
    
    Args:
        n: Deck size
        num_shuffles: Number of adjacent-swap shuffles
        num_trials: Number of independent trials
    
    Returns:
        Dict with shuffle quality metrics
    """
    j = n // 2  # Track middle card
    positions = []
    
    for _ in range(num_trials):
        perm = list(range(n))
        for _ in range(num_shuffles):
            i = np.random.randint(0, n - 1)
            perm[i], perm[i+1] = perm[i+1], perm[i]
        positions.append(perm.index(j))
    
    positions = np.array(positions, dtype=float)
    empirical_var = np.var(positions)
    uniform_var = (n**2 - 1) / 12.0
    
    # Quality metric: ratio of empirical to uniform variance
    quality = empirical_var / uniform_var if uniform_var > 0 else 0
    
    return {
        'n': n,
        'num_shuffles': num_shuffles,
        'empirical_variance': empirical_var,
        'uniform_variance': uniform_var,
        'quality_ratio': quality,
        'is_well_mixed': quality > 0.9,
    }


# ============================================================
# Application 2: Sorting Network Complexity
# ============================================================

def sorting_progress_by_inversions(n: int, num_steps: int,
                                    num_trials: int = 2000) -> List[float]:
    """
    Track sorting progress via total inversion count.
    
    Starting from a random permutation, adjacent swaps that reduce
    inversions sort the deck. The inversion count trajectory reveals
    the "distance to sorted" under the random walk.
    
    Connection to TASEP: inversions in a random permutation correspond
    to particles in an exclusion process. The rate of inversion reduction
    connects to current in TASEP.
    
    Args:
        n: Array size
        num_steps: Number of random adjacent swap steps
        num_trials: Number of trials to average
    
    Returns:
        Average inversion count at each time step
    """
    avg_inversions = np.zeros(num_steps + 1)
    
    for _ in range(num_trials):
        perm = list(np.random.permutation(n))
        
        # Count initial inversions
        inv_count = sum(1 for a in range(n) for b in range(a+1, n) 
                       if perm[a] > perm[b])
        avg_inversions[0] += inv_count
        
        for t in range(num_steps):
            i = np.random.randint(0, n - 1)
            if perm[i] > perm[i+1]:
                inv_count -= 1
            elif perm[i] < perm[i+1]:
                inv_count += 1
            perm[i], perm[i+1] = perm[i+1], perm[i]
            avg_inversions[t + 1] += inv_count
    
    return (avg_inversions / num_trials).tolist()


# ============================================================
# Application 3: Traffic Flow Model
# ============================================================

def traffic_flow_simulation(
    num_lanes: int,
    road_length: int,
    num_steps: int,
    density: float = 0.5,
) -> Dict:
    """
    Simplified traffic flow model based on TASEP-like dynamics.
    
    Models a single-lane road with vehicles that can only overtake
    their immediate neighbor (adjacent swap). This is exactly the
    exclusion process analog of our tagged-card walk.
    
    A "tagged vehicle" is tracked, and its current (throughput)
    is measured — this corresponds to the tagged-card current J_j(t).
    
    Args:
        num_lanes: Number of independent lanes (for averaging)
        road_length: Number of positions on the road
        num_steps: Simulation duration
        density: Vehicle density (0 to 1)
    
    Returns:
        Dict with traffic flow statistics
    """
    n = road_length
    num_vehicles = int(density * n)
    
    tagged_positions = []
    throughputs = []
    
    for lane in range(num_lanes):
        # Place vehicles at random positions
        vehicle_positions = sorted(np.random.choice(n, num_vehicles, replace=False))
        road = [0] * n
        for pos in vehicle_positions:
            road[pos] = 1
        
        # Tag the first vehicle
        tagged_pos = vehicle_positions[0] if vehicle_positions else 0
        initial_tagged = tagged_pos
        
        for t in range(num_steps):
            # Each vehicle attempts to move forward if space available
            # This is equivalent to random adjacent swaps of (0,1) pairs
            for pos in range(n - 1):
                if road[pos] == 1 and road[pos + 1] == 0 and np.random.random() < 0.5:
                    road[pos], road[pos + 1] = 0, 1
                    if pos == tagged_pos:
                        tagged_pos = pos + 1
        
        displacement = tagged_pos - initial_tagged
        tagged_positions.append(tagged_pos)
        throughputs.append(displacement / num_steps if num_steps > 0 else 0)
    
    return {
        'road_length': n,
        'density': density,
        'num_steps': num_steps,
        'mean_throughput': np.mean(throughputs),
        'var_throughput': np.var(throughputs),
        'mean_tagged_displacement': np.mean([p - int(density * n) for p in tagged_positions]),
    }


# ============================================================
# Application 4: Packet Routing Analysis
# ============================================================

def packet_routing_analysis(
    buffer_size: int,
    num_steps: int,
    num_trials: int = 1000,
) -> Dict:
    """
    Model packet reordering in a network buffer.
    
    Packets arrive in order but can be swapped with adjacent packets
    due to processing delays. The displacement of a tagged packet
    measures reordering severity.
    
    This is directly the tagged-card walk: each packet is a "card"
    and buffer operations are adjacent swaps.
    
    Connection to theorems:
    - Theorem 1 (drift decomposition): predicts per-step displacement
    - Theorem 2 (|Δ| ≤ 1): guarantees bounded per-step reordering
    - Theorem 3 (|ΔI| ≤ 1): bounds out-of-order metric change
    
    Args:
        buffer_size: Number of packets in buffer
        num_steps: Number of processing steps
        num_trials: Number of simulations
    
    Returns:
        Dict with reordering statistics
    """
    n = buffer_size
    tagged_packet = 0  # Track first packet
    
    max_displacements = []
    final_inversions = []
    
    for _ in range(num_trials):
        perm = list(range(n))  # Initial order
        max_disp = 0
        
        for _ in range(num_steps):
            i = np.random.randint(0, n - 1)
            perm[i], perm[i+1] = perm[i+1], perm[i]
            disp = abs(perm.index(tagged_packet) - tagged_packet)
            max_disp = max(max_disp, disp)
        
        max_displacements.append(max_disp)
        
        # Count inversions for tagged packet
        pos_0 = perm.index(tagged_packet)
        inv_count = sum(1 for k in range(tagged_packet + 1, n) 
                       if perm.index(k) < pos_0)
        final_inversions.append(inv_count)
    
    return {
        'buffer_size': n,
        'num_steps': num_steps,
        'mean_max_displacement': np.mean(max_displacements),
        'mean_final_inversions': np.mean(final_inversions),
        'prob_significant_reorder': np.mean([d > n//4 for d in max_displacements]),
    }


# ============================================================
# Main: Run all applications
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)
    
    print("=" * 60)
    print("  Applications of Tagged-Card TASEP Theory")
    print("=" * 60)
    
    # Application 1: Shuffle quality
    print("\n--- Application 1: Card Shuffle Quality ---")
    for num_shuffles in [10, 50, 100, 500, 1000]:
        result = shuffle_quality_by_tagged_card(52, num_shuffles, num_trials=2000)
        quality = result['quality_ratio']
        status = "MIXED" if result['is_well_mixed'] else "not mixed"
        print(f"  {num_shuffles:4d} shuffles: quality={quality:.3f} [{status}]")
    
    # Application 2: Sorting progress
    print("\n--- Application 2: Sorting Progress (n=10) ---")
    inversions = sorting_progress_by_inversions(10, 200, num_trials=1000)
    for t in [0, 10, 50, 100, 200]:
        print(f"  t={t:4d}: avg inversions = {inversions[t]:.1f}")
    
    # Application 3: Traffic flow
    print("\n--- Application 3: Traffic Flow Model ---")
    for density in [0.2, 0.5, 0.8]:
        result = traffic_flow_simulation(50, 20, 100, density)
        print(f"  density={density:.1f}: throughput={result['mean_throughput']:.4f}")
    
    # Application 4: Packet routing
    print("\n--- Application 4: Packet Reordering ---")
    for steps in [10, 50, 100, 500]:
        result = packet_routing_analysis(20, steps, num_trials=500)
        print(f"  {steps:4d} steps: max_disp={result['mean_max_displacement']:.1f}, "
              f"inversions={result['mean_final_inversions']:.1f}")


#!/usr/bin/env python3
"""
Demo: Tagged-Card TASEP Signatures in Permutation Random Walks

This script demonstrates the key observables and theorems connecting
the adjacent-transposition-plus-cycle walk on S_n to driven diffusive
systems (TASEP/KPZ universality).

Observables tracked:
- Tagged card position and displacement
- Drift-corrected (compensated) current
- Inversion count relative to a tagged card
- Empirical drift vs. predicted drift
- Variance scaling in t and n
- Skewness/kurtosis deviation from Gaussianity

Run: python demo.py
"""
import numpy as np
from collections import defaultdict
import itertools

# ============================================================
# Core: Permutation walk simulation
# ============================================================

def identity_perm(n):
    """Identity permutation on {0, ..., n-1}."""
    return list(range(n))

def apply_adjacent_swap(perm, i):
    """Swap positions i and i+1 in perm (in-place copy)."""
    p = perm[:]
    p[i], p[i+1] = p[i+1], p[i]
    return p

def apply_long_cycle(perm):
    """Apply the long cycle (0 1 2 ... n-1): position i gets card from position i-1 mod n."""
    n = len(perm)
    return [perm[(i - 1) % n] for i in range(n)]

def tagged_card_pos(perm, j):
    """Position of card j in perm (i.e., perm^{-1}(j))."""
    return perm.index(j)

def tagged_inversion_count(perm, j):
    """Number of cards k > j sitting to the left of card j."""
    pos_j = perm.index(j)
    count = 0
    for k in range(j + 1, len(perm)):
        if perm.index(k) < pos_j:
            count += 1
    return count

def signed_increment(perm_before, perm_after, j):
    """Signed displacement of card j in one step."""
    return tagged_card_pos(perm_after, j) - tagged_card_pos(perm_before, j)

def hybrid_step(perm, swap_prob=0.5):
    """One step of the hybrid walk: with prob swap_prob, do a random adjacent swap;
    otherwise apply the long cycle."""
    n = len(perm)
    if np.random.random() < swap_prob:
        i = np.random.randint(0, n - 1)  # swap positions i and i+1
        return apply_adjacent_swap(perm, i)
    else:
        return apply_long_cycle(perm)

def swap_only_step(perm):
    """One step: uniformly random adjacent swap (no cycle)."""
    n = len(perm)
    i = np.random.randint(0, n - 1)
    return apply_adjacent_swap(perm, i)

# ============================================================
# Theorem verification
# ============================================================

def verify_drift_decomposition(n=6, num_trials=50000):
    """
    Theorem 1 verification: drift decomposition.
    For each swap of (i, i+1), the increment of tagged card j is:
      +1 if card j is at position i
      -1 if card j is at position i+1
       0 otherwise
    """
    print("=" * 60)
    print(f"THEOREM 1: Drift decomposition (n={n})")
    print("=" * 60)
    
    j = n // 2  # tag card j = n/2
    violations = 0
    
    for _ in range(num_trials):
        perm = list(np.random.permutation(n))
        i = np.random.randint(0, n - 1)
        new_perm = apply_adjacent_swap(perm, i)
        delta = signed_increment(perm, new_perm, j)
        pos_j = tagged_card_pos(perm, j)
        
        if pos_j == i:
            expected = 1
        elif pos_j == i + 1:
            expected = -1
        else:
            expected = 0
        
        if delta != expected:
            violations += 1
    
    print(f"  Tested {num_trials} random (perm, swap) pairs")
    print(f"  Violations of drift decomposition: {violations}")
    print(f"  ✓ Theorem verified" if violations == 0 else "  ✗ VIOLATION FOUND")
    print()
    return violations == 0

def verify_increment_bound(n=6, num_trials=50000):
    """
    Theorem 2 verification: |Δ_j| ≤ 1 for adjacent swaps.
    """
    print("=" * 60)
    print(f"THEOREM 2: Per-step increment bound |Δ_j| ≤ 1 (n={n})")
    print("=" * 60)
    
    j = n // 2
    max_abs_delta = 0
    violations = 0
    
    for _ in range(num_trials):
        perm = list(np.random.permutation(n))
        i = np.random.randint(0, n - 1)
        new_perm = apply_adjacent_swap(perm, i)
        delta = signed_increment(perm, new_perm, j)
        
        max_abs_delta = max(max_abs_delta, abs(delta))
        if delta**2 > 1:
            violations += 1
    
    print(f"  Tested {num_trials} random (perm, swap) pairs")
    print(f"  Max |Δ_j| observed: {max_abs_delta}")
    print(f"  Violations of Δ_j² ≤ 1: {violations}")
    print(f"  ✓ Theorem verified" if violations == 0 else "  ✗ VIOLATION FOUND")
    print()
    return violations == 0

def verify_inversion_bound(n=6, num_trials=50000):
    """
    Theorem 3 verification: |I_j(τ) - I_j(σ)| ≤ 1 for adjacent swaps.
    """
    print("=" * 60)
    print(f"THEOREM 3: Inversion count change ≤ 1 (n={n})")
    print("=" * 60)
    
    j = n // 2
    max_change = 0
    violations = 0
    
    for _ in range(num_trials):
        perm = list(np.random.permutation(n))
        i = np.random.randint(0, n - 1)
        new_perm = apply_adjacent_swap(perm, i)
        
        inv_before = tagged_inversion_count(perm, j)
        inv_after = tagged_inversion_count(new_perm, j)
        change = abs(inv_after - inv_before)
        
        max_change = max(max_change, change)
        if change > 1:
            violations += 1
    
    print(f"  Tested {num_trials} random (perm, swap) pairs")
    print(f"  Max |ΔI_j| observed: {max_change}")
    print(f"  Violations of |ΔI_j| ≤ 1: {violations}")
    print(f"  ✓ Theorem verified" if violations == 0 else "  ✗ VIOLATION FOUND")
    print()
    return violations == 0

def verify_zero_increment_preserves_inversions(n=6, num_trials=50000):
    """
    Theorem 4 verification: Δ_j = 0 implies ΔI_j = 0.
    """
    print("=" * 60)
    print(f"THEOREM 4: Zero increment ⟹ zero inversion change (n={n})")
    print("=" * 60)
    
    j = n // 2
    zero_increment_count = 0
    violations = 0
    
    for _ in range(num_trials):
        perm = list(np.random.permutation(n))
        i = np.random.randint(0, n - 1)
        new_perm = apply_adjacent_swap(perm, i)
        
        delta = signed_increment(perm, new_perm, j)
        if delta == 0:
            zero_increment_count += 1
            inv_before = tagged_inversion_count(perm, j)
            inv_after = tagged_inversion_count(new_perm, j)
            if inv_after != inv_before:
                violations += 1
    
    print(f"  Tested {num_trials} pairs, {zero_increment_count} had Δ_j = 0")
    print(f"  Violations (Δ_j=0 but ΔI_j≠0): {violations}")
    print(f"  ✓ Theorem verified" if violations == 0 else "  ✗ VIOLATION FOUND")
    print()
    return violations == 0

# ============================================================
# Scaling analysis
# ============================================================

def empirical_drift_and_variance(n, j, num_steps, num_trials, swap_prob=0.5):
    """Compute empirical drift and variance of tagged card position."""
    positions = []
    for _ in range(num_trials):
        perm = identity_perm(n)
        for _ in range(num_steps):
            perm = hybrid_step(perm, swap_prob=swap_prob)
        positions.append(tagged_card_pos(perm, j))
    
    positions = np.array(positions, dtype=float)
    return np.mean(positions), np.var(positions)

def drift_analysis():
    """Compare empirical vs predicted drift for various n."""
    print("=" * 60)
    print("DRIFT ANALYSIS: Empirical vs. predicted")
    print("=" * 60)
    
    for n in [5, 6, 7, 8]:
        j = n // 2
        # For swap-only walk, expected drift per step = 0 (symmetric)
        # For hybrid walk with long cycle, there is a net drift of ~1/n per cycle step
        
        # Measure empirical per-step drift (swap-only)
        total_drift = 0
        num_trials = 20000
        for _ in range(num_trials):
            perm = list(np.random.permutation(n))
            new_perm = swap_only_step(perm)
            total_drift += signed_increment(perm, new_perm, j)
        
        emp_drift = total_drift / num_trials
        # Predicted: 0 (symmetric random walk)
        print(f"  n={n}, j={j}: empirical per-step drift (swap-only) = {emp_drift:.4f} (predicted: 0)")
    
    print()

def variance_scaling_analysis():
    """Analyze variance scaling in t and n."""
    print("=" * 60)
    print("VARIANCE SCALING: Var(pos_j) vs t for various n")
    print("=" * 60)
    
    num_trials = 3000
    for n in [5, 6, 7, 8]:
        j = n // 2
        print(f"\n  n={n}, j={j}:")
        for t in [10, 50, 100, 200]:
            displacements = []
            for _ in range(num_trials):
                perm = identity_perm(n)
                for _ in range(t):
                    perm = swap_only_step(perm)
                displacements.append(tagged_card_pos(perm, j) - j)
            
            displacements = np.array(displacements, dtype=float)
            var = np.var(displacements)
            print(f"    t={t:4d}: Var = {var:.3f}, Var/t = {var/t:.4f}")
    
    print()

def gaussianity_test():
    """Test deviation from Gaussian: skewness and kurtosis."""
    print("=" * 60)
    print("GAUSSIANITY TEST: Skewness and excess kurtosis")
    print("=" * 60)
    print("  (Gaussian: skewness=0, excess kurtosis=0)")
    print("  (Tracy-Widom: skewness≈0.29, excess kurtosis≈0.17)")
    print()
    
    num_trials = 10000
    for n in [6, 8, 10, 15]:
        j = n // 2
        t = n * n  # scaling regime
        displacements = []
        for _ in range(num_trials):
            perm = identity_perm(n)
            for _ in range(t):
                perm = swap_only_step(perm)
            displacements.append(tagged_card_pos(perm, j))
        
        displacements = np.array(displacements, dtype=float)
        mean = np.mean(displacements)
        std = np.std(displacements)
        if std > 0:
            skewness = np.mean(((displacements - mean) / std) ** 3)
            kurtosis = np.mean(((displacements - mean) / std) ** 4) - 3
        else:
            skewness = 0
            kurtosis = 0
        
        print(f"  n={n:2d}, t={t:4d}: skewness={skewness:+.3f}, excess_kurtosis={kurtosis:+.3f}")
    
    print()

def tagged_current_trajectories(n=8, j=4, num_steps=200, num_trajectories=5):
    """Show tagged card displacement trajectories."""
    print("=" * 60)
    print(f"TAGGED CARD TRAJECTORIES: n={n}, j={j}")
    print("=" * 60)
    
    for traj in range(num_trajectories):
        perm = identity_perm(n)
        positions = [tagged_card_pos(perm, j)]
        for _ in range(num_steps):
            perm = swap_only_step(perm)
            positions.append(tagged_card_pos(perm, j))
        
        # Show first 20 positions
        print(f"  Trajectory {traj+1}: {positions[:21]}...")
    
    print()

# ============================================================
# Conjecture falsifiability test
# ============================================================

def conjecture_falsifiability_test():
    """
    KPZ/TASEP Conjecture falsifiability:
    Test whether variance scaling is incompatible with KPZ/TASEP regime.
    
    For TASEP on a ring of size n, the current variance scales as t^{2/3}
    in the KPZ regime. For a simple random walk, it scales as t.
    
    We test: does Var(J_j(t)) / t converge to a constant (diffusive)
    or does it decay (subdiffusive = possible KPZ signature)?
    """
    print("=" * 60)
    print("CONJECTURE FALSIFIABILITY: Variance scaling regime")
    print("=" * 60)
    print("  Testing Var(pos_j(t)) / t for large t")
    print("  Diffusive: Var/t → const > 0")
    print("  Subdiffusive (KPZ-type): Var/t → 0 as t → ∞")
    print()
    
    num_trials = 5000
    for n in [6, 8, 10]:
        j = n // 2
        print(f"  n={n}, j={j}:")
        ratios = []
        for t in [50, 100, 200, 400, 800]:
            displacements = []
            for _ in range(num_trials):
                perm = identity_perm(n)
                for _ in range(t):
                    perm = swap_only_step(perm)
                displacements.append(tagged_card_pos(perm, j) - j)
            
            var = np.var(displacements)
            ratio = var / t
            ratios.append(ratio)
            print(f"    t={t:4d}: Var={var:.3f}, Var/t={ratio:.5f}")
        
        # Check if ratio is decreasing (subdiffusive signal)
        if all(ratios[i] >= ratios[i+1] for i in range(len(ratios)-1)):
            print(f"    → Var/t DECREASING: possible subdiffusive regime ✓")
        else:
            print(f"    → Var/t non-monotone: finite-size effects or diffusive")
        print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)
    
    print("\n" + "=" * 60)
    print("  TAGGED-CARD TASEP: Computational Demonstration")
    print("  Permutation Random Walks & Driven Diffusive Systems")
    print("=" * 60 + "\n")
    
    # Verify all four theorems
    all_pass = True
    all_pass &= verify_drift_decomposition()
    all_pass &= verify_increment_bound()
    all_pass &= verify_inversion_bound()
    all_pass &= verify_zero_increment_preserves_inversions()
    
    print(f"\n{'='*60}")
    print(f"ALL THEOREMS {'VERIFIED ✓' if all_pass else 'FAILED ✗'}")
    print(f"{'='*60}\n")
    
    # Scaling analysis
    drift_analysis()
    variance_scaling_analysis()
    
    # Trajectories
    tagged_current_trajectories()
    
    # Gaussianity
    gaussianity_test()
    
    # Conjecture test
    conjecture_falsifiability_test()
    
    print("Demo complete.")


#!/usr/bin/env python3
"""
Visualization 3: Position Heatmap and Inversion Current

Shows the evolution of tagged card position distribution over time as a
heatmap, revealing the transition from concentrated to spread-out distribution.
Also shows the inversion-current bridge (Theorem 4).
"""
import numpy as np
import matplotlib.pyplot as plt

def identity_perm(n):
    return list(range(n))

def swap_step(perm):
    n = len(perm)
    i = np.random.randint(0, n - 1)
    p = perm[:]
    p[i], p[i+1] = p[i+1], p[i]
    return p

def tagged_inversion_count(perm, j):
    pos_j = perm.index(j)
    return sum(1 for k in range(j + 1, len(perm)) if perm.index(k) < pos_j)

np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Position distribution heatmap
ax = axes[0, 0]
n = 10
j = 5
max_time = 200
num_trials = 5000
time_bins = list(range(0, max_time + 1, 5))
heatmap = np.zeros((n, len(time_bins)))

for trial in range(num_trials):
    perm = identity_perm(n)
    t_idx = 0
    for t in range(max_time + 1):
        if t_idx < len(time_bins) and t == time_bins[t_idx]:
            pos = perm.index(j)
            heatmap[pos, t_idx] += 1
            t_idx += 1
        if t < max_time:
            perm = swap_step(perm)

heatmap /= num_trials
im = ax.imshow(heatmap, aspect='auto', origin='lower', cmap='hot',
               extent=[0, max_time, -0.5, n - 0.5])
ax.set_xlabel('Time t', fontsize=11)
ax.set_ylabel('Position', fontsize=11)
ax.set_title(f'Position Distribution Heatmap (n={n}, j={j})', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax, label='Probability')

# Panel 2: Increment vs inversion change correlation
ax = axes[0, 1]
increments = []
inv_changes = []
for _ in range(30000):
    perm = list(np.random.permutation(n))
    i = np.random.randint(0, n - 1)
    
    old_pos = perm.index(j)
    old_inv = tagged_inversion_count(perm, j)
    
    perm[i], perm[i+1] = perm[i+1], perm[i]
    
    new_pos = perm.index(j)
    new_inv = tagged_inversion_count(perm, j)
    
    increments.append(new_pos - old_pos)
    inv_changes.append(new_inv - old_inv)

# Create scatter with jitter for visibility
inc_arr = np.array(increments)
inv_arr = np.array(inv_changes)
jitter_x = np.random.normal(0, 0.05, len(inc_arr))
jitter_y = np.random.normal(0, 0.05, len(inv_arr))
ax.scatter(inc_arr + jitter_x, inv_arr + jitter_y, alpha=0.01, s=1, c='blue')

# Count matrix
for dx in [-1, 0, 1]:
    for di in [-2, -1, 0, 1, 2]:
        mask = (inc_arr == dx) & (inv_arr == di)
        count = np.sum(mask)
        if count > 0:
            ax.annotate(f'{count}', (dx, di), ha='center', va='center',
                       fontsize=8, fontweight='bold',
                       bbox=dict(boxstyle='round,pad=0.2', facecolor='yellow', alpha=0.8))

ax.set_xlabel('Position increment Δⱼ', fontsize=11)
ax.set_ylabel('Inversion change ΔIⱼ', fontsize=11)
ax.set_title('Increment–Inversion Bridge (Theorem 4)', fontsize=12, fontweight='bold')
ax.set_xticks([-1, 0, 1])
ax.set_yticks([-2, -1, 0, 1, 2])
ax.grid(True, alpha=0.3)

# Panel 3: Convergence to uniform distribution
ax = axes[1, 0]
n = 8
j = 4
times_to_show = [0, 5, 20, 50, 100, 500]
num_trials = 10000

for t in times_to_show:
    pos_counts = np.zeros(n)
    for _ in range(num_trials):
        perm = identity_perm(n)
        for _ in range(t):
            perm = swap_step(perm)
        pos_counts[perm.index(j)] += 1
    pos_counts /= num_trials
    ax.plot(range(n), pos_counts, 'o-', markersize=4, linewidth=1.5, 
            label=f't={t}', alpha=0.8)

ax.axhline(y=1/n, color='black', linestyle='--', alpha=0.5, label='Uniform')
ax.set_xlabel('Position', fontsize=11)
ax.set_ylabel('Probability', fontsize=11)
ax.set_title(f'Convergence to Equilibrium (n={n}, j={j})', fontsize=12, fontweight='bold')
ax.legend(fontsize=8, ncol=2)

# Panel 4: Compensated current J_j(t)
ax = axes[1, 1]
n = 10
j = 5
num_steps = 500
for traj in range(6):
    perm = identity_perm(n)
    positions = [perm.index(j)]
    for _ in range(num_steps):
        perm = swap_step(perm)
        positions.append(perm.index(j))
    
    positions = np.array(positions, dtype=float)
    # Drift-corrected current (drift ≈ 0 for symmetric walk)
    drift = np.mean(np.diff(positions))
    t_arr = np.arange(len(positions))
    current = positions - positions[0] - drift * t_arr
    ax.plot(t_arr, current, alpha=0.5, linewidth=0.8)

ax.set_xlabel('Time t', fontsize=11)
ax.set_ylabel('Compensated current J_j(t)', fontsize=11)
ax.set_title(f'Drift-Corrected Current (n={n}, j={j})', fontsize=12, fontweight='bold')
ax.axhline(y=0, color='black', linestyle='--', alpha=0.3)

plt.suptitle('Tagged-Card Observables: Position, Inversions, and Current', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")


#!/usr/bin/env python3
"""
Visualization 2: Variance Scaling and KPZ Signature Detection

Analyzes the variance scaling of tagged-card displacement to test
for TASEP/KPZ universality signatures. Key questions:
1. Does Var/t converge to a constant (diffusive) or decay (subdiffusive)?
2. Does the fluctuation distribution deviate from Gaussian?
3. Is there a scaling collapse consistent with KPZ exponents?
"""
import numpy as np
import matplotlib.pyplot as plt

def identity_perm(n):
    return list(range(n))

def swap_step(perm):
    n = len(perm)
    i = np.random.randint(0, n - 1)
    p = perm[:]
    p[i], p[i+1] = p[i+1], p[i]
    return p

np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Var/t ratio vs t for multiple n
ax = axes[0, 0]
num_trials = 3000
for n in [5, 7, 10, 15]:
    j = n // 2
    times = [10, 20, 50, 100, 200, 400]
    ratios = []
    for t in times:
        disps = []
        for _ in range(num_trials):
            perm = identity_perm(n)
            for _ in range(t):
                perm = swap_step(perm)
            disps.append(perm.index(j) - j)
        var = np.var(disps)
        ratios.append(var / t)
    ax.plot(times, ratios, 'o-', markersize=4, linewidth=1.5, label=f'n={n}')

ax.set_xlabel('Time t', fontsize=11)
ax.set_ylabel('Var / t', fontsize=11)
ax.set_title('Variance Scaling: Var(Δ)/t vs t', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_xscale('log')

# Panel 2: Histogram vs Gaussian for n=10
ax = axes[0, 1]
n = 10
j = n // 2
t = n * n
disps = []
for _ in range(8000):
    perm = identity_perm(n)
    for _ in range(t):
        perm = swap_step(perm)
    disps.append(perm.index(j))

disps = np.array(disps, dtype=float)
mean, std = np.mean(disps), np.std(disps)

ax.hist(disps, bins=n, density=True, alpha=0.7, color='#3498db', 
        edgecolor='black', linewidth=0.5, label='Empirical')
x_gauss = np.linspace(0, n-1, 200)
gauss = np.exp(-0.5 * ((x_gauss - mean) / std)**2) / (std * np.sqrt(2 * np.pi))
ax.plot(x_gauss, gauss, 'r-', linewidth=2, label='Gaussian fit')
ax.set_xlabel('Position of tagged card', fontsize=11)
ax.set_ylabel('Density', fontsize=11)
ax.set_title(f'Position Distribution (n={n}, t={t})', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 3: Skewness and excess kurtosis vs n
ax = axes[1, 0]
ns = [5, 6, 7, 8, 10, 12, 15]
skewnesses = []
kurtoses = []
for n in ns:
    j = n // 2
    t = n * n
    disps = []
    for _ in range(5000):
        perm = identity_perm(n)
        for _ in range(t):
            perm = swap_step(perm)
        disps.append(perm.index(j))
    
    data = np.array(disps, dtype=float)
    m, s = np.mean(data), np.std(data)
    if s > 0:
        centered = (data - m) / s
        skewnesses.append(np.mean(centered**3))
        kurtoses.append(np.mean(centered**4) - 3)
    else:
        skewnesses.append(0)
        kurtoses.append(0)

ax.plot(ns, skewnesses, 'o-', color='#e74c3c', markersize=5, linewidth=1.5, label='Skewness')
ax.plot(ns, kurtoses, 's-', color='#2ecc71', markersize=5, linewidth=1.5, label='Excess kurtosis')
ax.axhline(y=0, color='black', linestyle='--', alpha=0.3, label='Gaussian value')
ax.set_xlabel('n', fontsize=11)
ax.set_ylabel('Moment', fontsize=11)
ax.set_title('Non-Gaussianity vs n (at t = n²)', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 4: Var * n² vs t (testing TASEP scaling Var ~ t/n²)
ax = axes[1, 1]
num_trials = 2000
for n in [6, 8, 10, 12]:
    j = n // 2
    times = [5, 10, 20, 50, 100, 150, 200]
    scaled_vars = []
    for t in times:
        disps = []
        for _ in range(num_trials):
            perm = identity_perm(n)
            for _ in range(t):
                perm = swap_step(perm)
            disps.append(perm.index(j) - j)
        var = np.var(disps)
        scaled_vars.append(var * n * n / t if t > 0 else 0)
    ax.plot(times, scaled_vars, 'o-', markersize=4, linewidth=1.5, label=f'n={n}')

ax.set_xlabel('Time t', fontsize=11)
ax.set_ylabel('Var · n² / t', fontsize=11)
ax.set_title('TASEP Scaling Test: Var·n²/t vs t', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

plt.suptitle('KPZ/TASEP Scaling Signatures in Tagged-Card Dynamics', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")


#!/usr/bin/env python3
"""
Visualization 1: Tagged Card Trajectories and Drift Decomposition

Shows multiple tagged card position trajectories under the adjacent-swap
walk on S_n, illustrating the random walk behavior predicted by the
drift decomposition theorem. Each step changes the tagged card position
by exactly +1, -1, or 0 (Theorem 1).

The plot reveals the diffusive spreading of position and the bounded
per-step increments that are the hallmark of exclusion-process dynamics.
"""
import numpy as np
import matplotlib.pyplot as plt

def identity_perm(n):
    return list(range(n))

def swap_step(perm):
    n = len(perm)
    i = np.random.randint(0, n - 1)
    p = perm[:]
    p[i], p[i+1] = p[i+1], p[i]
    return p

np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Multiple trajectories for n=8
ax = axes[0, 0]
n = 8
j = 4
num_steps = 300
for traj in range(8):
    perm = identity_perm(n)
    positions = [perm.index(j)]
    for _ in range(num_steps):
        perm = swap_step(perm)
        positions.append(perm.index(j))
    ax.plot(range(num_steps + 1), positions, alpha=0.6, linewidth=0.8)
ax.set_xlabel('Step t', fontsize=11)
ax.set_ylabel('Position of card j', fontsize=11)
ax.set_title(f'Tagged Card Trajectories (n={n}, j={j})', fontsize=12, fontweight='bold')
ax.axhline(y=j, color='black', linestyle='--', alpha=0.3, label='Initial position')
ax.legend(fontsize=9)

# Panel 2: Increment histogram (should be {-1, 0, 1})
ax = axes[0, 1]
increments = []
for _ in range(50000):
    perm = list(np.random.permutation(n))
    i_swap = np.random.randint(0, n - 1)
    old_pos = perm.index(j)
    perm[i_swap], perm[i_swap + 1] = perm[i_swap + 1], perm[i_swap]
    new_pos = perm.index(j)
    increments.append(new_pos - old_pos)

values, counts = np.unique(increments, return_counts=True)
colors = ['#e74c3c' if v == -1 else '#2ecc71' if v == 1 else '#3498db' for v in values]
ax.bar(values, counts / len(increments), color=colors, edgecolor='black', linewidth=0.5, width=0.6)
ax.set_xlabel('Increment Δⱼ', fontsize=11)
ax.set_ylabel('Probability', fontsize=11)
ax.set_title('Drift Decomposition: Increment Distribution', fontsize=12, fontweight='bold')
ax.set_xticks([-1, 0, 1])
for v, c in zip(values, counts):
    ax.annotate(f'{c/len(increments):.3f}', (v, c/len(increments) + 0.01), 
                ha='center', fontsize=10)

# Panel 3: Displacement variance vs time
ax = axes[1, 0]
num_trials = 2000
for n_val in [5, 6, 7, 8, 10]:
    j_val = n_val // 2
    times = list(range(0, 201, 10))
    variances = []
    for t in times:
        disps = []
        for _ in range(num_trials):
            perm = identity_perm(n_val)
            for _ in range(t):
                perm = swap_step(perm)
            disps.append(perm.index(j_val) - j_val)
        variances.append(np.var(disps))
    ax.plot(times, variances, 'o-', markersize=2, linewidth=1.5, label=f'n={n_val}')

ax.set_xlabel('Time t', fontsize=11)
ax.set_ylabel('Var(pos_j(t) − pos_j(0))', fontsize=11)
ax.set_title('Variance Growth (Theorem 2: bounded by t)', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 4: Inversion count trajectory
ax = axes[1, 1]
n = 8
j = 4
num_steps = 200
for traj in range(5):
    perm = identity_perm(n)
    inv_counts = []
    pos_j = perm.index(j)
    inv = sum(1 for k in range(j + 1, n) if perm.index(k) < pos_j)
    inv_counts.append(inv)
    for _ in range(num_steps):
        perm = swap_step(perm)
        pos_j = perm.index(j)
        inv = sum(1 for k in range(j + 1, n) if perm.index(k) < pos_j)
        inv_counts.append(inv)
    ax.plot(range(num_steps + 1), inv_counts, alpha=0.6, linewidth=0.8)

ax.set_xlabel('Step t', fontsize=11)
ax.set_ylabel('Inversion count I_j(σ)', fontsize=11)
ax.set_title(f'Inversion Count Trajectories (n={n}, j={j})', fontsize=12, fontweight='bold')

plt.suptitle('Tagged-Card Dynamics: TASEP Signatures in Permutation Walks', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved viz_trajectories.png")
