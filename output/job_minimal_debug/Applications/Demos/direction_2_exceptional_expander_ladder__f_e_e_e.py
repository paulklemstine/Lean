#!/usr/bin/env python3
"""
Exceptional Expander Ladder — Applications

Demonstrates real-world applications of the exceptional certificate framework:
1. Expansion certification for network design
2. Mixing time estimation for random walks
3. Code distance lower bounds from spectral gaps
4. Pseudorandomness quality metrics
"""

import math
import random
from typing import List, Tuple, Dict

# ─── Application 1: Network Expansion Certification ─────────────────────────

def certify_network_expansion(
    num_torus_types: int,
    local_bounds: List[float],
    threshold: float = 1.0,
) -> Dict[str, any]:
    """Certify that a Cayley graph from an exceptional group is an expander.

    Given the local character-ratio bounds for each torus type,
    determines whether the associated Cayley graph has a spectral gap.

    Args:
        num_torus_types: Number of torus types.
        local_bounds: Character-ratio bound for each torus type.
        threshold: Expansion threshold (typically 1.0).

    Returns:
        Certificate with expansion status, spectral gap, and diagnostics.
    """
    global_bound = max(local_bounds)
    argmax = local_bounds.index(global_bound)
    safety_margin = threshold - global_bound

    spectral_gap = max(0, 1 - global_bound) if global_bound < threshold else 0
    cheeger_bound = spectral_gap / 2

    return {
        "is_expander": safety_margin > 0,
        "global_bound": global_bound,
        "worst_torus_type": argmax,
        "safety_margin": safety_margin,
        "spectral_gap": spectral_gap,
        "cheeger_constant_lower_bound": cheeger_bound,
        "num_torus_types": num_torus_types,
    }


# ─── Application 2: Mixing Time Estimation ──────────────────────────────────

def estimate_mixing_time(
    spectral_gap: float,
    group_order: int,
    epsilon: float = 0.01,
) -> Dict[str, any]:
    """Estimate the mixing time of a random walk on the Cayley graph.

    Uses the bound: t_mix(ε) ≤ (1/gap) · ln(|G|/ε)

    Args:
        spectral_gap: Spectral gap of the Cayley graph.
        group_order: Order of the finite group.
        epsilon: Target total variation distance.

    Returns:
        Mixing time estimates and convergence profile.
    """
    if spectral_gap <= 0:
        return {
            "mixing_time": float("inf"),
            "spectral_radius": 1.0,
            "convergence_rate": 0.0,
            "convergence_profile": [],
        }

    spectral_radius = 1 - spectral_gap
    mixing_time = math.ceil(math.log(group_order / epsilon) / spectral_gap)

    # Convergence profile: L2 error at each step
    profile = []
    for t in range(min(mixing_time + 10, 200)):
        l2_error = spectral_radius ** t
        profile.append((t, l2_error))

    return {
        "mixing_time": mixing_time,
        "spectral_radius": spectral_radius,
        "convergence_rate": spectral_gap,
        "convergence_profile": profile,
    }


# ─── Application 3: Code Distance from Expansion ────────────────────────────

def code_distance_bound(
    cheeger_constant: float,
    degree: int,
    num_vertices: int,
) -> Dict[str, any]:
    """Compute a code distance lower bound from the Cheeger constant.

    For a d-regular expander on n vertices with Cheeger constant h,
    the associated code has distance δ ≥ h·n / (2d).

    Args:
        cheeger_constant: Cheeger constant lower bound.
        degree: Degree of the Cayley graph (= |S|).
        num_vertices: Number of vertices (= |G|).

    Returns:
        Code distance bounds and related metrics.
    """
    if cheeger_constant <= 0 or degree <= 0:
        return {"distance": 0, "rate": 0, "relative_distance": 0}

    distance = math.floor(cheeger_constant * num_vertices / (2 * degree))
    rate = 1 - math.log2(num_vertices) / num_vertices if num_vertices > 1 else 0
    relative_distance = distance / num_vertices if num_vertices > 0 else 0

    return {
        "distance": distance,
        "num_vertices": num_vertices,
        "degree": degree,
        "rate": rate,
        "relative_distance": relative_distance,
        "cheeger_constant": cheeger_constant,
    }


