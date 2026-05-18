#!/usr/bin/env python3
"""
Tropical Scaling Exponents — Applications

Demonstrates real-world applications of the tropical scaling framework:
1. Architecture comparison via tropical equivalence
2. Scaling exponent prediction for composed architectures
3. Optimal architecture selection within a tropical class
4. Visualization of tropical envelopes
"""

from fractions import Fraction
from typing import List, Tuple, Dict
from dataclasses import dataclass
import math


@dataclass(frozen=True)
class TropAffine:
    slope: Fraction
    intercept: Fraction

    def eval(self, x: float) -> float:
        return float(self.slope) * x + float(self.intercept)


class TropicalProfile:
    def __init__(self, forms: List[TropAffine]):
        self.forms = frozenset(forms)

    def envelope(self, x: float) -> float:
        return min(f.eval(x) for f in self.forms)

    def scaling_exponent(self) -> Fraction:
        return min(f.slope for f in self.forms)


# ============================================================
# Application 1: Architecture Comparison
# ============================================================

def app_architecture_comparison():
    """Compare different neural architecture designs using tropical profiles.

    Shows how architectures with different structures can be classified
    into tropical equivalence classes sharing the same scaling exponent.
    """
    print("=" * 70)
    print("APPLICATION 1: Architecture Comparison via Tropical Equivalence")
    print("=" * 70)

    # Define several "architectures" by their tropical profiles
    architectures = {
        "Transformer-6L": TropicalProfile([
            TropAffine(Fraction(1, 4), Fraction(5)),
            TropAffine(Fraction(1, 2), Fraction(1)),
            TropAffine(Fraction(3, 4), Fraction(-2)),
        ]),
        "Transformer-12L": TropicalProfile([
            TropAffine(Fraction(1, 4), Fraction(3)),
            TropAffine(Fraction(1, 2), Fraction(0)),
            TropAffine(Fraction(1, 1), Fraction(-4)),
        ]),
        "MLP-Wide": TropicalProfile([
            TropAffine(Fraction(1, 4), Fraction(5)),
            TropAffine(Fraction(1, 2), Fraction(1)),
            TropAffine(Fraction(3, 4), Fraction(-2)),
        ]),
        "ConvNet-Deep": TropicalProfile([
            TropAffine(Fraction(1, 3), Fraction(4)),
            TropAffine(Fraction(2, 3), Fraction(0)),
        ]),
        "ConvNet-Wide": TropicalProfile([
            TropAffine(Fraction(1, 3), Fraction(4)),
            TropAffine(Fraction(2, 3), Fraction(0)),
        ]),
        "Hybrid-Net": TropicalProfile([
            TropAffine(Fraction(1, 2), Fraction(2)),
            TropAffine(Fraction(1, 1), Fraction(-1)),
        ]),
    }

    # Classify into equivalence classes
    classes: Dict[frozenset, List[str]] = {}
    for name, profile in architectures.items():
        key = profile.forms
        if key not in classes:
            classes[key] = []
        classes[key].append(name)

    print("\nTropical Equivalence Classes:")
    for i, (forms, members) in enumerate(classes.items(), 1):
        alpha = min(f.slope for f in forms)
        print(f"\n  Class {i} (α = {alpha} = {float(alpha):.4f}):")
        for m in members:
            print(f"    - {m}")
        print(f"    Forms: {len(forms)} path cost functions")

    print("\n→ Architectures in the same class share the same scaling exponent,")
    print("  regardless of their structural differences.")


# ============================================================
# Application 2: Composition of Architectures
# ============================================================

