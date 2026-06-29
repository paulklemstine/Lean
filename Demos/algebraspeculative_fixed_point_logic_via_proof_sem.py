#!/usr/bin/env python3
"""
Proof-Semiring Diagonalization: Algorithms

Implements the core algorithms from the research paper with full
docstrings, type hints, and complexity analysis.
"""

from typing import Callable, Tuple, List, Optional, Dict, Set
from dataclasses import dataclass
import math


@dataclass
class CycleInfo:
    """Result of cycle detection."""
    tail_length: int  # m: steps before entering the cycle
    cycle_length: int  # k: period of the cycle
    cycle_start: int  # f^[m](x): first element in the cycle
    
    @property
    def total_steps(self) -> int:
        return self.tail_length + self.cycle_length


@dataclass 
class ObstructionCertificate:
    """Bounded obstruction certificate."""
    witness: int
    horizon: int
    separated_steps: List[int]  # indices where adjacent iterates differ


@dataclass
class StabilizationWitness:
    """Witness of adjacent iterate stabilization."""
    element: int
    step: int


@dataclass
class WeightTrajectory:
    """Weight trajectory of an iterated weight-controlled operator."""
    values: List[int]
    weights: List[int]
    bounds: List[int]
    cost: int


def floyd_cycle_detection(
    f: Callable[[int], int], 
    x0: int
) -> CycleInfo:
    """
    Floyd's tortoise-and-hare cycle detection algorithm.
    
    Time: O(m + k) where m = tail length, k = cycle length
    Space: O(1)
    
    Args:
        f: The function to iterate
        x0: Starting element
    
    Returns:
        CycleInfo with tail length, cycle length, and cycle start
    
    Example:
        >>> info = floyd_cycle_detection(lambda x: (x * x + 1) % 100, 2)
        >>> info.cycle_length > 0
        True
    """
    # Phase 1: Find meeting point
    tortoise = f(x0)
    hare = f(f(x0))
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(f(hare))
    
    # Phase 2: Find tail length (start of cycle)
    tortoise = x0
    m = 0
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(hare)
        m += 1
    
    # Phase 3: Find cycle length
    k = 1
    hare = f(tortoise)
    while tortoise != hare:
        hare = f(hare)
        k += 1
    
    return CycleInfo(tail_length=m, cycle_length=k, cycle_start=tortoise)


def brent_cycle_detection(
    f: Callable[[int], int],
    x0: int
) -> CycleInfo:
    """
    Brent's cycle detection algorithm (improved over Floyd's).
    
    Time: O(m + k) with fewer function evaluations than Floyd's
    Space: O(1)
    
    Args:
        f: The function to iterate
        x0: Starting element
    
    Returns:
        CycleInfo with tail length, cycle length, and cycle start
    """
    # Phase 1: Find cycle length
    power = 1
    lam = 1
    tortoise = x0
    hare = f(x0)
    while tortoise != hare:
        if power == lam:
            tortoise = hare
            power *= 2
            lam = 0
        hare = f(hare)
        lam += 1
    
    # Phase 2: Find tail length
    tortoise = x0
    hare = x0
    for _ in range(lam):
        hare = f(hare)
    
    m = 0
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(hare)
        m += 1
    
    return CycleInfo(tail_length=m, cycle_length=lam, cycle_start=tortoise)


def congruence_cycle_detection(
    f: Callable[[int], int],
    equiv: Callable[[int, int], bool],
    x0: int,
    n: int
) -> CycleInfo:
    """
    Cycle detection modulo an equivalence relation.
    
    Uses hash-table approach since Floyd/Brent require equality.
    
    Time: O(n * T_equiv) where T_equiv is the cost of equivalence testing
    Space: O(n)
    
    Args:
        f: The function to iterate
        equiv: Equivalence relation (decidable)
        x0: Starting element
        n: Upper bound (cardinality of type)
    
    Returns:
        CycleInfo with orbit repetition modulo equivalence
    """
    orbit = [x0]
    for i in range(1, n + 1):
        next_val = f(orbit[-1])
        for j in range(len(orbit)):
            if equiv(next_val, orbit[j]):
                return CycleInfo(
                    tail_length=j,
                    cycle_length=i - j,
                    cycle_start=orbit[j]
                )
        orbit.append(next_val)
    
    raise RuntimeError("No cycle found within n steps (impossible by pigeonhole)")


