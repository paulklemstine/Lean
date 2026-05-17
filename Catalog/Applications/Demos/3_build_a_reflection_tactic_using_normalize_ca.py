#!/usr/bin/env python3
"""
Applications of Tropical ACI Normalization
============================================

Demonstrates real-world applications of the tropical normalization algorithm
in shortest-path computation, scheduling, and piecewise-linear analysis.
"""

import numpy as np
from typing import List, Tuple, Dict
from dataclasses import dataclass


# ============================================================
# Application 1: Shortest Path Verification
# ============================================================

def min_plus_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication (tropical matrix multiplication).

    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    This is the fundamental operation in shortest-path algorithms.
    """
    n = A.shape[0]
    m = B.shape[1]
    k = A.shape[1]
    C = np.full((n, m), np.inf)
    for i in range(n):
        for j in range(m):
            for l in range(k):
                C[i, j] = min(C[i, j], A[i, l] + B[l, j])
    return C


def floyd_warshall_tropical(W: np.ndarray) -> np.ndarray:
    """
    All-pairs shortest paths via tropical matrix closure.

    Computes the Kleene star: W* = I ⊕ W ⊕ W² ⊕ W³ ⊕ ...
    where ⊕ is entrywise min and multiplication is min-plus.
    """
    n = W.shape[0]
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i, j] = min(D[i, j], D[i, k] + D[k, j])
    return D


def demo_shortest_paths():
    """
    Demonstrate that tropical algebra naturally expresses shortest paths.

    The key identity used: min(a + b, a + c) = a + min(b, c)
    This is the distributive law of tropical algebra.
    """
    print("Application 1: Shortest Path Algebra")
    print("-" * 40)

    # Weighted directed graph (adjacency matrix with ∞ for no edge)
    INF = np.inf
    W = np.array([
        [0,   3,   INF, 7  ],
        [INF, 0,   2,   INF],
        [INF, INF, 0,   1  ],
        [6,   INF, INF, 0  ]
    ])

    print("Weight matrix W:")
    for row in W:
        print("  ", [f"{x:5.0f}" if x < INF else "  INF" for x in row])

    D = floyd_warshall_tropical(W)
    print("\nAll-pairs shortest distances (W*):")
    for row in D:
        print("  ", [f"{x:5.0f}" for x in row])

    # Verify: W² should give 2-hop shortest paths
    W2 = min_plus_multiply(W, W)
    print("\n2-hop shortest paths (W²):")
    for row in W2:
        print("  ", [f"{x:5.0f}" if x < INF else "  INF" for x in row])

    # The tropical identity min(W, W²) = W ⊕ W² gives paths ≤ 2 hops
    W_or_W2 = np.minimum(W, W2)
    print("\nBest of 1-hop or 2-hop (W ⊕ W²):")
    for row in W_or_W2:
        print("  ", [f"{x:5.0f}" if x < INF else "  INF" for x in row])


# ============================================================
# Application 2: Job Scheduling (Makespan Optimization)
# ============================================================

@dataclass
class Job:
    name: str
    duration: float
    dependencies: List[str]

def compute_makespan(jobs: List[Job]) -> Dict[str, float]:
    """
    Compute earliest completion times using tropical algebra.

    The completion time of a job is:
        C(j) = d(j) + max over dependencies i of C(i)

    In min-plus terms (negating to convert max to min):
        -C(j) = -d(j) + min over dependencies i of (-C(i))

    More naturally, in max-plus algebra:
        C(j) = d(j) ⊕ (⊕_i C(i))
    where ⊕ = max and ⊗ = +
    """
    completion = {}
    job_dict = {j.name: j for j in jobs}

    def compute(name):
        if name in completion:
            return completion[name]
        job = job_dict[name]
        if not job.dependencies:
            completion[name] = job.duration
        else:
            dep_times = [compute(dep) for dep in job.dependencies]
            completion[name] = max(dep_times) + job.duration
        return completion[name]

    for j in jobs:
        compute(j.name)

    return completion


def demo_scheduling():
    """Demonstrate tropical algebra in job scheduling."""
    print("\n\nApplication 2: Job Scheduling")
    print("-" * 40)

    jobs = [
        Job("Foundation", 5, []),
        Job("Framing", 8, ["Foundation"]),
        Job("Plumbing", 4, ["Foundation"]),
        Job("Electrical", 6, ["Framing"]),
        Job("Drywall", 3, ["Framing", "Plumbing"]),
        Job("Painting", 2, ["Drywall", "Electrical"]),
        Job("Inspection", 1, ["Painting"]),
    ]

    completion = compute_makespan(jobs)

    print("Job Schedule (earliest completion times):")
    for j in jobs:
        deps = ", ".join(j.dependencies) if j.dependencies else "none"
        print(f"  {j.name:15s}  duration={j.duration:.0f}  deps=[{deps}]  completes at t={completion[j.name]:.0f}")

    makespan = max(completion.values())
    print(f"\nTotal makespan: {makespan:.0f}")
    print(f"\nThe critical path determines the makespan via max-plus algebra.")
    print(f"The tropical normalization tactic can verify scheduling identities")
    print(f"that express equivalence of different scheduling formulations.")


# ============================================================
# Application 3: Piecewise-Linear Functions
# ============================================================

def tropical_polynomial(coeffs: List[Tuple[float, List[int]]],
                        x: np.ndarray) -> np.ndarray:
    """
    Evaluate a tropical polynomial.

    A tropical polynomial in variables x₁,...,xₙ is:
        p(x) = min_i (c_i + a_{i,1}*x₁ + ... + a_{i,n}*xₙ)

    Each term is a linear function, and the polynomial is their
    pointwise minimum — a piecewise-linear concave function.
    """
    terms = []
    for c, exponents in coeffs:
        term = c + sum(e * xi for e, xi in zip(exponents, x))
        terms.append(term)
    return min(terms)


def demo_piecewise_linear():
    """Demonstrate tropical polynomials as piecewise-linear functions."""
    print("\n\nApplication 3: Piecewise-Linear Functions")
    print("-" * 40)

    # Tropical polynomial: min(2 + x, 3 + 2x, 5)
    # This defines a piecewise-linear function of one variable
    coeffs = [
        (2.0, [1.0]),   # 2 + x
        (3.0, [2.0]),   # 3 + 2x
        (5.0, [0.0]),   # 5
    ]

    print("Tropical polynomial: p(x) = min(2+x, 3+2x, 5)")
    print("\nValues:")
    for x_val in np.linspace(-3, 5, 17):
        val = tropical_polynomial(coeffs, [x_val])
        print(f"  p({x_val:5.1f}) = {val:6.2f}")

    # The breakpoints are where two terms are equal:
    # 2+x = 3+2x => x = -1
    # 2+x = 5 => x = 3
    # 3+2x = 5 => x = 1
    print("\nBreakpoints (where linear pieces meet):")
    print("  2+x = 3+2x at x = -1")
    print("  2+x = 5    at x = 3")
    print("  3+2x = 5   at x = 1")

    print("\nTropical normalization ensures that algebraically equivalent")
    print("representations of piecewise-linear functions are recognized as equal.")


# ============================================================
# Application 4: Bellman Equation (Dynamic Programming)
# ============================================================

def bellman_iteration(V: np.ndarray, R: np.ndarray, P: np.ndarray,
                       gamma: float = 0.9) -> np.ndarray:
    """
    One step of the Bellman optimality equation for MDPs.

    In the min-cost formulation:
        V'(s) = min_a [c(s,a) + γ * Σ_s' P(s'|s,a) * V(s')]

    The min operation is tropical addition, and the + with discount
    is tropical multiplication. The normalization tactic can verify
    algebraic identities in the Bellman operator's fixed-point theory.
    """
    n_states, n_actions = R.shape
    V_new = np.full(n_states, np.inf)
    for s in range(n_states):
        for a in range(n_actions):
            # Expected future cost
            future = sum(P[s, a, sp] * V[sp] for sp in range(n_states))
            V_new[s] = min(V_new[s], R[s, a] + gamma * future)
    return V_new


def demo_bellman():
    """Demonstrate tropical structure in dynamic programming."""
    print("\n\nApplication 4: Dynamic Programming (Bellman Equation)")
    print("-" * 40)

    # Simple 3-state MDP
    n_states, n_actions = 3, 2
    R = np.array([[1.0, 3.0], [2.0, 1.0], [4.0, 2.0]])
    P = np.zeros((n_states, n_actions, n_states))

    # Transition probabilities
    P[0, 0, :] = [0.2, 0.5, 0.3]
    P[0, 1, :] = [0.1, 0.6, 0.3]
    P[1, 0, :] = [0.4, 0.3, 0.3]
    P[1, 1, :] = [0.2, 0.2, 0.6]
    P[2, 0, :] = [0.3, 0.3, 0.4]
    P[2, 1, :] = [0.5, 0.2, 0.3]

    V = np.zeros(n_states)
    print("Value iteration (min-cost formulation):")
    print(f"  Initial V = {V}")

    for i in range(20):
        V_new = bellman_iteration(V, R, P, gamma=0.9)
        diff = np.max(np.abs(V_new - V))
        V = V_new
        if i < 5 or i == 19:
            print(f"  Iter {i+1:2d}: V = [{', '.join(f'{v:.4f}' for v in V)}], max_diff = {diff:.6f}")

    print(f"\nConverged value function:")
    print(f"  V* = [{', '.join(f'{v:.4f}' for v in V)}]")
    print(f"\nThe Bellman operator is a tropical contraction mapping.")
    print(f"Tropical normalization can verify algebraic properties of the operator.")


if __name__ == "__main__":
    demo_shortest_paths()
    demo_scheduling()
    demo_piecewise_linear()
    demo_bellman()


#!/usr/bin/env python3
"""
Tropical Algebra Normalization Demo
====================================

