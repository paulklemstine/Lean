"""
Applications of Entropy Barrier Theory to Resolution Proof Complexity.

Demonstrates real-world applications:
1. Predicting SAT solver hardness from entropy profiles
2. Comparing formula families by barrier strength
3. Free-energy phase transition detection
"""

import math
from algorithms import (
    php_cnf, random_3sat, estimate_width_entropy_profile,
    detect_entropy_barrier, free_energy, free_energy_barrier_height,
    crossing_time_lower_bound, clause_space_bound, Literal
)


def application_1_php_barrier_analysis():
    """
    Application 1: Entropy Barrier Analysis for the Pigeonhole Principle.

    For PHP(n+1, n) with small n, compute the width-entropy profile,
    detect the barrier, and predict proof length lower bounds.
    """
    print("=" * 70)
    print("APPLICATION 1: PHP Entropy Barrier Analysis")
    print("=" * 70)
    print()

    for n in range(3, 8):
        m = n + 1
        n_vars = m * n
        cnf = php_cnf(m, n)

        # Limit width to keep computation feasible
        max_w = min(n + 2, n_vars)

        print(f"PHP({m},{n}): {len(cnf)} clauses, {n_vars} variables")

        profile = estimate_width_entropy_profile(cnf, n_vars, max_width=max_w)

        print(f"  Width-entropy profile P(w):")
        for w, p in enumerate(profile):
            bar = "█" * int(p * 3)
            print(f"    w={w:2d}: P={p:6.2f} {bar}")

        barrier = detect_entropy_barrier(profile, w0=2, threshold=0.7)
        if barrier:
            print(f"  Barrier detected at w*={barrier.w_star}, "
                  f"gap_ratio={barrier.gap_ratio:.4f}, "
                  f"strength={barrier.barrier_strength:.4f}")

            # Predict lower bound
            delta_estimate = math.log2(n_vars + 1)  # heuristic growth bound
            A = profile[barrier.w_star]
            B = profile[barrier.w_max]
            lb = crossing_time_lower_bound(A, B, delta_estimate)
            print(f"  Predicted crossing time lower bound: {lb:.1f} steps")
        else:
            print("  No barrier detected (profile too smooth)")

        print()


def application_2_random_sat_phase_transition():
    """
    Application 2: Free-Energy Phase Transition in Random 3-SAT.

    Generate random 3-SAT at different clause densities and observe
    how the free-energy landscape changes near the threshold.
    """
    print("=" * 70)
    print("APPLICATION 2: Random 3-SAT Phase Transition")
    print("=" * 70)
    print()

    n_vars = 8
    densities = [2.0, 3.0, 4.0, 4.267, 5.0, 6.0]

    for alpha in densities:
        n_clauses = int(alpha * n_vars)
        cnf = random_3sat(n_vars, n_clauses, seed=42)
        max_w = min(6, n_vars)

        profile = estimate_width_entropy_profile(cnf, n_vars, max_width=max_w)

        print(f"Random 3-SAT: α={alpha:.3f}, {n_clauses} clauses, {n_vars} vars")

        # Compute free-energy for several β values
        for beta in [0.5, 1.0, 2.0]:
            fe = free_energy(beta, profile)
            barrier_h = free_energy_barrier_height(fe)
            print(f"  β={beta:.1f}: F_β = {[f'{x:.2f}' for x in fe]}")
            print(f"         barrier height = {barrier_h:.2f}")

        barrier = detect_entropy_barrier(profile, threshold=0.6)
        if barrier:
            print(f"  Entropy barrier at w*={barrier.w_star}, "
                  f"ratio={barrier.gap_ratio:.3f}")
        else:
            print(f"  No significant entropy barrier detected")
        print()


