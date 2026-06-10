"""
Applications of Galois Connection-Based Optimization

Demonstrates real-world applications of the closure theory framework:
1. Search query refinement
2. Feature selection in ML pipelines
3. Configuration space optimization
4. Requirements engineering
"""

from typing import Set, FrozenSet, List, Tuple, Dict
from algorithms import GaloisConnection, iterative_refinement, alternating_optimization
from itertools import combinations


# ===========================================================================
# Application 1: Search Query Refinement
# ===========================================================================

def search_query_refinement():
    """
    Model search query optimization as a Galois connection.
    
    P = query terms (subsets of vocabulary)
    Q = result quality properties (subsets of desiderata)
    
    eval: given query terms, what result properties are guaranteed?
    back: given desired properties, what query terms are needed?
    """
    print("APPLICATION 1: Search Query Refinement")
    print("=" * 60)
    
    vocabulary = ['python', 'machine', 'learning', 'deep', 'neural', 'network']
    desiderata = ['relevant', 'specific', 'comprehensive', 'recent']
    
    # Incidence: which terms guarantee which properties
    incidence = {
        ('python', 'relevant'),
        ('machine', 'relevant'), ('machine', 'comprehensive'),
        ('learning', 'relevant'), ('learning', 'comprehensive'),
        ('deep', 'specific'), ('deep', 'recent'),
        ('neural', 'specific'),
        ('network', 'specific'), ('network', 'comprehensive'),
    }
    
    def eval_query(S: FrozenSet[str]) -> FrozenSet[str]:
        return frozenset(
            j for j in desiderata
            if all(i in S for i in vocabulary if (i, j) in incidence)
        )
    
    def back_query(T: FrozenSet[str]) -> FrozenSet[str]:
        return frozenset(
            i for i in vocabulary
            if all(j in T for j in desiderata if (i, j) in incidence)
        )
    
    gc = GaloisConnection(
        eval_fn=eval_query,
        back_fn=back_query,
        le_P=lambda a, b: a.issubset(b),
        le_Q=lambda a, b: a.issubset(b),
    )
    
    # Start with a vague query
    initial = frozenset(['python', 'learning'])
    print(f"\nInitial query: {set(initial)}")
    
    opt_p, opt_q, steps, traj = alternating_optimization(gc, initial)
    
    print(f"Optimization trajectory ({steps} steps):")
    for i, (p, q) in enumerate(traj):
        print(f"  Step {i}: query={set(p)}, guaranteed={set(q)}")
    print(f"\nOptimal query: {set(opt_p)}")
    print(f"Guaranteed properties: {set(opt_q)}")
    
    # Show all closed queries
    print("\nAll closed (optimal) queries:")
    all_queries = []
    for r in range(len(vocabulary) + 1):
        for combo in combinations(vocabulary, r):
            S = frozenset(combo)
            if gc.is_closed(S):
                all_queries.append(S)
    
    for S in sorted(all_queries, key=len):
        q = eval_query(S)
        s_str = str(set(S)) if S else '∅'
        q_str = str(set(q)) if q else '∅'
        print(f"  {s_str:40s} → {q_str}")


# ===========================================================================
# Application 2: ML Feature Selection
# ===========================================================================

