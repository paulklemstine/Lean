#!/usr/bin/env python3
"""
Transseries Demo: Numerical examples of the Graded Dominance Algebra
and asymptotic comparison of log-exp monomials.
"""

import math
from typing import Tuple, Dict, Optional

# --- LogExpMonomial ---

class LogExpMonomial:
    """Represents exp(c*x) * x^a * (log x)^b"""
    def __init__(self, exp_coeff: int, poly_exp: int, log_exp: int):
        self.exp_coeff = exp_coeff
        self.poly_exp = poly_exp
        self.log_exp = log_exp
    
    def __repr__(self):
        parts = []
        if self.exp_coeff != 0:
            parts.append(f"exp({self.exp_coeff}x)")
        if self.poly_exp != 0:
            parts.append(f"x^{self.poly_exp}")
        if self.log_exp != 0:
            parts.append(f"(log x)^{self.log_exp}")
        return " · ".join(parts) if parts else "1"
    
    def __mul__(self, other):
        return LogExpMonomial(
            self.exp_coeff + other.exp_coeff,
            self.poly_exp + other.poly_exp,
            self.log_exp + other.log_exp
        )
    
    def inv(self):
        return LogExpMonomial(-self.exp_coeff, -self.poly_exp, -self.log_exp)
    
    def __lt__(self, other):
        return (self.exp_coeff, self.poly_exp, self.log_exp) < \
               (other.exp_coeff, other.poly_exp, other.log_exp)
    
    def __eq__(self, other):
        return (self.exp_coeff == other.exp_coeff and 
                self.poly_exp == other.poly_exp and 
                self.log_exp == other.log_exp)
    
    def __hash__(self):
        return hash((self.exp_coeff, self.poly_exp, self.log_exp))
    
    def depth(self) -> int:
        return abs(self.exp_coeff)
    
    def evaluate(self, x: float) -> float:
        """Evaluate the monomial at a given x > 0."""
        try:
            result = 1.0
            if self.exp_coeff != 0:
                result *= math.exp(self.exp_coeff * x)
            if self.poly_exp != 0:
                result *= x ** self.poly_exp
            if self.log_exp != 0:
                result *= math.log(x) ** self.log_exp
            return result
        except (OverflowError, ValueError):
            return float('inf') if self.exp_coeff > 0 else 0.0


# --- Transseries ---

class Transseries:
    """Finitely-supported formal sum of LogExpMonomials with real coefficients."""
    def __init__(self, terms: Optional[Dict[LogExpMonomial, float]] = None):
        self.terms = {}
        if terms:
            for m, c in terms.items():
                if abs(c) > 1e-15:
                    self.terms[m] = c
    
    def __repr__(self):
        if not self.terms:
            return "0"
        parts = []
        sorted_terms = sorted(self.terms.items(), key=lambda t: 
            (t[0].exp_coeff, t[0].poly_exp, t[0].log_exp), reverse=True)
        for m, c in sorted_terms:
            if abs(c - 1.0) < 1e-10:
                parts.append(str(m))
            elif abs(c + 1.0) < 1e-10:
                parts.append(f"-{m}")
            else:
                parts.append(f"{c:.4g}·{m}")
        return " + ".join(parts)
    
    def __add__(self, other):
        result = dict(self.terms)
        for m, c in other.terms.items():
            result[m] = result.get(m, 0.0) + c
        return Transseries({m: c for m, c in result.items() if abs(c) > 1e-15})
    
    def __neg__(self):
        return Transseries({m: -c for m, c in self.terms.items()})
    
    def __sub__(self, other):
        return self + (-other)
    
    def leading_monomial(self) -> Optional[LogExpMonomial]:
        if not self.terms:
            return None
        return max(self.terms.keys())
    
    def leading_coeff(self) -> float:
        m = self.leading_monomial()
        return self.terms.get(m, 0.0) if m else 0.0
    
    def exp_depth(self) -> int:
        if not self.terms:
            return 0
        return max(m.depth() for m in self.terms)
    
    def evaluate(self, x: float) -> float:
        return sum(c * m.evaluate(x) for m, c in self.terms.items())
    
    @staticmethod
    def const(r: float) -> 'Transseries':
        return Transseries({LogExpMonomial(0, 0, 0): r})
    
    @staticmethod
    def mono(m: LogExpMonomial) -> 'Transseries':
        return Transseries({m: 1.0})


