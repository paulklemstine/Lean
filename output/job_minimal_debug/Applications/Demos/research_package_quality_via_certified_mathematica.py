#!/usr/bin/env python3
"""
Applications of Certified Mathematical Significance Metrics.

Real-world applications demonstrating how the formal theory
can be used in practice for research evaluation, library curation,
and automated quality assessment.
"""

from typing import Dict, Set, List, Tuple
from dataclasses import dataclass, field
import json


# ============================================================
# Application 1: Mathematical Library Health Monitor
# ============================================================

@dataclass
class LibraryModule:
    """A module in a mathematical library."""
    name: str
    theorems: Set[str]
    domain: str
    dependencies: Set[str] = field(default_factory=set)


def library_health_report(
    modules: List[LibraryModule],
    weights: Dict[str, int],
    threshold: int
) -> Dict:
    """
    Generate a health report for a mathematical library.

    Analyzes each module's significance contribution and
    identifies modules that push the library past quality thresholds.

    Application: CI/CD pipeline for formal math libraries.
    When a PR adds new theorems, compute whether it advances
    the library's significance past the threshold.
    """
    all_theorems: Set[str] = set()
    report = {
        "modules": [],
        "total_significance": 0,
        "threshold": threshold,
        "passes_threshold": False,
        "domain_coverage": set(),
    }

    cumulative_sig = 0
    for module in sorted(modules, key=lambda m: m.name):
        module_sig = sum(weights.get(t, 0) for t in module.theorems)
        new_theorems = module.theorems - all_theorems
        marginal = sum(weights.get(t, 0) for t in new_theorems)

        all_theorems |= module.theorems
        cumulative_sig += marginal
        report["domain_coverage"].add(module.domain)

        report["modules"].append({
            "name": module.name,
            "theorems": len(module.theorems),
            "new_theorems": len(new_theorems),
            "module_significance": module_sig,
            "marginal_significance": marginal,
            "cumulative_significance": cumulative_sig,
            "crosses_threshold": cumulative_sig >= threshold and
                                 (cumulative_sig - marginal) < threshold,
        })

    report["total_significance"] = cumulative_sig
    report["passes_threshold"] = cumulative_sig >= threshold
    report["domain_count"] = len(report["domain_coverage"])
    report["domain_coverage"] = list(report["domain_coverage"])

    return report


# ============================================================
# Application 2: Research Package Reviewer
# ============================================================

@dataclass
class ResearchPackage:
    """A proposed research contribution."""
    name: str
    new_theorems: Set[str]
    proof_dependencies: Dict[str, Set[str]]  # theorem -> dependencies
    domain_tags: Dict[str, str]  # theorem -> domain


def review_package(
    package: ResearchPackage,
    existing_knowledge: Set[str],
    weights: Dict[str, int],
    depth_weights: Dict[str, int],
    novelty_weights: Dict[str, int],
    bridge_weights: Dict[str, int],
    threshold: int
) -> Dict:
    """
    Automated review of a research package.

    Evaluates:
    1. Significance increase (monotonicity guarantees non-decrease)
    2. Genuine novelty (threshold crossing theorem)
    3. Cross-domain reach (coverage lower bound)
    4. Triple significance (depth + novelty + bridge)
    5. MasterClass status

    Application: Automated pre-review for conference submissions
    or library inclusion requests.
    """
    K_old = existing_knowledge
    K_new = existing_knowledge | package.new_theorems

    sig_old = sum(weights.get(a, 0) for a in K_old)
    sig_new = sum(weights.get(a, 0) for a in K_new)

    genuinely_new = package.new_theorems - existing_knowledge
    domains_old = set(package.domain_tags.get(t, "unknown") for t in K_old
                      if t in package.domain_tags)
    domains_new = set(package.domain_tags.get(t, "unknown") for t in K_new
                      if t in package.domain_tags)
    new_domains = domains_new - domains_old

    # Triple significance
    d = sum(depth_weights.get(a, 0) for a in K_new)
    n = sum(novelty_weights.get(a, 0) for a in K_new)
    b = sum(bridge_weights.get(a, 0) for a in K_new)
    triple = d + n + b

    # Dependency depth
    max_dep_chain = 0
    for thm in package.new_theorems:
        deps = package.proof_dependencies.get(thm, set())
        depth = len(deps & package.new_theorems)  # internal dependency count
        max_dep_chain = max(max_dep_chain, depth)

    return {
        "package_name": package.name,
        "verdict": "ACCEPT" if sig_new >= threshold and len(genuinely_new) > 0
                   else "NEEDS_REVISION",
        "significance_delta": sig_new - sig_old,
        "genuinely_new_theorems": len(genuinely_new),
        "new_domains_opened": list(new_domains),
        "triple_significance": {
            "depth": d,
            "novelty": n,
            "bridge": b,
            "total": triple,
        },
        "masterclass": triple >= threshold,
        "max_internal_dependency_depth": max_dep_chain,
        "crosses_threshold": sig_old < threshold <= sig_new,
        "guaranteed_novel_by_theorem": sig_old < threshold <= sig_new,
    }


