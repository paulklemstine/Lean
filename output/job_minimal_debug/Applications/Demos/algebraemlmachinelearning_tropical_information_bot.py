"""
Tropical Information Bottleneck — Applications

Demonstrations of real-world applications of the tropical bottleneck duality.
"""

import math
from typing import List, Tuple
from algorithms import Observer, bottleneck_value, compute_tradeoff_curve, certified_rate_region_test


def neural_architecture_search_demo():
    """Application 1: Certified Neural Architecture Search

    Given a set of candidate architectures with measured capacity-distortion
    pairs, find the optimal architecture for any given trade-off weight β.

    The tropical bottleneck theorem guarantees that the search is exact:
    the optimal architecture at every β is a member of the finite spectrum.
    """
    print("=" * 60)
    print("APPLICATION 1: Certified Neural Architecture Search")
    print("=" * 60)

    architectures = [
        Observer("ResNet-18", capacity=2.0, distortion=4.5),
        Observer("ResNet-50", capacity=3.5, distortion=2.0),
        Observer("ResNet-152", capacity=5.0, distortion=1.2),
        Observer("MobileNet-v2", capacity=1.0, distortion=6.0),
        Observer("EfficientNet-B0", capacity=1.5, distortion=3.5),
        Observer("EfficientNet-B7", capacity=4.0, distortion=1.0),
        Observer("ViT-Small", capacity=2.5, distortion=3.0),
        Observer("ViT-Large", capacity=6.0, distortion=0.8),
    ]

    print("\nArchitecture Spectrum:")
    print(f"  {'Architecture':<20} {'Capacity':<12} {'Distortion':<12}")
    print("  " + "-" * 44)
    for a in architectures:
        print(f"  {a.name:<20} {a.capacity:<12.1f} {a.distortion:<12.1f}")

    segments = compute_tradeoff_curve(architectures)
    print("\nOptimal Architecture by Trade-off Region:")
    for seg in segments:
        if seg.beta_end == float('inf'):
            region = f"β ≥ {seg.beta_start:.3f}"
        else:
            region = f"β ∈ [{seg.beta_start:.3f}, {seg.beta_end:.3f}]"
        print(f"  {region:<30} → {seg.observer.name}")

    print("\nCertified optimality: the theorem guarantees no architecture")
    print("outside this spectrum can improve upon the trade-off curve.\n")


def compression_certificate_demo():
    """Application 2: Compression-Quality Certificates

    Given target compression requirements, determine whether they are
    achievable and, if so, which architecture achieves them.
    """
    print("=" * 60)
    print("APPLICATION 2: Compression-Quality Certificates")
    print("=" * 60)

    observers = [
        Observer("JPEG-Low", capacity=0.5, distortion=10.0),
        Observer("JPEG-Medium", capacity=1.5, distortion=5.0),
        Observer("JPEG-High", capacity=3.0, distortion=2.0),
        Observer("WebP", capacity=1.0, distortion=4.0),
        Observer("AVIF", capacity=0.8, distortion=3.5),
        Observer("Neural-Codec", capacity=0.3, distortion=6.0),
    ]

    requirements = [
        ("Low storage, any quality", 1.0, 15.0),
        ("Medium storage, good quality", 2.0, 5.0),
        ("High quality, any storage", 10.0, 2.5),
        ("Impossible: tiny + perfect", 0.2, 1.0),
        ("Edge case: exact match", 0.8, 3.5),
    ]

    print("\nCompression feasibility analysis:")
    for desc, c, d in requirements:
        ok, dom = certified_rate_region_test(observers, c, d)
        if ok:
            print(f"  ✓ '{desc}' (c≤{c}, d≤{d}): achievable via {dom.name}")
        else:
            print(f"  ✗ '{desc}' (c≤{c}, d≤{d}): NOT achievable")
            print(f"    Certificate: no observer dominates ({c}, {d})")

    print()


