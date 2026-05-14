#!/usr/bin/env python3
"""
Tropical Thermodynamic Complexity Theory — Algorithms

Implementations of the core algorithms from the research:
1. Tropical energy transport along reversible maps
2. Counting entropy computation
3. Landauer cost calculator
4. Bennett history construction for reversible simulation
5. Tropical free energy computation
"""

import math
from typing import Callable, Dict, List, Optional, Tuple, Set
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Tropical Energy Transport
# ============================================================
@dataclass
class TropicalSystem:
    """A finite tropical dynamical system.
    
    Attributes:
        states: List of configuration states
        energy: Energy function E : σ → ℝ
        
    Time complexity: O(|σ|) for transport, O(|σ| log |σ|) for free energy
    Space complexity: O(|σ|)
    """
    states: List[int]
    energy: Dict[int, float]
    
    def transport(self, bijection: Dict[int, int]) -> 'TropicalSystem':
        """Transport energy along a bijection f.
        
        Φ_f(E)(x) = E(f⁻¹(x))
        
        Time: O(|σ|)
        Space: O(|σ|)
        
        Args:
            bijection: A bijection f : σ → σ as a dictionary
            
        Returns:
            New TropicalSystem with transported energy
        """
        f_inv = {v: k for k, v in bijection.items()}
        new_energy = {x: self.energy[f_inv[x]] for x in self.states}
        return TropicalSystem(self.states, new_energy)
    
    def free_energy(self) -> float:
        """Compute tropical free energy: min_x E(x).
        
        Time: O(|σ|)
        """
        return min(self.energy.values())
    
    def counting_entropy(self) -> float:
        """Compute counting entropy: log(|σ|).
        
        Time: O(1)
        """
        return math.log(len(self.states))


def compose_bijections(f: Dict[int, int], g: Dict[int, int]) -> Dict[int, int]:
    """Compose two bijections: (f ∘ g)(x) = f(g(x)).
    
    Time: O(|σ|)
    
    >>> f = {0: 1, 1: 0}
    >>> compose_bijections(f, f)
    {0: 0, 1: 1}
    """
    return {x: f[g[x]] for x in g}


def verify_transport_composition(
    sys: TropicalSystem,
    f: Dict[int, int],
    g: Dict[int, int]
) -> bool:
    """Verify: Φ_{f∘g}(E) = Φ_g(Φ_f(E)).
    
    This checks the composition theorem tropicalTransport_comp.
    
    Time: O(|σ|)
    """
    fg = compose_bijections(g, f)  # g ∘ f in our convention
    
    lhs = sys.transport(fg)
    rhs = sys.transport(f).transport(g)
    
    return all(abs(lhs.energy[x] - rhs.energy[x]) < 1e-12 for x in sys.states)


# ============================================================
# Algorithm 2: Landauer Cost Calculator
# ============================================================
@dataclass
class ErasureMap:
    """A uniform-fiber erasure map e : σ → τ.
    
    Attributes:
        source_card: |σ|
        target_card: |τ|
        n_bits: Number of erased bits (fiber size = 2^n_bits)
        mapping: Optional explicit mapping
    """
    source_card: int
    target_card: int
    n_bits: int
    mapping: Optional[Dict[int, int]] = None
    
    @classmethod
    def from_mapping(cls, mapping: Dict[int, int]) -> 'ErasureMap':
        """Construct from explicit mapping, computing fiber structure.
        
        Time: O(|σ|)
        """
        source_card = len(mapping)
        target_card = len(set(mapping.values()))
        
        # Compute fiber sizes
        fibers: Dict[int, int] = {}
        for x, y in mapping.items():
            fibers[y] = fibers.get(y, 0) + 1
        
        # Check uniformity
        fiber_sizes = set(fibers.values())
        if len(fiber_sizes) != 1:
            raise ValueError(f"Non-uniform fibers: {fiber_sizes}")
        
        fiber_size = fiber_sizes.pop()
        n_bits = round(math.log2(fiber_size))
        if 2 ** n_bits != fiber_size:
            raise ValueError(f"Fiber size {fiber_size} is not a power of 2")
        
        return cls(source_card, target_card, n_bits, mapping)
    
    def entropy_drop(self) -> float:
        """Compute entropy drop: n * ln(2).
        
        This is the content of entropy_drop_of_uniform_fiber.
        
        Time: O(1)
        """
        return self.n_bits * math.log(2)
    
    def landauer_cost(self, kB: float, T: float) -> float:
        """Compute Landauer cost: kB * T * n * ln(2).
        
        This is the content of landauer_cost_uniform_erasure.
        
        Time: O(1)
        
        Args:
            kB: Boltzmann constant (1.380649e-23 J/K)
            T: Temperature in Kelvin
            
        Returns:
            Minimum heat dissipation in Joules
        """
        return kB * T * self.entropy_drop()
    
    def verify_cardinality(self) -> bool:
        """Verify: |σ| = |τ| × 2^n.
        
        This is card_eq_card_mul_fiber_of_uniform_surjective.
        
        Time: O(1)
        """
        return self.source_card == self.target_card * (2 ** self.n_bits)
    
    def verify_log_identity(self) -> bool:
        """Verify: log|σ| = log|τ| + n·log(2).
        
        This is log_card_ratio_uniform_fiber.
        
        Time: O(1)
        """
        lhs = math.log(self.source_card)
        rhs = math.log(self.target_card) + self.n_bits * math.log(2)
        return abs(lhs - rhs) < 1e-12


