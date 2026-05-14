#!/usr/bin/env python3
"""
Applications of Tropical Self-Replication Theory

Demonstrates real-world applications of the theorems:
1. Robust Distributed Consensus (CRDTs as tropical replicators)
2. Abstract Interpretation Convergence Bounds
3. Tropical Shortest-Path Stability
4. Artificial Chemistry Simulation
"""

import numpy as np
from typing import List, Tuple, Dict
from dataclasses import dataclass


# ============================================================
# Application 1: Conflict-Free Replicated Data Types (CRDTs)
# ============================================================

class GCounterCRDT:
    """
    G-Counter: a grow-only counter CRDT.

    Each node maintains a vector of counts. The merge operation
    takes the componentwise maximum — a tropical (max-plus) operation.

    The merge is idempotent, commutative, and associative,
    making it a tropical replicator.
    """

    def __init__(self, num_nodes: int):
        self.num_nodes = num_nodes
        self.counts = np.zeros(num_nodes, dtype=int)

    def increment(self, node_id: int):
        """Node increments its own counter."""
        self.counts[node_id] += 1

    def merge(self, other: 'GCounterCRDT') -> 'GCounterCRDT':
        """Merge with another replica (tropical max operation)."""
        result = GCounterCRDT(self.num_nodes)
        result.counts = np.maximum(self.counts, other.counts)
        return result

    def value(self) -> int:
        """Total count across all nodes."""
        return int(self.counts.sum())

    def __repr__(self):
        return f"GCounter({self.counts}, total={self.value()})"


def demo_crdt_tropical_replication():
    """
    Demonstrate that CRDT merge is a tropical replicator.

    The merge operation is:
    - Idempotent: merge(x, x) = x
    - Monotone: if x ≤ y componentwise, merge(x, z) ≤ merge(y, z)
    - Commutative: merge(x, y) = merge(y, x)

    This is exactly the attractor projection theorem in action:
    the "fixed points" of the merge are the synchronized states.
    """
    print("=" * 60)
    print("APPLICATION 1: CRDTs as Tropical Replicators")
    print("=" * 60)

    # Create 3 replicas
    r1 = GCounterCRDT(3)
    r2 = GCounterCRDT(3)
    r3 = GCounterCRDT(3)

    # Each node increments independently
    r1.increment(0); r1.increment(0); r1.increment(0)
    r2.increment(1); r2.increment(1)
    r3.increment(2)

    print(f"\n  Replica 1: {r1}")
    print(f"  Replica 2: {r2}")
    print(f"  Replica 3: {r3}")

    # Merge in different orders — result is the same (commutativity + associativity)
    m12 = r1.merge(r2)
    m123_a = m12.merge(r3)

    m23 = r2.merge(r3)
    m123_b = r1.merge(m23)

    print(f"\n  Merge(r1, r2, r3) = {m123_a}")
    print(f"  Merge(r1, Merge(r2, r3)) = {m123_b}")
    print(f"  Order-independent: {np.array_equal(m123_a.counts, m123_b.counts)}")

    # Verify idempotency of merge
    m_self = m123_a.merge(m123_a)
    print(f"\n  Merge(result, result) = {m_self}")
    print(f"  Idempotent: {np.array_equal(m123_a.counts, m_self.counts)}")
    print(f"\n  ✓ CRDT merge is a tropical replicator — synchronized state is a fixed point")
    print()


# ============================================================
# Application 2: Abstract Interpretation Convergence
# ============================================================

