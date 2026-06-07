"""
Transseries Demo: Asymptotic Expansions Beyond Power Series

Demonstrates the transseries hierarchy and dominance ordering
through concrete numerical examples.
"""
import math
from typing import List, Tuple

# ── TransLevel evaluation ──────────────────────────────────────────────
def eval_level(level: int, x: float) -> float:
    """Evaluate a transseries level at x.
    Level k means: apply exp k times (k>0) or log |k| times (k<0) to x."""
    if level == 0:
        return x
    elif level > 0:
        result = x
        for _ in range(level):
            result = math.exp(min(result, 700))  # overflow guard
        return result
    else:
        result = x
        for _ in range(abs(level)):
            if result <= 0:
                return float('-inf')
            result = math.log(result)
        return result


# ── TransMonomial ──────────────────────────────────────────────────────
class TransMonomial:
    """A monomial (level, exponent) representing eval_level(x)^exponent."""
    def __init__(self, level: int, exponent: float):
        self.level = level
        self.exponent = exponent

    def eval(self, x: float) -> float:
        base = eval_level(self.level, x)
        if base <= 0 and self.exponent != int(self.exponent):
            return 0.0
        return base ** self.exponent

    def __repr__(self):
        level_names = {0: "x", 1: "exp(x)", 2: "exp(exp(x))",
                       -1: "log(x)", -2: "log(log(x))"}
        base = level_names.get(self.level, f"level_{self.level}(x)")
        if self.exponent == 1:
            return base
        return f"{base}^{self.exponent}"


# ── TransTerm ──────────────────────────────────────────────────────────
class TransTerm:
    def __init__(self, coeff: float, monomial: TransMonomial):
        self.coeff = coeff
        self.monomial = monomial

    def eval(self, x: float) -> float:
        return self.coeff * self.monomial.eval(x)

    def __repr__(self):
        if self.coeff == 1:
            return repr(self.monomial)
        return f"{self.coeff}·{self.monomial}"


# ── FormalTransseries ──────────────────────────────────────────────────
class FormalTransseries:
    def __init__(self, terms: List[TransTerm]):
        self.terms = terms

    def eval(self, x: float) -> float:
        return sum(t.eval(x) for t in self.terms)

    def __repr__(self):
        if not self.terms:
            return "0"
        return " + ".join(repr(t) for t in self.terms)


