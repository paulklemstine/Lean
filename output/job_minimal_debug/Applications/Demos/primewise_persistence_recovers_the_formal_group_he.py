"""
Applications of Arithmetic Persistence to K3 Surface Classification

This module demonstrates real-world applications of the primewise arithmetic
persistence framework, including:
1. Automated height regime detection from Frobenius slope data
2. Family classification for K3 surfaces
3. Stability analysis for noisy arithmetic data
4. Tropical threshold analysis

All functions are self-contained with inline implementations.
"""

from fractions import Fraction
from typing import List, Tuple, Dict, Optional
import random
import math


# ---- Core implementations (inline) ----

class SlopeProfile:
    def __init__(self, p: int, slopes: List[float], center: float = 1.0):
        self.p = p
        self.slopes = slopes
        self.center = center

def height_sig(prof: SlopeProfile, eps: float) -> int:
    return sum(1 for s in prof.slopes if abs(s - prof.center) <= eps)

def trop_defect(prof: SlopeProfile, t: float) -> float:
    if not prof.slopes:
        return 0.0
    return max(max(0.0, abs(s - prof.center) - t) for s in prof.slopes)

def min_dev(prof: SlopeProfile) -> float:
    devs = [abs(s - prof.center) for s in prof.slopes if abs(s - prof.center) > 1e-15]
    return min(devs) if devs else 0.0

def classify(prof: SlopeProfile, eps: float) -> str:
    if len(prof.slopes) == height_sig(prof, eps):
        return "supersingular"
    return "finite-height"


# ---- Application 1: Automated Height Detection Pipeline ----

def detect_height_regime(slopes: List[float], prime: int,
                        center: float = 1.0) -> Dict:
    """Full height regime detection pipeline.

    Takes raw slope data and returns a comprehensive analysis including:
    - Classification (supersingular vs finite-height)
    - Confidence metrics
    - Stability radius
    - Recommended threshold

    Args:
        slopes: List of Frobenius slopes
        prime: The reduction prime
        center: Symmetry center (default 1.0 for weight 2)

    Returns:
        Dictionary with classification results and metrics

    Example:
        >>> result = detect_height_regime([1.0]*22, 5)
        >>> result['classification']
        'supersingular'
    """
    prof = SlopeProfile(prime, slopes, center)
    md = min_dev(prof)
    td0 = trop_defect(prof, 0)

    # Adaptive threshold selection
    if md > 0:
        eps_optimal = md / 2
    else:
        eps_optimal = 0.1  # default for supersingular

    classification = classify(prof, eps_optimal)

    # Confidence: how far from the decision boundary
    sig_ratio = height_sig(prof, eps_optimal) / len(slopes) if slopes else 0
    confidence = abs(sig_ratio - 0.5) * 2  # 0 = uncertain, 1 = certain

    return {
        'classification': classification,
        'prime': prime,
        'num_slopes': len(slopes),
        'min_deviation': md,
        'tropical_defect_0': td0,
        'optimal_threshold': eps_optimal,
        'signature_at_optimal': height_sig(prof, eps_optimal),
        'stability_radius': md / 2 if md > 0 else float('inf'),
        'confidence': confidence,
    }


# ---- Application 2: Family Classification ----

def classify_family(slope_data: Dict[int, List[float]],
                    center: float = 1.0) -> Dict:
    """Classify an entire family of K3 reductions across primes.

    Args:
        slope_data: Dictionary mapping prime -> list of slopes
        center: Symmetry center

    Returns:
        Classification summary with statistics
    """
    results = {}
    ss_count = 0
    fh_count = 0

    for prime, slopes in sorted(slope_data.items()):
        result = detect_height_regime(slopes, prime, center)
        results[prime] = result
        if result['classification'] == 'supersingular':
            ss_count += 1
        else:
            fh_count += 1

    total = len(slope_data)
    return {
        'per_prime': results,
        'total_primes': total,
        'supersingular_count': ss_count,
        'finite_height_count': fh_count,
        'supersingular_density': ss_count / total if total > 0 else 0,
        'summary': f"{ss_count} supersingular, {fh_count} finite-height out of {total} primes"
    }


# ---- Application 3: Stability Analysis ----

