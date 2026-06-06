#!/usr/bin/env python3
"""
EML Transcendence Tower: Numerical Demonstrations

Demonstrates the transcendence tower structure and properties of EML numbers.
"""

import math
from typing import List, Tuple

# --- EML Expression evaluator ---

class EMLExpr:
    """An EML (Exp-Mul-Log) expression tree."""
    pass

class Rat(EMLExpr):
    def __init__(self, q: float):
        self.q = q
    def eval(self) -> float:
        return self.q
    def depth(self) -> int:
        return 0
    def __repr__(self):
        return str(self.q)

class Add(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self) -> float:
        return self.a.eval() + self.b.eval()
    def depth(self) -> int:
        return max(self.a.depth(), self.b.depth())
    def __repr__(self):
        return f"({self.a} + {self.b})"

class Mul(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self) -> float:
        return self.a.eval() * self.b.eval()
    def depth(self) -> int:
        return max(self.a.depth(), self.b.depth())
    def __repr__(self):
        return f"({self.a} × {self.b})"

class Exp(EMLExpr):
    def __init__(self, a: EMLExpr):
        self.a = a
    def eval(self) -> float:
        return math.exp(self.a.eval())
    def depth(self) -> int:
        return self.a.depth() + 1
    def __repr__(self):
        return f"exp({self.a})"

class Log(EMLExpr):
    def __init__(self, a: EMLExpr):
        self.a = a
    def eval(self) -> float:
        v = self.a.eval()
        return math.log(v) if v > 0 else 0.0
    def depth(self) -> int:
        return self.a.depth() + 1
    def __repr__(self):
        return f"log({self.a})"


def iterated_exp(n: int, base: float = 1.0) -> float:
    """Compute exp^n(base) = exp(exp(...exp(base)...))."""
    result = base
    for _ in range(n):
        result = math.exp(result)
    return result


# --- Demonstrations ---

def demo_tower_levels():
    """Show canonical EML numbers at each tower level."""
    print("=" * 60)
    print("TRANSCENDENCE TOWER: Canonical EML Numbers")
    print("=" * 60)
    
    # Level 0: Rationals
    print("\n📐 Level 0 (Rationals):")
    for q in [0, 1, -1, 1/2, 22/7]:
        expr = Rat(q)
        print(f"  {expr} = {expr.eval():.6f}  (depth={expr.depth()})")
    
    # Level 1: One exp/log application
    print("\n🌟 Level 1 (Single exp/log):")
    level1 = [
        ("e = exp(1)", Exp(Rat(1))),
        ("1/e = exp(-1)", Exp(Rat(-1))),
        ("log(2)", Log(Rat(2))),
        ("log(3)", Log(Rat(3))),
        ("√2 = exp(log(2)/2)", Exp(Mul(Log(Rat(2)), Rat(0.5)))),
    ]
    for name, expr in level1:
        print(f"  {name} = {expr.eval():.10f}  (depth={expr.depth()})")
    
    # Level 2: Two exp/log applications
    print("\n⭐ Level 2 (Double exp/log):")
    level2 = [
        ("e^e = exp(exp(1))", Exp(Exp(Rat(1)))),
        ("log(log(2))", Log(Log(Rat(2)))),  # Note: log(log(2)) < 0 since log(2) < 1... actually log(2)≈0.693 > 0 but log(0.693)≈-0.366
        ("e^e + log(2)", Add(Exp(Exp(Rat(1))), Log(Rat(2)))),
        ("exp(log(2)·log(3))", Exp(Mul(Log(Rat(2)), Log(Rat(3))))),
    ]
    for name, expr in level2:
        print(f"  {name} = {expr.eval():.10f}  (depth={expr.depth()})")
    
    # Level 3
    print("\n🌠 Level 3 (Triple exp/log):")
    level3 = [
        ("exp(exp(exp(1)))", Exp(Exp(Exp(Rat(1))))),
        ("exp(e^e)", Exp(Exp(Exp(Rat(1))))),
    ]
    for name, expr in level3:
        v = expr.eval()
        print(f"  {name} = {v:.6e}  (depth={expr.depth()})")


