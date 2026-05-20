#!/usr/bin/env python3
"""
EML Category Applications
==========================
Real-world applications of EML categorical semantics:
1. Cobb-Douglas production function (economics)
2. Information geometry: Fisher information on exponential families
3. Log-linear models for statistical inference
4. Differentiable programming: trainable EML families
5. Chemical reaction kinetics (mass-action law)
"""

import math
from typing import List, Tuple, Callable


# ============================================================
# Application 1: Cobb-Douglas Production Function
# ============================================================

def cobb_douglas_demo():
    """
    The Cobb-Douglas production function Y = A · L^α · K^β
    is a log-affine map on positive inputs (A, L, K).

    In log coordinates: log Y = log A + α·log L + β·log K
    which is affine — confirming logAffine_log_is_affine.

    This means the entire microeconomic theory of production functions
    with constant returns to scale lives inside the EML category.
    """
    print("=" * 70)
    print("APPLICATION 1: Cobb-Douglas Production Function")
    print("=" * 70)
    print()

    # Parameters
    A = 1.0   # Total factor productivity
    alpha = 0.7  # Labor elasticity
    beta = 0.3   # Capital elasticity (constant returns: α + β = 1)

    # Log-affine form: weights = [0, α, β], constant = log(A)
    # On PosVec 3 where x = (A, L, K)
    # But since A is fixed, simplify to PosVec 2 with x = (L, K)
    w = [alpha, beta]
    c = math.log(A)

    print(f"Y = A · L^α · K^β  with A={A}, α={alpha}, β={beta}")
    print(f"Log-affine form: exp({alpha}·log(L) + {beta}·log(K) + {c})")
    print()

    scenarios = [
        ("Baseline", 100, 50),
        ("Double labor", 200, 50),
        ("Double capital", 100, 100),
        ("Double both", 200, 100),
    ]

    print(f"  {'Scenario':>15s}  {'L':>6s}  {'K':>6s}  {'Y':>10s}  {'log Y':>10s}")
    print(f"  {'-'*15}  {'-'*6}  {'-'*6}  {'-'*10}  {'-'*10}")
    for desc, L, K in scenarios:
        Y = A * L**alpha * K**beta
        logY = math.log(A) + alpha * math.log(L) + beta * math.log(K)
        print(f"  {desc:>15s}  {L:6d}  {K:6d}  {Y:10.2f}  {logY:10.4f}")

    print()
    print("Key insight: in log coordinates, doubling inputs adds log(2) ≈ 0.693")
    print(f"to log Y (since α+β=1). This linearity IS logAffine_log_is_affine.")
    print()


# ============================================================
# Application 2: Weighted Geometric Mean for Portfolio Returns
# ============================================================

def portfolio_demo():
    """
    Portfolio geometric mean return is a weighted geometric mean,
    which is an EML-computable function (emlComputable_weightedGeomMean).

    For assets with gross returns r_1, ..., r_n and portfolio weights w_i:
    Portfolio gross return = prod(r_i^w_i) = exp(sum w_i * log(r_i))
    """
    print("=" * 70)
    print("APPLICATION 2: Portfolio Geometric Mean Returns")
    print("=" * 70)
    print()

    # Three assets with annual gross returns
    asset_names = ["Stocks", "Bonds", "Real Estate"]
    returns_history = [
        [1.12, 1.05, 1.08],  # Year 1
        [0.95, 1.03, 1.06],  # Year 2
        [1.20, 1.02, 1.10],  # Year 3
        [1.08, 1.04, 1.03],  # Year 4
        [0.90, 1.06, 1.15],  # Year 5
    ]

    weights = [0.6, 0.3, 0.1]

    print(f"Portfolio weights: {dict(zip(asset_names, weights))}")
    print()

    for year, returns in enumerate(returns_history, 1):
        # Weighted geometric mean via EML formula
        wgm = math.exp(sum(weights[i] * math.log(returns[i]) for i in range(3)))
        print(f"  Year {year}: returns = {returns} → portfolio return = {wgm:.4f} ({(wgm-1)*100:+.2f}%)")

    # Compound geometric mean across all years
    all_portfolio = []
    for returns in returns_history:
        wgm = math.exp(sum(weights[i] * math.log(returns[i]) for i in range(3)))
        all_portfolio.append(wgm)

    compound = math.exp(sum(math.log(r) for r in all_portfolio) / len(all_portfolio))
    print(f"\n  Compound annual geometric mean: {compound:.4f} ({(compound-1)*100:+.2f}%)")
    print(f"  (This is a composition of EML-computable maps — vecEMLComp_comp)")
    print()


