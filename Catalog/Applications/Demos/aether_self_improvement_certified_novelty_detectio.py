#!/usr/bin/env python3
"""
Applications of Certified Novelty Detection

Demonstrates real-world applications of the novelty certification framework:
1. Library deduplication
2. Research novelty assessment
3. AI-generated theorem audit
4. Novelty landscape visualization
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Dict, Optional


@dataclass(frozen=True)
class TheoremDescriptor:
    """Theorem descriptor matching the formal Lean structure."""
    arity: int
    symbol_count: int
    quantifier_depth: int
    dependency_count: int
    has_induction: bool
    has_contradiction: bool
    name: str = ""

    def to_vector(self) -> Tuple[float, ...]:
        return (
            float(self.arity),
            float(self.symbol_count),
            float(self.quantifier_depth),
            float(self.dependency_count),
            1.0 if self.has_induction else 0.0,
            1.0 if self.has_contradiction else 0.0,
        )


def dist(v1: Tuple[float, ...], v2: Tuple[float, ...]) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(v1, v2)))


def nearest_dist(x: TheoremDescriptor, catalog: List[TheoremDescriptor]) -> Tuple[float, Optional[TheoremDescriptor]]:
    best = float('inf')
    nearest = None
    for t in catalog:
        d = dist(x.to_vector(), t.to_vector())
        if d < best:
            best, nearest = d, t
    return best, nearest


# ============================================================
# Application 1: Library Deduplication
# ============================================================

def library_deduplication(library: List[TheoremDescriptor], delta: float) -> List[Tuple[TheoremDescriptor, TheoremDescriptor, float]]:
    """
    Find potential duplicate pairs in a theorem library.

    Returns pairs within distance delta (potential equivalences).
    """
    duplicates = []
    for i in range(len(library)):
        for j in range(i + 1, len(library)):
            d = dist(library[i].to_vector(), library[j].to_vector())
            if d <= delta:
                duplicates.append((library[i], library[j], d))
    return sorted(duplicates, key=lambda x: x[2])


# ============================================================
# Application 2: Research Novelty Assessment
# ============================================================

def assess_research_novelty(
    submissions: List[TheoremDescriptor],
    known_corpus: List[TheoremDescriptor],
    delta: float,
) -> List[Dict]:
    """
    Assess novelty of research submissions against a known corpus.

    Returns a report for each submission with novelty score,
    certification status, and nearest known result.
    """
    reports = []
    for sub in submissions:
        score, nearest = nearest_dist(sub, known_corpus)
        reports.append({
            'submission': sub.name,
            'novelty_score': score,
            'certified_novel': score > delta,
            'nearest_known': nearest.name if nearest else 'N/A',
            'distance_to_nearest': score,
            'margin': score - delta,
        })
    return reports


# ============================================================
# Application 3: AI-Generated Theorem Audit
# ============================================================

def audit_ai_theorems(
    ai_theorems: List[TheoremDescriptor],
    training_corpus: List[TheoremDescriptor],
    delta: float,
) -> Dict:
    """
    Audit AI-generated theorems for originality relative to training data.

    Returns statistics on how many AI theorems are certified novel
    vs. potentially derived from training data.
    """
    novel_count = 0
    suspicious_count = 0
    results = []

    for thm in ai_theorems:
        score, nearest = nearest_dist(thm, training_corpus)
        is_novel = score > delta
        if is_novel:
            novel_count += 1
        else:
            suspicious_count += 1
        results.append({
            'theorem': thm.name,
            'score': score,
            'novel': is_novel,
            'nearest_training': nearest.name if nearest else 'N/A',
        })

    return {
        'total': len(ai_theorems),
        'certified_novel': novel_count,
        'potentially_derived': suspicious_count,
        'novelty_rate': novel_count / len(ai_theorems) if ai_theorems else 0,
        'details': results,
    }


# ============================================================
# Demo
# ============================================================

def main():
    print("=" * 70)
    print("Applications of Certified Novelty Detection")
    print("=" * 70)

    # Build a realistic catalog
    corpus = [
        TheoremDescriptor(3, 12, 1, 3, False, False, "Pythagorean Theorem"),
        TheoremDescriptor(1, 18, 2, 5, False, True, "Infinitude of Primes"),
        TheoremDescriptor(3, 25, 2, 12, False, False, "Fund. Thm. of Calculus"),
        TheoremDescriptor(2, 15, 1, 6, True, False, "Fermat's Little Theorem"),
        TheoremDescriptor(3, 20, 1, 4, False, False, "Quadratic Formula"),
        TheoremDescriptor(1, 10, 1, 2, True, False, "Sum of first n integers"),
        TheoremDescriptor(2, 22, 2, 8, True, True, "Fund. Thm. of Arithmetic"),
        TheoremDescriptor(2, 14, 1, 3, False, False, "Triangle Inequality"),
        TheoremDescriptor(1, 8, 1, 1, True, False, "Factorial recursion"),
        TheoremDescriptor(3, 30, 3, 15, False, True, "Intermediate Value Thm."),
    ]

    delta = 5.0

    # Application 1: Library Deduplication
    print("\n" + "-" * 70)
    print("Application 1: Library Deduplication")
    print("-" * 70)
    dupes = library_deduplication(corpus, delta)
    if dupes:
        print(f"\n  Found {len(dupes)} potential duplicate pairs (dist ≤ {delta}):")
        for t1, t2, d in dupes:
            print(f"    {t1.name} ↔ {t2.name}: dist = {d:.2f}")
    else:
        print(f"\n  No duplicates found at δ = {delta}")

    # Application 2: Research Novelty
    print("\n" + "-" * 70)
    print("Application 2: Research Novelty Assessment")
    print("-" * 70)
    submissions = [
        TheoremDescriptor(4, 35, 3, 20, False, False, "Cauchy Residue Theorem"),
        TheoremDescriptor(2, 16, 1, 7, True, False, "Euler's Theorem"),
        TheoremDescriptor(5, 45, 4, 25, True, True, "Spectral Gap Theorem"),
        TheoremDescriptor(1, 9, 1, 2, True, False, "Fibonacci recurrence"),
    ]
    reports = assess_research_novelty(submissions, corpus, delta)
    for r in reports:
        status = "✓ NOVEL" if r['certified_novel'] else "✗ NOT CERTIFIED"
        print(f"\n  {r['submission']}:")
        print(f"    Score: {r['novelty_score']:.2f} (margin: {r['margin']:+.2f})")
        print(f"    Nearest: {r['nearest_known']}")
        print(f"    Status: {status}")

    # Application 3: AI Audit
    print("\n" + "-" * 70)
    print("Application 3: AI-Generated Theorem Audit")
    print("-" * 70)
    ai_theorems = [
        TheoremDescriptor(3, 13, 1, 3, False, False, "AI: Pythagorean variant"),
        TheoremDescriptor(6, 50, 5, 30, True, True, "AI: Novel deep result"),
        TheoremDescriptor(2, 15, 1, 6, True, False, "AI: Fermat rephrasing"),
        TheoremDescriptor(4, 28, 2, 10, False, True, "AI: Analytic continuation"),
        TheoremDescriptor(1, 11, 1, 2, True, False, "AI: Sum formula variant"),
    ]
    audit = audit_ai_theorems(ai_theorems, corpus, delta)
    print(f"\n  Total AI theorems: {audit['total']}")
    print(f"  Certified novel: {audit['certified_novel']}")
    print(f"  Potentially derived: {audit['potentially_derived']}")
    print(f"  Novelty rate: {audit['novelty_rate']:.0%}")
    for d in audit['details']:
        flag = "✓" if d['novel'] else "✗"
        print(f"    {flag} {d['theorem']}: score={d['score']:.2f}, nearest={d['nearest_training']}")

    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Certified Novelty Detection via Theorem Embedding Uniqueness — Demo

This script demonstrates the novelty certification framework with concrete
numerical examples, showing how theorem descriptors are embedded into metric
space and how novelty certificates are issued.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass(frozen=True)
class TheoremDescriptor:
    """A structured descriptor for a mathematical theorem."""
    name: str
    arity: int          # number of free variables
    symbol_count: int   # total symbol count
    quantifier_depth: int  # max quantifier nesting
    dependency_count: int  # imported lemma count
    has_induction: bool
    has_contradiction: bool

    def to_vector(self) -> Tuple[float, ...]:
        """Embed into 6-dimensional Euclidean space."""
        return (
            float(self.arity),
            float(self.symbol_count),
            float(self.quantifier_depth),
            float(self.dependency_count),
            1.0 if self.has_induction else 0.0,
            1.0 if self.has_contradiction else 0.0,
        )


def euclidean_dist(v1: Tuple[float, ...], v2: Tuple[float, ...]) -> float:
    """Compute Euclidean distance between two vectors."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(v1, v2)))


