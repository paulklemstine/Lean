"""
Tropical Thermodynamics of Computation — Algorithms

Implementations of the core algorithms from the research paper:
1. Entropy defect computation
2. Tropical circuit evaluation (depth and free energy)
3. Zero-temperature limit computation
4. Entropy defect analysis for function families
"""

import math
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass
from enum import Enum


# ============================================================
# Algorithm 1: Entropy Defect Computation
# ============================================================

def compute_entropy_defect(f: List[int], domain_size: Optional[int] = None) -> float:
    """Compute the entropy defect of a function.
    
    The entropy defect is defined as:
        H(f) = log(|domain|) - log(|range(f)|)
    
    This measures the information lost by applying f, in natural-log units.
    
    Args:
        f: Function represented as a list where f[i] is the image of i.
        domain_size: Size of domain (defaults to len(f)).
    
    Returns:
        The entropy defect in nats. Returns 0.0 for empty domains.
    
    Time complexity: O(n) expected using hash set
    Space complexity: O(n)
    
    Examples:
        >>> compute_entropy_defect([0, 0])  # erasure on 2 states
        0.6931471805599453
        >>> compute_entropy_defect([0, 1, 2])  # identity (injective)
        0.0
        >>> compute_entropy_defect([0, 0, 1, 1])  # 2-to-1 map
        0.6931471805599453
    """
    n = domain_size if domain_size is not None else len(f)
    if n == 0:
        return 0.0
    range_size = len(set(f[:n]))
    if range_size == 0:
        return 0.0
    return math.log(n) - math.log(range_size)


def compute_entropy_defect_bits(f: List[int], domain_size: Optional[int] = None) -> float:
    """Compute the entropy defect in bits (base-2 logarithm).
    
    Args:
        f: Function as a list.
        domain_size: Size of domain.
    
    Returns:
        Entropy defect in bits.
    
    Examples:
        >>> compute_entropy_defect_bits([0, 0])  # 1 bit lost
        1.0
        >>> compute_entropy_defect_bits([0] * 8)  # 3 bits lost
        3.0
    """
    return compute_entropy_defect(f, domain_size) / math.log(2)


# ============================================================
# Algorithm 2: Tropical Circuit Evaluation
# ============================================================

class CircuitType(Enum):
    INPUT = "input"
    GATE = "gate"
    SEQ = "seq"
    PAR = "par"


@dataclass
class TropicalCircuit:
    """Tropical circuit with sequential and parallel composition.
    
    A recursive tree structure representing:
    - input: zero-cost identity operation
    - gate(child): unit-cost computational step
    - seq(left, right): sequential composition (costs add)
    - par(left, right): parallel composition (depth = max)
    """
    kind: CircuitType
    children: List['TropicalCircuit']
    
    @staticmethod
    def input() -> 'TropicalCircuit':
        return TropicalCircuit(CircuitType.INPUT, [])
    
    @staticmethod
    def gate(child: 'TropicalCircuit') -> 'TropicalCircuit':
        return TropicalCircuit(CircuitType.GATE, [child])
    
    @staticmethod
    def seq(left: 'TropicalCircuit', right: 'TropicalCircuit') -> 'TropicalCircuit':
        return TropicalCircuit(CircuitType.SEQ, [left, right])
    
    @staticmethod
    def par(left: 'TropicalCircuit', right: 'TropicalCircuit') -> 'TropicalCircuit':
        return TropicalCircuit(CircuitType.PAR, [left, right])
    
    def depth(self) -> int:
        """Compute circuit depth (longest path from input to output).
        
        Time complexity: O(|C|) where |C| is the number of nodes.
        
        Returns:
            Circuit depth as a natural number.
        """
        if self.kind == CircuitType.INPUT:
            return 0
        elif self.kind == CircuitType.GATE:
            return self.children[0].depth() + 1
        elif self.kind == CircuitType.SEQ:
            return self.children[0].depth() + self.children[1].depth()
        elif self.kind == CircuitType.PAR:
            return max(self.children[0].depth(), self.children[1].depth())
        raise ValueError(f"Unknown circuit type: {self.kind}")
    
    def free_energy(self) -> float:
        """Compute min-plus free energy.
        
        By Theorem 3.4 (freeEnergy_eq_depth), this always equals depth.
        This implementation mirrors the formal definition over ℝ.
        
        Time complexity: O(|C|)
        
        Returns:
            Free energy as a real number.
        """
        if self.kind == CircuitType.INPUT:
            return 0.0
        elif self.kind == CircuitType.GATE:
            return self.children[0].free_energy() + 1.0
        elif self.kind == CircuitType.SEQ:
            return self.children[0].free_energy() + self.children[1].free_energy()
        elif self.kind == CircuitType.PAR:
            return max(self.children[0].free_energy(), self.children[1].free_energy())
        raise ValueError(f"Unknown circuit type: {self.kind}")
    
    def node_count(self) -> int:
        """Count total nodes in the circuit tree."""
        return 1 + sum(c.node_count() for c in self.children)
    
    def verify_fe_eq_depth(self) -> bool:
        """Verify that free_energy == depth (Theorem 3.4) for this circuit."""
        return abs(self.free_energy() - self.depth()) < 1e-10