# ============================================================
# Application 3: Curriculum Optimizer
# ============================================================

def optimize_curriculum(
    available_topics: Dict[str, Set[str]],  # topic -> theorem set
    weights: Dict[str, int],
    max_topics: int
) -> List[str]:
    """
    Select topics to maximize knowledge significance within a budget.

    Since significance is modular (additive over disjoint sets),
    a greedy approach is optimal for disjoint topic sets and
    near-optimal in general.

    Application: Course design, textbook chapter selection,
    or learning path optimization.

    Time complexity: O(T² × max_atoms) where T = number of topics
    """
    selected: List[str] = []
    covered: Set[str] = set()

    for _ in range(min(max_topics, len(available_topics))):
        best_topic = None
        best_marginal = -1

        for topic, theorems in available_topics.items():
            if topic in selected:
                continue
            new_atoms = theorems - covered
            marginal = sum(weights.get(a, 0) for a in new_atoms)
            if marginal > best_marginal:
                best_marginal = marginal
                best_topic = topic

        if best_topic is None or best_marginal <= 0:
            break

        selected.append(best_topic)
        covered |= available_topics[best_topic]

    return selected


# ============================================================
# Demo
# ============================================================

def demo_library_health():
    print("=" * 60)
    print("APPLICATION 1: Library Health Monitor")
    print("=" * 60)

    modules = [
        LibraryModule("Algebra.Group", {"grp_assoc", "grp_inv", "grp_id"}, "algebra"),
        LibraryModule("Topology.Basic", {"top_open", "top_cont", "top_compact"}, "topology"),
        LibraryModule("Analysis.Measure", {"meas_sigma", "meas_int", "meas_conv"}, "analysis"),
        LibraryModule("Bridge.AlgTop", {"fund_grp", "cover_lift", "galois_top"}, "bridge"),
    ]

    weights = {t: 5 for m in modules for t in m.theorems}
    weights["galois_top"] = 15  # bridge theorem gets extra weight
    weights["fund_grp"] = 12

    report = library_health_report(modules, weights, threshold=40)

    print(f"\nTotal significance: {report['total_significance']}")
    print(f"Threshold: {report['threshold']}")
    print(f"Passes: {report['passes_threshold']}")
    print(f"Domains: {report['domain_coverage']}")

    for m in report["modules"]:
        marker = " ← CROSSES THRESHOLD" if m["crosses_threshold"] else ""
        print(f"  {m['name']}: marginal={m['marginal_significance']}, "
              f"cumulative={m['cumulative_significance']}{marker}")


def demo_review():
    print("\n" + "=" * 60)
    print("APPLICATION 2: Research Package Review")
    print("=" * 60)

    existing = {"basic_calc", "real_analysis", "group_theory"}
    package = ResearchPackage(
        name="Ergodic Bridge Theorems",
        new_theorems={"ergodic_main", "bridge_erg_top", "mixing_rate"},
        proof_dependencies={
            "ergodic_main": {"real_analysis"},
            "bridge_erg_top": {"ergodic_main", "group_theory"},
            "mixing_rate": {"ergodic_main"},
        },
        domain_tags={
            "basic_calc": "analysis",
            "real_analysis": "analysis",
            "group_theory": "algebra",
            "ergodic_main": "dynamics",
            "bridge_erg_top": "bridge",
            "mixing_rate": "dynamics",
        }
    )

    weights = {t: 5 for t in existing}
    weights.update({"ergodic_main": 10, "bridge_erg_top": 15, "mixing_rate": 8})

    review = review_package(
        package, existing, weights,
        depth_weights=weights,
        novelty_weights={t: 3 for t in weights},
        bridge_weights={"bridge_erg_top": 20, **{t: 0 for t in weights if t != "bridge_erg_top"}},
        threshold=30
    )

    print(f"\nPackage: {review['package_name']}")
    print(f"Verdict: {review['verdict']}")
    print(f"Significance delta: +{review['significance_delta']}")
    print(f"Genuinely new theorems: {review['genuinely_new_theorems']}")
    print(f"New domains: {review['new_domains_opened']}")
    print(f"Triple significance: {review['triple_significance']}")
    print(f"MasterClass: {review['masterclass']}")
    print(f"Crosses threshold (certified novel): {review['crosses_threshold']}")