def nearest_dist(candidate: TheoremDescriptor,
                 catalog: List[TheoremDescriptor]) -> Tuple[float, Optional[TheoremDescriptor]]:
    """Compute nearest distance from candidate to catalog."""
    if not catalog:
        return float('inf'), None
    best_dist = float('inf')
    best_match = None
    for thm in catalog:
        d = euclidean_dist(candidate.to_vector(), thm.to_vector())
        if d < best_dist:
            best_dist = d
            best_match = thm
    return best_dist, best_match


def certify_novelty(candidate: TheoremDescriptor,
                    catalog: List[TheoremDescriptor],
                    delta: float) -> Tuple[bool, float, Optional[TheoremDescriptor]]:
    """
    Certify whether a candidate is novel w.r.t. the catalog.

    Returns (is_certified_novel, novelty_score, nearest_theorem).
    By Theorem 3.1, if novelty_score > delta, the candidate is
    provably not equivalent to any catalog theorem.
    """
    score, nearest = nearest_dist(candidate, catalog)
    return score > delta, score, nearest


def feature_gap_check(x: TheoremDescriptor,
                      y: TheoremDescriptor,
                      tolerances: dict) -> List[str]:
    """
    Check which features show a gap beyond tolerance.
    By Theorem 3.5, any single gap certifies non-equivalence.
    """
    gaps = []
    checks = [
        ('arity', abs(x.arity - y.arity), tolerances.get('arity', float('inf'))),
        ('symbol_count', abs(x.symbol_count - y.symbol_count),
         tolerances.get('symbol_count', float('inf'))),
        ('quantifier_depth', abs(x.quantifier_depth - y.quantifier_depth),
         tolerances.get('quantifier_depth', float('inf'))),
        ('dependency_count', abs(x.dependency_count - y.dependency_count),
         tolerances.get('dependency_count', float('inf'))),
    ]
    for name, diff, tol in checks:
        if diff > tol:
            gaps.append(f"{name}: |{diff}| > {tol}")
    return gaps