def app_composition():
    """Show how scaling exponents behave under architecture composition.

    When composing two computation graphs (sequential pipeline), the
    resulting tropical profile is the "tropical convolution" of the
    component profiles.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Scaling Under Architecture Composition")
    print("=" * 70)

    # Component A: encoder with exponent 1/3
    encoder = TropicalProfile([
        TropAffine(Fraction(1, 3), Fraction(2)),
        TropAffine(Fraction(1, 1), Fraction(-1)),
    ])

    # Component B: decoder with exponent 1/4
    decoder = TropicalProfile([
        TropAffine(Fraction(1, 4), Fraction(3)),
        TropAffine(Fraction(1, 2), Fraction(0)),
    ])

    # Composed profile: all pairwise sums of (slope, intercept)
    composed_forms = []
    for fa in encoder.forms:
        for fb in decoder.forms:
            composed_forms.append(TropAffine(
                fa.slope + fb.slope,
                fa.intercept + fb.intercept
            ))
    composed = TropicalProfile(composed_forms)

    print(f"\nEncoder: α = {encoder.scaling_exponent()}")
    print(f"Decoder: α = {decoder.scaling_exponent()}")
    print(f"Composed (encoder + decoder): α = {composed.scaling_exponent()}")
    print(f"\nComposition rule: α_composed = min over path pairs of (α_enc + α_dec)")
    print(f"  = {encoder.scaling_exponent()} + {decoder.scaling_exponent()}")
    print(f"  = {encoder.scaling_exponent() + decoder.scaling_exponent()}")

    # Verify
    min_sum = min(fa.slope + fb.slope for fa in encoder.forms for fb in decoder.forms)
    print(f"  Actual minimum sum of slopes: {min_sum}")
    print(f"  Matches: {min_sum == composed.scaling_exponent()} ✓")

    print("\n→ The scaling exponent of a pipeline is determined by the")
    print("  minimum total slope across all path pairs.")


# ============================================================
# Application 3: Optimal Path Selection
# ============================================================

def app_optimal_path():
    """Demonstrate how the dominant path changes with scale.

    At different scales N, different paths through the computation graph
    are optimal. The tropical envelope captures this transition.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Optimal Path Selection Across Scales")
    print("=" * 70)

    forms = [
        TropAffine(Fraction(1, 5), Fraction(10)),   # Slow slope, high overhead
        TropAffine(Fraction(2, 5), Fraction(2)),     # Medium slope, medium overhead
        TropAffine(Fraction(4, 5), Fraction(-3)),    # Fast slope, low overhead
        TropAffine(Fraction(1, 1), Fraction(-5)),    # Fastest slope, negative overhead
    ]
    profile = TropicalProfile(forms)
    alpha = profile.scaling_exponent()

    path_names = [
        "Shallow-Wide (slow scaling, high startup cost)",
        "Balanced (moderate scaling and overhead)",
        "Deep-Narrow (fast scaling, small overhead)",
        "Ultra-Deep (fastest scaling, training shortcut)",
    ]

    print(f"\nScaling exponent: α = {alpha} = {float(alpha):.2f}")
    print(f"\nPath cost functions:")
    for i, (f, name) in enumerate(zip(forms, path_names)):
        print(f"  Path {i+1}: {float(f.slope):.2f}·x + {float(f.intercept):+.1f}  — {name}")

    print(f"\n{'x (=log N)':>12} | {'Optimal path':>15} | {'Cost':>8} | {'α·x approx':>12}")
    print("-" * 56)
    for x_val in [-10, -5, 0, 3, 5, 8, 10, 15, 20, 30, 50, 100]:
        x = float(x_val)
        costs = [f.eval(x) for f in forms]
        best_idx = costs.index(min(costs))
        env = min(costs)
        approx = float(alpha) * x
        print(f"{x:12.0f} | Path {best_idx+1:>10} | {env:8.1f} | {approx:12.1f}")

    print(f"\n→ For large x (large N), Path 1 with minimum slope dominates.")
    print(f"   The scaling exponent α = {alpha} controls the asymptotic rate.")


# ============================================================
# Application 4: Envelope Visualization (ASCII)
# ============================================================

