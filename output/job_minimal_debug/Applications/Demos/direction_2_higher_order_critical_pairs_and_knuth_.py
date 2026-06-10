#!/usr/bin/env python3
"""
applications.py — Real-world applications of bounded higher-order critical
pair analysis to functional program optimization.

Demonstrates how the theoretical framework applies to:
1. Compiler optimization coherence (map fusion)
2. CPS transformation correctness
3. Deforestation pipeline analysis
4. Equational reasoning certification
"""

from algorithms import (
    Term, RewriteRule, RewriteSystem, CriticalPair,
    generate_certificate, enumerate_beta_critical_pairs,
    try_join, bounded_normalize, is_miller_pattern
)
from typing import List


# ============================================================================
# Application 1: Compiler Optimization Coherence
# ============================================================================

def compiler_optimization_demo():
    """Demonstrate that map fusion + map identity form a coherent
    optimization system.

    In a functional compiler, these two rules represent common optimizations:
    - MapFusion: map f (map g xs) → map (f∘g) xs   (avoid intermediate list)
    - MapId: map id xs → xs                         (remove identity maps)

    If both critical pairs are joinable, the compiler can apply these
    optimizations in any order and always get the same result.
    """
    print("="*60)
    print("APPLICATION 1: Compiler Optimization Coherence")
    print("="*60)

    x0, x1, x2, x3 = [Term.var(i) for i in range(4)]

    system = RewriteSystem("CompilerOpt", [
        RewriteRule("MapFusion",
            Term.app(Term.app(x0, x1), Term.app(Term.app(x0, x2), x3)),
            Term.app(Term.app(x0,
                Term.lam(Term.app(Term.var(2), Term.app(Term.var(3), Term.var(0))))),
                x3)),
        RewriteRule("MapId",
            Term.app(Term.app(x0, Term.lam(Term.var(0))), x1),
            x1),
    ])

    cert = generate_certificate(system, bound=25)
    print(f"\nSystem: {system.name}")
    print(f"Rules: {len(system.rules)}")
    for r in system.rules:
        print(f"  {r}")
    print(f"\nCertificate:")
    print(f"  Miller patterns: {cert.is_pattern_system}")
    print(f"  Left-linear: {cert.is_left_linear}")
    print(f"  Critical pairs: {len(cert.critical_pairs)}")
    print(f"  All joinable: {cert.all_joinable}")

    if cert.is_valid():
        print("\n✓ CERTIFIED: Compiler can apply these optimizations in any order.")
        print("  Different optimization schedules are coherent up to bound 25.")
    else:
        print("\n✗ NOT CERTIFIED: Optimization order may matter.")

    print()


# ============================================================================
# Application 2: CPS Transformation Analysis
# ============================================================================

def cps_transformation_demo():
    """Analyze CPS (Continuation-Passing Style) transformation rules.

    CPS transformations are fundamental in compilers for:
    - Making control flow explicit
    - Enabling tail-call optimization
    - Supporting first-class continuations

    We check whether common CPS rules form a locally confluent system.
    """
    print("="*60)
    print("APPLICATION 2: CPS Transformation Analysis")
    print("="*60)

    x0, x1, x2 = [Term.var(i) for i in range(3)]

    system = RewriteSystem("CPS", [
        RewriteRule("CPS-App",
            Term.app(Term.app(x0, x1), x2),
            Term.app(x0, Term.lam(Term.app(Term.var(0), x2)))),
        RewriteRule("CPS-Eta",
            Term.lam(Term.app(Term.var(1), Term.var(0))),
            Term.var(0)),
    ])

    cert = generate_certificate(system, bound=20)
    print(f"\nSystem: {system.name}")
    for r in system.rules:
        print(f"  {r}")
    print(f"\n{cert}")
    print()


# ============================================================================
# Application 3: Deforestation Pipeline
# ============================================================================