def stability_analysis(slopes: List[float], prime: int,
                       noise_levels: List[float],
                       num_trials: int = 100,
                       center: float = 1.0) -> Dict:
    """Analyze classification stability under noise.

    Tests how robust the classification is to perturbations of the slope data.

    Args:
        slopes: Base slope data
        prime: The prime
        noise_levels: List of noise magnitudes to test
        num_trials: Number of random trials per noise level
        center: Symmetry center

    Returns:
        Stability report with accuracy at each noise level
    """
    prof = SlopeProfile(prime, slopes, center)
    md = min_dev(prof)
    base_class = classify(prof, md / 2 if md > 0 else 0.1)

    report = {
        'base_classification': base_class,
        'min_deviation': md,
        'stability_radius': md / 2 if md > 0 else float('inf'),
        'noise_results': {}
    }

    rng = random.Random(42)
    for delta in noise_levels:
        correct = 0
        for trial in range(num_trials):
            noisy_slopes = [s + rng.uniform(-delta, delta) for s in slopes]
            noisy_prof = SlopeProfile(prime, noisy_slopes, center)
            eps = md / 2 if md > 0 else 0.1
            if classify(noisy_prof, eps) == base_class:
                correct += 1
        report['noise_results'][delta] = {
            'accuracy': correct / num_trials,
            'within_stability_radius': delta < md / 2 if md > 0 else True
        }

    return report


# ---- Application 4: Tropical Threshold Analysis ----

def tropical_threshold_analysis(slopes: List[float], prime: int,
                                center: float = 1.0) -> Dict:
    """Analyze the tropical defect curve to identify breakpoints.

    The breakpoints of the tropical defect function correspond to
    slope deviations and determine the jump parameters of the
    persistent rank function.

    Args:
        slopes: Slope data
        prime: The prime
        center: Symmetry center

    Returns:
        Analysis of tropical defect breakpoints
    """
    prof = SlopeProfile(prime, slopes, center)

    # Compute deviations (breakpoints)
    deviations = sorted(set(abs(s - center) for s in slopes))

    # Compute tropical defect at breakpoints
    breakpoints = []
    for d in deviations:
        td_before = trop_defect(prof, d - 1e-10)
        td_at = trop_defect(prof, d)
        td_after = trop_defect(prof, d + 1e-10)
        breakpoints.append({
            'deviation': d,
            'defect_before': td_before,
            'defect_at': td_at,
            'defect_after': td_after,
            'is_breakpoint': abs(td_before - td_at) > 1e-8
        })

    # Find vanishing threshold
    max_dev = max(deviations) if deviations else 0
    vanishing_t = max_dev

    return {
        'deviations': deviations,
        'breakpoints': breakpoints,
        'vanishing_threshold': vanishing_t,
        'is_supersingular': max_dev < 1e-10,
        'num_breakpoints': sum(1 for b in breakpoints if b['is_breakpoint']),
    }


# ---- Demo ----

if __name__ == "__main__":
    print("=" * 60)
    print("Applications of Arithmetic Persistence")
    print("=" * 60)

    # App 1: Single profile analysis
    print("\n--- Application 1: Automated Height Detection ---")
    test_cases = [
        ("Supersingular", [1.0] * 22, 5),
        ("Ordinary h=1", [0.0] + [1.0]*20 + [2.0], 7),
        ("Height 3", [1.0 + k/3 for k in range(1,4)] +
                     [1.0 - k/3 for k in range(1,4)] + [1.0]*16, 11),
    ]
    for name, slopes, p in test_cases:
        result = detect_height_regime(slopes, p)
        print(f"\n  {name} (p={p}):")
        for k, v in result.items():
            print(f"    {k}: {v}")

    # App 2: Family classification
    print("\n--- Application 2: Family Classification ---")
    family_data = {}
    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for p in primes:
        if p % 4 == 3:  # "supersingular" primes
            family_data[p] = [1.0] * 22
        else:
            family_data[p] = [0.0] + [1.0]*20 + [2.0]

    family_result = classify_family(family_data)
    print(f"  {family_result['summary']}")
    print(f"  Supersingular density: {family_result['supersingular_density']:.1%}")

    # App 3: Stability analysis
    print("\n--- Application 3: Stability Analysis ---")
    base_slopes = [0.0] + [1.0]*20 + [2.0]
    stab = stability_analysis(base_slopes, 7, [0.01, 0.05, 0.1, 0.3, 0.5])
    print(f"  Base: {stab['base_classification']}, stability radius: {stab['stability_radius']:.4f}")
    for delta, res in stab['noise_results'].items():
        print(f"  δ={delta:.2f}: accuracy={res['accuracy']:.0%}, within_radius={res['within_stability_radius']}")

    # App 4: Tropical analysis
    print("\n--- Application 4: Tropical Threshold Analysis ---")
    slopes = [0.5, 0.8, 1.0, 1.0, 1.2, 1.5]
    trop = tropical_threshold_analysis(slopes, 7)
    print(f"  Deviations: {trop['deviations']}")
    print(f"  Vanishing threshold: {trop['vanishing_threshold']}")
    print(f"  Number of breakpoints: {trop['num_breakpoints']}")
    for bp in trop['breakpoints']:
        if bp['is_breakpoint']:
            print(f"    Breakpoint at d={bp['deviation']:.4f}: "
                  f"defect {bp['defect_before']:.4f} → {bp['defect_at']:.4f}")

    print("\n" + "=" * 60)
    print("All applications completed.")


