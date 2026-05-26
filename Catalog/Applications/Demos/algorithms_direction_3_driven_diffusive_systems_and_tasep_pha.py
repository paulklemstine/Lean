#!/usr/bin/env python3
"""
Algorithms for Tagged-Card TASEP Analysis

Implements the core algorithmic components for studying tagged-card dynamics
in permutation random walks, including:

1. Efficient permutation walk simulation
2. Tagged-card observable computation
3. Drift/variance estimation
4. Inversion count tracking
5. Current fluctuation analysis

All algorithms correspond to formally verified definitions in the Lean
formalization (TaggedCardTASEP.lean).
"""
import numpy as np
from typing import List, Tuple, Optional, Dict


# ============================================================
# Algorithm 1: Permutation Walk Engine
# ============================================================

class PermutationWalk:
    """
    Efficient simulation of the adjacent-transposition walk on S_n.
    
    The walk at each step uniformly selects a pair of adjacent positions
    (i, i+1) for i in {0, ..., n-2} and swaps the elements at those positions.
    
    Complexity per step: O(1) for swap, O(n) for observable computation.
    
    Usage:
        walk = PermutationWalk(n=8)
        for _ in range(1000):
            walk.step()
        print(walk.position_of(card=3))
    """
    
    def __init__(self, n: int, initial_perm: Optional[List[int]] = None):
        """
        Initialize walk on S_n.
        
        Args:
            n: Size of the permutation group
            initial_perm: Starting permutation (default: identity)
        """
        self.n = n
        if initial_perm is not None:
            self.perm = list(initial_perm)
        else:
            self.perm = list(range(n))
        self._build_inverse()
        self.step_count = 0
    
    def _build_inverse(self):
        """Build inverse permutation for O(1) position lookups."""
        self.inv = [0] * self.n
        for pos, card in enumerate(self.perm):
            self.inv[card] = pos
    
    def step(self) -> int:
        """
        Perform one random adjacent swap step.
        
        Returns:
            The swap index i (positions i and i+1 were swapped)
            
        Time complexity: O(1)
        """
        i = np.random.randint(0, self.n - 1)
        self._swap_positions(i)
        self.step_count += 1
        return i
    
    def _swap_positions(self, i: int):
        """Swap cards at positions i and i+1."""
        card_i = self.perm[i]
        card_i1 = self.perm[i + 1]
        self.perm[i], self.perm[i + 1] = card_i1, card_i
        self.inv[card_i] = i + 1
        self.inv[card_i1] = i
    
    def apply_cycle(self):
        """Apply the long cycle (0 1 2 ... n-1)."""
        last = self.perm[-1]
        for pos in range(self.n - 1, 0, -1):
            self.perm[pos] = self.perm[pos - 1]
        self.perm[0] = last
        self._build_inverse()
        self.step_count += 1
    
    def hybrid_step(self, swap_prob: float = 0.5) -> str:
        """One step of the hybrid walk (swap or cycle)."""
        if np.random.random() < swap_prob:
            self.step()
            return "swap"
        else:
            self.apply_cycle()
            return "cycle"
    
    def position_of(self, card: int) -> int:
        """Position of card j. Time: O(1)."""
        return self.inv[card]
    
    def card_at(self, pos: int) -> int:
        """Card at position pos. Time: O(1)."""
        return self.perm[pos]


# ============================================================
# Algorithm 2: Tagged-Card Observable Tracker
# ============================================================