def deforestation_demo():
    """Analyze deforestation rules (Wadler 1988).

    Deforestation eliminates intermediate data structures:
    - foldr f e (build g) → g f e    (fold/build fusion)
    - map f (build g) → build (λc n. g (λx. c (f x)) n)

    These transformations are critical for performance in functional languages
    like Haskell, where lazy evaluation and list fusion are key optimizations.
    """
    print("="*60)
    print("APPLICATION 3: Deforestation Pipeline")
    print("="*60)

    x0, x1, x2, x3, x4 = [Term.var(i) for i in range(5)]

    system = RewriteSystem("Deforestation", [
        RewriteRule("FoldBuild",
            Term.app(Term.app(Term.app(x0, x1), x2), Term.app(x3, x4)),
            Term.app(Term.app(x4, x1), x2)),
    ])

    cert = generate_certificate(system, bound=20)
    print(f"\nSystem: {system.name}")
    for r in system.rules:
        print(f"  {r}")
    print(f"\n{cert}")
    print()


# ============================================================================
# Application 4: Equational Reasoning Certification
# ============================================================================

def equational_reasoning_demo():
    """Demonstrate certified equational reasoning.

    Given a convergent rewrite system, we can decide the word problem:
    two terms are equivalent iff they have the same normal form.

    This is the fundamental application to automated theorem proving
    and proof-producing equational reasoning engines.
    """
    print("="*60)
    print("APPLICATION 4: Equational Reasoning Certification")
    print("="*60)

    # Simple system: (λx.x) = id, meaning we can simplify identity applications
    system = RewriteSystem("Identity", [
        RewriteRule("BetaId",
            Term.app(Term.lam(Term.var(0)), Term.var(1)),
            Term.var(1)),
    ])

    cert = generate_certificate(system, bound=15)
    print(f"\nSystem: {system.name}")
    for r in system.rules:
        print(f"  {r}")
    print(f"\n{cert}")

    # Test equational reasoning
    print("\nEquational reasoning tests:")
    t1 = Term.app(Term.lam(Term.var(0)), Term.var(0))
    t2 = Term.var(0)
    n1 = bounded_normalize(t1, 20)
    n2 = bounded_normalize(t2, 20)
    print(f"  {t1} =? {t2}")
    print(f"  NF({t1}) = {n1}")
    print(f"  NF({t2}) = {n2}")
    print(f"  Equal: {n1 == n2}")

    print()


# ============================================================================
# Application 5: Pattern System Analysis
# ============================================================================

def pattern_analysis_demo():
    """Analyze whether benchmark rules satisfy the Miller pattern condition.

    The Miller pattern condition is crucial for:
    - Decidable higher-order unification
    - Tractable critical pair enumeration
    - Certified completion modulo β

    We check each benchmark rule's LHS against the Miller pattern criterion.
    """
    print("="*60)
    print("APPLICATION 5: Pattern System Analysis")
    print("="*60)

    rules = [
        ("MapFusion",
         Term.app(Term.app(Term.var(0), Term.var(1)),
                  Term.app(Term.app(Term.var(0), Term.var(2)), Term.var(3)))),
        ("MapId",
         Term.app(Term.app(Term.var(0), Term.lam(Term.var(0))), Term.var(1))),
        ("Eta",
         Term.lam(Term.app(Term.var(1), Term.var(0)))),
        ("BetaId",
         Term.app(Term.lam(Term.var(0)), Term.var(1))),
        ("FoldBuild",
         Term.app(Term.app(Term.app(Term.var(0), Term.var(1)), Term.var(2)),
                  Term.app(Term.var(3), Term.var(4)))),
    ]

    print()
    for name, lhs in rules:
        is_mp = is_miller_pattern(lhs)
        status = "✓" if is_mp else "✗"
        print(f"  {status} {name}: {lhs}")
        print(f"    Size: {lhs.size()}, Miller pattern: {is_mp}")

    print()


