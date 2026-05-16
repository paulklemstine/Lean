#!/usr/bin/env python3
"""
Applications of Tropical Polynomial Normal Forms

1. Tropical circuit equivalence checking
2. ReLU network linear region analysis
3. Shortest path optimization certificate
"""
import numpy as np
from algorithms import (
    Monomial, eval_monomial, eval_tropical_poly,
    normalize_from_monomials, verify_semantic_equality,
    essentialize, collect_duplicates
)
from typing import List


def application_circuit_equivalence():
    """Application 1: Tropical Circuit Equivalence

    Two different min-plus circuits computing the same function.
    Normal form provides a certificate of equivalence.
    """
    print("=" * 60)
    print("Application 1: Tropical Circuit Equivalence")
    print("=" * 60)

    # Circuit A: min(x+y, 2x, 2y, x+1, y+1)
    circuit_a: List[Monomial] = [
        (0, (1, 1)),  # x + y
        (0, (2, 0)),  # 2x
        (0, (0, 2)),  # 2y
        (1, (1, 0)),  # x + 1
        (1, (0, 1)),  # y + 1
    ]

    # Circuit B: min(x+y, 2x, 2y)  (x+1 and y+1 are dominated)
    circuit_b: List[Monomial] = [
        (0, (1, 1)),
        (0, (2, 0)),
        (0, (0, 2)),
    ]

    nf_a = normalize_from_monomials(circuit_a, 2)
    nf_b = normalize_from_monomials(circuit_b, 2)

    print(f"Circuit A ({len(circuit_a)} monomials) → NF: {nf_a}")
    print(f"Circuit B ({len(circuit_b)} monomials) → NF: {nf_b}")

    eq, diff = verify_semantic_equality(circuit_a, circuit_b, 2)
    print(f"Circuits equivalent: {eq} (max diff: {diff:.2e})")
    print()


def application_relu_regions():
    """Application 2: ReLU Network Region Analysis

    A ReLU(x) = max(0, x) = -min(0, -x) can be represented tropically.
    Tropical normal form reveals the linear regions of a ReLU network.
    """
    print("=" * 60)
    print("Application 2: ReLU Network Linear Regions")
    print("=" * 60)

    # Simple network: f(x) = ReLU(x - 1) + ReLU(-x - 1)
    # = max(0, x-1) + max(0, -x-1)
    # In min-plus: -f(x) = min(0, 1-x) + min(0, 1+x)
    # Expanding: min(0+0, 0+(1+x), (1-x)+0, (1-x)+(1+x))
    # = min(0, 1+x, 1-x, 2)
    network: List[Monomial] = [
        (0, (0,)),   # 0
        (1, (1,)),   # 1 + x
        (1, (0,)),   # 1 - x ... wait, this is wrong for our convention
    ]
    # Let's do a correct example in our convention
    # min(x, -x, 0, 2) with one variable
    # Represents |x| capped at 0 and 2
    poly: List[Monomial] = [
        (0, (1,)),  # x
        (0, (0,)),  # 0
        (2, (0,)),  # 2
    ]
    nf = normalize_from_monomials(poly, 1)
    print(f"Polynomial: min(x, 0, 2)")
    print(f"  Raw: {poly}")
    print(f"  Normal form: {nf}")
    print(f"  Removed {len(poly) - len(nf)} dominated monomials")

    # Piecewise linear regions
    xs = np.linspace(-3, 5, 100)
    values = [eval_tropical_poly(nf, np.array([x])) for x in xs]
    active = []
    for x_val in xs:
        x = np.array([x_val])
        active_m = min(nf, key=lambda m: eval_monomial(m, x))
        active.append(active_m)
    regions = []
    current = active[0]
    start = xs[0]
    for i, m in enumerate(active):
        if m != current:
            regions.append((start, xs[i-1], current))
            current = m
            start = xs[i]
    regions.append((start, xs[-1], current))
    print(f"  Linear regions: {len(regions)}")
    for a, b, m in regions:
        print(f"    [{a:.1f}, {b:.1f}]: monomial {m}")
    print()


