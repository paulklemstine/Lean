#!/usr/bin/env python3
"""
EML Stone-Weierstrass Demo: Numerical Examples

Demonstrates the key results from the EML interpolation theory:
1. EML approximation of x² using a single exponential
2. Iterated exponential tower growth
3. EML complexity comparison: polynomials vs transcendentals
"""

import math

def eml_approx_square(x: float) -> float:
    """The EML approximation to x²: 2*(exp(x) - 1 - x)."""
    return 2.0 * (math.exp(x) - 1.0 - x)

def eml_approx_square_scaled(x: float, eps: float) -> float:
    """Scaled EML approximation: 2*(exp(eps*x) - 1 - eps*x) / eps².
    Converges to x² as eps → 0."""
    if abs(eps) < 1e-15:
        return x * x
    return 2.0 * (math.exp(eps * x) - 1.0 - eps * x) / (eps * eps)

def iterated_exp(n: int, x: float) -> float:
    """Compute exp^[n](x) = exp(exp(...exp(x)...)) with n applications."""
    result = x
    for _ in range(n):
        result = math.exp(result)
    return result

def eml_term_eval(term: dict, x: float) -> float:
    """Evaluate an EML term (represented as a dict) at x."""
    kind = term["kind"]
    if kind == "const":
        return term["value"]
    elif kind == "proj":
        return x
    elif kind == "exp":
        return math.exp(eml_term_eval(term["child"], x))
    elif kind == "log":
        val = eml_term_eval(term["child"], x)
        return math.log(val) if val > 0 else 0.0
    elif kind == "add":
        return eml_term_eval(term["left"], x) + eml_term_eval(term["right"], x)
    elif kind == "mul":
        return eml_term_eval(term["left"], x) * eml_term_eval(term["right"], x)
    else:
        raise ValueError(f"Unknown term kind: {kind}")

def eml_term_width(term: dict) -> int:
    """Count transcendental operations in an EML term."""
    kind = term["kind"]
    if kind in ("const", "proj"):
        return 0
    elif kind in ("exp", "log"):
        return eml_term_width(term["child"]) + 1
    elif kind in ("add", "mul"):
        return eml_term_width(term["left"]) + eml_term_width(term["right"])
    return 0

def eml_term_depth(term: dict) -> int:
    """Compute depth of an EML term."""
    kind = term["kind"]
    if kind in ("const", "proj"):
        return 0
    elif kind in ("exp", "log"):
        return eml_term_depth(term["child"]) + 1
    elif kind in ("add", "mul"):
        return max(eml_term_depth(term["left"]), eml_term_depth(term["right"])) + 1
    return 0