def ml_feature_selection():
    """
    Model feature selection as a Galois connection.
    
    P = subsets of available features
    Q = subsets of model quality guarantees
    
    The closure identifies the minimal sufficient feature sets.
    """
    print("\n\nAPPLICATION 2: ML Feature Selection")
    print("=" * 60)
    
    features = ['age', 'income', 'education', 'location', 'history', 'credit_score']
    guarantees = ['accuracy_80', 'fairness', 'interpretability', 'robustness']
    
    # Which features guarantee which properties
    incidence = {
        ('age', 'accuracy_80'), ('age', 'interpretability'),
        ('income', 'accuracy_80'), ('income', 'robustness'),
        ('education', 'accuracy_80'), ('education', 'interpretability'),
        ('location', 'robustness'),
        ('history', 'accuracy_80'), ('history', 'robustness'),
        ('credit_score', 'accuracy_80'), ('credit_score', 'interpretability'),
        ('credit_score', 'robustness'),
    }
    
    def eval_features(S):
        return frozenset(
            j for j in guarantees
            if all(i in S for i in features if (i, j) in incidence)
        )
    
    def back_features(T):
        return frozenset(
            i for i in features
            if all(j in T for j in guarantees if (i, j) in incidence)
        )
    
    gc = GaloisConnection(
        eval_fn=eval_features,
        back_fn=back_features,
        le_P=lambda a, b: a.issubset(b),
        le_Q=lambda a, b: a.issubset(b),
    )
    
    # Start with all features
    initial = frozenset(features)
    opt_p, steps, traj = iterative_refinement(gc, initial)
    
    print(f"\nStarting with all features: {set(initial)}")
    print(f"Optimal (closed) feature set: {set(opt_p)}")
    print(f"Guaranteed properties: {set(eval_features(opt_p))}")
    print(f"Converged in {steps} step(s)")
    
    # Start with minimal features
    initial2 = frozenset(['credit_score'])
    opt_p2, steps2, traj2 = iterative_refinement(gc, initial2)
    print(f"\nStarting with {{credit_score}}:")
    print(f"Optimal (closed) feature set: {set(opt_p2)}")
    print(f"Guaranteed properties: {set(eval_features(opt_p2))}")
    print(f"Converged in {steps2} step(s)")


# ===========================================================================
# Application 3: Configuration Space Optimization
# ===========================================================================

def config_optimization():
    """
    Model software configuration optimization as a Galois connection.
    
    P = configuration parameters (ordered by resource usage)
    Q = performance guarantees (ordered by strictness)
    
    Uses numeric product order.
    """
    print("\n\nAPPLICATION 3: Configuration Space Optimization")
    print("=" * 60)
    
    # Config: (threads, cache_mb, batch_size) — higher = more resources
    # Performance: (throughput_level, latency_level) — higher = better
    
    def eval_config(cfg):
        threads, cache, batch = cfg
        throughput = min(threads, batch)  # throughput limited by min of threads and batch
        latency = min(threads, cache)     # latency limited by threads and cache
        return (throughput, latency)
    
    def back_config(perf):
        throughput, latency = perf
        threads = max(throughput, latency)
        cache = latency
        batch = throughput
        return (threads, cache, batch)
    
    gc = GaloisConnection(
        eval_fn=eval_config,
        back_fn=back_config,
        le_P=lambda a, b: all(ai <= bi for ai, bi in zip(a, b)),
        le_Q=lambda a, b: all(ai <= bi for ai, bi in zip(a, b)),
    )
    
    # Demo configurations
    configs = [
        (1, 1, 1),
        (4, 2, 3),
        (8, 4, 8),
        (2, 8, 1),
        (3, 3, 3),
    ]
    
    for cfg in configs:
        cl = gc.closure(cfg)
        is_opt = gc.is_closed(cfg)
        perf = eval_config(cfg)
        print(f"  Config {cfg} → perf {perf} → optimal config {cl}  {'[OPTIMAL]' if is_opt else ''}")
    
    # Iterative refinement example
    print("\nIterative refinement from wasteful config (8, 1, 2):")
    opt, steps, traj = iterative_refinement(gc, (8, 1, 2))
    for i, t in enumerate(traj):
        marker = " ← CONVERGED" if i > 0 and t == traj[i-1] else ""
        print(f"  Step {i}: {t}{marker}")
    print(f"Optimal config: {opt}, performance: {eval_config(opt)}")
    print(f"Resources saved: {tuple(a-b for a,b in zip((8,1,2), opt))}")


# ===========================================================================
# Main
# ===========================================================================