def demo_iterated_exponentials():
    """The iterated exponential sequence: 1, e, e^e, e^{e^e}, ..."""
    print("\n" + "=" * 60)
    print("ITERATED EXPONENTIALS: The Transcendence Cascade")
    print("=" * 60)
    print("\nexp^0(1) = 1  (algebraic)")
    print(f"exp^1(1) = e ≈ {math.e:.15f}  (transcendental by Schanuel)")
    
    val = math.e
    for n in range(2, 6):
        try:
            val = math.exp(val)
        except OverflowError:
            val = float('inf')
        status = "transcendental by Schanuel + ExpTranscPropagation"
        if val > 1e100:
            print(f"exp^{n}(1) ≈ 10^{math.log10(val):.1f}  ({status})")
        else:
            print(f"exp^{n}(1) ≈ {val:.6f}  ({status})")
    
    print("\nKey result: Under Schanuel's conjecture, ALL exp^n(1) for n ≥ 1")
    print("are transcendental. This is the Transcendence Cascade theorem.")


def demo_algebraic_independence():
    """Demonstrate algebraic independence tests."""
    print("\n" + "=" * 60)
    print("ALGEBRAIC INDEPENDENCE: Schanuel's Conjecture Implications")
    print("=" * 60)
    
    print("\nSchanuel's conjecture (n=1):")
    print("  If α ≠ 0, then at least one of {α, exp(α)} is transcendental.")
    print(f"  α = 1:     {{1, e}} → e is transcendental (1 is algebraic)")
    print(f"  α = log 2: {{log 2, 2}} → log 2 is transcendental (2 is algebraic)")
    
    print("\nSchanuel's conjecture (n=2):")
    print("  If α, β are ℚ-lin. indep., at least 2 of {α, β, e^α, e^β} are alg. indep.")
    print(f"  α=1, β=e: {{1, e, e, e^e}} → e and e^e are algebraically independent")
    print(f"  → e^e ≈ {math.exp(math.e):.10f} is transcendental")
    
    print(f"\n  α=1, β=log 2: {{1, log 2, e, 2}} → 1 and e are alg. indep.")
    print(f"  → exp(exp(1)) + log(2) ≈ {math.exp(math.e) + math.log(2):.10f}")
    print(f"     is transcendental (sum of alg. indep. transcendentals)")


def demo_eml_depth_bounds():
    """Show depth vs transcendental weight bounds."""
    print("\n" + "=" * 60)
    print("DEPTH vs TRANSCENDENTAL WEIGHT")
    print("=" * 60)
    
    exprs = [
        ("1", Rat(1)),
        ("exp(1)", Exp(Rat(1))),
        ("log(2)", Log(Rat(2))),
        ("exp(exp(1))", Exp(Exp(Rat(1)))),
        ("exp(1) + log(2)", Add(Exp(Rat(1)), Log(Rat(2)))),
        ("exp(exp(1)) + log(2)", Add(Exp(Exp(Rat(1))), Log(Rat(2)))),
        ("exp(log(2)·exp(1))", Exp(Mul(Log(Rat(2)), Exp(Rat(1))))),
    ]
    
    print(f"\n{'Expression':<25} {'Value':<15} {'Depth':<7} {'Weight':<8}")
    print("-" * 55)
    for name, expr in exprs:
        # Count exp and log nodes
        def count_ops(e):
            if isinstance(e, Rat): return 0, 0
            elif isinstance(e, Add):
                a = count_ops(e.a)
                b = count_ops(e.b)
                return a[0]+b[0], a[1]+b[1]
            elif isinstance(e, Mul):
                a = count_ops(e.a)
                b = count_ops(e.b)
                return a[0]+b[0], a[1]+b[1]
            elif isinstance(e, Exp):
                a = count_ops(e.a)
                return a[0]+1, a[1]
            elif isinstance(e, Log):
                a = count_ops(e.a)
                return a[0], a[1]+1
            return 0, 0
        
        ec, lc = count_ops(expr)
        weight = ec + lc
        print(f"  {name:<23} {expr.eval():<15.6f} {expr.depth():<7} {weight:<8}")
    
    print("\nTheorem: depth(e) ≤ transcWeight(e) for all EML expressions e")


if __name__ == "__main__":
    demo_tower_levels()
    demo_iterated_exponentials()
    demo_algebraic_independence()
    demo_eml_depth_bounds()


#!/usr/bin/env python3
"""
Visualization: EML Transcendence Tower

Standalone visualization of the transcendence tower structure,
showing how EML numbers stratify by depth and transcendence complexity.
"""

import math

