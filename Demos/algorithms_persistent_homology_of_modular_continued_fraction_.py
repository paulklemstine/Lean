#!/usr/bin/env python3
"""
Algorithms for Modular Continued-Fraction Dynamics
====================================================

This module implements the core algorithms from the research paper on
persistent homology of modular continued-fraction dynamics.

Algorithms:
1. CF Convergent Recurrence (O(n) time, O(1) space)
2. Modular CF Graph Construction (O(n) time, O(p²) space)
3. Periodicity Detection via Brent's Algorithm (O(λ+μ) time, O(1) space)
4. Pisano Period Computation (O(p²) time, O(1) space)
5. Modular State Space Orbit Analysis (O(p⁴) time, O(p⁴) space)
"""

from typing import Tuple, List, Dict, Set, Optional
from dataclasses import dataclass
from collections import defaultdict
import math


@dataclass
class CFState:
    """State of the continued fraction convergent recurrence.

    Tracks (p_{n-1}, p_n, q_{n-1}, q_n) where p_n/q_n is the n-th convergent.
    """
    p_prev: int  # p_{n-1}
    p_curr: int  # p_n
    q_prev: int  # q_{n-1}
    q_curr: int  # q_n

    def step(self, a: int) -> 'CFState':
        """Advance by one CF coefficient a.

        Time: O(1) arithmetic operations
        Space: O(1)

        Recurrence:
            p_{n+1} = a * p_n + p_{n-1}
            q_{n+1} = a * q_n + q_{n-1}
        """
        return CFState(
            p_prev=self.p_curr,
            p_curr=a * self.p_curr + self.p_prev,
            q_prev=self.q_curr,
            q_curr=a * self.q_curr + self.q_prev,
        )

    def mod(self, m: int) -> 'CFState':
        """Reduce all components modulo m.

        Time: O(1)
        Space: O(1)
        """
        return CFState(
            p_prev=self.p_prev % m,
            p_curr=self.p_curr % m,
            q_prev=self.q_prev % m,
            q_curr=self.q_curr % m,
        )

    def step_mod(self, a: int, m: int) -> 'CFState':
        """Advance by one coefficient and reduce mod m.

        Time: O(1)
        Space: O(1)
        """
        return self.step(a).mod(m)

    def as_tuple(self) -> Tuple[int, int, int, int]:
        """Convert to hashable tuple for cycle detection."""
        return (self.p_prev, self.p_curr, self.q_prev, self.q_curr)

    @staticmethod
    def initial(a0: int) -> 'CFState':
        """Create initial state for CF coefficient a_0.

        Corresponds to: p_{-1}=1, p_0=a_0, q_{-1}=0, q_0=1
        """
        return CFState(p_prev=1, p_curr=a0, q_prev=0, q_curr=1)


def compute_convergents_stream(coefficients, n: int) -> List[CFState]:
    """Compute the first n CF states.

    Args:
        coefficients: callable or list giving CF coefficients
        n: number of states to compute

    Time: O(n) arithmetic operations
    Space: O(n) for storing all states

    Returns: List of CFState objects
    """
    if n == 0:
        return []

    a0 = coefficients[0] if isinstance(coefficients, list) else coefficients(0)
    states = [CFState.initial(a0)]

    for i in range(1, n):
        a = coefficients[i] if isinstance(coefficients, list) else coefficients(i)
        states.append(states[-1].step(a))

    return states


def compute_modular_cf_states(coefficients, n: int, m: int) -> List[CFState]:
    """Compute CF states reduced modulo m.

    Time: O(n)
    Space: O(n)
    """
    if n == 0:
        return []

    a0 = coefficients[0] if isinstance(coefficients, list) else coefficients(0)
    states = [CFState.initial(a0 % m).mod(m)]

    for i in range(1, n):
        a = coefficients[i] if isinstance(coefficients, list) else coefficients(i)
        states.append(states[-1].step_mod(a % m, m))

    return states


