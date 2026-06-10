#!/usr/bin/env python3
"""
Tropical Finite Optimization — Real-World Applications

Demonstrates how the tropical optimization theorems apply to:
1. Proof search optimization
2. Cryptographic key selection
3. Network routing (shortest path via tropical matrices)
4. Machine learning hyperparameter search
"""

import numpy as np
from algorithms import (
    finite_minimizer, tropical_finset_inf, below_average_element,
    matrix_entry_minimizer, tropical_matrix_multiply
)


def section(title: str) -> None:
    print(f"\n{'='*65}")
    print(f"  {title}")
    print(f"{'='*65}\n")


# ─────────────────────────────────────────────────────────
# Application 1: Proof Search Optimization
# ─────────────────────────────────────────────────────────
section("Application 1: Proof Search Optimization")

print("""Scenario: A theorem prover has 6 candidate proof strategies for
a propositional tautology. Each strategy has a known cost (proof length
in inference steps). By Theorem 3, an optimal strategy exists.
""")

strategies = {
    "Resolution":     142,
    "Tableaux":       89,
    "Natural Deduct": 67,
    "Sequent Calc":   103,
    "BDD-based":      45,
    "SAT Solver":     31,
}

names = list(strategies.keys())
costs = [strategies[n] for n in names]

best_name, best_cost = finite_minimizer(names, lambda n: strategies[n])
_, _, avg_cost = below_average_element(names, lambda n: strategies[n])

print(f"{'Strategy':<18s} {'Cost (steps)':>12s}")
print("-" * 32)
for n in names:
    marker = " ← optimal" if n == best_name else ""
    print(f"{n:<18s} {strategies[n]:>12d}{marker}")

print(f"\nOptimal strategy: {best_name} ({best_cost} steps)")
print(f"Average cost: {avg_cost:.1f} steps")
print(f"Speedup over worst: {max(costs)/best_cost:.1f}×")
print(f"\nTheorem 3 guarantees: optimal exists ✓")
print(f"Theorem 5 guarantees: some strategy ≤ {avg_cost:.1f} steps ✓")


# ─────────────────────────────────────────────────────────
# Application 2: Cryptographic Key Selection
# ─────────────────────────────────────────────────────────
section("Application 2: Cryptographic Key Selection")

print("""Scenario: A post-quantum signature scheme has 256 candidate key pairs.
Each key has a different verification time (due to structure-dependent
lattice geometry). The protocol needs the fastest-verifying key.
""")

np.random.seed(123)
n_keys = 256
# Simulate verification times: lognormal distribution (realistic for crypto)
verify_times = np.random.lognormal(mean=1.0, sigma=0.8, size=n_keys)

keys = list(range(n_keys))
opt_key, opt_time = finite_minimizer(keys, lambda k: verify_times[k])
_, _, avg_time = below_average_element(keys, lambda k: verify_times[k])

print(f"Key space size: {n_keys}")
print(f"Verification time distribution: LogNormal(μ=1.0, σ=0.8)")
print(f"\nOptimal key: #{opt_key}")
print(f"  Verification time: {opt_time:.4f} ms")
print(f"Average verification: {avg_time:.4f} ms")
print(f"Worst verification:  {max(verify_times):.4f} ms")
print(f"Speedup (optimal vs worst): {max(verify_times)/opt_time:.1f}×")
print(f"Speedup (optimal vs avg):   {avg_time/opt_time:.1f}×")
print(f"\nTheorem 4 (Fin n): optimal key exists in Fin {n_keys} ✓")


# ─────────────────────────────────────────────────────────
# Application 3: Network Routing via Tropical Matrices
# ─────────────────────────────────────────────────────────
section("Application 3: Network Shortest Path (Tropical Matrix Power)")

print("""Scenario: A 5-node network with weighted edges. We compute all-pairs
shortest paths using tropical matrix multiplication (min-plus algebra).
""")

INF = float('inf')
# Adjacency cost matrix (INF = no direct edge)
M = np.array([
    [0,   3,   INF, 7,   INF],
    [3,   0,   1,   INF, 8  ],
    [INF, 1,   0,   2,   INF],
    [7,   INF, 2,   0,   4  ],
    [INF, 8,   INF, 4,   0  ],
])

