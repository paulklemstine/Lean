#!/usr/bin/env python3
"""
Tropical Amortization: Real-World Applications

Demonstrates how the tropical amortization framework applies to:
1. Dynamic array (std::vector) performance analysis
2. Network shortest paths via tropical matrix multiplication
3. Sequence alignment (edit distance) as tropical convolution
4. Job scheduling optimization via min-plus algebra
"""

from typing import List, Tuple
import numpy as np


# =============================================================================
# Application 1: Dynamic Array Analysis
# =============================================================================

class AmortizedDynamicArray:
    """
    Dynamic array with verified amortized O(1) insertion.

    Uses the potential method:
    - Actual cost: 1 for normal insert, n+1 for resize
    - Amortized cost: 3 per insert
    - Potential: Phi(n) = 2*size - capacity

    The tropical amortization framework guarantees:
      total_cost <= 3n for all n
    """

    def __init__(self):
        self.data = [None]
        self.size = 0
        self.capacity = 1
        self.cost_log = []
        self.potential_log = [0]  # Phi(0) = 2*0 - 1... but we adjust

    def insert(self, value) -> int:
        """Insert a value. Returns the actual cost of this operation."""
        if self.size == self.capacity:
            # Resize: O(n) copy
            cost = self.capacity + 1
            new_data = [None] * (2 * self.capacity)
            for i in range(self.size):
                new_data[i] = self.data[i]
            self.data = new_data
            self.capacity *= 2
        else:
            cost = 1

        self.data[self.size] = value
        self.size += 1
        self.cost_log.append(cost)
        # Potential: 2 * size - capacity
        phi = 2 * self.size - self.capacity
        self.potential_log.append(phi)
        return cost

    def verify_amortized_bound(self) -> bool:
        """Verify that the amortized bound holds using Theorem 1."""
        total_cost = sum(self.cost_log)
        total_amortized = 3 * len(self.cost_log)
        return total_cost <= total_amortized

    def get_analysis(self) -> dict:
        """Return detailed amortized analysis."""
        n = len(self.cost_log)
        return {
            'n_operations': n,
            'total_actual_cost': sum(self.cost_log),
            'total_amortized_cost': 3 * n,
            'amortized_ratio': sum(self.cost_log) / (3 * n) if n > 0 else 0,
            'max_single_cost': max(self.cost_log) if self.cost_log else 0,
            'final_potential': self.potential_log[-1],
            'bound_holds': self.verify_amortized_bound(),
        }


# =============================================================================
# Application 2: Tropical Matrix Multiplication for Shortest Paths
# =============================================================================

