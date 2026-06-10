#!/usr/bin/env python3
"""
Algorithms for Invariant-Bearing Categorical Products.

Implements the core constructions and verification algorithms from the
categorical product framework for invariant-bearing systems.

Algorithms:
1. ProductInvariantComputer - computes max/sum product invariants
2. UniversalLiftConstructor - constructs and verifies universal lifts
3. OptimalityVerifier - verifies optimality of max-invariant
4. TerminationAnalyzer - modular termination analysis via product heights
"""

from dataclasses import dataclass, field
from typing import Callable, List, Tuple, Optional, Dict, Any, TypeVar
import numpy as np

T = TypeVar('T')
U = TypeVar('U')


@dataclass
class InvariantSystem:
    """
    An invariant-bearing system with carrier type and valuation.

    Attributes:
        name: Human-readable name for the system
        states: List of states in the carrier
        invariant: Function mapping states to non-negative real values
    """
    name: str
    states: List[Any]
    invariant: Callable[[Any], float]

    def max_invariant(self) -> float:
        """Compute the maximum invariant value across all states."""
        return max(self.invariant(s) for s in self.states)

    def min_invariant(self) -> float:
        """Compute the minimum invariant value across all states."""
        return min(self.invariant(s) for s in self.states)


@dataclass
class InvariantMorphism:
    """
    A morphism between invariant-bearing systems.

    The morphism f: A → B satisfies B.Inv(f(x)) ≤ A.Inv(x) for all x.
    """
    source: InvariantSystem
    target: InvariantSystem
    map_fn: Callable[[Any], Any]

    def is_valid(self) -> bool:
        """Verify the morphism condition: target.inv(f(x)) ≤ source.inv(x)."""
        for x in self.source.states:
            if self.target.invariant(self.map_fn(x)) > self.source.invariant(x) + 1e-10:
                return False
        return True

    def violation_report(self) -> List[Dict]:
        """Report all violations of the morphism condition."""
        violations = []
        for x in self.source.states:
            target_val = self.target.invariant(self.map_fn(x))
            source_val = self.source.invariant(x)
            if target_val > source_val + 1e-10:
                violations.append({
                    'input': x,
                    'output': self.map_fn(x),
                    'source_inv': source_val,
                    'target_inv': target_val,
                    'gap': target_val - source_val
                })
        return violations


class ProductInvariantComputer:
    """
    Algorithm 1: Compute product invariants.

    Given two invariant-bearing systems (T, I_T) and (U, I_U),
    computes the max-product and additive-product invariants on T × U.

    Time complexity: O(|T| × |U|) for enumeration
    Space complexity: O(|T| × |U|) for storing product states
    """

    @staticmethod
    def max_product(T: InvariantSystem, U: InvariantSystem) -> InvariantSystem:
        """
        Construct the max-product: Inv(t, u) = max(I_T(t), I_U(u)).

        This is the categorical product invariant — the least invariant
        making both projections into valid morphisms.
        """
        product_states = [(t, u) for t in T.states for u in U.states]
        return InvariantSystem(
            name=f"max({T.name}, {U.name})",
            states=product_states,
            invariant=lambda p: max(T.invariant(p[0]), U.invariant(p[1]))
        )

    @staticmethod
    def additive_product(T: InvariantSystem, U: InvariantSystem) -> InvariantSystem:
        """
        Construct the additive product: Inv(t, u) = I_T(t) + I_U(u).

        This models independent resource accumulation.
        """
        product_states = [(t, u) for t in T.states for u in U.states]
        return InvariantSystem(
            name=f"sum({T.name}, {U.name})",
            states=product_states,
            invariant=lambda p: T.invariant(p[0]) + U.invariant(p[1])
        )

    @staticmethod
    def comparison_gap(T: InvariantSystem, U: InvariantSystem) -> Dict:
        """
        Compute the gap between additive and max product invariants.

        Returns statistics about sum(I_T, I_U) - max(I_T, I_U) ≥ 0.
        """
        gaps = []
        for t in T.states:
            for u in U.states:
                it = T.invariant(t)
                iu = U.invariant(u)
                gap = (it + iu) - max(it, iu)
                gaps.append({
                    'state': (t, u),
                    'max_inv': max(it, iu),
                    'sum_inv': it + iu,
                    'gap': gap
                })
        gaps_array = np.array([g['gap'] for g in gaps])
        return {
            'all_nonneg': bool(np.all(gaps_array >= -1e-10)),
            'min_gap': float(np.min(gaps_array)),
            'max_gap': float(np.max(gaps_array)),
            'mean_gap': float(np.mean(gaps_array)),
            'details': gaps
        }