# ============================================================
# Application 3: Mass-Action Kinetics
# ============================================================

def mass_action_demo():
    """
    The mass-action law in chemistry:
    reaction rate = k · [A]^a · [B]^b · [C]^c

    This is a log-affine function on concentrations.
    By logAffine_mul_closed, combining reaction rates (e.g., for
    competing pathways) preserves log-affine structure.
    """
    print("=" * 70)
    print("APPLICATION 3: Chemical Reaction Kinetics (Mass-Action Law)")
    print("=" * 70)
    print()

    # Reaction: A + 2B → C
    # Rate = k · [A]^1 · [B]^2
    k = 0.05  # rate constant
    print(f"Reaction: A + 2B → C")
    print(f"Rate law: r = k·[A]·[B]²  with k = {k}")
    print(f"Log-affine form: exp(1·log[A] + 2·log[B] + log(k))")
    print()

    concentrations = [
        (1.0, 1.0),
        (2.0, 1.0),
        (1.0, 2.0),
        (2.0, 2.0),
        (0.5, 3.0),
    ]

    print(f"  {'[A]':>6s}  {'[B]':>6s}  {'Rate':>10s}  {'log(Rate)':>10s}")
    print(f"  {'-'*6}  {'-'*6}  {'-'*10}  {'-'*10}")
    for A_conc, B_conc in concentrations:
        rate = k * A_conc * B_conc**2
        log_rate = math.log(k) + math.log(A_conc) + 2 * math.log(B_conc)
        print(f"  {A_conc:6.2f}  {B_conc:6.2f}  {rate:10.4f}  {log_rate:10.4f}")

    print()
    print("In log coordinates, the rate law becomes LINEAR:")
    print("  log(r) = log(k) + 1·log[A] + 2·log[B]")
    print("This is the content of logAffine_log_is_affine applied to chemistry.")
    print()


# ============================================================
# Application 4: Trainable EML Families
# ============================================================

def trainable_family_demo():
    """
    By vecEMLComp_curry, EML-computable maps on joint (θ, x) space
    give rise to trainable families indexed by parameters θ.

    Example: log-linear classifier
    P(class=1 | x; θ) = σ(θ·x) = 1/(1+exp(-θ·x))
    The softmax/logistic function is built from exp and arithmetic.
    """
    print("=" * 70)
    print("APPLICATION 4: Trainable EML Families (Differentiable Programming)")
    print("=" * 70)
    print()

    # Simple 2D logistic classifier: σ(θ₁·x₁ + θ₂·x₂ + b)
    def logistic(z):
        return 1.0 / (1.0 + math.exp(-z))

    # Training data
    data = [
        ([1.0, 2.0], 1),
        ([2.0, 1.0], 0),
        ([3.0, 3.0], 1),
        ([0.5, 0.5], 0),
    ]

    # Different parameter settings
    param_sets = [
        ([0.0, 0.0, 0.0], "Untrained"),
        ([1.0, 1.0, -2.5], "Partially trained"),
        ([0.5, 1.5, -2.0], "Better fit"),
    ]

    for params, name in param_sets:
        theta1, theta2, b = params
        print(f"  Parameters θ = ({theta1}, {theta2}, {b})  [{name}]")
        print(f"  F_θ(x) = σ({theta1}·x₁ + {theta2}·x₂ + {b})")
        total_loss = 0
        for x, y in data:
            pred = logistic(theta1 * x[0] + theta2 * x[1] + b)
            loss = -(y * math.log(pred + 1e-10) + (1-y) * math.log(1 - pred + 1e-10))
            total_loss += loss
            print(f"    x={x}, y={y}, P(1|x)={pred:.4f}, loss={loss:.4f}")
        print(f"    Total loss: {total_loss:.4f}")
        print()

    print("vecEMLComp_curry guarantees: for ANY fixed θ,")
    print("the specialized map x ↦ F_θ(x) is EML-computable.")
    print()


# ============================================================
# Application 5: Entropy and Information Geometry
# ============================================================