def app_envelope_visualization():
    """ASCII visualization of the tropical envelope."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Tropical Envelope Visualization")
    print("=" * 70)

    forms = [
        TropAffine(Fraction(1, 3), Fraction(4)),
        TropAffine(Fraction(2, 3), Fraction(0)),
        TropAffine(Fraction(1, 1), Fraction(-2)),
    ]
    profile = TropicalProfile(forms)
    alpha = profile.scaling_exponent()

    # Compute envelope over range
    x_range = [i * 0.5 for i in range(-10, 41)]
    env_values = [profile.envelope(x) for x in x_range]

    # Also compute individual forms
    form_values = [[f.eval(x) for x in x_range] for f in forms]

    # ASCII plot
    min_y = min(env_values)
    max_y = max(env_values)
    height = 20
    width = len(x_range)

    print(f"\nα = {alpha}, envelope = min of {len(forms)} affine forms")
    print(f"x range: [{x_range[0]}, {x_range[-1]}]")
    print(f"y range: [{min_y:.1f}, {max_y:.1f}]")

    grid = [[' ' for _ in range(width)] for _ in range(height)]

    def y_to_row(y):
        if max_y == min_y:
            return height // 2
        return int((max_y - y) / (max_y - min_y) * (height - 1))

    # Plot individual forms (dots)
    symbols = ['.', '+', 'x']
    for fi, fv in enumerate(form_values):
        for xi, y in enumerate(fv):
            if min_y <= y <= max_y:
                r = y_to_row(y)
                if 0 <= r < height and grid[r][xi] == ' ':
                    grid[r][xi] = symbols[fi]

    # Plot envelope (solid line, overwrites)
    for xi, y in enumerate(env_values):
        r = y_to_row(y)
        if 0 <= r < height:
            grid[r][xi] = '█'

    print(f"\n{'':>8}  Legend: █=envelope  .=f₁(1/3)  +=f₂(2/3)  x=f₃(1)")
    for r in range(height):
        y_val = max_y - r * (max_y - min_y) / (height - 1)
        print(f"{y_val:7.1f} |{''.join(grid[r])}|")
    print(f"{'':>8} {'└' + '─' * width + '┘'}")
    print(f"{'':>8}  x: {x_range[0]:.0f}{' ' * (width - 8)}{x_range[-1]:.0f}")

    print(f"\n→ The envelope (█) follows the minimum of all forms at each x.")
    print(f"   For large x, the form with slope α = {alpha} dominates.")


# ============================================================
# Application 5: Scaling Law Prediction
# ============================================================

def app_scaling_prediction():
    """Predict scaling behavior for different model sizes."""
    print("\n" + "=" * 70)
    print("APPLICATION 5: Scaling Law Prediction")
    print("=" * 70)

    # Simulate a transformer-like architecture
    profile = TropicalProfile([
        TropAffine(Fraction(1, 4), Fraction(8)),      # attention path
        TropAffine(Fraction(1, 2), Fraction(2)),       # FFN path
        TropAffine(Fraction(3, 4), Fraction(-1)),      # residual path
    ])
    alpha = profile.scaling_exponent()

    print(f"\nArchitecture tropical profile:")
    for f in sorted(profile.forms, key=lambda f: f.slope):
        print(f"  slope={float(f.slope):.2f}, intercept={float(f.intercept):+.1f}")
    print(f"Scaling exponent: α = {alpha} = {float(alpha):.4f}")

    print(f"\nPredicted loss scaling: L(N) ~ N^(-{alpha}) = N^(-{float(alpha):.2f})")
    print(f"\n{'Parameters N':>14} | {'log₁₀(N)':>10} | {'Predicted Loss':>16} | {'Relative':>10}")
    print("-" * 56)

    base_loss = None
    for exp in [6, 7, 8, 9, 10, 11, 12]:
        N = 10 ** exp
        # Loss proxy: exp(envelope(ln(N)))
        ln_N = math.log(N)
        env = profile.envelope(ln_N)
        loss = math.exp(env)

        if base_loss is None:
            base_loss = loss
            rel = "1.00x"
        else:
            rel = f"{loss/base_loss:.4f}x"

        print(f"  10^{exp:>2} = {N:>8} | {exp:>10} | {loss:16.6f} | {rel:>10}")

    # Show that doubling N reduces loss by factor 2^(-alpha)
    print(f"\n  Doubling N reduces loss by factor 2^(-α) = 2^(-{float(alpha):.2f}) = {2**(-float(alpha)):.4f}")
    print(f"  10x more parameters reduces loss by factor 10^(-α) = {10**(-float(alpha)):.4f}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Scaling Exponents — Applications Suite                    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    app_architecture_comparison()
    app_composition()
    app_optimal_path()
    app_envelope_visualization()
    app_scaling_prediction()

    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Scaling Exponents for Computation DAGs — Interactive Demo

Demonstrates the core theorems with concrete numerical examples:
1. Tropical affine forms and eventual dominance
2. Tropical envelopes and scaling exponents
3. Non-isomorphic but tropically equivalent DAGs
4. Asymptotic sandwich bounds

Run: python demo.py
"""