def main():
    print("=" * 70)
    print("TRANSSERIES: ASYMPTOTIC EXPANSIONS BEYOND POWER SERIES")
    print("=" * 70)

    # ── Example 1: Level Hierarchy ─────────────────────────────────────
    print("\n── Example 1: Level Hierarchy ──")
    print("Evaluating different levels at x = 10:")
    for level in [-2, -1, 0, 1]:
        val = eval_level(level, 10.0)
        level_names = {-2: "log(log(x))", -1: "log(x)", 0: "x", 1: "exp(x)"}
        print(f"  Level {level:+d} [{level_names[level]:>12s}]: {val:.6e}")

    # ── Example 2: Dominance Gap ───────────────────────────────────────
    print("\n── Example 2: Exponential Dominance Gap ──")
    print("x^α / exp(x) as x grows (α = 100):")
    for x in [10, 50, 100, 200, 500]:
        ratio = (x ** 100) / math.exp(x) if x < 710 else 0
        print(f"  x = {x:>4d}: x^100 / exp(x) = {ratio:.6e}")

    # ── Example 3: Log Dominated by Powers ─────────────────────────────
    print("\n── Example 3: log(x) Dominated by x^ε (ε = 0.01) ──")
    for x in [10, 100, 1000, 10000, 100000]:
        ratio = math.log(x) / (x ** 0.01)
        print(f"  x = {x:>6d}: log(x) / x^0.01 = {ratio:.6f}")

    # ── Example 4: Three-Level Transseries ─────────────────────────────
    print("\n── Example 4: Three-Level Transseries ──")
    T = FormalTransseries([
        TransTerm(1.0, TransMonomial(1, 1)),    # exp(x)
        TransTerm(-2.0, TransMonomial(0, 3)),   # -2x³
        TransTerm(0.5, TransMonomial(-1, 2)),   # 0.5·log(x)²
    ])
    print(f"  T(x) = {T}")
    for x in [1.0, 2.0, 5.0, 10.0]:
        print(f"  T({x}) = {T.eval(x):.6e}")

    # ── Example 5: Succ/Pred Cancellation ──────────────────────────────
    print("\n── Example 5: Level Arithmetic ──")
    for l in [-3, -1, 0, 2, 5]:
        succ = l + 1
        pred = l - 1
        print(f"  level {l:+d}: succ = {succ:+d}, pred = {pred:+d}, "
              f"succ(pred) = {pred+1:+d}, pred(succ) = {succ-1:+d}")

    # ── Example 6: Asymptotic Comparison ───────────────────────────────
    print("\n── Example 6: Asymptotic Comparison Theorem ──")
    print("Two transseries with same terms give same values:")
    T1 = FormalTransseries([
        TransTerm(3.0, TransMonomial(1, 1)),
        TransTerm(-1.0, TransMonomial(0, 2)),
    ])
    T2 = FormalTransseries([
        TransTerm(3.0, TransMonomial(1, 1)),
        TransTerm(-1.0, TransMonomial(0, 2)),
    ])
    for x in [1.0, 5.0, 10.0]:
        v1, v2 = T1.eval(x), T2.eval(x)
        print(f"  x = {x}: T1 = {v1:.6e}, T2 = {v2:.6e}, diff = {abs(v1-v2):.2e}")

    # ── Example 7: Valuation (Leading Level) ───────────────────────────
    print("\n── Example 7: Leading Level as Valuation ──")
    examples = [
        ("exp(x) - x²", FormalTransseries([
            TransTerm(1.0, TransMonomial(1, 1)),
            TransTerm(-1.0, TransMonomial(0, 2)),
        ])),
        ("x³ + log(x)", FormalTransseries([
            TransTerm(1.0, TransMonomial(0, 3)),
            TransTerm(1.0, TransMonomial(-1, 1)),
        ])),
        ("5·log(log(x))", FormalTransseries([
            TransTerm(5.0, TransMonomial(-2, 1)),
        ])),
    ]
    for name, T in examples:
        leading = T.terms[0].monomial.level if T.terms else None
        print(f"  {name:>20s}: leading level = {leading}")

    print("\n" + "=" * 70)
    print("All examples demonstrate key transseries properties proved in Lean 4.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization: Transseries Level Dominance Hierarchy

Plots different transseries levels on a log scale to show
the exponential dominance gaps between levels.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def eval_level(level: int, x: float) -> float:
    if level == 0:
        return x
    elif level > 0:
        result = x
        for _ in range(level):
            result = math.exp(min(result, 700))
        return result
    else:
        result = x
        for _ in range(abs(level)):
            if result <= 0:
                return float('nan')
            result = math.log(result)
        return result

def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Level hierarchy
    ax1 = axes[0]
    x_vals = np.linspace(2.1, 8, 200)

    levels_and_labels = [
        (-2, "log(log(x))", "#e74c3c"),
        (-1, "log(x)", "#e67e22"),
        (0, "x", "#2ecc71"),
        (1, "exp(x)", "#3498db"),
    ]

    for level, label, color in levels_and_labels:
        y_vals = []
        for x in x_vals:
            y = eval_level(level, x)
            y_vals.append(y if y > 0 else float('nan'))
        ax1.semilogy(x_vals, y_vals, label=label, color=color, linewidth=2.5)

    ax1.set_xlabel("x", fontsize=13)
    ax1.set_ylabel("f(x)  [log scale]", fontsize=13)
    ax1.set_title("Transseries Level Hierarchy", fontsize=14, fontweight='bold')
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(1e-2, 1e4)

    # Panel 2: Dominance ratios
    ax2 = axes[1]
    x_vals2 = np.linspace(1, 30, 300)

    # x^10 / exp(x) → 0
    ratio1 = [x**10 / math.exp(x) for x in x_vals2]
    ax2.plot(x_vals2, ratio1, label=r"$x^{10} / e^x$", color="#3498db", linewidth=2)

    # log(x) / x^0.5 → 0
    ratio2 = [math.log(x) / x**0.5 for x in x_vals2]
    ax2.plot(x_vals2, ratio2, label=r"$\log(x) / x^{0.5}$", color="#e67e22", linewidth=2)

    # x / exp(x) → 0
    ratio3 = [x / math.exp(x) for x in x_vals2]
    ax2.plot(x_vals2, ratio3, label=r"$x / e^x$", color="#2ecc71", linewidth=2)

    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel("x", fontsize=13)
    ax2.set_ylabel("Ratio", fontsize=13)
    ax2.set_title("Dominance Gaps → 0", fontsize=14, fontweight='bold')
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-0.5, 5)

    plt.tight_layout()
    plt.savefig("Applications/transseries_dominance.png", dpi=150, bbox_inches='tight')
    print("Saved: Applications/transseries_dominance.png")