Demonstrates the ACI (Associative-Commutative-Idempotent) normalization
algorithm for tropical (min-plus) expressions. This is the computational
heart of a certified decision procedure for tropical identity proving.

The algorithm:
1. Recursively normalize sub-expressions
2. Flatten nested min/add into lists
3. Sort each list by a total order on expressions
4. Deduplicate the min-list (since min(x,x) = x)
5. Rebuild the expression from the sorted (deduped) list
"""

from dataclasses import dataclass
from typing import Union
from functools import total_ordering


# --- Expression AST ---

@dataclass(frozen=True)
class Var:
    """A variable, identified by index."""
    index: int
    def __repr__(self): return f"x{self.index}"

@dataclass(frozen=True)
class TMin:
    """Tropical addition: min(a, b)."""
    left: 'TropExpr'
    right: 'TropExpr'
    def __repr__(self): return f"min({self.left}, {self.right})"

@dataclass(frozen=True)
class TAdd:
    """Tropical multiplication: a + b."""
    left: 'TropExpr'
    right: 'TropExpr'
    def __repr__(self): return f"({self.left} + {self.right})"

TropExpr = Union[Var, TMin, TAdd]


# --- Expression Comparison (Total Order) ---

def tag(e: TropExpr) -> int:
    if isinstance(e, Var): return 0
    if isinstance(e, TMin): return 1
    if isinstance(e, TAdd): return 2
    raise TypeError

def cmp_expr(a: TropExpr, b: TropExpr) -> int:
    """Compare two expressions. Returns -1, 0, or 1."""
    ta, tb = tag(a), tag(b)
    if ta != tb:
        return -1 if ta < tb else 1
    if isinstance(a, Var):
        return (a.index > b.index) - (a.index < b.index)
    # TMin or TAdd: lexicographic on children
    c = cmp_expr(a.left, b.left)
    if c != 0: return c
    return cmp_expr(a.right, b.right)

from functools import cmp_to_key
expr_key = cmp_to_key(cmp_expr)


# --- Flatten / Build / Dedup ---

def flatten_min(e: TropExpr) -> list:
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e: TropExpr) -> list:
    if isinstance(e, TAdd):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]

def dedup(lst: list) -> list:
    """Remove consecutive duplicates from a sorted list."""
    if not lst: return []
    result = [lst[0]]
    for x in lst[1:]:
        if x != result[-1]:
            result.append(x)
    return result

def build_min(lst: list) -> TropExpr:
    assert lst, "Cannot build from empty list"
    result = lst[-1]
    for x in reversed(lst[:-1]):
        result = TMin(x, result)
    return result

def build_add(lst: list) -> TropExpr:
    assert lst, "Cannot build from empty list"
    result = lst[-1]
    for x in reversed(lst[:-1]):
        result = TAdd(x, result)
    return result


# --- ACI Normalizer ---

def normalize(e: TropExpr) -> TropExpr:
    """
    ACI normalization for tropical expressions.
    - min: flatten, sort, deduplicate (ACI)
    - add: flatten, sort (AC only)
    """
    if isinstance(e, Var):
        return e
    if isinstance(e, TMin):
        a = normalize(e.left)
        b = normalize(e.right)
        flat = flatten_min(TMin(a, b))
        flat.sort(key=expr_key)
        flat = dedup(flat)
        return build_min(flat)
    if isinstance(e, TAdd):
        a = normalize(e.left)
        b = normalize(e.right)
        flat = flatten_add(TAdd(a, b))
        flat.sort(key=expr_key)
        return build_add(flat)
    raise TypeError


# --- Evaluator ---

def evaluate(e: TropExpr, sigma: dict) -> float:
    """Evaluate expression under variable assignment sigma."""
    if isinstance(e, Var): return sigma[e.index]
    if isinstance(e, TMin): return min(evaluate(e.left, sigma), evaluate(e.right, sigma))
    if isinstance(e, TAdd): return evaluate(e.left, sigma) + evaluate(e.right, sigma)
    raise TypeError


# --- Demo ---

def demo_identity(name, lhs, rhs, sigma):
    """Verify a tropical identity both syntactically and numerically."""
    n_lhs = normalize(lhs)
    n_rhs = normalize(rhs)
    equal = n_lhs == n_rhs

    v_lhs = evaluate(lhs, sigma)
    v_rhs = evaluate(rhs, sigma)

    print(f"\n{'='*60}")
    print(f"Identity: {name}")
    print(f"  LHS: {lhs}")
    print(f"  RHS: {rhs}")
    print(f"  Normalized LHS: {n_lhs}")
    print(f"  Normalized RHS: {n_rhs}")
    print(f"  Syntactically equal: {equal}")
    print(f"  Numerical check (σ={sigma}):")
    print(f"    LHS = {v_lhs}, RHS = {v_rhs}, Equal: {v_lhs == v_rhs}")
    return equal


if __name__ == "__main__":
    a, b, c, d, e = Var(0), Var(1), Var(2), Var(3), Var(4)
    sigma = {0: 3.0, 1: 1.0, 2: 4.0, 3: 1.0, 4: 5.0}

    print("Tropical ACI Normalization Demo")
    print("================================")

    # 1. Associativity and commutativity of min with addition
    demo_identity(
        "min(a+b, min(c+d, a+b)) = min(min(d+c, b+a), a+b)",
        TMin(TAdd(a,b), TMin(TAdd(c,d), TAdd(a,b))),
        TMin(TMin(TAdd(d,c), TAdd(b,a)), TAdd(a,b)),
        sigma
    )

    # 2. Flattening nested mins
    demo_identity(
        "min(min(a,b), min(c,d)) = min(a, min(b, min(c,d)))",
        TMin(TMin(a,b), TMin(c,d)),
        TMin(a, TMin(b, TMin(c,d))),
        sigma
    )

    # 3. Duplicate elimination
    demo_identity(
        "min(a+b, min(a+b, c)) = min(c, b+a)",
        TMin(TAdd(a,b), TMin(TAdd(a,b), c)),
        TMin(c, TAdd(b,a)),
        sigma
    )

    # 4. AC normal form collapse
    demo_identity(
        "min(a+(b+c), (c+b)+a) = a+(b+c)",
        TMin(TAdd(a, TAdd(b,c)), TAdd(TAdd(c,b), a)),
        TAdd(a, TAdd(b,c)),
        sigma
    )

    # 5. Five-variable identity
    demo_identity(
        "min(min(a+b,c+d), min(d+c, min(b+a,e))) = min(min(a+b,e), c+d)",
        TMin(TMin(TAdd(a,b), TAdd(c,d)),
             TMin(TAdd(d,c), TMin(TAdd(b,a), e))),
        TMin(TMin(TAdd(a,b), e), TAdd(c,d)),
        sigma
    )

    # 6. Triple redundancy
    demo_identity(
        "min(a+b, min(b+a, a+b)) = a+b",
        TMin(TAdd(a,b), TMin(TAdd(b,a), TAdd(a,b))),
        TAdd(a,b),
        sigma
    )

    # 7. Numerical stress test with random assignments
    import random
    random.seed(42)
    print(f"\n{'='*60}")
    print("Stress test: 1000 random assignments")
    all_pass = True
    for _ in range(1000):
        s = {i: random.uniform(-10, 10) for i in range(5)}
        lhs = TMin(TAdd(a,b), TMin(TAdd(c,d), TAdd(a,b)))
        rhs = TMin(TMin(TAdd(d,c), TAdd(b,a)), TAdd(a,b))
        if abs(evaluate(lhs, s) - evaluate(rhs, s)) > 1e-12:
            all_pass = False
            break
    print(f"  All 1000 tests passed: {all_pass}")


#!/usr/bin/env python3
"""
Visualizations for Tropical ACI Normalization
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import base64
import io