# ============================================================
# Demo: Catalog of elementary theorems
# ============================================================

def main():
    print("=" * 70)
    print("Certified Novelty Detection — Demonstration")
    print("=" * 70)

    # Build a catalog of well-known theorems
    catalog = [
        TheoremDescriptor(
            name="Pythagorean Theorem",
            arity=3, symbol_count=12, quantifier_depth=1,
            dependency_count=3, has_induction=False, has_contradiction=False
        ),
        TheoremDescriptor(
            name="Euclid's Infinitude of Primes",
            arity=1, symbol_count=18, quantifier_depth=2,
            dependency_count=5, has_induction=False, has_contradiction=True
        ),
        TheoremDescriptor(
            name="Fundamental Theorem of Calculus",
            arity=3, symbol_count=25, quantifier_depth=2,
            dependency_count=12, has_induction=False, has_contradiction=False
        ),
        TheoremDescriptor(
            name="Fermat's Little Theorem",
            arity=2, symbol_count=15, quantifier_depth=1,
            dependency_count=6, has_induction=True, has_contradiction=False
        ),
        TheoremDescriptor(
            name="Quadratic Formula",
            arity=3, symbol_count=20, quantifier_depth=1,
            dependency_count=4, has_induction=False, has_contradiction=False
        ),
    ]

    delta = 5.0  # Equivalence radius

    print(f"\nCatalog size: {len(catalog)}")
    print(f"Equivalence radius δ = {delta}")
    print()

    # --- Experiment 1: Test novelty of several candidates ---
    print("-" * 70)
    print("Experiment 1: Novelty Certification")
    print("-" * 70)

    candidates = [
        TheoremDescriptor(
            name="Cauchy's Residue Theorem (complex analysis)",
            arity=4, symbol_count=35, quantifier_depth=3,
            dependency_count=20, has_induction=False, has_contradiction=False
        ),
        TheoremDescriptor(
            name="Euler's Theorem (number theory, near Fermat)",
            arity=2, symbol_count=16, quantifier_depth=1,
            dependency_count=7, has_induction=True, has_contradiction=False
        ),
        TheoremDescriptor(
            name="Bolzano-Weierstrass Theorem",
            arity=2, symbol_count=22, quantifier_depth=3,
            dependency_count=8, has_induction=True, has_contradiction=True
        ),
        TheoremDescriptor(
            name="Trivial rephrasing of Pythagorean (same features)",
            arity=3, symbol_count=13, quantifier_depth=1,
            dependency_count=3, has_induction=False, has_contradiction=False
        ),
    ]

    for cand in candidates:
        is_novel, score, nearest = certify_novelty(cand, catalog, delta)
        status = "✓ CERTIFIED NOVEL" if is_novel else "✗ NOT CERTIFIED (too close)"
        print(f"\n  Candidate: {cand.name}")
        print(f"  Novelty score: {score:.2f}")
        print(f"  Nearest known: {nearest.name if nearest else 'N/A'}")
        print(f"  Status: {status}")

    # --- Experiment 2: Feature-gap analysis ---
    print()
    print("-" * 70)
    print("Experiment 2: Feature-Gap Analysis")
    print("-" * 70)

    tolerances = {'arity': 1, 'symbol_count': 5, 'quantifier_depth': 1, 'dependency_count': 3}

    x = candidates[0]  # Cauchy's Residue Theorem
    y = catalog[0]      # Pythagorean Theorem

    print(f"\n  Comparing: {x.name}")
    print(f"       with: {y.name}")
    print(f"  Tolerances: {tolerances}")
    gaps = feature_gap_check(x, y, tolerances)
    if gaps:
        print(f"  Certified non-equivalent via feature gaps:")
        for g in gaps:
            print(f"    • {g}")
    else:
        print(f"  No feature gap detected — cannot certify via this method.")

    # --- Experiment 3: Catalog growth dynamics ---
    print()
    print("-" * 70)
    print("Experiment 3: Catalog Growth Dynamics")
    print("-" * 70)

    test_candidate = candidates[2]  # Bolzano-Weierstrass
    print(f"\n  Tracking novelty score of: {test_candidate.name}")
    print(f"  as catalog grows from 1 to {len(catalog)} theorems:\n")

    for size in range(1, len(catalog) + 1):
        subcatalog = catalog[:size]
        score, nearest = nearest_dist(test_candidate, subcatalog)
        print(f"  Catalog size {size}: score = {score:.2f}"
              f"  (nearest: {nearest.name if nearest else 'N/A'})")

    print()
    print("  → Novelty score is monotonically non-increasing (Theorem 5.2)")

    # --- Summary ---
    print()
    print("=" * 70)
    print("Summary of Verified Theorems Used")
    print("=" * 70)
    print("""
  1. novelty_of_far_from_catalog     — Sound certification via metric separation
  2. novelty_of_nearestDist_gt       — Nearest-neighbor score certification
  3. exists_nearest_in_finset        — Finite minimizer existence
  4. not_equivalent_of_coordinate_gap — Single-feature obstruction
  5. not_equivalent_of_any_feature_gap — Multi-feature obstruction
  6. nearestDist_insert_le           — Monotonicity under catalog expansion
  7. nearestDist_nonneg              — Non-negativity of novelty score
    """)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Certified Novelty Detection