def information_geometry_demo():
    """
    Shannon entropy and KL divergence involve exp and log,
    making them natural EML-computable quantities.

    For a discrete distribution p = (p_1, ..., p_n):
    H(p) = -∑ p_i · log(p_i)

    This is NOT log-affine (it involves addition of log terms),
    but it IS EML-computable since ScalarEML includes both
    add and exp/log (via composition with log).
    """
    print("=" * 70)
    print("APPLICATION 5: Information Geometry — Entropy as EML Computation")
    print("=" * 70)
    print()

    def entropy(p: List[float]) -> float:
        return -sum(pi * math.log(pi) for pi in p if pi > 0)

    def kl_divergence(p: List[float], q: List[float]) -> float:
        return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q) if pi > 0 and qi > 0)

    distributions = [
        ([0.5, 0.5], "Fair coin"),
        ([0.9, 0.1], "Biased coin"),
        ([0.25, 0.25, 0.25, 0.25], "Fair 4-sided die"),
        ([0.7, 0.1, 0.1, 0.1], "Loaded 4-sided die"),
    ]

    print("Shannon Entropy H(p) = -∑ pᵢ · log(pᵢ)")
    print("(EML-computable: uses mul, log, add, neg)")
    print()

    for p, name in distributions:
        H = entropy(p)
        print(f"  {name:>25s}: H = {H:.4f} nats")

    print()
    print("KL Divergence D_KL(p || q) = ∑ pᵢ · log(pᵢ/qᵢ)")
    print("(EML-computable: uses mul, log, div=mul·inv, add)")
    print()

    p = [0.7, 0.2, 0.1]
    q = [0.33, 0.33, 0.34]
    print(f"  p = {p}, q = {[round(qi, 2) for qi in q]}")
    print(f"  D_KL(p || q) = {kl_divergence(p, q):.4f} nats")
    print(f"  D_KL(q || p) = {kl_divergence(q, p):.4f} nats  (asymmetric!)")
    print()


if __name__ == "__main__":
    cobb_douglas_demo()
    portfolio_demo()
    mass_action_demo()
    trainable_family_demo()
    information_geometry_demo()
    print("All applications demonstrated.")


#!/usr/bin/env python3
"""
EML Category Demonstrations
============================
Concrete numerical demonstrations of the EML category theorems:
1. Log-affine normalization of multiplicative EML expressions
2. Weighted geometric mean computation via exp/log
3. Pairing/product of EML-computable maps
4. Currying of parameterized EML families
5. Log-affine closure under multiplication
"""

import math
import random
from typing import Callable, List, Tuple

# ============================================================
# Demo 1: Log-Affine Normalization
# ============================================================

class PosEMLExpr:
    """Syntax tree for the multiplicative positive EML fragment."""
    pass

class Coord(PosEMLExpr):
    def __init__(self, i: int):
        self.i = i
    def __repr__(self):
        return f"x[{self.i}]"

class PosConst(PosEMLExpr):
    def __init__(self, c: float):
        assert c > 0, "Constant must be positive"
        self.c = c
    def __repr__(self):
        return f"{self.c:.4g}"

class Mul(PosEMLExpr):
    def __init__(self, e1: PosEMLExpr, e2: PosEMLExpr):
        self.e1 = e1
        self.e2 = e2
    def __repr__(self):
        return f"({self.e1} * {self.e2})"

class RPow(PosEMLExpr):
    def __init__(self, e: PosEMLExpr, r: float):
        self.e = e
        self.r = r
    def __repr__(self):
        return f"({self.e})^{self.r:.4g}"


def evaluate(expr: PosEMLExpr, x: List[float]) -> float:
    """Evaluate a PosEMLExpr on a positive vector."""
    if isinstance(expr, Coord):
        return x[expr.i]
    elif isinstance(expr, PosConst):
        return expr.c
    elif isinstance(expr, Mul):
        return evaluate(expr.e1, x) * evaluate(expr.e2, x)
    elif isinstance(expr, RPow):
        return evaluate(expr.e, x) ** expr.r
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


