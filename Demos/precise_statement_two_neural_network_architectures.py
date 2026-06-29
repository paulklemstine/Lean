#!/usr/bin/env python3
"""
Tropical Universality Theory — Applications

Real-world applications of the tropical universality framework:
1. Architecture comparison: identify equivalent architectures before training
2. Residual design analysis: predict which skip connections help
3. Scaling law prediction from architecture topology
4. Architecture search via tropical invariants
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import List, Dict, Tuple
from algorithms import (
    AffineForm, TropicalProfile, ComputationDAG, DAGEdge,
    parallel_compose, serial_compose, are_tropically_equivalent,
    extract_scaling_exponent, classify_universality
)


# ─── Application 1: Architecture Comparison ────────────────────────────

def app1_architecture_comparison():
    """Compare neural architectures by tropical invariants.

    Key insight: if two architectures have the same tropical profile,
    they will exhibit the same scaling behavior — no training needed.
    """
    print("=" * 60)
    print("APPLICATION 1: Architecture Comparison Without Training")
    print("=" * 60)

    # Architecture A: simple feedforward
    # Layer 1: 2 paths, Layer 2: 2 paths → 4 total paths
    arch_A = ComputationDAG([
        DAGEdge("in", "h1", AffineForm(1.0, 0.0)),
        DAGEdge("in", "h2", AffineForm(0.8, 0.5)),
        DAGEdge("h1", "out", AffineForm(1.5, -0.3)),
        DAGEdge("h2", "out", AffineForm(1.2, 0.2)),
    ])

    # Architecture B: different topology, possibly same profile
    arch_B = ComputationDAG([
        DAGEdge("in", "h1", AffineForm(0.5, 0.1)),
        DAGEdge("in", "h2", AffineForm(1.0, -0.1)),
        DAGEdge("in", "h3", AffineForm(0.7, 0.3)),
        DAGEdge("h1", "out", AffineForm(2.0, -0.4)),
        DAGEdge("h2", "out", AffineForm(1.5, 0.0)),
        DAGEdge("h3", "out", AffineForm(0.8, 0.5)),
    ])

    # Architecture C: with skip connection
    arch_C = ComputationDAG([
        DAGEdge("in", "h1", AffineForm(1.0, 0.0)),
        DAGEdge("in", "h2", AffineForm(0.8, 0.5)),
        DAGEdge("h1", "out", AffineForm(1.5, -0.3)),
        DAGEdge("h2", "out", AffineForm(1.2, 0.2)),
        DAGEdge("in", "out", AffineForm(2.5, -0.1)),  # skip connection
    ])

    profiles = {
        'A (feedforward)': arch_A.extract_tropical_profile(),
        'B (wide)': arch_B.extract_tropical_profile(),
        'C (residual)': arch_C.extract_tropical_profile(),
    }

    print("\nArchitecture analysis:")
    for name, prof in profiles.items():
        print(f"\n  {name}:")
        print(f"    Forms: {prof.forms}")
        print(f"    Max slope (exponent): {prof.max_slope:.3f}")
        print(f"    Essential bias: {prof.essential_dominant_bias:.3f}")
        print(f"    Dominant multiplicity: {prof.dominant_multiplicity}")

    # Check pairwise equivalence
    names = list(profiles.keys())
    profs = list(profiles.values())
    print("\n  Pairwise equivalence:")
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            equiv, _ = are_tropically_equivalent(profs[i], profs[j])
            same_class = (abs(profs[i].max_slope - profs[j].max_slope) < 1e-10)
            print(f"    {names[i]} vs {names[j]}: "
                  f"equivalent={equiv}, same_class={same_class}")

    # Predict scaling laws
    print("\n  Predicted scaling exponents (no training needed!):")
    N = np.logspace(3, 8, 200)
    for name, prof in profiles.items():
        alpha, _ = extract_scaling_exponent(prof, N)
        print(f"    {name}: α ≈ {alpha:.4f}")

    # Plot
    fig, ax = plt.subplots(figsize=(10, 6))
    x = np.linspace(-2, 5, 1000)
    for name, prof in profiles.items():
        ax.plot(x, prof.eval_max_array(x), linewidth=2, label=name)
    ax.set_title('Tropical Envelopes of Three Architectures')
    ax.set_xlabel('x (log scale parameter)')
    ax.set_ylabel('Envelope value')
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('app_architecture_comparison.png', dpi=150)
    print("\n  Plot saved: app_architecture_comparison.png")


# ─── Application 2: Residual Architecture Design ───────────────────────

def app2_residual_design():
    """Analyze how skip connections affect scaling exponents.

    Key theorem: for parallel composition (residual blocks),
    the asymptotic slope is the maximum of the branch slopes.
    The "fastest" branch determines long-run behavior.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Residual Architecture Design Guide")
    print("=" * 60)

    # Base architecture (backbone)
    backbone = TropicalProfile([
        AffineForm(2.0, 1.0),
        AffineForm(1.5, 3.0),
    ])

    # Different skip connections to try
    skips = {
        'Linear skip (slope=1)': TropicalProfile([AffineForm(1.0, 5.0)]),
        'Quadratic skip (slope=2)': TropicalProfile([AffineForm(2.0, 2.0)]),
        'Cubic skip (slope=3)': TropicalProfile([AffineForm(3.0, -1.0)]),
        'Multi-path skip': TropicalProfile([AffineForm(1.5, 4.0), AffineForm(2.5, 0.0)]),
    }

    print(f"\n  Backbone: max_slope = {backbone.max_slope}")

    for name, skip in skips.items():
        residual = parallel_compose(backbone, skip)
        print(f"\n  + {name}:")
        print(f"    Skip max slope: {skip.max_slope}")
        print(f"    Residual max slope: {residual.max_slope}")
        improvement = residual.max_slope - backbone.max_slope
        print(f"    Improvement: {'+' if improvement >= 0 else ''}{improvement:.2f}")
        if improvement > 0:
            print(f"    → Skip connection IMPROVES scaling exponent!")
        elif improvement == 0:
            print(f"    → Skip connection has no effect on scaling exponent")
        else:
            print(f"    → This shouldn't happen (max of maxes ≥ either)")

    print("\n  DESIGN RULE: A skip connection improves the scaling exponent")
    print("  if and only if its slope exceeds the backbone's max slope.")
    print("  This is the 'fastest branch wins' theorem.")


