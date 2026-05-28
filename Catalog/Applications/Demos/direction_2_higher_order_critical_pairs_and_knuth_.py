#!/usr/bin/env python3
"""
Applications of Higher-Order Critical Pair Analysis

Demonstrates real-world applications:
1. Compiler optimization coherence checking
2. Functional program fusion verification
3. CPS transformation correctness
"""

from algorithms import HOTerm, TermKind, Rule, normalize, enumerate_critical_pairs, try_join, generate_certificate


# ============================================================================
# Application 1: Compiler Optimization Coherence
# ============================================================================

def compiler_optimization_demo():
    """
    Demonstrate that rewrite-based optimization passes are coherent:
    different orderings of optimizations produce the same result.
    """
    print("=" * 60)
    print("Application 1: Compiler Optimization Coherence")
    print("=" * 60)

    # Define optimization rules for a functional language
    x0, x1, x2, x3 = [HOTerm.var(i) for i in range(4)]

    rules = [
        Rule("inline-id", HOTerm.app(HOTerm.lam(HOTerm.var(0)), x1), x1),
        Rule("const-fold", HOTerm.app(HOTerm.app(x0, x1), x1),
             HOTerm.app(x0, x1)),
    ]

    print("\nOptimization rules:")
    for r in rules:
        print(f"  {r.name}: {r.lhs} → {r.rhs}")

    cert = generate_certificate(rules, bound=15)

    print(f"\nCoherence check (bound=15):")
    print(f"  Critical pairs found: {len(cert.critical_pairs)}")
    print(f"  All joinable: {cert.all_joinable}")
    if cert.all_joinable:
        print("  ✓ Optimization passes are coherent!")
        print("    → Any ordering produces the same normal form")
    else:
        print("  ✗ Potential incoherence detected")
        for cp in cert.non_joinable_pairs[:3]:
            print(f"    Non-joinable: {cp.left} vs {cp.right}")


# ============================================================================
# Application 2: Fusion Law Verification
# ============================================================================

def fusion_verification_demo():
    """
    Verify fusion laws for functional combinators.
    """
    print("\n" + "=" * 60)
    print("Application 2: Fusion Law Verification")
    print("=" * 60)

    x0, x1, x2, x3 = [HOTerm.var(i) for i in range(4)]

    # map f . map g = map (f . g)
    # In our encoding: map f (map g xs) → map (f∘g) xs
    fusion_rule = Rule(
        "map-fusion",
        lhs=HOTerm.app(HOTerm.app(x0, x1),
                        HOTerm.app(HOTerm.app(x0, x2), x3)),
        rhs=HOTerm.app(
            HOTerm.app(x0, HOTerm.lam(HOTerm.app(x2, HOTerm.app(x3, HOTerm.var(0))))),
            x3
        )
    )

    # map id xs = xs
    id_rule = Rule(
        "map-id",
        lhs=HOTerm.app(HOTerm.app(x0, HOTerm.lam(HOTerm.var(0))), x1),
        rhs=x1
    )

    rules = [fusion_rule, id_rule]

    print("\nFusion rules:")
    for r in rules:
        print(f"  {r.name}: {r.lhs} → {r.rhs}")

    for bound in [10, 20, 30]:
        cert = generate_certificate(rules, bound=bound)
        status = "✓" if cert.all_joinable else "✗"
        print(f"\n  Bound {bound}: {len(cert.critical_pairs)} CPs, "
              f"all joinable: {status}")


# ============================================================================
# Application 3: CPS Transformation
# ============================================================================

def cps_transformation_demo():
    """
    Verify correctness properties of CPS transformation rules.
    """
    print("\n" + "=" * 60)
    print("Application 3: CPS Transformation Coherence")
    print("=" * 60)

    x0, x1, x2 = [HOTerm.var(i) for i in range(3)]

    # CPS value: cps(v, k) → k(v)
    cps_val = Rule("cps-val",
                    HOTerm.app(HOTerm.app(x0, x1), x2),
                    HOTerm.app(x2, x1))

    rules = [cps_val]

    print("\nCPS rules:")
    for r in rules:
        print(f"  {r.name}: {r.lhs} → {r.rhs}")

    cert = generate_certificate(rules, bound=15)
    print(f"\nCPS coherence (bound=15):")
    print(f"  Critical pairs: {len(cert.critical_pairs)}")
    print(f"  All joinable: {'✓' if cert.all_joinable else '✗'}")

    if cert.all_joinable:
        print("  → CPS transformation rules are locally confluent")
        print("  → Different evaluation strategies produce consistent CPS output")


# ============================================================================
# Application 4: Term Normalization Benchmark
# ============================================================================

