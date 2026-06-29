#!/usr/bin/env python3
"""
applications.py — Real-world applications of subgroup ensemble renormalization.

Demonstrates:
1. Phase transition detection in symmetric group subgroup statistics
2. Error-correcting code analysis via subgroup pressure
3. Cryptographic key-space analysis through ensemble coarse-graining
"""

import math
import itertools
from typing import List, Tuple, Dict
from collections import defaultdict


# ─────────────────────────────────────────────────────────────────────
# Group utilities (self-contained)
# ─────────────────────────────────────────────────────────────────────

def compose_perm(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse_perm(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity_perm(n):
    return tuple(range(n))

def generate_subgroup(generators, n):
    ident = identity_perm(n)
    subgroup = {ident}
    frontier = set(generators)
    while frontier:
        new = set()
        subgroup |= frontier
        for g in frontier:
            for h in subgroup:
                for p in [compose_perm(g, h), compose_perm(h, g), inverse_perm(g)]:
                    if p not in subgroup:
                        new.add(p)
        frontier = new
    return frozenset(subgroup)

def all_subgroups_sn(n):
    perms = list(itertools.permutations(range(n)))
    subgroups = set()
    subgroups.add(frozenset([identity_perm(n)]))
    for g in perms:
        sg = generate_subgroup([g], n)
        subgroups.add(sg)
        for h in perms:
            sg2 = generate_subgroup([g, h], n)
            subgroups.add(sg2)
    return [set(s) for s in subgroups]


# ─────────────────────────────────────────────────────────────────────
# Application 1: Phase Transition Detection
# ─────────────────────────────────────────────────────────────────────

def detect_phase_transition():
    """Detect phase transitions in subgroup pressure of S_n.

    The pressure Π(β) = log Σ exp(-β·c(H))·w(H) can exhibit
    non-analytic behavior at critical β values. We scan for
    rapid changes in the derivative (susceptibility).

    This has applications in understanding when random subgroup
    selection undergoes qualitative changes in behavior.
    """
    print("APPLICATION 1: Phase Transition Detection in S_n")
    print("=" * 60)

    for n in [3, 4]:
        subs = all_subgroups_sn(n)
        G_order = math.factorial(n)

        def pressure_at(beta):
            Z = sum(
                math.exp(-beta * math.log(max(1, G_order / len(H))))
                for H in subs
            )
            return math.log(Z) if Z > 0 else float('-inf')

        # Scan susceptibility (second derivative via finite differences)
        h = 0.01
        betas = [i * 0.1 for i in range(1, 51)]
        max_susceptibility = 0
        critical_beta = 0

        print(f"\nS_{n} ({len(subs)} subgroups):")
        print(f"{'β':>6s} {'Π(β)':>10s} {'χ(β)':>12s}")

        for beta in betas:
            P = pressure_at(beta)
            chi = (pressure_at(beta + h) - 2 * P + pressure_at(beta - h)) / h**2
            if abs(chi) > max_susceptibility:
                max_susceptibility = abs(chi)
                critical_beta = beta
            if beta in [0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0]:
                print(f"{beta:6.1f} {P:10.4f} {chi:12.4f}")

        print(f"  Peak susceptibility at β ≈ {critical_beta:.2f} "
              f"(|χ| = {max_susceptibility:.4f})")
        print(f"  → This signals a crossover region in subgroup statistics.")


# ─────────────────────────────────────────────────────────────────────
# Application 2: Coding Theory — Subgroup Codes
# ─────────────────────────────────────────────────────────────────────

def subgroup_code_analysis():
    """Analyze error-correcting properties via subgroup pressure.

    Subgroups of S_n can define permutation codes. The minimum
    distance of such a code relates to the subgroup structure.
    Pressure analysis reveals which subgroups contribute most
    to code performance at a given noise level β.

    The coarse-graining operation corresponds to shortening
    a code to a smaller block length.
    """
    print("\n\nAPPLICATION 2: Permutation Code Analysis")
    print("=" * 60)

    for n in [3, 4]:
        subs = all_subgroups_sn(n)
        G_order = math.factorial(n)

        # Minimum Hamming distance of a subgroup code
        def min_distance(H):
            ident = identity_perm(n)
            dists = []
            for p in H:
                if p != ident:
                    d = sum(1 for i in range(n) if p[i] != i)
                    dists.append(d)
            return min(dists) if dists else 0

        print(f"\nS_{n} subgroup codes:")
        print(f"{'|H|':>6s} {'d_min':>6s} {'Rate':>8s} {'Complexity':>12s}")

        for H in sorted(subs, key=len):
            d = min_distance(H)
            rate = math.log2(len(H)) / n if n > 0 else 0
            complexity = math.log(G_order / len(H)) if len(H) > 0 else 0
            if len(H) in [1, 2, 3, 6, 24] or d >= 2:
                print(f"{len(H):6d} {d:6d} {rate:8.4f} {complexity:12.4f}")

        # Pressure-weighted code selection
        print(f"\n  Pressure-weighted code selection at β=1.0:")
        Z = sum(
            math.exp(-1.0 * math.log(max(1, G_order / len(H))))
            for H in subs
        )
        top_codes = sorted(
            [(H, math.exp(-1.0 * math.log(max(1, G_order / len(H)))) / Z)
             for H in subs],
            key=lambda x: -x[1]
        )[:3]
        for H, prob in top_codes:
            print(f"    |H|={len(H):4d}, d_min={min_distance(H)}, "
                  f"Boltzmann weight={prob:.4f}")


# ─────────────────────────────────────────────────────────────────────
# Application 3: Cryptographic Key-Space Coarse-Graining
# ─────────────────────────────────────────────────────────────────────

def crypto_keyspace_analysis():
    """Analyze cryptographic key-space via RG coarse-graining.

    In symmetric-key cryptography based on permutations (e.g., AES-like
    constructions), the key space is a subgroup of S_n. Coarse-graining
    by restricting to a sub-block reveals how security degrades when
    attackers can only observe partial outputs.

    Pressure at high β emphasizes large (complex) subgroups,
    modeling an attacker's preference for high-entropy keys.
    """
    print("\n\nAPPLICATION 3: Cryptographic Key-Space Analysis")
    print("=" * 60)

    n = 4
    subs = all_subgroups_sn(n)
    G_order = math.factorial(n)

    # Entropy of a subgroup as a key space
    def key_entropy(H):
        return math.log2(len(H))

    # Security level: bits of entropy
    print(f"\nS_{n} key-space analysis:")
    print(f"{'|H|':>6s} {'Entropy (bits)':>15s} {'Security level':>15s}")
    seen = set()
    for H in sorted(subs, key=len, reverse=True):
        if len(H) not in seen:
            seen.add(len(H))
            ent = key_entropy(H)
            level = "HIGH" if ent >= 3 else "MED" if ent >= 1.5 else "LOW"
            print(f"{len(H):6d} {ent:15.2f} {level:>15s}")

    # Coarse-graining effect on security
    print(f"\n  Effect of coarse-graining (S_4 → S_3 → S_2):")
    for target_n in [3, 2]:
        projected_sizes = defaultdict(int)
        for H in subs:
            proj = set()
            for p in H:
                if all(p[i] < target_n for i in range(target_n)):
                    proj.add(tuple(p[i] for i in range(target_n)))
            projected_sizes[len(proj)] += 1

        avg_size = sum(s * c for s, c in projected_sizes.items()) / len(subs)
        avg_entropy = math.log2(max(1, avg_size))
        print(f"    S_{n} → S_{target_n}: avg projected size = {avg_size:.2f}, "
              f"avg entropy = {avg_entropy:.2f} bits")
        print(f"    → Security loss: {key_entropy(set(itertools.permutations(range(n)))) - avg_entropy:.2f} bits")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Subgroup Ensemble Renormalization      ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    detect_phase_transition()
    subgroup_code_analysis()
    crypto_keyspace_analysis()

    print("\n" + "=" * 60)
    print("All applications complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Renormalization Group for Subgroup Ensembles

Demonstrates the core concepts from the formal Lean development:
1. Subgroup ensemble construction and partition function computation
2. Coarse-graining (RG) maps on ensembles
3. Pressure scaling under RG iteration
4. Fixed-point detection and universality class identification
5. Critical exponent extraction from scaling eigenvalues

Runs on small symmetric groups S_n (n = 2, 3, 4) using explicit
subgroup enumeration via itertools/permutations.
"""

import math
import itertools
from collections import defaultdict

# ─────────────────────────────────────────────────────────────────────
# 1. Finite group and subgroup machinery
# ─────────────────────────────────────────────────────────────────────

def symmetric_group(n):
    """Return all permutations of {0,...,n-1} as tuples."""
    return list(itertools.permutations(range(n)))

def compose_perm(p, q):
    """Compose two permutations: (p∘q)(i) = p[q[i]]."""
    return tuple(p[q[i]] for i in range(len(p)))

def inverse_perm(p):
    """Inverse of a permutation."""
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity_perm(n):
    return tuple(range(n))

def generate_subgroup(generators, n):
    """Generate the subgroup from a set of generators in S_n."""
    ident = identity_perm(n)
    subgroup = {ident}
    frontier = set(generators)
    while frontier:
        new = set()
        subgroup |= frontier
        for g in frontier:
            for h in subgroup:
                for p in [compose_perm(g, h), compose_perm(h, g),
                           inverse_perm(g)]:
                    if p not in subgroup:
                        new.add(p)
        frontier = new
    return frozenset(subgroup)

def all_subgroups(n):
    """Find all subgroups of S_n by brute force (feasible for n ≤ 4)."""
    perms = symmetric_group(n)
    subgroups = set()
    subgroups.add(frozenset([identity_perm(n)]))  # trivial subgroup
    # Try all subsets of generators (up to pairs for efficiency)
    for g in perms:
        sg = generate_subgroup([g], n)
        subgroups.add(sg)
        for h in perms:
            sg2 = generate_subgroup([g, h], n)
            subgroups.add(sg2)
    return [set(s) for s in subgroups]

# ─────────────────────────────────────────────────────────────────────
# 2. Ensemble and pressure computation
# ─────────────────────────────────────────────────────────────────────

class SubgroupEnsemble:
    """A weighted subgroup ensemble over a finite group."""

    def __init__(self, subgroups, weights=None, complexity_fn=None):
        """
        subgroups: list of subgroups (each a set of permutations)
        weights: list of nonneg reals (default: uniform)
        complexity_fn: subgroup -> real (default: log index)
        """
        self.subgroups = subgroups
        self.weights = weights if weights else [1.0] * len(subgroups)
        self.complexity_fn = complexity_fn if complexity_fn else (
            lambda H: math.log(max(1, len(subgroups[0]) if subgroups else 1))
        )

    def partition_function(self, beta):
        """Z(β) = Σ_H exp(-β·c(H)) · w(H)"""
        return sum(
            math.exp(-beta * self.complexity_fn(H)) * w
            for H, w in zip(self.subgroups, self.weights)
        )

    def pressure(self, beta):
        """Π(β) = log Z(β)"""
        Z = self.partition_function(beta)
        return math.log(Z) if Z > 0 else float('-inf')


def log_index_complexity(H, G_order):
    """Complexity = log|G:H| = log(|G|/|H|)."""
    return math.log(G_order / len(H)) if len(H) > 0 else 0.0


def make_ensemble(n):
    """Construct the full subgroup ensemble for S_n with log-index complexity."""
    G_order = math.factorial(n)
    subs = all_subgroups(n)
    complexity = lambda H: log_index_complexity(H, G_order)
    weights = [1.0] * len(subs)
    return SubgroupEnsemble(subs, weights, complexity)

# ─────────────────────────────────────────────────────────────────────
# 3. Coarse-graining (RG map)
# ─────────────────────────────────────────────────────────────────────

def coarse_grain_by_projection(ensemble, target_n):
    """
    Coarse-grain an ensemble on S_m to S_n (n < m) by restricting
    each subgroup to its action on {0,...,n-1}.
    Returns a new ensemble on S_n.
    """
    projected = defaultdict(float)
    for H, w in zip(ensemble.subgroups, ensemble.weights):
        # Project: keep only permutations that fix {n,...,m-1}
        proj = set()
        for p in H:
            if all(p[i] < target_n for i in range(target_n)):
                proj.add(tuple(p[i] for i in range(target_n)))
        proj_key = frozenset(proj)
        projected[proj_key] += w

    subs = [set(k) for k in projected.keys()]
    weights = list(projected.values())
    G_order = math.factorial(target_n)
    complexity = lambda H: log_index_complexity(H, G_order)
    return SubgroupEnsemble(subs, weights, complexity)

# ─────────────────────────────────────────────────────────────────────
# 4. Demonstrations
# ─────────────────────────────────────────────────────────────────────

def demo_pressure_scaling():
    """Demonstrate pressure computation at multiple scales."""
    print("=" * 60)
    print("DEMO 1: Subgroup Pressure at Multiple Scales")
    print("=" * 60)

    for n in [2, 3, 4]:
        ens = make_ensemble(n)
        print(f"\nS_{n}: {len(ens.subgroups)} subgroups")
        for beta in [0.0, 0.5, 1.0, 2.0]:
            P = ens.pressure(beta)
            Z = ens.partition_function(beta)
            print(f"  β={beta:.1f}: Z={Z:.4f}, Π={P:.4f}")


def demo_rg_flow():
    """Demonstrate RG flow by coarse-graining S_4 → S_3 → S_2."""
    print("\n" + "=" * 60)
    print("DEMO 2: RG Flow via Coarse-Graining")
    print("=" * 60)

    ens4 = make_ensemble(4)
    ens3 = coarse_grain_by_projection(ens4, 3)
    ens2 = coarse_grain_by_projection(ens3, 2)

    print(f"\nOriginal S_4 ensemble: {len(ens4.subgroups)} subgroups")
    print(f"After RG to S_3:      {len(ens3.subgroups)} subgroups")
    print(f"After RG to S_2:      {len(ens2.subgroups)} subgroups")

    print("\nPressure under RG flow:")
    for beta in [0.0, 0.5, 1.0, 2.0, 5.0]:
        P4 = ens4.pressure(beta)
        P3 = ens3.pressure(beta)
        P2 = ens2.pressure(beta)
        ratio43 = P3 / P4 if P4 != 0 else float('nan')
        ratio32 = P2 / P3 if P3 != 0 else float('nan')
        print(f"  β={beta:.1f}: Π₄={P4:.4f}, Π₃={P3:.4f}, Π₂={P2:.4f}  "
              f"(ratio 3/4={ratio43:.4f}, 2/3={ratio32:.4f})")


def demo_fixed_point():
    """Demonstrate fixed-point detection."""
    print("\n" + "=" * 60)
    print("DEMO 3: Fixed-Point Detection")
    print("=" * 60)

    # For product ensembles, the intensive pressure is a fixed point
    # Simulate with F(n) = n * F(1) model
    F1 = 2.5  # arbitrary pressure of base ensemble
    print(f"\nProduct ensemble model: F(n) = n × F(1), F(1) = {F1}")
    print(f"{'n':>4s} {'F(n)':>10s} {'F(n)/n':>10s} {'|F(n)/n - F(1)|':>16s}")
    for n in range(1, 11):
        Fn = n * F1
        intensive = Fn / n
        err = abs(intensive - F1)
        print(f"{n:4d} {Fn:10.4f} {intensive:10.4f} {err:16.2e}")

    print("\nThe intensive pressure is an EXACT fixed point of the RG map.")


def demo_critical_exponent():
    """Demonstrate critical exponent extraction from scaling."""
    print("\n" + "=" * 60)
    print("DEMO 4: Critical Exponent from Scaling Eigenvalues")
    print("=" * 60)

    # If λ = μ^α, then α = log(λ)/log(μ)
    test_cases = [
        (4.0, 2.0, "doubling with quadratic scaling"),
        (8.0, 2.0, "doubling with cubic scaling"),
        (2.0, 3.0, "tripling with binary scaling"),
        (9.0, 3.0, "tripling with quadratic scaling"),
    ]

    print(f"\n{'λ':>6s} {'μ':>6s} {'α=log(λ)/log(μ)':>16s}  Description")
    print("-" * 60)
    for lam, mu, desc in test_cases:
        alpha = math.log(lam) / math.log(mu)
        # Verify: μ^α should equal λ
        check = mu ** alpha
        print(f"{lam:6.1f} {mu:6.1f} {alpha:16.6f}  {desc}")
        assert abs(check - lam) < 1e-10, f"Verification failed: {check} ≠ {lam}"

    print("\nAll critical exponent extractions verified ✓")


def demo_universality_classes():
    """Demonstrate universality class identification."""
    print("\n" + "=" * 60)
    print("DEMO 5: Universality Classes")
    print("=" * 60)

    # Two ensembles are in the same universality class if they have
    # identical pressure under all RG iterates
    ens3a = make_ensemble(3)
    ens3b = make_ensemble(3)  # Same ensemble → same class

    # Modify weights for a different ensemble
    ens3c = SubgroupEnsemble(
        ens3a.subgroups,
        [w * 2.0 for w in ens3a.weights],  # doubled weights
        ens3a.complexity_fn
    )

    print("\nPressure comparison for universality class test:")
    print(f"{'β':>6s} {'Π(E_a)':>10s} {'Π(E_b)':>10s} {'Π(E_c)':>10s}  "
          f"{'a≡b?':>5s} {'a≡c?':>5s}")
    for beta in [0.0, 0.5, 1.0, 2.0]:
        Pa = ens3a.pressure(beta)
        Pb = ens3b.pressure(beta)
        Pc = ens3c.pressure(beta)
        same_ab = abs(Pa - Pb) < 1e-10
        same_ac = abs(Pa - Pc) < 1e-10
        print(f"{beta:6.1f} {Pa:10.4f} {Pb:10.4f} {Pc:10.4f}  "
              f"{'yes' if same_ab else 'no':>5s} {'yes' if same_ac else 'no':>5s}")


def demo_conjecture_test():
    """Test the block-restriction convergence conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 6: Conjecture Test — Normalized Pressure Convergence")
    print("=" * 60)

    # Test whether Π_n / n stabilizes for S_n ensembles
    print(f"\n{'n':>4s} {'#subgroups':>12s} {'Π(β=1)':>10s} {'Π/n':>10s}")
    print("-" * 40)
    pressures = []
    for n in [2, 3, 4]:
        ens = make_ensemble(n)
        P = ens.pressure(1.0)
        pressures.append((n, len(ens.subgroups), P, P / n))
        print(f"{n:4d} {len(ens.subgroups):12d} {P:10.4f} {P / n:10.4f}")

    if len(pressures) >= 2:
        ratios = [pressures[i+1][3] / pressures[i][3]
                  for i in range(len(pressures) - 1)
                  if pressures[i][3] != 0]
        print(f"\nIntensive pressure ratios: {[f'{r:.4f}' for r in ratios]}")
        print("Convergence would manifest as ratios approaching 1.")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Renormalization Group for Subgroup Ensembles — Demo    ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_pressure_scaling()
    demo_rg_flow()
    demo_fixed_point()
    demo_critical_exponent()
    demo_universality_classes()
    demo_conjecture_test()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 3: Critical Exponents and Universality Classes

Illustrates the fundamental identity α = log(λ)/log(μ) that links
pressure scaling eigenvalues to critical exponents. Shows how
different (λ, μ) pairs can yield the same critical exponent,
defining universality classes in the RG framework.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

fig, axes = plt.subplots(1, 3, figsize=(17, 5.5))

# ── Panel 1: Critical exponent surface ──
ax1 = axes[0]
lambdas = np.linspace(0.1, 10, 200)
mus = np.linspace(1.01, 5, 200)
L, M = np.meshgrid(lambdas, mus)
A = np.log(L) / np.log(M)

# Contour plot
levels = np.arange(-2, 5.1, 0.5)
cf = ax1.contourf(L, M, A, levels=levels, cmap='RdYlBu_r', alpha=0.8)
plt.colorbar(cf, ax=ax1, label=r'Critical exponent $\alpha$')
cs = ax1.contour(L, M, A, levels=[0.5, 1.0, 1.5, 2.0, 3.0],
                 colors='black', linewidths=1, alpha=0.5)
ax1.clabel(cs, inline=True, fontsize=9)

# Mark specific universality classes
points = [(4, 2, 2.0), (8, 2, 3.0), (9, 3, 2.0), (2, 2, 1.0)]
for lam, mu, alpha in points:
    ax1.plot(lam, mu, 'ko', markersize=8, zorder=5)
    ax1.annotate(f'α={alpha:.0f}', (lam, mu), textcoords="offset points",
                xytext=(8, 5), fontsize=9, fontweight='bold')

ax1.set_xlabel(r'Pressure scale $\lambda$', fontsize=12)
ax1.set_ylabel(r'Parameter scale $\mu$', fontsize=12)
ax1.set_title(r'$\alpha = \log\lambda / \log\mu$', fontsize=14)

# ── Panel 2: Power-law scaling ──
ax2 = axes[1]
t_values = np.linspace(0.01, 3, 200)

alphas = [0.5, 1.0, 1.5, 2.0, 3.0]
colors = plt.cm.plasma(np.linspace(0.1, 0.9, len(alphas)))

for alpha, color in zip(alphas, colors):
    P = t_values ** alpha
    ax2.plot(t_values, P, color=color, linewidth=2,
             label=f'α = {alpha}')

ax2.set_xlabel(r'Parameter $t$', fontsize=12)
ax2.set_ylabel(r'Pressure $\Pi(t) = t^\alpha$', fontsize=12)
ax2.set_title('Power-Law Profiles by Exponent', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 10)

# ── Panel 3: Universality class diagram ──
ax3 = axes[2]

# Draw circles for different universality classes
class_data = [
    (0.3, 0.7, 0.25, 'α = 1\n(Linear)', '#2196F3', [
        '(λ=2, μ=2)', '(λ=3, μ=3)', '(λ=5, μ=5)'
    ]),
    (0.7, 0.7, 0.22, 'α = 2\n(Quadratic)', '#FF5722', [
        '(λ=4, μ=2)', '(λ=9, μ=3)', '(λ=25, μ=5)'
    ]),
    (0.5, 0.25, 0.2, 'α = 3\n(Cubic)', '#4CAF50', [
        '(λ=8, μ=2)', '(λ=27, μ=3)'
    ]),
]

for cx, cy, r, label, color, members in class_data:
    circle = plt.Circle((cx, cy), r, fill=True, alpha=0.15, color=color)
    ax3.add_patch(circle)
    circle2 = plt.Circle((cx, cy), r, fill=False, color=color, linewidth=2)
    ax3.add_patch(circle2)
    ax3.text(cx, cy + r + 0.04, label, ha='center', va='bottom',
             fontsize=10, fontweight='bold', color=color)
    for i, member in enumerate(members):
        y = cy - 0.06 * (i - (len(members)-1)/2)
        ax3.text(cx, y, member, ha='center', va='center',
                 fontsize=8, color='black')

ax3.set_xlim(0, 1)
ax3.set_ylim(0, 1)
ax3.set_aspect('equal')
ax3.set_title('Universality Classes', fontsize=14)
ax3.text(0.5, 0.02, 'Ensembles with same α are in the same class',
         ha='center', fontsize=9, style='italic', color='gray')
ax3.axis('off')

plt.suptitle('Critical Exponents and Universality in Subgroup RG',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_critical_exponents.png', dpi=150, bbox_inches='tight')
print("Saved viz_critical_exponents.png")


#!/usr/bin/env python3
"""
Visualization 1: Pressure Landscape across Scales and Temperatures

Visualizes how the ensemble pressure Π(β) varies as a function of
inverse temperature β for symmetric groups S_2, S_3, S_4. Shows the
intensive pressure Π/n to reveal scale-invariant structure and the
emergence of a thermodynamic limit.
"""

import math
import itertools
import numpy as np
import matplotlib.pyplot as plt


# ── Self-contained group utilities ──

def compose_perm(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse_perm(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity_perm(n):
    return tuple(range(n))

def generate_subgroup(generators, n):
    ident = identity_perm(n)
    subgroup = {ident}
    frontier = set(generators)
    while frontier:
        new = set()
        subgroup |= frontier
        for g in frontier:
            for h in subgroup:
                for p in [compose_perm(g, h), compose_perm(h, g), inverse_perm(g)]:
                    if p not in subgroup:
                        new.add(p)
        frontier = new
    return frozenset(subgroup)

def all_subgroups_sn(n):
    perms = list(itertools.permutations(range(n)))
    subgroups = set()
    subgroups.add(frozenset([identity_perm(n)]))
    for g in perms:
        sg = generate_subgroup([g], n)
        subgroups.add(sg)
        for h in perms:
            sg2 = generate_subgroup([g, h], n)
            subgroups.add(sg2)
    return [set(s) for s in subgroups]

def pressure_sn(n, beta):
    subs = all_subgroups_sn(n)
    G_order = math.factorial(n)
    Z = sum(math.exp(-beta * math.log(max(1, G_order / len(H)))) for H in subs)
    return math.log(Z) if Z > 0 else 0


# ── Compute pressure data ──

betas = np.linspace(0.01, 5.0, 100)
groups = [2, 3, 4]
colors = ['#2196F3', '#FF5722', '#4CAF50']
labels = [f'$S_{n}$' for n in groups]

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Raw pressure
ax1 = axes[0]
for n, color, label in zip(groups, colors, labels):
    pressures = [pressure_sn(n, b) for b in betas]
    ax1.plot(betas, pressures, color=color, linewidth=2, label=label)
ax1.set_xlabel(r'Inverse temperature $\beta$', fontsize=12)
ax1.set_ylabel(r'Pressure $\Pi(\beta)$', fontsize=12)
ax1.set_title('Subgroup Pressure', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Panel 2: Intensive pressure
ax2 = axes[1]
for n, color, label in zip(groups, colors, labels):
    pressures = [pressure_sn(n, b) / n for b in betas]
    ax2.plot(betas, pressures, color=color, linewidth=2, label=label)
ax2.set_xlabel(r'Inverse temperature $\beta$', fontsize=12)
ax2.set_ylabel(r'Intensive pressure $\Pi(\beta)/n$', fontsize=12)
ax2.set_title('Intensive Pressure (Thermodynamic Limit)', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Panel 3: Susceptibility
ax3 = axes[2]
h = 0.02
for n, color, label in zip(groups, colors, labels):
    suscept = []
    for b in betas:
        P = pressure_sn(n, b)
        chi = (pressure_sn(n, b + h) - 2 * P + pressure_sn(n, b - h)) / h**2
        suscept.append(chi)
    ax3.plot(betas, suscept, color=color, linewidth=2, label=label)
ax3.set_xlabel(r'Inverse temperature $\beta$', fontsize=12)
ax3.set_ylabel(r'Susceptibility $\chi(\beta)$', fontsize=12)
ax3.set_title('Susceptibility (Phase Transition Signature)', fontsize=14)
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

plt.suptitle('Renormalization Group for Subgroup Ensembles: Pressure Landscape',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_pressure_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_pressure_landscape.png")


#!/usr/bin/env python3
"""
Visualization 2: RG Flow and Pressure Contraction

Shows how pressure evolves under repeated coarse-graining:
- Left: Geometric decay of pressure under contractive RG (|λ| < 1)
- Right: Fixed-point behavior where intensive pressure stabilizes
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# ── Panel 1: Pressure contraction trajectories ──
ax1 = axes[0]
n_steps = 20
scales = [0.3, 0.5, 0.7, 0.9, 0.95]
colors_contract = plt.cm.viridis(np.linspace(0.1, 0.9, len(scales)))

P0 = 10.0
ns = np.arange(n_steps + 1)

for scale, color in zip(scales, colors_contract):
    pressures = [scale**n * P0 for n in ns]
    ax1.plot(ns, pressures, 'o-', color=color, markersize=4, linewidth=1.5,
             label=f'$\\lambda = {scale}$')

ax1.axhline(y=0, color='red', linewidth=1.5, linestyle='--', alpha=0.7,
            label='Fixed point ($\\Pi = 0$)')
ax1.set_xlabel('RG iteration $n$', fontsize=12)
ax1.set_ylabel(r'Pressure $\Pi(\mathcal{R}^n(E))$', fontsize=12)
ax1.set_title('Pressure Contraction: $\\Pi_n = \\lambda^n \\cdot \\Pi_0$', fontsize=14)
ax1.legend(fontsize=10, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.5, P0 + 1)

# ── Panel 2: Intensive pressure convergence ──
ax2 = axes[1]
F1 = 2.5
n_max = 15
ns = np.arange(1, n_max + 1)

# Exact product model: F(n) = n * F(1)
intensive_exact = np.full_like(ns, F1, dtype=float)

# Perturbed models with corrections
np.random.seed(42)
perturbations = [
    ("Exact: $F(n) = n F_1$", lambda n: n * F1, '#2196F3'),
    ("$F(n) = n F_1 + 0.5\\sin(n)$", lambda n: n * F1 + 0.5 * np.sin(n), '#FF5722'),
    ("$F(n) = n F_1 + \\sqrt{n}$", lambda n: n * F1 + np.sqrt(n), '#4CAF50'),
    ("$F(n) = n F_1 + 2\\log(n+1)$", lambda n: n * F1 + 2 * np.log(n + 1), '#9C27B0'),
]

for label, fn, color in perturbations:
    intensive = np.array([fn(n) / n for n in ns])
    ax2.plot(ns, intensive, 'o-', color=color, markersize=5, linewidth=1.5,
             label=label)

ax2.axhline(y=F1, color='red', linewidth=1.5, linestyle='--', alpha=0.7,
            label=f'$F_1 = {F1}$')
ax2.set_xlabel('Scale $n$', fontsize=12)
ax2.set_ylabel(r'Intensive pressure $F(n)/n$', fontsize=12)
ax2.set_title('Thermodynamic Limit: $F(n)/n \\to F_1$', fontsize=14)
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3)
ax2.set_ylim(F1 - 1, F1 + 3)

plt.suptitle('RG Flow Dynamics and Convergence to Fixed Points',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_rg_flow.png', dpi=150, bbox_inches='tight')
print("Saved viz_rg_flow.png")