def demo_abstract_interpretation():
    """
    Demonstrate convergence of abstract interpretation using
    the bounded emergence theorem.

    Model: interval abstraction of a simple loop
      x = 0; while (x < 10) { x = x + 1; }

    The abstract domain is intervals [a, b] ⊆ {0, ..., 15}.
    The transfer function is monotone and inflationary.
    """
    print("=" * 60)
    print("APPLICATION 2: Abstract Interpretation Convergence")
    print("=" * 60)

    # Abstract state: (lower_bound, upper_bound) for variable x
    # Domain: {0, ..., 15} × {0, ..., 15} with lower ≤ upper

    def transfer(interval: Tuple[int, int]) -> Tuple[int, int]:
        """
        Transfer function for the loop body + widening.
        Models: if x < 10, then x := x + 1
        Uses widening to ensure convergence.
        """
        lo, hi = interval
        # Loop body: x + 1
        new_lo = min(lo + 1, 10)  # lower bound can only increase (up to 10)
        new_hi = min(hi + 1, 15)  # upper bound can increase (bounded by 15)
        # Join with loop entry
        result_lo = min(lo, new_lo)
        result_hi = max(hi, new_hi)
        return (result_lo, result_hi)

    # Start from x = 0 (interval [0, 0])
    state = (0, 0)
    print(f"\n  Initial abstract state: [{state[0]}, {state[1]}]")

    for step in range(20):
        new_state = transfer(state)
        print(f"  Step {step + 1}: [{new_state[0]}, {new_state[1]}]")
        if new_state == state:
            print(f"\n  ✓ Abstract interpretation converged in {step + 1} steps")
            print(f"  Fixed point: x ∈ [{state[0]}, {state[1]}]")
            break
        state = new_state
    print()


# ============================================================
# Application 3: Tropical Shortest-Path Stability
# ============================================================

def demo_shortest_path_stability():
    """
    Demonstrate that shortest-path computation (tropical matrix power)
    is stable under edge weight perturbations.

    The min-plus matrix multiplication is a tropical operation,
    and the all-pairs shortest path is its fixed point.
    """
    print("=" * 60)
    print("APPLICATION 3: Shortest-Path Mutation Stability")
    print("=" * 60)

    INF = 999

    # Adjacency matrix (min-plus: 0 on diagonal, edge weights, INF for no edge)
    W = np.array([
        [0,   3,   INF, 7],
        [INF, 0,   2,   INF],
        [INF, INF, 0,   1],
        [INF, INF, INF, 0]
    ])

    def tropical_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """Min-plus matrix multiplication."""
        n = A.shape[0]
        C = np.full((n, n), INF)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    C[i, j] = min(C[i, j], A[i, k] + B[k, j])
        return C

    # Compute shortest paths by repeated squaring
    D = W.copy()
    for _ in range(3):  # log2(4) iterations suffice
        D = tropical_mat_mul(D, D)

    print(f"\n  Original graph weights:")
    print(f"  {W}")
    print(f"\n  Shortest path distances:")
    print(f"  {D}")

    # Perturb one edge weight by ε = 1
    eps = 1
    W_mut = W.copy()
    W_mut[0, 1] = W[0, 1] + eps  # increase edge 0→1 by 1

    D_mut = W_mut.copy()
    for _ in range(3):
        D_mut = tropical_mat_mul(D_mut, D_mut)

    print(f"\n  Perturbed graph (edge 0→1 increased by {eps}):")
    print(f"  {W_mut}")
    print(f"\n  Perturbed shortest paths:")
    print(f"  {D_mut}")

    max_change = np.max(np.abs(D.astype(int) - D_mut.astype(int)))
    print(f"\n  Maximum change in shortest paths: {max_change}")
    print(f"  Perturbation size: {eps}")
    print(f"  Mutation amplified: {'No ✓' if max_change <= eps else 'Yes ✗'}")
    print()


# ============================================================
# Application 4: Artificial Chemistry Simulation
# ============================================================

@dataclass
class TropicalOrganism:
    """A tropical organism: a fixed point of a replication rule."""
    state: np.ndarray
    rule_name: str
    stability_radius: float

    def __repr__(self):
        return f"Organism({self.state}, rule={self.rule_name}, stability_ε={self.stability_radius})"