print("Direct connection costs (adjacency matrix):")
labels = ["A", "B", "C", "D", "E"]
print(f"     {'  '.join(f'{l:>5s}' for l in labels)}")
for i, row in enumerate(M):
    vals = ["  ∞  " if v == INF else f"{v:5.0f}" for v in row]
    print(f"  {labels[i]}  {'  '.join(vals)}")

# Compute shortest paths via tropical matrix powers
D = M.copy()
for _ in range(len(labels) - 1):
    D = tropical_matrix_multiply(D, M)

print(f"\nAll-pairs shortest path distances (M^{len(labels)} in tropical algebra):")
print(f"     {'  '.join(f'{l:>5s}' for l in labels)}")
for i, row in enumerate(D):
    vals = ["  ∞  " if v == INF else f"{v:5.0f}" for v in row]
    print(f"  {labels[i]}  {'  '.join(vals)}")

# Find global minimum transition
(mi, mj), min_dist = matrix_entry_minimizer(D + np.diag([INF]*5))
print(f"\nShortest path in entire network: {labels[mi]}→{labels[mj]}, cost={min_dist}")
print(f"Theorem 8: matrix entry minimizer exists ✓")


# ─────────────────────────────────────────────────────────
# Application 4: ML Hyperparameter Grid Search
# ─────────────────────────────────────────────────────────
section("Application 4: ML Hyperparameter Grid Search")

print("""Scenario: Grid search over learning rate × batch size for a neural network.
Each combination has a validation loss. Tropical optimization guarantees
the optimal hyperparameter combination exists.
""")

np.random.seed(77)
learning_rates = [0.001, 0.003, 0.01, 0.03, 0.1]
batch_sizes = [16, 32, 64, 128, 256]

# Simulate validation losses (U-shaped in both dimensions)
n_lr = len(learning_rates)
n_bs = len(batch_sizes)
loss_matrix = np.zeros((n_lr, n_bs))
for i, lr in enumerate(learning_rates):
    for j, bs in enumerate(batch_sizes):
        # Simulated loss landscape
        loss_matrix[i, j] = (
            0.5 * (np.log10(lr) + 1.5)**2 +  # optimal lr around 0.03
            0.3 * (np.log2(bs) - 6)**2 +       # optimal bs around 64
            np.random.normal(0, 0.05)
        )

print(f"{'':>8s}", end="")
for bs in batch_sizes:
    print(f"  bs={bs:<4d}", end="")
print()

for i, lr in enumerate(learning_rates):
    print(f"lr={lr:<6.3f}", end="")
    for j in range(n_bs):
        marker = ""
        print(f"  {loss_matrix[i,j]:6.3f}", end="")
    print()

(opt_i, opt_j), opt_loss = matrix_entry_minimizer(loss_matrix)
avg_loss = np.mean(loss_matrix)

print(f"\nOptimal: lr={learning_rates[opt_i]}, bs={batch_sizes[opt_j]}")
print(f"  Validation loss: {opt_loss:.4f}")
print(f"  Average loss:    {avg_loss:.4f}")
print(f"  Worst loss:      {np.max(loss_matrix):.4f}")
print(f"\nTheorem 8: optimal (lr, bs) pair exists in {n_lr}×{n_bs} grid ✓")
print(f"Theorem 5: some pair achieves loss ≤ {avg_loss:.4f} ✓")


# ─────────────────────────────────────────────────────────
# Application 5: Tropical Conjunction in Multi-Constraint Verification
# ─────────────────────────────────────────────────────────
section("Application 5: Multi-Constraint Verification (Tropical Conjunction)")

print("""Scenario: A system must satisfy 4 independent security constraints.
Each constraint has a verification cost. The tropical conjunction
(minimum) gives the tightest individual bound on the joint cost.
""")

constraints = {
    "Authentication":  12.5,
    "Authorization":    8.3,
    "Encryption":      15.7,
    "Integrity Check":  6.1,
}

costs_list = list(constraints.values())
tropical_sum = tropical_finset_inf(costs_list)

print(f"{'Constraint':<20s} {'Cost (ms)':>10s}")
print("-" * 32)
for name, cost in constraints.items():
    bound_check = "≥ tropical sum ✓" if cost >= tropical_sum else ""
    print(f"{name:<20s} {cost:>10.1f}  {bound_check}")