Generates publication-quality figures illustrating the key concepts.
"""

import math
import base64
import io
import json

# Use Agg backend for headless rendering
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def create_novelty_certification_diagram() -> str:
    """
    Figure 1: Novelty Certification in 2D Feature Space

    Shows catalog theorems as points with δ-balls, a novel candidate
    outside all balls, and a non-novel candidate inside a ball.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    catalog = [
        (2, 3, "Pythagorean\nTheorem"),
        (6, 7, "Euclid's\nPrimes"),
        (8, 2, "Fermat's\nLittle Thm"),
        (4, 8, "Fund. Thm.\nCalculus"),
        (9, 6, "Quadratic\nFormula"),
    ]

    delta = 1.5

    # Draw δ-balls
    for x, y, name in catalog:
        circle = plt.Circle((x, y), delta, color='lightblue', alpha=0.3, linewidth=2, edgecolor='steelblue')
        ax.add_patch(circle)
        ax.plot(x, y, 'o', color='steelblue', markersize=10, zorder=5)
        ax.annotate(name, (x, y), textcoords="offset points", xytext=(0, 18),
                    ha='center', fontsize=8, color='darkblue')

    # Novel candidate (far from all)
    nx, ny = 1, 9
    ax.plot(nx, ny, '*', color='green', markersize=20, zorder=5)
    ax.annotate("Novel\nCandidate ✓", (nx, ny), textcoords="offset points",
                xytext=(15, -10), ha='left', fontsize=10, color='green', fontweight='bold')

    # Non-novel candidate (inside a ball)
    nnx, nny = 2.5, 3.5
    ax.plot(nnx, nny, 'X', color='red', markersize=15, zorder=5)
    ax.annotate("Not Certified ✗", (nnx, nny), textcoords="offset points",
                xytext=(15, -15), ha='left', fontsize=10, color='red', fontweight='bold')

    # Draw distance line from novel to nearest
    nearest_x, nearest_y = 4, 8
    ax.annotate('', xy=(nx, ny), xytext=(nearest_x, nearest_y),
                arrowprops=dict(arrowstyle='<->', color='gray', lw=1.5, ls='--'))
    mid_x, mid_y = (nx + nearest_x) / 2, (ny + nearest_y) / 2
    ax.annotate(f'd > δ', (mid_x, mid_y), textcoords="offset points",
                xytext=(10, 5), ha='left', fontsize=10, color='gray')

    ax.set_xlim(-0.5, 11)
    ax.set_ylim(-0.5, 11)
    ax.set_xlabel("Feature 1 (e.g., Symbol Count)", fontsize=12)
    ax.set_ylabel("Feature 2 (e.g., Quantifier Depth)", fontsize=12)
    ax.set_title("Novelty Certification in Feature Space", fontsize=14, fontweight='bold')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='lightblue', edgecolor='steelblue', alpha=0.3,
                       label=f'Equivalence ball (radius δ = {delta})'),
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor='steelblue',
                   markersize=10, label='Catalog theorem'),
        plt.Line2D([0], [0], marker='*', color='w', markerfacecolor='green',
                   markersize=15, label='Certified novel'),
        plt.Line2D([0], [0], marker='X', color='w', markerfacecolor='red',
                   markersize=12, label='Not certified'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=10)

    return fig_to_base64(fig)