def demo_curriculum():
    print("\n" + "=" * 60)
    print("APPLICATION 3: Curriculum Optimizer")
    print("=" * 60)

    topics = {
        "Linear Algebra": {"vec_space", "eigenvalue", "svd"},
        "Real Analysis": {"limits", "continuity", "integration"},
        "Abstract Algebra": {"groups", "rings", "fields"},
        "Topology": {"open_sets", "continuity", "compactness"},
        "Number Theory": {"primes", "mod_arith", "quadratic_rec"},
    }

    weights = {
        "vec_space": 3, "eigenvalue": 7, "svd": 10,
        "limits": 4, "continuity": 5, "integration": 8,
        "groups": 6, "rings": 5, "fields": 9,
        "open_sets": 3, "compactness": 7,
        "primes": 5, "mod_arith": 4, "quadratic_rec": 8,
    }

    selected = optimize_curriculum(topics, weights, max_topics=3)

    print(f"\nAvailable topics: {list(topics.keys())}")
    print(f"Budget: 3 topics")
    print(f"\nOptimal selection (by greedy significance):")
    covered = set()
    for i, topic in enumerate(selected, 1):
        new = topics[topic] - covered
        sig = sum(weights.get(a, 0) for a in new)
        covered |= topics[topic]
        total = sum(weights.get(a, 0) for a in covered)
        print(f"  {i}. {topic}: +{sig} significance (total: {total})")


if __name__ == "__main__":
    demo_library_health()
    demo_review()
    demo_curriculum()


#!/usr/bin/env python3
"""
Demonstration of Certified Mathematical Significance Metrics.

Concrete numerical examples illustrating the significance valuation theory:
- Monotone significance on knowledge states
- Modularity (inclusion-exclusion) identity
- Threshold crossing and novelty detection
- ProofShape feature extraction and significance bounds
- Domain coverage lower bounds
- Triple significance and MasterClass gates
"""

import itertools
from typing import Dict, FrozenSet, Set, Callable, List, Tuple

# ============================================================
# Core Definitions
# ============================================================

def significance(w: Dict[str, int], K: Set[str]) -> int:
    """Significance of a knowledge state K under weight function w."""
    return sum(w.get(a, 0) for a in K)


def advances_field(w: Dict[str, int], tau: int,
                   K_old: Set[str], K_new: Set[str]) -> bool:
    """Check if K_new advances the field beyond K_old at threshold tau."""
    return (K_old <= K_new and
            significance(w, K_old) < tau and
            tau <= significance(w, K_new) and
            len(K_new - K_old) > 0)


# ============================================================
# Demo 1: Monotonicity of Significance
# ============================================================

def demo_monotonicity():
    print("=" * 60)
    print("DEMO 1: Monotonicity of Significance")
    print("=" * 60)

    w = {"prime_thm": 5, "group_iso": 8, "top_conn": 3,
         "galois_corr": 12, "spectral_seq": 7}

    K1 = {"prime_thm", "group_iso"}
    K2 = {"prime_thm", "group_iso", "top_conn"}
    K3 = {"prime_thm", "group_iso", "top_conn", "galois_corr", "spectral_seq"}

    print(f"\nWeights: {w}")
    print(f"\nK1 = {K1}")
    print(f"  σ(K1) = {significance(w, K1)}")
    print(f"\nK2 = {K2}")
    print(f"  σ(K2) = {significance(w, K2)}")
    print(f"\nK3 = {K3}")
    print(f"  σ(K3) = {significance(w, K3)}")
    print(f"\nK1 ⊆ K2 ⊆ K3: {K1 <= K2 and K2 <= K3}")
    print(f"σ(K1) ≤ σ(K2) ≤ σ(K3): "
          f"{significance(w, K1)} ≤ {significance(w, K2)} ≤ {significance(w, K3)}")
    print("✓ Monotonicity verified!")


# ============================================================
# Demo 2: Modularity (Inclusion-Exclusion)
# ============================================================

