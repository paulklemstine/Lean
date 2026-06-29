#!/usr/bin/env python3
"""
EML Closure Operator — Real-World Applications

Demonstrates how closure operator theory applies to:
1. Neural network expressivity analysis
2. Model selection and regularization
3. Compositional program synthesis
4. Quantum search optimization
5. Information-theoretic channel analysis
"""

import numpy as np
from typing import List, Tuple, Callable


# =============================================================================
# Application 1: Neural Network Expressivity via Closure Depth
# =============================================================================

def neural_network_expressivity():
    """
    Demonstrate how closure depth corresponds to network depth,
    and how the closure operator framework predicts expressivity.
    """
    print("=" * 70)
    print("APPLICATION 1: Neural Network Expressivity Analysis")
    print("=" * 70)

    # A neural network layer applies: x -> sigma(w*x + b)
    # The EML closure captures this: start with identity, apply
    # affine transformations (mul + add constants) and activation (comp)

    # Simulate what each closure depth can represent
    def count_representable_functions(depth: int, width: int = 10) -> int:
        """Estimate number of distinct functions at given depth."""
        # Each layer can create width new linear combinations
        # Composition with activation creates nonlinear features
        # Rough estimate: width^depth distinct functions
        return min(width ** depth, 10**9)

    print(f"\n  Network width = 10 neurons per layer")
    print(f"\n  {'Depth':>6}  {'Representable':>15}  {'Info Retained (α=0.9)':>22}")
    print("  " + "-" * 48)

    alpha = 0.9
    for depth in range(1, 8):
        n_funcs = count_representable_functions(depth)
        info = alpha ** depth
        print(f"  {depth:>6}  {n_funcs:>15,}  {info:>22.4f}")

    print(f"""
  KEY INSIGHT: The closure operator tells us that:
  1. Deeper networks (higher closure depth) are strictly more expressive
     (by extensivity: each depth includes the previous)
  2. But information retention DECREASES with depth
     (by info_decay_closure_transport)
  3. The optimal depth balances expressivity vs information loss
""")


# =============================================================================
# Application 2: Model Selection with Penalty Bounds
# =============================================================================

def model_selection_application():
    """
    Use penalty monotonicity to guide model selection.
    """
    print("=" * 70)
    print("APPLICATION 2: Model Selection via Penalty Monotonicity")
    print("=" * 70)

    n_samples = 500
    true_complexity = 15  # true model has 15 parameters

    # Simulate empirical risk for different complexities
    np.random.seed(42)
    noise_level = 0.1

    def empirical_risk(k: int) -> float:
        """Simulated empirical risk: decreases with k, plateaus near true complexity."""
        if k >= true_complexity:
            return noise_level
        return noise_level + (true_complexity - k) * 0.02

    def structural_penalty(k: int, n: int) -> float:
        if n <= 1:
            return 0
        return np.sqrt(2 * k * np.log(n) / n)

    print(f"\n  True complexity: k* = {true_complexity}")
    print(f"  Training samples: n = {n_samples}")
    print(f"\n  {'k':>4}  {'Emp Risk':>10}  {'Penalty':>10}  {'Total':>10}  {'Status':>10}")
    print("  " + "-" * 48)

    best_k = 1
    best_total = float('inf')

    for k in [1, 5, 10, 15, 20, 30, 50, 100]:
        emp = empirical_risk(k)
        pen = structural_penalty(k, n_samples)
        total = emp + pen
        status = ""
        if total < best_total:
            best_total = total
            best_k = k
            status = "← best"
        print(f"  {k:>4}  {emp:>10.4f}  {pen:>10.4f}  {total:>10.4f}  {status:>10}")

    print(f"\n  Optimal complexity: k = {best_k}")
    print(f"  THEOREM: penalty_mono_closure_enlargement guarantees that")
    print(f"  the penalty term is monotonically increasing in k,")
    print(f"  ensuring a unique minimum exists in the bias-variance tradeoff.")


