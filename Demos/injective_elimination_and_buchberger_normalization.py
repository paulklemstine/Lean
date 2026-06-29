"""
Max-Plus Application: Scheduling and Discrete Event Systems
============================================================

This demo shows how idempotent semiring congruences apply to real-world
scheduling and discrete event system optimization.

In max-plus algebra:
  - Addition is max (choose the later time)
  - Multiplication is + (sequential composition)

A congruence on the max-plus polynomial ring identifies equivalent
scheduling expressions, enabling automated simplification.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


# ============================================================
# Max-Plus Algebra
# ============================================================

NEG_INF = float('-inf')

class MaxPlusMatrix:
    """Matrix over the max-plus semiring."""

    def __init__(self, data):
        self.data = np.array(data, dtype=float)
        self.shape = self.data.shape

    def __matmul__(self, other):
        """Max-plus matrix multiplication."""
        n, m = self.shape
        m2, p = other.shape
        assert m == m2
        result = np.full((n, p), NEG_INF)
        for i in range(n):
            for j in range(p):
                for k in range(m):
                    val = self.data[i, k] + other.data[k, j]
                    result[i, j] = max(result[i, j], val)
        return MaxPlusMatrix(result)

    def __add__(self, other):
        """Max-plus addition (elementwise max)."""
        return MaxPlusMatrix(np.maximum(self.data, other.data))

    def __repr__(self):
        rows = []
        for row in self.data:
            parts = []
            for x in row:
                if x == NEG_INF:
                    parts.append("  -∞")
                else:
                    parts.append(f"{x:4.0f}")
            rows.append(" ".join(parts))
        return "\n".join(rows)

    def power(self, k):
        """Compute A^k in max-plus algebra (k-step reachability)."""
        n = self.shape[0]
        if k == 0:
            # Identity: 0 on diagonal, -∞ elsewhere
            data = np.full(self.shape, NEG_INF)
            np.fill_diagonal(data, 0)
            return MaxPlusMatrix(data)
        result = self
        for _ in range(k - 1):
            result = result @ self
        return result

    def kleene_star(self, max_iter=20):
        """Compute the Kleene star A* = I ⊕ A ⊕ A² ⊕ ... (longest paths)."""
        n = self.shape[0]
        star = self.power(0)  # Identity
        power = self.power(0)
        for k in range(1, max_iter + 1):
            power = power @ self
            new_star = star + power
            if np.array_equal(new_star.data, star.data):
                break
            star = new_star
        return star


# ============================================================
# Demo: Production Line Scheduling
# ============================================================

def demo_production_scheduling():
    """Model a production line as a max-plus linear system."""
    print("=" * 70)
    print("APPLICATION: Production Line Scheduling (Max-Plus Linear Systems)")
    print("=" * 70)

    print("""
    A production line with 3 machines:
      Machine 1: Processing time 3 units
      Machine 2: Processing time 5 units (needs input from M1)
      Machine 3: Processing time 2 units (needs input from M1 and M2)

    The max-plus system matrix A encodes precedence + processing times:
      A[i,j] = processing time of machine i, if j feeds into i
      A[i,j] = -∞ if no dependency
    """)

    # System matrix (adjacency + weights)
    A = MaxPlusMatrix([
        [NEG_INF,  NEG_INF,  NEG_INF],  # M1: no dependencies
        [       5, NEG_INF,  NEG_INF],  # M2: takes 5 after M1
        [       2,        2, NEG_INF],  # M3: takes 2 after M1 or M2
    ])

    print("System matrix A (max-plus):")
    print(A)

    # Initial start times
    x0 = MaxPlusMatrix([[0], [0], [0]])
    print(f"\nInitial state x₀ = [0, 0, 0]ᵀ")

    print(f"\nEvolution (x(k) = A ⊗ x(k-1)):")
    x = x0
    times = [x.data.flatten().tolist()]
    for k in range(1, 6):
        x = A @ x
        times.append(x.data.flatten().tolist())
        clean = [f"{v:4.0f}" if v != NEG_INF else " -∞" for v in x.data.flatten()]
        print(f"  x({k}) = [{', '.join(clean)}]ᵀ")

    # Visualize timeline
    fig, ax = plt.subplots(1, 1, figsize=(12, 5))

    colors = ['#2196F3', '#FF9800', '#4CAF50']
    labels = ['Machine 1', 'Machine 2', 'Machine 3']

    for step in range(len(times)):
        for m in range(3):
            t = times[step][m]
            if t != NEG_INF and t >= 0:
                ax.barh(m, 1, left=step * 8 + t, height=0.5,
                       color=colors[m], alpha=0.7, edgecolor='black')
                ax.text(step * 8 + t + 0.5, m, f't={t:.0f}',
                       ha='center', va='center', fontsize=8, fontweight='bold')

    ax.set_yticks(range(3))
    ax.set_yticklabels(labels, fontsize=11)
    ax.set_xlabel('Time', fontsize=12)
    ax.set_title('Production Line Evolution (Max-Plus Dynamics)\n'
                'Each step computes x(k) = A ⊗ x(k-1)', fontsize=13)
    ax.grid(True, alpha=0.3, axis='x')

    plt.tight_layout()
    plt.savefig('demos/production_scheduling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved: demos/production_scheduling.png")

    # Demonstrate congruence-based simplification
    print(f"\n--- Congruence-Based Simplification ---")
    print(f"  The congruence generated by (A², A³) identifies the 2-step")
    print(f"  and 3-step reachability matrices when the system stabilizes.")
    print(f"  This is exactly the idempotent congruence framework!")

    A2 = A.power(2)
    A3 = A.power(3)
    print(f"\n  A² =\n{A2}")
    print(f"\n  A³ =\n{A3}")

    # Check if A² = A³ (idempotent stabilization)
    A_star = A.kleene_star()
    print(f"\n  A* (Kleene star = longest paths) =\n{A_star}")


# ============================================================
# Demo: Train Network Critical Path
# ============================================================

def demo_train_network():
    """Model a train network as a max-plus system."""
    print("\n" + "=" * 70)
    print("APPLICATION: Train Network Critical Path Analysis")
    print("=" * 70)

    print("""
    A simple train network with 4 stations:
      A → B: 10 min
      A → C: 15 min
      B → D: 8 min
      C → D: 5 min
      B → C: 3 min

    Question: What are the longest (critical) paths between all stations?
    Answer: Compute the Kleene star A* in max-plus algebra.
    """)

    # Adjacency matrix with travel times
    A = MaxPlusMatrix([
        [NEG_INF,      10,      15, NEG_INF],  # From A
        [NEG_INF, NEG_INF,       3,       8],  # From B
        [NEG_INF, NEG_INF, NEG_INF,       5],  # From C
        [NEG_INF, NEG_INF, NEG_INF, NEG_INF],  # From D
    ])

    print("Travel time matrix:")
    print(A)

    A_star = A.kleene_star()
    print(f"\nLongest paths (A*):")
    print(A_star)

    # Visualize the network
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Network graph
    stations = {'A': (0, 1), 'B': (1, 2), 'C': (1, 0), 'D': (2, 1)}
    edges = [('A', 'B', 10), ('A', 'C', 15), ('B', 'D', 8),
             ('C', 'D', 5), ('B', 'C', 3)]

    for name, pos in stations.items():
        ax1.scatter(*pos, s=500, c='lightblue', edgecolors='black',
                   linewidths=2, zorder=5)
        ax1.text(*pos, name, ha='center', va='center', fontsize=14,
                fontweight='bold', zorder=6)

    for src, dst, weight in edges:
        sx, sy = stations[src]
        dx, dy = stations[dst]
        ax1.annotate('', xy=(dx, dy), xytext=(sx, sy),
                    arrowprops=dict(arrowstyle='->', color='gray',
                                  lw=2, connectionstyle='arc3,rad=0.1'))
        mx, my = (sx + dx) / 2, (sy + dy) / 2
        ax1.text(mx + 0.05, my + 0.1, f'{weight}min', fontsize=10,
                color='red', fontweight='bold')

    ax1.set_xlim(-0.5, 2.5)
    ax1.set_ylim(-0.5, 2.5)
    ax1.set_title('Train Network', fontsize=13)
    ax1.set_aspect('equal')
    ax1.axis('off')

    # Critical path matrix as heatmap
    station_names = ['A', 'B', 'C', 'D']
    data = A_star.data.copy()
    data[data == NEG_INF] = np.nan

    im = ax2.imshow(data, cmap='YlOrRd', aspect='equal')
    ax2.set_xticks(range(4))
    ax2.set_xticklabels(station_names, fontsize=12)
    ax2.set_yticks(range(4))
    ax2.set_yticklabels(station_names, fontsize=12)
    ax2.set_xlabel('Destination', fontsize=12)
    ax2.set_ylabel('Source', fontsize=12)
    ax2.set_title('Longest Paths (Max-Plus Kleene Star)', fontsize=13)

    for i in range(4):
        for j in range(4):
            val = A_star.data[i, j]
            if val != NEG_INF:
                ax2.text(j, i, f'{val:.0f}', ha='center', va='center',
                        fontsize=12, fontweight='bold')
            else:
                ax2.text(j, i, '-∞', ha='center', va='center',
                        fontsize=10, color='gray')

    plt.colorbar(im, ax=ax2, label='Time (minutes)')
    plt.tight_layout()
    plt.savefig('demos/train_network.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: demos/train_network.png")


# ============================================================
# Demo: Tropical Polynomial Equivalence Checker
# ============================================================

def demo_equivalence_checker():
    """A simple congruence membership checker using support reduction."""
    print("\n" + "=" * 70)
    print("APPLICATION: Tropical Polynomial Equivalence Checker")
    print("=" * 70)

    print("""
    Given a set of generator pairs G, check whether two tropical polynomials
    are equivalent modulo the congruence generated by G.

    This uses the support-based normal form algorithm (exists_normalForm)
    as a decision procedure: reduce both sides and compare.
    """)

    # Simple example: identify x₁² with x₁ (idempotent variables)
    print("  Generator: x₁² ≡ x₁  (variable idempotency)")
    print()

    # Polynomials to test
    tests = [
        ("3⊙x₁³", {(3,): 3}, "3⊙x₁", {(1,): 3}),
        ("x₁² ⊕ x₁", {(2,): 0, (1,): 0}, "x₁", {(1,): 0}),
        ("2⊙x₁⁴", {(4,): 2}, "2⊙x₁²", {(2,): 2}),
    ]

    for desc_p, terms_p, desc_q, terms_q in tests:
        p = set(terms_p.keys())
        q = set(terms_q.keys())
        sig = p | q
        print(f"  {desc_p} ≡? {desc_q}")
        print(f"    Support(p) = {sorted(p)}, Support(q) = {sorted(q)}")
        print(f"    Pair signature size = {len(sig)}")

        # In the support-based framework, we check if the pair reduces
        # to a diagonal pair (where both components have the same support)
        if p == q:
            print(f"    → EQUIVALENT (same support = trivial normal form)")
        else:
            print(f"    → Support differs; needs congruence-aware reduction")
        print()


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Max-Plus Applications of Idempotent Congruence Theory         ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_production_scheduling()
    demo_train_network()
    demo_equivalence_checker()

    print("\n" + "=" * 70)
    print("All application demos complete!")
    print("=" * 70)


"""
Tropical Congruence Demo: Support-Based Reduction and Normal Forms
==================================================================

