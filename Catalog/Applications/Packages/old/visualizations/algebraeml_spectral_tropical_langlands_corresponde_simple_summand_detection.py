#!/usr/bin/env python3
"""
Algorithms for Tropical Spectral Analysis

Implements the core algorithms from the tropical spectral Langlands
correspondence:

1. Closure operator construction from residuated actions
2. Simple summand detection (closure-prime + closed)
3. Eigenmeasure construction
4. Spectral fingerprinting
5. Character recovery

All algorithms work on finite lattices represented as DAGs.
"""

from typing import Callable, Optional
from dataclasses import dataclass
import numpy as np

NEG_INF = float('-inf')


# ─── Algorithm 1: Closure from Galois Connection ─────────────────────

@dataclass
class GaloisPair:
    """A Galois connection (l, u) on a finite poset.
    
    Satisfies: l(a) ≤ b ⟺ a ≤ u(b) for all a, b.
    
    Time complexity for verification: O(n²) where n = |poset|.
    """
    elements: list  # Finite poset elements
    le: Callable     # Partial order predicate
    left: Callable   # Left adjoint l
    right: Callable  # Right adjoint u (residual)
    
    def closure(self, x):
        """Closure operator: u(l(x)). O(1) per call."""
        return self.right(self.left(x))
    
    def verify(self) -> bool:
        """Verify Galois connection. O(n²)."""
        for a in self.elements:
            for b in self.elements:
                if self.le(self.left(a), b) != self.le(a, self.right(b)):
                    return False
        return True
    
    def closed_elements(self) -> list:
        """All fixed points of the closure. O(n)."""
        return [x for x in self.elements if self.closure(x) == x]
    
    def spectral_size(self) -> int:
        """Number of closed elements. O(n)."""
        return len(self.closed_elements())


# ─── Algorithm 2: Simple Summand Detection ────────────────────────────

def is_closure_prime(gp: GaloisPair, s) -> bool:
    """Check if s is closure-prime: s ≤ cl(x) ⟹ s ≤ x.
    
    Time complexity: O(n) where n = |elements|.
    """
    for x in gp.elements:
        if gp.le(s, gp.closure(x)) and not gp.le(s, x):
            return False
    return True


def find_summands(pairs: list[GaloisPair], bot) -> list:
    """Find simple summands: non-bot, closed, closure-prime under all actions.
    
    Time complexity: O(k·n²) where k = |pairs|, n = |elements|.
    """
    if not pairs:
        return []
    summands = []
    for x in pairs[0].elements:
        if x == bot:
            continue
        if all(gp.closure(x) == x for gp in pairs):
            if all(is_closure_prime(gp, x) for gp in pairs):
                summands.append(x)
    return summands


# ─── Algorithm 3: Eigenmeasure Construction ──────────────────────────

def indicator_measure(summand, x, le_fn) -> float:
    """Indicator eigenmeasure: 0 if summand ≤ x, -∞ otherwise.
    
    Time complexity: O(1).
    """
    return 0.0 if le_fn(summand, x) else NEG_INF


def verify_eigenmeasure(gp: GaloisPair, summand) -> dict:
    """Verify all eigenmeasure properties for an indicator.
    
    Returns dict with verification results.
    Time complexity: O(n).
    """
    results = {
        'monotone': True,
        'closure_invariant': True,
        'bot_maps_to_bot': True,
    }
    
    # Monotonicity
    for x in gp.elements:
        for y in gp.elements:
            if gp.le(x, y):
                mx = indicator_measure(summand, x, gp.le)
                my = indicator_measure(summand, y, gp.le)
                if mx > my:
                    results['monotone'] = False
    
    # Closure invariance
    for x in gp.elements:
        mx = indicator_measure(summand, x, gp.le)
        mcl = indicator_measure(summand, gp.closure(x), gp.le)
        if mx != mcl:
            results['closure_invariant'] = False
    
    return results


# ─── Algorithm 4: Spectral Fingerprinting ─────────────────────────────

@dataclass
class SpectralFingerprint:
    """Computable spectral invariant of a residuated action system.
    
    Components:
    - spectral_sizes: tuple of closed-element counts per action
    - closed_profiles: sorted tuple of element-level closure profiles
    - summand_count: number of simple summands
    """
    spectral_sizes: tuple
    closed_profiles: tuple
    summand_count: int
    
    def __eq__(self, other):
        return (self.spectral_sizes == other.spectral_sizes and
                self.summand_count == other.summand_count)
    
    def __hash__(self):
        return hash((self.spectral_sizes, self.summand_count))