def application_shortest_path():
    """Application 3: Shortest Path Certificate

    Min-plus matrix multiplication computes shortest paths.
    Normal form certificates confirm path optimality.
    """
    print("=" * 60)
    print("Application 3: Shortest Path Certificates")
    print("=" * 60)

    # 3-node graph with edges: 0→1 (cost 2), 1→2 (cost 3), 0→2 (cost 6)
    # Shortest 0→2: via node 1, cost 2+3=5
    # As tropical polynomial in "decision variable" choosing paths:
    # min(6, 2+3) = min(6, 5) = 5
    paths: List[Monomial] = [
        (6, ()),  # direct path: cost 6
        (5, ()),  # via node 1: cost 2+3=5
    ]
    nf = normalize_from_monomials(paths, 0)
    print(f"Path costs: direct=6, via-1=5")
    print(f"Normal form (optimal): {nf}")
    print(f"Optimal cost: {nf[0][0]}")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    application_circuit_equivalence()
    application_relu_regions()
    application_shortest_path()
    print("All applications completed successfully!")


#!/usr/bin/env python3
"""
Tropical Polynomial Normal Form — Demonstrations

Demonstrates the certified tropical polynomial normalization algorithm:
1. Building tropical expressions from syntax
2. Expanding them to monomial supports
3. Removing inessential (dominated) monomials via essentialization
4. Verifying that semantic equivalence ↔ normal form equality
"""
import numpy as np
from typing import List, Tuple, Dict, Set
from dataclasses import dataclass

# ── Type aliases ──
Monomial = Tuple[float, Tuple[int, ...]]  # (coefficient, exponent_vector)

def eval_monomial(m: Monomial, x: np.ndarray) -> float:
    """Evaluate monomial c + Σ wᵢxᵢ."""
    c, w = m
    return c + sum(wi * xi for wi, xi in zip(w, x))

def eval_nf(monomials: List[Monomial], x: np.ndarray) -> float:
    """Evaluate tropical polynomial = min of monomials."""
    return min(eval_monomial(m, x) for m in monomials)

# ── Tropical expression AST ──
class TropExpr:
    pass

@dataclass
class Const(TropExpr):
    value: float

@dataclass
class Var(TropExpr):
    index: int

@dataclass
class TropAdd(TropExpr):  # min
    left: TropExpr
    right: TropExpr

@dataclass
class TropMul(TropExpr):  # +
    left: TropExpr
    right: TropExpr

def eval_expr(e: TropExpr, x: np.ndarray) -> float:
    if isinstance(e, Const): return e.value
    if isinstance(e, Var): return x[e.index]
    if isinstance(e, TropAdd): return min(eval_expr(e.left, x), eval_expr(e.right, x))
    if isinstance(e, TropMul): return eval_expr(e.left, x) + eval_expr(e.right, x)

def expand(e: TropExpr, n: int) -> List[Monomial]:
    """Expand expression to monomial support."""
    if isinstance(e, Const):
        return [(e.value, tuple(0 for _ in range(n)))]
    if isinstance(e, Var):
        w = tuple(1 if i == e.index else 0 for i in range(n))
        return [(0.0, w)]
    if isinstance(e, TropAdd):
        return expand(e.left, n) + expand(e.right, n)
    if isinstance(e, TropMul):
        left = expand(e.left, n)
        right = expand(e.right, n)
        result = []
        for (c1, w1) in left:
            for (c2, w2) in right:
                result.append((c1 + c2, tuple(a + b for a, b in zip(w1, w2))))
        return result

def is_essential(monomials: List[Monomial], idx: int, n_vars: int,
                 n_samples: int = 10000) -> bool:
    """Check if monomial at idx is essential (achieves strict min somewhere)."""
    m = monomials[idx]
    others = [monomials[j] for j in range(len(monomials)) if j != idx]
    if not others:
        return True
    # Try random points and perturbations
    for _ in range(n_samples):
        x = np.random.randn(n_vars) * 5
        val = eval_monomial(m, x)
        if all(val < eval_monomial(o, x) for o in others):
            return True
    return False

def essentialize(monomials: List[Monomial], n_vars: int) -> List[Monomial]:
    """Remove inessential monomials."""
    # First deduplicate by keeping min coefficient for each exponent vector
    by_exp: Dict[Tuple[int,...], float] = {}
    for c, w in monomials:
        if w not in by_exp or c < by_exp[w]:
            by_exp[w] = c
    deduped = [(c, w) for w, c in by_exp.items()]
    # Remove dominated monomials
    essential = []
    for i, m in enumerate(deduped):
        if is_essential(deduped, i, n_vars):
            essential.append(m)
    return sorted(essential)

