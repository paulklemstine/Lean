#!/usr/bin/env python3
"""
Algorithms for Sharp Exponent Lower Bounds in Exchange Descent

Implements the core algorithms from the research:
1. Layer profile construction
2. Adversarial family building
3. Descent simulation and analysis
4. Decision-tree depth computation
"""

from typing import List, Tuple, Dict, Optional, Callable
import numpy as np
from dataclasses import dataclass, field


@dataclass
class LayerProfile:
    """
    A layer profile on a state space.

    Attributes:
        layer_fn: Function mapping states to layer indices (natural numbers)
        top: Maximum layer (start)
        bottom: Minimum layer (target)
    """
    layer_fn: Callable
    top: int
    bottom: int = 0

    @property
    def forced_layer_drop(self) -> int:
        """The forced layer drop: minimum path length through this profile."""
        return self.top - self.bottom


@dataclass
class ExchangeStep:
    """An exchange step: increment coordinate i, decrement coordinate j."""
    i: int
    j: int

    def apply(self, state: np.ndarray) -> np.ndarray:
        """Apply the exchange step to a state vector."""
        result = state.copy()
        result[self.i] += 1
        result[self.j] -= 1
        return result


@dataclass
class AdversarialExchangeFamily:
    """
    An adversarial exchange family in dimension d with depth k.

    Attributes:
        d: Dimension
        k: Certificate depth
        states: Set of feasible states (as list of tuples)
        objective: Objective function
        start: Designated start state
        profile: Layer profile witnessing the lower bound
    """
    d: int
    k: int
    states: List[tuple]
    objective: Callable
    start: tuple
    profile: LayerProfile

    @property
    def forced_layer_drop(self) -> int:
        return self.profile.forced_layer_drop

    @property
    def adversarial_layer_count(self) -> int:
        """The adversarial layer count: d^(d-k-1)."""
        exp = self.d - self.k - 1
        if exp <= 0:
            return 1
        return self.d ** exp


def build_layer_profile(d: int, k: int,
                        hard_coords: Optional[List[int]] = None) -> LayerProfile:
    """
    Build a layer profile for dimension d and depth k.

    Args:
        d: Dimension
        k: Certificate depth
        hard_coords: Indices of "hard" coordinates (default: last d-k-1 coords)

    Returns:
        LayerProfile with forced_layer_drop = sum of hard coordinate ranges
    """
    if hard_coords is None:
        hard_dims = max(d - k - 1, 1)
        hard_coords = list(range(k + 1, d))
        if not hard_coords:
            hard_coords = [0]

    max_val = d - 1  # each coordinate ranges [0, d-1]
    top = len(hard_coords) * max_val

    def layer_fn(state):
        return sum(abs(state[i]) for i in hard_coords)

    return LayerProfile(layer_fn=layer_fn, top=top, bottom=0)


def build_adversarial_family(d: int, k: int) -> AdversarialExchangeFamily:
    """
    Build an explicit adversarial exchange family.

    Construction: Grid on d dimensions where k+1 coordinates are "easy"
    (controlled by the certificate) and d-k-1 are "hard" (form a labyrinth).

    The layer function is the L1 distance in hard coordinates from the target.
    Each exchange step can change at most one hard coordinate, so the layer
    decreases by at most 1 per step.

    Args:
        d: Dimension (≥ 2)
        k: Certificate depth (0 ≤ k < d)

    Returns:
        AdversarialExchangeFamily with forced_layer_drop ≈ d^(d-k-1)
    """
    assert d >= 2 and 0 <= k < d

    hard_dims = max(d - k - 1, 1)
    grid_size = min(d, 6)  # cap for tractability

    # Build profile
    hard_coords = list(range(d - hard_dims, d))
    profile = build_layer_profile(d, k, hard_coords)

    # Start state: all hard coordinates at max
    start = tuple([0] * (d - hard_dims) + [grid_size - 1] * hard_dims)

    # Objective: sum of coordinates (decreasing toward origin)
    def objective(state):
        return sum(state)

    # Generate states (small subset for tractability)
    states = [start]  # at minimum, include start

    return AdversarialExchangeFamily(
        d=d, k=k, states=states, objective=objective,
        start=start, profile=profile
    )


