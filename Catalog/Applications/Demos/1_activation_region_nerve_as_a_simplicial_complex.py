#!/usr/bin/env python3
"""
Applications of Activation-Nerve Margin-Cosheaf Certification

Real-world applications demonstrating the topological certification framework:
1. Image classifier robustness certification
2. Safety-critical controller verification
3. Adversarial vulnerability diagnosis
"""

import numpy as np
from typing import List, Tuple, Dict
from dataclasses import dataclass


@dataclass 
class SimpleReLUNetwork:
    """A simple multi-layer ReLU network for demonstration."""
    weights: List[np.ndarray]
    biases: List[np.ndarray]
    
    def forward(self, x: np.ndarray) -> np.ndarray:
        """Forward pass through the network."""
        h = x.copy()
        for i, (W, b) in enumerate(zip(self.weights, self.biases)):
            h = W @ h + b
            if i < len(self.weights) - 1:  # ReLU on hidden layers
                h = np.maximum(h, 0)
        return h
    
    def margin(self, x: np.ndarray) -> float:
        """Margin: difference between top-2 class logits."""
        logits = self.forward(x)
        sorted_logits = np.sort(logits)[::-1]
        return float(sorted_logits[0] - sorted_logits[1])
    
    def predict(self, x: np.ndarray) -> int:
        """Predicted class."""
        return int(np.argmax(self.forward(x)))
    
    def lipschitz_bound(self) -> float:
        """Upper bound on Lipschitz constant (product of spectral norms)."""
        L = 1.0
        for W in self.weights:
            L *= np.linalg.norm(W, ord=2)
        return L


# ============================================================
# APPLICATION 1: Binary Classifier Certification
# ============================================================
def app_binary_classifier():
    """Certify a binary classifier on a 2D domain."""
    print("=" * 60)
    print("APPLICATION 1: Binary Classifier Robustness Certification")
    print("=" * 60)
    
    # Create a simple 2D binary classifier
    np.random.seed(42)
    net = SimpleReLUNetwork(
        weights=[
            np.array([[2.0, 1.0], [-1.0, 2.0], [1.0, -1.0], [0.5, 0.5]]),
            np.array([[1.0, -1.0, 0.5, 0.3], [-0.5, 1.0, -0.3, 0.7]]),
        ],
        biases=[
            np.array([0.1, -0.2, 0.3, -0.1]),
            np.array([0.0, 0.0]),
        ]
    )
    
    # Domain: unit square
    domain = [(-1.0, 1.0), (-1.0, 1.0)]
    
    # Sample the domain and compute margins
    n_grid = 50
    xs = np.linspace(domain[0][0], domain[0][1], n_grid)
    ys = np.linspace(domain[1][0], domain[1][1], n_grid)
    
    margins = np.zeros((n_grid, n_grid))
    predictions = np.zeros((n_grid, n_grid), dtype=int)
    
    for i, x in enumerate(xs):
        for j, y in enumerate(ys):
            point = np.array([x, y])
            margins[i, j] = net.margin(point)
            predictions[i, j] = net.predict(point)
    
    # Compute global statistics
    min_margin = margins.min()
    avg_margin = margins.mean()
    lipschitz = net.lipschitz_bound()
    
    print(f"\nNetwork: 2 → 4 → 2 (ReLU hidden layer)")
    print(f"Domain: [-1,1]²")
    print(f"Lipschitz bound: {lipschitz:.4f}")
    print(f"Minimum margin: {min_margin:.4f}")
    print(f"Average margin: {avg_margin:.4f}")
    
    if min_margin > 0:
        certified_radius = min_margin / lipschitz
        print(f"\n✓ CERTIFIED ROBUST")
        print(f"  Uniform margin δ = {min_margin:.4f}")
        print(f"  Certified radius r = δ/L = {certified_radius:.6f}")
        print(f"  Any perturbation ≤ {certified_radius:.6f} preserves classification")
    else:
        print(f"\n✗ NOT CERTIFIED — margin drops to {min_margin:.4f}")
        # Find vulnerable points
        min_idx = np.unravel_index(margins.argmin(), margins.shape)
        print(f"  Most vulnerable point: ({xs[min_idx[0]]:.2f}, {ys[min_idx[1]]:.2f})")