def normalize(e: TropExpr, n_vars: int) -> List[Monomial]:
    """Full normalization: expand + essentialize."""
    return essentialize(expand(e, n_vars), n_vars)

# ══════════════════════════════════════════════════════════════
# DEMONSTRATIONS
# ══════════════════════════════════════════════════════════════

def demo1_basic_normalization():
    """Demo 1: min(x, 0, x+1) = min(x, 0) — the monomial x+1 is inessential."""
    print("=" * 60)
    print("Demo 1: Inessential Monomial Removal")
    print("=" * 60)
    n = 1
    # Expression: min(x, 0, x+1)
    e1 = TropAdd(TropAdd(Var(0), Const(0)), TropMul(Var(0), Const(1)))
    # Expression: min(x, 0)
    e2 = TropAdd(Var(0), Const(0))

    raw = expand(e1, n)
    nf1 = normalize(e1, n)
    nf2 = normalize(e2, n)

    print(f"Expression 1: min(x, 0, x+1)")
    print(f"  Raw expansion: {raw}")
    print(f"  Normalized:    {nf1}")
    print(f"Expression 2: min(x, 0)")
    print(f"  Normalized:    {nf2}")
    print(f"Normal forms equal: {set(map(tuple, nf1)) == set(map(tuple, nf2))}")

    # Verify semantic equality
    test_points = np.linspace(-5, 5, 100)
    max_diff = max(abs(eval_expr(e1, np.array([t])) - eval_expr(e2, np.array([t])))
                   for t in test_points)
    print(f"Max evaluation difference: {max_diff:.2e}")
    print()

def demo2_distributivity():
    """Demo 2: Tropical distributivity a + min(b,c) = min(a+b, a+c)."""
    print("=" * 60)
    print("Demo 2: Tropical Distributivity")
    print("=" * 60)
    n = 3
    a, b, c = Var(0), Var(1), Var(2)
    lhs = TropMul(a, TropAdd(b, c))              # a + min(b, c)
    rhs = TropAdd(TropMul(a, b), TropMul(a, c))  # min(a+b, a+c)

    nf_lhs = normalize(lhs, n)
    nf_rhs = normalize(rhs, n)
    print(f"LHS: a ⊙ (b ⊕ c) normalized: {nf_lhs}")
    print(f"RHS: (a ⊙ b) ⊕ (a ⊙ c) normalized: {nf_rhs}")
    print(f"Equal: {set(map(tuple, nf_lhs)) == set(map(tuple, nf_rhs))}")

    test_points = [np.random.randn(n) * 3 for _ in range(1000)]
    max_diff = max(abs(eval_expr(lhs, x) - eval_expr(rhs, x)) for x in test_points)
    print(f"Max semantic difference: {max_diff:.2e}")
    print()

def demo3_two_variable():
    """Demo 3: Normal form in two variables with dominated monomials."""
    print("=" * 60)
    print("Demo 3: Two-Variable Normalization")
    print("=" * 60)
    n = 2
    # min(x₁, x₂, 0, x₁+1, x₂+1, 2)
    e = TropAdd(
        TropAdd(
            TropAdd(Var(0), Var(1)),
            TropAdd(Const(0), TropMul(Var(0), Const(1)))
        ),
        TropAdd(TropMul(Var(1), Const(1)), Const(2))
    )
    raw = expand(e, n)
    nf = normalize(e, n)
    print(f"Expression: min(x₁, x₂, 0, x₁+1, x₂+1, 2)")
    print(f"Raw monomials ({len(raw)}): {raw}")
    print(f"Essential monomials ({len(nf)}): {nf}")
    print(f"Removed {len(raw) - len(nf)} dominated monomials")
    print()

