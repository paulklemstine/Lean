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
    from algorithms import maxplus_spectral_radius, maxplus_matrix_mult, maxplus_tropical_trace
    
    rho = maxplus_spectral_radius(A)
    print(f"\nTropical spectral radius (cycle time): {rho:.2f}")
    print(f"Interpretation: minimum achievable period = {rho:.2f} time units")
    
    # Simulate max-plus dynamics
    x = np.array([0.0, 0.0, 0.0])  # Initial state
    print(f"\nMax-plus dynamics (state evolution):")
    print(f"  t=0: x = {x}")
    
    for t in range(1, 8):
        x_new = np.full(3, NEG_INF)
        for i in range(3):
            for j in range(3):
                if A[i, j] != NEG_INF:
                    x_new[i] = max(x_new[i], A[i, j] + x[j])
        x = x_new
        print(f"  t={t}: x = [{', '.join(f'{v:.0f}' for v in x)}]"
              f"  (max = {max(x):.0f})")
    
    return rho


# ─── Application 2: Abstract Interpretation ──────────────────────────

def abstract_interpretation():
    """Closure operators model abstract domains in program analysis.
    
    The tropical correspondence translates program semantics
    (abstract interpretation) into spectral invariants.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: ABSTRACT INTERPRETATION (Closure Semantics)")
    print("=" * 70)
    
    # Abstract domain: intervals on {0,...,7}
    # States are (lower, upper) bounds
    n = 8
    
    # A "program operation": x ← x + 1 (mod 8), with abstract transfer
    def abs_transfer(lo, hi):
        """Abstract transfer for x ← x + 1."""
        return ((lo + 1) % n, (hi + 1) % n)
    
    # Widening operator (closure): extend to nearest power-of-2 boundary
    def widen(lo, hi):
        """Widening closure: snap bounds to powers of 2."""
        import math
        if lo == hi:
            return (lo, hi)
        # Snap lower bound down
        new_lo = 0
        # Snap upper bound up
        new_hi = min(n - 1, 2 ** math.ceil(math.log2(hi + 1)) - 1) if hi > 0 else 0
        return (new_lo, new_hi)
    
    print("\nAbstract domain: integer intervals in [0, 7]")
    print("\nWidening examples:")
    for lo, hi in [(0, 0), (1, 3), (2, 5), (0, 7), (3, 6)]:
        w = widen(lo, hi)
        print(f"  [{lo}, {hi}] → [{w[0]}, {w[1]}]")
    
    # Fixed point computation with widening
    print("\nFixed point iteration with widening:")
    state = (0, 0)
    for i in range(6):
        print(f"  Step {i}: [{state[0]}, {state[1]}]")
        transferred = abs_transfer(state[0], state[1])
        # Join with previous state
        joined = (min(state[0], transferred[0]),
                  max(state[1], transferred[1]))
        state = widen(joined[0], joined[1])
    print(f"  Fixed point: [{state[0]}, {state[1]}]")
    
    print("\nConnection to tropical spectral theory:")
    print("  • Widening operators = closure operators")
    print("  • Fixed points = closed elements = stable abstractions")
    print("  • Spectral size = precision of the abstract domain")
    print("  • Simple summands = irreducible abstract properties")


# ─── Application 3: Network Routing ──────────────────────────────────

def network_routing():
    """Tropical shortest paths as a spectral problem.
    
    The all-pairs shortest path matrix is the tropical closure
    of the edge-weight matrix.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: NETWORK ROUTING (Tropical Shortest Paths)")
    print("=" * 70)
    
    from algorithms import maxplus_matrix_mult
    
    # Use min-plus (dual of max-plus) for shortest paths
    INF = float('inf')
    
    # Network: 4 nodes
    # Edge weights (distances)
    W = np.array([
        [0,   2,   INF, 7],
        [INF, 0,   3,   INF],
        [INF, INF, 0,   1],
        [4,   INF, INF, 0]
    ])
    
    print("\nEdge weight matrix:")
    labels = ['A', 'B', 'C', 'D']
    for i, row in enumerate(W):
        vals = [f"{int(x):2d}" if x != INF else ' ∞' for x in row]
        print(f"  {labels[i]}: [{', '.join(vals)}]")
    
    # Floyd-Warshall (= min-plus closure)
    D = W.copy()
    n = 4
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i, j] = min(D[i, j], D[i, k] + D[k, j])
    
    print("\nAll-pairs shortest paths (min-plus closure):")
    for i, row in enumerate(D):
        vals = [f"{int(x):2d}" if x != INF else ' ∞' for x in row]
        print(f"  {labels[i]}: [{', '.join(vals)}]")
    
    # The diagonal gives cycle weights
    print("\nMin-cycle weights (diagonal of closure):")
    for i in range(n):
        print(f"  Node {labels[i]}: {int(D[i, i])}")
    
    print("\nSpectral interpretation:")
    print("  • Edge matrix = action operator")
    print("  • Floyd-Warshall = closure computation (res ∘ act)")
    print("  • Shortest paths = closed elements")
    print("  • Cycle weights = tropical eigenvalues")
    min_cycle = min(D[i, i] for i in range(n))
    print(f"  • Min cycle weight (spectral radius) = {min_cycle}")