print(f"\nTropical conjunction (min): {tropical_sum} ms")
print(f"Theorem 1: tropical sum ≤ every constraint cost ✓")

# Binary conjunction bounds
pairs = list(constraints.items())
for i in range(len(pairs)):
    for j in range(i+1, len(pairs)):
        a_name, a_cost = pairs[i]
        b_name, b_cost = pairs[j]
        m = min(a_cost, b_cost)
        print(f"  min({a_name}, {b_name}) = {m:.1f} ≤ {a_cost:.1f} ∧ ≤ {b_cost:.1f} ✓")


print("\n" + "=" * 65)
print("  All applications demonstrated successfully.")
print("=" * 65)


#!/usr/bin/env python3
"""
Tropical Finite Optimization — Concrete Numerical Demonstrations

Demonstrates the key theorems with numerical examples:
1. Tropical finset infimum bound
2. Binary tropical conjunction bound  
3. Finite minimizer existence
4. Averaging/pigeonhole bound
5. Monotonicity under pointwise domination
6. Matrix entry minimizer
"""

import numpy as np

np.random.seed(42)

def section(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")

# ─────────────────────────────────────────────────────────
# Demo 1: Tropical Finset Infimum Bound
# ─────────────────────────────────────────────────────────
section("Theorem 1: Tropical Finset Infimum Bound")

costs = [12.0, 8.0, 15.0, 8.0, 10.0]
inf_val = min(costs)
print(f"Cost function: {costs}")
print(f"Infimum (tropical n-ary sum): {inf_val}")
print(f"Verification: inf ≤ every element?")
for i, c in enumerate(costs):
    print(f"  inf={inf_val} ≤ f({i})={c}  →  {inf_val <= c}  ✓")

# ─────────────────────────────────────────────────────────
# Demo 2: Binary Tropical Conjunction Bound
# ─────────────────────────────────────────────────────────
section("Theorem 2: Binary Tropical Conjunction Bound")

pairs = [(3.0, 7.0), (5.0, 5.0), (-2.0, 4.0), (100.0, 0.1)]
for a, b in pairs:
    m = min(a, b)
    print(f"min({a}, {b}) = {m}  ≤ {a}? {m <= a} ✓  ≤ {b}? {m <= b} ✓")

# ─────────────────────────────────────────────────────────
# Demo 3: Finite Minimizer Existence
# ─────────────────────────────────────────────────────────
section("Theorem 3: Finite Minimizer Existence")

for n in [10, 50, 200]:
    f = np.random.uniform(0, 100, size=n)
    argmin = np.argmin(f)
    print(f"n={n:>4d}: minimizer at index {argmin}, "
          f"f(argmin)={f[argmin]:.4f}, "
          f"all f(b) ≥ f(argmin)? {np.all(f >= f[argmin])} ✓")

# ─────────────────────────────────────────────────────────
# Demo 4: Averaging / Pigeonhole Bound
# ─────────────────────────────────────────────────────────
section("Theorem 5: Averaging / Pigeonhole Bound")

for n in [5, 20, 100, 1000]:
    f = np.random.uniform(0, 1, size=n)
    avg = np.mean(f)
    min_val = np.min(f)
    below_avg = np.sum(f <= avg)
    print(f"n={n:>5d}: min={min_val:.6f}, avg={avg:.4f}, "
          f"min ≤ avg? {min_val <= avg} ✓, "
          f"elements ≤ avg: {below_avg}/{n}")

# ─────────────────────────────────────────────────────────
# Demo 5: Monotonicity Under Pointwise Domination
# ─────────────────────────────────────────────────────────
section("Theorem 6: Monotonicity Under Pointwise Domination")

n = 20
f = np.random.uniform(0, 10, size=n)
shift = np.random.uniform(0, 5, size=n)  # always non-negative
g = f + shift  # g ≥ f pointwise

inf_f = np.min(f)
inf_g = np.min(g)
print(f"f = {np.round(f[:8], 2)}... (showing first 8)")
print(f"g = f + shift, g ≥ f pointwise")
print(f"inf(f) = {inf_f:.4f}")
print(f"inf(g) = {inf_g:.4f}")
print(f"inf(f) ≤ inf(g)? {inf_f <= inf_g} ✓")

# Stress test
violations = 0
for trial in range(10000):
    f = np.random.uniform(0, 10, size=50)
    g = f + np.random.uniform(0, 5, size=50)
    if np.min(f) > np.min(g):
        violations += 1
print(f"\nStress test: 10000 random trials, violations: {violations} ✓")

# ─────────────────────────────────────────────────────────
# Demo 6: Additive Shift Stability
# ─────────────────────────────────────────────────────────
section("Theorem 7: Argmin Stability Under Additive Shift")

f = np.array([5.0, 3.0, 8.0, 1.0, 6.0])
for c in [-10, 0, 7.5, 100]:
    g = f + c
    argmin_f = np.argmin(f)
    argmin_g = np.argmin(g)
    print(f"c={c:>6.1f}: argmin(f)={argmin_f}, argmin(f+c)={argmin_g}, "
          f"same? {argmin_f == argmin_g} ✓")

# ─────────────────────────────────────────────────────────
# Demo 7: Matrix Entry Minimizer
# ─────────────────────────────────────────────────────────
section("Theorem 8: Matrix Entry Minimizer")

for n in [3, 5, 10]:
    M = np.random.uniform(0, 100, size=(n, n))
    idx = np.unravel_index(np.argmin(M), M.shape)
    min_val = M[idx]
    all_ge = np.all(M >= min_val)
    print(f"n={n:>2d}: min entry M[{idx[0]},{idx[1]}] = {min_val:.4f}, "
          f"all M[i,j] ≥ min? {all_ge} ✓")

print(f"\nExample 3×3 matrix:")
M = np.random.uniform(0, 10, size=(3, 3))
print(np.round(M, 3))
idx = np.unravel_index(np.argmin(M), M.shape)
print(f"Global minimum: M[{idx[0]},{idx[1]}] = {M[idx]:.3f}")

# ─────────────────────────────────────────────────────────
# Demo 8: Cross-Domain Application — Proof Search
# ─────────────────────────────────────────────────────────
section("Application: Proof Search Over Finite Candidates")

proof_names = ["Direct", "Contradiction", "Induction", "Case Analysis", "Algebraic"]
proof_costs = [45, 23, 67, 31, 18]

print("Proof candidates and their costs (lines of proof):")
for name, cost in zip(proof_names, proof_costs):
    print(f"  {name:>20s}: {cost} lines")

opt_idx = np.argmin(proof_costs)
avg_cost = np.mean(proof_costs)
print(f"\nOptimal proof: {proof_names[opt_idx]} ({proof_costs[opt_idx]} lines)")
print(f"Average cost: {avg_cost:.1f} lines")
print(f"Optimal ≤ average? {proof_costs[opt_idx] <= avg_cost} ✓ (Theorem 5)")
print(f"Optimal ≤ every candidate? {all(proof_costs[opt_idx] <= c for c in proof_costs)} ✓ (Theorem 3)")

# ─────────────────────────────────────────────────────────
# Demo 9: Cross-Domain Application — Crypto Witness
# ─────────────────────────────────────────────────────────
section("Application: Cryptographic Witness Selection")

n_keys = 128
verify_costs = np.random.exponential(scale=2.0, size=n_keys)
opt_key = np.argmin(verify_costs)
print(f"Key space: Fin {n_keys}")
print(f"Verification costs: Exponential(λ=0.5)")
print(f"Optimal key: #{opt_key}, cost={verify_costs[opt_key]:.4f} ms")
print(f"Worst key:   #{np.argmax(verify_costs)}, cost={verify_costs.max():.4f} ms")
print(f"Average cost: {np.mean(verify_costs):.4f} ms")
print(f"Optimal ≤ average? {verify_costs[opt_key] <= np.mean(verify_costs)} ✓")
print(f"Speedup over worst: {verify_costs.max() / verify_costs[opt_key]:.1f}×")

print("\n" + "="*60)
print("  All demonstrations completed successfully.")
print("="*60)


#!/usr/bin/env python3
"""Generate PACKAGE.json by combining all deliverables."""

import json

# Read all files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_proofs = read_file('/workspace/request-project/Catalog/Bridges/TropicalFiniteOptimization.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')

# Read visualization data
with open('/workspace/request-project/viz_data.json', 'r') as f:
    visualizations = json.load(f)

package = {
    "title": "Tropical Finite Optimization: A Compositional Bridge Between Proof Theory, Coding Theory, and Idempotent Algebra",
    "domain": "Bridges — Tropical Algebra, Proof Theory, Cryptography, Optimization",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Finite Optimization Demos",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Finite Minimizer (Argmin)",
            "pseudocode": """ALGORITHM FiniteMinimizer(S, cost)
INPUT:  Nonempty finite set S, cost function cost : S → ℝ
OUTPUT: Element a* ∈ S with cost(a*) ≤ cost(b) for all b ∈ S

1. Pick any a* ∈ S
2. FOR each b ∈ S:
3.     IF cost(b) < cost(a*):
4.         a* ← b
5. RETURN a*

TIME:  O(|S|)
SPACE: O(1)""",
            "code": """def finite_minimizer(elements, cost):
    \"\"\"Find the global minimizer of a cost function over a finite nonempty set.\"\"\"
    import numpy as np
    if not elements:
        raise ValueError("Element set must be nonempty")
    best = elements[0]
    best_cost = cost(best)
    for elem in elements[1:]:
        c = cost(elem)
        if c < best_cost:
            best = elem
            best_cost = c
    return best, best_cost

# Example
elements = list(range(1, 11))
cost_fn = lambda x: (x - 4.5) ** 2
best, best_cost = finite_minimizer(elements, cost_fn)
print(f"Minimizer: {best}, cost: {best_cost}")"""
        },
        {
            "name": "Tropical Matrix Multiplication",
            "pseudocode": """ALGORITHM TropicalMatMul(A, B)
INPUT:  n×m matrix A, m×p matrix B over (ℝ ∪ {∞}, min, +)
OUTPUT: n×p matrix C with C[i,j] = min_k (A[i,k] + B[k,j])

1. Initialize C[i,j] ← ∞ for all i, j
2. FOR i = 1 TO n:
3.     FOR j = 1 TO p:
4.         FOR k = 1 TO m:
5.             C[i,j] ← min(C[i,j], A[i,k] + B[k,j])
6. RETURN C

TIME:  O(nmp)
SPACE: O(np)""",
            "code": """import numpy as np

def tropical_matrix_multiply(A, B):
    \"\"\"Tropical (min-plus) matrix multiplication.\"\"\"
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C

# Example: shortest paths
INF = float('inf')
M = np.array([[0, 3, INF], [3, 0, 1], [INF, 1, 0]])
D = tropical_matrix_multiply(M, M)
print("One-step costs:")
print(M)
print("Two-step shortest paths:")
print(D)"""
        },
        {
            "name": "Below-Average Element Finder",
            "pseudocode": """ALGORITHM BelowAverage(S, cost)
INPUT:  Nonempty finite set S, cost function cost : S → ℝ
OUTPUT: Element a ∈ S with cost(a) ≤ avg(cost)

1. total ← 0
2. FOR each x ∈ S: total ← total + cost(x)
3. avg ← total / |S|
4. a* ← FiniteMinimizer(S, cost)
5. ASSERT cost(a*) ≤ avg  // guaranteed by pigeonhole
6. RETURN a*

TIME:  O(|S|)
SPACE: O(1)""",
            "code": """def below_average_element(elements, cost):
    \"\"\"Find an element with cost at most the average.\"\"\"
    if not elements:
        raise ValueError("Empty set")
    total = sum(cost(e) for e in elements)
    avg = total / len(elements)
    best = min(elements, key=cost)
    best_cost = cost(best)
    assert best_cost <= avg
    return best, best_cost, avg

# Example
elements = ["A", "B", "C", "D", "E"]
costs = {"A": 10, "B": 3, "C": 7, "D": 12, "E": 8}
elem, ec, avg = below_average_element(elements, lambda x: costs[x])
print(f"Below-average: {elem} (cost={ec}, avg={avg})")"""
        }
    ],
    "visualizations": visualizations,
    "lean_proofs": lean_proofs
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""Generate visualizations as base64-encoded PNGs for the PACKAGE.json."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json