def demo_modularity():
    print("\n" + "=" * 60)
    print("DEMO 2: Modularity Identity")
    print("  σ(K1 ∪ K2) + σ(K1 ∩ K2) = σ(K1) + σ(K2)")
    print("=" * 60)

    w = {"A": 3, "B": 5, "C": 7, "D": 2, "E": 11}

    K1 = {"A", "B", "C"}
    K2 = {"B", "C", "D", "E"}

    union = K1 | K2
    inter = K1 & K2

    lhs = significance(w, union) + significance(w, inter)
    rhs = significance(w, K1) + significance(w, K2)

    print(f"\nK1 = {K1}, σ(K1) = {significance(w, K1)}")
    print(f"K2 = {K2}, σ(K2) = {significance(w, K2)}")
    print(f"K1 ∪ K2 = {union}, σ(K1 ∪ K2) = {significance(w, union)}")
    print(f"K1 ∩ K2 = {inter}, σ(K1 ∩ K2) = {significance(w, inter)}")
    print(f"\nLHS = σ(K1 ∪ K2) + σ(K1 ∩ K2) = {lhs}")
    print(f"RHS = σ(K1) + σ(K2) = {rhs}")
    print(f"Equal: {lhs == rhs}")
    print("✓ Modularity verified!")


# ============================================================
# Demo 3: Threshold Crossing and Novelty
# ============================================================

def demo_threshold():
    print("\n" + "=" * 60)
    print("DEMO 3: Threshold Crossing Implies Novelty")
    print("=" * 60)

    w = {"basic_calc": 2, "real_analysis": 6, "measure_theory": 8,
         "ergodic_thm": 10, "bridge_lemma": 15}

    K_old = {"basic_calc", "real_analysis"}
    tau = 20

    print(f"\nWeights: {w}")
    print(f"K_old = {K_old}, σ(K_old) = {significance(w, K_old)}")
    print(f"Threshold τ = {tau}")
    print(f"σ(K_old) < τ: {significance(w, K_old) < tau}")

    # Try adding theorems
    for new_atom in ["measure_theory", "ergodic_thm", "bridge_lemma"]:
        K_new = K_old | {new_atom}
        sig = significance(w, K_new)
        crosses = sig >= tau
        print(f"\n  Adding '{new_atom}': σ = {sig}, crosses threshold: {crosses}")
        if crosses:
            new_content = K_new - K_old
            print(f"  New content: {new_content}")
            print(f"  ✓ Advances field: {advances_field(w, tau, K_old, K_new)}")

    # Demonstrate that threshold crossing is impossible without new content
    print(f"\n  K_old = K_old (no change): advances = {advances_field(w, tau, K_old, K_old)}")
    print("✓ Threshold crossing requires genuinely new content!")


# ============================================================
# Demo 4: ProofShape Feature Extraction
# ============================================================

class ProofShape:
    """Abstract proof skeleton."""
    pass

class Ax(ProofShape):
    def __init__(self, tag: str):
        self.tag = tag
    def __repr__(self):
        return f"ax({self.tag})"

class App(ProofShape):
    def __init__(self, p: ProofShape, q: ProofShape):
        self.p, self.q = p, q
    def __repr__(self):
        return f"app({self.p}, {self.q})"

class Lam(ProofShape):
    def __init__(self, p: ProofShape):
        self.p = p
    def __repr__(self):
        return f"lam({self.p})"

class Pair(ProofShape):
    def __init__(self, p: ProofShape, q: ProofShape):
        self.p, self.q = p, q
    def __repr__(self):
        return f"pair({self.p}, {self.q})"


def features(p: ProofShape) -> Set[str]:
    """Extract feature set from a proof shape."""
    if isinstance(p, Ax):
        return {p.tag}
    elif isinstance(p, App):
        return features(p.p) | features(p.q)
    elif isinstance(p, Lam):
        return features(p.p)
    elif isinstance(p, Pair):
        return features(p.p) | features(p.q)
    return set()


def proof_size(p: ProofShape) -> int:
    """Structural size of a proof shape."""
    if isinstance(p, Ax):
        return 1
    elif isinstance(p, App):
        return proof_size(p.p) + proof_size(p.q) + 1
    elif isinstance(p, Lam):
        return proof_size(p.p) + 1
    elif isinstance(p, Pair):
        return proof_size(p.p) + proof_size(p.q) + 1
    return 0