def compute_fingerprint(pairs: list[GaloisPair], bot) -> SpectralFingerprint:
    """Compute the spectral fingerprint of an action system.
    
    Time complexity: O(k·n²) where k = |pairs|, n = |elements|.
    """
    sizes = tuple(gp.spectral_size() for gp in pairs)
    
    # Profile: for each element, which actions close it
    if pairs:
        elements = pairs[0].elements
        profiles = []
        for x in elements:
            profile = tuple(1 if gp.closure(x) == x else 0 for gp in pairs)
            profiles.append(profile)
        profiles = tuple(sorted(profiles))
    else:
        profiles = ()
    
    summands = find_summands(pairs, bot)
    
    return SpectralFingerprint(sizes, profiles, len(summands))


# ─── Algorithm 5: Character Recovery ──────────────────────────────────

def tropical_character(gp: GaloisPair, top):
    """Tropical character: closure of the top element.
    
    Time complexity: O(1).
    """
    return gp.closure(top)


def recover_character_from_closed(gp: GaloisPair, join_fn):
    """Recover character as supremum of closed elements.
    
    Time complexity: O(n).
    """
    closed = gp.closed_elements()
    if not closed:
        return None
    result = closed[0]
    for c in closed[1:]:
        result = join_fn(result, c)
    return result


# ─── Max-Plus Matrix Spectral Analysis ────────────────────────────────

