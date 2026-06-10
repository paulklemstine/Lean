#!/usr/bin/env python3
"""
Applications of Specification-as-Fixed-Points Framework.

Real-world applications demonstrating how the mathematical framework
applies to practical domains:
1. Neural network output certification
2. Control system stability verification
3. Data pipeline idempotency checking
4. Abstract interpretation for program safety
"""

import numpy as np
from typing import Callable, Set, List, Dict, Tuple

# ============================================================
# Application 1: Neural Network Output Certification
# ============================================================

def app_neural_network_certification():
    """
    Application: Certifying that a neural network's outputs lie in a safe region.
    
    Given a simple classifier network N and a safe output set S,
    verify ∀ x ∈ K, N(x) ∈ S using image inclusion.
    """
    print("=" * 60)
    print("Application 1: Neural Network Output Certification")
    print("=" * 60)
    
    # Simple ReLU network: 1 hidden layer
    W1 = np.array([[1.0, -1.0], [-1.0, 1.0], [0.5, 0.5]])
    b1 = np.array([0.0, 0.0, -0.5])
    W2 = np.array([[1.0, -1.0, 0.5], [-0.5, 0.5, 1.0]])
    b2 = np.array([0.0, 0.0])
    
    def network(x):
        """Simple 2-layer ReLU network."""
        h = np.maximum(0, W1 @ x + b1)  # ReLU
        return W2 @ h + b2
    
    # Input set: grid of points in [-1, 1]²
    K = [np.array([i/5, j/5]) for i in range(-5, 6) for j in range(-5, 6)]
    
    # Safe set: outputs with norm ≤ 5
    def is_safe(y):
        return np.linalg.norm(y) <= 5.0
    
    # Specification check: ∀ x ∈ K, N(x) ∈ S
    outputs = [network(x) for x in K]
    all_safe = all(is_safe(y) for y in outputs)
    max_norm = max(np.linalg.norm(y) for y in outputs)
    
    print(f"  Network: 2-input, 3-hidden (ReLU), 2-output")
    print(f"  Input domain K: grid of {len(K)} points in [-1,1]²")
    print(f"  Safe set S: ||output|| ≤ 5.0")
    print(f"  Max output norm: {max_norm:.4f}")
    print(f"  Specification satisfied: {all_safe}")
    print(f"  (By forall_mem_iff_subset_preimage: K ⊆ N⁻¹(S) ✓)")
    print()

# ============================================================
# Application 2: Control System Stability
# ============================================================

def app_control_stability():
    """
    Application: Verifying that a discrete-time control system's states
    remain in a safe region.
    
    System: x_{n+1} = A·x_n (linear, discrete-time)
    Specification: ∀ x₀ ∈ K, x_1 ∈ S (one-step safety)
    
    Uses the closure operator interpretation: the reachable set
    from K under the dynamics is A·K, and safety requires A·K ⊆ S.
    """
    print("=" * 60)
    print("Application 2: Control System Stability Verification")
    print("=" * 60)
    
    # Stable system matrix (eigenvalues inside unit circle)
    A = np.array([[0.8, 0.1], [-0.1, 0.7]])
    
    def dynamics(x):
        return A @ x
    
    # Initial set: box [-1, 1]²
    K = [np.array([i/10, j/10]) for i in range(-10, 11) for j in range(-10, 11)]
    
    # Safe set: box [-2, 2]²
    def is_safe(x):
        return np.all(np.abs(x) <= 2.0)
    
    # Multi-step verification
    print(f"  System: x_{'{n+1}'} = A·x_n")
    print(f"  A eigenvalues: {np.linalg.eigvals(A).round(4)}")
    print(f"  Initial set K: {len(K)} points in [-1,1]²")
    print(f"  Safe set S: [-2,2]²")
    print()
    
    current_set = K
    for step in range(1, 6):
        next_set = [dynamics(x) for x in current_set]
        safe = all(is_safe(x) for x in next_set)
        max_coord = max(np.max(np.abs(x)) for x in next_set)
        print(f"  Step {step}: max |coord| = {max_coord:.4f}, safe = {safe}")
        current_set = next_set
    
    print()
    print(f"  Since A is stable (|λ| < 1), iterates contract.")
    print(f"  This is the dynamical analogue of idempotent collapse:")
    print(f"  A^n · K → {{0}} as n → ∞ (unique fixed point = origin)")
    print()

