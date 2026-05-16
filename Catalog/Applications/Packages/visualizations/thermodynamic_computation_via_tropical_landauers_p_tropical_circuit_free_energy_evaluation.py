#!/usr/bin/env python3
"""
Algorithms for Tropical Thermodynamic Computation

Implements the core algorithms from the research paper:
1. Fiber-counting Landauer bound computation
2. Tropical circuit free energy evaluation
3. Optimal erasure strategy computation
4. Thermodynamic cost analysis for Boolean functions
"""

import math
from typing import Callable, Dict, List, Optional, Set, Tuple
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Fiber-Counting Landauer Bound
# ============================================================

@dataclass
class LandauerAnalysis:
    """Complete Landauer analysis of a finite map."""
    domain_size: int
    range_size: int
    fiber_sizes: Dict[int, int]
    min_fiber: int
    max_fiber: int
    entropy_defect: float
    landauer_bound: float  # log(min_fiber) when all fibers ≥ min_fiber
    is_injective: bool
    is_constant: bool

    def __repr__(self):
        return (
            f"LandauerAnalysis(\n"
            f"  domain={self.domain_size}, range={self.range_size},\n"
            f"  fibers={self.fiber_sizes},\n"
            f"  min_fiber={self.min_fiber}, max_fiber={self.max_fiber},\n"
            f"  entropy_defect={self.entropy_defect:.6f},\n"
            f"  landauer_bound={self.landauer_bound:.6f},\n"
            f"  injective={self.is_injective}, constant={self.is_constant}\n"
            f")"
        )


def analyze_landauer(f: Callable[[int], int], domain: List[int]) -> LandauerAnalysis:
    """Complete Landauer analysis of a finite map.

    Computes fiber sizes, entropy defect, and Landauer lower bound.

    Time complexity: O(|domain|)
    Space complexity: O(|range|)

    Args:
        f: A function from integers to integers
        domain: The finite domain as a list of integers

    Returns:
        LandauerAnalysis with all computed quantities
    """
    # Compute fibers
    fibers: Dict[int, int] = {}
    for x in domain:
        y = f(x)
        fibers[y] = fibers.get(y, 0) + 1

    n = len(domain)
    r = len(fibers)

    if n == 0:
        return LandauerAnalysis(
            domain_size=0, range_size=0,
            fiber_sizes={}, min_fiber=0, max_fiber=0,
            entropy_defect=0.0, landauer_bound=0.0,
            is_injective=True, is_constant=True
        )

    fiber_values = list(fibers.values())
    min_f = min(fiber_values)
    max_f = max(fiber_values)

    # Entropy defect
    log_n = math.log(n) if n > 0 else 0.0
    log_r = math.log(r) if r > 0 else 0.0
    defect = log_n - log_r

    # Landauer bound: valid when all fibers ≥ min_f
    bound = math.log(min_f) if min_f >= 1 else 0.0

    return LandauerAnalysis(
        domain_size=n, range_size=r,
        fiber_sizes=fibers,
        min_fiber=min_f, max_fiber=max_f,
        entropy_defect=defect,
        landauer_bound=bound,
        is_injective=(min_f == 1 and max_f == 1),
        is_constant=(r == 1)
    )


# ============================================================
# Algorithm 2: Tropical Circuit Evaluation
# ============================================================

@dataclass
class CircuitNode:
    """A node in a tropical circuit DAG."""
    kind: str  # 'input', 'gate', 'seq', 'par'
    children: List['CircuitNode']
    _depth_cache: Optional[int] = None
    _fe_cache: Optional[float] = None

    @staticmethod
    def input() -> 'CircuitNode':
        return CircuitNode('input', [])

    @staticmethod
    def gate(c: 'CircuitNode') -> 'CircuitNode':
        return CircuitNode('gate', [c])

    @staticmethod
    def seq(a: 'CircuitNode', b: 'CircuitNode') -> 'CircuitNode':
        return CircuitNode('seq', [a, b])

    @staticmethod
    def par(a: 'CircuitNode', b: 'CircuitNode') -> 'CircuitNode':
        return CircuitNode('par', [a, b])

    def depth(self) -> int:
        """Compute circuit depth with memoization.

        Time: O(|circuit|) with memoization
        """
        if self._depth_cache is not None:
            return self._depth_cache

        if self.kind == 'input':
            result = 0
        elif self.kind == 'gate':
            result = self.children[0].depth() + 1
        elif self.kind == 'seq':
            result = self.children[0].depth() + self.children[1].depth()
        elif self.kind == 'par':
            result = max(self.children[0].depth(), self.children[1].depth())
        else:
            raise ValueError(f"Unknown kind: {self.kind}")

        self._depth_cache = result
        return result

    def free_energy(self) -> float:
        """Compute min-plus free energy with memoization.

        By the Free Energy = Depth theorem, this always equals depth.
        Time: O(|circuit|) with memoization
        """
        if self._fe_cache is not None:
            return self._fe_cache

        if self.kind == 'input':
            result = 0.0
        elif self.kind == 'gate':
            result = self.children[0].free_energy() + 1.0
        elif self.kind == 'seq':
            result = self.children[0].free_energy() + self.children[1].free_energy()
        elif self.kind == 'par':
            result = max(self.children[0].free_energy(), self.children[1].free_energy())
        else:
            raise ValueError(f"Unknown kind: {self.kind}")

        self._fe_cache = result
        return result

    def verify_fe_eq_depth(self) -> bool:
        """Verify the Free Energy = Depth theorem computationally."""
        return abs(self.free_energy() - float(self.depth())) < 1e-12

    def node_count(self) -> int:
        """Count total nodes in the circuit."""
        return 1 + sum(c.node_count() for c in self.children)

    def gate_count(self) -> int:
        """Count gate nodes (computational steps)."""
        own = 1 if self.kind == 'gate' else 0
        return own + sum(c.gate_count() for c in self.children)