"""
Arithmetic Persistence for K3 Height Detection — Interactive Demo

This script demonstrates the primewise arithmetic persistence framework
for detecting formal Brauer group height dichotomies in K3 surface reductions.

It constructs synthetic slope profiles representing different reduction types,
computes persistence invariants, tests stability under perturbation, and
visualizes barcode-like threshold curves.

Requirements: matplotlib, numpy
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from fractions import Fraction
from typing import List, Tuple
import random

# ---- Inline core algorithms (self-contained) ----

class SlopeProfile:
    """Slope profile for arithmetic persistence."""
    def __init__(self, p: int, slopes: list, center: float = 1.0, label: str = ""):
        self.p = p
        self.slopes = [float(s) for s in slopes]
        self.center = center
        self.label = label

    @property
    def n(self):
        return len(self.slopes)

def height_signature(profile: SlopeProfile, eps: float) -> int:
    return sum(1 for s in profile.slopes if abs(s - profile.center) <= eps)

def persistent_rank(profile: SlopeProfile, t: float) -> int:
    return height_signature(profile, t)

def tropical_defect(profile: SlopeProfile, t: float) -> float:
    if not profile.slopes:
        return 0.0
    return max(max(0.0, abs(s - profile.center) - t) for s in profile.slopes)

def classify(profile: SlopeProfile, eps: float) -> bool:
    return len(profile.slopes) == height_signature(profile, eps)

def min_deviation(profile: SlopeProfile) -> float:
    devs = [abs(s - profile.center) for s in profile.slopes if abs(s - profile.center) > 1e-15]
    return min(devs) if devs else 0.0

def is_supersingular(profile: SlopeProfile) -> bool:
    return all(abs(s - profile.center) < 1e-15 for s in profile.slopes)


# ---- Profile constructors ----

def supersingular(p: int, n: int = 22) -> SlopeProfile:
    return SlopeProfile(p, [1.0] * n, label=f"Supersingular (p={p})")

def ordinary(p: int) -> SlopeProfile:
    slopes = [0.0] + [1.0] * 20 + [2.0]
    return SlopeProfile(p, slopes, label=f"Ordinary h=1 (p={p})")

def finite_height(p: int, h: int) -> SlopeProfile:
    slopes = []
    for k in range(1, h + 1):
        slopes.append(1.0 + k / h)
        slopes.append(1.0 - k / h)
    slopes.extend([1.0] * (22 - len(slopes)))
    return SlopeProfile(p, slopes, label=f"Height h={h} (p={p})")

def perturbed(profile: SlopeProfile, delta: float, seed: int = 42) -> SlopeProfile:
    rng = random.Random(seed)
    new_slopes = [s + rng.uniform(-delta, delta) for s in profile.slopes]
    return SlopeProfile(profile.p, new_slopes,
                       label=f"{profile.label} + noise δ={delta}")


# ---- Demo 1: Profile comparison ----

def demo_profiles():
    """Compare height signatures across reduction types."""
    print("=" * 60)
    print("DEMO 1: Slope Profile Comparison")
    print("=" * 60)

    profiles = [
        supersingular(5),
        ordinary(7),
        finite_height(11, 2),
        finite_height(13, 5),
        finite_height(17, 10),
    ]

    for prof in profiles:
        md = min_deviation(prof)
        print(f"\n{prof.label}:")
        print(f"  #slopes = {prof.n}")
        print(f"  Supersingular: {is_supersingular(prof)}")
        print(f"  Min deviation: {md:.6f}")
        print(f"  Tropical defect at t=0: {tropical_defect(prof, 0):.6f}")
        for eps in [0.01, 0.1, 0.5, 1.0]:
            sig = height_signature(prof, eps)
            cls = classify(prof, eps)
            print(f"  ε={eps:.2f}: signature={sig}/{prof.n}, classify={cls}")


# ---- Demo 2: Persistent rank curves ----

def demo_persistent_rank():
    """Plot persistent rank curves showing monotone filtration behavior."""
    print("\n" + "=" * 60)
    print("DEMO 2: Persistent Rank Curves")
    print("=" * 60)

    profiles = [
        supersingular(5),
        ordinary(7),
        finite_height(11, 2),
        finite_height(13, 5),
    ]

    t_values = np.linspace(0, 2.0, 500)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    for prof in profiles:
        ranks = [persistent_rank(prof, t) for t in t_values]
        ax1.plot(t_values, ranks, label=prof.label, linewidth=2)

    ax1.set_xlabel("Filtration parameter t", fontsize=12)
    ax1.set_ylabel("Persistent rank r(t)", fontsize=12)
    ax1.set_title("Persistent Rank Functions", fontsize=14)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-0.5, 23)

    # Tropical defect curves
    for prof in profiles:
        defects = [tropical_defect(prof, t) for t in t_values]
        ax2.plot(t_values, defects, label=prof.label, linewidth=2)

    ax2.set_xlabel("Threshold t", fontsize=12)
    ax2.set_ylabel("Tropical defect τ(t)", fontsize=12)
    ax2.set_title("Tropical Defect Functions", fontsize=14)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("persistent_rank_curves.png", dpi=150, bbox_inches='tight')
    print("Saved: persistent_rank_curves.png")
    plt.close()


# ---- Demo 3: Stability under perturbation ----

def demo_stability():
    """Test classifier stability under bounded perturbation."""
    print("\n" + "=" * 60)
    print("DEMO 3: Perturbation Stability")
    print("=" * 60)

    base = finite_height(11, 3)
    md = min_deviation(base)
    print(f"\nBase profile: {base.label}")
    print(f"Min deviation: {md:.6f}")
    print(f"Stability radius: {md/2:.6f}")

    deltas = [0.0, 0.01, 0.05, 0.1, 0.15, md/2 - 0.01, md/2, md/2 + 0.01, md]
    eps_test = md / 2

    print(f"\nClassification at ε = {eps_test:.6f} under perturbation:")
    print(f"{'δ':>10} {'classify':>10} {'signature':>12} {'stable?':>10}")
    print("-" * 45)

    base_cls = classify(base, eps_test)
    for delta in deltas:
        if delta < 0:
            continue
        pert = perturbed(base, delta)
        cls = classify(pert, eps_test)
        sig = height_signature(pert, eps_test)
        stable = "✓" if cls == base_cls else "✗"
        print(f"{delta:10.6f} {str(cls):>10} {sig:>8}/{pert.n:<4} {stable:>10}")

    # Plot stability landscape
    fig, ax = plt.subplots(figsize=(10, 5))
    delta_range = np.linspace(0, md * 1.5, 50)
    eps_range = np.linspace(0.01, 1.5, 50)

    stability_map = np.zeros((len(eps_range), len(delta_range)))
    for i, eps in enumerate(eps_range):
        for j, delta in enumerate(delta_range):
            # Average over several random perturbations
            correct = 0
            for seed in range(10):
                pert = perturbed(base, delta, seed=seed)
                if classify(pert, eps) == classify(base, eps):
                    correct += 1
            stability_map[i, j] = correct / 10

    im = ax.imshow(stability_map, aspect='auto', origin='lower',
                   extent=[0, md*1.5, 0.01, 1.5], cmap='RdYlGn')
    ax.set_xlabel("Perturbation δ", fontsize=12)
    ax.set_ylabel("Scale ε", fontsize=12)
    ax.set_title(f"Classification Stability Map — {base.label}", fontsize=14)
    ax.axvline(x=md/2, color='white', linestyle='--', linewidth=2,
               label=f'Stability radius = {md/2:.3f}')
    ax.legend(fontsize=10)
    plt.colorbar(im, label="Fraction correct", ax=ax)
    plt.tight_layout()
    plt.savefig("stability_map.png", dpi=150, bbox_inches='tight')
    print("Saved: stability_map.png")
    plt.close()


# ---- Demo 4: Benchmark families ----

def demo_benchmark_families():
    """Test classification on K3-inspired benchmark families."""
    print("\n" + "=" * 60)
    print("DEMO 4: Benchmark K3 Families")
    print("=" * 60)

    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]

    # Family 1: Diagonal quartic (mostly ordinary, supersingular at p ≡ 3 mod 4)
    print("\nFamily 1: Diagonal quartic model")
    print(f"{'prime':>6} {'type':>15} {'td(0)':>10} {'classify(0.5)':>15}")
    print("-" * 50)
    for p in primes:
        if p % 4 == 3:
            prof = supersingular(p)
            ptype = "supersingular"
        else:
            prof = ordinary(p)
            ptype = "ordinary"
        td = tropical_defect(prof, 0)
        cls = classify(prof, 0.5)
        print(f"{p:6d} {ptype:>15} {td:10.4f} {str(cls):>15}")

    # Family 2: Height-varying family
    print("\nFamily 2: Height-varying family")
    print(f"{'prime':>6} {'height':>8} {'min_dev':>10} {'td(0)':>10} {'classify(0.1)':>15}")
    print("-" * 55)
    for p in primes[:10]:
        h = (p % 10) + 1
        if h > 10:
            h = 10
        prof = finite_height(p, h)
        md = min_deviation(prof)
        td = tropical_defect(prof, 0)
        cls = classify(prof, 0.1)
        print(f"{p:6d} {h:8d} {md:10.4f} {td:10.4f} {str(cls):>15}")

    # Family 3: Kummer surface model
    print("\nFamily 3: Kummer surface model (symmetric slopes)")
    print(f"{'prime':>6} {'#noncentral':>12} {'min_dev':>10} {'td(0)':>10}")
    print("-" * 45)
    for p in primes[:8]:
        # Kummer: slopes come in symmetric pairs around 1
        n_pairs = p % 5 + 1
        slopes = [1.0] * (22 - 2 * n_pairs)
        for k in range(1, n_pairs + 1):
            slopes.extend([1.0 + k * 0.1, 1.0 - k * 0.1])
        prof = SlopeProfile(p, slopes, label=f"Kummer p={p}")
        md = min_deviation(prof)
        td = tropical_defect(prof, 0)
        print(f"{p:6d} {2*n_pairs:12d} {md:10.4f} {td:10.4f}")


# ---- Demo 5: Classification accuracy ----

def demo_classification_accuracy():
    """Measure classification accuracy on synthetic data."""
    print("\n" + "=" * 60)
    print("DEMO 5: Classification Accuracy")
    print("=" * 60)

    # Generate profiles with known types
    N = 100
    correct_td = 0  # tropical defect classifier
    correct_sig = 0  # height signature classifier

    rng = random.Random(123)

    for _ in range(N):
        p = rng.choice([5, 7, 11, 13, 17, 19, 23, 29, 31, 37])
        is_ss = rng.random() < 0.3  # 30% supersingular

        if is_ss:
            prof = supersingular(p)
        else:
            h = rng.randint(1, 10)
            prof = finite_height(p, h)

        # Add noise
        prof = perturbed(prof, 0.01, seed=rng.randint(0, 10000))

        # Tropical defect classifier: td(0) ≈ 0 → supersingular
        td = tropical_defect(prof, 0)
        pred_td = td < 0.05  # threshold

        # Height signature classifier at ε = 0.05
        pred_sig = classify(prof, 0.05)

        if pred_td == is_ss:
            correct_td += 1
        if pred_sig == is_ss:
            correct_sig += 1

    print(f"\nClassification on {N} profiles (30% supersingular, noise δ=0.01):")
    print(f"  Tropical defect classifier: {correct_td}/{N} = {correct_td/N:.1%} accuracy")
    print(f"  Height signature classifier: {correct_sig}/{N} = {correct_sig/N:.1%} accuracy")
    print(f"  Random baseline: ~50% accuracy")


# ---- Main ----

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Arithmetic Persistence for K3 Height Detection — Demo  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_profiles()
    demo_persistent_rank()
    demo_stability()
    demo_benchmark_families()
    demo_classification_accuracy()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("Generated plots: persistent_rank_curves.png, stability_map.png")
    print("=" * 60)


"""
Visualization: Persistent Rank and Tropical Defect Curves