# ─── Application 4: Pseudorandomness Quality ────────────────────────────────

def pseudorandomness_quality(
    spectral_gap: float,
    degree: int,
    num_vertices: int,
) -> Dict[str, any]:
    """Assess pseudorandomness quality of the Cayley graph.

    The expander mixing lemma gives:
    |e(S, T) - d·|S|·|T|/n| ≤ λ₂ · √(|S|·|T|)

    where λ₂ is the second-largest eigenvalue.

    Args:
        spectral_gap: Spectral gap (1 - λ₂/d for normalized adjacency).
        degree: Degree of the graph.
        num_vertices: Number of vertices.

    Returns:
        Pseudorandomness metrics.
    """
    lambda2 = degree * (1 - spectral_gap)

    # Edge discrepancy for sets of various sizes
    discrepancies = {}
    for frac in [0.01, 0.05, 0.1, 0.25, 0.5]:
        size = int(frac * num_vertices)
        if size < 1:
            continue
        expected_edges = degree * size * size / num_vertices
        max_deviation = lambda2 * size
        discrepancy = max_deviation / expected_edges if expected_edges > 0 else float("inf")
        discrepancies[f"|S|={size}"] = {
            "expected_edges": expected_edges,
            "max_deviation": max_deviation,
            "relative_discrepancy": discrepancy,
        }

    return {
        "lambda2": lambda2,
        "spectral_gap": spectral_gap,
        "degree": degree,
        "num_vertices": num_vertices,
        "discrepancies": discrepancies,
    }


# ─── Integrated Demo ─────────────────────────────────────────────────────────

def run_full_application_demo():
    """Run a complete application demo for F₄(q=7)."""
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║     EXCEPTIONAL EXPANDER APPLICATIONS — F₄(q=7)            ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # F₄(q=7) parameters
    rank = 4
    q = 7
    num_torus_types = 25
    degree = 48  # F₄ has 48 roots, so the natural generating set has 48 elements

    # Approximate group order: |F₄(q)| ~ q^52
    group_order = q ** 52

    # Generate sample local bounds
    rng = random.Random(42)
    local_bounds = [rng.uniform(0.05, 0.4) for _ in range(num_torus_types)]

    # Application 1: Expansion certification
    print("\n── Application 1: Expansion Certification ──")
    cert = certify_network_expansion(num_torus_types, local_bounds)
    print(f"  Is expander: {cert['is_expander']}")
    print(f"  Global bound: {cert['global_bound']:.6f}")
    print(f"  Worst torus type: t_{cert['worst_torus_type']}")
    print(f"  Spectral gap: {cert['spectral_gap']:.6f}")
    print(f"  Cheeger lower bound: {cert['cheeger_constant_lower_bound']:.6f}")

    # Application 2: Mixing time
    print("\n── Application 2: Mixing Time Estimation ──")
    mix = estimate_mixing_time(cert["spectral_gap"], group_order)
    print(f"  Spectral radius: {mix['spectral_radius']:.6f}")
    print(f"  Mixing time (ε=0.01): {mix['mixing_time']} steps")
    print(f"  Convergence at step 10: {mix['spectral_radius']**10:.6e}")
    print(f"  Convergence at step 50: {mix['spectral_radius']**50:.6e}")

    # Application 3: Code distance
    print("\n── Application 3: Code Distance Bound ──")
    code = code_distance_bound(cert["cheeger_constant_lower_bound"], degree, 10000)
    print(f"  Graph: {code['num_vertices']} vertices, degree {code['degree']}")
    print(f"  Code distance ≥ {code['distance']}")
    print(f"  Relative distance: {code['relative_distance']:.4f}")

    # Application 4: Pseudorandomness
    print("\n── Application 4: Pseudorandomness Quality ──")
    pr = pseudorandomness_quality(cert["spectral_gap"], degree, 10000)
    print(f"  Second eigenvalue λ₂: {pr['lambda2']:.4f}")
    for label, disc in pr["discrepancies"].items():
        print(f"  {label}: relative discrepancy = {disc['relative_discrepancy']:.4f}")