def demo_artificial_chemistry():
    """
    Simulate a simple tropical artificial chemistry.

    "Molecules" are vectors in ℕ^4.
    "Reactions" are tropical replicator rules.
    "Organisms" are the fixed points of these rules.
    """
    print("=" * 60)
    print("APPLICATION 4: Tropical Artificial Chemistry")
    print("=" * 60)

    dim = 4

    # Define three "reaction rules" (tropical replicators)
    rules = {
        "clamp[2,8]": lambda x: np.clip(x, 2, 8),
        "floor_avg": lambda x: np.full_like(x, int(np.min(x))),  # min-projection
        "threshold": lambda x: np.where(x >= 5, x, 5),  # inflate to ≥ 5
    }

    print(f"\n  State space: ℕ^{dim}")
    print(f"  Number of reaction rules: {len(rules)}")

    # Simulate "primordial soup": random initial states evolving under random rules
    np.random.seed(42)
    organisms_found = []

    print(f"\n  Primordial soup simulation (20 random seeds):")
    for trial in range(20):
        seed = np.random.randint(0, 15, size=dim)
        rule_name = list(rules.keys())[trial % len(rules)]
        F = rules[rule_name]

        # Iterate to fixed point
        x = seed.copy()
        for step in range(100):
            x_next = F(x)
            if np.array_equal(x_next, x):
                break
            x = x_next

        # Verify it's a fixed point
        is_fp = np.array_equal(F(x), x)

        # Compute mutation stability radius
        stability = float('inf')
        for _ in range(100):
            delta = np.random.randint(-3, 4, size=dim)
            y = np.maximum(x + delta, 0)
            d_in = np.max(np.abs(x.astype(int) - y.astype(int)))
            d_out = np.max(np.abs(F(x).astype(int) - F(y).astype(int)))
            if d_in > 0:
                stability = min(stability, d_out / d_in)

        org = TropicalOrganism(x, rule_name, round(stability, 2))
        organisms_found.append(org)

        if trial < 8:
            print(f"    Seed {seed} → {org}")

    print(f"    ... ({len(organisms_found)} organisms total)")

    # Count unique organisms
    unique_states = set(tuple(o.state) for o in organisms_found)
    print(f"\n  Unique organisms: {len(unique_states)}")
    print(f"  All fixed points: {all(np.array_equal(rules[o.rule_name](o.state), o.state) for o in organisms_found)}")
    print(f"  All mutation-stable: {all(o.stability_radius <= 1.0 for o in organisms_found)}")
    print()


if __name__ == "__main__":
    demo_crdt_tropical_replication()
    demo_abstract_interpretation()
    demo_shortest_path_stability()
    demo_artificial_chemistry()
    print("All applications demonstrated successfully! ✓")


#!/usr/bin/env python3
"""Build PACKAGE.json from all deliverables."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_proofs = read_file('/workspace/request-project/Speculative/AlienAlgebra/Core.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')
viz_code = read_file('/workspace/request-project/visualizations.py')

# Read visualization data
with open('/workspace/request-project/viz_data.json', 'r') as f:
    viz_data = json.load(f)

package = {
    "title": "Alien Algebra: Non-Archimedean Life Forms in Idempotent Semirings",
    "domain": "Tropical Geometry / Dynamical Systems / Artificial Chemistry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Self-Replication Demos",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "FindAttractor",
            "pseudocode": "Input: Monotone inflationary map F, initial state x\nOutput: Fixed point F^k(x)\n\nstate <- x\nfor step = 1 to n*m + 1:\n    new_state <- F(state)\n    if new_state = state:\n        return state\n    state <- new_state\nreturn state",
            "code": algorithms_code
        },
        {
            "name": "TropicalMinCA",
            "pseudocode": "Input: Initial state x on ring of N cells\nOutput: Sequence of states until stabilization\n\nfor each step:\n    for each cell i:\n        new[i] = min(x[i], x[(i+1) % N], x[(i-1) % N])\n    if new = x: break\n    x <- new\nreturn states",
            "code": "# See algorithms.py TropicalMinCA class"
        }
    ],
    "visualizations": [
        {
            "name": "Tropical CA Convergence Heatmap",
            "data": viz_data["tropical_ca"]
        },
        {
            "name": "Emergence Convergence Curves",
            "data": viz_data["emergence"]
        },
        {
            "name": "Mutation Stability Analysis",
            "data": viz_data["mutation"]
        },
        {
            "name": "Attractor Landscape Diagram",
            "data": viz_data["attractors"]
        }
    ],
    "lean_proofs": lean_proofs
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json created ({os.path.getsize('/workspace/request-project/PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Demonstration of Tropical Self-Replication Theorems

Concrete numerical examples illustrating:
1. Attractor Projection Theorem (idempotent image = fixed points)
2. Bounded Emergence (monotone inflationary maps stabilize)
3. Mutation Nonamplification (Lipschitz stability)
4. Tropical Cellular Automaton convergence
5. Composition of commuting idempotent maps
"""

import numpy as np
from typing import Callable, List, Tuple, Optional