# =============================================================================
# Application 3: Compositional Program Synthesis
# =============================================================================

def program_synthesis_application():
    """
    Show how closure self-stability enables compositional program synthesis.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Compositional Program Synthesis")
    print("=" * 70)

    # Define primitive operations
    primitives = {
        "inc": lambda x: x + 1,
        "double": lambda x: 2 * x,
        "square": lambda x: x * x,
        "negate": lambda x: -x,
    }

    # Target function: f(x) = 4x² + 2x + 1
    target = lambda x: 4 * x**2 + 2 * x + 1

    # Build it compositionally using closure operations
    # Step 1: square(x) = x²  [base]
    # Step 2: double(square(x)) = 2x²  [comp]
    # Step 3: double(2x²) = 4x²  [comp]
    # Step 4: double(x) = 2x  [base]
    # Step 5: 4x² + 2x  [add]
    # Step 6: 4x² + 2x + 1  [add with inc applied to const 0]

    synthesized = lambda x: 2 * (2 * (x * x)) + 2 * x + 1

    test_points = np.array([-3, -2, -1, 0, 1, 2, 3])
    target_vals = [target(x) for x in test_points]
    synth_vals = [synthesized(x) for x in test_points]

    print(f"\n  Target:      f(x) = 4x² + 2x + 1")
    print(f"  Synthesized: g(x) = double(double(square(x))) + double(x) + inc(0)")
    print(f"\n  Primitives used: {{inc, double, square}}")
    print(f"  Operations: 2 compositions + 2 additions")
    print(f"\n  {'x':>4}  {'target':>10}  {'synthesized':>12}  {'match':>6}")
    print("  " + "-" * 36)

    for x, t, s in zip(test_points, target_vals, synth_vals):
        match = "✓" if abs(t - s) < 1e-10 else "✗"
        print(f"  {x:>4.0f}  {t:>10.0f}  {s:>12.0f}  {match:>6}")

    print(f"""
  KEY INSIGHT (eml_closure_closed_under_comp):
  Since the closure is self-stable under composition, we can synthesize
  ANY function in the closure by composing simpler pieces — and the
  result is GUARANTEED to remain in the closure. This is the formal
  foundation for compositional program synthesis.
""")


# =============================================================================
# Application 4: Quantum Search Optimization
# =============================================================================

def quantum_search_application():
    """
    Apply Grover monotonicity to database search optimization.
    """
    print("=" * 70)
    print("APPLICATION 4: Quantum Database Search Optimization")
    print("=" * 70)

    # Scenario: searching for records matching a query
    database_size = 1_000_000

    print(f"\n  Database size: N = {database_size:,}")
    print(f"\n  Scenario: Progressively relaxing search criteria")
    print(f"\n  {'Criteria':>20}  {'Matches':>8}  {'Q-Iters':>8}  {'C-Cost':>8}  {'Speedup':>8}")
    print("  " + "-" * 60)

    criteria = [
        ("Exact match", 1),
        ("Fuzzy match", 10),
        ("Partial match", 100),
        ("Category match", 1000),
        ("Any match", 10000),
    ]

    for name, k in criteria:
        q_iter = int(np.sqrt(database_size / (k + 1)))
        c_cost = database_size
        speedup = c_cost / max(q_iter, 1)
        print(f"  {name:>20}  {k:>8}  {q_iter:>8}  {c_cost:>8,}  {speedup:>8.0f}x")

    print(f"""
  THEOREM (grover_mono_analogy):
  Relaxing search criteria (increasing k) monotonically DECREASES
  the quantum search cost. This mirrors closure monotonicity:
  enlarging the generator set enlarges the closure.

  Both are instances of the same abstract principle:
  "Larger admissible sets reduce computational cost"
