#!/usr/bin/env python3
"""
Algorithms for Compositional Invariant Transfer

Implements the core algorithms from the research paper:
1. Finite product construction
2. Subadditive bound computation
3. Security composition analysis
4. Termination verification
"""

from typing import List, Callable, Optional, Tuple, Dict
from dataclasses import dataclass
import math


# ============================================================
# Algorithm 1: Finite Product Construction
# ============================================================

@dataclass
class InvariantSystem:
    """
    An invariant-bearing transition system.

    Attributes:
        name: Human-readable identifier
        states: List of states
        step: Transition function (s, t) -> bool
        inv: Invariant function s -> float (non-increasing under step)
    """
    name: str
    states: list
    step: Callable  # (state, state) -> bool
    inv: Callable   # state -> float


def finite_product(systems: List[InvariantSystem]) -> dict:
    """
    Construct the finite product of invariant systems.

    Algorithm:
    1. State space = Cartesian product of component state spaces
    2. Step relation = coordinatewise conjunction
    3. Invariant = sum of component invariants

    Time complexity: O(∏ |Sᵢ|) for state enumeration
    Space complexity: O(∏ |Sᵢ|)

    Args:
        systems: List of component systems

    Returns:
        Dictionary with 'states', 'step', 'inv', and 'projections'
    """
    n = len(systems)
    if n == 0:
        return {'states': [()], 'step': lambda s, t: True,
                'inv': lambda s: 0.0, 'projections': []}

    # Build product states via iterative Cartesian product
    product_states = [[s] for s in systems[0].states]
    for i in range(1, n):
        new_states = []
        for prefix in product_states:
            for s in systems[i].states:
                new_states.append(prefix + [s])
        product_states = new_states

    product_states = [tuple(s) for s in product_states]

    def product_step(s: tuple, t: tuple) -> bool:
        return all(systems[i].step(s[i], t[i]) for i in range(n))

    def product_inv(s: tuple) -> float:
        return sum(systems[i].inv(s[i]) for i in range(n))

    projections = [lambda s, i=i: s[i] for i in range(n)]

    return {
        'states': product_states,
        'step': product_step,
        'inv': product_inv,
        'projections': projections
    }


def lift(systems: List[InvariantSystem],
         morphisms: List[Callable]) -> Callable:
    """
    Universal lift into the finite product.

    Given morphisms fᵢ : Z → Xᵢ, produce the unique mediating
    morphism ⟨fᵢ⟩ : Z → ∏ Xᵢ.

    Algorithm: ⟨fᵢ⟩(z) = (f₀(z), f₁(z), ..., fₙ₋₁(z))

    Time complexity: O(n) per application
    Space complexity: O(n) per output tuple

    Args:
        systems: Component systems (for type reference)
        morphisms: List of morphisms fᵢ : Z → Xᵢ

    Returns:
        The mediating morphism z ↦ (f₀(z), ..., fₙ₋₁(z))
    """
    def lifted(z):
        return tuple(f(z) for f in morphisms)
    return lifted


# ============================================================
# Algorithm 2: Subadditive Bound Computation
# ============================================================

def subadditive_bound(phi_values: List[float],
                      binary_phi: Optional[Callable] = None) -> Dict:
    """
    Compute the subadditive bound Φ(∏ Xᵢ) ≤ Σ Φ(Xᵢ).

    Algorithm (mirrors the inductive proof):
    1. Base case n=1: bound = Φ(X₀)
    2. Inductive step: bound(n+1) = Φ(X₀) + bound(n) for X₁,...,Xₙ

    If binary_phi is provided, also compute the actual product value
    by iteratively applying the binary product formula.

    Time complexity: O(n)
    Space complexity: O(n) for the trace

    Args:
        phi_values: List of Φ(Xᵢ) values
        binary_phi: Optional function (Φ(A), Φ(B)) -> Φ(A×B)

    Returns:
        Dict with 'bound', 'actual' (if binary_phi given), 'trace'
    """
    n = len(phi_values)
    if n == 0:
        return {'bound': 0.0, 'actual': None, 'trace': []}

    trace = []
    bound = phi_values[0]
    actual = phi_values[0] if binary_phi else None

    trace.append({
        'step': 0,
        'component': phi_values[0],
        'bound': bound,
        'actual': actual
    })

    for k in range(1, n):
        bound += phi_values[k]
        if binary_phi is not None:
            actual = binary_phi(actual, phi_values[k])
        trace.append({
            'step': k,
            'component': phi_values[k],
            'bound': bound,
            'actual': actual
        })

    return {
        'bound': bound,
        'actual': actual,
        'trace': trace,
        'gap': (bound - actual) if actual is not None else None
    }


# ============================================================
# Algorithm 3: Security Composition
# ============================================================

