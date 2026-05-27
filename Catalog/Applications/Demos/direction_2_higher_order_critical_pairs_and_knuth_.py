#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Higher-Order Critical Pair Theory
===============================================================================

Demonstrates how the bounded critical pair theorem applies to:
1. Compiler optimization verification (map fusion)
2. CPS transformation coherence
3. Deforestation rule systems
"""

from algorithms import (
    Term, Rule, RewriteSystem,
    certify_bounded_confluence, bounded_normalize,
    enumerate_critical_pairs
)


def compiler_optimization_demo():
    """Demonstrate that map fusion rules are coherent."""
    print("=" * 60)
    print("  Application 1: Compiler Optimization Verification")
    print("=" * 60)
    print()
    print("  Scenario: A functional language compiler applies")
    print("  map fusion and identity elimination as optimizations.")
    print("  We verify these can be applied in any order.")
    print()

    map_fusion = Rule(
        name="map-fusion",
        lhs=Term.app(Term.app(Term.var(0), Term.var(1)),
                      Term.app(Term.app(Term.var(0), Term.var(2)), Term.var(3))),
        rhs=Term.app(Term.app(Term.var(0),
                               Term.lam(Term.app(Term.var(2), Term.app(Term.var(3), Term.var(0))))),
                      Term.var(3))
    )
    map_id = Rule(
        name="map-id",
        lhs=Term.app(Term.app(Term.var(0), Term.lam(Term.var(0))), Term.var(1)),
        rhs=Term.var(1)
    )
    system = RewriteSystem("CompilerOpts", [map_fusion, map_id])

    cert = certify_bounded_confluence(system, bound=20)
    print(f"  Certificate: {cert}")
    print()
    if cert.is_locally_confluent:
        print("  ✓ VERIFIED: Optimization passes are coherent.")
        print("    Any order of applying map-fusion and map-id")
        print("    produces the same result on bounded programs.")
    else:
        print(f"  ✗ WARNING: {len(cert.non_joinable_pairs)} non-joinable pairs found.")


def cps_coherence_demo():
    """Demonstrate CPS administrative reduction coherence."""
    print()
    print("=" * 60)
    print("  Application 2: CPS Transformation Coherence")
    print("=" * 60)
    print()
    print("  Scenario: After CPS transformation, administrative")
    print("  β-redexes must be reduced. We verify that different")
    print("  reduction orders yield the same result.")
    print()

    admin_beta = Rule(
        name="admin-beta",
        lhs=Term.app(Term.lam(Term.var(0)), Term.var(1)),
        rhs=Term.var(1)
    )
    system = RewriteSystem("CPS-Admin", [admin_beta])

    cert = certify_bounded_confluence(system, bound=15)
    print(f"  Certificate: {cert}")
    print()
    if cert.is_locally_confluent:
        print("  ✓ VERIFIED: CPS administrative reductions are coherent.")


def deforestation_demo():
    """Demonstrate deforestation rule coherence."""
    print()
    print("=" * 60)
    print("  Application 3: Deforestation / Fold-Build Fusion")
    print("=" * 60)
    print()
    print("  Scenario: The fold/build fusion law eliminates")
    print("  intermediate data structures. We verify coherence.")
    print()

    fold_build = Rule(
        name="fold-build",
        lhs=Term.app(Term.app(Term.app(Term.var(0), Term.var(1)),
                               Term.var(2)),
                      Term.app(Term.var(3), Term.var(4))),
        rhs=Term.app(Term.app(Term.var(4), Term.var(1)), Term.var(2))
    )
    system = RewriteSystem("FoldBuild", [fold_build])

    cert = certify_bounded_confluence(system, bound=20)
    print(f"  Certificate: {cert}")
    print()
    if cert.is_locally_confluent:
        print("  ✓ VERIFIED: Deforestation rules are coherent.")


def growth_analysis():
    """Analyze critical pair growth across size bounds."""
    print()
    print("=" * 60)
    print("  Growth Analysis: Critical Pairs vs Size Bound")
    print("=" * 60)
    print()

    map_fusion = Rule(
        name="map-fusion",
        lhs=Term.app(Term.app(Term.var(0), Term.var(1)),
                      Term.app(Term.app(Term.var(0), Term.var(2)), Term.var(3))),
        rhs=Term.app(Term.app(Term.var(0),
                               Term.lam(Term.app(Term.var(2), Term.app(Term.var(3), Term.var(0))))),
                      Term.var(3))
    )
    map_id = Rule(
        name="map-id",
        lhs=Term.app(Term.app(Term.var(0), Term.lam(Term.var(0))), Term.var(1)),
        rhs=Term.var(1)
    )
    system = RewriteSystem("MapFusion", [map_fusion, map_id])

    print(f"  {'Bound N':>8} {'CPs':>6} {'N²':>6} {'Ratio':>8}")
    print(f"  {'-'*32}")
    for N in range(5, 35, 5):
        cps = enumerate_critical_pairs(system, N)
        ratio = len(cps) / (N * N) if N > 0 else 0
        print(f"  {N:>8} {len(cps):>6} {N*N:>6} {ratio:>8.3f}")


if __name__ == "__main__":
    compiler_optimization_demo()
    cps_coherence_demo()
    deforestation_demo()
    growth_analysis()


#!/usr/bin/env python3
"""
Higher-Order Critical Pairs and Bounded Knuth-Bendix Completion Modulo β
========================================================================
Interactive demonstration of higher-order rewriting theory concepts.