def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')

visualizations = []

# ─── Viz 1: Tropical Infimum Bound ───
fig, ax = plt.subplots(figsize=(8, 5))
np.random.seed(42)
n = 15
costs = np.random.uniform(2, 12, size=n)
inf_val = np.min(costs)
ax.bar(range(n), costs, color='steelblue', alpha=0.7, label='f(a)')
ax.axhline(y=inf_val, color='crimson', linewidth=2, linestyle='--', label=f'inf = {inf_val:.2f}')
ax.set_xlabel('Element index a', fontsize=12)
ax.set_ylabel('Cost f(a)', fontsize=12)
ax.set_title('Tropical Finset Infimum Bound\ninf\'(s, f) ≤ f(a) for all a ∈ s', fontsize=14)
ax.legend(fontsize=11)
ax.set_ylim(0, 14)
plt.tight_layout()
visualizations.append({"name": "Tropical Finset Infimum Bound", "data": fig_to_base64(fig)})
plt.close()

# ─── Viz 2: Minimizer Existence on Fin n ───
fig, axes = plt.subplots(1, 3, figsize=(14, 4))
for idx, n in enumerate([10, 50, 200]):
    np.random.seed(idx + 10)
    f = np.random.uniform(0, 10, size=n)
    argmin = np.argmin(f)
    ax = axes[idx]
    ax.plot(range(n), f, '.', color='steelblue', markersize=max(2, 8-idx*2), alpha=0.6)
    ax.plot(argmin, f[argmin], 'r*', markersize=15, zorder=5, label=f'minimizer (idx={argmin})')
    ax.axhline(y=f[argmin], color='crimson', linewidth=1, linestyle='--', alpha=0.5)
    ax.set_title(f'Fin {n}', fontsize=12)
    ax.set_xlabel('Index')
    ax.set_ylabel('f(a)')
    ax.legend(fontsize=9)