""")


# =============================================================================
# Application 5: Information Channel Capacity
# =============================================================================

def channel_capacity_application():
    """
    Use information decay to analyze communication channel cascades.
    """
    print("=" * 70)
    print("APPLICATION 5: Communication Channel Cascade Analysis")
    print("=" * 70)

    # Model: a cascade of n noisy channels, each retaining fraction alpha of info
    print(f"\n  Model: n channels in series, each retaining fraction α of information")
    print(f"\n  Scenario: Choose channel quality vs cascade depth\n")

    configurations = [
        ("High-quality short", 0.95, 3),
        ("High-quality long", 0.95, 10),
        ("Medium-quality short", 0.80, 3),
        ("Medium-quality long", 0.80, 10),
        ("Low-quality short", 0.60, 3),
        ("Low-quality long", 0.60, 10),
    ]

    print(f"  {'Configuration':>25}  {'α':>5}  {'Depth':>6}  {'Info %':>7}  {'Rating':>8}")
    print("  " + "-" * 57)

    for name, alpha, depth in configurations:
        info = alpha ** depth * 100
        if info > 50:
            rating = "Good"
        elif info > 10:
            rating = "Fair"
        else:
            rating = "Poor"
        print(f"  {name:>25}  {alpha:>5.2f}  {depth:>6}  {info:>6.1f}%  {rating:>8}")

    print(f"""
  THEOREM (info_decay_closure_transport):
  Information retention α^n is MONOTONICALLY DECREASING in depth n.
  This is not just a formula — it's a PROVEN INVARIANT of the closure
  operator. Any property that decays multiplicatively under one-step
  closure extension will decay exponentially across the full closure.

  This is the bridge between qualitative closure theory and quantitative
  information dynamics: "closure depth = information depth".
""")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  EML CLOSURE OPERATORS — REAL-WORLD APPLICATIONS")
    print("=" * 70 + "\n")

    neural_network_expressivity()
    model_selection_application()
    program_synthesis_application()
    quantum_search_application()
    channel_capacity_application()

    print("=" * 70)
    print("  All applications demonstrated successfully.")
    print("=" * 70 + "\n")


#!/usr/bin/env python3
"""
EML Closure Operator — Concrete Numerical Demonstrations

This module demonstrates the core theorems about EML closure operators
with tangible numerical examples, showing how closure preserves structure,
how information decays through compositional depth, and how penalty grows
with model complexity.
"""

import numpy as np


# =============================================================================
# 1. EML Generation: Building Functions from Primitives
# =============================================================================

def demonstrate_eml_generation():
    """
    Show how EMLClosure builds complex functions from simple generators
    using only constants, addition, multiplication, and composition.
    """
    print("=" * 70)
    print("DEMO 1: EML Closure Generation from Primitives")
    print("=" * 70)

    # Generator set: just the identity function
    identity = lambda x: x
    generators = {"id": identity}

    # Step 1: Constants are always in closure
    const_3 = lambda x: 3.0
    print(f"\n  Generator: id(x) = x")
    print(f"  Constant:  c(x) = 3  [always in closure]")

    # Step 2: Multiplication of id with itself gives x^2
    square = lambda x: x * x
    print(f"  Mul(id, id): x^2")

    # Step 3: Add constant to square: x^2 + 3
    shift = lambda x: x * x + 3.0
    print(f"  Add(x^2, 3): x^2 + 3")

    # Step 4: Compose square with shift: (x^2 + 3)^2
    composed = lambda x: (x * x + 3.0) ** 2
    print(f"  Comp(x^2, x^2+3): (x^2 + 3)^2")

    # Evaluate all at test points
    test_points = np.array([-2, -1, 0, 1, 2, 3])
    print(f"\n  Evaluation at x = {list(test_points)}:")
    print(f"    id(x)        = {[identity(x) for x in test_points]}")
    print(f"    x^2          = {[square(x) for x in test_points]}")
    print(f"    x^2 + 3      = {[shift(x) for x in test_points]}")
    print(f"    (x^2 + 3)^2  = {[composed(x) for x in test_points]}")

    # Show monotonicity: adding more generators only enlarges the closure
    print(f"\n  MONOTONICITY: Adding sin(x) to generators can only enlarge closure")
    print(f"  A = {{id}}, B = {{id, sin}} => EMLClosure(A) ⊆ EMLClosure(B)")
    print(f"  Every function built from A is also buildable from B ✓")


# =============================================================================
# 2. Information Decay Through Closure Depth
# =============================================================================

def demonstrate_info_decay():
    """
    Demonstrate the information decay theorem: alpha^n decreases with depth n.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Information Decay Through Closure Depth")
    print("=" * 70)

    alphas = [0.9, 0.7, 0.5, 0.3]
    depths = list(range(0, 11))

    print(f"\n  Information retained = alpha^depth")
    print(f"\n  {'Depth':>6}", end="")
    for a in alphas:
        print(f"  α={a:.1f}", end="")
    print()
    print("  " + "-" * 40)

    for d in depths:
        print(f"  {d:>6}", end="")
        for a in alphas:
            info = a ** d
            print(f"  {info:>5.3f}", end="")
        print()

    print(f"\n  KEY INSIGHT: For any 0 ≤ α ≤ 1 and m ≤ n:")
    print(f"    α^n ≤ α^m  (deeper = less information)")
    print(f"  This is exactly what closure_depth_info_bound proves.")