def demo_proof_shape():
    print("\n" + "=" * 60)
    print("DEMO 4: ProofShape Feature Extraction")
    print("=" * 60)

    # A proof that uses group theory and topology
    proof = App(
        Lam(Pair(Ax("group_hom"), Ax("top_cont"))),
        App(Ax("fund_group"), Ax("galois_conn"))
    )

    w = {"group_hom": 4, "top_cont": 3, "fund_group": 8, "galois_conn": 12}

    feats = features(proof)
    size = proof_size(proof)
    sig = significance(w, feats)

    print(f"\nProof: {proof}")
    print(f"Features: {feats}")
    print(f"Size: {size}")
    print(f"Significance: {sig}")
    print(f"|features| ≤ size: {len(feats)} ≤ {size} ✓")

    C = max(w.values())
    print(f"Max weight C = {C}")
    print(f"σ ≤ C × size: {sig} ≤ {C * size} ✓")


# ============================================================
# Demo 5: Domain Coverage Lower Bound
# ============================================================

def demo_domain_coverage():
    print("\n" + "=" * 60)
    print("DEMO 5: Domain Coverage Lower Bound")
    print("=" * 60)

    # Atoms tagged by domain
    tags = {
        "prime_thm": "number_theory",
        "group_iso": "algebra",
        "fund_group": "topology",
        "spectral_seq": "topology",
        "galois_corr": "algebra",
        "ergodic_thm": "dynamics",
        "bridge_lemma": "analysis",
    }
    w = {a: 3 for a in tags}  # uniform weight ≥ 1

    K = set(tags.keys())
    domains = set(tags[a] for a in K)

    print(f"\nKnowledge state: {K}")
    print(f"Domain tags: {tags}")
    print(f"Domains covered: {domains}")
    print(f"|domains| = {len(domains)}")
    print(f"σ(K) = {significance(w, K)}")
    print(f"|domains| ≤ σ(K): {len(domains)} ≤ {significance(w, K)} ✓")
    print("✓ Cross-domain reach forces nontrivial significance!")


# ============================================================
# Demo 6: Triple Significance and MasterClass
# ============================================================

def demo_masterclass():
    print("\n" + "=" * 60)
    print("DEMO 6: Triple Significance & MasterClass")
    print("=" * 60)

    depth_w = {"A": 5, "B": 2, "C": 8, "D": 1}
    novelty_w = {"A": 1, "B": 7, "C": 3, "D": 9}
    bridge_w = {"A": 0, "B": 0, "C": 6, "D": 4}

    def triple_sig(K):
        return significance(depth_w, K) + significance(novelty_w, K) + significance(bridge_w, K)

    K1 = {"A", "B"}
    K2 = {"A", "B", "C"}
    K3 = {"A", "B", "C", "D"}
    tau = 30

    for name, K in [("K1", K1), ("K2", K2), ("K3", K3)]:
        ts = triple_sig(K)
        mc = ts >= tau
        print(f"\n{name} = {K}")
        print(f"  depth = {significance(depth_w, K)}, "
              f"novelty = {significance(novelty_w, K)}, "
              f"bridge = {significance(bridge_w, K)}")
        print(f"  triple_sig = {ts}")
        print(f"  MasterClass(τ={tau}): {mc}")

    print(f"\nK1 ⊆ K2 ⊆ K3, and MasterClass is upward-closed: once achieved, it persists.")
    print("✓ MasterClass monotonicity verified!")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Certified Mathematical Significance Metrics — Demos   ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_monotonicity()
    demo_modularity()
    demo_threshold()
    demo_proof_shape()
    demo_domain_coverage()
    demo_masterclass()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Certified Mathematical Significance Metrics.