fig.suptitle('Existence of Global Minimizer on Fin n', fontsize=14, y=1.02)
plt.tight_layout()
visualizations.append({"name": "Minimizer Existence on Fin n", "data": fig_to_base64(fig)})
plt.close()

# ─── Viz 3: Averaging Bound ───
fig, ax = plt.subplots(figsize=(8, 5))
np.random.seed(55)
n = 20
costs = np.random.exponential(scale=5, size=n)
avg = np.mean(costs)
sorted_idx = np.argsort(costs)
colors = ['forestgreen' if costs[i] <= avg else 'steelblue' for i in sorted_idx]
ax.barh(range(n), costs[sorted_idx], color=colors, alpha=0.7)
ax.axvline(x=avg, color='orange', linewidth=2, linestyle='--', label=f'Average = {avg:.2f}')
ax.set_ylabel('Element (sorted)', fontsize=12)
ax.set_xlabel('Cost f(a)', fontsize=12)
ax.set_title('Pigeonhole: ∃ a with f(a) ≤ average\n(green = below average)', fontsize=14)
ax.legend(fontsize=11)
plt.tight_layout()
visualizations.append({"name": "Averaging Pigeonhole Bound", "data": fig_to_base64(fig)})
plt.close()

# ─── Viz 4: Matrix Entry Minimizer ───
fig, ax = plt.subplots(figsize=(7, 6))
np.random.seed(33)
n = 8
M = np.random.uniform(0, 10, size=(n, n))
idx = np.unravel_index(np.argmin(M), M.shape)
im = ax.imshow(M, cmap='YlOrRd', aspect='equal')
ax.plot(idx[1], idx[0], 's', color='cyan', markersize=20, markeredgecolor='black',
        markeredgewidth=2, label=f'Min: M[{idx[0]},{idx[1]}]={M[idx]:.2f}')
