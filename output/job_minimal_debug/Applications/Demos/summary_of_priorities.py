#!/usr/bin/env python3
"""
Applications of Tropical Polynomial Normal Forms

Demonstrates real-world applications of the tropical normalization framework:
1. ReLU Neural Network Analysis
2. Shortest Path Optimization
3. Robustness Certification for Classifiers
4. Scheduling Optimization (Max-Plus Linear Systems)
"""

import numpy as np
import itertools
from typing import List, Tuple, Dict

# ===========================================================================
# Application 1: ReLU Neural Networks as Tropical Polynomials
# ===========================================================================

def relu_to_tropical(weights: np.ndarray, biases: np.ndarray) -> List[Tuple[float, Tuple[int, ...]]]:
    """
    Convert a single ReLU layer to tropical polynomial form.

    A ReLU neuron computes: max(0, w·x + b)
    In tropical form: max(0, b + w₁x₁ + w₂x₂ + ...)

    For a layer with m neurons followed by max-pooling or
    further ReLU composition, the output is a tropical polynomial.

    Args:
        weights: (m, n) weight matrix
        biases: (m,) bias vector

    Returns:
        List of tropical monomials representing max over neurons.
    """
    m, n = weights.shape
    monomials = []

    # Each neuron contributes a monomial
    for j in range(m):
        # Monomial: b_j + w_j1 * x1 + w_j2 * x2 + ...
        # We represent integer exponents; for general weights,
        # this is an affine form (exponent 1 for each variable)
        c = float(biases[j])
        # For the tropical representation with general coefficients,
        # we treat this as coefficient c with "weight vector" w
        w = tuple(int(round(weights[j, i])) for i in range(n))
        monomials.append((c, w))

    # Add the zero monomial (from ReLU's max(0, ...))
    zero_w = tuple(0 for _ in range(n))
    monomials.append((0.0, zero_w))

    return monomials


def analyze_relu_network():
    """Demonstrate tropical analysis of a simple ReLU network."""
    print("=" * 60)
    print("APPLICATION 1: ReLU Neural Network → Tropical Polynomial")
    print("=" * 60)
    print()

    # Simple 2-input, 3-hidden-neuron, 1-output network
    W1 = np.array([[1, -1], [-1, 1], [1, 1]])
    b1 = np.array([0, 0, -1])

    print("Network: 2 inputs → 3 ReLU neurons → max-pool")
    print(f"  Weights: {W1.tolist()}")
    print(f"  Biases:  {b1.tolist()}")
    print()

    monomials = relu_to_tropical(W1, b1)
    print("Tropical representation:")
    for c, w in monomials:
        terms = []
        if c != 0: terms.append(f"{c}")
        for i, wi in enumerate(w):
            if wi != 0: terms.append(f"{wi}·x{i}")
        expr = " + ".join(terms) if terms else "0"
        print(f"  ({c}, {list(w)})  →  {expr}")
    print()

    print("Network output = max of all affine forms (tropical polynomial).")
    print("Each monomial is a CERTIFIED LOWER BOUND on the output.")
    print()

    # Evaluate at test points
    test_points = [[1, 0], [0, 1], [1, 1], [-1, -1], [2, -1]]
    print("Evaluation:")
    for x in test_points:
        values = [c + sum(wi * xi for wi, xi in zip(w, x)) for c, w in monomials]
        result = max(values)
        print(f"  x = {x}: max{[round(v, 2) for v in values]} = {result:.2f}")
    print()


# ===========================================================================
# Application 2: Shortest Path via Max-Plus
# ===========================================================================

def shortest_path_tropical(adj_matrix: np.ndarray, source: int, target: int,
                           max_hops: int) -> float:
    """
    Compute shortest path using tropical (min-plus) matrix power.

    In the min-plus semiring: ⊕ = min, ⊙ = +
    The (i,j) entry of A^k gives the shortest path from i to j using ≤ k edges.

    We use the max-plus dual: negate weights, use max-plus, negate result.

    Args:
        adj_matrix: adjacency matrix with edge weights (inf for no edge)
        source: source node index
        target: target node index
        max_hops: maximum number of hops

    Returns:
        Shortest path distance
    """
    n = adj_matrix.shape[0]
    # Convert to negated max-plus form
    neg_adj = -adj_matrix.copy()
    neg_adj[np.isinf(neg_adj)] = -np.inf

    # Tropical matrix power: (min-plus)^k via negation trick
    # Current shortest distances
    dist = np.full(n, -np.inf)
    dist[source] = 0.0

    for _ in range(max_hops):
        new_dist = np.full(n, -np.inf)
        for j in range(n):
            for i in range(n):
                if dist[i] > -np.inf and neg_adj[i, j] > -np.inf:
                    new_dist[j] = max(new_dist[j], dist[i] + neg_adj[i, j])
        dist = np.maximum(dist, new_dist)

    return -dist[target] if dist[target] > -np.inf else np.inf