class UniversalLiftConstructor:
    """
    Algorithm 2: Construct universal lifts.

    Given morphisms f: S → T and g: S → U, constructs the unique
    lift h = (f, g): S → T × U satisfying π₁ ∘ h = f and π₂ ∘ h = g.

    Time complexity: O(|S|) for construction, O(|S|) for verification
    Space complexity: O(|S|) for the lift mapping
    """

    @staticmethod
    def construct(
        S: InvariantSystem,
        T: InvariantSystem,
        U: InvariantSystem,
        f: InvariantMorphism,
        g: InvariantMorphism
    ) -> Tuple[InvariantMorphism, Dict]:
        """
        Construct the universal lift and verify all properties.

        Returns:
            (lift_morphism, verification_report)
        """
        TU = ProductInvariantComputer.max_product(T, U)

        lift = InvariantMorphism(
            source=S,
            target=TU,
            map_fn=lambda x: (f.map_fn(x), g.map_fn(x))
        )

        # Verify commutation laws
        fst_commutes = all(
            lift.map_fn(x)[0] == f.map_fn(x) for x in S.states
        )
        snd_commutes = all(
            lift.map_fn(x)[1] == g.map_fn(x) for x in S.states
        )

        report = {
            'lift_is_valid_morphism': lift.is_valid(),
            'fst_commutes': fst_commutes,
            'snd_commutes': snd_commutes,
            'f_is_valid': f.is_valid(),
            'g_is_valid': g.is_valid(),
            'all_properties_hold': (
                lift.is_valid() and fst_commutes and snd_commutes
                and f.is_valid() and g.is_valid()
            )
        }

        return lift, report


class OptimalityVerifier:
    """
    Algorithm 3: Verify optimality of max-invariant.

    Given a candidate invariant I on T × U, verifies whether:
    1. I makes both projections valid (I dominates component invariants)
    2. max dominates I (only true when I = max)
    3. I dominates max (always true when projections are valid)

    Time complexity: O(|T| × |U|) per verification
    """

    @staticmethod
    def verify_projection_validity(
        T: InvariantSystem,
        U: InvariantSystem,
        I: Callable[[Tuple], float]
    ) -> Dict:
        """Check if I makes both projections into valid morphisms."""
        fst_valid = all(
            T.invariant(t) <= I((t, u)) + 1e-10
            for t in T.states for u in U.states
        )
        snd_valid = all(
            U.invariant(u) <= I((t, u)) + 1e-10
            for t in T.states for u in U.states
        )
        return {
            'fst_projection_valid': fst_valid,
            'snd_projection_valid': snd_valid,
            'both_valid': fst_valid and snd_valid
        }

    @staticmethod
    def verify_max_optimality(
        T: InvariantSystem,
        U: InvariantSystem,
        I: Callable[[Tuple], float]
    ) -> Dict:
        """Verify that max ≤ I when I makes both projections valid."""
        results = []
        for t in T.states:
            for u in U.states:
                max_inv = max(T.invariant(t), U.invariant(u))
                i_val = I((t, u))
                results.append({
                    'state': (t, u),
                    'max_inv': max_inv,
                    'I_val': i_val,
                    'max_le_I': max_inv <= i_val + 1e-10
                })

        return {
            'all_optimal': all(r['max_le_I'] for r in results),
            'violations': [r for r in results if not r['max_le_I']],
            'details': results
        }