def to_log_affine_form(expr: PosEMLExpr, n: int) -> Tuple[List[float], float]:
    """
    Normalize a PosEMLExpr to log-affine form (w, c) such that
    eval(expr, x) = exp(sum_i w[i] * log(x[i]) + c).

    This implements the verified normalization algorithm from LogAffineNormal.lean.
    """
    if isinstance(expr, Coord):
        w = [0.0] * n
        w[expr.i] = 1.0
        return w, 0.0
    elif isinstance(expr, PosConst):
        return [0.0] * n, math.log(expr.c)
    elif isinstance(expr, Mul):
        w1, c1 = to_log_affine_form(expr.e1, n)
        w2, c2 = to_log_affine_form(expr.e2, n)
        return [w1[i] + w2[i] for i in range(n)], c1 + c2
    elif isinstance(expr, RPow):
        w, c = to_log_affine_form(expr.e, n)
        return [expr.r * wi for wi in w], expr.r * c
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


def eval_log_affine(w: List[float], c: float, x: List[float]) -> float:
    """Evaluate the log-affine normal form exp(sum w_i * log(x_i) + c)."""
    return math.exp(sum(w[i] * math.log(x[i]) for i in range(len(x))) + c)


def demo_normalization():
    """Demonstrate normalization of multiplicative EML expressions."""
    print("=" * 70)
    print("DEMO 1: Log-Affine Normalization")
    print("=" * 70)
    print()

    n = 3  # 3-dimensional input

    # Expression: x[0]^2 * x[1]^(-1) * x[2]^0.5 * 3.0
    # This is a weighted geometric monomial times a constant.
    expr = Mul(
        Mul(RPow(Coord(0), 2.0), RPow(Coord(1), -1.0)),
        Mul(RPow(Coord(2), 0.5), PosConst(3.0))
    )

    print(f"Expression: {expr}")
    print()

    w, c = to_log_affine_form(expr, n)
    print(f"Log-affine normal form:")
    print(f"  weights w = {[f'{wi:.4f}' for wi in w]}")
    print(f"  constant c = {c:.6f} (= log({math.exp(c):.4f}))")
    print(f"  Meaning: f(x) = exp({' + '.join(f'{w[i]:.1f}·log(x[{i}])' for i in range(n))} + {c:.4f})")
    print()

    # Test on several positive vectors
    test_vectors = [
        [2.0, 3.0, 4.0],
        [1.0, 1.0, 1.0],
        [0.5, 2.0, 8.0],
        [10.0, 0.1, 100.0],
    ]

    print(f"  {'x':>25s}  {'Direct eval':>12s}  {'Normal form':>12s}  {'Match?':>8s}")
    print(f"  {'-'*25}  {'-'*12}  {'-'*12}  {'-'*8}")
    for x in test_vectors:
        direct = evaluate(expr, x)
        normal = eval_log_affine(w, c, x)
        match = abs(direct - normal) < 1e-10
        print(f"  {str(x):>25s}  {direct:12.6f}  {normal:12.6f}  {'✓' if match else '✗':>8s}")

    print()


# ============================================================
# Demo 2: Weighted Geometric Mean
# ============================================================

def demo_weighted_geometric_mean():
    """Demonstrate weighted geometric mean as EML computation."""
    print("=" * 70)
    print("DEMO 2: Weighted Geometric Mean via exp/log")
    print("=" * 70)
    print()

    n = 4
    weights = [0.25, 0.25, 0.25, 0.25]  # Equal weights = geometric mean

    print(f"Weights: {weights}")
    print(f"Formula: WGM(x) = exp(Σ w_i · log(x_i))")
    print()

    test_vectors = [
        [2.0, 8.0, 4.0, 16.0],
        [1.0, 1.0, 1.0, 1.0],
        [3.0, 3.0, 3.0, 3.0],
        [1.0, 2.0, 4.0, 8.0],
    ]

    for x in test_vectors:
        wgm = math.exp(sum(weights[i] * math.log(x[i]) for i in range(n)))
        # Compare with direct geometric mean
        direct_gm = math.prod(x) ** (1.0 / n)
        print(f"  x = {x}")
        print(f"    EML WGM   = {wgm:.6f}")
        print(f"    Direct GM = {direct_gm:.6f}")
        print(f"    Match: {'✓' if abs(wgm - direct_gm) < 1e-10 else '✗'}")
        print()

    # Non-uniform weights
    weights2 = [0.5, 0.3, 0.15, 0.05]
    print(f"  Non-uniform weights: {weights2}")
    x = [2.0, 3.0, 5.0, 7.0]
    wgm = math.exp(sum(weights2[i] * math.log(x[i]) for i in range(n)))
    print(f"  x = {x}")
    print(f"  Weighted GM = {wgm:.6f}")
    print(f"  = 2^0.5 · 3^0.3 · 5^0.15 · 7^0.05 = {2**0.5 * 3**0.3 * 5**0.15 * 7**0.05:.6f}")
    print()