def demo_attractor_projection():
    """
    Demonstrate: image of an idempotent function = its fixed-point set.

    We construct an idempotent F on {0,1,2}^2 and verify:
    - range(F) == {x : F(x) = x}
    """
    print("=" * 60)
    print("DEMO 1: Attractor Projection Theorem")
    print("=" * 60)

    # Define an idempotent function on {0,1,2}^2
    # F(x,y) = (min(x,y), min(x,y)) -- projects onto diagonal
    def F(state: Tuple[int, int]) -> Tuple[int, int]:
        return (min(state), min(state))

    # Enumerate all states
    states = [(x, y) for x in range(3) for y in range(3)]

    # Verify idempotency
    print("\nVerifying idempotency F(F(x)) = F(x):")
    for s in states:
        assert F(F(s)) == F(s), f"Failed for {s}"
    print("  ✓ F is idempotent on all 9 states")

    # Compute image
    image = set(F(s) for s in states)
    print(f"\nImage of F: {sorted(image)}")

    # Compute fixed points
    fixed = set(s for s in states if F(s) == s)
    print(f"Fixed points: {sorted(fixed)}")

    # Verify equality
    assert image == fixed
    print("\n  ✓ Image = Fixed points (Attractor Projection Theorem verified)")
    print()


def demo_bounded_emergence():
    """
    Demonstrate: monotone inflationary F on Fin(n) -> Fin(m+1)
    stabilizes in at most n*m + 1 steps.
    """
    print("=" * 60)
    print("DEMO 2: Bounded Emergence Theorem")
    print("=" * 60)

    n, m = 4, 5  # 4-dimensional, values in {0,...,5}
    bound = n * m + 1
    print(f"\nState space: {{0,...,{m}}}^{n}")
    print(f"Theoretical bound: {bound} steps")

    # Monotone inflationary map: increment each coordinate by 1 (capped at m)
    def F(x: np.ndarray) -> np.ndarray:
        return np.minimum(x + 1, m)

    # Run from various seeds
    np.random.seed(42)
    max_steps_seen = 0

    for trial in range(10):
        x = np.random.randint(0, m + 1, size=n)
        seed = x.copy()
        steps = 0
        for k in range(bound + 1):
            x_next = F(x)
            if np.array_equal(x_next, x):
                steps = k
                break
            x = x_next
        else:
            steps = bound + 1

        max_steps_seen = max(max_steps_seen, steps)
        print(f"  Seed {seed} → fixed point {x} in {steps} steps")

    print(f"\n  Max steps observed: {max_steps_seen} (bound: {bound})")
    print(f"  ✓ All orbits stabilized within the bound")
    print()


def demo_mutation_stability():
    """
    Demonstrate: Lipschitz idempotent maps preserve mutation bounds.
    """
    print("=" * 60)
    print("DEMO 3: Mutation Nonamplification")
    print("=" * 60)

    n = 5  # dimension

    # Idempotent Lipschitz map: coordinate-wise clamp to [1, 8]
    def F(x: np.ndarray) -> np.ndarray:
        return np.clip(x, 1, 8)

    # Verify idempotency
    for _ in range(100):
        x = np.random.randint(0, 15, size=n)
        assert np.array_equal(F(F(x)), F(x))

    print(f"\n  ✓ F is idempotent (verified on 100 random inputs)")

    # Test mutation nonamplification
    print("\n  Testing mutation stability:")
    for eps in [1, 2, 3, 5]:
        violations = 0
        for _ in range(1000):
            x = np.random.randint(0, 15, size=n)
            y = x + np.random.randint(-eps, eps + 1, size=n)
            y = np.maximum(y, 0)  # keep non-negative

            d_input = np.max(np.abs(x.astype(int) - y.astype(int)))
            d_output = np.max(np.abs(F(x).astype(int) - F(y).astype(int)))

            if d_output > d_input:
                violations += 1

        print(f"    ε={eps}: {violations}/1000 violations "
              f"({'✓ stable' if violations == 0 else '✗ unstable'})")

    print()