def application_3_clause_space_comparison():
    """
    Application 3: Clause Space Bounds Across Formula Families.

    Compare the theoretical clause space bound with actual derivable
    clauses to measure "entropy utilization" — what fraction of the
    theoretical space is actually reachable.
    """
    print("=" * 70)
    print("APPLICATION 3: Clause Space Utilization")
    print("=" * 70)
    print()

    print("Theoretical clause space bounds (all possible clauses):")
    print(f"  {'n':>4s} {'w':>4s} {'bound':>12s} {'log2':>8s}")
    print(f"  {'-'*4:>4s} {'-'*4:>4s} {'-'*12:>12s} {'-'*8:>8s}")

    for n in range(3, 10):
        for w in [1, n // 2, n]:
            bound = clause_space_bound(n, w)
            log_bound = math.log2(bound) if bound > 0 else 0
            print(f"  {n:4d} {w:4d} {bound:12d} {log_bound:8.2f}")
    print()

    # Compare with actual derivable clauses for PHP
    print("PHP entropy utilization (derivable / possible at each width):")
    for n in range(3, 6):
        m = n + 1
        n_vars = m * n
        cnf = php_cnf(m, n)
        max_w = min(n + 1, n_vars)

        profile = estimate_width_entropy_profile(cnf, n_vars, max_width=max_w)

        print(f"\n  PHP({m},{n}):")
        for w in range(max_w + 1):
            theoretical = math.log2(clause_space_bound(n_vars, w)) if clause_space_bound(n_vars, w) > 0 else 0
            actual = profile[w]
            utilization = actual / theoretical if theoretical > 0 else 0
            print(f"    w={w:2d}: actual={actual:6.2f}, "
                  f"theoretical={theoretical:6.2f}, "
                  f"utilization={utilization:.4f}")


def application_4_barrier_strength_ranking():
    """
    Application 4: Ranking Formula Families by Barrier Strength.

    The entropy barrier framework predicts that families with stronger
    barriers should have longer minimal proofs. We test this by
    computing barrier strength for several families and comparing
    with known complexity results.
    """
    print("=" * 70)
    print("APPLICATION 4: Barrier Strength Ranking")
    print("=" * 70)
    print()

    results = []

    # PHP family
    for n in range(3, 7):
        m = n + 1
        n_vars = m * n
        cnf = php_cnf(m, n)
        max_w = min(n + 1, n_vars)
        profile = estimate_width_entropy_profile(cnf, n_vars, max_width=max_w)
        barrier = detect_entropy_barrier(profile, w0=1, threshold=0.8)
        strength = barrier.barrier_strength if barrier else 0.0
        results.append((f"PHP({m},{n})", strength, f"known: 2^Ω(n)={2**n}"))

    # Random 3-SAT at different densities
    n_vars = 8
    for alpha in [3.0, 4.267, 6.0]:
        n_clauses = int(alpha * n_vars)
        cnf = random_3sat(n_vars, n_clauses, seed=123)
        profile = estimate_width_entropy_profile(cnf, n_vars, max_width=6)
        barrier = detect_entropy_barrier(profile, threshold=0.8)
        strength = barrier.barrier_strength if barrier else 0.0
        results.append((f"Rand3SAT(α={alpha})", strength, "empirical"))

    # Sort by barrier strength
    results.sort(key=lambda x: x[1], reverse=True)

    print(f"{'Family':<25s} {'Barrier Strength':>18s} {'Known Complexity':<20s}")
    print("-" * 65)
    for name, strength, known in results:
        print(f"{name:<25s} {strength:18.4f} {known:<20s}")
    print()
    print("Prediction: higher barrier strength → harder for resolution")


if __name__ == "__main__":
    application_1_php_barrier_analysis()
    print("\n")
    application_2_random_sat_phase_transition()
    print("\n")
    application_3_clause_space_comparison()
    print("\n")
    application_4_barrier_strength_ranking()


#!/usr/bin/env python3
"""
Interactive demonstration of Entropy Barrier Theory for Resolution Proof Complexity.

This demo:
1. Generates CNF formula families (PHP, random 3-SAT)
2. Estimates width-entropy profiles
3. Detects entropy barriers
4. Computes free-energy landscapes
5. Visualizes results with ASCII art
6. Compares barrier diagnostics across families

Run: python demo.py
"""

import math
import random as stdlib_random
from dataclasses import dataclass
from typing import Optional


# ============================================================
# Core data structures
# ============================================================

@dataclass(frozen=True)
class Literal:
    var: int
    positive: bool

    def __neg__(self):
        return Literal(self.var, not self.positive)

    def __repr__(self):
        return f"x{self.var}" if self.positive else f"~x{self.var}"


def resolve(c1, c2, var):
    pos_lit = Literal(var, True)
    neg_lit = Literal(var, False)
    if pos_lit in c1 and neg_lit in c2:
        result = (c1 - {pos_lit}) | (c2 - {neg_lit})
        vars_pos = {l.var for l in result if l.positive}
        vars_neg = {l.var for l in result if not l.positive}
        if vars_pos & vars_neg:
            return None
        return result
    return None


def php_cnf(m, n):
    clauses = set()
    for i in range(m):
        clause = frozenset(Literal(i * n + j, True) for j in range(n))
        clauses.add(clause)
    for j in range(n):
        for i1 in range(m):
            for i2 in range(i1 + 1, m):
                clauses.add(frozenset([
                    Literal(i1 * n + j, False),
                    Literal(i2 * n + j, False)
                ]))
    return clauses


def bounded_width_saturation(cnf, max_width, n_vars, max_clauses=5000, max_iters=2):
    derived = set()
    for c in cnf:
        if len(c) <= max_width:
            derived.add(c)

    iteration = 0
    changed = True
    while changed and iteration < max_iters:
        iteration += 1
        changed = False
        new_clauses = set()
        derived_list = list(derived)
        for c1 in derived_list:
            for c2 in derived_list:
                for v in range(n_vars):
                    r = resolve(c1, c2, v)
                    if r is not None and len(r) <= max_width and r not in derived:
                        new_clauses.add(r)
                        if len(new_clauses) > 1000:
                            break
                if len(new_clauses) > 1000:
                    break
            if len(new_clauses) > 1000:
                break
        if new_clauses:
            derived |= new_clauses
            changed = True
            if len(derived) > max_clauses:
                break
    return derived


def estimate_profile(cnf, n_vars, max_width=None):
    if max_width is None:
        max_width = n_vars
    profile = []
    for w in range(max_width + 1):
        derived = bounded_width_saturation(cnf, w, n_vars)
        count = max(len(derived), 1)
        profile.append(math.log2(count))
    return profile


def free_energy_landscape(beta, profile):
    return [beta * w - profile[w] for w in range(len(profile))]


def clause_space_bound(n, w):
    total = 0
    for k in range(min(w, n) + 1):
        total += math.comb(n, k) * (2 ** k)
    return total


# ============================================================
# ASCII visualization
# ============================================================

def ascii_bar_chart(values, labels, title, width=50, char="█"):
    print(f"\n  {title}")
    print(f"  {'─' * (width + 20)}")
    max_val = max(abs(v) for v in values) if values else 1
    if max_val == 0:
        max_val = 1
    for label, val in zip(labels, values):
        bar_len = int(abs(val) / max_val * width)
        bar = char * bar_len
        print(f"  {label:>6s} │{bar} {val:.2f}")
    print()


def ascii_dual_chart(profile, fe_landscape, title):
    print(f"\n  {title}")
    print(f"  {'─' * 70}")
    max_p = max(profile) if profile else 1
    max_fe = max(abs(v) for v in fe_landscape) if fe_landscape else 1
    if max_p == 0: max_p = 1
    if max_fe == 0: max_fe = 1

    for w in range(len(profile)):
        p_bar = "█" * int(profile[w] / max_p * 20)
        fe_val = fe_landscape[w]
        if fe_val >= 0:
            fe_bar = "▓" * int(fe_val / max_fe * 20)
        else:
            fe_bar = "░" * int(-fe_val / max_fe * 20)
        print(f"  w={w:2d} │ P={profile[w]:5.1f} {p_bar:<22s} │ F={fe_val:6.1f} {fe_bar}")
    print()


# ============================================================
# Demo sections
# ============================================================

def demo_1_entropy_profiles():
    """Demonstrate width-entropy profiles for PHP."""
    print("╔" + "═" * 68 + "╗")
    print("║  DEMO 1: Width-Entropy Profiles for Pigeonhole Principle          ║")
    print("╚" + "═" * 68 + "╝")
    print()
    print("  The pigeonhole principle PHP(n+1, n) states that n+1 pigeons")
    print("  cannot be placed into n holes without collision.")
    print()
    print("  We compute the width-entropy profile P(w) = log₂(|derivable")
    print("  clauses of width ≤ w|) and look for entropy deserts.")
    print()

    for n in range(3, 6):
        m = n + 1
        n_vars = m * n
        cnf = php_cnf(m, n)
        max_w = min(n, n_vars)

        profile = estimate_profile(cnf, n_vars, max_width=max_w)

        labels = [f"w={w}" for w in range(len(profile))]
        ascii_bar_chart(profile, labels,
                       f"PHP({m},{n}): Entropy Profile (log₂ of derivable clauses)")

        # Detect barrier
        if len(profile) > 2 and profile[-1] > 0:
            for w in range(1, len(profile) - 1):
                ratio = profile[w] / profile[-1]
                if ratio < 0.7:
                    print(f"  ⚠ Entropy barrier detected at w={w}: "
                          f"P({w})/P({len(profile)-1}) = {ratio:.3f}")
                    break


def demo_2_free_energy():
    """Demonstrate free-energy landscapes."""
    print("\n╔" + "═" * 68 + "╗")
    print("║  DEMO 2: Free-Energy Landscapes                                  ║")
    print("╚" + "═" * 68 + "╝")
    print()
    print("  The free-energy F_β(w) = β·w - P(w) combines energetic cost")
    print("  (width) with entropic gain (derivable clauses).")
    print("  A barrier in F_β corresponds to a phase transition.")
    print()

    n = 4
    m = n + 1
    n_vars = m * n
    cnf = php_cnf(m, n)
    max_w = min(n + 1, n_vars)

    profile = estimate_profile(cnf, n_vars, max_width=max_w)

    for beta in [0.5, 1.0, 2.0]:
        fe = free_energy_landscape(beta, profile)
        ascii_dual_chart(profile, fe,
                        f"PHP({m},{n}): β={beta} — Entropy (█) vs Free-Energy (▓/░)")

        barrier_h = max(fe) - min(fe)
        print(f"  Free-energy barrier height: {barrier_h:.2f}")
        print(f"  Peak at w={fe.index(max(fe))}, trough at w={fe.index(min(fe))}")
        print()


def demo_3_crossing_bound():
    """Demonstrate the crossing time lower bound."""
    print("\n╔" + "═" * 68 + "╗")
    print("║  DEMO 3: Crossing Time Lower Bounds                              ║")
    print("╚" + "═" * 68 + "╝")
    print()
    print("  If a step-bounded process starts at entropy A and must reach")
    print("  entropy B, it needs at least (B-A)/Δ steps.")
    print()
    print("  This is the abstract engine: entropy gaps → proof length bounds.")
    print()

    print(f"  {'A':>6s} {'B':>6s} {'Δ':>6s} {'(B-A)/Δ':>10s}  Interpretation")
    print(f"  {'─'*6} {'─'*6} {'─'*6} {'─'*10}  {'─'*30}")

    test_cases = [
        (0, 10, 1.0, "10 steps minimum"),
        (0, 100, 2.0, "50 steps minimum"),
        (5, 20, 0.5, "30 steps minimum"),
        (0, 50, 0.1, "500 steps minimum (tight bottleneck)"),
    ]

    for A, B, delta, desc in test_cases:
        lb = (B - A) / delta
        print(f"  {A:6.1f} {B:6.1f} {delta:6.2f} {lb:10.1f}  {desc}")


def demo_4_barrier_comparison():
    """Compare barrier strength across formula families using synthetic estimates."""
    print("\n╔" + "═" * 68 + "╗")
    print("║  DEMO 4: Barrier Strength Comparison                             ║")
    print("╚" + "═" * 68 + "╝")
    print()
    print("  We compare estimated entropy barriers across formula families.")
    print("  Stronger barriers → harder for resolution.")
    print()

    # Use theoretical/heuristic estimates instead of expensive computation
    results = []

    # PHP: known to have exponential lower bounds
    for n in range(3, 10):
        # Theoretical: PHP(n+1,n) has width lower bound n
        # At low widths, only at-most-one clauses (width 2) are derivable
        # At width n, all at-least-one clauses become available
        # Estimated profile: sharp jump at width n
        low_entropy = math.log2(max(n * (n + 1) // 2, 1))  # width-2 clauses
        high_entropy = n * math.log2(3)  # all clauses at width n
        if high_entropy > 0:
            gap_ratio = low_entropy / high_entropy
            strength = 1.0 - gap_ratio
        else:
            strength = 0.0
        results.append((f"PHP({n+1},{n})", strength, f"2^Ω({n})"))

    # Random 3-SAT at different densities (heuristic estimates)
    for alpha, desc in [(2.0, "easy"), (4.267, "threshold"), (6.0, "hard")]:
        # Heuristic: barrier strength increases with density
        strength = min(alpha / 10.0, 0.9)
        results.append((f"R3SAT(α={alpha})", strength, desc))

    results.sort(key=lambda x: x[1], reverse=True)

    print(f"  {'Family':<20s} {'Barrier Strength':>18s} {'Known':>12s}")
    print(f"  {'─'*20} {'─'*18} {'─'*12}")

    for name, strength, known in results:
        bar = "█" * int(strength * 40)
        print(f"  {name:<20s} {strength:18.4f} {known:>12s}  {bar}")

    print()
    print("  Prediction: higher barrier strength → harder for resolution")


def demo_5_clause_space():
    """Demonstrate clause space bounds."""
    print("\n╔" + "═" * 68 + "╗")
    print("║  DEMO 5: Clause Space Bounds                                     ║")
    print("╚" + "═" * 68 + "╝")
    print()
    print("  The theoretical clause space bound counts all possible clauses")
    print("  of width ≤ w over n variables: ∑_{k=0}^{w} C(n,k)·2^k")
    print()
    print("  Key identity (proved in Lean): clauseSpaceBound(n, n) = 3^n")
    print()

    print(f"  {'n':>4s} {'w':>4s} {'bound':>12s} {'log₂':>8s} {'3^n':>10s}")
    print(f"  {'─'*4} {'─'*4} {'─'*12} {'─'*8} {'─'*10}")

    for n in range(2, 9):
        for w in [0, n // 2, n]:
            bound = clause_space_bound(n, w)
            log_b = math.log2(bound) if bound > 0 else 0
            three_n = 3 ** n if w == n else ""
            check = " ✓" if w == n and bound == 3 ** n else ""
            print(f"  {n:4d} {w:4d} {bound:12d} {log_b:8.2f} {str(three_n):>10s}{check}")


def demo_6_abstract_resolution_system():
    """Demonstrate the abstract resolution system concept."""
    print("\n╔" + "═" * 68 + "╗")
    print("║  DEMO 6: Abstract Resolution System                              ║")
    print("╚" + "═" * 68 + "╝")
    print()
    print("  An AbstractResolutionSystem bundles:")
    print("    • accessibleEntropy(F, t): entropy reachable in t steps")
    print("    • terminalEntropy(F): entropy needed for refutation")
    print("    • growthBound(F): max entropy increase per step")
    print()
    print("  The entropy_barrier_lower_bound theorem says:")
    print("    T ≥ (terminalEntropy - A₀) / growthBound")
    print()

    print("  Simulated abstract system for PHP:")
    print(f"  {'n':>4s} {'A₀':>8s} {'B':>8s} {'Δ':>8s} {'T_min':>10s} {'Known':>10s}")
    print(f"  {'─'*4} {'─'*8} {'─'*8} {'─'*8} {'─'*10} {'─'*10}")

    for n in range(3, 12):
        n_initial = (n + 1) + n * n * (n + 1) // 2
        A0 = math.log2(max(n_initial, 1))
        B = n * math.log2(3)
        delta = math.log2(max(n * (n + 1), 2))
        T_min = (B - A0) / delta if delta > 0 else float('inf')
        known = f"≥{n+1}"

        print(f"  {n:4d} {A0:8.2f} {B:8.2f} {delta:8.2f} {T_min:10.2f} {known:>10s}")


def main():
    print()
    print("  ╔═══════════════════════════════════════════════════════╗")
    print("  ║  ENTROPY BARRIER THEORY FOR RESOLUTION LOWER BOUNDS  ║")
    print("  ║  Interactive Demonstration                           ║")
    print("  ╚═══════════════════════════════════════════════════════╝")
    print()
    print("  This demo explores the connection between entropy profiles")
    print("  of CNF formulas and the hardness of resolution proofs.")
    print()
    print("  Key insight: an 'entropy desert' at intermediate clause")
    print("  widths forces exponentially long proofs.")
    print()

    demo_1_entropy_profiles()
    demo_2_free_energy()
    demo_3_crossing_bound()
    demo_4_barrier_comparison()
    demo_5_clause_space()
    demo_6_abstract_resolution_system()

    print("\n" + "=" * 70)
    print("  Demo complete. Key takeaways:")
    print("  1. Entropy profiles are monotone (formally proved)")
    print("  2. Entropy deserts at intermediate widths predict hard instances")
    print("  3. Free-energy barriers quantify phase transitions in proof search")
    print("  4. The crossing time lower bound is the abstract engine for")
    print("     converting entropy gaps into proof-length lower bounds")
    print("=" * 70)


if __name__ == "__main__":
    main()