def tradeoff_sensitivity_demo():
    """Application 3: Trade-off Sensitivity Analysis

    Analyze how the optimal architecture changes as the trade-off
    parameter β varies. Breakpoints indicate phase transitions.
    """
    print("=" * 60)
    print("APPLICATION 3: Trade-off Sensitivity Analysis")
    print("=" * 60)

    observers = [
        Observer("Strategy-A", capacity=1.0, distortion=5.0),
        Observer("Strategy-B", capacity=2.5, distortion=2.0),
        Observer("Strategy-C", capacity=4.0, distortion=1.0),
    ]

    print("\nPhase diagram of optimal strategies:")
    print("  β = 0 (pure compression): Strategy-A (lowest capacity)")
    print("  β → ∞ (pure fidelity): Strategy-C (lowest distortion)")

    segments = compute_tradeoff_curve(observers)
    print("\nPhase transitions:")
    for i, seg in enumerate(segments):
        if i > 0:
            print(f"  ── Breakpoint at β = {seg.beta_start:.4f} ──")
        if seg.beta_end == float('inf'):
            print(f"  β > {seg.beta_start:.4f}: {seg.observer.name}")
        else:
            print(f"  β ∈ [{seg.beta_start:.4f}, {seg.beta_end:.4f}]: {seg.observer.name}")

    print("\nSensitivity: near breakpoints, small changes in β")
    print("cause discrete jumps in the optimal architecture.")

    # Demonstrate sensitivity
    for seg in segments:
        if seg.beta_end != float('inf') and seg.beta_start > 0:
            bp = seg.beta_end
            eps = 0.001
            _, opt_before = bottleneck_value(observers, bp - eps)
            _, opt_after = bottleneck_value(observers, bp + eps)
            print(f"  At β = {bp:.4f} ± ε: {opt_before.name} → {opt_after.name}")

    print()


def operadic_composition_demo():
    """Application 4: Operadic Architecture Composition

    Show how composing two architectures (operadic composition) produces
    new observer pairs, expanding the spectrum.
    """
    print("=" * 60)
    print("APPLICATION 4: Operadic Architecture Composition")
    print("=" * 60)

    # Base layers
    layers = [
        Observer("Conv-3x3", capacity=1.0, distortion=3.0),
        Observer("Conv-1x1", capacity=0.5, distortion=5.0),
        Observer("Attention", capacity=2.0, distortion=1.5),
    ]

    print("\nBase layers:")
    for l in layers:
        print(f"  {l}")

    # Compose pairs (sequential): cap = cap1 + cap2, dist = min(dist1, dist2)
    # (simplified model of operadic composition)
    composed = []
    for i, l1 in enumerate(layers):
        for j, l2 in enumerate(layers):
            name = f"{l1.name}→{l2.name}"
            # Capacity adds (more parameters), distortion takes min (pipeline quality)
            c = l1.capacity + l2.capacity
            d = min(l1.distortion, l2.distortion)
            composed.append(Observer(name, c, d))

    print("\nComposed architectures (operadic products):")
    for c in composed:
        print(f"  {c}")

    # Combine base and composed
    all_obs = layers + composed
    segments = compute_tradeoff_curve(all_obs)
    print("\nExpanded trade-off curve:")
    for seg in segments:
        if seg.beta_end == float('inf'):
            region = f"β ≥ {seg.beta_start:.3f}"
        else:
            region = f"β ∈ [{seg.beta_start:.3f}, {seg.beta_end:.3f}]"
        print(f"  {region:<35} → {seg.observer.name}")

    print()