def tropical_matrix_mult(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.

    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    This computes shortest paths: if A encodes 1-hop distances and
    B encodes m-hop distances, then A ⊗ B gives (m+1)-hop distances.

    The connection to amortized analysis: the potential method's
    telescoping theorem is the scalar (1×1 matrix) case of this operation.

    Time complexity: O(n^3)
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def all_pairs_shortest_paths(adj: np.ndarray) -> np.ndarray:
    """
    All-pairs shortest paths via iterated tropical matrix multiplication.

    Uses repeated squaring: D^(2^k) in O(n^3 log n) time.
    This is the matrix-level analogue of iterated tropical convolution.
    """
    n = adj.shape[0]
    D = adj.copy()
    # Need log2(n) iterations for n vertices
    steps = int(np.ceil(np.log2(n))) + 1
    for _ in range(steps):
        D = tropical_matrix_mult(D, D)
    return D


# =============================================================================
# Application 3: Sequence Alignment as Tropical Convolution
# =============================================================================

def edit_distance_dp(s: str, t: str) -> Tuple[int, List[List[int]]]:
    """
    Edit distance via dynamic programming.

    The DP recurrence is a tropical (min-plus) operation:
      D[i,j] = min(D[i-1,j]+1, D[i,j-1]+1, D[i-1,j-1] + (0 if s[i]=t[j] else 1))

    This is tropical matrix-vector multiplication in disguise.

    Returns:
        (distance, full DP table)
    """
    m, n = len(s), len(t)
    D = [[0] * (n + 1) for _ in range(m + 1)]

    for i in range(m + 1):
        D[i][0] = i
    for j in range(n + 1):
        D[0][j] = j

    for i in range(1, m + 1):
        for j in range(1, n + 1):
            cost = 0 if s[i - 1] == t[j - 1] else 1
            D[i][j] = min(
                D[i - 1][j] + 1,      # deletion
                D[i][j - 1] + 1,      # insertion
                D[i - 1][j - 1] + cost  # substitution
            )

    return D[m][n], D


# =============================================================================
# Application 4: Job Scheduling via Min-Plus Algebra
# =============================================================================

def optimal_job_schedule(
    job_costs: List[List[int]],
    n_total: int
) -> Tuple[int, List[int]]:
    """
    Find the optimal way to split n_total tasks among multiple sequential phases.

    Each phase i has cost function job_costs[i][k] = cost of processing k items.
    The optimal total cost is the iterated tropical convolution:

      optimal = (f_1 ⋆ f_2 ⋆ ... ⋆ f_m)(n_total)

    By associativity (Theorem 6), the grouping doesn't matter.

    Returns:
        (optimal_cost, split_points)
    """
    m = len(job_costs)
    if m == 0:
        return 0, []

    # DP: dp[i][n] = min cost to process n items using phases 0..i
    max_n = n_total + 1
    dp = [[float('inf')] * max_n for _ in range(m)]

    # Base: first phase
    for n in range(min(max_n, len(job_costs[0]))):
        dp[0][n] = job_costs[0][n]

    # Iterate: tropical convolution with each subsequent phase
    for i in range(1, m):
        for n in range(max_n):
            for k in range(n + 1):
                j = n - k
                if k < len(dp[i - 1]) and j < len(job_costs[i]):
                    dp[i][n] = min(dp[i][n], dp[i - 1][k] + job_costs[i][j])

    # Backtrack to find split points
    splits = []
    remaining = n_total
    for i in range(m - 1, 0, -1):
        for k in range(remaining + 1):
            j = remaining - k
            if (k < len(dp[i - 1]) and j < len(job_costs[i]) and
                    dp[i][remaining] == dp[i - 1][k] + job_costs[i][j]):
                splits.append(j)
                remaining = k
                break
    splits.append(remaining)
    splits.reverse()

    return dp[m - 1][n_total], splits


# =============================================================================
# Main: demonstrate all applications
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Application 1: Dynamic Array Amortized Analysis")
    print("=" * 70)

    arr = AmortizedDynamicArray()
    for i in range(1000):
        arr.insert(i)

    analysis = arr.get_analysis()
    for key, val in analysis.items():
        print(f"  {key}: {val}")

    print()
    print("=" * 70)
    print("Application 2: Shortest Paths via Tropical Matrix Multiplication")
    print("=" * 70)

    # Small graph example
    INF = float('inf')
    adj = np.array([
        [0, 3, INF, 7],
        [INF, 0, 1, INF],
        [INF, INF, 0, 2],
        [INF, INF, INF, 0]
    ])
    print("Adjacency matrix:")
    print(adj)

    D = all_pairs_shortest_paths(adj)
    print("\nAll-pairs shortest paths:")
    print(D)
    print(f"\nShortest path 0→3: {D[0, 3]} (via 0→1→2→3: 3+1+2=6)")

    print()
    print("=" * 70)
    print("Application 3: Edit Distance as Tropical Computation")
    print("=" * 70)

    s, t = "kitten", "sitting"
    dist, table = edit_distance_dp(s, t)
    print(f"Edit distance('{s}', '{t}') = {dist}")
    print("DP table (each cell is a tropical min-plus computation):")
    header = "    " + " ".join(f"{c:3}" for c in " " + t)
    print(header)
    for i, row in enumerate(table):
        label = " " + s[i - 1] if i > 0 else " "
        print(f"  {label} " + " ".join(f"{v:3}" for v in row))

    print()
    print("=" * 70)
    print("Application 4: Job Scheduling via Min-Plus Convolution")
    print("=" * 70)

    # Three phases with different cost structures
    # Phase 1: setup-heavy (quadratic startup)
    phase1 = [k * k for k in range(11)]
    # Phase 2: linear processing
    phase2 = [2 * k for k in range(11)]
    # Phase 3: finishing (diminishing returns)
    phase3 = [int(10 * np.sqrt(k)) for k in range(11)]

    n_total = 10
    cost, splits = optimal_job_schedule([phase1, phase2, phase3], n_total)
    print(f"Total items: {n_total}")
    print(f"Phase costs: {phase1[:n_total + 1]}, {phase2[:n_total + 1]}, {phase3[:n_total + 1]}")
    print(f"Optimal cost: {cost}")
    print(f"Optimal split: {splits} (items per phase)")
    print(f"Verification: {phase1[splits[0]]} + {phase2[splits[1]]} + {phase3[splits[2]]} = {phase1[splits[0]] + phase2[splits[1]] + phase3[splits[2]]}")


#!/usr/bin/env python3
"""
Tropical Amortization: Demonstrations

Concrete numerical examples illustrating the main theorems:
1. Potential method telescoping
2. Accounting-potential duality
3. Min-plus convolution optimality
"""

import numpy as np


def demo_potential_method_telescoping():
    """
    Demonstrate Theorem 1: Potential method telescoping.

    Example: Dynamic array with doubling strategy.
    - Actual cost c(i) = 1 normally, c(i) = k+1 when resizing (copying k elements).
    - Amortized charge a(i) = 3 for every operation.
    - Potential Phi(n) = 2*n - capacity(n).
    """
    print("=" * 70)
    print("DEMO 1: Potential Method Telescoping (Dynamic Array)")
    print("=" * 70)

    n = 32  # number of insertions
    capacity = 1
    size = 0
    costs = []
    potentials = [0]  # Phi(0) = 0

    for i in range(n):
        if size == capacity:
            # Resize: copy all elements + insert new one
            cost = capacity + 1
            capacity *= 2
        else:
            cost = 1
        size += 1
        costs.append(cost)
        # Potential: 2 * size - capacity
        phi = 2 * size - capacity
        potentials.append(phi)

    amortized_charge = 3
    amortized = [amortized_charge] * n

    # Verify step inequality: c(i) + Phi(i+1) - Phi(i) <= a(i)
    print(f"\n{'i':>4} {'c(i)':>6} {'Phi(i)':>8} {'Phi(i+1)':>10} {'c+dPhi':>8} {'a(i)':>6} {'ok?':>5}")
    print("-" * 55)
    all_ok = True
    for i in range(n):
        c_i = costs[i]
        phi_i = potentials[i]
        phi_next = potentials[i + 1]
        amort = c_i + phi_next - phi_i
        ok = amort <= amortized[i]
        all_ok = all_ok and ok
        if i < 20 or i == n - 1:
            print(f"{i:4d} {c_i:6d} {phi_i:8d} {phi_next:10d} {amort:8d} {amortized[i]:6d} {'  ✓' if ok else '  ✗':>5}")
        elif i == 20:
            print("  ...")

    total_actual = sum(costs)
    total_amortized = sum(amortized)
    print(f"\nStep inequality holds everywhere: {all_ok}")
    print(f"Total actual cost:    {total_actual}")
    print(f"Total amortized cost: {total_amortized}")
    print(f"Phi(0) = {potentials[0]}, Phi(n) = {potentials[n]}")
    print(f"Bound from Theorem 1: sum(a) + Phi(0) - Phi(n) = {total_amortized + potentials[0] - potentials[n]}")
    print(f"Theorem 1 verified: {total_actual} <= {total_amortized + potentials[0] - potentials[n]}: {total_actual <= total_amortized + potentials[0] - potentials[n]}")
    print(f"Corollary (Phi >= 0): {total_actual} <= {total_amortized}: {total_actual <= total_amortized}")
    print()


def demo_accounting_potential_duality():
    """
    Demonstrate Theorem 2: Accounting-potential duality.

    Show that prefix domination <=> existence of nonneg potential.
    Construct the canonical witness Phi(n) = sum(a) - sum(c).
    """
    print("=" * 70)
    print("DEMO 2: Accounting-Potential Duality")
    print("=" * 70)

    # Variable cost sequence
    costs = [1, 1, 5, 1, 1, 1, 9, 1, 1, 1, 1, 1, 1, 1, 17, 1]
    n = len(costs)
    amortized_charge = 3
    amortized = [amortized_charge] * n

    # Check prefix domination (condition B)
    print(f"\n{'n':>4} {'sum(c)':>8} {'sum(a)':>8} {'Phi(n)':>8} {'sum(c)<=sum(a)?':>16}")
    print("-" * 50)
    prefix_ok = True
    canonical_phi = [0]
    sum_c, sum_a = 0, 0
    for i in range(n):
        sum_c += costs[i]
        sum_a += amortized[i]
        phi = sum_a - sum_c
        canonical_phi.append(phi)
        ok = sum_c <= sum_a
        prefix_ok = prefix_ok and ok
        print(f"{i + 1:4d} {sum_c:8d} {sum_a:8d} {phi:8d} {'✓' if ok else '✗':>16}")

    print(f"\nPrefix domination holds: {prefix_ok}")
    print(f"\nCanonical potential Phi(n) = sum(a) - sum(c):")
    print(f"  Phi = {canonical_phi}")
    print(f"  Phi(0) = {canonical_phi[0]} (should be 0)")
    print(f"  All Phi >= 0: {all(p >= 0 for p in canonical_phi)}")

    # Verify step equality: c(i) + Phi(i+1) - Phi(i) = a(i)
    print(f"\nStep equality verification:")
    for i in range(n):
        lhs = costs[i] + canonical_phi[i + 1] - canonical_phi[i]
        print(f"  c({i}) + Phi({i + 1}) - Phi({i}) = {costs[i]} + {canonical_phi[i + 1]} - {canonical_phi[i]} = {lhs} = a({i}) = {amortized[i]}: {'✓' if lhs == amortized[i] else '✗'}")
    print()


def tropical_conv(f, g, n):
    """Compute min-plus convolution (f * g)(n) = min_{0<=k<=n} (f(k) + g(n-k))."""
    return min(f(k) + g(n - k) for k in range(n + 1))


def demo_tropical_convolution():
    """
    Demonstrate Theorem 3: Min-plus convolution properties.
    """
    print("=" * 70)
    print("DEMO 3: Min-Plus (Tropical) Convolution")
    print("=" * 70)

    # Example: two quadratic cost functions
    f = lambda k: k * k
    g = lambda k: k * k

    n = 10
    conv_val = tropical_conv(f, g, n)
    print(f"\nf(k) = k^2, g(k) = k^2, n = {n}")
    print(f"\nSplit costs f(k) + g(n-k):")
    for k in range(n + 1):
        val = f(k) + g(n - k)
        marker = " <-- min" if val == conv_val else ""
        print(f"  k={k:2d}: f({k}) + g({n - k}) = {f(k):4d} + {g(n - k):4d} = {val:4d}{marker}")
    print(f"\ntropicalConv(f, g, {n}) = {conv_val}")
    print(f"Optimal split at k = {n // 2} (or {n - n // 2})")

    # Verify Theorem 4: conv <= every split
    print(f"\nTheorem 4 verification (conv <= every split):")
    for k in range(n + 1):
        ok = conv_val <= f(k) + g(n - k)
        print(f"  tropicalConv <= f({k}) + g({n - k}) = {f(k) + g(n - k)}: {'✓' if ok else '✗'}")

    # Verify Theorem 5: greatest lower bound
    h_val = conv_val  # h(n) = conv_val is achievable
    h_too_big = conv_val + 1
    all_below = all(h_val <= f(k) + g(n - k) for k in range(n + 1))
    not_all_below = all(h_too_big <= f(k) + g(n - k) for k in range(n + 1))
    print(f"\nTheorem 5 verification:")
    print(f"  h = {h_val} <= all splits: {all_below} (so h <= conv: {h_val <= conv_val} ✓)")
    print(f"  h = {h_too_big} <= all splits: {not_all_below} (violated, cannot exceed conv)")


def demo_associativity():
    """
    Demonstrate the stretch theorem: associativity of tropical convolution.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Associativity of Tropical Convolution")
    print("=" * 70)

    np.random.seed(42)
    f_vals = np.random.randint(1, 20, size=15)
    g_vals = np.random.randint(1, 20, size=15)
    h_vals = np.random.randint(1, 20, size=15)

    f = lambda k: int(f_vals[k]) if k < len(f_vals) else 10**9
    g = lambda k: int(g_vals[k]) if k < len(g_vals) else 10**9
    h = lambda k: int(h_vals[k]) if k < len(h_vals) else 10**9

    fg = lambda n: tropical_conv(f, g, n)
    gh = lambda n: tropical_conv(g, h, n)

    print(f"\nf = {list(f_vals)}")
    print(f"g = {list(g_vals)}")
    print(f"h = {list(h_vals)}")
    print(f"\n{'n':>4} {'(f*g)*h':>10} {'f*(g*h)':>10} {'equal?':>8}")
    print("-" * 36)

    all_equal = True
    for n in range(12):
        lhs = tropical_conv(fg, h, n)
        rhs = tropical_conv(f, gh, n)
        eq = lhs == rhs
        all_equal = all_equal and eq
        print(f"{n:4d} {lhs:10d} {rhs:10d} {'✓' if eq else '✗':>8}")

    print(f"\nAssociativity holds for all tested n: {all_equal}")


def demo_binary_counter():
    """
    Bonus demo: Binary counter amortized analysis.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Binary Counter — Amortized Analysis via Potential Method")
    print("=" * 70)

    n = 32
    costs = []
    potentials = [0]  # Phi(0) = popcount(0) = 0

    for i in range(n):
        # Cost of incrementing i to i+1: 1 + number of trailing 1-bits of i
        val = i
        trailing_ones = 0
        while val > 0 and val % 2 == 1:
            trailing_ones += 1
            val //= 2
        cost = 1 + trailing_ones
        costs.append(cost)

        # Potential = popcount(i+1)
        phi = bin(i + 1).count('1')
        potentials.append(phi)

    amortized_charge = 2
    amortized = [amortized_charge] * n

    print(f"\n{'i':>4} {'binary':>12} {'c(i)':>6} {'Phi(i)':>8} {'c+dPhi':>8} {'a(i)':>6}")
    print("-" * 52)
    for i in range(min(n, 20)):
        c_i = costs[i]
        dphi = potentials[i + 1] - potentials[i]
        amort = c_i + dphi
        print(f"{i:4d} {bin(i):>12} {c_i:6d} {potentials[i]:8d} {amort:8d} {amortized[i]:6d}")
    if n > 20:
        print("  ...")

    total_actual = sum(costs)
    total_amortized = sum(amortized)
    print(f"\nTotal actual cost:    {total_actual}")
    print(f"Total amortized cost: {total_amortized}")
    print(f"Ratio: {total_actual / total_amortized:.3f}")
    print(f"Amortized bound holds: {total_actual <= total_amortized}")


if __name__ == "__main__":
    demo_potential_method_telescoping()
    demo_accounting_potential_duality()
    demo_tropical_convolution()
    demo_associativity()
    demo_binary_counter()


#!/usr/bin/env python3
"""
Tropical Amortization: Visualizations

Generates publication-quality figures illustrating the main concepts:
1. Potential method telescoping
2. Accounting-potential duality
3. Tropical convolution landscape
4. Associativity verification
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
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


def viz_potential_method():
    """Visualize the potential method for a dynamic array."""
    n = 64
    costs = []
    potentials = [0]
    cap = 1
    sz = 0
    for i in range(n):
        if sz == cap:
            costs.append(cap + 1)
            cap *= 2
        else:
            costs.append(1)
        sz += 1
        potentials.append(2 * sz - cap)

    cumulative_actual = np.cumsum([0] + costs)
    cumulative_amortized = np.arange(n + 1) * 3

    fig, axes = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [2, 1]})

    # Top: cumulative costs
    ax = axes[0]
    ax.step(range(n + 1), cumulative_actual, where='post', color='#e74c3c', linewidth=2, label='Actual cumulative cost')
    ax.plot(range(n + 1), cumulative_amortized, color='#2ecc71', linewidth=2, linestyle='--', label='Amortized bound (3n)')
    ax.fill_between(range(n + 1), cumulative_actual, cumulative_amortized,
                    alpha=0.15, color='#2ecc71')
    ax.set_xlabel('Number of operations', fontsize=12)
    ax.set_ylabel('Cumulative cost', fontsize=12)
    ax.set_title('Potential Method Telescoping: Dynamic Array', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)

    # Bottom: potential function and per-operation costs
    ax2 = axes[1]
    bars = ax2.bar(range(n), costs, color=['#e74c3c' if c > 1 else '#3498db' for c in costs],
                   alpha=0.7, label='Actual cost per operation')
    ax2_twin = ax2.twinx()
    ax2_twin.plot(range(n + 1), potentials, color='#9b59b6', linewidth=2, label='Potential Φ(n)')
    ax2_twin.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    ax2.set_xlabel('Operation index', fontsize=12)
    ax2.set_ylabel('Per-operation cost', fontsize=12, color='#3498db')
    ax2_twin.set_ylabel('Potential Φ(n)', fontsize=12, color='#9b59b6')
    ax2.legend(loc='upper left', fontsize=10)
    ax2_twin.legend(loc='upper right', fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_potential_method.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_duality():
    """Visualize the accounting-potential duality."""
    costs = [1, 1, 5, 1, 1, 1, 9, 1, 1, 1, 1, 1, 1, 1, 17, 1, 1, 1, 1, 1]
    n = len(costs)
    B = 3  # amortized charge

    prefix_c = np.cumsum([0] + costs)
    prefix_a = np.arange(n + 1) * B
    phi = prefix_a - prefix_c  # canonical potential

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: prefix sums (condition B)
    ax = axes[0]
    ax.step(range(n + 1), prefix_c, where='post', color='#e74c3c', linewidth=2, label='Σ c(i) (actual)')
    ax.plot(range(n + 1), prefix_a, color='#2ecc71', linewidth=2, linestyle='--', label='Σ a(i) (amortized)')
    ax.fill_between(range(n + 1), prefix_c, prefix_a, alpha=0.15, color='#2ecc71',
                    where=prefix_a >= prefix_c)
    ax.set_xlabel('Prefix length n', fontsize=12)
    ax.set_ylabel('Cumulative cost', fontsize=12)
    ax.set_title('Prefix Domination\n(Accounting View)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: potential function (condition A)
    ax = axes[1]
    ax.fill_between(range(n + 1), 0, phi, alpha=0.3, color='#9b59b6')
    ax.plot(range(n + 1), phi, color='#9b59b6', linewidth=2, marker='o', markersize=4,
            label='Φ(n) = Σa − Σc')
    ax.axhline(y=0, color='#e74c3c', linestyle='--', linewidth=1.5, label='Φ ≥ 0 boundary')
    ax.set_xlabel('State n', fontsize=12)
    ax.set_ylabel('Potential Φ(n)', fontsize=12)
    ax.set_title('Nonneg Potential Certificate\n(Physicist View)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Accounting ↔ Potential Duality (Theorem 2)', fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_duality.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_tropical_convolution():
    """Visualize the tropical convolution landscape."""
    f = lambda k: k ** 2
    g = lambda k: (k - 5) ** 2

    n_vals = list(range(15))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: convolution for a fixed n
    n = 10
    splits = list(range(n + 1))
    split_costs = [f(k) + g(n - k) for k in splits]
    conv_val = min(split_costs)
    opt_k = split_costs.index(conv_val)

    ax = axes[0]
    ax.bar(splits, split_costs, color='#3498db', alpha=0.6, label='f(k) + g(n−k)')
    ax.bar(opt_k, split_costs[opt_k], color='#e74c3c', alpha=0.9, label=f'Optimal split k={opt_k}')
    ax.axhline(y=conv_val, color='#2ecc71', linestyle='--', linewidth=2, label=f'tropConv = {conv_val}')
    ax.set_xlabel('Split point k', fontsize=12)
    ax.set_ylabel('Split cost f(k) + g(n−k)', fontsize=12)
    ax.set_title(f'Tropical Convolution at n={n}\nf(k)=k², g(k)=(k−5)²', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: convolution function over all n
    conv_vals = []
    for n in n_vals:
        conv_vals.append(min(f(k) + g(n - k) for k in range(n + 1)))

    f_vals = [f(n) for n in n_vals]
    g_vals = [g(n) for n in n_vals]

    ax = axes[1]
    ax.plot(n_vals, f_vals, 'o-', color='#3498db', label='f(n) = n²', linewidth=1.5)
    ax.plot(n_vals, g_vals, 's-', color='#e67e22', label='g(n) = (n−5)²', linewidth=1.5)
    ax.plot(n_vals, conv_vals, 'D-', color='#e74c3c', linewidth=2.5, markersize=7,
            label='(f ⋆ g)(n) = min-plus conv')
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Min-Plus Convolution\nOptimal Compositional Cost', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_tropical_conv.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_associativity():
    """Visualize associativity of tropical convolution."""
    np.random.seed(42)
    f = np.random.randint(1, 15, size=12).tolist()
    g = np.random.randint(1, 15, size=12).tolist()
    h = np.random.randint(1, 15, size=12).tolist()

    def tconv(a, b):
        n = len(a) + len(b) - 1
        result = []
        for i in range(n):
            val = float('inf')
            for k in range(min(i + 1, len(a))):
                j = i - k
                if 0 <= j < len(b):
                    val = min(val, a[k] + b[j])
            result.append(int(val))
        return result

    fg = tconv(f, g)
    gh = tconv(g, h)
    fg_h = tconv(fg, h)
    f_gh = tconv(f, gh)

    n_vals = list(range(len(fg_h)))

    fig, ax = plt.subplots(figsize=(12, 5))

    ax.plot(n_vals, fg_h, 'o-', color='#e74c3c', linewidth=2, markersize=8,
            label='(f ⋆ g) ⋆ h', zorder=3)
    ax.plot(n_vals, f_gh, 'x--', color='#2ecc71', linewidth=2, markersize=10,
            label='f ⋆ (g ⋆ h)', zorder=4)

    # Show they're equal
    diffs = [abs(a - b) for a, b in zip(fg_h, f_gh)]
    max_diff = max(diffs)

    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Convolution value', fontsize=12)
    ax.set_title(f'Associativity of Tropical Convolution (max difference = {max_diff})',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    # Inset showing the three functions
    ax_inset = fig.add_axes([0.65, 0.55, 0.25, 0.35])
    ax_inset.bar(range(len(f)), f, alpha=0.6, color='#3498db', label='f')
    ax_inset.bar(range(len(g)), g, alpha=0.6, color='#e67e22', label='g')
    ax_inset.bar(range(len(h)), h, alpha=0.6, color='#9b59b6', label='h')
    ax_inset.set_title('Input functions', fontsize=9)
    ax_inset.legend(fontsize=8)
    ax_inset.set_xlabel('k', fontsize=8)

    fig.savefig('/workspace/request-project/viz_associativity.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1 = viz_potential_method()
    print(f"  viz_potential_method.png generated ({len(b64_1)} chars)")

    b64_2 = viz_duality()
    print(f"  viz_duality.png generated ({len(b64_2)} chars)")

    b64_3 = viz_tropical_convolution()
    print(f"  viz_tropical_conv.png generated ({len(b64_3)} chars)")

    b64_4 = viz_associativity()
    print(f"  viz_associativity.png generated ({len(b64_4)} chars)")

    print("\nAll visualizations saved.")

    # Save base64 strings for JSON package
    import json
    viz_data = {
        "potential_method": b64_1,
        "duality": b64_2,
        "tropical_conv": b64_3,
        "associativity": b64_4,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 data saved to viz_data.json")