# Import the algorithm
from algorithms import (
    Var, TMin, TAdd, normalize, random_expr, random_aci_permutation,
    are_aci_equivalent, evaluate
)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_normalization_performance():
    """Plot normalization time vs expression depth."""
    import time

    random.seed(42)
    depths = list(range(1, 13))
    avg_times = []
    sizes = []

    for depth in depths:
        times = []
        expr_sizes = []
        for _ in range(200):
            e = random_expr(5, depth)
            expr_sizes.append(e.size())
            start = time.perf_counter()
            normalize(e)
            elapsed = time.perf_counter() - start
            times.append(elapsed * 1000)
        avg_times.append(np.mean(times))
        sizes.append(np.mean(expr_sizes))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(depths, avg_times, 'o-', color='#2196F3', linewidth=2, markersize=6)
    ax1.set_xlabel('Expression Depth', fontsize=12)
    ax1.set_ylabel('Average Normalization Time (ms)', fontsize=12)
    ax1.set_title('Normalization Performance', fontsize=14, fontweight='bold')
    ax1.grid(True, alpha=0.3)

    ax2.plot(sizes, avg_times, 's-', color='#FF5722', linewidth=2, markersize=6)
    ax2.set_xlabel('Average Expression Size (nodes)', fontsize=12)
    ax2.set_ylabel('Average Normalization Time (ms)', fontsize=12)
    ax2.set_title('Time vs Expression Size', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical ACI Normalization: Computational Performance',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_tropical_polynomial():
    """Plot a tropical polynomial as a piecewise-linear function."""
    x = np.linspace(-4, 6, 1000)

    # Three linear functions
    f1 = 2 + x        # 2 + x
    f2 = 3 + 2*x      # 3 + 2x
    f3 = np.full_like(x, 5.0)  # 5

    # Tropical polynomial = pointwise min
    trop = np.minimum(np.minimum(f1, f2), f3)

    fig, ax = plt.subplots(figsize=(10, 6))

    ax.plot(x, f1, '--', color='#90CAF9', alpha=0.7, label='2 + x')
    ax.plot(x, f2, '--', color='#A5D6A7', alpha=0.7, label='3 + 2x')
    ax.plot(x, f3, '--', color='#FFCC80', alpha=0.7, label='5')
    ax.plot(x, trop, '-', color='#D32F2F', linewidth=3,
            label='min(2+x, 3+2x, 5)')

    # Mark breakpoints
    ax.axvline(x=-1, color='gray', linestyle=':', alpha=0.5)
    ax.axvline(x=1, color='gray', linestyle=':', alpha=0.5)
    ax.axvline(x=3, color='gray', linestyle=':', alpha=0.5)

    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('p(x)', fontsize=14)
    ax.set_title('Tropical Polynomial = Piecewise-Linear Function',
                 fontsize=16, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-3, 8)

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_normalization_pipeline():
    """Create a visual diagram of the normalization pipeline."""
    fig, axes = plt.subplots(1, 5, figsize=(18, 4))

    steps = [
        ("Input\nExpression", "min(a+b,\n  min(c+d,\n    a+b))", '#E3F2FD'),
        ("Normalize\nSub-expressions", "min(a+b,\n  min(c+d,\n    a+b))", '#E8F5E9'),
        ("Flatten\nmin-tree", "[a+b,\n c+d,\n a+b]", '#FFF3E0'),
        ("Sort &\nDeduplicate", "[a+b,\n c+d]", '#FCE4EC'),
        ("Rebuild\nCanonical Form", "min(a+b,\n  c+d)", '#E8EAF6'),
    ]

    for ax, (title, content, color) in zip(axes, steps):
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)

        # Box
        rect = plt.Rectangle((0.05, 0.15), 0.9, 0.7, linewidth=2,
                              edgecolor='#333', facecolor=color,
                              zorder=2)
        ax.add_patch(rect)

        # Title
        ax.text(0.5, 0.92, title, ha='center', va='top',
                fontsize=11, fontweight='bold', color='#333')

        # Content
        ax.text(0.5, 0.5, content, ha='center', va='center',
                fontsize=10, fontfamily='monospace', color='#555')

        ax.set_xticks([])
        ax.set_yticks([])
        ax.set_frame_on(False)

    # Arrows between boxes
    from matplotlib.patches import FancyArrowPatch
    for i in range(4):
        fig.patches.append(FancyArrowPatch(
            (0.19 + i * 0.2, 0.5), (0.21 + i * 0.2, 0.5),
            transform=fig.transFigure,
            arrowstyle='->', mutation_scale=20,
            color='#666', linewidth=2
        ))

    fig.suptitle('ACI Normalization Pipeline',
                 fontsize=18, fontweight='bold', y=1.05)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_compression_ratio():
    """Plot how normalization compresses expressions with duplicates."""
    random.seed(42)

    orig_sizes = []
    norm_sizes = []
    labels = []

    for n_dups in range(0, 8):
        for _ in range(50):
            e = random_expr(3, 3)
            # Add duplicates via min
            result = e
            for _ in range(n_dups):
                perm = random_aci_permutation(e)
                result = TMin(result, perm)
            orig_sizes.append(result.size())
            norm_sizes.append(normalize(result).size())
            labels.append(n_dups)

    fig, ax = plt.subplots(figsize=(10, 6))

    # Group by number of duplicates
    for n_dups in range(8):
        mask = [l == n_dups for l in labels]
        os = [orig_sizes[i] for i in range(len(mask)) if mask[i]]
        ns = [norm_sizes[i] for i in range(len(mask)) if mask[i]]
        ratio = [n/o for o, n in zip(os, ns)]
        ax.scatter([n_dups] * len(ratio), ratio,
                   alpha=0.3, s=20, color='#1976D2')

    # Average line
    avg_ratios = []
    for n_dups in range(8):
        mask = [l == n_dups for l in labels]
        os = [orig_sizes[i] for i in range(len(mask)) if mask[i]]
        ns = [norm_sizes[i] for i in range(len(mask)) if mask[i]]
        ratio = [n/o for o, n in zip(os, ns)]
        avg_ratios.append(np.mean(ratio))

    ax.plot(range(8), avg_ratios, 'o-', color='#D32F2F', linewidth=2,
            markersize=8, label='Average compression', zorder=5)

    ax.set_xlabel('Number of Duplicate Min-Operands Added', fontsize=12)
    ax.set_ylabel('Normalized Size / Original Size', fontsize=12)
    ax.set_title('Deduplication Power of ACI Normalization',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.1)

    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    perf_uri = plot_normalization_performance()
    print(f"  Performance plot: {len(perf_uri)} chars")

    poly_uri = plot_tropical_polynomial()
    print(f"  Polynomial plot: {len(poly_uri)} chars")

    pipeline_uri = plot_normalization_pipeline()
    print(f"  Pipeline diagram: {len(pipeline_uri)} chars")

    compression_uri = plot_compression_ratio()
    print(f"  Compression plot: {len(compression_uri)} chars")

    # Save to files
    for name, uri in [("perf", perf_uri), ("polynomial", poly_uri),
                       ("pipeline", pipeline_uri), ("compression", compression_uri)]:
        data = base64.b64decode(uri.split(",")[1])
        with open(f"viz_{name}.png", "wb") as f:
            f.write(data)
        print(f"  Saved viz_{name}.png")

    print("Done!")