# ============================================================
# Algorithm 3: Optimal Erasure Strategy
# ============================================================

def optimal_erasure_cost(n: int, target: int = 1) -> Tuple[float, List[Tuple[int, int]]]:
    """Compute the minimum Landauer cost to erase n states down to target states.

    Uses the fact that total cost = log(n/target) regardless of strategy,
    by telescoping of entropy defects.

    Args:
        n: Initial number of distinguishable states
        target: Target number of states (default 1 = full erasure)

    Returns:
        (total_cost, [(step_from, step_to), ...]) — cost and one optimal strategy

    Time: O(log(n/target))
    """
    if n <= target:
        return 0.0, []

    total_cost = math.log(n) - math.log(target)
    steps = []

    # Binary halving strategy (one possible optimal decomposition)
    current = n
    while current > target:
        next_size = max(target, current // 2)
        steps.append((current, next_size))
        current = next_size

    return total_cost, steps


# ============================================================
# Algorithm 4: Thermodynamic Cost Analysis
# ============================================================

@dataclass
class ThermodynamicProfile:
    """Thermodynamic profile of a computation."""
    total_landauer_cost: float  # in units of kT
    circuit_depth: int
    circuit_free_energy: float
    thermal_cost_joules: float  # at given temperature
    bits_erased: float
    efficiency: float  # ratio of minimum cost to actual cost

    def __repr__(self):
        return (
            f"ThermodynamicProfile(\n"
            f"  landauer_cost={self.total_landauer_cost:.4f} kT,\n"
            f"  depth={self.circuit_depth},\n"
            f"  free_energy={self.circuit_free_energy:.4f},\n"
            f"  thermal_cost={self.thermal_cost_joules:.4e} J,\n"
            f"  bits_erased={self.bits_erased:.2f},\n"
            f"  efficiency={self.efficiency:.4f}\n"
            f")"
        )


def thermodynamic_profile(
    f: Callable[[int], int],
    domain: List[int],
    circuit: CircuitNode,
    temperature: float = 300.0,
    k_B: float = 1.380649e-23
) -> ThermodynamicProfile:
    """Compute the complete thermodynamic profile of a computation.

    Combines Landauer analysis with circuit free energy to give
    a unified thermodynamic characterization.

    Args:
        f: The function being computed
        domain: Finite domain
        circuit: Circuit implementing f
        temperature: Temperature in Kelvin
        k_B: Boltzmann constant in J/K

    Returns:
        ThermodynamicProfile with all quantities
    """
    analysis = analyze_landauer(f, domain)
    depth = circuit.depth()
    fe = circuit.free_energy()

    landauer = analysis.entropy_defect  # in natural units
    bits = landauer / math.log(2) if math.log(2) > 0 else 0
    thermal = k_B * temperature * landauer

    # Efficiency: ratio of Landauer minimum to circuit free energy cost
    eff = landauer / fe if fe > 0 else 1.0

    return ThermodynamicProfile(
        total_landauer_cost=landauer,
        circuit_depth=depth,
        circuit_free_energy=fe,
        thermal_cost_joules=thermal,
        bits_erased=bits,
        efficiency=min(eff, 1.0)
    )


# ============================================================
# Main: Run all algorithms with examples
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Algorithm Demonstrations")
    print("=" * 70)

    # Algorithm 1: Landauer analysis
    print("\n--- Algorithm 1: Fiber-Counting Landauer Analysis ---")

    # Binary AND gate
    def binary_and(x: int) -> int:
        """AND gate: (a,b) → a∧b, encoded as 4 inputs → 2 outputs."""
        return 1 if x == 3 else 0  # Only (1,1)→1

    analysis = analyze_landauer(binary_and, [0, 1, 2, 3])
    print(f"\nBinary AND gate (4 inputs):")
    print(analysis)

    # Identity (reversible)
    analysis_id = analyze_landauer(lambda x: x, list(range(8)))
    print(f"\nIdentity on 8 elements:")
    print(analysis_id)

    # Algorithm 2: Circuit evaluation
    print("\n--- Algorithm 2: Circuit Free Energy ---")
    # Build a depth-5 circuit
    c = CircuitNode.input()
    for _ in range(5):
        c = CircuitNode.gate(c)
    print(f"\nDepth-5 pipeline:")
    print(f"  Depth: {c.depth()}")
    print(f"  Free energy: {c.free_energy()}")
    print(f"  FE = depth: {c.verify_fe_eq_depth()}")
    print(f"  Nodes: {c.node_count()}, Gates: {c.gate_count()}")

    # Algorithm 3: Optimal erasure
    print("\n--- Algorithm 3: Optimal Erasure Strategy ---")
    for n in [2, 8, 256, 1024]:
        cost, steps = optimal_erasure_cost(n)
        print(f"\n  Erasing {n} → 1:")
        print(f"    Minimum cost: {cost:.4f} = log({n}) = {cost/math.log(2):.2f} bits")
        print(f"    Strategy ({len(steps)} steps): {steps}")

    # Algorithm 4: Full thermodynamic profile
    print("\n--- Algorithm 4: Thermodynamic Profile ---")
    circuit = CircuitNode.seq(
        CircuitNode.gate(CircuitNode.input()),
        CircuitNode.gate(CircuitNode.input())
    )
    profile = thermodynamic_profile(binary_and, [0, 1, 2, 3], circuit)
    print(f"\nAND gate with depth-2 circuit at 300K:")
    print(profile)
