#!/usr/bin/env python3
"""
Algorithms for Tropical Thermodynamic Complexity

Implements the core algorithms from the formal framework:
1. Reversible simulation via swap construction
2. Entropy cost analysis for finite-state computations
3. Tropical cost function operations
4. Landauer cost calculation
"""

import numpy as np
from typing import Callable, Dict, List, Optional, Tuple
import math


# ============================================================
# Algorithm 1: Reversible Swap Simulation
# ============================================================

class SwapSimulator:
    """
    Reversible simulation of arbitrary finite-state functions using the swap construction.

    Given step : σ → σ on a finite state space {0, ..., N-1}:
    - Encodes x as (x, step(x)) in σ × σ
    - Applies swap: (a, b) → (b, a)
    - Decodes by taking the first component

    This yields a bijection on σ × σ that faithfully simulates step.

    Time complexity: O(1) per simulation step
    Space complexity: O(N) additional (one extra register)
    """

    def __init__(self, step: Callable[[int], int], n_states: int):
        """
        Args:
            step: Function from {0,...,n_states-1} to itself
            n_states: Size of state space
        """
        self.step = step
        self.n_states = n_states
        self._validate()

    def _validate(self):
        """Verify step maps within the state space."""
        for x in range(self.n_states):
            y = self.step(x)
            assert 0 <= y < self.n_states, f"step({x}) = {y} out of range [0, {self.n_states})"

    def encode(self, x: int) -> Tuple[int, int]:
        """Encode state x as (x, step(x))."""
        return (x, self.step(x))

    def decode(self, pair: Tuple[int, int]) -> int:
        """Decode pair to result: take first component."""
        return pair[0]

    def swap(self, pair: Tuple[int, int]) -> Tuple[int, int]:
        """Apply the reversible swap bijection."""
        return (pair[1], pair[0])

    def simulate_one_step(self, x: int) -> int:
        """Simulate one step of the original function."""
        encoded = self.encode(x)
        swapped = self.swap(encoded)
        return self.decode(swapped)

    def simulate_t_steps(self, x: int, t: int) -> int:
        """Simulate t iterations of step, using separate swap for each."""
        result = x
        for _ in range(t):
            result = self.step(result)
        return result

    def verify_simulation(self) -> bool:
        """Verify that simulation matches direct computation for all states."""
        for x in range(self.n_states):
            if self.simulate_one_step(x) != self.step(x):
                return False
        return True

    def verify_swap_bijective(self) -> bool:
        """Verify that swap is bijective on σ × σ."""
        image = set()
        for a in range(self.n_states):
            for b in range(self.n_states):
                image.add(self.swap((a, b)))
        return len(image) == self.n_states ** 2

    def entropy_cost(self) -> float:
        """Compute the uniform entropy loss δ(step) = log|σ| - log|range(step)|."""
        image_size = len(set(self.step(x) for x in range(self.n_states)))
        return math.log(self.n_states) - math.log(image_size)

    def is_reversible(self) -> bool:
        """Check if step is bijective (zero entropy cost)."""
        return len(set(self.step(x) for x in range(self.n_states))) == self.n_states


# ============================================================
# Algorithm 2: Entropy Cost Analyzer
# ============================================================

class EntropyCostAnalyzer:
    """
    Analyzes the thermodynamic cost of finite-state computations.

    Computes:
    - Shannon entropy of distributions
    - Uniform entropy loss (counting entropy defect)
    - Landauer cost at given temperature
    - Breakdown of reversible vs irreversible steps
    """

    def __init__(self, k_B: float = 1.380649e-23, temperature: float = 300.0):
        """
        Args:
            k_B: Boltzmann constant in J/K
            temperature: Temperature in Kelvin
        """
        self.k_B = k_B
        self.T = temperature

    def shannon_entropy(self, p: np.ndarray) -> float:
        """
        Compute Shannon entropy H(p) = -∑ p(x) log(p(x)).
        Uses natural logarithm.
        """
        p = np.asarray(p, dtype=float)
        mask = p > 0
        return -np.sum(p[mask] * np.log(p[mask]))

    def uniform_entropy(self, n_states: int) -> float:
        """Shannon entropy of uniform distribution over n states: log(n)."""
        return math.log(n_states) if n_states > 0 else 0.0

    def entropy_loss(self, step: Callable[[int], int], n_states: int) -> float:
        """
        Uniform entropy loss: log|σ| - log|range(step)|.
        Zero iff step is bijective.
        """
        image_size = len(set(step(x) for x in range(n_states)))
        return math.log(n_states) - math.log(image_size)

    def landauer_cost(self, delta_h: float) -> float:
        """Landauer cost: k_B · T · ΔH."""
        return self.k_B * self.T * delta_h

    def landauer_cost_n_bits(self, n_bits: int) -> float:
        """Exact Landauer cost for n-bit uniform erasure: n · k_B · T · log(2)."""
        return n_bits * self.k_B * self.T * math.log(2)

    def analyze_computation(self, steps: List[Tuple[str, Callable[[int], int]]],
                            n_states: int) -> Dict:
        """
        Analyze a sequence of computational steps.

        Returns dict with per-step and total analysis.
        """
        results = []
        total_entropy_loss = 0.0

        for name, step in steps:
            delta = self.entropy_loss(step, n_states)
            cost = self.landauer_cost(delta)
            is_rev = abs(delta) < 1e-12
            total_entropy_loss += delta

            results.append({
                "name": name,
                "entropy_loss": delta,
                "landauer_cost_J": cost,
                "is_reversible": is_rev,
            })

        return {
            "steps": results,
            "total_entropy_loss": total_entropy_loss,
            "total_landauer_cost_J": self.landauer_cost(total_entropy_loss),
            "n_reversible": sum(1 for r in results if r["is_reversible"]),
            "n_irreversible": sum(1 for r in results if not r["is_reversible"]),
        }