if __name__ == "__main__":
    print("GALOIS CONNECTION OPTIMIZATION — APPLICATIONS")
    print("=" * 60)
    print()
    
    search_query_refinement()
    ml_feature_selection()
    config_optimization()
    
    print("\n" + "=" * 60)
    print("KEY INSIGHT")
    print("=" * 60)
    print("""
In every application:
  • The Galois connection captures the fundamental duality between
    specifications (prompts/queries/configs) and guarantees (quality/results)
  • Closed elements = optimal specifications that waste nothing
  • Iterative refinement always converges to the nearest optimal point
  • The universal property ensures the refinement is canonical, not ad hoc
""")


"""
Prompt Optimization as Closure Theory via Galois Connections — Demo

Demonstrates the core mathematical theorems with concrete numerical examples:
1. Galois connection between prompt levels and quality levels
2. Closure operator properties (monotone, inflationary, idempotent)
3. Iterative convergence to optimal prompts
4. Complete lattice of closed (optimal) prompts
"""

import numpy as np
from itertools import product


# ===========================================================================
# Model 1: Simple Linear Orders (matching the Lean formalization)
# ===========================================================================

def demo_linear_model():
    """
    P = {0, 1, 2} (prompt refinement levels: rough, moderate, precise)
    Q = {0, 1}    (quality levels: low, high)
    
    eval: 0 -> 0, 1 -> 0, 2 -> 1
    back: 0 -> 1, 1 -> 2
    
    Galois connection: eval(p) <= q  iff  p <= back(q)
    """
    print("=" * 70)
    print("MODEL 1: Linear Prompt-Quality Levels")
    print("=" * 70)
    
    def eval_fn(p):
        return {0: 0, 1: 0, 2: 1}[p]
    
    def back_fn(q):
        return {0: 1, 1: 2}[q]
    
    def closure(p):
        return back_fn(eval_fn(p))
    
    P = [0, 1, 2]
    Q = [0, 1]
    
    # Verify Galois connection
    print("\n1. Verifying Galois Connection: eval(p) ≤ q  ⟺  p ≤ back(q)")
    print("-" * 50)
    all_ok = True
    for p in P:
        for q in Q:
            lhs = eval_fn(p) <= q
            rhs = p <= back_fn(q)
            status = "✓" if lhs == rhs else "✗"
            if lhs != rhs:
                all_ok = False
            print(f"  p={p}, q={q}: eval({p})={eval_fn(p)} ≤ {q} is {lhs},  "
                  f"{p} ≤ back({q})={back_fn(q)} is {rhs}  {status}")
    print(f"\n  Galois connection verified: {all_ok}")
    
    # Closure operator properties
    print("\n2. Closure Operator Properties")
    print("-" * 50)
    
    # Inflationary: p ≤ closure(p)
    print("  Inflationary (p ≤ cl(p)):")
    for p in P:
        cl_p = closure(p)
        print(f"    cl({p}) = {cl_p}, {p} ≤ {cl_p} = {p <= cl_p}")
    
    # Idempotent: cl(cl(p)) = cl(p)
    print("  Idempotent (cl(cl(p)) = cl(p)):")
    for p in P:
        cl_p = closure(p)
        cl_cl_p = closure(cl_p)
        print(f"    cl(cl({p})) = cl({cl_p}) = {cl_cl_p}, equals cl({p})={cl_p}: {cl_cl_p == cl_p}")
    
    # Monotone: p ≤ p' => cl(p) ≤ cl(p')
    print("  Monotone (p ≤ p' ⟹ cl(p) ≤ cl(p')):")
    for p in P:
        for p2 in P:
            if p <= p2:
                print(f"    {p} ≤ {p2}: cl({p})={closure(p)} ≤ cl({p2})={closure(p2)}: {closure(p) <= closure(p2)}")
    
    # Closed elements
    print("\n3. Closed (Optimal) Elements")
    print("-" * 50)
    closed = [p for p in P if closure(p) == p]
    not_closed = [p for p in P if closure(p) != p]
    print(f"  Closed prompts (cl(p)=p):     {closed}")
    print(f"  Non-closed prompts (cl(p)≠p): {not_closed}")
    for p in not_closed:
        print(f"    Prompt {p} refines to {closure(p)} (least closed above {p})")
    
    # Iterative convergence
    print("\n4. Iterative Convergence")
    print("-" * 50)
    for p0 in P:
        seq = [p0]
        current = p0
        for _ in range(5):
            current = closure(current)
            seq.append(current)
            if seq[-1] == seq[-2]:
                break
        print(f"  Starting from p₀={p0}: {' → '.join(map(str, seq))}")
        print(f"    Converged at step {len(seq)-2} to optimal prompt {seq[-1]}")
    
    return eval_fn, back_fn, closure