def security_composition(security_levels: List[float]) -> Dict:
    """
    Compute security bounds for composed systems.

    Implements three composition modes:
    1. Min-bound (weakest link): sec ≥ min_i sec(Xᵢ)
    2. Additive (independent entropy): sec = Σ sec(Xᵢ)
    3. Hybrid: different bounds for different threat models

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        security_levels: List of component security levels

    Returns:
        Dict with various composition bounds
    """
    n = len(security_levels)
    if n == 0:
        return {'min_bound': float('inf'), 'additive': 0.0}

    min_sec = min(security_levels)
    sum_sec = sum(security_levels)
    max_sec = max(security_levels)
    avg_sec = sum_sec / n

    # Weakest-link attacker: breaks the weakest component
    # Independent entropy: security adds up
    # Strongest-first attacker: targets strongest (unrealistic but informative)

    return {
        'n_components': n,
        'min_bound': min_sec,
        'additive_bound': sum_sec,
        'max_component': max_sec,
        'avg_component': avg_sec,
        'weakest_index': security_levels.index(min_sec),
        'composition_loss': avg_sec - min_sec,
        'bits_equivalent': {
            'weakest_link': min_sec,
            'independent': sum_sec,
            'geometric_mean': math.exp(sum(math.log(s) for s in security_levels) / n)
        }
    }


# ============================================================
# Algorithm 4: Termination Verification
# ============================================================

def verify_well_founded(states: list, step: Callable) -> Tuple[bool, Optional[list]]:
    """
    Verify that a relation is well-founded by checking for cycles.

    Algorithm:
    1. Build the directed graph of the step relation
    2. Perform DFS to detect cycles
    3. If no cycles, the relation is well-founded

    Time complexity: O(|S|²) for graph construction + O(|S| + |E|) for DFS
    Space complexity: O(|S|²) for adjacency representation

    Args:
        states: List of states
        step: Transition relation (s, t) -> bool

    Returns:
        (is_well_founded, counterexample_cycle_or_None)
    """
    n = len(states)
    state_idx = {s: i for i, s in enumerate(states)}

    # Build adjacency list
    adj = [[] for _ in range(n)]
    for i, s in enumerate(states):
        for j, t in enumerate(states):
            if step(s, t):
                adj[i].append(j)

    # DFS cycle detection
    WHITE, GRAY, BLACK = 0, 1, 2
    color = [WHITE] * n
    parent = [-1] * n

    def dfs(u):
        color[u] = GRAY
        for v in adj[u]:
            if color[v] == GRAY:
                # Found a cycle - reconstruct it
                cycle = [states[v], states[u]]
                w = parent[u]
                while w != v and w != -1:
                    cycle.append(states[w])
                    w = parent[w]
                return cycle[::-1]
            if color[v] == WHITE:
                parent[v] = u
                result = dfs(v)
                if result:
                    return result
        color[u] = BLACK
        return None

    for i in range(n):
        if color[i] == WHITE:
            cycle = dfs(i)
            if cycle:
                return False, cycle

    return True, None


def verify_product_termination(systems: List[InvariantSystem]) -> Dict:
    """
    Verify termination of the product system using the compositional theorem.

    Algorithm:
    1. Verify each component is well-founded
    2. By the product termination theorem, conclude the product terminates
    3. Optionally verify directly (expensive for large state spaces)

    Args:
        systems: List of component systems

    Returns:
        Dict with verification results
    """
    results = {
        'n_components': len(systems),
        'component_results': [],
        'product_terminates': True
    }

    for i, sys in enumerate(systems):
        wf, cycle = verify_well_founded(sys.states, sys.step)
        results['component_results'].append({
            'name': sys.name,
            'well_founded': wf,
            'counterexample': cycle
        })
        if not wf:
            results['product_terminates'] = False  # Can't conclude

    return results


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Example: 3 simple countdown systems
    def make_countdown(n: int, name: str) -> InvariantSystem:
        states = list(range(n + 1))
        step = lambda s, t: t == s - 1 and s > 0
        inv = lambda s: float(s)
        return InvariantSystem(name=name, states=states, step=step, inv=inv)

    systems = [make_countdown(3, "A"), make_countdown(4, "B"), make_countdown(2, "C")]

    print("=== Finite Product Construction ===")
    prod = finite_product(systems)
    print(f"Product has {len(prod['states'])} states")
    print(f"Sample state (3,4,2): inv = {prod['inv']((3,4,2))}")

    print("\n=== Subadditive Bound ===")
    result = subadditive_bound(
        [3.0, 4.0, 2.0],
        binary_phi=lambda a, b: 0.95 * (a + b)
    )
    print(f"Bound: {result['bound']}")
    print(f"Actual: {result['actual']:.4f}")
    print(f"Gap: {result['gap']:.4f}")

    print("\n=== Security Composition ===")
    sec = security_composition([128, 192, 256, 128, 160])
    print(f"Min bound: {sec['min_bound']} bits")
    print(f"Additive: {sec['additive_bound']} bits")
    print(f"Weakest component: index {sec['weakest_index']}")

    print("\n=== Termination Verification ===")
    term = verify_product_termination(systems)
    print(f"All components well-founded: {all(r['well_founded'] for r in term['component_results'])}")
    print(f"Product terminates: {term['product_terminates']}")