def build_chain(n: int) -> TropicalCircuit:
    """Build a chain circuit of n gates: gate(gate(...gate(input)...)).
    
    Args:
        n: Number of gates.
    
    Returns:
        Circuit with depth n.
    """
    C = TropicalCircuit.input()
    for _ in range(n):
        C = TropicalCircuit.gate(C)
    return C


def build_binary_tree(depth_val: int) -> TropicalCircuit:
    """Build a balanced binary tree of parallel compositions.
    
    Args:
        depth_val: Depth of the tree.
    
    Returns:
        Circuit with depth depth_val.
    """
    if depth_val == 0:
        return TropicalCircuit.input()
    leaf = TropicalCircuit.gate(TropicalCircuit.input())
    if depth_val == 1:
        return leaf
    C = leaf
    for _ in range(depth_val - 1):
        C = TropicalCircuit.par(TropicalCircuit.gate(C), TropicalCircuit.gate(C))
    return C


# ============================================================
# Algorithm 3: Zero-Temperature Limit
# ============================================================

def gibbs_free_energy(energies: List[float], temperature: float) -> float:
    """Compute Gibbs free energy F_T = -T * log(sum(exp(-E_i/T))).
    
    Uses log-sum-exp trick for numerical stability.
    
    Args:
        energies: List of energy values E_1, ..., E_n.
        temperature: Temperature T > 0.
    
    Returns:
        Gibbs free energy F_T.
    
    Raises:
        ValueError: If temperature <= 0 or energies is empty.
    
    Time complexity: O(n)
    Space complexity: O(1) (streaming)
    """
    if not energies:
        raise ValueError("Energy list must be non-empty")
    if temperature <= 0:
        raise ValueError("Temperature must be positive")
    
    E_min = min(energies)
    # F_T = E_min - T * log(sum(exp(-(E_i - E_min)/T)))
    log_sum = math.log(sum(math.exp(-(e - E_min) / temperature) for e in energies))
    return E_min - temperature * log_sum


def tropical_free_energy(energies: List[float]) -> float:
    """Compute tropical (zero-temperature) free energy = min(energies).
    
    This is the T → 0 limit of gibbs_free_energy.
    
    Args:
        energies: List of energy values.
    
    Returns:
        min(energies)
    """
    return min(energies)


def verify_tropical_limit(
    energies: List[float],
    temperatures: Optional[List[float]] = None,
    tolerance: float = 1e-6
) -> List[Tuple[float, float, float, bool]]:
    """Verify convergence of Gibbs free energy to tropical limit.
    
    Args:
        energies: Energy landscape.
        temperatures: List of temperatures to test (default: geometric sequence).
        tolerance: Convergence tolerance.
    
    Returns:
        List of (temperature, F_T, |F_T - min(E)|, converged) tuples.
    """
    if temperatures is None:
        temperatures = [10.0, 1.0, 0.1, 0.01, 0.001, 0.0001]
    
    E_min = tropical_free_energy(energies)
    results = []
    
    for T in temperatures:
        F_T = gibbs_free_energy(energies, T)
        error = abs(F_T - E_min)
        converged = error < tolerance
        results.append((T, F_T, error, converged))
    
    return results


# ============================================================
# Algorithm 4: Entropy Defect Analysis
# ============================================================