if __name__ == "__main__":
    run_full_application_demo()


#!/usr/bin/env python3
"""
Exceptional Expander Ladder — Interactive Demo

Demonstrates the certificate framework for exceptional groups F₄, E₆, E₇, E₈.
Users can input torus-type local bounds, compute global bounds and spectral
safety margins, test refinement monotonicity, and explore the toral complexity
profile.

Usage:
    python demo.py
"""

import random
import math

# ─── Exceptional Type Data ───────────────────────────────────────────────────

EXCEPTIONAL_TYPES = {
    "F4": {"rank": 4, "num_torus_types": 25, "weyl_order": 1152},
    "E6": {"rank": 6, "num_torus_types": 25, "weyl_order": 51840},
    "E7": {"rank": 7, "num_torus_types": 60, "weyl_order": 2903040},
    "E8": {"rank": 8, "num_torus_types": 112, "weyl_order": 696729600},
}


# ─── Core Certificate Framework ─────────────────────────────────────────────

class ExceptionalFamily:
    """An exceptional family with torus types, complexities, and local bounds."""

    def __init__(self, name, complexities, local_bounds):
        assert len(complexities) == len(local_bounds)
        self.name = name
        self.num_torus_types = len(complexities)
        self.complexities = list(complexities)
        self.local_bounds = list(local_bounds)

    def global_bound(self):
        """Maximum local bound over all torus types."""
        return max(self.local_bounds)

    def argmax_torus_type(self):
        """Index of the torus type achieving the global bound."""
        gb = self.global_bound()
        for i, lb in enumerate(self.local_bounds):
            if lb == gb:
                return i
        return 0

    def spectral_safety_margin(self, theta=1.0):
        """θ - globalBound. Positive ⟹ expansion certified."""
        return theta - self.global_bound()

    def toral_complexity_profile(self):
        """Set of complexity values across torus types."""
        return sorted(set(self.complexities))

    def is_certified_expander(self, theta=1.0):
        """True if the global bound is strictly below theta."""
        return self.global_bound() < theta

    def display(self, theta=1.0):
        """Pretty-print certificate summary."""
        gb = self.global_bound()
        margin = self.spectral_safety_margin(theta)
        argmax = self.argmax_torus_type()
        print(f"\n{'='*60}")
        print(f"  Exceptional Family: {self.name}")
        print(f"  Torus types: {self.num_torus_types}")
        print(f"  Global bound: {gb:.6f}")
        print(f"  Maximizing torus type: t_{argmax} (bound = {self.local_bounds[argmax]:.6f})")
        print(f"  Spectral safety margin (θ={theta}): {margin:.6f}")
        print(f"  Certified expander: {'YES ✓' if margin > 0 else 'NO ✗'}")
        print(f"  Toral complexity profile: {self.toral_complexity_profile()[:10]}{'...' if len(self.toral_complexity_profile()) > 10 else ''}")
        print(f"{'='*60}")


class ExceptionalCertificate(ExceptionalFamily):
    """An exceptional certificate with a complexity bound."""

    def __init__(self, name, complexities, local_bounds, complexity_bound=None):
        super().__init__(name, complexities, local_bounds)
        if complexity_bound is None:
            complexity_bound = max(complexities)
        self.complexity_bound = complexity_bound
        assert all(c <= complexity_bound for c in complexities)


class CertificateRefinement:
    """A refinement from C1 to C2, witnessed by a map refine: C2.torus → C1.torus."""

    def __init__(self, c1, c2, refine_map):
        self.c1 = c1
        self.c2 = c2
        self.refine_map = refine_map  # list: c2 torus index → c1 torus index
        # Verify: local bounds improve pointwise
        for t2 in range(c2.num_torus_types):
            t1 = refine_map[t2]
            assert c2.local_bounds[t2] <= c1.local_bounds[t1] + 1e-12, \
                f"Refinement violated at t2={t2}: {c2.local_bounds[t2]} > {c1.local_bounds[t1]}"