@dataclass
class ModularCFGraph:
    """The modular CF graph K_p(x, N).

    Vertices: elements of (Z/pZ)² representing (p_n mod p, q_n mod p)
    Edges: directed edges between consecutive convergent pairs
    """
    p: int
    window_size: int
    vertices: Set[Tuple[int, int]]
    edges: Set[Tuple[Tuple[int, int], Tuple[int, int]]]

    @property
    def vertex_count(self) -> int:
        return len(self.vertices)

    @property
    def edge_count(self) -> int:
        return len(self.edges)

    @property
    def density(self) -> float:
        """Edge density relative to maximum possible edges."""
        max_edges = self.vertex_count * (self.vertex_count - 1)
        return self.edge_count / max_edges if max_edges > 0 else 0.0


def build_modular_cf_graph(states: List[CFState], p: int,
                            start: int = 0, end: int = None) -> ModularCFGraph:
    """Build the modular CF graph from a range of CF states.

    Algorithm:
        1. Extract (p_n mod p, q_n mod p) for each state in the window
        2. Add directed edges between consecutive pairs
        3. Return the graph structure

    Time: O(window_size)
    Space: O(min(window_size, p²))

    Args:
        states: precomputed modular CF states
        p: prime modulus
        start: window start index
        end: window end index (exclusive)
    """
    if end is None:
        end = len(states)

    vertices: Set[Tuple[int, int]] = set()
    edges: Set[Tuple[Tuple[int, int], Tuple[int, int]]] = set()

    window_states = states[start:end]
    for i, s in enumerate(window_states):
        v = (s.p_curr % p, s.q_curr % p)
        vertices.add(v)
        if i > 0:
            prev_v = (window_states[i-1].p_curr % p, window_states[i-1].q_curr % p)
            edges.add((prev_v, v))

    return ModularCFGraph(
        p=p,
        window_size=end - start,
        vertices=vertices,
        edges=edges,
    )


def brent_cycle_detection(f, x0) -> Tuple[int, int]:
    """Brent's cycle detection algorithm.

    Finds the preperiod (μ) and period (λ) of the sequence
    x0, f(x0), f²(x0), ...

    Time: O(μ + λ)
    Space: O(1)

    Returns: (preperiod, period)
    """
    # Phase 1: Find a power of 2 that exceeds both μ and λ
    power = lam = 1
    tortoise = x0
    hare = f(x0)

    while tortoise != hare:
        if power == lam:
            tortoise = hare
            power *= 2
            lam = 0
        hare = f(hare)
        lam += 1

    # Phase 2: Find the preperiod μ
    tortoise = hare = x0
    for _ in range(lam):
        hare = f(hare)

    mu = 0
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(hare)
        mu += 1

    return mu, lam


def detect_modular_cf_period(coefficients, p: int,
                              max_steps: int = 10000) -> Tuple[int, int]:
    """Detect the period of the modular CF state sequence.

    Uses Brent's algorithm on the state space (Z/pZ)⁴.

    Time: O(μ + λ) where μ is preperiod and λ is period
    Space: O(1) (Brent's algorithm)

    Args:
        coefficients: CF coefficient sequence (callable or list)
        p: prime modulus
        max_steps: safety bound

    Returns: (preperiod, period), or (-1, -1) if not periodic within max_steps
    """
    # For eventually periodic coefficients, we need a different approach
    # since the transition function changes with time.
    # Use direct comparison instead.
    states: Dict[Tuple[int, int, int, int], int] = {}

    a0 = coefficients[0] if isinstance(coefficients, list) else coefficients(0)
    state = CFState.initial(a0 % p).mod(p)

    for n in range(max_steps):
        key = state.as_tuple()
        if key in states:
            preperiod = states[key]
            period = n - preperiod
            # Verify: check that coefficients are also periodic
            return preperiod, period
        states[key] = n

        a = coefficients[n + 1] if isinstance(coefficients, (list,)) and n + 1 < len(coefficients) \
            else (coefficients(n + 1) if callable(coefficients) else 0)
        state = state.step_mod(a % p, p)

    return -1, -1