def main():
    print("=" * 70)
    print("EML STONE-WEIERSTRASS: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: EML approximation of x²
    print("\n--- Demo 1: EML Approximation of x² ---")
    print("Term: 2*(exp(x) - 1 - x)")
    print("Width: 1 (one exponential), Depth: 3")
    print()
    print(f"{'x':>8} {'x²':>12} {'EML(x)':>12} {'Error':>12} {'Rel. Error':>12}")
    print("-" * 60)
    for x_val in [0.0, 0.1, 0.2, 0.3, 0.5, 0.7, 1.0]:
        true_val = x_val ** 2
        eml_val = eml_approx_square(x_val)
        error = eml_val - true_val
        rel_err = error / true_val if true_val > 0 else 0.0
        print(f"{x_val:8.2f} {true_val:12.6f} {eml_val:12.6f} {error:12.6f} {rel_err:12.4%}")

    print(f"\nMax error on [0,1]: {max(eml_approx_square(x/100) - (x/100)**2 for x in range(101)):.6f}")
    print(f"Theoretical bound (e - 2): {math.e - 2:.6f}")

    # Demo 2: Scaled EML approximation convergence
    print("\n--- Demo 2: Scaled EML Convergence ---")
    print("Term: 2*(exp(εx) - 1 - εx) / ε²")
    x_test = 0.5
    print(f"\nAt x = {x_test}, x² = {x_test**2}")
    for eps in [1.0, 0.5, 0.1, 0.01, 0.001]:
        approx = eml_approx_square_scaled(x_test, eps)
        print(f"  ε = {eps:<8.3f}  EML(x) = {approx:.10f}  error = {approx - x_test**2:+.2e}")

    # Demo 3: Iterated exponential tower
    print("\n--- Demo 3: Iterated Exponential Tower ---")
    print("exp^[n](0) for n = 0, 1, 2, 3, 4")
    for n in range(5):
        try:
            val = iterated_exp(n, 0.0)
            print(f"  exp^[{n}](0) = {val:.6f}")
        except OverflowError:
            print(f"  exp^[{n}](0) = OVERFLOW (too large for float)")

    print("\nStrictly increasing: ", end="")
    vals = []
    for n in range(5):
        try:
            vals.append(iterated_exp(n, 0.0))
        except OverflowError:
            break
    print(" < ".join(f"{v:.4f}" for v in vals))

    # Demo 4: EML term examples
    print("\n--- Demo 4: EML Term Construction ---")

    # x² as EML: Mul(Proj, Proj)
    x_sq = {"kind": "mul", "left": {"kind": "proj"}, "right": {"kind": "proj"}}
    print(f"x² = Mul(Proj, Proj)  width={eml_term_width(x_sq)}, depth={eml_term_depth(x_sq)}")
    print(f"  eval(1.5) = {eml_term_eval(x_sq, 1.5):.4f} (expected {1.5**2:.4f})")

    # exp(x) as EML
    exp_x = {"kind": "exp", "child": {"kind": "proj"}}
    print(f"exp(x) = Exp(Proj)  width={eml_term_width(exp_x)}, depth={eml_term_depth(exp_x)}")
    print(f"  eval(1.0) = {eml_term_eval(exp_x, 1.0):.6f} (expected {math.e:.6f})")

    # exp(exp(x)) as EML
    exp_exp_x = {"kind": "exp", "child": {"kind": "exp", "child": {"kind": "proj"}}}
    print(f"exp(exp(x)) = Exp(Exp(Proj))  width={eml_term_width(exp_exp_x)}, depth={eml_term_depth(exp_exp_x)}")
    print(f"  eval(0.0) = {eml_term_eval(exp_exp_x, 0.0):.6f} (expected {math.e:.6f})")

    # The approximation term: 2*(exp(x) - 1 - x)
    approx_term = {
        "kind": "mul",
        "left": {"kind": "const", "value": 2.0},
        "right": {
            "kind": "add",
            "left": {"kind": "exp", "child": {"kind": "proj"}},
            "right": {
                "kind": "mul",
                "left": {"kind": "const", "value": -1.0},
                "right": {
                    "kind": "add",
                    "left": {"kind": "const", "value": 1.0},
                    "right": {"kind": "proj"}
                }
            }
        }
    }
    print(f"2(exp(x)-1-x)  width={eml_term_width(approx_term)}, depth={eml_term_depth(approx_term)}")

    # Demo 5: EML complexity comparison
    print("\n--- Demo 5: EML Complexity ---")
    print("Polynomial x³: width=0 (no transcendentals needed)")
    print("exp(x):         width=1 (exactly one transcendental)")
    print("exp(exp(x)):    width=2 (two transcendentals)")
    print()
    print("Key insight: polynomials have EML complexity 0,")
    print("transcendental functions have positive EML complexity.")

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Approximation of x²

Shows the EML term 2*(exp(x) - 1 - x) versus x² on [0, 1],
with error analysis.
"""

import math

def plot_eml_approximation():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, printing table instead")
        for i in range(11):
            x = i / 10.0
            print(f"x={x:.1f}  x²={x**2:.4f}  EML={2*(math.exp(x)-1-x):.4f}  err={2*(math.exp(x)-1-x)-x**2:.4f}")
        return

    x = np.linspace(0, 1, 200)
    x_sq = x ** 2
    eml = 2 * (np.exp(x) - 1 - x)
    error = eml - x_sq

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left plot: functions
    ax1 = axes[0]
    ax1.plot(x, x_sq, 'b-', linewidth=2, label=r'$x^2$')
    ax1.plot(x, eml, 'r--', linewidth=2, label=r'$2(\exp(x) - 1 - x)$')
    ax1.fill_between(x, x_sq, eml, alpha=0.2, color='red', label='Overestimate')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('y', fontsize=12)
    ax1.set_title('EML Approximation of $x^2$ (Width = 1)', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right plot: error
    ax2 = axes[1]
    ax2.plot(x, error, 'r-', linewidth=2, label='Error')
    ax2.axhline(y=math.e - 2, color='gray', linestyle=':', linewidth=1,
                label=f'Bound: $e - 2 \\approx {math.e - 2:.3f}$')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('Error', fontsize=12)
    ax2.set_title('Approximation Error on [0, 1]', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_approximation.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_approximation.png")


def plot_scaled_convergence():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        return

    x = np.linspace(0, 1, 200)
    x_sq = x ** 2

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(x, x_sq, 'k-', linewidth=3, label=r'$x^2$ (target)')

    for eps, color in [(1.0, 'red'), (0.5, 'orange'), (0.1, 'green'), (0.01, 'blue')]:
        eml_scaled = 2 * (np.exp(eps * x) - 1 - eps * x) / (eps ** 2)
        ax.plot(x, eml_scaled, '--', color=color, linewidth=1.5,
                label=rf'$\varepsilon = {eps}$')

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title(r'Convergence: $\frac{2}{\varepsilon^2}(\exp(\varepsilon x) - 1 - \varepsilon x) \to x^2$',
                 fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.1, 1.5)

    plt.tight_layout()
    plt.savefig('eml_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_convergence.png")


if __name__ == "__main__":
    plot_eml_approximation()
    plot_scaled_convergence()


#!/usr/bin/env python3
"""
Visualization: Exponential Tower Growth

Shows the growth of iterated exponentials exp^[n](x) for n = 0, 1, 2, 3
on a compact interval, demonstrating the depth hierarchy.
"""

import math

def plot_tower_growth():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib not available")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: exp^[n](x) on [-1, 1]
    ax1 = axes[0]
    x = np.linspace(-1, 1, 300)
    colors = ['blue', 'green', 'orange', 'red']
    labels = [r'$x$ (depth 0)', r'$e^x$ (depth 1)',
              r'$e^{e^x}$ (depth 2)', r'$e^{e^{e^x}}$ (depth 3)']

    for n in range(4):
        y = x.copy()
        for _ in range(n):
            y = np.exp(y)
        # Clip for display
        y = np.clip(y, -10, 50)
        ax1.plot(x, y, color=colors[n], linewidth=2, label=labels[n])

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('y', fontsize=12)
    ax1.set_title('Iterated Exponentials: Depth Hierarchy', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-2, 50)
    ax1.grid(True, alpha=0.3)

    # Right: exp^[n](0) sequence (tower at zero)
    ax2 = axes[1]
    n_vals = list(range(5))
    tower_vals = []
    val = 0.0
    for n in range(5):
        tower_vals.append(val)
        val = math.exp(val)

    ax2.bar(n_vals, tower_vals, color=['blue', 'green', 'orange', 'red', 'purple'],
            alpha=0.7, edgecolor='black')
    for i, v in enumerate(tower_vals):
        ax2.text(i, v + 0.3, f'{v:.2f}', ha='center', fontsize=10)

    ax2.set_xlabel('n (depth)', fontsize=12)
    ax2.set_ylabel(r'$\exp^{[n]}(0)$', fontsize=12)
    ax2.set_title('Exponential Tower at Zero', fontsize=14)
    ax2.set_xticks(n_vals)
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('eml_tower_growth.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_tower_growth.png")


if __name__ == "__main__":
    plot_tower_growth()