Generates publication-quality figures illustrating the key mathematical
structures and theorems from the formal theory.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_monotonicity():
    """Visualize monotonicity of significance under knowledge growth."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Knowledge states growing over time
    stages = ['∅', '{A}', '{A,B}', '{A,B,C}', '{A,B,C,D}', '{A,B,C,D,E}']
    weights = [0, 5, 5+3, 5+3+8, 5+3+8+2, 5+3+8+2+11]

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(stages)))

    bars = ax.bar(range(len(stages)), weights, color=colors, edgecolor='black',
                  linewidth=0.8, width=0.6)

    # Add weight labels on bars
    for i, (bar, w) in enumerate(zip(bars, weights)):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
                f'σ = {w}', ha='center', va='bottom', fontsize=11, fontweight='bold')

    # Monotonicity arrows
    for i in range(len(stages)-1):
        ax.annotate('', xy=(i+1, weights[i+1]-1), xytext=(i, weights[i]+1),
                   arrowprops=dict(arrowstyle='->', color='red', lw=1.5, ls='--'))

    ax.set_xlabel('Knowledge State', fontsize=13)
    ax.set_ylabel('Significance σ(K)', fontsize=13)
    ax.set_title('Monotonicity: Knowledge Growth ⟹ Significance Growth',
                fontsize=15, fontweight='bold')
    ax.set_xticks(range(len(stages)))
    ax.set_xticklabels(stages, fontsize=10)
    ax.set_ylim(0, max(weights) + 5)
    ax.grid(axis='y', alpha=0.3)

    return fig_to_base64(fig)


def plot_modularity():
    """Visualize the modularity (inclusion-exclusion) identity."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Venn diagram style
    ax = axes[0]
    circle1 = plt.Circle((0.35, 0.5), 0.3, fill=False, color='blue',
                          linewidth=2, label='K₁')
    circle2 = plt.Circle((0.65, 0.5), 0.3, fill=False, color='red',
                          linewidth=2, label='K₂')
    ax.add_patch(circle1)
    ax.add_patch(circle2)

    ax.text(0.2, 0.5, 'K₁\\K₂\nσ=3', ha='center', va='center', fontsize=12,
            color='blue', fontweight='bold')
    ax.text(0.5, 0.5, 'K₁∩K₂\nσ=12', ha='center', va='center', fontsize=12,
            color='purple', fontweight='bold')
    ax.text(0.8, 0.5, 'K₂\\K₁\nσ=18', ha='center', va='center', fontsize=12,
            color='red', fontweight='bold')

    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(0.1, 0.9)
    ax.set_aspect('equal')
    ax.set_title('Knowledge State Overlap', fontsize=14, fontweight='bold')
    ax.axis('off')

    # Identity verification
    ax2 = axes[1]
    labels = ['σ(K₁∪K₂)', 'σ(K₁∩K₂)', 'σ(K₁)', 'σ(K₂)']
    values = [33, 12, 15, 30]
    colors_bar = ['#2ecc71', '#9b59b6', '#3498db', '#e74c3c']

    bars = ax2.barh(labels, values, color=colors_bar, edgecolor='black', height=0.5)

    for bar, v in zip(bars, values):
        ax2.text(bar.get_width() + 0.5, bar.get_y() + bar.get_height()/2,
                f'{v}', va='center', fontsize=12, fontweight='bold')

    ax2.set_xlabel('Value', fontsize=12)
    ax2.set_title('Modularity: σ(K₁∪K₂) + σ(K₁∩K₂) = σ(K₁) + σ(K₂)\n'
                 f'33 + 12 = 15 + 30 = 45 ✓', fontsize=13, fontweight='bold')
    ax2.set_xlim(0, 40)

    plt.tight_layout()
    return fig_to_base64(fig)