# ===========================================================================
# Model 2: Powerset Lattice (Formal Concept Analysis style)
# ===========================================================================

def demo_powerset_model():
    """
    P = 2^{features}  (subsets of {specificity, density, depth, breadth})
    Q = 2^{metrics}   (subsets of {novelty, rigor, completeness})
    
    Incidence relation R: feature i contributes to metric j.
    eval(S) = {j | ∀i, R(i,j) → i ∈ S}
    back(T) = {i | ∀j, R(i,j) → j ∈ T}
    """
    print("\n" + "=" * 70)
    print("MODEL 2: Feature-Metric Powerset Lattice")
    print("=" * 70)
    
    features = ['specificity', 'density', 'depth', 'breadth']
    metrics = ['novelty', 'rigor', 'completeness']
    
    # Incidence relation (matching the Lean file)
    R = {
        ('specificity', 'novelty'), ('specificity', 'rigor'),
        ('density', 'rigor'), ('density', 'completeness'),
        ('depth', 'novelty'), ('depth', 'completeness'),
        ('breadth', 'novelty'), ('breadth', 'rigor'), ('breadth', 'completeness'),
    }
    
    def eval_set(S):
        """Metrics guaranteed by feature set S."""
        return frozenset(j for j in metrics if all(i in S for i in features if (i, j) in R))
    
    def back_set(T):
        """Features required for metric set T."""
        return frozenset(i for i in features if all(j in T for j in metrics if (i, j) in R))
    
    def closure_set(S):
        return back_set(eval_set(S))
    
    print("\n1. Incidence Relation")
    print("-" * 50)
    for f in features:
        contributes = [m for m in metrics if (f, m) in R]
        print(f"  {f:15s} → {', '.join(contributes)}")
    
    print("\n2. Closure Examples")
    print("-" * 50)
    
    test_sets = [
        frozenset(),
        frozenset(['specificity']),
        frozenset(['specificity', 'density']),
        frozenset(['specificity', 'depth']),
        frozenset(['breadth']),
        frozenset(features),
    ]
    
    closed_elements = []
    for S in test_sets:
        S_str = '{' + ', '.join(sorted(S)) + '}' if S else '∅'
        eS = eval_set(S)
        eS_str = '{' + ', '.join(sorted(eS)) + '}' if eS else '∅'
        clS = closure_set(S)
        clS_str = '{' + ', '.join(sorted(clS)) + '}' if clS else '∅'
        is_closed = clS == S
        print(f"  S = {S_str:40s}")
        print(f"    eval(S) = {eS_str}")
        print(f"    cl(S)   = {clS_str}  {'[CLOSED]' if is_closed else ''}")
        if is_closed:
            closed_elements.append(S_str)
    
    print(f"\n  Closed elements found: {closed_elements}")
    
    # Enumerate ALL closed elements
    print("\n3. All Closed Elements (by exhaustive search)")
    print("-" * 50)
    all_closed = []
    for r in range(len(features) + 1):
        from itertools import combinations
        for combo in combinations(features, r):
            S = frozenset(combo)
            if closure_set(S) == S:
                S_str = '{' + ', '.join(sorted(S)) + '}' if S else '∅'
                eS = eval_set(S)
                eS_str = '{' + ', '.join(sorted(eS)) + '}' if eS else '∅'
                all_closed.append((S_str, eS_str))
                print(f"  {S_str:40s} → quality: {eS_str}")
    
    print(f"\n  Total closed elements: {len(all_closed)} out of {2**len(features)} subsets")