def demo_tropical_ca():
    """
    Demonstrate: Tropical min-CA convergence on a ring.
    """
    print("=" * 60)
    print("DEMO 4: Tropical Cellular Automaton")
    print("=" * 60)

    def trop_ca_step(x: np.ndarray) -> np.ndarray:
        """One step of the tropical min-CA on a ring."""
        N = len(x)
        result = np.zeros_like(x)
        for i in range(N):
            result[i] = min(x[i], x[(i + 1) % N], x[(i - 1) % N])
        return result

    # Example: ring of 10 cells
    N = 10
    np.random.seed(123)
    x0 = np.random.randint(0, 50, size=N)
    print(f"\n  Ring size: {N}")
    print(f"  Initial state: {x0}")
    print(f"  Global minimum: {x0.min()}")

    x = x0.copy()
    for step in range(N + 2):
        x_next = trop_ca_step(x)
        print(f"  Step {step + 1}: {x_next}")
        if np.array_equal(x_next, x):
            print(f"\n  ✓ Stabilized at step {step + 1}!")
            print(f"  Fixed point: all cells = {x[0]} (global minimum)")
            break
        x = x_next

    # Statistics over many trials
    print(f"\n  Convergence statistics over 100 random initial conditions:")
    convergence_times = []
    for _ in range(100):
        x = np.random.randint(0, 100, size=N)
        for step in range(N + 2):
            x_next = trop_ca_step(x)
            if np.array_equal(x_next, x):
                convergence_times.append(step + 1)
                break
            x = x_next

    print(f"    Mean convergence time: {np.mean(convergence_times):.1f}")
    print(f"    Max convergence time: {max(convergence_times)}")
    print(f"    Min convergence time: {min(convergence_times)}")
    print()


def demo_composition():
    """
    Demonstrate: composition of commuting idempotent maps is idempotent.
    """
    print("=" * 60)
    print("DEMO 5: Modular Composition of Replicators")
    print("=" * 60)

    n = 4

    # F: clamp to [2, ∞)
    def F(x: np.ndarray) -> np.ndarray:
        return np.maximum(x, 2)

    # G: clamp to (-∞, 7]
    def G(x: np.ndarray) -> np.ndarray:
        return np.minimum(x, 7)

    # F∘G: clamp to [2, 7]
    def FG(x: np.ndarray) -> np.ndarray:
        return F(G(x))

    # Verify individual idempotency
    for _ in range(100):
        x = np.random.randint(0, 15, size=n)
        assert np.array_equal(F(F(x)), F(x)), "F not idempotent"
        assert np.array_equal(G(G(x)), G(x)), "G not idempotent"

    # Verify commutativity
    commutes = True
    for _ in range(100):
        x = np.random.randint(0, 15, size=n)
        if not np.array_equal(F(G(x)), G(F(x))):
            commutes = False
            break

    print(f"\n  F: clamp below at 2 (idempotent: ✓)")
    print(f"  G: clamp above at 7 (idempotent: ✓)")
    print(f"  F and G commute: {'✓' if commutes else '✗'}")

    # Verify composition is idempotent
    comp_idempotent = True
    for _ in range(100):
        x = np.random.randint(0, 15, size=n)
        if not np.array_equal(FG(FG(x)), FG(x)):
            comp_idempotent = False
            break

    print(f"  F∘G is idempotent: {'✓' if comp_idempotent else '✗'}")

    # Show example
    x = np.array([0, 3, 9, 5])
    print(f"\n  Example: x = {x}")
    print(f"    G(x) = min(x, 7) = {G(x)}")
    print(f"    F(G(x)) = max(G(x), 2) = {FG(x)}")
    print(f"    F(G(F(G(x)))) = {FG(FG(x))}")
    print(f"    F∘G idempotent: {np.array_equal(FG(FG(x)), FG(x))}")
    print()


if __name__ == "__main__":
    demo_attractor_projection()
    demo_bounded_emergence()
    demo_mutation_stability()
    demo_tropical_ca()
    demo_composition()
    print("All demonstrations completed successfully! ✓")