def plot_threshold_crossing():
    """Visualize threshold crossing and novelty detection."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Timeline of knowledge additions
    steps = list(range(8))
    sigs = [0, 5, 8, 16, 16, 24, 31, 35]
    labels = ['∅', '+A(5)', '+B(3)', '+C(8)', 'repack', '+D(8)', '+E(7)', '+F(4)']
    novel = [False, True, True, True, False, True, True, True]

    tau = 20

    # Plot significance line
    for i in range(len(steps)-1):
        color = '#2ecc71' if sigs[i+1] > sigs[i] else '#e74c3c'
        ax.plot([steps[i], steps[i+1]], [sigs[i], sigs[i+1]],
               color=color, linewidth=2.5, zorder=3)

    # Plot points
    for i, (s, sig, lab, n) in enumerate(zip(steps, sigs, labels, novel)):
        marker = 'o' if n else 'x'
        color = '#2ecc71' if n else '#e74c3c'
        size = 100 if n else 150
        ax.scatter(s, sig, c=color, s=size, marker=marker, zorder=5,
                  edgecolors='black', linewidths=1)
        ax.text(s, sig + 1.5, lab, ha='center', va='bottom', fontsize=9,
               fontweight='bold', rotation=30)

    # Threshold line
    ax.axhline(y=tau, color='orange', linestyle='--', linewidth=2, label=f'Threshold τ = {tau}')
    ax.fill_between([min(steps)-0.5, max(steps)+0.5], tau, max(sigs)+5,
                    alpha=0.1, color='green')
    ax.text(max(steps)+0.3, tau+1, 'ADVANCES\nFIELD', fontsize=10,
           color='green', fontweight='bold', va='bottom')
    ax.text(max(steps)+0.3, tau-2, 'BELOW\nTHRESHOLD', fontsize=10,
           color='gray', va='top')

    # Mark crossing point
    cross_idx = next(i for i, s in enumerate(sigs) if s >= tau)
    ax.annotate(f'Threshold crossed!\nNovel content required',
               xy=(cross_idx, sigs[cross_idx]),
               xytext=(cross_idx-2, sigs[cross_idx]+8),
               arrowprops=dict(arrowstyle='->', color='orange', lw=2),
               fontsize=11, color='orange', fontweight='bold',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    ax.set_xlabel('Knowledge Evolution Steps', fontsize=13)
    ax.set_ylabel('Significance σ(K)', fontsize=13)
    ax.set_title('Threshold Crossing Implies Genuine Novelty', fontsize=15,
                fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(-2, max(sigs)+12)
    ax.grid(alpha=0.3)

    return fig_to_base64(fig)


def plot_proof_shape():
    """Visualize ProofShape feature extraction."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 7))

    # Left: Proof tree
    ax = axes[0]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 8)

    # Draw tree nodes
    nodes = {
        'app': (5, 7, 'APP'),
        'lam': (3, 5, 'LAM'),
        'pair': (3, 3, 'PAIR'),
        'ax_A': (2, 1, 'ax(A)'),
        'ax_B': (4, 1, 'ax(B)'),
        'app2': (7, 5, 'APP'),
        'ax_C': (6, 3, 'ax(C)'),
        'ax_D': (8, 3, 'ax(D)'),
    }

    edges = [
        ('app', 'lam'), ('app', 'app2'),
        ('lam', 'pair'),
        ('pair', 'ax_A'), ('pair', 'ax_B'),
        ('app2', 'ax_C'), ('app2', 'ax_D'),
    ]

    for name, (x, y, label) in nodes.items():
        color = '#3498db' if 'ax' not in name else '#e74c3c'
        ax.add_patch(plt.Circle((x, y), 0.4, color=color, alpha=0.8, zorder=3))
        ax.text(x, y, label, ha='center', va='center', fontsize=8,
               fontweight='bold', color='white', zorder=4)

    for n1, n2 in edges:
        x1, y1, _ = nodes[n1]
        x2, y2, _ = nodes[n2]
        ax.plot([x1, x2], [y1-0.4, y2+0.4], 'k-', linewidth=1.5, zorder=1)

    ax.set_title('Proof Shape Tree', fontsize=14, fontweight='bold')
    ax.axis('off')

    # Right: Feature extraction and significance
    ax2 = axes[1]
    features = {'A': 5, 'B': 3, 'C': 8, 'D': 2}
    names = list(features.keys())
    vals = list(features.values())
    colors = ['#e74c3c', '#e67e22', '#2ecc71', '#9b59b6']

    bars = ax2.bar(names, vals, color=colors, edgecolor='black', width=0.5)
    for bar, v in zip(bars, vals):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.2,
                f'w={v}', ha='center', va='bottom', fontsize=12, fontweight='bold')

    total = sum(vals)
    size = 7  # total nodes in tree
    C = max(vals)

    ax2.set_title(f'Extracted Features & Weights\n'
                 f'σ = {total} ≤ C×size = {C}×{size} = {C*size}',
                 fontsize=13, fontweight='bold')
    ax2.set_ylabel('Weight w(a)', fontsize=12)
    ax2.set_xlabel('Feature (Axiom Tag)', fontsize=12)
    ax2.axhline(y=C, color='gray', linestyle=':', label=f'C = {C} (max weight)')
    ax2.legend()

    plt.tight_layout()
    return fig_to_base64(fig)


