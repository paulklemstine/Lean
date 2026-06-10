#!/usr/bin/env python3
"""
Algorithms for reversible computing and thermodynamic cost analysis.

Implements the mathematical constructions formalized in the Lean proofs:
- Shannon entropy computation
- Reversible lift construction (Bennett embedding)
- Fiber analysis and max fiber cardinality
- Landauer cost estimation
- Reversible circuit synthesis for common functions
"""

import math
from typing import (
    TypeVar, Generic, Dict, List, Tuple, Set, Callable, Optional, Any
)
from collections import Counter
from dataclasses import dataclass
from itertools import product

T = TypeVar('T')
S = TypeVar('S')


# ============================================================
# Core: Shannon Entropy
# ============================================================

def shannon_entropy(distribution: Dict[Any, float]) -> float:
    """
    Compute Shannon entropy H(p) = -∑ p(x) log p(x) in nats.

    Uses the convention 0 log 0 = 0 (automatic since lim x→0+ x ln x = 0).

    Args:
        distribution: mapping from outcomes to probabilities (must sum to 1)

    Returns:
        Shannon entropy in nats (natural log base)
    """
    return -sum(
        p * math.log(p) if p > 0 else 0.0
        for p in distribution.values()
    )


def shannon_entropy_bits(distribution: Dict[Any, float]) -> float:
    """Compute Shannon entropy in bits (log base 2)."""
    return shannon_entropy(distribution) / math.log(2)


def uniform_distribution(elements: List[Any]) -> Dict[Any, float]:
    """Create a uniform distribution over a list of elements."""
    n = len(elements)
    return {x: 1.0 / n for x in elements}


# ============================================================
# Core: Pushforward Distribution
# ============================================================

def pushforward_distribution(
    distribution: Dict[Any, float],
    f: Callable
) -> Dict[Any, float]:
    """
    Compute the pushforward distribution f_* p.

    For each output y, (f_* p)(y) = ∑_{x: f(x)=y} p(x).

    This implements the operation whose entropy decrease is
    bounded by our formal data processing inequality.

    Args:
        distribution: input probability distribution
        f: deterministic function

    Returns:
        pushforward distribution on the codomain of f
    """
    result: Dict[Any, float] = {}
    for x, px in distribution.items():
        y = f(x)
        result[y] = result.get(y, 0.0) + px
    return result


# ============================================================
# Core: Reversible Lift (Bennett Embedding)
# ============================================================

@dataclass
class ReversibleLift:
    """
    The reversible lift of a function f: α → β into (α × β, +).

    Maps (x, y) ↦ (x, y + f(x)) where + is the group operation on β.

    For ZMod 2 (binary), this is XOR: (x, y) ↦ (x, y ⊕ f(x)).

    Attributes:
        f: the original function to lift
        group_op: the group addition operation (default: XOR for binary)
        group_inv: the group inverse/subtraction (default: XOR for binary)
    """
    f: Callable
    group_op: Callable = lambda a, b: a ^ b  # XOR for binary
    group_inv: Callable = lambda a, b: a ^ b  # XOR is self-inverse

    def forward(self, x: Any, y: Any) -> Tuple[Any, Any]:
        """Apply the reversible lift: (x, y) ↦ (x, y + f(x))."""
        return (x, self.group_op(y, self.f(x)))

    def inverse(self, x: Any, y: Any) -> Tuple[Any, Any]:
        """Apply the inverse: (x, y) ↦ (x, y - f(x))."""
        return (x, self.group_inv(y, self.f(x)))

    def verify_bijective(self, domain_x: List[Any], domain_y: List[Any]) -> bool:
        """Verify bijectivity by checking that forward is a permutation."""
        inputs = [(x, y) for x in domain_x for y in domain_y]
        outputs = [self.forward(x, y) for x, y in inputs]
        return len(set(outputs)) == len(inputs)

    def verify_involutive(self, domain_x: List[Any], domain_y: List[Any]) -> bool:
        """Verify involution property: R(R(x,y)) = (x,y)."""
        for x in domain_x:
            for y in domain_y:
                x1, y1 = self.forward(x, y)
                x2, y2 = self.forward(x1, y1)
                if (x2, y2) != (x, y):
                    return False
        return True

    def realizes_f(self, x: Any, zero_y: Any) -> bool:
        """Check that R(x, 0).second = f(x)."""
        _, out_y = self.forward(x, zero_y)
        return out_y == self.f(x)


# ============================================================
# Core: Fiber Analysis
# ============================================================

def compute_fibers(
    f: Callable,
    domain: List[Any]
) -> Dict[Any, List[Any]]:
    """
    Compute the fiber decomposition of f.

    Returns a dict mapping each output y to the list of inputs
    x such that f(x) = y.
    """
    fibers: Dict[Any, List[Any]] = {}
    for x in domain:
        y = f(x)
        if y not in fibers:
            fibers[y] = []
        fibers[y].append(x)
    return fibers


def fiber_cardinalities(
    f: Callable,
    domain: List[Any]
) -> Dict[Any, int]:
    """Compute |f^{-1}(y)| for each y in the range."""
    return {y: len(xs) for y, xs in compute_fibers(f, domain).items()}


def max_fiber_card(f: Callable, domain: List[Any]) -> int:
    """
    Compute the maximum fiber cardinality M = max_y |f^{-1}(y)|.

    This is the key combinatorial quantity controlling the minimum
    erasure cost: at least ceil(log2(M)) bits must be erased.
    """
    cards = fiber_cardinalities(f, domain)
    return max(cards.values()) if cards else 0