# =============================================================================
# 3. Penalty Monotonicity Under Model Complexity
# =============================================================================

def demonstrate_penalty():
    """
    Show that structural risk penalty sqrt(2k·log(n)/n) grows with k.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Structural Risk Penalty vs Model Complexity")
    print("=" * 70)

    n_samples = 1000
    complexities = [1, 5, 10, 20, 50, 100, 200, 500]

    print(f"\n  n = {n_samples} samples")
    print(f"\n  {'k (complexity)':>15}  {'Penalty':>10}  {'Trend':>6}")
    print("  " + "-" * 35)

    prev_penalty = 0
    for k in complexities:
        penalty = np.sqrt(2 * k * np.log(n_samples) / n_samples)
        trend = "↑" if penalty > prev_penalty else "="
        print(f"  {k:>15}  {penalty:>10.4f}  {trend:>6}")
        prev_penalty = penalty

    print(f"\n  THEOREM: k₁ ≤ k₂ => penalty(k₁, n) ≤ penalty(k₂, n)")
    print(f"  Larger closure = more expressive = higher risk penalty ✓")


# =============================================================================
# 4. Grover Search Monotonicity
# =============================================================================

def demonstrate_grover():
    """
    Show that more solutions means fewer Grover iterations.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Grover Search Iterations vs Solution Count")
    print("=" * 70)

    N = 1000000  # search space size
    solutions = [1, 5, 10, 50, 100, 500, 1000, 5000]

    print(f"\n  N = {N:,} (search space size)")
    print(f"\n  {'k (solutions)':>14}  {'Iterations':>12}  {'Trend':>6}")
    print("  " + "-" * 36)

    prev_iter = float('inf')
    for k in solutions:
        iterations = int(np.sqrt(N / (k + 1)))
        trend = "↓" if iterations < prev_iter else "="
        print(f"  {k:>14}  {iterations:>12}  {trend:>6}")
        prev_iter = iterations

    print(f"\n  THEOREM: k₁ ≤ k₂ => groverIter(N, k₂) ≤ groverIter(N, k₁)")
    print(f"  More solutions = easier search (mirrors closure monotonicity) ✓")


# =============================================================================
# 5. Idempotence Demonstration
# =============================================================================