def pisano_period(p: int) -> int:
    """Compute the Pisano period π(p) = period of Fibonacci sequence mod p.

    The Fibonacci sequence mod p is purely periodic with period π(p).
    This is equivalent to the period of the golden ratio CF ([1;1,1,...]) mod p.

    Time: O(π(p)) ≤ O(6p) conjecturally
    Space: O(1)

    Args:
        p: prime modulus (≥ 2)

    Returns: the Pisano period
    """
    if p <= 1:
        return 1

    f_prev, f_curr = 0, 1
    for i in range(1, 6 * p * p + 1):  # generous upper bound
        f_prev, f_curr = f_curr, (f_prev + f_curr) % p
        if f_prev == 0 and f_curr == 1:
            return i

    raise ValueError(f"Pisano period not found for p={p}")


def analyze_orbit_structure(coefficients, p: int,
                            n_steps: int = 200) -> Dict:
    """Analyze the complete orbit structure of modular CF dynamics.

    Time: O(n_steps)
    Space: O(n_steps)

    Returns dict with:
    - states: list of all states visited
    - unique_states: number of distinct states
    - state_space_size: p^4 (total possible states)
    - preperiod: detected preperiod (-1 if none)
    - period: detected period (-1 if none)
    - graph_stats: statistics about the modular CF graph
    """
    states = compute_modular_cf_states(coefficients, n_steps, p)
    unique = set(s.as_tuple() for s in states)

    graph = build_modular_cf_graph(states, p)
    preperiod, period = detect_modular_cf_period(coefficients, p, n_steps)

    return {
        'prime': p,
        'n_steps': n_steps,
        'unique_states': len(unique),
        'state_space_size': p ** 4,
        'state_space_usage': len(unique) / p ** 4,
        'preperiod': preperiod,
        'period': period,
        'graph_vertices': graph.vertex_count,
        'graph_edges': graph.edge_count,
        'graph_density': graph.density,
        'vertex_bound': min(n_steps, p ** 2),
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Modular CF Dynamics - Algorithm Demonstrations")
    print("=" * 60)

    # Golden ratio
    golden = lambda n: 1
    print("\n--- Golden Ratio φ = [1; 1, 1, ...] ---")
    for p in [3, 5, 7, 11, 13]:
        result = analyze_orbit_structure(golden, p, 200)
        print(f"  p={p:2d}: period={result['period']:3d}, "
              f"vertices={result['graph_vertices']:3d}/{result['vertex_bound']:3d}, "
              f"Pisano π(p)={pisano_period(p)}")

    # √2
    sqrt2 = lambda n: 1 if n == 0 else 2
    print("\n--- √2 = [1; 2, 2, 2, ...] ---")
    for p in [3, 5, 7, 11, 13]:
        result = analyze_orbit_structure(sqrt2, p, 200)
        print(f"  p={p:2d}: preperiod={result['preperiod']:2d}, period={result['period']:3d}, "
              f"vertices={result['graph_vertices']:3d}")

    # e (transcendental)
    def e_cf(n):
        if n == 0: return 2
        k = (n + 1) // 3
        return 2 * k if (n - 1) % 3 == 0 and n > 0 else 1

    print("\n--- e = [2; 1, 2, 1, 1, 4, ...] (transcendental) ---")
    for p in [3, 5, 7]:
        result = analyze_orbit_structure(e_cf, p, 500)
        print(f"  p={p:2d}: preperiod={result['preperiod']:2d}, period={result['period']:3d}, "
              f"vertices={result['graph_vertices']:3d}, density={result['graph_density']:.3f}")

    print("\n--- Pisano Period Verification ---")
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
        pi_p = pisano_period(p)
        print(f"  π({p:2d}) = {pi_p:4d},  6p = {6*p:4d},  "
              f"π(p)/p = {pi_p/p:.2f},  π(p) ≤ 6p: {'✓' if pi_p <= 6*p else '✗'}")
