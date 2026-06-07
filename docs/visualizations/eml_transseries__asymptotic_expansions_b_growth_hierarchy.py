"""
Visualization: Growth Level Hierarchy

Shows the dramatic separation between growth levels by plotting
eval(g, x) for various growth levels on a log-scale.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def eval_base(level: int, x: float) -> float:
    if level == 0:
        return x
    elif level > 0:
        result = x
        for _ in range(level):
            result = math.exp(min(result, 500))
        return result
    else:
        result = x
        for _ in range(-level):
            if result > 0:
                result = math.log(max(result, 1e-300))
            else:
                return 1e-300
        return max(result, 1e-300)


def eval_growth(level: int, exponent: float, x: float) -> float:
    base = eval_base(level, x)
    if base <= 0:
        return 1e-300
    try:
        return base ** exponent
    except (OverflowError, ValueError):
        return 1e300


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: log-scale comparison of growth levels
    ax1 = axes[0]
    x = np.linspace(2, 10, 200)

    growth_levels = [
        (-2, 1, "log(log(x))", "#2196F3"),
        (-1, 1, "log(x)", "#4CAF50"),
        (0, 0.5, "√x", "#FF9800"),
        (0, 1, "x", "#F44336"),
        (0, 2, "x²", "#9C27B0"),
        (1, 0.5, "exp(x)^0.5", "#795548"),
        (1, 1, "exp(x)", "#E91E63"),
    ]

    for level, exp, label, color in growth_levels:
        y = [eval_growth(level, exp, xi) for xi in x]
        y_clipped = [min(max(yi, 1e-5), 1e15) for yi in y]
        ax1.semilogy(x, y_clipped, label=label, color=color, linewidth=2)

    ax1.set_xlabel("x", fontsize=12)
    ax1.set_ylabel("Growth Level Evaluation (log scale)", fontsize=12)
    ax1.set_title("Growth Hierarchy: Each Level Dominates All Below", fontsize=13)
    ax1.legend(fontsize=9, loc="upper left")
    ax1.set_ylim(1e-2, 1e15)
    ax1.grid(True, alpha=0.3)

    # Right panel: Derivative behavior
    ax2 = axes[1]
    derivs_poly = list(range(8))
    poly_exponents = [5.0 - k for k in derivs_poly]

    derivs_exp = list(range(8))
    exp_exponents = [1.0] * 8

    ax2.plot(derivs_poly, poly_exponents, 'o-', color="#F44336",
             linewidth=2, markersize=8, label="x⁵ (polynomial)")
    ax2.plot(derivs_exp, exp_exponents, 's-', color="#E91E63",
             linewidth=2, markersize=8, label="exp(x) (exponential)")

    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax2.fill_between(derivs_poly, 0, poly_exponents, alpha=0.1, color="#F44336")

    ax2.set_xlabel("Number of derivatives k", fontsize=12)
    ax2.set_ylabel("Exponent after k derivatives", fontsize=12)
    ax2.set_title("Exp-Poly Dichotomy Under Differentiation", fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.annotate("Exponentials:\nFIXED POINT",
                 xy=(4, 1), fontsize=10, color="#E91E63",
                 ha='center', va='bottom')
    ax2.annotate("Polynomials:\nEROSIVE",
                 xy=(4, -1), fontsize=10, color="#F44336",
                 ha='center', va='top')

    plt.tight_layout()
    plt.savefig("Applications/growth_hierarchy.png", dpi=150, bbox_inches='tight')
    print("Saved: Applications/growth_hierarchy.png")


if __name__ == "__main__":
    main()