This demo:
1. Constructs benchmark higher-order rewrite systems (map fusion, CPS, etc.)
2. Enumerates overlaps and computes critical pairs
3. Attempts bounded joining of critical pairs
4. Reports bounded local confluence status
5. Visualizes peak/join diagrams
"""

from dataclasses import dataclass
from typing import Optional
from enum import Enum, auto


# ============================================================================
# Term representation (de Bruijn indices)
# ============================================================================

class TermKind(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()


@dataclass(frozen=True)
class Term:
    """Lambda term with de Bruijn indices."""
    kind: TermKind
    var_idx: int = 0
    left: Optional['Term'] = None
    right: Optional['Term'] = None
    body: Optional['Term'] = None

    @staticmethod
    def var(i: int) -> 'Term':
        return Term(TermKind.VAR, var_idx=i)

    @staticmethod
    def app(s: 'Term', t: 'Term') -> 'Term':
        return Term(TermKind.APP, left=s, right=t)

    @staticmethod
    def lam(body: 'Term') -> 'Term':
        return Term(TermKind.LAM, body=body)

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

    def is_closed_at(self, depth: int) -> bool:
        if self.kind == TermKind.VAR:
            return self.var_idx < depth
        elif self.kind == TermKind.APP:
            return self.left.is_closed_at(depth) and self.right.is_closed_at(depth)
        else:
            return self.body.is_closed_at(depth + 1)

    def is_closed(self) -> bool:
        return self.is_closed_at(0)

    def pretty(self, depth=0) -> str:
        if self.kind == TermKind.VAR:
            return f"x{self.var_idx}"
        elif self.kind == TermKind.APP:
            l = self.left.pretty(depth)
            r = self.right.pretty(depth)
            return f"({l} {r})"
        else:
            b = self.body.pretty(depth + 1)
            return f"(λ.{b})"

    def subterms(self) -> list['Term']:
        result = [self]
        if self.kind == TermKind.APP:
            result.extend(self.left.subterms())
            result.extend(self.right.subterms())
        elif self.kind == TermKind.LAM:
            result.extend(self.body.subterms())
        return result


# ============================================================================
# Substitution
# ============================================================================

def rename(rho, t: Term) -> Term:
    if t.kind == TermKind.VAR:
        return Term.var(rho(t.var_idx))
    elif t.kind == TermKind.APP:
        return Term.app(rename(rho, t.left), rename(rho, t.right))
    else:
        lift_rho = lambda n: 0 if n == 0 else rho(n - 1) + 1
        return Term.lam(rename(lift_rho, t.body))


def subst(t: Term, sigma) -> Term:
    if t.kind == TermKind.VAR:
        return sigma(t.var_idx)
    elif t.kind == TermKind.APP:
        return Term.app(subst(t.left, sigma), subst(t.right, sigma))
    else:
        lift_sigma = lambda n: Term.var(0) if n == 0 else rename(lambda x: x + 1, sigma(n - 1))
        return Term.lam(subst(t.body, lift_sigma))


def single_subst(s: Term):
    return lambda n: s if n == 0 else Term.var(n - 1)


def beta_contract(body: Term, arg: Term) -> Term:
    return subst(body, single_subst(arg))


# ============================================================================
# Rewrite rules and systems
# ============================================================================

@dataclass
class Rule:
    name: str
    lhs: Term
    rhs: Term


@dataclass
class RewriteSystem:
    name: str
    rules: list[Rule]


def syntactic_match(pattern: Term, target: Term) -> bool:
    """Check if pattern could match target (conservative)."""
    if pattern.kind == TermKind.VAR or target.kind == TermKind.VAR:
        return True
    if pattern.kind != target.kind:
        return False
    if pattern.kind == TermKind.APP:
        return syntactic_match(pattern.left, target.left) and \
               syntactic_match(pattern.right, target.right)
    if pattern.kind == TermKind.LAM:
        return syntactic_match(pattern.body, target.body)
    return False


# ============================================================================
# Critical pair enumeration
# ============================================================================

@dataclass
class CriticalPair:
    left: Term
    right: Term
    rule1: str
    rule2: str
    overlap_term: Optional[Term] = None


def enumerate_critical_pairs(system: RewriteSystem, bound: int) -> list[CriticalPair]:
    """Enumerate candidate critical pairs up to a size bound."""
    pairs = []
    for r1 in system.rules:
        for r2 in system.rules:
            for sub in r1.lhs.subterms():
                if syntactic_match(sub, r2.lhs) and \
                   r1.lhs.size() + r2.lhs.size() <= bound:
                    cp = CriticalPair(
                        left=r1.rhs,
                        right=r2.rhs,
                        rule1=r1.name,
                        rule2=r2.name,
                        overlap_term=sub
                    )
                    pairs.append(cp)
    return pairs


# ============================================================================
# Bounded normalization and joining
# ============================================================================

def try_beta_reduce(t: Term) -> Optional[Term]:
    """Attempt one top-level beta reduction."""
    if t.kind == TermKind.APP and t.left.kind == TermKind.LAM:
        return beta_contract(t.left.body, t.right)
    return None


def bounded_normalize(t: Term, fuel: int) -> Term:
    """Normalize a term with bounded fuel."""
    if fuel <= 0:
        return t
    result = try_beta_reduce(t)
    if result is not None:
        return bounded_normalize(result, fuel - 1)
    if t.kind == TermKind.APP:
        s = bounded_normalize(t.left, fuel - 1)
        u = bounded_normalize(t.right, fuel - 1)
        if s != t.left or u != t.right:
            return Term.app(s, u)
    elif t.kind == TermKind.LAM:
        body = bounded_normalize(t.body, fuel - 1)
        if body != t.body:
            return Term.lam(body)
    return t


def try_join(t: Term, u: Term, fuel: int = 100) -> bool:
    """Try to join two terms by normalizing both."""
    nt = bounded_normalize(t, fuel)
    nu = bounded_normalize(u, fuel)
    return nt == nu


# ============================================================================
# Benchmark systems
# ============================================================================

def make_map_fusion_system() -> RewriteSystem:
    """Map fusion + identity map elimination."""
    # map f (map g xs) → map (f∘g) xs
    map_fusion = Rule(
        name="map-fusion",
        lhs=Term.app(Term.app(Term.var(0), Term.var(1)),
                      Term.app(Term.app(Term.var(0), Term.var(2)), Term.var(3))),
        rhs=Term.app(Term.app(Term.var(0), Term.lam(Term.app(Term.var(2), Term.app(Term.var(3), Term.var(0))))),
                      Term.var(3))
    )
    # map (λx.x) xs → xs
    map_id = Rule(
        name="map-id",
        lhs=Term.app(Term.app(Term.var(0), Term.lam(Term.var(0))), Term.var(1)),
        rhs=Term.var(1)
    )
    return RewriteSystem("MapFusion", [map_fusion, map_id])


def make_beta_system() -> RewriteSystem:
    """Pure β-reduction system (no extra rules)."""
    return RewriteSystem("PureBeta", [])


def make_cps_system() -> RewriteSystem:
    """CPS transformation rules (simplified)."""
    # Administrative β: (λ.t) v → t[v]
    admin_beta = Rule(
        name="admin-beta",
        lhs=Term.app(Term.lam(Term.var(0)), Term.var(1)),
        rhs=Term.var(1)
    )
    return RewriteSystem("CPS-admin", [admin_beta])


def make_fold_build_system() -> RewriteSystem:
    """Fold/build fusion (simplified)."""
    # foldr f z (build g) → g f z
    fold_build = Rule(
        name="fold-build",
        lhs=Term.app(Term.app(Term.app(Term.var(0), Term.var(1)),
                               Term.var(2)),
                      Term.app(Term.var(3), Term.var(4))),
        rhs=Term.app(Term.app(Term.var(4), Term.var(1)), Term.var(2))
    )
    return RewriteSystem("FoldBuild", [fold_build])


# ============================================================================
# Analysis and reporting
# ============================================================================

def analyze_system(system: RewriteSystem, bound: int = 20):
    """Analyze a rewrite system for bounded local confluence."""
    print(f"\n{'='*60}")
    print(f"  System: {system.name}")
    print(f"  Rules: {len(system.rules)}")
    print(f"  Size bound: {bound}")
    print(f"{'='*60}")

    for r in system.rules:
        print(f"  {r.name}: {r.lhs.pretty()} → {r.rhs.pretty()}")
        print(f"    LHS size: {r.lhs.size()}, RHS size: {r.rhs.size()}")
        print(f"    LHS β-normal: {r.lhs.is_beta_normal()}")

    # Enumerate critical pairs
    cps = enumerate_critical_pairs(system, bound)
    print(f"\n  Critical pairs found: {len(cps)}")

    # Attempt joining
    joinable = 0
    non_joinable = []
    for i, cp in enumerate(cps):
        joined = try_join(cp.left, cp.right)
        if joined:
            joinable += 1
        else:
            non_joinable.append(cp)
        if i < 5:  # Show first 5
            status = "✓ joinable" if joined else "✗ NOT joinable"
            print(f"    CP {i+1}: {cp.left.pretty()} ↔ {cp.right.pretty()} [{status}]")
            print(f"           from {cp.rule1} × {cp.rule2}")

    if len(cps) > 5:
        print(f"    ... ({len(cps) - 5} more)")

    print(f"\n  Joinable: {joinable}/{len(cps)}")

    if not non_joinable:
        print(f"  ✓ ALL critical pairs joinable up to size {bound}")
        print(f"  → System satisfies bounded local confluence criterion")
    else:
        print(f"  ✗ {len(non_joinable)} non-joinable critical pair(s)")
        print(f"  First non-joinable pair:")
        cp = non_joinable[0]
        print(f"    {cp.left.pretty()} ↔ {cp.right.pretty()}")

    return cps, non_joinable


def visualize_peak(cp: CriticalPair, system_name: str = ""):
    """Display a peak/join diagram in ASCII art."""
    print(f"\n  Peak Diagram ({system_name}):")
    print(f"         t")
    print(f"        / \\")
    print(f"  {cp.rule1:>8}   {cp.rule2}")
    print(f"      /       \\")
    l = cp.left.pretty()[:20]
    r = cp.right.pretty()[:20]
    print(f"    {l:<20} {r}")
    joined = try_join(cp.left, cp.right)
    if joined:
        nf = bounded_normalize(cp.left, 100).pretty()[:20]
        print(f"      \\       /")
        print(f"       \\     /")
        print(f"        {nf}")
        print(f"      (joinable ✓)")
    else:
        print(f"      ?       ?")
        print(f"     (not joinable ✗)")


# ============================================================================
# Main demo
# ============================================================================

def main():
    print("=" * 60)
    print("  Higher-Order Critical Pairs")
    print("  Bounded Knuth-Bendix Completion Modulo β")
    print("=" * 60)

    # Benchmark systems
    systems = [
        make_map_fusion_system(),
        make_beta_system(),
        make_cps_system(),
        make_fold_build_system(),
    ]

    all_results = []
    for sys in systems:
        cps, non_joinable = analyze_system(sys, bound=20)
        all_results.append((sys.name, len(cps), len(non_joinable)))

        # Visualize first critical pair if any
        if cps:
            visualize_peak(cps[0], sys.name)

    # Summary table
    print(f"\n{'='*60}")
    print(f"  Summary")
    print(f"{'='*60}")
    print(f"  {'System':<15} {'CPs':>6} {'Non-join':>10} {'Status':>15}")
    print(f"  {'-'*50}")
    for name, n_cps, n_nj in all_results:
        status = "✓ Confluent" if n_nj == 0 else "✗ Non-confluent"
        print(f"  {name:<15} {n_cps:>6} {n_nj:>10} {status:>15}")

    # Conjecture testing
    print(f"\n{'='*60}")
    print(f"  Conjecture: Critical pair growth is at most quadratic")
    print(f"{'='*60}")
    sys = make_map_fusion_system()
    for N in [5, 10, 15, 20, 25, 30]:
        cps = enumerate_critical_pairs(sys, N)
        print(f"  N={N:3d}: {len(cps):4d} critical pairs (ratio N²={N*N})")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Critical Pair Growth Analysis

Visualizes how the number of critical pairs grows with the size bound N
for different benchmark rewrite systems. This illustrates the computational
tractability of the bounded completion approach.
"""