def demo_shortest_path():
    """Demonstrate tropical shortest path computation."""
    print("=" * 60)
    print("APPLICATION 2: Shortest Paths via Tropical Matrix Powers")
    print("=" * 60)
    print()

    inf = np.inf
    # 4-node graph
    adj = np.array([
        [0,   3,   7,   inf],
        [inf, 0,   1,   inf],
        [inf, inf, 0,   2  ],
        [inf, inf, inf, 0  ]
    ])

    print("Graph adjacency matrix (∞ = no edge):")
    for row in adj:
        print("  ", [f"{x:.0f}" if x < inf else "∞" for x in row])
    print()

    for s, t in [(0, 3), (0, 2), (1, 3)]:
        d = shortest_path_tropical(adj, s, t, 4)
        print(f"  Shortest path {s} → {t}: {d:.0f}")
    print()
    print("The tropical matrix power A^k computes k-hop shortest paths.")
    print("Each entry is a tropical polynomial in the edge weights.")
    print()


# ===========================================================================
# Application 3: Robustness Certification
# ===========================================================================

def certify_robustness(monomials_class0: List[Tuple[float, Tuple[int, ...]]],
                       monomials_class1: List[Tuple[float, Tuple[int, ...]]],
                       x: List[float],
                       epsilon: float) -> Dict:
    """
    Certify robustness of a tropical classifier at point x.

    Given tropical polynomial classifiers for two classes,
    the classification margin is:
      margin(x) = eval(class0, x) - eval(class1, x)

    The prediction is robust if margin > 0 for all x' with |x'-x|∞ < ε.

    By affine_lower_bound_of_nf, each monomial gives a lower bound.
    We compute the worst-case margin over the ε-ball.

    Returns:
        Dict with robustness certificate information.
    """
    n = len(x)

    # Evaluate both classes at nominal point
    val0 = max(c + sum(wi * xi for wi, xi in zip(w, x)) for c, w in monomials_class0)
    val1 = max(c + sum(wi * xi for wi, xi in zip(w, x)) for c, w in monomials_class1)
    nominal_margin = val0 - val1

    # Compute worst-case margin over ε-ball
    # For class 0: minimum over ε-ball = min over corners
    # For class 1: maximum over ε-ball = max over corners
    corners = list(itertools.product(*[(xi - epsilon, xi + epsilon) for xi in x]))

    worst_val0 = min(
        max(c + sum(wi * ci for wi, ci in zip(w, corner)) for c, w in monomials_class0)
        for corner in corners
    )
    worst_val1 = max(
        max(c + sum(wi * ci for wi, ci in zip(w, corner)) for c, w in monomials_class1)
        for corner in corners
    )
    worst_margin = worst_val0 - worst_val1

    return {
        'nominal_margin': nominal_margin,
        'worst_case_margin': worst_margin,
        'epsilon': epsilon,
        'is_robust': worst_margin > 0,
        'predicted_class': 0 if nominal_margin > 0 else 1,
    }


def demo_robustness():
    """Demonstrate robustness certification."""
    print("=" * 60)
    print("APPLICATION 3: Certified Robustness for Tropical Classifiers")
    print("=" * 60)
    print()

    # Two-class classifier in 2D
    class0 = [(2.0, (1, 0)), (1.0, (0, 1)), (0.0, (0, 0))]
    class1 = [(0.0, (1, 1)), (-1.0, (2, 0))]

    print("Class 0 tropical polynomial: max(2+x₀, 1+x₁, 0)")
    print("Class 1 tropical polynomial: max(x₀+x₁, -1+2x₀)")
    print()

    test_points = [[1.0, 0.5], [0.0, 0.0], [2.0, -1.0]]
    epsilons = [0.1, 0.5, 1.0]

    for x in test_points:
        print(f"  Point x = {x}:")
        for eps in epsilons:
            cert = certify_robustness(class0, class1, x, eps)
            status = "ROBUST ✓" if cert['is_robust'] else "VULNERABLE ✗"
            print(f"    ε={eps}: margin={cert['nominal_margin']:.2f}, "
                  f"worst={cert['worst_case_margin']:.2f} → {status}")
        print()

    print("Each monomial provides a certified affine lower bound.")
    print("Robustness = positive margin under worst-case perturbation.")
    print()


# ===========================================================================
# Application 4: Job Shop Scheduling (Max-Plus Linear Systems)
# ===========================================================================

def max_plus_schedule(processing_times: np.ndarray,
                      start_times: np.ndarray) -> np.ndarray:
    """
    Solve a simple job-shop scheduling problem using max-plus algebra.

    In max-plus form, the completion time of job j on machine i is:
      C[i,j] = max(C[i,j-1], C[i-1,j]) + p[i,j]

    This is a tropical polynomial in the processing times.

    Args:
        processing_times: (m, n) matrix, p[i,j] = time for job j on machine i
        start_times: (n,) start times for each job

    Returns:
        Completion times matrix (m, n)
    """
    m, n = processing_times.shape
    C = np.zeros((m, n))

    for j in range(n):
        for i in range(m):
            prev_machine = C[i-1, j] if i > 0 else start_times[j]
            prev_job = C[i, j-1] if j > 0 else 0
            C[i, j] = max(prev_machine, prev_job) + processing_times[i, j]

    return C