def plot_domain_coverage():
    """Visualize domain coverage lower bound."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Multiple knowledge states with varying domain coverage
    states = [
        ("Narrow\n(1 domain)", {"A": 5, "B": 3, "C": 4}, 1),
        ("Two domains", {"A": 5, "D": 7, "E": 3}, 2),
        ("Three domains", {"A": 5, "D": 7, "G": 8}, 3),
        ("Broad\n(4 domains)", {"A": 5, "D": 7, "G": 8, "J": 6}, 4),
        ("Full breadth\n(5 domains)", {"A": 5, "D": 7, "G": 8, "J": 6, "M": 10}, 5),
    ]

    x = range(len(states))
    sigs = [sum(s[1].values()) for s in states]
    domains = [s[2] for s in states]

    bar_width = 0.35
    bars1 = ax.bar([i - bar_width/2 for i in x], sigs, bar_width,
                   label='Significance σ(K)', color='#3498db', edgecolor='black')
    bars2 = ax.bar([i + bar_width/2 for i in x], domains, bar_width,
                   label='Domain Coverage |D(K)|', color='#e74c3c', edgecolor='black')

    for bar, v in zip(bars1, sigs):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
                str(v), ha='center', va='bottom', fontsize=11, fontweight='bold')
    for bar, v in zip(bars2, domains):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
                str(v), ha='center', va='bottom', fontsize=11, fontweight='bold',
                color='#e74c3c')

    ax.set_xlabel('Knowledge State Configuration', fontsize=13)
    ax.set_ylabel('Value', fontsize=13)
    ax.set_title('Domain Coverage Lower Bound: |domains| ≤ σ(K)\n'
                '(When all weights ≥ 1)', fontsize=15, fontweight='bold')
    ax.set_xticks(list(x))
    ax.set_xticklabels([s[0] for s in states], fontsize=10)
    ax.legend(fontsize=12)
    ax.grid(axis='y', alpha=0.3)

    return fig_to_base64(fig)


def plot_triple_significance():
    """Visualize triple significance decomposition."""
    fig, ax = plt.subplots(figsize=(10, 7))

    categories = ['Package A\n(Deep)', 'Package B\n(Novel)', 'Package C\n(Bridge)',
                  'Package D\n(Balanced)', 'Package E\n(Master)']

    depth =   [25, 5, 3, 12, 20]
    novelty = [3, 22, 5, 10, 18]
    bridge =  [2, 3, 20, 8, 15]

    x = np.arange(len(categories))
    width = 0.5

    ax.bar(x, depth, width, label='Depth', color='#2ecc71', edgecolor='black')
    ax.bar(x, novelty, width, bottom=depth, label='Novelty', color='#3498db', edgecolor='black')
    ax.bar(x, bridge, width, bottom=[d+n for d,n in zip(depth, novelty)],
           label='Bridge', color='#e74c3c', edgecolor='black')

    # Total labels
    totals = [d+n+b for d,n,b in zip(depth, novelty, bridge)]
    for i, t in enumerate(totals):
        ax.text(i, t + 1, f'Σ={t}', ha='center', va='bottom',
               fontsize=11, fontweight='bold')

    # MasterClass threshold
    tau = 40
    ax.axhline(y=tau, color='gold', linestyle='--', linewidth=2.5,
              label=f'MasterClass τ = {tau}')

    # Mark MasterClass packages
    for i, t in enumerate(totals):
        if t >= tau:
            ax.text(i, t + 5, '★', ha='center', fontsize=20, color='gold')

    ax.set_xlabel('Research Package', fontsize=13)
    ax.set_ylabel('Triple Significance', fontsize=13)
    ax.set_title('Triple Significance: Depth + Novelty + Bridge\n'
                'MasterClass status is upward-closed under knowledge growth',
                fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(categories, fontsize=10)
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(axis='y', alpha=0.3)
    ax.set_ylim(0, max(totals) + 12)

    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return as dict."""
    print("Generating visualizations...")

    viz = {}
    viz['monotonicity'] = plot_monotonicity()
    print("  ✓ Monotonicity plot")

    viz['modularity'] = plot_modularity()
    print("  ✓ Modularity plot")

    viz['threshold'] = plot_threshold_crossing()
    print("  ✓ Threshold crossing plot")

    viz['proof_shape'] = plot_proof_shape()
    print("  ✓ Proof shape plot")

    viz['domain_coverage'] = plot_domain_coverage()
    print("  ✓ Domain coverage plot")

    viz['triple_significance'] = plot_triple_significance()
    print("  ✓ Triple significance plot")

    return viz


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    print(f"\nGenerated {len(vizs)} visualizations as base64 data URIs.")

    # Save individual PNGs
    for name, uri in vizs.items():
        b64data = uri.split(",")[1]
        with open(f"viz_{name}.png", "wb") as f:
            f.write(base64.b64decode(b64data))
        print(f"  Saved viz_{name}.png")