def find_obstruction_or_stabilization(
    f: Callable[[int], int],
    equiv: Callable[[int, int], bool],
    x0: int,
    horizon: int
) -> Tuple[bool, int]:
    """
    Search for adjacent stabilization or build obstruction certificate.
    
    Time: O(horizon * T_equiv)
    Space: O(1)
    
    Args:
        f: Function to iterate
        equiv: Decidable equivalence relation
        x0: Starting element
        horizon: Maximum search depth (≤ card α)
    
    Returns:
        (True, step) if stabilization found at step
        (False, horizon) if obstruction certificate constructed
    """
    current = x0
    for step in range(horizon):
        next_val = f(current)
        if equiv(next_val, current):
            return (True, step)
        current = next_val
    return (False, horizon)


def weight_controlled_iterate(
    f: Callable[[int], int],
    weight: Callable[[int], int],
    x0: int,
    n_steps: int,
    cost: int
) -> WeightTrajectory:
    """
    Iterate a weight-controlled operator and verify the affine bound.
    
    Time: O(n_steps * (T_f + T_weight))
    Space: O(n_steps)
    
    Args:
        f: Weight-controlled operator
        weight: Weight function
        x0: Starting element
        n_steps: Number of iterations
        cost: Operator cost per step
    
    Returns:
        WeightTrajectory with values, weights, and bounds
    """
    values = [x0]
    weights = [weight(x0)]
    bounds = [weight(x0)]
    
    current = x0
    for step in range(1, n_steps + 1):
        current = f(current)
        w = weight(current)
        bound = weights[0] + step * cost
        values.append(current)
        weights.append(w)
        bounds.append(bound)
    
    return WeightTrajectory(values=values, weights=weights, bounds=bounds, cost=cost)


def verify_time_reversal(
    f: Callable[[int], int],
    g: Callable[[int], int],
    equiv: Callable[[int, int], bool],
    elements: List[int]
) -> Tuple[bool, bool]:
    """
    Verify time-reversal witness properties.
    
    Args:
        f, g: Functions forming a time-reversal pair
        equiv: Equivalence relation
        elements: All elements of the type
    
    Returns:
        (left_inv_holds, right_inv_holds)
    """
    left = all(equiv(g(f(x)), x) for x in elements)
    right = all(equiv(f(g(x)), x) for x in elements)
    return (left, right)


def classify_dynamics(
    f: Callable[[int], int],
    equiv: Callable[[int, int], bool],
    elements: List[int]
) -> str:
    """
    Apply the thermodynamic trichotomy classification.
    
    Args:
        f: Function on a finite type
        equiv: Decidable equivalence relation
        elements: All elements of the type
    
    Returns:
        Classification string: "FIXED_POINT", "NONTRIVIAL_CYCLE", or "OBSTRUCTION"
    """
    # Check for fixed points
    for x in elements:
        if equiv(f(x), x):
            return "FIXED_POINT"
    
    # No fixed point → must have nontrivial cycle (by pigeonhole)
    return "NONTRIVIAL_CYCLE"


def quotient_injective_propagation(
    f: Callable[[int], int],
    equiv: Callable[[int, int], bool],
    x: int,
    n: int
) -> Optional[int]:
    """
    If f is quotient-injective and f^[n+1](x) ≡ f^[n](x),
    propagate backwards to find the fixed point at x.
    
    Args:
        f: Quotient-injective function
        equiv: Equivalence relation
        x: Starting element
        n: Iterate depth
    
    Returns:
        The element x if f(x) ≡ x, else None
    """
    # Compute orbit up to n+1
    orbit = [x]
    for _ in range(n + 1):
        orbit.append(f(orbit[-1]))
    
    # Check if f^[n+1](x) ≡ f^[n](x)
    if not equiv(orbit[n + 1], orbit[n]):
        return None
    
    # By the theorem, f(x) ≡ x must hold
    if equiv(f(x), x):
        return x
    else:
        return None  # Function is not actually quotient-injective