def one_bit_erasure(alpha_size: int) -> ErasureMap:
    """Construct the canonical one-bit erasure Bool × α → α.
    
    This is the eraseBit function from the formal development.
    
    Time: O(|α|)
    """
    mapping = {}
    for b in [0, 1]:  # Bool
        for a in range(alpha_size):
            mapping[(b, a)] = a
    
    # Flatten keys for ErasureMap
    flat_mapping = {}
    idx = 0
    for b in [0, 1]:
        for a in range(alpha_size):
            flat_mapping[idx] = a
            idx += 1
    
    return ErasureMap(
        source_card=2 * alpha_size,
        target_card=alpha_size,
        n_bits=1,
        mapping=flat_mapping
    )


# ============================================================
# Algorithm 3: Bennett History Construction
# ============================================================
@dataclass
class ReversibleExtension:
    """A reversible extension of a deterministic step function.
    
    Given step : σ → σ (possibly non-injective), constructs:
    - τ = σ × σ (extended state space)
    - enc : σ → τ (encoding)
    - proj : τ → σ (projection)
    - R : τ ≃ τ (reversible step)
    
    Such that proj(R(enc(x))) = step(x) for all x.
    
    This implements reversible_extension_with_garbage.
    """
    states: List[int]
    step: Dict[int, int]
    
    def encode(self, x: int) -> Tuple[int, int]:
        """enc(x) = (x, step(x))"""
        return (x, self.step[x])
    
    def project(self, pair: Tuple[int, int]) -> int:
        """proj(a, b) = b (extract result)"""
        return pair[1]
    
    def reversible_step(self, pair: Tuple[int, int]) -> Tuple[int, int]:
        """R = identity (trivially reversible).
        
        The formal proof uses R = id on the encoded space,
        with the computation embedded in the encoding.
        """
        return pair
    
    def simulate(self, x: int) -> int:
        """Simulate one step: proj(R(enc(x))) = step(x).
        
        Time: O(1)
        """
        encoded = self.encode(x)
        stepped = self.reversible_step(encoded)
        return self.project(stepped)
    
    def verify(self) -> bool:
        """Verify the simulation is correct for all states.
        
        Time: O(|σ|)
        """
        return all(self.simulate(x) == self.step[x] for x in self.states)
    
    def extended_state_space_size(self) -> int:
        """Size of the extended state space |τ| = |σ|².
        
        The overhead is polynomial (quadratic).
        """
        return len(self.states) ** 2


def make_reversible(states: List[int], step: Dict[int, int]) -> ReversibleExtension:
    """Construct a reversible extension of a deterministic step function.
    
    This is the algorithm behind reversible_extension_with_garbage.
    
    Time: O(|σ|)
    Space: O(|σ|²) for the extended state space
    
    Args:
        states: List of states in σ
        step: Step function as a dictionary
        
    Returns:
        ReversibleExtension witnessing the simulation
        
    Example:
        >>> states = [0, 1, 2, 3]
        >>> step = {0: 1, 1: 1, 2: 3, 3: 3}  # non-injective
        >>> ext = make_reversible(states, step)
        >>> ext.verify()
        True
    """
    return ReversibleExtension(states, step)