class TaggedCardTracker:
    """
    Tracks observables for a tagged card in the permutation walk.
    
    Maintains running statistics for:
    - Position trajectory
    - Signed increments
    - Cumulative displacement
    - Running drift estimate
    - Inversion count
    
    Corresponds to the formal definitions:
    - taggedCardPos
    - taggedSignedIncrement
    - taggedInversionCount
    
    Usage:
        walk = PermutationWalk(n=8)
        tracker = TaggedCardTracker(walk, tagged_card=3)
        for _ in range(1000):
            walk.step()
            tracker.record()
        print(tracker.get_statistics())
    """
    
    def __init__(self, walk: PermutationWalk, tagged_card: int):
        self.walk = walk
        self.j = tagged_card
        self.positions: List[int] = [walk.position_of(tagged_card)]
        self.increments: List[int] = []
        self.inversion_counts: List[int] = [self._compute_inversion_count()]
    
    def record(self):
        """Record current state after a walk step."""
        new_pos = self.walk.position_of(self.j)
        old_pos = self.positions[-1]
        self.increments.append(new_pos - old_pos)
        self.positions.append(new_pos)
        self.inversion_counts.append(self._compute_inversion_count())
    
    def _compute_inversion_count(self) -> int:
        """
        Compute I_j(σ) = #{k > j : σ⁻¹(k) < σ⁻¹(j)}.
        
        Time complexity: O(n)
        """
        pos_j = self.walk.position_of(self.j)
        count = 0
        for k in range(self.j + 1, self.walk.n):
            if self.walk.position_of(k) < pos_j:
                count += 1
        return count
    
    def get_statistics(self) -> Dict:
        """
        Compute summary statistics for the tagged card.
        
        Returns dict with:
        - mean_increment: empirical drift per step
        - variance: position variance
        - max_abs_increment: maximum observed |Δ_j|
        - max_inversion_change: maximum observed |ΔI_j|
        """
        increments = np.array(self.increments)
        positions = np.array(self.positions)
        inv_changes = np.diff(self.inversion_counts)
        
        return {
            'mean_increment': np.mean(increments) if len(increments) > 0 else 0,
            'variance': np.var(positions) if len(positions) > 1 else 0,
            'max_abs_increment': np.max(np.abs(increments)) if len(increments) > 0 else 0,
            'max_inversion_change': np.max(np.abs(inv_changes)) if len(inv_changes) > 0 else 0,
            'num_steps': len(increments),
            'final_position': positions[-1] if len(positions) > 0 else 0,
        }
    
    def compensated_current(self, drift: Optional[float] = None) -> np.ndarray:
        """
        Compute drift-corrected (compensated) current J_j(t).
        
        J_j(t) = pos_j(X_t) - pos_j(X_0) - drift * t
        
        If drift is None, uses empirical mean increment.
        """
        positions = np.array(self.positions, dtype=float)
        if drift is None:
            drift = np.mean(self.increments) if self.increments else 0
        
        t = np.arange(len(positions))
        return positions - positions[0] - drift * t


# ============================================================
# Algorithm 3: Variance Scaling Estimator
# ============================================================

def estimate_variance_scaling(
    n: int,
    tagged_card: int,
    time_points: List[int],
    num_trials: int = 2000,
    swap_prob: float = 1.0,
) -> Dict[int, Tuple[float, float]]:
    """
    Estimate variance of tagged card position at multiple time points.
    
    For each time t in time_points, runs num_trials independent walks
    and computes Var(pos_j(X_t)).
    
    Args:
        n: Permutation group size
        tagged_card: Card label j to track
        time_points: List of times at which to measure variance
        num_trials: Number of independent walk samples
        swap_prob: Probability of swap vs cycle step
    
    Returns:
        Dict mapping t -> (variance, variance/t)
    
    Time complexity: O(num_trials * max(time_points) * n)
    """
    results = {}
    
    for t in time_points:
        final_positions = []
        for _ in range(num_trials):
            walk = PermutationWalk(n)
            for _ in range(t):
                if swap_prob >= 1.0:
                    walk.step()
                else:
                    walk.hybrid_step(swap_prob)
            final_positions.append(walk.position_of(tagged_card))
        
        positions = np.array(final_positions, dtype=float)
        var = np.var(positions)
        results[t] = (var, var / t if t > 0 else 0)
    
    return results


# ============================================================
# Algorithm 4: Drift Decomposition Verifier
# ============================================================