# ─── Application 3: Scaling Law Prediction ─────────────────────────────

def app3_scaling_prediction():
    """Predict scaling law curves from architecture topology alone.

    Demonstrates that tropical profiles can predict the shape
    of scaling curves without any training.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Scaling Law Prediction from Topology")
    print("=" * 60)

    # Define architectures as DAGs
    architectures = {
        'MLP-3': ComputationDAG([
            DAGEdge("in", "h1", AffineForm(1.0, 0.0)),
            DAGEdge("h1", "h2", AffineForm(1.0, 0.0)),
            DAGEdge("h2", "out", AffineForm(1.0, 0.0)),
        ]),
        'Wide-MLP': ComputationDAG([
            DAGEdge("in", "h1", AffineForm(0.5, 0.0)),
            DAGEdge("in", "h2", AffineForm(0.5, 0.0)),
            DAGEdge("in", "h3", AffineForm(0.5, 0.0)),
            DAGEdge("h1", "out", AffineForm(0.5, 0.0)),
            DAGEdge("h2", "out", AffineForm(0.5, 0.0)),
            DAGEdge("h3", "out", AffineForm(0.5, 0.0)),
        ]),
        'ResNet-2': ComputationDAG([
            DAGEdge("in", "h1", AffineForm(1.0, 0.0)),
            DAGEdge("h1", "out", AffineForm(1.0, 0.0)),
            DAGEdge("in", "out", AffineForm(0.5, 2.0)),  # skip
        ]),
    }

    N_values = np.logspace(2, 8, 200)
    log_N = np.log(N_values)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    for name, dag in architectures.items():
        profile = dag.extract_tropical_profile()
        alpha, beta = extract_scaling_exponent(profile, N_values)

        print(f"\n  {name}:")
        print(f"    Paths: {len(profile.forms)}")
        print(f"    Profile: {profile.forms}")
        print(f"    Predicted exponent α = {alpha:.4f}")
        print(f"    Max slope: {profile.max_slope}")

        # Plot envelope
        x = np.linspace(0, 20, 500)
        axes[0].plot(x, profile.eval_max_array(x), linewidth=2, label=name)

        # Plot predicted scaling law
        loss = np.exp(-profile.eval_max_array(log_N))
        axes[1].loglog(N_values, loss, linewidth=2, label=f'{name} (α={alpha:.2f})')

    axes[0].set_title('Tropical Envelopes')
    axes[0].set_xlabel('x')
    axes[0].set_ylabel('Envelope')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    axes[1].set_title('Predicted Scaling Laws')
    axes[1].set_xlabel('Parameter Count N')
    axes[1].set_ylabel('Loss L(N)')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('app_scaling_prediction.png', dpi=150)
    print("\n  Plot saved: app_scaling_prediction.png")


# ─── Application 4: Architecture Search ────────────────────────────────

def app4_architecture_search():
    """Use tropical invariants to prune architecture search space.

    Instead of training every candidate, compute tropical profiles
    and group architectures by universality class.
    Only train one representative per class.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Architecture Search via Tropical Invariants")
    print("=" * 60)

    # Generate candidate architectures by varying layer widths and skip patterns
    candidates = []
    descriptions = []

    for n_layers in [2, 3, 4]:
        for has_skip in [False, True]:
            for slope in [0.5, 1.0, 1.5]:
                edges = []
                prev = "in"
                for i in range(n_layers):
                    curr = f"h{i}"
                    edges.append(DAGEdge(prev, curr, AffineForm(slope, 0.0)))
                    prev = curr
                edges.append(DAGEdge(prev, "out", AffineForm(slope, 0.0)))

                if has_skip:
                    edges.append(DAGEdge("in", "out",
                                        AffineForm(slope * 0.8, 1.0)))

                dag = ComputationDAG(edges)
                profile = dag.extract_tropical_profile()
                candidates.append(profile)
                descriptions.append(
                    f"L={n_layers}, s={slope}, skip={has_skip}")

    # Classify by universality
    classes = classify_universality(candidates)

    print(f"\n  Total candidates: {len(candidates)}")
    print(f"  Universality classes: {len(classes)}")
    print(f"  Reduction: {len(candidates)} → {len(classes)} "
          f"({100*(1-len(classes)/len(candidates)):.0f}% savings)")

    print("\n  Classes:")
    for (s, b), indices in sorted(classes.items()):
        print(f"    Slope={s:.2f}, Bias={b:.2f}: "
              f"{len(indices)} architectures")
        for i in indices[:3]:  # show first 3
            print(f"      - {descriptions[i]}")
        if len(indices) > 3:
            print(f"      ... and {len(indices)-3} more")