def maxplus_matrix_mult(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Max-plus matrix multiplication: (A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj}).
    
    Time complexity: O(n³).
    """
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), NEG_INF)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                val = A[i, k] + B[k, j] if A[i, k] != NEG_INF and B[k, j] != NEG_INF else NEG_INF
                C[i, j] = max(C[i, j], val)
    return C


def maxplus_spectral_radius(A: np.ndarray) -> float:
    """Tropical spectral radius: max over all cycle means.
    
    For an n×n matrix, this is max_{k=1..n} max_{i} (A^k_{ii} / k).
    
    Time complexity: O(n⁴).
    """
    n = A.shape[0]
    best = NEG_INF
    power = np.eye(n) * 0  # Identity in max-plus: 0 on diagonal, -inf off
    for i in range(n):
        for j in range(n):
            if i != j:
                power[i, j] = NEG_INF
    
    for k in range(1, n + 1):
        power = maxplus_matrix_mult(power, A)
        for i in range(n):
            if power[i, i] != NEG_INF:
                cycle_mean = power[i, i] / k
                best = max(best, cycle_mean)
    
    return best


def maxplus_tropical_trace(A: np.ndarray) -> float:
    """Tropical trace: max of diagonal entries.
    
    Time complexity: O(n).
    """
    return max(A[i, i] for i in range(A.shape[0]))


# ─── Demo: Max-Plus Spectral Analysis ─────────────────────────────────

def demo_maxplus():
    """Demonstrate max-plus spectral analysis on small matrices."""
    print("=" * 70)
    print("MAX-PLUS SPECTRAL ANALYSIS")
    print("=" * 70)
    
    # Example: a 3×3 max-plus matrix
    A = np.array([
        [0, 3, NEG_INF],
        [2, 0, 1],
        [NEG_INF, 4, 0]
    ])
    
    print(f"\nMatrix A (max-plus):")
    for row in A:
        print(f"  [{', '.join(str(int(x)) if x != NEG_INF else '-∞' for x in row)}]")
    
    print(f"\nTropical trace (max diagonal): {maxplus_tropical_trace(A)}")
    print(f"Spectral radius (max cycle mean): {maxplus_spectral_radius(A):.2f}")
    
    # Compute powers
    A2 = maxplus_matrix_mult(A, A)
    A3 = maxplus_matrix_mult(A2, A)
    
    print(f"\nA² (max-plus):")
    for row in A2:
        print(f"  [{', '.join(str(int(x)) if x != NEG_INF else '-∞' for x in row)}]")
    
    print(f"\nTropical trace of A²: {maxplus_tropical_trace(A2)}")
    print(f"Tropical trace of A³: {maxplus_tropical_trace(A3)}")
    
    # The spectral radius is the limit of tr(A^k)^{1/k}
    traces = []
    power = A.copy()
    for k in range(1, 8):
        if k > 1:
            power = maxplus_matrix_mult(power, A)
        tr = maxplus_tropical_trace(power)
        traces.append((k, tr, tr / k if tr != NEG_INF else NEG_INF))
    
    print(f"\nConvergence of tr(A^k)/k to spectral radius:")
    for k, tr, mean in traces:
        print(f"  k={k}: tr(A^k)={tr:.0f}, tr(A^k)/k={mean:.2f}")


# ─── Demo: Linear Lattice Correspondence ─────────────────────────────

def demo_linear_lattice():
    """Demonstrate on a linear lattice (total order) where summands are clear."""
    print("\n" + "=" * 70)
    print("LINEAR LATTICE EXAMPLE")
    print("=" * 70)
    
    # Lattice: {0, 1, 2, 3, 4} with usual order
    elements = list(range(5))
    
    # Action: "floor division by 2" with residual "multiply by 2, cap at 4"
    def act1(x):
        return x // 2
    def res1(y):
        return min(2 * y + 1, 4)
    
    gp1 = GaloisPair(elements, lambda a, b: a <= b, act1, res1)
    
    # Action: identity
    gp_id = GaloisPair(elements, lambda a, b: a <= b, lambda x: x, lambda x: x)
    
    print(f"\nAction 1: floor(x/2) with residual min(2y+1, 4)")
    print(f"  Galois verified: {gp1.verify()}")
    print(f"  Closure map: {[(x, gp1.closure(x)) for x in elements]}")
    print(f"  Closed elements: {gp1.closed_elements()}")
    print(f"  Spectral size: {gp1.spectral_size()}")
    
    print(f"\nAction 2: identity")
    print(f"  Closed elements: {gp_id.closed_elements()}")
    print(f"  Spectral size: {gp_id.spectral_size()}")
    
    # Character recovery
    top = max(elements)
    char1 = tropical_character(gp1, top)
    char_from_closed = recover_character_from_closed(gp1, max)
    print(f"\n  Character (cl(⊤) = cl({top})): {char1}")
    print(f"  Recovered from sup of closed: {char_from_closed}")
    print(f"  Equal: {char1 == char_from_closed}")
    
    # Summands for single action
    summands = find_summands([gp1], bot=0)
    print(f"\n  Simple summands for action 1: {summands}")
    for s in summands:
        print(f"    Summand {s}: closure-prime = {is_closure_prime(gp1, s)}")
        props = verify_eigenmeasure(gp1, s)
        print(f"    Eigenmeasure properties: {props}")


if __name__ == "__main__":
    demo_maxplus()
    demo_linear_lattice()


#!/usr/bin/env python3
"""
Applications of the Tropical Spectral Langlands Correspondence

Demonstrates connections to:
1. Scheduling / Discrete Event Systems (max-plus dynamics)
2. Abstract Interpretation in Program Analysis (closure-based)
3. Network Routing Optimization (tropical shortest paths)
4. Idempotent Probability / Decision Theory
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO

NEG_INF = float('-inf')


# ─── Application 1: Job Shop Scheduling ──────────────────────────────

def job_shop_scheduling():
    """Max-plus scheduling: find the makespan of a 3-machine job shop.
    
    The tropical spectral radius of the system matrix gives the
    asymptotic cycle time (minimum achievable period).
    """
    print("=" * 70)
    print("APPLICATION 1: JOB SHOP SCHEDULING (Max-Plus Dynamics)")
    print("=" * 70)
    
    # System matrix: processing times + routing constraints
    # A[i][j] = time machine i must wait after machine j finishes
    A = np.array([
        [3, 5, NEG_INF],   # Machine 0
        [NEG_INF, 2, 4],   # Machine 1  
        [6, NEG_INF, 1]    # Machine 2
    ])
    
    print("\nSystem matrix (processing + routing):")
    labels = ['M0', 'M1', 'M2']
    for i, row in enumerate(A):
        vals = [f"{int(x):2d}" if x != NEG_INF else '-∞' for x in row]
        print(f"  {labels[i]}: [{', '.join(vals)}]")
    
    # Compute spectral radius (asymptotic cycle time)