def verify_drift_decomposition_exact(n: int, tagged_card: int) -> Dict:
    """
    Exhaustively verify the drift decomposition theorem for all
    permutations in S_n (feasible for small n ≤ 7).
    
    For every σ ∈ S_n and every swap index i ∈ {0,...,n-2},
    verifies that:
    - If σ⁻¹(j) = i: Δ_j = +1
    - If σ⁻¹(j) = i+1: Δ_j = -1
    - Otherwise: Δ_j = 0
    
    Time complexity: O(n! * n)
    """
    import itertools
    
    j = tagged_card
    total_checks = 0
    violations = 0
    
    for perm_tuple in itertools.permutations(range(n)):
        perm = list(perm_tuple)
        pos_j = perm.index(j)
        
        for i in range(n - 1):
            new_perm = perm[:]
            new_perm[i], new_perm[i+1] = new_perm[i+1], new_perm[i]
            delta = new_perm.index(j) - perm.index(j)
            
            if pos_j == i:
                expected = 1
            elif pos_j == i + 1:
                expected = -1
            else:
                expected = 0
            
            if delta != expected:
                violations += 1
            total_checks += 1
    
    return {
        'n': n,
        'tagged_card': j,
        'total_checks': total_checks,
        'violations': violations,
        'verified': violations == 0,
    }


# ============================================================
# Algorithm 5: Current Fluctuation Analyzer
# ============================================================

def analyze_current_fluctuations(
    n: int,
    tagged_card: int,
    num_steps: int,
    num_trials: int = 5000,
) -> Dict:
    """
    Analyze fluctuation statistics of the drift-corrected tagged current.
    
    Computes:
    - Mean, variance, skewness, kurtosis of the centered displacement
    - Comparison with Gaussian baseline
    - Preliminary KPZ/TASEP scaling test
    
    Args:
        n: Permutation group size
        tagged_card: Card label to track
        num_steps: Number of walk steps
        num_trials: Number of independent samples
    
    Returns:
        Dict with fluctuation statistics
    """
    final_displacements = []
    
    for _ in range(num_trials):
        walk = PermutationWalk(n)
        for _ in range(num_steps):
            walk.step()
        final_displacements.append(walk.position_of(tagged_card) - tagged_card)
    
    data = np.array(final_displacements, dtype=float)
    mean = np.mean(data)
    var = np.var(data)
    std = np.std(data)
    
    if std > 1e-10:
        centered = (data - mean) / std
        skewness = np.mean(centered ** 3)
        excess_kurtosis = np.mean(centered ** 4) - 3
    else:
        skewness = 0.0
        excess_kurtosis = 0.0
    
    return {
        'n': n,
        'tagged_card': tagged_card,
        'num_steps': num_steps,
        'num_trials': num_trials,
        'mean_displacement': mean,
        'variance': var,
        'skewness': skewness,
        'excess_kurtosis': excess_kurtosis,
        'gaussian_deviation': abs(skewness) + abs(excess_kurtosis),
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Tagged-Card TASEP Algorithms\n")
    
    # Example 1: Walk simulation
    walk = PermutationWalk(8)
    tracker = TaggedCardTracker(walk, tagged_card=4)
    for _ in range(500):
        walk.step()
        tracker.record()
    stats = tracker.get_statistics()
    print(f"Walk statistics (n=8, j=4, 500 steps):")
    for k, v in stats.items():
        print(f"  {k}: {v}")
    
    # Example 2: Exact verification
    print(f"\nExact drift decomposition verification:")
    for n in [4, 5, 6]:
        result = verify_drift_decomposition_exact(n, n // 2)
        print(f"  n={n}: {result['total_checks']} checks, "
              f"{'PASSED' if result['verified'] else 'FAILED'}")
    
    # Example 3: Variance scaling
    print(f"\nVariance scaling (n=8, j=4):")
    scaling = estimate_variance_scaling(8, 4, [10, 50, 100, 200, 500])
    for t, (var, ratio) in sorted(scaling.items()):
        print(f"  t={t:4d}: Var={var:.3f}, Var/t={ratio:.5f}")
    
    # Example 4: Fluctuation analysis
    print(f"\nFluctuation analysis:")
    for n in [6, 8, 10]:
        result = analyze_current_fluctuations(n, n//2, n*n, num_trials=3000)
        print(f"  n={n}: skew={result['skewness']:+.3f}, "
              f"kurt={result['excess_kurtosis']:+.3f}, "
              f"gauss_dev={result['gaussian_deviation']:.3f}")