def create_novelty_score_decay() -> str:
    """
    Figure 2: Novelty Score vs. Catalog Size

    Shows how the novelty score monotonically decreases as the catalog grows.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Simulate catalog growth
    np.random.seed(42)
    catalog_points = np.random.randn(50, 6) * 5 + np.array([5, 20, 2, 8, 0.5, 0.5])
    candidate = np.array([10, 40, 4, 25, 0, 0])

    sizes = range(1, 51)
    scores = []
    for size in sizes:
        dists = [np.linalg.norm(candidate - catalog_points[i]) for i in range(size)]
        scores.append(min(dists))

    ax.plot(list(sizes), scores, 'b-', linewidth=2, label='Novelty score')
    ax.fill_between(list(sizes), scores, alpha=0.1, color='blue')

    # Mark delta threshold
    delta = 8.0
    ax.axhline(y=delta, color='red', linestyle='--', linewidth=1.5, label=f'δ = {delta} (threshold)')

    # Find transition point
    transition = None
    for i, s in enumerate(scores):
        if s <= delta:
            transition = i + 1
            break

    if transition:
        ax.axvline(x=transition, color='orange', linestyle=':', linewidth=1.5, alpha=0.7)
        ax.annotate(f'Certification lost\nat catalog size {transition}',
                    (transition, delta), textcoords="offset points",
                    xytext=(20, 20), ha='left', fontsize=10, color='orange',
                    arrowprops=dict(arrowstyle='->', color='orange'))

    ax.set_xlabel("Catalog Size |K|", fontsize=12)
    ax.set_ylabel("Novelty Score (nearest distance)", fontsize=12)
    ax.set_title("Novelty Score Monotonically Decreases with Catalog Growth\n(Theorem 5.2: nearestDist_insert_le)",
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def create_feature_gap_diagram() -> str:
    """
    Figure 3: Multi-Feature Obstruction

    Shows how gaps in individual feature dimensions certify non-equivalence.
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    features = ['Arity', 'Symbol Count', 'Quantifier Depth']
    x_vals = [3, 12, 1]
    y_vals = [6, 35, 4]
    tolerances = [1, 5, 1]
    gaps = [abs(x - y) for x, y in zip(x_vals, y_vals)]

    colors = ['#2ecc71' if g > t else '#e74c3c' for g, t in zip(gaps, tolerances)]

    for idx, (ax, feat, xv, yv, tol, gap, col) in enumerate(
            zip(axes, features, x_vals, y_vals, tolerances, gaps, colors)):
        bars = ax.bar(['Theorem A', 'Theorem B'], [xv, yv], color=['steelblue', 'coral'],
                      width=0.5, edgecolor='black', linewidth=0.5)

        # Draw tolerance band around Theorem A
        ax.axhspan(xv - tol, xv + tol, alpha=0.15, color='gray',
                   label=f'Tolerance band (±{tol})')

        # Annotate gap
        mid = (xv + yv) / 2
        ax.annotate('', xy=(1.3, xv), xytext=(1.3, yv),
                    arrowprops=dict(arrowstyle='<->', color=col, lw=2))
        ax.text(1.45, mid, f'Gap = {gap}', fontsize=10, color=col,
                fontweight='bold', va='center')

        cert = "✓ Certified" if gap > tol else "✗ Not certified"
        ax.set_title(f"{feat}\n{cert}", fontsize=12, fontweight='bold',
                     color='green' if gap > tol else 'red')
        ax.legend(fontsize=8, loc='upper left')
        ax.set_xlim(-0.5, 2)

    fig.suptitle("Multi-Feature Obstruction: Any Single Gap Certifies Non-Equivalence\n(Theorem 3.5)",
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


def create_coding_theory_analogy() -> str:
    """
    Figure 4: Coding Theory Analogy

    Shows the parallel between theorem catalogs and error-correcting codes.
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Theorem space
    ax1.set_title("Theorem Feature Space", fontsize=13, fontweight='bold')
    theorems = [(2, 3), (7, 7), (9, 2), (4, 9)]
    delta = 1.5

    for x, y in theorems:
        circle = plt.Circle((x, y), delta, color='lightblue', alpha=0.3,
                             edgecolor='steelblue', linewidth=2)
        ax1.add_patch(circle)
        ax1.plot(x, y, 'o', color='steelblue', markersize=12)

    ax1.plot(1, 8, '*', color='green', markersize=20)
    ax1.annotate("Novel theorem", (1, 8), textcoords="offset points",
                 xytext=(10, 10), fontsize=10, color='green')
    ax1.set_xlim(-0.5, 11)
    ax1.set_ylim(-0.5, 11)
    ax1.set_xlabel("Feature dimension 1", fontsize=11)
    ax1.set_ylabel("Feature dimension 2", fontsize=11)
    ax1.set_aspect('equal')
    ax1.grid(True, alpha=0.3)
    ax1.annotate("δ-balls = equivalence\nneighborhoods", (5, 0.5),
                 fontsize=10, ha='center', style='italic', color='gray')

    # Right: Code space
    ax2.set_title("Error-Correcting Code Space", fontsize=13, fontweight='bold')
    codewords = [(2, 3), (7, 7), (9, 2), (4, 9)]

    for x, y in codewords:
        circle = plt.Circle((x, y), delta, color='lightyellow', alpha=0.4,
                             edgecolor='goldenrod', linewidth=2)
        ax2.add_patch(circle)
        ax2.plot(x, y, 's', color='goldenrod', markersize=12)

    ax2.plot(1, 8, 'D', color='purple', markersize=12)
    ax2.annotate("Undecodable\nsignal", (1, 8), textcoords="offset points",
                 xytext=(10, 10), fontsize=10, color='purple')
    ax2.set_xlim(-0.5, 11)
    ax2.set_ylim(-0.5, 11)
    ax2.set_xlabel("Signal dimension 1", fontsize=11)
    ax2.set_ylabel("Signal dimension 2", fontsize=11)
    ax2.set_aspect('equal')
    ax2.grid(True, alpha=0.3)
    ax2.annotate("Decoding balls =\ncodeword neighborhoods", (5, 0.5),
                 fontsize=10, ha='center', style='italic', color='gray')

    fig.suptitle("Novelty Certification ≅ Minimum-Distance Decoding",
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    viz1 = create_novelty_certification_diagram()
    print(f"Figure 1: {len(viz1)} chars")

    viz2 = create_novelty_score_decay()
    print(f"Figure 2: {len(viz2)} chars")

    viz3 = create_feature_gap_diagram()
    print(f"Figure 3: {len(viz3)} chars")

    viz4 = create_coding_theory_analogy()
    print(f"Figure 4: {len(viz4)} chars")

    print("All visualizations generated successfully.")

    # Save individual PNGs
    for name, data_uri in [("fig1_novelty_space.png", viz1),
                           ("fig2_score_decay.png", viz2),
                           ("fig3_feature_gaps.png", viz3),
                           ("fig4_coding_analogy.png", viz4)]:
        b64_data = data_uri.split(",", 1)[1]
        with open(name, "wb") as f:
            f.write(base64.b64decode(b64_data))
        print(f"Saved {name}")