Visualizes the core invariants of arithmetic persistence theory:
- Persistent rank functions r(t) showing monotone filtration behavior
- Tropical defect functions τ(t) showing supersingular collapse
- Height signature comparison across reduction types

The key insight: supersingular profiles produce flat maximal persistent rank
and identically zero tropical defect, while finite-height profiles show
characteristic jumps whose locations encode the formal Brauer group height.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

# ---- Inline implementations ----

def height_signature(slopes, center, eps):
    return sum(1 for s in slopes if abs(s - center) <= eps)

def tropical_defect(slopes, center, t):
    if not slopes:
        return 0.0
    return max(max(0.0, abs(s - center) - t) for s in slopes)

# ---- Profile data ----

def supersingular_slopes(n=22):
    return [1.0] * n

def ordinary_slopes():
    return [0.0] + [1.0] * 20 + [2.0]

def height_h_slopes(h):
    slopes = []
    for k in range(1, h + 1):
        slopes.append(1.0 + k / h)
        slopes.append(1.0 - k / h)
    slopes.extend([1.0] * (22 - len(slopes)))
    return slopes

# ---- Build figure ----

center = 1.0
t_vals = np.linspace(0, 2.5, 1000)

profiles = {
    'Supersingular (h=∞)': supersingular_slopes(),
    'Ordinary (h=1)': ordinary_slopes(),
    'Height h=2': height_h_slopes(2),
    'Height h=5': height_h_slopes(5),
    'Height h=10': height_h_slopes(10),
}