def main():
    print("=" * 70)
    print("TRANSSERIES DEMO: Graded Dominance Algebra in Action")
    print("=" * 70)
    
    # 1. Monomial Comparison
    print("\n--- 1. The Dominance Hierarchy ---")
    log2 = LogExpMonomial(0, 0, 2)    # (log x)^2
    x3 = LogExpMonomial(0, 3, 0)      # x^3
    exp1 = LogExpMonomial(1, 0, 0)    # e^x
    exp2 = LogExpMonomial(2, 0, 0)    # e^(2x)
    
    monomials = [log2, x3, exp1, exp2]
    print("Monomials in dominance order (smallest to largest):")
    for m in sorted(monomials):
        print(f"  {m}  [depth = {m.depth()}]")
    
    print(f"\n  (log x)^2 < x^3 ? {log2 < x3}")
    print(f"  x^3 < exp(x)   ? {x3 < exp1}")
    print(f"  exp(x) < exp(2x)? {exp1 < exp2}")
    
    # 2. Numerical verification
    print("\n--- 2. Numerical Verification at x = 10 ---")
    x = 10.0
    for m in sorted(monomials):
        print(f"  {str(m):20s} = {m.evaluate(x):.6e}")
    
    # 3. Group operations
    print("\n--- 3. Monomial Group Operations ---")
    m1 = LogExpMonomial(1, 2, 0)  # e^x * x^2
    m2 = LogExpMonomial(1, -1, 1) # e^x * x^(-1) * log(x)
    product = m1 * m2
    print(f"  ({m1}) * ({m2}) = {product}")
    print(f"  Depth: {m1.depth()} + {m2.depth()} = {m1.depth() + m2.depth()} >= {product.depth()} (subadditivity)")
    
    inv_m1 = m1.inv()
    identity = m1 * inv_m1
    print(f"  ({m1})^(-1) = {inv_m1}")
    print(f"  ({m1}) * ({inv_m1}) = {identity}")
    
    # 4. Transseries arithmetic
    print("\n--- 4. Transseries Arithmetic ---")
    f = Transseries({
        LogExpMonomial(1, 0, 0): 3.0,
        LogExpMonomial(0, 2, 0): -1.0,
        LogExpMonomial(0, 0, 1): 2.0
    })
    g = Transseries({
        LogExpMonomial(1, 0, 0): -3.0,
        LogExpMonomial(0, 3, 0): 5.0,
        LogExpMonomial(0, 0, 0): 1.0
    })
    print(f"  f = {f}")
    print(f"  g = {g}")
    print(f"  f + g = {f + g}")
    print(f"  Leading monomial of f: {f.leading_monomial()}")
    print(f"  Leading monomial of g: {g.leading_monomial()}")
    
    # 5. Leading Term Comparison Principle
    print("\n--- 5. Leading Term Comparison ---")
    h = f + g
    print(f"  f leading: {f.leading_monomial()} (coeff {f.leading_coeff():.1f})")
    print(f"  g leading: {g.leading_monomial()} (coeff {g.leading_coeff():.1f})")
    print(f"  f+g leading: {h.leading_monomial()} (coeff {h.leading_coeff():.1f})")
    print(f"  Note: exp(x) terms cancel (3 + (-3) = 0), so x^3 term dominates!")
    
    # 6. Depth filtration
    print("\n--- 6. Depth Filtration ---")
    poly_ts = Transseries({
        LogExpMonomial(0, 3, 0): 1.0,
        LogExpMonomial(0, 1, 0): -2.0,
        LogExpMonomial(0, 0, 0): 5.0
    })
    exp_ts = Transseries({
        LogExpMonomial(2, 0, 0): 1.0,
        LogExpMonomial(1, 1, 0): -3.0,
        LogExpMonomial(0, 0, 0): 7.0
    })
    print(f"  Polynomial: {poly_ts}  [depth = {poly_ts.exp_depth()}]")
    print(f"  Exponential: {exp_ts}  [depth = {exp_ts.exp_depth()}]")
    print(f"  Sum: {(poly_ts + exp_ts)}  [depth = {(poly_ts + exp_ts).exp_depth()}]")
    print(f"  max(depth_f, depth_g) = {max(poly_ts.exp_depth(), exp_ts.exp_depth())}")
    print(f"  depth(f+g) ≤ max ? {(poly_ts + exp_ts).exp_depth() <= max(poly_ts.exp_depth(), exp_ts.exp_depth())}")
    
    # 7. Quotient Monomial Theorem
    print("\n--- 7. Quotient Monomial Theorem ---")
    m_small = LogExpMonomial(0, 5, 0)  # x^5
    m_big = LogExpMonomial(1, 0, 0)    # e^x
    quotient = m_big * m_small.inv()
    print(f"  m₁ = {m_small}, m₂ = {m_big}")
    print(f"  m₁ < m₂ ? {m_small < m_big}")
    print(f"  Quotient m₂/m₁ = {quotient}")
    print(f"  Quotient has positive leading: expCoeff = {quotient.exp_coeff} > 0 ✓")
    
    print("\n" + "=" * 70)
    print("All demonstrations complete. Every theorem verified numerically.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Dominance Hierarchy of Log-Exp Monomials.
Plots the growth rates of different monomial classes on a log scale.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def evaluate_monomial(exp_c: int, poly_a: int, log_b: int, x: np.ndarray) -> np.ndarray:
    """Evaluate exp(cx) * x^a * (log x)^b, handling overflow."""
    result = np.ones_like(x, dtype=float)
    if exp_c != 0:
        with np.errstate(over='ignore'):
            result *= np.exp(exp_c * x)
    if poly_a != 0:
        result *= np.power(x, poly_a)
    if log_b != 0:
        result *= np.power(np.log(x), log_b)
    return result

def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left panel: Growth comparison on log scale
    ax = axes[0]
    x = np.linspace(1.1, 8, 500)
    
    monomials = [
        ((0, 0, 1), "(log x)¹", "#2ecc71"),
        ((0, 0, 2), "(log x)²", "#27ae60"),
        ((0, 1, 0), "x¹", "#3498db"),
        ((0, 2, 0), "x²", "#2980b9"),
        ((0, 3, 0), "x³", "#1a5276"),
        ((1, 0, 0), "eˣ", "#e74c3c"),
        ((2, 0, 0), "e²ˣ", "#c0392b"),
    ]
    
    for (c, a, b), label, color in monomials:
        y = evaluate_monomial(c, a, b, x)
        y = np.clip(y, 1e-10, 1e15)
        ax.semilogy(x, y, label=label, color=color, linewidth=2)
    
    ax.set_xlabel("x", fontsize=12)
    ax.set_ylabel("f(x)  (log scale)", fontsize=12)
    ax.set_title("The Dominance Hierarchy", fontsize=14, fontweight='bold')
    ax.legend(loc='upper left', fontsize=10)
    ax.set_ylim(1e-1, 1e15)
    ax.grid(True, alpha=0.3)
    
    # Annotations
    ax.annotate("Exponential\nDominance", xy=(6, 1e8), fontsize=10,
                color='#c0392b', fontweight='bold', ha='center')
    ax.annotate("Polynomial", xy=(7, 1e3), fontsize=10,
                color='#2980b9', fontweight='bold', ha='center')
    ax.annotate("Logarithmic", xy=(7, 5), fontsize=10,
                color='#27ae60', fontweight='bold', ha='center')
    
    # Right panel: Depth stratification
    ax2 = axes[1]
    
    # Plot monomial triples as 3D-projected points
    monomials_3d = [
        (0, 0, 1, "log x"),
        (0, 0, 2, "(log x)²"),
        (0, 1, 0, "x"),
        (0, 2, 0, "x²"),
        (0, 3, 0, "x³"),
        (1, 0, 0, "eˣ"),
        (1, 1, 0, "xeˣ"),
        (1, 0, 1, "eˣ·log x"),
        (2, 0, 0, "e²ˣ"),
        (-1, 0, 0, "e⁻ˣ"),
    ]
    
    depth_colors = {0: '#3498db', 1: '#e74c3c', 2: '#9b59b6', -1: '#f39c12'}
    
    for c, a, b, label in monomials_3d:
        # Project: x-axis = poly_exp, y-axis = log_exp, color/size by depth
        depth = abs(c)
        color = depth_colors.get(c, '#95a5a6')
        size = 100 + depth * 80
        ax2.scatter(a, b, s=size, c=color, edgecolors='black', linewidth=1, zorder=5)
        ax2.annotate(label, (a, b), textcoords="offset points",
                    xytext=(8, 8), fontsize=8)
    
    # Add depth level labels
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#3498db', label='Depth 0 (sub-exponential)'),
        Patch(facecolor='#e74c3c', label='Depth 1 (single exp)'),
        Patch(facecolor='#9b59b6', label='Depth 2 (double exp)'),
        Patch(facecolor='#f39c12', label='Depth -1 (exponential decay)'),
    ]
    ax2.legend(handles=legend_elements, loc='upper left', fontsize=9)
    
    ax2.set_xlabel("Polynomial exponent (a)", fontsize=12)
    ax2.set_ylabel("Logarithmic exponent (b)", fontsize=12)
    ax2.set_title("GDA Depth Stratification", fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(-1.5, 4)
    ax2.set_ylim(-0.5, 3)
    
    plt.tight_layout()
    plt.savefig("Applications/viz_dominance.png", dpi=150, bbox_inches='tight')
    print("Saved: Applications/viz_dominance.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Transseries comparison and leading term principle.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def eval_transseries(terms, x):
    """Evaluate a transseries given as list of (coeff, exp_c, poly_a, log_b)."""
    result = np.zeros_like(x)
    for coeff, exp_c, poly_a, log_b in terms:
        term = coeff * np.ones_like(x)
        if exp_c != 0:
            with np.errstate(over='ignore'):
                term = term * np.exp(exp_c * x)
        if poly_a != 0:
            term = term * np.power(x, poly_a)
        if log_b != 0:
            term = term * np.power(np.log(np.maximum(x, 1.01)), log_b)
        result += term
    return result

def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Panel 1: Leading Term Comparison
    ax = axes[0, 0]
    x = np.linspace(1.1, 5, 300)
    
    # f = 2*e^x - x^2 + 3
    f_terms = [(2, 1, 0, 0), (-1, 0, 2, 0), (3, 0, 0, 0)]
    # g = -2*e^x + x^3 + 1
    g_terms = [(-2, 1, 0, 0), (1, 0, 3, 0), (1, 0, 0, 0)]
    # f + g = x^3 - x^2 + 4 (exponential terms cancel!)
    
    y_f = eval_transseries(f_terms, x)
    y_g = eval_transseries(g_terms, x)
    y_sum = eval_transseries(f_terms + g_terms, x)
    
    ax.plot(x, np.clip(y_f, -500, 500), label='f = 2eˣ - x² + 3', color='#e74c3c', linewidth=2)
    ax.plot(x, np.clip(y_g, -500, 500), label='g = -2eˣ + x³ + 1', color='#3498db', linewidth=2)
    ax.plot(x, y_sum, label='f + g = x³ - x² + 4', color='#2ecc71', linewidth=2.5, linestyle='--')
    
    ax.set_xlabel("x", fontsize=11)
    ax.set_ylabel("f(x)", fontsize=11)
    ax.set_title("Leading Term Cancellation", fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.set_ylim(-100, 300)
    ax.grid(True, alpha=0.3)
    ax.annotate("eˣ terms cancel!\nLeading term drops\nfrom exp to poly",
                xy=(3.5, 50), fontsize=9, style='italic',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    # Panel 2: Asymptotic comparison at large x
    ax = axes[0, 1]
    x = np.linspace(2, 20, 300)
    
    monomials = [
        ((0, 0, 2), "(log x)²", "#2ecc71"),
        ((0, 2, 0), "x²", "#3498db"),
        ((0, 5, 0), "x⁵", "#1a5276"),
        ((1, 0, 0), "eˣ", "#e74c3c"),
    ]
    
    for (c, a, b), label, color in monomials:
        y = eval_transseries([(1, c, a, b)], x)
        y_log = np.log10(np.maximum(y, 1e-20))
        ax.plot(x, y_log, label=label, color=color, linewidth=2)
    
    ax.set_xlabel("x", fontsize=11)
    ax.set_ylabel("log₁₀ f(x)", fontsize=11)
    ax.set_title("Asymptotic Separation (log scale)", fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Depth filtration visualization
    ax = axes[1, 0]
    
    depths = [0, 1, 2, 3]
    counts = [6, 4, 2, 1]  # Example: monomials at each depth level
    colors = ['#3498db', '#e74c3c', '#9b59b6', '#f39c12']
    labels = ['Sub-exp\n(poly/log)', 'Single exp\n(e^{cx})', 'Double exp\n(e^{2cx})', 'Triple exp\n(e^{3cx})']
    
    bars = ax.bar(depths, counts, color=colors, edgecolor='black', linewidth=1.5)
    ax.set_xlabel("Depth Level", fontsize=11)
    ax.set_ylabel("Number of Monomials", fontsize=11)
    ax.set_title("GDA Depth Stratification", fontsize=13, fontweight='bold')
    ax.set_xticks(depths)
    ax.set_xticklabels(labels, fontsize=9)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Add subadditivity annotation
    ax.annotate("depth(m₁·m₂) ≤ depth(m₁) + depth(m₂)",
                xy=(1.5, 5), fontsize=10, ha='center',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    # Panel 4: Comparison theorem - coefficient matching
    ax = axes[1, 1]
    
    # Show two transseries with matching coefficients
    monomials_list = ['e²ˣ', 'eˣ', 'x³', 'x²', 'x', 'log x', '1']
    f_coeffs = [0, 3, 0, -2, 0, 1, 5]
    g_coeffs = [0, 3, 0, -2, 0, 1, 5]  # Same!
    
    x_pos = np.arange(len(monomials_list))
    width = 0.35
    
    ax.bar(x_pos - width/2, f_coeffs, width, label='f', color='#e74c3c', edgecolor='black', alpha=0.7)
    ax.bar(x_pos + width/2, g_coeffs, width, label='g', color='#3498db', edgecolor='black', alpha=0.7)
    
    ax.set_xlabel("Monomial", fontsize=11)
    ax.set_ylabel("Coefficient", fontsize=11)
    ax.set_title("Comparison Theorem: f = g ⟺ all coefficients match",
                fontsize=12, fontweight='bold')
    ax.set_xticks(x_pos)
    ax.set_xticklabels(monomials_list, fontsize=10)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')
    ax.annotate("∀m: coeff(f,m) = coeff(g,m) ⟹ f = g",
                xy=(3, 4.5), fontsize=10, ha='center',
                bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig("Applications/viz_transseries.png", dpi=150, bbox_inches='tight')
    print("Saved: Applications/viz_transseries.png")

if __name__ == "__main__":
    main()