if __name__ == "__main__":
    neural_architecture_search_demo()
    compression_certificate_demo()
    tradeoff_sensitivity_demo()
    operadic_composition_demo()

    print("=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


"""
Tropical Information Bottleneck Duality — Demonstrations

This script demonstrates the core mathematical results of the tropical
information bottleneck theorem with concrete numerical examples.

Key demonstrations:
1. Computing the bottleneck value function B(β) as a lower envelope
2. Visualizing the piecewise-affine structure
3. Finding breakpoints where observers exchange optimality
4. Computing the certified rate region
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, NamedTuple


class Observer(NamedTuple):
    """A canonical observer factor with capacity and distortion."""
    name: str
    capacity: float    # c_i: closure capacity (lower = better compression)
    distortion: float  # d_i: tropical distortion (lower = better fidelity)


def bottleneck_objective(obs: Observer, beta: float) -> float:
    """Compute the scalarized objective: c_i + β * d_i."""
    return obs.capacity + beta * obs.distortion


def bottleneck_value(observers: List[Observer], beta: float) -> float:
    """Compute B(β) = min_i (c_i + β * d_i)."""
    return min(bottleneck_objective(obs, beta) for obs in observers)


def optimal_observer(observers: List[Observer], beta: float) -> Observer:
    """Find the observer achieving the minimum at parameter β."""
    return min(observers, key=lambda obs: bottleneck_objective(obs, beta))


def find_breakpoints(observers: List[Observer]) -> List[Tuple[float, Observer, Observer]]:
    """Find all breakpoints where two observers exchange optimality.

    At a breakpoint β*, we have c_i + β* d_i = c_j + β* d_j,
    so β* = (c_j - c_i) / (d_i - d_j) when d_i ≠ d_j.

    Returns: List of (β*, obs_i, obs_j) triples.
    """
    breakpoints = []
    n = len(observers)
    for i in range(n):
        for j in range(i + 1, n):
            di, dj = observers[i].distortion, observers[j].distortion
            ci, cj = observers[i].capacity, observers[j].capacity
            if abs(di - dj) > 1e-12:
                beta_star = (cj - ci) / (di - dj)
                breakpoints.append((beta_star, observers[i], observers[j]))
    breakpoints.sort(key=lambda x: x[0])
    return breakpoints


def certified_rate_region(observers: List[Observer], grid_size: int = 200):
    """Compute the certified rate region (upward closure of spectrum).

    A pair (c, d) is achievable iff ∃ i: c_i ≤ c and d_i ≤ d.
    """
    caps = [obs.capacity for obs in observers]
    dists = [obs.distortion for obs in observers]

    c_min, c_max = min(caps) - 0.5, max(caps) + 1.5
    d_min, d_max = min(dists) - 0.5, max(dists) + 1.5

    c_grid = np.linspace(c_min, c_max, grid_size)
    d_grid = np.linspace(d_min, d_max, grid_size)
    C, D = np.meshgrid(c_grid, d_grid)

    achievable = np.zeros_like(C, dtype=bool)
    for obs in observers:
        achievable |= (C >= obs.capacity) & (D >= obs.distortion)

    return C, D, achievable


# ─── Example 1: Neural Architecture Observers ───────────────────────────────

print("=" * 70)
print("TROPICAL INFORMATION BOTTLENECK DUALITY — DEMONSTRATION")
print("=" * 70)

# Define a set of canonical observer factors
# These represent different neural architecture factorizations
observers = [
    Observer("Deep-Narrow", capacity=1.0, distortion=5.0),
    Observer("Medium", capacity=2.5, distortion=2.0),
    Observer("Wide-Shallow", capacity=4.0, distortion=1.0),
    Observer("Balanced", capacity=2.0, distortion=3.0),
    Observer("Ultra-Compressed", capacity=0.5, distortion=8.0),
]

print("\n── Observer Spectrum (Operadic Compression Pairs) ──")
print(f"{'Observer':<20} {'Capacity (c)':<15} {'Distortion (d)':<15}")
print("-" * 50)
for obs in observers:
    print(f"{obs.name:<20} {obs.capacity:<15.1f} {obs.distortion:<15.1f}")

# Compute bottleneck values
betas = np.linspace(0, 5, 1000)
B_values = [bottleneck_value(observers, b) for b in betas]

print("\n── Bottleneck Values B(β) at Selected Points ──")
for b in [0, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0]:
    opt = optimal_observer(observers, b)
    val = bottleneck_value(observers, b)
    print(f"  β = {b:.1f}:  B(β) = {val:.2f}  (achieved by {opt.name})")

# Find breakpoints
breakpoints = find_breakpoints(observers)
print("\n── Breakpoints (Observer Exchange Points) ──")
relevant_bps = [(bp, oi, oj) for bp, oi, oj in breakpoints if 0 <= bp <= 5]
for bp, oi, oj in relevant_bps:
    val = bottleneck_value(observers, bp)
    print(f"  β* = {bp:.4f}: {oi.name} ↔ {oj.name}, B(β*) = {val:.4f}")

# Count active breakpoints (where both observers are actually optimal)
active_bps = []
for bp, oi, oj in relevant_bps:
    val = bottleneck_value(observers, bp)
    if abs(bottleneck_objective(oi, bp) - val) < 1e-10:
        active_bps.append((bp, oi, oj))

print(f"\n  Active breakpoints (on the lower envelope): {len(active_bps)}")
for bp, oi, oj in active_bps:
    print(f"    β* = {bp:.4f}: {oi.name} ↔ {oj.name}")


# ─── Visualization 1: Bottleneck Value Function ─────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot individual observer lines and the envelope
ax = axes[0]
colors = plt.cm.Set2(np.linspace(0, 1, len(observers)))
for obs, color in zip(observers, colors):
    y = [bottleneck_objective(obs, b) for b in betas]
    ax.plot(betas, y, '--', alpha=0.4, color=color, label=f"{obs.name}")

ax.plot(betas, B_values, 'k-', linewidth=2.5, label="B(β) (envelope)")

for bp, oi, oj in active_bps:
    val = bottleneck_value(observers, bp)
    ax.plot(bp, val, 'ro', markersize=8, zorder=5)

ax.set_xlabel("β (distortion weight)", fontsize=12)
ax.set_ylabel("B(β) (bottleneck value)", fontsize=12)
ax.set_title("Tropical Bottleneck = Lower Envelope", fontsize=13)
ax.legend(fontsize=8, loc='upper left')
ax.grid(True, alpha=0.3)

# Plot certified rate region
ax = axes[1]
C, D, achievable = certified_rate_region(observers)
ax.contourf(C, D, achievable.astype(float), levels=[0.5, 1.5],
            colors=['#cce5ff'], alpha=0.7)
ax.contour(C, D, achievable.astype(float), levels=[0.5],
           colors=['#0066cc'], linewidths=2)

for obs in observers:
    ax.plot(obs.capacity, obs.distortion, 'ko', markersize=10, zorder=5)
    ax.annotate(obs.name, (obs.capacity, obs.distortion),
                textcoords="offset points", xytext=(8, 8), fontsize=8)

ax.set_xlabel("Capacity c", fontsize=12)
ax.set_ylabel("Distortion d", fontsize=12)
ax.set_title("Certified Rate Region\n(Upward Closure of Spectrum)", fontsize=13)
ax.grid(True, alpha=0.3)

# Plot which observer is optimal at each β
ax = axes[2]
for obs, color in zip(observers, colors):
    optimal_betas = [b for b in betas
                     if abs(bottleneck_objective(obs, b) - bottleneck_value(observers, b)) < 1e-8]
    if optimal_betas:
        ax.barh(obs.name, max(optimal_betas) - min(optimal_betas),
                left=min(optimal_betas), color=color, alpha=0.8, height=0.6)

for bp, _, _ in active_bps:
    ax.axvline(x=bp, color='red', linestyle=':', alpha=0.5)

ax.set_xlabel("β (distortion weight)", fontsize=12)
ax.set_title("Optimal Observer Regions\n(Breakpoints in red)", fontsize=13)
ax.grid(True, alpha=0.3, axis='x')

plt.tight_layout()
plt.savefig("tropical_bottleneck_duality.png", dpi=150, bbox_inches='tight')
plt.close()
print("\n✓ Saved tropical_bottleneck_duality.png")


# ─── Example 2: Monotone Scalarization Verification ─────────────────────────

print("\n── Verifying Monotone Scalarization ──")
print("If observer i dominates observer j (c_i ≤ c_j and d_i ≤ d_j),")
print("then Φ_β(i) ≤ Φ_β(j) for all β ≥ 0.")

# The "Balanced" observer (c=2.0, d=3.0) is dominated by "Medium" (c=2.5, d=2.0)?
# No: 2.5 > 2.0. Let's check which observers dominate others.
print("\nDomination analysis:")
for i, oi in enumerate(observers):
    for j, oj in enumerate(observers):
        if i != j and oi.capacity <= oj.capacity and oi.distortion <= oj.distortion:
            print(f"  {oi.name} dominates {oj.name}")
            # Verify scalarization monotonicity
            for b in [0, 1, 2, 5]:
                assert bottleneck_objective(oi, b) <= bottleneck_objective(oj, b)
            print(f"    ✓ Scalarization monotonicity verified for β ∈ {{0, 1, 2, 5}}")


# ─── Example 3: Legendre Duality / Tropical Conjugate ───────────────────────

print("\n── Tropical Legendre Duality ──")
print("B(β) = min_i(c_i + β·d_i) is the tropical (min-plus) Legendre")
print("transform of the indicator function of the observer spectrum.")
print("\nThe slopes of B are exactly the distortion values {d_i}:")
print(f"  Distortion spectrum: {sorted(set(obs.distortion for obs in observers))}")
print("The intercepts are the capacity values {c_i}:")
print(f"  Capacity spectrum: {sorted(set(obs.capacity for obs in observers))}")

# Verify piecewise-affine structure
print("\nPiecewise-affine structure verification:")
for b in betas[::200]:
    opt = optimal_observer(observers, b)
    val = bottleneck_value(observers, b)
    reconstructed = opt.capacity + b * opt.distortion
    assert abs(val - reconstructed) < 1e-10, f"Mismatch at β={b}"
print("  ✓ B(β) = cap(i*) + β·dist(i*) verified for all sampled β")


# ─── Summary Statistics ─────────────────────────────────────────────────────

print("\n── Summary ──")
print(f"  Number of observers: {len(observers)}")
print(f"  Spectrum dimension: {len(set((o.capacity, o.distortion) for o in observers))}")
print(f"  Active breakpoints: {len(active_bps)}")
print(f"  Number of affine pieces: {len(active_bps) + 1}")
print(f"  B(0) = min capacity = {min(o.capacity for o in observers):.1f}")
print(f"  Slope at β=0: d = {optimal_observer(observers, 0.01).distortion:.1f}")
print(f"  Slope at β→∞: d = {optimal_observer(observers, 100).distortion:.1f}")

print("\n" + "=" * 70)
print("All demonstrations completed successfully.")
print("=" * 70)