colors = ['#e74c3c', '#2ecc71', '#3498db', '#9b59b6', '#f39c12']

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Persistent rank curves
ax = axes[0, 0]
for (name, slopes), color in zip(profiles.items(), colors):
    ranks = [height_signature(slopes, center, t) for t in t_vals]
    ax.plot(t_vals, ranks, label=name, color=color, linewidth=2)
ax.set_xlabel('Filtration parameter t', fontsize=11)
ax.set_ylabel('Persistent rank r(t)', fontsize=11)
ax.set_title('(a) Persistent Rank Functions', fontsize=13, fontweight='bold')
ax.legend(fontsize=8, loc='lower right')
ax.grid(True, alpha=0.2)
ax.set_ylim(-0.5, 23)
ax.axhline(y=22, color='gray', linestyle=':', alpha=0.5, label='maximal rank')

# Panel 2: Tropical defect curves
ax = axes[0, 1]
for (name, slopes), color in zip(profiles.items(), colors):
    defects = [tropical_defect(slopes, center, t) for t in t_vals]
    ax.plot(t_vals, defects, label=name, color=color, linewidth=2)
ax.set_xlabel('Threshold t', fontsize=11)
ax.set_ylabel('Tropical defect τ(t)', fontsize=11)
ax.set_title('(b) Tropical Defect Functions', fontsize=13, fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.2)