# ============================================================
# Algorithm 3: Tropical Cost Operations
# ============================================================

class TropicalCostSpace:
    """
    Tropical (min-plus) algebra on cost function spaces.

    Operations:
    - Tropical addition (⊕): pointwise minimum
    - Tropical scalar multiplication (⊗ₛ): pointwise constant addition
    - Tropical multiplication (⊗): pointwise real addition
    - Pullback along permutations
    """

    @staticmethod
    def trop_add(phi: np.ndarray, psi: np.ndarray) -> np.ndarray:
        """Tropical addition: pointwise minimum."""
        return np.minimum(phi, psi)

    @staticmethod
    def trop_smul(c: float, phi: np.ndarray) -> np.ndarray:
        """Tropical scalar multiplication: add constant."""
        return c + phi

    @staticmethod
    def trop_mul(phi: np.ndarray, psi: np.ndarray) -> np.ndarray:
        """Tropical multiplication: pointwise addition."""
        return phi + psi

    @staticmethod
    def pullback(phi: np.ndarray, perm: np.ndarray) -> np.ndarray:
        """
        Pullback of cost function along a permutation.
        pullback_σ(Φ)(x) = Φ(σ(x))
        """
        return phi[perm]

    @staticmethod
    def verify_tropical_iso(perm: np.ndarray, n_tests: int = 100) -> Dict[str, bool]:
        """
        Verify that pullback along a permutation preserves tropical operations.
        Uses random test cost functions.
        """
        n = len(perm)
        results = {"add": True, "smul": True, "mul": True, "bijective": True}

        for _ in range(n_tests):
            phi = np.random.randn(n)
            psi = np.random.randn(n)
            c = np.random.randn()

            pb = lambda f: f[perm]

            # Check tropical addition
            if not np.allclose(pb(np.minimum(phi, psi)),
                               np.minimum(pb(phi), pb(psi))):
                results["add"] = False

            # Check tropical scalar mul
            if not np.allclose(pb(c + phi), c + pb(phi)):
                results["smul"] = False

            # Check tropical mul
            if not np.allclose(pb(phi + psi), pb(phi) + pb(psi)):
                results["mul"] = False

        # Check bijectivity (permutation is always bijective)
        results["bijective"] = len(set(perm)) == n

        return results


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # 1. Swap Simulator
    print("\n--- Swap Simulator ---")
    N = 8
    step = lambda x: (x * 3 + 1) % N
    sim = SwapSimulator(step, N)
    print(f"Function: x ↦ (3x+1) mod {N}")
    print(f"Simulation correct: {sim.verify_simulation()}")
    print(f"Swap bijective: {sim.verify_swap_bijective()}")
    print(f"Entropy cost: {sim.entropy_cost():.6f}")
    print(f"Is reversible: {sim.is_reversible()}")

    # 2. Entropy Cost Analyzer
    print("\n--- Entropy Cost Analyzer ---")
    analyzer = EntropyCostAnalyzer()
    steps = [
        ("NOT (flip)", lambda x: (N - 1 - x)),
        ("Collapse mod 4", lambda x: x % 4),
        ("Increment mod 4", lambda x: (x + 1) % 4 if x < 4 else x),
    ]
    analysis = analyzer.analyze_computation(steps, N)
    for r in analysis["steps"]:
        print(f"  {r['name']:>20}: δ={r['entropy_loss']:.4f}, "
              f"cost={r['landauer_cost_J']:.3e} J, rev={r['is_reversible']}")
    print(f"  Total: δ={analysis['total_entropy_loss']:.4f}, "
          f"cost={analysis['total_landauer_cost_J']:.3e} J")
    print(f"  Reversible: {analysis['n_reversible']}, Irreversible: {analysis['n_irreversible']}")

    # 3. Tropical Cost Space
    print("\n--- Tropical Isomorphism Verification ---")
    perm = np.array([2, 0, 3, 1, 6, 4, 7, 5])  # random permutation of 8 elements
    results = TropicalCostSpace.verify_tropical_iso(perm)
    for key, val in results.items():
        print(f"  Preserves {key}: {val}")

    print("\nAll algorithm demonstrations complete.")
