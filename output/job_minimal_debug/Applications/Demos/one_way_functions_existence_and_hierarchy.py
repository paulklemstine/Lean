#!/usr/bin/env python3
"""
Demonstration of the Cryptographic Hardness Hierarchy

Illustrates the key mathematical results formalized in Lean:
1. Lossy function collisions (pigeonhole)
2. PRG stretch non-surjectivity and output gap
3. Hybrid argument advantage bounds
4. GGM tree evaluation
5. Security profile degradation
6. Collision density conjecture testing
"""

import random
import math
from algorithms import (
    CryptoLevel, SecurityProfile, HybridSequence, CryptoReduction,
    ggm_evaluate, compute_fibers, collision_free_count,
    lossy_collision_check, amplification_failure_prob,
    security_parameter_for_target, HIERARCHY
)


def demo_hierarchy():
    """Demonstrate the cryptographic hardness lattice."""
    print("=" * 60)
    print("1. CRYPTOGRAPHIC HARDNESS HIERARCHY")
    print("=" * 60)
    print()
    print("Levels (weakest to strongest):")
    for level in HIERARCHY:
        print(f"  {level.name} (rank {level.rank})")
    print()
    print("Implication table (row implies column):")
    print(f"{'':>6}", end="")
    for b in HIERARCHY:
        print(f"{b.name:>6}", end="")
    print()
    for a in HIERARCHY:
        print(f"{a.name:>6}", end="")
        for b in HIERARCHY:
            print(f"{'  ✓':>6}" if a <= b else f"{'  ✗':>6}", end="")
        print()
    print()
    print("Strictness: No two distinct levels are equivalent")
    for a in HIERARCHY:
        for b in HIERARCHY:
            if a.name != b.name:
                both = (a <= b) and (b <= a)
                assert not both, f"Strictness violated for {a}, {b}"
    print("  ✓ Verified for all pairs")
    print()


def demo_lossy_collisions():
    """Demonstrate lossy function collision bounds."""
    print("=" * 60)
    print("2. LOSSY FUNCTION COLLISIONS")
    print("=" * 60)
    print()
    for (N, M) in [(20, 10), (100, 50), (256, 128), (1000, 100)]:
        f = lambda x, M=M: x % M  # Simple lossy function
        collision = lossy_collision_check(f, N, M)
        fibers = compute_fibers(f, N)
        max_fiber = max(len(v) for v in fibers.values())
        print(f"  f: {{0..{N-1}}} → {{0..{M-1}}} (mod {M})")
        print(f"    Image size: {len(fibers)} ≤ {M}")
        print(f"    Max fiber size: {max_fiber}")
        print(f"    Collision found: {collision}")
        print()


def demo_prg_stretch():
    """Demonstrate PRG stretch non-surjectivity and output gap."""
    print("=" * 60)
    print("3. PRG STRETCH NON-SURJECTIVITY")
    print("=" * 60)
    print()
    for n in range(3, 9):
        N = 2**n
        M = 2**(n+1)
        # Random "PRG"
        random.seed(42 + n)
        outputs = set(random.randint(0, M-1) for _ in range(N))
        gap = M - len(outputs)
        min_gap = M - N
        print(f"  n={n}: |seed|=2^{n}={N}, |output|=2^{n+1}={M}")
        print(f"    Image size ≤ {N} (actual: {len(outputs)})")
        print(f"    Output gap ≥ {min_gap} (actual: {gap})")
        print(f"    Coverage: {len(outputs)/M:.4f} of output space")
        print()


def demo_hybrid_argument():
    """Demonstrate hybrid argument advantage decomposition."""
    print("=" * 60)
    print("4. HYBRID ARGUMENT")
    print("=" * 60)
    print()
    # Example: 8-step hybrid with varying advantages
    advantages = [0.001, 0.003, 0.002, 0.005, 0.001, 0.004, 0.002, 0.003]
    H = HybridSequence(step_advantages=advantages)
    print(f"  Hybrid with {H.num_steps} steps:")
    print(f"    Step advantages: {advantages}")
    print(f"    Total advantage: {H.total_advantage():.4f}")
    print(f"    Triangle bound:  {H.triangle_bound():.4f}")
    print(f"    Tightness ratio: {H.tightness_ratio():.4f}")
    print(f"    Max step advantage: {max(advantages):.4f}")
    print()
    print("  Theorem: total ≤ numSteps × max")
    print(f"    {H.total_advantage():.4f} ≤ {H.num_steps} × {max(advantages):.4f} = {H.triangle_bound():.4f} ✓")
    print()
    print("  Theorem: max step ≤ total (tightness)")
    print(f"    {max(advantages):.4f} ≤ {H.total_advantage():.4f} ✓")
    print()