# ============================================================
# Application 3: Data Pipeline Idempotency
# ============================================================

def app_data_pipeline_idempotency():
    """
    Application: Verifying that a data transformation pipeline is idempotent.
    
    In ETL (Extract-Transform-Load), idempotent pipelines are critical
    for reliability: re-running the pipeline should not change the output.
    
    By spec_to_fixPts_of_idempotent: if the pipeline is idempotent,
    every output is automatically a fixed point (re-processing is safe).
    """
    print("=" * 60)
    print("Application 3: Data Pipeline Idempotency Verification")
    print("=" * 60)
    
    # Pipeline 1: Normalize and deduplicate (idempotent)
    def pipeline_clean(data: list) -> list:
        """Clean data: lowercase, strip whitespace, deduplicate, sort."""
        cleaned = sorted(set(s.lower().strip() for s in data))
        return cleaned
    
    # Pipeline 2: Add timestamp (NOT idempotent)
    counter = [0]
    def pipeline_stamp(data: list) -> list:
        """Add processing count (not idempotent!)."""
        counter[0] += 1
        return [f"v{counter[0]}:{s}" for s in data]
    
    test_data = ["  Hello ", "WORLD", "hello", "  World  ", "test"]
    
    # Test idempotency of pipeline 1
    result1 = pipeline_clean(test_data)
    result1_again = pipeline_clean(result1)
    is_idem1 = (result1 == result1_again)
    
    print(f"  Pipeline 1 (clean): {test_data}")
    print(f"    → First pass:  {result1}")
    print(f"    → Second pass: {result1_again}")
    print(f"    Idempotent: {is_idem1}")
    print(f"    By spec_to_fixPts_of_idempotent: output is a fixed point ✓")
    print()
    
    # Test idempotency of pipeline 2
    counter[0] = 0
    result2 = pipeline_stamp(test_data)
    result2_again = pipeline_stamp(result2)
    is_idem2 = (result2 == result2_again)
    
    print(f"  Pipeline 2 (stamp): {test_data}")
    print(f"    → First pass:  {result2}")
    print(f"    → Second pass: {result2_again}")
    print(f"    Idempotent: {is_idem2}")
    print(f"    ⚠ Re-processing changes the output!")
    print()

# ============================================================
# Application 4: Abstract Interpretation for Program Safety
# ============================================================

def app_abstract_interpretation():
    """
    Application: Using closure operators for program safety verification.
    
    Abstract interpretation verifies program properties by computing
    an over-approximation (closure hull) of reachable states and checking
    if it lies within the safe set.
    
    By subset_closed_iff_closure_subset:
      init ⊆ safe ↔ C(init) ⊆ safe  (when safe is C-closed)
    """
    print("=" * 60)
    print("Application 4: Abstract Interpretation for Program Safety")
    print("=" * 60)
    
    # Program: simple loop that increments a counter
    # State = (counter_value,)
    # Safe set: counter ∈ [0, 100]
    
    # Interval abstract domain
    def interval_closure(states: set) -> set:
        """Interval abstraction: closure = convex hull on integers."""
        if not states:
            return set()
        lo, hi = min(states), max(states)
        return set(range(lo, hi + 1))
    
    # Initial states
    init = {0, 1, 2}
    
    # After one loop iteration: counter += 1
    def step(states: set) -> set:
        return {s + 1 for s in states}
    
    # Safe set: [0, 100]
    safe = set(range(0, 101))
    
    # Verify: C(safe) = safe (safe is closed)
    C_safe = interval_closure(safe)
    safe_is_closed = (C_safe == safe)
    
    print(f"  Program: counter := counter + 1 (loop)")
    print(f"  Initial states: {sorted(init)}")
    print(f"  Safe set: [0, 100]")
    print(f"  Safe is C-closed: {safe_is_closed}")
    print()
    
    # Simulate k steps with closure hull tracking
    current = init
    print(f"  Step-by-step reachability analysis:")
    for k in range(1, 8):
        current = step(current)
        hull = interval_closure(current)
        safe_check = hull.issubset(safe)
        print(f"    After step {k}: states = [{min(current)}, {max(current)}], "
              f"hull ⊆ safe: {safe_check}")
    
    print()
    print(f"  By abstract_interpretation_safety:")
    print(f"  init ⊆ safe ↔ C(init) ⊆ safe")
    print(f"  This reduces infinite-state verification to hull checking!")
    print()