# ============================================================
# Demo 3: Pairing / Product Structure
# ============================================================

def demo_pairing():
    """Demonstrate pairing of EML-computable maps."""
    print("=" * 70)
    print("DEMO 3: Pairing of EML-Computable Maps (Product Structure)")
    print("=" * 70)
    print()

    # f: R^2 -> R^2, f(x) = (exp(x1), x1 * x2)
    # g: R^2 -> R^1, g(x) = (x1 + x2,)
    # pair(f,g): R^2 -> R^3, pair(f,g)(x) = (exp(x1), x1*x2, x1+x2)

    def f(x):
        return [math.exp(x[0]), x[0] * x[1]]

    def g(x):
        return [x[0] + x[1]]

    def pair_fg(x):
        return f(x) + g(x)  # concatenation

    print("f(x₁,x₂) = (exp(x₁), x₁·x₂)     -- EML-computable (exp, mul)")
    print("g(x₁,x₂) = (x₁ + x₂)              -- EML-computable (add)")
    print("pair(f,g)(x₁,x₂) = (exp(x₁), x₁·x₂, x₁+x₂)")
    print()
    print("By vecEMLComp_pair, the paired map is EML-computable.")
    print()

    test_vectors = [[1.0, 2.0], [0.0, 0.0], [-1.0, 3.0], [2.0, -0.5]]
    for x in test_vectors:
        result = pair_fg(x)
        print(f"  pair(f,g)({x}) = [{', '.join(f'{v:.4f}' for v in result)}]")

    print()


# ============================================================
# Demo 4: Currying / Parameter Splitting
# ============================================================

def demo_currying():
    """Demonstrate currying for parameterized EML families."""
    print("=" * 70)
    print("DEMO 4: Currying — Parameterized EML Families")
    print("=" * 70)
    print()

    # Combined map F: R^(2+1) -> R^1
    # F(θ₁, θ₂, x) = exp(θ₁ * x + θ₂)
    # This is EML-computable on the joint 3D input space.
    #
    # By vecEMLComp_curry, fixing θ gives an EML-computable family:
    # F_θ(x) = exp(θ₁ * x + θ₂)

    def F_joint(theta_x):
        theta1, theta2, x = theta_x
        return [math.exp(theta1 * x + theta2)]

    print("Joint map F(θ₁,θ₂,x) = exp(θ₁·x + θ₂)  -- EML-computable on R³")
    print()
    print("By vecEMLComp_curry, for any fixed θ, F_θ(x) = exp(θ₁·x + θ₂)")
    print("is EML-computable on R¹.")
    print()

    parameter_sets = [
        (1.0, 0.0, "F(x) = exp(x)"),
        (2.0, 1.0, "F(x) = exp(2x + 1)"),
        (-1.0, 0.0, "F(x) = exp(-x)"),
        (0.5, -2.0, "F(x) = exp(0.5x - 2)"),
    ]

    x_vals = [-1.0, 0.0, 0.5, 1.0, 2.0]

    for theta1, theta2, desc in parameter_sets:
        print(f"  θ = ({theta1}, {theta2}):  {desc}")
        values = [math.exp(theta1 * x + theta2) for x in x_vals]
        print(f"    x =     {['%.2f' % x for x in x_vals]}")
        print(f"    F_θ(x) = {['%.4f' % v for v in values]}")
        print()


# ============================================================
# Demo 5: Log-Affine Closure Under Multiplication
# ============================================================