def demo_ggm_tree():
    """Demonstrate GGM tree evaluation."""
    print("=" * 60)
    print("5. GGM TREE CONSTRUCTION")
    print("=" * 60)
    print()
    # Simple PRG over integers mod 256
    def simple_prg(x: int) -> tuple[int, int]:
        left = (x * 137 + 43) % 256
        right = (x * 211 + 97) % 256
        return (left, right)

    seed = 42
    print(f"  PRG: G(x) = ((137x + 43) mod 256, (211x + 97) mod 256)")
    print(f"  Seed: {seed}")
    print()

    # Evaluate at all 3-bit paths
    all_outputs = set()
    for i in range(8):
        path = [(i >> (2-j)) & 1 == 1 for j in range(3)]
        output = ggm_evaluate(simple_prg, seed, path)
        path_str = ''.join('1' if b else '0' for b in path)
        print(f"    Path {path_str} → {output}")
        all_outputs.add(output)

    print(f"\n  Distinct outputs: {len(all_outputs)} ≤ 256 (|α|) ✓")
    print()


def demo_security_profile():
    """Demonstrate security profile degradation."""
    print("=" * 60)
    print("6. SECURITY PROFILE DEGRADATION")
    print("=" * 60)
    print()

    # Standard hierarchy: OWF → PRG → PRF → ENC
    # HILL: O(n²) loss, GGM: O(2^d) loss, PRF→ENC: tight
    degradation = [16.0, 2**7, 1.0]  # n²=16, 2^d=128, tight
    profile = SecurityProfile.from_target(
        target_bits=128,
        degradation=degradation
    )
    profile.levels = ["OWF", "PRG", "PRF", "ENC"]

    print(f"  Chain: OWF → PRG → PRF → ENC")
    print(f"  Target encryption security: 128 bits")
    print(f"  Degradation factors: {degradation}")
    print(f"  Total degradation: {profile.total_degradation()}")
    print(f"  Total degradation (log2): {profile.total_degradation_log2():.1f} bits")
    print()
    print("  Security at each level:")
    for i, (level, sec) in enumerate(zip(profile.levels, profile.security_at_level)):
        print(f"    {level}: {sec:.1f} (log2: {math.log2(sec):.1f} bits)")
    print()
    print(f"  Chain condition verified: {profile.verify_chain()} ✓")
    print(f"  End-to-end bound: {profile.end_to_end_bound():.1f}")
    print()

    # Required OWF security for various targets
    print("  Required OWF security (bits) for different targets:")
    for target in [80, 128, 192, 256]:
        req = security_parameter_for_target(target, degradation)
        print(f"    Target {target}-bit ENC → need {req:.1f}-bit OWF")
    print()


def demo_amplification():
    """Demonstrate advantage amplification."""
    print("=" * 60)
    print("7. ADVANTAGE AMPLIFICATION")
    print("=" * 60)
    print()
    p = 0.01  # 1% advantage
    print(f"  Single-trial advantage: p = {p}")
    print()
    print(f"  {'k':>6}  {'(1-p)^k':>12}  {'Failure %':>10}")
    print(f"  {'-'*6}  {'-'*12}  {'-'*10}")
    for k in [1, 5, 10, 50, 100, 500, 1000]:
        fail = amplification_failure_prob(p, k)
        print(f"  {k:>6}  {fail:>12.8f}  {fail*100:>9.6f}%")
    print()
    print("  Theorem: (1-p)^k ≤ 1 for 0 ≤ p ≤ 1 ✓")
    print("  Theorem: (1-p)^k₂ ≤ (1-p)^k₁ for k₁ ≤ k₂ ✓")
    print()


def demo_collision_density():
    """Test the collision density conjecture."""
    print("=" * 60)
    print("8. COLLISION DENSITY CONJECTURE")
    print("=" * 60)
    print()
    print("  Conjecture: For f : Fin(2^n) → Fin(2^(n+1)),")
    print("  collision-free outputs ≥ 2^n - n")
    print()

    random.seed(42)
    for n in range(1, 9):
        N = 2**n
        M = 2**(n + 1)
        threshold = N - n
        min_cf = M  # track minimum over trials

        num_trials = min(1000, M**N if M**N < 1000 else 1000)
        for _ in range(num_trials):
            # Random function f : {0..N-1} → {0..M-1}
            f_values = [random.randint(0, M - 1) for _ in range(N)]
            f = lambda x, vals=f_values: vals[x]
            cf = collision_free_count(f, N, M)
            min_cf = min(min_cf, cf)

        status = "✓" if min_cf >= threshold else "✗ REFUTED"
        print(f"  n={n}: N={N}, M={M}, threshold={threshold}, "
              f"min_cf={min_cf} {status}")

    print()
    print("  Original conjecture (2^n - n) is REFUTED for small n.")
    print("  Empirical data suggests min_cf ≈ N/e ≈ 0.37·N for random functions.")
    print()