# ─── Application 5: Serial vs Parallel Composition ─────────────────────

def app5_composition_algebra():
    """Demonstrate the algebra of architecture composition.

    Shows how serial and parallel composition interact with
    tropical invariants.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 5: Composition Algebra of Architectures")
    print("=" * 60)

    A = TropicalProfile([AffineForm(2, 1), AffineForm(1, 3)])
    B = TropicalProfile([AffineForm(3, -1), AffineForm(1.5, 2)])

    par = parallel_compose(A, B)
    ser = serial_compose(A, B)

    print(f"\n  Profile A: max_slope={A.max_slope}, bias={A.essential_dominant_bias}")
    print(f"  Profile B: max_slope={B.max_slope}, bias={B.essential_dominant_bias}")

    print(f"\n  Parallel (A ∥ B):")
    print(f"    max_slope = max({A.max_slope}, {B.max_slope}) = {par.max_slope}")
    print(f"    Forms: {par.forms}")

    print(f"\n  Serial (A ; B):")
    print(f"    max_slope = {ser.max_slope}")
    print(f"    Expected: {A.max_slope} + {B.max_slope} = {A.max_slope + B.max_slope}")
    print(f"    Forms: {ser.forms}")

    print(f"\n  KEY LAWS:")
    print(f"    Parallel: slope(A ∥ B) = max(slope(A), slope(B))  [proved in Lean]")
    print(f"    Serial:   slope(A ; B) ≤ slope(A) + slope(B)      [upper bound]")

    # Verify serial upper bound
    assert ser.max_slope <= A.max_slope + B.max_slope + 1e-10
    print(f"    Serial upper bound verified ✓")

    # Plot
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    x = np.linspace(-2, 5, 500)

    for ax, (prof, name) in zip(axes, [(A, 'Profile A'), (B, 'Profile B'),
                                        (par, 'Parallel A∥B')]):
        for f in prof.forms:
            ax.plot(x, f.eval_array(x), '--', alpha=0.4)
        ax.plot(x, prof.eval_max_array(x), 'k-', linewidth=2)
        ax.set_title(name)
        ax.set_xlabel('x')
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('app_composition_algebra.png', dpi=150)
    print("\n  Plot saved: app_composition_algebra.png")


# ─── Run All Applications ──────────────────────────────────────────────

if __name__ == "__main__":
    app1_architecture_comparison()
    app2_residual_design()
    app3_scaling_prediction()
    app4_architecture_search()
    app5_composition_algebra()

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Universality Theory — Demonstration Script

Demonstrates the key theorems with concrete numerical examples:
1. Tropical equivalence preserves asymptotic slope
2. Parallel composition envelope = pointwise max
3. Asymptotic slope of parallel composition = max of slopes
4. Concrete example of non-isomorphic DAGs with same tropical profile
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import List, Tuple


@dataclass
class AffineForm:
    """An affine function f(x) = slope * x + bias."""
    slope: float
    bias: float

    def eval(self, x: np.ndarray) -> np.ndarray:
        return self.slope * x + self.bias

    def __repr__(self):
        sign = '+' if self.bias >= 0 else '-'
        return f"{self.slope:.2f}·x {sign} {abs(self.bias):.2f}"


class TropicalProfile:
    """A tropical profile: a nonempty finite set of affine forms."""

    def __init__(self, forms: List[AffineForm]):
        assert len(forms) > 0, "Profile must be nonempty"
        self.forms = forms

    def eval_max(self, x: np.ndarray) -> np.ndarray:
        """Compute the tropical envelope (pointwise max of all forms)."""
        values = np.array([f.eval(x) for f in self.forms])
        return np.max(values, axis=0)

    @property
    def max_slope(self) -> float:
        """The maximum slope among all forms."""
        return max(f.slope for f in self.forms)

    @property
    def dominant_forms(self) -> List[AffineForm]:
        """Forms achieving the maximum slope."""
        ms = self.max_slope
        return [f for f in self.forms if f.slope == ms]

    @property
    def essential_dominant_bias(self) -> float:
        """Maximum bias among dominant forms."""
        return max(f.bias for f in self.dominant_forms)

    @property
    def dominant_multiplicity(self) -> int:
        return len(self.dominant_forms)

    def __repr__(self):
        forms_str = ", ".join(str(f) for f in self.forms)
        return f"TropicalProfile([{forms_str}])"


def parallel_compose(P: TropicalProfile, Q: TropicalProfile) -> TropicalProfile:
    """Parallel composition: union of forms (models residual/skip architecture)."""
    return TropicalProfile(P.forms + Q.forms)


# ─── DEMO 1: Tropical Equivalence ───────────────────────────────────────

print("=" * 70)
print("DEMO 1: Tropical Equivalence Preserves Asymptotic Slope")
print("=" * 70)

# Profile A: {2x + 1, x + 5, 3x - 2}
profile_A = TropicalProfile([
    AffineForm(2, 1),
    AffineForm(1, 5),
    AffineForm(3, -2),
])

# Profile B: {3x - 2, 2x + 1, x + 5, 2.5x - 1}
# The extra form 2.5x - 1 is always dominated
profile_B = TropicalProfile([
    AffineForm(3, -2),
    AffineForm(2, 1),
    AffineForm(1, 5),
    AffineForm(2.5, -1),
])

x = np.linspace(-5, 10, 1000)
env_A = profile_A.eval_max(x)
env_B = profile_B.eval_max(x)

print(f"\nProfile A: {profile_A}")
print(f"Profile B: {profile_B}")
print(f"\nMax slope A: {profile_A.max_slope}")
print(f"Max slope B: {profile_B.max_slope}")
print(f"Essential bias A: {profile_A.essential_dominant_bias}")
print(f"Essential bias B: {profile_B.essential_dominant_bias}")
print(f"\nEnvelopes equal? {np.allclose(env_A, env_B)}")
print(f"Max |difference|: {np.max(np.abs(env_A - env_B)):.2e}")

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

ax = axes[0]
for f in profile_A.forms:
    ax.plot(x, f.eval(x), '--', alpha=0.5, label=str(f))
ax.plot(x, env_A, 'k-', linewidth=2, label='Envelope A')
ax.set_title('Profile A: Individual Forms & Envelope')
ax.legend()
ax.set_xlabel('x')
ax.set_ylabel('f(x)')
ax.grid(True, alpha=0.3)

ax = axes[1]
ax.plot(x, env_A, 'b-', linewidth=2, label='Envelope A')
ax.plot(x, env_B, 'r--', linewidth=2, label='Envelope B')
ax.plot(x, profile_B.forms[3].eval(x), 'g:', alpha=0.7,
        label=f'Extra form: {profile_B.forms[3]}')
ax.set_title('Tropical Equivalence: A ≡ B')
ax.legend()
ax.set_xlabel('x')
ax.set_ylabel('f(x)')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('demo_tropical_equivalence.png', dpi=150)
print("\nPlot saved: demo_tropical_equivalence.png")


# ─── DEMO 2: Parallel Composition (Residual Architecture) ──────────────

print("\n" + "=" * 70)
print("DEMO 2: Parallel Composition — 'Fastest Branch Wins'")
print("=" * 70)

# Branch 1: slow-growing branch
branch1 = TropicalProfile([AffineForm(1, 3), AffineForm(0.5, 5)])
# Branch 2: fast-growing branch
branch2 = TropicalProfile([AffineForm(4, -1), AffineForm(2, 2)])

composed = parallel_compose(branch1, branch2)

print(f"\nBranch 1: {branch1}  (max slope = {branch1.max_slope})")
print(f"Branch 2: {branch2}  (max slope = {branch2.max_slope})")
print(f"Composed: {composed}  (max slope = {composed.max_slope})")
print(f"\nTheorem: max slope of composition = max(1, 4) = {max(branch1.max_slope, branch2.max_slope)}")
print(f"Verified: {composed.max_slope == max(branch1.max_slope, branch2.max_slope)}")

x = np.linspace(-2, 8, 1000)
fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(x, branch1.eval_max(x), 'b-', linewidth=1.5, label=f'Branch 1 (slope={branch1.max_slope})')
ax.plot(x, branch2.eval_max(x), 'r-', linewidth=1.5, label=f'Branch 2 (slope={branch2.max_slope})')
ax.plot(x, composed.eval_max(x), 'k-', linewidth=2.5, label=f'Composed (slope={composed.max_slope})')

# Verify evalMax_parallel_compose
env_max = np.maximum(branch1.eval_max(x), branch2.eval_max(x))
assert np.allclose(composed.eval_max(x), env_max), "Theorem violated!"
ax.plot(x, env_max, 'g--', linewidth=1, alpha=0.7, label='max(Branch1, Branch2)')

ax.set_title('Residual Architecture: Fastest Branch Dominates Asymptotically')
ax.legend()
ax.set_xlabel('x (log parameter count)')
ax.set_ylabel('Envelope value')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('demo_parallel_composition.png', dpi=150)
print("Plot saved: demo_parallel_composition.png")


# ─── DEMO 3: Eventual Slope Dominance ──────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 3: Eventual Slope Dominance")
print("=" * 70)

profile = TropicalProfile([
    AffineForm(1, 10),    # gentle slope, high start
    AffineForm(2, 0),     # medium slope
    AffineForm(3, -15),   # steep slope, very low start
])

x = np.linspace(-5, 20, 10000)
values = np.array([f.eval(x) for f in profile.forms])
argmax = np.argmax(values, axis=0)

# Find crossover points
transitions = np.where(np.diff(argmax) != 0)[0]
print(f"\nProfile: {profile}")
print(f"Max slope: {profile.max_slope}")
print(f"Dominant form has slope 3 and bias -15")
print(f"\nCrossover points (x values where dominant form changes):")
for t in transitions:
    print(f"  x ≈ {x[t]:.2f}: form {argmax[t]} → form {argmax[t+1]}")

# For large x, verify form with slope 3 dominates
x_large = 100.0
for f in profile.forms:
    print(f"  At x={x_large}: {f} = {f.eval(np.array([x_large]))[0]:.1f}"
          f"  {'← DOMINANT' if f.slope == profile.max_slope else ''}")


# ─── DEMO 4: Multiple Architectures, Same Universality Class ──────────

print("\n" + "=" * 70)
print("DEMO 4: Multiple Architectures in the Same Universality Class")
print("=" * 70)

# Three "architectures" with different internal structures but same
# max slope (= scaling exponent)

arch_1 = TropicalProfile([AffineForm(2, 5), AffineForm(1, 10)])
arch_2 = TropicalProfile([AffineForm(2, 3), AffineForm(2, 5), AffineForm(0, 20)])
arch_3 = TropicalProfile([AffineForm(2, 5), AffineForm(1.5, 7), AffineForm(0.5, 15)])

print(f"\nArchitecture 1: {arch_1}")
print(f"  Max slope: {arch_1.max_slope}, Essential bias: {arch_1.essential_dominant_bias}")
print(f"Architecture 2: {arch_2}")
print(f"  Max slope: {arch_2.max_slope}, Essential bias: {arch_2.essential_dominant_bias}")
print(f"Architecture 3: {arch_3}")
print(f"  Max slope: {arch_3.max_slope}, Essential bias: {arch_3.essential_dominant_bias}")

print(f"\nAll have max slope = 2 → same universality class!")
print(f"Architectures 1 & 3 also share essential bias = 5 → same eventual linear behavior")

# Simulate "scaling laws" L(N) = exp(-alpha * log(N) + beta)
N_values = np.logspace(2, 8, 100)
log_N = np.log(N_values)

fig, ax = plt.subplots(figsize=(10, 6))
for i, (arch, name) in enumerate([(arch_1, "Arch 1"), (arch_2, "Arch 2"), (arch_3, "Arch 3")]):
    loss = np.exp(-arch.eval_max(log_N))
    ax.loglog(N_values, loss, linewidth=2, label=f'{name} (slope={arch.max_slope})')

# Reference line
ref_loss = N_values ** (-2) * 100
ax.loglog(N_values, ref_loss, 'k--', alpha=0.5, label='Reference: N^{-2}')

ax.set_title('Scaling Laws: Same Universality Class (slope = 2)')
ax.set_xlabel('Parameter count N')
ax.set_ylabel('Loss L(N)')
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('demo_universality_classes.png', dpi=150)
print("\nPlot saved: demo_universality_classes.png")

print("\n" + "=" * 70)
print("All demonstrations completed successfully!")
print("=" * 70)