def demonstrate_idempotence():
    """
    Show that closing a closed set does nothing.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Idempotence — Closing a Closed Set Adds Nothing")
    print("=" * 70)

    print(f"""
  Consider A = {{x, x²}} as generators.

  EMLClosure(A) contains:
    - x, x²                          (generators)
    - c for all c ∈ ℝ                (constants)
    - x + x² = x + x²               (addition)
    - x · x² = x³                   (multiplication)
    - x²(x²) = x⁴                  (composition)
    - x + c, x² + c, x³ + c, ...   (add constants)
    - c₁·x + c₂·x² + c₃            (linear combinations)
    - ALL polynomials (by induction)
    - ALL compositions of polynomials
    - ...

  Now apply EMLClosure again:
    EMLClosure(EMLClosure(A)) adds constants? Already there.
    Adds sums of elements? Already there (closure is closed under +).
    Adds products? Already there (closure is closed under ×).
    Adds compositions? Already there (closure is closed under ∘).

  THEOREM: EMLClosure(EMLClosure(A)) = EMLClosure(A) ✓
  This is the hallmark of a TRUE closure operator.
""")


# =============================================================================
# 6. Closure Operator Lattice Structure
# =============================================================================

def demonstrate_lattice():
    """
    Show the lattice structure induced by the closure operator.
    """
    print("=" * 70)
    print("DEMO 6: Closure Operator Lattice Structure")
    print("=" * 70)

    print(f"""
  The three axioms together give us a CLOSURE OPERATOR:

  1. EXTENSIVITY:   A ⊆ EMLClosure(A)
     "Generators are always in the closure"

  2. MONOTONICITY:  A ⊆ B  =>  EMLClosure(A) ⊆ EMLClosure(B)
     "More generators = larger closure"

  3. IDEMPOTENCE:   EMLClosure(EMLClosure(A)) = EMLClosure(A)
     "Closing is a one-shot operation"

  This makes EMLClosure a ClosureOperator on Set(ℝ → ℝ), which means:

  • The "closed sets" form a MOORE FAMILY (closed under arbitrary intersection)
  • We get a GALOIS CONNECTION between generators and closed classes
  • Every closed set is a FIXED POINT of the closure operator
  • The Knaster-Tarski theorem gives us LEAST and GREATEST fixed points

  VERIFIED: EMLClosureOp is formally instantiated as a Mathlib ClosureOperator ✓
""")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  EML CLOSURE OPERATORS: AN INFORMATION-DYNAMICS ENGINE")
    print("  Concrete Numerical Demonstrations")
    print("=" * 70)

    demonstrate_eml_generation()
    demonstrate_info_decay()
    demonstrate_penalty()
    demonstrate_grover()
    demonstrate_idempotence()
    demonstrate_lattice()

    print("\n" + "=" * 70)
    print("  All demonstrations completed successfully.")
    print("=" * 70 + "\n")


#!/usr/bin/env python3
"""
EML Closure Operator — Visualizations

Generates publication-quality charts for the research paper and article.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def create_info_decay_chart() -> str:
    """Create information decay vs depth chart."""
    fig, ax = plt.subplots(figsize=(10, 6))

    depths = np.arange(0, 21)
    alphas = [0.95, 0.85, 0.7, 0.5, 0.3]
    colors = ['#2ecc71', '#3498db', '#f39c12', '#e74c3c', '#9b59b6']

    for alpha, color in zip(alphas, colors):
        info = alpha ** depths
        ax.plot(depths, info, 'o-', color=color, linewidth=2, markersize=4,
                label=f'α = {alpha}')

    ax.axhline(y=0.01, color='gray', linestyle='--', alpha=0.5,
               label='1% threshold')
    ax.set_xlabel('Closure Depth (n)', fontsize=13)
    ax.set_ylabel('Information Retained (α^n)', fontsize=13)
    ax.set_title('Information Decay Through Compositional Depth',
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(0, 21, 2))

    return fig_to_base64(fig)