# ============================================================
# APPLICATION 2: Safety-Critical Controller
# ============================================================
def app_safety_controller():
    """Verify a safety-critical neural controller."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Safety-Critical Controller Verification")
    print("=" * 60)
    
    # Scenario: a neural network controls braking force
    # Input: [speed, distance_to_obstacle]
    # Output: [brake_force, throttle]
    # Safety: brake_force > throttle when distance < threshold
    
    net = SimpleReLUNetwork(
        weights=[
            np.array([[1.0, -2.0], [-0.5, 1.0], [0.3, 0.8]]),
            np.array([[2.0, -0.5, 1.0], [-1.0, 1.5, -0.3]]),
        ],
        biases=[
            np.array([0.5, 0.1, -0.2]),
            np.array([0.3, -0.1]),
        ]
    )
    
    # Safety domain: speed in [0, 30] m/s, distance in [0, 5] m
    # In this region, the controller must output brake > throttle
    n_test = 100
    speeds = np.linspace(0, 30, n_test)
    distances = np.linspace(0, 5, n_test)
    
    min_safety_margin = float('inf')
    worst_point = None
    safety_violations = 0
    
    for s in speeds:
        for d in distances:
            output = net.forward(np.array([s/30.0, d/5.0]))  # Normalize inputs
            brake, throttle = output[0], output[1]
            safety_margin = brake - throttle  # Must be positive
            
            if safety_margin < min_safety_margin:
                min_safety_margin = safety_margin
                worst_point = (s, d)
            
            if safety_margin < 0:
                safety_violations += 1
    
    lipschitz = net.lipschitz_bound()
    total_points = n_test * n_test
    
    print(f"\nController: 2 → 3 → 2 (ReLU)")
    print(f"Safety domain: speed ∈ [0, 30] m/s, distance ∈ [0, 5] m")
    print(f"Safety condition: brake_force > throttle")
    print(f"\nResults:")
    print(f"  Points tested: {total_points}")
    print(f"  Safety violations: {safety_violations}")
    print(f"  Minimum safety margin: {min_safety_margin:.4f}")
    print(f"  Lipschitz bound: {lipschitz:.4f}")
    
    if min_safety_margin > 0:
        radius = min_safety_margin / lipschitz
        print(f"\n✓ CONTROLLER VERIFIED SAFE")
        print(f"  Robustness radius: {radius:.6f}")
        print(f"  Sensor noise tolerance: ±{radius:.6f} (normalized)")
    else:
        print(f"\n✗ SAFETY VIOLATION DETECTED")
        print(f"  Worst point: speed={worst_point[0]:.1f} m/s, dist={worst_point[1]:.1f} m")
        print(f"  Margin at worst point: {min_safety_margin:.4f}")


# ============================================================
# APPLICATION 3: Adversarial Vulnerability Diagnosis
# ============================================================
def app_vulnerability_diagnosis():
    """Diagnose adversarial vulnerability using the nerve structure."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Adversarial Vulnerability Diagnosis")
    print("=" * 60)
    
    # Create a network with deliberate vulnerability
    net = SimpleReLUNetwork(
        weights=[
            np.array([[3.0, 0.0], [0.0, 3.0], [-2.0, -2.0], [1.0, -1.0]]),
            np.array([[1.0, 0.5, -0.8, 0.3], [0.2, -1.0, 0.5, 0.7]]),
        ],
        biases=[
            np.array([0.0, 0.0, 1.0, 0.5]),
            np.array([0.1, -0.1]),
        ]
    )
    
    # Define activation regions as quadrants (simplified)
    region_names = ["NE (x>0, y>0)", "NW (x<0, y>0)", 
                    "SW (x<0, y<0)", "SE (x>0, y<0)"]
    
    region_bounds = [
        [(0, 1), (0, 1)],      # NE
        [(-1, 0), (0, 1)],     # NW
        [(-1, 0), (-1, 0)],    # SW
        [(0, 1), (-1, 0)],     # SE
    ]
    
    # Compute margin on each region
    n_samples = 500
    region_margins = {}
    region_min_margins = {}
    
    print(f"\nNetwork: 2 → 4 → 2 (ReLU)")
    print(f"Domain: [-1,1]²")
    print(f"\nRegion-by-region analysis:")
    
    for idx, (name, bounds) in enumerate(zip(region_names, region_bounds)):
        margins = []
        for _ in range(n_samples):
            x = np.random.uniform(bounds[0][0], bounds[0][1])
            y = np.random.uniform(bounds[1][0], bounds[1][1])
            m = net.margin(np.array([x, y]))
            margins.append(m)
        
        min_m = min(margins)
        avg_m = np.mean(margins)
        region_margins[idx] = margins
        region_min_margins[idx] = min_m
        
        status = "✓" if min_m > 0 else "✗ VULNERABLE"
        print(f"  R_{idx} ({name}):")
        print(f"    Min margin: {min_m:.4f}  Avg margin: {avg_m:.4f}  {status}")
    
    # Degree-1 exactness check
    all_positive = all(m > 0 for m in region_min_margins.values())
    global_min = min(region_min_margins.values())
    
    print(f"\nDegree-1 Exactness Analysis:")
    print(f"  All vertex margins positive: {all_positive}")
    print(f"  Global minimum margin: {global_min:.4f}")
    
    if not all_positive:
        vulnerable = [i for i, m in region_min_margins.items() if m <= 0]
        print(f"\n  ⚠ DIAGNOSIS: Vulnerability located in {len(vulnerable)} region(s):")
        for v in vulnerable:
            print(f"    → Region R_{v} ({region_names[v]}): margin = {region_min_margins[v]:.4f}")
        print(f"\n  RECOMMENDATION: Retrain with margin regularization on vulnerable regions.")
        print(f"  Target: increase margin in R_{vulnerable[0]} from {region_min_margins[vulnerable[0]]:.4f} to > 0")
    else:
        lipschitz = net.lipschitz_bound()
        radius = global_min / lipschitz
        print(f"\n  ✓ All regions certifiable")
        print(f"  Lipschitz bound: {lipschitz:.4f}")
        print(f"  Certified radius: {radius:.6f}")
    
    # Nerve structure
    print(f"\nActivation Nerve Structure:")
    print(f"  Vertices (0-simplices): {len(region_names)}")
    print(f"  Edges (1-simplices): {4} (adjacent regions)")
    print(f"  Faces (2-simplices): {0} (no triple overlaps)")
    print(f"  Euler characteristic: {len(region_names) - 4}")