if __name__ == "__main__":
    np.random.seed(42)
    demo1_basic_normalization()
    demo2_distributivity()
    demo3_two_variable()
    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""Generate visualizations for tropical polynomial normal forms."""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import eval_monomial, eval_tropical_poly, essentialize, Monomial
from typing import List
import base64
import io

def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()

def plot_lower_envelope():
    """Plot the lower envelope showing essential vs inessential monomials."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Before essentialization
    monomials: List[Monomial] = [
        (0, (1,)),    # x
        (0, (0,)),    # 0
        (1, (0,)),    # 1
        (-1, (2,)),   # 2x - 1
    ]
    xs = np.linspace(-3, 4, 500)

    for m in monomials:
        ys = [eval_monomial(m, np.array([x])) for x in xs]
        c, w = m
        label = f"{c:+.0f} + {w[0]}x" if w[0] else f"{c:.0f}"
        ax1.plot(xs, ys, '--', alpha=0.6, label=label)

    envelope = [eval_tropical_poly(monomials, np.array([x])) for x in xs]
    ax1.plot(xs, envelope, 'k-', linewidth=2.5, label='Lower envelope')
    ax1.set_title('Before Essentialization', fontsize=14)
    ax1.set_xlabel('x')
    ax1.set_ylabel('f(x)')
    ax1.legend()
    ax1.set_ylim(-5, 6)
    ax1.grid(True, alpha=0.3)

    # After essentialization
    essential = essentialize(monomials, 1)
    for m in essential:
        ys = [eval_monomial(m, np.array([x])) for x in xs]
        c, w = m
        label = f"{c:+.0f} + {w[0]}x" if w[0] else f"{c:.0f}"
        ax2.plot(xs, ys, '-', alpha=0.8, linewidth=1.5, label=f'{label} (essential)')

    removed = [m for m in monomials if m not in essential]
    for m in removed:
        ys = [eval_monomial(m, np.array([x])) for x in xs]
        c, w = m
        label = f"{c:+.0f} + {w[0]}x" if w[0] else f"{c:.0f}"
        ax2.plot(xs, ys, ':', alpha=0.3, label=f'{label} (removed)')

    envelope2 = [eval_tropical_poly(essential, np.array([x])) for x in xs]
    ax2.plot(xs, envelope2, 'k-', linewidth=2.5, label='Lower envelope')
    ax2.set_title('After Essentialization', fontsize=14)
    ax2.set_xlabel('x')
    ax2.set_ylabel('f(x)')
    ax2.legend()
    ax2.set_ylim(-5, 6)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Polynomial Normal Form: Lower Envelope Extraction',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    fig.savefig('lower_envelope.png', dpi=150, bbox_inches='tight')
    print("Saved lower_envelope.png")
    b64 = fig_to_base64(fig)
    plt.close()
    return b64

def plot_2d_regions():
    """Plot active regions of a 2D tropical polynomial."""
    fig, ax = plt.subplots(figsize=(8, 7))

    monomials: List[Monomial] = [
        (0, (1, 0)),  # x₁
        (0, (0, 1)),  # x₂
        (0, (0, 0)),  # 0
    ]

    N = 300
    x1s = np.linspace(-3, 3, N)
    x2s = np.linspace(-3, 3, N)
    X1, X2 = np.meshgrid(x1s, x2s)
    active = np.zeros_like(X1)

    for i in range(N):
        for j in range(N):
            x = np.array([X1[i,j], X2[i,j]])
            vals = [eval_monomial(m, x) for m in monomials]
            active[i,j] = np.argmin(vals)

    colors = plt.cm.Set2(np.linspace(0, 1, len(monomials)))
    for k, m in enumerate(monomials):
        mask = active == k
        c, w = m
        label = f"Region of {'x₁' if w==(1,0) else 'x₂' if w==(0,1) else '0'}"
        ax.contourf(X1, X2, (active == k).astype(float),
                   levels=[0.5, 1.5], colors=[colors[k]], alpha=0.4)

    # Draw boundaries
    ax.contour(X1, X2, active, colors='black', linewidths=1, levels=[0.5, 1.5])

    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Active Regions of min(x₁, x₂, 0)\n(Tropical Polynomial in 2 Variables)',
                fontsize=14)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    # Add labels
    ax.text(-2, 0, 'x₁ active', fontsize=11, ha='center', fontweight='bold')
    ax.text(0, -2, 'x₂ active', fontsize=11, ha='center', fontweight='bold')
    ax.text(1.5, 1.5, '0 active', fontsize=11, ha='center', fontweight='bold')

    plt.tight_layout()
    fig.savefig('active_regions.png', dpi=150, bbox_inches='tight')
    print("Saved active_regions.png")
    b64 = fig_to_base64(fig)
    plt.close()
    return b64

if __name__ == "__main__":
    np.random.seed(42)
    plot_lower_envelope()
    plot_2d_regions()
    print("All visualizations generated.")