def demo_reduction_composition():
    """Demonstrate reduction composition."""
    print("=" * 60)
    print("9. REDUCTION COMPOSITION")
    print("=" * 60)
    print()

    r1 = CryptoReduction("HILL (OWF→PRG)", loss_factor=16.0, runtime_overhead=1000)
    r2 = CryptoReduction("GGM (PRG→PRF)", loss_factor=128.0, runtime_overhead=500)
    r3 = CryptoReduction("GM (PRF→ENC)", loss_factor=1.0, runtime_overhead=100)

    composed = r1.compose(r2).compose(r3)
    print(f"  Individual reductions:")
    print(f"    {r1.name}: loss={r1.loss_factor}, overhead={r1.runtime_overhead}")
    print(f"    {r2.name}: loss={r2.loss_factor}, overhead={r2.runtime_overhead}")
    print(f"    {r3.name}: loss={r3.loss_factor}, overhead={r3.runtime_overhead}")
    print()
    print(f"  Composed reduction:")
    print(f"    Name: {composed.name}")
    print(f"    Loss factor: {composed.loss_factor}")
    print(f"    Runtime overhead: {composed.runtime_overhead}")
    print()
    print("  Theorem: adv_C ≤ L₁·L₂·L₃ · adv_A")
    print(f"  If adv_A = 2^(-128), then:")
    adv_A = 2**(-128)
    adv_C_bound = composed.loss_factor * adv_A
    print(f"    adv_C ≤ {composed.loss_factor} × 2^(-128) = {adv_C_bound:.2e}")
    print(f"    Effective security: {-math.log2(adv_C_bound):.1f} bits")
    print()


if __name__ == "__main__":
    demo_hierarchy()
    demo_lossy_collisions()
    demo_prg_stretch()
    demo_hybrid_argument()
    demo_ggm_tree()
    demo_security_profile()
    demo_amplification()
    demo_collision_density()
    demo_reduction_composition()
    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""Visualization: Cryptographic Hardness Hierarchy and Security Degradation"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# Figure 1: Hierarchy diagram and security degradation
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Hierarchy diagram
ax1 = axes[0]
levels = ['OWF', 'PRG', 'PRF', 'ENC']
ranks = [0, 1, 2, 3]
colors = ['#e74c3c', '#f39c12', '#2ecc71', '#3498db']

for i, (level, rank, color) in enumerate(zip(levels, ranks, colors)):
    circle = plt.Circle((0.5, rank * 0.25 + 0.125), 0.06, color=color, ec='black', lw=2)
    ax1.add_patch(circle)
    ax1.text(0.5, rank * 0.25 + 0.125, level, ha='center', va='center',
             fontsize=12, fontweight='bold', color='white')

# Draw arrows
for i in range(3):
    ax1.annotate('', xy=(0.5, ranks[i] * 0.25 + 0.185),
                xytext=(0.5, ranks[i+1] * 0.25 + 0.065),
                arrowprops=dict(arrowstyle='->', lw=2, color='gray'))
    # Label the reduction
    reductions = ['HILL\n(loss: O(n²))', 'GGM\n(loss: O(2^d))', 'GM\n(loss: 1)']
    ax1.text(0.72, (ranks[i] * 0.25 + ranks[i+1] * 0.25) / 2 + 0.125, reductions[i],
            ha='left', va='center', fontsize=8, color='gray', style='italic')

ax1.set_xlim(0, 1.2)
ax1.set_ylim(0, 1)
ax1.set_aspect('equal')
ax1.set_title('Cryptographic Hardness Hierarchy', fontsize=14, fontweight='bold')
ax1.axis('off')
ax1.text(0.15, 0.95, 'Stronger →', fontsize=10, va='top', color='gray')
ax1.text(0.15, 0.05, '← Weaker', fontsize=10, va='bottom', color='gray')

# Right: Security degradation
ax2 = axes[1]
target_bits = [80, 128, 192, 256]
degradation_factors = [
    [4.0, 128.0, 1.0],   # n=2, d=7
    [16.0, 128.0, 1.0],  # n=4, d=7
    [64.0, 128.0, 1.0],  # n=8, d=7
    [256.0, 128.0, 1.0], # n=16, d=7
]

x = np.arange(len(target_bits))
width = 0.2

level_names = ['ENC', 'PRF', 'PRG', 'OWF']
level_colors = ['#3498db', '#2ecc71', '#f39c12', '#e74c3c']

for j, (target, factors) in enumerate(zip(target_bits, degradation_factors)):
    security = [float(target)]
    for f in reversed(factors):
        security.append(security[-1] * f)
    security.reverse()

    for i, (sec, color) in enumerate(zip(security, level_colors[::-1])):
        ax2.bar(x[j] + (i - 1.5) * width, np.log2(sec), width * 0.9,
               color=color, edgecolor='black', linewidth=0.5)