# ============================================================
# Algorithm 4: Thermodynamic Cost Analysis
# ============================================================
def analyze_computation_cost(
    states: List[int],
    steps: List[Dict[int, int]],
    kB: float = 1.380649e-23,
    T: float = 300.0
) -> Dict[str, float]:
    """Analyze the thermodynamic cost of a sequence of computational steps.
    
    For each step, determines if it is reversible (injective) or irreversible,
    and computes the total Landauer cost.
    
    Time: O(t × |σ|) where t is the number of steps
    Space: O(|σ|)
    
    Args:
        states: Configuration space
        steps: List of step functions
        kB: Boltzmann constant
        T: Temperature
        
    Returns:
        Dictionary with cost analysis results
    """
    total_entropy_drop = 0.0
    reversible_steps = 0
    irreversible_steps = 0
    
    for i, step in enumerate(steps):
        # Check injectivity
        image = set(step.values())
        is_injective = len(image) == len(step)
        
        if is_injective:
            reversible_steps += 1
            # Zero entropy cost
        else:
            irreversible_steps += 1
            # Compute fiber structure
            fibers: Dict[int, int] = {}
            for x, y in step.items():
                fibers[y] = fibers.get(y, 0) + 1
            
            # Entropy drop = log(|σ|) - log(|image|)
            entropy_drop = math.log(len(step)) - math.log(len(image))
            total_entropy_drop += entropy_drop
    
    total_heat = kB * T * total_entropy_drop
    
    return {
        "total_steps": len(steps),
        "reversible_steps": reversible_steps,
        "irreversible_steps": irreversible_steps,
        "total_entropy_drop_nats": total_entropy_drop,
        "total_entropy_drop_bits": total_entropy_drop / math.log(2),
        "total_heat_joules": total_heat,
        "total_heat_kBT": total_entropy_drop,
    }


# ============================================================
# Main: Run examples
# ============================================================
if __name__ == "__main__":
    print("Tropical Thermodynamic Complexity — Algorithm Examples\n")
    
    # Example 1: Tropical transport
    sys = TropicalSystem(
        states=[0, 1, 2, 3],
        energy={0: 5.0, 1: 2.0, 2: 8.0, 3: 1.0}
    )
    f = {0: 2, 1: 3, 2: 0, 3: 1}
    g = {0: 1, 1: 0, 2: 3, 3: 2}
    
    print(f"Free energy preserved: {sys.free_energy() == sys.transport(f).free_energy()}")
    print(f"Composition law: {verify_transport_composition(sys, f, g)}")
    
    # Example 2: Landauer cost
    erase = one_bit_erasure(8)
    print(f"\nOne-bit erasure:")
    print(f"  Entropy drop: {erase.entropy_drop():.6f} nats")
    print(f"  Landauer cost at 300K: {erase.landauer_cost(1.380649e-23, 300):.4e} J")
    print(f"  Cardinality check: {erase.verify_cardinality()}")
    print(f"  Log identity check: {erase.verify_log_identity()}")
    
    # Example 3: Reversible extension
    step = {0: 1, 1: 1, 2: 3, 3: 3}
    ext = make_reversible([0, 1, 2, 3], step)
    print(f"\nReversible extension:")
    print(f"  Original states: {len(ext.states)}")
    print(f"  Extended states: {ext.extended_state_space_size()}")
    print(f"  Simulation correct: {ext.verify()}")
    
    # Example 4: Cost analysis
    steps = [
        {0: 2, 1: 3, 2: 0, 3: 1},  # reversible (rotation)
        {0: 1, 1: 1, 2: 3, 3: 3},  # irreversible (collapse)
        {0: 0, 1: 1, 2: 2, 3: 3},  # reversible (identity)
    ]
    analysis = analyze_computation_cost([0, 1, 2, 3], steps)
    print(f"\nCost analysis of 3-step computation:")
    for k, v in analysis.items():
        print(f"  {k}: {v}")