def is_injective(f: Callable, domain: List[Any]) -> bool:
    """Check if f is injective on the given domain."""
    return max_fiber_card(f, domain) <= 1


# ============================================================
# Core: Landauer Cost
# ============================================================

@dataclass
class LandauerAnalysis:
    """Complete thermodynamic analysis of a computation."""
    function_name: str
    input_entropy_nats: float
    output_entropy_nats: float
    entropy_drop_nats: float
    entropy_drop_bits: float
    landauer_cost_joules: float
    max_fiber_size: int
    min_erasure_bits: float  # ceil(log2(max_fiber_size))
    is_injective: bool
    fiber_sizes: Dict[Any, int]

    def __str__(self) -> str:
        lines = [
            f"Landauer Analysis: {self.function_name}",
            f"  H(input)  = {self.input_entropy_nats:.4f} nats ({self.input_entropy_nats/math.log(2):.4f} bits)",
            f"  H(output) = {self.output_entropy_nats:.4f} nats ({self.output_entropy_nats/math.log(2):.4f} bits)",
            f"  ΔH = {self.entropy_drop_nats:.4f} nats ({self.entropy_drop_bits:.4f} bits)",
            f"  Landauer cost = {self.landauer_cost_joules:.4e} J (at 300K)",
            f"  Max fiber = {self.max_fiber_size}",
            f"  Min erasure = {self.min_erasure_bits:.2f} bits",
            f"  Injective = {self.is_injective}",
            f"  Fiber sizes = {self.fiber_sizes}",
        ]
        return "\n".join(lines)


def landauer_analysis(
    f: Callable,
    domain: List[Any],
    distribution: Optional[Dict[Any, float]] = None,
    name: str = "f",
    temperature: float = 300.0,
) -> LandauerAnalysis:
    """
    Perform a complete Landauer thermodynamic analysis of function f.

    Args:
        f: the function to analyze
        domain: the input domain
        distribution: input distribution (default: uniform)
        name: descriptive name for the function
        temperature: temperature in Kelvin (default: 300K room temp)

    Returns:
        LandauerAnalysis with all thermodynamic quantities
    """
    kB = 1.380649e-23  # J/K

    if distribution is None:
        distribution = uniform_distribution(domain)

    dist_out = pushforward_distribution(distribution, f)

    h_in = shannon_entropy(distribution)
    h_out = shannon_entropy(dist_out)
    delta_h = h_in - h_out

    fibers = fiber_cardinalities(f, domain)
    mfc = max(fibers.values()) if fibers else 0

    return LandauerAnalysis(
        function_name=name,
        input_entropy_nats=h_in,
        output_entropy_nats=h_out,
        entropy_drop_nats=delta_h,
        entropy_drop_bits=delta_h / math.log(2),
        landauer_cost_joules=kB * temperature * delta_h,
        max_fiber_size=mfc,
        min_erasure_bits=math.ceil(math.log2(mfc)) if mfc > 1 else 0,
        is_injective=(mfc <= 1),
        fiber_sizes=fibers,
    )


# ============================================================
# Reversible Circuit Synthesis
# ============================================================

def synthesize_reversible_circuit(
    f: Callable,
    input_domain: List[Any],
    output_domain: List[int],
) -> ReversibleLift:
    """
    Synthesize a reversible circuit for f using the Bennett embedding.

    The circuit maps (x, y) ↦ (x, y ⊕ f(x)) where ⊕ is XOR on bits.

    Args:
        f: function to implement
        input_domain: list of possible inputs
        output_domain: list of possible outputs (integers for XOR)

    Returns:
        ReversibleLift object implementing the reversible circuit
    """
    return ReversibleLift(f=f)


def parity_function(bits: Tuple[int, ...]) -> int:
    """Compute parity (XOR of all bits)."""
    return sum(bits) % 2


def linear_map_zmod2(matrix: List[List[int]], x: Tuple[int, ...]) -> Tuple[int, ...]:
    """Apply a linear map over ZMod 2 (GF(2))."""
    m = len(matrix)
    n = len(x)
    result = []
    for i in range(m):
        val = sum(matrix[i][j] * x[j] for j in range(n)) % 2
        result.append(val)
    return tuple(result)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Example: AND gate analysis
    domain = [(0, 0), (0, 1), (1, 0), (1, 1)]

    def and_gate(x):
        return x[0] & x[1]

    analysis = landauer_analysis(and_gate, domain, name="AND gate")
    print(analysis)

    print()

    # Example: Reversible lift of AND
    lift = ReversibleLift(f=and_gate)
    print(f"Reversible lift of AND:")
    print(f"  Bijective: {lift.verify_bijective(domain, [0, 1])}")
    print(f"  Involutive: {lift.verify_involutive(domain, [0, 1])}")
    for x in domain:
        print(f"  R({x}, 0) = {lift.forward(x, 0)}, realizes f({x})={and_gate(x)}: {lift.realizes_f(x, 0)}")

    print()

    # Example: Parity function analysis
    for n in range(2, 6):
        domain_n = list(product([0, 1], repeat=n))
        analysis = landauer_analysis(
            parity_function, domain_n, name=f"Parity({n} bits)"
        )
        print(f"\n{analysis}")