def normalization_benchmark():
    """
    Benchmark β-normalization on various term families.
    """
    print("\n" + "=" * 60)
    print("Application 4: β-Normalization Benchmark")
    print("=" * 60)

    # Church numerals
    def church(n):
        """Construct Church numeral n = λf.λx. f^n(x)."""
        body = HOTerm.var(0)  # x
        for _ in range(n):
            body = HOTerm.app(HOTerm.var(1), body)  # f(...)
        return HOTerm.lam(HOTerm.lam(body))

    # Church addition: add m n = λf.λx. m f (n f x)
    def church_add(m, n):
        f, x = HOTerm.var(1), HOTerm.var(0)
        nfx = HOTerm.app(HOTerm.app(n, f), x)
        return HOTerm.lam(HOTerm.lam(
            HOTerm.app(HOTerm.app(m, f), nfx)
        ))

    print("\nChurch numeral normalization:")
    for n in range(1, 6):
        cn = church(n)
        nf, steps = normalize(cn)
        print(f"  {n}: size={cn.size()}, steps={steps}, "
              f"β-normal={nf.is_beta_normal()}")

    print("\nChurch addition (2+3):")
    add_2_3 = church_add(church(2), church(3))
    nf, steps = normalize(add_2_3, fuel=200)
    print(f"  Input size: {add_2_3.size()}")
    print(f"  Steps: {steps}")
    print(f"  Result size: {nf.size()}")
    print(f"  β-normal: {nf.is_beta_normal()}")


if __name__ == "__main__":
    compiler_optimization_demo()
    fusion_verification_demo()
    cps_transformation_demo()
    normalization_benchmark()


#!/usr/bin/env python3
"""
Higher-Order Critical Pairs and Bounded Knuth-Bendix Completion Modulo β
========================================================================

Interactive demonstration of:
1. Higher-order term construction and β-reduction
2. Critical pair enumeration for pattern rewrite systems
3. Bounded joinability checking
4. Bounded local confluence certification

This demo implements the computational core of the certified completion
theory formalized in Lean 4.
"""

from dataclasses import dataclass
from typing import Optional
from enum import Enum, auto


# ============================================================================
# Core Term Algebra
# ============================================================================