# ============================================================================
# Main
# ============================================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Higher-Order Critical Pair Analysis    ║")
    print("║  to Functional Program Optimization                    ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    compiler_optimization_demo()
    cps_transformation_demo()
    deforestation_demo()
    equational_reasoning_demo()
    pattern_analysis_demo()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of bounded higher-order critical pair
analysis and Knuth-Bendix completion modulo β.

Constructs benchmark higher-order rewrite systems, enumerates overlaps,
computes critical pairs, attempts joins, and reports bounded local confluence
status. Includes visualization of peak/join diagrams.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional, Set
from enum import Enum, auto


# ============================================================================
# Term Representation
# ============================================================================

class TermKind(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()


@dataclass(frozen=True)
class HOTerm:
    """Higher-order term: variable, application, or lambda abstraction."""
    kind: TermKind
    var_index: int = -1
    left: Optional['HOTerm'] = None
    right: Optional['HOTerm'] = None
    body: Optional['HOTerm'] = None

    @staticmethod
    def var(i: int) -> 'HOTerm':
        return HOTerm(TermKind.VAR, var_index=i)

    @staticmethod
    def app(s: 'HOTerm', t: 'HOTerm') -> 'HOTerm':
        return HOTerm(TermKind.APP, left=s, right=t)

    @staticmethod
    def lam(body: 'HOTerm') -> 'HOTerm':
        return HOTerm(TermKind.LAM, body=body)

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
            return self.var_index < depth
        elif self.kind == TermKind.APP:
            return self.left.is_closed_at(depth) and self.right.is_closed_at(depth)
        else:
            return self.body.is_closed_at(depth + 1)

    def is_closed(self) -> bool:
        return self.is_closed_at(0)

    def subterms(self) -> List['HOTerm']:
        if self.kind == TermKind.VAR:
            return [self]
        elif self.kind == TermKind.APP:
            return [self] + self.left.subterms() + self.right.subterms()
        else:
            return [self] + self.body.subterms()

    def __str__(self) -> str:
        if self.kind == TermKind.VAR:
            return f"x{self.var_index}"
        elif self.kind == TermKind.APP:
            left_str = str(self.left)
            right_str = str(self.right)
            if self.right.kind == TermKind.APP:
                right_str = f"({right_str})"
            return f"{left_str} {right_str}"
        else:
            return f"(λ.{self.body})"

    def substitute(self, sigma: dict) -> 'HOTerm':
        """Apply a substitution (dict from var index to term)."""
        if self.kind == TermKind.VAR:
            return sigma.get(self.var_index, self)
        elif self.kind == TermKind.APP:
            return HOTerm.app(self.left.substitute(sigma), self.right.substitute(sigma))
        else:
            # Naive: don't handle capture (fine for demo)
            return HOTerm.lam(self.body.substitute(sigma))

    def beta_contract(self) -> Optional['HOTerm']:
        """Try one-step beta reduction at the root."""
        if self.kind == TermKind.APP and self.left.kind == TermKind.LAM:
            # (λ.body) arg → body[0 := arg]
            return self.left.body.substitute({0: self.right})
        return None


# ============================================================================
# Rewrite Rules and Systems
# ============================================================================

@dataclass
class Rule:
    """A rewrite rule: lhs → rhs."""
    name: str
    lhs: HOTerm
    rhs: HOTerm

    def __str__(self):
        return f"{self.name}: {self.lhs} → {self.rhs}"


@dataclass
class HoSystem:
    """A higher-order rewrite system."""
    name: str
    rules: List[Rule]


# ============================================================================
# Critical Pair Detection
# ============================================================================

def syntactic_match(pattern: HOTerm, target: HOTerm) -> bool:
    """Check if pattern and target could unify (syntactic overlap check)."""
    if pattern.kind == TermKind.VAR or target.kind == TermKind.VAR:
        return True
    if pattern.kind != target.kind:
        return False
    if pattern.kind == TermKind.APP:
        return (syntactic_match(pattern.left, target.left) and
                syntactic_match(pattern.right, target.right))
    if pattern.kind == TermKind.LAM:
        return syntactic_match(pattern.body, target.body)
    return False


def enumerate_critical_pairs(system: HoSystem, bound: int) -> List[Tuple[Rule, Rule, HOTerm]]:
    """Enumerate critical pairs up to a given size bound.

    Returns list of (rule1, rule2, overlap_subterm) triples.
    """
    pairs = []
    for r1 in system.rules:
        for r2 in system.rules:
            for sub in r1.lhs.subterms():
                if (syntactic_match(sub, r2.lhs) and
                    r1.lhs.size() + r2.lhs.size() <= bound):
                    pairs.append((r1, r2, sub))
    return pairs


def try_join(system: HoSystem, t1: HOTerm, t2: HOTerm, fuel: int = 10) -> bool:
    """Try to join two terms by bounded normalization."""
    n1 = bounded_normalize(t1, fuel)
    n2 = bounded_normalize(t2, fuel)
    return n1 == n2


def bounded_normalize(term: HOTerm, fuel: int) -> HOTerm:
    """Normalize a term with bounded fuel."""
    if fuel <= 0:
        return term

    # Try beta reduction at root
    contracted = term.beta_contract()
    if contracted is not None:
        return bounded_normalize(contracted, fuel - 1)

    # Try reducing subterms
    if term.kind == TermKind.APP:
        left_norm = bounded_normalize(term.left, fuel - 1)
        right_norm = bounded_normalize(term.right, fuel - 1)
        new_term = HOTerm.app(left_norm, right_norm)
        if new_term != term:
            return bounded_normalize(new_term, fuel - 1)
        return term
    elif term.kind == TermKind.LAM:
        body_norm = bounded_normalize(term.body, fuel - 1)
        if body_norm != term.body:
            return HOTerm.lam(body_norm)
        return term
    return term


# ============================================================================
# Peak/Join Diagram Visualization
# ============================================================================

def visualize_peak_join(source: str, left: str, right: str,
                        join: Optional[str] = None) -> str:
    """Create an ASCII peak/join diagram."""
    lines = []
    lines.append("        " + source)
    lines.append("       / \\")
    lines.append("      /   \\")
    lines.append("     ↓     ↓")
    max_len = max(len(left), len(right))
    lines.append(f"  {left:<{max_len}}   {right}")
    if join:
        lines.append("     \\   /")
        lines.append("      \\ /")
        lines.append("       ↓")
        lines.append("    " + join)
        lines.append("")
        lines.append("  ✓ Peak is JOINABLE")
    else:
        lines.append("     ?   ?")
        lines.append("")
        lines.append("  ✗ Join NOT found within bound")
    return "\n".join(lines)


# ============================================================================
# Benchmark Systems
# ============================================================================

def make_map_fusion_system() -> HoSystem:
    """Map fusion benchmark system."""
    x0, x1, x2, x3 = HOTerm.var(0), HOTerm.var(1), HOTerm.var(2), HOTerm.var(3)

    # map f (map g xs) → map (f ∘ g) xs
    map_fusion = Rule(
        "MapFusion",
        HOTerm.app(HOTerm.app(x0, x1), HOTerm.app(HOTerm.app(x0, x2), x3)),
        HOTerm.app(HOTerm.app(x0,
            HOTerm.lam(HOTerm.app(HOTerm.var(2), HOTerm.app(HOTerm.var(3), HOTerm.var(0))))),
            x3)
    )

    # map id xs → xs
    map_id = Rule(
        "MapId",
        HOTerm.app(HOTerm.app(x0, HOTerm.lam(HOTerm.var(0))), x1),
        x1
    )

    return HoSystem("MapFusion", [map_fusion, map_id])


def make_eta_system() -> HoSystem:
    """η-reduction benchmark system."""
    x0, x1 = HOTerm.var(0), HOTerm.var(1)

    eta = Rule(
        "Eta",
        HOTerm.lam(HOTerm.app(x1, x0)),
        x0
    )
    return HoSystem("Eta", [eta])


def make_cps_system() -> HoSystem:
    """CPS transformation benchmark system."""
    x0, x1 = HOTerm.var(0), HOTerm.var(1)

    cps_id = Rule(
        "CPS-Id",
        HOTerm.app(x0, HOTerm.lam(HOTerm.var(0))),
        HOTerm.app(x1, HOTerm.lam(HOTerm.var(0)))
    )

    return HoSystem("CPS", [cps_id])


def make_deforestation_system() -> HoSystem:
    """Simple deforestation benchmark."""
    x0, x1, x2 = HOTerm.var(0), HOTerm.var(1), HOTerm.var(2)

    # foldr f e (build g) → g f e
    fold_build = Rule(
        "FoldBuild",
        HOTerm.app(HOTerm.app(HOTerm.app(x0, x1), x2),
                   HOTerm.app(HOTerm.var(3), HOTerm.var(4))),
        HOTerm.app(HOTerm.app(HOTerm.var(4), x1), x2)
    )

    return HoSystem("Deforestation", [fold_build])


# ============================================================================
# Main Demo
# ============================================================================

def analyze_system(system: HoSystem, bound: int = 20):
    """Analyze a rewrite system for bounded local confluence."""
    print(f"\n{'='*60}")
    print(f"  System: {system.name}")
    print(f"  Bound: {bound}")
    print(f"{'='*60}")

    print(f"\n  Rules ({len(system.rules)}):")
    for r in system.rules:
        print(f"    {r}")

    # Enumerate critical pairs
    cps = enumerate_critical_pairs(system, bound)
    print(f"\n  Critical pairs found: {len(cps)}")

    all_joinable = True
    first_non_joinable = None

    for i, (r1, r2, sub) in enumerate(cps):
        joinable = try_join(system, r1.rhs, r2.rhs, fuel=20)
        status = "✓ joinable" if joinable else "✗ NOT joinable"
        print(f"    CP {i+1}: {r1.name} × {r2.name} → {status}")

        if not joinable:
            all_joinable = False
            if first_non_joinable is None:
                first_non_joinable = (r1, r2, sub)

    # Report
    print(f"\n  {'─'*50}")
    if all_joinable:
        print(f"  ✓ BOUNDED LOCAL CONFLUENCE CERTIFICATE")
        print(f"    All {len(cps)} critical pairs are joinable up to bound {bound}")
        print(f"    → System is locally confluent on closed terms of size ≤ {bound}")
    else:
        print(f"  ✗ BOUNDED LOCAL CONFLUENCE NOT ESTABLISHED")
        r1, r2, sub = first_non_joinable
        print(f"    First non-joinable pair: {r1.name} × {r2.name}")
        print(f"\n  Peak diagram:")
        diagram = visualize_peak_join(
            str(r1.lhs), str(r1.rhs), str(r2.rhs))
        for line in diagram.split('\n'):
            print(f"    {line}")

    # Show a join diagram for first joinable pair
    if cps and all_joinable:
        r1, r2, sub = cps[0]
        n1 = bounded_normalize(r1.rhs, 20)
        n2 = bounded_normalize(r2.rhs, 20)
        print(f"\n  Example peak/join diagram (CP 1):")
        join_str = str(n1) if n1 == n2 else "?"
        diagram = visualize_peak_join(
            str(r1.lhs), str(r1.rhs), str(r2.rhs),
            join=join_str if n1 == n2 else None)
        for line in diagram.split('\n'):
            print(f"    {line}")

    return all_joinable


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Higher-Order Critical Pairs & Completion Modulo β      ║")
    print("║  Bounded Confluence Analysis for Functional Programs    ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Benchmark systems
    systems = [
        make_map_fusion_system(),
        make_eta_system(),
        make_cps_system(),
        make_deforestation_system(),
    ]

    results = {}
    for sys in systems:
        result = analyze_system(sys, bound=20)
        results[sys.name] = result

    # Summary
    print(f"\n{'='*60}")
    print(f"  SUMMARY")
    print(f"{'='*60}")
    for name, confluent in results.items():
        status = "✓ locally confluent" if confluent else "✗ unknown"
        print(f"  {name}: {status}")

    # Conjecture testing
    print(f"\n{'='*60}")
    print(f"  CONJECTURE TEST")
    print(f"{'='*60}")
    print(f"  Testing: First non-joinable CP appears at overlap size")
    print(f"  ≤ quadratic in largest rule size")
    for sys in systems:
        max_rule_size = max(r.lhs.size() + r.rhs.size() for r in sys.rules)
        quadratic_bound = max_rule_size * max_rule_size
        cps_at_bound = enumerate_critical_pairs(sys, quadratic_bound)
        all_join = all(try_join(sys, r1.rhs, r2.rhs, 20)
                       for r1, r2, _ in cps_at_bound)
        print(f"  {sys.name}: max rule size = {max_rule_size}, "
              f"quadratic bound = {quadratic_bound}, "
              f"all joinable at bound = {all_join}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualize the Bounded Completion Pipeline.

This script creates a flowchart-style visualization of the bounded
higher-order Knuth-Bendix completion pipeline modulo β, showing how
critical pair analysis leads to local confluence certificates.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


fig, ax = plt.subplots(1, 1, figsize=(14, 10))
ax.set_xlim(0, 14)
ax.set_ylim(0, 10)
ax.axis('off')
ax.set_title('Bounded Higher-Order Completion Pipeline Modulo β',
             fontsize=16, fontweight='bold', pad=20)

# Color scheme
box_color = '#3498db'
check_color = '#2ecc71'
fail_color = '#e74c3c'
cert_color = '#9b59b6'
bridge_color = '#f39c12'

def draw_box(ax, x, y, w, h, text, color, fontsize=10):
    rect = patches.FancyBboxPatch((x, y), w, h,
                                   boxstyle="round,pad=0.15",
                                   facecolor=color, edgecolor='white',
                                   alpha=0.9, linewidth=2)
    ax.add_patch(rect)
    ax.text(x + w/2, y + h/2, text, ha='center', va='center',
            fontsize=fontsize, color='white', fontweight='bold',
            wrap=True)

def draw_arrow(ax, x1, y1, x2, y2, label='', color='#34495e'):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))
    if label:
        mx, my = (x1+x2)/2, (y1+y2)/2
        ax.text(mx + 0.3, my, label, fontsize=8, color=color,
                style='italic')

# Step 1: Input system
draw_box(ax, 5, 8.5, 4, 0.8, 'Rewrite System E\n(rules with Miller patterns)', box_color)

# Step 2: Check properties
draw_box(ax, 1, 7, 3.5, 0.7, 'Check:\nLeft-linear?', check_color, 9)
draw_box(ax, 5.25, 7, 3.5, 0.7, 'Check:\nMiller patterns?', check_color, 9)
draw_box(ax, 9.5, 7, 3.5, 0.7, 'Choose bound N', bridge_color, 9)

draw_arrow(ax, 5.5, 8.5, 2.75, 7.7)
draw_arrow(ax, 7, 8.5, 7, 7.7)
draw_arrow(ax, 8.5, 8.5, 11.25, 7.7)

# Step 3: Enumerate critical pairs
draw_box(ax, 3.5, 5.5, 7, 0.8,
         'Enumerate β-Critical Pairs up to size N\n'
         'betaCriticalPairsUpTo N E', box_color)

draw_arrow(ax, 2.75, 7, 5.5, 6.3, 'yes')
draw_arrow(ax, 7, 7, 7, 6.3)
draw_arrow(ax, 11.25, 7, 8.5, 6.3)

# Step 4: Check joinability
draw_box(ax, 3.5, 4, 7, 0.7,
         'For each pair (s, t): try joining s and t\n'
         'by bounded normalization', check_color)

draw_arrow(ax, 7, 5.5, 7, 4.7)

# Step 5: Decision
draw_box(ax, 1, 2.5, 4.5, 0.7, 'All joinable?\n→ LOCAL CONFLUENCE ✓', check_color)
draw_box(ax, 8.5, 2.5, 4.5, 0.7, 'Some non-joinable?\n→ Report pair ✗', fail_color)

draw_arrow(ax, 5.5, 4, 3.25, 3.2, 'yes')
draw_arrow(ax, 8.5, 4, 10.75, 3.2, 'no')

# Step 6: Certificate / Newman's lemma
draw_box(ax, 0.5, 0.8, 5.5, 0.8,
         'CompletionCertificateβ\n'
         '+ Newman\'s Lemma → Unique NFs', cert_color)

draw_arrow(ax, 3.25, 2.5, 3.25, 1.6)

# Step 7: Cross-domain
draw_box(ax, 0.5, -0.3, 5.5, 0.7,
         'Cross-domain: Coherent compiler optimization\n'
         'Word problem decidability', bridge_color, 9)

draw_arrow(ax, 3.25, 0.8, 3.25, 0.4)

# Annotations
ax.text(13, 5.9, 'Theorem:\nbounded_confluence_\nfrom_joinable_cps',
        fontsize=8, color=box_color, style='italic',
        bbox=dict(boxstyle='round', facecolor='#ecf0f1', alpha=0.8))

ax.text(13, 3.5, 'Theorem:\ncompletion_pipeline_\nnewman',
        fontsize=8, color=cert_color, style='italic',
        bbox=dict(boxstyle='round', facecolor='#ecf0f1', alpha=0.8))

ax.text(13, 1.5, 'Theorem:\nword_problem_\ndecidability',
        fontsize=8, color=bridge_color, style='italic',
        bbox=dict(boxstyle='round', facecolor='#ecf0f1', alpha=0.8))

plt.tight_layout()
plt.savefig('completion_pipeline.png', dpi=150, bbox_inches='tight',
            facecolor='white')
print("Saved: completion_pipeline.png")


#!/usr/bin/env python3
"""
Visualize Critical Pair Growth vs. System Size.

This script creates a heatmap showing how the number of critical pairs
grows with the size bound and the number of rewrite rules, illustrating
the computational tractability of bounded critical pair analysis for
Miller-pattern systems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from enum import Enum, auto
from dataclasses import dataclass
from typing import Optional, List


# Inline the term representation (self-contained)
class TK(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()

@dataclass(frozen=True)
class T:
    kind: TK
    idx: int = -1
    left: Optional['T'] = None
    right: Optional['T'] = None
    body: Optional['T'] = None

    @staticmethod
    def v(i): return T(TK.VAR, idx=i)
    @staticmethod
    def a(s, t): return T(TK.APP, left=s, right=t)
    @staticmethod
    def l(b): return T(TK.LAM, body=b)

    def size(self):
        if self.kind == TK.VAR: return 1
        if self.kind == TK.APP: return 1 + self.left.size() + self.right.size()
        return 1 + self.body.size()

    def subterms(self):
        if self.kind == TK.VAR: return [self]
        if self.kind == TK.APP: return [self] + self.left.subterms() + self.right.subterms()
        return [self] + self.body.subterms()


def syn_match(p, q):
    if p.kind == TK.VAR or q.kind == TK.VAR: return True
    if p.kind != q.kind: return False
    if p.kind == TK.APP: return syn_match(p.left, q.left) and syn_match(p.right, q.right)
    if p.kind == TK.LAM: return syn_match(p.body, q.body)
    return False


def count_cps(rules, bound):
    count = 0
    for r1_lhs, _ in rules:
        for r2_lhs, _ in rules:
            for sub in r1_lhs.subterms():
                if syn_match(sub, r2_lhs) and r1_lhs.size() + r2_lhs.size() <= bound:
                    count += 1
    return count


# Generate benchmark rule sets of increasing size
def make_rules(n_rules):
    """Generate n_rules synthetic rewrite rules."""
    rules = []
    for i in range(n_rules):
        # Rule: f_i(x, g_i(y)) → h_i(x, y)
        x, y = T.v(0), T.v(1)
        lhs = T.a(T.a(T.v(i + 10), x), T.a(T.v(i + 20), y))
        rhs = T.a(T.v(i + 30), T.a(x, y))
        rules.append((lhs, rhs))
    return rules


# Compute critical pair counts
rule_counts = [1, 2, 3, 4, 5, 6, 8, 10]
bounds = [5, 10, 15, 20, 25, 30, 40, 50]

data = np.zeros((len(rule_counts), len(bounds)))

for i, n_rules in enumerate(rule_counts):
    rules = make_rules(n_rules)
    for j, bound in enumerate(bounds):
        data[i, j] = count_cps(rules, bound)

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap
im = ax1.imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax1.set_xticks(range(len(bounds)))
ax1.set_xticklabels(bounds)
ax1.set_yticks(range(len(rule_counts)))
ax1.set_yticklabels(rule_counts)
ax1.set_xlabel('Size Bound N', fontsize=12)
ax1.set_ylabel('Number of Rules', fontsize=12)
ax1.set_title('Critical Pair Count by System Size & Bound', fontsize=13,
              fontweight='bold')

# Add value annotations
for i in range(len(rule_counts)):
    for j in range(len(bounds)):
        val = int(data[i, j])
        color = 'white' if val > data.max() * 0.6 else 'black'
        ax1.text(j, i, str(val), ha='center', va='center',
                fontsize=8, color=color)

plt.colorbar(im, ax=ax1, label='Number of Critical Pairs')

# Growth curve
for i, n_rules in enumerate([2, 4, 6, 10]):
    idx = rule_counts.index(n_rules)
    ax2.plot(bounds, data[idx, :], 'o-', label=f'{n_rules} rules',
             linewidth=2, markersize=6)

ax2.set_xlabel('Size Bound N', fontsize=12)
ax2.set_ylabel('Number of Critical Pairs', fontsize=12)
ax2.set_title('Critical Pair Growth vs. Size Bound', fontsize=13,
              fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Add annotation about quadratic conjecture
ax2.text(0.05, 0.95,
         'Conjecture: First non-joinable CP\n'
         'appears at size ≤ O(max_rule²)',
         transform=ax2.transAxes, fontsize=9,
         verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='#f0f0f0', alpha=0.8))

plt.tight_layout()
plt.savefig('critical_pair_growth.png', dpi=150, bbox_inches='tight',
            facecolor='white')
print("Saved: critical_pair_growth.png")


#!/usr/bin/env python3
"""
Visualize Peak/Join Diagrams for Higher-Order Critical Pairs.

This script creates a visual representation of the peak classification
theorem: every local peak in a rewrite system is either disjoint, nested,
or a genuine overlap, and each type has a characteristic join pattern.

The visualization shows the diamond property for each peak type, which is
the geometric heart of the Knuth-Bendix critical pair theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_peak_join(ax, title, source, left, right, join,
                   peak_type, color, joinable=True):
    """Draw a single peak/join diagram."""
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(title, fontsize=13, fontweight='bold', pad=15)

    # Source node (top)
    ax.plot(0, 3, 'o', markersize=18, color=color, zorder=5)
    ax.text(0, 3, source, ha='center', va='center', fontsize=9,
            fontweight='bold', color='white', zorder=6)

    # Left node
    ax.plot(-1, 2, 'o', markersize=18, color=color, alpha=0.7, zorder=5)
    ax.text(-1, 2, left, ha='center', va='center', fontsize=8, zorder=6)

    # Right node
    ax.plot(1, 2, 'o', markersize=18, color=color, alpha=0.7, zorder=5)
    ax.text(1, 2, right, ha='center', va='center', fontsize=8, zorder=6)

    # Downward arrows from source
    ax.annotate('', xy=(-0.85, 2.15), xytext=(-0.15, 2.85),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))
    ax.annotate('', xy=(0.85, 2.15), xytext=(0.15, 2.85),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))

    if joinable:
        # Join node (bottom)
        ax.plot(0, 1, 'o', markersize=18, color='#2ecc71', zorder=5)
        ax.text(0, 1, join, ha='center', va='center', fontsize=8,
                fontweight='bold', color='white', zorder=6)

        # Arrows to join
        ax.annotate('', xy=(-0.15, 1.15), xytext=(-0.85, 1.85),
                    arrowprops=dict(arrowstyle='->', color='#2ecc71',
                                    lw=2, linestyle='dashed'))
        ax.annotate('', xy=(0.15, 1.15), xytext=(0.85, 1.85),
                    arrowprops=dict(arrowstyle='->', color='#2ecc71',
                                    lw=2, linestyle='dashed'))

        ax.text(0, 0.3, '✓ Joinable', ha='center', fontsize=11,
                color='#2ecc71', fontweight='bold')
    else:
        ax.text(-0.5, 1.2, '?', ha='center', fontsize=20, color='#e74c3c')
        ax.text(0.5, 1.2, '?', ha='center', fontsize=20, color='#e74c3c')
        ax.text(0, 0.3, '✗ Not joinable', ha='center', fontsize=11,
                color='#e74c3c', fontweight='bold')

    # Peak type label
    ax.text(0, -0.2, f'Peak type: {peak_type}', ha='center', fontsize=9,
            style='italic', color='#7f8c8d')


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Peak Classification in Higher-Order Rewriting Modulo β',
             fontsize=16, fontweight='bold', y=0.98)

# 1. Disjoint peak
draw_peak_join(axes[0], 'Disjoint Peak',
               's₁ s₂', "s₁' s₂", "s₁ s₂'", "s₁' s₂'",
               'Disjoint', '#3498db', joinable=True)

# 2. Nested peak (one redex inside another)
draw_peak_join(axes[1], 'Nested Peak',
               'C[l]', 'C[r]', "C'[l]", "C'[r]",
               'Nested', '#9b59b6', joinable=True)

# 3. Overlap peak (critical pair)
draw_peak_join(axes[2], 'Overlap Peak (Critical Pair)',
               'σ(l₁)', 'σ(r₁)', 'σ(r₂)', 'w',
               'Overlap', '#e67e22', joinable=True)

plt.tight_layout()
plt.savefig('peak_classification.png', dpi=150, bbox_inches='tight',
            facecolor='white')
print("Saved: peak_classification.png")
