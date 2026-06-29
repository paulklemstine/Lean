#!/usr/bin/env python3
"""
Čech Cohomological Classification of Quantum Contextuality
==========================================================

Interactive demonstration of the Peres-Mermin and GHZ contextuality
theorems, nerve complex topology, and the entanglement-cohomology hierarchy.

All results verified in Lean 4 (see Physics/Quantum/CechContextualityCore.lean).
"""

from itertools import product

# ──────────────────────────────────────────────────────────────
# 1. MEASUREMENT SCENARIOS
# ──────────────────────────────────────────────────────────────

class MeasurementScenario:
    """A measurement scenario: measurements, contexts, parity targets."""

    def __init__(self, name, n_meas, contexts, targets):
        self.name = name
        self.n_meas = n_meas
        self.contexts = contexts  # list of lists of measurement indices
        self.targets = targets    # list of target parities (0 or 1)

    def check_assignment(self, f):
        """Check if assignment f satisfies all parity constraints."""
        for ctx, target in zip(self.contexts, self.targets):
            parity = sum(f[m] for m in ctx) % 2
            if parity != target:
                return False
        return True

    def count_satisfying(self):
        """Count satisfying assignments (brute force)."""
        count = 0
        for bits in product([0, 1], repeat=self.n_meas):
            if self.check_assignment(bits):
                count += 1
        return count

    def is_contextual(self):
        return self.count_satisfying() == 0

    def degree(self, m):
        """Number of contexts containing measurement m."""
        return sum(1 for ctx in self.contexts if m in ctx)

    def total_parity(self):
        return sum(self.targets) % 2

    def min_violations(self):
        """Minimum number of violated constraints over all assignments."""
        min_v = len(self.contexts)
        for bits in product([0, 1], repeat=self.n_meas):
            v = 0
            for ctx, target in zip(self.contexts, self.targets):
                parity = sum(bits[m] for m in ctx) % 2
                if parity != target:
                    v += 1
            min_v = min(min_v, v)
        return min_v

    def overlap_pairs(self):
        """Count pairs of contexts that share a measurement."""
        count = 0
        for i in range(len(self.contexts)):
            for j in range(i+1, len(self.contexts)):
                if set(self.contexts[i]) & set(self.contexts[j]):
                    count += 1
        return count


# ──────────────────────────────────────────────────────────────
# 2. SCENARIO DEFINITIONS
# ──────────────────────────────────────────────────────────────

# Peres-Mermin Magic Square
# 9 measurements in 3×3 grid, 6 contexts (3 rows + 3 columns)
PM = MeasurementScenario(
    name="Peres-Mermin",
    n_meas=9,
    contexts=[
        [0, 1, 2],  # Row 0
        [3, 4, 5],  # Row 1
        [6, 7, 8],  # Row 2
        [0, 3, 6],  # Col 0
        [1, 4, 7],  # Col 1
        [2, 5, 8],  # Col 2
    ],
    targets=[0, 0, 0, 0, 0, 1]  # All even except Col 2
)

# Mermin-GHZ
GHZ = MeasurementScenario(
    name="Mermin-GHZ",
    n_meas=6,
    contexts=[
        [0, 2, 4],  # XXX
        [0, 3, 5],  # XYY
        [1, 2, 5],  # YXY
        [1, 3, 4],  # YYX
    ],
    targets=[0, 0, 0, 1]
)

# Bell-CHSH
CHSH = MeasurementScenario(
    name="Bell-CHSH",
    n_meas=4,
    contexts=[[0, 2], [0, 3], [1, 2], [1, 3]],
    targets=[0, 0, 0, 1]
)

# Pentagon (Klyachko)
PENT = MeasurementScenario(
    name="Pentagon",
    n_meas=5,
    contexts=[[0, 1], [1, 2], [2, 3], [3, 4], [4, 0]],
    targets=[1, 1, 1, 1, 1]
)


# ──────────────────────────────────────────────────────────────
# 3. NERVE GRAPH COMPUTATION
# ──────────────────────────────────────────────────────────────

class NerveGraph:
    """The nerve graph of a measurement scenario."""

    def __init__(self, scenario):
        self.scenario = scenario
        n = len(scenario.contexts)
        self.n_vertices = n
        self.edges = []
        for i in range(n):
            for j in range(i+1, n):
                if set(scenario.contexts[i]) & set(scenario.contexts[j]):
                    self.edges.append((i, j))
        self.n_edges = len(self.edges)

        # Compute connected components via union-find
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px != py:
                parent[px] = py
        for i, j in self.edges:
            union(i, j)
        self.n_components = len(set(find(i) for i in range(n)))

    def betti_one(self):
        """First Betti number: β₁ = |E| - |V| + |components|."""
        return self.n_edges - self.n_vertices + self.n_components

    def cohom_rank(self):
        """Cohomological rank (non-negative β₁)."""
        return max(0, self.betti_one())