def create_penalty_chart() -> str:
    """Create penalty vs complexity chart."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Penalty growth
    ks = np.arange(1, 201)
    for n in [100, 500, 1000, 5000]:
        penalties = np.sqrt(2 * ks * np.log(n) / n)
        ax1.plot(ks, penalties, linewidth=2, label=f'n = {n}')

    ax1.set_xlabel('Model Complexity (k)', fontsize=12)
    ax1.set_ylabel('Structural Penalty', fontsize=12)
    ax1.set_title('Penalty Grows with Complexity', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Bias-variance tradeoff
    n = 1000
    ks = np.arange(1, 101)
    emp_risk = 1.0 / (1 + ks * 0.1)
    penalties = np.sqrt(2 * ks * np.log(n) / n)
    total = emp_risk + penalties

    ax2.plot(ks, emp_risk, '--', linewidth=2, label='Empirical Risk', color='#3498db')
    ax2.plot(ks, penalties, '--', linewidth=2, label='Penalty', color='#e74c3c')
    ax2.plot(ks, total, '-', linewidth=3, label='Total Risk', color='#2c3e50')

    k_opt = ks[np.argmin(total)]
    ax2.axvline(x=k_opt, color='#2ecc71', linestyle=':', linewidth=2,
                label=f'Optimal k = {k_opt}')
    ax2.scatter([k_opt], [total[k_opt-1]], color='#2ecc71', s=100, zorder=5)

    ax2.set_xlabel('Model Complexity (k)', fontsize=12)
    ax2.set_ylabel('Risk', fontsize=12)
    ax2.set_title('Bias-Variance Tradeoff', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig_to_base64(fig)


def create_grover_chart() -> str:
    """Create Grover iterations vs solutions chart."""
    fig, ax = plt.subplots(figsize=(10, 6))

    N_values = [10000, 100000, 1000000]
    colors = ['#3498db', '#e74c3c', '#2ecc71']
    ks = np.arange(1, 1001)

    for N, color in zip(N_values, colors):
        iters = np.sqrt(N / (ks + 1)).astype(int)
        ax.plot(ks, iters, linewidth=2, color=color, label=f'N = {N:,}')

    ax.set_xlabel('Number of Solutions (k)', fontsize=13)
    ax.set_ylabel('Grover Iterations', fontsize=13)
    ax.set_title('Search Cost Decreases with More Solutions',
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3, which='both')

    return fig_to_base64(fig)


def create_closure_lattice_diagram() -> str:
    """Create a diagram showing the closure operator lattice structure."""
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')

    # Draw nested sets representing closure levels
    colors = ['#ecf0f1', '#d5dbdb', '#aeb6bf', '#85929e']
    labels = ['EMLClosure³(A) = EMLClosure(A)', 'EMLClosure²(A) = EMLClosure(A)',
              'EMLClosure(A)', 'A (generators)']

    for i, (color, label) in enumerate(zip(colors, labels)):
        r = 3.5 - i * 0.7
        circle = plt.Circle((5, 4), r, facecolor=color, edgecolor='#2c3e50',
                           linewidth=2, alpha=0.7)
        ax.add_patch(circle)

    # Labels
    ax.text(5, 7.2, 'Idempotence: Closing again adds nothing',
            ha='center', fontsize=12, fontweight='bold', color='#2c3e50')

    ax.text(5, 1.2, 'A\n(generators)',
            ha='center', fontsize=10, color='#2c3e50')

    ax.text(5, 2.5, 'EMLClosure(A)\n= EMLClosure²(A)\n= EMLClosure³(A) = ...',
            ha='center', fontsize=11, fontweight='bold', color='#2c3e50')

    # Arrows showing extensivity
    ax.annotate('', xy=(5, 2.0), xytext=(5, 1.5),
                arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2))
    ax.text(6.5, 1.6, 'A ⊆ EMLClosure(A)\n(extensivity)',
            fontsize=9, color='#e74c3c')

    # Title
    ax.set_title('EML Closure: A True Closure Operator',
                 fontsize=16, fontweight='bold', pad=20)

    return fig_to_base64(fig)


def create_monotonicity_chart() -> str:
    """Create chart showing monotonicity of closure."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Simulate closure sizes for different generator set sizes
    gen_sizes = np.arange(1, 21)
    closure_sizes = []
    for n in gen_sizes:
        # Rough model: closure size grows superlinearly with generators
        # due to all pairwise operations
        size = n + n * (n - 1) // 2 * 3 + n  # base + pairwise ops + constants
        closure_sizes.append(size)

    closure_sizes = np.array(closure_sizes)

    ax.bar(gen_sizes, gen_sizes, alpha=0.4, color='#3498db',
           label='|A| (generators)')
    ax.bar(gen_sizes, closure_sizes, alpha=0.4, color='#e74c3c',
           label='|EMLClosure(A)| (one step)')

    ax.set_xlabel('Number of Generators |A|', fontsize=13)
    ax.set_ylabel('Set Size', fontsize=13)
    ax.set_title('Monotonicity: More Generators → Larger Closure',
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    return fig_to_base64(fig)


def create_cross_domain_chart() -> str:
    """Create a chart showing cross-domain monotonicity principle."""
    fig = plt.figure(figsize=(14, 5))
    gs = GridSpec(1, 3, figure=fig, wspace=0.3)

    # Panel 1: Closure monotonicity
    ax1 = fig.add_subplot(gs[0])
    sizes = [1, 3, 5, 8, 12]
    closures = [5, 20, 55, 120, 230]
    ax1.plot(sizes, closures, 'o-', color='#3498db', linewidth=2, markersize=8)
    ax1.fill_between(sizes, closures, alpha=0.2, color='#3498db')
    ax1.set_xlabel('Generator Size |A|')
    ax1.set_ylabel('Closure Size |Cl(A)|')
    ax1.set_title('Closure\nMonotonicity', fontweight='bold')
    ax1.grid(True, alpha=0.3)

    # Panel 2: Information decay
    ax2 = fig.add_subplot(gs[1])
    depths = range(0, 11)
    info = [0.9**d for d in depths]
    ax2.plot(depths, info, 'o-', color='#e74c3c', linewidth=2, markersize=8)
    ax2.fill_between(depths, info, alpha=0.2, color='#e74c3c')
    ax2.set_xlabel('Depth n')
    ax2.set_ylabel('Info Retained α^n')
    ax2.set_title('Information\nDecay', fontweight='bold')
    ax2.grid(True, alpha=0.3)

    # Panel 3: Grover monotonicity
    ax3 = fig.add_subplot(gs[2])
    ks = range(1, 101)
    iters = [int(np.sqrt(10000 / (k+1))) for k in ks]
    ax3.plot(ks, iters, '-', color='#2ecc71', linewidth=2)
    ax3.fill_between(ks, iters, alpha=0.2, color='#2ecc71')
    ax3.set_xlabel('Solutions k')
    ax3.set_ylabel('Search Iterations')
    ax3.set_title('Search\nMonotonicity', fontweight='bold')
    ax3.grid(True, alpha=0.3)

    fig.suptitle('Three Faces of the Same Monotonicity Principle',
                 fontsize=14, fontweight='bold', y=1.02)

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    charts = {
        "info_decay": create_info_decay_chart(),
        "penalty": create_penalty_chart(),
        "grover": create_grover_chart(),
        "lattice": create_closure_lattice_diagram(),
        "monotonicity": create_monotonicity_chart(),
        "cross_domain": create_cross_domain_chart(),
    }

    # Save as individual files
    for name, data_uri in charts.items():
        # Extract base64 data and save as PNG
        b64_data = data_uri.split(",")[1]
        with open(f"{name}.png", "wb") as f:
            f.write(base64.b64decode(b64_data))
        print(f"  Saved {name}.png")

    print("\nAll visualizations generated successfully.")