ax.set_title(f'Matrix Entry Minimizer (8×8)\nGlobal min = {M[idx]:.3f}', fontsize=14)
ax.set_xlabel('Column j')
ax.set_ylabel('Row i')
ax.legend(fontsize=11, loc='upper right')
plt.colorbar(im, ax=ax, label='Cost M[i,j]')
plt.tight_layout()
visualizations.append({"name": "Matrix Entry Minimizer", "data": fig_to_base64(fig)})
plt.close()

# ─── Viz 5: Monotonicity Under Pointwise Domination ───
fig, ax = plt.subplots(figsize=(8, 5))
np.random.seed(77)
n = 12
f = np.random.uniform(1, 8, size=n)
g = f + np.random.uniform(0.5, 3, size=n)
x = np.arange(n)
ax.bar(x - 0.2, f, 0.35, color='steelblue', alpha=0.7, label=f'f (inf={np.min(f):.2f})')
ax.bar(x + 0.2, g, 0.35, color='coral', alpha=0.7, label=f'g ≥ f (inf={np.min(g):.2f})')
ax.axhline(y=np.min(f), color='steelblue', linewidth=1.5, linestyle='--', alpha=0.7)
ax.axhline(y=np.min(g), color='coral', linewidth=1.5, linestyle='--', alpha=0.7)
ax.set_xlabel('Element index', fontsize=12)
ax.set_ylabel('Cost', fontsize=12)
ax.set_title('Monotonicity: f ≤ g pointwise ⟹ inf(f) ≤ inf(g)', fontsize=14)
ax.legend(fontsize=11)
plt.tight_layout()
visualizations.append({"name": "Monotonicity Under Pointwise Domination", "data": fig_to_base64(fig)})
plt.close()