class TerminationAnalyzer:
    """
    Algorithm 4: Modular termination analysis via product heights.

    Given two reduction systems with height functions, analyzes
    termination of the synchronized product under max-height.

    Time complexity: O(max_height) per trajectory
    Space complexity: O(max_height) for trajectory storage
    """

    @staticmethod
    def simulate_reduction(
        state: Any,
        step: Callable[[Any], Any],
        height: Callable[[Any], int],
        max_steps: int = 1000
    ) -> List[Tuple[Any, int]]:
        """Simulate a reduction sequence, recording (state, height) pairs."""
        trajectory = [(state, height(state))]
        for _ in range(max_steps):
            next_state = step(state)
            if next_state == state:
                break
            state = next_state
            trajectory.append((state, height(state)))
        return trajectory

    @staticmethod
    def analyze_product_termination(
        s1: Any, s2: Any,
        step1: Callable, step2: Callable,
        height1: Callable, height2: Callable,
        max_steps: int = 1000
    ) -> Dict:
        """Analyze termination of the synchronized product system."""
        traj1 = TerminationAnalyzer.simulate_reduction(s1, step1, height1, max_steps)
        traj2 = TerminationAnalyzer.simulate_reduction(s2, step2, height2, max_steps)

        # Product trajectory (synchronized)
        product_heights = []
        for i in range(max(len(traj1), len(traj2))):
            h1 = traj1[min(i, len(traj1)-1)][1]
            h2 = traj2[min(i, len(traj2)-1)][1]
            product_heights.append(max(h1, h2))

        return {
            'system1_steps': len(traj1) - 1,
            'system2_steps': len(traj2) - 1,
            'product_steps': len(product_heights) - 1,
            'system1_terminates': traj1[-1][0] == step1(traj1[-1][0]),
            'system2_terminates': traj2[-1][0] == step2(traj2[-1][0]),
            'initial_product_height': product_heights[0],
            'final_product_height': product_heights[-1],
            'height_trajectory': product_heights,
            'system1_trajectory': [h for _, h in traj1],
            'system2_trajectory': [h for _, h in traj2]
        }


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Create example systems
    T = InvariantSystem("Energy", list(range(10)), lambda x: float(x))
    U = InvariantSystem("Height", list(range(8)), lambda x: float(x ** 2))

    # Algorithm 1: Product invariants
    print("\n--- Algorithm 1: Product Invariants ---")
    max_prod = ProductInvariantComputer.max_product(T, U)
    add_prod = ProductInvariantComputer.additive_product(T, U)
    comparison = ProductInvariantComputer.comparison_gap(T, U)
    print(f"Max product max invariant: {max_prod.max_invariant()}")
    print(f"Add product max invariant: {add_prod.max_invariant()}")
    print(f"All gaps non-negative (max ≤ sum): {comparison['all_nonneg']}")
    print(f"Min gap: {comparison['min_gap']:.2f}, Max gap: {comparison['max_gap']:.2f}")

    # Algorithm 2: Universal lift
    print("\n--- Algorithm 2: Universal Lift ---")
    S = InvariantSystem("Source", list(range(6)), lambda x: float(x + 5))
    f = InvariantMorphism(S, T, lambda x: x)  # identity embedding
    g = InvariantMorphism(S, U, lambda x: x // 3)  # division
    lift, report = UniversalLiftConstructor.construct(S, T, U, f, g)
    print(f"Lift valid: {report['lift_is_valid_morphism']}")
    print(f"π₁ commutes: {report['fst_commutes']}")
    print(f"π₂ commutes: {report['snd_commutes']}")

    # Algorithm 3: Optimality
    print("\n--- Algorithm 3: Optimality Verification ---")
    # Test with a candidate that adds a constant
    I_candidate = lambda p: max(T.invariant(p[0]), U.invariant(p[1])) + 1.0
    proj_check = OptimalityVerifier.verify_projection_validity(T, U, I_candidate)
    opt_check = OptimalityVerifier.verify_max_optimality(T, U, I_candidate)
    print(f"Candidate makes projections valid: {proj_check['both_valid']}")
    print(f"Max ≤ candidate (optimality): {opt_check['all_optimal']}")

    # Algorithm 4: Termination
    print("\n--- Algorithm 4: Termination Analysis ---")
    result = TerminationAnalyzer.analyze_product_termination(
        s1=15, s2=20,
        step1=lambda x: x - 1 if x > 0 else x,
        step2=lambda x: x // 2 if x > 0 else x,
        height1=lambda x: x,
        height2=lambda x: x
    )
    print(f"System 1 terminates: {result['system1_terminates']} in {result['system1_steps']} steps")
    print(f"System 2 terminates: {result['system2_terminates']} in {result['system2_steps']} steps")
    print(f"Product height: {result['initial_product_height']} → {result['final_product_height']}")
    print(f"Product steps: {result['product_steps']}")