def generate_tower_data():
    """Generate data for the transcendence tower visualization."""
    levels = {
        0: [
            ("0", 0), ("1", 1), ("-1", -1), ("1/2", 0.5),
            ("2", 2), ("3", 3), ("7", 7),
        ],
        1: [
            ("e", math.e), ("1/e", 1/math.e),
            ("log 2", math.log(2)), ("log 3", math.log(3)),
            ("log 10", math.log(10)),
        ],
        2: [
            ("e^e", math.exp(math.e)),
            ("e^e+log 2", math.exp(math.e) + math.log(2)),
            ("log(log 10)", math.log(math.log(10))),
        ],
    }
    return levels


def plot_tower():
    """Create the transcendence tower visualization."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import matplotlib.patches as mpatches
    except ImportError:
        print("matplotlib not available, printing text version")
        levels = generate_tower_data()
        for k, items in sorted(levels.items()):
            print(f"\nLevel {k}:")
            for name, val in items:
                print(f"  {name} = {val:.6f}")
        return
    
    levels = generate_tower_data()
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))
    
    # Left panel: Tower structure
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#9b59b6']
    
    for k, items in sorted(levels.items()):
        y_positions = [k] * len(items)
        x_positions = [v for _, v in items]
        labels = [n for n, _ in items]
        
        ax1.scatter(x_positions, y_positions, 
                   s=100, c=colors[k % len(colors)], 
                   zorder=5, alpha=0.8, edgecolors='black', linewidth=0.5)
        
        for x, y, label in zip(x_positions, y_positions, labels):
            ax1.annotate(label, (x, y), textcoords="offset points",
                        xytext=(0, 12), ha='center', fontsize=8,
                        fontweight='bold')
    
    ax1.set_xlabel('Value', fontsize=12)
    ax1.set_ylabel('Tower Level', fontsize=12)
    ax1.set_title('EML Transcendence Tower', fontsize=14, fontweight='bold')
    ax1.set_yticks([0, 1, 2])
    ax1.set_yticklabels(['Level 0\n(Algebraic)', 'Level 1\n(exp/log of rationals)', 
                        'Level 2\n(iterated exp/log)'])
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)
    ax1.axhline(y=1.5, color='gray', linestyle='--', alpha=0.5)
    
    # Right panel: Iterated exponentials (log scale)
    n_values = list(range(0, 6))
    iter_exp_values = []
    val = 1.0
    for n in n_values:
        iter_exp_values.append(val)
        try:
            val = math.exp(val)
        except OverflowError:
            val = float('inf')
    
    # Use log scale for display
    log_values = [math.log10(max(v, 1e-10)) for v in iter_exp_values if v < float('inf')]
    n_plot = n_values[:len(log_values)]
    
    ax2.bar(n_plot, log_values, color=[colors[min(n, 3)] for n in n_plot],
            edgecolor='black', linewidth=0.5, alpha=0.8)
    
    for n, lv in zip(n_plot, log_values):
        if iter_exp_values[n] < 1e6:
            ax2.text(n, lv + 0.3, f'{iter_exp_values[n]:.2f}', 
                    ha='center', fontsize=9, fontweight='bold')
        else:
            ax2.text(n, lv + 0.3, f'10^{lv:.1f}', 
                    ha='center', fontsize=9, fontweight='bold')
    
    ax2.set_xlabel('n (number of exp applications)', fontsize=12)
    ax2.set_ylabel('log₁₀(exp^n(1))', fontsize=12)
    ax2.set_title('Iterated Exponentials: The Cascade', fontsize=14, fontweight='bold')
    ax2.set_xticks(n_plot)
    ax2.grid(True, alpha=0.3, axis='y')
    
    # Add status labels
    status_labels = ['algebraic', 'transcendental\n(Schanuel n=1)', 
                     'transcendental\n(Schanuel n=2)', 
                     'transcendental\n(Schanuel n=3)',
                     'transcendental\n(cascade)', 'transcendental\n(cascade)']
    for n in n_plot:
        ax2.text(n, -1.5, status_labels[n], ha='center', fontsize=7,
                style='italic', color='gray')
    
    plt.tight_layout()
    plt.savefig('transcendence_tower.png', dpi=150, bbox_inches='tight')
    print("Saved transcendence_tower.png")
    plt.close()


if __name__ == "__main__":
    plot_tower()