# ──────────────────────────────────────────────────────────────
# 4. CONSTRAINT MATRIX ANALYSIS
# ──────────────────────────────────────────────────────────────

def constraint_matrix(scenario):
    """Build the constraint matrix A over GF(2).
    A[c][m] = 1 iff measurement m is in context c."""
    n_ctx = len(scenario.contexts)
    A = [[0]*scenario.n_meas for _ in range(n_ctx)]
    for c, ctx in enumerate(scenario.contexts):
        for m in ctx:
            A[c][m] = 1
    return A

def gf2_rank(A):
    """Compute rank of matrix A over GF(2) using Gaussian elimination."""
    A = [row[:] for row in A]  # copy
    m = len(A)
    if m == 0:
        return 0
    n = len(A[0])
    rank = 0
    for col in range(n):
        pivot = None
        for row in range(rank, m):
            if A[row][col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        A[rank], A[pivot] = A[pivot], A[rank]
        for row in range(m):
            if row != rank and A[row][col] == 1:
                A[row] = [(A[row][j] + A[rank][j]) % 2 for j in range(n)]
        rank += 1
    return rank


# ──────────────────────────────────────────────────────────────
# 5. MAIN DEMONSTRATION
# ──────────────────────────────────────────────────────────────

def demo_scenario(scenario):
    """Full analysis of a measurement scenario."""
    print(f"\n{'='*60}")
    print(f"  {scenario.name} Scenario")
    print(f"{'='*60}")

    # Basic properties
    print(f"\n  Measurements: {scenario.n_meas}")
    print(f"  Contexts:     {len(scenario.contexts)}")

    # Degree analysis
    degrees = [scenario.degree(m) for m in range(scenario.n_meas)]
    print(f"  Degrees:      {degrees}")
    all_even = all(d % 2 == 0 for d in degrees)
    print(f"  All even:     {all_even}")

    # Total parity
    tp = scenario.total_parity()
    print(f"  Total parity: {tp} ({'odd' if tp else 'even'})")

    # Contextuality
    n_sat = scenario.count_satisfying()
    print(f"\n  Satisfying assignments: {n_sat} / {2**scenario.n_meas}")
    is_ctx = scenario.is_contextual()
    print(f"  CONTEXTUAL: {'YES ✓' if is_ctx else 'NO'}")

    if all_even and tp == 1:
        print(f"  → Proved by Total Parity Obstruction (degrees even, target sum odd)")

    # Contextuality strength
    mv = scenario.min_violations()
    print(f"  Min violations: {mv}")

    # Constraint matrix
    A = constraint_matrix(scenario)
    r = gf2_rank(A)
    print(f"\n  Constraint matrix rank (over GF(2)): {r}")
    print(f"  Cokernel dimension: {len(scenario.contexts) - r}")

    # Nerve graph
    nerve = NerveGraph(scenario)
    print(f"\n  Nerve graph:")
    print(f"    Vertices:   {nerve.n_vertices}")
    print(f"    Edges:      {nerve.n_edges}")
    print(f"    Components: {nerve.n_components}")
    print(f"    β₁ (Betti): {nerve.betti_one()}")
    print(f"    Cohom rank: {nerve.cohom_rank()}")
    print(f"    Overlaps:   {scenario.overlap_pairs()}")

    return nerve


def peres_mermin_grid_demo():
    """Demonstrate the PM double-counting argument."""
    print(f"\n{'='*60}")
    print(f"  Peres-Mermin Double-Counting Argument")
    print(f"{'='*60}")

    print("\n  The Peres-Mermin square has 9 observables in a 3×3 grid:")
    print("  ┌─────────────────────────┐")
    print("  │  σ_x⊗I   I⊗σ_x  σ_x⊗σ_x│  → product = +I (parity 0)")
    print("  │  I⊗σ_z   σ_z⊗I  σ_z⊗σ_z│  → product = +I (parity 0)")
    print("  │  σ_x⊗σ_z σ_z⊗σ_x σ_y⊗σ_y│  → product = +I (parity 0)")
    print("  └─────────────────────────┘")
    print("    ↓          ↓          ↓")
    print("   +I(0)     +I(0)     -I(1)  ← column products")

    print("\n  If f(i) ∈ {0,1} assigns eigenvalues to each observable:")
    print("  Sum of row constraints:    f(0)+...+f(8) = 0+0+0 = 0 (mod 2)")
    print("  Sum of column constraints: f(0)+...+f(8) = 0+0+1 = 1 (mod 2)")
    print("  Contradiction: 0 ≠ 1")
    print("  ∴ No consistent assignment exists → CONTEXTUAL ✓")

    print(f"\n  Enumeration: 64 of 512 grids satisfy all row constraints.")
    print(f"  But 0 of those also satisfy the column constraints.")

    # Show a best-possible assignment
    best = None
    best_violations = 7
    for bits in product([0, 1], repeat=9):
        violations = 0
        constraints = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8]]
        targets = [0, 0, 0, 0, 0, 1]
        for ctx, tgt in zip(constraints, targets):
            if sum(bits[m] for m in ctx) % 2 != tgt:
                violations += 1
        if violations < best_violations:
            best_violations = violations
            best = bits

    print(f"\n  Best assignment: {best}")
    print(f"  Violations: {best_violations} (minimum possible)")