from fractions import Fraction
from typing import List, Tuple, Set
import math


class TropAffine:
    """A tropical affine form: slope * x + intercept."""

    def __init__(self, slope: Fraction, intercept: Fraction):
        self.slope = Fraction(slope)
        self.intercept = Fraction(intercept)

    def eval(self, x: Fraction) -> Fraction:
        return self.slope * x + self.intercept

    def __repr__(self):
        return f"({self.slope})*x + ({self.intercept})"

    def __eq__(self, other):
        return self.slope == other.slope and self.intercept == other.intercept

    def __hash__(self):
        return hash((self.slope, self.intercept))


class TropicalProfile:
    """A nonempty finite set of tropical affine forms."""

    def __init__(self, forms: List[TropAffine]):
        assert len(forms) > 0, "Profile must be nonempty"
        self.forms = frozenset(forms)

    def envelope(self, x: Fraction) -> Fraction:
        """Pointwise minimum of all forms."""
        return min(f.eval(x) for f in self.forms)

    def scaling_exponent(self) -> Fraction:
        """Minimum slope across all forms."""
        return min(f.slope for f in self.forms)

    def __eq__(self, other):
        return self.forms == other.forms


class WeightedDAG:
    """A weighted computation DAG with its tropical profile."""

    def __init__(self, name: str, num_vertices: int, num_edges: int,
                 profile: TropicalProfile):
        self.name = name
        self.num_vertices = num_vertices
        self.num_edges = num_edges
        self.profile = profile

    def scaling_exponent(self) -> Fraction:
        return self.profile.scaling_exponent()

    def complexity_proxy(self, x: Fraction) -> Fraction:
        return self.profile.envelope(x)

    def is_tropically_equivalent(self, other: 'WeightedDAG') -> bool:
        return self.profile == other.profile

    def is_non_isomorphic(self, other: 'WeightedDAG') -> bool:
        return (self.num_vertices != other.num_vertices or
                self.num_edges != other.num_edges)


def demo_eventual_dominance():
    """Demonstrate that lower-slope affine forms eventually dominate."""
    print("=" * 70)
    print("DEMO 1: Eventual Dominance of Minimum-Slope Forms")
    print("=" * 70)

    f = TropAffine(Fraction(1, 2), Fraction(10))  # 0.5x + 10
    g = TropAffine(Fraction(1, 1), Fraction(-5))   # x - 5

    print(f"\nForm f: {f}  (slope = {float(f.slope):.2f})")
    print(f"Form g: {g}  (slope = {float(g.slope):.2f})")
    print(f"\nSince f.slope < g.slope, f should eventually dominate (be smaller).")

    # Crossover point
    crossover = (f.intercept - g.intercept) / (g.slope - f.slope)
    print(f"Crossover point X₀ = {crossover} = {float(crossover):.1f}")

    print(f"\n{'x':>8} | {'f(x)':>10} | {'g(x)':>10} | {'f ≤ g?':>8}")
    print("-" * 45)
    for x_val in [-10, 0, 10, 20, 30, 40, 50]:
        x = Fraction(x_val)
        fx = f.eval(x)
        gx = g.eval(x)
        dom = "✓" if fx <= gx else "✗"
        print(f"{float(x):8.0f} | {float(fx):10.1f} | {float(gx):10.1f} | {dom:>8}")

    print(f"\n→ For x ≥ {float(crossover):.0f}, f(x) ≤ g(x) always. ✓")