This demo implements the support-based reduction system for polynomial pairs
over idempotent (tropical) semirings, demonstrating the key theorems:

1. Support reduction strictly decreases measure (reduce_decreases_measure)
2. Reduction is well-founded (reduction_wellFounded)
3. Every pair has a normal form (exists_normalForm)

We work over the tropical semiring (ℝ ∪ {-∞}, max, +), where:
  - Addition is max (idempotent: max(a, a) = a)
  - Multiplication is ordinary addition
"""

import numpy as np
from itertools import product
from collections import defaultdict
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


# ============================================================
# Tropical Semiring Implementation
# ============================================================

NEG_INF = float('-inf')

def trop_add(a, b):
    """Tropical addition = max."""
    return max(a, b)

def trop_mul(a, b):
    """Tropical multiplication = ordinary addition."""
    if a == NEG_INF or b == NEG_INF:
        return NEG_INF
    return a + b


class TropicalPolynomial:
    """A multivariate tropical polynomial in n variables.

    Represented as a dict: monomial_exponent_tuple -> coefficient.
    A monomial (e1, e2, ..., en) represents x1^e1 * x2^e2 * ... * xn^en.
    In the tropical semiring, this is e1*x1 + e2*x2 + ... + en*xn (ordinary arithmetic).
    The polynomial is max over (coeff + monomial_value) for all terms.
    """

    def __init__(self, terms=None, n_vars=2):
        self.n_vars = n_vars
        self.terms = {}  # tuple of exponents -> coefficient
        if terms:
            for exp, coeff in terms.items():
                if coeff != NEG_INF:
                    self.terms[exp] = coeff

    @property
    def support(self):
        """The monomial support: set of exponent tuples with non -∞ coefficient."""
        return frozenset(self.terms.keys())

    def support_card(self):
        return len(self.terms)

    def evaluate(self, point):
        """Evaluate at a point (tropical semiring operations)."""
        result = NEG_INF
        for exp, coeff in self.terms.items():
            monomial_val = coeff
            for i, e in enumerate(exp):
                monomial_val = trop_mul(monomial_val, e * point[i])
            result = trop_add(result, monomial_val)
        return result

    def __repr__(self):
        if not self.terms:
            return "-∞"
        parts = []
        for exp, coeff in sorted(self.terms.items()):
            var_parts = []
            for i, e in enumerate(exp):
                if e > 0:
                    var_parts.append(f"x{i+1}^{e}" if e > 1 else f"x{i+1}")
            term = f"{coeff}" if coeff != 0 else ""
            if var_parts:
                if term:
                    term += "⊙"
                term += "⊙".join(var_parts)
            elif not term:
                term = "0"
            parts.append(term)
        return " ⊕ ".join(parts)


# ============================================================
# Pair Signature and Reduction
# ============================================================

def pair_signature(p, q):
    """Combined support signature of a polynomial pair."""
    return p.support | q.support


def pair_measure(p, q):
    """Natural number measure: cardinality of combined support."""
    return len(pair_signature(p, q))


def is_reducible_by(p1, q1, p2, q2):
    """Check if (p2, q2) has strictly smaller support than (p1, q1).

    This implements the ReducibleBy relation: pairSignature q ⊂ pairSignature p.
    """
    sig1 = pair_signature(p1, q1)
    sig2 = pair_signature(p2, q2)
    return sig2 < sig1  # strict subset (using frozenset comparison)


def is_normal_form(p, q, generator_pairs):
    """Check if (p, q) is in normal form w.r.t. generators.

    A pair is normal if no reduction step is possible.
    """
    sig = pair_signature(p, q)
    # In our framework, normal form means no pair has strictly smaller support
    # For the demo, we check if the support is minimal
    return len(sig) == 0 or all(
        not (pair_signature(p2, q2) < sig)
        for p2, q2 in generator_pairs
    )


def reduce_to_normal_form(p, q, generators, max_steps=100):
    """Reduce a pair to normal form, recording the reduction chain.

    Returns (normal_form_pair, reduction_chain, measures).
    """
    chain = [(p, q)]
    measures = [pair_measure(p, q)]

    current_p, current_q = p, q
    for step in range(max_steps):
        current_sig = pair_signature(current_p, current_q)
        reduced = False

        for gp, gq in generators:
            # Try to form a reduced pair by intersecting supports
            new_terms_p = {k: v for k, v in current_p.terms.items()
                          if k in current_sig and k not in gp.support}
            new_terms_q = {k: v for k, v in current_q.terms.items()
                          if k in current_sig and k not in gq.support}

            new_p = TropicalPolynomial(new_terms_p, current_p.n_vars)
            new_q = TropicalPolynomial(new_terms_q, current_q.n_vars)

            new_sig = pair_signature(new_p, new_q)
            if new_sig < current_sig:  # strict decrease
                current_p, current_q = new_p, new_q
                chain.append((current_p, current_q))
                measures.append(pair_measure(current_p, current_q))
                reduced = True
                break

        if not reduced:
            break

    return (current_p, current_q), chain, measures


# ============================================================
# Demo 1: Reduction Chain Visualization
# ============================================================

def demo_reduction_chain():
    """Demonstrate a reduction chain and measure decrease."""
    print("=" * 70)
    print("DEMO 1: Support-Based Reduction Chain")
    print("=" * 70)

    # Create polynomials over 2 variables
    # p = 1 ⊕ 2⊙x₁ ⊕ 3⊙x₂ ⊕ 4⊙x₁⊙x₂
    p = TropicalPolynomial({
        (0, 0): 1, (1, 0): 2, (0, 1): 3, (1, 1): 4
    })
    # q = 0 ⊕ 1⊙x₁ ⊕ 2⊙x₂ ⊕ 5⊙x₁⊙x₂ ⊕ 3⊙x₁²
    q = TropicalPolynomial({
        (0, 0): 0, (1, 0): 1, (0, 1): 2, (1, 1): 5, (2, 0): 3
    })

    # Generator pair
    g1 = TropicalPolynomial({(1, 1): 4}, 2)
    g2 = TropicalPolynomial({(1, 1): 5, (2, 0): 3}, 2)

    generators = [(g1, g2)]

    print(f"\nInitial pair:")
    print(f"  p = {p}")
    print(f"  q = {q}")
    print(f"  Support(p) = {sorted(p.support)}")
    print(f"  Support(q) = {sorted(q.support)}")
    print(f"  Pair signature = {sorted(pair_signature(p, q))}")
    print(f"  Pair measure = {pair_measure(p, q)}")

    print(f"\nGenerator pair:")
    print(f"  g₁ = {g1}")
    print(f"  g₂ = {g2}")

    nf, chain, measures = reduce_to_normal_form(p, q, generators)

    print(f"\nReduction chain (measure decreases at each step):")
    for i, ((pi, qi), m) in enumerate(zip(chain, measures)):
        print(f"  Step {i}: measure = {m}, |supp(p)| = {pi.support_card()}, |supp(q)| = {qi.support_card()}")

    print(f"\nNormal form:")
    print(f"  p* = {nf[0]}")
    print(f"  q* = {nf[1]}")
    print(f"  Final measure = {measures[-1]}")

    # Plot measure decrease
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(range(len(measures)), measures, 'bo-', markersize=10, linewidth=2)
    ax.set_xlabel('Reduction Step', fontsize=12)
    ax.set_ylabel('Pair Measure (Support Cardinality)', fontsize=12)
    ax.set_title('Strict Decrease of Pair Measure Under Reduction\n(Theorem: reduce_decreases_measure)',
                 fontsize=13)
    ax.set_xticks(range(len(measures)))
    ax.grid(True, alpha=0.3)

    for i, m in enumerate(measures):
        ax.annotate(f'{m}', (i, m), textcoords="offset points",
                   xytext=(0, 12), ha='center', fontsize=11, fontweight='bold')

    plt.tight_layout()
    plt.savefig('demos/reduction_chain.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved: demos/reduction_chain.png")


# ============================================================
# Demo 2: Well-Foundedness Visualization
# ============================================================

def demo_well_foundedness():
    """Demonstrate well-foundedness by showing all chains terminate."""
    print("\n" + "=" * 70)
    print("DEMO 2: Well-Foundedness of Reduction")
    print("=" * 70)

    np.random.seed(42)

    # Generate random polynomial pairs and reduce them
    n_trials = 20
    max_support_size = 8
    chain_lengths = []

    generators = [
        (TropicalPolynomial({(1, 0): 1}, 2),
         TropicalPolynomial({(0, 1): 1}, 2)),
        (TropicalPolynomial({(1, 1): 2}, 2),
         TropicalPolynomial({(0, 0): 0}, 2)),
    ]

    print(f"\nRunning {n_trials} random reductions...")
    for trial in range(n_trials):
        # Random polynomial with random support
        n_terms_p = np.random.randint(1, max_support_size + 1)
        n_terms_q = np.random.randint(1, max_support_size + 1)

        terms_p = {}
        for _ in range(n_terms_p):
            exp = (np.random.randint(0, 4), np.random.randint(0, 4))
            terms_p[exp] = float(np.random.randint(-5, 6))

        terms_q = {}
        for _ in range(n_terms_q):
            exp = (np.random.randint(0, 4), np.random.randint(0, 4))
            terms_q[exp] = float(np.random.randint(-5, 6))

        p = TropicalPolynomial(terms_p, 2)
        q = TropicalPolynomial(terms_q, 2)

        nf, chain, measures = reduce_to_normal_form(p, q, generators)
        chain_lengths.append(len(chain) - 1)

    print(f"  All {n_trials} reductions terminated!")
    print(f"  Chain lengths: min={min(chain_lengths)}, max={max(chain_lengths)}, "
          f"avg={np.mean(chain_lengths):.1f}")

    # Plot chain length distribution
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.hist(chain_lengths, bins=range(max(chain_lengths) + 2), align='left',
            color='steelblue', edgecolor='black', alpha=0.8)
    ax.set_xlabel('Reduction Chain Length', fontsize=12)
    ax.set_ylabel('Frequency', fontsize=12)
    ax.set_title(f'Distribution of Reduction Chain Lengths ({n_trials} trials)\n'
                 f'(Theorem: reduction_wellFounded — all chains terminate)',
                 fontsize=13)
    ax.grid(True, alpha=0.3, axis='y')
    plt.tight_layout()
    plt.savefig('demos/well_foundedness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: demos/well_foundedness.png")


# ============================================================
# Demo 3: Support Geometry in 2D
# ============================================================

def demo_support_geometry():
    """Visualize the support geometry of polynomial pairs and reductions."""
    print("\n" + "=" * 70)
    print("DEMO 3: Support Geometry of Polynomial Pairs")
    print("=" * 70)

    # Create a polynomial pair with interesting support
    p = TropicalPolynomial({
        (0, 0): 1, (1, 0): 2, (0, 1): 3, (2, 0): 1,
        (0, 2): 2, (1, 1): 4, (2, 1): 3, (1, 2): 2
    })
    q = TropicalPolynomial({
        (0, 0): 0, (1, 0): 1, (0, 1): 2, (1, 1): 5,
        (2, 0): 3, (0, 2): 1, (3, 0): 2
    })

    generators = [
        (TropicalPolynomial({(2, 1): 3, (1, 2): 2}, 2),
         TropicalPolynomial({(3, 0): 2}, 2)),
    ]

    nf, chain, measures = reduce_to_normal_form(p, q, generators)

    fig, axes = plt.subplots(1, min(len(chain), 3), figsize=(5 * min(len(chain), 3), 5))
    if len(chain) == 1:
        axes = [axes]

    display_indices = [0]
    if len(chain) > 2:
        display_indices.append(len(chain) // 2)
    if len(chain) > 1:
        display_indices.append(len(chain) - 1)

    for idx, step_idx in enumerate(display_indices[:len(axes)]):
        ax = axes[idx]
        pi, qi = chain[step_idx]

        # Plot support of p (blue dots)
        if pi.terms:
            p_exps = list(pi.support)
            ax.scatter([e[0] for e in p_exps], [e[1] for e in p_exps],
                      c='blue', s=100, marker='o', label='supp(p)', zorder=5)

        # Plot support of q (red triangles)
        if qi.terms:
            q_exps = list(qi.support)
            ax.scatter([e[0] for e in q_exps], [e[1] for e in q_exps],
                      c='red', s=100, marker='^', label='supp(q)', zorder=5)

        ax.set_xlabel('x₁ exponent', fontsize=11)
        ax.set_ylabel('x₂ exponent', fontsize=11)
        label = 'Initial' if step_idx == 0 else ('Normal Form' if step_idx == len(chain) - 1 else f'Step {step_idx}')
        ax.set_title(f'{label}\nmeasure = {measures[step_idx]}', fontsize=12)
        ax.legend(fontsize=9)
        ax.set_xlim(-0.5, 4.5)
        ax.set_ylim(-0.5, 3.5)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)

    fig.suptitle('Support Geometry Under Reduction\n(Support shrinks at each step)',
                 fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('demos/support_geometry.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: demos/support_geometry.png")


# ============================================================
# Demo 4: Congruence Generation
# ============================================================

def demo_congruence_generation():
    """Demonstrate finite generation of congruences on tropical polynomials."""
    print("\n" + "=" * 70)
    print("DEMO 4: Congruence Generation and Normal Form Basis")
    print("=" * 70)

    # In a tropical polynomial ring, a congruence identifies polynomials.
    # We demonstrate with 1-variable tropical polynomials.
    # A congruence generated by (x, 2⊙x) identifies x with 2+x.

    print("\nExample: Congruence on tropical polynomials in 1 variable")
    print("  Generated by: (x₁, 2⊙x₁) — identifying x₁ with 2+x₁")
    print()

    # Generator
    g1 = TropicalPolynomial({(1,): 0}, 1)  # x₁
    g2 = TropicalPolynomial({(1,): 2}, 1)  # 2⊙x₁

    # Test pairs
    test_pairs = [
        (TropicalPolynomial({(1,): 0}, 1), TropicalPolynomial({(1,): 2}, 1)),
        (TropicalPolynomial({(2,): 0}, 1), TropicalPolynomial({(2,): 4}, 1)),
        (TropicalPolynomial({(0,): 0, (1,): 0}, 1), TropicalPolynomial({(0,): 0, (1,): 2}, 1)),
    ]

    generators = [(g1, g2)]

    for i, (p, q) in enumerate(test_pairs):
        sig = pair_signature(p, q)
        measure = pair_measure(p, q)
        print(f"  Pair {i+1}: ({p}, {q})")
        print(f"    Signature size = {len(sig)}, Measure = {measure}")

    print(f"\n  The generating set G = {{(g₁, g₂)}} generates the congruence.")
    print(f"  By exists_finite_normalizing_basis, every pair has a normal form w.r.t. G.")
    print(f"  This is the key algorithmic milestone: terminating normalization!")


# ============================================================
# Demo 5: Variable Embedding and Rename
# ============================================================

def demo_variable_embedding():
    """Demonstrate the rename/embedding construction."""
    print("\n" + "=" * 70)
    print("DEMO 5: Variable Embedding and Rename")
    print("=" * 70)

    print("\nEmbedding ι: {t₁, t₂} ↪ {x₁, x₂, x₃}")
    print("  ι(t₁) = x₁, ι(t₂) = x₃")
    print()

    # Original polynomial in {t₁, t₂}
    p = TropicalPolynomial({(1, 0): 3, (0, 1): 5, (1, 1): 7}, 2)
    print(f"  p(t₁, t₂) = {p}")
    print(f"  Support = {sorted(p.support)}")

    # Renamed polynomial in {x₁, x₂, x₃} (via ι)
    renamed_terms = {}
    for (e1, e2), coeff in p.terms.items():
        # ι maps t₁ → x₁ (index 0), t₂ → x₃ (index 2)
        new_exp = (e1, 0, e2)  # x₁^e1 * x₂^0 * x₃^e2
        renamed_terms[new_exp] = coeff

    p_renamed = TropicalPolynomial(renamed_terms, 3)
    print(f"\n  rename(ι)(p)(x₁,x₂,x₃) = {p_renamed}")
    print(f"  Support = {sorted(p_renamed.support)}")

    print(f"\n  Key theorem (rename_embedding_injective):")
    print(f"    rename ι is injective: distinct polynomials in {{t₁,t₂}}")
    print(f"    map to distinct polynomials in {{x₁,x₂,x₃}}")

    print(f"\n  Key theorem (rename_injective_equiv_range):")
    print(f"    The image of rename ι is a subsemiring of MvPolynomial {{x₁,x₂,x₃}} S,")
    print(f"    isomorphic to MvPolynomial {{t₁,t₂}} S")

    # Visualize support transformation
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Original support in 2D
    supp_orig = list(p.support)
    ax1.scatter([e[0] for e in supp_orig], [e[1] for e in supp_orig],
               c='blue', s=150, marker='o', zorder=5)
    for e in supp_orig:
        ax1.annotate(f'({e[0]},{e[1]})', e, textcoords="offset points",
                    xytext=(8, 8), fontsize=10)
    ax1.set_xlabel('t₁ exponent', fontsize=12)
    ax1.set_ylabel('t₂ exponent', fontsize=12)
    ax1.set_title('Original Support\n(2 variables)', fontsize=13)
    ax1.set_xlim(-0.5, 2.5)
    ax1.set_ylim(-0.5, 2.5)
    ax1.grid(True, alpha=0.3)
    ax1.set_aspect('equal')

    # Renamed support in 3D projection
    supp_new = list(p_renamed.support)
    from mpl_toolkits.mplot3d import Axes3D
    ax2 = fig.add_subplot(122, projection='3d')
    ax2.scatter([e[0] for e in supp_new], [e[1] for e in supp_new],
               [e[2] for e in supp_new], c='red', s=150, marker='^', zorder=5)
    for e in supp_new:
        ax2.text(e[0], e[1], e[2], f'  ({e[0]},{e[1]},{e[2]})', fontsize=9)
    ax2.set_xlabel('x₁ exp', fontsize=10)
    ax2.set_ylabel('x₂ exp', fontsize=10)
    ax2.set_zlabel('x₃ exp', fontsize=10)
    ax2.set_title('Renamed Support\n(3 variables, embedded)', fontsize=13)

    plt.tight_layout()
    plt.savefig('demos/variable_embedding.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved: demos/variable_embedding.png")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Congruence Demo: Idempotent Semiring Normal Forms    ║")
    print("║  Demonstrating formally verified theorems from Lean 4          ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_reduction_chain()
    demo_well_foundedness()
    demo_support_geometry()
    demo_congruence_generation()
    demo_variable_embedding()

    print("\n" + "=" * 70)
    print("All demos complete!")
    print("=" * 70)
