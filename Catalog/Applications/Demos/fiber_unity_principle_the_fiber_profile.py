"""
Fiber Unity Principle — Demonstrations
=======================================
Numerical examples demonstrating the core theorems.
"""

from algorithms import (
    fiber_profile,
    deficiency,
    max_fiber_size,
    depth_lower_bound,
    erasure_cost_bits,
    weighted_landauer_cost,
    verify_fiber_partition,
    verify_combinatorial_second_law,
    verify_unity_theorem,
    fiber_renyi_entropy,
)


def demo_fiber_profile():
    """Demonstrate fiber profile computation for various functions."""
    print("=" * 60)
    print("DEMO 1: Fiber Profile Computation")
    print("=" * 60)

    examples = [
        ("Identity on {0..7}", lambda x: x, range(8)),
        ("Constant → 0", lambda x: 0, range(8)),
        ("Mod 2", lambda x: x % 2, range(8)),
        ("Mod 3 on {0..11}", lambda x: x % 3, range(12)),
        ("Floor div 2 on {0..7}", lambda x: x // 2, range(8)),
        ("x^2 mod 7 on {0..6}", lambda x: (x * x) % 7, range(7)),
    ]

    for name, f, domain in examples:
        profile = fiber_profile(f, list(domain))
        d = deficiency(f, list(domain))
        mfs = max_fiber_size(f, list(domain))
        dlb = depth_lower_bound(f, list(domain))
        ec = erasure_cost_bits(f, list(domain))
        print(f"\n  {name}:")
        print(f"    Fiber profile: {profile}")
        print(f"    Deficiency:    {d}")
        print(f"    Max fiber:     {mfs}")
        print(f"    Depth bound:   {dlb}")
        print(f"    Erasure cost:  {ec:.4f} bits")


def demo_combinatorial_second_law():
    """Demonstrate that deficiency is monotone under composition."""
    print("\n" + "=" * 60)
    print("DEMO 2: Combinatorial Second Law")
    print("=" * 60)

    domain = list(range(12))

    # f: mod 4, g: mod 2
    f = lambda x: x % 4
    g = lambda y: y % 2

    def_f = deficiency(f, domain)
    def_gf = deficiency(lambda x: g(f(x)), domain)

    print(f"\n  f = mod 4, g = mod 2, domain = {{0..11}}")
    print(f"  def(f)     = {def_f}")
    print(f"  def(g∘f)   = {def_gf}")
    print(f"  def(f) ≤ def(g∘f)? {def_f <= def_gf} ✓")

    # Another example: f: floor div 3, g: mod 2
    f2 = lambda x: x // 3
    g2 = lambda y: y % 2

    def_f2 = deficiency(f2, domain)
    def_g2f2 = deficiency(lambda x: g2(f2(x)), domain)

    print(f"\n  f = ⌊x/3⌋, g = mod 2, domain = {{0..11}}")
    print(f"  def(f)     = {def_f2}")
    print(f"  def(g∘f)   = {def_g2f2}")
    print(f"  def(f) ≤ def(g∘f)? {def_f2 <= def_g2f2} ✓")


def demo_fiber_partition():
    """Verify the fiber partition theorem: sum of fiber sizes = |domain|."""
    print("\n" + "=" * 60)
    print("DEMO 3: Fiber Partition Theorem")
    print("=" * 60)

    tests = [
        ("mod 5 on {0..24}", lambda x: x % 5, range(25)),
        ("constant on {0..99}", lambda x: 42, range(100)),
        ("identity on {0..9}", lambda x: x, range(10)),
        ("x^2 mod 11 on {0..10}", lambda x: (x * x) % 11, range(11)),
    ]

    for name, f, domain in tests:
        profile = fiber_profile(f, list(domain))
        ok = verify_fiber_partition(f, list(domain))
        print(f"\n  {name}:")
        print(f"    Profile: {profile}")
        print(f"    Sum = {sum(profile)}, |domain| = {len(list(domain))}")
        print(f"    Partition theorem holds? {ok} ✓")


def demo_unity_theorem():
    """Verify: deficiency + |image| = |domain|."""
    print("\n" + "=" * 60)
    print("DEMO 4: Fiber Unity Theorem")
    print("=" * 60)

    tests = [
        ("mod 3 on {0..8}", lambda x: x % 3, range(9)),
        ("floor div 4 on {0..15}", lambda x: x // 4, range(16)),
        ("constant", lambda x: 0, range(7)),
        ("identity", lambda x: x, range(5)),
    ]

    for name, f, domain in tests:
        d = deficiency(f, list(domain))
        image_size = len(set(f(x) for x in domain))
        n = len(list(domain))
        ok = verify_unity_theorem(f, list(domain))
        print(f"\n  {name}:")
        print(f"    def(f) = {d}, |image| = {image_size}, |domain| = {n}")
        print(f"    {d} + {image_size} = {d + image_size} = {n}? {ok} ✓")


def demo_landauer_cost():
    """Demonstrate weighted Landauer cost computation."""
    print("\n" + "=" * 60)
    print("DEMO 5: Landauer Erasure Cost")
    print("=" * 60)

    import math

    tests = [
        ("AND gate (4→2)", lambda x: 1 if x == 3 else 0, range(4)),
        ("3-bit erasure (8→1)", lambda x: 0, range(8)),
        ("Bijection (8→8)", lambda x: x, range(8)),
        ("Balanced 2-to-1 (8→4)", lambda x: x // 2, range(8)),
    ]

    for name, f, domain in tests:
        profile = fiber_profile(f, list(domain))
        w = weighted_landauer_cost(f, list(domain))
        ec = erasure_cost_bits(f, list(domain))
        print(f"\n  {name}:")
        print(f"    Profile: {profile}")
        print(f"    Weighted Landauer cost (kT=1): {w:.4f}")
        print(f"    Erasure cost: {ec:.4f} bits")
        print(f"    Landauer bound (kT ln 2 × bits): {ec * math.log(2):.4f}")


def demo_renyi_spectrum():
    """Demonstrate Rényi entropy spectrum for different fiber profiles."""
    print("\n" + "=" * 60)
    print("DEMO 6: Rényi Entropy Spectrum")
    print("=" * 60)

    tests = [
        ("Uniform (mod 4 on {0..7})", lambda x: x % 4, range(8)),
        ("Skewed ({5,2,1})", lambda x: 0 if x < 5 else (1 if x < 7 else 2), range(8)),
        ("Constant", lambda x: 0, range(8)),
    ]

    alphas = [0, 0.5, 1.0, 2.0, 5.0, float("inf")]

    for name, f, domain in tests:
        profile = fiber_profile(f, list(domain))
        print(f"\n  {name}, profile = {profile}:")
        for a in alphas:
            h = fiber_renyi_entropy(f, list(domain), a)
            label = f"α={a}" if a != float("inf") else "α=∞"
            print(f"    H({label:>5}) = {h:.4f}")


if __name__ == "__main__":
    demo_fiber_profile()
    demo_combinatorial_second_law()
    demo_fiber_partition()
    demo_unity_theorem()
    demo_landauer_cost()
    demo_renyi_spectrum()


"""
Fiber Profile Visualization
============================
Standalone visualization of fiber profiles, deficiency monotonicity,
and the Rényi entropy spectrum.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import Counter
from math import log2, ceil


def fiber_profile(f, domain):
    counts = Counter(f(x) for x in domain)
    return sorted(counts.values(), reverse=True)


def deficiency(f, domain):
    return len(domain) - len(set(f(x) for x in domain))


def fiber_renyi_entropy(profile, n, alpha):
    probs = [s / n for s in profile]
    if alpha == 0:
        return log2(len(profile))
    elif abs(alpha - 1.0) < 1e-10:
        return -sum(p * log2(p) for p in probs if p > 0)
    elif alpha == float("inf"):
        return -log2(max(probs))
    else:
        power_sum = sum(p**alpha for p in probs)
        return (1 / (1 - alpha)) * log2(power_sum)


def plot_fiber_profiles():
    """Plot fiber profiles for several functions side by side."""
    fig, axes = plt.subplots(2, 3, figsize=(14, 8))
    fig.suptitle("Fiber Profiles of Functions on {0, ..., 11}", fontsize=14, fontweight="bold")

    domain = list(range(12))
    functions = [
        ("Identity", lambda x: x),
        ("mod 3", lambda x: x % 3),
        ("mod 2", lambda x: x % 2),
        ("⌊x/3⌋", lambda x: x // 3),
        ("x² mod 7", lambda x: (x * x) % 7),
        ("Constant", lambda x: 0),
    ]

    colors = plt.cm.viridis(np.linspace(0.2, 0.8, 12))

    for ax, (name, f) in zip(axes.flat, functions):
        profile = fiber_profile(f, domain)
        image_vals = sorted(set(f(x) for x in domain))
        fiber_sizes = [sum(1 for x in domain if f(x) == v) for v in image_vals]

        bars = ax.bar(range(len(fiber_sizes)), fiber_sizes, color=colors[: len(fiber_sizes)])
        ax.set_title(f"f(x) = {name}", fontsize=11)
        ax.set_xlabel("Output value")
        ax.set_ylabel("Fiber size")
        ax.set_ylim(0, max(13, max(fiber_sizes) + 1))

        d = deficiency(f, domain)
        ax.text(
            0.95, 0.95,
            f"def = {d}\nmax = {max(profile)}",
            transform=ax.transAxes,
            ha="right", va="top",
            fontsize=9,
            bbox=dict(boxstyle="round", facecolor="wheat", alpha=0.8),
        )

    plt.tight_layout()
    plt.savefig("fiber_profiles.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved fiber_profiles.png")


def plot_deficiency_monotonicity():
    """Plot deficiency growth under iterated composition."""
    fig, ax = plt.subplots(figsize=(10, 6))

    domain = list(range(24))
    f = lambda x: x % 8
    g = lambda x: x % 4
    h = lambda x: x % 2

    compositions = [
        ("id", lambda x: x),
        ("f = mod 8", f),
        ("g ∘ f = mod 4", lambda x: g(f(x))),
        ("h ∘ g ∘ f = mod 2", lambda x: h(g(f(x)))),
        ("const ∘ ... = const", lambda x: 0),
    ]

    names = [c[0] for c in compositions]
    defs = [deficiency(c[1], domain) for c in compositions]
    image_sizes = [len(set(c[1](x) for x in domain)) for c in compositions]

    x = np.arange(len(names))
    width = 0.35

    bars1 = ax.bar(x - width / 2, defs, width, label="Deficiency", color="#e74c3c", alpha=0.8)
    bars2 = ax.bar(x + width / 2, image_sizes, width, label="|Image|", color="#3498db", alpha=0.8)

    # Add the sum line
    for i in range(len(names)):
        ax.plot([i - width, i + width], [24, 24], "k--", alpha=0.3)

    ax.set_xlabel("Composition chain", fontsize=12)
    ax.set_ylabel("Count", fontsize=12)
    ax.set_title(
        "Combinatorial Second Law: Deficiency ↑ as Compositions Accumulate\n"
        "(domain = {0,...,23}, deficiency + |image| = 24 always)",
        fontsize=13, fontweight="bold",
    )
    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=15, ha="right")
    ax.legend()
    ax.set_ylim(0, 28)

    # Annotate unity theorem
    for i in range(len(names)):
        ax.annotate(
            f"{defs[i]}+{image_sizes[i]}=24",
            xy=(i, 25),
            ha="center",
            fontsize=8,
            color="gray",
        )

    plt.tight_layout()
    plt.savefig("deficiency_monotonicity.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved deficiency_monotonicity.png")


def plot_renyi_spectrum():
    """Plot the Rényi entropy spectrum for different fiber profiles."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n = 12
    profiles = {
        "Uniform {3,3,3,3}": [3, 3, 3, 3],
        "Skewed {6,3,2,1}": [6, 3, 2, 1],
        "Binary {6,6}": [6, 6],
        "Singleton {12}": [12],
        "Flat {1}×12": [1] * 12,
    }

    alphas = np.concatenate([np.linspace(0.01, 0.99, 30), np.linspace(1.01, 10, 50)])
    colors = ["#e74c3c", "#3498db", "#2ecc71", "#9b59b6", "#f39c12"]

    for (name, profile), color in zip(profiles.items(), colors):
        entropies = [fiber_renyi_entropy(profile, n, a) for a in alphas]
        ax.plot(alphas, entropies, label=name, color=color, linewidth=2)

        # Mark Shannon entropy (alpha=1)
        h1 = fiber_renyi_entropy(profile, n, 1.0)
        ax.plot(1.0, h1, "o", color=color, markersize=8)

    ax.axvline(x=1.0, color="gray", linestyle="--", alpha=0.5, label="α=1 (Shannon)")
    ax.set_xlabel("Rényi order α", fontsize=12)
    ax.set_ylabel("H_α (bits)", fontsize=12)
    ax.set_title(
        "Rényi Entropy Spectrum of Fiber Profiles (domain size = 12)",
        fontsize=13, fontweight="bold",
    )
    ax.legend(fontsize=9)
    ax.set_xlim(0, 10)
    ax.set_ylim(-0.5, 4.5)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("renyi_spectrum.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved renyi_spectrum.png")


if __name__ == "__main__":
    plot_fiber_profiles()
    plot_deficiency_monotonicity()
    plot_renyi_spectrum()