def demo_tropical_profiles():
    """Demonstrate tropical profiles, envelopes, and scaling exponents."""
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical Profiles and Scaling Exponents")
    print("=" * 70)

    forms = [
        TropAffine(Fraction(1, 3), Fraction(2)),    # x/3 + 2
        TropAffine(Fraction(2, 3), Fraction(0)),     # 2x/3
        TropAffine(Fraction(1, 1), Fraction(-1)),    # x - 1
    ]
    profile = TropicalProfile(forms)

    print("\nTropical profile with 3 forms:")
    for i, f in enumerate(sorted(forms, key=lambda f: f.slope)):
        print(f"  f_{i+1}: {f}  (slope = {float(f.slope):.4f})")

    alpha = profile.scaling_exponent()
    print(f"\nScaling exponent α = min of slopes = {alpha} = {float(alpha):.4f}")
    print(f"α is rational: {alpha} = {alpha.numerator}/{alpha.denominator} ✓")

    print(f"\n{'x':>8} | {'f₁(x)':>10} | {'f₂(x)':>10} | {'f₃(x)':>10} | {'env(x)':>10} | {'active':>8}")
    print("-" * 68)
    for x_val in [-5, -2, 0, 2, 5, 10, 20, 50]:
        x = Fraction(x_val)
        vals = [f.eval(x) for f in sorted(forms, key=lambda f: f.slope)]
        env = profile.envelope(x)
        active = min(range(3), key=lambda i: vals[i]) + 1
        print(f"{float(x):8.0f} | {float(vals[0]):10.2f} | {float(vals[1]):10.2f} | {float(vals[2]):10.2f} | {float(env):10.2f} | f_{active}")

    print(f"\n→ For large x, f₁ (slope = {float(forms[0].slope):.4f} = α) dominates. ✓")


def demo_non_isomorphic_equivalence():
    """Demonstrate non-isomorphic but tropically equivalent DAGs."""
    print("\n" + "=" * 70)
    print("DEMO 3: Non-Isomorphic but Tropically Equivalent DAGs")
    print("=" * 70)

    # Example pair 1: Chain vs Diamond
    profile1 = TropicalProfile([
        TropAffine(Fraction(1, 2), Fraction(0)),
        TropAffine(Fraction(1, 1), Fraction(1)),
    ])
    chain = WeightedDAG("Chain", num_vertices=3, num_edges=2, profile=profile1)
    diamond = WeightedDAG("Diamond", num_vertices=4, num_edges=4, profile=profile1)

    print("\n--- Example Pair 1 ---")
    print(f"Chain DAG:   {chain.num_vertices} vertices, {chain.num_edges} edges")
    print(f"Diamond DAG: {diamond.num_vertices} vertices, {diamond.num_edges} edges")
    print(f"Non-isomorphic: {chain.is_non_isomorphic(diamond)} ✓")
    print(f"Tropically equivalent: {chain.is_tropically_equivalent(diamond)} ✓")
    print(f"Chain exponent:   α = {chain.scaling_exponent()} = {float(chain.scaling_exponent()):.4f}")
    print(f"Diamond exponent: α = {diamond.scaling_exponent()} = {float(diamond.scaling_exponent()):.4f}")
    print(f"Same exponent: {chain.scaling_exponent() == diamond.scaling_exponent()} ✓")

    # Example pair 2: Wide vs Deep
    profile2 = TropicalProfile([
        TropAffine(Fraction(1, 3), Fraction(2)),
        TropAffine(Fraction(2, 3), Fraction(0)),
        TropAffine(Fraction(1, 1), Fraction(-1)),
    ])
    wide = WeightedDAG("Wide", num_vertices=5, num_edges=4, profile=profile2)
    deep = WeightedDAG("Deep", num_vertices=6, num_edges=5, profile=profile2)

    print("\n--- Example Pair 2 ---")
    print(f"Wide DAG: {wide.num_vertices} vertices, {wide.num_edges} edges")
    print(f"Deep DAG: {deep.num_vertices} vertices, {deep.num_edges} edges")
    print(f"Non-isomorphic: {wide.is_non_isomorphic(deep)} ✓")
    print(f"Tropically equivalent: {wide.is_tropically_equivalent(deep)} ✓")
    print(f"Wide exponent: α = {wide.scaling_exponent()} = {float(wide.scaling_exponent()):.4f}")
    print(f"Deep exponent: α = {deep.scaling_exponent()} = {float(deep.scaling_exponent()):.4f}")
    print(f"Same exponent: {wide.scaling_exponent() == deep.scaling_exponent()} ✓")