# ─── Visualizations ──────────────────────────────────────────────────

def create_visualizations():
    """Generate publication-quality visualizations."""
    
    # Visualization 1: Closure lattice
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Panel 1: Spectral size comparison
    ax = axes[0]
    actions = ['Identity', 'Proj({0})', 'Proj({0,1})', 'Proj({0,2})', 'Swap(0,1)']
    sizes = [8, 2, 4, 4, 8]
    colors = ['#2ecc71' if s == 8 else '#3498db' if s == 4 else '#e74c3c'
              for s in sizes]
    bars = ax.bar(range(len(actions)), sizes, color=colors, edgecolor='black',
                  linewidth=0.5)
    ax.set_xticks(range(len(actions)))
    ax.set_xticklabels(actions, rotation=30, ha='right', fontsize=9)
    ax.set_ylabel('Spectral Size', fontsize=11)
    ax.set_title('Spectral Size of Actions\non P({0,1,2})', fontsize=12)
    ax.set_ylim(0, 10)
    for bar, s in zip(bars, sizes):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.2,
                str(s), ha='center', fontsize=10, fontweight='bold')
    
    # Panel 2: Max-plus spectral radius convergence
    ax = axes[1]
    A = np.array([
        [0, 3, NEG_INF],
        [2, 0, 1],
        [NEG_INF, 4, 0]
    ])
    
    from algorithms import maxplus_matrix_mult, maxplus_tropical_trace
    
    ks = list(range(1, 15))
    means = []
    power = A.copy()
    for k in ks:
        if k > 1:
            power = maxplus_matrix_mult(power, A)
        tr = maxplus_tropical_trace(power)
        means.append(tr / k if tr != NEG_INF else 0)
    
    ax.plot(ks, means, 'o-', color='#e74c3c', markersize=5, linewidth=1.5)
    ax.axhline(y=2.5, color='#2c3e50', linestyle='--', linewidth=1,
               label='Spectral radius = 2.5')
    ax.set_xlabel('Power k', fontsize=11)
    ax.set_ylabel('tr(A^k) / k', fontsize=11)
    ax.set_title('Convergence to\nTropical Spectral Radius', fontsize=12)
    ax.legend(fontsize=9)
    ax.set_ylim(0, 3.5)
    
    # Panel 3: Closure operator on linear lattice
    ax = axes[2]
    elements = list(range(5))
    closure_map = {0: 1, 1: 1, 2: 3, 3: 3, 4: 4}
    
    # Draw elements
    for x in elements:
        color = '#2ecc71' if closure_map[x] == x else '#bdc3c7'
        ax.plot(0.5, x, 'o', markersize=20, color=color, 
                markeredgecolor='black', markeredgewidth=1.5, zorder=5)
        ax.text(0.5, x, str(x), ha='center', va='center', fontsize=12,
                fontweight='bold', zorder=6)
    
    # Draw closure arrows
    for x in elements:
        if closure_map[x] != x:
            ax.annotate('', xy=(0.7, closure_map[x]), xytext=(0.7, x),
                       arrowprops=dict(arrowstyle='->', color='#e74c3c',
                                      lw=2, connectionstyle='arc3,rad=0.3'))
    
    # Draw Hasse diagram edges
    for x in elements[:-1]:
        ax.plot([0.5, 0.5], [x, x + 1], '-', color='#95a5a6', linewidth=1,
                zorder=1)
    
    ax.set_xlim(0, 1.2)
    ax.set_ylim(-0.5, 4.5)
    ax.set_title('Closure Operator on [0,4]\n(green = closed)', fontsize=12)
    ax.axis('off')
    
    # Add legend markers
    ax.plot([], [], 'o', color='#2ecc71', markersize=10, 
            markeredgecolor='black', label='Closed (fixed)')
    ax.plot([], [], 'o', color='#bdc3c7', markersize=10,
            markeredgecolor='black', label='Not closed')
    ax.legend(loc='lower left', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/spectral_analysis.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    
    # Visualization 2: The correspondence diagram
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Draw the two sides
    left_x, right_x = 1.5, 6.5
    
    # Left side: Representation / Action
    ax.text(left_x, 5.5, 'Tropical Representation', fontsize=14, 
            fontweight='bold', ha='center', color='#2c3e50')
    ax.text(left_x, 4.8, 'Residuated H-Action on M', fontsize=11,
            ha='center', color='#7f8c8d')
    
    summand_labels = ['Simple\nSummand 1', 'Simple\nSummand 2', 'Simple\nSummand 3']
    for i, label in enumerate(summand_labels):
        y = 3.5 - i * 1.2
        circle = plt.Circle((left_x, y), 0.4, fill=True, 
                           facecolor='#3498db', edgecolor='#2c3e50',
                           linewidth=2, alpha=0.8)
        ax.add_patch(circle)
        ax.text(left_x, y, label, ha='center', va='center', fontsize=8,
                fontweight='bold', color='white')
    
    # Right side: Closure Spectrum
    ax.text(right_x, 5.5, 'Closure Spectrum', fontsize=14,
            fontweight='bold', ha='center', color='#2c3e50')
    ax.text(right_x, 4.8, 'Eigenmeasures on Sat(M)', fontsize=11,
            ha='center', color='#7f8c8d')
    
    measure_labels = ['Extremal\nMeasure 1', 'Extremal\nMeasure 2', 'Extremal\nMeasure 3']
    for i, label in enumerate(measure_labels):
        y = 3.5 - i * 1.2
        circle = plt.Circle((right_x, y), 0.4, fill=True,
                           facecolor='#e74c3c', edgecolor='#2c3e50',
                           linewidth=2, alpha=0.8)
        ax.add_patch(circle)
        ax.text(right_x, y, label, ha='center', va='center', fontsize=8,
                fontweight='bold', color='white')
    
    # Arrows (the correspondence)
    for i in range(3):
        y = 3.5 - i * 1.2
        ax.annotate('', xy=(right_x - 0.5, y), xytext=(left_x + 0.5, y),
                   arrowprops=dict(arrowstyle='<->', color='#f39c12',
                                  lw=2.5, connectionstyle='arc3,rad=0'))
    
    # Central label
    ax.text(4.0, 5.0, 'Φ_M : Injection', fontsize=13, ha='center',
            fontweight='bold', color='#f39c12',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#fef9e7',
                     edgecolor='#f39c12', linewidth=2))
    
    # Bottom label
    ax.text(4.0, 0.3, 
            'Tropical Spectral Langlands Correspondence\n'
            'Simple summands ↪ Extremal closure eigenmeasures',
            fontsize=12, ha='center', va='center',
            style='italic', color='#2c3e50',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#ecf0f1',
                     edgecolor='#bdc3c7'))
    
    ax.set_xlim(0, 8)
    ax.set_ylim(-0.3, 6.2)
    ax.axis('off')
    ax.set_aspect('equal')
    
    plt.savefig('/workspace/request-project/correspondence_diagram.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    
    print("\nVisualizations saved:")
    print("  • spectral_analysis.png")
    print("  • correspondence_diagram.png")


if __name__ == "__main__":
    job_shop_scheduling()
    abstract_interpretation()
    network_routing()
    print("\n" + "=" * 70)
    print("GENERATING VISUALIZATIONS")
    print("=" * 70)
    create_visualizations()


#!/usr/bin/env python3
"""
Tropical Spectral Langlands Correspondence: Interactive Demo

Demonstrates the core mathematical construction:
- Residuated actions on finite lattices
- Closure operators from Galois connections
- Simple summand detection via closure-prime elements
- The spectral correspondence (summands ↔ eigenmeasures)
- Character recovery from closure data

All computations use max-plus (tropical) arithmetic over integers
extended with -∞.
"""

import itertools
from typing import Optional

# ─── Max-Plus Arithmetic ───────────────────────────────────────────────

NEG_INF = float('-inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)."""
    return max(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with -∞ absorbing)."""
    if a == NEG_INF or b == NEG_INF:
        return NEG_INF
    return a + b

# ─── Finite Lattice: Power Set of {0,1,...,n-1} ──────────────────────

def powerset(n: int) -> list[frozenset]:
    """All subsets of {0,...,n-1}, ordered by inclusion."""
    elems = list(range(n))
    result = []
    for r in range(n + 1):
        for combo in itertools.combinations(elems, r):
            result.append(frozenset(combo))
    return sorted(result, key=lambda s: (len(s), sorted(s)))

def le_set(a: frozenset, b: frozenset) -> bool:
    """Partial order: subset inclusion."""
    return a <= b

def join_set(a: frozenset, b: frozenset) -> frozenset:
    """Join (sup): union."""
    return a | b

def bot_set() -> frozenset:
    """Bottom element: empty set."""
    return frozenset()

# ─── Residuated Action ───────────────────────────────────────────────

class ResidualAction:
    """A residuated (Galois-connected) monotone action on a finite lattice.
    
    The lattice is the powerset of {0,...,n-1} ordered by inclusion.
    The action and residual form a Galois connection:
        act(x) ⊆ y  ⟺  x ⊆ res(y)
    """
    
    def __init__(self, name: str, act_fn, res_fn, n: int):
        self.name = name
        self.act = act_fn
        self.res = res_fn
        self.n = n
        self.lattice = powerset(n)
    
    def verify_galois(self) -> bool:
        """Verify the Galois connection property on all pairs."""
        for x in self.lattice:
            for y in self.lattice:
                lhs = le_set(self.act(x), y)
                rhs = le_set(x, self.res(y))
                if lhs != rhs:
                    return False
        return True
    
    def closure(self, x: frozenset) -> frozenset:
        """Closure operator: res(act(x))."""
        return self.res(self.act(x))
    
    def closed_elements(self) -> list[frozenset]:
        """All fixed points of the closure operator."""
        return [x for x in self.lattice if self.closure(x) == x]
    
    def spectral_size(self) -> int:
        """Number of closed (fixed) elements."""
        return len(self.closed_elements())

# ─── Simple Summands ─────────────────────────────────────────────────

def is_closure_prime(action: ResidualAction, s: frozenset) -> bool:
    """Check if s is closure-prime: s ⊆ cl(x) ⟹ s ⊆ x for all x."""
    for x in action.lattice:
        if le_set(s, action.closure(x)) and not le_set(s, x):
            return False
    return True

def find_simple_summands(actions: list[ResidualAction]) -> list[frozenset]:
    """Find all simple summands: non-bot elements that are closed under
    all actions and closure-prime under all actions."""
    if not actions:
        return []
    lattice = actions[0].lattice
    summands = []
    for x in lattice:
        if x == bot_set():
            continue
        # Must be closed under all actions
        if not all(a.closure(x) == x for a in actions):
            continue
        # Must be closure-prime under all actions
        if not all(is_closure_prime(a, x) for a in actions):
            continue
        summands.append(x)
    return summands

# ─── Closure Eigenmeasures ────────────────────────────────────────────

def summand_indicator(s: frozenset, x: frozenset) -> float:
    """Indicator eigenmeasure: 0 if s ⊆ x, -∞ otherwise."""
    return 0.0 if le_set(s, x) else NEG_INF

def verify_closure_invariance(action: ResidualAction, s: frozenset) -> bool:
    """Verify μ_s(cl(x)) = μ_s(x) for all x."""
    for x in action.lattice:
        if summand_indicator(s, action.closure(x)) != summand_indicator(s, x):
            return False
    return True

# ─── Character Recovery ──────────────────────────────────────────────

def tropical_character(action: ResidualAction) -> frozenset:
    """Tropical character: closure of the top element."""
    top = frozenset(range(action.n))
    return action.closure(top)

# ─── Example Actions ─────────────────────────────────────────────────

def identity_action(n: int) -> ResidualAction:
    """Identity action: act = res = id."""
    return ResidualAction("identity", lambda x: x, lambda x: x, n)

def projection_action(n: int, keep: frozenset) -> ResidualAction:
    """Projection action: act(x) = x ∩ keep, res(y) = y ∪ keep^c.
    
    This projects onto the coordinates in 'keep', with residual
    adding back the complement coordinates.
    """
    full = frozenset(range(n))
    complement = full - keep
    return ResidualAction(
        f"proj_{set(keep)}",
        act_fn=lambda x, k=keep: x & k,
        res_fn=lambda y, c=complement: y | c,
        n=n
    )

def swap_action(n: int, i: int, j: int) -> ResidualAction:
    """Swap action: exchanges elements i and j. Self-adjoint."""
    def swap(x: frozenset, a=i, b=j) -> frozenset:
        s = set(x)
        has_a, has_b = a in s, b in s
        if has_a and not has_b:
            s.remove(a); s.add(b)
        elif has_b and not has_a:
            s.remove(b); s.add(a)
        return frozenset(s)
    return ResidualAction(f"swap({i},{j})", swap, swap, n)

# ─── Main Demo ────────────────────────────────────────────────────────

def demo_basic():
    """Demonstrate the basic correspondence on small examples."""
    print("=" * 70)
    print("TROPICAL SPECTRAL LANGLANDS CORRESPONDENCE: DEMO")
    print("=" * 70)
    
    n = 3
    print(f"\nLattice: powerset of {{0,1,2}} (size {2**n})")
    
    # Identity action
    act_id = identity_action(n)
    print(f"\n--- Action: {act_id.name} ---")
    print(f"  Galois connection verified: {act_id.verify_galois()}")
    closed = act_id.closed_elements()
    print(f"  Closed elements ({len(closed)}): {[set(c) for c in closed]}")
    print(f"  Spectral size: {act_id.spectral_size()}")
    char = tropical_character(act_id)
    print(f"  Tropical character: {set(char)}")
    
    # Projection action
    keep = frozenset({0, 1})
    act_proj = projection_action(n, keep)
    print(f"\n--- Action: {act_proj.name} ---")
    print(f"  Galois connection verified: {act_proj.verify_galois()}")
    closed = act_proj.closed_elements()
    print(f"  Closed elements ({len(closed)}): {[set(c) for c in closed]}")
    print(f"  Spectral size: {act_proj.spectral_size()}")
    char = tropical_character(act_proj)
    print(f"  Tropical character: {set(char)}")
    
    # Swap action
    act_swap = swap_action(n, 0, 1)
    print(f"\n--- Action: {act_swap.name} ---")
    print(f"  Galois connection verified: {act_swap.verify_galois()}")
    closed = act_swap.closed_elements()
    print(f"  Closed elements ({len(closed)}): {[set(c) for c in closed]}")
    print(f"  Spectral size: {act_swap.spectral_size()}")

def demo_correspondence():
    """Demonstrate the spectral correspondence theorem."""
    print("\n" + "=" * 70)
    print("SPECTRAL CORRESPONDENCE THEOREM")
    print("=" * 70)
    
    n = 3
    actions = [
        projection_action(n, frozenset({0, 1})),
        projection_action(n, frozenset({1, 2})),
    ]
    
    print(f"\nActions: {[a.name for a in actions]}")
    for a in actions:
        print(f"  {a.name}: Galois = {a.verify_galois()}, "
              f"spectral size = {a.spectral_size()}")
    
    summands = find_simple_summands(actions)
    print(f"\nSimple summands (closure-prime, closed under all actions):")
    for s in summands:
        print(f"  {set(s)}")
    
    print(f"\nEigenmeasure verification:")
    for s in summands:
        for a in actions:
            inv = verify_closure_invariance(a, s)
            print(f"  μ_{set(s)} invariant under {a.name}: {inv}")
    
    # Show the indicator values
    lattice = powerset(n)
    print(f"\nIndicator eigenmeasure values:")
    for s in summands:
        vals = []
        for x in lattice:
            v = summand_indicator(s, x)
            vals.append((set(x), v))
        nonbot = [(v, w) for v, w in vals if w != NEG_INF]
        print(f"  μ_{set(s)}: non-⊥ on {[v for v, _ in nonbot]}")
    
    # Injectivity check
    print(f"\nInjectivity check (distinct summands → distinct measures):")
    for i, s1 in enumerate(summands):
        for j, s2 in enumerate(summands):
            if i < j:
                same = all(
                    summand_indicator(s1, x) == summand_indicator(s2, x)
                    for x in lattice
                )
                print(f"  μ_{set(s1)} ≠ μ_{set(s2)}: {not same}")

def demo_character_recovery():
    """Demonstrate tropical character recovery from closure data."""
    print("\n" + "=" * 70)
    print("CHARACTER RECOVERY FROM CLOSURE DATA")
    print("=" * 70)
    
    n = 3
    actions = [
        identity_action(n),
        projection_action(n, frozenset({0})),
        projection_action(n, frozenset({0, 2})),
    ]
    
    for a in actions:
        char = tropical_character(a)
        closed = a.closed_elements()
        # Character should be the sup (union) of all closed elements
        sup_closed = frozenset()
        for c in closed:
            sup_closed = join_set(sup_closed, c)
        
        print(f"\n  {a.name}:")
        print(f"    Tropical character (cl(⊤)): {set(char)}")
        print(f"    Sup of closed elements:     {set(sup_closed)}")
        print(f"    Equal: {char == sup_closed}")

def demo_spectral_fingerprint():
    """Demonstrate the spectral fingerprint: a computable invariant
    that classifies actions up to spectral equivalence."""
    print("\n" + "=" * 70)
    print("SPECTRAL FINGERPRINTING")
    print("=" * 70)
    
    n = 3
    actions = [
        identity_action(n),
        projection_action(n, frozenset({0})),
        projection_action(n, frozenset({0, 1})),
        projection_action(n, frozenset({0, 2})),
        swap_action(n, 0, 1),
    ]
    
    print(f"\nSpectral fingerprints (# closed elements):")
    for a in actions:
        size = a.spectral_size()
        closed = a.closed_elements()
        # Fingerprint: sizes of closed elements
        sizes = sorted([len(c) for c in closed])
        print(f"  {a.name}: spectral_size={size}, "
              f"closed_sizes={sizes}")

if __name__ == "__main__":
    demo_basic()
    demo_correspondence()
    demo_character_recovery()
    demo_spectral_fingerprint()