if __name__ == "__main__":
    main()


"""
Visualization: Transseries Evaluation and Comparison

Shows how a three-level transseries decomposes into its constituent
terms and demonstrates the asymptotic comparison theorem.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Three-level decomposition
    ax1 = axes[0]
    x_vals = np.linspace(0.5, 4, 300)

    # T(x) = exp(x) - 2x³ + 0.5·log(x)²
    exp_part = np.exp(x_vals)
    poly_part = -2 * x_vals**3
    log_part = 0.5 * np.log(np.maximum(x_vals, 1e-10))**2
    total = exp_part + poly_part + log_part

    ax1.plot(x_vals, exp_part, label=r"$e^x$", color="#3498db",
             linewidth=2, linestyle='--')
    ax1.plot(x_vals, poly_part, label=r"$-2x^3$", color="#e67e22",
             linewidth=2, linestyle='--')
    ax1.plot(x_vals, log_part, label=r"$0.5 \cdot \log^2(x)$", color="#2ecc71",
             linewidth=2, linestyle='--')
    ax1.plot(x_vals, total, label=r"$T(x) = e^x - 2x^3 + 0.5\log^2(x)$",
             color="#e74c3c", linewidth=3)

    ax1.set_xlabel("x", fontsize=13)
    ax1.set_ylabel("f(x)", fontsize=13)
    ax1.set_title("Three-Level Transseries Decomposition", fontsize=14,
                  fontweight='bold')
    ax1.legend(fontsize=10, loc='upper left')
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-100, 150)

    # Panel 2: Asymptotic comparison — ratio of terms
    ax2 = axes[1]
    x_vals2 = np.linspace(1, 15, 300)

    # Ratio: poly term / exp term → 0
    ratio_poly = np.abs(-2 * x_vals2**3) / np.exp(x_vals2)
    # Ratio: log term / poly term → 0
    ratio_log = np.abs(0.5 * np.log(x_vals2)**2) / np.abs(2 * x_vals2**3)

    ax2.semilogy(x_vals2, ratio_poly, label=r"$|{-2x^3}| / e^x$",
                 color="#e67e22", linewidth=2.5)
    ax2.semilogy(x_vals2, ratio_log, label=r"$0.5\log^2(x) / 2x^3$",
                 color="#2ecc71", linewidth=2.5)

    ax2.set_xlabel("x", fontsize=13)
    ax2.set_ylabel("Ratio  [log scale]", fontsize=13)
    ax2.set_title("Adjacent-Level Dominance Ratios → 0",
                  fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("Applications/transseries_evaluation.png", dpi=150,
                bbox_inches='tight')
    print("Saved: Applications/transseries_evaluation.png")

if __name__ == "__main__":
    main()