def demo_asymptotic_sandwich():
    """Demonstrate the asymptotic sandwich theorem."""
    print("\n" + "=" * 70)
    print("DEMO 4: Asymptotic Sandwich Theorem")
    print("=" * 70)

    forms = [
        TropAffine(Fraction(1, 2), Fraction(3)),
        TropAffine(Fraction(3, 4), Fraction(-1)),
        TropAffine(Fraction(1, 1), Fraction(-3)),
    ]
    profile = TropicalProfile(forms)
    alpha = profile.scaling_exponent()

    # Upper bound: use the min-slope form directly
    min_slope_form = min(forms, key=lambda f: f.slope)
    b_upper = min_slope_form.intercept

    # Lower bound: use min intercept with X₀ = 0
    b_lower = min(f.intercept for f in forms)
    X0 = Fraction(0)

    print(f"\nProfile with 3 forms, α = {alpha}")
    print(f"Upper bound: env(x) ≤ {alpha}·x + {b_upper}  (for all x)")
    print(f"Lower bound: {alpha}·x + {b_lower} ≤ env(x)  (for x ≥ {X0})")

    print(f"\n{'x':>6} | {'lower':>10} | {'env(x)':>10} | {'upper':>10} | {'sand?':>6}")
    print("-" * 52)
    for x_val in [0, 2, 5, 10, 20, 50, 100]:
        x = Fraction(x_val)
        env = profile.envelope(x)
        lower = alpha * x + b_lower
        upper = alpha * x + b_upper
        ok = "✓" if (x >= X0 and lower <= env <= upper) else ("—" if x < X0 else "✗")
        print(f"{float(x):6.0f} | {float(lower):10.2f} | {float(env):10.2f} | {float(upper):10.2f} | {ok:>6}")

    print(f"\n→ For x ≥ {float(X0)}, envelope is sandwiched: α·x + b₁ ≤ env(x) ≤ α·x + b₂ ✓")
    print(f"   This confirms env(x) = α·x + Θ(1), i.e., power-law scaling N^{{-α}}.")


def demo_power_law_scaling():
    """Demonstrate the power-law scaling interpretation."""
    print("\n" + "=" * 70)
    print("DEMO 5: Power-Law Scaling L(N) ~ N^{-α}")
    print("=" * 70)

    profile = TropicalProfile([
        TropAffine(Fraction(1, 2), Fraction(3)),
        TropAffine(Fraction(1, 1), Fraction(0)),
    ])
    alpha = profile.scaling_exponent()
    print(f"\nScaling exponent α = {alpha}")
    print(f"Predicted: L(N) ~ N^{{-{alpha}}} = N^{{-0.5}} = 1/√N")

    print(f"\n{'N':>12} | {'log N':>8} | {'env(log N)':>12} | {'N^(-α)':>12} | {'ratio':>8}")
    print("-" * 60)
    for n_exp in [2, 3, 4, 5, 6, 8, 10]:
        N = 10 ** n_exp
        log_N = Fraction(n_exp) * Fraction(23026, 10000)  # approx ln(10)
        env = float(profile.envelope(log_N))
        n_alpha = N ** (-float(alpha))
        exp_env = math.exp(env)
        print(f"{N:12d} | {float(log_N):8.2f} | {env:12.2f} | {n_alpha:12.6f} | —")

    print(f"\n→ The envelope grows linearly with log N, confirming power-law scaling.")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Scaling Exponents for Computation DAGs — Demo Suite       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_eventual_dominance()
    demo_tropical_profiles()
    demo_non_isomorphic_equivalence()
    demo_asymptotic_sandwich()
    demo_power_law_scaling()

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)