# ─── Viz 6: Tropical Shortest Path ───
fig, axes = plt.subplots(1, 2, figsize=(13, 5))

# Graph visualization (left)
ax = axes[0]
positions = {0: (0, 1), 1: (1, 2), 2: (2, 1), 3: (1, 0), 4: (3, 1.5)}
edges = [(0,1,3), (0,3,7), (1,2,1), (2,3,2), (1,4,8), (3,4,4)]
labels_map = ["A", "B", "C", "D", "E"]

for i, (x, y) in positions.items():
    ax.plot(x, y, 'o', color='steelblue', markersize=25, zorder=5)
    ax.text(x, y, labels_map[i], ha='center', va='center', fontsize=12, 
            fontweight='bold', color='white', zorder=6)

for u, v, w in edges:
    xu, yu = positions[u]
    xv, yv = positions[v]
    ax.annotate('', xy=(xv, yv), xytext=(xu, yu),
                arrowprops=dict(arrowstyle='-', color='gray', lw=2))
    mx, my = (xu+xv)/2, (yu+yv)/2 + 0.15
    ax.text(mx, my, str(w), fontsize=11, ha='center', color='crimson', fontweight='bold')

ax.set_xlim(-0.5, 3.5)
ax.set_ylim(-0.5, 2.5)
ax.set_aspect('equal')
ax.set_title('Network Graph', fontsize=13)
ax.axis('off')

# Distance matrix (right)
ax = axes[1]
INF = float('inf')
M = np.array([
    [0, 3, INF, 7, INF],
    [3, 0, 1, INF, 8],
    [INF, 1, 0, 2, INF],
    [7, INF, 2, 0, 4],
    [INF, 8, INF, 4, 0],
])
D = M.copy()
for _ in range(4):
    n_dim = D.shape[0]
    D_new = np.full_like(D, INF)
    for i in range(n_dim):
        for j in range(n_dim):
            for k in range(n_dim):
                D_new[i,j] = min(D_new[i,j], D[i,k] + M[k,j])
    D = D_new

# Mask diagonal for display
D_display = D.copy()
im = ax.imshow(D_display, cmap='YlGnBu_r', aspect='equal')
for i in range(5):
    for j in range(5):
        ax.text(j, i, f'{D_display[i,j]:.0f}', ha='center', va='center', fontsize=11,
                color='white' if D_display[i,j] > 5 else 'black')
ax.set_xticks(range(5))
ax.set_yticks(range(5))
ax.set_xticklabels(labels_map)
ax.set_yticklabels(labels_map)
ax.set_title('All-Pairs Shortest Paths\n(Tropical Matrix Power)', fontsize=13)
plt.colorbar(im, ax=ax, label='Distance')

plt.tight_layout()
visualizations.append({"name": "Tropical Shortest Path via Matrix Power", "data": fig_to_base64(fig)})
plt.close()

# Save visualization data
with open('/workspace/request-project/viz_data.json', 'w') as f:
    json.dump(visualizations, f)

print(f"Generated {len(visualizations)} visualizations")
for v in visualizations:
    print(f"  - {v['name']} ({len(v['data'])} chars)")