# Panel 3: Slope distributions
ax = axes[1, 0]
for i, (name, slopes) in enumerate(profiles.items()):
    y_offset = i * 0.4
    devs = sorted([abs(s - center) for s in slopes])
    ax.scatter(devs, [y_offset] * len(devs), color=colors[i], s=40, alpha=0.7,
              zorder=5, edgecolors='black', linewidth=0.5)
    ax.annotate(name, (-0.05, y_offset), fontsize=8, ha='right', va='center')
ax.set_xlabel('|slope − center|', fontsize=11)
ax.set_title('(c) Slope Deviation Distributions', fontsize=13, fontweight='bold')
ax.set_yticks([])
ax.grid(True, alpha=0.2, axis='x')
ax.set_xlim(-0.1, 1.5)

# Panel 4: Classification phase diagram
ax = axes[1, 1]
heights = list(range(1, 11)) + [0]  # 0 = supersingular
eps_range = np.linspace(0.01, 1.5, 200)

phase_data = np.zeros((len(heights), len(eps_range)))
for i, h in enumerate(heights):
    if h == 0:
        slopes = supersingular_slopes()
    else:
        slopes = height_h_slopes(h)
    for j, eps in enumerate(eps_range):
        sig = height_signature(slopes, center, eps)
        phase_data[i, j] = sig / 22.0

im = ax.imshow(phase_data, aspect='auto', origin='lower',
              extent=[eps_range[0], eps_range[-1], -0.5, len(heights)-0.5],
              cmap='viridis', vmin=0, vmax=1)
ax.set_yticks(range(len(heights)))
ax.set_yticklabels([f'h={h}' if h > 0 else 'SS' for h in heights], fontsize=8)
ax.set_xlabel('Scale ε', fontsize=11)
ax.set_title('(d) Height Signature Heatmap', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax, label='Normalized signature', shrink=0.8)