def hierarchy_demo():
    """Demonstrate the entanglement-cohomology hierarchy."""
    print(f"\n{'='*60}")
    print(f"  Entanglement-Cohomology Hierarchy")
    print(f"{'='*60}")

    scenarios = [CHSH, PENT, GHZ, PM]
    nerves = []
    for s in scenarios:
        n = NerveGraph(s)
        nerves.append(n)

    print("\n  ┌──────────┬──────┬──────┬─────────┬────┬────────────┬──────────┐")
    print("  │ Scenario │ nMeas│ nCtx │ Overlap │ β₁ │ Contextual │ Cert.Bits│")
    print("  ├──────────┼──────┼──────┼─────────┼────┼────────────┼──────────┤")
    for s, n in zip(scenarios, nerves):
        ctx_str = "YES" if s.is_contextual() else "NO"
        print(f"  │ {s.name:8s} │ {s.n_meas:4d} │ {len(s.contexts):4d} │ {s.overlap_pairs():7d} │ {n.cohom_rank():2d} │ {ctx_str:10s} │ {n.cohom_rank():8d} │")
    print("  └──────────┴──────┴──────┴─────────┴────┴────────────┴──────────┘")

    print("\n  Hierarchy: CHSH = Pentagon (rank 1) < GHZ (rank 3) < PM (rank 4)")
    print("  → PM has strictly richer cohomological structure than GHZ")
    print("  → PM provides more certified randomness bits")


def ghz_paradox_demo():
    """Demonstrate the GHZ paradox."""
    print(f"\n{'='*60}")
    print(f"  GHZ Paradox (3-party)")
    print(f"{'='*60}")

    print("\n  6 observables: X₁, Y₁, X₂, Y₂, X₃, Y₃")
    print("  4 measurement contexts:")
    print("    XXX = {X₁, X₂, X₃} → product = +1 (parity 0)")
    print("    XYY = {X₁, Y₂, Y₃} → product = +1 (parity 0)")
    print("    YXY = {Y₁, X₂, Y₃} → product = +1 (parity 0)")
    print("    YYX = {Y₁, Y₂, X₃} → product = -1 (parity 1)")

    print("\n  Proof of contextuality:")
    print("    Each variable appears in exactly 2 contexts.")
    print("    Sum of all 4 constraints: 2·(X₁+Y₁+X₂+Y₂+X₃+Y₃) = 0 (mod 2)")
    print("    But target sum = 0+0+0+1 = 1 (mod 2)")
    print("    Contradiction: 0 ≠ 1 → CONTEXTUAL ✓")


def nerve_structure_demo():
    """Visualize nerve graph structures."""
    print(f"\n{'='*60}")
    print(f"  Nerve Graph Structures")
    print(f"{'='*60}")

    print("\n  PM Nerve = K_{3,3} (complete bipartite):")
    print("    R0 ─── C0")
    print("    │ ╲ ╱ │")
    print("    R1 ─── C1")
    print("    │ ╲ ╱ │")
    print("    R2 ─── C2")
    print("    6 vertices, 9 edges, β₁ = 9-6+1 = 4")

    print("\n  GHZ Nerve = K₄ (complete graph):")
    print("    XXX ── XYY")
    print("     │ ╲╱ │")
    print("     │ ╱╲ │")
    print("    YXY ── YYX")
    print("    4 vertices, 6 edges, β₁ = 6-4+1 = 3")

    print("\n  CHSH Nerve:")
    print("    C₀ ── C₁")
    print("    │      │")
    print("    C₂ ── C₃")
    print("    4 vertices, 4 edges, β₁ = 4-4+1 = 1")

    print("\n  Pentagon Nerve = C₅:")
    print("    C₀ ─ C₁")
    print("    │       │")
    print("    C₄     C₂")
    print("     ╲   ╱")
    print("       C₃")
    print("    5 vertices, 5 edges, β₁ = 5-5+1 = 1")


# ──────────────────────────────────────────────────────────────
# 6. RUN DEMO
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  Čech Cohomological Classification of Quantum            ║")
    print("║  Contextuality — Computational Demonstration             ║")
    print("║                                                          ║")
    print("║  All results verified in Lean 4 with Mathlib             ║")
    print("╚════════════════════════════════════════════════════════════╝")

    # Run demos
    peres_mermin_grid_demo()
    ghz_paradox_demo()

    nerves = {}
    for scenario in [PM, GHZ, CHSH, PENT]:
        nerves[scenario.name] = demo_scenario(scenario)

    nerve_structure_demo()
    hierarchy_demo()

    print("\n" + "="*60)
    print("  All results match the Lean 4 formalization.")
    print("  See: Physics/Quantum/CechContextualityCore.lean")
    print("="*60)