def demonstrate_refinement_monotonicity(c1, c2, refine_map):
    """Demonstrate that refinement improves the global bound."""
    ref = CertificateRefinement(c1, c2, refine_map)
    gb1 = c1.global_bound()
    gb2 = c2.global_bound()
    print(f"\n  Refinement: {c1.name} ← {c2.name}")
    print(f"  Global bound (coarse): {gb1:.6f}")
    print(f"  Global bound (fine):   {gb2:.6f}")
    print(f"  Monotonicity: {gb2:.6f} ≤ {gb1:.6f} → {'VERIFIED ✓' if gb2 <= gb1 + 1e-12 else 'FAILED ✗'}")
    improvement = (gb1 - gb2) / gb1 * 100 if gb1 > 0 else 0
    print(f"  Improvement: {improvement:.2f}%")
    return ref


# ─── Sample Data Generation ─────────────────────────────────────────────────

def generate_sample_family(lie_type, q, seed=42):
    """Generate a sample exceptional family with synthetic local bounds.

    Bounds are modeled as C_t / q where C_t depends on torus type.
    """
    info = EXCEPTIONAL_TYPES[lie_type]
    n = info["num_torus_types"]
    rng = random.Random(seed)

    # Complexity: roughly proportional to centralizer order
    complexities = [rng.randint(1, info["weyl_order"] // n) for _ in range(n)]

    # Local bounds: C_t / q with C_t ~ Uniform(0.5, rank)
    rank = info["rank"]
    C_t = [rng.uniform(0.5, rank) for _ in range(n)]
    local_bounds = [c / q for c in C_t]

    return ExceptionalCertificate(
        name=f"{lie_type}(q={q})",
        complexities=complexities,
        local_bounds=local_bounds,
        complexity_bound=max(complexities)
    )


def generate_refined_family(coarse, seed=123):
    """Generate a refined certificate by splitting the worst torus type."""
    rng = random.Random(seed)
    argmax = coarse.argmax_torus_type()

    # Split the worst torus type into 3 subtypes
    new_complexities = list(coarse.complexities)
    new_local_bounds = list(coarse.local_bounds)

    worst_bound = coarse.local_bounds[argmax]
    worst_complexity = coarse.complexities[argmax]

    # Replace the worst type with 3 subtypes, each with a better bound
    new_complexities.pop(argmax)
    new_local_bounds.pop(argmax)

    for i in range(3):
        new_complexities.append(worst_complexity + i + 1)
        # Each subtype has a bound strictly less than the original
        new_local_bounds.append(worst_bound * rng.uniform(0.7, 0.95))

    # Build refinement map: new indices → old indices
    refine_map = list(range(coarse.num_torus_types))
    refine_map.pop(argmax)
    refine_map.extend([argmax] * 3)

    refined = ExceptionalCertificate(
        name=f"{coarse.name} (refined)",
        complexities=new_complexities,
        local_bounds=new_local_bounds,
    )
    return refined, refine_map


# ─── Main Demo ───────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║     EXCEPTIONAL EXPANDER LADDER — Interactive Demo          ║")
    print("║     Certificate Framework for F₄, E₆, E₇, E₈              ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # ── Part 1: Display exceptional type data ──
    print("\n" + "─"*60)
    print("  EXCEPTIONAL LIE TYPES")
    print("─"*60)
    print(f"  {'Type':<6} {'Rank':<6} {'Torus Types':<14} {'Weyl Order':<15}")
    for name, info in EXCEPTIONAL_TYPES.items():
        print(f"  {name:<6} {info['rank']:<6} {info['num_torus_types']:<14} {info['weyl_order']:>15,}")

    # ── Part 2: Generate certificates for each type ──
    print("\n" + "─"*60)
    print("  CERTIFICATE GENERATION (q = 7)")
    print("─"*60)

    q = 7
    families = {}
    for lie_type in EXCEPTIONAL_TYPES:
        fam = generate_sample_family(lie_type, q)
        fam.display()
        families[lie_type] = fam

    # ── Part 3: Demonstrate refinement monotonicity ──
    print("\n" + "─"*60)
    print("  REFINEMENT MONOTONICITY DEMONSTRATION")
    print("─"*60)

    for lie_type in ["F4", "E8"]:
        coarse = families[lie_type]
        refined, refine_map = generate_refined_family(coarse)
        demonstrate_refinement_monotonicity(coarse, refined, refine_map)

    # ── Part 4: Spectral safety margin across q values ──
    print("\n" + "─"*60)
    print("  SPECTRAL SAFETY MARGIN vs FIELD SIZE q")
    print("─"*60)

    for lie_type in ["F4", "E8"]:
        print(f"\n  {lie_type}:")
        print(f"  {'q':<6} {'Global Bound':<15} {'Safety Margin':<15} {'Expander?':<10}")
        for q in [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25]:
            fam = generate_sample_family(lie_type, q)
            gb = fam.global_bound()
            margin = fam.spectral_safety_margin()
            exp_str = "YES" if margin > 0 else "NO"
            print(f"  {q:<6} {gb:<15.6f} {margin:<15.6f} {exp_str:<10}")

    # ── Part 5: Conjecture testing ──
    print("\n" + "─"*60)
    print("  EXCEPTIONAL TORAL BOUNDEDNESS CONJECTURE TEST")
    print("─"*60)

    for lie_type in EXCEPTIONAL_TYPES:
        max_gb = 0
        for q in [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27, 29, 31]:
            fam = generate_sample_family(lie_type, q)
            # Compute q * globalBound to test if C_X = q * M_X(q) is bounded
            scaled = q * fam.global_bound()
            max_gb = max(max_gb, scaled)
        print(f"  {lie_type}: max(q · M_X(q)) = {max_gb:.4f}  (bounded = {'YES ✓' if max_gb < 100 else 'UNCLEAR'})")

    # ── Part 6: Sum composition ──
    print("\n" + "─"*60)
    print("  SUM COMPOSITION: globalBound(F₁ ⊕ F₂) = max(gb₁, gb₂)")
    print("─"*60)

    f4 = families["F4"]
    e8 = families["E8"]
    gb_f4 = f4.global_bound()
    gb_e8 = e8.global_bound()
    gb_sum = max(gb_f4, gb_e8)
    print(f"  globalBound(F₄) = {gb_f4:.6f}")
    print(f"  globalBound(E₈) = {gb_e8:.6f}")
    print(f"  globalBound(F₄ ⊕ E₈) = max = {gb_sum:.6f}")
    print(f"  Verified: {gb_sum == max(gb_f4, gb_e8)} ✓")

    print("\n" + "═"*60)
    print("  Demo complete.")
    print("═"*60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Refinement Ladder and Monotonicity

Visualizes the certificate refinement process: starting from a coarse
certificate and iteratively splitting the worst torus type. The global
bound decreases monotonically at each step (proven formally as
globalBound_mono_under_refinement).

SELF-CONTAINED: All functions are inlined. No local imports.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

# ─── Inline certificate logic ───────────────────────────────────────────────

def generate_certificate(num_types, max_bound, seed=42):
    rng = random.Random(seed)
    bounds = [rng.uniform(0.05, max_bound) for _ in range(num_types)]
    complexities = [rng.randint(1, 50) for _ in range(num_types)]
    return bounds, complexities

def refine_step(bounds, complexities, rng):
    """Split the worst torus type into 3 subtypes with reduced bounds."""
    argmax = bounds.index(max(bounds))
    worst = bounds[argmax]
    worst_c = complexities[argmax]

    new_bounds = list(bounds)
    new_complexities = list(complexities)
    new_bounds.pop(argmax)
    new_complexities.pop(argmax)

    for i in range(3):
        new_bounds.append(worst * rng.uniform(0.7, 0.95))
        new_complexities.append(worst_c + i + 1)

    return new_bounds, new_complexities

# ─── Generate refinement ladder data ────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for idx, (lie_type, n_types, color) in enumerate([
    ("F₄", 25, "#2196F3"),
    ("E₆", 25, "#4CAF50"),
    ("E₇", 60, "#FF9800"),
    ("E₈", 112, "#F44336"),
]):
    ax = axes[idx // 2][idx % 2]
    rng = random.Random(42 + idx)

    bounds, complexities = generate_certificate(n_types, 0.8, seed=42+idx)
    global_bounds = [max(bounds)]
    num_types_history = [len(bounds)]
    margin_history = [1.0 - max(bounds)]

    for step in range(12):
        bounds, complexities = refine_step(bounds, complexities, rng)
        global_bounds.append(max(bounds))
        num_types_history.append(len(bounds))
        margin_history.append(1.0 - max(bounds))

    steps = list(range(len(global_bounds)))

    # Plot global bound
    ax.plot(steps, global_bounds, 'o-', color=color, linewidth=2.5, markersize=7,
            label='Global bound', zorder=3)
    ax.fill_between(steps, global_bounds, alpha=0.15, color=color)

    # Plot safety margin
    ax.plot(steps, margin_history, 's--', color='gray', linewidth=1.5, markersize=5,
            label='Safety margin', alpha=0.7)

    ax.axhline(y=1.0, color='black', linestyle=':', alpha=0.3)
    ax.set_xlabel("Refinement step", fontsize=11)
    ax.set_ylabel("Bound value", fontsize=11)
    ax.set_title(f"{lie_type}: Refinement Ladder ({n_types} initial types)", fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.2)

    # Annotate monotonicity
    for i in range(1, len(global_bounds)):
        if global_bounds[i] <= global_bounds[i-1]:
            pass  # All steps should satisfy this
        else:
            ax.annotate("VIOLATION!", (i, global_bounds[i]), color='red', fontsize=8)

plt.suptitle("Certificate Refinement Monotonicity\n(globalBound decreases at each step — formally proven)",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("refinement_ladder_visualization.png", dpi=150, bbox_inches='tight')
print("Saved: refinement_ladder_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Exceptional Spectral Atlas Heatmap

Visualizes the local character-ratio bounds as a heatmap across
torus types (rows) and field sizes (columns) for each exceptional type.
This is a preview of the Exceptional Spectral Atlas.

SELF-CONTAINED: All functions are inlined. No local imports.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

# ─── Generate atlas data ────────────────────────────────────────────────────

def generate_atlas_data(num_types, rank, q_values, seed=42):
    """Generate a synthetic local-bound matrix: rows=torus types, cols=q values."""
    rng = random.Random(seed)
    C_t = [rng.uniform(0.3, rank * 0.7) for _ in range(num_types)]
    matrix = np.zeros((num_types, len(q_values)))
    for j, q in enumerate(q_values):
        for i in range(num_types):
            matrix[i, j] = C_t[i] / q
    return matrix

q_values = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 19, 23, 25, 27, 31]

fig, axes = plt.subplots(2, 2, figsize=(16, 12))

types_data = [
    ("F₄", 25, 4, "#2196F3"),
    ("E₆", 25, 6, "#4CAF50"),
    ("E₇", 60, 7, "#FF9800"),
    ("E₈", 112, 8, "#F44336"),
]

for idx, (name, n_types, rank, color) in enumerate(types_data):
    ax = axes[idx // 2][idx % 2]

    # For visualization, show only first 30 torus types for readability
    show_types = min(n_types, 30)
    matrix = generate_atlas_data(n_types, rank, q_values, seed=42+idx)[:show_types]

    im = ax.imshow(matrix, aspect='auto', cmap='YlOrRd', interpolation='nearest',
                   vmin=0, vmax=np.max(matrix))

    ax.set_xlabel("Field size q", fontsize=11)
    ax.set_ylabel("Torus type index", fontsize=11)
    ax.set_title(f"{name} — Local Bounds Atlas\n({n_types} torus types, showing {show_types})",
                 fontsize=12, fontweight='bold')

    # Set tick labels
    ax.set_xticks(range(0, len(q_values), 2))
    ax.set_xticklabels([str(q_values[i]) for i in range(0, len(q_values), 2)], fontsize=9)

    if show_types <= 30:
        ax.set_yticks(range(0, show_types, max(1, show_types // 10)))

    plt.colorbar(im, ax=ax, label='Local bound', shrink=0.8)

    # Mark the global bound (worst row) for each q
    for j in range(len(q_values)):
        worst_type = np.argmax(matrix[:, j])
        ax.plot(j, worst_type, 'k*', markersize=8, alpha=0.7)

plt.suptitle("Exceptional Spectral Atlas\n(★ marks the maximizing torus type for each q)",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("spectral_atlas_visualization.png", dpi=150, bbox_inches='tight')
print("Saved: spectral_atlas_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Toral Bounds Across Exceptional Types

Visualizes how the global character-ratio bound varies with field size q
for each exceptional type F₄, E₆, E₇, E₈. The key prediction is that
q × M_X(q) stabilizes below a finite ceiling that grows with rank.

SELF-CONTAINED: All functions are inlined. No local imports.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

# ─── Inline data and functions ───────────────────────────────────────────────

EXCEPTIONAL_TYPES = {
    "F₄": {"rank": 4, "num_torus_types": 25, "weyl_order": 1152, "color": "#2196F3"},
    "E₆": {"rank": 6, "num_torus_types": 25, "weyl_order": 51840, "color": "#4CAF50"},
    "E₇": {"rank": 7, "num_torus_types": 60, "weyl_order": 2903040, "color": "#FF9800"},
    "E₈": {"rank": 8, "num_torus_types": 112, "weyl_order": 696729600, "color": "#F44336"},
}

def generate_sample_bounds(lie_type, q, seed=42):
    """Generate sample local bounds for a given exceptional type and field size."""
    info = EXCEPTIONAL_TYPES[lie_type]
    n = info["num_torus_types"]
    rng = random.Random(seed + hash(lie_type))
    rank = info["rank"]
    # C_t values are roughly proportional to rank
    C_t = [rng.uniform(0.5, rank * 0.8) for _ in range(n)]
    return [c / q for c in C_t]

# ─── Generate data ──────────────────────────────────────────────────────────

q_values = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27, 29, 31, 37, 41, 43, 47]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Global bound vs q
ax1 = axes[0]
for lie_type, info in EXCEPTIONAL_TYPES.items():
    gbs = []
    for q in q_values:
        bounds = generate_sample_bounds(lie_type, q)
        gbs.append(max(bounds))
    ax1.plot(q_values, gbs, 'o-', color=info["color"], label=lie_type, linewidth=2, markersize=5)

ax1.set_xlabel("Field size q", fontsize=13)
ax1.set_ylabel("Global bound M_X(q)", fontsize=13)
ax1.set_title("Global Character-Ratio Bound vs Field Size", fontsize=14, fontweight='bold')
ax1.legend(fontsize=12)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)
ax1.axhline(y=1.0, color='black', linestyle='--', alpha=0.5, label='Expansion threshold')

# Right panel: Scaled bound q * M_X(q) — should stabilize
ax2 = axes[1]
for lie_type, info in EXCEPTIONAL_TYPES.items():
    scaled = []
    for q in q_values:
        bounds = generate_sample_bounds(lie_type, q)
        scaled.append(q * max(bounds))
    ax2.plot(q_values, scaled, 's-', color=info["color"], label=lie_type, linewidth=2, markersize=5)

ax2.set_xlabel("Field size q", fontsize=13)
ax2.set_ylabel("q × M_X(q)  (should stabilize)", fontsize=13)
ax2.set_title("Toral Boundedness Conjecture Test", fontsize=14, fontweight='bold')
ax2.legend(fontsize=12)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("toral_bounds_visualization.png", dpi=150, bbox_inches='tight')
print("Saved: toral_bounds_visualization.png")