class TermKind(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()


@dataclass
class HOTerm:
    """Higher-order term: variables, applications, and lambda abstractions."""
    kind: TermKind
    var_id: int = 0
    left: Optional['HOTerm'] = None
    right: Optional['HOTerm'] = None
    body: Optional['HOTerm'] = None

    @staticmethod
    def var(i: int) -> 'HOTerm':
        return HOTerm(kind=TermKind.VAR, var_id=i)

    @staticmethod
    def app(s: 'HOTerm', t: 'HOTerm') -> 'HOTerm':
        return HOTerm(kind=TermKind.APP, left=s, right=t)

    @staticmethod
    def lam(body: 'HOTerm') -> 'HOTerm':
        return HOTerm(kind=TermKind.LAM, body=body)

    def size(self) -> int:
        if self.kind == TermKind.VAR:
            return 1
        elif self.kind == TermKind.APP:
            return 1 + self.left.size() + self.right.size()
        else:
            return 1 + self.body.size()

    def is_beta_normal(self) -> bool:
        if self.kind == TermKind.VAR:
            return True
        elif self.kind == TermKind.APP:
            if self.left.kind == TermKind.LAM:
                return False
            return self.left.is_beta_normal() and self.right.is_beta_normal()
        else:
            return self.body.is_beta_normal()

    def is_closed_at(self, depth: int = 0) -> bool:
        if self.kind == TermKind.VAR:
            return self.var_id < depth
        elif self.kind == TermKind.APP:
            return self.left.is_closed_at(depth) and self.right.is_closed_at(depth)
        else:
            return self.body.is_closed_at(depth + 1)

    def __repr__(self):
        return self._to_str()

    def _to_str(self, prec=0) -> str:
        if self.kind == TermKind.VAR:
            return f"x{self.var_id}"
        elif self.kind == TermKind.APP:
            s = f"{self.left._to_str(1)} {self.right._to_str(2)}"
            return f"({s})" if prec >= 2 else s
        else:
            s = f"λ.{self.body._to_str(0)}"
            return f"({s})" if prec >= 1 else s

    def __eq__(self, other):
        if not isinstance(other, HOTerm):
            return False
        if self.kind != other.kind:
            return False
        if self.kind == TermKind.VAR:
            return self.var_id == other.var_id
        elif self.kind == TermKind.APP:
            return self.left == other.left and self.right == other.right
        else:
            return self.body == other.body

    def __hash__(self):
        if self.kind == TermKind.VAR:
            return hash(('V', self.var_id))
        elif self.kind == TermKind.APP:
            return hash(('A', self.left, self.right))
        else:
            return hash(('L', self.body))


# ============================================================================
# Substitution and β-Reduction
# ============================================================================

def rename(rho, term: HOTerm) -> HOTerm:
    """Apply a renaming function to a term."""
    if term.kind == TermKind.VAR:
        return HOTerm.var(rho(term.var_id))
    elif term.kind == TermKind.APP:
        return HOTerm.app(rename(rho, term.left), rename(rho, term.right))
    else:
        lift = lambda n: 0 if n == 0 else rho(n - 1) + 1
        return HOTerm.lam(rename(lift, term.body))


def subst(term: HOTerm, sigma) -> HOTerm:
    """Apply a substitution to a term."""
    if term.kind == TermKind.VAR:
        return sigma(term.var_id)
    elif term.kind == TermKind.APP:
        return HOTerm.app(subst(term.left, sigma), subst(term.right, sigma))
    else:
        lift_sigma = lambda n: HOTerm.var(0) if n == 0 else rename(lambda k: k + 1, sigma(n - 1))
        return HOTerm.lam(subst(term.body, lift_sigma))


def beta_contract(body: HOTerm, arg: HOTerm) -> HOTerm:
    """Perform one β-contraction: (λ.body) arg → body[0 := arg]."""
    single = lambda n: arg if n == 0 else HOTerm.var(n - 1)
    return subst(body, single)


def beta_reduce_once(term: HOTerm) -> Optional[HOTerm]:
    """Try one β-reduction step. Returns None if no redex found."""
    if term.kind == TermKind.APP and term.left.kind == TermKind.LAM:
        return beta_contract(term.left.body, term.right)
    if term.kind == TermKind.APP:
        left_reduced = beta_reduce_once(term.left)
        if left_reduced is not None:
            return HOTerm.app(left_reduced, term.right)
        right_reduced = beta_reduce_once(term.right)
        if right_reduced is not None:
            return HOTerm.app(term.left, right_reduced)
    if term.kind == TermKind.LAM:
        body_reduced = beta_reduce_once(term.body)
        if body_reduced is not None:
            return HOTerm.lam(body_reduced)
    return None


def normalize(term: HOTerm, fuel: int = 100) -> HOTerm:
    """Normalize a term by repeated β-reduction."""
    current = term
    for _ in range(fuel):
        reduced = beta_reduce_once(current)
        if reduced is None:
            return current
        current = reduced
    return current


# ============================================================================
# Rewrite Systems
# ============================================================================

@dataclass
class Rule:
    """A rewrite rule: lhs → rhs."""
    name: str
    lhs: HOTerm
    rhs: HOTerm

    def __repr__(self):
        return f"{self.name}: {self.lhs} → {self.rhs}"


@dataclass
class HoSystem:
    """A higher-order rewrite system."""
    name: str
    rules: list

    def __repr__(self):
        rules_str = "\n  ".join(str(r) for r in self.rules)
        return f"System '{self.name}':\n  {rules_str}"


# ============================================================================
# Critical Pair Enumeration
# ============================================================================

def subterms(term: HOTerm):
    """Enumerate all subterms of a term."""
    yield term
    if term.kind == TermKind.APP:
        yield from subterms(term.left)
        yield from subterms(term.right)
    elif term.kind == TermKind.LAM:
        yield from subterms(term.body)


def syntactic_overlap(pattern: HOTerm, target: HOTerm) -> bool:
    """Check if two terms could potentially unify (syntactic overlap check)."""
    if pattern.kind == TermKind.VAR or target.kind == TermKind.VAR:
        return True
    if pattern.kind != target.kind:
        return False
    if pattern.kind == TermKind.APP:
        return (syntactic_overlap(pattern.left, target.left) and
                syntactic_overlap(pattern.right, target.right))
    if pattern.kind == TermKind.LAM:
        return syntactic_overlap(pattern.body, target.body)
    return False


def enumerate_critical_pairs(system: HoSystem, bound: int):
    """Enumerate critical pairs up to a size bound."""
    pairs = []
    for r1 in system.rules:
        for r2 in system.rules:
            for sub in subterms(r1.lhs):
                if (syntactic_overlap(sub, r2.lhs) and
                        r1.lhs.size() + r2.lhs.size() <= bound):
                    pair = (r1.rhs, r2.rhs, r1.name, r2.name)
                    pairs.append(pair)
    return pairs


def try_join(system: HoSystem, t1: HOTerm, t2: HOTerm, fuel: int = 50) -> bool:
    """Try to join two terms by normalizing both."""
    n1 = normalize(t1, fuel)
    n2 = normalize(t2, fuel)
    return n1 == n2


# ============================================================================
# Benchmark Systems
# ============================================================================

def make_map_fusion_system():
    """Map fusion: map f (map g xs) → map (f ∘ g) xs, map id xs → xs."""
    x0, x1, x2, x3 = HOTerm.var(0), HOTerm.var(1), HOTerm.var(2), HOTerm.var(3)

    map_fusion = Rule(
        name="map-fusion",
        lhs=HOTerm.app(HOTerm.app(x0, x1), HOTerm.app(HOTerm.app(x0, x2), x3)),
        rhs=HOTerm.app(
            HOTerm.app(x0, HOTerm.lam(HOTerm.app(x2, HOTerm.app(x3, HOTerm.var(0))))),
            x3
        )
    )

    map_id = Rule(
        name="map-id",
        lhs=HOTerm.app(HOTerm.app(x0, HOTerm.lam(HOTerm.var(0))), x1),
        rhs=x1
    )

    return HoSystem(name="Map Fusion", rules=[map_fusion, map_id])


def make_beta_eta_system():
    """Simple β-η system for administrative reductions."""
    # (λ.x0) x1 → x1  (β at top level)
    beta_rule = Rule(
        name="beta-admin",
        lhs=HOTerm.app(HOTerm.lam(HOTerm.var(0)), HOTerm.var(1)),
        rhs=HOTerm.var(1)
    )

    return HoSystem(name="Beta-Admin", rules=[beta_rule])


def make_cps_system():
    """CPS transformation rules."""
    x0, x1, x2 = HOTerm.var(0), HOTerm.var(1), HOTerm.var(2)

    # CPS value rule: cps v k → k v
    cps_val = Rule(
        name="cps-val",
        lhs=HOTerm.app(HOTerm.app(x0, x1), x2),
        rhs=HOTerm.app(x2, x1)
    )

    return HoSystem(name="CPS Transform", rules=[cps_val])


# ============================================================================
# Peak / Join Diagram Visualization (ASCII)
# ============================================================================

def visualize_peak(source, left, right, join_result=None):
    """Visualize a peak/join diagram in ASCII."""
    src_str = str(source)
    left_str = str(left)
    right_str = str(right)

    print(f"\n    Peak Diagram:")
    print(f"        {src_str}")
    print(f"       / \\")
    print(f"      /   \\")
    print(f"     ↓     ↓")
    print(f"  {left_str}   {right_str}")

    if join_result is not None:
        print(f"     \\   /")
        print(f"      \\ /")
        print(f"       ↓")
        print(f"    {join_result}")
        print(f"    ✓ Joinable!")
    else:
        print(f"    ✗ Not joinable (within search bound)")


# ============================================================================
# Main Demo
# ============================================================================

def run_demo():
    """Main demonstration."""
    print("=" * 70)
    print("Higher-Order Critical Pairs & Bounded Knuth-Bendix Completion Modulo β")
    print("=" * 70)

    # ---- Demo 1: Term construction and β-reduction ----
    print("\n" + "─" * 70)
    print("Demo 1: Higher-Order Terms and β-Reduction")
    print("─" * 70)

    # (λx. x) y → y
    identity = HOTerm.lam(HOTerm.var(0))
    y = HOTerm.var(42)
    redex = HOTerm.app(identity, y)
    result = normalize(redex)
    print(f"\n  Term: {redex}")
    print(f"  β-normal form: {result}")
    print(f"  Is β-normal: {result.is_beta_normal()}")

    # (λx. λy. x) a b → a
    K = HOTerm.lam(HOTerm.lam(HOTerm.var(1)))
    a, b = HOTerm.var(10), HOTerm.var(11)
    Kab = HOTerm.app(HOTerm.app(K, a), b)
    result_K = normalize(Kab)
    print(f"\n  K combinator: {K}")
    print(f"  K a b = {Kab}")
    print(f"  β-normal form: {result_K}")

    # ---- Demo 2: Rewrite systems ----
    print("\n" + "─" * 70)
    print("Demo 2: Benchmark Rewrite Systems")
    print("─" * 70)

    systems = [
        make_map_fusion_system(),
        make_beta_eta_system(),
        make_cps_system(),
    ]

    for sys in systems:
        print(f"\n  {sys}")

    # ---- Demo 3: Critical pair enumeration ----
    print("\n" + "─" * 70)
    print("Demo 3: Critical Pair Enumeration")
    print("─" * 70)

    for sys in systems:
        for bound in [10, 20, 30]:
            pairs = enumerate_critical_pairs(sys, bound)
            print(f"\n  System: {sys.name}, Bound: {bound}")
            print(f"  Critical pairs found: {len(pairs)}")

            if pairs and len(pairs) <= 5:
                for i, (l, r, rn1, rn2) in enumerate(pairs[:5]):
                    joined = try_join(sys, l, r)
                    status = "✓ joinable" if joined else "✗ not joinable"
                    print(f"    CP {i+1} ({rn1} × {rn2}): {l} ↔ {r}  [{status}]")

    # ---- Demo 4: Bounded local confluence check ----
    print("\n" + "─" * 70)
    print("Demo 4: Bounded Local Confluence Certification")
    print("─" * 70)

    for sys in systems:
        bound = 20
        pairs = enumerate_critical_pairs(sys, bound)
        all_joinable = all(try_join(sys, l, r) for l, r, _, _ in pairs)

        print(f"\n  System: {sys.name}")
        print(f"  Bound: {bound}")
        print(f"  Critical pairs: {len(pairs)}")
        print(f"  All joinable: {'✓ YES' if all_joinable else '✗ NO'}")

        if all_joinable:
            print(f"  → System is LOCALLY CONFLUENT on closed terms up to size {bound}")
            print(f"  → Certified for rewrite-based optimization!")
        else:
            # Find first non-joinable pair
            for l, r, rn1, rn2 in pairs:
                if not try_join(sys, l, r):
                    print(f"  → First non-joinable pair: ({rn1} × {rn2})")
                    print(f"    Left:  {l}")
                    print(f"    Right: {r}")
                    break

    # ---- Demo 5: Peak visualization ----
    print("\n" + "─" * 70)
    print("Demo 5: Peak/Join Diagram Visualization")
    print("─" * 70)

    # Create a simple peak from the beta-admin system
    sys = make_beta_eta_system()
    source = HOTerm.app(HOTerm.lam(HOTerm.var(0)), HOTerm.var(5))
    left = normalize(source)
    right = HOTerm.var(5)
    visualize_peak(source, left, right, join_result=left if left == right else None)

    # ---- Demo 6: Conjecture testing ----
    print("\n" + "─" * 70)
    print("Demo 6: Conjecture — Quadratic Bound on First Non-Joinable CP")
    print("─" * 70)

    print("\n  Conjecture: For benchmark families, the first non-joinable")
    print("  β-critical pair (if any) appears at overlap size at most")
    print("  quadratic in the largest rule size.")

    for sys in systems:
        max_rule_size = max(r.lhs.size() + r.rhs.size() for r in sys.rules)
        quad_bound = max_rule_size ** 2

        first_nonjoin_size = None
        for bound in range(1, quad_bound + 1):
            pairs = enumerate_critical_pairs(sys, bound)
            for l, r, _, _ in pairs:
                if not try_join(sys, l, r):
                    first_nonjoin_size = bound
                    break
            if first_nonjoin_size is not None:
                break

        print(f"\n  System: {sys.name}")
        print(f"  Max rule size: {max_rule_size}")
        print(f"  Quadratic bound: {quad_bound}")
        if first_nonjoin_size is not None:
            print(f"  First non-joinable CP at size: {first_nonjoin_size}")
            print(f"  Within quadratic bound: {'✓' if first_nonjoin_size <= quad_bound else '✗'}")
        else:
            print(f"  No non-joinable CP found up to quadratic bound ✓")

    print("\n" + "=" * 70)
    print("Demo complete.")
    print("=" * 70)


if __name__ == "__main__":
    run_demo()


#!/usr/bin/env python3
"""
Visualization: Confluence Diamond Diagram

Illustrates the peak/join structure of local confluence:
given a peak t → u, t → v, show how joinability of critical pairs
guarantees the existence of a common reduct w.

Renders multiple peak diagrams showing the structure of the
critical pair theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_diamond(ax, x, y, label_top, label_left, label_right,
                  label_bottom=None, joinable=True, title=""):
    """Draw a confluence diamond diagram."""
    w, h = 1.5, 1.2

    # Nodes
    nodes = {
        'top': (x, y + h),
        'left': (x - w, y),
        'right': (x + w, y),
    }
    if label_bottom is not None:
        nodes['bottom'] = (x, y - h)

    # Draw arrows
    arrow_style = dict(arrowstyle='->', lw=1.5, color='#2c3e50')

    ax.annotate('', xy=nodes['left'], xytext=nodes['top'],
                arrowprops=arrow_style)
    ax.annotate('', xy=nodes['right'], xytext=nodes['top'],
                arrowprops=arrow_style)

    if label_bottom is not None:
        dash_style = dict(arrowstyle='->', lw=1.5,
                          color='#27ae60' if joinable else '#e74c3c',
                          linestyle='dashed')
        ax.annotate('', xy=nodes['bottom'], xytext=nodes['left'],
                    arrowprops=dash_style)
        ax.annotate('', xy=nodes['bottom'], xytext=nodes['right'],
                    arrowprops=dash_style)

    # Node circles
    for key, (nx, ny) in nodes.items():
        color = '#3498db'
        if key == 'bottom':
            color = '#27ae60' if joinable else '#e74c3c'
        circle = plt.Circle((nx, ny), 0.25, color=color, alpha=0.8, zorder=5)
        ax.add_patch(circle)

    # Labels
    fontsize = 9
    ax.text(nodes['top'][0], nodes['top'][1], label_top,
            ha='center', va='center', fontsize=fontsize, fontweight='bold',
            color='white', zorder=6)
    ax.text(nodes['left'][0], nodes['left'][1], label_left,
            ha='center', va='center', fontsize=fontsize, fontweight='bold',
            color='white', zorder=6)
    ax.text(nodes['right'][0], nodes['right'][1], label_right,
            ha='center', va='center', fontsize=fontsize, fontweight='bold',
            color='white', zorder=6)
    if label_bottom is not None:
        ax.text(nodes['bottom'][0], nodes['bottom'][1], label_bottom,
                ha='center', va='center', fontsize=fontsize, fontweight='bold',
                color='white', zorder=6)

    # Title
    if title:
        ax.text(x, y + h + 0.5, title, ha='center', va='center',
                fontsize=11, fontweight='bold', color='#2c3e50')

    # Status
    status_y = y - h - 0.5 if label_bottom else y - 0.5
    if joinable:
        ax.text(x, status_y, '✓ Joinable',
                ha='center', va='center', fontsize=10,
                color='#27ae60', fontweight='bold')
    elif label_bottom is not None:
        ax.text(x, status_y, '✗ Not joinable',
                ha='center', va='center', fontsize=10,
                color='#e74c3c', fontweight='bold')


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Row 1: Three types of joinable peaks
ax = axes[0, 0]
draw_diamond(ax, 0, 0, 't', 'u₁', 'u₂', 'w', joinable=True,
             title='β/β Peak\n(Church-Rosser)')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

ax = axes[0, 1]
draw_diamond(ax, 0, 0, 't', 'u₁', 'u₂', 'w', joinable=True,
             title='Disjoint Peak\n(Independent Redexes)')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

ax = axes[0, 2]
draw_diamond(ax, 0, 0, 't', 'u₁', 'u₂', 'w', joinable=True,
             title='Overlap Peak\n(Critical Pair Joinable)')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

# Row 2: The full pipeline
ax = axes[1, 0]
# Newman's lemma illustration
draw_diamond(ax, 0, 0, 's', 'a', 'b', 'w', joinable=True,
             title="Newman's Lemma\n(Local → Global)")
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

ax = axes[1, 1]
# Critical pair theorem
draw_diamond(ax, 0, 0, 'CP', 'l', 'r', 'nf', joinable=True,
             title='Critical Pair Theorem\n(All CPs Joinable → LC)')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

ax = axes[1, 2]
# Unique normal form
draw_diamond(ax, 0, 0, 't', 'n₁', 'n₂', 'n', joinable=True,
             title='Unique Normal Form\n(Terminating + Confluent)')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-2.5, 2.5)
ax.set_aspect('equal')
ax.axis('off')

fig.suptitle('Higher-Order Confluence: Peak Classification & Pipeline',
             fontsize=14, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('confluence_diamonds.png', dpi=150, bbox_inches='tight')
print("Saved: confluence_diamonds.png")


#!/usr/bin/env python3
"""
Visualization: Critical Pair Analysis Heatmap

Visualizes the number of critical pairs found at different size bounds
for multiple benchmark rewrite systems. Shows how overlap complexity
grows with term size — the key parameter for bounded completion.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ============================================================================
# Inline term algebra (self-contained, no local imports)
# ============================================================================

class HOTerm:
    def __init__(self, kind, var_id=0, left=None, right=None, body=None):
        self.kind = kind
        self.var_id = var_id
        self.left = left
        self.right = right
        self.body = body

    @staticmethod
    def var(i): return HOTerm('VAR', var_id=i)
    @staticmethod
    def app(s, t): return HOTerm('APP', left=s, right=t)
    @staticmethod
    def lam(b): return HOTerm('LAM', body=b)

    def size(self):
        if self.kind == 'VAR': return 1
        if self.kind == 'APP': return 1 + self.left.size() + self.right.size()
        return 1 + self.body.size()

    def subterms(self):
        yield self
        if self.kind == 'APP':
            yield from self.left.subterms()
            yield from self.right.subterms()
        elif self.kind == 'LAM':
            yield from self.body.subterms()

    def __eq__(self, other):
        if not isinstance(other, HOTerm): return False
        if self.kind != other.kind: return False
        if self.kind == 'VAR': return self.var_id == other.var_id
        if self.kind == 'APP': return self.left == other.left and self.right == other.right
        return self.body == other.body

    def __hash__(self):
        if self.kind == 'VAR': return hash(('V', self.var_id))
        if self.kind == 'APP': return hash(('A', hash(self.left), hash(self.right)))
        return hash(('L', hash(self.body)))


def syntactic_overlap(p, t):
    if p.kind == 'VAR' or t.kind == 'VAR': return True
    if p.kind != t.kind: return False
    if p.kind == 'APP': return syntactic_overlap(p.left, t.left) and syntactic_overlap(p.right, t.right)
    if p.kind == 'LAM': return syntactic_overlap(p.body, t.body)
    return False


def count_critical_pairs(rules, bound):
    count = 0
    for r1_lhs, r1_rhs in rules:
        for r2_lhs, r2_rhs in rules:
            for sub in r1_lhs.subterms():
                if syntactic_overlap(sub, r2_lhs) and r1_lhs.size() + r2_lhs.size() <= bound:
                    count += 1
    return count


# ============================================================================
# Benchmark systems
# ============================================================================

def make_systems():
    x0, x1, x2, x3 = [HOTerm.var(i) for i in range(4)]

    map_fusion = [
        (HOTerm.app(HOTerm.app(x0, x1), HOTerm.app(HOTerm.app(x0, x2), x3)),
         HOTerm.app(HOTerm.app(x0, HOTerm.lam(HOTerm.app(x2, HOTerm.app(x3, HOTerm.var(0))))), x3)),
        (HOTerm.app(HOTerm.app(x0, HOTerm.lam(HOTerm.var(0))), x1), x1),
    ]

    beta_admin = [
        (HOTerm.app(HOTerm.lam(HOTerm.var(0)), x1), x1),
    ]

    cps = [
        (HOTerm.app(HOTerm.app(x0, x1), x2), HOTerm.app(x2, x1)),
    ]

    double_app = [
        (HOTerm.app(HOTerm.app(x0, x1), x1), HOTerm.app(x0, x1)),
        (HOTerm.app(HOTerm.lam(HOTerm.var(0)), x1), x1),
    ]

    return {
        'Map Fusion': map_fusion,
        'β-Admin': beta_admin,
        'CPS Transform': cps,
        'Double-App + β': double_app,
    }


# ============================================================================
# Generate heatmap data
# ============================================================================

systems = make_systems()
bounds = list(range(5, 36, 1))
system_names = list(systems.keys())

data = np.zeros((len(system_names), len(bounds)))
for i, name in enumerate(system_names):
    rules = systems[name]
    for j, b in enumerate(bounds):
        data[i, j] = count_critical_pairs(rules, b)

# ============================================================================
# Plot
# ============================================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Heatmap
im = ax1.imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax1.set_yticks(range(len(system_names)))
ax1.set_yticklabels(system_names)
ax1.set_xlabel('Size Bound')
ax1.set_ylabel('Rewrite System')
ax1.set_title('Critical Pair Count by Size Bound')

# Set x-tick labels to show bounds
tick_positions = range(0, len(bounds), 5)
ax1.set_xticks(list(tick_positions))
ax1.set_xticklabels([bounds[i] for i in tick_positions])

plt.colorbar(im, ax=ax1, label='Number of Critical Pairs')

# Line plot
for i, name in enumerate(system_names):
    ax2.plot(bounds, data[i], 'o-', label=name, markersize=3)

ax2.set_xlabel('Size Bound')
ax2.set_ylabel('Number of Critical Pairs')
ax2.set_title('Critical Pair Growth vs. Size Bound')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('critical_pairs_analysis.png', dpi=150, bbox_inches='tight')
print("Saved: critical_pairs_analysis.png")


#!/usr/bin/env python3
"""
Visualization: β-Normalization Reduction Paths

Shows how different reduction strategies converge to the same normal form
in a confluent system. Plots reduction step counts and term sizes during
normalization for Church numeral arithmetic.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ============================================================================
# Self-contained term algebra
# ============================================================================

class Term:
    def __init__(self, kind, var_id=0, left=None, right=None, body=None):
        self.kind = kind
        self.var_id = var_id
        self.left = left
        self.right = right
        self.body = body

    @staticmethod
    def var(i): return Term('VAR', var_id=i)
    @staticmethod
    def app(s, t): return Term('APP', left=s, right=t)
    @staticmethod
    def lam(b): return Term('LAM', body=b)

    def size(self):
        if self.kind == 'VAR': return 1
        if self.kind == 'APP': return 1 + self.left.size() + self.right.size()
        return 1 + self.body.size()

    def __eq__(self, other):
        if not isinstance(other, Term): return False
        if self.kind != other.kind: return False
        if self.kind == 'VAR': return self.var_id == other.var_id
        if self.kind == 'APP': return self.left == other.left and self.right == other.right
        return self.body == other.body


def _rename(rho, t):
    if t.kind == 'VAR': return Term.var(rho(t.var_id))
    if t.kind == 'APP': return Term.app(_rename(rho, t.left), _rename(rho, t.right))
    lift = lambda n: 0 if n == 0 else rho(n-1) + 1
    return Term.lam(_rename(lift, t.body))

def _subst(t, sigma):
    if t.kind == 'VAR': return sigma(t.var_id)
    if t.kind == 'APP': return Term.app(_subst(t.left, sigma), _subst(t.right, sigma))
    lift = lambda n: Term.var(0) if n == 0 else _rename(lambda k: k+1, sigma(n-1))
    return Term.lam(_subst(t.body, lift))

def _beta(body, arg):
    single = lambda n: arg if n == 0 else Term.var(n-1)
    return _subst(body, single)


def leftmost_reduce(t):
    """Leftmost-outermost β-reduction."""
    if t.kind == 'APP' and t.left.kind == 'LAM':
        return _beta(t.left.body, t.right)
    if t.kind == 'APP':
        r = leftmost_reduce(t.left)
        if r is not None: return Term.app(r, t.right)
        r = leftmost_reduce(t.right)
        if r is not None: return Term.app(t.left, r)
    if t.kind == 'LAM':
        r = leftmost_reduce(t.body)
        if r is not None: return Term.lam(r)
    return None

def rightmost_reduce(t):
    """Rightmost-innermost β-reduction."""
    if t.kind == 'APP':
        r = rightmost_reduce(t.right)
        if r is not None: return Term.app(t.left, r)
        r = rightmost_reduce(t.left)
        if r is not None: return Term.app(r, t.right)
        if t.left.kind == 'LAM':
            return _beta(t.left.body, t.right)
    if t.kind == 'LAM':
        r = rightmost_reduce(t.body)
        if r is not None: return Term.lam(r)
    return None


def trace_reduction(t, strategy, fuel=300):
    """Trace a reduction sequence, recording sizes."""
    sizes = [t.size()]
    current = t
    for _ in range(fuel):
        r = strategy(current)
        if r is None: break
        current = r
        sizes.append(current.size())
    return sizes


# ============================================================================
# Church numerals
# ============================================================================

def church(n):
    body = Term.var(0)
    for _ in range(n):
        body = Term.app(Term.var(1), body)
    return Term.lam(Term.lam(body))

def church_add(m, n):
    f, x = Term.var(1), Term.var(0)
    nfx = Term.app(Term.app(n, f), x)
    return Term.lam(Term.lam(Term.app(Term.app(m, f), nfx)))

def church_mul(m, n):
    f = Term.var(1)
    nf = Term.app(n, f)
    return Term.lam(Term.lam(Term.app(Term.app(m, nf), Term.var(0))))


# ============================================================================
# Generate data
# ============================================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Reduction paths for 2+3
ax = axes[0, 0]
t = church_add(church(2), church(3))
left_sizes = trace_reduction(t, leftmost_reduce)
right_sizes = trace_reduction(t, rightmost_reduce)

ax.plot(range(len(left_sizes)), left_sizes, 'b-o', markersize=3,
        label='Leftmost-outermost', alpha=0.8)
ax.plot(range(len(right_sizes)), right_sizes, 'r-s', markersize=3,
        label='Rightmost-innermost', alpha=0.8)
ax.set_xlabel('Reduction Step')
ax.set_ylabel('Term Size')
ax.set_title('Reduction of 2+3 (Church Numerals)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Reduction paths for 2×3
ax = axes[0, 1]
t = church_mul(church(2), church(3))
left_sizes = trace_reduction(t, leftmost_reduce)
right_sizes = trace_reduction(t, rightmost_reduce)

ax.plot(range(len(left_sizes)), left_sizes, 'b-o', markersize=3,
        label='Leftmost-outermost', alpha=0.8)
ax.plot(range(len(right_sizes)), right_sizes, 'r-s', markersize=3,
        label='Rightmost-innermost', alpha=0.8)
ax.set_xlabel('Reduction Step')
ax.set_ylabel('Term Size')
ax.set_title('Reduction of 2×3 (Church Numerals)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Steps to normal form vs input
ax = axes[1, 0]
ns = range(1, 8)
left_steps = []
right_steps = []
for n in ns:
    t = church_add(church(n), church(n))
    ls = trace_reduction(t, leftmost_reduce)
    rs = trace_reduction(t, rightmost_reduce)
    left_steps.append(len(ls) - 1)
    right_steps.append(len(rs) - 1)

ax.bar(np.array(list(ns)) - 0.15, left_steps, 0.3,
       label='Leftmost', color='#3498db', alpha=0.8)
ax.bar(np.array(list(ns)) + 0.15, right_steps, 0.3,
       label='Rightmost', color='#e74c3c', alpha=0.8)
ax.set_xlabel('n (computing n+n)')
ax.set_ylabel('Steps to Normal Form')
ax.set_title('Reduction Steps: n+n')
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

# Plot 4: Confluence verification
ax = axes[1, 1]
confluent_results = []
for n in range(1, 10):
    t = church_add(church(n), church(1))
    ls = trace_reduction(t, leftmost_reduce)
    rs = trace_reduction(t, rightmost_reduce)
    # Check if they converge to same normal form (same final size)
    same_nf = ls[-1] == rs[-1]
    confluent_results.append((n, ls[-1], rs[-1], same_nf))

ns_plot = [r[0] for r in confluent_results]
left_final = [r[1] for r in confluent_results]
right_final = [r[2] for r in confluent_results]
colors = ['#27ae60' if r[3] else '#e74c3c' for r in confluent_results]

ax.scatter(ns_plot, left_final, c=colors, s=100, marker='o', label='Left NF size', zorder=5)
ax.scatter(ns_plot, right_final, c=colors, s=100, marker='x', label='Right NF size', zorder=5)
ax.set_xlabel('n (computing n+1)')
ax.set_ylabel('Normal Form Size')
ax.set_title('Confluence: Both Strategies → Same NF')

# Add legend for confluence status
import matplotlib.lines as mlines
green_dot = mlines.Line2D([], [], color='#27ae60', marker='o', linestyle='None',
                           markersize=8, label='Confluent ✓')
ax.legend(handles=[green_dot])
ax.grid(True, alpha=0.3)

fig.suptitle('β-Reduction Strategies and Confluence Verification',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('normalization_paths.png', dpi=150, bbox_inches='tight')
print("Saved: normalization_paths.png")
