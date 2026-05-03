"""
Quantitative Algebraic-Compositional Approximation Calculus: Interactive Demo

This demo illustrates the key theorems from the Lean formalization:
1. Leibniz product error bound
2. Sharp max-Lipschitz inequality
3. Error propagation through expression trees
4. Log-sum-exp tropical bridge

Each section shows concrete numerical examples and generates visualizations.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

# Ensure output directory exists
os.makedirs("demos/figures", exist_ok=True)


# =============================================================================
# Section 1: Elementary Inequalities
# =============================================================================

def demo_leibniz_product_error():
    """
    Demonstrates the Leibniz product error bound:
    |f*g - F*G| <= |f|*|g - G| + |G|*|f - F|
    """
    print("=" * 70)
    print("DEMO 1: Leibniz Product Error Bound")
    print("=" * 70)
    print()
    print("Theorem: |f*g - F*G| <= |f|*|g-G| + |G|*|f-F|")
    print("(Telescoping: f*g - F*G = f*(g-G) + G*(f-F))")
    print()

    test_cases = [
        (3.0, 4.0, 3.1, 3.8),
        (1.0, 2.0, 1.5, 2.5),
        (-2.0, 3.0, -1.8, 3.2),
        (10.0, 0.1, 10.5, 0.15),
    ]

    print(f"{'f':>8} {'g':>8} {'F':>8} {'G':>8} | {'|fg-FG|':>10} {'<= bound':>10} {'gap':>8}")
    print("-" * 70)

    for f, g, F, G in test_cases:
        actual = abs(f * g - F * G)
        bound = abs(f) * abs(g - G) + abs(G) * abs(f - F)
        gap = bound - actual
        print(f"{f:8.2f} {g:8.2f} {F:8.2f} {G:8.2f} | {actual:10.4f} {bound:10.4f} {gap:8.4f}")
        assert actual <= bound + 1e-10, "Bound violated!"

    print()
    print("All bounds verified numerically.")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    f_val, G_val = 2.0, 3.0
    eps_f = np.linspace(0, 1, 100)
    eps_g = np.linspace(0, 1, 100)
    EF, EG = np.meshgrid(eps_f, eps_g)
    bound_surface = abs(f_val) * EG + abs(G_val) * EF

    ax = axes[0]
    c = ax.contourf(EF, EG, bound_surface, levels=20, cmap='YlOrRd')
    plt.colorbar(c, ax=ax, label='Error bound')
    ax.set_xlabel('ef = |f - F|')
    ax.set_ylabel('eg = |g - G|')
    ax.set_title(f'Leibniz Bound: |f|*eg + |G|*ef\n(f={f_val}, G={G_val})')

    ax = axes[1]
    np.random.seed(42)
    n_samples = 500
    f_s = np.random.uniform(-5, 5, n_samples)
    g_s = np.random.uniform(-5, 5, n_samples)
    ef_s = np.random.uniform(-1, 1, n_samples)
    eg_s = np.random.uniform(-1, 1, n_samples)
    F_s = f_s + ef_s
    G_s = g_s + eg_s

    actual = np.abs(f_s * g_s - F_s * G_s)
    bound = np.abs(f_s) * np.abs(eg_s) + np.abs(G_s) * np.abs(ef_s)

    ax.scatter(bound, actual, alpha=0.3, s=10, c='steelblue')
    max_val = max(bound.max(), actual.max())
    ax.plot([0, max_val], [0, max_val], 'r--', label='y = x (tight)')
    ax.set_xlabel('Bound: |f|*|g-G| + |G|*|f-F|')
    ax.set_ylabel('Actual: |f*g - F*G|')
    ax.set_title('Actual Error vs Leibniz Bound')
    ax.legend()

    plt.tight_layout()
    plt.savefig('demos/figures/leibniz_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  -> Saved: demos/figures/leibniz_bound.png")


def demo_max_lipschitz():
    """
    Demonstrates |max(a,b) - max(c,d)| <= max(|a-c|, |b-d|)
    """
    print("=" * 70)
    print("DEMO 2: Sharp Max-Lipschitz Inequality")
    print("=" * 70)
    print()
    print("Theorem: |max(a,b) - max(c,d)| <= max(|a-c|, |b-d|)")
    print()

    test_cases = [
        (5, 3, 4, 2),
        (1, 7, 3, 6),
        (-1, -2, 1, 0),
        (0, 0, 0.1, -0.1),
    ]

    print(f"{'a':>6} {'b':>6} {'c':>6} {'d':>6} | {'LHS':>8} {'<= RHS':>8} {'tight?':>8}")
    print("-" * 55)

    for a, b, c, d in test_cases:
        lhs = abs(max(a, b) - max(c, d))
        rhs = max(abs(a - c), abs(b - d))
        tight = "YES" if abs(lhs - rhs) < 1e-10 else "no"
        print(f"{a:6.1f} {b:6.1f} {c:6.1f} {d:6.1f} | {lhs:8.4f} {rhs:8.4f} {tight:>8}")

    print()

    # Visualization
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    np.random.seed(123)
    n = 1000
    vals = np.random.uniform(-5, 5, (n, 4))
    a_s, b_s, c_s, d_s = vals[:, 0], vals[:, 1], vals[:, 2], vals[:, 3]

    lhs = np.abs(np.maximum(a_s, b_s) - np.maximum(c_s, d_s))
    sharp = np.maximum(np.abs(a_s - c_s), np.abs(b_s - d_s))
    additive = np.abs(a_s - c_s) + np.abs(b_s - d_s)

    ax.scatter(sharp, lhs, alpha=0.3, s=10, c='blue', label='vs max(|a-c|,|b-d|) [sharp]')
    ax.scatter(additive, lhs, alpha=0.15, s=10, c='orange', label='vs |a-c|+|b-d| [additive]')
    max_val = max(additive.max(), sharp.max())
    ax.plot([0, max_val], [0, max_val], 'r--', alpha=0.5)
    ax.set_xlabel('Bound')
    ax.set_ylabel('Actual |max(a,b) - max(c,d)|')
    ax.set_title('Sharp vs Additive Max-Lipschitz Bound')
    ax.legend()

    plt.tight_layout()
    plt.savefig('demos/figures/max_lipschitz.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  -> Saved: demos/figures/max_lipschitz.png")


# =============================================================================
# Section 2: Expression Tree Error Propagation
# =============================================================================

class Var:
    def __init__(self, i): self.i = i
class Const:
    def __init__(self, c): self.c = c
class Add:
    def __init__(self, l, r): self.left, self.right = l, r
class Mul:
    def __init__(self, l, r): self.left, self.right = l, r
class ScalarMul:
    def __init__(self, c, e): self.c, self.expr = c, e
class MaxOp:
    def __init__(self, l, r): self.left, self.right = l, r


def eval_expr(e, v):
    if isinstance(e, Var): return v[e.i]
    if isinstance(e, Const): return np.full_like(list(v.values())[0], e.c) if v else e.c
    if isinstance(e, Add): return eval_expr(e.left, v) + eval_expr(e.right, v)
    if isinstance(e, Mul): return eval_expr(e.left, v) * eval_expr(e.right, v)
    if isinstance(e, ScalarMul): return e.c * eval_expr(e.expr, v)
    if isinstance(e, MaxOp): return np.maximum(eval_expr(e.left, v), eval_expr(e.right, v))

def bound_val(e, B):
    if isinstance(e, Var): return B[e.i]
    if isinstance(e, Const): return abs(e.c)
    if isinstance(e, Add): return bound_val(e.left, B) + bound_val(e.right, B)
    if isinstance(e, Mul): return bound_val(e.left, B) * bound_val(e.right, B)
    if isinstance(e, ScalarMul): return abs(e.c) * bound_val(e.expr, B)
    if isinstance(e, MaxOp): return max(bound_val(e.left, B), bound_val(e.right, B))

def err_bound(e, eps, B):
    if isinstance(e, Var): return eps[e.i]
    if isinstance(e, Const): return 0.0
    if isinstance(e, Add): return err_bound(e.left, eps, B) + err_bound(e.right, eps, B)
    if isinstance(e, Mul):
        return bound_val(e.left, B) * err_bound(e.right, eps, B) + \
               bound_val(e.right, B) * err_bound(e.left, eps, B)
    if isinstance(e, ScalarMul): return abs(e.c) * err_bound(e.expr, eps, B)
    if isinstance(e, MaxOp): return max(err_bound(e.left, eps, B), err_bound(e.right, eps, B))

def expr_str(e):
    if isinstance(e, Var): return f"x{e.i}"
    if isinstance(e, Const): return f"{e.c}"
    if isinstance(e, Add): return f"({expr_str(e.left)} + {expr_str(e.right)})"
    if isinstance(e, Mul): return f"({expr_str(e.left)} * {expr_str(e.right)})"
    if isinstance(e, ScalarMul): return f"{e.c}*{expr_str(e.expr)}"
    if isinstance(e, MaxOp): return f"max({expr_str(e.left)}, {expr_str(e.right)})"


def demo_expression_tree():
    print("=" * 70)
    print("DEMO 3: Expression Tree Error Propagation")
    print("=" * 70)
    print()

    # Expression: max(x0 * x1 + 2*x2, x1 * x2)
    expr = MaxOp(
        Add(Mul(Var(0), Var(1)), ScalarMul(2.0, Var(2))),
        Mul(Var(1), Var(2))
    )

    B = {0: 3.0, 1: 2.0, 2: 4.0}
    eps = {0: 0.1, 1: 0.05, 2: 0.2}

    computed_err = err_bound(expr, eps, B)
    print(f"Expression: {expr_str(expr)}")
    print(f"Variable bounds:  B = {B}")
    print(f"Variable errors:  eps = {eps}")
    print(f"Computed errBound = {computed_err:.4f}")
    print()

    # Monte Carlo verification
    np.random.seed(42)
    n_samples = 10000
    max_actual_err = 0

    for _ in range(n_samples):
        v_true = {i: np.array([np.random.uniform(-B[i], B[i])]) for i in range(3)}
        v_approx = {i: v_true[i] + np.random.uniform(-eps[i], eps[i]) for i in range(3)}
        true_val = eval_expr(expr, v_true).item()
        approx_val = eval_expr(expr, v_approx).item()
        max_actual_err = max(max_actual_err, abs(true_val - approx_val))

    print(f"Monte Carlo ({n_samples} samples):")
    print(f"  Max observed error: {max_actual_err:.6f}")
    print(f"  Theoretical bound:  {computed_err:.6f}")
    print(f"  Tightness ratio:    {max_actual_err / computed_err:.4f}")
    print()

    # Visualization
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    base_eps_range = np.linspace(0.001, 0.5, 50)
    err_bounds_list = []
    actual_maxes = []

    for base_eps in base_eps_range:
        eps_scaled = {i: base_eps * (i + 1) for i in range(3)}
        eb = err_bound(expr, eps_scaled, B)
        err_bounds_list.append(eb)

        max_err = 0
        for _ in range(300):
            v_true = {i: np.array([np.random.uniform(-B[i], B[i])]) for i in range(3)}
            v_approx = {i: v_true[i] + np.random.uniform(-eps_scaled[i], eps_scaled[i]) for i in range(3)}
            true_val = eval_expr(expr, v_true).item()
            approx_val = eval_expr(expr, v_approx).item()
            max_err = max(max_err, abs(true_val - approx_val))
        actual_maxes.append(max_err)

    ax.fill_between(base_eps_range, 0, err_bounds_list, alpha=0.2, color='red')
    ax.plot(base_eps_range, err_bounds_list, 'r-', linewidth=2, label='errBound (theoretical)')
    ax.plot(base_eps_range, actual_maxes, 'b-', linewidth=2, label='Max observed error')
    ax.set_xlabel('Base error scale')
    ax.set_ylabel('Error')
    ax.set_title(f'Error Propagation: {expr_str(expr)}')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/figures/expr_tree_error.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  -> Saved: demos/figures/expr_tree_error.png")


def demo_softmax_bridge():
    print("=" * 70)
    print("DEMO 4: Log-Sum-Exp Tropical Bridge")
    print("=" * 70)
    print()

    def softmax(a, b, tau):
        m = np.maximum(a, b)
        return tau * (m/tau + np.log(np.exp((a - m)/tau) + np.exp((b - m)/tau)))

    a, b = 3.0, 1.0
    taus = [2.0, 1.0, 0.5, 0.1, 0.01]

    print(f"a = {a}, b = {b}, max(a,b) = {max(a,b)}")
    print(f"{'tau':>8} {'softmax':>12} {'error':>10} {'tau*ln2':>10}")
    print("-" * 45)

    for tau in taus:
        sm = softmax(a, b, tau)
        err = abs(sm - max(a, b))
        bnd = tau * np.log(2)
        print(f"{tau:8.3f} {sm:12.6f} {err:10.6f} {bnd:10.6f}")

    print()

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    x = np.linspace(-3, 3, 500)
    for tau in [0.1, 0.5, 1.0, 2.0]:
        sm_vals = softmax(x, 0.0, tau)
        ax.plot(x, sm_vals, label=f'tau = {tau}', linewidth=1.5)
    ax.plot(x, np.maximum(x, 0.0), 'k--', linewidth=2, label='max(x, 0)')
    ax.set_xlabel('x')
    ax.set_title('Soft-max converges to max')
    ax.legend()
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    tau_range = np.linspace(0.01, 3, 200)
    for a_val, b_val in [(3, 1), (2, 2), (0, -1)]:
        errors = [abs(softmax(a_val, b_val, t) - max(a_val, b_val)) for t in tau_range]
        ax.plot(tau_range, errors, linewidth=1.5, label=f'a={a_val}, b={b_val}')
    ax.plot(tau_range, tau_range * np.log(2), 'k--', linewidth=2, label='tau*ln(2) bound')
    ax.set_xlabel('tau')
    ax.set_ylabel('|softmax - max|')
    ax.set_title('Approximation Error vs Temperature')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/figures/softmax_bridge.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  -> Saved: demos/figures/softmax_bridge.png")


def demo_network_approximation():
    print("=" * 70)
    print("DEMO 5: Modular Network Approximation")
    print("=" * 70)
    print()

    x = np.linspace(-1, 1, 1000)

    f1_true = x ** 2
    eps1 = 0.05
    f1_approx = x ** 2 + eps1 * np.sin(5 * x)

    f2_true = np.sin(np.pi * x)
    eps2 = 0.08
    f2_approx = np.sin(np.pi * x) + eps2 * np.cos(3 * x)

    # Max composition
    target = np.maximum(f1_true, f2_true)
    composed = np.maximum(f1_approx, f2_approx)
    theoretical_bound = max(eps1, eps2)
    actual_max_error = np.max(np.abs(target - composed))

    print(f"Target: max(x^2, sin(pi*x)) on [-1, 1]")
    print(f"Sharp max bound: max(eps1, eps2) = {theoretical_bound}")
    print(f"Actual max error: {actual_max_error:.6f}")
    print()

    # Product composition
    B1, M2 = 1.0, 1.0 + eps2
    product_target = f1_true * f2_true
    product_approx = f1_approx * f2_approx
    product_bound = B1 * eps2 + M2 * eps1
    product_actual = np.max(np.abs(product_target - product_approx))

    print(f"Product: x^2 * sin(pi*x)")
    print(f"Leibniz bound: {product_bound:.4f}")
    print(f"Actual error:  {product_actual:.6f}")
    print()

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    ax = axes[0, 0]
    ax.plot(x, f1_true, 'b-', label='x^2', linewidth=2)
    ax.plot(x, f1_approx, 'b--', label=f'approx (eps<={eps1})', alpha=0.7)
    ax.plot(x, f2_true, 'r-', label='sin(pi*x)', linewidth=2)
    ax.plot(x, f2_approx, 'r--', label=f'approx (eps<={eps2})', alpha=0.7)
    ax.set_title('Individual Approximations')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    ax = axes[0, 1]
    ax.plot(x, target, 'k-', linewidth=2, label='max(x^2, sin(pi*x))')
    ax.plot(x, composed, 'g--', linewidth=2, label='composed approximation')
    ax.fill_between(x, target - theoretical_bound, target + theoretical_bound,
                    alpha=0.15, color='green')
    ax.set_title(f'Max Composition (error <= {theoretical_bound})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    ax = axes[1, 0]
    ax.plot(x, product_target, 'k-', linewidth=2, label='x^2*sin(pi*x)')
    ax.plot(x, product_approx, 'm--', linewidth=2, label='composed approximation')
    ax.fill_between(x, product_target - product_bound, product_target + product_bound,
                    alpha=0.15, color='purple')
    ax.set_title(f'Product Composition (error <= {product_bound:.4f})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    ax = axes[1, 1]
    ax.plot(x, np.abs(target - composed), 'g-', label=f'max error (bound={theoretical_bound})')
    ax.axhline(y=theoretical_bound, color='g', linestyle=':', alpha=0.7)
    ax.plot(x, np.abs(product_target - product_approx), 'm-',
            label=f'product error (bound={product_bound:.3f})')
    ax.axhline(y=product_bound, color='m', linestyle=':', alpha=0.7)
    ax.set_title('Pointwise Errors vs Bounds')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_xlabel('x')

    plt.tight_layout()
    plt.savefig('demos/figures/network_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  -> Saved: demos/figures/network_approximation.png")


if __name__ == "__main__":
    print()
    print("=" * 70)
    print("  Quantitative Algebraic-Compositional Approximation Calculus")
    print("  Interactive Demonstration")
    print("=" * 70)
    print()

    demo_leibniz_product_error()
    print()
    demo_max_lipschitz()
    print()
    demo_expression_tree()
    print()
    demo_softmax_bridge()
    print()
    demo_network_approximation()

    print()
    print("=" * 70)
    print("All demonstrations complete! Figures saved to demos/figures/")
    print("=" * 70)