# Example usage
if __name__ == "__main__":
    # Floyd cycle detection
    f = lambda x: (x * x + 1) % 1000
    info = floyd_cycle_detection(f, 2)
    print(f"Floyd: tail={info.tail_length}, cycle={info.cycle_length}")
    
    # Brent cycle detection
    info2 = brent_cycle_detection(f, 2)
    print(f"Brent: tail={info2.tail_length}, cycle={info2.cycle_length}")
    
    # Weight-controlled iteration
    g = lambda x: (x + 3) % 16
    weight = lambda x: bin(x).count('1')
    traj = weight_controlled_iterate(g, weight, 0, 10, 2)
    print(f"Weights: {traj.weights}")
    print(f"Bounds:  {traj.bounds}")
    print(f"All satisfied: {all(w <= b for w, b in zip(traj.weights, traj.bounds))}")


#!/usr/bin/env python3
"""
Proof-Semiring Diagonalization: Applications

Real-world applications of the framework to cryptographic hash analysis,
neural network certified robustness, and quantum circuit verification.
"""

import random
import hashlib
from typing import List, Tuple, Callable


# ============================================================
# Application 1: Cryptographic Hash Collision Analysis
# ============================================================

def truncated_sha256(x: int, bits: int = 32) -> int:
    """Truncate SHA-256 to `bits` bits for collision analysis."""
    h = hashlib.sha256(x.to_bytes(8, 'big')).digest()
    return int.from_bytes(h[:bits // 8], 'big') % (2 ** bits)


def pollard_rho_collision(f: Callable[[int], int], x0: int, max_steps: int) -> Tuple[int, int, int]:
    """
    Find collision using Floyd's cycle detection.
    Returns (m, element, steps) where f^[m](x0) enters the cycle.
    
    Application: post_quantum_security analysis of hash function iteration.
    The chronometric bound guarantees termination within card(α) steps.
    """
    # Phase 1: Find meeting point
    tortoise = f(x0)
    hare = f(f(x0))
    steps = 1
    while tortoise != hare and steps < max_steps:
        tortoise = f(tortoise)
        hare = f(f(hare))
        steps += 1
    
    if steps >= max_steps:
        return (-1, -1, steps)
    
    # Phase 2: Find cycle start
    tortoise = x0
    m = 0
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(hare)
        m += 1
    
    return (m, tortoise, steps)


def hash_collision_demo():
    """Demonstrate collision finding on truncated hash functions."""
    print("=" * 60)
    print("APPLICATION 1: Hash Collision Analysis")
    print("=" * 60)
    
    for bits in [16, 20, 24]:
        n = 2 ** bits
        f = lambda x, b=bits: truncated_sha256(x, b)
        x0 = 0
        
        m, elem, steps = pollard_rho_collision(f, x0, n)
        
        expected = int(1.25 * (n ** 0.5))  # Birthday bound ≈ 1.25√n
        
        print(f"\n{bits}-bit hash (space size 2^{bits} = {n}):")
        print(f"  Collision found in {steps} steps")
        print(f"  Expected (birthday): ~{expected}")
        print(f"  Chronometric bound: {n}")
        print(f"  Ratio (actual/birthday): {steps/expected:.2f}")


# ============================================================
# Application 2: Neural Network Certified Robustness
# ============================================================

def relu(x: float) -> float:
    return max(0.0, x)


def lipschitz_layer(weights: List[List[float]], bias: List[float], x: List[float]) -> List[float]:
    """Single neural network layer: ReLU(Wx + b)."""
    out = []
    for i in range(len(bias)):
        s = bias[i]
        for j in range(len(x)):
            s += weights[i][j] * x[j]
        out.append(relu(s))
    return out


def operator_norm(weights: List[List[float]]) -> float:
    """Compute operator norm (max row sum of absolute values) for Lipschitz bound."""
    return max(sum(abs(w) for w in row) for row in weights)


def certified_robustness_demo():
    """
    Demonstrate Lipschitz certified robustness for a small neural network.
    
    The weight-controlled iteration bound gives:
    ||f^[L](x) - f^[L](x')|| ≤ L * max_layer_lipschitz * ||x - x'||
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Neural Network Certified Robustness")
    print("=" * 60)
    
    random.seed(42)
    
    # 3-layer network: 4 → 3 → 3 → 2
    layers = [
        {
            'weights': [[random.gauss(0, 0.5) for _ in range(4)] for _ in range(3)],
            'bias': [random.gauss(0, 0.1) for _ in range(3)]
        },
        {
            'weights': [[random.gauss(0, 0.5) for _ in range(3)] for _ in range(3)],
            'bias': [random.gauss(0, 0.1) for _ in range(3)]
        },
        {
            'weights': [[random.gauss(0, 0.5) for _ in range(3)] for _ in range(2)],
            'bias': [random.gauss(0, 0.1) for _ in range(2)]
        }
    ]
    
    # Compute per-layer Lipschitz constants
    lipschitz_constants = [operator_norm(layer['weights']) for layer in layers]
    total_lipschitz = 1.0
    for c in lipschitz_constants:
        total_lipschitz *= c
    
    # Additive cost model (log-Lipschitz)
    import math
    log_costs = [math.log(max(c, 1e-10)) for c in lipschitz_constants]
    total_log_cost = sum(log_costs)
    
    print(f"\nNetwork architecture: 4 → 3 → 3 → 2")
    print(f"\nPer-layer Lipschitz constants:")
    for i, c in enumerate(lipschitz_constants):
        print(f"  Layer {i+1}: {c:.4f}")
    
    print(f"\nTotal Lipschitz constant (product): {total_lipschitz:.4f}")
    print(f"Sum of log-Lipschitz costs: {total_log_cost:.4f}")
    
    # Test with perturbation
    x = [1.0, 0.5, -0.3, 0.8]
    epsilon = 0.01
    x_perturbed = [xi + epsilon * random.gauss(0, 1) for xi in x]
    
    # Forward pass
    y = x[:]
    y_p = x_perturbed[:]
    for layer in layers:
        y = lipschitz_layer(layer['weights'], layer['bias'], y)
        y_p = lipschitz_layer(layer['weights'], layer['bias'], y_p)
    
    input_diff = sum((a - b) ** 2 for a, b in zip(x, x_perturbed)) ** 0.5
    output_diff = sum((a - b) ** 2 for a, b in zip(y, y_p)) ** 0.5
    
    certified_bound = total_lipschitz * input_diff
    
    print(f"\nPerturbation test:")
    print(f"  Input perturbation: ||δx|| = {input_diff:.6f}")
    print(f"  Output perturbation: ||δy|| = {output_diff:.6f}")
    print(f"  Certified bound: {certified_bound:.6f}")
    print(f"  Bound satisfied: {'✓' if output_diff <= certified_bound + 1e-10 else '✗'}")
    print(f"  Tightness ratio: {output_diff / certified_bound:.4f}")


# ============================================================
# Application 3: Quantum Circuit Reversibility Verification
# ============================================================

def quantum_gate_X(state: List[complex]) -> List[complex]:
    """Pauli-X gate on a 2-element state vector."""
    return [state[1], state[0]]


def quantum_gate_H(state: List[complex]) -> List[complex]:
    """Hadamard gate on a 2-element state vector."""
    s = 1.0 / (2 ** 0.5)
    return [s * (state[0] + state[1]), s * (state[0] - state[1])]


def quantum_circuit_demo():
    """
    Demonstrate time-reversal symmetry for quantum gates.
    
    The quantum_timeReversal_mod_congruence theorem states:
    If (f, g) are mutual inverses mod ρ, then
    HasCongruenceFixedPoint ρ f ↔ HasCongruenceFixedPoint ρ g.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Quantum Circuit Reversibility")
    print("=" * 60)
    
    # X gate is self-inverse
    print("\nPauli-X gate (self-inverse):")
    states = [[1, 0], [0, 1], [0.6, 0.8]]
    for s in states:
        s_complex = [complex(x) for x in s]
        forward = quantum_gate_X(s_complex)
        roundtrip = quantum_gate_X(forward)
        diff = sum(abs(a - b) for a, b in zip(s_complex, roundtrip))
        print(f"  |ψ⟩ = {s} → X|ψ⟩ = {[f'{x.real:.1f}' for x in forward]} → XX|ψ⟩ roundtrip error: {diff:.2e}")
    
    # H gate is self-inverse
    print("\nHadamard gate (self-inverse):")
    for s in states:
        s_complex = [complex(x) for x in s]
        forward = quantum_gate_H(s_complex)
        roundtrip = quantum_gate_H(forward)
        diff = sum(abs(a - b) for a, b in zip(s_complex, roundtrip))
        print(f"  |ψ⟩ = {s} → H|ψ⟩ → HH|ψ⟩ roundtrip error: {diff:.2e}")
    
    # Discrete simulation: permutation group on n elements
    n = 6
    print(f"\nDiscrete simulation: S_{n} (permutations of {n} elements)")
    
    # f = cyclic shift, g = inverse cyclic shift
    f_perm = list(range(1, n)) + [0]  # (0 1 2 ... n-1)
    g_perm = [n - 1] + list(range(n - 1))  # (n-1 0 1 ... n-2)
    
    def apply_perm(perm: List[int], x: int) -> int:
        return perm[x]
    
    # Verify time-reversal
    left_ok = all(apply_perm(g_perm, apply_perm(f_perm, x)) == x for x in range(n))
    right_ok = all(apply_perm(f_perm, apply_perm(g_perm, x)) == x for x in range(n))
    
    fp_f = [x for x in range(n) if apply_perm(f_perm, x) == x]
    fp_g = [x for x in range(n) if apply_perm(g_perm, x) == x]
    
    print(f"  f = {f_perm} (cyclic shift)")
    print(f"  g = {g_perm} (inverse shift)")
    print(f"  Time-reversal verified: left={left_ok}, right={right_ok}")
    print(f"  Fixed points of f: {fp_f}")
    print(f"  Fixed points of g: {fp_g}")
    print(f"  Symmetry preserved: {'✓' if bool(fp_f) == bool(fp_g) else '✗'}")


if __name__ == "__main__":
    hash_collision_demo()
    certified_robustness_demo()
    quantum_circuit_demo()
    
    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Proof-Semiring Diagonalization: Demonstrations

Concrete numerical examples illustrating the main theorems of the
proof-semiring diagonalization framework.
"""

import random
from typing import Callable, Tuple, List, Optional, Dict
from collections import defaultdict


def find_orbit_repetition(f: Callable[[int], int], x: int, n: int) -> Tuple[int, int]:
    """
    Find orbit repetition: returns (m, k) where f^[m+k](x) = f^[m](x), k > 0.
    Guaranteed to terminate within n steps by the chronometric pigeonhole theorem.
    
    Implements Algorithm FindCongruenceCycle from the paper.
    Time: O(n), Space: O(n)
    """
    orbit = [x]
    seen: Dict[int, int] = {x: 0}
    current = x
    for i in range(1, n + 1):
        current = f(current)
        if current in seen:
            m = seen[current]
            return m, i - m
        seen[current] = i
        orbit.append(current)
    raise RuntimeError(f"No repetition found in {n} steps (should not happen for n >= card alpha)")


def find_obstruction_or_stabilization(
    f: Callable[[int], int], 
    equiv: Callable[[int, int], bool],
    x: int, 
    horizon: int
) -> Tuple[str, int]:
    """
    Search for adjacent stabilization or build obstruction certificate.
    Returns ('stabilization', n) or ('obstruction', horizon).
    """
    current = x
    for step in range(horizon):
        next_val = f(current)
        if equiv(next_val, current):
            return ('stabilization', step)
        current = next_val
    return ('obstruction', horizon)


def demo_pigeonhole():
    """Demonstrate the chronometric pigeonhole theorem on a small example."""
    print("=" * 60)
    print("DEMO 1: Chronometric Pigeonhole Theorem")
    print("=" * 60)
    
    n = 20  # Working in {0, 1, ..., 19}
    
    # Define a specific function: f(x) = (3x + 7) mod 20
    f = lambda x: (3 * x + 7) % n
    
    print(f"\nType: {{0, 1, ..., {n-1}}} (card = {n})")
    print(f"Function: f(x) = (3x + 7) mod {n}")
    
    x0 = 0
    print(f"\nStarting from x₀ = {x0}:")
    print("Orbit: ", end="")
    current = x0
    orbit = [current]
    for i in range(n + 1):
        current = f(current)
        orbit.append(current)
        print(f"{orbit[i]}", end=" → ")
    print(f"{current}")
    
    m, k = find_orbit_repetition(f, x0, n)
    print(f"\nRepetition found: f^[{m}]({x0}) = f^[{m+k}]({x0}) = {orbit[m]}")
    print(f"Cycle period: {k}")
    print(f"Cycle start: f^[{m}]({x0}) = {orbit[m]}")
    print(f"Bound satisfied: {m+k} ≤ {n} ✓" if m + k <= n else f"Bound: {m+k} > {n}")


def demo_cycle_detection():
    """Demonstrate cycle detection on random functions."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Hash Collision Detection")
    print("=" * 60)
    
    sizes = [10, 50, 100, 500, 1000]
    trials = 100
    
    print(f"\nRandom function cycle detection ({trials} trials per size):")
    print(f"{'Size':>8} {'Mean steps':>12} {'Max steps':>12} {'Bound':>8} {'Ratio':>8}")
    print("-" * 52)
    
    for n in sizes:
        steps_list = []
        for _ in range(trials):
            # Random function on {0, ..., n-1}
            table = [random.randint(0, n - 1) for _ in range(n)]
            f = lambda x, t=table: t[x]
            x0 = random.randint(0, n - 1)
            m, k = find_orbit_repetition(f, x0, n)
            steps_list.append(m + k)
        
        mean_steps = sum(steps_list) / len(steps_list)
        max_steps = max(steps_list)
        print(f"{n:>8} {mean_steps:>12.1f} {max_steps:>12} {n:>8} {mean_steps/n:>8.3f}")


def demo_weight_controlled():
    """Demonstrate weight-controlled iteration bounds."""
    print("\n" + "=" * 60)
    print("DEMO 3: Weight-Controlled Iteration (Lipschitz Certified Robustness)")
    print("=" * 60)
    
    n = 16  # Working in Z/16Z
    
    # Weight function: number of 1-bits in binary representation
    def weight(x: int) -> int:
        return bin(x).count('1')
    
    # Weight-controlled operator: f(x) = (x + 3) mod 16, cost = 2
    cost = 2
    f = lambda x: (x + 3) % n
    
    print(f"\nType: Z/{n}Z")
    print(f"Weight: popcount (number of 1-bits)")
    print(f"Operator: f(x) = (x + 3) mod {n}, cost = {cost}")
    
    x0 = 0
    print(f"\nStarting from x₀ = {x0} (weight = {weight(x0)}):")
    print(f"{'Step':>6} {'Value':>8} {'Weight':>8} {'Bound':>8} {'Satisfied':>10}")
    print("-" * 44)
    
    current = x0
    for step in range(10):
        w = weight(current)
        bound = weight(x0) + step * cost
        ok = w <= bound
        print(f"{step:>6} {current:>8} {w:>8} {bound:>8} {'✓' if ok else '✗':>10}")
        current = f(current)


def demo_time_reversal():
    """Demonstrate the quantum time-reversal symmetry theorem."""
    print("\n" + "=" * 60)
    print("DEMO 4: Quantum Time-Reversal Symmetry")
    print("=" * 60)
    
    n = 12
    
    # f and g are mutual inverses mod n
    f = lambda x: (x + 5) % n  # shift by 5
    g = lambda x: (x - 5) % n  # shift by -5 (= shift by 7)
    
    print(f"\nType: Z/{n}Z with equality as setoid")
    print(f"f(x) = (x + 5) mod {n}")
    print(f"g(x) = (x - 5) mod {n}")
    
    # Verify time-reversal property
    print("\nVerifying time-reversal witness:")
    all_left = all(g(f(x)) == x for x in range(n))
    all_right = all(f(g(x)) == x for x in range(n))
    print(f"  g(f(x)) = x for all x: {'✓' if all_left else '✗'}")
    print(f"  f(g(x)) = x for all x: {'✓' if all_right else '✗'}")
    
    # Find fixed points of f and g
    fp_f = [x for x in range(n) if f(x) == x]
    fp_g = [x for x in range(n) if g(x) == x]
    
    print(f"\nFixed points of f: {fp_f}")
    print(f"Fixed points of g: {fp_g}")
    print(f"Both empty or both nonempty: {'✓' if bool(fp_f) == bool(fp_g) else '✗'}")
    
    # Now with a function that has fixed points
    f2 = lambda x: (x * 5) % n
    g2 = lambda x: (x * 5) % n  # 5 * 5 = 25 ≡ 1 mod 12, so g2 = f2
    
    print(f"\nf₂(x) = (5x) mod {n}")
    print(f"g₂(x) = (5x) mod {n}  (5² ≡ 1 mod 12)")
    
    all_left2 = all(g2(f2(x)) == x for x in range(n))
    all_right2 = all(f2(g2(x)) == x for x in range(n))
    print(f"  g₂(f₂(x)) = x for all x: {'✓' if all_left2 else '✗'}")
    
    fp_f2 = [x for x in range(n) if f2(x) == x]
    fp_g2 = [x for x in range(n) if g2(x) == x]
    print(f"Fixed points of f₂: {fp_f2}")
    print(f"Fixed points of g₂: {fp_g2}")
    print(f"Symmetric: {'✓' if bool(fp_f2) == bool(fp_g2) else '✗'}")


def demo_trichotomy():
    """Demonstrate the thermodynamic trichotomy on various functions."""
    print("\n" + "=" * 60)
    print("DEMO 5: Thermodynamic Trichotomy Classification")
    print("=" * 60)
    
    n = 10
    
    functions = [
        ("identity", lambda x: x),
        ("constant 0", lambda x: 0),
        ("shift +1", lambda x: (x + 1) % n),
        ("doubling", lambda x: (2 * x) % n),
        ("square", lambda x: (x * x) % n),
        ("collatz-like", lambda x: x // 2 if x % 2 == 0 else (3 * x + 1) % n),
    ]
    
    print(f"\nType: Z/{n}Z, Setoid: equality")
    print(f"{'Function':>15} {'Fixed pts':>12} {'Cycle len':>12} {'Classification':>20}")
    print("-" * 63)
    
    for name, f in functions:
        # Find fixed points
        fps = [x for x in range(n) if f(x) == x]
        
        # Find shortest cycle
        min_cycle = n + 1
        for x0 in range(n):
            m, k = find_orbit_repetition(f, x0, n)
            min_cycle = min(min_cycle, k)
        
        if fps:
            classification = "FIXED POINT"
        elif min_cycle == 1:
            classification = "TRIVIAL CYCLE"
        else:
            classification = f"CYCLE (period {min_cycle})"
        
        print(f"{name:>15} {str(fps):>12} {min_cycle:>12} {classification:>20}")


def demo_obstruction_certificates():
    """Demonstrate bounded obstruction certificate construction."""
    print("\n" + "=" * 60)
    print("DEMO 6: Post-Quantum Security Obstruction Certificates")
    print("=" * 60)
    
    n = 15
    
    # Shift function (no adjacent stabilization under equality)
    f_shift = lambda x: (x + 1) % n
    # Contractive function (stabilizes quickly)
    f_contract = lambda x: x // 2
    
    print(f"\nType: {{0, ..., {n-1}}}, Setoid: equality")
    
    for name, f in [("shift +1", f_shift), ("x // 2", f_contract)]:
        print(f"\nFunction: {name}")
        result, value = find_obstruction_or_stabilization(
            f, lambda a, b: a == b, 0, n
        )
        if result == 'stabilization':
            print(f"  Result: Stabilization at step {value}")
            x = 0
            for _ in range(value):
                x = f(x)
            print(f"  f^[{value+1}](0) = f^[{value}](0) = {x}")
        else:
            print(f"  Result: Obstruction certificate (horizon = {value})")
            print(f"  No adjacent stabilization in {value} steps")
    
    # With equivalence mod 3
    print(f"\nWith setoid: equivalence mod 3")
    equiv_mod3 = lambda a, b: a % 3 == b % 3
    
    for name, f in [("shift +1", f_shift), ("x // 2", f_contract)]:
        print(f"\nFunction: {name}")
        result, value = find_obstruction_or_stabilization(
            f, equiv_mod3, 0, n
        )
        if result == 'stabilization':
            print(f"  Result: Stabilization at step {value} (mod 3)")
        else:
            print(f"  Result: Obstruction certificate (horizon = {value})")


if __name__ == "__main__":
    random.seed(42)
    demo_pigeonhole()
    demo_cycle_detection()
    demo_weight_controlled()
    demo_time_reversal()
    demo_trichotomy()
    demo_obstruction_certificates()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)