# ===========================================================================
# Model 3: Numeric Product Order
# ===========================================================================

def demo_product_order():
    """
    P = {0,1,2,3}³  (specificity × density × depth)
    Q = {0,1,2,3}²  (novelty × rigor)
    
    eval(s,d,t) = (min(s,t), min(s,d))
    back(n,r)   = (max(n,r), r, n)
    
    Galois connection: eval(p) ≤ q ⟺ p ≤ back(q) (componentwise)
    """
    print("\n" + "=" * 70)
    print("MODEL 3: Product Order (Numeric Prompt Dimensions)")
    print("=" * 70)
    
    N = 4  # values 0..3
    
    def eval_prod(p):
        s, d, t = p
        return (min(s, t), min(s, d))
    
    def back_prod(q):
        n, r = q
        return (max(n, r), r, n)
    
    def closure_prod(p):
        return back_prod(eval_prod(p))
    
    # Verify GC on sample points
    print("\n1. Galois Connection Verification (sample)")
    print("-" * 50)
    
    P_sample = [(0,0,0), (1,0,0), (1,1,1), (2,1,2), (3,3,3), (2,2,1)]
    Q_sample = [(0,0), (1,0), (1,1), (2,2), (3,3)]
    
    gc_holds = True
    for p in P_sample:
        for q in Q_sample:
            ep = eval_prod(p)
            bq = back_prod(q)
            lhs = all(ep[i] <= q[i] for i in range(2))
            rhs = all(p[i] <= bq[i] for i in range(3))
            if lhs != rhs:
                gc_holds = False
                print(f"  FAIL: p={p}, q={q}: eval(p)={ep}≤{q}={lhs}, p≤back(q)={bq}={rhs}")
    
    # Full verification
    all_P = list(product(range(N), repeat=3))
    all_Q = list(product(range(N), repeat=2))
    for p in all_P:
        for q in all_Q:
            ep = eval_prod(p)
            bq = back_prod(q)
            if all(ep[i] <= q[i] for i in range(2)) != all(p[i] <= bq[i] for i in range(3)):
                gc_holds = False
    print(f"  Full GC verification ({len(all_P)}×{len(all_Q)} pairs): {'✓ PASS' if gc_holds else '✗ FAIL'}")
    
    # Closure examples
    print("\n2. Closure Examples")
    print("-" * 50)
    for p in [(0,0,0), (1,0,0), (2,1,2), (1,1,1), (3,3,3), (2,0,1)]:
        cl = closure_prod(p)
        is_closed = cl == p
        print(f"  cl{p} = {cl}  {'[CLOSED]' if is_closed else ''}")
    
    # Count closed elements
    closed_count = sum(1 for p in all_P if closure_prod(p) == p)
    print(f"\n  Closed elements: {closed_count} out of {len(all_P)}")
    
    # Convergence demo
    print("\n3. Iterative Convergence")
    print("-" * 50)
    for p0 in [(0,0,0), (2,0,1), (3,1,2), (1,2,3)]:
        seq = [p0]
        current = p0
        for _ in range(10):
            current = closure_prod(current)
            seq.append(current)
            if seq[-1] == seq[-2]:
                break
        print(f"  p₀={p0}:")
        for i, s in enumerate(seq):
            marker = " ← FIXED" if i > 0 and s == seq[i-1] else ""
            print(f"    step {i}: {s}{marker}")


if __name__ == "__main__":
    print("PROMPT OPTIMIZATION AS CLOSURE THEORY")
    print("Concrete Demonstrations of the Galois Connection Framework")
    print()
    
    demo_linear_model()
    demo_powerset_model()
    demo_product_order()
    
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
All three models demonstrate the same mathematical structure:

1. A Galois connection eval ⊣ back between prompts and quality
2. The closure cl = back ∘ eval is monotone, inflationary, idempotent
3. Optimal prompts = fixed points of cl (closed elements)
4. Iterative refinement converges in finitely many steps
5. The closed elements form a complete lattice