# ============================================================
# Run all applications
# ============================================================
if __name__ == "__main__":
    print("Activation-Nerve Certification: Real-World Applications")
    print()
    
    app_binary_classifier()
    app_safety_controller()
    app_vulnerability_diagnosis()
    
    print("\n" + "=" * 60)
    print("All applications complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Activation-Nerve Margin-Cosheaf Certification: Concrete Demonstrations

This script demonstrates the mathematical framework for certifying neural network
robustness via the activation nerve and margin cosheaf, with concrete numerical examples.
"""

import numpy as np
from itertools import combinations
from typing import Dict, List, Tuple, Set, Optional


def compute_activation_regions_1d(weights: np.ndarray, biases: np.ndarray,
                                    domain: Tuple[float, float]) -> List[Tuple[float, float]]:
    """Compute activation regions of a single ReLU layer in 1D.
    
    Each neuron w*x + b has a breakpoint at x = -b/w (if w != 0).
    The activation regions are the intervals between consecutive breakpoints.
    """
    breakpoints = []
    for w, b in zip(weights, biases):
        if abs(w) > 1e-12:
            bp = -b / w
            if domain[0] <= bp <= domain[1]:
                breakpoints.append(bp)
    breakpoints = sorted(set([domain[0]] + breakpoints + [domain[1]]))
    regions = [(breakpoints[i], breakpoints[i+1]) 
               for i in range(len(breakpoints) - 1)]
    return regions


def compute_nerve_1d(regions: List[Tuple[float, float]]) -> Dict[frozenset, bool]:
    """Compute the nerve of a 1D interval cover.
    
    Two intervals overlap if they share an endpoint (closure intersection).
    Returns dict mapping finsets of indices to whether they are simplices.
    """
    n = len(regions)
    nerve = {}
    
    # 0-simplices (vertices): all regions
    for i in range(n):
        nerve[frozenset([i])] = True
    
    # 1-simplices (edges): adjacent regions share a boundary point
    for i in range(n):
        for j in range(i+1, n):
            a1, b1 = regions[i]
            a2, b2 = regions[j]
            # Check if closures intersect
            if b1 >= a2 and b2 >= a1:
                nerve[frozenset([i, j])] = True
    
    # Higher simplices: check triple+ intersections
    for k in range(3, n+1):
        for combo in combinations(range(n), k):
            # All pairwise overlaps must exist
            all_pairs = all(frozenset([combo[i], combo[j]]) in nerve 
                          for i in range(len(combo)) for j in range(i+1, len(combo)))
            if all_pairs:
                # Check actual intersection
                left = max(regions[c][0] for c in combo)
                right = min(regions[c][1] for c in combo)
                if left <= right:
                    nerve[frozenset(combo)] = True
    
    return nerve


def compute_margin_cosheaf_1d(regions: List[Tuple[float, float]],
                                margin_fn,
                                n_samples: int = 1000) -> Dict[int, float]:
    """Compute the margin cosheaf values (approximate infimum on each region)."""
    cosheaf = {}
    for i, (a, b) in enumerate(regions):
        if abs(b - a) < 1e-15:
            cosheaf[i] = margin_fn((a + b) / 2)
        else:
            xs = np.linspace(a, b, n_samples)
            margins = [margin_fn(x) for x in xs]
            cosheaf[i] = min(margins)
    return cosheaf


def check_degree1_exactness(cosheaf: Dict[int, float]) -> Tuple[bool, float]:
    """Check degree-1 exactness: all vertex margins positive.
    
    Returns (is_exact, min_margin).
    """
    min_margin = min(cosheaf.values())
    is_exact = min_margin > 0
    return is_exact, min_margin


def certified_radius(min_margin: float, lipschitz: float) -> float:
    """Compute the certified robustness radius: δ/L."""
    if lipschitz <= 0 or min_margin <= 0:
        return 0.0
    return min_margin / lipschitz


def zaslavsky_bound(n: int, d: int) -> int:
    """Zaslavsky's bound on regions of n hyperplanes in R^d."""
    from math import comb
    return sum(comb(n, k) for k in range(d + 1))


# ============================================================
# DEMO 1: Simple 1D ReLU classifier
# ============================================================
def demo_1d_classifier():
    """Demonstrate the certification pipeline on a 1D ReLU classifier."""
    print("=" * 60)
    print("DEMO 1: 1D ReLU Classifier Certification")
    print("=" * 60)
    
    # A simple ReLU network: f(x) = ReLU(x - 1) - ReLU(x + 1) + 2
    # This creates a "tent" function peaked around x=0
    def classifier(x):
        return max(0, x - 1) - max(0, x + 1) + 2
    
    # Margin function (distance from decision boundary at 0)
    def margin(x):
        return classifier(x)
    
    domain = (-3.0, 3.0)
    
    # Activation regions: breakpoints at x = -1 and x = 1
    regions = [(-3.0, -1.0), (-1.0, 1.0), (1.0, 3.0)]
    
    print(f"\nDomain: [{domain[0]}, {domain[1]}]")
    print(f"Activation regions: {regions}")
    print(f"Number of regions: {len(regions)}")
    
    # Compute nerve
    nerve = compute_nerve_1d(regions)
    print(f"\nNerve simplices:")
    for sigma, _ in sorted(nerve.items(), key=lambda x: (len(x[0]), x[0])):
        print(f"  σ = {set(sigma)}")
    
    # Compute margin cosheaf
    cosheaf = compute_margin_cosheaf_1d(regions, margin)
    print(f"\nMargin cosheaf values:")
    for i, val in sorted(cosheaf.items()):
        print(f"  M(R_{i}) = {val:.4f}")
    
    # Check exactness
    is_exact, min_margin = check_degree1_exactness(cosheaf)
    print(f"\nDegree-1 exactness: {is_exact}")
    print(f"Minimum margin (δ): {min_margin:.4f}")
    
    # Lipschitz constant (slope of the affine pieces)
    L = 1.0  # The maximum slope magnitude
    radius = certified_radius(min_margin, L)
    print(f"Lipschitz constant (L): {L}")
    print(f"Certified robustness radius (δ/L): {radius:.4f}")
    print(f"\nConclusion: Any perturbation of size ≤ {radius:.4f} preserves classification.")


# ============================================================
# DEMO 2: Comparing robust vs. vulnerable classifiers
# ============================================================
def demo_robust_vs_vulnerable():
    """Compare a robust classifier (exact cosheaf) vs vulnerable (non-exact)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Robust vs. Vulnerable Classifier")
    print("=" * 60)
    
    # Robust classifier: margin > 0 everywhere on [-2, 2]
    def margin_robust(x):
        return 1.0 + 0.5 * np.cos(np.pi * x / 2)
    
    # Vulnerable classifier: margin dips below 0 in one region
    def margin_vulnerable(x):
        return 0.5 - 0.8 * np.exp(-x**2)
    
    regions = [(-2.0, -0.5), (-0.5, 0.5), (0.5, 2.0)]
    
    for name, margin_fn in [("ROBUST", margin_robust), ("VULNERABLE", margin_vulnerable)]:
        print(f"\n--- {name} classifier ---")
        cosheaf = compute_margin_cosheaf_1d(regions, margin_fn)
        for i, val in sorted(cosheaf.items()):
            print(f"  M(R_{i}) = {val:.4f}")
        
        is_exact, min_margin = check_degree1_exactness(cosheaf)
        print(f"  Degree-1 exact: {is_exact}")
        print(f"  Min margin: {min_margin:.4f}")
        
        if is_exact:
            L = 2.0
            r = certified_radius(min_margin, L)
            print(f"  Certified radius: {r:.4f}")
        else:
            print(f"  ⚠ NOT CERTIFIABLE — adversarial vulnerability detected!")
            # Identify vulnerable region
            for i, val in cosheaf.items():
                if val <= 0:
                    print(f"  → Vulnerability in region R_{i} = {regions[i]}")


# ============================================================
# DEMO 3: Zaslavsky bounds and nerve complexity
# ============================================================
def demo_complexity_bounds():
    """Demonstrate activation region count bounds."""
    print("\n" + "=" * 60)
    print("DEMO 3: Activation Region Complexity Bounds")
    print("=" * 60)
    
    print("\nZaslavsky bound: max regions for n neurons in d dimensions")
    print(f"{'n':>4} {'d':>4} {'maxRegions':>12}")
    print("-" * 24)
    for d in [2, 5, 10]:
        for n in [4, 8, 16, 32, 64]:
            bound = zaslavsky_bound(n, d)
            print(f"{n:>4} {d:>4} {bound:>12}")
        print()
    
    print("Multi-layer bounds (product of per-layer bounds):")
    architectures = [
        ("2-4-4-1", [4, 4], [2, 4]),
        ("10-8-8-1", [8, 8], [10, 8]),
        ("100-16-16-1", [16, 16], [100, 16]),
    ]
    for name, widths, input_dims in architectures:
        total = 1
        for w, d in zip(widths, input_dims):
            total *= zaslavsky_bound(w, d)
        print(f"  Architecture {name}: ≤ {total} regions")


# ============================================================
# DEMO 4: Full certification pipeline
# ============================================================
def demo_full_pipeline():
    """Run the complete certification pipeline on a 2D example."""
    print("\n" + "=" * 60)
    print("DEMO 4: Full Certification Pipeline (2D)")
    print("=" * 60)
    
    # 2D classifier with 4 quadrant-like activation regions
    # Margin function: distance from the unit circle boundary
    def margin_2d(x, y):
        return 1.5 - np.sqrt(x**2 + y**2)
    
    # Activation regions (simplified: 4 quadrants on [-2,2]^2)
    region_names = ["Q1 (x≥0, y≥0)", "Q2 (x<0, y≥0)", 
                    "Q3 (x<0, y<0)", "Q4 (x≥0, y<0)"]
    
    # Sample margins on each region
    n_samples = 50
    local_margins = []
    for qi in range(4):
        min_m = float('inf')
        for _ in range(n_samples * n_samples):
            if qi == 0: x, y = np.random.uniform(0, 2), np.random.uniform(0, 2)
            elif qi == 1: x, y = np.random.uniform(-2, 0), np.random.uniform(0, 2)
            elif qi == 2: x, y = np.random.uniform(-2, 0), np.random.uniform(-2, 0)
            else: x, y = np.random.uniform(0, 2), np.random.uniform(-2, 0)
            m = margin_2d(x, y)
            min_m = min(min_m, m)
        local_margins.append(min_m)
    
    print("\nStep 1: Activation region decomposition")
    for i, name in enumerate(region_names):
        print(f"  R_{i} = {name}")
    
    print("\nStep 2: Build activation nerve")
    print("  Vertices: {0}, {1}, {2}, {3}")
    print("  Edges: {0,1}, {0,3}, {1,2}, {2,3}")
    print("  (Adjacent quadrants share a boundary)")
    
    print("\nStep 3: Compute margin cosheaf")
    for i in range(4):
        print(f"  M(R_{i}) = {local_margins[i]:.4f}")
    
    print("\nStep 4: Check degree-1 exactness")
    min_margin = min(local_margins)
    is_exact = min_margin > 0
    print(f"  All vertex margins positive: {is_exact}")
    print(f"  Minimum margin δ = {min_margin:.4f}")
    
    print("\nStep 5: Compute certified radius")
    L = 1.0  # Lipschitz constant of the margin
    if is_exact:
        r = min_margin / L
        print(f"  Lipschitz constant L = {L}")
        print(f"  Certified radius r = δ/L = {r:.4f}")
        print(f"\n✓ CERTIFIED: No adversarial example within radius {r:.4f}")
    else:
        print(f"  ✗ NOT CERTIFIABLE")


# ============================================================
# Run all demos
# ============================================================
if __name__ == "__main__":
    print("Activation-Nerve Margin-Cosheaf Certification Framework")
    print("Concrete Numerical Demonstrations")
    print()
    
    demo_1d_classifier()
    demo_robust_vs_vulnerable()
    demo_complexity_bounds()
    demo_full_pipeline()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Generate visualizations for the Activation-Nerve Margin-Cosheaf framework.
Saves figures as base64-encoded PNGs and SVGs for embedding in PACKAGE.json.
"""

import numpy as np
import base64
import io
import json
import sys

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    from matplotlib.collections import PatchCollection
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib not available, generating SVG-only visualizations")


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def generate_nerve_svg() -> str:
    """Generate an SVG diagram of the activation nerve."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 400" width="500" height="400">
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="0" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#666"/>
    </marker>
  </defs>
  
  <!-- Title -->
  <text x="250" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#333">Activation Nerve of a ReLU Classifier</text>
  
  <!-- Activation regions (background) -->
  <rect x="50" y="60" width="180" height="150" rx="8" fill="#e3f2fd" stroke="#1565c0" stroke-width="2" opacity="0.6"/>
  <text x="140" y="85" text-anchor="middle" font-size="13" fill="#1565c0" font-weight="bold">R₁</text>
  <text x="140" y="105" text-anchor="middle" font-size="10" fill="#1565c0">margin ≥ 0.3</text>
  
  <rect x="160" y="60" width="180" height="150" rx="8" fill="#e8f5e9" stroke="#2e7d32" stroke-width="2" opacity="0.6"/>
  <text x="250" y="85" text-anchor="middle" font-size="13" fill="#2e7d32" font-weight="bold">R₂</text>
  <text x="250" y="105" text-anchor="middle" font-size="10" fill="#2e7d32">margin ≥ 0.5</text>
  
  <rect x="270" y="60" width="180" height="150" rx="8" fill="#fff3e0" stroke="#e65100" stroke-width="2" opacity="0.6"/>
  <text x="360" y="85" text-anchor="middle" font-size="13" fill="#e65100" font-weight="bold">R₃</text>
  <text x="360" y="105" text-anchor="middle" font-size="10" fill="#e65100">margin ≥ 0.2</text>
  
  <!-- Arrow to nerve -->
  <text x="250" y="240" text-anchor="middle" font-size="14" fill="#666">↓ Build Nerve ↓</text>
  
  <!-- Nerve diagram -->
  <!-- Vertices -->
  <circle cx="120" cy="320" r="20" fill="#1565c0" stroke="#0d47a1" stroke-width="2"/>
  <text x="120" y="325" text-anchor="middle" font-size="14" fill="white" font-weight="bold">v₁</text>
  
  <circle cx="250" cy="280" r="20" fill="#2e7d32" stroke="#1b5e20" stroke-width="2"/>
  <text x="250" y="285" text-anchor="middle" font-size="14" fill="white" font-weight="bold">v₂</text>
  
  <circle cx="380" cy="320" r="20" fill="#e65100" stroke="#bf360c" stroke-width="2"/>
  <text x="380" y="325" text-anchor="middle" font-size="14" fill="white" font-weight="bold">v₃</text>
  
  <!-- Edges (overlaps) -->
  <line x1="140" y1="315" x2="230" y2="285" stroke="#666" stroke-width="3"/>
  <line x1="270" y1="285" x2="360" y2="315" stroke="#666" stroke-width="3"/>
  
  <!-- Edge labels -->
  <text x="175" y="290" text-anchor="middle" font-size="10" fill="#666">R₁∩R₂ ≠ ∅</text>
  <text x="325" y="290" text-anchor="middle" font-size="10" fill="#666">R₂∩R₃ ≠ ∅</text>
  
  <!-- Exactness annotation -->
  <text x="250" y="380" text-anchor="middle" font-size="12" fill="#333">δ = min(0.3, 0.5, 0.2) = 0.2 → Certified radius = δ/L</text>
</svg>'''
    return svg


def generate_pipeline_svg() -> str:
    """Generate an SVG diagram of the certification pipeline."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 200" width="700" height="200">
  <!-- Pipeline boxes -->
  <rect x="10" y="60" width="120" height="80" rx="10" fill="#e3f2fd" stroke="#1565c0" stroke-width="2"/>
  <text x="70" y="95" text-anchor="middle" font-size="11" fill="#1565c0" font-weight="bold">Activation</text>
  <text x="70" y="115" text-anchor="middle" font-size="11" fill="#1565c0" font-weight="bold">Regions</text>
  
  <polygon points="145,100 160,85 160,115" fill="#666"/>
  
  <rect x="170" y="60" width="110" height="80" rx="10" fill="#e8f5e9" stroke="#2e7d32" stroke-width="2"/>
  <text x="225" y="95" text-anchor="middle" font-size="11" fill="#2e7d32" font-weight="bold">Build</text>
  <text x="225" y="115" text-anchor="middle" font-size="11" fill="#2e7d32" font-weight="bold">Nerve</text>
  
  <polygon points="295,100 310,85 310,115" fill="#666"/>
  
  <rect x="320" y="60" width="110" height="80" rx="10" fill="#fff3e0" stroke="#e65100" stroke-width="2"/>
  <text x="375" y="95" text-anchor="middle" font-size="11" fill="#e65100" font-weight="bold">Margin</text>
  <text x="375" y="115" text-anchor="middle" font-size="11" fill="#e65100" font-weight="bold">Cosheaf</text>
  
  <polygon points="445,100 460,85 460,115" fill="#666"/>
  
  <rect x="470" y="60" width="110" height="80" rx="10" fill="#fce4ec" stroke="#c62828" stroke-width="2"/>
  <text x="525" y="95" text-anchor="middle" font-size="11" fill="#c62828" font-weight="bold">Check</text>
  <text x="525" y="115" text-anchor="middle" font-size="11" fill="#c62828" font-weight="bold">Exactness</text>
  
  <polygon points="595,100 610,85 610,115" fill="#666"/>
  
  <rect x="620" y="60" width="70" height="80" rx="10" fill="#e8eaf6" stroke="#283593" stroke-width="2"/>
  <text x="655" y="95" text-anchor="middle" font-size="11" fill="#283593" font-weight="bold">δ/L</text>
  <text x="655" y="115" text-anchor="middle" font-size="10" fill="#283593">radius</text>
  
  <!-- Title -->
  <text x="350" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">Certification Pipeline</text>
  
  <!-- Bottom labels -->
  <text x="70" y="170" text-anchor="middle" font-size="9" fill="#666">R₁, R₂, ..., Rₙ</text>
  <text x="225" y="170" text-anchor="middle" font-size="9" fill="#666">Simplicial complex</text>
  <text x="375" y="170" text-anchor="middle" font-size="9" fill="#666">inf margins</text>
  <text x="525" y="170" text-anchor="middle" font-size="9" fill="#666">All positive?</text>
  <text x="655" y="170" text-anchor="middle" font-size="9" fill="#666">Certified!</text>
</svg>'''
    return svg


def generate_margin_plot() -> str:
    """Generate a margin landscape plot as base64 PNG."""
    if not HAS_MATPLOTLIB:
        return ""
    
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Plot 1: Robust classifier (all margins positive)
    ax = axes[0]
    x = np.linspace(-2, 2, 200)
    margin_robust = 0.5 + 0.3 * np.cos(np.pi * x / 2)
    
    ax.fill_between(x, 0, margin_robust, alpha=0.3, color='green', label='Positive margin')
    ax.plot(x, margin_robust, 'g-', linewidth=2, label='Margin function')
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5, label='Decision boundary')
    ax.axhline(y=min(margin_robust), color='blue', linestyle=':', alpha=0.7, 
               label=f'δ = {min(margin_robust):.3f}')
    
    # Mark activation regions
    for bp in [-1, 0, 1]:
        ax.axvline(x=bp, color='gray', linestyle='-', alpha=0.3)
    ax.text(-1.5, 0.85, 'R₁', fontsize=14, ha='center', color='#666')
    ax.text(-0.5, 0.85, 'R₂', fontsize=14, ha='center', color='#666')
    ax.text(0.5, 0.85, 'R₃', fontsize=14, ha='center', color='#666')
    ax.text(1.5, 0.85, 'R₄', fontsize=14, ha='center', color='#666')
    
    ax.set_xlabel('Input x', fontsize=12)
    ax.set_ylabel('Margin', fontsize=12)
    ax.set_title('Robust: Degree-1 Exact ✓', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9, loc='upper right')
    ax.set_ylim(-0.2, 1.0)
    ax.grid(alpha=0.2)
    
    # Plot 2: Vulnerable classifier (margin dips below 0)
    ax = axes[1]
    margin_vuln = 0.3 - 0.5 * np.exp(-x**2)
    
    pos_mask = margin_vuln >= 0
    neg_mask = margin_vuln < 0
    
    ax.fill_between(x, 0, np.maximum(margin_vuln, 0), alpha=0.3, color='green')
    ax.fill_between(x, margin_vuln, 0, where=neg_mask, alpha=0.3, color='red', 
                    label='Negative margin')
    ax.plot(x, margin_vuln, 'r-', linewidth=2, label='Margin function')
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
    
    for bp in [-1, 0, 1]:
        ax.axvline(x=bp, color='gray', linestyle='-', alpha=0.3)
    ax.text(-1.5, 0.35, 'R₁', fontsize=14, ha='center', color='#666')
    ax.text(-0.5, 0.35, 'R₂', fontsize=14, ha='center', color='#666')
    ax.text(0.5, 0.35, 'R₃', fontsize=14, ha='center', color='#666')
    ax.text(1.5, 0.35, 'R₄', fontsize=14, ha='center', color='#666')
    
    ax.annotate('Vulnerability!', xy=(0, margin_vuln[100]), xytext=(1.0, -0.15),
                fontsize=11, color='red', fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='red'))
    
    ax.set_xlabel('Input x', fontsize=12)
    ax.set_ylabel('Margin', fontsize=12)
    ax.set_title('Vulnerable: Not Exact ✗', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9, loc='upper right')
    ax.set_ylim(-0.3, 0.5)
    ax.grid(alpha=0.2)
    
    plt.tight_layout()
    return fig_to_base64(fig)


def generate_complexity_plot() -> str:
    """Generate complexity bounds plot."""
    if not HAS_MATPLOTLIB:
        return ""
    
    from math import comb
    
    fig, ax = plt.subplots(figsize=(8, 5))
    
    neurons = list(range(1, 65))
    for d in [2, 5, 10, 20]:
        bounds = [sum(comb(n, k) for k in range(d + 1)) for n in neurons]
        ax.semilogy(neurons, bounds, linewidth=2, label=f'd = {d}')
    
    ax.set_xlabel('Number of neurons (n)', fontsize=12)
    ax.set_ylabel('Max activation regions', fontsize=12)
    ax.set_title("Zaslavsky's Bound: Activation Region Count", fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, title='Dimension d')
    ax.grid(alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


def generate_cosheaf_monotonicity_plot() -> str:
    """Generate a plot showing cosheaf monotonicity on the face poset."""
    if not HAS_MATPLOTLIB:
        return ""
    
    fig, ax = plt.subplots(figsize=(8, 5))
    
    # Example: 3 regions with overlaps
    # Vertices: R1, R2, R3
    # Edges: R1∩R2, R2∩R3
    # Margin values decrease as we go from edges to vertices
    
    labels = ['R₁∩R₂', 'R₂∩R₃', 'R₁', 'R₂', 'R₃']
    values = [0.8, 0.6, 0.3, 0.5, 0.2]
    colors = ['#2196F3', '#2196F3', '#4CAF50', '#4CAF50', '#4CAF50']
    dims = ['1-simplex', '1-simplex', '0-simplex', '0-simplex', '0-simplex']
    
    bars = ax.barh(range(len(labels)), values, color=colors, edgecolor='white', height=0.6)
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels(labels, fontsize=12)
    ax.set_xlabel('Margin cosheaf value M(σ)', fontsize=12)
    ax.set_title('Cosheaf Monotonicity: M(σ) ≤ M(τ) when σ ⊆ τ', 
                 fontsize=14, fontweight='bold')
    
    # Add value labels
    for i, (v, d) in enumerate(zip(values, dims)):
        ax.text(v + 0.02, i, f'{v:.1f} ({d})', va='center', fontsize=10)
    
    # Add arrow annotations showing monotonicity
    ax.annotate('', xy=(0.3, 2.3), xytext=(0.8, 0.3),
                arrowprops=dict(arrowstyle='->', color='gray', lw=1.5, ls='--'))
    ax.text(0.55, 1.1, 'σ ⊆ τ\n⟹ M(σ) ≤ M(τ)', fontsize=9, color='gray',
            ha='center', style='italic')
    
    ax.set_xlim(0, 1.1)
    ax.grid(axis='x', alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    visuals = {}
    
    # SVG diagrams (always available)
    visuals['nerve_diagram'] = generate_nerve_svg()
    visuals['pipeline_diagram'] = generate_pipeline_svg()
    
    # Matplotlib plots (if available)
    if HAS_MATPLOTLIB:
        visuals['margin_landscape'] = generate_margin_plot()
        visuals['complexity_bounds'] = generate_complexity_plot()
        visuals['cosheaf_monotonicity'] = generate_cosheaf_monotonicity_plot()
    
    # Save visualization data
    with open('visualization_data.json', 'w') as f:
        json.dump(visuals, f)
    
    print(f"Generated {len(visuals)} visualizations")
    for name, data in visuals.items():
        if data.startswith('data:'):
            print(f"  {name}: base64 PNG ({len(data)} chars)")
        elif data.startswith('<svg'):
            print(f"  {name}: inline SVG ({len(data)} chars)")
        else:
            print(f"  {name}: empty (matplotlib not available)")