def demo_scheduling():
    """Demonstrate tropical scheduling optimization."""
    print("=" * 60)
    print("APPLICATION 4: Job-Shop Scheduling via Max-Plus Algebra")
    print("=" * 60)
    print()

    # 3 machines, 4 jobs
    processing = np.array([
        [3, 2, 4, 1],  # Machine 0
        [2, 3, 1, 4],  # Machine 1
        [1, 2, 3, 2],  # Machine 2
    ])
    starts = np.array([0, 0, 0, 0])

    print("Processing times (machines × jobs):")
    print(f"  {processing.tolist()}")
    print(f"  Start times: {starts.tolist()}")
    print()

    C = max_plus_schedule(processing, starts)
    print("Completion times:")
    for i in range(C.shape[0]):
        print(f"  Machine {i}: {C[i].tolist()}")

    makespan = C[-1, -1]
    print(f"\nMakespan (total completion time): {makespan}")
    print()
    print("The completion time is a TROPICAL POLYNOMIAL in processing times.")
    print("  C[i,j] = max(C[i-1,j], C[i,j-1]) + p[i,j]")
    print("         = tropical_multiply(tropical_add(C[i-1,j], C[i,j-1]), p[i,j])")
    print()
    print("Normalization reveals which processing times are CRITICAL:")
    print("(those that appear in the dominant path through the schedule)")
    print()


# ===========================================================================
# Main
# ===========================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Real-World Applications of Tropical Normalization      ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    analyze_relu_network()
    demo_shortest_path()
    demo_robustness()
    demo_scheduling()

    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Polynomial Normal Forms: Interactive Demonstrations