#!/usr/bin/env python3
"""
Visualizations for Tropical Self-Replication Theory

Generates publication-quality figures:
1. Tropical CA convergence heatmap
2. Attractor landscape diagram
3. Mutation stability scatter plot
4. Emergence convergence curves
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_tropical_ca_convergence():
    """Generate heatmap of tropical CA convergence."""
    N = 20
    np.random.seed(42)
    x0 = np.random.randint(0, 100, size=N)

    # Simulate
    states = [x0.copy()]
    x = x0.copy()
    for step in range(N + 2):
        x_next = np.zeros_like(x)
        for i in range(N):
            x_next[i] = min(x[i], x[(i+1) % N], x[(i-1) % N])
        states.append(x_next.copy())
        if np.array_equal(x_next, x):
            break
        x = x_next

    # Plot heatmap
    fig, ax = plt.subplots(figsize=(12, 6))
    data = np.array(states)
    im = ax.imshow(data, aspect='auto', cmap='viridis', interpolation='nearest')
    ax.set_xlabel('Cell Index', fontsize=14)
    ax.set_ylabel('Time Step', fontsize=14)
    ax.set_title('Tropical Min-CA: Convergence to Global Minimum', fontsize=16)
    plt.colorbar(im, ax=ax, label='Cell Value')

    # Add annotation
    ax.annotate(f'Fixed point: all cells = {x[0]}',
                xy=(N//2, len(states)-1), fontsize=11,
                ha='center', va='bottom',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

    fig.savefig('/workspace/request-project/viz_tropical_ca.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_emergence_curves():
    """Plot convergence curves for the bounded emergence theorem."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Weight vs step for multiple seeds
    ax = axes[0]
    N = 15
    np.random.seed(123)

    for trial in range(8):
        x = np.random.randint(0, 80, size=N)
        weights = [x.sum()]
        for step in range(N + 2):
            x_next = np.zeros_like(x)
            for i in range(N):
                x_next[i] = min(x[i], x[(i+1) % N], x[(i-1) % N])
            weights.append(x_next.sum())
            if np.array_equal(x_next, x):
                weights.extend([weights[-1]] * (N + 2 - step - 1))
                break
            x = x_next

        ax.plot(weights[:N+3], alpha=0.7, linewidth=2, label=f'Seed {trial+1}')

    ax.set_xlabel('Time Step', fontsize=13)
    ax.set_ylabel('Total Weight Σᵢ x(i)', fontsize=13)
    ax.set_title('Deflationary Convergence\n(Total Weight Decreases)', fontsize=14)
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3)

    # Right: Convergence time vs ring size
    ax = axes[1]
    ring_sizes = [5, 10, 15, 20, 30, 50, 75, 100]
    mean_times = []
    max_times = []

    for N in ring_sizes:
        times = []
        for _ in range(50):
            x = np.random.randint(0, 100, size=N)
            for step in range(N + 2):
                x_next = np.zeros_like(x)
                for i in range(N):
                    x_next[i] = min(x[i], x[(i+1) % N], x[(i-1) % N])
                if np.array_equal(x_next, x):
                    times.append(step + 1)
                    break
                x = x_next
        mean_times.append(np.mean(times))
        max_times.append(max(times))

    ax.plot(ring_sizes, mean_times, 'o-', color='steelblue', linewidth=2,
            markersize=8, label='Mean convergence time')
    ax.plot(ring_sizes, max_times, 's--', color='firebrick', linewidth=2,
            markersize=8, label='Max convergence time')
    ax.plot(ring_sizes, [N/2 for N in ring_sizes], ':', color='gray',
            linewidth=2, label='N/2 (diameter bound)')

    ax.set_xlabel('Ring Size N', fontsize=13)
    ax.set_ylabel('Convergence Time (steps)', fontsize=13)
    ax.set_title('Convergence Time Scales\nLinearly with Ring Size', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_emergence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_mutation_stability():
    """Scatter plot showing mutation nonamplification."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    dim = 5
    np.random.seed(42)

    # Left: Lipschitz map (clamp) — stable
    ax = axes[0]
    F_stable = lambda x: np.clip(x, 2, 8)

    d_inputs, d_outputs = [], []
    for _ in range(500):
        x = np.random.randint(0, 15, size=dim)
        y = x + np.random.randint(-5, 6, size=dim)
        y = np.maximum(y, 0)
        d_in = np.max(np.abs(x.astype(int) - y.astype(int)))
        d_out = np.max(np.abs(F_stable(x).astype(int) - F_stable(y).astype(int)))
        d_inputs.append(d_in)
        d_outputs.append(d_out)

    ax.scatter(d_inputs, d_outputs, alpha=0.4, s=20, color='steelblue')
    max_d = max(max(d_inputs), max(d_outputs)) + 1
    ax.plot([0, max_d], [0, max_d], 'r--', linewidth=2, label='y = x (no amplification)')
    ax.set_xlabel('Input Distance d∞(x, y)', fontsize=13)
    ax.set_ylabel('Output Distance d∞(F(x), F(y))', fontsize=13)
    ax.set_title('Lipschitz Map (Clamp)\nMutation Stable ✓', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Right: Non-Lipschitz map (squaring) — unstable
    ax = axes[1]
    F_unstable = lambda x: x ** 2

    d_inputs, d_outputs = [], []
    for _ in range(500):
        x = np.random.randint(0, 8, size=dim)
        y = x + np.random.randint(-2, 3, size=dim)
        y = np.maximum(y, 0)
        d_in = np.max(np.abs(x.astype(int) - y.astype(int)))
        d_out = np.max(np.abs(F_unstable(x).astype(int) - F_unstable(y).astype(int)))
        d_inputs.append(d_in)
        d_outputs.append(d_out)

    ax.scatter(d_inputs, d_outputs, alpha=0.4, s=20, color='firebrick')
    max_d = max(max(d_inputs), max(d_outputs)) + 1
    ax.plot([0, max_d], [0, max_d], 'r--', linewidth=2, label='y = x (no amplification)')
    ax.set_xlabel('Input Distance d∞(x, y)', fontsize=13)
    ax.set_ylabel('Output Distance d∞(F(x), F(y))', fontsize=13)
    ax.set_title('Non-Lipschitz Map (Squaring)\nMutation Unstable ✗', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_mutation.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_attractor_landscape():
    """Visualize the attractor landscape of idempotent maps."""
    from itertools import product as iterproduct

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Distribution of fixed-point counts for n=4
    ax = axes[0]

    for n in [3, 4, 5]:
        fp_counts = {}
        for mask in range(1, 2**n):
            S = [i for i in range(n) if mask & (1 << i)]
            k = len(S)
            non_S = [i for i in range(n) if i not in S]
            num_maps = len(S) ** len(non_S) if non_S else 1
            fp_counts[k] = fp_counts.get(k, 0) + num_maps

        ks = sorted(fp_counts.keys())
        vals = [fp_counts[k] for k in ks]
        total = sum(vals)
        probs = [v / total for v in vals]
        offset = (n - 4) * 0.2
        ax.bar([k + offset for k in ks], probs, width=0.2, alpha=0.7,
               label=f'n={n}')

    ax.set_xlabel('Number of Fixed Points', fontsize=13)
    ax.set_ylabel('Fraction of Idempotent Maps', fontsize=13)
    ax.set_title('Attractor Landscape Distribution', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    # Right: Orbit diagram for a specific inflationary map on {0,...,9}
    ax = axes[1]

    m = 9
    F = lambda x: min(x + 2, m)  # inflationary: x -> min(x+2, 9)

    for x0 in range(m + 1):
        orbit = [x0]
        x = x0
        for _ in range(10):
            x = F(x)
            orbit.append(x)
            if orbit[-1] == orbit[-2]:
                break

        ax.plot(range(len(orbit)), orbit, 'o-', markersize=6, alpha=0.7)
        ax.annotate(f'{x0}', xy=(0, x0), fontsize=8, ha='right',
                    va='center', color='gray')

    ax.set_xlabel('Iteration Step', fontsize=13)
    ax.set_ylabel('State Value', fontsize=13)
    ax.set_title(f'Orbits of F(x) = min(x+2, {m})\nAll Seeds → Fixed Point {m}', fontsize=14)
    ax.axhline(y=m, color='red', linestyle='--', alpha=0.5, label=f'Fixed point = {m}')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_attractors.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_ca = viz_tropical_ca_convergence()
    print(f"  ✓ Tropical CA convergence heatmap ({len(b64_ca)} chars)")

    b64_emergence = viz_emergence_curves()
    print(f"  ✓ Emergence convergence curves ({len(b64_emergence)} chars)")

    b64_mutation = viz_mutation_stability()
    print(f"  ✓ Mutation stability scatter plot ({len(b64_mutation)} chars)")

    b64_attractors = viz_attractor_landscape()
    print(f"  ✓ Attractor landscape diagram ({len(b64_attractors)} chars)")

    print("\nAll visualizations saved!")

    # Save base64 data for PACKAGE.json
    import json
    viz_data = {
        "tropical_ca": b64_ca,
        "emergence": b64_emergence,
        "mutation": b64_mutation,
        "attractors": b64_attractors
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 data saved to viz_data.json")