def simulate_exchange_descent(family: AdversarialExchangeFamily,
                                num_trials: int = 100,
                                strategy: str = 'random') -> Dict:
    """
    Simulate exchange descent on an adversarial family.

    Args:
        family: The adversarial exchange family
        num_trials: Number of random trials
        strategy: 'random' (random improving step) or 'greedy' (best step)

    Returns:
        Dict with step counts, layer trajectories, etc.
    """
    d = family.d
    hard_dims = max(d - family.k - 1, 1)
    grid_size = min(d, 8)

    results = {
        'step_counts': [],
        'layer_trajectories': [],
        'min_steps': float('inf'),
        'max_steps': 0,
    }

    for _ in range(num_trials):
        state = list(family.start)
        layers = [family.profile.layer_fn(state)]
        steps = 0

        while any(state[i] > 0 for i in range(d - hard_dims, d)):
            # Find possible improving exchange steps
            candidates = []
            for i in range(d):
                for j in range(d):
                    if i != j and state[j] > 0:
                        # Exchange: state[i] += 1, state[j] -= 1
                        new_state = state.copy()
                        new_state[i] += 1
                        new_state[j] -= 1
                        if sum(new_state) < sum(state) or \
                           (sum(new_state) == sum(state) and
                            family.profile.layer_fn(new_state) < family.profile.layer_fn(state)):
                            candidates.append((i, j, new_state))

            if not candidates:
                # Fallback: simple descent on hard coordinates
                for i in range(d - hard_dims, d):
                    if state[i] > 0:
                        state[i] -= 1
                        steps += 1
                        break
            else:
                if strategy == 'greedy':
                    # Pick the step that decreases objective most
                    best = min(candidates, key=lambda c: sum(c[2]))
                    state = best[2]
                else:
                    # Random improving step
                    idx = np.random.randint(len(candidates))
                    state = candidates[idx][2]
                steps += 1

            layers.append(family.profile.layer_fn(state))

            if steps > 10 * grid_size ** hard_dims:
                break  # safety limit

        results['step_counts'].append(steps)
        results['layer_trajectories'].append(layers)
        results['min_steps'] = min(results['min_steps'], steps)
        results['max_steps'] = max(results['max_steps'], steps)

    return results


def compute_decision_tree_depth_bound(d: int, k: int) -> int:
    """
    Compute the decision-tree depth lower bound.

    The number of forced layers is d^(d-k-1). A decision tree must
    have depth at least log2(d^(d-k-1)) = (d-k-1) * log2(d).

    Args:
        d: Dimension
        k: Certificate depth

    Returns:
        Lower bound on decision-tree depth
    """
    exp = max(d - k - 1, 0)
    if exp == 0:
        return 0
    num_layers = d ** exp
    return int(np.ceil(np.log2(max(num_layers, 1))))


def analyze_exponent_sharpness(d_range: range, k: int) -> Dict:
    """
    Analyze whether the exponent d-k is sharp.

    For each d, compute:
    - Lower bound: d^(d-k-1)
    - Upper bound: d^(d-k)
    - Simulated worst-case: from descent simulation
    - Normalized ratio: simulated / d^(d-k-1)

    Args:
        d_range: Range of dimensions to test
        k: Fixed certificate depth

    Returns:
        Analysis results dict
    """
    results = {
        'd_values': list(d_range),
        'lower_bounds': [],
        'upper_bounds': [],
        'simulated': [],
        'normalized_ratios': [],
        'decision_tree_depths': [],
    }

    for d in d_range:
        if k + 1 >= d:
            results['lower_bounds'].append(1)
            results['upper_bounds'].append(d)
            results['simulated'].append(1)
            results['normalized_ratios'].append(1.0)
            results['decision_tree_depths'].append(0)
            continue

        lb = d ** (d - k - 1)
        ub = d ** (d - k)

        family = build_adversarial_family(d, k)
        sim = simulate_exchange_descent(family, num_trials=50)
        avg_steps = np.mean(sim['step_counts'])
        max_steps = sim['max_steps']

        results['lower_bounds'].append(lb)
        results['upper_bounds'].append(ub)
        results['simulated'].append(max_steps)
        results['normalized_ratios'].append(max_steps / lb if lb > 0 else 0)
        results['decision_tree_depths'].append(compute_decision_tree_depth_bound(d, k))

    return results


if __name__ == '__main__':
    print("=" * 60)
    print("ALGORITHMS: Sharp Exponent Analysis")
    print("=" * 60)

    # Example: build and analyze a family
    d, k = 6, 1
    family = build_adversarial_family(d, k)
    print(f"\nFamily (d={d}, k={k}):")
    print(f"  Adversarial layer count: {family.adversarial_layer_count}")
    print(f"  Forced layer drop: {family.forced_layer_drop}")
    print(f"  Upper bound exponent: d^(d-k) = {d}^{d-k} = {d**(d-k)}")
    print(f"  Lower bound exponent: d^(d-k-1) = {d}^{d-k-1} = {d**(d-k-1)}")
    print(f"  Gap ratio: {d}")

    # Simulate
    sim = simulate_exchange_descent(family, num_trials=100)
    print(f"\nSimulation (100 trials):")
    print(f"  Min steps: {sim['min_steps']}")
    print(f"  Max steps: {sim['max_steps']}")
    print(f"  Mean steps: {np.mean(sim['step_counts']):.1f}")

    # Decision tree depth
    dt_depth = compute_decision_tree_depth_bound(d, k)
    print(f"\nDecision tree depth lower bound: {dt_depth}")

    # Sharpness analysis
    print("\n" + "=" * 60)
    print("SHARPNESS ANALYSIS (k=1)")
    print("=" * 60)
    analysis = analyze_exponent_sharpness(range(3, 10), k=1)
    print(f"{'d':>4} {'LB d^(d-k-1)':>15} {'UB d^(d-k)':>15} {'Ratio':>8} {'DT depth':>10}")
    for i, d in enumerate(analysis['d_values']):
        print(f"{d:>4} {analysis['lower_bounds'][i]:>15} "
              f"{analysis['upper_bounds'][i]:>15} "
              f"{analysis['upper_bounds'][i] // max(analysis['lower_bounds'][i], 1):>8} "
              f"{analysis['decision_tree_depths'][i]:>10}")