plt.suptitle('Arithmetic Persistence Invariants for K3 Height Detection',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_persistence_curves.png', dpi=150, bbox_inches='tight')
print("Saved: viz_persistence_curves.png")
plt.close()


"""
Visualization: Stability of Arithmetic Persistence Classifier

Demonstrates the stability theorem: the height regime classifier is robust
under bounded perturbation of slope data, with stability radius equal to
half the minimal nonzero deviation from the symmetry center.

This visualizes the key result that makes the framework computationally viable:
even with noisy or approximate Frobenius data, the supersingular/finite-height
dichotomy can be reliably detected.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random

# ---- Inline implementations ----

def height_signature(slopes, center, eps):
    return sum(1 for s in slopes if abs(s - center) <= eps)

def classify(slopes, center, eps):
    return len(slopes) == height_signature(slopes, center, eps)

def min_deviation(slopes, center):
    devs = [abs(s - center) for s in slopes if abs(s - center) > 1e-15]
    return min(devs) if devs else 0.0

def perturb(slopes, delta, rng):
    return [s + rng.uniform(-delta, delta) for s in slopes]

# ---- Profile constructors ----

def ordinary_slopes():
    return [0.0] + [1.0] * 20 + [2.0]

def height_h_slopes(h):
    slopes = []
    for k in range(1, h + 1):
        slopes.append(1.0 + k / h)
        slopes.append(1.0 - k / h)
    slopes.extend([1.0] * (22 - len(slopes)))
    return slopes

# ---- Build figure ----

center = 1.0
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

test_profiles = [
    ('Ordinary (h=1)', ordinary_slopes()),
    ('Height h=3', height_h_slopes(3)),
    ('Height h=8', height_h_slopes(8)),
]

for ax_idx, (name, base_slopes) in enumerate(test_profiles):
    ax = axes[ax_idx]
    md = min_deviation(base_slopes, center)
    stab_r = md / 2

    delta_range = np.linspace(0, md * 2, 40)
    eps_range = np.linspace(0.01, 1.5, 40)

    rng = random.Random(42)
    accuracy_map = np.zeros((len(eps_range), len(delta_range)))

    for i, eps in enumerate(eps_range):
        base_cls = classify(base_slopes, center, eps)
        for j, delta in enumerate(delta_range):
            correct = 0
            num_trials = 30
            for _ in range(num_trials):
                noisy = perturb(base_slopes, delta, rng)
                if classify(noisy, center, eps) == base_cls:
                    correct += 1
            accuracy_map[i, j] = correct / num_trials

    im = ax.imshow(accuracy_map, aspect='auto', origin='lower',
                  extent=[0, md*2, eps_range[0], eps_range[-1]],
                  cmap='RdYlGn', vmin=0, vmax=1)
    ax.axvline(x=stab_r, color='white', linestyle='--', linewidth=2.5)
    ax.text(stab_r + md*0.05, eps_range[-1]*0.9,
           f'r = {stab_r:.3f}', color='white', fontsize=9, fontweight='bold')
    ax.set_xlabel('Perturbation δ', fontsize=11)
    if ax_idx == 0:
        ax.set_ylabel('Scale ε', fontsize=11)
    ax.set_title(f'{name}\nmin. dev. = {md:.3f}', fontsize=11, fontweight='bold')

plt.colorbar(im, ax=axes.tolist(), label='Classification accuracy', shrink=0.8)
plt.suptitle('Classification Stability Under Slope Perturbation',
            fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_stability.png', dpi=150, bbox_inches='tight')
print("Saved: viz_stability.png")
plt.close()


"""
Visualization: Tropical Defect as Height Detector

Shows the cross-domain connection between arithmetic slope data and tropical
geometry through the tropical defect function. The key theorem:
the tropical defect vanishes identically at all non-negative thresholds
if and only if the profile is supersingular.

This visualization demonstrates how slope concentration produces tropical
collapse — the min-plus analogue of the height dichotomy.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ---- Inline implementations ----

def tropical_defect(slopes, center, t):
    if not slopes:
        return 0.0
    return max(max(0.0, abs(s - center) - t) for s in slopes)

def height_signature(slopes, center, eps):
    return sum(1 for s in slopes if abs(s - center) <= eps)

# ---- Profiles ----

center = 1.0

profiles = {
    'Supersingular': [1.0] * 22,
    'Height 1 (ordinary)': [0.0] + [1.0]*20 + [2.0],
    'Height 2': [1.0 + k/2 for k in range(1,3)] + [1.0 - k/2 for k in range(1,3)] + [1.0]*18,
    'Height 5': [1.0 + k/5 for k in range(1,6)] + [1.0 - k/5 for k in range(1,6)] + [1.0]*12,
}

colors = ['#e74c3c', '#2ecc71', '#3498db', '#9b59b6']

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Tropical defect curves
ax = axes[0, 0]
t_vals = np.linspace(0, 2.0, 500)
for (name, slopes), color in zip(profiles.items(), colors):
    defects = [tropical_defect(slopes, center, t) for t in t_vals]
    ax.plot(t_vals, defects, label=name, color=color, linewidth=2.5)

    # Mark breakpoints
    devs = sorted(set(abs(s - center) for s in slopes))
    for d in devs:
        if d > 0:
            td = tropical_defect(slopes, center, d)
            ax.plot(d, td, 'o', color=color, markersize=6, zorder=5)

ax.set_xlabel('Threshold t', fontsize=12)
ax.set_ylabel('Tropical defect τ(t)', fontsize=12)
ax.set_title('(a) Tropical Defect Functions', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)

# Panel 2: Derivative of tropical defect (slope detection)
ax = axes[0, 1]
dt = t_vals[1] - t_vals[0]
for (name, slopes), color in zip(profiles.items(), colors):
    defects = np.array([tropical_defect(slopes, center, t) for t in t_vals])
    ddefects = -np.gradient(defects, dt)  # Negative derivative (defect decreases)
    ax.plot(t_vals, ddefects, label=name, color=color, linewidth=1.5, alpha=0.8)

ax.set_xlabel('Threshold t', fontsize=12)
ax.set_ylabel('-dτ/dt', fontsize=12)
ax.set_title('(b) Tropical Defect Derivative\n(Jump Detection)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 3: Combined persistence + tropical view
ax = axes[1, 0]
slopes_h3 = [1.0 + k/3 for k in range(1,4)] + [1.0 - k/3 for k in range(1,4)] + [1.0]*16
t_fine = np.linspace(0, 2.0, 1000)

ranks = [height_signature(slopes_h3, center, t) / 22 for t in t_fine]
defects = [tropical_defect(slopes_h3, center, t) for t in t_fine]

ax.plot(t_fine, ranks, color='#3498db', linewidth=2.5, label='Normalized rank r(t)/n')
ax_twin = ax.twinx()
ax_twin.plot(t_fine, defects, color='#e74c3c', linewidth=2.5, linestyle='--',
            label='Tropical defect τ(t)')
ax_twin.set_ylabel('Tropical defect', fontsize=11, color='#e74c3c')

# Mark critical deviations
devs = sorted(set(abs(s - center) for s in slopes_h3))
for d in devs:
    if d > 0:
        ax.axvline(x=d, color='gray', linestyle=':', alpha=0.4)
        ax.annotate(f'd={d:.2f}', (d, 0.05), fontsize=7, rotation=90)

ax.set_xlabel('Parameter t', fontsize=12)
ax.set_ylabel('Normalized rank', fontsize=11, color='#3498db')
ax.set_title('(c) Height 3: Rank vs Tropical Defect', fontsize=13, fontweight='bold')
ax.legend(loc='center left', fontsize=9)
ax_twin.legend(loc='center right', fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 4: Phase transition diagram
ax = axes[1, 1]
heights = range(1, 11)
max_devs = []
vanishing_thresholds = []

for h in heights:
    slopes = [1.0 + k/h for k in range(1, h+1)] + \
             [1.0 - k/h for k in range(1, h+1)] + [1.0]*(22-2*h)
    md = max(abs(s - center) for s in slopes)
    max_devs.append(md)
    vanishing_thresholds.append(md)

ax.bar(list(heights), vanishing_thresholds, color='#3498db', alpha=0.7,
       edgecolor='navy', linewidth=1.5)
ax.plot(list(heights), [1.0]*len(heights), 'r--', linewidth=2,
       label='Symmetry center', alpha=0.5)
ax.set_xlabel('Formal Brauer group height h', fontsize=12)
ax.set_ylabel('Tropical vanishing threshold', fontsize=12)
ax.set_title('(d) Height vs Tropical Vanishing\n(Phase Transition)', fontsize=13, fontweight='bold')
ax.set_xticks(list(heights))
ax.legend(fontsize=10)
ax.grid(True, alpha=0.2, axis='y')

# Add annotation about supersingular limit
ax.annotate('h → ∞: threshold → 0\n(tropical collapse)',
           xy=(8, 0.3), fontsize=9, fontstyle='italic',
           bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle('Tropical Geometry Meets Arithmetic Persistence',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_tropical.png', dpi=150, bbox_inches='tight')
print("Saved: viz_tropical.png")
plt.close()