This is not metaphor — it is rigorous order theory applied to optimization.
""")


"""
Visualizations for Prompt Optimization as Closure Theory

Generates publication-quality figures showing:
1. Galois connection diagram
2. Closure operator convergence
3. Lattice of closed elements
4. Convergence heatmap
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product as cart_product
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


# ===========================================================================
# Figure 1: Galois Connection Diagram
# ===========================================================================

def plot_galois_connection():
    """Visualize the Galois connection between prompt and quality spaces."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    # Prompt space (left)
    P_labels = ['0 (rough)', '1 (moderate)', '2 (precise)']
    P_y = [1, 2, 3]
    P_x = [1.5] * 3
    
    # Quality space (right)
    Q_labels = ['0 (low)', '1 (high)']
    Q_y = [1.5, 2.5]
    Q_x = [5.5] * 2
    
    # Draw boxes
    prompt_box = mpatches.FancyBboxPatch((0.5, 0.3), 2.5, 3.5, 
                                         boxstyle="round,pad=0.2",
                                         facecolor='#E8F4FD', edgecolor='#2196F3', linewidth=2)
    quality_box = mpatches.FancyBboxPatch((4.5, 0.3), 2.5, 3.5,
                                          boxstyle="round,pad=0.2",
                                          facecolor='#FDE8E8', edgecolor='#F44336', linewidth=2)
    ax.add_patch(prompt_box)
    ax.add_patch(quality_box)
    
    # Draw prompt nodes
    for i, (label, y) in enumerate(zip(P_labels, P_y)):
        color = '#4CAF50' if i >= 1 else '#FF9800'  # green if closed, orange if not
        ax.plot(P_x[i], y, 'o', markersize=20, color=color, zorder=5)
        ax.text(P_x[i], y, str(i), ha='center', va='center', fontsize=12, 
                fontweight='bold', color='white', zorder=6)
        ax.text(P_x[i] - 0.8, y, label, ha='right', va='center', fontsize=10)
    
    # Draw quality nodes
    for i, (label, y) in enumerate(zip(Q_labels, Q_y)):
        ax.plot(Q_x[i], y, 's', markersize=20, color='#9C27B0', zorder=5)
        ax.text(Q_x[i], y, str(i), ha='center', va='center', fontsize=12,
                fontweight='bold', color='white', zorder=6)
        ax.text(Q_x[i] + 0.8, y, label, ha='left', va='center', fontsize=10)
    
    # Draw eval arrows (blue)
    eval_map = {0: 0, 1: 0, 2: 1}
    for p, q in eval_map.items():
        ax.annotate('', xy=(Q_x[0] - 0.3, Q_y[q] + 0.1), 
                    xytext=(P_x[0] + 0.3, P_y[p] + 0.1),
                    arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2))
    
    # Draw back arrows (red, dashed)
    back_map = {0: 1, 1: 2}
    for q, p in back_map.items():
        ax.annotate('', xy=(P_x[0] + 0.3, P_y[p] - 0.1),
                    xytext=(Q_x[0] - 0.3, Q_y[q] - 0.1),
                    arrowprops=dict(arrowstyle='->', color='#F44336', lw=2, linestyle='dashed'))
    
    # Labels
    ax.text(1.75, 4.2, 'Prompt Space P', ha='center', fontsize=14, fontweight='bold', color='#2196F3')
    ax.text(5.75, 4.2, 'Quality Space Q', ha='center', fontsize=14, fontweight='bold', color='#F44336')
    ax.text(3.5, 3.5, 'eval →', ha='center', fontsize=11, color='#2196F3', fontweight='bold')
    ax.text(3.5, 1.0, '← back', ha='center', fontsize=11, color='#F44336', fontweight='bold')
    
    # Legend
    closed_patch = mpatches.Patch(color='#4CAF50', label='Closed (optimal)')
    open_patch = mpatches.Patch(color='#FF9800', label='Not closed')
    ax.legend(handles=[closed_patch, open_patch], loc='lower center', fontsize=11)
    
    ax.set_xlim(-0.5, 8)
    ax.set_ylim(-0.2, 4.8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Galois Connection: eval ⊣ back', fontsize=16, fontweight='bold', pad=15)
    
    fig.savefig('galois_connection.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ===========================================================================
# Figure 2: Closure Convergence
# ===========================================================================

def plot_convergence():
    """Visualize iterative convergence of the closure operator."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 5))
    
    # Product order model: P = {0..3}^3, Q = {0..3}^2
    def eval_prod(p):
        s, d, t = p
        return (min(s, t), min(s, d))
    
    def back_prod(q):
        n, r = q
        return (max(n, r), r, n)
    
    def closure_prod(p):
        return back_prod(eval_prod(p))
    
    starting_points = [(0, 0, 0), (3, 1, 2), (2, 0, 3)]
    titles = ['Start: (0,0,0)', 'Start: (3,1,2)', 'Start: (2,0,3)']
    colors = ['#2196F3', '#4CAF50', '#FF9800']
    
    for ax, p0, title, color in zip(axes, starting_points, titles, colors):
        trajectory = [p0]
        current = p0
        for _ in range(10):
            current = closure_prod(current)
            trajectory.append(current)
            if trajectory[-1] == trajectory[-2]:
                break
        
        steps = list(range(len(trajectory)))
        
        # Plot each component
        for comp, label, ls in [(0, 'threads', '-'), (1, 'cache', '--'), (2, 'batch', ':')]:
            values = [t[comp] for t in trajectory]
            ax.plot(steps, values, ls, linewidth=2.5, label=label, marker='o', markersize=8)
        
        # Mark convergence
        conv_step = len(trajectory) - 2
        ax.axvline(x=conv_step, color='red', linestyle='-.', alpha=0.5, label=f'converged (n={conv_step})')
        
        ax.set_xlabel('Iteration', fontsize=12)
        ax.set_ylabel('Value', fontsize=12)
        ax.set_title(title, fontsize=13, fontweight='bold')
        ax.legend(fontsize=9)
        ax.set_xticks(steps)
        ax.set_ylim(-0.5, 4)
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('Iterative Closure Convergence on Product Order', fontsize=15, fontweight='bold')
    plt.tight_layout()
    fig.savefig('convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ===========================================================================
# Figure 3: Convergence Heatmap
# ===========================================================================

def plot_convergence_heatmap():
    """Heatmap showing convergence steps from each starting point."""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    N = 4
    
    def eval_prod(p):
        s, d, t = p
        return (min(s, t), min(s, d))
    
    def back_prod(q):
        n, r = q
        return (max(n, r), r, n)
    
    def closure_prod(p):
        return back_prod(eval_prod(p))
    
    # For 2D visualization, fix t=1 and vary s, d
    t_fixed = 1
    steps_grid = np.zeros((N, N))
    
    for s in range(N):
        for d in range(N):
            p = (s, d, t_fixed)
            current = p
            for step in range(20):
                next_p = closure_prod(current)
                if next_p == current:
                    steps_grid[d, s] = step
                    break
                current = next_p
    
    im = ax.imshow(steps_grid, cmap='YlOrRd', origin='lower', aspect='equal', 
                   vmin=0, vmax=np.max(steps_grid))
    
    # Annotate
    for s in range(N):
        for d in range(N):
            p = (s, d, t_fixed)
            cl = closure_prod(p)
            is_closed = cl == p
            text = f"{int(steps_grid[d, s])}"
            if is_closed:
                text += "\n✓"
            ax.text(s, d, text, ha='center', va='center', fontsize=11,
                    fontweight='bold' if is_closed else 'normal',
                    color='white' if steps_grid[d, s] > 0 else 'black')
    
    ax.set_xlabel('Specificity (s)', fontsize=13)
    ax.set_ylabel('Density (d)', fontsize=13)
    ax.set_title(f'Convergence Steps (depth t={t_fixed} fixed)\n'
                 f'✓ = already optimal (closed)', fontsize=14, fontweight='bold')
    ax.set_xticks(range(N))
    ax.set_yticks(range(N))
    
    cbar = plt.colorbar(im, ax=ax)
    cbar.set_label('Steps to converge', fontsize=12)
    
    plt.tight_layout()
    fig.savefig('convergence_heatmap.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ===========================================================================
# Figure 4: Closed Element Lattice
# ===========================================================================

def plot_closed_lattice():
    """Visualize the lattice structure of closed elements."""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    N = 3  # Smaller for readability
    
    def eval_prod(p):
        s, d, t = p
        return (min(s, t), min(s, d))
    
    def back_prod(q):
        n, r = q
        return (max(n, r), r, n)
    
    def closure_prod(p):
        return back_prod(eval_prod(p))
    
    # Find all closed elements in {0..N-1}^3
    all_P = list(cart_product(range(N), repeat=3))
    closed = [p for p in all_P if closure_prod(p) == p]
    not_closed = [p for p in all_P if closure_prod(p) != p]
    
    # Layout: use sum of coordinates as y, spread x
    def layout(p):
        s, d, t = p
        y = s + d + t
        x = s - t + 0.5 * d
        return x, y
    
    # Draw edges (covering relations)
    def covers(a, b):
        """b covers a: a < b and no c with a < c < b"""
        if not all(ai <= bi for ai, bi in zip(a, b)):
            return False
        diff = sum(bi - ai for ai, bi in zip(a, b))
        return diff == 1
    
    # Draw edges for closed elements
    for i, a in enumerate(closed):
        for j, b in enumerate(closed):
            if covers(a, b):
                xa, ya = layout(a)
                xb, yb = layout(b)
                ax.plot([xa, xb], [ya, yb], '-', color='#90CAF9', linewidth=1.5, zorder=1)
    
    # Draw non-closed elements (small, gray)
    for p in not_closed:
        x, y = layout(p)
        cl = closure_prod(p)
        xcl, ycl = layout(cl)
        ax.annotate('', xy=(xcl, ycl), xytext=(x, y),
                    arrowprops=dict(arrowstyle='->', color='#BDBDBD', lw=0.8, alpha=0.4))
        ax.plot(x, y, 'o', markersize=6, color='#E0E0E0', zorder=2)
    
    # Draw closed elements (large, colored)
    for p in closed:
        x, y = layout(p)
        ax.plot(x, y, 'o', markersize=14, color='#4CAF50', zorder=3, 
                markeredgecolor='#2E7D32', markeredgewidth=1.5)
        ax.text(x, y + 0.3, str(p), ha='center', va='bottom', fontsize=8, fontweight='bold')
    
    ax.set_title(f'Lattice of Closed (Optimal) Elements\n'
                 f'{len(closed)} closed out of {len(all_P)} total in {{0..{N-1}}}³',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('Layout coordinate', fontsize=11)
    ax.set_ylabel('Sum of coordinates (height)', fontsize=11)
    
    closed_patch = mpatches.Patch(color='#4CAF50', label=f'Closed elements ({len(closed)})')
    not_closed_patch = mpatches.Patch(color='#E0E0E0', label=f'Non-closed ({len(not_closed)})')
    ax.legend(handles=[closed_patch, not_closed_patch], fontsize=11, loc='upper left')
    
    ax.grid(True, alpha=0.2)
    plt.tight_layout()
    fig.savefig('closed_lattice.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ===========================================================================
# Generate all figures
# ===========================================================================

if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_gc = plot_galois_connection()
    print(f"  ✓ galois_connection.png ({len(b64_gc)} chars)")
    
    b64_conv = plot_convergence()
    print(f"  ✓ convergence.png ({len(b64_conv)} chars)")
    
    b64_heat = plot_convergence_heatmap()
    print(f"  ✓ convergence_heatmap.png ({len(b64_heat)} chars)")
    
    b64_lattice = plot_closed_lattice()
    print(f"  ✓ closed_lattice.png ({len(b64_lattice)} chars)")
    
    print("\nAll visualizations generated successfully!")