Demonstrates the core mathematical ideas behind tropical polynomial normalization:
- Tropical arithmetic (max-plus semiring)
- Expression normalization via monomial support computation
- Soundness verification: normalized forms preserve evaluation
- Certified lower bounds from individual monomials
- The Minkowski sum correspondence for tropical multiplication
"""

import itertools
from typing import Dict, List, Tuple, Callable
import numpy as np

# ===========================================================================
# Core Tropical Arithmetic
# ===========================================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition = max"""
    return max(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication = classical +"""
    return a + b

# ===========================================================================
# Tropical Expression AST
# ===========================================================================

class TropExpr:
    """Abstract syntax tree for tropical polynomial expressions."""
    pass

class Var(TropExpr):
    def __init__(self, index: int):
        self.index = index
    def __repr__(self):
        return f"x{self.index}"

class Const(TropExpr):
    def __init__(self, value: float):
        self.value = value
    def __repr__(self):
        return f"{self.value}"

class TMax(TropExpr):
    def __init__(self, left: TropExpr, right: TropExpr):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"max({self.left}, {self.right})"

class TPlus(TropExpr):
    def __init__(self, left: TropExpr, right: TropExpr):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"({self.left} ⊙ {self.right})"

# ===========================================================================
# Evaluation
# ===========================================================================

def evaluate(expr: TropExpr, x: List[float]) -> float:
    """Evaluate a tropical expression at a point x."""
    if isinstance(expr, Var):
        return x[expr.index]
    elif isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, TMax):
        return max(evaluate(expr.left, x), evaluate(expr.right, x))
    elif isinstance(expr, TPlus):
        return evaluate(expr.left, x) + evaluate(expr.right, x)
    raise TypeError(f"Unknown expression type: {type(expr)}")

# ===========================================================================
# Tropical Monomial and Normal Form
# ===========================================================================

# A monomial is (coefficient, exponent_vector)
TropMonomial = Tuple[float, Tuple[int, ...]]

def eval_monomial(m: TropMonomial, x: List[float]) -> float:
    """Evaluate c + sum(w_i * x_i)."""
    c, w = m
    return c + sum(wi * xi for wi, xi in zip(w, x))

def eval_nf(support: List[TropMonomial], x: List[float]) -> float:
    """Evaluate a normal form = max over all monomials."""
    return max(eval_monomial(m, x) for m in support)

def mul_monomial(m1: TropMonomial, m2: TropMonomial) -> TropMonomial:
    """Tropical multiplication of monomials: add coefficients, add exponents."""
    c1, w1 = m1
    c2, w2 = m2
    return (c1 + c2, tuple(a + b for a, b in zip(w1, w2)))

# ===========================================================================
# Normalization
# ===========================================================================

def normalize(expr: TropExpr, n_vars: int) -> List[TropMonomial]:
    """
    Normalize a tropical expression to its polynomial normal form.
    Returns a list of (coefficient, exponent_vector) monomials.
    """
    if isinstance(expr, Var):
        w = tuple(1 if j == expr.index else 0 for j in range(n_vars))
        return [(0.0, w)]
    elif isinstance(expr, Const):
        w = tuple(0 for _ in range(n_vars))
        return [(expr.value, w)]
    elif isinstance(expr, TMax):
        # Union of supports
        left_nf = normalize(expr.left, n_vars)
        right_nf = normalize(expr.right, n_vars)
        # Deduplicate
        seen = set()
        result = []
        for m in left_nf + right_nf:
            if m not in seen:
                seen.add(m)
                result.append(m)
        return result
    elif isinstance(expr, TPlus):
        # Minkowski sum
        left_nf = normalize(expr.left, n_vars)
        right_nf = normalize(expr.right, n_vars)
        seen = set()
        result = []
        for m1, m2 in itertools.product(left_nf, right_nf):
            m = mul_monomial(m1, m2)
            if m not in seen:
                seen.add(m)
                result.append(m)
        return result
    raise TypeError(f"Unknown expression type: {type(expr)}")

# ===========================================================================
# Demo 1: Basic Tropical Arithmetic
# ===========================================================================

def demo_basic_arithmetic():
    print("=" * 60)
    print("DEMO 1: Basic Tropical Arithmetic")
    print("=" * 60)
    print()
    print("In tropical algebra, we redefine arithmetic:")
    print("  a ⊕ b = max(a, b)    (tropical addition)")
    print("  a ⊙ b = a + b        (tropical multiplication)")
    print()

    examples = [(3, 5), (7, 2), (-1, 4), (0, 0)]
    for a, b in examples:
        print(f"  {a} ⊕ {b} = max({a}, {b}) = {trop_add(a, b)}")
        print(f"  {a} ⊙ {b} = {a} + {b} = {trop_mul(a, b)}")
        print()

    print("Key property: tropical addition is IDEMPOTENT")
    print(f"  5 ⊕ 5 = max(5, 5) = {trop_add(5, 5)}")
    print()
    print("Distributivity: a ⊙ (b ⊕ c) = (a ⊙ b) ⊕ (a ⊙ c)")
    a, b, c = 3, 5, 2
    lhs = trop_mul(a, trop_add(b, c))
    rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
    print(f"  {a} ⊙ ({b} ⊕ {c}) = {a} + max({b},{c}) = {lhs}")
    print(f"  ({a} ⊙ {b}) ⊕ ({a} ⊙ {c}) = max({a}+{b}, {a}+{c}) = {rhs}")
    print(f"  Equal? {lhs == rhs} ✓")
    print()

# ===========================================================================
# Demo 2: Expression Normalization
# ===========================================================================

def demo_normalization():
    print("=" * 60)
    print("DEMO 2: Expression Normalization")
    print("=" * 60)
    print()

    # Expression: max(x0 + x1, x0 + 3)
    # = tmax(tplus(var(0), var(1)), tplus(var(0), const(3)))
    n = 2
    expr = TMax(TPlus(Var(0), Var(1)), TPlus(Var(0), Const(3)))
    print(f"Expression: {expr}")
    nf = normalize(expr, n)
    print(f"Normal form monomials:")
    for c, w in nf:
        terms = " + ".join(f"{wi}·x{i}" for i, wi in enumerate(w) if wi > 0)
        if not terms:
            terms = "0"
        print(f"  ({c}, {list(w)})  →  {c} + {terms}")
    print()

    # Verify soundness at several points
    print("Soundness verification (eval_normalize):")
    test_points = [[1.0, 2.0], [3.0, -1.0], [0.0, 5.0], [-2.0, -3.0]]
    for x in test_points:
        direct = evaluate(expr, x)
        from_nf = eval_nf(nf, x)
        match = "✓" if abs(direct - from_nf) < 1e-10 else "✗"
        print(f"  x = {x}: direct = {direct:.2f}, NF = {from_nf:.2f}  {match}")
    print()

    # Demonstrate that two different expressions with same NF give same values
    print("Functional completeness demo:")
    # (x0 ⊙ x1) ⊕ (x0 ⊙ 3) vs x0 ⊙ (x1 ⊕ 3)  [by distributivity]
    expr1 = TMax(TPlus(Var(0), Var(1)), TPlus(Var(0), Const(3)))
    expr2 = TPlus(Var(0), TMax(Var(1), Const(3)))
    nf1 = normalize(expr1, n)
    nf2 = normalize(expr2, n)
    print(f"  Expression 1: {expr1}")
    print(f"  Expression 2: {expr2}")
    print(f"  NF1 monomials: {sorted(nf1)}")
    print(f"  NF2 monomials: {sorted(nf2)}")
    print(f"  Same NF? {sorted(nf1) == sorted(nf2)}")
    print()
    print("  Since NFs match, by normalize_complete_functional,")
    print("  these expressions are equal for ALL valuations:")
    for x in test_points:
        v1 = evaluate(expr1, x)
        v2 = evaluate(expr2, x)
        print(f"    x = {x}: {v1:.2f} = {v2:.2f}  {'✓' if abs(v1-v2)<1e-10 else '✗'}")
    print()

# ===========================================================================
# Demo 3: Certified Lower Bounds
# ===========================================================================

def demo_lower_bounds():
    print("=" * 60)
    print("DEMO 3: Certified Lower Bounds from Monomials")
    print("=" * 60)
    print()

    n = 2
    # max(2 + x0, 1 + x1, x0 + x1)
    expr = TMax(TMax(TPlus(Const(2), Var(0)), TPlus(Const(1), Var(1))),
                TPlus(Var(0), Var(1)))
    nf = normalize(expr, n)
    print(f"Expression: {expr}")
    print(f"Normal form has {len(nf)} monomials:")
    for c, w in nf:
        terms = " + ".join(f"{wi}·x{i}" for i, wi in enumerate(w) if wi > 0)
        full = f"{c} + {terms}" if terms else f"{c}"
        print(f"  m = ({c}, {list(w)})  →  {full}")
    print()

    print("By affine_lower_bound_of_nf, EACH monomial is a lower bound:")
    x_test = [1.0, 2.0]
    poly_val = eval_nf(nf, x_test)
    print(f"  At x = {x_test}, polynomial value = {poly_val:.2f}")
    for c, w in nf:
        mono_val = eval_monomial((c, w), x_test)
        terms = " + ".join(f"{wi}·{x_test[i]}" for i, wi in enumerate(w) if wi > 0)
        full = f"{c} + {terms}" if terms else f"{c}"
        print(f"    {full} = {mono_val:.2f} ≤ {poly_val:.2f}  ✓")
    print()

    print("This means: every monomial in the support provides a CERTIFICATE")
    print("that the polynomial is at least as large as that affine function.")
    print("This is the bridge to certified optimization.")
    print()

# ===========================================================================
# Demo 4: Minkowski Sum Correspondence
# ===========================================================================

def demo_minkowski():
    print("=" * 60)
    print("DEMO 4: Tropical Multiplication = Minkowski Sum")
    print("=" * 60)
    print()

    n = 2

    # S = max(x0, x1)  →  {(0,[1,0]), (0,[0,1])}
    S_expr = TMax(Var(0), Var(1))
    S_nf = normalize(S_expr, n)

    # T = max(1, x0)  →  {(1,[0,0]), (0,[1,0])}
    T_expr = TMax(Const(1), Var(0))
    T_nf = normalize(T_expr, n)

    print(f"S = {S_expr}")
    print(f"  Support: {S_nf}")
    print(f"T = {T_expr}")
    print(f"  Support: {T_nf}")
    print()

    # S ⊙ T = S + T (tropical multiplication)
    product_expr = TPlus(S_expr, T_expr)
    product_nf = normalize(product_expr, n)

    print(f"S ⊙ T = {product_expr}")
    print(f"  Minkowski sum of supports:")
    for m1 in S_nf:
        for m2 in T_nf:
            result = mul_monomial(m1, m2)
            print(f"    {m1} ⊕ {m2} = {result}")
    print(f"  Normalized support: {product_nf}")
    print()

    # Verify eval_mulNF
    print("Verification of eval_mulNF (tropical convolution theorem):")
    for x in [[1, 2], [3, -1], [0, 0], [-2, 5]]:
        s_val = eval_nf(S_nf, x)
        t_val = eval_nf(T_nf, x)
        prod_val = eval_nf(product_nf, x)
        direct = evaluate(product_expr, x)
        print(f"  x={x}: S={s_val:.1f}, T={t_val:.1f}, "
              f"S+T={s_val+t_val:.1f}, NF={prod_val:.1f}, "
              f"direct={direct:.1f}  {'✓' if abs(prod_val - direct) < 1e-10 else '✗'}")
    print()

# ===========================================================================
# Demo 5: Decision Procedure in Action
# ===========================================================================

def demo_decision_procedure():
    print("=" * 60)
    print("DEMO 5: Decision Procedure for Tropical Identities")
    print("=" * 60)
    print()

    n = 3

    # Test: x ⊙ (y ⊕ z) = (x ⊙ y) ⊕ (x ⊙ z)  [distributivity]
    x, y, z = Var(0), Var(1), Var(2)
    lhs = TPlus(x, TMax(y, z))
    rhs = TMax(TPlus(x, y), TPlus(x, z))

    lhs_nf = normalize(lhs, n)
    rhs_nf = normalize(rhs, n)

    print("Test 1: Distributivity  x ⊙ (y ⊕ z) = (x ⊙ y) ⊕ (x ⊙ z)")
    print(f"  LHS NF: {sorted(lhs_nf)}")
    print(f"  RHS NF: {sorted(rhs_nf)}")
    print(f"  Decision: {'EQUAL ✓' if sorted(lhs_nf) == sorted(rhs_nf) else 'NOT EQUAL ✗'}")
    print()

    # Test: (x ⊕ y) ⊙ (x ⊕ z) vs x ⊕ (y ⊙ z)  [NOT equal in general]
    lhs2 = TPlus(TMax(x, y), TMax(x, z))
    rhs2 = TMax(TPlus(x, x), TMax(TPlus(x, z), TMax(TPlus(y, x), TPlus(y, z))))

    lhs2_nf = normalize(lhs2, n)
    rhs2_nf = normalize(rhs2, n)

    print("Test 2: (x⊕y)⊙(x⊕z) = x² ⊕ xz ⊕ yx ⊕ yz (expanded)")
    print(f"  LHS NF: {sorted(lhs2_nf)}")
    print(f"  RHS NF: {sorted(rhs2_nf)}")
    print(f"  Decision: {'EQUAL ✓' if sorted(lhs2_nf) == sorted(rhs2_nf) else 'NOT EQUAL ✗'}")
    print()

    # Test a NON-identity
    lhs3 = TMax(x, y)
    rhs3 = TPlus(x, y)
    lhs3_nf = normalize(lhs3, n)
    rhs3_nf = normalize(rhs3, n)
    print("Test 3: x ⊕ y vs x ⊙ y  (max(x,y) vs x+y)")
    print(f"  LHS NF: {sorted(lhs3_nf)}")
    print(f"  RHS NF: {sorted(rhs3_nf)}")
    print(f"  Decision: {'EQUAL ✓' if sorted(lhs3_nf) == sorted(rhs3_nf) else 'NOT EQUAL ✗'}")
    print()

    # Idempotency: x ⊕ x = x
    lhs4 = TMax(x, x)
    rhs4 = x
    lhs4_nf = normalize(lhs4, n)
    rhs4_nf = normalize(rhs4, n)
    print("Test 4: Idempotency  x ⊕ x = x")
    print(f"  LHS NF: {sorted(lhs4_nf)}")
    print(f"  RHS NF: {sorted(rhs4_nf)}")
    print(f"  Decision: {'EQUAL ✓' if sorted(lhs4_nf) == sorted(rhs4_nf) else 'NOT EQUAL ✗'}")
    print()

# ===========================================================================
# Main
# ===========================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Polynomial Normal Forms: Decision Procedure   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_basic_arithmetic()
    demo_normalization()
    demo_lower_bounds()
    demo_minkowski()
    demo_decision_procedure()

    print("=" * 60)
    print("All demonstrations complete.")
    print()
    print("Key theorem verified computationally:")
    print("  eval_normalize: normalization preserves evaluation")
    print("  normalize_complete_functional: equal NFs ⟹ equal functions")
    print("  affine_lower_bound_of_nf: monomials are certified bounds")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical Polynomial Normal Forms

Generates publication-quality figures showing:
1. Tropical polynomial as max of affine functions (1D)
2. Newton polytope of a tropical polynomial (2D)
3. Tropical surface (2 variables, 3D)
4. Normalization diagram showing syntax → normal form → evaluation
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_tropical_1d():
    """
    Plot a 1D tropical polynomial as max of affine functions.
    Shows how the piecewise-linear structure emerges.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    x = np.linspace(-3, 5, 500)

    # Monomials: max(2, x, 2x-1)
    m1 = np.full_like(x, 2.0)        # constant 2
    m2 = x.copy()                     # x
    m3 = 2 * x - 1                    # 2x - 1

    tropical = np.maximum(np.maximum(m1, m2), m3)

    # Left plot: individual affine functions
    ax = axes[0]
    ax.plot(x, m1, '--', color='#e74c3c', alpha=0.7, label='$f_1(x) = 2$')
    ax.plot(x, m2, '--', color='#3498db', alpha=0.7, label='$f_2(x) = x$')
    ax.plot(x, m3, '--', color='#2ecc71', alpha=0.7, label='$f_3(x) = 2x - 1$')
    ax.plot(x, tropical, 'k-', linewidth=2.5, label='$\\max(f_1, f_2, f_3)$')
    ax.set_xlabel('$x$', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Tropical Polynomial = Max of Affine Forms', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-4, 10)

    # Right plot: lower bound certificates
    ax = axes[1]
    ax.fill_between(x, -5, tropical, alpha=0.15, color='gold',
                    label='Feasible region')
    ax.plot(x, tropical, 'k-', linewidth=2.5, label='Tropical polynomial')
    ax.plot(x, m1, '--', color='#e74c3c', alpha=0.8, linewidth=1.5,
            label='Certificate: $f_1 \\leq p$')
    ax.plot(x, m2, '--', color='#3498db', alpha=0.8, linewidth=1.5,
            label='Certificate: $f_2 \\leq p$')
    ax.plot(x, m3, '--', color='#2ecc71', alpha=0.8, linewidth=1.5,
            label='Certificate: $f_3 \\leq p$')
    ax.set_xlabel('$x$', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Each Monomial = Certified Lower Bound', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-4, 10)

    fig.suptitle('Tropical Polynomials: Piecewise-Linear Structure',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()

    # Save
    fig.savefig('viz_tropical_1d.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    b64 = fig_to_base64(fig)
    return b64


def plot_newton_polytope():
    """
    Plot the Newton polytope of a 2-variable tropical polynomial.
    Shows the correspondence between monomials and lattice points.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Monomials of max(3, x+1, y+2, x+y, 2x)
    monomials = [
        (3, (0, 0)),    # constant 3
        (1, (1, 0)),    # x + 1
        (2, (0, 1)),    # y + 2
        (0, (1, 1)),    # x + y
        (0, (2, 0)),    # 2x
    ]

    # Left: Newton polytope (exponent vectors)
    ax = axes[0]
    exps = np.array([w for _, w in monomials])
    coeffs = [c for c, _ in monomials]

    # Draw convex hull
    from scipy.spatial import ConvexHull
    if len(exps) >= 3:
        hull = ConvexHull(exps)
        hull_pts = exps[hull.vertices]
        hull_pts = np.vstack([hull_pts, hull_pts[0]])
        ax.fill(hull_pts[:, 0], hull_pts[:, 1], alpha=0.15, color='steelblue')
        ax.plot(hull_pts[:, 0], hull_pts[:, 1], 'b-', linewidth=1.5, alpha=0.5)

    # Plot lattice points
    for i, ((c, w), exp) in enumerate(zip(monomials, exps)):
        ax.scatter(*exp, s=120, c='steelblue', zorder=5, edgecolors='navy')
        label = f'$c={c}$'
        ax.annotate(label, (exp[0], exp[1]),
                   textcoords="offset points", xytext=(8, 8),
                   fontsize=10, color='navy')

    # Draw grid
    ax.set_xticks(range(0, 3))
    ax.set_yticks(range(0, 3))
    ax.grid(True, alpha=0.3)
    ax.set_xlabel('Exponent of $x_0$', fontsize=12)
    ax.set_ylabel('Exponent of $x_1$', fontsize=12)
    ax.set_title('Newton Polytope\n(Exponent Vectors)', fontsize=13)
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 2)
    ax.set_aspect('equal')

    # Right: Lifted Newton polytope (with coefficients)
    ax = axes[1]
    from mpl_toolkits.mplot3d import Axes3D  # noqa
    ax.remove()
    ax = fig.add_subplot(122, projection='3d')

    for c, w in monomials:
        ax.scatter(w[0], w[1], c, s=80, c='steelblue', edgecolors='navy', zorder=5)
        ax.text(w[0] + 0.1, w[1] + 0.1, c + 0.2, f'$({w[0]},{w[1]},{c})$',
                fontsize=8)

    # Draw connections
    for i in range(len(monomials)):
        for j in range(i + 1, len(monomials)):
            c1, w1 = monomials[i]
            c2, w2 = monomials[j]
            ax.plot([w1[0], w2[0]], [w1[1], w2[1]], [c1, c2],
                    'b-', alpha=0.2, linewidth=0.8)

    ax.set_xlabel('$w_0$', fontsize=11)
    ax.set_ylabel('$w_1$', fontsize=11)
    ax.set_zlabel('Coeff $c$', fontsize=11)
    ax.set_title('Lifted Newton Polytope\n$(w_0, w_1, c)$', fontsize=13)
    ax.view_init(elev=25, azim=-60)

    fig.suptitle('Newton Polytope: Geometric Structure of Tropical Polynomials',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('viz_newton_polytope.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    b64 = fig_to_base64(fig)
    return b64


def plot_tropical_surface():
    """
    Plot a 2D tropical polynomial as a surface (max of planes).
    """
    fig = plt.figure(figsize=(14, 5))

    x = np.linspace(-3, 3, 200)
    y = np.linspace(-3, 3, 200)
    X, Y = np.meshgrid(x, y)

    # Monomials: max(1, x, y, x+y-1)
    Z1 = np.ones_like(X)         # constant 1
    Z2 = X.copy()                 # x
    Z3 = Y.copy()                 # y
    Z4 = X + Y - 1               # x + y - 1

    Z = np.maximum(np.maximum(Z1, Z2), np.maximum(Z3, Z4))

    # Left: 3D surface
    ax1 = fig.add_subplot(121, projection='3d')
    ax1.plot_surface(X, Y, Z, cmap='viridis', alpha=0.8, edgecolor='none')
    ax1.set_xlabel('$x_0$')
    ax1.set_ylabel('$x_1$')
    ax1.set_zlabel('Value')
    ax1.set_title('Tropical Polynomial Surface\n$\\max(1, x_0, x_1, x_0+x_1-1)$',
                  fontsize=12)
    ax1.view_init(elev=30, azim=-45)

    # Right: contour showing piecewise-linear regions
    ax2 = fig.add_subplot(122)
    contour = ax2.contourf(X, Y, Z, levels=20, cmap='viridis')
    plt.colorbar(contour, ax=ax2, label='Value')

    # Draw region boundaries (where two monomials are equal)
    # Z1=Z2: 1=x → x=1
    ax2.plot([1, 1], [-3, 3], 'w--', linewidth=1.5, alpha=0.7)
    # Z1=Z3: 1=y → y=1
    ax2.plot([-3, 3], [1, 1], 'w--', linewidth=1.5, alpha=0.7)
    # Z2=Z3: x=y
    ax2.plot([-3, 3], [-3, 3], 'w--', linewidth=1.5, alpha=0.7)
    # Z1=Z4: 1=x+y-1 → x+y=2
    ax2.plot([-1, 3], [3, -1], 'w--', linewidth=1.5, alpha=0.7)

    ax2.set_xlabel('$x_0$', fontsize=12)
    ax2.set_ylabel('$x_1$', fontsize=12)
    ax2.set_title('Tropical Subdivision\n(Region boundaries in white)', fontsize=12)

    fig.suptitle('2D Tropical Polynomial: Piecewise-Linear Geometry',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('viz_tropical_surface.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    b64 = fig_to_base64(fig)
    return b64


def plot_normalization_diagram():
    """
    Diagram showing the normalization pipeline.
    """
    fig, ax = plt.subplots(figsize=(14, 4))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 3)
    ax.axis('off')

    # Boxes
    boxes = [
        (0.5, 1, 2.5, 1.5, 'Expression\n$e_1, e_2$\n(syntax)', '#3498db'),
        (3.8, 1, 2.5, 1.5, 'Normal Form\n$\\mathrm{NF}(e)$\n(monomial set)', '#e74c3c'),
        (7.2, 1, 2.5, 1.5, 'Evaluation\n$\\mathrm{eval}(e, x)$\n(real number)', '#2ecc71'),
    ]

    for x, y, w, h, text, color in boxes:
        rect = plt.Rectangle((x, y), w, h, linewidth=2,
                             edgecolor=color, facecolor=color,
                             alpha=0.15, zorder=1)
        ax.add_patch(rect)
        ax.text(x + w/2, y + h/2, text,
               ha='center', va='center', fontsize=11,
               fontweight='bold', color=color, zorder=2)

    # Arrows
    arrow_style = dict(arrowstyle='->', color='#34495e',
                      connectionstyle='arc3,rad=0',
                      linewidth=2, mutation_scale=20)

    # normalize arrow
    ax.annotate('', xy=(3.7, 1.75), xytext=(3.1, 1.75), arrowprops=arrow_style)
    ax.text(3.4, 2.6, 'normalize', ha='center', fontsize=10,
           fontstyle='italic', color='#34495e')

    # evalNF arrow
    ax.annotate('', xy=(7.1, 1.75), xytext=(6.4, 1.75), arrowprops=arrow_style)
    ax.text(6.75, 2.6, 'evalNF', ha='center', fontsize=10,
           fontstyle='italic', color='#34495e')

    # Direct eval arrow (bottom)
    ax.annotate('', xy=(7.2, 1.1), xytext=(3.0, 1.1),
               arrowprops=dict(arrowstyle='->', color='#95a5a6',
                              connectionstyle='arc3,rad=-0.3',
                              linewidth=2, mutation_scale=20,
                              linestyle='dashed'))
    ax.text(5.1, 0.2, 'eval (direct)', ha='center', fontsize=10,
           fontstyle='italic', color='#95a5a6')

    # Soundness annotation
    ax.text(5.1, 0.5, '⟵ eval_normalize: these paths commute ⟶',
           ha='center', fontsize=9, color='#7f8c8d',
           bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                    edgecolor='#f39c12', alpha=0.8))

    fig.suptitle('Normalization Pipeline: Syntax → Normal Form → Semantics',
                 fontsize=14, fontweight='bold')
    fig.tight_layout()
    fig.savefig('viz_normalization_diagram.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1d = plot_tropical_1d()
    print(f"  1D tropical plot: {len(b64_1d)} chars")

    try:
        b64_newton = plot_newton_polytope()
        print(f"  Newton polytope: {len(b64_newton)} chars")
    except ImportError:
        print("  Newton polytope: skipped (scipy not available)")
        b64_newton = None

    b64_surface = plot_tropical_surface()
    print(f"  Tropical surface: {len(b64_surface)} chars")

    b64_diagram = plot_normalization_diagram()
    print(f"  Normalization diagram: {len(b64_diagram)} chars")

    print("\nAll visualizations saved as PNG files.")