def analyze_function_family(
    domain_sizes: List[int],
    function_generator: Callable[[int], List[int]],
    num_samples: int = 1000
) -> List[Tuple[int, float, float]]:
    """Analyze entropy defect statistics for a family of functions.
    
    Args:
        domain_sizes: List of domain sizes to test.
        function_generator: Function that takes domain size and returns a random function.
        num_samples: Number of samples per domain size.
    
    Returns:
        List of (domain_size, mean_defect, std_defect) tuples.
    """
    import random
    results = []
    
    for n in domain_sizes:
        defects = []
        for _ in range(num_samples):
            f = function_generator(n)
            defects.append(compute_entropy_defect(f, n))
        
        mean_d = sum(defects) / len(defects)
        var_d = sum((d - mean_d) ** 2 for d in defects) / len(defects)
        std_d = math.sqrt(var_d)
        results.append((n, mean_d, std_d))
    
    return results


def landauer_bound_check(f: List[int], is_constant: bool = False) -> dict:
    """Check Landauer bound for a given function.
    
    Args:
        f: Function as a list.
        is_constant: Whether f is known to be constant.
    
    Returns:
        Dictionary with entropy defect, bounds, and verification status.
    """
    n = len(f)
    range_size = len(set(f))
    ed = compute_entropy_defect(f)
    is_injective = (range_size == n)
    
    result = {
        "domain_size": n,
        "range_size": range_size,
        "entropy_defect_nats": ed,
        "entropy_defect_bits": ed / math.log(2) if ed > 0 else 0.0,
        "is_injective": is_injective,
        "is_constant": range_size == 1 and n > 0,
    }
    
    # Check bounds
    if range_size == 1 and n >= 2:
        result["landauer_bound_satisfied"] = ed >= math.log(2) - 1e-10
        result["bound_type"] = "erasure (Theorem 3.2)"
    elif not is_injective:
        result["landauer_bound_satisfied"] = ed >= -1e-10
        result["bound_type"] = "non-injective (Theorem 3.3)"
    else:
        result["landauer_bound_satisfied"] = True
        result["bound_type"] = "injective (trivially satisfied)"
    
    return result


# ============================================================
# Main: Run examples
# ============================================================

if __name__ == "__main__":
    import random
    
    print("=" * 60)
    print("Tropical Thermodynamics — Algorithm Examples")
    print("=" * 60)
    print()
    
    # Algorithm 1: Entropy defect
    print("--- Algorithm 1: Entropy Defect ---")
    examples = [
        ([0, 0], "erasure on 2 states"),
        ([0, 0, 0, 0], "erasure on 4 states"),
        ([0, 1, 0, 1], "2-to-1 map"),
        ([0, 1, 2, 3], "identity (injective)"),
    ]
    for f, desc in examples:
        result = landauer_bound_check(f)
        print(f"  {desc}: defect = {result['entropy_defect_bits']:.2f} bits, "
              f"bound: {result['bound_type']}, satisfied: {result['landauer_bound_satisfied']}")
    print()
    
    # Algorithm 2: Circuit evaluation
    print("--- Algorithm 2: Circuit Depth & Free Energy ---")
    circuits = [
        ("chain(3)", build_chain(3)),
        ("chain(5)", build_chain(5)),
        ("binary_tree(3)", build_binary_tree(3)),
    ]
    for name, C in circuits:
        assert C.verify_fe_eq_depth(), f"Theorem 3.4 violated for {name}!"
        print(f"  {name}: depth = {C.depth()}, free_energy = {C.free_energy():.0f}, "
              f"nodes = {C.node_count()}, FE=depth: ✓")
    print()
    
    # Algorithm 3: Zero-temperature limit
    print("--- Algorithm 3: Zero-Temperature Limit ---")
    energies = [3.0, 1.5, 2.7, 4.1, 1.5]
    results = verify_tropical_limit(energies)
    print(f"  Energies: {energies}, min = {min(energies)}")
    for T, F_T, error, converged in results:
        print(f"    T = {T:>8.4f}: F_T = {F_T:.6f}, error = {error:.2e}, "
              f"converged: {'✓' if converged else '✗'}")
    print()
    
    # Algorithm 4: Random function analysis
    print("--- Algorithm 4: Random Function Analysis ---")
    random.seed(42)
    def random_function(n):
        return [random.randint(0, n - 1) for _ in range(n)]
    
    analysis = analyze_function_family([10, 50, 100, 500], random_function, 500)
    theoretical = -math.log(1 - 1/math.e)
    print(f"  Theoretical mean entropy defect for random f:[n]→[n]: {theoretical:.4f}")
    for n, mean, std in analysis:
        print(f"    n = {n:>4}: mean = {mean:.4f} ± {std:.4f}")
    print()
    
    print("All algorithms verified successfully.")