import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from typing import Optional
from enum import Enum, auto


# ============================================================================
# Inline term implementation (self-contained)
# ============================================================================

class TK(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()

@dataclass(frozen=True)
class T:
    kind: TK
    idx: int = 0
    l: Optional['T'] = None
    r: Optional['T'] = None
    b: Optional['T'] = None

    @staticmethod
    def v(i): return T(TK.VAR, idx=i)
    @staticmethod
    def a(s, t): return T(TK.APP, l=s, r=t)
    @staticmethod
    def la(body): return T(TK.LAM, b=body)

    def size(self):
        if self.kind == TK.VAR: return 1
        elif self.kind == TK.APP: return 1 + self.l.size() + self.r.size()
        else: return 1 + self.b.size()

    def subterms(self):
        result = [self]
        if self.kind == TK.APP:
            result.extend(self.l.subterms())
            result.extend(self.r.subterms())
        elif self.kind == TK.LAM:
            result.extend(self.b.subterms())
        return result

def syn_match(p, t):
    if p.kind == TK.VAR or t.kind == TK.VAR: return True
    if p.kind != t.kind: return False
    if p.kind == TK.APP: return syn_match(p.l, t.l) and syn_match(p.r, t.r)
    if p.kind == TK.LAM: return syn_match(p.b, t.b)
    return False

@dataclass
class Rule:
    name: str
    lhs: T
    rhs: T

@dataclass
class System:
    name: str
    rules: list

def count_cps(system, bound):
    count = 0
    for r1 in system.rules:
        for r2 in system.rules:
            for sub in r1.lhs.subterms():
                if syn_match(sub, r2.lhs) and r1.lhs.size() + r2.lhs.size() <= bound:
                    count += 1
    return count

# ============================================================================
# Benchmark systems
# ============================================================================

map_fusion_sys = System("Map Fusion + Id", [
    Rule("fusion", T.a(T.a(T.v(0), T.v(1)), T.a(T.a(T.v(0), T.v(2)), T.v(3))),
         T.a(T.a(T.v(0), T.la(T.a(T.v(2), T.a(T.v(3), T.v(0))))), T.v(3))),
    Rule("map-id", T.a(T.a(T.v(0), T.la(T.v(0))), T.v(1)), T.v(1))
])

fold_build_sys = System("Fold/Build", [
    Rule("fold-build",
         T.a(T.a(T.a(T.v(0), T.v(1)), T.v(2)), T.a(T.v(3), T.v(4))),
         T.a(T.a(T.v(4), T.v(1)), T.v(2)))
])

cps_sys = System("CPS Admin", [
    Rule("admin-beta", T.a(T.la(T.v(0)), T.v(1)), T.v(1))
])

# ============================================================================
# Generate data
# ============================================================================

bounds = list(range(3, 40))
systems = [map_fusion_sys, fold_build_sys, cps_sys]
colors = ['#2196F3', '#FF5722', '#4CAF50']
markers = ['o', 's', '^']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Critical pairs vs bound
for sys, color, marker in zip(systems, colors, markers):
    counts = [count_cps(sys, N) for N in bounds]
    ax1.plot(bounds, counts, color=color, marker=marker, markersize=4,
             linewidth=2, label=sys.name)

ax1.set_xlabel('Size Bound N', fontsize=12)
ax1.set_ylabel('Number of Critical Pairs', fontsize=12)
ax1.set_title('Critical Pair Growth vs Size Bound', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Ratio CPs / N
for sys, color, marker in zip(systems, colors, markers):
    counts = [count_cps(sys, N) for N in bounds]
    ratios = [c / N if N > 0 else 0 for c, N in zip(counts, bounds)]
    ax2.plot(bounds, ratios, color=color, marker=marker, markersize=4,
             linewidth=2, label=sys.name)

ax2.set_xlabel('Size Bound N', fontsize=12)
ax2.set_ylabel('CPs / N (normalized)', fontsize=12)
ax2.set_title('Critical Pair Density (CPs per unit bound)', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('critical_pairs_growth.png', dpi=150, bbox_inches='tight')
print("Saved: critical_pairs_growth.png")


#!/usr/bin/env python3
"""
Visualization: Peak and Join Diagrams

Visualizes the key concepts of rewriting theory:
- Local peaks (divergent rewrites from a common source)
- Joinability (convergence to a common target)
- The critical pair theorem structure
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_peak_join_diagram(ax, title, labels, joinable=True):
    """Draw a peak/join diamond diagram."""
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.8, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(title, fontsize=13, fontweight='bold', pad=15)

    # Node positions
    top = (0, 1.2)
    left = (-1, 0)
    right = (1, 0)
    bottom = (0, -1.2)

    node_color = '#E3F2FD'
    node_edge = '#1565C0'

    # Draw nodes
    for pos, label in [(top, labels[0]), (left, labels[1]),
                       (right, labels[2])]:
        circle = plt.Circle(pos, 0.3, facecolor=node_color,
                           edgecolor=node_edge, linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(pos[0], pos[1], label, ha='center', va='center',
                fontsize=11, fontweight='bold', zorder=4)

    # Draw arrows (top to left, top to right)
    arrow_props = dict(arrowstyle='->', color='#D32F2F', lw=2,
                      connectionstyle='arc3,rad=0.1')
    ax.annotate('', xy=(-0.75, 0.25), xytext=(-0.2, 0.95),
                arrowprops=arrow_props)
    ax.annotate('', xy=(0.75, 0.25), xytext=(0.2, 0.95),
                arrowprops=arrow_props)

    # Labels on arrows
    ax.text(-0.7, 0.75, 'r₁', fontsize=10, color='#D32F2F',
            fontweight='bold')
    ax.text(0.55, 0.75, 'r₂', fontsize=10, color='#D32F2F',
            fontweight='bold')

    if joinable:
        # Draw join arrows and bottom node
        circle = plt.Circle(bottom, 0.3, facecolor='#E8F5E9',
                           edgecolor='#2E7D32', linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(bottom[0], bottom[1], labels[3] if len(labels) > 3 else 'w',
                ha='center', va='center', fontsize=11, fontweight='bold',
                zorder=4)

        join_props = dict(arrowstyle='->', color='#2E7D32', lw=2,
                         connectionstyle='arc3,rad=0.1', linestyle='dashed')
        ax.annotate('', xy=(-0.2, -0.95), xytext=(-0.75, -0.25),
                    arrowprops=join_props)
        ax.annotate('', xy=(0.2, -0.95), xytext=(0.75, -0.25),
                    arrowprops=join_props)

        ax.text(-0.7, -0.65, '*', fontsize=14, color='#2E7D32',
                fontweight='bold')
        ax.text(0.55, -0.65, '*', fontsize=14, color='#2E7D32',
                fontweight='bold')

        ax.text(0, -1.7, '✓ Joinable', fontsize=11, ha='center',
                color='#2E7D32', fontweight='bold')
    else:
        ax.text(-1, -0.6, '?', fontsize=20, ha='center', color='#FF6F00')
        ax.text(1, -0.6, '?', fontsize=20, ha='center', color='#FF6F00')
        ax.text(0, -1.2, '✗ Non-joinable', fontsize=11, ha='center',
                color='#D32F2F', fontweight='bold')


fig, axes = plt.subplots(1, 3, figsize=(16, 6))

# Diagram 1: Disjoint peak (always joinable)
draw_peak_join_diagram(axes[0],
    'Disjoint Peak\n(Always Joinable)',
    ['f(s,t)', 'f(s\',t)', 'f(s,t\')', 'f(s\',t\')'],
    joinable=True)

# Diagram 2: Critical pair peak (joinable if CP joins)
draw_peak_join_diagram(axes[1],
    'Critical Pair Peak\n(Joinable iff CP Joins)',
    ['σ(l)', 'σ(r₁)', 'σ(r₂)', 'w'],
    joinable=True)

# Diagram 3: Non-confluent peak
draw_peak_join_diagram(axes[2],
    'Non-Confluent Peak\n(System Defect)',
    ['t', 'u', 'v'],
    joinable=False)

plt.suptitle('Peak Classification in Higher-Order Rewriting',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('peak_diagrams.png', dpi=150, bbox_inches='tight')
print("Saved: peak_diagrams.png")