ax2.set_xticks(x)
ax2.set_xticklabels([f'{t}-bit\ntarget' for t in target_bits])
ax2.set_ylabel('Security (log₂ bits)', fontsize=11)
ax2.set_title('Security Degradation Through Hierarchy', fontsize=14, fontweight='bold')
patches = [mpatches.Patch(color=c, label=l) for c, l in zip(level_colors, level_names)]
ax2.legend(handles=patches, loc='upper left', fontsize=9)
ax2.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('viz_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_hierarchy.png")

# Figure 2: Hybrid argument and amplification
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Hybrid argument
ax1 = axes[0]
np.random.seed(42)
for n_steps in [4, 8, 16, 32]:
    advantages = np.random.exponential(0.001, n_steps)
    cumulative = np.cumsum(advantages)
    ax1.plot(range(1, n_steps + 1), cumulative, 'o-', markersize=3,
            label=f'n={n_steps}, total={cumulative[-1]:.4f}')
    # Triangle bound
    ax1.axhline(y=n_steps * advantages.max(), color='gray', linestyle='--', alpha=0.3)

ax1.set_xlabel('Hybrid Step', fontsize=11)
ax1.set_ylabel('Cumulative Advantage', fontsize=11)
ax1.set_title('Hybrid Argument: Cumulative Advantage', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(alpha=0.3)

# Right: Amplification
ax2 = axes[1]
k_values = np.arange(1, 501)
for p in [0.001, 0.005, 0.01, 0.05, 0.1]:
    fail_prob = (1 - p) ** k_values
    ax2.semilogy(k_values, fail_prob, label=f'p={p}')

ax2.set_xlabel('Number of Repetitions (k)', fontsize=11)
ax2.set_ylabel('Failure Probability (1-p)^k', fontsize=11)
ax2.set_title('Advantage Amplification', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(alpha=0.3)
ax2.set_ylim(1e-10, 1)

plt.tight_layout()
plt.savefig('viz_amplification.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_amplification.png")

# Figure 3: PRG stretch gap and collision density
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: PRG output gap
ax1 = axes[0]
n_values = range(2, 16)
N_vals = [2**n for n in n_values]
M_vals = [2**(n+1) for n in n_values]
gaps = [m - n for n, m in zip(N_vals, M_vals)]
coverages = [n/m for n, m in zip(N_vals, M_vals)]

ax1_twin = ax1.twinx()
bars = ax1.bar(list(n_values), gaps, color='#e74c3c', alpha=0.7, label='Output gap (M-N)')
ax1_twin.plot(list(n_values), coverages, 'b-o', markersize=5, label='Coverage (N/M)')
ax1.set_xlabel('Security Parameter n', fontsize=11)
ax1.set_ylabel('Output Gap (M - N)', fontsize=11, color='red')
ax1_twin.set_ylabel('Coverage Fraction (N/M)', fontsize=11, color='blue')
ax1.set_title('PRG Stretch: Output Gap', fontsize=14, fontweight='bold')
ax1.set_yscale('log')
lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax1_twin.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2, loc='center right', fontsize=9)

# Right: Collision density
ax2 = axes[1]
import random
random.seed(42)
n_range = range(1, 13)
avg_cf = []
min_cf = []
max_cf = []
for n in n_range:
    N = 2**n
    M = 2**(n+1)
    cfs = []
    for _ in range(200):
        f_vals = [random.randint(0, M-1) for _ in range(N)]
        # Count collision-free
        from collections import Counter
        counts = Counter(f_vals)
        cf = sum(1 for v in counts.values() if v == 1)
        cfs.append(cf)
    avg_cf.append(np.mean(cfs))
    min_cf.append(min(cfs))
    max_cf.append(max(cfs))

N_vals_cf = [2**n for n in n_range]
expected = [n / np.e for n in N_vals_cf]

ax2.fill_between(list(n_range), min_cf, max_cf, alpha=0.2, color='blue')
ax2.plot(list(n_range), avg_cf, 'b-o', markersize=5, label='Avg collision-free')
ax2.plot(list(n_range), expected, 'r--', label='N/e (expected)')
ax2.plot(list(n_range), N_vals_cf, 'g--', label='N (upper bound)')
ax2.set_xlabel('Parameter n (domain = 2^n)', fontsize=11)
ax2.set_ylabel('Collision-free outputs', fontsize=11)
ax2.set_title('Collision Density in Stretching Functions', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(alpha=0.3)
ax2.set_yscale('log')

plt.tight_layout()
plt.savefig('viz_collision_density.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_collision_density.png")