# ============================================================
# Application 5: OML Map in Signal Processing
# ============================================================

def app_oml_signal_processing():
    """
    Application: The oml map x ↦ 1 - ln(x) as a signal normalizer.
    
    In signal processing, we want outputs to converge to a stable value.
    By oml_spec_unique_fixed_point, the only stable positive output is 1.
    By oml_spec_collapse, if outputs reach a fixed point, they must be 1.
    """
    print("=" * 60)
    print("Application 5: OML as Signal Normalizer")
    print("=" * 60)
    
    oml = lambda x: 1.0 - np.log(x)
    
    # Iterate oml on various starting points
    starts = [0.1, 0.5, 1.0, 2.0, np.e**0.5]
    
    print(f"  oml(x) = 1 - ln(x)")
    print(f"  Iterating oml from various starting points:\n")
    
    for x0 in starts:
        trajectory = [x0]
        x = x0
        converged = False
        for i in range(20):
            try:
                x = oml(x)
                if x <= 0:
                    break
                trajectory.append(x)
                if len(trajectory) >= 3:
                    # Check 2-cycle convergence
                    if abs(trajectory[-1] - trajectory[-3]) < 1e-10:
                        converged = True
            except:
                break
        
        print(f"  x₀ = {x0:.4f}:")
        for j, v in enumerate(trajectory[:8]):
            marker = " ← fixed point!" if abs(v - 1.0) < 1e-10 else ""
            print(f"    x_{j} = {v:.6f}{marker}")
        if len(trajectory) > 8:
            print(f"    ... ({len(trajectory)} iterations total)")
        print()
    
    print(f"  Note: oml has derivative -1 at x=1 (boundary stability).")
    print(f"  Orbits oscillate but the unique fixed point is still 1.")
    print(f"  By oml_spec_unique_fixed_point: any fixed point must be 1.")
    print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  SPECIFICATION AS FIXED POINTS: Applications")
    print("=" * 60 + "\n")
    
    app_neural_network_certification()
    app_control_stability()
    app_data_pipeline_idempotency()
    app_abstract_interpretation()
    app_oml_signal_processing()
    
    print("=" * 60)
    print("  All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demonstration of Specification-as-Fixed-Points framework.

Concrete numerical examples illustrating the key theorems:
1. Preimage/image inclusion for specification checking
2. Closure operator reduction
3. Fixed-point collapse for idempotent operators
4. OML unique fixed point and specification collapse
"""

import numpy as np
from typing import Callable, Set, FrozenSet

# ============================================================
# Demo 1: Universal Specification as Preimage/Image Inclusion
# ============================================================

def demo_preimage_inclusion():
    """
    Theorem: (∀ x ∈ K, N(x) ∈ S) ↔ K ⊆ N⁻¹(S) ↔ N(K) ⊆ S
    
    We verify this computationally for a concrete function on finite sets.
    """
    print("=" * 60)
    print("Demo 1: Specification as Preimage/Image Inclusion")
    print("=" * 60)
    
    # Define N: x ↦ x² mod 10
    N = lambda x: (x * x) % 10
    
    # Input set K and safe set S
    K = {1, 2, 3, 4, 5}
    S = {0, 1, 4, 5, 6, 9}  # All quadratic residues mod 10
    
    # Check universal specification pointwise
    spec_holds = all(N(x) in S for x in K)
    
    # Check preimage inclusion: K ⊆ N⁻¹(S)
    preimage_S = {x for x in range(10) if N(x) in S}
    preimage_check = K.issubset(preimage_S)
    
    # Check image inclusion: N(K) ⊆ S
    image_K = {N(x) for x in K}
    image_check = image_K.issubset(S)
    
    print(f"  N(x) = x² mod 10")
    print(f"  K = {sorted(K)}")
    print(f"  S = {sorted(S)}")
    print(f"  N(K) = {sorted(image_K)}")
    print(f"  N⁻¹(S) = {sorted(preimage_S)}")
    print(f"  ∀ x ∈ K, N(x) ∈ S: {spec_holds}")
    print(f"  K ⊆ N⁻¹(S):        {preimage_check}")
    print(f"  N(K) ⊆ S:           {image_check}")
    print(f"  All three equivalent: {spec_holds == preimage_check == image_check}")
    print()

# ============================================================
# Demo 2: Closure Operator Specification Reduction
# ============================================================

def demo_closure_reduction():
    """
    Theorem: If C(S) = S (S is C-closed), then K ⊆ S ↔ C(K) ⊆ S.
    
    We use the convex hull as a closure operator on subsets of ℝ.
    """
    print("=" * 60)
    print("Demo 2: Closure Operator Specification Reduction")
    print("=" * 60)
    
    # Closure operator: convex hull on ℝ (= interval [min, max])
    def closure_1d(points):
        """Convex hull in 1D = closed interval from min to max."""
        if not points:
            return set()
        lo, hi = min(points), max(points)
        # For discrete demo, return all integers in [lo, hi]
        return set(range(lo, hi + 1))
    
    # Safe set S = [0, 10] (already convex/closed)
    S = set(range(0, 11))
    C_S = closure_1d(S)
    is_closed = (C_S == S)
    
    # Input set K₁ = {2, 5, 8} ⊆ S
    K1 = {2, 5, 8}
    C_K1 = closure_1d(K1)
    
    # Input set K₂ = {-1, 3, 7} ⊄ S
    K2 = {-1, 3, 7}
    C_K2 = closure_1d(K2)
    
    print(f"  Closure operator: convex hull on integers")
    print(f"  S = {{0, 1, ..., 10}} (convex, C(S) = S: {is_closed})")
    print()
    print(f"  K₁ = {sorted(K1)}")
    print(f"  C(K₁) = {sorted(C_K1)}")
    print(f"  K₁ ⊆ S: {K1.issubset(S)}")
    print(f"  C(K₁) ⊆ S: {C_K1.issubset(S)}")
    print(f"  Both agree: {K1.issubset(S) == C_K1.issubset(S)}")
    print()
    print(f"  K₂ = {sorted(K2)}")
    print(f"  C(K₂) = {sorted(C_K2)}")
    print(f"  K₂ ⊆ S: {K2.issubset(S)}")
    print(f"  C(K₂) ⊆ S: {C_K2.issubset(S)}")
    print(f"  Both agree: {K2.issubset(S) == C_K2.issubset(S)}")
    print()

# ============================================================
# Demo 3: Idempotent Operators and Fixed Points
# ============================================================

def demo_idempotent_fixed_points():
    """
    Theorem: If N is idempotent (N∘N = N), then N(x) ∈ Fix(N) for all x.
    
    We demonstrate with floor function (idempotent on integers within reals)
    and a projection operator.
    """
    print("=" * 60)
    print("Demo 3: Idempotent Operators and Fixed Points")
    print("=" * 60)
    
    # Example 1: Rounding to nearest integer (on a grid)
    N1 = lambda x: round(x)
    test_points = [0.3, 1.7, 2.5, 3.1, -0.4, -1.8]
    
    print("  Example: N(x) = round(x)")
    print(f"  {'x':>8} | {'N(x)':>8} | {'N(N(x))':>8} | {'N(x)=N(N(x))':>12} | {'N(x) fixed?':>12}")
    print("  " + "-" * 60)
    for x in test_points:
        nx = N1(x)
        nnx = N1(nx)
        is_idem = (nx == nnx)
        is_fixed = (N1(nx) == nx)
        print(f"  {x:8.2f} | {nx:8.2f} | {nnx:8.2f} | {str(is_idem):>12} | {str(is_fixed):>12}")
    
    print()
    print("  Key insight: Every output N(x) is a fixed point of N.")
    print("  This is exactly spec_to_fixPts_of_idempotent!")
    print()

# ============================================================
# Demo 4: OML Unique Fixed Point Collapse
# ============================================================

def demo_oml_collapse():
    """
    Theorem: oml(x) = 1 - ln(x) has unique positive fixed point x = 1.
    If outputs land in Fix(oml), they must all equal 1.
    """
    print("=" * 60)
    print("Demo 4: OML Unique Fixed Point and Specification Collapse")
    print("=" * 60)
    
    oml = lambda x: 1.0 - np.log(x)
    
    # Verify x=1 is a fixed point
    print(f"  oml(x) = 1 - ln(x)")
    print(f"  oml(1) = {oml(1.0):.6f} (should be 1.0)")
    print()
    
    # Show oml is not idempotent in general
    test_vals = [0.5, 1.0, 2.0, np.e, 0.1]
    print(f"  {'x':>8} | {'oml(x)':>12} | {'oml(oml(x))':>12} | {'oml(x) fixed?':>14}")
    print("  " + "-" * 55)
    for x in test_vals:
        ox = oml(x)
        if ox > 0:
            oox = oml(ox)
            is_fixed = abs(ox - oox) < 1e-10
        else:
            oox = float('nan')
            is_fixed = False
        print(f"  {x:8.4f} | {ox:12.6f} | {oox:12.6f} | {str(is_fixed):>14}")
    
    print()
    print("  Only x=1 gives oml(x) = x. By oml_spec_unique_fixed_point,")
    print("  any positive fixed point must equal 1.")
    print()
    
    # Demonstrate specification collapse
    print("  Specification Collapse Demo:")
    print("  If a system forces outputs into Fix(oml), all outputs = 1.")
    K = [0.5, 1.0, 2.0, 3.0, 0.1]
    print(f"  Input set K = {K}")
    outputs = [oml(x) for x in K]
    print(f"  oml(K) = {[f'{v:.4f}' for v in outputs]}")
    print(f"  If these were all fixed points, they'd all have to be 1.")
    print(f"  (Only oml(1.0) = {oml(1.0):.4f} is actually a fixed point.)")
    print()

# ============================================================
# Demo 5: Finite Set Verification
# ============================================================

def demo_finset_verification():
    """
    Theorem: ∀ x ∈ K, N(x) ∈ S ↔ K.image(N) ⊆ S  (Finset version)
    
    Computationally executable specification checking.
    """
    print("=" * 60)
    print("Demo 5: Finite Set Specification Checking")
    print("=" * 60)
    
    # Network: simple classifier
    def classifier(x):
        if x < 0:
            return "negative"
        elif x == 0:
            return "zero"
        else:
            return "positive"
    
    K = [-3, -1, 0, 2, 5]
    S_safe = {"negative", "zero", "positive"}
    S_positive = {"positive"}
    
    image_K = {classifier(x) for x in K}
    
    print(f"  Classifier: x → sign(x)")
    print(f"  K = {K}")
    print(f"  classifier(K) = {image_K}")
    print()
    print(f"  S₁ = {S_safe}")
    print(f"  classifier(K) ⊆ S₁: {image_K.issubset(S_safe)}")
    print(f"  Spec '∀ x ∈ K, output is valid': ✓")
    print()
    print(f"  S₂ = {S_positive}")
    print(f"  classifier(K) ⊆ S₂: {image_K.issubset(S_positive)}")
    print(f"  Spec '∀ x ∈ K, output is positive': ✗")
    print()

# ============================================================
# Demo 6: Unique Fixed Point Implies Constant Output
# ============================================================

def demo_unique_fp_constant():
    """
    Theorem: If N is idempotent with unique fixed point p, then N(x) = p for all x.
    """
    print("=" * 60)
    print("Demo 6: Idempotent + Unique Fixed Point = Constant Output")
    print("=" * 60)
    
    # Example: projection onto the mean
    # N(x) = mean of all coordinates (for vectors)
    # This is idempotent: N(N(x)) = N(x) since N(x) is constant
    
    # Simpler: N(x) = 0 for all x (constant function)
    N = lambda x: 0.0
    
    print("  N(x) = 0 (constant function)")
    print("  N is idempotent: N(N(x)) = N(0) = 0 = N(x) ✓")
    print("  Unique fixed point: N(p) = p ⟹ 0 = p ⟹ p = 0")
    print()
    
    test_vals = [-5, -1, 0, 1, 3.14, 100]
    for x in test_vals:
        print(f"  N({x}) = {N(x)} = p = 0 ✓")
    
    print()
    print("  By idempotent_unique_fixed_point_const:")
    print("  Any idempotent map with a unique fixed point is constant!")
    print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  SPECIFICATION AS FIXED POINTS: Numerical Demonstrations")
    print("=" * 60 + "\n")
    
    demo_preimage_inclusion()
    demo_closure_reduction()
    demo_idempotent_fixed_points()
    demo_oml_collapse()
    demo_finset_verification()
    demo_unique_fp_constant()
    
    print("=" * 60)
    print("  All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Specification-as-Fixed-Points Framework.

Generates matplotlib figures saved as PNG files.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import base64
from io import BytesIO

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_preimage_inclusion():
    """Visualize the preimage/image inclusion equivalence."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Setup
    N = lambda x: (x * x) % 10
    K = {1, 2, 3, 4, 5}
    S = {0, 1, 4, 5, 6, 9}
    universe = set(range(10))
    image_K = {N(x) for x in K}
    preimage_S = {x for x in universe if N(x) in S}
    
    # Panel 1: Pointwise specification
    ax = axes[0]
    ax.set_title("∀ x ∈ K, N(x) ∈ S", fontsize=14, fontweight='bold')
    for x in sorted(universe):
        color = 'steelblue' if x in K else 'lightgray'
        ax.barh(x, 1, color=color, edgecolor='black', linewidth=0.5)
        nx = N(x)
        in_S = nx in S
        marker = '✓' if (x in K and in_S) else ('✗' if x in K else '')
        ax.text(1.2, x, f"N({x})={nx} {marker}", va='center', fontsize=9)
    ax.set_xlim(-0.5, 3)
    ax.set_ylabel("Domain elements")
    ax.set_yticks(list(range(10)))
    ax.legend(['K (blue)', 'Others (gray)'], loc='upper right', fontsize=8)
    
    # Panel 2: Image inclusion
    ax = axes[1]
    ax.set_title("N(K) ⊆ S", fontsize=14, fontweight='bold')
    for y in sorted(universe):
        in_image = y in image_K
        in_S_set = y in S
        if in_image and in_S_set:
            color = 'green'
        elif in_image:
            color = 'red'
        elif in_S_set:
            color = 'lightyellow'
        else:
            color = 'lightgray'
        ax.barh(y, 1, color=color, edgecolor='black', linewidth=0.5)
        label = ""
        if y in image_K:
            label += "∈ N(K) "
        if y in S:
            label += "∈ S"
        ax.text(1.1, y, label, va='center', fontsize=9)
    ax.set_xlim(-0.5, 3)
    ax.set_ylabel("Codomain elements")
    ax.set_yticks(list(range(10)))
    
    # Panel 3: Preimage inclusion
    ax = axes[2]
    ax.set_title("K ⊆ N⁻¹(S)", fontsize=14, fontweight='bold')
    for x in sorted(universe):
        in_K = x in K
        in_preimage = x in preimage_S
        if in_K and in_preimage:
            color = 'green'
        elif in_K:
            color = 'red'
        elif in_preimage:
            color = 'lightyellow'
        else:
            color = 'lightgray'
        ax.barh(x, 1, color=color, edgecolor='black', linewidth=0.5)
        label = ""
        if x in K:
            label += "∈ K "
        if x in preimage_S:
            label += "∈ N⁻¹(S)"
        ax.text(1.1, x, label, va='center', fontsize=9)
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylabel("Domain elements")
    ax.set_yticks(list(range(10)))
    
    fig.suptitle("Three Equivalent Views of Specification Checking\nN(x) = x² mod 10", 
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_preimage_inclusion.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_oml_fixed_point():
    """Visualize the OML map and its unique fixed point."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    x = np.linspace(0.01, 5, 1000)
    oml = 1 - np.log(x)
    
    # Panel 1: OML function vs identity
    ax = axes[0]
    ax.plot(x, oml, 'b-', linewidth=2, label='oml(x) = 1 - ln(x)')
    ax.plot(x, x, 'k--', linewidth=1, label='y = x')
    ax.plot(1, 1, 'ro', markersize=12, zorder=5, label='Fixed point (1, 1)')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.fill_between(x, oml, x, where=(oml > x), alpha=0.1, color='blue')
    ax.fill_between(x, oml, x, where=(oml < x), alpha=0.1, color='red')
    ax.set_xlim(0, 5)
    ax.set_ylim(-2, 5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('OML Map: Unique Fixed Point at x = 1', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Cobweb diagram showing iteration
    ax = axes[1]
    ax.plot(x, oml, 'b-', linewidth=2, label='oml(x)')
    ax.plot(x, x, 'k--', linewidth=1, label='y = x')
    ax.plot(1, 1, 'ro', markersize=10, zorder=5)
    
    # Cobweb from x₀ = 0.3
    x0 = 0.3
    xn = x0
    cobweb_x = [xn]
    cobweb_y = [0]
    for _ in range(12):
        yn = 1 - np.log(xn)
        if yn <= 0 or yn > 10:
            break
        cobweb_x.extend([xn, yn])
        cobweb_y.extend([yn, yn])
        xn = yn
    
    ax.plot(cobweb_x, cobweb_y, 'r-', linewidth=1, alpha=0.7, label=f'Orbit from x₀={x0}')
    ax.plot(x0, 0, 'g^', markersize=10, label=f'Start: x₀={x0}')
    
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 4)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('oml(x)', fontsize=12)
    ax.set_title('Cobweb Diagram: Oscillation Around Fixed Point', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_oml_fixed_point.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_closure_reduction():
    """Visualize closure operator specification reduction."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    
    # Visualize on 2D: convex hull as closure operator
    # S = convex set (disk), K = finite point set
    theta = np.linspace(0, 2*np.pi, 100)
    
    # Safe set S: disk of radius 3
    S_x = 3 * np.cos(theta)
    S_y = 3 * np.sin(theta)
    ax.fill(S_x, S_y, alpha=0.15, color='green', label='Safe set S (C-closed)')
    ax.plot(S_x, S_y, 'g-', linewidth=2)
    
    # Input set K₁ (inside S)
    K1 = np.array([[0.5, 0.5], [-1, 1], [1, -0.5], [0, -1]])
    ax.scatter(K1[:, 0], K1[:, 1], c='blue', s=80, zorder=5, label='K₁ (safe)')
    
    # Convex hull of K₁
    from matplotlib.path import Path
    hull_idx = [0, 1, 3, 2, 0]  # manual convex hull ordering
    hull1 = K1[hull_idx]
    ax.fill(hull1[:, 0], hull1[:, 1], alpha=0.2, color='blue')
    ax.plot(hull1[:, 0], hull1[:, 1], 'b--', linewidth=1.5, label='C(K₁) (convex hull)')
    
    # Input set K₂ (outside S)
    K2 = np.array([[2, 2], [-2, -2], [3.5, 0], [0, 1]])
    ax.scatter(K2[:, 0], K2[:, 1], c='red', s=80, zorder=5, marker='x', 
               linewidths=2, label='K₂ (unsafe)')
    
    # Convex hull of K₂
    hull2_idx = [1, 3, 0, 2, 1]
    hull2 = K2[hull2_idx]
    ax.fill(hull2[:, 0], hull2[:, 1], alpha=0.15, color='red')
    ax.plot(hull2[:, 0], hull2[:, 1], 'r--', linewidth=1.5, label='C(K₂) (extends outside S)')
    
    ax.set_xlim(-4.5, 5)
    ax.set_ylim(-4, 4)
    ax.set_aspect('equal')
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Closure Reduction: K ⊆ S ↔ C(K) ⊆ S\n(Convex hull as closure operator)', 
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    
    # Annotations
    ax.annotate('C(K₁) ⊆ S ✓', xy=(0.3, -0.3), fontsize=12, color='blue',
                fontweight='bold', ha='center')
    ax.annotate('C(K₂) ⊄ S ✗', xy=(2.5, -1.5), fontsize=12, color='red',
                fontweight='bold', ha='center')
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_closure_reduction.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_specification_hierarchy():
    """Visualize the theorem dependency hierarchy."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Boxes for theorems
    boxes = {
        'preimage': (1, 6.5, 'forall_mem_iff\n_subset_preimage'),
        'image': (5, 6.5, 'mapsTo_iff\n_image_subset'),
        'equiv': (3, 5, 'preimage_eq\n_image_subset'),
        'closure': (8, 6.5, 'subset_closed_iff\n_closure_subset'),
        'fixpts': (1, 3.5, 'fixPts\n(definition)'),
        'idem': (4, 3.5, 'spec_to_fixPts\n_of_idempotent'),
        'preimage_univ': (7, 3.5, 'preimage_fixPts\n_eq_univ'),
        'unique': (4, 1.5, 'outputs_eq_unique\n_fixed_point'),
        'const': (8, 1.5, 'idempotent_unique\n_fixed_point_const'),
        'oml': (1, 0.5, 'oml_spec_collapse'),
        'safety': (11, 6.5, 'abstract_interpretation\n_safety'),
        'finset': (11, 3.5, 'forall_mem_finset\n_iff_image_subset'),
    }
    
    colors = {
        'preimage': '#4CAF50', 'image': '#4CAF50', 'equiv': '#4CAF50',
        'closure': '#2196F3', 'fixpts': '#FF9800', 'idem': '#FF9800',
        'preimage_univ': '#FF9800', 'unique': '#F44336', 'const': '#F44336',
        'oml': '#9C27B0', 'safety': '#2196F3', 'finset': '#4CAF50',
    }
    
    for key, (x, y, text) in boxes.items():
        w, h = 2.5, 1.0
        rect = FancyBboxPatch((x - w/2, y - h/2), w, h,
                               boxstyle="round,pad=0.1",
                               facecolor=colors[key], alpha=0.3,
                               edgecolor=colors[key], linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y, text, ha='center', va='center', fontsize=7,
                fontweight='bold', family='monospace')
    
    # Arrows (dependencies)
    arrows = [
        ('preimage', 'equiv'), ('image', 'equiv'),
        ('closure', 'safety'),
        ('fixpts', 'idem'), ('idem', 'unique'),
        ('fixpts', 'preimage_univ'),
        ('idem', 'const'), ('unique', 'oml'),
    ]
    
    for src, dst in arrows:
        sx, sy, _ = boxes[src]
        dx, dy, _ = boxes[dst]
        ax.annotate('', xy=(dx, dy + 0.5), xytext=(sx, sy - 0.5),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    # Legend
    legend_items = [
        ('#4CAF50', 'Set-theoretic normalization'),
        ('#2196F3', 'Closure operator theory'),
        ('#FF9800', 'Idempotent/fixed-point theory'),
        ('#F44336', 'Uniqueness collapse'),
        ('#9C27B0', 'Concrete EML corollary'),
    ]
    for i, (color, label) in enumerate(legend_items):
        ax.add_patch(FancyBboxPatch((10.5, 2.0 - i*0.4), 0.3, 0.25,
                                     boxstyle="round,pad=0.05",
                                     facecolor=color, alpha=0.3))
        ax.text(11.0, 2.12 - i*0.4, label, fontsize=8, va='center')
    
    ax.set_title('Theorem Dependency Hierarchy:\nSpecification as Fixed Points',
                 fontsize=16, fontweight='bold')
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_theorem_hierarchy.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = viz_preimage_inclusion()
    print(f"  Saved viz_preimage_inclusion.png ({len(b64_1)} chars base64)")
    
    b64_2 = viz_oml_fixed_point()
    print(f"  Saved viz_oml_fixed_point.png ({len(b64_2)} chars base64)")
    
    b64_3 = viz_closure_reduction()
    print(f"  Saved viz_closure_reduction.png ({len(b64_3)} chars base64)")
    
    b64_4 = viz_specification_hierarchy()
    print(f"  Saved viz_theorem_hierarchy.png ({len(b64_4)} chars base64)")
    
    print("\nAll visualizations generated successfully.")