def demo_log_affine_closure():
    """Demonstrate that log-affine maps are closed under multiplication."""
    print("=" * 70)
    print("DEMO 5: Log-Affine Closure Under Multiplication")
    print("=" * 70)
    print()

    n = 2

    # f(x) = exp(2·log(x₁) + 1·log(x₂) + 0) = x₁² · x₂
    w_f, c_f = [2.0, 1.0], 0.0
    # g(x) = exp(-1·log(x₁) + 3·log(x₂) + log(2)) = 2 · x₁⁻¹ · x₂³
    w_g, c_g = [-1.0, 3.0], math.log(2.0)

    # Product: (f·g)(x) = exp((2-1)·log(x₁) + (1+3)·log(x₂) + (0+log2))
    #                    = exp(1·log(x₁) + 4·log(x₂) + log2)
    #                    = 2 · x₁ · x₂⁴
    w_fg = [w_f[i] + w_g[i] for i in range(n)]
    c_fg = c_f + c_g

    print(f"f(x) = exp({w_f[0]}·log(x₁) + {w_f[1]}·log(x₂) + {c_f})")
    print(f"     = x₁² · x₂")
    print()
    print(f"g(x) = exp({w_g[0]}·log(x₁) + {w_g[1]}·log(x₂) + {c_g:.4f})")
    print(f"     = 2 · x₁⁻¹ · x₂³")
    print()
    print(f"Product weights: w = {w_fg}")
    print(f"Product constant: c = {c_fg:.4f} (= log({math.exp(c_fg):.4f}))")
    print(f"(f·g)(x) = 2 · x₁ · x₂⁴")
    print()

    test_vectors = [[2.0, 3.0], [1.0, 1.0], [0.5, 2.0], [3.0, 0.5]]

    print(f"  {'x':>12s}  {'f(x)':>10s}  {'g(x)':>10s}  {'f·g direct':>12s}  {'f·g normal':>12s}  {'Match?':>8s}")
    print(f"  {'-'*12}  {'-'*10}  {'-'*10}  {'-'*12}  {'-'*12}  {'-'*8}")
    for x in test_vectors:
        fx = eval_log_affine(w_f, c_f, x)
        gx = eval_log_affine(w_g, c_g, x)
        direct = fx * gx
        normal = eval_log_affine(w_fg, c_fg, x)
        match = abs(direct - normal) < 1e-10
        print(f"  {str(x):>12s}  {fx:10.4f}  {gx:10.4f}  {direct:12.4f}  {normal:12.4f}  {'✓' if match else '✗':>8s}")

    print()
    print("Theorem logAffine_mul_closed verified numerically: the product")
    print("of log-affine maps is log-affine with summed weights and constants.")
    print()


# ============================================================
# Demo 6: Log Chart — Affine Becomes Linear
# ============================================================

def demo_log_chart():
    """Demonstrate that log-affine maps become affine in log coordinates."""
    print("=" * 70)
    print("DEMO 6: The Log Chart — Multiplicative → Additive")
    print("=" * 70)
    print()

    n = 3
    w = [2.0, -1.0, 0.5]
    c = math.log(5.0)

    print(f"Log-affine function: f(x) = exp(2·log(x₁) - log(x₂) + 0.5·log(x₃) + log(5))")
    print(f"                          = 5 · x₁² · x₂⁻¹ · x₃^0.5")
    print()
    print(f"In log coordinates y_i = log(x_i):")
    print(f"  log(f(x)) = 2·y₁ - y₂ + 0.5·y₃ + log(5)")
    print(f"This is an AFFINE function of y — the theorem logAffine_log_is_affine.")
    print()

    test_vectors = [[1.0, 1.0, 1.0], [2.0, 4.0, 9.0], [math.e, math.e, math.e]]

    for x in test_vectors:
        y = [math.log(xi) for xi in x]
        fx = eval_log_affine(w, c, x)
        log_fx = math.log(fx)
        affine_val = sum(w[i] * y[i] for i in range(n)) + c
        print(f"  x = [{', '.join(f'{xi:.4f}' for xi in x)}]")
        print(f"  y = log(x) = [{', '.join(f'{yi:.4f}' for yi in y)}]")
        print(f"  f(x) = {fx:.6f}")
        print(f"  log(f(x)) = {log_fx:.6f}")
        print(f"  w·y + c   = {affine_val:.6f}")
        print(f"  Match: {'✓' if abs(log_fx - affine_val) < 1e-10 else '✗'}")
        print()


if __name__ == "__main__":
    demo_normalization()
    demo_weighted_geometric_mean()
    demo_pairing()
    demo_currying()
    demo_log_affine_closure()
    demo_log_chart()
    print("All demonstrations complete.")
